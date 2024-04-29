--------------------------------------------------------
--  DDL for Package PSP_ENC_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PSPENELS.pls 120.2 2006/02/20 05:05:34 spchakra noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_ELEMENT_ID in NUMBER,
  X_INPUT_VALUE_ID in NUMBER,  -- Added for Additional Earnings Element Enh
  X_FORMULA_ID in NUMBER,  -- Added for Encumbrance Rearchitecture
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ELEMENT_TYPE_CATEGORY in VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ENC_ELEMENT_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ELEMENT_TYPE_CATEGORY in VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_INPUT_VALUE_ID in NUMBER,	-- Added for Additional Earnings Element Enh
  X_FORMULA_ID in NUMBER  -- Added for Encumbrance Rearchitecture
);
procedure UPDATE_ROW (
  X_ENC_ELEMENT_ID in NUMBER,
  X_INPUT_VALUE_ID in NUMBER,  -- Added for Additional Earnings Element Enh
  X_FORMULA_ID in NUMBER,  -- Added for Encumbrance Rearchitecture
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ELEMENT_TYPE_CATEGORY in VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_ELEMENT_ID in NUMBER,
  X_INPUT_VALUE_ID in NUMBER, -- Added for Additional Earnings Element Enh
  X_FORMULA_ID in NUMBER,  -- Added for Encumbrance Rearchitecture
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ELEMENT_TYPE_CATEGORY in VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ENC_ELEMENT_ID in NUMBER
);
end PSP_ENC_ELEMENTS_PKG;

 

/
