--------------------------------------------------------
--  DDL for Package PAY_MONETARY_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MONETARY_UNITS_PKG" AUTHID CURRENT_USER as
/* $Header: pymon01t.pkh 115.1 2003/07/16 22:21:10 scchakra ship $ */

procedure pop_flds(p_terr_code IN VARCHAR2,
		   p_country   IN OUT NOCOPY VARCHAR2);

procedure chk_unq_row(p_cur_code  IN VARCHAR2,
		      p_unit_name IN VARCHAR2,
                      p_bgroup_id IN NUMBER,
                      p_rowid     IN VARCHAR2,
		      p_leg_code  IN VARCHAR2 default null,
		      p_rel_value IN NUMBER   default null);

procedure get_id(p_munit_id IN OUT NOCOPY NUMBER);

procedure stb_del_valid(p_munit_id IN NUMBER);

procedure INSERT_ROW (
  X_ROWID              in out nocopy VARCHAR2,
  X_MONETARY_UNIT_ID   in out nocopy NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2,
  X_CREATION_DATE      in DATE,
  X_CREATED_BY         in NUMBER,
  X_LAST_UPDATE_DATE   in DATE,
  X_LAST_UPDATED_BY    in NUMBER,
  X_LAST_UPDATE_LOGIN  in NUMBER);
--
procedure LOCK_ROW (
  X_MONETARY_UNIT_ID   in NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2
);
--
procedure UPDATE_ROW (
  X_ROWID              in VARCHAR2,
  X_MONETARY_UNIT_ID   in NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE   in DATE,
  X_LAST_UPDATED_BY    in NUMBER,
  X_LAST_UPDATE_LOGIN  in NUMBER
);
--
procedure DELETE_ROW (
  X_MONETARY_UNIT_ID in NUMBER
);
--
procedure ADD_LANGUAGE;
--
procedure TRANSLATE_ROW
(X_RELATIVE_VALUE        in NUMBER,
 X_MONETARY_UNIT_NAME    in VARCHAR2,
 X_CURRENCY_CODE         in VARCHAR2,
 X_LEGISLATION_CODE      in VARCHAR2,
 X_BUSINESS_GROUP_NAME   in VARCHAR2,
 X_OWNER                 in VARCHAR2
);
--
procedure LOAD_ROW (
  X_CURRENCY_CODE        in VARCHAR2,
  X_BUSINESS_GROUP_NAME  in VARCHAR2,
  X_LEGISLATION_CODE     in VARCHAR2,
  X_RELATIVE_VALUE       in NUMBER,
  X_COMMENTS             in LONG,
  X_MONETARY_UNIT_NAME   in VARCHAR2,
  X_OWNER                in VARCHAR2
  );
--
procedure SET_TRANSLATION_GLOBALS
  (P_BUSINESS_GROUP_ID  in NUMBER
  ,P_LEGISLATION_CODE   in VARCHAR2
  ,P_CURRENCY_CODE      in VARCHAR2
  );
--
procedure VALIDATE_TRANSLATION
  (P_MONETARY_UNIT_ID   in NUMBER
  ,P_LANGUAGE           in VARCHAR2
  ,P_MONETARY_UNIT_NAME in VARCHAR2
  ,P_BUSINESS_GROUP_ID  in NUMBER   default null
  ,P_LEGISLATION_CODE   in VARCHAR2 default null
  );
--

end PAY_MONETARY_UNITS_PKG;

 

/
