--------------------------------------------------------
--  DDL for Package FA_RX_ATTRSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_ATTRSETS_PKG" AUTHID CURRENT_USER as
/* $Header: faxrxats.pls 120.5.12010000.2 2009/07/19 13:11:29 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_PRINT_SOB_FLAG in VARCHAR2,
  X_PRINT_FUNC_CURR_FLAG in VARCHAR2,
  X_PRINT_TITLE in VARCHAR2,
  X_PRINT_SUBMISSION_DATE in VARCHAR2,
  X_PRINT_CURRENT_PAGE in VARCHAR2,
  X_PRINT_TOTAL_PAGES in VARCHAR2,
  X_PRINT_PARAMETERS in VARCHAR2,
  X_PRINT_PAGE_BREAK_COLS in VARCHAR2,
  X_GROUP_DISPLAY_TYPE in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DEFAULT_DATE_FORMAT in VARCHAR2,
  X_DEFAULT_DATE_TIME_FORMAT in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_PRINT_SOB_FLAG in VARCHAR2,
  X_PRINT_FUNC_CURR_FLAG in VARCHAR2,
  X_PRINT_TITLE in VARCHAR2,
  X_PRINT_SUBMISSION_DATE in VARCHAR2,
  X_PRINT_CURRENT_PAGE in VARCHAR2,
  X_PRINT_TOTAL_PAGES in VARCHAR2,
  X_PRINT_PARAMETERS in VARCHAR2,
  X_PRINT_PAGE_BREAK_COLS in VARCHAR2,
  X_GROUP_DISPLAY_TYPE in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DEFAULT_DATE_FORMAT in VARCHAR2,
  X_DEFAULT_DATE_TIME_FORMAT in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2
);
procedure UPDATE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_PRINT_SOB_FLAG in VARCHAR2,
  X_PRINT_FUNC_CURR_FLAG in VARCHAR2,
  X_PRINT_TITLE in VARCHAR2,
  X_PRINT_SUBMISSION_DATE in VARCHAR2,
  X_PRINT_CURRENT_PAGE in VARCHAR2,
  X_PRINT_TOTAL_PAGES in VARCHAR2,
  X_PRINT_PARAMETERS in VARCHAR2,
  X_PRINT_PAGE_BREAK_COLS in VARCHAR2,
  X_GROUP_DISPLAY_TYPE in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DEFAULT_DATE_FORMAT in VARCHAR2,
  X_DEFAULT_DATE_TIME_FORMAT in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2
);
procedure ADD_LANGUAGE;

--* overloaded procedure below
--*
procedure LOAD_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_PRINT_SOB_FLAG in VARCHAR2,
  X_PRINT_FUNC_CURR_FLAG in VARCHAR2,
  X_PRINT_TITLE in VARCHAR2,
  X_PRINT_SUBMISSION_DATE in VARCHAR2,
  X_PRINT_CURRENT_PAGE in VARCHAR2,
  X_PRINT_TOTAL_PAGES in VARCHAR2,
  X_PRINT_PARAMETERS in VARCHAR2,
  X_PRINT_PAGE_BREAK_COLS in VARCHAR2,
  X_GROUP_DISPLAY_TYPE in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DEFAULT_DATE_FORMAT in VARCHAR2,
  X_DEFAULT_DATE_TIME_FORMAT in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_OWNER in VARCHAR2);

procedure LOAD_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_PRINT_SOB_FLAG in VARCHAR2,
  X_PRINT_FUNC_CURR_FLAG in VARCHAR2,
  X_PRINT_TITLE in VARCHAR2,
  X_PRINT_SUBMISSION_DATE in VARCHAR2,
  X_PRINT_CURRENT_PAGE in VARCHAR2,
  X_PRINT_TOTAL_PAGES in VARCHAR2,
  X_PRINT_PARAMETERS in VARCHAR2,
  X_PRINT_PAGE_BREAK_COLS in VARCHAR2,
  X_GROUP_DISPLAY_TYPE in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DEFAULT_DATE_FORMAT in VARCHAR2,
  X_DEFAULT_DATE_TIME_FORMAT in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_Last_Update_Date VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
  );

procedure TRANSLATE_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_OWNER in VARCHAR2);

procedure TRANSLATE_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_REPORT_TITLE in VARCHAR2,
  X_USER_ATTRIBUTE_SET in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2);

end FA_RX_ATTRSETS_PKG;


/