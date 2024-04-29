--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DEFINITION_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DEFINITION_REPORT_PVT" AS
/* $Header: jtftrrdb.pls 120.0 2005/06/02 18:21:49 appldev ship $ */

/*----------------------------------------------------------------
PROCEDURE report_wrapper
----------------------------------------------------------------*/

PROCEDURE report_wrapper
    ( p_response IN varchar2,
      p_srp      IN number, -- our resource_id
      --p_usg      IN number,
      p_qual     in number) -- our qual_usg_id
    IS
    g_image_prefix  varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
    l_response      varchar2(2000);
    l_srp           number;
    --l_sgrp          number;
    l_usg           number;
    l_qual          number;
    l_usg_name      varchar2(250);
    l_ziplo         varchar2(2000);
    l_ziphi         varchar2(2000);
    l_agent         varchar2(2000);
    l_rec_count     number;

    l_display_type varchar2(100);
    l_convert_to_id_flag varchar2(1);

    p_territory_id       NUMBER;
    p_territory_type_id  NUMBER;

    -- cursor of result territory searches with resource and qualifier restrictions
    CURSOR cur_terr is
        select j.terr_id,  wf_notification.substitutespecialchars(j.name) name, j.rank
        from jtf_terr j
        where NVL(j.end_date_active, sysdate) >= sysdate
          AND j.start_date_active <= sysdate
          AND EXISTS
            ( select jtr.terr_id
              from jtf_terr_rsc jtr, jtf_terr_qual jtq --, jtf_terr_usgs jtu
              where jtr.terr_id = jtq.terr_id
                    and jtr.resource_id = decode(l_srp,-1,jtr.resource_id,l_srp)
                    and jtq.qual_usg_id = decode(l_qual, -1, jtq.qual_usg_id, l_qual)
                    --and jtu.source_id = decode(l_usg, -1, jtu.source_id, l_usg)
                    AND jtr.terr_id = j.terr_id
            );

    -- cursor to get salesreps DELIVERY
    CURSOR c_get_salesrep(ci_terr_id NUMBER) IS
        select distinct resource_id,  wf_notification.substitutespecialchars(resource_name) resource_name
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
            , wf_notification.substitutespecialchars(j1.CNR_GROUP_NAME) CNR_GROUP_NAME
            , wf_notification.substitutespecialchars(DISPLAY_TYPE) DISPLAY_TYPE
            , wf_notification.substitutespecialchars(CONVERT_TO_ID_FLAG) CONVERT_TO_ID_FLAG
            --bug#3175772
            , VALUE1_ID
            , wf_notification.substitutespecialchars(VALUE1_DESC) VALUE1_DESC
            , VALUE2_ID
            , wf_notification.substitutespecialchars(VALUE2_DESC) VALUE2_DESC
            , VALUE3_ID
            , wf_notification.substitutespecialchars(VALUE3_DESC) VALUE3_DESC
      FROM   jtf_terr_values_desc_v j1
      WHERE  j1.terr_qual_id = p_terr_qual_id
      ORDER BY j1.LOW_VALUE_CHAR_DESC, j1.COMPARISON_OPERATOR;

BEGIN

   l_srp     := p_srp;
   l_qual    := p_qual;
   --l_usg     := p_usg;
   l_response := p_response;
   fnd_client_info.set_org_context(fnd_profile.value('ORG_ID'));

    if (icx_sec.validateSession(c_function_code => 'JTF_TERR_DFN_RPT', c_validate_only => 'Y')) then

        if l_response = 'Excel' then
            xls(l_srp,
               l_qual);
        else
            l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
            htp.htmlopen;
            htp.headOpen;
            htp.title('Territory Definitions');

            htp.headClose;
            htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
            htp.formOpen( curl => l_agent||'/'||'jtf_terr_definition_report.xls', cmethod => 'POST', cattributes => ' name="excel"');
            htp.formHidden( cname => 'p_srp', cvalue => l_srp);
            --htp.formHidden( cname => 'p_sgrp', cvalue => l_sgrp);
            htp.formHidden( cname => 'p_qual', cvalue => l_qual);
            htp.formClose;

            htp.p('<CENTER>');
            htp.tableOpen('border="0"  ');
            htp.tableRowOpen( calign => 'TOP' );
            --htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
            htp.tableData( '<FONT size=+1 face="times new roman">' || 'Territory Definitions Report', cnowrap => 'TRUE');
            --htp.tabledata(htf.anchor('JavaScript:document.excel.submit();',htf.img(curl=>g_image_prefix||'up_excel.gif')),calign=>'Right',cattributes=>'width="100%"');
            htp.tableRowClose;
            /*
            htp.tableRowOpen( calign => 'TOP' );
            htp.tableData('Usage: ' ||l_usg_name);
            htp.tableRowClose;
            */
            htp.tableClose;
            htp.br;

            htp.tableOpen (cattributes => 'COLS=4 border="1" width="100%"');
            fnd_client_info.set_org_context(fnd_profile.value_wnps('ORG_ID'));
            -- display territories
            l_rec_count := 0;
            FOR rec_terr in cur_terr loop
                htp.tableRowOpen;
                htp.p('<TR NOWRAP bgcolor="#999999" >');
                htp.p('<th colspan="2" width="50%" align="center">');
                htp.p(rec_terr.name);
                htp.p('</th>');
                htp.p('<th colspan="2" width="50%" align="center">');
                htp.p('Rank: ' ||rec_terr.rank);
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
                    if rec_get_terr_qual.qual_usg_id = -1012 then
                        htp.p('<td align="center">');
                        htp.p('');
                        htp.p('</td>');
                        htp.p('<td align="center">');
                        htp.p('Customer Name Range Group');
                        htp.p('</td>');
                    end if;
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
                                htp.p(rec_get_terr_values.CNR_GROUP_NAME);
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
                       -- bug#3175772
                        elsif (l_display_type = 'DEP_2FIELDS_CHAR_2IDS') then
                            If (l_convert_to_id_flag = 'Y') then
                                htp.tableRowOpen;
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.comparison_operator);
                                htp.p('</bold></td>');
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.value1_desc );
                                htp.p('</bold></td>');
                                htp.p('<td align="left">');
                                htp.p(rec_get_terr_values.value1_id);
                                htp.p('</td>');
                                htp.p('<td align="left"><bold>');
                                htp.p('');
                                htp.p('</bold></td>');
                                htp.tableRowClose;
                                if rec_get_terr_values.value2_id is not null
                                then
                                htp.tableRowOpen;
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.comparison_operator);
                                htp.p('</bold></td>');
                                htp.p('<td align="left"><bold>');
                                htp.p(rec_get_terr_values.value2_desc );
                                htp.p('</bold></td>');
                                htp.p('<td align="left">');
                                htp.p(rec_get_terr_values.value2_id);
                                htp.p('</td>');
                                htp.p('<td align="left"><bold>');
                                htp.p('');
                                htp.p('</bold></td>');
                                htp.tableRowClose;
                                end if;

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
                                htp.p(rec_get_terr_values.CNR_GROUP_NAME);
                                htp.p('</bold></td>');
                                htp.tableRowClose;
                            End if;
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
           htp.bodyClose;
           htp.htmlClose;
        end if; -- whether we're using excel or not
    else
           htp.p('Invalid session');
    end if;
    EXCEPTION
        when no_data_found then
	       htp.p('Territory Definition Report: No Data Found!!!');
	       htp.print('Territory Definition Report: No Data Found!!!');
        when others then
            htp.p('Territory Definition Report: No Data Found!!!');
            htp.print('report_wrapper: ' || substr(SQLERRM, 1,200));
END report_wrapper;

/*----------------------------------------------------------------
PROCEDURE XLS
----------------------------------------------------------------*/

PROCEDURE XLS
   (  p_srp      IN number,
      --p_sgrp     IN number,
      p_qual     in number)
IS
    g_image_prefix  varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
    l_response      varchar2(2000);
    v_tab           varchar2(1);
    v_tabrow        varchar2(32747);
    l_rec_count     number;

    l_srp           number;
    l_sgrp          number;
    l_qual          number;
    l_counter       number;

    l_display_type varchar2(100);
    l_convert_to_id_flag varchar2(1);
    h1_divider      varchar2(100) := '****************************************';
    h2_divider      varchar2(100) := '===================';
    h3_divider      varchar2(100) := '-------------------';

    p_territory_id  as_territories.territory_id%type ;
    p_territory_type_id  as_territories.territory_type_id%type ;

    -- cursor of result territory searches with resource and qualifier restrictions
    CURSOR cur_terr is
        select terr_id,  wf_notification.substitutespecialchars(name) name, rank from jtf_terr_all
        where terr_id in
            (select jtr.terr_id from jtf_terr_rsc jtr, jtf_terr_qual jtq
            where jtr.terr_id = jtq.terr_id
                    and jtr.resource_id = decode(l_srp,-1,jtr.resource_id,l_srp)
                    and jtq.qual_usg_id = decode(l_qual, -1, jtq.qual_usg_id, l_qual));

    -- cursor to get salesreps DELIVERY
    CURSOR c_get_salesrep(ci_terr_id NUMBER) IS
        select distinct resource_id,  wf_notification.substitutespecialchars(resource_name) resource_name
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
            , wf_notification.substitutespecialchars(j1.CNR_GROUP_NAME) CNR_GROUP_NAME
            , wf_notification.substitutespecialchars(DISPLAY_TYPE) DISPLAY_TYPE
            , wf_notification.substitutespecialchars(CONVERT_TO_ID_FLAG) CONVERT_TO_ID_FLAG
      FROM   jtf_terr_values_desc_v j1
      WHERE  j1.terr_qual_id = p_terr_qual_id
      ORDER BY j1.LOW_VALUE_CHAR_DESC, j1.COMPARISON_OPERATOR;

BEGIN

    l_srp     := p_srp;
    --l_sgrp    := p_sgrp;
    l_qual    := p_qual ;

    owa_util.mime_header('application/excel');
    fnd_client_info.set_org_context(fnd_profile.value('ORG_ID'));

    SELECT FND_GLOBAL.TAB
    INTO v_tab
    FROM dual;

    v_tabrow := null;
    -- display territories
    l_rec_count := 0;

    FOR rec_terr in cur_terr loop
        /*
        if cur_terr%rowcount > 1 then
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
        htp.p(v_tabrow);  -- print out prepared line
        v_tabrow := null;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        v_tabrow := v_tabrow||h1_divider||v_tab;
        htp.p(v_tabrow);  -- divider since we dont' know how to format rows in XLS
        l_rec_count := l_rec_count + 1;
        -- display sales reps
        FOR rec_get_salesrep in c_get_salesrep(rec_terr.terr_id) loop
            v_tabrow := null;
            v_tabrow := v_tabrow||rec_get_salesrep.resource_name||v_tab;
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
            if rec_get_terr_qual.qual_usg_id = -1012 then
                v_tabrow := v_tabrow||v_tab||v_tab||'Customer Name Range Group'||v_tab;
            end if;
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
                        v_tabrow := v_tabrow||rec_get_terr_values.cnr_group_name|| v_tab;
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

EXCEPTION
    when no_data_found then
	   htp.print('Territory Definition excel: No Data Found!!!');
    when others then
        htp.print('Territory Definition excel: '||substr(SQLERRM, 1,200));
END XLS;

END;

/
