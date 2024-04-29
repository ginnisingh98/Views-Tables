--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_ORG_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_ORG_CONTACT_PKG" AS
/*$Header: ARHLORCB.pls 120.36.12010000.4 2008/10/27 09:39:36 idali ship $*/

l_error_flag                            FLAG_COLUMN;
l_action_mismatch_errors		FLAG_ERROR;
l_flex_val_errors			NUMBER_COLUMN;

l_dup_rel_errors 			FLAG_ERROR;
l_department_code_errors   		LOOKUP_ERROR;
l_title_errors 			        LOOKUP_ERROR;
l_job_title_code_errors 		LOOKUP_ERROR;
l_rel_code_errors			LOOKUP_ERROR;
l_hierarchical_flag_errors		FLAG_ERROR;
l_start_date_errors                     FLAG_ERROR;
l_start_end_date_errors                 FLAG_ERROR;
l_sbj_person_type_errors                FLAG_ERROR;
l_obj_org_type_errors                   FLAG_ERROR;
l_decision_maker_flag_errors            FLAG_ERROR;
l_reference_use_flag_errors             FLAG_ERROR;
l_dss_security_errors			FLAG_COLUMN;


l_exception_exists                      FLAG_ERROR;

l_batch_id                    		NUMBER;
l_sub_orig_system                       SUB_ORIG_SYSTEM;
l_sub_owner_table_id                    SUB_ORIG_SYSTEM_REFERENCE;
l_obj_orig_system                       OBJ_ORIG_SYSTEM;
l_obj_owner_table_id                    OBJ_ORIG_SYSTEM_REFERENCE;
l_insert_update_flag                    INSERT_UPDATE_FLAG;
l_contact_number                        CONTACT_NUMBER;
l_department_code                       DEPARTMENT_CODE;
l_department                            DEPARTMENT;
l_title                                 TITLE;
l_job_title                             JOB_TITLE;
l_job_title_code                        JOB_TITLE_CODE;
l_decision_maker_flag                   DECISION_MAKER_FLAG;
l_reference_use_flag                    REFERENCE_USE_FLAG;
l_comments                              COMMENTS;
l_relationship_type                     RELATIONSHIP_TYPE;
l_relationship_code                     RELATIONSHIP_CODE;
l_forward_rel_code                      RELATIONSHIP_CODE;
l_backward_rel_code                     RELATIONSHIP_CODE;
l_start_date                            START_DATE;
l_end_date                              END_DATE;
l_rel_comments                          REL_COMMENTS;
l_attribute_category                    ATTRIBUTE_CATEGORY;
l_attribute1                            ATTRIBUTE;
l_attribute2                            ATTRIBUTE;
l_attribute3                            ATTRIBUTE;
l_attribute4              		ATTRIBUTE;
l_attribute5              		ATTRIBUTE;
l_attribute6              		ATTRIBUTE;
l_attribute7              		ATTRIBUTE;
l_attribute8              		ATTRIBUTE;
l_attribute9              		ATTRIBUTE;
l_attribute10             	        ATTRIBUTE;
l_attribute11             	        ATTRIBUTE;
l_attribute12             	        ATTRIBUTE;
l_attribute13                           ATTRIBUTE;
l_attribute14                           ATTRIBUTE;
l_attribute15                           ATTRIBUTE;
l_attribute16                           ATTRIBUTE;
l_attribute17                           ATTRIBUTE;
l_attribute18                           ATTRIBUTE;
l_attribute19                           ATTRIBUTE;
l_attribute20                           ATTRIBUTE;
l_interface_status                      INTERFACE_STATUS;
l_error_id                              ERROR_ID;

l_created_by_module                     CREATED_BY_MODULE;
l_row_id				ROWID;

l_subject_name                          PARTY_NAME;
l_object_name                           PARTY_NAME;
l_subject_party_type                    PARTY_TYPE;
l_object_party_type                     PARTY_TYPE;
l_relationship_id                       PARTY_ID;
l_subject_party_id                      PARTY_ID;
l_object_party_id                       PARTY_ID;
l_rel_party_id                          PARTY_ID;
l_contact_id                            PARTY_ID;
l_subject_id	                        PARTY_ID;
l_object_id                             PARTY_ID;
l_rel_party_number                      PARTY_NUMBER;
l_direction_code                        DIRECTION_CODE;
l_org_contact_id                        ORG_CONTACT_ID;

--l_old_orig_system_reference PARTY_ORIG_SYSTEM_REFERENCE;
l_osr_error_flag FLAG_COLUMN;

l_createdby_errors        LOOKUP_ERROR;


/* Keep track of rows that do not get inserted or updated successfully.
   Those are the rows that have some validation or DML errors.
   Use this when inserting into or updating other tables so that we
   do not need to check all the validation arrays. */

l_num_row_processed  NUMBER_COLUMN;

l_no_end_date DATE;


/**********************************************
 *  private procedure validate_desc_flexfield
 *
 * DESCRIPTION
 *     Validate flexfield.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created

************************************************/

PROCEDURE validate_desc_flexfield(
  p_validation_date IN DATE
) IS

BEGIN

  FOR i IN 1..l_relationship_id.count LOOP

    FND_FLEX_DESCVAL.set_context_value(l_attribute_category(i));

    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1', l_attribute1(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2', l_attribute2(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3', l_attribute3(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4', l_attribute4(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5', l_attribute5(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6', l_attribute6(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7', l_attribute7(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8', l_attribute8(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9', l_attribute9(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10', l_attribute10(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11', l_attribute11(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12', l_attribute12(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13', l_attribute13(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14', l_attribute14(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15', l_attribute15(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16', l_attribute16(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17', l_attribute17(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18', l_attribute18(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19', l_attribute19(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20', l_attribute20(i));

    IF (NOT FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_ORG_CONTACTS',
      'V',
      p_validation_date)) THEN
      l_flex_val_errors(i) := 1;
    END IF;

  END LOOP;

END validate_desc_flexfield;


/**********************************************
 *  public function validate_desc_flexfield_f
 *
 * DESCRIPTION
 *     Validate flexfield Function.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   18-Sep-08   Idris Ali    o Created

************************************************/
/* Validate desc flexfield HZ_ORG_CONTACTS. Used only when inserting
   new Contacts because need to have a function to be called in MTI.
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
      'HZ_ORG_CONTACTS',
      'V',
      p_validation_date)) THEN
    return 'Y';
  ELSE
    return null;
  END IF;

END validate_desc_flexfield_f;



/**********************************************
 *  private procedure validate_DSS_security
 *
 * DESCRIPTION
 *     Check if the DSS security is
 *     granted to the user.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created

************************************************/

PROCEDURE validate_DSS_security IS
  dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  dss_msg_count     NUMBER := 0;
  dss_msg_data      VARCHAR2(2000):= null;
BEGIN

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

END validate_DSS_security;


/**********************************************
 * private procedure report_errors
 *
 * DESCRIPTION
 *     Report error.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     P_ACTION                     IN     VARCHAR2,
 *     P_DML_EXCEPTION              IN     VARCHAR2,
 *
 * NOTES Used by update procedure.
 *       Error is caught individually, it's reported individually
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created
 *
**********************************************/

PROCEDURE report_errors(
  P_DML_RECORD    IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
  P_ACTION        IN      VARCHAR2,
  P_DML_EXCEPTION IN	  VARCHAR2
) IS
  l_error_id HZ_IMP_CONTACTS_INT.ERROR_ID%TYPE;
  m NUMBER := 1;
  n NUMBER := 1;
  num_exp NUMBER;
  exp_ind NUMBER := 1;

BEGIN

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'report_errors (+)');
  /**********************************/
  /* Validation and Error reporting */
  /**********************************/

  IF l_org_contact_id.count = 0 THEN
    return;
  END IF;

  /**********************************/
  /* Validation and Error reporting */
  /**********************************/
  l_num_row_processed := null;
  l_num_row_processed := NUMBER_COLUMN();
  l_num_row_processed.extend(l_org_contact_id.count);
  l_exception_exists := null;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_org_contact_id.count);
  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, '  ' || P_ACTION || ' Action, ' || ' total ' || num_exp || ' exceptions');

  FOR k IN 1..l_org_contact_id.count LOOP

    /* If DML fails due to validation errors or exceptions */
      IF SQL%BULK_ROWCOUNT(k) = 0 THEN
        -- FND_FILE.PUT_LINE(FND_FILE.LOG,  '  DML fails at record ' || k || '!');

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
    forall j in 1..l_org_contact_id.count
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
	 ACTION_MISMATCH_FLAG,
         e1_flag, e2_flag, e3_flag,e4_flag,e5_flag,
         e6_flag,e7_flag,e8_flag,e9_flag,
         e10_flag,e11_flag,e12_flag,
	 e13_flag,
	 e14_flag,e15_flag,e16_flag,e17_flag,
         e18_flag,
         OTHER_EXCEP_FLAG
      )
      (
        select P_DML_RECORD.REQUEST_ID,
               P_DML_RECORD.BATCH_ID,
               l_row_id(j),
               'HZ_IMP_CONTACTS_INT',
               HZ_IMP_ERRORS_S.NextVal,
               P_DML_RECORD.SYSDATE,
               P_DML_RECORD.USER_ID,
               P_DML_RECORD.SYSDATE,
               P_DML_RECORD.USER_ID,
               P_DML_RECORD.LAST_UPDATE_LOGIN,
               P_DML_RECORD.PROGRAM_APPLICATION_ID,
               P_DML_RECORD.PROGRAM_ID,
               P_DML_RECORD.SYSDATE,

               l_action_mismatch_errors(j),
               l_error_flag(j),
	       'Y', 'Y', 'Y', 'Y',
               l_department_code_errors(j),
               l_title_errors(j),
               l_job_title_code_errors(j),
               l_decision_maker_flag_errors(j),
               l_reference_use_flag_errors(j),
               l_start_end_date_errors(j),
               decode(l_flex_val_errors(j), 1, null, 'Y'),
	       'Y',
               l_dup_rel_errors(j),
               decode(l_dss_security_errors(j), FND_API.G_TRUE,'Y',null),
               l_start_date_errors(j),
	       'Y',
               'Y',
               l_exception_exists(j)
          from dual
         where l_num_row_processed(j) = 0
      );

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'report_errors (-)');

END report_errors;


/********************************************************************************
 *
 * PROCEDURE populate_error_table
 *
 * DESCRIPTION
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *         P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
 *         P_DUP_VAL_EXP               IN     VARCHAR2
 *         P_SQL_ERRM                  IN     VARCHAR2
 *
 *   OUT
 * NOTES   record errors in temp error when exception happens during insert or update.
 *
 * MODIFICATION HISTORY
 *
 *   08-27-03   Kate Shan    o Created
 *
 ********************************************************************************/

PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
BEGIN

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
       e12_flag,
       e13_flag,
       e14_flag,
       e15_flag,
       e16_flag,
       e17_flag,
       e18_flag,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              cnt_sg.int_row_id,
              'HZ_IMP_CONTACTS_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
	      'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              'Y',
              dup_val_exp_val,
              other_exp_val
         from hz_imp_contacts_sg cnt_sg, hz_imp_contacts_int cnt_int
        where cnt_sg.action_flag = 'I'
          and cnt_int.rowid = cnt_sg.int_row_id
          and cnt_int.batch_id = P_DML_RECORD.BATCH_ID
          and cnt_int.sub_orig_system = P_DML_RECORD.OS
          and cnt_int.sub_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

END populate_error_table;

/********************************************************************************
 *
 * PROCEDURE process_insert_orgcontacts
 *
 * DESCRIPTION
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *
 *   OUT
 *     x_return_status             OUT NOCOPY    VARCHAR2
 *     x_msg_count                 OUT NOCOPY    NUMBER
 *     x_msg_data                  OUT NOCOPY    VARCHAR2
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created

 *
 ********************************************************************************/


PROCEDURE process_insert_org_contacts (
  P_DML_RECORD  	       IN  	     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_insert RefCurType;

  l_insert_sql1 varchar2(20000) :=
      'BEGIN
      insert all
         when (error_flag is null
	  and sub_id is not null
	  and obj_id is not null
          and relationship_type is not null
          and rel_code_error is not null
          and start_end_date_error is not null
          and hierarchical_flag_error is not null
          and action_mismatch_error is not null
          and dup_rel_error is not null
          and department_code_error is not null
          and title_error is not null
          and job_title_code_error is not null
          and sbj_person_type_error is not null
          and obj_org_type_error is not null
          and decision_maker_flag_error is not null
          and reference_use_flag_error is not null
	  and relate_self_error is not null
          and createdby_error is not null
	  and flex_val_error is not null) then
         into hz_parties (
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
              validated_flag)
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
              1,  --object_version_number
              ''N'')
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
       ''ORG_CONTACT'',
       ''HZ_RELATIONSHIPS'',
       hz_relationships_s.nextval,
       start_date,
       end_date,
       ''A'',
       created_by_module,
       1)
         into hz_relationships (
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
              hz_relationships_s.nextval,
              sub_id,
              sp_type,
              ''HZ_PARTIES'',
              obj_id,
              op_type,
              ''HZ_PARTIES'',
              hz_parties_s.nextval,
              relationship_code,
              ''F'',
              rel_comments,
              start_date,
              end_date,
              ''A'',
              relationship_type,
              1,
              created_by_module,
              direction_code)
         into hz_relationships (
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
              hz_relationships_s.nextval,
              obj_id,
              op_type,
              ''HZ_PARTIES'',
              sub_id,
              sp_type,
              ''HZ_PARTIES'',
              hz_parties_s.nextval,
              backward_rel_code,
              ''B'',
              rel_comments,
              start_date,
              end_date,
              ''A'',
              relationship_type,
              1,  -- object_version_number,
              created_by_module,
              decode(direction_code, ''P'', ''C'', ''C'', ''P'', ''N''))
         into hz_org_contacts (
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
              department_code,
              department,
              title,
              job_title,
              job_title_code,
              decision_maker_flag,
              reference_use_flag,
              comments,
              orig_system_reference,
              status,
              object_version_number,
              created_by_module,
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
              attribute20)
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
              contact_id, --hz_org_contacts_s.nextval,
              hz_relationships_s.nextval,
              nvl(contact_number, hz_contact_numbers_s.nextval),
              department_code,
              department,
              title,
              job_title,
              job_title_code,
              decision_maker_flag,
              reference_use_flag,
              comments,
              contact_orig_system_reference,
              ''A'',
              1,
              created_by_module,
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
              attribute20)
         into hz_orig_sys_references (
              application_id,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              orig_system_ref_id,
              orig_system,
              orig_system_reference,
              owner_table_name,
              owner_table_id,
              status,
	      party_id,   --  relationship party party_id
              start_date_active,
              created_by_module,
              object_version_number,
              request_id,
              program_application_id,
              program_id,
              program_update_date)
       values (
              :application_id,
              :user_id,
              :l_sysdate,
              :user_id,
              :l_sysdate,
              :last_update_login,
              hz_orig_system_ref_s.nextval,
              contact_orig_system,
              contact_orig_system_reference,
              ''HZ_ORG_CONTACTS'',
              contact_id, ''A'',
	      hz_parties_s.nextval,
              :l_sysdate,
              created_by_module,
              1,
              :request_id,
              :program_application_id,
              :program_id,
              :l_sysdate)

         else
         into hz_imp_tmp_errors (
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
              ACTION_MISMATCH_FLAG,
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
              e12_flag,
              e13_flag,
	      e14_flag,
	      e15_flag,
	      e16_flag,
	      e17_flag,
              e18_flag
              )
       values (
              :user_id,
              :l_sysdate,
              :user_id,
              :l_sysdate,
              :last_update_login,
              :program_application_id,
              :program_id,
              :l_sysdate,

              hz_imp_errors_s.nextval,
              :p_batch_id,
              :request_id,
              row_id,
              ''HZ_IMP_CONTACTS_INT'',
              action_mismatch_error,
	      nvl2(sub_id, ''Y'', null),
	      nvl2(obj_id, ''Y'', null),
	      sbj_person_type_error,
              obj_org_type_error,
	      rel_code_error,
              department_code_error,
              title_error,
              job_title_code_error,
              decision_maker_flag_error,
              reference_use_flag_error,
              start_end_date_error,
              flex_val_error,
              hierarchical_flag_error,
              dup_rel_error,
	      ''Y'',
	      ''Y'',
	      relate_self_error,
              createdby_error)';
  l_insert_sql2 varchar2(20000) :=
       '
       select /*+ use_nl(rt) */ rs.row_id,
              rs.contact_orig_system,
              rs.contact_orig_system_reference,
              rs.sub_id,
              rs.sp_type,
              rs.obj_id,
              rs.op_type,
              rs.party_name,
              rs.contact_id,
              rs.contact_number,
              rs.department_code,
              rs.department,
              rs.title,
              rs.job_title,
              rs.job_title_code,
              rs.decision_maker_flag,
              rs.reference_use_flag,
              rs.comments,
              rt.direction_code,
              rt.backward_rel_code,
              rs.relationship_type,
              rs.relationship_code,
              rs.start_date,
              rs.end_date,
              rs.rel_comments,
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
              rs.created_by_module,
              rs.error_flag,
              rs.action_mismatch_error,
              rs.start_end_date_error,
              rs.sbj_person_type_error,
              rs.obj_org_type_error,
              rs.rel_code_error,
              rs.createdby_error,
              decode(rt.hierarchical_flag, null , ''Y'', ''N'', decode (rt.allow_circular_relationships, ''Y'', ''Y'', null), null) hierarchical_flag_error,
              rs.department_code_error,
              rs.title_error,
              rs.decision_maker_flag_error,
              rs.job_title_code_error,
              rs.reference_use_flag_error,
              rs.dup_rel_error,
              decode(rs.obj_id, rs.sub_id, decode(rt.allow_relate_to_self_flag, ''N'', null,''Y''), ''Y'') relate_self_error,
              decode(:l_val_flex, ''Y'',
                     HZ_IMP_LOAD_ORG_CONTACT_PKG.validate_desc_flexfield_f(
                     rs.attribute_category, rs.attribute1, rs.attribute2, rs.attribute3, rs.attribute4,
                     rs.attribute5, rs.attribute6, rs.attribute7, rs.attribute8, rs.attribute9,
                     rs.attribute10, rs.attribute11, rs.attribute12, rs.attribute13, rs.attribute14,
                     rs.attribute15, rs.attribute16, rs.attribute17, rs.attribute18, rs.attribute19,
                     rs.attribute20, :l_sysdate
                     ), ''Y'') flex_val_error
         from hz_relationship_types rt, (
       select /*+ ordered index(sp, HZ_PARTIES_U1) index(op, HZ_PARTIES_U1) */
              ocint.rowid row_id,
              ocsg.contact_orig_system,
              ocsg.contact_orig_system_reference,
              ocsg.sub_id,
              sp.party_type sp_type,
              ocsg.obj_id,
              op.party_type op_type,
              substrb(sp.party_name || ''-'' || op.party_name, 1, 360) party_name,
              ocsg.contact_id,
              ocint.contact_number,
              nullif(ocint.department_code, :p_gmiss_char) department_code,
              nullif(ocint.department, :p_gmiss_char) department,
              nullif(ocint.title, :p_gmiss_char) title,
              nullif(ocint.job_title, :p_gmiss_char) job_title,
              nullif(ocint.job_title_code, :p_gmiss_char) job_title_code,
              nullif(ocint.decision_maker_flag, :p_gmiss_char) decision_maker_flag,
              nullif(ocint.reference_use_flag, :p_gmiss_char) reference_use_flag,
              nullif(ocint.comments, :p_gmiss_char) comments,
              ocint.relationship_type,
              ocint.relationship_code,
              nvl(nullif(ocint.start_date, :p_gmiss_date), :l_sysdate) start_date,
              nvl(nullif(ocint.end_date, :p_gmiss_date), :l_no_end_date) end_date,
              ocint.rel_comments,
              nullif(ocint.attribute_category, :p_gmiss_char) attribute_category,
              nullif(ocint.attribute1, :p_gmiss_char) attribute1,
              nullif(ocint.attribute2, :p_gmiss_char) attribute2,
              nullif(ocint.attribute3, :p_gmiss_char) attribute3,
              nullif(ocint.attribute4, :p_gmiss_char) attribute4,
              nullif(ocint.attribute5, :p_gmiss_char) attribute5,
              nullif(ocint.attribute6, :p_gmiss_char) attribute6,
              nullif(ocint.attribute7, :p_gmiss_char) attribute7,
              nullif(ocint.attribute8, :p_gmiss_char) attribute8,
              nullif(ocint.attribute9, :p_gmiss_char) attribute9,
              nullif(ocint.attribute10, :p_gmiss_char) attribute10,
              nullif(ocint.attribute11, :p_gmiss_char) attribute11,
              nullif(ocint.attribute12, :p_gmiss_char) attribute12,
              nullif(ocint.attribute13, :p_gmiss_char) attribute13,
              nullif(ocint.attribute14, :p_gmiss_char) attribute14,
              nullif(ocint.attribute15, :p_gmiss_char) attribute15,
              nullif(ocint.attribute16, :p_gmiss_char) attribute16,
              nullif(ocint.attribute17, :p_gmiss_char) attribute17,
              nullif(ocint.attribute18, :p_gmiss_char) attribute18,
              nullif(ocint.attribute19, :p_gmiss_char) attribute19,
              nullif(ocint.attribute20, :p_gmiss_char) attribute20,
              nvl(nullif(ocint.created_by_module, :p_gmiss_char), ''HZ_IMPORT'') created_by_module,
              ocsg.error_flag,
              nvl2(nullif(nullif(ocint.insert_update_flag, :p_gmiss_char), ocsg.action_flag), null, ''Y'') action_mismatch_error,
              decode(ocint.end_date, null, ''Y'', decode(sign(ocint.end_date - nvl(ocint.start_date, sysdate)), -1, null, ''Y'')) start_end_date_error,
              decode(sp.party_type, ''PERSON'', ''Y'', null) sbj_person_type_error,
              decode(op.party_type, ''ORGANIZATION'', ''Y'', ''PERSON'', ''Y'', null) obj_org_type_error,
              nvl2(party_rel_type_l.lookup_code, ''Y'', null) rel_code_error,
              nvl2(ocint.department_code, nvl2(dept_l.lookup_code, ''Y'', null), ''Y'') department_code_error,
              nvl2(ocint.title, nvl2(title_l.lookup_code, ''Y'', null), ''Y'') title_error,
	      decode (ocint.decision_maker_flag, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) decision_maker_flag_error,
              nvl2(ocint.job_title_code, nvl2(job_title_code_l.lookup_code, ''Y'', null), ''Y'') job_title_code_error,
              decode (ocint.reference_use_flag, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) reference_use_flag_error,
              ocint.interface_status,
              decode(tc.a, 0, ''Y'') dup_rel_error,
              nvl2(nullif(ocint.created_by_module, :p_gmiss_char), nvl2(createdby_l.lookup_code, ''Y'', null), ''Y'') createdby_error

         from hz_imp_contacts_sg ocsg,
              hz_imp_contacts_int ocint,
              (select 0 a from dual union all select 1 a from dual) tc,
              hz_parties sp,
              hz_parties op,
              fnd_lookup_values party_rel_type_l,
              fnd_lookup_values dept_l,
              fnd_lookup_values title_l,
              fnd_lookup_values job_title_code_l,
              fnd_lookup_values createdby_l
        where ocint.rowid = ocsg.int_row_id
          -- validate subject id and object id
          and ocsg.sub_id = sp.party_id (+)
          and ocsg.obj_id = op.party_id (+)
          and ocsg.action_flag = ''I''
          and ocsg.batch_mode_flag = :p_batch_mode_flag
          and ocsg.batch_id = :p_batch_id
          and ocsg.sub_orig_system = :p_wu_os
          and ocsg.sub_orig_system_reference between :p_from_osr and :p_to_osr
          -- validate relationship code
          and party_rel_type_l.lookup_code (+) = ocint.relationship_code
          and party_rel_type_l.lookup_type (+) = ''PARTY_RELATIONS_TYPE''
          and party_rel_type_l.language (+) = userenv(''LANG'')
          and party_rel_type_l.view_application_id (+) = 222
          and party_rel_type_l.security_group_id (+) =
              fnd_global.lookup_security_group(''PARTY_RELATIONS_TYPE'', 222)
          -- validate department_code
          and dept_l.lookup_code (+) = ocint.department_code
          and dept_l.lookup_type (+) = ''DEPARTMENT_TYPE''
          and dept_l.language (+) = userenv(''LANG'')
          and dept_l.view_application_id (+) = 222
          and dept_l.security_group_id (+) =
              fnd_global.lookup_security_group(''DEPARTMENT_TYPE'', 222)
          -- validate title
          and title_l.lookup_code (+) = ocint.title
          and title_l.lookup_type (+) = ''CONTACT_TITLE''
          and title_l.language (+) = userenv(''LANG'')
          and title_l.view_application_id (+) = 222
          and title_l.security_group_id (+) =
              fnd_global.lookup_security_group(''CONTACT_TITLE'', 222)
          -- validate job_title_code
          and job_title_code_l.lookup_code (+) = ocint.job_title_code
          and job_title_code_l.lookup_type (+) = ''RESPONSIBILITY''
          and job_title_code_l.language (+) = userenv(''LANG'')
          and job_title_code_l.view_application_id (+) = 222
          and job_title_code_l.security_group_id (+) =
              fnd_global.lookup_security_group(''RESPONSIBILITY'', 222)
          and createdby_l.lookup_code (+) = ocint.created_by_module
          and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
          and createdby_l.language (+) = userenv(''LANG'')
          and createdby_l.view_application_id (+) = 222
          and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
          and tc.a = (select count(*)    ---- check relationship duplicate, 0 indicates no error
	              from hz_relationships r1
                      where r1.subject_id = ocsg.sub_id
                      and r1.subject_table_name = ''HZ_PARTIES''
                      and r1.object_id = ocsg.obj_id
                      and r1.relationship_type = ocint.relationship_type
                      and r1.relationship_code = ocint.relationship_code
                      and nvl(ocint.end_date, :l_no_end_date) >= r1.start_date
                      and nvl(r1.end_date, :l_no_end_date) >= ocint.start_date
                      and r1.actual_content_source= :actual_content_src
                      and r1.status = ''A''
                      and rownum = 1)
          ';

  l_insert_sql3 varchar2(2000) :='
	      ) rs
        where rs.relationship_type = rt.relationship_type (+)
          and rs.relationship_code = rt.forward_rel_code (+)
          and rs.sp_type = rt.subject_type (+)
          and rs.op_type = rt.object_type (+)
       ';

  -- append this when P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'N'
  l_where_enabled_lookup_sql varchar2(3000) :=
	' AND  ( party_rel_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( party_rel_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( party_rel_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
          AND  ( dept_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( dept_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( dept_l.END_DATE_ACTIVE,:l_sysdate ) ) )
          AND  ( title_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( title_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( title_l.END_DATE_ACTIVE,:l_sysdate ) ) )
          AND  ( job_title_code_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( job_title_code_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( job_title_code_l.END_DATE_ACTIVE,:l_sysdate ) ) )
          AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	  ';

  -- append this where clause when it is a new batch
  l_where_first_run_sql varchar2(35) := ' AND rs.interface_status is null';

  -- append this where clause when it is a rerun batch
  l_where_rerun_sql varchar2(35) := ' AND rs.interface_status = ''C''';

  l_end_sql          VARCHAR2(10) := '; END;';

  l_dml_exception varchar2(1) := 'N';

BEGIN

  savepoint process_insert_contacts_pvt;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_insert_org_contacts (+)');

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'fetch data from cursor start ' || dbms_utility.get_time);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_no_end_date = ' || l_no_end_date);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_DML_RECORD.ACTUAL_CONTENT_SRC = ' || P_DML_RECORD.ACTUAL_CONTENT_SRC);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_BATCH_ID = ' || P_BATCH_ID);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_WU_OS = ' || P_WU_OS);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_FROM_OSR = ' || P_FROM_OSR);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_TO_OSR = ' || P_TO_OSR);
*/

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
    --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_allow_disabled_lookup = Y');

    IF P_DML_RECORD.RERUN = 'N' THEN
      --  First Run
      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'First run');
      EXECUTE IMMEDIATE l_insert_sql1 || l_insert_sql2 || l_insert_sql3 || l_where_first_run_sql || l_end_sql
        USING
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
	p_dml_record.gmiss_char,
        p_dml_record.gmiss_date,
        l_no_end_date,
	--p_dml_record.gmiss_char,
        p_dml_record.batch_mode_flag,
        p_dml_record.os,
        p_dml_record.from_osr,
        p_dml_record.to_osr;

    ELSE
      -- Rerun
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-run');
      EXECUTE IMMEDIATE l_insert_sql1 || l_insert_sql2 || l_insert_sql3 || l_where_rerun_sql || l_end_sql
        USING
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
	p_dml_record.gmiss_char,
        p_dml_record.gmiss_date,
        l_no_end_date,
	--p_dml_record.gmiss_char,
        p_dml_record.batch_mode_flag,
        p_dml_record.os,
        p_dml_record.from_osr,
        p_dml_record.to_osr;

    END IF;

  ELSE -- l_allow_disabled_lookup
     -- FND_FILE.PUT_LINE(FND_FILE.LOG,'l_allow_disabled_lookup = N');

    IF P_DML_RECORD.RERUN = 'N' THEN

      --  First Run
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'First run');
      EXECUTE IMMEDIATE l_insert_sql1 || l_insert_sql2 || l_where_enabled_lookup_sql || l_insert_sql3 || l_where_first_run_sql  || l_end_sql
        USING
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
	p_dml_record.gmiss_char,
        p_dml_record.gmiss_date,
        l_no_end_date,
	--p_dml_record.gmiss_char,
        p_dml_record.batch_mode_flag,
        p_dml_record.os,
        p_dml_record.from_osr,
        p_dml_record.to_osr;


    ELSE
      -- Rerun
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-run');
      EXECUTE IMMEDIATE l_insert_sql1 || l_insert_sql2 || l_where_enabled_lookup_sql || l_insert_sql3 ||  l_where_rerun_sql || l_end_sql
        USING
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
	p_dml_record.gmiss_char,
        p_dml_record.gmiss_date,
        l_no_end_date,
	--p_dml_record.gmiss_char,
        p_dml_record.batch_mode_flag,
        p_dml_record.os,
        p_dml_record.from_osr,
        p_dml_record.to_osr;

    END IF;


  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_insert_org_contacts (-)');

EXCEPTION

    WHEN DUP_VAL_ON_INDEX THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert contacts dup val exception: ' || SQLERRM);
      ROLLBACK to process_insert_contacts_pvt;

      populate_error_table(P_DML_RECORD, 'Y', SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert org contacts other exception: ' || SQLERRM);
    ROLLBACK to process_insert_contacts_pvt;

    populate_error_table(P_DML_RECORD, 'N', SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

END process_insert_org_contacts;



/********************************************************************************
 *
 * PROCEDURE process_update_org_contacts
 *
 * DESCRIPTION
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *
 *   OUT
 *     x_return_status             OUT NOCOPY    VARCHAR2
 *     x_msg_count                 OUT NOCOPY    NUMBER
 *     x_msg_data                  OUT NOCOPY    VARCHAR2
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created
 *
 ********************************************************************************/

PROCEDURE process_update_org_contacts (
  P_DML_RECORD  	       IN  	     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_update RefCurType;

  /* Fewer validations than insert because many columns like subject, object,
     rel type, rel code etc are not updateable */
  l_update_sql varchar2(25000) :=
 	'SELECT /*+ leading(cs) use_nl(ci) rowid(ci) */
       ci.ROWID,

        -- org contact columns
        oc.org_contact_id,
        ci.contact_number,
        ci.department_code,
        ci.department,
        ci.title,
        ci.job_title,
        ci.job_title_code,
        ci.decision_maker_flag,
        ci.reference_use_flag,
        ci.comments,

        -- relationship columns
        r.relationship_id,
        ci.start_date,
        ci.end_date,
        ci.rel_comments,

        -- org contact attribute columns
        ci.ATTRIBUTE_CATEGORY,
        ci.ATTRIBUTE1,
        ci.ATTRIBUTE2,
        ci.ATTRIBUTE3,
        ci.ATTRIBUTE4,
        ci.ATTRIBUTE5,
        ci.ATTRIBUTE6,
        ci.ATTRIBUTE7,
        ci.ATTRIBUTE8,
        ci.ATTRIBUTE9,
        ci.ATTRIBUTE10,
        ci.ATTRIBUTE11,
        ci.ATTRIBUTE12,
        ci.ATTRIBUTE13,
        ci.ATTRIBUTE14,
        ci.ATTRIBUTE15,
        ci.ATTRIBUTE16,
        ci.ATTRIBUTE17,
        ci.ATTRIBUTE18,
        ci.ATTRIBUTE19,
        ci.ATTRIBUTE20,

        -- errors
        cs.ERROR_FLAG error_flag,
        decode(nvl(ci.insert_update_flag, cs.action_flag), cs.action_flag, ''Y'', null) action_mismatch_error,
        0 flex_val_errors,
        ''T'' dss_security_errors,
        --decode(ci.department_code, null, ''Y'', dept_l.lookup_code)             department_code_error,
	nvl2(ci.department_code, nvl2(dept_l.lookup_code, ''Y'', null), ''Y'') department_code_error, --bug 7034169
       -- decode(ci.title, null, ''Y'', title_l.lookup_code)                      title_error,
       	nvl2(ci.title, nvl2(title_l.lookup_code, ''Y'', null), ''Y'') title_error,--bug 7034169
        decode(ci.decision_maker_flag , null, ''Y'', decision_l.lookup_code)    decision_maker_flag_error,
        --decode(ci.job_title_code, null, ''Y'', job_title_code_l.lookup_code)    job_title_code_error,
	nvl2(ci.job_title_code, nvl2(job_title_code_l.lookup_code, ''Y'', null), ''Y'') job_title_code_error,--bug7034169
        decode(ci.reference_use_flag, null, ''Y'', reference_use_l.lookup_code) reference_use_flag_error,
        decode(ci.START_DATE, :G_MISS_DATE, null, ''Y'') start_date_error,
        decode(ci.END_DATE,
          null,
          decode(r.END_DATE, null, ''Y'',
          decode(ci.START_DATE, null, decode(sign(r.END_DATE - r.START_DATE), -1, null, ''Y''),
          decode(sign(r.END_DATE - ci.START_DATE), -1, null, ''Y''))),
          :G_MISS_DATE, ''Y'',
          decode(ci.START_DATE, null, decode(sign(ci.END_DATE - r.START_DATE), -1, null, ''Y''),
          decode(sign(ci.END_DATE - ci.START_DATE), -1, null, ''Y''))
          ) start_end_date_error,
          decode(tc.a, 0, ''Y'') dup_rel_error
/*
          (select r1.relationship_id from hz_relationships r1
          where r1.subject_id = r.subject_id
          and r1.object_id = r.object_id
          and r1.object_type = r.object_type
          and r1.subject_type = r.subject_type
          and r1.relationship_type = r.relationship_type
          and r1.relationship_code = r.relationship_code
          and decode(ci.end_date, :G_MISS_DATE, :l_no_end_date, null, nvl(r.end_date, :l_no_end_date)) >= r1.start_date
          and nvl(r1.end_date, :l_no_end_date) >= nvl(ci.start_date, r.start_date)
          and r1.actual_content_source= r.content_source_type
          and r1.status = ''A''
          and r1.relationship_id <> r.relationship_id
                 and rownum = 1
          ) identical_rel
*/
        FROM HZ_IMP_CONTACTS_INT ci,
             HZ_IMP_CONTACTS_SG cs,
             HZ_RELATIONSHIPS r,
             HZ_ORG_CONTACTS oc,
             AR_LOOKUPS dept_l,
             AR_LOOKUPS title_l,
             AR_LOOKUPS decision_l,
             AR_LOOKUPS job_title_code_l,
             AR_LOOKUPS reference_use_l,
             (select 0 a from dual union all select 1 a from dual) tc
        WHERE
            ci.rowid = cs.int_row_id
        AND cs.contact_id = oc.org_contact_id
        AND oc.party_relationship_id = r.relationship_id
        AND r.directional_flag = ''F''
        AND cs.batch_id = :P_BATCH_ID
        AND cs.sub_orig_system = :P_WU_OS
        AND cs.sub_orig_system_reference between :P_FROM_OSR and :P_TO_OSR
        AND cs.ACTION_FLAG = ''U''
	AND cs.batch_mode_flag = :P_BATCH_MODE_FLAG
        AND dept_l.lookup_type(+) = ''DEPARTMENT_TYPE''
        AND ci.department_code = dept_l.lookup_code(+)
        AND title_l.lookup_type(+) = ''CONTACT_TITLE''
        AND ci.title  = title_l.lookup_code(+)
        AND decision_l.lookup_type(+)=''YES/NO''
        AND ci.decision_maker_flag = decision_l.lookup_code(+)
        AND job_title_code_l.lookup_type(+) = ''RESPONSIBILITY''
        AND ci.job_title_code  = job_title_code_l.lookup_code(+)
        and reference_use_l.lookup_type(+)=''YES/NO''
        and ci.reference_use_flag = reference_use_l.lookup_code(+)
        and tc.a = (select count(*)    ---- check relationship duplicate, 0 indicates no error
	              from hz_relationships r1
                      where r1.subject_id = cs.sub_id
                      and r1.subject_table_name = ''HZ_PARTIES''
                      and r1.object_id = cs.obj_id
                      and r1.relationship_id <> oc.party_relationship_id
                      and r1.relationship_type = ci.relationship_type
                      and r1.relationship_code = ci.relationship_code
                      and nvl(ci.end_date, :l_no_end_date) >= r1.start_date
                      and nvl(r1.end_date, :l_no_end_date) >= ci.start_date
                      and r1.actual_content_source= :l_content_source_type
                      and r1.status = ''A''
                      and rownum = 1)

        ';

  l_where_first_run_sql varchar2(40) := ' AND ci.interface_status is null';
  l_where_rerun_sql varchar2(40) := ' AND ci.interface_status = ''C''';

  l_dml_exception varchar2(1) := 'N';

BEGIN

  savepoint process_update_contacts_pvt;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_update_org_contacts (+)');

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF P_DML_RECORD.RERUN = 'N' THEN

      --  First Run
      OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      -- P_DML_RECORD.GMISS_DATE, l_no_end_date, l_no_end_date, l_no_end_date,
      P_DML_RECORD.batch_id, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR,
      P_DML_RECORD.TO_OSR, P_DML_RECORD.batch_mode_flag,
      l_no_end_date, l_no_end_date, p_dml_record.actual_content_src;

    ELSE
      -- Rerun
      OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      -- P_DML_RECORD.GMISS_DATE, l_no_end_date, l_no_end_date, l_no_end_date,
      P_DML_RECORD.batch_id, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR,
      P_DML_RECORD.TO_OSR, P_DML_RECORD.batch_mode_flag,
      l_no_end_date, l_no_end_date, p_dml_record.actual_content_src;

    END IF;


  FETCH c_handle_update BULK COLLECT INTO

    l_row_id,

    -- org contact columns
    l_org_contact_id,
    l_contact_number,
    l_department_code,
    l_department,
    l_title,
    l_job_title,
    l_job_title_code,
    l_decision_maker_flag,
    l_reference_use_flag,
    l_comments,

    -- relationship columns
    l_relationship_id,
    l_start_date,
    l_end_date,
    l_rel_comments,

    -- org contact attribute columns
    l_attribute_category,
    l_attribute1,
    l_attribute2,
    l_attribute3,
    l_attribute4,
    l_attribute5,
    l_attribute6,
    l_attribute7,
    l_attribute8,
    l_attribute9,
    l_attribute10,
    l_attribute11,
    l_attribute12,
    l_attribute13,
    l_attribute14,
    l_attribute15,
    l_attribute16,
    l_attribute17,
    l_attribute18,
    l_attribute19,
    l_attribute20,

    -- error flags
    l_error_flag,
    l_action_mismatch_errors,
    l_flex_val_errors,
    l_dss_security_errors,
    l_department_code_errors,
    l_title_errors,
    l_decision_maker_flag_errors,
    l_job_title_code_errors,
    l_reference_use_flag_errors,
    l_start_date_errors,
    l_start_end_date_errors,
    l_dup_rel_errors;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'org_contact_id count = ' || l_org_contact_id.count);

  /*** Do FND desc flex validation based on profile ***/
  IF P_DML_RECORD.FLEX_VALIDATION = 'Y' THEN
    validate_desc_flexfield(P_DML_RECORD.SYSDATE);
  END IF;


  /*** Do DSS security validation based on profile ***/
  IF P_DML_RECORD.DSS_SECURITY = 'Y' THEN
    validate_DSS_security;
  END IF;

  /*************************************************/
  /*   Update HZ_RELATIONSHIPS (Both directions)   */
  /*************************************************/

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'update hz_party_relationships ');

  BEGIN
    ForAll j in 1..l_relationship_id.count SAVE EXCEPTIONS
      update hz_relationships set
        START_DATE =  /* No need to check G_MISS here as it is caught by l_start_date_errors */
                    nvl(l_start_date(j), start_date),
        END_DATE =
                   DECODE(l_end_date(j),
                   	  NULL, end_date,
                   	  P_DML_RECORD.GMISS_DATE, NULL,
                   	  l_end_date(j)),

        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_DATE = trunc(P_DML_RECORD.SYSDATE),
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        COMMENTS =
                   DECODE(l_rel_comments(j),
                   	  NULL, comments,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_rel_comments(j)),
        OBJECT_VERSION_NUMBER =
                   DECODE(OBJECT_VERSION_NUMBER,
                   	  NULL, 1,
                   	  OBJECT_VERSION_NUMBER+1)
      where
        relationship_id = l_relationship_id(j)
        and l_start_date_errors(j) is not null
        and l_start_end_date_errors(j) is not null
        and l_error_flag(j) is null
        and l_action_mismatch_errors(j) is not null
        and l_dup_rel_errors(j) is not null
        and l_flex_val_errors(j) = 0
	and l_dss_security_errors(j) = 'T'
        and l_department_code_errors(j) is not null
        and l_title_errors(j) is not null
        and l_decision_maker_flag_errors(j) is not null
        and l_job_title_code_errors(j) is not null
        and l_reference_use_flag_errors(j) is not null;
         /* Bug 7416351
        and actual_content_source= P_DML_RECORD.ACTUAL_CONTENT_SRC
        and actual_content_source = P_DML_RECORD.ACTUAL_CONTENT_SRC;
        */
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other exceptions when updating hz_relationships');
      l_dml_exception := 'Y';

      FOR k IN 1..l_relationship_id.count LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'dml_errors BULK_ROWCOUNT = ' || SQL%BULK_ROWCOUNT(k));
      END LOOP;
  END;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, '3 ' || dbms_utility.get_time);

  report_errors(P_DML_RECORD, 'U', l_dml_exception);


  /*************************************************/
  /*   Update HZ_ORG_CONTACTS                      */
  /*************************************************/

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'update hz_org_contacts ');

  BEGIN
    ForAll j in 1..l_org_contact_id.count
      update hz_org_contacts set
        CONTACT_NUMBER =
                   DECODE(l_contact_number(j),
                    	  NULL, CONTACT_NUMBER,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_contact_number(j)),
        DEPARTMENT_CODE =
                   DECODE(l_department_code(j),
                    	  NULL, DEPARTMENT_CODE,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_department_code(j)),
        DEPARTMENT =
                   DECODE(l_department(j),
                    	  NULL, DEPARTMENT,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_department(j)),
        TITLE =
                   DECODE(l_title(j),
                    	  NULL, TITLE,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_title(j)),
        JOB_TITLE =
                   DECODE(l_job_title(j),
                    	  NULL, JOB_TITLE,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_job_title(j)),
        JOB_TITLE_CODE =
                   DECODE(l_job_title_code(j),
                    	  NULL, JOB_TITLE_CODE,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_job_title_code(j)),
        DECISION_MAKER_FLAG =
                   DECODE(l_decision_maker_flag(j),
                    	  NULL, DECISION_MAKER_FLAG,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_decision_maker_flag(j)),
        REFERENCE_USE_FLAG =
                   DECODE(l_reference_use_flag(j),
                    	  NULL, REFERENCE_USE_FLAG,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_reference_use_flag(j)),
        COMMENTS =
                   DECODE(l_comments(j),
                    	  NULL, comments,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_comments(j)),
        ATTRIBUTE_CATEGORY =
                   DECODE(l_attribute_category(j),
                   	  NULL, attribute_category,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute_category(j)),
        ATTRIBUTE1 =
                   DECODE(l_attribute1(j),
                   	  NULL, attribute1,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute1(j)),
        ATTRIBUTE2 =
                   DECODE(l_attribute2(j),
                   	  NULL, attribute2,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute2(j)),
        ATTRIBUTE3 =
                   DECODE(l_attribute3(j),
                   	  NULL, attribute3,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                    	  l_attribute3(j)),
        ATTRIBUTE4 =
                   DECODE(l_attribute4(j),
                   	  NULL, attribute4,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute4(j)),
        ATTRIBUTE5 =
                   DECODE(l_attribute5(j),
                   	  NULL, attribute5,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute5(j)),
        ATTRIBUTE6 =
                   DECODE(l_attribute6(j),
                   	  NULL, attribute6,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute6(j)),
        ATTRIBUTE7 =
                   DECODE(l_attribute7(j),
                   	  NULL, attribute7,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute7(j)),
        ATTRIBUTE8 =
                   DECODE(l_attribute8(j),
                   	  NULL, attribute8,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute8(j)),
        ATTRIBUTE9 =
                   DECODE(l_attribute9(j),
                   	  NULL, attribute9,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute9(j)),
        ATTRIBUTE10 =
                   DECODE(l_attribute10(j),
                   	  NULL, attribute10,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute10(j)),
        ATTRIBUTE11 =
                   DECODE(l_attribute11(j),
                   	  NULL, attribute11,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute11(j)),
        ATTRIBUTE12 =
                   DECODE(l_attribute12(j),
                   	  NULL, attribute12,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute12(j)),
        ATTRIBUTE13 =
                   DECODE(l_attribute13(j),
                   	  NULL, attribute13,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute13(j)),
        ATTRIBUTE14 =
                   DECODE(l_attribute14(j),
                   	  NULL, attribute14,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute14(j)),
        ATTRIBUTE15 =
                   DECODE(l_attribute15(j),
                   	  NULL, attribute15,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute15(j)),
        ATTRIBUTE16 =
                   DECODE(l_attribute16(j),
                   	  NULL, attribute16,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute16(j)),
        ATTRIBUTE17 =
                   DECODE(l_attribute17(j),
                   	  NULL, attribute17,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute17(j)),
        ATTRIBUTE18 =
                   DECODE(l_attribute18(j),
                   	  NULL, attribute18,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute18(j)),
        ATTRIBUTE19 =
                   DECODE(l_attribute19(j),
                   	  NULL, attribute19,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute19(j)),
        ATTRIBUTE20 =
                   DECODE(l_attribute20(j),
                   	  NULL, attribute20,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attribute20(j)),
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_DATE = trunc(P_DML_RECORD.SYSDATE),
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE

      where
        org_contact_id = l_org_contact_id(j)
        and l_start_date_errors(j) is not null
        and l_start_end_date_errors(j) is not null
        and l_error_flag(j) is null
        and l_action_mismatch_errors(j) is not null
        and l_dup_rel_errors(j) is not null
        and l_flex_val_errors(j) = 0
	and l_dss_security_errors(j) = 'T'
        and l_department_code_errors(j) is not null
        and l_title_errors(j) is not null
        and l_decision_maker_flag_errors(j) is not null
        and l_job_title_code_errors(j) is not null
        and l_reference_use_flag_errors(j) is not null
	-- only update those rows which sucessfully updated in hz_relationships
	and l_num_row_processed(j) = 1;

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other exceptions when updating hz_org_contacts');
      ROLLBACK to process_update_contacts_pvt;

      populate_error_table(P_DML_RECORD, 'N', SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

  END;

  CLOSE c_handle_update;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_update_org_contacts (-)');

END process_update_org_contacts;

/********************************************************************************
 *
 * PROCEDURE load_org_contacts
 *
 * DESCRIPTION
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     P_DML_RECORD                 IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
 *
 *   OUT
 *     x_return_status             OUT NOCOPY    VARCHAR2
 *     x_msg_count                 OUT NOCOPY    NUMBER
 *     x_msg_data                  OUT NOCOPY    VARCHAR2
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created
 *
 ********************************************************************************/

PROCEDURE load_org_contacts (
   P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

   l_return_status    VARCHAR2(30);
   l_msg_data         VARCHAR2(2000);
   l_msg_count        NUMBER;

BEGIN

   savepoint load_org_contacts_pvt;
   FND_MSG_PUB.initialize;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'load_org_contacts (+)');

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_no_end_date := TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');

   process_insert_org_contacts(
      P_DML_RECORD       => P_DML_RECORD
      ,x_return_status   => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
   );

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     return;
   END IF;

   process_update_org_contacts(
      P_DML_RECORD       => P_DML_RECORD
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
   );


   FND_FILE.PUT_LINE(FND_FILE.LOG, 'load_org_contacts (-)');

END load_org_contacts;
END HZ_IMP_LOAD_ORG_CONTACT_PKG;

/
