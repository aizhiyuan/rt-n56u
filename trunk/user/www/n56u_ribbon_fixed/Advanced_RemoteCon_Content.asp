<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu7_1#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/client_function.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	init_itoggle('p2p_enable_x', change_p2p_enabled);
});

</script>
<script>

<% login_state_hook(); %>

var RuleList = [<% get_nvram_list("P2PConnection", "RuleList"); %>];

function initial(){
	var id_menu = 3;
	if(!support_ipv6())
		id_menu--;

	show_banner(2);
	show_menu(5,4,id_menu);
	show_footer();

	change_p2p_enabled();

	show_RuleList();
}

function applyRule(){
	showLoading();
	document.form.sid_list.value = "P2PConnection;"
	document.form.group_id.value = "RuleList";
	if (document.form.p2p_enable_x[0].checked)
		document.form.action_mode.value = " Restart ";
	else
		document.form.action_mode.value = " Apply ";
	document.form.next_page.value = "";
	document.form.submit();
}

function done_validating(action){
	if(action == " Add ")
		split_vts_rule();
	else
		refreshpage();
}

function change_p2p_enabled(){
	var v = document.form.p2p_enable_x[0].checked;
	showhide_div("P2PList_Block", v);
}

/* 路由处理 */
/* this, 64, ' Add ' */
function markGroupP2PVS(o, c, b) {
	var i, obj;
	document.form.sid_list.value = "P2PConnection;"
	document.form.group_id.value = "RuleList";
	
	if(b == " Add "){
		if (document.form.p2p_num_x_0.value >= c){
			alert("<#JS_itemlimit1#> " + c + " <#JS_itemlimit2#>");
			return false;
		}
		/*
		obj = document.form.p2p_gw_ip_x_0;
		if (obj.value!=""){
			obj = document.form.p2p_gw_ip_x_0;
			if(obj.value.split("*").length >= 2){
				if(!valid_IP_subnet(obj))
					return false;
			}else if(!validate_ipaddr_final(obj, ""))
				return false;
		}
		obj = document.form.p2p_local_ip_x_0;
		if (obj.value==""){
			alert("<#JS_fieldblank#>");
			obj.focus();
			return false;
		}else if (!validate_ipaddr_final(obj, "")){
			return false;
		}
		*/
	}
	pageChanged = 0;
	document.form.action_mode.value = b;
	return true;
}

var vts_rule_array = new Array();
var count = 0;
function split_vts_rule(s){
	var i;
	var count_dup = 0;
	if(typeof(s) !== "undefined"){
		this.vts_rule_array = s;
	}
	if(this.vts_rule_array.length <= 0){
		refreshpage();
		return;
	}
	else{
		document.form.vts_port_x_0.value = this.vts_rule_array[0];
		this.vts_rule_array.shift();
	}
	
	for(i=0; i< VSList.length; i++){
		if(entry_cmp(VSList[i][3].toLowerCase(), document.form.vts_proto_x_0.value.toLowerCase(), 5)==0){
			if(!(portrange_min(document.form.vts_port_x_0.value, 11) > portrange_max(VSList[i][0], 11) ||
				portrange_max(document.form.vts_port_x_0.value, 11) < portrange_min(VSList[i][0], 11))){
				count_dup = count_dup + 1;
			}
			if(entry_cmp(VSList[i][1], document.form.vts_ipaddr_x_0.value.toLowerCase(), 15)==0){
				if(document.form.vts_lport_x_0.value.length!=0){
					if(entry_cmp(VSList[i][2], "", 5)==0){
						if(!(portrange_min(document.form.vts_lport_x_0.value, 5) > portrange_max(VSList[i][0], 11) || portrange_max(document.form.vts_lport_x_0.value, 5) < portrange_min(VSList[i][0], 11))){
							count_dup = count_dup + 1;
						}
					}
					else{
						if(portrange_min(document.form.vts_lport_x_0.value,5) == portrange_min(VSList[i][2], 5)){
							count_dup = count_dup + 1;
						}
					}
				}
				else{
					if(entry_cmp(VSList[i][2], "", 5)==0){
						if(!(portrange_min(document.form.vts_port_x_0.value, 11) > portrange_max(VSList[i][0], 11) ||
							portrange_max(document.form.vts_port_x_0.value, 11) < portrange_min(VSList[i][0], 11))){
							count_dup = count_dup + 1;
						}
					}
					else{
						if(!(portrange_min(document.form.vts_port_x_0.value, 11) > portrange_min(VSList[i][2], 5) ||
							portrange_max(document.form.vts_port_x_0.value, 11) < portrange_min(VSList[i][2], 5))){
								count_dup = count_dup + 1;
						}
					}
				}
			}
		}
	}
	
	if (count_dup != "0"){
		alert('<#JS_duplicate#>');
		split_vts_rule();
	}
	else{
		document.form.action = "/start_apply.htm";
		document.form.target = "hidden_frame";
		document.form.action_mode.value = " Add ";
		document.form.current_page.value = "";
		document.form.next_page.value = "";
		document.form.submit();
	}
}

function show_RuleList(){
	var i;
	var code = '';
	var rule_name, gw_ip, local_ip, local_mask;
	if(RuleList.length == 0)
		code +='<tr><td colspan="7" style="text-align: center;"><div class="alert alert-info"><#P2PConnection_VSList_Norule#></div></td></tr>';
	else{
	    for(i = 0; i < RuleList.length; i++){
			rule_name = RuleList[i][0];	// 获取路由规则名称

		if (RuleList[i][1] != null && RuleList[i][1] != "") // 获取网关ip
		{
			gw_ip = RuleList[i][1];	
		}

		if (RuleList[i][2] != null && RuleList[i][2] != "") // 获取子网ip
		{
			local_ip = RuleList[i][2];	
		}

		if (RuleList[i][3] != null && RuleList[i][3] != "") // 获取子网掩码
		{
			local_mask = RuleList[i][3];	
		}
		
		code +='<tr id="p2prow' + i + '">';
		code +='<td width="20%">&nbsp;' + rule_name + '</td>';
		code +='<td width="25%">&nbsp;' + gw_ip + '</td>';
		code +='<td width="25%">&nbsp;' + local_ip + '</td>';
		code +='<td width="25%">&nbsp;' + local_mask + '</td>';
		code +='<td width="5%" style="text-align: center;"><input type="checkbox" name="RuleList_s" value="' + i + '" onClick="changeBgColor_p2p(this,' + i + ');" id="p2pcheck' + i + '"></td>';
		code +='</tr>';
	    }
		code += '<tr>';
		code += '<td colspan="6">&nbsp;</td>'
		code += '<td><button class="btn btn-danger" type="submit" onclick="markGroupP2PVS(this, 64,\' Del \');" name="RuleList"><i class="icon icon-minus icon-white"></i></button></td>';
		code += '</tr>'
	}
	$j('#P2PVSList_Block').append(code);
}

function changeBgColor_p2p(obj, num){
	$("p2prow" + num).style.background=(obj.checked)?'#D9EDF7':'whiteSmoke';
}

function valid_IP_subnet(obj){
	var ipPattern1 = new RegExp("(^([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.(\\*)$)", "gi");
	var ipPattern2 = new RegExp("(^([0-9]{1,3})\\.([0-9]{1,3})\\.(\\*)\\.(\\*)$)", "gi");
	var ipPattern3 = new RegExp("(^([0-9]{1,3})\\.(\\*)\\.(\\*)\\.(\\*)$)", "gi");
	var ipPattern4 = new RegExp("(^(\\*)\\.(\\*)\\.(\\*)\\.(\\*)$)", "gi");
	var parts = obj.value.split(".");
	if(!ipPattern1.test(obj.value) && !ipPattern2.test(obj.value) && !ipPattern3.test(obj.value) && !ipPattern4.test(obj.value)){
		alert(obj.value + " <#JS_validip#>");
		obj.focus();
		obj.select();
		return false;
	}else if(parts[0] == 0 || parts[0] > 255 || parts[1] > 255 || parts[2] > 255){
		alert(obj.value + " <#JS_validip#>");
		obj.focus();
		obj.select();
		return false;
	}else
		return true;
}

</script>
<style>
.table-list td {
    padding: 6px 4px;
}
.table-list input,
.table-list select {
    margin-top: 0px;
    margin-bottom: 0px;
}
.table-list tr:nth-child(2) {
    font-size: 75%;
    font-weight: bold;
}
</style>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

    <form method="post" name="form" action="/start_apply.htm" target="hidden_frame" >
    <input type="hidden" name="current_page" value="Advanced_RemoteCon_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="P2PConnection;">
    <input type="hidden" name="group_id" value="RuleList">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu7#> - <#menu7_1#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;"><#P2PConnection_Remote_Network_Setting#></div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#P2PConnection_Remote_Network_Manual#></th>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#P2PConnection_P2PEnable_itemname#>
                                                <input type="hidden" name="p2p_num_x_0" value="<% nvram_get_x("P2PConnection", "p2p_num_x"); %>" readonly="1" />
                                            </th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="p2p_enable_x_on_of">
                                                        <input type="checkbox" id="p2p_enable_x_fake" <% nvram_match_x("", "p2p_enable_x", "1", "value=1 checked"); %><% nvram_match_x("", "p2p_enable_x", "0", "value=0"); %> />
                                                    </div>
                                                </div>

                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="p2p_enable_x" id="p2p_enable_x_1" onclick="change_p2p_enabled();" <% nvram_match_x("", "p2p_enable_x", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="p2p_enable_x" id="p2p_enable_x_0" onclick="change_p2p_enabled();" <% nvram_match_x("", "p2p_enable_x", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

									<!-- 路由设置 -->
									<table width="100%" cellpadding="4" cellspacing="0" class="table table-list" id="P2PVSList_Block">
                                        <tr>
                                            <td width="20%"><#P2PConnection_VSListInfo_RemoteSiteName#></td>
                                            <td width="25%"><#P2PConnection_VSListInfo_RemoteTapIP#></td>
                                            <td width="25%"><#P2PConnection_VSListInfo_RemoteLANIP#></td>
                                            <td width="25%"><#P2PConnection_VSListInfo_RemoteLANMask#></td>
                                            <td width="5%">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type="text" size="10" class="span12" maxlength="30" name="p2p_route_rule_name_0" value="<% nvram_get_x("", "p2p_route_rule_name_0"); %>" onkeypress="return is_string(this,event);" />
                                            </td>
                                            <td>
                                                <input type="text" size="12" class="span12" maxlength="15" name="p2p_gw_ip_x_0" value="<% nvram_get_x("", "p2p_gw_ip_x_0"); %>" onKeyPress="return is_iprange(this,event);"/>
                                            </td>
											<td>
                                                <input type="text" size="12" class="span12" maxlength="15" name="p2p_local_ip_x_0" value="<% nvram_get_x("", "p2p_local_ip_x_0"); %>" onKeyPress="return is_iprange(this,event);"/>
                                            </td>
											<td>
                                                <input type="text" size="12" class="span12" maxlength="15" name="p2p_local_mask_x_0" value="<% nvram_get_x("", "p2p_local_mask_x_0"); %>" onKeyPress="return is_iprange(this,event);"/>
                                            </td>
                                            <td>
                                                <button class="btn" type="submit" onclick="return markGroupP2PVS(this, 64, ' Add ');" name="RuleList"><i class="icon icon-plus"></i></button>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td style="border: 0 none;"><center><input name="button" type="button" class="btn btn-primary" style="width: 219px" onclick="applyRule();" value="<#CTL_apply#>"/></center></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                 </div>
            </div>
        </div>
    </div>

    </form>

    <div id="footer"></div>
</div>
</body>
</html>
