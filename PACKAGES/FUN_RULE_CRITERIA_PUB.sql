--------------------------------------------------------
--  DDL for Package FUN_RULE_CRITERIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_CRITERIA_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRCTPUS.pls 120.1 2005/06/22 05:01:02 ammishra noship $ */
/*#
 * This package contains the public APIs for Rules Criteria.
 * @rep:scope internal
 * @rep:product FUN
 * @rep:displayname Rules Framework:Rules Criteria Definition
 * @rep:category BUSINESS_ENTITY FUN_RULE_CRITERIA
 * @rep:lifecycle active
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE rule_criteria_rec_type IS RECORD (
   criteria_id			FUN_RULE_CRITERIA.CRITERIA_ID%TYPE,
   rule_detail_id   		FUN_RULE_CRITERIA.RULE_DETAIL_ID%TYPE,
   criteria_param_id		FUN_RULE_CRITERIA.CRITERIA_PARAM_ID%TYPE,
   condition			FUN_RULE_CRITERIA.CONDITION%TYPE,
   param_value			FUN_RULE_CRITERIA.PARAM_VALUE%TYPE,
   case_sensitive_flag		FUN_RULE_CRITERIA.CASE_SENSITIVE_FLAG%TYPE,
   creation_date 		FUN_RULE_CRITERIA.CREATION_DATE%TYPE,
   created_by 			FUN_RULE_CRITERIA.CREATED_BY%TYPE,
   last_update_date 		FUN_RULE_CRITERIA.LAST_UPDATE_DATE%TYPE,
   last_updated_by 		FUN_RULE_CRITERIA.LAST_UPDATED_BY%TYPE,
   last_update_login 		FUN_RULE_CRITERIA.LAST_UPDATE_LOGIN%TYPE,
   created_by_module            FUN_RULE_CRITERIA.CREATED_BY_MODULE%TYPE
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_rule_criteria
 *
 * DESCRIPTION
 *     Creates criteria of each rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                  Initialize message stack if it is set to
 *                                      FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_criteria_rec              Rule Criteria record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                  Return status after the call. The status can
 *                                      be FND_API.G_RET_STS_SUCCESS (success),
 *                                      FND_API.G_RET_STS_ERROR (error),
 *                                      FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                      Number of messages in message stack.
 *     x_msg_data                       Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-Sep-2004    Amulya Mishra       Created.
 *
 */

/**
 * Use this routine to create a rule criteria and its related information.
 * With this API you can create a record in the FUN_RULE_CRITERIA table.
 * By defining a criteria for rule end users  can define their individual
 * criteria parametere object name, condition, param value, case sensitive
 * checking allowed or not etc.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Rule Criteria
 * @rep:businessevent oracle.apps.fun.rules.server.HACustomizableObjectEO.create
 * @rep:doccd
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_criteria_rec Rule Criteria record.
 * @param x_criteria_id      Internal identifier for the Rule Criteria
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created

 */

PROCEDURE create_rule_criteria(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_criteria_rec     		 IN      RULE_CRITERIA_REC_TYPE,
    x_criteria_id                        OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);


/**
 * Use this routine to update a Rule Criteria. The API updates records in the
 * FUN_RULE_CRITERIA table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Rule Criteria
 * @rep:businessevent
 * @rep:doccd
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_criteria_rec Rule Criteria record.
 * @param p_object_version_number Record version number
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */
PROCEDURE update_rule_criteria(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_criteria_rec    		 IN      RULE_CRITERIA_REC_TYPE,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
);


/**
 * Use this routine to Get a Rule Criteria Record. The API selects record from the
 * FUN_RULE_CRITERIA table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Retrieve Rule Criteria Record
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_criteria_id      Internal Indentifier for the Criteria.
 * @param p_rule_detail_id   Internal identifier for the Rule.
 * @param x_rule_criteria_rec Rule Criteria record.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */


PROCEDURE get_rule_criteria_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_criteria_id                   	    IN     NUMBER,
    p_rule_detail_id                        IN     NUMBER,
    x_rule_criteria_rec        		    OUT    NOCOPY RULE_CRITERIA_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * Use this routine to delete a Rule Criteria. The API deletes records in the
 * FUN_RULE_CRITERIA table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Rule Criteria
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_criteria_id      Internal Indentifier for the Criteria.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE delete_rule_criteria(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_criteria_id             IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);

END FUN_RULE_CRITERIA_PUB;

 

/
