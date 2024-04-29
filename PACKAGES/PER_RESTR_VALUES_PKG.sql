--------------------------------------------------------
--  DDL for Package PER_RESTR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RESTR_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: perpeprv.pkh 115.1 2002/12/06 14:46:14 eumenyio noship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         25-Sep-00      VTreiger       Created.
==============================================================================
                                                                            */
------------------------------------------------------------------------------
PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME VARCHAR2,
                           P_FORM_NAME              VARCHAR2,
                           P_NAME                   VARCHAR2,
                           P_BUSINESS_GROUP_NAME    VARCHAR2,
                           P_LEGISLATION_CODE       VARCHAR2,
                           P_RESTRICTION_CODE       VARCHAR2,
                           P_VALUE                  VARCHAR2,
                           P_ROWID                  VARCHAR2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
);

procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_RESTRICTION_CODE_NEW in VARCHAR2,
  X_VALUE_NEW in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
);

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_OWNER            in varchar2
  );

END PER_RESTR_VALUES_PKG;

 

/
