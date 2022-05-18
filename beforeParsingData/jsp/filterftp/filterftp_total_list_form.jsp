<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/cmmn/frd_libs.jsp" %>
<%
 /**
  * @Class Name : 진단 파일 상세 리스트 상세
  * @Description : 진단 파일 상세 리스트 상세
  * @Modification Information
  * - AS-IS 코드 : total_list.jsp
  *
  * @author FRD kss
  * @since 2021.08.27
  * @version 2.0
  * @see
  *
  * Copyright (C) Jirandata. All right reserved.
  */
%>
<script type="text/javaScript" language="javascript" defer="defer">

/**************************************************
 *  document ready function 
 **************************************************/
$(document).ready(function(){	
		
	//---------------------------------------------
	// radio/checkbox 스타일 입히기
	//---------------------------------------------
	$('input.s_icheck').iCheck({
		checkboxClass: 'icheckbox_red_small'
		//,radioClass: 'iradio_red_small'
	});	
	$('input.l_icheck').iCheck({
		checkboxClass: 'icheckbox_red_large'
		//,radioClass: 'iradio_red_large'
	});
	//---------------------------------------------
	
	
	//-----------------------------------------------------------------------
	// 일자 검색 설정
	//-----------------------------------------------------------------------
	// 진단 검색 구간 설정
	$('#search_s_date').val(moment().add(-7, 'day').format('YYYY[-]MM[-]DD'));
	$('#search_e_date').val(moment().format('YYYY[-]MM[-]DD'));
    $('#start').datetimepicker({
    	locale: 'ko',
    	format: 'YYYY-MM-DD'
    });
    $('#end').datetimepicker({
    	locale: 'ko',
        useCurrent: false,
        format: 'YYYY-MM-DD'
    });
    
  	//기간유형 변경시
	var searchPeriodTp = '1';
  	$('#dt_period').val(searchPeriodTp);

	// 콤보로 구성
	$('select[name=dt_period]').change( function () {
		//console.log('change');
	
		searchPeriodTp = $(this).val();
		
		// 하루
		if('0' == searchPeriodTp) {
			$('#search_s_date').val(moment().add(-1, 'day').format('YYYY[-]MM[-]DD'));
		    $('#search_e_date').val(moment().format('YYYY[-]MM[-]DD'));
		}
		// 일주일
		if('1' == searchPeriodTp) {
			$('#search_s_date').val(moment().add(-7, 'day').format('YYYY[-]MM[-]DD'));
		    $('#search_e_date').val(moment().format('YYYY[-]MM[-]DD'));
		}
		// 한달
		else if('2' == searchPeriodTp) {
			$('#search_s_date').val(moment().add(-1, 'month').format('YYYY[-]MM[-]DD'));
		    $('#search_e_date').val(moment().format('YYYY[-]MM[-]DD'));
		}
		// 기간설정
		else if('3' == searchPeriodTp) {
			fn_formDisabled('search_s_date', false);
			fn_formDisabled('search_e_date', false);
			fn_formDisabled('search_s_hour', false);
			fn_formDisabled('search_e_hour', false);
		}
	});
	
  	//-----------------------------------------------------------------------
  	
	// 조회정보를 화면에 매핑한다.
	var jsonResult = JSON.parse('${jsonResult}');
	console.log(jsonResult);	
	
	//----------------------------------------------------------------------
	// 코드 명칭으로 변경
	//----------------------------------------------------------------------
	jsonResult.search_type = fn_getResultTpRender(jsonResult.search_type);
	jsonResult.search_result = fn_getResultRender(jsonResult.search_error, -1);
	//console.log(jsonResult);	
	//----------------------------------------------------------------------
	
	
	cf_setContainerData("ftpDtil", jsonResult);
	
	//대상서버 목록
	var table = $('#serverTable').DataTable( {
		"processing": true,
        "serverSide": true,
		"select":true, 
		"ajax": {
			type : "POST",
			dataType : "json",
			url: "<c:url value='/filterftp/getFtpTotalFileList.do'/>",
			data: function(param) {
				param.searchField = $('#searchField').val();
				param.searchValue = $('#searchValue').val();
				param.ftpSeq = $('#ftp_seq').val();
				param.searchSeq = $('#search_seq').val();
				param.searchGroup = $('#group_id').val();
				
				if(fn_isNotEmpty($('#search_s_date').val())) {
					param.searchStart = $('#search_s_date').val()+" "+$("#search_s_hour").val();
				}
				if(fn_isNotEmpty($('#search_e_date').val())) {
					param.searchStop = $('#search_e_date').val()+" "+$("#search_e_hour").val();
				}
				
				param['_csrf'] = '${_csrf.token}';
            },
            dataSrc: function(json){
            	//totalCnt=json.recordsTotal;
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
    	},
        "columns": [
        	{ "data": null, "title":'<input class="l_icheck" type="checkbox" id="select-all">',
            	"searchable": false,
	            "orderable": false,
	            "className": "col_center",
	            "responsivePriority": 2,
	            "render": function (data, type, full, meta){
	                return '<input type="checkbox" name="ftp_total_seq" class="l_icheck" id="'+data.ftp_total_seq+'" value="'+data.ftp_total_seq+'">';
	            }
	        },
	        { "data": "search_seq", "title":"진단차수", "className": "col_center"},
	        { "data": "reg_date", "title":"진단시간", "className": "col_center", render: $.timeStampRenderMilliSec('YYYY-MM-DD HH:mm:ss')},
	        { "data": "ftp_file_time", "title":"파일생성일자", "className": "col_center", render: $.timeStampRender('YYYY-MM-DD HH:mm:ss')},
	        { "data": "ftp_path", "title":"진단 파일",
	        	// 말줄임 표시
	        	render: $.fn.dataTable.render.ellipsis( 100, true )
	        },
	        { "data": "ftp_file_hash", "title":"파일용량", "className": "col_center", render: $.fileSizeRenderEx()},
	        { "data": "folder_type", "title":"디렉토리/파일", "className": "col_center", render: $.folderTypeRender('folder_type')},
	        { "data": "folder_count", "title":"파일 수", "className": "col_center"},
         ],
	     "order": [[3, 'desc']],
	     "lengthMenu": [[15, 30, 50, 100, 1000],[15, 30, 50, 100, 1000]],
	     "pageLength": 15,
	     "dom": '<"dt_export_div"tilpB>',
	     "buttons":[{
				extend:'csvHtml5',
				title: 'ftp_total_list_excel_'+$('#site_name').html(),
				text: ' ',
				footer: true,
				bom: true,
				className: 'exportCSV',
				"action": newexportaction
		  }] 
	});
	
	//그리드 새로고침
	$("#btnGridRefresh").click( function () {
		// 검색조건 클리어
		$("#searchField").val("ftp_path");
		$("#searchValue").val("");
		
		// 진단 검색 구간 설정
		$('#search_s_date').val(moment().add(-7, 'day').format('YYYY[-]MM[-]DD'));
		$('#search_e_date').val(moment().format('YYYY[-]MM[-]DD'));
		
		//기간유형 변경시
		var searchPeriodTp = '1';
		$('#dt_period').val(searchPeriodTp);
		$("#search_s_hour").val("01");
		$("#search_e_hour").val("24");
		
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
	
	// 엑셀 다운로드 
	$("#btnListDownload").click( function () {
		$(".exportCSV").click();
	});
	
	// 체크된 삭제 사용자 rows
	var delRows = [];
	var delIds = "";
	
	// 삭제버튼 클릭
	$("#btnErrorDel").click( function () {

		// 체크정보 초기화
		delRows = [];
		delIds = "";
		
		// 선택된  사용자 정보 얻기
		delRows = table.$('input:checkbox[class=l_icheck]:checked').map(function () {
		  return table.row($(this).closest('tr').first()).data();
		});
		
		//console.log(rows.toArray());
		if(delRows.length == 0) {
			$.notify({
				icon: 'fa fa-exclamation-triangle',
				message: '삭제 할 항목을 선택하세요.'
	    	});
			return;
		}
						
		$.each(delRows, function(){
	    	if(fn_isNotEmpty(delIds)) {
	    		delIds += ',';
	    	}
	    	delIds += this.ftp_total_seq;
	    });
		//console.log('삭제 사용자 목록', delUsers);
		
		var totalForm = {'command':'TOTALDEL', "ftp_total_seqs": delIds, "ftp_seq": $("#ftp_seq").val(), "search_seq": $("#search_seq").val()};
		//console.log(errorForm);
		
		//confirm결과를 확인하여 다음 단계 수행함
		var result = cfmsg.windows.confirm("삭제 확인", "선택한 진단 정보를 삭제하시겠습니까?", function msgCallBack(msg){
			if('OK' === msg) {
				wfds.ajax({
					type : "POST",
					url : "<c:url value='/filterftp/getFtpTotalDelete.do'/>",
					dataType : "json",
					data : {				
						'totalForm' : JSON.stringify(totalForm)
					},
					success: function (response){
						if(fn_isNotEmptyVal(response.result) >= 0) {
							var notiMsg = '삭제가 완료 되었습니다.';
							$.notify({icon: 'fa fa-check',message: notiMsg},{type:"success"});
						} else {
							$.notify({
								icon: 'fa fa-exclamation-triangle',
								message: "삭제 실패."
				    		});
						}
		   				// 그리드 Refresh
		   				table.ajax.reload();
					},
					error: function (XMLHttpRequest,status,error){
					}
				});
			}
		});

	});	
	
	// 그리드 전체 선택/해제
	$(document).ajaxComplete(function( event, request, settings) {
    	//console.log(settings.url);
    	if ( settings.url === "<c:url value='/filterftp/getFtpTotalFileList.do'/>" ) {
    		$('input.l_icheck').iCheck({
    			checkboxClass: 'icheckbox_red_large',
    			radioClass: 'iradio_red_large',
    			indeterminateClass: 'indeterminate_large'
    		});
			$('#select-all').on('ifToggled', function (event) {
				var chkToggle;
				$(this).is(':checked') ? chkToggle = "check" : chkToggle = "uncheck";
				$('input[name="ftp_total_seq"]').iCheck(chkToggle);
			});
			$('#serverTable tbody input[name="ftp_total_seq"]').on('ifToggled', function(){
				if($('input[name="ftp_total_seq"]').filter(':checked').length == 0){
					$('#select-all').iCheck('determinate');
				}else if ($('input[name="ftp_total_seq"]').filter(':checked').length == $('input[name="ftp_total_seq"]').length){
					$('#select-all').iCheck('check');
				}else {
					$('#select-all').iCheck('indeterminate');
				}
			});
			$('#serverTable tbody input[name="ftp_total_seq"]').on('ifToggled', function(){
				var $row = $(this).closest('tr');
				if(this.checked){
					$row.addClass('selected');
				} else {
				    $row.removeClass('selected');
				}
			});  
			table.on( 'select', function ( e, dt, type, indexes ) {
				table.$('tr.selected').iCheck('check');
			});
			table.on( 'deselect', function ( e, dt, type, indexes ) {
				table.$('tr').iCheck('uncheck');
			});
    	}
    	
    	
    });
	
});

</script>


<!-- Content Header (Page header) -->
<section class="content-header">
	<h1> <span></span><spring:message code="filterftp.total.form.title1" /><small><spring:message code="filterftp.total.form.title2" /></small> </h1>
	<ol class="breadcrumb">
		<li><a href="./"><i class="fa fa-home"></i><spring:message code="common.home"/></a></li>
		<li><a href="./filterftp.do?cmd=site_list&searchGroup=all"><spring:message code="common.file.diag"/></a></li>
		<li class="active"><spring:message code="filterftp.total.list.title1" /></li>
	</ol>
</section>

<!-- Main content -->
<section class="content">
   	<div class="row">
		<section class="col-xs-12 connectedSortable">
			<div class="box box-primary">
				<!-- box-header -->
				<div class="box-header">
					<h3 class="box-title"><spring:message code="filterdb.pop.error.title3" /></h3>
				</div>
				<!-- /.box-header -->
				<!-- box-body -->
				<div class="box-body">
		   			<div class="form-group">

						<form class="form-horizontal" id="ftpDtil">	
							<input type="hidden" id="ftp_seq" name="ftp_seq" />	
							<input type="hidden" id="search_seq" name="search_seq" />
							<input type="hidden" id="server_id" name="server_id" />	
							<input type="hidden" id="group_id" name="group_id" />	
															
							<table class="table table-bordered-dtil">
								<colgroup>
									<col width="20%;"/>
									<col width="30%;"/>
									<col width="20%;"/>
									<col width="30%;"/>
								</colgroup>
								<tr>
									<th ><spring:message code="filter.policy.servername" /></th>												
									<td><span id="site_name" class=isTextView></span></td>
									<th ><spring:message code="settings.group_name" /></th>
									<td><span id="group_name" class=isTextView></span></td>
								</tr>
								<tr>
									<th ><spring:message code="filter.log.report.domain.name" /></th>
									<td><span id="site_domain" class=isTextView></span></td>
									<th ><spring:message code="filter.ip" /></th>
									<td><span id="ip" class=isTextView></span></td>
								</tr>
								<tr>
									<th ><spring:message code="privacy.search.type1" /></th>
									<td><span id="search_type" class=isTextView></span></td>
									<th ><spring:message code="common.diag.result" /></th>
									<td><span id="search_result" class=isTextView></span></td>
								</tr>
								<tr>
									<th ><spring:message code="common.diag.start" /></th>
									<td><span id="search_start" class=isTextView></span></td>
									<th ><spring:message code="common.diag.finish" /></th>
									<td><span id="search_stop" class=isTextView></span></td>
								</tr>
							</table>
						</form>

					</div>
				</div>
					
			</div>
			<div class="box box-primary">
				<div class="box-header">
					<h3 class="box-title"><spring:message code="common.diag.stat" /></h3>
					<button type="button" class="btn btn-success btn-sm" id="btnGridRefresh" title="<spring:message code="common.reload"/>"><i class="fa fa-refresh" aria-hidden="true"></i></button>					
					<button type="button" class="btn btn-default" id="btnListDownload" style="float:right; margin-top:3px; margin-right:5px"><i  aria-hidden="true"></i><spring:message code="common.excel_export" /></button>
				</div>

				<div class="box-body">
					<div class="divHoriz">
					
					<c:if test="${sessionScope.loginAuthorities=='[ROLE_SUPER]' || registrationAuth eq 'Y'  || registrationAuth eq 'S'}">
						<button type="button" id="btnErrorDel" class="btn btn-warning" title="진단현황삭제"><i class="fa " aria-hidden="true"></i><span class="text"><spring:message code="common.del" /></span></button>
					</c:if>

						<select class="form-control w130" id="dt_period" name="dt_period">
							<option value="0" selected="selected"><spring:message code="common.one.day" /></option>
							<option value="1"><spring:message code="common.week" /></option>
							<option value="2"><spring:message code="common.one.month" /></option>
							<option value="3"><spring:message code="common.select.user" /></option>
						</select>
						
						<div id='search_date_start'>
						    <div class='input-group date' id='start' style="width:150px;">
						        <input type='text' class="form-control" id='search_s_date' />	<!-- disabled="disabled" -->
						        <span class="input-group-addon common_gray">
						            <i class="fa fa-calendar" aria-hidden="true"></i>
						        </span>
						    </div>						    
						</div>
						<select class="form-control w70" id="search_s_hour" name="search_s_hour" >	<!-- disabled="disabled" -->
							
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
						</select><span><label for="search_s_hour" class="label_normal_cursor"><spring:message code="common.time" /></label></span>
						<div id='search_date_span' style="padding:0 10px; margin-top:7px;">~</div>
						<div id='search_date_end'>
						    <div class='input-group date' id='end' style="width:150px;">
						        <input type='text' class="form-control" id='search_e_date' />	<!-- disabled="disabled" -->
						        <span class="input-group-addon common_gray">
						            <i class="fa fa-calendar" aria-hidden="true"></i>
						        </span>
						    </div>
					    </div>
					    <select class="form-control w70" id="search_e_hour" name="search_e_hour" >	<!-- disabled="disabled" -->
					    	
							<option value="01" >01</option>
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
							<option value="24" selected="selected">24</option>
						</select><span><label for="search_e_hour" class="label_normal_cursor"><spring:message code="common.time" /></label></span>
					</div>
					
					<div class="searchForm divHorizWithSrch" >	<!-- style="margin-top: -34px;" -->
						<select class="form-control searchField" id="searchField" name="searchField">
							<option value="ftp_path" selected="selected"><spring:message code="common.diag.file" /></option>
						</select>
						<input type="text" class="form-control SEARCHTEXT" id="searchValue" name="searchValue" style="width:200px;" />
						<button class="btn btn-primary" type="button" id='btnSearch' style="vertical-align:baseline;">
							<i class="fa " aria-hidden="true"></i>
							<span><spring:message code="common.search"/></span>
						</button>
					</div>
								
					<!-- Grid Area -->
					<table id="serverTable" class="table table-striped table-bordered table-hover dt-responsive nowrap" style="width: 100%"></table>					
				</div>
				<!-- //box-body -->				
			</div>

	</section>
</div>
</section>
<!-- // Main content -->