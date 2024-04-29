--------------------------------------------------------
--  DDL for Package GMD_FORMULA_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_COMMON_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPFMCS.pls 120.2.12000000.2 2007/02/09 12:24:31 kmotupal ship $ */

/* Record type define the action to be taken */
/* by default Insert are 'I' and Updates are 'U' */
/* If the user wants to define a DELETE Pl/sql table */
/* the user must pass a 'D' for the record type */

TYPE formula_update_rec_type IS RECORD
(
   RECORD_TYPE                 VARCHAR2(1)     := 'U'
  ,FORMULA_NO                  VARCHAR2(32)
  ,FORMULA_VERS                NUMBER
  ,FORMULA_TYPE                NUMBER
  ,FORMULA_DESC1               VARCHAR2(70)
  ,FORMULA_DESC2               VARCHAR2(70)
  ,FORMULA_CLASS               VARCHAR2(32)
  ,FMCONTROL_CLASS             VARCHAR2(32)
  ,INACTIVE_IND                NUMBER
  ,OWNER_ORGANIZATION_ID       NUMBER
  ,TOTAL_INPUT_QTY             NUMBER
  ,TOTAL_OUTPUT_QTY            NUMBER
  ,YIELD_UOM                   VARCHAR2(3)
  ,FORMULA_STATUS              VARCHAR2(30)
  ,OWNER_ID                    NUMBER(15)
  ,FORMULA_ID                  NUMBER
  ,FORMULALINE_ID              NUMBER
  ,LINE_TYPE                   NUMBER
  ,LINE_NO                     NUMBER
  ,ITEM_NO                     VARCHAR2(2000)
  ,INVENTORY_ITEM_ID           NUMBER
  ,REVISION	 	       VARCHAR2(3)
  ,QTY                         NUMBER
  ,DETAIL_UOM	               VARCHAR2(3)
  ,RELEASE_TYPE                NUMBER
  ,SCRAP_FACTOR                NUMBER
  ,SCALE_TYPE_HDR              NUMBER
  ,SCALE_TYPE_DTL              NUMBER
  ,COST_ALLOC                  NUMBER
  ,PHANTOM_TYPE                NUMBER
  ,REWORK_TYPE                 NUMBER
  ,BUFFER_IND                  NUMBER
  /*Bug 2509076 - Thomas Daniel  New field for Quality integration */
  ,BY_PRODUCT_TYPE             VARCHAR2(1)
  ,INGREDIENT_END_DATE         DATE          --Bug 4479101
  ,ATTRIBUTE1                  VARCHAR2(240)
  ,ATTRIBUTE2                  VARCHAR2(240)
  ,ATTRIBUTE3                  VARCHAR2(240)
  ,ATTRIBUTE4                  VARCHAR2(240)
  ,ATTRIBUTE5                  VARCHAR2(240)
  ,ATTRIBUTE6                  VARCHAR2(240)
  ,ATTRIBUTE7                  VARCHAR2(240)
  ,ATTRIBUTE8                  VARCHAR2(240)
  ,ATTRIBUTE9                  VARCHAR2(240)
  ,ATTRIBUTE10                 VARCHAR2(240)
  ,ATTRIBUTE11                 VARCHAR2(240)
  ,ATTRIBUTE12                 VARCHAR2(240)
  ,ATTRIBUTE13                 VARCHAR2(240)
  ,ATTRIBUTE14                 VARCHAR2(240)
  ,ATTRIBUTE15                 VARCHAR2(240)
  ,ATTRIBUTE16                 VARCHAR2(240)
  ,ATTRIBUTE17                 VARCHAR2(240)
  ,ATTRIBUTE18                 VARCHAR2(240)
  ,ATTRIBUTE19                 VARCHAR2(240)
  ,ATTRIBUTE20                 VARCHAR2(240)
  ,ATTRIBUTE21                 VARCHAR2(240)
  ,ATTRIBUTE22                 VARCHAR2(240)
  ,ATTRIBUTE23                 VARCHAR2(240)
  ,ATTRIBUTE24                 VARCHAR2(240)
  ,ATTRIBUTE25                 VARCHAR2(240)
  ,ATTRIBUTE26                 VARCHAR2(240)
  ,ATTRIBUTE27                 VARCHAR2(240)
  ,ATTRIBUTE28                 VARCHAR2(240)
  ,ATTRIBUTE29                 VARCHAR2(240)
  ,ATTRIBUTE30                 VARCHAR2(240)
  ,DTL_ATTRIBUTE1              VARCHAR2(240)
  ,DTL_ATTRIBUTE2              VARCHAR2(240)
  ,DTL_ATTRIBUTE3              VARCHAR2(240)
  ,DTL_ATTRIBUTE4              VARCHAR2(240)
  ,DTL_ATTRIBUTE5              VARCHAR2(240)
  ,DTL_ATTRIBUTE6              VARCHAR2(240)
  ,DTL_ATTRIBUTE7              VARCHAR2(240)
  ,DTL_ATTRIBUTE8              VARCHAR2(240)
  ,DTL_ATTRIBUTE9              VARCHAR2(240)
  ,DTL_ATTRIBUTE10             VARCHAR2(240)
  ,DTL_ATTRIBUTE11             VARCHAR2(240)
  ,DTL_ATTRIBUTE12             VARCHAR2(240)
  ,DTL_ATTRIBUTE13             VARCHAR2(240)
  ,DTL_ATTRIBUTE14             VARCHAR2(240)
  ,DTL_ATTRIBUTE15             VARCHAR2(240)
  ,DTL_ATTRIBUTE16             VARCHAR2(240)
  ,DTL_ATTRIBUTE17             VARCHAR2(240)
  ,DTL_ATTRIBUTE18             VARCHAR2(240)
  ,DTL_ATTRIBUTE19             VARCHAR2(240)
  ,DTL_ATTRIBUTE20             VARCHAR2(240)
  ,DTL_ATTRIBUTE21             VARCHAR2(240)
  ,DTL_ATTRIBUTE22             VARCHAR2(240)
  ,DTL_ATTRIBUTE23             VARCHAR2(240)
  ,DTL_ATTRIBUTE24             VARCHAR2(240)
  ,DTL_ATTRIBUTE25             VARCHAR2(240)
  ,DTL_ATTRIBUTE26             VARCHAR2(240)
  ,DTL_ATTRIBUTE27             VARCHAR2(240)
  ,DTL_ATTRIBUTE28             VARCHAR2(240)
  ,DTL_ATTRIBUTE29             VARCHAR2(240)
  ,DTL_ATTRIBUTE30             VARCHAR2(240)
  ,DTL_ATTRIBUTE_CATEGORY      VARCHAR2(30)
  ,ATTRIBUTE_CATEGORY          VARCHAR2(30)
  ,TPFORMULA_ID                NUMBER
  ,IAFORMULA_ID                NUMBER
  ,SCALE_MULTIPLE              NUMBER
  ,CONTRIBUTE_YIELD_IND        VARCHAR2(1)
  ,SCALE_UOM                   VARCHAR2(4)
  ,CONTRIBUTE_STEP_QTY_IND     VARCHAR2(1)
  ,SCALE_ROUNDING_VARIANCE     NUMBER
  ,ROUNDING_DIRECTION          NUMBER
  ,TEXT_CODE_HDR               NUMBER
  ,TEXT_CODE_DTL               NUMBER
  ,CREATION_DATE               DATE
  ,CREATED_BY                  NUMBER(15)
  ,LAST_UPDATED_BY             NUMBER(15)
  ,LAST_UPDATE_DATE            DATE
  ,LAST_UPDATE_LOGIN           NUMBER(15)
  ,DELETE_MARK                 NUMBER
  ,USER_ID                     NUMBER
  ,USER_NAME                   VARCHAR2(100)
  ,AUTO_PRODUCT_CALC           VARCHAR2(1)    -- Bug# 5716318
  ,PROD_PERCENT                NUMBER
);

TYPE formula_insert_rec_type IS RECORD
(
   RECORD_TYPE                 VARCHAR2(1)     := 'I'
  ,FORMULA_NO                  VARCHAR2(32)
  ,FORMULA_VERS                NUMBER
  ,FORMULA_TYPE                NUMBER          := 0
  ,FORMULA_DESC1               VARCHAR2(70)
  ,FORMULA_DESC2               VARCHAR2(70)
  ,FORMULA_CLASS               VARCHAR2(32)
  ,FMCONTROL_CLASS             VARCHAR2(32)
  ,INACTIVE_IND                NUMBER          := 0
  ,OWNER_ORGANIZATION_ID       NUMBER
  ,TOTAL_INPUT_QTY             NUMBER          := 0
  ,TOTAL_OUTPUT_QTY            NUMBER          := 0
  ,YIELD_UOM                   VARCHAR2(3)
  ,FORMULA_STATUS              VARCHAR2(30)    := '100'
  ,OWNER_ID                    NUMBER(15)
  ,FORMULA_ID                  NUMBER
  ,FORMULALINE_ID              NUMBER
  ,LINE_TYPE                   NUMBER          := 1
  ,LINE_NO                     NUMBER
  ,ITEM_NO                     VARCHAR2(2000)
  ,INVENTORY_ITEM_ID           NUMBER
  ,REVISION		       VARCHAR2(3)
  ,QTY                         NUMBER
  ,DETAIL_UOM	               VARCHAR2(3)
  ,MASTER_FORMULA_ID           NUMBER
  ,RELEASE_TYPE                NUMBER          := 0
  ,SCRAP_FACTOR                NUMBER          := 0
  ,SCALE_TYPE_HDR              NUMBER          := 1
  ,SCALE_TYPE_DTL              NUMBER          := 1
  ,COST_ALLOC                  NUMBER          := 0
  ,PHANTOM_TYPE                NUMBER          := 0
  ,REWORK_TYPE                 NUMBER          := 0
  ,BUFFER_IND                  NUMBER          := 0
  /*Bug 2509076 - Thomas Daniel New field for Quality integration */
  ,BY_PRODUCT_TYPE             VARCHAR2(1)
  ,INGREDIENT_END_DATE         DATE          --Bug 4479101
  ,ATTRIBUTE1                  VARCHAR2(240)
  ,ATTRIBUTE2                  VARCHAR2(240)
  ,ATTRIBUTE3                  VARCHAR2(240)
  ,ATTRIBUTE4                  VARCHAR2(240)
  ,ATTRIBUTE5                  VARCHAR2(240)
  ,ATTRIBUTE6                  VARCHAR2(240)
  ,ATTRIBUTE7                  VARCHAR2(240)
  ,ATTRIBUTE8                  VARCHAR2(240)
  ,ATTRIBUTE9                  VARCHAR2(240)
  ,ATTRIBUTE10                 VARCHAR2(240)
  ,ATTRIBUTE11                 VARCHAR2(240)
  ,ATTRIBUTE12                 VARCHAR2(240)
  ,ATTRIBUTE13                 VARCHAR2(240)
  ,ATTRIBUTE14                 VARCHAR2(240)
  ,ATTRIBUTE15                 VARCHAR2(240)
  ,ATTRIBUTE16                 VARCHAR2(240)
  ,ATTRIBUTE17                 VARCHAR2(240)
  ,ATTRIBUTE18                 VARCHAR2(240)
  ,ATTRIBUTE19                 VARCHAR2(240)
  ,ATTRIBUTE20                 VARCHAR2(240)
  ,ATTRIBUTE21                 VARCHAR2(240)
  ,ATTRIBUTE22                 VARCHAR2(240)
  ,ATTRIBUTE23                 VARCHAR2(240)
  ,ATTRIBUTE24                 VARCHAR2(240)
  ,ATTRIBUTE25                 VARCHAR2(240)
  ,ATTRIBUTE26                 VARCHAR2(240)
  ,ATTRIBUTE27                 VARCHAR2(240)
  ,ATTRIBUTE28                 VARCHAR2(240)
  ,ATTRIBUTE29                 VARCHAR2(240)
  ,ATTRIBUTE30                 VARCHAR2(240)
  ,DTL_ATTRIBUTE1              VARCHAR2(240)
  ,DTL_ATTRIBUTE2              VARCHAR2(240)
  ,DTL_ATTRIBUTE3              VARCHAR2(240)
  ,DTL_ATTRIBUTE4              VARCHAR2(240)
  ,DTL_ATTRIBUTE5              VARCHAR2(240)
  ,DTL_ATTRIBUTE6              VARCHAR2(240)
  ,DTL_ATTRIBUTE7              VARCHAR2(240)
  ,DTL_ATTRIBUTE8              VARCHAR2(240)
  ,DTL_ATTRIBUTE9              VARCHAR2(240)
  ,DTL_ATTRIBUTE10             VARCHAR2(240)
  ,DTL_ATTRIBUTE11             VARCHAR2(240)
  ,DTL_ATTRIBUTE12             VARCHAR2(240)
  ,DTL_ATTRIBUTE13             VARCHAR2(240)
  ,DTL_ATTRIBUTE14             VARCHAR2(240)
  ,DTL_ATTRIBUTE15             VARCHAR2(240)
  ,DTL_ATTRIBUTE16             VARCHAR2(240)
  ,DTL_ATTRIBUTE17             VARCHAR2(240)
  ,DTL_ATTRIBUTE18             VARCHAR2(240)
  ,DTL_ATTRIBUTE19             VARCHAR2(240)
  ,DTL_ATTRIBUTE20             VARCHAR2(240)
  ,DTL_ATTRIBUTE21             VARCHAR2(240)
  ,DTL_ATTRIBUTE22             VARCHAR2(240)
  ,DTL_ATTRIBUTE23             VARCHAR2(240)
  ,DTL_ATTRIBUTE24             VARCHAR2(240)
  ,DTL_ATTRIBUTE25             VARCHAR2(240)
  ,DTL_ATTRIBUTE26             VARCHAR2(240)
  ,DTL_ATTRIBUTE27             VARCHAR2(240)
  ,DTL_ATTRIBUTE28             VARCHAR2(240)
  ,DTL_ATTRIBUTE29             VARCHAR2(240)
  ,DTL_ATTRIBUTE30             VARCHAR2(240)
  ,ATTRIBUTE_CATEGORY          VARCHAR2(30)
  ,DTL_ATTRIBUTE_CATEGORY      VARCHAR2(30)
  ,TPFORMULA_ID                NUMBER
  ,IAFORMULA_ID                NUMBER
  ,SCALE_MULTIPLE              NUMBER
  ,CONTRIBUTE_YIELD_IND        VARCHAR2(1)    := 'Y'
  ,SCALE_UOM                   VARCHAR2(4)
  ,CONTRIBUTE_STEP_QTY_IND     VARCHAR2(1)    := 'Y'
  ,SCALE_ROUNDING_VARIANCE     NUMBER
  ,ROUNDING_DIRECTION          NUMBER
  ,TEXT_CODE_HDR               NUMBER
  ,TEXT_CODE_DTL               NUMBER
  ,USER_ID                     NUMBER
  ,CREATION_DATE               DATE
  ,CREATED_BY                  NUMBER(15)
  ,LAST_UPDATED_BY             NUMBER(15)
  ,LAST_UPDATE_DATE            DATE
  ,LAST_UPDATE_LOGIN           NUMBER(15)
  ,USER_NAME                   VARCHAR2(100)
  ,DELETE_MARK                 NUMBER         := 0
  ,AUTO_PRODUCT_CALC           VARCHAR2(1)  -- Bug# 5716318
  ,PROD_PERCENT                NUMBER
);

END GMD_FORMULA_COMMON_PUB;

 

/
