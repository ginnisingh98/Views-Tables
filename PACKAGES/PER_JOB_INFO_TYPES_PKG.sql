--------------------------------------------------------
--  DDL for Package PER_JOB_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_INFO_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: perjobit.pkh 115.2 2002/12/06 13:42:56 eumenyio ship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         21-Sep-99      IHarding       Created.
==============================================================================
                                                                            */
------------------------------------------------------------------------------
PROCEDURE UNIQUENESS_CHECK(P_INFORMATION_TYPE           VARCHAR2,
                           P_ACTIVE_INACTIVE_FLAG       VARCHAR2,
                           P_LEGISLATION_CODE           VARCHAR2,
                           P_ROWID                      VARCHAR2,
                           P_DESCRIPTION                VARCHAR2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW (
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_INFORMATION_TYPE in VARCHAR2
);

procedure LOAD_ROW (
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW
  (X_INFORMATION_TYPE in varchar2
  ,X_DESCRIPTION      in varchar2
  ,X_OWNER            in varchar2
  );

END PER_JOB_INFO_TYPES_PKG;

 

/
