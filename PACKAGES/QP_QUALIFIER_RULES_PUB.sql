--------------------------------------------------------
--  DDL for Package QP_QUALIFIER_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIER_RULES_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPQRQS.pls 120.2 2005/08/31 17:50:53 srashmi noship $*/
/*#
 * This package consists of entities to set up qualifiers.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Qualifier Setup
 * @rep:category BUSINESS_ENTITY QP_PRICE_QUALIFIER
 */

--  Qualifier_Rules record type

TYPE Qualifier_Rules_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   qualifier_rule_id             NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Qualifier_Rules_Tbl_Type IS TABLE OF Qualifier_Rules_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Qualifier_Rules value record type

TYPE Qualifier_Rules_Val_Rec_Type IS RECORD
(   qualifier_rule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Qualifier_Rules_Val_Tbl_Type IS TABLE OF Qualifier_Rules_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Qualifiers record type

TYPE Qualifiers_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   created_from_rule_id          NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   excluder_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   qualifier_attribute           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_attr_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attr_value_to       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_context             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualifier_datatype            VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   qualifier_grouping_no         NUMBER         := FND_API.G_MISS_NUM
,   qualifier_id                  NUMBER         := FND_API.G_MISS_NUM
,   qualifier_precedence          NUMBER         := FND_API.G_MISS_NUM
,   qualifier_rule_id             NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   list_type_code			    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qual_attr_value_from_number   NUMBER	    := FND_API.G_MISS_NUM
,   qual_attr_value_to_number     NUMBER	    := FND_API.G_MISS_NUM
,   active_flag     		    VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   search_ind				    NUMBER         := FND_API.G_MISS_NUM
,   qualifier_group_cnt		    NUMBER	    := FND_API.G_MISS_NUM
,   header_quals_exist_flag	    VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   distinct_row_count		    NUMBER	    := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   qualify_hier_descendent_flag  VARCHAR2(1)    := FND_API.G_MISS_CHAR -- Added for TCA
);

TYPE Qualifiers_Tbl_Type IS TABLE OF Qualifiers_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Qualifiers value record type

/*TYPE Qualifiers_Val_Rec_Type IS RECORD
(   comparison_operator           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   created_from_rule             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   excluder                      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_rule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
);*/

TYPE Qualifiers_Val_Rec_Type IS RECORD
(   created_from_rule             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_rule                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attribute_desc      VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attr_value_desc     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   qualifier_attr_value_to_desc  VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Qualifiers_Val_Tbl_Type IS TABLE OF Qualifiers_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_QUALIFIER_RULES_REC    Qualifier_Rules_Rec_Type;
G_MISS_QUALIFIER_RULES_VAL_REC Qualifier_Rules_Val_Rec_Type;
G_MISS_QUALIFIER_RULES_TBL    Qualifier_Rules_Tbl_Type;
G_MISS_QUALIFIER_RULES_VAL_TBL Qualifier_Rules_Val_Tbl_Type;
G_MISS_QUALIFIERS_REC         Qualifiers_Rec_Type;
G_MISS_QUALIFIERS_VAL_REC     Qualifiers_Val_Rec_Type;
G_MISS_QUALIFIERS_TBL         Qualifiers_Tbl_Type;
G_MISS_QUALIFIERS_VAL_TBL     Qualifiers_Val_Tbl_Type;


-- Added on Jan-20-00 for 'delayed request' functionality'.


TYPE Request_Rec_Type IS RECORD
  (
   -- Object for which the delayed request has been logged.
   -- Examples could be QP_GLOBAL>G_ENTITY_PRICE_LIST  .
   Entity_code         Varchar2(30):= NULL,

   -- Primary key for the object as in entity_code
   Entity_id          Number := NULL,

   Entity_index	      Number := NULL,
   -- Request types as defined in qp_globals
   request_type       Varchar2(30) := NULL,

   return_status	VARCHAR2(1)    := FND_API.G_MISS_CHAR,

   -- Keys to identify a unique request.
   request_unique_key1	VARCHAR2(30) := NULL,
   request_unique_key2  VARCHAR2(30) := NULL,
   request_unique_key3  VARCHAR2(30) := NULL,
   request_unique_key4  VARCHAR2(30) := NULL,
   request_unique_key5  VARCHAR2(30) := NULL,

   -- Parameters (param - param10) for the delayed request
   param1             Varchar2(2000) := NULL,
   param2             Varchar2(240) := NULL,
   param3             Varchar2(240) := NULL,
   param4             Varchar2(240) := NULL,
   param5             Varchar2(240) := NULL,
   param6             Varchar2(240) := NULL,
   param7             Varchar2(240) := NULL,
   param8             Varchar2(240) := NULL,
   param9             Varchar2(240) := NULL,
   param10            Varchar2(240) := NULL,
   param11            Varchar2(240) := NULL,
   param12            Varchar2(240) := NULL,
   param13            Varchar2(240) := NULL,
   param14            Varchar2(240) := NULL,
   param15            Varchar2(240) := NULL,
   param16            Varchar2(240) := NULL,
   param17            Varchar2(240) := NULL,
   param18            Varchar2(240) := NULL,
   param19            Varchar2(240) := NULL,
   param20            Varchar2(240) := NULL,
   param21            Varchar2(240) := NULL,
   param22            Varchar2(240) := NULL,
   param23            Varchar2(240) := NULL,
   param24            Varchar2(240) := NULL,
   param25            Varchar2(240) := NULL,
   long_param1        Varchar2(2000) := NULL,
   date_param1		  DATE := NULL,
   date_param2		  DATE := NULL,
   date_param3		  DATE := NULL,
   date_param4		  DATE := NULL,
   date_param5		  DATE := NULL,
   processed		  VARCHAR2(1)	:= 'N'
);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Record to store the entity that is logging the request. Is used
-- in deleting delayed requests logged by an entity that is being
-- cleared or deleted.
TYPE Requesting_Entity_Rec_Type IS RECORD
  (
   -- Object which is logging the delayed request
   -- ie MODIFIERS,PRICE_LIST
   Entity_code         Varchar2(30):= NULL,
   -- Primary key for the entity e.g. list_line_id
   Entity_id          Number := NULL,
   -- Index of the request being logged in the request table
   request_index	NUMBER := NULL
);

--  API Requesting entity table type.
TYPE Requesting_Entity_Tbl_Type IS TABLE OF Requesting_Entity_Rec_Type
    INDEX BY BINARY_INTEGER;


-- End of additions for 'Delayed Request'










--  Start of Comments
--  API name    Process_Qualifier_Rules
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

/*#
 * Creates, updates, and deletes pricing qualifier rules and pricing qualifiers
 * belonging to those rules.
 *
 * @param p_api_version_number the api version number
 * @param p_init_msg_list true or false if there is an initial message list
 * @param p_return_values true or false if there are return values
 * @param p_commit true or false if the modifier should be committed
 * @param x_return_status the return status
 * @param x_msg_count the message count
 * @param x_msg_data the message data
 * @param p_QUALIFIER_RULES_rec the input record of the operation that the
 *        process should perform
 * @param p_QUALIFIER_RULES_val_rec the input record containing the values of the
 *        operation that the process should perform
 * @param p_QUALIFIERS_tbl the input table containing the qualifier definitions
 * @param p_QUALIFIERS_val_tbl the input table containing the qualifier values
 * @param x_QUALIFIER_RULES_rec the output record containing the operation
 * @param x_QUALIFIER_RULES_val_rec the output record containing the operation
 *        values
 * @param x_QUALIFIERS_tbl the output table containing the qualifier definitions
 * @param x_QUALIFIERS_val_tbl the output table containing the qualifier values
 *
 * @rep:displayname Process Qualifier Rule
 */
PROCEDURE Process_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_VAL_REC
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Qualifier_Rules
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  Qualifier_Rules_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIER_RULES_val_rec       IN  Qualifier_Rules_Val_Rec_Type :=
                                        G_MISS_QUALIFIER_RULES_VAL_REC
,   p_QUALIFIERS_tbl                IN  Qualifiers_Tbl_Type :=
                                        G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qualifiers_Val_Tbl_Type :=
                                        G_MISS_QUALIFIERS_VAL_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Qualifier_Rules
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule                IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_val_rec       OUT NOCOPY /* file.sql.39 change */ Qualifier_Rules_Val_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qualifiers_Val_Tbl_Type
);


PROCEDURE Copy_Qualifier_rule
(  p_api_version_number            IN NUMBER
,  p_init_msg_list                 IN VARCHAR2 :=FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule                IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_to_qualifier_rule             IN VARCHAR2
,   p_to_description                IN VARCHAR2 :=FND_API.G_MISS_CHAR
,   x_qualifier_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
);


END QP_Qualifier_Rules_PUB;

 

/
