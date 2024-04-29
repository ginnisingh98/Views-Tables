--------------------------------------------------------
--  DDL for Package FUN_RULE_CRIT_PARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_CRIT_PARAMS_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRCPPUS.pls 120.3 2006/01/10 12:17:26 ammishra noship $ */
/*#
 * This package contains the public APIs for Criteria Parameters for  Rules objects.
 * @rep:scope internal
 * @rep:product FUN
 * @rep:displayname Rules Engine:Rules Criteria Parameters Definition
 * @rep:category BUSINESS_ENTITY FUN_RULE_CRIT_PARAMS_B
 * @rep:lifecycle active
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE rule_crit_params_rec_type IS RECORD (
   criteria_param_id		NUMBER(15),
   rule_object_id   		NUMBER(15),
   param_name			VARCHAR2(30),
   user_param_name		VARCHAR2(50),
   description			VARCHAR2(240),
   tiptext			VARCHAR2(240),
   data_type			VARCHAR2(30),
   flex_value_set_id            NUMBER(15),
   creation_date 		DATE,
   created_by 			NUMBER(15),
   last_update_date 		DATE,
   last_updated_by 		NUMBER(15),
   last_update_login 		NUMBER(15),
   created_by_module            VARCHAR2(150)
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * Use this routine to create a Criteria Parameters for a Rule Object and
 * its related information.With this API you can create a record in the
 * FUN_RULE_CRIT_PARAMS_* table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Criteria parameter for a Rule Object.
 *
 * @param p_init_msg_list        Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_crit_param_rec  Rule Criteria parameter record.
 * @param x_criteria_param_id    Internal identifier for the Rule Criteria parameter
 * @param x_return_status        Return status after the call.
 * @param x_msg_count            Number of messages in message stack.
 * @param x_msg_data             Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE create_rule_crit_param(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_crit_param_rec    		 IN      RULE_CRIT_PARAMS_REC_TYPE,
    x_criteria_param_id                  OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);

/**
 * Use this routine to create duplicate Criteria Parameters for a Rule Object and
 * its related information.With this API you can create a record in the
 * FUN_RULE_CRIT_PARAMS_* table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Duplicate Criteria parameters for a Rule Object.
 *
 * @param p_init_msg_list        Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_from_rule_object_id  Rule Object Id from which you need to create parameters.
 * @param p_to_rule_object_id    Rule Object Id For/To which you need to create parameters from p_from_rule_object_id.
 * @param x_return_status        Return status after the call.
 * @param x_msg_count            Number of messages in message stack.
 * @param x_msg_data             Message text if x_msg_count is 1.
 *
 * @rep:comment 27-Dec-2005      Amulya Mishra     Created
 */

PROCEDURE create_dup_rule_crit_params(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_from_rule_object_id                IN             NUMBER,
    p_to_rule_object_id                  IN             NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);

/**
 * Use this routine to update a rule criteria parameter. The API updates records in the
 * FUN_RULE_CRIT_PARAMS table.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Rule Criteria parameter.
 * @rep:businessevent
 * @rep:doccd
 * @param p_init_msg_list        Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_crit_param_rec  Rule Criteria parameter record.
 * @param p_object_version_number Record version number
 * @param x_return_status        Return status after the call.
 * @param x_msg_count            Number of messages in message stack.
 * @param x_msg_data             Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created

 */
PROCEDURE update_rule_crit_param(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_crit_param_rec    		 IN      RULE_CRIT_PARAMS_REC_TYPE,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
);


/**
 * Gets Rule Criteria parameter record.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Retrieve Rule C riteria parameter Record.
 *
 * @param p_init_msg_list        Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_id       Internal Identifier of Rule Object.
 * @param p_param_name           Criteria Parameter Name.
 * @param x_rule_crit_param_rec  Rule Criteria Parameter record.
 * @param x_return_status        Return status after the call.
 * @param x_msg_count            Number of messages in message stack.
 * @param x_msg_data             Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE get_rule_crit_param_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                    IN     NUMBER,
    p_param_name	                    IN     VARCHAR2,
    x_rule_crit_param_rec    		    OUT    NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


/**
 * Use this routine to delete a user customizable rule object. The API deletes records in the
 * FUN_RULE_CRIT_PARAMS table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Rule Criteria parameter.
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_criteria_param_id Internal Identifier For Criteria parameter.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE delete_rule_crit_param(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_criteria_param_id       IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);

END FUN_RULE_CRIT_PARAMS_PUB;

 

/
