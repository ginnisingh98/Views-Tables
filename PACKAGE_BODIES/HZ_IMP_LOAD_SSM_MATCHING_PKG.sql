--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_SSM_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_SSM_MATCHING_PKG" AS
/*$Header: ARHLSSMB.pls 120.37.12010000.2 2008/10/27 09:40:27 idali ship $*/



   c_end_date                   DATE  := to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI');
   l_no_end_date                DATE := TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');

   PROCEDURE match_parties(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   /******
   Populattion of new_osr_exists_flag for DNB Data
   - The new_osr_exists_flag is populated for the following three cases

   Interface Table Entry:   Party_ID       Party_OSR
                              1000            ABC

   SSM Table Entry:       Owner_table_id   Party_OSR
   a) OSR Collision           1000            CDE  (end-date in import)
                              2000            ABC  (end-date in import)
                           ------------------------------------
                              1000            ABC  (insert in import)
   b) First time DNB for existing data

                           ------------------------------------
                              1000            ABC  (insert in import)
   c) First time DNB for exisitng data, party already exists for the OSR
                              2000            ABC  (end-date in import)
                           ------------------------------------
                              1000            ABC  (insert in import)

   The flag is populated for different values for the above cases, null oterwise
   a) 'Y'
   b) 'E'
   c) 'R'
   ******/

   BEGIN
   if (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN = 'Y') then
     -- re-run for third party vender, OSR change possible
 --dbms_output.put_line('flag 1');
    insert all
    when ( 1 = 1 )
    then
    into hz_imp_parties_sg
    (
       PARTY_ID,
       PARTY_ORIG_SYSTEM,
       PARTY_ORIG_SYSTEM_REFERENCE,
       INT_ROW_ID,
       ACTION_FLAG,
       OLD_ORIG_SYSTEM_REFERENCE,
       new_osr_exists_flag,
       batch_mode_flag,
       batch_id
     ) values
     (
       nvl(party_id,HZ_PARTIES_S.NextVal),
       party_os,
       party_osr,
       int_row_id,
       action_flag,
       old_osr,
       new_osr_exists_flag,
       P_BATCH_MODE_FLAG,
       P_BATCH_ID
     )
    when (
      old_osr is not null
    ) then
    into hz_imp_osr_change (
       entity_name,
       new_osr_exists_flag,
       OLD_ORIG_SYSTEM_REFERENCE,
       NEW_ORIG_SYSTEM_REFERENCE,
       ENTITY_ID,
       BATCH_ID
    ) values
    (  'HZ_PARTIES',
       new_osr_exists_flag,
       old_osr,
       party_osr,
       party_id,
       P_BATCH_ID
    )
       select /*+ leading(p_int) index_asc(p_int) use_nl(mosr) use_nl(mosr2) */
           nvl(p_int.party_id, mosr.owner_table_id) party_id,
           p_int.party_orig_system                                             party_os,
           p_int.party_orig_system_reference                                   party_osr,
           p_int.rowid int_row_id,
           nvl2(nvl(p_int.party_id, mosr.owner_table_id), 'U', 'I')            action_flag,
           -- populate old_osr only if osr change
           nullif(mosr2.orig_system_reference, p_int.party_orig_system_reference) old_osr,
           -- if party id in interface,
           -- populate 'E' if no match for the id at all in mosr table
           -- populate 'Y' if the new osr is occupied by another party
           nvl2(p_int.party_id,
           nvl2(mosr2.orig_system_reference,
                nvl2(nullif(mosr.owner_table_id, p_int.party_id), 'Y', null),
                nvl2(mosr.owner_table_id, 'R', 'E')
                ), null)                                  new_osr_exists_flag
         from hz_imp_parties_int p_int,
              hz_orig_sys_references mosr, -- OSR look up
              hz_orig_sys_references mosr2 -- look up for osr collision
        where p_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and p_int.party_orig_system = mosr.orig_system (+)
          and p_int.party_id = mosr2.owner_table_id (+)
          and p_int.batch_id = P_BATCH_ID
          and p_int.party_orig_system = P_OS
          and p_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          and mosr2.owner_table_name (+) = 'HZ_PARTIES'
          and mosr2.orig_system (+) = P_ACTUAL_CONTENT_SRC
          and mosr2.status (+) = 'A'
          and p_int.interface_status = 'C';
   elsif (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN <> 'Y') then

     -- first run for third party vender, OSR change possible

   --dbms_output.put_line('flag 2');

    insert all
    when ( 1 = 1 )
    then
    into hz_imp_parties_sg
    (
       PARTY_ID,
       PARTY_ORIG_SYSTEM,
       PARTY_ORIG_SYSTEM_REFERENCE,
       INT_ROW_ID,
       ACTION_FLAG,
       OLD_ORIG_SYSTEM_REFERENCE,
       new_osr_exists_flag,
       batch_mode_flag,
       batch_id
     ) values
     (
       nvl(party_id,HZ_PARTIES_S.NextVal),
       party_os,
       party_osr,
       int_row_id,
       action_flag,
       old_osr,
       new_osr_exists_flag,
       P_BATCH_MODE_FLAG,
       P_BATCH_ID
     )
    when (
      old_osr is not null
    ) then
    into hz_imp_osr_change (
       entity_name,
       new_osr_exists_flag,
       OLD_ORIG_SYSTEM_REFERENCE,
       NEW_ORIG_SYSTEM_REFERENCE,
       ENTITY_ID,
       BATCH_ID
    ) values
    (  'HZ_PARTIES',
       new_osr_exists_flag,
       old_osr,
       party_osr,
       party_id,
       P_BATCH_ID
    )
       select /*+ leading(p_int) index_asc(p_int) use_nl(mosr) use_nl(mosr2) */
           nvl(p_int.party_id, mosr.owner_table_id) party_id,
           p_int.party_orig_system                                             party_os,
           p_int.party_orig_system_reference                                   party_osr,
           p_int.rowid int_row_id,
           nvl2(nvl(p_int.party_id, mosr.owner_table_id), 'U', 'I')            action_flag,
           -- populate old_osr only if osr change
           nullif(mosr2.orig_system_reference, p_int.party_orig_system_reference) old_osr,
           -- if party id in interface,
           -- populate 'E' if no match for the id at all in mosr table
           -- populate 'Y' if the new osr is occupied by another party
           nvl2(p_int.party_id,
           nvl2(mosr2.orig_system_reference,
                nvl2(nullif(mosr.owner_table_id, p_int.party_id), 'Y', null),
                nvl2(mosr.owner_table_id, 'R', 'E')
                ), null)                                  new_osr_exists_flag
         from hz_imp_parties_int p_int,
              hz_orig_sys_references mosr, -- OSR look up
              hz_orig_sys_references mosr2 -- look up for osr collision
        where p_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and p_int.party_orig_system = mosr.orig_system (+)
          and p_int.party_id = mosr2.owner_table_id (+)
          and p_int.batch_id = P_BATCH_ID
          and p_int.party_orig_system = P_OS
          and p_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          and mosr2.owner_table_name (+) = 'HZ_PARTIES'
          and mosr2.orig_system (+) = P_ACTUAL_CONTENT_SRC
          and mosr2.status (+) = 'A'
          and p_int.interface_status is null;
   elsif (P_ACTUAL_CONTENT_SRC = 'USER_ENTERED' and P_RERUN = 'Y') then
     -- re-run for legacy system, OSR change ignored

    --dbms_output.put_line('flag 3');

     insert into hz_imp_parties_sg
     (
         PARTY_ID,
         PARTY_ORIG_SYSTEM,
         PARTY_ORIG_SYSTEM_REFERENCE,
         INT_ROW_ID,
         ACTION_FLAG,
         batch_mode_flag,
         batch_id
     )
     (
        select /*+ leading(p_int) index_asc(p_int) use_nl(mosr) */
           nvl(mosr.owner_table_id, HZ_PARTIES_S.NextVal)  party_id,
           p_int.party_orig_system                         party_os,
           p_int.party_orig_system_reference               party_osr,
           p_int.rowid int_row_id,
           nvl2(mosr.owner_table_id, 'U', 'I')             action_flag,
           P_BATCH_MODE_FLAG, P_BATCH_ID
         from hz_imp_parties_int p_int,
              hz_orig_sys_references mosr
        where p_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and p_int.party_orig_system = mosr.orig_system (+)
          and p_int.batch_id = P_BATCH_ID
          and p_int.party_orig_system = P_OS
          and p_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          and p_int.interface_status = 'C'
     );
   else
     -- first run for legacy system, OSR change ignored

      --dbms_output.put_line('flag 4');

     insert into hz_imp_parties_sg
     (
         PARTY_ID,
         PARTY_ORIG_SYSTEM,
         PARTY_ORIG_SYSTEM_REFERENCE,
         INT_ROW_ID,
         ACTION_FLAG,
         batch_mode_flag,
         batch_id
     )
     (
        select /*+ leading(p_int) index_asc(p_int) use_nl(mosr) */
           nvl(mosr.owner_table_id, HZ_PARTIES_S.NextVal)  party_id,
           p_int.party_orig_system                         party_os,
           p_int.party_orig_system_reference               party_osr,
           p_int.rowid int_row_id,
           nvl2(mosr.owner_table_id, 'U', 'I')             action_flag,
           P_BATCH_MODE_FLAG, P_BATCH_ID
         from hz_imp_parties_int p_int,
              hz_orig_sys_references mosr
        where p_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and p_int.party_orig_system = mosr.orig_system (+)
          and p_int.batch_id = P_BATCH_ID
          and p_int.party_orig_system = P_OS
          and p_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          and p_int.interface_status is null
     );
   end if;
   commit;
   end match_parties;


   PROCEDURE match_addresses(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   /*
           Fix bug 4374278: If party_id is passed from address_int table, check if the
           party_id is valid. If party_id is not passed, retain original
           testing.
   */
   if (P_RERUN = 'Y') then
     -- re-run
    insert all
    when ( 1 = 1 )
    then
    into hz_imp_addresses_sg
    (
          PARTY_ID,
          party_orig_system,
          PARTY_ORIG_SYSTEM_REFERENCE,
          site_orig_system,
          SITE_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          PARTY_SITE_ID,
          ERROR_FLAG,
          PARTY_ACTION_FLAG,
          OLD_SITE_ORIG_SYSTEM_REF,
          new_osr_exists_flag,
          BATCH_ID,
          BATCH_MODE_FLAG,
          PRIMARY_FLAG
    ) values
    (
          pid, pos, posr,
          psos, psosr,
          int_row_id, action_flag,
          nvl(party_site_id, hz_party_sites_s.nextval),
          error_flag, party_action_flag,
          old_psosr, overwrite_osr_flag,
          P_BATCH_ID, P_BATCH_MODE_FLAG,
          primary_flag
    )
    when (
     psosr <> old_psosr
    ) then
    into hz_imp_osr_change (
       entity_name,
       new_osr_exists_flag,
       OLD_ORIG_SYSTEM_REFERENCE,
       NEW_ORIG_SYSTEM_REFERENCE,
       ENTITY_ID,
       BATCH_ID,
       PARTY_ID
    ) values
    (  'HZ_PARTY_SITES',
       overwrite_osr_flag,
       old_psosr,
       psosr,
       nvl(party_site_id, hz_party_sites_s.nextval),
       P_BATCH_ID, pid
    )
select /*+ leading(ps_int_w_psosr) use_nl(psosr_mosr,hz_ps) index(hz_ps, hz_party_sites_n4) */
	      ps_int_w_psosr.pid, ps_int_w_psosr.pos, ps_int_w_psosr.posr,
          ps_int_w_psosr.psos, ps_int_w_psosr.psosr,
	      ps_int_w_psosr.int_row_id,
          nvl2(psosr_mosr.owner_table_id,decode(ps_int_w_psosr.owning_pty_chg_flag,'Y','I','U'),'I') action_flag,
          nvl2(ps_int_w_psosr.owning_pty_chg_flag,null,psosr_mosr.owner_table_id) party_site_id,
          --nvl(psosr_mosr.owner_table_id, hz_party_sites_s.nextval) party_site_id,
	  --psosr_mosr.owner_table_id party_site_id, -- Bug6082657
              DECODE (ps_int_w_psosr.ps_int_pid, NULL, nvl2(nullif(psosr_mosr.party_id, ps_int_w_psosr.pid), 2, null),
          	    NVL2(p.party_id, NULL, 3) ) error_flag,
             ps_int_w_psosr.party_action_flag,
	      ps_int_w_psosr.final_psosr old_psosr,
	      ps_int_w_psosr.psg_new_osr_flag overwrite_osr_flag,
          -- parttition by id to select one primary per party
          nvl2(hz_ps.party_site_id, null,
            decode(row_number() over
                   (partition by ps_int_w_psosr.pid order by
	                ps_int_w_psosr.primary_flag
                   desc nulls last),
	               1, 'Y', null)) primary_flag
	 from hz_orig_sys_references psosr_mosr,
          hz_party_sites hz_ps,
	      (
	   select /*+ no_merge leading(ps_int) index_asc(ps_int) use_hash(psg) use_nl(mosr) */
		     ps_int.rowid int_row_id,
             -- note osr_change.entity_id must come before mosr
             -- in case of osr collision mosr.owner_table_id is not correct
             nvl(nvl(nvl(ps_int.party_id, psg.party_id), osr_change_tbl.entity_id), mosr.owner_table_id) pid,
             ps_int.party_id ps_int_pid,
             mosr.owner_table_id mosr_pid,
		     ps_int.party_orig_system_reference posr,
		     ps_int.party_orig_system pos,
		     ps_int.site_orig_system_reference psosr,
		     ps_int.site_orig_system psos,
             -- the psosr to match, changed back to old osr for osr change case
             decode(osr_change_tbl.old_orig_system_reference, null,
		     ps_int.site_orig_system_reference,
		     osr_change_tbl.old_orig_system_reference || substr(
		     ps_int.site_orig_system_reference, instr(
		     ps_int.site_orig_system_reference, '-'))) final_psosr,
                     nvl2(ps_int.party_id,'U',nvl(psg.action_flag, 'U')) party_action_flag,
		     osr_change_tbl.new_osr_exists_flag psg_new_osr_flag,
		     ps_int.primary_flag primary_flag,
                     nvl2(nullif(ps_int.party_id,mosr.owner_table_id),'Y',null) owning_pty_chg_flag
		from hz_imp_addresses_int ps_int,
		     hz_imp_parties_sg psg,
		     hz_orig_sys_references mosr,
             hz_imp_osr_change osr_change_tbl
	   where mosr.owner_table_name (+) = 'HZ_PARTIES'
		 and mosr.status (+) = 'A'
		 and ps_int.batch_id = P_BATCH_ID
		 and ps_int.party_orig_system = P_OS
		 and ps_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		 and ps_int.party_orig_system_reference = psg.party_orig_system_reference (+)
         and psg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
         and psg.party_orig_system (+) = P_OS
         and psg.batch_id(+) = P_BATCH_ID
		 and ps_int.party_orig_system = psg.party_orig_system (+)
		 and ps_int.batch_id = psg.batch_id(+)
		 and psg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
		 and psg.action_flag(+) = 'I'
		 and ps_int.party_orig_system_reference = mosr.orig_system_reference (+)
		 and ps_int.party_orig_system = mosr.orig_system (+)
		 and ps_int.interface_status = 'C'
		 and ps_int.party_orig_system_reference = osr_change_tbl.new_orig_system_reference (+)
         and osr_change_tbl.entity_name (+) = 'HZ_PARTIES'
         and osr_change_tbl.batch_id (+) = P_BATCH_ID
       ) ps_int_w_psosr,
       hz_parties p
	where ps_int_w_psosr.psos = psosr_mosr.orig_system (+)
	  and ps_int_w_psosr.final_psosr =
	      psosr_mosr.orig_system_reference (+)
	  and psosr_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
	  and psosr_mosr.status (+) = 'A'
      and ps_int_w_psosr.pid = hz_ps.party_id (+)
      and 'Y' = hz_ps.identifying_address_flag (+)
      and 'A' = hz_ps.status (+)
      AND ps_int_w_psosr.ps_int_pid = p.party_id (+);
   else
     -- first run
    insert all
    when ( 1 = 1 )
    then
    into hz_imp_addresses_sg
    (
          PARTY_ID,
          party_orig_system,
          PARTY_ORIG_SYSTEM_REFERENCE,
          site_orig_system,
          SITE_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          PARTY_SITE_ID,
          ERROR_FLAG,
          PARTY_ACTION_FLAG,
          OLD_SITE_ORIG_SYSTEM_REF,
          new_osr_exists_flag,
          BATCH_ID,
          BATCH_MODE_FLAG,
          PRIMARY_FLAG
    ) values
    (
          pid, pos, posr,
          psos, psosr,
          int_row_id, action_flag,
          nvl(party_site_id, hz_party_sites_s.nextval),
          error_flag, party_action_flag,
          old_psosr, overwrite_osr_flag,
          P_BATCH_ID, P_BATCH_MODE_FLAG,
          primary_flag
    )
    when (
     psosr <> old_psosr
    ) then
    into hz_imp_osr_change (
       entity_name,
       new_osr_exists_flag,
       OLD_ORIG_SYSTEM_REFERENCE,
       NEW_ORIG_SYSTEM_REFERENCE,
       ENTITY_ID,
       BATCH_ID, PARTY_ID
    ) values
    (  'HZ_PARTY_SITES',
       overwrite_osr_flag,
       old_psosr,
       psosr,
       nvl(party_site_id, hz_party_sites_s.nextval),
       P_BATCH_ID, pid
    )
select /*+ leading(ps_int_w_psosr) use_nl(psosr_mosr,hz_ps) index(hz_ps, hz_party_sites_n4) */
	      ps_int_w_psosr.pid, ps_int_w_psosr.pos, ps_int_w_psosr.posr,
          ps_int_w_psosr.psos, ps_int_w_psosr.psosr,
	      ps_int_w_psosr.int_row_id,
          nvl2(psosr_mosr.owner_table_id,decode(ps_int_w_psosr.owning_pty_chg_flag,'Y','I','U'),'I') action_flag,
          nvl2(ps_int_w_psosr.owning_pty_chg_flag,null,psosr_mosr.owner_table_id) party_site_id,
          --nvl(psosr_mosr.owner_table_id, hz_party_sites_s.nextval) party_site_id,
	  --psosr_mosr.owner_table_id party_site_id,   -- Bug6082657
              DECODE (ps_int_w_psosr.ps_int_pid, NULL, nvl2(nullif(psosr_mosr.party_id, ps_int_w_psosr.pid), 2, null),
	            NVL2(p.party_id, NULL, 3) ) error_flag,
              ps_int_w_psosr.party_action_flag,
	      ps_int_w_psosr.final_psosr old_psosr,
	      ps_int_w_psosr.psg_new_osr_flag overwrite_osr_flag,
          -- parttition by id to select one primary per party
          nvl2(hz_ps.party_site_id, null,
            decode(row_number() over
                   (partition by ps_int_w_psosr.pid order by
	                ps_int_w_psosr.primary_flag
                   desc nulls last),
	               1, 'Y', null)) primary_flag
	 from hz_orig_sys_references psosr_mosr,
          hz_party_sites hz_ps,
	      (
	   select /*+ no_merge leading(ps_int) index_asc(ps_int) use_hash(psg) use_nl(mosr) */
		     ps_int.rowid int_row_id,
             -- note osr_change.entity_id must come before mosr
             -- in case of osr collision mosr.owner_table_id is not correct
             nvl(nvl(nvl(ps_int.party_id, psg.party_id), osr_change_tbl.entity_id), mosr.owner_table_id) pid,
             ps_int.party_id ps_int_pid,
             mosr.owner_table_id mosr_pid,
		     ps_int.party_orig_system_reference posr,
		     ps_int.party_orig_system pos,
		     ps_int.site_orig_system_reference psosr,
		     ps_int.site_orig_system psos,
             -- the psosr to match, changed back to old osr for osr change case
             decode(osr_change_tbl.old_orig_system_reference, null,
		     ps_int.site_orig_system_reference,
		     osr_change_tbl.old_orig_system_reference || substr(
		     ps_int.site_orig_system_reference, instr(
		     ps_int.site_orig_system_reference, '-'))) final_psosr,
                     nvl2(ps_int.party_id,'U',nvl(psg.action_flag, 'U')) party_action_flag,
		     osr_change_tbl.new_osr_exists_flag psg_new_osr_flag,
		     ps_int.primary_flag primary_flag,
                     nvl2(nullif(ps_int.party_id,mosr.owner_table_id),'Y',null) owning_pty_chg_flag
		from hz_imp_addresses_int ps_int,
		     hz_imp_parties_sg psg,
		     hz_orig_sys_references mosr,
             hz_imp_osr_change osr_change_tbl
	   where mosr.owner_table_name (+) = 'HZ_PARTIES'
		 and mosr.status (+) = 'A'
		 and ps_int.batch_id = P_BATCH_ID
		 and ps_int.party_orig_system = P_OS
		 and ps_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		 and ps_int.party_orig_system_reference = psg.party_orig_system_reference (+)
         and psg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
         and psg.party_orig_system (+) = P_OS
         and psg.batch_id(+) = P_BATCH_ID
		 and ps_int.party_orig_system = psg.party_orig_system (+)
		 and ps_int.batch_id = psg.batch_id(+)
		 and psg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
		 and psg.action_flag(+) = 'I'
		 and ps_int.party_orig_system_reference = mosr.orig_system_reference (+)
		 and ps_int.party_orig_system = mosr.orig_system (+)
		 and ps_int.interface_status is null
		 and ps_int.party_orig_system_reference = osr_change_tbl.new_orig_system_reference (+)
         and osr_change_tbl.entity_name (+) = 'HZ_PARTIES'
         and osr_change_tbl.batch_id (+) = P_BATCH_ID
       ) ps_int_w_psosr,
       hz_parties p
	where ps_int_w_psosr.psos = psosr_mosr.orig_system (+)
	  and ps_int_w_psosr.final_psosr =
	      psosr_mosr.orig_system_reference (+)
	  and psosr_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
	  and psosr_mosr.status (+) = 'A'
      and ps_int_w_psosr.pid = hz_ps.party_id (+)
      and 'Y' = hz_ps.identifying_address_flag (+)
      and 'A' = hz_ps.status (+)
      AND ps_int_w_psosr.ps_int_pid = p.party_id (+)
      ;
   end if;
   commit;
   end match_addresses;


   PROCEDURE match_contact_points(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN

   if (P_RERUN = 'Y') then
     -- re-run
   INSERT INTO HZ_IMP_CONTACTPTS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          PARTY_SITE_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          CONTACT_POINT_ID,
          ERROR_FLAG,
          PARTY_ACTION_FLAG,
          OLD_CP_ORIG_SYSTEM_REF,
          new_osr_exists_flag,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG,
          CONTACT_POINT_TYPE
     )
     (
select /*+ leading(cpi_cosr) use_nl(asg, ps_mosr, cp_mosr, hz_cpt_pri) index(hz_cpt_pri, hz_contact_points_n6) index(asg, hz_imp_addresses_sg_n2) */
       cpi_cosr.pid party_id, cpi_cosr.pos party_os, cpi_cosr.posr,
       nvl(nvl(asg.party_site_id, addr_osr_ch_tbl.entity_id), ps_mosr.owner_table_id) site_id,
       cpi_cosr.int_row_id,
       nvl2(cp_mosr.owner_table_id, decode(cpi_cosr.owning_pty_chg_flag,'Y','I','U'), 'I') action_flag,
       nvl(nvl2(cpi_cosr.owning_pty_chg_flag,null,cp_mosr.owner_table_id),hz_contact_points_s.nextval) cp_id,
--       nvl(cp_mosr.owner_table_id, hz_contact_points_s.nextval) cp_id, -- Bug6082657
       nvl2(nullif(ps_mosr.party_id,cpi_cosr.pid), 2, null) error_flag,
       cpi_cosr.party_action_flag party_action_flag,
       decode(cpi_cosr.old_posr, null, cpi_cosr.new_cosr, cpi_cosr.old_posr ||
       substr(cpi_cosr.new_cosr, instr(cpi_cosr.new_cosr, '-'))) old_cp_osr,
       cpi_cosr.new_osr_exists_flag, p_batch_mode_flag, p_batch_id,
       nvl2(hz_cpt_pri.owner_table_id,null,
       -- partition by party id and contact point type, select a primary per
       -- party and per type
       decode(row_number() over
         (partition by
         cpi_cosr.pid, cpi_cosr.contact_point_type
         order by nvl2(cp_mosr.owner_table_id,
         null,cpi_cosr.primary_flag
         ) desc nulls last,
       cp_mosr.owner_table_id nulls last), 1, 'Y', null) ) primary_flag,
       cpi_cosr.contact_point_type
  from hz_imp_addresses_sg asg,
       hz_imp_osr_change addr_osr_ch_tbl,
       hz_contact_points hz_cpt_pri,
       hz_orig_sys_references ps_mosr,
       hz_orig_sys_references cp_mosr,
       (
       select /*+ no_merge leading(cp_int) index_asc(cp_int) use_hash(psg) use_nl(mosr) */
	      cp_int.party_orig_system_reference posr,
              cp_int.rowid int_row_id, cp_int.cp_orig_system cos,
	      cp_int.site_orig_system los, cp_int.party_orig_system pos,
	      party_osr_ch_tbl.old_orig_system_reference old_posr,
	      cp_int.cp_orig_system_reference new_cosr,
	      cp_int.site_orig_system_reference new_losr,
          nvl(nvl(nvl(cp_int.party_id, psg.party_id), party_osr_ch_tbl.entity_id), mosr.owner_table_id) pid,
          nvl2(cp_int.party_id,'U',nvl(psg.action_flag, 'U')) party_action_flag,
          party_osr_ch_tbl.new_osr_exists_flag, cp_int.primary_flag,
          cp_int.batch_id, cp_int.contact_point_type,
          nvl2(nullif(cp_int.party_id,mosr.owner_table_id),'Y',null) owning_pty_chg_flag
         from hz_imp_contactpts_int cp_int,
              hz_imp_parties_sg psg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change party_osr_ch_tbl
        where cp_int.interface_status = 'C'
          and cp_int.batch_id = P_BATCH_ID
          and cp_int.party_orig_system = P_OS
          and cp_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and psg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and psg.party_orig_system (+) = P_OS
          and psg.batch_id(+) = P_BATCH_ID
		  and party_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and party_osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and party_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cp_int.party_orig_system_reference
          and cp_int.party_orig_system_reference = psg.party_orig_system_reference (+)
          and cp_int.party_orig_system = psg.party_orig_system (+)
          and cp_int.batch_id = psg.batch_id (+)
          and psg.batch_mode_flag (+) = P_BATCH_MODE_FLAG
          and psg.action_flag (+) = 'I'
          and cp_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and cp_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) cpi_cosr
        where cpi_cosr.new_losr = asg.site_orig_system_reference (+)
          and cpi_cosr.los = asg.site_orig_system (+)
          and cpi_cosr.batch_id = asg.batch_id (+)
		  and addr_osr_ch_tbl.entity_name (+) = 'HZ_PARTY_SITES'
          and addr_osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and addr_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cpi_cosr.new_losr
          and asg.batch_mode_flag (+) = P_BATCH_MODE_FLAG
          and asg.action_flag (+) = 'I'
          and decode(cpi_cosr.old_posr, null, cpi_cosr.new_losr,
              cpi_cosr.old_posr || substr(cpi_cosr.new_losr, instr(
              cpi_cosr.new_losr, '-'))) = ps_mosr.orig_system_reference (+)
          and cpi_cosr.los = ps_mosr.orig_system (+)
          and decode(cpi_cosr.old_posr, null, cpi_cosr.new_cosr,
              cpi_cosr.old_posr || substr(cpi_cosr.new_cosr, instr(
              cpi_cosr.new_cosr, '-'))) = cp_mosr.orig_system_reference (+)
          and cpi_cosr.cos = cp_mosr.orig_system (+)
          and ps_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
          and ps_mosr.status (+) = 'A'
          and cp_mosr.owner_table_name (+) = 'HZ_CONTACT_POINTS'
          and cp_mosr.status (+) = 'A'
          and hz_cpt_pri.owner_table_name (+) = 'HZ_PARTIES'
          and hz_cpt_pri.owner_table_id (+) = cpi_cosr.pid
	      and hz_cpt_pri.contact_point_type  (+) = cpi_cosr.contact_point_type
          and hz_cpt_pri.primary_flag (+) = 'Y'
          and hz_cpt_pri.status (+) = 'A'
       );
   else
     -- first run
INSERT INTO HZ_IMP_CONTACTPTS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          PARTY_SITE_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          CONTACT_POINT_ID,
          ERROR_FLAG,
          PARTY_ACTION_FLAG,
          OLD_CP_ORIG_SYSTEM_REF,
          new_osr_exists_flag,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG,
          CONTACT_POINT_TYPE
     )
     (
select /*+ leading(cpi_cosr) use_nl(asg, ps_mosr, cp_mosr, hz_cpt_pri) index(hz_cpt_pri, hz_contact_points_n6) index(asg, hz_imp_addresses_sg_n2) */
       cpi_cosr.pid party_id, cpi_cosr.pos party_os, cpi_cosr.posr,
       nvl(nvl(asg.party_site_id, addr_osr_ch_tbl.entity_id), ps_mosr.owner_table_id) site_id,
       cpi_cosr.int_row_id,
       nvl2(cp_mosr.owner_table_id,decode(cpi_cosr.owning_pty_chg_flag,'Y','I','U'), 'I') action_flag,
       nvl(nvl2(cpi_cosr.owning_pty_chg_flag,null,cp_mosr.owner_table_id),hz_contact_points_s.nextval) cp_id,
       -- nvl(cp_mosr.owner_table_id, hz_contact_points_s.nextval) cp_id, --Bug6082657
       nvl2(nullif(ps_mosr.party_id,cpi_cosr.pid), 2, null) error_flag,
       cpi_cosr.party_action_flag party_action_flag,
       decode(cpi_cosr.old_posr, null, cpi_cosr.new_cosr, cpi_cosr.old_posr ||
       substr(cpi_cosr.new_cosr, instr(cpi_cosr.new_cosr, '-'))) old_cp_osr,
       cpi_cosr.new_osr_exists_flag, p_batch_mode_flag, p_batch_id,
       nvl2(hz_cpt_pri.owner_table_id,null,
       -- partition by party id and contact point type, select a primary per
       -- party and per type
       decode(row_number() over
         (partition by
         cpi_cosr.pid, cpi_cosr.contact_point_type
         order by nvl2(cp_mosr.owner_table_id,
         null,cpi_cosr.primary_flag
         ) desc nulls last,
       cp_mosr.owner_table_id nulls last), 1, 'Y', null) ) primary_flag,
       cpi_cosr.contact_point_type
  from hz_imp_addresses_sg asg,
       hz_imp_osr_change addr_osr_ch_tbl,
       hz_contact_points hz_cpt_pri,
       hz_orig_sys_references ps_mosr,
       hz_orig_sys_references cp_mosr,
       (
       select /*+ no_merge leading(cp_int) index_asc(cp_int) use_hash(psg) use_nl(mosr) */
	      cp_int.party_orig_system_reference posr,
              cp_int.rowid int_row_id, cp_int.cp_orig_system cos,
	      cp_int.site_orig_system los, cp_int.party_orig_system pos,
	      party_osr_ch_tbl.old_orig_system_reference old_posr,
	      cp_int.cp_orig_system_reference new_cosr,
	      cp_int.site_orig_system_reference new_losr,
          nvl(nvl(nvl(cp_int.party_id, psg.party_id), party_osr_ch_tbl.entity_id), mosr.owner_table_id) pid,
          nvl2(cp_int.party_id,'U',nvl(psg.action_flag, 'U')) party_action_flag,
          party_osr_ch_tbl.new_osr_exists_flag, cp_int.primary_flag,
          cp_int.batch_id, cp_int.contact_point_type,
          nvl2(nullif(cp_int.party_id,mosr.owner_table_id),'Y',null) owning_pty_chg_flag
         from hz_imp_contactpts_int cp_int,
              hz_imp_parties_sg psg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change party_osr_ch_tbl
        where cp_int.interface_status is null
          and cp_int.batch_id = P_BATCH_ID
          and cp_int.party_orig_system = P_OS
          and cp_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and psg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and psg.party_orig_system (+) = P_OS
          and psg.batch_id(+) = P_BATCH_ID
		  and party_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and party_osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and party_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cp_int.party_orig_system_reference
          and cp_int.party_orig_system_reference = psg.party_orig_system_reference (+)
          and cp_int.party_orig_system = psg.party_orig_system (+)
          and cp_int.batch_id = psg.batch_id (+)
          and psg.batch_mode_flag (+) = P_BATCH_MODE_FLAG
          and psg.action_flag (+) = 'I'
          and cp_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and cp_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) cpi_cosr
        where cpi_cosr.new_losr = asg.site_orig_system_reference (+)
          and cpi_cosr.los = asg.site_orig_system (+)
          and cpi_cosr.batch_id = asg.batch_id (+)
		  and addr_osr_ch_tbl.entity_name (+) = 'HZ_PARTY_SITES'
          and addr_osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and addr_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cpi_cosr.new_losr
          and asg.batch_mode_flag (+) = P_BATCH_MODE_FLAG
          and asg.action_flag (+) = 'I'
          and decode(cpi_cosr.old_posr, null, cpi_cosr.new_losr,
              cpi_cosr.old_posr || substr(cpi_cosr.new_losr, instr(
              cpi_cosr.new_losr, '-'))) = ps_mosr.orig_system_reference (+)
          and cpi_cosr.los = ps_mosr.orig_system (+)
          and decode(cpi_cosr.old_posr, null, cpi_cosr.new_cosr,
              cpi_cosr.old_posr || substr(cpi_cosr.new_cosr, instr(
              cpi_cosr.new_cosr, '-'))) = cp_mosr.orig_system_reference (+)
          and cpi_cosr.cos = cp_mosr.orig_system (+)
          and ps_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
          and ps_mosr.status (+) = 'A'
          and cp_mosr.owner_table_name (+) = 'HZ_CONTACT_POINTS'
          and cp_mosr.status (+) = 'A'
          and hz_cpt_pri.owner_table_name (+) = 'HZ_PARTIES'
          and hz_cpt_pri.owner_table_id (+) = cpi_cosr.pid
	      and hz_cpt_pri.contact_point_type  (+) = cpi_cosr.contact_point_type
          and hz_cpt_pri.primary_flag (+) = 'Y'
          and hz_cpt_pri.status (+) = 'A'
       );
   end if;
   commit;
   end match_contact_points;


   PROCEDURE match_credit_ratings(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_DEF_START_TIME             IN       DATE,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   if(P_RERUN = 'Y') then
     -- re-run
     INSERT INTO HZ_IMP_CREDITRTNGS_SG
     (
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CREDIT_RATING_ID,
          BATCH_ID,
          BATCH_MODE_FLAG
     )
     (
  select /*+ leading(cr_int_w_pid) use_nl(hz_cr) */
       cr_int_w_pid.pid                                         pid,
       cr_int_w_pid.party_os                                    party_os,
       cr_int_w_pid.party_osr                                   party_osr,
       cr_int_w_pid.int_row_id                                  int_row_id,
       nvl2(hz_cr.credit_rating_id, 'U', 'I')                   action_flag,
       nvl(hz_cr.credit_rating_id, hz_credit_ratings_s.NextVal) cr_id,
       P_BATCH_ID, P_BATCH_MODE_FLAG
  from HZ_CREDIT_RATINGS HZ_CR,
       (select /*+ leading(cr_int) index_asc(cr_int) use_hash(party_sg) use_nl(mosr) */
	      nvl(nvl(nvl(cr_int.party_id, party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              cr_int.party_orig_system party_os,
	      cr_int.party_orig_system_reference party_osr,
	      cr_int.rated_as_of_date, cr_int.rating_organization
	      rating_org, cr_int.rowid int_row_id
         from hz_imp_creditrtngs_int cr_int,
              hz_imp_parties_sg party_sg,
	          hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where cr_int.interface_status = 'C'
          and cr_int.batch_id = P_BATCH_ID
          and cr_int.party_orig_system = P_OS
          and cr_int.batch_id = party_sg.batch_id(+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cr_int.party_orig_system_reference
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
	      and cr_int.party_orig_system_reference between p_from_osr and p_to_osr
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and cr_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and cr_int.party_orig_system = mosr.orig_system (+)
	      and mosr.owner_table_name (+) = 'HZ_PARTIES'
	      and mosr.status (+) = 'A'
          and cr_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and cr_int.party_orig_system = party_sg.party_orig_system (+)
      ) cr_int_w_pid
 where cr_int_w_pid.pid = hz_cr.party_id (+)
   and cr_int_w_pid.rating_org = hz_cr.rating_organization (+)
   and trunc(nvl(cr_int_w_pid.rated_as_of_date, P_DEF_START_TIME)) =
       trunc(hz_cr.rated_as_of_date (+))
   and HZ_CR.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC);
   else
     -- frist run
     INSERT INTO HZ_IMP_CREDITRTNGS_SG
     (
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CREDIT_RATING_ID,
          BATCH_ID,
          BATCH_MODE_FLAG
     )
     (
  select /*+ leading(cr_int_w_pid) use_nl(hz_cr) */
       cr_int_w_pid.pid                                         pid,
       cr_int_w_pid.party_os                                    party_os,
       cr_int_w_pid.party_osr                                   party_osr,
       cr_int_w_pid.int_row_id                                  int_row_id,
       nvl2(hz_cr.credit_rating_id, 'U', 'I')                   action_flag,
       nvl(hz_cr.credit_rating_id, hz_credit_ratings_s.NextVal) cr_id,
       P_BATCH_ID, P_BATCH_MODE_FLAG
  from HZ_CREDIT_RATINGS HZ_CR,
       (select /*+ leading(cr_int) index_asc(cr_int) use_hash(party_sg) use_nl(mosr) */
	      nvl(nvl(nvl(cr_int.party_id, party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              cr_int.party_orig_system party_os,
	      cr_int.party_orig_system_reference party_osr,
	      cr_int.rated_as_of_date, cr_int.rating_organization
	      rating_org, cr_int.rowid int_row_id
         from hz_imp_creditrtngs_int cr_int,
              hz_imp_parties_sg party_sg,
	          hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where cr_int.interface_status is null
          and cr_int.batch_id = P_BATCH_ID
          and cr_int.party_orig_system = P_OS
          and cr_int.batch_id = party_sg.batch_id(+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  cr_int.party_orig_system_reference
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
	      and cr_int.party_orig_system_reference between p_from_osr and p_to_osr
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and cr_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and cr_int.party_orig_system = mosr.orig_system (+)
	      and mosr.owner_table_name (+) = 'HZ_PARTIES'
	      and mosr.status (+) = 'A'
          and cr_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and cr_int.party_orig_system = party_sg.party_orig_system (+)
      ) cr_int_w_pid
 where cr_int_w_pid.pid = hz_cr.party_id (+)
   and cr_int_w_pid.rating_org = hz_cr.rating_organization (+)
   and trunc(nvl(cr_int_w_pid.rated_as_of_date, P_DEF_START_TIME)) =
       trunc(hz_cr.rated_as_of_date (+))
   and HZ_CR.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC);
   end if;
   commit;
   end match_credit_ratings;


   PROCEDURE match_code_assignments(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   if (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN = 'Y') then
     -- re-run/DNB
     INSERT INTO HZ_IMP_CLASSIFICS_SG
     (    CLASS_CATEGORY,
          CLASS_CODE,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CODE_ASSIGNMENT_ID,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG
     )
     (
select /*+ leading(ca_int_w_pid) use_nl(hz_ca) */
       ca_int_w_pid.class_category, ca_int_w_pid.class_code,
       ca_int_w_pid.start_date_active, ca_int_w_pid.end_date_active,
       ca_int_w_pid.pid, ca_int_w_pid.party_os, ca_int_w_pid.party_osr,
       ca_int_w_pid.int_row_id, nvl2(hz_ca.code_assignment_id, 'U', 'I')
       action_flag, nvl(hz_ca.code_assignment_id,
       hz_code_assignments_s.nextval) ca_id, p_batch_mode_flag, p_batch_id,
       -- set as not primary if already a primary,
       -- pick on primary per party per class category
       -- if any of the code assignment set as primary in interface
        nvl2(hz_ca3.code_assignment_id, null,
          decode(row_number() over
          (partition by  pid, ca_int_w_pid.class_category
           order by ca_int_w_pid.primary_flag
          desc nulls last),
	      1, ca_int_w_pid.primary_flag, null)) primary_flag
  from hz_code_assignments hz_ca,
       hz_code_assignments hz_ca3,
       (
       select /*+ leading(ca_int) index_asc(ca_int) use_hash(party_sg) use_nl(mosr) */
              nvl(nvl(nvl(ca_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              ca_int.party_orig_system party_os,
              ca_int.party_orig_system_reference party_osr,
              ca_int.class_code,
              ca_int.start_date_active start_date_active,
              ca_int.end_date_active end_date_active,
              ca_int.rowid int_row_id,
          case when ca_int.class_category
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else ca_int.class_category end class_category,
          ca_int.primary_flag
         from hz_imp_classifics_int ca_int,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where ca_int.interface_status = 'C'
          and ca_int.batch_id = p_batch_id
          and ca_int.party_orig_system = p_os
          and ca_int.party_orig_system_reference between p_from_osr and p_to_osr
          and ca_int.batch_id = party_sg.batch_id (+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ca_int.party_orig_system_reference
          and party_sg.batch_mode_flag (+) = p_batch_mode_flag
          and party_sg.action_flag (+) = 'I'
          and ca_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and ca_int.party_orig_system = party_sg.party_orig_system (+)
          and ca_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and ca_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) ca_int_w_pid
        where ca_int_w_pid.pid = hz_ca.owner_table_id (+)
          --and ca_int_w_pid.class_category = hz_ca.class_category (+)
          and (case when hz_ca.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca.class_category (+) end ) =
              ca_int_w_pid.class_category
          and ca_int_w_pid.class_code = hz_ca.class_code (+)

          --wawong: ignore start data for DNB data
          --and trunc(ca_int_w_pid.start_date_active) = trunc(hz_ca.start_date_active (+))
          and nvl(hz_ca.end_date_active (+),c_end_date )  = c_end_date

          and hz_ca.owner_table_name (+) = 'HZ_PARTIES'
          /* Bug 4979902 */
          --and hz_ca.content_source_type (+) = p_actual_content_src
          and hz_ca.actual_content_source (+) = p_actual_content_src
          and hz_ca3.owner_table_name (+) = 'HZ_PARTIES'
          and hz_ca3.owner_table_id (+) = ca_int_w_pid.pid
          and nvl(hz_ca3.end_date_active (+),c_end_date )  = c_end_date
          and (case when hz_ca3.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca3.class_category (+) end ) =
              ca_int_w_pid.class_category
          and hz_ca3.primary_flag (+) = 'Y'
          and hz_ca3.status (+) = 'A'
   );
   elsif (P_ACTUAL_CONTENT_SRC = 'USER_ENTERED' and P_RERUN = 'Y') then
   -- re-run/NON-DNB
     INSERT INTO HZ_IMP_CLASSIFICS_SG
     (    CLASS_CATEGORY,
          CLASS_CODE,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CODE_ASSIGNMENT_ID,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG
     )
     (
select /*+ leading(ca_int_w_pid) use_nl(hz_ca) */
       ca_int_w_pid.class_category, ca_int_w_pid.class_code,
       ca_int_w_pid.start_date_active, ca_int_w_pid.end_date_active,
       ca_int_w_pid.pid, ca_int_w_pid.party_os, ca_int_w_pid.party_osr,
       ca_int_w_pid.int_row_id, nvl2(hz_ca.code_assignment_id, 'U', 'I')
       action_flag, nvl(hz_ca.code_assignment_id,
       hz_code_assignments_s.nextval) ca_id, p_batch_mode_flag, p_batch_id,
       -- set as not primary if already a primary,
       -- pick on primary per party per class category
       -- if any of the code assignment set as primary in interface
        nvl2(hz_ca3.code_assignment_id, null,
          decode(row_number() over
          (partition by  pid, ca_int_w_pid.class_category
           order by ca_int_w_pid.primary_flag
          desc nulls last),
	      1, ca_int_w_pid.primary_flag, null)) primary_flag
  from hz_code_assignments hz_ca,
       hz_code_assignments hz_ca3,
       (
       select /*+ leading(ca_int) index_asc(ca_int) use_hash(party_sg) use_nl(mosr) */
              nvl(nvl(nvl(ca_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              ca_int.party_orig_system party_os,
              ca_int.party_orig_system_reference party_osr,
              ca_int.class_code,
              ca_int.start_date_active start_date_active,
              ca_int.end_date_active end_date_active,
              ca_int.rowid int_row_id,
          case when ca_int.class_category
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else ca_int.class_category end class_category,
          ca_int.primary_flag
         from hz_imp_classifics_int ca_int,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where ca_int.interface_status = 'C'
          and ca_int.batch_id = p_batch_id
          and ca_int.party_orig_system = p_os
          and ca_int.party_orig_system_reference between p_from_osr and p_to_osr
          and ca_int.batch_id = party_sg.batch_id (+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ca_int.party_orig_system_reference
          and party_sg.batch_mode_flag (+) = p_batch_mode_flag
          and party_sg.action_flag (+) = 'I'
          and ca_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and ca_int.party_orig_system = party_sg.party_orig_system (+)
          and ca_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and ca_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) ca_int_w_pid
        where ca_int_w_pid.pid = hz_ca.owner_table_id (+)
          --and ca_int_w_pid.class_category = hz_ca.class_category (+)
          and (case when hz_ca.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca.class_category (+) end ) =
              ca_int_w_pid.class_category
          and ca_int_w_pid.class_code = hz_ca.class_code (+)

          --wawong: ignore start data for DNB data
          and trunc(ca_int_w_pid.start_date_active) = trunc(hz_ca.start_date_active (+))
          --and nvl(hz_ca.end_date_active (+),c_end_date )  = c_end_date

          and hz_ca.owner_table_name (+) = 'HZ_PARTIES'
           /* Bug 4979902 */
          --and hz_ca.content_source_type (+) = p_actual_content_src
          and hz_ca.actual_content_source (+) = p_actual_content_src
          and hz_ca3.owner_table_name (+) = 'HZ_PARTIES'
          and hz_ca3.owner_table_id (+) = ca_int_w_pid.pid
          and (case when hz_ca3.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca3.class_category (+) end ) =
              ca_int_w_pid.class_category
          and hz_ca3.primary_flag (+) = 'Y'
          and hz_ca3.status (+) = 'A'
   );
   elsif (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN <> 'Y') then
   -- first run/DNB
     INSERT INTO HZ_IMP_CLASSIFICS_SG
     (    CLASS_CATEGORY,
          CLASS_CODE,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CODE_ASSIGNMENT_ID,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG
     )
     (
select /*+ leading(ca_int_w_pid) use_nl(hz_ca) */
       ca_int_w_pid.class_category, ca_int_w_pid.class_code,
       ca_int_w_pid.start_date_active, ca_int_w_pid.end_date_active,
       ca_int_w_pid.pid, ca_int_w_pid.party_os, ca_int_w_pid.party_osr,
       ca_int_w_pid.int_row_id, nvl2(hz_ca.code_assignment_id, 'U', 'I')
       action_flag, nvl(hz_ca.code_assignment_id,
       hz_code_assignments_s.nextval) ca_id, p_batch_mode_flag, p_batch_id,
       -- set as not primary if already a primary,
       -- pick on primary per party per class category
       -- if any of the code assignment set as primary in interface
        nvl2(hz_ca3.code_assignment_id, null,
          decode(row_number() over
          (partition by  pid, ca_int_w_pid.class_category
           order by ca_int_w_pid.primary_flag
          desc nulls last),
	      1, ca_int_w_pid.primary_flag, null)) primary_flag
  from hz_code_assignments hz_ca,
       hz_code_assignments hz_ca3,
       (
       select /*+ leading(ca_int) index_asc(ca_int) use_hash(party_sg) use_nl(mosr) */
              nvl(nvl(nvl(ca_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              ca_int.party_orig_system party_os,
              ca_int.party_orig_system_reference party_osr,
              ca_int.class_code,
              ca_int.start_date_active start_date_active,
              ca_int.end_date_active end_date_active,
              ca_int.rowid int_row_id,
          case when ca_int.class_category
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else ca_int.class_category end class_category,
          ca_int.primary_flag
         from hz_imp_classifics_int ca_int,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where ca_int.interface_status is null
          and ca_int.batch_id = p_batch_id
          and ca_int.party_orig_system = p_os
          and ca_int.party_orig_system_reference between p_from_osr and p_to_osr
          and ca_int.batch_id = party_sg.batch_id (+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ca_int.party_orig_system_reference
          and party_sg.batch_mode_flag (+) = p_batch_mode_flag
          and party_sg.action_flag (+) = 'I'
          and ca_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and ca_int.party_orig_system = party_sg.party_orig_system (+)
          and ca_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and ca_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) ca_int_w_pid
        where ca_int_w_pid.pid = hz_ca.owner_table_id (+)
          --and ca_int_w_pid.class_category = hz_ca.class_category (+)
          and (case when hz_ca.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca.class_category (+) end ) =
              ca_int_w_pid.class_category
          and ca_int_w_pid.class_code = hz_ca.class_code (+)

          --wawong: ignore start data for DNB data
          --and trunc(ca_int_w_pid.start_date_active) = trunc(hz_ca.start_date_active (+))
          and nvl(hz_ca.end_date_active (+),c_end_date )  = c_end_date

          and hz_ca.owner_table_name (+) = 'HZ_PARTIES'
          /* bug 4079902 */
          --and hz_ca.content_source_type (+) = p_actual_content_src
          and hz_ca.actual_content_source (+) = p_actual_content_src
          and hz_ca3.owner_table_name (+) = 'HZ_PARTIES'
          and hz_ca3.owner_table_id (+) = ca_int_w_pid.pid
          and nvl(hz_ca3.end_date_active (+),c_end_date )  = c_end_date
          and (case when hz_ca3.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca3.class_category (+) end ) =
              ca_int_w_pid.class_category
          and hz_ca3.primary_flag (+) = 'Y'
          and hz_ca3.status (+) = 'A'
   );
   else
   -- first run/non-DNB
     INSERT INTO HZ_IMP_CLASSIFICS_SG
     (    CLASS_CATEGORY,
          CLASS_CODE,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          PARTY_ID,
          party_orig_system,
          party_orig_system_reference,
          INT_ROW_ID,
          ACTION_FLAG,
          CODE_ASSIGNMENT_ID,
          BATCH_MODE_FLAG, BATCH_ID,
          PRIMARY_FLAG
     )
     (
select /*+ leading(ca_int_w_pid) use_nl(hz_ca) */
       ca_int_w_pid.class_category, ca_int_w_pid.class_code,
       ca_int_w_pid.start_date_active, ca_int_w_pid.end_date_active,
       ca_int_w_pid.pid, ca_int_w_pid.party_os, ca_int_w_pid.party_osr,
       ca_int_w_pid.int_row_id, nvl2(hz_ca.code_assignment_id, 'U', 'I')
       action_flag, nvl(hz_ca.code_assignment_id,
       hz_code_assignments_s.nextval) ca_id, p_batch_mode_flag, p_batch_id,
       -- set as not primary if already a primary,
       -- pick on primary per party per class category
       -- if any of the code assignment set as primary in interface
        nvl2(hz_ca3.code_assignment_id, null,
          decode(row_number() over
          (partition by  pid, ca_int_w_pid.class_category
           order by ca_int_w_pid.primary_flag
          desc nulls last),
	      1, ca_int_w_pid.primary_flag, null)) primary_flag
  from hz_code_assignments hz_ca,
       hz_code_assignments hz_ca3,
       (
       select /*+ leading(ca_int) index_asc(ca_int) use_hash(party_sg) use_nl(mosr) */
              nvl(nvl(nvl(ca_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
              ca_int.party_orig_system party_os,
              ca_int.party_orig_system_reference party_osr,
              ca_int.class_code,
              ca_int.start_date_active start_date_active,
              ca_int.end_date_active end_date_active,
              ca_int.rowid int_row_id,
          case when ca_int.class_category
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else ca_int.class_category end class_category,
          ca_int.primary_flag
         from hz_imp_classifics_int ca_int,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references mosr,
              hz_imp_osr_change osr_ch_tbl
        where ca_int.interface_status is null
          and ca_int.batch_id = p_batch_id
          and ca_int.party_orig_system = p_os
          and ca_int.party_orig_system_reference between p_from_osr and p_to_osr
          and ca_int.batch_id = party_sg.batch_id (+)
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ca_int.party_orig_system_reference
          and party_sg.batch_mode_flag (+) = p_batch_mode_flag
          and party_sg.action_flag (+) = 'I'
          and ca_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and ca_int.party_orig_system = party_sg.party_orig_system (+)
          and ca_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and ca_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
          ) ca_int_w_pid
        where ca_int_w_pid.pid = hz_ca.owner_table_id (+)
          --and ca_int_w_pid.class_category = hz_ca.class_category (+)
          and (case when hz_ca.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca.class_category (+) end ) =
              ca_int_w_pid.class_category
          and ca_int_w_pid.class_code = hz_ca.class_code (+)

          --wawong: ignore start data for DNB data
          and trunc(ca_int_w_pid.start_date_active) = trunc(hz_ca.start_date_active (+))
          --and nvl(hz_ca.end_date_active (+),c_end_date )  = c_end_date

          and hz_ca.owner_table_name (+) = 'HZ_PARTIES'
           /* Bug 4979902 */
          --and hz_ca.content_source_type (+) = p_actual_content_src
          and hz_ca.actual_content_source (+) = p_actual_content_src
          and hz_ca3.owner_table_name (+) = 'HZ_PARTIES'
          and hz_ca3.owner_table_id (+) = ca_int_w_pid.pid
          and (case when hz_ca3.class_category (+)
                in ('1972 SIC', '1977 SIC', '1987 SIC', 'NAICS_1997')
                then 'SIC' else hz_ca3.class_category (+) end ) =
              ca_int_w_pid.class_category
          and hz_ca3.primary_flag (+) = 'Y'
          and hz_ca3.status (+) = 'A'
   );
   end if;
   commit;
   end match_code_assignments;


   PROCEDURE match_financial_reports(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   if (P_RERUN = 'Y') then
INSERT INTO HZ_IMP_FINREPORTS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          FINANCIAL_REPORT_ID,
          DOCUMENT_REFERENCE,
          TYPE_OF_FINANCIAL_REPORT,
          DATE_REPORT_ISSUED,
          REPORT_START_DATE,
          REPORT_END_DATE,
          ISSUED_PERIOD,
          BATCH_ID,
          BATCH_MODE_FLAG
     )
select pid, party_os, party_osr, int_row_id, nvl2(FINANCIAL_REPORT_ID,
       'U', 'I'), nvl(FINANCIAL_REPORT_ID, hz_financial_reports_s.NextVal),
       DOCUMENT_REFERENCE, TYPE_OF_FINANCIAL_REPORT, DATE_REPORT_ISSUED,
       REPORT_START_DATE, REPORT_END_DATE, ISSUED_PERIOD, P_BATCH_ID,
       P_BATCH_MODE_FLAG
  from (
select pid, party_os, party_osr, int_row_id,
       nvl2(ranking, FINANCIAL_REPORT_ID, null) FINANCIAL_REPORT_ID,
       DOCUMENT_REFERENCE, TYPE_OF_FINANCIAL_REPORT, DATE_REPORT_ISSUED,
       REPORT_START_DATE, REPORT_END_DATE, ISSUED_PERIOD, rank() over
       (partition by int_row_id order by ranking nulls last,
       financial_report_id) new_rank
  from (
select /*+ leading(fr_int_w_pid) use_nl(hz_fr1) */
	fr_int_w_pid.pid,
	fr_int_w_pid.party_os,
	fr_int_w_pid.party_osr,
	fr_int_w_pid.int_row_id,
	hz_fr1.FINANCIAL_REPORT_ID,
	fr_int_w_pid.DOCUMENT_REFERENCE,
	fr_int_w_pid.TYPE_OF_FINANCIAL_REPORT,
	fr_int_w_pid.DATE_REPORT_ISSUED,
	fr_int_w_pid.REPORT_START_DATE,
	fr_int_w_pid.REPORT_END_DATE,
	fr_int_w_pid.ISSUED_PERIOD,
   case /*when trunc(fr_int_w_pid.DATE_REPORT_ISSUED) =
             trunc(hz_fr1.DATE_REPORT_ISSUED) then 1*/
        when fr_int_w_pid.ISSUED_PERIOD = hz_fr1.ISSUED_PERIOD then 1
        when trunc(fr_int_w_pid.REPORT_START_DATE) =
             trunc(hz_fr1.REPORT_START_DATE)
         and trunc(fr_int_w_pid.REPORT_END_DATE) =
             trunc(hz_fr1.REPORT_END_DATE) then 2 end ranking
  from HZ_FINANCIAL_REPORTS hz_fr1,
       (select /*+ no_merge leading(fr_int) index_asc(fr_int)
                   use_hash(party_sg) use_nl(mosr) */
          nvl(nvl(nvl(fr_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
          fr_int.party_orig_system party_os,
          fr_int.party_orig_system_reference party_osr,
          TYPE_OF_FINANCIAL_REPORT,
          DOCUMENT_REFERENCE,
          DATE_REPORT_ISSUED,
          ISSUED_PERIOD,
          REPORT_END_DATE,
          REPORT_START_DATE,
          fr_int.rowid int_row_id
        from hz_imp_finreports_int fr_int,
             hz_imp_parties_sg party_sg,
             hz_orig_sys_references mosr,
             hz_imp_osr_change osr_ch_tbl
        where fr_int.interface_status = 'C'
          and fr_int.batch_id = P_BATCH_ID
          and fr_int.party_orig_system = P_OS
	      and fr_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  fr_int.party_orig_system_reference
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and fr_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and fr_int.party_orig_system = party_sg.party_orig_system (+)
          and fr_int.batch_id = party_sg.batch_id(+)
          and party_sg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
          and party_sg.action_flag(+) = 'I'
          and fr_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and fr_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
      ) fr_int_w_pid
 where fr_int_w_pid.pid = hz_fr1.PARTY_ID (+)
   and nvl(trunc(fr_int_w_pid.DATE_REPORT_ISSUED), c_end_date) =
       nvl(trunc(hz_fr1.DATE_REPORT_ISSUED (+) ) , c_end_date)
   and fr_int_w_pid.TYPE_OF_FINANCIAL_REPORT = hz_fr1.TYPE_OF_FINANCIAL_REPORT (+)
   and fr_int_w_pid.DOCUMENT_REFERENCE = hz_fr1.DOCUMENT_REFERENCE (+)
   and hz_fr1.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC))
where new_rank = 1;
   else
   -- first run
INSERT INTO HZ_IMP_FINREPORTS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          FINANCIAL_REPORT_ID,
          DOCUMENT_REFERENCE,
          TYPE_OF_FINANCIAL_REPORT,
          DATE_REPORT_ISSUED,
          REPORT_START_DATE,
          REPORT_END_DATE,
          ISSUED_PERIOD,
          BATCH_ID,
          BATCH_MODE_FLAG
     )
select pid, party_os, party_osr, int_row_id, nvl2(FINANCIAL_REPORT_ID,
       'U', 'I'), nvl(FINANCIAL_REPORT_ID, hz_financial_reports_s.NextVal),
       DOCUMENT_REFERENCE, TYPE_OF_FINANCIAL_REPORT, DATE_REPORT_ISSUED,
       REPORT_START_DATE, REPORT_END_DATE, ISSUED_PERIOD, P_BATCH_ID,
       P_BATCH_MODE_FLAG
  from (
select pid, party_os, party_osr, int_row_id,
       nvl2(ranking, FINANCIAL_REPORT_ID, null) FINANCIAL_REPORT_ID,
       DOCUMENT_REFERENCE, TYPE_OF_FINANCIAL_REPORT, DATE_REPORT_ISSUED,
       REPORT_START_DATE, REPORT_END_DATE, ISSUED_PERIOD, rank() over
       (partition by int_row_id order by ranking nulls last,
       financial_report_id) new_rank
  from (
select /*+ leading(fr_int_w_pid) use_nl(hz_fr1) */
	fr_int_w_pid.pid,
	fr_int_w_pid.party_os,
	fr_int_w_pid.party_osr,
	fr_int_w_pid.int_row_id,
	hz_fr1.FINANCIAL_REPORT_ID,
	fr_int_w_pid.DOCUMENT_REFERENCE,
	fr_int_w_pid.TYPE_OF_FINANCIAL_REPORT,
	fr_int_w_pid.DATE_REPORT_ISSUED,
	fr_int_w_pid.REPORT_START_DATE,
	fr_int_w_pid.REPORT_END_DATE,
	fr_int_w_pid.ISSUED_PERIOD,
   case /*when trunc(fr_int_w_pid.DATE_REPORT_ISSUED) =
             trunc(hz_fr1.DATE_REPORT_ISSUED) then 1*/
        when fr_int_w_pid.ISSUED_PERIOD = hz_fr1.ISSUED_PERIOD then 1
        when trunc(fr_int_w_pid.REPORT_START_DATE) =
             trunc(hz_fr1.REPORT_START_DATE)
         and trunc(fr_int_w_pid.REPORT_END_DATE) =
             trunc(hz_fr1.REPORT_END_DATE) then 2 end ranking
  from HZ_FINANCIAL_REPORTS hz_fr1,
       (select /*+ no_merge leading(fr_int) index_asc(fr_int)
                   use_hash(party_sg) use_nl(mosr) */
          nvl(nvl(nvl(fr_int.party_id,party_sg.party_id),osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
          fr_int.party_orig_system party_os,
          fr_int.party_orig_system_reference party_osr,
          TYPE_OF_FINANCIAL_REPORT,
          DOCUMENT_REFERENCE,
          DATE_REPORT_ISSUED,
          ISSUED_PERIOD,
          REPORT_END_DATE,
          REPORT_START_DATE,
          fr_int.rowid int_row_id
        from hz_imp_finreports_int fr_int,
             hz_imp_parties_sg party_sg,
             hz_orig_sys_references mosr,
             hz_imp_osr_change osr_ch_tbl
        where fr_int.interface_status is null
          and fr_int.batch_id = P_BATCH_ID
          and fr_int.party_orig_system = P_OS
	      and fr_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		  and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
          and osr_ch_tbl.batch_id (+) = P_BATCH_ID
          and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  fr_int.party_orig_system_reference
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and fr_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and fr_int.party_orig_system = party_sg.party_orig_system (+)
          and fr_int.batch_id = party_sg.batch_id(+)
          and party_sg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
          and party_sg.action_flag(+) = 'I'
          and fr_int.party_orig_system_reference = mosr.orig_system_reference (+)
          and fr_int.party_orig_system = mosr.orig_system (+)
          and mosr.owner_table_name (+) = 'HZ_PARTIES'
          and mosr.status (+) = 'A'
      ) fr_int_w_pid
 where fr_int_w_pid.pid = hz_fr1.PARTY_ID (+)
   and nvl(trunc(fr_int_w_pid.DATE_REPORT_ISSUED), c_end_date) =
       nvl(trunc(hz_fr1.DATE_REPORT_ISSUED (+) ) , c_end_date)
   and fr_int_w_pid.TYPE_OF_FINANCIAL_REPORT = hz_fr1.TYPE_OF_FINANCIAL_REPORT (+)
   and fr_int_w_pid.DOCUMENT_REFERENCE = hz_fr1.DOCUMENT_REFERENCE (+)
   and hz_fr1.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC))
where new_rank = 1;
   end if;

   commit;
   end match_financial_reports;


   PROCEDURE match_financial_numbers(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   if(P_RERUN = 'Y') then
     -- re-run
INSERT INTO HZ_IMP_FINNUMBERS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          FINANCIAL_NUMBER_ID,
          FINANCIAL_REPORT_ID,
          TYPE_OF_FINANCIAL_REPORT,
          DOCUMENT_REFERENCE,
          DATE_REPORT_ISSUED,
          ISSUED_PERIOD,
          REPORT_START_DATE,
          REPORT_END_DATE,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
-- filter out all less ranking
select party_id,
       party_os,
       party_osr,
       int_row_id,
       -- if ranking is null, there is no match in FR and FN
       nvl2(ranking, action_flag, 'I'),
       nvl2(ranking, nvl(hz_fn2.financial_number_id, hz_financial_numbers_s.NextVal), hz_financial_numbers_s.NextVal) fn_id,
       nvl2(ranking, fr_id, null),
       type_of_financial_report,
       document_reference,
       date_report_issued,
       issued_period,
       report_start_date,
       report_end_date,
       P_BATCH_MODE_FLAG, P_BATCH_ID
  from (
  -- match all fn ids
select /*+ leading(fi_frid) use_nl(hz_fn) */
       pid party_id,
       fi_frid.party_os,
       fi_frid.party_osr,
       fi_frid.int_row_id,
       nvl2(hz_fn.financial_number_id, 'U', 'I') action_flag,
       hz_fn.financial_number_id,
       fr_id,
       fi_frid.type_of_financial_report,
       fi_frid.document_reference,
       fi_frid.date_report_issued,
       fi_frid.issued_period,
       fi_frid.report_start_date,
       fi_frid.report_end_date,
       -- select the highest ranking
       rank() over (partition by fi_frid.int_row_id
       order by fi_frid.ranking nulls last, fr_rowid) new_rank,
       fi_frid.ranking ranking
  from hz_financial_numbers hz_fn,
       (
       -- match all fr ids without the date columns
       select /*+ no_merge leading(fi_pid) use_nl(frsg, fr) */
              fi_pid.pid, fi_pid.party_os, fi_pid.party_osr,
              nvl(frsg.financial_report_id, fr.financial_report_id) fr_id,
              fi_pid.type_of_financial_report, fi_pid.document_reference,
              fi_pid.date_report_issued, fi_pid.issued_period,
              fi_pid.report_start_date, fi_pid.report_end_date,
              fi_pid.financial_number_name, fi_pid.int_row_id,
   -- rank the matched FR which matches other than date cols
   case when fi_pid.ISSUED_PERIOD = frsg.ISSUED_PERIOD then 1
        when trunc(fi_pid.REPORT_START_DATE) = trunc(frsg.REPORT_START_DATE)
         and trunc(fi_pid.REPORT_END_DATE) = trunc(frsg.REPORT_END_DATE) then 2
        when fi_pid.ISSUED_PERIOD = fr.ISSUED_PERIOD then 3
        when trunc(fi_pid.REPORT_START_DATE) = trunc(fr.REPORT_START_DATE)
         and trunc(fi_pid.REPORT_END_DATE) = trunc(fr.REPORT_END_DATE) then 4
         end ranking,
              fr.rowid fr_rowid
         from (
             -- match with party id
             select /*+ no_merge leading(fn_int) index_asc(fn_int) use_hash(party_sg) use_nl(mosr) */
                     nvl(nvl(nvl(fn_int.party_id,party_sg.party_id), osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
                     fn_int.party_orig_system party_os,
                     fn_int.party_orig_system_reference party_osr,
                     fn_int.type_of_financial_report,
                     fn_int.document_reference, trunc(
                     fn_int.date_report_issued) date_report_issued,
                     fn_int.issued_period, trunc(fn_int.report_end_date)
                     report_end_date, trunc(fn_int.report_start_date)
                     report_start_date, fn_int.financial_number_name,
                     fn_int.rowid int_row_id,
                     fn_int.batch_id
                from hz_imp_finnumbers_int fn_int,
                     hz_imp_parties_sg party_sg,
                     hz_orig_sys_references mosr,
                     hz_imp_osr_change osr_ch_tbl
               where fn_int.interface_status = 'C'
                 and fn_int.batch_id = P_BATCH_ID
                 and fn_int.party_orig_system = P_OS
                 and fn_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		         and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
                 and osr_ch_tbl.batch_id (+) = P_BATCH_ID
                 and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  fn_int.party_orig_system_reference
                 and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
                 and party_sg.party_orig_system (+) = P_OS
                 and party_sg.batch_id(+) = P_BATCH_ID
                 and fn_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
                 and fn_int.party_orig_system = party_sg.party_orig_system (+)
                 and fn_int.batch_id = party_sg.batch_id(+)
                 and party_sg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
                 and party_sg.action_flag(+) = 'I'
                 and fn_int.party_orig_system_reference = mosr.orig_system_reference (+)
                 and fn_int.party_orig_system = mosr.orig_system (+)
                 and mosr.owner_table_name (+) = 'HZ_PARTIES'
                 and mosr.status (+) = 'A'
              ) fi_pid,
              hz_imp_finreports_sg frsg,
              hz_financial_reports fr
        where fi_pid.pid = frsg.party_id (+)
          and fi_pid.type_of_financial_report = frsg.type_of_financial_report (+)
          and fi_pid.document_reference = frsg.document_reference (+)
          and frsg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
          and frsg.action_flag(+) = 'I'
          and fi_pid.batch_id = frsg.batch_id(+)
          and fi_pid.pid = fr.party_id (+)
          and nvl(trunc(fi_pid.DATE_REPORT_ISSUED), c_end_date) =
              nvl(trunc(fr.DATE_REPORT_ISSUED (+) ) , c_end_date)
          and fi_pid.type_of_financial_report = fr.type_of_financial_report (+)
          and fi_pid.document_reference = fr.document_reference (+)
          and fr.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
       ) fi_frid
 where fi_frid.financial_number_name = hz_fn.financial_number_name (+)
   and fi_frid.fr_id = hz_fn.financial_report_id (+)
   and HZ_FN.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
       ) hz_fn2
 where new_rank = 1
     );

   else
   -- first run
INSERT INTO HZ_IMP_FINNUMBERS_SG
     (
          PARTY_ID,
          PARTY_ORIG_SYSTEM,
          PARTY_ORIG_SYSTEM_REFERENCE,
          INT_ROW_ID,
          ACTION_FLAG,
          FINANCIAL_NUMBER_ID,
          FINANCIAL_REPORT_ID,
          TYPE_OF_FINANCIAL_REPORT,
          DOCUMENT_REFERENCE,
          DATE_REPORT_ISSUED,
          ISSUED_PERIOD,
          REPORT_START_DATE,
          REPORT_END_DATE,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
-- filter out all less ranking
select party_id,
       party_os,
       party_osr,
       int_row_id,
       -- if ranking is null, there is no match in FR and FN
       nvl2(ranking, action_flag, 'I'),
       nvl2(ranking, nvl(hz_fn2.financial_number_id, hz_financial_numbers_s.NextVal), hz_financial_numbers_s.NextVal) fn_id,
       nvl2(ranking, fr_id, null),
       type_of_financial_report,
       document_reference,
       date_report_issued,
       issued_period,
       report_start_date,
       report_end_date,
       P_BATCH_MODE_FLAG, P_BATCH_ID
  from (
  -- match all fn ids
select /*+ leading(fi_frid) use_nl(hz_fn) */
       pid party_id,
       fi_frid.party_os,
       fi_frid.party_osr,
       fi_frid.int_row_id,
       nvl2(hz_fn.financial_number_id, 'U', 'I') action_flag,
       hz_fn.financial_number_id,
       fr_id,
       fi_frid.type_of_financial_report,
       fi_frid.document_reference,
       fi_frid.date_report_issued,
       fi_frid.issued_period,
       fi_frid.report_start_date,
       fi_frid.report_end_date,
       -- select the highest ranking
       rank() over (partition by fi_frid.int_row_id
       order by fi_frid.ranking nulls last, fr_rowid) new_rank,
       fi_frid.ranking ranking
  from hz_financial_numbers hz_fn,
       (
       -- match all fr ids without the date columns
       select /*+ no_merge leading(fi_pid) use_nl(frsg, fr) */
              fi_pid.pid, fi_pid.party_os, fi_pid.party_osr,
              nvl(frsg.financial_report_id, fr.financial_report_id) fr_id,
              fi_pid.type_of_financial_report, fi_pid.document_reference,
              fi_pid.date_report_issued, fi_pid.issued_period,
              fi_pid.report_start_date, fi_pid.report_end_date,
              fi_pid.financial_number_name, fi_pid.int_row_id,
   -- rank the matched FR which matches other than date cols
   case when fi_pid.ISSUED_PERIOD = frsg.ISSUED_PERIOD then 1
        when trunc(fi_pid.REPORT_START_DATE) = trunc(frsg.REPORT_START_DATE)
         and trunc(fi_pid.REPORT_END_DATE) = trunc(frsg.REPORT_END_DATE) then 2
        when fi_pid.ISSUED_PERIOD = fr.ISSUED_PERIOD then 3
        when trunc(fi_pid.REPORT_START_DATE) = trunc(fr.REPORT_START_DATE)
         and trunc(fi_pid.REPORT_END_DATE) = trunc(fr.REPORT_END_DATE) then 4
         end ranking,
              fr.rowid fr_rowid
         from (
             -- match with party id
             select /*+ no_merge leading(fn_int) index_asc(fn_int) use_hash(party_sg) use_nl(mosr) */
                     nvl(nvl(nvl(fn_int.party_id,party_sg.party_id), osr_ch_tbl.entity_id),mosr.owner_table_id) pid,
                     fn_int.party_orig_system party_os,
                     fn_int.party_orig_system_reference party_osr,
                     fn_int.type_of_financial_report,
                     fn_int.document_reference, trunc(
                     fn_int.date_report_issued) date_report_issued,
                     fn_int.issued_period, trunc(fn_int.report_end_date)
                     report_end_date, trunc(fn_int.report_start_date)
                     report_start_date, fn_int.financial_number_name,
                     fn_int.rowid int_row_id,
                     fn_int.batch_id
                from hz_imp_finnumbers_int fn_int,
                     hz_imp_parties_sg party_sg,
                     hz_orig_sys_references mosr,
                     hz_imp_osr_change osr_ch_tbl
               where fn_int.interface_status is null
                 and fn_int.batch_id = P_BATCH_ID
                 and fn_int.party_orig_system = P_OS
                 and fn_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
		         and osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
                 and osr_ch_tbl.batch_id (+) = P_BATCH_ID
                 and osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  fn_int.party_orig_system_reference
                 and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
                 and party_sg.party_orig_system (+) = P_OS
                 and party_sg.batch_id(+) = P_BATCH_ID
                 and fn_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
                 and fn_int.party_orig_system = party_sg.party_orig_system (+)
                 and fn_int.batch_id = party_sg.batch_id(+)
                 and party_sg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
                 and party_sg.action_flag(+) = 'I'
                 and fn_int.party_orig_system_reference = mosr.orig_system_reference (+)
                 and fn_int.party_orig_system = mosr.orig_system (+)
                 and mosr.owner_table_name (+) = 'HZ_PARTIES'
                 and mosr.status (+) = 'A'
              ) fi_pid,
              hz_imp_finreports_sg frsg,
              hz_financial_reports fr
        where fi_pid.pid = frsg.party_id (+)
          and fi_pid.type_of_financial_report = frsg.type_of_financial_report (+)
          and fi_pid.document_reference = frsg.document_reference (+)
          and frsg.batch_mode_flag(+) = P_BATCH_MODE_FLAG
          and frsg.action_flag(+) = 'I'
          and fi_pid.batch_id = frsg.batch_id(+)
          and fi_pid.pid = fr.party_id (+)
          and nvl(trunc(fi_pid.DATE_REPORT_ISSUED), c_end_date) =
              nvl(trunc(fr.DATE_REPORT_ISSUED (+) ) , c_end_date)
          and fi_pid.type_of_financial_report = fr.type_of_financial_report (+)
          and fi_pid.document_reference = fr.document_reference (+)
          and fr.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
       ) fi_frid
 where fi_frid.financial_number_name = hz_fn.financial_number_name (+)
   and fi_frid.fr_id = hz_fn.financial_report_id (+)
   and HZ_FN.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
       ) hz_fn2
 where new_rank = 1
     );
   end if;
   commit;
   end match_financial_numbers;


   PROCEDURE match_relationships(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   BEGIN
   /*
        Fix bug 4374278: For DNB, when comparing the end_date cannot use c_end_date.
        The c_end_date = to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI'); but when relationship records
        are created in Data Load HZ_IMP_LOAD_RELATIONSHIPS_PKG it use
        l_no_end_date := TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');

        Change the code to use l_no_end_date.
  */
   if (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN = 'Y') then
   -- re-run/DNB
     INSERT INTO HZ_IMP_RELSHIPS_SG
     (    RELATIONSHIP_TYPE,
          RELATIONSHIP_CODE,
          START_DATE,
          END_DATE,
          SUB_ORIG_SYSTEM,
          SUB_ORIG_SYSTEM_REFERENCE,
          SUB_ID,
          OBJ_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          RELATIONSHIP_ID,
          ERROR_FLAG,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
select /*+ leading(ri_ids) use_nl(hz_rel) */
       ri_ids.rel_type,
       ri_ids.rel_code,
       ri_ids.start_date,
       ri_ids.end_date,
       ri_ids.subject_os,
       ri_ids.subject_osr,
       ri_ids.subject_id                                       subject_id,
       ri_ids.object_id                                        object_id,
       ri_ids.int_row_id                                       int_row_id,
       nvl2(hz_rel.relationship_id, 'U', 'I')                  action_flag,
       nvl(hz_rel.relationship_id, hz_relationships_s.NextVal) relationship_id,
       -- populate error flag
       -- error 1 - object not found; error 2 - subject not found
       nvl2(ri_ids.object_id, nvl2(ri_ids.subject_id, null, 2), 1) error_flag,
       P_BATCH_MODE_FLAG, P_BATCH_ID
from   hz_relationships hz_rel,
       (select /*+ no_merge leading(ri) index_asc(ri)
		   use_nl(mosr,mosr2,PARTY_SGA) use_hash(PARTY_SGB) */
              ri.relationship_type rel_type,
              ri.relationship_code rel_code,
              ri.sub_orig_system subject_os,
              ri.sub_orig_system_reference subject_osr,
              nvl(nvl(nvl(ri.obj_id,PARTY_SGA.party_id), obj_osr_ch_tbl.entity_id), mosr.owner_table_id)  object_id,
              nvl(nvl(PARTY_SGB.party_id, sub_osr_ch_tbl.entity_id), mosr2.owner_table_id) subject_id,
              ri.rowid int_row_id, relationship_type, relationship_code,
              ri.start_date start_date,
              ri.end_date end_date,
              sub_int.party_type sub_type,
              obj_int.party_type obj_type
        from  hz_imp_RELSHIPS_int ri,
              hz_orig_sys_references mosr,
              hz_orig_sys_references mosr2,
              HZ_IMP_PARTIES_SG PARTY_SGA,
              HZ_IMP_PARTIES_SG PARTY_SGB,
              hz_imp_osr_change sub_osr_ch_tbl,
              hz_imp_osr_change obj_osr_ch_tbl,
              hz_imp_parties_int sub_int,
              hz_imp_parties_int obj_int
        where mosr.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr.status (+) = 'A'
        and   mosr2.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr2.status (+) = 'A'
        and   sub_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   obj_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   sub_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   sub_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.sub_orig_system_reference
        and   obj_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   obj_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.obj_orig_system_reference
        and   ri.batch_id = P_BATCH_ID
        and   ri.sub_orig_system = P_OS
        and   ri.interface_status = 'C'
        and   ri.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
        and   ri.obj_orig_system_reference = mosr.orig_system_reference (+)
        and   ri.obj_orig_system = mosr.orig_system (+)
        and   ri.sub_orig_system_reference = mosr2.orig_system_reference (+)
        and   ri.sub_orig_system = mosr2.orig_system (+)
        and   ri.obj_orig_system_reference = PARTY_SGA.party_orig_system_reference (+)
        and   ri.obj_orig_system = PARTY_SGA.party_orig_system (+)
        and   ri.batch_id = PARTY_SGA.batch_id(+)
        and   PARTY_SGA.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        and   PARTY_SGA.ACTION_FLAG(+) = 'I'
        and   ri.sub_orig_system_reference = PARTY_SGB.party_orig_system_reference (+)
        and   ri.sub_orig_system = PARTY_SGB.party_orig_system (+)
        and   ri.batch_id = PARTY_SGB.batch_id(+)
        and   PARTY_SGB.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
        and   PARTY_SGB.party_orig_system (+) = P_OS
        and   PARTY_SGB.batch_id(+) = P_BATCH_ID
        and   PARTY_SGB.batch_mode_flag(+)= P_BATCH_MODE_FLAG
        /* and   PARTY_SGB.ACTION_FLAG(+) = 'I' */
        and ri.batch_id = sub_int.batch_id(+)
        and sub_int.interface_status(+) is null
        and ri.sub_orig_system_reference = sub_int.party_orig_system_reference (+)
        and ri.sub_orig_system = sub_int.party_orig_system (+)
        and ri.batch_id = obj_int.batch_id(+)
        and obj_int.interface_status(+) is null
        and ri.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
        and ri.obj_orig_system = obj_int.party_orig_system (+)
       ) ri_ids
where  ri_ids.object_id = hz_rel.object_id (+)
and    ri_ids.subject_id = hz_rel.subject_id (+)
and    ri_ids.obj_type   = hz_rel.object_type (+)
and    ri_ids.sub_type   = hz_rel.subject_type (+)
and    ri_ids.relationship_type = hz_rel.relationship_type (+)
and    ri_ids.relationship_code = hz_rel.relationship_code (+)
-- for DNB, ignore start date, filter out end-dated records
and    nvl(hz_rel.END_DATE (+),l_no_end_date )  = l_no_end_date
and    hz_rel.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
and    hz_rel.subject_table_name (+) = 'HZ_PARTIES'
);
   elsif (P_ACTUAL_CONTENT_SRC = 'USER_ENTERED' and P_RERUN = 'Y') then
   -- re-run/USER_ENTERED
     INSERT INTO HZ_IMP_RELSHIPS_SG
     (    RELATIONSHIP_TYPE,
          RELATIONSHIP_CODE,
          START_DATE,
          END_DATE,
          SUB_ORIG_SYSTEM,
          SUB_ORIG_SYSTEM_REFERENCE,
          SUB_ID,
          OBJ_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          RELATIONSHIP_ID,
          ERROR_FLAG,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
select /*+ leading(ri_ids) use_nl(hz_rel) */
       ri_ids.rel_type,
       ri_ids.rel_code,
       ri_ids.start_date,
       ri_ids.end_date,
       ri_ids.subject_os,
       ri_ids.subject_osr,
       ri_ids.subject_id                                       subject_id,
       ri_ids.object_id                                        object_id,
       ri_ids.int_row_id                                       int_row_id,
       nvl2(hz_rel.relationship_id, 'U', 'I')                  action_flag,
       nvl(hz_rel.relationship_id, hz_relationships_s.NextVal) relationship_id,
       nvl2(ri_ids.object_id, nvl2(ri_ids.subject_id, null, 2), 1) error_flag,
       P_BATCH_MODE_FLAG, P_BATCH_ID
from   hz_relationships hz_rel,
       (select /*+ no_merge leading(ri) index_asc(ri)
		   use_nl(mosr,mosr2,PARTY_SGA) use_hash(PARTY_SGB) */
              ri.relationship_type rel_type,
              ri.relationship_code rel_code,
              ri.sub_orig_system subject_os,
              ri.sub_orig_system_reference subject_osr,
              nvl(nvl(nvl(ri.obj_id,PARTY_SGA.party_id), obj_osr_ch_tbl.entity_id), mosr.owner_table_id)  object_id,
              nvl(nvl(PARTY_SGB.party_id, sub_osr_ch_tbl.entity_id), mosr2.owner_table_id) subject_id,
              ri.rowid int_row_id, relationship_type, relationship_code,
              ri.start_date start_date,
              ri.end_date end_date,
              sub_int.party_type sub_type,
              obj_int.party_type obj_type
        from  hz_imp_RELSHIPS_int ri,
              hz_orig_sys_references mosr,
              hz_orig_sys_references mosr2,
              HZ_IMP_PARTIES_SG PARTY_SGA,
              HZ_IMP_PARTIES_SG PARTY_SGB,
              hz_imp_osr_change sub_osr_ch_tbl,
              hz_imp_osr_change obj_osr_ch_tbl,
              hz_imp_parties_int sub_int,
              hz_imp_parties_int obj_int
        where mosr.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr.status (+) = 'A'
        and   mosr2.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr2.status (+) = 'A'
        and   sub_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   obj_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   sub_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   sub_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.sub_orig_system_reference
        and   obj_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   obj_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.obj_orig_system_reference
        and   ri.batch_id = P_BATCH_ID
        and   ri.sub_orig_system = P_OS
        and   ri.interface_status = 'C'
        and   ri.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
        and   ri.obj_orig_system_reference = mosr.orig_system_reference (+)
        and   ri.obj_orig_system = mosr.orig_system (+)
        and   ri.sub_orig_system_reference = mosr2.orig_system_reference (+)
        and   ri.sub_orig_system = mosr2.orig_system (+)
        and   ri.obj_orig_system_reference = PARTY_SGA.party_orig_system_reference (+)
        and   ri.obj_orig_system = PARTY_SGA.party_orig_system (+)
        and   ri.batch_id = PARTY_SGA.batch_id(+)
        and   PARTY_SGA.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        and   PARTY_SGA.ACTION_FLAG(+) = 'I'
        and   ri.sub_orig_system_reference = PARTY_SGB.party_orig_system_reference (+)
        and   ri.sub_orig_system = PARTY_SGB.party_orig_system (+)
        and   ri.batch_id = PARTY_SGB.batch_id(+)
        and   PARTY_SGB.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
        and   PARTY_SGB.party_orig_system (+) = P_OS
        and   PARTY_SGB.batch_id(+) = P_BATCH_ID
        and   PARTY_SGB.batch_mode_flag(+)= P_BATCH_MODE_FLAG
        /* and   PARTY_SGB.ACTION_FLAG(+) = 'I' */
        and ri.batch_id = sub_int.batch_id(+)
        and sub_int.interface_status(+) is null
        and ri.sub_orig_system_reference = sub_int.party_orig_system_reference (+)
        and ri.sub_orig_system = sub_int.party_orig_system (+)
        and ri.batch_id = obj_int.batch_id(+)
        and obj_int.interface_status(+) is null
        and ri.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
        and ri.obj_orig_system = obj_int.party_orig_system (+)
        ) ri_ids
where  ri_ids.object_id = hz_rel.object_id (+)
and    ri_ids.subject_id = hz_rel.subject_id (+)
and    ri_ids.obj_type   = hz_rel.object_type (+)
and    ri_ids.sub_type   = hz_rel.subject_type (+)
and    ri_ids.relationship_type = hz_rel.relationship_type (+)
and    ri_ids.relationship_code = hz_rel.relationship_code (+)
-- use start date as key for non-DNB data
and    trunc(ri_ids.START_DATE) = trunc(hz_rel.START_DATE (+))
and    hz_rel.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
and    hz_rel.subject_table_name (+) = 'HZ_PARTIES'
);
   elsif (P_ACTUAL_CONTENT_SRC <> 'USER_ENTERED' and P_RERUN <> 'Y') then
   -- first run/DNB
     INSERT INTO HZ_IMP_RELSHIPS_SG
     (    RELATIONSHIP_TYPE,
          RELATIONSHIP_CODE,
          START_DATE,
          END_DATE,
          SUB_ORIG_SYSTEM,
          SUB_ORIG_SYSTEM_REFERENCE,
          SUB_ID,
          OBJ_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          RELATIONSHIP_ID,
          ERROR_FLAG,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
select /*+ leading(ri_ids) use_nl(hz_rel) */
       ri_ids.rel_type,
       ri_ids.rel_code,
       ri_ids.start_date,
       ri_ids.end_date,
       ri_ids.subject_os,
       ri_ids.subject_osr,
       ri_ids.subject_id                                       subject_id,
       ri_ids.object_id                                        object_id,
       ri_ids.int_row_id                                       int_row_id,
       nvl2(hz_rel.relationship_id, 'U', 'I')                  action_flag,
       nvl(hz_rel.relationship_id, hz_relationships_s.NextVal) relationship_id,
       nvl2(ri_ids.object_id, nvl2(ri_ids.subject_id, null, 2), 1) error_flag,
       P_BATCH_MODE_FLAG, P_BATCH_ID
from   hz_relationships hz_rel,
       (select /*+ no_merge leading(ri) index_asc(ri)
		   use_nl(mosr,mosr2,PARTY_SGA) use_hash(PARTY_SGB) */
              ri.relationship_type rel_type,
              ri.relationship_code rel_code,
              ri.sub_orig_system subject_os,
              ri.sub_orig_system_reference subject_osr,
              nvl(nvl(nvl(ri.obj_id, PARTY_SGA.party_id), obj_osr_ch_tbl.entity_id), mosr.owner_table_id)  object_id,
              nvl(nvl(PARTY_SGB.party_id, sub_osr_ch_tbl.entity_id), mosr2.owner_table_id) subject_id,
              ri.rowid int_row_id, relationship_type, relationship_code,
              ri.start_date start_date,
              ri.end_date end_date,
              sub_int.party_type sub_type,
              obj_int.party_type obj_type
        from  hz_imp_RELSHIPS_int ri,
              hz_orig_sys_references mosr,
              hz_orig_sys_references mosr2,
              HZ_IMP_PARTIES_SG PARTY_SGA,
              HZ_IMP_PARTIES_SG PARTY_SGB,
              hz_imp_osr_change sub_osr_ch_tbl,
              hz_imp_osr_change obj_osr_ch_tbl,
              hz_imp_parties_int sub_int,
              hz_imp_parties_int obj_int
        where mosr.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr.status (+) = 'A'
        and   mosr2.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr2.status (+) = 'A'
        and   sub_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   obj_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   sub_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   sub_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.sub_orig_system_reference
        and   obj_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   obj_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.obj_orig_system_reference
        and   ri.batch_id = P_BATCH_ID
        and   ri.sub_orig_system = P_OS
        and   ri.interface_status is null
        and   ri.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
        and   ri.obj_orig_system_reference = mosr.orig_system_reference (+)
        and   ri.obj_orig_system = mosr.orig_system (+)
        and   ri.sub_orig_system_reference = mosr2.orig_system_reference (+)
        and   ri.sub_orig_system = mosr2.orig_system (+)
        and   ri.obj_orig_system_reference = PARTY_SGA.party_orig_system_reference (+)
        and   ri.obj_orig_system = PARTY_SGA.party_orig_system (+)
        and   ri.batch_id = PARTY_SGA.batch_id(+)
        and   PARTY_SGA.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        and   PARTY_SGA.ACTION_FLAG(+) = 'I'
        and   ri.sub_orig_system_reference = PARTY_SGB.party_orig_system_reference (+)
        and   ri.sub_orig_system = PARTY_SGB.party_orig_system (+)
        and   ri.batch_id = PARTY_SGB.batch_id(+)
        and   PARTY_SGB.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
        and   PARTY_SGB.party_orig_system (+) = P_OS
        and   PARTY_SGB.batch_id(+) = P_BATCH_ID
        and   PARTY_SGB.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        /* and   PARTY_SGB.ACTION_FLAG(+) = 'I' */
        and ri.batch_id = sub_int.batch_id(+)
        and sub_int.interface_status(+) is null
        and ri.sub_orig_system_reference = sub_int.party_orig_system_reference (+)
        and ri.sub_orig_system = sub_int.party_orig_system (+)
        and ri.batch_id = obj_int.batch_id(+)
        and obj_int.interface_status(+) is null
        and ri.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
        and ri.obj_orig_system = obj_int.party_orig_system (+)
       ) ri_ids
where  ri_ids.object_id = hz_rel.object_id (+)
and    ri_ids.subject_id = hz_rel.subject_id (+)
and    ri_ids.obj_type   = hz_rel.object_type (+)
and    ri_ids.sub_type   = hz_rel.subject_type (+)
and    ri_ids.relationship_type = hz_rel.relationship_type (+)
and    ri_ids.relationship_code = hz_rel.relationship_code (+)
--and    trunc(ri_ids.START_DATE) = trunc(hz_rel.START_DATE (+))
and    nvl(hz_rel.END_DATE (+),l_no_end_date )  = l_no_end_date
and    hz_rel.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
and    hz_rel.subject_table_name (+) = 'HZ_PARTIES'
);
   else
   -- first run/non-DNB
     INSERT INTO HZ_IMP_RELSHIPS_SG
     (    RELATIONSHIP_TYPE,
          RELATIONSHIP_CODE,
          START_DATE,
          END_DATE,
          SUB_ORIG_SYSTEM,
          SUB_ORIG_SYSTEM_REFERENCE,
          SUB_ID,
          OBJ_ID,
          INT_ROW_ID,
          ACTION_FLAG,
          RELATIONSHIP_ID,
          ERROR_FLAG,
          BATCH_MODE_FLAG, BATCH_ID
     )
     (
select /*+ leading(ri_ids) use_nl(hz_rel) */
       ri_ids.rel_type,
       ri_ids.rel_code,
       ri_ids.start_date,
       ri_ids.end_date,
       ri_ids.subject_os,
       ri_ids.subject_osr,
       ri_ids.subject_id                                       subject_id,
       ri_ids.object_id                                        object_id,
       ri_ids.int_row_id                                       int_row_id,
       nvl2(hz_rel.relationship_id, 'U', 'I')                  action_flag,
       nvl(hz_rel.relationship_id, hz_relationships_s.NextVal) relationship_id,
       nvl2(ri_ids.object_id, nvl2(ri_ids.subject_id, null, 2), 1) error_flag,
       P_BATCH_MODE_FLAG, P_BATCH_ID
from   hz_relationships hz_rel,
       (select /*+ no_merge leading(ri) index_asc(ri)
		   use_nl(mosr,mosr2,PARTY_SGA) use_hash(PARTY_SGB) */
              ri.relationship_type rel_type,
              ri.relationship_code rel_code,
              ri.sub_orig_system subject_os,
              ri.sub_orig_system_reference subject_osr,
              nvl(nvl(nvl(ri.obj_id,PARTY_SGA.party_id), obj_osr_ch_tbl.entity_id), mosr.owner_table_id)  object_id,
              nvl(nvl(PARTY_SGB.party_id, sub_osr_ch_tbl.entity_id), mosr2.owner_table_id) subject_id,
              ri.rowid int_row_id, relationship_type, relationship_code,
              ri.start_date start_date,
              ri.end_date end_date,
              sub_int.party_type sub_type,
              obj_int.party_type obj_type
        from  hz_imp_RELSHIPS_int ri,
              hz_orig_sys_references mosr,
              hz_orig_sys_references mosr2,
              HZ_IMP_PARTIES_SG PARTY_SGA,
              HZ_IMP_PARTIES_SG PARTY_SGB,
              hz_imp_osr_change sub_osr_ch_tbl,
              hz_imp_osr_change obj_osr_ch_tbl,
              hz_imp_parties_int sub_int,
              hz_imp_parties_int obj_int
        where mosr.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr.status (+) = 'A'
        and   mosr2.owner_table_name (+) = 'HZ_PARTIES'
        and   mosr2.status (+) = 'A'
        and   sub_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   obj_osr_ch_tbl.entity_name (+) = 'HZ_PARTIES'
        and   sub_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   sub_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.sub_orig_system_reference
        and   obj_osr_ch_tbl.batch_id (+) = P_BATCH_ID
        and   obj_osr_ch_tbl.NEW_ORIG_SYSTEM_REFERENCE (+) =  ri.obj_orig_system_reference
        and   ri.batch_id = P_BATCH_ID
        and   ri.sub_orig_system = P_OS
        and   ri.interface_status is null
        and   ri.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
        and   ri.obj_orig_system_reference = mosr.orig_system_reference (+)
        and   ri.obj_orig_system = mosr.orig_system (+)
        and   ri.sub_orig_system_reference = mosr2.orig_system_reference (+)
        and   ri.sub_orig_system = mosr2.orig_system (+)
        and   ri.obj_orig_system_reference = PARTY_SGA.party_orig_system_reference (+)
        and   ri.obj_orig_system = PARTY_SGA.party_orig_system (+)
        and   ri.batch_id = PARTY_SGA.batch_id(+)
        and   PARTY_SGA.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        and   PARTY_SGA.ACTION_FLAG(+) = 'I'
        and   ri.sub_orig_system_reference = PARTY_SGB.party_orig_system_reference (+)
        and   ri.sub_orig_system = PARTY_SGB.party_orig_system (+)
        and   ri.batch_id = PARTY_SGB.batch_id(+)
        and   PARTY_SGB.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
        and   PARTY_SGB.party_orig_system (+) = P_OS
        and   PARTY_SGB.batch_id(+) = P_BATCH_ID
        and   PARTY_SGB.batch_mode_flag(+)=P_BATCH_MODE_FLAG
        /* and   PARTY_SGB.ACTION_FLAG(+) = 'I' */
        and ri.batch_id = sub_int.batch_id(+)
        and sub_int.interface_status(+) is null
        and ri.sub_orig_system_reference = sub_int.party_orig_system_reference (+)
        and ri.sub_orig_system = sub_int.party_orig_system (+)
        and ri.batch_id = obj_int.batch_id(+)
        and obj_int.interface_status(+) is null
        and ri.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
        and ri.obj_orig_system = obj_int.party_orig_system (+)
       ) ri_ids
where  ri_ids.object_id = hz_rel.object_id (+)
and    ri_ids.subject_id = hz_rel.subject_id (+)
and    ri_ids.obj_type   = hz_rel.object_type (+)
and    ri_ids.sub_type   = hz_rel.subject_type (+)
and    ri_ids.relationship_type = hz_rel.relationship_type (+)
and    ri_ids.relationship_code = hz_rel.relationship_code (+)
and    trunc(ri_ids.START_DATE) = trunc(hz_rel.START_DATE (+))
and    hz_rel.ACTUAL_CONTENT_SOURCE (+) = P_ACTUAL_CONTENT_SRC
and    hz_rel.subject_table_name (+) = 'HZ_PARTIES'
);
    end if;
    commit;
   end match_relationships;


   PROCEDURE match_contacts(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   begin

   if(P_RERUN = 'Y') then
   -- re-run
     INSERT INTO HZ_IMP_CONTACTS_SG
     ( RELATIONSHIP_TYPE,
       RELATIONSHIP_CODE,
       START_DATE,
       END_DATE,
       SUB_ORIG_SYSTEM,
       SUB_ORIG_SYSTEM_REFERENCE,
       CONTACT_ID,
       CONTACT_ORIG_SYSTEM,
       CONTACT_ORIG_SYSTEM_REFERENCE,
       SUB_ID,
       OBJ_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       PARTY_ACTION_FLAG,
       BATCH_MODE_FLAG, BATCH_ID
     )
     (
  select /*+ leading(cont_int) index_asc(cont_int)
	use_nl(cont_mosr,sub_mosr,obj_sg,obj_mosr) use_hash(sub_sg) */
         cont_int.relationship_type,
         cont_int.relationship_code,
         cont_int.start_date,
         cont_int.end_date,
         cont_int.sub_orig_system sos,
         cont_int.sub_orig_system_reference sosr,
         nvl(cont_mosr.owner_table_id, hz_org_contacts_s.NextVal) cont_id,
         cont_int.contact_orig_system cont_orig_system,
         cont_int.contact_orig_system_reference cont_orig_system_reference,
         /*6913856 */
         coalesce(sub_sg.party_id, sub_int.party_id,sub_mosr.owner_table_id) sub_id,
         coalesce(obj_sg.party_id, obj_int.party_id,obj_mosr.owner_table_id) obj_id,
         cont_int.rowid int_row_id,
         nvl2(cont_mosr.owner_table_id, 'U', 'I') action_flag,
         nvl(obj_sg.action_flag,'U') PARTY_ACTION_FLAG,
         P_BATCH_MODE_FLAG, P_BATCH_ID
    from hz_imp_contacts_int cont_int,
         hz_orig_sys_references cont_mosr,
         hz_imp_parties_sg sub_sg,
         hz_orig_sys_references sub_mosr,
         hz_imp_parties_sg obj_sg,
         hz_imp_parties_int sub_int,
         hz_imp_parties_int obj_int, /*6913856 */
         hz_orig_sys_references obj_mosr
   where cont_int.batch_id = P_BATCH_ID
     and cont_int.sub_orig_system = P_OS
     and cont_int.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
     and cont_int.interface_status = 'C'
     and cont_int.batch_id = sub_sg.batch_id(+)
     and sub_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
     -- and sub_sg.action_flag(+)='I'
     and cont_int.batch_id = obj_sg.batch_id(+)
     and obj_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
     -- and obj_sg.action_flag(+)='I'
     and cont_mosr.owner_table_name (+) = 'HZ_ORG_CONTACTS'
     and cont_mosr.status (+) = 'A'
     and cont_int.contact_orig_system_reference = cont_mosr.orig_system_reference (+)
     and cont_int.contact_orig_system = cont_mosr.orig_system (+)
     and cont_int.sub_orig_system_reference = sub_sg.party_orig_system_reference (+)
     and cont_int.sub_orig_system = sub_sg.party_orig_system (+)
     and sub_mosr.owner_table_name (+) = 'HZ_PARTIES'
     and sub_mosr.status (+) = 'A'
     and sub_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
     and sub_sg.party_orig_system (+) = P_OS
     and sub_sg.batch_id(+) = P_BATCH_ID
     and cont_int.sub_orig_system_reference = sub_mosr.orig_system_reference (+)
     and cont_int.sub_orig_system = sub_mosr.orig_system (+)
     and cont_int.obj_orig_system_reference = obj_sg.party_orig_system_reference (+)
     and cont_int.obj_orig_system = obj_sg.party_orig_system (+)
     and obj_mosr.owner_table_name (+) = 'HZ_PARTIES'
     and obj_mosr.status (+) = 'A'
     and cont_int.obj_orig_system_reference = obj_mosr.orig_system_reference (+)
     and cont_int.obj_orig_system = obj_mosr.orig_system (+)
     and cont_int.batch_id = sub_int.batch_id(+)
     and sub_int.interface_status(+)= 'C'
     and cont_int.sub_orig_system_reference = sub_int.party_orig_system_reference (+)
     and cont_int.sub_orig_system = sub_int.party_orig_system (+)
     and cont_int.batch_id = obj_int.batch_id(+)
     and obj_int.interface_status(+)= 'C'
     and cont_int.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
     and cont_int.obj_orig_system = obj_int.party_orig_system (+)
   );
   else
     INSERT INTO HZ_IMP_CONTACTS_SG
     ( RELATIONSHIP_TYPE,
       RELATIONSHIP_CODE,
       START_DATE,
       END_DATE,
       SUB_ORIG_SYSTEM,
       SUB_ORIG_SYSTEM_REFERENCE,
       CONTACT_ID,
       CONTACT_ORIG_SYSTEM,
       CONTACT_ORIG_SYSTEM_REFERENCE,
       SUB_ID,
       OBJ_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       PARTY_ACTION_FLAG,
       BATCH_MODE_FLAG, BATCH_ID
     )
     (
  select /*+ leading(cont_int) index_asc(cont_int)
	use_nl(cont_mosr,sub_mosr,obj_sg,obj_mosr) use_hash(sub_sg) */
         cont_int.relationship_type,
         cont_int.relationship_code,
         cont_int.start_date,
         cont_int.end_date,
         cont_int.sub_orig_system sos,
         cont_int.sub_orig_system_reference sosr,
         nvl(cont_mosr.owner_table_id, hz_org_contacts_s.NextVal) cont_id,
         cont_int.contact_orig_system cont_orig_system,
         cont_int.contact_orig_system_reference cont_orig_system_reference,
         coalesce(sub_sg.party_id, sub_int.party_id,sub_mosr.owner_table_id) sub_id,
         coalesce(obj_sg.party_id, obj_int.party_id,obj_mosr.owner_table_id) obj_id,
         cont_int.rowid int_row_id,
         nvl2(cont_mosr.owner_table_id, 'U', 'I') action_flag,
         nvl(obj_sg.action_flag,'U') PARTY_ACTION_FLAG,
         P_BATCH_MODE_FLAG, P_BATCH_ID
    from hz_imp_contacts_int cont_int,
         hz_orig_sys_references cont_mosr,
         hz_imp_parties_sg sub_sg,
         hz_orig_sys_references sub_mosr,
         hz_imp_parties_sg obj_sg,
         hz_imp_parties_int sub_int,
         hz_imp_parties_int obj_int,
         hz_orig_sys_references obj_mosr
   where cont_int.batch_id = P_BATCH_ID
     and cont_int.sub_orig_system = P_OS
     and cont_int.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
     and cont_int.interface_status is null
     and cont_int.batch_id = sub_sg.batch_id(+)
     and sub_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
    -- and sub_sg.action_flag(+)='I'
     and cont_int.batch_id = obj_sg.batch_id(+)
     and obj_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
    -- and obj_sg.action_flag(+)='I'
     and cont_mosr.owner_table_name (+) = 'HZ_ORG_CONTACTS'
     and cont_mosr.status (+) = 'A'
     and cont_int.contact_orig_system_reference = cont_mosr.orig_system_reference (+)
     and cont_int.contact_orig_system = cont_mosr.orig_system (+)
     and cont_int.sub_orig_system_reference = sub_sg.party_orig_system_reference (+)
     and cont_int.sub_orig_system = sub_sg.party_orig_system (+)
     and sub_mosr.owner_table_name (+) = 'HZ_PARTIES'
     and sub_mosr.status (+) = 'A'
     and sub_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
     and sub_sg.party_orig_system (+) = P_OS
     and sub_sg.batch_id(+) = P_BATCH_ID
     and cont_int.sub_orig_system_reference = sub_mosr.orig_system_reference (+)
     and cont_int.sub_orig_system = sub_mosr.orig_system (+)
     and cont_int.obj_orig_system_reference = obj_sg.party_orig_system_reference (+)
     and cont_int.obj_orig_system = obj_sg.party_orig_system (+)
     and obj_mosr.owner_table_name (+) = 'HZ_PARTIES'
     and obj_mosr.status (+) = 'A'
     and cont_int.obj_orig_system_reference = obj_mosr.orig_system_reference (+)
     and cont_int.obj_orig_system = obj_mosr.orig_system (+)
     and cont_int.batch_id = sub_int.batch_id(+)
     and sub_int.interface_status(+) is null
     and cont_int.sub_orig_system_reference =sub_int.party_orig_system_reference (+)
     and cont_int.sub_orig_system = sub_int.party_orig_system (+)
     and cont_int.batch_id = obj_int.batch_id(+)
     and obj_int.interface_status(+) is null
     and cont_int.obj_orig_system_reference = obj_int.party_orig_system_reference (+)
     and cont_int.obj_orig_system = obj_int.party_orig_system (+)
   );
   end if;
   commit;
   end match_contacts;


   PROCEDURE match_contactroles(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                      IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC           IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   begin
   if(P_RERUN = 'Y') then
INSERT INTO HZ_IMP_CONTACTROLES_SG
     (
       SUB_ORIG_SYSTEM,
       SUB_ORIG_SYSTEM_REFERENCE,
       CONTACT_ID,
       CONTACT_ROLE_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       ERROR_FLAG,
       BATCH_MODE_FLAG, BATCH_ID
     )
     (
   select /*+ leading(conr_w_cid) use_nl(hz_conr) */
          sos, sosr,
          conr_w_cid.contact_id contact_id,
          nvl(hz_conr.org_contact_role_id, hz_org_contact_roles_S.NextVal) conr_id,
          conr_w_cid.int_row_id int_row_id,
          nvl2(hz_conr.org_contact_role_id, 'U', 'I') action_flag,
          decode(conr_w_cid.cont_action_flag,
            'I', decode(conr_w_cid.sub_id, conr_w_cid.cont_sub_id, null, 2),
            null) error_flag,
         P_BATCH_MODE_FLAG, P_BATCH_ID
     from hz_org_contact_roles hz_conr,
     (
       select /*+ no_merge leading(conrole_int) index_asc(conrole_int)
		  use_nl(cont_sg,con_mosr,party_mosr) use_hash(party_sg) */
              conrole_int.sub_orig_system sos,
              conrole_int.sub_orig_system_reference sosr,
              nvl(cont_sg.contact_id, con_mosr.owner_table_id) contact_id,
              conrole_int.rowid int_row_id,
              nvl(party_sg.party_id, party_mosr.owner_table_id) sub_id,
              cont_sg.sub_id cont_sub_id,
              cont_sg.action_flag cont_action_flag,
              conrole_int.role_type role_type
         from hz_imp_contactroles_int conrole_int,
              hz_imp_contacts_sg cont_sg,
              hz_orig_sys_references con_mosr,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references party_mosr--,
        where conrole_int.batch_id = P_BATCH_ID
          and conrole_int.sub_orig_system = P_OS
              and conrole_int.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and conrole_int.interface_status = 'C'
          and conrole_int.batch_id = party_sg.batch_id(+)
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
          and conrole_int.batch_id = cont_sg.batch_id(+)
          and cont_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and cont_sg.action_flag(+)='I'
          and con_mosr.owner_table_name (+) = 'HZ_ORG_CONTACTS'
          and con_mosr.status (+) = 'A'
          and conrole_int.contact_orig_system_reference = con_mosr.orig_system_reference (+)
          and conrole_int.contact_orig_system = con_mosr.orig_system (+)
          and conrole_int.contact_orig_system_reference = cont_sg.contact_orig_system_reference (+)
          and conrole_int.contact_orig_system = cont_sg.contact_orig_system (+)
          and party_mosr.owner_table_name (+) = 'HZ_PARTIES'
          and party_mosr.status (+) = 'A'
          and conrole_int.sub_orig_system_reference = party_mosr.orig_system_reference (+)
          and conrole_int.sub_orig_system = party_mosr.orig_system (+)
          and conrole_int.sub_orig_system_reference = party_sg.party_orig_system_reference (+)
          and conrole_int.sub_orig_system = party_sg.party_orig_system (+)
     ) conr_w_cid
    where conr_w_cid.contact_id = hz_conr.org_contact_id (+)
      and conr_w_cid.role_type = hz_conr.role_type (+)
   );
   else
INSERT INTO HZ_IMP_CONTACTROLES_SG
     (
       SUB_ORIG_SYSTEM,
       SUB_ORIG_SYSTEM_REFERENCE,
       CONTACT_ID,
       CONTACT_ROLE_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       ERROR_FLAG,
       BATCH_MODE_FLAG, BATCH_ID
     )
     (
   select /*+ leading(conr_w_cid) use_nl(hz_conr) */
          sos, sosr,
          conr_w_cid.contact_id contact_id,
          nvl(hz_conr.org_contact_role_id, hz_org_contact_roles_S.NextVal) conr_id,
          conr_w_cid.int_row_id int_row_id,
          nvl2(hz_conr.org_contact_role_id, 'U', 'I') action_flag,
          decode(conr_w_cid.cont_action_flag,
            'I', decode(conr_w_cid.sub_id, conr_w_cid.cont_sub_id, null, 2),
            null) error_flag,
         P_BATCH_MODE_FLAG, P_BATCH_ID
     from hz_org_contact_roles hz_conr,
     (
       select /*+ no_merge leading(conrole_int) index_asc(conrole_int)
		  use_nl(cont_sg,con_mosr,party_mosr) use_hash(party_sg) */
              conrole_int.sub_orig_system sos,
              conrole_int.sub_orig_system_reference sosr,
              nvl(cont_sg.contact_id, con_mosr.owner_table_id) contact_id,
              conrole_int.rowid int_row_id,
              nvl(party_sg.party_id, party_mosr.owner_table_id) sub_id,
              cont_sg.sub_id cont_sub_id,
              cont_sg.action_flag cont_action_flag,
              conrole_int.role_type role_type
         from hz_imp_contactroles_int conrole_int,
              hz_imp_contacts_sg cont_sg,
              hz_orig_sys_references con_mosr,
              hz_imp_parties_sg party_sg,
              hz_orig_sys_references party_mosr--,
        where conrole_int.batch_id = P_BATCH_ID
          and conrole_int.sub_orig_system = P_OS
              and conrole_int.sub_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and conrole_int.interface_status is null
          and conrole_int.batch_id = party_sg.batch_id(+)
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
          and conrole_int.batch_id = cont_sg.batch_id(+)
          and cont_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and cont_sg.action_flag(+)='I'
          and con_mosr.owner_table_name (+) = 'HZ_ORG_CONTACTS'
          and con_mosr.status (+) = 'A'
          and conrole_int.contact_orig_system_reference = con_mosr.orig_system_reference (+)
          and conrole_int.contact_orig_system = con_mosr.orig_system (+)
          and conrole_int.contact_orig_system_reference = cont_sg.contact_orig_system_reference (+)
          and conrole_int.contact_orig_system = cont_sg.contact_orig_system (+)
          and party_mosr.owner_table_name (+) = 'HZ_PARTIES'
          and party_mosr.status (+) = 'A'
          and conrole_int.sub_orig_system_reference = party_mosr.orig_system_reference (+)
          and conrole_int.sub_orig_system = party_mosr.orig_system (+)
          and conrole_int.sub_orig_system_reference = party_sg.party_orig_system_reference (+)
          and conrole_int.sub_orig_system = party_sg.party_orig_system (+)
     ) conr_w_cid
    where conr_w_cid.contact_id = hz_conr.org_contact_id (+)
      and conr_w_cid.role_type = hz_conr.role_type (+)
   );
   end if;
   commit;
   end match_contactroles;


   PROCEDURE match_addruses(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   ) IS

   begin
   if (P_RERUN = 'Y') then
INSERT INTO HZ_IMP_ADDRESSUSES_SG
     ( SITE_USE_TYPE,
       PARTY_ORIG_SYSTEM,
       PARTY_ORIG_SYSTEM_REFERENCE,
       PARTY_SITE_USE_ID,
       PARTY_SITE_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       ERROR_FLAG,
       BATCH_MODE_FLAG, BATCH_ID,
       PRIMARY_FLAG
     )
     (
select /*+ leading(addruse_w_id) use_nl(hz_psuse) */
       addruse_w_id.site_use_type, pos, posr,
       nvl(hz_psuse.party_site_use_id, hz_party_site_uses_s.nextval)
       siteusr_id, addruse_w_id.site_id, addruse_w_id.int_row_id,
       nvl2(hz_psuse.party_site_use_id, 'U', 'I') action_flag,
       decode(addruse_w_id.addr_action_flag, 'I', decode(
       addruse_w_id.party_id, addruse_w_id.addr_party_id, null, 2), null)
       error_flag, P_BATCH_MODE_FLAG, P_BATCH_ID, decode(row_number() over
       (partition by addruse_w_id.party_id, addruse_w_id.site_use_type
        order by nvl2(hz_psuse.party_site_use_id, hz_psuse.primary_per_type,
                 addruse_w_id.primary_flag) desc nulls last,
                 hz_psuse.party_site_use_id nulls last), 1, decode((
       select count(*)
         from hz_party_sites hz_ps,
              hz_party_site_uses hz_ps_use
        where hz_ps.party_id = addruse_w_id.party_id
          and hz_ps.party_site_id = hz_ps_use.party_site_id
          and hz_ps_use.site_use_type = addruse_w_id.site_use_type
          and hz_ps_use.primary_per_type = 'Y'
          and hz_ps_use.status = 'A'
          and rownum < 2), 0, 'Y')) primary_flag
  from hz_party_site_uses hz_psuse,
       (
       select /*+ no_merge ordered index_asc(addruse_int) index(addr_sg,HZ_IMP_ADDRESSES_SG_N2)
                  use_nl(addr_sg,addr_mosr,party_mosr) use_hash(party_sg) */
	      addruse_int.party_orig_system pos,
	      addruse_int.party_orig_system_reference posr,
          nvl(addr_sg.party_site_id, addr_mosr.owner_table_id)
	      site_id, addruse_int.rowid int_row_id, nvl(
	      party_sg.party_id, party_mosr.owner_table_id) party_id,
	      addr_sg.party_id addr_party_id, addruse_int.site_use_type,
	      nvl(addr_sg.action_flag, 'U') addr_action_flag,
	      addruse_int.primary_flag
         from hz_imp_addressuses_int addruse_int,
              hz_imp_parties_sg party_sg,
              hz_imp_addresses_sg addr_sg,
              hz_orig_sys_references addr_mosr,
              hz_orig_sys_references party_mosr
        where addruse_int.batch_id = P_BATCH_ID
          and addruse_int.party_orig_system = P_OS
          and addruse_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and addruse_int.interface_status = 'C'
          and addruse_int.batch_id = party_sg.batch_id(+)
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
          and addruse_int.batch_id = addr_sg.batch_id(+)
          and addr_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and addr_sg.action_flag(+)='I'
          and addr_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
          and addr_mosr.status (+) = 'A'
          and addruse_int.site_orig_system_reference = addr_mosr.orig_system_reference (+)
          and addruse_int.site_orig_system = addr_mosr.orig_system (+)
          and addruse_int.site_orig_system_reference = addr_sg.site_orig_system_reference (+)
          and addruse_int.site_orig_system = addr_sg.site_orig_system (+)
          and party_mosr.owner_table_name (+) = 'HZ_PARTIES'
          and party_mosr.status (+) = 'A'
          and addruse_int.party_orig_system_reference = party_mosr.orig_system_reference (+)
          and addruse_int.party_orig_system = party_mosr.orig_system (+)
          and addruse_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and addruse_int.party_orig_system = party_sg.party_orig_system (+)
       ) addruse_w_id
 where addruse_w_id.site_id = hz_psuse.party_site_id (+)
   and addruse_w_id.site_use_type = hz_psuse.site_use_type (+)
   );
   else
INSERT INTO HZ_IMP_ADDRESSUSES_SG
     ( SITE_USE_TYPE,
       PARTY_ORIG_SYSTEM,
       PARTY_ORIG_SYSTEM_REFERENCE,
       PARTY_SITE_USE_ID,
       PARTY_SITE_ID,
       INT_ROW_ID,
       ACTION_FLAG,
       ERROR_FLAG,
       BATCH_MODE_FLAG, BATCH_ID,
       PRIMARY_FLAG
     )
     (
select /*+ leading(addruse_w_id) use_nl(hz_psuse) */
       addruse_w_id.site_use_type, pos, posr,
       nvl(hz_psuse.party_site_use_id, hz_party_site_uses_s.nextval)
       siteusr_id, addruse_w_id.site_id, addruse_w_id.int_row_id,
       nvl2(hz_psuse.party_site_use_id, 'U', 'I') action_flag,
       decode(addruse_w_id.addr_action_flag, 'I', decode(
       addruse_w_id.party_id, addruse_w_id.addr_party_id, null, 2), null)
       error_flag, P_BATCH_MODE_FLAG, P_BATCH_ID, decode(row_number() over
       (partition by addruse_w_id.party_id, addruse_w_id.site_use_type
        order by nvl2(hz_psuse.party_site_use_id, hz_psuse.primary_per_type,
                 addruse_w_id.primary_flag) desc nulls last,
                 hz_psuse.party_site_use_id nulls last), 1, decode((
       select count(*)
         from hz_party_sites hz_ps,
              hz_party_site_uses hz_ps_use
        where hz_ps.party_id = addruse_w_id.party_id
          and hz_ps.party_site_id = hz_ps_use.party_site_id
          and hz_ps_use.site_use_type = addruse_w_id.site_use_type
          and hz_ps_use.primary_per_type = 'Y'
          and hz_ps_use.status = 'A'
          and rownum < 2), 0, 'Y')) primary_flag
  from hz_party_site_uses hz_psuse,
       (
       select /*+ no_merge ordered index_asc(addruse_int) index(addr_sg,HZ_IMP_ADDRESSES_SG_N2)
                  use_nl(addr_sg,addr_mosr,party_mosr) use_hash(party_sg) */
	      addruse_int.party_orig_system pos,
	      addruse_int.party_orig_system_reference posr,
          nvl(addr_sg.party_site_id, addr_mosr.owner_table_id)
	      site_id, addruse_int.rowid int_row_id, nvl(
	      party_sg.party_id, party_mosr.owner_table_id) party_id,
	      addr_sg.party_id addr_party_id, addruse_int.site_use_type,
	      nvl(addr_sg.action_flag, 'U') addr_action_flag,
	      addruse_int.primary_flag
         from hz_imp_addressuses_int addruse_int,
              hz_imp_parties_sg party_sg,
              hz_imp_addresses_sg addr_sg,
              hz_orig_sys_references addr_mosr,
              hz_orig_sys_references party_mosr
        where addruse_int.batch_id = P_BATCH_ID
          and addruse_int.party_orig_system = P_OS
          and addruse_int.party_orig_system_reference between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system_reference (+) between P_FROM_OSR and P_TO_OSR
          and party_sg.party_orig_system (+) = P_OS
          and party_sg.batch_id(+) = P_BATCH_ID
          and addruse_int.interface_status is null
          and addruse_int.batch_id = party_sg.batch_id(+)
          and party_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and party_sg.action_flag(+)='I'
          and addruse_int.batch_id = addr_sg.batch_id(+)
          and addr_sg.batch_mode_flag(+)=P_BATCH_MODE_FLAG
          and addr_sg.action_flag(+)='I'
          and addr_mosr.owner_table_name (+) = 'HZ_PARTY_SITES'
          and addr_mosr.status (+) = 'A'
          and addruse_int.site_orig_system_reference = addr_mosr.orig_system_reference (+)
          and addruse_int.site_orig_system = addr_mosr.orig_system (+)
          and addruse_int.site_orig_system_reference = addr_sg.site_orig_system_reference (+)
          and addruse_int.site_orig_system = addr_sg.site_orig_system (+)
          and party_mosr.owner_table_name (+) = 'HZ_PARTIES'
          and party_mosr.status (+) = 'A'
          and addruse_int.party_orig_system_reference = party_mosr.orig_system_reference (+)
          and addruse_int.party_orig_system = party_mosr.orig_system (+)
          and addruse_int.party_orig_system_reference = party_sg.party_orig_system_reference (+)
          and addruse_int.party_orig_system = party_sg.party_orig_system (+)
       ) addruse_w_id
 where addruse_w_id.site_id = hz_psuse.party_site_id (+)
   and addruse_w_id.site_use_type = hz_psuse.site_use_type (+)
   );
   end if;
   commit;
   end match_addruses;


END HZ_IMP_LOAD_SSM_MATCHING_PKG;

/
