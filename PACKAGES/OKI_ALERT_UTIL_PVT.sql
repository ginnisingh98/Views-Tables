--------------------------------------------------------
--  DDL for Package OKI_ALERT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_ALERT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRAUTS.pls 115.9 2002/07/12 01:16:13 rpotnuru noship $*/
/*---------------------------------------------------------------------------+
|                                                                            |
|  PACKAGE: OKI_ALERT_UTIL_PVT                                               |
|  DESC   : Private interface for OKI ALERT UTILITIES Packag
|  FILE   : OKIRAUTS.pls                                                     |
|                                                                            |
*-------------------------------------------------------------------------- */
--------------------------------------------------------------------------------
--
--  Modification History
--  03-DEC-2001 brrao    created
--  29-JAN-2001 mezra    Added get_gv_prev_x_qtr_end_date and dflt_gv_qed for
--                       functions for the oki_expiration_graph graph component
--                       for the bins.
--  04-FEB-2002 mezra    Change get_gv_prev_x_qtr_end_date and dflt_gv_qed
--                       function to remove hard coded 'DD-MON-YY format
--                       mask.
--  30-APR-2002 mezra    Added dbdrv command and correct header syntax.
--
--------------------------------------------------------------------------------

   g_output_stream             UTL_FILE.FILE_TYPE;
   g_alert_dist_list           VARCHAR2(1000);
   g_alert_publish_dir         VARCHAR2(1000);
   g_utl_file_dest             VARCHAR2(1000);
   g_oki_alert_url             VARCHAR2(1000);
   g_oki_parent_url            VARCHAR2(1000);

   VERSION         CONSTANT NUMBER := 1.0;

   PROCEDURE Send_email (ERRBUF              OUT VARCHAR2,
                         RETCODE             OUT NUMBER,
                         subject 	     IN   VARCHAR2,
	                 body 	             IN   VARCHAR2,
                         email_list          IN   VARCHAR2 );

   PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit	        IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	        IN	VARCHAR2 := FND_API.g_false,
                        email_list 		IN   VARCHAR2,
                        subject 	        IN   VARCHAR2,
	        	body 			IN   VARCHAR2,
                        return_status           OUT  VARCHAR2,
                	x_msg_count		OUT	NUMBER,
                	x_msg_data		OUT	VARCHAR2
			);

   procedure myprint(p_str IN VARCHAR2);

   FUNCTION set_output_stream(p_file_name IN VARCHAR2) RETURN BOOLEAN;
       -- 1. Success
       -- 0. Failure
   PROCEDURE end_output_stream;

   procedure reportHeaderCell(p_str IN VARCHAR2, p_ref in VARCHAR2);
   procedure populateCell(p_str IN VARCHAR2,
                          p_align IN VARCHAR2,
                          p_link IN VARCHAR2,
                          p_class in VARCHAR2,
                          p_width in VARCHAR2);
   procedure create_page( p_title IN varchar2);
   procedure create_mainheader( p_title IN varchar2, p_run_date IN DATE);
   procedure start_row;
   procedure end_row;
   procedure create_crumb( p_title IN varchar2,
			   p_link IN VARCHAR2,
			   flag in VARCHAR2);
   procedure end_table(p_run_date IN DATE );
   procedure spaceCell(p_space in VARCHAR2,p_str IN VARCHAR2,
		       p_align IN VARCHAR2, p_link IN VARCHAR2,
		       p_class in VARCHAR2, p_width in VARCHAR2);
   procedure start_table( p_align IN varchar2 default 'L',
			  p_cellpadding IN NUMBER default 0,
			  p_bdr in NUMBER default 0);
   procedure print_error(p_string IN VARCHAR2);

  -- This function returns the quarter end date.  It takes the quarter and year
  -- as the starting date and uses the number of quarters parameter to determine
  -- the number of quarters to go back and determine the quarter start date.
  FUNCTION get_gv_prev_x_qtr_end_date
  (  p_qtr_end_date   IN DATE   DEFAULT NULL
   , p_number_of_qtrs IN NUMBER DEFAULT NULL
  ) RETURN DATE ;

/* Commented by Ravi on 02-11-2002
  -- This function defaults the current quarter start date.
  FUNCTION dflt_gv_qed
  (  p_name IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 ;
*/

END ; -- Package Specification OKI_ALERT_UTIL_PVT

 

/
