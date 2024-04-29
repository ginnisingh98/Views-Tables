--------------------------------------------------------
--  DDL for Package CSD_RULES_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RULES_ENGINE_PVT" AUTHID CURRENT_USER as
/* $Header: csdvruls.pls 120.1.12010000.4 2008/11/10 20:15:09 swai ship $ */
-- Start of Comments
-- Package name     : CSD_RULES_ENGINE_PVT
-- Purpose          : Jan-14-2008    rfieldma created
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH        CONSTANT NUMBER        := 30;
G_EQUALS                       CONSTANT VARCHAR2(6)   := 'EQUALS';
G_NOT_EQUALS                   CONSTANT VARCHAR2(10)  := 'NOT_EQUALS';
G_LESS_THAN                    CONSTANT VARCHAR2(9)   := 'LESS_THAN';
G_GREATER_THAN                 CONSTANT VARCHAR2(12)  := 'GREATER_THAN';
G_RULE_TYPE_BULLETIN           CONSTANT VARCHAR2(8)   := 'BULLETIN';
G_RULE_TYPE_DEFAULTING         CONSTANT VARCHAR2(10)  := 'DEFAULTING';
G_RULE_MATCH_ONE               CONSTANT NUMBER        := 1; -- used by CSD_RULE_MATCHING_REC_TYPE.RULE_MATCH_CODE
G_RULE_MATCH_ALL               CONSTANT NUMBER        := 2; -- used by CSD_RULE_MATCHING_REC_TYPE.RULE_MATCH_CODE
G_VALUE_TYPE_ATTRIBUTE         CONSTANT VARCHAR2(9)   := 'ATTRIBUTE';
G_VALUE_TYPE_PROFILE           CONSTANT VARCHAR2(7)   := 'PROFILE';
G_VALUE_TYPE_PLSQL             CONSTANT VARCHAR2(9)   := 'PLSQL_API';
G_L_API_VERSION_NUMBER         CONSTANT NUMBER        := 1.0;


G_ATTR_TYPE_RO                 CONSTANT VARCHAR2(22)  := 'CSD_DEF_ENTITY_ATTR_RO';
G_ATTR_CODE_REPAIR_ORG         CONSTANT VARCHAR2(10)  := 'REPAIR_ORG';
G_ATTR_CODE_REPAIR_OWNER       CONSTANT VARCHAR2(12)  := 'REPAIR_OWNER';
G_ATTR_CODE_INV_ORG            CONSTANT VARCHAR2(7)   := 'INV_ORG';
G_ATTR_CODE_RMA_RCV_ORG        CONSTANT VARCHAR2(11)  := 'RMA_RCV_ORG';
G_ATTR_CODE_RMA_RCV_SUBINV     CONSTANT VARCHAR2(14)  := 'RMA_RCV_SUBINV';
G_ATTR_CODE_PRIORITY           CONSTANT VARCHAR2(8)   := 'PRIORITY';
G_ATTR_CODE_REPAIR_TYPE        CONSTANT VARCHAR2(11)  := 'REPAIR_TYPE';
G_ATTR_CODE_SHIP_FROM_ORG      CONSTANT VARCHAR2(13)  := 'SHIP_FROM_ORG';
G_ATTR_CODE_SHIP_FROM_SUBINV   CONSTANT VARCHAR2(16)  := 'SHIP_FROM_SUBINV';
G_ATTR_CODE_VENDOR_ACCOUNT     CONSTANT VARCHAR2(14)  := 'VENDOR_ACCOUNT';

G_PROFILE_REPAIR_ORG           CONSTANT VARCHAR2(22)  := 'CSD_DEFAULT_REPAIR_ORG';
G_PROFILE_REPAIR_TYPE          CONSTANT VARCHAR2(23)  := 'CSD_DEFAULT_REPAIR_TYPE';
G_PROFILE_INV_ORG              CONSTANT VARCHAR2(19)  := 'CSD_DEF_REP_INV_ORG';
G_PROFILE_QUALITY_CHECK_PERIOD CONSTANT VARCHAR2(24)  := 'CSD_QUALITY_CHECK_PERIOD';

G_ACTION_TYPE_RMA              CONSTANT VARCHAR2(3)   := 'RMA';
G_ACTION_TYPE_RMA_THIRD_PTY    CONSTANT VARCHAR2(13)  := 'RMA_THIRD_PTY';

G_ACTION_CODE_EXCHANGE         CONSTANT VARCHAR2(8)   := 'EXCHANGE';
G_ACTION_CODE_LOANER           CONSTANT VARCHAR2(6)   := 'LOANER';
G_ACTION_CODE_CUST_PROD        CONSTANT VARCHAR2(9)   := 'CUST_PROD'; -- swai: bug 7524870

/*--------------------------------------------------------------------*/
/* Record name:  CSD_RULE_CONDITION_REC_TYPE                          */
/* Description : Record used for single match from rules engine       */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Rule Engine                             */
/*                                                                    */
/*--------------------------------------------------------------------*/
TYPE CSD_RULE_CONDITION_REC_TYPE IS RECORD
(
       RULE_CONDITION_ID      NUMBER
,      RULE_ID                NUMBER
,      ATTRIBUTE_CATEGORY     VARCHAR2(30)
,      ATTRIBUTE1             VARCHAR2(150)
,      ATTRIBUTE2             VARCHAR2(150)
,      ATTRIBUTE3             VARCHAR2(150)
,      ATTRIBUTE4             VARCHAR2(150)
,      ATTRIBUTE5             VARCHAR2(150)
,      ATTRIBUTE6             VARCHAR2(150)
,      ATTRIBUTE7             VARCHAR2(150)
,      ATTRIBUTE8             VARCHAR2(150)
,      ATTRIBUTE9             VARCHAR2(150)
,      ATTRIBUTE10            VARCHAR2(150)
,      ATTRIBUTE11            VARCHAR2(150)
,      ATTRIBUTE12            VARCHAR2(150)
,      ATTRIBUTE13            VARCHAR2(150)
,      ATTRIBUTE14            VARCHAR2(150)
,      ATTRIBUTE15            VARCHAR2(150)
);

/*--------------------------------------------------------------------*/
/* Type to  hold multiple rule conditions                             */
/*--------------------------------------------------------------------*/
TYPE  CSD_RULE_CONDITION_TBL_TYPE    IS TABLE OF CSD_RULE_CONDITION_REC_TYPE
                                            INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------*/
/* Record name:  CSD_RULE_INPUT_REC_TYPE                              */
/* Description : Record used for Input values into rules engine       */
/*                                                                    */
/* The following are valid criteria for the rules engine:             */
/*     User                                                           */
/*     User Responsibility                                            */
/*     User Inventory Org                                             */
/*     User Operating Unit                                            */
/*     SR Customer                                                    */
/*     SR Customer Account                                            */
/*     SR Bill to country                                             */
/*     SR Ship to country                                             */
/*     SR Item                                                        */
/*     SR Item Category                                               */
/*     SR Contract Entitlement                                        */
/*     SR Problem Code                                                */
/*                                                                    */
/* Called from: Depot Repair Rules Engine                             */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*--------------------------------------------------------------------*/
TYPE CSD_RULE_INPUT_REC_TYPE IS RECORD
(
       REPAIR_LINE_ID                  NUMBER
,      SR_CUSTOMER_ID                  NUMBER
,      SR_CUSTOMER_ACCOUNT_ID          NUMBER
,      SR_BILL_TO_SITE_USE_ID          NUMBER
,      SR_SHIP_TO_SITE_USE_ID          NUMBER
,      SR_ITEM_ID                      NUMBER
,      SR_ITEM_CATEGORY_ID             NUMBER
,      SR_CONTRACT_ID                  NUMBER
,      SR_PROBLEM_CODE                 VARCHAR2(30)
,      SR_INSTANCE_ID                  NUMBER
,      RO_ITEM_ID                      NUMBER  -- swai: 12.1.1 ER 7233924
);


/*--------------------------------------------------------------------*/
/* Record name:  CSD_RULE_RESULTS_REC_TYPE                            */
/* Description : Record used for single match from rules engine       */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Rule Engine                             */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*--------------------------------------------------------------------*/
TYPE CSD_RULE_RESULTS_REC_TYPE IS RECORD
(
       RULE_ID                NUMBER
,      DEFAULTING_VALUE       VARCHAR2(150)
,      VALUE_TYPE             VARCHAR2(30)

);

/*--------------------------------------------------------------------*/
/* Type to Return multiple results from rules engine                  */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair                                         */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*--------------------------------------------------------------------*/
TYPE  CSD_RULE_RESULTS_TBL_TYPE      IS TABLE OF CSD_RULE_RESULTS_REC_TYPE
                                                 INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------*/
/* Record name:  CSD_RULE_MATCHING_REC_TYPE                           */
/* Description : Record used for Input values into rules engine       */
/*                                                                    */
/*                                                                    */
/*     RULE_MATCH_CODE  has the following meanings:                   */
/*          1 -  Find the first matching rule in order of precedence  */
/*          2 -  Find all matching rules regardless of precedence     */
/*                                                                    */
/*     RULE_TYPE - lookup code from CSD_RULE_TYPES of rule type match */
/*                                                                    */
/*     DEFAULTING_ATTRIBUTE_ID                                        */
/*          Primary key from CSD_DEFAULTING_ATTRIBUTES_B to match     */
/*          with rules                                                */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Rules Engine                            */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
TYPE CSD_RULE_MATCHING_REC_TYPE IS RECORD
(
       RULE_MATCH_CODE                 NUMBER
,      RULE_TYPE                       VARCHAR2(30)
,      ENTITY_ATTRIBUTE_TYPE           VARCHAR2(30)
,      ENTITY_ATTRIBUTE_CODE           VARCHAR2(30)
,      RULE_INPUT_REC                  CSD_RULE_INPUT_REC_TYPE
,      RULE_RESULTS_TBL                CSD_RULE_RESULTS_TBL_TYPE
);


/*--------------------------------------------------------------------*/
/* procedure name: PROCESS_RULE_MATCHING                              */
/* description : procedure used to Match Rules with input data        */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Bulletins                               */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_rule_matching_rec CSD_RULE_MATCHING_REC_TYPE                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE PROCESS_RULE_MATCHING(
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    px_rule_matching_rec           IN OUT NOCOPY CSD_RULE_MATCHING_REC_TYPE,
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
);


/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value = VARCHAR2 data type                   */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     VARCHAR2                                     */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_entity_attribute_type        IN            VARCHAR2,
    p_entity_attribute_code        IN            VARCHAR2,
    p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
    x_default_value                OUT    NOCOPY VARCHAR2,
    x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value =  NUMBER data type                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     NUMBER                                       */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_entity_attribute_type        IN            VARCHAR2,
    p_entity_attribute_code        IN            VARCHAR2,
    p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
    x_default_value                OUT    NOCOPY NUMBER,
    x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE_FROM_RULE   (overloaded)         */
/* description : procedure used to get default values from rules      */
/*               default value = DATE data type                       */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Workbench defaulting                    */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   p_entity_attribute_type VARCHAR2 Req                             */
/*   p_entity_attribute_code VARCHAR2 Req                             */
/*   p_rule_input_rec    CSD_RULE_INPUT_REC_TYPE Req                  */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/*   x_default_value     DATE                                         */
/*   x_rule_id           NUMBER        Rule ID that determined value  */
/*                                     if null, then no rule used     */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*               Aug-20-08   swai       added param x_rule_id         */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE GET_DEFAULT_VALUE_FROM_RULE (
    p_api_version_number           IN            NUMBER,
    p_init_msg_list                IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit                       IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level             IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_entity_attribute_type        IN            VARCHAR2,
    p_entity_attribute_code        IN            VARCHAR2,
    p_rule_input_rec               IN            CSD_RULE_INPUT_REC_TYPE,
    x_default_value                OUT    NOCOPY DATE,
    x_rule_id                      OUT    NOCOPY NUMBER,  -- swai: 12.1.1 ER 7233924
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: MATCH_CONDITION                                    */
/* description : procedure used to match parameter to criterion based */
/*               on operatior                                         */
/*               Calls overloaded function - CHECK_CONDITION_MATCH    */
/*                                                                    */
/*                                                                    */
/* Called from : PROCEDURE PROCESS_RULE_MATCHING                      */
/* Input Parm  :                                                      */
/*    p_parameter_type  VARCHAR2 Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       VARCHAR2 Req                                  */
/*    p_rule_input_rec  CSD_RULE_INPUT_REC_TYPE Req                   */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  MATCH_CONDITION (
    p_parameter_type              IN            VARCHAR2,
    p_operator                    IN            VARCHAR2,
    p_criterion                   IN            VARCHAR2,
    p_rule_input_rec              IN            CSD_RULE_INPUT_REC_TYPE
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = NUMBER data type              */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  NUMBER Req                                    */
/*    p_operator        NUMBER Req                                    */
/*    p_criterion       NUMBER Req                                    */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
    p_input_param                 IN            NUMBER,
    p_operator                    IN            VARCHAR2,
    p_criterion                   IN            NUMBER
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = VARCHAR2 data type            */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  VARCHAR2 Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       VARCHAR2 Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
    p_input_param                 IN            VARCHAR2,
    p_operator                    IN            VARCHAR2,
    p_criterion                   IN            VARCHAR2
) RETURN VARCHAR2;



/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONDITION_MATCH   (overloaded)               */
/* description : procedure used to check if parameter matches         */
/*               criterion based on operator                          */
/*               parameter, criterion = DATE data type                */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_parameter_type  DATE     Req                                  */
/*    p_operator        VARCHAR2 Req                                  */
/*    p_criterion       DATE     Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 G_MISS.G_TRUE/G_MISS.G_FALSE                           */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION  CHECK_CONDITION_MATCH (
    p_input_param                 IN            DATE,
    p_operator                    IN            VARCHAR2,
    p_criterion                   IN            DATE
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: COPY_RULE_INPUT_REC_VALUES                         */
/* description : copies source rec into dest rec                      */
/*               rec typ = CSD_RULE_INPUT_REC_TYPE                    */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_s_rec  CSD_RULE_INPUT_REC_TYPE     Req                        */
/*    p_d_Rec  CSD_RULE_INPUT_REC_TYPE     VARCHAR2 Req               */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE COPY_RULE_INPUT_REC_VALUES(
   p_s_rec                       IN                   CSD_RULE_INPUT_REC_TYPE, -- source rec
   px_d_rec                      IN OUT NOCOPY        CSD_RULE_INPUT_REC_TYPE -- destination rec
);

/*--------------------------------------------------------------------*/
/* procedure name: COPY_RULE_INPUT_REC_VALUES                         */
/* description : copies source rec into dest rec                      */
/*               rec typ = CSD_RULE_INPUT_REC_TYPE                    */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_s_rec  CSD_RULE_INPUT_REC_TYPE     Req                        */
/*    p_d_Rec  CSD_RULE_INPUT_REC_TYPE     VARCHAR2 Req               */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE POPULATE_RULE_INPUT_REC(
   px_rule_input_rec              IN OUT NOCOPY   CSD_RULE_INPUT_REC_TYPE,
   p_repair_line_id               IN              NUMBER
);

/*--------------------------------------------------------------------*/
/* procedure name: GET_DEFAULT_VALUE                                  */
/* description : retrieves default value based on type                */
/*               ATTRIBUTE -> return default value as is              */
/*               PROFILE   -> return profile (default value)          */
/*               PLSQL     -> execute function call stored in default */
/*                            value and cast return value to string   */
/*                            and return that string value            */
/*                                                                    */
/*                                                                    */
/* Called from : FUNCTION  GET_DEFAULT_VALUE_FROM_RULE                */
/* Input Parm  :                                                      */
/*    p_value_type       VARCHAR2 Req                                 */
/*    p_defaulting_value VARCHAR2 Req                                 */
/*   p_attribute_type    VARCHAR2 Req                                 */
/*   p_attribute_code    VARCHAR2 Req                                 */
/*    x_return_status   VARCHAR2 Req                                  */
/*    x_msg_count       VARCHAR2 Req                                  */
/*    x_msg_data        VARCHAR2 Req                                  */
/* Return Val :                                                       */
/*    VARCHAR2 - the actual default value                             */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_DEFAULT_VALUE(
   p_value_type        IN            VARCHAR2,
   p_defaulting_value  IN            VARCHAR2,
   p_attribute_type    IN            VARCHAR2,
   p_attribute_code    IN            VARCHAR2
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: GET_COUNTRY_CODE                                   */
/* description : returns country code based on site_useid             */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_site_use_id   NUMBER   Req                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - COUNTRY code                                         */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_COUNTRY_CODE(
   p_site_use_id    IN NUMBER
) RETURN VARCHAR2;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RO_ITEM_CATEGORY                             */
/* description : checks if the RO item is in the specified category   */
/*               This function assumes the service validation         */
/*               inventory org                                        */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_ro_item_id   NUMBER   Req RO Inventory Item Id                */
/*    p_operator     VARCHAR2 Req 'EQUALS': check item is in category */
/*                                'NOT_EQUALS': check item is not in  */
/*                                 item category                      */
/*    p_criterion    NUMBER   Req  Item Category Id                   */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Aug-18-08   swai   created for 12.1.1  ER 7233924    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RO_ITEM_CATEGORY(
   p_ro_item_id        IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN NUMBER
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_PROMISE_DATE                                 */
/* description : retrieves RO promise by date                         */
/*               compare threshold with promise_date - sysdate        */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_PROMISE_DATE(
   p_repair_line_id    IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RESOLVE_BY_DATE                              */
/* description : retrieves RO resolve by date                         */
/*               compare threshold with resolve_by_date - sysdate     */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RESOLVE_BY_DATE(
   p_repair_line_id    IN NUMBER,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* procedure name: CHECK_RETURN_BY_DATE                               */
/* description : retrieves return by date on logistics line           */
/*               '%'       => RMA_THIRD_PARTY line                    */
/*               loaner    => RMA line                                */
/*               exchange  => RMA line                                */
/*               compare threshold with return by date - sysdate      */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/*    p_action_type      VARCHAR2 Req                                 */
/*    p_action_code      VARCHAR2 Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_RETURN_BY_DATE(
   p_repair_line_id    IN NUMBER,
   p_action_type       IN VARCHAR2,
   p_action_code       IN VARCHAR2,
   p_operator          IN VARCHAR2,
   p_criterion         IN VARCHAR2
) RETURN VARCHAR2;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_REPEAT_REPAIR                                */
/* description : 1) get instance id based on repair_line_id           */
/*               2) get the lastest repair based on the instance id   */
/*                  (order by closed_date desc  )                     */
/*                  NOTE: ideally, we would like to use the ship date */
/*                        on the logistics line.  But due to the      */
/*                        complexity, we are using closed_date for    */
/*                        this release.                               */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_REPEAT_REPAIR(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
) RETURN VARCHAR2;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CHRONIC_REPAIR                               */
/* description : 1) get instance id based on repair_line_id           */
/*               2) get profile option CSD_QUALITY_CHECK_PERIOD value */
/*               3) query # of repair orders during this period       */
/*                  (closed_date)                                     */
/*                  NOTE: ideally, we would like to use the ship date */
/*                        on the logistics line.  But due to the      */
/*                        complexity, we are using closed_date for    */
/*                        this release.                               */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id   NUMBER   Req                                 */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_CHRONIC_REPAIR(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
)RETURN VARCHAR2;

/*--------------------------------------------------------------------*/
/* procedure name: CHECK_CONTRACT_EXP_DATE                            */
/* description : calls OKS_ENTITLEMENTS_PUB.Get_Contracts_Expiration  */
/*               checks threshold with exp date - sysdate             */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_repair_line_id      NUMBER   Req                              */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - G_TRUE or G_FALSE                                    */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION CHECK_CONTRACT_EXP_DATE(
   p_repair_line_id IN NUMBER,
   p_operator       IN VARCHAR2,
   p_criterion      IN VARCHAR2
) RETURN VARCHAR2;

/*   probably should be moved to util package                         */
/*--------------------------------------------------------------------*/
/* procedure name: GET_RO_INSTANCE_ID                                 */
/* description : returns customer_producet_id instance id of RO       */
/*                                                                    */
/* Called from : FUNCTION  MATCH_CONDITION                            */
/* Input Parm  :                                                      */
/*    p_contract_id      NUMBER   Req                                 */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    NUMBER - Instance ID                                            */
/*                                                                    */
/* Change Hist : Jan-14-08   rfieldma   created                       */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_RO_INSTANCE_ID(
    p_repair_line_id IN NUMBER
) RETURN NUMBER;



/*--------------------------------------------------------------------*/
/* function name: GET_RULE_SQL_FOR_RO                                 */
/* description : Given a single rule, generate a sql query            */
/*               that will match all repair orders for all the rule   */
/*               conditions                                           */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETIN_FOR_RULE                    */
/* Input Parm  :                                                      */
/*    p_rule_id      NUMBER     Req                                   */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - SQL Query to get ROs for rule                        */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_RULE_SQL_FOR_RO(
    p_rule_id IN NUMBER
) RETURN VARCHAR2;


/*--------------------------------------------------------------------*/
/* function name: GET_SQL_OPERATOR                                    */
/* description : Turns the given operator into the corresponding      */
/*               operator symbol used in a sql query                  */
/*                                                                    */
/* Called from : FUNCTION  GET_RULE_SQL_FOR_RO                        */
/* Input Parm  :                                                      */
/*    p_operator      VARCHAR2     Req                                */
/*                                                                    */
/*                                                                    */
/* Return Val :                                                       */
/*    VARCHAR2 - Operator Lookup code from CSD_RULE_OPERATORS         */
/*                                                                    */
/*--------------------------------------------------------------------*/
FUNCTION GET_SQL_OPERATOR (
    p_operator IN VARCHAR2
) RETURN VARCHAR2;

END CSD_RULES_ENGINE_PVT;

/
