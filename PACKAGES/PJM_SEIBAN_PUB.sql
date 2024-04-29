--------------------------------------------------------
--  DDL for Package PJM_SEIBAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_SEIBAN_PUB" AUTHID CURRENT_USER AS
/* $Header: PJMPSBNS.pls 115.5 2002/12/07 10:50:49 alaw noship $ */

--
-- Record and Table Types
--
TYPE DescFlexRecType IS RECORD
( Category   pjm_seiban_numbers.attribute_category%type
, Attr1      pjm_seiban_numbers.attribute1%type
, Attr2      pjm_seiban_numbers.attribute2%type
, Attr3      pjm_seiban_numbers.attribute3%type
, Attr4      pjm_seiban_numbers.attribute4%type
, Attr5      pjm_seiban_numbers.attribute5%type
, Attr6      pjm_seiban_numbers.attribute6%type
, Attr7      pjm_seiban_numbers.attribute7%type
, Attr8      pjm_seiban_numbers.attribute8%type
, Attr9      pjm_seiban_numbers.attribute9%type
, Attr10     pjm_seiban_numbers.attribute10%type
, Attr11     pjm_seiban_numbers.attribute11%type
, Attr12     pjm_seiban_numbers.attribute12%type
, Attr13     pjm_seiban_numbers.attribute13%type
, Attr14     pjm_seiban_numbers.attribute14%type
, Attr15     pjm_seiban_numbers.attribute15%type
);

TYPE OrgRecType IS RECORD
( Organization_ID      pjm_project_parameters.organization_id%type
, Cost_Group_ID        pjm_project_parameters.costing_group_id%type
, WIP_Acct_Class_Code  pjm_project_parameters.wip_acct_class_code%type
, Start_Date_Active    pjm_project_parameters.start_date_active%type
, End_Date_Active      pjm_project_parameters.end_date_active%type
, Attr_Category        pjm_project_parameters.attribute_category%type
, Attr1                pjm_project_parameters.attribute1%type
, Attr2                pjm_project_parameters.attribute2%type
, Attr3                pjm_project_parameters.attribute3%type
, Attr4                pjm_project_parameters.attribute4%type
, Attr5                pjm_project_parameters.attribute5%type
, Attr6                pjm_project_parameters.attribute6%type
, Attr7                pjm_project_parameters.attribute7%type
, Attr8                pjm_project_parameters.attribute8%type
, Attr9                pjm_project_parameters.attribute9%type
, Attr10               pjm_project_parameters.attribute10%type
, Attr11               pjm_project_parameters.attribute11%type
, Attr12               pjm_project_parameters.attribute12%type
, Attr13               pjm_project_parameters.attribute13%type
, Attr14               pjm_project_parameters.attribute14%type
, Attr15               pjm_project_parameters.attribute15%type
);

TYPE OrgTblType IS TABLE OF OrgRecType
  INDEX BY BINARY_INTEGER;


--
-- Functions and Procedures
--
PROCEDURE Create_Seiban
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_TRUE
, P_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_seiban_number           IN            VARCHAR2
, P_seiban_name             IN            VARCHAR2
, P_operating_unit          IN            NUMBER   DEFAULT NULL
, P_planning_group          IN            VARCHAR2 DEFAULT NULL
, P_DFF                     IN            DescFlexRecType
, P_org_list                IN            OrgTblType
, X_project_id              OUT NOCOPY    NUMBER
);

END PJM_SEIBAN_PUB;

 

/
