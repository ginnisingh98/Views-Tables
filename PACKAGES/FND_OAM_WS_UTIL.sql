--------------------------------------------------------
--  DDL for Package FND_OAM_WS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_WS_UTIL" AUTHID CURRENT_USER as
/* $Header: AFOAMWSUTILS.pls 120.1 2005/08/21 12:15:07 ssuprasa noship $ */


/* This routine is used as a concurrent program.  */
/* Nobody besides the concurrent manager should call it. */
procedure delete_by_date_cp(   errbuf out NOCOPY varchar2,
                               retcode out NOCOPY varchar2,
                               start_date in  varchar2,
                               end_date in  varchar2 );

 /* Purge Function to delete all requests Data */
 FUNCTION delete_requests_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER ;

 /* Purge Function to delete all response Data */
 FUNCTION delete_responses_by_date_range(
	   x_start_date IN DATE,
           x_end_date IN DATE) return NUMBER;

 /* Purge Function to delete all method Data */
 FUNCTION delete_method_by_date_range(
 	   x_start_date IN DATE,
           x_end_date IN DATE) return NUMBER;

 /* Purge Function to delete all attachment Data */
 FUNCTION delete_att_by_date_range(
	    	   x_start_date IN DATE,
           x_end_date IN DATE) return NUMBER;

  /* Purge Function to delete all attachment body Data */
 FUNCTION delete_body_by_date_range(
	    	   x_start_date IN DATE,
           x_end_date IN DATE) return NUMBER;
end fnd_oam_ws_util;

 

/
