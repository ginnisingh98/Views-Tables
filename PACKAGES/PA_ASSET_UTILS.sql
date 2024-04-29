--------------------------------------------------------
--  DDL for Package PA_ASSET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSET_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXAUTLS.pls 115.0 99/07/16 15:18:45 porting ship $


--
--  FUNCTION
--              check_unique_asset_name
--  PURPOSE
--              This function returns 1 if asset name is not already
--              used for assets on this project and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--
function check_unique_asset_name (x_asset_name  IN varchar2,
				  x_project_id IN number,
                                    x_rowid       IN varchar2 ) return number;
--
--  FUNCTION
--              check_valid_asset_number
--  PURPOSE
--              This function returns
--                 1 if asset number has not been used by PA.
--                 0 if asset number is already in use in PA
--                      (further checking should be done to make
--                      sure the asset is not in use in FA.  See
--                      the FA_MASS_ADD_VALIDATE package.
--
--              If Oracle error occurs, Oracle error number is returned.
--
--
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--
function check_valid_asset_number (x_asset_number  IN varchar2,
                                    x_rowid       IN varchar2 ) return number;
--
--  FUNCTION
--              check_asset_references
--  PURPOSE
--              This function returns 1 if an asset can be deleted, and
--		returns 0 if the asset has references which prevent it
--		from being deleted.
--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--

function check_asset_references (x_project_asset_id  IN number)
						 return number;


--  FUNCTION
--              check_fa_asset_num
--  PURPOSE
--              This function returns a 1 if the asset number being
--             	checked is one of the valid FA asset numbers for the
--		given pa_asset_id.  This function returns a 0 if the
--		asset number is NOT a valid FA asset number for the
--		given pa_asset_id.

--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   29-JAN-96      C. Conlin       Created
--
--
function check_fa_asset_num(pa_asset_id IN NUMBER,
			  check_asset_number IN VARCHAR2) return number;

--  FUNCTION
--              fa_implementation_status
--  PURPOSE
--         	Returns a 'Y' if FA is implemented.  Returns a 'N'
--		if FA is not implemented.
--
--

FUNCTION fa_implementation_status RETURN VARCHAR2;

end pa_asset_utils;

 

/
