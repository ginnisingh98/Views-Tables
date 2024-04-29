--------------------------------------------------------
--  DDL for Package Body GML_POCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_POCR" AS
/* $Header: GMLPOCRB.pls 115.4 1999/12/02 10:17:07 pkm ship   $ */
PROCEDURE gmlpocr(errbufx  OUT VARCHAR2, retcode OUT VARCHAR2) IS


flag number := 0;

  err_num                 NUMBER;
  err_msg                 VARCHAR2(100);
  errbuf                  VARCHAR2(100);
  v_request_id            number;
  r_retcode               number;
  s_retcode               number;
  b_retcode               number;
  validation_error        EXCEPTION;
  dist_flag               varchar2(1) := 'N';

  CURSOR DIST_CUR IS
  SELECT 'Y'
  FROM   all_db_links
  WHERE  db_link='GEMMS_DB.WORLD';

BEGIN

 --FND_FILE.PUT_NAMES('testx.log','testx.out','/tmp');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Common Purchasing Error Log File');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Common Purchasing Output File');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Date : '|| to_char(sysdate,'DD-MON-YYYY hh24:mi:ss'));
   FND_FILE.NEW_LINE(FND_FILE.LOG, 2);


  /* Call the Blanket PO Synchronization Routine */

   gml_synch_bpos.cpg_bint2gms( b_retcode );

  /* Call the Standard PO Synchronization Routine */

  gml_po_synch.cpg_int2gms( s_retcode);

  /* Call the Receipt Synronization Routine */

  /*
  gml_po_recv.cpg_recvmv(r_retcode );

  */


  IF ((b_retcode = 1) OR (s_retcode = 1) OR (r_retcode=1)) THEN
    fnd_profile.put('b_retcode=',b_retcode);
    fnd_profile.put('s_retcode=',s_retcode);
    /*
    fnd_profile.put('r_retcode=',r_retcode);
    */

    retcode := 1;
    IF b_retcode = 1 THEN
	errbufx := 'gml_synch_bpos.cpg_bint2gms returned 1';
    END IF;
    IF s_retcode = 1 THEN
	errbufx  := 'gml_po_synch.cpg_int2gms returned 1';
    END IF;
    /*
    IF r_retcode = 1 THEN
	errbufx := 'cpg_po_recv.cpg_recvmv returned 1';
    END IF;
    */
    RAISE validation_error;
  END IF;

  -- This Procedure Will only be Called under Distributed Instance Scenario
  -- Make sure the following parameters are set to ensure SNP background
  -- processes are available.
  -- JOB_QUEUE_PROCESSES = 1 (must have a least on SNP backgrond process)
  -- JOB_QUEUE_INTERVAL = 60 (default)

  OPEN DIST_CUR;
  FETCH DIST_CUR INTO dist_flag;
  IF (dist_flag = 'Y') THEN
     gml_dummy.cpg_oragems_mapping_refresh;
  END IF;
  CLOSE DIST_CUR;

exception
   when utl_FILE.INVALID_PATH THEN
--       dbms_output.put_line('Invalid Path....');
       errbufx := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
   when utl_FILE.INVALID_MODE THEN
--       dbms_output.put_line('Invalid Mode ....');
       errbufx := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
   when utl_file.invalid_filehandle then
        errbufx := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;

   when utl_FILE.INVALID_OPERATION THEN
--       dbms_output.put_line('Invalid Operation....');
       errbufx := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
   when utl_file.write_error then
       errbufx := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;

   when validation_error then
--       dbms_output.put_line('Validation Errors Detected....');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Validation Errors Detected...');
       errbufx := 'Validation error - '||to_char(SQLCODE) || ' ' || SQLERRM;
       flag := 1;

   when others then
       err_num := SQLCODE;
       err_msg := SQLERRM(err_num);
--       dbms_output.put_line( ' In others');
--       dbms_output.put_line('Unhandled Exception....');
--       dbms_output.put_line(err_num || ' ' || err_msg);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Validation Errors Detected...');
       FND_FILE.PUT_LINE(FND_FILE.LOG, err_msg);
       errbufx := to_char(SQLCODE) || ' ' || SQLERRM;

       raise;
/*
DECLARE
 validation_error    EXCEPTION;
BEGIN
  IF flag = 1
  THEN
    RAISE validation_error;
  END IF;

EXCEPTION
  WHEN validation_error THEN
    RAISE;
  WHEN others THEN
    RAISE;
END;
*/
END GMLPOCR;/* procedure GMLPOCR */

END GML_POCR; /* package */

/
