--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_INFO_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: payetpit.pkh 115.0 2002/12/16 06:23:47 scchakra noship $ */
------------------------------------------------------------------------------
--
procedure INSERT_ROW (
  P_ROWID                    in out nocopy VARCHAR2,
  P_INFORMATION_TYPE         in VARCHAR2,
  P_ACTIVE_INACTIVE_FLAG     in VARCHAR2,
  P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  P_LEGISLATION_CODE         in VARCHAR2,
  P_OBJECT_VERSION_NUMBER    in NUMBER,
  P_DESCRIPTION              in VARCHAR2
);
--
procedure UPDATE_ROW (
  P_INFORMATION_TYPE         in VARCHAR2,
  P_ACTIVE_INACTIVE_FLAG     in VARCHAR2,
  P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  P_LEGISLATION_CODE         in VARCHAR2,
  P_OBJECT_VERSION_NUMBER    in NUMBER,
  P_DESCRIPTION              in VARCHAR2
);
--
procedure LOAD_ROW
  (P_INFORMATION_TYPE         in varchar2
  ,P_ACTIVE_INACTIVE_FLAG     in varchar2
  ,P_MULTIPLE_OCCURENCES_FLAG in varchar2
  ,P_DESCRIPTION              in varchar2
  ,P_LEGISLATION_CODE         in varchar2
  ,P_OBJECT_VERSION_NUMBER    in number
  ,P_OWNER                    in varchar2
  );

procedure TRANSLATE_ROW
  (P_INFORMATION_TYPE in varchar2
  ,P_DESCRIPTION      in varchar2
  ,P_OWNER            in varchar2
  );

END PAY_ELEMENT_INFO_TYPES_PKG;

 

/
