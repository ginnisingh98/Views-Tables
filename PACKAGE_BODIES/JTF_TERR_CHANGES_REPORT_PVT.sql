--------------------------------------------------------
--  DDL for Package Body JTF_TERR_CHANGES_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_CHANGES_REPORT_PVT" AS
/* $Header: jtftrrcb.pls 120.0 2005/06/02 18:21:47 appldev ship $ */

 PROCEDURE report_wrapper
    ( p_response IN varchar2,
      --p_manager  in varchar2,
      p_sd_date  IN varchar2,
      p_sm_date  IN varchar2,
      p_sy_date  IN varchar2,
      p_ed_date  IN varchar2,
      p_em_date  IN varchar2,
      p_ey_date  IN varchar2)
    IS

    --g_image_prefix  varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
    l_response      varchar2(2000);
    l_agent         varchar2(2000);
    p_orderby       varchar2(2000);
    cid             INTEGER;
    v_sql_st        varchar2(2000);

    v_date          date;
    v_cost_center   varchar2(10);
    v_name          varchar2(2000);
    v_email         varchar2(2000);
    v_count         varchar2(2000);
     -- DBMS_
    rows_processed  number;
    l_from_date date;
    l_to_date date;
    v_temp          varchar2(2000);
    p_select        varchar2(2000);
    p_from          varchar2(2000);
    p_where         varchar2(2000);
    p_groupby       varchar2(2000);
    p_count         number := 0;
    l_rec_count     number;


    l_display_type varchar2(100);
    l_convert_to_id_flag varchar2(1);


    -- cursor to get territory records
    cursor cur_territory(c_from_date date, c_to_date date) is
        select terr_id,  wf_notification.substitutespecialchars(name) name,
               wf_notification.substitutespecialchars(terr_type_name) terr_type_name, rank,
               trunc(creation_date) creation_date, trunc(last_update_date) last_update_date
        from jtf_terr_overview_v
        where last_update_date >= c_from_date  --'01-OCT-2001'
            and last_update_date <= c_to_date;  --'11-JUN-1997'
/*    -- cursor to get salesreps DEVELOPMENT
    CURSOR c_get_salesrep(ci_terr_id NUMBER) IS
        select resource_id, resource_id || ': Rsc Name Not Available' resource_name
        from jtf_terr_rsc where terr_id = ci_terr_id;
*/
    -- cursor to get salesreps DELIVERY
    CURSOR c_get_salesrep(ci_terr_id NUMBER) IS
        select distinct resource_id, wf_notification.substitutespecialchars(resource_name) resource_name
        from jtf_terr_resources_v jtrv
        where jtrv.terr_id = ci_terr_id
        order by resource_name;

    -- cursor to get dynamic qualifiers
    CURSOR c_get_terr_qual (p_template_terr_id NUMBER) IS
        SELECT  distinct TERR_QUAL_ID,
                TERR_ID,
                QUAL_USG_ID,
                ORG_ID,
                wf_notification.substitutespecialchars(qualifier_name) qualifier_name
        FROM    jtf_terr_qualifiers_v
        WHERE   terr_id = p_template_terr_id;
    -- cursor to get values for dynamic qualifier values
    CURSOR c_get_terr_values (p_terr_qual_id NUMBER) IS
        SELECT j1.TERR_VALUE_ID
            , wf_notification.substitutespecialchars(j1.COMPARISON_OPERATOR) COMPARISON_OPERATOR
            , wf_notification.substitutespecialchars(j1.LOW_VALUE_CHAR_DESC) LOW_VALUE_CHAR_DESC
            , wf_notification.substitutespecialchars(j1.HIGH_VALUE_CHAR_DESC) HIGH_VALUE_CHAR_DESC
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , wf_notification.substitutespecialchars(j1.INTEREST_TYPE) INTEREST_TYPE
            , wf_notification.substitutespecialchars(j1.PRIMARY_INTEREST_CODE) PRIMARY_INTEREST_CODE
            , wf_notification.substitutespecialchars(j1.SECONDARY_INTEREST_CODE) SECONDARY_INTEREST_CODE
            , wf_notification.substitutespecialchars(j1.CURRENCY_CODE) CURRENCY_CODE
            , j1.LOW_VALUE_CHAR_ID
            , wf_notification.substitutespecialchars(DISPLAY_TYPE) DISPLAY_TYPE
            , wf_notification.substitutespecialchars(CONVERT_TO_ID_FLAG) CONVERT_TO_ID_FLAG
        FROM   jtf_terr_values_desc_v j1
        WHERE  j1.terr_qual_id = p_terr_qual_id
        ORDER BY j1.value_set;

    BEGIN
        fnd_client_info.set_org_context(fnd_profile.value('ORG_ID'));
        l_response := p_response;

        select trunc(to_date(p_sd_date||'-'||p_sm_date||'-'||p_sy_date,'DD/MM/YYYY'))
        into l_from_date
        from dual;
        select trunc(to_date(p_ed_date||'-'||p_em_date||'-'||p_ey_date,'DD/MM/YYYY'))
        into l_to_date
        from dual;

        /*
        htp.p(l_from_date);
        htp.br;
        htp.p(l_to_date);
        htp.br;
        */

        if (icx_sec.validateSession(c_function_code => 'JTF_TERR_CHGS_RPT', c_validate_only => 'Y')) then
            if l_response = 'Excel' then
                  xls(l_from_date,l_to_date);
            else
                --dbms_session.set_sql_trace(TRUE);
                l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
                htp.htmlopen;
                htp.headOpen;
                htp.title('Territory Changes Report');
                htp.headClose;
                htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
                /*htp.formOpen( curl => l_agent||'/'||'as_ofl_terr_changes_report.xls', cmethod => 'POST', cattributes => ' name="excel"');
                --htp.formHidden( cname => 'p_manager', cvalue => p_manager);
                htp.formHidden( cname => 'l_from_date', cvalue => l_from_date);
                htp.formHidden( cname => 'l_to_date', cvalue => l_to_date);
                htp.formClose;
                */
                htp.p('<CENTER>');
                htp.tableOpen('border="0"  ');
                htp.tableRowOpen( calign => 'TOP' );
                --htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
                htp.tableData( '<FONT size=+1 face="times new roman">' || 'Territory Changes Report', cnowrap => 'TRUE');
                --htp.tabledata(htf.anchor('JavaScript:document.excel.submit();',htf.img(curl=>g_image_prefix||'up_excel.gif')),calign=>'Right',cattributes=>'width="100%"');
                htp.tableRowClose;
                htp.tableClose;
                htp.br;


            htp.tableOpen (cattributes => 'COLS=4 border="1" width="100%"');
            fnd_client_info.set_org_context(fnd_profile.value_wnps('ORG_ID'));
            -- display territories
            l_rec_count := 0;
            FOR rec_terr in cur_territory(l_from_date, l_to_date) loop
                htp.tableRowOpen;
                htp.p('<TR NOWRAP bgcolor="#999999" >');
                htp.p('<th colspan="1" width="30%" align="center">');
                htp.p(rec_terr.name);
                htp.p('</th>');
                htp.p('<th colspan="1" width="20%" align="center">');
                htp.p('Rank: ' ||rec_terr.rank);
                htp.p('</th>');
                htp.p('<th colspan="1" width="20%" align="center">');
                htp.p('Type: ' ||rec_terr.terr_type_name);
                htp.p('</th>');
                htp.p('<th colspan="1" width="20%" align="center">');
                htp.p('Created: ' ||rec_terr.creation_date);
                htp.p('Updated: ' ||rec_terr.last_update_date);
                htp.p('</th>');
                htp.tableRowClose;
                l_rec_count := l_rec_count + 1;

                -- display sales reps
                FOR rec_get_salesrep in c_get_salesrep(rec_terr.terr_id) loop
                    htp.tableRowOpen;
                    htp.p('<td colspan="2" width="50%" align="left"><bold>');
                    htp.p(rec_get_salesrep.resource_name);
                    htp.p('</bold></td>');
                    --htp.p('<td colspan="2" width="50%" align="left">');
                    --htp.p(rec_get_salesrep.resource_id);
                    --htp.p('</td>');
                    --htp.tableRowClose;
                END LOOP;
                -- display qualifiers
                FOR rec_get_terr_qual in c_get_terr_qual(rec_terr.terr_id) loop
                    htp.tableRowOpen;
                    htp.p('<TR NOWRAP bgcolor="#999999" >');
                    htp.p('<td colspan="2" align="center" width="50%">');
                    htp.p(rec_get_terr_qual.qualifier_name);
                    htp.p('</td>');
                    --htp.p('<td colspan="2" align="center" width="50%">');
                    --htp.p('Terr_qual_id: ' ||rec_get_terr_qual.terr_qual_id);
                    --htp.p('</td>');
                    htp.tableRowClose;
                    -- display qualifier values
                    FOR rec_get_terr_values in c_get_terr_values(rec_get_terr_qual.terr_qual_id) loop
                        -- output qualifier values according to display_type and convert_to_id_flag
                        l_display_type := rec_get_terr_values.display_type;
                        l_convert_to_id_flag := rec_get_terr_values.convert_to_id_flag;

                        If (l_display_type = 'CHAR') then
                            If (l_convert_to_id_flag = 'Y') then
                                htp.tableRowOpen;
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.comparison_operator);
                                htp.p('</bold></td>');
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.low_value_char_desc);
                                htp.p('</bold></td>');
                                htp.p('<td align="left">');
                                htp.p(rec_get_terr_values.low_value_char_id);
                                htp.p('</td>');
                                htp.p('<td align="left"><bold>');
                                htp.p('');
                                htp.p('</bold></td>');
                                htp.tableRowClose;
                             else -- (l_convert_to_id_flag = 'N')
                                htp.tableRowOpen;
                                htp.p('<td align="left"><bold>');
                                    htp.p(rec_get_terr_values.comparison_operator);
                                htp.p('</bold></td>');
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.low_value_char_desc);
                                htp.p('</bold></td>');
                                htp.p('<td align="left">');
                                htp.p(rec_get_terr_values.high_value_char_desc);
                                htp.p('</td>');
                                htp.p('<td align="left"><bold>');
                                htp.p('');
                                htp.p('</bold></td>');
                                htp.tableRowClose;
                            End if;
                        elsif (l_display_type = 'INTEREST_TYPE') then
                            htp.tableRowOpen;
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.comparison_operator);
                            htp.p('</bold></td>');
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.interest_type);
                            htp.p('</bold></td>');
                            htp.p('<td align="left">');
                            htp.p(rec_get_terr_values.primary_interest_code);
                            htp.p('</td>');
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.secondary_interest_code);
                            htp.p('</bold></td>');
                            htp.tableRowClose;
                        elsif (l_display_type = 'NUMBER') then
                            htp.tableRowOpen;
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.comparison_operator);
                            htp.p('</bold></td>');
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.low_value_number);
                            htp.p('</bold></td>');
                            htp.p('<td align="left">');
                            htp.p(rec_get_terr_values.high_value_number);
                            htp.p('</td>');
                            htp.p('<td align="left"><bold>');
                            htp.p('');
                            htp.p('</bold></td>');
                            htp.tableRowClose;
                        elsif (l_display_type = 'CURRENCY') then
                            htp.tableRowOpen;
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.comparison_operator);
                            htp.p('</bold></td>');
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.low_value_number);
                            htp.p('</bold></td>');
                            htp.p('<td align="left">');
                            htp.p(rec_get_terr_values.high_value_number);
                            htp.p('</td>');
                            htp.p('<td align="left"><bold>');
                            htp.p(rec_get_terr_values.currency_code);
                            htp.p('</bold></td>');
                            htp.tableRowClose;
                        else
                            htp.tableRowOpen;
                            htp.p('<td colspan="4" align="left"><bold>');
                            htp.p('NO DATA DISPLAYED');
                            htp.p('</bold></td>');
                            htp.tableRowClose;
                        end if;
                    END LOOP;
                END LOOP;
            END LOOP;
            If l_rec_count = 0 then
                htp.p('No territories meet search criteria.');
            End if;

           htp.tableClose;

                /*
                htp.tableOpen (cattributes => 'border="1" width="100%"');
                htp.tableRowOpen;
                htp.p('<TR NOWRAP bgcolor="#999999" >');
                htp.p('<th NOWRAP align="CENTER" width="30%" valign="top">Territory Name</th>');
                htp.p('<th NOWRAP align="CENTER" width="15%" valign="top">SalesRep</th>');
                --htp.p('<th NOWRAP align="CENTER" width="10%" valign="top">Group Name</th>');
                htp.p('<th NOWRAP align="CENTER" width="5%" valign="top">Territory Type</th>');
                htp.p('<th NOWRAP align="CENTER" width="10%" valign="top">Qualifier Name</th>');
                htp.p('<th NOWRAP align="CENTER" width="10%" valign="top">Value1</th>');
                htp.p('<th NOWRAP align="CENTER" width="10%" valign="top">Value2</th>');
                htp.p('<th NOWRAP align="CENTER" width="10%" valign="top">Created/Updates</th>');
                htp.tableRowClose;
                -- display territories
                for  rec_territory in cur_territory(l_from_date, l_to_date) loop
                    htp.tableRowOpen;
                    htp.p('<td align="center">');
                    htp.p(rec_territory.name||'/' ||rec_territory.terr_id || ' - ' || rec_territory.last_update_date);
                    htp.p('</td>');
                    htp.br;
                    htp.tableRowClose;
                end loop;

                --  DBMS_SQL.CLOSE_CURSOR(cid);
                htp.tableClose;
                */
                htp.Br;
                --  htp.p(p_count - 1||' records found');
                htp.bodyClose;
                htp.htmlClose;
            end if;
        else
            htp.p('Invalid session');
        end if;
        -- dbms_session.set_sql_trace(FALSE);

    EXCEPTION
      when no_data_found then
	   htp.print('Territory Changes Report: No Data Found!!!');
      when others then
	   htp.print('report_wrapper: ' || substr(SQLERRM, 1,200));
    END;

 ----------------------------------------------------------------------------------------------------------------------
  PROCEDURE XLS (
    l_from_date date,
    l_to_date date)

    IS

    v_tab          varchar2(1);
    v_tabrow       varchar2(32747);

    l_display_type varchar2(100);
    l_convert_to_id_flag varchar2(1);
    h1_divider      varchar2(100) := '****************************************';
    h2_divider      varchar2(100) := '===================';
    h3_divider      varchar2(100) := '-------------------';
    l_counter       number;
    l_counter2       number;
    l_rec_count     number;



    -- cursor to get territory records
    cursor cur_territory(c_from_date date, c_to_date date) is
        select terr_id, wf_notification.substitutespecialchars(name) name,
               wf_notification.substitutespecialchars(terr_type_name) terr_type_name, rank,
               trunc(creation_date) creation_date, trunc(last_update_date) last_update_date
        from jtf_terr_overview_v
        where last_update_date >= c_from_date  --'01-OCT-2001'
            and last_update_date <= c_to_date;  --'11-JUN-1997'

    -- cursor to get salesreps DELIVERY
    CURSOR c_get_salesrep(ci_terr_id NUMBER) IS
        select distinct resource_id, wf_notification.substitutespecialchars(resource_name) resource_name
        from jtf_terr_resources_v jtrv
        where jtrv.terr_id = ci_terr_id
        order by resource_name;
    -- cursor to get dynamic qualifiers
    CURSOR c_get_terr_qual (p_template_terr_id NUMBER) IS
        SELECT  distinct TERR_QUAL_ID,
                TERR_ID,
                QUAL_USG_ID,
                ORG_ID,
                wf_notification.substitutespecialchars(qualifier_name) qualifier_name
        FROM    jtf_terr_qualifiers_v
        WHERE   terr_id = p_template_terr_id;
    -- cursor to get values for dynamic qualifier values
    CURSOR c_get_terr_values (p_terr_qual_id NUMBER) IS
        SELECT j1.TERR_VALUE_ID
            , wf_notification.substitutespecialchars(j1.COMPARISON_OPERATOR) COMPARISON_OPERATOR
            , wf_notification.substitutespecialchars(j1.LOW_VALUE_CHAR_DESC) LOW_VALUE_CHAR_DESC
            , wf_notification.substitutespecialchars(j1.HIGH_VALUE_CHAR_DESC) HIGH_VALUE_CHAR_DESC
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , wf_notification.substitutespecialchars(j1.INTEREST_TYPE) INTEREST_TYPE
            , wf_notification.substitutespecialchars(j1.PRIMARY_INTEREST_CODE) PRIMARY_INTEREST_CODE
            , wf_notification.substitutespecialchars(j1.SECONDARY_INTEREST_CODE) SECONDARY_INTEREST_CODE
            , wf_notification.substitutespecialchars(j1.CURRENCY_CODE) CURRENCY_CODE
            , j1.LOW_VALUE_CHAR_ID
            , wf_notification.substitutespecialchars(DISPLAY_TYPE) DISPLAY_TYPE
            , wf_notification.substitutespecialchars(CONVERT_TO_ID_FLAG) CONVERT_TO_ID_FLAG
        FROM   jtf_terr_values_desc_v j1
        WHERE  j1.terr_qual_id = p_terr_qual_id
        ORDER BY j1.value_set;

    BEGIN
        owa_util.mime_header('application/excel');
        fnd_client_info.set_org_context(fnd_profile.value('ORG_ID'));

        --  fnd_client_info.set_org_context(fnd_profile.value_wnps('ORG_ID'));
        SELECT FND_GLOBAL.TAB
        INTO v_tab
        from dual;

        --htp.p(v_tabrow);
        v_tabrow := null;
    -- display territories
    l_rec_count := 0;

    FOR rec_terr in cur_territory(l_from_date, l_to_date)  loop
        /*
        if cur_territory%rowcount > 1 then
            v_tabrow := v_tabrow||' '||v_tab;
            htp.p(v_tabrow);
            htp.p(v_tabrow);
            v_tabrow := null;
        end if;
        */
        v_tabrow := null;
        htp.p(v_tabrow); -- add a blank before each territory
        v_tabrow := null;
        v_tabrow := v_tabrow||rec_terr.name||v_tab;
        v_tabrow := v_tabrow||'Rank: '||rec_terr.rank||v_tab;
        v_tabrow := v_tabrow||'Type: '||rec_terr.terr_type_name||v_tab;
        v_tabrow := v_tabrow||'Created: '||rec_terr.creation_date||' Updated: '||rec_terr.last_update_date||v_tab;
        htp.p(v_tabrow);  -- print out prepared line
        v_tabrow := null;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        htp.p(v_tabrow);  -- divider since we dont' know how to format rows in XLS
        -- display sales reps
            l_counter2 := 0;
        FOR rec_get_salesrep in c_get_salesrep(rec_terr.terr_id) loop
            l_counter2 := l_counter2 + 1;
            v_tabrow := null;
            v_tabrow := v_tabrow||rec_get_salesrep.resource_name||v_tab;
            --v_tabrow := v_tabrow||rec_get_salesrep.resource_name||'l_counter2: '||l_counter2||v_tab;
            --v_tabrow := v_tabrow||rec_get_salesrep.resource_id||v_tab;
            htp.p(v_tabrow);
        END LOOP;
            v_tabrow := null;
            v_tabrow := v_tabrow||h2_divider||v_tab;
            htp.p(v_tabrow);
        -- display qualifiers
        FOR rec_get_terr_qual in c_get_terr_qual(rec_terr.terr_id) loop
            v_tabrow := null;
            htp.p(v_tabrow); -- put in a CR before each qualifier
            v_tabrow := null;
            v_tabrow := v_tabrow||rec_get_terr_qual.qualifier_name||v_tab;
            --v_tabrow := v_tabrow||rec_get_terr_qual.terr_qual_id||v_tab;
            htp.p(v_tabrow);
            v_tabrow := null;
            v_tabrow := v_tabrow||h3_divider||v_tab;
            htp.p(v_tabrow);

            -- display qualifier values
            l_counter := 0;
            FOR rec_get_terr_values in c_get_terr_values(rec_get_terr_qual.terr_qual_id) loop
                -- output qualifier values according to display_type and convert_to_id_flag
                l_display_type := rec_get_terr_values.display_type;
                l_convert_to_id_flag := rec_get_terr_values.convert_to_id_flag;
                l_counter := l_counter + 1;
                If (l_display_type = 'CHAR') then
                    If (l_convert_to_id_flag = 'Y') then
                        v_tabrow := null;
                        v_tabrow := v_tabrow||rec_get_terr_values.comparison_operator||v_tab;
                        v_tabrow := v_tabrow||rec_get_terr_values.low_value_char_desc||v_tab;
                        --v_tabrow := v_tabrow||rec_get_terr_values.low_value_char_id|| 'CHAR_Y l_counter:'||l_counter|| v_tab;
                        v_tabrow := v_tabrow||rec_get_terr_values.low_value_char_id||v_tab;
                        htp.p(v_tabrow);
                    else -- (l_convert_to_id_flag = 'N')
                        v_tabrow := null;
                        v_tabrow := v_tabrow||rec_get_terr_values.comparison_operator||v_tab;
                        v_tabrow := v_tabrow||rec_get_terr_values.low_value_char_desc||v_tab;
                        --v_tabrow := v_tabrow||rec_get_terr_values.high_value_char_desc|| 'CHAR_N l_counter:'||l_counter|| v_tab;
                        v_tabrow := v_tabrow||rec_get_terr_values.high_value_char_desc||v_tab;
                        htp.p(v_tabrow);
                    End if;
                elsif (l_display_type = 'INTEREST_TYPE') then
                    v_tabrow := null;
                    v_tabrow := v_tabrow||rec_get_terr_values.comparison_operator||v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.interest_type||v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.primary_interest_code||v_tab;
                    --v_tabrow := v_tabrow||rec_get_terr_values.secondary_interest_code|| 'INT_T l_counter:'||l_counter|| v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.secondary_interest_code||v_tab;
                    htp.p(v_tabrow);
                elsif (l_display_type = 'NUMBER') then
                    v_tabrow := null;
                    v_tabrow := v_tabrow||rec_get_terr_values.comparison_operator||v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.low_value_number||v_tab;
                    --v_tabrow := v_tabrow||rec_get_terr_values.high_value_number|| 'NUM l_counter:'||l_counter|| v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.high_value_number||v_tab;
                    htp.p(v_tabrow);
                elsif (l_display_type = 'CURRENCY') then
                    v_tabrow := null;
                    v_tabrow := v_tabrow||rec_get_terr_values.comparison_operator||v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.low_value_number||v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.high_value_number||v_tab;
                    --v_tabrow := v_tabrow||rec_get_terr_values.currency_code|| 'CUR l_counter:'||l_counter|| v_tab;
                    v_tabrow := v_tabrow||rec_get_terr_values.currency_code||v_tab;
                    htp.p(v_tabrow);
                else
                    v_tabrow := null;
                    v_tabrow := v_tabrow||'NO DATA DISPLAYED'||v_tab;
                    htp.p(v_tabrow);
                end if;
            END LOOP;
        END LOOP;
    END LOOP;
    If l_rec_count = 0 then
        v_tabrow := null;
        v_tabrow := v_tabrow||'No territories meet search criteria.'||v_tab;
        htp.p(v_tabrow);
    End if;


    exception
    when no_data_found then
        htp.print('Territory Changes excel: No Data Found!!!');
	when others then
        htp.print('Territory Changes excel: '||substr(SQLERRM, 1,200));
  END XLS;


END;

/
