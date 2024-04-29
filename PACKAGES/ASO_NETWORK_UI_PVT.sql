--------------------------------------------------------
--  DDL for Package ASO_NETWORK_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_NETWORK_UI_PVT" AUTHID CURRENT_USER as
/* $Header: asovnets.pls 120.1 2005/06/29 12:42:17 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_NETWORK_UI_PVT
-- Purpose          : This is a wrapper, to make the CZ API Calls for MACD Functionality in Quoting Forms UI
-- History          :
-- NOTE             :
-- End of Comments

-- publication applicability parameters
--   config_creation_date (optional)
--   config_model_lookup_date (optional)
--   config_effective_date (optional)
--   calling_application_id (required)
--   usage_name (optional): if usage_name is not supplied: the value of profile option 'CZ_PUBLICATION_USAGE'
--   will be used if it is set; G_ANY_USAGE_NAME will be used otherwise.
--   publication_mode (optional): if publication_mode is not provided: the value of profile option
--   'CZ_PUBLICATION_MODE' will be used if it is set; G_PRODUCTION_PUB_MODE will be used otherwise.
--   language (optional): default value is session language

TYPE aso_appl_param_rec_type IS RECORD
(
  config_creation_date     DATE,
  config_model_lookup_date DATE,
  config_effective_date    DATE,
  calling_application_id   NUMBER,
  usage_name               VARCHAR2(255),
  publication_mode         VARCHAR2(1),
  language                 VARCHAR2(4)
);


------number tbl declaration
TYPE aso_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
---TYPE aso_number_tbl_type IS TABLE OF NUMBER;

-----

TYPE aso_Instance_Rec_Type IS RECORD
(
    Instance_id        NUMBER,
    Price_List_Id      NUMBER := FND_API.G_MISS_NUM
);
G_MISS_Instance_Rec    aso_Instance_Rec_Type;

TYPE aso_Instance_Tbl_Type IS TABLE OF aso_Instance_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_Instance_Tbl    aso_Instance_Tbl_Type;


------------------------------------------------------------------------------
-- API name : is_container
-- Package Name: ASO_NETWORK_UI_PVT
-- Type : Private
-- Pre-reqs : None
-- Function: Checks if a model specified by the top inventory_item_id and
-- organization_id is a network container model.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameterp_inventory_item_id (required),
-- top inventory_item_id of model
-- p_inventory_item_id (required), top inventory_item_id of model
-- p_organization_id (required), organization_id of model
-- p_appl_param_rec (required), publication applicability parameters
-- program callers should pass in the same set of applicability
-- parameter values as they pass in the Configurator xml initialize
-- message.
-- OUT: x_return_value, has one of the following values FND_API.G_TRUE,FND_API.G_FALSE,NULL
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter


procedure aso_is_container(p_api_version        IN   NUMBER
                          ,p_inventory_item_id  IN   NUMBER
                          ,p_organization_id    IN   NUMBER
                          ,p_appl_param_rec     IN   ASO_NETWORK_UI_PVT.aso_appl_param_rec_type
                          ,x_return_value       OUT NOCOPY  VARCHAR2
                          ,x_return_status      OUT NOCOPY  VARCHAR2
                          ,x_msg_count          OUT NOCOPY  NUMBER
                          ,x_msg_data           OUT NOCOPY  VARCHAR2
                          );





-------------------------------------------------------------------------------------------
-- API name : get_contained_models
-- Package Name: ASO_NETWORK_UI_PVT
-- Type : Private
-- Pre-reqs : None
-- Function: Retrieves all possible enclosed trackable child models for the network
-- container model specified by the input inventory_item_id and
-- organization_id
-- Version : Current version 1.0
-- Initial version 1.0

-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_inventory_item_id (required), top inventory_item_id of network
-- container model
-- p_organization_id (required), organization_id of network container model
-- p_appl_param_rec (required), publication applicability parameters
-- program callers should pass in the same set of applicability
-- parameter values as they pass in the Configurator xml initialize
-- message
--
-- OUT: x_model_tbl, output array of inventory_item_ids of enclosed models
-- IF any error occurs during execution of this procedure, null will be
-- returned.
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter

procedure aso_get_contained_models(p_api_version    IN          NUMBER
                                  ,p_inventory_item_id  IN          NUMBER
                                  ,p_organization_id    IN          NUMBER
                                  ,p_appl_param_rec     IN          ASO_NETWORK_UI_PVT.aso_appl_param_rec_type
                                  ,x_model_tbl          OUT NOCOPY  ASO_NETWORK_UI_PVT.aso_number_tbl_type
                                  ,x_return_status      OUT NOCOPY  VARCHAR2
                                  ,x_msg_count          OUT NOCOPY  NUMBER
                                  ,x_msg_data           OUT NOCOPY  VARCHAR2
                                  );


PROCEDURE aso_config_operations(
    P_Api_Version_Number        IN        NUMBER,
    P_Init_Msg_List   		IN	  VARCHAR2                          := FND_API.G_FALSE,
    P_Commit    		IN	  VARCHAR2                          := FND_API.G_FALSE,
    p_validation_level   	IN	  NUMBER                            := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		IN	  ASO_QUOTE_PUB.Control_Rec_Type    := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN        ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_qte_line_tbl              IN	  ASO_QUOTE_PUB.Qte_line_tbl_type   := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl ,
    P_instance_tbl              IN        ASO_NETWORK_UI_PVT.aso_Instance_Tbl_Type,
    p_operation_code            IN        VARCHAR2,
    x_Qte_Header_Rec            OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    X_Msg_Count    	 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
);

PROCEDURE aso_Get_config_details(
    P_Api_Version_Number         IN   NUMBER    := FND_API.G_MISS_NUM,
    P_Init_Msg_List              IN   VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    p_control_rec                IN   aso_quote_pub.control_rec_type := aso_quote_pub.G_MISS_control_rec,
    p_config_rec                 IN   aso_quote_pub.qte_line_dtl_rec_type,
    p_model_line_rec             IN   aso_quote_pub.qte_line_rec_type,
    p_config_hdr_id              IN   NUMBER ,
    p_config_rev_nbr             IN   NUMBER,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    ) ;

END ASO_NETWORK_UI_PVT;

 

/
