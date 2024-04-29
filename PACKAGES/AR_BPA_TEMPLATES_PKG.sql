--------------------------------------------------------
--  DDL for Package AR_BPA_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_TEMPLATES_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPTMPS.pls 120.4 2006/01/10 01:33:32 lishao noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_REF_TEMPLATE_ID in NUMBER,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_CONTRACT_LINE_TYPE in VARCHAR2,
  X_SHOW_LINE_DETAILS_FLAG in VARCHAR2,
  X_SHOW_LINE_GROUPING_FLAG in VARCHAR2,
  X_SHOW_SEQUENCE_FLAG in VARCHAR2,
  X_SHOW_ITEMIZED_TAX_FLAG in VARCHAR2,
  X_USE_AR_TAXOPTION_FLAG in VARCHAR2,
  X_TAX_SUMMARY_GRPBY in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_HEADER_HEIGHT in NUMBER,
  X_FOOTER_HEIGHT in NUMBER,
  X_HEADER_SHOW_TYPE in VARCHAR2,
  X_FOOTER_SHOW_TYPE in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_PAGE_SETUP_ID in NUMBER,
  X_SECONDARY_HEADER_HEIGHT in NUMBER,
  X_EXTERNAL_TEMPLATE_FLAG IN VARCHAR2,
  X_PRINT_LINES_FLAG IN VARCHAR2,
  X_TEMPLATE_TYPE  IN VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE  in VARCHAR2,
	X_TRX_CLASS  in VARCHAR2,
	X_TEMPLATE_FORMAT  in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_REF_TEMPLATE_ID in NUMBER,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_CONTRACT_LINE_TYPE in VARCHAR2,
  X_SHOW_LINE_DETAILS_FLAG in VARCHAR2,
  X_SHOW_LINE_GROUPING_FLAG in VARCHAR2,
  X_SHOW_SEQUENCE_FLAG in VARCHAR2,
  X_SHOW_ITEMIZED_TAX_FLAG in VARCHAR2,
  X_USE_AR_TAXOPTION_FLAG in VARCHAR2,
  X_TAX_SUMMARY_GRPBY in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_HEADER_HEIGHT in NUMBER,
  X_FOOTER_HEIGHT in NUMBER,
  X_HEADER_SHOW_TYPE in VARCHAR2,
  X_FOOTER_SHOW_TYPE in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_PAGE_SETUP_ID in NUMBER,
  X_SECONDARY_HEADER_HEIGHT in NUMBER,
  X_EXTERNAL_TEMPLATE_FLAG IN VARCHAR2,
  X_PRINT_LINES_FLAG IN VARCHAR2,
  X_TEMPLATE_TYPE  IN VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE  in VARCHAR2,
	X_TRX_CLASS  in VARCHAR2,
	X_TEMPLATE_FORMAT  in VARCHAR2
);

procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_REF_TEMPLATE_ID in NUMBER,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_CONTRACT_LINE_TYPE in VARCHAR2,
  X_SHOW_LINE_DETAILS_FLAG in VARCHAR2,
  X_SHOW_LINE_GROUPING_FLAG in VARCHAR2,
  X_SHOW_SEQUENCE_FLAG in VARCHAR2,
  X_SHOW_ITEMIZED_TAX_FLAG in VARCHAR2,
  X_USE_AR_TAXOPTION_FLAG in VARCHAR2,
  X_TAX_SUMMARY_GRPBY in VARCHAR2,
  X_COMPLETED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_HEADER_HEIGHT in NUMBER,
  X_FOOTER_HEIGHT in NUMBER,
  X_HEADER_SHOW_TYPE in VARCHAR2,
  X_FOOTER_SHOW_TYPE in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_PAGE_SETUP_ID in NUMBER,
  X_SECONDARY_HEADER_HEIGHT in NUMBER,
  X_EXTERNAL_TEMPLATE_FLAG IN VARCHAR2,
  X_PRINT_LINES_FLAG IN VARCHAR2,
  X_TEMPLATE_TYPE  IN VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE  in VARCHAR2,
	X_TRX_CLASS  in VARCHAR2,
	X_TEMPLATE_FORMAT  in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure LOAD_ROW (
        X_COMPLETED_FLAG                 IN VARCHAR2,
        X_CONTRACT_LINE_TYPE             IN VARCHAR2,
        X_PRIMARY_APP_ID                 IN NUMBER,
        X_REF_TEMPLATE_ID                IN NUMBER,
        X_SECONDARY_APP_ID               IN NUMBER,
        X_SEEDED_FLAG                    IN VARCHAR2,
        X_SHOW_ITEMIZED_TAX_FLAG         IN VARCHAR2,
        X_SHOW_LINE_DETAILS_FLAG         IN VARCHAR2,
        X_SHOW_LINE_GROUPING_FLAG        IN VARCHAR2,
        X_SHOW_SEQUENCE_FLAG             IN VARCHAR2,
        X_TAX_SUMMARY_GRPBY              IN VARCHAR2,
        X_TEMPLATE_DESCRIPTION           IN VARCHAR2,
        X_TEMPLATE_ID                    IN NUMBER,
        X_TEMPLATE_NAME                  IN VARCHAR2,
        X_USE_AR_TAXOPTION_FLAG          IN VARCHAR2,
	  X_HEADER_HEIGHT                  IN NUMBER,
	  X_FOOTER_HEIGHT                  IN NUMBER,
	  X_HEADER_SHOW_TYPE               IN VARCHAR2,
	  X_FOOTER_SHOW_TYPE               IN VARCHAR2,
	  X_PAGE_WIDTH                     IN NUMBER,
	  X_PAGE_HEIGHT                    IN NUMBER,
	  X_TOP_MARGIN                     IN NUMBER,
	  X_BOTTOM_MARGIN                  IN NUMBER,
	  X_LEFT_MARGIN                    IN NUMBER,
	  X_RIGHT_MARGIN                   IN NUMBER,
	  X_PAGE_NUMBER_LOC                IN VARCHAR2,
	  X_PAGE_SETUP_ID                  IN NUMBER,
        X_SECONDARY_HEADER_HEIGHT in NUMBER,
        X_EXTERNAL_TEMPLATE_FLAG IN VARCHAR2,
        X_PRINT_LINES_FLAG IN VARCHAR2,
        X_TEMPLATE_TYPE  IN VARCHAR2,
	  X_PRINT_FONT_FAMILY in VARCHAR2,
	  X_PRINT_FONT_SIZE  in VARCHAR2,
	X_TRX_CLASS  in VARCHAR2,
	X_TEMPLATE_FORMAT  in VARCHAR2,
        X_OWNER                          IN VARCHAR2
) ;

procedure TRANSLATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) ;

end AR_BPA_TEMPLATES_PKG;

 

/
