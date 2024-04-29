--------------------------------------------------------
--  DDL for Package FUN_RULE_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_OBJECTS_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULROBPUS.pls 120.6 2006/07/18 10:21:17 havvari noship $ */
/*#
 * This package contains the public APIs for user customizable Rules objects.
 * @rep:scope internal
 * @rep:product FUN
 * @rep:displayname Rules Framework:Customizable Object Definition
 * @rep:category BUSINESS_ENTITY FUN_RULE_OBJECT
 * @rep:lifecycle active
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE rule_objects_rec_type IS RECORD (
   rule_object_id		NUMBER(15),
   application_id   		NUMBER(15),
   rule_object_name		VARCHAR2(30),
   user_rule_object_name	VARCHAR2(80),
   description			VARCHAR2(240),
   result_type			VARCHAR2(30),
   required_flag		VARCHAR2(1),
   use_default_value_flag       VARCHAR2(1),
   default_application_id	NUMBER,
   default_value		VARCHAR2(240),
   flex_value_set_id            NUMBER,
   flexfield_name               VARCHAR2(80),
   flexfield_app_short_name     VARCHAR2(50),
   multi_rule_result_flag       VARCHAR2(1),
   use_instance_flag            VARCHAR2(1),
   instance_label               VARCHAR2(150),
   parent_rule_object_id        VARCHAR2(15),
   org_id                       NUMBER(15),
   creation_date 		DATE,
   created_by 			NUMBER,
   last_update_date 		DATE,
   last_updated_by 		NUMBER,
   last_update_login 		NUMBER,
   created_by_module            VARCHAR2(150)
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * Use this routine to create a rule object and its related information.
 * With this API you can create a record in the FUN_RULE_OBJECTS_B ,
 * FUN_RULE_OBJECTS_TL and FUN_RULE_OBJ_ATTRIBUTES table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Rule Objects
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_rec  User customizable objects record.
 * @param p_rule_object_id   Internal identifier for the Rule Object
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE create_rule_object(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_rec     		 IN      RULE_OBJECTS_REC_TYPE,
    x_rule_object_id                     OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);

/**
 * Use this routine to create a rule object instance to be used for rule partitioning.
 * With this API you can create a record in the FUN_RULE_OBJECTS_B ,
 * table provided the flag USE_INSTANCE_FLAG is set to 'Y'. This API will return
 * the rule_object_id of the newly created rule object instance record.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Rule Object Instance
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_application_id   Application identifier
 * @param p_rule_object_name Name of Rule Object
 * @param p_instance_label   Name of the Instance.
 * @param p_rule_object_id   Internal identifier for the Rule Object
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 27-Dec-2005    Amulya Mishra     Created
 */



PROCEDURE create_rule_object_instance(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_application_id                     IN      NUMBER,
    p_rule_object_name     		 IN      VARCHAR2,
    p_instance_label                     IN      VARCHAR2,
    p_org_id                             IN      NUMBER,
    x_rule_object_id                     OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);


/**
 * Use this routine to update a rule object. The API updates records in the
 * FUN_RULE_OBJECTS_B , FUN_RULE_OBJECTS_TL and FUN_RULE_OBJ_ATTRIBUTES tables.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update User Customizable Rule
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_rec  User customizable objects record.
 * @param p_object_version_number Record version number
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE update_rule_object(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_rec    		 IN      RULE_OBJECTS_REC_TYPE,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
);

/**
 * Gets Rule Object object record  based on passed Rule Object name and Application Id .
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Retrieve User Customizable Rule
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_name Name of Rule Object
 * @param p_application_id   Application identifier
 * @param p_rule_object_rec  User customizable objects record.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE get_rule_object_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_name                      IN     VARCHAR2,
    p_application_id                        IN     NUMBER,
    p_instance_label                        IN     VARCHAR2,
    p_org_id                                IN     NUMBER,
    x_rule_object_rec        		    OUT    NOCOPY RULE_OBJECTS_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * Gets Rule Object object record based on passed Rule Object Id.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Retrieve User Customizable Rule
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_id   Identifier of Rule Object
 * @param p_rule_object_rec  User customizable objects record.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE get_rule_object_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                        IN     NUMBER,
    x_rule_object_rec        		    OUT    NOCOPY RULE_OBJECTS_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * Use this routine to delete a rule object and its instances. The API deletes records in the
 * FUN_RULE_OBJECTS_B , FUN_RULE_OBJECTS_TL and FUN_RULE_OBJ_ATTRIBUTES table.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete  Rule Object Record.
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_name Name of Rule Object
 * @param p_application_id   Application identifier
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 10-Sep-2004    Amulya Mishra     Created
 */

PROCEDURE delete_rule_object(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_name        IN        VARCHAR2,
    p_application_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);

/**
 * Use this routine to delete a rule object instance. The API deletes a record in the
 * FUN_RULE_OBJECTS_B table after checking if the USE_INSTANCE_FLAG is Y or not.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete  Rule Object Record.
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_application_id   Application identifier
 * @param p_rule_object_name Name of Rule Object
 * @param p_instance_label   Name of the Instance.
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 27-Dec-2005    Amulya Mishra     Created
 */

PROCEDURE delete_rule_object_instance(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
);

/**
 * Use this routine to check if a particular rule object instance exists in the database or not.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete  Rule Object Record.
 *
 * @param p_application_id   Application identifier
 * @param p_rule_object_name Name of Rule Object
 * @param p_instance_label   Name of the Instance.
 *
 * @rep:comment 27-Dec-2005    Amulya Mishra     Created
 */

FUNCTION rule_object_instance_exists(
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER
) RETURN BOOLEAN;

/**
 * Use this routine to check if a particular rule object instance exists in the database or not.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete  Rule Object Record.
 *
 * @param p_application_id   Application identifier
 * @param p_rule_object_name Name of Rule Object
 * @param p_instance_label   Name of the Instance.
 * @param p_org_id	     Operating Unit
 *
 * @rep:comment 18-Jul-2006    A.Hari Krishna     Created
 */

FUNCTION rule_object_instance_exists_vc(
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER
) RETURN VARCHAR2;

/**
 * Use this routine to determine if a rule object uses a certain parameter.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Rule Object uses a Parameter or Not.
 *
 * @param p_rule_object_name Name of Rule Object
 * @param p_parameter_name   Criteria paramete Name
 *
 * @rep:comment 20-Aug-2005    Amulya Mishra     Created
 */

FUNCTION RULE_OBJECT_USES_PARAMETER(p_rule_object_name IN VARCHAR2,
                                    p_parameter_name IN VARCHAR2)
RETURN BOOLEAN;

/**
 * Use this routine to convert the Rule Object to make it enabling Instance
 * and vice versa.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Convert Rule Object Instance Enabling Feature
 *
 * @param p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * @param p_rule_object_id   Internal identifier for the Rule Object
 * @param p_instance_flag    Use Instance Flag value for the Rule Object
 * @param p_instance_label   Instance Label to be associated with the Rule Object Instances.
 * @param p_org_id           Internal identifier for the organization id to be associated with the Rule Object Instances
 * @param x_return_status    Return status after the call.
 * @param x_msg_count        Number of messages in message stack.
 * @param x_msg_data         Message text if x_msg_count is 1.
 *
 * @rep:comment 14-Feb-2006    Amulya Mishra     Created
 */

PROCEDURE convert_use_instance(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                     IN      NUMBER,
    p_use_instance_flag                  IN      VARCHAR2,
    p_instance_label                     IN      VARCHAR2 DEFAULT NULL,
    P_ORG_ID                             IN      NUMBER DEFAULT NULL,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
);


END FUN_RULE_OBJECTS_PUB;

 

/
