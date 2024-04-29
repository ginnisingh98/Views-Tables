--------------------------------------------------------
--  DDL for Package Body JTF_TERR_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_RPT" AS
/* $Header: jtftrtrb.pls 115.14 2004/01/09 00:35:24 vxsriniv ship $ */
--    Start of Comments
--    PURPOSE
--      Custom Assignment API
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      03/18/02    SGKUMAR  Created
--      03/20/02    SGKUMAR  added new procedure insert_qualifiers
--      03/20/02    SGKUMAR  added new procedure set_winners
--      03/20/02    SGKUMAR  added new procedure get_winners
--      04/12/02    SGKUMAR  added code to initialize resource name
--                           territory name, etc
--      04/15/02    SGKUMAR  removed resource and group related data
--      05/29/02    JDOCHERT  changed sql for parties to dynamic sql
--      05/29/02    SGKUMAR  support for shuttle
--      05/30/02    SGKUMAR  changed code for getting only active terr
--                           if parent terr made inactive
--    End of Comments
----
/* Description: inserts qualifier data from staging table to          */
/*              jtf_tae_rpt_objs                                    */
/* Usage: public procedure , should be invoked when the staging table */        /*        is populated                                                */


PROCEDURE cleanup
as
begin
 delete from jtf.jtf_tae_rpt_staging_out
 where  session_id  in (select session_id from APPS.icx_sessions
                        where disabled_flag <> 'N');

 delete from APPS.jtf_tae_rpt_staging_out
 where  session_id  not in (select session_id from APPS.icx_sessions);

 commit;

end cleanup;

PROCEDURE get_keyword_parties(p_session_id number,
                      p_terr_id number)
as

  l_dyn_str VARCHAR2(8000);

BEGIN
  -- delete previous data for the older dead sessions
  cleanup;
  delete from jtf_tae_rpt_staging_out
  where session_id = p_session_id;

   l_dyn_str :=
   ' insert into jtf_tae_rpt_staging_out ' ||
   '   (TRANS_OBJECT_ID, ' ||
   '    TRANS_DETAIL_OBJECT_ID, ' ||
   '    SOURCE_ID,' ||
   '    TRANS_OBJECT_TYPE_ID, ' ||
   '    TERR_ID,' ||
   '    session_id, ' ||
   '    at_char01, ' ||
   '    at_char02, ' ||
   '    low_value_char ' ||
   '    ) ' ||
   'select ' ||
   '     ROW_NUMBER() OVER (ORDER BY ilv.low_value_char, ilv.org_name, ilv.org_address) ' ||
   '     AS PSEUDO_ROWNUM,         ' ||
   '     -999, ' ||
   '     -999, ' ||
   '     -999, ' ||
   '     :p_terr_id1, ' ||
   '     :p_session_id, ' ||
   '     ilv.org_name, ' ||
   '     ilv.org_address, ' ||
   '     ilv.low_value_char         ' ||
   ' FROM ( ' ||
   '       SELECT ' ||
   '         Q1012.low_value_char, Q1012.high_value_char ' ||
   '       , hzp.party_name org_name ' ||
   '       , hzl.address1 || '', '' || hzl.address2 || '', '' || ' ||
   '         hzl.city || '', '' || hzl.state ' ||
   '         || '', '' || hzl.postal_code org_address ' ||
   '       FROM  ' ||
   '             APPS.jtf_terr_qual_rules_mv Q1007R1 ' ||
   '           , APPS.jtf_terr_qual_rules_mv Q1012 ' ||
   '           , APPS.hz_locations hzl ' ||
   '           , APPS.hz_party_sites hzps ' ||
   '           , APPS.hz_parties hzp ' ||
   '           , APPS.as_accesses_all aaa ' ||
   '           , APPS.jtf_terr_rsc_all jtr ' ||
   '       WHERE ' ||
   '          ( ( hzl.postal_code = Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''='' ) ' ||
   '               OR ' ||
   '             ( hzl.postal_code <= Q1007R1.high_value_char AND ' ||
   '               hzl.postal_code >= Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''BETWEEN'' ) ' ||
   '           ) ' ||
   '       AND Q1007R1.qual_usg_id = -1007 ' ||
   '       AND Q1007R1.terr_id = jtr.terr_id ' ||
   '       AND UPPER(hzp.party_name) = Q1012.low_value_char ' ||
   '       AND Q1012.COMPARISON_OPERATOR = ''='' ' ||
   '       AND Q1012.qual_usg_id = -1012 ' ||
   '       AND Q1012.terr_id = jtr.terr_id ' ||
   '       AND hzl.location_id = hzps.location_id ' ||
   '       AND (hzps.status IN (''A'',''I'') OR hzps.status IS NULL ) ' ||
   '       AND hzps.party_id = hzp.party_id ' ||
   '       AND hzp.status = ''A'' ' ||
   '       AND hzp.party_id = aaa.customer_id ' ||
   '       AND aaa.salesforce_id = jtr.resource_id ' ||
   '       AND jtr.terr_id = :p_terr_id2 ' ||

   '       UNION  ' ||

   '       SELECT ' ||
   '         Q1012.low_value_char, NULL ' ||
   '       , hzp.party_name org_name ' ||
   '       , hzl.address1 || '', '' || hzl.address2 || '', '' || ' ||
   '         hzl.city || '', '' || hzl.state ' ||
   '         || '', '' || hzl.postal_code org_address ' ||
   '       FROM  ' ||
   '             APPS.jtf_terr_qual_rules_mv Q1007R1 ' ||
   '           , APPS.jtf_terr_cnr_qual_like_mv Q1012 ' ||
   '           , APPS.hz_locations hzl ' ||
   '           , APPS.hz_party_sites hzps ' ||
   '           , APPS.hz_parties hzp ' ||
   '           , APPS.as_accesses_all aaa ' ||
   '           , APPS.jtf_terr_rsc_all jtr ' ||
   '       WHERE ' ||
   '          ( ( hzl.postal_code = Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''='' ) ' ||
   '               OR ' ||
   '             ( hzl.postal_code <= Q1007R1.high_value_char AND ' ||
   '               hzl.postal_code >= Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''BETWEEN'' ) ' ||
   '           ) ' ||
   '       AND Q1007R1.qual_usg_id = -1007 ' ||
   '       AND Q1007R1.terr_id = jtr.terr_id ' ||
   '       AND UPPER(hzp.party_name) LIKE Q1012.low_value_char ' ||
   '       AND UPPER(SUBSTR(hzp.party_name, 1, 1)) = Q1012.first_char ' ||
   '       AND Q1012.qual_usg_id = -1012 ' ||
   '       AND Q1012.terr_id = jtr.terr_id ' ||
   '       AND hzl.location_id = hzps.location_id ' ||
   '       AND (hzps.status IN (''A'',''I'') OR hzps.status IS NULL ) ' ||
   '       AND hzps.party_id = hzp.party_id ' ||
   '       AND hzp.status = ''A'' ' ||
   '       AND hzp.party_id = aaa.customer_id ' ||
   '       AND aaa.salesforce_id = jtr.resource_id ' ||
   '       AND jtr.terr_id = :p_terr_id3 ' ||

   '       UNION  ' ||

  '       SELECT ' ||
   '         Q1012.low_value_char, NULL ' ||
   '       , hzp.party_name org_name ' ||
   '       , hzl.address1 || '', '' || hzl.address2 || '', '' || ' ||
   '         hzl.city || '', '' || hzl.state ' ||
   '         || '', '' || hzl.postal_code org_address ' ||
   '       FROM  ' ||
   '             APPS.jtf_terr_qual_rules_mv Q1007R1 ' ||
   '           , APPS.jtf_terr_cnr_qual_like_mv Q1012 ' ||
   '           , APPS.hz_locations hzl ' ||
   '           , APPS.hz_party_sites hzps ' ||
   '           , APPS.hz_parties hzp ' ||
   '           , APPS.as_accesses_all aaa ' ||
   '           , APPS.jtf_terr_rsc_all jtr ' ||
  '       WHERE ' ||
   '          ( ( hzl.postal_code = Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''='' ) ' ||
   '               OR ' ||
   '             ( hzl.postal_code <= Q1007R1.high_value_char AND ' ||
   '               hzl.postal_code >= Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''BETWEEN'' ) ' ||
   '           ) ' ||
   '       AND Q1007R1.qual_usg_id = -1007 ' ||
   '       AND Q1007R1.terr_id = jtr.terr_id ' ||
   '       AND UPPER(hzp.party_name) LIKE Q1012.low_value_char ' ||
   '       AND ''%'' = Q1012.first_char ' ||
   '       AND Q1012.qual_usg_id = -1012 ' ||
   '       AND Q1012.terr_id = jtr.terr_id ' ||
   '       AND hzl.location_id = hzps.location_id ' ||
   '       AND (hzps.status IN (''A'',''I'') OR hzps.status IS NULL ) ' ||
   '       AND hzps.party_id = hzp.party_id ' ||
   '       AND hzp.status = ''A'' ' ||
   '       AND hzp.party_id = aaa.customer_id ' ||
   '       AND aaa.salesforce_id = jtr.resource_id ' ||
   '       AND jtr.terr_id = :p_terr_id4 ' ||

   '       UNION  ' ||

   '       SELECT ' ||
   '         Q1012.low_value_char, Q1012.high_value_char ' ||
   '       , hzp.party_name org_name ' ||
   '       , hzl.address1 || '', '' || hzl.address2 || '', '' || ' ||
   '         hzl.city || '', '' || hzl.state ' ||
   '         || '', '' || hzl.postal_code org_address ' ||
   '       FROM  ' ||
   '             APPS.jtf_terr_qual_rules_mv Q1007R1 ' ||
   '           , APPS.jtf_terr_cnr_qual_btwn_mv Q1012 ' ||
   '           , APPS.hz_locations hzl ' ||
   '           , APPS.hz_party_sites hzps ' ||
   '           , APPS.hz_parties hzp ' ||
   '           , APPS.as_accesses_all aaa ' ||
   '           , APPS.jtf_terr_rsc_all jtr ' ||
   '       WHERE ' ||
   '          ( ( hzl.postal_code = Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''='' ) ' ||
   '               OR ' ||
   '             ( hzl.postal_code <= Q1007R1.high_value_char AND ' ||
   '               hzl.postal_code >= Q1007R1.low_value_char AND ' ||
   '               Q1007R1.comparison_operator = ''BETWEEN'' ) ' ||
   '           ) ' ||
   '       AND Q1007R1.qual_usg_id = -1007 ' ||
   '       AND Q1007R1.terr_id = jtr.terr_id ' ||
   '       AND UPPER(hzp.party_name) BETWEEN Q1012.low_value_char AND Q1012.high_value_char ' ||
   '       AND Q1012.qual_usg_id = -1012  ' ||
   '       AND Q1012.terr_id = jtr.terr_id ' ||
   '       AND hzl.location_id = hzps.location_id ' ||
   '       AND (hzps.status IN (''A'',''I'') OR hzps.status IS NULL ) ' ||
   '       AND hzps.party_id = hzp.party_id ' ||
   '       AND hzp.status = ''A'' ' ||
   '       AND hzp.party_id = aaa.customer_id ' ||
   '       AND aaa.salesforce_id = jtr.resource_id ' ||
   '       AND jtr.terr_id = :p_terr_id5 ' ||
   '     ) ilv ';




   EXECUTE IMMEDIATE l_dyn_str USING
      p_terr_id,
      p_session_id,
      p_terr_id,
      p_terr_id,
      p_terr_id,
      p_terr_id;

     commit;

END get_keyword_parties;

PROCEDURE get_results(p_session_id number,
                      p_resource_id number,
                      p_group_id number,
                      p_active_date varchar2
                      )
as
 lp_active_date                   DATE   := SYSDATE;
 lp_sysdate                   DATE   := SYSDATE;

BEGIN
  delete from jtf_tae_rpt_staging_out
  where session_id = p_session_id;
  /*
  insert into jtf_tae_rpt_staging_out
      (TRANS_OBJECT_ID,
       TRANS_DETAIL_OBJECT_ID,
       SOURCE_ID,
       TRANS_OBJECT_TYPE_ID,
       TERR_ID,
       terr_name,
       terr_rank,
       session_id)
  values(-999,
        -999,
        -999,
        -999,
        -999,
        p_resource_id,
        p_group_id,
        p_session_id);
  */
  lp_active_date := to_date(p_active_date, 'YYYY/MM/DD');
  insert into jtf_tae_rpt_staging_out
      (TRANS_OBJECT_ID,
       TRANS_DETAIL_OBJECT_ID,
       SOURCE_ID,
       TRANS_OBJECT_TYPE_ID,
       TERR_ID,
       terr_name,
       terr_rank,
       session_id)
  select distinct -999,
        -999,
        -999,
        -999,
        jta.terr_id,
        jta.name,
        jta.rank,
        p_session_id
  from jtf_terr_all jta,
       jtf_terr_rsc_all jtra
  where jta.terr_id = jtra.terr_id
  and (jtra.resource_id = p_resource_id or p_resource_id = -999)
  and (jtra.group_id = p_group_id or p_group_id =-999)
  AND NOT EXISTS (
       SELECT jt.terr_id
       FROM jtf_terr_all jt
       WHERE ( ( NVL(jt.end_date_active, lp_sysdate) <= NVL(lp_active_date, lp_sysdate) ) OR
               ( NVL(jt.start_date_active, lp_sysdate) > NVL(lp_active_date, lp_sysdate) )
                          )
        CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
        START WITH jt.terr_id = jta.terr_id );

  commit;
END get_results;



end JTF_TERR_RPT;

/
