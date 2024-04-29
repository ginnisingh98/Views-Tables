--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_STAGE_SHADOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_STAGE_SHADOW" AS
/*$Header: ARHDSHSB.pls 120.13 2006/05/05 22:35:37 repuri noship $ */


g_batch_size NUMBER := 200;
g_num_stage_steps NUMBER := 3;
g_num_stage_new_steps NUMBER := 6;
g_schema_name VARCHAR2(30) ;
G_PS_QKEY_STR VARCHAR2(400) := '''#''||H_TX22(I)||''#''||H_TX14(I)||''#''||'||
    'H_TX21(I)||''#''||H_TX10(I)||''#''||H_TX11(I)||''#''||'||
    'TRANSLATE(INITCAP(H_TX4(I)),''ABCDEFGHIJKLMNOPQRSTUVWXYZ! abcdefghijklmnopqrstuvwxyz'',''ABCDEFGHIJKLMNOPQRSTUVWXYZ'')||''#''';
--#EXACT(Country)#WR(State)#Cleanse(County)#Cleanse(City)#postal_code#first/letter(cleanse(address))#
G_C_QKEY_STR VARCHAR2(200) := '''#''||TRANSLATE(INITCAP(H_TX23(I)),''ABCDEFGHIJKLMNOPQRSTUVWXYZ! abcdefghijklmnopqrstuvwxyz'',''ABCDEFGHIJKLMNOPQRSTUVWXYZ'')||''#''||H_TX22(I)||''#'''; -- #first letters(WR(Name))#jobtitle#
G_CPT_QKEY_STR VARCHAR2(200) := '''#''||H_CONTACT_POINT_TYPE(I)||''#''||H_TX2(I)||''#''||H_TX5(I)||''#'''; -- #cpttype#phonenumber#email#


PROCEDURE l(str VARCHAR2) IS
BEGIN
  HZ_GEN_PLSQL.add_line(str);
END;

PROCEDURE verify_all_procs;

PROCEDURE create_btree_indexes (p_entity VARCHAR2);

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

PROCEDURE generate_map_proc (
   p_entity             IN      VARCHAR2,
   p_proc_name          IN      VARCHAR2,
   p_command            IN      VARCHAR2
);

PROCEDURE generate_party_query_proc;
PROCEDURE generate_contact_query_proc;
PROCEDURE generate_contact_pt_query_proc;
PROCEDURE generate_party_site_query_proc;

PROCEDURE generate_declarations;
PROCEDURE generate_uds_proc;

PROCEDURE create_initial_prefs( p_tablespace IN VARCHAR2,
                                l_num_prll OUT nocopy VARCHAR2,
                                l_idx_mem OUT nocopy VARCHAR2) IS
ctx_tbsp VARCHAR2(255);
ctx_index_tbsp VARCHAR2(255);

BEGIN
  --- Create memory, storage and lexer preferences.

  log('---------------------------------------------------');
  log('Calling create_initial_prefs');

    IF FND_PROFILE.value('HZ_DQM_INDEX_MEMORY') IS NOT NULL THEN
      l_idx_mem := FND_PROFILE.value('HZ_DQM_INDEX_MEMORY');
    ELSE
      BEGIN
        SELECT PAR_VALUE INTO l_idx_mem
        FROM CTX_PARAMETERS
        WHERE PAR_NAME = 'MAX_INDEX_MEMORY';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT PAR_VALUE INTO l_idx_mem
            FROM CTX_PARAMETERS
            WHERE PAR_NAME = 'DEFAULT_INDEX_MEMORY';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_idx_mem := '0';
          END;
      END;
    END IF;

    IF FND_PROFILE.value('HZ_DQM_INDEX_PARALLEL') IS NOT NULL THEN
      l_num_prll := FND_PROFILE.value('HZ_DQM_INDEX_PARALLEL');
    ELSE
      l_num_prll := NULL;
    END IF;

    BEGIN
        ctx_ddl.drop_preference('HZ_DQM_STORAGE');
      EXCEPTION
       WHEN OTHERS THEN
         NULL;
      END;

    IF p_tablespace IS NOT NULL THEN
      ctx_tbsp := p_tablespace;
      ctx_index_tbsp := p_tablespace;
    ELSE
      select tablespace, index_tablespace
      into ctx_tbsp, ctx_index_tbsp
      from fnd_product_installations
      where application_id = '222';
    END IF;

      ctx_ddl.create_preference('HZ_DQM_STORAGE', 'BASIC_STORAGE');
      ctx_ddl.set_attribute('HZ_DQM_STORAGE', 'I_TABLE_CLAUSE', 'tablespace '|| ctx_tbsp|| ' storage (initial 4K next 8M pctincrease 0)');
      ctx_ddl.set_attribute('HZ_DQM_STORAGE', 'K_TABLE_CLAUSE', 'tablespace ' || ctx_tbsp || ' storage (initial 4K next 8M pctincrease 0)');
      ctx_ddl.set_attribute('HZ_DQM_STORAGE', 'R_TABLE_CLAUSE', 'tablespace '|| ctx_tbsp || ' storage (initial 4K next 8M pctincrease 0)  lob (data) store as (cache) ');
      ctx_ddl.set_attribute('HZ_DQM_STORAGE', 'I_INDEX_CLAUSE', 'tablespace '|| ctx_index_tbsp || '  storage (initial 4K next 8M pctincrease 0)  compress 2');

  BEGIN
    ctx_ddl.drop_preference('dqm_lexer');
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  ctx_ddl.create_preference('dqm_lexer', 'BASIC_LEXER');
  ctx_ddl.set_attribute ( 'dqm_lexer', 'index_themes', 'NO');
  ctx_ddl.set_attribute ( 'dqm_lexer', 'index_text', 'YES');

END ;



FUNCTION wait_for_request(
    p_request_id NUMBER) RETURN VARCHAR2;

FUNCTION has_trx_context(proc VARCHAR2) RETURN BOOLEAN;
FUNCTION has_context(proc VARCHAR2) RETURN BOOLEAN;

--------------------------------------------------------------
-- CHANGE: This should change to reflect the correct datastore
--------------------------------------------------------------

PROCEDURE insert_into_thin_tables( p_entity IN VARCHAR2) IS
  BEGIN
    log ('-------------------------------------');
    log ('Calling insert_into_thin_tables for ' || p_entity);


    IF p_entity = 'PARTIES'
    THEN
        log('Start Time for Parties ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
        insert /*+ append */ into hz_thin_st_parties
        (party_id, status, partition_id, parent_rowid, concat_col)
        select party_id, status, decode(TX36, 'ORGANIZATION ',0,'PERSON ',1,1),ROWID,null
        from hz_shadow_st_parties;
        log('End Time for Parties ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
    ELSIF p_entity = 'PARTY_SITES'
    THEN
        log('Start Time for Party Sites ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
        insert /*+ append */ into hz_thin_st_psites
        (party_id, party_site_id, person_party_id, qkey, org_contact_id,
         parent_rowid, concat_col,status_flag) -- Bug No: 4299785
        select decode(party_id,person_party_id,NULL,party_id), party_site_id,person_party_id, qkey,org_contact_id,ROWID,null,status_flag -- Fix for bug 5155761
        --select party_id, party_site_id,person_party_id, qkey,org_contact_id,ROWID,null,status_flag -- Bug No: 4299785
	from hz_shadow_st_psites;
        log('End Time for Party Sites ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
    ELSIF p_entity = 'CONTACTS'
    THEN
        log('Start Time for Contacts ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
        insert /*+ append */ into hz_thin_st_contacts
        (party_id, person_party_id, qkey, org_contact_id, parent_rowid, concat_col,status_flag) -- Fix for bug 5155761
         select decode(party_id,person_party_id,NULL,party_id),person_party_id, qkey,org_contact_id,ROWID,null,status_flag -- Fix for bug 5155761
        --(party_id, qkey, org_contact_id, parent_rowid, concat_col,status_flag)-- Bug No: 4299785
        --select party_id, qkey,org_contact_id,ROWID,null,status_flag  -- Bug No: 4299785
        from hz_shadow_st_contacts;
        log('End Time for Contacts ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
    ELSIF p_entity = 'CONTACT_POINTS'
    THEN
        log('Start Time for Contact Points ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
        insert /*+ append */ into hz_thin_st_cpts
        (party_id, partition_id, contact_point_id, party_site_id,
         person_party_id, parent_rowid, org_contact_id, qkey, concat_col,status_flag) -- Bug No: 4299785
         select decode(party_id,person_party_id,NULL,party_id), decode(contact_point_type,'PHONE',0,'EMAIL',1,2),contact_point_id,party_site_id, person_party_id,ROWID,org_contact_id, qkey, null,status_flag -- Fix for bug 5155761
        --select party_id, decode(contact_point_type,'PHONE',0,'EMAIL',1,2),contact_point_id,party_site_id,person_party_id,ROWID,org_contact_id, qkey, null,status_flag -- Bug No: 4299785
        from hz_shadow_st_cpts;
        log('End Time for Contact Points ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
    END IF ;
END ;


PROCEDURE truncate_staging_tables IS

l_owner VARCHAR2(255);
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
l_sql  VARCHAR2(4000);
BEGIN
  log('---------------------------------------------------');
  log('Calling truncate_staging_tables ');
   IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
/*    select owner into l_owner from sys.all_objects
    where object_name = 'HZ_STAGED_PARTIES' and OBJECT_TYPE = 'TABLE' and owner = l_owner1;*/
    l_sql := ' select owner from sys.all_tables where table_name = ''HZ_STAGED_PARTIES'' and owner = :1';
    EXECUTE IMMEDIATE l_sql into l_owner USING l_owner1;
   END IF;
    log('Truncating HZ_SHADOW_ST_PARTIES .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_SHADOW_ST_PARTIES';
    log('Done');

    log('Truncating HZ_SHADOW_ST_PSITES .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_SHADOW_ST_PSITES';
    log('Done');

    log('Truncating HZ_SHADOW_ST_CONTACTS .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_SHADOW_ST_CONTACTS';
    log('Done');

    log('Truncating HZ_SHADOW_ST_CPTS .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.hz_shadow_st_cpts';
    log('Done');

    /* Not Needed for staging SHADOW
    log('Attempting to truncate HZ_DQM_SYNC_INTERFACE ..',FALSE);
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.hz_dqm_sync_interface';
      log('Done Successfully');
    EXCEPTION
      WHEN OTHERS THEN
        log('Lock on table. Unable to truncate');
    END;
    */

END;

PROCEDURE truncate_thin_tables IS
l_owner VARCHAR2(255);
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
l_sql VARCHAR2(4000);
BEGIN
 log('---------------------------------------------------');
 log('Calling truncate_thin_tables ');

   IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
    l_sql := ' select owner from sys.all_tables where table_name = ''HZ_THIN_ST_PARTIES'' and owner = :1';
    EXECUTE IMMEDIATE l_sql into l_owner USING l_owner1;
   /* select owner into l_owner from sys.all_objects
    where object_name = 'HZ_THIN_ST_PARTIES' and OBJECT_TYPE = 'TABLE' and
    owner = l_owner1;*/
   END IF;
    log('Truncating HZ_THIN_ST_PARTIES .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_THIN_ST_PARTIES';
    log('Done');

    log('Truncating HZ_THIN_ST_PSITES .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_THIN_ST_PSITES';
    log('Done');

    log('Truncating HZ_THIN_ST_CONTACTS .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_THIN_ST_CONTACTS';
    log('Done');

    log('Truncating HZ_THIN_ST_CPTS .. ', FALSE);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_owner||'.HZ_THIN_ST_CPTS';
    log('Done');

    EXCEPTION
      WHEN OTHERS THEN
        log('Lock on table. Unable to truncate'||SQLERRM);
END;




PROCEDURE generate_map_pkg_nolog IS
BEGIN
    HZ_GEN_PLSQL.new('HZ_STAGE_MAP_TRANSFORM_SHADOW', 'PACKAGE BODY');
    l('CREATE OR REPLACE PACKAGE BODY HZ_STAGE_MAP_TRANSFORM_SHADOW AS');

    generate_declarations;
    generate_uds_proc;
    generate_party_query_proc;
    generate_contact_query_proc;
    generate_contact_pt_query_proc;
    generate_party_site_query_proc;

    l('END;');

    HZ_GEN_PLSQL.compile_code;
END;

PROCEDURE generate_uds_proc(p_entity varchar2, p_proc_name varchar2) IS
  CURSOR c_trns(cp_entity VARCHAR2) IS
    SELECT staged_attribute_column
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = cp_entity
      AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
      AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
      --AND nvl(f.PRIMARY_FLAG,'Y') = 'Y' --5044716
      ;
  l_trns varchar2(2000);
  l_trns1 varchar2(2000);
  first_time boolean := TRUE;
BEGIN
  l('procedure '||p_proc_name||'(rid in rowid, tlob in out clob) IS');
  l('data varchar2(32767);');
  l('l_rec_id NUMBER(15);');
  l('BEGIN');
  l(' FOR R IN ( ');
  l('   SELECT ');
  OPEN c_trns(p_entity);
  LOOP
    FETCH c_trns INTO l_trns;
    EXIT WHEN c_trns%NOTFOUND;
    if first_time = true then
       first_time := false;
    else
       l('||');
    end if;
    -- To add '<TX1>'||TX1||'</TX1>'
    l('''<'||l_trns||'>'''||'||'||l_trns||'||''</'||l_trns||'>''');
    END LOOP;
  CLOSE c_trns; -- Nimit New

  -- Begin Code changes for bug 5155761
  if p_entity = 'PARTY' then
      l(' data ');
      l(' ,p.STATUS  from hz_shadow_st_parties p,hz_thin_st_parties t '); -- Bug 5209633
  end if;

   --Create party_id, person_party and contact_point_type section
  if p_entity = 'PARTY_SITES' then
    l_trns := 'PARTY_ID';
    l_trns1 := 'P.PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l_trns := 'PERSON_PARTY_ID';
    l_trns1 := 'P.PERSON_PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l(' data ');
    l('  from hz_shadow_st_psites p,hz_thin_st_psites t ');
  end if;
  if p_entity = 'CONTACTS' then
    l_trns := 'PARTY_ID';
    l_trns1 := 'P.PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l_trns := 'PERSON_PARTY_ID';
    l_trns1 := 'P.PERSON_PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l(' data ');
    l('  from hz_shadow_st_contacts p,hz_thin_st_contacts t ');
  end if;
  if p_entity = 'CONTACT_POINTS' then
    l_trns := 'PARTY_ID';
    l_trns1 := 'P.PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l_trns := 'PERSON_PARTY_ID';
    l_trns1 := 'P.PERSON_PARTY_ID';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l_trns := 'CONTACT_POINT_TYPE';
    l_trns1 := 'P.CONTACT_POINT_TYPE';
    l('||');
    l('''<'||l_trns||'>'''||'||'||l_trns1||'||''</'||l_trns||'>''');
    l(' data ');
    l(' from HZ_SHADOW_ST_CPTS p,hz_thin_st_cpts t '); -- Bug 5209633
  end if;
  l('  where t.ROWID = rid and p.ROWID=parent_rowid) LOOP ');
  l('    data := R.data;');
  l('    dbms_lob.writeappend(tlob, length(data),data);');
  l('  END LOOP;');
  l('END;');
  log('Done');
END;

PROCEDURE generate_uds_proc IS
BEGIN
  log('---------------------------------------------------');
  log('Calling generate_uds_proc');
  generate_uds_proc('PARTY', 'PARTY_DS');
  generate_uds_proc('PARTY_SITES', 'PARTY_SITE_DS');
  generate_uds_proc('CONTACTS', 'CONTACT_DS');
  generate_uds_proc('CONTACT_POINTS', 'CONTACT_POINT_DS');
END;
-------------------------------------------------------------------------------------
-- CHANGE :  See if you can add a procedure called generate_user_ds_columns
---          which will generate four procedures party_pref, ps_pref, ct_pref, cpt_pref
--           in HZ_STAGE_MAP_TRANSFORM_R12
------------------------------------------------------------------------------------


PROCEDURE generate_map_pkg IS
BEGIN
    log('------------------------------------------------');
    log('Calling generate_map_pkg');
    log('Generating package body for HZ_STAGE_MAP_TRANSFORM_SHADOW');
    HZ_GEN_PLSQL.new('HZ_STAGE_MAP_TRANSFORM_SHADOW', 'PACKAGE BODY');
    l('CREATE OR REPLACE PACKAGE BODY HZ_STAGE_MAP_TRANSFORM_SHADOW AS');

    generate_declarations;
    generate_uds_proc;
    generate_party_query_proc;
    generate_contact_query_proc;
    generate_contact_pt_query_proc;
    generate_party_site_query_proc;

    l('END;');

    log('Compiling package body .. ', false);
    HZ_GEN_PLSQL.compile_code;
    log('Done');
END;


PROCEDURE add_section (
  p_dsname VARCHAR2,
  p_attr VARCHAR2,
  p_stype VARCHAR2) IS
BEGIN
  log('------------------------------------');
  log('Calling add_section');
  IF p_stype = 'ZONE' THEN
    ctx_ddl.add_zone_section(p_dsname, p_attr,p_attr);
  ELSE
    ctx_ddl.add_field_section(p_dsname, p_attr,p_attr,TRUE);
  END IF;
END;

PROCEDURE create_uds_prefs
IS
BEGIN
  log(' In create_uds_prefs ');
    begin
      log('Trying to drop user data store preferences');
      ctx_ddl.drop_preference(G_SCHEMA_NAME || '.hz_party_uds');
      ctx_ddl.drop_preference(G_SCHEMA_NAME || '.hz_party_site_uds');
      ctx_ddl.drop_preference(G_SCHEMA_NAME || '.hz_contact_uds');
      ctx_ddl.drop_preference(G_SCHEMA_NAME || '.hz_contact_point_uds');

    exception
      when others then
        log(' Exception while dropping preferences');
        null;
    end;

    begin
            log('Creating user data store preferences for PARTY');
            ctx_ddl.create_preference('hz_party_uds', 'user_datastore');
            ctx_ddl.set_attribute(   'hz_party_uds', 'procedure', 'HZ_STAGE_MAP_TRANSFORM_SHADOW.party_ds');
            ctx_ddl.set_attribute(   'hz_party_uds', 'output_type', 'CLOB');

            log('Creating user data store preferences for PARTY SITE');
            ctx_ddl.create_preference('hz_party_site_uds', 'user_datastore');
            ctx_ddl.set_attribute('hz_party_site_uds', 'procedure', 'HZ_STAGE_MAP_TRANSFORM_SHADOW.party_site_ds');
            ctx_ddl.set_attribute('hz_party_site_uds', 'output_type', 'CLOB');

            log('Creating user data store preferences for CONTACT');
            ctx_ddl.create_preference('hz_contact_uds', 'user_datastore');
            ctx_ddl.set_attribute('hz_contact_uds', 'procedure', 'HZ_STAGE_MAP_TRANSFORM_SHADOW.contact_ds');
            ctx_ddl.set_attribute('hz_contact_uds', 'output_type', 'CLOB');

            log('Creating user data store preferences for CONTACT POINT');
            ctx_ddl.create_preference('hz_contact_point_uds', 'user_datastore');
            ctx_ddl.set_attribute('hz_contact_point_uds', 'procedure', 'HZ_STAGE_MAP_TRANSFORM_SHADOW.contact_point_ds');
            ctx_ddl.set_attribute('hz_contact_point_uds', 'output_type', 'CLOB');



            exception
            when others then
                log('Error creating preferences. Error is '|| SQLERRM );
                RAISE ;
    end ;

   log('Done creating user data store preferences ') ;
END ;


PROCEDURE create_section_group_prefs(p_entity VARCHAR2) IS

  -- Cursor to get number of active acquistion enabled transformations
  CURSOR c_num_trns(cp_entity VARCHAR2) IS
    SELECT COUNT(1)
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = cp_entity
      AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
      AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
      --AND nvl(f.PRIMARY_FLAG,'Y') = 'Y' --5044716
      ;

  -- Cursor to get active acquistion enabled transformations
  CURSOR c_trns(cp_entity VARCHAR2) IS
    SELECT staged_attribute_column
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = cp_entity
      AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
      AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
      --AND nvl(f.PRIMARY_FLAG,'Y') = 'Y' --5044716
      ;

  l_trns VARCHAR2(255);

  -- Nimit New End
  l_cnt NUMBER;
  l_stype VARCHAR2(255);

  pref_cols VARCHAR2(1000);
  proc_cols VARCHAR2(2000);
  tmp VARCHAR2(2000);
  section_grp_name varchar2(50);

BEGIN
   log('-------------------------------------');
   log('In create_section_group_prefs for ' || p_entity);
   log('Trying to drop section group preferences');
  BEGIN
    IF p_entity='PARTY' THEN
      ctx_ddl.drop_section_group(g_schema_name || '.HZ_DQM_PARTY_GRP');
      /* No Need for R12 SHADOW Staging
      UPDATE HZ_TRANS_ATTRIBUTES_B set TEMP_SECTION=NULL
      WHERE ENTITY_NAME='PARTY';
      */
    END IF;

    IF p_entity='PARTY_SITES' THEN
      ctx_ddl.drop_section_group(G_SCHEMA_NAME || '.HZ_DQM_PS_GRP');
      /* No Need for R12 SHADOW Staging
      UPDATE HZ_TRANS_ATTRIBUTES_B set TEMP_SECTION=NULL
      WHERE ENTITY_NAME='PARTY_SITES';
      */
    END IF;

    IF p_entity='CONTACTS' THEN
      ctx_ddl.drop_section_group(G_SCHEMA_NAME || '.HZ_DQM_CONTACT_GRP');
      /* No Need for R12 SHADOW Staging
      UPDATE HZ_TRANS_ATTRIBUTES_B set TEMP_SECTION=NULL
      WHERE ENTITY_NAME='CONTACTS';
      */
    END IF;

    IF p_entity='CONTACT_POINTS' THEN
      ctx_ddl.drop_section_group(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP');
      /* No Need for R12 SHADOW Staging
      UPDATE HZ_TRANS_ATTRIBUTES_B set TEMP_SECTION=NULL
      WHERE ENTITY_NAME='CONTACT_POINTS';
      */
    END IF;
  /* No Need for R12 SHADOW Staging
  log('Update of temp_section in HZ_TRANS_ATTRIBUTES_B successful for ' || p_entity);
  */
  EXCEPTION
   WHEN OTHERS THEN
     log('Exception thrown. Error message is ' || SQLERRM );
     NULL;
  END;

  IF p_entity='PARTY' THEN
    log('Creating party section group',FALSE);
    ctx_ddl.create_section_group(G_SCHEMA_NAME || '.HZ_DQM_PARTY_GRP','BASIC_SECTION_GROUP');

    OPEN c_trns('PARTY');
    LOOP
      FETCH c_trns INTO l_trns;
      EXIT WHEN c_trns%NOTFOUND;
      add_section(G_SCHEMA_NAME || '.HZ_DQM_PARTY_GRP',l_trns,'FIELD');
    END LOOP;
    CLOSE c_trns;

  END IF;

  IF p_entity='PARTY_SITES' THEN
    log('Creating party site section group',FALSE);
    ctx_ddl.create_section_group(G_SCHEMA_NAME || '.HZ_DQM_PS_GRP','BASIC_SECTION_GROUP');

    OPEN c_trns('PARTY_SITES');
    LOOP
      FETCH c_trns INTO l_trns;
      EXIT WHEN c_trns%NOTFOUND;
      add_section(G_SCHEMA_NAME || '.HZ_DQM_PS_GRP',l_trns,'FIELD');
    END LOOP;
    CLOSE c_trns;
    add_section(G_SCHEMA_NAME || '.HZ_DQM_PS_GRP','PARTY_ID','FIELD'); -- Fix for bug 5155761
    add_section(G_SCHEMA_NAME || '.HZ_DQM_PS_GRP','PERSON_PARTY_ID','FIELD'); -- Fix for bug 5155761

  END IF;

  IF p_entity='CONTACTS' THEN
    log('Creating contact section group',FALSE);
    ctx_ddl.create_section_group(G_SCHEMA_NAME || '.HZ_DQM_CONTACT_GRP','BASIC_SECTION_GROUP');
    OPEN c_trns('CONTACTS');
    LOOP
      FETCH c_trns INTO l_trns;
      EXIT WHEN c_trns%NOTFOUND;
      add_section(G_SCHEMA_NAME || '.HZ_DQM_CONTACT_GRP',l_trns,'FIELD');
    END LOOP;
    CLOSE c_trns;
    add_section(G_SCHEMA_NAME || '.HZ_DQM_CONTACT_GRP','PARTY_ID','FIELD'); -- Fix for bug 5155761
    add_section(G_SCHEMA_NAME || '.HZ_DQM_CONTACT_GRP','PERSON_PARTY_ID','FIELD'); -- Fix for bug 5155761

  END IF;

  IF p_entity='CONTACT_POINTS' THEN
    log('Creating contact point section group',FALSE);
    ctx_ddl.create_section_group(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP','BASIC_SECTION_GROUP');
   -- add_section(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP','CONTACT_POINT_TYPE','FIELD');

    OPEN c_trns('CONTACT_POINTS');
    LOOP
      FETCH c_trns INTO l_trns;
      EXIT WHEN c_trns%NOTFOUND;
      add_section(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP',l_trns,'FIELD');
    END LOOP;
    CLOSE c_trns;
    add_section(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP','CONTACT_POINT_TYPE','FIELD'); -- Fix for bug 5155761
    add_section(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP','PARTY_ID','FIELD'); -- Fix for bug 5155761
    add_section(G_SCHEMA_NAME || '.HZ_DQM_CPT_GRP','PERSON_PARTY_ID','FIELD'); -- Fix for bug 5155761
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    log('Error create_section_group_prefs  '||SQLERRM);
    RAISE;
END;


PROCEDURE create_section_group_prefs IS

BEGIN
  create_section_group_prefs('PARTY');
  create_section_group_prefs('PARTY_SITES');
  create_section_group_prefs('CONTACTS');
  create_section_group_prefs('CONTACT_POINTS');
END;


PROCEDURE drop_context_indexes IS

l_status VARCHAR2(255);
l_index_owner VARCHAR2(255);
l_temp VARCHAR2(255);

l_bool BOOLEAN;

BEGIN

  l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_index_owner);
  log('---------------------------------------------------');
  log('Calling drop_context_indexes');
  log('Dropping Context Indexes on Thin tables');
  BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_parties_t1 FORCE';
      log('Dropped hz_thin_st_parties_t1');
  EXCEPTION
      WHEN OTHERS THEN
       log('Exception while dropping hz_thin_st_parties_t1. Error is ' || SQLERRM );
        NULL;
  END;
  BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_psites_t1 FORCE';
      log('Dropped hz_thin_st_psites_t1');
  EXCEPTION
      WHEN OTHERS THEN
       log('Exception while dropping hz_thin_st_psites_t1. Error is ' || SQLERRM );
        NULL;
  END;
  BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_contacts_t1 FORCE';
      log('Dropped hz_thin_st_contacts_t1');
  EXCEPTION
     WHEN OTHERS THEN
       log('Exception while dropping hz_thin_st_contacts_t1. Error is ' || SQLERRM );
        NULL;
  END;
  BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_cpts_t1 FORCE';
      log('Dropped hz_thin_st_cpts_t1');
  EXCEPTION
      WHEN OTHERS THEN
       log('Exception while dropping hz_thin_st_cpts_t1. Error is ' || SQLERRM );
        NULL;
  END;
  log('Done with dropping context indexes on Thin tables');
END;

PROCEDURE drop_btree_indexes IS
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
BEGIN
log('---------------------------------------------------');
log('Calling drop_btree_indexes');
log('Dropping Btree Indexes on Base Staging tables');
IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
  FOR IDX in (
    SELECT OWNER||'.'||INDEX_NAME idx_name
    FROM sys.all_indexes i, hz_trans_attributes_vl a, hz_trans_functions_vl f
    WHERE f.attribute_id = a.attribute_id
    AND i.owner = l_owner1
    AND f.index_required_flag in ('Y','T')
    AND i.INDEX_NAME = decode(a.entity_name,'PARTY','HZ_SHADOW_ST_PARTIES',
                  'PARTY_SITES','HZ_SHADOW_ST_PSITES','CONTACTS','HZ_SHADOW_ST_CONTACTS',
                  'CONTACT_POINTS','HZ_SHADOW_ST_CPTS')||'_N0'||f.function_id) LOOP
    EXECUTE IMMEDIATE 'DROP INDEX '||IDX.idx_name;
  END LOOP;
   log('Done with dropping btree indexes on Base Staging tables');
  /* Not Needed for R12 SHADOW STAGING
  UPDATE hz_trans_functions_b set index_required_flag='N' where index_required_flag='T';
  */
END IF;
END;


PROCEDURE create_log(
   p_operation VARCHAR2,
   p_step VARCHAR2,
   p_worker_number NUMBER DEFAULT 0,
   p_num_workers NUMBER DEFAULT 0) IS

BEGIN

  INSERT INTO HZ_DQM_STAGE_LOG (
	OPERATION,
	NUMBER_OF_WORKERS,
        WORKER_NUMBER,
	STEP,
	START_FLAG,
	START_TIME,
	END_FLAG,
	END_TIME,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY)
   VALUES (
        substr(p_operation,1,30),
        p_num_workers,
        p_worker_number,
	p_step,
        NULL,
	NULL,
	NULL,
	NULL,
	hz_utility_pub.created_by,
        hz_utility_pub.creation_date,
        hz_utility_pub.last_update_login,
        hz_utility_pub.last_update_date,
        hz_utility_pub.user_id
   );
END;


PROCEDURE Stage (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY   VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_continue		IN	VARCHAR2,
        p_tablespace		IN	VARCHAR2,
	p_index_creation	IN	VARCHAR2
) IS

TYPE nTable IS TABLE OF NUMBER index by binary_integer;
TYPE vTable IS TABLE OF VARCHAR2(255) index by binary_integer;
l_sub_requests nTable;
l_req_status vTable;

uphase VARCHAR2(255);
dphase VARCHAR2(255);
ustatus VARCHAR2(255);
dstatus VARCHAR2(255);
message VARCHAR2(32000);

l_start_flag VARCHAR2(1);
l_end_flag VARCHAR2(1);

CURSOR c_primary(cp_entity_name VARCHAR2) IS
  SELECT f.TRANSFORMATION_NAME, f.STAGED_ATTRIBUTE_COLUMN
  FROM HZ_TRANS_FUNCTIONS_VL f, HZ_TRANS_ATTRIBUTES_VL a
  WHERE PRIMARY_FLAG = 'Y'
  AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
  AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
  AND a.ENTITY_NAME = cp_entity_name;

l_trans_name HZ_TRANS_FUNCTIONS_VL.TRANSFORMATION_NAME%TYPE;
l_stg_attr HZ_TRANS_FUNCTIONS_VL.STAGED_ATTRIBUTE_COLUMN%TYPE;

l_cols VARCHAR2(4000);
l_message VARCHAR2(4000);
l_status VARCHAR2(255) := 'NORMAL';

l_num_workers NUMBER;
l_num_funcs NUMBER;
l_req_id  NUMBER;
l_bool BOOLEAN;
l_continue VARCHAR2(1) := 'N';

l_party_prim_tx NUMBER := 1;
l_ps_prim_tx NUMBER := 1;
l_contact_prim_tx NUMBER := 1;
l_cpt_prim_tx NUMBER := 1;

l_index_owner VARCHAR2(255);
l_temp VARCHAR2(255);

l_idx_mem VARCHAR2(255);
l_num_prll VARCHAR2(255);





T NUMBER;

l_index_creation VARCHAR2(255) := 'PARALLEL';

l_command VARCHAR2(255);
l_last_num_workers NUMBER;
l_num_stage_stepS NUMBER;
reco_staging_size NUMBER;
reco_staging_parties NUMBER;
reco_staging_party_sites NUMBER;
reco_staging_contacts NUMBER;
reco_staging_contact_points NUMBER;
reco_index_size NUMBER;
safety_factor NUMBER(5, 1) := 2.0 ;
sizing_factor NUMBER(5, 1) := 5;

l_index VARCHAR2(255);

l_workers_completed boolean;


l_step VARCHAR2(255);
l_is_wildchar NUMBER;
req_data varchar2(100);

STAGE_ALL_DATA boolean := false;
GENERATE_MAP_PROC boolean := false;
CREATE_INDEXES boolean := false;
GEN_MISSING_INVALID_INDEXES boolean := false;
ESTIMATE_SIZE boolean := false;
STAGE_NEW_TRANSFORMATIONS boolean := false;
ANALYZE_STAGED_TABLES boolean := false;
create_index_flag boolean := false;
wait_for_child_flag boolean := false;

l_rebuild_party_idx boolean;
l_rebuild_psite_idx boolean;
l_rebuild_contact_idx boolean;
l_rebuild_cpt_idx boolean;

BEGIN

  l_index_creation := nvl(p_index_creation,'PARALLEL');

  IF p_num_workers IS NULL THEN
    l_num_workers:=1;
  ELSE
    l_num_workers := to_number(p_num_workers);
  END IF;

  l_command:='STAGE_ALL_DATA';
  l_continue:=nvl(p_continue,'N');
  if (l_command = 'STAGE_ALL_DATA') then
     STAGE_ALL_DATA := true;
     CREATE_INDEXES := true;
     GENERATE_MAP_PROC := true;
  elsif (l_command = 'CREATE_INDEXES') then
    CREATE_INDEXES := true;
    l_continue := 'N';
  elsif (l_command = 'STAGE_NEW_TRANSFORMATIONS') then
    STAGE_NEW_TRANSFORMATIONS := true;
    l_continue := 'N';
  elsif (l_command = 'CREATE_MISSING_INVALID_INDEXES') then
    GEN_MISSING_INVALID_INDEXES := true;
    l_continue := 'N';
  elsif (l_command = 'GENERATE_MAP_PROC') then
    GENERATE_MAP_PROC := true;
    l_continue := 'N';
  elsif (l_command = 'ESTIMATE_SIZE') then
    ESTIMATE_SIZE := true;
    l_continue := 'N';
  elsif (l_command = 'ANALYZE_STAGED_TABLES') then
    ANALYZE_STAGED_TABLES := true;
    l_continue := 'N';
  end if;

  -- REPURI. Bug 4884742. To delete the record
  -- at the beginning of the staging program.

  DELETE FROM HZ_DQM_STAGE_LOG
  WHERE operation = 'SHADOW_STAGING'
  AND   step      = 'COMPLETE';

  -- req_data will be null the first time, by default
  req_data := fnd_conc_global.request_data;

  l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_index_owner);
   -- First Phase
  IF (req_data IS NULL)
  THEN
      retcode := 0;

      log('------------------------------');
      outandlog('Starting Concurrent Program ''Stage Party Data''');
      outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
      outandlog('NEWLINE');


      FND_MSG_PUB.initialize;


       IF l_command = 'STAGE_ALL_DATA' THEN
            BEGIN
              SELECT count(*) into l_is_wildchar from HZ_DQM_STAGE_LOG where operation = 'SHADOW_STAGE_FOR_WILDCHAR_SRCH' and rownum = 1 ;
              IF l_is_wildchar < 1 THEN
                  INSERT INTO HZ_DQM_STAGE_LOG(operation, number_of_workers, worker_number, step,
                                    last_update_date, creation_date, created_by, last_updated_by)
                  VALUES ('SHADOW_STAGE_FOR_WILDCHAR_SRCH', '-1', '-1', 'Y', SYSDATE, SYSDATE, 0, 0);
              END IF;

              SELECT number_of_workers INTO l_last_num_workers
              FROM HZ_DQM_STAGE_LOG
              WHERE operation = l_command
              AND STEP = 'SHADOW_INIT';

              IF l_last_num_workers<>l_num_workers AND l_continue = 'Y' THEN
                log('Cannot continue with different number of workers. Using ' ||
                     l_last_num_workers ||' workers, as specified in first run');
                l_num_workers := l_last_num_workers;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_continue := 'N';
            END;
       END IF;

       if CREATE_INDEXES and l_continue <> 'Y' then
         -- drop context indexes, btree indexes on all tables and truncate them
         drop_context_indexes;
         drop_btree_indexes ;
       end if;

       if STAGE_ALL_DATA and l_continue <> 'Y' then
          truncate_staging_tables ;
          truncate_thin_tables ;
          -- Verify the validity of transformations and custom procedures,
          verify_all_procs;
          DELETE from HZ_DQM_STAGE_LOG where operation = l_command and
                      step like 'SHADOW%';



          create_log(
                p_operation=>l_command,
                p_step=>'SHADOW_INIT',
                p_num_workers=>l_num_workers);

          l_num_stage_steps := g_num_stage_steps;

          FOR I in 1..l_num_stage_steps LOOP
            FOR J in 0..(l_num_workers-1) LOOP
              create_log(
                p_operation=>l_command,
                p_step=>'SHADOW_STEP'||I,
                p_worker_number=> J,
                p_num_workers=>l_num_workers);
            END LOOP;
          END LOOP;
          DELETE from HZ_DQM_STAGE_LOG where operation = 'SHADOW_POPULATE_THIN';
          create_log(
              p_operation=>'SHADOW_POPULATE_THIN',
              p_step=>'HZ_PARTIES');
          create_log(
              p_operation=>'SHADOW_POPULATE_THIN',
              p_step=>'HZ_PARTY_SITES');
          create_log(
              p_operation=>'SHADOW_POPULATE_THIN',
              p_step=>'HZ_ORG_CONTACTS');
          create_log(
              p_operation=>'SHADOW_POPULATE_THIN',
              p_step=>'HZ_CONTACT_POINTS');

          DELETE from HZ_DQM_STAGE_LOG where operation = 'SHADOW_CREATE_INDEXES';
          create_log(
              p_operation=>'SHADOW_CREATE_INDEXES',
              p_step=>'HZ_PARTIES');
          create_log(
              p_operation=>'SHADOW_CREATE_INDEXES',
              p_step=>'HZ_PARTY_SITES');
          create_log(
              p_operation=>'SHADOW_CREATE_INDEXES',
              p_step=>'HZ_ORG_CONTACTS');
          create_log(
              p_operation=>'SHADOW_CREATE_INDEXES',
              p_step=>'HZ_CONTACT_POINTS');



          -- Update Transformation metadata, to signify that none of the transformations
          -- are usable right now
          /* Not needed for R12 SHADOW Staging
    	  UPDATE HZ_TRANS_FUNCTIONS_B SET STAGED_FLAG='N';
    	  */
       end if;

       if GENERATE_MAP_PROC then
          -- Create preferences for section groups
          create_section_group_prefs ;
          -- Create preferences for user data store
          create_uds_prefs ;
          -- Generate the procedures in HZ_STAGE_MAP_TRANSFORM_SHADOW, which will be eventually used by the
          -- Data Workers, to stage Data.
          generate_map_pkg;
       end if;


       if STAGE_ALL_DATA or STAGE_NEW_TRANSFORMATIONS then
            --------------------------------------------------------------
            --------------------------------------------------------------
            --  DATA STAGING PART
            --------------------------------------------------------------
            --------------------------------------------------------------


            -- Step :  Fire off the Data Workers with the assumption that we will never fire off more than 10
            FOR I in 1..10 LOOP
              l_sub_requests(i) := 1;
            END LOOP;


            log('Spawning ' || l_num_workers || ' Data Workers for staging');
            FOR I in 1..l_num_workers LOOP
              l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDQMSSTW',
                            'Stage Party Shadow Data Worker ' || to_char(i),
                            to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                            TRUE, to_char(l_num_workers), TO_CHAR(I), l_command,l_continue);
              IF l_sub_requests(i) = 0 THEN
                log('Error submitting worker ' || i);
                log(fnd_message.get);
              ELSE
                log('Submitted request for Worker ' || TO_CHAR(I) );
                log('Request ID : ' || l_sub_requests(i));
              END IF;
              EXIT when l_sub_requests(i) = 0;
            END LOOP;

            -- wait for completion of all workers
            fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'DQM_DATA_WORKERS') ;
            return;
       end if;
  end if;
  if (req_data = 'DQM_DATA_WORKERS') then
          -- AFTER ALL THE WORKERS ARE DONE, SEE IF THEY HAVE ALL COMPLETED NORMALLY


          -- assume that all concurrent dup workers completed normally, unless found otherwise
          l_workers_completed := TRUE;

          Select request_id BULK COLLECT into l_sub_requests
          from Fnd_Concurrent_Requests R
          Where Parent_Request_Id = FND_GLOBAL.conc_request_id
          and (phase_code<>'C' or status_code<>'C');

          IF  l_sub_requests.count>0 THEN
            l_workers_completed:=FALSE;
            FOR I in 1..l_sub_requests.COUNT LOOP
              outandlog('Data worker with request id ' || l_sub_requests(I) );
              outandlog('did not complete normally');
              retcode := 2;
            END LOOP;
          END IF;

          if (l_workers_completed = false) then
            return;
          end if;

          log('Data workers completed');
          if (STAGE_ALL_DATA) then
              BEGIN
                SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
                FROM HZ_DQM_STAGE_LOG
                WHERE OPERATION = 'SHADOW_POPULATE_THIN'
                AND step = 'HZ_PARTIES';
              EXCEPTION
                WHEN no_data_found THEN
                  l_start_flag:=NULL;
                  l_end_flag:=NULL;
              END;
              IF nvl(l_end_flag,'N') = 'N'  THEN
                if nvl(l_start_flag, 'N') = 'Y' then
                    log('Truncating HZ_THIN_ST_PARTIES .. ', FALSE);
                    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.HZ_THIN_ST_PARTIES';
                    log('Done');
                end if;
                UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_PARTIES';
                COMMIT;
                insert_into_thin_tables('PARTIES');
                UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_PARTIES';
                COMMIT;
              END IF;
              BEGIN
                SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
                FROM HZ_DQM_STAGE_LOG
                WHERE OPERATION = 'SHADOW_POPULATE_THIN'
                AND step = 'HZ_PARTY_SITES';
              EXCEPTION
                WHEN no_data_found THEN
                  l_start_flag:=NULL;
                  l_end_flag:=NULL;
              END;
              IF nvl(l_end_flag,'N') = 'N'  THEN
                if nvl(l_start_flag, 'N') = 'Y' then
                    log('Truncating HZ_THIN_ST_PSITES .. ', FALSE);
                    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.HZ_THIN_ST_PSITES';
                    log('Done');
                end if;
                UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_PARTY_SITES';
                COMMIT;
                insert_into_thin_tables('PARTY_SITES');
                UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_PARTY_SITES';
                COMMIT;
              END IF;
              BEGIN
                SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
                FROM HZ_DQM_STAGE_LOG
                WHERE OPERATION = 'SHADOW_POPULATE_THIN'
                AND step = 'HZ_ORG_CONTACTS';
              EXCEPTION
                WHEN no_data_found THEN
                  l_start_flag:=NULL;
                  l_end_flag:=NULL;
              END;
              IF nvl(l_end_flag,'N') = 'N'  THEN
                if nvl(l_start_flag, 'N') = 'Y' then
                    log('Truncating HZ_THIN_ST_CONTACTS .. ', FALSE);
                    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.HZ_THIN_ST_CONTACTS';
                    log('Done');
                end if;
                UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_ORG_CONTACTS';
                COMMIT;
                insert_into_thin_tables('CONTACTS') ;
                UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_ORG_CONTACTS';
                COMMIT;
              END IF;
              BEGIN
                SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
                FROM HZ_DQM_STAGE_LOG
                WHERE OPERATION = 'SHADOW_POPULATE_THIN'
                AND step = 'HZ_CONTACT_POINTS';
              EXCEPTION
                WHEN no_data_found THEN
                  l_start_flag:=NULL;
                  l_end_flag:=NULL;
              END;
              IF nvl(l_end_flag,'N') = 'N'  THEN
                if nvl(l_start_flag, 'N') = 'Y' then
                    log('Truncating HZ_THIN_ST_CPTS .. ', FALSE);
                    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.HZ_THIN_ST_CPTS';
                    log('Done');
                end if;
                UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_CONTACT_POINTS';
                COMMIT;
                insert_into_thin_tables('CONTACT_POINTS') ;
                UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
                WHERE operation = 'SHADOW_POPULATE_THIN' AND step ='HZ_CONTACT_POINTS';
                COMMIT;
              END IF;
              log('inserted into thin tables');
          end if;
  end if;

  if (CREATE_INDEXES or GEN_MISSING_INVALID_INDEXES or STAGE_NEW_TRANSFORMATIONS) and
     (req_data IS NULL or req_data = 'DQM_DATA_WORKERS') then
        --------------------------------------------------------------
        --------------------------------------------------------------
        --  INDEX STAGING PART
        --------------------------------------------------------------
        --------------------------------------------------------------

        -- Create Initial Preferences -- Storage, Memory, Theme etc.,
        create_initial_prefs( p_tablespace, l_num_prll, l_idx_mem) ;
        outandlog('index mem : '||l_idx_mem||' num parallel :'||l_num_prll);

        if (l_idx_mem = '0') then
          l_idx_mem := '500M' ;
        end if;
        wait_for_child_flag := false;
        -- Step :  Fire off the PARTY Index worker, once we have the request id for the first Data Worker
        for I in 1..4 loop
            if (CREATE_INDEXES or (STAGE_NEW_TRANSFORMATIONS and
                ((I = 1 and l_rebuild_party_idx) or
                 (I = 2 and l_rebuild_psite_idx) or
                 (I = 3 and l_rebuild_contact_idx) or
                 (I = 4 and l_rebuild_cpt_idx)))) then
              create_index_flag := true;
            else
              create_index_flag := false;
            end if;
            if I = 1 then
              l_index := 'HZ_PARTIES';
              if create_index_flag = false and STAGE_NEW_TRANSFORMATIONS = false then
                BEGIN
                  SELECT 1 INTO T FROM HZ_THIN_ST_PARTIES
                  WHERE ROWNUM=1
                  AND CONTAINS (concat_col, 'dummy_string')>0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    UPDATE HZ_DQM_STAGE_LOG
                    SET START_FLAG ='Y', START_TIME=SYSDATE,END_FLAG = 'Y', END_TIME=SYSDATE
                    WHERE OPERATION = 'SHADOW_CREATE_INDEXES' AND step = 'HZ_PARTIES';
                    log('hz_thin_st_parties_t1 is valid. No recreation necessary.');
                  WHEN OTHERS THEN
                    BEGIN
                        EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_parties_t1 FORCE';
                        log('Dropped hz_thin_st_parties_t1');
                    EXCEPTION
                        WHEN OTHERS THEN
                         log('Exception while dropping hz_thin_st_parties_t1. Error is ' || SQLERRM );
                          NULL;
                    END;
                    create_index_flag := true;
                END;
              end if;
            elsif I = 2 then
              l_index := 'HZ_PARTY_SITES';
              if create_index_flag = false  and STAGE_NEW_TRANSFORMATIONS = false then
                BEGIN
                  SELECT 1 INTO T FROM HZ_THIN_ST_PSITES
                  WHERE ROWNUM=1
                  AND CONTAINS (concat_col, 'dummy_string')>0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    UPDATE HZ_DQM_STAGE_LOG
                    SET START_FLAG ='Y', START_TIME=SYSDATE,END_FLAG = 'Y', END_TIME=SYSDATE
                    WHERE OPERATION = 'SHADOW_CREATE_INDEXES' AND step = 'HZ_PARTY_SITES';
                    log('hz_thin_st_psites_t1 is valid. No recreation necessary.');
                WHEN OTHERS THEN
                    BEGIN
                        EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_psites_t1 FORCE';
                        log('Dropped hz_thin_st_psites_t1');
                    EXCEPTION
                        WHEN OTHERS THEN
                        log('Exception while dropping hz_thin_st_psites_t1. Error is ' || SQLERRM );
                        NULL;
                    END;
                    create_index_flag := true;
                  END;
              end if;
            elsif I = 3 then
              l_index := 'HZ_ORG_CONTACTS';
              if create_index_flag = false  and STAGE_NEW_TRANSFORMATIONS = false then
                BEGIN
                  SELECT 1 INTO T FROM HZ_THIN_ST_CONTACTS
                  WHERE ROWNUM=1
                  AND CONTAINS (concat_col, 'dummy_string')>0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    UPDATE HZ_DQM_STAGE_LOG
                    SET START_FLAG ='Y', START_TIME=SYSDATE,END_FLAG = 'Y', END_TIME=SYSDATE
                    WHERE OPERATION = 'SHADOW_CREATE_INDEXES' AND step = 'HZ_ORG_CONTACTS';
                    log('hz_thin_st_contacts_t1 is valid. No recreation necessary.');
                  WHEN OTHERS THEN
                    BEGIN
                        EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_contacts_t1 FORCE';
                        log('Dropped hz_thin_st_contacts_t1');
                    EXCEPTION
                       WHEN OTHERS THEN
                       log('Exception while dropping hz_thin_st_contacts_t1. Error is ' || SQLERRM );
                       NULL;
                    END;
                    create_index_flag := true;
                END;
              end if;
            elsif I = 4  and STAGE_NEW_TRANSFORMATIONS = false then
              l_index := 'HZ_CONTACT_POINTS';
              if create_index_flag = false then
                BEGIN
                  SELECT 1 INTO T FROM HZ_THIN_ST_CPTS
                  WHERE ROWNUM=1
                  AND CONTAINS (concat_col, 'dummy_string')>0;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    UPDATE HZ_DQM_STAGE_LOG
                    SET START_FLAG ='Y', START_TIME=SYSDATE,END_FLAG = 'Y', END_TIME=SYSDATE
                    WHERE OPERATION = 'SHADOW_CREATE_INDEXES' AND step = 'HZ_CONTACT_POINTS';
                    log('hz_thin_st_cpts_t1 is valid. No recreation necessary.');
                  WHEN OTHERS THEN
                    BEGIN
                       EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_cpts_t1 FORCE';
                       log('Dropped hz_thin_st_cpts_t1');
                    EXCEPTION
                       WHEN OTHERS THEN
                       log('Exception while dropping hz_thin_st_cpts_t1. Error is ' || SQLERRM );
                       NULL;
                    END;
                    create_index_flag := true;
                  END;
              end if;
            end if;
            if create_index_flag then
                l_req_id := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDQMSCR',
                         'DQM Create Index On Thin Tables', to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                         TRUE, l_command, l_idx_mem, l_num_prll, l_index);
                IF l_req_id = 0 THEN
                    log('Error submitting request');
                    log(fnd_message.get);
                ELSE
                    log('Submitted request ID for '||l_index||': ' || l_req_id );
                    log('Request ID : ' || l_req_id);
                END IF;
                wait_for_child_flag := true;
            end if;
        end loop;


        if (wait_for_child_flag) then
          -- wait for completion of all workers
          fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'DQM_INDEX_WORKERS') ;
          return;
          /* Not needed for R12 SHADOW Staging
        else
            if (STAGE_ALL_DATA or STAGE_NEW_TRANSFORMATIONS) then
              -- FINALLY UPDATE THE STAGED_FLAG IN HZ_TRANS_FUNCTIONS
              UPDATE HZ_TRANS_FUNCTIONS_B
              SET STAGED_FLAG='Y' WHERE nvl(ACTIVE_FLAG,'Y') = 'Y';
            end if;
            */
        end if;
  end if;

  if req_data = 'DQM_INDEX_WORKERS' then
      -- AFTER ALL THE WORKERS ARE DONE, SEE IF THEY HAVE ALL COMPLETED NORMALLY


      -- assume that all concurrent dup workers completed normally, unless found otherwise
      l_workers_completed := TRUE;

      Select request_id BULK COLLECT into l_sub_requests
      from Fnd_Concurrent_Requests R
      Where Parent_Request_Id = FND_GLOBAL.conc_request_id
      and (phase_code<>'C' or status_code<>'C');

      IF  l_sub_requests.count>0 THEN
        l_workers_completed:=FALSE;
        FOR I in 1..l_sub_requests.COUNT LOOP
          outandlog('Index worker with request id ' || l_sub_requests(I) );
          outandlog('did not complete normally');
          retcode := 2;
        END LOOP;
      END IF;

      if (l_workers_completed = false) then
        return;
      end if;

      log('Index workers completed');
      /* Not needed for R12 SHADOW Staging
      if (STAGE_ALL_DATA or STAGE_NEW_TRANSFORMATIONS) then
         -- FINALLY UPDATE THE STAGED_FLAG IN HZ_TRANS_FUNCTIONS
         UPDATE HZ_TRANS_FUNCTIONS_B
         SET STAGED_FLAG='Y' WHERE nvl(ACTIVE_FLAG,'Y') = 'Y';
      end if;
      */
  end if;

  -- REPURI. Bug 4884742. To insert a record into hz_dqm_stage_log table
  -- indicating that shadow staging conc prog has completed successfully.

  create_log ('SHADOW_STAGING','COMPLETE');

  outandlog('Concurrent Program Execution completed ');
  outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error: Aborting staging');
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog('Error: Aborting staging');
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
   FND_FILE.close;
  WHEN OTHERS THEN
    log(fnd_message.get);
    outandlog('Error: Aborting staging');
    outandlog(SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    FND_FILE.close;
END;


PROCEDURE Stage_worker(
        errbuf                  OUT NOCOPY   VARCHAR2,
        retcode                 OUT NOCOPY   VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_worker_number         IN      VARCHAR2,
        p_command         	IN      VARCHAR2,
        p_continue         	IN      VARCHAR2

) IS

CURSOR l_log_cur(p_command VARCHAR2, l_worker_number NUMBER, l_step VARCHAR2) is
   ( SELECT start_flag, end_flag
      FROM HZ_DQM_STAGE_LOG
      WHERE OPERATION = p_command
      AND WORKER_NUMBER = l_worker_number AND step = l_step);

l_party_id		NUMBER;
l_party_type		HZ_PARTIES.PARTY_TYPE%TYPE;

l_party_staged VARCHAR2(1);
l_temp_party_id		NUMBER;
l_worker_number		NUMBER;
l_num_workers		NUMBER;

l_index_owner VARCHAR2(255);
l_temp VARCHAR2(255);
l_bool BOOLEAN;
l_status VARCHAR2(255);

l_error  VARCHAR2(2000);

l_party_cur StageCurTyp;
l_party_site_cur StageCurTyp;
l_contact_cur StageCurTyp;
l_cpt_cur StageCurTyp;

l_start_flag VARCHAR2(30);
l_end_flag VARCHAR2(30);

l_number_of_workers NUMBER;
l_startdate DATE;

l_log_step VARCHAR2(30);

BEGIN

  retcode := 0;
  l_worker_number := TO_NUMBER(p_worker_number);
  l_num_workers := TO_NUMBER(p_num_workers);
  IF l_worker_number = l_num_workers THEN
    l_worker_number := 0;
  END IF;

  log('----------------------------------------------------------');
  log('Starting Concurrent Program ''Stage Party Data'', Worker:  ' ||
            p_worker_number);
  log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));


  log('This worker stages all parties whose party_id/10 produces a remainder equal to the worker number ');
  log('');
  log('Stage Parties begin');

  FND_MSG_PUB.initialize;
  HZ_TRANS_PKG.set_staging_context('Y');

    SELECT SYSDATE INTO l_startdate FROM DUAL;

    log('Staging Organization Party Records');

    OPEN l_log_cur(p_command, l_worker_number, 'SHADOW_STEP1');
    FETCH l_log_cur INTO l_start_flag, l_end_flag;
    IF (l_log_cur%NOTFOUND) THEN
       l_start_flag:=NULL;
       l_end_flag:=NULL;
    END IF;
    CLOSE l_log_cur;

    log('Start Flag is ' || l_start_flag );
    log('End Flag is ' || l_end_flag );
    log('Command is ' || p_command);


    IF nvl(l_end_flag,'N') = 'N' THEN
      IF nvl(l_start_flag ,'N') = 'N' THEN

        l_log_step := 'SHADOW_STEP1';
        UPDATE HZ_DQM_STAGE_LOG set start_flag='Y', start_time = SYSDATE
        WHERE OPERATION = p_command
        AND WORKER_NUMBER = l_worker_number AND step = l_log_step;
        COMMIT;
        log(' Regular Flow -- Fresh Run of Staging');
        HZ_TRANS_PKG.set_party_type('ORGANIZATION');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
         'ALL_PARTIES', 'ORGANIZATION',l_worker_number, l_num_workers, NULL,'N', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('N',l_party_cur);
      ELSE
        HZ_TRANS_PKG.set_party_type('ORGANIZATION');
        log(' Continue for Org cursor');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
         'ALL_PARTIES', 'ORGANIZATION',l_worker_number, l_num_workers, NULL,'Y', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('Y',l_party_cur);
      END IF;

      CLOSE l_party_cur;
      l_log_step := 'SHADOW_STEP1';
      UPDATE HZ_DQM_STAGE_LOG set end_flag='Y', end_time = SYSDATE
      WHERE OPERATION = p_command
      AND WORKER_NUMBER = l_worker_number AND step = l_log_step;

      COMMIT;
    END IF;

    log('Staging Person Party Records');
    OPEN l_log_cur(p_command, l_worker_number, 'SHADOW_STEP2');
    FETCH l_log_cur INTO l_start_flag, l_end_flag;
    IF (l_log_cur%NOTFOUND) THEN
       l_start_flag:=NULL;
       l_end_flag:=NULL;
    END IF;
    CLOSE l_log_cur;

    log('Start Flag is ' || l_start_flag );
    log('End Flag is ' || l_end_flag );
    log('Command is ' || p_command);

    IF nvl(l_end_flag,'N') = 'N' THEN
      IF nvl(l_start_flag,'N') = 'N' THEN
        l_log_step := 'SHADOW_STEP2';
        UPDATE HZ_DQM_STAGE_LOG set start_flag='Y', start_time = SYSDATE
        WHERE OPERATION = p_command
        AND WORKER_NUMBER = l_worker_number AND step = l_log_step;
        COMMIT;
        log(' Regular Flow -- Fresh Run of Staging');
        HZ_TRANS_PKG.set_party_type('PERSON');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
          'ALL_PARTIES', 'PERSON',l_worker_number, l_num_workers, NULL,'N', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('N',l_party_cur);
      ELSE
        log(' Continue for Per cursor');
        HZ_TRANS_PKG.set_party_type('PERSON');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
          'ALL_PARTIES', 'PERSON',l_worker_number, l_num_workers, NULL,'Y', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('Y',l_party_cur);
      END IF;

      CLOSE l_party_cur;
      l_log_step := 'SHADOW_STEP2';
      UPDATE HZ_DQM_STAGE_LOG set end_flag='Y', end_time = SYSDATE
      WHERE OPERATION = p_command
      AND WORKER_NUMBER = l_worker_number AND step = l_log_step;

      COMMIT;
    END IF;

    log('Staging Group Party Records');
    OPEN l_log_cur(p_command, l_worker_number, 'SHADOW_STEP3');
    FETCH l_log_cur INTO l_start_flag, l_end_flag;
    IF (l_log_cur%NOTFOUND) THEN
       l_start_flag:=NULL;
       l_end_flag:=NULL;
    END IF;
    CLOSE l_log_cur;

    log('Start Flag is ' || l_start_flag );
    log('End Flag is ' || l_end_flag );
    log('Command is ' || p_command);

    IF nvl(l_end_flag,'N') = 'N' THEN
      IF nvl(l_start_flag,'N') = 'N' THEN
        l_log_step := 'SHADOW_STEP3';
        UPDATE HZ_DQM_STAGE_LOG set start_flag='Y', start_time = SYSDATE
        WHERE OPERATION = p_command
        AND WORKER_NUMBER = l_worker_number AND step = l_log_step;
        COMMIT;
        log(' Regular Flow -- Fresh Run of Staging');
        HZ_TRANS_PKG.set_party_type('OTHER');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
          'ALL_PARTIES', 'OTHER',l_worker_number, l_num_workers, NULL,'N', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('N',l_party_cur);
      ELSE
        log(' Continue for Oth cursor');
        HZ_TRANS_PKG.set_party_type('OTHER');
        HZ_STAGE_MAP_TRANSFORM_SHADOW.open_party_cursor(
          'ALL_PARTIES', 'OTHER',l_worker_number, l_num_workers, NULL,'Y', l_party_cur);
        HZ_STAGE_MAP_TRANSFORM_SHADOW.insert_stage_parties('Y',l_party_cur);
      END IF;

      CLOSE l_party_cur;
      l_log_step := 'SHADOW_STEP3';
      UPDATE HZ_DQM_STAGE_LOG set end_flag='Y', end_time = SYSDATE
      WHERE OPERATION = p_command
      AND WORKER_NUMBER = l_worker_number AND step = l_log_step;

      COMMIT;

    END IF;

    /* Not needed for R12 Shadow Staging
    log('Deleting records from HZ_DQM_SYNC_INTERFACE, that have a earlier creation date');
    DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE mod(PARTY_ID,l_num_workers) = l_worker_number
    AND creation_date<=l_startdate;
    */

  log('Concurrent Program Execution completed ');
  log('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error: Aborting staging ' || FND_MESSAGE.GET);
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog('Error: Aborting staging ' || FND_MESSAGE.GET);
    retcode := 2;
    errbuf := errbuf || logerror;
   FND_FILE.close;
  WHEN OTHERS THEN
    outandlog('Error: Aborting staging '|| SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
END;

FUNCTION new_primary_trans(p_entity VARCHAR2
)    RETURN BOOLEAN IS
  cursor is_new_tran (p_entity VARCHAR2) is
        select 'Y'
        from hz_trans_functions_vl t, hz_trans_attributes_b a
        where  a.attribute_id = t.attribute_id
        and ENTITY_NAME = p_entity
        and  nvl(staged_flag, 'N') = 'N'
        and primary_flag = 'Y'
        and nvl(active_flag, 'Y') = 'Y'
        and rownum = 1;
  l_var VARCHAR2(1);
BEGIN
     l_var := 'N';
     OPEN is_new_tran(p_entity);
     FETCH is_new_tran INTO l_var;
     CLOSE is_new_tran;
     IF (l_var = 'Y') THEN
         return true;
     ELSE
         return false;
     END IF;
EXCEPTION WHEN OTHERS THEN
     CLOSE is_new_tran;
     return true;
END new_primary_trans;

PROCEDURE Stage_create_index (
    errbuf                  OUT NOCOPY    VARCHAR2,
    retcode                 OUT NOCOPY   VARCHAR2,
	p_command		IN	VARCHAR2,
	p_idx_mem		IN	VARCHAR2,
	p_num_prll		IN	VARCHAR2,
	p_index			IN	VARCHAR2
) IS

  CURSOR c_num_attrs (p_entity VARCHAR2) IS
    SELECT count(1) FROM
      (SELECT distinct f.staged_attribute_column
      FROM HZ_TRANS_FUNCTIONS_VL f, HZ_TRANS_ATTRIBUTES_VL a
      WHERE
      -- PRIMARY_FLAG = 'Y' --5044716
      nvl(f.ACTIVE_FLAG,'Y') = 'Y'
      and f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
      AND a.entity_name = p_entity
      );

  l_num_sections NUMBER;

  uphase VARCHAR2(255);
  dphase VARCHAR2(255);
  ustatus VARCHAR2(255);
  dstatus VARCHAR2(255);
  l_index_owner VARCHAR2(255);
  message VARCHAR2(32000);

  l_bool BOOLEAN;

  l_num_parts NUMBER;
  l_num_jobs NUMBER;
  l_num_prll NUMBER;

  l_start_flag VARCHAR2(30);
  l_end_flag VARCHAR2(30);
  l_command VARCHAR2(255);

  l_section_grp VARCHAR2(255);
  l_min_id number;
  l_max_id number;
  tmp number;


  CREATE_PARTY_INDEXES BOOLEAN := FALSE ;
  CREATE_PS_INDEXES BOOLEAN := FALSE ;
  CREATE_CONTACT_INDEXES BOOLEAN := FALSE ;
  CREATE_CPT_INDEXES BOOLEAN := FALSE ;


BEGIN

  retcode := 0;
  l_command := p_command;

  log ('--------------------------------------');
  outandlog('Starting Concurrent Program ''Create DQM indexes''');
  outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  outandlog('Waiting for workers to complete');


  log('Data Workers have completed successfully');

  l_bool := fnd_installation.GET_APP_INFO('AR',ustatus,dstatus,l_index_owner);

  log('About to create index');
  log('Index owner is ' || l_index_owner);
  log('Schema Name is ' || g_schema_name );
  log('p_idx_mem is '|| p_idx_mem);
  -- Determine what needs to be done

  IF p_index = 'ALL'
  THEN
        CREATE_PARTY_INDEXES := TRUE ;
        CREATE_PS_INDEXES := TRUE ;
        CREATE_CONTACT_INDEXES := TRUE ;
        CREATE_CPT_INDEXES := TRUE ;
  ELSIF p_index = 'HZ_PARTIES'
  THEN
        CREATE_PARTY_INDEXES := TRUE ;
        log('Creating Party Indexes');
  ELSIF p_index = 'HZ_PARTY_SITES'
  THEN
        CREATE_PS_INDEXES := TRUE ;
        log('Creating party sites Indexes');
  ELSIF p_index = 'HZ_ORG_CONTACTS'
  THEN
        CREATE_CONTACT_INDEXES := TRUE ;
        log('Creating Contact Indexes');
  ELSIF p_index = 'HZ_CONTACT_POINTS'
  THEN
        CREATE_CPT_INDEXES := TRUE ;
        log('Creating Contact Point Indexes');
  END IF ;

 -- PARTY INDEX CREATION
 IF CREATE_PARTY_INDEXES THEN
    create_btree_indexes ('PARTY');

    BEGIN
      SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
      FROM HZ_DQM_STAGE_LOG
      WHERE OPERATION = 'SHADOW_CREATE_INDEXES'
      AND step = 'HZ_PARTIES';
    EXCEPTION
      WHEN no_data_found THEN
        l_start_flag:=NULL;
        l_end_flag:=NULL;
    END;
    log(' start flag = '||l_start_flag||' end flag = '||l_end_flag);
    -- Continue From Previous Run of Staging
    IF nvl(l_end_flag,'N') = 'N' THEN
      BEGIN
        execute immediate 'begin ctx_output.start_log(''party_index''); end;';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
    END;

    IF nvl(l_start_flag,'N') = 'Y' THEN
        BEGIN
          log('Attempting restart build of index '||l_index_owner || '.hz_thin_st_parties_t1');
          EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
              '.hz_thin_st_parties_t1 rebuild parameters(''resume memory ' || p_idx_mem || ''')';
          log('Index Successfully built');

          UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
          WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTIES';
          COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            log('Restart Unsuccesful .. Recreating');
            BEGIN
              EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_parties_t1 FORCE';
              log('Dropped hz_thin_st_parties_t1');
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            l_start_flag := 'N';
            l_command := 'STAGE_ALL_DATA';

        END;
    END IF;

      -- Regular Flow, We do not Continue from a previous Run of Staging
      IF nvl(l_start_flag,'N') = 'N' THEN
        log('regular creation of party indexes');
        UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', START_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTIES';
        COMMIT;

        l_section_grp := g_schema_name || '.HZ_DQM_PARTY_GRP';

          log(' Creating hz_thin_st_parties_t1 on hz_thin_st_parties .');
          log(' Index Memory ' || p_idx_mem);
          log(' Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );

          --  commenting the sync part || ' sync (every "sysdate+(1/24)")'
             EXECUTE IMMEDIATE 'CREATE INDEX ' || l_index_owner || '.hz_thin_st_parties_t1 ON ' ||
              'hz_thin_st_parties(concat_col) indextype is ctxsys.context ' ||
              'parameters (''storage  '||g_schema_name || '.HZ_DQM_STORAGE datastore '||g_schema_name || '.hz_party_uds ' ||
              'SECTION GROUP '||l_section_grp||' STOPLIST CTXSYS.EMPTY_STOPLIST LEXER '||g_schema_name || '.dqm_lexer memory ' ||
              p_idx_mem /* || ' sync (every "sysdate+(5/1440)")' */ || ''')';

        UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTIES';
        COMMIT;
      END IF;

      log(' Completed at ' || to_char(SYSDATE, 'HH24:MI:SS'));

    END IF;
  END IF;


  ----  PARTY SITE INDEX CREATION
  IF CREATE_PS_INDEXES THEN
    create_btree_indexes ('PARTY_SITES');
    BEGIN
      SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
      FROM HZ_DQM_STAGE_LOG
      WHERE OPERATION = 'SHADOW_CREATE_INDEXES'
      AND step = 'HZ_PARTY_SITES';
    EXCEPTION
      WHEN no_data_found THEN
        l_start_flag:=NULL;
        l_end_flag:=NULL;
    END;

     -- Continue From Previous Run of Staging
    IF nvl(l_end_flag,'N') = 'N' THEN
      BEGIN
        execute immediate 'begin ctx_output.start_log(''party_site_index''); end;';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF nvl(l_start_flag,'N') = 'Y' THEN
        BEGIN
          log('Attempting restart build of index '||l_index_owner || '.hz_thin_st_psites_t1');
          EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
              '.hz_thin_st_psites_t1 rebuild parameters(''resume memory ' || p_idx_mem /*|| 'sync (every "sysdate+(1/24)")'*/ || ''')';
          log('Index Successfully built');

          UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
          WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTY_SITES';
          COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            log('Restart Unsuccesful .. Recreating');
            BEGIN
              EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_psites_t1 FORCE';
              log('Dropped hz_thin_st_psites_t1');
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            l_start_flag := 'N';
            l_command := 'STAGE_ALL_DATA';

        END;
      END IF;




      IF nvl(l_start_flag,'N') = 'N' THEN
        UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', START_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTY_SITES';
        COMMIT;

        l_section_grp := g_schema_name || '.HZ_DQM_PS_GRP';

          log(' Creating hz_thin_st_psites_t1 on hz_thin_st_psites. ');
          log(' Index Memory ' || p_idx_mem);
          log(' Starting at ' || to_char(SYSDATE, 'HH24:MI:SS'));

          -- commenting the sync part  || ' sync (every "sysdate+(1/24)")'
          EXECUTE IMMEDIATE 'CREATE INDEX ' || l_index_owner || '.hz_thin_st_psites_t1 ON ' ||
               'hz_thin_st_psites(concat_col) indextype is ctxsys.context ' ||
              'parameters (''storage '||g_schema_name || '.HZ_DQM_STORAGE datastore '||g_schema_name || '.hz_party_site_uds ' ||
              'SECTION GROUP '||l_section_grp||' STOPLIST CTXSYS.EMPTY_STOPLIST LEXER '||g_schema_name || '.dqm_lexer memory ' ||
              p_idx_mem /* || ' sync (every "sysdate+(5/1440)")' */ || ''')';

        UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_PARTY_SITES';
        COMMIT;
      END IF;
      log(' Completed at ' || to_char(SYSDATE, 'HH24:MI:SS'));
    END IF;
  END IF;
  log('');


  -- CONTACT INDEX CREATION
  IF CREATE_CONTACT_INDEXES  THEN
    create_btree_indexes ('CONTACTS');
    BEGIN
      SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
      FROM HZ_DQM_STAGE_LOG
      WHERE OPERATION = 'SHADOW_CREATE_INDEXES'
      AND step = 'HZ_ORG_CONTACTS';
    EXCEPTION
      WHEN no_data_found THEN
        l_start_flag:=NULL;
        l_end_flag:=NULL;
    END;

    -- Continue From Previous Run of Staging
    IF nvl(l_end_flag,'N') = 'N' THEN
      BEGIN
        execute immediate 'begin ctx_output.start_log(''contact_index''); end;';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF nvl(l_start_flag,'N') = 'Y' THEN
        BEGIN
          log('Attempting restart build of index '||l_index_owner || '.hz_thin_st_contacts_t1');
          EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
              '.hz_thin_st_contacts_t1 rebuild parameters(''resume memory ' || p_idx_mem  || ''')';
          log('Index Successfully built');

          UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
          WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_ORG_CONTACTS';
          COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            log('Restart unsuccessful. Recreating Index');
            BEGIN
              EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_contacts_t1 FORCE';
              log('Dropped hz_thin_st_contacts_t1 ');
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            l_start_flag := 'N';
            l_command := 'STAGE_ALL_DATA';

        END;
      END IF;

      IF nvl(l_start_flag,'N') = 'N' THEN
        UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', START_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_ORG_CONTACTS';
        COMMIT;

        l_section_grp := g_schema_name || '.HZ_DQM_CONTACT_GRP';


          log(' Creating hz_thin_st_contacts_t1 on hz_thin_st_contacts. ');
          log(' Index Memory ' || p_idx_mem);
          log(' Starting at ' || to_char(SYSDATE, 'HH24:MI:SS'));

          -- commenting the sync part || 'sync (every "sysdate+(1/24)")'
          EXECUTE IMMEDIATE 'CREATE INDEX ' || l_index_owner || '.hz_thin_st_contacts_t1 ON ' ||
              'hz_thin_st_contacts(concat_col) indextype is ctxsys.context ' ||
              'parameters (''storage '||g_schema_name || '.HZ_DQM_STORAGE datastore '||g_schema_name || '.hz_contact_uds ' ||
              'SECTION GROUP '||l_section_grp||' STOPLIST CTXSYS.EMPTY_STOPLIST LEXER '||g_schema_name || '.dqm_lexer memory '
              || p_idx_mem /* || ' sync (every "sysdate+(5/1440)")' */ || ''')';
        UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_ORG_CONTACTS';
        COMMIT;
      END IF;
      log(' Completed at ' || to_char(SYSDATE, 'HH24:MI:SS'));
    END IF;
  END IF;
  log('');

  -- CONTACT POINT INDEX CREATION
  IF CREATE_CPT_INDEXES THEN
    create_btree_indexes ('CONTACT_POINTS');
    BEGIN
      SELECT start_flag, end_flag INTO l_start_flag, l_end_flag
      FROM HZ_DQM_STAGE_LOG
      WHERE OPERATION = 'SHADOW_CREATE_INDEXES'
      AND step = 'HZ_CONTACT_POINTS';
    EXCEPTION
      WHEN no_data_found THEN
        l_start_flag:=NULL;
        l_end_flag:=NULL;
    END;

    -- Continue From Previous Run of Staging
    IF nvl(l_end_flag,'N') = 'N' THEN
      BEGIN
        execute immediate 'begin ctx_output.start_log(''contact_point_index''); end;';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF nvl(l_start_flag,'N') = 'Y' THEN
        BEGIN
          log('Attempting restart build of index '||l_index_owner || '.hz_thin_st_cpts_t1');
          EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||
              '.hz_thin_st_cpts_t1 rebuild parameters(''resume memory ' || p_idx_mem /* || 'sync (every "sysdate+(1/24)")' */ || ''')';

          log('Index Successfully built');
          UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
          WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_CONTACT_POINTS';
          COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            log('Restart unsuccessful. Rebuilding index.');
            BEGIN
              EXECUTE IMMEDIATE 'DROP INDEX ' || l_index_owner || '.hz_thin_st_cpts_t1 FORCE';
              log('Dropped hz_thin_st_cpts_t1');
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            l_start_flag := 'N';
            l_command := 'STAGE_ALL_DATA';

        END;
      END IF;

      IF nvl(l_start_flag,'N') = 'N' THEN
        UPDATE HZ_DQM_STAGE_LOG set START_FLAG = 'Y', START_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_CONTACT_POINTS';
        COMMIT;

        l_section_grp := g_schema_name || '.HZ_DQM_CPT_GRP';


          log(' Creating hz_thin_st_cpts_t1 on hz_thin_st_cpts . ');
          log(' Index Memory ' || p_idx_mem);
          log(' Starting at ' || to_char(SYSDATE, 'HH24:MI:SS'));
          -- commenting the sync part || ' sync (every "sysdate+(1/24)")'
          EXECUTE IMMEDIATE 'CREATE INDEX ' || l_index_owner || '.hz_thin_st_cpts_t1 ON ' ||
               'hz_thin_st_cpts(concat_col) indextype is ctxsys.context ' ||
              'parameters (''storage '||g_schema_name || '.HZ_DQM_STORAGE datastore '||g_schema_name || '.hz_contact_point_uds ' ||
              'SECTION GROUP '||l_section_grp||' STOPLIST CTXSYS.EMPTY_STOPLIST LEXER '||g_schema_name || '.dqm_lexer memory '
              || p_idx_mem /* || ' sync (every "sysdate+(5/1440)")' */ || ''')';

        UPDATE HZ_DQM_STAGE_LOG set END_FLAG = 'Y', END_TIME=SYSDATE
        WHERE operation = 'SHADOW_CREATE_INDEXES' AND step ='HZ_CONTACT_POINTS';
        COMMIT;
      END IF;
      log(' Completed at ' || to_char(SYSDATE, 'HH24:MI:SS'));
    END IF;
  END IF;

  log('');
  log('Concurrent Program Execution completed ');
  log('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
  WHEN OTHERS THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 2;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    FND_FILE.close;
END;

PROCEDURE generate_map_proc (
   p_entity 		IN	VARCHAR2,
   p_proc_name 		IN	VARCHAR2,
   p_command 		IN	VARCHAR2
) IS
  l_update_str VARCHAR2(4000);
  FIRST BOOLEAN;
BEGIN


  l('FUNCTION ' || p_proc_name || '( ');
  l('      p_record_id NUMBER,');
  IF p_entity = 'PARTY' THEN
    l('      p_search_rec HZ_PARTY_SEARCH.party_search_rec_type');
    l('  ) RETURN HZ_PARTY_STAGE.party_stage_rec_type IS ');
    l('l_stage_rec HZ_PARTY_STAGE.party_stage_rec_type;');
    l('BEGIN');
    l('  l_stage_rec.party_id := p_record_id;');
    l('  l_stage_rec.status := p_search_rec.STATUS;');
  ELSIF p_entity = 'PARTY_SITES' THEN
    l('      p_party_id NUMBER,');
    l('      p_search_rec HZ_PARTY_SEARCH.party_site_search_rec_type');
    l('  ) RETURN HZ_PARTY_STAGE.party_site_stage_rec_type IS ');
    l('l_stage_rec HZ_PARTY_STAGE.party_site_stage_rec_type;');
    l('BEGIN');
    l('  l_stage_rec.party_id := p_party_id;');
    l('  l_stage_rec.party_site_id := p_record_id;');
  ELSIF p_entity = 'CONTACTS' THEN
    l('      p_party_id NUMBER,');
    l('      p_search_rec HZ_PARTY_SEARCH.contact_search_rec_type');
    l('  ) RETURN HZ_PARTY_STAGE.contact_stage_rec_type IS ');
    l('l_stage_rec HZ_PARTY_STAGE.contact_stage_rec_type;');
    l('BEGIN');
    l('  l_stage_rec.party_id := p_party_id;');
    l('  l_stage_rec.org_contact_id := p_record_id;');
  ELSIF p_entity = 'CONTACT_POINTS' THEN
    l('      p_party_id NUMBER,');
    l('      p_search_rec HZ_PARTY_SEARCH.contact_point_search_rec_type');
    l('  ) RETURN HZ_PARTY_STAGE.contact_pt_stage_rec_type IS ');
    l('l_stage_rec HZ_PARTY_STAGE.contact_pt_stage_rec_type;');
    l('BEGIN');
    l('  l_stage_rec.party_id := p_party_id;');
    l('  l_stage_rec.contact_point_id := p_record_id;');
    l('  l_stage_rec.contact_point_type := p_search_rec.CONTACT_POINT_TYPE;');
  END IF;

  IF p_command = 'STAGE_NEW_TRANSFORMATIONS' THEN
    FIRST := TRUE;
    l_update_str := null;

    for ATTRS IN (SELECT ATTRIBUTE_ID, ATTRIBUTE_NAME
                  FROM HZ_TRANS_ATTRIBUTES_VL
                  WHERE ENTITY_NAME = p_entity)

    LOOP
       for FUNCS IN (SELECT PROCEDURE_NAME, STAGED_ATTRIBUTE_COLUMN
                     FROM HZ_TRANS_FUNCTIONS_VL
                     WHERE ATTRIBUTE_ID = ATTRS.ATTRIBUTE_ID
                     AND nvl(ACTIVE_FLAG,'Y') = 'Y'
                     AND NVL(STAGED_FLAG,'N') <> 'Y')
       LOOP
          l('  l_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
          l('        ' || FUNCS.PROCEDURE_NAME ||'(');
          l('             p_search_rec.'||ATTRS.ATTRIBUTE_NAME);
          l('             ,null,''' || ATTRS.ATTRIBUTE_NAME || '''');
          l('             ,''' ||p_entity||''');');
          IF FIRST THEN
            l_update_str := ' '|| FUNCS.STAGED_ATTRIBUTE_COLUMN || ' = ' ||
                            ' l_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' ';
            FIRST := FALSE;
          ELSE
            l_update_str := l_update_str || ','|| FUNCS.STAGED_ATTRIBUTE_COLUMN || ' = ' ||
                            ' l_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' ';
          END IF;
       END LOOP;
    END LOOP;

    IF l_update_str IS NOT NULL THEN
      IF p_entity = 'PARTY' THEN
        l('  UPDATE HZ_SHADOW_ST_PARTIES SET ');
        l('  ' || l_update_str);
        l('  WHERE party_id = p_record_id;');
      ELSIF p_entity = 'PARTY_SITES' THEN
        l('  UPDATE HZ_SHADOW_ST_PSITES SET ');
        l('  ' || l_update_str);
        l('  WHERE party_site_id = p_record_id;');
      ELSIF p_entity = 'CONTACTS' THEN
        l('  UPDATE HZ_SHADOW_ST_CONTACTS SET ');
        l('  ' || l_update_str);
        l('  WHERE org_contact_id = p_record_id;');
      ELSIF p_entity = 'CONTACT_POINTS' THEN
        l('  UPDATE HZ_SHADOW_ST_CPTS SET ');
        l('  ' || l_update_str);
        l('  WHERE contact_point_id = p_record_id;');
      END IF;
    END IF;

  ELSE

    for ATTRS IN (SELECT ATTRIBUTE_ID, ATTRIBUTE_NAME
                  FROM HZ_TRANS_ATTRIBUTES_VL
                  WHERE ENTITY_NAME = p_entity)
    LOOP
       for FUNCS IN (SELECT PROCEDURE_NAME, STAGED_ATTRIBUTE_COLUMN
                     FROM HZ_TRANS_FUNCTIONS_VL
                     WHERE ATTRIBUTE_ID = ATTRS.ATTRIBUTE_ID
                     AND nvl(ACTIVE_FLAG,'Y') = 'Y')
       LOOP
          l('  l_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
          l('        ' || FUNCS.PROCEDURE_NAME ||'(');
          l('             p_search_rec.'||ATTRS.ATTRIBUTE_NAME);

          -- Temporary fix for bug 2265498
          -- Will be fixed when bug 2269873
          l('             ,null,''' || ATTRS.ATTRIBUTE_NAME || '''');
          l('             ,''' ||p_entity||''');');
       END LOOP;
    END LOOP;
  END IF;

  l('  RETURN l_stage_rec;');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_MAP_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' ,''' || p_proc_name||''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');

  l('END;');

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'generate_transform_proc');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END;

PROCEDURE generate_declarations IS

BEGIN
  l('  TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;');
  l('  TYPE Char1List IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;');
  l('  TYPE Char2List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;');
  l('  TYPE CharList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;');
  l('  ');
  l('  H_PERSON_PARTY_ID NumberList;');
  l('  H_P_PARTY_ID NumberList;');
  l('  H_PS_DEN CharList;');
  l('  H_CT_DEN CharList;');
  l('  H_CPT_DEN CharList;');
  l('  H_PARTY_INDEX NumberList;');
  l('  H_PARTY_ID NumberList;');
  l('  H_C_PARTY_ID NumberList;');
  l('  H_PS_PARTY_ID NumberList;');
  l('  H_CPT_PARTY_ID NumberList;');
  l('  H_R_PARTY_ID NumberList;');
  l('  H_STATUS Char1List;');
  l('  H_PARTY_SITE_ID NumberList;');
  l('  H_CPT_PARTY_SITE_ID NumberList;');
  l('  H_ORG_CONTACT_ID NumberList;');
  l('  H_PS_ORG_CONTACT_ID NumberList;');
  l('  H_CPT_ORG_CONTACT_ID NumberList;');
  l('  H_CONTACT_POINT_ID NumberList;');
  l('  H_CONTACT_POINT_TYPE Char2List;');
  l('  H_TX1 CharList;');
  l('  H_TX2 CharList;');
  l('  H_TX3 CharList;');
  l('  H_TX4 CharList;');
  l('  H_TX5 CharList;');
  l('  H_TX6 CharList;');
  l('  H_TX7 CharList;');
  l('  H_TX8 CharList;');
  l('  H_TX9 CharList;');
  l('  H_TX10 CharList;');
  l('  H_TX11 CharList;');
  l('  H_TX12 CharList;');
  l('  H_TX13 CharList;');
  l('  H_TX14 CharList;');
  l('  H_TX15 CharList;');
  l('  H_TX16 CharList;');
  l('  H_TX17 CharList;');
  l('  H_TX18 CharList;');
  l('  H_TX19 CharList;');
  l('  H_TX20 CharList;');
  l('  H_TX21 CharList;');
  l('  H_TX22 CharList;');
  l('  H_TX23 CharList;');
  l('  H_TX24 CharList;');
  l('  H_TX25 CharList;');
  l('  H_TX26 CharList;');
  l('  H_TX27 CharList;');
  l('  H_TX28 CharList;');
  l('  H_TX29 CharList;');
  l('  H_TX30 CharList;');
  l('  H_TX31 CharList;');
  l('  H_TX32 CharList;');
  l('  H_TX33 CharList;');
  l('  H_TX34 CharList;');
  l('  H_TX35 CharList;');
  l('  H_TX36 CharList;');
  l('  H_TX37 CharList;');
  l('  H_TX38 CharList;');
  l('  H_TX39 CharList;');
  l('  H_TX40 CharList;');
  l('  H_TX41 CharList;');
  l('  H_TX42 CharList;');
  l('  H_TX43 CharList;');
  l('  H_TX44 CharList;');
  l('  H_TX45 CharList;');
  l('  H_TX46 CharList;');
  l('  H_TX47 CharList;');
  l('  H_TX48 CharList;');
  l('  H_TX49 CharList;');
  l('  H_TX50 CharList;');
  l('  H_TX51 CharList;');
  l('  H_TX52 CharList;');
  l('  H_TX53 CharList;');
  l('  H_TX54 CharList;');
  l('  H_TX55 CharList;');
  l('  H_TX56 CharList;');
  l('  H_TX57 CharList;');
  l('  H_TX58 CharList;');
  l('  H_TX59 CharList;');
  l('  H_TX60 CharList;');
  l('  H_TX61 CharList;');
  l('  H_TX62 CharList;');
  l('  H_TX63 CharList;');
  l('  H_TX64 CharList;');
  l('  H_TX65 CharList;');
  l('  H_TX66 CharList;');
  l('  H_TX67 CharList;');
  l('  H_TX68 CharList;');
  l('  H_TX69 CharList;');
  l('  H_TX70 CharList;');
  l('  H_TX71 CharList;');
  l('  H_TX72 CharList;');
  l('  H_TX73 CharList;');
  l('  H_TX74 CharList;');
  l('  H_TX75 CharList;');
  l('  H_TX76 CharList;');
  l('  H_TX77 CharList;');
  l('  H_TX78 CharList;');
  l('  H_TX79 CharList;');
  l('  H_TX80 CharList;');
  l('  H_TX81 CharList;');
  l('  H_TX82 CharList;');
  l('  H_TX83 CharList;');
  l('  H_TX84 CharList;');
  l('  H_TX85 CharList;');
  l('  H_TX86 CharList;');
  l('  H_TX87 CharList;');
  l('  H_TX88 CharList;');
  l('  H_TX89 CharList;');
  l('  H_TX90 CharList;');
  l('  H_TX91 CharList;');
  l('  H_TX92 CharList;');
  l('  H_TX93 CharList;');
  l('  H_TX94 CharList;');
  l('  H_TX95 CharList;');
  l('  H_TX96 CharList;');
  l('  H_TX97 CharList;');
  l('  H_TX98 CharList;');
  l('  H_TX99 CharList;');
  l('  H_TX100 CharList;');
  l('  H_TX101 CharList;');
  l('  H_TX102 CharList;');
  l('  H_TX103 CharList;');
  l('  H_TX104 CharList;');
  l('  H_TX105 CharList;');
  l('  H_TX106 CharList;');
  l('  H_TX107 CharList;');
  l('  H_TX108 CharList;');
  l('  H_TX109 CharList;');
  l('  H_TX110 CharList;');
  l('  H_TX111 CharList;');
  l('  H_TX112 CharList;');
  l('  H_TX113 CharList;');
  l('  H_TX114 CharList;');
  l('  H_TX115 CharList;');
  l('  H_TX116 CharList;');
  l('  H_TX117 CharList;');
  l('  H_TX118 CharList;');
  l('  H_TX119 CharList;');
  l('  H_TX120 CharList;');
  l('  H_TX121 CharList;');
  l('  H_TX122 CharList;');
  l('  H_TX123 CharList;');
  l('  H_TX124 CharList;');
  l('  H_TX125 CharList;');
  l('  H_TX126 CharList;');
  l('  H_TX127 CharList;');
  l('  H_TX128 CharList;');
  l('  H_TX129 CharList;');
  l('  H_TX130 CharList;');
  l('  H_TX131 CharList;');
  l('  H_TX132 CharList;');
  l('  H_TX133 CharList;');
  l('  H_TX134 CharList;');
  l('  H_TX135 CharList;');
  l('  H_TX136 CharList;');
  l('  H_TX137 CharList;');
  l('  H_TX138 CharList;');
  l('  H_TX139 CharList;');
  l('  H_TX140 CharList;');
  l('  H_TX141 CharList;');
  l('  H_TX142 CharList;');
  l('  H_TX143 CharList;');
  l('  H_TX144 CharList;');
  l('  H_TX145 CharList;');
  l('  H_TX146 CharList;');
  l('  H_TX147 CharList;');
  l('  H_TX148 CharList;');
  l('  H_TX149 CharList;');
  l('  H_TX150 CharList;');
  l('  H_TX151 CharList;');
  l('  H_TX152 CharList;');
  l('  H_TX153 CharList;');
  l('  H_TX154 CharList;');
  l('  H_TX155 CharList;');
  l('  H_TX156 CharList;');
  l('  H_TX157 CharList;');
  l('  H_TX158 CharList;');
  l('  H_TX159 CharList;');
  l('  H_TX160 CharList;');
  l('  H_TX161 CharList;');
  l('  H_TX162 CharList;');
  l('  H_TX163 CharList;');
  l('  H_TX164 CharList;');
  l('  H_TX165 CharList;');
  l('  H_TX166 CharList;');
  l('  H_TX167 CharList;');
  l('  H_TX168 CharList;');
  l('  H_TX169 CharList;');
  l('  H_TX170 CharList;');
  l('  H_TX171 CharList;');
  l('  H_TX172 CharList;');
  l('  H_TX173 CharList;');
  l('  H_TX174 CharList;');
  l('  H_TX175 CharList;');
  l('  H_TX176 CharList;');
  l('  H_TX177 CharList;');
  l('  H_TX178 CharList;');
  l('  H_TX179 CharList;');
  l('  H_TX180 CharList;');
  l('  H_TX181 CharList;');
  l('  H_TX182 CharList;');
  l('  H_TX183 CharList;');
  l('  H_TX184 CharList;');
  l('  H_TX185 CharList;');
  l('  H_TX186 CharList;');
  l('  H_TX187 CharList;');
  l('  H_TX188 CharList;');
  l('  H_TX189 CharList;');
  l('  H_TX190 CharList;');
  l('  H_TX191 CharList;');
  l('  H_TX192 CharList;');
  l('  H_TX193 CharList;');
  l('  H_TX194 CharList;');
  l('  H_TX195 CharList;');
  l('  H_TX196 CharList;');
  l('  H_TX197 CharList;');
  l('  H_TX198 CharList;');
  l('  H_TX199 CharList;');
  l('  H_TX200 CharList;');
  l('  H_TX201 CharList;');
  l('  H_TX202 CharList;');
  l('  H_TX203 CharList;');
  l('  H_TX204 CharList;');
  l('  H_TX205 CharList;');
  l('  H_TX206 CharList;');
  l('  H_TX207 CharList;');
  l('  H_TX208 CharList;');
  l('  H_TX209 CharList;');
  l('  H_TX210 CharList;');
  l('  H_TX211 CharList;');
  l('  H_TX212 CharList;');
  l('  H_TX213 CharList;');
  l('  H_TX214 CharList;');
  l('  H_TX215 CharList;');
  l('  H_TX216 CharList;');
  l('  H_TX217 CharList;');
  l('  H_TX218 CharList;');
  l('  H_TX219 CharList;');
  l('  H_TX220 CharList;');
  l('  H_TX221 CharList;');
  l('  H_TX222 CharList;');
  l('  H_TX223 CharList;');
  l('  H_TX224 CharList;');
  l('  H_TX225 CharList;');
  l('  H_TX226 CharList;');
  l('  H_TX227 CharList;');
  l('  H_TX228 CharList;');
  l('  H_TX229 CharList;');
  l('  H_TX230 CharList;');
  l('  H_TX231 CharList;');
  l('  H_TX232 CharList;');
  l('  H_TX233 CharList;');
  l('  H_TX234 CharList;');
  l('  H_TX235 CharList;');
  l('  H_TX236 CharList;');
  l('  H_TX237 CharList;');
  l('  H_TX238 CharList;');
  l('  H_TX239 CharList;');
  l('  H_TX240 CharList;');
  l('  H_TX241 CharList;');
  l('  H_TX242 CharList;');
  l('  H_TX243 CharList;');
  l('  H_TX244 CharList;');
  l('  H_TX245 CharList;');
  l('  H_TX246 CharList;');
  l('  H_TX247 CharList;');
  l('  H_TX248 CharList;');
  l('  H_TX249 CharList;');
  l('  H_TX250 CharList;');
  l('  H_TX251 CharList;');
  l('  H_TX252 CharList;');
  l('  H_TX253 CharList;');
  l('  H_TX254 CharList;');
  l('  H_TX255 CharList;');
END;


PROCEDURE generate_party_query_proc IS
 cur_col_num NUMBER := 1;

 TYPE coltab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

 l_org_select coltab;
 l_per_select coltab;
 l_oth_select coltab;

 l_forall_list coltab;
 l_custom_list coltab;
 l_mincol_list coltab;
 l_min_colnum NUMBER;
 idx NUMBER :=1;
 is_first boolean := true;

 -- VJN Introduced for conditional word replacements
 l_cond_attrib_list coltab ;
 l_idx number ;
 l_attr_name     varchar2(2000); --Bug No: 4954701
 l_org_attr_name varchar2(2000); --Bug No: 4954701
 l_per_attr_name varchar2(2000); --Bug No: 4954701
BEGIN
  l('  PROCEDURE open_party_cursor( ');
  l('    p_select_type	IN	VARCHAR2,');
  l('    p_party_type	IN	VARCHAR2,');
  l('    p_worker_number IN	NUMBER,');
  l('    p_num_workers	IN	NUMBER,');
  l('    p_party_id	IN	NUMBER,');
  l('    p_continue	IN	VARCHAR2,');
  l('    x_party_cur	IN OUT	HZ_PARTY_STAGE.StageCurTyp) IS ');
  l('');
  l('    l_party_type VARCHAR2(255);');
  l('  BEGIN');

  FOR ATTRS IN (SELECT a.ATTRIBUTE_ID,
                       a.ATTRIBUTE_NAME,
                       a.SOURCE_TABLE,
                       a.CUSTOM_ATTRIBUTE_PROCEDURE,
                       f.PROCEDURE_NAME,
                       f.STAGED_ATTRIBUTE_COLUMN,
                       to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3)) COLNUM,
		       nvl(TAG,'C') column_data_type --Bug No: 4954701
                FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f,FND_LOOKUP_VALUES_VL lkp --Bug No: 4954701
                WHERE ENTITY_NAME = 'PARTY'
                AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
                AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
		AND lkp.LOOKUP_TYPE = 'PARTY_LOGICAL_ATTRIBUTE_LIST' --Bug No: 4954701
		AND lkp.LOOKUP_CODE = a.ATTRIBUTE_NAME --Bug No: 4954701
                ORDER BY COLNUM) LOOP

    IF cur_col_num<ATTRS.COLNUM THEN
      FOR I in cur_col_num..ATTRS.COLNUM-1 LOOP
        l_mincol_list(I) := 'N';
        l_forall_list(I) := 'N';
        l_custom_list(I) := 'N';
      END LOOP;
    END IF;
    cur_col_num:=ATTRS.COLNUM+1;
    IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY'',''STAGE'')';
    ELSE
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY'')';
    END IF;
    l_mincol_list(ATTRS.COLNUM) := 'N';

    SELECT min(to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3))) INTO l_min_colnum
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = 'PARTY'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
    AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
    AND a.ATTRIBUTE_NAME=ATTRS.ATTRIBUTE_NAME;

    IF ATTRS.colnum>l_min_colnum THEN
      l_mincol_list(ATTRS.COLNUM) := 'N';
    IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY'',''STAGE'')';
    ELSE
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY'')';
    END IF;
    ELSE
      l_mincol_list(ATTRS.COLNUM) := 'Y';
    END IF;

    IF ATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
      IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
	 -----Start of Bug No: 4954701----------
	 l_attr_name := ATTRS.ATTRIBUTE_NAME;
         IF(ATTRS.column_data_type ='D') THEN
	  l_org_attr_name := 'TO_CHAR(op.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
	  l_per_attr_name := 'TO_CHAR(pe.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
	  l_attr_name     := 'TO_CHAR(p.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
         ELSE
	  l_org_attr_name := 'op.'||l_attr_name;
	  l_per_attr_name := 'pe.'||l_attr_name;
          l_attr_name     := 'p.'||l_attr_name;
	 END IF;
         -----End of Bug No: 4954701------------
        IF ATTRS.SOURCE_TABLE='HZ_ORGANIZATION_PROFILES' THEN
          l_org_select(idx) := l_org_attr_name;
          l_per_select(idx) := 'NULL';
          l_oth_select(idx) := 'NULL';
        ELSIF ATTRS.SOURCE_TABLE='HZ_PERSON_PROFILES' THEN
          l_per_select(idx) := l_per_attr_name;
          l_org_select(idx) := 'NULL';
          l_oth_select(idx) := 'NULL';
        ELSIF ATTRS.SOURCE_TABLE='HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' OR
              ATTRS.SOURCE_TABLE='HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' THEN
          l_org_select(idx) := l_org_attr_name;
          l_per_select(idx) := l_per_attr_name;
          l_oth_select(idx) := 'NULL';
        ELSE
          l_org_select(idx) := l_attr_name;
          l_per_select(idx) := l_attr_name;
          l_oth_select(idx) := l_attr_name;
        END IF;
      ELSE
        l_org_select(idx):='N';
        l_per_select(idx):='N';
        l_oth_select(idx):='N';
      END IF;

      l_custom_list(ATTRS.COLNUM) := 'N';
    ELSE
        l_org_select(idx):='N';
        l_per_select(idx):='N';
        l_oth_select(idx):='N';
        l_custom_list(ATTRS.COLNUM) := 'N';
        IF ATTRS.ATTRIBUTE_NAME = 'PARTY_ALL_NAMES' THEN
          IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
            l_org_select(idx) := 'p.PARTY_NAME || '' '' || p.KNOWN_AS || '' '' || p.KNOWN_AS2 || '' '' || p.KNOWN_AS3 || '' ''|| p.KNOWN_AS4 || '' ''|| p.KNOWN_AS5';
            l_per_select(idx) := 'p.PARTY_NAME || '' '' || p.KNOWN_AS || '' '' || p.KNOWN_AS2 || '' '' || p.KNOWN_AS3 || '' ''|| p.KNOWN_AS4 || '' ''|| p.KNOWN_AS5';
            l_oth_select(idx) := 'p.PARTY_NAME || '' '' || p.KNOWN_AS || '' '' || p.KNOWN_AS2 || '' '' || p.KNOWN_AS3 || '' ''|| p.KNOWN_AS4 || '' ''|| p.KNOWN_AS5';
          END IF;
        ELSE
          IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
            IF has_context(ATTRS.custom_attribute_procedure) THEN
              l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_P_PARTY_ID(I),''PARTY'','''||ATTRS.ATTRIBUTE_NAME|| ''', ''STAGE'')';
            ELSE
              l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_P_PARTY_ID(I),''PARTY'','''||ATTRS.ATTRIBUTE_NAME|| ''')';
            END IF;
          END IF;
        END IF;
    END IF;
    idx := idx+1;

    -- VJN ADDED CODE FOR TRACKING CONDITION ATTRIBUTES AT THIS ENTITY LEVEL
    IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( ATTRS.attribute_id)
     THEN
         l_cond_attrib_list(ATTRS.COLNUM) := ATTRS.attribute_id ;
    END IF;


  END LOOP;

  IF cur_col_num<255 THEN
    FOR I in cur_col_num..255 LOOP
      l_mincol_list(I) := 'N';
      l_forall_list(I) := 'N';
      l_custom_list(I) := 'N';
    END LOOP;
  END IF;

  l('    IF p_select_type = ''SINGLE_PARTY'' THEN');
  l('      NULL;');
  l('    ELSIF p_select_type = ''ALL_PARTIES'' THEN');
  l('      IF p_continue IS NULL OR p_continue<>''Y'' THEN');
  l('        IF p_party_type = ''ORGANIZATION'' THEN');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, NULL AS PERSON_PARTY_ID '); -- Fix for bug 5155761
  FOR I in 1..l_org_select.COUNT LOOP
    IF l_org_select(I) <> 'N' THEN
      l('                  ,' || l_org_select(I));
    END IF;
  END LOOP;
  l('            FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND p.party_id = op.party_id ');
  l('            AND op.effective_end_date is NULL ');
  l('            AND p.PARTY_TYPE =''ORGANIZATION'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        ELSIF p_party_type = ''PERSON'' THEN');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, p.PARTY_ID AS PERSON_PARTY_ID '); -- Fix for bug 5155761
  FOR I in 1..l_per_select.COUNT LOOP
    IF l_per_select(I) <> 'N' THEN
      l('                  ,' || l_per_select(I));
    END IF;
  END LOOP;
  l('            FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND p.party_id = pe.party_id ');
  l('            AND pe.effective_end_date is NULL ');
  l('            AND p.PARTY_TYPE =''PERSON'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        ELSE');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, NULL AS PERSON_PARTY_ID '); -- Fix for bug 5155761
  FOR I in 1..l_oth_select.COUNT LOOP
    IF l_oth_select(I) <> 'N' THEN
      l('                  ,' || l_oth_select(I));
    END IF;
  END LOOP;
  l('            FROM HZ_PARTIES p ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND p.party_type <> ''PERSON'' ');
  l('            AND p.party_type <> ''ORGANIZATION'' ');
  l('            AND p.party_type <> ''PARTY_RELATIONSHIP'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        END IF;');
  l('      ELSE');
  l('        IF p_party_type = ''ORGANIZATION'' THEN');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, NULL AS PERSON_PARTY_ID '); -- Fix for bug 5155761
  FOR I in 1..l_org_select.COUNT LOOP
    IF l_org_select(I) <> 'N' THEN
      l('                  ,' || l_org_select(I));
    END IF;
  END LOOP;

  l('            FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND NOT EXISTS (select 1 FROM HZ_SHADOW_ST_PARTIES sp  ');
  l('                            WHERE sp.party_id = p.party_id)   ' );
  l('            AND p.party_id = op.party_id ');
  l('            AND op.effective_end_date is NULL ');
  l('            AND p.PARTY_TYPE =''ORGANIZATION'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        ELSIF p_party_type = ''PERSON'' THEN');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, p.PARTY_ID AS PERSON_PARTY_ID '); -- Fix for bug 5155761
  FOR I in 1..l_per_select.COUNT LOOP
    IF l_per_select(I) <> 'N' THEN
      l('                  ,' || l_per_select(I));
    END IF;
  END LOOP;
  l('            FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND NOT EXISTS (select 1 FROM HZ_SHADOW_ST_PARTIES sp  ');
  l('                            WHERE sp.party_id = p.party_id)   ' );
  l('            AND p.party_id = pe.party_id ');
  l('            AND pe.effective_end_date is NULL ');
  l('            AND p.PARTY_TYPE =''PERSON'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        ELSE');
  l('          open x_party_cur FOR ' );
  l('            SELECT p.PARTY_ID, p.STATUS, NULL AS PERSON_PARTY_ID'); -- Fix for bug 5155761
  FOR I in 1..l_oth_select.COUNT LOOP
    IF l_oth_select(I) <> 'N' THEN
      l('                  ,' || l_oth_select(I));
    END IF;
  END LOOP;
  l('            FROM HZ_PARTIES p ');
  l('            WHERE mod(p.PARTY_ID, p_num_workers) = p_worker_number ');
  l('            AND NOT EXISTS (select 1 FROM HZ_SHADOW_ST_PARTIES sp  ');
  l('                            WHERE sp.party_id = p.party_id)   ' );
  l('            AND p.party_type <> ''PERSON'' ');
  l('            AND p.party_type <> ''ORGANIZATION'' ');
  l('            AND p.party_type <> ''PARTY_RELATIONSHIP'' ');
  l('            ORDER BY p.PARTY_NAME;');
  l('        END IF;');
  l('      END IF;');
  l('    END IF;');
  l('  END;');

  l('  PROCEDURE insert_stage_parties ( ');
  l('    p_continue          IN VARCHAR2, ');
  l('    p_party_cur         IN HZ_PARTY_STAGE.StageCurTyp) IS ');
  l('    l_limit NUMBER := ' || g_batch_size || ';');
  l('    l_contact_cur        HZ_PARTY_STAGE.StageCurTyp;');
  l('    l_cpt_cur            HZ_PARTY_STAGE.StageCurTyp;');
  l('    l_party_site_cur     HZ_PARTY_STAGE.StageCurTyp;');
  l('    l_last_fetch         BOOLEAN := FALSE;');
  l('    call_status          BOOLEAN;');
  l('    rphase               varchar2(255);');
  l('    rstatus              varchar2(255);');
  l('    dphase               varchar2(255);');
  l('    dstatus              varchar2(255);');
  l('    message              varchar2(255);');
  l('    req_id               NUMBER;');
  l('    l_st                 number; ');
  l('    l_en                 number; ');
  l('    H_PERSON_PARTY_ID    NumberList;'); -- Fix for bug 5155761
  l('    USER_TERMINATE       EXCEPTION;');
  l('');
  l('  BEGIN');
  l('    req_id := FND_GLOBAL.CONC_REQUEST_ID;');
  l('    LOOP');
  l('      call_status := FND_CONCURRENT.GET_REQUEST_STATUS(');
  l('                req_id, null,null,rphase,rstatus,dphase,dstatus,message);');
  l('      IF dstatus = ''TERMINATING'' THEN');
  l('        FND_FILE.put_line(FND_FILE.log,''Aborted by User'');');
  l('        RAISE USER_TERMINATE;');
  l('      END IF;');
  l('      FETCH p_party_cur BULK COLLECT INTO');
  l('        H_P_PARTY_ID');
  l('        , H_STATUS');
  l('        , H_PERSON_PARTY_ID'); -- Fix for bug 5155761
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         ,H_TX'||I);
    END IF;
  END LOOP;
  l('      LIMIT l_limit;');
  l('');
  l('    IF p_party_cur%NOTFOUND THEN');
  l('      l_last_fetch:=TRUE;');
  l('    END IF;');

  l('    IF H_P_PARTY_ID.COUNT=0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');

  l('    FOR I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST LOOP');

 -- VJN INTRODUCED FOR CONDITIONAL REPLACEMENTS
  -- CYCLE THROUGH THE CONDITON LIST AND GENERATE THE CODE
  -- FOR POPULATING THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(I));');
      l_idx := l_idx+1;
  END LOOP;
  l('         HZ_TRANS_PKG.next_gen_dqm := ''Y'';');
  l('');


  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_custom_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  l('      H_PARTY_INDEX(I) := I;');
  l('    END LOOP;');

  l('    SAVEPOINT party_batch;');
  l('    BEGIN ');
  l('      l_st := 1;  ');
  l('      l_en := H_P_PARTY_ID.COUNT; ');
  l('      LOOP ');
  l('          BEGIN  ');
  l('          FORALL I in l_st..l_en');
  l('            INSERT INTO HZ_SHADOW_ST_PARTIES (');
  l('	           PARTY_ID');
  l('  	           ,STATUS');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('               , TX'||I);
    END IF;
  END LOOP;
  l('             ) VALUES (');
  l('             H_P_PARTY_ID(I)');
  l('             ,H_STATUS(I)');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(I),null,H_TX'||I||'(I),H_TX'||I||'(I)||'' '')');
    END IF;
  END LOOP;
  l('            );');
  l('           EXIT; ');
  l('        EXCEPTION  WHEN OTHERS THEN ');
  l('            l_st:= l_st+SQL%ROWCOUNT+1;');
  l('        END; ');
  l('      END LOOP; ');
  l('      FORALL I in H_P_PARTY_ID.FIRST..H_P_PARTY_ID.LAST');
  l('        INSERT INTO HZ_DQM_STAGE_GT ( PARTY_ID, OWNER_ID, PARTY_INDEX, PERSON_PARTY_ID) VALUES ('); -- Fix for bug 5155761
  l('           H_P_PARTY_ID(I),H_P_PARTY_ID(I),H_PARTY_INDEX(I),H_PERSON_PARTY_ID(I));'); -- Fix for bug 5155761

  l('        insert_stage_contacts;');
  l('        insert_stage_party_sites;');
  l('        insert_stage_contact_pts;');
  l('      EXCEPTION ');
  l('        WHEN OTHERS THEN');
  l('          ROLLBACK to party_batch;');
  l('          RAISE;');
  l('      END;');
  l('      IF l_last_fetch THEN');
  l('        FND_CONCURRENT.AF_Commit;');
  l('        EXIT;');
  l('      END IF;');
  l('      FND_CONCURRENT.AF_Commit;');
  l('    END LOOP;');
  l('  END;');

  l('  PROCEDURE sync_single_party (');
  l('    p_party_id NUMBER,');
  l('    p_party_type VARCHAR2,');
  l('    p_operation VARCHAR2) IS');
  l('');
  l('  l_tryins BOOLEAN;');
  l('  l_tryupd BOOLEAN;');
  l('   BEGIN');
  l('    IF p_party_type = ''ORGANIZATION'' THEN');
  l('      SELECT p.PARTY_ID, p.STATUS ');
  FOR I in 1..l_org_select.COUNT LOOP
    IF l_org_select(I) <> 'N' THEN
      l('        ,' || l_org_select(I));
    END IF;
  END LOOP;
  l('      INTO H_P_PARTY_ID(1), H_STATUS(1)');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;
  l('      FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op ');
  l('      WHERE p.party_id = p_party_id ');
  l('      AND p.party_id = op.party_id ');
  l('      AND (p.status = ''M'' or op.effective_end_date is NULL)  AND ROWNUM=1; ');
  l('    ELSIF p_party_type = ''PERSON'' THEN');
  l('      SELECT p.PARTY_ID, p.STATUS ');
  FOR I in 1..l_per_select.COUNT LOOP
    IF l_per_select(I) <> 'N' THEN
      l('        ,' || l_per_select(I));
    END IF;
  END LOOP;
  l('      INTO H_P_PARTY_ID(1), H_STATUS(1)');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;
  l('      FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe ');
  l('      WHERE p.party_id = p_party_id ');
  l('      AND p.party_id = pe.party_id ');
  l('      AND (p.status = ''M'' or pe.effective_end_date is NULL) AND ROWNUM=1;');
  l('    ELSE');
  l('      SELECT p.PARTY_ID, p.STATUS ');
  FOR I in 1..l_oth_select.COUNT LOOP
    IF l_per_select(I) <> 'N' THEN
      l('        ,' || l_oth_select(I));
    END IF;
  END LOOP;

  l('      INTO H_P_PARTY_ID(1), H_STATUS(1)');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;
  l('      FROM HZ_PARTIES p ');
  l('      WHERE p.party_id = p_party_id;');
  l('    END IF;');
  -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(1));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');


    FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('   H_TX'||I||'(1):='||replace(l_custom_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('   H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('   H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;

  l('   l_tryins := FALSE;');
  l('   l_tryupd := FALSE;');
  l('   IF p_operation=''C'' THEN');
  l('     l_tryins:=TRUE;');
  l('   ELSE ');
  l('     l_tryupd:=TRUE;');
  l('   END IF;');
  l('   WHILE (l_tryins OR l_tryupd) LOOP');
  l('     IF l_tryins THEN');
  l('       BEGIN');
  l('         l_tryins:=FALSE;');
  l('         INSERT INTO HZ_SHADOW_ST_PARTIES (');
  l('             PARTY_ID');
  l('            ,STATUS');
  l('            ,D_PS');
  l('            ,D_CT');
  l('            ,D_CPT');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('              , TX'||I);
    END IF;
  END LOOP;
  l('           ) VALUES (');
  l('             H_P_PARTY_ID(1)');
  l('            ,H_STATUS(1)');
  l('            ,''SYNC''');
  l('            ,''SYNC''');
  l('            ,''SYNC''');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
    END IF;
  END LOOP;
  l('         );');
  l('       EXCEPTION');
  l('         WHEN DUP_VAL_ON_INDEX THEN');
  l('           IF p_operation=''C'' THEN');
  l('             l_tryupd:=TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('     IF l_tryupd THEN');
  l('       BEGIN');
  l('         l_tryupd:=FALSE;');
  l('         UPDATE HZ_SHADOW_ST_PARTIES SET ');
  l('            status =H_STATUS(1) ');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
            l('            ,TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
    END IF;
  END LOOP;
  l('         WHERE PARTY_ID=H_P_PARTY_ID(1);');
  l('         IF SQL%ROWCOUNT=0 AND p_operation=''U'' THEN');
  l('           l_tryins := TRUE;');
  l('         END IF;');
  l('       EXCEPTION ');
  l('         WHEN NO_DATA_FOUND THEN');
  l('           IF p_operation=''U'' THEN');
  l('             l_tryins := TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('   END LOOP;');
  l('  END;');

END;

PROCEDURE generate_party_site_query_proc IS
 cur_col_num NUMBER := 1;

 TYPE coltab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

 l_select coltab;
 FIRST BOOLEAN := FALSE;

 l_forall_list coltab;
 l_custom_list coltab;
 l_mincol_list coltab;
 l_min_colnum NUMBER;
 idx NUMBER :=1;
 is_first boolean := true;

 -- VJN Introduced for conditional word replacements
 l_cond_attrib_list coltab ;
 l_idx number ;
 l_attr_name varchar2(2000); --Bug No: 4954701
 l_ps_attr_name varchar2(2000); --Bug No: 4954701
 l_loc_attr_name varchar2(2000); --Bug No: 4954701
BEGIN

  l('  PROCEDURE insert_stage_party_sites IS ');
  l('  l_limit NUMBER := ' || g_batch_size || ';');
  l('  l_last_fetch BOOLEAN := FALSE;');
  l('  l_denorm VARCHAR2(2000);');
  l('  l_st number; ');
  l('  l_en number; ');

  l(' ');

  FOR ATTRS IN (SELECT a.ATTRIBUTE_ID,
                       a.ATTRIBUTE_NAME,
                       a.SOURCE_TABLE,
                       a.CUSTOM_ATTRIBUTE_PROCEDURE,
                       f.PROCEDURE_NAME,
                       f.STAGED_ATTRIBUTE_COLUMN,
                       to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3)) COLNUM,
		       nvl(lkp.tag,'C') column_data_type
                FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f,FND_LOOKUP_VALUES_VL lkp --Bug No: 4954701
                WHERE ENTITY_NAME = 'PARTY_SITES'
                AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
                AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
		AND lkp.lookup_type = 'PARTY_SITE_LOGICAL_ATTRIB_LIST'
		and lkp.lookup_code = a.ATTRIBUTE_NAME
                ORDER BY COLNUM) LOOP
    IF cur_col_num<ATTRS.COLNUM THEN
      FOR I in cur_col_num..ATTRS.COLNUM-1 LOOP
        l_mincol_list(I) := 'N';
        l_forall_list(I) := 'N';
        l_custom_list(I) := 'N';
      END LOOP;
    END IF;
    cur_col_num:=ATTRS.COLNUM+1;
    IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY_SITES'',''STAGE'')';
    ELSE
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY_SITES'')';
    END IF;

    SELECT min(to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3))) INTO l_min_colnum
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = 'PARTY_SITES'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
    AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
    AND a.ATTRIBUTE_NAME=ATTRS.ATTRIBUTE_NAME;

    IF ATTRS.colnum>l_min_colnum THEN
      l_mincol_list(ATTRS.COLNUM) := 'N';
      IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY_SITES'',''STAGE'')';
      ELSE
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''PARTY_SITES'')';
      END IF;
    ELSE
      l_mincol_list(ATTRS.COLNUM) := 'Y';
    END IF;

    IF ATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
      IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
       	 -----Start of Bug No: 4954701----------
	 l_attr_name := ATTRS.ATTRIBUTE_NAME;
         IF(ATTRS.column_data_type ='D') THEN
	  l_ps_attr_name  := 'TO_CHAR(ps.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
	  l_loc_attr_name := 'TO_CHAR(l.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
         ELSE
	  l_ps_attr_name  := 'ps.'||l_attr_name;
	  l_loc_attr_name := 'l.'||l_attr_name;
	 END IF;
         -----End of Bug No: 4954701------------
        IF ATTRS.SOURCE_TABLE='HZ_LOCATIONS' THEN
          l_select(idx) := l_loc_attr_name;
        ELSIF ATTRS.SOURCE_TABLE='HZ_PARTY_SITES' THEN
          l_select(idx) := l_ps_attr_name;
        END IF;
      ELSE
        l_select(idx) := 'N';
      END IF;

      l_custom_list(ATTRS.COLNUM) := 'N';
    ELSE
      l_select(idx) := 'N';
      l_custom_list(ATTRS.COLNUM) := 'N';
      IF ATTRS.ATTRIBUTE_NAME = 'ADDRESS' THEN
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          l_select(idx) := 'rtrim(l.address1 || '' '' || l.address2 || '' '' || l.address3 || '' '' || l.address4)';
        END IF;
      ELSE
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          IF has_context(ATTRS.custom_attribute_procedure) THEN
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_PARTY_SITE_ID(I),''PARTY_SITES'','''||ATTRS.ATTRIBUTE_NAME|| ''', ''STAGE'')';
          ELSE
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_PARTY_SITE_ID(I), ''PARTY_SITES'','''||ATTRS.ATTRIBUTE_NAME|| ''')';
          END IF;
        END IF;
      END IF;
    END IF;
    idx := idx+1;

    -- VJN ADDED CODE FOR TRACKING CONDITION ATTRIBUTES AT THIS ENTITY LEVEL
    IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( ATTRS.attribute_id)
     THEN
         l_cond_attrib_list(ATTRS.COLNUM) := ATTRS.attribute_id ;
    END IF;

  END LOOP;

  IF cur_col_num<255 THEN
    FOR I in cur_col_num..255 LOOP
      l_mincol_list(I) := 'N';
      l_forall_list(I) := 'N';
      l_custom_list(I) := 'N';
    END LOOP;
  END IF;

  l('    CURSOR party_site_cur IS');
  l('            SELECT /*+ cardinality(g 200) use_nl(g ps l) */ ps.PARTY_SITE_ID, g.party_id, g.org_contact_id, g.PARTY_INDEX, g.PERSON_PARTY_ID, ps.status '); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('                  ,' || l_select(I));
    END IF;
  END LOOP;

  l('            FROM HZ_DQM_STAGE_GT g, HZ_PARTY_SITES ps, HZ_LOCATIONS l');
  l('            WHERE ps.PARTY_ID = g.owner_id ');
  l('            AND (ps.status is null OR ps.status = ''A'' OR ps.status = ''I'')    ');
  l('            AND ps.location_id = l.location_id; ');

  l('  BEGIN');
  l('    OPEN party_site_cur;');
  l('    LOOP');
  l('      FETCH party_site_cur BULK COLLECT INTO');
  l('        H_PARTY_SITE_ID');
  l('        ,H_PS_PARTY_ID');
  l('        ,H_PS_ORG_CONTACT_ID');
  l('        ,H_PARTY_INDEX');
  l('        ,H_PERSON_PARTY_ID');
  l('        ,H_STATUS'); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         ,H_TX'||I);
    END IF;
  END LOOP;
  l('      LIMIT l_limit;');
  l('');
  l('    IF party_site_cur%NOTFOUND THEN');
  l('      l_last_fetch:=TRUE;');
  l('    END IF;');

  l('    IF H_PS_PARTY_ID.COUNT=0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');

  l('    FOR I in H_PS_PARTY_ID.FIRST..H_PS_PARTY_ID.LAST LOOP');

  -- VJN INTRODUCED FOR CONDITIONAL REPLACEMENTS
  -- CYCLE THROUGH THE CONDITON LIST AND GENERATE THE CODE
  -- FOR POPULATING THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ---------');
  END IF ;


  l('');


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(I));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');

  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_custom_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;


  l('    END LOOP;');
  l('      l_st := 1;  ');
  l('      l_en :=  H_PS_PARTY_ID.COUNT; ');
  l('      LOOP ');
  l('          BEGIN  ');
  l('          FORALL I in l_st..l_en');
  l('             INSERT INTO HZ_SHADOW_ST_PSITES (');
  l('	              PARTY_SITE_ID');
  l('	              ,PARTY_ID');
  l('	              ,ORG_CONTACT_ID');
  l('	              ,PERSON_PARTY_ID');
  l('	              ,STATUS_FLAG');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('                 , TX'||I);
    END IF;
  END LOOP;
  l('                 ,QKEY');
  l('                 ) VALUES (');
  l('                 H_PARTY_SITE_ID(I)');
  l('                ,H_PS_PARTY_ID(I)');
  l('                ,H_PS_ORG_CONTACT_ID(I)');
  l('                ,H_PERSON_PARTY_ID(I)');
  l('                ,H_STATUS(I)'); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('                 , decode(H_TX'||I||'(I),null,H_TX'||I||'(I),H_TX'||I||'(I)||'' '')');
    END IF;
  END LOOP;
  l('                ,'||G_PS_QKEY_STR);
  l('        );');
  l('        EXIT; ');
  l('        EXCEPTION  WHEN OTHERS THEN ');
  l('            l_st:= l_st+SQL%ROWCOUNT+1;');
  l('        END; ');
  l('      END LOOP; ');
  l('      FORALL I in H_PS_PARTY_ID.FIRST..H_PS_PARTY_ID.LAST ');
  l('        INSERT INTO HZ_DQM_STAGE_GT (PARTY_ID, OWNER_ID, OWNER_TABLE, PARTY_SITE_ID,');
  l('                                     PERSON_PARTY_ID, ORG_CONTACT_ID,PARTY_INDEX) VALUES (');
  l('        H_PS_PARTY_ID(I),H_PARTY_SITE_ID(I),''HZ_PARTY_SITES'',H_PARTY_SITE_ID(I),');
  l('        H_PERSON_PARTY_ID(I), H_PS_ORG_CONTACT_ID(I),H_PARTY_INDEX(I));'); -- Fix for bug 5155761

  l('      IF l_last_fetch THEN');
  l('        EXIT;');
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE party_site_cur;');
  l('  END;');

  l('  PROCEDURE sync_single_party_site (');
  l('    p_party_site_id NUMBER,');
  l('    p_operation VARCHAR2) IS');
  l('');
  l('  l_tryins BOOLEAN;');
  l('  l_tryupd BOOLEAN;');
  l('   BEGIN');

  l('     SELECT ps.PARTY_SITE_ID, d.party_id, d.org_contact_id, ps.status '); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('                  ,' || l_select(I));
    END IF;
  END LOOP;
  l('      INTO H_PARTY_SITE_ID(1), H_PARTY_ID(1), H_ORG_CONTACT_ID(1),H_STATUS(1) ');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;
  l('     FROM HZ_PARTY_SITES ps, HZ_DQM_SYNC_INTERFACE d, HZ_LOCATIONS l ');
  l('     WHERE d.ENTITY=''PARTY_SITES'' ');
  l('     AND ps.party_site_id = p_party_site_id');
  l('     AND d.record_id = ps.party_site_id ');
  l('     AND ps.location_id = l.location_id ');
  l('     AND (ps.status is null OR ps.status = ''A'' OR ps.status = ''I'')    ');
  l('     AND ROWNUM=1;');

  -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE PARTY SITE LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(1));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');

  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_custom_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;

  l('   l_tryins := FALSE;');
  l('   l_tryupd := FALSE;');
  l('   IF p_operation=''C'' THEN');
  l('     l_tryins:=TRUE;');
  l('   ELSE ');
  l('     l_tryupd:=TRUE;');
  l('   END IF;');
  l('   WHILE (l_tryins OR l_tryupd) LOOP');
  l('     IF l_tryins THEN');
  l('       BEGIN');
  l('         l_tryins:=FALSE;');
  l('         INSERT INTO HZ_SHADOW_ST_PSITES (');
  l('           PARTY_SITE_ID');
  l('           ,PARTY_ID');
  l('           ,ORG_CONTACT_ID');
  l('           ,STATUS_FLAG');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('              , TX'||I);
    END IF;
  END LOOP;
  l('           ) VALUES (');
  l('            H_PARTY_SITE_ID(1)');
  l('            ,H_PARTY_ID(1)');
  l('            ,H_ORG_CONTACT_ID(1)');
  l('           ,H_STATUS(1) '); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
    END IF;
  END LOOP;
  l('         );');
  l('       EXCEPTION');
  l('         WHEN DUP_VAL_ON_INDEX THEN');
  l('           IF p_operation=''C'' THEN');
  l('             l_tryupd:=TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('     IF l_tryupd THEN');
  l('       BEGIN');
  l('         l_tryupd:=FALSE;');
  l('         UPDATE HZ_SHADOW_ST_PSITES SET ');

  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      	IF (is_first) THEN
	     is_first := false;
             l('            TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	ELSE
             l('            ,TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	END IF;
    END IF;
  END LOOP;
  l('            ,STATUS_FLAG = H_STATUS(1) ');-- Bug No: 4299785
  l('         WHERE PARTY_SITE_ID=H_PARTY_SITE_ID(1);');
  l('         IF SQL%ROWCOUNT=0 AND p_operation=''U'' THEN');
  l('           l_tryins := TRUE;');
  l('         END IF;');
  l('       EXCEPTION ');
  l('         WHEN NO_DATA_FOUND THEN');
  l('           IF p_operation=''U'' THEN');
  l('             l_tryins := TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('   END LOOP;');
  l('   UPDATE HZ_SHADOW_ST_PARTIES set');
  l('   D_PS = ''SYNC''');
  l('   WHERE PARTY_ID = H_PARTY_ID(1);');
  l('  END;');
END;

PROCEDURE generate_contact_query_proc IS
 cur_col_num NUMBER := 1;

 TYPE coltab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

 l_select coltab;
 FIRST BOOLEAN := FALSE;

 l_forall_list coltab;
 l_custom_list coltab;
 l_mincol_list coltab;
 l_min_colnum NUMBER;
 idx NUMBER :=1;
 is_first boolean := true;

 -- VJN Introduced for conditional word replacements
 l_cond_attrib_list coltab ;
 l_idx number ;
 l_attr_name     varchar2(2000); --Bug No: 4954701
 l_pp_attr_name  varchar2(2000); --Bug No: 4954701
 l_oc_attr_name  varchar2(2000); --Bug No: 4954701
BEGIN

  l('  PROCEDURE insert_stage_contacts IS ');
  l('    l_limit NUMBER := ' || g_batch_size || ';');
  l('    l_last_fetch BOOLEAN := FALSE;');
  l('    l_denorm VARCHAR2(2000);');
  l('    l_st number; ');
  l('    l_en number; ');
  FOR ATTRS IN (SELECT a.ATTRIBUTE_ID,
                       a.ATTRIBUTE_NAME,
                       a.SOURCE_TABLE,
                       a.CUSTOM_ATTRIBUTE_PROCEDURE,
                       f.PROCEDURE_NAME,
                       f.STAGED_ATTRIBUTE_COLUMN,
                       to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3)) COLNUM,
		       nvl(lkp.tag,'C') column_data_type
                FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f,FND_LOOKUP_VALUES_VL lkp --Bug No: 4954701
                WHERE ENTITY_NAME = 'CONTACTS'
                AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
                AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
		AND lkp.LOOKUP_TYPE='CONTACT_LOGICAL_ATTRIB_LIST'
                AND lkp.LOOKUP_CODE =  a.ATTRIBUTE_NAME
                ORDER BY COLNUM) LOOP
    IF cur_col_num<ATTRS.COLNUM THEN
      FOR I in cur_col_num..ATTRS.COLNUM-1 LOOP
        l_mincol_list(I) := 'N';
        l_forall_list(I) := 'N';
        l_custom_list(I) := 'N';
      END LOOP;
    END IF;
    cur_col_num:=ATTRS.COLNUM+1;
    IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACTS'',''STAGE'')';
    ELSE
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACTS'')';
    END IF;

    SELECT min(to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3))) INTO l_min_colnum
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = 'CONTACTS'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
    AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
    AND a.ATTRIBUTE_NAME=ATTRS.ATTRIBUTE_NAME;

    IF ATTRS.colnum>l_min_colnum THEN
      l_mincol_list(ATTRS.COLNUM) := 'N';
      IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACTS'',''STAGE'')';
      ELSE
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACTS'')';
      END IF;

    ELSE
      l_mincol_list(ATTRS.COLNUM) := 'Y';
    END IF;

    IF ATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
      IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
	 -----Start of Bug No: 4954701----------
	 l_attr_name := ATTRS.ATTRIBUTE_NAME;
         IF(ATTRS.column_data_type ='D') THEN
	  l_pp_attr_name := 'TO_CHAR(pp.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
	  l_oc_attr_name := 'TO_CHAR(oc.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
	  l_attr_name    := 'TO_CHAR(r.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
         ELSE
	  l_pp_attr_name := 'pp.'||l_attr_name;
	  l_oc_attr_name := 'oc.'||l_attr_name;
          l_attr_name    := 'r.'||l_attr_name;
	 END IF;
         -----End of Bug No: 4954701------------
        IF ATTRS.SOURCE_TABLE='HZ_PERSON_PROFILES' THEN
          l_select(idx) := l_pp_attr_name;
        ELSIF ATTRS.SOURCE_TABLE='HZ_ORG_CONTACTS' THEN
          l_select(idx) := l_oc_attr_name;
        ELSIF ATTRS.SOURCE_TABLE='HZ_RELATIONSHIPS' THEN
          l_select(idx) := l_attr_name;
        END IF;
      ELSE
        l_select(idx) := 'N';
      END IF;

      l_custom_list(ATTRS.COLNUM) := 'N';
    ELSE
      l_select(idx) := 'N';
      l_custom_list(ATTRS.COLNUM) := 'N';
      IF ATTRS.ATTRIBUTE_NAME = 'CONTACT_NAME' THEN
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          l_select(idx) := 'rtrim(pp.person_first_name || '' '' || pp.person_last_name)';
        END IF;
      ELSE
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          IF has_context(ATTRS.custom_attribute_procedure) THEN
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_ORG_CONTACT_ID(I),''CONTACTS'','''||ATTRS.ATTRIBUTE_NAME|| ''', ''STAGE'')';
          ELSE
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_ORG_CONTACT_ID(I), ''CONTACTS'','''||ATTRS.ATTRIBUTE_NAME|| ''')';
          END IF;
        END IF;
      END IF;
    END IF;
    idx := idx+1;
    -- VJN ADDED CODE FOR TRACKING CONDITION ATTRIBUTES AT THIS ENTITY LEVEL
    IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( ATTRS.attribute_id)
     THEN
         l_cond_attrib_list(ATTRS.COLNUM) := ATTRS.attribute_id ;
    END IF;
  END LOOP;

  IF cur_col_num<255 THEN
    FOR I in cur_col_num..255 LOOP
      l_mincol_list(I) := 'N';
      l_forall_list(I) := 'N';
      l_custom_list(I) := 'N';
    END LOOP;
  END IF;

  l('  CURSOR contact_cur IS');
  l('            SELECT ');
  l('              /*+ cardinality(g 200) use_nl(g r oc pp) */');
  l('            oc.ORG_CONTACT_ID , r.OBJECT_ID, r.PARTY_ID, g.PARTY_INDEX,r.SUBJECT_ID, r.status '); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('                  ,' || l_select(I));
    END IF;
  END LOOP;
  l('           FROM HZ_DQM_STAGE_GT g, HZ_RELATIONSHIPS r,');
  l('           HZ_ORG_CONTACTS oc, HZ_PERSON_PROFILES pp');
  l('           WHERE oc.party_relationship_id =  r.relationship_id ');
  l('           AND r.object_id = g.party_id ');
  l('           AND r.subject_id = pp.party_id ');
  l('           AND r.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('           AND r.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('           AND DIRECTIONAL_FLAG= ''F'' ');
  l('           AND pp.effective_end_date is NULL ');
  l('           AND (oc.status is null OR oc.status = ''A'' or oc.status = ''I'')');
  l('           AND (r.status is null OR r.status = ''A'' or r.status = ''I'');');
  l('');
  l('  BEGIN');
  l('    OPEN contact_cur;');
  l('    LOOP');
  l('      FETCH contact_cur BULK COLLECT INTO');
  l('        H_ORG_CONTACT_ID');
  l('        ,H_C_PARTY_ID');
  l('        ,H_R_PARTY_ID');
  l('        ,H_PARTY_INDEX');
  l('        ,H_PERSON_PARTY_ID');
  l('        ,H_STATUS');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         ,H_TX'||I);
    END IF;
  END LOOP;
  l('      LIMIT l_limit;');
  l('');
  l('    IF contact_cur%NOTFOUND THEN');
  l('      l_last_fetch:=TRUE;');
  l('    END IF;');

  l('    IF H_C_PARTY_ID.COUNT=0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');

  l('    FOR I in H_C_PARTY_ID.FIRST..H_C_PARTY_ID.LAST LOOP');


  -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD
  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE CONTACT LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(I));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');

  l('');

  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_custom_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;

  l('    END LOOP;');
  l('      l_st :=  1;  ');
  l('      l_en :=  H_C_PARTY_ID.COUNT; ');
  l('      LOOP ');
  l('          BEGIN  ');
  l('             FORALL I in l_st..l_en');
  l('             INSERT INTO HZ_SHADOW_ST_CONTACTS (');
  l('	            ORG_CONTACT_ID');
  l('	            ,PARTY_ID');
  l('	            ,PERSON_PARTY_ID');
  l('	            ,STATUS_FLAG');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('                , TX'||I);
    END IF;
  END LOOP;
  l('                 ,QKEY');
  l('             ) VALUES (');
  l('             H_ORG_CONTACT_ID(I)');
  l('             ,H_C_PARTY_ID(I)');
  l('             ,H_PERSON_PARTY_ID(I)');
  l('             ,H_STATUS(I)'); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(I),null,H_TX'||I||'(I),H_TX'||I||'(I)||'' '')');
    END IF;
  END LOOP;
  l('                ,'||G_C_QKEY_STR);
  l('          );');
  l('        EXIT; ');
  l('        EXCEPTION  WHEN OTHERS THEN ');
  l('            l_st:= l_st+SQL%ROWCOUNT+1;');
  l('        END; ');
  l('      END LOOP; ');
  l('      FORALL I in H_C_PARTY_ID.FIRST..H_C_PARTY_ID.LAST ');
  l('        INSERT INTO HZ_DQM_STAGE_GT(PARTY_ID,OWNER_ID,ORG_CONTACT_ID,PARTY_INDEX, PERSON_PARTY_ID) ');
  l('           SELECT H_C_PARTY_ID(I), H_R_PARTY_ID(I), H_ORG_CONTACT_ID(I), H_PARTY_INDEX(I), H_PERSON_PARTY_ID(I)');
  l('           FROM DUAL WHERE H_R_PARTY_ID(I) IS NOT NULL;');
  l('      IF l_last_fetch THEN');
  l('        EXIT;');
  l('      END IF;');
  l('    END LOOP;');
  l('     CLOSE contact_cur;');
  l('  END;');

  l('  PROCEDURE sync_single_contact (');
  l('    p_org_contact_id NUMBER,');
  l('    p_operation VARCHAR2) IS');
  l('');
  l('  l_tryins BOOLEAN;');
  l('  l_tryupd BOOLEAN;');
  l('   BEGIN');
  l('     SELECT oc.ORG_CONTACT_ID , d.PARTY_ID, r.status '); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('          ,' || l_select(I));
    END IF;
  END LOOP;
  l('      INTO H_ORG_CONTACT_ID(1), H_PARTY_ID(1), H_STATUS(1) '); --Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;

  l('     FROM HZ_ORG_CONTACTS oc, HZ_DQM_SYNC_INTERFACE d, ');
  l('          HZ_RELATIONSHIPS r, HZ_PERSON_PROFILES pp');
  l('     WHERE d.ENTITY = ''CONTACTS'' ');
  l('     AND oc.org_contact_id = p_org_contact_id');
  l('     AND oc.org_contact_id = d.RECORD_ID');
  l('     AND oc.party_relationship_id =  r.relationship_id ');
  l('     AND r.subject_id = pp.party_id ');
  l('     AND r.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('     AND r.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('     AND DIRECTIONAL_FLAG= ''F'' ');
  l('     AND pp.effective_end_date is NULL ');
  l('     AND (oc.status is null OR oc.status = ''A'' or oc.status = ''I'')');
  l('     AND (r.status is null OR r.status = ''A'' or r.status = ''I'')');
  l('     AND ROWNUM=1;');

  -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE CONTACT LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(1));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_custom_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;

  l('   l_tryins := FALSE;');
  l('   l_tryupd := FALSE;');
  l('   IF p_operation=''C'' THEN');
  l('     l_tryins:=TRUE;');
  l('   ELSE ');
  l('     l_tryupd:=TRUE;');
  l('   END IF;');
  l('   WHILE (l_tryins OR l_tryupd) LOOP');
  l('     IF l_tryins THEN');
  l('       BEGIN');
  l('         l_tryins:=FALSE;');
  l('         INSERT INTO HZ_SHADOW_ST_CONTACTS (');
  l('           ORG_CONTACT_ID');
  l('           ,PARTY_ID');
  l('           ,STATUS_FLAG '); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('              , TX'||I);
    END IF;
  END LOOP;
  l('           ) VALUES (');
  l('            H_ORG_CONTACT_ID(1)');
  l('            , H_PARTY_ID(1)');
  l('            , H_STATUS(1)');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
    END IF;
  END LOOP;
  l('         );');
  l('       EXCEPTION');
  l('         WHEN DUP_VAL_ON_INDEX THEN');
  l('           IF p_operation=''C'' THEN');
  l('             l_tryupd:=TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('     IF l_tryupd THEN');
  l('       BEGIN');
  l('         l_tryupd:=FALSE;');
  l('         UPDATE HZ_SHADOW_ST_CONTACTS SET ');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      	IF (is_first) THEN
             is_first := false;
             l('            TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	ELSE
             l('            ,TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	END IF;
    END IF;
  END LOOP;
  l('         ,STATUS_FLAG = H_STATUS(1) ');-- Bug No: 4299785
  l('         WHERE ORG_CONTACT_ID=H_ORG_CONTACT_ID(1);');
  l('         IF SQL%ROWCOUNT=0 AND p_operation=''U'' THEN');
  l('           l_tryins := TRUE;');
  l('         END IF;');
  l('       EXCEPTION ');
  l('         WHEN NO_DATA_FOUND THEN');
  l('           IF p_operation=''U'' THEN');
  l('             l_tryins := TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('   END LOOP;');
  l('   UPDATE HZ_SHADOW_ST_PARTIES set');
  l('   D_CT = ''SYNC''');
  l('   WHERE PARTY_ID = H_PARTY_ID(1);');
  l('  END;');
END;


PROCEDURE generate_contact_pt_query_proc IS
 cur_col_num NUMBER := 1;

 TYPE coltab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

 l_select coltab;
 FIRST BOOLEAN := FALSE;

 l_forall_list coltab;
 l_custom_list coltab;
 l_mincol_list coltab;
 l_min_colnum NUMBER;
 idx NUMBER :=1;
 is_first boolean := true;

 -- VJN Introduced for conditional word replacements
 l_cond_attrib_list coltab ;
 l_idx number ;
 l_attr_name varchar2(2000);

BEGIN
  l('  PROCEDURE insert_stage_contact_pts IS ');
  l('   l_limit NUMBER := ' || g_batch_size || ';');
  l('   l_last_fetch BOOLEAN := FALSE;');
  l('   l_denorm VARCHAR2(2000);');
  l('   l_st number; ');
  l('   l_en number; ');

  l('');

  FOR ATTRS IN (SELECT a.ATTRIBUTE_ID,
                       a.ATTRIBUTE_NAME,
                       a.SOURCE_TABLE,
                       a.CUSTOM_ATTRIBUTE_PROCEDURE,
                       f.PROCEDURE_NAME,
                       f.STAGED_ATTRIBUTE_COLUMN,
                       to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3)) COLNUM,
		       nvl(lkp.tag,'C') column_data_type
                FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f,FND_LOOKUP_VALUES_VL lkp --Bug No: 4954701
                WHERE ENTITY_NAME = 'CONTACT_POINTS'
                AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
                AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
		AND lkp.LOOKUP_TYPE = 'CONTACT_PT_LOGICAL_ATTRIB_LIST'
		AND lkp.lookup_code = a.ATTRIBUTE_NAME
                ORDER BY COLNUM) LOOP
    IF cur_col_num<ATTRS.COLNUM THEN
      FOR I in cur_col_num..ATTRS.COLNUM-1 LOOP
        l_mincol_list(I) := 'N';
        l_forall_list(I) := 'N';
      END LOOP;
    END IF;
    cur_col_num:=ATTRS.COLNUM+1;
    IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACT_POINTS'',''STAGE'')';
    ELSE
      l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||ATTRS.COLNUM||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACT_POINTS'')';
    END IF;

    SELECT min(to_number(substrb(STAGED_ATTRIBUTE_COLUMN, 3))) INTO l_min_colnum
    FROM HZ_TRANS_ATTRIBUTES_VL a, HZ_TRANS_FUNCTIONS_VL f
    WHERE ENTITY_NAME = 'CONTACT_POINTS'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'
    AND f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
    AND a.ATTRIBUTE_NAME=ATTRS.ATTRIBUTE_NAME;

    IF ATTRS.colnum>l_min_colnum THEN
      l_mincol_list(ATTRS.COLNUM) := 'N';
      IF has_trx_context(ATTRS.PROCEDURE_NAME) THEN
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACT_POINTS'',''STAGE'')';
      ELSE
        l_forall_list(ATTRS.COLNUM) := ATTRS.PROCEDURE_NAME || '(H_TX'||l_min_colnum||'(I),NULL, ''' || ATTRS.ATTRIBUTE_NAME || ''',''CONTACT_POINTS'')';
      END IF;

    ELSE
      l_mincol_list(ATTRS.COLNUM) := 'Y';
    END IF;

    IF ATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
	-----Start of Bug No: 4954701----------
	l_attr_name := ATTRS.ATTRIBUTE_NAME;
        IF(ATTRS.column_data_type ='D') THEN
	   l_attr_name    := 'TO_CHAR(cp.'||l_attr_name||',''DD-MON-YYYY'') '||l_attr_name;
        ELSE
          l_attr_name    := 'cp.'||l_attr_name;
	END IF;
        -----End of Bug No: 4954701------------
      IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
        l_select(idx) := l_attr_name;
      ELSE
        l_select(idx) := 'N';
      END IF;

      l_custom_list(ATTRS.COLNUM) := 'N';
    ELSE
      l_select(idx) := 'N';
      l_custom_list(ATTRS.COLNUM) := 'N';
      IF ATTRS.ATTRIBUTE_NAME = 'FLEX_FORMAT_PHONE_NUMBER' THEN
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          l_select(idx) := 'translate(phone_number,''0123456789ABCDEFGHIJKLMNOPQRSTUV'||
'WXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''''*+,-./:;<=>?@[\]^'||
'_`{|}~ '',''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ'') || '' '' || ' ||
                           'translate(phone_area_code||'' '' || phone_number,''0123456789ABCDEFGHIJKLMNOPQRSTUV'||
'WXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''''*+,-./:;<=>?@[\]^'||
'_`{|}~ '',''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ'') || '' '' || '||
                           ' translate(phone_country_code|| '' '' || phone_area_code||'' '' || phone_number,''0123456789ABCDEFGHIJKLMNOPQRSTUV'||
'WXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''''*+,-./:;<=>?@[\]^'||
'_`{|}~ '',''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ'')';
        END IF;
      ELSIF ATTRS.ATTRIBUTE_NAME = 'RAW_PHONE_NUMBER' THEN
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          l_select(idx) := 'translate(phone_country_code|| '' '' || phone_area_code||'' '' || phone_number,''0123456789ABCDEFGHIJKLMNOPQRSTUV'||
'WXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''''*+,-./:;<=>?@[\]^_'||
'`{|}~ '',''0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ'')';

        END IF;
      ELSE
        IF l_mincol_list(ATTRS.COLNUM) = 'Y' THEN
          IF has_context(ATTRS.custom_attribute_procedure) THEN
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_CONTACT_POINT_ID(I),''CONTACT_POINTS'','''||ATTRS.ATTRIBUTE_NAME|| ''', ''STAGE'')';
          ELSE
            l_custom_list(ATTRS.COLNUM) := ATTRS.custom_attribute_procedure || '(H_CONTACT_POINT_ID(I), ''CONTACT_POINTS'','''||ATTRS.ATTRIBUTE_NAME|| ''')';
          END IF;
        END IF;
      END IF;
    END IF;
    idx := idx+1;

    -- VJN ADDED CODE FOR TRACKING CONDITION ATTRIBUTES AT THIS ENTITY LEVEL
    IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( ATTRS.attribute_id)
     THEN
         l_cond_attrib_list(ATTRS.COLNUM) := ATTRS.attribute_id ;
    END IF;

  END LOOP;

  IF cur_col_num<255 THEN
    FOR I in cur_col_num..255 LOOP
      l_mincol_list(I) := 'N';
      l_forall_list(I) := 'N';
      l_custom_list(I) := 'N';
    END LOOP;
  END IF;

  l('  CURSOR contact_pt_cur IS');
  l('           SELECT /*+ cardinality(g 200) use_nl(g cp) */ cp.CONTACT_POINT_ID, g.party_id, g.party_site_id, g.org_contact_id, cp.CONTACT_POINT_TYPE, PARTY_INDEX, g.PERSON_PARTY_ID, cp.status'); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('                  ,' || l_select(I));
    END IF;
  END LOOP;
  l('           FROM HZ_DQM_STAGE_GT g,HZ_CONTACT_POINTS cp');
  l('           WHERE cp.owner_table_id  =  g.owner_id ');
  l('           AND cp.OWNER_TABLE_NAME = nvl(g.owner_table,''HZ_PARTIES'') ');
  l('           AND (cp.status is null OR cp.status = ''A'' or cp.status = ''I''); ');
  l('');
  l('  BEGIN');
  l('    OPEN contact_pt_cur;');
  l('    LOOP');
  l('      FETCH contact_pt_cur BULK COLLECT INTO');
  l('        H_CONTACT_POINT_ID');
  l('        ,H_CPT_PARTY_ID');
  l('        ,H_CPT_PARTY_SITE_ID');
  l('        ,H_CPT_ORG_CONTACT_ID');
  l('        ,H_CONTACT_POINT_TYPE');
  l('        ,H_PARTY_INDEX');
  l('        ,H_PERSON_PARTY_ID');
  l('        ,H_STATUS');  -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         ,H_TX'||I);
    END IF;
  END LOOP;
  l('      LIMIT l_limit;');
  l('');
  l('    IF contact_pt_cur%NOTFOUND THEN');
  l('      l_last_fetch:=TRUE;');
  l('    END IF;');

  l('    IF H_CPT_PARTY_ID.COUNT=0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');

  l('    FOR I in H_CPT_PARTY_ID.FIRST..H_CPT_PARTY_ID.LAST LOOP');

  -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE CONTACT POINT LEVEL ---------');
  END IF ;

  l('');


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(I));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_custom_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('         H_TX'||I||'(I):='||l_forall_list(I)||';');
      END IF;
    END IF;
  END LOOP;
  l('    END LOOP;');
  l('      l_st := 1;  ');
  l('      l_en := H_CPT_PARTY_ID.COUNT; ');
  l('      LOOP ');
  l('          BEGIN  ');
  l('              FORALL I in l_st..l_en');
  l('                INSERT INTO HZ_SHADOW_ST_CPTS (');
  l('	               CONTACT_POINT_ID');
  l('	               ,PARTY_ID');
  l('	               ,PARTY_SITE_ID');
  l('	               ,ORG_CONTACT_ID');
  l('	               ,CONTACT_POINT_TYPE');
  l('	               ,PERSON_PARTY_ID');
  l('	               ,STATUS_FLAG');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('                   , TX'||I);
    END IF;
  END LOOP;
  l('                 ,QKEY');
  l('                   ) VALUES (');
  l('                   H_CONTACT_POINT_ID(I)');
  l('                   ,H_CPT_PARTY_ID(I)');
  l('                   ,H_CPT_PARTY_SITE_ID(I)');
  l('                   ,H_CPT_ORG_CONTACT_ID(I)');
  l('                   ,H_CONTACT_POINT_TYPE(I)');
  l('                   ,H_PERSON_PARTY_ID(I)');
  l('                   ,H_STATUS(I)');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('                  , decode(H_TX'||I||'(I),null,H_TX'||I||'(I),H_TX'||I||'(I)||'' '')');
    END IF;
  END LOOP;
  l('                ,'||G_CPT_QKEY_STR);
  l('          );');
  l('        EXIT; ');
  l('        EXCEPTION  WHEN OTHERS THEN ');
  l('            l_st:= l_st+SQL%ROWCOUNT+1;');
  l('        END; ');
  l('      END LOOP; ');
  l('      IF l_last_fetch THEN');
  l('        EXIT;');
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE contact_pt_cur;');
  l('  END;');

  l('  PROCEDURE sync_single_contact_point (');
  l('    p_contact_point_id NUMBER,');
  l('    p_operation VARCHAR2) IS');
  l('');
  l('  l_tryins BOOLEAN;');
  l('  l_tryupd BOOLEAN;');
  l('   BEGIN');
  l('     SELECT cp.CONTACT_POINT_ID, d.PARTY_ID, d.PARTY_SITE_ID, d.ORG_CONTACT_ID, cp.CONTACT_POINT_TYPE, cp.STATUS '); -- Bug No: 4299785
  FOR I in 1..l_select.COUNT LOOP
    IF l_select(I) <> 'N' THEN
      l('            ,' || l_select(I));
    END IF;
  END LOOP;
  l('      INTO H_CONTACT_POINT_ID(1),H_PARTY_ID(1), H_PARTY_SITE_ID(1),H_ORG_CONTACT_ID(1),H_CONTACT_POINT_TYPE(1), H_STATUS(1) '); -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' AND l_mincol_list(I) = 'Y' AND
       l_custom_list(I) = 'N' THEN
      l('         , H_TX'||I||'(1)');
    END IF;
  END LOOP;
  l('     FROM HZ_CONTACT_POINTS cp, HZ_DQM_SYNC_INTERFACE d ');
  l('     WHERE  d.ENTITY = ''CONTACT_POINTS'' ');
  l('     AND cp.contact_point_id  =  p_contact_point_id ');
  l('     AND cp.contact_point_id  =  d.RECORD_ID ');
  l('     AND (cp.status is null OR cp.status = ''A'' or cp.status = ''I'') and rownum = 1 ; ');
   -- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
  -- OF THE GLOBAL CONDITION RECORD

  l_idx := l_cond_attrib_list.FIRST ;
  IF l_idx IS NOT NULL
  THEN
    l('----------- SETTING GLOBAL CONDITION RECORD AT THE CONTACT POINT LEVEL ---------');
  END IF ;


  WHILE l_cond_attrib_list.EXISTS(l_idx)
  LOOP

      l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||l_cond_attrib_list(l_idx)||','||'H_TX'||l_idx||'(1));');
      l_idx := l_idx+1;
  END LOOP;
  l('     HZ_TRANS_PKG.next_gen_dqm := ''Y'';');

  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_custom_list(I) <> 'N' AND l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_custom_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) <> 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      IF l_mincol_list(I) = 'Y' THEN
        l('    H_TX'||I||'(1):='||replace(l_forall_list(I),'(I)','(1)')||';');
      END IF;
    END IF;
  END LOOP;
  l('   l_tryins := FALSE;');
  l('   l_tryupd := FALSE;');
  l('   IF p_operation=''C'' THEN');
  l('     l_tryins:=TRUE;');
  l('   ELSE ');
  l('     l_tryupd:=TRUE;');
  l('   END IF;');
  l('   WHILE (l_tryins OR l_tryupd) LOOP');
  l('     IF l_tryins THEN');
  l('       BEGIN');
  l('         l_tryins:=FALSE;');
  l('         INSERT INTO HZ_SHADOW_ST_CPTS (');
  l('           CONTACT_POINT_ID');
  l('           ,PARTY_ID');
  l('           ,PARTY_SITE_ID');
  l('           ,ORG_CONTACT_ID');
  l('           ,CONTACT_POINT_TYPE');
  l('           ,PERSON_PARTY_ID');
  l('           ,STATUS_FLAG');-- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('              , TX'||I);
    END IF;
  END LOOP;
  l('           ) VALUES (');
  l('             H_CONTACT_POINT_ID(1)');
  l('            ,H_PARTY_ID(1)');
  l('            ,H_PARTY_SITE_ID(1)');
  l('            ,H_ORG_CONTACT_ID(1)');
  l('            ,H_CONTACT_POINT_TYPE(1)');
  l('            ,H_PERSON_PARTY_ID(1)');
  l('            ,H_STATUS(1)');  -- Bug No: 4299785
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
      l('             , decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
    END IF;
  END LOOP;
  l('         );');
  l('       EXCEPTION');
  l('         WHEN DUP_VAL_ON_INDEX THEN');
  l('           IF p_operation=''C'' THEN');
  l('             l_tryupd:=TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('     IF l_tryupd THEN');
  l('       BEGIN');
  l('         l_tryupd:=FALSE;');
  l('         UPDATE HZ_SHADOW_ST_CPTS SET ');
  FOR I IN 1..255 LOOP
    IF l_forall_list(I) <> 'N' THEN
   	IF (is_first) THEN
	      is_first := false;
	      l('            TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	ELSE
	      l('            ,TX'||I||'=decode(H_TX'||I||'(1),null,H_TX'||I||'(1),H_TX'||I||'(1)||'' '')');
	END IF;
    END IF;
  END LOOP;
  l('         ,STATUS_FLAG = H_STATUS(1) ');-- Bug No: 4299785
  l('         WHERE CONTACT_POINT_ID=H_CONTACT_POINT_ID(1);');
  l('         IF SQL%ROWCOUNT=0 AND p_operation=''U'' THEN');
  l('           l_tryins := TRUE;');
  l('         END IF;');
  l('       EXCEPTION ');
  l('         WHEN NO_DATA_FOUND THEN');
  l('           IF p_operation=''U'' THEN');
  l('             l_tryins := TRUE;');
  l('           END IF;');
  l('       END;');
  l('     END IF;');
  l('   END LOOP;');
  l('   UPDATE HZ_SHADOW_ST_PARTIES set');
  l('   D_CPT = ''SYNC''');
  l('   WHERE PARTY_ID = H_PARTY_ID(1);');
  l('  END;');
END;



PROCEDURE create_btree_indexes (p_entity VARCHAR2)
 IS
  l_index_owner VARCHAR2(255);

  CURSOR indexes_reqd IS
    SELECT decode(a.entity_name,'PARTY','HZ_SHADOW_ST_PARTIES',
                  'PARTY_SITES','HZ_SHADOW_ST_PSITES','CONTACTS','HZ_SHADOW_ST_CONTACTS',
                  'CONTACT_POINTS','HZ_SHADOW_ST_CPTS')||'_N0'||substrb(staged_attribute_column,3) index_name,
           decode(a.entity_name,'PARTY','HZ_SHADOW_ST_PARTIES',
                  'PARTY_SITES','HZ_SHADOW_ST_PSITES','CONTACTS','HZ_SHADOW_ST_CONTACTS',
                  'CONTACT_POINTS','HZ_SHADOW_ST_CPTS') table_name,
           decode(a.entity_name,'PARTY','HZ_SRCH_PARTIES',
                  'PARTY_SITES','HZ_SRCH_PSITES','CONTACTS','HZ_SRCH_CONTACTS',
                  'CONTACT_POINTS','HZ_SRCH_CPTS')||'_N0'||substrb(staged_attribute_column,3) srch_index_name,
           decode(a.entity_name,'PARTY','HZ_SRCH_PARTIES',
                  'PARTY_SITES','HZ_SRCH_PSITES','CONTACTS','HZ_SRCH_CONTACTS',
                  'CONTACT_POINTS','HZ_SRCH_CPTS') srch_table_name,
           f.staged_attribute_column column_name
   FROM hz_trans_attributes_vl a, hz_trans_functions_vl f
   WHERE f.attribute_id = a.attribute_id
   AND f.index_required_flag = 'Y'
   AND a.entity_name = p_entity;

 CURSOR check_index(cp_index_name VARCHAR2,cp_table_name VARCHAR2) IS
   SELECT 1 FROM sys.all_indexes
   WHERE INDEX_NAME=cp_index_name
   AND TABLE_NAME=cp_table_name and owner = l_index_owner;

 l_index_name VARCHAR2(255);
 l_table_name VARCHAR2(255);
 l_srch_index_name VARCHAR2(255);
 l_srch_table_name VARCHAR2(255);
 l_column_name VARCHAR2(255);

 ar_index_tbsp VARCHAR2(255);
 l_storage_params VARCHAR2(2000);
 tmp NUMBER;

l_status VARCHAR2(255);
l_temp VARCHAR2(255);

l_bool BOOLEAN;

BEGIN

  l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_index_owner);

  select index_tablespace
  into ar_index_tbsp
  from fnd_product_installations
  where application_id = '222';

  l_storage_params := 'LOGGING STORAGE (INITIAL 4K NEXT 1M MINEXTENTS 1 '||
                      'MAXEXTENTS unlimited PCTINCREASE 0 FREELIST GROUPS 4 '||
                      'FREELISTS 4) PCTFREE 10 INITRANS 4 MAXTRANS 255 '||
                      'COMPUTE STATISTICS TABLESPACE '||ar_index_tbsp;

  OPEN indexes_reqd;
  LOOP
    FETCH indexes_reqd INTO l_index_name, l_table_name,l_srch_index_name, l_srch_table_name, l_column_name;
    EXIT WHEN indexes_reqd%NOTFOUND;

    OPEN check_index(l_index_name,l_table_name);
    FETCH check_index INTO tmp;
    IF check_index%NOTFOUND THEN
      EXECUTE IMMEDIATE 'CREATE INDEX '||l_index_owner||'.'||l_index_name||' ON '||l_table_name||'('||l_column_name||') '||
                        l_storage_params||' LOCAL '; -- for shadow create local indexes
    END IF;
    CLOSE check_index;

    OPEN check_index(l_srch_index_name,l_srch_table_name);
    FETCH check_index INTO tmp;
    IF check_index%NOTFOUND THEN
      EXECUTE IMMEDIATE 'CREATE INDEX '||l_index_owner||'.'||l_srch_index_name||' ON '||l_srch_table_name||'('||l_column_name||') '||
                        l_storage_params;
    END IF;
    CLOSE check_index;
  END LOOP;
  CLOSE indexes_reqd;
END;

FUNCTION has_trx_context(proc VARCHAR2) RETURN BOOLEAN IS

  l_sql VARCHAR2(255);
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  c NUMBER;
  n NUMBER;
  l_custom BOOLEAN;

BEGIN
  c := dbms_sql.open_cursor;
  l_sql := 'select ' || proc ||
           '(:attrval,:lang,:attr,:entity,:ctx) from dual';
  dbms_sql.parse(c,l_sql,2);
  DBMS_SQL.BIND_VARIABLE(c,':attrval','x');
  DBMS_SQL.BIND_VARIABLE(c,':lang','x');
  DBMS_SQL.BIND_VARIABLE(c,':attr','x');
  DBMS_SQL.BIND_VARIABLE(c,':entity','x');
  DBMS_SQL.BIND_VARIABLE(c,':ctx','x');
  n:=DBMS_SQL.execute(c);
  dbms_sql.close_cursor(c);
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RETURN FALSE;
END;

FUNCTION has_context(proc VARCHAR2) RETURN BOOLEAN IS

  l_sql VARCHAR2(255);
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  c NUMBER;
  n NUMBER;
  l_custom BOOLEAN;

BEGIN
  c := dbms_sql.open_cursor;
  l_sql := 'select ' || proc ||
           '(:record_id,:entity,:attr,:ctx) from dual';
  dbms_sql.parse(c,l_sql,2);
  DBMS_SQL.BIND_VARIABLE(c,':record_id','x');
  DBMS_SQL.BIND_VARIABLE(c,':entity','x');
  DBMS_SQL.BIND_VARIABLE(c,':attr','x');
  DBMS_SQL.BIND_VARIABLE(c,':ctx','x');
  n:=DBMS_SQL.execute(c);
  dbms_sql.close_cursor(c);
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RETURN FALSE;
END;


PROCEDURE verify_all_procs IS

  l_sql VARCHAR2(255);
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  l_trans_name VARCHAR2(255);
  c NUMBER;
  l_custom BOOLEAN;
BEGIN
  log('---------------------------------------------------');
  log('Calling verify_all_procs');
  FOR FUNCS IN (SELECT PROCEDURE_NAME, a.ENTITY_NAME, a.ATTRIBUTE_NAME, f.TRANSFORMATION_NAME
                FROM HZ_TRANS_FUNCTIONS_VL f, HZ_TRANS_ATTRIBUTES_VL a
                WHERE a.ATTRIBUTE_ID = f.ATTRIBUTE_ID
                AND nvl(f.ACTIVE_FLAG,'Y') = 'Y' )
    LOOP
        BEGIN
             l_custom := FALSE;
             l_entity := FUNCS.ENTITY_NAME;
             l_attribute := FUNCS.ATTRIBUTE_NAME;
             l_procedure := FUNCS.PROCEDURE_NAME;
             l_trans_name := FUNCS.TRANSFORMATION_NAME;
             c := dbms_sql.open_cursor;
             l_sql := 'select ' || FUNCS.PROCEDURE_NAME ||
               '(:attrval,:lang,:attr,:entity) from dual';
             dbms_sql.parse(c,l_sql,2);
             dbms_sql.close_cursor(c);
          EXCEPTION WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('AR', 'HZ_TRANS_PROC_ERROR1');
               FND_MESSAGE.SET_TOKEN('PROC' ,l_procedure);
               FND_MESSAGE.SET_TOKEN('ENTITY' ,l_entity);
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attribute);
               FND_MESSAGE.SET_TOKEN('TRANS' ,l_trans_name);
               FND_MSG_PUB.ADD;
          END;
    END LOOP;
   FOR FUNCS IN (SELECT custom_attribute_procedure, ENTITY_NAME, ATTRIBUTE_NAME
                 FROM HZ_TRANS_ATTRIBUTES_VL a
                 WHERE source_table = 'CUSTOM' OR
                 custom_attribute_procedure is NOT NULL
                 AND EXISTS (select 1 from HZ_TRANS_FUNCTIONS_VL f
                             WHERE f.attribute_id = a.attribute_id
                             AND nvl(f.ACTIVE_FLAG,'Y') = 'Y'))
     LOOP
         BEGIN
              l_custom := TRUE;
              l_entity := FUNCS.ENTITY_NAME;
              l_attribute := FUNCS.ATTRIBUTE_NAME;
              l_procedure := FUNCS.custom_attribute_procedure;
              c := dbms_sql.open_cursor;
              l_sql := 'select ' || FUNCS.custom_attribute_procedure ||
               '(:record_id,:entity,:attr) from dual';
              dbms_sql.parse(c,l_sql,2);
              dbms_sql.close_cursor(c);
          EXCEPTION WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('AR', 'HZ_CUSTOM_PROC_ERROR1');
               FND_MESSAGE.SET_TOKEN('PROC' ,l_procedure);
               FND_MESSAGE.SET_TOKEN('ENTITY' ,l_entity);
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attribute);
               FND_MSG_PUB.ADD;
          END;
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RAISE FND_API.G_EXC_ERROR;
END ;



/**
* Procedure to write a message to the out file
**/
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

/**
* Procedure to write a message to the log file
**/
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

/**
* Procedure to write a message to the out and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

FUNCTION wait_for_request(
    p_request_id NUMBER) RETURN VARCHAR2 IS

uphase VARCHAR2(255);
dphase VARCHAR2(255);
ustatus VARCHAR2(255);
dstatus VARCHAR2(255);
message VARCHAR2(32000);

l_bool BOOLEAN;

BEGIN
  l_bool := FND_CONCURRENT.wait_for_request(p_request_id,
             60, 144000, uphase, ustatus, dphase, dstatus, message);

  IF dphase <> 'COMPLETE' and dstatus <> 'NORMAL' THEN
    return 'ERROR';
  ELSE
    return 'SUCCESS';
  END IF;
END wait_for_request;

BEGIN
    g_schema_name := hz_utility_v2pub.get_appsschemaname;

END HZ_PARTY_STAGE_SHADOW;

/
