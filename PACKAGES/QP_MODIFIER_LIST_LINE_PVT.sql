--------------------------------------------------------
--  DDL for Package QP_MODIFIER_LIST_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIER_LIST_LINE_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVMLLS.pls 115.0 99/10/14 18:54:21 porting ship   $ */

PROCEDURE Insert_Row(
  X_LIST_LINE_ID         IN OUT     NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_HEADER_ID                  NUMBER
, X_LIST_LINE_TYPE_CODE             VARCHAR2
, X_START_DATE_ACTIVE            DATE
, X_END_DATE_ACTIVE              DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_MODIFIER_LEVEL_CODE             VARCHAR2
, X_LIST_PRICE                      NUMBER
, X_LIST_PRICE_UOM_CODE             VARCHAR2
, X_PRIMARY_UOM_FLAG                VARCHAR2
, X_INVENTORY_ITEM_ID               NUMBER
, X_ORGANIZATION_ID                 NUMBER
, X_RELATED_ITEM_ID                 NUMBER
, X_RELATIONSHIP_TYPE_ID            NUMBER
, X_SUBSTITUTION_CONTEXT            VARCHAR2
, X_SUBSTITUTION_ATTRIBUTE          VARCHAR2
, X_SUBSTITUTION_VALUE              VARCHAR2
, X_REVISION                        VARCHAR2
, X_REVISION_DATE                   DATE
, X_REVISION_REASON_CODE            VARCHAR2
, X_COMMENTS                        VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
,X_PRICE_BREAK_TYPE_CODE                    VARCHAR2
, X_PERCENT_PRICE                            NUMBER
, X_PRICE_BY_FORMULA_ID                      NUMBER
, X_NUMBER_EFFECTIVE_PERIODS                 NUMBER
, X_EFFECTIVE_PERIOD_UOM                     VARCHAR2
, X_ARITHMETIC_OPERATOR                      VARCHAR2
, X_OPERAND                                  NUMBER
, X_NEW_PRICE                                NUMBER
, X_OVERRIDE_FLAG                            VARCHAR2
, X_PRINT_ON_INVOICE_FLAG                    VARCHAR2
, X_GL_CLASS_ID                              NUMBER
, X_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2
, X_REBATE_SUBTYPE_CODE                      VARCHAR2
, X_BASE_QTY                                 NUMBER
, X_BASE_UOM_CODE                            VARCHAR2
, X_ACCRUAL_TYPE_CODE                        VARCHAR2
, X_ACCRUAL_QTY                              NUMBER
, X_ACCRUAL_UOM_CODE                         VARCHAR2
, X_ESTIM_ACCRUAL_RATE                       NUMBER
, X_ACCUM_TO_ACCR_CONV_RATE                  NUMBER
, X_GENERATE_USING_FORMULA_ID                NUMBER
);


PROCEDURE Lock_Row(
  X_LIST_LINE_ID          IN OUT    NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_HEADER_ID                  NUMBER
, X_LIST_LINE_TYPE_CODE             VARCHAR2
, X_START_DATE_ACTIVE            DATE
, X_END_DATE_ACTIVE              DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_MODIFIER_LEVEL_CODE             VARCHAR2
, X_LIST_PRICE                      NUMBER
, X_LIST_PRICE_UOM_CODE             VARCHAR2
, X_PRIMARY_UOM_FLAG                VARCHAR2
, X_INVENTORY_ITEM_ID               NUMBER
, X_ORGANIZATION_ID                 NUMBER
, X_RELATED_ITEM_ID                 NUMBER
, X_RELATIONSHIP_TYPE_ID            NUMBER
, X_SUBSTITUTION_CONTEXT            VARCHAR2
, X_SUBSTITUTION_ATTRIBUTE          VARCHAR2
, X_SUBSTITUTION_VALUE              VARCHAR2
, X_REVISION                        VARCHAR2
, X_REVISION_DATE                   DATE
, X_REVISION_REASON_CODE            VARCHAR2
, X_COMMENTS                        VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
,X_PRICE_BREAK_TYPE_CODE                    VARCHAR2
, X_PERCENT_PRICE                            NUMBER
, X_PRICE_BY_FORMULA_ID                      NUMBER
, X_NUMBER_EFFECTIVE_PERIODS                 NUMBER
, X_EFFECTIVE_PERIOD_UOM                     VARCHAR2
, X_ARITHMETIC_OPERATOR                      VARCHAR2
, X_OPERAND                                  NUMBER
, X_NEW_PRICE                                NUMBER
, X_OVERRIDE_FLAG                            VARCHAR2
, X_PRINT_ON_INVOICE_FLAG                    VARCHAR2
, X_GL_CLASS_ID                              NUMBER
, X_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2
, X_REBATE_SUBTYPE_CODE                      VARCHAR2
, X_BASE_QTY                                 NUMBER
, X_BASE_UOM_CODE                            VARCHAR2
, X_ACCRUAL_TYPE_CODE                        VARCHAR2
, X_ACCRUAL_QTY                              NUMBER
, X_ACCRUAL_UOM_CODE                         VARCHAR2
, X_ESTIM_ACCRUAL_RATE                       NUMBER
, X_ACCUM_TO_ACCR_CONV_RATE                  NUMBER
, X_GENERATE_USING_FORMULA_ID                NUMBER


);


PROCEDURE Update_Row(
  X_LIST_LINE_ID          IN OUT    NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_HEADER_ID                  NUMBER
, X_LIST_LINE_TYPE_CODE             VARCHAR2
, X_START_DATE_ACTIVE            DATE
, X_END_DATE_ACTIVE              DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_MODIFIER_LEVEL_CODE             VARCHAR2
, X_LIST_PRICE                      NUMBER
, X_LIST_PRICE_UOM_CODE             VARCHAR2
, X_PRIMARY_UOM_FLAG                VARCHAR2
, X_INVENTORY_ITEM_ID               NUMBER
, X_ORGANIZATION_ID                 NUMBER
, X_RELATED_ITEM_ID                 NUMBER
, X_RELATIONSHIP_TYPE_ID            NUMBER
, X_SUBSTITUTION_CONTEXT            VARCHAR2
, X_SUBSTITUTION_ATTRIBUTE          VARCHAR2
, X_SUBSTITUTION_VALUE              VARCHAR2
, X_REVISION                        VARCHAR2
, X_REVISION_DATE                   DATE
, X_REVISION_REASON_CODE            VARCHAR2
, X_COMMENTS                        VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
,X_PRICE_BREAK_TYPE_CODE                    VARCHAR2
, X_PERCENT_PRICE                            NUMBER
, X_PRICE_BY_FORMULA_ID                      NUMBER
, X_NUMBER_EFFECTIVE_PERIODS                 NUMBER
, X_EFFECTIVE_PERIOD_UOM                     VARCHAR2
, X_ARITHMETIC_OPERATOR                      VARCHAR2
, X_OPERAND                                  NUMBER
, X_NEW_PRICE                                NUMBER
, X_OVERRIDE_FLAG                            VARCHAR2
, X_PRINT_ON_INVOICE_FLAG                    VARCHAR2
, X_GL_CLASS_ID                              NUMBER
, X_REBATE_TRANSACTION_TYPE_CODE             VARCHAR2
, X_REBATE_SUBTYPE_CODE                      VARCHAR2
, X_BASE_QTY                                 NUMBER
, X_BASE_UOM_CODE                            VARCHAR2
, X_ACCRUAL_TYPE_CODE                        VARCHAR2
, X_ACCRUAL_QTY                              NUMBER
, X_ACCRUAL_UOM_CODE                         VARCHAR2
, X_ESTIM_ACCRUAL_RATE                       NUMBER
, X_ACCUM_TO_ACCR_CONV_RATE                  NUMBER
, X_GENERATE_USING_FORMULA_ID                NUMBER

);

PROCEDURE Delete_Row(
X_LIST_LINE_ID		NUMBER
);


END QP_MODIFIER_LIST_LINE_PVT;

 

/
