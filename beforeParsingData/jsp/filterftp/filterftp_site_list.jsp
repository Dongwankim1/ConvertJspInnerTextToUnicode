<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/cmmn/frd_libs.jsp" %>

<%-- <script src="<c:url value="/resources/js/filterftp/filter_site_list.js"/>?r=<%=rNumber %>"></script>  --%>

<script type="text/javaScript" language="javascript" defer="defer">

//트리노드 선택정보
var selectText = "모든서버";
var selectNode = '${searchGroup}';
// 그리드  객체
var table;

//progress bar 객체
var progressBarArr = [];
var pBa = new ProgressBarAdmin();
/**************************************************
 *  document ready function 
 **************************************************/
$(document).ready(function(){		

	// 상세 정보 조회
	function loadDetailInfo(searchGroup) {
		location.href="./filterftp.do?cmd=site_list&searchGroup="+searchGroup;
	}

	//------------------------------------------------------------------
	// 진단 대상 그룹 트리 구성
	//------------------------------------------------------------------
	// 트리바인딩 json데이터
	var jsonTreeData;	
	
	// 트리목록 조회
	refreshTree();
		
	// 진단 대상 그룹 트리로딩
	$("#layerTree").jstree({
		core:{
			data : jsonTreeData,
			multiple: false,
			themes:{responsive:!1}
	    },
	    plugins:["types","search"],
	    types:{"default":{icon:"fa fa-folder icon_state-warning icon_lg"}},
		search:{
			"case_sensitive":false,
			"show_only_matches":true
		}
	}); 			
	
	// 전체 그룹 선택시 등록 버튼 비활성화
	if("all" == selectNode) {		
		$('#btnServerAdd').attr('disabled', true);
		//$('#btnServerAddBulk').attr('disabled', true);
	}
	
	// tree 선택
	$("#layerTree").bind("select_node.jstree", function(evt, data){
		//console.log(evt, data);
		selectText=data.node.original.value;
		//selectValue=parseInt(data.node.original.order);
		selectNode=$("#layerTree").jstree().get_selected(true)[0].id;		
		//console.log('화면 갱신하기', '선택그룹 -', selectText + " : " + selectNode);
				
		// 화면 갱신하기
		loadDetailInfo(selectNode);	
    });
	
	//tree 새로고침
	function refreshTree(){
		//console.log('refreshTree');		
		 wfds.ajax({
			type : "POST",
			async : false,
			url : "<c:url value='/settings/getGroupTreeList.do'/>",
			dataType : "json",
			data: {searchGroup : selectNode
			},
			timeout : 30000,
			cache : false,
			error : function(request, status, error) {
	 			console.log("error:"+error);
	 			$.notify({
					icon: 'fa fa-exclamation-triangle',
					message: $.i18n.prop('common.server.request.fail')
		    	});
	   		},
	   		success : function(data) {
	   			//console.log('refreshTree', data);
	   			
	   			jsonTreeData = data.group;
	   			// 선택된 트리 노드 정보
	   			//selectNode = data.searchGroup;
	   			
	   			if($('#layerTree').jstree(true).settings) {
	   				$('#layerTree').jstree(true).settings.core.data = jsonTreeData;
					$("#layerTree").jstree(true).refresh();	
	   			}
			}
		}); 
	}
	
	//트리 새로고침
	$("#btnTreeRefresh").click( function () {
		
		// 화면 갱신하기
		loadDetailInfo("all");
	});
	
	// 트리검색
	$("#department_search").on("keyup",function(key){		
		// 트리 'search plugin' 검색
        var searchString = $(this).val();
        $('#layerTree').jstree('search', searchString);
        
        //if(key.keyCode==13) {
        //	$("#btnTreeRefresh").click();
        //}
    });		
	//------------------------------------------------------------------

	//대상서버 목록
	table = $('#serverTable').DataTable( {
		"processing": true,
        "serverSide": true,
		"select":true, 
		"ajax": {
			type : "POST",
			//contentType: "application/x-www-form-urlencoded; charset=UTF-8",
			dataType : "json",
			url: "<c:url value='/filterftp/getFtpDignsList.do'/>",
			data: function(param) {
				param.searchField = $('#searchField').val();
				param.searchValue = $('#searchValue').val();
				// 트리에서 선택된 서버그룹
				param.searchGroup = selectNode;
				param['_csrf'] = '${_csrf.token}';
            },
            dataSrc: function(json){
            	//--------------------------------------------------------------------------------------
            	// 점검시작, 중지 비할성하고 항목중 상태를 판단하여 할성화 처리함
            	//--------------------------------------------------------------------------------------
            	fn_btnShowHide('btnDiagnStart', true);
            	fn_btnShowHide('btnDiagnStop', true);
            	var isRunning = false;
            	for(i=0; i<json.data.length; i++){
            		if(json.data[i].job_state == 'READY'
							|| json.data[i].job_state == 'RUNNING'
							|| json.data[i].job_state_re == 'READY'
							|| json.data[i].job_state_re == 'RUNNING'){

						isRunning = true;
                	}
            	}
            	
            	if(isRunning) {            		
            		fn_btnShowHide('btnDiagnStop', false);



            		// 진단 상태를 조회한다.
            		getProgressStatus();
            	} else {
            		fn_btnShowHide('btnDiagnStart', false);
            		$('#divConsole').hide();
					progressBars = {};

            	}
            	//--------------------------------------------------------------------------------------
            	
				return json.data;
			},
			error : function(request, status, error) {
				console.log("error:"+error);
			}
    	},
    	// 데이터 로딩완료
    	"drawCallback": function( settings ) {
    		// 전체선택 해제
    		$('#select-all').iCheck('uncheck');
    	
    		// 화면 로딩시 설정된 관리자 예약유무 옵션
    		getOrgReStatusTcsList();
    		// 자동암호화 설정 원본 옵션
    		getOrgDelZipFlagList();
    	},
        "columns": [
        	{ "data": null, "title":'<input class="l_icheck" type="checkbox" id="select-all">',
            	"searchable": false,
	            "orderable": false,
	            "className": "col_center",
	            "responsivePriority": 2,
	            "render": function (data, type, full, meta){
	                return '<input type="checkbox" name="server_id" class="l_icheck" id="'+data.server_id+'" value="'+data.server_id+'">';
	            }
	        },
	        // 서버명
	        { "data": "site_name", "title":"서버명",
	        	"render": function(data, type, row, meta){	        		
	        		return '<a href="#" style="text-decoration:underline;" onclick="getFfpView('+row.ftp_seq+','+row.server_id+','+row.group_id+');"><span title="'+data+'">'+data+'</span></a>';
	            }
	        },
	        // 그룹명
	        { "data": "group_name", "title":"그룹명", "className": "col_center"},
	        // 도메인
	        { "data": "site_domain", "title":"도메인"},
	        // IP
	        { "data": "ip", "title":"IP", "className": "col_center",
				"render":function(data,type,row,meta){
					var temp = "-";

					var rVal = row.con_state;

					if(       'SUCCESS' == rVal){
						temp = "<font color='green'>"+data+"</font><img src='/admin_img/connect.png' style='max-width: 25px; height: auto;'/>";
					} else if('FAIL' == rVal){
						temp = "<font color='red'>"+data+"<img src='/admin_img/unconnect.png' style='max-width: 25px; height: auto;'/></font>";
					}else{
						temp = data;
					}

					return temp;
				}
			},
	        // 연결상태
	        //{ "data": "con_state", "title":"연결상태", "className": "col_center", render: $.fptConStateRender( 'con_state'), 'orderable': false},
	        // 진단상태 render: $.jobStateRender( 'job_state', 'SUPER_ADMIN' )
	        { "data": "job_state", "title":"진단상태", "className": "col_center", 
	        	"render": function(data, type, row, meta){
	        		var span_id = row.ftp_seq;
	        		var p_type = 'state'; // state or re
	        		return '<a href="#" onclick="goDignView(event,'+row.ftp_seq+','+row.server_id+','+row.group_id+',&#39;'+row.job_state+'&#39;,&#39;'+row.job_state_re+'&#39;,&#39;'+p_type+'&#39;);"><span id="job_state_'+span_id+'" >'+fn_getJobStateNmWithColor(data)+'</span></a>';
	        	}
	        },
	        // 예약 상태 - render: $.jobStateRender( 'job_state_re', 'SUPER_ADMIN' )
	        { "data": "job_state_re", "title":"예약상태", "className": "col_center", 
	        	"render": function(data, type, row, meta){
	        		return '<span>'+fn_getJobStateNmWithColor(data)+'</span>';
	        	}
	        },
	     	// 예약 시간
	        { "data": "re_time", "title":"예약시간", "className": "col_center", 'orderable': false,
	        	"render": function(data, type, row, meta){	        		
	        		var msg = "미사용";
	        		if(row.re_time == null){
	        			return "미설정";
	        		}
	        		else if(fn_isNotEmpty(row.re_time)){
	        			msg = row.re_time;
	        			msg = msg.split("]");
	        			msg = msg[0] + "]<br/>" + msg[1];
	        		}
	        		return msg;
	        	}
	        },
	        // 관리자 예약유무
	        { "data": "re_check", "title":'<a href="#" style="text-decoration:underline;" onclick="fnReCheckSetAll()">관리자<br/>예약유무</a>', "className": "col_center", 'orderable': false,
	        	"render": function(data, type, row, meta){
	        		if(row.re_check == "Y"){ 
		        		return '<input type="checkbox" class="s_icheck" name="re_check" id="re_check_'+row.re_check+'" checked>';
		        	}else{
		        		return '<input type="checkbox" class="s_icheck" name="re_check" id="re_check_'+row.re_check+'" >';
		        	}
	            }
	        },
	       <c:if test="${'Y' eq sessionScope.auto_encrypt }">
	        { "data": "delzip_flag", "title":'<a href="#" style="text-decoration:underline;" onclick="fnDelzipFlagSetAll()">자동<br/>암호화</a>', "className": "col_center",'orderable': false,
	        	"render": function(data, type, row, meta){
	        		if(row.delzip_flag == "Y"){ 
		        		return '<input type="checkbox" class="s_icheck3" name="delzip_flag" id="delzip_flag_'+row.delzip_flag+'" checked>';
		        	}else{
		        		return '<input type="checkbox" class="s_icheck3" name="delzip_flag" id="delzip_flag_'+row.delzip_flag+'" >';
		        	}
	            }
	        },
		   </c:if>
	        // 사용자 예약유무
	        { "data": "re_check_type", "title":"사용자<br/>예약유무", "className": "col_center", 'orderable': false,
	        	"render": function(data, type, row, meta){
	        		if(row.re_check_type == "P"){ 
		        		return '<input type="checkbox" class="s_icheck2" name="re_check_type" id="re_check_type_'+row.re_check_type+'" checked disabled="disabled">';
		        	}else{
		        		return '<input type="checkbox" class="s_icheck2" name="re_check_type" id="re_check_type_'+row.re_check_type+'" disabled="disabled">';
		        	}
	            }
	        },
	      	//최종 진단일 , render: $.dateRender( 'YYYY-MM-DD HH:mm:ss' )
	        { "data": "search_stop", "title":"최종<br>진단일", "className": "col_center"}	
         ],
	     "order": [[1, 'asc']],
	     "lengthMenu": [[15, 30, 50, 100, 1000],[15, 30, 50, 100, 1000]],
	     "pageLength": 15
	});
	
	//그리드 새로고침
	$("#btnGridRefresh").click( function () {
		// 검색조건 클리어
		$("#searchField").val("ALL");
		$("#searchValue").val("");
		
		$("#btnSearch").click();
	});
	
	//검색
	$("#btnSearch").click( function () {
		// 전체선택 해제
		$('#select-all').iCheck('uncheck');
		
		//alert($('#searchValue').val());
		//table.draw();
		$($.fn.dataTable.tables(true)).DataTable().columns.adjust().responsive.recalc();
		table.ajax.reload();
	});
	$("#searchValue").on("keydown", function(e) {
		if (e.keyCode === 13) {
			$("#btnSearch").click();
		}
	});
	
	// 등록버튼 클릭
	$("#btnServerAdd").click( function () {

		
		if(fn_isEmpty(selectNode)) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '서버 그룹을 선택하세요.'
	    	});
			return;
		}
		
		// alert결과를 확인하여 다음 단계 수행함
		location.href="<c:url value='/filterftp.do?cmd=site_list_form&command=NEW&group_id="+selectNode+"'/>";
	});
	
	// 일괄등록 팝업화면 열기
	$("#btnServerAddBulk").click( function () {
		var url = "<c:url value='/pop/getCommonPopView.do?div=filterftp&cmd=site_addbulk'/>";	
		cfmsg.windows.popup("파일진단 대상 서버 일괄 등록", url, 700, 0, null, null);
	});
	
	// 삭제 서버 목록
	var delServers = "";
	var delSiteNames = "";
	var delFtpTypes = "";
	
	// 삭제버튼 클릭
	$("#btnServerDel").click( function () {

		delServers = "";
		delSiteNames = "";
		delFtpTypes = "";
		
		// 선택된  정보 얻기
		var delRows = table.$('input:checkbox[class=l_icheck]:checked').map(function () {
		  return table.row($(this).closest('tr').first()).data();
		});
		
		//console.log(rows.toArray());
		if(delRows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '삭제 할 서버를 선택하세요.'
	    	});
			return;
		}
						
		$.each(delRows, function(){
	    	if(fn_isNotEmpty(delServers)) {
	    		delServers += ',';
	    		delSiteNames += ',';
	    		delFtpTypes += ',';
	    	}
	    	delServers += this.ftp_seq;
	    	delSiteNames += this.site_name;
	    	delFtpTypes += this.ftp_type;
	    });
		//console.log('삭제 서버 목록', delServers, delSiteNames);
		
		// 모달 삭제 알림 메시지 표시
		$("#delModal").modal('show')
		// 모달이 열린 이후 QR코드 호출
		.on('shown.bs.modal', function (e) {
			// 삭제 사용자 정보 확인
			var tempS = "<span>선택된 서버는 </span>";
			var tempE = "<span>입니다.</span><br>";
			$("#delModal #delChkInfo").html(tempS+"<label>"+delSiteNames+"</label>"+tempE);			
		});

	});		
	
	// 삭제 알림 이후 실제 삭제 처리
	$("#delModal #btnModalDel").click( function () {

		var serverForm = {'command':'DELETE', 'ftp_seq_list': delServers, 'site_name_list': delSiteNames, 'ftp_type_list' : delFtpTypes};
		
		wfds.ajax({
			type : "POST",
			async : true,
			url : "/filterftp/saveFtpServer.do",
			dataType : "json",
			timeout : 10000,
			cache : false,
			data : {				
				'serverForm' : JSON.stringify(serverForm)
			},
			error : function(request, status, error) {
				console.log("error:"+error);
				$.notify({
					icon: 'fa fa-exclamation-triangle',
					message: $.i18n.prop('common.server.request.fail')
		    	});
			},
			success : function(response, status, request) {

				if(fn_isNotEmpty(response.resultMsg)) {
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: response.resultMsg
			    	});
				}
				
   				$("#delModal").modal('hide');
   				$.notify({
   					icon: 'fa fa-check',
					message: '삭제 처리 완료'
	    		},{
	    			type:"success"
	    		});
   				
   				// 그리드 Refresh
   				$("#btnGridRefresh").click();
			}
		});
	});
	
	var orgReStatusTcsList = "";
	var orgReSiteName = "";
	// 화면 로딩시 설정된 관리자 예약유무 옵션
	function getOrgReStatusTcsList()
	{
		orgReStatusTcsList = "";
		orgReSiteName = "";
		var regRows = table.$('input[class="s_icheck"]:checked').map(function () {		
		  return table.row($(this).closest('tr').first()).data();
		});
		
		$.each(regRows, function(){
			if(fn_isNotEmpty(orgReStatusTcsList)) {
	    		orgReStatusTcsList += ',';
	    		orgReSiteName += ',';
	    	}
			if("Y" == this.re_check) {
	    		orgReStatusTcsList += this.ftp_seq;
	    		var chkName = this.site_name;
	    		orgReSiteName += chkName.replace(/,/gi, "");
	    	}
	    });
		//console.log('orgReStatusTcsList', orgReStatusTcsList, orgReSiteName);
	}
	
	var orgDelZipFlagList = "";
	var orgDelZipFlagSiteName = "";
	// 화면 로딩시 설정된 자동암호화 원본 옵션 저장함
	function getOrgDelZipFlagList()
	{
		orgDelZipFlagList = "";
		orgDelZipFlagSiteName = "";
		var regRows = table.$('input[class="s_icheck3"]:checked').map(function () {		
		  return table.row($(this).closest('tr').first()).data();
		});
		
		$.each(regRows, function(){
			if(fn_isNotEmpty(orgDelZipFlagList)) {
	    		orgDelZipFlagList += ',';
	    		orgDelZipFlagSiteName += ',';
	    	}
			if("Y" == this.delzip_flag) {
	    		orgDelZipFlagList += this.ftp_seq;
	    		var chkName = this.site_name;
	    		orgDelZipFlagSiteName += chkName.replace(/,/gi, "");
	    	}
	    });
		//console.log('orgDelZipFlagList', orgDelZipFlagList, orgDelZipFlagSiteName);
	}
	
	// 예약설정버튼 클릭
	$("#btnSetReg").click(function(){
		var regSiteName = "";
		var regSeq = "";
		var regCheck = "";	

		// 선택된  row
		//var regRows = table.$('input[class="l_icheck"]:checked').map(function () {
		var regRows = table.$('input[class="s_icheck"]:checked').map(function () {		
		  return table.row($(this).closest('tr').first()).data();
		});
    	
		//console.log(orgReStatusTcsList, fn_isEmpty(orgReStatusTcsList));
		if(fn_isEmpty(orgReStatusTcsList) && regRows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '예약 진단을 수행할 서버를 선택해주세요.'
	    	});
			return;
		}
		
		$.each(regRows, function(){
	    	if(fn_isNotEmpty(regSeq)) {
	    		regSeq += ',';
	    		regSiteName += ',';
	    		regCheck += ',';
	    	}
	    	regSeq += this.ftp_seq;
	    	regSiteName += this.site_name;
	    	regCheck += 'Y';
	    });
		//console.log('checkReStatusTcsList', regSeq, regCheck);
		
		// 관리자 예약유무 옵션이 변경되지 않은 경우는 수행안함
		if(orgReStatusTcsList == regSeq) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '관리자 예약유무를 체크 또는 해제하여 주세요.'
	    	});
			return;
		}

		var regForm = {'command':'RE_UPDATE', 'ftp_seq_lst': regSeq, 'site_domain_lst': regSiteName, 're_check_lst': regCheck, 're_org_check_lst' : orgReStatusTcsList};
		
		var result = cfmsg.windows.confirm("예약 설정", "예약을 설정 하시겠습니까?", function msgCallBack(msg){
			if('OK' === msg) {
				wfds.ajax({
					type : "POST",
					async : true,
					url : "/filterftp/setFtpReUpdate.do",
					dataType : "json",
					timeout : 10000,
					cache : false,
					data : {				
						'regForm' : JSON.stringify(regForm)
					},
					error : function(request, status, error) {
						console.log("error:"+error);
						$.notify({
							icon: 'fa fa-exclamation-triangle',
							message: $.i18n.prop('common.server.request.fail')
				    	});
					},
					success : function(response, status, request) {
						
						if(fn_isNotEmpty(response.script)) {
							$.notify({
								icon: 'fa fa-exclamation-triangle',
								message: response.script
					    	},{
							type:"success"
				    		});
						}
						
		   				// 그리드 Refresh
		   				$("#btnGridRefresh").click();
					}
				});
			}
		});
		
		
	});
		
	// 자동암호화설정 버튼 클릭
	$("#btnSetDelZipFlag").click(function(){
		var regSiteName = "";
		var regFtpSeq = "";
		var regCheck = "";

		table.rows().every( function (index) {
			var data = this.data();
			if(index!=0) {
				regFtpSeq += ',';
				regSiteName += ',';
				regCheck += ',';
			}
			regFtpSeq += data.ftp_seq;
			regSiteName += data.site_name;
			regCheck += document.getElementsByName("delzip_flag")[index].checked ? "Y" : "N";


		} );

		var regForm = {'command':'DELZIP_UPDATE', 'ftp_seq_lst': regFtpSeq, 'site_domain_lst': regSiteName, 're_check_lst': regCheck, 're_org_check_lst' : orgDelZipFlagList};
				
		var result = cfmsg.windows.confirm("자동암호화 설정", "자동암호화 처리시 최대 10개의 SFTP연결이 추가될 수 있습니다. \n자동 암호화를 설정 하시겠습니까?", function msgCallBack(msg){
			if('OK' === msg) {
				wfds.ajax({
					type : "POST",
					async : true,
					url : "/filterftp/setFtpDelZipFlagUpdate.do",
					dataType : "json",
					timeout : 10000,
					cache : false,
					data : {				
						'regForm' : JSON.stringify(regForm)
					},
					error : function(request, status, error) {
						console.log("error:"+error);
						$.notify({
							icon: 'fa fa-exclamation-triangle',
							message: $.i18n.prop('common.server.request.fail')
				    	});
					},
					success : function(response, status, request) {
						$.notify({
							icon: 'fa fa-exclamation-triangle',
							message: response.script
				    	},{
						type:"success"
			    		});
						
		   				// 그리드 Refresh
		   				$("#btnGridRefresh").click();
					}
				});
			}
		});		
		
		
	});
		
	// 진단 상태를 조회한다.
	var stopSearch = false;
	function getProgressStatus() {


		if(stopSearch) {
			return;	
		}

		
		wfds.ajaxSilent({
			type : "POST",
			async : true,
			url : "/filterftp/wfds-ftp-list-start.do",
			dataType : "json",
			timeout : 30000,
			cache : false,
			data : {				
				//'serverForm' : JSON.stringify(serverForm)
			},
			error : function(request, status, error) {
				console.log("error:"+error);
				$.notify({
					icon: 'fa fa-exclamation-triangle',
					message: $.i18n.prop('common.server.request.fail')
		    	});
			},
			success : function(response, status, request) {

				
				if(response == null || response.result == null || response.result.length == 0) {
					return;
				}

				var isRunning = false;
				
				// 진단중인 서버 목록
				var arrProgress = response.result;
				for(var r=0; r<arrProgress.length; r++) {

					//if('READY' == arrProgress[r].jobstate  || 'RUNNING' == arrProgress[r].jobstate){
					if('start' == arrProgress[r].state){
            			isRunning = true;
                	}

				}
                //완료된 progress Bar는 제거한다.
				if(arrProgress.length != pBa.getLength()){

                }
				// 진단 진행 상태를 그리드에 표시한다.
        		showCheckStatus(response.result);
				
				//--------------------------------------------------------------------------------------
            	// 점검시작, 중지 비할성하고 항목중 상태를 판단하여 할성화 처리함
            	//--------------------------------------------------------------------------------------
            	fn_btnShowHide('btnDiagnStart', true);
            	fn_btnShowHide('btnDiagnStop', true);


            	if(isRunning) {
            		$('#divConsole').show();
            		fn_btnShowHide('btnDiagnStop', false);


					for(var r=0; r<arrProgress.length; r++) {
						var id = arrProgress[r].ftpSeq
						if((id != null || id!=undefined)) {

                           if(parseInt(arrProgress[r].progress)!=100 &&( arrProgress[r].progress!=undefined || arrProgress[r].progress!=null)){
                               pBa.createChildProgressBar(id,'Y','divConsole');
                               var pObj = pBa.getProgressBar(id);
                               pObj.reloadBar(arrProgress[r].progress);
                               pObj.reloadTitle(arrProgress[r].search);
                           }else if(arrProgress[r].progress==undefined || arrProgress[r].progress==null){
                               pBa.createChildProgressBar(id,'N','divConsole');
                               var pObj = pBa.getProgressBar(id);
                               pObj.reloadTitle(arrProgress[r].search);
                           }
                        }

					}
            		setTimeout(function() {
            			getProgressStatus();
       				}, 4000);
            		
            		
            	} else {
            		stopSearch = false;
            		$('#divConsole').hide();            	            		
            		fn_btnShowHide('btnDiagnStart', false);
                    pBa.removeAll();
            		table.ajax.reload();
            	}
            	//--------------------------------------------------------------------------------------
				
				
			}
		});
	}


	// 잔단 상태 진행률을 표시한다.
	function showCheckStatus(arrProgress) {
		
		if(arrProgress == null || arrProgress.length == 0) {
			return;
		}	
		
		//===========================================================================================================================================
		// ftp 상태 처리용 샘플 배열
		//===========================================================================================================================================

		
		for(var r=0; r<arrProgress.length; r++) {

				//--------------------------------------------------------
				// 진단중 파일명 콘솔 출력
				//--------------------------------------------------------
				var srchText = arrProgress[r].searchFilePath;
				if(fn_isEmpty(srchText) || 'null' == srchText || '"null"' == srchText) {
					srchText = "...";
				}

                if(arrProgress[r].progress) {

                    if (100.0 == parseFloat(arrProgress[r].progress)) {
                            pBa.remove(arrProgress[r].ftpSeq);

                    }
                }
				//--------------------------------------------------------
			
				//--------------------------------------------------------------------
				// 진행률 정보를 그리드에 표시함
				//--------------------------------------------------------------------
				var rows = table.$('input[class="l_icheck"]').map(function () {
				  return table.row($(this).closest('tr').first()).data();
				});
				
				var s_serverId=arrProgress[r].serverId;
				var s_ftpSeq=arrProgress[r].ftpSeq;
				var s_groupId=arrProgress[r].groupId;
				var s_searchSeq=arrProgress[r].searchSeq;
				
				$.each(rows, function(){
					//console.log(this.ftp_seq, this.group_id, this.search_seq);
			    	if(s_ftpSeq == this.ftp_seq ) { //&& s_searchSeq == this.search_seq
			    		//console.log('find!!', this.rownum,this.site_name);
			    		var span_id = this.ftp_seq;  // + "_" + this.search_seq;
						//진단상태 RUNNING 이거나 예약상태 RUNNING 일때

			    		if(arrProgress[r].state=="start"){
							var sProgVal = fn_isNotEmptyVal(arrProgress[r].progress);
							if('' != sProgVal) {
								sProgVal = ' ['+sProgVal + '%]';
							}
				    		if(arrProgress[r].jobstate =='RUNNING' || arrProgress[r].jobstate =='STANDBY'){
								//진단상태가 진행중일때
								var m_job_state_nm = fn_getJobStateNm(arrProgress[r].jobstate);

								if(arrProgress[r].jobstate == 'STANDBY') {
									m_job_state_nm = '가동대기중';
								}
								$('#job_state_'+span_id).html('<font color="green">'+m_job_state_nm + sProgVal + '</font>');

							}else{
								var m_job_state_nm = fn_getJobStateNm(arrProgress[r].jobstatere);

								if(arrProgress[r].jobstatere == 'STANDBY') {
									m_job_state_nm = '가동대기중';
								}
								$('#job_state_re'+span_id).html('<font color="green">'+m_job_state_nm + sProgVal + '</font>');


							}
			    		}
			    	}
			    });
				//--------------------------------------------------------------------

		}
		//===========================================================================================================================================
	}

	// 연결테스트버튼 클릭
	$("#btnConTest").click(function(){

		conFtpSeq = "";
		
		// 선택된  사용자 정보 얻기
		var rows = table.$('input[class="l_icheck"]:checked').map(function () {
		  return table.row($(this).closest('tr').first()).data();
		});
    	
		if(rows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '연결테스트 할 서버를 선택하세요.'
	    	});
			return;
		}

		$.each(rows, function(){
	    	if(fn_isNotEmpty(conFtpSeq)) {
	    		conFtpSeq += ',';
	    	}
	    	conFtpSeq += this.ftp_seq;
	    });
		
		wfds.ajax({
			type : "POST",
			async : true,
			url : "/filterftp/ftpConnectionMultiCheck.do",
			dataType : "json",
			cache : false,
			data : {				
				'serverForm' : conFtpSeq
			},
			error : function(request, status, error) {

				$.notify({
					icon: 'fa fa-exclamation-triangle',
					message: '연결에 실패하였습니다.'
		    	});
				$("#btnSearch").click();


			},
			success : function(response, status, request) {
 				//console.log('FTP연결 테스트 결과 : ', response);
				var successText="서버명 :[";
				var failText = "";
				var isSuccess;
				var isFail;
				/*
				for(var i=0;i<response.length;i++){

					if(response[i].result == "SUCCESS"){
						debugger;
						if(response[i].reConnect=="TRUE") {
							isSuccess = true;
							successText += " " + response[i].site_name;
						}

					}else{
						if(response[i].reConnect=="TRUE") {
							isFail = true;
							failText += " "+response[i].site_name;
						}

					}
				}
				if(isSuccess){
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: successText + "] </br>연결에 성공하였습니다."
					},{
						type:"success"
					});
				}
				if(isFail){
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: failText + "] </br>연결에 실패하였습니다."
					},{
						type:"success"
					});
				}
				*/

				
				// 연결상태 갱신을 위해 그리드 Refresh
				$("#btnSearch").click();

				
			}
		});
		
	});
	
	// 진단시작버튼 클릭
	$("#btnDiagnStart").click( function(){
		var command = 'STARTSEARCH';
		searchSeq = "";
		//searchGroup = "";
		// 선택된  사용자 정보 얻기
		var rows = table.$('input[class="l_icheck"]:checked').map(function () {
		  return table.row($(this).closest('tr').first()).data();
		});
		
		if(rows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '개인정보 진단할 서버를 선택하세요.'
	    	});
			return;
		}
		
		$.each(rows, function(){
	    	if(fn_isNotEmpty(searchSeq)) {
	    		searchSeq += ',';
	    	}
	    	searchSeq += this.ftp_seq;
	    	//searchGroup = this.group_id;
	    });
		var result = cfmsg.windows.confirm("진단시작", "선택한 서버의 진단을 시작하시겠습니까?", function msgCallBack(msg){ 
			if('OK' === msg) {
				getSearch(command, searchSeq, '', '', '');
			}
		});
	});
	
	// 진단중단버튼 클릭
	$("#btnDiagnStop").click( function(){
		var command = 'STOPSEARCH';
		searchSeq = "";
		//searchGroup = "";
		// 선택된  사용자 정보 얻기
		var rows = table.$('input[class="l_icheck"]:checked').map(function () {
		  return table.row($(this).closest('tr').first()).data();
		});
		
		if(rows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '개인정보 진단중단할 서버를 선택하세요.'
	    	});
			return;
		}
		
		$.each(rows, function(){
	    	if(fn_isNotEmpty(searchSeq)) {
	    		searchSeq += ',';
	    	}
	    	searchSeq += this.ftp_seq;
	    	//searchGroup = this.group_id;
	    });
		var result = cfmsg.windows.confirm("진단중단", "선택한 서버의 진단을 중단하시겠습니까?", function msgCallBack(msg){ 
			if('OK' === msg) {
				// 진단중단
				stopSearch = true;
                var seql = this.searchSeq.split(',');
                pBa.remove(seql);

				getSearch(command, searchSeq, '', '', '');
				
				$('#divConsole').hide();
				fn_btnShowHide('btnDiagnStop', true);
				fn_btnShowHide('btnDiagnStart', false);
				//removeAllProgressBar(searchSeq);
                //remove All progressBar

        		table.ajax.reload();
        		
			}
		});
	});
	
	// 그리드 전체 선택/해제
	$(document).ajaxComplete(function( event, request, settings) {
    	//console.log(settings.url);
    	if ( settings.url === "<c:url value='/filterftp/getFtpDignsList.do'/>" ) {
    		$('input.l_icheck').iCheck({
    			checkboxClass: 'icheckbox_red_large',
    			radioClass: 'iradio_red_large',
    			indeterminateClass: 'indeterminate_large'
    		});
    		$('input.s_icheck').iCheck({
    			checkboxClass: 'icheckbox_red_small',
    			radioClass: 'iradio_red_small',
    			indeterminateClass: 'indeterminate_small'
    		});
    		$('input.s_icheck2').iCheck({
    			checkboxClass: 'icheckbox_red_small',
    			radioClass: 'iradio_red_small',
    			indeterminateClass: 'indeterminate_small'
    		});
    		$('input.s_icheck3').iCheck({
    			checkboxClass: 'icheckbox_red_small',
    			radioClass: 'iradio_red_small',
    			indeterminateClass: 'indeterminate_small'
    		});
			$('#select-all').on('ifToggled', function (event) {
				var chkToggle;
				$(this).is(':checked') ? chkToggle = "check" : chkToggle = "uncheck";
				$('input[name="server_id"]').iCheck(chkToggle);
			});
			$('#serverTable tbody input[name="server_id"]').on('ifToggled', function(){
				if($('input[name="server_id"]').filter(':checked').length == 0){
					$('#select-all').iCheck('determinate');
				}else if ($('input[name="server_id"]').filter(':checked').length == $('input[name="server_id"]').length){
					$('#select-all').iCheck('check');
				}else {
					$('#select-all').iCheck('indeterminate');
				}
			});
			$('#serverTable tbody input[name="server_id"]').on('ifToggled', function(){
				var $row = $(this).closest('tr');
				if(this.checked){
					$row.addClass('selected');
				} else {
				    $row.removeClass('selected');
				}
			});  
			table.on( 'select', function ( e, dt, type, indexes ) {
				table.$('tr.selected').find('td').eq(0).iCheck('check');
			});
			table.on( 'deselect', function ( e, dt, type, indexes ) {
				table.$('td:eq(0)').iCheck('uncheck');
			});
    	}
    	
    	
    });

	
});
	
//진단 시작 및 중단
function getSearch(command, searchSeq, serverId, searchGroup, job_state){
	//location.href="/filterftp.do?cmd=site_list&command="+command+"&ftp_seq_list="+searchSeq+"&searchGroup="+selectNode;

	wfds.ajaxSilent({
		type : "POST",
		async : true,
		url : "/filterftp/getSearch.do",
		dataType : "json",
		timeout : 10000,
		cache : false,
		data : {				
			'command' : command,
			'ftp_seq_list' : searchSeq,
			'server_id_list' : serverId,
			'job_state' : job_state
		},
		error : function(request, status, error) {
			console.log("error:"+error);
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: $.i18n.prop('common.server.request.fail')
	    	});
		},
		success : function(response, status, request) {


			table.ajax.reload();


		}
	});
}

// ftp상세정보 화면으로 이동
function getFfpView(ftpSeq, p_server_id, p_group_id){
	//console.log('선택그룹', p_group_id);
	
	location.href="/filterftp.do?cmd=site_list_form&command=UPDATE&ftp_seq="+ftpSeq+"&server_id="+p_server_id+"&group_id="+p_group_id;    
}

// 서버 진단 수행 레이어 표시
var x,y;
function goDignView(e, ftpSeq, p_server_id, p_group_id, job_state, job_state_re, type){	

	
	if('RUNNING' == job_state || 'PAUSE' == job_state || 'STANDBY' == job_state) {
		var ex_obj = document.getElementById('reStart');
		
		if('RUNNING' == job_state || 'STANDBY' == job_state) {
			ex_obj = document.getElementById('pause');
		}
		
	    if(!e) e = window.Event;
	    pos = abspos(e);
	    ex_obj.style.left = pos.x+"px";
	    ex_obj.style.top = (pos.y+10)+"px";btnSetDelZipFlag
	    ex_obj.style.display = ex_obj.style.display=='none'?'block':'none';
	    
	    // 파라메터값 임시변수 셋팅
	    document.setSearch.select_fepSeq.value = ftpSeq;
	    document.setSearch.select_serverId.value = p_server_id;
	    document.setSearch.state_type.value = type;		// 'state' or 're'
	} else {

		if(job_state == 'READY'){
			if (confirm('진단을 정지 하시겠습니까?')) {
				
				getSearch('JOBEDIT', ftpSeq, p_server_id, '', 'STOP');
                pBa.remove(ftpSeq);
				//document.setSearch.command.value = "JOBEDIT";
				//document.setSearch.action = 'wfds-ftp-list.do?ftp_seq='+ftp_seq+'&server_idx='+server_id+'&job_state=STOP';
			}
		}else{
			if (confirm('진단을 시작 하시겠습니까?')) {

				if(job_state_re=="READY"){
					//alert("예약진단 대기중인 서버 입니다.");
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: '예약진단 상태가 대기중인 서버 입니다.'
			    	});
					return;
				}else if(job_state_re=="RUNNING"){
					//alert("예약진단 진단중인 서버 입니다.");
					$.notify({
						icon: 'fa fa-exclamation-triangle',
						message: '예약진단 상태가 진단중인 서버 입니다.'
			    	});
					return;
				}else{
					getSearch('JOBEDIT', ftpSeq, p_server_id, '', 'READY');
					//document.setSearch.command.value = "JOBEDIT";
					//document.setSearch.action = 'wfds-ftp-list.do?ftp_seq='+ftp_seq+'&server_idx='+server_id+'&job_state=READY';
				}
			}		
		}
	}
}
function abspos(e){
  this.x = e.clientX + (document.documentElement.scrollLeft?document.documentElement.scrollLeft:document.body.scrollLeft);
  this.y = e.clientY + (document.documentElement.scrollTop?document.documentElement.scrollTop:document.body.scrollTop);
  return this;
}
function hide_div(state) {
	var ex_obj = document.getElementById(state);
	ex_obj.style.display = ex_obj.style.display=='none'?'block':'none';
	
	// 파라메터값 임시변수 초기화
    document.setSearch.select_fepSeq.value = '';
    document.setSearch.select_serverId.value = '';
    document.setSearch.state_type.value = '';	
}

// 서버 작업 명령 수행
function job_update(state){
	var ftp_seq = document.setSearch.select_fepSeq.value;
    var server_id = document.setSearch.select_serverId.value;
    var state_type = document.setSearch.state_type.value;
    var type;
    if (state_type=="state") {
    	type = "JOBEDIT";
	}else{
		type = "JOBEDITRE";
	}
    
	if(state == 'RUNNING'){
		if (confirm('진단을 재시작 하시겠습니까?')) {
			getSearch(type, ftp_seq, server_id, '', state);
            document.getElementById('pause').style.display="none";
            document.getElementById('reStart').style.display="none";

		}
	}
	if(state == 'STOPING'){
		if (confirm('진단을 완전정지 하시겠습니까?')) {
			getSearch(type, ftp_seq, server_id, '', state);
            document.getElementById('pause').style.display="none";
            document.getElementById('reStart').style.display="none";
            pBa.remove(ftp_seq)

		}
	}
	if(state == 'PAUSE'){
		if (confirm('진단을 일시정지 하시겠습니까?')) {
			getSearch(type, ftp_seq, server_id, '', state);
            document.getElementById('pause').style.display="none";
            document.getElementById('reStart').style.display="none";

		}
	}
}

// 관리자 예약유무 전체 선택/해제 
var chkToggleReCheck = "uncheck";
function fnReCheckSetAll() {
	(chkToggleReCheck == 'uncheck') ? chkToggleReCheck = "check" : chkToggleReCheck = "uncheck";
	$('input[name="re_check"]').iCheck(chkToggleReCheck);
}

// 자동 암호화 전체 선택/해제 fnReCheckSetAll
var chkToggleDelzip = "uncheck";
function fnDelzipFlagSetAll() {	
	(chkToggleDelzip == 'uncheck') ? chkToggleDelzip = "check" : chkToggleDelzip = "uncheck";
	$('input[name="delzip_flag"]').iCheck(chkToggleDelzip);
}

</script>


<c:set var="pageName">파일 진단 관리</c:set>

<!-- Content Header (Page header) -->
<section class="content-header">
	<h1> <span></span><spring:message code="settings.leftNav.menu_8" /> <small><spring:message code="settings.header_info_8" /></small> </h1>
	<ol class="breadcrumb">
		<li><a href="./"><i class="fa fa-home"></i><spring:message code="common.home"/></a></li>
		<li><a href="./filterftp.do?cmd=site_list&searchGroup=all"><spring:message code="common.file.diag"/></a></li>
		<li class="active"><spring:message code="filterftp.total.west.title1" /></li>
	</ol> 
</section>
<!-- // Content Header (Page header) -->

<!-- Main content -->
<section class="content">
   <div class="row" >
   		<section class="col-xs-12 col-md-2 col-xs-3 connectedSortable">
			<div class="box box-primary">
				<!-- box-header -->
				<div class="box-header">
					<h3 class="box-title"><spring:message code="filterftp.file.trg.group" /></h3>
					<button type="button" class="btn btn-success btn-sm" id="btnTreeRefresh" title="<spring:message code="common.reload"/>"><i class="fa fa-refresh" aria-hidden="true"></i></button>
				</div>
				<!-- /.box-header -->

				<div class="box-body">
					<input type="text" class="form-control input-sm" id="department_search" placeholder="Search" style="ime-mode:active; background:url('/resources/img/common /search_icon.png') top right no-repeat;background-size: 30px;">
					<div id="layerTree" class="tree" ></div>
				<!-- //box-body -->
				</div>
			</div>
		</section>
		
		<section class="col-xs-12 col-md-10 col-xs-9 connectedSortable">
			<div class="box box-primary">
				<!-- box-header -->
				<div class="box-header">
					<h3 class="box-title"><spring:message code="filterftp.file.trg.server.list" /></h3>
					<button type="button" class="btn btn-success btn-sm" id="btnGridRefresh" title="<spring:message code="common.reload"/>"><i class="fa fa-refresh" aria-hidden="true"></i></button>
				</div>
				<!-- // box-header -->
				
				<!-- box-body -->
				<div class="box-body">

				<c:if test="${sessionScope.loginAuthorities=='[ROLE_SUPER]' || registrationAuth eq 'Y'  || registrationAuth eq 'S'}">
					<button type="button" class="btn btn-primary" id="btnServerAdd" title='<spring:message code="settings.page.reg" arguments="${pageName }"/>'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.register" /></span></button>
 					<button type="button" class="btn btn-primary" id="btnServerAddBulk" title='<spring:message code="settings.page.regBulk" arguments="${pageName }"/>'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.register.blcuk" /></span></button>
					<button type="button" class="btn btn-warning" id="btnServerDel" title='<spring:message code="settings.page.del" arguments="${pageName }"/>'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.del" /></span></button>
					<button type="button" class="btn btn-primary" id="btnConTest" title='<spring:message code="common.connect.test" />'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.connect.test" /></span></button>
					<button type="button" class="btn btn-primary-red" id="btnDiagnStop" title='파일진단 종료' style="display:none"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.diag.stop" /></span></button>
					<button type="button" class="btn btn-primary" id="btnDiagnStart" title='파일진단 수행' ><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.diag.start" /></span></button>
					<button type="button" class="btn btn-primary" id="btnSetReg" title='파일진단 예약설정'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.reservation.set" /></span></button>				

					<c:if test="${'Y' eq sessionScope.auto_encrypt }">
					<button type="button" class="btn btn-primary" id="btnSetDelZipFlag" title='파일 자동 암호화 설정'><i class="fa " aria-hidden="true"></i><span class="text">자동암호화설정</span></button>
					</c:if>
				</c:if>
				<c:if test="${registrationAuth eq 'N' || registrationAuth eq 'C'}">
					<button type="button" class="btn btn-primary" id="btnConTest" title='<spring:message code="common.connect.test" />'><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.connect.test" /></span></button>
					<button type="button" class="btn btn-primary-red" id="btnDiagnStop" title='파일진단 종료' style="display:none"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.diag.stop" /></span></button>
					<button type="button" class="btn btn-primary" id="btnDiagnStart" title='파일진단 수행' ><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.diag.start" /></span></button>
				</c:if>
					
					<!-- Search Input Area -->
					<div class="searchForm" >

						<select class="form-control searchField" id="searchField" name="searchField">
							<option value="ALL"><spring:message code="common.all"/></option>
							<option value="serverName"><spring:message code="statistics.server.name" /></option>
							<option value="groupName"><spring:message code="settings.group_name" /></option>
							<option value="ip"><spring:message code="settings.history.report.ip1" /></option>
							<option value="siteDomain"><spring:message code="filter.log.report.domain" /></option>
						</select>

						<input type="text" class="form-control SEARCHTEXT" id="searchValue" name="searchValue" style="width:200px;" />
						<button class="btn btn-primary" type="button" id='btnSearch' style="vertical-align:baseline;">
							<i class="fa " aria-hidden="true"></i>
							<span><spring:message code="common.search"/></span>
						</button>

					</div>
				    <!-- // Search Input Area -->
				    
				    <c:if test="${'Y' eq sessionScope.auto_encrypt }">
					<div class="box-primary" style="padding-top: 10px;">
						<span style="color: red;">자동 암호화 설정 후 진단 시 개인정보가 존재하는 파일은 자동 암호화됩니다.</span>
					</div>
					</c:if>
				    
				    <!-- 진단 로그 출력 -->
				    <div class="box2 box-primary2" id="divConsole" style="display:none">
						<!-- box-header -->
						<%/*
						<div class="box-header">
							<h3 class="box-title">파일진단중&nbsp;&nbsp;<span id="spProgrss"></span>&nbsp;...</h3>
							<progress id="file" max="100" value="0"></progress>
						</div>
						<!-- /.box-header -->
						<!-- box-body -->
						<div class="box-body">
							<textarea id="txtConsole" rows="1" style="width:100%; height: 160px; white-space:pre;" readonly="readonly"></textarea>
						</div>
						*/%>
					</div>
				    
				    <!-- Grid Area -->
				    <table id="serverTable" class="table table-striped table-bordered table-hover dt-responsive nowrap" style="width:100%;"></table>
				    <!-- // Grid Area -->
				    
				</div>
				<!-- //box-body -->
			</div>
		</section>	
	</div>
</section>
<!-- // Main content -->

<!-- 서버 삭제 팝업 -->
<div class="modal fade" id="delModal" data-backdrop="static" tabindex="-1" role="dialog" aria-hidden="true" >
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" ><span aria-hidden="true">×</span><span class="sr-only">Close</span></button>
		<h4 class="modal-title"><spring:message code="settings.server.del" /></h4>
	      </div>
	      <div class="modal-body" style="text-align:center; padding:15px;">
	      	<span id="delChkInfo"></span>
			<label><spring:message code="settings.message.server.del.comment" /></label>
	      </div>
	      <div class="modal-footer">
	      	<button type="button" class="btn btn-primary" id="btnModalDel"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.ok"/></span></button>
          	<button type="button" class="btn btn-warning" data-dismiss="modal"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.cancel"/></span></button>
     	 </div>
    </div>
  </div>
</div>

<!-- 진단 중지 처리 래이어 -->
<form name="setSearch" method="post" onsubmit="return false">
<input type="hidden" id='select_fepSeq' name="select_fepSeq">
<input type="hidden" id='select_serverId' name="select_serverId">
<input type="hidden" id='state_type' name="state_type">
</form>
<div id='reStart' style="position: absolute; left: 0px; top: 0px; z-index: 1; display: none;">
	<table width="80" height="30" borderColor=#c8c8c8 bgColor=#FFFFFF cellSpacing=0 cellPadding=0 border=1 style="padding-top: 3">
		<tr><td align="center" width="*" style="background-color: #DCEBFF;" style="padding-left:5px"><font color="black" size="2"><b>MENU</b></font></td><td align="center" width="14" style="background-color: #DCEBFF;"><img src="/resources/img/ico/error.png" width="14" height="13" title="닫기" onclick="hide_div('reStart')" /></td></tr>
		<tr><td align="left" colspan="2" style="padding-left:4px"><a onclick="job_update('STOPING');"><img src="/resources/img/ico/stop.gif"/><font color="black">&nbsp;<b>정지</b></font></a></td></tr>
		<tr><td align="left" colspan="2" style="padding-left:4px"><a onclick="job_update('RUNNING');"><img src="/resources/img/ico/start.gif"/><font color="black">&nbsp;<b>재시작</b></font></a></td></tr>
	</table>
</div>
<div id='pause' style="position: absolute; left: 0px; top: 0px; z-index: 1; display: none;">
	<table width="85" height="30" borderColor=#c8c8c8 bgColor=#DCEBFF cellSpacing=0 cellPadding=0 border=1 style="padding-top: 3;background-color: #FFFFFF">
		<tr><td align="center" width="*" style="background-color: #DCEBFF;" style="padding-left:5px"><font color="black" size="2"><b>MENU</b></font></td><td align="center" width="14" style="background-color: #DCEBFF;"><img src="/resources/img/ico/error.png" width="14" height="13" title="닫기" onclick="hide_div('pause')" /></td></tr>
		<tr><td align="left" colspan="2" style="padding-left:4px;cursor: pointer"><a onclick="job_update('STOPING');"><img src="/resources/img/ico/stop.gif"/><font color="black">&nbsp;<b>정지</b></font></a></td></tr>
		<tr><td align="left" colspan="2" style="padding-left:4px;cursor: pointer"><a onclick="job_update('PAUSE');"><img src="/resources/img/ico/pause.gif"/><font color="black">&nbsp;<b>일시정지</b></font></a></td></tr>
	</table>
</div>
