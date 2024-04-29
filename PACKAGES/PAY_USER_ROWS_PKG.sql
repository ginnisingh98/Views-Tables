--------------------------------------------------------
--  DDL for Package PAY_USER_ROWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_ROWS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusr01t.pkh 120.1 2005/07/29 05:08:44 shisriva noship $ */
--
-- Checks that the row low range is unique within the given user table
--
procedure check_unique ( p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_business_group_id     in number ) ;

--
-- Overloaded check_unique procedure to accept p_validation_start_date and
-- p_validation_end_date to check the uniquness of row_low_range_or_name
-- only in validation range.Bug No 3734910.
--
procedure check_unique ( p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_business_group_id     in number ,
			 p_validation_start_date in date ,
			 p_validation_end_date   in date) ;
--
-- Checks that the range defined does not contain overlapping values
--
procedure check_overlap ( p_rowid                 in varchar2,
                          p_user_table_id         in number,
                          p_user_row_id           in number,
                          p_row_low_range_or_name in varchar2,
                          p_row_high_range        in varchar2,
                          p_business_group_id     in number);

--
-- Overloaded check_overlap procedure to accept p_validation_start_date and
-- p_validation_end_date to check for overlapping ranges which lie in the
-- validation range.Bug No 3734910.
--

procedure check_overlap ( p_rowid                 in varchar2,
                          p_user_table_id         in number,
                          p_user_row_id           in number,
                          p_row_low_range_or_name in varchar2,
                          p_row_high_range        in varchar2,
                          p_business_group_id     in number,
			  p_validation_start_date in date,
			  p_validation_end_date   in date);

--
-- Set end date if overlapping future rows exist
--
function range_end_date (p_user_table_id         in number,
                         p_effective_start_date  in date,
                         p_row_low_range_or_name in varchar2,
                         p_row_high_range        in varchar2,
                         p_business_group_id     in number)return date;
--
-- Set end date if identical future matches exist
--
function match_end_date (p_user_table_id         in number,
                         p_effective_start_date  in date,
                         p_row_low_range_or_name in varchar2,
                         p_business_group_id     in number) return date;
--
-- Check for future rows before delete next change
--
function future_ranges_exist (p_user_table_id         in number,
                              p_effective_start_date  in date,
                              p_row_low_range_or_name in varchar2,
                              p_row_high_range        in varchar2,
                              p_business_group_id     in number)return boolean;


--
-- Check for future identical matches before delete next change
--


--
-- Overloaded future_ranges_exist procedure to accept p_validation_start_date and
-- p_validation_end_date to check for future ranges only in validation range.
-- Also accepted user_row_id parameter to distinguish other records from future
-- updates of the row for which this function is called.
-- Bug No 3734910.
--


function future_ranges_exist (p_user_table_id         in number,
                              p_effective_start_date  in date,
                              p_row_low_range_or_name in varchar2,
                              p_row_high_range        in varchar2,
                              p_business_group_id     in number,
			      p_user_row_id           in number,
			      p_validation_start_date in date,
			      p_validation_end_date   in date)return boolean;

function future_matches_exist (p_user_table_id         in number,
                               p_effective_start_date  in date,
                               p_row_low_range_or_name in varchar2,
                               p_business_group_id     in number) return boolean;
--
-- Gets the next value for the user_row_id field from the sequence
-- Retrieve the next sequence number
--
procedure get_seq ( p_user_row_id   in out NOCOPY number ) ;
--
-- Package check_unique and get_sequence_number calls
--
procedure pre_insert ( p_rowid                 in 		varchar2,
                       p_user_table_id         in 		number,
                       p_row_low_range_or_name in 		varchar2,
		       p_user_row_id           in out	NOCOPY 	number,
                       p_business_group_id     in 		number,
		       p_ghr_installed	       in 		varchar2 default 'N' ) ;
--
-- Check that the given delete mode is appropriate
--
procedure check_delete_row ( p_user_row_id           in number,
			     p_validation_start_date in date,
			     p_dt_delete_mode        in varchar2 )  ;
--
--For MLS-----------------------------------------------------------------------
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (X_B_ROW_LOW_RANGE_OR_NAME in VARCHAR2,
                         X_B_LEGISLATION_CODE in VARCHAR2,
                         X_ROW_LOW_RANGE_OR_NAME in VARCHAR2,
                         X_OWNER in VARCHAR2);

PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2,
                                  p_user_table_id IN NUMBER);

procedure validate_translation(user_row_id	NUMBER,
			       language		VARCHAR2,
			       row_low_range_or_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL);
--------------------------------------------------------------------------------
END PAY_USER_ROWS_PKG;

 

/
