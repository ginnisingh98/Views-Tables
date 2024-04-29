--------------------------------------------------------
--  DDL for Package PV_MATCH_V2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_MATCH_V2_PUB" AUTHID CURRENT_USER as
/* $Header: pvxmtchs.pls 120.1 2005/12/02 16:56:35 amaram noship $*/

G_PKG_NAME      CONSTANT VARCHAR2(30):='PV_MATCH_V2_PUB';



g_string_data_type		CONSTANT VARCHAR2(30) := 'STRING';
g_number_data_type		CONSTANT VARCHAR2(30) := 'NUMBER';
g_date_data_type		CONSTANT VARCHAR2(30) := 'DATE';
g_currency_data_type		CONSTANT VARCHAR2(30) := 'CURRENCY';

g_drop_attr_match               CONSTANT VARCHAR2(30) := 'ANY';
g_nodrop_attr_match             CONSTANT VARCHAR2(30) := 'ALL';

g_and_attr_select               CONSTANT VARCHAR2(30) := 'AND';
g_or_attr_select               CONSTANT VARCHAR2(30) := 'OR';

g_equals_opr	                CONSTANT VARCHAR2(30) := 'EQUALS';
g_not_equals_opr	        CONSTANT VARCHAR2(30) := 'NOT_EQUALS';
g_null_opr			CONSTANT VARCHAR2(30) := 'IS_NULL';
g_not_null_opr			CONSTANT VARCHAR2(30) := 'IS_NOT_NULL';
g_greater_opr			CONSTANT VARCHAR2(30) := 'GREATER_THAN';
g_less_opr			CONSTANT VARCHAR2(30) := 'LESS_THAN';
g_grt_or_equ_opr		CONSTANT VARCHAR2(30) := 'GREATER_THAN_OR_EQUALS';
g_less_or_equ_opr		CONSTANT VARCHAR2(30) := 'LESS_THAN_OR_EQUALS';
g_between_opr			CONSTANT VARCHAR2(30) := 'BETWEEN';
g_from_match_lov_flag           BOOLEAN      := FALSE;

TYPE bind_var_tbl IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


-- pklin

Procedure Manual_match(
    p_api_version_number    IN	   NUMBER,
    p_init_msg_list	    IN	   VARCHAR2 := FND_API.G_FALSE,
    p_commit		    IN	   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	    IN	   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_attr_id_tbl	    IN OUT NOCOPY   JTF_NUMBER_TABLE,
    p_attr_value_tbl	    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_4000,
    p_attr_operator_tbl	    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_data_type_tbl    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_selection_mode   IN	   VARCHAR2,
    p_att_delmter	    IN	   VARCHAR2,
    p_selection_criteria    IN	   VARCHAR2,
    p_resource_id	    IN	   NUMBER,
    p_lead_id		    IN	   NUMBER,
    p_auto_match_flag	    IN	   VARCHAR2,
    p_get_distance_flag	    IN	   VARCHAR2 := 'F',
    x_matched_id	    OUT	   NOCOPY JTF_NUMBER_TABLE,
    x_partner_details	    OUT    NOCOPY JTF_VARCHAR2_TABLE_4000,
    x_distance_tbl	    OUT    NOCOPY JTF_NUMBER_TABLE,
    x_distance_uom_returned OUT    NOCOPY VARCHAR2,
    x_flagcount		    OUT    NOCOPY JTF_VARCHAR2_TABLE_100,
    x_return_status	    OUT    NOCOPY VARCHAR2,
    x_msg_count		    OUT    NOCOPY NUMBER,
    x_msg_data		    OUT    NOCOPY VARCHAR2,
    p_top_n_rows_by_profile IN     VARCHAR2 := 'T'
);

procedure Form_Where_Clause(
    p_api_version_number   IN     NUMBER,
    p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_attr_id_tbl	   IN OUT NOCOPY JTF_NUMBER_TABLE,
    p_attr_value_tbl       IN OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    p_attr_operator_tbl    IN OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    p_attr_data_type_tbl   IN OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    p_attr_selection_mode  IN     VARCHAR2,
    p_att_delmter          IN     VARCHAR2,
    p_selection_criteria   IN     VARCHAR2,
    p_resource_id          IN     NUMBER,
    p_lead_id              IN     NUMBER,
    p_auto_match_flag      IN     VARCHAR2,
    x_matched_id           OUT    NOCOPY JTF_NUMBER_TABLE,
    x_return_status        OUT    NOCOPY VARCHAR2,
    x_msg_count            OUT    NOCOPY NUMBER,
    x_msg_data             OUT    NOCOPY VARCHAR2,
    p_top_n_rows_by_profile IN    VARCHAR2 := 'T');





/*Procedure Auto_Match_Criteria (
    p_api_version_number   IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id              IN  Number,
    p_resource_id          IN  Number,
    x_matched_attr         OUT NOCOPY JTF_NUMBER_TABLE,
    x_matched_attr_val     OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_original_attr        OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_original_attr_val    OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_matched_id           OUT NOCOPY JTF_NUMBER_TABLE,
    x_partner_details      OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    x_flagcount            OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2);      */


Procedure   Get_Assigned_Partners(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id               IN  NUMBER,
    p_resource_id           IN  NUMBER,
    x_assigned_partner_id   OUT NOCOPY JTF_NUMBER_TABLE,
    x_partner_details       OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    x_flagcount             OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2) ;

Procedure   Create_Assignment(
    P_API_VERSION_NUMBER    IN  NUMBER,
    P_INIT_MSG_LIST         IN  VARCHAR2,
    P_COMMIT                IN  VARCHAR2,
    P_VALIDATION_LEVEL      IN  NUMBER,
    P_ENTITY                IN  VARCHAR2,
    P_LEAD_ID               IN  NUMBER,
    P_CREATING_USERNAME     IN  VARCHAR2,
    P_ASSIGNMENT_TYPE       IN  VARCHAR2,
    P_BYPASS_CM_OK_FLAG     IN  VARCHAR2,
    P_PROCESS_RULE_ID       IN  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2);

Procedure Match_partner(
    p_api_version_number   IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_sql                  IN  VARCHAR2,
    p_selection_criteria   IN  VARCHAR2,
    p_num_of_attrs         IN  NUMBER,
    p_bind_var_tbl         IN  bind_var_tbl,
    p_top_n_rows_by_profile IN VARCHAR2 := 'T',
    x_matched_prt          OUT NOCOPY JTF_NUMBER_TABLE,
    x_prt_matched          OUT NOCOPY BOOLEAN,
    x_matched_attr_cnt     OUT NOCOPY NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
    );


 Procedure Get_Matched_Partner_Details(
     p_api_version_number    IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_lead_id               IN  NUMBER,
     p_extra_partner_details IN  JTF_VARCHAR2_TABLE_1000 := null,
     p_matched_id            IN  OUT NOCOPY   JTF_NUMBER_TABLE,
     x_partner_details       OUT NOCOPY       JTF_VARCHAR2_TABLE_4000,
     x_flagcount             OUT NOCOPY      JTF_VARCHAR2_TABLE_100,
     x_return_status         OUT NOCOPY      VARCHAR2,
     x_msg_count             OUT NOCOPY      NUMBER,
     x_msg_data              OUT NOCOPY      VARCHAR2);






end PV_MATCH_V2_PUB;

 

/
