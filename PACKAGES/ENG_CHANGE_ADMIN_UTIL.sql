--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ADMIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ADMIN_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGADUTS.pls 115.3 2003/10/15 03:46:51 lkasturi ship $ */

/*-------------------------------------------------------------------------
    Name
        check_delete_for_reason

    Description

    Returns
        Number 1 or 2.
+--------------------------------------------------------------------------*/
FUNCTION check_delete_for_reason(
    p_reason_code   IN  VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (check_delete_for_reason, WNDS, WNPS);

/*-------------------------------------------------------------------------
    Name
        check_delete_for_priority

    Description

    Returns
        Number 1 or 2.
+--------------------------------------------------------------------------*/
FUNCTION check_delete_for_priority(
    p_priority_code   IN  VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (check_delete_for_priority, WNDS, WNPS);

/*-------------------------------------------------------------------------
    Name
        check_delete_for_status

    Description

    Returns
        Number 1 or 2.
+--------------------------------------------------------------------------*/
FUNCTION check_delete_for_status(
    p_status_code   IN  NUMBER
    ) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (check_delete_for_status, WNDS, WNPS);

/*-------------------------------------------------------------------------
    Name
        check_delete_for_phase

    Description

    Returns
        Number 1 or 2.
+--------------------------------------------------------------------------*/

FUNCTION check_delete_for_phase(
    p_status_code   IN  NUMBER,
    p_change_type_id IN NUMBER
    ) RETURN NUMBER;

/*-------------------------------------------------------------------------
    Name
        check_classifications_delete

    Description

    Returns
        Number 1 or 2.
+--------------------------------------------------------------------------*/
FUNCTION check_classifications_delete
 (
     p_classification_id  IN  NUMBER
    ) RETURN NUMBER;

END ENG_CHANGE_ADMIN_UTIL;

 

/
