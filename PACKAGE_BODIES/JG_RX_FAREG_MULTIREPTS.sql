--------------------------------------------------------
--  DDL for Package Body JG_RX_FAREG_MULTIREPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_RX_FAREG_MULTIREPTS" AS
/* $Header: jgrxfrmb.pls 115.5 2002/11/18 14:16:58 arimai ship $ */

PROCEDURE get_format(errbuf    OUT NOCOPY VARCHAR2,
                                retcode   OUT NOCOPY NUMBER,
                                p_asset_concurr_name  VARCHAR2,
                                p_asset_report_id     NUMBER,
                                p_asset_attribute_set VARCHAR2,
                                p_rtmnt_concurr_name  VARCHAR2,
                                p_rtmnt_report_id     NUMBER,
                                p_rtmnt_attribute_set VARCHAR2,
                                p_book                VARCHAR2,
                                p_from_period         VARCHAR2,
                                p_to_period           VARCHAR2,
                                p_dummy               NUMBER,
                                p_major_category      VARCHAR2,
                                p_minor_category      VARCHAR2,
                                p_debug_flag          VARCHAR2,
                                p_sql_trace           VARCHAR2)
 IS

 req_data                   VARCHAR2(10);
 r                          NUMBER;
 i                          NUMBER := 0;
 this_request_id            NUMBER;
 report_complex_flag        VARCHAR2(1);
 X_asset_report_id          NUMBER;
 X_rtmnt_report_id          NUMBER;

BEGIN
   --
   -- Read the value from REQUEST_DATA.  IF this is the
   -- first run of the program, THEN this value will be null.
   -- OtherwISe, this will be the value that we passed to
   -- SET_REQ_GLOBALS on the previous run.
   --
   req_data := FND_CONC_GLOBAL.request_data;
   IF (req_data IS NOT NULL) THEN
       errbuf := 'Done!';
       retcode := 0 ;
       return;
   END IF;

   this_request_id := FND_GLOBAL.conc_request_id;
   report_complex_flag := 'N';



   --
   -- Submit the child request.  The sub_request parameter
   -- must be set to 'Y'.
   --

   -- ***********************************************************
   -- First section ASSET


   -- Find report_id for asset
      SELECT R.report_id
        INTO X_asset_report_id
        FROM fnd_concurrent_programs c,
             fnd_application         a,
             fa_rx_reports           r
       WHERE c.application_id = a.application_id
         AND a.application_short_name ='JG'
	 AND c.concurrent_program_name=p_asset_concurr_name
	 AND c.application_id = r.application_id
	 AND r.concurrent_program_id = c.concurrent_program_id;


   i := i + 1;
   r := FND_REQUEST.submit_request(
                                   'JG',
                                   'RXJGFAAX',
                                   'Multiformat ' || to_char(i),
                                   NULL,
                                   TRUE,
                                   p_book                ,
                                   p_from_period         ,
                                   p_to_period           ,
                                   p_dummy               ,
                                   p_major_category      ,
                                   p_minor_category      ,
                                   'ASSET'               ,
                                   p_debug_flag          ,
                                   p_sql_trace
                                  );

   IF r = 0 THEN
     --
     -- If request submission failed, exit with error.
     --
     errbuf  := FND_MESSAGE.get;
     retcode := 2;
     RETURN;
   END IF;

   INSERT INTO fa_rx_multiformat_reps (
                                       request_id,
                                       sub_request_id,
                                       sub_attribute_set,
                                       sub_report_id,
                                       seq_number,
                                       complex_flag,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by
                                      )
   VALUES (
           this_request_id,
           r,
           p_asset_attribute_set,
           X_asset_report_id,
           i,
           report_complex_flag,
           sysdate,
           1,
           sysdate,
           1
          );


   -- ***********************************************************
   -- Second section RETIREMENT
   -- Find report_id for Retirement

      SELECT R.report_id
        INTO X_rtmnt_report_id
        FROM fnd_concurrent_programs c,
             fnd_application         a,
             fa_rx_reports           r
       WHERE c.application_id = a.application_id
         AND a.application_short_name ='JG'
	 AND c.concurrent_program_name=p_rtmnt_concurr_name
	 AND c.application_id = r.application_id
	 AND r.concurrent_program_id = c.concurrent_program_id;

   i := i + 1;
   r := FND_REQUEST.submit_request(
                                   'JG',
                                   'RXJGFARX',
                                   'Multiformat ' || to_char(i),
                                   NULL,
                                   TRUE,
                                   p_book                ,
                                   p_from_period         ,
                                   p_to_period           ,
                                   p_dummy               ,
                                   p_major_category      ,
                                   p_minor_category      ,
                                   'RTRMNT'              ,
                                   p_debug_flag          ,
                                   p_sql_trace
                                  );

   IF r = 0 THEN
     --
     -- If request submission failed, exit with error.
     --
     errbuf  := FND_MESSAGE.get;
     retcode := 2;
     RETURN;
   END IF;


   INSERT INTO fa_rx_multiformat_reps (
                                       request_id,
                                       sub_request_id,
                                       sub_attribute_set,
                                       sub_report_id,
                                       seq_number,
                                       complex_flag,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by
                                      )
   VALUES (
           this_request_id,
           r,
           p_rtmnt_attribute_set,
           X_rtmnt_report_id,
           i,
           report_complex_flag,
           sysdate,
           1,
           sysdate,
           1
          );

   --
   -- Here we set the globals to put the program into the
   -- PAUSED status on exit, and to save the state in
   -- request_data.
   --
   FND_CONC_GLOBAL.set_req_globals(conc_status  => 'PAUSED',
                                   request_data => to_char(i)) ;
   errbuf := 'Sub-Request submitted!';
   retcode := 0 ;

   RETURN;

END get_format;

END JG_RX_FAREG_MULTIREPTS;

/
