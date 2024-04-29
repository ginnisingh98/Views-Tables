--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_ORGANIZATION_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_ORGANIZATION_BO_PVT" AS
/*$Header: ARHEPOVB.pls 120.11.12000000.2 2007/02/23 20:55:37 awu ship $ */
/*
 * This package contains the private APIs for logical organization.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Organization
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Organization Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_organization_bo
  --
  -- DESCRIPTION
  --     Get a logical organization.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_organization_id          Organization ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_obj         Logical organization record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   06-JUN-2005   AWU                Created.
  --

-- private procedure get_financial_report_bos

procedure get_financial_report_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_financial_report_objs  OUT NOCOPY    HZ_FINANCIAL_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
CURSOR C1 IS
	SELECT  HZ_FINANCIAL_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		FINANCIAL_REPORT_ID,
		PARTY_ID,
		TYPE_OF_FINANCIAL_REPORT,
		DOCUMENT_REFERENCE,
		DATE_REPORT_ISSUED,
		ISSUED_PERIOD,
		REPORT_START_DATE,
		REPORT_END_DATE,
		ACTUAL_CONTENT_SOURCE,
		REQUIRING_AUTHORITY,
		AUDIT_IND,
		CONSOLIDATED_IND,
		ESTIMATED_IND,
		FISCAL_IND,
		FINAL_IND,
		FORECAST_IND,
		OPENING_IND,
		PROFORMA_IND,
		QUALIFIED_IND,
		RESTATED_IND,
		SIGNED_BY_PRINCIPALS_IND,
		TRIAL_BALANCE_IND,
		UNBALANCED_IND,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
	CAST(MULTISET (
		SELECT HZ_FINANCIAL_NUMBER_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		FINANCIAL_NUMBER_ID,
		FINANCIAL_REPORT_ID,
		FINANCIAL_NUMBER,
		FINANCIAL_NUMBER_NAME,
		FINANCIAL_UNITS_APPLIED,
		FINANCIAL_NUMBER_CURRENCY,
		PROJECTED_ACTUAL_FLAG,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE)
	FROM HZ_FINANCIAL_NUMBERS
	WHERE FINANCIAL_REPORT_ID = FR.FINANCIAL_REPORT_ID) AS  HZ_FINANCIAL_NUMBER_OBJ_TBL))
     FROM  HZ_FINANCIAL_REPORTS FR
     WHERE PARTY_ID = P_ORGANIZATION_ID;

l_debug_prefix              VARCHAR2(30) := '';

BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_financial_report_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_financial_report_objs := HZ_FINANCIAL_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_financial_report_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_financial_report_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_financial_report_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_financial_report_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_financial_report_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



/*
The Get Organization API Procedure is a retrieval service that returns a full Organization business object.
The user identifies a particular Organization business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization business object is returned. The object consists of all data included within
the Organization business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Org Contact	N	Y	get_contact_bo
Party Site	N	Y	get_party_site_bo
Phone	N	Y	get_phone_bo
Telex	N	Y	get_telex_bo
Email	N	Y	get_email_bo
Web	N	Y	get_web_bo
EDI	N	Y	get_edi_bo
EFT	N	Y	get_eft_bo
Financial Report	N	Y		Business Structure. Included entities: HZ_FINANCIAL_REPORTS, HZ_FINANCIAL_NUMBERS


To retrieve the appropriate embedded entities within the Organization business object,
the Get procedure returns all records for the particular organization from these TCA entity tables:

Embedded TCA Entity	Mandatory    Multiple	TCA Table Entities

Party, Org Profile	Y		N	HZ_PARTIES, HZ_ORGANIZATION_PROFILES
Org Preference		N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Credit Rating		N		Y	HZ_CREDIT_RATINGS
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE

*/


 PROCEDURE get_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_ORGANIZATION_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		P.PARTY_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		P.PARTY_NUMBER,
		P.VALIDATED_FLAG,
		P.STATUS,
		P.CATEGORY_CODE,
		P.SALUTATION,
		P.ATTRIBUTE_CATEGORY,
		P.ATTRIBUTE1,
		P.ATTRIBUTE2,
		P.ATTRIBUTE3,
		P.ATTRIBUTE4,
		P.ATTRIBUTE5,
		P.ATTRIBUTE6,
		P.ATTRIBUTE7,
		P.ATTRIBUTE8,
		P.ATTRIBUTE9,
		P.ATTRIBUTE10,
		P.ATTRIBUTE11,
		P.ATTRIBUTE12,
		P.ATTRIBUTE13,
		P.ATTRIBUTE14,
		P.ATTRIBUTE15,
		P.ATTRIBUTE16,
		P.ATTRIBUTE17,
		P.ATTRIBUTE18,
		P.ATTRIBUTE19,
		P.ATTRIBUTE20,
		P.ATTRIBUTE21,
		P.ATTRIBUTE22,
		P.ATTRIBUTE23,
		P.ATTRIBUTE24,
		PRO.ORGANIZATION_NAME,
		PRO.DUNS_NUMBER_C,
		PRO.ENQUIRY_DUNS,
		PRO.CEO_NAME,
		PRO.CEO_TITLE,
		PRO.PRINCIPAL_NAME,
		PRO.PRINCIPAL_TITLE,
		PRO.LEGAL_STATUS,
		PRO.CONTROL_YR,
		PRO.EMPLOYEES_TOTAL,
		PRO.HQ_BRANCH_IND,
		PRO.BRANCH_FLAG,
		PRO.OOB_IND,
		PRO.LINE_OF_BUSINESS,
		PRO.CONG_DIST_CODE,
		PRO.SIC_CODE,
		PRO.IMPORT_IND,
		PRO.EXPORT_IND,
		PRO.LABOR_SURPLUS_IND,
		PRO.DEBARMENT_IND,
		PRO.MINORITY_OWNED_IND,
		PRO.MINORITY_OWNED_TYPE,
		PRO.WOMAN_OWNED_IND,
		PRO.DISADV_8A_IND,
		PRO.SMALL_BUS_IND,
		PRO.RENT_OWN_IND,
		PRO.DEBARMENTS_COUNT,
		PRO.DEBARMENTS_DATE,
		PRO.FAILURE_SCORE,
		PRO.FAILURE_SCORE_NATNL_PERCENTILE,
		PRO.FAILURE_SCORE_OVERRIDE_CODE,
		PRO.FAILURE_SCORE_COMMENTARY,
		PRO.GLOBAL_FAILURE_SCORE,
		PRO.DB_RATING,
		PRO.CREDIT_SCORE,
		PRO.CREDIT_SCORE_COMMENTARY,
		PRO.PAYDEX_SCORE,
		PRO.PAYDEX_THREE_MONTHS_AGO,
		PRO.PAYDEX_NORM,
		PRO.BEST_TIME_CONTACT_BEGIN,
		PRO.BEST_TIME_CONTACT_END,
		PRO.ORGANIZATION_NAME_PHONETIC,
		PRO.TAX_REFERENCE,
		PRO.GSA_INDICATOR_FLAG,
		PRO.JGZZ_FISCAL_CODE,
		PRO.ANALYSIS_FY,
		PRO.FISCAL_YEAREND_MONTH,
		PRO.CURR_FY_POTENTIAL_REVENUE,
		PRO.NEXT_FY_POTENTIAL_REVENUE,
		PRO.YEAR_ESTABLISHED,
		PRO.MISSION_STATEMENT,
		PRO.ORGANIZATION_TYPE,
		PRO.BUSINESS_SCOPE,
		PRO.CORPORATION_CLASS,
		PRO.KNOWN_AS,
		PRO.KNOWN_AS2,
		PRO.KNOWN_AS3,
		PRO.KNOWN_AS4,
		PRO.KNOWN_AS5,
		PRO.LOCAL_BUS_IDEN_TYPE,
		PRO.LOCAL_BUS_IDENTIFIER,
		PRO.PREF_FUNCTIONAL_CURRENCY,
		PRO.REGISTRATION_TYPE,
		PRO.TOTAL_EMPLOYEES_TEXT,
		PRO.TOTAL_EMPLOYEES_IND,
		PRO.TOTAL_EMP_EST_IND,
		PRO.TOTAL_EMP_MIN_IND,
		PRO.PARENT_SUB_IND,
		PRO.INCORP_YEAR,
		PRO.SIC_CODE_TYPE,
		PRO.PUBLIC_PRIVATE_OWNERSHIP_FLAG,
		PRO.INTERNAL_FLAG,
		PRO.LOCAL_ACTIVITY_CODE_TYPE,
		PRO.LOCAL_ACTIVITY_CODE,
		PRO.EMP_AT_PRIMARY_ADR,
		PRO.EMP_AT_PRIMARY_ADR_TEXT,
		PRO.EMP_AT_PRIMARY_ADR_EST_IND,
		PRO.EMP_AT_PRIMARY_ADR_MIN_IND,
		PRO.HIGH_CREDIT,
		PRO.AVG_HIGH_CREDIT,
		PRO.TOTAL_PAYMENTS,
		PRO.CREDIT_SCORE_CLASS,
		PRO.CREDIT_SCORE_NATL_PERCENTILE,
		PRO.CREDIT_SCORE_INCD_DEFAULT,
		PRO.CREDIT_SCORE_AGE,
		PRO.CREDIT_SCORE_DATE,
		PRO.CREDIT_SCORE_COMMENTARY2,
		PRO.CREDIT_SCORE_COMMENTARY3,
		PRO.CREDIT_SCORE_COMMENTARY4,
		PRO.CREDIT_SCORE_COMMENTARY5,
		PRO.CREDIT_SCORE_COMMENTARY6,
		PRO.CREDIT_SCORE_COMMENTARY7,
		PRO.CREDIT_SCORE_COMMENTARY8,
		PRO.CREDIT_SCORE_COMMENTARY9,
		PRO.CREDIT_SCORE_COMMENTARY10,
		PRO.FAILURE_SCORE_CLASS,
		PRO.FAILURE_SCORE_INCD_DEFAULT,
		PRO.FAILURE_SCORE_AGE,
		PRO.FAILURE_SCORE_DATE,
		PRO.FAILURE_SCORE_COMMENTARY2,
		PRO.FAILURE_SCORE_COMMENTARY3,
		PRO.FAILURE_SCORE_COMMENTARY4,
		PRO.FAILURE_SCORE_COMMENTARY5,
		PRO.FAILURE_SCORE_COMMENTARY6,
		PRO.FAILURE_SCORE_COMMENTARY7,
		PRO.FAILURE_SCORE_COMMENTARY8,
		PRO.FAILURE_SCORE_COMMENTARY9,
		PRO.FAILURE_SCORE_COMMENTARY10,
		PRO.MAXIMUM_CREDIT_RECOMMENDATION,
		PRO.MAXIMUM_CREDIT_CURRENCY_CODE,
		PRO.DISPLAYED_DUNS_PARTY_ID,
		PRO.PROGRAM_UPDATE_DATE,
		PRO.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PRO.CREATED_BY),
		PRO.CREATION_DATE,
		PRO.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PRO.LAST_UPDATED_BY),
		PRO.DO_NOT_CONFUSE_WITH,
		PRO.ACTUAL_CONTENT_SOURCE,
		HZ_ORIG_SYS_REF_OBJ_TBL(),
		HZ_EXT_ATTRIBUTE_OBJ_TBL(),
		HZ_ORG_CONTACT_BO_TBL(),
		HZ_PARTY_SITE_BO_TBL(),
	CAST(MULTISET (
		SELECT HZ_PARTY_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		PARTY_PREFERENCE_ID,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		CATEGORY,
		PREFERENCE_CODE,
		VALUE_VARCHAR2,
		VALUE_NUMBER,
		VALUE_DATE,
		VALUE_NAME,
		MODULE,
		ADDITIONAL_VALUE1,
		ADDITIONAL_VALUE2,
		ADDITIONAL_VALUE3,
		ADDITIONAL_VALUE4,
		ADDITIONAL_VALUE5,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_PARTY_PREFERENCES
		WHERE PARTY_ID = P_ORGANIZATION_ID) AS HZ_PARTY_PREF_OBJ_TBL),
		HZ_PHONE_CP_BO_TBL(),
		HZ_TELEX_CP_BO_TBL(),
		HZ_EMAIL_CP_BO_TBL(),
		HZ_WEB_CP_BO_TBL(),
		HZ_EDI_CP_BO_TBL(),
		HZ_EFT_CP_BO_TBL(),
		HZ_RELATIONSHIP_OBJ_TBL(),
	CAST(MULTISET (
		SELECT HZ_CODE_ASSIGNMENT_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CODE_ASSIGNMENT_ID,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		CLASS_CATEGORY,
		CLASS_CODE,
		PRIMARY_FLAG,
		ACTUAL_CONTENT_SOURCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		RANK)
	FROM HZ_CODE_ASSIGNMENTS
	WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND OWNER_TABLE_ID = P_ORGANIZATION_ID) AS HZ_CODE_ASSIGNMENT_OBJ_TBL),
		HZ_FINANCIAL_BO_TBL(),
			CAST(MULTISET (
	SELECT HZ_CREDIT_RATING_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CREDIT_RATING_ID,
		DESCRIPTION,
		PARTY_ID,
		RATING,
		RATED_AS_OF_DATE,
		RATING_ORGANIZATION,
		COMMENTS,
		DET_HISTORY_IND,
		FINCL_EMBT_IND,
		CRIMINAL_PROCEEDING_IND,
		CLAIMS_IND,
		SECURED_FLNG_IND,
		FINCL_LGL_EVENT_IND,
		DISASTER_IND,
		OPRG_SPEC_EVNT_IND,
		OTHER_SPEC_EVNT_IND,
		STATUS,
		AVG_HIGH_CREDIT,
		CREDIT_SCORE,
		CREDIT_SCORE_AGE,
		CREDIT_SCORE_CLASS,
		CREDIT_SCORE_COMMENTARY,
		CREDIT_SCORE_COMMENTARY2,
		CREDIT_SCORE_COMMENTARY3,
		CREDIT_SCORE_COMMENTARY4,
		CREDIT_SCORE_COMMENTARY5,
		CREDIT_SCORE_COMMENTARY6,
		CREDIT_SCORE_COMMENTARY7,
		CREDIT_SCORE_COMMENTARY8,
		CREDIT_SCORE_COMMENTARY9,
		CREDIT_SCORE_COMMENTARY10,
		CREDIT_SCORE_DATE,
		CREDIT_SCORE_INCD_DEFAULT,
		CREDIT_SCORE_NATL_PERCENTILE,
		FAILURE_SCORE,
		FAILURE_SCORE_AGE,
		FAILURE_SCORE_CLASS,
		FAILURE_SCORE_COMMENTARY,
		FAILURE_SCORE_COMMENTARY2,
		FAILURE_SCORE_COMMENTARY3,
		FAILURE_SCORE_COMMENTARY4,
		FAILURE_SCORE_COMMENTARY5,
		FAILURE_SCORE_COMMENTARY6,
		FAILURE_SCORE_COMMENTARY7,
		FAILURE_SCORE_COMMENTARY8,
		FAILURE_SCORE_COMMENTARY9,
		FAILURE_SCORE_COMMENTARY10,
		FAILURE_SCORE_DATE,
		FAILURE_SCORE_INCD_DEFAULT,
		FAILURE_SCORE_NATNL_PERCENTILE,
		FAILURE_SCORE_OVERRIDE_CODE,
		GLOBAL_FAILURE_SCORE,
		DEBARMENT_IND,
		DEBARMENTS_COUNT,
		DEBARMENTS_DATE,
		HIGH_CREDIT,
		MAXIMUM_CREDIT_CURRENCY_CODE,
		MAXIMUM_CREDIT_RECOMMENDATION,
		PAYDEX_NORM,
		PAYDEX_SCORE,
		PAYDEX_THREE_MONTHS_AGO,
		CREDIT_SCORE_OVERRIDE_CODE,
		CR_SCR_CLAS_EXPL,
		LOW_RNG_DELQ_SCR,
		HIGH_RNG_DELQ_SCR,
		DELQ_PMT_RNG_PRCNT,
		DELQ_PMT_PCTG_FOR_ALL_FIRMS,
		NUM_TRADE_EXPERIENCES,
		PAYDEX_FIRM_DAYS,
		PAYDEX_FIRM_COMMENT,
		PAYDEX_INDUSTRY_DAYS,
		PAYDEX_INDUSTRY_COMMENT,
		PAYDEX_COMMENT,
		SUIT_IND,
		LIEN_IND,
		JUDGEMENT_IND,
		BANKRUPTCY_IND,
		NO_TRADE_IND,
		PRNT_HQ_BKCY_IND,
		NUM_PRNT_BKCY_FILING,
		PRNT_BKCY_FILG_TYPE,
		PRNT_BKCY_FILG_CHAPTER,
		PRNT_BKCY_FILG_DATE,
		NUM_PRNT_BKCY_CONVS,
		PRNT_BKCY_CONV_DATE,
		PRNT_BKCY_CHAPTER_CONV,
		SLOW_TRADE_EXPL,
		NEGV_PMT_EXPL,
		PUB_REC_EXPL,
		BUSINESS_DISCONTINUED,
		SPCL_EVENT_COMMENT,
		NUM_SPCL_EVENT,
		SPCL_EVENT_UPDATE_DATE,
		SPCL_EVNT_TXT,
		ACTUAL_CONTENT_SOURCE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM HZ_CREDIT_RATINGS
	WHERE PARTY_ID = P_ORGANIZATION_ID) AS HZ_CREDIT_RATING_OBJ_TBL),
		CAST(MULTISET (
	SELECT HZ_CERTIFICATION_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CERTIFICATION_ID,
		CERTIFICATION_NAME,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		CURRENT_STATUS,
		EXPIRES_ON_DATE,
		GRADE,
		ISSUED_BY_AUTHORITY,
		ISSUED_ON_DATE,
		--WH_UPDATE_DATE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_CERTIFICATIONS
		WHERE PARTY_ID = P_ORGANIZATION_ID) AS HZ_CERTIFICATION_OBJ_TBL),
	CAST(MULTISET (
		SELECT HZ_FINANCIAL_PROF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		FINANCIAL_PROFILE_ID,
		ACCESS_AUTHORITY_DATE,
		ACCESS_AUTHORITY_GRANTED,
		BALANCE_AMOUNT,
		BALANCE_VERIFIED_ON_DATE,
		FINANCIAL_ACCOUNT_NUMBER,
		FINANCIAL_ACCOUNT_TYPE,
		FINANCIAL_ORG_TYPE,
		FINANCIAL_ORGANIZATION_NAME,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		--WH_UPDATE_DATE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_FINANCIAL_PROFILE
		WHERE PARTY_ID = P_ORGANIZATION_ID) AS HZ_FINANCIAL_PROF_OBJ_TBL),
		HZ_CONTACT_PREF_OBJ_TBL(),
		HZ_PARTY_USAGE_OBJ_TBL())
      	FROM HZ_ORGANIZATION_PROFILES PRO, HZ_PARTIES P
	WHERE PRO.PARTY_ID = P.PARTY_ID
	AND PRO.PARTY_ID = P_ORGANIZATION_ID
	AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND NVL(EFFECTIVE_END_DATE,SYSDATE);

 cursor get_profile_id_csr is
	select organization_profile_id
	from HZ_ORGANIZATION_PROFILES
	where party_id = p_organization_id
	AND sysdate between effective_start_date and nvl(effective_end_date,sysdate);

 l_debug_prefix              VARCHAR2(30) := '';
 l_prof_id number;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organization_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	open c1;
	fetch c1 into x_organization_obj;
	close c1;

	HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => p_organization_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => NULL, --p_action_type,
		 x_orig_sys_ref_objs => x_organization_obj.orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	open get_profile_id_csr;
	fetch  get_profile_id_csr into l_prof_id;
	close  get_profile_id_csr;

	hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_ext_object_id => l_prof_id,
    		 p_ext_object_name => 'HZ_ORGANIZATION_PROFILES',
		 p_action_type => p_action_type,
		 x_ext_attribute_objs => x_organization_obj.ext_attributes_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PARTY_SITE_BO_PVT.get_party_site_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_party_id => p_organization_id,
	         p_party_site_id => NULL,
		 p_action_type => p_action_type,
		 x_party_site_objs => x_organization_obj.party_site_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PARTY_USAGE_BO_PVT.get_party_usage_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => p_organization_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_party_usage_objs => x_organization_obj.party_usage_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_ORG_CONT_BO_PVT.get_org_contact_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_organization_id => p_organization_id,
		 p_action_type => p_action_type,
		  x_org_contact_objs => x_organization_obj.contact_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	get_financial_report_bos(p_init_msg_list => fnd_api.g_false,
		 p_organization_id => p_organization_id,
		 p_action_type => p_action_type,
		  x_financial_report_objs => x_organization_obj.financial_report_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);


	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	hz_extract_cont_point_bo_pvt.get_phone_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_phone_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_phone_objs  => x_organization_obj.phone_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	hz_extract_cont_point_bo_pvt.get_telex_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_telex_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_telex_objs  => x_organization_obj.telex_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	hz_extract_cont_point_bo_pvt.get_email_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_email_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_email_objs  => x_organization_obj.email_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	hz_extract_cont_point_bo_pvt.get_web_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_web_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_web_objs  => x_organization_obj.web_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	hz_extract_cont_point_bo_pvt.get_edi_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_edi_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_edi_objs  => x_organization_obj.edi_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	hz_extract_cont_point_bo_pvt.get_eft_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_eft_id => null,
		 p_parent_id => p_organization_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_eft_objs  => x_organization_obj.eft_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	HZ_EXTRACT_RELATIONSHIP_BO_PVT.get_relationship_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_subject_id => p_organization_id,
		 p_action_type => p_action_type,
		 x_relationship_objs =>  x_organization_obj.relationship_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	hz_extract_cont_point_bo_pvt.get_cont_pref_objs
		(p_init_msg_list => fnd_api.g_false,
		 p_cont_level_table_id  => p_organization_id,
	         p_cont_level_table  => 'HZ_PARTIES',
		 p_contact_type   => NULL,
		 p_action_type => p_action_type,
		 x_cont_pref_objs => x_organization_obj.contact_pref_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;





 --------------------------------------
  --
  -- PROCEDURE get_organizations_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations created business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005    AWU                Created.
  --



/*
The Get Organizations Created procedure is a service to retrieve all of the Organization business objects
whose creations have been captured by a logical business event. Each Organizations Created
business event signifies that one or more Organization business objects have been created.
The caller provides an identifier for the Organizations Created business event and the procedure
returns all of the Organization business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORGANIZATION_BO_PVT.get_organization_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_organizations_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organization_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


  	x_organization_objs := HZ_ORGANIZATION_BO_TBL();

	for i in 1..l_obj_root_ids.count loop
		x_organization_objs.extend;
		get_organization_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_organization_id  => l_obj_root_ids(i),
    		p_action_type => 'CREATED',
    		x_organization_obj  => x_organization_objs(i),
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);
  	end loop;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organization_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organization_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;





--------------------------------------
  --
  -- PROCEDURE get_organizations_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005     AWU                Created.
  --



/*
The Get Organizations Updated procedure is a service to retrieve all of the Organization business objects whose updates
have been captured by the logical business event. Each Organizations Updated business event signifies that one or more
Organization business objects have been updated.
The caller provides an identifier for the Organizations Update business event and the procedure returns database objects
of the type HZ_ORGANIZATION_BO for all of the Organization business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and
returns them to the caller.
*/

 PROCEDURE get_organizations_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organizations_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	-- call event API get_organization_updated for each id.

	x_organization_objs := HZ_ORGANIZATION_BO_TBL();

	for i in 1..l_obj_root_ids.count loop
		x_organization_objs.extend;
		get_organization_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		p_organization_id  => l_obj_root_ids(i),
    		x_organization_obj  => x_organization_objs(i),
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
  	end loop;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organizations_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

procedure set_orgcnt_site_bo_action_type(p_node_path		  IN       VARCHAR2,
				    p_child_id  IN NUMBER,
				    p_action_type IN VARCHAR2,
				    p_child_entity_name IN VARCHAR2,
				    p_child_bo_code IN VARCHAR2,
				    px_party_site_obj IN OUT NOCOPY HZ_PARTY_SITE_BO) is

l_child_upd_flag varchar2(1);

begin

		if p_child_entity_name = 'HZ_PARTY_SITES'
		then
		    if px_party_site_obj.party_site_id = p_child_id
		    then
			px_party_site_obj.action_type := p_action_type;
			l_child_upd_flag := 'N';
			if p_action_type = 'CREATED'
			then
				px_party_site_obj.location_obj.action_type :='CREATED';
	       			l_child_upd_flag := 'Y';
			end if;


 		    end if;
		end if;


		if p_child_entity_name = 'HZ_LOCATIONS'
		then
			if px_party_site_obj.location_obj.location_id = p_child_id and p_action_type = 'UPDATED'
			then px_party_site_obj.location_obj.action_type := p_action_type;
			     l_child_upd_flag := 'Y';
			end if;
		end if;

		if p_child_entity_name = 'HZ_CONTACT_POINTS'
		then
			if p_child_bo_code = 'EMAIL'
			then
			for j in 1..px_party_site_obj.EMAIL_OBJS.COUNT
			loop
				if px_party_site_obj.EMAIL_OBJS(j).email_id = p_child_id
				then px_party_site_obj.EMAIL_OBJS(j).action_type := p_action_type;
				     l_child_upd_flag := 'Y';
				end if;
			end loop;
			elsif p_child_bo_code = 'PHONE'
			then
				for j in 1..px_party_site_obj.PHONE_OBJS.COUNT
				loop
					if px_party_site_obj.PHONE_OBJS(j).phone_id = p_child_id
					then px_party_site_obj.PHONE_OBJS(j).action_type := p_action_type;
	     				     l_child_upd_flag := 'Y';
					end if;
				end loop;
			elsif p_child_bo_code = 'WEB'
			then
				for j in 1..px_party_site_obj.WEB_OBJS.COUNT
				loop
					if px_party_site_obj.WEB_OBJS(j).web_id = p_child_id
					then px_party_site_obj.WEB_OBJS(j).action_type := p_action_type;
	     				     l_child_upd_flag := 'Y';
					end if;
				end loop;
			elsif p_child_bo_code = 'TLX'
			then
				for j in 1..px_party_site_obj.TELEX_OBJS.COUNT
				loop
					if px_party_site_obj.TELEX_OBJS(j).telex_id = p_child_id
					then px_party_site_obj.TELEX_OBJS(j).action_type := p_action_type;
	     				     l_child_upd_flag := 'Y';
					end if;
				end loop;
				end if;
			end if;	--'HZ_CONTACT_POINTS'
			if p_child_entity_name = 'HZ_CONTACT_PREFERENCES' then
				for j in 1..px_party_site_obj.CONTACT_PREF_OBJS.count
				loop
					if px_party_site_obj.CONTACT_PREF_OBJS(j).contact_preference_id = p_child_id
					then px_party_site_obj.CONTACT_PREF_OBJS(j).action_type := p_action_type;
	     				     l_child_upd_flag := 'Y';
					end if;
				end loop;
			end if;

		if px_party_site_obj.action_type =  'UNCHANGED'  and l_child_upd_flag =  'Y'
		then
			px_party_site_obj.action_type := 'CHILD_UPDATED';
		end if;
end set_orgcnt_site_bo_action_type;


-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'

procedure set_org_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_org_obj IN OUT NOCOPY HZ_ORGANIZATION_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2) is
	cursor c1 is

	   SELECT
  		sys_connect_by_path(CHILD_BO_CODE, '/') node_path,
  		CHILD_OPERATION_FLAG,
  		CHILD_BO_CODE,
  		CHILD_ENTITY_NAME,
  		CHILD_ID,
  		populated_flag
	   FROM HZ_BUS_OBJ_TRACKING
	   where event_id = p_event_id
	   	START WITH child_id = p_root_id
	   	and child_entity_name = 'HZ_PARTIES'
   	   	AND  PARENT_BO_CODE IS NULL
   	   	AND CHILD_BO_CODE = 'ORG' --(or ORG, PERSON_CUST, ORG_CUST).
		and event_id = p_event_id
	   CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
    	  	AND PARENT_ID = PRIOR CHILD_ID
    	  	AND parent_bo_code = PRIOR child_bo_code
		and event_id = PRIOR event_id;


	cursor c2 is
    	   select CHILD_ENTITY_NAME
	    FROM HZ_BUS_OBJ_TRACKING
	    where event_id = p_event_id
	    and populated_flag = 'N'
	    and CHILD_ENTITY_NAME = 'HZ_ORGANIZATION_PROFILES';

L_CHILD_OPERATION_FLAG VARCHAR2(1);
L_CHILD_BO_CODE VARCHAR2(30);
L_CHILD_ENTITY_NAME  VARCHAR2(30);
L_CHILD_ID NUMBER;
l_action_type varchar2(30);
l_node_path varchar2(2000);
l_populated_flag varchar2(1);
l_child_upd_flag varchar2(1);

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Solve populate_flag is not in sync in hz_parties and hz_org_profiles.
        -- c1 can't return profile entity.

	open c2;
        fetch c2 into L_CHILD_ENTITY_NAME;
	close c2;

	if l_child_entity_name =  'HZ_ORGANIZATION_PROFILES'
	then
		px_org_obj.action_type := 'UPDATED';
	else px_org_obj.action_type := 'CHILD_UPDATED';
	end if;

	open c1;
	loop
		fetch c1 into L_NODE_PATH, L_CHILD_OPERATION_FLAG,L_CHILD_BO_CODE,
			L_CHILD_ENTITY_NAME, L_CHILD_ID, l_populated_flag;
		exit when c1%NOTFOUND;
		if l_child_entity_name =  'HZ_ORGANIZATION_PROFILES'
		then
			px_org_obj.action_type := 'UPDATED';
		end if;
 	   if l_populated_flag = 'N'
	   then
		if L_CHILD_OPERATION_FLAG = 'I'
		then l_action_type := 'CREATED';
		elsif  L_CHILD_OPERATION_FLAG = 'U'
		then l_action_type := 'UPDATED';
		end if;


		-- check first level entity objects

	        if l_child_entity_name = 'HZ_FINANCIAL_REPORTS' then
			for i in 1..PX_ORG_OBJ.FINANCIAL_REPORT_OBJS.COUNT
			loop
				if PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).FINANCIAL_REPORT_ID = l_child_id
				then PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
		elsif l_child_entity_name = 'HZ_PARTY_USG_ASSIGNMENTS' then
			for i in 1..PX_ORG_OBJ.PARTY_USAGE_OBJS .COUNT
			loop
				if PX_ORG_OBJ.PARTY_USAGE_OBJS(i).party_usg_assignment_id = l_child_id
				then PX_ORG_OBJ.PARTY_USAGE_OBJS(i).action_type := l_action_type;
				     l_child_upd_flag := 'Y';
				end if;
			end loop;

       		elsif l_child_entity_name = 'HZ_RELATIONSHIPS' then
			for i in 1..PX_ORG_OBJ.RELATIONSHIP_OBJS .COUNT
			loop
				if PX_ORG_OBJ.RELATIONSHIP_OBJS(i).relationship_id = l_child_id
				then PX_ORG_OBJ.RELATIONSHIP_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_CERTIFICATIONS' then
			for i in 1..PX_ORG_OBJ.CERTIFICATION_OBJS .COUNT
			loop
				if PX_ORG_OBJ.CERTIFICATION_OBJS(i).certification_id = l_child_id
				then PX_ORG_OBJ.CERTIFICATION_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_CREDIT_RATINGS' then
			for i in 1..PX_ORG_OBJ.CREDIT_RATING_OBJS.COUNT
			loop
				if PX_ORG_OBJ.CREDIT_RATING_OBJS(i).CREDIT_RATING_ID = l_child_id
				then PX_ORG_OBJ.CREDIT_RATING_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;

       		elsif l_child_entity_name = 'HZ_CODE_ASSIGNMENTS' then
			for i in 1..PX_ORG_OBJ.CLASS_OBJS .COUNT
			loop
				if PX_ORG_OBJ.CLASS_OBJS(i).code_assignment_id = l_child_id
				then PX_ORG_OBJ.CLASS_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_FINANCIAL_PROFILE' then
			for i in 1..PX_ORG_OBJ.FINANCIAL_PROF_OBJS .COUNT
			loop
				if PX_ORG_OBJ.FINANCIAL_PROF_OBJS(i).financial_profile_id = l_child_id
				then PX_ORG_OBJ.FINANCIAL_PROF_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_PARTY_PREFERENCES' then
			for i in 1..PX_ORG_OBJ.PREFERENCE_OBJS .COUNT
			loop
				if PX_ORG_OBJ.PREFERENCE_OBJS(i).party_preference_id = l_child_id
				then PX_ORG_OBJ.PREFERENCE_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;

		elsif l_child_entity_name = 'HZ_ORG_PROFILES_EXT_VL' then
			for i in 1..PX_ORG_OBJ.EXT_ATTRIBUTES_OBJS .COUNT
			loop
				if PX_ORG_OBJ.EXT_ATTRIBUTES_OBJS(i).extension_id = l_child_id
				then PX_ORG_OBJ.EXT_ATTRIBUTES_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;

		-- contact preference might have multiple parents, but one id will not belong to
                -- more than one parents
       		elsif l_child_entity_name = 'HZ_CONTACT_PREFERENCES' then
			l_child_upd_flag := 'Y';

			for i in 1..PX_ORG_OBJ.CONTACT_PREF_OBJS .COUNT
			loop
				if PX_ORG_OBJ.CONTACT_PREF_OBJS(i).contact_preference_id = l_child_id
				then PX_ORG_OBJ.CONTACT_PREF_OBJS(i).action_type := l_action_type;
				end if;
			end loop;
			if instr(l_node_path, 'ORG/PHONE') > 0 then
		        	for i in 1..PX_ORG_OBJ.PHONE_OBJS.COUNT
				loop
					for j in 1..PX_ORG_OBJ.PHONE_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.phone_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.phone_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;
						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'ORG/EMAIL') > 0 then
				for i in 1..PX_ORG_OBJ.EMAIL_OBJS.COUNT
				loop
					for j in 1..PX_ORG_OBJ.EMAIL_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.email_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.email_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'ORG/WEB') > 0 then
				for i in 1..PX_ORG_OBJ.WEB_OBJS.COUNT
				loop
					for j in 1..PX_ORG_OBJ.WEB_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.web_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.web_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;

			if instr(l_node_path, 'ORG/EDI') > 0 then

				for i in 1..PX_ORG_OBJ.EDI_OBJS.COUNT
				loop
					for j in 1..PX_ORG_OBJ.EDI_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.edi_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.edi_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;

			if instr(l_node_path, 'ORG/TLX') > 0 then
				for i in 1..PX_ORG_OBJ.TELEX_OBJS.COUNT
				loop
				  for j in 1..PX_ORG_OBJ.TELEX_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.telex_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.telex_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'ORG/EFT') > 0 then
				for i in 1..PX_ORG_OBJ.EFT_OBJS.COUNT
				loop
					for j in 1..PX_ORG_OBJ.EFT_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.eft_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.eft_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;


		elsif l_child_entity_name = 'HZ_CONTACT_POINTS' then
			if l_child_bo_code = 'EMAIL'
			then
				for i in 1..PX_ORG_OBJ.EMAIL_OBJS.COUNT
				loop
					if PX_ORG_OBJ.EMAIL_OBJS(i).email_id = l_child_id
					then PX_ORG_OBJ.EMAIL_OBJS(i).action_type := l_action_type;
					end if;
				end loop;
	  			l_child_upd_flag := 'Y';
			elsif l_child_bo_code = 'PHONE'
			then
				for i in 1..PX_ORG_OBJ.PHONE_OBJS.COUNT
				loop
					if PX_ORG_OBJ.PHONE_OBJS(i).phone_id = l_child_id
					then PX_ORG_OBJ.PHONE_OBJS(i).action_type := l_action_type;
					end if;
				end loop;
				l_child_upd_flag := 'Y';
			elsif l_child_bo_code = 'WEB'
			then
				for i in 1..PX_ORG_OBJ.WEB_OBJS.COUNT
				loop
					if PX_ORG_OBJ.WEB_OBJS(i).web_id = l_child_id
					then PX_ORG_OBJ.WEB_OBJS(i).action_type := l_action_type;

					end if;
				end loop;
  				l_child_upd_flag := 'Y';
			elsif l_child_bo_code = 'EDI'
			then
				for i in 1..PX_ORG_OBJ.EDI_OBJS.COUNT
				loop
					if PX_ORG_OBJ.EDI_OBJS(i).edi_id = l_child_id
					then PX_ORG_OBJ.EDI_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';

					end if;
				end loop;

			elsif l_child_bo_code = 'TLX'
			then
				for i in 1..PX_ORG_OBJ.TELEX_OBJS.COUNT
				loop
					if PX_ORG_OBJ.TELEX_OBJS(i).telex_id = l_child_id
					then PX_ORG_OBJ.TELEX_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';

					end if;
				end loop;

			elsif l_child_bo_code = 'EFT'
			then
				for i in 1..PX_ORG_OBJ.EFT_OBJS.COUNT
				loop
					if PX_ORG_OBJ.EFT_OBJS(i).eft_id = l_child_id
					then PX_ORG_OBJ.EFT_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
					end if;
				end loop;

			end if;
		end if; -- if l_child_entity_name = 'HZ_CONTACT_PREFERENCES'

		-- check party site object

		if instr(l_node_path, 'ORG/PARTY_SITE') > 0
		then


			for i in 1..PX_ORG_OBJ.PARTY_SITE_OBJS.COUNT
			loop
				-- check root level
				if l_child_entity_name = 'HZ_PARTY_SITES'
				then
				   if px_org_obj.party_site_objs(i).party_site_id = l_child_id
				   then
				     px_org_obj.party_site_objs(i).action_type := l_action_type;
				     l_child_upd_flag := 'N';
				     if l_action_type = 'CREATED'
				     then
				        px_org_obj.party_site_objs(i).location_obj.action_type :='CREATED';
					l_child_upd_flag := 'Y';
	                 	     end if;

				   end if;

				end if;

				-- check second level

				if l_child_entity_name = 'HZ_LOCATIONS'
				then
					if px_org_obj.party_site_objs(i).location_obj.location_id = l_child_id and l_action_type = 'UPDATED'
					then px_org_obj.party_site_objs(i).location_obj.action_type := l_action_type;					   	l_child_upd_flag := 'Y';
					end if;
				end if;
				if l_child_entity_name = 'HZ_CONTACT_POINTS'
				then
				  if l_child_bo_code = 'EMAIL'
				  then
					for j in 1..px_org_obj.party_site_objs(i).EMAIL_OBJS.COUNT
					loop
						if px_org_obj.party_site_objs(i).EMAIL_OBJS(j).email_id = l_child_id
						then px_org_obj.party_site_objs(i).EMAIL_OBJS(j).action_type := l_action_type;
						l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'PHONE'
				  then
					for j in 1..px_org_obj.party_site_objs(i).PHONE_OBJS.COUNT
					loop
						if px_org_obj.party_site_objs(i).PHONE_OBJS(j).phone_id = l_child_id
						then px_org_obj.party_site_objs(i).PHONE_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'WEB'
				  then
					for j in 1..px_org_obj.party_site_objs(i).WEB_OBJS.COUNT
					loop
						if px_org_obj.party_site_objs(i).WEB_OBJS(j).web_id = l_child_id
						then px_org_obj.party_site_objs(i).WEB_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
				elsif l_child_bo_code = 'TLX'
				then
					for j in 1..px_org_obj.party_site_objs(i).TELEX_OBJS.COUNT
					loop
						if px_org_obj.party_site_objs(i).TELEX_OBJS(j).telex_id = l_child_id
						then px_org_obj.party_site_objs(i).TELEX_OBJS(j).action_type := l_action_type;
						l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
			end if;	--'HZ_CONTACT_POINTS'
			if l_child_entity_name = 'HZ_CONTACT_PREFERENCES' then
					for j in 1..PX_ORG_OBJ.PARTY_SITE_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_org_obj.party_site_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_org_obj.party_site_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;
						l_child_upd_flag := 'Y';
						end if;
					end loop;
			end if;
					if l_child_entity_name = 'HZ_PARTY_SITE_USES' then
					for j in 1..PX_ORG_OBJ.PARTY_SITE_OBJS(i).PARTY_SITE_USE_OBJS.count
					loop
						if px_org_obj.party_site_objs(i).PARTY_SITE_USE_OBJS(j).party_site_use_id = l_child_id
						then px_org_obj.party_site_objs(i).PARTY_SITE_USE_OBJS(j).action_type := l_action_type;

						l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
				if  px_org_obj.party_site_objs(i).action_type =  'UNCHANGED'
				    and l_child_upd_flag = 'Y'
				then
				    px_org_obj.party_site_objs(i).action_type := 'CHILD_UPDATED';
			        end if;

			end loop; -- party_site_obj
		end if;  -- party_site_obj

		-- check fin report object

		if instr(l_node_path, 'ORG/FIN_REPORT') > 0
		then
			for i in 1..PX_ORG_OBJ.FINANCIAL_REPORT_OBJS.COUNT
			loop
				-- check root level
				if l_child_entity_name = 'HZ_FINANCIAL_REPORTS'
				then
				   if px_org_obj.FINANCIAL_REPORT_OBJS(i).FINANCIAL_REPORT_ID = l_child_id
                                   then
				     px_org_obj.FINANCIAL_REPORT_OBJS(i).action_type := l_action_type;
				     l_child_upd_flag := 'N';
				   end if;
				end if;

				-- check second level

				if l_child_entity_name = 'HZ_FINANCIAL_NUMBERS'
				then
					for j in 1..PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).FINANCIAL_NUMBER_OBJS.COUNT
					loop
						if PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).FINANCIAL_NUMBER_OBJS(j).FINANCIAL_NUMBER_ID = l_child_id
						then PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).FINANCIAL_NUMBER_OBJS(j).action_type := l_action_type;
						 l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
				if PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).action_type =  'UNCHANGED'  and l_child_upd_flag = 'Y'
				then
				   PX_ORG_OBJ.FINANCIAL_REPORT_OBJS(i).action_type :=  'CHILD_UPDATED';
				end if;
			end loop;
		end if; -- fin report

		-- check org contact object

		if instr(l_node_path, 'ORG/ORG_CONTACT') > 0
		then
			for i in 1..PX_ORG_OBJ.CONTACT_OBJS.COUNT
			loop
				-- check root level
				if l_child_entity_name = 'HZ_ORG_CONTACTS'
				then
				    if px_org_obj.contact_objs(i).org_contact_id = l_child_id
				    then
				      px_org_obj.contact_objs(i).action_type := l_action_type;
				      l_child_upd_flag := 'N';
				    end if;
				end if;

				-- check second level

				if l_child_entity_name = 'HZ_PERSON_PROFILES'
				then
					if px_org_obj.contact_objs(i).PERSON_PROFILE_OBJ.person_id = l_child_id
					then px_org_obj.contact_objs(i).PERSON_PROFILE_OBJ.action_type := l_action_type;
					      l_child_upd_flag := 'Y';
					end if;
				end if;
				if l_child_entity_name = 'HZ_CONTACT_POINTS'
				then
				  if l_child_bo_code = 'EMAIL'
				  then
					for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).EMAIL_OBJS.COUNT
					loop
						if PX_ORG_OBJ.CONTACT_OBJS(i).EMAIL_OBJS(j).email_id = l_child_id
						then PX_ORG_OBJ.CONTACT_OBJS(i).EMAIL_OBJS(j).action_type := l_action_type;
						      l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'PHONE'
				  then
					for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).PHONE_OBJS.COUNT
					loop
						if PX_ORG_OBJ.CONTACT_OBJS(i).PHONE_OBJS(j).phone_id = l_child_id
						then PX_ORG_OBJ.CONTACT_OBJS(i).PHONE_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'WEB'
				  then
					for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).WEB_OBJS.COUNT
					loop
						if PX_ORG_OBJ.CONTACT_OBJS(i).WEB_OBJS(j).web_id = l_child_id
						then PX_ORG_OBJ.CONTACT_OBJS(i).WEB_OBJS(j).action_type := l_action_type;
						      l_child_upd_flag := 'Y';
						end if;
					end loop;
				elsif l_child_bo_code = 'TLX'
				then
					for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).TELEX_OBJS.COUNT
					loop
						if PX_ORG_OBJ.CONTACT_OBJS(i).TELEX_OBJS(j).telex_id = l_child_id
						then PX_ORG_OBJ.CONTACT_OBJS(i).TELEX_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
			end if;	--'HZ_CONTACT_POINTS'
			if l_child_entity_name = 'HZ_CONTACT_PREFERENCES' then
					for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if PX_ORG_OBJ.CONTACT_OBJS(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then PX_ORG_OBJ.CONTACT_OBJS(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
			end if;
			if l_child_entity_name = 'HZ_ORG_CONTACT_ROLES' then
				for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).ORG_CONTACT_ROLE_OBJS.count
				loop
					if PX_ORG_OBJ.CONTACT_OBJS(i).ORG_CONTACT_ROLE_OBJS(j).ORG_CONTACT_ROLE_ID = l_child_id
					then PX_ORG_OBJ.CONTACT_OBJS(i).ORG_CONTACT_ROLE_OBJS(j).action_type := l_action_type;
					     l_child_upd_flag := 'Y';
					end if;
				end loop;
			end if;
			if l_child_entity_name in ('HZ_PARTY_SITES','HZ_LOCATIONS','HZ_CONTACT_POINTS','HZ_CONTACT_PREFERENCES','HZ_PARTY_SITE_USES') then
				for j in 1..PX_ORG_OBJ.CONTACT_OBJS(i).PARTY_SITE_OBJS.count
				loop
					set_orgcnt_site_bo_action_type(p_node_path	=> l_node_path,
				    		p_child_id => l_child_id,
				    		p_action_type => l_action_type,
				    		p_child_entity_name => l_child_entity_name,
						p_child_bo_code => l_child_bo_code,
				    		px_party_site_obj => PX_ORG_OBJ.CONTACT_OBJS(i).party_site_objs(j) );
					l_child_upd_flag := 'Y';
				end loop;
			end if; -- org contact site obj
			if  PX_ORG_OBJ.CONTACT_OBJS(i).action_type =  'UNCHANGED'
			    and l_child_upd_flag = 'Y'
			then PX_ORG_OBJ.CONTACT_OBJS(i).action_type := 'CHILD_UPDATED';
			end if;
		   end loop;
		end if;  -- org contact_obj
	   end if; -- populated_flag = 'N'
	end loop;
	close c1;

EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;


WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

end set_org_bo_action_type;



--------------------------------------
  --
  -- PROCEDURE get_organization_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and organization id
  --the procedure returns one database object of the type HZ_ORGANIZATION_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005     AWU                Created.
  --

PROCEDURE get_organization_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
l_organization_obj HZ_ORGANIZATION_BO;

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organizations_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;
/*   moved to public api
	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_organization_id,
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;
*/
	-- Set action type to 'UNCHANGED' by default

	get_organization_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_organization_id  => p_organization_id,
    		p_action_type => 'UNCHANGED',
    		x_organization_obj  => x_organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'


	l_organization_obj := x_organization_obj;
	set_org_bo_action_type(p_event_id  => p_event_id,
				p_root_id     => p_organization_id,
				px_org_obj => l_organization_obj,
				x_return_status => x_return_status
				);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	x_organization_obj := l_organization_obj;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_organizations_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;





END HZ_EXTRACT_ORGANIZATION_BO_PVT;

/
