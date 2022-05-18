<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/cmmn/frd_libs.jsp" %>
<%
 /**
  * @Class Name : 진단 파일  리스트 
  * @Description : 진단 파일  리스트
  * @Modification Information
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

//트리노드 선택정보
var selectText = "모든서버";
var selectNode = '${searchGroup}';

/**************************************************
 *  document ready function 
 **************************************************/
$(document).ready(function(){	
	
	//-----------------------------------------------------------------------
	// 일자 검색 설정
	//-----------------------------------------------------------------------
	// 진단 검색 구간 설정
	$('#search_s_date').val(moment().format('YYYY[-]MM[-]DD'));
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
  	//-----------------------------------------------------------------------
	
 	// 상세 정보 조회
	function loadDetailInfo(searchGroup) {
		location.href="./filterftp.do?cmd=total_list&searchGroup="+searchGroup;
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
	
	// tree 선택
	$("#layerTree").bind("select_node.jstree", function(evt, data){
		console.log(evt, data);
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
		/* // 트리 선택 해제
		selectNode = "0";
		
		// 트리 노드 클리어
		$('#layerTree').jstree(true).settings.core.data = null;
		$("#layerTree").jstree(true).refresh();	
		
		// 트리 조회
		refreshTree();	 */
		
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
	var table = $('#serverTable').DataTable( {
		"processing": true,
        "serverSide": true,
		"select":true, 
		"ajax": {
			type : "POST",
			dataType : "json",
			url: "<c:url value='/filterftp/getFtpTotalSiteList.do'/>",
			data: function(param) {
				param.searchField = $('#searchField').val();
				param.searchValue = $('#searchValue').val();
				// 트리에서 선택된 서버그룹
				param.searchGroup = selectNode;
				// 일자 검색 구간
				if('searchStart' == searchField) {					
					$("#search_input").val("");
					$("#search_date_end").val("");
				} else if('searchStop' == searchField) {
					$("#search_input").val("");
					$("#search_date_start").val("");
				} else if('searchDate' == searchField) {
					$("#search_input").val("");
				}
				param.searchStart = $('#search_s_date').val();
				param.searchStop = $('#search_e_date').val();
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
        	/* { "data": null, "title":'<input class="l_icheck" type="checkbox" id="select-all">',
            	"searchable": false,
	            "orderable": false,
	            "className": "col_center",
	            "responsivePriority": 2,
	            "render": function (data, type, full, meta){
	                return '<input type="checkbox" name="server_id" class="l_icheck" id="'+data.server_id+'" value="'+data.server_id+'">';
	            }
	        }, */
	     	// 진단차수
	        { "data": "search_seq", "title":"진단차수", "className": "col_center"},
	     	// 서버명
	        { "data": "site_name", "title":"서버명",
	        	"render": function(data, type, row, meta){	        		
	        		return '<a href="#" style="text-decoration:underline;" onclick="getFtpTotalView('+row.ftp_seq+','+row.server_id+','+row.group_id+','+row.search_seq+');"><span title="'+data+'">'+data+'</span></a>';
	            }
	        },
	     	// 그룹명
	        { "data": "group_name", "title":"그룹명", "className": "col_center"},
	        // 도메인
	        { "data": "site_domain", "title":"도메인"},
	        // IP
	        { "data": "ip", "title":"IP", "className": "col_center"},
	        // 진단형태
	        { "data": "search_type", "title":"진단형태", "className": "col_center", render: $.srchResultTpRender( 'search_type' )},
	        // 진단시작
	        { "data": "search_start", "title":"진단시작", render: $.dateRender( 'YYYY-MM-DD HH:mm:ss' )},
	     	// 진단종료
	        { "data": "search_stop", "title":"진단종료", render: $.dateRender( 'YYYY-MM-DD HH:mm:ss' )},
         ],
	     "order": [[7, 'desc']],
	     "lengthMenu": [[15, 30, 50, 100, 1000],[15, 30, 50, 100, 1000]],
	     "pageLength": 15
	});
	
	//그리드 새로고침
	$("#btnGridRefresh").click( function () {
		// 검색조건 클리어
		$("#searchField").val("serverName");
		$("#searchValue").val("");
		
		$("#search_date_start").hide();
		$("#search_date_span").hide();
		$("#search_date_end").hide();
		$("#search_input").show();
		
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
	
	//검색구분 변경시
	$("#searchField").change( function () {
		var searchField = $(this).val();

		$("#search_date_start").hide();
		$("#search_date_span").hide();
		$("#search_date_end").hide();
		
		if('searchStart' == searchField) {
			$("#search_date_start").show();
			$("#search_input").hide();
		} else if('searchStop' == searchField) {
			$("#search_date_end").show();
			$("#search_input").hide();
		} else if('searchDate' == searchField) {
			$("#search_date_start").show();
			$("#search_date_span").show();
			$("#search_date_end").show();
			$("#search_input").hide();
		} else {
			$("#search_input").show();
		}
	});
	
	
	// 그리드 전체 선택/해제
	/* $(document).ajaxComplete(function( event, request, settings) {
    	//console.log(settings.url);
    	if ( settings.url === "<c:url value='/filterftp/getFtpTotalSiteList.do'/>" ) {
    		$('input.l_icheck').iCheck({
    			checkboxClass: 'icheckbox_red_large',
    			radioClass: 'iradio_red_large',
    			indeterminateClass: 'indeterminate_large'
    		});
			$('#select-all').on('ifToggled', function (event) {
				var chkToggle;
				$(this).is(':checked') ? chkToggle = "check" : chkToggle = "uncheck";
				$('input[name="serverId"]').iCheck(chkToggle);
			});
			$('#serverTable tbody input[name="serverId"]').on('ifToggled', function(){
				if($('input[name="serverId"]').filter(':checked').length == 0){
					$('#select-all').iCheck('determinate');
				}else if ($('input[name="serverId"]').filter(':checked').length == $('input[name="serverId"]').length){
					$('#select-all').iCheck('check');
				}else {
					$('#select-all').iCheck('indeterminate');
				}
			});
			$('#serverTable tbody input[name="serverId"]').on('ifToggled', function(){
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
    }); */
	
});

//ftp 진단 파일 리스트 상세정보 화면으로 이동
function getFtpTotalView(ftpSeq, p_server_id, p_group_id, p_search_seq){
	 
	location.href="/filterftp.do?cmd=total_list_form&command=SELECT&ftp_seq="+ftpSeq+"&server_id="+p_server_id+"&group_id="+p_group_id+"&search_seq="+p_search_seq;
}

</script>


<c:set var="pageName">진단 파일 리스트</c:set>

<!-- Content Header (Page header) -->
<section class="content-header">
	<h1> <span></span><spring:message code="filterftp.total.list.title1" /><small><spring:message code="filterftp.total.list.title2" /></small> </h1>
	<ol class="breadcrumb">
		<li><a href="./"><i class="fa fa-home"></i><spring:message code="common.home"/></a></li>
		<li><a href="./filterftp.do?cmd=site_list&searchGroup=all"><spring:message code="common.file.diag"/></a></li>
		<li class="active"><spring:message code="filterftp.total.list.title1" /></li>
	</ol>
</section>
<!-- // Content Header (Page header) -->

<!-- Main content -->
<section class="content">
   <div class="row">
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
					<h3 class="box-title"><spring:message code="filterftp.site.title2" /></h3>
					<button type="button" class="btn btn-success btn-sm" id="btnGridRefresh" title="<spring:message code="common.reload"/>"><i class="fa fa-refresh" aria-hidden="true"></i></button>
				</div>
				<!-- // box-header -->
				
				<!-- box-body -->
				<div class="box-body">
				
					<!-- Search Input Area -->
					<div class="searchForm">
						<select class="form-control searchField" id="searchField" name="searchField">
							<option value="serverName"><spring:message code="filter.policy.servername" /></option>
							<option value="groupName"><spring:message code="settings.group_name" /></option>
							<option value="siteDomain"><spring:message code="filter.log.report.domain.name" /></option>
							<option value="ip"><spring:message code="filter.ip.address" /></option>
							<option value="searchStart"><spring:message code="common.diag.start" /></option>
							<option value="searchStop"><spring:message code="common.diag.finish" /></option>				
						</select>
						<div id='search_date_start' style="float:left; margin-left:10px; display:none;">
						    <div class='input-group date' id='start' style="width:150px;">
						        <input type='text' class="form-control" id='search_s_date' />
						        <span class="input-group-addon common_gray">
						            <i class="fa fa-calendar" aria-hidden="true"></i>
						        </span>
						    </div>
						</div>
						<div id='search_date_span' style="float:left; padding:0 10px; margin-top:7px; display:none;">~</div>
						<div id='search_date_end' style="float:left; margin:0 10px 0 0; display:none;">
						    <div class='input-group date' id='end' style="width:150px;">
						        <input type='text' class="form-control" id='search_e_date' />
						        <span class="input-group-addon common_gray">
						            <i class="fa fa-calendar" aria-hidden="true"></i>
						        </span>
						    </div>
					    </div>
					    <div id='search_input'>
							<input type="text" class="form-control SEARCHTEXT" id="searchValue" name="searchValue" style="width:200px;" />
						</div>
						<button class="btn btn-primary" type="button" id='btnSearch' style="vertical-align:baseline;">
							<i class="fa " aria-hidden="true"></i>
							<span><spring:message code="common.search"/></span>
						</button>
					</div>
				    <!-- // Search Input Area -->
				    
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
