--------------------------------------------------------
--  DDL for Package PER_CUSTOMIZED_RESTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CUSTOMIZED_RESTR_PKG" AUTHID CURRENT_USER as
/* $Header: perpepcr.pkh 115.3 2003/07/03 13:21:50 tvankayl noship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         25-Sep-00      VTreiger       Created.
	 01-JUL-03      tvankayl       Modified table handles Insert_row,
				       Update_Row , Lock_ Row , Delete_row

				       1. prototypes were changed to follow
					  AOL standards.
				       2. DML operations were applied on
				          Translation table also.

					  Load_row and Translate_row were
				          modified to compensate for changes in
					  insert_row and update_row
115.3     03-JUL-03      tvankayl       removed the unnecessary comments.

==============================================================================
                                                                            */
------------------------------------------------------------------------------

PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME VARCHAR2,
                           P_FORM_NAME              VARCHAR2,
                           P_NAME                   VARCHAR2,
                           P_BUSINESS_GROUP_NAME    VARCHAR2,
                           P_LEGISLATION_CODE       VARCHAR2,
                           P_ROWID                  VARCHAR2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in out nocopy NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2
);


procedure UPDATE_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);


procedure DELETE_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
);


procedure LOAD_ROW
  (X_APPLICATION_SHORT_NAME   in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_OWNER in VARCHAR2
  );


procedure TRANSLATE_ROW
  (X_APPLICATION_SHORT_NAME in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_OWNER            in varchar2
  );


procedure ADD_LANGUAGE;

END PER_CUSTOMIZED_RESTR_PKG;

 

/
