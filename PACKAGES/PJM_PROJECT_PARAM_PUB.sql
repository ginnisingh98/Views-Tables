--------------------------------------------------------
--  DDL for Package PJM_PROJECT_PARAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJECT_PARAM_PUB" AUTHID CURRENT_USER AS
/* $Header: PJMPPJPS.pls 115.0 2002/12/10 00:23:38 alaw noship $ */

TYPE ParamRecType IS RECORD
( Project_ID                pjm_project_parameters.project_id%type
, Organization_ID           pjm_project_parameters.organization_id%type
, Cost_Group_ID             pjm_project_parameters.costing_group_id%type
, WIP_Acct_Class_Code       pjm_project_parameters.wip_acct_class_code%type
, EAM_Acct_Class_Code       pjm_project_parameters.wip_acct_class_code%type
, IPV_Expenditure_Type      pjm_project_parameters.ipv_expenditure_type%type
, ERV_Expenditure_Type      pjm_project_parameters.erv_expenditure_type%type
, Freight_Expenditure_Type  pjm_project_parameters.freight_expenditure_type%type
, Tax_Expenditure_Type      pjm_project_parameters.tax_expenditure_type%type
, Misc_Expenditure_Type     pjm_project_parameters.misc_expenditure_type%type
, PPV_Expenditure_Type      pjm_project_parameters.ppv_expenditure_type%type
, Dir_Item_Expenditure_Type pjm_project_parameters.dir_item_expenditure_type%type
, Start_Date_Active         pjm_project_parameters.start_date_active%type
, End_Date_Active           pjm_project_parameters.end_date_active%type
, Attr_Category             pjm_project_parameters.attribute_category%type
, Attr1                     pjm_project_parameters.attribute1%type
, Attr2                     pjm_project_parameters.attribute2%type
, Attr3                     pjm_project_parameters.attribute3%type
, Attr4                     pjm_project_parameters.attribute4%type
, Attr5                     pjm_project_parameters.attribute5%type
, Attr6                     pjm_project_parameters.attribute6%type
, Attr7                     pjm_project_parameters.attribute7%type
, Attr8                     pjm_project_parameters.attribute8%type
, Attr9                     pjm_project_parameters.attribute9%type
, Attr10                    pjm_project_parameters.attribute10%type
, Attr11                    pjm_project_parameters.attribute11%type
, Attr12                    pjm_project_parameters.attribute12%type
, Attr13                    pjm_project_parameters.attribute13%type
, Attr14                    pjm_project_parameters.attribute14%type
, Attr15                    pjm_project_parameters.attribute15%type
);

TYPE ParamTblType IS TABLE OF ParamRecType
  INDEX BY BINARY_INTEGER;


--
-- Functions and Procedures
--
PROCEDURE Create_Project_Parameter
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_param_data              IN            ParamRecType
);


PROCEDURE Create_Project_Parameter
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_param_data              IN            ParamTblType
);


PROCEDURE update_planning_group
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_project_id              IN            NUMBER
, P_planning_group          IN            VARCHAR2
);

END PJM_PROJECT_PARAM_PUB;

 

/
