--------------------------------------------------------
--  DDL for Package MTH_ITEM_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_ITEM_DIMENSION_PKG" AUTHID CURRENT_USER AS
/*$Header: mthitems.pls 120.1.12010000.4 2009/08/21 09:49:09 sdonthu ship $ */


/* ****************************************************************************
* Procedure		:ITEM_DIM_LOAD_DENORM	          	              *
* Description 	 	:This procedure is used to populate the denorm table  *
*			 for the item dimension hierarchy		      *
* File Name	 	:MTHITEMDS.PLS              			      *
* Visibility		:Public                				      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	29-May--2007	Initial Creation      *
**************************************************************************** */


PROCEDURE ITEM_DIM_LOAD_DENORM ;


/* ****************************************************************************
* Procedure		:ITEM_DIM_LOAD_DENORM_INCR	          	      *
* Description 	 	:This procedure is used to incrementally populate the *
*                        denorm table for the item dimension hierarchy        *
* File Name	 	:MTHITEMDS.PLS              			      *
* Visibility		:Public                				      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Yong Feng	10-July-2008	Initial Creation      *
**************************************************************************** */

PROCEDURE ITEM_DIM_LOAD_DENORM_INCR;

/* ****************************************************************************
* Procedure		:ITEM_DIM_HRCHY_LEVEL_LOAD	      	              *
* Description 	 	:This procedure will populate the level information   *
*			for the item - category and category - category	      *
*			relatiopnships in the item hierarchy staging table    *
* File Name	 	:MTHITEMDS.PLS              		              *
* Visibility		:Public                     			      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	29-May--2007	Initial Creation      *
**************************************************************************** */



PROCEDURE ITEM_DIM_HRCHY_LEVEL_LOAD;


END MTH_ITEM_DIMENSION_PKG;

/
