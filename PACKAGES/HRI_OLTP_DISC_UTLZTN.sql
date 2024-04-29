--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_UTLZTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_UTLZTN" AUTHID CURRENT_USER AS
/* $Header: hriodutl.pkh 115.2 2003/01/24 10:06:48 jtitmas noship $ */

FUNCTION convert_entry_to_hours( p_assignment_id       IN NUMBER,
                                 p_business_group_id   IN NUMBER,
                                 p_screen_value        IN VARCHAR2,
                                 p_uom                 IN VARCHAR2,
                                 p_effective_date      IN DATE)
            RETURN NUMBER;

FUNCTION calc_hours_worked_from_formula
                             (p_formula_name        IN VARCHAR2,
                              p_assignment_id       IN NUMBER,
                              p_business_group_id   IN NUMBER,
                              p_effective_date      IN DATE)
             RETURN NUMBER;

END hri_oltp_disc_utlztn;

 

/
