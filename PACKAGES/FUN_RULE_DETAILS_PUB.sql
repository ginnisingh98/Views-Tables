--------------------------------------------------------
--  DDL for Package FUN_RULE_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_DETAILS_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRDTPUS.pls 120.2.12010000.2 2008/08/06 07:44:07 makansal ship $ */
/*
 * This package contains the public APIs for set of Rules.
 * @rep:scope internal
 * @rep:product FUN
 * @rep:displayname Rules Framework:Set of Rules Defintion
 * @rep:category BUSINESS_ENTITY FUN_rule_details
 * @rep:lifecycle active
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE rule_details_rec_type IS RECORD (
   rule_detail_id               FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
   rule_object_id		FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE,
   rule_name			FUN_RULE_DETAILS.RULE_NAME%TYPE,
   seq				FUN_RULE_DETAILS.SEQ%TYPE,
   operator			FUN_RULE_DETAILS.OPERATOR%TYPE,
   enabled_flag			FUN_RULE_DETAILS.ENABLED_FLAG%TYPE,
   result_application_id	FUN_RULE_DETAILS.RESULT_APPLICATION_ID%TYPE,
   result_value			FUN_RULE_DETAILS.RESULT_VALUE%TYPE,
   creation_date 		FUN_RULE_DETAILS.CREATION_DATE%TYPE,
   created_by 			FUN_RULE_DETAILS.CREATED_BY%TYPE,
   last_update_date 		FUN_RULE_DETAILS.LAST_UPDATE_DATE%TYPE,
   last_updated_by 		FUN_RULE_DETAILS.LAST_UPDATED_BY%TYPE,
   last_update_login 		FUN_RULE_DETAILS.LAST_UPDATE_LOGIN%TYPE,
   created_by_module            FUN_RULE_DETAILS.CREATED_BY_MODULE%TYPE
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * Use this routine to create a rule and its related information.
 * With this API you can create a record in the FUN_RULE_DETAILS table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Rule
 * @rep:businessevent oracle.apps.fun.rules.server.HACustomizableObjectEO.create
 * @rep:doccd
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_detail_rec  Rule record.
 * @param x_rule_detail_id   Internal identifier for the Rule
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE create_rule_detail(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_rec     		 IN      RULE_DETAILS_REC_TYPE,
    x_rule_detail_id                     OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);

/**
 * Use this routine to update a user defined rule. The API updates records in the
 * FUN_RULE_DETAILS table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update User Defined Rule
 * @rep:businessevent
 * @rep:doccd
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_detail_rec  Rule record.
 * @param p_object_version_number Record version number
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */
PROCEDURE update_rule_detail(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_rec    		 IN      RULE_DETAILS_REC_TYPE,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
);

/**
 * Gets Rule record.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Retrieve A Rule Record
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_detail_id   Internal Identifier of Rule.
 * @param p_rule_object_id   Internal Identifier of Rule Object.
 * @param x_rule_detail_rec  Rule record.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE get_rule_detail_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_id                        IN     NUMBER,
    p_rule_object_id                        IN     NUMBER,
    x_rule_detail_rec        		    OUT    NOCOPY RULE_DETAILS_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * Use this routine to delete a rule. The API deletes records in the
 * FUN_RULE_DETAILS table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Rule.
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_name        Name of Rule
 * @param p_rule_object_id   Internal Identifier of Rule Object.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE delete_rule_detail(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_name               IN        VARCHAR2,
    p_rule_object_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);


END FUN_RULE_DETAILS_PUB;

/
