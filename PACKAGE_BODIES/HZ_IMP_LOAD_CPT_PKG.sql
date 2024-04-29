--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_CPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_CPT_PKG" AS
/* $Header: ARHLCPTB.pls 120.41.12010000.2 2008/09/09 10:53:33 kguggila ship $ */


g_debug_count             NUMBER := 0;
--g_debug                   BOOLEAN := FALSE;

l_batch_id 	 		BATCH_ID;
l_cp_orig_system 	 	ORIG_SYSTEM;
l_cp_orig_system_reference 	ORIG_SYSTEM_REFERENCE;
l_party_orig_system 	 	ORIG_SYSTEM;
l_party_orig_system_reference 	ORIG_SYSTEM_REFERENCE;
l_site_orig_system 	 	ORIG_SYSTEM;
l_site_orig_system_reference 	ORIG_SYSTEM_REFERENCE;
l_insert_update_flag 	 	INSERT_UPDATE_FLAG;
l_contact_point_type 	 	CONTACT_POINT_TYPE;
l_contact_point_purpose 	CONTACT_POINT_PURPOSE;
l_edi_ece_tp_location_code 	EDI_ECE_TP_LOCATION_CODE;
l_edi_id_number 	 	EDI_ID_NUMBER;
l_edi_payment_format 	 	EDI_PAYMENT_FORMAT;
l_edi_payment_method 	   	EDI_PAYMENT_METHOD;
l_edi_remittance_instruction 	EDI_REMITTANCE_INSTRUCTION;
l_edi_remittance_method  	EDI_REMITTANCE_METHOD;
l_edi_tp_header_id 	   	EDI_TP_HEADER_ID;
l_edi_transaction_handling 	EDI_TRANSACTION_HANDLING;
l_eft_printing_program_id 	EFT_PRINTING_PROGRAM_ID;
l_eft_swift_code 	 	EFT_SWIFT_CODE;
l_eft_transmission_program_id 	EFT_TRANSMISSION_PROGRAM_ID;
l_eft_user_number 	 	EFT_USER_NUMBER;
l_email_address 	 	EMAIL_ADDRESS;
l_email_format 	 		EMAIL_FORMAT;
l_phone_area_code 	 	PHONE_AREA_CODE;
l_phone_country_code 	 	PHONE_COUNTRY_CODE;
l_phone_extension 	 	PHONE_EXTENSION;
l_phone_line_type 	 	PHONE_LINE_TYPE;
l_phone_number 	 		PHONE_NUMBER;
l_raw_phone_number 	 	RAW_PHONE_NUMBER;
l_phone_calling_calendar 	PHONE_CALLING_CALENDAR;
l_telex_number 	   		TELEX_NUMBER;
l_timezone_id 	   		TIMEZONE_ID;
l_timezone_code   		TIMEZONE_CODE;
l_url 	 			URL;
l_web_type 	 		WEB_TYPE;
l_attribute_category 		ATTRIBUTE_CATEGORY;
l_attribute1 	 		ATTRIBUTE;
l_attribute2 	 		ATTRIBUTE;
l_attribute3 	 	   	ATTRIBUTE;
l_attribute4 	 	 	ATTRIBUTE;
l_attribute5 	 	 	ATTRIBUTE;
l_attribute6 	 		ATTRIBUTE;
l_attribute7 	   		ATTRIBUTE;
l_attribute8 	   		ATTRIBUTE;
l_attribute9 	 		ATTRIBUTE;
l_attribute10 	 		ATTRIBUTE;
l_attribute11 		 	ATTRIBUTE;
l_attribute12 	 		ATTRIBUTE;
l_attribute13 	 		ATTRIBUTE;
l_attribute14 	 		ATTRIBUTE;
l_attribute15 	 		ATTRIBUTE;
l_attribute16 	 		ATTRIBUTE;
l_attribute17 	 		ATTRIBUTE;
l_attribute18 	  		ATTRIBUTE;
l_attribute19 	  		ATTRIBUTE;
l_attribute20 	 		ATTRIBUTE;
l_interface_status 	 	INTERFACE_STATUS;
l_action_flag 	 		ACTION_FLAG;
l_error_id 	 		ERROR_ID;
l_dqm_action_flag 	 	DQM_ACTION_FLAG;
l_dup_within_int_flag 		DUP_WITHIN_INT_FLAG;
l_party_id 	 		PARTY_ID;
l_party_site_id 	 	PARTY_SITE_ID;
-- l_stage_cp_id 	 	STAGE_CP_ID;
l_created_by_module 	 	CREATED_BY_MODULE;
l_owner_table_name        	OWNER_TABLE_NAME;
l_owner_table_id		OWNER_TABLE_ID;
l_contact_point_id        	CONTACT_POINT_ID;
l_owner_table_error		FLAG_ERROR;
l_action_mismatch_error   	FLAG_ERROR;
l_contact_point_type_error 	LOOKUP_ERROR;
l_cpt_type_updatable_error	LOOKUP_ERROR;
l_cp_purpose_web_err          	LOOKUP_ERROR;
l_cp_purpose_error		LOOKUP_ERROR;
l_edi_id_number_error		FLAG_ERROR;
l_email_address_error         	FLAG_ERROR;
l_email_format_error          	LOOKUP_ERROR;
l_phone_country_code_error	LOOKUP_ERROR;
l_phone_line_type_error		LOOKUP_ERROR;
l_phone_number_error          	FLAG_ERROR;
l_raw_phone_number_error      	FLAG_ERROR;
l_telex_number_error          	FLAG_ERROR;
l_timezone_error        	LOOKUP_ERROR;
l_url_error              	FLAG_ERROR;
l_web_type_error 	   	FLAG_ERROR;
l_error_flag              	FLAG_ERROR;
l_primary_flag            	FLAG_ERROR;

l_error_party_id		PARTY_ID;
l_error_cpt_id			CONTACT_POINT_ID;
l_error_cpt_type		CONTACT_POINT_TYPE;
l_update_party_id		PARTY_ID;
l_update_cpt_id			CONTACT_POINT_ID;
l_update_cpt_type		CONTACT_POINT_TYPE;

l_contact_point_type_errors   	LOOKUP_ERROR;
l_status_error			LOOKUP_ERROR;
l_primary_flag_error		LOOKUP_ERROR;
l_phone_lone_type_error		LOOKUP_ERROR;
l_contact_point_purpose_error	LOOKUP_ERROR;
l_orig_system_ref_upd_error   	LOOKUP_ERROR;

l_createdby_errors              LOOKUP_ERROR;


l_flex_val_errors		NUMBER_COLUMN;
l_dss_security_errors		FLAG_COLUMN;
l_new_osr_exists_flag	        FLAG_ERROR;
l_old_cp_orig_system_ref	ORIG_SYSTEM_REFERENCE;

l_third_party_update_error      FLAG_ERROR; /* bug 4079902 */

l_creation_date			DATE;
l_user_id 		   	NUMBER;
l_last_update_date 		DATE;
l_last_updated_by		NUMBER;
l_last_update_login 		NUMBER;
l_program_id 		   	NUMBER;
l_program_application_id 	NUMBER;
l_request_id 			NUMBER;
l_program_update_date 		DATE;
l_sysdate			DATE;
l_rerun_flag 			varchar2(1);
l_content_source_type 		varchar2(100);
l_actual_content_source 	varchar2(100);

/* For updating error_id in interface table in bulk */
l_int_error_row_id 		ROWID := ROWID();
l_int_error_id 			ERROR_ID := ERROR_ID();

/* For inserting into hz_imp_errors in bulk */
l_err_error_id 			ERROR_ID := ERROR_ID();
l_err_message_name 		ERROR_MESSAGE_NAME := ERROR_MESSAGE_NAME();
l_token1 		   	ERROR_MESSAGE_TOKEN := ERROR_MESSAGE_TOKEN();
l_errm 				varchar2(100);
l_row_id 			ROWID;
l_osr_error_flag 	   	FLAG_COLUMN;
--l_primary_flag            	FLAG_ERROR;
-- l_status FLAG_COLUMN;


/* Keep track of rows that do not get inserted or updated successfully.
   Those are the rows that have some validation or DML errors.
   Use this when inserting into or updating other tables so that we
   do not need to check all the validation arrays. */
l_num_row_processed 		NUMBER_COLUMN;

PROCEDURE validate_desc_flexfield(p_validation_date IN DATE) IS

-- l_validation_date DATE := P_DML_RECORD.SYSDATE;
l_flex_exists  VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM   fnd_descriptive_flexs
  WHERE  application_id = 222
  AND    descriptive_flexfield_name = 'RA_PHONES_HZ';

BEGIN
/*
OPEN desc_flex_exists;
FETCH desc_flex_exists INTO l_flex_exists;
IF desc_flex_exists%NOTFOUND THEN
  CLOSE desc_flex_exists;
  -- Error out all flexfield validation entries as flexfield doesn't exist
  FOR i IN 1..l_cp_orig_system_reference.count LOOP
    l_flex_val_errors(i) := 1;
  END LOOP;
  return;
END IF;
CLOSE desc_flex_exists;
*/

FOR i IN 1..l_contact_point_id.count LOOP

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
    'RA_PHONES_HZ',
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
    'RA_PHONES_HZ',
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
BEGIN
/* Check if the DSS security is granted to the user.
   Only check for update. */
FOR i IN 1..l_cp_orig_system_reference.count LOOP
  l_dss_security_errors(i) :=
       hz_dss_util_pub.test_instance(
	      p_operation_code     => 'UPDATE',
	      p_db_object_name     => 'HZ_CONTACT_POINTS',
	      p_instance_pk1_value => l_contact_point_id(i),
	      p_instance_pk2_value => null,
	      p_instance_pk3_value => null,
	      p_instance_pk4_value => null,
	      p_instance_pk5_value => null,
	      p_user_name          => fnd_global.user_name,
	      x_return_status      => dss_return_status,
	      x_msg_count          => dss_msg_count,
	      x_msg_data           => dss_msg_data);
END LOOP;

END validate_DSS_security;

procedure report_errors (
  P_DML_RECORD      IN  HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,P_ACTION         IN  VARCHAR2
  ,P_DML_EXCEPTION  IN  VARCHAR2  ) IS

-- local variables
n   NUMBER := 1; -- Counter if # of exceptions and validation errors
		 -- across all errored interface records.
num_exp     NUMBER;      -- variable to store # of DML exceptions occured
exp_ind     NUMBER := 1; -- temp variable to store expection index.

-- For updating error_id in interface table in bulk
l_exception_exists   FLAG_ERROR;
l_debug_prefix       VARCHAR2(30) := '';
BEGIN
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;
IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:no of recs processed:'||l_contact_point_id.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
END IF;
--
-- Flow
-- what is the flow?
--
-- 1. if there are no rows processed then return gracefully
-- 2.

-- 1. if there are no rows processed return.
l_num_row_processed := NUMBER_COLUMN();  -- initalizing
num_exp := SQL%BULK_EXCEPTIONS.COUNT;
l_num_row_processed.extend(l_contact_point_id.count);
l_exception_exists := FLAG_ERROR();
l_exception_exists.extend(l_contact_point_id.count);

IF l_contact_point_id.count = 0 THEN
  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:# no rows to process - exiting',
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
  END IF;
  RETURN ;
END IF;

/* Note: For Credit Ratings update would not cause following errors:
    1. dup val exception
    2. missing_parent exception.
other entities copying the code may need to take care of that.

IF g_debug THEN
  hz_utility_v2pub.debug('CPT:report_errors:initializing collections');
END IF;
*/

--  l_num_row_processed := null; -- is this needed ?
-- for all the rows that must be processed
--   check the BULK_ROWCOUNT exception to see
--   if there are any error while doing DML.
--   If so identify the row.

FOR k IN 1..  l_contact_point_id.count LOOP
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(p_message=>'CPT:bfr bulk row excep check',
			    p_prefix =>l_debug_prefix,
			    p_msg_level=>fnd_log.level_statement);
  END IF;
  -- check the bulk row exception for each row

  IF (SQL%BULK_ROWCOUNT(k) = 0) THEN
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:DML fails at:'||k,
			          p_prefix =>'ERROR',
			          p_msg_level=>fnd_log.level_error);
    END IF;
    -- Check for any exceptions during DML
    l_num_row_processed(k) := 0;
    IF P_DML_EXCEPTION = 'Y' THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:DML exception occured',
			          p_prefix =>'ERROR',
			          p_msg_level=>fnd_log.level_error);
      END IF;

      -- determine if exception is at this index
      FOR i IN exp_ind..num_exp LOOP

	IF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = k THEN
	  -- if the error index is same as the interface rec, process
	  -- the exception.
	  IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CPT:excep code:'||SQL%BULK_EXCEPTIONS(i).ERROR_CODE,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
          END IF;
	  IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE <> 1 THEN
	    -- In case of any other exceptions, raise apps exception
	    -- to be caught in load_creditrtaings()
	    l_exception_exists(k) := 'Y';
	    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	      l_errm := SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
	      hz_utility_v2pub.debug(p_message=>'CPT:exception is:'||l_errm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;         -- error code 1 check ends

	  -- increment the total errors count and go to next exception
	  n := n+1;
	  exp_ind := n+1;

	ELSE
	  -- if the error index is not the current interface row, exit
	  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'CPT:error index <> current int row',
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
	  END IF;
	  EXIT;
	END IF; -- end of error index check
      END LOOP; -- end of exceptions loop.
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:No DML exception',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF; -- end of DML exception check
  ELSE
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:record#'||k||' processed successfully ',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CPT:SQL%BULK_ROWCOUNT(k):'||SQL%BULK_ROWCOUNT(k),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    l_num_row_processed(k) := 1;
  END IF; -- end of  SQL%BULK_ROWCOUNT(k) = 0 check
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:----------------------',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;
END LOOP; -- end of loop for l_contact_point_id.count

BEGIN -- anonymous block to insert into hz_imp_errors
 forall j in 1..l_contact_point_id.count
  insert into hz_imp_tmp_errors
  (  request_id, batch_id, int_row_id,
     interface_table_name,  error_id,
     creation_date,  created_by, last_update_date,
     last_updated_by, last_update_login,
     program_application_id, program_id,
     program_update_date,/*MISSING_PARENT_FLAG, */
     MISSING_PARENT_FLAG, --Bug No: 3443866
     ACTION_MISMATCH_FLAG, OTHER_EXCEP_FLAG,
     e1_flag,        e2_flag,
     e3_flag,        e4_flag,
     e5_flag,        e6_flag,
     e7_flag,        e8_flag,
     e9_flag,        e10_flag,
     e11_flag,       e12_flag,
     e13_flag,       e14_flag,
     e15_flag, --only for insert
     e16_flag,
     e17_flag,	   e18_flag,
     e19_flag,     e20_flag,
     e21_flag
  )(
  select
    P_DML_RECORD.REQUEST_ID,
    P_DML_RECORD.BATCH_ID,
    l_row_id(j),
    'HZ_IMP_CONTACTPTS_INT',
    HZ_IMP_ERRORS_S.NextVal,
    P_DML_RECORD.SYSDATE,
    P_DML_RECORD.USER_ID,
    P_DML_RECORD.SYSDATE,
    P_DML_RECORD.USER_ID,
    P_DML_RECORD.LAST_UPDATE_LOGIN,
    P_DML_RECORD.PROGRAM_APPLICATION_ID,
    P_DML_RECORD.PROGRAM_ID,
    P_DML_RECORD.SYSDATE,/*l_owner_table_error(j), */
    'Y',--Bug No: 3443866
    l_action_mismatch_error(j),
    l_exception_exists(j),
    'Y',
    l_cp_purpose_error(j),
    l_edi_id_number_error(j),
    l_email_address_error(j),
    l_email_format_error(j),
    l_phone_country_code_error(j),
    l_phone_line_type_error(j),
    l_phone_number_error(j),
    l_telex_number_error(j),
    l_timezone_error(j),
    l_url_error(j),
    l_web_type_error(j),
    l_flex_val_errors(j),
    'Y',
    'Y',
    'Y',
    l_cpt_type_updatable_error(j),
    decode(l_dss_security_errors(j),FND_API.G_FALSE,
      nvl2(l_party_orig_system_reference(j),'P',nvl2(l_site_orig_system_reference(j),'S','P')),'Y'),
    l_cp_purpose_web_err(j),
    l_third_party_update_error(j),
    l_createdby_errors(j)
    from dual
   where l_num_row_processed(j) = 0
);

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CPT:while inserting into errors tbl got others excep',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
END; -- anonymous block end

--Start Bug No:3387220
/*
IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:Update errored records in interface table',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
END IF;
-- Update for success cases, on in the case of reruns
if (P_DML_RECORD.RERUN = 'Y') THEN
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT:In case of rerun, update sucessful interface records',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;
  ForAll j in 1..l_num_row_processed.count
    update HZ_IMP_CONTACTPTS_INT
    set error_id = null,
	interface_status = null,
	insert_update_flag = P_ACTION
    where
	l_num_row_processed(j) = 1
    and rowid = l_row_id(j);
end if;
--------------
*/--End of Bug No:3387220

IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:report_errors()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CPT:in report_errors() expection block',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
END report_errors;

PROCEDURE populate_error_table(
   P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
   P_DUP_VAL_EXP               IN     VARCHAR2,
   P_SQL_ERRM                  IN     VARCHAR2  ) IS

   dup_val_exp_val             VARCHAR2(1) := null;
   other_exp_val               VARCHAR2(1) := 'Y';
   l_debug_prefix	       VARCHAR2(30) := '';
BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT: populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF(P_DUP_VAL_EXP = 'Y') then
     other_exp_val := null;
     IF(instr(P_SQL_ERRM, '_U1')<>0) THEN
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CPT: HZ_CONTACT_POINTS_U1 violated',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;
       dup_val_exp_val := 'A';
      END IF;
    END IF;

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
     e2_flag,e3_flag, e4_flag,
     e5_flag, e6_flag, e7_flag,
     e8_flag, e9_flag, e10_flag,
     e11_flag, e12_flag, e13_flag,
     e14_flag, e15_flag, e16_flag,
     e17_flag,e18_flag,e19_flag,e20_flag,
     e21_flag,
     ACTION_MISMATCH_FLAG,
     DUP_VAL_IDX_EXCEP_FLAG,
     OTHER_EXCEP_FLAG
   )
   (
     select P_DML_RECORD.REQUEST_ID,
	    P_DML_RECORD.BATCH_ID,
	    p_sg.int_row_id,
	    'HZ_IMP_CONTACTPTS_INT',
	    HZ_IMP_ERRORS_S.NextVal,
	    P_DML_RECORD.SYSDATE,
	    P_DML_RECORD.USER_ID,
	    P_DML_RECORD.SYSDATE,
	    P_DML_RECORD.USER_ID,
	    P_DML_RECORD.LAST_UPDATE_LOGIN,
	    P_DML_RECORD.PROGRAM_APPLICATION_ID,
	    P_DML_RECORD.PROGRAM_ID,
	    P_DML_RECORD.SYSDATE,
	    'Y','Y','Y','Y','Y',
	    'Y','Y','Y','Y','Y',
	    'Y','Y','Y','Y','Y',
	    'Y','Y','Y',
	    'Y','Y','Y','Y',
	    dup_val_exp_val,
	    other_exp_val
       from hz_imp_contactpts_int int,hz_imp_contactpts_sg p_sg
      where int.rowid = p_sg.int_row_id
	and p_sg.action_flag = 'I'
	and p_sg.batch_id = P_DML_RECORD.BATCH_ID
	and int.party_orig_system = P_DML_RECORD.OS
	and int.party_orig_system_reference
	    between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
   );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
END populate_error_table;


--------------------------------------
-- private procedures and functions
--------------------------------------
  --------------------------------------
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
END enable_debug;      -- end procedure
*/
--------------------------------------
--------------------------------------
/*PROCEDURE disable_debug IS
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
/********************************************************************************
*
*	process_insert_contactpoints
*
********************************************************************************/

PROCEDURE process_insert_contactpoints
(
 P_DML_RECORD	 	 IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
,x_return_status             OUT NOCOPY    VARCHAR2
,x_msg_count                 OUT NOCOPY    NUMBER
,x_msg_data                  OUT NOCOPY    VARCHAR2
)
as
c_handle_insert 			RefCurType;
primary_flag_err_cursor	RefCurType;
de_norm_cursor				RefCurType;

l_insert_sql varchar2(25000) :=
'BEGIN insert all
when (action_mismatch_error is not null
 and flex_val_errors is not null
 and cpt_null_error is not null
 and contact_point_type_error is not null
 and cp_purpose_web_error is not null
 and cp_purpose_error is not null
 and edi_id_number_error is not null
 and email_address_error is not null
 and email_format_error is not null
 and phone_country_code_error is not null
 and phone_line_type_error is not null
 and phone_number_error is not null
 and telex_number_error is not null
 and timezone_id_error is not null
 and url_error is not null
 and web_type_error is not null
 --and owner_table_error is not null --Bug No:3443866
 and owner_table_error =''Y'' --Bug No:3443866
 and error_flag is null
 and cpt_addr_osr_mismatch_err is not null
 and createdby_error is not null
 ) then
into hz_contact_points (
     actual_content_source, application_id, content_source_type,
     created_by, creation_date, last_updated_by,
     last_update_date, last_update_login, program_application_id,
     program_id, program_update_date, request_id,
     contact_point_id, contact_point_type, status,
     owner_table_name, owner_table_id, primary_flag,
     orig_system_reference, attribute_category, attribute1,
     attribute2, attribute3, attribute4,
     attribute5, attribute6, attribute7,
     attribute8, attribute9, attribute10,
     attribute11, attribute12, attribute13,
     attribute14, attribute15, attribute16,
     attribute17, attribute18, attribute19,
     attribute20, edi_transaction_handling, edi_id_number,
     edi_payment_method, edi_payment_format, edi_remittance_method,
     edi_remittance_instruction, edi_tp_header_id, edi_ece_tp_location_code,
     email_format, email_address, phone_calling_calendar,
     timezone_id, phone_area_code, phone_country_code,
     phone_number, phone_extension, phone_line_type,
     telex_number, web_type, url,
     raw_phone_number, object_version_number, created_by_module,
     contact_point_purpose, eft_transmission_program_id, eft_printing_program_id,
     eft_user_number, eft_swift_code)
values (
:l_actual_content_src, :l_application_id, :l_content_source,
:l_user_id, :l_sysdate, :l_user_id, :l_sysdate, -- l_created_by, l_creation_date, l_last_updated_by,l_last_update_date
:l_last_update_login, :l_program_application_id,
:l_program_id, :l_sysdate, -- l_program_update_date,
:l_request_id,
contact_point_id, contact_point_type, ''A'',
owner_table_name, owner_table_id, primary_flag,
cp_orig_system_reference, attribute_category, attribute1,
attribute2, attribute3, attribute4,
attribute5, attribute6, attribute7,
attribute8, attribute9, attribute10,
attribute11, attribute12, attribute13,
attribute14, attribute15, attribute16,
attribute17, attribute18, attribute19,
attribute20, edi_transaction_handling, edi_id_number,
edi_payment_method, edi_payment_format, edi_remittance_method,
edi_remittance_instruction, edi_tp_header_id, edi_ece_tp_location_code,
email_format, email_address, phone_calling_calendar,
timezone_id, phone_area_code, phone_country_code,
phone_number, phone_extension, phone_line_type,
telex_number, web_type, url,
raw_phone_number,1,nvl(nullif(created_by_module,:G_MISS_CHAR),''HZ_IMPORT''),
contact_point_purpose, eft_transmission_program_id, eft_printing_program_id,
eft_user_number, eft_swift_code)
into hz_orig_sys_references (
     application_id, created_by, creation_date,
     last_updated_by, last_update_date, last_update_login,
     orig_system_ref_id, orig_system, orig_system_reference,
     owner_table_name, owner_table_id, status,
     start_date_active, created_by_module, object_version_number,party_id,
     request_id, program_application_id, program_id, program_update_date)
values (
     :l_application_id,
     :l_user_id, :l_sysdate,:l_user_id, :l_sysdate, -- l_created_by, l_creation_date, l_last_updated_by,l_last_update_date
     :l_last_update_login,
     hz_orig_system_ref_s.nextval, cp_orig_system, cp_orig_system_reference,
     ''HZ_CONTACT_POINTS'', contact_point_id, ''A'',
     :l_sysdate, created_by_module, 1,party_id,
     :l_request_id, :l_program_application_id, :l_program_id, :l_sysdate)
else
into hz_imp_tmp_errors (
     created_by, creation_date, last_updated_by,
     last_update_date, last_update_login,
     program_application_id,
     program_id, program_update_date,
     error_id, batch_id, request_id,
     int_row_id, interface_table_name, e1_flag,
     e2_flag, e3_flag, e4_flag,
     e5_flag, e6_flag, e7_flag,
     e8_flag, e9_flag, e10_flag,
     e11_flag, e12_flag, e13_flag,
     /* e14_flag ,*/ e15_flag, e16_flag,
     e19_flag,
     MISSING_PARENT_FLAG,ACTION_MISMATCH_FLAG,
     e17_flag,e18_flag,e20_flag,
     e21_flag)
values (
     :l_user_id, :l_sysdate, :l_user_id,
     :l_sysdate, :l_last_update_login,
     :l_program_application_id,
     :l_program_id, :l_sysdate,
     HZ_IMP_ERRORS_S.nextval, :l_batch_id, :l_request_id,
     row_id, ''HZ_IMP_CONTACTPTS_INT'',contact_point_type_error,
     cp_purpose_error, edi_id_number_error,email_address_error,
     email_format_error, phone_country_code_error,phone_line_type_error,
     phone_number_error, telex_number_error,timezone_id_error,
     url_error, web_type_error,flex_val_errors,
     /* cpt_party_osr_mismatch_err ,*/ cpt_null_error,cpt_addr_osr_mismatch_err,
     cp_purpose_web_error,
     owner_table_error,action_mismatch_error,
     ''Y'',''Y'',''Y'',
     createdby_error)
select row_id, cp_orig_system, cp_orig_system_reference,
     party_orig_system, party_orig_system_reference, site_orig_system,
     site_orig_system_reference, insert_update_flag, contact_point_type,
     contact_point_purpose, edi_ece_tp_location_code, edi_id_number,
     edi_payment_format, edi_payment_method, edi_remittance_instruction,
     edi_remittance_method, edi_tp_header_id, edi_transaction_handling,
     eft_printing_program_id, eft_swift_code, eft_transmission_program_id,
     eft_user_number, email_address,
     decode(contact_point_type,''EMAIL'',nvl(email_format,''MAILTEXT''),email_format) email_format,
     phone_area_code, phone_country_code, phone_extension,
     phone_line_type, phone_number, nvl(raw_phone_number,phone_area_code||''-''|| phone_number) raw_phone_number,
     phone_calling_calendar, telex_number, timezone_id,
     url, web_type, attribute_category,
     attribute1, attribute2, attribute3,
     attribute4, attribute5, attribute6,
     attribute7, attribute8, attribute9,
     attribute10, attribute11, attribute12,
     attribute13, attribute14, attribute15,
     attribute16, attribute17, attribute18,
     attribute19, attribute20, interface_status,
     action_flag, error_id, dqm_action_flag,
     dup_within_int_flag, party_id, party_site_id,
     nvl(created_by_module,''HZ_IMPORT'') created_by_module, owner_table_name, owner_table_id,
     primary_flag, contact_point_id,
     --party_id,
     nvl2(nullif(insert_update_flag, action_flag), null, ''Y'') action_mismatch_error,
     decode(:l_val_flex, ''Y'',
       HZ_IMP_LOAD_CPT_PKG.validate_desc_flexfield_f(
       attribute_category, attribute1, attribute2, attribute3, attribute4,
       attribute5, attribute6, attribute7, attribute8, attribute9,
       attribute10, attribute11, attribute12, attribute13, attribute14,
       attribute15, attribute16, attribute17, attribute18, attribute19,
       attribute20, :l_sysdate), ''T'') flex_val_errors,
     ''T'' dss_security_errors,
     nvl2(contact_point_type, ''Y'',null) cpt_null_error,
     nvl2(contact_point_type_l, ''Y'',null) contact_point_type_error,
     --decode(contact_point_type, null, ''Y'', ''WEB'', nvl2(contact_point_purpose, cp_purpose_web_l, ''Y''), nvl2(contact_point_purpose, cp_purpose_l, ''Y'')) cp_purpose_error,
     decode(contact_point_type, ''WEB'', nvl2(contact_point_purpose, cp_purpose_web_l, ''Y''),''Y'') cp_purpose_web_error,
     decode(contact_point_type, ''WEB'',''Y'',null,''Y'', nvl2(contact_point_purpose, cp_purpose_l, ''Y'')) cp_purpose_error,
     decode(contact_point_type, ''EDI'', nvl2(edi_id_number, ''Y'', null), ''Y'') edi_id_number_error,
     decode(contact_point_type, ''EMAIL'', nvl2(email_address, ''Y'', null), ''Y'') email_address_error,
     decode(contact_point_type, ''EMAIL'', nvl2(email_format, email_format_l, ''Y''), ''Y'') email_format_error,
     --decode(contact_point_type, ''PHONE'', nvl2(nullif(phone_country_code, pccl), null, ''Y''), ''Y'') phone_country_code_error,--3401319
     decode(contact_point_type, ''PHONE'', pccl, ''Y'') phone_country_code_error,--3401319
     decode(contact_point_type, ''PHONE'', nvl2(phone_line_type, phone_line_type_l, ''Y''), ''Y'') phone_line_type_error,
     decode(contact_point_type, ''PHONE'', decode(phone_number,null, nvl2(raw_phone_number,''Y'', null),nvl2(raw_phone_number,null,''Y'')), ''Y'') phone_number_error,
     /*decode(contact_point_type, ''PHONE'',
	      decode(phone_number, null, decode(raw_phone_number, null,null,:G_MISS_CHAR, null,''Y''),
		     :G_MISS_CHAR,decode(raw_phone_number,null,null,:G_MISS_CHAR, null,''Y''),
		      decode(raw_phone_number,null,''Y'',:G_MISS_CHAR,''Y'',null)), ''Y'') phone_number_error,*/
     decode(contact_point_type, ''TLX'', nvl2(telex_number,''Y'',null), ''Y'') telex_number_error,
     decode(contact_point_type, ''PHONE'', decode(timezone_code, null,''Y'',decode(timezone_id,null,null,''Y'')), ''Y'') timezone_id_error,
     decode(contact_point_type, ''WEB'', nvl2(url,''Y'',null), ''Y'') url_error,
     decode(contact_point_type, ''WEB'', nvl2(web_type,''Y'',null), ''Y'') web_type_error,
     --nvl2(mosr_owner_table_id,''Y'',null) owner_table_error, --Bug No:3443866
     nvl2(mosr_owner_table_id,nvl2(owner_table_id,''Y'',nvl2(site_orig_system_reference,''A'',''P'')),
       nvl2(site_orig_system_reference,''A'',''P'')) owner_table_error, --Bug No:3443866
       --owner_table_error should check for null owner_table_id as it will throw exception
     decode(party_site_id,null,''Y'',nvl2(nullif(party_site_id,site_owner_table_id),null,''Y'')) cpt_addr_osr_mismatch_err,
	 --decode(party_id,null,''Y'',nvl2(nullif(party_id,party_owner_table_id),null,''Y'')) cpt_party_osr_mismatch_err,
     --owner_table_error,
     error_flag,
     nvl2(created_by_module, createdby_l, ''Y'') createdby_error
from (
select /*+ leading(ps) use_nl(contact_point_type_l, email_format_l,
cp_purpose_l,cp_purpose_web_l, phone_line_type_l) */ pi.rowid row_id,
     pi.cp_orig_system,
     pi.cp_orig_system_reference,
     pi.party_orig_system,
     pi.party_orig_system_reference,
     pi.site_orig_system,
     pi.site_orig_system_reference,
     nullif(pi.insert_update_flag, :G_MISS_CHAR) insert_update_flag,
     nullif(pi.contact_point_type, :G_MISS_CHAR) contact_point_type,
     nullif(pi.contact_point_purpose, :G_MISS_CHAR) contact_point_purpose,
     nullif(pi.edi_ece_tp_location_code, :G_MISS_CHAR) edi_ece_tp_location_code,
     nullif(pi.edi_id_number, :G_MISS_CHAR) edi_id_number,
     nullif(pi.edi_payment_format, :G_MISS_CHAR) edi_payment_format,
     nullif(pi.edi_payment_method, :G_MISS_CHAR) edi_payment_method,
     nullif(pi.edi_remittance_instruction, :G_MISS_CHAR) edi_remittance_instruction,
     nullif(pi.edi_remittance_method, :G_MISS_CHAR) edi_remittance_method,
     nullif(pi.edi_tp_header_id, to_number(:G_MISS_NUM)) edi_tp_header_id,
     nullif(pi.edi_transaction_handling, :G_MISS_CHAR) edi_transaction_handling,
     nullif(pi.eft_printing_program_id, to_number(:G_MISS_NUM)) eft_printing_program_id,
     nullif(pi.eft_swift_code, :G_MISS_CHAR) eft_swift_code,
     nullif(pi.eft_transmission_program_id, to_number(:G_MISS_NUM)) eft_transmission_program_id,
     nullif(pi.eft_user_number, :G_MISS_CHAR) eft_user_number,
     substrb(nullif(pi.email_address, :G_MISS_CHAR),1,320) email_address,
     nullif(pi.email_format, :G_MISS_CHAR) email_format,
     nullif(pi.phone_area_code, :G_MISS_CHAR) phone_area_code,
     nullif(pi.phone_country_code, :G_MISS_CHAR) phone_country_code,
     nullif(pi.phone_extension, :G_MISS_CHAR) phone_extension,
     nullif(pi.phone_line_type, :G_MISS_CHAR) phone_line_type,
     nullif(pi.phone_number, :G_MISS_CHAR) phone_number,
     nullif(pi.raw_phone_number, :G_MISS_CHAR) raw_phone_number,
     nullif(pi.phone_calling_calendar, :G_MISS_CHAR) phone_calling_calendar,
     nullif(pi.telex_number, :G_MISS_CHAR) telex_number,
     nullif(pi.timezone_code, :G_MISS_CHAR) timezone_code,
     ht.upgrade_tz_id timezone_id,
     nullif(pi.url, :G_MISS_CHAR) url,
     nullif(pi.web_type, :G_MISS_CHAR) web_type,
     nullif(pi.attribute_category, :G_MISS_CHAR) attribute_category,
     nullif(pi.attribute1, :G_MISS_CHAR) attribute1,
     nullif(pi.attribute2, :G_MISS_CHAR) attribute2,
     nullif(pi.attribute3, :G_MISS_CHAR) attribute3,
     nullif(pi.attribute4, :G_MISS_CHAR) attribute4,
     nullif(pi.attribute5, :G_MISS_CHAR) attribute5,
     nullif(pi.attribute6, :G_MISS_CHAR) attribute6,
     nullif(pi.attribute7, :G_MISS_CHAR) attribute7,
     nullif(pi.attribute8, :G_MISS_CHAR) attribute8,
     nullif(pi.attribute9, :G_MISS_CHAR) attribute9,
     nullif(pi.attribute10, :G_MISS_CHAR) attribute10,
     nullif(pi.attribute11, :G_MISS_CHAR) attribute11,
     nullif(pi.attribute12, :G_MISS_CHAR) attribute12,
     nullif(pi.attribute13, :G_MISS_CHAR) attribute13,
     nullif(pi.attribute14, :G_MISS_CHAR) attribute14,
     nullif(pi.attribute15, :G_MISS_CHAR) attribute15,
     nullif(pi.attribute16, :G_MISS_CHAR) attribute16,
     nullif(pi.attribute17, :G_MISS_CHAR) attribute17,
     nullif(pi.attribute18, :G_MISS_CHAR) attribute18,
     nullif(pi.attribute19, :G_MISS_CHAR) attribute19,
     nullif(pi.attribute20, :G_MISS_CHAR) attribute20,
     pi.interface_status,
     ps.action_flag,
     pi.error_id,
     pi.dqm_action_flag,
     pi.dup_within_int_flag,
     ps.party_id,
     ps.party_site_id,
     ps.contact_point_id,
     nvl(ps.primary_flag,''N'') primary_flag,
     nullif(pi.created_by_module, :G_MISS_CHAR) created_by_module,
     nvl2(ps.party_site_id, ''HZ_PARTY_SITES'', ''HZ_PARTIES'') owner_table_name,
     nvl(ps.party_site_id, ps.party_id) owner_table_id,
     nvl2(contact_point_type_l.lookup_code, ''Y'', null) contact_point_type_l,
     nvl2(email_format_l.lookup_code, ''Y'', null) email_format_l,
     nvl2(cp_purpose_l.lookup_code, ''Y'', null) cp_purpose_l,
     nvl2(cp_purpose_web_l.lookup_code, ''Y'', null) cp_purpose_web_l,
     nvl2(phone_line_type_l.lookup_code, ''Y'', null) phone_line_type_l,
     --nvl2(hpc.phone_country_code, ''Y'', null) pccl,
     --hpc.phone_country_code pccl,
     nvl2(pi.phone_country_code, decode(tc.a, 1, ''Y''), ''Y'') pccl,
     nvl2(createdby_l.lookup_code, ''Y'', null) createdby_l,
     --nvl(mosr_site.owner_table_id,mosr_party.owner_table_id) mosr_owner_table_id, --Bug No:3443866
     nvl2(pi.site_orig_system_reference,mosr_site.owner_table_id,hp.party_id) mosr_owner_table_id, --Bug No:3443866
     /*(select ''Y''
       from hz_orig_sys_references
      where status = ''A''
	and rownum = 1
	and (orig_system, orig_system_reference, owner_table_name) in (
	    (pi.site_orig_system, pi.site_orig_system_reference,
	    ''HZ_PARTY_SITES''),
	    (pi.party_orig_system, pi.party_orig_system_reference,
	    ''HZ_PARTIES''))) owner_table_error, */
     ps.error_flag,
     hp.party_id party_owner_table_id,
     mosr_site.owner_table_id site_owner_table_id
from hz_imp_contactpts_int pi,
     hz_imp_contactpts_sg ps,
     --hz_orig_sys_references mosr_party,
     hz_parties hp,
     hz_orig_sys_references mosr_site,
     --(select distinct phone_country_code from hz_phone_country_codes) hpc,--3401319
     (select 0 a from dual union all select 1 a from dual) tc,--3401319
     fnd_timezones_b ht,
     fnd_lookup_values contact_point_type_l,
     fnd_lookup_values email_format_l,
     fnd_lookup_values cp_purpose_l,
     fnd_lookup_values cp_purpose_web_l,
     fnd_lookup_values phone_line_type_l,
     fnd_lookup_values createdby_l

where pi.rowid = ps.int_row_id
 and mosr_site.orig_system (+) = pi.site_orig_system
 and mosr_site.orig_system_reference (+) = pi.site_orig_system_reference
 and mosr_site.status (+) = ''A''
 and mosr_site.owner_table_name (+) = ''HZ_PARTY_SITES''
 and hp.party_id (+) = ps.party_id
 and hp.status (+) = ''A''
 and contact_point_type_l.lookup_code (+) = pi.contact_point_type
 and contact_point_type_l.lookup_type (+) = ''COMMUNICATION_TYPE''
 and contact_point_type_l.language (+) = userenv(''LANG'')
 and contact_point_type_l.view_application_id (+) = 222
 and contact_point_type_l.security_group_id (+) =
     fnd_global.lookup_security_group(''COMMUNICATION_TYPE'', 222)
 and cp_purpose_l.lookup_code (+) = pi.contact_point_purpose
 and cp_purpose_l.lookup_type (+) = ''CONTACT_POINT_PURPOSE''
 and cp_purpose_l.language (+) = userenv(''LANG'')
 and cp_purpose_l.view_application_id (+) = 222
 and cp_purpose_l.security_group_id (+) =
     fnd_global.lookup_security_group(''CONTACT_POINT_PURPOSE'', 222)
 and cp_purpose_web_l.lookup_code (+) = pi.contact_point_purpose
 and cp_purpose_web_l.lookup_type (+) = ''CONTACT_POINT_PURPOSE_WEB''
 and cp_purpose_web_l.language (+) = userenv(''LANG'')
 and cp_purpose_web_l.view_application_id (+) = 222
 and cp_purpose_web_l.security_group_id (+) =
     fnd_global.lookup_security_group(''CONTACT_POINT_PURPOSE_WEB'', 222)
 and email_format_l.lookup_code (+) = pi.email_format
 and email_format_l.lookup_type (+) = ''EMAIL_FORMAT''
 and email_format_l.language (+) = userenv(''LANG'')
 and email_format_l.view_application_id (+) = 222
 and email_format_l.security_group_id (+) =
     fnd_global.lookup_security_group(''EMAIL_FORMAT'', 222)
 and phone_line_type_l.lookup_code (+) = pi.phone_line_type
 and phone_line_type_l.lookup_type (+) = ''PHONE_LINE_TYPE''
 and phone_line_type_l.language (+) = userenv(''LANG'')
 and phone_line_type_l.view_application_id (+) = 222
 and phone_line_type_l.security_group_id (+) =
     fnd_global.lookup_security_group(''PHONE_LINE_TYPE'', 222)
 and pi.timezone_code = ht.timezone_code (+)
 --and pi.phone_country_code = hpc.phone_country_code (+) --3401319
 and tc.a = (select count(*) from  hz_phone_country_codes hpc --3401319
	     where pi.phone_country_code = hpc.phone_country_code
	     and rownum < 2)
 and createdby_l.lookup_code (+) = pi.created_by_module
 and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
 and createdby_l.language (+) = userenv(''LANG'')
 and createdby_l.view_application_id (+) = 222
 and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
 and ps.batch_id = :l_batch_id
 and ps.party_orig_system = :l_os
 and ps.party_orig_system_reference between :l_from_osr and :l_to_osr
 and ps.batch_mode_flag = :l_batch_mode_flag
 and ps.action_flag = ''I''';

l_where_first_run_sql varchar2(35) := ' AND pi.interface_status is null';
l_where_rerun_sql varchar2(35) := ' AND pi.interface_status = ''C''';

l_where_enabled_lookup_sql varchar2(1500) :=
      ' AND  ( contact_point_type_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( contact_point_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( contact_point_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( cp_purpose_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( cp_purpose_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( cp_purpose_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( cp_purpose_web_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( cp_purpose_web_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( cp_purpose_web_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( email_format_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( email_format_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( email_format_l.END_DATE_ACTIVE,SYSDATE ) ) )
      --AND  ( ht.ENABLED_FLAG(+) = ''Y'') --Bug No:3398342
      AND  ( phone_line_type_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( phone_line_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( phone_line_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( createdby_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( createdby_l.END_DATE_ACTIVE,SYSDATE ) ) )';
l_end_sql 		VARCHAR2(10) := ' ); END;';
l_final_sql		VARCHAR2(32000);
l_entity_attr_id 	NUMBER := null;
l_dml_exception 	VARCHAR2(1) := 'N';
l_debug_prefix	       VARCHAR2(30) := '';

BEGIN
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT: process_insert_contactpoints (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;
IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT: RERUN:' || P_DML_RECORD.RERUN,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CPT: ALLOW_DISABLED_LOOKUP:' || P_DML_RECORD.ALLOW_DISABLED_LOOKUP,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
END IF;

savepoint process_insert_cpt_pvt;

FND_MSG_PUB.initialize;

--Initialize API return status to success.
x_return_status := FND_API.G_RET_STS_SUCCESS;


IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
  IF P_DML_RECORD.RERUN = 'N'  THEN
   -- First run with disabled lookup
   l_final_sql := l_insert_sql || l_where_first_run_sql || l_end_sql;
  ELSE
    -- Re-run with disabled lookup
       l_final_sql := l_insert_sql || l_where_rerun_sql || l_end_sql;
  END IF;
ELSE
  IF P_DML_RECORD.RERUN = 'N' THEN
   -- First run with enabled lookup
    l_final_sql := l_insert_sql || l_where_first_run_sql || l_where_enabled_lookup_sql || l_end_sql;
  ELSE
    -- Re-run with enabled lookup
    l_final_sql := l_insert_sql || l_where_rerun_sql || l_where_enabled_lookup_sql || l_end_sql;
  END IF;
END IF;

EXECUTE IMMEDIATE l_final_sql  using
      P_DML_RECORD.ACTUAL_CONTENT_SRC,
      P_DML_RECORD.APPLICATION_ID,
      'USER_ENTERED',--Bug No:3413574
      P_DML_RECORD.USER_ID,
      P_DML_RECORD.SYSDATE,
      P_DML_RECORD.LAST_UPDATE_LOGIN,
      P_DML_RECORD.PROGRAM_APPLICATION_ID,
      P_DML_RECORD.PROGRAM_ID,
      P_DML_RECORD.REQUEST_ID,
      P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.BATCH_ID,
      P_DML_RECORD.FLEX_VALIDATION,
      P_DML_RECORD.GMISS_NUM,
      P_DML_RECORD.OS,
      P_DML_RECORD.FROM_OSR,
      P_DML_RECORD.TO_OSR,
      P_DML_RECORD.BATCH_MODE_FLAG;

FND_FILE.put_line(fnd_file.log, 'CPT:Rows inserted in MTI = ' || SQL%ROWCOUNT);

FND_FILE.PUT_LINE(FND_FILE.LOG, 'BATCH_ID = ' || P_DML_RECORD.BATCH_ID);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'OS = ' || P_DML_RECORD.OS);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'FROM_OSR = ' || P_DML_RECORD.FROM_OSR);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'TO_OSR = ' || P_DML_RECORD.TO_OSR);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACTUAL_CONTENT_SRC = ' || P_DML_RECORD.ACTUAL_CONTENT_SRC);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'RERUN = ' || P_DML_RECORD.RERUN);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR_LIMIT = ' || P_DML_RECORD.ERROR_LIMIT);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'BATCH_MODE_FLAG = ' || P_DML_RECORD.BATCH_MODE_FLAG);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'USER_ID = ' || P_DML_RECORD.USER_ID);

FND_FILE.PUT_LINE(FND_FILE.LOG, 'SYSDATE = ' || to_char(P_DML_RECORD.SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG, 'REQUEST_ID = ' || P_DML_RECORD.REQUEST_ID);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'GMISS_CHAR = ' || P_DML_RECORD.GMISS_CHAR);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'GMISS_NUM = ' || P_DML_RECORD.GMISS_NUM);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'FLEX_VALIDATION = ' || P_DML_RECORD.FLEX_VALIDATION);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'DSS_SECURITY = ' || P_DML_RECORD.DSS_SECURITY);

  /* DE-NORM */
  /* for all the failed record of primary_flag = 'Y', update the party with */
  /* the next available contact point */
  --Bug 3978485: changed where condition to use request_id in HZ_IMP_TMP_ERRORS
  OPEN primary_flag_err_cursor FOR
    'select cpt_sg.party_id, int.contact_point_type,
	    ( select hz_cpt.contact_point_id
		from hz_contact_points hz_cpt
	       where hz_cpt.owner_table_id = cpt_sg.party_id
		 and hz_cpt.owner_table_name= ''HZ_PARTIES''
		 and hz_cpt.CONTACT_POINT_TYPE = int.contact_point_type
		 and rownum = 1
	    ) contact_point_id
       from HZ_IMP_TMP_ERRORS err_table,
	    hz_imp_contactpts_int int,
	    hz_imp_contactpts_sg cpt_sg
      where err_table.request_id = :request_id
	 and cpt_sg.batch_id = :batch_id
	and cpt_sg.batch_mode_flag = :batch_mode_flag
	and err_table.interface_table_name = ''HZ_IMP_CONTACTPTS_INT''
	and cpt_sg.party_orig_system = :orig_system
	and cpt_sg.party_orig_system_reference between :from_osr and :to_osr
	and cpt_sg.primary_flag = ''Y''
	and cpt_sg.int_row_id = err_table.int_row_id
	and int.rowid = cpt_sg.int_row_id
	and int.contact_point_type in(''WEB'',''EMAIL'')
	and cpt_sg.action_flag = ''I'''
	using P_DML_RECORD.REQUEST_ID,P_DML_RECORD.BATCH_ID,
	      P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
	      P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

  fetch primary_flag_err_cursor  BULK COLLECT INTO
    l_error_party_id,l_error_cpt_type, l_error_cpt_id;
  close primary_flag_err_cursor;
/* Start of bug 7383480
  forall i in 1..l_error_party_id.count
    update hz_parties hz_pty
       set (email_address,url ) =
	   ( select email_address,url
	       from hz_contact_points
	      where contact_point_id = l_error_cpt_id(i)
	   )
     where hz_pty.party_id = l_error_party_id(i);
*/
 forall i in 1..l_error_party_id.count
    update hz_parties hz_pty
       set email_address  =
	   ( select email_address
	       from hz_contact_points
	      where contact_point_id = l_error_cpt_id(i)
	      and contact_point_type='EMAIL'
	   )
     where hz_pty.party_id = l_error_party_id(i)
     and l_error_cpt_type(i)= 'EMAIL';

  forall i in 1..l_error_party_id.count
    update hz_parties hz_pty
       set url =
	   ( select url
	       from hz_contact_points
	      where contact_point_id = l_error_cpt_id(i)
	      and contact_point_type='WEB'
	   )
     where hz_pty.party_id = l_error_party_id(i)
     and l_error_cpt_type(i)= 'WEB';
   --end of bug 7383480
      forall i in 1..l_error_party_id.count
    update hz_contact_points
       set primary_flag = 'Y'
     where contact_point_id = l_error_cpt_id(i);

FND_FILE.put_line(fnd_file.log, 'CPT:Rows updated with primary flag = ' || l_error_party_id.count);

  /* de-norm the primary contact point to parties */
  /* Note: for error case, the party with the id will just be not found */
  /*       in update. Not necessary to filter out here. */
  OPEN de_norm_cursor FOR
    'select cpt_sg.party_id, cpt_sg.contact_point_id, int.contact_point_type
       from hz_imp_contactpts_int int,hz_imp_contactpts_sg cpt_sg
      where int.rowid = cpt_sg.int_row_id
	and int.contact_point_type in(''WEB'',''EMAIL'')
	and cpt_sg.batch_id = :batch_id
	and cpt_sg.batch_mode_flag = :batch_mode_flag
	and cpt_sg.party_orig_system = :orig_system
	and cpt_sg.party_orig_system_reference between :from_osr and :to_osr
	and cpt_sg.primary_flag = ''Y''
	and cpt_sg.action_flag = ''I''
	and cpt_sg.party_action_flag = ''U''
	and not exists (select tmp_err.INT_ROW_ID
				   from hz_imp_tmp_errors tmp_err
				   where tmp_err.INT_ROW_ID = int.rowid
				   and tmp_err.INTERFACE_TABLE_NAME = ''HZ_IMP_CONTACTPTS_INT'')
	'
	using P_DML_RECORD.BATCH_ID,
	      P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
	      P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

  fetch de_norm_cursor  BULK COLLECT INTO
    l_update_party_id, l_update_cpt_id,l_update_cpt_type;
  close de_norm_cursor;
/* Start of bug 7383480
  forall i in 1..l_update_party_id.count
    update hz_parties hz_pty
       set (email_address,url  ) =
	   ( select email_address,url
	       from hz_contact_points
	      where contact_point_id = l_update_cpt_id(i)
	   )
     where hz_pty.party_id = l_update_party_id(i);
      */
       forall i in 1..l_update_party_id.count
		update hz_parties hz_pty
		set email_address =( select email_address
				     from hz_contact_points
				     where contact_point_id = l_update_cpt_id(i)
				     and   contact_point_type='EMAIL')
		where hz_pty.party_id = l_update_party_id(i)
		and l_update_cpt_type(i) = 'EMAIL' ;


	forall i in 1..l_update_party_id.count
		update hz_parties hz_pty
		set url =( select url
				     from hz_contact_points
				     where contact_point_id = l_update_cpt_id(i)
				     and   contact_point_type='WEB')
		where hz_pty.party_id = l_update_party_id(i)
		and l_update_cpt_type(i) = 'WEB' ;
    --End of bug 7383480
FND_FILE.put_line(fnd_file.log, 'CPT:Denormalised contact point counts = ' || l_update_party_id.count);

IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT: process_insert_contactpoints-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN

   ROLLBACK TO process_insert_cpt_pvt;
   populate_error_table(P_DML_RECORD, 'Y', SQLERRM);
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   ROLLBACK TO process_insert_cpt_pvt;
   populate_error_table(P_DML_RECORD, 'N', SQLERRM);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

 WHEN OTHERS THEN

   ROLLBACK TO process_insert_cpt_pvt;
   FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading contactpoints in process_insert_contactpoints');
   FND_FILE.put_line(fnd_file.log, SQLERRM);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
   FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

END process_insert_contactpoints;


/********************************************************************************
*
*	process_update_contactpoints
*
********************************************************************************/

PROCEDURE process_update_contactpoints
(
P_DML_RECORD  	       IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
,x_return_status             OUT NOCOPY    VARCHAR2
,x_msg_count                 OUT NOCOPY    NUMBER
,x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS
c_handle_update RefCurType;
l_update_sql varchar2(12000) :=
      'SELECT /*+ leading(ps) use_nl(pi) rowid(pi) */
	 pi.rowid row_id,
     pi.cp_orig_system,
     pi.cp_orig_system_reference,
     pi.party_orig_system,
     pi.party_orig_system_reference,
     pi.site_orig_system,
     pi.site_orig_system_reference,
     nullif(pi.insert_update_flag, :G_MISS_CHAR) insert_update_flag,
     nullif(pi.contact_point_type, :G_MISS_CHAR) contact_point_type,
     nullif(pi.contact_point_purpose, :G_MISS_CHAR) contact_point_purpose,
     nullif(pi.edi_ece_tp_location_code, :G_MISS_CHAR) edi_ece_tp_location_code,
     nullif(pi.edi_id_number, :G_MISS_CHAR) edi_id_number,
     nullif(pi.edi_payment_format, :G_MISS_CHAR) edi_payment_format,
     nullif(pi.edi_payment_method, :G_MISS_CHAR) edi_payment_method,
     nullif(pi.edi_remittance_instruction, :G_MISS_CHAR) edi_remittance_instruction,
     nullif(pi.edi_remittance_method, :G_MISS_CHAR) edi_remittance_method,
     nullif(pi.edi_tp_header_id, :G_MISS_NUM) edi_tp_header_id,
     nullif(pi.edi_transaction_handling, :G_MISS_CHAR) edi_transaction_handling,
     nullif(pi.eft_printing_program_id, :G_MISS_NUM) eft_printing_program_id,
     nullif(pi.eft_swift_code, :G_MISS_CHAR) eft_swift_code,
     nullif(pi.eft_transmission_program_id, :G_MISS_NUM) eft_transmission_program_id,
     nullif(pi.eft_user_number, :G_MISS_CHAR) eft_user_number,
     substrb(nullif(pi.email_address, :G_MISS_CHAR),1,320) email_address,
     nullif(pi.email_format, :G_MISS_CHAR) email_format,
     nullif(pi.phone_area_code, :G_MISS_CHAR) phone_area_code,
     nullif(pi.phone_country_code, :G_MISS_CHAR) phone_country_code,
     nullif(pi.phone_extension, :G_MISS_CHAR) phone_extension,
     nullif(pi.phone_line_type, :G_MISS_CHAR) phone_line_type,
     nullif(pi.phone_number, :G_MISS_CHAR) phone_number,
     nullif(pi.raw_phone_number, :G_MISS_CHAR) raw_phone_number,
     nullif(pi.phone_calling_calendar, :G_MISS_CHAR) phone_calling_calendar,
     nullif(pi.telex_number, :G_MISS_CHAR) telex_number,
     nullif(pi.timezone_code, :G_MISS_CHAR) timezone_code,
     ht.upgrade_tz_id timezone_id,
     nullif(pi.url, :G_MISS_CHAR) url,
     nullif(pi.web_type, :G_MISS_CHAR) web_type,
     nullif(pi.attribute_category, :G_MISS_CHAR) attribute_category,
     nullif(pi.attribute1, :G_MISS_CHAR) attribute1,
     nullif(pi.attribute2, :G_MISS_CHAR) attribute2,
     nullif(pi.attribute3, :G_MISS_CHAR) attribute3,
     nullif(pi.attribute4, :G_MISS_CHAR) attribute4,
     nullif(pi.attribute5, :G_MISS_CHAR) attribute5,
     nullif(pi.attribute6, :G_MISS_CHAR) attribute6,
     nullif(pi.attribute7, :G_MISS_CHAR) attribute7,
     nullif(pi.attribute8, :G_MISS_CHAR) attribute8,
     nullif(pi.attribute9, :G_MISS_CHAR) attribute9,
     nullif(pi.attribute10, :G_MISS_CHAR) attribute10,
     nullif(pi.attribute11, :G_MISS_CHAR) attribute11,
     nullif(pi.attribute12, :G_MISS_CHAR) attribute12,
     nullif(pi.attribute13, :G_MISS_CHAR) attribute13,
     nullif(pi.attribute14, :G_MISS_CHAR) attribute14,
     nullif(pi.attribute15, :G_MISS_CHAR) attribute15,
     nullif(pi.attribute16, :G_MISS_CHAR) attribute16,
     nullif(pi.attribute17, :G_MISS_CHAR) attribute17,
     nullif(pi.attribute18, :G_MISS_CHAR) attribute18,
     nullif(pi.attribute19, :G_MISS_CHAR) attribute19,
     nullif(pi.attribute20, :G_MISS_CHAR) attribute20,
     pi.interface_status,
     ps.action_flag,
     pi.error_id,
     pi.dqm_action_flag,
     pi.dup_within_int_flag,
     ps.party_id,
     ps.party_site_id,
     ps.contact_point_id,
     nvl(hp.primary_flag,''N'') primary_flag, /* Bug No: 3917168 */
     nullif(pi.created_by_module,:G_MISS_CHAR) created_by_module,
     nvl2(ps.party_site_id, ''HZ_PARTY_SITES'', ''HZ_PARTIES'') owner_table_name,
     nvl(ps.party_site_id, ps.party_id) owner_table_id,
     nvl2(nullif(pi.insert_update_flag, ps.action_flag),null, ''Y'') action_mismatch_error,
	 decode(nullif(pi.contact_point_type,:G_MISS_CHAR),null,null,hp.contact_point_type,''Y'',null) cpt_type_updatable_error,
	 /*decode(hp.CONTACT_POINT_TYPE,null,''Y'',''WEB'',nvl2(nullif(pi.CONTACT_POINT_PURPOSE,:G_MISS_CHAR),nvl2(cp_purpose_web_l.lookup_code,''Y'',null),''Y'' ),
		      nvl2(nullif(pi.CONTACT_POINT_PURPOSE,:G_MISS_CHAR),nvl2(cp_purpose_l.lookup_code,''Y'',null),''Y'' ))cp_purpose_error,*/
	 decode(hp.CONTACT_POINT_TYPE,null,''Y'',''WEB'',nvl2(nullif(pi.CONTACT_POINT_PURPOSE,:G_MISS_CHAR),nvl2(cp_purpose_web_l.lookup_code,''Y'',null),''Y'' ),''Y'' ) cp_purpose_web_err,
	 decode(hp.CONTACT_POINT_TYPE,null,''Y'',''WEB'',''Y'',
		      nvl2(nullif(pi.CONTACT_POINT_PURPOSE,:G_MISS_CHAR),nvl2(cp_purpose_l.lookup_code,''Y'',null),''Y'' ))cp_purpose_error,
	 decode(hp.CONTACT_POINT_TYPE,''EDI'',nvl2(nullif(pi.EDI_ID_NUMBER,:G_MISS_CHAR),''Y'',null),''Y'') edi_id_number_error,
	 decode(hp.CONTACT_POINT_TYPE,''EMAIL'',nvl2(nullif(pi.EMAIL_ADDRESS,:G_MISS_CHAR),''Y'',null),''Y'') email_address_error,
	 decode(hp.CONTACT_POINT_TYPE,''EMAIL'',nvl2(nullif(pi.EMAIL_FORMAT,:G_MISS_CHAR),
						      nvl2(email_format_l.lookup_code,''Y'',null),nvl2(hp.email_format,null,''Y'')),''Y'') email_format_error,
	 --decode(hp.CONTACT_POINT_TYPE,''PHONE'',nvl2(nullif(pi.PHONE_COUNTRY_CODE,:G_MISS_CHAR),nvl2(hpc.phone_country_code,''Y'',null),''Y''),''Y'') phone_country_code_error,--3401319
	 decode(hp.CONTACT_POINT_TYPE,''PHONE'',nvl2(nullif(pi.PHONE_COUNTRY_CODE,:G_MISS_CHAR),decode(tc.a, 1, ''Y''),''Y''),''Y'') phone_country_code_error,--3401319
	 decode(hp.CONTACT_POINT_TYPE,''PHONE'',nvl2(nullif(pi.PHONE_LINE_TYPE,:G_MISS_CHAR),nvl2(phone_line_type_l.lookup_code,''Y'',null),null),''Y'') phone_line_type_error,
	 decode(hp.contact_point_type, ''PHONE'',decode(nullif(pi.phone_number,:G_MISS_CHAR),null,nvl2(nullif(pi.raw_phone_number,:G_MISS_CHAR),''Y'',null),
		      nvl2(nullif(pi.raw_phone_number,:G_MISS_CHAR),null,''Y'')), ''Y'') phone_number_error,
	 decode(hp.CONTACT_POINT_TYPE,''TLX'',nvl2(nullif(pi.TELEX_NUMBER,:G_MISS_CHAR),''Y'',null),''Y'') telex_number_error,
	 decode(hp.CONTACT_POINT_TYPE,''PHONE'',nvl2(nullif(pi.TIMEZONE_CODE,:G_MISS_CHAR),nvl2(ht.UPGRADE_TZ_ID,''Y'',null),''Y''),''Y'') timezone_error,
	 decode(hp.CONTACT_POINT_TYPE,''WEB'',nvl2(nullif(pi.URL,:G_MISS_CHAR),''Y'', null),''Y'') url_error,
	 decode(hp.CONTACT_POINT_TYPE,''WEB'',nvl2(nullif(pi.WEB_TYPE,:G_MISS_CHAR),''Y'', null),''Y'') web_type_error,
	 --nvl2(nullif(pi.cp_orig_system_reference,hp.orig_system_reference),null,''Y'') orig_system_ref_upd_error,
	 ps.error_flag,
	 --mosr.owner_table_id owner_table_error,
	 ''T'' dss_security_errors,
	 0 flex_val_errors,
	 ps.old_cp_orig_system_ref,
	 ps.NEW_OSR_EXISTS_FLAG,
         /* Bug 4079902 */
         nvl2(nullif(hp.actual_content_source,:l_actual_content_source),
              nvl2(nullif(hos.orig_system_type,''PURCHASED''),''Y'',null),
              ''Y'')             third_party_update_error,
          nvl2(nullif(pi.created_by_module,:GMISS_CHAR),
               nvl2(ps.new_osr_exists_flag,
                    nvl2(nullif(pi.cp_orig_system_reference,ps.old_cp_orig_system_ref),
                         createdby_l.lookup_code,
                         ''Y''
                        ),
                    ''Y''
                    ),
               ''Y'')  createdby_error

  FROM HZ_IMP_CONTACTPTS_INT pi, HZ_IMP_CONTACTPTS_SG ps,hz_contact_points hp,
       hz_orig_systems_b hos, /* Bug 4079902 */
    --(select distinct phone_country_code from hz_phone_country_codes) hpc,--3401319
    (select 0 a from dual union all select 1 a from dual) tc,--3401319
    fnd_timezones_b ht,fnd_lookup_values contact_point_type_l,
    fnd_lookup_values email_format_l,fnd_lookup_values cp_purpose_l,
    fnd_lookup_values cp_purpose_web_l,fnd_lookup_values phone_line_type_l,
    fnd_lookup_values createdby_l
  WHERE  pi.rowid = ps.int_row_id
   and   ps.contact_point_id = hp.contact_point_id
   and   pi.CONTACT_POINT_TYPE = contact_point_type_l.lookup_code(+)
   and   contact_point_type_l.lookup_type(+) = ''COMMUNICATION_TYPE''
   and   contact_point_type_l.language (+) = userenv(''LANG'')
   and   contact_point_type_l.view_application_id (+) = 222
   and   contact_point_type_l.security_group_id (+) =
		      fnd_global.lookup_security_group(''COMMUNICATION_TYPE'', 222)
   and   pi.CONTACT_POINT_PURPOSE = cp_purpose_l.lookup_code(+)
   and   cp_purpose_l.lookup_type(+) = ''CONTACT_POINT_PURPOSE''
   and   cp_purpose_l.language (+) = userenv(''LANG'')
       and   cp_purpose_l.view_application_id (+) = 222
       and   cp_purpose_l.security_group_id (+) =
		      fnd_global.lookup_security_group(''CONTACT_POINT_PURPOSE'', 222)
   and   pi.CONTACT_POINT_PURPOSE = cp_purpose_web_l.lookup_code(+)
   and   cp_purpose_web_l.lookup_type(+) = ''CONTACT_POINT_PURPOSE_WEB''
       and   cp_purpose_web_l.language (+) = userenv(''LANG'')
       and   cp_purpose_web_l.view_application_id (+) = 222
       and   cp_purpose_web_l.security_group_id (+) =
		      fnd_global.lookup_security_group(''CONTACT_POINT_PURPOSE_WEB'', 222)
   and   pi.EMAIL_FORMAT = email_format_l.lookup_code(+)
   and   email_format_l.lookup_type(+) = ''EMAIL_FORMAT''
       and   email_format_l.language (+) = userenv(''LANG'')
       and   email_format_l.view_application_id (+) = 222
       and   email_format_l.security_group_id (+) =
		      fnd_global.lookup_security_group(''EMAIL_FORMAT'', 222)
   and   pi.PHONE_LINE_TYPE = phone_line_type_l.lookup_code(+)
   and   phone_line_type_l.lookup_type(+) = ''PHONE_LINE_TYPE''
       and   phone_line_type_l.language (+) = userenv(''LANG'')
       and   phone_line_type_l.view_application_id (+) = 222
   and   phone_line_type_l.security_group_id (+) =
		      fnd_global.lookup_security_group(''PHONE_LINE_TYPE'', 222)
   and   pi.TIMEZONE_CODE = ht.timezone_code(+)
   --and   pi.PHONE_COUNTRY_CODE = hpc.phone_country_code(+)--3401319
   and createdby_l.lookup_code (+) = pi.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and tc.a = (select count(*) from  hz_phone_country_codes hpc --3401319
	       where pi.phone_country_code = hpc.phone_country_code
	       and rownum < 2)
   and   ps.batch_id = :l_batch_id
       and   ps.party_orig_system = :l_os
       and   ps.party_orig_system_reference between :l_from_osr and :l_to_osr
       and   ps.batch_mode_flag = :l_batch_mode_flag
   and   ps.ACTION_FLAG = ''U''
   /* bug 4079902 */
   and hos.orig_system=hp.actual_content_source';

l_where_first_run_sql varchar2(35) := ' AND pi.interface_status is null';
l_where_rerun_sql varchar2(35) := ' AND pi.interface_status = ''C''';

l_where_enabled_lookup_sql varchar2(3000) :=
      ' AND  ( contact_point_type_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( contact_point_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( contact_point_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( cp_purpose_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( cp_purpose_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( cp_purpose_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( cp_purpose_web_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( cp_purpose_web_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( cp_purpose_web_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( email_format_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( email_format_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( email_format_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( phone_line_type_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( phone_line_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( phone_line_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
      AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	TRUNC(SYSDATE) BETWEEN
	TRUNC(NVL( createdby_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	TRUNC(NVL( createdby_l.END_DATE_ACTIVE,SYSDATE ) ) )';

l_dml_exception varchar2(1) := 'N';
l_final_sql		VARCHAR2(32000);
l_debug_prefix	       VARCHAR2(30) := '';
BEGIN
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT: process_update_contactpoints (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;
IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CPT: RERUN:' || P_DML_RECORD.RERUN,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CPT: ALLOW_DISABLED_LOOKUP:' || P_DML_RECORD.ALLOW_DISABLED_LOOKUP,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
END IF;

savepoint process_update_cpts_pvt;

FND_MSG_PUB.initialize;

--Initialize API return status to success.
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
  IF P_DML_RECORD.RERUN = 'N'  THEN
   -- First run with disabled lookup
   l_final_sql := l_update_sql || l_where_first_run_sql;
  ELSE
    -- Re-run with disabled lookup
       l_final_sql := l_update_sql || l_where_rerun_sql;
  END IF;
ELSE
  IF P_DML_RECORD.RERUN = 'N' THEN
   -- First run with enabled lookup
    l_final_sql := l_update_sql || l_where_first_run_sql || l_where_enabled_lookup_sql;
  ELSE
    -- Re-run with enabled lookup
    l_final_sql := l_update_sql || l_where_rerun_sql || l_where_enabled_lookup_sql;
  END IF;
END IF;

OPEN c_handle_update FOR  l_final_sql  using
  P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_NUM,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_NUM,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_NUM,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,/*P_DML_RECORD.GMISS_NUM,*/ P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.GMISS_CHAR,P_DML_RECORD.ACTUAL_CONTENT_SRC,
      P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.BATCH_ID,P_DML_RECORD.OS,P_DML_RECORD.FROM_OSR,P_DML_RECORD.TO_OSR,
      P_DML_RECORD.BATCH_MODE_FLAG;

FETCH c_handle_update BULK COLLECT INTO
 l_row_id,
 l_cp_orig_system,
 l_cp_orig_system_reference,
 l_party_orig_system,
 l_party_orig_system_reference,
 l_site_orig_system,
 l_site_orig_system_reference,
 l_insert_update_flag,
 l_contact_point_type,
 l_contact_point_purpose,
 l_edi_ece_tp_location_code,
 l_edi_id_number,
 l_edi_payment_format,
 l_edi_payment_method,
 l_edi_remittance_instruction,
 l_edi_remittance_method,
 l_edi_tp_header_id,
 l_edi_transaction_handling,
 l_eft_printing_program_id,
 l_eft_swift_code,
 l_eft_transmission_program_id,
 l_eft_user_number,
 l_email_address,
 l_email_format,
 l_phone_area_code,
 l_phone_country_code,
 l_phone_extension,
 l_phone_line_type,
 l_phone_number,
 l_raw_phone_number,
 l_phone_calling_calendar,
 l_telex_number,
 l_timezone_code,
 l_timezone_id,
 l_url,
 l_web_type,
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
 l_interface_status,
 l_action_flag,
 l_error_id,
 l_dqm_action_flag,
 l_dup_within_int_flag,
 l_party_id,
 l_party_site_id,
 l_contact_point_id,
 l_primary_flag,
 l_created_by_module,
 l_owner_table_name,
 l_owner_table_id,
 l_action_mismatch_error,
 l_cpt_type_updatable_error,
 l_cp_purpose_web_err,
 l_cp_purpose_error,
 l_edi_id_number_error,
 l_email_address_error,
 l_email_format_error,
 l_phone_country_code_error,
 l_phone_line_type_error,
 l_phone_number_error,
 l_telex_number_error,
 l_timezone_error,
 l_url_error,
 l_web_type_error,
 --l_orig_system_ref_upd_error,
 l_error_flag,
 --l_owner_table_error,
 l_dss_security_errors,
 l_flex_val_errors,
 l_old_cp_orig_system_ref,
 l_new_osr_exists_flag,
 l_third_party_update_error, /* Bug 4079902 */
 l_createdby_errors;
-- Do FND desc flex validation based on profile
IF P_DML_RECORD.FLEX_VALIDATION = 'Y' THEN
  validate_desc_flexfield(P_DML_RECORD.SYSDATE);
END IF;

-- Do DSS security validation based on profile
IF P_DML_RECORD.DSS_SECURITY = 'Y' THEN
  validate_DSS_security;
END IF;

BEGIN
   ForAll j in 1..l_contact_point_id.count SAVE EXCEPTIONS
    update hz_contact_points set
    --CONTACT_POINT_ID = DECODE(l_contact_point_id(j),NULL,CONTACT_POINT_ID,P_DML_RECORD.GMISS_CHAR, NULL,l_contact_point_id(j)),
      --CONTACT_POINT_TYPE = DECODE(l_contact_point_type(j),NULL,CONTACT_POINT_TYPE,P_DML_RECORD.GMISS_CHAR, NULL,l_contact_point_type(j)),
      --STATUS = DECODE(l_status(j),NULL,STATUS,P_DML_RECORD.GMISS_CHAR, NULL,l_status(j)),
      --OWNER_TABLE_NAME = DECODE(l_owner_table_name(j),NULL,OWNER_TABLE_NAME,P_DML_RECORD.GMISS_CHAR, NULL,l_owner_table_name(j)),
      --OWNER_TABLE_ID = DECODE(l_owner_table_id(j),NULL,OWNER_TABLE_ID,P_DML_RECORD.GMISS_CHAR, NULL,l_owner_table_id(j)),
      --PRIMARY_FLAG 	= DECODE(l_primary_flag(j),NULL,PRIMARY_FLAG,P_DML_RECORD.GMISS_CHAR, NULL,l_primary_flag(j)), /* Bug No: 3917168 */
      LAST_UPDATE_DATE 	= P_DML_RECORD.SYSDATE,
      LAST_UPDATED_BY 	= P_DML_RECORD.USER_ID,
      LAST_UPDATE_LOGIN	= P_DML_RECORD.LAST_UPDATE_LOGIN,
      REQUEST_ID 	= P_DML_RECORD.REQUEST_ID,
      PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
      PROGRAM_ID 	     = P_DML_RECORD.PROGRAM_ID,
      PROGRAM_UPDATE_DATE    = P_DML_RECORD.SYSDATE,
      ATTRIBUTE_CATEGORY     = DECODE(l_attribute_category(j),NULL,ATTRIBUTE_CATEGORY,
				       P_DML_RECORD.GMISS_CHAR, NULL,l_attribute_category(j)),
      ATTRIBUTE1 =  DECODE(l_attribute1(j),NULL,ATTRIBUTE1,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute1(j)),
      ATTRIBUTE2 =  DECODE(l_attribute2(j),NULL,ATTRIBUTE2,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute2(j)),
      ATTRIBUTE3 =  DECODE(l_attribute3(j),NULL,ATTRIBUTE3,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute3(j)),
      ATTRIBUTE4 =  DECODE(l_attribute4(j),NULL,ATTRIBUTE4,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute4(j)),
      ATTRIBUTE5 =  DECODE(l_attribute5(j),NULL,ATTRIBUTE5,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute5(j)),
      ATTRIBUTE6 =  DECODE(l_attribute6(j),NULL,ATTRIBUTE6,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute6(j)),
      ATTRIBUTE7 =  DECODE(l_attribute7(j),NULL,ATTRIBUTE7,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute7(j)),
      ATTRIBUTE8 =  DECODE(l_attribute8(j),NULL,ATTRIBUTE8,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute8(j)),
      ATTRIBUTE9 =  DECODE(l_attribute9(j),NULL,ATTRIBUTE9,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute9(j)),
      ATTRIBUTE10 = DECODE(l_attribute10(j),NULL,ATTRIBUTE10,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute10(j)),
      ATTRIBUTE11 = DECODE(l_attribute11(j),NULL,ATTRIBUTE11,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute11(j)),
      ATTRIBUTE12 = DECODE(l_attribute12(j),NULL,ATTRIBUTE12,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute12(j)),
      ATTRIBUTE13 = DECODE(l_attribute13(j),NULL,ATTRIBUTE13,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute13(j)),
      ATTRIBUTE14 = DECODE(l_attribute14(j),NULL,ATTRIBUTE14,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute14(j)),
      ATTRIBUTE15 = DECODE(l_attribute15(j),NULL,ATTRIBUTE15,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute15(j)),
      ATTRIBUTE16 = DECODE(l_attribute16(j),NULL,ATTRIBUTE16,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute16(j)),
      ATTRIBUTE17 = DECODE(l_attribute17(j),NULL,ATTRIBUTE17,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute17(j)),
      ATTRIBUTE18 = DECODE(l_attribute18(j),NULL,ATTRIBUTE18,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute18(j)),
      ATTRIBUTE19 = DECODE(l_attribute19(j),NULL,ATTRIBUTE19,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute19(j)),
      ATTRIBUTE20 = DECODE(l_attribute20(j),NULL,ATTRIBUTE20,P_DML_RECORD.GMISS_CHAR, NULL,l_attribute20(j)),
      EDI_TRANSACTION_HANDLING = DECODE(l_edi_transaction_handling(j),NULL,EDI_TRANSACTION_HANDLING,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_transaction_handling(j)),
      EDI_ID_NUMBER 	   		= DECODE(l_edi_id_number(j),NULL,EDI_ID_NUMBER,P_DML_RECORD.GMISS_NUM, NULL,l_edi_id_number(j)),
      EDI_PAYMENT_METHOD 		= DECODE(l_edi_payment_method(j),NULL,EDI_PAYMENT_METHOD,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_payment_method(j)),
      EDI_PAYMENT_FORMAT 		= DECODE(l_edi_payment_format(j),NULL,EDI_PAYMENT_FORMAT,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_payment_format(j)),
      EDI_REMITTANCE_METHOD 	= DECODE(l_edi_remittance_method(j),NULL,EDI_REMITTANCE_METHOD,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_remittance_method(j)),
      EDI_REMITTANCE_INSTRUCTION = DECODE(l_edi_remittance_instruction(j),NULL,EDI_REMITTANCE_INSTRUCTION,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_remittance_instruction(j)),
      EDI_TP_HEADER_ID 		= DECODE(l_edi_tp_header_id(j),NULL,EDI_TP_HEADER_ID,P_DML_RECORD.GMISS_NUM, NULL,l_edi_tp_header_id(j)),
      EDI_ECE_TP_LOCATION_CODE = DECODE(l_edi_ece_tp_location_code(j),NULL,EDI_ECE_TP_LOCATION_CODE,P_DML_RECORD.GMISS_CHAR, NULL,l_edi_ece_tp_location_code(j)),
      EMAIL_FORMAT 			= DECODE(l_email_format(j),NULL,EMAIL_FORMAT,P_DML_RECORD.GMISS_CHAR, NULL,l_email_format(j)),
      EMAIL_ADDRESS 			= DECODE(l_email_address(j),NULL,EMAIL_ADDRESS,P_DML_RECORD.GMISS_CHAR, NULL,l_email_address(j)),
      --BEST_TIME_TO_CONTACT_START = DECODE(l_best_time_to_contact_start(j),NULL,BEST_TIME_TO_CONTACT_START,P_DML_RECORD.GMISS_CHAR, NULL,l_best_time_to_contact_start(j)),
      --BEST_TIME_TO_CONTACT_END = DECODE(l_best_time_to_contact_end(j),NULL,BEST_TIME_TO_CONTACT_END,P_DML_RECORD.GMISS_CHAR, NULL,l_best_time_to_contact_end(j)),
      PHONE_CALLING_CALENDAR 	= DECODE(l_phone_calling_calendar(j),NULL,PHONE_CALLING_CALENDAR,P_DML_RECORD.GMISS_CHAR, NULL,l_phone_calling_calendar(j)),
      --CONTACT_ATTEMPTS 		= DECODE(l_contact_attempts(j),NULL,CONTACT_ATTEMPTS,P_DML_RECORD.GMISS_CHAR, NULL,l_contact_attempts(j)),
      --CONTACTS 				= DECODE(l_contacts(j),NULL,CONTACTS,P_DML_RECORD.GMISS_CHAR, NULL,l_contacts(j)),
      --LAST_CONTACT_DT_TIME 	= DECODE(l_last_contact_dt_time(j),NULL,LAST_CONTACT_DT_TIME,P_DML_RECORD.GMISS_CHAR, NULL,l_last_contact_dt_time(j)),
      PHONE_AREA_CODE 		= DECODE(l_phone_area_code(j),NULL,PHONE_AREA_CODE,P_DML_RECORD.GMISS_CHAR, NULL,l_phone_area_code(j)),
      PHONE_COUNTRY_CODE 		= DECODE(l_phone_country_code(j),NULL,PHONE_COUNTRY_CODE,P_DML_RECORD.GMISS_CHAR, NULL,l_phone_country_code(j)),
      PHONE_NUMBER 			= DECODE(l_phone_number(j),NULL,decode(l_raw_phone_number(j),null,PHONE_NUMBER,null),P_DML_RECORD.GMISS_CHAR, NULL,l_phone_number(j)),
      PHONE_EXTENSION 		= DECODE(l_phone_extension(j),NULL,PHONE_EXTENSION,P_DML_RECORD.GMISS_CHAR, NULL,l_phone_extension(j)),
      PHONE_LINE_TYPE 		= DECODE(l_phone_line_type(j),NULL,PHONE_LINE_TYPE,P_DML_RECORD.GMISS_CHAR, NULL,l_phone_line_type(j)),
      TELEX_NUMBER 			= DECODE(l_telex_number(j),NULL,TELEX_NUMBER,P_DML_RECORD.GMISS_CHAR, NULL,l_telex_number(j)),
      WEB_TYPE 				= DECODE(l_web_type(j),NULL,WEB_TYPE,P_DML_RECORD.GMISS_CHAR, NULL,l_web_type(j)),
      URL 					= DECODE(l_url(j),NULL,URL,P_DML_RECORD.GMISS_CHAR, NULL,l_url(j)),
      --CONTENT_SOURCE_TYPE = DECODE(l_content_source_type(j),NULL,CONTENT_SOURCE_TYPE,P_DML_RECORD.GMISS_CHAR, NULL,l_content_source_type(j)),
      RAW_PHONE_NUMBER 		= DECODE(l_raw_phone_number(j),NULL,decode(l_phone_number(j),null,RAW_PHONE_NUMBER,null),P_DML_RECORD.GMISS_CHAR, NULL,l_raw_phone_number(j)),
      OBJECT_VERSION_NUMBER 	= nvl(OBJECT_VERSION_NUMBER,1) +1,
      --CREATED_BY_MODULE = nvl(CREATED_BY_MODULE, decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, l_created_by_module(j))),
      --APPLICATION_ID 		= DECODE(l_application_id(j),NULL,APPLICATION_ID,P_DML_RECORD.GMISS_CHAR, NULL,l_application_id(j)),
      TIMEZONE_ID 			= DECODE(l_timezone_code(j),NULL,TIMEZONE_ID,P_DML_RECORD.GMISS_CHAR, NULL,l_timezone_id(j)),
      CONTACT_POINT_PURPOSE 	= DECODE(l_contact_point_purpose(j),NULL,CONTACT_POINT_PURPOSE,P_DML_RECORD.GMISS_CHAR, NULL,l_contact_point_purpose(j)),
      --PRIMARY_BY_PURPOSE 	= DECODE(l_primary_by_purpose(j),NULL,PRIMARY_BY_PURPOSE,P_DML_RECORD.GMISS_CHAR, NULL,l_primary_by_purpose(j)),
      --TRANSPOSED_PHONE_NUMBER = DECODE(l_transposed_phone_number(j),NULL,TRANSPOSED_PHONE_NUMBER,P_DML_RECORD.GMISS_CHAR, NULL,l_transposed_phone_number(j)),
      EFT_TRANSMISSION_PROGRAM_ID = DECODE(l_eft_transmission_program_id(j),NULL,EFT_TRANSMISSION_PROGRAM_ID,P_DML_RECORD.GMISS_NUM, NULL,l_eft_transmission_program_id(j)),
      EFT_PRINTING_PROGRAM_ID = DECODE(l_eft_printing_program_id(j),NULL,EFT_PRINTING_PROGRAM_ID,P_DML_RECORD.GMISS_NUM, NULL,l_eft_printing_program_id(j)),
      EFT_USER_NUMBER 		= DECODE(l_eft_user_number(j),NULL,EFT_USER_NUMBER,P_DML_RECORD.GMISS_CHAR, NULL,l_eft_user_number(j)),
      EFT_SWIFT_CODE 			= DECODE(l_eft_swift_code(j),NULL,EFT_SWIFT_CODE,P_DML_RECORD.GMISS_CHAR, NULL,l_eft_swift_code(j)),
      --ACTUAL_CONTENT_SOURCE = DECODE(l_actual_content_source,NULL,ACTUAL_CONTENT_SOURCE,P_DML_RECORD.GMISS_CHAR, NULL,l_actual_content_source(j))
      ACTUAL_CONTENT_SOURCE = p_dml_record.actual_content_src /* Bug 4079902 */
       where  contact_point_id = l_contact_point_id(j)
	 and  l_action_mismatch_error(j) is not null
     and  l_cpt_type_updatable_error(j) is not null
     and  l_cp_purpose_web_err(j) is not null
	 and  l_cp_purpose_error(j) is not null
	 and  l_edi_id_number_error(j) is not null
	 and  l_email_address_error(j) is not null
	 and  l_email_format_error(j) is not null
	 and  l_phone_country_code_error(j) is not null
	 and  l_phone_line_type_error(j) is not null
	 and  l_phone_number_error(j) is not null
	 and  l_telex_number_error(j) is not null
	 and  l_timezone_error(j) is not null
	 and  l_url_error(j) is not null
	 and  l_flex_val_errors(j) = 0
	 and  l_dss_security_errors(j) = 'T'
	 and  l_web_type_error(j) is not null
	 --and  l_orig_system_ref_upd_error(j) is not null
	 and  l_error_flag(j) is null
	 --and  l_owner_table_error(j) is not null
         and l_third_party_update_error(j) is not null /* Bug 4079902 */
         and l_createdby_errors(j) is not null;

 FND_FILE.put_line(fnd_file.log, 'CPT:Rows updated = ' || SQL%ROWCOUNT);


   EXCEPTION
    WHEN OTHERS THEN
     -- dbms_output.put_line('Other exceptions');
      --Record the errors if occurred.
      l_dml_exception := 'Y';
  END;
  -- record errors
report_errors(P_DML_RECORD,'U', l_dml_exception);

ForAll j in 1..l_contact_point_id.count
    update hz_parties hz_pty
       set (email_address,url  ) =
	   ( select email_address,url
	       from hz_contact_points
	      where contact_point_id = l_contact_point_id(j)
	   )
     where hz_pty.party_id = l_party_id(j)
     and  l_action_mismatch_error(j) is not null
     and  l_cpt_type_updatable_error(j) is not null
     and  l_cp_purpose_web_err(j) is not null
	 and  l_cp_purpose_error(j) is not null
	 and  l_edi_id_number_error(j) is not null
	 and  l_email_address_error(j) is not null
	 and  l_email_format_error(j) is not null
	 and  l_phone_country_code_error(j) is not null
	 and  l_phone_line_type_error(j) is not null
	 and  l_phone_number_error(j) is not null
	 and  l_telex_number_error(j) is not null
	 and  l_timezone_error(j) is not null
	 and  l_url_error(j) is not null
	 and  l_flex_val_errors(j) = 0
	 and  l_dss_security_errors(j) = 'T'
	 and  l_web_type_error(j) is not null
	 --and  l_orig_system_ref_upd_error(j) is not null
	 and  l_error_flag(j) is null
	 --and  l_owner_table_error(j) is not null
	 and  l_primary_flag(j) = 'Y'
         and l_third_party_update_error(j) is not null /* Bug 4079902 */
         and l_createdby_errors(j) is not null;


    /******************************************/
    /*           Handle OSR change            */
    /******************************************/

    /* End date current MOSR mapping */
    ForAll j in 1..l_cp_orig_system_reference.count
      update HZ_ORIG_SYS_REFERENCES set
        STATUS = 'I',
        LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
        END_DATE_ACTIVE = P_DML_RECORD.SYSDATE,
        OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1
      where ORIG_SYSTEM = l_cp_orig_system(j)
        and ORIG_SYSTEM_REFERENCE = l_old_cp_orig_system_ref(j)
        and OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
        and OWNER_TABLE_ID = l_contact_point_id(j)
        and l_new_osr_exists_flag(j) is not null
        and l_num_row_processed(j) = 1
        and status = 'A'
        --and trunc(nvl(end_date_active, P_DML_RECORD.SYSDATE)) >= trunc(P_DML_RECORD.SYSDATE)
	and l_cp_orig_system_reference(j) <> l_old_cp_orig_system_ref(j);


    /* Insert new MOSR mapping in case of OSR change */
    ForAll j in 1..l_cp_orig_system_reference.count
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
	l_cp_orig_system(j),
	l_cp_orig_system_reference(j),
	'HZ_CONTACT_POINTS',
	l_contact_point_id(j),
	l_party_id(j),
	'A',
	l_old_cp_orig_system_ref(j),
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
        l_old_cp_orig_system_ref(j) is not null
        and l_num_row_processed(j) = 1
	and l_cp_orig_system_reference(j) <> l_old_cp_orig_system_ref(j);
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT: process_update_contactpoints-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO process_update_cpts_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO process_update_cpts_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

 WHEN OTHERS THEN
   ROLLBACK TO process_update_cpts_pvt;
   FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while updating contactpoints');
   FND_FILE.put_line(fnd_file.log, l_errm);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
   FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);


END process_update_contactpoints;


/********************************************************************************
*
*	load_contactpoints
*
********************************************************************************/

PROCEDURE load_contactpoints
(
P_DML_RECORD  	       	   IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
,x_return_status             OUT NOCOPY    VARCHAR2
,x_msg_count                 OUT NOCOPY    NUMBER
,x_msg_data                  OUT NOCOPY    VARCHAR2
)

IS
l_debug_prefix	       VARCHAR2(30) := '';
BEGIN

savepoint load_contactpoints_pvt;

-- Check if API is called in debug mode. If yes, enable debug.
--enable_debug;
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:load_contactpoints()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;

 FND_MSG_PUB.initialize;

 FND_FILE.put_line(fnd_file.log,'load_contactpoints+');

 /**** ?? Remove later. Disable policy function ***/
 --hz_common_pub.disable_cont_source_security; Bug No:3387220

 --Initialize API return status to success.
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 process_insert_contactpoints
 (
   P_DML_RECORD  	 	 =>P_DML_RECORD
   ,x_return_status    => x_return_status
   ,x_msg_count        => x_msg_count
   ,x_msg_data         => x_msg_data
 );


 process_update_contactpoints(
   P_DML_RECORD  	 	 =>P_DML_RECORD
   ,x_return_status    => x_return_status
   ,x_msg_count        => x_msg_count
   ,x_msg_data         => x_msg_data
 );

-- dbms_output.put_line('load_contactpoints-');
IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CPT:load_contactpoints()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
END IF;
 -- if enabled, disable debug
 --disable_debug;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO load_contactpoints_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
   IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
   END IF;
   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(p_message=>'CPT:load_contactpoints()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   ROLLBACK TO load_contactpoints_pvt;
   FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading contactpoints');
   FND_FILE.put_line(fnd_file.log, l_errm);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
   FND_MESSAGE.SET_TOKEN('ERROR' ,l_errm);
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
   IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
   END IF;
   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(p_message=>'CPT:load_contactpoints()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;

 WHEN OTHERS THEN
   ROLLBACK TO load_contactpoints_pvt;
   FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading contactpoints');
   FND_FILE.put_line(fnd_file.log, l_errm);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
   FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
   IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
   END IF;
   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(p_message=>'CPT:load_contactpoints()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;
END load_contactpoints;

END HZ_IMP_LOAD_CPT_PKG;

/
