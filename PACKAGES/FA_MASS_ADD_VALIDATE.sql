--------------------------------------------------------
--  DDL for Package FA_MASS_ADD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_ADD_VALIDATE" AUTHID CURRENT_USER as
-- $Header: faxmads.pls 120.2.12010000.3 2009/08/05 20:23:23 bridgway ship $


--  FUNCTION
--              check_valid_asset_number
--  PURPOSE
--              This function returns
--		   1 if asset number has not been used by FA and
--			does not conflict with FA automatic numbers
--		   0 if asset number is already in use
--		   2 if asset number is not in use, but conflicts with FA
--			automatic numbering
--
--              If Oracle error occurs, Oracle error number is returned.
--
--
--  HISTORY
--   28-NOV-95      C. Conlin       Created
--
--
function check_valid_asset_number(x_asset_number  IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                                    return number;
-- Fix for Bug #4183210.  Comment out the pragma reference
-- pragma RESTRICT_REFERENCES (check_valid_asset_number, WNDS, WNPS );

--
--  FUNCTION
--              can_add_to_asset
--  PURPOSE
--              This function returns 1 if the asset can receive
--	 	additional cost and returns 0 if the asset cannot
--		receive additional cost.
--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-NOV-95      C. Conlin       Created
--
--
function can_add_to_asset(x_asset_id  IN number,
			  x_book_type_code IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                                    return number;
--  FUNCTION
--             valid_date_in_service
--  PURPOSE
--              This function returns 1 if the date placed in service
--              is valid and returns 0 if the date placed in service
--              is not valid.
--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-NOV-95      C. Conlin       Created
--
function valid_date_in_service(x_date_in_service IN date,
				x_book_type_code IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                                    return number;
 pragma RESTRICT_REFERENCES (valid_date_in_service, WNDS, WNPS );


end fa_mass_add_validate;

/
