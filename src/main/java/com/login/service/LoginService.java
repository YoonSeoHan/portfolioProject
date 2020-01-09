package com.login.service;

import com.login.dao.LoginVo;

public interface LoginService {

	public int loginAction(LoginVo vo) throws Exception;
}
