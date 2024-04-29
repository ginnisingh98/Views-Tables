--------------------------------------------------------
--  DDL for Package FND_SOA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SOA_UTIL" AUTHID CURRENT_USER as
/* $Header: FNDSOAUS.pls 120.0.12010000.4 2010/05/18 06:45:41 dsardar ship $ */


/* This routine is used as a concurrent program.  */
/* Nobody besides the concurrent manager should call it. */
procedure delete_by_date_cp(   errbuf out NOCOPY varchar2,
                               retcode out NOCOPY varchar2,
                               start_date in  varchar2,
                               end_date in  varchar2 );

 /* Purge Function to delete all requests Data */
 FUNCTION delete_requests_by_date_range(
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

/* Purge Function to delete all ErrorData */
FUNCTION delete_error_by_date_range(
			x_start_date IN DATE,
			x_end_date IN DATE) return NUMBER;

/* Purge Function to delete all log messages */
FUNCTION delete_log_by_date_range(
			x_start_date IN DATE,
			x_end_date IN DATE) return NUMBER;

/* Purge Function to delete log messages for an Instance ID*/
FUNCTION delete_log_by_instance_id(
			x_instance_id IN NUMBER) return NUMBER;

end fnd_soa_util;

/
