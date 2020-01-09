package com.login.dao;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class LoginDaoImpl implements LoginDao{
	
	@Autowired
	SqlSession sqlsession;
	private static final String Namespace = "classpath:/sqlmap/mapper/loginMap";
	
	
	@Override
	public int loginAction(LoginVo vo) {
		int rs = sqlsession.selectOne(Namespace+".selectLogin", vo);
		
		return 1;
	}
}
