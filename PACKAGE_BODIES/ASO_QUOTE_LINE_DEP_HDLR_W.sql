--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_LINE_DEP_HDLR_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_LINE_DEP_HDLR_W" AS
/* $Header: asovqwlb.pls 120.2 2006/05/19 11:34:52 gkeshava noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_LINE_DEP_HDLR_W


G_PKG_NAME           CONSTANT    VARCHAR2(30)                             := 'ASO_QUOTE_LINE_DEP_HDLR_W';
G_FILE_NAME          CONSTANT    VARCHAR2(12)                             := 'asovqwlb.pls';

PROCEDURE Get_Dependent_Attributes_Sets
  (
      X_L_AGREEMENT_ID                OUT NOCOPY jtf_number_table
  ,   X_L_INV_TO_CUST_ACCT_ID         OUT NOCOPY jtf_number_table
  ,   X_L_INV_TO_PTY_SITE_ID          OUT NOCOPY jtf_number_table
  ,   X_L_ORDER_LINE_TYPE_ID          OUT NOCOPY jtf_number_table
  ,   X_L_PRICE_LIST_ID               OUT NOCOPY jtf_number_table
  ,   X_L_SHIP_TO_CUST_ACCT_ID        OUT NOCOPY jtf_number_table
  ,   X_L_SHIP_TO_PARTY_SITE_ID       OUT NOCOPY jtf_number_table
  ,   X_RETURN_STATUS                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,   X_MSG_COUNT                     OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,   X_MSG_DATA                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
  X_L_AGREEMENT_ID_tbl              ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_INV_TO_CUST_ACCT_ID_TBL       ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_INV_TO_PTY_SITE_ID_TBL        ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_ORDER_LINE_TYPE_ID_TBL        ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_PRICE_LIST_ID_TBL             ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_SHIP_TO_CUST_ACCT_ID_TBL      ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;
  X_L_SHIP_TO_PARTY_SITE_ID_TBL     ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;

Begin

  ASO_QUOTE_LINE_DEP_HDLR.Get_Dependent_Attributes_Sets
  (   P_INIT_MSG_LIST                 =>  fnd_api.g_false
  ,   X_L_AGREEMENT_ID_TBL            =>  X_L_AGREEMENT_ID_tbl
  ,   X_L_INV_TO_CUST_ACCT_ID_TBL     =>  X_L_INV_TO_CUST_ACCT_ID_TBL
  ,   X_L_INV_TO_PTY_SITE_ID_TBL      =>  X_L_INV_TO_PTY_SITE_ID_TBL
  ,   X_L_ORDER_LINE_TYPE_ID_TBL      =>  X_L_ORDER_LINE_TYPE_ID_TBL
  ,   X_L_PRICE_LIST_ID_TBL           =>  X_L_PRICE_LIST_ID_TBL
  ,   X_L_SHIP_TO_CUST_ACCT_ID_TBL    =>  X_L_SHIP_TO_CUST_ACCT_ID_TBL
  ,   X_L_SHIP_TO_PARTY_SITE_ID_TBL   =>  X_L_SHIP_TO_PARTY_SITE_ID_TBL
  ,   X_RETURN_STATUS                 =>  X_RETURN_STATUS
  ,   X_MSG_COUNT                     =>  X_MSG_COUNT
  ,   X_MSG_DATA                      =>  X_MSG_DATA
);


  ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_L_AGREEMENT_ID_tbl,
   x_num_id     => X_L_AGREEMENT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_L_INV_TO_CUST_ACCT_ID_TBL,
   x_num_id     => X_L_INV_TO_CUST_ACCT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    =>  X_L_INV_TO_PTY_SITE_ID_TBL,
   x_num_id     =>  X_L_INV_TO_PTY_SITE_ID
   );


   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_L_ORDER_LINE_TYPE_ID_TBL,
   x_num_id     => X_L_ORDER_LINE_TYPE_ID
   );


   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    =>  X_L_PRICE_LIST_ID_TBL,
   x_num_id     =>  X_L_PRICE_LIST_ID
   );


   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_L_SHIP_TO_CUST_ACCT_ID_TBL,
   x_num_id     => X_L_SHIP_TO_CUST_ACCT_ID
   );

   ASO_QUOTE_UTIL_PVT.Set_num_Tbl_Out
   (
   p_num_tbl    => X_L_SHIP_TO_PARTY_SITE_ID_TBL,
   x_num_id     => X_L_SHIP_TO_PARTY_SITE_ID
   );



END Get_Dependent_Attributes_Sets;


END ASO_QUOTE_LINE_DEP_HDLR_W;



/
