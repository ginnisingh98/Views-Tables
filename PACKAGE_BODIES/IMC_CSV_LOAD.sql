--------------------------------------------------------
--  DDL for Package Body IMC_CSV_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_CSV_LOAD" AS
/* $Header: IMCLOADB.pls 120.13.12010000.2 2009/07/31 06:26:24 vsegu ship $ */
PROCEDURE LOAD_DETAILS(loadId NUMBER, batchId NUMBER) IS
p_init_msg_list           	              VARCHAR2(25) := FND_API.G_FALSE;
x_return_status                           VARCHAR2(50);
x_msg_count                               NUMBER;
x_msg_data                                VARCHAR2(100);
load_id                                   imc_csv_interface_fields.LOAD_ID%TYPE;
BATCH_ID                                  imc_csv_interface_fields.BATCH_ID%TYPE;
PARTY_REC_ID                              imc_csv_interface_fields.PARTY_REC_ID%TYPE;
REC_STATUS                                imc_csv_interface_fields.REC_STATUS%TYPE;
PARTY_ORIG_SYSTEM                         HZ_IMP_PARTIES_INT.PARTY_ORIG_SYSTEM%TYPE;
PARTY_ORIG_SYSTEM_REFERENCE               HZ_IMP_PARTIES_INT.PARTY_ORIG_SYSTEM_REFERENCE%TYPE;
PARTY_TYPE                                imc_csv_interface_fields.PARTY_TYPE%TYPE;
ORGANIZATION_NAME                         imc_csv_interface_fields.ORGANIZATION_NAME%TYPE;
CEO_NAME                                  imc_csv_interface_fields.CEO_NAME%TYPE;
CEO_TITLE                                 imc_csv_interface_fields.CEO_TITLE%TYPE;
PRINCIPAL_NAME                            imc_csv_interface_fields.PRINCIPAL_NAME%TYPE;
PRINCIPAL_TITLE                           imc_csv_interface_fields.PRINCIPAL_TITLE%TYPE;
LEGAL_STATUS                              imc_csv_interface_fields.LEGAL_STATUS%TYPE;
CONTROL_YR                                imc_csv_interface_fields.CONTROL_YR%TYPE;
EMPLOYEES_TOTAL                           imc_csv_interface_fields.EMPLOYEES_TOTAL%TYPE;
HQ_BRANCH_IND                             imc_csv_interface_fields.HQ_BRANCH_IND%TYPE;
BRANCH_FLAG                               imc_csv_interface_fields.BRANCH_FLAG%TYPE;
OOB_IND                                   imc_csv_interface_fields.OOB_IND%TYPE;
TAX_REFERENCE                             imc_csv_interface_fields.TAX_REFERENCE%TYPE;
GSA_INDICATOR_FLAG                        imc_csv_interface_fields.GSA_INDICATOR_FLAG%TYPE;
JGZZ_FISCAL_CODE                          imc_csv_interface_fields.JGZZ_FISCAL_CODE%TYPE;
ANALYSIS_FY                               imc_csv_interface_fields.ANALYSIS_FY%TYPE;
FISCAL_YEAREND_MONTH                      imc_csv_interface_fields.FISCAL_YEAREND_MONTH%TYPE;
CURR_FY_POTENTIAL_REVENUE                 imc_csv_interface_fields.CURR_FY_POTENTIAL_REVENUE%TYPE;
NEXT_FY_POTENTIAL_REVENUE                 imc_csv_interface_fields.NEXT_FY_POTENTIAL_REVENUE%TYPE;
YEAR_ESTABLISHED                          imc_csv_interface_fields.YEAR_ESTABLISHED%TYPE;
MISSION_STATEMENT                         imc_csv_interface_fields.MISSION_STATEMENT%TYPE;
ORGANIZATION_TYPE                         imc_csv_interface_fields.ORGANIZATION_TYPE%TYPE;
BUSINESS_SCOPE                            imc_csv_interface_fields.BUSINESS_SCOPE%TYPE;
KNOWN_AS                                  imc_csv_interface_fields.KNOWN_AS%TYPE;
KNOWN_AS2                                 imc_csv_interface_fields.KNOWN_AS2%TYPE;
KNOWN_AS3                                 imc_csv_interface_fields.KNOWN_AS3%TYPE;
KNOWN_AS4                                 imc_csv_interface_fields.KNOWN_AS4%TYPE;
KNOWN_AS5                                 imc_csv_interface_fields.KNOWN_AS5%TYPE;
LOCAL_BUS_IDEN_TYPE                       imc_csv_interface_fields.LOCAL_BUS_IDEN_TYPE%TYPE;
LOCAL_BUS_IDENTIFIER                      imc_csv_interface_fields.LOCAL_BUS_IDENTIFIER%TYPE;
PREF_FUNCTIONAL_CURRENCY                  imc_csv_interface_fields.PREF_FUNCTIONAL_CURRENCY%TYPE;
REGISTRATION_TYPE                         imc_csv_interface_fields.REGISTRATION_TYPE%TYPE;
PARENT_SUB_IND                            imc_csv_interface_fields.PARENT_SUB_IND%TYPE;
INCORP_YEAR                               imc_csv_interface_fields.INCORP_YEAR%TYPE;
PUBLIC_PRIVATE_OWNERSHIP_FLAG             imc_csv_interface_fields.PUBLIC_PRIVATE_OWNERSHIP_FLAG%TYPE;
TOTAL_PAYMENTS                            imc_csv_interface_fields.TOTAL_PAYMENTS%TYPE;
DUNS_NUMBER_C                             imc_csv_interface_fields.DUNS_NUMBER_C%TYPE;
CLASS_CODE                                imc_csv_interface_fields.CLASS_CODE%TYPE;
CLASS_CATEGORY                            imc_csv_interface_fields.CLASS_CATEGORY%TYPE;
PERSON_PRE_NAME_ADJUNCT                   imc_csv_interface_fields.PERSON_PRE_NAME_ADJUNCT%TYPE;
PERSON_FIRST_NAME                         imc_csv_interface_fields.PERSON_FIRST_NAME%TYPE;
PERSON_MIDDLE_NAME                        imc_csv_interface_fields.PERSON_MIDDLE_NAME%TYPE;
PERSON_LAST_NAME                          imc_csv_interface_fields.PERSON_LAST_NAME%TYPE;
PERSON_NAME_SUFFIX                        imc_csv_interface_fields.PERSON_NAME_SUFFIX%TYPE;
PERSON_TITLE                              imc_csv_interface_fields.PERSON_TITLE%TYPE;
PERSON_ACADEMIC_TITLE                     imc_csv_interface_fields.PERSON_ACADEMIC_TITLE%TYPE;
PERSON_PREVIOUS_LAST_NAME                 imc_csv_interface_fields.PERSON_PREVIOUS_LAST_NAME%TYPE;
PERSON_INITIALS                           imc_csv_interface_fields.PERSON_INITIALS%TYPE;
PERSON_NAME_PHONETIC                      imc_csv_interface_fields.PERSON_NAME_PHONETIC%TYPE;
PERSON_FIRST_NAME_PHONETIC                imc_csv_interface_fields.PERSON_FIRST_NAME_PHONETIC%TYPE;
PERSON_MIDDLE_NAME_PHONETIC               imc_csv_interface_fields.PERSON_MIDDLE_NAME_PHONETIC%TYPE;
PERSON_LAST_NAME_PHONETIC                 imc_csv_interface_fields.PERSON_LAST_NAME_PHONETIC%TYPE;
PERSON_IDEN_TYPE                          imc_csv_interface_fields.PERSON_IDEN_TYPE%TYPE;
PERSON_IDENTIFIER                         imc_csv_interface_fields.PERSON_IDENTIFIER%TYPE;
DATE_OF_BIRTH                             imc_csv_interface_fields.DATE_OF_BIRTH%TYPE;
PLACE_OF_BIRTH                            imc_csv_interface_fields.PLACE_OF_BIRTH%TYPE;
DATE_OF_DEATH                             imc_csv_interface_fields.DATE_OF_DEATH%TYPE;
GENDER                                    imc_csv_interface_fields.GENDER%TYPE;
DECLARED_ETHNICITY                        imc_csv_interface_fields.DECLARED_ETHNICITY%TYPE;
MARITAL_STATUS                            imc_csv_interface_fields.MARITAL_STATUS%TYPE;
MARITAL_STATUS_EFFECTIVE_DATE             imc_csv_interface_fields.MARITAL_STATUS_EFFECTIVE_DATE%TYPE;
PERSONAL_INCOME                           imc_csv_interface_fields.PERSONAL_INCOME%TYPE;
HEAD_OF_HOUSEHOLD_FLAG                    imc_csv_interface_fields.HEAD_OF_HOUSEHOLD_FLAG%TYPE;
HOUSEHOLD_INCOME                          imc_csv_interface_fields.HOUSEHOLD_INCOME%TYPE;
HOUSEHOLD_SIZE                            imc_csv_interface_fields.HOUSEHOLD_SIZE%TYPE;
RENT_OWN_IND                              imc_csv_interface_fields.RENT_OWN_IND%TYPE;
COUNTRY                                   imc_csv_interface_fields.COUNTRY%TYPE;
ADDRESS1                                  imc_csv_interface_fields.ADDRESS1%TYPE;
ADDRESS2                                  imc_csv_interface_fields.ADDRESS2%TYPE;
ADDRESS3                                  imc_csv_interface_fields.ADDRESS3%TYPE;
ADDRESS4                                  imc_csv_interface_fields.ADDRESS4%TYPE;
CITY                                      imc_csv_interface_fields.CITY%TYPE;
POSTAL_CODE                               imc_csv_interface_fields.POSTAL_CODE%TYPE;
STATE                                     imc_csv_interface_fields.STATE%TYPE;
PROVINCE                                  imc_csv_interface_fields.PROVINCE%TYPE;
COUNTY                                    imc_csv_interface_fields.COUNTY%TYPE;
ADDRESS_LINES_PHONETIC                    imc_csv_interface_fields.ADDRESS_LINES_PHONETIC%TYPE;
LOCATION_DIRECTIONS                       HZ_IMP_ADDRESSES_INT.LOCATION_DIRECTIONS%TYPE;
DESCRIPTION                               imc_csv_interface_fields.DESCRIPTION%TYPE;
SALES_TAX_GEOCODE                         HZ_IMP_ADDRESSES_INT.SALES_TAX_GEOCODE%TYPE;
PRIMARY_FLAG                              HZ_IMP_ADDRESSES_INT.PRIMARY_FLAG%TYPE;
PARTY_SITE_NAME                           imc_csv_interface_fields.PARTY_SITE_NAME%TYPE;
CONTACT_POINT_TYPE                        imc_csv_interface_fields.CONTACT_POINT_TYPE%TYPE;
EMAIL_FORMAT                              imc_csv_interface_fields.EMAIL_FORMAT%TYPE;
EMAIL_ADDRESS                             imc_csv_interface_fields.EMAIL_ADDRESS%TYPE;
PHONE_AREA_CODE                           imc_csv_interface_fields.PHONE_AREA_CODE%TYPE;
PHONE_COUNTRY_CODE                        imc_csv_interface_fields.PHONE_COUNTRY_CODE%TYPE;
PHONE_NUMBER                              imc_csv_interface_fields.PHONE_NUMBER%TYPE;
PHONE_EXTENSION                           imc_csv_interface_fields.PHONE_EXTENSION%TYPE;
PHONE_LINE_TYPE                           imc_csv_interface_fields.PHONE_LINE_TYPE%TYPE;
TELEX_NUMBER                              imc_csv_interface_fields.TELEX_NUMBER%TYPE;
WEB_TYPE                                  imc_csv_interface_fields.WEB_TYPE%TYPE;
URL                                       imc_csv_interface_fields.URL%TYPE;
RAW_PHONE_NUMBER                          imc_csv_interface_fields.RAW_PHONE_NUMBER%TYPE;
CONTACT_POINT_PURPOSE                     imc_csv_interface_fields.CONTACT_POINT_PURPOSE%TYPE;
IDENTIFYING_ADDRESS_FLAG                  VARCHAR2(100);
LANGUAGE                                  imc_csv_interface_fields.LANGUAGE%TYPE;
DEPARTMENT_CODE                           imc_csv_interface_fields.DEPARTMENT_CODE%TYPE;
DEPARTMENT                                imc_csv_interface_fields.DEPARTMENT%TYPE;
TITLE                                     imc_csv_interface_fields.TITLE%TYPE;
JOB_TITLE                                 imc_csv_interface_fields.JOB_TITLE%TYPE;
LINE_OF_BUSINESS                          imc_csv_interface_fields.LINE_OF_BUSINESS%TYPE;
CREATION_DATE                             imc_csv_interface_fields.CREATION_DATE%TYPE;
CREATED_BY                                imc_csv_interface_fields.CREATED_BY%TYPE;
LAST_UPDATE_DATE                          imc_csv_interface_fields.LAST_UPDATE_DATE%TYPE;
LAST_UPDATED_BY                           imc_csv_interface_fields.LAST_UPDATED_BY%TYPE;
LAST_UPDATE_LOGIN                         imc_csv_interface_fields.LAST_UPDATE_LOGIN%TYPE;

date_format  imc_csv_load_details.DATE_FORMAT%TYPE;
ADDRESS_FLAG imc_csv_load_details.ADDRESS_FLAG%TYPE;
CONTACT_POINTS_FLAG imc_csv_load_details.CONTACT_POINTS_FLAG%TYPE;
CLASSIFICATION_FLAG imc_csv_load_details.CLASSIFICATION_FLAG%TYPE;
CONTACT_FLAG  VARCHAR2(10);

birthdate          HZ_IMP_PARTIES_INT.DATE_OF_BIRTH%TYPE;
deathdate          HZ_IMP_PARTIES_INT.DATE_OF_DEATH%TYPE;
maritaldate        HZ_IMP_PARTIES_INT.MARITAL_STATUS_EFFECTIVE_DATE%TYPE;
--Data Type validations for CONTROL_YR,EMPLOYEES_TOTAL,INCORP_YEAR,TOTAL_PAYMENTS,YEAR_ESTABLISHED
control_year       HZ_IMP_PARTIES_INT.CONTROL_YR%TYPE;
emp_total          HZ_IMP_PARTIES_INT.EMPLOYEES_TOTAL%TYPE;
incorporation_year HZ_IMP_PARTIES_INT.INCORP_YEAR%TYPE;
total_pays         HZ_IMP_PARTIES_INT.TOTAL_PAYMENTS%TYPE;
yr_established     HZ_IMP_PARTIES_INT.YEAR_ESTABLISHED%TYPE;
per_income         HZ_IMP_PARTIES_INT.PERSONAL_INCOME%TYPE;
house_income       HZ_IMP_PARTIES_INT.HOUSEHOLD_INCOME%TYPE;
house_size         HZ_IMP_PARTIES_INT.HOUSEHOLD_SIZE%TYPE;

lookup_code_count  VARCHAR2(50);
CNT_ORIG_SYSTEM_REFERENCE number;
CNTORG_ORIG_SYSTEM_REFERENCE number;
SITE_ORIG_SYSTEM_REFERENCE number;
CP_ORIG_SYSTEM_REFERENCE number;
PARTY_NAME imc_csv_interface_fields.ORGANIZATION_NAME%TYPE;

TYPE org_cnt_rec_type IS RECORD (
   org_name                  imc_csv_interface_fields.ORGANIZATION_NAME%TYPE,
   original_sys_ref                NUMBER);

TYPE org_contact_type IS TABLE OF org_cnt_rec_type INDEX BY BINARY_INTEGER;

org_contact org_contact_type;
org_contact_rec org_cnt_rec_type;
old_org_name imc_csv_interface_fields.ORGANIZATION_NAME%TYPE;
orig_sys_ref NUMBER;
old_contact_org VARCHAR2(100);
i NUMBER;

 cursor get_details(loadId number, batchId number) is
 select LOAD_ID,BATCH_ID,PARTY_REC_ID,REC_STATUS,PARTY_TYPE,ORGANIZATION_NAME,CEO_NAME,
CEO_TITLE,PRINCIPAL_NAME,PRINCIPAL_TITLE,LEGAL_STATUS,CONTROL_YR,EMPLOYEES_TOTAL,
HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,GSA_INDICATOR_FLAG,
JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,NEXT_FY_POTENTIAL_REVENUE,
YEAR_ESTABLISHED,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,KNOWN_AS2,KNOWN_AS3,KNOWN_AS4,
KNOWN_AS5,LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,
INCORP_YEAR,LINE_OF_BUSINESS,PUBLIC_PRIVATE_OWNERSHIP_FLAG,TOTAL_PAYMENTS,DUNS_NUMBER_C,PERSON_PRE_NAME_ADJUNCT,
PERSON_FIRST_NAME,PERSON_MIDDLE_NAME,PERSON_LAST_NAME,PERSON_NAME_SUFFIX,PERSON_TITLE,PERSON_ACADEMIC_TITLE,
PERSON_PREVIOUS_LAST_NAME,PERSON_INITIALS,PERSON_NAME_PHONETIC,PERSON_FIRST_NAME_PHONETIC,PERSON_MIDDLE_NAME_PHONETIC,
PERSON_LAST_NAME_PHONETIC,PERSON_IDEN_TYPE,PERSON_IDENTIFIER,DATE_OF_BIRTH,PLACE_OF_BIRTH,DATE_OF_DEATH,GENDER,
DECLARED_ETHNICITY,MARITAL_STATUS,MARITAL_STATUS_EFFECTIVE_DATE,PERSONAL_INCOME,HEAD_OF_HOUSEHOLD_FLAG,
HOUSEHOLD_INCOME,HOUSEHOLD_SIZE,RENT_OWN_IND,COUNTRY,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,POSTAL_CODE,STATE,
PROVINCE,COUNTY,ADDRESS_LINES_PHONETIC,DESCRIPTION,LANGUAGE,PARTY_SITE_NAME,CONTACT_POINT_TYPE,EMAIL_FORMAT,
EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,WEB_TYPE,URL,
RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CLASS_CATEGORY,CLASS_CODE,DEPARTMENT_CODE,DEPARTMENT,TITLE,JOB_TITLE,
TELEX_NUMBER,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN
 from imc_csv_interface_fields where load_id = loadId and batch_id=batchId
 and (rec_status='E' OR nvl(rec_status,'NULL')='NULL');

 cursor get_load_details(loadId number, batchId number) is
 select date_format,ADDRESS_FLAG,CONTACT_POINTS_FLAG,CLASSIFICATION_FLAG
  from imc_csv_load_details where load_id = loadId and batch_id=batchId;

 cursor get_next_ref_id is
 select imc_csv_orig_ref_s.NEXTVAL from dual;

-- Bug 4310048/4315682 : do not show invalid lookups
-- Add check for ENABLED_FLAG and END_DATE_ACTIVE

cursor legal_status_code(legal_status_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='LEGAL_STATUS' and lookup_code=legal_status_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor hq_branch(hq_branch_ind_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='HQ_BRANCH_IND' and lookup_code=hq_branch_ind_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor FISCAL_YREND_MONTH(fiscal_yearend_month_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='MONTH' and lookup_code = fiscal_yearend_month_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor REGISTRY_TYPE(registration_type_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='REGISTRATION_TYPE' and lookup_code=registration_type_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor contact_title(pre_name_adjunct VARCHAR2) is
select count(*) from ar_lookups where lookup_type='CONTACT_TITLE' and lookup_code=pre_name_adjunct
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor marry_status(marital_status_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='MARITAL_STATUS' and lookup_code=marital_status_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor own_rent(own_rent_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='OWN_RENT_IND' and lookup_code=own_rent_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor contact_pnt_type(contact_pnt_type_cd VARCHAR2) is
select count(*) from ar_lookups where lookup_type='COMMUNICATION_TYPE' and lookup_code=contact_pnt_type_cd
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

-- Bug 4310158: Should only allow valid country code
cursor country_code(country_cd VARCHAR2) is
select count(*) from FND_TERRITORIES where TERRITORY_CODE=country_cd AND OBSOLETE_FLAG = 'N';

cursor language_code(language_cd VARCHAR2) is
select count(*) from FND_LANGUAGES where LANGUAGE_CODE IN ('B', 'I') and LANGUAGE_CODE=language_cd;

cursor clss_category(p_class_category VARCHAR2) is
select count(*) from hz_class_categories where class_category = p_class_category;

cursor clss_code(class_category VARCHAR2,class_code VARCHAR2) is
select count(*) from ar_lookups where lookup_type = class_category and lookup_code = class_code
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

cursor ph_line_type(ph_line_type_value VARCHAR2) is
select count(*) from ar_lookups where lookup_type='PHONE_LINE_TYPE' and lookup_code=ph_line_type_value
AND ENABLED_FLAG = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)) ;

BEGIN
 open get_load_details(loadId,batchId);
  fetch get_load_details into date_format,ADDRESS_FLAG,CONTACT_POINTS_FLAG,CLASSIFICATION_FLAG;
 close get_load_details ;

 open get_details(loadId,batchId);
 LOOP
 fetch get_details into
LOAD_ID,BATCH_ID,PARTY_REC_ID,REC_STATUS,PARTY_TYPE,ORGANIZATION_NAME,CEO_NAME,
CEO_TITLE,PRINCIPAL_NAME,PRINCIPAL_TITLE,LEGAL_STATUS,CONTROL_YR,EMPLOYEES_TOTAL,
HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,GSA_INDICATOR_FLAG,
JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,NEXT_FY_POTENTIAL_REVENUE,
YEAR_ESTABLISHED,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,KNOWN_AS2,KNOWN_AS3,KNOWN_AS4,
KNOWN_AS5,LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,
INCORP_YEAR,LINE_OF_BUSINESS,PUBLIC_PRIVATE_OWNERSHIP_FLAG,TOTAL_PAYMENTS,DUNS_NUMBER_C,PERSON_PRE_NAME_ADJUNCT,
PERSON_FIRST_NAME,PERSON_MIDDLE_NAME,PERSON_LAST_NAME,PERSON_NAME_SUFFIX,PERSON_TITLE,PERSON_ACADEMIC_TITLE,
PERSON_PREVIOUS_LAST_NAME,PERSON_INITIALS,PERSON_NAME_PHONETIC,PERSON_FIRST_NAME_PHONETIC,PERSON_MIDDLE_NAME_PHONETIC,
PERSON_LAST_NAME_PHONETIC,PERSON_IDEN_TYPE,PERSON_IDENTIFIER,DATE_OF_BIRTH,PLACE_OF_BIRTH,DATE_OF_DEATH,GENDER,
DECLARED_ETHNICITY,MARITAL_STATUS,MARITAL_STATUS_EFFECTIVE_DATE,PERSONAL_INCOME,HEAD_OF_HOUSEHOLD_FLAG,
HOUSEHOLD_INCOME,HOUSEHOLD_SIZE,RENT_OWN_IND,COUNTRY,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,POSTAL_CODE,STATE,
PROVINCE,COUNTY,ADDRESS_LINES_PHONETIC,DESCRIPTION,LANGUAGE,PARTY_SITE_NAME,CONTACT_POINT_TYPE,EMAIL_FORMAT,
EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,WEB_TYPE,URL,
RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CLASS_CATEGORY,CLASS_CODE,DEPARTMENT_CODE,DEPARTMENT,TITLE,JOB_TITLE,
TELEX_NUMBER,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN;
  exit when get_details%NOTFOUND;

 open get_next_ref_id;
 fetch get_next_ref_id into PARTY_ORIG_SYSTEM_REFERENCE;
close get_next_ref_id;
REC_STATUS:=null;
--Validations for the Organization fields
if (PARTY_TYPE='ORGANIZATION') then
   if (ORGANIZATION_NAME is null) then
    insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',null,null,'ORGANIZATION_NAME',null,null,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||' and party_rec_id = '||PARTY_REC_ID;
     REC_STATUS := 'E';
   end if;
   PARTY_NAME:=ORGANIZATION_NAME;
  -- dbms_output.put_line('registration type'||REGISTRATION_TYPE);
   --Data Type validations for CONTROL_YR,EMPLOYEES_TOTAL,INCORP_YEAR,TOTAL_PAYMENTS,YEAR_ESTABLISHED

   if(CONTROL_YR is not null) then
   begin
      control_year := to_number(CONTROL_YR);
    EXCEPTION
     WHEN OTHERS THEN
    insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',CONTROL_YR,null,'CONTROL_YR',null,ORGANIZATION_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

  if(EMPLOYEES_TOTAL is not null) then
   begin
      emp_total := to_number(EMPLOYEES_TOTAL);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',EMPLOYEES_TOTAL,null,'EMPLOYEES_TOTAL',null,ORGANIZATION_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

   if(INCORP_YEAR is not null) then
   begin
      incorporation_year := to_number(INCORP_YEAR);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',INCORP_YEAR,null,'INCORP_YEAR',null,ORGANIZATION_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;


   if(TOTAL_PAYMENTS is not null) then
   begin
      total_pays := to_number(TOTAL_PAYMENTS);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',TOTAL_PAYMENTS,null,'TOTAL_PAYMENTS',null,ORGANIZATION_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

   if(YEAR_ESTABLISHED is not null) then
   begin
      yr_established := to_number(YEAR_ESTABLISHED);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',YEAR_ESTABLISHED,null,'YEAR_ESTABLISHED',null,ORGANIZATION_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

  if (LEGAL_STATUS is not null) then
   open legal_status_code(LEGAL_STATUS);
     fetch legal_status_code into lookup_code_count;
     if (lookup_code_count=0) then
      insert into imc_csv_error_details(
      LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
      CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
      loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',LEGAL_STATUS,null,'LEGAL_STATUS','LEGAL_STATUS',ORGANIZATION_NAME,'E',
      SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

      execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
     REC_STATUS := 'E';
    end if;
   close legal_status_code;
  end if;

  if (HQ_BRANCH_IND is not null) then
   open hq_branch(HQ_BRANCH_IND);
     fetch hq_branch into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',HQ_BRANCH_IND,null,'HQ_BRANCH_IND','HQ_BRANCH_IND',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close hq_branch;
  end if;

  if (FISCAL_YEAREND_MONTH is not null) then
   open FISCAL_YREND_MONTH(FISCAL_YEAREND_MONTH);
     fetch FISCAL_YREND_MONTH into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',FISCAL_YEAREND_MONTH,null,'FISCAL_YEAREND_MONTH','MONTH',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close FISCAL_YREND_MONTH;
  end if;

  if (REGISTRATION_TYPE is not null) then
   open REGISTRY_TYPE(REGISTRATION_TYPE);
     fetch REGISTRY_TYPE into lookup_code_count;
    if (lookup_code_count=0) then
     --dbms_output.put_line('lookup code count'||lookup_code_count);
     --dbms_output.put_line('resistation type'||REGISTRATION_TYPE);
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',REGISTRATION_TYPE,null,'REGISTRATION_TYPE','REGISTRATION_TYPE',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close REGISTRY_TYPE;
  end if;

   if (OOB_IND is not null) then
    if (OOB_IND='Y' OR OOB_IND='N') then
     null;
    else
    insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',OOB_IND,null,'OOB_IND','IMC_CSV_Y_OR_N',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;
  end if;

  if (BRANCH_FLAG is not null) then
    if (BRANCH_FLAG='Y' OR BRANCH_FLAG='N') then
     null;
    else
    insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',BRANCH_FLAG,null,'BRANCH_FLAG','IMC_CSV_Y_OR_N',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;
  end if;

   if (PARENT_SUB_IND is not null) then
    if (PARENT_SUB_IND='Y' OR PARENT_SUB_IND='N') then
     null;
    else
    insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',PARENT_SUB_IND,null,'PARENT_SUB_IND','IMC_CSV_Y_OR_N',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;
  end if;

   if (PUBLIC_PRIVATE_OWNERSHIP_FLAG is not null) then
    if (PUBLIC_PRIVATE_OWNERSHIP_FLAG='Y' OR PUBLIC_PRIVATE_OWNERSHIP_FLAG='N') then
     null;
    else
    insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',PUBLIC_PRIVATE_OWNERSHIP_FLAG,null,'PUBLIC_PRIVATE_OWNERSHIP_FLAG','IMC_CSV_Y_OR_N',ORGANIZATION_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;
  end if;
 END IF;

 ----Validations for the Person fields
 if (PARTY_TYPE='PERSON') then
    if (PERSON_FIRST_NAME is null and PERSON_LAST_NAME is null) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',null,null,'PERSON_FIRST_NAME',null,null,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
     REC_STATUS := 'E';
    else
     if (ORGANIZATION_NAME is not null) then
     CONTACT_FLAG:='Y';
     end if;
   end if;
     PARTY_NAME:=PERSON_FIRST_NAME||' '||PERSON_LAST_NAME;
     --Data Type validations for PERSONAL_INCOME,HOUSEHOLD_INCOME,HOUSEHOLD_SIZE

   if(PERSONAL_INCOME is not null) then
   begin
      per_income := to_number(PERSONAL_INCOME);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',PERSONAL_INCOME,null,'PERSONAL_INCOME',null,PARTY_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

   if(HOUSEHOLD_INCOME is not null) then
   begin
      house_income := to_number(HOUSEHOLD_INCOME);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',HOUSEHOLD_INCOME,null,'HOUSEHOLD_INCOME',null,PARTY_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;

   if(HOUSEHOLD_SIZE is not null) then
   begin
      house_size := to_number(HOUSEHOLD_SIZE);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATA_TYPE',HOUSEHOLD_SIZE,null,'HOUSEHOLD_SIZE',null,PARTY_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
   end if;


    IF (DATE_OF_BIRTH is not null ) then
    begin
      birthdate := to_date(DATE_OF_BIRTH,date_format);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATE_FORMAT',DATE_OF_BIRTH,null,'DATE_OF_BIRTH',null,PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
    end if;

    IF (DATE_OF_DEATH is not null ) then
    begin
      deathdate := to_date(DATE_OF_DEATH,date_format);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATE_FORMAT',DATE_OF_DEATH,null,'DATE_OF_DEATH',null,PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
    end if;

    IF (MARITAL_STATUS_EFFECTIVE_DATE is not null ) then
    begin
      maritaldate := to_date(MARITAL_STATUS_EFFECTIVE_DATE,date_format);
    EXCEPTION
     WHEN OTHERS THEN
     insert into imc_csv_error_details(
    LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
    loadId,batchId,PARTY_REC_ID,'DATE_FORMAT',MARITAL_STATUS_EFFECTIVE_DATE,null,'MARITAL_STATUS_EFFECTIVE_DATE',null,PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
    SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);

    execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end;
    end if;

  if (PERSON_PRE_NAME_ADJUNCT is not null) then
   open contact_title(PERSON_PRE_NAME_ADJUNCT);
     fetch contact_title into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',PERSON_PRE_NAME_ADJUNCT,null,'PERSON_PRE_NAME_ADJUNCT','CONTACT_TITLE',PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close contact_title;
  end if;

  if (MARITAL_STATUS is not null) then
   open marry_status(MARITAL_STATUS);
     fetch marry_status into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',MARITAL_STATUS,null,'MARITAL_STATUS','MARITAL_STATUS',PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close marry_status;
  end if;

  if (RENT_OWN_IND is not null) then
   open own_rent(RENT_OWN_IND);
     fetch own_rent into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',RENT_OWN_IND,null,'RENT_OWN_IND','OWN_RENT_IND',PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close own_rent;
  end if;

  if (HEAD_OF_HOUSEHOLD_FLAG is not null) then
    if (HEAD_OF_HOUSEHOLD_FLAG='Y' OR HEAD_OF_HOUSEHOLD_FLAG='N') then
     null;
    else
    insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',HEAD_OF_HOUSEHOLD_FLAG,null,'HEAD_OF_HOUSEHOLD_FLAG','IMC_CSV_Y_OR_N',PERSON_FIRST_NAME||' '||PERSON_LAST_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;
  end if;
 END IF;

----Validations for the Address fields
 if(ADDRESS_FLAG ='Y') then
    if (ADDRESS1 is null) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',ADDRESS1,null,'ADDRESS1',null,PARTY_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   end if;

  if (COUNTRY is not null) then
   open country_code(COUNTRY);
     fetch country_code into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'VALUE_ERROR',COUNTRY,null,'COUNTRY',null,PARTY_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close country_code;
  else
   insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',COUNTRY,null,'COUNTRY',null,PARTY_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
  end if;

  if (LANGUAGE is not null) then
   open language_code(LANGUAGE);
     fetch language_code into lookup_code_count;
    if (lookup_code_count=0) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'VALUE_ERROR',LANGUAGE,null,'LANGUAGE',null,PARTY_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
    end if;
   close language_code;
  end if;
 end if;

 ----Validations for the contact points fields

     if (PHONE_LINE_TYPE is not null) then
     open ph_line_type(PHONE_LINE_TYPE);
     fetch ph_line_type into lookup_code_count;
      if (lookup_code_count=0) then
       insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',PHONE_LINE_TYPE,null,'PHONE_LINE_TYPE','PHONE_LINE_TYPE',PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;
    close ph_line_type;
    END IF;

 if(CONTACT_POINTS_FLAG ='Y') then
    if (CONTACT_POINT_TYPE is not null) then
     open contact_pnt_type(CONTACT_POINT_TYPE);
     fetch contact_pnt_type into lookup_code_count;
      if (lookup_code_count=0) then
       insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',CONTACT_POINT_TYPE,null,'CONTACT_POINT_TYPE','COMMUNICATION_TYPE',PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;
    close contact_pnt_type;

     if (CONTACT_POINT_TYPE='PHONE' AND (PHONE_NUMBER is null AND RAW_PHONE_NUMBER is null)) then
      insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',PHONE_NUMBER,null,'PHONE_NUMBER',null,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;

     if (CONTACT_POINT_TYPE='FAX' AND (PHONE_NUMBER is null AND RAW_PHONE_NUMBER is null)) then
      insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',PHONE_NUMBER,null,'PHONE_NUMBER',null,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;

     if (CONTACT_POINT_TYPE='EMAIL' AND EMAIL_ADDRESS is null) then
      insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',EMAIL_ADDRESS,null,'EMAIL_ADDRESS',null,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;

     if (CONTACT_POINT_TYPE='WEB' AND URL is null) then
      insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',URL,null,'URL',null,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;

     if (CONTACT_POINT_TYPE='TLX' AND TELEX_NUMBER is null) then
      insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',TELEX_NUMBER,null,'TELEX_NUMBER',null,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
      REC_STATUS := 'E';
     end if;

    end if;
 end if;

----Validations for the classifications fields
 if (CLASSIFICATION_FLAG = 'Y') then
   if (CLASS_CATEGORY is null) then
     insert into imc_csv_error_details(
     LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
     CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
     loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',CLASS_CATEGORY,null,'CLASS_CATEGORY','SIC_CODE_TYPE',PARTY_NAME,'E',
     SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
    REC_STATUS := 'E';
   else
    open clss_category(CLASS_CATEGORY);
     fetch clss_category into lookup_code_count;
    close clss_category;
      if (lookup_code_count=0) then
       insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',CLASS_CATEGORY,null,'CLASS_CATEGORY','SIC_CODE_TYPE',PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
       REC_STATUS := 'E';
      else
       if (CLASS_CODE is null) then
       insert into imc_csv_error_details(
       LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
       loadId,batchId,PARTY_REC_ID,'MANDATORY_FIELDS',CLASS_CODE,null,'CLASS_CODE',CLASS_CATEGORY,PARTY_NAME,'E',
       SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
       execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
       REC_STATUS := 'E';
       else
        open clss_code(CLASS_CATEGORY,CLASS_CODE);
        fetch clss_code into lookup_code_count;
        close clss_code;
        if (lookup_code_count=0) then
        insert into imc_csv_error_details(
        LOAD_ID,BATCH_ID,PARTY_REC_ID,ERROR_TYPE,ERROR_VALUE,NEW_VALUE,ATTRIBUTE_ERRORED,LOOKUP_ERROR,PARTY_NAME,ERROR_STATUS,
        CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN) values(
        loadId,batchId,PARTY_REC_ID,'LOOKUP_ERROR',CLASS_CODE,null,'CLASS_CODE',CLASS_CATEGORY,PARTY_NAME,'E',
        SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
        execute immediate 'update imc_csv_interface_fields set rec_status=''E'' where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
        REC_STATUS := 'E';
       end if;
      end if;
    end if;

   end if;

   end if;


  --INSERT INTO INTERFACE TABLES
  if (REC_STATUS is null) OR (REC_STATUS<>'E') then
    if (PARTY_TYPE='ORGANIZATION') then
        --dbms_output.put_line('inserting into HZ parties interface');
     insert into HZ_IMP_PARTIES_INT(batch_id,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,PARTY_TYPE,ORGANIZATION_NAME,CEO_NAME,CEO_TITLE,PRINCIPAL_NAME,
     PRINCIPAL_TITLE,LEGAL_STATUS,CONTROL_YR,EMPLOYEES_TOTAL,HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,
     GSA_INDICATOR_FLAG,JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,
     NEXT_FY_POTENTIAL_REVENUE,YEAR_ESTABLISHED,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,
     LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,INCORP_YEAR,
     PUBLIC_PRIVATE_OWNERSHIP_FLAG,TOTAL_PAYMENTS,DUNS_NUMBER_C,CREATION_DATE,CREATED_BY,
     LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
     values (batchId,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,'ORGANIZATION',ORGANIZATION_NAME,CEO_NAME,CEO_TITLE,PRINCIPAL_NAME,
     PRINCIPAL_TITLE,LEGAL_STATUS,control_year,emp_total,HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,
     GSA_INDICATOR_FLAG,JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,
     NEXT_FY_POTENTIAL_REVENUE,yr_established,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,
     LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,
     incorporation_year,PUBLIC_PRIVATE_OWNERSHIP_FLAG,total_pays,DUNS_NUMBER_C,SYSDATE,FND_GLOBAL.user_id,SYSDATE,
     FND_GLOBAL.user_id,FND_GLOBAL.login_id);
   elsif (PARTY_TYPE='PERSON') then
     insert into HZ_IMP_PARTIES_INT(batch_id,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,PARTY_TYPE,PERSON_PRE_NAME_ADJUNCT,PERSON_FIRST_NAME,
      PERSON_MIDDLE_NAME,PERSON_LAST_NAME,PERSON_NAME_SUFFIX,PERSON_TITLE,PERSON_ACADEMIC_TITLE,
      PERSON_PREVIOUS_LAST_NAME,PERSON_INITIALS,KNOWN_AS,PERSON_NAME_PHONETIC,PERSON_FIRST_NAME_PHONETIC,
      person_MIDDLE_NAME_PHONETIC,PERSON_LAST_NAME_PHONETIC,TAX_REFERENCE,JGZZ_FISCAL_CODE,PERSON_IDEN_TYPE,
      PERSON_IDENTIFIER,DATE_OF_BIRTH,PLACE_OF_BIRTH,DATE_OF_DEATH,GENDER,DECLARED_ETHNICITY,MARITAL_STATUS,
      MARITAL_STATUS_EFFECTIVE_DATE,PERSONAL_INCOME,HEAD_OF_HOUSEHOLD_FLAG,HOUSEHOLD_INCOME,
      HOUSEHOLD_SIZE,RENT_OWN_IND,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,'PERSON',PERSON_PRE_NAME_ADJUNCT,PERSON_FIRST_NAME,
      PERSON_MIDDLE_NAME,PERSON_LAST_NAME,PERSON_NAME_SUFFIX,PERSON_TITLE,PERSON_ACADEMIC_TITLE,
      PERSON_PREVIOUS_LAST_NAME,PERSON_INITIALS,KNOWN_AS,PERSON_NAME_PHONETIC,PERSON_FIRST_NAME_PHONETIC,
      PERSON_MIDDLE_NAME_PHONETIC,PERSON_LAST_NAME_PHONETIC,TAX_REFERENCE,JGZZ_FISCAL_CODE,PERSON_IDEN_TYPE,
      PERSON_IDENTIFIER,birthdate,PLACE_OF_BIRTH,deathdate,GENDER,DECLARED_ETHNICITY,MARITAL_STATUS,
      maritaldate,per_income,HEAD_OF_HOUSEHOLD_FLAG,house_income,house_size,
      RENT_OWN_IND,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
     if(CONTACT_FLAG='Y') then
      old_contact_org := 'N';
      i:=1;
      while(i<=org_contact.COUNT) LOOP
       org_contact_rec := org_contact(i);
       old_org_name := org_contact_rec.org_name ;
       orig_sys_ref := org_contact_rec.original_sys_ref;
       if(old_org_name = ORGANIZATION_NAME) then
        old_contact_org := 'Y';
        CNTORG_ORIG_SYSTEM_REFERENCE := orig_sys_ref;
       end if;
        i:=i+1;
     end loop;

      if(old_contact_org ='N') then

       open get_next_ref_id;
       fetch get_next_ref_id into CNTORG_ORIG_SYSTEM_REFERENCE;
       close get_next_ref_id;

       insert into HZ_IMP_PARTIES_INT(batch_id,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,PARTY_TYPE,ORGANIZATION_NAME,CEO_NAME,CEO_TITLE,PRINCIPAL_NAME,
       PRINCIPAL_TITLE,LEGAL_STATUS,CONTROL_YR,EMPLOYEES_TOTAL,HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,
       GSA_INDICATOR_FLAG,JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,
       NEXT_FY_POTENTIAL_REVENUE,YEAR_ESTABLISHED,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,
       LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,INCORP_YEAR,
       PUBLIC_PRIVATE_OWNERSHIP_FLAG,TOTAL_PAYMENTS,DUNS_NUMBER_C,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
       values (batchId,'CSV',CNTORG_ORIG_SYSTEM_REFERENCE,'ORGANIZATION',ORGANIZATION_NAME,CEO_NAME,CEO_TITLE,PRINCIPAL_NAME,
       PRINCIPAL_TITLE,LEGAL_STATUS,CONTROL_YR,EMPLOYEES_TOTAL,HQ_BRANCH_IND,BRANCH_FLAG,OOB_IND,TAX_REFERENCE,
       GSA_INDICATOR_FLAG,JGZZ_FISCAL_CODE,ANALYSIS_FY,FISCAL_YEAREND_MONTH,CURR_FY_POTENTIAL_REVENUE,
       NEXT_FY_POTENTIAL_REVENUE,YEAR_ESTABLISHED,MISSION_STATEMENT,ORGANIZATION_TYPE,BUSINESS_SCOPE,KNOWN_AS,
       LOCAL_BUS_IDEN_TYPE,LOCAL_BUS_IDENTIFIER,PREF_FUNCTIONAL_CURRENCY,REGISTRATION_TYPE,PARENT_SUB_IND,INCORP_YEAR,
       PUBLIC_PRIVATE_OWNERSHIP_FLAG,TOTAL_PAYMENTS,DUNS_NUMBER_C,SYSDATE,FND_GLOBAL.user_id,SYSDATE,
       FND_GLOBAL.user_id,FND_GLOBAL.login_id);

        org_contact_rec.org_name := ORGANIZATION_NAME ;
        org_contact_rec.original_sys_ref := CNTORG_ORIG_SYSTEM_REFERENCE;
        org_contact(i) := org_contact_rec;

       end if;

      open get_next_ref_id;
        fetch get_next_ref_id into CNT_ORIG_SYSTEM_REFERENCE;
       close get_next_ref_id;

      insert into HZ_IMP_CONTACTS_INT(
       BATCH_ID,CONTACT_ORIG_SYSTEM,CONTACT_ORIG_SYSTEM_REFERENCE,SUB_ORIG_SYSTEM,SUB_ORIG_SYSTEM_REFERENCE,
       OBJ_ORIG_SYSTEM,OBJ_ORIG_SYSTEM_REFERENCE ,DEPARTMENT_CODE,DEPARTMENT,TITLE,JOB_TITLE,RELATIONSHIP_TYPE,RELATIONSHIP_CODE,
       START_DATE,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',CNT_ORIG_SYSTEM_REFERENCE,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,
             'CSV',CNTORG_ORIG_SYSTEM_REFERENCE,DEPARTMENT_CODE,DEPARTMENT,TITLE,JOB_TITLE,'CONTACT','CONTACT_OF',
       SYSDATE,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id) ;
     end if;
    end if;

   if(ADDRESS_FLAG ='Y') then

    open get_next_ref_id;
      fetch get_next_ref_id into SITE_ORIG_SYSTEM_REFERENCE;
    close get_next_ref_id;

    insert into HZ_IMP_ADDRESSES_INT(batch_id,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,SITE_ORIG_SYSTEM,
    SITE_ORIG_SYSTEM_REFERENCE,COUNTRY,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,
    POSTAL_CODE,STATE,PROVINCE,COUNTY,ADDRESS_LINES_PHONETIC,LOCATION_DIRECTIONS,DESCRIPTION,SALES_TAX_GEOCODE,
    PRIMARY_FLAG,PARTY_SITE_NAME,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
    values(batchId,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,'CSV',SITE_ORIG_SYSTEM_REFERENCE,COUNTRY,ADDRESS1,ADDRESS2,
    ADDRESS3,ADDRESS4,CITY,POSTAL_CODE,STATE,PROVINCE,COUNTY,ADDRESS_LINES_PHONETIC,LOCATION_DIRECTIONS,
    DESCRIPTION,SALES_TAX_GEOCODE,PRIMARY_FLAG,PARTY_SITE_NAME,SYSDATE,FND_GLOBAL.user_id,SYSDATE,
    FND_GLOBAL.user_id,FND_GLOBAL.login_id);
   end if;

   if(CONTACT_POINTS_FLAG ='Y') then
       /* Bug 3854824: If contact_point_type is not passed, based on the
       contact point passed, set the contact point type */
       /* Bug 5371056 : insert one row to hz_imp_contactpts_int for
  |                     each contact point */
    if (PHONE_NUMBER is not null OR RAW_PHONE_NUMBER is not null) then
      CONTACT_POINT_TYPE := 'PHONE';
      if (PHONE_LINE_TYPE is null) then
        PHONE_LINE_TYPE := 'GEN';
      end if;
      open get_next_ref_id;
        fetch get_next_ref_id into CP_ORIG_SYSTEM_REFERENCE;
      close get_next_ref_id;

      insert into HZ_IMP_CONTACTPTS_INT(
      batch_id,CP_ORIG_SYSTEM,CP_ORIG_SYSTEM_REFERENCE,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,
      PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CREATION_DATE,CREATED_BY,
      LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',CP_ORIG_SYSTEM_REFERENCE,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,
      PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,
      RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
    end if;

    if (EMAIL_ADDRESS is not null) then
      CONTACT_POINT_TYPE := 'EMAIL';
      open get_next_ref_id;
        fetch get_next_ref_id into CP_ORIG_SYSTEM_REFERENCE;
      close get_next_ref_id;

      insert into HZ_IMP_CONTACTPTS_INT(
      batch_id,CP_ORIG_SYSTEM,CP_ORIG_SYSTEM_REFERENCE,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,
      PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CREATION_DATE,CREATED_BY,
      LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',CP_ORIG_SYSTEM_REFERENCE,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,
      PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,
      RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
    end if;

    if (URL is not null) then
      CONTACT_POINT_TYPE := 'WEB';
      open get_next_ref_id;
        fetch get_next_ref_id into CP_ORIG_SYSTEM_REFERENCE;
      close get_next_ref_id;

      insert into HZ_IMP_CONTACTPTS_INT(
      batch_id,CP_ORIG_SYSTEM,CP_ORIG_SYSTEM_REFERENCE,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,
      PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CREATION_DATE,CREATED_BY,
      LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',CP_ORIG_SYSTEM_REFERENCE,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,
      PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,
      RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
    end if;

    if (TELEX_NUMBER is not null) then
      CONTACT_POINT_TYPE := 'TLX';
      open get_next_ref_id;
        fetch get_next_ref_id into CP_ORIG_SYSTEM_REFERENCE;
      close get_next_ref_id;

      insert into HZ_IMP_CONTACTPTS_INT(
      batch_id,CP_ORIG_SYSTEM,CP_ORIG_SYSTEM_REFERENCE,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,
      PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,CREATION_DATE,CREATED_BY,
      LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
      values(batchId,'CSV',CP_ORIG_SYSTEM_REFERENCE,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,CONTACT_POINT_TYPE,EMAIL_FORMAT,EMAIL_ADDRESS,
      PHONE_AREA_CODE,PHONE_COUNTRY_CODE,PHONE_NUMBER,PHONE_EXTENSION,PHONE_LINE_TYPE,TELEX_NUMBER,WEB_TYPE,URL,
      RAW_PHONE_NUMBER,CONTACT_POINT_PURPOSE,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
    end if;
   end if;

   if(CLASSIFICATION_FLAG ='Y') then
     insert into HZ_IMP_CLASSIFICS_INT(BATCH_ID,PARTY_ORIG_SYSTEM,PARTY_ORIG_SYSTEM_REFERENCE,CLASS_CATEGORY,CLASS_CODE,
     START_DATE_ACTIVE, CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
     values(batchId,'CSV',PARTY_ORIG_SYSTEM_REFERENCE,CLASS_CATEGORY,CLASS_CODE,SYSDATE,SYSDATE,FND_GLOBAL.user_id,
            SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
   end if;
   --dbms_output.put_line('before the update to rec status to P');
   execute immediate 'delete from imc_csv_interface_fields where load_id ='||loadId||' and batch_id = '||batchId||
                       ' and party_rec_id = '||PARTY_REC_ID;
   end if;
  end loop;
 close get_details;
 -- Activating the created batch

 EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_ERROR;
   execute immediate 'update hz_imp_batch_summary set csv_status=''ERROR'' where load_type=''CSV'' and batch_id = '||batchId;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    execute immediate 'update hz_imp_batch_summary set csv_status=''ERROR'' where load_type=''CSV'' and batch_id = '||batchId;


  WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'IMC_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
            RAISE FND_API.G_EXC_ERROR;
       execute immediate 'update hz_imp_batch_summary set csv_status=''ERROR'' where load_type=''CSV'' and batch_id = '||batchId;

 END;
END IMC_CSV_LOAD;

/
