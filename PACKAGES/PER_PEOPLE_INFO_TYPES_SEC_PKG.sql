--------------------------------------------------------
--  DDL for Package PER_PEOPLE_INFO_TYPES_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE_INFO_TYPES_SEC_PKG" AUTHID CURRENT_USER as
/* $Header: perpeits.pkh 115.2 2002/12/06 14:11:11 eumenyio noship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         25-Sep-00      VTreiger       Created.
==============================================================================
                                                                            */
------------------------------------------------------------------------------
PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME VARCHAR2,
                           P_RESPONSIBILITY_KEY     VARCHAR2,
                           P_INFO_TYPE_TABLE_NAME   VARCHAR2,
                           P_INFORMATION_TYPE       VARCHAR2,
                           P_ROWID                  VARCHAR2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_INFORMATION_TYPE_NEW in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2
);

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_INFORMATION_TYPE_NEW in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW
  (X_APPLICATION_SHORT_NAME in VARCHAR2
  ,X_RESPONSIBILITY_KEY in VARCHAR2
  ,X_INFO_TYPE_TABLE_NAME in VARCHAR2
  ,X_INFORMATION_TYPE in varchar2
  ,X_DESCRIPTION      in varchar2
  ,X_OWNER            in varchar2
  );

END PER_PEOPLE_INFO_TYPES_SEC_PKG;

 

/
