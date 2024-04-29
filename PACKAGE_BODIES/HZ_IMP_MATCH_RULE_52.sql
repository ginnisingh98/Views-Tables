--------------------------------------------------------
--  DDL for Package Body HZ_IMP_MATCH_RULE_52
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_MATCH_RULE_52" AS
    g_match_rule_id NUMBER := 52;
    TYPE StageImpContactCurTyp IS REF CURSOR;
    TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE CharList2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    TYPE CharList1000 IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
    TYPE CharList30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE CharList60 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE CharList240 IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
    TYPE CharList1 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE RowIdList IS TABLE OF rowid INDEX BY BINARY_INTEGER; 
    H_P_ROW_ID RowIdList; 
    H_P_N_PARTY CharList1; 
    H_P_PARTY_ID NumberList;
    H_P_PARTY_OS CharList30;
    H_P_PARTY_OSR CharList240;
    H_P_PS_OS CharList30;
    H_P_PS_OSR CharList240;
    H_P_P_TYPE CharList30; 
    H_P_PARTY_SITE_ID NumberList;
    H_P_CONTACT_POINT_ID NumberList;
    H_P_CP_OS CharList30;
    H_P_CP_OSR CharList240;
    H_P_SUBJECT_OS CharList30;
    H_P_SUBJECT_OSR CharList240;
    H_P_CONTACT_OS CharList30;
    H_P_CONTACT_OSR CharList240;
    H_P_CP_TYPE CharList30; 
    H_TX0 CharList2000;
    g_limit NUMBER := 1000;
    H_CT_OBJ_ID NumberList; 
    H_TX10 CharList2000;
    H_TX11 CharList2000;
    H_TX14 CharList2000;
    H_TX15 CharList2000;
    H_TX156 CharList2000;
    H_TX158 CharList2000;
    H_TX19 CharList2000;
    H_TX2 CharList2000;
    H_TX22 CharList2000;
    H_TX23 CharList2000;
    H_TX24 CharList2000;
    H_TX26 CharList2000;
    H_TX27 CharList2000;
    H_TX3 CharList2000;
    H_TX36 CharList2000;
    H_TX4 CharList2000;
    H_TX41 CharList2000;
    H_TX45 CharList2000;
    H_TX46 CharList2000;
    H_TX5 CharList2000;
    H_TX59 CharList2000;
    H_TX6 CharList2000;
    H_TX60 CharList2000;
    H_TX7 CharList2000;
    H_TX8 CharList2000;
    H_TX9 CharList2000;
    H_8E CharList2000;
    H_14E CharList2000;
    H_16E CharList2000;
    H_19E CharList2000;
    H_20E CharList2000;
    H_29E CharList2000;
    H_30E CharList2000;
    H_32E CharList2000;
    H_36E CharList2000;
    H_43E CharList2000;
    H_48E CharList2000;
    H_49E CharList2000;
    H_CT_NAME CharList2000; 
    H_CT_CUST_TX2 CharList2000;
    H_CT_CUST_TX23 CharList2000;
    H_P_CP_R_PH_NO CharList60; 
    H_CP_CUST_TX10 CharList2000;
    H_CP_CUST_TX158 CharList2000;
    H_P_PS_ADD CharList1000; 
    H_PS_CUST_TX26 CharList2000;
PROCEDURE pop_parties (
   	 p_batch_id IN	NUMBER,
        p_from_osr                       IN   VARCHAR2,
   	 p_to_osr                         IN   VARCHAR2,
        p_batch_mode_flag                IN   VARCHAR2 
) IS 
 l_last_fetch BOOLEAN := FALSE;
 p_party_cur HZ_PARTY_STAGE.StageCurTyp;

 count NUMBER := 0;
  BEGIN 
-- query for interface to TCA
        open p_party_cur FOR 
  select decode(a.party_type, 'ORGANIZATION', a.organization_name, 'PERSON', a.person_first_name || ' ' || a.person_last_name) as PARTY_NAME , a.PARTY_TYPE, a.DUNS_NUMBER_C, a.JGZZ_FISCAL_CODE, a.party_orig_system, a.party_orig_system_reference, b.party_id, a.rowid, a.party_type
    		from hz_imp_parties_int a, hz_imp_parties_sg b 
    		where  b.action_flag = 'I'
    		and b.int_row_id = a.rowid 
            and a.batch_id = p_batch_id 
            and b.party_orig_system_reference >=  p_from_osr 
            and b.party_orig_system_reference <= p_to_osr  
            and b.batch_mode_flag = p_batch_mode_flag 
            and interface_status is null ; 
   LOOP 
    FETCH p_party_cur BULK COLLECT INTO 
       H_8E, H_14E, H_16E, H_19E, H_P_PARTY_OS , H_P_PARTY_OSR, H_P_PARTY_ID, H_P_ROW_ID, H_P_P_TYPE
          LIMIT g_limit; 
    IF (p_party_cur%NOTFOUND)  THEN 
      l_last_fetch:=TRUE;
    END IF;
   
    IF H_P_PARTY_OS.COUNT=0 AND l_last_fetch THEN
      EXIT;
    END IF;
   
    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP
        HZ_TRANS_PKG.set_party_type(H_P_P_TYPE(I));
        H_TX2(I) := HZ_TRANS_PKG.EXACT_PADDED(H_8E(I), NULL, 'PARTY_NAME', 'PARTY');
        H_TX36(I) := HZ_TRANS_PKG.EXACT(H_14E(I), NULL, 'PARTY_TYPE', 'PARTY');
        H_TX41(I) := HZ_TRANS_PKG.EXACT(H_16E(I), NULL, 'DUNS_NUMBER_C', 'PARTY');
        H_TX45(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_19E(I), NULL, 'JGZZ_FISCAL_CODE', 'PARTY', 'SEARCH' );
        H_TX59(I) := HZ_TRANS_PKG.BASIC_WRNAMES(H_8E(I), NULL, 'PARTY_NAME', 'PARTY', 'SEARCH' );
    END LOOP;
    SAVEPOINT pop_parties;
    BEGIN 
      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST
        INSERT INTO HZ_SRCH_PARTIES (
          TX2, TX36, TX41, TX45, TX59, PARTY_OS, PARTY_OSR, PARTY_ID, BATCH_ID, INT_ROW_ID
        ) VALUES ( 
          H_TX2(I), H_TX36(I), H_TX41(I), H_TX45(I), H_TX59(I),  H_P_PARTY_OS(I),  H_P_PARTY_OSR(I),  H_P_PARTY_ID(I), P_BATCH_ID, H_P_ROW_ID(I)
            ); 
      EXCEPTION 
        WHEN OTHERS THEN
          ROLLBACK to pop_parties;
 --          dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
          RAISE;
      END ;
      IF l_last_fetch THEN
        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;
      FND_CONCURRENT.AF_Commit;
      
   END LOOP; 
   CLOSE  p_party_cur; 
  END pop_parties; 

  PROCEDURE pop_party_sites ( 
   	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
  	 p_to_osr                         IN   VARCHAR2, 
      p_batch_mode_flag                IN   VARCHAR2 
    ) IS 
 l_last_fetch BOOLEAN := FALSE; 
 l_party_site_cur HZ_PARTY_STAGE.StageCurTyp; 
 
  BEGIN 
-- query for interface to tca 
		open l_party_site_cur for 
  select  decode(accept_standardized_flag, 'Y', a.CITY_STD, a.CITY),  decode(accept_standardized_flag, 'Y', a.POSTAL_CODE_STD, a.POSTAL_CODE),  a.STATE,  decode(accept_standardized_flag, 'Y', a.COUNTRY_STD, a.COUNTRY), a.party_orig_system, a.party_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, b.party_id, b.party_site_id, b.party_action_flag, a.rowid, decode(accept_standardized_flag, 'Y', a.ADDRESS1_STD, a.ADDRESS1) || ' ' || decode(accept_standardized_flag, 'Y', a.ADDRESS2_STD, a.ADDRESS2) || ' ' || decode(accept_standardized_flag, 'Y', a.ADDRESS3_STD, a.ADDRESS3) || ' ' || decode(accept_standardized_flag, 'Y', a.ADDRESS4_STD, a.ADDRESS4) as address 
            from hz_imp_addresses_int a, hz_imp_addresses_sg b 
            where a.batch_id = p_batch_id 
            and b.action_flag = 'I' 
            and b.int_row_id = a.rowid 
            and a.party_orig_system_reference >= p_from_osr 
            and a.party_orig_system_reference <= p_to_osr 
            and b.batch_mode_flag = p_batch_mode_flag 
            and interface_status is null ; 
   LOOP 
    FETCH l_party_site_cur BULK COLLECT INTO 
       H_29E, H_30E, H_32E, H_36E, H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_ID, H_P_PARTY_SITE_ID, H_P_N_PARTY, H_P_ROW_ID, H_P_PS_ADD 
      LIMIT g_limit;  
     
    IF (l_party_site_cur%NOTFOUND) THEN 
      l_last_fetch := TRUE;
    END IF;
   
    IF H_P_PS_OS.COUNT = 0 AND l_last_fetch THEN
      EXIT;
    END IF;
   
    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP     
----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY_SITES LEVEL ---------
      HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_36E(I) );
        H_TX11(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_30E(I), NULL, 'POSTAL_CODE', 'PARTY_SITES', 'SEARCH' );
        H_TX14(I) := HZ_TRANS_PKG.WRSTATE_EXACT(H_32E(I), NULL, 'STATE', 'PARTY_SITES', 'SEARCH' );
        H_TX22(I) := HZ_TRANS_PKG.EXACT(H_36E(I), NULL, 'COUNTRY', 'PARTY_SITES');
        H_TX9(I) := HZ_TRANS_PKG.EXACT(H_29E(I), NULL, 'CITY', 'PARTY_SITES');
        H_PS_CUST_TX26(I) := HZ_TRANS_PKG.BASIC_WRADDR(H_P_PS_ADD(I), NULL, 'ADDRESS', 'PARTY_SITES', 'SEARCH' );
    END LOOP; 
    SAVEPOINT pop_party_sites; 
    BEGIN      
      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST 
        INSERT INTO HZ_SRCH_PSITES ( 
          TX11, TX14, TX22, TX9, PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID , TX26
        ) VALUES (  
          H_TX11(I), H_TX14(I), H_TX22(I), H_TX9(I), H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I) , H_PS_CUST_TX26(I)
            ); 
      EXCEPTION 
        WHEN OTHERS THEN 
          ROLLBACK to pop_party_sites; 
          RAISE; 
      END; 
       
      IF l_last_fetch THEN 
        FND_CONCURRENT.AF_Commit; 
        EXIT; 
      END IF; 
      FND_CONCURRENT.AF_Commit; 
       
   END LOOP; 
   CLOSE  l_party_site_cur; 
	  END pop_party_sites; 
  PROCEDURE pop_cp (  
   	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
  	     p_to_osr                         IN   VARCHAR2, 
        p_batch_mode_flag                  IN VARCHAR2 
    ) IS  
  
    	l_last_fetch BOOLEAN := FALSE; 
      l_cp_cur HZ_PARTY_STAGE.StageCurTyp;
  BEGIN 
	open l_cp_cur for 
  select a.EMAIL_ADDRESS, a.URL, a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, b.party_site_id, b.contact_point_id, b.party_id, b.party_action_flag, a.rowid, a.contact_point_type, decode(a.raw_phone_number, null, a.PHONE_COUNTRY_CODE||a.PHONE_AREA_CODE ||a.phone_number, a.raw_phone_number) as raw_phone_number 
    	from  HZ_IMP_CONTACTPTS_INT a,  HZ_IMP_CONTACTPTS_SG b --
    	where a.batch_id = p_batch_id  
    	and b.action_flag = 'I' 
 		and b.int_row_id = a.rowid 
    	and b.party_orig_system_reference >= p_from_osr 
    	and b.party_orig_system_reference <= p_to_osr 
       and b.batch_mode_flag = p_batch_mode_flag 
       and interface_status is null ; 
   LOOP 
      FETCH l_cp_cur BULK COLLECT INTO 
       H_48E, H_49E, H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_SITE_ID, H_P_CONTACT_POINT_ID, H_P_PARTY_ID, H_P_N_PARTY, H_P_ROW_ID, H_P_CP_TYPE, H_P_CP_R_PH_NO 
       LIMIT g_limit; 
     IF l_cp_cur%NOTFOUND THEN    
       l_last_fetch := TRUE; 
     END IF; 
      
     IF H_P_CP_OSR.COUNT = 0 AND l_last_fetch THEN 
       EXIT; 
     END IF; 
      
     FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP   
        H_TX5(I) := HZ_TRANS_PKG.EXACT_EMAIL(H_48E(I), NULL, 'EMAIL_ADDRESS', 'CONTACT_POINTS');
        H_TX7(I) := HZ_TRANS_PKG.EXACT_URL(H_49E(I), NULL, 'URL', 'CONTACT_POINTS');
        H_CP_CUST_TX10(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_P_CP_R_PH_NO(I), NULL, 'RAW_PHONE_NUMBER', 'CONTACT_POINTS', 'SEARCH' );
        H_CP_CUST_TX158(I) := HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_P_CP_R_PH_NO(I), NULL, 'RAW_PHONE_NUMBER', 'CONTACT_POINTS'); 
     END LOOP;  
     SAVEPOINT POP_CP; 
     BEGIN      
       FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST  
         INSERT INTO HZ_SRCH_CPTS  ( 
          TX5, TX7, PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_POINT_ID, CONTACT_PT_OS, CONTACT_PT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE , TX10, TX158
        ) VALUES ( 
          H_TX5(I), H_TX7(I), H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I) , H_P_CONTACT_POINT_ID(I), H_P_CP_OS(I), H_P_CP_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I) , H_CP_CUST_TX10(I), H_CP_CUST_TX158(I)
            );  
      EXCEPTION  
        WHEN OTHERS THEN  
          ROLLBACK to POP_CP;  
          RAISE; 
      END; 
        
       IF l_last_fetch THEN 
         FND_CONCURRENT.AF_Commit; 
         EXIT; 
       END IF; 
       FND_CONCURRENT.AF_Commit; 
 
  END LOOP; 
  CLOSE l_cp_cur; 
  END pop_cp; 
   PROCEDURE get_contact_cur( 
    	 p_batch_id IN	NUMBER, 
        p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2, 
        p_batch_mode_flag                IN   VARCHAR2, 
        x_contact_cur IN OUT NOCOPY StageImpContactCurTyp 
 ) IS  
   	 is_using_allow_cust_attr	VARCHAR2(1); 
      CURSOR c1 is    select 'Y' 
      from hz_trans_attributes_vl  
      where entity_name = 'CONTACTS'   
      and attribute_name = 'CONTACT_NAME' 
      and attribute_id in (    
      select attribute_id 
      from hz_match_rule_primary b 
      where match_rule_id = 52
      union 
      select attribute_id 
      from hz_match_rule_secondary b 
      where match_rule_id = 52 ) and rownum = 1;   
 
 BEGIN 
    OPEN c1; 
    LOOP     
     FETCH c1 INTO is_using_allow_cust_attr; 
     EXIT when c1%NOTFOUND; 
    END LOOP;  
   CLOSE  c1; 
    IF (is_using_allow_cust_attr = 'Y') THEN 
      OPEN x_contact_cur FOR      
  select a.JOB_TITLE, a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, b.party_action_flag, a.rowid, b.obj_id, c.person_first_name || '  ' || c.person_last_name as person_name
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b, HZ_IMP_PARTIES_INT c 
         	where a.batch_id = p_batch_id 
         	and b.action_flag = 'I' 
             and b.int_row_id = a.rowid  
             and a.sub_orig_system_reference >= p_from_osr 
             and a.sub_orig_system_reference <= p_to_osr 
             and a.sub_orig_system = c.party_orig_system 
             and a.batch_id = c.batch_id 
             and b.sub_id = c.party_id 
            and b.batch_mode_flag = p_batch_mode_flag 
            and a.interface_status is null  
             union all 
  select a.JOB_TITLE, a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, b.party_action_flag, a.rowid, b.obj_id,  c.party_name as person_name
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b, hz_parties c  
         	where a.batch_id = p_batch_id 
         	and b.action_flag = 'I' 
             and b.int_row_id = a.rowid 
             and a.sub_orig_system_reference >= p_from_osr 
             and a.sub_orig_system_reference <= p_to_osr 
             and b.sub_id = c.party_id 
            and b.batch_mode_flag = p_batch_mode_flag 
            and a.interface_status is null  
        ; 
   ELSE       
      OPEN x_contact_cur FOR 
  select a.JOB_TITLE, a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, b.party_action_flag, a.rowid, b.obj_id 
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b 
         	where a.batch_id = p_batch_id 
         	and b.action_flag = 'I' 
             and b.int_row_id = a.rowid  
             and a.sub_orig_system_reference  >= p_from_osr 
             and a.sub_orig_system_reference  <= p_to_osr    
            and b.batch_mode_flag = p_batch_mode_flag 
            and a.interface_status is null ; 
        END IF; 
 END get_contact_cur; 
 
 PROCEDURE pop_contacts ( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2, 
      p_batch_mode_flag                IN   VARCHAR2 
     ) IS  
  l_last_fetch BOOLEAN := FALSE; 
  l_contact_cur StageImpContactCurTyp; 
   
   BEGIN 
      get_contact_cur(p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag, l_contact_cur ); 
    LOOP 
       FETCH l_contact_cur BULK COLLECT INTO 
       H_43E, H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_N_PARTY, H_P_ROW_ID, H_CT_OBJ_ID , H_CT_NAME 
      LIMIT g_limit;  
  
     IF l_contact_cur%NOTFOUND THEN     
       l_last_fetch:=TRUE; 
     END IF; 
     IF H_P_CONTACT_OS.COUNT=0 AND l_last_fetch THEN 
       EXIT; 
     END IF; 
      
     FOR I in H_P_CONTACT_OSR.FIRST..H_P_CONTACT_OSR.LAST LOOP 
        H_TX22(I) := HZ_TRANS_PKG.EXACT(H_43E(I), NULL, 'JOB_TITLE', 'CONTACTS');
        H_CT_CUST_TX23(I) := HZ_TRANS_PKG.BASIC_WRPERSON(H_CT_NAME(I), NULL, 'CONTACT_NAME', 'CONTACTS', 'SEARCH' );
        H_CT_CUST_TX2(I) := HZ_TRANS_PKG.EXACT_PADDED(H_CT_NAME(I), NULL, 'CONTACT_NAME', 'CONTACTS'); 
     END LOOP; 
     SAVEPOINT pop_contacts; 
     BEGIN     
       FORALL I in H_P_CONTACT_OSR.FIRST..H_P_CONTACT_OSR.LAST 
         INSERT INTO HZ_SRCH_CONTACTS ( 
          TX22, PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, PARTY_ID , TX2, TX23
         ) VALUES ( 
          H_TX22(I), H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_CT_OBJ_ID(I) , H_CT_CUST_TX2(I), H_CT_CUST_TX23(I)
             ); 
       EXCEPTION  
         WHEN OTHERS THEN 
           ROLLBACK to pop_contacts; 
           RAISE; 
       END; 
        
       IF l_last_fetch THEN 
         FND_CONCURRENT.AF_Commit; 
         EXIT; 
       END IF; 
       FND_CONCURRENT.AF_Commit; 
        
    END LOOP; 
    CLOSE l_contact_cur ; 
 	  END pop_contacts; 
 
 PROCEDURE pop_parties_int ( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
    	 p_to_osr                         IN   VARCHAR2 
 ) IS  
  l_last_fetch BOOLEAN := FALSE; 
  p_party_cur HZ_PARTY_STAGE.StageCurTyp; 
  
  count NUMBER := 0; 
  l_os VARCHAR2(30); 
   BEGIN  
   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); 
         open p_party_cur FOR 
  select decode(a.party_type, 'ORGANIZATION', a.organization_name, 'PERSON', a.person_first_name || ' ' || a.person_last_name) as PARTY_NAME , a.PARTY_TYPE, a.DUNS_NUMBER_C, a.JGZZ_FISCAL_CODE, a.party_orig_system, a.party_orig_system_reference, a.rowid, a.party_type  , a.party_id 
    		from hz_imp_parties_int a  
    		where a.batch_id = p_batch_id  
         and a.party_orig_system_reference >= p_from_osr 
         and a.party_orig_system_reference <= p_to_osr 
         and a.party_orig_system = l_os; 
    LOOP 
    FETCH p_party_cur BULK COLLECT INTO 
       H_8E, H_14E, H_16E, H_19E, H_P_PARTY_OS , H_P_PARTY_OSR, H_P_ROW_ID, H_P_P_TYPE , H_P_PARTY_ID 
          LIMIT g_limit; 
    IF p_party_cur%NOTFOUND THEN 
      l_last_fetch:=TRUE; 
    END IF; 
    
    IF H_P_PARTY_OS.COUNT=0 AND l_last_fetch THEN 
      EXIT; 
    END IF; 
    
    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP 
        HZ_TRANS_PKG.set_party_type(H_P_P_TYPE(I));
        H_TX2(I) := HZ_TRANS_PKG.EXACT_PADDED(H_8E(I), NULL, 'PARTY_NAME', 'PARTY');
        H_TX36(I) := HZ_TRANS_PKG.EXACT(H_14E(I), NULL, 'PARTY_TYPE', 'PARTY');
        H_TX41(I) := HZ_TRANS_PKG.EXACT(H_16E(I), NULL, 'DUNS_NUMBER_C', 'PARTY');
        H_TX45(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_19E(I), NULL, 'JGZZ_FISCAL_CODE', 'PARTY', 'SEARCH' );
        H_TX59(I) := HZ_TRANS_PKG.BASIC_WRNAMES(H_8E(I), NULL, 'PARTY_NAME', 'PARTY', 'SEARCH' );
    END LOOP; 
    SAVEPOINT pop_parties_int; 
    BEGIN  
      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST 
        INSERT INTO HZ_SRCH_PARTIES ( 
          TX2, TX36, TX41, TX45, TX59, PARTY_OS, PARTY_OSR, BATCH_ID, INT_ROW_ID , PARTY_ID 
        ) VALUES ( 
          H_TX2(I), H_TX36(I), H_TX41(I), H_TX45(I), H_TX59(I),  H_P_PARTY_OS(I),  H_P_PARTY_OSR(I), P_BATCH_ID, H_P_ROW_ID(I) , H_P_PARTY_ID(I) 
            );  
      EXCEPTION  
        WHEN OTHERS THEN 
          ROLLBACK to pop_parties_int; 
--          dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255)); 
          RAISE; 
      END ; 
     IF l_last_fetch THEN 
        FND_CONCURRENT.AF_Commit; 
        EXIT; 
      END IF; 
      FND_CONCURRENT.AF_Commit; 
       
  END LOOP; 
   CLOSE  p_party_cur; 
  END pop_parties_int; 
 
  PROCEDURE pop_party_sites_int ( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2 
     ) IS  
  l_last_fetch BOOLEAN := FALSE; 
  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp; 
   
  l_os VARCHAR2(30); 
   BEGIN  
   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); 
 		open l_party_site_cur for 
  select a.CITY, a.POSTAL_CODE, a.STATE, a.COUNTRY, a.party_orig_system, a.party_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid,  a.address1 || ' ' || a.address2 || ' ' || a.address3 || ' ' || a.address4 as address   , a.party_id 
             from hz_imp_addresses_int a 
             where a.batch_id = p_batch_id 
             and a.party_orig_system_reference >= p_from_osr 
             and a.party_orig_system_reference <= p_to_osr 
             and a.party_orig_system = l_os; 
   LOOP 
     FETCH l_party_site_cur BULK COLLECT INTO 
       H_29E, H_30E, H_32E, H_36E, H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID, H_P_PS_ADD  , H_P_PARTY_ID 
      LIMIT g_limit; 
   
     IF l_party_site_cur%NOTFOUND THEN 
       l_last_fetch:=TRUE; 
     END IF; 
     IF H_P_PS_OS.COUNT=0 AND l_last_fetch THEN 
       EXIT; 
     END IF; 
      
     FOR I in H_P_PS_OSR.FIRST..H_P_PS_OSR.LAST LOOP 
----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY_SITES LEVEL ---------
      HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_36E(I) );
        H_TX11(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_30E(I), NULL, 'POSTAL_CODE', 'PARTY_SITES', 'SEARCH' );
        H_TX14(I) := HZ_TRANS_PKG.WRSTATE_EXACT(H_32E(I), NULL, 'STATE', 'PARTY_SITES', 'SEARCH' );
        H_TX22(I) := HZ_TRANS_PKG.EXACT(H_36E(I), NULL, 'COUNTRY', 'PARTY_SITES');
        H_TX9(I) := HZ_TRANS_PKG.EXACT(H_29E(I), NULL, 'CITY', 'PARTY_SITES');
        H_PS_CUST_TX26(I) := HZ_TRANS_PKG.BASIC_WRADDR(H_P_PS_ADD(I), NULL, 'ADDRESS', 'PARTY_SITES', 'SEARCH' );
     END LOOP; 
     SAVEPOINT pop_party_sites_int; 
     BEGIN      
       FORALL I in H_P_PS_OSR.FIRST..H_P_PS_OSR.LAST  
         INSERT INTO HZ_SRCH_PSITES ( 
          TX11, TX14, TX22, TX9, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, BATCH_ID, INT_ROW_ID, TX26 , PARTY_ID 
         ) VALUES ( 
          H_TX11(I), H_TX14(I), H_TX22(I), H_TX9(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), P_BATCH_ID, H_P_ROW_ID(I), H_PS_CUST_TX26(I) , H_P_PARTY_ID(I) 
             ); 
       EXCEPTION  
         WHEN OTHERS THEN 
           ROLLBACK to pop_party_sites_int; 
           RAISE; 
       END; 
     
       IF l_last_fetch THEN 
         FND_CONCURRENT.AF_Commit; 
         EXIT; 
       END IF; 
       FND_CONCURRENT.AF_Commit; 
     
    END LOOP; 
   CLOSE  l_party_site_cur; 
 	  END pop_party_sites_int; 
 
  PROCEDURE pop_cp_int ( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2 
     ) IS  
 	l_last_fetch BOOLEAN := FALSE; 
     l_cp_cur HZ_PARTY_STAGE.StageCurTyp; 
  l_os VARCHAR2(30); 
   BEGIN  
   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); 
 	open l_cp_cur for  
  select a.EMAIL_ADDRESS, a.URL, a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid, a.contact_point_type,decode(a.raw_phone_number, null, a.PHONE_COUNTRY_CODE||a.PHONE_AREA_CODE ||a.phone_number,a.raw_phone_number) as raw_phone_number  , a.party_id 
     	from HZ_IMP_CONTACTPTS_INT a 
     	where a.batch_id = p_batch_id  
     	and a.party_orig_system_reference >= p_from_osr 
     	and a.party_orig_system_reference <= p_to_osr 
         and a.party_orig_system = l_os; 
  
   LOOP 
       FETCH l_cp_cur BULK COLLECT INTO 
       H_48E, H_49E, H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID, H_P_CP_TYPE, H_P_CP_R_PH_NO  , H_P_PARTY_ID 
       LIMIT g_limit; 
     IF l_cp_cur%NOTFOUND THEN 
       l_last_fetch:=TRUE; 
     END IF; 
      
     IF H_P_CP_OS.COUNT=0 AND l_last_fetch THEN 
       EXIT; 
     END IF; 
     
     FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP 
        H_TX5(I) := HZ_TRANS_PKG.EXACT_EMAIL(H_48E(I), NULL, 'EMAIL_ADDRESS', 'CONTACT_POINTS');
        H_TX7(I) := HZ_TRANS_PKG.EXACT_URL(H_49E(I), NULL, 'URL', 'CONTACT_POINTS');
        H_CP_CUST_TX10(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_P_CP_R_PH_NO(I), NULL, 'RAW_PHONE_NUMBER', 'CONTACT_POINTS', 'SEARCH' );
        H_CP_CUST_TX158(I) := HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_P_CP_R_PH_NO(I), NULL, 'RAW_PHONE_NUMBER', 'CONTACT_POINTS'); 
     END LOOP; 
     SAVEPOINT pop_cp_int; 
     BEGIN      
       FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST 
         INSERT INTO HZ_SRCH_CPTS ( 
          TX5, TX7, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_PT_OS, CONTACT_PT_OSR, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE, TX10, TX158 , PARTY_ID 
         ) VALUES ( 
          H_TX5(I), H_TX7(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), H_P_CP_OS(I), H_P_CP_OSR(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I), H_CP_CUST_TX10(I), H_CP_CUST_TX158(I) ,H_P_PARTY_ID(I) 
             ); 
       EXCEPTION  
         WHEN OTHERS THEN 
           ROLLBACK to pop_cp_int; 
           RAISE; 
       END; 
      
       IF l_last_fetch THEN 
         FND_CONCURRENT.AF_Commit; 
         EXIT; 
       END IF; 
       FND_CONCURRENT.AF_Commit; 
      
    END LOOP; 
    CLOSE l_cp_cur ; 
 
  END pop_cp_int; 
 PROCEDURE get_contact_cur_int( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2, 
      x_contact_cur IN OUT NOCOPY StageImpContactCurTyp 
 ) IS  
   	 is_using_allow_cust_attr	VARCHAR2(1); 
      CURSOR c1 is    select 'Y' 
      from hz_trans_attributes_vl  
      where entity_name = 'CONTACTS'   
      and attribute_name = 'CONTACT_NAME' 
      and attribute_id in (    
      select attribute_id 
      from hz_match_rule_primary b 
      where match_rule_id = 52
      union 
      select attribute_id 
      from hz_match_rule_secondary b 
      where match_rule_id = 52 ) and rownum = 1;   
 
  l_os VARCHAR2(30); 
   BEGIN  --
   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); 
    OPEN c1; 
    LOOP     
     FETCH c1 into is_using_allow_cust_attr; 
     EXIT when c1%NOTFOUND; 
    END LOOP;  
    IF (is_using_allow_cust_attr = 'Y') THEN 
      OPEN x_contact_cur FOR      
  select a.JOB_TITLE, a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, a.rowid, c.person_first_name || '  ' || c.person_last_name as person_name
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_PARTIES_INT c 
         	where a.batch_id = p_batch_id 
             and a.sub_orig_system_reference >= p_from_osr 
             and a.sub_orig_system_reference <= p_to_osr 
             and a.sub_orig_system_reference = c.party_orig_system_reference 
             and a.sub_orig_system = c.party_orig_system 
             and a.batch_id = c.batch_id 
             and a.sub_orig_system = l_os; 
   ELSE        
      OPEN x_contact_cur FOR 
  select a.JOB_TITLE, a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, a.rowid,  null person_name
             from HZ_IMP_CONTACTS_INT a 
         	where a.batch_id = p_batch_id 
             and a.sub_orig_system_reference >= p_from_osr 
             and a.sub_orig_system_reference <= p_to_osr   
             and a.sub_orig_system = l_os; 
        END IF; 
 END get_contact_cur_int; 
 
 PROCEDURE pop_contacts_int ( 
    	 p_batch_id IN	NUMBER, 
      p_from_osr                       IN   VARCHAR2, 
   	 p_to_osr                         IN   VARCHAR2 
     ) IS  
  l_last_fetch BOOLEAN := FALSE; 
  l_contact_cur StageImpContactCurTyp; 
   
   BEGIN 
      get_contact_cur_int(p_batch_id, p_from_osr, p_to_osr, l_contact_cur ); 
    LOOP 
       FETCH l_contact_cur BULK COLLECT INTO 
       H_43E, H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_ROW_ID , H_CT_NAME 
       LIMIT g_limit; 
  
     IF l_contact_cur%NOTFOUND THEN     
       l_last_fetch:=TRUE; 
     END IF; 
     IF H_P_CONTACT_OS.COUNT=0 AND l_last_fetch THEN 
       EXIT; 
     END IF; 
     FOR I in H_P_CONTACT_OS.FIRST..H_P_CONTACT_OS.LAST LOOP 
        H_TX22(I) := HZ_TRANS_PKG.EXACT(H_43E(I), NULL, 'JOB_TITLE', 'CONTACTS');
        H_CT_CUST_TX23(I) := HZ_TRANS_PKG.BASIC_WRPERSON(H_CT_NAME(I), NULL, 'CONTACT_NAME', 'CONTACTS', 'SEARCH' );
        H_CT_CUST_TX2(I) := HZ_TRANS_PKG.EXACT_PADDED(H_CT_NAME(I), NULL, 'CONTACT_NAME', 'CONTACTS'); 
     END LOOP; 
     SAVEPOINT pop_contacts_int; 
     BEGIN      
       FORALL I in H_P_CONTACT_OS.FIRST..H_P_CONTACT_OS.LAST 
         INSERT INTO HZ_SRCH_CONTACTS ( 
          TX22, PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, BATCH_ID, INT_ROW_ID , TX2, TX23
         ) VALUES ( 
          H_TX22(I), H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), P_BATCH_ID, H_P_ROW_ID(I) , H_CT_CUST_TX2(I), H_CT_CUST_TX23(I)
             ); 
       EXCEPTION  
         WHEN OTHERS THEN 
           ROLLBACK to pop_contacts_int; 
           RAISE; 
       END; 
        
       IF l_last_fetch THEN 
         FND_CONCURRENT.AF_Commit; 
         EXIT; 
       END IF; 
       FND_CONCURRENT.AF_Commit; 
        
     END LOOP; 
     CLOSE l_contact_cur ; 
 	  END pop_contacts_int; 




---------------------------------------------------------------
-------------------- TCA JOIN BEGINS --------------------------
---------------------------------------------------------------
PROCEDURE tca_join_entities(trap_explosion in varchar2, rows_in_chunk in number, inserted_duplicates out number)
IS
    x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;
    x_insert_threshold number := 20;
    l_party_limit NUMBER := 50000;
    l_detail_limit NUMBER := 100000;
BEGIN
FND_FILE.put_line(FND_FILE.log,'Start time of insert of Parties '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_dup_results(fid, tid, ord_fid, ord_tid, score)
select f, t, least(f,t), greatest(f,t), sum(score) score  from (
select /*+ ORDERED */ s1.party_id f, s2.party_id t,
-------PARTY ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX2,s1.TX2),1,80,
decode(instrb(s2.TX59,s1.TX59),1,72,
0
)
)
 +  
decode(instrb(s2.TX41,s1.TX41),1,200,
0
)
 +  
decode(instrb(s2.TX45,s1.TX45),1,200,
0
)
 score 
from hz_dup_worker_chunk_gt p, HZ_STAGED_PARTIES s1, HZ_STAGED_PARTIES s2
where p.party_id = s1.party_id and s1.party_id<>s2.party_id 
and nvl(s1.status,'A') = 'A' and nvl(s2.status,'A') = 'A' 
and 1=decode(trap_explosion,'N',1,decode(rownum,l_party_limit,to_number('A'),1))
and (
-------PARTY ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX45 is not null and s2.TX45 like s1.TX45 || decode(sign(lengthb(s1.TX45)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX59 is not null and s2.TX59 like s1.TX59 || decode(sign(lengthb(s1.TX59)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX41 is not null and s2.TX41 like s1.TX41 || decode(sign(lengthb(s1.TX41)-3),1,'%',''))
)
)
union all
select f, t, max(score) score from (
select /*+ ORDERED */ s1.party_id f, s2.party_id t,
-------CONTACT_POINTS ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX5,s1.TX5),1,60,
0
)
 +  
decode(instrb(s2.TX7,s1.TX7),1,20,
0
)
 +  
decode(instrb(s2.TX10,s1.TX10),1,70,
decode(instrb(s2.TX158,s1.TX158),1,70,
0
)
)
 score 
from hz_dup_worker_chunk_gt p, HZ_STAGED_CONTACT_POINTS s1, HZ_STAGED_CONTACT_POINTS s2
where p.party_id = s1.party_id and s1.party_id<>s2.party_id 
and exists(SELECT 1 from hz_staged_parties q where q.party_id = s2.party_id and nvl(q.status,'A') = 'A') 
and 1=decode(trap_explosion,'N',1,decode(rownum,l_detail_limit,to_number('A'),1))
and (
-------CONTACT_POINTS ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX158 is not null and s2.TX158 like s1.TX158 || decode(sign(lengthb(s1.TX158)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX5 is not null and s2.TX5 like s1.TX5 || decode(sign(lengthb(s1.TX5)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX7 is not null and s2.TX7 like s1.TX7 || decode(sign(lengthb(s1.TX7)-3),1,'%',''))
)
)
 ) group by f, t 
 )
------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------
where EXISTS (
SELECT 1 FROM HZ_STAGED_PARTIES p1, HZ_STAGED_PARTIES p2
WHERE p1.party_id = f and p2.party_id = t
and
-- do an or between all the transformations of an attribute -- 
(
((p1.TX36 is null and p2.TX36 is null) or p2.TX36 = p1.TX36)
)
and
-- do an or between all the transformations of an attribute -- 
(
((p1.TX46 is null and p2.TX46 is null) or p2.TX46 = p1.TX46)
)
)
group by f, t 
having sum(score) >= x_insert_threshold
;
inserted_duplicates := (SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'Number of parties inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time of insert '||to_char(sysdate,'hh24:mi:ss'));
FND_CONCURRENT.AF_Commit;


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f, t, max(score) score from (
 select /*+ ORDERED */ s1.party_id f, s2.party_id t,
decode(instrb(s2.TX26,s1.TX26),1,100,
0
)
+
decode(instrb(s2.TX9,s1.TX9),1,15,
0
)
+
decode(instrb(s2.TX14,s1.TX14),1,5,
0
)
+
decode(instrb(s2.TX22,s1.TX22),1,5,
0
)
score
from hz_dup_worker_chunk_gt p, hz_dup_results h1, HZ_STAGED_PARTY_SITES s1, HZ_STAGED_PARTY_SITES s2
where p.party_id=h1.fid and s1.party_id = h1.fid and s2.party_id = h1.tid
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX26 is not null and s2.TX26 like s1.TX26 || decode(sign(lengthb(s1.TX26)-3),1,'%',''))
)
)
------------ FILTER ATTRIBUTES SECTION ------------------------
and 
-- do an or between all the transformations of an attribute -- 
(
((s1.TX11 is null and s2.TX11 is null) or s2.TX11 = s1.TX11)
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_dup_results(x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of PARTY_SITES');
FND_CONCURRENT.AF_Commit;


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f, t, max(score) score from (
 select /*+ ORDERED */ s1.party_id f, s2.party_id t,
decode(instrb(s2.TX2,s1.TX2),1,20,
decode(instrb(s2.TX23,s1.TX23),1,18,
0
)
)
+
decode(instrb(s2.TX22,s1.TX22),1,10,
0
)
score
from hz_dup_worker_chunk_gt p, hz_dup_results h1, HZ_STAGED_CONTACTS s1, HZ_STAGED_CONTACTS s2
where p.party_id=h1.fid and s1.party_id = h1.fid and s2.party_id = h1.tid
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX23 is not null and s2.TX23 like s1.TX23 || decode(sign(lengthb(s1.TX23)-3),1,'%',''))
)
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_dup_results(x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of CONTACTS');
FND_CONCURRENT.AF_Commit;


---------- exception block ---------------
EXCEPTION
WHEN OTHERS THEN
         IF sqlcode=-1722
         THEN
             inserted_duplicates := -1;
         ELSE
             FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
             FND_MESSAGE.SET_TOKEN('PROC','HZ_IMP_MATCH_RULE_52.tca_join_entities');
             FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
END tca_join_entities;




---------------------------------------------------------------
-------------------- INTERFACE TCA JOIN BEGINS --------------------------
---------------------------------------------------------------
PROCEDURE interface_tca_join_entities( p_batch_id in number, from_osr in varchar2, to_osr in varchar2,
                                  p_threshold in number, p_auto_merge_threshold in number)
IS
x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;
x_insert_threshold number := 20;
BEGIN
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'WU: '||from_osr||' to '||to_osr);
FND_FILE.put_line(FND_FILE.log,'Start time of insert of Parties '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_dup_parties(party_id,dup_party_id, score, party_osr, party_os, batch_id, auto_merge_flag
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select f, t, sum(score) sc, party_osr, party_os, p_batch_id, 'N' 
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from (
------------------ PARTY LEVEL DUPLICATE IDENTIFICATION BEGINS --------------------
select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,
-------PARTY ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX2,s1.TX2),1,80,
decode(instrb(s2.TX59,s1.TX59),1,72,
0
)
)
+
decode(instrb(s2.TX41,s1.TX41),1,200,
0
)
+
decode(instrb(s2.TX45,s1.TX45),1,200,
0
)
score , s1.party_osr party_osr, s1.party_os party_os
from HZ_SRCH_PARTIES s1, HZ_STAGED_PARTIES s2 
where s1.party_id is not null and s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr
and nvl(s2.status,'A') = 'A' 
and ( 
-------PARTY ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX45 is not null and s2.TX45 like s1.TX45 || decode(sign(lengthb(s1.TX45)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX59 is not null and s2.TX59 like s1.TX59 || decode(sign(lengthb(s1.TX59)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX41 is not null and s2.TX41 like s1.TX41 || decode(sign(lengthb(s1.TX41)-3),1,'%',''))
)
)
union all
select f, t, max(score) score, party_osr, party_os from (
select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,
-------CONTACT_POINTS ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX5,s1.TX5),1,60,
0
)
+
decode(instrb(s2.TX7,s1.TX7),1,20,
0
)
+
decode(instrb(s2.TX10,s1.TX10),1,70,
decode(instrb(s2.TX158,s1.TX158),1,70,
0
)
)
score , s1.party_osr party_osr, s1.party_os party_os
from HZ_SRCH_CPTS s1, HZ_STAGED_CONTACT_POINTS s2
where s1.party_id is not null and s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = 'I'
and exists(SELECT 1 from hz_staged_parties q where q.party_id = s2.party_id and nvl(q.status,'A') = 'A') 
and ( 
-------CONTACT_POINTS ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX158 is not null and s2.TX158 like s1.TX158 || decode(sign(lengthb(s1.TX158)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX5 is not null and s2.TX5 like s1.TX5 || decode(sign(lengthb(s1.TX5)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX7 is not null and s2.TX7 like s1.TX7 || decode(sign(lengthb(s1.TX7)-3),1,'%',''))
)
)
)
group by f, t, party_osr, party_os
)
------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------
where EXISTS (
SELECT 1 FROM HZ_SRCH_PARTIES p1, HZ_STAGED_PARTIES p2
WHERE p1.batch_id = p_batch_id and p1.party_osr = party_osr and p1.party_os = party_os
and p2.party_id = t
and
-- do an or between all the transformations of an attribute -- 
(
((p1.TX36 is null and p2.TX36 is null) or p2.TX36 = p1.TX36 || ' ' )
)
)
group by f, t, party_osr, party_os
having sum(score) >= x_insert_threshold
;
FND_FILE.put_line(FND_FILE.log,'Number of parties inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time of insert '||to_char(sysdate,'hh24:mi:ss'));


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f,t,max(score) from (
 select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,
decode(instrb(s2.TX26,s1.TX26),1,100,
0
)
+
decode(instrb(s2.TX9,s1.TX9),1,15,
0
)
+
decode(instrb(s2.TX14,s1.TX14),1,5,
0
)
+
decode(instrb(s2.TX22,s1.TX22),1,5,
0
)
score
from hz_imp_dup_parties h1, HZ_SRCH_PSITES s1, HZ_STAGED_PARTY_SITES s2
where h1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr
and s1.batch_id = h1.batch_id and s1.party_osr = h1.party_osr and s1.party_os = h1.party_os and s2.party_id = h1.dup_party_id
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX26 is not null and s2.TX26 like s1.TX26 || decode(sign(lengthb(s1.TX26)-3),1,'%',''))
)
)
------------ FILTER ATTRIBUTES SECTION ------------------------
and 
-- do an or between all the transformations of an attribute -- 
(
((s1.TX11 is null and s2.TX11 is null) or s2.TX11 = s1.TX11 || ' ' )
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_imp_dup_parties(p_batch_id, x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of PARTY_SITES');


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f,t,max(score) from (
 select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,
decode(instrb(s2.TX2,s1.TX2),1,20,
decode(instrb(s2.TX23,s1.TX23),1,18,
0
)
)
+
decode(instrb(s2.TX22,s1.TX22),1,10,
0
)
score
from hz_imp_dup_parties h1, HZ_SRCH_CONTACTS s1, HZ_STAGED_CONTACTS s2
where h1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr
and s1.batch_id = h1.batch_id and s1.party_osr = h1.party_osr and s1.party_os = h1.party_os and s2.party_id = h1.dup_party_id
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX23 is not null and s2.TX23 like s1.TX23 || decode(sign(lengthb(s1.TX23)-3),1,'%',''))
)
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_imp_dup_parties(p_batch_id, x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of CONTACTS');

--------DELETE ON THRESHOLD AND REMOVE INDIRECT TRANSITIVITY ---------------------

FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'DELETE ON THRESHOLD AND INDIRECT TRANSITIVITY ');
FND_FILE.put_line(FND_FILE.log,'Begin time to delete '||to_char(sysdate,'hh24:mi:ss'));

delete from hz_imp_dup_parties a
where (a.party_osr >= from_osr and a.party_osr <= to_osr
and a.batch_id = p_batch_id)
and (
a.score < p_threshold
or
-- delete the party id whose duplicate is a bigger number, when scores are same
exists
      (Select 1 from hz_imp_dup_parties b
       where b.batch_id=p_batch_id and a.party_id=b.party_id and a.dup_party_id > b.dup_party_id and a.score = b.score)
or
-- delete the party id with least score, if scores are different
exists
      (Select 1 from hz_imp_dup_parties b
       where b.batch_id=p_batch_id and a.party_id=b.party_id and a.score < b.score)
);

FND_FILE.put_line(FND_FILE.log,'Number of records deleted from hz_imp_dup_parties '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to delete '||to_char(sysdate,'hh24:mi:ss'));
--------UPDATE AUTO MERGE FLAG --------------
update hz_imp_dup_parties a
set a.auto_merge_flag = 'Y'
where a.score >= p_auto_merge_threshold
and a.party_osr >= from_osr and a.party_osr <= to_osr
and a.batch_id = p_batch_id ;
--------UPDATE DQM ACTION FLAG IN INTERFACE/STAGING TABLES --------------

open x_ent_cur for
select a.party_osr, a.party_os, a.auto_merge_flag
from hz_imp_dup_parties a
where a.batch_id = p_batch_id
and a.party_osr between from_osr and to_osr ;
HZ_DQM_DUP_ID_PKG.update_party_dqm_action_flag(p_batch_id, x_ent_cur);
----------------------PARTY LEVEL DUPLICATE IDENTIFICATION ENDS --------------------


-------------CONTACT_POINTS LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of CONTACT_POINTS');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_dup_details(party_id, score, party_osr, party_os, batch_id, entity, record_id, record_osr, record_os, dup_record_id
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ s1.party_id f,
decode(instrb(s2.TX5,s1.TX5),1,60,
0
)
+
decode(instrb(s2.TX7,s1.TX7),1,20,
0
)
+
decode(instrb(s2.TX10,s1.TX10),1,70,
decode(instrb(s2.TX158,s1.TX158),1,70,
0
)
)
score , s1.party_osr, s1.party_os, p_batch_id,'CONTACT_POINTS', s1.CONTACT_POINT_ID, s1.CONTACT_PT_OSR, s1.CONTACT_PT_OS,
                                                                      s2.CONTACT_POINT_ID
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_CPTS s1, HZ_STAGED_CONTACT_POINTS s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = 'U'
and s1.party_id = s2.party_id
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX158 is not null and s2.TX158 like s1.TX158 || decode(sign(lengthb(s1.TX158)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX5 is not null and s2.TX5 like s1.TX5 || decode(sign(lengthb(s1.TX5)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX7 is not null and s2.TX7 like s1.TX7 || decode(sign(lengthb(s1.TX7)-3),1,'%',''))
)
)
;


--------UPDATE DQM ACTION FLAG IN CONTACT_POINTS INTERFACE/STAGING TABLES --------------
open x_ent_cur for
select distinct a.record_osr, a.record_os
from hz_imp_dup_details a
where a.batch_id = p_batch_id
and a.party_osr between from_osr and to_osr and a.entity ='CONTACT_POINTS';
HZ_DQM_DUP_ID_PKG.update_detail_dqm_action_flag('CONTACT_POINTS',p_batch_id, x_ent_cur);
-------------CONTACT_POINTS LEVEL DUPLICATE IDENTIFICATION ENDS ------------------------
FND_FILE.put_line(FND_FILE.log,'Ending insert of CONTACT_POINTS');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));



-------------PARTY_SITES LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_dup_details(party_id, score, party_osr, party_os, batch_id, entity, record_id, record_osr, record_os, dup_record_id
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ s1.party_id f,
decode(instrb(s2.TX26,s1.TX26),1,100,
0
)
+
decode(instrb(s2.TX9,s1.TX9),1,15,
0
)
+
decode(instrb(s2.TX14,s1.TX14),1,5,
0
)
+
decode(instrb(s2.TX22,s1.TX22),1,5,
0
)
score , s1.party_osr, s1.party_os, p_batch_id,'PARTY_SITES', s1.PARTY_SITE_ID, s1.PARTY_SITE_OSR, s1.PARTY_SITE_OS,
                                                                      s2.PARTY_SITE_ID
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_PSITES s1, HZ_STAGED_PARTY_SITES s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = 'U'
and s1.party_id = s2.party_id
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX26 is not null and s2.TX26 like s1.TX26 || decode(sign(lengthb(s1.TX26)-3),1,'%',''))
)
)
------------ FILTER ATTRIBUTES SECTION ------------------------
and 
-- do an or between all the transformations of an attribute -- 
(
((s1.TX11 is null and s2.TX11 is null) or s2.TX11 = s1.TX11 || ' ' )
)
;


--------UPDATE DQM ACTION FLAG IN PARTY_SITES INTERFACE/STAGING TABLES --------------
open x_ent_cur for
select distinct a.record_osr, a.record_os
from hz_imp_dup_details a
where a.batch_id = p_batch_id
and a.party_osr between from_osr and to_osr and a.entity ='PARTY_SITES';
HZ_DQM_DUP_ID_PKG.update_detail_dqm_action_flag('PARTY_SITES',p_batch_id, x_ent_cur);
-------------PARTY_SITES LEVEL DUPLICATE IDENTIFICATION ENDS ------------------------
FND_FILE.put_line(FND_FILE.log,'Ending insert of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));



-------------CONTACTS LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_dup_details(party_id, score, party_osr, party_os, batch_id, entity, record_id, record_osr, record_os, dup_record_id
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ s1.party_id f,
decode(instrb(s2.TX2,s1.TX2),1,20,
decode(instrb(s2.TX23,s1.TX23),1,18,
0
)
)
+
decode(instrb(s2.TX22,s1.TX22),1,10,
0
)
score , s1.party_osr, s1.party_os, p_batch_id,'CONTACTS', s1.ORG_CONTACT_ID, s1.CONTACT_OSR, s1.CONTACT_OS,
                                                                      s2.ORG_CONTACT_ID
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_CONTACTS s1, HZ_STAGED_CONTACTS s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = 'U'
and s1.party_id = s2.party_id
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX23 is not null and s2.TX23 like s1.TX23 || decode(sign(lengthb(s1.TX23)-3),1,'%',''))
)
)
;


--------UPDATE DQM ACTION FLAG IN CONTACTS INTERFACE/STAGING TABLES --------------
open x_ent_cur for
select distinct a.record_osr, a.record_os
from hz_imp_dup_details a
where a.batch_id = p_batch_id
and a.party_osr between from_osr and to_osr and a.entity ='CONTACTS';
HZ_DQM_DUP_ID_PKG.update_detail_dqm_action_flag('CONTACTS',p_batch_id, x_ent_cur);
-------------CONTACTS LEVEL DUPLICATE IDENTIFICATION ENDS ------------------------
FND_FILE.put_line(FND_FILE.log,'Ending insert of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));



---------- exception block ---------------
EXCEPTION
WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','HZ_IMP_MATCH_RULE_52.interface_tca_join_entities');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END interface_tca_join_entities;




---------------------------------------------------------------
-------------------- INTERFACE JOIN BEGINS --------------------------
---------------------------------------------------------------
PROCEDURE interface_join_entities(p_batch_id in number,
          from_osr in varchar2, to_osr in varchar2, p_threshold in number)
IS
x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;
    x_insert_threshold number := 20;
BEGIN
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'WU: '||from_osr||' to '||to_osr);
FND_FILE.put_line(FND_FILE.log,'Start time of insert of Parties '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_int_dup_results(batch_id, f_osr,t_osr,ord_f_osr,ord_t_osr,score,f_os, t_os)
select p_batch_id, f, t, least(f,t), greatest(f,t), sum(score) score, fos, tos from (
------------------ PARTY LEVEL DUPLICATE IDENTIFICATION BEGINS --------------------
select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,
-------PARTY ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX2,s1.TX2),1,80,
decode(instrb(s2.TX59,s1.TX59),1,72,
0
)
)
+
decode(instrb(s2.TX41,s1.TX41),1,200,
0
)
+
decode(instrb(s2.TX45,s1.TX45),1,200,
0
)
score, s1.party_os fos, s2.party_os tos
from HZ_SRCH_PARTIES s1, HZ_SRCH_PARTIES s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.party_osr <> s2.party_osr
and s2.batch_id = p_batch_id and not exists (select 1 from HZ_INT_DUP_RESULTS WHERE t_osr = s1.party_osr and batch_id = p_batch_id)
and (
-------PARTY ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX45 is not null and s2.TX45 like s1.TX45 || decode(sign(lengthb(s1.TX45)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX59 is not null and s2.TX59 like s1.TX59 || decode(sign(lengthb(s1.TX59)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX41 is not null and s2.TX41 like s1.TX41 || decode(sign(lengthb(s1.TX41)-3),1,'%',''))
)
)
union all
select f, t, max(score) score, fos, tos from (
select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,
-------CONTACT_POINTS ENTITY: SCORING SECTION ---------
decode(instrb(s2.TX5,s1.TX5),1,60,
0
)
+
decode(instrb(s2.TX7,s1.TX7),1,20,
0
)
+
decode(instrb(s2.TX10,s1.TX10),1,70,
decode(instrb(s2.TX158,s1.TX158),1,70,
0
)
)
score, s1.party_os fos, s2.party_os tos
from HZ_SRCH_CPTS s1, HZ_SRCH_CPTS s2
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.party_osr <> s2.party_osr
and s2.batch_id = p_batch_id and not exists (select 1 from HZ_INT_DUP_RESULTS WHERE t_osr = s1.party_osr and batch_id = p_batch_id)
and s1.contact_point_type = s2.contact_point_type
and (
-------CONTACT_POINTS ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX158 is not null and s2.TX158 like s1.TX158 || decode(sign(lengthb(s1.TX158)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX5 is not null and s2.TX5 like s1.TX5 || decode(sign(lengthb(s1.TX5)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX7 is not null and s2.TX7 like s1.TX7 || decode(sign(lengthb(s1.TX7)-3),1,'%',''))
)
)
)
group by f, t, fos, tos
)
------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------
where EXISTS (
SELECT 1 FROM HZ_SRCH_PARTIES p1, HZ_SRCH_PARTIES p2
WHERE p1.batch_id = p_batch_id and p1.party_osr = f and p1.party_os = fos
and p2.batch_id = p_batch_id and p2.party_osr = t and p2.party_os = tos
and
-- do an or between all the transformations of an attribute -- 
(
((p1.TX36 is null and p2.TX36 is null) or p2.TX36 = p1.TX36)
)
)
group by f, t, fos, tos
having sum(score) >= x_insert_threshold
;
FND_FILE.put_line(FND_FILE.log,'Number of parties inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time of insert '||to_char(sysdate,'hh24:mi:ss'));
FND_CONCURRENT.AF_Commit;


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f,t,max(score) from (
 select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,
decode(instrb(s2.TX26,s1.TX26),1,100,
0
)
+
decode(instrb(s2.TX9,s1.TX9),1,15,
0
)
+
decode(instrb(s2.TX14,s1.TX14),1,5,
0
)
+
decode(instrb(s2.TX22,s1.TX22),1,5,
0
)
score
from hz_int_dup_results h1, HZ_SRCH_PSITES s1, HZ_SRCH_PSITES s2
where
s1.party_osr = h1.f_osr and s2.party_osr = h1.t_osr and h1.batch_id = p_batch_id
and s1.party_osr between from_osr and to_osr
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX26 is not null and s2.TX26 like s1.TX26 || decode(sign(lengthb(s1.TX26)-3),1,'%',''))
)
)
------------ FILTER ATTRIBUTES SECTION ------------------------
and 
-- do an or between all the transformations of an attribute -- 
(
((s1.TX11 is null and s2.TX11 is null) or s2.TX11 = s1.TX11)
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_int_dup_results(p_batch_id,x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of PARTY_SITES');
FND_CONCURRENT.AF_Commit;


FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning update of Parties on the basis of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Start time of update '||to_char(sysdate,'hh24:mi:ss'));
open x_ent_cur for
select f,t,max(score) from (
 select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,
decode(instrb(s2.TX2,s1.TX2),1,20,
decode(instrb(s2.TX23,s1.TX23),1,18,
0
)
)
+
decode(instrb(s2.TX22,s1.TX22),1,10,
0
)
score
from hz_int_dup_results h1, HZ_SRCH_CONTACTS s1, HZ_SRCH_CONTACTS s2
where
s1.party_osr = h1.f_osr and s2.party_osr = h1.t_osr and h1.batch_id = p_batch_id
and s1.party_osr between from_osr and to_osr
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX23 is not null and s2.TX23 like s1.TX23 || decode(sign(lengthb(s1.TX23)-3),1,'%',''))
)
)
) group by f,t ;
HZ_DQM_DUP_ID_PKG.update_hz_int_dup_results(p_batch_id,x_ent_cur);
close x_ent_cur;
FND_FILE.put_line(FND_FILE.log,'Number of parties updated '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to update '||to_char(sysdate,'hh24:mi:ss'));
FND_FILE.put_line(FND_FILE.log,'Ending update of Parties on the basis of CONTACTS');
FND_CONCURRENT.AF_Commit;
-------------CONTACT_POINTS LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of CONTACT_POINTS');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_int_dedup_results(batch_id, winner_record_osr, winner_record_os,
dup_record_osr, dup_record_os, detail_party_osr, detail_party_os, entity, score,
dup_creation_date,dup_last_update_date
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ p_batch_id, s1.CONTACT_PT_OSR, s1.CONTACT_PT_OS,
s2.CONTACT_PT_OSR, s2.CONTACT_PT_OS,
s1.party_osr, s2.party_os,'CONTACT_POINTS',
decode(nvl(s1.TX5,'N1'),nvl(substrb(s2.TX5,1,length(s1.TX5)),'N2'),60, 
0
)
+
decode(nvl(s1.TX7,'N1'),nvl(substrb(s2.TX7,1,length(s1.TX7)),'N2'),20, 
0
)
+
decode(nvl(s1.TX10,'N1'),nvl(substrb(s2.TX10,1,length(s1.TX10)),'N2'),70, 
decode(nvl(s1.TX158,'N1'),nvl(substrb(s2.TX158,1,length(s1.TX158)),'N2'),70, 
0
)
)
score ,hz_utility_v2pub.creation_date, hz_utility_v2pub.last_update_date
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_CPTS s1, HZ_SRCH_CPTS s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr 
 and ( ( (s1.party_osr = s2.party_osr) and ( nvl(s1.party_id, 1) = nvl(s2.party_id,1) ) ) OR ( s1.party_id = s2.party_id) ) 
and s2.batch_id = p_batch_id and s1.CONTACT_PT_OSR < s2.CONTACT_PT_OSR
and s1.contact_point_type = s2.contact_point_type
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX158 is not null and s2.TX158 like s1.TX158 || decode(sign(lengthb(s1.TX158)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX5 is not null and s2.TX5 like s1.TX5 || decode(sign(lengthb(s1.TX5)-3),1,'%',''))
)
or
-- do an or between all the transformations of an attribute -- 
(
(s1.TX7 is not null and s2.TX7 like s1.TX7 || decode(sign(lengthb(s1.TX7)-3),1,'%',''))
)
)
;
FND_FILE.put_line(FND_FILE.log,'Ending insert of CONTACT_POINTS');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));
FND_CONCURRENT.AF_Commit;
-------------PARTY_SITES LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_int_dedup_results(batch_id, winner_record_osr, winner_record_os,
dup_record_osr, dup_record_os, detail_party_osr, detail_party_os, entity, score,
dup_creation_date,dup_last_update_date
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ p_batch_id, s1.PARTY_SITE_OSR, s1.PARTY_SITE_OS,
s2.PARTY_SITE_OSR, s2.PARTY_SITE_OS,
s1.party_osr, s2.party_os,'PARTY_SITES',
decode(nvl(s1.TX26,'N1'),nvl(substrb(s2.TX26,1,length(s1.TX26)),'N2'),100, 
0
)
+
decode(nvl(s1.TX9,'N1'),nvl(substrb(s2.TX9,1,length(s1.TX9)),'N2'),15, 
0
)
+
decode(nvl(s1.TX14,'N1'),nvl(substrb(s2.TX14,1,length(s1.TX14)),'N2'),5, 
0
)
+
decode(nvl(s1.TX22,'N1'),nvl(substrb(s2.TX22,1,length(s1.TX22)),'N2'),5, 
0
)
score ,hz_utility_v2pub.creation_date, hz_utility_v2pub.last_update_date
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_PSITES s1, HZ_SRCH_PSITES s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr 
 and ( ( (s1.party_osr = s2.party_osr) and ( nvl(s1.party_id, 1) = nvl(s2.party_id,1) ) ) OR ( s1.party_id = s2.party_id) ) 
and s2.batch_id = p_batch_id and s1.PARTY_SITE_OSR < s2.PARTY_SITE_OSR
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX26 is not null and s2.TX26 like s1.TX26 || decode(sign(lengthb(s1.TX26)-3),1,'%',''))
)
)
------------ FILTER ATTRIBUTES SECTION ------------------------
and 
-- do an or between all the transformations of an attribute -- 
(
((s1.TX11 is null and s2.TX11 is null) or s2.TX11 = s1.TX11)
)
;
FND_FILE.put_line(FND_FILE.log,'Ending insert of PARTY_SITES');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));
FND_CONCURRENT.AF_Commit;
-------------CONTACTS LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------
FND_FILE.put_line(FND_FILE.log,'------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Beginning insert  of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Start time of insert '||to_char(sysdate,'hh24:mi:ss'));
insert into hz_imp_int_dedup_results(batch_id, winner_record_osr, winner_record_os,
dup_record_osr, dup_record_os, detail_party_osr, detail_party_os, entity, score,
dup_creation_date,dup_last_update_date
,created_by,creation_date,last_update_login,last_update_date,last_updated_by)
select /*+ USE_CONCAT */ p_batch_id, s1.CONTACT_OSR, s1.CONTACT_OS,
s2.CONTACT_OSR, s2.CONTACT_OS,
s1.party_osr, s2.party_os,'CONTACTS',
decode(nvl(s1.TX2,'N1'),nvl(substrb(s2.TX2,1,length(s1.TX2)),'N2'),20, 
decode(nvl(s1.TX23,'N1'),nvl(substrb(s2.TX23,1,length(s1.TX23)),'N2'),18, 
0
)
)
+
decode(nvl(s1.TX22,'N1'),nvl(substrb(s2.TX22,1,length(s1.TX22)),'N2'),10, 
0
)
score ,hz_utility_v2pub.creation_date, hz_utility_v2pub.last_update_date
,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login
,hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by
from HZ_SRCH_CONTACTS s1, HZ_SRCH_CONTACTS s2 
where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr 
 and ( ( (s1.party_osr = s2.party_osr) and ( nvl(s1.party_id, 1) = nvl(s2.party_id,1) ) ) OR ( s1.party_id = s2.party_id) ) 
and s2.batch_id = p_batch_id and s1.CONTACT_OSR < s2.CONTACT_OSR
and ( 
------------ NON FILTER ATTRIBUTES SECTION ------------------------
-- do an or between all the transformations of an attribute -- 
(
(s1.TX23 is not null and s2.TX23 like s1.TX23 || decode(sign(lengthb(s1.TX23)-3),1,'%',''))
)
)
;
FND_FILE.put_line(FND_FILE.log,'Ending insert of CONTACTS');
FND_FILE.put_line(FND_FILE.log,'Number of records inserted '||SQL%ROWCOUNT);
FND_FILE.put_line(FND_FILE.log,'End time to insert '||to_char(sysdate,'hh24:mi:ss'));
FND_CONCURRENT.AF_Commit;

---------- exception block ---------------
EXCEPTION
WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','HZ_IMP_MATCH_RULE_52.interface_join_entities');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END interface_join_entities;
END;

/
