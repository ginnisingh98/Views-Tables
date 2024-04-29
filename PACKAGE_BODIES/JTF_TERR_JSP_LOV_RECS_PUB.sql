--------------------------------------------------------
--  DDL for Package Body JTF_TERR_JSP_LOV_RECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_JSP_LOV_RECS_PUB" AS
/* $Header: jtfpjlvb.pls 120.5.12010000.2 2008/08/20 08:26:15 rajukum ship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_JSP_LOV_RECS_PUB
--    ---------------------------------------------------
--    PURPOSE
--      JTF/A Territories LOV Package
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/30/2001    EIHSU           Created
--      11/20/2001    EIHSU           Additional data groups
--      05/18/2004    ACHANDA         Bug # 3610389 : Make call to WF_NOTIFICATION.SubstituteSpecialChars
--                                    before rendering the data in jsp
--      06/03/2004    ACHANDA         Bug # 3664794
--      28/07/2008    GMARWAH         Bug 7237992. modified jtf_qual_usg to
--                                    jtf_qual_usg_all.
--    End of Comments
--
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_JSP_LOV_RECS_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfpjlvb.pls';

   G_NEW_LINE        VARCHAR2(02);
   G_APPL_ID         NUMBER;
   G_LOGIN_ID        NUMBER;
   G_PROGRAM_ID      NUMBER;
   G_USER_ID         NUMBER;
   G_REQUEST_ID      NUMBER;
   G_APP_SHORT_NAME  VARCHAR2(15);
   G_test_var        NUMBER;
   G_test_var2       NUMBER;
   G_dyn_result_tbl  JTF_TERR_JSP_LOV_RECS_PUB.lov_output_tbl_type;

    --TYPE GenericCurTyp IS REF CURSOR;
    TYPE Lov_output_cur_type IS REF CURSOR RETURN lov_inout_rec_type;

    Procedure Get_LOV_Records
    (   p_range_low           IN NUMBER,
        p_range_high          IN NUMBER,
        p_record_group_name   IN VARCHAR2, -- name of the data to fetch
        p_in_filter_lov_rec   IN lov_inout_rec_type,
        x_total_rows          OUT NOCOPY NUMBER,
        x_more_data_flag      OUT NOCOPY VARCHAR2,
        x_lov_ak_region       OUT NOCOPY VARCHAR2,
        x_result_tbl          OUT NOCOPY lov_output_tbl_type,
        x_disp_format_tbl     OUT NOCOPY lov_disp_format_tbl_type
    )
    IS
        -- Our generic cursor
        lov_output_cur      Lov_output_cur_type;

        -- filtering record type
        l_in_filter_lov_rec     lov_inout_rec_type;

        -- Processed cursor filter inputs
        l_column1       varchar2(2000);
        l_column2       varchar2(2000);
        l_column3       varchar2(2000);
        l_column4       varchar2(2000);
        l_column5       varchar2(2000);
        l_column6       varchar2(2000);
        l_column7       varchar2(2000);
        l_column8       varchar2(2000);
        l_column9       varchar2(2000);
        l_column10      varchar2(2000);
        l_column11      varchar2(2000);
        l_column12      varchar2(2000);
        l_column13      varchar2(2000);
        l_column14      varchar2(2000);
        l_column15      varchar2(2000);
        -------------------------------
        l_filter1       varchar2(2000);
        l_filter2       varchar2(2000);
        l_filter3       varchar2(2000);
        l_filter4       varchar2(2000);
        l_filter5       varchar2(2000);

        -- Cursor iteration variables
        l_index                      NUMBER := 0;
        l_range_high                 NUMBER;
        rec                          lov_inout_rec_type;

        l_new_low_value             number;
        l_new_high_value            number;
        l_total_count               number := 0;
        l_rec_set                   number := 1;
        l_start                     number := 0;
        l_more_data                 varchar2(1) ;
        l_org_id                    number;
        l_catset                    number;
        l_row_count                 number;

        -- Other variables
        l_jsp_lov_sql               varchar2(2000);

        -- dynamic block variables
        jtty_list1      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
        jtty_list2      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
        jtty_list3      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
        jtty_list4      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
        jtty_list5      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
        l_out_cols      number := 0;  -- number of columns in dynamic qual value sql
        l_qv_total      number := 0;

        l_dummy1        varchar2(300);
        l_dummy2        varchar2(300);
        l_dyn_body_top          varchar2(2000);
        l_dyn_body_loop_cmds    varchar2(2000);
        l_dyn_body_btm          varchar2(2000);

 --       cursor c_all_dyn_qual_vals is
 --           select * from JTF_TERR_JSP_LOV_REC_TBL;


    BEGIN
     G_NEW_LINE        := FND_GLOBAL.Local_Chr(10);
     G_APPL_ID         := FND_GLOBAL.Prog_Appl_Id;
     G_LOGIN_ID        := FND_GLOBAL.Conc_Login_Id;
     G_PROGRAM_ID      := FND_GLOBAL.Conc_Program_Id;
     G_USER_ID         := FND_GLOBAL.User_Id;
     G_REQUEST_ID      := FND_GLOBAL.Conc_Request_Id;
     G_APP_SHORT_NAME  := FND_GLOBAL.Application_Short_Name;
     G_test_var        := 5;
     G_test_var2       := 4;

        l_column1       :=   p_in_filter_lov_rec.column1;
        l_column2       :=   p_in_filter_lov_rec.column2;
        l_column3       :=   p_in_filter_lov_rec.column3;
        l_column4       :=   p_in_filter_lov_rec.column4;
        l_column5       :=   p_in_filter_lov_rec.column5;
        l_column6       :=   p_in_filter_lov_rec.column6;
        l_column7       :=   p_in_filter_lov_rec.column7;
        l_column8       :=   p_in_filter_lov_rec.column8;
        l_column9       :=   p_in_filter_lov_rec.column9;
        l_column10      :=   p_in_filter_lov_rec.column10;
        l_column11      :=   p_in_filter_lov_rec.column11;
        l_column12      :=   p_in_filter_lov_rec.column12;
        l_column13      :=   p_in_filter_lov_rec.column13;
        l_column14      :=   p_in_filter_lov_rec.column14;
        l_column15      :=   p_in_filter_lov_rec.column15;
        l_filter1       :=   p_in_filter_lov_rec.filter1;
        l_filter2       :=   p_in_filter_lov_rec.filter2;
        l_filter3       :=   p_in_filter_lov_rec.filter3;
        l_filter4       :=   p_in_filter_lov_rec.filter4;
        l_filter5       :=   p_in_filter_lov_rec.filter5;
        l_in_filter_lov_rec := p_in_filter_lov_rec;

        l_new_low_value             := p_range_low ;
        l_new_high_value            := p_range_high ;

        l_dyn_body_top          := '';
        l_dyn_body_loop_cmds    := '';
        l_dyn_body_btm          := '';

        IF (p_range_high < 0) THEN
           l_rec_set  := ABS(p_range_high);
        END IF;



        If p_record_group_name = 'QUALIFIER_VALUES' then

            --////////////////////////////////////
            --// QUALIFIER VALUES CONDITION
            --////////////////////////////////////

            if l_in_filter_lov_rec.column1 = '-9001' then
               l_jsp_lov_sql := 'select WF_NOTIFICATION.SubstituteSpecialChars(Meaning) col1_value, lookup_code col2_value from ar_lookups where lookup_type = ''HZ_PARTY_CERT_LEVEL'' ';
            else
               select distinct jsp_lov_sql into l_jsp_lov_sql
               from jtf_qual_usgs_all
               where qual_usg_id = l_in_filter_lov_rec.column1;

            end if;

            --dbms_output.put_line('l_in_filter_lov_rec.column1 ' || l_in_filter_lov_rec.column1);

            --/////////////////////////////////////////////////////
            --//  Dynamic block for fetching all qualifier values
            --/////////////////////////////////////////////////////

            if instr(l_jsp_lov_sql, 'col1_value') > 0 then
                l_out_cols := 1;
                l_dyn_body_loop_cmds := l_dyn_body_loop_cmds || '
                                            ld_jtty_list1.extend;
                                            ld_jtty_list1(ld_out_index) := ld_rec_qual_vals.col1_value;
                                        ';
            end if;
            if instr(l_jsp_lov_sql, 'col2_value') > 0 then
                l_out_cols := 2;
                l_dyn_body_loop_cmds := l_dyn_body_loop_cmds || '
                                            ld_jtty_list2.extend;
                                            ld_jtty_list2(ld_out_index) := ld_rec_qual_vals.col2_value;
                                        ';
            end if;
            if instr(l_jsp_lov_sql, 'col3_value') > 0 then
                l_out_cols := 3;
                l_dyn_body_loop_cmds := l_dyn_body_loop_cmds || '
                                            ld_jtty_list3.extend;
                                            ld_jtty_list3(ld_out_index) := ld_rec_qual_vals.col3_value;
                                        ';
            end if;
            if instr(l_jsp_lov_sql, 'col4_value') > 0 then
                l_out_cols := 4;
                l_dyn_body_loop_cmds := l_dyn_body_loop_cmds || '
                                            ld_jtty_list4.extend;
                                            ld_jtty_list4(ld_out_index) := ld_rec_qual_vals.col4_value;
                                        ';
            end if;
            if instr(l_jsp_lov_sql, 'col5_value') > 0 then
                l_out_cols := 5;
                l_dyn_body_loop_cmds := l_dyn_body_loop_cmds || '
                                            ld_jtty_list5.extend;
                                            ld_jtty_list5(ld_out_index) := ld_rec_qual_vals.col5_value;
                                        ';
            end if;

            l_dyn_body_top := '
                DECLARE
                    CURSOR ldc_qual_vals IS
                    '
                    || l_jsp_lov_sql || ';' ||
                    '
                    ld_out_index number := 1;
                    ld_dummy1    varchar2(300);
                    ld_jtty_list1      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
                    ld_jtty_list2      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
                    ld_jtty_list3      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
                    ld_jtty_list4      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
                    ld_jtty_list5      JTF_TERR_CHAR_360LIST := JTF_TERR_CHAR_360LIST();
                    ld_low_value    number := ' || l_new_low_value || ';
                    ld_high_value   number := ' || l_new_high_value || ';
                    ld_out_total    number;
                BEGIN

                    --dbms_output.put_line(''ld_low_value '' || ld_low_value);
                    --dbms_output.put_line(''ld_high_value '' || ld_high_value);

                    for ld_rec_qual_vals in ldc_qual_vals loop
                       --dbms_output.put_line(''vals: '' || ld_rec_qual_vals.col1_value || ''//'' ||
                       --                                   ld_rec_qual_vals.col2_value);
                '
                ;

            l_dyn_body_btm := '
                        ld_out_index := ld_out_index + 1;
                    end loop;

                    --dbms_output.put_line(''ld_jtty_list1.last '' || ld_jtty_list1.last);
                    ld_out_total := ld_jtty_list1.last ;
                    if ld_out_total is null then
                        ld_out_total := 0;
                    end if;

                    :1 := ld_jtty_list1;
                    :2 := ld_jtty_list2;
                    :3 := ld_jtty_list3;
                    :4 := ld_jtty_list4;
                    :5 := ld_jtty_list5;
                    :6 := ld_out_total;
                 END;
                '
                ;

            if l_new_low_value is null then l_new_low_value := 1; end if;
            if l_new_high_value is null then l_new_high_value := -1; end if;
            -- create dynamic block
            execute immediate
                l_dyn_body_top || l_dyn_body_loop_cmds  || l_dyn_body_btm
                using in OUT jtty_list1,
                      in OUT jtty_list2,
                      in OUT jtty_list3,
                      in OUT jtty_list4,
                      in OUT jtty_list5,
                      in OUT l_qv_total;

            --dbms_output.put_line('l_qv_total= ' || l_qv_total);
            -- this is total row coming OUT NOCOPYof dynamic block

            l_row_count := 0;
            loop
                exit when jtty_list1.last is null;
                exit when jtty_list1.last = l_row_count;
                l_row_count := l_row_count + 1;
                if l_out_cols >= 1 then
                    x_result_tbl(l_row_count).column1 := WF_NOTIFICATION.SubstituteSpecialChars(jtty_list1(l_row_count));
                end if;
                if l_out_cols >= 2 then
                    x_result_tbl(l_row_count).column2 := jtty_list2(l_row_count);
                end if;
                if l_out_cols >= 3 then
                    x_result_tbl(l_row_count).column3 := jtty_list3(l_row_count);
                end if;
                if l_out_cols >= 4 then
                    x_result_tbl(l_row_count).column4 := jtty_list4(l_row_count);
                end if;
                if l_out_cols >= 5 then
                    x_result_tbl(l_row_count).column5 := jtty_list5(l_row_count);
                end if;
            end loop;

            x_total_rows := l_row_count;

        else -- data group name is not qualifier_values

            If p_record_group_name = 'SOURCES' then
                --------------------------------------------------------------------
                -- Sources
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'JTF_TERR_SOURCES_LOV_REGION';
                -- instantiate filter values
                l_column1 := UPPER(l_in_filter_lov_rec.column1) || '%';

                -- Get the total count for display
                SELECT count(*)
                INTO l_total_count
                from jtf_sources
                where UPPER(meaning) like NVL(l_column1, '%');

                OPEN lov_output_cur FOR
                    Select WF_NOTIFICATION.SubstituteSpecialChars(meaning), source_id, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from jtf_sources
                    where UPPER(meaning) like NVL(l_column1, '%')
                    order by meaning;

            elsif p_record_group_name = 'ENABLED_QUALS' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                l_column1 := UPPER(l_in_filter_lov_rec.column1) || '%';

                -- Get the total count for display
                SELECT count(*)
                INTO l_total_count
                from jtf_seeded_qual_usgs_v
                where UPPER(seeded_qual_name) like NVL(l_column1, '%') || '%'
    --                and source_id = l_column2
                    and enabled_flag = 'Y';

                OPEN lov_output_cur FOR
                    Select distinct WF_NOTIFICATION.SubstituteSpecialChars(jsquv.seeded_qual_name) sqname, jsquv.qual_usg_id, jsquv.qual_type_id,
                        jsquv.source_id, jsquv.qual_col1_alias,
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from jtf_seeded_qual_usgs_v jsquv
                    where UPPER(seeded_qual_name) like NVL(l_column1, '%') || '%'
                        and source_id = NVL(l_column2, source_id)
                        and enabled_flag = 'Y'
                    order by jsquv.source_id, sqname;

            elsif p_record_group_name = 'ALL_TERR_RESOURCES' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                l_column1 := UPPER(l_in_filter_lov_rec.column1) || '%';

                -- Get the total count for display
                SELECT distinct count(*)
                INTO l_total_count
                from jtf_terr_resources_v jtrv
                where UPPER(resource_name) like NVL(l_column1, '%') || '%'
                -- ARPATEL09/08/2003  bug#2966686 fix
                or l_column1 = '%';

                OPEN lov_output_cur FOR
                    Select distinct WF_NOTIFICATION.SubstituteSpecialChars(resource_name), resource_id,
                             resource_type, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from jtf_terr_resources_v jtrv
                    where (UPPER(resource_name) like NVL(l_column1, '%') || '%'
                    -- ARPATEL09/08/2003  bug#2966686 fix
                       or l_column1 = '%')
                      AND EXISTS ( SELECT NULL
                                   FROM jtf_terr_denorm_rules_all jtdr
                                   WHERE jtdr.source_id = NVL(l_column2, source_id)
                                     AND jtdr.terr_id = jtrv.terr_id
				     AND JTDR.RELATED_TERR_ID = JTRV.TERR_ID)
                    order by resource_name;

            elsif p_record_group_name = 'LOOKUP_QUALIFIERS' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                l_column1 := l_in_filter_lov_rec.column1;  -- usage filter
                --dbms_output.put_line('LOOKUP_QUALIFIERS ');
                -- Get the total count for display
                l_total_count := 1;  -- because this will always be used to get all rows

                OPEN lov_output_cur FOR

                 /*   select WF_NOTIFICATION.SubstituteSpecialChars(seeded_qual_name), qual_usg_id, Decode(jsp_lov_sql, null, 'N', 'Y'),
                        qual_col1_alias, display_type,
                        seeded_qual_id, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from jtf_seeded_qual_usgs_v
                    where use_in_lookup_flag = 'Y'
                       and enabled_flag = 'Y'
                       and source_id = -1001
		       ARPATEL BUG#3736597 fix
		       and qual_col1_alias is not null
                    order by display_sequence;*/ --commented for bug 7237992.

                -- replaced the above query with following query
                SELECT distinct WF_NOTIFICATION.SubstituteSpecialChars(jsq.name), jqu.qual_usg_id, Decode(jqu.jsp_lov_sql, null, 'N', 'Y'),
                        jqu.qual_col1_alias, jqu.display_type,
                        jsq.seeded_qual_id, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                FROM jtf_qual_usgs_all jqu, jtf_seeded_qual_all_b jsq,jtf_qual_type_usgs_all jqtu,
                     jtf_qual_types_all jqt ,jtf_sources_all js
                WHERE jqu.use_in_lookup_flag = 'Y'
                       and jqu.enabled_flag = 'Y'
                       and jqtu.qual_type_id = jqt.qual_type_id
                       and jqtu.qual_type_usg_id = jqu.qual_type_usg_id
                       and jsq.seeded_qual_id = jqu.seeded_qual_id
                       and js.source_id = jqtu.source_id
                       and js.source_id= -1001
                       and jqu.qual_col1_alias is not null;

            elsif p_record_group_name = 'BLANK' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                -- Get the total count for display
                l_total_count := 1;  -- because this will always be used to get all rows

                OPEN lov_output_cur FOR
                    select '--------------', '-------------', ' ', ' ', ' ',
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from dual;

            elsif p_record_group_name = 'SYSTEM_DATE' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                -- Get the total count for display
                l_total_count := 1;  -- because this will always be used to get all rows

                OPEN lov_output_cur FOR
                    select trunc(sysdate), null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                    from dual;



            elsif p_record_group_name = 'SALES_GROUP' then
                --------------------------------------------------------------------
                -- DATA_GROUP
                --------------------------------------------------------------------
                -- AK REGION
                x_lov_ak_region := 'XXXX';
                -- instantiate filter values
                l_column1 := UPPER(l_in_filter_lov_rec.column1) || '%';

                -- Get the total count for display
                SELECT count(*)
                INTO l_total_count
                from  JTF_TERR_RESOURCES_V
                where (end_date_active is null or end_date_active >= sysdate)
                and group_id is not null;

                OPEN lov_output_cur FOR
                    Select distinct jtr.group_name, jtr.group_id, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null,
                        null, null, null, null, null
                   from  JTF_TERR_RESOURCES_V jtr
                   where (jtr.end_date_active is null or jtr.end_date_active >= sysdate)
                     and jtr.group_id is not null
                     AND EXISTS ( SELECT NULL
                                  FROM jtf_terr_denorm_rules_all jtdr
                                  WHERE jtdr.source_id = -1001
                                    AND jtdr.terr_id = jtr.terr_id
				    AND JTDR.RELATED_TERR_ID = JTR.TERR_ID )
                    order by group_name;


            else
                l_total_count := 0;

            end if;

            ----------------------------------------------
            -- Loop dynamic cursor to output table type
            ----------------------------------------------
           	l_row_count := 0;
            If l_range_high >= 0 then
                l_range_high := l_new_high_value + 1;
            end if;

            if l_total_count > 0 then
                loop
                    fetch lov_output_cur into rec;
                    IF (l_row_count = l_range_high) then
                        x_more_data_flag := 'Y' ;
                    ELSE
                      IF ((l_row_count <> l_range_high) OR lov_output_cur%notfound ) THEN
                        x_more_data_flag := 'N' ;
                      END IF;
                    END IF;
            -- RETURN ALL RECORDS IF THEY PUT -1 as range high
                    if l_range_high = -1 then
                        null;
                    else
                        exit when l_row_count = l_range_high;
                    end if;
                    exit when lov_output_cur%notfound;

                    l_row_count := l_row_count + 1;
                    if (l_row_count between l_new_low_value and l_new_high_value) OR
                        (p_range_high = -1) then
                        l_index := l_index + 1;
                        x_result_tbl(l_index) := rec;
                     end if;
                end loop;
                close lov_output_cur;

            end if;
            x_total_rows := l_total_count;

        end if; -- qualifier_values or other data group?

    END Get_LOV_Records;

END JTF_TERR_JSP_LOV_RECS_PUB;

/
