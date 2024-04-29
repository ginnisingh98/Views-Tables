--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_TIME" AUTHID CURRENT_USER AS
/* $Header: hriodtim.pkh 115.1 2003/12/08 07:11:16 knarula noship $ */
--
/**************************************************************************
Description   : For a given date, this function finds the start date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_start_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : It returns the start date for the period
Post Failure  : Returns p_start_date being sent as input
***************************************************************************/
FUNCTION get_period_start_date(p_start_date	IN DATE,
			       p_period		IN VARCHAR2) RETURN DATE;
--
/**************************************************************************
Description   : For a given date, this function finds the end date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_end_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : It returns the end date for the period
Post Failure  : Returns p_end_date being sent as input
***************************************************************************/
FUNCTION get_period_end_date(p_end_date		IN DATE,
			     p_period		IN VARCHAR2) RETURN DATE;
--
END hri_oltp_disc_time;

 

/
