--------------------------------------------------------
--  DDL for Package AR_BPA_CONTENT_AREAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_CONTENT_AREAS_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPCNTS.pls 120.2 2005/10/30 04:13:15 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CONTENT_AREA_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_CONTENT_TYPE in NUMBER,
  X_CONTENT_ORIENTATION in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_CONTENT_STYLE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_CONTENT_AREA_WIDTH in VARCHAR2,
  X_CONTENT_AREA_LEFT_SPACE in NUMBER,
  X_CONTENT_AREA_RIGHT_SPACE in NUMBER,
  X_CONTENT_AREA_TOP_SPACE in NUMBER,
  X_CONTENT_AREA_BOTTOM_SPACE in NUMBER,
  X_CONTENT_COUNT in NUMBER,
  X_LINE_REGION_FLAG in VARCHAR2,
  X_ITEM_LABEL_STYLE in VARCHAR2,
  X_CONTENT_DISP_PROMPT_STYLE in VARCHAR2,
  X_ITEM_VALUE_STYLE in VARCHAR2,
  X_INVOICE_LINE_TYPE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_ITEM_COLUMN_WIDTH in NUMBER,
  X_CONTENT_AREA_NAME in VARCHAR2,
  X_CONTENT_DISPLAY_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_CONTENT_AREA_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_CONTENT_TYPE in NUMBER,
  X_CONTENT_ORIENTATION in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_CONTENT_STYLE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_CONTENT_AREA_WIDTH in VARCHAR2,
  X_CONTENT_AREA_LEFT_SPACE in NUMBER,
  X_CONTENT_AREA_RIGHT_SPACE in NUMBER,
  X_CONTENT_AREA_TOP_SPACE in NUMBER,
  X_CONTENT_AREA_BOTTOM_SPACE in NUMBER,
  X_CONTENT_COUNT in NUMBER,
  X_LINE_REGION_FLAG in VARCHAR2,
  X_ITEM_LABEL_STYLE in VARCHAR2,
  X_CONTENT_DISP_PROMPT_STYLE in VARCHAR2,
  X_ITEM_VALUE_STYLE in VARCHAR2,
  X_INVOICE_LINE_TYPE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_ITEM_COLUMN_WIDTH in NUMBER,
  X_CONTENT_AREA_NAME in VARCHAR2,
  X_CONTENT_DISPLAY_PROMPT in VARCHAR2
);
procedure UPDATE_ROW (
  X_CONTENT_AREA_ID in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_CONTENT_TYPE in NUMBER,
  X_CONTENT_ORIENTATION in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_CONTENT_STYLE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_URL_ID in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_CONTENT_AREA_WIDTH in VARCHAR2,
  X_CONTENT_AREA_LEFT_SPACE in NUMBER,
  X_CONTENT_AREA_RIGHT_SPACE in NUMBER,
  X_CONTENT_AREA_TOP_SPACE in NUMBER,
  X_CONTENT_AREA_BOTTOM_SPACE in NUMBER,
  X_CONTENT_COUNT in NUMBER,
  X_LINE_REGION_FLAG in VARCHAR2,
  X_ITEM_LABEL_STYLE in VARCHAR2,
  X_CONTENT_DISP_PROMPT_STYLE in VARCHAR2,
  X_ITEM_VALUE_STYLE in VARCHAR2,
  X_INVOICE_LINE_TYPE in VARCHAR2,
  X_AREA_CODE in VARCHAR2,
  X_PARENT_AREA_CODE in VARCHAR2,
  X_ITEM_COLUMN_WIDTH in NUMBER,
  X_CONTENT_AREA_NAME in VARCHAR2,
  X_CONTENT_DISPLAY_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CONTENT_AREA_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_CONTENT_AREA_ID in NUMBER,
  X_CONTENT_AREA_NAME in VARCHAR2,
  X_CONTENT_DISPLAY_PROMPT in VARCHAR2,
  X_OWNER in VARCHAR2) ;


procedure LOAD_ROW (
        X_AREA_CODE                      IN VARCHAR2,
        X_CONTENT_AREA_BOTTOM_SPACE      IN NUMBER,
        X_CONTENT_AREA_ID                IN NUMBER,
        X_CONTENT_AREA_LEFT_SPACE        IN NUMBER,
        X_CONTENT_AREA_NAME              IN VARCHAR2,
        X_CONTENT_AREA_RIGHT_SPACE       IN NUMBER,
        X_CONTENT_AREA_TOP_SPACE         IN NUMBER,
        X_CONTENT_AREA_WIDTH             IN VARCHAR2,
        X_CONTENT_COUNT                  IN NUMBER,
        X_CONTENT_DISPLAY_PROMPT         IN VARCHAR2,
        X_CONTENT_DISP_PROMPT_STYLE      IN VARCHAR2,
        X_CONTENT_ORIENTATION            IN NUMBER,
        X_CONTENT_STYLE_ID               IN NUMBER,
        X_CONTENT_TYPE                   IN NUMBER,
        X_DISPLAY_LEVEL                  IN VARCHAR2,
        X_DISPLAY_SEQUENCE               IN NUMBER,
        X_INVOICE_LINE_TYPE              IN VARCHAR2,
        X_ITEM_ID                        IN NUMBER,
        X_ITEM_LABEL_STYLE               IN VARCHAR2,
        X_ITEM_VALUE_STYLE               IN VARCHAR2,
        X_LINE_REGION_FLAG               IN VARCHAR2,
        X_PARENT_AREA_CODE               IN VARCHAR2,
        X_TEMPLATE_ID                    IN NUMBER,
        X_URL_ID                         IN NUMBER,
        X_ITEM_COLUMN_WIDTH              IN NUMBER,
        X_OWNER                 IN VARCHAR2
) ;



end AR_BPA_CONTENT_AREAS_PKG;

 

/
