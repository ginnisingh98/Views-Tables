--------------------------------------------------------
--  DDL for Package PYWSPAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYWSPAS" AUTHID CURRENT_USER as
/* $Header: pywspas1.pkh 115.0 99/07/17 06:50:48 porting ship $ */
  procedure get_date_limits (p_assignment_id		number,
			     p_earliest_date	IN OUT	date,
			     p_latest_date	IN OUT	date);

end pywspas;

 

/
