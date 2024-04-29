--------------------------------------------------------
--  DDL for Package ASO_QUOTE_HEADER_DEP_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_HEADER_DEP_HDLR" AUTHID CURRENT_USER AS
/* $Header: asodpqhs.pls 120.2 2005/08/10 18:24:14 appldev noship $ */
-- Package name     : ASO_QUOTE_HEADER_DEP_HDLR
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Get_Dependent_Attributes_Sets
  (   P_INIT_MSG_LIST                 IN  VARCHAR2 := fnd_api.g_false
  ,   X_Q_CONTRACT_ID_TBL             OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_CUST_ACCOUNT_ID_TBL         OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_CUST_PARTY_ID_TBL           OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_INV_TO_CUST_ACCT_ID_TBL     OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_INV_TO_PTY_SITE_ID_TBL      OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_ORDER_TYPE_ID_TBL           OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_ORG_ID_TBL                  OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_PRICE_LIST_ID_TBL           OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_RESOURCE_ID_TBL             OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_SHIP_TO_CUST_ACCT_ID_TBL    OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_Q_SHIP_TO_PARTY_SITE_ID_TBL   OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
  ,   X_RETURN_STATUS                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,   X_MSG_COUNT                     OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,   X_MSG_DATA                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE   Get_Dependent_Attributes_Proc
(   P_INIT_MSG_LIST                 IN  VARCHAR2 := fnd_api.g_false
  , P_TRIGGER_RECORD                IN  ASO_AK_QUOTE_HEADER_V%ROWTYPE
  , P_TRIGGERS_ID_TBL               IN  ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
                                      := ASO_DEFAULTING_INT.G_MISS_ATTRIBUTE_IDS_TBL
  , P_CONTROL_RECORD                IN  ASO_DEFAULTING_INT.Control_Rec_Type
                                      := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC
  , X_DEPENDENT_RECORD              OUT NOCOPY /* file.sql.39 change */ ASO_AK_QUOTE_HEADER_V%ROWTYPE
  , X_RETURN_STATUS                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  , X_MSG_COUNT                     OUT NOCOPY /* file.sql.39 change */ NUMBER
  , X_MSG_DATA                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END ASO_QUOTE_HEADER_DEP_HDLR;

 

/
