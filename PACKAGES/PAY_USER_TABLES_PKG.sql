--------------------------------------------------------
--  DDL for Package PAY_USER_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLES_PKG" AUTHID CURRENT_USER AS
/* $Header: pyust01t.pkh 120.1 2005/07/29 05:06:06 shisriva noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Package Header Variable                              |
-- ----------------------------------------------------------------------------
--
g_dml_status boolean := FALSE;  -- Global package variable
--
  procedure insert_row(p_rowid                in out NOCOPY varchar2,
		       p_user_table_id	      in out NOCOPY number,
		       p_business_group_id    in number,
		       p_legislation_code     in varchar2,
		       p_legislation_subgroup in varchar2,
		       p_range_or_match       in varchar2,
		       p_user_key_units       in varchar2,
		       p_user_table_name      in varchar2,
		       p_user_row_title	      in varchar2 )  ;
--
 procedure update_row(p_rowid                in varchar2,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_range_or_match       in varchar2,
		      p_user_key_units       in varchar2,
		      p_user_table_name      in varchar2,
		      p_user_row_title	     in varchar2,
		      p_base_user_table_name in varchar2 default hr_api.g_varchar2,
		      p_base_user_row_title  in varchar2 default hr_api.g_varchar2) ;
--
  procedure delete_row(p_rowid         in varchar2,
		       p_user_table_id in number ) ;
--
  procedure lock_row (p_rowid                in varchar2,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_range_or_match       in varchar2,
		      p_user_key_units       in varchar2,
		      p_user_table_name      in varchar2,
		      p_user_row_title	     in varchar2,
		      p_base_user_table_name      in varchar2 default hr_api.g_varchar2,
		      p_base_user_row_title	  in varchar2 default hr_api.g_varchar2) ;

--
-- This procedure checks whether the user_table_name is unique within business
-- group and legislation_code. If the table name is ok then it succeeds silently
-- otherwise it raises an error.
--
  procedure check_unique ( p_rowid             in varchar2,
			   p_user_table_name   in varchar2,
			   p_business_group_id in number,
			   p_legislation_code  in varchar2,
			   p_base_user_table_name   in varchar2 default hr_api.g_varchar2 ) ;
--
-- Following procedure checks whether the given user table can be
-- deleted. Checks PAY_USER_TABLES and PAY_USER_COLUMNS
--
   procedure check_references ( p_user_table_id in number )  ;
--
-- Name
--  get_db_defaults
-- Purpose
--  Retrieves the db constants used as defaults by the form PAYWSDUT
--  The following are retrieved
--     The field prompts used for the rows zone
--     The text for the datatype of 'N' ( Number )
-- Arguments
--  See below
   procedure get_db_defaults ( p_lower_bound  in out NOCOPY varchar2,
			       p_upper_bound  in out NOCOPY varchar2,
			       p_match_prompt in out NOCOPY varchar2,
			       p_number_text  in out NOCOPY varchar2 ) ;
--
--  function to handle the conversion of 'Exact' values in the user tables
--  LOV's
--
   function ut_lov_conversion ( p_value in varchar2,
			        p_uom in varchar2 ) return varchar2;

--
--For MLS-----------------------------------------------------------------------
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_B_USER_TABLE_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_USER_TABLE_NAME in VARCHAR2,
   X_USER_ROW_TITLE in VARCHAR2,
   X_OWNER in VARCHAR2);

procedure validate_translation(user_table_id	NUMBER,
			       language		VARCHAR2,
			       user_table_name	VARCHAR2,
			       user_row_title	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL);

procedure check_base_update(p_base_user_table_name   in varchar2,
                             p_rowid                  in varchar2);

function return_dml_status return boolean;
--------------------------------------------------------------------------------
END PAY_USER_TABLES_PKG;

 

/
