--------------------------------------------------------
--  DDL for Package PQH_EMPLOYMENT_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_EMPLOYMENT_CATEGORY" AUTHID CURRENT_USER AS
/* $Header: pqhuseeo.pkh 115.6 2003/01/17 15:27:24 kgowripe noship $*/
--
--
PROCEDURE fetch_empl_categories (
	p_business_group_id	 in number,
	p_full_time_regular out nocopy varchar2,
	p_full_time_temp    out nocopy varchar2,
	p_part_time_regular out nocopy varchar2,
	p_part_time_temp    out nocopy varchar2 );
--
--
FUNCTION  identify_empl_category (
	p_empl_category		in varchar2,
	p_full_time_regular	in varchar2,
	p_full_time_temp   	in varchar2,
	p_part_time_regular	in varchar2,
	p_part_time_temp   	in varchar2)RETURN varchar2;
--
-- function for returning the equivalent no. of months given a duration
FUNCTION get_duration_in_months(
          p_duration    IN NUMBER,
          p_duration_units IN VARCHAR2,
          p_business_group_id IN NUMBER,
          p_ref_date    IN date DEFAULT sysdate) RETURN NUMBER;
--
FUNCTION   get_service_start_date (p_period_of_service_id IN NUMBER) RETURN DATE;
--
END pqh_employment_category;

 

/
