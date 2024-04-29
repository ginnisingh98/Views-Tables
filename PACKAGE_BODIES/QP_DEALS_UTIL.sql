--------------------------------------------------------
--  DDL for Package Body QP_DEALS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEALS_UTIL" as
/* $Header: QPXUDLSB.pls 120.0.12010000.2 2008/11/05 12:09:57 bhuchand ship $ */

procedure debug_log(p_origin number, text varchar2)
is
begin
   if p_origin = 660 then
	oe_debug_pub.add(text);
   end if;
   if p_origin = 697 then
      aso_debug_pub.ADD (text);
   end if;
end;

PROCEDURE CALL_DEALS_API(
	    p_origin 	in NUMBER,
	    p_header_id 	in NUMBER,
	    p_updatable_flag 	IN varchar2,
	    x_redirect_function out nocopy varchar2,
	    x_is_deal_compliant out nocopy varchar2,
	    x_rules_desc 	out nocopy varchar2,
	    x_return_status 	out nocopy varchar2,
	    x_msg_data 		out nocopy varchar2,
	    x_is_curr_inst_deal_inst out nocopy varchar2)

IS
l_package 		VARCHAR2(30) := 'QPR_PRICE_NEGOTIATION_PUB';
l_procedure		VARCHAR2(30) := 'INITIATE_DEAL';
QPR_DEAL_WKB_URL varchar2(1000) := 'OA.jsp?page=/oracle/apps/qpr/planning/negotiation/webui/PNDetailsPG' || '&' ||
'OAHP=QPR_ANALYST_HOME' || '&' || 'OASF=QPR_DEAL_WORKBENCH' || '&' || 'OAPB=QPR_BRANDING_TEXT';
QPR_DEAL_NEGO_URL varchar2(1000) := 'OA.jsp?page=/oracle/apps/qpr/planning/negotiation/webui/PNWorkbenchPG' || '&' ||
'OAHP=QPR_ANALYST_HOME' || '&' || 'OASF=QPR_DEAL_NEGOTIATION' || '&' || 'OAPB=QPR_BRANDING_TEXT';
l_instance_id		NUMBER;
l_db_link		 varchar2(240);
l_dynamicSqlString	VARCHAR2(2000);
l_quote_origin NUMBER ;
l_usr_name varchar2(100);
l_resp_id number;
l_usr_id number;
l_appl_id number;
l_responsibility_name varchar2(100) := 'QPR_PRICING_ANALYST';
l_sql varchar2(1000);
l_pn_url varchar2(1000);
l_dummy number;
--
BEGIN
    l_quote_origin := p_origin;

    x_is_curr_inst_deal_inst := 'Y';

    l_instance_id	:= FND_PROFILE.VALUE('QPR_CURRENT_INSTANCE') ;
    l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

    --If Instance ID is NULL, QPR API will fail so DONT call.
    if l_instance_id is NULL THEN
      x_return_status :='E';
      x_is_deal_compliant := 'N';
      debug_log(p_origin, 'Profile: QPR:Instance Id of this Server is null');
      x_msg_data := fnd_message.get_string('QP','QP_QPR_INSTID_NULL_ERROR');
      return;
    end if;

-- This check is only required when deal instance and quote instance
-- are different

    if  l_db_link is NOT NULL THEN
        l_db_link := '@' || l_db_link;
        debug_log(p_origin, 'DBLink:' || l_db_link);

        l_pn_url := fnd_profile.value('QPR_PN_URL');

        if l_pn_url is null then
          x_return_status :='E';
          x_is_deal_compliant := 'N';
          debug_log(p_origin,'Profile QPR:Price Negotiation Web server is null');
          x_msg_data := fnd_message.get_string('QP','QP_QPR_PN_URL_NULL_ERROR');
          return;
        end if;
        begin
            debug_log(p_origin, 'Testing dblink...');
            l_sql := 'select 1 from dual' || l_db_link;
            execute immediate l_sql into l_dummy;
            debug_log(p_origin, 'Success!');
        exception
            when others then
              x_return_status := 'E';
              x_is_deal_compliant := 'N';
              debug_log(p_origin, 'Error connecting to remote instance');
              debug_log(p_origin, sqlerrm);
              x_msg_data := fnd_message.get_string('QP','QP_QPR_DBLINK_ERROR');
              return;
        end;

        x_is_curr_inst_deal_inst := 'N';
    end if;

    select user_name into l_usr_name
    from fnd_user_view
    where user_id = fnd_global.user_id;

    debug_log(p_origin,
      'Checking if user context is available in deal instance..');

    l_sql := 'begin :1 := fnd_global.user_id' || l_db_link || '; end;';

    execute immediate l_sql using out l_usr_id;

    debug_log(p_origin, 'Deal user id: ' || l_usr_id);

    if nvl(l_usr_id , -1) = -1 then
      debug_log(p_origin, 'Setting user context in deal instance for user '|| l_usr_name);
      begin
        l_sql := 'select user_id from fnd_user_view' || l_db_link
        || ' where user_name = :1' ;
        execute immediate l_sql into l_usr_id using l_usr_name ;

        l_sql := 'select application_id, responsibility_id from fnd_responsibility' || l_db_link;
        l_sql := l_sql || ' where responsibility_key = :1';

        execute immediate l_sql into l_appl_id, l_resp_id
        using l_responsibility_name ;

        l_sql := 'begin fnd_global.apps_initialize' || l_db_link ;
        l_sql := l_sql || '(:usr, :resp, :appl_id);end; ' ;

        execute immediate l_sql using in l_usr_id, l_resp_id, l_appl_id;
      exception
        when others then
          x_return_status := 'E';
          x_is_deal_compliant := 'N';
          debug_log(p_origin, 'Error setting user context in remote instance');
          debug_log(p_origin, sqlerrm);
          x_msg_data := fnd_message.get_string('QP','QP_QPR_USR_CTXT_ERROR');
          return;
      end;
    end if;

    begin
      debug_log(p_origin, 'Invoking deal creation method...');
      l_dynamicSqlString := ' begin ';
      l_dynamicSqlString := l_dynamicSqlString || l_package ||'.';
      l_dynamicSqlString := l_dynamicSqlString || l_procedure || l_db_link ;
      l_dynamicSqlString := l_dynamicSqlString || '( ';
      l_dynamicSqlString := l_dynamicSqlString || ':source_id, ';
      l_dynamicSqlString := l_dynamicSqlString || ':source_ref_id,';
      l_dynamicSqlString := l_dynamicSqlString || ':instance_id, ';
      l_dynamicSqlString := l_dynamicSqlString || ':updatable, ';
      -- OUT Parameters
      l_dynamicSqlString := l_dynamicSqlString || ':redirect_function, ';
      l_dynamicSqlString := l_dynamicSqlString || ':p_is_deal_compliant, ';
      l_dynamicSqlString := l_dynamicSqlString || ':p_rules_desc, ';
      l_dynamicSqlString := l_dynamicSqlString || ':x_return_status , ';
      l_dynamicSqlString := l_dynamicSqlString || ':x_mesg_data ); ';
      l_dynamicSqlString := l_dynamicSqlString || ' end; ';

      EXECUTE IMMEDIATE l_dynamicSqlString USING
                                                IN l_quote_origin,
                                                IN p_header_id,
                                                IN l_instance_id,
                                                IN p_updatable_flag,
                                                OUT x_redirect_function,
                                                OUT x_is_deal_compliant,
                                                OUT x_rules_desc,
                                                OUT x_return_status,
                                                OUT x_msg_data;
      if x_return_status = FND_API.G_RET_STS_SUCCESS then
--        if l_quote_origin = 697 then
--          commit;
--        end if;

-- If quote instance and deal instance are different then
-- to invoke deal page we return the entire url
-- else we send the function name.

        if l_pn_url is not null and l_db_link is not null then
          if substr(l_pn_url, -1, 1) <> '/' then
            l_pn_url := l_pn_url || '/';
          end if;
          if x_redirect_function = 'QPR_DEAL_WORKBENCH' then
            x_redirect_function := l_pn_url || QPR_DEAL_WKB_URL;
          elsif x_redirect_function = 'QPR_DEAL_NEGOTIATION' then
            x_redirect_function := l_pn_url || QPR_DEAL_NEGO_URL;
          end if;
        end if;
     end if;
    exception
      when others then
          x_return_status := 'E';
          x_is_deal_compliant := 'N';
          debug_log(p_origin, 'Error invoking /from deal creation method');
          debug_log(p_origin, sqlerrm);
          x_msg_data := fnd_message.get_string('QP','QP_QPR_DEAL_CREATE_ERROR');
          return;
    end;

EXCEPTION
	  when others then
	  	x_return_status :='E';
		  x_is_deal_compliant := 'N';
      debug_log(p_origin, 'Unexpected error');
      debug_log(p_origin, sqlerrm);
END CALL_DEALS_API;

END QP_DEALS_UTIL;

/
