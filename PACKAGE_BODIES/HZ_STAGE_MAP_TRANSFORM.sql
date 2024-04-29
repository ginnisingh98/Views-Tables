--------------------------------------------------------
--  DDL for Package Body HZ_STAGE_MAP_TRANSFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STAGE_MAP_TRANSFORM" AS
  TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE Char1List IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE Char2List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE CharList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE RowIdList IS TABLE OF ROWID INDEX BY BINARY_INTEGER; 
  
  H_ROWID RowIdList;
  H_P_PARTY_ID NumberList;
  H_PS_DEN CharList;
  H_CT_DEN CharList;
  H_CPT_DEN CharList;
  H_PARTY_INDEX NumberList;
  H_PARTY_ID NumberList;
  H_C_PARTY_ID NumberList;
  H_PS_PARTY_ID NumberList;
  H_CPT_PARTY_ID NumberList;
  H_R_PARTY_ID NumberList;
  H_STATUS Char1List;
  H_PARTY_SITE_ID NumberList;
  H_CPT_PARTY_SITE_ID NumberList;
  H_ORG_CONTACT_ID NumberList;
  H_PS_ORG_CONTACT_ID NumberList;
  H_CPT_ORG_CONTACT_ID NumberList;
  H_CONTACT_POINT_ID NumberList;
  H_CONTACT_POINT_TYPE Char2List;
  H_TX1 CharList;
  H_TX2 CharList;
  H_TX3 CharList;
  H_TX4 CharList;
  H_TX5 CharList;
  H_TX6 CharList;
  H_TX7 CharList;
  H_TX8 CharList;
  H_TX9 CharList;
  H_TX10 CharList;
  H_TX11 CharList;
  H_TX12 CharList;
  H_TX13 CharList;
  H_TX14 CharList;
  H_TX15 CharList;
  H_TX16 CharList;
  H_TX17 CharList;
  H_TX18 CharList;
  H_TX19 CharList;
  H_TX20 CharList;
  H_TX21 CharList;
  H_TX22 CharList;
  H_TX23 CharList;
  H_TX24 CharList;
  H_TX25 CharList;
  H_TX26 CharList;
  H_TX27 CharList;
  H_TX28 CharList;
  H_TX29 CharList;
  H_TX30 CharList;
  H_TX31 CharList;
  H_TX32 CharList;
  H_TX33 CharList;
  H_TX34 CharList;
  H_TX35 CharList;
  H_TX36 CharList;
  H_TX37 CharList;
  H_TX38 CharList;
  H_TX39 CharList;
  H_TX40 CharList;
  H_TX41 CharList;
  H_TX42 CharList;
  H_TX43 CharList;
  H_TX44 CharList;
  H_TX45 CharList;
  H_TX46 CharList;
  H_TX47 CharList;
  H_TX48 CharList;
  H_TX49 CharList;
  H_TX50 CharList;
  H_TX51 CharList;
  H_TX52 CharList;
  H_TX53 CharList;
  H_TX54 CharList;
  H_TX55 CharList;
  H_TX56 CharList;
  H_TX57 CharList;
  H_TX58 CharList;
  H_TX59 CharList;
  H_TX60 CharList;
  H_TX61 CharList;
  H_TX62 CharList;
  H_TX63 CharList;
  H_TX64 CharList;
  H_TX65 CharList;
  H_TX66 CharList;
  H_TX67 CharList;
  H_TX68 CharList;
  H_TX69 CharList;
  H_TX70 CharList;
  H_TX71 CharList;
  H_TX72 CharList;
  H_TX73 CharList;
  H_TX74 CharList;
  H_TX75 CharList;
  H_TX76 CharList;
  H_TX77 CharList;
  H_TX78 CharList;
  H_TX79 CharList;
  H_TX80 CharList;
  H_TX81 CharList;
  H_TX82 CharList;
  H_TX83 CharList;
  H_TX84 CharList;
  H_TX85 CharList;
  H_TX86 CharList;
  H_TX87 CharList;
  H_TX88 CharList;
  H_TX89 CharList;
  H_TX90 CharList;
  H_TX91 CharList;
  H_TX92 CharList;
  H_TX93 CharList;
  H_TX94 CharList;
  H_TX95 CharList;
  H_TX96 CharList;
  H_TX97 CharList;
  H_TX98 CharList;
  H_TX99 CharList;
  H_TX100 CharList;
  H_TX101 CharList;
  H_TX102 CharList;
  H_TX103 CharList;
  H_TX104 CharList;
  H_TX105 CharList;
  H_TX106 CharList;
  H_TX107 CharList;
  H_TX108 CharList;
  H_TX109 CharList;
  H_TX110 CharList;
  H_TX111 CharList;
  H_TX112 CharList;
  H_TX113 CharList;
  H_TX114 CharList;
  H_TX115 CharList;
  H_TX116 CharList;
  H_TX117 CharList;
  H_TX118 CharList;
  H_TX119 CharList;
  H_TX120 CharList;
  H_TX121 CharList;
  H_TX122 CharList;
  H_TX123 CharList;
  H_TX124 CharList;
  H_TX125 CharList;
  H_TX126 CharList;
  H_TX127 CharList;
  H_TX128 CharList;
  H_TX129 CharList;
  H_TX130 CharList;
  H_TX131 CharList;
  H_TX132 CharList;
  H_TX133 CharList;
  H_TX134 CharList;
  H_TX135 CharList;
  H_TX136 CharList;
  H_TX137 CharList;
  H_TX138 CharList;
  H_TX139 CharList;
  H_TX140 CharList;
  H_TX141 CharList;
  H_TX142 CharList;
  H_TX143 CharList;
  H_TX144 CharList;
  H_TX145 CharList;
  H_TX146 CharList;
  H_TX147 CharList;
  H_TX148 CharList;
  H_TX149 CharList;
  H_TX150 CharList;
  H_TX151 CharList;
  H_TX152 CharList;
  H_TX153 CharList;
  H_TX154 CharList;
  H_TX155 CharList;
  H_TX156 CharList;
  H_TX157 CharList;
  H_TX158 CharList;
  H_TX159 CharList;
  H_TX160 CharList;
  H_TX161 CharList;
  H_TX162 CharList;
  H_TX163 CharList;
  H_TX164 CharList;
  H_TX165 CharList;
  H_TX166 CharList;
  H_TX167 CharList;
  H_TX168 CharList;
  H_TX169 CharList;
  H_TX170 CharList;
  H_TX171 CharList;
  H_TX172 CharList;
  H_TX173 CharList;
  H_TX174 CharList;
  H_TX175 CharList;
  H_TX176 CharList;
  H_TX177 CharList;
  H_TX178 CharList;
  H_TX179 CharList;
  H_TX180 CharList;
  H_TX181 CharList;
  H_TX182 CharList;
  H_TX183 CharList;
  H_TX184 CharList;
  H_TX185 CharList;
  H_TX186 CharList;
  H_TX187 CharList;
  H_TX188 CharList;
  H_TX189 CharList;
  H_TX190 CharList;
  H_TX191 CharList;
  H_TX192 CharList;
  H_TX193 CharList;
  H_TX194 CharList;
  H_TX195 CharList;
  H_TX196 CharList;
  H_TX197 CharList;
  H_TX198 CharList;
  H_TX199 CharList;
  H_TX200 CharList;
  H_TX201 CharList;
  H_TX202 CharList;
  H_TX203 CharList;
  H_TX204 CharList;
  H_TX205 CharList;
  H_TX206 CharList;
  H_TX207 CharList;
  H_TX208 CharList;
  H_TX209 CharList;
  H_TX210 CharList;
  H_TX211 CharList;
  H_TX212 CharList;
  H_TX213 CharList;
  H_TX214 CharList;
  H_TX215 CharList;
  H_TX216 CharList;
  H_TX217 CharList;
  H_TX218 CharList;
  H_TX219 CharList;
  H_TX220 CharList;
  H_TX221 CharList;
  H_TX222 CharList;
  H_TX223 CharList;
  H_TX224 CharList;
  H_TX225 CharList;
  H_TX226 CharList;
  H_TX227 CharList;
  H_TX228 CharList;
  H_TX229 CharList;
  H_TX230 CharList;
  H_TX231 CharList;
  H_TX232 CharList;
  H_TX233 CharList;
  H_TX234 CharList;
  H_TX235 CharList;
  H_TX236 CharList;
  H_TX237 CharList;
  H_TX238 CharList;
  H_TX239 CharList;
  H_TX240 CharList;
  H_TX241 CharList;
  H_TX242 CharList;
  H_TX243 CharList;
  H_TX244 CharList;
  H_TX245 CharList;
  H_TX246 CharList;
  H_TX247 CharList;
  H_TX248 CharList;
  H_TX249 CharList;
  H_TX250 CharList;
  H_TX251 CharList;
  H_TX252 CharList;
  H_TX253 CharList;
  H_TX254 CharList;
  H_TX255 CharList;
  FUNCTION miscp (rid IN ROWID) RETURN CLOB IS
  BEGIN
    RETURN NULL;
  END;
  FUNCTION miscps (rid IN ROWID) RETURN CLOB IS
  BEGIN
    RETURN NULL;
  END;
  FUNCTION miscct (rid IN ROWID) RETURN CLOB IS
  BEGIN
    RETURN NULL;
  END;
  FUNCTION misccpt (rid IN ROWID) RETURN CLOB IS
  BEGIN
    RETURN NULL;
  END;
  FUNCTION den_ps (party_id NUMBER) RETURN VARCHAR2 IS
   CURSOR party_site_denorm (cp_party_id NUMBER) IS
    SELECT distinct
      TX9||' '||
      TX10||' '||
      TX11||' '||
      TX12||' '||
      TX13||' '||
      TX14||' '||
      TX15||' '||
      TX20||' '||
      TX21||' '||
      TX22||' '||
        ' '
    FROM APPS.HZ_STAGED_PARTY_SITES
    WHERE party_id = cp_party_id;
    l_buffer VARCHAR2(4000);
    l_den_ps VARCHAR2(2000);
  BEGIN
     OPEN party_site_denorm(party_id);
     LOOP
       FETCH party_site_denorm INTO l_den_ps;
       EXIT WHEN party_site_denorm%NOTFOUND;
       l_buffer := l_buffer||' '||l_den_ps;
     END LOOP;
     CLOSE party_site_denorm;
     RETURN l_buffer;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_buffer;
  END;
  FUNCTION den_ct (party_id NUMBER) RETURN VARCHAR2 IS
   CURSOR contact_denorm (cp_party_id NUMBER) IS
    SELECT distinct
      TX22||' '||
        ' '
    FROM APPS.HZ_STAGED_CONTACTS
    WHERE party_id = cp_party_id;
    l_buffer VARCHAR2(4000);
    l_den_ct VARCHAR2(2000);
  BEGIN
     OPEN contact_denorm(party_id);
     LOOP
       FETCH contact_denorm INTO l_den_ct;
       EXIT WHEN contact_denorm%NOTFOUND;
       l_buffer := l_buffer||' '||l_den_ct;
     END LOOP;
     CLOSE contact_denorm;
     RETURN l_buffer;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_buffer;
  END;
  FUNCTION den_cpt (party_id NUMBER) RETURN VARCHAR2 IS
   CURSOR contact_pt_denorm (cp_party_id NUMBER) IS
    SELECT distinct
      TX3||' '||
      TX4||' '||
        ' '
    FROM APPS.HZ_STAGED_CONTACT_POINTS
    WHERE party_id = cp_party_id;
    l_buffer VARCHAR2(4000);
    l_den_cpt VARCHAR2(2000);
  BEGIN
     OPEN contact_pt_denorm(party_id);
     LOOP
       FETCH contact_pt_denorm INTO l_den_cpt;
       EXIT WHEN contact_pt_denorm%NOTFOUND;
       l_buffer := l_buffer||' '||l_den_cpt;
     END LOOP;
     CLOSE contact_pt_denorm;
     RETURN l_buffer;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_buffer;
  END;

    FUNCTION den_acc_number (party_id NUMBER) RETURN VARCHAR2 IS
    CURSOR all_account_number (p_party_id NUMBER) IS
    SELECT ACCOUNT_NUMBER
    FROM  APPS.hz_cust_accounts
    WHERE PARTY_ID = p_party_id
    ORDER BY STATUS,CREATION_DATE;
  
    l_acct_number VARCHAR2(30);
    l_buffer VARCHAR2(4000);
    
    BEGIN
       OPEN all_account_number(party_id);
       LOOP
         FETCH all_account_number INTO l_acct_number;
         EXIT WHEN all_account_number%NOTFOUND;
         l_buffer := l_buffer||' '||l_acct_number;
       END LOOP;
       CLOSE all_account_number;
       RETURN l_buffer;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN l_buffer;
    END;


  PROCEDURE log( 
    message      IN      VARCHAR2, 
    newline      IN      BOOLEAN DEFAULT TRUE) IS 
  BEGIN 
    IF message = 'NEWLINE' THEN 
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1); 
    ELSIF (newline) THEN 
      FND_FILE.put_line(fnd_file.log,message); 
    ELSE 
      FND_FILE.put(fnd_file.log,message); 
    END IF; 
  END log; 


  PROCEDURE insert_dqm_sync_error_rec ( 
    p_party_id            IN   NUMBER, 
    p_record_id           IN   NUMBER, 
    p_party_site_id       IN   NUMBER, 
    p_org_contact_id      IN   NUMBER, 
    p_entity              IN   VARCHAR2, 
    p_operation           IN   VARCHAR2, 
    p_staged_flag         IN   VARCHAR2 DEFAULT 'E', 
    p_realtime_sync_flag  IN   VARCHAR2 DEFAULT 'Y', 
    p_error_data          IN   VARCHAR2 
  ) IS 
  BEGIN 
    INSERT INTO hz_dqm_sync_interface ( 
      PARTY_ID, 
      RECORD_ID, 
      PARTY_SITE_ID, 
      ORG_CONTACT_ID, 
      ENTITY, 
      OPERATION, 
      STAGED_FLAG, 
      REALTIME_SYNC_FLAG, 
      ERROR_DATA, 
      CREATED_BY, 
      CREATION_DATE, 
      LAST_UPDATE_LOGIN, 
      LAST_UPDATE_DATE, 
      LAST_UPDATED_BY, 
      SYNC_INTERFACE_NUM 
    ) VALUES ( 
      p_party_id, 
      p_record_id, 
      p_party_site_id, 
      p_org_contact_id, 
      p_entity, 
      p_operation, 
      p_staged_flag, 
      p_realtime_sync_flag, 
      p_error_data, 
      hz_utility_pub.created_by, 
      hz_utility_pub.creation_date, 
      hz_utility_pub.last_update_login, 
      hz_utility_pub.last_update_date, 
      hz_utility_pub.user_id, 
      HZ_DQM_SYNC_INTERFACE_S.nextval 
    ); 
  END insert_dqm_sync_error_rec; 


  PROCEDURE open_party_cursor( 
    p_select_type	IN	VARCHAR2,
    p_party_type	IN	VARCHAR2,
    p_worker_number IN	NUMBER,
    p_num_workers	IN	NUMBER,
    p_party_id	IN	NUMBER,
    p_continue	IN	VARCHAR2,
    x_party_cur	IN OUT	HZ_PARTY_STAGE.StageCurTyp) IS 

    l_party_type VARCHAR2(255);
  BEGIN
    IF p_select_type = 'SINGLE_PARTY' THEN
      NULL;
    ELSIF p_select_type = 'ALL_PARTIES' THEN
      IF p_continue IS NULL OR p_continue<>'Y' THEN
        IF p_party_type = 'ORGANIZATION' THEN
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,op.DUNS_NUMBER_C
                  ,op.TAX_NAME
                  ,op.TAX_REFERENCE
                  ,op.JGZZ_FISCAL_CODE
                  ,op.SIC_CODE
                  ,op.SIC_CODE_TYPE
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,op.CORPORATION_CLASS
            FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND p.party_id = op.party_id 
            AND op.effective_end_date is NULL 
            AND p.PARTY_TYPE ='ORGANIZATION'; 
        ELSIF p_party_type = 'PERSON' THEN
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,pe.TAX_NAME
                  ,pe.TAX_REFERENCE
                  ,pe.JGZZ_FISCAL_CODE
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
            FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND p.party_id = pe.party_id 
            AND pe.effective_end_date is NULL 
            AND p.PARTY_TYPE ='PERSON'; 
        ELSE
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
            FROM HZ_PARTIES p 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND p.party_type <> 'PERSON' 
            AND p.party_type <> 'ORGANIZATION' 
            AND p.party_type <> 'PARTY_RELATIONSHIP'; 
        END IF;
      ELSE
        IF p_party_type = 'ORGANIZATION' THEN
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,op.DUNS_NUMBER_C
                  ,op.TAX_NAME
                  ,op.TAX_REFERENCE
                  ,op.JGZZ_FISCAL_CODE
                  ,op.SIC_CODE
                  ,op.SIC_CODE_TYPE
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,op.CORPORATION_CLASS
            FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND NOT EXISTS (select 1 FROM HZ_STAGED_PARTIES sp  
                            WHERE sp.party_id = p.party_id)   
            AND p.party_id = op.party_id 
            AND op.effective_end_date is NULL 
            AND p.PARTY_TYPE ='ORGANIZATION'; 
        ELSIF p_party_type = 'PERSON' THEN
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,pe.TAX_NAME
                  ,pe.TAX_REFERENCE
                  ,pe.JGZZ_FISCAL_CODE
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
            FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND NOT EXISTS (select 1 FROM HZ_STAGED_PARTIES sp  
                            WHERE sp.party_id = p.party_id)   
            AND p.party_id = pe.party_id 
            AND pe.effective_end_date is NULL 
            AND p.PARTY_TYPE ='PERSON'; 
        ELSE
          open x_party_cur FOR 
            SELECT p.PARTY_ID, p.STATUS 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
            FROM HZ_PARTIES p 
            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number 
            AND NOT EXISTS (select 1 FROM HZ_STAGED_PARTIES sp  
                            WHERE sp.party_id = p.party_id)   
            AND p.party_type <> 'PERSON' 
            AND p.party_type <> 'ORGANIZATION' 
            AND p.party_type <> 'PARTY_RELATIONSHIP'; 
        END IF;
      END IF;
    END IF;
  END;

  PROCEDURE insert_stage_parties ( 
    p_continue     IN VARCHAR2, 
    p_party_cur    IN HZ_PARTY_STAGE.StageCurTyp) IS 
 l_limit NUMBER := 200;
 l_contact_cur HZ_PARTY_STAGE.StageCurTyp;
 l_cpt_cur HZ_PARTY_STAGE.StageCurTyp;
 l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;
 l_last_fetch BOOLEAN := FALSE;
 call_status BOOLEAN;
 rphase varchar2(255);
 rstatus varchar2(255);
 dphase varchar2(255);
 dstatus varchar2(255);
 message varchar2(255);
 req_id NUMBER;
 l_st number; 
 l_en number; 
 USER_TERMINATE EXCEPTION;

  BEGIN
    req_id := FND_GLOBAL.CONC_REQUEST_ID;
    LOOP
      call_status := FND_CONCURRENT.GET_REQUEST_STATUS(
                req_id, null,null,rphase,rstatus,dphase,dstatus,message);
      IF dstatus = 'TERMINATING' THEN
        FND_FILE.put_line(FND_FILE.log,'Aborted by User');
        RAISE USER_TERMINATE;
      END IF;
      FETCH p_party_cur BULK COLLECT INTO
        H_P_PARTY_ID
        , H_STATUS
         ,H_TX2
         ,H_TX34
         ,H_TX36
         ,H_TX39
         ,H_TX41
         ,H_TX42
         ,H_TX44
         ,H_TX45
         ,H_TX46
         ,H_TX47
         ,H_TX48
         ,H_TX156
         ,H_TX157
      LIMIT l_limit;

    IF p_party_cur%NOTFOUND THEN
      l_last_fetch:=TRUE;
    END IF;
    IF H_P_PARTY_ID.COUNT=0 AND l_last_fetch THEN
      EXIT;
    END IF;
    FOR I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST LOOP

         H_TX32(I):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(I),'PARTY','ALL_ACCOUNT_NAMES', 'STAGE');
         H_TX35(I):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(I),'PARTY','ALL_ACCOUNT_NUMBERS', 'STAGE');
         H_TX61(I):=HZ_EMAIL_DOMAINS_V2PUB.get_email_domains(H_P_PARTY_ID(I),'PARTY','DOMAIN_NAME', 'STAGE');
         H_TX63(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_P_PARTY_ID(I),'PARTY','PARTY_SOURCE_SYSTEM_REF', 'STAGE');
         H_TX4(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
         H_TX8(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
         H_TX19(I):=HZ_TRANS_PKG.SOUNDX(H_TX2(I),NULL, 'PARTY_NAME','PARTY');
         H_TX33(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX32(I),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
         H_TX40(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
         H_TX43(I):=HZ_TRANS_PKG.CLEANSE(H_TX42(I),NULL, 'TAX_NAME','PARTY');
         H_TX59(I):=HZ_TRANS_PKG.BASIC_WRNAMES(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
         H_TX60(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRNAMES(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
         H_TX62(I):=HZ_EMAIL_DOMAINS_V2PUB.FULL_DOMAIN(H_TX61(I),NULL, 'DOMAIN_NAME','PARTY');
         H_TX158(I):=HZ_TRANS_PKG.SOUNDX(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY');
         H_TX2(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(I),NULL, 'PARTY_NAME','PARTY');
         H_TX32(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX32(I),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
         H_TX34(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX34(I),NULL, 'PARTY_NUMBER','PARTY','STAGE');
         H_TX35(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX35(I),NULL, 'ALL_ACCOUNT_NUMBERS','PARTY','STAGE');
         H_TX36(I):=HZ_TRANS_PKG.EXACT(H_TX36(I),NULL, 'PARTY_TYPE','PARTY');
         H_TX39(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
         H_TX41(I):=HZ_TRANS_PKG.EXACT(H_TX41(I),NULL, 'DUNS_NUMBER_C','PARTY');
         H_TX42(I):=HZ_TRANS_PKG.EXACT(H_TX42(I),NULL, 'TAX_NAME','PARTY');
         H_TX44(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX44(I),NULL, 'TAX_REFERENCE','PARTY','STAGE');
         H_TX45(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX45(I),NULL, 'JGZZ_FISCAL_CODE','PARTY','STAGE');
         H_TX46(I):=HZ_TRANS_PKG.EXACT(H_TX46(I),NULL, 'SIC_CODE','PARTY');
         H_TX47(I):=HZ_TRANS_PKG.EXACT(H_TX47(I),NULL, 'SIC_CODE_TYPE','PARTY');
         H_TX48(I):=HZ_TRANS_PKG.EXACT(H_TX48(I),NULL, 'CATEGORY_CODE','PARTY');
         H_TX61(I):=HZ_EMAIL_DOMAINS_V2PUB.CORE_DOMAIN(H_TX61(I),NULL, 'DOMAIN_NAME','PARTY');
         H_TX63(I):=HZ_TRANS_PKG.EXACT(H_TX63(I),NULL, 'PARTY_SOURCE_SYSTEM_REF','PARTY');
         H_TX156(I):=HZ_TRANS_PKG.EXACT(H_TX156(I),NULL, 'REFERENCE_USE_FLAG','PARTY');
         H_TX157(I):=HZ_TRANS_PKG.EXACT(H_TX157(I),NULL, 'CORPORATION_CLASS','PARTY');
      H_PARTY_INDEX(I) := I;
      H_PS_DEN(I) := ' ';
      H_CT_DEN(I) := ' ';
      H_CPT_DEN(I) := ' ';
    END LOOP;
    SAVEPOINT party_batch;
    BEGIN 
      l_st := 1;  
      l_en := H_P_PARTY_ID.COUNT; 
      LOOP 
          BEGIN  
          FORALL I in l_st..l_en
            INSERT INTO HZ_STAGED_PARTIES (
	           PARTY_ID
  	           ,STATUS
               , TX2
               , TX4
               , TX8
               , TX19
               , TX32
               , TX33
               , TX34
               , TX35
               , TX36
               , TX39
               , TX40
               , TX41
               , TX42
               , TX43
               , TX44
               , TX45
               , TX46
               , TX47
               , TX48
               , TX59
               , TX60
               , TX61
               , TX62
               , TX63
               , TX156
               , TX157
               , TX158
             ) VALUES (
             H_P_PARTY_ID(I)
             ,H_STATUS(I)
             , decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
             , decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
             , decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
             , decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
             , decode(H_TX32(I),null,H_TX32(I),H_TX32(I)||' ')
             , decode(H_TX33(I),null,H_TX33(I),H_TX33(I)||' ')
             , decode(H_TX34(I),null,H_TX34(I),H_TX34(I)||' ')
             , decode(H_TX35(I),null,H_TX35(I),H_TX35(I)||' ')
             , decode(H_TX36(I),null,H_TX36(I),H_TX36(I)||' ')
             , decode(H_TX39(I),null,H_TX39(I),H_TX39(I)||' ')
             , decode(H_TX40(I),null,H_TX40(I),H_TX40(I)||' ')
             , decode(H_TX41(I),null,H_TX41(I),H_TX41(I)||' ')
             , decode(H_TX42(I),null,H_TX42(I),H_TX42(I)||' ')
             , decode(H_TX43(I),null,H_TX43(I),H_TX43(I)||' ')
             , decode(H_TX44(I),null,H_TX44(I),H_TX44(I)||' ')
             , decode(H_TX45(I),null,H_TX45(I),H_TX45(I)||' ')
             , decode(H_TX46(I),null,H_TX46(I),H_TX46(I)||' ')
             , decode(H_TX47(I),null,H_TX47(I),H_TX47(I)||' ')
             , decode(H_TX48(I),null,H_TX48(I),H_TX48(I)||' ')
             , decode(H_TX59(I),null,H_TX59(I),H_TX59(I)||' ')
             , decode(H_TX60(I),null,H_TX60(I),H_TX60(I)||' ')
             , decode(H_TX61(I),null,H_TX61(I),H_TX61(I)||' ')
             , decode(H_TX62(I),null,H_TX62(I),H_TX62(I)||' ')
             , decode(H_TX63(I),null,H_TX63(I),H_TX63(I)||' ')
             , decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
             , decode(H_TX157(I),null,H_TX157(I),H_TX157(I)||' ')
             , decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
            );
           EXIT; 
        EXCEPTION  WHEN OTHERS THEN 
            l_st:= l_st+SQL%ROWCOUNT+1;
        END; 
      END LOOP; 
      FORALL I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST
        INSERT INTO HZ_DQM_STAGE_GT ( PARTY_ID, OWNER_ID, PARTY_INDEX) VALUES (
           H_P_PARTY_ID(I),H_P_PARTY_ID(I),H_PARTY_INDEX(I));
        insert_stage_contacts;
        insert_stage_party_sites;
        insert_stage_contact_pts;
      FORALL I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST
        UPDATE HZ_STAGED_PARTIES SET 
                D_PS = H_PS_DEN(I),
                D_CT = H_CT_DEN(I),
                D_CPT = H_CPT_DEN(I)
        WHERE PARTY_ID = H_P_PARTY_ID(I);
      EXCEPTION 
        WHEN OTHERS THEN
          ROLLBACK to party_batch;
          RAISE;
      END;
      IF l_last_fetch THEN
        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;
      FND_CONCURRENT.AF_Commit;
    END LOOP;
  END;

  PROCEDURE sync_single_party (
    p_party_id NUMBER,
    p_party_type VARCHAR2,
    p_operation VARCHAR2) IS

  l_tryins BOOLEAN;
  l_tryupd BOOLEAN;
   BEGIN
    IF p_party_type = 'ORGANIZATION' THEN
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,op.DUNS_NUMBER_C
        ,op.TAX_NAME
        ,op.TAX_REFERENCE
        ,op.JGZZ_FISCAL_CODE
        ,op.SIC_CODE
        ,op.SIC_CODE_TYPE
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,op.CORPORATION_CLASS
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op 
      WHERE p.party_id = p_party_id 
      AND p.party_id = op.party_id 
      AND (p.status = 'M' or op.effective_end_date is NULL)  AND ROWNUM=1; 
    ELSIF p_party_type = 'PERSON' THEN
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,NULL
        ,pe.TAX_NAME
        ,pe.TAX_REFERENCE
        ,pe.JGZZ_FISCAL_CODE
        ,NULL
        ,NULL
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,NULL
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe 
      WHERE p.party_id = p_party_id 
      AND p.party_id = pe.party_id 
      AND (p.status = 'M' or pe.effective_end_date is NULL) AND ROWNUM=1;
    ELSE
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,NULL
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p 
      WHERE p.party_id = p_party_id;
    END IF;
   H_TX32(1):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(1),'PARTY','ALL_ACCOUNT_NAMES', 'STAGE');
   H_TX35(1):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(1),'PARTY','ALL_ACCOUNT_NUMBERS', 'STAGE');
   H_TX61(1):=HZ_EMAIL_DOMAINS_V2PUB.get_email_domains(H_P_PARTY_ID(1),'PARTY','DOMAIN_NAME', 'STAGE');
   H_TX63(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_P_PARTY_ID(1),'PARTY','PARTY_SOURCE_SYSTEM_REF', 'STAGE');
   H_TX4(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
   H_TX8(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
   H_TX19(1):=HZ_TRANS_PKG.SOUNDX(H_TX2(1),NULL, 'PARTY_NAME','PARTY');
   H_TX33(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX32(1),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
   H_TX40(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
   H_TX43(1):=HZ_TRANS_PKG.CLEANSE(H_TX42(1),NULL, 'TAX_NAME','PARTY');
   H_TX59(1):=HZ_TRANS_PKG.BASIC_WRNAMES(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
   H_TX60(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRNAMES(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
   H_TX62(1):=HZ_EMAIL_DOMAINS_V2PUB.FULL_DOMAIN(H_TX61(1),NULL, 'DOMAIN_NAME','PARTY');
   H_TX158(1):=HZ_TRANS_PKG.SOUNDX(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY');
   H_TX2(1):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(1),NULL, 'PARTY_NAME','PARTY');
   H_TX32(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX32(1),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
   H_TX34(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX34(1),NULL, 'PARTY_NUMBER','PARTY','STAGE');
   H_TX35(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX35(1),NULL, 'ALL_ACCOUNT_NUMBERS','PARTY','STAGE');
   H_TX36(1):=HZ_TRANS_PKG.EXACT(H_TX36(1),NULL, 'PARTY_TYPE','PARTY');
   H_TX39(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
   H_TX41(1):=HZ_TRANS_PKG.EXACT(H_TX41(1),NULL, 'DUNS_NUMBER_C','PARTY');
   H_TX42(1):=HZ_TRANS_PKG.EXACT(H_TX42(1),NULL, 'TAX_NAME','PARTY');
   H_TX44(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX44(1),NULL, 'TAX_REFERENCE','PARTY','STAGE');
   H_TX45(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX45(1),NULL, 'JGZZ_FISCAL_CODE','PARTY','STAGE');
   H_TX46(1):=HZ_TRANS_PKG.EXACT(H_TX46(1),NULL, 'SIC_CODE','PARTY');
   H_TX47(1):=HZ_TRANS_PKG.EXACT(H_TX47(1),NULL, 'SIC_CODE_TYPE','PARTY');
   H_TX48(1):=HZ_TRANS_PKG.EXACT(H_TX48(1),NULL, 'CATEGORY_CODE','PARTY');
   H_TX61(1):=HZ_EMAIL_DOMAINS_V2PUB.CORE_DOMAIN(H_TX61(1),NULL, 'DOMAIN_NAME','PARTY');
   H_TX63(1):=HZ_TRANS_PKG.EXACT(H_TX63(1),NULL, 'PARTY_SOURCE_SYSTEM_REF','PARTY');
   H_TX156(1):=HZ_TRANS_PKG.EXACT(H_TX156(1),NULL, 'REFERENCE_USE_FLAG','PARTY');
   H_TX157(1):=HZ_TRANS_PKG.EXACT(H_TX157(1),NULL, 'CORPORATION_CLASS','PARTY');
   l_tryins := FALSE;
   l_tryupd := FALSE;
   IF p_operation='C' THEN
     l_tryins:=TRUE;
   ELSE 
     l_tryupd:=TRUE;
   END IF;
   WHILE (l_tryins OR l_tryupd) LOOP
     IF l_tryins THEN
       BEGIN
         l_tryins:=FALSE;
         INSERT INTO HZ_STAGED_PARTIES (
             PARTY_ID
            ,STATUS
            ,D_PS
            ,D_CT
            ,D_CPT
              , TX2
              , TX4
              , TX8
              , TX19
              , TX32
              , TX33
              , TX34
              , TX35
              , TX36
              , TX39
              , TX40
              , TX41
              , TX42
              , TX43
              , TX44
              , TX45
              , TX46
              , TX47
              , TX48
              , TX59
              , TX60
              , TX61
              , TX62
              , TX63
              , TX156
              , TX157
              , TX158
           ) VALUES (
             H_P_PARTY_ID(1)
            ,H_STATUS(1)
            ,'SYNC'
            ,'SYNC'
            ,'SYNC'
             , decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
             , decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
             , decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
             , decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
             , decode(H_TX32(1),null,H_TX32(1),H_TX32(1)||' ')
             , decode(H_TX33(1),null,H_TX33(1),H_TX33(1)||' ')
             , decode(H_TX34(1),null,H_TX34(1),H_TX34(1)||' ')
             , decode(H_TX35(1),null,H_TX35(1),H_TX35(1)||' ')
             , decode(H_TX36(1),null,H_TX36(1),H_TX36(1)||' ')
             , decode(H_TX39(1),null,H_TX39(1),H_TX39(1)||' ')
             , decode(H_TX40(1),null,H_TX40(1),H_TX40(1)||' ')
             , decode(H_TX41(1),null,H_TX41(1),H_TX41(1)||' ')
             , decode(H_TX42(1),null,H_TX42(1),H_TX42(1)||' ')
             , decode(H_TX43(1),null,H_TX43(1),H_TX43(1)||' ')
             , decode(H_TX44(1),null,H_TX44(1),H_TX44(1)||' ')
             , decode(H_TX45(1),null,H_TX45(1),H_TX45(1)||' ')
             , decode(H_TX46(1),null,H_TX46(1),H_TX46(1)||' ')
             , decode(H_TX47(1),null,H_TX47(1),H_TX47(1)||' ')
             , decode(H_TX48(1),null,H_TX48(1),H_TX48(1)||' ')
             , decode(H_TX59(1),null,H_TX59(1),H_TX59(1)||' ')
             , decode(H_TX60(1),null,H_TX60(1),H_TX60(1)||' ')
             , decode(H_TX61(1),null,H_TX61(1),H_TX61(1)||' ')
             , decode(H_TX62(1),null,H_TX62(1),H_TX62(1)||' ')
             , decode(H_TX63(1),null,H_TX63(1),H_TX63(1)||' ')
             , decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
             , decode(H_TX157(1),null,H_TX157(1),H_TX157(1)||' ')
             , decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
         );
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           IF p_operation='C' THEN
             l_tryupd:=TRUE;
           END IF;
       END;
     END IF;
     IF l_tryupd THEN
       BEGIN
         l_tryupd:=FALSE;
         UPDATE HZ_STAGED_PARTIES SET 
            status =H_STATUS(1) 
            ,concat_col = concat_col 
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX8=decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,TX19=decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,TX32=decode(H_TX32(1),null,H_TX32(1),H_TX32(1)||' ')
            ,TX33=decode(H_TX33(1),null,H_TX33(1),H_TX33(1)||' ')
            ,TX34=decode(H_TX34(1),null,H_TX34(1),H_TX34(1)||' ')
            ,TX35=decode(H_TX35(1),null,H_TX35(1),H_TX35(1)||' ')
            ,TX36=decode(H_TX36(1),null,H_TX36(1),H_TX36(1)||' ')
            ,TX39=decode(H_TX39(1),null,H_TX39(1),H_TX39(1)||' ')
            ,TX40=decode(H_TX40(1),null,H_TX40(1),H_TX40(1)||' ')
            ,TX41=decode(H_TX41(1),null,H_TX41(1),H_TX41(1)||' ')
            ,TX42=decode(H_TX42(1),null,H_TX42(1),H_TX42(1)||' ')
            ,TX43=decode(H_TX43(1),null,H_TX43(1),H_TX43(1)||' ')
            ,TX44=decode(H_TX44(1),null,H_TX44(1),H_TX44(1)||' ')
            ,TX45=decode(H_TX45(1),null,H_TX45(1),H_TX45(1)||' ')
            ,TX46=decode(H_TX46(1),null,H_TX46(1),H_TX46(1)||' ')
            ,TX47=decode(H_TX47(1),null,H_TX47(1),H_TX47(1)||' ')
            ,TX48=decode(H_TX48(1),null,H_TX48(1),H_TX48(1)||' ')
            ,TX59=decode(H_TX59(1),null,H_TX59(1),H_TX59(1)||' ')
            ,TX60=decode(H_TX60(1),null,H_TX60(1),H_TX60(1)||' ')
            ,TX61=decode(H_TX61(1),null,H_TX61(1),H_TX61(1)||' ')
            ,TX62=decode(H_TX62(1),null,H_TX62(1),H_TX62(1)||' ')
            ,TX63=decode(H_TX63(1),null,H_TX63(1),H_TX63(1)||' ')
            ,TX156=decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
            ,TX157=decode(H_TX157(1),null,H_TX157(1),H_TX157(1)||' ')
            ,TX158=decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
         WHERE PARTY_ID=H_P_PARTY_ID(1);
         IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
           l_tryins := TRUE;
         END IF;
       EXCEPTION 
         WHEN NO_DATA_FOUND THEN
           IF p_operation='U' THEN
             l_tryins := TRUE;
           END IF;
       END;
     END IF;
   END LOOP;
  END;

  PROCEDURE sync_single_party_online (
    p_party_id    NUMBER,
    p_operation   VARCHAR2) IS

  l_tryins           BOOLEAN;
  l_tryupd           BOOLEAN;
  l_party_type       VARCHAR2(30); 
  l_org_contact_id   NUMBER; 
  l_sql_err_message  VARCHAR2(2000); 

  --bug 4500011 replaced hz_party_relationships with hz_relationships 
  CURSOR c_contact IS 
    SELECT oc.org_contact_id 
    FROM HZ_RELATIONSHIPS pr, HZ_ORG_CONTACTS oc 
    WHERE pr.relationship_id    = oc.party_relationship_id 
    AND   pr.subject_id         = p_party_id 
    AND   pr.subject_table_name = 'HZ_PARTIES' 
    AND   pr.object_table_name  = 'HZ_PARTIES' 
    AND   pr.directional_flag   = 'F'; 

  BEGIN

    -- Get party_type 
    SELECT party_type INTO l_party_type 
    FROM hz_parties WHERE party_id = p_party_id; 

    -- Set global G_PARTY_TYPE variable value
    hz_trans_pkg.set_party_type(l_party_type); 

    IF l_party_type = 'PERSON' THEN 
    ---------------------------------- 
    -- Take care of CONTACT INFORMATION 
    -- When the operation is an update 
    ---------------------------------- 
      IF p_operation = 'U' THEN 
        OPEN c_contact; 
        LOOP 
          FETCH c_contact INTO l_org_contact_id; 
          EXIT WHEN c_contact%NOTFOUND; 
          BEGIN 
            sync_single_contact_online(l_org_contact_id, p_operation); 
          EXCEPTION WHEN OTHERS THEN 
            -- FAILOVER : REPORT RECORD TO HZ_DQM_SYNC_INTERFACE 
            -- FOR ONLINE FLOWS 
            l_sql_err_message := SQLERRM; 
            insert_dqm_sync_error_rec(p_party_id,l_org_contact_id,null,null,'CONTACTS','U','E','Y', l_sql_err_message); 
          END ; 
        END LOOP; 
      END IF ; 
    END IF; 

    IF l_party_type = 'ORGANIZATION' THEN
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,op.DUNS_NUMBER_C
        ,op.TAX_NAME
        ,op.TAX_REFERENCE
        ,op.JGZZ_FISCAL_CODE
        ,op.SIC_CODE
        ,op.SIC_CODE_TYPE
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,op.CORPORATION_CLASS
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op 
      WHERE p.party_id = p_party_id 
      AND p.party_id = op.party_id 
      AND (p.status = 'M' or op.effective_end_date is NULL)  AND ROWNUM=1; 
    ELSIF l_party_type = 'PERSON' THEN
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,NULL
        ,pe.TAX_NAME
        ,pe.TAX_REFERENCE
        ,pe.JGZZ_FISCAL_CODE
        ,NULL
        ,NULL
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,NULL
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe 
      WHERE p.party_id = p_party_id 
      AND p.party_id = pe.party_id 
      AND (p.status = 'M' or pe.effective_end_date is NULL) AND ROWNUM=1;
    ELSE
      SELECT p.PARTY_ID, p.STATUS 
        ,p.PARTY_NAME
        ,p.PARTY_NUMBER
        ,p.PARTY_TYPE
        ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,p.CATEGORY_CODE
        ,p.REFERENCE_USE_FLAG
        ,NULL
      INTO H_P_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX34(1)
         , H_TX36(1)
         , H_TX39(1)
         , H_TX41(1)
         , H_TX42(1)
         , H_TX44(1)
         , H_TX45(1)
         , H_TX46(1)
         , H_TX47(1)
         , H_TX48(1)
         , H_TX156(1)
         , H_TX157(1)
      FROM HZ_PARTIES p 
      WHERE p.party_id = p_party_id;
    END IF;

    H_TX32(1):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(1),'PARTY','ALL_ACCOUNT_NAMES', 'STAGE');
    H_TX35(1):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(1),'PARTY','ALL_ACCOUNT_NUMBERS', 'STAGE');
    H_TX61(1):=HZ_EMAIL_DOMAINS_V2PUB.get_email_domains(H_P_PARTY_ID(1),'PARTY','DOMAIN_NAME', 'STAGE');
    H_TX63(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_P_PARTY_ID(1),'PARTY','PARTY_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX4(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
    H_TX8(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
    H_TX19(1):=HZ_TRANS_PKG.SOUNDX(H_TX2(1),NULL, 'PARTY_NAME','PARTY');
    H_TX33(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX32(1),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
    H_TX40(1):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
    H_TX43(1):=HZ_TRANS_PKG.CLEANSE(H_TX42(1),NULL, 'TAX_NAME','PARTY');
    H_TX59(1):=HZ_TRANS_PKG.BASIC_WRNAMES(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
    H_TX60(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRNAMES(H_TX2(1),NULL, 'PARTY_NAME','PARTY','STAGE');
    H_TX62(1):=HZ_EMAIL_DOMAINS_V2PUB.FULL_DOMAIN(H_TX61(1),NULL, 'DOMAIN_NAME','PARTY');
    H_TX158(1):=HZ_TRANS_PKG.SOUNDX(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY');
    H_TX2(1):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(1),NULL, 'PARTY_NAME','PARTY');
    H_TX32(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX32(1),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
    H_TX34(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX34(1),NULL, 'PARTY_NUMBER','PARTY','STAGE');
    H_TX35(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX35(1),NULL, 'ALL_ACCOUNT_NUMBERS','PARTY','STAGE');
    H_TX36(1):=HZ_TRANS_PKG.EXACT(H_TX36(1),NULL, 'PARTY_TYPE','PARTY');
    H_TX39(1):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX39(1),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
    H_TX41(1):=HZ_TRANS_PKG.EXACT(H_TX41(1),NULL, 'DUNS_NUMBER_C','PARTY');
    H_TX42(1):=HZ_TRANS_PKG.EXACT(H_TX42(1),NULL, 'TAX_NAME','PARTY');
    H_TX44(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX44(1),NULL, 'TAX_REFERENCE','PARTY','STAGE');
    H_TX45(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX45(1),NULL, 'JGZZ_FISCAL_CODE','PARTY','STAGE');
    H_TX46(1):=HZ_TRANS_PKG.EXACT(H_TX46(1),NULL, 'SIC_CODE','PARTY');
    H_TX47(1):=HZ_TRANS_PKG.EXACT(H_TX47(1),NULL, 'SIC_CODE_TYPE','PARTY');
    H_TX48(1):=HZ_TRANS_PKG.EXACT(H_TX48(1),NULL, 'CATEGORY_CODE','PARTY');
    H_TX61(1):=HZ_EMAIL_DOMAINS_V2PUB.CORE_DOMAIN(H_TX61(1),NULL, 'DOMAIN_NAME','PARTY');
    H_TX63(1):=HZ_TRANS_PKG.EXACT(H_TX63(1),NULL, 'PARTY_SOURCE_SYSTEM_REF','PARTY');
    H_TX156(1):=HZ_TRANS_PKG.EXACT(H_TX156(1),NULL, 'REFERENCE_USE_FLAG','PARTY');
    H_TX157(1):=HZ_TRANS_PKG.EXACT(H_TX157(1),NULL, 'CORPORATION_CLASS','PARTY');

    l_tryins := FALSE;
    l_tryupd := FALSE;

    IF p_operation='C' THEN
      l_tryins:=TRUE;
    ELSE 
      l_tryupd:=TRUE;
    END IF;

    WHILE (l_tryins OR l_tryupd) LOOP
      IF l_tryins THEN
        BEGIN
          l_tryins:=FALSE;
          INSERT INTO HZ_STAGED_PARTIES (
             PARTY_ID
            ,STATUS
            ,D_PS
            ,D_CT
            ,D_CPT
            ,TX2
            ,TX4
            ,TX8
            ,TX19
            ,TX32
            ,TX33
            ,TX34
            ,TX35
            ,TX36
            ,TX39
            ,TX40
            ,TX41
            ,TX42
            ,TX43
            ,TX44
            ,TX45
            ,TX46
            ,TX47
            ,TX48
            ,TX59
            ,TX60
            ,TX61
            ,TX62
            ,TX63
            ,TX156
            ,TX157
            ,TX158
          ) VALUES (
             H_P_PARTY_ID(1)
            ,H_STATUS(1)
            ,'SYNC'
            ,'SYNC'
            ,'SYNC'
            ,decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,decode(H_TX32(1),null,H_TX32(1),H_TX32(1)||' ')
            ,decode(H_TX33(1),null,H_TX33(1),H_TX33(1)||' ')
            ,decode(H_TX34(1),null,H_TX34(1),H_TX34(1)||' ')
            ,decode(H_TX35(1),null,H_TX35(1),H_TX35(1)||' ')
            ,decode(H_TX36(1),null,H_TX36(1),H_TX36(1)||' ')
            ,decode(H_TX39(1),null,H_TX39(1),H_TX39(1)||' ')
            ,decode(H_TX40(1),null,H_TX40(1),H_TX40(1)||' ')
            ,decode(H_TX41(1),null,H_TX41(1),H_TX41(1)||' ')
            ,decode(H_TX42(1),null,H_TX42(1),H_TX42(1)||' ')
            ,decode(H_TX43(1),null,H_TX43(1),H_TX43(1)||' ')
            ,decode(H_TX44(1),null,H_TX44(1),H_TX44(1)||' ')
            ,decode(H_TX45(1),null,H_TX45(1),H_TX45(1)||' ')
            ,decode(H_TX46(1),null,H_TX46(1),H_TX46(1)||' ')
            ,decode(H_TX47(1),null,H_TX47(1),H_TX47(1)||' ')
            ,decode(H_TX48(1),null,H_TX48(1),H_TX48(1)||' ')
            ,decode(H_TX59(1),null,H_TX59(1),H_TX59(1)||' ')
            ,decode(H_TX60(1),null,H_TX60(1),H_TX60(1)||' ')
            ,decode(H_TX61(1),null,H_TX61(1),H_TX61(1)||' ')
            ,decode(H_TX62(1),null,H_TX62(1),H_TX62(1)||' ')
            ,decode(H_TX63(1),null,H_TX63(1),H_TX63(1)||' ')
            ,decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
            ,decode(H_TX157(1),null,H_TX157(1),H_TX157(1)||' ')
            ,decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
          );
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            IF p_operation='C' THEN
              l_tryupd:=TRUE;
            END IF;
        END;
      END IF;

      IF l_tryupd THEN
        BEGIN
          l_tryupd:=FALSE;
          UPDATE HZ_STAGED_PARTIES SET 
             concat_col = concat_col 
            ,status =H_STATUS(1) 
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX8=decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,TX19=decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,TX32=decode(H_TX32(1),null,H_TX32(1),H_TX32(1)||' ')
            ,TX33=decode(H_TX33(1),null,H_TX33(1),H_TX33(1)||' ')
            ,TX34=decode(H_TX34(1),null,H_TX34(1),H_TX34(1)||' ')
            ,TX35=decode(H_TX35(1),null,H_TX35(1),H_TX35(1)||' ')
            ,TX36=decode(H_TX36(1),null,H_TX36(1),H_TX36(1)||' ')
            ,TX39=decode(H_TX39(1),null,H_TX39(1),H_TX39(1)||' ')
            ,TX40=decode(H_TX40(1),null,H_TX40(1),H_TX40(1)||' ')
            ,TX41=decode(H_TX41(1),null,H_TX41(1),H_TX41(1)||' ')
            ,TX42=decode(H_TX42(1),null,H_TX42(1),H_TX42(1)||' ')
            ,TX43=decode(H_TX43(1),null,H_TX43(1),H_TX43(1)||' ')
            ,TX44=decode(H_TX44(1),null,H_TX44(1),H_TX44(1)||' ')
            ,TX45=decode(H_TX45(1),null,H_TX45(1),H_TX45(1)||' ')
            ,TX46=decode(H_TX46(1),null,H_TX46(1),H_TX46(1)||' ')
            ,TX47=decode(H_TX47(1),null,H_TX47(1),H_TX47(1)||' ')
            ,TX48=decode(H_TX48(1),null,H_TX48(1),H_TX48(1)||' ')
            ,TX59=decode(H_TX59(1),null,H_TX59(1),H_TX59(1)||' ')
            ,TX60=decode(H_TX60(1),null,H_TX60(1),H_TX60(1)||' ')
            ,TX61=decode(H_TX61(1),null,H_TX61(1),H_TX61(1)||' ')
            ,TX62=decode(H_TX62(1),null,H_TX62(1),H_TX62(1)||' ')
            ,TX63=decode(H_TX63(1),null,H_TX63(1),H_TX63(1)||' ')
            ,TX156=decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
            ,TX157=decode(H_TX157(1),null,H_TX157(1),H_TX157(1)||' ')
            ,TX158=decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
          WHERE PARTY_ID=H_P_PARTY_ID(1);
          IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
            l_tryins := TRUE;
          END IF;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN
            IF p_operation='U' THEN
              l_tryins := TRUE;
            END IF;
        END;
      END IF;
    END LOOP;

      -- REPURI. Bug 4884742. If shadow staging is completely successfully 
      -- insert a record into hz_dqm_sh_sync_interface table for each record 
    IF (HZ_DQM_SYNC.is_shadow_staging_complete) THEN 
      BEGIN 
        HZ_DQM_SYNC.insert_sh_interface_rec(p_party_id,null,null,null,'PARTY',p_operation); 
      EXCEPTION WHEN OTHERS THEN 
        NULL; 
      END; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    -- FAILOVER : REPORT RECORD TO HZ_DQM_SYNC_INTERFACE 
    -- FOR ONLINE FLOWS 
    l_sql_err_message := SQLERRM; 
    insert_dqm_sync_error_rec(p_party_id, NULL, NULL, NULL, 'PARTY', p_operation, 'E', 'Y', l_sql_err_message); 
  END;

  PROCEDURE insert_stage_contacts IS 
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    l_denorm VARCHAR2(2000);
    l_st number; 
    l_en number; 
  CURSOR contact_cur IS
            SELECT 
              /*+ ORDERED USE_NL(R OC PP)*/
            oc.ORG_CONTACT_ID , r.OBJECT_ID, r.PARTY_ID, g.PARTY_INDEX, r.STATUS 
                  ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
                  ,oc.CONTACT_NUMBER
                  ,oc.JOB_TITLE
           FROM HZ_DQM_STAGE_GT g, HZ_RELATIONSHIPS r,
           HZ_ORG_CONTACTS oc, HZ_PERSON_PROFILES pp
           WHERE oc.party_relationship_id =  r.relationship_id 
           AND r.object_id = g.party_id 
           AND r.subject_id = pp.party_id 
           AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND DIRECTIONAL_FLAG= 'F' 
           AND pp.effective_end_date is NULL 
           AND (oc.status is null OR oc.status = 'A' or oc.status = 'I')
           AND (r.status is null OR r.status = 'A' or r.status = 'I');

  BEGIN
    OPEN contact_cur;
    LOOP
      FETCH contact_cur BULK COLLECT INTO
        H_ORG_CONTACT_ID
        ,H_C_PARTY_ID
        ,H_R_PARTY_ID
        ,H_PARTY_INDEX
        ,H_STATUS
         ,H_TX2
         ,H_TX11
         ,H_TX22
      LIMIT l_limit;

    IF contact_cur%NOTFOUND THEN
      l_last_fetch:=TRUE;
    END IF;
    IF H_C_PARTY_ID.COUNT=0 AND l_last_fetch THEN
      EXIT;
    END IF;
    FOR I in H_C_PARTY_ID.FIRST..H_C_PARTY_ID.LAST LOOP

         H_TX25(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_ORG_CONTACT_ID(I),'CONTACTS','CONTACT_SOURCE_SYSTEM_REF', 'STAGE');
         H_TX5(I):=HZ_TRANS_PKG.WRPERSON_EXACT(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
         H_TX6(I):=HZ_TRANS_PKG.WRPERSON_CLEANSE(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
         H_TX23(I):=HZ_TRANS_PKG.BASIC_WRPERSON(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
         H_TX24(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRPERSON(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
         H_TX156(I):=HZ_TRANS_PKG.SOUNDX(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS');
         H_TX2(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS');
         H_TX11(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'CONTACT_NUMBER','CONTACTS','STAGE');
         H_TX22(I):=HZ_TRANS_PKG.EXACT(H_TX22(I),NULL, 'JOB_TITLE','CONTACTS');
         H_TX25(I):=HZ_TRANS_PKG.EXACT(H_TX25(I),NULL, 'CONTACT_SOURCE_SYSTEM_REF','CONTACTS');
      BEGIN 
        l_denorm := H_TX22(I)
             ;
        IF H_CT_DEN(H_PARTY_INDEX(I)) = 'SYNC' THEN
          NULL;
        ELSIF lengthb(H_CT_DEN(H_PARTY_INDEX(I)))+lengthb(l_denorm)<2000 THEN
          IF H_CT_DEN(H_PARTY_INDEX(I)) IS NULL OR instrb(H_CT_DEN(H_PARTY_INDEX(I)),l_denorm)= 0 THEN
            H_CT_DEN(H_PARTY_INDEX(I)) := H_CT_DEN(H_PARTY_INDEX(I)) || ' ' || l_denorm;
          END IF;
        ELSE
          H_CT_DEN(H_PARTY_INDEX(I)) := 'SYNC';
        END IF;
      EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE=-6502 THEN
          H_CT_DEN(H_PARTY_INDEX(I)) := 'SYNC';
        END IF; 
      END; 
    END LOOP;
      l_st :=  1;  
      l_en :=  H_C_PARTY_ID.COUNT; 
      LOOP 
          BEGIN  
             FORALL I in l_st..l_en
             INSERT INTO HZ_STAGED_CONTACTS (
	            ORG_CONTACT_ID
	            ,PARTY_ID
                ,STATUS_FLAG 
                , TX2
                , TX5
                , TX6
                , TX11
                , TX22
                , TX23
                , TX24
                , TX25
                , TX156
             ) VALUES (
             H_ORG_CONTACT_ID(I)
             ,H_C_PARTY_ID(I)
             ,H_STATUS(I)
             , decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
             , decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
             , decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
             , decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
             , decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
             , decode(H_TX23(I),null,H_TX23(I),H_TX23(I)||' ')
             , decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
             , decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
             , decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
          );
        EXIT; 
        EXCEPTION  WHEN OTHERS THEN 
            l_st:= l_st+SQL%ROWCOUNT+1;
        END; 
      END LOOP; 
      FORALL I in H_C_PARTY_ID.FIRST..H_C_PARTY_ID.LAST 
        INSERT INTO HZ_DQM_STAGE_GT(PARTY_ID,OWNER_ID,ORG_CONTACT_ID,PARTY_INDEX) 
           SELECT H_C_PARTY_ID(I), H_R_PARTY_ID(I), H_ORG_CONTACT_ID(I), H_PARTY_INDEX(I)
           FROM DUAL WHERE H_R_PARTY_ID(I) IS NOT NULL;
      IF l_last_fetch THEN
        EXIT;
      END IF;
    END LOOP;
     CLOSE contact_cur;
  END;

  PROCEDURE sync_single_contact (
    p_org_contact_id NUMBER,
    p_operation VARCHAR2) IS

  l_tryins BOOLEAN;
  l_tryupd BOOLEAN;
   BEGIN
     SELECT oc.ORG_CONTACT_ID, d.PARTY_ID, r.STATUS 
          ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
          ,oc.CONTACT_NUMBER
          ,oc.JOB_TITLE
      INTO H_ORG_CONTACT_ID(1), H_PARTY_ID(1), H_STATUS(1)
         , H_TX2(1)
         , H_TX11(1)
         , H_TX22(1)
     FROM HZ_ORG_CONTACTS oc, HZ_DQM_SYNC_INTERFACE d, 
          HZ_RELATIONSHIPS r, HZ_PERSON_PROFILES pp
     WHERE d.ENTITY = 'CONTACTS' 
     AND oc.org_contact_id = p_org_contact_id
     AND oc.org_contact_id = d.RECORD_ID
     AND oc.party_relationship_id =  r.relationship_id 
     AND r.subject_id = pp.party_id 
     AND r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
     AND r.OBJECT_TABLE_NAME = 'HZ_PARTIES'
     AND DIRECTIONAL_FLAG= 'F' 
     AND pp.effective_end_date is NULL 
     AND (oc.status is null OR oc.status = 'A' or oc.status = 'I')
     AND (r.status is null OR r.status = 'A' or r.status = 'I')
     AND ROWNUM=1;
    H_TX25(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_ORG_CONTACT_ID(1),'CONTACTS','CONTACT_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX5(1):=HZ_TRANS_PKG.WRPERSON_EXACT(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX6(1):=HZ_TRANS_PKG.WRPERSON_CLEANSE(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX23(1):=HZ_TRANS_PKG.BASIC_WRPERSON(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX24(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRPERSON(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX156(1):=HZ_TRANS_PKG.SOUNDX(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS');
    H_TX2(1):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS');
    H_TX11(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(1),NULL, 'CONTACT_NUMBER','CONTACTS','STAGE');
    H_TX22(1):=HZ_TRANS_PKG.EXACT(H_TX22(1),NULL, 'JOB_TITLE','CONTACTS');
    H_TX25(1):=HZ_TRANS_PKG.EXACT(H_TX25(1),NULL, 'CONTACT_SOURCE_SYSTEM_REF','CONTACTS');
   l_tryins := FALSE;
   l_tryupd := FALSE;
   IF p_operation='C' THEN
     l_tryins:=TRUE;
   ELSE 
     l_tryupd:=TRUE;
   END IF;
   WHILE (l_tryins OR l_tryupd) LOOP
     IF l_tryins THEN
       BEGIN
         l_tryins:=FALSE;
         INSERT INTO HZ_STAGED_CONTACTS (
           ORG_CONTACT_ID
           ,PARTY_ID
           ,STATUS_FLAG 
              , TX2
              , TX5
              , TX6
              , TX11
              , TX22
              , TX23
              , TX24
              , TX25
              , TX156
           ) VALUES (
            H_ORG_CONTACT_ID(1)
            , H_PARTY_ID(1)
            , H_STATUS(1)
             , decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
             , decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
             , decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
             , decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
             , decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
             , decode(H_TX23(1),null,H_TX23(1),H_TX23(1)||' ')
             , decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
             , decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
             , decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
         );
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           IF p_operation='C' THEN
             l_tryupd:=TRUE;
           END IF;
       END;
     END IF;
     IF l_tryupd THEN
       BEGIN
         l_tryupd:=FALSE;
         UPDATE HZ_STAGED_CONTACTS SET 
            concat_col = concat_col
           ,status_flag = H_STATUS(1)
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX5=decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,TX6=decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX22=decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,TX23=decode(H_TX23(1),null,H_TX23(1),H_TX23(1)||' ')
            ,TX24=decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,TX25=decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,TX156=decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
         WHERE ORG_CONTACT_ID=H_ORG_CONTACT_ID(1);
         IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
           l_tryins := TRUE;
         END IF;
       EXCEPTION 
         WHEN NO_DATA_FOUND THEN
           IF p_operation='U' THEN
             l_tryins := TRUE;
           END IF;
       END;
     END IF;
   END LOOP;
   --Fix for bug 5048604, to update concat_col during update of denorm column 
   UPDATE HZ_STAGED_PARTIES set
     D_CT = 'SYNC'
    ,CONCAT_COL = CONCAT_COL 
   WHERE PARTY_ID = H_PARTY_ID(1);
  END;

  PROCEDURE sync_single_contact_online (
    p_org_contact_id   NUMBER,
    p_operation        VARCHAR2) IS

    l_tryins BOOLEAN;
    l_tryupd BOOLEAN;
    l_party_id NUMBER; 
    l_sql_err_message VARCHAR2(2000); 

  BEGIN

    l_party_id := -1; 

    SELECT r.object_id INTO l_party_id 
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r 
    WHERE oc.org_contact_id         = p_org_contact_id 
    AND   oc.party_relationship_id  =  r.relationship_id 
    AND   r.SUBJECT_TABLE_NAME      = 'HZ_PARTIES' 
    AND   r.OBJECT_TABLE_NAME       = 'HZ_PARTIES' 
    AND   subject_type              = 'PERSON' 
    AND   DIRECTIONAL_FLAG          = 'F' 
    AND   (oc.status is null OR oc.status = 'A' or oc.status = 'I') 
    AND   (r.status is null OR r.status = 'A' or r.status = 'I') ; 

    SELECT oc.ORG_CONTACT_ID, l_party_id, r.status 
          ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
          ,oc.CONTACT_NUMBER
          ,oc.JOB_TITLE
    INTO H_ORG_CONTACT_ID(1), H_PARTY_ID(1), H_STATUS(1)
        ,H_TX2(1)
        ,H_TX11(1)
        ,H_TX22(1)
    FROM HZ_ORG_CONTACTS oc, 
         HZ_RELATIONSHIPS r, HZ_PERSON_PROFILES pp
    WHERE 
          oc.org_contact_id         = p_org_contact_id
     AND  oc.party_relationship_id  = r.relationship_id 
     AND  r.subject_id              = pp.party_id 
     AND  r.SUBJECT_TABLE_NAME      = 'HZ_PARTIES'
     AND  r.OBJECT_TABLE_NAME       = 'HZ_PARTIES'
     AND  DIRECTIONAL_FLAG          = 'F' 
     AND  pp.effective_end_date is NULL 
     AND  (oc.status is null OR oc.status = 'A' or oc.status = 'I')
     AND  (r.status is null OR r.status = 'A' or r.status = 'I')
     AND  ROWNUM=1;

    H_TX25(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_ORG_CONTACT_ID(1),'CONTACTS','CONTACT_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX5(1):=HZ_TRANS_PKG.WRPERSON_EXACT(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX6(1):=HZ_TRANS_PKG.WRPERSON_CLEANSE(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX23(1):=HZ_TRANS_PKG.BASIC_WRPERSON(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX24(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRPERSON(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
    H_TX156(1):=HZ_TRANS_PKG.SOUNDX(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS');
    H_TX2(1):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(1),NULL, 'CONTACT_NAME','CONTACTS');
    H_TX11(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(1),NULL, 'CONTACT_NUMBER','CONTACTS','STAGE');
    H_TX22(1):=HZ_TRANS_PKG.EXACT(H_TX22(1),NULL, 'JOB_TITLE','CONTACTS');
    H_TX25(1):=HZ_TRANS_PKG.EXACT(H_TX25(1),NULL, 'CONTACT_SOURCE_SYSTEM_REF','CONTACTS');

    l_tryins := FALSE;
    l_tryupd := FALSE;

    IF p_operation='C' THEN
      l_tryins:=TRUE;
    ELSE 
      l_tryupd:=TRUE;
    END IF;

    WHILE (l_tryins OR l_tryupd) LOOP
      IF l_tryins THEN
        BEGIN
          l_tryins:=FALSE;
          INSERT INTO HZ_STAGED_CONTACTS (
             ORG_CONTACT_ID
            ,PARTY_ID
            ,STATUS_FLAG
            ,TX2
            ,TX5
            ,TX6
            ,TX11
            ,TX22
            ,TX23
            ,TX24
            ,TX25
            ,TX156
          ) VALUES (
             H_ORG_CONTACT_ID(1)
            ,H_PARTY_ID(1)
            ,H_STATUS(1)
            ,decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,decode(H_TX23(1),null,H_TX23(1),H_TX23(1)||' ')
            ,decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
          );
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            IF p_operation='C' THEN
              l_tryupd:=TRUE;
            END IF;
        END;
      END IF;

      IF l_tryupd THEN
        BEGIN
          l_tryupd:=FALSE;
          UPDATE HZ_STAGED_CONTACTS SET 
             concat_col = concat_col
            ,status_flag = H_STATUS(1) 
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX5=decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,TX6=decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX22=decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,TX23=decode(H_TX23(1),null,H_TX23(1),H_TX23(1)||' ')
            ,TX24=decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,TX25=decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,TX156=decode(H_TX156(1),null,H_TX156(1),H_TX156(1)||' ')
          WHERE ORG_CONTACT_ID=H_ORG_CONTACT_ID(1);
          IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
            l_tryins := TRUE;
          END IF;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN
            IF p_operation='U' THEN
              l_tryins := TRUE;
            END IF;
        END;
      END IF;
    END LOOP;

    --Fix for bug 5048604, to update concat_col during update of denorm column 
    UPDATE HZ_STAGED_PARTIES set
      D_CT = 'SYNC'
     ,CONCAT_COL = CONCAT_COL 
    WHERE PARTY_ID = H_PARTY_ID(1);

      -- REPURI. Bug 4884742. If shadow staging is completely successfully 
      -- insert a record into hz_dqm_sh_sync_interface table for each record 
    IF (HZ_DQM_SYNC.is_shadow_staging_complete) THEN 
      BEGIN 
        HZ_DQM_SYNC.insert_sh_interface_rec(l_party_id,p_org_contact_id,null,null,'CONTACTS',p_operation); 
      EXCEPTION WHEN OTHERS THEN 
        NULL; 
      END; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    -- FAILOVER : REPORT RECORD TO HZ_DQM_SYNC_INTERFACE 
    -- FOR ONLINE FLOWS 
    l_sql_err_message := SQLERRM; 
    insert_dqm_sync_error_rec(l_party_id, p_org_contact_id, NULL, NULL, 'CONTACTS', p_operation, 'E', 'Y', l_sql_err_message); 
  END;

  PROCEDURE insert_stage_contact_pts IS 
   l_limit NUMBER := 200;
   l_last_fetch BOOLEAN := FALSE;
   l_denorm VARCHAR2(2000);
   l_st number; 
   l_en number; 

  CURSOR contact_pt_cur IS
           SELECT /*+ ORDERED USE_NL(cp) */ cp.CONTACT_POINT_ID, g.party_id, g.party_site_id, g.org_contact_id, cp.CONTACT_POINT_TYPE, PARTY_INDEX, cp.STATUS 
                  ,translate(phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' || translate(phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' ||  translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
                  ,cp.PHONE_NUMBER
                  ,cp.PHONE_AREA_CODE
                  ,cp.PHONE_COUNTRY_CODE
                  ,cp.EMAIL_ADDRESS
                  ,cp.URL
                  ,cp.PRIMARY_FLAG
                  ,translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
                  ,cp.PHONE_LINE_TYPE
                  ,cp.STATUS
                  ,cp.CONTACT_POINT_PURPOSE
           FROM HZ_DQM_STAGE_GT g,HZ_CONTACT_POINTS cp
           WHERE cp.owner_table_id  =  g.owner_id 
           AND cp.OWNER_TABLE_NAME = nvl(g.owner_table,'HZ_PARTIES') 
           AND (cp.status is null OR cp.status = 'A' or cp.status = 'I'); 

  BEGIN
    OPEN contact_pt_cur;
    LOOP
      FETCH contact_pt_cur BULK COLLECT INTO
        H_CONTACT_POINT_ID
        ,H_CPT_PARTY_ID
        ,H_CPT_PARTY_SITE_ID
        ,H_CPT_ORG_CONTACT_ID
        ,H_CONTACT_POINT_TYPE
        ,H_PARTY_INDEX
        ,H_STATUS
         ,H_TX1
         ,H_TX2
         ,H_TX3
         ,H_TX4
         ,H_TX5
         ,H_TX7
         ,H_TX9
         ,H_TX10
         ,H_TX11
         ,H_TX12
         ,H_TX13
      LIMIT l_limit;

    IF contact_pt_cur%NOTFOUND THEN
      l_last_fetch:=TRUE;
    END IF;
    IF H_CPT_PARTY_ID.COUNT=0 AND l_last_fetch THEN
      EXIT;
    END IF;
    FOR I in H_CPT_PARTY_ID.FIRST..H_CPT_PARTY_ID.LAST LOOP

         H_TX14(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_CONTACT_POINT_ID(I),'CONTACT_POINTS','CPT_SOURCE_SYSTEM_REF', 'STAGE');
         H_TX6(I):=HZ_TRANS_PKG.CLEANSED_EMAIL(H_TX5(I),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS','STAGE');
         H_TX8(I):=HZ_TRANS_PKG.CLEANSED_URL(H_TX7(I),NULL, 'URL','CONTACT_POINTS','STAGE');
         H_TX158(I):=HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_TX10(I),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS');
         H_TX1(I):=HZ_TRANS_PKG.RM_SPLCHAR_CTX(H_TX1(I),NULL, 'FLEX_FORMAT_PHONE_NUMBER','CONTACT_POINTS','STAGE');
         H_TX2(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX2(I),NULL, 'PHONE_NUMBER','CONTACT_POINTS','STAGE');
         H_TX3(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX3(I),NULL, 'PHONE_AREA_CODE','CONTACT_POINTS','STAGE');
         H_TX4(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX4(I),NULL, 'PHONE_COUNTRY_CODE','CONTACT_POINTS','STAGE');
         H_TX5(I):=HZ_TRANS_PKG.EXACT_EMAIL(H_TX5(I),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS');
         H_TX7(I):=HZ_TRANS_PKG.EXACT_URL(H_TX7(I),NULL, 'URL','CONTACT_POINTS');
         H_TX9(I):=HZ_TRANS_PKG.EXACT(H_TX9(I),NULL, 'PRIMARY_FLAG','CONTACT_POINTS');
         H_TX10(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX10(I),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS','STAGE');
         H_TX11(I):=HZ_TRANS_PKG.EXACT(H_TX11(I),NULL, 'PHONE_LINE_TYPE','CONTACT_POINTS');
         H_TX12(I):=HZ_TRANS_PKG.EXACT(H_TX12(I),NULL, 'STATUS','CONTACT_POINTS');
         H_TX13(I):=HZ_TRANS_PKG.EXACT(H_TX13(I),NULL, 'CONTACT_POINT_PURPOSE','CONTACT_POINTS');
         H_TX14(I):=HZ_TRANS_PKG.EXACT(H_TX14(I),NULL, 'CPT_SOURCE_SYSTEM_REF','CONTACT_POINTS');
      BEGIN 
        l_denorm := H_TX3(I)
                  || ' ' || H_TX4(I)
             ;
        IF H_CPT_DEN(H_PARTY_INDEX(I)) = 'SYNC' THEN
          NULL;
        ELSIF lengthb(H_CPT_DEN(H_PARTY_INDEX(I)))+lengthb(l_denorm)<2000 THEN
          IF H_CPT_DEN(H_PARTY_INDEX(I)) IS NULL OR instrb(H_CPT_DEN(H_PARTY_INDEX(I)),l_denorm)= 0 THEN
            H_CPT_DEN(H_PARTY_INDEX(I)) := H_CPT_DEN(H_PARTY_INDEX(I)) || ' ' || l_denorm;
          END IF;
        ELSE
          H_CPT_DEN(H_PARTY_INDEX(I)) := 'SYNC';
        END IF;
      EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE=-6502 THEN
          H_CPT_DEN(H_PARTY_INDEX(I)) := 'SYNC';
        END IF; 
      END; 
    END LOOP;
      l_st := 1;  
      l_en := H_CPT_PARTY_ID.COUNT; 
      LOOP 
          BEGIN  
              FORALL I in l_st..l_en
                INSERT INTO HZ_STAGED_CONTACT_POINTS (
	               CONTACT_POINT_ID
	               ,PARTY_ID
	               ,PARTY_SITE_ID
	               ,ORG_CONTACT_ID
	               ,CONTACT_POINT_TYPE
                  ,STATUS_FLAG
                   , TX1
                   , TX2
                   , TX3
                   , TX4
                   , TX5
                   , TX6
                   , TX7
                   , TX8
                   , TX9
                   , TX10
                   , TX11
                   , TX12
                   , TX13
                   , TX14
                   , TX158
                   ) VALUES (
                   H_CONTACT_POINT_ID(I)
                   ,H_CPT_PARTY_ID(I)
                   ,H_CPT_PARTY_SITE_ID(I)
                   ,H_CPT_ORG_CONTACT_ID(I)
                   ,H_CONTACT_POINT_TYPE(I)
                   ,H_STATUS(I)
                  , decode(H_TX1(I),null,H_TX1(I),H_TX1(I)||' ')
                  , decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
                  , decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
                  , decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
                  , decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
                  , decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
                  , decode(H_TX7(I),null,H_TX7(I),H_TX7(I)||' ')
                  , decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
                  , decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
                  , decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
                  , decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
                  , decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
                  , decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
                  , decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
                  , decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
          );
        EXIT; 
        EXCEPTION  WHEN OTHERS THEN 
            l_st:= l_st+SQL%ROWCOUNT+1;
        END; 
      END LOOP; 
      IF l_last_fetch THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE contact_pt_cur;
  END;

  PROCEDURE sync_single_contact_point (
    p_contact_point_id NUMBER,
    p_operation VARCHAR2) IS

  l_tryins BOOLEAN;
  l_tryupd BOOLEAN;
   BEGIN
     SELECT cp.CONTACT_POINT_ID, d.PARTY_ID, d.PARTY_SITE_ID, d.ORG_CONTACT_ID, cp.CONTACT_POINT_TYPE, cp.STATUS 
            ,translate(phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' || translate(phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' ||  translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
            ,cp.PHONE_NUMBER
            ,cp.PHONE_AREA_CODE
            ,cp.PHONE_COUNTRY_CODE
            ,cp.EMAIL_ADDRESS
            ,cp.URL
            ,cp.PRIMARY_FLAG
            ,translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
            ,cp.PHONE_LINE_TYPE
            ,cp.STATUS
            ,cp.CONTACT_POINT_PURPOSE
      INTO H_CONTACT_POINT_ID(1),H_PARTY_ID(1), H_PARTY_SITE_ID(1),H_ORG_CONTACT_ID(1),H_CONTACT_POINT_TYPE(1), H_STATUS(1)
         , H_TX1(1)
         , H_TX2(1)
         , H_TX3(1)
         , H_TX4(1)
         , H_TX5(1)
         , H_TX7(1)
         , H_TX9(1)
         , H_TX10(1)
         , H_TX11(1)
         , H_TX12(1)
         , H_TX13(1)
     FROM HZ_CONTACT_POINTS cp, HZ_DQM_SYNC_INTERFACE d 
     WHERE  d.ENTITY = 'CONTACT_POINTS' 
     AND cp.contact_point_id  =  p_contact_point_id 
     AND cp.contact_point_id  =  d.RECORD_ID 
     AND (cp.status is null OR cp.status = 'A' or cp.status = 'I') and rownum = 1 ; 
    H_TX14(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_CONTACT_POINT_ID(1),'CONTACT_POINTS','CPT_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX6(1):=HZ_TRANS_PKG.CLEANSED_EMAIL(H_TX5(1),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS','STAGE');
    H_TX8(1):=HZ_TRANS_PKG.CLEANSED_URL(H_TX7(1),NULL, 'URL','CONTACT_POINTS','STAGE');
    H_TX158(1):=HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_TX10(1),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS');
    H_TX1(1):=HZ_TRANS_PKG.RM_SPLCHAR_CTX(H_TX1(1),NULL, 'FLEX_FORMAT_PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX2(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX2(1),NULL, 'PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX3(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX3(1),NULL, 'PHONE_AREA_CODE','CONTACT_POINTS','STAGE');
    H_TX4(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX4(1),NULL, 'PHONE_COUNTRY_CODE','CONTACT_POINTS','STAGE');
    H_TX5(1):=HZ_TRANS_PKG.EXACT_EMAIL(H_TX5(1),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS');
    H_TX7(1):=HZ_TRANS_PKG.EXACT_URL(H_TX7(1),NULL, 'URL','CONTACT_POINTS');
    H_TX9(1):=HZ_TRANS_PKG.EXACT(H_TX9(1),NULL, 'PRIMARY_FLAG','CONTACT_POINTS');
    H_TX10(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX10(1),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX11(1):=HZ_TRANS_PKG.EXACT(H_TX11(1),NULL, 'PHONE_LINE_TYPE','CONTACT_POINTS');
    H_TX12(1):=HZ_TRANS_PKG.EXACT(H_TX12(1),NULL, 'STATUS','CONTACT_POINTS');
    H_TX13(1):=HZ_TRANS_PKG.EXACT(H_TX13(1),NULL, 'CONTACT_POINT_PURPOSE','CONTACT_POINTS');
    H_TX14(1):=HZ_TRANS_PKG.EXACT(H_TX14(1),NULL, 'CPT_SOURCE_SYSTEM_REF','CONTACT_POINTS');
   l_tryins := FALSE;
   l_tryupd := FALSE;
   IF p_operation='C' THEN
     l_tryins:=TRUE;
   ELSE 
     l_tryupd:=TRUE;
   END IF;
   WHILE (l_tryins OR l_tryupd) LOOP
     IF l_tryins THEN
       BEGIN
         l_tryins:=FALSE;
         INSERT INTO HZ_STAGED_CONTACT_POINTS (
           CONTACT_POINT_ID
           ,PARTY_ID
           ,PARTY_SITE_ID
           ,ORG_CONTACT_ID
           ,CONTACT_POINT_TYPE
           ,STATUS_FLAG
              , TX1
              , TX2
              , TX3
              , TX4
              , TX5
              , TX6
              , TX7
              , TX8
              , TX9
              , TX10
              , TX11
              , TX12
              , TX13
              , TX14
              , TX158
           ) VALUES (
             H_CONTACT_POINT_ID(1)
            ,H_PARTY_ID(1)
            ,H_PARTY_SITE_ID(1)
            ,H_ORG_CONTACT_ID(1)
            ,H_CONTACT_POINT_TYPE(1)
            ,H_STATUS(1)
             , decode(H_TX1(1),null,H_TX1(1),H_TX1(1)||' ')
             , decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
             , decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
             , decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
             , decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
             , decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
             , decode(H_TX7(1),null,H_TX7(1),H_TX7(1)||' ')
             , decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
             , decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
             , decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
             , decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
             , decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
             , decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
             , decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
             , decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
         );
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           IF p_operation='C' THEN
             l_tryupd:=TRUE;
           END IF;
       END;
     END IF;
     IF l_tryupd THEN
       BEGIN
         l_tryupd:=FALSE;
         UPDATE HZ_STAGED_CONTACT_POINTS SET 
            concat_col = concat_col
           ,status_flag    = H_STATUS(1) 
            ,TX1=decode(H_TX1(1),null,H_TX1(1),H_TX1(1)||' ')
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX3=decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX5=decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,TX6=decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,TX7=decode(H_TX7(1),null,H_TX7(1),H_TX7(1)||' ')
            ,TX8=decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,TX9=decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,TX10=decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX12=decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,TX13=decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,TX14=decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,TX158=decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
         WHERE CONTACT_POINT_ID=H_CONTACT_POINT_ID(1);
         IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
           l_tryins := TRUE;
         END IF;
       EXCEPTION 
         WHEN NO_DATA_FOUND THEN
           IF p_operation='U' THEN
             l_tryins := TRUE;
           END IF;
       END;
     END IF;
   END LOOP;
   --Fix for bug 5048604, to update concat_col during update of denorm column 
   UPDATE HZ_STAGED_PARTIES set
     D_CPT = 'SYNC'
    ,CONCAT_COL = CONCAT_COL 
   WHERE PARTY_ID = H_PARTY_ID(1);
  END;

  PROCEDURE sync_single_cpt_online (
    p_contact_point_id   NUMBER,
    p_operation          VARCHAR2) IS

    l_tryins          BOOLEAN;
    l_tryupd          BOOLEAN;
    l_party_id        NUMBER := 0; 
    l_party_id1       NUMBER; 
    l_org_contact_id  NUMBER; 
    l_party_site_id   NUMBER; 
    l_pr_id           NUMBER; 
    l_num_ocs         NUMBER; 
    l_ot_id           NUMBER; 
    l_ot_table        VARCHAR2(60); 
    l_party_type      VARCHAR2(60); 
    l_sql_err_message VARCHAR2(2000); 

  BEGIN

    l_org_contact_id := -1; 
    l_party_site_id  := -1; 

    SELECT owner_table_name,owner_table_id INTO l_ot_table, l_ot_id 
    FROM hz_contact_points 
    WHERE contact_point_id = p_contact_point_id; 

    IF l_ot_table = 'HZ_PARTY_SITES' THEN 
      SELECT p.party_id, ps.party_site_id, party_type 
      INTO l_party_id1, l_party_site_id, l_party_type 
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p 
      WHERE party_site_id  = l_ot_id 
      AND   p.party_id     = ps.party_id; 

      IF l_party_type = 'PARTY_RELATIONSHIP' THEN 
        BEGIN 
          SELECT r.object_id, org_contact_id INTO l_party_id,l_org_contact_id 
          FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r 
          WHERE r.party_id            = l_party_id1 
          AND   r.relationship_id     = oc.party_relationship_id 
          AND   r.directional_flag    = 'F' 
          AND   r.SUBJECT_TABLE_NAME  = 'HZ_PARTIES' 
          AND   r.OBJECT_TABLE_NAME   = 'HZ_PARTIES'; 
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN 
            RETURN; 
        END; 
      ELSE 
        l_party_id:=l_party_id1; 
        l_org_contact_id:=NULL; 
      END IF; 

    ELSIF l_ot_table = 'HZ_PARTIES' THEN 
      l_party_site_id := NULL; 
      SELECT party_type INTO l_party_type 
      FROM hz_parties 
      WHERE party_id = l_ot_id; 

      IF l_party_type <> 'PARTY_RELATIONSHIP' THEN 
        l_party_id := l_ot_id; 
        l_org_contact_id:=NULL; 
      ELSE 
        BEGIN 
          SELECT r.object_id, org_contact_id INTO l_party_id,l_org_contact_id 
          FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r 
          WHERE r.party_id            = l_ot_id 
          AND   r.relationship_id     = oc.party_relationship_id 
          AND   r.directional_flag    = 'F' 
          AND   r.SUBJECT_TABLE_NAME  = 'HZ_PARTIES' 
          AND   r.OBJECT_TABLE_NAME   = 'HZ_PARTIES'; 
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN 
            RETURN; 
        END; 
      END IF; 
    END IF; 

    SELECT cp.CONTACT_POINT_ID, l_party_id, l_party_site_id, l_org_contact_id, cp.CONTACT_POINT_TYPE, cp.STATUS 
          ,translate(phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' || translate(phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' ||  translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
          ,cp.PHONE_NUMBER
          ,cp.PHONE_AREA_CODE
          ,cp.PHONE_COUNTRY_CODE
          ,cp.EMAIL_ADDRESS
          ,cp.URL
          ,cp.PRIMARY_FLAG
          ,translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
          ,cp.PHONE_LINE_TYPE
          ,cp.STATUS
          ,cp.CONTACT_POINT_PURPOSE
    INTO H_CONTACT_POINT_ID(1),H_PARTY_ID(1), H_PARTY_SITE_ID(1),H_ORG_CONTACT_ID(1),H_CONTACT_POINT_TYPE(1), H_STATUS(1)
        ,H_TX1(1)
        ,H_TX2(1)
        ,H_TX3(1)
        ,H_TX4(1)
        ,H_TX5(1)
        ,H_TX7(1)
        ,H_TX9(1)
        ,H_TX10(1)
        ,H_TX11(1)
        ,H_TX12(1)
        ,H_TX13(1)
    FROM HZ_CONTACT_POINTS cp 
    WHERE 
          cp.contact_point_id  =  p_contact_point_id 
      AND (cp.status is null OR cp.status = 'A' or cp.status = 'I') and rownum = 1 ; 

    H_TX14(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_CONTACT_POINT_ID(1),'CONTACT_POINTS','CPT_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX6(1):=HZ_TRANS_PKG.CLEANSED_EMAIL(H_TX5(1),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS','STAGE');
    H_TX8(1):=HZ_TRANS_PKG.CLEANSED_URL(H_TX7(1),NULL, 'URL','CONTACT_POINTS','STAGE');
    H_TX158(1):=HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_TX10(1),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS');
    H_TX1(1):=HZ_TRANS_PKG.RM_SPLCHAR_CTX(H_TX1(1),NULL, 'FLEX_FORMAT_PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX2(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX2(1),NULL, 'PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX3(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX3(1),NULL, 'PHONE_AREA_CODE','CONTACT_POINTS','STAGE');
    H_TX4(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX4(1),NULL, 'PHONE_COUNTRY_CODE','CONTACT_POINTS','STAGE');
    H_TX5(1):=HZ_TRANS_PKG.EXACT_EMAIL(H_TX5(1),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS');
    H_TX7(1):=HZ_TRANS_PKG.EXACT_URL(H_TX7(1),NULL, 'URL','CONTACT_POINTS');
    H_TX9(1):=HZ_TRANS_PKG.EXACT(H_TX9(1),NULL, 'PRIMARY_FLAG','CONTACT_POINTS');
    H_TX10(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX10(1),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS','STAGE');
    H_TX11(1):=HZ_TRANS_PKG.EXACT(H_TX11(1),NULL, 'PHONE_LINE_TYPE','CONTACT_POINTS');
    H_TX12(1):=HZ_TRANS_PKG.EXACT(H_TX12(1),NULL, 'STATUS','CONTACT_POINTS');
    H_TX13(1):=HZ_TRANS_PKG.EXACT(H_TX13(1),NULL, 'CONTACT_POINT_PURPOSE','CONTACT_POINTS');
    H_TX14(1):=HZ_TRANS_PKG.EXACT(H_TX14(1),NULL, 'CPT_SOURCE_SYSTEM_REF','CONTACT_POINTS');

    l_tryins := FALSE;
    l_tryupd := FALSE;

    IF p_operation='C' THEN
      l_tryins:=TRUE;
    ELSE 
      l_tryupd:=TRUE;
    END IF;

    WHILE (l_tryins OR l_tryupd) LOOP
      IF l_tryins THEN
        BEGIN
          l_tryins:=FALSE;
          INSERT INTO HZ_STAGED_CONTACT_POINTS (
             CONTACT_POINT_ID
            ,PARTY_ID
            ,PARTY_SITE_ID
            ,ORG_CONTACT_ID
            ,CONTACT_POINT_TYPE
            ,STATUS_FLAG
            ,TX1
            ,TX2
            ,TX3
            ,TX4
            ,TX5
            ,TX6
            ,TX7
            ,TX8
            ,TX9
            ,TX10
            ,TX11
            ,TX12
            ,TX13
            ,TX14
            ,TX158
          ) VALUES (
             H_CONTACT_POINT_ID(1)
            ,H_PARTY_ID(1)
            ,H_PARTY_SITE_ID(1)
            ,H_ORG_CONTACT_ID(1)
            ,H_CONTACT_POINT_TYPE(1)
            ,H_STATUS(1)
            ,decode(H_TX1(1),null,H_TX1(1),H_TX1(1)||' ')
            ,decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,decode(H_TX7(1),null,H_TX7(1),H_TX7(1)||' ')
            ,decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
          );
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            IF p_operation='C' THEN
              l_tryupd:=TRUE;
            END IF;
        END;
      END IF;

      IF l_tryupd THEN
        BEGIN
          l_tryupd:=FALSE;
          UPDATE HZ_STAGED_CONTACT_POINTS SET 
             concat_col = concat_col
            ,status_flag = H_STATUS(1) 
            ,TX1=decode(H_TX1(1),null,H_TX1(1),H_TX1(1)||' ')
            ,TX2=decode(H_TX2(1),null,H_TX2(1),H_TX2(1)||' ')
            ,TX3=decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX5=decode(H_TX5(1),null,H_TX5(1),H_TX5(1)||' ')
            ,TX6=decode(H_TX6(1),null,H_TX6(1),H_TX6(1)||' ')
            ,TX7=decode(H_TX7(1),null,H_TX7(1),H_TX7(1)||' ')
            ,TX8=decode(H_TX8(1),null,H_TX8(1),H_TX8(1)||' ')
            ,TX9=decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,TX10=decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX12=decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,TX13=decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,TX14=decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,TX158=decode(H_TX158(1),null,H_TX158(1),H_TX158(1)||' ')
          WHERE CONTACT_POINT_ID=H_CONTACT_POINT_ID(1);
          IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
            l_tryins := TRUE;
          END IF;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN
            IF p_operation='U' THEN
              l_tryins := TRUE;
            END IF;
        END;
      END IF;
    END LOOP;

    --Fix for bug 5048604, to update concat_col during update of denorm column 
    UPDATE HZ_STAGED_PARTIES set
      D_CPT = 'SYNC'
     ,CONCAT_COL = CONCAT_COL 
    WHERE PARTY_ID = H_PARTY_ID(1);

      -- REPURI. Bug 4884742. If shadow staging is completely successfully 
      -- insert a record into hz_dqm_sh_sync_interface table for each record 
    IF (HZ_DQM_SYNC.is_shadow_staging_complete) THEN 
      BEGIN 
        HZ_DQM_SYNC.insert_sh_interface_rec(l_party_id,p_contact_point_id,l_party_site_id, l_org_contact_id, 'CONTACT_POINTS',p_operation); 
      EXCEPTION WHEN OTHERS THEN 
        NULL; 
      END; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    -- FAILOVER : REPORT RECORD TO HZ_DQM_SYNC_INTERFACE 
    -- FOR ONLINE FLOWS 
    l_sql_err_message := SQLERRM; 
    insert_dqm_sync_error_rec(l_party_id, p_contact_point_id, l_party_site_id, l_org_contact_id, 'CONTACT_POINTS', p_operation, 'E', 'Y', l_sql_err_message); 
  END;

  PROCEDURE insert_stage_party_sites IS 
  l_limit NUMBER := 200;
  l_last_fetch BOOLEAN := FALSE;
  l_denorm VARCHAR2(2000);
  l_st number; 
  l_en number; 
 
    CURSOR party_site_cur IS
            SELECT /*+ ORDERED USE_NL(ps l) */ ps.PARTY_SITE_ID, g.party_id, g.org_contact_id, g.PARTY_INDEX, ps.status 
                  ,rtrim(l.address1 || ' ' || l.address2 || ' ' || l.address3 || ' ' || l.address4)
                  ,l.CITY
                  ,l.POSTAL_CODE
                  ,l.PROVINCE
                  ,l.STATE
                  ,ps.PARTY_SITE_NUMBER
                  ,ps.PARTY_SITE_NAME
                  ,l.COUNTY
                  ,l.COUNTRY
                  ,ps.IDENTIFYING_ADDRESS_FLAG
                  ,ps.STATUS
                  ,l.ADDRESS1
            FROM HZ_DQM_STAGE_GT g, HZ_PARTY_SITES ps, HZ_LOCATIONS l
            WHERE ps.PARTY_ID = g.owner_id 
            AND (ps.status is null OR ps.status = 'A' OR ps.status = 'I')    
            AND ps.location_id = l.location_id; 
  BEGIN
    OPEN party_site_cur;
    LOOP
      FETCH party_site_cur BULK COLLECT INTO
        H_PARTY_SITE_ID
        ,H_PS_PARTY_ID
        ,H_PS_ORG_CONTACT_ID
        ,H_PARTY_INDEX
        ,H_STATUS
         ,H_TX3
         ,H_TX9
         ,H_TX11
         ,H_TX12
         ,H_TX14
         ,H_TX17
         ,H_TX18
         ,H_TX20
         ,H_TX22
         ,H_TX24
         ,H_TX25
         ,H_TX28
      LIMIT l_limit;

    IF party_site_cur%NOTFOUND THEN
      l_last_fetch:=TRUE;
    END IF;
    IF H_PS_PARTY_ID.COUNT=0 AND l_last_fetch THEN
      EXIT;
    END IF;
    FOR I in H_PS_PARTY_ID.FIRST..H_PS_PARTY_ID.LAST LOOP
----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ---------

     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_TX22(I));
         H_TX30(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_PARTY_SITE_ID(I),'PARTY_SITES','ADDR_SOURCE_SYSTEM_REF', 'STAGE');
         H_TX4(I):=HZ_TRANS_PKG.WRADDRESS_CLEANSE(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
         H_TX10(I):=HZ_TRANS_PKG.CLEANSE(H_TX9(I),NULL, 'CITY','PARTY_SITES');
         H_TX13(I):=HZ_TRANS_PKG.CLEANSE(H_TX12(I),NULL, 'PROVINCE','PARTY_SITES');
         H_TX15(I):=HZ_TRANS_PKG.WRSTATE_CLEANSE(H_TX14(I),NULL, 'STATE','PARTY_SITES','STAGE');
         H_TX19(I):=HZ_TRANS_PKG.CLEANSE(H_TX18(I),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
         H_TX21(I):=HZ_TRANS_PKG.CLEANSE(H_TX20(I),NULL, 'COUNTY','PARTY_SITES');
         H_TX26(I):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
         H_TX27(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
         H_TX29(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX28(I),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
         H_TX3(I):=HZ_TRANS_PKG.WRADDRESS_EXACT(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
         H_TX9(I):=HZ_TRANS_PKG.EXACT(H_TX9(I),NULL, 'CITY','PARTY_SITES');
         H_TX11(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'POSTAL_CODE','PARTY_SITES','STAGE');
         H_TX12(I):=HZ_TRANS_PKG.EXACT(H_TX12(I),NULL, 'PROVINCE','PARTY_SITES');
         H_TX14(I):=HZ_TRANS_PKG.WRSTATE_EXACT(H_TX14(I),NULL, 'STATE','PARTY_SITES','STAGE');
         H_TX17(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX17(I),NULL, 'PARTY_SITE_NUMBER','PARTY_SITES','STAGE');
         H_TX18(I):=HZ_TRANS_PKG.EXACT(H_TX18(I),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
         H_TX20(I):=HZ_TRANS_PKG.EXACT(H_TX20(I),NULL, 'COUNTY','PARTY_SITES');
         H_TX22(I):=HZ_TRANS_PKG.EXACT(H_TX22(I),NULL, 'COUNTRY','PARTY_SITES');
         H_TX24(I):=HZ_TRANS_PKG.EXACT(H_TX24(I),NULL, 'IDENTIFYING_ADDRESS_FLAG','PARTY_SITES');
         H_TX25(I):=HZ_TRANS_PKG.EXACT(H_TX25(I),NULL, 'STATUS','PARTY_SITES');
         H_TX28(I):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX28(I),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
         H_TX30(I):=HZ_TRANS_PKG.EXACT(H_TX30(I),NULL, 'ADDR_SOURCE_SYSTEM_REF','PARTY_SITES');
      BEGIN 
        l_denorm := H_TX9(I)
                  || ' ' ||  H_TX10(I)
                  || ' ' ||  H_TX11(I)
                  || ' ' ||  H_TX12(I)
                  || ' ' ||  H_TX13(I)
                  || ' ' ||  H_TX14(I)
                  || ' ' ||  H_TX15(I)
                  || ' ' ||  H_TX20(I)
                  || ' ' ||  H_TX21(I)
                  || ' ' ||  H_TX22(I)
             ;
         IF H_PS_DEN(H_PARTY_INDEX(I)) = 'SYNC' THEN
            NULL;
         ELSIF lengthb(H_PS_DEN(H_PARTY_INDEX(I)))+lengthb(l_denorm)<2000 THEN
           IF H_PS_DEN(H_PARTY_INDEX(I)) IS NULL OR instrb(H_PS_DEN(H_PARTY_INDEX(I)),l_denorm)=0 THEN
             H_PS_DEN(H_PARTY_INDEX(I)) := H_PS_DEN(H_PARTY_INDEX(I)) || ' ' || l_denorm;
           END IF;
         ELSE
           H_PS_DEN(H_PARTY_INDEX(I)) := 'SYNC';
         END IF;
      EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE=-6502 THEN
          H_PS_DEN(H_PARTY_INDEX(I)) := 'SYNC';
        END IF; 
      END; 
    END LOOP;
      l_st := 1;  
      l_en :=  H_PS_PARTY_ID.COUNT; 
      LOOP 
          BEGIN  
          FORALL I in l_st..l_en
             INSERT INTO HZ_STAGED_PARTY_SITES (
	              PARTY_SITE_ID
	              ,PARTY_ID
	              ,ORG_CONTACT_ID
                 ,STATUS_FLAG
                 , TX3
                 , TX4
                 , TX9
                 , TX10
                 , TX11
                 , TX12
                 , TX13
                 , TX14
                 , TX15
                 , TX17
                 , TX18
                 , TX19
                 , TX20
                 , TX21
                 , TX22
                 , TX24
                 , TX25
                 , TX26
                 , TX27
                 , TX28
                 , TX29
                 , TX30
                 ) VALUES (
                 H_PARTY_SITE_ID(I)
                ,H_PS_PARTY_ID(I)
                ,H_PS_ORG_CONTACT_ID(I)
                ,H_STATUS(I)
                 , decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
                 , decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
                 , decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
                 , decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
                 , decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
                 , decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
                 , decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
                 , decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
                 , decode(H_TX15(I),null,H_TX15(I),H_TX15(I)||' ')
                 , decode(H_TX17(I),null,H_TX17(I),H_TX17(I)||' ')
                 , decode(H_TX18(I),null,H_TX18(I),H_TX18(I)||' ')
                 , decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
                 , decode(H_TX20(I),null,H_TX20(I),H_TX20(I)||' ')
                 , decode(H_TX21(I),null,H_TX21(I),H_TX21(I)||' ')
                 , decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
                 , decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
                 , decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
                 , decode(H_TX26(I),null,H_TX26(I),H_TX26(I)||' ')
                 , decode(H_TX27(I),null,H_TX27(I),H_TX27(I)||' ')
                 , decode(H_TX28(I),null,H_TX28(I),H_TX28(I)||' ')
                 , decode(H_TX29(I),null,H_TX29(I),H_TX29(I)||' ')
                 , decode(H_TX30(I),null,H_TX30(I),H_TX30(I)||' ')
        );
        EXIT; 
        EXCEPTION  WHEN OTHERS THEN 
            l_st:= l_st+SQL%ROWCOUNT+1;
        END; 
      END LOOP; 
      FORALL I in H_PS_PARTY_ID.FIRST..H_PS_PARTY_ID.LAST 
        INSERT INTO HZ_DQM_STAGE_GT (PARTY_ID, OWNER_ID, OWNER_TABLE, PARTY_SITE_ID,
                                     ORG_CONTACT_ID,PARTY_INDEX) VALUES (
        H_PS_PARTY_ID(I),H_PARTY_SITE_ID(I),'HZ_PARTY_SITES',H_PARTY_SITE_ID(I),
         H_PS_ORG_CONTACT_ID(I),H_PARTY_INDEX(I));
      IF l_last_fetch THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE party_site_cur;
  END;

  PROCEDURE sync_single_party_site (
    p_party_site_id NUMBER,
    p_operation VARCHAR2) IS

  l_tryins BOOLEAN;
  l_tryupd BOOLEAN;
   BEGIN
     SELECT ps.PARTY_SITE_ID, d.party_id, d.org_contact_id, ps.STATUS 
                  ,rtrim(l.address1 || ' ' || l.address2 || ' ' || l.address3 || ' ' || l.address4)
                  ,l.CITY
                  ,l.POSTAL_CODE
                  ,l.PROVINCE
                  ,l.STATE
                  ,ps.PARTY_SITE_NUMBER
                  ,ps.PARTY_SITE_NAME
                  ,l.COUNTY
                  ,l.COUNTRY
                  ,ps.IDENTIFYING_ADDRESS_FLAG
                  ,ps.STATUS
                  ,l.ADDRESS1
      INTO H_PARTY_SITE_ID(1), H_PARTY_ID(1), H_ORG_CONTACT_ID(1), H_STATUS(1)
         , H_TX3(1)
         , H_TX9(1)
         , H_TX11(1)
         , H_TX12(1)
         , H_TX14(1)
         , H_TX17(1)
         , H_TX18(1)
         , H_TX20(1)
         , H_TX22(1)
         , H_TX24(1)
         , H_TX25(1)
         , H_TX28(1)
     FROM HZ_PARTY_SITES ps, HZ_DQM_SYNC_INTERFACE d, HZ_LOCATIONS l 
     WHERE d.ENTITY='PARTY_SITES' 
     AND ps.party_site_id = p_party_site_id
     AND d.record_id = ps.party_site_id 
     AND ps.location_id = l.location_id 
     AND (ps.status is null OR ps.status = 'A' OR ps.status = 'I')    
     AND ROWNUM=1;
----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ---------
     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_TX22(1));
    H_TX30(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_PARTY_SITE_ID(1),'PARTY_SITES','ADDR_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX4(1):=HZ_TRANS_PKG.WRADDRESS_CLEANSE(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX10(1):=HZ_TRANS_PKG.CLEANSE(H_TX9(1),NULL, 'CITY','PARTY_SITES');
    H_TX13(1):=HZ_TRANS_PKG.CLEANSE(H_TX12(1),NULL, 'PROVINCE','PARTY_SITES');
    H_TX15(1):=HZ_TRANS_PKG.WRSTATE_CLEANSE(H_TX14(1),NULL, 'STATE','PARTY_SITES','STAGE');
    H_TX19(1):=HZ_TRANS_PKG.CLEANSE(H_TX18(1),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
    H_TX21(1):=HZ_TRANS_PKG.CLEANSE(H_TX20(1),NULL, 'COUNTY','PARTY_SITES');
    H_TX26(1):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX27(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX29(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX28(1),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
    H_TX3(1):=HZ_TRANS_PKG.WRADDRESS_EXACT(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX9(1):=HZ_TRANS_PKG.EXACT(H_TX9(1),NULL, 'CITY','PARTY_SITES');
    H_TX11(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(1),NULL, 'POSTAL_CODE','PARTY_SITES','STAGE');
    H_TX12(1):=HZ_TRANS_PKG.EXACT(H_TX12(1),NULL, 'PROVINCE','PARTY_SITES');
    H_TX14(1):=HZ_TRANS_PKG.WRSTATE_EXACT(H_TX14(1),NULL, 'STATE','PARTY_SITES','STAGE');
    H_TX17(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX17(1),NULL, 'PARTY_SITE_NUMBER','PARTY_SITES','STAGE');
    H_TX18(1):=HZ_TRANS_PKG.EXACT(H_TX18(1),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
    H_TX20(1):=HZ_TRANS_PKG.EXACT(H_TX20(1),NULL, 'COUNTY','PARTY_SITES');
    H_TX22(1):=HZ_TRANS_PKG.EXACT(H_TX22(1),NULL, 'COUNTRY','PARTY_SITES');
    H_TX24(1):=HZ_TRANS_PKG.EXACT(H_TX24(1),NULL, 'IDENTIFYING_ADDRESS_FLAG','PARTY_SITES');
    H_TX25(1):=HZ_TRANS_PKG.EXACT(H_TX25(1),NULL, 'STATUS','PARTY_SITES');
    H_TX28(1):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX28(1),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
    H_TX30(1):=HZ_TRANS_PKG.EXACT(H_TX30(1),NULL, 'ADDR_SOURCE_SYSTEM_REF','PARTY_SITES');
   l_tryins := FALSE;
   l_tryupd := FALSE;
   IF p_operation='C' THEN
     l_tryins:=TRUE;
   ELSE 
     l_tryupd:=TRUE;
   END IF;
   WHILE (l_tryins OR l_tryupd) LOOP
     IF l_tryins THEN
       BEGIN
         l_tryins:=FALSE;
         INSERT INTO HZ_STAGED_PARTY_SITES (
           PARTY_SITE_ID
           ,PARTY_ID
           ,ORG_CONTACT_ID
           ,STATUS_FLAG
              , TX3
              , TX4
              , TX9
              , TX10
              , TX11
              , TX12
              , TX13
              , TX14
              , TX15
              , TX17
              , TX18
              , TX19
              , TX20
              , TX21
              , TX22
              , TX24
              , TX25
              , TX26
              , TX27
              , TX28
              , TX29
              , TX30
           ) VALUES (
            H_PARTY_SITE_ID(1)
            ,H_PARTY_ID(1)
            ,H_ORG_CONTACT_ID(1)
            ,H_STATUS(1)
             , decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
             , decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
             , decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
             , decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
             , decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
             , decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
             , decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
             , decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
             , decode(H_TX15(1),null,H_TX15(1),H_TX15(1)||' ')
             , decode(H_TX17(1),null,H_TX17(1),H_TX17(1)||' ')
             , decode(H_TX18(1),null,H_TX18(1),H_TX18(1)||' ')
             , decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
             , decode(H_TX20(1),null,H_TX20(1),H_TX20(1)||' ')
             , decode(H_TX21(1),null,H_TX21(1),H_TX21(1)||' ')
             , decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
             , decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
             , decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
             , decode(H_TX26(1),null,H_TX26(1),H_TX26(1)||' ')
             , decode(H_TX27(1),null,H_TX27(1),H_TX27(1)||' ')
             , decode(H_TX28(1),null,H_TX28(1),H_TX28(1)||' ')
             , decode(H_TX29(1),null,H_TX29(1),H_TX29(1)||' ')
             , decode(H_TX30(1),null,H_TX30(1),H_TX30(1)||' ')
         );
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           IF p_operation='C' THEN
             l_tryupd:=TRUE;
           END IF;
       END;
     END IF;
     IF l_tryupd THEN
       BEGIN
         l_tryupd:=FALSE;
         UPDATE HZ_STAGED_PARTY_SITES SET 
            concat_col = concat_col
           ,status_flag = H_STATUS(1)
            ,TX3=decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX9=decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,TX10=decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX12=decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,TX13=decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,TX14=decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,TX15=decode(H_TX15(1),null,H_TX15(1),H_TX15(1)||' ')
            ,TX17=decode(H_TX17(1),null,H_TX17(1),H_TX17(1)||' ')
            ,TX18=decode(H_TX18(1),null,H_TX18(1),H_TX18(1)||' ')
            ,TX19=decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,TX20=decode(H_TX20(1),null,H_TX20(1),H_TX20(1)||' ')
            ,TX21=decode(H_TX21(1),null,H_TX21(1),H_TX21(1)||' ')
            ,TX22=decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,TX24=decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,TX25=decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,TX26=decode(H_TX26(1),null,H_TX26(1),H_TX26(1)||' ')
            ,TX27=decode(H_TX27(1),null,H_TX27(1),H_TX27(1)||' ')
            ,TX28=decode(H_TX28(1),null,H_TX28(1),H_TX28(1)||' ')
            ,TX29=decode(H_TX29(1),null,H_TX29(1),H_TX29(1)||' ')
            ,TX30=decode(H_TX30(1),null,H_TX30(1),H_TX30(1)||' ')
         WHERE PARTY_SITE_ID=H_PARTY_SITE_ID(1);
         IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
           l_tryins := TRUE;
         END IF;
       EXCEPTION 
         WHEN NO_DATA_FOUND THEN
           IF p_operation='U' THEN
             l_tryins := TRUE;
           END IF;
       END;
     END IF;
   END LOOP;
   --Fix for bug 5048604, to update concat_col during update of denorm column 
   UPDATE HZ_STAGED_PARTIES set 
     D_PS = 'SYNC' 
    ,CONCAT_COL = CONCAT_COL 
   WHERE PARTY_ID = H_PARTY_ID(1); 
  END;

  PROCEDURE sync_single_party_site_online (
    p_party_site_id   NUMBER,
    p_operation       VARCHAR2) IS

    l_tryins          BOOLEAN;
    l_tryupd          BOOLEAN;
    l_party_id        NUMBER; 
    l_party_id1       NUMBER; 
    l_org_contact_id  NUMBER; 
    l_party_type      VARCHAR2(255); 
    l_sql_err_message VARCHAR2(2000); 

  BEGIN

    l_party_id        := -1; 
    l_org_contact_id  := -1; 

    BEGIN 
      SELECT ps.party_id,p.party_type INTO l_party_id1, l_party_type 
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p 
      WHERE party_site_id  = p_party_site_id 
      AND   p.PARTY_ID     = ps.PARTY_ID; 
    -- take care of invalid party ids 
    EXCEPTION  
      WHEN NO_DATA_FOUND THEN 
        -- dbms_output.put_line ( 'Exception caught in party_site '); 
        RETURN; 
    END; 

    IF l_party_type = 'PARTY_RELATIONSHIP' THEN 
      BEGIN 
        SELECT r.object_id, org_contact_id INTO l_party_id,l_org_contact_id 
        FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r 
        WHERE r.party_id            = l_party_id1 
        AND   r.relationship_id     = oc.party_relationship_id 
        AND   r.directional_flag    = 'F' 
        AND   r.SUBJECT_TABLE_NAME  = 'HZ_PARTIES' 
        AND   r.OBJECT_TABLE_NAME   = 'HZ_PARTIES'; 
      -- take care of invalid identifiers 
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
          -- dbms_output.put_line ( 'Exception caught in party_rel '); 
          RETURN; 
      END; 
    ELSE 
      l_party_id :=l_party_id1; 
      l_org_contact_id:=NULL; 
    END IF; 

    SELECT ps.PARTY_SITE_ID, l_party_id, l_org_contact_id, ps.STATUS 
          ,rtrim(l.address1 || ' ' || l.address2 || ' ' || l.address3 || ' ' || l.address4)
          ,l.CITY
          ,l.POSTAL_CODE
          ,l.PROVINCE
          ,l.STATE
          ,ps.PARTY_SITE_NUMBER
          ,ps.PARTY_SITE_NAME
          ,l.COUNTY
          ,l.COUNTRY
          ,ps.IDENTIFYING_ADDRESS_FLAG
          ,ps.STATUS
          ,l.ADDRESS1
    INTO H_PARTY_SITE_ID(1), H_PARTY_ID(1), H_ORG_CONTACT_ID(1), H_STATUS(1)
        ,H_TX3(1)
        ,H_TX9(1)
        ,H_TX11(1)
        ,H_TX12(1)
        ,H_TX14(1)
        ,H_TX17(1)
        ,H_TX18(1)
        ,H_TX20(1)
        ,H_TX22(1)
        ,H_TX24(1)
        ,H_TX25(1)
        ,H_TX28(1)
    FROM HZ_PARTY_SITES ps, HZ_LOCATIONS l 
    WHERE 
          ps.party_site_id = p_party_site_id
     AND  ps.location_id = l.location_id 
     AND  (ps.status is null OR ps.status = 'A' OR ps.status = 'I')    
     AND  ROWNUM=1;

    ---- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ----
    HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_TX22(1));
    H_TX30(1):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_PARTY_SITE_ID(1),'PARTY_SITES','ADDR_SOURCE_SYSTEM_REF', 'STAGE');
    H_TX4(1):=HZ_TRANS_PKG.WRADDRESS_CLEANSE(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX10(1):=HZ_TRANS_PKG.CLEANSE(H_TX9(1),NULL, 'CITY','PARTY_SITES');
    H_TX13(1):=HZ_TRANS_PKG.CLEANSE(H_TX12(1),NULL, 'PROVINCE','PARTY_SITES');
    H_TX15(1):=HZ_TRANS_PKG.WRSTATE_CLEANSE(H_TX14(1),NULL, 'STATE','PARTY_SITES','STAGE');
    H_TX19(1):=HZ_TRANS_PKG.CLEANSE(H_TX18(1),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
    H_TX21(1):=HZ_TRANS_PKG.CLEANSE(H_TX20(1),NULL, 'COUNTY','PARTY_SITES');
    H_TX26(1):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX27(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX29(1):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX28(1),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
    H_TX3(1):=HZ_TRANS_PKG.WRADDRESS_EXACT(H_TX3(1),NULL, 'ADDRESS','PARTY_SITES','STAGE');
    H_TX9(1):=HZ_TRANS_PKG.EXACT(H_TX9(1),NULL, 'CITY','PARTY_SITES');
    H_TX11(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(1),NULL, 'POSTAL_CODE','PARTY_SITES','STAGE');
    H_TX12(1):=HZ_TRANS_PKG.EXACT(H_TX12(1),NULL, 'PROVINCE','PARTY_SITES');
    H_TX14(1):=HZ_TRANS_PKG.WRSTATE_EXACT(H_TX14(1),NULL, 'STATE','PARTY_SITES','STAGE');
    H_TX17(1):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX17(1),NULL, 'PARTY_SITE_NUMBER','PARTY_SITES','STAGE');
    H_TX18(1):=HZ_TRANS_PKG.EXACT(H_TX18(1),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
    H_TX20(1):=HZ_TRANS_PKG.EXACT(H_TX20(1),NULL, 'COUNTY','PARTY_SITES');
    H_TX22(1):=HZ_TRANS_PKG.EXACT(H_TX22(1),NULL, 'COUNTRY','PARTY_SITES');
    H_TX24(1):=HZ_TRANS_PKG.EXACT(H_TX24(1),NULL, 'IDENTIFYING_ADDRESS_FLAG','PARTY_SITES');
    H_TX25(1):=HZ_TRANS_PKG.EXACT(H_TX25(1),NULL, 'STATUS','PARTY_SITES');
    H_TX28(1):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX28(1),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
    H_TX30(1):=HZ_TRANS_PKG.EXACT(H_TX30(1),NULL, 'ADDR_SOURCE_SYSTEM_REF','PARTY_SITES');

    l_tryins := FALSE;
    l_tryupd := FALSE;

    IF p_operation='C' THEN
      l_tryins:=TRUE;
    ELSE 
      l_tryupd:=TRUE;
    END IF;

    WHILE (l_tryins OR l_tryupd) LOOP
      IF l_tryins THEN
        BEGIN
          l_tryins:=FALSE;
          INSERT INTO HZ_STAGED_PARTY_SITES (
             PARTY_SITE_ID
            ,PARTY_ID
            ,ORG_CONTACT_ID
            ,STATUS_FLAG
            ,TX3
            ,TX4
            ,TX9
            ,TX10
            ,TX11
            ,TX12
            ,TX13
            ,TX14
            ,TX15
            ,TX17
            ,TX18
            ,TX19
            ,TX20
            ,TX21
            ,TX22
            ,TX24
            ,TX25
            ,TX26
            ,TX27
            ,TX28
            ,TX29
            ,TX30
          ) VALUES (
             H_PARTY_SITE_ID(1)
            ,H_PARTY_ID(1)
            ,H_ORG_CONTACT_ID(1)
            ,H_STATUS(1)
            ,decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,decode(H_TX15(1),null,H_TX15(1),H_TX15(1)||' ')
            ,decode(H_TX17(1),null,H_TX17(1),H_TX17(1)||' ')
            ,decode(H_TX18(1),null,H_TX18(1),H_TX18(1)||' ')
            ,decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,decode(H_TX20(1),null,H_TX20(1),H_TX20(1)||' ')
            ,decode(H_TX21(1),null,H_TX21(1),H_TX21(1)||' ')
            ,decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,decode(H_TX26(1),null,H_TX26(1),H_TX26(1)||' ')
            ,decode(H_TX27(1),null,H_TX27(1),H_TX27(1)||' ')
            ,decode(H_TX28(1),null,H_TX28(1),H_TX28(1)||' ')
            ,decode(H_TX29(1),null,H_TX29(1),H_TX29(1)||' ')
            ,decode(H_TX30(1),null,H_TX30(1),H_TX30(1)||' ')
          );
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            IF p_operation='C' THEN
              l_tryupd:=TRUE;
            END IF;
        END;
      END IF;

      IF l_tryupd THEN
        BEGIN
          l_tryupd:=FALSE;
          UPDATE HZ_STAGED_PARTY_SITES SET 
             concat_col = concat_col
            ,status_flag = H_STATUS(1)
            ,TX3=decode(H_TX3(1),null,H_TX3(1),H_TX3(1)||' ')
            ,TX4=decode(H_TX4(1),null,H_TX4(1),H_TX4(1)||' ')
            ,TX9=decode(H_TX9(1),null,H_TX9(1),H_TX9(1)||' ')
            ,TX10=decode(H_TX10(1),null,H_TX10(1),H_TX10(1)||' ')
            ,TX11=decode(H_TX11(1),null,H_TX11(1),H_TX11(1)||' ')
            ,TX12=decode(H_TX12(1),null,H_TX12(1),H_TX12(1)||' ')
            ,TX13=decode(H_TX13(1),null,H_TX13(1),H_TX13(1)||' ')
            ,TX14=decode(H_TX14(1),null,H_TX14(1),H_TX14(1)||' ')
            ,TX15=decode(H_TX15(1),null,H_TX15(1),H_TX15(1)||' ')
            ,TX17=decode(H_TX17(1),null,H_TX17(1),H_TX17(1)||' ')
            ,TX18=decode(H_TX18(1),null,H_TX18(1),H_TX18(1)||' ')
            ,TX19=decode(H_TX19(1),null,H_TX19(1),H_TX19(1)||' ')
            ,TX20=decode(H_TX20(1),null,H_TX20(1),H_TX20(1)||' ')
            ,TX21=decode(H_TX21(1),null,H_TX21(1),H_TX21(1)||' ')
            ,TX22=decode(H_TX22(1),null,H_TX22(1),H_TX22(1)||' ')
            ,TX24=decode(H_TX24(1),null,H_TX24(1),H_TX24(1)||' ')
            ,TX25=decode(H_TX25(1),null,H_TX25(1),H_TX25(1)||' ')
            ,TX26=decode(H_TX26(1),null,H_TX26(1),H_TX26(1)||' ')
            ,TX27=decode(H_TX27(1),null,H_TX27(1),H_TX27(1)||' ')
            ,TX28=decode(H_TX28(1),null,H_TX28(1),H_TX28(1)||' ')
            ,TX29=decode(H_TX29(1),null,H_TX29(1),H_TX29(1)||' ')
            ,TX30=decode(H_TX30(1),null,H_TX30(1),H_TX30(1)||' ')
          WHERE PARTY_SITE_ID=H_PARTY_SITE_ID(1);
          IF SQL%ROWCOUNT=0 AND p_operation='U' THEN
            l_tryins := TRUE;
          END IF;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN
            IF p_operation='U' THEN
              l_tryins := TRUE;
            END IF;
        END;
      END IF;
    END LOOP;

    --Fix for bug 5048604, to update concat_col during update of denorm column 
    UPDATE HZ_STAGED_PARTIES set
      D_PS = 'SYNC'
     ,CONCAT_COL = CONCAT_COL 
    WHERE PARTY_ID = H_PARTY_ID(1);

      -- REPURI. Bug 4884742. If shadow staging is completely successfully 
      -- insert a record into hz_dqm_sh_sync_interface table for each record 
    IF (HZ_DQM_SYNC.is_shadow_staging_complete) THEN 
      BEGIN 
        HZ_DQM_SYNC.insert_sh_interface_rec(l_party_id,p_party_site_id,null,l_org_contact_id,'PARTY_SITES',p_operation); 
      EXCEPTION WHEN OTHERS THEN 
        NULL; 
      END; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    -- FAILOVER : REPORT RECORD TO HZ_DQM_SYNC_INTERFACE 
    -- FOR ONLINE FLOWS 
    l_sql_err_message := SQLERRM; 
    insert_dqm_sync_error_rec(l_party_id, p_party_site_id, NULL, l_org_contact_id, 'PARTY_SITES', p_operation, 'E', 'Y', l_sql_err_message); 
  END;

  PROCEDURE open_sync_party_cursor( 
    p_operation       IN      VARCHAR2,
    p_party_type      IN      VARCHAR2,
    p_from_rec        IN      VARCHAR2,
    p_to_rec          IN      VARCHAR2,
    x_sync_party_cur  IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 

  BEGIN

    IF p_party_type = 'ORGANIZATION' THEN
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, dsi.ROWID 
              ,p.PARTY_NAME
              ,p.PARTY_NUMBER
              ,p.PARTY_TYPE
              ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
              ,op.DUNS_NUMBER_C
              ,op.TAX_NAME
              ,op.TAX_REFERENCE
              ,op.JGZZ_FISCAL_CODE
              ,op.SIC_CODE
              ,op.SIC_CODE_TYPE
              ,p.CATEGORY_CODE
              ,p.REFERENCE_USE_FLAG
              ,op.CORPORATION_CLASS
        FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op, HZ_DQM_SYNC_INTERFACE dsi 
        WHERE p.party_id      = op.party_id 
        AND   p.party_id      = dsi.party_id 
        AND   p.PARTY_TYPE    = 'ORGANIZATION' 
        AND   dsi.entity      = 'PARTY' 
        AND   dsi.staged_flag = 'N' 
        AND   dsi.operation   = p_operation 
        AND   dsi.sync_interface_num >= p_from_rec 
        AND   dsi.sync_interface_num <= p_to_rec 
        AND   (p.status = 'M' or op.effective_end_date is NULL); 
    ELSIF p_party_type = 'PERSON' THEN
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, dsi.ROWID 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,pe.TAX_NAME
                  ,pe.TAX_REFERENCE
                  ,pe.JGZZ_FISCAL_CODE
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
        FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe, HZ_DQM_SYNC_INTERFACE dsi 
        WHERE p.party_id      = pe.party_id 
        AND   p.party_id      = dsi.party_id 
        AND   p.PARTY_TYPE    = 'PERSON' 
        AND   dsi.entity      = 'PARTY' 
        AND   dsi.staged_flag = 'N' 
        AND   dsi.operation   = p_operation 
        AND   dsi.sync_interface_num >= p_from_rec 
        AND   dsi.sync_interface_num <= p_to_rec 
        AND   (p.status = 'M' or pe.effective_end_date is NULL); 
    ELSE
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, dsi.ROWID 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
        FROM HZ_PARTIES p, HZ_DQM_SYNC_INTERFACE dsi 
        WHERE p.party_id      = dsi.party_id 
        AND   dsi.entity      = 'PARTY' 
        AND   dsi.staged_flag = 'N' 
        AND   dsi.operation   = p_operation 
        AND   dsi.sync_interface_num >= p_from_rec 
        AND   dsi.sync_interface_num <= p_to_rec 
        AND   p.party_type <> 'PERSON' 
        AND   p.party_type <> 'ORGANIZATION' 
        AND   p.party_type <> 'PARTY_RELATIONSHIP'; 
    END IF;
    hz_trans_pkg.set_party_type(p_party_type); 
  END;

  PROCEDURE sync_all_parties ( 
    p_operation             IN VARCHAR2, 
    p_bulk_sync_type        IN VARCHAR2, 
    p_sync_all_party_cur    IN HZ_DQM_SYNC.SyncCurTyp) IS 

    l_limit         NUMBER  := 200;
    l_last_fetch    BOOLEAN := FALSE;
    l_sql_errm      VARCHAR2(2000); 
    l_st            NUMBER; 
    l_en            NUMBER; 
    l_err_index     NUMBER; 
    l_err_count     NUMBER; 

    bulk_errors     EXCEPTION; 
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381); 

  BEGIN
    log ('Begin Synchronizing Parties'); 
    LOOP
      log ('Bulk Collecting Parties Data...',FALSE); 
      FETCH p_sync_all_party_cur BULK COLLECT INTO
         H_P_PARTY_ID
        ,H_STATUS
        ,H_ROWID
        ,H_TX2
        ,H_TX34
        ,H_TX36
        ,H_TX39
        ,H_TX41
        ,H_TX42
        ,H_TX44
        ,H_TX45
        ,H_TX46
        ,H_TX47
        ,H_TX48
        ,H_TX156
        ,H_TX157
      LIMIT l_limit;
      log ('Done'); 

      IF p_sync_all_party_cur%NOTFOUND THEN
        l_last_fetch:=TRUE;
      END IF;

      IF H_P_PARTY_ID.COUNT=0 AND l_last_fetch THEN
        EXIT;
      END IF;

      log ('Synchronizing for '||H_P_PARTY_ID.COUNT||' Parties'); 
      log ('Populating Party Transformation Functions into Arrays...',FALSE); 
      FOR I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST LOOP

        H_TX32(I):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(I),'PARTY','ALL_ACCOUNT_NAMES', 'STAGE');
        H_TX35(I):=HZ_PARTY_ACQUIRE.get_account_info(H_P_PARTY_ID(I),'PARTY','ALL_ACCOUNT_NUMBERS', 'STAGE');
        H_TX61(I):=HZ_EMAIL_DOMAINS_V2PUB.get_email_domains(H_P_PARTY_ID(I),'PARTY','DOMAIN_NAME', 'STAGE');
        H_TX63(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_P_PARTY_ID(I),'PARTY','PARTY_SOURCE_SYSTEM_REF', 'STAGE');
        H_TX4(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
        H_TX8(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
        H_TX19(I):=HZ_TRANS_PKG.SOUNDX(H_TX2(I),NULL, 'PARTY_NAME','PARTY');
        H_TX33(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX32(I),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
        H_TX40(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
        H_TX43(I):=HZ_TRANS_PKG.CLEANSE(H_TX42(I),NULL, 'TAX_NAME','PARTY');
        H_TX59(I):=HZ_TRANS_PKG.BASIC_WRNAMES(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
        H_TX60(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRNAMES(H_TX2(I),NULL, 'PARTY_NAME','PARTY','STAGE');
        H_TX62(I):=HZ_EMAIL_DOMAINS_V2PUB.FULL_DOMAIN(H_TX61(I),NULL, 'DOMAIN_NAME','PARTY');
        H_TX158(I):=HZ_TRANS_PKG.SOUNDX(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY');
        H_TX2(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(I),NULL, 'PARTY_NAME','PARTY');
        H_TX32(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX32(I),NULL, 'ALL_ACCOUNT_NAMES','PARTY','STAGE');
        H_TX34(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX34(I),NULL, 'PARTY_NUMBER','PARTY','STAGE');
        H_TX35(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX35(I),NULL, 'ALL_ACCOUNT_NUMBERS','PARTY','STAGE');
        H_TX36(I):=HZ_TRANS_PKG.EXACT(H_TX36(I),NULL, 'PARTY_TYPE','PARTY');
        H_TX39(I):=HZ_TRANS_PKG.WRNAMES_EXACT(H_TX39(I),NULL, 'PARTY_ALL_NAMES','PARTY','STAGE');
        H_TX41(I):=HZ_TRANS_PKG.EXACT(H_TX41(I),NULL, 'DUNS_NUMBER_C','PARTY');
        H_TX42(I):=HZ_TRANS_PKG.EXACT(H_TX42(I),NULL, 'TAX_NAME','PARTY');
        H_TX44(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX44(I),NULL, 'TAX_REFERENCE','PARTY','STAGE');
        H_TX45(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX45(I),NULL, 'JGZZ_FISCAL_CODE','PARTY','STAGE');
        H_TX46(I):=HZ_TRANS_PKG.EXACT(H_TX46(I),NULL, 'SIC_CODE','PARTY');
        H_TX47(I):=HZ_TRANS_PKG.EXACT(H_TX47(I),NULL, 'SIC_CODE_TYPE','PARTY');
        H_TX48(I):=HZ_TRANS_PKG.EXACT(H_TX48(I),NULL, 'CATEGORY_CODE','PARTY');
        H_TX61(I):=HZ_EMAIL_DOMAINS_V2PUB.CORE_DOMAIN(H_TX61(I),NULL, 'DOMAIN_NAME','PARTY');
        H_TX63(I):=HZ_TRANS_PKG.EXACT(H_TX63(I),NULL, 'PARTY_SOURCE_SYSTEM_REF','PARTY');
        H_TX156(I):=HZ_TRANS_PKG.EXACT(H_TX156(I),NULL, 'REFERENCE_USE_FLAG','PARTY');
        H_TX157(I):=HZ_TRANS_PKG.EXACT(H_TX157(I),NULL, 'CORPORATION_CLASS','PARTY');
      END LOOP;
      log ('Done'); 

      l_st := 1;  
      l_en := H_P_PARTY_ID.COUNT; 

      IF p_operation = 'C' THEN 
        BEGIN  
          log ('Inserting Data into HZ_STAGED_PARTIES...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            INSERT INTO HZ_STAGED_PARTIES (
               PARTY_ID
  	           ,STATUS
              ,D_PS
              ,D_CT
              ,D_CPT
              ,TX2
              ,TX4
              ,TX8
              ,TX19
              ,TX32
              ,TX33
              ,TX34
              ,TX35
              ,TX36
              ,TX39
              ,TX40
              ,TX41
              ,TX42
              ,TX43
              ,TX44
              ,TX45
              ,TX46
              ,TX47
              ,TX48
              ,TX59
              ,TX60
              ,TX61
              ,TX62
              ,TX63
              ,TX156
              ,TX157
              ,TX158
            ) VALUES (
               H_P_PARTY_ID(I)
              ,H_STATUS(I)
              ,'SYNC' 
              ,'SYNC' 
              ,'SYNC' 
              ,decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
              ,decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
              ,decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
              ,decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
              ,decode(H_TX32(I),null,H_TX32(I),H_TX32(I)||' ')
              ,decode(H_TX33(I),null,H_TX33(I),H_TX33(I)||' ')
              ,decode(H_TX34(I),null,H_TX34(I),H_TX34(I)||' ')
              ,decode(H_TX35(I),null,H_TX35(I),H_TX35(I)||' ')
              ,decode(H_TX36(I),null,H_TX36(I),H_TX36(I)||' ')
              ,decode(H_TX39(I),null,H_TX39(I),H_TX39(I)||' ')
              ,decode(H_TX40(I),null,H_TX40(I),H_TX40(I)||' ')
              ,decode(H_TX41(I),null,H_TX41(I),H_TX41(I)||' ')
              ,decode(H_TX42(I),null,H_TX42(I),H_TX42(I)||' ')
              ,decode(H_TX43(I),null,H_TX43(I),H_TX43(I)||' ')
              ,decode(H_TX44(I),null,H_TX44(I),H_TX44(I)||' ')
              ,decode(H_TX45(I),null,H_TX45(I),H_TX45(I)||' ')
              ,decode(H_TX46(I),null,H_TX46(I),H_TX46(I)||' ')
              ,decode(H_TX47(I),null,H_TX47(I),H_TX47(I)||' ')
              ,decode(H_TX48(I),null,H_TX48(I),H_TX48(I)||' ')
              ,decode(H_TX59(I),null,H_TX59(I),H_TX59(I)||' ')
              ,decode(H_TX60(I),null,H_TX60(I),H_TX60(I)||' ')
              ,decode(H_TX61(I),null,H_TX61(I),H_TX61(I)||' ')
              ,decode(H_TX62(I),null,H_TX62(I),H_TX62(I)||' ')
              ,decode(H_TX63(I),null,H_TX63(I),H_TX63(I)||' ')
              ,decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
              ,decode(H_TX157(I),null,H_TX157(I),H_TX157(I)||' ')
              ,decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
            );
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting Party with PARTY_ID - '||H_P_PARTY_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='PARTY' AND OPERATION='C' AND PARTY_ID=H_P_PARTY_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_P_PARTY_ID(l_err_index), NULL, NULL, NULL, 'PARTY', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      ELSIF p_operation = 'U' THEN 
        BEGIN 
          log ('Updating Data in HZ_STAGED_PARTIES...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            UPDATE HZ_STAGED_PARTIES SET 
               status =H_STATUS(I) 
              ,concat_col = concat_col 
                ,TX2=decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
                ,TX4=decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
                ,TX8=decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
                ,TX19=decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
                ,TX32=decode(H_TX32(I),null,H_TX32(I),H_TX32(I)||' ')
                ,TX33=decode(H_TX33(I),null,H_TX33(I),H_TX33(I)||' ')
                ,TX34=decode(H_TX34(I),null,H_TX34(I),H_TX34(I)||' ')
                ,TX35=decode(H_TX35(I),null,H_TX35(I),H_TX35(I)||' ')
                ,TX36=decode(H_TX36(I),null,H_TX36(I),H_TX36(I)||' ')
                ,TX39=decode(H_TX39(I),null,H_TX39(I),H_TX39(I)||' ')
                ,TX40=decode(H_TX40(I),null,H_TX40(I),H_TX40(I)||' ')
                ,TX41=decode(H_TX41(I),null,H_TX41(I),H_TX41(I)||' ')
                ,TX42=decode(H_TX42(I),null,H_TX42(I),H_TX42(I)||' ')
                ,TX43=decode(H_TX43(I),null,H_TX43(I),H_TX43(I)||' ')
                ,TX44=decode(H_TX44(I),null,H_TX44(I),H_TX44(I)||' ')
                ,TX45=decode(H_TX45(I),null,H_TX45(I),H_TX45(I)||' ')
                ,TX46=decode(H_TX46(I),null,H_TX46(I),H_TX46(I)||' ')
                ,TX47=decode(H_TX47(I),null,H_TX47(I),H_TX47(I)||' ')
                ,TX48=decode(H_TX48(I),null,H_TX48(I),H_TX48(I)||' ')
                ,TX59=decode(H_TX59(I),null,H_TX59(I),H_TX59(I)||' ')
                ,TX60=decode(H_TX60(I),null,H_TX60(I),H_TX60(I)||' ')
                ,TX61=decode(H_TX61(I),null,H_TX61(I),H_TX61(I)||' ')
                ,TX62=decode(H_TX62(I),null,H_TX62(I),H_TX62(I)||' ')
                ,TX63=decode(H_TX63(I),null,H_TX63(I),H_TX63(I)||' ')
                ,TX156=decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
                ,TX157=decode(H_TX157(I),null,H_TX157(I),H_TX157(I)||' ')
                ,TX158=decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
            WHERE PARTY_ID = H_P_PARTY_ID(I);
          log ('Done'); 
        EXCEPTION WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting Party with PARTY_ID - '||H_P_PARTY_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='PARTY' AND OPERATION='U' AND PARTY_ID=H_P_PARTY_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data  = l_sql_errm 
                  ,staged_flag     = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid        = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_P_PARTY_ID(l_err_index), NULL, NULL, NULL, 'PARTY', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      END IF; 

      -- REPURI. Bug 4884742. 
      -- Bulk Insert the Import Parties into  Shadow Sync Interface table 
      -- if Shadow Staging has already run and completed successfully 
      IF ((p_bulk_sync_type = 'IMPORT_SYNC') AND 
          (HZ_DQM_SYNC.is_shadow_staging_complete)) THEN 
        BEGIN 
           -- REPURI. Bug 4968126. 
           -- Using the Merge instead of Insert statement 
           -- so that duplicate records dont get inserted. 
          log ('Merging data into HZ_DQM_SH_SYNC_INTERFACE...',FALSE); 
          FORALL I in l_st..l_en  
            MERGE INTO hz_dqm_sh_sync_interface S 
              USING ( 
                SELECT 
                  H_P_PARTY_ID(I) AS party_id 
                FROM dual ) T 
              ON (S.entity      = 'PARTY'  AND 
                  S.party_id    = T.party_id AND 
                  S.staged_flag <> 'E') 
              WHEN NOT MATCHED THEN 
              INSERT ( 
                PARTY_ID, 
                RECORD_ID, 
                PARTY_SITE_ID, 
                ORG_CONTACT_ID, 
                ENTITY, 
                OPERATION, 
                STAGED_FLAG, 
                REALTIME_SYNC_FLAG, 
                CREATED_BY, 
                CREATION_DATE, 
                LAST_UPDATE_LOGIN, 
                LAST_UPDATE_DATE, 
                LAST_UPDATED_BY, 
                SYNC_INTERFACE_NUM 
              ) VALUES ( 
                H_P_PARTY_ID(I), 
                NULL, 
                NULL, 
                NULL, 
                'PARTY', 
                p_operation, 
                'N', 
                'N', 
                hz_utility_pub.created_by, 
                hz_utility_pub.creation_date, 
                hz_utility_pub.last_update_login, 
                hz_utility_pub.last_update_date, 
                hz_utility_pub.user_id, 
                HZ_DQM_SH_SYNC_INTERFACE_S.nextval 
            ); 
        log ('Done'); 
        EXCEPTION WHEN OTHERS THEN 
              log ('Exception occured while inserting data into HZ_DQM_SH_SYNC_INTERFACE Table');   
              log ('Eror Message is - '|| sqlerrm);   
        END; 
      END IF; 

      IF l_last_fetch THEN
        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;

      FND_CONCURRENT.AF_Commit;

    END LOOP;
    log ('End Synchronizing Parties'); 
  END;

  PROCEDURE open_sync_party_site_cursor ( 
    p_operation            IN      VARCHAR2,
    p_from_rec             IN      VARCHAR2,
    p_to_rec               IN      VARCHAR2,
    x_sync_party_site_cur  IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_party_site_cur FOR 
      SELECT /*+ ORDERED USE_NL(ps l) */ 
         ps.PARTY_SITE_ID 
        ,dsi.party_id 
        ,dsi.org_contact_id 
        ,ps.status 
        ,dsi.ROWID 
        ,rtrim(l.address1 || ' ' || l.address2 || ' ' || l.address3 || ' ' || l.address4)
        ,l.CITY
        ,l.POSTAL_CODE
        ,l.PROVINCE
        ,l.STATE
        ,ps.PARTY_SITE_NUMBER
        ,ps.PARTY_SITE_NAME
        ,l.COUNTY
        ,l.COUNTRY
        ,ps.IDENTIFYING_ADDRESS_FLAG
        ,ps.STATUS
        ,l.ADDRESS1
      FROM   HZ_DQM_SYNC_INTERFACE dsi, HZ_PARTY_SITES ps, HZ_LOCATIONS l
      WHERE  dsi.record_id   = ps.party_site_id 
      AND    dsi.entity      = 'PARTY_SITES' 
      AND    dsi.operation   = p_operation 
      AND    dsi.staged_flag = 'N' 
      AND    dsi.sync_interface_num >= p_from_rec 
      AND    dsi.sync_interface_num <= p_to_rec 
      AND    (ps.status is null OR ps.status = 'A' OR ps.status = 'I') 
      AND    ps.location_id = l.location_id; 
  END; 

  PROCEDURE sync_all_party_sites ( 
    p_operation                IN VARCHAR2, 
    p_bulk_sync_type           IN VARCHAR2, 
    p_sync_all_party_site_cur  IN HZ_DQM_SYNC.SyncCurTyp) IS 

    l_limit         NUMBER  := 200;
    l_last_fetch    BOOLEAN := FALSE;
    l_sql_errm      VARCHAR2(2000); 
    l_st            NUMBER; 
    l_en            NUMBER; 
    l_err_index     NUMBER; 
    l_err_count     NUMBER; 

    bulk_errors     EXCEPTION; 
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381); 

  BEGIN
    log ('Begin Synchronizing Party Sites'); 
    LOOP
      log ('Bulk Collecting Party Sites Data...',FALSE); 
      FETCH p_sync_all_party_site_cur BULK COLLECT INTO
         H_PARTY_SITE_ID
        ,H_PS_PARTY_ID
        ,H_PS_ORG_CONTACT_ID
        ,H_STATUS
        ,H_ROWID
        ,H_TX3
        ,H_TX9
        ,H_TX11
        ,H_TX12
        ,H_TX14
        ,H_TX17
        ,H_TX18
        ,H_TX20
        ,H_TX22
        ,H_TX24
        ,H_TX25
        ,H_TX28
      LIMIT l_limit;
      log ('Done'); 

      IF p_sync_all_party_site_cur%NOTFOUND THEN
        l_last_fetch:=TRUE;
     END IF;

      IF H_PARTY_SITE_ID.COUNT=0 AND l_last_fetch THEN
        EXIT;
      END IF;

      log ('Synchronizing for '||H_PARTY_SITE_ID.COUNT||' Party Sites'); 
      log ('Populating Party Sites Transformation Functions into Arrays...',FALSE); 
      FOR I in H_PARTY_SITE_ID.FIRST..H_PARTY_SITE_ID.LAST LOOP
        ---- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ----

        HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (36,H_TX22(I));

        H_TX30(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_PARTY_SITE_ID(I),'PARTY_SITES','ADDR_SOURCE_SYSTEM_REF', 'STAGE');
        H_TX4(I):=HZ_TRANS_PKG.WRADDRESS_CLEANSE(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
        H_TX10(I):=HZ_TRANS_PKG.CLEANSE(H_TX9(I),NULL, 'CITY','PARTY_SITES');
        H_TX13(I):=HZ_TRANS_PKG.CLEANSE(H_TX12(I),NULL, 'PROVINCE','PARTY_SITES');
        H_TX15(I):=HZ_TRANS_PKG.WRSTATE_CLEANSE(H_TX14(I),NULL, 'STATE','PARTY_SITES','STAGE');
        H_TX19(I):=HZ_TRANS_PKG.CLEANSE(H_TX18(I),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
        H_TX21(I):=HZ_TRANS_PKG.CLEANSE(H_TX20(I),NULL, 'COUNTY','PARTY_SITES');
        H_TX26(I):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
        H_TX27(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
        H_TX29(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_TX28(I),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
        H_TX3(I):=HZ_TRANS_PKG.WRADDRESS_EXACT(H_TX3(I),NULL, 'ADDRESS','PARTY_SITES','STAGE');
        H_TX9(I):=HZ_TRANS_PKG.EXACT(H_TX9(I),NULL, 'CITY','PARTY_SITES');
        H_TX11(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'POSTAL_CODE','PARTY_SITES','STAGE');
        H_TX12(I):=HZ_TRANS_PKG.EXACT(H_TX12(I),NULL, 'PROVINCE','PARTY_SITES');
        H_TX14(I):=HZ_TRANS_PKG.WRSTATE_EXACT(H_TX14(I),NULL, 'STATE','PARTY_SITES','STAGE');
        H_TX17(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX17(I),NULL, 'PARTY_SITE_NUMBER','PARTY_SITES','STAGE');
        H_TX18(I):=HZ_TRANS_PKG.EXACT(H_TX18(I),NULL, 'PARTY_SITE_NAME','PARTY_SITES');
        H_TX20(I):=HZ_TRANS_PKG.EXACT(H_TX20(I),NULL, 'COUNTY','PARTY_SITES');
        H_TX22(I):=HZ_TRANS_PKG.EXACT(H_TX22(I),NULL, 'COUNTRY','PARTY_SITES');
        H_TX24(I):=HZ_TRANS_PKG.EXACT(H_TX24(I),NULL, 'IDENTIFYING_ADDRESS_FLAG','PARTY_SITES');
        H_TX25(I):=HZ_TRANS_PKG.EXACT(H_TX25(I),NULL, 'STATUS','PARTY_SITES');
        H_TX28(I):=HZ_TRANS_PKG.BASIC_WRADDR(H_TX28(I),NULL, 'ADDRESS1','PARTY_SITES','STAGE');
        H_TX30(I):=HZ_TRANS_PKG.EXACT(H_TX30(I),NULL, 'ADDR_SOURCE_SYSTEM_REF','PARTY_SITES');
      END LOOP;
      log ('Done'); 

      l_st := 1;  
      l_en := H_PARTY_SITE_ID.COUNT; 

      IF p_operation = 'C' THEN 
        BEGIN  
          log ('Inserting Data into HZ_STAGED_PARTY_SITES...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            INSERT INTO HZ_STAGED_PARTY_SITES (
               PARTY_SITE_ID
              ,PARTY_ID
              ,ORG_CONTACT_ID
              ,STATUS_FLAG
              ,TX3
              ,TX4
              ,TX9
              ,TX10
              ,TX11
              ,TX12
              ,TX13
              ,TX14
              ,TX15
              ,TX17
              ,TX18
              ,TX19
              ,TX20
              ,TX21
              ,TX22
              ,TX24
              ,TX25
              ,TX26
              ,TX27
              ,TX28
              ,TX29
              ,TX30
            ) VALUES (
               H_PARTY_SITE_ID(I)
              ,H_PS_PARTY_ID(I)
              ,H_PS_ORG_CONTACT_ID(I)
              ,H_STATUS(I)
              ,decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
              ,decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
              ,decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
              ,decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
              ,decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
              ,decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
              ,decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
              ,decode(H_TX15(I),null,H_TX15(I),H_TX15(I)||' ')
              ,decode(H_TX17(I),null,H_TX17(I),H_TX17(I)||' ')
              ,decode(H_TX18(I),null,H_TX18(I),H_TX18(I)||' ')
              ,decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
              ,decode(H_TX20(I),null,H_TX20(I),H_TX20(I)||' ')
              ,decode(H_TX21(I),null,H_TX21(I),H_TX21(I)||' ')
              ,decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
              ,decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
              ,decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
              ,decode(H_TX26(I),null,H_TX26(I),H_TX26(I)||' ')
              ,decode(H_TX27(I),null,H_TX27(I),H_TX27(I)||' ')
              ,decode(H_TX28(I),null,H_TX28(I),H_TX28(I)||' ')
              ,decode(H_TX29(I),null,H_TX29(I),H_TX29(I)||' ')
              ,decode(H_TX30(I),null,H_TX30(I),H_TX30(I)||' ')
            );
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting Party Site with PARTY_SITE_ID - '||H_PARTY_SITE_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='PARTY_SITES' AND OPERATION='C' AND RECORD_ID=H_PARTY_SITE_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_PS_PARTY_ID(l_err_index), H_PARTY_SITE_ID(l_err_index), NULL, H_PS_ORG_CONTACT_ID(l_err_index), 'PARTY_SITES', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      ELSIF p_operation = 'U' THEN 
        BEGIN 
          log ('Updating Data in HZ_STAGED_PARTY_SITES...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            UPDATE HZ_STAGED_PARTY_SITES SET 
               concat_col = concat_col
              ,status_flag = H_STATUS(I)
              ,TX3=decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
              ,TX4=decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
              ,TX9=decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
              ,TX10=decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
              ,TX11=decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,TX12=decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
              ,TX13=decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
              ,TX14=decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
              ,TX15=decode(H_TX15(I),null,H_TX15(I),H_TX15(I)||' ')
              ,TX17=decode(H_TX17(I),null,H_TX17(I),H_TX17(I)||' ')
              ,TX18=decode(H_TX18(I),null,H_TX18(I),H_TX18(I)||' ')
              ,TX19=decode(H_TX19(I),null,H_TX19(I),H_TX19(I)||' ')
              ,TX20=decode(H_TX20(I),null,H_TX20(I),H_TX20(I)||' ')
              ,TX21=decode(H_TX21(I),null,H_TX21(I),H_TX21(I)||' ')
              ,TX22=decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
              ,TX24=decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
              ,TX25=decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
              ,TX26=decode(H_TX26(I),null,H_TX26(I),H_TX26(I)||' ')
              ,TX27=decode(H_TX27(I),null,H_TX27(I),H_TX27(I)||' ')
              ,TX28=decode(H_TX28(I),null,H_TX28(I),H_TX28(I)||' ')
              ,TX29=decode(H_TX29(I),null,H_TX29(I),H_TX29(I)||' ')
              ,TX30=decode(H_TX30(I),null,H_TX30(I),H_TX30(I)||' ')
            WHERE PARTY_SITE_ID=H_PARTY_SITE_ID(I);
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting Party Site with PARTY_SITE_ID - '||H_PARTY_SITE_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='PARTY_SITES' AND OPERATION='U' AND RECORD_ID=H_PARTY_SITE_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_PS_PARTY_ID(l_err_index), H_PARTY_SITE_ID(l_err_index), NULL, H_PS_ORG_CONTACT_ID(l_err_index), 'PARTY_SITES', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      END IF;

      IF l_last_fetch THEN
        -- Update HZ_STAGED_PARTIES, if corresponding child entity records 
        -- PARTY_SITES (in this case), have been inserted/updated 

        log ('Updating D_PS column to SYNC in HZ_STAGED_PARTIES table for all related records...',FALSE); 
        --Fix for bug 5048604, to update concat_col during update of denorm column 
        FORALL I IN H_PARTY_SITE_ID.FIRST..H_PARTY_SITE_ID.LAST 
          UPDATE HZ_STAGED_PARTIES set 
            D_PS = 'SYNC' 
           ,CONCAT_COL = CONCAT_COL 
          WHERE PARTY_ID = H_PS_PARTY_ID(I); 
        log ('Done'); 

      -- REPURI. Bug 4884742. 
      -- Bulk Insert of Import Party Sites into  Shadow Sync Interface table 
      -- if Shadow Staging has already run and completed successfully 
      IF ((p_bulk_sync_type = 'IMPORT_SYNC') AND 
          (HZ_DQM_SYNC.is_shadow_staging_complete)) THEN 
        BEGIN 
           -- REPURI. Bug 4968126. 
           -- Using the Merge instead of Insert statement 
           -- so that duplicate records dont get inserted. 
          log ('Merging data into HZ_DQM_SH_SYNC_INTERFACE...',FALSE); 
          FORALL I in l_st..l_en  
            MERGE INTO hz_dqm_sh_sync_interface S 
              USING ( 
                SELECT 
                   H_PS_PARTY_ID(I)       AS party_id 
                  ,H_PARTY_SITE_ID(I)     AS record_id 
                  ,H_PS_ORG_CONTACT_ID(I) AS org_contact_id 
                FROM dual ) T 
              ON (S.entity                   = 'PARTY_SITES'              AND 
                  S.party_id                 = T.party_id                 AND 
                  S.record_id                = T.record_id                AND 
                  NVL(S.org_contact_id, -99) = NVL(T.org_contact_id, -99) AND 
                  S.staged_flag             <> 'E') 
              WHEN NOT MATCHED THEN 
              INSERT ( 
                PARTY_ID, 
                RECORD_ID, 
                PARTY_SITE_ID, 
                ORG_CONTACT_ID, 
                ENTITY, 
                OPERATION, 
                STAGED_FLAG, 
                REALTIME_SYNC_FLAG, 
                CREATED_BY, 
                CREATION_DATE, 
                LAST_UPDATE_LOGIN, 
                LAST_UPDATE_DATE, 
                LAST_UPDATED_BY, 
                SYNC_INTERFACE_NUM 
              ) VALUES ( 
                H_PS_PARTY_ID(I), 
                H_PARTY_SITE_ID(I), 
                NULL, 
                H_PS_ORG_CONTACT_ID(I), 
                'PARTY_SITES', 
                p_operation, 
                'N', 
                'N', 
                hz_utility_pub.created_by, 
                hz_utility_pub.creation_date, 
                hz_utility_pub.last_update_login, 
                hz_utility_pub.last_update_date, 
                hz_utility_pub.user_id, 
                HZ_DQM_SH_SYNC_INTERFACE_S.nextval 
            ); 
        log ('Done'); 
        EXCEPTION WHEN OTHERS THEN 
              log ('Exception occured while inserting data into HZ_DQM_SH_SYNC_INTERFACE Table');   
              log ('Eror Message is - '|| sqlerrm);   
        END; 
      END IF; 

        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;

      FND_CONCURRENT.AF_Commit;

    END LOOP;
    log ('End Synchronizing Party Sites'); 
  END;

  PROCEDURE open_sync_contact_cursor ( 
    p_operation            IN      VARCHAR2,
    p_from_rec             IN      VARCHAR2,
    p_to_rec               IN      VARCHAR2,
    x_sync_contact_cur     IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_contact_cur FOR 
      SELECT 
         /*+ leading(dsi) USE_NL(OC R PP) */ 
         oc.ORG_CONTACT_ID 
        ,r.OBJECT_ID 
        ,r.PARTY_ID 
        ,r.STATUS 
        ,dsi.ROWID 
        ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
        ,oc.CONTACT_NUMBER
        ,oc.JOB_TITLE
      FROM HZ_DQM_SYNC_INTERFACE dsi, HZ_RELATIONSHIPS r,
           HZ_ORG_CONTACTS oc, HZ_PERSON_PROFILES pp
      WHERE oc.party_relationship_id = r.relationship_id 
      AND   dsi.record_id            = oc.org_contact_id 
      AND   r.subject_id             = pp.party_id 
      AND   r.subject_type           = 'PERSON' 
      AND   r.SUBJECT_TABLE_NAME     = 'HZ_PARTIES'
      AND   r.OBJECT_TABLE_NAME      = 'HZ_PARTIES'
      AND   DIRECTIONAL_FLAG         = 'F' 
      AND   pp.effective_end_date    is NULL 
      AND   dsi.entity               = 'CONTACTS' 
      AND   dsi.operation            = p_operation 
      AND   dsi.staged_flag          = 'N' 
      AND   dsi.sync_interface_num  >= p_from_rec 
      AND   dsi.sync_interface_num  <= p_to_rec 
      AND   (oc.status is null OR oc.status = 'A' or oc.status = 'I')
      AND   (r.status is null OR r.status = 'A' or r.status = 'I');
  END; 

  PROCEDURE sync_all_contacts ( 
    p_operation               IN VARCHAR2, 
    p_bulk_sync_type          IN VARCHAR2, 
    p_sync_all_contact_cur    IN HZ_DQM_SYNC.SyncCurTyp) IS 

    l_limit         NUMBER  := 200;
    l_last_fetch    BOOLEAN := FALSE;
    l_sql_errm      VARCHAR2(2000); 
    l_st            NUMBER; 
    l_en            NUMBER; 
    l_err_index     NUMBER; 
    l_err_count     NUMBER; 

    bulk_errors     EXCEPTION; 
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381); 

  BEGIN
    log ('Begin Synchronizing Contacts'); 
    LOOP
      log ('Bulk Collecting Contacts Data...',FALSE); 
      FETCH p_sync_all_contact_cur BULK COLLECT INTO
         H_ORG_CONTACT_ID
        ,H_C_PARTY_ID
        ,H_R_PARTY_ID
        ,H_STATUS
        ,H_ROWID
        ,H_TX2
        ,H_TX11
        ,H_TX22
      LIMIT l_limit;
      log ('Done'); 

      IF p_sync_all_contact_cur%NOTFOUND THEN
        l_last_fetch:=TRUE;
      END IF;

      IF H_ORG_CONTACT_ID.COUNT=0 AND l_last_fetch THEN
        EXIT;
      END IF;

      log ('Synchronizing for '||H_ORG_CONTACT_ID.COUNT||' Contacts'); 
      log ('Populating Contacts Transformation Functions into Arrays...',FALSE); 

      FOR I in H_ORG_CONTACT_ID.FIRST..H_ORG_CONTACT_ID.LAST LOOP

        H_TX25(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_ORG_CONTACT_ID(I),'CONTACTS','CONTACT_SOURCE_SYSTEM_REF', 'STAGE');
        H_TX5(I):=HZ_TRANS_PKG.WRPERSON_EXACT(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
        H_TX6(I):=HZ_TRANS_PKG.WRPERSON_CLEANSE(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
        H_TX23(I):=HZ_TRANS_PKG.BASIC_WRPERSON(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
        H_TX24(I):=HZ_TRANS_PKG.BASIC_CLEANSE_WRPERSON(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS','STAGE');
        H_TX156(I):=HZ_TRANS_PKG.SOUNDX(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS');
        H_TX2(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX2(I),NULL, 'CONTACT_NAME','CONTACTS');
        H_TX11(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'CONTACT_NUMBER','CONTACTS','STAGE');
        H_TX22(I):=HZ_TRANS_PKG.EXACT(H_TX22(I),NULL, 'JOB_TITLE','CONTACTS');
        H_TX25(I):=HZ_TRANS_PKG.EXACT(H_TX25(I),NULL, 'CONTACT_SOURCE_SYSTEM_REF','CONTACTS');
      END LOOP;
      log ('Done'); 

      l_st :=  1;  
      l_en :=  H_ORG_CONTACT_ID.COUNT; 

      IF p_operation = 'C' THEN 
        BEGIN 
          log ('Inserting Data into HZ_STAGED_CONTACTS...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            INSERT INTO HZ_STAGED_CONTACTS (
	            ORG_CONTACT_ID
              ,PARTY_ID
              ,STATUS_FLAG 
              ,TX2
              ,TX5
              ,TX6
              ,TX11
              ,TX22
              ,TX23
              ,TX24
              ,TX25
              ,TX156
            ) VALUES (
               H_ORG_CONTACT_ID(I)
              ,H_C_PARTY_ID(I)
              ,H_STATUS(I)
              ,decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
              ,decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
              ,decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
              ,decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
              ,decode(H_TX23(I),null,H_TX23(I),H_TX23(I)||' ')
              ,decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
              ,decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
              ,decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
            );
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting a Contact with ORG_CONTACT_ID - '||H_ORG_CONTACT_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='CONTACTS' AND OPERATION='C' AND RECORD_ID=H_ORG_CONTACT_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_C_PARTY_ID(l_err_index), H_ORG_CONTACT_ID(l_err_index), NULL, NULL, 'CONTACTS', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      ELSIF p_operation = 'U' THEN 
        BEGIN 
          log ('Updating Data in HZ_STAGED_CONTACTS...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            UPDATE HZ_STAGED_CONTACTS SET 
              concat_col = concat_col
             ,status_flag = H_STATUS(I)
              ,TX2=decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
              ,TX5=decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
              ,TX6=decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
              ,TX11=decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,TX22=decode(H_TX22(I),null,H_TX22(I),H_TX22(I)||' ')
              ,TX23=decode(H_TX23(I),null,H_TX23(I),H_TX23(I)||' ')
              ,TX24=decode(H_TX24(I),null,H_TX24(I),H_TX24(I)||' ')
              ,TX25=decode(H_TX25(I),null,H_TX25(I),H_TX25(I)||' ')
              ,TX156=decode(H_TX156(I),null,H_TX156(I),H_TX156(I)||' ')
            WHERE ORG_CONTACT_ID=H_ORG_CONTACT_ID(I);
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting a Contact with ORG_CONTACT_ID - '||H_ORG_CONTACT_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='CONTACTS' AND OPERATION='U' AND RECORD_ID=H_ORG_CONTACT_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_C_PARTY_ID(l_err_index), H_ORG_CONTACT_ID(l_err_index), NULL, NULL, 'CONTACTS', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      END IF;

      IF l_last_fetch THEN
        -- Update HZ_STAGED_PARTIES, if corresponding child entity records 
        -- CONTACTS (in this case), have been inserted/updated 

        log ('Updating D_CT column to SYNC in HZ_STAGED_PARTIES table for all related records...',FALSE); 
        --Fix for bug 5048604, to update concat_col during update of denorm column 
        FORALL I IN H_ORG_CONTACT_ID.FIRST..H_ORG_CONTACT_ID.LAST 
          UPDATE HZ_STAGED_PARTIES set 
            D_CT = 'SYNC' 
           ,CONCAT_COL = CONCAT_COL 
          WHERE PARTY_ID = H_C_PARTY_ID(I); 
        log ('Done'); 

      -- REPURI. Bug 4884742. 
      -- Bulk Insert of Import Contacts into  Shadow Sync Interface table 
      -- if Shadow Staging has already run and completed successfully 
      IF ((p_bulk_sync_type = 'IMPORT_SYNC') AND 
          (HZ_DQM_SYNC.is_shadow_staging_complete)) THEN 
        BEGIN 
           -- REPURI. Bug 4968126. 
           -- Using the Merge instead of Insert statement 
           -- so that duplicate records dont get inserted. 
          log ('Merging data into HZ_DQM_SH_SYNC_INTERFACE...',FALSE); 
          FORALL I in l_st..l_en  
            MERGE INTO hz_dqm_sh_sync_interface S 
              USING ( 
                SELECT 
                   H_C_PARTY_ID(I)      AS party_id 
                  ,H_ORG_CONTACT_ID(I)  AS record_id 
                FROM dual ) T 
              ON (S.entity        = 'CONTACTS' AND 
                  S.party_id      = T.party_id   AND 
                  S.record_id     = T.record_id  AND 
                  S.staged_flag   <> 'E') 
              WHEN NOT MATCHED THEN 
              INSERT ( 
                PARTY_ID, 
                RECORD_ID, 
                PARTY_SITE_ID, 
                ORG_CONTACT_ID, 
                ENTITY, 
                OPERATION, 
                STAGED_FLAG, 
                REALTIME_SYNC_FLAG, 
                CREATED_BY, 
                CREATION_DATE, 
                LAST_UPDATE_LOGIN, 
                LAST_UPDATE_DATE, 
                LAST_UPDATED_BY, 
                SYNC_INTERFACE_NUM 
              ) VALUES ( 
                H_C_PARTY_ID(I), 
                H_ORG_CONTACT_ID(I), 
                NULL, 
                NULL, 
                'CONTACTS', 
                p_operation, 
                'N', 
                'N', 
                hz_utility_pub.created_by, 
                hz_utility_pub.creation_date, 
                hz_utility_pub.last_update_login, 
                hz_utility_pub.last_update_date, 
                hz_utility_pub.user_id, 
                HZ_DQM_SH_SYNC_INTERFACE_S.nextval 
            ); 
        log ('Done'); 
        EXCEPTION WHEN OTHERS THEN 
              log ('Exception occured while inserting data into HZ_DQM_SH_SYNC_INTERFACE Table');   
              log ('Eror Message is - '|| sqlerrm);   
        END; 
      END IF; 

        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;

      FND_CONCURRENT.AF_Commit;

    END LOOP;
    log ('End Synchronizing Contacts'); 
  END;

  PROCEDURE open_sync_cpt_cursor ( 
    p_operation            IN      VARCHAR2,
    p_from_rec             IN      VARCHAR2,
    p_to_rec               IN      VARCHAR2,
    x_sync_cpt_cur         IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_cpt_cur FOR 
      SELECT 
         /*+ ORDERED USE_NL(cp) */ 
         cp.CONTACT_POINT_ID 
        ,dsi.party_id 
        ,dsi.party_site_id 
        ,dsi.org_contact_id 
        ,cp.CONTACT_POINT_TYPE 
        ,cp.STATUS 
        ,dsi.ROWID 
        ,translate(phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' || translate(phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' ||  translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
        ,cp.PHONE_NUMBER
        ,cp.PHONE_AREA_CODE
        ,cp.PHONE_COUNTRY_CODE
        ,cp.EMAIL_ADDRESS
        ,cp.URL
        ,cp.PRIMARY_FLAG
        ,translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
        ,cp.PHONE_LINE_TYPE
        ,cp.STATUS
        ,cp.CONTACT_POINT_PURPOSE
      FROM HZ_DQM_SYNC_INTERFACE dsi,HZ_CONTACT_POINTS cp
      WHERE dsi.record_id            = cp.contact_point_id 
      AND   dsi.entity               = 'CONTACT_POINTS' 
      AND   dsi.operation            = p_operation 
      AND   dsi.staged_flag          = 'N' 
      AND   dsi.sync_interface_num  >= p_from_rec 
      AND   dsi.sync_interface_num  <= p_to_rec 
      AND (cp.status is null OR cp.status = 'A' or cp.status = 'I'); 
    END; 

  PROCEDURE sync_all_contact_points ( 
    p_operation               IN VARCHAR2, 
    p_bulk_sync_type          IN VARCHAR2, 
    p_sync_all_cpt_cur        IN HZ_DQM_SYNC.SyncCurTyp) IS 

    l_limit         NUMBER  := 200;
    l_last_fetch    BOOLEAN := FALSE;
    l_sql_errm      VARCHAR2(2000); 
    l_st            NUMBER; 
    l_en            NUMBER; 
    l_err_index     NUMBER; 
    l_err_count     NUMBER; 

    bulk_errors     EXCEPTION; 
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381); 

  BEGIN
    log ('Begin Synchronizing Contact Points'); 
    LOOP
      log ('Bulk Collecting Contact Points Data...',FALSE); 
      FETCH p_sync_all_cpt_cur BULK COLLECT INTO
         H_CONTACT_POINT_ID
        ,H_CPT_PARTY_ID
        ,H_CPT_PARTY_SITE_ID
        ,H_CPT_ORG_CONTACT_ID
        ,H_CONTACT_POINT_TYPE
        ,H_STATUS
        ,H_ROWID 
         ,H_TX1
         ,H_TX2
         ,H_TX3
         ,H_TX4
         ,H_TX5
         ,H_TX7
         ,H_TX9
         ,H_TX10
         ,H_TX11
         ,H_TX12
         ,H_TX13
      LIMIT l_limit;
      log ('Done'); 

      IF p_sync_all_cpt_cur%NOTFOUND THEN
        l_last_fetch:=TRUE;
      END IF;

      IF H_CONTACT_POINT_ID.COUNT=0 AND l_last_fetch THEN
        EXIT;
      END IF;

      log ('Synchronizing for '||H_CONTACT_POINT_ID.COUNT||' Contact Points'); 
      log ('Populating Contact Points Transformation Functions into Arrays...',FALSE); 

      FOR I in H_CONTACT_POINT_ID.FIRST..H_CONTACT_POINT_ID.LAST LOOP

        H_TX14(I):=HZ_PARTY_ACQUIRE.get_ssm_mappings(H_CONTACT_POINT_ID(I),'CONTACT_POINTS','CPT_SOURCE_SYSTEM_REF', 'STAGE');
        H_TX6(I):=HZ_TRANS_PKG.CLEANSED_EMAIL(H_TX5(I),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS','STAGE');
        H_TX8(I):=HZ_TRANS_PKG.CLEANSED_URL(H_TX7(I),NULL, 'URL','CONTACT_POINTS','STAGE');
        H_TX158(I):=HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_TX10(I),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS');
        H_TX1(I):=HZ_TRANS_PKG.RM_SPLCHAR_CTX(H_TX1(I),NULL, 'FLEX_FORMAT_PHONE_NUMBER','CONTACT_POINTS','STAGE');
        H_TX2(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX2(I),NULL, 'PHONE_NUMBER','CONTACT_POINTS','STAGE');
        H_TX3(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX3(I),NULL, 'PHONE_AREA_CODE','CONTACT_POINTS','STAGE');
        H_TX4(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX4(I),NULL, 'PHONE_COUNTRY_CODE','CONTACT_POINTS','STAGE');
        H_TX5(I):=HZ_TRANS_PKG.EXACT_EMAIL(H_TX5(I),NULL, 'EMAIL_ADDRESS','CONTACT_POINTS');
        H_TX7(I):=HZ_TRANS_PKG.EXACT_URL(H_TX7(I),NULL, 'URL','CONTACT_POINTS');
        H_TX9(I):=HZ_TRANS_PKG.EXACT(H_TX9(I),NULL, 'PRIMARY_FLAG','CONTACT_POINTS');
        H_TX10(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX10(I),NULL, 'RAW_PHONE_NUMBER','CONTACT_POINTS','STAGE');
        H_TX11(I):=HZ_TRANS_PKG.EXACT(H_TX11(I),NULL, 'PHONE_LINE_TYPE','CONTACT_POINTS');
        H_TX12(I):=HZ_TRANS_PKG.EXACT(H_TX12(I),NULL, 'STATUS','CONTACT_POINTS');
        H_TX13(I):=HZ_TRANS_PKG.EXACT(H_TX13(I),NULL, 'CONTACT_POINT_PURPOSE','CONTACT_POINTS');
        H_TX14(I):=HZ_TRANS_PKG.EXACT(H_TX14(I),NULL, 'CPT_SOURCE_SYSTEM_REF','CONTACT_POINTS');
      END LOOP;
      log ('Done'); 

      l_st :=  1;  
      l_en :=  H_CONTACT_POINT_ID.COUNT; 

      IF p_operation = 'C' THEN 
        BEGIN 
          log ('Inserting Data into HZ_STAGED_CONTACT_POINTS...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            INSERT INTO HZ_STAGED_CONTACT_POINTS (
               CONTACT_POINT_ID
              ,PARTY_ID
              ,PARTY_SITE_ID
	           ,ORG_CONTACT_ID
              ,CONTACT_POINT_TYPE
              ,STATUS_FLAG
              ,TX1
              ,TX2
              ,TX3
              ,TX4
              ,TX5
              ,TX6
              ,TX7
              ,TX8
              ,TX9
              ,TX10
              ,TX11
              ,TX12
              ,TX13
              ,TX14
              ,TX158
            ) VALUES (
               H_CONTACT_POINT_ID(I)
              ,H_CPT_PARTY_ID(I)
              ,H_CPT_PARTY_SITE_ID(I)
              ,H_CPT_ORG_CONTACT_ID(I)
              ,H_CONTACT_POINT_TYPE(I)
              ,H_STATUS(I)
              ,decode(H_TX1(I),null,H_TX1(I),H_TX1(I)||' ')
              ,decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
              ,decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
              ,decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
              ,decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
              ,decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
              ,decode(H_TX7(I),null,H_TX7(I),H_TX7(I)||' ')
              ,decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
              ,decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
              ,decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
              ,decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
              ,decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
              ,decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
              ,decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
            );
          log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting a Contact Point with CONTACT_POINT_ID - '||H_CONTACT_POINT_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='CONTACT_POINTS' AND OPERATION='C' AND RECORD_ID=H_CONTACT_POINT_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_CPT_PARTY_ID(l_err_index), H_CONTACT_POINT_ID(l_err_index), H_CPT_PARTY_SITE_ID(l_err_index), H_CPT_ORG_CONTACT_ID(l_err_index), 'CONTACT_POINTS', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      ELSIF p_operation = 'U' THEN 
        BEGIN 
          log ('Updating Data in HZ_STAGED_CONTACT_POINTS...',FALSE); 
          FORALL I in l_st..l_en SAVE EXCEPTIONS 
            UPDATE HZ_STAGED_CONTACT_POINTS SET 
              concat_col = concat_col
             ,status_flag    = H_STATUS(I) 
              ,TX1=decode(H_TX1(I),null,H_TX1(I),H_TX1(I)||' ')
              ,TX2=decode(H_TX2(I),null,H_TX2(I),H_TX2(I)||' ')
              ,TX3=decode(H_TX3(I),null,H_TX3(I),H_TX3(I)||' ')
              ,TX4=decode(H_TX4(I),null,H_TX4(I),H_TX4(I)||' ')
              ,TX5=decode(H_TX5(I),null,H_TX5(I),H_TX5(I)||' ')
              ,TX6=decode(H_TX6(I),null,H_TX6(I),H_TX6(I)||' ')
              ,TX7=decode(H_TX7(I),null,H_TX7(I),H_TX7(I)||' ')
              ,TX8=decode(H_TX8(I),null,H_TX8(I),H_TX8(I)||' ')
              ,TX9=decode(H_TX9(I),null,H_TX9(I),H_TX9(I)||' ')
              ,TX10=decode(H_TX10(I),null,H_TX10(I),H_TX10(I)||' ')
              ,TX11=decode(H_TX11(I),null,H_TX11(I),H_TX11(I)||' ')
              ,TX12=decode(H_TX12(I),null,H_TX12(I),H_TX12(I)||' ')
              ,TX13=decode(H_TX13(I),null,H_TX13(I),H_TX13(I)||' ')
              ,TX14=decode(H_TX14(I),null,H_TX14(I),H_TX14(I)||' ')
              ,TX158=decode(H_TX158(I),null,H_TX158(I),H_TX158(I)||' ')
            WHERE CONTACT_POINT_ID=H_CONTACT_POINT_ID(I);
            log ('Done'); 
        EXCEPTION  WHEN bulk_errors THEN 
          l_err_count := SQL%BULK_EXCEPTIONS.COUNT; 
          FOR indx IN 1..l_err_count LOOP 
            l_err_index := SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX; 
            l_sql_errm  := sqlerrm(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE); 
            IF (instr(l_sql_errm,'ORA-00001')>0) THEN  
              log ('Exception DUP_VAL_ON_INDEX occured while inserting a Contact Point with CONTACT_POINT_ID - '||H_CONTACT_POINT_ID(l_err_index)); 
              DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE ENTITY='CONTACT_POINTS' AND OPERATION='U' AND RECORD_ID=H_CONTACT_POINT_ID(l_err_index);	
            ELSE 
              IF p_bulk_sync_type = 'DQM_SYNC' THEN 
                UPDATE hz_dqm_sync_interface 
                  SET  error_data = l_sql_errm 
                  ,staged_flag    = decode (error_data, NULL, 'N', 'E') 
                WHERE rowid       = H_ROWID(l_err_index); 
              ELSIF  p_bulk_sync_type = 'IMPORT_SYNC' THEN 
                -- Insert the Error Record into HZ_DQM_SYNC_INTERFACE table 
                insert_dqm_sync_error_rec(H_CPT_PARTY_ID(l_err_index), H_CONTACT_POINT_ID(l_err_index), H_CPT_PARTY_SITE_ID(l_err_index), H_CPT_ORG_CONTACT_ID(l_err_index), 'CONTACT_POINTS', p_operation, 'E', 'N', l_sql_errm); 
              END IF; 
            END IF; 
          END LOOP; 
        END; 
      END IF;

      IF l_last_fetch THEN
        -- Update HZ_STAGED_PARTIES, if corresponding child entity records 
        -- CONTACT_POINTS (in this case), have been inserted/updated 

        log ('Updating D_CPT column to SYNC in HZ_STAGED_PARTIES table for all related records...',FALSE); 
        --Fix for bug 5048604, to update concat_col during update of denorm column 
        FORALL I IN H_CONTACT_POINT_ID.FIRST..H_CONTACT_POINT_ID.LAST 
          UPDATE HZ_STAGED_PARTIES set 
            D_CPT = 'SYNC' 
           ,CONCAT_COL = CONCAT_COL 
          WHERE PARTY_ID = H_CPT_PARTY_ID(I); 
        log ('Done'); 

      -- REPURI. Bug 4884742. 
      -- Bulk Insert the Import of Contact Points into  Shadow Sync Interface table 
      -- if Shadow Staging has already run and completed successfully 
      IF ((p_bulk_sync_type = 'IMPORT_SYNC') AND 
          (HZ_DQM_SYNC.is_shadow_staging_complete)) THEN 
        BEGIN 
           -- REPURI. Bug 4968126. 
           -- Using the Merge instead of Insert statement 
           -- so that duplicate records dont get inserted. 
          log ('Merging data into HZ_DQM_SH_SYNC_INTERFACE...',FALSE); 
          FORALL I in l_st..l_en  
            MERGE INTO hz_dqm_sh_sync_interface S 
              USING ( 
                SELECT 
                   H_CPT_PARTY_ID(I)       AS party_id 
                  ,H_CONTACT_POINT_ID(I)   AS record_id 
                  ,H_CPT_PARTY_SITE_ID(I)  AS party_site_id 
                  ,H_CPT_ORG_CONTACT_ID(I) AS org_contact_id 
                FROM dual ) T 
              ON (S.entity                   = 'CONTACT_POINTS'           AND 
                  S.party_id                 = T.party_id                 AND 
                  S.record_id                = T.record_id                AND 
                  NVL(S.party_site_id, -99)  = NVL(T.party_site_id, -99)  AND 
                  NVL(S.org_contact_id, -99) = NVL(T.org_contact_id, -99) AND 
                  S.staged_flag              <> 'E') 
              WHEN NOT MATCHED THEN 
              INSERT ( 
                PARTY_ID, 
                RECORD_ID, 
                PARTY_SITE_ID, 
                ORG_CONTACT_ID, 
                ENTITY, 
                OPERATION, 
                STAGED_FLAG, 
                REALTIME_SYNC_FLAG, 
                CREATED_BY, 
                CREATION_DATE, 
                LAST_UPDATE_LOGIN, 
                LAST_UPDATE_DATE, 
                LAST_UPDATED_BY, 
                SYNC_INTERFACE_NUM 
              ) VALUES ( 
                H_CPT_PARTY_ID(I), 
                H_CONTACT_POINT_ID(I), 
                H_CPT_PARTY_SITE_ID(I), 
                H_CPT_ORG_CONTACT_ID(I), 
                'CONTACT_POINTS', 
                p_operation, 
                'N', 
                'N', 
                hz_utility_pub.created_by, 
                hz_utility_pub.creation_date, 
                hz_utility_pub.last_update_login, 
                hz_utility_pub.last_update_date, 
                hz_utility_pub.user_id, 
                HZ_DQM_SH_SYNC_INTERFACE_S.nextval 
            ); 
        log ('Done'); 
        EXCEPTION WHEN OTHERS THEN 
              log ('Exception occured while inserting data into HZ_DQM_SH_SYNC_INTERFACE Table');   
              log ('Eror Message is - '|| sqlerrm);   
        END; 
      END IF; 

        FND_CONCURRENT.AF_Commit;
        EXIT;
      END IF;

      FND_CONCURRENT.AF_Commit;

    END LOOP;
    log ('End Synchronizing Contact Points'); 
  END;

  PROCEDURE open_bulk_imp_sync_party_cur( 
    p_batch_id        IN      NUMBER, 
    p_batch_mode_flag IN      VARCHAR2, 
    p_from_osr        IN      VARCHAR2, 
    p_to_osr          IN      VARCHAR2, 
    p_os              IN      VARCHAR2, 
    p_party_type      IN      VARCHAR2, 
    p_operation       IN      VARCHAR2, 
    x_sync_party_cur  IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    IF p_party_type = 'ORGANIZATION' THEN
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, p.ROWID 
              ,p.PARTY_NAME
              ,p.PARTY_NUMBER
              ,p.PARTY_TYPE
              ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
              ,op.DUNS_NUMBER_C
              ,op.TAX_NAME
              ,op.TAX_REFERENCE
              ,op.JGZZ_FISCAL_CODE
              ,op.SIC_CODE
              ,op.SIC_CODE_TYPE
              ,p.CATEGORY_CODE
              ,p.REFERENCE_USE_FLAG
              ,op.CORPORATION_CLASS
        FROM   HZ_PARTIES p, HZ_IMP_PARTIES_SG ps, HZ_IMP_BATCH_DETAILS bd 
              ,HZ_ORGANIZATION_PROFILES op 
        WHERE  p.request_id         = bd.main_conc_req_id 
        AND    bd.batch_id          = ps.batch_id 
        AND    p.PARTY_TYPE         = 'ORGANIZATION' 
        AND    p.party_id           = ps.party_id 
        AND    ps.batch_id          = p_batch_id 
        AND    ps.party_orig_system = p_os 
        AND    ps.batch_mode_flag   = p_batch_mode_flag 
        AND    ps.action_flag       = p_operation 
        AND    p.party_id           = op.party_id 
        AND    ps.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
        AND   (p.status = 'M' OR op.effective_end_date IS NULL); 
    ELSIF p_party_type = 'PERSON' THEN
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, p.ROWID 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,pe.TAX_NAME
                  ,pe.TAX_REFERENCE
                  ,pe.JGZZ_FISCAL_CODE
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
        FROM   HZ_PARTIES p, HZ_IMP_PARTIES_SG ps, HZ_IMP_BATCH_DETAILS bd 
              ,HZ_PERSON_PROFILES pe 
        WHERE  p.request_id         = bd.main_conc_req_id 
        AND    bd.batch_id          = ps.batch_id 
        AND    p.PARTY_TYPE         = 'PERSON' 
        AND    p.party_id           = ps.party_id 
        AND    ps.batch_id          = p_batch_id 
        AND    ps.party_orig_system = p_os 
        AND    ps.batch_mode_flag   = p_batch_mode_flag 
        AND    ps.action_flag       = p_operation 
        AND    p.party_id           = pe.party_id 
        AND    ps.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
        AND   (p.status = 'M' OR pe.effective_end_date IS NULL); 
    ELSE
      open x_sync_party_cur FOR 
        SELECT p.PARTY_ID, p.STATUS, p.ROWID 
                  ,p.PARTY_NAME
                  ,p.PARTY_NUMBER
                  ,p.PARTY_TYPE
                  ,p.PARTY_NAME || ' ' || p.KNOWN_AS || ' ' || p.KNOWN_AS2 || ' ' || p.KNOWN_AS3 || ' '|| p.KNOWN_AS4 || ' '|| p.KNOWN_AS5
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,p.CATEGORY_CODE
                  ,p.REFERENCE_USE_FLAG
                  ,NULL
        FROM   HZ_PARTIES p, HZ_IMP_PARTIES_SG ps, HZ_IMP_BATCH_DETAILS bd 
        WHERE  p.request_id         = bd.main_conc_req_id 
        AND    bd.batch_id          = ps.batch_id 
        AND    p.party_id           = ps.party_id 
        AND    ps.batch_id          = p_batch_id 
        AND    ps.party_orig_system = p_os 
        AND    ps.batch_mode_flag   = p_batch_mode_flag 
        AND    ps.action_flag       = p_operation 
        AND    p.party_type         <> 'PERSON' 
        AND    p.party_type         <> 'ORGANIZATION' 
        AND    p.party_type         <> 'PARTY_RELATIONSHIP' 
        AND    ps.party_orig_system_reference between p_from_osr and p_to_osr; 
    END IF;

    hz_trans_pkg.set_party_type(p_party_type); 

  END open_bulk_imp_sync_party_cur;


  PROCEDURE open_bulk_imp_sync_psite_cur ( 
    p_batch_id             IN      NUMBER, 
    p_batch_mode_flag      IN      VARCHAR2, 
    p_from_osr             IN      VARCHAR2, 
    p_to_osr               IN      VARCHAR2, 
    p_os                   IN      VARCHAR2, 
    p_operation            IN      VARCHAR2, 
    x_sync_party_site_cur  IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_party_site_cur FOR 
      SELECT /*+ ORDERED USE_NL(ps l) */ 
         ps.PARTY_SITE_ID 
        ,ps.PARTY_ID 
        ,NULL 
        ,ps.STATUS 
        ,ps.ROWID 
        ,rtrim(l.address1 || ' ' || l.address2 || ' ' || l.address3 || ' ' || l.address4)
        ,l.CITY
        ,l.POSTAL_CODE
        ,l.PROVINCE
        ,l.STATE
        ,ps.PARTY_SITE_NUMBER
        ,ps.PARTY_SITE_NAME
        ,l.COUNTY
        ,l.COUNTRY
        ,ps.IDENTIFYING_ADDRESS_FLAG
        ,ps.STATUS
        ,l.ADDRESS1
      FROM hz_locations l, hz_party_sites ps, 
           hz_imp_addresses_sg addr_sg, hz_imp_batch_details bd 
      WHERE l.request_id               = bd.main_conc_req_id 
      AND    bd.batch_id               = addr_sg.batch_id 
      AND    l.location_id             = ps.location_id 
      AND    addr_sg.batch_id          = p_batch_id 
      AND    addr_sg.batch_mode_flag   = p_batch_mode_flag 
      AND    addr_sg.party_orig_system = p_os 
      AND    addr_sg.party_site_id     = ps.party_site_id 
      AND    addr_sg.action_flag       = p_operation 
      AND    addr_sg.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
      AND    (ps.status IS NULL OR ps.status = 'A' OR ps.status = 'I'); 

  END open_bulk_imp_sync_psite_cur; 


  PROCEDURE open_bulk_imp_sync_ct_cur ( 
    p_batch_id             IN      NUMBER, 
    p_batch_mode_flag      IN      VARCHAR2, 
    p_from_osr             IN      VARCHAR2, 
    p_to_osr               IN      VARCHAR2, 
    p_os                   IN      VARCHAR2, 
    p_operation            IN      VARCHAR2, 
    x_sync_contact_cur     IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_contact_cur FOR 
      SELECT 
         /*+ ORDERED USE_NL(R OC PP)*/
         oc.ORG_CONTACT_ID 
        ,r.OBJECT_ID 
        ,r.PARTY_ID 
        ,r.STATUS 
        ,oc.ROWID 
        ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
        ,oc.CONTACT_NUMBER
        ,oc.JOB_TITLE
      FROM hz_org_contacts oc, hz_imp_contacts_sg ocsg, hz_imp_batch_details bd, 
           hz_relationships r, hz_person_profiles pp
      WHERE ocsg.batch_mode_flag     = p_batch_mode_flag 
      AND   oc.party_relationship_id = r.relationship_id 
      AND   ocsg.batch_id            = p_batch_id 
      AND   ocsg.sub_orig_system     = p_os 
      AND   ocsg.contact_id          = oc.org_contact_id 
      AND   oc.request_id            = bd.main_conc_req_id 
      AND   bd.batch_id              = ocsg.batch_id 
      AND   r.subject_id             = pp.party_id 
      AND   r.subject_type           = 'PERSON' 
      AND   r.SUBJECT_TABLE_NAME     = 'HZ_PARTIES'
      AND   r.OBJECT_TABLE_NAME      = 'HZ_PARTIES'
      AND   DIRECTIONAL_FLAG         = 'F' 
      AND   ocsg.action_flag          = p_operation 
      AND   pp.effective_end_date  IS NULL 
      AND   ocsg.sub_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
      AND   (oc.status IS NULL OR oc.status = 'A' OR oc.status = 'I')
      AND   (r.status  IS NULL OR r.status  = 'A' OR r.status  = 'I') 
      UNION 
      SELECT 
         /*+ ORDERED USE_NL(R OC PP)*/
         oc.ORG_CONTACT_ID 
        ,r.OBJECT_ID 
        ,r.PARTY_ID 
        ,r.STATUS 
        ,oc.ROWID 
        ,rtrim(pp.person_first_name || ' ' || pp.person_last_name)
        ,oc.CONTACT_NUMBER
        ,oc.JOB_TITLE
      FROM hz_org_contacts oc, hz_imp_relships_sg rsg, hz_imp_batch_details bd 
          ,hz_relationships r, hz_person_profiles pp 
      WHERE rsg.batch_mode_flag     = p_batch_mode_flag 
      AND   rsg.batch_id            = p_batch_id 
      AND   rsg.sub_orig_system     = p_os 
      AND   rsg.relationship_id     = oc.party_relationship_id 
      AND   oc.request_id           = bd.main_conc_req_id 
      AND   bd.batch_id             = rsg.batch_id 
      AND   rsg.relationship_id     = r.relationship_id 
      AND   r.directional_flag      = 'F' 
      AND   r.subject_id            = pp.party_id 
      AND   r.subject_type          = 'PERSON' 
      AND   r.object_type           = 'ORGANIZATION' 
      AND   r.SUBJECT_TABLE_NAME    = 'HZ_PARTIES' 
      AND   r.OBJECT_TABLE_NAME     = 'HZ_PARTIES' 
      AND   rsg.action_flag         = p_operation 
      AND   pp.effective_end_date   IS NULL 
      AND   rsg.sub_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
      AND   (oc.status IS NULL OR oc.status = 'A' OR oc.status = 'I')
      AND   (r.status  IS NULL OR r.status  = 'A' OR r.status  = 'I');
  END open_bulk_imp_sync_ct_cur; 

  PROCEDURE open_bulk_imp_sync_cpt_cur ( 
    p_batch_id             IN      NUMBER, 
    p_batch_mode_flag      IN      VARCHAR2, 
    p_from_osr             IN      VARCHAR2, 
    p_to_osr               IN      VARCHAR2, 
    p_os                   IN      VARCHAR2, 
    p_operation            IN      VARCHAR2, 
    x_sync_cpt_cur         IN OUT  HZ_DQM_SYNC.SyncCurTyp) IS 
  BEGIN
    OPEN x_sync_cpt_cur FOR 
      SELECT 
         /*+ ORDERED USE_NL(cp) */ 
         cp.CONTACT_POINT_ID 
        ,cps.party_id 
        ,decode (cp.owner_table_name, 'HZ_PARTY_SITES', cp.owner_table_id, NULL) party_site_id 
        ,NULL 
        ,cp.CONTACT_POINT_TYPE 
        ,cp.STATUS 
        ,cp.ROWID 
        ,translate(phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' || translate(phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ') || ' ' ||  translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
        ,cp.PHONE_NUMBER
        ,cp.PHONE_AREA_CODE
        ,cp.PHONE_COUNTRY_CODE
        ,cp.EMAIL_ADDRESS
        ,cp.URL
        ,cp.PRIMARY_FLAG
        ,translate(phone_country_code|| ' ' || phone_area_code||' ' || phone_number,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ')
        ,cp.PHONE_LINE_TYPE
        ,cp.STATUS
        ,cp.CONTACT_POINT_PURPOSE
      FROM hz_contact_points cp, hz_imp_contactpts_sg cps, hz_imp_batch_details bd 
      WHERE cp.request_id         = bd.main_conc_req_id 
      AND   bd.batch_id           = cps.batch_id 
      AND   cp.contact_point_id   = cps.contact_point_id 
      AND   cps.batch_id          = p_batch_id 
      AND   cps.party_orig_system = p_os 
      AND   cps.batch_mode_flag   = p_batch_mode_flag 
      AND   cps.action_flag       = p_operation
      AND   cps.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr 
      AND   (cp.status IS NULL OR cp.status = 'A' OR cp.status = 'I'); 

    END open_bulk_imp_sync_cpt_cur; 

END;

/

  GRANT EXECUTE ON "APPS"."HZ_STAGE_MAP_TRANSFORM" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."HZ_STAGE_MAP_TRANSFORM" TO "AR";
