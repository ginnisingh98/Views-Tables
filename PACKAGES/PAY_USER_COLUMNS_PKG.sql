--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMNS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusc01t.pkh 120.1 2005/07/29 05:07:48 shisriva noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Package Header Variable                              |
-- ----------------------------------------------------------------------------
--
g_dml_status boolean := FALSE;  -- Global package variable
--
  procedure insert_row(p_rowid                in out nocopy varchar2,
		       p_user_column_id	      in out nocopy number,
		       p_user_table_id	      in number,
		       p_business_group_id    in number,
		       p_legislation_code     in varchar2,
		       p_legislation_subgroup in varchar2,
		       p_user_column_name     in varchar2,
		       p_formula_id	      in number )  ;
--
 procedure update_row(p_rowid                in varchar2,
		      p_user_column_id	     in number,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_user_column_name     in varchar2,
		      p_formula_id	     in number,
		      p_base_user_column_name in varchar2 default hr_api.g_varchar2)  ;
--
  procedure delete_row(p_rowid   in varchar2) ;
--
  procedure lock_row (p_rowid                in varchar2,
		      p_user_column_id	     in number,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_user_column_name     in varchar2,
		      p_formula_id	     in number,
		      p_base_user_column_name in varchar2 default hr_api.g_varchar2)  ;
--
  procedure check_unique ( p_rowid             in varchar2,
			   p_user_column_name  in varchar2,
			   p_user_table_id     in number,
                           p_business_group_id in number,
			   p_base_user_column_name in varchar2 default hr_api.g_varchar2) ;
--
  procedure check_unique_f ( p_rowid             in varchar2,
			   p_user_column_name  in varchar2,
                           p_user_table_id     in number,
                           p_business_group_id in number,
                           p_legislation_code  in varchar2,
			   p_base_user_column_name   in varchar2 default hr_api.g_varchar2) ;
--
  procedure check_delete ( p_user_column_id    in number ) ;
--
----For MLS---------------------------------------------------------------------
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (X_B_USER_COLUMN_NAME in VARCHAR2,
                         X_B_LEGISLATION_CODE in VARCHAR2,
                         X_USER_COLUMN_NAME in VARCHAR2,
                         X_OWNER in VARCHAR2);
procedure check_base_update(p_base_user_column_name   in varchar2,
                            p_rowid                   in varchar2);

PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2,
                                  p_user_table_id IN NUMBER);

procedure validate_translation(user_column_id	NUMBER,
			       language		VARCHAR2,
			       user_column_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL);

function return_dml_status return boolean;

--------------------------------------------------------------------------------
END PAY_USER_COLUMNS_PKG;

 

/
