--------------------------------------------------------
--  DDL for Package Body JTF_TERR_JSP_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_JSP_REPORTS" AS
/* $Header: jtfpjrpb.pls 120.7.12010000.11 2009/07/24 09:15:14 ppillai ship $ */
---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_JSP_REPORTS
--    ---------------------------------------------------
--    PURPOSE
--      JTF/A Territories JSP Reports Package
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/18/2001    EIHSU           Created
--      11/13/2001    ARPATEL         Added SQL statements for intelligence report JSP
--      11/20/2001    EIHSU	      removed dbms output messages
--                                    added active_on date conditions into def, chg reports
--      05/06/2002    ARPATEL         Added support for p_rpt_type = 'LOOKUP_TERR' in
--                                    definition_rpt proc - enh# 2109535
--      05/18/2004    ACHANDA         Bug # 3610389 : Make call to WF_NOTIFICATION.SubstituteSpecialChars
--                                    before rendering the data in jsp
--      28/07/2008    GMARWAH         Modified for Bug 7237992
--      18/08/2008    GMARWAH         Modified for bug 731589 to display operating unit
--    End of Comments
--

  type terr_name_rec_type is record
    (terr_id    NUMBER,
     name       VARCHAR2(2000),
     rank       NUMBER,
     start_date_active DATE,
     end_date_active    DATE,
     last_update_date   DATE,
     description    VARCHAR2(2000)
     );

  type terr_name_cur_type is REF CURSOR RETURN terr_name_rec_type;



  ---------------------------------------------------------------
  --    definition_rpt
  --    Notes: This procedure handles Definitions and Changes Reports
  --           arpatel 05/06/2002 - also handles Lookup territory details by terr_id
  --
  --
  ---------------------------------------------------------------
  procedure definition_rpt (p_param1 in varchar2,
                            p_param2 in varchar2,
                            p_param3 in varchar2,
                            p_param4 in varchar2,
                            p_param5 in varchar2,
                            p_rpt_type in varchar2,
                            x_result_tbl OUT NOCOPY report_out_tbl_type)
  is

  --lc_resource_id    number := p_param1;
  --lc_qual_usg_id    number := p_param2;

  ll_terr_id        number;
  ll_terr_name      varchar2(300);
  ll_terr_rank      number;
  l_out_index       number;
  l_out_rec         report_out_rec_type;
  lx_result_tbl report_out_tbl_type := report_out_tbl_type();

  qual_type_count           number;
  resource_count            number;
  rsc_access_count          number;
  terr_qual_count           number;
  terr_rsc_qual_count       number;
  qual_value_count          number;
  rsc_qual_value_count      number;
  cumulative_qual_val_count number;
  qual_colspan              number;
  terr_colspan              number;
  terr_rspan_row_number     number;
  rsc_access_rspan_row_number number;
  tqual_rspan_row_number    number;
  qval_rspan_row_number     number;

  terr_name_cur             terr_name_cur_type;
  rec_terr                  terr_name_rec_type;
  rpt_type                  VARCHAR2(30);
    -- all the territories we will be reporting on
/*
    CURSOR cur_terr is
        select j.terr_id, j.name, j.rank
        from jtf_terr j
        where NVL(j.end_date_active, sysdate) >= sysdate
          AND j.start_date_active <= sysdate
          AND EXISTS
            ( select jtr.terr_id
              from jtf_terr_rsc jtr, jtf_terr_qual jtq
              where jtr.terr_id = jtq.terr_id
                    and jtr.resource_id = decode(lc_resource_id ,null, jtr.resource_id, lc_resource_id)
                    and jtq.qual_usg_id = decode(lc_qual_usg_id ,null, jtq.qual_usg_id, lc_qual_usg_id)
                    AND jtr.terr_id = j.terr_id
            );
*/
    -- qualifier types
    CURSOR c_get_qual_types(ci_terr_id NUMBER) IS
        select qual_type_usg_id, WF_NOTIFICATION.SubstituteSpecialChars(qualifier_type_name) qualifier_type_name,
               WF_NOTIFICATION.SubstituteSpecialChars(qualifier_type_description) qualifier_type_description
        from jtf_terr_transactions_v
        where terr_id = ci_terr_id;


    -- dynamic qualifiers
    CURSOR c_get_terr_qual (ci_terr_id NUMBER) IS
/*        SELECT  TERR_QUAL_ID,
                TERR_ID,
                QUAL_USG_ID,
                ORG_ID,
                WF_NOTIFICATION.SubstituteSpecialChars(qualifier_name) qualifier_name
        FROM    jtf_terr_qualifiers_v
        WHERE   qualifier_type_name <> 'RESOURCE'
            and terr_id = ci_terr_id
            and terr_qual_id is not null -- added becuse we have some real bad data in jtadom
            ;
*/-- Commented for bug 7237992

SELECT
      JTQ.TERR_QUAL_ID,
      JTQ.TERR_ID,
      JTQ.QUAL_USG_ID,
      JTQ.ORG_ID,
      WF_NOTIFICATION.SUBSTITUTESPECIALCHARS(JSQ.NAME) QUALIFIER_NAME
FROM
 JTF_TERR_QUAL_ALL JTQ ,
 JTF_QUAL_USGS_ALL JQU ,
 JTF_SEEDED_QUAL_ALL_TL JSQ ,
 JTF_QUAL_TYPE_USGS_ALL JQTU ,
 JTF_QUAL_TYPES JQT
WHERE JTQ.QUAL_USG_ID = JQU.QUAL_USG_ID
AND   JTQ.ORG_ID = JQU.ORG_ID
AND JQU.SEEDED_QUAL_ID = JSQ.SEEDED_QUAL_ID
AND JSQ.LANGUAGE = USERENV('LANG')
AND JQU.QUAL_TYPE_USG_ID = JQTU.QUAL_TYPE_USG_ID
AND JQTU.QUAL_TYPE_ID = JQT.QUAL_TYPE_ID
AND jtq.terr_id = ci_terr_id
AND jtq.terr_qual_id is not null
AND jqt.qual_type_id <> -1001 ;



    CURSOR c_get_terr_rsc_qual (ci_terr_id NUMBER) IS
        SELECT  TERR_QUAL_ID,
                TERR_ID,
                QUAL_USG_ID,
                ORG_ID,
                WF_NOTIFICATION.SubstituteSpecialChars(qualifier_name) qualifier_name
        FROM    jtf_terr_qualifiers_v
        WHERE   qualifier_type_name = 'RESOURCE'
            and terr_id = ci_terr_id;


    -- dynamic qualifier values
    /*
    CURSOR c_get_terr_values (ci_terr_qual_id NUMBER) IS
       SELECT j1.TERR_VALUE_ID
            , j1.COMPARISON_OPERATOR
           -- , WF_NOTIFICATION.SubstituteSpecialChars(j1.LOW_VALUE_CHAR_DESC) LOW_VALUE_CHAR_DESC
           --, WF_NOTIFICATION.SubstituteSpecialChars(j1.HIGH_VALUE_CHAR_DESC) HIGH_VALUE_CHAR_DESC
           -- Commented for bug 8365663
            ,decode(j2.display_type,   'CHAR'
            ,decode(j1.id_used_flag,   'Y',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char_id,   NULL)
            ,'N',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char,   NULL),   NULL)
            ,'DEP_2FIELDS_1CHAR_1ID',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char,   NULL)
             ,WF_NOTIFICATION.SubstituteSpecialChars(j1.LOW_VALUE_CHAR)) low_value_char_desc

             ,decode(j2.display_type,   'CHAR'
             ,jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.high_value_char,   NULL)
             ,'DEP_2FIELDS_1CHAR_1ID',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,   j1.low_value_char_id,   NULL)
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.HIGH_VALUE_CHAR)) high_value_char_desc
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , j1.INTEREST_TYPE
            , j1.PRIMARY_INTEREST_CODE
            , j1.SECONDARY_INTEREST_CODE
            , j1.CURRENCY_DESC
            , j1.LOW_VALUE_CHAR_ID
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.CNR_GROUP_NAME) CNR_GROUP_NAME
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE1_DESC) VALUE1_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE2_DESC) VALUE2_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE3_DESC) VALUE3_DESC
            , j1.LOW_VALUE_DATE
            , j1.HIGH_VALUE_DATE
            , DISPLAY_TYPE
            , CONVERT_TO_ID_FLAG
            -- more to come directly from the jtf_terr_values_desc_v view
      FROM   jtf_terr_values_desc_v j1
      WHERE  j1.terr_qual_id = ci_terr_qual_id
         and j1.terr_value_id is not null -- added becuse we have some real bad data in jtadom
      ORDER BY j1.LOW_VALUE_CHAR_DESC, j1.COMPARISON_OPERATOR;*/--COmmented for bug 7237992
/*
      SELECT distinct  j1.TERR_VALUE_ID
            , j1.COMPARISON_OPERATOR
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.LOW_VALUE_CHAR) LOW_VALUE_CHAR_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.HIGH_VALUE_CHAR) HIGH_VALUE_CHAR_DESC
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
            , j1.INTEREST_TYPE_ID INTEREST_TYPE
            , j1.PRIMARY_INTEREST_CODE_ID PRIMARY_INTEREST_CODE
            , j1.SECONDARY_INTEREST_CODE_ID SECONDARY_INTEREST_CODE
            , j1.CURRENCY_CODE  CURRENCY_DESC
            , j1.LOW_VALUE_CHAR_ID
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.CNR_GROUP_ID) CNR_GROUP_NAME
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE1_ID) VALUE1_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE2_ID) VALUE2_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.VALUE3_ID) VALUE3_DESC
            , null LOW_VALUE_DATE
            , null HIGH_VALUE_DATE
            , DISPLAY_TYPE
            , CONVERT_TO_ID_FLAG
      FROM   jtf_terr_values_all j1, JTF_QUAL_USGS_ALL j2, JTF_TERR_QUAL_ALL j3
      WHERE  j1.terr_qual_id = ci_terr_qual_id
        AND j1.terr_qual_id = j3.terr_qual_id
        AND j2.QUAL_USG_ID = j3.QUAL_USG_ID
        AND j1.terr_value_id is not null
      ORDER BY  j1.COMPARISON_OPERATOR;
*/

  CURSOR c_get_terr_values (ci_terr_qual_id NUMBER) IS
      SELECT distinct  j1.TERR_VALUE_ID
            , j1.COMPARISON_OPERATOR
            --, WF_NOTIFICATION.SubstituteSpecialChars(j1.LOW_VALUE_CHAR) LOW_VALUE_CHAR_DESC
            --, WF_NOTIFICATION.SubstituteSpecialChars(j1.HIGH_VALUE_CHAR) HIGH_VALUE_CHAR_DESC
           -- Commented for bug 8365663
            ,decode(j2.display_type,   'CHAR'
            ,decode(j1.id_used_flag,   'Y',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char_id,   NULL)
            ,'N',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char,   NULL),   NULL)
            ,'DEP_2FIELDS_1CHAR_1ID',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.low_value_char,   NULL)
             ,WF_NOTIFICATION.SubstituteSpecialChars(j1.LOW_VALUE_CHAR))
              low_value_char_desc

             ,decode(j2.display_type,   'CHAR'
             ,jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.high_value_char,   NULL)
             ,'DEP_2FIELDS_1CHAR_1ID',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,   j1.low_value_char_id,   NULL)
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.HIGH_VALUE_CHAR))
              high_value_char_desc
            , j1.LOW_VALUE_NUMBER
            , j1.HIGH_VALUE_NUMBER
--            , j1.INTEREST_TYPE_ID INTEREST_TYPE
--            , j1.PRIMARY_INTEREST_CODE_ID PRIMARY_INTEREST_CODE
--            , j1.SECONDARY_INTEREST_CODE_ID SECONDARY_INTEREST_CODE
              , decode(j2.display_type,   'INTEREST_TYPE',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.interest_type_id,   NULL),   NULL) INTEREST_TYPE
              , decode(j2.display_type,   'INTEREST_TYPE',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,   j1.primary_interest_code_id,   NULL),   NULL)  PRIMARY_INTEREST_CODE
              , decode(j2.display_type,   'INTEREST_TYPE',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql3,   j1.secondary_interest_code_id,   NULL),   NULL) SECONDARY_INTEREST_CODE

            , j1.CURRENCY_CODE  CURRENCY_DESC
            , j1.LOW_VALUE_CHAR_ID
            , WF_NOTIFICATION.SubstituteSpecialChars(j1.CNR_GROUP_ID) CNR_GROUP_NAME
            , WF_NOTIFICATION.SubstituteSpecialChars(decode(j2.display_type,   'CHAR_2IDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.value1_id,   j1.value2_id),
													'DEP_2FIELDS_CHAR_2IDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.value1_id,   -9999),   'DEP_2FIELDS',
													jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.value1_id,   -9999),   'DEP_3FIELDS_CHAR_3IDS',
													jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql1,   j1.value1_id,   -9999),   NULL)) VALUE1_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(decode(j2.display_type,   'DEP_2FIELDS_CHAR_2IDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,
													j1.value2_id,   j1.value3_id),   'DEP_2FIELDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,   j1.value2_id,   -9999),
													'DEP_3FIELDS_CHAR_3IDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql2,   j1.value2_id,   -9999),   NULL)) VALUE2_DESC
            , WF_NOTIFICATION.SubstituteSpecialChars(decode(j2.display_type,   'DEP_3FIELDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql3,   j1.value3_id,   NULL),
													'DEP_3FIELDS_CHAR_3IDS',   jtf_territory_pvt.get_terr_value_desc(j2.convert_to_id_flag,   j2.display_type,   j2.column_count,   j2.display_sql3,   j1.value3_id,   j1.value4_id),   NULL)) VALUE3_DESC
            , null LOW_VALUE_DATE
            , null HIGH_VALUE_DATE
            , DISPLAY_TYPE
            , CONVERT_TO_ID_FLAG
      FROM   jtf_terr_values_all j1, JTF_QUAL_USGS_ALL j2, JTF_TERR_QUAL_ALL j3
      WHERE  j1.terr_qual_id = ci_terr_qual_id
        AND j1.terr_qual_id = j3.terr_qual_id
        AND j2.QUAL_USG_ID = j3.QUAL_USG_ID
        AND j1.terr_value_id is not null
      ORDER BY  j1.COMPARISON_OPERATOR;
    -- resources
    CURSOR c_get_resource(ci_terr_id NUMBER) IS
/*        select resource_id, WF_NOTIFICATION.SubstituteSpecialChars(resource_name) resource_name, resource_type, terr_rsc_id
        from jtf_terr_resources_v jtrv
        where jtrv.terr_id = ci_terr_id
        order by resource_name;
*/
        select resource_id, WF_NOTIFICATION.SubstituteSpecialChars(jtf_territory_resource_pvt.get_resource_name(
        RESOURCE_ID , DECODE( RESOURCE_TYPE , 'RS_SUPPLIER', 'RS_SUPPLIER_CONTACT' ,
RESOURCE_TYPE ) )) resource_name, resource_type, terr_rsc_id
        from JTF_TERR_RSC
	where terr_id = ci_terr_id
        order by resource_name;

    -- resource accesses
    CURSOR c_get_rsc_access(ci_terr_rsc_id NUMBER) IS
        select terr_rsc_access_id, access_type, WF_NOTIFICATION.SubstituteSpecialChars(meaning) meaning
        from jtf_terr_rsc_access_v
        where terr_rsc_id = ci_terr_rsc_id;

    lp_sysdate     DATE := SYSDATE;
    l_match_qual NUMBER := 0;

    /* ARPATEL: 10/16, bug#2832442 */
    l_resource_id VARCHAR2(2000);
    l_resource_type VARCHAR2(2000);

    /*Added for bug 7315889 */
    CURSOR c_get_operating_unit(ci_terr_id VARCHAR2) IS
     SELECT distinct hr.name operating_unit
     FROM hr_operating_units hr, jtf_terr_all jt
     WHERE hr.organization_id = jt.org_id
     AND jt.terr_id = ci_terr_id;

    -- ADDED FOR BUG 7315889
    l_terr_operating_unit hr_operating_units.name%TYPE;

  begin

    --dbms_output.put_line('JTF_TERR_JSP_REPORTS.definition_rpt: BEGIN ');
    --dbms_output.put_line(p_param1 || ' / ' || p_param2 || ' / ' || p_param3 || ' / ' || p_param4 || ' / ' || p_param5);
      -- loop through cur_terr
      l_out_index := 0;

    /* arpatel 05/06/02 enh# 2109535 */
    if p_rpt_type = 'LOOKUP_TERR' and p_param5 IS NOT NULL then
       open terr_name_cur for
            select j.terr_id, WF_NOTIFICATION.SubstituteSpecialChars(j.name) name, j.rank, j.start_date_active, j.end_date_active,
                   j.last_update_date, WF_NOTIFICATION.SubstituteSpecialChars(j.description) description
            from jtf_terr_all  j
            where j.terr_id = p_param5;


        -- ADDED FOR BUG 7315889
        OPEN c_get_operating_unit(p_param5);
        FETCH c_get_operating_unit INTO l_terr_operating_unit;
        CLOSE c_get_operating_unit;

    elsif p_rpt_type = 'DEFINITION' then
      if ((p_param5 is null) or (p_param5 = '')) then

        /* ARPATEL: 10/16, bug#2832442 */
        --parse the resource_id to extract the resource_type
        select SUBSTR(p_param1, 1,INSTR(p_param1, 'R')-1)
          into l_resource_id
          from dual;

        select SUBSTR(p_param1, INSTR(p_param1, 'R'))
          into l_resource_type
          from dual;

        /* ARPATEL: 10/16, END OF bug#2832442 */

        --dbms_output.put_line('get territory by property');
        open terr_name_cur for
            select j.terr_id, WF_NOTIFICATION.SubstituteSpecialChars(j.name) name, j.rank, j.start_date_active, j.end_date_active,
                   j.last_update_date, WF_NOTIFICATION.SubstituteSpecialChars(j.description) description
            from jtf_terr j
              WHERE ( TRUNC(j.end_date_active) >= NVL(p_param4, lp_sysdate)
                      AND
                      TRUNC(j.start_date_active) <= NVL(p_param4, lp_sysdate)
                    )
              AND EXISTS
                ( select jtr.terr_id
                  from jtf_terr_rsc jtr, jtf_terr_qual jtq, jtf_terr_usgs jtu
                  where jtr.terr_id = jtq.terr_id
                        and jtr.terr_id = jtu.terr_id
                        and jtr.resource_id = decode(l_resource_id ,null, jtr.resource_id, l_resource_id)
                        /* ARPATEL: 10/16, bug#2832442 */
                        and jtr.resource_type = decode(l_resource_type ,null, jtr.resource_type, l_resource_type)
                        and jtq.qual_usg_id = decode(p_param2 ,null, jtq.qual_usg_id, p_param2)
                        and jtu.source_id   = decode(p_param3 ,null, jtu.source_id, p_param3)
                        AND jtr.terr_id = j.terr_id
                )
               AND NOT EXISTS (
                    SELECT jt.terr_id
                    FROM jtf_terr_all jt
                    WHERE ( ( NVL(jt.end_date_active, lp_sysdate) <= NVL(p_param4, lp_sysdate) ) OR
                            ( NVL(jt.start_date_active, lp_sysdate) > NVL(p_param4, lp_sysdate) )
                          )
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = j.terr_id )  ;
      else
        --dbms_output.put_line('get territory by_id mode ');
        open terr_name_cur for
            select j.terr_id, WF_NOTIFICATION.SubstituteSpecialChars(j.name) name, j.rank, j.start_date_active, j.end_date_active,
                   j.last_update_date, WF_NOTIFICATION.SubstituteSpecialChars(j.description) description
            from jtf_terr j
            where j.terr_id = p_param5;

      end if;
    elsif p_rpt_type = 'CHANGES' then
      --dbms_output.put_line('creating changes cursor ');
      open terr_name_cur for
          select j.terr_id, WF_NOTIFICATION.SubstituteSpecialChars(j.name) name, j.rank, j.start_date_active, j.end_date_active,
                 j.last_update_date, WF_NOTIFICATION.SubstituteSpecialChars(j.description) description
          from jtf_terr j, jtf_terr_usgs jtu
          where 1=1
            --and j.terr_id = '19027'
            AND j.terr_id = jtu.terr_id
            AND j.start_date_active <= sysdate
            AND trunc(j.terr_update_date) >= p_param1
            AND trunc(j.terr_update_date) <= NVL(p_param2, sysdate)
            AND ( TRUNC(j.end_date_active) >= NVL(p_param4, lp_sysdate)
                  AND
                  TRUNC(j.start_date_active) <= NVL(p_param4, lp_sysdate)
                 )
            AND jtu.source_id = NVL(p_param3, jtu.source_id)
               AND NOT EXISTS (
                    SELECT jt.terr_id
                    FROM jtf_terr_all jt
                    WHERE ( ( NVL(jt.end_date_active, lp_sysdate) <= NVL(p_param4, lp_sysdate) ) OR
                            ( NVL(jt.start_date_active, lp_sysdate) >= NVL(p_param4, lp_sysdate) )
                          )
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = j.terr_id )   ;
    end if;


      -- list from terr_name_cur
      loop
        fetch terr_name_cur into rec_terr;
        exit when terr_name_cur%notfound;
        --dbms_output.put_line('territory cursor rec_terr.terr_id: ' || rec_terr.terr_id);
        terr_rspan_row_number  := 0;
        rsc_access_rspan_row_number := 0;
        tqual_rspan_row_number:= 0;
        qval_rspan_row_number := 0;

        lx_result_tbl.extend;
        l_out_index := l_out_index + 1;
        lx_result_tbl(l_out_index):= l_out_rec;

        lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
        lx_result_tbl(l_out_index).column2 := rec_terr.name;
        lx_result_tbl(l_out_index).column3 := rec_terr.rank;
        lx_result_tbl(l_out_index).column4 := rec_terr.description;
        lx_result_tbl(l_out_index).column12 := rec_terr.start_date_active;
        lx_result_tbl(l_out_index).column13 := rec_terr.end_date_active;
        lx_result_tbl(l_out_index).column14 := rec_terr.last_update_date;

        lx_result_tbl(l_out_index).column15 := l_out_index;
        lx_result_tbl(l_out_index).column19 := 'TERR_PTY';

        lx_result_tbl(l_out_index).column18 := l_terr_operating_unit; -- ADDED FOR BUG 7315889

        terr_rspan_row_number := l_out_index;


        -- list from c_get_qual_types
        qual_type_count := 0;

       IF p_rpt_type <> 'LOOKUP_TERR' THEN
        for rec_qual_type in c_get_qual_types(rec_terr.terr_id) loop
          --dbms_output.put_line('  qual types cursor: rec_qual_type.qual_type_usg_id= '|| rec_qual_type.qual_type_usg_id);
          -- for HTML column formatting
          qual_type_count := qual_type_count + 1;

          lx_result_tbl.extend;
          l_out_index := l_out_index + 1;
          lx_result_tbl(l_out_index):= l_out_rec;

          lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
          lx_result_tbl(l_out_index).column2 := rec_terr.name;
          lx_result_tbl(l_out_index).column3 := rec_terr.rank;
          lx_result_tbl(l_out_index).column12 := rec_terr.start_date_active;
          lx_result_tbl(l_out_index).column13 := rec_terr.end_date_active;
          lx_result_tbl(l_out_index).column14 := rec_terr.last_update_date;

          lx_result_tbl(l_out_index).column4 := rec_qual_type.qual_type_usg_id;
          lx_result_tbl(l_out_index).column5 := rec_qual_type.qualifier_type_description;
          lx_result_tbl(l_out_index).column6 := rec_qual_type.qualifier_type_name;

          lx_result_tbl(l_out_index).column15 := l_out_index;
          lx_result_tbl(l_out_index).column19 := 'QUAL_TYPE';

        end loop;
       END IF; --p_rpt_type <> 'LOOKUP_TERR'

        -- loop through c_get_terr_qual
        terr_qual_count := 0;

        for rec_terr_qual in c_get_terr_qual(rec_terr.terr_id) loop
          --dbms_output.put_line('  tx qual cursor: rec_terr_qual.terr_qual_id =' || rec_terr_qual.TERR_QUAL_ID);
          qual_value_count := 0;

          for rec_qual_value in c_get_terr_values(rec_terr_qual.TERR_QUAL_ID)loop
            --dbms_output.put_line('    qual value cursor rec_qual_value.TERR_VALUE_ID = ' || rec_qual_value.TERR_VALUE_ID);
            l_match_qual := 0;
            qual_value_count := qual_value_count + 1;

            lx_result_tbl.extend;
            l_out_index := l_out_index + 1;
            lx_result_tbl(l_out_index):= l_out_rec;

            if qual_value_count = 1 then
              qval_rspan_row_number := l_out_index;
            end if;

            lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
            lx_result_tbl(l_out_index).column2 := rec_terr.name;
            lx_result_tbl(l_out_index).column3 := rec_terr.rank;

            lx_result_tbl(l_out_index).column4 := rec_terr_qual.qual_usg_id;
            lx_result_tbl(l_out_index).column5 := rec_terr_qual.terr_qual_id;
            lx_result_tbl(l_out_index).column6 := rec_terr_qual.qualifier_name;

            lx_result_tbl(l_out_index).column7 := rec_qual_value.TERR_VALUE_ID;
            lx_result_tbl(l_out_index).column8 := rec_qual_value.COMPARISON_OPERATOR;
            lx_result_tbl(l_out_index).column15 := l_out_index;
            lx_result_tbl(l_out_index).column20 := qval_rspan_row_number;
            lx_result_tbl(l_out_index).column16 := 0;
            lx_result_tbl(l_out_index).column17 := 0;
            lx_result_tbl(l_out_index).column19 := 'QUAL_VAL';

            if qual_value_count = 1 then
              lx_result_tbl(l_out_index).column17 := terr_qual_count;
            else
              lx_result_tbl(l_out_index).column17 := 0;
            end if;

            --lx_result_tbl(l_out_index).column18 := qual_value_count;
            --------------------------------------
            -- Deal with all the display types
            --------------------------------------

            if rec_qual_value.display_type = 'CHAR' then
              if rec_qual_value.CONVERT_TO_ID_FLAG = 'Y' then
                lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_char_desc;
                lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_char_desc;
              else
                lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_char_desc;
                lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_char_desc;
              end if;
            elsif rec_qual_value.display_type = 'INTEREST_TYPE' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.interest_type;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.primary_interest_code;
              lx_result_tbl(l_out_index).column11 := rec_qual_value.secondary_interest_code;
            elsif rec_qual_value.display_type = 'DATE' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_date;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_date;
            elsif rec_qual_value.display_type = 'NUMBER' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_number;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_number;
  -- Fix for bug 6964643. The display type is NUMERIC for the qualifier NO OF EMLOYEES.
            elsif rec_qual_value.display_type = 'NUMERIC' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_number;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_number;
            elsif rec_qual_value.display_type = 'CURRENCY' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_number;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_number;
              lx_result_tbl(l_out_index).column11 := rec_qual_value.currency_desc;
            elsif rec_qual_value.display_type = 'CHAR_2IDS' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.value1_desc;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.value2_desc;
            --elsif rec_qual_value.display_type = 'COMPETENCE' then

            elsif rec_qual_value.display_type = 'DEP_2FIELDS' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.value1_desc;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.value2_desc;

            elsif rec_qual_value.display_type = 'DEP_2FIELDS_CHAR_2IDS' then
              lx_result_tbl(l_out_index).column9  := rec_qual_value.value1_desc;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.value2_desc;

            else
              lx_result_tbl(l_out_index).column9  := rec_qual_value.low_value_char_desc;
              lx_result_tbl(l_out_index).column10 := rec_qual_value.high_value_char_desc;
            end if;
            -- increment qual_value_count
            --qual_value_count := qual_value_count + 1;

            --LOOKUP_TERR processing for CNR
            if p_rpt_type = 'LOOKUP_TERR' and rec_terr_qual.qual_usg_id = -1012 --CNR
            and rec_qual_value.COMPARISON_OPERATOR IN ('BETWEEN','=','LIKE')
            then
              if rec_qual_value.COMPARISON_OPERATOR = 'BETWEEN'
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param3) BETWEEN lx_result_tbl(l_out_index).column9 and lx_result_tbl(l_out_index).column10;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if rec_qual_value.COMPARISON_OPERATOR = '='
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param3) = lx_result_tbl(l_out_index).column9;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if rec_qual_value.COMPARISON_OPERATOR = 'LIKE'
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param3) LIKE lx_result_tbl(l_out_index).column9;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if l_match_qual = 0
              then
                 if qual_value_count = 1 then
                   qval_rspan_row_number := 0;
                 end if;
                 l_out_index := l_out_index - 1;
                 qual_value_count := qual_value_count - 1;
                 lx_result_tbl.trim;
              end if;

            end if;--LOOKUP_TERR processing for CNR

            --LOOKUP_TERR processing for Postal Code
            if p_rpt_type = 'LOOKUP_TERR' and rec_terr_qual.qual_usg_id = -1007 --Postal Code
            and rec_qual_value.COMPARISON_OPERATOR IN ('BETWEEN','=','LIKE')
            then

              if rec_qual_value.COMPARISON_OPERATOR = 'BETWEEN'
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param4) BETWEEN lx_result_tbl(l_out_index).column9 and lx_result_tbl(l_out_index).column10;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if rec_qual_value.COMPARISON_OPERATOR = '='
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param4) = lx_result_tbl(l_out_index).column9;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if rec_qual_value.COMPARISON_OPERATOR = 'LIKE'
              then
                begin
                select 1 into l_match_qual from dual
                where UPPER(p_param4) LIKE lx_result_tbl(l_out_index).column9;

                exception
                when no_data_found then l_match_qual := 0;
                end;

              end if;

              if l_match_qual = 0
              then
                 if qual_value_count = 1 then
                   qval_rspan_row_number := 0;
                 end if;
                 l_out_index := l_out_index - 1;
                 qual_value_count := qual_value_count - 1;
                 lx_result_tbl.trim;
              end if;

            end if;--LOOKUP_TERR processing for Postal Code

          end loop; -- all values
          if qval_rspan_row_number <> 0 then
            lx_result_tbl(qval_rspan_row_number).column17 := qual_value_count;
          end if;
        end loop;  -- all qualifier

        -- loop through c_get_terr_rsc_qual
        terr_rsc_qual_count := 0;

       IF p_rpt_type <> 'LOOKUP_TERR' THEN
        for rec_terr_rsc_qual in c_get_terr_rsc_qual(rec_terr.terr_id) loop
          --dbms_output.put_line('  resource qual cursor rec_terr_rsc_qual.terr_qual_id = ' || rec_terr_rsc_qual.terr_qual_id);
          rsc_qual_value_count := 0;

          for rec_rsc_qual_value in c_get_terr_values(rec_terr_rsc_qual.TERR_qual_ID)loop

            rsc_qual_value_count := rsc_qual_value_count + 1;

            lx_result_tbl.extend;
            l_out_index := l_out_index + 1;
            lx_result_tbl(l_out_index):= l_out_rec;

            if rsc_qual_value_count = 1 then
              qval_rspan_row_number := l_out_index;
            end if;

            lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
            lx_result_tbl(l_out_index).column2 := rec_terr.name;
            lx_result_tbl(l_out_index).column3 := rec_terr.rank;

            lx_result_tbl(l_out_index).column4 := rec_terr_rsc_qual.qual_usg_id;
            lx_result_tbl(l_out_index).column5 := rec_terr_rsc_qual.terr_qual_id;
            lx_result_tbl(l_out_index).column6 := rec_terr_rsc_qual.qualifier_name;

            lx_result_tbl(l_out_index).column7 := rec_rsc_qual_value.TERR_VALUE_ID;
            lx_result_tbl(l_out_index).column8 := rec_rsc_qual_value.COMPARISON_OPERATOR;
            lx_result_tbl(l_out_index).column15 := l_out_index;
            lx_result_tbl(l_out_index).column20 := qval_rspan_row_number;
            lx_result_tbl(l_out_index).column16 := 0;
            lx_result_tbl(l_out_index).column17 := 0;
            lx_result_tbl(l_out_index).column19 := 'RSC_QUAL_VAL';

            if rsc_qual_value_count = 1 then
              lx_result_tbl(l_out_index).column17 := terr_rsc_qual_count;
            else
              lx_result_tbl(l_out_index).column17 := 0;
            end if;

            --lx_result_tbl(l_out_index).column18 := rsc_qual_value_count;

          end loop; -- all values
          if qval_rspan_row_number <> 0 then
            lx_result_tbl(qval_rspan_row_number).column17 := rsc_qual_value_count;
          end if;
        end loop;  -- all rsc rsc_qualifier
       END IF; -- p_rpt_type <> 'LOOKUP_TERR'




        -- list from c_get_resource(current_terr_id)
        resource_count := 0;

       IF p_rpt_type <> 'LOOKUP_TERR' THEN
        for rec_res in c_get_resource(rec_terr.terr_id) loop
          --dbms_output.put_line('  resource cursor: rec_res.resource_id= ' || rec_res.resource_id);
          lx_result_tbl.extend;
          l_out_index := l_out_index + 1;
          lx_result_tbl(l_out_index):= l_out_rec;

          lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
          lx_result_tbl(l_out_index).column2 := rec_terr.name;
          lx_result_tbl(l_out_index).column3 := rec_terr.rank;
          lx_result_tbl(l_out_index).column12 := rec_terr.start_date_active;
          lx_result_tbl(l_out_index).column13 := rec_terr.end_date_active;
          lx_result_tbl(l_out_index).column14 := rec_terr.last_update_date;

          lx_result_tbl(l_out_index).column4 := rec_res.resource_id;
          lx_result_tbl(l_out_index).column5 := rec_res.resource_name;
          lx_result_tbl(l_out_index).column6 := rec_res.terr_rsc_id; --resource_type;

          lx_result_tbl(l_out_index).column15 := l_out_index;
          lx_result_tbl(l_out_index).column19 := 'RESOURCE';
          rsc_access_rspan_row_number := l_out_index;

          -- list from c_get_rsc_access
          rsc_access_count := 0;

          for rec_rsc_access in c_get_rsc_access(rec_res.terr_rsc_id) loop
            --dbms_output.put_line('rsc access cursor ');
            -- for HTML column formatting
            rsc_access_count := rsc_access_count + 1;

            lx_result_tbl.extend;
            l_out_index := l_out_index + 1;
            lx_result_tbl(l_out_index):= l_out_rec;

             --dbms_output.put_line('rec_terr.terr_id =  ' || rec_terr.terr_id);

            lx_result_tbl(l_out_index).column1 := rec_terr.terr_id;
            lx_result_tbl(l_out_index).column2 := rec_terr.name;
            lx_result_tbl(l_out_index).column3 := rec_terr.rank;
            lx_result_tbl(l_out_index).column12 := rec_terr.start_date_active;
            lx_result_tbl(l_out_index).column13 := rec_terr.end_date_active;
            lx_result_tbl(l_out_index).column14 := rec_terr.last_update_date;

            lx_result_tbl(l_out_index).column4 := rec_res.resource_id;
            lx_result_tbl(l_out_index).column5 := rec_res.resource_name;
            lx_result_tbl(l_out_index).column6 := rec_res.terr_rsc_id; --resource_type;

            lx_result_tbl(l_out_index).column7 := rec_rsc_access.terr_rsc_access_id;
            lx_result_tbl(l_out_index).column8 := rec_rsc_access.meaning;

            lx_result_tbl(l_out_index).column15 := l_out_index;
            lx_result_tbl(l_out_index).column19 := 'RSC_ACCESS';
            lx_result_tbl(l_out_index).column16 := 0;
            lx_result_tbl(l_out_index).column17 := 1;


          end loop; -- resource accesses
--          --dbms_output.put_line('setting rsc_access at ' || rsc_access_rspan_row_number || 'rowspan: ' || rsc_access_count);
          if rsc_access_rspan_row_number <> 0 then
            lx_result_tbl(rsc_access_rspan_row_number).column17 := rsc_access_count;
          end if;
        end loop; -- resources
       END IF; -- p_rpt_type <> 'LOOKUP_TERR'

        -- this used to be row span count for resource but now we use in conjunction at bottom
        --lx_result_tbl(terr_rspan_row_number).column16 := resource_count;

-----------------------------


        if terr_rspan_row_number <> 0 then
          lx_result_tbl(terr_rspan_row_number).column16 := l_out_index - terr_rspan_row_number + 1;
        else
          null;
          --dbms_output.put_line('rowspan for row ' || terr_rspan_row_number || ': ' ||(l_out_index - terr_rspan_row_number + 1)  );
        end if;
      end loop; -- all territories
      x_result_tbl := lx_result_tbl;
--dbms_output.put_line('lx_result_tbl.last: ' || lx_result_tbl.last);
--      exception
--        when others then
--            return;


  end DEFINITION_RPT;


  ---------------------------------------------------------------
  --    CHANGES_RPT
  --    Notes: Territory Changes Report
  --    NOT USED SINCE WE CALL DEFINITIONS REPORT
  --
  ---------------------------------------------------------------

  PROCEDURE CHANGES_RPT    (p_param1 in varchar2,
                            p_param2 in varchar2,
                            p_param3 in varchar2,
                            p_param4 in varchar2,
                            p_param5 in varchar2,
                            x_result_tbl OUT NOCOPY report_out_tbl_type)
  IS

  begin
      null;
  end CHANGES_RPT;

  ---------------------------------------------------------------
  --    INTEL_RPT
  --    Notes: Territory Changes Report
  --    NOT CURRENTLY USED AS SQL CALLS MADE FROM JSP
  --    arpatel     11/13      Adding sql calls to INTEL_RPT
  ---------------------------------------------------------------

  PROCEDURE INTEL_RPT    (  p_param1 in varchar2,
                            p_param2 in varchar2,
                            p_param3 in varchar2,
                            p_param4 in varchar2,
                            p_param5 in varchar2,
                            x_result_tbl OUT NOCOPY report_out_tbl_type)
  IS
    lx_result_tbl report_out_tbl_type; -- := report_out_tbl_type();
    l_out_index number :=   0;

    --ACTIVE GLOBAL CURSOR
    cursor c_ACTIVE_GLOBAL IS
    SELECT  'All' name,
             atc.ACTIVE_TERR_COUNT ACTIVE_TERR_COUNT,
             tdac.TERR_DUAL_ASSGN_COUNT TERR_DUAL_ASSGN_COUNT,
             tcc.TERR_CREATED_COUNT TERR_CREATED_COUNT,
             tsdc.TERR_SOFT_DEL_COUNT TERR_SOFT_DEL_COUNT,
             tuc.TERR_UPDATED_COUNT TERR_UPDATED_COUNT,
             arc.ACTIVE_DIST_REP_COUNT ACTIVE_DIST_REP_COUNT,
             ROUND((atc.ACTIVE_TERR_COUNT / decode(arc.ACTIVE_DIST_REP_COUNT, 0, 1, arc.ACTIVE_DIST_REP_COUNT)),2) TERR_PER_REP
    FROM
          -- Total # of Active Territories
         ( SELECT COUNT(*) ACTIVE_TERR_COUNT
           FROM jtf_terr_all jt
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
         ) atc,

          -- Total # of Territories that have Internal and External Reps
         ( SELECT COUNT(*)  TERR_DUAL_ASSGN_COUNT
           FROM  jtf_terr_all jt
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
             AND EXISTS ( SELECT jtr.terr_id
                          FROM jtf_terr_rsc_all jtr
                          WHERE jtr.role IN ('TELESALES_AGENT', 'Telesales Agent', 'TELESALES_MANAGER', 'Telesales Manager', NULL)
                            AND jtr.terr_id = jt.terr_id )
             AND EXISTS ( SELECT jtr.terr_id
                          FROM jtf_terr_rsc_all jtr
                          WHERE jtr.role IN ('SALES_REP', 'Sales Representative', 'SALES_MANAGER', 'Sales Manager', NULL)
                            AND jtr.terr_id = jt.terr_id )
         ) tdac,

          -- Territories created last 7 days
         ( SELECT COUNT(*) TERR_CREATED_COUNT
           FROM jtf_terr_all jt
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
             and jt.creation_date BETWEEN SYSDATE-7 AND SYSDATE+1
         ) tcc,

          -- Total # of (SOFT) DELETED Territories
         ( SELECT COUNT(*) TERR_SOFT_DEL_COUNT
           FROM jtf_terr_all jt
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
             and jt.end_date_active BETWEEN SYSDATE-7 AND SYSDATE+1
         ) tsdc,

          -- Total # of UPDATED Territories
         ( SELECT COUNT(*) TERR_UPDATED_COUNT
           FROM jtf_terr_all jt
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
             and jt.last_update_date BETWEEN SYSDATE-7 AND SYSDATE+1
         ) tuc,

          -- Total Distinct # of People Assigned to Active Territories  -- 2930
   	     ( SELECT COUNT(DISTINCT jtr.resource_id) ACTIVE_DIST_REP_COUNT
           FROM jtf_terr_rsc_all jtr
           WHERE EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.resource_exists_flag = 'Y'
                            AND jtdr.terr_id = jtr.terr_id and jtdr.source_id = p_param2)
         ) arc ;

       --ACTIVE COUNTRY CURSOR
    cursor c_ACTIVE_BY_COUNTRY IS
       SELECT
           houo.name name,
           NVL(atc.ACTIVE_TERR_COUNT, 0)  ACTIVE_TERR_COUNT,
  	       NVL(tdac.TERR_DUAL_ASSGN_COUNT, 0) TERR_DUAL_ASSGN_COUNT,
           NVL(tcc.TERR_CREATED_COUNT, 0) TERR_CREATED_COUNT,
           NVL(tsdc.TERR_SOFT_DEL_COUNT, 0) TERR_SOFT_DEL_COUNT,
           NVL(tuc.TERR_UPDATED_COUNT, 0) TERR_UPDATED_COUNT,
           NVL(arc.ACTIVE_DIST_REP_COUNT, 0) ACTIVE_DIST_REP_COUNT,
           DECODE( arc.ACTIVE_DIST_REP_COUNT
                 , NULL, 'No Active Reps'
                 , ROUND((atc.ACTIVE_TERR_COUNT / arc.ACTIVE_DIST_REP_COUNT), 2)
                 )  TERR_PER_REP

       FROM
         hr_organization_units houo,
         -- Total # of Active Territories  -- 13918
         ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(*) ACTIVE_TERR_COUNT
           FROM jtf_terr_all jt, hr_organization_units hou
           WHERE jt.org_id = hou.organization_id
             AND EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.terr_id = jt.terr_id and jtdr.source_id = p_param2)
           GROUP BY hou.name, hou.organization_id
         ) atc,

         -- Total # of Territories that have Internal and External Reps
         ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(*) TERR_DUAL_ASSGN_COUNT
           FROM jtf_terr_all jt, hr_organization_units hou
           WHERE jt.org_id = hou.organization_id
             AND EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.terr_id = jt.terr_id and jtdr.source_id = p_param2)
             AND EXISTS ( SELECT jtr.terr_id
                          FROM jtf_terr_rsc_all jtr
                          WHERE jtr.role IN ('TELESALES_AGENT', 'Telesales Agent', 'TELESALES_MANAGER', 'Telesales Manager', NULL)
                            AND jtr.terr_id = jt.terr_id )
             AND EXISTS ( SELECT jtr.terr_id
                          FROM jtf_terr_rsc_all jtr
                          WHERE jtr.role IN ('SALES_REP', 'Sales Representative', 'SALES_MANAGER', 'Sales Manager', NULL)
                            AND jtr.terr_id = jt.terr_id )
           GROUP BY hou.name, hou.organization_id
         ) tdac,

         -- Territories created last 7 days
        ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(*) TERR_CREATED_COUNT
          FROM jtf_terr_all jt, hr_organization_units hou
          WHERE jt.org_id = hou.organization_id
            and EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
            AND jt.creation_date BETWEEN SYSDATE-7 AND SYSDATE+1
          GROUP BY hou.name, hou.organization_id
         ) tcc,

         -- Total # of (SOFT) DELETED Territories
        ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(*) TERR_SOFT_DEL_COUNT
          FROM jtf_terr_all jt, hr_organization_units hou
          WHERE jt.org_id = hou.organization_id
            and EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
            AND jt.END_DATE_ACTIVE BETWEEN SYSDATE-7 AND SYSDATE+1
          GROUP BY hou.name, hou.organization_id
         ) tsdc,

         -- Total # of UPDATED Territories
         ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(*) TERR_UPDATED_COUNT
           FROM jtf_terr_all jt, hr_organization_units hou
           WHERE jt.org_id = hou.organization_id
             and EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.source_id = p_param2 and jtdr.terr_id = jt.terr_id )
             AND jt.LAST_UPDATE_DATE BETWEEN SYSDATE-7 AND SYSDATE+1
           GROUP BY hou.name, hou.organization_id
         ) tuc,

         -- Total Distinct # of People Assigned to  Territories  -- 2930
         ( SELECT
              hou.name,
              hou.organization_id,
              COUNT(DISTINCT jtr.resource_id) ACTIVE_DIST_REP_COUNT
           FROM jtf_terr_rsc_all jtr, hr_organization_units hou
           WHERE jtr.org_id = hou.organization_id
             AND EXISTS ( SELECT jtdr.terr_id
                          FROM jtf_terr_denorm_rules_all jtdr
                          WHERE jtdr.resource_exists_flag = 'Y'
                            AND jtdr.terr_id = jtr.terr_id and jtdr.source_id = p_param2)

           GROUP BY hou.name, hou.organization_id
         ) arc
    WHERE
          houo.organization_id = atc.organization_id
      AND houo.organization_id = tdac.organization_id(+)
      AND houo.organization_id = tcc.organization_id(+)
      AND houo.organization_id = tsdc.organization_id(+)
      AND houo.organization_id = tuc.organization_id(+)
      AND houo.organization_id = arc.organization_id(+)
    ORDER BY atc.ACTIVE_TERR_COUNT DESC;

    cursor c_NONACTIVE_GLOBAL IS
    SELECT 'All' name,
          COUNT(*) INACTIVE_TERR_COUNT
    FROM  jtf_terr_all jt
    WHERE
      exists (  select jtua.terr_id
                from jtf_terr_usgs_all jtua
                where jtua.source_id = p_param2 and jtua.terr_id = jt.terr_id)
      and NOT EXISTS ( SELECT jtdr.terr_id
                       FROM jtf_terr_denorm_rules_all jtdr
                       WHERE jtdr.terr_id = jt.terr_id );

    cursor c_NONACTIVE_BY_COUNTRY IS
    SELECT
         hou.name name,
         COUNT(*) INACTIVE_TERR_COUNT,
         hou.organization_id org_id
    FROM  jtf_terr_all jt, hr_organization_units hou
    WHERE jt.org_id = hou.organization_id
     and exists (  select jtua.terr_id
            from jtf_terr_usgs_all jtua
            where jtua.source_id = p_param2 and jtua.terr_id = jt.terr_id)
     AND NOT EXISTS ( SELECT jtdr.terr_id
                      FROM jtf_terr_denorm_rules_all jtdr
                      WHERE jtdr.terr_id = jt.terr_id )
    GROUP BY hou.name, hou.organization_id
    ORDER BY INACTIVE_TERR_COUNT DESC;

  begin

    lx_result_tbl := report_out_tbl_type();
    l_out_index := 0;
--dbms_output.put_line('p_param1= ' || p_param1);
--dbms_output.put_line('p_param2= ' || p_param2);

    If p_param1 = 'ACTIVE_GLOBAL' then
      --dbms_output.put_line('ACTIVE_GLOBAL');

      for actglobal_type in c_ACTIVE_GLOBAL
      loop
        l_out_index := l_out_index + 1;
        lx_result_tbl.extend;
        lx_result_tbl(l_out_index).column1 := actglobal_type.name;
        lx_result_tbl(l_out_index).column2 := actglobal_type.ACTIVE_TERR_COUNT;
        lx_result_tbl(l_out_index).column3 := actglobal_type.TERR_DUAL_ASSGN_COUNT;
        lx_result_tbl(l_out_index).column4 := actglobal_type.TERR_CREATED_COUNT;
        lx_result_tbl(l_out_index).column5 := actglobal_type.TERR_SOFT_DEL_COUNT;
        lx_result_tbl(l_out_index).column6 := actglobal_type.TERR_UPDATED_COUNT;
        lx_result_tbl(l_out_index).column7 := actglobal_type.ACTIVE_DIST_REP_COUNT;
        lx_result_tbl(l_out_index).column8 := actglobal_type.TERR_PER_REP;
      end loop;

    elsif p_param1 = 'ACTIVE_BY_COUNTRY' then
      --dbms_output.put_line('ACTIVE_BY_COUNTRY');

      for actcountry_type in c_ACTIVE_BY_COUNTRY
      loop
        l_out_index := l_out_index + 1;
        lx_result_tbl.extend;
        lx_result_tbl(l_out_index).column1 := actcountry_type.name;
        lx_result_tbl(l_out_index).column2 := actcountry_type.ACTIVE_TERR_COUNT;
        lx_result_tbl(l_out_index).column3 := actcountry_type.TERR_DUAL_ASSGN_COUNT;
        lx_result_tbl(l_out_index).column4 := actcountry_type.TERR_CREATED_COUNT;
        lx_result_tbl(l_out_index).column5 := actcountry_type.TERR_SOFT_DEL_COUNT;
        lx_result_tbl(l_out_index).column6 := actcountry_type.TERR_UPDATED_COUNT;
        lx_result_tbl(l_out_index).column7 := actcountry_type.ACTIVE_DIST_REP_COUNT;
        lx_result_tbl(l_out_index).column8 := actcountry_type.TERR_PER_REP;
      end loop;


    elsif p_param1 = 'NONACTIVE_GLOBAL' then
      --dbms_output.put_line('NONACTIVE_GLOBAL');

      for nonactglobal_type in c_NONACTIVE_GLOBAL
      loop
        l_out_index := l_out_index + 1;
        lx_result_tbl.extend;
        lx_result_tbl(l_out_index).column1 := nonactglobal_type.name;
        lx_result_tbl(l_out_index).column2 := nonactglobal_type.INACTIVE_TERR_COUNT;
      end loop;

    elsif p_param1 = 'NONACTIVE_BY_COUNTRY' then
      --dbms_output.put_line('NONACTIVE_BY_COUNTRY');

      for nonactcountry_type in c_NONACTIVE_BY_COUNTRY
      loop
        l_out_index := l_out_index + 1;
        lx_result_tbl.extend;
        lx_result_tbl(l_out_index).column1 := nonactcountry_type.name;
        lx_result_tbl(l_out_index).column2 := nonactcountry_type.INACTIVE_TERR_COUNT;
        lx_result_tbl(l_out_index).column3 := nonactcountry_type.org_id;
      end loop;
    end if;

    x_result_tbl := lx_result_tbl;

  end INTEL_RPT;

  ---------------------------------------------------------------
  --    SYSTEM_INFO_RPT
  --    Notes: Territory System Information Report
  --
  ---------------------------------------------------------------

  PROCEDURE SYSTEM_INFO_RPT(p_param1 in varchar2,
                            p_param2 in varchar2,
                            p_param3 in varchar2,
                            p_param4 in varchar2,
                            p_param5 in varchar2,
                            x_result_tbl OUT NOCOPY report_out_tbl_type)
  IS
    lx_result_tbl report_out_tbl_type := report_out_tbl_type();
    l_out_index   number := 0;


  begin
    -- TERR_ADMINS
    lx_result_tbl.extend();
    l_out_index := l_out_index + 1;
    lx_result_tbl(l_out_index).column1 := 'TERR_ADMIN_COUNT';
    lx_result_tbl(l_out_index).column2 := 'FAKE_TERR_ADMIN_COUNT';

    -- TERR_ADMIN_LOGINS
    lx_result_tbl.extend();
    l_out_index := l_out_index + 1;
    lx_result_tbl(l_out_index).column1 := 'TERR_ADMIN_LOGINS';
    lx_result_tbl(l_out_index).column2 := 'FAKE_TERR_ADMIN_LOGINS';

    -- LOOKUP_USERS
    lx_result_tbl.extend();
    l_out_index := l_out_index + 1;
    lx_result_tbl(l_out_index).column1 := 'LOOKUP_USER_COUNT';
    lx_result_tbl(l_out_index).column2 := 'FAKE_LOOKUP_USER_COUNT';

    -- LOOKUP_USER_LOGINS
    lx_result_tbl.extend();
    l_out_index := l_out_index + 1;
    lx_result_tbl(l_out_index).column1 := 'LOOKUP_USER_LOGINS';
    lx_result_tbl(l_out_index).column2 := 'FAKE_LOOKUP_USER_LOGINS';


    -- TIME
    lx_result_tbl.extend();
    l_out_index := l_out_index + 1;
    lx_result_tbl(l_out_index).column1 := 'TIME';
    lx_result_tbl(l_out_index).column2 := 'FAKE_TIME';

    x_result_tbl := lx_result_tbl;

  end SYSTEM_INFO_RPT;



  ---------------------------------------------------------------
  --    REPORT_CONTROL
  --    Notes: Directs call to proper report generator.
  --
  --
  ---------------------------------------------------------------
  PROCEDURE REPORT_CONTROL (p_report in varchar2,
                            p_param1 in varchar2,
                            p_param2 in varchar2,
                            p_param3 in varchar2,
                            p_param4 in varchar2,
                            p_param5 in varchar2,
                            x_result_tbl OUT NOCOPY report_out_tbl_type)
  IS

  begin
  --dbms_output.put_line('REPORT_CONTROL ');
    if p_report = 'DEFINITION' then

        DEFINITION_RPT( p_param1 => p_param1,  -- resource_id
                        p_param2 => p_param2,  -- qual_usg_id
                        p_param3 => p_param3,  -- source_id
                        p_param4 => p_param4,  -- active on
                        p_param5 => p_param5,  -- optional terr_id
                        p_rpt_type => 'DEFINITION',
                        x_result_tbl => x_result_tbl);

    elsif p_report = 'CHANGES' then
      --dbms_output.put_line(' CHANGES');
        DEFINITION_RPT( p_param1 => p_param1,  -- optional last_update_date >= this
                        p_param2 => p_param2,  -- last_update_date <= this
                        p_param3 => p_param3,  -- optional source_id
                        p_param4 => p_param4,  -- active on
                        p_param5 => p_param5,
                        p_rpt_type => 'CHANGES',
                        x_result_tbl => x_result_tbl);

    elsif p_report = 'INTEL' then
        --dbms_output.put_line('p_report = INTEL');
        INTEL_RPT(      p_param1 => p_param1,
                        p_param2 => p_param2,
                        p_param3 => p_param3,
                        p_param4 => p_param4,
                        p_param5 => p_param5,
                        x_result_tbl => x_result_tbl);

    elsif p_report = 'LOOKUP_TERR' then
        --dbms_output.put_line('p_report = LOOKUP_TERR');
        DEFINITION_RPT( p_param1 => p_param1,
                        p_param2 => p_param2,
                        p_param3 => p_param3,
                        p_param4 => p_param4,
                        p_param5 => p_param5,
                        p_rpt_type => 'LOOKUP_TERR',
                        x_result_tbl => x_result_tbl);

    elsif p_report = 'SYSTEM_INFO' then
        SYSTEM_INFO_RPT(p_param1 => p_param1,
                        p_param2 => p_param2,
                        p_param3 => p_param3,
                        p_param4 => p_param4,
                        p_param5 => p_param5,
                        x_result_tbl => x_result_tbl);

    end if; -- which report do we call?
  end REPORT_CONTROL;

end;

/
