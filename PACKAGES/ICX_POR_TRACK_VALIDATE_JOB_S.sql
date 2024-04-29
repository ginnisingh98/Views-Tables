--------------------------------------------------------
--  DDL for Package ICX_POR_TRACK_VALIDATE_JOB_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_TRACK_VALIDATE_JOB_S" AUTHID CURRENT_USER as
/* $Header: ICXVALJS.pls 115.5 2004/03/31 21:43:38 vkartik ship $ */


procedure update_job_status(p_jobno in number,
                            p_new_status in varchar2,
                            p_loaded_items in number,
                            p_failed_items in number,
                  			    p_loaded_price in number,
			                      p_failed_price in number,
                            p_loaded_header in number,
                            p_failed_header in number,
                            p_user_id IN NUMBER);


FUNCTION create_job(p_supplier_id IN NUMBER,
                    p_supplier_file IN VARCHAR2,
                    p_exchange_file IN VARCHAR2,
                    p_host_ip_address IN VARCHAR2,
                    p_exchange_operator_id IN NUMBER,
                    p_job_type IN VARCHAR2,
                    p_max_failed_lines IN NUMBER) RETURN NUMBER;


FUNCTION delete_job(p_jobno in number) RETURN VARCHAR2;

PROCEDURE set_debug_channel(p_debug_channel number default 0) ;
PROCEDURE init_fnd_debug(p_request_id number);

/* Procedure to insert the log messages into fnd_log_messages table */
PROCEDURE log(p_debug_message VARCHAR2,
              p_log_type VARCHAR2 DEFAULT 'LOADER' ) ;

/* This will be set to TRUE when the DEBUG_CHANNEL is ON in the
Loader configuration file. This will be set only at the time of
starting up the loader */
g_debug_channel   BOOLEAN       := FALSE;
g_request_id      NUMBER        := null;
g_module_name     VARCHAR2(50)  := 'ICX.PLSQL.LOADER.';

end icx_por_track_validate_job_s;

 

/
