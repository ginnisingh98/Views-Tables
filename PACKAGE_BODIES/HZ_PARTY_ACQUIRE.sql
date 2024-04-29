--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_ACQUIRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_ACQUIRE" AS
/* $Header: ARHDQAQB.pls 120.7.12010000.2 2010/03/29 11:19:05 amstephe ship $ */

TYPE vTable IS TABLE OF VARCHAR2(255) index by binary_integer;

g_party_custom_attrs vTable;
g_party_custom_procs vTable;
g_party_custom_valid vTable;

g_ps_custom_attrs vTable;
g_ps_custom_procs vTable;
g_ps_custom_valid vTable;

g_cpt_custom_attrs vTable;
g_cpt_custom_procs vTable;
g_cpt_custom_valid vTable;

g_cont_custom_attrs vTable;
g_cont_custom_procs vTable;
g_cont_custom_valid vTable;

g_party_custom_queried VARCHAR2(1) := 'N';
g_ps_custom_queried VARCHAR2(1) := 'N';
g_cpt_custom_queried VARCHAR2(1) := 'N';
g_cont_custom_queried VARCHAR2(1) := 'N';

FUNCTION filter_ph_num(
  p_inval	IN	VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  IF p_inval IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN translate(
    p_inval,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ',
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ');
END;

FUNCTION get_party_rec (
  p_party_id      IN      NUMBER,
 p_party_type      IN      VARCHAR2
  ) RETURN HZ_PARTY_SEARCH.party_search_rec_type IS
CURSOR org IS
  SELECT o.ANALYSIS_FY
         ,o.AVG_HIGH_CREDIT
         ,o.BEST_TIME_CONTACT_BEGIN
         ,o.BEST_TIME_CONTACT_END
         ,o.BRANCH_FLAG
         ,o.BUSINESS_SCOPE
         ,o.CEO_NAME
         ,o.CEO_TITLE
         ,o.CONG_DIST_CODE
         ,o.CONTENT_SOURCE_NUMBER
         ,o.CONTENT_SOURCE_TYPE
         ,o.CONTROL_YR
         ,o.CORPORATION_CLASS
         ,o.CREDIT_SCORE
         ,o.CREDIT_SCORE_AGE
         ,o.CREDIT_SCORE_CLASS
         ,o.CREDIT_SCORE_COMMENTARY
         ,o.CREDIT_SCORE_COMMENTARY10
         ,o.CREDIT_SCORE_COMMENTARY2
         ,o.CREDIT_SCORE_COMMENTARY3
         ,o.CREDIT_SCORE_COMMENTARY4
         ,o.CREDIT_SCORE_COMMENTARY5
         ,o.CREDIT_SCORE_COMMENTARY6
         ,o.CREDIT_SCORE_COMMENTARY7
         ,o.CREDIT_SCORE_COMMENTARY8
         ,o.CREDIT_SCORE_COMMENTARY9
         ,o.CREDIT_SCORE_DATE
         ,o.CREDIT_SCORE_INCD_DEFAULT
         ,o.CREDIT_SCORE_NATL_PERCENTILE
         ,o.CURR_FY_POTENTIAL_REVENUE
         ,o.DB_RATING
         ,o.DEBARMENTS_COUNT
         ,o.DEBARMENTS_DATE
         ,o.DEBARMENT_IND
         ,o.DISADV_8A_IND
         ,o.DUNS_NUMBER_C
         ,o.EMPLOYEES_TOTAL
         ,o.EMP_AT_PRIMARY_ADR
         ,o.EMP_AT_PRIMARY_ADR_EST_IND
         ,o.EMP_AT_PRIMARY_ADR_MIN_IND
         ,o.EMP_AT_PRIMARY_ADR_TEXT
         ,o.ENQUIRY_DUNS
         ,o.EXPORT_IND
         ,o.FAILURE_SCORE
         ,o.FAILURE_SCORE_AGE
         ,o.FAILURE_SCORE_CLASS
         ,o.FAILURE_SCORE_COMMENTARY
         ,o.FAILURE_SCORE_COMMENTARY10
         ,o.FAILURE_SCORE_COMMENTARY2
         ,o.FAILURE_SCORE_COMMENTARY3
         ,o.FAILURE_SCORE_COMMENTARY4
         ,o.FAILURE_SCORE_COMMENTARY5
         ,o.FAILURE_SCORE_COMMENTARY6
         ,o.FAILURE_SCORE_COMMENTARY7
         ,o.FAILURE_SCORE_COMMENTARY8
         ,o.FAILURE_SCORE_COMMENTARY9
         ,o.FAILURE_SCORE_DATE
         ,o.FAILURE_SCORE_INCD_DEFAULT
         ,o.FAILURE_SCORE_OVERRIDE_CODE
         ,o.FISCAL_YEAREND_MONTH
         ,o.GLOBAL_FAILURE_SCORE
         ,o.GSA_INDICATOR_FLAG
         ,o.HIGH_CREDIT
         ,o.HQ_BRANCH_IND
         ,o.IMPORT_IND
         ,o.INCORP_YEAR
         ,o.INTERNAL_FLAG
         ,o.JGZZ_FISCAL_CODE
         ,o.LABOR_SURPLUS_IND
         ,o.LEGAL_STATUS
         ,o.LINE_OF_BUSINESS
         ,o.LOCAL_ACTIVITY_CODE
         ,o.LOCAL_ACTIVITY_CODE_TYPE
         ,o.LOCAL_BUS_IDENTIFIER
         ,o.LOCAL_BUS_IDEN_TYPE
         ,o.MAXIMUM_CREDIT_CURRENCY_CODE
         ,o.MAXIMUM_CREDIT_RECOMMENDATION
         ,o.MINORITY_OWNED_IND
         ,o.MINORITY_OWNED_TYPE
         ,o.NEXT_FY_POTENTIAL_REVENUE
         ,o.OOB_IND
         ,o.ORGANIZATION_NAME
         ,o.ORGANIZATION_NAME_PHONETIC
         ,o.ORGANIZATION_TYPE
         ,o.PARENT_SUB_IND
         ,o.PAYDEX_NORM
         ,o.PAYDEX_SCORE
         ,o.PAYDEX_THREE_MONTHS_AGO
         ,o.PREF_FUNCTIONAL_CURRENCY
         ,o.PRINCIPAL_NAME
         ,o.PRINCIPAL_TITLE
         ,o.PUBLIC_PRIVATE_OWNERSHIP_FLAG
         ,o.REGISTRATION_TYPE
         ,o.RENT_OWN_IND
         ,o.SIC_CODE
         ,o.SIC_CODE_TYPE
         ,o.SMALL_BUS_IND
         ,o.TAX_NAME
         ,o.TAX_REFERENCE
         ,o.TOTAL_EMPLOYEES_TEXT
         ,o.TOTAL_EMP_EST_IND
         ,o.TOTAL_EMP_MIN_IND
         ,o.TOTAL_EMPLOYEES_IND
         ,o.TOTAL_PAYMENTS
         ,o.WOMAN_OWNED_IND
         ,o.YEAR_ESTABLISHED
         ,p.CATEGORY_CODE
         ,p.COMPETITOR_FLAG
         ,p.DO_NOT_MAIL_FLAG
         ,p.GROUP_TYPE
         ,p.LANGUAGE_NAME
         ,p.PARTY_NAME
         ,p.PARTY_NUMBER
         ,p.PARTY_TYPE
         ,p.REFERENCE_USE_FLAG
         ,p.SALUTATION
         ,nvl(p.STATUS,'A')
         ,p.THIRD_PARTY_FLAG
         ,p.VALIDATED_FLAG
         ,o.EFFECTIVE_START_DATE
         ,o.EFFECTIVE_END_DATE
         ,p.KNOWN_AS
         ,p.KNOWN_AS2
         ,p.KNOWN_AS3
         ,p.KNOWN_AS4
         ,p.KNOWN_AS5
  FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES o
  WHERE p.party_id = p_party_id
  AND o.effective_end_date is NULL
  AND p.party_id = o.party_id;

CURSOR pers IS
  SELECT p.CATEGORY_CODE
         ,p.COMPETITOR_FLAG
         ,p.DO_NOT_MAIL_FLAG
         ,p.GROUP_TYPE
         ,p.LANGUAGE_NAME
         ,p.PARTY_NAME
         ,p.PARTY_NUMBER
         ,p.PARTY_TYPE
         ,p.REFERENCE_USE_FLAG
         ,p.SALUTATION
         ,nvl(p.STATUS,'A')
         ,p.THIRD_PARTY_FLAG
         ,p.VALIDATED_FLAG
	 ,pe.DATE_OF_BIRTH
	 ,pe.DATE_OF_DEATH
	 ,pe.DECLARED_ETHNICITY
	 ,pe.GENDER
	 ,pe.HEAD_OF_HOUSEHOLD_FLAG
	 ,pe.HOUSEHOLD_INCOME
	 ,pe.HOUSEHOLD_SIZE
	 ,pe.LAST_KNOWN_GPS
	 ,pe.MARITAL_STATUS
	 ,pe.MARITAL_STATUS_EFFECTIVE_DATE
	 ,pe.MIDDLE_NAME_PHONETIC
	 ,pe.PERSONAL_INCOME
	 ,pe.PERSON_ACADEMIC_TITLE
	 ,pe.PERSON_FIRST_NAME
	 ,pe.PERSON_FIRST_NAME_PHONETIC
	 ,pe.PERSON_IDENTIFIER
	 ,pe.PERSON_IDEN_TYPE
	 ,pe.PERSON_INITIALS
	 ,pe.PERSON_LAST_NAME
	 ,pe.PERSON_LAST_NAME_PHONETIC
	 ,pe.PERSON_MIDDLE_NAME
	 ,pe.PERSON_NAME
	 ,pe.PERSON_NAME_PHONETIC
	 ,pe.PERSON_NAME_SUFFIX
	 ,pe.PERSON_PREVIOUS_LAST_NAME
	 ,pe.PERSON_PRE_NAME_ADJUNCT
	 ,pe.PERSON_TITLE
	 ,pe.PLACE_OF_BIRTH
         ,pe.BEST_TIME_CONTACT_BEGIN
	 ,pe.BEST_TIME_CONTACT_END
	 ,pe.CONTENT_SOURCE_NUMBER
	 ,pe.CONTENT_SOURCE_TYPE
	 ,pe.INTERNAL_FLAG
	 ,pe.JGZZ_FISCAL_CODE
         ,pe.RENT_OWN_IND
	 ,pe.TAX_NAME
	 ,pe.TAX_REFERENCE
         ,pe.EFFECTIVE_START_DATE
         ,pe.EFFECTIVE_END_DATE
         ,p.KNOWN_AS
         ,p.KNOWN_AS2
         ,p.KNOWN_AS3
         ,p.KNOWN_AS4
         ,p.KNOWN_AS5
  FROM HZ_PARTIES p, HZ_PERSON_PROFILES pe
  WHERE p.party_id = p_party_id
  AND pe.effective_end_date is NULL
  AND p.party_id = pe.party_id;
CURSOR custom_attribs IS
  SELECT attribute_name, custom_attribute_procedure
  FROM HZ_TRANS_ATTRIBUTES_VL
  WHERE entity_name='PARTY'
  AND (source_table = 'CUSTOM'
  OR custom_attribute_procedure is not null);

l_attr_name VARCHAR2(255);

l_proc_name VARCHAR2(255);
plsql_block VARCHAR2(32000);
l_val VARCHAR2(2000);

l_return_status         VARCHAR2(1);

l_party_search_rec HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
NUM NUMBER;
c NUMBER;

l_sql VARCHAR2(255);

BEGIN
  l_party_search_rec.party_type := p_party_type;
  IF p_party_type = 'ORGANIZATION' THEN
    OPEN org;
    FETCH org INTO l_party_search_rec.ANALYSIS_FY
                   ,l_party_search_rec.AVG_HIGH_CREDIT
                   ,l_party_search_rec.BEST_TIME_CONTACT_BEGIN
                   ,l_party_search_rec.BEST_TIME_CONTACT_END
                   ,l_party_search_rec.BRANCH_FLAG
                   ,l_party_search_rec.BUSINESS_SCOPE
                   ,l_party_search_rec.CEO_NAME
                   ,l_party_search_rec.CEO_TITLE
                   ,l_party_search_rec.CONG_DIST_CODE
                   ,l_party_search_rec.CONTENT_SOURCE_NUMBER
                   ,l_party_search_rec.CONTENT_SOURCE_TYPE
                   ,l_party_search_rec.CONTROL_YR
                   ,l_party_search_rec.CORPORATION_CLASS
                   ,l_party_search_rec.CREDIT_SCORE
                   ,l_party_search_rec.CREDIT_SCORE_AGE
                   ,l_party_search_rec.CREDIT_SCORE_CLASS
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY10
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY2
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY3
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY4
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY5
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY6
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY7
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY8
                   ,l_party_search_rec.CREDIT_SCORE_COMMENTARY9
                   ,l_party_search_rec.CREDIT_SCORE_DATE
                   ,l_party_search_rec.CREDIT_SCORE_INCD_DEFAULT
                   ,l_party_search_rec.CREDIT_SCORE_NATL_PERCENTILE
                   ,l_party_search_rec.CURR_FY_POTENTIAL_REVENUE
                   ,l_party_search_rec.DB_RATING
                   ,l_party_search_rec.DEBARMENTS_COUNT
                   ,l_party_search_rec.DEBARMENTS_DATE
                   ,l_party_search_rec.DEBARMENT_IND
                   ,l_party_search_rec.DISADV_8A_IND
                   ,l_party_search_rec.DUNS_NUMBER_C
                   ,l_party_search_rec.EMPLOYEES_TOTAL
                   ,l_party_search_rec.EMP_AT_PRIMARY_ADR
                   ,l_party_search_rec.EMP_AT_PRIMARY_ADR_EST_IND
                   ,l_party_search_rec.EMP_AT_PRIMARY_ADR_MIN_IND
                   ,l_party_search_rec.EMP_AT_PRIMARY_ADR_TEXT
                   ,l_party_search_rec.ENQUIRY_DUNS
                   ,l_party_search_rec.EXPORT_IND
                   ,l_party_search_rec.FAILURE_SCORE
                   ,l_party_search_rec.FAILURE_SCORE_AGE
                   ,l_party_search_rec.FAILURE_SCORE_CLASS
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY10
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY2
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY3
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY4
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY5
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY6
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY7
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY8
                   ,l_party_search_rec.FAILURE_SCORE_COMMENTARY9
                   ,l_party_search_rec.FAILURE_SCORE_DATE
                   ,l_party_search_rec.FAILURE_SCORE_INCD_DEFAULT
                   ,l_party_search_rec.FAILURE_SCORE_OVERRIDE_CODE
                   ,l_party_search_rec.FISCAL_YEAREND_MONTH
                   ,l_party_search_rec.GLOBAL_FAILURE_SCORE
                   ,l_party_search_rec.GSA_INDICATOR_FLAG
                   ,l_party_search_rec.HIGH_CREDIT
                   ,l_party_search_rec.HQ_BRANCH_IND
                   ,l_party_search_rec.IMPORT_IND
                   ,l_party_search_rec.INCORP_YEAR
                   ,l_party_search_rec.INTERNAL_FLAG
                   ,l_party_search_rec.JGZZ_FISCAL_CODE
                   ,l_party_search_rec.LABOR_SURPLUS_IND
                   ,l_party_search_rec.LEGAL_STATUS
                   ,l_party_search_rec.LINE_OF_BUSINESS
                   ,l_party_search_rec.LOCAL_ACTIVITY_CODE
                   ,l_party_search_rec.LOCAL_ACTIVITY_CODE_TYPE
                   ,l_party_search_rec.LOCAL_BUS_IDENTIFIER
                   ,l_party_search_rec.LOCAL_BUS_IDEN_TYPE
                   ,l_party_search_rec.MAXIMUM_CREDIT_CURRENCY_CODE
                   ,l_party_search_rec.MAXIMUM_CREDIT_RECOMMENDATION
                   ,l_party_search_rec.MINORITY_OWNED_IND
                   ,l_party_search_rec.MINORITY_OWNED_TYPE
                   ,l_party_search_rec.NEXT_FY_POTENTIAL_REVENUE
                   ,l_party_search_rec.OOB_IND
                   ,l_party_search_rec.ORGANIZATION_NAME
                   ,l_party_search_rec.ORGANIZATION_NAME_PHONETIC
                   ,l_party_search_rec.ORGANIZATION_TYPE
                   ,l_party_search_rec.PARENT_SUB_IND
                   ,l_party_search_rec.PAYDEX_NORM
                   ,l_party_search_rec.PAYDEX_SCORE
                   ,l_party_search_rec.PAYDEX_THREE_MONTHS_AGO
                   ,l_party_search_rec.PREF_FUNCTIONAL_CURRENCY
                   ,l_party_search_rec.PRINCIPAL_NAME
                   ,l_party_search_rec.PRINCIPAL_TITLE
                   ,l_party_search_rec.PUBLIC_PRIVATE_OWNERSHIP_FLAG
                   ,l_party_search_rec.REGISTRATION_TYPE
                   ,l_party_search_rec.RENT_OWN_IND
                   ,l_party_search_rec.SIC_CODE
                   ,l_party_search_rec.SIC_CODE_TYPE
                   ,l_party_search_rec.SMALL_BUS_IND
                   ,l_party_search_rec.TAX_NAME
                   ,l_party_search_rec.TAX_REFERENCE
                   ,l_party_search_rec.TOTAL_EMPLOYEES_TEXT
                   ,l_party_search_rec.TOTAL_EMP_EST_IND
                   ,l_party_search_rec.TOTAL_EMP_MIN_IND
                   ,l_party_search_rec.TOTAL_EMPLOYEES_IND
                   ,l_party_search_rec.TOTAL_PAYMENTS
                   ,l_party_search_rec.WOMAN_OWNED_IND
                   ,l_party_search_rec.YEAR_ESTABLISHED
                   ,l_party_search_rec.CATEGORY_CODE
                   ,l_party_search_rec.COMPETITOR_FLAG
                   ,l_party_search_rec.DO_NOT_MAIL_FLAG
                   ,l_party_search_rec.GROUP_TYPE
                   ,l_party_search_rec.LANGUAGE_NAME
                   ,l_party_search_rec.PARTY_NAME
                   ,l_party_search_rec.PARTY_NUMBER
                   ,l_party_search_rec.PARTY_TYPE
                   ,l_party_search_rec.REFERENCE_USE_FLAG
                   ,l_party_search_rec.SALUTATION
                   ,l_party_search_rec.STATUS
                   ,l_party_search_rec.THIRD_PARTY_FLAG
                   ,l_party_search_rec.VALIDATED_FLAG
                   ,l_party_search_rec.EFFECTIVE_START_DATE
                   ,l_party_search_rec.EFFECTIVE_END_DATE
                   ,l_party_search_rec.KNOWN_AS
                   ,l_party_search_rec.KNOWN_AS2
                   ,l_party_search_rec.KNOWN_AS3
                   ,l_party_search_rec.KNOWN_AS4
                   ,l_party_search_rec.KNOWN_AS5;
    CLOSE org;
  ELSIF p_party_type = 'PERSON' THEN
    OPEN pers;
    FETCH pers INTO l_party_search_rec.CATEGORY_CODE
                   ,l_party_search_rec.COMPETITOR_FLAG
                   ,l_party_search_rec.DO_NOT_MAIL_FLAG
                   ,l_party_search_rec.GROUP_TYPE
                   ,l_party_search_rec.LANGUAGE_NAME
                   ,l_party_search_rec.PARTY_NAME
                   ,l_party_search_rec.PARTY_NUMBER
                   ,l_party_search_rec.PARTY_TYPE
                   ,l_party_search_rec.REFERENCE_USE_FLAG
                   ,l_party_search_rec.SALUTATION
                   ,l_party_search_rec.STATUS
                   ,l_party_search_rec.THIRD_PARTY_FLAG
                   ,l_party_search_rec.VALIDATED_FLAG
                   ,l_party_search_rec.DATE_OF_BIRTH
                   ,l_party_search_rec.DATE_OF_DEATH
                   ,l_party_search_rec.DECLARED_ETHNICITY
                   ,l_party_search_rec.GENDER
                   ,l_party_search_rec.HEAD_OF_HOUSEHOLD_FLAG
                   ,l_party_search_rec.HOUSEHOLD_INCOME
                   ,l_party_search_rec.HOUSEHOLD_SIZE
                   ,l_party_search_rec.LAST_KNOWN_GPS
                   ,l_party_search_rec.MARITAL_STATUS
                   ,l_party_search_rec.MARITAL_STATUS_EFFECTIVE_DATE
                   ,l_party_search_rec.MIDDLE_NAME_PHONETIC
                   ,l_party_search_rec.PERSONAL_INCOME
                   ,l_party_search_rec.PERSON_ACADEMIC_TITLE
                   ,l_party_search_rec.PERSON_FIRST_NAME
                   ,l_party_search_rec.PERSON_FIRST_NAME_PHONETIC
                   ,l_party_search_rec.PERSON_IDENTIFIER
                   ,l_party_search_rec.PERSON_IDEN_TYPE
                   ,l_party_search_rec.PERSON_INITIALS
                   ,l_party_search_rec.PERSON_LAST_NAME
                   ,l_party_search_rec.PERSON_LAST_NAME_PHONETIC
                   ,l_party_search_rec.PERSON_MIDDLE_NAME
                   ,l_party_search_rec.PERSON_NAME
                   ,l_party_search_rec.PERSON_NAME_PHONETIC
                   ,l_party_search_rec.PERSON_NAME_SUFFIX
                   ,l_party_search_rec.PERSON_PREVIOUS_LAST_NAME
                   ,l_party_search_rec.PERSON_PRE_NAME_ADJUNCT
                   ,l_party_search_rec.PERSON_TITLE
                   ,l_party_search_rec.PLACE_OF_BIRTH
                   ,l_party_search_rec.BEST_TIME_CONTACT_BEGIN
                   ,l_party_search_rec.BEST_TIME_CONTACT_END
                   ,l_party_search_rec.CONTENT_SOURCE_NUMBER
                   ,l_party_search_rec.CONTENT_SOURCE_TYPE
                   ,l_party_search_rec.INTERNAL_FLAG
                   ,l_party_search_rec.JGZZ_FISCAL_CODE
                   ,l_party_search_rec.RENT_OWN_IND
                   ,l_party_search_rec.TAX_NAME
                   ,l_party_search_rec.TAX_REFERENCE
                   ,l_party_search_rec.EFFECTIVE_START_DATE
                   ,l_party_search_rec.EFFECTIVE_END_DATE
                   ,l_party_search_rec.KNOWN_AS
                   ,l_party_search_rec.KNOWN_AS2
                   ,l_party_search_rec.KNOWN_AS3
                   ,l_party_search_rec.KNOWN_AS4
                   ,l_party_search_rec.KNOWN_AS5;
    CLOSE pers;
  END IF;

  IF g_party_custom_queried = 'N' THEN
    g_party_custom_queried := 'Y';

    NUM := 1;
    OPEN custom_attribs;
    LOOP

      FETCH custom_attribs INTO g_party_custom_attrs(NUM), g_party_custom_procs(NUM);
      EXIT WHEN custom_attribs%NOTFOUND;

      c := dbms_sql.open_cursor;
      l_sql := 'select '|| g_party_custom_procs(NUM) || '(:record_id, :entity_name, :attribute_name) from dual';
      BEGIN
        dbms_sql.parse(c,l_sql,2);
        g_party_custom_valid(NUM) := 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          g_party_custom_valid(NUM) := 'N';
          FND_FILE.put_line(fnd_file.log,'Error parsing custom attribute procedure ' || g_party_custom_procs(NUM) ||
              ' for attribute PARTY.'||g_party_custom_attrs(NUM));
      END;
      dbms_sql.close_cursor(c);

      NUM := NUM+1;
    END LOOP;
    CLOSE custom_attribs;
  END IF;

  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..g_party_custom_procs.COUNT LOOP
    l_proc_name := g_party_custom_procs(I);
    l_attr_name := g_party_custom_attrs(I);

    IF g_party_custom_valid(I) = 'Y' THEN
      BEGIN

        IF l_proc_name = 'HZ_PARTY_ACQUIRE.get_known_as' THEN
          l_val := HZ_PARTY_ACQUIRE.get_known_as(p_party_id,'PARTY', l_attr_name, 'STAGE');
        ELSIF l_proc_name = 'HZ_PARTY_ACQUIRE.get_account_info' THEN
          l_val := HZ_PARTY_ACQUIRE.get_account_info(p_party_id,'PARTY', l_attr_name, 'STAGE');
        ELSE
          -- Create a dynamic SQL block to execute the merge procedure
          plsql_block := 'BEGIN '||
                       ' :retval := '||l_proc_name||'(:record_id, :entity_name, :attribute_name);'||
                       'END;';

          -- Execute the dynamic PLSQL block
          EXECUTE IMMEDIATE plsql_block USING
              OUT l_val, p_party_id, 'PARTY', l_attr_name;
        END IF;

        IF l_attr_name = 'ALL_ACCOUNT_NAMES' THEN
          l_party_search_rec.ALL_ACCOUNT_NAMES := l_val;
        ELSIF l_attr_name = 'ALL_ACCOUNT_NUMBERS' THEN
          l_party_search_rec.ALL_ACCOUNT_NUMBERS := l_val;
        ELSIF l_attr_name = 'PARTY_ALL_NAMES' THEN
          l_party_search_rec.PARTY_ALL_NAMES := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE1' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE1 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE2' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE2 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE3' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE3 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE4' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE4 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE5' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE5 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE6' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE6 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE7' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE7 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE8' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE8 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE9' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE9 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE10' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE10:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE11' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE11 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE12' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE12 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE13' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE13 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE14' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE14 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE15' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE15 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE16' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE16 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE17' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE17 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE18' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE18 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE19' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE19 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE20' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE20:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE21' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE21 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE22' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE22 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE23' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE23 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE24' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE24 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE25' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE25 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE26' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE26 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE27' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE27 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE28' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE28 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE29' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE29 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE30' THEN
          l_party_search_rec.CUSTOM_ATTRIBUTE30:= l_val;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.put_line(FND_FILE.log,'Error executing custom procedure for attribute ' || l_attr_name || ' (Party ID: ' || p_party_id || '). Continuing ... ');
          FND_FILE.put_line(FND_FILE.log,SQLERRM);
/*
          FND_MESSAGE.SET_NAME('AR', 'HZ_CUSTOM_PROC_ERROR');
          FND_MESSAGE.SET_TOKEN('ENTITY' ,'PARTY');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attr_name);
          FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
*/
      END;
    END IF;
  END LOOP;

  RETURN l_party_search_rec;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'get_party_rec');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


FUNCTION get_party_site_rec (
        p_party_site_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.party_site_search_rec_type IS

  CURSOR c_party_site IS
         SELECT l.ADDRESS1
         ,l.ADDRESS2
         ,l.ADDRESS3
         ,l.ADDRESS4
         ,l.ADDRESS_EFFECTIVE_DATE
         ,l.ADDRESS_EXPIRATION_DATE
         ,l.ADDRESS_LINES_PHONETIC
         ,l.CITY
         ,l.CLLI_CODE
         ,l.CONTENT_SOURCE_TYPE
         ,l.COUNTRY
         ,l.COUNTY
         ,l.FLOOR
         ,l.HOUSE_NUMBER
         ,l.LANGUAGE
         ,l.POSITION
         ,l.POSTAL_CODE
         ,l.POSTAL_PLUS4_CODE
         ,l.PO_BOX_NUMBER
         ,l.PROVINCE
         ,l.SALES_TAX_GEOCODE
         ,l.SALES_TAX_INSIDE_CITY_LIMITS
         ,l.STATE
         ,l.STREET
         ,l.STREET_NUMBER
         ,l.STREET_SUFFIX
         ,l.SUITE
         ,l.TRAILING_DIRECTORY_CODE
         ,l.VALIDATED_FLAG
         ,ps.IDENTIFYING_ADDRESS_FLAG
         ,ps.MAILSTOP
         ,ps.PARTY_SITE_NAME
         ,ps.PARTY_SITE_NUMBER
    FROM HZ_PARTY_SITES ps, HZ_LOCATIONS l
    WHERE ps.party_site_id = p_party_site_id
    AND   ps.location_id = l.location_id
    AND (ps.status is null OR ps.status = 'A' or ps.status = 'I');

CURSOR custom_attribs IS
  SELECT attribute_name, custom_attribute_procedure
  FROM HZ_TRANS_ATTRIBUTES_VL
  WHERE entity_name='PARTY_SITES'
  AND (source_table = 'CUSTOM'
  OR custom_attribute_procedure is not null);

l_attr_name VARCHAR2(255);
l_proc_name VARCHAR2(255);
plsql_block VARCHAR2(32000);
l_val VARCHAR2(2000);

l_party_site_search_rec HZ_PARTY_SEARCH.PARTY_SITE_SEARCH_REC_TYPE;
l_return_status         VARCHAR2(1);

NUM NUMBER;
c NUMBER;

l_sql VARCHAR2(255);

BEGIN
  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  OPEN c_party_site;
  FETCH c_party_site INTO l_party_site_search_rec.ADDRESS1
                ,l_party_site_search_rec.ADDRESS2
                ,l_party_site_search_rec.ADDRESS3
                ,l_party_site_search_rec.ADDRESS4
                ,l_party_site_search_rec.ADDRESS_EFFECTIVE_DATE
                ,l_party_site_search_rec.ADDRESS_EXPIRATION_DATE
                ,l_party_site_search_rec.ADDRESS_LINES_PHONETIC
                ,l_party_site_search_rec.CITY
                ,l_party_site_search_rec.CLLI_CODE
                ,l_party_site_search_rec.CONTENT_SOURCE_TYPE
                ,l_party_site_search_rec.COUNTRY
                ,l_party_site_search_rec.COUNTY
                ,l_party_site_search_rec.FLOOR
                ,l_party_site_search_rec.HOUSE_NUMBER
                ,l_party_site_search_rec.LANGUAGE
                ,l_party_site_search_rec.POSITION
                ,l_party_site_search_rec.POSTAL_CODE
                ,l_party_site_search_rec.POSTAL_PLUS4_CODE
                ,l_party_site_search_rec.PO_BOX_NUMBER
                ,l_party_site_search_rec.PROVINCE
                ,l_party_site_search_rec.SALES_TAX_GEOCODE
                ,l_party_site_search_rec.SALES_TAX_INSIDE_CITY_LIMITS
                ,l_party_site_search_rec.STATE
                ,l_party_site_search_rec.STREET
                ,l_party_site_search_rec.STREET_NUMBER
                ,l_party_site_search_rec.STREET_SUFFIX
                ,l_party_site_search_rec.SUITE
                ,l_party_site_search_rec.TRAILING_DIRECTORY_CODE
                ,l_party_site_search_rec.VALIDATED_FLAG
                ,l_party_site_search_rec.IDENTIFYING_ADDRESS_FLAG
                ,l_party_site_search_rec.MAILSTOP
                ,l_party_site_search_rec.PARTY_SITE_NAME
                ,l_party_site_search_rec.PARTY_SITE_NUMBER;

  CLOSE c_party_site;


  IF g_ps_custom_queried = 'N' THEN
    g_ps_custom_queried := 'Y';

    NUM := 1;
    OPEN custom_attribs;
    LOOP

      FETCH custom_attribs INTO g_ps_custom_attrs(NUM), g_ps_custom_procs(NUM);
      EXIT WHEN custom_attribs%NOTFOUND;

      c := dbms_sql.open_cursor;
      l_sql := 'select '|| g_ps_custom_procs(NUM) || '(:record_id, :entity_name, :attribute_name) from dual';
      BEGIN
        dbms_sql.parse(c,l_sql,2);
        g_ps_custom_valid(NUM) := 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          g_ps_custom_valid(NUM) := 'N';
          FND_FILE.put_line(fnd_file.log,'Error parsing custom attribute procedure ' || g_ps_custom_procs(NUM) ||
              ' for attribute PARTY.'||g_ps_custom_attrs(NUM));
      END;
      dbms_sql.close_cursor(c);

      NUM := NUM+1;
    END LOOP;
    CLOSE custom_attribs;
  END IF;

  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..g_ps_custom_procs.COUNT LOOP
    l_proc_name := g_ps_custom_procs(I);
    l_attr_name := g_ps_custom_attrs(I);

    IF g_ps_custom_valid(I) = 'Y' THEN

      BEGIN
        IF l_proc_name = 'HZ_PARTY_ACQUIRE.get_address' THEN
          l_val := HZ_PARTY_ACQUIRE.get_address(p_party_site_id, 'PARTY_SITES', l_attr_name, 'STAGE');
        ELSE
          -- Create a dynamic SQL block to execute the merge procedure
          plsql_block := 'BEGIN '||
                     ' :retval := '||l_proc_name||'(:record_id, :entity_name, :attribute_name);'||
                     'END;';

          -- Execute the dynamic PLSQL block
          EXECUTE IMMEDIATE plsql_block USING
            OUT l_val, p_party_site_id, 'PARTY_SITES', l_attr_name;
        END IF;

        IF l_attr_name = 'ADDRESS' THEN
          l_party_site_search_rec.ADDRESS := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE1' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE1 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE2' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE2 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE3' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE3 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE4' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE4 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE5' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE5 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE6' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE6 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE7' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE7 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE8' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE8 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE9' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE9 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE10' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE10:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE11' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE11 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE12' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE12 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE13' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE13 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE14' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE14 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE15' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE15 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE16' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE16 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE17' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE17 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE18' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE18 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE19' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE19 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE20' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE20:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE21' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE21 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE22' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE22 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE23' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE23 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE24' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE24 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE25' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE25 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE26' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE26 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE27' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE27 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE28' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE28 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE29' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE29 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE30' THEN
          l_party_site_search_rec.CUSTOM_ATTRIBUTE30:= l_val;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.put_line(FND_FILE.log,'Error executing custom procedure for attribute ' || l_attr_name || ' (Party Site ID: ' || p_party_site_id || '). Continuing ... ');
          FND_FILE.put_line(FND_FILE.log,SQLERRM);
/*
          FND_MESSAGE.SET_NAME('AR', 'HZ_CUSTOM_PROC_ERROR');
          FND_MESSAGE.SET_TOKEN('ENTITY' ,'PARTY_SITES');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attr_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
*/
      END;
    END IF;
  END LOOP;

  RETURN l_party_site_search_rec;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'get_party_site_rec');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


FUNCTION get_contact_rec (
        p_org_contact_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.contact_search_rec_type IS

  CURSOR c_org_contact IS
    SELECT o.CONTACT_NUMBER
         ,o.DECISION_MAKER_FLAG
         ,o.JOB_TITLE
         ,o.JOB_TITLE_CODE
         ,o.MAIL_STOP
         ,o.NATIVE_LANGUAGE
         ,o.OTHER_LANGUAGE_1
         ,o.OTHER_LANGUAGE_2
         ,o.RANK
         ,o.REFERENCE_USE_FLAG
         ,o.TITLE
         ,pr.RELATIONSHIP_TYPE
         ,ps.BEST_TIME_CONTACT_BEGIN
         ,ps.BEST_TIME_CONTACT_END
         ,ps.DATE_OF_BIRTH
         ,ps.DATE_OF_DEATH
         ,ps.JGZZ_FISCAL_CODE
         ,ps.KNOWN_AS
         ,ps.PERSON_ACADEMIC_TITLE
         ,ps.PERSON_FIRST_NAME
         ,ps.PERSON_FIRST_NAME_PHONETIC
         ,ps.PERSON_IDENTIFIER
         ,ps.PERSON_IDEN_TYPE
         ,ps.PERSON_INITIALS
         ,ps.PERSON_LAST_NAME
         ,ps.PERSON_LAST_NAME_PHONETIC
         ,ps.PERSON_MIDDLE_NAME
         ,ps.PERSON_NAME
         ,ps.PERSON_NAME_PHONETIC
         ,ps.PERSON_NAME_SUFFIX
         ,ps.PERSON_PREVIOUS_LAST_NAME
         ,ps.PERSON_TITLE
         ,ps.PLACE_OF_BIRTH
         ,ps.TAX_NAME
         ,ps.TAX_REFERENCE
    FROM HZ_ORG_CONTACTS o, HZ_RELATIONSHIPS pr, HZ_PERSON_PROFILES ps
    WHERE o.party_relationship_id = pr.relationship_id
    AND pr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND pr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND pr.DIRECTIONAL_FLAG = 'F'
    AND pr.subject_id = ps.party_id
    AND ps.effective_end_date IS NULL
    AND o.org_contact_id = p_org_contact_id
    AND (o.status is null OR o.status = 'A' or o.status = 'I')
    AND (pr.status is null OR pr.status = 'A' or pr.status = 'I');

  CURSOR custom_attribs IS
    SELECT attribute_name, custom_attribute_procedure
    FROM HZ_TRANS_ATTRIBUTES_VL
    WHERE entity_name='CONTACTS'
    AND (source_table = 'CUSTOM'
    OR custom_attribute_procedure is not null);

  l_attr_name VARCHAR2(255);
  l_proc_name VARCHAR2(255);
  plsql_block VARCHAR2(32000);
  l_val VARCHAR2(2000);

  l_contact_search_rec HZ_PARTY_SEARCH.contact_search_rec_type;
  l_subject_id NUMBER;
  l_return_status         VARCHAR2(1);

  NUM NUMBER;
  c NUMBER;

  l_sql VARCHAR2(255);

BEGIN
  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  OPEN c_org_contact;
  FETCH c_org_contact INTO l_contact_search_rec.CONTACT_NUMBER
                    ,l_contact_search_rec.DECISION_MAKER_FLAG
                    ,l_contact_search_rec.JOB_TITLE
                    ,l_contact_search_rec.JOB_TITLE_CODE
                    ,l_contact_search_rec.MAIL_STOP
                    ,l_contact_search_rec.NATIVE_LANGUAGE
                    ,l_contact_search_rec.OTHER_LANGUAGE_1
                    ,l_contact_search_rec.OTHER_LANGUAGE_2
                    ,l_contact_search_rec.RANK
                    ,l_contact_search_rec.REFERENCE_USE_FLAG
                    ,l_contact_search_rec.TITLE
                    ,l_contact_search_rec.RELATIONSHIP_TYPE
                    ,l_contact_search_rec.BEST_TIME_CONTACT_BEGIN
                    ,l_contact_search_rec.BEST_TIME_CONTACT_END
                    ,l_contact_search_rec.DATE_OF_BIRTH
                    ,l_contact_search_rec.DATE_OF_DEATH
                    ,l_contact_search_rec.JGZZ_FISCAL_CODE
                    ,l_contact_search_rec.KNOWN_AS
                    ,l_contact_search_rec.PERSON_ACADEMIC_TITLE
                    ,l_contact_search_rec.PERSON_FIRST_NAME
                    ,l_contact_search_rec.PERSON_FIRST_NAME_PHONETIC
                    ,l_contact_search_rec.PERSON_IDENTIFIER
                    ,l_contact_search_rec.PERSON_IDEN_TYPE
                    ,l_contact_search_rec.PERSON_INITIALS
                    ,l_contact_search_rec.PERSON_LAST_NAME
                    ,l_contact_search_rec.PERSON_LAST_NAME_PHONETIC
                    ,l_contact_search_rec.PERSON_MIDDLE_NAME
                    ,l_contact_search_rec.PERSON_NAME
                    ,l_contact_search_rec.PERSON_NAME_PHONETIC
                    ,l_contact_search_rec.PERSON_NAME_SUFFIX
                    ,l_contact_search_rec.PERSON_PREVIOUS_LAST_NAME
                    ,l_contact_search_rec.PERSON_TITLE
                    ,l_contact_search_rec.PLACE_OF_BIRTH
                    ,l_contact_search_rec.TAX_NAME
                    ,l_contact_search_rec.TAX_REFERENCE;
  CLOSE c_org_contact;

  IF g_cont_custom_queried = 'N' THEN
    g_cont_custom_queried := 'Y';

    NUM := 1;
    OPEN custom_attribs;
    LOOP

      FETCH custom_attribs INTO g_cont_custom_attrs(NUM), g_cont_custom_procs(NUM);
      EXIT WHEN custom_attribs%NOTFOUND;

      c := dbms_sql.open_cursor;
      l_sql := 'select '|| g_cont_custom_procs(NUM) || '(:record_id, :entity_name, :attribute_name) from dual';
      BEGIN
        dbms_sql.parse(c,l_sql,2);
        g_cont_custom_valid(NUM) := 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          g_cont_custom_valid(NUM) := 'N';
          FND_FILE.put_line(fnd_file.log,'Error parsing custom attribute procedure ' || g_cont_custom_procs(NUM) ||
              ' for attribute PARTY.'||g_cont_custom_attrs(NUM));
      END;
      dbms_sql.close_cursor(c);

      NUM := NUM+1;
    END LOOP;
    CLOSE custom_attribs;
  END IF;

  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..g_cont_custom_procs.COUNT LOOP
    l_proc_name := g_cont_custom_procs(I);
    l_attr_name := g_cont_custom_attrs(I);

    IF g_cont_custom_valid(I) = 'Y' THEN

      BEGIN
        IF l_proc_name='HZ_PARTY_ACQUIRE.get_contact_name' THEN
          l_val := HZ_PARTY_ACQUIRE.get_contact_name(p_org_contact_id, 'CONTACTS', l_attr_name, 'STAGE');
        ELSE
          -- Create a dynamic SQL block to execute the merge procedure
          plsql_block := 'BEGIN '||
                     ' :retval := '||l_proc_name||'(:record_id, :entity_name, :attribute_name);'||
                     'END;';

          -- Execute the dynamic PLSQL block
          EXECUTE IMMEDIATE plsql_block USING
              OUT l_val, p_org_contact_id, 'CONTACTS', l_attr_name;
        END IF;

        IF l_attr_name = 'CONTACT_NAME' THEN
          l_contact_search_rec.CONTACT_NAME := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE1' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE1 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE2' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE2 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE3' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE3 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE4' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE4 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE5' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE5 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE6' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE6 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE7' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE7 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE8' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE8 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE9' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE9 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE10' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE10:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE11' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE11 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE12' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE12 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE13' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE13 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE14' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE14 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE15' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE15 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE16' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE16 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE17' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE17 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE18' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE18 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE19' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE19 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE20' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE20:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE21' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE21 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE22' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE22 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE23' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE23 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE24' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE24 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE25' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE25 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE26' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE26 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE27' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE27 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE28' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE28 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE29' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE29 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE30' THEN
          l_contact_search_rec.CUSTOM_ATTRIBUTE30:= l_val;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.put_line(FND_FILE.log,'Error executing custom procedure for attribute ' || l_attr_name || ' (Org Contact ID: ' || p_org_contact_id || '). Continuing ... ');
          FND_FILE.put_line(FND_FILE.log,SQLERRM);
/*
          FND_MESSAGE.SET_NAME('AR', 'HZ_CUSTOM_PROC_ERROR');
          FND_MESSAGE.SET_TOKEN('ENTITY' ,'CONTACT');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attr_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
*/
      END;
    END IF;
  END LOOP;

  RETURN l_contact_search_rec;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'get_contact_Rec');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


FUNCTION get_contact_point_rec (
        p_contact_point_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.contact_point_search_rec_type IS

  CURSOR cpt IS
    SELECT CONTACT_POINT_TYPE
         ,CONTENT_SOURCE_TYPE
         ,EDI_ECE_TP_LOCATION_CODE
         ,EDI_ID_NUMBER
         ,EDI_PAYMENT_FORMAT
         ,EDI_PAYMENT_METHOD
         ,EDI_REMITTANCE_INSTRUCTION
         ,EDI_REMITTANCE_METHOD
         ,EDI_TP_HEADER_ID
         ,EDI_TRANSACTION_HANDLING
         ,EMAIL_ADDRESS
         ,EMAIL_FORMAT
         ,LAST_CONTACT_DT_TIME
         ,PHONE_AREA_CODE
         ,PHONE_CALLING_CALENDAR
         ,PHONE_COUNTRY_CODE
         ,PHONE_EXTENSION
         ,PHONE_LINE_TYPE
         ,PHONE_NUMBER
         ,PRIMARY_FLAG
         ,TELEPHONE_TYPE
         ,TELEX_NUMBER
         ,TIME_ZONE
         ,URL
         ,WEB_TYPE
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = p_contact_point_id
    AND (status is null OR status = 'A' or status = 'I');

  CURSOR custom_attribs IS
    SELECT attribute_name, custom_attribute_procedure
    FROM HZ_TRANS_ATTRIBUTES_VL
    WHERE entity_name='CONTACT_POINTS'
    AND (source_table = 'CUSTOM'
    OR custom_attribute_procedure IS NOT NULL);

  l_attr_name VARCHAR2(255);
  l_proc_name VARCHAR2(255);
  plsql_block VARCHAR2(32000);
  l_val VARCHAR2(2000);

  l_contact_pt_search_rec HZ_PARTY_SEARCH.contact_point_search_rec_type;
  l_return_status VARCHAR2(1);

  NUM NUMBER;
  c NUMBER;

  l_sql VARCHAR2(255);

BEGIN
  l_return_status:=FND_API.G_RET_STS_SUCCESS;

  OPEN cpt;
  FETCH cpt INTO l_contact_pt_search_rec.CONTACT_POINT_TYPE
    ,l_contact_pt_search_rec.CONTENT_SOURCE_TYPE
    ,l_contact_pt_search_rec.EDI_ECE_TP_LOCATION_CODE
    ,l_contact_pt_search_rec.EDI_ID_NUMBER
    ,l_contact_pt_search_rec.EDI_PAYMENT_FORMAT
    ,l_contact_pt_search_rec.EDI_PAYMENT_METHOD
    ,l_contact_pt_search_rec.EDI_REMITTANCE_INSTRUCTION
    ,l_contact_pt_search_rec.EDI_REMITTANCE_METHOD
    ,l_contact_pt_search_rec.EDI_TP_HEADER_ID
    ,l_contact_pt_search_rec.EDI_TRANSACTION_HANDLING
    ,l_contact_pt_search_rec.EMAIL_ADDRESS
    ,l_contact_pt_search_rec.EMAIL_FORMAT
    ,l_contact_pt_search_rec.LAST_CONTACT_DT_TIME
    ,l_contact_pt_search_rec.PHONE_AREA_CODE
    ,l_contact_pt_search_rec.PHONE_CALLING_CALENDAR
    ,l_contact_pt_search_rec.PHONE_COUNTRY_CODE
    ,l_contact_pt_search_rec.PHONE_EXTENSION
    ,l_contact_pt_search_rec.PHONE_LINE_TYPE
    ,l_contact_pt_search_rec.PHONE_NUMBER
    ,l_contact_pt_search_rec.PRIMARY_FLAG
    ,l_contact_pt_search_rec.TELEPHONE_TYPE
    ,l_contact_pt_search_rec.TELEX_NUMBER
    ,l_contact_pt_search_rec.TIME_ZONE
    ,l_contact_pt_search_rec.URL
    ,l_contact_pt_search_rec.WEB_TYPE;
  CLOSE cpt;

  IF g_cpt_custom_queried = 'N' THEN
    g_cpt_custom_queried := 'Y';

    NUM := 1;
    OPEN custom_attribs;
    LOOP

      FETCH custom_attribs INTO g_cpt_custom_attrs(NUM), g_cpt_custom_procs(NUM);
      EXIT WHEN custom_attribs%NOTFOUND;

      c := dbms_sql.open_cursor;

      l_sql := 'select '|| g_cpt_custom_procs(NUM) || '(:record_id, :entity_name, :attribute_name) from dual';
      BEGIN
        dbms_sql.parse(c,l_sql,2);
        g_cpt_custom_valid(NUM) := 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          g_cpt_custom_valid(NUM) := 'N';
          FND_FILE.put_line(fnd_file.log,'Error parsing custom attribute procedure '
             || g_cpt_custom_procs(NUM) ||
             ' for attribute PARTY.'||g_cpt_custom_attrs(NUM));
      END;
      dbms_sql.close_cursor(c);


      NUM := NUM+1;
    END LOOP;
    CLOSE custom_attribs;
  END IF;

  l_return_status:=FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..g_cpt_custom_procs.COUNT LOOP
    l_proc_name := g_cpt_custom_procs(I);
    l_attr_name := g_cpt_custom_attrs(I);

    IF g_cpt_custom_valid(I) = 'Y' THEN

      BEGIN
        IF l_proc_name='HZ_PARTY_ACQUIRE.get_phone_number' THEN
          l_val := HZ_PARTY_ACQUIRE.get_phone_number(p_contact_point_id, 'CONTACT_POINTS', l_attr_name, 'STAGE');
        ELSE
          -- Create a dynamic SQL block to execute the merge procedure
          plsql_block := 'BEGIN '||
                     ' :retval := '||l_proc_name||'(:record_id, :entity_name, :attribute_name);'||
                     'END;';

          -- Execute the dynamic PLSQL block
          EXECUTE IMMEDIATE plsql_block USING
              OUT l_val, p_contact_point_id, 'CONTACT_POINTS', l_attr_name;
        END IF;

        IF l_attr_name = 'FLEX_FORMAT_PHONE_NUMBER' THEN
          l_contact_pt_search_rec.FLEX_FORMAT_PHONE_NUMBER := l_val;
        ELSIF l_attr_name = 'RAW_PHONE_NUMBER' THEN
          l_contact_pt_search_rec.RAW_PHONE_NUMBER := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE1' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE1 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE2' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE2 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE3' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE3 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE4' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE4 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE5' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE5 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE6' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE6 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE7' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE7 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE8' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE8 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE9' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE9 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE10' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE10:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE11' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE11 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE12' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE12 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE13' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE13 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE14' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE14 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE15' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE15 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE16' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE16 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE17' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE17 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE18' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE18 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE19' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE19 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE20' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE20:= l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE21' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE21 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE22' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE22 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE23' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE23 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE24' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE24 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE25' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE25 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE26' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE26 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE27' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE27 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE28' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE28 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE29' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE29 := l_val;
        ELSIF l_attr_name = 'CUSTOM_ATTRIBUTE30' THEN
          l_contact_pt_search_rec.CUSTOM_ATTRIBUTE30:= l_val;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.put_line(FND_FILE.log,'Error executing custom procedure for attribute ' || l_attr_name || ' (Contact Point ID: ' || p_contact_point_id || '). Continuing ... ');
          FND_FILE.put_line(FND_FILE.log,SQLERRM);
/*
          FND_MESSAGE.SET_NAME('AR', 'HZ_CUSTOM_PROC_ERROR');
          FND_MESSAGE.SET_TOKEN('ENTITY' ,'CONTACT POINTS');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE' ,l_attr_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
*/
      END;
    END IF;
  END LOOP;

  RETURN l_contact_pt_search_rec;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    RAISE;
    FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'get_contact_point_rec');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;

FUNCTION get_account_info(
	p_party_id	IN	NUMBER,
	p_entity	IN	VARCHAR2,
	p_attribute	IN	VARCHAR2,
    p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR cust_acct_info IS
  SELECT ACCOUNT_NAME, ACCOUNT_NUMBER
  FROM hz_cust_accounts
  WHERE PARTY_ID = p_party_id
  ORDER BY STATUS,CREATION_DATE;--Bug 9155543

l_acct_name VARCHAR2(240);
l_acct_number VARCHAR2(30);

l_acct_ret VARCHAR2(1999); --Bug No: 4304921
BEGIN

  OPEN cust_acct_info;
  LOOP
    FETCH cust_acct_info INTO l_acct_name, l_acct_number;
    EXIT WHEN cust_acct_info%NOTFOUND;

    IF p_attribute = 'ALL_ACCOUNT_NAMES' THEN
      l_acct_ret :=
        l_acct_ret || ' ' || l_acct_name;
    ELSIF p_attribute = 'ALL_ACCOUNT_NUMBERS' THEN
      l_acct_ret :=
        l_acct_ret || ' ' ||l_acct_number;
    END IF;
  END LOOP;
  CLOSE cust_acct_info;
  RETURN l_acct_ret;

EXCEPTION
  WHEN OTHERS THEN
    IF (sqlcode=-6502) THEN
        RETURN 'SYNC';--Bug 9204273
    END IF;
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.get_account_info');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_account_info;

FUNCTION get_known_as (
        p_party_id      IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR known_as IS
  SELECT PARTY_NAME || ' ' || KNOWN_AS || ' ' || KNOWN_AS2 || ' ' || KNOWN_AS3
          || ' '|| KNOWN_AS4 || ' '|| KNOWN_AS5, PARTY_NAME
  FROM HZ_PARTIES
  WHERE party_id = p_party_id;

l_known_as VARCHAR2(4000);
l_party_name VARCHAR2(4000);

BEGIN
  OPEN known_as;
  FETCH known_as INTO l_known_as, l_party_name;
  CLOSE known_as;

  IF p_context IS NOT NULL THEN
    RETURN l_known_as;
  ELSE
    RETURN l_party_name;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.get_known_as');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_known_as;

FUNCTION get_address (
        p_party_site_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR c_party_site IS
    SELECT rtrim(l.address1 || ' ' || l.address2 || ' ' ||
                 l.address3 || ' ' || l.address4), rtrim(l.address1)
    FROM HZ_PARTY_SITES ps, HZ_LOCATIONS l
    WHERE ps.party_site_id = p_party_site_id
    AND   ps.location_id = l.location_id;

l_address VARCHAR2(4000);
l_address1 VARCHAR2(4000);

BEGIN
  OPEN c_party_site;
  FETCH  c_party_site INTO l_address, l_address1;
  CLOSE c_party_site;

  IF p_context IS NOT NULL THEN
    RETURN l_address;
  ELSE
    RETURN l_address1;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.get_address');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_address;

FUNCTION get_contact_name (
        p_org_contact_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS

  CURSOR cname IS
    select party_name
    from HZ_ORG_CONTACTS o, HZ_RELATIONSHIPS pr, HZ_parties p
    WHERE o.party_relationship_id = pr.relationship_id
    AND pr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND pr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND pr.DIRECTIONAL_FLAG = 'F'
    AND pr.subject_id = p.party_id
    AND o.org_contact_id = p_org_contact_id
    AND (o.status is null OR o.status = 'A' or o.status = 'I')
    AND (pr.status is null OR pr.status = 'A' or pr.status = 'I');

l_cname VARCHAR2(2000);
BEGIN
  OPEN cname;
  FETCH cname INTO l_cname;
  CLOSE cname;

  RETURN l_cname;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.get_address');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_contact_name;

FUNCTION get_phone_number (
        p_contact_pt_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR cpt IS
    SELECT PHONE_NUMBER, PHONE_AREA_CODE, PHONE_COUNTRY_CODE
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = p_contact_pt_id;

l_phone_number VARCHAR2(255);
l_phone_area_code VARCHAR2(255);
l_phone_country_code VARCHAR2(255);

BEGIN
  OPEN cpt;
  FETCH cpt INTO l_phone_number, l_phone_area_code, l_phone_country_code;
  CLOSE cpt;

  IF p_attribute = 'FLEX_FORMAT_PHONE_NUMBER' THEN
    IF p_context IS NOT NULL THEN
     RETURN
       filter_ph_num(l_phone_number) || ' '||
       filter_ph_num(l_phone_area_code||
                   l_phone_number) || ' '||
       filter_ph_num(l_phone_country_code ||
                   l_phone_area_code||
                   l_phone_number);
    ELSE
      RETURN filter_ph_num(
                   l_phone_country_code ||
                   l_phone_area_code||
                   l_phone_number);
    END IF;
  ELSIF p_attribute = 'RAW_PHONE_NUMBER' THEN
    RETURN filter_ph_num(
                   l_phone_country_code ||
                   l_phone_area_code||
                   l_phone_number);
  END IF;
  RETURN null;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.get_phone_number');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_phone_number;

-- this will return the concaternation of the
-- orig sytem and the orig system reference
-- delimited by a space
FUNCTION get_ssm_mappings (
        p_record_id     IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS
retstr VARCHAR2(2000) ;
BEGIN

-- record_id will map to owner_table id
-- decoded entity will map to owner_table_name
-- return concatenation of all that you can find
IF p_context = 'STAGE'
THEN
    FOR t_cur in
    ( select orig_system, orig_system_reference
      from
     hz_orig_sys_references
     where owner_table_name = decode(p_entity,
                               'PARTY','HZ_PARTIES',
                               'PARTY_SITES', 'HZ_PARTY_SITES',
                               'CONTACTS','HZ_ORG_CONTACTS',
                               'CONTACT_POINTS', 'HZ_CONTACT_POINTS')
          and owner_table_id = p_record_id
          and nvl(STATUS,'A')='A' )
     LOOP
        retstr := retstr || t_cur.orig_system ||' '|| t_cur.orig_system_reference || ' ';
     END LOOP;

-- return the primary one
ELSE

     IF p_entity = 'PARTY'
     THEN
       select b.orig_system || ' '||a.orig_system_reference
       into retstr
       from hz_parties a, hz_orig_sys_references b
       where b.owner_table_id = p_record_id
       and b.owner_table_name = 'HZ_PARTIES'
       and b.orig_system_reference = a.orig_system_reference
       and nvl(b.STATUS,'A')='A';
     END IF;

     IF p_entity = 'PARTY_SITES'
     THEN
        select b.orig_system || ' '||a.orig_system_reference into retstr
        from hz_party_sites a, hz_orig_sys_references b
        where b.owner_table_id = p_record_id
        and b.owner_table_name = 'HZ_PARTY_SITES'
        and b.orig_system_reference = a.orig_system_reference
        and nvl(b.STATUS,'A')='A';
     END IF;

     IF p_entity = 'CONTACT'
     THEN
        select b.orig_system || ' '||a.orig_system_reference into retstr
        from hz_org_contacts a, hz_orig_sys_references b
        where b.owner_table_id = p_record_id
        and b.owner_table_name = 'HZ_ORG_CONTACTS'
        and b.orig_system_reference = a.orig_system_reference
        and nvl(b.STATUS,'A')='A';

     END IF;

     IF p_entity = 'CONTACT_POINTS'
     THEN
         select b.orig_system || ' '||a.orig_system_reference into retstr
         from hz_contact_points a, hz_orig_sys_references b
         where b.owner_table_id = p_record_id
         and b.owner_table_name = 'HZ_CONTACT_POINTS'
         and b.orig_system_reference = a.orig_system_reference
         and nvl(b.STATUS,'A')='A';

     END IF;

 END IF ;

    return retstr;



EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    IF (sqlcode=-6502) THEN
       return retstr;
    END IF;
    FND_MESSAGE.SET_NAME('AR', 'HZ_ACQUIRE_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_PARTY_ACQUIRE.GET_SSM_MAPPINGS');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_ssm_mappings ;

END;

/
