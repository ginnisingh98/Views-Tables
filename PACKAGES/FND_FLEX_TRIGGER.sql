--------------------------------------------------------
--  DDL for Package FND_FLEX_TRIGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_TRIGGER" AUTHID CURRENT_USER AS
/* $Header: AFFFSV3S.pls 120.1.12010000.1 2008/07/25 14:14:31 appldev ship $ */


  --------
  -- PRIVATE TYPES
  --
  --

  ------------
  -- PRIVATE CONSTANTS
  --

  -------------
  -- EXCEPTIONS
  --


  -------------
  -- GLOBAL VARIABLES
  --

/* ----------------------------------------------------------------------- */
/*	The following functions are called only from triggers on           */
/*	FND_FLEX_VALIDATION_RULES and FND_FLEX_VALIDATION_RULE_LINES.      */
/*	The trigger should use FND_MESSAGE.raise_exception if any of       */
/*	these functions returns error.					   */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*      Updates the FND_FLEX_VALIDATION_RULE_STATS table with the number   */
/*	of new rules, new include rule lines and new exclude rule lines    */
/*	for the given flexfield structure.  Creates a new row in the       */
/*	rule stats table if there isn't already one there for this         */
/*	structure.  Can input negative numbers to mean rules or lines      */
/*	were deleted.  If anything deleted limits counts in rule stats     */
/*	table to >= 0.  Does not delete rows from the rule stats table.    */
/*	Also sets the last update date to sysdate whenever it is called    */
/*	even if there were no new rules or lines.  This is so that the     */
/*	last update for each flex structure can be set when a rule or line */
/*	is updated.  This is useful for keeping track of when to outdate   */
/*	entries in the cross-validation rules cache. 			   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION update_cvr_stats(appid         IN  NUMBER,
			    flex_code     IN  VARCHAR2,
			    flex_num      IN  NUMBER,
			    n_new_rules   IN  NUMBER,
			    n_new_incls   IN  NUMBER,
			    n_new_excls   IN  NUMBER) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*      Inserts separated segments of new rule line into  		   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table.					   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION insert_rule_line(ruleline_id  IN  NUMBER,
			appid 	      IN  NUMBER,
			flex_code     IN  VARCHAR2,
			flex_num      IN  NUMBER,
			rule_name     IN  VARCHAR2,
			incl_excl     IN  VARCHAR2,
			enab_flag     IN  VARCHAR2,
			create_by     IN  NUMBER,
			create_date   IN  DATE,
			update_date   IN  DATE,
			update_by     IN  NUMBER,
			update_login  IN  NUMBER,
			catsegs_low   IN  VARCHAR2,
			catsegs_high  IN  VARCHAR2) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*      Updates rule line specified by ruleline_id in either		   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table.					   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION update_rule_line(ruleline_id  IN  NUMBER,
			appid 	      IN  NUMBER,
			flex_code     IN  VARCHAR2,
			flex_num      IN  NUMBER,
			rule_name     IN  VARCHAR2,
			incl_excl     IN  VARCHAR2,
			enab_flag     IN  VARCHAR2,
			create_by     IN  NUMBER,
			create_date   IN  DATE,
			update_date   IN  DATE,
			update_by     IN  NUMBER,
			update_login  IN  NUMBER,
			catsegs_low   IN  VARCHAR2,
			catsegs_high  IN  VARCHAR2) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*      Deletes rule line by rule_line_id from either			   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table.					   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION delete_rule_line(ruleline_id IN  NUMBER,
			    appid       IN  NUMBER,
		 	    flex_code   IN  VARCHAR2,
			    flex_num    IN  NUMBER,
			    incl_excl   IN  VARCHAR2) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */

END fnd_flex_trigger;

/
