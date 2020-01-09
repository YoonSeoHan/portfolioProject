package com.login.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.login.dao.LoginDao;
import com.login.dao.LoginVo;

@Service
public class LoginServiceImpl implements LoginService{
	
	@Autowired
	LoginDao loginDao;
	
	@Override
	public int loginAction(LoginVo vo) throws Exception{
		
		return loginDao.loginAction(vo);
	}
	
}
