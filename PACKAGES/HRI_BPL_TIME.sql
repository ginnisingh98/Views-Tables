--------------------------------------------------------
--  DDL for Package HRI_BPL_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_TIME" AUTHID CURRENT_USER AS
/* $Header: hribtime.pkh 115.1 2003/12/08 07:11:11 knarula noship $ */
--
/**************************************************************************
Description   : For a given date, this function finds the start date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_start_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : Returns the start date of the period
Post Failure  : Raise error no_data_found
***************************************************************************/
FUNCTION get_period_start_date(p_start_date 	    IN DATE,
			       p_period 	    IN VARCHAR2)
RETURN 	 DATE;
--
/**************************************************************************
Description   : For a given date, this function finds the end date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_end_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : Returns the end date fo the period
Post Failure  : Raise error no_data_found
***************************************************************************/
FUNCTION get_period_end_date  (p_end_date 	    IN  DATE,
		      	       p_period 	    IN VARCHAR2)
RETURN DATE;
--
END hri_bpl_time;

 

/
