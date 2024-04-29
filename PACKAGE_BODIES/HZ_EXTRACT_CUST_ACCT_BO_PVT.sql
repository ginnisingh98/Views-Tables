--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_CUST_ACCT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_CUST_ACCT_BO_PVT" AS
/*$Header: ARHECAVB.pls 120.9 2008/02/06 10:04:40 vsegu ship $ */
/*
 * This package contains the private APIs for logical customer account.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf customer account Get APIs
 */

-- Private local procedure
 PROCEDURE get_cust_acct_relate_objs(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_relate_objs    OUT NOCOPY    HZ_CUST_ACCT_RELATE_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

CURSOR C1 IS
	SELECT HZ_CUST_ACCT_RELATE_OBJ (
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CUST_ACCOUNT_ID,
		RELATED_CUST_ACCOUNT_ID,
		NULL, --RELATED_CUST_ACCOUNT_OS,
		NULL, --RELATED_CUST_ACCOUNT_OSR,
		RELATIONSHIP_TYPE,
		COMMENTS,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		CUSTOMER_RECIPROCAL_FLAG,
		STATUS,
		BILL_TO_FLAG,
		SHIP_TO_FLAG,
		ORG_ID,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
			CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
		OWNER_TABLE_ID,
		STATUS,
		REASON_CODE,
		OLD_ORIG_SYSTEM_REFERENCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20)
		FROM HZ_ORIG_SYS_REFERENCES
		WHERE
		OWNER_TABLE_ID = RELATED_CUST_ACCOUNT_ID
		AND OWNER_TABLE_NAME = 'HZ_CUST_ACCOUNTS'
		AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL))
	FROM HZ_CUST_ACCT_RELATE
	WHERE CUST_ACCOUNT_ID = P_CUST_ACCT_ID;

BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	open c1;
	fetch c1 bulk collect into x_cust_acct_relate_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_relate_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


-- Private local procedure
 PROCEDURE get_cust_profile_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_profile_obj    OUT NOCOPY    HZ_CUSTOMER_PROFILE_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

CURSOR C1 IS
	SELECT HZ_CUSTOMER_PROFILE_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CUST_ACCOUNT_PROFILE_ID,
		CUST_ACCOUNT_ID,
		STATUS,
		COLLECTOR_ID,
		CREDIT_ANALYST_ID,
		CREDIT_CHECKING,
		NEXT_CREDIT_REVIEW_DATE,
		TOLERANCE,
		DISCOUNT_TERMS,
		DUNNING_LETTERS,
		INTEREST_CHARGES,
		SEND_STATEMENTS,
		CREDIT_BALANCE_STATEMENTS,
		CREDIT_HOLD,
		PROFILE_CLASS_ID,
		SITE_USE_ID,
		CREDIT_RATING,
		RISK_CODE,
		STANDARD_TERMS,
		OVERRIDE_TERMS,
		DUNNING_LETTER_SET_ID,
		INTEREST_PERIOD_DAYS,
		PAYMENT_GRACE_DAYS,
		DISCOUNT_GRACE_DAYS,
		STATEMENT_CYCLE_ID,
		ACCOUNT_STATUS,
		PERCENT_COLLECTABLE,
		AUTOCASH_HIERARCHY_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		AUTO_REC_INCL_DISPUTED_FLAG,
		TAX_PRINTING_OPTION,
		CHARGE_ON_FINANCE_CHARGE_FLAG,
		GROUPING_RULE_ID,
		CLEARING_DAYS,
		JGZZ_ATTRIBUTE_CATEGORY,
		JGZZ_ATTRIBUTE1,
		JGZZ_ATTRIBUTE2,
		JGZZ_ATTRIBUTE3,
		JGZZ_ATTRIBUTE4,
		JGZZ_ATTRIBUTE5,
		JGZZ_ATTRIBUTE6,
		JGZZ_ATTRIBUTE7,
		JGZZ_ATTRIBUTE8,
		JGZZ_ATTRIBUTE9,
		JGZZ_ATTRIBUTE10,
		JGZZ_ATTRIBUTE11,
		JGZZ_ATTRIBUTE12,
		JGZZ_ATTRIBUTE13,
		JGZZ_ATTRIBUTE14,
		JGZZ_ATTRIBUTE15,
		GLOBAL_ATTRIBUTE1,
		GLOBAL_ATTRIBUTE2,
		GLOBAL_ATTRIBUTE3,
		GLOBAL_ATTRIBUTE4,
		GLOBAL_ATTRIBUTE5,
		GLOBAL_ATTRIBUTE6,
		GLOBAL_ATTRIBUTE7,
		GLOBAL_ATTRIBUTE8,
		GLOBAL_ATTRIBUTE9,
		GLOBAL_ATTRIBUTE10,
		GLOBAL_ATTRIBUTE11,
		GLOBAL_ATTRIBUTE12,
		GLOBAL_ATTRIBUTE13,
		GLOBAL_ATTRIBUTE14,
		GLOBAL_ATTRIBUTE15,
		GLOBAL_ATTRIBUTE16,
		GLOBAL_ATTRIBUTE17,
		GLOBAL_ATTRIBUTE18,
		GLOBAL_ATTRIBUTE19,
		GLOBAL_ATTRIBUTE20,
		GLOBAL_ATTRIBUTE_CATEGORY,
		CONS_INV_FLAG,
		CONS_INV_TYPE,
		AUTOCASH_HIERARCHY_ID_FOR_ADR,
		LOCKBOX_MATCHING_OPTION,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		REVIEW_CYCLE,
		LAST_CREDIT_REVIEW_DATE,
		CREDIT_CLASSIFICATION,
		CONS_BILL_LEVEL,
                LATE_CHARGE_CALCULATION_TRX,
                CREDIT_ITEMS_FLAG,
                DISPUTED_TRANSACTIONS_FLAG,
                LATE_CHARGE_TYPE,
                LATE_CHARGE_TERM_ID,
                INTEREST_CALCULATION_PERIOD,
                HOLD_CHARGED_INVOICES_FLAG,
                MESSAGE_TEXT_ID,
                MULTIPLE_INTEREST_RATES_FLAG,
                CHARGE_BEGIN_DATE,
	CAST(MULTISET (
	SELECT HZ_CUST_PROFILE_AMT_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CUST_ACCT_PROFILE_AMT_ID,
		CUST_ACCOUNT_PROFILE_ID,
		CURRENCY_CODE,
		TRX_CREDIT_LIMIT,
		OVERALL_CREDIT_LIMIT,
		MIN_DUNNING_AMOUNT,
		MIN_DUNNING_INVOICE_AMOUNT,
		MAX_INTEREST_CHARGE,
		MIN_STATEMENT_AMOUNT,
		AUTO_REC_MIN_RECEIPT_AMOUNT,
		INTEREST_RATE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		MIN_FC_BALANCE_AMOUNT,
		MIN_FC_INVOICE_AMOUNT,
		CUST_ACCOUNT_ID,
		SITE_USE_ID,
		EXPIRATION_DATE,
		JGZZ_ATTRIBUTE_CATEGORY,
		JGZZ_ATTRIBUTE1,
		JGZZ_ATTRIBUTE2,
		JGZZ_ATTRIBUTE3,
		JGZZ_ATTRIBUTE4,
		JGZZ_ATTRIBUTE5,
		JGZZ_ATTRIBUTE6,
		JGZZ_ATTRIBUTE7,
		JGZZ_ATTRIBUTE8,
		JGZZ_ATTRIBUTE9,
		JGZZ_ATTRIBUTE10,
		JGZZ_ATTRIBUTE11,
		JGZZ_ATTRIBUTE12,
		JGZZ_ATTRIBUTE13,
		JGZZ_ATTRIBUTE14,
		JGZZ_ATTRIBUTE15,
		GLOBAL_ATTRIBUTE1,
		GLOBAL_ATTRIBUTE2,
		GLOBAL_ATTRIBUTE3,
		GLOBAL_ATTRIBUTE4,
		GLOBAL_ATTRIBUTE5,
		GLOBAL_ATTRIBUTE6,
		GLOBAL_ATTRIBUTE7,
		GLOBAL_ATTRIBUTE8,
		GLOBAL_ATTRIBUTE9,
		GLOBAL_ATTRIBUTE10,
		GLOBAL_ATTRIBUTE11,
		GLOBAL_ATTRIBUTE12,
		GLOBAL_ATTRIBUTE13,
		GLOBAL_ATTRIBUTE14,
		GLOBAL_ATTRIBUTE15,
		GLOBAL_ATTRIBUTE16,
		GLOBAL_ATTRIBUTE17,
		GLOBAL_ATTRIBUTE18,
		GLOBAL_ATTRIBUTE19,
		GLOBAL_ATTRIBUTE20,
		GLOBAL_ATTRIBUTE_CATEGORY,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
                EXCHANGE_RATE_TYPE,
                MIN_FC_INVOICE_OVERDUE_TYPE,
                MIN_FC_INVOICE_PERCENT,
                MIN_FC_BALANCE_OVERDUE_TYPE,
                MIN_FC_BALANCE_PERCENT,
                INTEREST_TYPE,
                INTEREST_FIXED_AMOUNT,
                INTEREST_SCHEDULE_ID,
                PENALTY_TYPE,
                PENALTY_RATE,
                MIN_INTEREST_CHARGE,
                PENALTY_FIXED_AMOUNT,
                PENALTY_SCHEDULE_ID )
		FROM HZ_CUST_PROFILE_AMTS
		WHERE CUST_ACCOUNT_ID = P_CUST_ACCT_ID) AS HZ_CUST_PROFILE_AMT_OBJ_TBL))
	FROM HZ_CUSTOMER_PROFILES
	WHERE CUST_ACCOUNT_ID = P_CUST_ACCT_ID;


BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cust_profile_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	open c1;
	fetch c1 into x_cust_profile_obj;
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
        	hz_utility_v2pub.debug(p_message=>'get_cust_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_profile_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;





  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_obj         Logical customer account record.
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
  --   8-JUN-2005  AWU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure
returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_objs          OUT NOCOPY    HZ_CUST_ACCT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

CURSOR C1 IS
	SELECT  HZ_CUST_ACCT_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CA.CUST_ACCOUNT_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_CUST_ACCOUNTS',CA.PARTY_ID),
		CA.PARTY_ID,
		CA.ACCOUNT_NUMBER,
		CA.ATTRIBUTE_CATEGORY,
		CA.ATTRIBUTE1,
		CA.ATTRIBUTE2,
		CA.ATTRIBUTE3,
		CA.ATTRIBUTE4,
		CA.ATTRIBUTE5,
		CA.ATTRIBUTE6,
		CA.ATTRIBUTE7,
		CA.ATTRIBUTE8,
		CA.ATTRIBUTE9,
		CA.ATTRIBUTE10,
		CA.ATTRIBUTE11,
		CA.ATTRIBUTE12,
		CA.ATTRIBUTE13,
		CA.ATTRIBUTE14,
		CA.ATTRIBUTE15,
		CA.ATTRIBUTE16,
		CA.ATTRIBUTE17,
		CA.ATTRIBUTE18,
		CA.ATTRIBUTE19,
		CA.ATTRIBUTE20,
		CA.GLOBAL_ATTRIBUTE_CATEGORY,
		CA.GLOBAL_ATTRIBUTE1,
		CA.GLOBAL_ATTRIBUTE2,
		CA.GLOBAL_ATTRIBUTE3,
		CA.GLOBAL_ATTRIBUTE4,
		CA.GLOBAL_ATTRIBUTE5,
		CA.GLOBAL_ATTRIBUTE6,
		CA.GLOBAL_ATTRIBUTE7,
		CA.GLOBAL_ATTRIBUTE8,
		CA.GLOBAL_ATTRIBUTE9,
		CA.GLOBAL_ATTRIBUTE10,
		CA.GLOBAL_ATTRIBUTE11,
		CA.GLOBAL_ATTRIBUTE12,
		CA.GLOBAL_ATTRIBUTE13,
		CA.GLOBAL_ATTRIBUTE14,
		CA.GLOBAL_ATTRIBUTE15,
		CA.GLOBAL_ATTRIBUTE16,
		CA.GLOBAL_ATTRIBUTE17,
		CA.GLOBAL_ATTRIBUTE18,
		CA.GLOBAL_ATTRIBUTE19,
		CA.GLOBAL_ATTRIBUTE20,
		CA.STATUS,
		CA.CUSTOMER_TYPE,
		CA.CUSTOMER_CLASS_CODE,
		CA.PRIMARY_SALESREP_ID,
		CA.SALES_CHANNEL_CODE,
		CA.ORDER_TYPE_ID,
		CA.PRICE_LIST_ID,
		CA.TAX_CODE,
		CA.FOB_POINT,
		CA.FREIGHT_TERM,
		CA.SHIP_PARTIAL,
		CA.SHIP_VIA,
		CA.WAREHOUSE_ID,
		CA.TAX_HEADER_LEVEL_FLAG,
		CA.TAX_ROUNDING_RULE,
		CA.COTERMINATE_DAY_MONTH,
		CA.PRIMARY_SPECIALIST_ID,
		CA.SECONDARY_SPECIALIST_ID,
		CA.ACCOUNT_LIABLE_FLAG,
		CA.CURRENT_BALANCE,
		CA.ACCOUNT_ESTABLISHED_DATE,
		CA.ACCOUNT_TERMINATION_DATE,
		CA.ACCOUNT_ACTIVATION_DATE,
		CA.DEPARTMENT,
		CA.HELD_BILL_EXPIRATION_DATE,
		CA.HOLD_BILL_FLAG,
		CA.REALTIME_RATE_FLAG,
		CA.ACCT_LIFE_CYCLE_STATUS,
		CA.ACCOUNT_NAME,
		CA.DEPOSIT_REFUND_METHOD,
		CA.DORMANT_ACCOUNT_FLAG,
		CA.NPA_NUMBER,
		CA.SUSPENSION_DATE,
		CA.SOURCE_CODE,
		CA.COMMENTS,
		CA.DATES_NEGATIVE_TOLERANCE,
		CA.DATES_POSITIVE_TOLERANCE,
		CA.DATE_TYPE_PREFERENCE,
		CA.OVER_SHIPMENT_TOLERANCE,
		CA.UNDER_SHIPMENT_TOLERANCE,
		CA.OVER_RETURN_TOLERANCE,
		CA.UNDER_RETURN_TOLERANCE,
		CA.ITEM_CROSS_REF_PREF,
		CA.SHIP_SETS_INCLUDE_LINES_FLAG,
		CA.ARRIVALSETS_INCLUDE_LINES_FLAG,
		CA.SCHED_DATE_PUSH_FLAG,
		CA.INVOICE_QUANTITY_RULE,
		CA.PRICING_EVENT,
		CA.STATUS_UPDATE_DATE,
		CA.AUTOPAY_FLAG,
		CA.NOTIFY_FLAG,
		CA.LAST_BATCH_ID,
		CA.SELLING_PARTY_ID,
		CA.PROGRAM_UPDATE_DATE,
		CA.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CA.CREATED_BY),
		CA.CREATION_DATE,
		CA.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CA.LAST_UPDATED_BY),
	CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
		OWNER_TABLE_ID,
		STATUS,
		REASON_CODE,
		OLD_ORIG_SYSTEM_REFERENCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20)
		FROM HZ_ORIG_SYS_REFERENCES OSR
		WHERE
		OSR.OWNER_TABLE_ID = CA.CUST_ACCOUNT_ID
		AND OWNER_TABLE_NAME = 'HZ_CUST_ACCOUNTS'
		AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
		HZ_CUST_ACCT_RELATE_OBJ_TBL(),
		HZ_CUST_ACCT_SITE_BO_TBL(),
		HZ_CUST_ACCT_CONTACT_BO_TBL(),
		NULL, --CUST_PROFILE_OBJ,
	CAST(MULTISET (
	SELECT HZ_BANK_ACCT_USE_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		INSTR_ASSIGNMENT_ID, --BANK_ACCT_USE_ID,
		PAYMENT_FUNCTION,
		PARTY_ID,
		ORG_TYPE,
		ORG_ID,
		CUST_ACCOUNT_ID,
		ACCT_SITE_USE_ID,
		INSTRUMENT_ID,
		INSTRUMENT_TYPE,
		ORDER_OF_PREFERENCE,
		ASSIGNMENT_START_DATE,
		ASSIGNMENT_END_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		ASSIGNMENT_LAST_UPDATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM IBY_FNDCPT_PAYER_ASSGN_INSTR_V
	WHERE CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID) AS HZ_BANK_ACCT_USE_OBJ_TBL),
        (SELECT	 HZ_PAYMENT_METHOD_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CRM.CUST_RECEIPT_METHOD_ID, --PAYMENT_METHOD_ID,
		CRM.CUSTOMER_ID,
		CRM.RECEIPT_METHOD_ID,
		CRM.PRIMARY_FLAG,
		CRM.SITE_USE_ID,
		CRM.START_DATE,
		CRM.END_DATE,
		CRM.ATTRIBUTE_CATEGORY,
		CRM.ATTRIBUTE1,
		CRM.ATTRIBUTE2,
		CRM.ATTRIBUTE3,
		CRM.ATTRIBUTE4,
		CRM.ATTRIBUTE5,
		CRM.ATTRIBUTE6,
		CRM.ATTRIBUTE7,
		CRM.ATTRIBUTE8,
		CRM.ATTRIBUTE9,
		CRM.ATTRIBUTE10,
		CRM.ATTRIBUTE11,
		CRM.ATTRIBUTE12,
		CRM.ATTRIBUTE13,
		CRM.ATTRIBUTE14,
		CRM.ATTRIBUTE15,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CRM.CREATED_BY),
		CRM.CREATION_DATE,
		CRM.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CRM.LAST_UPDATED_BY))
        FROM RA_CUST_RECEIPT_METHODS CRM
        WHERE CA.CUST_ACCOUNT_ID = CRM.CUSTOMER_ID
        AND ROWNUM = 1)
	)
	FROM HZ_PARTIES P, HZ_CUST_ACCOUNTS CA
	WHERE P.PARTY_ID = CA.PARTY_ID
	AND ((P_CUST_ACCT_ID IS NULL AND P.PARTY_ID = P_PARENT_ID)
	OR (P_CUST_ACCT_ID IS NOT NULL AND CA.CUST_ACCOUNT_ID = P_CUST_ACCT_ID));


BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_cust_acct_objs := HZ_CUST_ACCT_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_cust_acct_objs;
	close c1;

	for i in 1..x_cust_acct_objs.count loop
		HZ_EXTRACT_ACCT_SITE_BO_PVT.get_cust_acct_site_bos(
    			p_init_msg_list  => fnd_api.g_false,
    			p_parent_id   => x_cust_acct_objs(i).cust_acct_id,
    			p_cust_acct_site_id  => NULL,
    			p_action_type  => p_action_type,
    			x_cust_acct_site_objs => x_cust_acct_objs(i).cust_acct_site_objs,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		HZ_EXTRACT_ACCT_CONT_BO_PVT.get_cust_acct_contact_bos(
    			p_init_msg_list  => fnd_api.g_false,
    			p_parent_id   => x_cust_acct_objs(i).cust_acct_id,
    			p_cust_acct_contact_id  => NULL,
    			p_action_type  => p_action_type,
    			x_cust_acct_contact_objs => x_cust_acct_objs(i).cust_acct_contact_objs,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;


		get_cust_profile_bo(
    			p_init_msg_list  => fnd_api.g_false,
    			p_cust_acct_id   => x_cust_acct_objs(i).cust_acct_id,
    			p_action_type  => p_action_type,
    			x_cust_profile_obj => x_cust_acct_objs(i).cust_profile_obj,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		get_cust_acct_relate_objs(
    			p_init_msg_list  => fnd_api.g_false,
    			p_cust_acct_id   => x_cust_acct_objs(i).cust_acct_id,
    			p_action_type  => p_action_type,
    			x_cust_acct_relate_objs => x_cust_acct_objs(i).acct_relate_objs,
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
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_v2_obj         Logical customer account record.
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
  --   1-FEB-2008  VSEGU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_v2_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure
returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_v2_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_v2_objs          OUT NOCOPY    HZ_CUST_ACCT_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

CURSOR C1 IS
	SELECT  HZ_CUST_ACCT_V2_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CA.CUST_ACCOUNT_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_CUST_ACCOUNTS',CA.PARTY_ID),
		CA.PARTY_ID,
		CA.ACCOUNT_NUMBER,
		CA.ATTRIBUTE_CATEGORY,
		CA.ATTRIBUTE1,
		CA.ATTRIBUTE2,
		CA.ATTRIBUTE3,
		CA.ATTRIBUTE4,
		CA.ATTRIBUTE5,
		CA.ATTRIBUTE6,
		CA.ATTRIBUTE7,
		CA.ATTRIBUTE8,
		CA.ATTRIBUTE9,
		CA.ATTRIBUTE10,
		CA.ATTRIBUTE11,
		CA.ATTRIBUTE12,
		CA.ATTRIBUTE13,
		CA.ATTRIBUTE14,
		CA.ATTRIBUTE15,
		CA.ATTRIBUTE16,
		CA.ATTRIBUTE17,
		CA.ATTRIBUTE18,
		CA.ATTRIBUTE19,
		CA.ATTRIBUTE20,
		CA.GLOBAL_ATTRIBUTE_CATEGORY,
		CA.GLOBAL_ATTRIBUTE1,
		CA.GLOBAL_ATTRIBUTE2,
		CA.GLOBAL_ATTRIBUTE3,
		CA.GLOBAL_ATTRIBUTE4,
		CA.GLOBAL_ATTRIBUTE5,
		CA.GLOBAL_ATTRIBUTE6,
		CA.GLOBAL_ATTRIBUTE7,
		CA.GLOBAL_ATTRIBUTE8,
		CA.GLOBAL_ATTRIBUTE9,
		CA.GLOBAL_ATTRIBUTE10,
		CA.GLOBAL_ATTRIBUTE11,
		CA.GLOBAL_ATTRIBUTE12,
		CA.GLOBAL_ATTRIBUTE13,
		CA.GLOBAL_ATTRIBUTE14,
		CA.GLOBAL_ATTRIBUTE15,
		CA.GLOBAL_ATTRIBUTE16,
		CA.GLOBAL_ATTRIBUTE17,
		CA.GLOBAL_ATTRIBUTE18,
		CA.GLOBAL_ATTRIBUTE19,
		CA.GLOBAL_ATTRIBUTE20,
		CA.STATUS,
		CA.CUSTOMER_TYPE,
		CA.CUSTOMER_CLASS_CODE,
		CA.PRIMARY_SALESREP_ID,
		CA.SALES_CHANNEL_CODE,
		CA.ORDER_TYPE_ID,
		CA.PRICE_LIST_ID,
		CA.TAX_CODE,
		CA.FOB_POINT,
		CA.FREIGHT_TERM,
		CA.SHIP_PARTIAL,
		CA.SHIP_VIA,
		CA.WAREHOUSE_ID,
		CA.TAX_HEADER_LEVEL_FLAG,
		CA.TAX_ROUNDING_RULE,
		CA.COTERMINATE_DAY_MONTH,
		CA.PRIMARY_SPECIALIST_ID,
		CA.SECONDARY_SPECIALIST_ID,
		CA.ACCOUNT_LIABLE_FLAG,
		CA.CURRENT_BALANCE,
		CA.ACCOUNT_ESTABLISHED_DATE,
		CA.ACCOUNT_TERMINATION_DATE,
		CA.ACCOUNT_ACTIVATION_DATE,
		CA.DEPARTMENT,
		CA.HELD_BILL_EXPIRATION_DATE,
		CA.HOLD_BILL_FLAG,
		CA.REALTIME_RATE_FLAG,
		CA.ACCT_LIFE_CYCLE_STATUS,
		CA.ACCOUNT_NAME,
		CA.DEPOSIT_REFUND_METHOD,
		CA.DORMANT_ACCOUNT_FLAG,
		CA.NPA_NUMBER,
		CA.SUSPENSION_DATE,
		CA.SOURCE_CODE,
		CA.COMMENTS,
		CA.DATES_NEGATIVE_TOLERANCE,
		CA.DATES_POSITIVE_TOLERANCE,
		CA.DATE_TYPE_PREFERENCE,
		CA.OVER_SHIPMENT_TOLERANCE,
		CA.UNDER_SHIPMENT_TOLERANCE,
		CA.OVER_RETURN_TOLERANCE,
		CA.UNDER_RETURN_TOLERANCE,
		CA.ITEM_CROSS_REF_PREF,
		CA.SHIP_SETS_INCLUDE_LINES_FLAG,
		CA.ARRIVALSETS_INCLUDE_LINES_FLAG,
		CA.SCHED_DATE_PUSH_FLAG,
		CA.INVOICE_QUANTITY_RULE,
		CA.PRICING_EVENT,
		CA.STATUS_UPDATE_DATE,
		CA.AUTOPAY_FLAG,
		CA.NOTIFY_FLAG,
		CA.LAST_BATCH_ID,
		CA.SELLING_PARTY_ID,
		CA.PROGRAM_UPDATE_DATE,
		CA.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CA.CREATED_BY),
		CA.CREATION_DATE,
		CA.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CA.LAST_UPDATED_BY),
	CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
		OWNER_TABLE_ID,
		STATUS,
		REASON_CODE,
		OLD_ORIG_SYSTEM_REFERENCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20)
		FROM HZ_ORIG_SYS_REFERENCES OSR
		WHERE
		OSR.OWNER_TABLE_ID = CA.CUST_ACCOUNT_ID
		AND OWNER_TABLE_NAME = 'HZ_CUST_ACCOUNTS'
		AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
		HZ_CUST_ACCT_RELATE_OBJ_TBL(),
		HZ_CUST_ACCT_SITE_V2_BO_TBL(),
		HZ_CUST_ACCT_CONTACT_BO_TBL(),
		NULL, --CUST_PROFILE_OBJ,
	CAST(MULTISET (
	SELECT HZ_BANK_ACCT_USE_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		INSTR_ASSIGNMENT_ID, --BANK_ACCT_USE_ID,
		PAYMENT_FUNCTION,
		PARTY_ID,
		ORG_TYPE,
		ORG_ID,
		CUST_ACCOUNT_ID,
		ACCT_SITE_USE_ID,
		INSTRUMENT_ID,
		INSTRUMENT_TYPE,
		ORDER_OF_PREFERENCE,
		ASSIGNMENT_START_DATE,
		ASSIGNMENT_END_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		ASSIGNMENT_LAST_UPDATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM IBY_FNDCPT_PAYER_ASSGN_INSTR_V
	WHERE CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID) AS HZ_BANK_ACCT_USE_OBJ_TBL),
	CAST( MULTISET ( SELECT HZ_PAYMENT_METHOD_OBJ(
		P_ACTION_TYPE,
            NULL, -- COMMON_OBJ_ID
		CRM.CUST_RECEIPT_METHOD_ID, --PAYMENT_METHOD_ID,
		CRM.CUSTOMER_ID,
		CRM.RECEIPT_METHOD_ID,
		CRM.PRIMARY_FLAG,
		CRM.SITE_USE_ID,
		CRM.START_DATE,
		CRM.END_DATE,
		CRM.ATTRIBUTE_CATEGORY,
		CRM.ATTRIBUTE1,
		CRM.ATTRIBUTE2,
		CRM.ATTRIBUTE3,
		CRM.ATTRIBUTE4,
		CRM.ATTRIBUTE5,
		CRM.ATTRIBUTE6,
		CRM.ATTRIBUTE7,
		CRM.ATTRIBUTE8,
		CRM.ATTRIBUTE9,
		CRM.ATTRIBUTE10,
		CRM.ATTRIBUTE11,
		CRM.ATTRIBUTE12,
		CRM.ATTRIBUTE13,
		CRM.ATTRIBUTE14,
		CRM.ATTRIBUTE15,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CRM.CREATED_BY),
		CRM.CREATION_DATE,
		CRM.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CRM.LAST_UPDATED_BY))
      FROM RA_CUST_RECEIPT_METHODS CRM
      WHERE CA.CUST_ACCOUNT_ID = CRM.CUSTOMER_ID ) AS HZ_PAYMENT_METHOD_OBJ_TBL )
      )
	FROM HZ_PARTIES P, HZ_CUST_ACCOUNTS CA
	WHERE P.PARTY_ID = CA.PARTY_ID
	AND ((P_CUST_ACCT_ID IS NULL AND P.PARTY_ID = P_PARENT_ID)
	OR (P_CUST_ACCT_ID IS NOT NULL AND CA.CUST_ACCOUNT_ID = P_CUST_ACCT_ID));


BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_v2_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_cust_acct_v2_objs := HZ_CUST_ACCT_V2_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_cust_acct_v2_objs;
	close c1;

	for i in 1..x_cust_acct_v2_objs.count loop
		HZ_EXTRACT_ACCT_SITE_BO_PVT.get_cust_acct_site_v2_bos(
    			p_init_msg_list  => fnd_api.g_false,
    			p_parent_id   => x_cust_acct_v2_objs(i).cust_acct_id,
    			p_cust_acct_site_id  => NULL,
    			p_action_type  => p_action_type,
    			x_cust_acct_site_v2_objs => x_cust_acct_v2_objs(i).cust_acct_site_objs,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		HZ_EXTRACT_ACCT_CONT_BO_PVT.get_cust_acct_contact_bos(
    			p_init_msg_list  => fnd_api.g_false,
    			p_parent_id   => x_cust_acct_v2_objs(i).cust_acct_id,
    			p_cust_acct_contact_id  => NULL,
    			p_action_type  => p_action_type,
    			x_cust_acct_contact_objs => x_cust_acct_v2_objs(i).cust_acct_contact_objs,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;


		get_cust_profile_bo(
    			p_init_msg_list  => fnd_api.g_false,
    			p_cust_acct_id   => x_cust_acct_v2_objs(i).cust_acct_id,
    			p_action_type  => p_action_type,
    			x_cust_profile_obj => x_cust_acct_v2_objs(i).cust_profile_obj,
 			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		get_cust_acct_relate_objs(
    			p_init_msg_list  => fnd_api.g_false,
    			p_cust_acct_id   => x_cust_acct_v2_objs(i).cust_acct_id,
    			p_action_type  => p_action_type,
    			x_cust_acct_relate_objs => x_cust_acct_v2_objs(i).acct_relate_objs,
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
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_v2_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_v2_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_v2_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_v2_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


END HZ_EXTRACT_CUST_ACCT_BO_PVT;

/
