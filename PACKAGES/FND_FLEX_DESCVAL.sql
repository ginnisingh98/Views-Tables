--------------------------------------------------------
--  DDL for Package FND_FLEX_DESCVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_DESCVAL" AUTHID CURRENT_USER AS
/* $Header: AFFFDVLS.pls 120.1.12010000.3 2017/02/13 22:00:08 tebarnes ship $ */


/* ------------------------------------------------------------------------ */
/*	SET_CONTEXT_VALUE():						    */
/*	Sets the contex value in PLSQL global memory in preparation for     */
/*	calling validate_desccols().  See validate_desccols() for more      */
/*	information.							    *
/* ------------------------------------------------------------------------ */

  PROCEDURE set_context_value(context_value  IN  VARCHAR2);

/* ------------------------------------------------------------------------ */
/*	SET_COLUMN_VALUE():						    */
/*	Sets the values for the named columns in PLSQL global memory in     */
/*	preparation for calling validate_desccols().  This function is      */
/*	overloaded for use with VARCHAR2, NUMBER, and DATE type columns.    */
/*	See validate_desccols() for more information.			    */
/* ------------------------------------------------------------------------ */

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
			     column_value IN VARCHAR2);

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
			     column_value IN NUMBER);

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
			     column_value IN DATE);

/* ------------------------------------------------------------------------ */
/*	CLEAR_COLUMN_VALUES():						    */
/*	Clears all values for the columns in PLSQL global memory that were  */
/*	defined by previous calls to set_column_value().   Note that column */
/*	values are also cleared after calling VALIDATE_DESCCOLS() or        */
/*      VAL_DESC().  See also set_column_value().                           */
/* ------------------------------------------------------------------------ */

  PROCEDURE clear_column_values;

/* ------------------------------------------------------------------------ */
/*	VALIDATE_DESCCOLS():						    */
/*	Checks descriptive flexfield information prior to inserting it      */
/*	into the table upon which the desciptive flexfield is defined.      */
/*	The user must first pass the values or ids for all columns that     */
/*	might be used in the descriptive flexfield by setting them in       */
/*	PLSQL package globals by calling set_column_value(). The context    */
/*	column value can either be set as one of the column values, or      */
/*	can be set directly by set_context_value().  The context column     */
/*	name and the set of all possible columns the flexfield can use      */
/*	can be obtained from the register descriptive flexfields form.      */
/*
/*	This function is will indicate an error if any of the values are    */
/*	invalid, disabled, expired or not available for the current user    */
/*	because of value security rules.  The user information is obtained  */
/*	from the FND_GLOBAL package which is set automatically if the       */
/*	database session was started from Oracle forms or by the concurrent */
/*	manager.  If the session was started directly from SQL*Plus the     */
/*	user information is not set automatically and can optionally be     */
/*	passed in using resp_appl_id and resp_id.			    */
/*									    */
/*	Returns TRUE if all segments of the descriptive flexfield are	    */
/*	valid.  otherwise returns FALSE and sets the validation status      */
/*	codes to indicate the detailed nature of the error.		    */
/*	If this function returns TRUE, the segment information for the      */
/*	most recently validated flexfield can be retrieved using the data   */
/*	retrieval functions.  If the function returns FALSE, the segment    */
/*	data will be null, but the error message can be read.		    */
/*									    */
/*	Do not use enabled_activation.  This is for AOL internal use only.  */
/*	Only supports IDs input (values_or_ids = 'I') at this time.	    */
/* ------------------------------------------------------------------------ */

  FUNCTION validate_desccols(appl_short_name 	IN  VARCHAR2,
		    desc_flex_name	IN  VARCHAR2,
		    values_or_ids	IN  VARCHAR2 DEFAULT 'I',
		    validation_date	IN  DATE     DEFAULT SYSDATE,
		    enabled_activation	IN  BOOLEAN  DEFAULT TRUE,
		    resp_appl_id	IN  NUMBER   DEFAULT NULL,
		    resp_id		IN  NUMBER   DEFAULT NULL)
							    RETURN BOOLEAN;

/* ------------------------------------------------------------------------ */
/*	VAL_DESC():							    */
/*	Checks descriptive flexfield information that is passed in as a     */
/*	concatenated string of segment ids or values.  This function is     */
/*	designed to be used to verify the validity of descriptive flexfield */
/*	information before being inserted into a table.	It will indicate    */
/*	an error if any of the values are invalid, disabled, expired or     */
/*	not available for the current user because of value security rules. */
/*									    */
/*	Returns TRUE if all segments of the descriptive flexfield are	    */
/*	valid.  otherwise returns FALSE and sets the validation status      */
/*	codes to indicate the detailed nature of the error.		    */
/*	If this function returns TRUE, the segment information for the      */
/*	most recently validated flexfield can be retrieved using the data   */
/*	retrieval functions.  If the function returns FALSE, the segment    */
/*	data will be null, but the error message can be read.		    */
/*									    */
/*	ARGUMENTS:							    */
/*	===========							    */
/*	The descriptive flexfield is identified by appl_short_name and      */
/*	desc_flex_name.  A string representing the concatenated ids or      */
/*	values is input in concat_segments.  This string should have the    */
/*	id or values in the order in which they are displayed in the edit   */
/*	window with global segments followed by the context segment,        */
/*	followed by the context-sensitive segments.  If ids are passed in   */
/*	one id is required for each enabled segment even if the segment is  */
/*	not displayed.  If values are input, only pass in values for the    */
/*	displayed segments and the rest will be defaulted.  The values or   */
/*	ids can be input in a PLSQL table and concatenated using the        */
/*	FND_FLEX_EXT.concatenate_segments() utility.  Values_or_ids         */
/*	indicates whether input segments are values ('V') or ids ('I').     */
/*	The validation date is used to check whether the values are         */
/*	active for that date.  The resp_appl_id, and resp_id arguments 	    */
/*	identify the user for the purposes of value security rules.         */
/*	If these are not specified the values from FND_GLOBAL will          */
/*	be used.  The FND_GLOBAL values are set by the form or by           */
/*	the concurrent program that starts this database session.           */
/*	The enabled_activation flag is for internal use only.  It is not    */
/*	supported outside of the Application Object Library.		    */
/* ------------------------------------------------------------------------ */

  FUNCTION val_desc(appl_short_name 	IN  VARCHAR2,
		    desc_flex_name	IN  VARCHAR2,
		    concat_segments	IN  VARCHAR2,
		    values_or_ids	IN  VARCHAR2 DEFAULT 'I',
		    validation_date	IN  DATE     DEFAULT SYSDATE,
		    enabled_activation	IN  BOOLEAN  DEFAULT TRUE,
		    resp_appl_id	IN  NUMBER   DEFAULT NULL,
		    resp_id		IN  NUMBER   DEFAULT NULL)
							    RETURN BOOLEAN;


  FUNCTION val_desc_and_redefault(appl_short_name 	IN  VARCHAR2,
		    desc_flex_name	IN  VARCHAR2,
		    concat_segments	IN  VARCHAR2,
		    validation_date	IN  DATE     DEFAULT SYSDATE,
		    enabled_activation	IN  BOOLEAN  DEFAULT TRUE,
		    resp_appl_id	IN  NUMBER   DEFAULT NULL,
		    resp_id		IN  NUMBER   DEFAULT NULL,
                    srs_reqst_appl_id   IN  NUMBER   DEFAULT NULL,
                    srs_reqst_id        IN  NUMBER   DEFAULT NULL,
                    srs_reqst_pgm_id    IN  NUMBER   DEFAULT NULL,
                    concat_ids          OUT nocopy VARCHAR2,
                    error_msg           OUT nocopy VARCHAR2)
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
FUNCTION segment_delimiter RETURN VARCHAR2;
FUNCTION concatenated_values RETURN VARCHAR2;
FUNCTION concatenated_ids RETURN VARCHAR2;
FUNCTION concatenated_descriptions RETURN VARCHAR2;
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

END fnd_flex_descval;

/
