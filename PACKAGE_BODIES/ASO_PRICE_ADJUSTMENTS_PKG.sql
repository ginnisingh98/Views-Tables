--------------------------------------------------------
--  DDL for Package Body ASO_PRICE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICE_ADJUSTMENTS_PKG" as
/* $Header: asotpadb.pls 120.1 2005/06/29 12:39:37 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICE_ADJUSTMENTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PRICE_ADJUSTMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asotpadb.pls';

PROCEDURE Insert_Row(
          px_PRICE_ADJUSTMENT_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID    NUMBER,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_MODIFIER_HEADER_ID    NUMBER,
          p_MODIFIER_LINE_ID    NUMBER,
          p_MODIFIER_LINE_TYPE_CODE    VARCHAR2,
          p_MODIFIER_MECHANISM_TYPE_CODE    VARCHAR2,
          p_MODIFIED_FROM    NUMBER,
          p_MODIFIED_TO    NUMBER,
          p_OPERAND    NUMBER,
          p_ARITHMETIC_OPERATOR    VARCHAR2,
          p_AUTOMATIC_FLAG    VARCHAR2,
          p_UPDATE_ALLOWABLE_FLAG    VARCHAR2,
          p_UPDATED_FLAG    VARCHAR2,
          p_APPLIED_FLAG    VARCHAR2,
          p_ON_INVOICE_FLAG    VARCHAR2,
          p_PRICING_PHASE_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
          p_ORIG_SYS_DISCOUNT_REF                    VARCHAR2 := NULL ,
          p_CHANGE_SEQUENCE                          VARCHAR2 := NULL ,
          -- p_LIST_HEADER_ID                           NUMBER := NULL ,
          -- p_LIST_LINE_ID                             NUMBER := NULL ,
          -- p_LIST_LINE_TYPE_CODE                      VARCHAR2 := NULL,
          p_UPDATE_ALLOWED                           VARCHAR2 := NULL,
          p_CHANGE_REASON_CODE                       VARCHAR2 := NULL,
          p_CHANGE_REASON_TEXT                       VARCHAR2 := NULL,
          p_COST_ID                                  NUMBER := NULL,
          p_TAX_CODE                                 VARCHAR2 := NULL,
          p_TAX_EXEMPT_FLAG                          VARCHAR2 := NULL,
          p_TAX_EXEMPT_NUMBER                        VARCHAR2 := NULL,
          p_TAX_EXEMPT_REASON_CODE                   VARCHAR2 := NULL,
          p_PARENT_ADJUSTMENT_ID                     NUMBER := NULL,
          p_INVOICED_FLAG                            VARCHAR2 := NULL,
          p_ESTIMATED_FLAG                           VARCHAR2 := NULL,
          p_INC_IN_SALES_PERFORMANCE                 VARCHAR2 := NULL,
          p_SPLIT_ACTION_CODE                        VARCHAR2 := NULL,
          p_ADJUSTED_AMOUNT                          NUMBER := NULL,
          p_CHARGE_TYPE_CODE                         VARCHAR2 := NULL,
          p_CHARGE_SUBTYPE_CODE                      VARCHAR2 := NULL,
          p_RANGE_BREAK_QUANTITY                     NUMBER := NULL,
          p_ACCRUAL_CONVERSION_RATE                  NUMBER := NULL ,
          p_PRICING_GROUP_SEQUENCE                   NUMBER := NULL,
          p_ACCRUAL_FLAG                             VARCHAR2 := NULL,
          p_LIST_LINE_NO                             VARCHAR2 := NULL,
          p_SOURCE_SYSTEM_CODE                       VARCHAR2 := NULL ,
          p_BENEFIT_QTY                              NUMBER := NULL,
          p_BENEFIT_UOM_CODE                         VARCHAR2 := NULL,
          p_PRINT_ON_INVOICE_FLAG                    VARCHAR2 := NULL,
          p_EXPIRATION_DATE                          DATE := NULL,
          p_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2 := NULL,
          p_REBATE_TRANSACTION_REFERENCE             VARCHAR2 := NULL,
          p_REBATE_PAYMENT_SYSTEM_CODE               VARCHAR2 := NULL,
          p_REDEEMED_DATE                            DATE := NULL,
          p_REDEEMED_FLAG                            VARCHAR2 := NULL,
          p_MODIFIER_LEVEL_CODE                      VARCHAR2 := NULL,
          p_PRICE_BREAK_TYPE_CODE                    VARCHAR2 := NULL,
          p_SUBSTITUTION_ATTRIBUTE                   VARCHAR2 := NULL,
          p_PRORATION_TYPE_CODE                      VARCHAR2 := NULL,
          p_INCLUDE_ON_RETURNS_FLAG                  VARCHAR2 := NULL,
          p_CREDIT_OR_CHARGE_FLAG                    VARCHAR2 := NULL,
		p_quote_shipment_id                        NUMBER := NULL,
		p_OPERAND_PER_PQTY                         NUMBER := NULL,
		p_ADJUSTED_AMOUNT_PER_PQTY                 NUMBER := NULL,
          p_OBJECT_VERSION_NUMBER  NUMBER)

 IS
   CURSOR C2 IS SELECT ASO_PRICE_ADJUSTMENTS_S.nextval FROM sys.dual;
BEGIN
   If (px_PRICE_ADJUSTMENT_ID IS NULL) OR (px_PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PRICE_ADJUSTMENT_ID;
       CLOSE C2;
   End If;
   INSERT INTO ASO_PRICE_ADJUSTMENTS(
           PRICE_ADJUSTMENT_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID,
           QUOTE_HEADER_ID,
           QUOTE_LINE_ID,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           MODIFIER_MECHANISM_TYPE_CODE,
           MODIFIED_FROM,
           MODIFIED_TO,
           OPERAND,
           ARITHMETIC_OPERATOR,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           UPDATED_FLAG,
           APPLIED_FLAG,
           ON_INVOICE_FLAG,
           PRICING_PHASE_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           ATTRIBUTE16,
           ATTRIBUTE17,
           ATTRIBUTE18,
           ATTRIBUTE19,
           ATTRIBUTE20,
           ORIG_SYS_DISCOUNT_REF          ,
           CHANGE_SEQUENCE                ,
           UPDATE_ALLOWED                 ,
           CHANGE_REASON_CODE             ,
           CHANGE_REASON_TEXT             ,
           COST_ID                        ,
           TAX_CODE                       ,
           TAX_EXEMPT_FLAG                ,
           TAX_EXEMPT_NUMBER              ,
           TAX_EXEMPT_REASON_CODE         ,
           PARENT_ADJUSTMENT_ID           ,
           INVOICED_FLAG                  ,
           ESTIMATED_FLAG                 ,
           INC_IN_SALES_PERFORMANCE       ,
           SPLIT_ACTION_CODE              ,
           ADJUSTED_AMOUNT                ,
           CHARGE_TYPE_CODE               ,
           CHARGE_SUBTYPE_CODE            ,
           RANGE_BREAK_QUANTITY           ,
           ACCRUAL_CONVERSION_RATE        ,
           PRICING_GROUP_SEQUENCE         ,
           ACCRUAL_FLAG                   ,
           LIST_LINE_NO                   ,
           SOURCE_SYSTEM_CODE             ,
           BENEFIT_QTY                    ,
           BENEFIT_UOM_CODE               ,
           PRINT_ON_INVOICE_FLAG          ,
           EXPIRATION_DATE                ,
           REBATE_TRANSACTION_TYPE_CODE   ,
           REBATE_TRANSACTION_REFERENCE   ,
           REBATE_PAYMENT_SYSTEM_CODE     ,
           REDEEMED_DATE                  ,
           REDEEMED_FLAG                  ,
           MODIFIER_LEVEL_CODE            ,
           PRICE_BREAK_TYPE_CODE          ,
           SUBSTITUTION_ATTRIBUTE         ,
           PRORATION_TYPE_CODE            ,
           INCLUDE_ON_RETURNS_FLAG        ,
           CREDIT_OR_CHARGE_FLAG         ,
		 quote_shipment_id,
		 OPERAND_PER_PQTY,
		 ADJUSTED_AMOUNT_PER_PQTY,
           OBJECT_VERSION_NUMBER
            )
            VALUES (
           px_PRICE_ADJUSTMENT_ID,
           ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_HEADER_ID),
           decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_LINE_ID),
           decode( p_MODIFIER_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_MODIFIER_HEADER_ID),
           decode( p_MODIFIER_LINE_ID, FND_API.G_MISS_NUM, NULL, p_MODIFIER_LINE_ID),
           decode( p_MODIFIER_LINE_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_MODIFIER_LINE_TYPE_CODE),
           decode( p_MODIFIER_MECHANISM_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_MODIFIER_MECHANISM_TYPE_CODE),
           decode( p_MODIFIED_FROM, FND_API.G_MISS_NUM, NULL, p_MODIFIED_FROM),
           decode( p_MODIFIED_TO, FND_API.G_MISS_NUM, NULL, p_MODIFIED_TO),
           decode( p_OPERAND, FND_API.G_MISS_NUM, NULL, p_OPERAND),
           decode( p_ARITHMETIC_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_ARITHMETIC_OPERATOR),
           decode( p_AUTOMATIC_FLAG, FND_API.G_MISS_CHAR, NULL, p_AUTOMATIC_FLAG),
           decode( p_UPDATE_ALLOWABLE_FLAG, FND_API.G_MISS_CHAR, NULL, p_UPDATE_ALLOWABLE_FLAG),
           decode( p_UPDATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_UPDATED_FLAG),
           decode( p_APPLIED_FLAG, FND_API.G_MISS_CHAR, NULL, p_APPLIED_FLAG),
           decode( p_ON_INVOICE_FLAG, FND_API.G_MISS_CHAR, NULL, p_ON_INVOICE_FLAG),
           decode( p_PRICING_PHASE_ID, FND_API.G_MISS_NUM, NULL, p_PRICING_PHASE_ID),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE16),
           decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE17),
           decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE18),
           decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE19),
           decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE20),
           decode( p_ORIG_SYS_DISCOUNT_REF, FND_API.G_MISS_CHAR, NULL, p_ORIG_SYS_DISCOUNT_REF),
           decode( p_CHANGE_SEQUENCE, FND_API.G_MISS_CHAR, NULL,p_CHANGE_SEQUENCE)         ,
           decode( p_UPDATE_ALLOWED, FND_API.G_MISS_CHAR, NULL,p_UPDATE_ALLOWED)         ,
           decode( p_CHANGE_REASON_CODE, FND_API.G_MISS_CHAR, NULL,p_CHANGE_REASON_CODE)         ,
           decode( p_CHANGE_REASON_TEXT, FND_API.G_MISS_CHAR, NULL,p_CHANGE_REASON_TEXT)         ,
           decode( p_COST_ID, FND_API.G_MISS_NUM, NULL,p_COST_ID)                 ,
           decode( p_TAX_CODE, FND_API.G_MISS_CHAR, NULL,p_TAX_CODE)         ,
           decode( p_TAX_EXEMPT_FLAG, FND_API.G_MISS_CHAR, NULL,p_TAX_EXEMPT_FLAG)         ,
           decode( p_TAX_EXEMPT_NUMBER, FND_API.G_MISS_CHAR, NULL,p_TAX_EXEMPT_NUMBER)         ,
           decode( p_TAX_EXEMPT_REASON_CODE, FND_API.G_MISS_CHAR, NULL,p_TAX_EXEMPT_REASON_CODE)         ,
           decode( p_PARENT_ADJUSTMENT_ID, FND_API.G_MISS_NUM, NULL,p_PARENT_ADJUSTMENT_ID)                 ,
           decode( p_INVOICED_FLAG, FND_API.G_MISS_CHAR, NULL,p_INVOICED_FLAG)         ,
           decode( p_ESTIMATED_FLAG, FND_API.G_MISS_CHAR, NULL,p_ESTIMATED_FLAG)         ,
           decode( p_INC_IN_SALES_PERFORMANCE, FND_API.G_MISS_CHAR, NULL,p_INC_IN_SALES_PERFORMANCE)         ,
           decode( p_SPLIT_ACTION_CODE, FND_API.G_MISS_CHAR, NULL,p_SPLIT_ACTION_CODE)         ,
           decode( p_ADJUSTED_AMOUNT, FND_API.G_MISS_NUM, NULL,p_ADJUSTED_AMOUNT)                 ,
           decode( p_CHARGE_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,p_CHARGE_TYPE_CODE)         ,
           decode( p_CHARGE_SUBTYPE_CODE, FND_API.G_MISS_CHAR, NULL,p_CHARGE_SUBTYPE_CODE)         ,
           decode( p_RANGE_BREAK_QUANTITY, FND_API.G_MISS_NUM, NULL,p_RANGE_BREAK_QUANTITY)                 ,
           decode( p_ACCRUAL_CONVERSION_RATE, FND_API.G_MISS_NUM, NULL,p_ACCRUAL_CONVERSION_RATE)                 ,
           decode( p_PRICING_GROUP_SEQUENCE, FND_API.G_MISS_NUM, NULL,p_PRICING_GROUP_SEQUENCE)                 ,
           decode( p_ACCRUAL_FLAG, FND_API.G_MISS_CHAR, NULL,p_ACCRUAL_FLAG)         ,
           decode( p_LIST_LINE_NO, FND_API.G_MISS_CHAR, NULL,p_LIST_LINE_NO)         ,
           decode( p_SOURCE_SYSTEM_CODE, FND_API.G_MISS_CHAR, NULL,p_SOURCE_SYSTEM_CODE)         ,
           decode( p_BENEFIT_QTY, FND_API.G_MISS_NUM, NULL,p_BENEFIT_QTY)                 ,
           decode( p_BENEFIT_UOM_CODE, FND_API.G_MISS_CHAR, NULL,p_BENEFIT_UOM_CODE)         ,
           decode( p_PRINT_ON_INVOICE_FLAG, FND_API.G_MISS_CHAR, NULL,p_PRINT_ON_INVOICE_FLAG)         ,
           ASO_UTILITY_PVT.decode( p_EXPIRATION_DATE, FND_API.G_MISS_DATE, NULL,p_EXPIRATION_DATE)         ,
           decode( p_REBATE_TRANSACTION_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,p_REBATE_TRANSACTION_TYPE_CODE)         ,
           decode( p_REBATE_TRANSACTION_REFERENCE, FND_API.G_MISS_CHAR, NULL,p_REBATE_TRANSACTION_REFERENCE)         ,
           decode( p_REBATE_PAYMENT_SYSTEM_CODE, FND_API.G_MISS_CHAR, NULL,p_REBATE_PAYMENT_SYSTEM_CODE)         ,
           ASO_UTILITY_PVT.decode( p_REDEEMED_DATE, FND_API.G_MISS_DATE, NULL,p_REDEEMED_DATE)         ,
           decode( p_REDEEMED_FLAG, FND_API.G_MISS_CHAR, NULL,p_REDEEMED_FLAG)         ,
           decode( p_MODIFIER_LEVEL_CODE, FND_API.G_MISS_CHAR, NULL,p_MODIFIER_LEVEL_CODE)         ,
           decode( p_PRICE_BREAK_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,p_PRICE_BREAK_TYPE_CODE)         ,
           decode( p_SUBSTITUTION_ATTRIBUTE, FND_API.G_MISS_CHAR, NULL,p_SUBSTITUTION_ATTRIBUTE)         ,
           decode( p_PRORATION_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,p_PRORATION_TYPE_CODE)         ,
           decode( p_INCLUDE_ON_RETURNS_FLAG, FND_API.G_MISS_CHAR, NULL,p_INCLUDE_ON_RETURNS_FLAG)         ,
           decode( p_CREDIT_OR_CHARGE_FLAG, FND_API.G_MISS_CHAR, NULL,p_CREDIT_OR_CHARGE_FLAG)    ,
           decode( p_quote_shipment_id, FND_API.G_MISS_NUM, NULL,p_quote_shipment_id),
           decode( p_OPERAND_PER_PQTY, FND_API.G_MISS_NUM, NULL,p_OPERAND_PER_PQTY),
           decode( p_ADJUSTED_AMOUNT_PER_PQTY, FND_API.G_MISS_NUM, NULL,p_ADJUSTED_AMOUNT_PER_PQTY),
		 decode ( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,1,NULL,1, p_OBJECT_VERSION_NUMBER)
            );
End Insert_Row;

PROCEDURE Update_Row(
          p_PRICE_ADJUSTMENT_ID                      NUMBER,
          p_CREATION_DATE                            DATE,
          p_CREATED_BY                               NUMBER,
          p_LAST_UPDATE_DATE                         DATE,
          p_LAST_UPDATED_BY                          NUMBER,
          p_LAST_UPDATE_LOGIN                        NUMBER,
          p_PROGRAM_APPLICATION_ID                   NUMBER,
          p_PROGRAM_ID                               NUMBER,
          p_PROGRAM_UPDATE_DATE                      DATE,
          p_REQUEST_ID                               NUMBER,
          p_QUOTE_HEADER_ID                          NUMBER,
          p_QUOTE_LINE_ID                            NUMBER,
          p_MODIFIER_HEADER_ID                       NUMBER,
          p_MODIFIER_LINE_ID                         NUMBER,
          p_MODIFIER_LINE_TYPE_CODE                  VARCHAR2,
          p_MODIFIER_MECHANISM_TYPE_CODE             VARCHAR2,
          p_MODIFIED_FROM                            NUMBER,
          p_MODIFIED_TO                              NUMBER,
          p_OPERAND                                  NUMBER,
          p_ARITHMETIC_OPERATOR                      VARCHAR2,
          p_AUTOMATIC_FLAG                           VARCHAR2,
          p_UPDATE_ALLOWABLE_FLAG                    VARCHAR2,
          p_UPDATED_FLAG                             VARCHAR2,
          p_APPLIED_FLAG                             VARCHAR2,
          p_ON_INVOICE_FLAG                          VARCHAR2,
          p_PRICING_PHASE_ID                         NUMBER,
          p_ATTRIBUTE_CATEGORY                       VARCHAR2,
          p_ATTRIBUTE1                               VARCHAR2,
          p_ATTRIBUTE2                               VARCHAR2,
          p_ATTRIBUTE3                               VARCHAR2,
          p_ATTRIBUTE4                               VARCHAR2,
          p_ATTRIBUTE5                               VARCHAR2,
          p_ATTRIBUTE6                               VARCHAR2,
          p_ATTRIBUTE7                               VARCHAR2,
          p_ATTRIBUTE8                               VARCHAR2,
          p_ATTRIBUTE9                               VARCHAR2,
          p_ATTRIBUTE10                              VARCHAR2,
          p_ATTRIBUTE11                              VARCHAR2,
          p_ATTRIBUTE12                              VARCHAR2,
          p_ATTRIBUTE13                              VARCHAR2,
          p_ATTRIBUTE14                              VARCHAR2,
          p_ATTRIBUTE15                              VARCHAR2,
          p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
          p_ORIG_SYS_DISCOUNT_REF                    VARCHAR2,
          p_CHANGE_SEQUENCE                          VARCHAR2,
          --p_LIST_HEADER_ID                         NUMBER,
          --p_LIST_LINE_ID                           NUMBER,
          --p_LIST_LINE_TYPE_CODE                    VARCHAR2,
          p_UPDATE_ALLOWED                           VARCHAR2,
          p_CHANGE_REASON_CODE                       VARCHAR2,
          p_CHANGE_REASON_TEXT                       VARCHAR2,
          p_COST_ID                                  NUMBER,
          p_TAX_CODE                                 VARCHAR2,
          p_TAX_EXEMPT_FLAG                          VARCHAR2,
          p_TAX_EXEMPT_NUMBER                        VARCHAR2,
          p_TAX_EXEMPT_REASON_CODE                   VARCHAR2,
          p_PARENT_ADJUSTMENT_ID                     NUMBER,
          p_INVOICED_FLAG                            VARCHAR2,
          p_ESTIMATED_FLAG                           VARCHAR2,
          p_INC_IN_SALES_PERFORMANCE                 VARCHAR2,
          p_SPLIT_ACTION_CODE                        VARCHAR2,
          p_ADJUSTED_AMOUNT                          NUMBER,
          p_CHARGE_TYPE_CODE                         VARCHAR2,
          p_CHARGE_SUBTYPE_CODE                      VARCHAR2,
          p_RANGE_BREAK_QUANTITY                     NUMBER,
          p_ACCRUAL_CONVERSION_RATE                  NUMBER,
          p_PRICING_GROUP_SEQUENCE                   NUMBER,
          p_ACCRUAL_FLAG                             VARCHAR2,
          p_LIST_LINE_NO                             VARCHAR2,
          p_SOURCE_SYSTEM_CODE                       VARCHAR2,
          p_BENEFIT_QTY                              NUMBER,
          p_BENEFIT_UOM_CODE                         VARCHAR2,
          p_PRINT_ON_INVOICE_FLAG                    VARCHAR2,
          p_EXPIRATION_DATE                          DATE,
          p_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2,
          p_REBATE_TRANSACTION_REFERENCE             VARCHAR2,
          p_REBATE_PAYMENT_SYSTEM_CODE               VARCHAR2,
          p_REDEEMED_DATE                            DATE,
          p_REDEEMED_FLAG                            VARCHAR2,
          p_MODIFIER_LEVEL_CODE                      VARCHAR2,
          p_PRICE_BREAK_TYPE_CODE                    VARCHAR2,
          p_SUBSTITUTION_ATTRIBUTE                   VARCHAR2,
          p_PRORATION_TYPE_CODE                      VARCHAR2,
          p_INCLUDE_ON_RETURNS_FLAG                  VARCHAR2,
          p_CREDIT_OR_CHARGE_FLAG                    VARCHAR2,
		p_quote_shipment_id                         NUMBER,
		p_OPERAND_PER_PQTY                         NUMBER,
		p_ADJUSTED_AMOUNT_PER_PQTY                 NUMBER,
          p_OBJECT_VERSION_NUMBER                     NUMBER
          )

 IS
 BEGIN
    Update ASO_PRICE_ADJUSTMENTS
    SET
            /*  CREATION_DATE = ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),*/
              LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              QUOTE_HEADER_ID = decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, QUOTE_HEADER_ID, p_QUOTE_HEADER_ID),
              QUOTE_LINE_ID = decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, QUOTE_LINE_ID, p_QUOTE_LINE_ID),
              MODIFIER_HEADER_ID = decode( p_MODIFIER_HEADER_ID, FND_API.G_MISS_NUM, MODIFIER_HEADER_ID, p_MODIFIER_HEADER_ID),
              MODIFIER_LINE_ID = decode( p_MODIFIER_LINE_ID, FND_API.G_MISS_NUM, MODIFIER_LINE_ID, p_MODIFIER_LINE_ID),
              MODIFIER_LINE_TYPE_CODE = decode( p_MODIFIER_LINE_TYPE_CODE, FND_API.G_MISS_CHAR, MODIFIER_LINE_TYPE_CODE, p_MODIFIER_LINE_TYPE_CODE),
              MODIFIER_MECHANISM_TYPE_CODE = decode( p_MODIFIER_MECHANISM_TYPE_CODE, FND_API.G_MISS_CHAR, MODIFIER_MECHANISM_TYPE_CODE, p_MODIFIER_MECHANISM_TYPE_CODE),
              MODIFIED_FROM = decode( p_MODIFIED_FROM, FND_API.G_MISS_NUM, MODIFIED_FROM, p_MODIFIED_FROM),
              MODIFIED_TO = decode( p_MODIFIED_TO, FND_API.G_MISS_NUM, MODIFIED_TO, p_MODIFIED_TO),
              OPERAND = decode( p_OPERAND, FND_API.G_MISS_NUM, OPERAND, p_OPERAND),
              ARITHMETIC_OPERATOR = decode( p_ARITHMETIC_OPERATOR, FND_API.G_MISS_CHAR, ARITHMETIC_OPERATOR, p_ARITHMETIC_OPERATOR),
              AUTOMATIC_FLAG = decode( p_AUTOMATIC_FLAG, FND_API.G_MISS_CHAR, AUTOMATIC_FLAG, p_AUTOMATIC_FLAG),
              UPDATE_ALLOWABLE_FLAG = decode( p_UPDATE_ALLOWABLE_FLAG, FND_API.G_MISS_CHAR, UPDATE_ALLOWABLE_FLAG, p_UPDATE_ALLOWABLE_FLAG),
              UPDATED_FLAG = decode( p_UPDATED_FLAG, FND_API.G_MISS_CHAR, UPDATED_FLAG, p_UPDATED_FLAG),
              APPLIED_FLAG = decode( p_APPLIED_FLAG, FND_API.G_MISS_CHAR, APPLIED_FLAG, p_APPLIED_FLAG),
              ON_INVOICE_FLAG = decode( p_ON_INVOICE_FLAG, FND_API.G_MISS_CHAR, ON_INVOICE_FLAG, p_ON_INVOICE_FLAG),
              PRICING_PHASE_ID = decode( p_PRICING_PHASE_ID, FND_API.G_MISS_NUM, PRICING_PHASE_ID, p_PRICING_PHASE_ID),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15) ,
              ATTRIBUTE16 = decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, ATTRIBUTE16, p_ATTRIBUTE16),
              ATTRIBUTE17 = decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, ATTRIBUTE17, p_ATTRIBUTE17),
              ATTRIBUTE18 = decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, ATTRIBUTE18, p_ATTRIBUTE18),
              ATTRIBUTE19 = decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, ATTRIBUTE19, p_ATTRIBUTE19),
              ATTRIBUTE20 = decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, ATTRIBUTE20, p_ATTRIBUTE20),
            ORIG_SYS_DISCOUNT_REF = decode( p_ORIG_SYS_DISCOUNT_REF, FND_API.G_MISS_CHAR, ORIG_SYS_DISCOUNT_REF, p_ORIG_SYS_DISCOUNT_REF),
           CHANGE_SEQUENCE = decode( p_CHANGE_SEQUENCE, FND_API.G_MISS_CHAR, CHANGE_SEQUENCE,p_CHANGE_SEQUENCE),
           UPDATE_ALLOWED = decode( p_UPDATE_ALLOWED, FND_API.G_MISS_CHAR, UPDATE_ALLOWED,p_UPDATE_ALLOWED),
           CHANGE_REASON_CODE = decode( p_CHANGE_REASON_CODE, FND_API.G_MISS_CHAR, CHANGE_REASON_CODE,p_CHANGE_REASON_CODE),
           CHANGE_REASON_TEXT = decode( p_CHANGE_REASON_TEXT, FND_API.G_MISS_CHAR, CHANGE_REASON_TEXT,p_CHANGE_REASON_TEXT),
           COST_ID = decode( p_COST_ID, FND_API.G_MISS_NUM, COST_ID,p_COST_ID),
           TAX_CODE = decode( p_TAX_CODE, FND_API.G_MISS_CHAR, TAX_CODE,p_TAX_CODE),
           TAX_EXEMPT_FLAG = decode( p_TAX_EXEMPT_FLAG, FND_API.G_MISS_CHAR, TAX_EXEMPT_FLAG,p_TAX_EXEMPT_FLAG),
           TAX_EXEMPT_NUMBER = decode( p_TAX_EXEMPT_NUMBER, FND_API.G_MISS_CHAR, TAX_EXEMPT_NUMBER,p_TAX_EXEMPT_NUMBER),
           TAX_EXEMPT_REASON_CODE = decode( p_TAX_EXEMPT_REASON_CODE, FND_API.G_MISS_CHAR, TAX_EXEMPT_REASON_CODE,p_TAX_EXEMPT_REASON_CODE),
           PARENT_ADJUSTMENT_ID = decode( p_PARENT_ADJUSTMENT_ID, FND_API.G_MISS_NUM, PARENT_ADJUSTMENT_ID,p_PARENT_ADJUSTMENT_ID),
           INVOICED_FLAG = decode( p_INVOICED_FLAG, FND_API.G_MISS_CHAR, INVOICED_FLAG,p_INVOICED_FLAG),
           ESTIMATED_FLAG = decode( p_ESTIMATED_FLAG, FND_API.G_MISS_CHAR, ESTIMATED_FLAG,p_ESTIMATED_FLAG),
           INC_IN_SALES_PERFORMANCE = decode( p_INC_IN_SALES_PERFORMANCE, FND_API.G_MISS_CHAR, INC_IN_SALES_PERFORMANCE,p_INC_IN_SALES_PERFORMANCE),
           SPLIT_ACTION_CODE  =  decode  ( p_SPLIT_ACTION_CODE, FND_API.G_MISS_CHAR, SPLIT_ACTION_CODE,p_SPLIT_ACTION_CODE),
           ADJUSTED_AMOUNT  =  decode  ( p_ADJUSTED_AMOUNT, FND_API.G_MISS_NUM, ADJUSTED_AMOUNT,p_ADJUSTED_AMOUNT),
           CHARGE_TYPE_CODE  =  decode  ( p_CHARGE_TYPE_CODE, FND_API.G_MISS_CHAR, CHARGE_TYPE_CODE,p_CHARGE_TYPE_CODE),
           CHARGE_SUBTYPE_CODE  =  decode  ( p_CHARGE_SUBTYPE_CODE, FND_API.G_MISS_CHAR, CHARGE_SUBTYPE_CODE,p_CHARGE_SUBTYPE_CODE),
            RANGE_BREAK_QUANTITY =  decode  ( p_RANGE_BREAK_QUANTITY, FND_API.G_MISS_NUM, RANGE_BREAK_QUANTITY,p_RANGE_BREAK_QUANTITY),
            ACCRUAL_CONVERSION_RATE =  decode  ( p_ACCRUAL_CONVERSION_RATE, FND_API.G_MISS_NUM, ACCRUAL_CONVERSION_RATE,p_ACCRUAL_CONVERSION_RATE),
            PRICING_GROUP_SEQUENCE =  decode ( p_PRICING_GROUP_SEQUENCE, FND_API.G_MISS_NUM, PRICING_GROUP_SEQUENCE,p_PRICING_GROUP_SEQUENCE),
            ACCRUAL_FLAG =  decode  ( p_ACCRUAL_FLAG, FND_API.G_MISS_CHAR, ACCRUAL_FLAG,p_ACCRUAL_FLAG),
            LIST_LINE_NO =  decode ( p_LIST_LINE_NO, FND_API.G_MISS_CHAR, LIST_LINE_NO,p_LIST_LINE_NO),
            SOURCE_SYSTEM_CODE =  decode  ( p_SOURCE_SYSTEM_CODE, FND_API.G_MISS_CHAR, SOURCE_SYSTEM_CODE,p_SOURCE_SYSTEM_CODE),
            BENEFIT_QTY =  decode  ( p_BENEFIT_QTY, FND_API.G_MISS_NUM, BENEFIT_QTY,p_BENEFIT_QTY),
            BENEFIT_UOM_CODE =  decode  ( p_BENEFIT_UOM_CODE, FND_API.G_MISS_CHAR, BENEFIT_UOM_CODE,p_BENEFIT_UOM_CODE),
            PRINT_ON_INVOICE_FLAG =  decode  ( p_PRINT_ON_INVOICE_FLAG, FND_API.G_MISS_CHAR, PRINT_ON_INVOICE_FLAG,p_PRINT_ON_INVOICE_FLAG),
            EXPIRATION_DATE = ASO_UTILITY_PVT.decode( p_EXPIRATION_DATE, FND_API.G_MISS_DATE, EXPIRATION_DATE,p_EXPIRATION_DATE),
            REBATE_TRANSACTION_TYPE_CODE =  decode( p_REBATE_TRANSACTION_TYPE_CODE, FND_API.G_MISS_CHAR, REBATE_TRANSACTION_TYPE_CODE,p_REBATE_TRANSACTION_TYPE_CODE),
            REBATE_TRANSACTION_REFERENCE =  decode( p_REBATE_TRANSACTION_REFERENCE, FND_API.G_MISS_CHAR, REBATE_TRANSACTION_REFERENCE,p_REBATE_TRANSACTION_REFERENCE),
            REBATE_PAYMENT_SYSTEM_CODE =  decode( p_REBATE_PAYMENT_SYSTEM_CODE, FND_API.G_MISS_CHAR, REBATE_PAYMENT_SYSTEM_CODE,p_REBATE_PAYMENT_SYSTEM_CODE),
            REDEEMED_DATE = ASO_UTILITY_PVT.decode( p_REDEEMED_DATE, FND_API.G_MISS_DATE, REDEEMED_DATE,p_REDEEMED_DATE),
            REDEEMED_FLAG =  decode( p_REDEEMED_FLAG, FND_API.G_MISS_CHAR, REDEEMED_FLAG,p_REDEEMED_FLAG),
            MODIFIER_LEVEL_CODE =  decode( p_MODIFIER_LEVEL_CODE, FND_API.G_MISS_CHAR, MODIFIER_LEVEL_CODE,p_MODIFIER_LEVEL_CODE),
            PRICE_BREAK_TYPE_CODE =  decode( p_PRICE_BREAK_TYPE_CODE, FND_API.G_MISS_CHAR, PRICE_BREAK_TYPE_CODE,p_PRICE_BREAK_TYPE_CODE),
            SUBSTITUTION_ATTRIBUTE =  decode( p_SUBSTITUTION_ATTRIBUTE, FND_API.G_MISS_CHAR, SUBSTITUTION_ATTRIBUTE,p_SUBSTITUTION_ATTRIBUTE),
            PRORATION_TYPE_CODE =  decode( p_PRORATION_TYPE_CODE, FND_API.G_MISS_CHAR, PRORATION_TYPE_CODE,p_PRORATION_TYPE_CODE),
            INCLUDE_ON_RETURNS_FLAG =  decode( p_INCLUDE_ON_RETURNS_FLAG, FND_API.G_MISS_CHAR, INCLUDE_ON_RETURNS_FLAG,p_INCLUDE_ON_RETURNS_FLAG),
            CREDIT_OR_CHARGE_FLAG = decode( p_CREDIT_OR_CHARGE_FLAG, FND_API.G_MISS_CHAR, CREDIT_OR_CHARGE_FLAG,p_CREDIT_OR_CHARGE_FLAG),
		  quote_shipment_id  =  decode( p_quote_shipment_id, FND_API.G_MISS_NUM, quote_shipment_id,p_quote_shipment_id),
		  OPERAND_PER_PQTY  =  decode( p_OPERAND_PER_PQTY, FND_API.G_MISS_NUM, OPERAND_PER_PQTY,p_OPERAND_PER_PQTY),
		  ADJUSTED_AMOUNT_PER_PQTY  =  decode( p_ADJUSTED_AMOUNT_PER_PQTY, FND_API.G_MISS_NUM, ADJUSTED_AMOUNT_PER_PQTY,p_ADJUSTED_AMOUNT_PER_PQTY),
		  OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, nvl(OBJECT_VERSION_NUMBER,0)+1, nvl(p_OBJECT_VERSION_NUMBER, nvl(OBJECT_VERSION_NUMBER,0))+1)
    where PRICE_ADJUSTMENT_ID = p_PRICE_ADJUSTMENT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PRICE_ADJUSTMENT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ASO_PRICE_ADJUSTMENTS
    WHERE PRICE_ADJUSTMENT_ID = p_PRICE_ADJUSTMENT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


PROCEDURE Delete_Row(
    p_PRICE_ADJ_ID  NUMBER)
 IS

 BEGIN

    DELETE FROM ASO_PRICE_ADJ_ATTRIBS
    WHERE PRICE_ADJUSTMENT_ID = p_PRICE_ADJ_ID;
    If (SQL%NOTFOUND) then
       null;
    End If;

-- delete from aso_price adjustments the id and the related id
    DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
    WHERE PRICE_ADJUSTMENT_ID = p_PRICE_ADJ_ID
    OR RLTD_PRICE_ADJ_ID = p_PRICE_ADJ_ID;
    If (SQL%NOTFOUND) then
       null;
    End If;


-- delete from aso_price_adjustments

    DELETE FROM ASO_PRICE_ADJUSTMENTS
    WHERE PRICE_ADJUSTMENT_ID = p_PRICE_ADJ_ID;
    If (SQL%NOTFOUND) then
       null;
        RAISE NO_DATA_FOUND;
    End If;
 END Delete_Row;

PROCEDURE Delete_Row(
    p_LINE_ID  NUMBER,
    p_TYPE_CODE VARCHAR2)
IS
  l_price_adj_id NUMBER;


Cursor C_line_adj(l_quote_line_id NUMBER) IS
  SELECT price_adjustment_id
  FROM aso_price_adjustments
  where quote_line_id = l_quote_line_id;

Cursor C_shipment_adj(l_quote_shipment_id NUMBER) IS
  SELECT price_adjustment_id
  FROM aso_price_adjustments
  where quote_shipment_id = l_quote_shipment_id;

BEGIN

  If p_TYPE_CODE = 'QUOTE_LINE' THEN

     DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
     WHERE QUOTE_LINE_ID = p_line_id;
     If (SQL%NOTFOUND) then
       null;
     End If;

     For i in  C_line_adj(p_line_id) LOOP
        Delete_Row( p_PRICE_ADJ_ID => i.price_adjustment_id);
     END LOOP;

  elsif p_TYPE_CODE = 'SHIPMENT_LINE' THEN

     DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
     WHERE QUOTE_SHIPMENT_ID = p_line_id;
     If (SQL%NOTFOUND) then
       null;
     End If;

     For i in  C_shipment_adj(p_line_id) LOOP
        Delete_Row( p_PRICE_ADJ_ID => i.price_adjustment_id);
     END LOOP;

  end if;

 END Delete_Row;

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_PRICE_ADJUSTMENT_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID    NUMBER,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_MODIFIER_HEADER_ID    NUMBER,
          p_MODIFIER_LINE_ID    NUMBER,
          p_MODIFIER_LINE_TYPE_CODE    VARCHAR2,
          p_MODIFIER_MECHANISM_TYPE_CODE    VARCHAR2,
          p_MODIFIED_FROM    NUMBER,
          p_MODIFIED_TO    NUMBER,
          p_OPERAND    NUMBER,
          p_ARITHMETIC_OPERATOR    VARCHAR2,
          p_AUTOMATIC_FLAG    VARCHAR2,
          p_UPDATE_ALLOWABLE_FLAG    VARCHAR2,
          p_UPDATED_FLAG    VARCHAR2,
          p_APPLIED_FLAG    VARCHAR2,
          p_ON_INVOICE_FLAG    VARCHAR2,
          p_PRICING_PHASE_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ORIG_SYS_DISCOUNT_REF                    VARCHAR2 ,
          p_CHANGE_SEQUENCE                          VARCHAR2,
          -- p_LIST_HEADER_ID                           NUMBER,
          -- p_LIST_LINE_ID                             NUMBER,
          -- p_LIST_LINE_TYPE_CODE                      VARCHAR2,
          p_UPDATE_ALLOWED                           VARCHAR2,
          p_CHANGE_REASON_CODE                       VARCHAR2,
          p_CHANGE_REASON_TEXT                       VARCHAR2,
          p_COST_ID                                  NUMBER,
          p_TAX_CODE                                 VARCHAR2,
          p_TAX_EXEMPT_FLAG                          VARCHAR2,
          p_TAX_EXEMPT_NUMBER                        VARCHAR2,
          p_TAX_EXEMPT_REASON_CODE                   VARCHAR2,
          p_PARENT_ADJUSTMENT_ID                     NUMBER,
          p_INVOICED_FLAG                            VARCHAR2,
          p_ESTIMATED_FLAG                           VARCHAR2,
          p_INC_IN_SALES_PERFORMANCE                 VARCHAR2,
          p_SPLIT_ACTION_CODE                        VARCHAR2,
          p_ADJUSTED_AMOUNT                          NUMBER,
          p_CHARGE_TYPE_CODE                         VARCHAR2,
          p_CHARGE_SUBTYPE_CODE                      VARCHAR2,
          p_RANGE_BREAK_QUANTITY                     NUMBER,
          p_ACCRUAL_CONVERSION_RATE                  NUMBER,
          p_PRICING_GROUP_SEQUENCE                   NUMBER,
          p_ACCRUAL_FLAG                             VARCHAR2,
          p_LIST_LINE_NO                             VARCHAR2,
          p_SOURCE_SYSTEM_CODE                       VARCHAR2,
          p_BENEFIT_QTY                              NUMBER,
          p_BENEFIT_UOM_CODE                         VARCHAR2,
          p_PRINT_ON_INVOICE_FLAG                    VARCHAR2,
          p_EXPIRATION_DATE                          DATE,
          p_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2,
          p_REBATE_TRANSACTION_REFERENCE             VARCHAR2,
          p_REBATE_PAYMENT_SYSTEM_CODE               VARCHAR2,
          p_REDEEMED_DATE                            DATE,
          p_REDEEMED_FLAG                            VARCHAR2,
          p_MODIFIER_LEVEL_CODE                      VARCHAR2,
          p_PRICE_BREAK_TYPE_CODE                    VARCHAR2,
          p_SUBSTITUTION_ATTRIBUTE                   VARCHAR2,
          p_PRORATION_TYPE_CODE                      VARCHAR2,
          p_INCLUDE_ON_RETURNS_FLAG                  VARCHAR2,
          p_CREDIT_OR_CHARGE_FLAG                    VARCHAR2,
		p_quote_shipment_id                        NUMBER)

 IS
   CURSOR C IS
        SELECT TAX_CODE,
	   --OBJECT_VERSION_NUMBER,
TAX_EXEMPT_FLAG,
TAX_EXEMPT_NUMBER,
TAX_EXEMPT_REASON_CODE,
PARENT_ADJUSTMENT_ID,
INVOICED_FLAG,
ESTIMATED_FLAG,
INC_IN_SALES_PERFORMANCE,
SPLIT_ACTION_CODE,
ADJUSTED_AMOUNT,
CHARGE_TYPE_CODE,
CHARGE_SUBTYPE_CODE,
RANGE_BREAK_QUANTITY,
ACCRUAL_CONVERSION_RATE,
PRICING_GROUP_SEQUENCE,
ACCRUAL_FLAG,
LIST_LINE_NO,
SOURCE_SYSTEM_CODE,
BENEFIT_QTY,
BENEFIT_UOM_CODE,
PRINT_ON_INVOICE_FLAG,
EXPIRATION_DATE,
REBATE_TRANSACTION_TYPE_CODE,
REBATE_TRANSACTION_REFERENCE,
REBATE_PAYMENT_SYSTEM_CODE,
REDEEMED_DATE,
REDEEMED_FLAG,
MODIFIER_LEVEL_CODE,
PRICE_BREAK_TYPE_CODE,
SUBSTITUTION_ATTRIBUTE,
PRORATION_TYPE_CODE,
INCLUDE_ON_RETURNS_FLAG,
CREDIT_OR_CHARGE_FLAG,
ORIG_SYS_DISCOUNT_REF,
MODIFIED_TO,
OPERAND,
ARITHMETIC_OPERATOR,
AUTOMATIC_FLAG,
UPDATE_ALLOWABLE_FLAG,
UPDATED_FLAG,
APPLIED_FLAG,
ON_INVOICE_FLAG,
PRICING_PHASE_ID,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
CHANGE_REASON_CODE,
CHANGE_REASON_TEXT,
COST_ID,
PRICE_ADJUSTMENT_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
MODIFIER_HEADER_ID,
MODIFIER_LINE_ID,
MODIFIER_LINE_TYPE_CODE,
MODIFIER_MECHANISM_TYPE_CODE,
MODIFIED_FROM,
LIST_LINE_TYPE_CODE,
UPDATE_ALLOWED,
CHANGE_SEQUENCE,
LIST_HEADER_ID,
LIST_LINE_ID,
quote_shipment_id
         FROM ASO_PRICE_ADJUSTMENTS
        WHERE PRICE_ADJUSTMENT_ID =  p_PRICE_ADJUSTMENT_ID
        FOR UPDATE of PRICE_ADJUSTMENT_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
/*
           (      Recinfo.PRICE_ADJUSTMENT_ID = p_PRICE_ADJUSTMENT_ID)
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND
*/
	  (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
/*
       AND
	   (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
	      OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
		         AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.QUOTE_HEADER_ID = p_QUOTE_HEADER_ID)
            OR (    ( Recinfo.QUOTE_HEADER_ID IS NULL )
                AND (  p_QUOTE_HEADER_ID IS NULL )))
       AND (    ( Recinfo.QUOTE_LINE_ID = p_QUOTE_LINE_ID)
            OR (    ( Recinfo.QUOTE_LINE_ID IS NULL )
                AND (  p_QUOTE_LINE_ID IS NULL )))
       AND (    ( Recinfo.MODIFIER_HEADER_ID = p_MODIFIER_HEADER_ID)
            OR (    ( Recinfo.MODIFIER_HEADER_ID IS NULL )
                AND (  p_MODIFIER_HEADER_ID IS NULL )))
       AND (    ( Recinfo.MODIFIER_LINE_ID = p_MODIFIER_LINE_ID)
            OR (    ( Recinfo.MODIFIER_LINE_ID IS NULL )
                AND (  p_MODIFIER_LINE_ID IS NULL )))
       AND (    ( Recinfo.MODIFIER_LINE_TYPE_CODE = p_MODIFIER_LINE_TYPE_CODE)
            OR (    ( Recinfo.MODIFIER_LINE_TYPE_CODE IS NULL )
                AND (  p_MODIFIER_LINE_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.MODIFIER_MECHANISM_TYPE_CODE = p_MODIFIER_MECHANISM_TYPE_CODE)
            OR (    ( Recinfo.MODIFIER_MECHANISM_TYPE_CODE IS NULL )
                AND (  p_MODIFIER_MECHANISM_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.MODIFIED_FROM = p_MODIFIED_FROM)
            OR (    ( Recinfo.MODIFIED_FROM IS NULL )
                AND (  p_MODIFIED_FROM IS NULL )))
       AND (    ( Recinfo.MODIFIED_TO = p_MODIFIED_TO)
            OR (    ( Recinfo.MODIFIED_TO IS NULL )
                AND (  p_MODIFIED_TO IS NULL )))
       AND (    ( Recinfo.OPERAND = p_OPERAND)
            OR (    ( Recinfo.OPERAND IS NULL )
                AND (  p_OPERAND IS NULL )))
       AND (    ( Recinfo.ARITHMETIC_OPERATOR = p_ARITHMETIC_OPERATOR)
            OR (    ( Recinfo.ARITHMETIC_OPERATOR IS NULL )
                AND (  p_ARITHMETIC_OPERATOR IS NULL )))
       AND (    ( Recinfo.AUTOMATIC_FLAG = p_AUTOMATIC_FLAG)
            OR (    ( Recinfo.AUTOMATIC_FLAG IS NULL )
                AND (  p_AUTOMATIC_FLAG IS NULL )))
       AND (    ( Recinfo.UPDATE_ALLOWABLE_FLAG = p_UPDATE_ALLOWABLE_FLAG)
            OR (    ( Recinfo.UPDATE_ALLOWABLE_FLAG IS NULL )
                AND (  p_UPDATE_ALLOWABLE_FLAG IS NULL )))
       AND (    ( Recinfo.UPDATED_FLAG = p_UPDATED_FLAG)
            OR (    ( Recinfo.UPDATED_FLAG IS NULL )
                AND (  p_UPDATED_FLAG IS NULL )))
       AND (    ( Recinfo.APPLIED_FLAG = p_APPLIED_FLAG)
            OR (    ( Recinfo.APPLIED_FLAG IS NULL )
                AND (  p_APPLIED_FLAG IS NULL )))
       AND (    ( Recinfo.ON_INVOICE_FLAG = p_ON_INVOICE_FLAG)
            OR (    ( Recinfo.ON_INVOICE_FLAG IS NULL )
                AND (  p_ON_INVOICE_FLAG IS NULL )))
       AND (    ( Recinfo.PRICING_PHASE_ID = p_PRICING_PHASE_ID)
            OR (    ( Recinfo.PRICING_PHASE_ID IS NULL )
                AND (  p_PRICING_PHASE_ID IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       AND (    ( Recinfo.ORIG_SYS_DISCOUNT_REF = p_ORIG_SYS_DISCOUNT_REF)
            OR (    ( Recinfo.ORIG_SYS_DISCOUNT_REF IS NULL )
                AND (  p_ORIG_SYS_DISCOUNT_REF IS NULL )))
        AND (    ( Recinfo.CHANGE_SEQUENCE = p_CHANGE_SEQUENCE)
            OR (    ( Recinfo.CHANGE_SEQUENCE IS NULL )
                AND (  p_CHANGE_SEQUENCE IS NULL )))
        AND (    ( Recinfo.UPDATE_ALLOWED = p_UPDATE_ALLOWED)
            OR (    ( Recinfo.UPDATE_ALLOWED IS NULL )
                AND (  p_UPDATE_ALLOWED IS NULL )))
        AND (    ( Recinfo.CHANGE_REASON_CODE = p_CHANGE_REASON_CODE)
            OR (    ( Recinfo.CHANGE_REASON_CODE IS NULL )
                AND (  p_CHANGE_REASON_CODE IS NULL )))
        AND (    ( Recinfo.COST_ID = p_COST_ID)
            OR (    ( Recinfo.COST_ID IS NULL )
                AND (  p_COST_ID IS NULL )))
        AND (    ( Recinfo.TAX_CODE = p_TAX_CODE)
            OR (    ( Recinfo.TAX_CODE IS NULL )
                AND (  p_TAX_CODE IS NULL )))
        AND (    ( Recinfo.TAX_EXEMPT_FLAG = p_TAX_EXEMPT_FLAG)
            OR (    ( Recinfo.TAX_EXEMPT_FLAG IS NULL )
                AND (  p_TAX_EXEMPT_FLAG IS NULL )))
        AND (    ( Recinfo.TAX_EXEMPT_NUMBER = p_TAX_EXEMPT_NUMBER)
            OR (    ( Recinfo.TAX_EXEMPT_NUMBER IS NULL )
                AND (  p_TAX_EXEMPT_NUMBER IS NULL )))
        AND (    ( Recinfo.TAX_EXEMPT_REASON_CODE = p_TAX_EXEMPT_REASON_CODE)
            OR (    ( Recinfo.TAX_EXEMPT_REASON_CODE IS NULL )
                AND (  p_TAX_EXEMPT_REASON_CODE IS NULL )))
        AND (    ( Recinfo.PARENT_ADJUSTMENT_ID = p_PARENT_ADJUSTMENT_ID)
            OR (    ( Recinfo.PARENT_ADJUSTMENT_ID IS NULL )
                AND (  p_PARENT_ADJUSTMENT_ID IS NULL )))
        AND (    ( Recinfo.INVOICED_FLAG = p_INVOICED_FLAG)
            OR (    ( Recinfo.INVOICED_FLAG IS NULL )
                AND (  p_INVOICED_FLAG IS NULL )))
        AND (    ( Recinfo.ESTIMATED_FLAG = p_ESTIMATED_FLAG)
            OR (    ( Recinfo.ESTIMATED_FLAG IS NULL )
                AND (  p_ESTIMATED_FLAG IS NULL )))
        AND (    ( Recinfo.INC_IN_SALES_PERFORMANCE = p_INC_IN_SALES_PERFORMANCE)
            OR (    ( Recinfo.INC_IN_SALES_PERFORMANCE IS NULL )
                AND (  p_INC_IN_SALES_PERFORMANCE IS NULL )))
        AND (    ( Recinfo.SPLIT_ACTION_CODE = p_SPLIT_ACTION_CODE)
            OR (    ( Recinfo.SPLIT_ACTION_CODE IS NULL )
                AND (  p_SPLIT_ACTION_CODE IS NULL )))
        AND (    ( Recinfo.ADJUSTED_AMOUNT = p_ADJUSTED_AMOUNT)
            OR (    ( Recinfo.ADJUSTED_AMOUNT IS NULL )
                AND (  p_ADJUSTED_AMOUNT IS NULL )))
        AND (    ( Recinfo.CHARGE_TYPE_CODE = p_CHARGE_TYPE_CODE)
            OR (    ( Recinfo.CHARGE_TYPE_CODE IS NULL )
                AND (  p_CHARGE_TYPE_CODE IS NULL )))
        AND (    ( Recinfo.CHARGE_SUBTYPE_CODE = p_CHARGE_SUBTYPE_CODE)
            OR (    ( Recinfo.CHARGE_SUBTYPE_CODE IS NULL )
                AND (  p_CHARGE_SUBTYPE_CODE IS NULL )))
        AND (    ( Recinfo.RANGE_BREAK_QUANTITY = p_RANGE_BREAK_QUANTITY)
            OR (    ( Recinfo.RANGE_BREAK_QUANTITY IS NULL )
                AND (  p_RANGE_BREAK_QUANTITY IS NULL )))
        AND (    ( Recinfo.ACCRUAL_CONVERSION_RATE = p_ACCRUAL_CONVERSION_RATE)
            OR (    ( Recinfo.ACCRUAL_CONVERSION_RATE IS NULL )
                AND (  p_ACCRUAL_CONVERSION_RATE IS NULL )))
        AND (    ( Recinfo.PRICING_GROUP_SEQUENCE = p_PRICING_GROUP_SEQUENCE)
            OR (    ( Recinfo.PRICING_GROUP_SEQUENCE IS NULL )
                AND (  p_PRICING_GROUP_SEQUENCE IS NULL )))
        AND (    ( Recinfo.ACCRUAL_FLAG = p_ACCRUAL_FLAG)
            OR (    ( Recinfo.ACCRUAL_FLAG IS NULL )
                AND (  p_ACCRUAL_FLAG IS NULL )))
        AND (    ( Recinfo.LIST_LINE_NO = p_LIST_LINE_NO)
            OR (    ( Recinfo.LIST_LINE_NO IS NULL )
                AND (  p_LIST_LINE_NO IS NULL )))
        AND (    ( Recinfo.SOURCE_SYSTEM_CODE = p_SOURCE_SYSTEM_CODE)
            OR (    ( Recinfo.SOURCE_SYSTEM_CODE IS NULL )
                AND (  p_SOURCE_SYSTEM_CODE IS NULL )))
        AND (    ( Recinfo.BENEFIT_QTY = p_BENEFIT_QTY)
            OR (    ( Recinfo.BENEFIT_QTY IS NULL )
                AND (  p_BENEFIT_QTY IS NULL )))
        AND (    ( Recinfo.BENEFIT_UOM_CODE = p_BENEFIT_UOM_CODE)
            OR (    ( Recinfo.BENEFIT_UOM_CODE IS NULL )
                AND (  p_BENEFIT_UOM_CODE IS NULL )))
        AND (    ( Recinfo.PRINT_ON_INVOICE_FLAG  = p_PRINT_ON_INVOICE_FLAG)
            OR (    ( Recinfo.PRINT_ON_INVOICE_FLAG  IS NULL )
                AND (  p_PRINT_ON_INVOICE_FLAG IS NULL )))
        AND (    ( Recinfo.EXPIRATION_DATE  = p_EXPIRATION_DATE)
            OR (    ( Recinfo.EXPIRATION_DATE  IS NULL )
                AND (  p_EXPIRATION_DATE IS NULL )))
        AND (    ( Recinfo.REBATE_TRANSACTION_TYPE_CODE  = p_REBATE_TRANSACTION_TYPE_CODE)
            OR (    ( Recinfo.REBATE_TRANSACTION_TYPE_CODE  IS NULL )
                AND (  p_REBATE_TRANSACTION_TYPE_CODE IS NULL )))
         AND (    ( Recinfo.REBATE_TRANSACTION_REFERENCE  = p_REBATE_TRANSACTION_REFERENCE)
            OR (    ( Recinfo.REBATE_TRANSACTION_REFERENCE  IS NULL )
                AND (  p_REBATE_TRANSACTION_REFERENCE IS NULL )))
         AND (    ( Recinfo.REBATE_PAYMENT_SYSTEM_CODE  = p_REBATE_PAYMENT_SYSTEM_CODE)
            OR (    ( Recinfo.REBATE_PAYMENT_SYSTEM_CODE  IS NULL )
                AND (  p_REBATE_PAYMENT_SYSTEM_CODE IS NULL )))
        AND (    ( Recinfo.REDEEMED_DATE  = p_REDEEMED_DATE)
            OR (    ( Recinfo.REDEEMED_DATE  IS NULL )
                AND (  p_REDEEMED_DATE IS NULL )))
        AND (    ( Recinfo.REDEEMED_FLAG  = p_REDEEMED_FLAG)
            OR (    ( Recinfo.REDEEMED_FLAG  IS NULL )
                AND (  p_REDEEMED_FLAG IS NULL )))
       AND (    ( Recinfo.MODIFIER_LEVEL_CODE  = p_MODIFIER_LEVEL_CODE)
            OR (    ( Recinfo.MODIFIER_LEVEL_CODE  IS NULL )
                AND (  p_MODIFIER_LEVEL_CODE IS NULL )))
       AND (    ( Recinfo.PRICE_BREAK_TYPE_CODE  = p_PRICE_BREAK_TYPE_CODE)
            OR (    ( Recinfo.PRICE_BREAK_TYPE_CODE  IS NULL )
                AND (  p_PRICE_BREAK_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.SUBSTITUTION_ATTRIBUTE  = p_SUBSTITUTION_ATTRIBUTE)
            OR (    ( Recinfo.SUBSTITUTION_ATTRIBUTE  IS NULL )
                AND (  p_SUBSTITUTION_ATTRIBUTE IS NULL )))
       AND (    ( Recinfo.PRORATION_TYPE_CODE  = p_PRORATION_TYPE_CODE)
            OR (    ( Recinfo.PRORATION_TYPE_CODE  IS NULL )
                AND (  p_PRORATION_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.INCLUDE_ON_RETURNS_FLAG  = p_INCLUDE_ON_RETURNS_FLAG)
            OR (    ( Recinfo.INCLUDE_ON_RETURNS_FLAG  IS NULL )
                AND (  p_INCLUDE_ON_RETURNS_FLAG IS NULL )))
       AND (    ( Recinfo.CREDIT_OR_CHARGE_FLAG  = p_CREDIT_OR_CHARGE_FLAG)
            OR (    ( Recinfo.CREDIT_OR_CHARGE_FLAG  IS NULL )
                AND (  p_CREDIT_OR_CHARGE_FLAG IS NULL )))
       AND (    ( Recinfo.quote_shipment_id  = p_quote_shipment_id)
            OR (    ( Recinfo.quote_shipment_id  IS NULL )
                AND (  p_quote_shipment_id IS NULL )))
*/
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End ASO_PRICE_ADJUSTMENTS_PKG;

/
