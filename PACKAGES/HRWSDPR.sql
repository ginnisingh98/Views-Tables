--------------------------------------------------------
--  DDL for Package HRWSDPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRWSDPR" AUTHID CURRENT_USER as
/* $Header: pywsdpr1.pkh 115.0 99/07/17 06:50:33 porting ship $ */
  procedure get_period_for_date (p_payroll_id		number,
				 p_given_date		date,
				 p_period	IN OUT	varchar2,
				 p_start_date	IN OUT	date,
				 p_end_date	IN OUT	date,
				 p_session_date		date);
end hrwsdpr;

 

/
