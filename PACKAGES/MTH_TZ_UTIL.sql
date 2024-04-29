--------------------------------------------------------
--  DDL for Package MTH_TZ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_TZ_UTIL" AUTHID CURRENT_USER AS
/*$Header: mthtzuts.pls 120.0.12010000.6 2009/08/21 09:49:48 sdonthu noship $*/

/* ****************************************************************************
* Function		: convert_tz                                          *
* Description 	 	: This function is used to return date by passed Date,*
*                         Source, and Target time zone name                   *
* File Name	 	: MTHTZUTS.PLS		             		      *
* Visibility		: Public               				      *
* Parameters	 	: date, from_tz, to _tz                               *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Tawen Kan       01-Mar-2008	Initial Creation      *
**************************************************************************** */
Function convert_tz(date_time date
                    ,from_tz varchar2
                    ,to_tz varchar2) return date;

/* ****************************************************************************
* Function		: FROM_TZ                                             *
* Description 		: This function is used to return date by passed      *
*                         Source time zone name                               *
* File Name	 	: MTHTZUTS.PLS       		             	      *
* Visibility		: Public                			      *
* Parameters	 	: date, from_tz                                       *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Tawen Kan       01-Mar-2008	Initial Creation      *
**************************************************************************** */
Function from_tz(date_time date
                 ,from_tz varchar2) return date;

/* ****************************************************************************
* Function		: TO_TZ                                               *
* Description 		: This function is used to return date by passed      *
*                         Target time zone name                               *
* File Name	 	: MTHTZUTS.PLS       		             	      *
* Visibility		: Public                			      *
* Parameters	 	: date, to_tz                                         *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Tawen Kan       01-Mar-2008	Initial Creation      *
**************************************************************************** */
Function to_tz(date_time date
               ,to_tz   varchar2) return date;

END MTH_TZ_UTIL;

/
