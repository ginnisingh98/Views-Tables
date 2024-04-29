--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_RELATIONSHIPS_PKG" AS
/*$Header: ARHLRELB.pls 120.36 2006/02/04 01:21:07 achung noship $*/

  g_debug_count             		NUMBER := 0;
  --g_debug                   		BOOLEAN := FALSE;

  l_action_mismatch_errors		FLAG_ERROR;
  l_flex_val_errors			NUMBER_COLUMN;
  l_dss_security_errors			FLAG_COLUMN;

  l_row_id ROWID;
  l_relationship_id RELATIONSHIP_ID;
  l_subject_id PARTY_ID;
  l_object_id PARTY_ID;
  l_relationship_type RELATIONSHIP_TYPE;

  l_comments COMMENTS;
  l_attr_category ATTRIBUTE_CATEGORY;
  l_attr1 ATTRIBUTE;
  l_attr2 ATTRIBUTE;
  l_attr3 ATTRIBUTE;
  l_attr4 ATTRIBUTE;
  l_attr5 ATTRIBUTE;
  l_attr6 ATTRIBUTE;
  l_attr7 ATTRIBUTE;
  l_attr8 ATTRIBUTE;
  l_attr9 ATTRIBUTE;
  l_attr10 ATTRIBUTE;
  l_attr11 ATTRIBUTE;
  l_attr12 ATTRIBUTE;
  l_attr13 ATTRIBUTE;
  l_attr14 ATTRIBUTE;
  l_attr15 ATTRIBUTE;
  l_attr16 ATTRIBUTE;
  l_attr17 ATTRIBUTE;
  l_attr18 ATTRIBUTE;
  l_attr19 ATTRIBUTE;
  l_attr20 ATTRIBUTE;
  l_exception_exists FLAG_ERROR;

  l_errm varchar2(100);

  /* Keep track of rows that do not get inserted or updated successfully.
     Those are the rows that have some validation or DML errors.
     Use this when inserting into or updating other tables so that we
     do not need to check all the validation arrays. */
  l_num_row_processed NUMBER_COLUMN;

  l_no_end_date DATE;
  l_actual_content_source varchar2(100);

  TYPE CREATED_BY_MODULE          IS TABLE OF HZ_IMP_RELSHIPS_INT.CREATED_BY_MODULE%TYPE;
  TYPE LOOKUP_ERROR               IS TABLE OF ar_lookups.lookup_code%TYPE;

  l_created_by_module             CREATED_BY_MODULE;
  l_createdby_errors              LOOKUP_ERROR;




  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
       fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;

  PROCEDURE disable_debug IS
    BEGIN

      IF g_debug THEN
        g_debug_count := g_debug_count - 1;
             IF g_debug_count = 0 THEN
               hz_utility_v2pub.disable_debug;
               g_debug := FALSE;
            END IF;
      END IF;

   END disable_debug;
   */


/* Validate desc flexfield HZ_RELATIONSHIPS. Used only when updating
   parties. If invalid, set l_flex_val_errors(i) to 1. Else do nothing. */
PROCEDURE validate_desc_flexfield(
  p_validation_date IN DATE
) IS
  l_flex_exists  VARCHAR2(1);

BEGIN

  FOR i IN 1..l_relationship_id.count LOOP

    FND_FLEX_DESCVAL.set_context_value(l_attr_category(i));

    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1', l_attr1(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2', l_attr2(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3', l_attr3(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4', l_attr4(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5', l_attr5(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6', l_attr6(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7', l_attr7(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8', l_attr8(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9', l_attr9(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10', l_attr10(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11', l_attr11(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12', l_attr12(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13', l_attr13(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14', l_attr14(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15', l_attr15(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16', l_attr16(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17', l_attr17(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18', l_attr18(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19', l_attr19(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20', l_attr20(i));

    IF (NOT FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_RELATIONSHIPS',
      'V',
      p_validation_date)) THEN
      l_flex_val_errors(i) := 1;
    END IF;

  END LOOP;

END validate_desc_flexfield;


/* Validate desc flexfield HZ_RELATIONSHIPS. Used only when inserting
   new parties because need to have a function to be called in MTI.
   Returns Y if flexfield is valid. Returns null if invalid. */
FUNCTION validate_desc_flexfield_f(
  p_attr_category  IN VARCHAR2,
  p_attr1          IN VARCHAR2,
  p_attr2          IN VARCHAR2,
  p_attr3          IN VARCHAR2,
  p_attr4          IN VARCHAR2,
  p_attr5          IN VARCHAR2,
  p_attr6          IN VARCHAR2,
  p_attr7          IN VARCHAR2,
  p_attr8          IN VARCHAR2,
  p_attr9          IN VARCHAR2,
  p_attr10         IN VARCHAR2,
  p_attr11         IN VARCHAR2,
  p_attr12         IN VARCHAR2,
  p_attr13         IN VARCHAR2,
  p_attr14         IN VARCHAR2,
  p_attr15         IN VARCHAR2,
  p_attr16         IN VARCHAR2,
  p_attr17         IN VARCHAR2,
  p_attr18         IN VARCHAR2,
  p_attr19         IN VARCHAR2,
  p_attr20         IN VARCHAR2,
  p_validation_date IN DATE
) RETURN VARCHAR2 IS
BEGIN

  FND_FLEX_DESCVAL.set_context_value(p_attr_category);

  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1', p_attr1);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2', p_attr2);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3', p_attr3);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4', p_attr4);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5', p_attr5);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6', p_attr6);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7', p_attr7);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8', p_attr8);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9', p_attr9);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10', p_attr10);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11', p_attr11);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12', p_attr12);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13', p_attr13);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14', p_attr14);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15', p_attr15);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16', p_attr16);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17', p_attr17);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18', p_attr18);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19', p_attr19);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20', p_attr20);

  IF (FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_RELATIONSHIPS',
      'V',
      p_validation_date)) THEN
    return 'Y';
  ELSE
    return null;
  END IF;

END validate_desc_flexfield_f;


PROCEDURE validate_DSS_security IS
  dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  dss_msg_count     NUMBER := 0;
  dss_msg_data      VARCHAR2(2000):= null;
  l_debug_prefix    VARCHAR2(30) := '';

BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:validate_DSS_security()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  /* Check if the DSS security is granted to the user.
     Only check for update. */
  FOR i IN 1..l_relationship_id.count LOOP
    l_dss_security_errors(i) :=
    		hz_dss_util_pub.test_instance(
                p_operation_code     => 'UPDATE',
                p_db_object_name     => 'HZ_RELATIONSHIPS',
                p_instance_pk1_value => l_relationship_id(i),
                p_instance_pk2_value => 'F',
                p_user_name          => fnd_global.user_name,
                x_return_status      => dss_return_status,
                x_msg_count          => dss_msg_count,
                x_msg_data           => dss_msg_data);

  END LOOP;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:validate_DSS_security()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END validate_DSS_security;


/* Only used when updating parties */
PROCEDURE report_errors(
  P_DML_RECORD    IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
  P_ACTION        IN      VARCHAR2,
  P_DML_EXCEPTION IN	  VARCHAR2
) IS
  num_exp NUMBER;
  exp_ind NUMBER := 1;
  l_debug_prefix    VARCHAR2(30) := '';
  l_exception_exists FLAG_ERROR;
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  /**********************************/
  /* Validation and Error reporting */
  /**********************************/
  IF l_relationship_id.count = 0 THEN
    return;
  END IF;

  l_num_row_processed := null;
  l_num_row_processed := NUMBER_COLUMN();
  l_num_row_processed.extend(l_relationship_id.count);
  l_exception_exists := null;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_relationship_id.count);
  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  FOR k IN 1..l_relationship_id.count LOOP

    IF SQL%BULK_ROWCOUNT(k) = 0 THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'DML fails at ' || k,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      l_num_row_processed(k) := 0;

      /* Check for any exceptions during DML */
      IF P_DML_EXCEPTION = 'Y' THEN
        /* determine if exception at this index */
        FOR i IN exp_ind..num_exp LOOP
          IF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = k THEN
            l_exception_exists(k) := 'Y';
          ELSIF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX > k THEN
            EXIT;
          END IF;
        END LOOP;
      END IF; /* P_DML_EXCEPTION = 'Y' */

    ELSE
      l_num_row_processed(k) := 1;
    END IF; /* SQL%BULK_ROWCOUNT(k) = 0 */
  END LOOP;

  /* insert into tmp error tables */
  forall j in 1..l_relationship_id.count
    insert into hz_imp_tmp_errors
    (
       request_id,
       batch_id,
       int_row_id,
       interface_table_name,
       error_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       e1_flag,e2_flag,e3_flag,
       e9_flag,e10_flag,
       e11_flag,
       action_mismatch_flag,
       OTHER_EXCEP_FLAG
    )
    (
      select P_DML_RECORD.REQUEST_ID,
             P_DML_RECORD.BATCH_ID,
             l_row_id(j),
             'HZ_IMP_FINREPORTS_INT',
             HZ_IMP_ERRORS_S.NextVal,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.LAST_UPDATE_LOGIN,
             P_DML_RECORD.PROGRAM_APPLICATION_ID,
             P_DML_RECORD.PROGRAM_ID,
             P_DML_RECORD.SYSDATE,
             nvl2(l_subject_id(j), 'Y', null),    --HZ_IMP_REL_SUBJ_OBJ_ERROR,SUB_OR_OBJ,SUBJECT
             nvl2(l_object_id(j), 'Y', null),     --HZ_IMP_REL_SUBJ_OBJ_ERROR,SUB_OR_OBJ,OBJECT
             decode(l_subject_id(j), null, 'Y',
               decode(l_object_id(j), null, 'Y', nvl2(l_relationship_type(j), 'Y', null))), --HZ_IMP_REL_TYPE_ERROR
             decode(l_flex_val_errors(j), 1, null, 'Y'), --AR_RAPI_DESC_FLEX_INVALID,DFF_NAME,HZ_RELATIONSHIPS
             decode(l_dss_security_errors(j), FND_API.G_TRUE,'Y',null), --HZ_DSS_SECURITY_FAIL,USER_NAME,FND_GLOBAL.user_name,OPER_NAME,UPDATE,OBJECT_NAME,HZ_RELATIONSHIPS
             'Y',
             nvl2(l_action_mismatch_errors(j), 'Y', null),     --HZ_IMP_ACTION_MISMATCH
             l_exception_exists(j)
        from dual
       where l_num_row_processed(j) = 0
    );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:report_errors()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END report_errors;


/* Populate error table when exception happens during updating or
   inserting parties. */
PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		 VARCHAR2(30) := '';
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

     /* other entities need to add checking for other constraints */
     if (P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       dup_val_exp_val := 'A';
     end if;

     insert into hz_imp_tmp_errors
     (
       request_id,
       batch_id,
       int_row_id,
       interface_table_name,
       error_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       e1_flag,
       e2_flag,
       e3_flag,
       e4_flag,
       e5_flag,
       e6_flag,
       e7_flag,
       e8_flag,
       e9_flag,
       e10_flag,
       e11_flag,
       ACTION_MISMATCH_FLAG,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              rel_sg.int_row_id,
              'HZ_IMP_RELSHIPS_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              'Y','Y',
              dup_val_exp_val,
              other_exp_val
         from hz_imp_relships_sg rel_sg, hz_imp_relships_int rel_int
        where rel_sg.action_flag = 'I'
          and rel_int.rowid = rel_sg.int_row_id
          and rel_sg.batch_id = P_DML_RECORD.BATCH_ID
          and rel_sg.sub_orig_system = P_DML_RECORD.OS
          and rel_sg.sub_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END populate_error_table;


/********************************************************************************
 *
 *	process_insert_rels
 *
 ********************************************************************************/

PROCEDURE process_insert_rels (
  P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  l_insert_sql1 varchar2(32767) :=
'BEGIN insert all
  when (sub_id is not null
       and obj_id is not null
       and relationship_type is not null
       and rel_code_error is not null
       and start_end_date_error is not null
       and hierarchical_flag_error is not null
       and action_mismatch_error is not null
       and relate_self_error is not null
       and createdby_error is not null
       and dup_rel_error is not null
       and flex_val_error is not null) then
  into hz_parties ( /* insert relationship party if no validation error */
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       party_id,
       party_number,
       party_name,
       party_type,
       created_by_module,
       orig_system_reference,
       status,
       object_version_number,
       validated_flag,
       application_id)
values (
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       :request_id,
       hz_parties_s.nextval,
       hz_party_number_s.nextval,
       party_name,
       ''PARTY_RELATIONSHIP'',
       created_by_module,
       hz_parties_s.nextval,
       ''A'',
       1,
       ''N'',
       :application_id)
  into hz_relationships ( /* insert forward relationship */
       actual_content_source,
       application_id,
       content_source_type,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       relationship_id,
       subject_id,
       subject_type,
       subject_table_name,
       object_id,
       object_type,
       object_table_name,
       party_id,
       relationship_code,
       directional_flag,
       comments,
       start_date,
       end_date,
       status,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       relationship_type,
       object_version_number,
       created_by_module,
       direction_code)
values (
       :actual_content_src,
       :application_id,
       ''USER_ENTERED'',
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       :request_id,
       relationship_id,
       sub_id,
       sp_type,
       ''HZ_PARTIES'',
       obj_id,
       op_type,
       ''HZ_PARTIES'',
       hz_parties_s.nextval,
       forward_rel_code,
       ''F'',
       comments,
       start_date,
       end_date,
       ''A'',
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       relationship_type,
       1,  -- OBJECT_VERSION_NUMBER,
       created_by_module,
       direction_code)
  into hz_relationships ( /* insert backward relationship */
       actual_content_source,
       application_id,
       content_source_type,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       relationship_id,
       subject_id,
       subject_type,
       subject_table_name,
       object_id,
       object_type,
       object_table_name,
       party_id,
       relationship_code,
       directional_flag,
       comments,
       start_date,
       end_date,
       status,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       relationship_type,
       object_version_number,
       created_by_module,
       direction_code)
values (
       :actual_content_src,
       :application_id,
       ''USER_ENTERED'',
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       :request_id,
       relationship_id,
       obj_id,
       op_type,
       ''HZ_PARTIES'',
       sub_id,
       sp_type,
       ''HZ_PARTIES'',
       hz_parties_s.nextval,
       backward_rel_code,
       ''B'',
       comments,
       start_date,
       end_date,
       ''A'',
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       relationship_type,
       1,  -- OBJECT_VERSION_NUMBER,
       created_by_module,
       decode(direction_code, ''P'', ''C'', ''C'', ''P'', ''N''))
  when (sub_id is not null
       and obj_id is not null
       and relationship_type is not null
       and rel_code_error is not null
       and start_end_date_error is not null
       and hierarchical_flag_error is not null
       and action_mismatch_error is not null
       and relate_self_error is not null
       and dup_rel_error is not null
       and flex_val_error is not null
       -- Bug 4455041. To create a row in HZ_ORG_CONTACTS for all relationships
       and sp_type in  (''PERSON'',''ORGANIZATION'',''GROUP'')
       and op_type in  (''PERSON'',''ORGANIZATION'',''GROUP'')
       ) then
  into hz_org_contacts ( /* insert org contact if at least one party is person */
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       org_contact_id,
       party_relationship_id,
       contact_number,
       orig_system_reference,
       status,
       object_version_number,
       created_by_module)
values (
       :application_id,
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       :request_id,
       hz_org_contacts_s.nextval,
       relationship_id,
       hz_contact_numbers_s.nextval,
       hz_org_contacts_s.nextval,
       ''A'',
       1,
       ''HZ_IMPORT'')
  when (sub_id is not null
       and obj_id is not null
       and relationship_type is not null
       and rel_code_error is not null
       and start_end_date_error is not null
       and hierarchical_flag_error is not null
       and action_mismatch_error is not null
       and relate_self_error is not null
       and dup_rel_error is not null
       and flex_val_error is not null
       and ((sp_type=''PERSON'' and op_type=''ORGANIZATION'')
           or (op_type=''PERSON'' and sp_type=''ORGANIZATION''))
       ) then
  into hz_party_usg_assignments (
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       request_id,
       party_usg_assignment_id,
       party_id,
       party_usage_code,
       owner_table_name,
       owner_table_id,
       effective_start_date,
       effective_end_date,
       status_flag,
       created_by_module,
       object_version_number)
values (
       :application_id,
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :request_id,
       hz_party_usg_assignments_s.nextval,
       decode(sp_type,''PERSON'',sub_id,obj_id),
       ''ORG_CONTACT'',
       ''HZ_RELATIONSHIPS'',
       relationship_id,
       start_date,
       end_date,
       ''A'',
       created_by_module,
       1)
  when (sub_id is not null
       and obj_id is not null
       and relationship_type is not null
       and rel_code_error is not null
       and start_end_date_error is not null
       and hierarchical_flag_error is not null
       and action_mismatch_error is not null
       and relate_self_error is not null
       and dup_rel_error is not null
       and flex_val_error is not null
       and sp_type=''PERSON''
       and op_type=''PERSON''
       ) then
  into hz_party_usg_assignments (
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       request_id,
       party_usg_assignment_id,
       party_id,
       party_usage_code,
       owner_table_name,
       owner_table_id,
       effective_start_date,
       effective_end_date,
       status_flag,
       created_by_module,
       object_version_number)
values (
       :application_id,
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :request_id,
       hz_party_usg_assignments_s.nextval,
       sub_id,
       ''RELATED_PERSON'',
       ''HZ_RELATIONSHIPS'',
       relationship_id,
       start_date,
       end_date,
       ''A'',
       created_by_module,
       1)
  into hz_party_usg_assignments (
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       request_id,
       party_usg_assignment_id,
       party_id,
       party_usage_code,
       owner_table_name,
       owner_table_id,
       effective_start_date,
       effective_end_date,
       status_flag,
       created_by_module,
       object_version_number)
values (
       :application_id,
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :request_id,
       hz_party_usg_assignments_s.nextval+1,
       obj_id,
       ''RELATED_PERSON'',
       ''HZ_RELATIONSHIPS'',
       relationship_id,
       start_date,
       end_date,
       ''A'',
       created_by_module,
       1)
  else
  into hz_imp_tmp_errors ( /* insert into tmp errors for any validation error */
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       error_id,
       batch_id,
       request_id,
       int_row_id,
       interface_table_name,
       e1_flag,
       e2_flag,
       e3_flag,
       e4_flag,
       e5_flag,
       e6_flag,
       e7_flag,
       e8_flag,
       e9_flag,
       e10_flag,
       e11_flag,
       action_mismatch_flag)
values (
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       HZ_IMP_ERRORS_S.NextVal,
       :p_batch_id,
       :request_id,
       row_id,
       ''HZ_IMP_RELSHIPS_INT'',
       nvl2(sub_pid, ''Y'', null),
       nvl2(obj_pid, ''Y'', null),
       decode(sub_pid, null, ''Y'',
         decode(obj_pid, null, ''Y'', nvl2(relationship_type, ''Y'', nvl2(rel_code_error, null, ''Y'')))),
       rel_code_error,
       start_end_date_error,
       nvl2(relationship_type, hierarchical_flag_error, ''Y''),
       relate_self_error,
       dup_rel_error,
       flex_val_error,
       ''Y'',
       createdby_error,
       action_mismatch_error)
select /*+ index(rt, hz_relationship_types_n3) use_nl(rt, party_rel_type_l) */
       rs.row_id,
       rs.sub_pid,
       rs.obj_pid,
       rs.relationship_id,
       rt.direction_code,
       rt.backward_rel_code,
       rs.sub_id,
       rs.sp_type,
       rs.party_name,
       rs.obj_id,
       rs.op_type,
       rt.relationship_type,
       rt.forward_rel_code,
       rs.start_date,
       rs.end_date,
       rs.attribute_category,
       rs.attribute1,
       rs.attribute2,
       rs.attribute3,
       rs.attribute4,
       rs.attribute5,
       rs.attribute6,
       rs.attribute7,
       rs.attribute8,
       rs.attribute9,
       rs.attribute10,
       rs.attribute11,
       rs.attribute12,
       rs.attribute13,
       rs.attribute14,
       rs.attribute15,
       rs.attribute16,
       rs.attribute17,
       rs.attribute18,
       rs.attribute19,
       rs.attribute20,
       rs.interface_status,
       rs.comments,
       rs.created_by_module,
       nvl2(createdby_l.lookup_code,''Y'',null) createdby_error,
       rs.start_end_date_error,
       rs.action_mismatch_error,
       nvl2(party_rel_type_l.lookup_code, ''Y'', null) rel_code_error,
       decode(rt.hierarchical_flag, ''N'', decode (rt.allow_circular_relationships, ''Y'',
''Y'', null), null) hierarchical_flag_error,
       decode(:l_val_flex, ''Y'',
         HZ_IMP_LOAD_RELATIONSHIPS_PKG.validate_desc_flexfield_f(
         rs.attribute_category, rs.attribute1, rs.attribute2, rs.attribute3,
rs.attribute4,
         rs.attribute5, rs.attribute6, rs.attribute7, rs.attribute8, rs.attribute9,
         rs.attribute10, rs.attribute11, rs.attribute12, rs.attribute13,
rs.attribute14,
         rs.attribute15, rs.attribute16, rs.attribute17, rs.attribute18,
rs.attribute19,
         rs.attribute20, :l_sysdate
         ), ''T'') flex_val_error,
       decode(rs.obj_id, rs.sub_id, decode(rt.allow_relate_to_self_flag, ''N'', null,
''Y''), ''Y'') relate_self_error,
       dup_rel_error,
       dup_rel_count
  from hz_relationship_types rt,
       fnd_lookup_values party_rel_type_l,
       fnd_lookup_values createdby_l,
       (
select /*+ ordered index(sp, HZ_PARTIES_U1) index(op, HZ_PARTIES_U1) */ ri.rowid row_id,
       sp.party_id sub_pid,
       op.party_id obj_pid,
       irs.relationship_id,
       ri.relationship_code,
       irs.sub_id,
       sp.party_type sp_type,
       substrb(sp.party_name || ''-'' || op.party_name, 1, 360) party_name,
       irs.obj_id,
       op.party_type op_type,
       ri.relationship_type,
       nvl(nullif(ri.start_date, :p_gmiss_date), :l_sysdate) start_date,
       nvl(nullif(ri.end_date, :p_gmiss_date), :l_no_end_date) end_date,
       nullif(ri.attribute_category, :p_gmiss_char) attribute_category,
       nullif(ri.attribute1, :p_gmiss_char) attribute1,
       nullif(ri.attribute2, :p_gmiss_char) attribute2,
       nullif(ri.attribute3, :p_gmiss_char) attribute3,
       nullif(ri.attribute4, :p_gmiss_char) attribute4,
       nullif(ri.attribute5, :p_gmiss_char) attribute5,
       nullif(ri.attribute6, :p_gmiss_char) attribute6,
       nullif(ri.attribute7, :p_gmiss_char) attribute7,
       nullif(ri.attribute8, :p_gmiss_char) attribute8,
       nullif(ri.attribute9, :p_gmiss_char) attribute9,
       nullif(ri.attribute10, :p_gmiss_char) attribute10,
       nullif(ri.attribute11, :p_gmiss_char) attribute11,
       nullif(ri.attribute12, :p_gmiss_char) attribute12,
       nullif(ri.attribute13, :p_gmiss_char) attribute13,
       nullif(ri.attribute14, :p_gmiss_char) attribute14,
       nullif(ri.attribute15, :p_gmiss_char) attribute15,
       nullif(ri.attribute16, :p_gmiss_char) attribute16,
       nullif(ri.attribute17, :p_gmiss_char) attribute17,
       nullif(ri.attribute18, :p_gmiss_char) attribute18,
       nullif(ri.attribute19, :p_gmiss_char) attribute19,
       nullif(ri.attribute20, :p_gmiss_char) attribute20,
       nullif(ri.interface_status, :p_gmiss_char) interface_status,
       nullif(ri.comments, :p_gmiss_char) comments,
       nvl(nullif(ri.created_by_module, :p_gmiss_char), ''HZ_IMPORT'') created_by_module,
       decode(ri.end_date, null, ''Y'', decode(sign(ri.end_date - ri.start_date), -1,
null, ''Y'')) start_end_date_error,
       nvl2(nullif(nullif(ri.insert_update_flag, :p_gmiss_char), irs.action_flag),
null, ''Y'') action_mismatch_error,
       decode(tc.a, 0, ''Y'') dup_rel_error,
       tc.a dup_rel_count
  from hz_imp_relships_sg irs,
       hz_imp_relships_int ri,
       (select 0 a from dual union all select 1 a from dual) tc,
       hz_parties sp,
       hz_parties op
 where irs.batch_mode_flag = :p_batch_mode_flag
   and irs.action_flag = ''I''
   and irs.sub_id = sp.party_id (+)
   and irs.obj_id = op.party_id (+)
   and ri.rowid = irs.int_row_id
   and irs.batch_id = :p_batch_id
   and irs.sub_orig_system = :p_os
   and irs.sub_orig_system_reference between :p_from_osr and :p_to_osr';

  l_insert_sql2 varchar2(4000) :=
       ' and tc.a = (select count(*)
	  from hz_relationships r1
	 where r1.subject_id = irs.sub_id
	   and r1.subject_table_name = ''HZ_PARTIES''
	   and r1.object_id = irs.obj_id
	   and r1.relationship_type = ri.relationship_type
	   and r1.relationship_code = ri.relationship_code
	   and nvl(ri.end_date, :l_no_end_date) >= nvl(r1.start_date, :l_sysdate)
	   and nvl(r1.end_date, :l_no_end_date) >= nvl(ri.start_date, :l_sysdate)
	   and r1.actual_content_source = :actual_content_src
	   and r1.status = ''A''
	   and rownum = 1)) rs
 where party_rel_type_l.lookup_code (+) = rs.relationship_code
   and party_rel_type_l.lookup_type (+) = ''PARTY_RELATIONS_TYPE''
   and party_rel_type_l.language (+) = userenv(''LANG'')
   and party_rel_type_l.view_application_id (+) = 222
   and party_rel_type_l.security_group_id (+) =
       fnd_global.lookup_security_group(''PARTY_RELATIONS_TYPE'', 222)
   and createdby_l.lookup_code (+) = rs.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and rs.relationship_type = rt.relationship_type (+)
   and rs.relationship_code = rt.forward_rel_code (+)
   and rs.sp_type = rt.subject_type (+)
   and rs.op_type = rt.object_type (+)';

  l_dnb_rel_sql varchar2(35) := ' and dup_rel_count = 0';

  l_where_first_run_sql varchar2(35) := ' AND ri.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND ri.interface_status = ''C''';

  l_where_enabled_lookup_sql varchar2(1000) :=
	' AND  ( party_rel_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( party_rel_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( party_rel_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
          AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:l_sysdate ) ) )';

  l_end_sql          VARCHAR2(10) := '; END;';
  l_dml_exception varchar2(1) := 'N';
  l_debug_prefix    VARCHAR2(30) := '';

BEGIN
  savepoint process_insert_rels_pvt;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:process_insert_rels()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_actual_content_source <> 'USER_ENTERED' THEN
    l_insert_sql2 := l_insert_sql2 || l_dnb_rel_sql;
  END IF;

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN

    IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN

      EXECUTE IMMEDIATE l_insert_sql1 || l_where_first_run_sql || l_insert_sql2 || l_end_sql
	using
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.application_id,
	p_dml_record.actual_content_src,

	p_dml_record.batch_id,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_date,
	l_no_end_date,
	p_dml_record.gmiss_char,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    ELSE /* Rerun to correct errors */

      EXECUTE IMMEDIATE l_insert_sql1 || l_where_rerun_sql || l_insert_sql2 || l_end_sql
	using
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.application_id,
	p_dml_record.actual_content_src,

	p_dml_record.batch_id,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_date,
	l_no_end_date,
	p_dml_record.gmiss_char,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    END IF;

  ELSE -- l_allow_disabled_lookup

    IF 	p_dml_record.RERUN = 'N' /*** First Run ***/ THEN

      EXECUTE IMMEDIATE l_insert_sql1 || l_where_first_run_sql || l_insert_sql2 || l_where_enabled_lookup_sql || l_end_sql
	using
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.application_id,
	p_dml_record.actual_content_src,

	p_dml_record.batch_id,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_date,
	l_no_end_date,
	p_dml_record.gmiss_char,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    ELSE /* Rerun to correct errors */

      EXECUTE IMMEDIATE l_insert_sql1 || l_where_rerun_sql || l_insert_sql2 || l_where_enabled_lookup_sql || l_end_sql
	using
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
    p_dml_record.request_id,
	p_dml_record.application_id,
	p_dml_record.actual_content_src,

	p_dml_record.batch_id,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_date,
	l_no_end_date,
	p_dml_record.gmiss_char,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;
    END IF;

  END IF;

  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'REL:Rows inserted in MTI = ' || SQL%ROWCOUNT,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  IF P_DML_RECORD.OS = 'DNB' THEN
    /* End date old DNB parents */

    UPDATE /*+ index(r, hz_relationships_u1) */ hz_relationships r
    SET end_date = decode(TRUNC(start_date), TRUNC(p_dml_record.sysdate),
    			 TRUNC(p_dml_record.sysdate),
    			 TRUNC(p_dml_record.sysdate-1)),
       status = 'I',
       last_update_date = p_dml_record.sysdate,
       last_updated_by = p_dml_record.user_id,
       last_update_login = p_dml_record.last_update_login,
       request_id = p_dml_record.request_id
    WHERE (relationship_id, directional_flag) in (
      SELECT t.relationship_id, t.directional_flag
        FROM   hz_imp_tmp_rel_end_date t
        WHERE int_row_id is not null
        and batch_id = p_dml_record.batch_id
        and sub_orig_system_reference between p_dml_record.from_osr and p_dml_record.to_osr
        and int_row_id not in (
            select /*+ hash_aj */ e.int_row_id
            from hz_imp_tmp_errors e
            where e.request_id = p_dml_record.request_id
              AND e.interface_table_name = 'HZ_IMP_RELATIONSHIPS_INT'
              and e.batch_id = p_dml_record.batch_id
        and e.int_row_id is not null));

  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:process_insert_rels()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert rels dup val exception: ' || SQLERRM);

        ROLLBACK to process_insert_rels_pvt;

        populate_error_table(P_DML_RECORD, 'Y', SQLERRM);

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert rels other exception: ' || SQLERRM);

        ROLLBACK to process_insert_rels_pvt;

        populate_error_table(P_DML_RECORD, 'N', SQLERRM);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END process_insert_rels;


/********************************************************************************
 *
 *	process_update_rels
 *
 ********************************************************************************/

PROCEDURE process_update_rels (
  P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_update RefCurType;

  /* Fewer validations than insert because many columns like subject, object,
     rel type, rel code etc are not updateable */
  l_update_sql varchar2(11000) :=
	'SELECT /*+ leading(rs) use_nl(ri) rowid(ri) */
        ri.ROWID,
	rs.relationship_id,
	rs.sub_id,
	rs.obj_id,
	ri.relationship_type,
	ri.COMMENTS,
	ri.ATTRIBUTE_CATEGORY,
	ri.ATTRIBUTE1,
	ri.ATTRIBUTE2,
	ri.ATTRIBUTE3,
	ri.ATTRIBUTE4,
	ri.ATTRIBUTE5,
	ri.ATTRIBUTE6,
	ri.ATTRIBUTE7,
	ri.ATTRIBUTE8,
	ri.ATTRIBUTE9,
	ri.ATTRIBUTE10,
	ri.ATTRIBUTE11,
	ri.ATTRIBUTE12,
	ri.ATTRIBUTE13,
	ri.ATTRIBUTE14,
	ri.ATTRIBUTE15,
	ri.ATTRIBUTE16,
	ri.ATTRIBUTE17,
	ri.ATTRIBUTE18,
	ri.ATTRIBUTE19,
	ri.ATTRIBUTE20,
	decode(nvl(ri.insert_update_flag, rs.action_flag), rs.action_flag, ''Y'', null) action_mismatch_error,
	0 flex_val_errors,
	''T'' dss_security_error
	FROM HZ_IMP_RELSHIPS_INT ri, HZ_IMP_RELSHIPS_SG rs,
	  HZ_RELATIONSHIPS r
	WHERE
	ri.rowid = rs.int_row_id
	AND rs.relationship_id = r.relationship_id
	AND r.directional_flag = ''F''
	AND rs.batch_id = :P_BATCH_ID
	AND rs.sub_orig_system = :P_OS
	AND rs.sub_orig_system_reference between :P_FROM_OSR and :P_TO_OSR
	AND rs.batch_mode_flag = :l_batch_mode_flag
	AND rs.ACTION_FLAG = ''U''';

  l_where_first_run_sql varchar2(40) := ' AND ri.interface_status is null';
  l_where_rerun_sql varchar2(40) := ' AND ri.interface_status = ''C''';
  l_dnb_rel varchar2(200) :=
    ' AND ri.relationship_type not in (''HEADQUARTERS/DIVISION'',''PARENT/SUBSIDIARY'',''DOMESTIC_ULTIMATE'',''GLOBAL_ULTIMATE'')';


  l_dml_exception varchar2(1) := 'N';
  l_debug_prefix    VARCHAR2(30) := '';
 BEGIN

  savepoint process_update_rels_pvt;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:process_update_rels()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN

      IF l_actual_content_source <> 'USER_ENTERED' THEN
        OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql || l_dnb_rel
        USING
        P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS,
        P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
      ELSE
        OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql
        USING
        P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS,
        P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
      END IF;
    ELSE /* Rerun to correct errors */
      IF l_actual_content_source <> 'USER_ENTERED' THEN
        OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql || l_dnb_rel
        USING
        P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS,
        P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
      ELSE
        OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql
        USING
        P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS,
        P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
      END IF;
    END IF;

  FETCH c_handle_update BULK COLLECT INTO
    l_row_id,
    l_relationship_id,
    l_subject_id,
    l_object_id,
    l_relationship_type,
    l_comments,
    l_attr_category,
    l_attr1,
    l_attr2,
    l_attr3,
    l_attr4,
    l_attr5,
    l_attr6,
    l_attr7,
    l_attr8,
    l_attr9,
    l_attr10,
    l_attr11,
    l_attr12,
    l_attr13,
    l_attr14,
    l_attr15,
    l_attr16,
    l_attr17,
    l_attr18,
    l_attr19,
    l_attr20,
    l_action_mismatch_errors,
    l_flex_val_errors,
    l_dss_security_errors;

  /* Do FND desc flex validation based on profile */
  IF P_DML_RECORD.FLEX_VALIDATION = 'Y' THEN
    validate_desc_flexfield(P_DML_RECORD.SYSDATE);
  END IF;

  /* Do DSS security validation based on profile */
  IF P_DML_RECORD.DSS_SECURITY = 'Y' THEN
    validate_DSS_security;
  END IF;

  /*************************************************/
  /*** Update HZ_RELATIONSHIPS (Both directions) ***/
  /*************************************************/


  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'REL:Update relationships',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  /*
    Reason for disallowing update to start_date and end_date:
    Let's say in TCA in hz_relationships, there are 2 records

    Subj ID    Obj ID    Rel Type    Rel Code    Start Date    End Date
    1          2         abc         xyz         01/01/01      01/20/01
    1          2         abc         xyz         02/01/01      02/20/01

    In Relationships Interface Table, there is 1 record as follows:
    Subj ID    Obj ID    Rel Type    Rel Code    Start Date    End Date
    1          2         abc         xyz         03/01/01      03/20/01

    There is no way to know if we should a new record or update one of the records.
    If Update, then which one?

    In the Matching phase, we should include both start and end dates
    (actual value, not range/ overlap) when checking for existence of records in TCA.
    In the above case, the record will be marked for Insert.

    In the DML phase, we anyways check for date overlap, so if a record were to be
    marked as Insert due to different dates, but if they were overlapping with those of
    an existing record in TCA, in DML phase, record will be marked for 'Error'.
  */

  BEGIN
    ForAll j in 1..l_relationship_id.count SAVE EXCEPTIONS
      update hz_relationships set
        /* Not allow update to start_date, end_date */
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_DATE = trunc(P_DML_RECORD.SYSDATE),
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        COMMENTS =
                   DECODE(l_comments(j),
                   	  NULL, comments,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_comments(j)),
        ATTRIBUTE_CATEGORY =
                   DECODE(l_attr_category(j),
                   	  NULL, attribute_category,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr_category(j)),
        ATTRIBUTE1 =
                   DECODE(l_attr1(j),
                   	  NULL, attribute1,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr1(j)),
        ATTRIBUTE2 =
                   DECODE(l_attr2(j),
                   	  NULL, attribute2,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr2(j)),
        ATTRIBUTE3 =
                   DECODE(l_attr3(j),
                   	  NULL, attribute3,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                    	  l_attr3(j)),
        ATTRIBUTE4 =
                   DECODE(l_attr4(j),
                   	  NULL, attribute4,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr4(j)),
        ATTRIBUTE5 =
                   DECODE(l_attr5(j),
                   	  NULL, attribute5,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr5(j)),
        ATTRIBUTE6 =
                   DECODE(l_attr6(j),
                   	  NULL, attribute6,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr6(j)),
        ATTRIBUTE7 =
                   DECODE(l_attr7(j),
                   	  NULL, attribute7,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr7(j)),
        ATTRIBUTE8 =
                   DECODE(l_attr8(j),
                   	  NULL, attribute8,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr8(j)),
        ATTRIBUTE9 =
                   DECODE(l_attr9(j),
                   	  NULL, attribute9,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr9(j)),
        ATTRIBUTE10 =
                   DECODE(l_attr10(j),
                   	  NULL, attribute10,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr10(j)),
        ATTRIBUTE11 =
                   DECODE(l_attr11(j),
                   	  NULL, attribute11,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr11(j)),
        ATTRIBUTE12 =
                   DECODE(l_attr12(j),
                   	  NULL, attribute12,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr12(j)),
        ATTRIBUTE13 =
                   DECODE(l_attr13(j),
                   	  NULL, attribute13,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr13(j)),
        ATTRIBUTE14 =
                   DECODE(l_attr14(j),
                   	  NULL, attribute14,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr14(j)),
        ATTRIBUTE15 =
                   DECODE(l_attr15(j),
                   	  NULL, attribute15,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr15(j)),
        ATTRIBUTE16 =
                   DECODE(l_attr16(j),
                   	  NULL, attribute16,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr16(j)),
        ATTRIBUTE17 =
                   DECODE(l_attr17(j),
                   	  NULL, attribute17,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr17(j)),
        ATTRIBUTE18 =
                   DECODE(l_attr18(j),
                   	  NULL, attribute18,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr18(j)),
        ATTRIBUTE19 =
                   DECODE(l_attr19(j),
                   	  NULL, attribute19,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr19(j)),
        ATTRIBUTE20 =
                   DECODE(l_attr20(j),
                   	  NULL, attribute20,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr20(j)),
        OBJECT_VERSION_NUMBER =
                   DECODE(OBJECT_VERSION_NUMBER,
                   	  NULL, 1,
                   	  OBJECT_VERSION_NUMBER+1)
      where
        relationship_id = l_relationship_id(j)
        and l_action_mismatch_errors(j) is not null
        and l_flex_val_errors(j) = 0
        and l_dss_security_errors(j) ='T'
        and actual_content_source = l_actual_content_source;

  EXCEPTION
    WHEN OTHERS THEN
      l_dml_exception := 'Y';

  END;

  report_errors(P_DML_RECORD, 'U', l_dml_exception);

  CLOSE c_handle_update;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:process_update_rels()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION

    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update rels other exception: ' || SQLERRM);

        ROLLBACK to process_update_rels_pvt;

        populate_error_table(P_DML_RECORD, 'N', SQLERRM);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END process_update_rels;


/********************************************************************************
 *
 *	load_relationships
 *
 ********************************************************************************/

PROCEDURE load_relationships (
  P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  l_return_status    VARCHAR2(30);
  l_msg_data         VARCHAR2(2000);
  l_msg_count        NUMBER;
  l_debug_prefix    VARCHAR2(30) := '';
BEGIN

  savepoint load_rels_pvt;
  FND_MSG_PUB.initialize;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:load_relationships()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_actual_content_source := P_DML_RECORD.ACTUAL_CONTENT_SRC;
  l_no_end_date := TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');

  process_insert_rels(
    P_DML_RECORD	=> P_DML_RECORD
    ,x_return_status    => x_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data
  );

  IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
    process_update_rels(
      P_DML_RECORD	  => P_DML_RECORD
      ,x_return_status    => x_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data
    );
  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'REL:load_relationships()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- if enabled, disable debug
  --disable_debug;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO load_rels_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO load_rels_pvt;
    FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading relationships');
    FND_FILE.put_line(fnd_file.log, l_errm);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,l_errm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO load_rels_pvt;
    FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading relationships');
    FND_FILE.put_line(fnd_file.log, l_errm);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);

END load_relationships;


END HZ_IMP_LOAD_RELATIONSHIPS_PKG;

/
