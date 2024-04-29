--------------------------------------------------------
--  DDL for Package ENG_BIS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_BIS_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: engbisfs.pls 115.1 2002/02/06 19:15:51 skagarwa ship $ */

/*
 * GetWorkdaysBetween
 *
 *   This function calculates the number of mfg
 *   workdays between a start date and an end
 *   date for a particular organization.
 */
FUNCTION GetWorkdaysBetween(p_organization_id  NUMBER,
			    p_start_date       DATE,
	 		    p_end_date	       DATE)
RETURN number;


END ENG_BIS_FUNCTIONS;

 

/
