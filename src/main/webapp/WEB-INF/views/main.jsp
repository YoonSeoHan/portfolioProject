<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<meta charset="utf-8">

<head>

<link rel="shortcut icon" href="">
<link rel="stylesheet" type="text/css" href="resources/css/main.css">
<script src="//code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/rsa_js/jsbn.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/rsa_js/prng4.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/rsa_js/rng.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/rsa_js/rsa.js"></script>

<script>


	$(document).ready(function() {
		var rsa = new RSAKey();

		var sessionName = "<%=(String)session.getAttribute("username")%>"
		if(sessionName == 'null'){
			$('.login-window').text('Login');
		} else{
			$('.login-window').text('Logout');
			$('.login-window').attr('class','logout-window');
		}

		var jbOffset = $('.main_header').offset();
		$(window).scroll(function() {
			if ($(document).scrollTop() > jbOffset.top) {
				$('.main_header').addClass('header_fixed');
			} else {
				$('.main_header').removeClass('header_fixed');
			}
		});

		$('#menu_bar_open, #menu_bar_close').click(function() {
			if ($('#drop_menu').css('display') == 'none') {
				$('#drop_menu').css('display', 'contents');
				$('#menu_bar_open').attr('id', 'menu_bar_close');
			} else {
				$('#drop_menu').css('display', 'none');
				$('#menu_bar_close').attr('id', 'menu_bar_open');
			}
		});

		var typingBool = false;
		var typingIdx = 0;
		var typingTxt = $('.typing-txt').text(); // 타이핑될 텍스트를 가져온다 
		typingTxt = typingTxt.split(""); // 한글자씩 자른다. 
		if (typingBool == false) { // 타이핑이 진행되지 않았다면 
			typingBool = true;

			var tyInt = setInterval(typing, 100); // 반복동작 
		}

		function typing() {
			if (typingIdx < typingTxt.length) { // 타이핑될 텍스트 길이만큼 반복 
				$(".typing").append(typingTxt[typingIdx]); // 한글자씩 이어준다. 
				typingIdx++;
			} else {
				clearInterval(tyInt); //끝나면 반복종료 
			}
		}

		$('.header_menu li, #drop_menu li').on('click', function(e) {
			var page = $(this).attr('value');
			var offset = $('#' + page).offset();
			$('html, body').animate({
				scrollTop : offset.top
			}, 400);
		})

		$('a.login-window').click(function() {

			//Getting the variable's value from a link 
			var loginBox = $(this).attr('href');

			//Fade in the Popup
			$(loginBox).fadeIn(300);

			//Set the center alignment padding + border see css style
			var popMargTop = ($(loginBox).height() + 24) / 2;
			var popMargLeft = ($(loginBox).width() + 24) / 2;

			$(loginBox).css({
				'margin-top' : -popMargTop,
				'margin-left' : -popMargLeft
			});

			// Add the mask to body
			$('body').append('<div id="mask"></div>');
			$('#mask').fadeIn(300);

			$.ajax({
				type: "GET", //요청 메소드 방식
				url:"/login_action.ajax",
				contentType: 'application/json; charset=utf-8',
				dataType : "json",
				async:true,
				success : function(data){
					//서버의 응답데이터가 클라이언트에게 도착하면 자동으로 실행되는함수(콜백)
					// Server로부터 받은 공개키 입력
					rsa.setPublic(data.modulus, data.exponent);
				},
				error: function (request, status, error) {
					alert("code:" + request.status + "\n" + "message:"
							+ request.responseText + "\n" + "error:" + error);
				}
			});
			return false;
		});


		$('a.logout-window').click(function() {

			<%session.removeAttribute("username");%>
			document.location.href= "/";
		});


		

		// When clicking on the button close or the mask layer the popup closed
		$('a.close, #mask').on('click', function() {

			$('#mask , .login-popup').fadeOut(300, function() {
				$('#mask').remove();
			});

			return false;
		});

		/* =========================================================== */
		var $username = $("#hiddenForm input[name='username']");
		var $password = $("#hiddenForm input[name='password']");

		

		$("#loginForm").submit(function(e) {
			// 실제 유저 입력 form은 event 취소
			// javascript가 작동되지 않는 환경에서는 유저 입력 form이 submit 됨
			// -> Server 측에서 검증되므로 로그인 불가
			e.preventDefault();

			/* 아이디/패스워드 암호화 */
			var username = rsa.encrypt($(this).find("#username").val()); 
			var password = rsa.encrypt($(this).find("#password").val());			

			$.ajax({
				type: "POST", //요청 메소드 방식
				url:"/login_action.ajax",
				dataType : "json",
				data : { "username": username, "password": password },
				async:false,
				success : function(data){
					document.location.href= "/";
				},
				error: function (request, status, error) {
					alert("code:" + request.status + "\n" + "message:"
							+ request.responseText + "\n" + "error:" + error);
					alert('비정상 적인 접근 입니다.');
					document.location.href= "/";
				}
			});
			
		});

	});
</script>

</head>
<body style="margin: 0; padding: 0;">

	<div id="wrap">
		<div id="login-box" class="login-popup">
			<a href="#" class="close"> <img
				src="${pageContext.request.contextPath}/resources/img/close_pop.jpg"
				class="btn_close" title="Close Window" alt="Close" /></a>

			<form method="post" class="signin" action="login_action.do" id="loginForm">
				<fieldset class="textbox">
					<label class="username"> <span>Username</span> <input
						id="username" name="username" value="" type="text"
						autocomplete="on" placeholder="Username">
					</label> <label class="password"> <span>Password</span> <input
						id="password" name="password" value="" type="password"
						placeholder="Password">
					</label>
					<button class="submit button" type="submit">Sign in</button>
				</fieldset>
			</form>
		</div>

		<div class="main_header">
			<ul class="header_menu">
				<li value="main_bg">Home</li>
				<li value="main_about">About</li>
				<li value="main_skills">Skills</li>
				<li value="main_project">Project</li>
				<li>Contact</li>
				<li><a href="#login-box" class="login-window">Login</a></li>
			</ul>
		</div>

		<div class="main_header_bar">
			<div id="menu_bar_open">
				<div class="bar1"></div>
				<div class="bar2"></div>
				<div class="bar3"></div>
			</div>
			<ul id="drop_menu">
				<li value="main_bg">Home</li>
				<li value="main_about">About</li>
				<li value="main_skills">Skills</li>
				<li value="main_project">Project</li>
				<li>Contact</li>
				<li>Login</li>
			</ul>
		</div>

		<div id="main_bg">
			<p class="typing-txt">Developer 한윤서의 포트폴리오 입니다.</p>
			<p class="typing"></p>
		</div>

		<div id="main_about">
			<div>About me</div>
			<section>
				<h1>Good developer</h1>
				<p>학창시절 IT에 관심이 많아 C언어를 혼자서 공부를 하고 홈페이지를 개발 했습니다. 처음에는 많은것이
					미흡했으나 모르던 것을 깨닫고 조금씩 개발하여 완성시켰을때 왠지모를 희열감과 뿌듯함이 있었습니다. 이후 점점 더 재미를
					느끼기 시작하여 마음이 맞는 친구들과 함께 배달어플등도 만들며 개발자로서의 꿈을 키우기 시작했습니다.</p>

				<p>저는 잘하는 개발자가 될 것입니다.IT에서 빠르게 변화하는 최신 기술 동향을 따라잡기 위해 계속해서 공부를
					하고 프로젝트 개발시 반드시 필요한 덕목인 팀원과의 의사 소통과 문제 해결 능력을 가지고 있는 개발자가 되겠습니다.</p>

			</section>
		</div>
		<div id="main_skills">
			<h1>Skills</h1>
			<div id="skills_content">
				<h2 class="skills_title">Launage</h2>

				<div class="skills_img">

					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_java.jpg">
						<div class="mouse_ov">JAVA</div>
					</div>

					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_js.jpg">
						<div class="mouse_ov">SCRIPT</div>
					</div>
				</div>

				<h2 class="skills_title">Web Skils</h2>
				<div class="skills_img">
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_html5.jpg">
						<div class="mouse_ov">HTML5</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_css3.jpg">
						<div class="mouse_ov">CSS3</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_js.jpg">
						<div class="mouse_ov">SCRIPT</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_jquery.jpg">
						<div class="mouse_ov">JQUERY</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_jsp.jpg">
						<div class="mouse_ov">JSP</div>
					</div>
				</div>


				<h2 class="skills_title">FrameWork</h2>
				<div class="skills_img">
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_spring.jpg">
						<div class="mouse_ov">SPRING</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_mybatis.jpg">
						<div class="mouse_ov">MYBATIS</div>
					</div>
				</div>

				<h2 class="skills_title">DataBase</h2>
				<div class="skills_img">
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_oracle.jpg">
						<div class="mouse_ov">ORACLE</div>
					</div>
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_mysql.jpg">
						<div class="mouse_ov">MYSQL</div>
					</div>
				</div>

				<h2 class="skills_title">Operating System</h2>
				<div class="skills_img">
					<div class="img_overay">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/skills_window.jpg">
						<div class="mouse_ov">WINDOW</div>
					</div>
				</div>

			</div>
		</div>


		<div id="main_project">
			<h1>Project</h1>
			<div class="project_wrap">
				<div class="project_content">
					<div class="project_img">
						<img alt=""
							src="${pageContext.request.contextPath}/resources/img/project_shoppingmall.jpg">
					</div>
					<div class="project_account">
						<ul>
							<li>Sense Of Light</li>
							<li>개발기간 :2019.07 ~ 2019.10</li>
							<li>Spring + Jquery + Mybatis + Mysql을 이용하여 일반적인 쇼핑몰 대부분의
								기능을 구현한 조명 쇼핑몰입니다. MVC패턴,게시판,CRUD,비동기통신 + Transection처리</li>
							<li>#Spring#Juqery#Mybatis#Mysql#tiles</li>
							<li><a
								href="https://github.com/YoonSeoHan/springProject.git"
								target="_blank"> <img alt=""
									src="${pageContext.request.contextPath}/resources/img/github_icon.jpg">
							</a></li>
						</ul>
					</div>
				</div>
			</div>
		</div>

	</div>
</body>
</html>