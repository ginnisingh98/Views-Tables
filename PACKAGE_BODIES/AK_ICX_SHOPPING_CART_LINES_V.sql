--------------------------------------------------------
--  DDL for Package Body AK$ICX_SHOPPING_CART_LINES_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK$ICX_SHOPPING_CART_LINES_V" AS
/* $Header: ICXAKSLB.pls 115.0 99/08/09 17:21:37 porting ship $ */

  PROCEDURE DEFAULT_MISSING(
     P_REC      IN OUT REC)
  IS
  BEGIN
    P_REC."ICX_AUTOSOURCE_DOC_HEADER_$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_AUTOSOURCE_DOC_LINE_NU$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_CART_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_CART_LINE_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_CATEGORY_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_CATEGORY_NAME$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCOUNT_SEGMENT$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG1$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG10$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG11$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG12$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG13$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG14$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG15$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG16$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG17$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG18$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG19$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG2$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG20$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG21$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG22$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG23$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG24$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG25$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG26$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG27$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG28$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG29$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG3$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG30$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG4$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG5$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG6$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG7$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG8$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_CHARGE_ACCT_SEG9$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_DELIVER_TO_LOCATION_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_DEST_ORG_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_EXPENDITURE_ITEM_DATE$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_EXPENDITURE_ORGANIZATI$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_ITEM_DESCRIPTION$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_ITEM_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_ITEM_REV$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_1$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_10$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_11$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_12$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_13$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_14$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_15$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_2$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_3$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_4$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_5$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_6$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_7$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_8$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_9$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ATTRIBUTE_CATEGOR$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_ID$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_LINE_TYPE_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_NEED_BY_DATE$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_PROJECT_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_QTY_V$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_SHOPPER_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_SUGGESTED_BUYER_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_SUGGESTED_VENDOR_CONTA$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_SUGGESTED_VENDOR_ITEM_$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_SUGGESTED_VENDOR_NAME$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_SUGGESTED_VENDOR_PHONE$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_SUGGESTED_VENDOR_SITE$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_TASK_ID$178" := FND_API.G_MISS_NUM;
    P_REC."ICX_UNIT_OF_MEASUREMENT$178" := FND_API.G_MISS_CHAR;
    P_REC."ICX_UNIT_PRICE$178" := FND_API.G_MISS_CHAR;
  END;
END;

/