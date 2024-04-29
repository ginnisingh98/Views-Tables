--------------------------------------------------------
--  DDL for Package HXT_CLOCK_USER_EDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_CLOCK_USER_EDITS" AUTHID CURRENT_USER AS
/* $Header: hxtclked.pkh 120.0 2005/05/29 06:01:36 appldev noship $ */

FUNCTION get_person_id(i_employee_number IN VARCHAR2,
                       i_business_group_id IN NUMBER,
                       i_date_worked IN DATE,
                       o_person_id OUT NOCOPY NUMBER,
                       o_last_name OUT NOCOPY VARCHAR2,
		       o_first_name OUT NOCOPY VARCHAR2)RETURN NUMBER;

FUNCTION determine_pay_date( i_start_time IN DATE,
			     i_end_time IN DATE,
                             i_person_id IN NUMBER,
                             o_date_worked OUT NOCOPY DATE) RETURN NUMBER;
------------------------------------------------------------------
END HXT_CLOCK_USER_EDITS;

 

/
