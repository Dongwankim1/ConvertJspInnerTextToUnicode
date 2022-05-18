<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/cmmn/frd_libs.jsp" %>
<%
 /**
  * @Class Name : 파일 진단 관리
  * @Description : FTP 진단관리 설정
  * @Modification Information
  * - AS-IS 코드 : ftp_form.jsp
  *
  * @author FRD kss
  * @since 2021.08.27
  * @version 2.0
  * @see
  *
  * Copyright (C) Jirandata. All right reserved.
  */
%>

<script type="text/javascript" src="resources/plugins/angular/angular.min.js"></script>

<link rel="stylesheet" href="resources/plugins/multiselect/bootstrap-multiselect.css" type="text/css">
<script type="text/javascript" src="resources/plugins/multiselect/bootstrap-multiselect.js"></script>
                                      
<script type="text/javaScript" language="javascript" defer="defer">

//---------------------------------------------
//Angular를 이용하여 view변경 테스트
//---------------------------------------------	
var app = angular.module('mainApp', []);
app.controller('mainCtrl', function($scope, $http) {
	$scope.viewData = {};

	var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
	if(!isIE11) {
		// 멀티 select 체크수행
		$scope.setMultiChkOpt = function (opts, chkVal) {

			return opts.includes(chkVal);
		};
	}else{
		$scope.setMultiChkOpt = function (opts, chkVal) {

			var returnValue = false;

			if (opts.indexOf(chkVal) !== -1) {
				returnValue = true;
			}
			return returnValue;
		};
	}
	// 진단필터 전체선택 수행
	$scope.checkAll= function() {				
		//$scope.viewData.checkAllFlag = $(".checkAll").prop("checked");

		var chk_value = $(".checkAll").prop("checked") ? "Y" : "N";
		// 전체 체크박스 상태 적용
		$scope.viewData.privRrno=chk_value; //주민등록번호
		$scope.viewData.privRrnoi=chk_value; //신주민등록번호
		$scope.viewData.privIf=chk_value; //외국인등록번호
		$scope.viewData.privPass=chk_value; //여권번호
		$scope.viewData.privCar=chk_value; //운전면허번호
		$scope.viewData.privCard=chk_value; //카드번호	
		$scope.viewData.privBank=chk_value; //계좌번호
		$scope.viewData.privHealth=chk_value; //건강보험번호
		$scope.viewData.privHand=chk_value; //휴대전화번호
		$scope.viewData.privPhone=chk_value; //일반전화번호
		$scope.viewData.privEmail=chk_value; //이메일
		$scope.viewData.privCorp=chk_value; //법인번호
		$scope.viewData.privEnter=chk_value; //사업자등록번호
		$scope.viewData.privArmy=chk_value; //군번	
		
		// 전체선택 해제시 관련 체크박스 해제
		if(!$(".checkAll").prop("checked")) {
			$(".checkFilterTy1").prop("checked", false);
			$(".checkFilterTy2").prop("checked", false);
			$(".privSetting").prop("checked", false);
		} else {
			$(".checkFilterTy1").prop("checked", true);
			$(".checkFilterTy2").prop("checked", true);
			$(".privSetting").prop("checked", true);
		}
	}
	
	// 고유식별정보 일괄 체크

	$scope.checkFilterTy1 = function() {
		var chk_value = $(".checkFilterTy1").prop("checked") ? "Y" : "N";		
		//$scope.viewData.checkAllFlag = $(".checkFilterTy1").prop("checked");
		
		// 일괄 체크박스 상태 적용
		$scope.viewData.privRrno=chk_value; //주민등록번호
		$scope.viewData.privRrnoi=chk_value; //신주민등록번호
		$scope.viewData.privIf=chk_value; //외국인등록번호
		$scope.viewData.privPass=chk_value; //여권번호
		$scope.viewData.privCar=chk_value; //운전면허번호
		
		$(".needablePrivacy").prop("checked", $(this).prop("checked"));
	}

	// 기타개인정보 일괄 체크
	$scope.checkFilterTy2 = function() {	
		var chk_value = $(".checkFilterTy2").prop("checked") ? true : false;
		//$scope.viewData.checkAllFlag = $(".checkFilterTy2").prop("checked");
		// 일괄 체크박스 상태 적용
		$scope.viewData.privCard=chk_value; //카드번호	
		$scope.viewData.privBank=chk_value; //계좌번호
		$scope.viewData.privHealth=chk_value; //건강보험번호
		$scope.viewData.privHand=chk_value; //휴대전화번호
		$scope.viewData.privPhone=chk_value; //일반전화번호
		$scope.viewData.privEmail=chk_value; //이메일
		$scope.viewData.privCorp=chk_value; //법인번호
		$scope.viewData.privEnter=chk_value; //사업자등록번호
		$scope.viewData.privArmy=chk_value; //군번
		
		$(".choicePrivacy").prop("checked", $(this).prop("checked"));

	}
	
	// GDPR필터 전체선택 수행
	$scope.checkAllGdpr= function() {				
		//$scope.viewData.checkAllFlag = $(".checkAllGdpr").prop("checked");
		
		//var chk_value = $(".checkAllGdpr").prop("checked") ? "Y" : "N";
		// 전체 체크박스 상태 적용
		$(".asso_codes").prop("checked", $(".checkAllGdpr").prop("checked"));
	}

	
});
//---------------------------------------------	

// 등록 전 ftp연결 확인
var connectChk = true;

/**************************************************
 *  document ready function 
 **************************************************/
$(document).ready(function(){
	
	//console.log('${command}');


	// 조회정보를 화면에 매핑한다.
	var jsonResult = {};
	var jsonMonitorVOs = [];
	var jsonPrivCodeVOs = [];	// Gdpr필터 목록
	
	if('NEW' == ('${command}')){
		// 기본값 설정
		jsonResult = {server_id:'${server_id}', group_id:'${group_id}', user_name : '${sessionScope.loginUserName}', ftp_type : 'S', ftp_search_type:'F', check_type:'A', sync_chk:'N', key_certification_type:'P'};	// privRrno:'Y' - 신규 기본체크
		
		// 그룹설정값을 기본값으로 표시함
		var jsonFtpSettingVO = JSON.parse('${ftpSettingVO}');
		jsonFtpSettingVO.file_ext_type = 'N'
		jsonFtpSettingVO.file_size_min = '20'
		jsonFtpSettingVO.file_size = '100'
		jsonFtpSettingVO.file_ext = 'avi,mpg,mov,dvd,wmv,mpeg,vob,flv,skm,mkv,mp3,ape,cda,flac,m3u,mid,mp1,mp2,mp3,ogg,wav,wma,jpg,jpeg,jpe,jfif,gif,tif,tiff,png,bmp'
		jsonFtpSettingVO.bandwidth = '20';
		jsonFtpSettingVO.system_directory = '/boot/,/bin/,/dev/,/etc/,/lib/,/lib64/,/lostfound/'
		$.extend(true, jsonResult, jsonFtpSettingVO);

	}
	else if('UPDATE' == ('${command}')){
		jsonResult = JSON.parse('${jsonResult}');		
	}

	// form 입력 actionType
	jsonResult.command = '${command}';

	//특수문자 입력방지
	$("#site_name").fn_isDomainName();
	$("#site_domain").fn_isDomainName();

	// 요일별 진단 설정
	if(fn_isNotEmpty('${jsonMonitorVOs}')) {
		jsonMonitorVOs = JSON.parse('${jsonMonitorVOs}');
		//console.log('jsonMonitorVOs', jsonMonitorVOs);
	}
	
	// Gdpr필터 설정 목록
	if(fn_isNotEmpty('${privCodeVOs}')) {
		try{
			jsonPrivCodeVOs = JSON.parse('${privCodeVOs}');
			jsonResult.privCodeVOs = jsonPrivCodeVOs;
			//console.log('privCodeVOs', jsonPrivCodeVOs);
		}catch(e){}
	}

	//예약설정 시간설정이 월일경우 span 활성화
	if(jsonResult.re_dates_ftp=="month"){
		document.getElementById("re_month_span").style.display="block";

	}else{
		document.getElementById("re_month_span").style.display="none";
	}

	// 요일별 동작시간 - 서버에서 조회함ftpUpdate
	jsonResult.monitorVOs = jsonMonitorVOs;
	
	//----------------------------------------------------------------------
	// 데이터처리 키값 상이 항목
	//----------------------------------------------------------------------
	// [진단형태] - 서버에서 설정된 config
	jsonResult.check_type = jsonResult.check_type;
	//jsonResult.check_type = null;

	// [요일별 진단 설정]
	jsonResult.monitor_flag = ('T' == jsonResult.monitor_flag) ? "Y" : "N";
	
	// [예약설정]
	jsonResult.re_check_type = ('P' == jsonResult.re_check_type) ? "Y" : "N";

	//진단 제외 파일 / 해당 진단 파일

	if('Y' == jsonResult.file_except_allow_flag) {
		jsonResult.file_except_allow_flag_nm = '해당 진단 파일';

	} else {
		jsonResult.file_except_allow_flag_nm = '진단 제외 파일';
	}

	// SFTP 서버 타입
	if("L" == jsonResult.ftp_type){
		jsonResult.local_chk = "Y";
	}else{
		jsonResult.local_chk = "N";
	}
		
	// 진단상테 동작중 : RUNNING, PAUSE인 경우는 '등록', '연결테스트' 버튼 숨김
	if("Y" == jsonResult.state){
		jsonResult.sync_chk = "Y";
	}else{
		jsonResult.sync_chk = "N";
	}
	
	// SFTP 접속 방식에 따른 압력란 활성/비활성
	if('P' != jsonResult.key_certification_type) {
		jsonResult.account_depth_chk = 'N';
	}
	setTimeout(function(){
		// 2단계 계정연결 사용 여부 off
		if('P' != jsonResult.key_certification_type) {
			$('input.btn_switch', ".div_AccountDepthChk").lcs_off();
			$('input.btn_switch', ".div_AccountDepthChk").lcs_disable();
			$('input.btn_switch', ".div_password_chk").lcs_off();
			$('input.btn_switch', ".div_password_chk").lcs_disable();

		} else {
			//$('input.btn_switch', ".div_AccountDepthChk").lcs_on();
			$('input.btn_switch', ".div_AccountDepthChk").lcs_enable();
			$('input.btn_switch', ".div_password_chk").lcs_enable();
		}
	}, 200);
	//----------------------------------------------------------------------		
		
	// 화면에 상세내역을 셋팅함
	//console.log(jsonResult);	
	cf_setContainerData("frmDtil", jsonResult);	
	cf_setContainerData("ftpHiddenDtil", jsonResult);	
	
	//---------------------------------------------
	// Angular를 이용하여 view변경
	//---------------------------------------------		
	var $scopeAgr = getAngularScope('mainCtrl');
	if($scopeAgr != null && $scopeAgr != undefined) {
		$scopeAgr.viewData = jsonResult;
		$scopeAgr.$apply();
	}
	//---------------------------------------------

	//---------------------------------------------
	// radio/checkbox 스타일 입히기
	//---------------------------------------------
	$('input.s_icheck').iCheck({
		checkboxClass: 'icheckbox_red_small',
		radioClass: 'iradio_red_small'
	});	
	$('input.l_icheck').iCheck({
		checkboxClass: 'icheckbox_red_large',
		radioClass: 'iradio_red_large'
	});


	
	// on/off 스위치 스타일 적용
	$('input.btn_switch').lc_switch();
	//---------------------------------------------

	
	//---------------------------------------------
	// multipleSelect : 요일별 진단 동작 시간 설정
	//---------------------------------------------
	$('.ftp_monitor_timeCheckBox').multiselect({		
		//enableHTML: true,
		//enableFiltering: true,
		includeSelectAllOption: true,
		countSelected : false,
		selectAllText : '모두선택',
		allSelectedText : '시간전체',
		nSelectedText : '개 선택됨',
		buttonContainer: '<div class="btn-group w-100" />'
    });
	//---------------------------------------------
	
	
	//---------------------------------------------
	// 날짜선택 컨트롤
	//---------------------------------------------
	$('#startDt').datetimepicker({
    	locale: 'ko',
    	format: 'YYYY-MM-DD'
    });	
	//---------------------------------------------

	// SFTP 접속 방식에 따른 압력란 활성/비활성
	$('#key_certification_type_P,#key_certification_type_K,#key_certification_type_L').on('ifChecked', function(event){
		$scopeAgr.viewData.key_certification_type = $("input[name=key_certification_type]:checked").val();
		if('P' != $scopeAgr.viewData.key_certification_type) {			
			$scopeAgr.viewData.account_depth_chk = 'N';
			$scopeAgr.viewData.password_chk = 'N';
			// 2단계 계정연결 사용 여부 off
			$('input.btn_switch', ".div_AccountDepthChk").lcs_off();
			$('input.btn_switch', ".div_AccountDepthChk").lcs_disable();
			$('input.btn_switch', ".div_password_chk").lcs_off();
			$('input.btn_switch', ".div_password_chk").lcs_disable();


		} else {
			$('input.btn_switch', ".div_AccountDepthChk").lcs_enable();
			$('input.btn_switch', ".div_password_chk").lcs_enable();
		}
		$scopeAgr.$apply();
	});

	// 2단계 계정연결 사용 클릭
	$(".lcs_switch", ".div_AccountDepthChk").click( function () {		
		setTimeout(function(){

			// 2단계 계정연결 사용 체크 상태 처리용 셋팅	
			var chk_value = $("#account_depth_chk").prop("checked") ? "Y" : "N";			
			$scopeAgr.viewData.account_depth_chk = chk_value;					
			if(fn_isNotEmptyVal($scopeAgr.viewData.account_depth_chk) != 'Y') {
				$("#sub_id").val('');
				$("#sub_password").val('');
			}
			$scopeAgr.$apply();
			
		}, 100);
	});

	// 패스워드 변경여부
	$(".lcs_switch", ".div_password_chk").click( function () {		
		setTimeout(function(){

			// 2단계 계정연결 사용 체크 상태 처리용 셋팅	
			var chk_value = $("#password_chk").prop("checked") ? "Y" : "N";			
			$scopeAgr.viewData.password_chk = chk_value;					
			if(fn_isNotEmptyVal($scopeAgr.viewData.password_chk) != 'Y') {				
				$("#password2").val('');
				$("#password3").val('');
			}
			$scopeAgr.$apply();
			
		}, 100);
	});
	
	// SFTP 연결 시간 제한  클릭
	$(".lcs_switch", ".div_SftpConnectionTimeFlag").click( function () {		
		setTimeout(function(){

			var chk_value = $("#sftp_connection_time_flag").prop("checked") ? "Y" : "N";			
			$scopeAgr.viewData.sftp_connection_time_flag = chk_value;

			// SFTP 연결 시간 제한 상태 처리용 셋팅				
			if(fn_isNotEmptyVal($scopeAgr.viewData.sftp_connection_time_flag) != 'Y') {
				$("#sftp_connection_timer").val('');
			}
			$scopeAgr.$apply();
			
		}, 100);
	});
	
	// 예약 설정 클릭
	$(".lcs_switch", ".div_re_check_type").click( function () {		
		setTimeout(function(){

			var chk_value = $("#re_check_type").prop("checked") ? "Y" : "N";			
			$scopeAgr.viewData.re_check_type = chk_value;

			// 예약설정 처리용 셋팅				
			if(fn_isNotEmptyVal($scopeAgr.viewData.re_check_type) == 'Y') {
				// 예약설정 기본유형 설정
				if(fn_isEmpty($("#re_dates").val())) {
					$scopeAgr.viewData.re_dates = "day";
				} else {
					$scopeAgr.viewData.re_dates = $("#re_dates").val();
				}
			}
			$scopeAgr.$apply();
			
		}, 100);
	});
		
	// 자동 삭제 설정
	$(".lcs_switch", ".div_del_flag").click( function () {		
		setTimeout(function(){
			$scopeAgr.viewData.del_flag = $("#del_flag").prop("checked") ? "Y" : "N";		
			$scopeAgr.$apply();
			
		}, 100);
	});
	
	// GDPR패턴설정
	$(".lcs_switch", ".div_gdpr_flag").click( function () {		
		setTimeout(function(){
			$scopeAgr.viewData.gdpr_flag = $("#gdpr_flag").prop("checked") ? "Y" : "N";		
			$scopeAgr.$apply();
		}, 100);
	});	
	
	// 요일별 진단설정 클릭
	$(".lcs_switch", ".div_monitor_flag").click( function () {		
		setTimeout(function(){
	
			$scopeAgr.viewData.monitor_flag = $("#monitor_flag").prop("checked") ? "Y" : "N";		
			$scopeAgr.$apply();
			
		}, 100);
	});

	// 진단 제외 파일 / 해당 파일
	$('input[name="file_except_allow_flag"]').on('ifChecked', function(event){
		setTimeout(function(){
			$scopeAgr.viewData.file_except_allow_flag = $("input[name=file_except_allow_flag]:checked").val();
			if('Y' == $scopeAgr.viewData.file_except_allow_flag) {
				$scopeAgr.viewData.file_except_allow_flag_nm = '해당 진단 파일';

			} else {
				$scopeAgr.viewData.file_except_allow_flag_nm = '진단 제외 파일';
			}
			$scopeAgr.$apply();
		}, 100);
	});
	
	// 요일별 진단 동작 시간 설정
	$(".lcs_switch", ".div_ftp_monitor_delay").click( function (evt) {		
		setTimeout(function(){
			var elemId = evt.currentTarget.parentElement.firstChild.id;
			var lstIdx = elemId.split("_")[3];
			var optVal = $("#" + elemId).prop("checked") ? "Y" : "N";
			//console.log(lstIdx, elemId, optVal);
			$scopeAgr.viewData.monitorVOs[lstIdx].ftp_monitor_delay = optVal;
			$scopeAgr.$apply();	
		}, 100);
	});
	
	// SFTP 서버 타입 설정 변경처리
	$("#ftp_type").change( function () {
		$scopeAgr.viewData.ftp_type = $(this).val();
		$scopeAgr.$apply();
	});
	
	// 예약 시작시간 설정 변경처리
	$("#re_dates").change( function () {
		// 예약설정 기본유형 설정
		if(fn_isEmpty($("#re_dates").val())) {
			$scopeAgr.viewData.re_dates = "day";
		} else {
			$scopeAgr.viewData.re_dates = $("#re_dates").val();
		}

		if($("#re_dates").val()=="month"){
			document.getElementById("re_month_span").style.display="block";
		}else{
			document.getElementById("re_month_span").style.display="none";
		}
		$scopeAgr.$apply();
	});
	
	// 그룹정책 사용 여부
	$('#sync_flag_Y,#sync_flag_N').on('ifClicked', function(event){
		if(event.currentTarget.value == $("input[name=sync_flag]:checked").val()) return;
		window.onload();
		$scopeAgr.viewData.sync_flag = $("input[name=sync_flag]:checked").val() != "N" ? 'N' : 'Y';
		if ( 'RUNNING' == $scopeAgr.viewData.job_state || 'RUNNING' == $scopeAgr.viewData.job_state_re ) {

			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '진단 중에는 개별설정 </br>여부를 변경할 수 없습니다.'
			});
			$scopeAgr.viewData.sync_flag != "N" ? $('#sync_flag_Y').iCheck('uncheck') : $('#sync_flag_N').iCheck('uncheck')

			// (JOB_STATE='RUNNING' OR JOB_STATE_RE ='RUNNING')
			setTimeout(function () {

				$scopeAgr.viewData.sync_flag != "N" ? $('#sync_flag_N').iCheck('check') : $('#sync_flag_Y').iCheck('check')
				$scopeAgr.viewData.sync_flag = $("input[name=sync_flag]:checked").val() == "N" ? 'N' : 'Y';
				$scopeAgr.$apply();
			}, 100);



		}else{
			$scopeAgr.$apply();
		}
	});
	
	// 진단 대상 확장자 여부
	$('#file_ext_type_Y,#file_ext_type_N').on('ifChecked', function(event){
		$scopeAgr.viewData.file_ext_type = $("input[name=file_ext_type]:checked").val();		
		$scopeAgr.$apply();
	});
	
	// 복합패턴 사용 클릭
	$(".lcs_switch", ".divComplexPattern").click( function () {	
		setTimeout(function(){
			var chk_value = $("#complex_pattern").prop("checked") ? "Y" : "N";			
			$scopeAgr.viewData.complex_pattern = chk_value;
			$scopeAgr.$apply();			
		}, 100);divComplexPattern
	});
	
	$("#btnCancel").click( function () {
		location.href="/filterftp.do?cmd=site_list&searchGroup=" + $('#group_id').val();
	});

	if('${command}' == 'UPDATE'){
		connectChk = true;		
	}else {
		connectChk = false;
	}
	
	// FTP연결 테스트 
	$("#btnConTest").click( function () {
		
		var formId = "addServerForm";

		if(!validateEmpty('site_name', formId, true)) {
			return false;
		}
		if(!validateEmpty('site_domain', formId, true)) {
			return false;
		}
		if(!validateEmpty('ip', formId, true)) {
			return false;
		}
		if(!validateEmpty('root_directory', formId, true)) {
			return false;
		}
		if(!validateEmpty('ftp_port', formId, true)) {
			return false;
		}
		
		$("#hidden_ip").val($("#ip").val());
		$("#hidden_port").val($("#ftp_port").val());
		var addServerFormData = $("#addServerForm").serializeFormJSON();
		$("#loadingImg").css("display","");
		$("#comment").html('');
		$("#connectModal").modal('show')
		// 모달이 열린 이후
		.on('shown.bs.modal', function (e) {
// 	    	$("#comment").hide();
			$("#btnModalClose").button("option", "disabled", true);		
		});
		//미권한자 수정 모드일경우에
		if('${authCheck}'=='N'){
			addServerFormData.id = document.getElementById("id").value;
			addServerFormData.ip = document.getElementById("ip").value;
			addServerFormData.ftp_port = document.getElementById("ftp_port").value;
			addServerFormData.ftp_type = document.getElementById("ftp_type").value;
		}
		wfds.ajax({
			url: "<c:url value='/filterftp/ftpConnectionCheck.do'/>",
			type: "post",
			dataType:"json",		
			data : {serverForm : JSON.stringify(addServerFormData)
			},				
			success: function (response){
				//console.log(response);
				
				$("#connectModal").modal('show');
// 				$("#loadingImg").hide();
				$("#comment").html(response.message);
				$("#comment").show();
				if(response.result == "SUCCESS"){
					$("#loadingImg").css("display","none");
					$("#comment").html("<img src='/admin_img/connect.png' style='max-width: 25px; height: auto;'/> "+response.message);
					$("#modalTitle").text("연결 상태 체크 [성공]");
					connectChk = true;
				}else{
					$("#loadingImg").css("display","none");
					$("#comment").html("<img src='/admin_img/unconnect.png' style='max-width: 25px; height: auto;'/> "+response.message);
					$("#modalTitle").text("연결 상태 체크 [실패]");
					connectChk = false;
				}
				$("#btnModalClose").button("option", "disabled", false);
				
			},
			error: function (XMLHttpRequest,status,error){
			}
		}); 
	});

	$("#btnModalClose").click( function () {
		$("#connectModal").modal('hide');
	});
	
	//진단설정 등록
	$("#btnAdd").click( function () {
		
 		// 공통 필수입력 유효성 확인
		if(!fn_validateForm('frmDtil')){
			return;
		}
		
		// 2차 로직 유효성 확인
		if(!validateInput('frmDtil')){
			return;
		}
		
		cfmsg.windows.confirm("저장 확인", "저장하시겠습니까?", function msgCallBack(msg){
			if('OK' === msg) {
				doSave('');
			}
		});
	});
	
	//저장 처리 수행
	function doSave(mode) {
		var addServerFormData = $("#addServerForm").serializeFormJSON();
		var addFilterFormmData = $("#addFilterForm").serializeFormJSON(); 
		
		//----------------------------------------------------------------------
		// 데이터처리 키값 상이 항목 -> 원복
		//----------------------------------------------------------------------						
		
		// 체크 데이터값 상이[예약설정]
		addServerFormData.re_check_type = $("#re_check_type").prop("checked") ? "P" : "N";	//('Y' == addServerFormData.re_check_type) ? "P" : "N";
		
		// 체크 데이터값 상이[요일별 진단 설정]
		addFilterFormmData.monitor_flag = $("#monitor_flag").prop("checked") ? "T" : "F";	//('Y' == addFilterFormmData.monitor_flag) ? "T" : "F";
		
		// [진단형태]
		var arr_check_type = [];
		if($('#check_type_p').prop("checked")) {
			arr_check_type.push('P');
		} else if($('#check_type_c').prop("checked")) {
			arr_check_type.push('C');
		} else if($('#check_type_w').prop("checked")) {
			arr_check_type.push('W');
		}
		if(arr_check_type.length ==0){
			arr_check_type.push('P');
		}
		//console.log('진단형태', arr_check_type);
		addFilterFormmData.check_type = arr_check_type.join(",");
		//----------------------------------------------------------------------
		
		
		//----------------------------------------------------------------------
		// 요일별 멀티 체크값 설정
		//----------------------------------------------------------------------
		//console.log(jsonMonitorVOs);
		var arrMonitorTime = [];
		for(var i = 0; i < 7; i++) {
			var arrValues = $('#ftp_monitor_time_'+i).val();
			var sMonitorTimeStr = "0";
			if(fn_isNotEmpty(arrValues)) {
				sMonitorTimeStr = arrValues.join(",");
			}
			
			arrMonitorTime.push(sMonitorTimeStr);
		}
		addFilterFormmData.ftp_monitor_time = arrMonitorTime;
		
		var weeks = "월,화,수,목,금,토,일";
		addFilterFormmData.weeks = weeks;
		
		addFilterFormmData.ftp_monitor_time = addFilterFormmData.ftp_monitor_time.join("|");
		addFilterFormmData.ftp_monitor_delay = addFilterFormmData.ftp_monitor_delay.join("|");
		//----------------------------------------------------------------------								
		
		// 예약설정 'off'인 경우는 연결 하위 값 클리어
		if(fn_isNotEmptyVal(addServerFormData.re_check_type) != 'P') {
			addServerFormData.re_dates = null;
			addServerFormData.re_week = null;
			addServerFormData.re_month = null;
			addServerFormData.re_dates = null;
			addServerFormData.re_time = null;
		}
		
		//console.log('addServerForm ===>>> ');
		//console.log(addServerFormData);
		
		//console.log('addFilterForm ===>>> ');
		//console.log(addFilterFormmData);
		
		// Gdpr설정
		var lst_asso_codes = [];
		$("input:checkbox[name=asso_codes]:checked").each(function() {
			//console.log('>>>>'+$(this).val());
			lst_asso_codes.push($(this).val());
		});
		//console.log('gdpr설정', lst_asso_codes);
		addFilterFormmData.asso_codes = lst_asso_codes.join(",");
		
		addFilterFormmData.undefined = null;
	    $.extend(true, addServerFormData, addFilterFormmData);		    
	    //submitData['_csrf'] = '${_csrf.token}';
	    
	    if('NEW' == ('${command}')){
	    	addServerFormData.command = 'INSERT';
	    }
	    //console.log(addServerFormData);
		
		wfds.ajax({
			url: "<c:url value='/filterftp/saveFtpServer.do'/>",
			type: "post",
			dataType:"json",
			data: {serverForm : JSON.stringify(addServerFormData)
			},					
			success: function (response){
				//console.log('저장응답', response);					
				var notiMsg = $.i18n.prop('common.message.add');
				if('NEW' != $('#command').val()) {
					notiMsg = $.i18n.prop('common.message.modify');
				}

				if(fn_isNotEmptyVal(response.result) == 0) {
					$.notify({
	   					icon: 'fa fa-check',
						message: notiMsg
		    		},{
						type:"success"
					});
					$("#btnCancel").click();
				} else {
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: $.i18n.prop('common.server.request.fail')
			    	});
				}
			},
			error: function (XMLHttpRequest,status,error){
				console.log('저장에러!', error);			
			}
		});
	}
	
	// 고유식별정보 클릭 처리
	$(".needablePrivacy").click( function () {
		//console.log('needablePrivacy', $(this).is('checked'))
		setChekStatus();
	});
	
	// 기타개인정보 클릭 처리
	$(".choicePrivacy").click( function () {
		//console.log('기타개인정보', $(this).is('checked'))
		setChekStatus();
	});

	//고유식별정보 전체클릭
	$("#checkFilterTy1").click(function(e){
		var elems = document.querySelectorAll(".needablePrivacy")
		for(var i=0;i<elems.length;i++){
			elems[i].checked = e.currentTarget.checked
		}
		setChekStatus();
	})


	//기타 개인정보 전체클릭
	$("#checkFilterTy2").click(function(e){
		var elems = document.querySelectorAll(".choicePrivacy")
		for(var i=0;i<elems.length;i++){
			elems[i].checked = e.currentTarget.checked
		}
		setChekStatus();
	})

});



//고유식별정보, 기타개인정보 체크상태 처리
function setChekStatus() {
	var needablePrivacy = 0;
	
	$('.needablePrivacy:checked').each(function(index) {
		//console.log(index, $(this).val());
		needablePrivacy++;
	});
	// 고유식별번호 체크 On
	if(needablePrivacy == 5) {
		$('#checkFilterTy1').prop('checked', true);
	} else {
		$('#checkFilterTy1').prop('checked', false);
	}
	
	var choicePrivacy = 0;
	$('.choicePrivacy:checked').each(function(index) {
		choicePrivacy++;
	});
	// 기타개인정보 체크 On
	if(choicePrivacy == 9) {
		$('#checkFilterTy2').prop('checked', true);
	} else {
		$('#checkFilterTy2').prop('checked', false);
	}
	// 전체선택
	if(needablePrivacy + choicePrivacy == 14) {
		$('#checkAll').prop('checked', true);
	} else {
		$('#checkAll').prop('checked', false);
	}		
}

//GDPR 패턴 체크상태 처리
function setChekGdprStatus() {
	var gdprPrivacy = 0;
	
	$('.asso_codes:checked').each(function(index) {
		gdprPrivacy++;
	});
	
	//console.log('gdprPrivacy', gdprPrivacy);
	if(gdprPrivacy == 8) {
		$('#checkAllGdpr').prop('checked', true);
	} else {
		$('#checkAllGdpr').prop('checked', false);
	}
}

//공통 validation 체크 이후 화면에 입력 유효성 체크
function validateInput(formId) {
	
	//console.log($("#ftp_type").val(), $("#ip").val());
	if("L" != $("#ftp_type").val() ){ // local_chk : "Y"
		if(!validateEmpty('ip', formId, true)) {
			return false;
		}
	
		var licenseOver = false;
		// LicenseControllAjaxAction.java
		wfds.ajaxSilent({
			url: "<c:url value='/json/settings/license-check-ajax.do'/>",
			method : "POST",
			cache : false,
			async : false,
			data : {ip : $('#ip', '#'+formId).val()},
			success : function(obj){
				//console.log(obj);
				//var obj = eval("("+result+")");
				if(obj.result == "block" && obj.ftpCheck != "T"){
					//alert("SERVERFILTER 등록 라이센스 수["+obj.licenseCount+"]를 초과하였습니다.\n새로운 진단 대상 서버를 추가하실 수 없습니다.");
					var tmpMsg = "SERVERFILTER 등록 라이센스 수["+obj.licenseCount+"]를 초과하였습니다.\n새로운 진단 대상 서버를 추가하실 수 없습니다.";
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: tmpMsg
			    	});
					licenseOver = true;
				}
			}
		});
		if(licenseOver) return;		
		
		if(!validateEmpty('id', formId, true)) {
			return false;
		}
		
		// SFTP 접속 방식[radio]
		if("P" == $("input[name=key_certification_type]:checked").val()){
			if(!validateEmpty('password', formId, true)) {
				return false;
			}
		}
		
		// 패스워드 변경여부
		if($("#password_chk").prop("checked") ){
			if(!validateEmpty('password2', formId, true)) { 
				return false;
			}
			if(!validateEmpty('password3', formId, true)) {
				return false;
			}
		}
		
		// 2단계 계정연결 사용
		if($("#account_depth_chk").prop("checked") ){
			if(!validateEmpty('sub_id', formId, true)) {
				return false;
			}
			if(!validateEmpty('sub_password', formId, true)) {
				return false;
			}
		}
		
		if($("#sftp_connection_time_flag").prop("checked") ){
			if(!validateEmptyNum('sftp_connection_timer', formId, true)) {
				return false;
			}
		}
	}
	
	// 예약설정[switch/checkbox]
	if($("#re_check_type").prop("checked") ){
		if(!fn_validateFormItm(formId, 're_dates')) {
			return false;
		}
		
		if('day' == $('#re_dates').val() && !fn_validateFormItmEx(formId, 're_time', '시간')) {
			return false;
		}
		else if('week' == $('#re_dates').val()) {
			if(!fn_validateFormItmEx(formId, 're_week', '요일')) {
				return false;
			}
			if(!fn_validateFormItmEx(formId, 're_time', '시간')) {
				return false;
			}
		}
		else if('month' == $('#re_dates').val()) {
			if(!fn_validateFormItmEx(formId, 're_month', '일자')) {
				return false;
			}
			if(!fn_validateFormItmEx(formId, 're_time', '시간')) {
				return false;
			}
		}
		else if('1day' == $('#re_dates').val()) {
			if(!fn_validateFormItmEx(formId, 're_date', '일자')) {
				return false;
			}
			if(!fn_validateFormItmEx(formId, 're_time', '시간')) {
				return false;
			}
		}
	}
	
	// 개별정책 사용 여부[radio]
	if("N" == $("input[name=sync_flag]:checked").val()){
		var check = 0;
		var privcode = "privRrno,privCar,privPass,privIf,privCard,privBank,privRrnoi,privHealth,privHand,privEmail,privCorp,privEnter,privArmy,privPhone";
		var asso_codes = privcode.split(",");
		for(var i=0;i<asso_codes.length;i++){
			
			if($("#"+asso_codes[i]).is(":checked")){
				check++;
			}
		}
		
		if(check==0){
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: "진단필터를 하나 이상 등록해주시기 바랍니다."
    		},{type:"warning"});
			return false;
		}

	}
	
	// 삭제 설정
	if($("#del_flag").prop("checked") ){
		if(!fn_validateFormItmEx(formId, 'del_day', '자동 삭제 기간')) {
			return false;
		}
	}
	
	// 복합패턴을 사용하기 위해서는 필수/선택 개인정보 항목을 하나이상 체크해야함 
	if($("#complex_pattern").prop("checked") ){
		var needablePrivacy = 0;
		var choicePrivacy = 0;
		$('.needablePrivacy:checked').each(function(index) {
			//console.log(index, $(this).val());
			needablePrivacy++;
		});
		$('.choicePrivacy:checked').each(function(index) {
			choicePrivacy++;
		});
		
		if(needablePrivacy == 0 || choicePrivacy == 0){
			$.notify({icon: 'fa fa-exclamation-triangle', message: '복합패턴을 사용하기 위해서는  [고유식별정보/기타개인정보] 항목을 하나이상씩 체크하세요.' },{type:"warning"});
			return false;
		}
	}
	
	// GDPR패턴 ON시 반드시 하나이상 선택 필요
	if($("#gdpr_flag").prop("checked") ){		
		if($('.asso_codes:checked').length == 0) {
			$.notify({icon: 'fa fa-exclamation-triangle', message: 'GDPR 패턴을 하나 이상 등록해주시기 바랍니다.' },{type:"warning"});
			return false;	
		}		
	}
	
	// 등록시 sftp연결 확인 필수
	if($("#hidden_ip").val() != $("#ip").val()){
		connectChk = false;
	}
	if($("#hidden_port").val() != $("#ftp_port").val()){
		connectChk = false;
	}
	
	//console.log('연결테스트 결과 : ', connectChk);
	if(!connectChk){			
		$.notify({
			icon: 'fa fa-exclamation-triangle',
			message: "연결테스트를 확인해주세요."
		},{type:"warning"});
		return false;
	}
	
	return true;
}

</script>

<c:set var="option" value="${sessionScope.filter_option}"></c:set>
<c:set var="optionFlag" value="${sessionScope.autoDeleteFlag}"></c:set>

<!-- Content Header (Page header) -->
<section class="content-header">
	<h1> <span></span><spring:message code="common.server.info" /> <spring:message code="common.register" /><small><spring:message code="common.message.info.register" /></small> </h1>
	<ol class="breadcrumb">
		<li><a href="./"><i class="fa fa-home"></i><spring:message code="common.home"/></a></li>
		<li><a href="./filterftp.do?cmd=site_list&searchGroup=all"><spring:message code="common.file.diag"/></a></li>
		<li class="active"><spring:message code="filterftp.total.west.title1" /></li>
	</ol>
</section>
<!-- //Content Header (Page header) -->

<!-- Main content -->
<section class="content">
   	<div class="row" ng-app="mainApp" ng-controller="mainCtrl" >
		<section class="col-xs-12 connectedSortable">
			<div class="box box-primary">
				<!-- box-header -->
				<div class="box-header">
					<h3 class="box-title"><spring:message code="filterftp.file.trg.server.register" /></h3>
				</div>
				<!-- /.box-header -->
				<!-- box-body -->
				<div class="box-body" id="frmDtil">
			   		<div class="form-group" style="margin:0px;" >
						<div class="col-xs-12" style="padding:5px;">
							<div class="inner_group" style="margin-bottom:0px;">
								<h4><i class="fa fa-home"> ${group_name}</i> - <span style="vertical-align:middle;"><spring:message code="common.server.info" /></span> </h4>
								<div class="inner_group_con clearfix">
									<form class="form-horizontal" id="addServerForm">										
										<input type="hidden" id="custom" value="${sessionScope.custom }">
										<input type="hidden" name="page" value="1">
										<input type="hidden" name="group" value="">
										<input type="hidden" name="command" value="${command}" />
										<input type="hidden" name="ftp_seq" value="" />
										<input type="hidden" name="server_id" value="" />											
										<input type="hidden" name="local_chk" value="" />
										<input type="hidden" name="authCheck" value="${authCheck}"/>
										<input type="hidden" id="group_id" name="group_id" value="" />
									
										<div class="form-group">
											<label class="col-xs-3" ><i aria-hidden="true" style=""></i><spring:message code="common.user_name" /></label>
											<div class="col-xs-5">
												<input class="form-control" id="user_name" name="user_name" type="text" maxlength="30" style="" readonly="readonly" />
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="statistics.server.name" /></label>
											<div class="col-xs-5">
												<input class="form-control" id="site_name" name="site_name" type="text" maxlength="30" style="" placeholder="<spring:message code="filterftp.reserv.trg" /> <spring:message code="statistics.server.name" />" required/>
												<br/>
												<span><spring:message code="common.comment.special.char" /></span>
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filter.log.report.domain.name" /></label>
											<div class="col-xs-5">
												<input class="form-control" id="site_domain" name="site_domain" maxlength="30" type="text" style="" placeholder="<spring:message code="filterftp.reserv.trg" /> <spring:message code="statistics.nomal.server" /> <spring:message code="filter.log.report.domain" />" required/>
												<br/>
												<span><spring:message code="common.comment.special.char" /></span>
											</div>
										</div>
									<c:if test="${'kbsec' eq sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="common.department" /></label>
											<div class="col-xs-5">
												<input class="form-control PLAINTEXT" id="department_name" name="department_name" type="text" maxlength="50" style="" />
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="statistics.nomal.server" /> <spring:message code="common.charge.mng" /></label>
											<div class="col-xs-5">
												<input class="form-control PLAINTEXT" id="staff_name" name="staff_name" type="text" maxlength="50" style="" />
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="dashboard.trg.server.type" /></label>
											<div class="col-xs-5">
												<input class="form-control PLAINTEXT" id="os_type" name="os_type" type="text" maxlength="50" style="" />
											</div>
										</div>
									</c:if>
									<c:if test="${'bnk' eq sessionScope.custom || 'kbsec' eq sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="dashboard.trg.os" /></label>
											<div class="col-xs-5">
												<input class="form-control PLAINTEXT" id="os_type" name="os_type" type="text" maxlength="50" style="" />
											</div>
										</div>
									</c:if>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>진단대상 운영체제</label>
											<div class="col-xs-5">
												<select class="form-control w250" id="os_type" name="os_type" required>
													<option value="L" selected="selected">Linuxs</option>
													<option value="U" >Unix</option>
													<option value="W" >Windows</option>
													<option value="E" >Etc</option>
												</select>
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="dashboard.trg.os" />(IP)</label>
											<div class="col-xs-5">
												<input class="form-control IPADDR" id="ip" name="ip" type="text" maxlength="15" style="" placeholder="<spring:message code="filterftp.trg.server" /> IP" />
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="settings.history.report.id" /></label>
											<div class="col-xs-5">
												<input class="form-control IDTEXT" id="id" name="id" type="text" maxlength="30" style="" placeholder="<spring:message code="filterftp.trg.server" /> <spring:message code="common.connect" /> <spring:message code="login.id" />" />
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="tools.password" /></label>
											<div class="col-xs-5">
												<input class="form-control" id="password" name="password" type="password" maxlength="30" style="" placeholder="<spring:message code="filterftp.trg.server1" />" ng-disabled="'P' != viewData.key_certification_type"/>
											</div>
										</div>
									<c:choose>									
									<c:when test="${'gs' ne sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="common.connect" /> <spring:message code="common.formula" /></label>
											<div class="col-xs-5">
												<input type="radio" class="l_icheck" name="key_certification_type" id="key_certification_type_P" value="P" checked="checked"/><label  class="cursor">&nbsp;<spring:message code="tools.password" /> <spring:message code="authentication.nomal.certificate" /></label>&nbsp;&nbsp;
												<input type="radio" class="l_icheck" name="key_certification_type" id="key_certification_type_K" value="K"/><label for="key_certification_type_K" class="cursor">&nbsp;<spring:message code="common.key" /> <spring:message code="authentication.nomal.certificate" /></label>
												<c:if test="${'TRUE' eq sessionScope.hunesionLinkFlag }">
												<input type="radio" class="l_icheck" name="key_certification_type" id="key_certification_type_L" value="L"/><label for="key_certification_type_K" class="cursor">&nbsp;<spring:message code="tools.password" /> <spring:message code="statistics.nomal.server" /> <spring:message code="statistics.nomal.peristalsis" /></label>
												</c:if>
											</div>
										</div>
										<div class="form-group" style="display:none">
											<label class="col-xs-3"><i class="fa" aria-hidden="true" style=""></i><b>SFTP <spring:message code="common.module" /> <spring:message code="common.install" /><br/><spring:message code="common.absolute.path.position" /></b>&nbsp;</label>
											<div class="col-xs-5">
												<input class="form-control PLAINTEXT" id="sftp_module_setup_path" name="sftp_module_setup_path" type="text" maxlength="250" style="" readonly="readonly" />
											</div>
										</div>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="key_certification_type" name="key_certification_type" value="P" />
									</c:otherwise>
									</c:choose>
									
									<c:choose>									
									<c:when test="${'gs' ne sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>2<spring:message code="common.step" /> <spring:message code="common.account" /><spring:message code="common.nomal.connect" /> <spring:message code="settings.use" /></label>
											<div class="col-xs-9 div_AccountDepthChk" >
												<input class="btn_switch pull-left" type="checkbox" id="account_depth_chk" name="account_depth_chk" />
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.account_depth_chk">
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>2<spring:message code="common.step" /> SFTP <spring:message code="settings.history.report.id" /></label>
													<div class="col-xs-5">
														<input class="form-control IDTEXT" id="sub_id" name="sub_id" type="text" maxlength="40" style="width:70%;" placeholder="<spring:message code="filterftp.trg.server" /> SFTP <spring:message code="common.connect" /> <spring:message code="settings.history.report.id" />" />
													</div>
												</div>
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.account_depth_chk">
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>2<spring:message code="common.step" /> SFTP <spring:message code="tools.password" /></label>
													<div class="col-xs-5">
														<input class="form-control" id="sub_password" name="sub_password" type="password" maxlength="40" style="width:70%;" placeholder="<spring:message code="filterftp.trg.server" /> SFTP <spring:message code="common.connect" /> <spring:message code="tools.password" />"/>
													</div>
												</div>
											</div>
										</div>	
									</c:when>
									<c:otherwise>
										<input type="hidden" id="account_depth_chk" name="account_depth_chk" value="N" />
									</c:otherwise>
									</c:choose>
										
									<c:choose>									
									<c:when test="${'Y' eq sessionScope.password_recycle }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="tools.password" /> <spring:message code="common.change" /><spring:message code="common.confirm" /></label>
											<div class="col-xs-9 div_password_chk" >
												<input class="btn_switch pull-left" type="checkbox" id="password_chk" name="password_chk" />
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.password_chk">
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="tools.password" />2</label>
													<div class="col-xs-5">
														<input class="form-control" id="password2" name="password2" type="password" maxlength="40" style="width:70%;" placeholder="SFTP <spring:message code="tools.password" />2" />
													</div>
												</div>
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.password_chk">
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="tools.password" />3</label>
													<div class="col-xs-5">
														<input class="form-control" id="password3" name="password3" type="password" maxlength="40" style="width:70%;" placeholder="SFTP <spring:message code="tools.password" />3"/>
													</div>
												</div>
											</div>
										</div>	
									</c:when>
									<c:otherwise>
										<input type="hidden" id="password_chk" name="password_chk" value="N" />
									</c:otherwise>
									</c:choose>
										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="common.nomal.diag" /> <spring:message code="common.directory" /></label>
											<div class="col-xs-9 ">
												<div class="divHoriz">
												<input class="form-control w250 PLAINTEXT" id="root_directory" name="root_directory" type="text" placeholder="<spring:message code="common.nomal.diag" /> <spring:message code="common.directory" /> <spring:message code="common.nomal.path" />" required/>
												<label style="padding-top: 0px!important;">[<input type="checkbox" id="choice_file_flag" name="choice_file_flag" value="Y" class="horiz-itm" /><spring:message code="common.nomal.certain" /> <spring:message code="common.nomal.file" /> <spring:message code="common.nomal.diag" />]</label>
												</div>
											
												<c:if test="${'gs' ne sessionScope.custom }">
													<span><label><spring:message code="common.select.fullpath" /></label></span><br/>
													 <span><spring:message code="filterftp.comment.sftp.directory" /></span><br/>
													 <span><spring:message code="filterftp.comment.linux.window" /></span><br/>
													<span><label><spring:message code="common.select.path" /></label></span><br/>
													 <span><spring:message code="filterftp.comment.first.word" /></span><br/>
													 <span><spring:message code="filterftp.comment.warning" /></span><br/>
												</c:if>
													<span><label><spring:message code="common.select.specific.file" /> </label></span><br/>
													 <span><spring:message code="filterftp.comment.example.specific.file" /></span><br/>
													 <span><spring:message code="filterftp.comment.warning.sftp.set" /></span>
											
											</div>
											
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i>SFTP <spring:message code="filter.settings.server.port" /> <spring:message code="common.pw_set" /></label>
											<div class="col-xs-5">
												<input class="form-control w250 NUMBER" id="ftp_port" name="ftp_port" type="text" maxlength="5" placeholder="SFTP <spring:message code="filter.settings.server.port1" />" required/>
												<br/>
												<span><spring:message code="filterftp.site.form.span1" /></span>
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label1" /></label>
											<div class="col-xs-5">
												<select class="form-control w250" id="ftp_type" name="ftp_type" required>
													<option value="S" selected="selected">SFTP(Secure File Transfer Protocol)</option>
												<c:if test="${'gs' ne sessionScope.custom }">
													<option value="W">SMB/CIFS(Server Message Block/Common Internet File System)</option>
													<option value="L">LocalDrive</option>
												</c:if>
												</select>
											</div>
										</div>
										
									<c:choose>									
									<c:when test="${'gs' ne sessionScope.custom }">
										<div class="form-group" ng-show="'S'==viewData.ftp_type">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label2" /></label>
											<div class="col-xs-9 div_SftpConnectionTimeFlag">
												<input class="btn_switch pull-left" type="checkbox" id="sftp_connection_time_flag" name="sftp_connection_time_flag" />
												<span><spring:message code="filterftp.site.form.span13"/></span>
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.sftp_connection_time_flag">
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label3" /></label>
													<div class="col-xs-4 divHoriz">
														<input class="form-control NUMBER" style="width:70px" id="sftp_connection_timer" name="sftp_connection_timer" type="text" maxlength="3" /><span><spring:message code="common.min" /></span>
													</div>
												</div>
											</div>
										</div>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="sftp_connection_time_flag" name="sftp_connection_time_flag" value="N" />
										<input type="hidden" id="sftp_connection_timer" name="sftp_connection_timer" value="120" />
									</c:otherwise>
									</c:choose>
												
									<c:choose>									
									<c:when test="${'0' eq option }">
										<div class="form-group">
											<label class="col-xs-3" for="check_type_p"><i class="fa fa-check" aria-hidden="true"></i><spring:message code="privacy.search.type1" /></label>
											<div class="col-xs-6">
												<input type="checkbox" id="check_type_p" name="check_type" value="P" disabled="disabled" ng-checked="'A'==viewData.check_type || 'B'==viewData.check_type || 'E'==viewData.check_type || 'F'==viewData.check_type" ng-click="viewData.check_type='P'"/><label for="check_type_p">&nbsp;<spring:message code="filterftp.site.form.label4" />&nbsp;&nbsp;</label>
												<c:choose>									
												<c:when test="${'1' eq option || '3' eq option }">
												<input type="checkbox" id="check_type_c" name="check_type" value="C" ng-checked="'A'==viewData.check_type || 'C'==viewData.check_type || 'E'==viewData.check_type || 'G'==viewData.check_type" ng-click="viewData.check_type='C'"/><label for="check_type_c">&nbsp;<spring:message code="filterftp.site.form.label5" />&nbsp;&nbsp;</label>
												</c:when>
												<c:when test="${'2' eq option || '3' eq option }">
												<input type="checkbox" id="check_type_w" name="check_type" value="W" ng-checked="'A'==viewData.check_type || 'D'==viewData.check_type || 'E'==viewData.check_type || 'G'==viewData.check_type" ng-click="viewData.check_type='W'"/><label for="check_type_w">&nbsp;<spring:message code="filterftp.site.form.label6" />&nbsp;&nbsp;</label>
												</c:when>
												</c:choose>
											</div>
										</div>									
									</c:when>
									<c:otherwise>
										<input type="hidden" name="check_type" id="check_type_p" value="P" />
									</c:otherwise>
									</c:choose>
									
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label7" /></label>
											<div class="col-xs-5">
												<select class="form-control w250" id="ftp_search_type" name="ftp_search_type" required>
													<option value="F" selected="selected"><spring:message code="filterftp.site.form.option1" /></option>
													<option value="S"><spring:message code="filterftp.site.form.option2" /></option>
													<c:if test="${'gs' ne sessionScope.custom }">
													<option value="E"><spring:message code="filterftp.site.form.option3" /></option>
													</c:if>
												</select>
												<br/>
												<span><spring:message code="filterftp.site.form.span2" /></span><br/>
											</div>
										</div>
									
									<c:choose>									
									<c:when test="${'gs' ne sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label8" /></label>
											<div class="col-xs-5">
												<div class="col-xs-5">
													<input type="radio" class="l_icheck" name="ftp_encoding" id="ftp_encoding_E" value="E"/><label for="ftp_encoding_E" class="cursor">&nbsp;EUC-KR</label>&nbsp;&nbsp;
													<input type="radio" class="l_icheck" name="ftp_encoding" id="ftp_encoding_U" value="U" checked="checked"/><label for="ftp_encoding_U" class="cursor">&nbsp;UTF-8</label>													
												</div>
												<br/>
												<span><spring:message code="filterftp.site.form.span3" /></span><br/>
											</div>
										</div>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="ftp_encoding_U" name="ftp_encoding" value="U">
									</c:otherwise>
									</c:choose>
									
									<c:if test="${'skps' eq sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label9" /></label>
											<div class="col-xs-5">
												<div class="col-xs-5">
													<input type="radio" class="l_icheck" name="archive_check" id="archive_check_Y" value="Y"/><label for="ftp_encoding_E" class="cursor">&nbsp;<spring:message code="statistics.nomal.notperistalsis" /></label>&nbsp;&nbsp;
													<input type="radio" class="l_icheck" name="archive_check" id="archive_check_N" value="N"/><label for="ftp_encoding_U" class="cursor">&nbsp;<spring:message code="statistics.nomal.peristalsis" /></label>													
												</div>
											</div>
										</div>
									</c:if>
																		
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="common.reservation.set" /></label>
											<div class="col-xs-8 div_re_check_type">
												<input class="btn_switch pull-left" type="checkbox" id="re_check_type" name="re_check_type" />
												<div class="form-group" style="margin-left:100px" ng-show="'Y'==viewData.re_check_type" >
													<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="common.diag.restart.set" /></label>
													<div class="col-xs-8 divHoriz" >
														<select class="form-control" style="width:90px" id="re_dates" name="re_dates">
															<option value="day"><spring:message code="resources.everyday" /></option>
															<option value="week" ><spring:message code="resources.weekly" /></option>
															<option value="month" ><spring:message code="resources.monthly" /></option>
															<option value="1day" ><spring:message code="resources.onlyone" /></option>
														</select>
														<select class="form-control" style="width:90px" id="re_week" name="re_week" ng-show="'week' == viewData.re_dates">
															<option value="월" selected="selected"><spring:message code="common.monday" /></option>
															<option value="화" ><spring:message code="common.tuesday" /></option>
															<option value="수" ><spring:message code="common.wedsday" /></option>
															<option value="목" ><spring:message code="common.thursday" /></option>
															<option value="금" ><spring:message code="common.friday" /></option>
															<option value="토" ><spring:message code="common.saturday" /></option>
															<option value="일" ><spring:message code="common.sunday" /></option>
														</select>
														<select class="form-control" style="width:70px" id="re_month" name="re_month" ng-show="'month' == viewData.re_dates">
															<option value="01" selected="selected" >1</option>
															<option value="02" >2</option>
															<option value="03" >3</option>
															<option value="04" >4</option>
															<option value="05" >5</option>
															<option value="06" >6</option>
															<option value="07" >7</option>
															<option value="08" >8</option>
															<option value="09" >9</option>
															<option value="10" >10</option>
															<option value="11" >11</option>
															<option value="12" >12</option>
															<option value="13" >13</option>
															<option value="14" >14</option>
															<option value="15" >15</option>
															<option value="16" >16</option>
															<option value="17" >17</option>
															<option value="18" >18</option>
															<option value="19" >19</option>
															<option value="20" >20</option>
															<option value="21" >21</option>
															<option value="22" >22</option>
															<option value="23" >23</option>
															<option value="24" >24</option>
															<option value="25" >25</option>
															<option value="26" >26</option>
															<option value="27" >27</option>
															<option value="28" >28</option>
															<option value="29" >29</option>
															<option value="30" >30</option>
															<option value="31" >31</option>
														</select><span id="re_month_span"><spring:message code="dashboard.day" /></span>
														<div class='input-group date' id='startDt' style="width:140px; display: inline-block;top:-3px" ng-show="'1day' == viewData.re_dates" >
													        <input type='text' class="form-control" id='re_date' name="re_date" style="width:100px;" maxlength="10"/>
													        <span class="input-group-addon common_gray" style="width:34px;height: 34px" >
													             <i class="fa fa-calendar" aria-hidden="true"  ></i>
													        </span>
													    </div>
														<select class="form-control" style="width:70px" id="re_time" name="re_time">
															
															<option value="01" selected="selected">01</option>
															<option value="02" >02</option>
															<option value="03" >03</option>
															<option value="04" >04</option>
															<option value="05" >05</option>
															<option value="06" >06</option>
															<option value="07" >07</option>
															<option value="08" >08</option>
															<option value="09" >09</option>
															<option value="10" >10</option>
															<option value="11" >11</option>
															<option value="12" >12</option>
															<option value="13" >13</option>
															<option value="14" >14</option>
															<option value="15" >15</option>
															<option value="16" >16</option>
															<option value="17" >17</option>
															<option value="18" >18</option>
															<option value="19" >19</option>
															<option value="20" >20</option>
															<option value="21" >21</option>
															<option value="22" >22</option>
															<option value="23" >23</option>
															<option value="24" >24</option>
														</select><span>시</span>
													</div>
												</div>
												
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterdb.siteformt.label6" /></label>
											<div class="col-xs-6">
												<input type="radio" class="l_icheck sync_flag" name="sync_flag" id="sync_flag_Y" value="Y" checked="checked"/><label for="sync_flag_Y" class="cursor">&nbsp;<spring:message code="filterdb.siteformt.label8" /></label>&nbsp;&nbsp;
												<input type="radio" class="l_icheck sync_flag" name="sync_flag" id="sync_flag_N" value="N" /><label for="sync_flag_N" class="cursor">&nbsp;<spring:message code="filterdb.siteformt.label7" /></label>
											</div>
										</div>
										
										
									</form>
								</div>
							</div>
						</div>
					</div>
					
					<div class="form-group" style="margin:0px;" ng-show="'N'==viewData.sync_flag">
						<div class="col-xs-12" style="padding:5px;">
							<div class="inner_group" style="margin-bottom:0px;">
								<h4><span style="vertical-align:middle;"><spring:message code="filterdb.siteformt.label9" /></span></h4>
								<div class="inner_group_con clearfix">
									<form class="form-horizontal" id="addFilterForm">
									
										<script>
											console.log('${sessionScope.eachSetting}');
										</script>
									<!-- 추가환경설정 -->
									<c:choose>
									<c:when test="${'TRUE' eq sessionScope.eachSetting }">
										<div class="form-group ">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.result.form.th1" /></label>
											<div class="col-xs-9 divHoriz">
												<input class="form-control w80 NUMBER" id="file_size_min" name="file_size_min" maxlength="5" type="text"/><span>MB ~ </span><input class="form-control w80 NUMBER" id="file_size" name="file_size" maxlength="5" type="text"/><span>MB</span>
												<span><spring:message code="filterftp.site.form.span4" /></span>
											</div>
										</div>
										<div class="form-group ">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.result.form.th2" /></label>
											<div class="col-xs-9 ">
												<div class="form-group " >
												<input type="radio" class="l_icheck" name="file_ext_type" id="file_ext_type_N" value="N" ng-selected="'N'==viewData.file_ext_type" /><label for="file_ext_type_N" class="cursor">&nbsp;<spring:message code="filterftp.site.form.label10" /></label>&nbsp;&nbsp;
												<input type="radio" class="l_icheck" name="file_ext_type" id="file_ext_type_Y" value="Y" ng-selected="'Y'==viewData.file_ext_type" /><label for="file_ext_type_Y" class="cursor">&nbsp;<spring:message code="filterftp.site.form.label11" /></label><span><spring:message code="filterftp.site.form.label12" /></span>
												</div>

												<div class="form-group "  ng-show="'Y'==viewData.file_ext_type">
													<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i><spring:message code="filterftp.site.form.label13" /></label>
													<div class="col-xs-8 " >
														<input class="form-control NAMETEXT w250" id="target_file_ext" name="target_file_ext" type="text" maxlength="250" /><span><spring:message code="filterftp.site.form.span5" /></span>
													</div>
												</div>
												
												<div class="form-group"  ng-show="'N'==viewData.file_ext_type" >
													<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i><spring:message code="filterftp.site.form.label14" /></label>
													<div class="col-xs-8 divHoriz" >
														<input class="form-control NAMETEXT w250" id="file_ext" name="file_ext" type="text" maxlength="250" /><span><spring:message code="filterftp.site.form.span5" /></span>
													</div>
												</div>
												<div class="form-group"  >
													<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i><spring:message code="filterftp.site.form.label15" /></label>
													<div class="col-xs-8 " >
														<input class="form-control NUMBER w250" id="bandwidth" name="bandwidth" type="text" maxlength="3" /><span><spring:message code="filterftp.site.form.span6" /></span>

													</div>
												</div>
												<div class="form-group"  >
													<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i><spring:message code="filterftp.site.form.label16" /></label>
													<div class="col-xs-8 " >
														<input class="form-control PATHTEXT w250" id="system_directory" name="system_directory" type="text" maxlength="50" /><span><spring:message code="filterftp.site.form.span7" /></span>
													</div>
												</div>
											</div>
										</div>
											
									</c:when>
									<c:otherwise>
										<input type="hidden" name="eachSet" id="eachSet" value="N" /> 
									</c:otherwise>
									</c:choose>
									<!-- // 추가환경설정 -->
									
									<c:choose>									
									<c:when test="${'gs' eq sessionScope.custom }">
										<input type="hidden" id="pass_directory" name="pass_directory" value="" />	
									</c:when>
									<c:otherwise>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label17" /></label>
											<div class="col-xs-5">
												<input class="form-control PATHTEXT" id="pass_directory" name="pass_directory" type="text" style="" maxlength="250" placeholder="<spring:message code="filterftp.site.form.input1" />" />
												 <span><spring:message code="filterftp.site.form.span8" /></span>
											</div>
										</div>
									</c:otherwise>
									</c:choose>
										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i>{{viewData.file_except_allow_flag_nm}}</label>
											<div class="col-xs-9">
												<input type="radio" class="l_icheck" name="file_except_allow_flag" id="file_except_allow_flag_N" value="N"/><label for="file_except_allow_flag_N" class="cursor">&nbsp;진단 제외(Default)</label>&nbsp;&nbsp;
												<input type="radio" class="l_icheck" name="file_except_allow_flag" id="file_except_allow_flag_Y" value="Y"/><label for="file_except_allow_flag_Y" class="cursor">&nbsp;해당 파일 진단</label>
												<br/>
												<div class="divHoriz" style="padding-top: 10px">
													<input class="form-control w250" id="pass_file" name="pass_file" type="text" maxlength="255"/>
													<span><spring:message code='setting.ftp.span12'/> logo.jpg, index.jsp</span>
												</div>										
											</div>
										</div>
										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label18" /></label>
											<div class="col-xs-5">
												<input class="form-control NAMETEXT" id="detect_keyword" name="detect_keyword" type="text" style="" maxlength="255" placeholder="<spring:message code="filterftp.site.form.input2" />"/>
												<br/>
												 <span><spring:message code="filterftp.site.form.span9" /></span>
											</div>
										</div>
										
									<c:if test="${'0' ne option }">
										<div class="form-group" ng-show="'A'==viewData.check_type || 'C'==viewData.check_type || 'E'==viewData.check_type || 'G'==viewData.check_type || 'D'==viewData.check_type || 'F'==viewData.check_type">
											<label class="col-xs-3" ><i class="fa " aria-hidden="true" style=""></i><spring:message code="filterftp.site.form.label19" /></label>
											<div class="col-xs-5">
												<input class="form-control PATHTEXT" id="zip_file_directory" name="zip_file_directory" maxlength="250" type="text" style="" />
												<br/>
												 <span><spring:message code="filterftp.site.form.span10" /></span>
											</div>
										</div>
									</c:if>
										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label20" /></label>
											<div class="col-xs-9 div_monitor_flag">
												<input class="btn_switch pull-left" type="checkbox" id="monitor_flag" name="monitor_flag" />
											</div>
										</div>
										<div class="form-group " ng-show="'Y'==viewData.monitor_flag">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label21" /></label>
											<div class="col-xs-5">
												
												<table width="100%" cellpadding="0" cellspacing="0" border="1" style="min-width: 480px">
													<tr valign="middle" style="height: 35px"> 
														<td align="center" width="60%">
															<span><spring:message code="filterftp.site.form.label22" /></span>
														</td>
														<td align="center" width="40%">
															<span><spring:message code="filterftp.site.form.label23" /></span>
														</td>															
													</tr>

													<tr valign="middle" ng-repeat="moniterItm in viewData.monitorVOs" style="height: 35px"> 
														<td align="left" width="50%" style="padding-left: 20px">
															{{moniterItm.monitor_week}}<spring:message code="filterftp.site.form.td1" />
															<select id="ftp_monitor_time_{{$index}}" class="ftp_monitor_timeCheckBox" name="ftp_monitor_time" multiple="multiple"> 
																<!-- <option value=""><spring:message code="filterftp.site.form.option4" /></option> -->
																<option value="24" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '24')">0<spring:message code="common.time" /></option>
																<option value="01" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '01')">01<spring:message code="common.time" /></option>
																<option value="02" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '02')">02<spring:message code="common.time" /></option>
																<option value="03" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '03')">03<spring:message code="common.time" /></option>
																<option value="04" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '04')">04<spring:message code="common.time" /></option>
																<option value="05" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '05')">05<spring:message code="common.time" /></option>
																<option value="06" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '06')">06<spring:message code="common.time" /></option>
																<option value="07" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '07')">07<spring:message code="common.time" /></option>
																<option value="08" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '08')">08<spring:message code="common.time" /></option>
																<option value="09" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '09')">09<spring:message code="common.time" /></option>
																<option value="10" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '10')">10<spring:message code="common.time" /></option>
																<option value="11" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '11')">11<spring:message code="common.time" /></option>
																<option value="12" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '12')">12<spring:message code="common.time" /></option>
																<option value="13" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '13')">13<spring:message code="common.time" /></option>
																<option value="14" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '14')">14<spring:message code="common.time" /></option>
																<option value="15" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '15')">15<spring:message code="common.time" /></option>
																<option value="16" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '16')">16<spring:message code="common.time" /></option>
																<option value="17" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '17')">17<spring:message code="common.time" /></option>
																<option value="18" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '18')">18<spring:message code="common.time" /></option>
																<option value="19" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '19')">19<spring:message code="common.time" /></option>
																<option value="20" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '20')">20<spring:message code="common.time" /></option>
																<option value="21" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '21')">21<spring:message code="common.time" /></option>
																<option value="22" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '22')">22<spring:message code="common.time" /></option>
																<option value="23" ng-selected="setMultiChkOpt(moniterItm.ftp_monitor_time, '23')">23<spring:message code="common.time" /></option>
																
															</select>시
														</td>
														<td align="center" width="50%" class="div_ftp_monitor_delay">
															<input id="ftp_monitor_stat_{{$index}}" class="btn_switch pull-left" type="checkbox" name="ftp_monitor_delay" ng-value="moniterItm.ftp_monitor_delay" ng-checked="moniterItm.ftp_monitor_delay == 'Y'"/>
															<span id="ftp_monitor_stat_on_{{$index}}" ng-show="moniterItm.ftp_monitor_delay != 'Y'" >[미 설정시간 운용]</span>
															<span id="ftp_monitor_stat_off_{{$index}}" ng-show="moniterItm.ftp_monitor_delay == 'Y'">[미 설정시간 대기]</span>
														</td>																
													</tr>

												</table>
												
													
											</div>
										</div>
										
									<!-- 자동삭제 옵션[auto.delete.flag]이 설정된 경우 -->
									<c:if test="${'TRUE' eq optionFlag }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><c:if test="${'samoo' eq sessionScope.custom }"><spring:message code="filterftp.site.form.label24" /></br><spring:message code="filterftp.site.form.label25" /></c:if><c:if test="${'samoo' ne sessionScope.custom }"><spring:message code="filterftp.site.form.label26" /></c:if></label>
											<div class="col-xs-8 div_del_flag">
												<input class="btn_switch pull-left" type="checkbox" id="del_flag" name="del_flag" />
												<div class="form-group divHoriz" style="margin-top: 8px;" ng-show="'Y'==viewData.del_flag" >
													<c:if test="${'samoo' eq sessionScope.custom }">
														<span><font color="red"><spring:message code="filterftp.site.form.span11" /></font></span>
														<input type="hidden" name="del_day" id="del_day" value="0" />
													</c:if>
													<c:if test="${'samoo' ne sessionScope.custom }">
														<input class="form-control NUMBER w80" id="del_day" name="del_day" type="text" maxlength="3" /> <span><spring:message code="common.day" /></sapn>
														<span><font color="red"><spring:message code="filterftp.site.form.span12" /></font></span>
													</c:if>
												</div>
											</div>
										</div>
									</c:if>
										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterdb.siteformt.label15" /></label>
											<div class="col-xs-3">
												<label >&nbsp;<spring:message code="privacy.all_select" /></label>
												<input type="checkbox" id="checkAll" class="checkAll" ng-click="checkAll()"/>												
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterftp.site.form.label27" />
												<input type="checkbox" id="checkFilterTy1" class="checkFilterTy1" ng-click="" />
											</label>
											
											<div class="col-xs-8">
												<table width="100%" cellpadding="0" cellspacing="0" border="0">
													<tr valign="top"> 
														<td align="left" width="20%" >
															<input type="checkbox" id="privRrno" name="privrrno" class="needablePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privRrno" /><label for="privRrno"><spring:message code="common.old.resident.num" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox" id="privRrnoi" name="privrrnoi" class="needablePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privRrnoi" /><label for="privRrnoi"><spring:message code="common.new.resident.num" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox" id="privIf" name="privif" class="needablePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privIf" /><label for="privIf"><spring:message code="common.foreign_number" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox" id="privPass" name="privpass" class="needablePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privPass" /><label for="privPass"><spring:message code="common.passport_number" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox" id="privCar" name="privcar" class="needablePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privCar" /><label for="privCar"><spring:message code="common.drive_number" /></label>
														</td>																
													</tr>
												</table>
												
											</div>
										</div>
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filter.pattern.other" />
												<input type="checkbox" id="checkFilterTy2" class="checkFilterTy2" ng-click="" />
											</label>
											<div class="col-xs-8">
												<table width="100%" cellpadding="0" cellspacing="0" border="0">
													<tr valign="top">
														<td align="left" width="20%">
															<input type="checkbox"  id="privCard" name="privcard" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privCard" /><label for="privCard"><spring:message code="common.nomal.card_number" /></label>	
														</td><td align="left" width="20%">                                                                                                  
															<input type="checkbox"  id="privBank" name="privbank" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privBank" /><label for="privBank"><spring:message code="common.account_number" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox"  id="privHealth" name="privhealth" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privHealth" /><label for="privHealth"><spring:message code="common.insurance_number" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox"  id="privHand" name="privhand" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privHand" /><label for="privHand"><spring:message code="common.phone" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox"  id="privPhone" name="privphone" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privPhone" /><label for="privPhone"><spring:message code="common.tele" /></label>
														</td>
													</tr>
													<tr valign="top">
														<td align="left" width="20%">
															<input type="checkbox"  id="privEmail" name="privemail" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privEmail" /><label for="privEmail"><spring:message code="common.email" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox"  id="privCorp" name="privcorp" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privCorp" /><label for="privCorp"><spring:message code="common.corporate_number" /></label>
														</td><td align="left" width="20%">
															<input type="checkbox"  id="privEnter" name="priventer" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privEnter" /><label for="privEnter"><spring:message code="common.permit_number" /></label>
														</td><td align="left" width="40%" colspan="2">																		
															<input type="checkbox"  id="privArmy" name="privarmy" class="choicePrivacy privSetting" value="Y" ng-checked="'Y'==viewData.privArmy" /><label for="privArmy"><spring:message code="common.army_number" /></label>				
														</td>
													</tr>
												</table>												
											</div>
										</div>
										
									<c:choose>									
									<c:when test="${'gs' ne sessionScope.custom }">
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa fa-check" aria-hidden="true"></i><spring:message code="filterdb.siteformt.label16" /></label>
											<div class="col-xs-8 divComplexPattern" >
												<input class="btn_switch pull-left" type="checkbox" id="complex_pattern" name="complex_pattern" />
												<label  ng-show="viewData.complex_pattern == 'Y'" >&nbsp;<spring:message code="filterdb.siteformt.label17" /></label>

											</div>
										</div>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="complex_pattern" name="complex_pattern" value="N" />
									</c:otherwise>
									</c:choose>
									
									<c:if test="${'TRUE' eq sessionScope.gdpr_disabled }">										
										<div class="form-group">
											<label class="col-xs-3" ><i class="fa" aria-hidden="true" style=""></i><spring:message code="filterdb.siteformt.label20" /></label>
											<div class="col-xs-8 div_gdpr_flag">
												<input class="btn_switch pull-left" type="checkbox" id="gdpr_flag" name="gdpr_flag" />
												
												<div class="form-group" style="margin-top: 15px;">
													<div class="col-xs-3" ng-show="'Y'==viewData.gdpr_flag">
														<label >&nbsp;<spring:message code="privacy.all_select" /></label>
														<input type="checkbox" id="checkAllGdpr" class="checkAllGdpr" ng-click="checkAllGdpr()"/>												
													</div>
												</div>
												<div class="form-group divHoriz" ng-show="'Y'==viewData.gdpr_flag" >
													<label ng-repeat="gdprItm in viewData.privCodeVOs" >
														<input type="checkbox" name="asso_codes" class="asso_codes" onclick="javascript:setChekGdprStatus();" id="asso_codes_{{$index}}" value="{{gdprItm.priv_code}}" ng-checked="'Y'==gdprItm.asso_status_tc" > </input>
														{{gdprItm.priv_code_name}}&nbsp;
													</label>
												</div>
											</div>
										</div>
									</c:if>
										
									<script>					
										//고유식별정보, 기타개인정보 체크상태 처리
										setTimeout(function(){
											setChekStatus();
											setChekGdprStatus();
										}, 200);
									</script>
										
									</form>
								</div>
							</div>
						</div>
					</div>
					
					<!-- //box-body -->
					<div class="col-xs-12" style="padding:5px;">
						<div style="width:100%; border-top:1px solid #f4f4f4;">
							<div style="margin:10px 0px 10px; float:left;" ng-show="'N'==viewData.sync_chk">
								<button type="button" class="btn btn-primary" id="btnConTest"><i class="fa " aria-hidden="true"></i> <spring:message code="common.connect.test" /></button>
							</div>	
							<div style="margin:10px 0px 10px; float:right;">
								<button type="button" class="btn btn-primary" id="btnAdd" ng-show="'N'==viewData.sync_chk"><i class="fa " aria-hidden="true"></i> <c:if test="${'UPDATE' eq command }"> <spring:message code="common.modify" /> </c:if> <c:if test="${'UPDATE' ne command }"> <spring:message code="common.register" /> </c:if> </button>
								<button type="button" class="btn btn-warning" id="btnCancel"><i class="fa " aria-hidden="true"></i> <spring:message code="common.cancel" /></button>
							</div>	
						</div>
					</div>		
				</div>
			</div>	
		</section>
	</div>
</section>
<!-- /.content -->

<!-- 연결 테스트  팝업 -->
<div class="modal fade" id="connectModal" data-backdrop="static" tabindex="-1" role="dialog" aria-hidden="true" >
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" ><span aria-hidden="true">×</span><span class="sr-only">Close</span></button>
		<h4 class="modal-title" id="modalTitle"></h4>
	      </div>
	      <div class="modal-body" style="text-align:center; padding:15px;" >
	      	<span id="loadingImg" style="width:100%;height:100%;resize: none;"><img src='/resources/img/common/ajax-loader.gif'> <spring:message code="common.connect.test" /></span><br>
   			<div id="comment" style="width:100%;height:85px;resize: none;word-break:break-all;display: none;overflow-x:hidden;overflow-y:auto;"></div>
	      </div>
	      <div class="modal-footer">
	      	<button type="button" class="btn btn-primary" id="btnModalClose" ><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.ok"/></span></button>
          	<button type="button" class="btn btn-warning" data-dismiss="modal"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.cancel"/></span></button>
     	 </div>
    </div>
  </div>
</div>

<div id="ftpHiddenDtil">
<input type="hidden" id="hidden_ip" name="ip" value="" />
<input type="hidden" id="hidden_port" name="ftp_port" value="" />
</div>

<script>
	if('${authCheck}'=='N'){
		$(".form-control").attr("readonly",true);

		$(".l_icheck").attr("disabled",true);
		$(".lcs_wrap").attr("disabled",true);
		$(".btn_switch").attr("disabled",true);
		$(".lcs_switch").addClass("lcs_disabled");
		$("#account_depth_chk").attr("disabled",true);
		$("input[type='checkbox']").attr("disabled",true);
		$("#password").attr("disabled",false);
		$("#password").attr("readonly",false);

	}

</script>