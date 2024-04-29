--------------------------------------------------------
--  DDL for Package ASO_QUOTE_LINE_DEP_HDLR_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_LINE_DEP_HDLR_W" AUTHID CURRENT_USER AS
/* $Header: asovqwls.pls 120.1 2005/06/29 12:44:33 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_LINE_DEP_HDLR_W


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
);


END ASO_QUOTE_LINE_DEP_HDLR_W;


 

/
