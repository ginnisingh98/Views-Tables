--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_HEADER_DEP_HDLR_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_HEADER_DEP_HDLR_W" AS
/* $Header: asovqwhb.pls 120.2 2005/08/10 18:26:20 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_HEADER_DEP_HDLR_W


G_PKG_NAME           CONSTANT    VARCHAR2(30)                             := 'ASO_QUOTE_HEADER_DEP_HDLR_W';
G_FILE_NAME          CONSTANT    VARCHAR2(12)                             := 'asovqwhb.pls';


PROCEDURE Get_Dependent_Attributes_Sets
  (
      X_Q_CONTRACT_ID                 OUT NOCOPY jtf_number_table
  ,   X_Q_CUST_ACCOUNT_ID             OUT NOCOPY jtf_number_table
  ,   X_Q_CUST_PARTY_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_INV_TO_CUST_ACCT_ID         OUT NOCOPY jtf_number_table
  ,   X_Q_INV_TO_PTY_SITE_ID          OUT NOCOPY jtf_number_table
  ,   X_Q_ORDER_TYPE_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_ORG_ID                      OUT NOCOPY jtf_number_table
  ,   X_Q_PRICE_LIST_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_RESOURCE_ID                 OUT NOCOPY jtf_number_table
  ,   X_Q_SHIP_TO_CUST_ACCT_ID        OUT NOCOPY jtf_number_table
  ,   X_Q_SHIP_TO_PARTY_SITE_ID       OUT NOCOPY jtf_number_table
  ,   X_RETURN_STATUS                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,   X_MSG_COUNT                     OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,   X_MSG_DATA                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2 ( 50 ) := 'Get_Dependent_Attributes_Sets';

  X_Q_CONTRACT_ID_TBL             ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_CUST_ACCOUNT_ID_TBL         ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_CUST_PARTY_ID_TBL           ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_INV_TO_CUST_ACCT_ID_TBL     ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_INV_TO_PTY_SITE_ID_TBL      ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_ORDER_TYPE_ID_TBL           ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_ORG_ID_TBL                  ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_PRICE_LIST_ID_TBL           ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_RESOURCE_ID_TBL             ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_SHIP_TO_CUST_ACCT_ID_TBL    ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_Q_SHIP_TO_PARTY_SITE_ID_TBL   ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;

Begin

  ASO_QUOTE_HEADER_DEP_HDLR.Get_Dependent_Attributes_Sets
  (   P_INIT_MSG_LIST                 =>  fnd_api.g_false
  ,   X_Q_CONTRACT_ID_TBL             =>  X_Q_CONTRACT_ID_TBL
  ,   X_Q_CUST_ACCOUNT_ID_TBL         =>  X_Q_CUST_ACCOUNT_ID_TBL
  ,   X_Q_CUST_PARTY_ID_TBL           =>  X_Q_CUST_PARTY_ID_TBL
  ,   X_Q_INV_TO_CUST_ACCT_ID_TBL     =>  X_Q_INV_TO_CUST_ACCT_ID_TBL
  ,   X_Q_INV_TO_PTY_SITE_ID_TBL      =>  X_Q_INV_TO_PTY_SITE_ID_TBL
  ,   X_Q_ORDER_TYPE_ID_TBL           =>  X_Q_ORDER_TYPE_ID_TBL
  ,   X_Q_ORG_ID_TBL                  =>  X_Q_ORG_ID_TBL
  ,   X_Q_PRICE_LIST_ID_TBL           =>  X_Q_PRICE_LIST_ID_TBL
  ,   X_Q_RESOURCE_ID_TBL             =>  X_Q_RESOURCE_ID_TBL
  ,   X_Q_SHIP_TO_CUST_ACCT_ID_TBL    =>  X_Q_SHIP_TO_CUST_ACCT_ID_TBL
  ,   X_Q_SHIP_TO_PARTY_SITE_ID_TBL   =>  X_Q_SHIP_TO_PARTY_SITE_ID_TBL
  ,   X_RETURN_STATUS                 =>  X_RETURN_STATUS
  ,   X_MSG_COUNT                     =>  X_MSG_COUNT
  ,   X_MSG_DATA                      =>  X_MSG_DATA
);


  ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_CONTRACT_ID_TBL,
   x_num_id     => X_Q_CONTRACT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_CUST_ACCOUNT_ID_TBL,
   x_num_id     => X_Q_CUST_ACCOUNT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_CUST_PARTY_ID_TBL,
   x_num_id     => X_Q_CUST_PARTY_ID
   );


   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    =>  X_Q_INV_TO_CUST_ACCT_ID_TBL,
   x_num_id     =>  X_Q_INV_TO_CUST_ACCT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    =>  X_Q_INV_TO_PTY_SITE_ID_TBL,
   x_num_id     =>  X_Q_INV_TO_PTY_SITE_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_ORDER_TYPE_ID_TBL,
   x_num_id     => X_Q_ORDER_TYPE_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_ORG_ID_TBL,
   x_num_id     => X_Q_ORG_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_PRICE_LIST_ID_TBL,
   x_num_id     => X_Q_PRICE_LIST_ID
   );

    ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_RESOURCE_ID_TBL,
   x_num_id     => X_Q_RESOURCE_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_SHIP_TO_CUST_ACCT_ID_TBL,
   x_num_id     => X_Q_SHIP_TO_CUST_ACCT_ID
   );


   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_Q_SHIP_TO_PARTY_SITE_ID_TBL,
   x_num_id     => X_Q_SHIP_TO_PARTY_SITE_ID
   );


END Get_Dependent_Attributes_Sets;


END ASO_QUOTE_HEADER_DEP_HDLR_W;



/
