--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_BATCH_COUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_BATCH_COUNTS_PKG" AS
/*$Header: ARHLBCB.pls 120.12.12010000.2 2008/10/27 09:38:45 idali ship $*/
/*
  Procedure: pre_import_counts()
  These are the counts of each entity before running
   the dataload process. This procedure also initializes
   the post count columns to zero.
  This procedure is called from
    hz_imp_batch_summary_v2pub.activate_batch().
  The above API is called from teh last stage of DNB adapter.
*/

PROCEDURE pre_import_counts
 ( P_BATCH_ID    IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
   P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE) IS
    -- Declare the variables
  l_ADDRESSUSES_IN_BATCH  NUMBER;
  l_ADDRESSES_IN_BATCH  NUMBER;
  l_FINNUMBERS_IN_BATCH  NUMBER;
  l_CODEASSIGNS_IN_BATCH  NUMBER;
  l_RELATIONSHIPS_IN_BATCH  NUMBER;
  l_CONTACTROLES_IN_BATCH  NUMBER;
  l_CONTACTS_IN_BATCH  NUMBER;
  l_CONTACTPOINTS_IN_BATCH  NUMBER;
  l_CREDITRATINGS_IN_BATCH  NUMBER;
  l_FINREPORTS_IN_BATCH  NUMBER;
  l_PARTIES_IN_BATCH  NUMBER;
   l_total_batch_records number;

BEGIN
  SELECT  count(INT.BATCH_ID) into l_ADDRESSUSES_IN_BATCH
    FROM HZ_IMP_ADDRESSUSES_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_ADDRESSES_IN_BATCH
    FROM HZ_IMP_ADDRESSES_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_FINNUMBERS_IN_BATCH
    FROM HZ_IMP_FINNUMBERS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_CODEASSIGNS_IN_BATCH
    FROM HZ_IMP_CLASSIFICS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_RELATIONSHIPS_IN_BATCH
    FROM HZ_IMP_RELSHIPS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_CONTACTROLES_IN_BATCH
    FROM HZ_IMP_CONTACTROLES_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.CONTACT_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_CONTACTS_IN_BATCH
    FROM HZ_IMP_CONTACTS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.CONTACT_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_CONTACTPOINTS_IN_BATCH
    FROM HZ_IMP_CONTACTPTS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_CREDITRATINGS_IN_BATCH
    FROM HZ_IMP_CREDITRTNGS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_FINREPORTS_IN_BATCH
    FROM HZ_IMP_FINREPORTS_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  SELECT  count(INT.BATCH_ID) into l_PARTIES_IN_BATCH
    FROM HZ_IMP_PARTIES_INT INT
    WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM ;
  l_total_batch_records :=
   l_ADDRESSUSES_IN_BATCH +
   l_ADDRESSES_IN_BATCH +
   l_FINNUMBERS_IN_BATCH +
   l_CODEASSIGNS_IN_BATCH +
   l_RELATIONSHIPS_IN_BATCH +
   l_CONTACTROLES_IN_BATCH +
   l_CONTACTS_IN_BATCH +
   l_CONTACTPOINTS_IN_BATCH +
   l_CREDITRATINGS_IN_BATCH +
   l_FINREPORTS_IN_BATCH +
   l_PARTIES_IN_BATCH ;

 UPDATE HZ_IMP_BATCH_SUMMARY SET
   ADDRESSUSES_IN_BATCH = l_ADDRESSUSES_IN_BATCH,
   ADDRESSES_IN_BATCH = l_ADDRESSES_IN_BATCH,
   FINNUMBERS_IN_BATCH = l_FINNUMBERS_IN_BATCH,
   CODEASSIGNS_IN_BATCH = l_CODEASSIGNS_IN_BATCH,
   RELATIONSHIPS_IN_BATCH = l_RELATIONSHIPS_IN_BATCH,
   CONTACTROLES_IN_BATCH = l_CONTACTROLES_IN_BATCH,
   CONTACTS_IN_BATCH = l_CONTACTS_IN_BATCH,
   CONTACTPOINTS_IN_BATCH = l_CONTACTPOINTS_IN_BATCH,
   CREDITRATINGS_IN_BATCH = l_CREDITRATINGS_IN_BATCH,
   FINREPORTS_IN_BATCH = l_FINREPORTS_IN_BATCH,
   PARTIES_IN_BATCH = l_PARTIES_IN_BATCH,
   TOTAL_BATCH_RECORDS =  l_total_batch_records,
  ADDRESSUSES_INSERTED = 0,
  ADDRESSUSES_UPDATED = 0,
  ADDRESSUSES_IMPORTED = 0,
  ADDRESSES_INSERTED = 0,
  ADDRESSES_UPDATED = 0,
  ADDRESSES_IMPORTED = 0,
  ADDRESS_MERGE_REQUESTS = 0,
  FINNUMBERS_INSERTED = 0,
  FINNUMBERS_UPDATED = 0,
  FINNUMBERS_IMPORTED = 0,
  CODEASSIGNS_INSERTED = 0,
  CODEASSIGNS_UPDATED = 0,
  CODEASSIGNS_IMPORTED = 0,
  RELATIONSHIPS_INSERTED = 0,
  RELATIONSHIPS_UPDATED = 0,
  RELATIONSHIPS_IMPORTED = 0,
  CONTACTROLES_INSERTED = 0,
  CONTACTROLES_UPDATED = 0,
  CONTACTROLES_IMPORTED = 0,
  CONTACTS_INSERTED = 0,
  CONTACTS_UPDATED = 0,
  CONTACTS_IMPORTED = 0,
  CONTACT_MERGE_REQUESTS = 0,
  CONTACTPOINTS_INSERTED = 0,
  CONTACTPOINTS_UPDATED = 0,
  CONTACTPOINTS_IMPORTED = 0,
  CONTACTPOINT_MERGE_REQUESTS = 0,
  CREDITRATINGS_INSERTED = 0,
  CREDITRATINGS_UPDATED = 0,
  CREDITRATINGS_IMPORTED = 0,
  FINREPORTS_INSERTED = 0,
  FINREPORTS_UPDATED = 0,
  FINREPORTS_IMPORTED = 0,
  PARTIES_INSERTED = 0,
  PARTIES_UPDATED = 0,
  PARTIES_IMPORTED = 0,
  PARTY_MERGE_REQUESTS = 0,
  PARTIES_AUTO_MERGED    = 0,
  TOTAL_MERGE_REQUESTS   = 0,
  TOTAL_ERRORS           = 0,
  TOTAL_RECORDS_IMPORTED = 0
 WHERE BATCH_ID = P_BATCH_ID;
END pre_import_counts;

/*
  Procedure: post_import_counts()
  These are the counts after populating the TCA registry.
  These counts are cumulative i.e., per batch (not per run).
  This procedure is called from within the dataload process.
*/

procedure post_import_counts
     (P_BATCH_ID    IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
       P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE,
       P_BATCH_MODE_FLAG in VARCHAR2,
       P_REQUEST_ID      IN NUMBER,
       P_RERUN_FLAG IN VARCHAR2) IS -- N for First Run any other value is rerun

-- Declare the variables

 l_ADDRESSUSES_INSERTED NUMBER;
 l_ADDRESSES_INSERTED NUMBER;
 l_FINNUMBERS_INSERTED NUMBER;
 l_CODEASSIGNS_INSERTED NUMBER;
 l_RELATIONSHIPS_INSERTED NUMBER;
 l_CONTACTROLES_INSERTED NUMBER;
 l_CONTACTS_INSERTED NUMBER;
 l_CONTACTPOINTS_INSERTED NUMBER;
 l_CREDITRATINGS_INSERTED NUMBER;
 l_FINREPORTS_INSERTED NUMBER;
 l_PARTIES_INSERTED NUMBER;

 l_ADDRESSUSES_UPDATED NUMBER;
 l_ADDRESSES_UPDATED NUMBER;
 l_FINNUMBERS_UPDATED NUMBER;
 l_CODEASSIGNS_UPDATED NUMBER;
 l_RELATIONSHIPS_UPDATED NUMBER;
 l_CONTACTROLES_UPDATED NUMBER;
 l_CONTACTS_UPDATED NUMBER;
 l_CONTACTPOINTS_UPDATED NUMBER;
 l_CREDITRATINGS_UPDATED NUMBER;
 l_FINREPORTS_UPDATED NUMBER;
 l_PARTIES_UPDATED NUMBER;

 l_ADDRESSUSES_ERRORED NUMBER;
 l_ADDRESSES_ERRORED NUMBER;
 l_FINNUMBERS_ERRORED NUMBER;
 l_CODEASSIGNS_ERRORED NUMBER;
 l_RELATIONSHIPS_ERRORED NUMBER;
 l_CONTACTROLES_ERRORED NUMBER;
 l_CONTACTS_ERRORED NUMBER;
 l_CONTACTPOINTS_ERRORED NUMBER;
 l_CREDITRATINGS_ERRORED NUMBER;
 l_FINREPORTS_ERRORED NUMBER;
 l_PARTIES_ERRORED NUMBER;

 l_ADDRESSUSES_IMPORTED NUMBER;
 l_ADDRESSES_IMPORTED NUMBER;
 l_FINNUMBERS_IMPORTED NUMBER;
 l_CODEASSIGNS_IMPORTED NUMBER;
 l_RELATIONSHIPS_IMPORTED NUMBER;
 l_CONTACTROLES_IMPORTED NUMBER;
 l_CONTACTS_IMPORTED NUMBER;
 l_CONTACTPOINTS_IMPORTED NUMBER;
 l_CREDITRATINGS_IMPORTED NUMBER;
 l_FINREPORTS_IMPORTED NUMBER;
 l_PARTIES_IMPORTED NUMBER;

 l_total_errors number;
 l_total_records_imported number;

l_bool BOOLEAN;
l_status_owner VARCHAR2(255);
l_ar_schema_name VARCHAR2(255);
l_tmp           VARCHAR2(2000);

l_sst_flag            HZ_ORIG_SYSTEMS_B.sst_flag%TYPE := 'N';
l_rels_updated  NUMBER := 0;

BEGIN

-- Bug 3872618
l_bool := fnd_installation.GET_APP_INFO('AR',l_status_owner,l_tmp,l_ar_schema_name);

/*
  IF ( p_rerun_flag = 'N') THEN
    -- compute total_errors in first run
      l_total_errors :=
    l_ADDRESSUSES_ERRORED +
    l_ADDRESSES_ERRORED +
    l_FINNUMBERS_ERRORED +
    l_CODEASSIGNS_ERRORED +
    l_RELATIONSHIPS_ERRORED +
    l_CONTACTROLES_ERRORED +
    l_CONTACTS_ERRORED +
    l_CONTACTPOINTS_ERRORED +
    l_CREDITRATINGS_ERRORED +
    l_FINREPORTS_ERRORED +
    l_PARTIES_ERRORED ;
  ELSE
    -- FOR RE-RUN CASES total_errors = total_errors - newly imported recs
    l_total_errors :=   l_total_records_imported;
  END IF;
*/

select ct, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11, c12,
       c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23
  into l_total_errors, l_relationships_inserted, l_relationships_updated,
       l_finnumbers_inserted, l_finnumbers_updated, l_finreports_inserted,
       l_finreports_updated, l_contactpoints_inserted,
       l_contactpoints_updated, l_addresses_inserted, l_addresses_updated,
       l_parties_inserted, l_parties_updated, l_contactroles_inserted,
       l_contactroles_updated, l_addressuses_inserted,
       l_addressuses_updated, l_contacts_inserted, l_contacts_updated,
       l_creditratings_inserted, l_creditratings_updated,
       l_codeassigns_inserted, l_codeassigns_updated, l_total_records_imported
  from (
select ct, rank() over (order by a) r,
       lead(ct, 1) over (order by a) c01,
       lead(ct, 2) over (order by a) c02,
       lead(ct, 3) over (order by a) c03,
       lead(ct, 4) over (order by a) c04,
       lead(ct, 5) over (order by a) c05,
       lead(ct, 6) over (order by a) c06,
       lead(ct, 7) over (order by a) c07,
       lead(ct, 8) over (order by a) c08,
       lead(ct, 9) over (order by a) c09,
       lead(ct, 10) over (order by a) c10,
       lead(ct, 11) over (order by a) c11,
       lead(ct, 12) over (order by a) c12,
       lead(ct, 13) over (order by a) c13,
       lead(ct, 14) over (order by a) c14,
       lead(ct, 15) over (order by a) c15,
       lead(ct, 16) over (order by a) c16,
       lead(ct, 17) over (order by a) c17,
       lead(ct, 18) over (order by a) c18,
       lead(ct, 19) over (order by a) c19,
       lead(ct, 20) over (order by a) c20,
       lead(ct, 21) over (order by a) c21,
       lead(ct, 22) over (order by a) c22,
       sum(ct) over (order by a rows between 1 following and 22 following) c23
  from (
select x.a, nvl(y.ct, 0) ct from (
select multiplier a from gl_row_multipliers
 where rownum < 24) x, (
select a, count(*) ct from (
select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
       1, nvl2(NVL(rel.relationship_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 2, 3),24)) a
  from hz_imp_tmp_errors e, hz_imp_relships_sg sg,hz_relationships rel, HZ_IMP_RELSHIPS_INT hzint
 where sg.batch_mode_flag = p_batch_mode_flag
   and sg.batch_id = p_batch_id
   and sg.sub_orig_system = p_original_system
   and e.int_row_id (+) = sg.int_row_id
   and e.request_id (+) = p_request_id
   and e.interface_table_name (+) = 'HZ_IMP_RELSHIPS_INT'
   and rel.relationship_id (+) = sg.relationship_id
   and rel.request_id (+) = p_request_id
   and rel.directional_flag(+) = 'F'
   and sg.int_row_id = hzint.rowid (+)
   and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(fnn.financial_number_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 4, 5),24)) a
    from hz_imp_tmp_errors e, hz_imp_finnumbers_sg sg,hz_financial_numbers fnn, HZ_IMP_FINNUMBERS_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_FINNUMBERS_INT'
     and fnn.financial_number_id (+) = sg.financial_number_id
     and fnn.request_id(+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(fnr.financial_report_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 6, 7),24)) a
    from hz_imp_tmp_errors e, hz_imp_finreports_sg sg,hz_financial_reports fnr, HZ_IMP_FINREPORTS_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_FINREPORTS_INT'
     and fnr.financial_report_id(+) = sg.financial_report_id
     and fnr.request_id(+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hcp.contact_point_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 8, 9),24)) a
    from hz_imp_tmp_errors e, hz_imp_contactpts_sg sg,hz_contact_points hcp, HZ_IMP_CONTACTPTS_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_CONTACTPTS_INT'
     and hcp.contact_point_id (+) = sg.contact_point_id
     and hcp.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
   select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(loc.location_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 10, 11),24)) a
    from hz_imp_tmp_errors e, hz_imp_addresses_sg sg,hz_party_sites hps,
         hz_orig_sys_references hosr,hz_locations loc, HZ_IMP_ADDRESSES_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and hosr.orig_system(+) =sg.party_orig_system
     and hosr.orig_system_reference(+) =sg.site_orig_system_reference
     and hosr.owner_table_name(+)  = 'HZ_PARTY_SITES'
     and hosr.status(+) = 'A'
     and hosr.owner_table_id = hps.party_site_id(+)
     and hps.location_id = loc.location_id(+)
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_ADDRESSES_INT'
     --and hps.party_site_id (+) = sg.party_site_id
     and loc.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hp.party_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 12, 13),24)) a
    from hz_imp_tmp_errors e, hz_imp_parties_sg sg,hz_parties hp, HZ_IMP_PARTIES_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_PARTIES_INT'
     and hp.party_id (+) = sg.party_id
     and hp.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hocr.org_contact_role_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 14, 15),24)) a
    from hz_imp_tmp_errors e, hz_imp_contactroles_sg sg,hz_org_contact_roles hocr, HZ_IMP_CONTACTROLES_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.sub_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_CONTACTROLES_INT'
     and hocr.org_contact_role_id (+) = sg.contact_role_id
--     and hocr.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hpsu.party_site_use_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 16, 17),24)) a
    from hz_imp_tmp_errors e, hz_imp_addressuses_sg sg, hz_party_site_uses hpsu, HZ_IMP_ADDRESSUSES_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_ADDRESSUSES_INT'
     and hpsu.party_site_use_id (+) = sg.party_site_use_id
--     and hpsu.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hoc.org_contact_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 18, 19),24)) a
    from hz_imp_tmp_errors e, hz_imp_contacts_sg sg, hz_org_contacts hoc, HZ_IMP_CONTACTS_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.contact_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_CONTACTS_INT'
     and hoc.org_contact_id (+) = sg.contact_id
     and hoc.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
   union all
  select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
         1, nvl2(NVL(hcr.credit_rating_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 20, 21),24)) a
    from hz_imp_tmp_errors e, hz_imp_creditrtngs_sg sg,hz_credit_ratings hcr, HZ_IMP_CREDITRTNGS_INT hzint
   where sg.batch_mode_flag = p_batch_mode_flag
     and sg.batch_id = p_batch_id
     and sg.party_orig_system = p_original_system
     and e.int_row_id (+) = sg.int_row_id
     and e.request_id (+) = p_request_id
     and e.interface_table_name (+) = 'HZ_IMP_CREDITRTNGS_INT'
     and hcr.credit_rating_id(+) = sg.credit_rating_id
     and hcr.request_id (+) = p_request_id
     and sg.int_row_id = hzint.rowid (+)
     and hzint.interface_status(+) = 'D'
 union all
select /*+ full(sg) parallel(sg) */ nvl2(e.int_row_id,
       1, nvl2(NVL(hca.code_assignment_id,hzint.BATCH_ID),decode(sg.action_flag, 'I', 22, 23),24)) a
  from hz_imp_tmp_errors e, hz_imp_classifics_sg sg,hz_code_assignments hca, HZ_IMP_CLASSIFICS_INT hzint
 where sg.batch_mode_flag = p_batch_mode_flag
   and sg.batch_id = p_batch_id
   and sg.party_orig_system = p_original_system
   and e.int_row_id (+) = sg.int_row_id
   and e.request_id (+) = p_request_id
   and e.interface_table_name (+) = 'HZ_IMP_CLASSIFICS_INT'
   and hca.code_assignment_id (+) = sg.code_assignment_id
   and hca.request_id (+) = p_request_id
   and sg.int_row_id = hzint.rowid (+)
   and hzint.interface_status(+) = 'D'
  )
 group by a) y
 where x.a = y.a (+)))
 where r = 1;


IF p_original_system <> 'USER_ENTERED'
THEN
select sst_flag
into l_sst_flag
from hz_orig_systems_b
where orig_system = p_original_system
and status='A';

IF l_sst_flag='Y'
THEN
  select count(*)
  into l_rels_updated
  from hz_imp_relships_sg
  where batch_id=p_batch_id
  and action_flag='U'
  and relationship_type in
      ('HEADQUARTERS/DIVISION','PARENT/SUBSIDIARY','DOMESTIC_ULTIMATE','GLOBAL_ULTIMATE')
  and sub_orig_system = p_original_system
  and batch_mode_flag=p_batch_mode_flag;
END IF;
END IF;

  update hz_imp_batch_summary set
    addressuses_inserted = addressuses_inserted + l_addressuses_inserted,
    addressuses_updated = addressuses_updated + l_addressuses_updated,
    addressuses_imported = addressuses_imported + l_addressuses_inserted + l_addressuses_updated,
    addresses_inserted = addresses_inserted + l_addresses_inserted,
    addresses_updated = addresses_updated + l_addresses_updated,
    addresses_imported = addresses_imported + l_addresses_inserted + l_addresses_updated,
    address_merge_requests = 0, --l_addresses_merge_requests,
    finnumbers_inserted = finnumbers_inserted + l_finnumbers_inserted,
    finnumbers_updated = finnumbers_updated + l_finnumbers_updated,
    finnumbers_imported = finnumbers_imported + l_finnumbers_inserted + l_finnumbers_updated,
    codeassigns_inserted = codeassigns_inserted + l_codeassigns_inserted,
    codeassigns_updated = codeassigns_updated + l_codeassigns_updated,
    codeassigns_imported = codeassigns_imported + l_codeassigns_inserted + l_codeassigns_updated,
    relationships_inserted = relationships_inserted + l_relationships_inserted,
    relationships_updated = relationships_updated + l_relationships_updated + l_rels_updated,
    relationships_imported = relationships_imported + l_relationships_inserted + l_relationships_updated + l_rels_updated,
    contactroles_inserted = contactroles_inserted + l_contactroles_inserted,
    contactroles_updated = contactroles_updated + l_contactroles_updated,
    contactroles_imported = contactroles_imported + l_contactroles_inserted + l_contactroles_updated,
    contacts_inserted = contacts_inserted + l_contacts_inserted,
    contacts_updated = contacts_updated + l_contacts_updated,
    contacts_imported = contacts_imported + l_contacts_inserted + l_contacts_updated,
    contact_merge_requests = 0, --l_contacts_merge_requests,
    contactpoints_inserted = contactpoints_inserted + l_contactpoints_inserted,
    contactpoints_updated = contactpoints_updated + l_contactpoints_updated,
    contactpoints_imported = contactpoints_imported + l_contactpoints_inserted + l_contactpoints_updated,
    contactpoint_merge_requests = 0, --l_contactpoints_merge_requests,
    creditratings_inserted = creditratings_inserted + l_creditratings_inserted,
    creditratings_updated = creditratings_updated + l_creditratings_updated,
    creditratings_imported = creditratings_imported + l_creditratings_inserted + l_creditratings_updated,
    finreports_inserted = finreports_inserted + l_finreports_inserted,
    finreports_updated = finreports_updated + l_finreports_updated,
    finreports_imported = finreports_imported + l_finreports_inserted + l_finreports_updated,
    parties_inserted = parties_inserted + l_parties_inserted,
    parties_updated = parties_updated + l_parties_updated,
    parties_imported = parties_imported + l_parties_inserted + l_parties_updated,
    total_errors  = decode(p_rerun_flag, 'N', l_total_errors, decode (total_errors, 0, l_total_errors, (total_errors - l_total_records_imported))),
    total_records_imported = total_records_imported + l_total_records_imported + l_rels_updated
  where batch_id = p_batch_id;
/*
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_ADDRESSUSES_INSERTED'|| l_ADDRESSUSES_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_ADDRESSES_INSERTED'|| l_ADDRESSES_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_FINNUMBERS_INSERTED'|| l_FINNUMBERS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CODEASSIGNS_INSERTED'|| l_CODEASSIGNS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_RELATIONSHIPS_INSERTED'|| l_RELATIONSHIPS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTROLES_INSERTED'|| l_CONTACTROLES_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTS_INSERTED'|| l_CONTACTS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTPOINTS_INSERTED'|| l_CONTACTPOINTS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CREDITRATINGS_INSERTED'|| l_CREDITRATINGS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_FINREPORTS_INSERTED'|| l_FINREPORTS_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_PARTIES_INSERTED'|| l_PARTIES_INSERTED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_ADDRESSUSES_UPDATED'|| l_ADDRESSUSES_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_ADDRESSES_UPDATED'|| l_ADDRESSES_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_FINNUMBERS_UPDATED'|| l_FINNUMBERS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CODEASSIGNS_UPDATED'|| l_CODEASSIGNS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_RELATIONSHIPS_UPDATED'|| l_RELATIONSHIPS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTROLES_UPDATED'|| l_CONTACTROLES_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTS_UPDATED'|| l_CONTACTS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CONTACTPOINTS_UPDATED'|| l_CONTACTPOINTS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_CREDITRATINGS_UPDATED'|| l_CREDITRATINGS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_FINREPORTS_UPDATED'|| l_FINREPORTS_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_PARTIES_UPDATED'|| l_PARTIES_UPDATED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_BATCH_MODE_FLAG:'||P_BATCH_MODE_FLAG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_total_errors :='||l_total_errors);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_ADDRESSUSES_ERRORED:'||l_ADDRESSUSES_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_ADDRESSES_ERRORED +'||l_ADDRESSES_ERRORED );
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_FINNUMBERS_ERRORED +'||l_FINNUMBERS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_CODEASSIGNS_ERRORED +'||l_CODEASSIGNS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_RELATIONSHIPS_ERRORED +'||l_RELATIONSHIPS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_CONTACTROLES_ERRORED +'||l_CONTACTROLES_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_CONTACTS_ERRORED +'||l_CONTACTS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_CONTACTPOINTS_ERRORED +'||l_CONTACTPOINTS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_CREDITRATINGS_ERRORED +'||l_CREDITRATINGS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_FINREPORTS_ERRORED +'||l_FINREPORTS_ERRORED);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_PARTIES_ERRORED:'||l_PARTIES_ERRORED) ;
*/

/*
 -- updating the batch summary table
 -- with all the counts. Also, initializing the merge counts to zero so that
 -- if and when DQM populates them, the merge counts will have appropriate values
 -- otherwise, they will show zeros.

 UPDATE HZ_IMP_BATCH_SUMMARY SET
  ADDRESSUSES_INSERTED = ADDRESSUSES_INSERTED + l_ADDRESSUSES_INSERTED,
  ADDRESSUSES_UPDATED = ADDRESSUSES_UPDATED + l_ADDRESSUSES_UPDATED,
  ADDRESSUSES_IMPORTED = ADDRESSUSES_IMPORTED + l_ADDRESSUSES_IMPORTED,
  ADDRESSES_INSERTED = ADDRESSES_INSERTED + l_ADDRESSES_INSERTED,
  ADDRESSES_UPDATED = ADDRESSES_UPDATED + l_ADDRESSES_UPDATED,
  ADDRESSES_IMPORTED = ADDRESSES_IMPORTED + l_ADDRESSES_IMPORTED,
  ADDRESS_MERGE_REQUESTS = 0, --l_ADDRESSES_MERGE_REQUESTS,
  FINNUMBERS_INSERTED = FINNUMBERS_INSERTED + l_FINNUMBERS_INSERTED,
  FINNUMBERS_UPDATED = FINNUMBERS_UPDATED + l_FINNUMBERS_UPDATED,
  FINNUMBERS_IMPORTED = FINNUMBERS_IMPORTED + l_FINNUMBERS_IMPORTED,
  CODEASSIGNS_INSERTED = CODEASSIGNS_INSERTED + l_CODEASSIGNS_INSERTED,
  CODEASSIGNS_UPDATED = CODEASSIGNS_UPDATED + l_CODEASSIGNS_UPDATED,
  CODEASSIGNS_IMPORTED = CODEASSIGNS_IMPORTED + l_CODEASSIGNS_IMPORTED,
  RELATIONSHIPS_INSERTED = RELATIONSHIPS_INSERTED + l_RELATIONSHIPS_INSERTED,
  RELATIONSHIPS_UPDATED = RELATIONSHIPS_UPDATED + l_RELATIONSHIPS_UPDATED,
  RELATIONSHIPS_IMPORTED = RELATIONSHIPS_IMPORTED + l_RELATIONSHIPS_IMPORTED,
  CONTACTROLES_INSERTED = CONTACTROLES_INSERTED + l_CONTACTROLES_INSERTED,
  CONTACTROLES_UPDATED = CONTACTROLES_UPDATED + l_CONTACTROLES_UPDATED,
  CONTACTROLES_IMPORTED = CONTACTROLES_IMPORTED + l_CONTACTROLES_IMPORTED,
  CONTACTS_INSERTED = CONTACTS_INSERTED + l_CONTACTS_INSERTED,
  CONTACTS_UPDATED = CONTACTS_UPDATED + l_CONTACTS_UPDATED,
  CONTACTS_IMPORTED = CONTACTS_IMPORTED + l_CONTACTS_IMPORTED,
  CONTACT_MERGE_REQUESTS = 0, --l_CONTACTS_MERGE_REQUESTS,
  CONTACTPOINTS_INSERTED = CONTACTPOINTS_INSERTED + l_CONTACTPOINTS_INSERTED,
  CONTACTPOINTS_UPDATED = CONTACTPOINTS_UPDATED + l_CONTACTPOINTS_UPDATED,
  CONTACTPOINTS_IMPORTED = CONTACTPOINTS_IMPORTED + l_CONTACTPOINTS_IMPORTED,
  CONTACTPOINT_MERGE_REQUESTS = 0, --l_CONTACTPOINTS_MERGE_REQUESTS,
  CREDITRATINGS_INSERTED = CREDITRATINGS_INSERTED + l_CREDITRATINGS_INSERTED,
  CREDITRATINGS_UPDATED = CREDITRATINGS_UPDATED + l_CREDITRATINGS_UPDATED,
  CREDITRATINGS_IMPORTED = CREDITRATINGS_IMPORTED + l_CREDITRATINGS_IMPORTED,
  FINREPORTS_INSERTED = FINREPORTS_INSERTED + l_FINREPORTS_INSERTED,
  FINREPORTS_UPDATED = FINREPORTS_UPDATED + l_FINREPORTS_UPDATED,
  FINREPORTS_IMPORTED = FINREPORTS_IMPORTED + l_FINREPORTS_IMPORTED,
  PARTIES_INSERTED = PARTIES_INSERTED + l_PARTIES_INSERTED,
  PARTIES_UPDATED = PARTIES_UPDATED + l_PARTIES_UPDATED,
  PARTIES_IMPORTED = PARTIES_IMPORTED + l_PARTIES_IMPORTED,
  PARTY_MERGE_REQUESTS = 0, -- l_PARTIES_MERGE_REQUESTS,
  PARTIES_AUTO_MERGED    = 0, --l_parties_auto_merged,
  TOTAL_MERGE_REQUESTS   = 0, --l_total_merge_requests,
  TOTAL_ERRORS  = DECODE (p_rerun_flag, 'N', l_total_errors, (TOTAL_ERRORS - l_total_errors)),
  TOTAL_RECORDS_IMPORTED = TOTAL_RECORDS_IMPORTED + l_total_records_imported
 WHERE BATCH_ID = P_BATCH_ID;
*/
END post_import_counts;

/*
  Procedure: what_if_import_counts()
  These are the counts of potential entries that might
  happen if the dataload process is allowed to go through to
  completion.  These are per  per run counts.
  This procedure is called from stage 2 of teh dataload process only
  when teh what_IF option is chosen.
*/

  PROCEDURE what_if_import_counts
     ( P_BATCH_ID    IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
       P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE) IS
-- Declare the variables
 l_NEW_UNIQUE_ADDRESSUSES NUMBER;
 l_NEW_UNIQUE_ADDRESSES NUMBER;
 l_NEW_UNIQUE_FINNUMBERS NUMBER;
 l_NEW_UNIQUE_CODEASSIGNS NUMBER;
 l_NEW_UNIQUE_RELATIONSHIPS NUMBER;
 l_NEW_UNIQUE_CONTACTROLES NUMBER;
 l_NEW_UNIQUE_CONTACTS NUMBER;
 l_NEW_UNIQUE_CONTACTPOINTS NUMBER;
 l_NEW_UNIQUE_CREDITRATINGS NUMBER;
 l_NEW_UNIQUE_FINREPORTS NUMBER;
 l_NEW_UNIQUE_PARTIES NUMBER;
 l_EXISTING_ADDRESSUSES NUMBER;
 l_EXISTING_ADDRESSES NUMBER;
 l_EXISTING_FINNUMBERS NUMBER;
 l_EXISTING_CODEASSIGNS NUMBER;
 l_EXISTING_RELATIONSHIPS NUMBER;
 l_EXISTING_CONTACTROLES NUMBER;
 l_EXISTING_CONTACTS NUMBER;
 l_EXISTING_CONTACTPOINTS NUMBER;
 l_EXISTING_CREDITRATINGS NUMBER;
 l_EXISTING_FINREPORTS NUMBER;
 l_EXISTING_PARTIES NUMBER;
 l_REMOVED_ADDRESSUSES NUMBER;
 l_REMOVED_ADDRESSES NUMBER;
 l_REMOVED_FINNUMBERS NUMBER;
 l_REMOVED_CODEASSIGNS NUMBER;
 l_REMOVED_RELATIONSHIPS NUMBER;
 l_REMOVED_CONTACTROLES NUMBER;
 l_REMOVED_CONTACTS NUMBER;
 l_REMOVED_CONTACTPOINTS NUMBER;
 l_REMOVED_CREDITRATINGS NUMBER;
 l_REMOVED_FINREPORTS NUMBER;
 l_REMOVED_PARTIES NUMBER;
 l_removed_by_user NUMBER;

BEGIN
  -- number of new and unique recs
     -- for l_NEW_UNIQUE_ADDRESSUSES
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_ADDRESSUSES
   FROM HZ_IMP_ADDRESSUSES_SG  INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
     -- for l_NEW_UNIQUE_ADDRESSES
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_ADDRESSES
   FROM HZ_IMP_ADDRESSES_INT INT, HZ_IMP_ADDRESSES_SG  SG
  WHERE INT.BATCH_ID = P_BATCH_ID AND
     INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM AND
     INT.BATCH_ID = SG.BATCH_ID AND
     INT.PARTY_ORIG_SYSTEM = SG.PARTY_ORIG_SYSTEM AND
     INT.rowid = sg.int_row_id
  AND INT.DQM_ACTION_FLAG IS NULL  AND SG.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_FINNUMBERS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_FINNUMBERS
   FROM HZ_IMP_FINNUMBERS_SG  INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_CODEASSIGNS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_CODEASSIGNS
   FROM HZ_IMP_CLASSIFICS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
      -- for l_NEW_UNIQUE_RELATIONSHIPS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_RELATIONSHIPS
   FROM HZ_IMP_RELSHIPS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
      -- for l_NEW_UNIQUE_CONTACTROLES
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_CONTACTROLES
   FROM HZ_IMP_CONTACTROLES_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
      -- for l_NEW_UNIQUE_CONTACTS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_CONTACTS
   FROM HZ_IMP_CONTACTS_INT INT, HZ_IMP_CONTACTS_SG  SG
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM AND
     INT.BATCH_ID = SG.BATCH_ID AND
     INT.SUB_ORIG_SYSTEM = SG.SUB_ORIG_SYSTEM AND
     INT.rowid = sg.int_row_id
  AND INT.DQM_ACTION_FLAG IS NULL  AND SG.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_CONTACTPOINTS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_CONTACTPOINTS
   FROM HZ_IMP_CONTACTPTS_INT INT, HZ_IMP_CONTACTPTS_SG  SG
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM AND
     INT.BATCH_ID = SG.BATCH_ID AND
     INT.PARTY_ORIG_SYSTEM = SG.PARTY_ORIG_SYSTEM AND
     INT.rowid = sg.int_row_id
  AND INT.DQM_ACTION_FLAG IS NULL  AND SG.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_CREDITRATINGS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_CREDITRATINGS
   FROM HZ_IMP_CREDITRTNGS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_FINREPORTS
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_FINREPORTS
   FROM HZ_IMP_FINREPORTS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'I' ;
    -- for l_NEW_UNIQUE_PARTIES
  SELECT  count(INT.BATCH_ID) into  l_NEW_UNIQUE_PARTIES
   FROM HZ_IMP_PARTIES_INT INT, HZ_IMP_PARTIES_SG  SG
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM AND
     INT.BATCH_ID = SG.BATCH_ID AND
     INT.PARTY_ORIG_SYSTEM = SG.PARTY_ORIG_SYSTEM AND
     INT.rowid = sg.int_row_id
  AND INT.DQM_ACTION_FLAG IS NULL  AND SG.ACTION_FLAG = 'I' ;
  -- counts of existing entity recs
   -- for l_EXISTING_ADDRESSUSES
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_ADDRESSUSES
   FROM HZ_IMP_ADDRESSUSES_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_ADDRESSES
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_ADDRESSES
   FROM HZ_IMP_ADDRESSES_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_FINNUMBERS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_FINNUMBERS
   FROM HZ_IMP_FINNUMBERS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_CODEASSIGNS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_CODEASSIGNS
   FROM HZ_IMP_CLASSIFICS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_RELATIONSHIPS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_RELATIONSHIPS
   FROM HZ_IMP_RELSHIPS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_CONTACTROLES
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_CONTACTROLES
   FROM HZ_IMP_CONTACTROLES_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_CONTACTS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_CONTACTS
   FROM HZ_IMP_CONTACTS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.CONTACT_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_CONTACTPOINTS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_CONTACTPOINTS
   FROM HZ_IMP_CONTACTPTS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_CREDITRATINGS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_CREDITRATINGS
   FROM HZ_IMP_CREDITRTNGS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_FINREPORTS
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_FINREPORTS
   FROM HZ_IMP_FINREPORTS_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;
    -- for l_EXISTING_PARTIES
  SELECT  count(INT.BATCH_ID) into  l_EXISTING_PARTIES
   FROM HZ_IMP_PARTIES_SG INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.ACTION_FLAG = 'U' ;

  -- counts of removed entity recs
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_ADDRESSUSES
   FROM HZ_IMP_ADDRESSUSES_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_ADDRESSES
   FROM HZ_IMP_ADDRESSES_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_FINNUMBERS
   FROM HZ_IMP_FINNUMBERS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_CODEASSIGNS
   FROM HZ_IMP_CLASSIFICS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_RELATIONSHIPS
   FROM HZ_IMP_RELSHIPS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.SUB_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_CONTACTROLES
   FROM HZ_IMP_CONTACTROLES_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.CONTACT_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_CONTACTS
   FROM HZ_IMP_CONTACTS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.CONTACT_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_CONTACTPOINTS
   FROM HZ_IMP_CONTACTPTS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_CREDITRATINGS
   FROM HZ_IMP_CREDITRTNGS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_FINREPORTS
   FROM HZ_IMP_FINREPORTS_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;
  SELECT  count(INT.BATCH_ID) into  l_REMOVED_PARTIES
   FROM HZ_IMP_PARTIES_INT INT
  WHERE INT.BATCH_ID = P_BATCH_ID AND
       INT.PARTY_ORIG_SYSTEM = P_ORIGINAL_SYSTEM
    AND INT.INTERFACE_STATUS = 'R' ;

  -- compute total number of removed recs
  l_removed_by_user :=
    l_REMOVED_ADDRESSUSES +
    l_REMOVED_ADDRESSES +
    l_REMOVED_FINNUMBERS +
    l_REMOVED_CODEASSIGNS +
    l_REMOVED_RELATIONSHIPS +
    l_REMOVED_CONTACTROLES +
    l_REMOVED_CONTACTS +
    l_REMOVED_CONTACTPOINTS +
    l_REMOVED_CREDITRATINGS +
    l_REMOVED_FINREPORTS +
    l_REMOVED_PARTIES ;

   -- update stmt
 UPDATE HZ_IMP_BATCH_SUMMARY SET
  NEW_UNIQUE_ADDRESSUSES = l_NEW_UNIQUE_ADDRESSUSES,
  NEW_UNIQUE_ADDRESSES = l_NEW_UNIQUE_ADDRESSES,
  NEW_UNIQUE_FINNUMBERS = l_NEW_UNIQUE_FINNUMBERS,
  NEW_UNIQUE_CODEASSIGNS = l_NEW_UNIQUE_CODEASSIGNS,
  NEW_UNIQUE_RELATIONSHIPS = l_NEW_UNIQUE_RELATIONSHIPS,
  NEW_UNIQUE_CONTACTROLES = l_NEW_UNIQUE_CONTACTROLES,
  NEW_UNIQUE_CONTACTS = l_NEW_UNIQUE_CONTACTS,
  NEW_UNIQUE_CONTACTPOINTS = l_NEW_UNIQUE_CONTACTPOINTS,
  NEW_UNIQUE_CREDITRATINGS = l_NEW_UNIQUE_CREDITRATINGS,
  NEW_UNIQUE_FINREPORTS = l_NEW_UNIQUE_FINREPORTS,
  NEW_UNIQUE_PARTIES = l_NEW_UNIQUE_PARTIES,
  EXISTING_ADDRESSUSES = l_EXISTING_ADDRESSUSES,
  EXISTING_ADDRESSES = l_EXISTING_ADDRESSES,
  EXISTING_FINNUMBERS = l_EXISTING_FINNUMBERS,
  EXISTING_CODEASSIGNS = l_EXISTING_CODEASSIGNS,
  EXISTING_RELATIONSHIPS = l_EXISTING_RELATIONSHIPS,
  EXISTING_CONTACTROLES = l_EXISTING_CONTACTROLES,
  EXISTING_CONTACTS = l_EXISTING_CONTACTS,
  EXISTING_CONTACTPOINTS = l_EXISTING_CONTACTPOINTS,
  EXISTING_CREDITRATINGS = l_EXISTING_CREDITRATINGS,
  EXISTING_FINREPORTS = l_EXISTING_FINREPORTS,
  EXISTING_PARTIES = l_EXISTING_PARTIES,
    removed_by_user = l_removed_by_user
 WHERE BATCH_ID = P_BATCH_ID;
END what_if_import_counts;

END HZ_IMP_LOAD_BATCH_COUNTS_PKG;

/
