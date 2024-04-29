--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_PARTIES_PKG" AS
/*$Header: ARHLPTYB.pls 120.51.12010000.2 2008/09/10 10:00:45 kguggila ship $*/

  g_debug_count             		NUMBER := 0;
  --g_debug                   		BOOLEAN := FALSE;

  l_party_type_errors 			LOOKUP_ERROR;
  l_month_errors 			LOOKUP_ERROR;
  l_legal_status_errors 		LOOKUP_ERROR;
  l_local_bus_iden_type_errors 		LOOKUP_ERROR;
  l_reg_type_errors 			LOOKUP_ERROR;
  l_own_rent_errors 			LOOKUP_ERROR;
  l_hq_branch_errors 			LOOKUP_ERROR;
  l_minority_owned_errors 		FLAG_ERROR;
  l_gsa_errors  			FLAG_ERROR;
  l_import_errors 			FLAG_ERROR;
  l_export_errors			FLAG_ERROR;
  l_branch_flag_errors			FLAG_ERROR;
  l_disadv_8a_ind_errors		FLAG_ERROR;
  l_labor_surplus_errors 		FLAG_ERROR;
  l_oob_errors 				FLAG_ERROR;
  l_parent_sub_errors 			FLAG_ERROR;
  l_pub_ownership_errors 		FLAG_ERROR;
  l_small_bus_errors 			FLAG_ERROR;
  l_tot_emp_est_errors 			LOOKUP_ERROR;
  l_tot_emp_min_errors			LOOKUP_ERROR;
  l_tot_emp_ind_errors			LOOKUP_ERROR;
  l_woman_own_errors 			FLAG_ERROR;
  l_emp_pri_adr_est_ind_errors	  	LOOKUP_ERROR;
  l_emp_pri_adr_est_min_errors		LOOKUP_ERROR;
  l_marital_status_errors		LOOKUP_ERROR;
  -- Bug 4310257
  l_gender_errors	        	LOOKUP_ERROR;
  l_person_iden_type_errors    		LOOKUP_ERROR;

  -- Bug 4310257
  l_createdby_errors	        	LOOKUP_ERROR;

  l_contact_title_errors		LOOKUP_ERROR;
  l_deceased_flag_errors		FLAG_ERROR;
  l_birth_date_errors			FLAG_ERROR;
  l_death_date_errors			FLAG_ERROR;
  l_birth_death_errors			FLAG_ERROR;
  l_action_mismatch_errors		FLAG_ERROR;
  l_head_of_household_errors		FLAG_ERROR;
  l_flex_val_errors			NUMBER_COLUMN;
  l_dss_security_errors			FLAG_COLUMN;

  -- Bug 5146904
  l_party_name_update_errors            FLAG_ERROR;
  l_party_name_profile                  VARCHAR2(1000);

  l_party_orig_system PARTY_ORIG_SYSTEM;
  l_party_orig_system_reference PARTY_ORIG_SYSTEM_REFERENCE;
  l_insert_update_flag INSERT_UPDATE_FLAG;
  l_party_type TYPE_COLUMN;
  l_party_id PARTY_ID;
  l_tca_party_id PARTY_ID;
  l_party_number PARTY_NUMBER;
  l_salutation SALUTATION;
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
  l_attr21 ATTRIBUTE;
  l_attr22 ATTRIBUTE;
  l_attr23 ATTRIBUTE;
  l_attr24 ATTRIBUTE;
  l_organization_name ORGANIZATION_NAME;
  l_organization_name_phonetic ORGANIZATION_NAME_PHONETIC;
  l_organization_type TYPE_COLUMN;
  l_analysis_fy ANALYSIS_FY;
  l_branch_flag BRANCH_FLAG;
  l_business_scope BUSINESS_SCOPE;
  l_ceo_name CEO;
  l_ceo_title CEO;
  l_cong_dist_code CONG_DIST_CODE;
  l_control_yr NUMBER_COLUMN;
  l_corporation_class CORPORATION_CLASS;
  l_curr_fy_potential_revenue NUMBER_COLUMN;
  l_next_fy_potential_revenue NUMBER_COLUMN;
  l_pref_functional_currency PREF_FUNCTIONAL_CURRENCY;
  l_disadv_8a_ind IND_COLUMN;
  l_do_not_confuse_with DO_NOT_CONFUSE_WITH;
  l_duns_c DUNS_NUMBER_C;
  l_emp_at_primary_adr EMP_AT_PRIMARY_ADR;
  l_emp_at_primary_adr_est_ind IND_COLUMN;
  l_emp_at_primary_adr_min_ind IND_COLUMN;
  l_emp_at_primary_adr_text EMP_AT_PRIMARY_ADR_TEXT;
  l_employees_total NUMBER_COLUMN;
  l_displayed_duns DISPLAYED_DUNS;
  l_displayed_duns_party_id NUMBER_COLUMN;
  l_export_ind IND_COLUMN;
  l_fiscal_yearend_month FISCAL_YEAREND_MONTH;
  l_gsa_indicator_flag FLAG_COLUMN;
  l_hq_branch_ind IND_COLUMN;
  l_import_ind IND_COLUMN;
  l_incorp_year YEAR_COLUMN;
  l_jgzz_fiscal_code JGZZ_FISCAL_CODE;
  l_tax_reference TAX_REFERENCE;
  l_known_as KNOWN_AS;
  l_known_as2 KNOWN_AS;
  l_known_as3 KNOWN_AS;
  l_known_as4 KNOWN_AS;
  l_known_as5 KNOWN_AS;
  l_labor_surplus_ind IND_COLUMN;
  l_legal_status LEGAL_STATUS;
  l_line_of_business LINE_OF_BUSINESS;
  l_local_bus_identifier LOCAL_BUS_IDENTIFIER;
  l_local_bus_iden_type TYPE_COLUMN;
  l_minority_owned_ind IND_COLUMN;
  l_minority_owned_type TYPE_COLUMN;
  l_mission_statement MISSION_STATEMENT;
  l_oob_ind IND_COLUMN;
  l_parent_sub_ind IND_COLUMN;
  l_principal_name PRINCIPAL_NAME;
  l_principal_title PRINCIPAL_TITLE;
  l_public_private_flag FLAG_COLUMN;
  l_registration_type TYPE_COLUMN;
  l_rent_own_ind IND_COLUMN;
  l_small_bus_ind IND_COLUMN;
  l_total_emp_est_ind IND_COLUMN;
  l_total_emp_min_ind IND_COLUMN;
  l_total_employees_ind IND_COLUMN;
  l_total_employees_text TOTAL_EMPLOYEES_TEXT;
  l_total_payments NUMBER_COLUMN;
  l_woman_owned_ind IND_COLUMN;
  l_year_established YEAR_COLUMN;
  l_person_first_name PERSON_FIRST_NAME;
  l_person_last_name PERSON_LAST_NAME;
  l_person_middle_name PERSON_MIDDLE_NAME;
  l_person_initials PERSON_INITIALS;
  l_person_name_suffix PERSON_NAME_SUFFIX;
  l_person_pre_name_adjunct PERSON_PRE_NAME_ADJUNCT;
  l_person_previous_last_name PERSON_PREVIOUS_LAST_NAME;
  l_person_title PERSON_TITLE;
  l_person_first_name_phonetic PERSON_FIRST_NAME_PHONETIC;
  l_person_last_name_phonetic PERSON_FIRST_NAME_PHONETIC;
  l_person_middle_name_phonetic PERSON_FIRST_NAME_PHONETIC;
  l_person_name_phonetic PERSON_NAME_PHONETIC;
  l_person_academic_title PERSON_ACADEMIC_TITLE;
  l_date_of_birth DATE_COLUMN;
  l_place_of_birth PLACE_OF_BIRTH;
  l_date_of_death DATE_COLUMN;
  l_deceased_flag FLAG_COLUMN;
  l_declared_ethnicity DECLARED_ETHNICITY;
  l_gender GENDER;
  l_head_of_household_flag FLAG_COLUMN;
  l_household_income NUMBER_COLUMN;
  l_household_size NUMBER_COLUMN;
  l_marital_status MARITAL_STATUS;
  l_marital_status_eff_date DATE_COLUMN;
  l_person_iden_type TYPE_COLUMN;
  l_person_identifier PERSON_IDENTIFIER;
  l_personal_income NUMBER_COLUMN;
  l_created_by_module CREATED_BY_MODULE;
  l_party_name PARTY_NAME;
  l_person_name PERSON_NAME;
  l_interface_status INTERFACE_STATUS;
  l_action_flag FLAG_COLUMN;
  l_row_id ROWID;
  l_status FLAG_COLUMN;

  l_old_orig_system_reference PARTY_ORIG_SYSTEM_REFERENCE;
  l_new_osr_exists FLAG_COLUMN;

  l_errm varchar2(100);

  /* Keep track of rows that do not get inserted or updated successfully.
     Those are the rows that have some validation or DML errors.
     Use this when inserting into or updating other tables so that we
     do not need to check all the validation arrays. */
  l_num_row_processed NUMBER_COLUMN;

  l_user_name varchar2(100);
  l_no_end_date DATE:= TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');

  l_content_source_type varchar2(100);
  l_actual_content_source varchar2(100);
  l_entity_attr_id NUMBER;
  l_org_mixnmatch_enabled VARCHAR2(1);
  l_per_mixnmatch_enabled VARCHAR2(1);

  l_index number := 1;


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


PROCEDURE validate_desc_flexfield(
p_validation_date IN DATE
) IS
  l_flex_exists  VARCHAR2(1);

BEGIN
  FOR i IN 1..l_party_orig_system_reference.count LOOP

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
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE21', l_attr21(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE22', l_attr22(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE23', l_attr23(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE24', l_attr24(i));

    IF (NOT FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_PARTIES',
      'V',
      p_validation_date)) THEN
      l_flex_val_errors(i) := 1;
    END IF;

  END LOOP;

END validate_desc_flexfield;


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
  p_attr21         IN VARCHAR2,
  p_attr22         IN VARCHAR2,
  p_attr23         IN VARCHAR2,
  p_attr24         IN VARCHAR2,
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
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE21', p_attr21);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE22', p_attr22);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE23', p_attr23);
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE24', p_attr24);

  IF (FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_PARTIES',
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
	hz_utility_v2pub.debug(p_message=>'PTY:validate_DSS_security()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  /* Check if the DSS security is granted to the user.
     Only check for update. */
  FOR i IN 1..l_party_orig_system_reference.count LOOP
    l_dss_security_errors(i) :=
    	      hz_dss_util_pub.test_instance(
                p_operation_code     => 'UPDATE',
                p_db_object_name     => 'HZ_PARTIES',
                p_instance_pk1_value => l_party_id(i),
                p_user_name          => fnd_global.user_name,
                x_return_status      => dss_return_status,
                x_msg_count          => dss_msg_count,
                x_msg_data           => dss_msg_data);

  END LOOP;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:validate_DSS_security()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  END validate_DSS_security;


PROCEDURE report_errors(
  P_DML_RECORD    IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
  P_DML_EXCEPTION IN	  VARCHAR2
) IS
  num_exp NUMBER;
  exp_ind NUMBER := 1;

  l_dup_val_exists FLAG_ERROR;
  l_exception_exists FLAG_ERROR;
  l_debug_prefix    VARCHAR2(30) := '';
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  /**********************************/
  /* Validation and Error reporting */
  /**********************************/

  IF l_party_orig_system_reference.count = 0 THEN
    return;
  END IF;

  l_num_row_processed := null;
  l_num_row_processed := NUMBER_COLUMN();
  l_num_row_processed.extend(l_party_orig_system_reference.count);
  l_dup_val_exists := null;
  l_dup_val_exists := FLAG_ERROR();
  l_dup_val_exists.extend(l_party_orig_system_reference.count);
  l_exception_exists := null;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_party_orig_system_reference.count);
  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  FOR k IN 1..l_party_orig_system_reference.count LOOP

    /* If DML fails due to validation errors or exceptions */
    IF SQL%BULK_ROWCOUNT(k) = 0 THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'DML fails at ' || k,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

      l_num_row_processed(k) := 0;

      /* Check for any exceptions during DML */
      IF P_DML_EXCEPTION = 'Y' THEN

        FOR i IN exp_ind..num_exp LOOP
          IF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = k THEN

            IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE = 1 THEN
              l_dup_val_exists(k) := 'Y';
            ELSE
              l_exception_exists(k) := 'Y';
            END IF;

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
  forall j in 1..l_party_orig_system_reference.count
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
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,
       e6_flag,e7_flag,e8_flag,e9_flag,e10_flag,
       e11_flag,e12_flag,e13_flag,e14_flag,e15_flag,
       e16_flag,e17_flag,e18_flag,e19_flag,e20_flag,
       e21_flag,e22_flag,e23_flag,e24_flag,e25_flag,
       e26_flag,e27_flag,e28_flag,e29_flag,e30_flag,
       e31_flag,e32_flag,e33_flag,e34_flag,e35_flag,
       e36_flag,e37_flag, -- Bug 4310257
       e38_flag, -- Bug 4619002
       e39_flag,
       ACTION_MISMATCH_FLAG,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
    )
    (
      select P_DML_RECORD.REQUEST_ID,
             P_DML_RECORD.BATCH_ID,
             l_row_id(j),
             'HZ_IMP_PARTIES_INT',
             HZ_IMP_ERRORS_S.NextVal,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.LAST_UPDATE_LOGIN,
             P_DML_RECORD.PROGRAM_APPLICATION_ID,
             P_DML_RECORD.PROGRAM_ID,
             P_DML_RECORD.SYSDATE,
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_month_errors(j),'Y', null), 'Y'),  --HZ_API_INVALID_LOOKUP,COLUMN,FISCAL_YEAREND_MONTH,LOOKUP_TYPE,MONTH
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_legal_status_errors(j),'Y', null), 'Y'),   --HZ_API_INVALID_LOOKUP,COLUMN,LEGAL_STATUS,LOOKUP_TYPE,LEGAL_STATUS
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_local_bus_iden_type_errors(j),'Y', null), 'Y'),  --HZ_API_INVALID_LOOKUP,COLUMN,LOCAL_BUS_IDEN_TYPE,LOOKUP_TYPE,LOCAL_BUS_IDEN_TYPE
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_reg_type_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,REGISTRATION_TYPE,LOOKUP_TYPE,REGISTRATION_TYPE
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_hq_branch_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,HQ_BRANCH_IND,LOOKUP_TYPE,HQ_BRANCH_IND
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_minority_owned_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,MINORITY_OWNED_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_gsa_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,GSA_INDICATOR_FLAG,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_import_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,IMPORT_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_export_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,EXPORT_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_branch_flag_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,BRANCH_FLAG,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_disadv_8a_ind_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,DISADV_8A_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_labor_surplus_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,LABOR_SURPLUS_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_oob_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,OOB_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_parent_sub_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,PARENT_SUB_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_pub_ownership_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,PUBLIC_PRIVATE_OWNERSHIP_FLAG,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_small_bus_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,SMALL_BUS_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_tot_emp_est_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,TOTAL_EMP_EST_IND,LOOKUP_TYPE,TOTAL_EMP_EST_IND
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_tot_emp_min_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,TOTAL_EMP_MIN_IND,LOOKUP_TYPE,TOTAL_EMP_MIN_IND
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_tot_emp_ind_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,TOTAL_EMPLOYEES_IND,LOOKUP_TYPE,TOTAL_EMPLOYEES_INDICATOR
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_woman_own_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,WOMAN_OWNED_IND,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_emp_pri_adr_est_ind_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,EMP_AT_PRIMARY_ADR_EST_IND,LOOKUP_TYPE,EMP_AT_PRIMARY_ADR_EST_IND
             decode(l_party_type(j), 'ORGANIZATION', nvl2(l_emp_pri_adr_est_min_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,EMP_AT_PRIMARY_ADR_MIN_IND,LOOKUP_TYPE,EMP_AT_PRIMARY_ADR_MIN_IND
             decode(l_party_type(j), 'PERSON', nvl2(l_marital_status_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,MARITAL_STATUS,LOOKUP_TYPE,MARITAL_STATUS
             decode(l_party_type(j), 'PERSON', nvl2(l_contact_title_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,PERSON_PRE_NAME_ADJUNCT,LOOKUP_TYPE,CONTACT_TITLE
             decode(l_party_type(j), 'PERSON', nvl2(l_deceased_flag_errors(j),'Y', null), 'Y'), --HZ_IMP_DECEASED_FLAG_ERROR
             decode(l_party_type(j), 'PERSON', nvl2(l_head_of_household_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,HEAD_OF_HOUSEHOLD_FLAG,LOOKUP_TYPE,YES/NO
             decode(l_party_type(j), 'PERSON', nvl2(l_birth_date_errors(j),'Y', null), 'Y'), --HZ_API_DATE_GREATER,DATE2,SYSDATE,DATE1,DATE_OF_BIRTH
             decode(l_party_type(j), 'PERSON', nvl2(l_death_date_errors(j),'Y', null), 'Y'), --HZ_API_DATE_GREATER,DATE2,SYSDATE,DATE1,DATE_OF_DEATH
             decode(l_party_type(j), 'PERSON', nvl2(l_birth_death_errors(j),'Y', null), 'Y'), --HZ_API_DATE_GREATER,DATE2,DATE_OF_DEATH,DATE1,DATE_OF_BIRTH
             nvl2(l_party_type_errors(j),'Y', null), --HZ_IMP_PARTY_TYPE_ERROR
             nvl2(l_own_rent_errors(j),'Y', null), --HZ_API_INVALID_LOOKUP,COLUMN,RENT_OWN_IND,LOOKUP_TYPE,OWN_RENT_IND
             decode(l_flex_val_errors(j),'1', null, 'Y'),   --????? AR_RAPI_DESC_FLEX_INVALID,DFF_NAME,HZ_PARTIES
             nvl2(l_tca_party_id(j), nvl2(l_party_name(j),'Y', null), 'Y'),    --HZ_IMP_PARTY_NAME_ERROR
             -- Bug 3871136
             decode(l_dss_security_errors(j), FND_API.G_FALSE,decode(l_party_type(j),'PERSON','P',
                   'ORGANIZATION','O',null),'Y'), --HZ_DSS_SECURITY_FAIL
             nvl2(l_tca_party_id(j),'Y', null),  --HZ_API_NO_RECORD
              -- Bug 4310257
             decode(l_party_type(j), 'PERSON', nvl2(l_gender_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,GENDER,LOOKUP_TYPE,HZ_GENDER
             decode(l_party_type(j), 'PERSON', nvl2(l_person_iden_type_errors(j),'Y', null), 'Y'), --HZ_API_INVALID_LOOKUP,COLUMN,PERSON_IDEN_TYPE,LOOKUP_TYPE,HZ_PERSON_IDEN_TYPE
             l_createdby_errors(j), --HZ_API_INVALID_LOOKUP,COLUMN,CREATED_BY_MODULE,LOOKUP_TYPE,HZ_CREATED_BY_MODULES
             l_party_name_update_errors(j), -- Bug 5146904
             nvl2(l_action_mismatch_errors(j),'Y',null),  --HZ_IMP_ACTION_MISMATCH
             l_dup_val_exists(j),
             l_exception_exists(j)
        from dual
       where l_num_row_processed(j) = 0
    );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:report_errors()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END report_errors;


PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix	         VARCHAR2(30) := '';
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

     /* other entities need to add checking for other constraints */
     if (P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       if(instr(P_SQL_ERRM, 'HZ_PARTIES_PK')>0) then
         dup_val_exp_val := 'A';
       else -- '_U2'
         dup_val_exp_val := 'B';
       end if;
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
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,
       e6_flag,e7_flag,e8_flag,e9_flag,e10_flag,
       e11_flag,e12_flag,e13_flag,e14_flag,e15_flag,
       e16_flag,e17_flag,e18_flag,e19_flag,e20_flag,
       e21_flag,e22_flag,e23_flag,e24_flag,e25_flag,
       e26_flag,e27_flag,e28_flag,e29_flag,e30_flag,
       e31_flag,e32_flag,e33_flag,e34_flag,e35_flag,
       e36_flag,e37_flag,
       e38_flag,
       e39_flag,
       ACTION_MISMATCH_FLAG,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              p_sg.int_row_id,
              'HZ_IMP_PARTIES_INT',
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
              'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              'Y','Y','Y','Y','Y',
              'Y','Y',
              'Y',
              'Y',
              'Y',
              dup_val_exp_val,
              other_exp_val
         from hz_imp_parties_sg p_sg
        where p_sg.action_flag = 'I'
          and p_sg.batch_id = P_DML_RECORD.BATCH_ID
          and p_sg.party_orig_system = P_DML_RECORD.OS
          and p_sg.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END populate_error_table;


/********************************************************************************
 *
 *	process_insert_parties
 *
 ********************************************************************************/

PROCEDURE process_insert_parties (
  P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_insert RefCurType;

l_s1 varchar2(10000) := '
insert all
  when (all_errors is not null) then
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
       party_id,
       status,
       start_date_active,
       created_by_module,
       object_version_number)
values (
       :1, -- application_id
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       hz_orig_system_ref_s.nextval,
       party_orig_system,
       party_orig_system_reference,
       ''HZ_PARTIES'',
       party_id,
       party_id,
       ''A'',
       :3, -- sysdate
       created_by_module,
       1)
  into hz_parties (
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
       party_id,
       party_number,
       party_name,
       party_type,
       orig_system_reference,
       status,
       salutation,
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
       attribute21,
       attribute22,
       attribute23,
       attribute24,
       analysis_fy,
       curr_fy_potential_revenue,
       duns_number_c,
       employees_total,
       fiscal_yearend_month,
       gsa_indicator_flag,
       hq_branch_ind,
       jgzz_fiscal_code,
       known_as,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       mission_statement,
       next_fy_potential_revenue,
       organization_name_phonetic,
       person_academic_title,
       person_first_name,
       person_first_name_phonetic,
       person_iden_type,
       person_identifier,
       person_last_name,
       person_last_name_phonetic,
       person_middle_name,
       person_name_suffix,
       person_pre_name_adjunct,
       person_previous_last_name,
       person_title,
       tax_reference,
       year_established,
       object_version_number,
       validated_flag,
       created_by_module,
       address1,
       address2,
       address3,
       address4,
       city,
       country,
       county,
       postal_code,
       province,
       state,
       email_address,
       url,
       primary_phone_contact_pt_id,
       primary_phone_purpose,
       primary_phone_line_type,
       primary_phone_country_code,
       primary_phone_area_code,
       primary_phone_number,
       primary_phone_extension,
       category_code,
       sic_code_type,
       sic_code)
values (
       :1, -- application_id
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       party_id,
       nvl(party_number, hz_party_number_s.nextval),
       party_name,
       party_type,
       party_orig_system_reference,
       ''A'',
       salutation,
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
       attribute21,
       attribute22,
       attribute23,
       attribute24,

       analysis_fy,
       curr_fy_potential_revenue,
       duns_number_c,
       employees_total,
       fiscal_yearend_month,
       gsa_indicator_flag,
       hq_branch_ind,
       jgzz_fiscal_code,
       known_as,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       mission_statement,
       next_fy_potential_revenue,
       organization_name_phonetic,
       person_academic_title,
       person_first_name,
       person_first_name_phonetic,
       person_iden_type,
       person_identifier,
       person_last_name,
       person_last_name_phonetic,
       person_middle_name,
       person_name_suffix,
       person_pre_name_adjunct,
       person_previous_last_name,
       person_title,
       tax_reference,
       year_established,

       1,
       ''N'',
       created_by_module,
  --following code added for bug 6164407
       decode(ads_err_flag, NULL,address1),
       decode(ads_err_flag, NULL,address2),
       decode(ads_err_flag, NULL,address3),
       decode(ads_err_flag, NULL,address4),
       decode(ads_err_flag, NULL,city),
       decode(ads_err_flag, NULL,country),
       decode(ads_err_flag, NULL,county),
       decode(ads_err_flag, NULL,postal_code),
       decode(ads_err_flag, NULL,province),
       decode(ads_err_flag, NULL,state),
       email_address,
       url,
       primary_phone_contact_pt_id,
       primary_phone_purpose,
       primary_phone_line_type,
       primary_phone_country_code,
       primary_phone_area_code,
       primary_phone_number,
       primary_phone_extension,
       category_code,
       sic_code_type,
       sic_code)';

l_s2 varchar2(10000) := '
  when (all_errors is not null and party_type = ''ORGANIZATION'') then -- o1
  into hz_organization_profiles (
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
       organization_profile_id,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       effective_start_date,
       effective_end_date,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       internal_flag,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       displayed_duns_party_id,
       duns_number_c,
       object_version_number,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code)
values (
       decode(l_content_source_type, ''USER_ENTERED'', ''SST'', :9),
       :1, -- application_id
       :9, -- actual_content_src
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_organization_profiles_s.nextval,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       :3, -- sysdate, EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       ''N'', --INTERNAL_FLAG,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       displayed_duns_party_id,
       duns_number_c,
       1,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code
       ) ';

l_s3 varchar2(10000) := '
  when (all_errors is not null
   and l_content_source_type <> ''USER_ENTERED''
   and party_type = ''ORGANIZATION'') then
  into hz_organization_profiles ( -- o2
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
       organization_profile_id,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       effective_start_date,
       effective_end_date,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       internal_flag,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       displayed_duns_party_id,
       duns_number_c,
       object_version_number,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code)
values (
       ''SST'',
       :1, -- application_id
       ''USER_ENTERED'',
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_organization_profiles_s.nextval+1,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       :3, -- sysdate --EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       ''N'', --INTERNAL_FLAG,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
 	null,
       duns_number_c,
       1,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code) ';

l_s4 varchar2(10000) := 'when (all_errors is not null
and l_content_source_type <> ''USER_ENTERED''
and party_type = ''ORGANIZATION''
and :10 = ''Y'') then
into hz_organization_profiles ( -- o3
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
       organization_profile_id,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       effective_start_date,
       effective_end_date,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       internal_flag,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       displayed_duns_party_id,
       duns_number_c,
       object_version_number,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code)
values (
       ''USER_ENTERED'',
       :1, -- application_id
       ''USER_ENTERED'',
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_organization_profiles_s.nextval+2,
       party_id,
       organization_name,
       ceo_name,
       ceo_title,
       principal_name,
       principal_title,
       legal_status,
       control_yr,
       employees_total,
       hq_branch_ind,
       oob_ind,
       line_of_business,
       cong_dist_code,
       import_ind,
       export_ind,
       branch_flag,
       labor_surplus_ind,
       minority_owned_ind,
       minority_owned_type,
       woman_owned_ind,
       disadv_8a_ind,
       small_bus_ind,
       rent_own_ind,
       organization_name_phonetic,
       tax_reference,
       gsa_indicator_flag,
       jgzz_fiscal_code,
       analysis_fy,
       fiscal_yearend_month,
       curr_fy_potential_revenue,
       next_fy_potential_revenue,
       year_established,
       mission_statement,
       organization_type,
       business_scope,
       corporation_class,
       known_as,
       local_bus_iden_type,
       local_bus_identifier,
       pref_functional_currency,
       registration_type,
       total_employees_text,
       total_employees_ind,
       total_emp_est_ind,
       total_emp_min_ind,
       parent_sub_ind,
       incorp_year,
       :3, -- sysdate --EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       public_private_ownership_flag,
       emp_at_primary_adr,
       emp_at_primary_adr_text,
       emp_at_primary_adr_est_ind,
       emp_at_primary_adr_min_ind,
       ''N'', --INTERNAL_FLAG,
       total_payments,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       null,
       duns_number_c,
       1,
       created_by_module,
       do_not_confuse_with,
       sic_code_type,
       sic_code,
       local_activity_code_type,
       local_activity_code) ';

l_s5 varchar2(10000) := '
  when (all_errors is not null and party_type = ''PERSON'') then
  into hz_person_profiles ( -- p1
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
       person_profile_id,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       effective_start_date,
       effective_end_date,
       internal_flag,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       middle_name_phonetic,
       object_version_number,
       deceased_flag,
       created_by_module)
values (
       decode(l_content_source_type, ''USER_ENTERED'', ''SST'', :9),
       :1, -- application_id
       :9, -- actual_content_src
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_person_profiles_s.nextval,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       :3, -- sysdate --EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       ''N'', --INTERNAL_FLAG,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       person_middle_name_phonetic,
       1, -- OBJECT_VERSION_NUMBER,
       deceased_flag,
       created_by_module)';

l_s6 varchar2(10000) := '
  when (all_errors is not null
   and l_content_source_type <> ''USER_ENTERED''
   and party_type = ''PERSON'') then
  into hz_person_profiles ( -- p2
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
       person_profile_id,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       effective_start_date,
       effective_end_date,
       internal_flag,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       middle_name_phonetic,
       object_version_number,
       deceased_flag,
       created_by_module)
values (
       ''SST'', --  ACTUAL_CONTENT_SOURCE,
       :1, -- application_id
       ''USER_ENTERED'', -- CONTENT_SOURCE_TYPE,
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_person_profiles_s.nextval+1,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       :3, -- sysdate --EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       ''N'', --INTERNAL_FLAG,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       person_middle_name_phonetic,
       1, -- OBJECT_VERSION_NUMBER,
       deceased_flag,
       created_by_module) ';

l_s7 varchar2(10000) := '
  when (all_errors is not null
   and l_content_source_type <> ''USER_ENTERED''
   and party_type = ''PERSON''
   and :11 = ''Y'') then
  into hz_person_profiles ( -- p2
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
       person_profile_id,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       effective_start_date,
       effective_end_date,
       internal_flag,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       middle_name_phonetic,
       object_version_number,
       deceased_flag,
       created_by_module)
values (
       ''USER_ENTERED'',
       :1, -- application_id
       ''USER_ENTERED'',
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       :7, -- request_id
       hz_person_profiles_s.nextval+2,
       party_id,
       person_name,
       person_pre_name_adjunct,
       person_first_name,
       person_middle_name,
       person_last_name,
       person_name_suffix,
       person_title,
       person_academic_title,
       person_previous_last_name,
       person_initials,
       known_as,
       person_name_phonetic,
       person_first_name_phonetic,
       person_last_name_phonetic,
       tax_reference,
       jgzz_fiscal_code,
       person_iden_type,
       person_identifier,
       date_of_birth,
       place_of_birth,
       date_of_death,
       gender,
       declared_ethnicity,
       marital_status,
       marital_status_effective_date,
       personal_income,
       head_of_household_flag,
       household_income,
       household_size,
       rent_own_ind,
       :3, -- sysdate --EFFECTIVE_START_DATE,
       null, --EFFECTIVE_END_DATE,
       ''N'', --INTERNAL_FLAG,
       known_as2,
       known_as3,
       known_as4,
       known_as5,
       person_middle_name_phonetic,
       1, -- OBJECT_VERSION_NUMBER,
       deceased_flag,
       created_by_module) ';

l_s8 varchar2(20000) := '
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
       e19_flag,
       e20_flag,
       e21_flag,
       e22_flag,
       e23_flag,
       e24_flag,
       e25_flag,
       e26_flag,
       e27_flag,
       e28_flag,
       e29_flag,
       e30_flag,
       e31_flag,
       e32_flag,
       e33_flag,
       e34_flag,
       e35_flag,
       -- Bug 4310257
       e36_flag,
       e37_flag,
       e38_flag,
       e39_flag,
       ACTION_MISMATCH_FLAG)
values (
       :2, -- user_id
       :3, -- sysdate
       :2, -- user_id
       :3, -- sysdate
       :4, -- last_update_login
       :5, -- program_application_id
       :6, -- program_id
       :3, -- sysdate
       hz_imp_errors_s.nextval,
       :12, -- batch_id
       :7, -- request_id
       row_id,
       ''HZ_IMP_PARTIES_INT'',
       month_error,
       legal_status_error,
       local_bus_iden_type_error,
       reg_type_error,
       hq_branch_error,
       minority_owned_error,
       gsa_error,
       import_error,
       export_error,
       branch_flag_error,
       disadv_8a_ind_error,
       labor_surplus_error,
       oob_error,
       parent_sub_error,
       pub_ownership_error,
       small_bus_error,
       tot_emp_est_error,
       tot_emp_min_error,
       tot_emp_ind_error,
       woman_own_error,
       emp_at_pri_adr_est_ind_error,
       emp_at_pri_adr_min_ind_error,
       marital_status_error,
       contact_title_error,
       deceased_flag_error,
       head_of_household_error,
       birth_date_error,
       death_date_error,
       birth_death_error,
       party_type_error,
       own_rent_error,
       flex_val_error,
       nvl2(party_name, ''Y'', null),
       ''Y'',
       ''Y'',
       gender_error,
       person_iden_type_error,
       createdby_error,
       ''Y'',
       action_mismatch_error)
';

l_s9 varchar2(32767) := 'select analysis_fy,
        ads_err_flag, -- added for bug 6164407
	attribute1,
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
	attribute2,
	attribute20,
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute_category,
	branch_flag,
	business_scope,
	ceo_name,
	ceo_title,
	cong_dist_code,
	control_yr,
	corporation_class,
	created_by_module,
	curr_fy_potential_revenue,
	date_of_birth,
	date_of_death,
	deceased_flag,
	declared_ethnicity,
	disadv_8a_ind,
	displayed_duns_party_id,
	do_not_confuse_with,
	case when duns_number_c IS NOT NULL AND
                  lengthb(duns_number_c)<9
             then upper(lpad(duns_number_c,9,''0''))
             else upper(duns_number_c) end duns_number_c,
	emp_at_primary_adr,
	emp_at_primary_adr_est_ind,
	emp_at_primary_adr_min_ind,
	emp_at_primary_adr_text,
	employees_total,
	export_ind,
	fiscal_yearend_month,
	gender,
	gsa_indicator_flag,
	head_of_household_flag,
	household_income,
	household_size,
	hq_branch_ind,
	import_ind,
	incorp_year,
	jgzz_fiscal_code,
	known_as,
	known_as2,
	known_as3,
	known_as4,
	known_as5,
	labor_surplus_ind,
	legal_status,
	line_of_business,
	local_bus_iden_type,
	local_bus_identifier,
	marital_status,
	marital_status_effective_date,
	minority_owned_ind,
	minority_owned_type,
	mission_statement,
	next_fy_potential_revenue,
	oob_ind,
	organization_name,
	organization_name_phonetic,
	organization_type,
	parent_sub_ind,
	party_id,
	party_name,
	party_number,
	party_orig_system,
	party_orig_system_reference,
	party_type,
	person_academic_title,
	person_first_name,
	person_first_name_phonetic,
	person_iden_type,
	person_identifier,
	person_initials,
	person_last_name,
	person_last_name_phonetic,
	person_middle_name,
	person_middle_name_phonetic,
	person_name,
	person_name_phonetic,
	person_name_suffix,
	person_pre_name_adjunct,
	person_previous_last_name,
	person_title,
	personal_income,
	place_of_birth,
	pref_functional_currency,
	principal_name,
	principal_title,
	public_private_ownership_flag,
	registration_type,
	rent_own_ind,
	row_id,
	salutation,
	small_bus_ind,
	tax_reference,
	total_emp_est_ind,
	total_emp_min_ind,
	total_employees_ind,
	total_employees_text,
	total_payments,
	woman_owned_ind,
	year_established,
	month_error,
	legal_status_error,
	local_bus_iden_type_error,
	reg_type_error,
	hq_branch_error,
	minority_owned_error,
	gsa_error,
	import_error,
	export_error,
	branch_flag_error,
	disadv_8a_ind_error,
	labor_surplus_error,
	oob_error,
	parent_sub_error,
	pub_ownership_error,
	small_bus_error,
	tot_emp_est_error,
	tot_emp_min_error,
	tot_emp_ind_error,
	woman_own_error,
	emp_at_pri_adr_est_ind_error,
	emp_at_pri_adr_min_ind_error,
	marital_status_error,
	contact_title_error,
	deceased_flag_error,
	head_of_household_error,
	birth_date_error,
	death_date_error,
	birth_death_error,
	party_type_error,
	own_rent_error,
	action_mismatch_error,
	flex_val_error,
        gender_error,
        person_iden_type_error,
        createdby_error,
	case when month_error is not null
	and legal_status_error is not null
	and local_bus_iden_type_error is not null
	and reg_type_error is not null
	and hq_branch_error is not null
	and minority_owned_error is not null
	and gsa_error is not null
	and import_error is not null
	and export_error is not null
	and branch_flag_error is not null
	and disadv_8a_ind_error is not null
	and labor_surplus_error is not null
	and oob_error is not null
	and parent_sub_error is not null
	and pub_ownership_error is not null
	and small_bus_error is not null
	and tot_emp_est_error is not null
	and tot_emp_min_error is not null
	and tot_emp_ind_error is not null
	and woman_own_error is not null
	and emp_at_pri_adr_est_ind_error is not null
	and emp_at_pri_adr_min_ind_error is not null
	and marital_status_error is not null
	and contact_title_error is not null
	and deceased_flag_error is not null
	and head_of_household_error is not null
	and birth_date_error is not null
	and death_date_error is not null
	and birth_death_error is not null
	and party_type_error is not null
	and own_rent_error is not null
	and action_mismatch_error is not null
	and flex_val_error is not null
	and party_name is not null
        and gender_error is not null
        and person_iden_type_error is not null
        and createdby_error is not null
	then 1 else null end all_errors,
	sysdate mysysdate,
	fnd_global.resp_appl_id resp_appl_id,
	:13 l_actual_content_source,
	:14 l_content_source_type,
	:4 l_last_update_login,
	:5 l_program_application_id,
	:6 l_program_id,
	:3 l_program_update_date,
	:7 l_request_id,
	:1 l_resp_appl_id,
	:2 l_user_id,
	address1,
	address2,
	address3,
	address4,
	city,
	country,
	county,
	postal_code,
	province,
	state,
	email_address,
	url,
        primary_phone_contact_pt_id,
        primary_phone_purpose,
        primary_phone_line_type,
        primary_phone_country_code,
        primary_phone_area_code,
        primary_phone_number,
        primary_phone_extension,
	category_code,
	sic_code_type,
	sic_code,
	local_activity_code_type,
	local_activity_code
from (
select analysis_fy,
        ads_err_flag, -- added for bug 6164407
	attribute1,
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
	attribute2,
	attribute20,
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute_category,
	branch_flag,
	business_scope,
	ceo_name,
	ceo_title,
	cong_dist_code,
	control_yr,
	corporation_class,
	nvl(created_by_module, ''HZ_IMPORT'') created_by_module,
	curr_fy_potential_revenue,
	date_of_birth,
	date_of_death,
	nvl(deceased_flag, nvl2(date_of_death, ''Y'', ''N'')) deceased_flag,
	declared_ethnicity,
	disadv_8a_ind,
	case when party_orig_system = ''DNB''
	     and displayed_duns = party_orig_system_reference
	    then party_id else null end displayed_duns_party_id,
	do_not_confuse_with,
	duns_number_c,
	emp_at_primary_adr,
	emp_at_primary_adr_est_ind,
	emp_at_primary_adr_min_ind,
	emp_at_primary_adr_text,
	employees_total,
	export_ind,
	fiscal_yearend_month,
	gender,
	gsa_indicator_flag,
	head_of_household_flag,
	household_income,
	household_size,
	hq_branch_ind,
	import_ind,
	incorp_year,
	jgzz_fiscal_code,
	known_as,
	known_as2,
	known_as3,
	known_as4,
	known_as5,
	labor_surplus_ind,
	legal_status,
	line_of_business,
	local_bus_iden_type,
	local_bus_identifier,
	marital_status,
	marital_status_effective_date,
	minority_owned_ind,
	minority_owned_type,
	mission_statement,
	next_fy_potential_revenue,
	oob_ind,
	organization_name,
	organization_name_phonetic,
	organization_type,
	parent_sub_ind,
	party_id,
	case when party_type = ''ORGANIZATION'' then organization_name
	    when party_type = ''PERSON'' then
	    case when person_first_name is null then person_last_name
		   when person_last_name is null then person_first_name
		   else person_first_name || '' '' || person_last_name
	    end
	    else ''Y''
	end party_name,
	party_number,
	party_orig_system,
	party_orig_system_reference,
	party_type,
	person_academic_title,
	person_first_name,
	person_first_name_phonetic,
	person_iden_type,
	person_identifier,
	person_initials,
	person_last_name,
	person_last_name_phonetic,
	person_middle_name,
	person_middle_name_phonetic,
	rtrim(person_title || nvl2(person_title, '' '', null) ||
	person_first_name || nvl2(person_first_name, '' '', null) ||
	person_middle_name || nvl2(person_middle_name, '' '', null) ||
	person_last_name || nvl2(person_last_name, '' '', null) ||
	person_name_suffix) person_name,
	person_name_phonetic,
	person_name_suffix,
	person_pre_name_adjunct,
	person_previous_last_name,
	person_title,
	personal_income,
	place_of_birth,
	pref_functional_currency,
	principal_name,
	principal_title,
	public_private_ownership_flag,
	registration_type,
	rent_own_ind,
	row_id,
	salutation,
	small_bus_ind,
	tax_reference,
	total_emp_est_ind,
	total_emp_min_ind,
	total_employees_ind,
	total_employees_text,
	total_payments,
	woman_owned_ind,
	year_established,
	decode(party_type, ''PERSON'', ''Y'', nvl2(fiscal_yearend_month, month_l, ''Y'')) month_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(legal_status, legal_status_l, ''Y'')) legal_status_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(local_bus_iden_type, local_bus_iden_type_l, ''Y'')) local_bus_iden_type_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(registration_type, reg_type_l, ''Y'')) reg_type_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(hq_branch_ind, hq_branch_l, ''Y'')) hq_branch_error,
	decode(party_type, ''PERSON'', ''Y'', decode(minority_owned_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) minority_owned_error,
	decode(party_type, ''PERSON'', ''Y'', decode(gsa_indicator_flag, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) gsa_error,
	decode(party_type, ''PERSON'', ''Y'', decode(import_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) import_error,
	decode(party_type, ''PERSON'', ''Y'', decode(export_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) export_error,
	decode(party_type, ''PERSON'', ''Y'', decode(branch_flag, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) branch_flag_error,
	decode(party_type, ''PERSON'', ''Y'', decode(disadv_8a_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) disadv_8a_ind_error,
	decode(party_type, ''PERSON'', ''Y'', decode(labor_surplus_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) labor_surplus_error,
	decode(party_type, ''PERSON'', ''Y'', decode(oob_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) oob_error,
	decode(party_type, ''PERSON'', ''Y'', decode(parent_sub_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) parent_sub_error,
	decode(party_type, ''PERSON'', ''Y'', decode(public_private_ownership_flag, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) pub_ownership_error,
	decode(party_type, ''PERSON'', ''Y'', decode(small_bus_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) small_bus_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(total_emp_est_ind, tot_emp_est_l, ''Y'')) tot_emp_est_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(total_emp_min_ind, tot_emp_min_l, ''Y'')) tot_emp_min_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(total_employees_ind, tot_emp_ind_l, ''Y'')) tot_emp_ind_error,
	decode(party_type, ''PERSON'', ''Y'', decode(woman_owned_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) woman_own_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(emp_at_primary_adr_est_ind, emp_at_pri_adr_est_ind_l, ''Y'')) emp_at_pri_adr_est_ind_error,
	decode(party_type, ''PERSON'', ''Y'', nvl2(emp_at_primary_adr_min_ind, emp_at_pri_adr_min_ind_l, ''Y'')) emp_at_pri_adr_min_ind_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', nvl2(marital_status, marital_status_l, ''Y'')) marital_status_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', nvl2(gender, gender_l, ''Y'')) gender_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', nvl2(person_iden_type, person_iden_type_l, ''Y'')) person_iden_type_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', nvl2(person_pre_name_adjunct, contact_title_l, ''Y'')) contact_title_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', nvl2(date_of_death, decode(deceased_flag, ''N'', null, ''Y''), ''Y'')) deceased_flag_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', decode(head_of_household_flag, null, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) head_of_household_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', case when nvl(date_of_birth, sysdate) <= sysdate then ''Y'' else null end) birth_date_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', case when nvl(date_of_death, sysdate) <= sysdate then ''Y'' else null end) death_date_error,
	decode(party_type, ''ORGANIZATION'', ''Y'', case when date_of_birth > date_of_death then null else ''Y'' end) birth_death_error,
	nvl2(nullif(nullif(party_type, ''PARTY_RELATIONSHIP''), ''GROUP''), party_type_l, null) party_type_error,
	nvl2(nullif(insert_update_flag, action_flag), null, ''Y'') action_mismatch_error,
	nvl2(rent_own_ind, own_rent_l, ''Y'') own_rent_error,
	nvl2(created_by_module, createdby_l, ''Y'') createdby_error,
	decode(:15, ''Y'',
	  HZ_IMP_LOAD_PARTIES_PKG.validate_desc_flexfield_f(
	  attribute_category, attribute1, attribute2, attribute3, attribute4,
	  attribute5, attribute6, attribute7, attribute8, attribute9,
	  attribute10, attribute11, attribute12, attribute13, attribute14,
	  attribute15, attribute16, attribute17, attribute18, attribute19,
	  attribute20, attribute21, attribute22, attribute23, attribute24, :3
	  ), ''T'') flex_val_error,
	address1, address2, address3, address4,
	city, country, county, postal_code, province, state,
	email_address, url,
	primary_phone_contact_pt_id, primary_phone_purpose,
	primary_phone_line_type, primary_phone_country_code,
	primary_phone_area_code, primary_phone_number,
	primary_phone_extension,
        category_code,
	sic_code_type, sic_code, local_activity_code_type, local_activity_code
from (
select /*+ leading(ps) index(webs HZ_IMP_CONTACTPTS_SG_U1)
           index(emails HZ_IMP_CONTACTPTS_SG_U1)
           index(phones HZ_IMP_CONTACTPTS_SG_U1)
           index(ads HZ_IMP_ADDRESSES_SG_U1)
           use_nl(pi party_type_l month_l legal_status_l
           local_bus_iden_type_l reg_type_l own_rent_l
           hq_branch_l tot_emp_est_l tot_emp_min_l
           tot_emp_ind_l emp_at_pri_adr_est_ind_l
           emp_at_pri_adr_min_ind_l marital_status_l
           contact_title_l gender_l person_iden_type_l sicfs nacfs cccfs)
           index(sicfs HZ_IMP_CLASSIFICS_SG_N2)
           index(nacfs HZ_IMP_CLASSIFICS_SG_N2)
           index(cccfs HZ_IMP_CLASSIFICS_SG_N2) */
	ps.action_flag action_flag,
	nullif(pi.analysis_fy, :16) analysis_fy,
	nullif(pi.attribute1, :16) attribute1,
	nullif(pi.attribute10, :16) attribute10,
	nullif(pi.attribute11, :16) attribute11,
	nullif(pi.attribute12, :16) attribute12,
	nullif(pi.attribute13, :16) attribute13,
	nullif(pi.attribute14, :16) attribute14,
	nullif(pi.attribute15, :16) attribute15,
	nullif(pi.attribute16, :16) attribute16,
	nullif(pi.attribute17, :16) attribute17,
	nullif(pi.attribute18, :16) attribute18,
	nullif(pi.attribute19, :16) attribute19,
	nullif(pi.attribute2, :16) attribute2,
	nullif(pi.attribute20, :16) attribute20,
	nullif(pi.attribute21, :16) attribute21,
	nullif(pi.attribute22, :16) attribute22,
	nullif(pi.attribute23, :16) attribute23,
	nullif(pi.attribute24, :16) attribute24,
	nullif(pi.attribute3, :16) attribute3,
	nullif(pi.attribute4, :16) attribute4,
	nullif(pi.attribute5, :16) attribute5,
	nullif(pi.attribute6, :16) attribute6,
	nullif(pi.attribute7, :16) attribute7,
	nullif(pi.attribute8, :16) attribute8,
	nullif(pi.attribute9, :16) attribute9,
	nullif(pi.attribute_category, :16) attribute_category,
	nullif(pi.branch_flag, :16) branch_flag,
	nullif(pi.business_scope, :16) business_scope,
	nullif(pi.ceo_name, :16) ceo_name,
	nullif(pi.ceo_title, :16) ceo_title,
	nullif(pi.cong_dist_code, :16) cong_dist_code,
	nullif(pi.control_yr, :17) control_yr,
	nullif(pi.corporation_class, :16) corporation_class,
	nullif(pi.created_by_module, :16) created_by_module,
	nullif(pi.curr_fy_potential_revenue, :17) curr_fy_potential_revenue,
	nullif(pi.date_of_birth, :18) date_of_birth,
	nullif(pi.date_of_death, :18) date_of_death,
	nullif(pi.deceased_flag, :16) deceased_flag,
	nullif(pi.declared_ethnicity, :16) declared_ethnicity,
	nullif(pi.disadv_8a_ind, :16) disadv_8a_ind,
	pi.displayed_duns displayed_duns,
	nullif(pi.do_not_confuse_with, :16) do_not_confuse_with,
	nullif(upper(pi.duns_number_c), :16) duns_number_c,
	nullif(pi.emp_at_primary_adr, :16) emp_at_primary_adr,
	nullif(pi.emp_at_primary_adr_est_ind, :16) emp_at_primary_adr_est_ind,
	nullif(pi.emp_at_primary_adr_min_ind, :16) emp_at_primary_adr_min_ind,
	nullif(pi.emp_at_primary_adr_text, :16) emp_at_primary_adr_text,
	nullif(pi.employees_total, :17) employees_total,
	nullif(pi.export_ind, :16) export_ind,
	nullif(pi.fiscal_yearend_month, :16) fiscal_yearend_month,
	nullif(pi.gender, :16) gender,
	nullif(pi.gsa_indicator_flag, :16) gsa_indicator_flag,
	nullif(pi.head_of_household_flag, :16) head_of_household_flag,
	nullif(pi.household_income, :17) household_income,
	nullif(pi.household_size, :17) household_size,
	nullif(pi.hq_branch_ind, :16) hq_branch_ind,
	nullif(pi.import_ind, :16) import_ind,
	nullif(pi.incorp_year, :17) incorp_year,
	nullif(pi.insert_update_flag, :16) insert_update_flag,
	nullif(pi.jgzz_fiscal_code, :16) jgzz_fiscal_code,
	nullif(pi.known_as, :16) known_as,
	nullif(pi.known_as2, :16) known_as2,
	nullif(pi.known_as3, :16) known_as3,
	nullif(pi.known_as4, :16) known_as4,
	nullif(pi.known_as5, :16) known_as5,
	nullif(pi.labor_surplus_ind, :16) labor_surplus_ind,
	nullif(pi.legal_status, :16) legal_status,
	nullif(pi.line_of_business, :16) line_of_business,
	nullif(pi.local_bus_iden_type, :16) local_bus_iden_type,
	nullif(pi.local_bus_identifier, :16) local_bus_identifier,
	nullif(pi.marital_status, :16) marital_status,
	nullif(pi.marital_status_effective_date, :18) marital_status_effective_date,
	nullif(pi.minority_owned_ind, :16) minority_owned_ind,
	nullif(pi.minority_owned_type, :16) minority_owned_type,
	nullif(pi.mission_statement, :16) mission_statement,
	nullif(pi.next_fy_potential_revenue, :17) next_fy_potential_revenue,
	nullif(pi.oob_ind, :16) oob_ind,
	pi.organization_name organization_name,
	nullif(pi.organization_name_phonetic, :16) organization_name_phonetic,
	nullif(pi.organization_type, :16) organization_type,
	nullif(pi.parent_sub_ind, :16) parent_sub_ind,
	ps.party_id party_id,
	pi.party_number party_number,
	pi.party_orig_system party_orig_system,
	pi.party_orig_system_reference party_orig_system_reference,
	pi.party_type party_type,
	nullif(pi.person_academic_title, :16) person_academic_title,
	nullif(pi.person_first_name, :16) person_first_name,
	nullif(pi.person_first_name_phonetic, :16) person_first_name_phonetic,
	nullif(pi.person_iden_type, :16) person_iden_type,
	nullif(pi.person_identifier, :16) person_identifier,
	nullif(pi.person_initials, :16) person_initials,
	nullif(pi.person_last_name, :16) person_last_name,
	nullif(pi.person_last_name_phonetic, :16) person_last_name_phonetic,
	nullif(pi.person_middle_name, :16) person_middle_name,
	nullif(pi.person_middle_name_phonetic, :16) person_middle_name_phonetic,
	nullif(pi.person_name_phonetic, :16) person_name_phonetic,
	nullif(pi.person_name_suffix, :16) person_name_suffix,
	nullif(pi.person_pre_name_adjunct, :16) person_pre_name_adjunct,
	nullif(pi.person_previous_last_name, :16) person_previous_last_name,
	nullif(pi.person_title, :16) person_title,
	nullif(pi.personal_income, :17) personal_income,
	nullif(pi.place_of_birth, :16) place_of_birth,
	nullif(pi.pref_functional_currency, :16) pref_functional_currency,
	nullif(pi.principal_name, :16) principal_name,
	nullif(pi.principal_title, :16) principal_title,
	nullif(pi.public_private_ownership_flag, :16) public_private_ownership_flag,
	nullif(pi.registration_type, :16) registration_type,
	nullif(pi.rent_own_ind, :16) rent_own_ind,
	pi.rowid row_id,
	nullif(pi.salutation, :16) salutation,
	nullif(pi.small_bus_ind, :16) small_bus_ind,
	nullif(pi.tax_reference, :16) tax_reference,
	nullif(pi.total_emp_est_ind, :16) total_emp_est_ind,
	nullif(pi.total_emp_min_ind, :16) total_emp_min_ind,
	nullif(pi.total_employees_ind, :16) total_employees_ind,
	nullif(pi.total_employees_text, :16) total_employees_text,
	nullif(pi.total_payments, :17) total_payments,
	nullif(pi.woman_owned_ind, :16) woman_owned_ind,
	nullif(pi.year_established, :17) year_established,
	nvl2(party_type_l.lookup_code, ''Y'', null) party_type_l,
	nvl2(month_l.lookup_code, ''Y'', null) month_l,
	nvl2(legal_status_l.lookup_code, ''Y'', null) legal_status_l,
	nvl2(local_bus_iden_type_l.lookup_code, ''Y'', null) local_bus_iden_type_l,
	nvl2(reg_type_l.lookup_code, ''Y'', null) reg_type_l,
	nvl2(own_rent_l.lookup_code, ''Y'', null) own_rent_l,
	nvl2(hq_branch_l.lookup_code, ''Y'', null) hq_branch_l,
	nvl2(tot_emp_est_l.lookup_code, ''Y'', null) tot_emp_est_l,
	nvl2(tot_emp_min_l.lookup_code, ''Y'', null) tot_emp_min_l,
	nvl2(tot_emp_ind_l.lookup_code, ''Y'', null) tot_emp_ind_l,
	nvl2(emp_at_pri_adr_est_ind_l.lookup_code, ''Y'', null) emp_at_pri_adr_est_ind_l,
	nvl2(emp_at_pri_adr_min_ind_l.lookup_code, ''Y'', null) emp_at_pri_adr_min_ind_l,
	nvl2(marital_status_l.lookup_code, ''Y'', null) marital_status_l,
	nvl2(contact_title_l.lookup_code, ''Y'', null) contact_title_l,
	nvl2(gender_l.lookup_code, ''Y'', null) gender_l,
	nvl2(person_iden_type_l.lookup_code, ''Y'', null) person_iden_type_l,
        ads.error_flag ads_err_flag,  -- added for bug 6164407
	nvl2(createdby_l.lookup_code, ''Y'', null) createdby_l,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.address1_std,
	  nullif(adi.address1, :16)) address1,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.address2_std,
	  nullif(adi.address2, :16)) address2,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.address3_std,
	  nullif(adi.address3, :16)) address3,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.address4_std,
	  nullif(adi.address4, :16)) address4,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.city_std,
	  nullif(adi.city, :16)) city,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.country_std,
	  nullif(adi.country, :16)) country,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.county_std,
	  nullif(adi.county, :16)) county,
	decode(adi.accept_standardized_flag, ''Y'',
	  adi.postal_code_std,
	  nullif(adi.postal_code, :16)) postal_code,
	decode(adi.accept_standardized_flag, ''Y'',
	 nvl2(adi.province, adi.prov_state_admin_code_std, null),
	  nullif(adi.province, :16)) province,
	decode(adi.accept_standardized_flag, ''Y'',
	 nvl2(adi.state, adi.prov_state_admin_code_std, null),
	  nullif(adi.state, :16)) state,
	substrb(nullif(emaili.email_address, :16),1,320) email_address,
	nullif(webi.url, :16) url,
	nullif(phones.contact_point_id, :17) primary_phone_contact_pt_id,
	nullif(phonei.contact_point_purpose, :16) primary_phone_purpose,
	nullif(phonei.phone_line_type, :16) primary_phone_line_type,
	nullif(phonei.phone_country_code, :16) primary_phone_country_code,
	nullif(phonei.phone_area_code, :16) primary_phone_area_code,
	nullif(phonei.phone_number, :16) primary_phone_number,
	nullif(phonei.phone_extension, :16) primary_phone_extension,
	nullif(cccfi.class_code, :16) category_code,
	case when sicfi.class_category in
	     (''1972 SIC'', ''1977 SIC'', ''1987 SIC'', ''NAICS_1997'')
	then nullif(sicfi.class_category, :16)
	else null end sic_code_type,
	case when sicfi.class_category in
	     (''1972 SIC'', ''1977 SIC'', ''1987 SIC'', ''NAICS_1997'')
	then nullif(sicfi.class_code, :16)
	else null end sic_code,
	nvl2(nullif(nacfi.class_code, :16), 4, null) local_activity_code_type,
	nullif(nacfi.class_code, :16) local_activity_code
  from hz_imp_parties_sg ps,
	hz_imp_parties_int pi,
	hz_imp_addresses_sg ads,
	hz_imp_addresses_int adi,
	hz_imp_contactpts_sg webs,
	hz_imp_contactpts_int webi,
	hz_imp_contactpts_sg emails,
	hz_imp_contactpts_int emaili,
	hz_imp_contactpts_sg phones,
	hz_imp_contactpts_int phonei,
	hz_imp_classifics_sg cccfs,
	hz_imp_classifics_int cccfi,
	hz_imp_classifics_sg nacfs,
	hz_imp_classifics_int nacfi,
	hz_imp_classifics_sg sicfs,
	hz_imp_classifics_int sicfi,
	fnd_lookup_values party_type_l,
	fnd_lookup_values month_l,
	fnd_lookup_values legal_status_l,
	fnd_lookup_values local_bus_iden_type_l,
	fnd_lookup_values reg_type_l,
	fnd_lookup_values own_rent_l,
	fnd_lookup_values hq_branch_l,
	fnd_lookup_values tot_emp_est_l,
	fnd_lookup_values tot_emp_min_l,
	fnd_lookup_values tot_emp_ind_l,
	fnd_lookup_values emp_at_pri_adr_est_ind_l,
	fnd_lookup_values emp_at_pri_adr_min_ind_l,
	fnd_lookup_values marital_status_l,
	fnd_lookup_values contact_title_l,
	fnd_lookup_values gender_l,
	fnd_lookup_values person_iden_type_l,
	fnd_lookup_values createdby_l
 where pi.rowid = ps.int_row_id
   and ps.party_id = ads.party_id(+)
   and ads.batch_id(+) = ps.batch_id
   and ads.primary_flag(+) = ''Y''
   and ads.int_row_id = adi.rowid(+)
   and ads.batch_mode_flag(+) = :19
   and ps.party_id = webs.party_id(+)
   and webs.batch_id(+) = ps.batch_id
   and webs.primary_flag(+) = ''Y''
   and webs.int_row_id = webi.rowid(+)
   and webs.batch_mode_flag(+) = :19
   and webs.contact_point_type(+) = ''WEB''
   and ps.party_id = emails.party_id(+)
   and emails.batch_id(+) = ps.batch_id
   and emails.primary_flag(+) = ''Y''
   and emails.int_row_id = emaili.rowid(+)
   and emails.batch_mode_flag(+) = :19
   and emails.contact_point_type(+) = ''EMAIL''
   and ps.party_id = phones.party_id(+)
   and phones.batch_id(+) = ps.batch_id
   and phones.primary_flag(+) = ''Y''
   and phones.int_row_id = phonei.rowid(+)
   and phones.batch_mode_flag(+) = :19
   and phones.contact_point_type(+) = ''PHONE''
   and ps.party_id = cccfs.party_id(+)
   and cccfi.rowid (+) = cccfs.int_row_id
   and cccfs.primary_flag (+) = ''Y''
   and cccfs.batch_id (+) = ps.batch_id
   and cccfs.batch_mode_flag(+) = :19
   and cccfi.class_category (+) = ''CUSTOMER_CATEGORY''
   and cccfs.class_category (+) = ''CUSTOMER_CATEGORY''
   and ps.party_id = sicfs.party_id(+)
   and sicfi.rowid (+) = sicfs.int_row_id
   and sicfs.primary_flag (+) = ''Y''
   and sicfs.batch_id (+) = ps.batch_id
   and sicfs.batch_mode_flag(+) = :19
   and sicfs.class_category (+)=''SIC''
   and ps.party_id = nacfs.party_id(+)
   and nacfi.rowid (+) = nacfs.int_row_id
   and nacfs.primary_flag (+) = ''Y''
   and nacfs.batch_id (+) = ps.batch_id
   and nacfs.batch_mode_flag(+) = :19
   and nacfi.class_category (+) = ''NACE''
   and nacfs.class_category (+) = ''NACE''
   and party_type_l.lookup_code (+) = pi.party_type
   and party_type_l.lookup_type (+) = ''PARTY_TYPE''
   and party_type_l.language (+) = userenv(''LANG'')
   and party_type_l.view_application_id (+) = 222
   and party_type_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''PARTY_TYPE'', 222)
   and month_l.lookup_code (+) = pi.fiscal_yearend_month
   and month_l.lookup_type (+) = ''MONTH''
   and month_l.language (+) = userenv(''LANG'')
   and month_l.view_application_id (+) = 222
   and month_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''MONTH'', 222)
   and legal_status_l.lookup_code (+) = pi.legal_status
   and legal_status_l.lookup_type (+) = ''LEGAL_STATUS''
   and legal_status_l.language (+) = userenv(''LANG'')
   and legal_status_l.view_application_id (+) = 222
   and legal_status_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''LEGAL_STATUS'', 222)
   and local_bus_iden_type_l.lookup_code (+) = pi.local_bus_iden_type
   and local_bus_iden_type_l.lookup_type (+) = ''LOCAL_BUS_IDEN_TYPE''
   and local_bus_iden_type_l.language (+) = userenv(''LANG'')
   and local_bus_iden_type_l.view_application_id (+) = 222
   and local_bus_iden_type_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''LOCAL_BUS_IDEN_TYPE'', 222)
   and reg_type_l.lookup_code (+) = pi.registration_type
   and reg_type_l.lookup_type (+) = ''REGISTRATION_TYPE''
   and reg_type_l.language (+) = userenv(''LANG'')
   and reg_type_l.view_application_id (+) = 222
   and reg_type_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''REGISTRATION_TYPE'', 222)
   and own_rent_l.lookup_code (+) = pi.rent_own_ind
   and own_rent_l.lookup_type (+) = ''OWN_RENT_IND''
   and own_rent_l.language (+) = userenv(''LANG'')
   and own_rent_l.view_application_id (+) = 222
   and own_rent_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''OWN_RENT_IND'', 222)
   and hq_branch_l.lookup_code (+) = pi.hq_branch_ind
   and hq_branch_l.lookup_type (+) = ''HQ_BRANCH_IND''
   and hq_branch_l.language (+) = userenv(''LANG'')
   and hq_branch_l.view_application_id (+) = 222
   and hq_branch_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HQ_BRANCH_IND'', 222)
   and tot_emp_est_l.lookup_code (+) = pi.total_emp_est_ind
   and tot_emp_est_l.lookup_type (+) = ''TOTAL_EMP_EST_IND''
   and tot_emp_est_l.language (+) = userenv(''LANG'')
   and tot_emp_est_l.view_application_id (+) = 222
   and tot_emp_est_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''TOTAL_EMP_EST_IND'', 222)
   and tot_emp_min_l.lookup_code (+) = pi.total_emp_min_ind
   and tot_emp_min_l.lookup_type (+) = ''TOTAL_EMP_MIN_IND''
   and tot_emp_min_l.language (+) = userenv(''LANG'')
   and tot_emp_min_l.view_application_id (+) = 222
   and tot_emp_min_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''TOTAL_EMP_MIN_IND'', 222)
   and tot_emp_ind_l.lookup_code (+) = pi.total_employees_ind
   and tot_emp_ind_l.lookup_type (+) = ''TOTAL_EMPLOYEES_INDICATOR''
   and tot_emp_ind_l.language (+) = userenv(''LANG'')
   and tot_emp_ind_l.view_application_id (+) = 222
   and tot_emp_ind_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''TOTAL_EMPLOYEES_INDICATOR'', 222)
   and emp_at_pri_adr_est_ind_l.lookup_code (+) = pi.emp_at_primary_adr_est_ind
   and emp_at_pri_adr_est_ind_l.lookup_type (+) = ''EMP_AT_PRIMARY_ADR_EST_IND''
   and emp_at_pri_adr_est_ind_l.language (+) = userenv(''LANG'')
   and emp_at_pri_adr_est_ind_l.view_application_id (+) = 222
   and emp_at_pri_adr_est_ind_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''EMP_AT_PRIMARY_ADR_EST_IND'', 222)
   and emp_at_pri_adr_min_ind_l.lookup_code (+) = pi.emp_at_primary_adr_min_ind
   and emp_at_pri_adr_min_ind_l.lookup_type (+) = ''EMP_AT_PRIMARY_ADR_MIN_IND''
   and emp_at_pri_adr_min_ind_l.language (+) = userenv(''LANG'')
   and emp_at_pri_adr_min_ind_l.view_application_id (+) = 222
   and emp_at_pri_adr_min_ind_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''EMP_AT_PRIMARY_ADR_MIN_IND'', 222)
   and marital_status_l.lookup_code (+) = pi.marital_status
   and marital_status_l.lookup_type (+) = ''MARITAL_STATUS''
   and marital_status_l.language (+) = userenv(''LANG'')
   and marital_status_l.view_application_id (+) = 222
   and marital_status_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''MARITAL_STATUS'', 222)
   and contact_title_l.lookup_code (+) = pi.person_pre_name_adjunct
   and contact_title_l.lookup_type (+) = ''CONTACT_TITLE''
   and contact_title_l.language (+) = userenv(''LANG'')
   and contact_title_l.view_application_id (+) = 222
   and contact_title_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''CONTACT_TITLE'', 222)
   and gender_l.lookup_code (+) = pi.gender
   and gender_l.lookup_type (+) = ''HZ_GENDER''
   and gender_l.language (+) = userenv(''LANG'')
   and gender_l.view_application_id (+) = 222
   and gender_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_GENDER'', 222)
   and person_iden_type_l.lookup_code (+) = pi.person_iden_type
   and person_iden_type_l.lookup_type (+) = ''HZ_PERSON_IDEN_TYPE''
   and person_iden_type_l.language (+) = userenv(''LANG'')
   and person_iden_type_l.view_application_id (+) = 222
   and person_iden_type_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_PERSON_IDEN_TYPE'', 222)
   and createdby_l.lookup_code (+) = pi.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and ps.batch_id = :12
   and ps.party_orig_system = :20
   and ps.party_orig_system_reference between :21 and :22
   and ps.batch_mode_flag = :19
   and ps.action_flag = ''I''';


  l_where_first_run_sql varchar2(35) := ' AND pi.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND pi.interface_status = ''C''';

  l_where_enabled_lookup_sql varchar2(4000) :=
	' AND  ( party_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( party_type_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( party_type_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( month_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( month_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( month_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( legal_status_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( legal_status_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( legal_status_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( local_bus_iden_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( local_bus_iden_type_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( local_bus_iden_type_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( reg_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( reg_type_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( reg_type_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( own_rent_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( own_rent_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( own_rent_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( hq_branch_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( hq_branch_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( hq_branch_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( tot_emp_est_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( tot_emp_est_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( tot_emp_est_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( tot_emp_min_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( tot_emp_min_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( tot_emp_min_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( tot_emp_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( tot_emp_ind_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( tot_emp_ind_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( emp_at_pri_adr_est_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( emp_at_pri_adr_est_ind_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( emp_at_pri_adr_est_ind_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( emp_at_pri_adr_min_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( emp_at_pri_adr_min_ind_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( emp_at_pri_adr_min_ind_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( marital_status_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( marital_status_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( marital_status_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( contact_title_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( contact_title_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( contact_title_l.END_DATE_ACTIVE,:3 ) ) )
	AND  ( gender_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( gender_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( gender_l.END_DATE_ACTIVE,:3 ) ) )
 	AND  ( person_iden_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( person_iden_type_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( person_iden_type_l.END_DATE_ACTIVE,:3 ) ) )
 	AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:3) BETWEEN
	  TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:3 ) ) AND
	  TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:3 ) ) )';

  l_dml_exception varchar2(1) := 'N';
  l_debug_prefix    VARCHAR2(30) := '';
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:process_insert_parties()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  savepoint process_insert_parties_pvt;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN

    IF P_DML_RECORD.RERUN = 'N' /*** First Run     ***/ THEN

      EXECUTE IMMEDIATE
	'begin ' || l_s1 || l_s2 || l_s3 || l_s4 || l_s5 || l_s6 || l_s7 || l_s8 || l_s9 ||
	l_where_first_run_sql || ') a); end;'
	using
	p_dml_record.application_id,
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.actual_content_src,
	l_org_mixnmatch_enabled,
	l_per_mixnmatch_enabled,
	p_dml_record.batch_id,
	l_actual_content_source,
	l_content_source_type,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_char,
	p_dml_record.gmiss_num,
	p_dml_record.gmiss_date,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    ELSE /* Rerun to correct errors */

      EXECUTE IMMEDIATE
	'begin ' || l_s1 || l_s2 || l_s3 || l_s4 || l_s5 || l_s6 || l_s7 || l_s8 || l_s9 ||
	l_where_rerun_sql || ') a); end;'
	using
	p_dml_record.application_id,
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.actual_content_src,
	l_org_mixnmatch_enabled,
	l_per_mixnmatch_enabled,
	p_dml_record.batch_id,
	l_actual_content_source,
	l_content_source_type,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_char,
	p_dml_record.gmiss_num,
	p_dml_record.gmiss_date,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    END IF;
  ELSE
    IF P_DML_RECORD.RERUN = 'N' /*** First Run     ***/ THEN

      EXECUTE IMMEDIATE
	'begin ' || l_s1 || l_s2 || l_s3 || l_s4 || l_s5 || l_s6 || l_s7 || l_s8 ||  l_s9 ||
	l_where_first_run_sql || l_where_enabled_lookup_sql || ')); end;'
	using
	p_dml_record.application_id,
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.actual_content_src,
	l_org_mixnmatch_enabled,
	l_per_mixnmatch_enabled,
	p_dml_record.batch_id,
	l_actual_content_source,
	l_content_source_type,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_char,
	p_dml_record.gmiss_num,
	p_dml_record.gmiss_date,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    ELSE /* Rerun to correct errors */

      EXECUTE IMMEDIATE
	'begin ' || l_s1 || l_s2 || l_s3 || l_s4 || l_s5 || l_s6 || l_s7 || l_s8 ||  l_s9 ||
	l_where_rerun_sql || l_where_enabled_lookup_sql || ')); end;'
	using
	p_dml_record.application_id,
	p_dml_record.user_id,
	p_dml_record.sysdate,
	p_dml_record.last_update_login,
	p_dml_record.program_application_id,
	p_dml_record.program_id,
	p_dml_record.request_id,
	p_dml_record.actual_content_src,
	l_org_mixnmatch_enabled,
	l_per_mixnmatch_enabled,
	p_dml_record.batch_id,
	l_actual_content_source,
	l_content_source_type,
	p_dml_record.flex_validation,
	p_dml_record.gmiss_char,
	p_dml_record.gmiss_num,
	p_dml_record.gmiss_date,
	p_dml_record.batch_mode_flag,
	p_dml_record.os,
	p_dml_record.from_osr,
	p_dml_record.to_osr;

    END IF;
  END IF;

  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'PTY:Rows inserted in MTI = ' || SQL%ROWCOUNT,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:process_insert_parties()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert parties dup val exception: ' || SQLERRM);
        ROLLBACK to process_insert_parties_pvt;

        populate_error_table(P_DML_RECORD, 'Y', SQLERRM);

        x_return_status := FND_API.G_RET_STS_ERROR;

        -- HZ_PARTIES_PK, HZ_PARTIES_U2
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert parties other exception: ' || SQLERRM);
        ROLLBACK to process_insert_parties_pvt;

        populate_error_table(P_DML_RECORD, 'N', SQLERRM);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END process_insert_parties;


/********************************************************************************
 *
 *	process_update_parties
 *
 ********************************************************************************/

PROCEDURE process_update_parties (
  P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  l_acs varchar2(30);
  c_handle_update RefCurType;
  l_debug_prefix    VARCHAR2(30) := '';
  --l_prof_version VARCHAR2(1000) := P_DML_RECORD.PROFILE_VERSION;

  l_update_sql varchar2(32767) :=
	'SELECT /*+ index(p, HZ_PARTIES_U1) use_nl(pi
	party_type_l month_l legal_status_l local_bus_iden_type_l reg_type_l
	own_rent_l hq_branch_l tot_emp_est_l tot_emp_min_l tot_emp_ind_l
	emp_at_pri_adr_est_ind_l emp_at_pri_adr_min_ind_l marital_status_l
	contact_title_l gender_l person_iden_type_l) */
	pi.ROWID,
	pi.PARTY_ORIG_SYSTEM,
	pi.PARTY_ORIG_SYSTEM_REFERENCE,
	nvl(pi.INSERT_UPDATE_FLAG, ''U''),
	p.PARTY_TYPE,
	pi.PARTY_NUMBER,
	pi.SALUTATION,
	pi.ATTRIBUTE_CATEGORY,
	pi.ATTRIBUTE1,
	pi.ATTRIBUTE2,
	pi.ATTRIBUTE3,
	pi.ATTRIBUTE4,
	pi.ATTRIBUTE5,
	pi.ATTRIBUTE6,
	pi.ATTRIBUTE7,
	pi.ATTRIBUTE8,
	pi.ATTRIBUTE9,
	pi.ATTRIBUTE10,
	pi.ATTRIBUTE11,
	pi.ATTRIBUTE12,
	pi.ATTRIBUTE13,
	pi.ATTRIBUTE14,
	pi.ATTRIBUTE15,
	pi.ATTRIBUTE16,
	pi.ATTRIBUTE17,
	pi.ATTRIBUTE18,
	pi.ATTRIBUTE19,
	pi.ATTRIBUTE20,
	pi.ATTRIBUTE21,
	pi.ATTRIBUTE22,
	pi.ATTRIBUTE23,
	pi.ATTRIBUTE24,
	pi.ORGANIZATION_NAME,
	pi.ORGANIZATION_NAME_PHONETIC,
	pi.ORGANIZATION_TYPE,
	pi.ANALYSIS_FY,
	pi.BRANCH_FLAG,
	pi.BUSINESS_SCOPE,
	pi.CEO_NAME,
	pi.CEO_TITLE,
	pi.CONG_DIST_CODE,
	pi.CONTROL_YR,
	pi.CORPORATION_CLASS,
	pi.CURR_FY_POTENTIAL_REVENUE,
	pi.NEXT_FY_POTENTIAL_REVENUE,
	pi.PREF_FUNCTIONAL_CURRENCY,
	pi.DISADV_8A_IND,
	pi.DO_NOT_CONFUSE_WITH,
	case when upper(pi.DUNS_NUMBER_C) is not null
             and lengthb(pi.duns_number_c)<9
             then upper(lpad(pi.duns_number_c,9,''0''))
             else upper(pi.duns_number_c) end duns_number_c,
	pi.EMP_AT_PRIMARY_ADR,
	pi.EMP_AT_PRIMARY_ADR_EST_IND,
	pi.EMP_AT_PRIMARY_ADR_MIN_IND,
	pi.EMP_AT_PRIMARY_ADR_TEXT,
	pi.EMPLOYEES_TOTAL,
	pi.DISPLAYED_DUNS,
	pi.EXPORT_IND,
	pi.BRANCH_FLAG,
	pi.FISCAL_YEAREND_MONTH,
	pi.GSA_INDICATOR_FLAG,
	pi.HQ_BRANCH_IND,
	pi.IMPORT_IND,
	pi.INCORP_YEAR,
	pi.JGZZ_FISCAL_CODE,
	pi.TAX_REFERENCE,
	pi.KNOWN_AS,
	pi.KNOWN_AS2,
	pi.KNOWN_AS3,
	pi.KNOWN_AS4,
	pi.KNOWN_AS5,
	pi.LABOR_SURPLUS_IND,
	pi.LEGAL_STATUS,
	pi.LINE_OF_BUSINESS,
	pi.LOCAL_BUS_IDENTIFIER,
	pi.LOCAL_BUS_IDEN_TYPE,
	pi.MINORITY_OWNED_IND,
	pi.MINORITY_OWNED_TYPE,
	pi.MISSION_STATEMENT,
	pi.OOB_IND,
	pi.PARENT_SUB_IND,
	pi.PRINCIPAL_NAME,
	pi.PRINCIPAL_TITLE,
	pi.PUBLIC_PRIVATE_OWNERSHIP_FLAG,
	pi.REGISTRATION_TYPE,
	pi.RENT_OWN_IND,
	pi.SMALL_BUS_IND,
	pi.TOTAL_EMP_EST_IND,
	pi.TOTAL_EMP_MIN_IND,
	pi.TOTAL_EMPLOYEES_IND,
	pi.TOTAL_EMPLOYEES_TEXT,
	pi.TOTAL_PAYMENTS,
	pi.WOMAN_OWNED_IND,
	pi.YEAR_ESTABLISHED,
	pi.PERSON_FIRST_NAME,
	pi.PERSON_LAST_NAME,
	pi.PERSON_MIDDLE_NAME,
	pi.PERSON_INITIALS,
	pi.PERSON_NAME_SUFFIX,
	pi.PERSON_PRE_NAME_ADJUNCT,
	pi.PERSON_PREVIOUS_LAST_NAME,
	pi.PERSON_TITLE,
	pi.PERSON_FIRST_NAME_PHONETIC,
	pi.PERSON_LAST_NAME_PHONETIC,
	pi.PERSON_MIDDLE_NAME_PHONETIC,
	pi.PERSON_NAME_PHONETIC,
	pi.PERSON_ACADEMIC_TITLE,
	pi.DATE_OF_BIRTH,
	pi.PLACE_OF_BIRTH,
	pi.DATE_OF_DEATH,
	nvl(pi.deceased_flag,nvl2(nullif(to_char(pi.DATE_OF_DEATH),to_char(:G_MISS_DATE)), ''Y'', ''N'')) ,
	pi.DECLARED_ETHNICITY,
	pi.GENDER,
	pi.HEAD_OF_HOUSEHOLD_FLAG,
	pi.HOUSEHOLD_INCOME,
	pi.HOUSEHOLD_SIZE,
	pi.MARITAL_STATUS,
	pi.MARITAL_STATUS_EFFECTIVE_DATE,
	pi.PERSON_IDEN_TYPE,
	pi.PERSON_IDENTIFIER,
	pi.PERSONAL_INCOME,
	pi.INTERFACE_STATUS,
	nvl(decode(pi.party_type,''ORGANIZATION'',op.created_by_module,pp.created_by_module),
            nvl(pi.CREATED_BY_MODULE, ''HZ_IMPORT'')),
	decode(pi.PARTY_TYPE, null, ''Y'', :G_MISS_CHAR, null, ''PARTY_RELATIONSHIP'', null, ''GROUP'', null,
	  party_type_l.lookup_code) party_type_error,
	decode(nvl(pi.insert_update_flag, ps.action_flag), ps.action_flag, ''Y'', null) action_mismatch_error,
	0 flex_val_errors,
	''T'' dss_security_errors,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.FISCAL_YEAREND_MONTH, null, ''Y'', :G_MISS_CHAR, ''Y'', month_l.lookup_code)) month_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.LEGAL_STATUS, null, ''Y'', :G_MISS_CHAR, ''Y'', legal_status_l.lookup_code)) legal_status_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.LOCAL_BUS_IDEN_TYPE, null, ''Y'', :G_MISS_CHAR, ''Y'', local_bus_iden_type_l.lookup_code)) local_bus_iden_type_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.REGISTRATION_TYPE, null, ''Y'', :G_MISS_CHAR, ''Y'', reg_type_l.lookup_code)) reg_type_error,
	decode(pi.RENT_OWN_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', own_rent_l.lookup_code) own_rent_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.HQ_BRANCH_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', hq_branch_l.lookup_code)) hq_branch_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.MINORITY_OWNED_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) minority_owned_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.GSA_INDICATOR_FLAG, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) gsa_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.IMPORT_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) import_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.EXPORT_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) export_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.BRANCH_FLAG, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) branch_flag_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.DISADV_8A_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) disadv_8a_ind_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.LABOR_SURPLUS_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) labor_surplus_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.OOB_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) oob_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.PARENT_SUB_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) parent_sub_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.PUBLIC_PRIVATE_OWNERSHIP_FLAG, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) pub_ownership_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.SMALL_BUS_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) small_bus_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.TOTAL_EMP_EST_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', tot_emp_est_l.lookup_code)) tot_emp_est_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.TOTAL_EMP_MIN_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', tot_emp_min_l.lookup_code)) tot_emp_min_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.TOTAL_EMPLOYEES_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', tot_emp_ind_l.lookup_code)) tot_emp_ind_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.WOMAN_OWNED_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) woman_own_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.EMP_AT_PRIMARY_ADR_EST_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', emp_at_pri_adr_est_ind_l.lookup_code)) emp_at_pri_adr_est_ind_error,
	decode(p.PARTY_TYPE, ''PERSON'', ''Y'',
	  decode(pi.EMP_AT_PRIMARY_ADR_MIN_IND, null, ''Y'', :G_MISS_CHAR, ''Y'', emp_at_pri_adr_min_ind_l.lookup_code)) emp_at_pri_adr_min_ind_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.MARITAL_STATUS, null, ''Y'', :G_MISS_CHAR, ''Y'', marital_status_l.lookup_code)) marital_status_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.GENDER, null, ''Y'', :G_MISS_CHAR, ''Y'', gender_l.lookup_code)) gender_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.PERSON_IDEN_TYPE, null, ''Y'', :G_MISS_CHAR, ''Y'', person_iden_type_l.lookup_code)) person_iden_type_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.PERSON_PRE_NAME_ADJUNCT, null, ''Y'', :G_MISS_CHAR, ''Y'', contact_title_l.lookup_code)) contact_title_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.DATE_OF_DEATH,
	  null, decode(pi.DECEASED_FLAG,
	  null, ''X'', ''Y'', ''X'',
	  decode(pp.DATE_OF_DEATH, null, ''X'', null)),
	  :G_MISS_DATE, ''X'',
	  decode(pi.DECEASED_FLAG,
	  null, ''X'',
	  ''Y'', ''X'',
	  ''N'', null)
	  )) deceased_flag_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.HEAD_OF_HOUSEHOLD_FLAG, null, ''Y'', :G_MISS_CHAR, ''Y'', ''Y'', ''Y'', ''N'', ''N'', null)) head_of_household_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.DATE_OF_BIRTH, null, ''Y'', :G_MISS_DATE, ''Y'', decode(sign(pi.DATE_OF_BIRTH - sysdate), 1, null, ''Y''))) birth_date_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.DATE_OF_DEATH, null, ''Y'', :G_MISS_DATE, ''Y'', decode(sign(pi.DATE_OF_DEATH - sysdate), 1, null, ''Y''))) death_date_error,
	decode(p.PARTY_TYPE, ''ORGANIZATION'', ''Y'',
	  decode(pi.DATE_OF_DEATH,
	  null,
	  decode(pp.DATE_OF_DEATH, null, ''Y'',
	  decode(pi.DATE_OF_BIRTH, null, decode(sign(pp.DATE_OF_DEATH - pp.DATE_OF_BIRTH), -1, null, ''Y''),
	  decode(sign(pp.DATE_OF_DEATH - pi.DATE_OF_BIRTH), -1, null, ''Y''))),
	  :G_MISS_DATE, ''Y'',
	  decode(pi.DATE_OF_BIRTH, null, decode(sign(pi.DATE_OF_DEATH - pp.DATE_OF_BIRTH), -1, null, ''Y''),
	  decode(sign(pi.DATE_OF_DEATH - pi.DATE_OF_BIRTH), -1, null, ''Y''))
	  )) birth_death_error,
	  decode(p.PARTY_TYPE, ''ORGANIZATION'',
		decode(pi.ORGANIZATION_NAME, null, p.PARTY_NAME, :G_MISS_CHAR, null, pi.ORGANIZATION_NAME),
		''PERSON'',
		decode(pi.PERSON_FIRST_NAME, null, pp.PERSON_FIRST_NAME, :G_MISS_CHAR, null, pi.PERSON_FIRST_NAME) ||
		decode(pi.PERSON_FIRST_NAME, :G_MISS_CHAR, null,
		  null, decode(pp.PERSON_FIRST_NAME, null, null,
		    decode(pi.PERSON_LAST_NAME, :G_MISS_CHAR, null,
		      null, decode(pp.PERSON_LAST_NAME, null, null, '' ''), '' '')),
		  decode(pi.PERSON_LAST_NAME, :G_MISS_CHAR, null,
		      null, decode(pp.PERSON_LAST_NAME, null, null, '' ''), '' '')) ||
		decode(pi.PERSON_LAST_NAME, null, pp.PERSON_LAST_NAME, :G_MISS_CHAR, null, pi.PERSON_LAST_NAME)
		) party_name,
	  nvl2(decode(pi.party_type,''ORGANIZATION'',op.created_by_module,pp.created_by_module),
               ''Y'',
               decode(pi.created_by_module,null,''Y'',
                      :G_MISS_CHAR,''Y'',
                      nvl2(ps.old_orig_system_reference,
                           nvl2(createdby_l.lookup_code,''Y'',null),
                           nvl2(ps.new_osr_exists_flag,
                                nvl2(createdby_l.lookup_code,''Y'',null),
                                decode(:l_prof_version /*P_DML_RECORD.PROFILE_VERSION*/,
                                       ''NEW_VERSION'',nvl2(createdby_l.lookup_code,''Y'',null),
                                       ''ONE_DAY_VERSION'',
                                       decode(sign(trunc(pp.effective_start_date)-trunc(:l_sysdate))
                                              ,-1,nvl2(createdby_l.lookup_code,''Y'',null),''Y''),
                                        ''Y''
                                        )
                                )
                          )
                       )
              ) createdby_error,
	 decode(:l_party_profile,
                ''N'',nvl2(nullif(decode(pi.party_type,''ORGANIZATION'',pi.organization_name,
                                         ''PERSON'',pi.person_first_name||'' ''||pi.person_last_name)
                                  ,p.party_name)
                           ,null,''Y''),
                ''Y'') party_name_update_error,
         pi.PERSON_TITLE ||
	  decode(pi.PERSON_TITLE, null, null, '' '') ||
	  pi.PERSON_FIRST_NAME ||
	  decode(pi.PERSON_FIRST_NAME, null, null, decode(pi.PERSON_MIDDLE_NAME, null, decode(pi.PERSON_LAST_NAME, null, null, '' ''), '' '')) ||
	  pi.PERSON_MIDDLE_NAME ||
	  decode(pi.PERSON_MIDDLE_NAME, null, null, decode(pi.PERSON_LAST_NAME, null, null, '' '')) ||
	  pi.PERSON_LAST_NAME ||
	  decode(pi.PERSON_NAME_SUFFIX, null, null, '' '') ||
	  pi.PERSON_NAME_SUFFIX  person_name,
	p.party_id tca_party_id,
	p.status status,
	ps.party_id,
	ps.new_osr_exists_flag,
	ps.old_orig_system_reference
      FROM HZ_IMP_PARTIES_INT pi, HZ_IMP_PARTIES_SG ps, HZ_PARTIES p,
	HZ_PERSON_PROFILES pp,
        HZ_ORGANIZATION_PROFILES op,
	fnd_lookup_values party_type_l,
	fnd_lookup_values month_l,
	fnd_lookup_values legal_status_l,
	fnd_lookup_values local_bus_iden_type_l,
	fnd_lookup_values reg_type_l,
	fnd_lookup_values own_rent_l,
	fnd_lookup_values hq_branch_l,
	fnd_lookup_values tot_emp_est_l,
	fnd_lookup_values tot_emp_min_l,
	fnd_lookup_values tot_emp_ind_l,
	fnd_lookup_values emp_at_pri_adr_est_ind_l,
	fnd_lookup_values emp_at_pri_adr_min_ind_l,
	fnd_lookup_values marital_status_l,
	fnd_lookup_values contact_title_l,
	fnd_lookup_values gender_l,
	fnd_lookup_values person_iden_type_l,
	fnd_lookup_values createdby_l
      WHERE
	pi.rowid = ps.int_row_id
	AND ps.party_id = p.party_id(+)
	AND ps.party_id = pp.party_id(+)
	AND pp.effective_end_date is null
	AND pp.actual_content_source(+) = :l_actual_content_source
	AND ps.party_id = op.party_id(+)
	AND op.effective_end_date is null
	AND op.actual_content_source(+) = :l_actual_content_source
	AND party_type_l.lookup_code (+) = pi.party_type
	AND party_type_l.lookup_type (+) = ''PARTY_TYPE''
	AND party_type_l.language (+) = userenv(''LANG'')
	AND party_type_l.view_application_id (+) = 222
	AND party_type_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''PARTY_TYPE'', 222)
	AND month_l.lookup_code (+) = pi.fiscal_yearend_month
	AND month_l.lookup_type (+) = ''MONTH''
	AND month_l.language (+) = userenv(''LANG'')
	AND month_l.view_application_id (+) = 222
	AND month_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''MONTH'', 222)
	AND legal_status_l.lookup_code (+) = pi.legal_status
	AND legal_status_l.lookup_type (+) = ''LEGAL_STATUS''
	AND legal_status_l.language (+) = userenv(''LANG'')
	AND legal_status_l.view_application_id (+) = 222
	AND legal_status_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''LEGAL_STATUS'', 222)
	AND local_bus_iden_type_l.lookup_code (+) = pi.local_bus_iden_type
	AND local_bus_iden_type_l.lookup_type (+) = ''LOCAL_BUS_IDEN_TYPE''
	AND local_bus_iden_type_l.language (+) = userenv(''LANG'')
	AND local_bus_iden_type_l.view_application_id (+) = 222
	AND local_bus_iden_type_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''LOCAL_BUS_IDEN_TYPE'', 222)
	AND reg_type_l.lookup_code (+) = pi.registration_type
	AND reg_type_l.lookup_type (+) = ''REGISTRATION_TYPE''
	AND reg_type_l.language (+) = userenv(''LANG'')
	AND reg_type_l.view_application_id (+) = 222
	AND reg_type_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''REGISTRATION_TYPE'', 222)
	AND own_rent_l.lookup_code (+) = pi.rent_own_ind
	AND own_rent_l.lookup_type (+) = ''OWN_RENT_IND''
	AND own_rent_l.language (+) = userenv(''LANG'')
	AND own_rent_l.view_application_id (+) = 222
	AND own_rent_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''OWN_RENT_IND'', 222)
	AND hq_branch_l.lookup_code (+) = pi.hq_branch_ind
	AND hq_branch_l.lookup_type (+) = ''HQ_BRANCH_IND''
	AND hq_branch_l.language (+) = userenv(''LANG'')
	AND hq_branch_l.view_application_id (+) = 222
	AND hq_branch_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''HQ_BRANCH_IND'', 222)
	AND tot_emp_est_l.lookup_code (+) = pi.total_emp_est_ind
	AND tot_emp_est_l.lookup_type (+) = ''TOTAL_EMP_EST_IND''
	AND tot_emp_est_l.language (+) = userenv(''LANG'')
	AND tot_emp_est_l.view_application_id (+) = 222
	AND tot_emp_est_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''TOTAL_EMP_EST_IND'', 222)
	AND tot_emp_min_l.lookup_code (+) = pi.total_emp_min_ind
	AND tot_emp_min_l.lookup_type (+) = ''TOTAL_EMP_MIN_IND''
	AND tot_emp_min_l.language (+) = userenv(''LANG'')
	AND tot_emp_min_l.view_application_id (+) = 222
	AND tot_emp_min_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''TOTAL_EMP_MIN_IND'', 222)
	AND tot_emp_ind_l.lookup_code (+) = pi.total_employees_ind
	AND tot_emp_ind_l.lookup_type (+) = ''TOTAL_EMPLOYEES_INDICATOR''
	AND tot_emp_ind_l.language (+) = userenv(''LANG'')
	AND tot_emp_ind_l.view_application_id (+) = 222
	AND tot_emp_ind_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''TOTAL_EMPLOYEES_INDICATOR'', 222)
	AND emp_at_pri_adr_est_ind_l.lookup_code (+) = pi.emp_at_primary_adr_est_ind
	AND emp_at_pri_adr_est_ind_l.lookup_type (+) = ''EMP_AT_PRIMARY_ADR_EST_IND''
	AND emp_at_pri_adr_est_ind_l.language (+) = userenv(''LANG'')
	AND emp_at_pri_adr_est_ind_l.view_application_id (+) = 222
	AND emp_at_pri_adr_est_ind_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''EMP_AT_PRIMARY_ADR_EST_IND'', 222)
	AND emp_at_pri_adr_min_ind_l.lookup_code (+) = pi.emp_at_primary_adr_min_ind
	AND emp_at_pri_adr_min_ind_l.lookup_type (+) = ''EMP_AT_PRIMARY_ADR_MIN_IND''
	AND emp_at_pri_adr_min_ind_l.language (+) = userenv(''LANG'')
	AND emp_at_pri_adr_min_ind_l.view_application_id (+) = 222
	AND emp_at_pri_adr_min_ind_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''EMP_AT_PRIMARY_ADR_MIN_IND'', 222)
	AND marital_status_l.lookup_code (+) = pi.marital_status
	AND marital_status_l.lookup_type (+) = ''MARITAL_STATUS''
	AND marital_status_l.language (+) = userenv(''LANG'')
	AND marital_status_l.view_application_id (+) = 222
	AND marital_status_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''MARITAL_STATUS'', 222)
	AND contact_title_l.lookup_code (+) = pi.person_pre_name_adjunct
	AND contact_title_l.lookup_type (+) = ''CONTACT_TITLE''
	AND contact_title_l.language (+) = userenv(''LANG'')
	AND contact_title_l.view_application_id (+) = 222
	AND contact_title_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''CONTACT_TITLE'', 222)
	AND gender_l.lookup_code (+) = pi.gender
	AND gender_l.lookup_type (+) = ''HZ_GENDER''
	AND gender_l.language (+) = userenv(''LANG'')
	AND gender_l.view_application_id (+) = 222
	AND gender_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''HZ_GENDER'', 222)
	AND person_iden_type_l.lookup_code (+) = pi.person_iden_type
	AND person_iden_type_l.lookup_type (+) = ''HZ_PERSON_IDEN_TYPE''
	AND person_iden_type_l.language (+) = userenv(''LANG'')
	AND person_iden_type_l.view_application_id (+) = 222
	AND person_iden_type_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''HZ_PERSON_IDEN_TYPE'', 222)
	AND createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
	AND createdby_l.lookup_code (+) = pi.created_by_module
	AND createdby_l.language (+) = userenv(''LANG'')
	AND createdby_l.view_application_id (+) = 222
	AND createdby_l.security_group_id (+) =
	  fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
	AND ps.batch_id = :P_BATCH_ID
	AND ps.party_orig_system = :P_OS
	AND ps.party_orig_system_reference between :P_FROM_OSR and :P_TO_OSR
	AND ps.batch_mode_flag = :P_BATCH_MODE_FLAG
	AND ps.ACTION_FLAG = ''U''';

  l_where_first_run_sql varchar2(35) := ' AND pi.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND pi.interface_status = ''C''';

  l_where_enabled_lookup_sql varchar2(4000) :=
	' AND  ( party_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( party_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( party_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( month_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( month_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( month_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( legal_status_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( legal_status_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( legal_status_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( local_bus_iden_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( local_bus_iden_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( local_bus_iden_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( reg_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( reg_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( reg_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( own_rent_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( own_rent_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( own_rent_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( hq_branch_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( hq_branch_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( hq_branch_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( tot_emp_est_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( tot_emp_est_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( tot_emp_est_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( tot_emp_min_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( tot_emp_min_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( tot_emp_min_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( tot_emp_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( tot_emp_ind_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( tot_emp_ind_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( emp_at_pri_adr_est_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( emp_at_pri_adr_est_ind_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( emp_at_pri_adr_est_ind_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( emp_at_pri_adr_min_ind_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( emp_at_pri_adr_min_ind_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( emp_at_pri_adr_min_ind_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( marital_status_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( marital_status_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( marital_status_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( contact_title_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( contact_title_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( contact_title_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( gender_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( gender_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( gender_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( person_iden_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( person_iden_type_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( person_iden_type_l.END_DATE_ACTIVE,:l_sysdate ) ) )
	AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:l_sysdate) BETWEEN
	  TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
	  TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:l_sysdate ) ) )';

  l_dml_exception varchar2(1) := 'N';

  l_insert_org_profile varchar2(10000) :=
	'insert into hz_organization_profiles op1
	(
	  ORGANIZATION_PROFILE_ID,
	  PARTY_ID,
	  ORGANIZATION_NAME,
	  CEO_NAME,
	  CEO_TITLE,
	  PRINCIPAL_NAME,
	  PRINCIPAL_TITLE,
	  LEGAL_STATUS,
	  CONTROL_YR,
	  EMPLOYEES_TOTAL,
	  HQ_BRANCH_IND,
	  OOB_IND,
	  LINE_OF_BUSINESS,
	  CONG_DIST_CODE,
	  IMPORT_IND,
	  EXPORT_IND,
	  BRANCH_FLAG,
	  LABOR_SURPLUS_IND,
	  MINORITY_OWNED_IND,
	  MINORITY_OWNED_TYPE,
	  WOMAN_OWNED_IND,
	  DISADV_8A_IND,
	  SMALL_BUS_IND,
	  RENT_OWN_IND,
	  ORGANIZATION_NAME_PHONETIC,
	  TAX_REFERENCE,
	  GSA_INDICATOR_FLAG,
	  JGZZ_FISCAL_CODE,
	  ANALYSIS_FY,
	  FISCAL_YEAREND_MONTH,
	  CURR_FY_POTENTIAL_REVENUE,
	  NEXT_FY_POTENTIAL_REVENUE,
	  YEAR_ESTABLISHED,
	  MISSION_STATEMENT,
	  ORGANIZATION_TYPE,
	  BUSINESS_SCOPE,
	  CORPORATION_CLASS,
	  KNOWN_AS,
	  LOCAL_BUS_IDEN_TYPE,
	  LOCAL_BUS_IDENTIFIER,
	  PREF_FUNCTIONAL_CURRENCY,
	  REGISTRATION_TYPE,
	  TOTAL_EMPLOYEES_TEXT,
	  TOTAL_EMPLOYEES_IND,
	  TOTAL_EMP_EST_IND,
	  TOTAL_EMP_MIN_IND,
	  PARENT_SUB_IND,
	  INCORP_YEAR,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  CONTENT_SOURCE_TYPE,
	  EFFECTIVE_START_DATE,
	  EFFECTIVE_END_DATE,
	  PUBLIC_PRIVATE_OWNERSHIP_FLAG,
	  EMP_AT_PRIMARY_ADR,
	  EMP_AT_PRIMARY_ADR_TEXT,
	  EMP_AT_PRIMARY_ADR_EST_IND,
	  EMP_AT_PRIMARY_ADR_MIN_IND,
	  INTERNAL_FLAG,
	  TOTAL_PAYMENTS,
	  KNOWN_AS2,
	  KNOWN_AS3,
	  KNOWN_AS4,
	  KNOWN_AS5,
	  DISPLAYED_DUNS_PARTY_ID,
	  DUNS_NUMBER_C,
	  OBJECT_VERSION_NUMBER,
	  CREATED_BY_MODULE,
	  APPLICATION_ID,
	  DO_NOT_CONFUSE_WITH,
	  ACTUAL_CONTENT_SOURCE
 	)
	select
	hz_organization_profiles_s.nextval,
	PARTY_ID,
	decode(:l_organization_name, NULL, ORGANIZATION_NAME, :G_MISS_CHAR, ORGANIZATION_NAME,
	  :l_organization_name),
	decode(:l_ceo_name, NULL, CEO_NAME, :G_MISS_CHAR, NULL,
	  :l_ceo_name),
	decode(:l_ceo_title, NULL, CEO_TITLE, :G_MISS_CHAR, NULL,
	  :l_ceo_title),
	decode(:l_principal_name, NULL, PRINCIPAL_NAME, :G_MISS_CHAR, NULL,
	  :l_principal_name),
	decode(:l_principal_title, NULL, PRINCIPAL_TITLE, :G_MISS_CHAR, NULL,
	  :l_principal_title),
	decode(:l_legal_status, NULL, LEGAL_STATUS, :G_MISS_CHAR, NULL,
	  :l_legal_status),
	decode(:l_control_yr, NULL, CONTROL_YR, :G_MISS_NUM, NULL,
	  :l_control_yr),
	decode(:l_employees_total, NULL, EMPLOYEES_TOTAL, :G_MISS_NUM, NULL,
	  :l_employees_total),
	decode(:l_hq_branch_ind, NULL, HQ_BRANCH_IND, :G_MISS_CHAR, NULL,
	  :l_hq_branch_ind),
	decode(:l_oob_ind, NULL, OOB_IND, :G_MISS_CHAR, NULL,
	  :l_oob_ind),
	decode(:l_line_of_business, NULL, LINE_OF_BUSINESS, :G_MISS_CHAR, NULL,
	  :l_line_of_business),
	decode(:l_cong_dist_code, NULL, CONG_DIST_CODE, :G_MISS_CHAR, NULL,
	  :l_cong_dist_code),
	decode(:l_import_ind, NULL, IMPORT_IND, :G_MISS_CHAR, NULL,
	  :l_import_ind),
	decode(:l_export_ind, NULL, EXPORT_IND, :G_MISS_CHAR, NULL,
	  :l_export_ind),
	decode(:l_branch_flag, NULL, BRANCH_FLAG, :G_MISS_CHAR, NULL,
	  :l_branch_flag),
	decode(:l_labor_surplus_ind, NULL, LABOR_SURPLUS_IND, :G_MISS_CHAR, NULL,
	  :l_labor_surplus_ind),
	decode(:l_minority_owned_ind, NULL, MINORITY_OWNED_IND, :G_MISS_CHAR, NULL,
	  :l_minority_owned_ind),
	decode(:l_minority_owned_type, NULL, MINORITY_OWNED_TYPE, :G_MISS_CHAR, NULL,
	  :l_minority_owned_type),
	decode(:l_woman_owned_ind, NULL, WOMAN_OWNED_IND, :G_MISS_CHAR, NULL,
	  :l_woman_owned_ind),
	decode(:l_disadv_8a_ind, NULL, DISADV_8A_IND, :G_MISS_CHAR, NULL,
	  :l_disadv_8a_ind),
	decode(:l_small_bus_ind, NULL, SMALL_BUS_IND, :G_MISS_CHAR, NULL,
	  :l_small_bus_ind),
	decode(:l_rent_own_ind, NULL, RENT_OWN_IND, :G_MISS_CHAR, NULL,
	  :l_rent_own_ind),
	decode(:l_organization_name_phonetic, NULL, ORGANIZATION_NAME_PHONETIC, :G_MISS_CHAR, NULL,
	  :l_organization_name_phonetic),
	decode(:l_tax_reference, NULL, TAX_REFERENCE, :G_MISS_CHAR, NULL,
	  :l_tax_reference),
	decode(:l_gsa_indicator_flag, NULL, GSA_INDICATOR_FLAG, :G_MISS_CHAR, NULL,
	  :l_gsa_indicator_flag),
	decode(:l_jgzz_fiscal_code, NULL, JGZZ_FISCAL_CODE, :G_MISS_CHAR, NULL,
	  :l_jgzz_fiscal_code),
	decode(:l_analysis_fy, NULL, ANALYSIS_FY, :G_MISS_CHAR, NULL,
	  :l_analysis_fy),
	decode(:l_fiscal_yearend_month, NULL, FISCAL_YEAREND_MONTH, :G_MISS_CHAR, NULL,
	  :l_fiscal_yearend_month),
	decode(:l_curr_fy_potential_revenue, NULL, CURR_FY_POTENTIAL_REVENUE, :G_MISS_NUM, NULL,
	  :l_curr_fy_potential_revenue),
	decode(:l_next_fy_potential_revenue, NULL, NEXT_FY_POTENTIAL_REVENUE, :G_MISS_NUM, NULL,
	  :l_next_fy_potential_revenue),
	decode(:l_year_established, NULL, YEAR_ESTABLISHED, :G_MISS_NUM, NULL,
	  :l_year_established),
	decode(:l_mission_statement, NULL, MISSION_STATEMENT, :G_MISS_CHAR, NULL,
	  :l_mission_statement),
	decode(:l_organization_type, NULL, ORGANIZATION_TYPE, :G_MISS_CHAR, NULL,
	  :l_organization_type),
	decode(:l_business_scope, NULL, BUSINESS_SCOPE, :G_MISS_CHAR, NULL,
	  :l_business_scope),
	decode(:l_corporation_class, NULL, CORPORATION_CLASS, :G_MISS_CHAR, NULL,
	  :l_corporation_class),
	decode(:l_known_as, NULL, KNOWN_AS, :G_MISS_CHAR, NULL,
	  :l_known_as),
	decode(:l_local_bus_iden_type, NULL, LOCAL_BUS_IDEN_TYPE, :G_MISS_CHAR, NULL,
	  :l_local_bus_iden_type),
	decode(:l_local_bus_identifier, NULL, LOCAL_BUS_IDENTIFIER, :G_MISS_CHAR, NULL,
	  :l_local_bus_identifier),
	decode(:l_pref_functional_currency, NULL, PREF_FUNCTIONAL_CURRENCY, :G_MISS_CHAR, NULL,
	  :l_pref_functional_currency),
	decode(:l_registration_type, NULL, REGISTRATION_TYPE, :G_MISS_CHAR, NULL,
	  :l_registration_type),
	decode(:l_total_employees_text, NULL, TOTAL_EMPLOYEES_TEXT, :G_MISS_CHAR, NULL,
	  :l_total_employees_text),
	decode(:l_total_employees_ind, NULL, TOTAL_EMPLOYEES_IND, :G_MISS_CHAR, NULL,
	  :l_total_employees_ind),
	decode(:l_total_emp_est_ind, NULL, TOTAL_EMP_EST_IND, :G_MISS_CHAR, NULL,
	  :l_total_emp_est_ind),
	decode(:l_total_emp_min_ind, NULL, TOTAL_EMP_MIN_IND, :G_MISS_CHAR, NULL,
	  :l_total_emp_min_ind),
	decode(:l_parent_sub_ind, NULL, PARENT_SUB_IND, :G_MISS_CHAR, NULL,
	  :l_parent_sub_ind),
	decode(:l_incorp_year, NULL, INCORP_YEAR, :G_MISS_NUM, NULL,
	  :l_incorp_year),
	:l_sysdate,
	:l_user_id,
	:l_sysdate,
	:l_user_id,
	:l_last_update_login,
        :l_request_id,
        :l_program_application_id,
        :l_program_id,
        :l_program_update_date,
	CONTENT_SOURCE_TYPE,
	:l_sysdate,
	null,
	decode(:l_public_private_flag, NULL, PUBLIC_PRIVATE_OWNERSHIP_FLAG, :G_MISS_CHAR, NULL,
	  :l_public_private_flag),
	decode(:l_emp_at_primary_adr, NULL, EMP_AT_PRIMARY_ADR, :G_MISS_CHAR, NULL,
	  :l_emp_at_primary_adr),
	decode(:l_emp_at_primary_adr_text, NULL, EMP_AT_PRIMARY_ADR_TEXT, :G_MISS_CHAR, NULL,
	  :l_emp_at_primary_adr_text),
	decode(:l_emp_at_primary_adr_est_ind, NULL, EMP_AT_PRIMARY_ADR_EST_IND, :G_MISS_CHAR, NULL,
	  :l_emp_at_primary_adr_est_ind),
	decode(:l_emp_at_primary_adr_min_ind, NULL, EMP_AT_PRIMARY_ADR_MIN_IND, :G_MISS_CHAR, NULL,
	  :l_emp_at_primary_adr_min_ind),
	INTERNAL_FLAG,
	decode(:l_total_payments, NULL, TOTAL_PAYMENTS, :G_MISS_NUM, NULL,
	  :l_total_payments),
	decode(:l_known_as2, NULL, KNOWN_AS2, :G_MISS_CHAR, NULL,
	  :l_known_as2),
	decode(:l_known_as3, NULL, KNOWN_AS3, :G_MISS_CHAR, NULL,
	  :l_known_as3),
	decode(:l_known_as4, NULL, KNOWN_AS4, :G_MISS_CHAR, NULL,
	  :l_known_as4),
	decode(:l_known_as5, NULL, KNOWN_AS5, :G_MISS_CHAR, NULL,
	  :l_known_as5),
        decode(:l_party_orig_system, ''DNB'',
               decode(:l_displayed_duns, :l_party_orig_system_reference,
 	       :l_party_id, NULL), NULL),
	decode(:l_duns_c, NULL, DUNS_NUMBER_C, :G_MISS_CHAR, NULL,
	  :l_duns_c),
	1,
	nvl(CREATED_BY_MODULE, decode(:l_created_by_module, NULL, ''HZ_IMPORT'', :G_MISS_CHAR, ''HZ_IMPORT'',
	       :l_created_by_module)),
	APPLICATION_ID,
	decode(:l_do_not_confuse_with, NULL, DO_NOT_CONFUSE_WITH, :G_MISS_CHAR, NULL,
	  :l_do_not_confuse_with),
	ACTUAL_CONTENT_SOURCE
      from hz_organization_profiles where ';

  l_insert_per_profile varchar2(10000) :=
	'insert into hz_person_profiles pp1
	(
	  PERSON_PROFILE_ID,
	  PARTY_ID,
	  PERSON_NAME,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  PERSON_PRE_NAME_ADJUNCT,
	  PERSON_FIRST_NAME,
	  PERSON_MIDDLE_NAME,
	  PERSON_LAST_NAME,
	  PERSON_NAME_SUFFIX,
	  PERSON_TITLE,
	  PERSON_ACADEMIC_TITLE,
	  PERSON_PREVIOUS_LAST_NAME,
	  PERSON_INITIALS,
	  KNOWN_AS,
	  PERSON_NAME_PHONETIC,
	  PERSON_FIRST_NAME_PHONETIC,
	  PERSON_LAST_NAME_PHONETIC,
	  TAX_REFERENCE,
	  JGZZ_FISCAL_CODE,
	  PERSON_IDEN_TYPE,
	  PERSON_IDENTIFIER,
	  DATE_OF_BIRTH,
	  PLACE_OF_BIRTH,
	  DATE_OF_DEATH,
	  GENDER,
	  DECLARED_ETHNICITY,
	  MARITAL_STATUS,
	  MARITAL_STATUS_EFFECTIVE_DATE,
	  PERSONAL_INCOME,
	  HEAD_OF_HOUSEHOLD_FLAG,
	  HOUSEHOLD_INCOME,
	  HOUSEHOLD_SIZE,
	  RENT_OWN_IND,
	  EFFECTIVE_START_DATE,
	  EFFECTIVE_END_DATE,
	  CONTENT_SOURCE_TYPE,
	  INTERNAL_FLAG,
	  KNOWN_AS2,
	  KNOWN_AS3,
	  KNOWN_AS4,
	  KNOWN_AS5,
	  MIDDLE_NAME_PHONETIC,
	  OBJECT_VERSION_NUMBER,
	  APPLICATION_ID,
	  ACTUAL_CONTENT_SOURCE,
	  DECEASED_FLAG,
	  CREATED_BY_MODULE
	)
	select
	  hz_person_profiles_s.nextval,
	  PARTY_ID,
	  decode(:l_person_name, NULL, PERSON_NAME, :G_MISS_CHAR, PERSON_NAME,
		:l_person_name),
	  :l_sysdate,
	  :l_user_id,
	  :l_sysdate,
	  :l_user_id,
	  :l_last_update_login,
          :l_request_id,
          :l_program_application_id,
          :l_program_id,
          :l_program_update_date,
	  decode(:l_person_pre_name_adjunct, NULL, PERSON_PRE_NAME_ADJUNCT, :G_MISS_CHAR, NULL,
		:l_person_pre_name_adjunct),
	  decode(:l_person_first_name, NULL, PERSON_FIRST_NAME, :G_MISS_CHAR, NULL,
		:l_person_first_name),
	  decode(:l_person_middle_name, NULL, PERSON_MIDDLE_NAME, :G_MISS_CHAR, NULL,
		:l_person_middle_name),
	  decode(:l_person_last_name, NULL, PERSON_LAST_NAME, :G_MISS_CHAR, NULL,
		:l_person_last_name),
	  decode(:l_person_name_suffix, NULL, PERSON_NAME_SUFFIX, :G_MISS_CHAR, NULL,
		:l_person_name_suffix),
	  decode(:l_person_title, NULL, PERSON_TITLE, :G_MISS_CHAR, NULL,
		:l_person_title),
	  decode(:l_person_academic_title, NULL, PERSON_ACADEMIC_TITLE, :G_MISS_CHAR, NULL,
		:l_person_academic_title),
	  decode(:l_person_previous_last_name, NULL, PERSON_PREVIOUS_LAST_NAME, :G_MISS_CHAR, NULL,
		:l_person_previous_last_name),
	  decode(:l_person_initials, NULL, PERSON_INITIALS, :G_MISS_CHAR, NULL,
		:l_person_initials),
	  decode(:l_known_as, NULL, KNOWN_AS, :G_MISS_CHAR, NULL,
		:l_known_as),
	  decode(:l_person_name_phonetic, NULL, PERSON_NAME_PHONETIC, :G_MISS_CHAR, NULL,
		:l_person_name_phonetic),
	  decode(:l_person_first_name_phonetic, NULL, PERSON_FIRST_NAME_PHONETIC, :G_MISS_CHAR, NULL,
		:l_person_first_name_phonetic),
	  decode(:l_person_last_name_phonetic, NULL, PERSON_LAST_NAME_PHONETIC, :G_MISS_CHAR, NULL,
		:l_person_last_name_phonetic),
	  decode(:l_tax_reference, NULL, TAX_REFERENCE, :G_MISS_CHAR, NULL,
		:l_tax_reference),
	  decode(:l_jgzz_fiscal_code, NULL, JGZZ_FISCAL_CODE, :G_MISS_CHAR, NULL,
		:l_jgzz_fiscal_code),
	  decode(:l_person_iden_type, NULL, PERSON_IDEN_TYPE, :G_MISS_CHAR, NULL,
		:l_person_iden_type),
	  decode(:l_person_identifier, NULL, PERSON_IDENTIFIER, :G_MISS_CHAR, NULL,
		:l_person_identifier),
	  decode(:l_date_of_birth, NULL, DATE_OF_BIRTH, :G_MISS_DATE, NULL,
		:l_date_of_birth),
	  decode(:l_place_of_birth, NULL, PLACE_OF_BIRTH, :G_MISS_CHAR, NULL,
		:l_place_of_birth),
	  decode(:l_date_of_death, NULL, DATE_OF_DEATH, :G_MISS_DATE, NULL,
		:l_date_of_death),
	  decode(:l_gender, NULL, GENDER, :G_MISS_CHAR, NULL,
		:l_gender),
	  decode(:l_declared_ethnicity, NULL, DECLARED_ETHNICITY, :G_MISS_CHAR, NULL,
		:l_declared_ethnicity),
	  decode(:l_marital_status, NULL, MARITAL_STATUS, :G_MISS_CHAR, NULL,
		:l_marital_status),
	  decode(:l_marital_status_eff_date, NULL, MARITAL_STATUS_EFFECTIVE_DATE, :G_MISS_DATE, NULL,
		:l_marital_status_eff_date),
	  decode(:l_personal_income, NULL, PERSONAL_INCOME, :G_MISS_NUM, NULL,
		:l_personal_income),
	  decode(:l_head_of_household_flag, NULL, HEAD_OF_HOUSEHOLD_FLAG, :G_MISS_CHAR, NULL,
		:l_head_of_household_flag),
	  decode(:l_household_income, NULL, HOUSEHOLD_INCOME, :G_MISS_NUM, NULL,
		:l_household_income),
	  decode(:l_household_size, NULL, HOUSEHOLD_SIZE, :G_MISS_NUM, NULL,
		:l_household_size),
	  decode(:l_rent_own_ind, NULL, RENT_OWN_IND, :G_MISS_CHAR, NULL,
		:l_rent_own_ind),
	  :l_sysdate,
	  null,
	  CONTENT_SOURCE_TYPE,
	  INTERNAL_FLAG,
	  decode(:l_known_as2, NULL, KNOWN_AS2, :G_MISS_CHAR, NULL,
		:l_known_as2),
	  decode(:l_known_as3, NULL, KNOWN_AS3, :G_MISS_CHAR, NULL,
		:l_known_as3),
	  decode(:l_known_as4, NULL, KNOWN_AS4, :G_MISS_CHAR, NULL,
		:l_known_as4),
	  decode(:l_known_as5, NULL, KNOWN_AS5, :G_MISS_CHAR, NULL,
		:l_known_as5),
	  decode(:l_person_middle_name_phonetic, NULL, MIDDLE_NAME_PHONETIC, :G_MISS_CHAR, NULL,
		:l_person_middle_name_phonetic),
	  1,
	  APPLICATION_ID,
	  ACTUAL_CONTENT_SOURCE,
	  decode(:l_deceased_flag, NULL, DECEASED_FLAG,
		:G_MISS_CHAR, decode(:l_date_of_death,
		null, decode(date_of_death, null, ''N'', ''Y''),
		:G_MISS_DATE, ''N'', ''Y''),
		:l_deceased_flag),
	  nvl(CREATED_BY_MODULE, decode(:l_created_by_module, :G_MISS_CHAR, ''HZ_IMPORT'',
		NULL, ''HZ_IMPORT'', :l_created_by_module))
      from hz_person_profiles where ';

  l_update_org_profile varchar2(10000) :=
	'update hz_organization_profiles op1 set
	ORGANIZATION_NAME = DECODE(:l_organization_name,
		NULL, ORGANIZATION_NAME,
		:G_MISS_CHAR, ORGANIZATION_NAME,
		:l_organization_name),
	CEO_NAME = DECODE(:l_ceo_name,
		NULL, CEO_NAME,
		:G_MISS_CHAR, NULL,
		:l_ceo_name),
	CEO_TITLE = DECODE(:l_ceo_title,
		NULL, CEO_TITLE,
		:G_MISS_CHAR, NULL,
		:l_ceo_title),
	PRINCIPAL_NAME = DECODE(:l_principal_name,
		NULL, PRINCIPAL_NAME,
		:G_MISS_CHAR, NULL,
		:l_principal_name),
	PRINCIPAL_TITLE = DECODE(:l_principal_title,
		NULL, PRINCIPAL_TITLE,
		:G_MISS_CHAR, NULL,
		:l_principal_title),
	LEGAL_STATUS = DECODE(:l_legal_status,
		NULL, LEGAL_STATUS,
		:G_MISS_CHAR, NULL,
		:l_legal_status),
	CONTROL_YR = DECODE(:l_control_yr,
		NULL, CONTROL_YR,
		:G_MISS_NUM, NULL,
		:l_control_yr),
	EMPLOYEES_TOTAL = DECODE(:l_employees_total,
		NULL, EMPLOYEES_TOTAL,
		:G_MISS_NUM, NULL,
		:l_employees_total),
	HQ_BRANCH_IND = DECODE(:l_hq_branch_ind,
		NULL, HQ_BRANCH_IND,
		:G_MISS_CHAR, NULL,
		:l_hq_branch_ind),
	OOB_IND = DECODE(:l_oob_ind,
		NULL, OOB_IND,
		:G_MISS_CHAR, NULL,
		:l_oob_ind),
	LINE_OF_BUSINESS = DECODE(:l_line_of_business,
		NULL, LINE_OF_BUSINESS,
		:G_MISS_CHAR, NULL,
		:l_line_of_business),
	CONG_DIST_CODE = DECODE(:l_cong_dist_code,
		NULL, CONG_DIST_CODE,
		:G_MISS_CHAR, NULL,
		:l_cong_dist_code),
	IMPORT_IND = DECODE(:l_import_ind,
		NULL, IMPORT_IND,
		:G_MISS_CHAR, NULL,
		:l_import_ind),
	EXPORT_IND = DECODE(:l_export_ind,
		NULL, EXPORT_IND,
		:G_MISS_CHAR, NULL,
		:l_export_ind),
	BRANCH_FLAG = DECODE(:l_branch_flag,
		NULL, BRANCH_FLAG,
		:G_MISS_CHAR, NULL,
		:l_branch_flag),
	LABOR_SURPLUS_IND = DECODE(:l_labor_surplus_ind,
		NULL, LABOR_SURPLUS_IND,
		:G_MISS_CHAR, NULL,
		:l_labor_surplus_ind),
	MINORITY_OWNED_IND = DECODE(:l_minority_owned_ind,
		NULL, MINORITY_OWNED_IND,
		:G_MISS_CHAR, NULL,
		:l_minority_owned_ind),
	MINORITY_OWNED_TYPE = DECODE(:l_minority_owned_type,
		NULL, MINORITY_OWNED_TYPE,
		:G_MISS_CHAR, NULL,
		:l_minority_owned_type),
	WOMAN_OWNED_IND = DECODE(:l_woman_owned_ind,
		NULL, WOMAN_OWNED_IND,
		:G_MISS_CHAR, NULL,
		:l_woman_owned_ind),
	DISADV_8A_IND = DECODE(:l_disadv_8a_ind,
		NULL, DISADV_8A_IND,
		:G_MISS_CHAR, NULL,
		:l_disadv_8a_ind),
	SMALL_BUS_IND = DECODE(:l_small_bus_ind,
		NULL, SMALL_BUS_IND,
		:G_MISS_CHAR, NULL,
	:l_small_bus_ind),
	RENT_OWN_IND = DECODE(:l_rent_own_ind,
		NULL, RENT_OWN_IND,
		:G_MISS_CHAR, NULL,
		:l_rent_own_ind),
	ORGANIZATION_NAME_PHONETIC = DECODE(:l_organization_name_phonetic,
		NULL, ORGANIZATION_NAME_PHONETIC,
		:G_MISS_CHAR, NULL,
		:l_organization_name_phonetic),
	TAX_REFERENCE = DECODE(:l_tax_reference,
		NULL, TAX_REFERENCE,
		:G_MISS_CHAR, NULL,
		:l_tax_reference),
	GSA_INDICATOR_FLAG = DECODE(:l_gsa_indicator_flag,
		NULL, GSA_INDICATOR_FLAG,
		:G_MISS_CHAR, NULL,
		:l_gsa_indicator_flag),
	JGZZ_FISCAL_CODE = DECODE(:l_jgzz_fiscal_code,
		NULL, JGZZ_FISCAL_CODE,
		:G_MISS_CHAR, NULL,
		:l_jgzz_fiscal_code),
	ANALYSIS_FY = DECODE(:l_analysis_fy,
		NULL, ANALYSIS_FY,
		:G_MISS_CHAR, NULL,
		:l_analysis_fy),
	FISCAL_YEAREND_MONTH = DECODE(:l_fiscal_yearend_month,
		NULL, FISCAL_YEAREND_MONTH,
		:G_MISS_CHAR, NULL,
		:l_fiscal_yearend_month),
	CURR_FY_POTENTIAL_REVENUE = DECODE(:l_curr_fy_potential_revenue,
		NULL, CURR_FY_POTENTIAL_REVENUE,
		:G_MISS_NUM, NULL,
		:l_curr_fy_potential_revenue),
	NEXT_FY_POTENTIAL_REVENUE = DECODE(:l_next_fy_potential_revenue,
		NULL, NEXT_FY_POTENTIAL_REVENUE,
		:G_MISS_NUM, NULL,
		:l_next_fy_potential_revenue),
	YEAR_ESTABLISHED = DECODE(:l_year_established,
		NULL, YEAR_ESTABLISHED,
		:G_MISS_NUM, NULL,
		:l_year_established),
	MISSION_STATEMENT = DECODE(:l_mission_statement,
		NULL, MISSION_STATEMENT,
		:G_MISS_CHAR, NULL,
		:l_mission_statement),
	ORGANIZATION_TYPE = DECODE(:l_organization_type,
		NULL, ORGANIZATION_TYPE,
		:G_MISS_CHAR, NULL,
		:l_organization_type),
	BUSINESS_SCOPE = DECODE(:l_business_scope,
		NULL, BUSINESS_SCOPE,
		:G_MISS_CHAR, NULL,
		:l_business_scope),
	CORPORATION_CLASS = DECODE(:l_corporation_class,
		NULL, CORPORATION_CLASS,
		:G_MISS_CHAR, NULL,
		:l_corporation_class),
	KNOWN_AS = DECODE(:l_known_as,
		NULL, KNOWN_AS,
		:G_MISS_CHAR, NULL,
		:l_known_as),
	LOCAL_BUS_IDEN_TYPE = DECODE(:l_local_bus_iden_type,
		NULL, LOCAL_BUS_IDEN_TYPE,
		:G_MISS_CHAR, NULL,
		:l_local_bus_iden_type),
	LOCAL_BUS_IDENTIFIER = DECODE(:l_local_bus_identifier,
		NULL, LOCAL_BUS_IDENTIFIER,
		:G_MISS_CHAR, NULL,
		:l_local_bus_identifier),
	PREF_FUNCTIONAL_CURRENCY = DECODE(:l_pref_functional_currency,
		NULL, PREF_FUNCTIONAL_CURRENCY,
		:G_MISS_CHAR, NULL,
		:l_pref_functional_currency),
	REGISTRATION_TYPE = DECODE(:l_registration_type,
		NULL, REGISTRATION_TYPE,
		:G_MISS_CHAR, NULL,
		:l_registration_type),
	TOTAL_EMPLOYEES_TEXT = DECODE(:l_total_employees_text,
		NULL, TOTAL_EMPLOYEES_TEXT,
		:G_MISS_CHAR, NULL,
		:l_total_employees_text),
	TOTAL_EMPLOYEES_IND = DECODE(:l_total_employees_ind,
		NULL, TOTAL_EMPLOYEES_IND,
		:G_MISS_CHAR, NULL,
		:l_total_employees_ind),
	TOTAL_EMP_EST_IND = DECODE(:l_total_emp_est_ind,
		NULL, TOTAL_EMP_EST_IND,
		:G_MISS_CHAR, NULL,
		:l_total_emp_est_ind),
	TOTAL_EMP_MIN_IND = DECODE(:l_total_emp_min_ind,
		NULL, TOTAL_EMP_MIN_IND,
		:G_MISS_CHAR, NULL,
		:l_total_emp_min_ind),
	PARENT_SUB_IND = DECODE(:l_parent_sub_ind,
		NULL, PARENT_SUB_IND,
		:G_MISS_CHAR, NULL,
		:l_parent_sub_ind),
	INCORP_YEAR = DECODE(:l_incorp_year,
		NULL, INCORP_YEAR,
		:G_MISS_NUM, NULL,
		:l_incorp_year),
	LAST_UPDATE_DATE = :l_sysdate,
	LAST_UPDATED_BY = :l_user_id,
	LAST_UPDATE_LOGIN = :l_last_update_login,
	REQUEST_ID = :l_request_id,
	PROGRAM_APPLICATION_ID = :l_program_application_id,
	PROGRAM_ID = :l_program_id,
	PROGRAM_UPDATE_DATE = :l_program_update_date,
	PUBLIC_PRIVATE_OWNERSHIP_FLAG = DECODE(:l_public_private_flag,
		NULL, PUBLIC_PRIVATE_OWNERSHIP_FLAG,
		:G_MISS_CHAR, NULL,
		:l_public_private_flag),
	EMP_AT_PRIMARY_ADR = DECODE(:l_emp_at_primary_adr,
		NULL, EMP_AT_PRIMARY_ADR,
		:G_MISS_CHAR, NULL,
		:l_emp_at_primary_adr),
	EMP_AT_PRIMARY_ADR_TEXT = DECODE(:l_emp_at_primary_adr_text,
		NULL, EMP_AT_PRIMARY_ADR_TEXT,
		:G_MISS_CHAR, NULL,
		:l_emp_at_primary_adr_text),
	EMP_AT_PRIMARY_ADR_EST_IND = DECODE(:l_emp_at_primary_adr_est_ind,
		NULL, EMP_AT_PRIMARY_ADR_EST_IND,
		:G_MISS_CHAR, NULL,
		:l_emp_at_primary_adr_est_ind),
	EMP_AT_PRIMARY_ADR_MIN_IND = DECODE(:l_emp_at_primary_adr_min_ind,
		NULL, EMP_AT_PRIMARY_ADR_MIN_IND,
		:G_MISS_CHAR, NULL,
		:l_emp_at_primary_adr_min_ind),
	TOTAL_PAYMENTS = DECODE(:l_total_payments,
		NULL, TOTAL_PAYMENTS,
		:G_MISS_NUM, NULL,
		:l_total_payments),
	KNOWN_AS2 = DECODE(:l_known_as2,
		NULL, KNOWN_AS2,
		:G_MISS_CHAR, NULL,
		:l_known_as2),
	KNOWN_AS3 = DECODE(:l_known_as3,
		NULL, KNOWN_AS3,
		:G_MISS_CHAR, NULL,
		:l_known_as3),
	KNOWN_AS4 = DECODE(:l_known_as4,
		NULL, KNOWN_AS4,
		:G_MISS_CHAR, NULL,
		:l_known_as4),
	KNOWN_AS5 = DECODE(:l_known_as5,
		NULL, KNOWN_AS5,
		:G_MISS_CHAR, NULL,
		:l_known_as5),
	DISPLAYED_DUNS_PARTY_ID = DECODE(:l_party_orig_system, ''DNB'',
		DECODE(:l_displayed_duns, :l_party_orig_system_reference,
		:l_party_id, NULL), NULL),
	DUNS_NUMBER_C = DECODE(:l_duns_c,
		NULL, DUNS_NUMBER_C,
		:G_MISS_CHAR, NULL,
		:l_duns_c),
	OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
	VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1,
	DO_NOT_CONFUSE_WITH = DECODE(:l_do_not_confuse_with,
		NULL, DO_NOT_CONFUSE_WITH,
		:G_MISS_CHAR, NULL,
		:l_do_not_confuse_with)
	where ';


  l_update_per_profile varchar2(10000) :=
	'update hz_person_profiles pp1 set
	PERSON_NAME = DECODE(:l_person_name,
		NULL, PERSON_NAME,
		:G_MISS_CHAR, PERSON_NAME,
		:l_person_name),
	LAST_UPDATE_DATE = :l_sysdate,
	LAST_UPDATED_BY = :l_user_id,
	LAST_UPDATE_LOGIN = :l_last_update_login,
	REQUEST_ID = :l_request_id,
	PROGRAM_APPLICATION_ID = :l_program_application_id,
	PROGRAM_ID = :l_program_id,
	PROGRAM_UPDATE_DATE = :l_program_update_date,
	PERSON_PRE_NAME_ADJUNCT = DECODE(:l_person_pre_name_adjunct,
		NULL, PERSON_PRE_NAME_ADJUNCT,
		:G_MISS_CHAR, NULL,
		:l_person_pre_name_adjunct),
	PERSON_FIRST_NAME = DECODE(:l_person_first_name,
		NULL, PERSON_FIRST_NAME,
		:G_MISS_CHAR, NULL,
		:l_person_first_name),
	PERSON_MIDDLE_NAME = DECODE(:l_person_middle_name,
		NULL, PERSON_MIDDLE_NAME,
		:G_MISS_CHAR, NULL,
		:l_person_middle_name),
	PERSON_LAST_NAME = DECODE(:l_person_last_name,
		NULL, PERSON_LAST_NAME,
		:G_MISS_CHAR, NULL,
		:l_person_last_name),
	PERSON_NAME_SUFFIX = DECODE(:l_person_name_suffix,
		NULL, PERSON_NAME_SUFFIX,
		:G_MISS_CHAR, NULL,
		:l_person_name_suffix),
	PERSON_TITLE = DECODE(:l_person_title,
		NULL, PERSON_TITLE,
		:G_MISS_CHAR, NULL,
		:l_person_title),
	PERSON_ACADEMIC_TITLE = DECODE(:l_person_academic_title,
		NULL, PERSON_ACADEMIC_TITLE,
		:G_MISS_CHAR, NULL,
		:l_person_academic_title),
	PERSON_PREVIOUS_LAST_NAME = DECODE(:l_person_previous_last_name,
		NULL, PERSON_PREVIOUS_LAST_NAME,
		:G_MISS_CHAR, NULL,
		:l_person_previous_last_name),
	PERSON_INITIALS = DECODE(:l_person_initials,
		NULL, PERSON_INITIALS,
		:G_MISS_CHAR, NULL,
		:l_person_initials),
	KNOWN_AS = DECODE(:l_known_as,
		NULL, KNOWN_AS,
		:G_MISS_CHAR, NULL,
		:l_known_as),
	PERSON_NAME_PHONETIC = DECODE(:l_person_name_phonetic,
		NULL, PERSON_NAME_PHONETIC,
		:G_MISS_CHAR, NULL,
		:l_person_name_phonetic),
	PERSON_FIRST_NAME_PHONETIC = DECODE(:l_person_first_name_phonetic,
		NULL, PERSON_FIRST_NAME_PHONETIC,
		:G_MISS_CHAR, NULL,
		:l_person_first_name_phonetic),
	PERSON_LAST_NAME_PHONETIC = DECODE(:l_person_last_name_phonetic,
		NULL, PERSON_LAST_NAME_PHONETIC,
		:G_MISS_CHAR, NULL,
		:l_person_last_name_phonetic),
	TAX_REFERENCE = DECODE(:l_tax_reference,
		NULL, TAX_REFERENCE,
		:G_MISS_CHAR, NULL,
		:l_tax_reference),
	JGZZ_FISCAL_CODE = DECODE(:l_jgzz_fiscal_code,
		NULL, JGZZ_FISCAL_CODE,
		:G_MISS_CHAR, NULL,
		:l_jgzz_fiscal_code),
	PERSON_IDEN_TYPE = DECODE(:l_person_iden_type,
		NULL, PERSON_IDEN_TYPE,
		:G_MISS_CHAR, NULL,
		:l_person_iden_type),
	PERSON_IDENTIFIER = DECODE(:l_person_identifier,
		NULL, PERSON_IDENTIFIER,
		:G_MISS_CHAR, NULL,
		:l_person_identifier),
	DATE_OF_BIRTH = DECODE(:l_date_of_birth,
		NULL, DATE_OF_BIRTH,
		:G_MISS_DATE, NULL,
		:l_date_of_birth),
	PLACE_OF_BIRTH = DECODE(:l_place_of_birth,
		NULL, PLACE_OF_BIRTH,
		:G_MISS_CHAR, NULL,
		:l_place_of_birth),
	DATE_OF_DEATH = DECODE(:l_date_of_death,
		NULL, DATE_OF_DEATH,
		:G_MISS_DATE, NULL,
		:l_date_of_death),
	GENDER = DECODE(:l_gender,
		NULL, GENDER,
		:G_MISS_CHAR, NULL,
		:l_gender),
	DECLARED_ETHNICITY = DECODE(:l_declared_ethnicity,
		NULL, DECLARED_ETHNICITY,
		:G_MISS_CHAR, NULL,
		:l_declared_ethnicity),
	MARITAL_STATUS = DECODE(:l_marital_status,
		NULL, MARITAL_STATUS,
		:G_MISS_CHAR, NULL,
		:l_marital_status),
	MARITAL_STATUS_EFFECTIVE_DATE = DECODE(:l_marital_status_eff_date,
		NULL, MARITAL_STATUS_EFFECTIVE_DATE,
		:G_MISS_DATE, NULL,
		:l_marital_status_eff_date),
	PERSONAL_INCOME = DECODE(:l_personal_income,
		NULL, PERSONAL_INCOME,
		:G_MISS_NUM, NULL,
		:l_personal_income),
	HEAD_OF_HOUSEHOLD_FLAG = DECODE(:l_head_of_household_flag,
		NULL, HEAD_OF_HOUSEHOLD_FLAG,
		:G_MISS_CHAR, NULL,
		:l_head_of_household_flag),
	HOUSEHOLD_INCOME = DECODE(:l_household_income,
		NULL, HOUSEHOLD_INCOME,
		:G_MISS_NUM, NULL,
		:l_household_income),
	HOUSEHOLD_SIZE = DECODE(:l_household_size,
		NULL, HOUSEHOLD_SIZE,
		:G_MISS_NUM, NULL,
		:l_household_size),
	RENT_OWN_IND = DECODE(:l_rent_own_ind,
		NULL, RENT_OWN_IND,
		:G_MISS_CHAR, NULL,
		:l_rent_own_ind),
	KNOWN_AS2 = DECODE(:l_known_as2,
		NULL, KNOWN_AS2,
		:G_MISS_CHAR, NULL,
		:l_known_as2),
	KNOWN_AS3 = DECODE(:l_known_as3,
		NULL, KNOWN_AS3,
		:G_MISS_CHAR, NULL,
		:l_known_as3),
	KNOWN_AS4 = DECODE(:l_known_as4,
		NULL, KNOWN_AS4,
		:G_MISS_CHAR, NULL,
		:l_known_as4),
	KNOWN_AS5 = DECODE(:l_known_as5,
		NULL, KNOWN_AS5,
		:G_MISS_CHAR, NULL,
		:l_known_as5),
	MIDDLE_NAME_PHONETIC = DECODE(:l_person_middle_name_phonetic,
		NULL, MIDDLE_NAME_PHONETIC,
		:G_MISS_CHAR, NULL,
		:l_person_middle_name_phonetic),
	OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
	VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1,
	DECEASED_FLAG = DECODE(:l_deceased_flag,
		NULL, DECEASED_FLAG,
		:G_MISS_CHAR, NULL,
		:l_deceased_flag)
	where ';

BEGIN
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'BATCH_ID = ' || P_DML_RECORD.BATCH_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'OS = ' || P_DML_RECORD.OS,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'FROM_OSR = ' || P_DML_RECORD.FROM_OSR,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'TO_OSR = ' || P_DML_RECORD.TO_OSR,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'ACTUAL_CONTENT_SRC = ' || P_DML_RECORD.ACTUAL_CONTENT_SRC,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'RERUN = ' || P_DML_RECORD.RERUN,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'ERROR_LIMIT = ' || P_DML_RECORD.ERROR_LIMIT,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'BATCH_MODE_FLAG = ' || P_DML_RECORD.BATCH_MODE_FLAG,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'USER_ID = ' || P_DML_RECORD.USER_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);

    hz_utility_v2pub.debug(p_message=>'SYSDATE = ' || to_char(P_DML_RECORD.SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'REQUEST_ID = ' || P_DML_RECORD.REQUEST_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'GMISS_CHAR = ' || P_DML_RECORD.GMISS_CHAR,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'GMISS_NUM = ' || P_DML_RECORD.GMISS_NUM,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'FLEX_VALIDATION = ' || P_DML_RECORD.FLEX_VALIDATION,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'DSS_SECURITY = ' || P_DML_RECORD.DSS_SECURITY,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);

    hz_utility_v2pub.debug(p_message=>'ALLOW_DISABLED_LOOKUP = ' || P_DML_RECORD.ALLOW_DISABLED_LOOKUP,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    hz_utility_v2pub.debug(p_message=>'PROFILE_VERSION = ' || P_DML_RECORD.PROFILE_VERSION,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
  END IF;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'PTY:process_update_parties()+',p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_procedure);
  END IF;

  savepoint process_update_parties_pvt;

  FND_MSG_PUB.initialize;

  l_party_name_profile := NVL(FND_PROFILE.value('AR_CHANGE_CUST_NAME'), 'Y');

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--  l_version_profile := P_DML_RECORD.PROFILE_VERSION;
  --NEW_VERSION, NO_VERSION, ONE_DAY_VERSION

  IF l_content_source_type <> 'USER_ENTERED' THEN
    l_acs := l_content_source_type;
  ELSE
    IF l_per_mixnmatch_enabled = 'Y' THEN
      l_acs := 'USER_ENTERED';
    ELSE
      l_acs := 'SST';
    END IF;
  END IF;

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN

    IF P_DML_RECORD.RERUN = 'N' /*** First Run     ***/ THEN
      OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.PROFILE_VERSION, P_DML_RECORD.SYSDATE, l_party_name_profile,
      l_acs, l_acs, P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
    ELSE /* Rerun to correct errors */
      OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,  P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.PROFILE_VERSION, P_DML_RECORD.SYSDATE, l_party_name_profile,
      l_acs, l_acs, P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;
    END IF;
  ELSE
    IF P_DML_RECORD.RERUN = 'N' /*** First Run     ***/ THEN
      OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql || l_where_enabled_lookup_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.PROFILE_VERSION, P_DML_RECORD.SYSDATE,  l_party_name_profile,
      l_acs, l_acs, P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE;

    ELSE /* Rerun to correct errors */
      OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql || l_where_enabled_lookup_sql
      USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.PROFILE_VERSION, P_DML_RECORD.SYSDATE, l_party_name_profile,
      l_acs, l_acs, P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE;

    END IF;
  END IF;
  hz_utility_v2pub.debug('Fetch update cursor');
  FETCH c_handle_update BULK COLLECT INTO
    l_row_id,
    l_party_orig_system,
    l_party_orig_system_reference,
    l_insert_update_flag,
    l_party_type,
    l_party_number,
    l_salutation,
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
    l_attr21,
    l_attr22,
    l_attr23,
    l_attr24,
    l_organization_name,
    l_organization_name_phonetic,
    l_organization_type,
    l_analysis_fy,
    l_branch_flag,
    l_business_scope,
    l_ceo_name,
    l_ceo_title,
    l_cong_dist_code,
    l_control_yr,
    l_corporation_class,
    l_curr_fy_potential_revenue,
    l_next_fy_potential_revenue,
    l_pref_functional_currency,
    l_disadv_8a_ind,
    l_do_not_confuse_with,
    l_duns_c,
    l_emp_at_primary_adr,
    l_emp_at_primary_adr_est_ind,
    l_emp_at_primary_adr_min_ind,
    l_emp_at_primary_adr_text,
    l_employees_total,
    l_displayed_duns,
    l_export_ind,
    l_branch_flag,
    l_fiscal_yearend_month,
    l_gsa_indicator_flag,
    l_hq_branch_ind,
    l_import_ind,
    l_incorp_year,
    l_jgzz_fiscal_code,
    l_tax_reference,
    l_known_as,
    l_known_as2,
    l_known_as3,
    l_known_as4,
    l_known_as5,
    l_labor_surplus_ind,
    l_legal_status,
    l_line_of_business,
    l_local_bus_identifier,
    l_local_bus_iden_type,
    l_minority_owned_ind,
    l_minority_owned_type,
    l_mission_statement,
    l_oob_ind,
    l_parent_sub_ind,
    l_principal_name,
    l_principal_title,
    l_public_private_flag,
    l_registration_type,
    l_rent_own_ind,
    l_small_bus_ind,
    l_total_emp_est_ind,
    l_total_emp_min_ind,
    l_total_employees_ind,
    l_total_employees_text,
    l_total_payments,
    l_woman_owned_ind,
    l_year_established,
    l_person_first_name,
    l_person_last_name,
    l_person_middle_name,
    l_person_initials,
    l_person_name_suffix,
    l_person_pre_name_adjunct,
    l_person_previous_last_name,
    l_person_title,
    l_person_first_name_phonetic,
    l_person_last_name_phonetic,
    l_person_middle_name_phonetic,
    l_person_name_phonetic,
    l_person_academic_title,
    l_date_of_birth,
    l_place_of_birth,
    l_date_of_death,
    l_deceased_flag,
    l_declared_ethnicity,
    l_gender,
    l_head_of_household_flag,
    l_household_income,
    l_household_size,
    l_marital_status,
    l_marital_status_eff_date,
    l_person_iden_type,
    l_person_identifier,
    l_personal_income,
    l_interface_status,
    l_created_by_module,
    l_party_type_errors,
    l_action_mismatch_errors,
    l_flex_val_errors,
    l_dss_security_errors,
    l_month_errors ,
    l_legal_status_errors,
    l_local_bus_iden_type_errors,
    l_reg_type_errors,
    l_own_rent_errors,
    l_hq_branch_errors,
    l_minority_owned_errors,
    l_gsa_errors ,
    l_import_errors,
    l_export_errors,
    l_branch_flag_errors,
    l_disadv_8a_ind_errors,
    l_labor_surplus_errors,
    l_oob_errors,
    l_parent_sub_errors,
    l_pub_ownership_errors,
    l_small_bus_errors,
    l_tot_emp_est_errors,
    l_tot_emp_min_errors,
    l_tot_emp_ind_errors,
    l_woman_own_errors,
    l_emp_pri_adr_est_ind_errors,
    l_emp_pri_adr_est_min_errors,
    l_marital_status_errors,
    l_gender_errors,
    l_person_iden_type_errors,
    l_contact_title_errors,
    l_deceased_flag_errors,
    l_head_of_household_errors,
    l_birth_date_errors,
    l_death_date_errors,
    l_birth_death_errors,
    l_party_name,
    l_createdby_errors,
    l_party_name_update_errors,
    l_person_name,
    l_tca_party_id,
    l_status,
    l_party_id,
    l_new_osr_exists,
    l_old_orig_system_reference;

  /*** Do FND desc flex validation based on profile ***/
  IF P_DML_RECORD.FLEX_VALIDATION = 'Y' THEN
    validate_desc_flexfield(P_DML_RECORD.SYSDATE);
  END IF;

  /*** Do DSS security validation based on profile ***/
  IF P_DML_RECORD.DSS_SECURITY = 'Y' THEN
    validate_DSS_security;
  END IF;

hz_utility_v2pub.debug('count = ' || l_party_orig_system_reference.count);


  /******************************/
  /***   Update HZ_PARTIES    ***/
  /******************************/

  /* Loop to handle duplicate party_id or party_number exceptions. Only
     needed for hz_parties. When inserting into hz_organization_profiles or
     hz_person_profiles, l_num_row_processed is used to determine if an interface
     record was inserted successfully, which excludes problem with duplicate
     party_id as well. So this problem will not be reported again. Then when
     inserting into profiles table, whenever there is any exception, just
     exit as it'll be some unknown error not encountered while updating into
     hz_parties */

  BEGIN
    IF l_content_source_type = 'USER_ENTERED' OR
       l_org_mixnmatch_enabled = 'N' OR l_per_mixnmatch_enabled = 'N' THEN

        /* Update hz_parties. Update party_name and other columns that are
           supposed to be denormalized from SST only if OS is USER_ENTERED
           and mix and match disabled. Otherwise, mix and match proc will update
           party name */
        ForAll j in 1..l_party_orig_system_reference.count SAVE EXCEPTIONS
          update hz_parties set
            PARTY_NAME = decode(l_party_type(j), 'PERSON', l_person_name(j), l_party_name(j)),
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
 	    LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
  	    SALUTATION =
                   DECODE(l_salutation(j),
                   	  NULL, salutation,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_salutation(j)),
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
  	    ATTRIBUTE21 =
                   DECODE(l_attr21(j),
                   	  NULL, attribute21,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr21(j)),
  	    ATTRIBUTE22 =
                   DECODE(l_attr22(j),
                   	  NULL, attribute22,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr22(j)),
  	    ATTRIBUTE23 =
                   DECODE(l_attr23(j),
                   	  NULL, attribute23,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr23(j)),
  	    ATTRIBUTE24 =
                   DECODE(l_attr24(j),
                   	  NULL, attribute24,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr24(j)),
  	    analysis_fy =
                   DECODE(l_analysis_fy(j),
                   	  NULL, analysis_fy,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_analysis_fy(j)),
  	    curr_fy_potential_revenue =
                   DECODE(l_curr_fy_potential_revenue(j),
                   	  NULL, curr_fy_potential_revenue,
                   	  P_DML_RECORD.GMISS_NUM, NULL,
                   	  l_curr_fy_potential_revenue(j)),
  	    duns_number_c =
                   DECODE(l_duns_c(j),
                   	  NULL, duns_number_c,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_duns_c(j)),
  	    employees_total =
                   DECODE(l_employees_total(j),
                   	  NULL, employees_total,
                   	  P_DML_RECORD.GMISS_NUM, NULL,
                   	  l_employees_total(j)),
  	    fiscal_yearend_month =
                   DECODE(l_fiscal_yearend_month(j),
                   	  NULL, fiscal_yearend_month,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_fiscal_yearend_month(j)),
  	    gsa_indicator_flag =
                   DECODE(l_gsa_indicator_flag(j),
                   	  NULL, gsa_indicator_flag,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_gsa_indicator_flag(j)),
  	    hq_branch_ind =
                   DECODE(l_hq_branch_ind(j),
                   	  NULL, hq_branch_ind,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_hq_branch_ind(j)),
  	    jgzz_fiscal_code =
                   DECODE(l_jgzz_fiscal_code(j),
                   	  NULL, jgzz_fiscal_code,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_jgzz_fiscal_code(j)),
  	    known_as =
                   DECODE(l_known_as(j),
                   	  NULL, known_as,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_known_as(j)),
  	    known_as2 =
                   DECODE(l_known_as2(j),
                   	  NULL, known_as2,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_known_as2(j)),
  	    known_as3 =
                   DECODE(l_known_as3(j),
                   	  NULL, known_as3,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_known_as3(j)),
  	    known_as4 =
                   DECODE(l_known_as4(j),
                   	  NULL, known_as4,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_known_as4(j)),
  	    known_as5 =
                   DECODE(l_known_as5(j),
                   	  NULL, known_as5,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_known_as5(j)),
  	    mission_statement =
                   DECODE(l_mission_statement(j),
                   	  NULL, mission_statement,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_mission_statement(j)),
  	    next_fy_potential_revenue =
                   DECODE(l_next_fy_potential_revenue(j),
                   	  NULL, next_fy_potential_revenue,
                   	  P_DML_RECORD.GMISS_NUM, NULL,
                   	  l_next_fy_potential_revenue(j)),
  	    organization_name_phonetic =
                   DECODE(l_organization_name_phonetic(j),
                   	  NULL, organization_name_phonetic,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_organization_name_phonetic(j)),
  	    person_academic_title =
                   DECODE(l_person_academic_title(j),
                   	  NULL, person_academic_title,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_academic_title(j)),
  	    person_first_name =
                   DECODE(l_person_first_name(j),
                   	  NULL, person_first_name,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_first_name(j)),
  	    person_first_name_phonetic =
                   DECODE(l_person_first_name_phonetic(j),
                   	  NULL, person_first_name_phonetic,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_first_name_phonetic(j)),
  	    person_iden_type =
                   DECODE(l_person_iden_type(j),
                   	  NULL, person_iden_type,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_iden_type(j)),
  	    person_identifier =
                   DECODE(l_person_identifier(j),
                   	  NULL, person_identifier,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_identifier(j)),
  	    person_last_name =
                   DECODE(l_person_last_name(j),
                   	  NULL, person_last_name,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_last_name(j)),
  	    person_last_name_phonetic =
                   DECODE(l_person_last_name_phonetic(j),
                   	  NULL, person_last_name_phonetic,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_last_name_phonetic(j)),
  	    person_middle_name =
                   DECODE(l_person_middle_name(j),
                   	  NULL, person_middle_name,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_middle_name(j)),
  	    person_name_suffix =
                   DECODE(l_person_name_suffix(j),
                   	  NULL, person_name_suffix,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_name_suffix(j)),
  	    person_pre_name_adjunct =
                   DECODE(l_person_pre_name_adjunct(j),
                   	  NULL, person_pre_name_adjunct,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_pre_name_adjunct(j)),
  	    person_previous_last_name =
                   DECODE(l_person_previous_last_name(j),
                   	  NULL, person_previous_last_name,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_previous_last_name(j)),
  	    person_title =
                   DECODE(l_person_title(j),
                   	  NULL, person_title,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_person_title(j)),
  	    tax_reference =
                   DECODE(l_tax_reference(j),
                   	  NULL, tax_reference,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_tax_reference(j)),
  	    year_established =
                   DECODE(l_year_established(j),
                   	  NULL, year_established,
                   	  P_DML_RECORD.GMISS_NUM, NULL,
                   	  l_year_established(j)),
            REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and l_party_type_errors(j) is not null
            and l_month_errors(j) is not null
            and l_legal_status_errors(j) is not null
            and l_local_bus_iden_type_errors(j) is not null
            and l_reg_type_errors(j) is not null
            and l_own_rent_errors(j) is not null
            and l_hq_branch_errors(j) is not null
            and l_minority_owned_errors(j) is not null
            and l_gsa_errors(j) is not null
            and l_import_errors(j) is not null
            and l_export_errors(j) is not null
            and l_branch_flag_errors(j) is not null
            and l_disadv_8a_ind_errors(j) is not null
            and l_labor_surplus_errors(j) is not null
            and l_oob_errors(j) is not null
            and l_parent_sub_errors(j) is not null
            and l_pub_ownership_errors(j) is not null
            and l_small_bus_errors(j) is not null
            and l_tot_emp_est_errors(j) is not null
            and l_tot_emp_min_errors(j) is not null
            and l_tot_emp_ind_errors(j) is not null
            and l_woman_own_errors(j) is not null
            and l_emp_pri_adr_est_ind_errors(j) is not null
            and l_emp_pri_adr_est_min_errors(j) is not null
            and l_marital_status_errors(j) is not null
            and l_gender_errors(j) is not null
            and l_person_iden_type_errors(j) is not null
            and l_createdby_errors(j) is not null
            and l_party_name_update_errors(j) is not null
            and l_contact_title_errors(j) is not null
            and l_deceased_flag_errors(j) is not null
            and l_head_of_household_errors(j) is not null
            and l_birth_date_errors(j) is not null
            and l_death_date_errors(j) is not null
            and l_birth_death_errors(j) is not null
            and l_action_mismatch_errors(j) is not null
            and l_flex_val_errors(j) = 0
            and l_dss_security_errors(j) = 'T'
            and l_party_name(j) is not null
            and l_tca_party_id(j) is not null;
    ELSE
        /* Update hz_parties */
        ForAll j in 1..l_party_orig_system_reference.count SAVE EXCEPTIONS
          update hz_parties set
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
 	    LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
  	    SALUTATION =
                   DECODE(l_salutation(j),
                   	  NULL, salutation,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_salutation(j)),
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
  	    ATTRIBUTE21 =
                   DECODE(l_attr21(j),
                   	  NULL, attribute21,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr21(j)),
  	    ATTRIBUTE22 =
                   DECODE(l_attr22(j),
                   	  NULL, attribute22,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr22(j)),
  	    ATTRIBUTE23 =
                   DECODE(l_attr23(j),
                   	  NULL, attribute23,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr23(j)),
  	    ATTRIBUTE24 =
                   DECODE(l_attr24(j),
                   	  NULL, attribute24,
                   	  P_DML_RECORD.GMISS_CHAR, NULL,
                   	  l_attr24(j)),
            REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and l_party_type_errors(j) is not null
            and l_month_errors(j) is not null
            and l_legal_status_errors(j) is not null
            and l_local_bus_iden_type_errors(j) is not null
            and l_reg_type_errors(j) is not null
            and l_own_rent_errors(j) is not null
            and l_hq_branch_errors(j) is not null
            and l_minority_owned_errors(j) is not null
            and l_gsa_errors(j) is not null
            and l_import_errors(j) is not null
            and l_export_errors(j) is not null
            and l_branch_flag_errors(j) is not null
            and l_disadv_8a_ind_errors(j) is not null
            and l_labor_surplus_errors(j) is not null
            and l_oob_errors(j) is not null
            and l_parent_sub_errors(j) is not null
            and l_pub_ownership_errors(j) is not null
            and l_small_bus_errors(j) is not null
            and l_tot_emp_est_errors(j) is not null
            and l_tot_emp_min_errors(j) is not null
            and l_tot_emp_ind_errors(j) is not null
            and l_woman_own_errors(j) is not null
            and l_emp_pri_adr_est_ind_errors(j) is not null
            and l_emp_pri_adr_est_min_errors(j) is not null
            and l_marital_status_errors(j) is not null
            and l_contact_title_errors(j) is not null
            and l_deceased_flag_errors(j) is not null
            and l_head_of_household_errors(j) is not null
            and l_birth_date_errors(j) is not null
            and l_death_date_errors(j) is not null
            and l_birth_death_errors(j) is not null
            and l_action_mismatch_errors(j) is not null
            and l_flex_val_errors(j) = 0
            and l_dss_security_errors(j) = 'T'
            and l_party_name(j) is not null
            and l_gender_errors(j) is not null
            and l_person_iden_type_errors(j) is not null
            and l_createdby_errors(j) is not null
            and l_party_name_update_errors(j) is not null
            and l_tca_party_id(j) is not null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other exceptions');
      l_dml_exception := 'Y';
  END;

  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_party_orig_system_reference count = ' || l_party_orig_system_reference.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  report_errors(P_DML_RECORD, l_dml_exception);


    IF P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION' THEN
      IF l_org_mixnmatch_enabled = 'N' THEN

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'mixnmatch disabled AND version profile = NEW_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Insert new org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : disabled            ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
            USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j),
            l_content_source_type, l_actual_content_source;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'End date current org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /*************************************************/
        /*** End date current HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : disabled  	       ***/
        /*** Version Profile: NEW_VERSION	       ***/
        /*************************************************/

        -- End date current profile and save the profile ids.
        -- Then use the profile ids for copying values to new profile
        ForAll j in 1..l_party_orig_system_reference.count
          update hz_organization_profiles op1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'ORGANIZATION'
            and content_source_type = l_content_source_type
            and actual_content_source = l_actual_content_source
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;

      END IF; -- l_org_mixnmatch_enabled = 'N'

      IF l_per_mixnmatch_enabled = 'N' THEN

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Insert new per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /********************************************/
        /*** Insert into HZ_PERSON_PROFILES       ***/
        /*** Mix and Match  : disabled  	  ***/
        /*** Version Profile: NEW_VERSION	  ***/
        /********************************************/

        -- mixnmatch disabled and version = NEW_VERSION

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j),
            l_content_source_type, l_actual_content_source;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'End date current per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /********************************************/
        /*** End date current HZ_PERSON_PROFILES  ***/
        /*** Mix and Match  : disabled       	  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        -- mixnmatch disabled and version = NEW_VERSION
        -- End date current profile and save the profile ids.
        -- Then use the profile ids for copying values to new profile
        ForAll j in 1..l_party_orig_system_reference.count
          update hz_person_profiles pp1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'PERSON'
            and content_source_type = l_content_source_type
            and actual_content_source = l_actual_content_source
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;

      END IF; -- l_per_mixnmatch_enabled = 'N'
    END IF; -- P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION'


    IF P_DML_RECORD.PROFILE_VERSION = 'NO_VERSION' THEN
      IF l_org_mixnmatch_enabled = 'N' THEN
        -- mixnmatch disabled and version = NO_VERSION
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'mixnmatch disabled AND version profile = NO_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Update org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /********************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	  ***/
        /*** Mix and Match  : disabled  	  ***/
        /*** Version Profile: NO_VERSION	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''ORGANIZATION''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;

      END IF; -- l_org_mixnmatch_enabled = 'N'

      IF l_per_mixnmatch_enabled = 'N' THEN
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : disabled  	***/
        /*** Version Profile: NO_VERSION  	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''PERSON''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;

      END IF; -- l_per_mixnmatch_enabled = 'N'
    END IF; -- P_DML_RECORD.PROFILE_VERSION = 'NO_VERSION'


    IF P_DML_RECORD.PROFILE_VERSION = 'ONE_DAY_VERSION' THEN
      IF l_org_mixnmatch_enabled = 'N' THEN
        -- mixnmatch disabled and version = ONE_DAY_VERSION
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'mixnmatch disabled AND version profile = ONE_DAY_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : disabled  	***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/

    /* For org profiles that have effective_start_date = sysdate,
       update the current profile. */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Update org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''ORGANIZATION''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;


        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : disabled            ***/
        /*** Version Profile: ONE_DAY_VERSION     ***/
        /********************************************/
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Insert org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and :l_party_type = ''ORGANIZATION''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;


        /********************************************/
        /*** End date HZ_ORGANIZATION_PROFILES    ***/
        /*** Mix and Match  : disabled   	  ***/
        /*** Version Profile: ONE_DAY_VERSION     ***/
        /********************************************/

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'End date org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      update hz_organization_profiles op1 set
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
        VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
      where
        party_id = l_party_id(j)
        and EFFECTIVE_END_DATE is null
        and l_num_row_processed(j) = 1
        and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
        and l_party_type(j) = 'ORGANIZATION'
        and content_source_type = l_content_source_type
        and actual_content_source = l_actual_content_source
        and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


      END IF; -- l_org_mixnmatch_enabled = 'N'

      IF l_per_mixnmatch_enabled = 'N' THEN

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : disabled  	***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/

    /* For person profiles that have effective_start_date = sysdate,
       update the current profile. */
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''PERSON''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      l_content_source_type, l_actual_content_source;


    /* For person profiles that have effective_start_date <> P_DML_RECORD.SYSDATE,
       we should create a new profile and end date the old one */



        /******************************************/
        /*** Insert into HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : disabled  	***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Insert person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and :l_party_type = ''PERSON''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
         USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;


        /******************************************/
        /*** End date HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : disabled  	***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'End date person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

     ForAll j in 1..l_party_orig_system_reference.count
       update hz_person_profiles pp1 set
         LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
         LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	 REQUEST_ID = P_DML_RECORD.REQUEST_ID,
         PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
         PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
       where
         party_id = l_party_id(j)
         and EFFECTIVE_END_DATE is null
         and l_num_row_processed(j) = 1
         and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
         and l_party_type(j) = 'PERSON'
         and content_source_type = l_content_source_type
         and actual_content_source = l_actual_content_source
         and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;

      END IF; -- l_per_mixnmatch_enabled = 'N'
    END IF; -- P_DML_RECORD.PROFILE_VERSION = 'ONE_DAY_VERSION'


    IF l_org_mixnmatch_enabled = 'N' AND
       l_content_source_type <> 'USER_ENTERED' THEN
        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : disabled            ***/
        /********************************************/
        /* Insert new org profile if content source is 3rd party and
           3rd party data not exists */

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Insert into hz_organization_profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      ForAll j in 1..l_party_orig_system_reference.count
      insert into hz_organization_profiles
      (
        ORGANIZATION_PROFILE_ID,
        PARTY_ID,
        ORGANIZATION_NAME,
        CEO_NAME,
        CEO_TITLE,
        PRINCIPAL_NAME,
        PRINCIPAL_TITLE,
        LEGAL_STATUS,
        CONTROL_YR,
        EMPLOYEES_TOTAL,
        HQ_BRANCH_IND,
        OOB_IND,
        LINE_OF_BUSINESS,
        CONG_DIST_CODE,
        IMPORT_IND,
        EXPORT_IND,
        BRANCH_FLAG,
        LABOR_SURPLUS_IND,
        MINORITY_OWNED_IND,
        MINORITY_OWNED_TYPE,
        WOMAN_OWNED_IND,
        DISADV_8A_IND,
        SMALL_BUS_IND,
        RENT_OWN_IND,
        ORGANIZATION_NAME_PHONETIC,
        TAX_REFERENCE,
        GSA_INDICATOR_FLAG,
        JGZZ_FISCAL_CODE,
        ANALYSIS_FY,
        FISCAL_YEAREND_MONTH,
        CURR_FY_POTENTIAL_REVENUE,
        NEXT_FY_POTENTIAL_REVENUE,
        YEAR_ESTABLISHED,
        MISSION_STATEMENT,
        ORGANIZATION_TYPE,
        BUSINESS_SCOPE,
        CORPORATION_CLASS,
        KNOWN_AS,
        LOCAL_BUS_IDEN_TYPE,
        LOCAL_BUS_IDENTIFIER,
        PREF_FUNCTIONAL_CURRENCY,
        REGISTRATION_TYPE,
        TOTAL_EMPLOYEES_TEXT,
        TOTAL_EMPLOYEES_IND,
        TOTAL_EMP_EST_IND,
        TOTAL_EMP_MIN_IND,
        PARENT_SUB_IND,
        INCORP_YEAR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        CONTENT_SOURCE_TYPE,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        PUBLIC_PRIVATE_OWNERSHIP_FLAG,
        EMP_AT_PRIMARY_ADR,
        EMP_AT_PRIMARY_ADR_TEXT,
        EMP_AT_PRIMARY_ADR_EST_IND,
        EMP_AT_PRIMARY_ADR_MIN_IND,
        INTERNAL_FLAG,
        TOTAL_PAYMENTS,
        KNOWN_AS2,
        KNOWN_AS3,
        KNOWN_AS4,
        KNOWN_AS5,
        DISPLAYED_DUNS_PARTY_ID,
        DUNS_NUMBER_C,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        APPLICATION_ID,
        DO_NOT_CONFUSE_WITH,
        ACTUAL_CONTENT_SOURCE
      )
      select
        hz_organization_profiles_s.nextval,
        l_party_id(j), -- assume l_party_id cannot be null or G_MISS
        nvl(l_organization_name(j), l_party_name(j)),
        decode(l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_ceo_name(j)),
        decode(l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_ceo_title(j)),
        decode(l_principal_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_principal_name(j)),
        decode(l_principal_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_principal_title(j)),
        decode(l_legal_status(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_legal_status(j)),
        decode(l_control_yr(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_control_yr(j)),
        decode(l_employees_total(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_employees_total(j)),
        decode(l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_hq_branch_ind(j)),
        decode(l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_oob_ind(j)),
        decode(l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_line_of_business(j)),
        decode(l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_cong_dist_code(j)),
        decode(l_import_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_import_ind(j)),
        decode(l_export_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_export_ind(j)),
        decode(l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_branch_flag(j)),
        decode(l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_labor_surplus_ind(j)),
        decode(l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_minority_owned_ind(j)),
        decode(l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_minority_owned_type(j)),
        decode(l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_woman_owned_ind(j)),
        decode(l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_disadv_8a_ind(j)),
        decode(l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_small_bus_ind(j)),
        decode(l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_rent_own_ind(j)),
        decode(l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_organization_name_phonetic(j)),
        decode(l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_tax_reference(j)),
        decode(l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_gsa_indicator_flag(j)),
        decode(l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_jgzz_fiscal_code(j)),
        decode(l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_analysis_fy(j)),
        decode(l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_fiscal_yearend_month(j)),
        decode(l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_curr_fy_potential_revenue(j)),
        decode(l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_next_fy_potential_revenue(j)),
        decode(l_year_established(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_year_established(j)),
        decode(l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_mission_statement(j)),
        decode(l_organization_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_organization_type(j)),
        decode(l_business_scope(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_business_scope(j)),
        decode(l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_corporation_class(j)),
        decode(l_known_as(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as(j)),
        decode(l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_local_bus_iden_type(j)),
        decode(l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_local_bus_identifier(j)),
        decode(l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_pref_functional_currency(j)),
        decode(l_registration_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_registration_type(j)),
        decode(l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_employees_text(j)),
        decode(l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_employees_ind(j)),
        decode(l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_emp_est_ind(j)),
        decode(l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_emp_min_ind(j)),
        decode(l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_parent_sub_ind(j)),
        decode(l_incorp_year(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_incorp_year(j)),
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE,
        l_content_source_type,
        P_DML_RECORD.SYSDATE, --EFFECTIVE_START_DATE,
        null, --EFFECTIVE_END_DATE,
        decode(l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_public_private_flag(j)),
        decode(l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr(j)),
        decode(l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_text(j)),
        decode(l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_est_ind(j)),
        decode(l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_min_ind(j)),
        'N', --INTERNAL_FLAG,
        decode(l_total_payments(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_total_payments(j)),
        decode(l_known_as2(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as2(j)),
        decode(l_known_as3(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as3(j)),
        decode(l_known_as4(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as4(j)),
        decode(l_known_as5(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as5(j)),
        decode(l_party_id(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_party_id(j)),  --DISPLAYED_DUNS_PARTY_ID,
        decode(l_duns_c(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_duns_c(j)),
        1,
        decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, 'HZ_IMPORT',
               NULL, 'HZ_IMPORT', l_created_by_module(j)),
        P_DML_RECORD.APPLICATION_ID, --APPLICATION_ID,
        decode(l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_do_not_confuse_with(j)),
        l_actual_content_source  --  ACTUAL_CONTENT_SOURCE
      from dual
      where
        l_num_row_processed(j) = 1
        and l_party_type(j) = 'ORGANIZATION'
        and not exists (select 1 from hz_organization_profiles op2
        		where op2.content_source_type = l_content_source_type
        		and op2.actual_content_source = l_actual_content_source
        		and op2.party_id = l_party_id(j));

    END IF; -- l_org_mixnmatch_enabled = 'N' AND l_content_source_type <> 'USER_ENTERED'

    IF l_per_mixnmatch_enabled = 'N' AND
       l_content_source_type <> 'USER_ENTERED' THEN

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Insert into hz_person_profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      insert into hz_person_profiles
      (
        PERSON_PROFILE_ID,
        PARTY_ID,
        PERSON_NAME,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        PERSON_PRE_NAME_ADJUNCT,
        PERSON_FIRST_NAME,
        PERSON_MIDDLE_NAME,
        PERSON_LAST_NAME,
        PERSON_NAME_SUFFIX,
        PERSON_TITLE,
        PERSON_ACADEMIC_TITLE,
        PERSON_PREVIOUS_LAST_NAME,
        PERSON_INITIALS,
        KNOWN_AS,
        PERSON_NAME_PHONETIC,
        PERSON_FIRST_NAME_PHONETIC,
        PERSON_LAST_NAME_PHONETIC,
        TAX_REFERENCE,
        JGZZ_FISCAL_CODE,
        PERSON_IDEN_TYPE,
        PERSON_IDENTIFIER,
        DATE_OF_BIRTH,
        PLACE_OF_BIRTH,
        DATE_OF_DEATH,
        GENDER,
        DECLARED_ETHNICITY,
        MARITAL_STATUS,
        MARITAL_STATUS_EFFECTIVE_DATE,
        PERSONAL_INCOME,
        HEAD_OF_HOUSEHOLD_FLAG,
        HOUSEHOLD_INCOME,
        HOUSEHOLD_SIZE,
        RENT_OWN_IND,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        CONTENT_SOURCE_TYPE,
        INTERNAL_FLAG,
        KNOWN_AS2,
        KNOWN_AS3,
        KNOWN_AS4,
        KNOWN_AS5,
        MIDDLE_NAME_PHONETIC,
        OBJECT_VERSION_NUMBER,
        APPLICATION_ID,
        ACTUAL_CONTENT_SOURCE,
        DECEASED_FLAG,
        CREATED_BY_MODULE
      )
      select
        hz_person_profiles_s.nextval,
        l_party_id(j),
        nvl(l_person_name(j), l_party_name(j)),
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE,
        decode(l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_pre_name_adjunct(j)),
        decode(l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_first_name(j)),
        decode(l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_middle_name(j)),
        decode(l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_last_name(j)),
        decode(l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_name_suffix(j)),
        decode(l_person_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_title(j)),
        decode(l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_academic_title(j)),
        decode(l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_previous_last_name(j)),
        decode(l_person_initials(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_initials(j)),
        decode(l_known_as(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as(j)),
        decode(l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_name_phonetic(j)),
        decode(l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_first_name_phonetic(j)),
        decode(l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_last_name_phonetic(j)),
        decode(l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_tax_reference(j)),
        decode(l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_jgzz_fiscal_code(j)),
        decode(l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_iden_type(j)),
        decode(l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_identifier(j)),
        decode(l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_date_of_birth(j)),
        decode(l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_place_of_birth(j)),
        decode(l_date_of_death(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_date_of_death(j)),
        decode(l_gender(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_gender(j)),
        decode(l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_declared_ethnicity(j)),
        decode(l_marital_status(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_marital_status(j)),
        decode(l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_marital_status_eff_date(j)),
        decode(l_personal_income(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_personal_income(j)),
        decode(l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_head_of_household_flag(j)),
        decode(l_household_income(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_household_income(j)),
        decode(l_household_size(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_household_size(j)),
        decode(l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_rent_own_ind(j)),
        P_DML_RECORD.SYSDATE, --EFFECTIVE_START_DATE,
        null, --EFFECTIVE_END_DATE,
        l_content_source_type, -- CONTENT_SOURCE_TYPE
        'N', --INTERNAL_FLAG,
        decode(l_known_as2(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as2(j)),
        decode(l_known_as3(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as3(j)),
        decode(l_known_as4(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as4(j)),
        decode(l_known_as5(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as5(j)),
        decode(l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_middle_name_phonetic(j)),
        1, -- OBJECT_VERSION_NUMBER,
        P_DML_RECORD.APPLICATION_ID,
        l_actual_content_source, -- ACTUAL_CONTENT_SOURCE
        decode(l_deceased_flag(j), NULL, decode(l_date_of_death(j), null, 'N', P_DML_RECORD.GMISS_DATE, 'N', 'Y'),
               P_DML_RECORD.GMISS_CHAR, decode(l_date_of_death(j), null, 'N', P_DML_RECORD.GMISS_DATE, 'N', 'Y'),
 	       l_deceased_flag(j)),
        decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, 'HZ_IMPORT',
          NULL, 'HZ_IMPORT', l_created_by_module(j))
      from dual
      where
        l_num_row_processed(j) = 1
        and l_party_type(j) = 'PERSON'
        and not exists (select 1 from hz_person_profiles pp2        -- Bug 6398209
        		where pp2.content_source_type = l_content_source_type
        		and pp2.actual_content_source = l_actual_content_source
        		and pp2.party_id = l_party_id(j));
    END IF; -- l_per_mixnmatch_enabled = 'N' AND l_content_source_type <> 'USER_ENTERED'

      IF l_content_source_type = 'USER_ENTERED' THEN
        IF P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION' THEN
        -- mixnmatch enabled and cst = USER_ENTERED and version = NEW_VERSION

          IF l_org_mixnmatch_enabled = 'Y' THEN

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = USER_ENTERED AND version profile = NEW_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		hz_utility_v2pub.debug(p_message=>'Handle records with no DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		hz_utility_v2pub.debug(p_message=>'Insert new org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /* Handle records with no DNB data */

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED 	  ***/
        /*** Has no DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

    /* Check if any UE/UE records exist and not l_content_source_type/
       l_actual_content_source because there might be some DNB data loaded
       but the current OS is another 3rd party system. So if UE/UE record
       exists, we should update it */
    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''SST''
            and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = ''USER_ENTERED''
                            and op2.actual_content_source = ''USER_ENTERED''
                            and :l_party_id = op2.party_id)'
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), l_party_id(j);

        /*************************************************/
        /*** End date current HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		       ***/
        /*** Orig system    : USER_ENTERED 	       ***/
        /*** Has no DNB data  			       ***/
        /*** Version Profile: NEW_VERSION              ***/
        /*************************************************/

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'End date current org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        -- End date current profile and save the profile ids.
        -- Then use the profile ids for copying values to new profile
        ForAll j in 1..l_party_orig_system_reference.count
          update hz_organization_profiles op1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'ORGANIZATION'
            and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            and ACTUAL_CONTENT_SOURCE = 'SST'
            and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = 'USER_ENTERED'
                            and op2.actual_content_source = 'USER_ENTERED'
                            and op1.party_id = op2.party_id)
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN -- mixnmatch enabled

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert new per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /********************************************/
        /*** Insert into HZ_PERSON_PROFILES 	  ***/
        /*** Mix and Match  : enabled  	  	  ***/
        /*** Orig system    : USER_ENTERED	  ***/
        /*** Has no DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''SST''
            and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = ''USER_ENTERED''
                            and pp2.actual_content_source = ''USER_ENTERED''
                            and :party_id = pp2.party_id)'
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), l_party_id(j);

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date current per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /********************************************/
        /*** End date current HZ_PERSON_PROFILES  ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED 	  ***/
        /*** Has no DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          update hz_person_profiles pp1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'PERSON'
            and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            and ACTUAL_CONTENT_SOURCE = 'SST'
            and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = 'USER_ENTERED'
                            and pp2.actual_content_source = 'USER_ENTERED'
                            and pp1.party_id = pp2.party_id)
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_per_mixnmatch_enabled = 'Y'

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Handle records with DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /* Handle records with DNB data */

          IF l_org_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert new org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED	  ***/
        /*** Has DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j);

        /*************************************************/
        /*** End date current HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled		       ***/
        /*** Orig system    : USER_ENTERED 	       ***/
        /*** Has DNB data   			       ***/
        /*** Version Profile: NEW_VERSION  	       ***/
        /*************************************************/

        -- End date current profile and save the profile ids.
        -- Then use the profile ids for copying values to new profile
        ForAll j in 1..l_party_orig_system_reference.count
          update hz_organization_profiles op1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'ORGANIZATION'
            and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            and ACTUAL_CONTENT_SOURCE = 'USER_ENTERED'
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert new per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /********************************************/
        /*** Insert into HZ_PERSON_PROFILES 	  ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED 	  ***/
        /*** Has DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date current per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        /********************************************/
        /*** End date current HZ_PERSON_PROFILES  ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED 	  ***/
        /*** Has DNB data   			  ***/
        /*** Version Profile: NEW_VERSION  	  ***/
        /********************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          update hz_person_profiles pp1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'PERSON'
            and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            and ACTUAL_CONTENT_SOURCE = 'USER_ENTERED'
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_per_mixnmatch_enabled = 'Y'

        ELSIF P_DML_RECORD.PROFILE_VERSION = 'NO_VERSION' THEN
        -- mixnmatch enabled and cst = USER_ENTERED and version = NO_VERSION

          IF l_org_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = USER_ENTERED AND version profile = NO_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'Handle records with no DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'Update org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has no DNB data   			***/
        /*** Version Profile: NO_VERSION  	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''ORGANIZATION''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''SST''
             and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = ''USER_ENTERED''
                            and op2.actual_content_source = ''USER_ENTERED''
                            and op1.party_id = op2.party_id)'
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
       	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j);

          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has no DNB data   			***/
        /*** Version Profile: NO_VERSION  	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''PERSON''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''SST''
             and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = ''USER_ENTERED''
                            and pp2.actual_content_source = ''USER_ENTERED''
                            and pp1.party_id = pp2.party_id)'
            USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j);

          END IF; -- l_per_mixnmatch_enabled = 'Y'
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Handle records with DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

          IF l_org_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has DNB data   			***/
        /*** Version Profile: NO_VERSION  	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''ORGANIZATION''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j);

          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has DNB data   			***/
        /*** Version Profile: NO_VERSION  	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''PERSON''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
            USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j);

          END IF; -- l_per_mixnmatch_enabled = 'Y'

        ELSIF P_DML_RECORD.PROFILE_VERSION = 'ONE_DAY_VERSION' THEN
        -- mixnmatch enabled and cst = USER_ENTERED and version = ONE_DAY_VERSION

          IF l_org_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = USER_ENTERED AND version profile = ONE_DAY_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has no DNB data   			***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/

    /* For org profiles that have effective_start_date = sysdate,
       update the current profile. */
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Handle records with no DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'Update org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''ORGANIZATION''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''SST''
             and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = ''USER_ENTERED''
                            and op2.actual_content_source = ''USER_ENTERED''
                            and op1.party_id = op2.party_id)'

      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j);


        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED 	  ***/
        /*** Has no DNB data   			  ***/
        /*** Version Profile: ONE_DAY_VERSION     ***/
        /********************************************/

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''SST''
            and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = ''USER_ENTERED''
                            and op2.actual_content_source = ''USER_ENTERED''
                            and :l_party_id = op2.party_id)'
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), trunc(P_DML_RECORD.SYSDATE), l_party_id(j);

        /******************************************/
        /*** End date HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Has no DNB data   			***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      update hz_organization_profiles op1 set
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
        VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
      where
        party_id = l_party_id(j)
        and EFFECTIVE_END_DATE is null
        and l_num_row_processed(j) = 1
        and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
        and l_party_type(j) = 'ORGANIZATION'
        and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
        and ACTUAL_CONTENT_SOURCE = 'SST'
        and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = 'USER_ENTERED'
                            and op2.actual_content_source = 'USER_ENTERED'
                            and op1.party_id = op2.party_id)
        and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

         /*****************************************/
         /*** Update HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has no DNB data   		***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/

	 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''PERSON''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''SST''
             and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = ''USER_ENTERED''
                            and pp2.actual_content_source = ''USER_ENTERED''
                            and :l_party_id = pp2.party_id)'
      	    USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j), l_party_id(j);


         /*****************************************/
         /*** Insert into HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has no DNB data   		***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/

	 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''SST''
            and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = ''USER_ENTERED''
                            and pp2.actual_content_source = ''USER_ENTERED''
                            and :l_party_id = pp2.party_id)'
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), trunc(P_DML_RECORD.SYSDATE), l_party_id(j);


         /*****************************************/
         /*** End date HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has no DNB data   		***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

     ForAll j in 1..l_party_orig_system_reference.count
       update hz_person_profiles pp1 set
         LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
         LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	 REQUEST_ID = P_DML_RECORD.REQUEST_ID,
         PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
         PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
       where
         party_id = l_party_id(j)
         and EFFECTIVE_END_DATE is null
         and l_num_row_processed(j) = 1
         and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
         and l_party_type(j) = 'PERSON'
         and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
         and ACTUAL_CONTENT_SOURCE = 'SST'
         and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = 'USER_ENTERED'
                            and pp2.actual_content_source = 'USER_ENTERED'
                            and pp1.party_id = pp2.party_id)
         and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


         END IF; -- l_per_mixnmatch_enabled = 'Y'

	 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Handle records with DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;

         IF l_org_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : USER_ENTERED 	***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /*** Has DNB data   			***/
        /******************************************/

    /* For org profiles that have effective_start_date = sysdate,
       update the current profile. */
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''ORGANIZATION''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j);

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : USER_ENTERED	  ***/
        /*** Has DNB data   			  ***/
        /*** Version Profile: ONE_DAY_VERSION  	  ***/
        /********************************************/

       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), trunc(P_DML_RECORD.SYSDATE);

        /********************************************/
        /*** End date HZ_ORGANIZATION_PROFILES 	  ***/
        /*** Mix and Match  : enabled 		  ***/
        /*** Orig system    : USER_ENTERED	  ***/
        /*** Version Profile: ONE_DAY_VERSION	  ***/
        /*** Has DNB data   			  ***/
        /********************************************/

       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      update hz_organization_profiles op1 set
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
        VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
      where
        party_id = l_party_id(j)
        and EFFECTIVE_END_DATE is null
        and l_num_row_processed(j) = 1
        and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
        and l_party_type(j) = 'ORGANIZATION'
        and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
        and ACTUAL_CONTENT_SOURCE = 'USER_ENTERED'
        and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

         /*****************************************/
         /*** Update HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has DNB data   			***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/

       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''PERSON''
             and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
             and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
      	    USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j);


         /*****************************************/
         /*** Insert into HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has DNB data   			***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and CONTENT_SOURCE_TYPE = ''USER_ENTERED''
            and ACTUAL_CONTENT_SOURCE = ''USER_ENTERED'''
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), trunc(P_DML_RECORD.SYSDATE);


         /*****************************************/
         /*** End date HZ_PERSON_PROFILES 	***/
         /*** Mix and Match  : enabled  	***/
         /*** Orig system    : USER_ENTERED 	***/
         /*** Has DNB data   			***/
         /*** Version Profile: ONE_DAY_VERSION  ***/
         /*****************************************/

       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

     ForAll j in 1..l_party_orig_system_reference.count
       update hz_person_profiles pp1 set
         LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
         LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	 REQUEST_ID = P_DML_RECORD.REQUEST_ID,
         PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
         PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
       where
         party_id = l_party_id(j)
         and EFFECTIVE_END_DATE is null
         and l_num_row_processed(j) = 1
         and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
         and l_party_type(j) = 'PERSON'
         and CONTENT_SOURCE_TYPE = 'USER_ENTERED'
         and ACTUAL_CONTENT_SOURCE = 'USER_ENTERED'
         and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_per_mixnmatch_enabled = 'Y'

        END IF; -- P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION'

      ELSE /* l_content_source_type = 3rd party */

        IF P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION' THEN
        -- mixnmatch enabled and cst = 3rd party and version = NEW_VERSION

          IF l_org_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = 3rd party AND version profile = NEW_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Version Profile: NEW_VERSION	  ***/
        /*** Orig system    : 3rd Party		  ***/
        /*** With existing 3rd party data	  ***/
        /********************************************/

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j),
            l_content_source_type, l_actual_content_source;

        /*************************************************/
        /*** End date current HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		       ***/
        /*** Version Profile: NEW_VERSION 	       ***/
        /*** Orig system    : 3rd Party 	       ***/
        /*** With existing 3rd party data 	       ***/
        /*************************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'update org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          update hz_organization_profiles op1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'ORGANIZATION'
            and content_source_type = l_content_source_type
            and actual_content_source = l_actual_content_source
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Insert into HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: NEW_VERSION  	***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert new per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''PERSON''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j),
            l_content_source_type, l_actual_content_source;


        /********************************************/
        /*** End date current HZ_PERSON_PROFILES  ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Version Profile: NEW_VERSION	  ***/
        /*** Orig system    : 3rd Party	 	  ***/
        /*** With existing 3rd party data	  ***/
        /********************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date current per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          update hz_person_profiles pp1 set
            LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
            LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
            LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	    REQUEST_ID = P_DML_RECORD.REQUEST_ID,
            PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
            PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
            PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
	    EFFECTIVE_END_DATE = DECODE(TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE),
            				TRUNC(EFFECTIVE_START_DATE), TRUNC(P_DML_RECORD.SYSDATE-1)),
            OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
            VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
          where
            party_id = l_party_id(j)
            and EFFECTIVE_END_DATE is null
            and l_num_row_processed(j) = 1
            and l_party_type(j) = 'PERSON'
            and content_source_type = l_content_source_type
            and actual_content_source = l_actual_content_source
            and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_per_mixnmatch_enabled = 'Y'

        ELSIF P_DML_RECORD.PROFILE_VERSION = 'NO_VERSION' THEN
        -- mixnmatch enabled and cst = 3rd party and version = NO_VERSION

          IF l_org_mixnmatch_enabled = 'Y' THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = 3rd party AND version profile = NO_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'Update org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled 		***/
        /*** Version Profile: NO_VERSION  	***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''ORGANIZATION''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;

          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: NO_VERSION  	***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and :l_party_type = ''PERSON''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
            USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;

          END IF; -- l_per_mixnmatch_enabled = 'Y'

        ELSIF P_DML_RECORD.PROFILE_VERSION = 'ONE_DAY_VERSION' THEN
        -- mixnmatch enabled and cst = 3rd party and version = ONE_DAY_VERSION
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'mixnmatch enabled AND cst = 3rd party AND version profile = ONE_DAY_VERSION',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;

          IF l_org_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Update HZ_ORGANIZATION_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: ONE_DAY_VERSION  	***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_org_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''ORGANIZATION''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
      	    l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
      	    l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
      	    l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
      	    l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
      	    l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
      	    l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
      	    l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
      	    l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
      	    l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
      	    l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
      	    l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
      	    l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
      	    l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
      	    l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
      	    l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
      	    l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
      	    l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
      	    l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
      	    l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
      	    l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
      	    l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
      	    l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
      	    l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
      	    l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
      	    l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
      	    l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
      	    l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
      	    l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
      	    l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
      	    l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
      	    l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
      	    l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
      	    l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
      	    l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
      	    l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
      	    l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
      	    l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
      	    l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
      	    l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
      	    l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
      	    l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
      	    l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_party_orig_system(j), l_displayed_duns(j),
      	      l_party_orig_system_reference(j), l_party_id(j),
      	    l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
      	    l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;



        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Version Profile: ONE_DAY_VERSION     ***/
        /*** Orig system    : 3rd Party 	  ***/
        /*** With existing 3rd party data 	  ***/
        /********************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'insert org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_org_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and :l_party_type = ''ORGANIZATION''
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
            l_organization_name(j), P_DML_RECORD.GMISS_CHAR, l_organization_name(j),
            l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, l_ceo_name(j),
            l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, l_ceo_title(j),
            l_principal_name(j), P_DML_RECORD.GMISS_CHAR, l_principal_name(j),
            l_principal_title(j), P_DML_RECORD.GMISS_CHAR, l_principal_title(j),
            l_legal_status(j), P_DML_RECORD.GMISS_CHAR, l_legal_status(j),
            l_control_yr(j), P_DML_RECORD.GMISS_NUM, l_control_yr(j),
            l_employees_total(j), P_DML_RECORD.GMISS_NUM, l_employees_total(j),
            l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, l_hq_branch_ind(j),
            l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, l_oob_ind(j),
            l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, l_line_of_business(j),
            l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, l_cong_dist_code(j),
            l_import_ind(j), P_DML_RECORD.GMISS_CHAR, l_import_ind(j),
            l_export_ind(j), P_DML_RECORD.GMISS_CHAR, l_export_ind(j),
            l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, l_branch_flag(j),
            l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, l_labor_surplus_ind(j),
            l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_ind(j),
            l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, l_minority_owned_type(j),
            l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, l_woman_owned_ind(j),
            l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, l_disadv_8a_ind(j),
            l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, l_small_bus_ind(j),
            l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
            l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_organization_name_phonetic(j),
            l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
            l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, l_gsa_indicator_flag(j),
            l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
            l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, l_analysis_fy(j),
            l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, l_fiscal_yearend_month(j),
            l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_curr_fy_potential_revenue(j),
            l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, l_next_fy_potential_revenue(j),
            l_year_established(j), P_DML_RECORD.GMISS_NUM, l_year_established(j),
            l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, l_mission_statement(j),
            l_organization_type(j), P_DML_RECORD.GMISS_CHAR, l_organization_type(j),
            l_business_scope(j), P_DML_RECORD.GMISS_CHAR, l_business_scope(j),
            l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, l_corporation_class(j),
            l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
            l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_iden_type(j),
            l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, l_local_bus_identifier(j),
            l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, l_pref_functional_currency(j),
            l_registration_type(j), P_DML_RECORD.GMISS_CHAR, l_registration_type(j),
            l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_text(j),
            l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_employees_ind(j),
            l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_est_ind(j),
            l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_total_emp_min_ind(j),
            l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, l_parent_sub_ind(j),
            l_incorp_year(j), P_DML_RECORD.GMISS_NUM, l_incorp_year(j),
            P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
            l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, l_public_private_flag(j),
            l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr(j),
            l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_text(j),
            l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_est_ind(j),
            l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, l_emp_at_primary_adr_min_ind(j),
            l_total_payments(j), P_DML_RECORD.GMISS_NUM, l_total_payments(j),
            l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
            l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
            l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
            l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
            l_party_orig_system(j), l_displayed_duns(j),
              l_party_orig_system_reference(j), l_party_id(j),
            l_duns_c(j), P_DML_RECORD.GMISS_CHAR, l_duns_c(j),
            l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, l_do_not_confuse_with(j),
            l_party_id(j), l_num_row_processed(j), l_party_type(j), trunc(P_DML_RECORD.SYSDATE),
            l_content_source_type, l_actual_content_source;

        /******************************************/
        /*** End date HZ_ORGANIZATION_PROFILES  ***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date current org profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      update hz_organization_profiles op1 set
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
        VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
      where
        party_id = l_party_id(j)
        and EFFECTIVE_END_DATE is null
        and l_num_row_processed(j) = 1
        and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
        and content_source_type = l_content_source_type
        and actual_content_source = l_actual_content_source
        and l_party_type(j) = 'ORGANIZATION'
        and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Update HZ_PERSON_PROFILES 		***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Update person profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_update_per_profile ||
            'party_id = :l_party_id
             and EFFECTIVE_END_DATE is null
             and :l_num_row_processed = 1
             and trunc(EFFECTIVE_START_DATE) = :l_sysdate
             and :l_party_type = ''PERSON''
             and content_source_type = :l_content_source_type
             and actual_content_source = :l_actual_content_source'
      	    USING
      	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
      	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
      	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
      	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
      	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
      	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
      	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
      	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
      	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
      	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
      	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
      	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
      	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
      	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
      	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
      	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
      	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
      	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
      	    l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, l_date_of_birth(j),
      	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
      	    l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_date_of_death(j),
      	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
      	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
      	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
      	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, l_marital_status_eff_date(j),
      	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
      	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
      	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
      	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
      	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j),
      	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
      	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
      	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
      	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
      	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
      	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_deceased_flag(j),
      	    l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE), l_party_type(j),
      	    l_content_source_type, l_actual_content_source;


        /******************************************/
        /*** Insert into HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert new per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        ForAll j in 1..l_party_orig_system_reference.count
          EXECUTE IMMEDIATE
            l_insert_per_profile ||
            'party_id = :l_party_id
            and EFFECTIVE_END_DATE is null
            and :l_num_row_processed = 1
            and trunc(EFFECTIVE_START_DATE) < :l_sysdate
            and :l_party_type = ''PERSON''
            and content_source_type = :l_content_source_type
            and actual_content_source = :l_actual_content_source'
	    USING
	    l_person_name(j), P_DML_RECORD.GMISS_CHAR, l_person_name(j),
	    P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN,
            P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
	    l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, l_person_pre_name_adjunct(j),
	    l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name(j),
	    l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name(j),
	    l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name(j),
	    l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, l_person_name_suffix(j),
	    l_person_title(j), P_DML_RECORD.GMISS_CHAR, l_person_title(j),
	    l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, l_person_academic_title(j),
	    l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, l_person_previous_last_name(j),
	    l_person_initials(j), P_DML_RECORD.GMISS_CHAR, l_person_initials(j),
	    l_known_as(j), P_DML_RECORD.GMISS_CHAR, l_known_as(j),
	    l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_name_phonetic(j),
	    l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_first_name_phonetic(j),
	    l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_last_name_phonetic(j),
	    l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, l_tax_reference(j),
	    l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, l_jgzz_fiscal_code(j),
	    l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, l_person_iden_type(j),
	    l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, l_person_identifier(j),
	    l_date_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_date_of_birth(j),
	    l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, l_place_of_birth(j),
	    l_date_of_death(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j),
	    l_gender(j), P_DML_RECORD.GMISS_CHAR, l_gender(j),
	    l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, l_declared_ethnicity(j),
	    l_marital_status(j), P_DML_RECORD.GMISS_CHAR, l_marital_status(j),
	    l_marital_status_eff_date(j), P_DML_RECORD.GMISS_CHAR, l_marital_status_eff_date(j),
	    l_personal_income(j), P_DML_RECORD.GMISS_NUM, l_personal_income(j),
	    l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, l_head_of_household_flag(j),
	    l_household_income(j), P_DML_RECORD.GMISS_NUM, l_household_income(j),
	    l_household_size(j), P_DML_RECORD.GMISS_NUM, l_household_size(j),
	    l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, l_rent_own_ind(j), P_DML_RECORD.SYSDATE,
	    l_known_as2(j), P_DML_RECORD.GMISS_CHAR, l_known_as2(j),
	    l_known_as3(j), P_DML_RECORD.GMISS_CHAR, l_known_as3(j),
	    l_known_as4(j), P_DML_RECORD.GMISS_CHAR, l_known_as4(j),
	    l_known_as5(j), P_DML_RECORD.GMISS_CHAR, l_known_as5(j),
	    l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, l_person_middle_name_phonetic(j),
	    l_deceased_flag(j), P_DML_RECORD.GMISS_CHAR, l_date_of_death(j), P_DML_RECORD.GMISS_DATE, l_deceased_flag(j),
	    l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, l_created_by_module(j),
            l_party_id(j), l_num_row_processed(j), trunc(P_DML_RECORD.SYSDATE) ,l_party_type(j),
            l_content_source_type, l_actual_content_source;


        /******************************************/
        /*** End date HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Version Profile: ONE_DAY_VERSION   ***/
        /*** Orig system    : 3rd Party 	***/
        /*** With existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'End date current per profile',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

     ForAll j in 1..l_party_orig_system_reference.count
       update hz_person_profiles pp1 set
         LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
         LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
	 REQUEST_ID = P_DML_RECORD.REQUEST_ID,
         PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
         PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         EFFECTIVE_END_DATE = TRUNC(P_DML_RECORD.SYSDATE-1),
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         VERSION_NUMBER = NVL(VERSION_NUMBER,1)+1
       where
         party_id = l_party_id(j)
         and EFFECTIVE_END_DATE is null
         and l_num_row_processed(j) = 1
         and trunc(EFFECTIVE_START_DATE) < trunc(P_DML_RECORD.SYSDATE)
         and l_party_type(j) = 'PERSON'
         and content_source_type = l_content_source_type
         and actual_content_source = l_actual_content_source
         and nvl(request_id, -1) <> P_DML_RECORD.REQUEST_ID;


          END IF; -- l_per_mixnmatch_enabled = 'Y'

        END IF; -- P_DML_RECORD.PROFILE_VERSION = 'NEW_VERSION'

          IF l_org_mixnmatch_enabled = 'Y' THEN

        /********************************************/
        /*** Insert into HZ_ORGANIZATION_PROFILES ***/
        /*** Mix and Match  : enabled  		  ***/
        /*** Orig system    : 3rd Party 	  ***/
        /*** Without existing 3rd party data	  ***/
        /********************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Handle records with no existing DNB data',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'Insert org profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

    /* There is no existing DNB data for the party. So, create a new
       profile without getting values from the current user entered profile.
       Insert record after above update or the new record will be processed
       by the updates */
    ForAll j in 1..l_party_orig_system_reference.count
      insert into hz_organization_profiles
      (
        ORGANIZATION_PROFILE_ID,
        PARTY_ID,
        ORGANIZATION_NAME,
        CEO_NAME,
        CEO_TITLE,
        PRINCIPAL_NAME,
        PRINCIPAL_TITLE,
        LEGAL_STATUS,
        CONTROL_YR,
        EMPLOYEES_TOTAL,
        HQ_BRANCH_IND,
        OOB_IND,
        LINE_OF_BUSINESS,
        CONG_DIST_CODE,
        IMPORT_IND,
        EXPORT_IND,
        BRANCH_FLAG,
        LABOR_SURPLUS_IND,
        MINORITY_OWNED_IND,
        MINORITY_OWNED_TYPE,
        WOMAN_OWNED_IND,
        DISADV_8A_IND,
        SMALL_BUS_IND,
        RENT_OWN_IND,
        ORGANIZATION_NAME_PHONETIC,
        TAX_REFERENCE,
        GSA_INDICATOR_FLAG,
        JGZZ_FISCAL_CODE,
        ANALYSIS_FY,
        FISCAL_YEAREND_MONTH,
        CURR_FY_POTENTIAL_REVENUE,
        NEXT_FY_POTENTIAL_REVENUE,
        YEAR_ESTABLISHED,
        MISSION_STATEMENT,
        ORGANIZATION_TYPE,
        BUSINESS_SCOPE,
        CORPORATION_CLASS,
        KNOWN_AS,
        LOCAL_BUS_IDEN_TYPE,
        LOCAL_BUS_IDENTIFIER,
        PREF_FUNCTIONAL_CURRENCY,
        REGISTRATION_TYPE,
        TOTAL_EMPLOYEES_TEXT,
        TOTAL_EMPLOYEES_IND,
        TOTAL_EMP_EST_IND,
        TOTAL_EMP_MIN_IND,
        PARENT_SUB_IND,
        INCORP_YEAR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        CONTENT_SOURCE_TYPE,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        PUBLIC_PRIVATE_OWNERSHIP_FLAG,
        EMP_AT_PRIMARY_ADR,
        EMP_AT_PRIMARY_ADR_TEXT,
        EMP_AT_PRIMARY_ADR_EST_IND,
        EMP_AT_PRIMARY_ADR_MIN_IND,
        INTERNAL_FLAG,
        TOTAL_PAYMENTS,
        KNOWN_AS2,
        KNOWN_AS3,
        KNOWN_AS4,
        KNOWN_AS5,
        DISPLAYED_DUNS_PARTY_ID,
        DUNS_NUMBER_C,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        APPLICATION_ID,
        DO_NOT_CONFUSE_WITH,
        ACTUAL_CONTENT_SOURCE
      )
      select
        hz_organization_profiles_s.nextval,
        l_party_id(j), -- assume l_party_id cannot be null or G_MISS
        nvl(l_organization_name(j), l_party_name(j)),
        decode(l_ceo_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_ceo_name(j)),
        decode(l_ceo_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_ceo_title(j)),
        decode(l_principal_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_principal_name(j)),
        decode(l_principal_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_principal_title(j)),
        decode(l_legal_status(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_legal_status(j)),
        decode(l_control_yr(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_control_yr(j)),
        decode(l_employees_total(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_employees_total(j)),
        decode(l_hq_branch_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_hq_branch_ind(j)),
        decode(l_oob_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_oob_ind(j)),
        decode(l_line_of_business(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_line_of_business(j)),
        decode(l_cong_dist_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_cong_dist_code(j)),
        decode(l_import_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_import_ind(j)),
        decode(l_export_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_export_ind(j)),
        decode(l_branch_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_branch_flag(j)),
        decode(l_labor_surplus_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_labor_surplus_ind(j)),
        decode(l_minority_owned_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_minority_owned_ind(j)),
        decode(l_minority_owned_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_minority_owned_type(j)),
        decode(l_woman_owned_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_woman_owned_ind(j)),
        decode(l_disadv_8a_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_disadv_8a_ind(j)),
        decode(l_small_bus_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_small_bus_ind(j)),
        decode(l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_rent_own_ind(j)),
        decode(l_organization_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_organization_name_phonetic(j)),
        decode(l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_tax_reference(j)),
        decode(l_gsa_indicator_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_gsa_indicator_flag(j)),
        decode(l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_jgzz_fiscal_code(j)),
        decode(l_analysis_fy(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_analysis_fy(j)),
        decode(l_fiscal_yearend_month(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_fiscal_yearend_month(j)),
        decode(l_curr_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_curr_fy_potential_revenue(j)),
        decode(l_next_fy_potential_revenue(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_next_fy_potential_revenue(j)),
        decode(l_year_established(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_year_established(j)),
        decode(l_mission_statement(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_mission_statement(j)),
        decode(l_organization_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_organization_type(j)),
        decode(l_business_scope(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_business_scope(j)),
        decode(l_corporation_class(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_corporation_class(j)),
        decode(l_known_as(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as(j)),
        decode(l_local_bus_iden_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_local_bus_iden_type(j)),
        decode(l_local_bus_identifier(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_local_bus_identifier(j)),
        decode(l_pref_functional_currency(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_pref_functional_currency(j)),
        decode(l_registration_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_registration_type(j)),
        decode(l_total_employees_text(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_employees_text(j)),
        decode(l_total_employees_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_employees_ind(j)),
        decode(l_total_emp_est_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_emp_est_ind(j)),
        decode(l_total_emp_min_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_total_emp_min_ind(j)),
        decode(l_parent_sub_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_parent_sub_ind(j)),
        decode(l_incorp_year(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_incorp_year(j)),
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE,
        l_content_source_type,  -- CONTENT_SOURCE_TYPE
        P_DML_RECORD.SYSDATE, --EFFECTIVE_START_DATE,
        null, --EFFECTIVE_END_DATE,
        decode(l_public_private_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_public_private_flag(j)),
        decode(l_emp_at_primary_adr(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr(j)),
        decode(l_emp_at_primary_adr_text(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_text(j)),
        decode(l_emp_at_primary_adr_est_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_est_ind(j)),
        decode(l_emp_at_primary_adr_min_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_emp_at_primary_adr_min_ind(j)),
        'N', --INTERNAL_FLAG,
        decode(l_total_payments(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_total_payments(j)),
        decode(l_known_as2(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as2(j)),
        decode(l_known_as3(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as3(j)),
        decode(l_known_as4(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as4(j)),
        decode(l_known_as5(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as5(j)),
        decode(l_party_id(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_party_id(j)),  --DISPLAYED_DUNS_PARTY_ID,
        decode(l_duns_c(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_duns_c(j)),
        1,
        decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, 'HZ_IMPORT',
               NULL, 'HZ_IMPORT', l_created_by_module(j)),
        P_DML_RECORD.APPLICATION_ID, --APPLICATION_ID,
        decode(l_do_not_confuse_with(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_do_not_confuse_with(j)),
        l_actual_content_source  --  ACTUAL_CONTENT_SOURCE
      from dual
      where
        l_num_row_processed(j) = 1
        and l_party_type(j) = 'ORGANIZATION'
        and not exists (select 1 from hz_organization_profiles op2
                            where op2.content_source_type = l_content_source_type
                            and op2.actual_content_source = l_actual_content_source
                            and op2.party_id = l_party_id(j)
                            and op2.effective_end_date is null);

          END IF; -- l_org_mixnmatch_enabled = 'Y'

          IF l_per_mixnmatch_enabled = 'Y' THEN

        /******************************************/
        /*** Insert into HZ_PERSON_PROFILES 	***/
        /*** Mix and Match  : enabled  		***/
        /*** Orig system    : 3rd Party 	***/
        /*** Without existing 3rd party data 	***/
        /******************************************/
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Insert into hz_person_profiles',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;

    ForAll j in 1..l_party_orig_system_reference.count
      insert into hz_person_profiles
      (
        PERSON_PROFILE_ID,
        PARTY_ID,
        PERSON_NAME,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        PERSON_PRE_NAME_ADJUNCT,
        PERSON_FIRST_NAME,
        PERSON_MIDDLE_NAME,
        PERSON_LAST_NAME,
        PERSON_NAME_SUFFIX,
        PERSON_TITLE,
        PERSON_ACADEMIC_TITLE,
        PERSON_PREVIOUS_LAST_NAME,
        PERSON_INITIALS,
        KNOWN_AS,
        PERSON_NAME_PHONETIC,
        PERSON_FIRST_NAME_PHONETIC,
        PERSON_LAST_NAME_PHONETIC,
        TAX_REFERENCE,
        JGZZ_FISCAL_CODE,
        PERSON_IDEN_TYPE,
        PERSON_IDENTIFIER,
        DATE_OF_BIRTH,
        PLACE_OF_BIRTH,
        DATE_OF_DEATH,
        GENDER,
        DECLARED_ETHNICITY,
        MARITAL_STATUS,
        MARITAL_STATUS_EFFECTIVE_DATE,
        PERSONAL_INCOME,
        HEAD_OF_HOUSEHOLD_FLAG,
        HOUSEHOLD_INCOME,
        HOUSEHOLD_SIZE,
        RENT_OWN_IND,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        CONTENT_SOURCE_TYPE,
        INTERNAL_FLAG,
        KNOWN_AS2,
        KNOWN_AS3,
        KNOWN_AS4,
        KNOWN_AS5,
        MIDDLE_NAME_PHONETIC,
        OBJECT_VERSION_NUMBER,
        APPLICATION_ID,
        ACTUAL_CONTENT_SOURCE,
        DECEASED_FLAG,
        CREATED_BY_MODULE
      )
      select
        hz_person_profiles_s.nextval,
        l_party_id(j),
        nvl(l_person_name(j), l_party_name(j)),
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE,
        decode(l_person_pre_name_adjunct(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_pre_name_adjunct(j)),
        decode(l_person_first_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_first_name(j)),
        decode(l_person_middle_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_middle_name(j)),
        decode(l_person_last_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_last_name(j)),
        decode(l_person_name_suffix(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_name_suffix(j)),
        decode(l_person_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_title(j)),
        decode(l_person_academic_title(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_academic_title(j)),
        decode(l_person_previous_last_name(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_previous_last_name(j)),
        decode(l_person_initials(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_initials(j)),
        decode(l_known_as(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as(j)),
        decode(l_person_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_name_phonetic(j)),
        decode(l_person_first_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_first_name_phonetic(j)),
        decode(l_person_last_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_last_name_phonetic(j)),
        decode(l_tax_reference(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_tax_reference(j)),
        decode(l_jgzz_fiscal_code(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_jgzz_fiscal_code(j)),
        decode(l_person_iden_type(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_iden_type(j)),
        decode(l_person_identifier(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_identifier(j)),
        decode(l_date_of_birth(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_date_of_birth(j)),
        decode(l_place_of_birth(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_place_of_birth(j)),
        decode(l_date_of_death(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_date_of_death(j)),
        decode(l_gender(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_gender(j)),
        decode(l_declared_ethnicity(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_declared_ethnicity(j)),
        decode(l_marital_status(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_marital_status(j)),
        decode(l_marital_status_eff_date(j), P_DML_RECORD.GMISS_DATE, NULL,
 	       l_marital_status_eff_date(j)),
        decode(l_personal_income(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_personal_income(j)),
        decode(l_head_of_household_flag(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_head_of_household_flag(j)),
        decode(l_household_income(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_household_income(j)),
        decode(l_household_size(j), P_DML_RECORD.GMISS_NUM, NULL,
 	       l_household_size(j)),
        decode(l_rent_own_ind(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_rent_own_ind(j)),
        P_DML_RECORD.SYSDATE, --EFFECTIVE_START_DATE,
        null, --EFFECTIVE_END_DATE,
        l_content_source_type, -- CONTENT_SOURCE_TYPE
        'N', --INTERNAL_FLAG,
        decode(l_known_as2(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as2(j)),
        decode(l_known_as3(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as3(j)),
        decode(l_known_as4(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as4(j)),
        decode(l_known_as5(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_known_as5(j)),
        decode(l_person_middle_name_phonetic(j), P_DML_RECORD.GMISS_CHAR, NULL,
 	       l_person_middle_name_phonetic(j)),
        1, -- OBJECT_VERSION_NUMBER,
        P_DML_RECORD.APPLICATION_ID,
        l_actual_content_source, -- ACTUAL_CONTENT_SOURCE
        decode(l_deceased_flag(j), NULL, decode(l_date_of_death(j), null, 'N', P_DML_RECORD.GMISS_DATE, 'N', 'Y'),
               P_DML_RECORD.GMISS_CHAR, decode(l_date_of_death(j), null, 'N', P_DML_RECORD.GMISS_DATE, 'N', 'Y'),
 	       l_deceased_flag(j)),
        decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, 'HZ_IMPORT',
          NULL, 'HZ_IMPORT', l_created_by_module(j))
      from dual
      where
        l_num_row_processed(j) = 1
        and l_party_type(j) = 'PERSON'
        and not exists (select 1 from hz_person_profiles pp2
                            where pp2.content_source_type = l_content_source_type
                            and pp2.actual_content_source = l_actual_content_source
                            and pp2.party_id = l_party_id(j)
                            and pp2.effective_end_date is null);

          END IF; -- l_org_mixnmatch_enabled = 'Y'

    END IF; -- l_content_source_type = 'USER_ENTERED'


    /******************************************/
    /*           Handle OSR change            */
    /******************************************/

    /* End date current MOSR mapping */
    ForAll j in 1..l_party_orig_system_reference.count
      update HZ_ORIG_SYS_REFERENCES set
        STATUS = 'I',
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
        END_DATE_ACTIVE = P_DML_RECORD.SYSDATE,
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
      where
        ORIG_SYSTEM = l_party_orig_system(j)
        and ORIG_SYSTEM_REFERENCE = l_old_orig_system_reference(j)
        and OWNER_TABLE_NAME = 'HZ_PARTIES'
        and OWNER_TABLE_ID = l_party_id(j)
        and l_num_row_processed(j) = 1
        and status = 'A'
        and trunc(nvl(end_date_active, P_DML_RECORD.SYSDATE)) >= trunc(P_DML_RECORD.SYSDATE);

    /* End date the collided OSR mapping. This can happen in one of two cases:
       1. There is OSR change and the new OSR already has a record in SSM.
          new_osr_exists_flag has value 'Y'.
       2. There is no OSR change. There is a record in SSM with the same OS and OSR
          but different party_id than the one in interface table.
          new_osr_exists_flag has value 'R'. */
    ForAll j in 1..l_party_orig_system_reference.count
      update HZ_ORIG_SYS_REFERENCES set
        STATUS = 'I',
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
        END_DATE_ACTIVE = P_DML_RECORD.SYSDATE,
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
      where
        ORIG_SYSTEM = l_party_orig_system(j)
        and ORIG_SYSTEM_REFERENCE = l_party_orig_system_reference(j)
        and OWNER_TABLE_NAME = 'HZ_PARTIES'
        and l_new_osr_exists(j) in ('Y', 'R')
        and l_num_row_processed(j) = 1
        and status = 'A'
        and trunc(nvl(end_date_active, P_DML_RECORD.SYSDATE)) >= trunc(P_DML_RECORD.SYSDATE);

    /* Insert new MOSR mapping in case of OSR change */
    ForAll j in 1..l_party_orig_system_reference.count
      insert into HZ_ORIG_SYS_REFERENCES
      (
	ORIG_SYSTEM_REF_ID,
	ORIG_SYSTEM,
	ORIG_SYSTEM_REFERENCE,
	OWNER_TABLE_NAME,
	OWNER_TABLE_ID,
	PARTY_ID,
	STATUS,
	OLD_ORIG_SYSTEM_REFERENCE,
	START_DATE_ACTIVE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	CREATED_BY_MODULE,
	APPLICATION_ID,
	OBJECT_VERSION_NUMBER
      )
      select
	HZ_ORIG_SYSTEM_REF_S.NEXTVAL,
	l_party_orig_system(j),
	l_party_orig_system_reference(j),
	'HZ_PARTIES',
	l_party_id(j),
	l_party_id(j),
	'A',
	l_old_orig_system_reference(j),
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.LAST_UPDATE_LOGIN,
	nvl(l_created_by_module(j), 'HZ_IMPORT'),
	P_DML_RECORD.APPLICATION_ID,
	1
      from dual
      where
        l_old_orig_system_reference(j) is not null
        and l_num_row_processed(j) = 1;


    /*******************************************************************/
    /* Handle importing 3rd party data (e.g. DNB) for existing parties */
    /* which do not have existing profiles with OS = 3rd party system  */
    /*******************************************************************/

    IF l_content_source_type <> 'USER_ENTERED' THEN

    /* Insert record into SSM table */
    ForAll j in 1..l_party_orig_system_reference.count
      insert into HZ_ORIG_SYS_REFERENCES
      (
	ORIG_SYSTEM_REF_ID,
	ORIG_SYSTEM,
	ORIG_SYSTEM_REFERENCE,
	OWNER_TABLE_NAME,
	OWNER_TABLE_ID,
	PARTY_ID,
	STATUS,
	START_DATE_ACTIVE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	CREATED_BY_MODULE,
	APPLICATION_ID,
	OBJECT_VERSION_NUMBER
      )
      select
	HZ_ORIG_SYSTEM_REF_S.NEXTVAL,
	l_party_orig_system(j),
	l_party_orig_system_reference(j),
	'HZ_PARTIES',
	l_party_id(j),
	l_party_id(j),
	'A',
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.LAST_UPDATE_LOGIN,
	nvl(l_created_by_module(j), 'HZ_IMPORT'),
	P_DML_RECORD.APPLICATION_ID,
	1
      from dual
      where
        l_old_orig_system_reference(j) is null
        and l_new_osr_exists(j) is not null
        and l_num_row_processed(j) = 1;

    END IF; /* End processing of handling new 3rd party data */

    IF l_party_orig_system_reference.count > 0 THEN
      /* Call mix and match procedures to handle SST for org and person */
      IF l_org_mixnmatch_enabled = 'Y' THEN
        HZ_MIXNM_CONC_DYNAMIC_PKG.ImportCreateOrgSST (
  	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_ID,
  	  P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID);

        HZ_MIXNM_CONC_DYNAMIC_PKG.ImportUpdateOrgSST (
	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_ID,
	  P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID);
      END IF;
      IF l_per_mixnmatch_enabled = 'Y' THEN
        HZ_MIXNM_CONC_DYNAMIC_PKG.ImportCreatePersonSST (
	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_ID,
	  P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID);

        HZ_MIXNM_CONC_DYNAMIC_PKG.ImportUpdatePersonSST (
	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_ID,
	  P_DML_RECORD.REQUEST_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.PROGRAM_APPLICATION_ID);
      END IF;
    END IF;

    CLOSE c_handle_update;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:process_update_parties()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION

    WHEN OTHERS THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update parties other exception: ' || SQLERRM);

        ROLLBACK to process_update_parties_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END process_update_parties;

PROCEDURE sync_party_tax_profile
  ( P_BATCH_ID                      IN NUMBER,
    P_REQUEST_ID                    IN NUMBER,
    P_ORIG_SYSTEM                   IN VARCHAR2,
    P_FROM_OSR                      IN VARCHAR2,
    P_TO_OSR                        IN VARCHAR2,
    P_BATCH_MODE_FLAG               IN VARCHAR2,
    P_PROGRAM_ID                    IN NUMBER
  )
IS

BEGIN

  -- Import Party
  MERGE INTO ZX_PARTY_TAX_PROFILE PTP
    USING
      (SELECT
       'THIRD_PARTY' PARTY_TYPE_CODE,
        party.party_id PARTY_ID,
       party.country COUNTRY_CODE,--4742586
        FND_GLOBAL.Login_ID PROGRAM_LOGIN_ID ,
        party.tax_reference TAX_REFERENCE,
        SYSDATE CREATION_DATE,
        FND_GLOBAL.User_ID CREATED_BY,
        SYSDATE LAST_UPDATE_DATE,
        FND_GLOBAL.User_ID LAST_UPDATED_BY,
        FND_GLOBAL.Login_ID LAST_UPDATE_LOGIN
      FROM HZ_PARTIES party,HZ_IMP_PARTIES_SG ps, HZ_IMP_PARTIES_INT pint
      WHERE party.request_id = p_request_id
        AND party.party_id = ps.party_id
        AND ps.batch_mode_flag = p_batch_mode_flag
        AND ps.batch_id = p_batch_id
        AND ps.party_orig_system = p_orig_system
        AND ps.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr
        AND ps.int_row_id = pint.rowid
        AND (pint.interface_status is null or pint.interface_status='C')
        AND (party.party_type ='ORGANIZATION' OR party.party_type ='PERSON')) PTY
    ON (PTY.PARTY_ID = PTP.PARTY_ID AND PTP.PARTY_TYPE_CODE = 'THIRD_PARTY')
    WHEN MATCHED THEN
      UPDATE SET
        PTP.REP_REGISTRATION_NUMBER = PTY.TAX_REFERENCE,
        PTP.LAST_UPDATE_DATE=PTY.LAST_UPDATE_DATE,
        PTP.LAST_UPDATED_BY=PTY.LAST_UPDATED_BY,
        PTP.LAST_UPDATE_LOGIN=PTY.LAST_UPDATE_LOGIN,
        PTP.OBJECT_VERSION_NUMBER = PTP.OBJECT_VERSION_NUMBER +1,
        PTP.PROGRAM_ID = P_PROGRAM_ID,
        PTP.REQUEST_ID = P_REQUEST_ID
    WHEN NOT MATCHED THEN
      INSERT (PARTY_TYPE_CODE,
              PARTY_TAX_PROFILE_ID,
              PARTY_ID,
              PROGRAM_LOGIN_ID,
              REP_REGISTRATION_NUMBER,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              OBJECT_VERSION_NUMBER,
              COUNTRY_CODE,
              PROGRAM_ID,
              REQUEST_ID)--4742586
      VALUES (PTY.PARTY_TYPE_CODE,
              ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
              PTY.PARTY_ID,
              PTY.PROGRAM_LOGIN_ID,
              PTY.TAX_REFERENCE,
              PTY.CREATION_DATE,
              PTY.CREATED_BY,
              PTY.LAST_UPDATE_DATE,
              PTY.LAST_UPDATED_BY,
              PTY.LAST_UPDATE_LOGIN,
              1,
              PTY.COUNTRY_CODE,
              P_PROGRAM_ID,
              P_REQUEST_ID);--4742586

END sync_party_tax_profile;

/********************************************************************************
 *
 *	load_parties
 *
 ********************************************************************************/

PROCEDURE load_parties (
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

  savepoint load_parties_pvt;
  FND_MSG_PUB.initialize;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:load_parties()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
 END IF;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_org_mixnmatch_enabled := HZ_MIXNM_UTILITY.isMixNMatchEnabled('HZ_ORGANIZATION_PROFILES',l_entity_attr_id);
  l_per_mixnmatch_enabled := HZ_MIXNM_UTILITY.isMixNMatchEnabled('HZ_PERSON_PROFILES',l_entity_attr_id);

  l_content_source_type := P_DML_RECORD.ACTUAL_CONTENT_SRC;
  IF l_content_source_type = 'USER_ENTERED' THEN
    l_actual_content_source := 'SST';
  ELSE
    l_actual_content_source := l_content_source_type;
  END IF;

  process_insert_parties(
     P_DML_RECORD	=> P_DML_RECORD
    ,x_return_status    => x_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data
  );
  IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
    process_update_parties(
       P_DML_RECORD	   => P_DML_RECORD
       ,x_return_status    => x_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data
    );
  END IF;

  sync_party_tax_profile
    ( P_BATCH_ID           =>   P_DML_RECORD.batch_id ,
      P_REQUEST_ID         =>   P_DML_RECORD.request_id ,
      P_ORIG_SYSTEM        =>   P_DML_RECORD.os ,
      P_FROM_OSR           =>   P_DML_RECORD.from_osr ,
      P_TO_OSR             =>   P_DML_RECORD.to_osr ,
      P_BATCH_MODE_FLAG    =>   P_DML_RECORD.batch_mode_flag,
      P_PROGRAM_ID         =>   P_DML_RECORD.program_id
    );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PTY:load_parties()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- if enabled, disable debug
  --disable_debug;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO load_parties_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO load_parties_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading parties');
     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR', l_errm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN

     ROLLBACK TO load_parties_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading parties');
     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END load_parties;


END HZ_IMP_LOAD_PARTIES_PKG;

/
