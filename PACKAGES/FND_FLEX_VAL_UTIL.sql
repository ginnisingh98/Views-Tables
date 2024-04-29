--------------------------------------------------------
--  DDL for Package FND_FLEX_VAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_VAL_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFFFUTVS.pls 120.2.12010000.2 2008/11/10 18:50:54 hgeorgi ship $ */


bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);

-- ==================================================
-- Success Codes.
-- ==================================================
g_ret_no_error                 NUMBER := 0;
g_ret_bad_parameter            NUMBER := 1;
g_ret_exception_others         NUMBER := 2;
g_ret_vs_bad_date              NUMBER := 3;
g_ret_value_too_long           NUMBER := 5;
g_ret_invalid_number           NUMBER := 6;
g_ret_invalid_date             NUMBER := 7;
g_ret_vs_bad_precision         NUMBER := 8;
g_ret_vs_bad_format            NUMBER := 9;
g_ret_vs_bad_numrange          NUMBER := 10;
g_ret_vs_bad_daterange         NUMBER := 11;
g_ret_val_out_of_range         NUMBER := 12;

-- ==============================
-- FUNCTION : is_success
-- ==============================
-- Returns TRUE if p_success is g_ret_no_error,
-- Returns FALSE otherwise.
--
FUNCTION is_success(p_success IN NUMBER) RETURN BOOLEAN;
PRAGMA restrict_references (is_success, wnds, wnps);

-- ==================================================
-- Debugging
-- ==================================================
-- Errors and some internal steps are reported in debug.
--
-- ==============================
-- FUNCTION : get_debug
-- ==============================
-- Returns internal debug string.
--
FUNCTION get_debug RETURN VARCHAR2;

-- ==============================
-- PROCEDURE : set_debuging
-- ==============================
-- Turn ON/OFF debugging mechanism. By default it is turned ON.
--
PROCEDURE set_debugging(p_flag IN BOOLEAN DEFAULT TRUE);

-- ==================================================
-- Date, DateTime, Time and Numeric Format Masks
-- ==================================================
-- ------------------------------
-- Canonical Format Masks.
-- ------------------------------
-- These masks will be used while saving data into database or reading
-- data from database. They are hard coded and not alterable.
--
-- Mask Name:                Value:
-- -----------------------------------------------
-- CANONICAL_DATE          | 'YYYY/MM/DD HH24:MI:SS'
-- CANONICAL_DATETIME      | 'YYYY/MM/DD HH24:MI:SS'
-- CANONICAL_TIME          | 'HH24:MI:SS'
-- CANONICAL_NUMERIC_CHARS | '.,'
-- DB_NUMERIC_CHARS        | substr(to_char(1234.5,'FM9G999D9'), 6, 1) ||
--                         | substr(to_char(1234.5,'FM9G999D9'), 2, 1)
--
-- ------------------------------
-- NLS Masks.
-- ------------------------------
-- These masks will be used while interacting with user. IN masks will
-- be used while reading data from user, and OUT masks will be used while
-- presenting data to user.
-- They can be updated using set_mask function.
--
-- Out masks can only have one of it's kind.
-- In masks can be multiple, if multiple, must be seperated by '|'.
--
-- Mask Name :             Default Value:
-- ------------------------------------------------
-- NLS_DATE_IN	         | fnd_date.user_mask
-- NLS_DATE_OUT	         | fnd_date.output_mask
-- NLS_DATETIME_IN       | fnd_date.userdt_mask
-- NLS_DATETIME_OUT      | fnd_date.outputdt_mask
-- NLS_TIME_IN	         | 'HH24:MI:SS'
-- NLS_TIME_OUT	         | 'HH24:MI:SS'
-- NLS_NUMERIC_CHARS_IN  | substr(to_char(1234.5,'FM9G999D9'), 6, 1) ||
--                       | substr(to_char(1234.5,'FM9G999D9'), 2, 1)
-- NLS_NUMERIC_CHARS_OUT | substr(to_char(1234.5,'FM9G999D9'), 6, 1) ||
--                       | substr(to_char(1234.5,'FM9G999D9'), 2, 1)
--
-- ==============================
-- FUNCTION : get_mask
-- ==============================
-- Returns TRUE and the value of mask. Valid masks are given above.
-- Returns FALSE if the mask is not valid.
--
FUNCTION get_mask(p_mask_name  IN VARCHAR2,
		  x_mask_value OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

-- ==============================
-- FUNCTION : set_mask
-- ==============================
-- Sets the value of mask and returns TRUE. Valid masks are given above.
-- Returns FALSE if the mask is not valid.
--
FUNCTION set_mask(p_mask_name  IN VARCHAR2,
		  p_mask_value IN VARCHAR2) RETURN BOOLEAN;

-- ==============================
-- PROCEDURE : get_storage_format
-- ==============================
-- Returns the storage format of a value set.
-- Value set format type should be in {Number (N), Date (D), DateTime (T)
-- Time (I, t), Standard Date (X), Standard DateTime (Y), Standard Time (Z)}
-- In case of failure return FALSE.
--
FUNCTION get_storage_format(p_vset_format IN VARCHAR2,
			    p_max_length  IN NUMBER,
			    p_precision   IN NUMBER DEFAULT NULL,
			    x_format      OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

-- ==============================
-- PROCEDURE : get_display_format
-- ==============================
-- Returns the display format of a value set.
-- Value set format type should be in {Number (N), Date (D), DateTime (T)
-- Time (I, t), Standard Date (X), Standard DateTime (Y), Standard Time (Z)}
-- x_format_in  is the FROM USER TO VALIDATION ENGINE format.
-- x_format_out is the FROM VALIDATION ENGINE TO USER format.
-- In case of failure return FALSE.
--
FUNCTION get_display_format(p_vset_format IN VARCHAR2,
			    p_max_length  IN NUMBER,
			    p_precision   IN NUMBER DEFAULT NULL,
			    x_format_in   OUT NOCOPY VARCHAR2,
			    x_format_out  OUT NOCOPY VARCHAR2) RETURN BOOLEAN;
-- ==============================
-- FUNCTION : is_date
-- ==============================
-- Checks whether a string is in correct date format, if so returns its date
-- value, otherwise returns FALSE.
-- p_nls_date_format can have multiple date masks separated by '|'.
--
FUNCTION is_date(p_value           IN VARCHAR2,
		 p_nls_date_format IN VARCHAR2 DEFAULT NULL,
		 x_date            OUT NOCOPY DATE) RETURN BOOLEAN;
PRAGMA restrict_references (is_date, wnds);

-- ==============================
-- FUNCTION : flex_to_date
-- ==============================
-- Cover routine for is_date, and this one returns DATE.
-- In case of error it returns NULL.
--
FUNCTION flex_to_date(p_value           IN VARCHAR2,
		      p_nls_date_format IN VARCHAR2) RETURN DATE;
PRAGMA restrict_references(flex_to_date, wnds);

-- ==============================
-- FUNCTION : is_number
-- ==============================
-- Checks whether a string is in correct number format, if so returns its
-- number value, and its db equivalent, otherwise returns FALSE.
-- p_nls_numeric_chars can have multiple NLS_NUMERIC_CHARS separated by '|'.
--
FUNCTION is_number(p_value             IN VARCHAR2,
		   p_nls_numeric_chars IN VARCHAR2,
		   x_value             OUT NOCOPY VARCHAR2,
		   x_number            OUT NOCOPY NUMBER) RETURN BOOLEAN;
PRAGMA restrict_references (is_number, wnds);

-- ==============================
-- FUNCTION : flex_to_number
-- ==============================
-- Cover routine for is_number, and this one returns NUMBER.
-- In case of error it returns NULL.
--
FUNCTION flex_to_number(p_value             IN VARCHAR2,
			p_nls_numeric_chars IN VARCHAR2) RETURN NUMBER;
PRAGMA restrict_references(flex_to_number, wnds);

-- ==============================
-- PROCEDURE : validate_value
-- ==============================
-- Validates the given value.
--
PROCEDURE validate_value(p_value             IN VARCHAR2,
			 p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			 p_vset_name         IN VARCHAR2 DEFAULT NULL,
			 p_vset_format       IN VARCHAR2 DEFAULT 'C',
			 p_max_length        IN NUMBER   DEFAULT 0,
			 p_precision         IN NUMBER   DEFAULT NULL,
			 p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			 p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			 p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			 p_min_value         IN VARCHAR2 DEFAULT NULL,
			 p_max_value         IN VARCHAR2 DEFAULT NULL,
			 x_storage_value     OUT NOCOPY VARCHAR2,
			 x_display_value     OUT NOCOPY VARCHAR2,
			 x_success           OUT NOCOPY BOOLEAN);

-- ==============================
-- FUNCTION : is_value_valid
-- ==============================
-- Checks if a value is valid or not.
--
FUNCTION is_value_valid(p_value             IN VARCHAR2,
			p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			p_vset_name         IN VARCHAR2 DEFAULT NULL,
			p_vset_format       IN VARCHAR2 DEFAULT 'C',
			p_max_length        IN NUMBER   DEFAULT 0,
			p_precision         IN NUMBER   DEFAULT NULL,
			p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			p_min_value         IN VARCHAR2 DEFAULT NULL,
			p_max_value         IN VARCHAR2 DEFAULT NULL,
			x_storage_value     OUT NOCOPY VARCHAR2,
			x_display_value     OUT NOCOPY VARCHAR2) RETURN BOOLEAN;
PRAGMA restrict_references (is_value_valid, wnds);

-- ==============================
-- FUNCTION : to_display_value
-- ==============================
-- Returns display equivalent of a storage value.
-- Returns NULL in case of an error.
--
FUNCTION to_display_value(p_value             IN VARCHAR2,
			  p_vset_format       IN VARCHAR2 DEFAULT 'C',
			  p_vset_name         IN VARCHAR2 DEFAULT NULL,
			  p_max_length        IN NUMBER   DEFAULT 0,
			  p_precision         IN NUMBER   DEFAULT NULL,
			  p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			  p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			  p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			  p_min_value         IN VARCHAR2 DEFAULT NULL,
			  p_max_value         IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;
PRAGMA restrict_references (to_display_value, wnds);

-- ==============================
-- FUNCTION : to_storage_value
-- ==============================
-- Returns storage equivalent of a display value.
-- Returns NULL in case of an error.
--
FUNCTION to_storage_value(p_value             IN VARCHAR2,
			  p_vset_format       IN VARCHAR2 DEFAULT 'C',
			  p_vset_name         IN VARCHAR2 DEFAULT NULL,
			  p_max_length        IN NUMBER   DEFAULT 0,
			  p_precision         IN NUMBER   DEFAULT NULL,
			  p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			  p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			  p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			  p_min_value         IN VARCHAR2 DEFAULT NULL,
			  p_max_value         IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;
PRAGMA restrict_references (to_storage_value, wnds);

-- ==============================
-- PROCEDURE : validate_value_private
-- ==============================
-- This procedure can only be used by Flexfields Server Side
-- Validation Engine. This is exactly same as validate_value, but
-- this one returns success code.
--
PROCEDURE validate_value_ssv(p_value             IN VARCHAR2,
			     p_is_displayed      IN BOOLEAN  DEFAULT TRUE,
			     p_vset_name         IN VARCHAR2 DEFAULT NULL,
			     p_vset_format       IN VARCHAR2 DEFAULT 'C',
			     p_max_length        IN NUMBER   DEFAULT 0,
			     p_precision         IN NUMBER   DEFAULT NULL,
			     p_alpha_allowed     IN VARCHAR2 DEFAULT 'Y',
			     p_uppercase_only    IN VARCHAR2 DEFAULT 'N',
			     p_zero_fill         IN VARCHAR2 DEFAULT 'N',
			     p_min_value         IN VARCHAR2 DEFAULT NULL,
			     p_max_value         IN VARCHAR2 DEFAULT NULL,
			     x_storage_value     OUT NOCOPY VARCHAR2,
			     x_display_value     OUT NOCOPY VARCHAR2,
			     x_success           OUT NOCOPY NUMBER);
PRAGMA restrict_references (validate_value_ssv, wnds);

-- ==============================
-- PROCEDURE : get_server_global
-- ==============================
-- Used to get server side globals that can be retrieved as (in PL/SQL);
-- BEGIN
--   x_char_out := p_char_in;
-- END;
--
-- x_error   : NUMBER : 0    : success
--                      else : failure (SQLCODE)
-- x_message : VARCHAR2(1998): encoded error message, in case of failure.
--
-- This procedure can also be used to call server side functions which return
-- VARCHAR2.
--
-- p_char_in examples :
-- --------------------
--    'fnd_date.user_mask'
--    'fnd_number.decimal_character || fnd_number.group_separator'
--    'fnd_number.number_to_canonical(1234.567)'
--
--
PROCEDURE get_server_global(p_char_in  IN VARCHAR2,
			    x_char_out OUT NOCOPY VARCHAR2,
			    x_error    OUT NOCOPY NUMBER,
			    x_message  OUT NOCOPY VARCHAR2);

-- ==============================
-- PROCEDURE : vtv_to_display_value
-- ==============================
-- Converts the internal VTV (Compiled Value Attribute Values)
-- (For historical reasons it is called VTV) to displayed values.
-- i.e. Y\nN\nA will become : Yes.No.Asset in English.
-- This function is used by FNDFFMSV (Flex Values form.)
--
-- This function will do it's best, if any kind of failure happens
-- it will return NULL. No exception is raised.
--
-- If p_use_default is TRUE and the storage value is not complete,
-- this procedure will use the default values for segment qualifiers.
--
PROCEDURE vtv_to_display_value(p_flex_value_set_id IN NUMBER,
			       p_use_default       IN BOOLEAN,
			       p_storage_value     IN VARCHAR2,
			       x_display_value     OUT NOCOPY VARCHAR2);

-- ===============================
-- PROCEDURE : flex_date_converter
-- ===============================
-- Flexfields date converter, (supports timezones)
--
-- p_vs_format_type : Value set format type.
-- p_tz_direction   : Time zone conversion direction.
--                    '1' : Server to local, '2' : Local to server.
-- p_input_mask     : Format mask for input value.
-- p_input          : Input datetime value as vc2.
-- p_output_mask    : Format mask for output value.
-- x_output         : Output datetime value as vc2.
-- x_error          : Error code, 0 if there is no error.
-- x_message        : Error message in case of error.
--
PROCEDURE flex_date_converter(p_vs_format_type IN VARCHAR2,
			      p_tz_direction   IN VARCHAR2,
			      p_input_mask     IN VARCHAR2,
			      p_input          IN VARCHAR2,
			      p_output_mask    IN VARCHAR2,
			      x_output         OUT NOCOPY VARCHAR2,
			      x_error          OUT NOCOPY NUMBER,
			      x_message        OUT NOCOPY VARCHAR2);

-- =======================================================================
--          Added by NGOUGLER START
-- =======================================================================
-- ===============================
-- PROCEDURE : flex_date_converter_cal
-- ===============================
-- Flexfields calendar date converter, (supports timezones)
--
-- p_vs_format_type : Value set format type.
-- p_tz_direction   : Time zone conversion direction.
--                    '1' : Server to local, '2' : Local to server.
-- p_cal_direction   : Calendar conversion direction.
--                    '1' : Gregorain to User calendar, '2' : User to Gregorian calendar
-- p_mask     : Format mask for date value
-- p_calendar    :  Calendar information for date value
-- p_input          : Input datetime value as vc2.
-- x_output         : Output datetime value as vc2.
-- x_error          : Error code, 0 if there is no error.
-- x_message        : Error message in case of error.
--

PROCEDURE flex_date_converter_cal(p_vs_format_type IN VARCHAR2,
			      p_tz_direction   IN VARCHAR2,
                                          p_cal_direction  IN VARCHAR2,
			      p_mask     IN VARCHAR2,
			      p_calendar    IN VARCHAR2,
			      p_input          IN VARCHAR2,
			      x_output         OUT NOCOPY VARCHAR2,
			      x_error          OUT NOCOPY NUMBER,
			      x_message        OUT NOCOPY VARCHAR2);


-- =======================================================================
--          Added by NGOUGLER END
-- =======================================================================


END fnd_flex_val_util;

/
