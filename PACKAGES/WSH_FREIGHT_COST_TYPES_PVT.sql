--------------------------------------------------------
--  DDL for Package WSH_FREIGHT_COST_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FREIGHT_COST_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHFCTPS.pls 115.2 2003/07/02 18:47:21 ttrichy ship $ */
-- set tabstop=3 to read in correct alignment
--
-- Package type declarations
--
TYPE Freight_Cost_Type_Rec_Type IS RECORD (
 FREIGHT_COST_TYPE_ID                     NUMBER,
 NAME                                     VARCHAR2(60),
 FREIGHT_COST_TYPE_CODE                   VARCHAR2(30),
 AMOUNT                                   NUMBER,
 CURRENCY_CODE                            VARCHAR2(15),
 DESCRIPTION                              VARCHAR2(240),
 START_DATE_ACTIVE                        DATE,
 END_DATE_ACTIVE                          DATE,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30),
 ATTRIBUTE1                               VARCHAR2(150),
 ATTRIBUTE2                               VARCHAR2(150),
 ATTRIBUTE3                               VARCHAR2(150),
 ATTRIBUTE4                               VARCHAR2(150),
 ATTRIBUTE5                               VARCHAR2(150),
 ATTRIBUTE6                               VARCHAR2(150),
 ATTRIBUTE7                               VARCHAR2(150),
 ATTRIBUTE8                               VARCHAR2(150),
 ATTRIBUTE9                               VARCHAR2(150),
 ATTRIBUTE10                              VARCHAR2(150),
 ATTRIBUTE11                              VARCHAR2(150),
 ATTRIBUTE12                              VARCHAR2(150),
 ATTRIBUTE13                              VARCHAR2(150),
 ATTRIBUTE14                              VARCHAR2(150),
 ATTRIBUTE15                              VARCHAR2(150),
 CREATION_DATE                    	  DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATE_DATE                         DATE,
 LAST_UPDATED_BY                          NUMBER,
 LAST_UPDATE_LOGIN                        NUMBER,
 PROGRAM_APPLICATION_ID                   NUMBER,
 PROGRAM_ID                               NUMBER,
 PROGRAM_UPDATE_DATE                      DATE,
 REQUEST_ID                               NUMBER,
 CHARGE_MAP_FLAG                          VARCHAR2(1)
);

--
-- Procedure:    Create_Freight_Cost_Type
--
PROCEDURE Create_Freight_Cost_Type(
  p_freight_cost_type_info                     IN     Freight_Cost_Type_Rec_Type
, x_rowid                                      OUT NOCOPY  VARCHAR2
, x_freight_cost_type_id                       OUT NOCOPY  NUMBER
, x_return_status                              OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Freight_Cost_Type(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_type_info                       IN     Freight_Cost_Type_Rec_Type
, x_return_status                           OUT NOCOPY  VARCHAR2
);

PROCEDURE Lock_Freight_Cost_Type(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_type_info                       IN     Freight_Cost_Type_Rec_Type
);

PROCEDURE Delete_Freight_Cost_Type(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_type_id                         IN     NUMBER
, x_return_status                              OUT NOCOPY  VARCHAR2
);




END WSH_FREIGHT_COST_TYPES_PVT;

 

/
