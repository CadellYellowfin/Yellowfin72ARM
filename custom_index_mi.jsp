<%@page import="com.hof.manager.ConfigurationManager"%>
<%@page import="org.codehaus.groovy.tools.shell.commands.ShowCommand"%>
<%@page import="com.hof.manager.EventManager"%>
<%@page import="java.net.InetAddress"%>
<%! private static final String cvsId = "$Id: index_mi.jsp,v 1.56 2014/07/08 00:23:25 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://www.yellowfin.com.au/tags/yellowfin-app" prefix="app" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.text.*" %> 
<%@ page import="java.util.*" %>
<%@ page import="org.apache.struts.*" %>
<%@ page import="org.apache.struts.action.*" %>
<%@ page import="com.hof.data.*" %>
<%@ page import="com.hof.mi.models.*" %>
<%@ page import="com.hof.ip.web.form.LogonForm" %>
<%@ page import="com.hof.pool.DBConnectionManager" %>
<%@ page import="com.hof.process.PersonProcess" %>
<%@ page import="com.hof.process.ConfigurationProcess" %>
<%@ page import="com.hof.util.*" %>
<%

// check the database started up correctly.
// if not, redirect to an error page
DBConnectionManager manager = DBConnectionManager.getInstance();
if (!manager.isAppPoolInitialised()) {
   response.sendRedirect("startuperror.jsp");
   return;
}

// log on view model
final LogonViewModel vm = new LogonViewModelWeb(new SessionToken(request));

// check if 'remember me' redirect is required
if (LogonViewModel.LogonMode.RememberMe == vm.getLogonMode() && null != vm.getRememberMeRedirectURL()) {
	response.sendRedirect(vm.getRememberMeRedirectURL());
}

// setup form
LogonForm loForm = vm.getLogonForm();
if (loForm.getEmail() == null || loForm.getEmail().trim().length() == 0)
   loForm.setEmail("<Type your User Id>");

final boolean quick = vm.getLogonMode() == LogonViewModel.LogonMode.LogonAgain;
final String name = quick ? vm.getLoginAgainUsername() : null;

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

ActionErrors errors = (ActionErrors)request.getAttribute(Globals.ERROR_KEY);
boolean errorsExist = errors != null && !errors.isEmpty();

boolean showRegister = true;

ConfigurationBean cb = ConfigurationProcess.selectSystemParameter(null, Const.UNO, "REGISTER");

if(cb != null && "FALSE".equals(cb.getConfigData())) {
		showRegister = false;
}

%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="expires" content="<%=new java.util.Date(0)%>" />
<meta http-equiv="no-cache" />
<app:base/>
<title>Yellowfin Information Collaboration</title>
<link href="css/ie.css" rel="styleSheet" type="text/css" />
<link rel="icon" type="image/vnd.microsoft.icon" href="favicon.ico" />
<jsp:include page="includes/YFCommon.jsp"></jsp:include>

<script src="js/js.js"></script>
<script src="js/redshift/countries.js"></script>
<style type="text/css">
<!--
body
{
   margin: 0px;
}
.loginButton
{
	width: 80px;
	background:#009EEC;
	padding:6px;
	border:0px;
	border-radius: 5px; -o-border-radius: 5px; -icab-border-radius: 5px; -khtml-border-radius: 5px; -moz-border-radius: 5px; -webkit-border-radius: 5px; 
	behavior: url(css/PIE.htc);
	outline:0px;
	font-size:14px;
	color:white;
	text-align:center;
	cursor:pointer;
	position:relative;
}
div.loginButton img {
   margin-top: -3px;
   margin-left: 2px;
}
.loginContainer
{
	margin:5px;
	FONT-FAMILY: sourceSansPro, Arial, Helvetica, sans-serif;
	font-size:14px;
	float:right;
	color:#666;
}
.loginBox
{
	width: 160px;
	background:#DDD;
	padding:6px;
	border:0px;
	border-radius:5px;
	behavior: url(css/PIE.htc);
	outline:0px;
	position:relative;
	font-family: sourceSansPro, Arial, Helveica, sans-serif;
	font-size: 14px;
}
#loginBoxOutline
{
	width: 92px;
	padding:2px;
	background:#fff;
	border:0px;
	border-radius:5px;
	behavior: url(css/PIE.htc);
	outline:0px;
	position:relative;
	
}

.extraLinks {
	position:absolute;
	top:420px;
	left:500px;
	color: white;
	FONT-FAMILY: sourceSansProLight, Arial, Helvetica, sans-serif;
	font-size: 20px;
}

.extraLinks a {
	color: white;
	text-decoration: none;
	display:block;
	float:left;
	margin-top:6px;
	margin-left:5px;
}

.extraLinks img {
	float:left;
	display:block;
}

.extraLinks div {
	clear:both;
	overflow:hidden;
	margin-bottom:5px;
	margin-top:5px;
}

.contactFormTemplate {
	FONT-FAMILY: sourceSansProLight, Arial, Helvetica, sans-serif;
	font-size: 20px; 
	color: #666;
}

.contactFormTemplate .contactTitle {
	font-size: 32px;
	font-weight : normal;
	color : #009EEC;
	margin-bottom:5px;
	
}

.contactFormTemplate .contactSubTitle {
	font-size: 20px;
	font-weight : normal;
	color : #ADADAD;
	margin-bottom:15px;
}

.contactRow {
	clear:both;
	overflow:hidden;
}

.contactRow div {
	float: left;
	
}

.contactRow .rowOption {
	margin-right : 10px;
}

.contactFormTemplate .contactRowTitle {
	width : 300px;
	height : 50px;
}

.contactFormTemplate .endInfo {
	clear:both;
	margin-left:300px;
	margin-top:15px;
}

.contactFormTemplate .endInfo .extraInfoText {
	float:left;
}

.contactFormTemplate .endInfo .contactButtons div {
	margin-bottom: 5px;
}

.contactFormTemplate .endInfo .broadcastInputTextArea {
	height :60px;
	width: 425px;
}

#contactForm {
	display:none;
	width:835px;
	height:550px;
	position:fixed;
	z-index:50;
	background-color:#F6F6F6;
	padding: 10px 55px;
}


-->
</style>
<script src="js/window.js"></script>
<script src="js/EventObj.js"></script>
<script language="JavaScript">
<!--

function checkKey(e) {
   var key = e.keyCode;
   if (key == 13) {
      e.returnValue = false;
   }
}

function keypress(e, action) {
   if (e.keyCode == 13) {
      on_submit(action);
   }
}

// LogonForm submit routines
function on_submit(dest) {

   var objForm = document.LogonForm;
   var strMissingInfo = "";

   if (dest == 'logon') {  

      if (objForm.email.value == "")
         strMissingInfo += "\n  - <%= UtilString.getResourceString("error.logon.enter.user.id") %>" ;
      //else if (objForm.email.value.search("@") <= 0 || objForm.email.value.search("[.*]") == -1)
      //   strMissingInfo += "\n  - Enter a valid email address";

      // password validation

      if (objForm.password.value == "")
         strMissingInfo += "\n  - <%=UtilString.getResourceString("error.logon.enter.password")%>";
   }


   if (strMissingInfo != "")  {
      strMissingInfo =
         "\n\n<%= UtilString.getResourceString("error.login.msg") %>\n" +
         "__________________________________________\n" + strMissingInfo + 
         "\n__________________________________________\n" +
         "\n<%= UtilString.getResourceString("error.login.msg2") %>\n";
      alert(strMissingInfo);
   } else {
      objForm.action.value=dest;
      objForm.submit();
   }
}

    			
var registerView = null;
var demoView = null;

function loader() {
   MM_preloadImages(
      'images/go_over.gif'
   );

<% if (!quick) { %>
   document.LogonForm.email.focus();
   document.LogonForm.email.select();
<% } %>


<% if(showRegister) { %>

	require(['js/backbone/custom/redshift/view/ContactFormView'], function(cfv) {
		var contactOptions = [
		        				{ 
		      					title : 'Name', 
		      					inputType : 'TextInputView', 
		      					options : [
		      						{
		      							property : 'firstName',
		      							placeholder : 'First Name',
		      							textClassName : 'broadcastInput',
		      							mandatory : true
		      					 }, {
		      							property : 'lastName',
		      							placeholder : 'Last Name',
		      							textClassName : 'broadcastInput',
		      							mandatory : true
		      					 }
		      					] 
		      				},
		      				{
		      					title : 'Job Title',
		      					inputType : 'TextInputView',
		      					options : [{
		      						property : 'jobTitle',
		      						placeholder : 'Job Title',
		      						textClassName : 'broadcastInput',
		      						mandatory : true
		      					}]
		      				},
		      				{
		      					title : 'Contact',
		      					inputType : 'TextInputView',
		      					options : [{
		      						property : 'email',
		      						placeholder : 'Email',
		      						textClassName : 'broadcastInput',
		      						mandatory : true
		      					},{
		      						property : 'phone',
		      						placeholder : 'Phone',
		      						textClassName : 'broadcastInput',
		      						mandatory : true
		      					}]
		      				},	
		      				
		      				{
		      					inputType : 'DropDownView',
		      					options : [{
		      						property : 'country',
		      						optionsList : countries,
		      						divClassName : 'styledSelect',
		      						mandatory : true,
		      						placeholder : 'Country'
		      					},
		      					{
		      						property : 'state',
		      						optionsList : states['empty'],
		      						divClassName : 'styledSelect',
		  							parentProperty : 'country',
		  							//madatory : true,
		  							placeHolder : 'State'
		      					}],
		      				},
		      				
		      				{
		      					title : 'Company',
		      					inputType : 'TextInputView',
		      					options : [{
		      						property : 'company',
		      						placeholder : 'Company Name',
		      						textClassName : 'broadcastInput',
		      						mandatory : true
		      					},{
		      						property : 'companyURL',
		      						placeholder : 'Website',
		      						textClassName : 'broadcastInput'
		      					}]
		      				},
		      				
		      				{
		      					title : 'Proposed Interest',
		      					inputType : 'RadioButtonListView',
		      					options : [{
		      						property : 'interest',
		      						optionsList : [{
		      							value : "CUSTOMER", description : "Customer"
		      						},
		      						{
		      							value : "RESELLER", description : "Reseller"
		      						},
		      						{
		      							value : "ISVPARTNER", description : "ISV Partner"
		      						}]
		      					}]
		      				}
		      			];
		registerView = new cfv({
			title : 'Thanks for choosing try Yellowfin',
			subTitle : 'To register your 1 year evaluation copy of Yellowfin, please complete the registration form below',
			contactOptions : contactOptions,
			el : $('#contactForm'),
			contactUrl : 'RedshiftAjax.i4',
			ajaxData : {
				action : 'register',
				calledFrom : 'Azure',
				refer : 'Azure',
				ajaxAction : 'AzureAjax.i4'
			},
			contactSuccess : function(result) {
				$('#contactForm').hide();
				$('#registerLink').hide();
				$('#emailSent').show();
				alert("You have successfully submitted your details.");
			}
		});
		registerView.listenTo(registerView, 'close', hideContactForm);
	});
	
	<%}%>
}

function hideContactForm() {
	$('#contactForm').hide();
}

function showRegister() {
	registerView.render();
	var $el = $('#contactForm');
	centreElement($el)
	$el.show();
}

function centreElement($el) {
	var width = $el.width();
	var height = $el.height();
	
	var windowHeight = $(window).height();
	var windowWidth = $(window).width();
	
	var left = (windowWidth / 2) - (width / 2);
	var top = (windowHeight / 2) - (height / 2);
	
	$el.css({
		left : left + 'px',
		top : top + 'px'
	});
	
	
}

var cleared = false;
function emailOnClick(e) {
   var eo = new EventObj(e, this);
   if (!cleared && document.LogonForm.email.value == '<Type your User Id>') {
      document.LogonForm.email.value = '';
      cleared = true;
      eo.preventDefault();
      return false;
   }
}

function forgotPassword() {
	
	NewWindow('PasswordForgotten.i4?return=blank', 'ForgotPassword', 300, 500);
	
}

function toggleRememberMe() {
	
	document.LogonForm.rememberMe.checked=!document.LogonForm.rememberMe.checked;
	
}

function logonFocus(focus)
{
	if(focus)
	{
		getObj('loginBoxOutline').style.background="#ddd";
	}
	else
	{
		getObj('loginBoxOutline').style.background="white";
	}
}

function logonKeyDown(event)
{
	if (event.keyCode == 13)
	{
		on_submit('logon');
	}
}

//-->
</script>

<!-- Include custom css here. This should be after any other css includes. -->
<link rel="stylesheet" type="text/css" href="css/CustomCSS.i4" />
</head>
<body onload="loader()" onKeyPress="checkKey(event)" style="background:#DFDFDF;">
<div style="background:white">
	<div style="margin: 0px auto;width:945px">
		<html:form action="logon.i4">
<% //if(!showRegister) { %>
	<table border="0" cellpadding="0" cellspacing="0" width="945">
	<% if (errorsExist) { %>
	  <tr>
	    <td width="234">&nbsp;</td>
	    <td width="250">&nbsp;</td>
	    <td width="388"><br /><html:errors /></td>
	  </tr>
	<% } %>
	  <tr>
	    <td width="234"><img src="images/logo.png" class="tpng" style="margin-top:10px;margin-left:10px;" border="0" alt="" /></td>
	    <td width="250">&nbsp;</td>
	    <td width="388"  height="90">
	
	        <table border="0" cellpadding="2" cellspacing="1" width="100%">
	        
	        <input type="hidden" name="org" value="<%=vm.getIpOrg()%>" />
	        <input type="hidden" name="<%=Const.INDEX_PAGE%>" value="/custom_index_mi.jsp" />
	        <input type="hidden" name="action" />
	 <% if (quick) { %>
	          <tr>
	            <td class="i4bodytext" align="center"><bean:message key="mi.text.loginas" arg0="<%=name%>" /></td>
	          </tr>
	          <tr>
	            <td class="i4bodytext" align="center">
	              <a href="javascript:on_submit('quickLogon');"><bean:message key="mi.text.loginagain" /></a>
	              &nbsp;&nbsp;&nbsp;
	              <a href="javascript:on_submit('logonMain');"><bean:message key="mi.text.loginanotheruser" /></a>
	            </td>
	          </tr>
	<% } else { 
	
		String autoComplete = "off";
		//if (vm.getAutoCompleteOption()) autoComplete = "on";
		
	%>
	
	          <input type="hidden" name="clientReferenceId" value="" />
	          <tr>
	            <td width="20">&nbsp;</td>
	             <td width="132"><div class="loginContainer">
			<span style="display:block">&nbsp;<app:message key="mi.text.login.username" />: </span>
			<html:text tabindex="1" property="email" onmousedown="emailOnClick(event);"  styleClass="loginBox" />
		</div></td>
	            <td width="132">
	            
	            <div class="loginContainer ">
					<span style="display:block">&nbsp;<app:message key="mi.text.password" />: </span>
					<input type="password" autocomplete="<%= autoComplete %>" tabindex="2" name="password" value="" onkeypress="keypress(event, 'logon');" class="loginBox" />
				</div>
	            
	            </td>
	            <td width="60">
	            	<div class="loginContainer">
						<br/>
						<div id="loginBoxOutline" >
							<div id="logonButton" onclick="on_submit('logon');" class="loginButton">
								<a href="javascript:;" style="color:white;text-decoration:none;outline:0px;" onfocus="logonFocus(true)" onblur="logonFocus(false)" onkeydown="logonKeyDown(event)" tabindex="3">
									<bean:message key="mi.text.login" />
								</a> 
							</div>
						</div>
					</div>
				</td>
	          </tr>
	          <tr>
	            <td width="20">&nbsp;</td>
	            <td width="132">&nbsp;</td>
	            <td colspan="2">
	            
	            	<table width="100%" cellpadding="0" cellspacing="0">
	            	 <tr>
	            	  <td align="left">&nbsp;
	            	<% if (vm.getRecoverPassword()) { %> 
	            		<a class="i4bodytext" href="javascript:forgotPassword();"><app:message key="mi.text.forgotten.password" /></a>
	                <% } %>
	            	</td>
	            	<td align="right">
	            	
	            	<% if (vm.getRememberMeOption()) { %> 
	            	
	            			<input type="checkbox" name="rememberMe" value="true">
	            			<a class="i4bodytext" style="color: black;" href="javascript:toggleRememberMe();"><app:message key="mi.text.rememberme.option" /></a>
	            		
	            	<% } %>
	            	</td></tr></table>
	            	
	            
	            </td>&nbsp;
	         </tr>
	          

	<% } %>
	       
	        </table>
	 
	   </td>
	  </tr>
	</table>
	<% //} %>
	 </html:form>
	</div>
</div>
<div style="background:#1171B7;" >
	<div style="width:945px; margin:0px auto; position:relative">
		<img src="images/redshiftwelcome/red_shift_welcome.jpg" style="margin: 0px auto;display:block"/>
	
		<div class="extraLinks">
			<% if(showRegister) { %>
			<div id = "registerLink">
				<img src="images/redshiftwelcome/Register.png" />
				<a href="javascript:showRegister()">Register to receive your login</a>
			</div>
			<p id="emailSent" style="margin:0;top:-10px;position:relative;display:none">Thanks for signing up!<br/>Please check your email for the username and password.</p>
			<% } %>
		</div>
	</div>
</div>

<div id="contactForm">
</div>
<div style="margin: 0px auto;display:block;width:945px">

<jsp:include page="includes/StandardFooter.jsp">
	<jsp:param value="TRUE" name="loginPage"/>
</jsp:include>
</div>
</body>
</html>

