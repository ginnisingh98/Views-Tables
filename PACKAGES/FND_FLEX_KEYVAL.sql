--------------------------------------------------------
--  DDL for Package FND_FLEX_KEYVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_KEYVAL" AUTHID CURRENT_USER AS
/* $Header: AFFFKVLS.pls 120.1.12010000.1 2008/07/25 14:14:08 appldev ship $ */


/* ------------------------------------------------------------------------ */
/*				OVERVIEW				    */
/*									    */
/*	These key flexfields server validation API functions are a          */
/*	low level interface to key flexfields validation.  They are         */
/*	designed to allow access to all the flexfields functionality,       */
/*	and to allow the user to get only the information they need in      */
/*	return.  Because of their generality, these functions are more      */
/*	difficult to use than those in the FND_FLEX_EXT package.  We        */
/*	strongly suggest using the functions in FND_FLEX_EXT if at          */
/*	all possible.  							    */
/*									    */
/*	The main functions in this package are validate_segs() and          */
/*	validate_ccid().  These functions are called with either the        */
/*	key flexfield segments or combination id, respecitvely.  They       */
/*	look up or create the desired combination and return TRUE if        */
/*	everything is ok, or FALSE on error.  The results and/or error      */
/*	messages are not returned directly, but rather are stored in        */
/*	PLSQL package globals whose contents can be accessed by the         */
/*	remaining functions in this package.  The global variables are      */
/*	reset upon each call to validate_segs() or validate_ccid() so       */
/*	the calling function must get all needed results before passing     */
/*	in the next combination.					    */
/*									    */
/*	The global variable access functions can be grouped into status     */
/*	functions (is_valid, is_secured, value_error, unsupported_error,    */
/*	and serious_error), error message functions (error_message,         */
/*	encoded_error_message, and error_segment), and combination          */
/*	information functions (the remaining ones).  The status functions   */
/*	are allways set after each call to validate_segs() or               */
/*	validate_ccid().  The error messages are null unless the            */
/*	combination is invalid.  The error_segment is null unless the       */
/*	error can be traced to a specific segment of the combination.       */
/*									    */
/*	Because each product typically only uses a subset of the            */
/*	complete flexfields functionality, we recommend that each	    */
/*	application team code a server-side PLSQL function over the         */
/*	routines in this package.  This allows the application to           */
/*	use only the functionality they need, and can be used to make       */
/*	a function that returns all of its output as OUT parameters         */
/*	in a single call rather than having to make multiple calls to       */
/*	retrieve the desired results.					    */
/*									    */
/*	Also note that the breakup_segments(), get_delimiter() and          */
/*	concatenate_segments() functions of the FND_FLEX_EXT package        */
/*	can be used to convert between concatenated segments and a          */
/*	PLSQL table of segment values.					    */
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------ */
/* 				VALIDATE_SEGS:				    */
/*	Finds combination from given segment values.			    */
/*	Segments are passed in as a concatenated string in increasing	    */
/*	order of segment_number (display order).			    */
/*	Operation is one of:						    */
/*	  'FIND_COMBINATION' - Combination must already exist.	  	    */
/*	  'CREATE_COMBINATION' - Combination is created if doesn't exist.   */
/*        'CREATE_COMB_NO_AT' - same as create_combination but does not     */
/*                              use an autonomous transaction.              */
/*	  'CHECK_COMBINATION' - Checks if combination valid, doesn't create.*/
/*	  'DEFAULT_COMBINATION' - Returns minimal default combination.      */
/*	  'CHECK_SEGMENTS' - Validates segments individually.		    */
/*									    */
/*	If validation date is NULL checks all cross-validation rules.	    */
/*	Returns TRUE if combination valid, or FALSE and sets error message  */
/*	on server if invalid. 						    */
/*									    */
/*	The defaulted arguments listed after combination_id are all         */
/*	optional.  Use the default values if you do not want any special    */
/*	functionality.  Defaulted argument descriptions:		    */
/*	-  user_id, resp_id, and resp_appl_id identify the user and         */
/*	   responsibility.  They default to the values from FND_GLOBAL      */
/*	   which are set by the navigator form if this database session     */
/*	   underlies a form on the client or by the concurrent manager if   */
/*	   this package is in a database session started through the        */
/*	   concurrent manager.						    */
/*	-  Values_or_ids indicates whether input segments are values ('V')  */
/*	   hidden ids ('I').  If values are input the function expects one  */
/*	   value for every displayed segment, whereas if ids are input the  */
/*	   function expects one id for each enabled segment whether or not  */
/*	   the segment is displayed.					    */
/*	-  displayable is used to specify which segments are displayed.     */
/*	   This argument allows the user to not display segments that would */
/*	   otherwise be displayed based on the flexfield definition.        */
/*	-  data_set specifies the effective flexfield structure number to   */
/*	   use when selecting or inserting into the combinations table.     */
/*	-  vrule can be used to impose additional validation constraints    */
/*	   based on flexfield qualifier values.				    */
/*	-  where_clause limits existing combinations based on a user-       */
/*	   specified SQL where clause expression.  Only use with dinsert    */
/*	   FALSE.						 	    */
/*	-  get_columns specifies additional columns from the combinations   */
/*	   table that are to be retrieved when a combination is found.      */
/*	-  allow_nulls and allow_orphans are only checked if the operation  */
/*	   is 'CHECK_SEGMENTS'.  In this case, if allow_nulls is TRUE then  */
/*	   required segments that are null will be considered valid.  If    */
/*	   allow_orphans is TRUE, then all possible dependent segment       */
/*	   values be valid if the parent segment is null.		    */
/* ------------------------------------------------------------------------ */
  FUNCTION validate_segs(operation	IN  VARCHAR2,
		      appl_short_name 	IN  VARCHAR2,
		      key_flex_code	IN  VARCHAR2,
		      structure_number	IN  NUMBER,
		      concat_segments	IN  VARCHAR2,
		      values_or_ids	IN  VARCHAR2 DEFAULT 'V',
		      validation_date	IN  DATE DEFAULT SYSDATE,
		      displayable     	IN  VARCHAR2 DEFAULT 'ALL',
		      data_set		IN  NUMBER   DEFAULT NULL,
		      vrule		IN  VARCHAR2 DEFAULT NULL,
		      where_clause  	IN  VARCHAR2 DEFAULT NULL,
		      get_columns	IN  VARCHAR2 DEFAULT NULL,
		      allow_nulls	IN  BOOLEAN  DEFAULT FALSE,
		      allow_orphans	IN  BOOLEAN  DEFAULT FALSE,
		      resp_appl_id	IN  NUMBER   DEFAULT NULL,
		      resp_id		IN  NUMBER   DEFAULT NULL,
		      user_id		IN  NUMBER   DEFAULT NULL,
		      select_comb_from_view  IN  VARCHAR2 DEFAULT NULL,
		      no_combmsg        IN VARCHAR2 DEFAULT NULL,
		      where_clause_msg  IN VARCHAR2 DEFAULT NULL)
							    RETURN BOOLEAN;

/* ------------------------------------------------------------------------ */
/* 				VALIDATE_CCID:				    */
/*	Looks up flexfield combination by its combination id.		    */
/*	Returns TRUE if combination found, otherwise returns FALSE 	    */
/*	and sets error on the server.  Checks value security rules, 	    */
/*	but violations do not invalidate the combination.		    */
/*	The defaulted arguments listed after combination_id are all         */
/*	optional.  Use the default values if you do not want any special    */
/*	functionality.  Defaulted argument descriptions:		    */
/*	-  user_id, resp_id, and resp_appl_id identify the user and         */
/*	   responsibility.  They default to the values from FND_GLOBAL      */
/*	   which are set by the navigator form if this database session     */
/*	   underlies a form on the client or by the concurrent manager if   */
/*	   this package is in a database session started through the        */
/*	   concurrent manager.  These parameters are used to determine if   */
/*	   values are secured.  Combinations with secrued values can still  */
/*	   be looked up using this function without returning an error,     */
/*	   but this function will note if any segments violate security.    */
/*	   Use is_secured to check if security violated.  	            */
/*	-  displayable is used to specify which segments are displayed.     */
/*	   This argument allows the user to not display segments that would */
/*	   otherwise be displayed based on the flexfield definition.        */
/*	   Only the displayed segments are returned.			    */
/*	-  data_set specifies the effective flexfield structure number to   */
/*	   use when selecting or inserting into the combinations table.     */
/*	-  vrule can be used to impose additional validation constraints    */
/*	   based on flexfield qualifier values.				    */
/*	-  Get_columns specifies additional columns from the combinations   */
/*	   table that are to be retrieved when a combination is found.      */
/*	-  security determines whether or not to check value security.      */
/*	   IGNORE  - ignores value security altogether.			    */
/*	   CHECK   - checks security, but violation is not an error.	    */
/*	   ENFORCE - Stop validating and return error ifs security violated.*/
/* ------------------------------------------------------------------------ */

  FUNCTION validate_ccid(appl_short_name 	IN  VARCHAR2,
			key_flex_code	  	IN  VARCHAR2,
			structure_number	IN  NUMBER,
			combination_id	  	IN  NUMBER,
			displayable		IN  VARCHAR2 DEFAULT 'ALL',
			data_set		IN  NUMBER   DEFAULT NULL,
			vrule			IN  VARCHAR2 DEFAULT NULL,
			security		IN  VARCHAR2 DEFAULT 'IGNORE',
			get_columns		IN  VARCHAR2 DEFAULT NULL,
			resp_appl_id 		IN  NUMBER   DEFAULT NULL,
			resp_id			IN  NUMBER   DEFAULT NULL,
			user_id			IN  NUMBER   DEFAULT NULL,
			select_comb_from_view   IN  VARCHAR2 DEFAULT NULL)
							RETURN BOOLEAN;

/* ------------------------------------------------------------------------ */
/*	Functions for getting more details about the most recently	    */
/*	validated combination.	These typically do not trap errors 	    */
/*	related to the user not leaving enough room in destination 	    */
/*	strings to store the result.					    */
/* ------------------------------------------------------------------------ */

FUNCTION is_valid RETURN BOOLEAN;
FUNCTION is_secured RETURN BOOLEAN;
FUNCTION value_error RETURN BOOLEAN;
FUNCTION unsupported_error RETURN BOOLEAN;
FUNCTION serious_error RETURN BOOLEAN;

FUNCTION error_segment RETURN NUMBER;
FUNCTION error_message RETURN VARCHAR2;
FUNCTION encoded_error_message RETURN VARCHAR2;

FUNCTION new_combination RETURN BOOLEAN;
FUNCTION combination_id RETURN NUMBER;
FUNCTION segment_delimiter RETURN VARCHAR2;

/* ------------------------------------------------------------------------ */
/*	Concatenated segment values and descriptions are only those	    */
/*	displayed, and descriptions are truncated to catdesc_len.  Ids are  */
/*	returned for all enabled segments whether or not they are displayed.*/
/* ------------------------------------------------------------------------ */
FUNCTION concatenated_values RETURN VARCHAR2;
FUNCTION concatenated_ids RETURN VARCHAR2;
FUNCTION concatenated_descriptions RETURN VARCHAR2;


FUNCTION enabled_flag RETURN BOOLEAN;
FUNCTION summary_flag RETURN BOOLEAN;

/* ------------------------------------------------------------------------ */
/*	If start or end date is null => no limit.  			    */
/* ------------------------------------------------------------------------ */
FUNCTION start_date RETURN DATE;
FUNCTION end_date RETURN DATE;

/* ------------------------------------------------------------------------ */
/*    Segnum indexes all enabled segments whether or not they are displayed */
/* ------------------------------------------------------------------------ */
FUNCTION segment_count RETURN NUMBER;
FUNCTION segment_value(segnum  IN  NUMBER) RETURN VARCHAR2;
FUNCTION segment_id(segnum  IN  NUMBER) RETURN VARCHAR2;
FUNCTION segment_description(segnum  IN  NUMBER) RETURN VARCHAR2;
FUNCTION segment_concat_desc_length(segnum  IN  NUMBER) RETURN NUMBER;
FUNCTION segment_displayed(segnum  IN  NUMBER) RETURN BOOLEAN;
FUNCTION segment_valid(segnum  IN  NUMBER) RETURN BOOLEAN;
FUNCTION segment_column_name(segnum  IN  NUMBER) RETURN VARCHAR2;
FUNCTION segment_column_type(segnum  IN  NUMBER) RETURN VARCHAR2;

/* ------------------------------------------------------------------------ */
/*	Colnum indexes column requested with the get_columns token in 	    */
/*	the order in which the columns were requested. (1 to N)		    */
/* ------------------------------------------------------------------------ */
FUNCTION column_count RETURN NUMBER;
FUNCTION column_value(colnum  IN  NUMBER) RETURN VARCHAR2;

FUNCTION qualifier_value(segqual_name  	   IN  VARCHAR2,
			 table_or_derived  IN  VARCHAR2  DEFAULT 'D')
							RETURN VARCHAR2;

/* ------------------------------------------------------------------------ */

END fnd_flex_keyval;

/
