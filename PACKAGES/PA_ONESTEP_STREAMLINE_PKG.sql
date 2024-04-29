--------------------------------------------------------
--  DDL for Package PA_ONESTEP_STREAMLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ONESTEP_STREAMLINE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAOSTRMS.pls 120.2.12000000.3 2007/12/07 08:48:25 rdegala ship $ */

  TYPE strm_request_id_type IS RECORD
     ( request_id NUMBER,
       lookup_code VARCHAR2(30),
       u_phase VARCHAR2(80),
       u_status VARCHAR2(80),
       phase VARCHAR2(80),
       status VARCHAR2(80),
       fired VARCHAR2(2),
       sob_type VARCHAR2(2),
       sob_id NUMBER
     );
  TYPE strm_request_id_table IS TABLE OF strm_request_id_type
    INDEX BY binary_integer;
  -- For phase column:                        For status column:
  -- COMPLETE                                 NORMAL
  --                                          ERROR
  --                                          WARNING
  --                                          CANCELLED
  --                                          TERMINATED
  TYPE sob_err_id_type IS RECORD
    ( sob_name varchar2(30) );
  TYPE sob_err_table IS TABLE OF sob_err_id_type
    INDEX BY binary_integer;

  /* added global variables for print options cascading bug 2816916 */

  l_request_id          fnd_concurrent_requests.request_id%TYPE;
  l_number_of_copies    fnd_concurrent_requests.number_of_copies%TYPE;
  l_print_style         fnd_concurrent_requests.print_style%TYPE;
  l_printer             fnd_concurrent_requests.printer%TYPE;
  l_save_output_flag    fnd_concurrent_requests.save_output_flag%TYPE;

  l_result_print        boolean;
  l_save_op_flag_bool   boolean;

  l_print_no            NUMBER;
/*end adding variables for bug 2816916*/

  PROCEDURE PAOSTRM( errbuf OUT NOCOPY VARCHAR2,
		             retcode OUT NOCOPY VARCHAR2,
		             debug_mode IN VARCHAR2,
		             strm_opt IN VARCHAR2,
			     acct_date IN VARCHAR2);
  /* Added acct_date for bug 6655250*/
  g_debug_mode VARCHAR2(2);

END PA_ONESTEP_STREAMLINE_PKG;

/
