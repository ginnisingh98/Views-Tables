--------------------------------------------------------
--  DDL for Package PSP_EXTERNAL_EFFORT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EXTERNAL_EFFORT_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPHREFS.pls 120.0 2006/02/02 14:23:09 sramacha noship $ */
/*
   The functions declared in this header are designed to be used
   by the Data Pump engine to resolve id values that have to be passed
   to the API modules.

*/
------------------------- get_external_effort_line_id -------------------
/* NAME
    get_external_effort_line_id
  DESCRIPTION
    Returns external effort line id
  NOTES
    This function returns an external effort line_id.  */

FUNCTION get_external_effort_line_id
( p_ext_effort_line_user_key   IN VARCHAR2
 ) RETURN NUMBER;
pragma restrict_references (get_external_effort_line_id,WNDS);

-------------------------- get_external_effort_ovn ---------------------
/* NAME
    get_external_effort_ovn
  DESCRIPTION
    Returns External Effort Line Object Version Number.
  DESCRIPTION
    Returns External Effort Object Version Number
  NOTES
    This function returns the Object Version Number */



FUNCTION get_external_effort_ovn
(
    p_ext_effort_line_user_key IN VARCHAR2
)
   RETURN NUMBER;
pragma restrict_references (get_external_effort_ovn,WNDS);

END psp_external_effort_lines_pkg;

 

/
