package com.login.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.PrivateKey;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.login.dao.LoginVo;
import com.login.service.LoginService;
import com.rsa.util.RSA;
import com.rsa.util.RSAUtil;

import net.sf.json.JSONObject;

@Controller
public class LoginController {

	@Autowired
	RSAUtil rsaUtil;
	@Autowired
	LoginService loginSvc;

	private static int USER_LOGIN_FAIL = 0;
	private static int USER_LOGIN_SUCCES = 1;

	@RequestMapping(value = "/login_action.ajax", method = RequestMethod.GET)
	public void loginForm(HttpSession session, Model model, HttpServletResponse res) {
		// RSA 키 생성
		PrivateKey key = (PrivateKey) session.getAttribute("RSAprivateKey");
		if (key != null) { // 기존 key 파기
			session.removeAttribute("RSAprivateKey");
		}

		RSA rsa = rsaUtil.createRSA();

		model.addAttribute("modulus", rsa.getModulus());
		model.addAttribute("exponent", rsa.getExponent());
		session.setAttribute("RSAprivateKey", rsa.getPrivateKey());

		JSONObject obj = new JSONObject();

		obj.put("modulus", rsa.getModulus());
		obj.put("exponent", rsa.getExponent());

		try {
			res.setContentType("application/json; charset=UTF-8");
			PrintWriter pw = res.getWriter();
			pw.print(obj.toString());
			pw.flush();

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	@RequestMapping(value = "/login_action.ajax", method = RequestMethod.POST)
	@ResponseBody
	public void loginAction(HttpServletRequest req, HttpServletResponse res, HttpSession session, LoginVo vo) {
		PrivateKey key = (PrivateKey) session.getAttribute("RSAprivateKey");
		

		// key는 로그인 모달을 불러올때 ajax통신으로 생성하도록 되어있음 만약 null값이면 문제가 생겼다는 얘기 null시 강제 exception처리
		if (key == null) {
			try {
				// 예외 발생
				throw new Exception(); 
			} catch(Exception e) {
				System.out.println("Exception");
			}
		}

		// session에 저장된 개인키 초기화
		session.removeAttribute("RSAprivateKey");
		
		// 아이디/비밀번호 복호화
		try {
			String username = rsaUtil.getDecryptText(key, req.getParameter("username"));
			String password = rsaUtil.getDecryptText(key, req.getParameter("password"));

			// 복호화된 평문을 재설정
			vo.setUsername(username);
			vo.setPassword(password);

		} catch (Exception e) {
			e.printStackTrace();
		}

		// 로그인 로직
		// 로그인 실패 or 복호화 실패시 redirect
		try {
			int rs = loginSvc.loginAction(vo);
			JSONObject obj = new JSONObject();

			if (rs == USER_LOGIN_SUCCES) {
				obj.put("login", "success");
				session.setAttribute("username", vo.getUsername());
				session.setMaxInactiveInterval(60);
				System.out.println(session.getAttribute("username"));
			} else if (rs == USER_LOGIN_FAIL) {
				obj.put("login", "fail");
			}

			try {
				res.setContentType("application/json; charset=UTF-8");
				PrintWriter pw = res.getWriter();
				pw.print(obj.toString());
				pw.flush();

			} catch (IOException e) {
				e.printStackTrace();
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
