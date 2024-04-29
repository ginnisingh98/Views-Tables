--------------------------------------------------------
--  DDL for Package ITG_OUTBOUND_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_OUTBOUND_UTILS" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgoutus.pls 115.2 2002/12/19 02:08:09 ecoe noship $
 * CVS:  itgoutus.pls,v 1.9 2002/12/19 02:00:36 ecoe Exp
 */

  /* Create a parameter list (array).
   * Args:
   *	p_bsr		The BSR VERB_NOUN string, with no revision number.
   *                    For example: 'SYNC_PO'.
   *    P_id		The id of the DB table/view row for this document.
   *    p_org           The org id of this document (unless NULL).
   *    p_param1-4      Additional optional parameters; transaction-specific.
   */
  FUNCTION get_parameter_list(
    p_bsr    IN            VARCHAR2,
    p_id     IN            NUMBER,
    p_org    IN            NUMBER,
    p_doctyp IN		   VARCHAR2,
    p_clntyp IN		   VARCHAR2,
    p_doc    IN		   VARCHAR2 := NULL,
    p_rel    IN		   VARCHAR2 := NULL,
    p_param1 IN            VARCHAR2 := NULL,
    p_param2 IN            VARCHAR2 := NULL,
    p_param3 IN            VARCHAR2 := NULL,
    p_param4 IN            VARCHAR2 := NULL
  ) RETURN wf_parameter_list_t;

  /* Change args in list object if not NULL.  Set list object item to NULL
   * if VARCHAR2 args are ' ' (a single space) or NUMBER args are -1.
   */
  PROCEDURE change_parameter_list(
    p_list   IN OUT NOCOPY wf_parameter_list_t,
    p_bsr    IN            VARCHAR2 := NULL,
    p_id     IN            NUMBER   := NULL,
    p_org    IN            NUMBER   := NULL,
    p_doctyp IN            VARCHAR2 := NULL,
    p_clntyp IN            VARCHAR2 := NULL,
    p_doc    IN            VARCHAR2 := NULL,
    p_rel    IN            VARCHAR2 := NULL,
    p_param1 IN            VARCHAR2 := NULL,
    p_param2 IN            VARCHAR2 := NULL,
    p_param3 IN            VARCHAR2 := NULL,
    p_param4 IN            VARCHAR2 := NULL
  );

  /* Raise a WF event with our event name and key and the given p_params */
  PROCEDURE raise_wf_event_params(
    p_params IN            wf_parameter_list_t
  );

  /* Combine everything in a single convient function. */
  PROCEDURE raise_wf_event(
    p_bsr    IN            VARCHAR2,
    p_id     IN            NUMBER,
    p_org    IN            NUMBER,
    p_doctyp IN		   VARCHAR2,
    p_clntyp IN		   VARCHAR2,
    p_doc    IN            VARCHAR2 := NULL,
    p_rel    IN            VARCHAR2 := NULL,
    p_param1 IN            VARCHAR2 := NULL,
    p_param2 IN            VARCHAR2 := NULL,
    p_param3 IN            VARCHAR2 := NULL,
    p_param4 IN            VARCHAR2 := NULL
  );

END itg_outbound_utils;

 

/
