--------------------------------------------------------
--  DDL for Package HZ_STYLE_FMT_VARIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STYLE_FMT_VARIATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPSFVS.pls 120.5 2005/06/16 21:14:50 jhuang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in out NOCOPY NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER  in NUMBER
);

procedure LOCK_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2
);

procedure UPDATE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER  in NUMBER
);

PROCEDURE SELECT_ROW (
  X_STYLE_FORMAT_CODE		IN OUT NOCOPY VARCHAR2,
  X_VARIATION_NUMBER    	IN OUT NOCOPY NUMBER,
  X_VARIATION_RANK 		OUT    NOCOPY NUMBER,
  X_SELECTION_CONDITION		OUT    NOCOPY VARCHAR2,
  X_START_DATE_ACTIVE		OUT    NOCOPY DATE,
  X_END_DATE_ACTIVE		OUT    NOCOPY DATE
);

procedure DELETE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
);


end HZ_STYLE_FMT_VARIATIONS_PKG;

 

/