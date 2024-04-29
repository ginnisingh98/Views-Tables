--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DIAGNOSTIC_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DIAGNOSTIC_TEST" AS
/* $Header: jtftrdtb.pls 120.3 2007/12/17 14:54:20 vpalle ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstgb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is for general territory testing                     |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 26-Sept-2002   arpatel          Created.                              |
 +======================================================================*/

  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executed prior to test run - leave body as null otherwize
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   -- test writer could insert special setup code here
   null;
  END init;

 ------------------------------------------------------------
 -- procedure to cleanup any  test datastructures that were setup in the init
-- procedure call executes after test run - leave body as null otherwize
------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
   -- test writer could insert special cleanup code here
   NULL;
  END cleanup;

  ------------------------------------------------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are
-- returned.
------------------------------------------------------------
 PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                    report OUT NOCOPY JTF_DIAG_REPORT,
                    reportClob OUT NOCOPY CLOB) IS

     --sql stmt vars
     l_active_sales_terrs VARCHAR2(360);
     l_terr_res_assign    VARCHAR2(360);
     l_active_reps        VARCHAR2(360);
     l_num_values         VARCHAR2(360);
     l_parties            VARCHAR2(360);
     l_party_sites        VARCHAR2(360);
     l_locations          VARCHAR2(360);
     l_lookup_code        VARCHAR2(360);
     l_meaning            VARCHAR2(360);
     l_source_id          NUMBER;
     l_percent_count      NUMBER;
     l_terr_with_inv_res  NUMBER;

     --framwork vars
     reportStr LONG;
     counter   NUMBER;
     c_userid  VARCHAR2(50);
     statusStr VARCHAR2(50);
     errStr    VARCHAR2(4000);
     fixInfo   VARCHAR2(4000);
     isFatal   VARCHAR2(50);

     CURSOR C_valid_terrs(lc_source_id NUMBER)
     IS
     select qta.description name, count(*) terr_count
     from jtf_terr_denorm_rules_all jtdr
        , jtf_qual_types qta
     where jtdr.source_id = lc_source_id
      and jtdr.terr_id = jtdr.related_terr_id
      and jtdr.qual_type_id = qta.qual_type_id
     group by qta.description
     order by 1;

     CURSOR C_valid_terrs_with_reps(lc_source_id NUMBER)
     IS
     select qta.description name, count(*) terr_count
     from jtf_terr_denorm_rules_all jtdr
        , jtf_qual_types_all qta
     where jtdr.source_id = lc_source_id
      and jtdr.terr_id = jtdr.related_terr_id
      and jtdr.qual_type_id = qta.qual_type_id
      and jtdr.resource_exists_flag = 'Y'
     group by qta.description
     order by 1;

     CURSOR C_num_values(lc_source_id NUMBER)
     IS
     select seed.name, count(*) value_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_seeded_qual_all_b seed
         , jtf_qual_usgs_all jqu
     where jtv.terr_qual_id = jtq.terr_qual_id
       and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
                                                   jtf_terr_usgs_all jtu
                            where jtu.source_id = lc_source_id
                              and jtu.terr_id = jt.terr_id
                              and jt.start_date_active <= SYSDATE
                              and NVL(jt.end_date_active, SYSDATE) >= SYSDATE  )
       and jtq.qual_usg_id = jqu.qual_usg_id
       and jqu.seeded_qual_id = seed.seeded_qual_id
       and jqu.org_id = -3113
       and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name
      order by 2 desc;

      CURSOR C_num_values_ALL(lc_source_id NUMBER)
      IS
      select seed.name, count(*) value_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_seeded_qual_all_b seed
         , jtf_qual_usgs_all jqu
     where jtv.terr_qual_id = jtq.terr_qual_id
       and jtq.qual_usg_id = jqu.qual_usg_id
       and jqu.seeded_qual_id = seed.seeded_qual_id
       and jqu.org_id = -3113
       and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name
      order by 2 desc;

      CURSOR C_values_in_MV
      IS
      select seed.name, count(*) value_count
      from ( SELECT /*+ ORDERED */
		  r.rowid rule_rowid
		, q.rowid qual_rowid
		, v.rowid val_rowid
		, r.terr_id terr_id
		, r.absolute_rank absolute_rank
		, r.related_terr_id related_terr_id
		, r.top_level_terr_id top_level_terr_id
		, r.num_winners num_winners
		, r.source_id source_id
		, q.terr_qual_id terr_qual_id
		, q.qual_usg_id qual_usg_id
		, v.terr_value_id  terr_value_id
		, v.comparison_operator comparison_operator
		, v.low_value_char_id low_value_char_id
	   FROM jtf_terr_denorm_rules_all r
	        , jtf_terr_qual_all q
 	        , jtf_terr_values_all v
	   WHERE r.source_id = -1001
		  AND q.terr_id = r.related_terr_id
		  AND v.terr_qual_id = q.terr_qual_id
		  AND q.qual_usg_id <> -1102
		  AND NOT ( q.qual_usg_id = -1012 AND
		            ( v.comparison_operator = 'LIKE' OR v.comparison_operator = 'BETWEEN' )
		          )) mv
         , jtf_qual_usgs_all jqu
         , jtf_seeded_qual_all_b seed
      where mv.qual_usg_id = jqu.qual_usg_id
        and jqu.seeded_qual_id = seed.seeded_qual_id
        and jqu.org_id = -3113
        and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name
      order by 2 desc;

      CURSOR C_values_in_System(lc_source_id NUMBER)
      IS
      select seed.name, jtv.comparison_operator operator, count(*) value_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_qual_usgs_all jqu
         , jtf_seeded_qual_all_b seed
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
                      jtf_terr_usgs_all jtu
                      where jtu.source_id = lc_source_id
                        and jtu.terr_id = jt.terr_id
                        and jt.start_date_active <= SYSDATE
                        AND NVL(jt.end_date_active, SYSDATE) >= SYSDATE  )
        and jtq.qual_usg_id = jqu.qual_usg_id
        and jqu.seeded_qual_id = seed.seeded_qual_id
        and jqu.org_id = -3113
        and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name, jtv.comparison_operator
      order by 3 desc;

      CURSOR C_values_in_system_ALL(lc_source_id NUMBER)
      IS
      select seed.name, jtv.comparison_operator operator, count(*) value_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_qual_usgs_all jqu
         , jtf_seeded_qual_all_b seed
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.qual_usg_id = jqu.qual_usg_id
        and jqu.seeded_qual_id = seed.seeded_qual_id
        and jqu.org_id = -3113
        and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name, jtv.comparison_operator
      order by 3 desc;

      CURSOR C_values_in_System_warnings(lc_source_id NUMBER)
      IS
      select jta.name terr_name ,seed.name qual_name, jtv.comparison_operator operator, count(*) value_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_terr_all jta
         , jtf_qual_usgs_all jqu
         , jtf_seeded_qual_all_b seed
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
          jtf_terr_usgs_all jtu
                      where jtu.source_id = lc_source_id
                        and jtu.terr_id = jt.terr_id
                        and jt.start_date_active <= SYSDATE
                        AND NVL(jt.end_date_active, SYSDATE) >= SYSDATE  )
        and jtq.qual_usg_id = jqu.qual_usg_id
        and jqu.seeded_qual_id = seed.seeded_qual_id
        and jta.terr_id = jtq.terr_id
        and jqu.org_id = -3113
        and (seed.org_id = -3114 OR seed.org_id is null)
        and UPPER(jtv.comparison_operator) NOT IN ('=','LIKE','BETWEEN')
      group by jta.name, seed.name, jtv.comparison_operator
      order by 3 desc;

      CURSOR C_values_in_MV_per_qual
      IS
      select seed.name, mv.comparison_operator operator, count(*) value_count
      from  ( SELECT /*+ ORDERED */
		  r.rowid rule_rowid
		, q.rowid qual_rowid
		, v.rowid val_rowid
		, r.terr_id terr_id
		, r.absolute_rank absolute_rank
		, r.related_terr_id related_terr_id
		, r.top_level_terr_id top_level_terr_id
		, r.num_winners num_winners
		, r.source_id source_id
		, q.terr_qual_id terr_qual_id
		, q.qual_usg_id qual_usg_id
		, v.terr_value_id  terr_value_id
		, v.comparison_operator comparison_operator
		, v.low_value_char_id low_value_char_id
	   FROM jtf_terr_denorm_rules_all r
	        , jtf_terr_qual_all q
 	        , jtf_terr_values_all v
	   WHERE r.source_id = -1001
		  AND q.terr_id = r.related_terr_id
		  AND v.terr_qual_id = q.terr_qual_id
		  AND q.qual_usg_id <> -1102
		  AND NOT ( q.qual_usg_id = -1012 AND
		            ( v.comparison_operator = 'LIKE' OR v.comparison_operator = 'BETWEEN' )
		          )) mv
         , jtf_qual_usgs_all jqu
         , jtf_seeded_qual_all_b seed
      where mv.qual_usg_id = jqu.qual_usg_id
      and jqu.seeded_qual_id = seed.seeded_qual_id
      and jqu.org_id = -3113
      and (seed.org_id = -3114 OR seed.org_id is null)
      group by seed.name, mv.comparison_operator
      order by 3 desc;

      CURSOR C_Usages IS
      select source_id, meaning, lookup_code
      from jtf_sources_all
      order by 1 desc;

   BEGIN

    --This set-up of the CLOB must be done
    JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
    JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

    JTF_DIAGNOSTIC_COREAPI.line_out('SUMMARY WARNING INFORMATION');
    JTF_DIAGNOSTIC_COREAPI.line_out('========================================================');
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    for sources in C_Usages loop

      l_source_id := sources.source_id;
      l_lookup_code := sources.lookup_code;
      l_meaning := sources.meaning;

      --show warnings for each usage here
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;WARNINGS for '||l_meaning);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;------------------------------------------------------------');
    JTF_DIAGNOSTIC_COREAPI.brprint;

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;1. '||l_meaning||' qualifiers using non-performant operators: ');

    for vals_in_system in C_values_in_system_warnings(l_source_id)
    loop
      if C_values_in_system_warnings%notfound
      then
        JTF_DIAGNOSTIC_COREAPI.line_out('NONE');
      end if;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Territory = ' ||vals_in_system.terr_name ||'; Qualifier = ' || vals_in_system.qual_name);
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||
                                      '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||
                                      ' Operator = '''|| vals_in_system.operator||'''');
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

      select count(*)
      into l_percent_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_qual_usgs_all jqu
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
            jtf_terr_usgs_all jtu
                      where jtu.source_id = l_source_id
                        and jtu.terr_id = jt.terr_id
                        and jt.start_date_active <= SYSDATE
                        AND NVL(jt.end_date_active, SYSDATE) >= SYSDATE  )
        and jtq.qual_usg_id = jqu.qual_usg_id
        and jqu.org_id = -3113
        and SUBSTR(jtv.low_value_char,0,1) = '%'
        and jtv.comparison_operator = 'LIKE';

      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;2. No. of '||l_meaning||' qualifier values using % as a first char = '||l_percent_count);
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;



    end loop;

    JTF_DIAGNOSTIC_COREAPI.brprint;

    JTF_DIAGNOSTIC_COREAPI.line_out('GENERAL INFORMATION');
    JTF_DIAGNOSTIC_COREAPI.line_out('========================================================');
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --Total Number of Parties
    --===========================
    SELECT COUNT(*)
    into l_parties
    FROM hz_parties;

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Total Number of Parties = '||l_parties);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --Total Number of Party Sites
    --================================
    SELECT COUNT(*)
    into l_party_sites
    FROM hz_party_sites;

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Total Number of Party Sites = '||l_party_sites);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --Total Number of Locations
    --==============================
    SELECT COUNT(*)
    into l_locations
    FROM hz_locations;

    JTF_DIAGNOSTIC_COREAPI.line_out( '&nbsp;&nbsp;Total Number of Locations = '||l_locations);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    JTF_DIAGNOSTIC_COREAPI.brprint;

  -- for Usage specific information
  for sources in C_Usages loop

    l_source_id := sources.source_id;
    l_lookup_code := sources.lookup_code;
    l_meaning := sources.meaning;

    JTF_DIAGNOSTIC_COREAPI.line_out('USAGE: '||l_meaning);
    JTF_DIAGNOSTIC_COREAPI.line_out('========================================================');
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --show warnings for each usage here
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;WARNINGS');
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;--------------------------------------------------------');
    JTF_DIAGNOSTIC_COREAPI.brprint;

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;1. '||l_meaning||' qualifiers using non-performant operators: ');

    for vals_in_system in C_values_in_system_warnings(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Territory = ' ||vals_in_system.terr_name ||'; Qualifier = ' || vals_in_system.qual_name);
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||
                                      '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||
                                      ' Operator = '''|| vals_in_system.operator||'''');
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

      select count(*)
      into l_percent_count
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
         , jtf_qual_usgs_all jqu
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
            jtf_terr_usgs_all jtu
                      where jtu.source_id = l_source_id
                        and jtu.terr_id = jt.terr_id
                        and jt.start_date_active <= SYSDATE
                        AND NVL(jt.end_date_active, SYSDATE) >= SYSDATE  )
        and jtq.qual_usg_id = jqu.qual_usg_id
        and jqu.org_id = -3113
        and SUBSTR(jtv.low_value_char,0,1) = '%'
        and jtv.comparison_operator = 'LIKE';

      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;2. No. of '||l_meaning||' qualifier values using % as a first char = '||l_percent_count);
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --show other informational info here...
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;ADDITIONAL INFORMATION');
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;--------------------------------------------------------');
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --#1. Number of ACTIVE Territories
    --======================================
    select count(*)
    into l_active_sales_terrs
    from jtf_terr_all jta, jtf_terr_usgs_all jtua
    where jtua.terr_id = jta.terr_id
      and jtua.source_id = l_source_id
      and jta.start_date_active <= SYSDATE
      AND NVL(jta.end_date_active, SYSDATE) >= SYSDATE;

      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;1. Number of ACTIVE '||l_meaning||' Territories = '||l_active_sales_terrs);
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#2. Number of VALID Territories for Assignment
    --====================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;2. Number of ACTIVE '||l_meaning||' Territories VALID for Assignment: ');

    for sales_terr in C_valid_terrs(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Transaction Type = ' || sales_terr.name || ', Territory Count = ' || sales_terr.terr_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#3. Number of VALID Sales Territories with Reps for Assignment
    --==============================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;3. Number of ACTIVE '||l_meaning||' Territories VALID for Assignment, with Reps: ');

    for sales_terr_with_rep in C_valid_terrs_with_reps(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;Transaction Type = ' || sales_terr_with_rep.name || ', Territory Count = ' || sales_terr_with_rep.terr_count);
  end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#4. Total Number of Values in System
    --=====================================
      select count(*)
      into l_num_values
      from jtf_terr_values_all jtv, jtf_terr_qual_all jtq
      where jtv.terr_qual_id = jtq.terr_qual_id
        and jtq.terr_id IN ( select jt.terr_id from jtf_terr_all jt,
          jtf_terr_usgs_all jtu
                      where jtu.source_id = l_source_id
                        and jtu.terr_id = jt.terr_id
                        and jt.start_date_active <= SYSDATE
                        AND NVL(jt.end_date_active, SYSDATE + 1) >= SYSDATE  );

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;4. Number of Values for ACTIVE '||l_meaning||' Territories = '||l_num_values);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;


    --#5. Total # of Territory Resource Assignments
    --=============================================
    select count(*)
    into l_terr_res_assign
    from jtf_terr_rsc_all jtr
    where jtr.start_date_active <= SYSDATE
      AND NVL(jtr.end_date_active, SYSDATE) >= SYSDATE
      AND EXISTS ( SELECT jtdr.terr_id
                  FROM jtf_terr_denorm_rules_all jtdr
                  WHERE jtdr.source_id = l_source_id );

    JTF_DIAGNOSTIC_COREAPI.line_out( '&nbsp;&nbsp;5. Number of ACTIVE '||l_meaning||' Territory Resource Assignments = '||l_terr_res_assign);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --#6. Total # of DISTINCT Territory Resources (Total # of Active Reps)
    --====================================================================
    SELECT COUNT (*)
    into l_active_reps FROM (
    select DISTINCT jtr.resource_id, jtr.resource_type
    from    jtf_terr_rsc_all jtr
    where jtr.start_date_active <= SYSDATE
      AND NVL(jtr.end_date_active, SYSDATE) >= SYSDATE
      AND EXISTS ( SELECT jtdr.terr_id
                  FROM jtf_terr_denorm_rules_all jtdr
                  WHERE jtdr.source_id = l_source_id ) );

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;6. Number of ACTIVE '||l_meaning||' Territory Resources (Total # of Active Reps) = '||l_active_reps);
    JTF_DIAGNOSTIC_COREAPI.brprint;
    JTF_DIAGNOSTIC_COREAPI.brprint;

    --#7. Total Number of Values per each Qualifier in System
    --========================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;7. Number of ALL values for each '||l_meaning||' Qualifier: ');

    for num_values_rec in C_num_values_ALL(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||num_values_rec.name || ' = ' || num_values_rec.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#8. Total Number of Values per each Qualifier Operator in System
    --=================================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;8. Number of ALL values for each '||l_meaning||' Qualifier, per operator: ');

    for vals_in_system in C_values_in_system_ALL(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||vals_in_system.name || ' with '''||vals_in_system.operator ||''' Operator = '||vals_in_system.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#9. Total Number of Values per each Qualifier in System
    --========================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;9. Number of ACTIVE values for each '||l_meaning||' Qualifier: ');

    for num_values_rec in C_num_values(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||num_values_rec.name || ' = ' || num_values_rec.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

    --#10. Total Number of Values per each Qualifier Operator in System
    --=================================================================

    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;10. Number of ACTIVE values for each '||l_meaning||' Qualifier, per operator: ');

    for vals_in_system in C_values_in_system(l_source_id)
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||vals_in_system.name || ' with '''||vals_in_system.operator ||''' Operator = '||vals_in_system.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;


    if l_source_id = -1001 then --sales
      --Total Number of values per Qualifier in MV
    --==============================================
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;11. Number of values for each Qualifier in MV (only for '||l_meaning||') : ');

    for vals_in_MV in C_values_in_MV
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||vals_in_MV.name || ' = ' || vals_in_MV.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;


    --Total Number of Values per each Qualifier Operator in MV
    --=============================================================
    JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;12. Number of Values for each Qualifier, per operator in MV (only for '||l_meaning||') : ');

    for vals_in_MV_per_qual in C_values_in_MV_per_qual
    loop
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.line_out('&nbsp;&nbsp;'||vals_in_MV_per_qual.name || ' with '''|| vals_in_MV_per_qual.operator||''' Operator = '|| vals_in_MV_per_qual.value_count);
    end loop;
      JTF_DIAGNOSTIC_COREAPI.brprint;
      JTF_DIAGNOSTIC_COREAPI.brprint;

  end if;
     JTF_DIAGNOSTIC_COREAPI.brprint;
 end loop;

       statusStr := 'SUCCESS';
         reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
         report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    EXCEPTION when others then
      JTF_DIAGNOSTIC_COREAPI.ERRORPRINT(sqlerrm);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
         report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport('FAILURE','Exception thrown',fixInfo,isFatal);
   END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Territory Diagnostics Tests ';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
  BEGIN
    descStr := 'Territory set-up information using various criteria';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Territory set-up information';
  END getTestName;


END JTF_TERR_DIAGNOSTIC_TEST;



/
