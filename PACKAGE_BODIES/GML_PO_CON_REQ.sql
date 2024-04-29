--------------------------------------------------------
--  DDL for Package Body GML_PO_CON_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_CON_REQ" AS
/* $Header: GMLPORCB.pls 115.13 2002/12/04 23:30:45 uphadtar ship $ */

inserted_ind VARCHAR2(1) := NULL;

/*############################################################################
  #  PROC
  #    fire_request
  #
  #    GMLPORCO.pls           Concurrent Program for Synchronizing POs  RCPT.
  #
  #  DESCRIPTION
  #
  #    This Procedure fires the Concurrent Request to Synchronize the
  #    Purchase Orders (Standard and Planned), Releases from Oralce to GEMMS
  #    and Receipts from GEMMS to Oracle.
  #
  #    This Executable Fired with the FND_SUBMIT_REQUEST is a SQL File which
  #     opens the Common Purchasing Log File in the directory named in the
  #     init.ora and displays the log file in the Standard Concurent Manager
  #     request log.
  #
  #  MODIFICATION HISTORY
  #
  #     29-JAN-99 Tony Ricci
  #
  ########################################################################### */
  PROCEDURE fire_request IS

  v_request_id     NUMBER   ;
  dummy            BOOLEAN  ;

  v_call_status    BOOLEAN  ;
  v_request_phase  VARCHAR2(30) ;
  v_request_status VARCHAR2(30) ;
  v_dev_phase      VARCHAR2(30) ;
  v_dev_status     VARCHAR2(30) ;
  v_line           VARCHAR2(80) ;
  v_message        VARCHAR2(240);

  err_num          NUMBER;
  tmp_num          NUMBER;
  Err_Msg          VARCHAR2(100);

BEGIN

  dummy := fnd_request.set_mode(TRUE);


  v_call_status := fnd_concurrent.get_request_status
                   (v_request_id,
                    'GML',
                    'GMLPORCV',
                    v_request_phase,
                    v_request_status,
                    v_dev_phase,
                    v_dev_status,
                    v_message);

  /* Fire the Concurrent Request, Only if the Previous one is Completed. If,
     the program, fired earlier is Pending or Running State, do not start a
     fresh request, since the current request will pick up the current set of
     rows also from the Interface Table */

  IF ((v_dev_phase = 'PENDING') OR (v_dev_phase = 'RUNNING')) AND
     (v_dev_status = 'NORMAL') THEN
   	tmp_num := 1;
  ELSIF (v_dev_phase = 'INACTIVE' AND v_dev_status = 'NO_MANAGER') THEN
   	tmp_num := 2;
  ELSE

    v_request_id := fnd_request.submit_request(
                    'GML',                       /* Application name*/
                    'GMLPORCV',                 /* Program Name*/
                    'OPM Common Purchasing Synchronization', /*Description*/
                    '',                         /* Start Date*/
                     FALSE,                     /* Not called from another */
                                                /*  concurrent request*/
                     CHR(0), '', '','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','','',
                     '','','','','','','','','',''
                     );


    IF (v_request_id = 0) THEN

      fnd_message.set_name('FND', 'CONC-MENU-MANAGERS');
      fnd_message.set_token('Managers', 'Cannot Fire Concurrent Request...');
      app_exception.raise_exception;

    END IF; /* v_request_id = 0 */
  END IF;   /* v_request_id = 0 */

  EXCEPTION
    WHEN OTHERS THEN
      err_num := SQLCODE;
      Err_Msg := SUBSTRB(SQLERRM, 1, 100);
      RAISE_APPLICATION_ERROR(-20000, Err_Msg);
END fire_request;

/*===========================================================================
|                                                                           |
| PROCEDURE NAME        po_resub_insert                                     |
|                                                                           |
| DESCRIPTION		This private procedure will call procedure to       |
|                       insert rows in cpg_purchasing_interface table       |
|                                                                           |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                       Uday Phadtare new procedure created for Bug2048971. |
============================================================================*/
PROCEDURE po_resub_insert (v_po_header_id        IN NUMBER,
			   v_po_line_id          IN NUMBER,
			   v_po_line_location_id IN NUMBER,
			   v_po_release_id       IN NUMBER,
			   v_transaction_type    IN VARCHAR2) IS

  CURSOR get_failed_releases (v_po_header_id NUMBER, v_po_line_id NUMBER,
                              v_po_line_location_id NUMBER, v_po_release_id NUMBER) IS
  SELECT po_release_id, invalid_ind
  FROM   cpg_purchasing_interface
  WHERE  po_header_id 	     = v_po_header_id
  AND    po_line_id          = v_po_line_id
  AND    po_line_location_id = v_po_line_location_id
  AND	 po_release_id 	     = v_po_release_id
  AND    release_num         <> 0
  ORDER  BY transaction_id DESC;

  CURSOR get_failed_release_details (v_po_header_id NUMBER, v_release_id NUMBER)
  IS
  SELECT po_header_id, po_line_id, line_location_id, ship_to_location_id
  FROM   po_line_locations_all
  WHERE  po_header_id  = v_po_header_id
  AND    po_release_id = v_release_id
  ORDER BY po_header_id, po_line_id,line_location_id;


  CURSOR   shipping_details(v_po_header_id NUMBER) IS
  SELECT   po_header_id, po_line_id, line_location_id, ship_to_location_id
  FROM     po_line_locations_all
  WHERE    po_header_id = v_po_header_id
  AND      approved_flag ='Y'
  ORDER BY po_header_id, po_line_id, line_location_id;

  get_failed_releases_rec get_failed_releases%ROWTYPE;
  fetch_failed NUMBER := 0;
  err_num NUMBER;
  Err_Msg VARCHAR2(1000);

BEGIN

  IF v_transaction_type IN('STANDARD') THEN

      FOR shipping_details_rec IN shipping_details(v_po_header_id)
         LOOP
            Gml_Po_Interface.insert_rec( shipping_details_rec.po_header_id,
                      shipping_details_rec.po_line_id,
                      shipping_details_rec.line_location_id,
                      NULL,         NULL,       NULL,
                      NULL,         NULL,       NULL,
                      NULL,         NULL,       'N',
                      NULL, shipping_details_rec.ship_to_location_id, NULL);

	        inserted_ind := 'Y';
	 END LOOP;
  ELSE

     OPEN  get_failed_releases(v_po_header_id,v_po_line_id,v_po_line_location_id,v_po_release_id);
     FETCH get_failed_releases INTO get_failed_releases_rec;

     IF get_failed_releases%NOTFOUND THEN
	    fetch_failed := 1;
     END IF;

     CLOSE get_failed_releases;

     IF (fetch_failed = 1 OR get_failed_releases_rec.invalid_ind = 'Y') THEN
            FOR get_failed_release_details_rec IN get_failed_release_details(v_po_header_id, v_po_release_id)
            LOOP

               Gml_Po_Interface.insert_rec( get_failed_release_details_rec.po_header_id,
	              get_failed_release_details_rec.po_line_id,
	              get_failed_release_details_rec.line_location_id,
	              NULL,         NULL,       NULL,
	              NULL,         NULL,       NULL,
	              NULL,         NULL,       'N',
	              NULL, get_failed_release_details_rec.ship_to_location_id, NULL);

	        inserted_ind := 'Y';
		fetch_failed := 0;

            END LOOP;
     END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    Err_Msg := SUBSTRB(SQLERRM, 1, 1000);
    RAISE_APPLICATION_ERROR(-20099, Err_Msg);

END po_resub_insert;

/*===========================================================================
|                                                                           |
| PROCEDURE NAME        po_resub                                            |
|                                                                           |
| DESCRIPTION		Resubmission procedure which resubmits the set of   |
|                       PO's which fall BETWEEN the given dates OR OF PO    |
|                       NUMBER given                                        |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                                                                           |
|    30-JAN-99 Tony Ricci                                                   |
|                                                                           |
|    11/10/99 - BUG#:1030064 - Allow USER TO RUN report without making PO   |
|                      required.  Retrieve po_header_id AND COMMENT         |
|                      OUT converting from_date AND TO_DATE TO_DATE IN      |
|                      second LOOP.                                         |
|    15-NOV-2001 Bug#2048971 Uday Phadtare Entire procedure was rewritten   |
|                For standard PO whole PO will be synched again.       	    |
|                For Planned PO only failed releases will be synched.       |
|                For Blanket PO only failed releases will be synched.       |
|                PPO template does not get synched through po_resub. It has |
|                    to be exclusively synched through PO form.             |
============================================================================*/


PROCEDURE po_resub
(errbuf  OUT NOCOPY VARCHAR2,
 retcode OUT NOCOPY NUMBER,
 v_from_date IN OUT NOCOPY VARCHAR2,
 v_to_date IN OUT NOCOPY VARCHAR2,
 v_po_no IN VARCHAR2)
IS

  v_po_header_id     cpg_purchasing_interface.po_header_id%TYPE        := NULL;
  v_po_line_id       cpg_purchasing_interface.po_line_id%TYPE          := NULL;
  v_line_location_id cpg_purchasing_interface.po_line_location_id%TYPE := NULL;
  v_transaction_id   cpg_purchasing_interface.transaction_id%TYPE      := NULL;
  v_po_release_id    cpg_purchasing_interface.po_release_id%TYPE       := NULL;
  v_transaction_type cpg_purchasing_interface.transaction_type%TYPE    := NULL;

  CURSOR get_synch_failed_rows_DT (v_date_from DATE, v_date_to DATE) IS
  SELECT po_header_id,
    	 po_line_id,
  	 line_location_id,
	 po_release_id
  FROM   po_line_locations_all
  WHERE  (creation_date >= v_date_from AND creation_date < v_date_to + 1 )
  ORDER  BY po_header_id,po_release_id,po_line_id,line_location_id;

  CURSOR get_transaction_type(v_po_head_id NUMBER) IS
  SELECT type_lookup_code
  FROM	 po_headers_all
  WHERE	 po_header_id = v_po_head_id;

  CURSOR get_trans_type(v_po_no VARCHAR2) IS
  SELECT type_lookup_code, po_header_id
  FROM	 po_headers_all
  WHERE	 segment1 = v_po_no;

  CURSOR get_synch_failed_rows_PO (v_po_header_id  VARCHAR2) IS
  SELECT po_header_id,
    	 po_line_id,
  	 line_location_id,
	 po_release_id
  FROM   po_line_locations_all
  WHERE  po_header_id = v_po_header_id
  ORDER  BY po_header_id,po_release_id,po_line_id,line_location_id;

  get_synch_failed_rows_PO_rec get_synch_failed_rows_PO%ROWTYPE;
  get_trans_type_rec get_trans_type%ROWTYPE;
  err_num NUMBER;
  Err_Msg VARCHAR2(1000);
  date_format VARCHAR2(20) := 'DD-MON-YYYY';

BEGIN

  v_from_date := TO_CHAR(TO_DATE(v_from_date, date_format),date_format) ;
  v_to_date   := TO_CHAR(TO_DATE(v_to_date, date_format),date_format) ;

 IF (v_po_no IS NULL) THEN   /* po number is not given */

   FOR get_synch_failed_rows_DT_rec IN get_synch_failed_rows_DT(
        	    NVL(TO_DATE(v_from_date,date_format),TO_DATE('01-01-1970','DD-MM-YYYY')),
                    NVL(TO_DATE(v_to_date,date_format),SYSDATE))
   LOOP
     IF get_synch_failed_rows_DT_rec.po_release_id IS NULL THEN

    	 IF v_po_header_id IS NULL THEN

		   inserted_ind := 'N';
		   v_po_header_id    := get_synch_failed_rows_DT_rec.po_header_id;
		   v_po_line_id      := get_synch_failed_rows_DT_rec.po_line_id;
		   v_line_location_id:= get_synch_failed_rows_DT_rec.line_location_id;

		   OPEN  get_transaction_type(v_po_header_id);
		   FETCH get_transaction_type INTO v_transaction_type;
		   CLOSE get_transaction_type;

		   po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,NULL,v_transaction_type);

	 ELSE

		IF get_synch_failed_rows_DT_rec.po_header_id = v_po_header_id	AND inserted_ind = 'Y' THEN
			NULL;
		ELSE
			inserted_ind := 'N';
			v_po_header_id    := get_synch_failed_rows_DT_rec.po_header_id;
			v_po_line_id      := get_synch_failed_rows_DT_rec.po_line_id;
			v_line_location_id:= get_synch_failed_rows_DT_rec.line_location_id;

	           OPEN  get_transaction_type(v_po_header_id);
		   FETCH get_transaction_type INTO v_transaction_type;
		   CLOSE get_transaction_type;

		   po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,NULL,v_transaction_type);

                END IF;
         END IF;

     ELSE

         IF v_po_header_id IS NULL THEN
		inserted_ind := 'N';
		v_po_header_id    := get_synch_failed_rows_DT_rec.po_header_id;
		v_po_line_id      := get_synch_failed_rows_DT_rec.po_line_id;
		v_line_location_id:= get_synch_failed_rows_DT_rec.line_location_id;
		v_po_release_id	  := get_synch_failed_rows_DT_rec.po_release_id;

		OPEN  get_transaction_type(v_po_header_id);
		FETCH get_transaction_type INTO v_transaction_type;
		CLOSE get_transaction_type;

		po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,v_po_release_id,v_transaction_type);

	 ELSE
		IF  get_synch_failed_rows_DT_rec.po_header_id = v_po_header_id AND
			get_synch_failed_rows_DT_rec.po_release_id =  NVL(v_po_release_id,0)
			AND inserted_ind = 'Y' THEN
			NULL;
		ELSE
			inserted_ind := 'N';
			v_po_header_id    := get_synch_failed_rows_DT_rec.po_header_id;
			v_po_line_id      := get_synch_failed_rows_DT_rec.po_line_id;
			v_line_location_id:= get_synch_failed_rows_DT_rec.line_location_id;
			v_po_release_id	  := get_synch_failed_rows_DT_rec.po_release_id;

			OPEN  get_transaction_type(v_po_header_id);
			FETCH get_transaction_type INTO v_transaction_type;
			CLOSE get_transaction_type;

			po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,v_po_release_id,v_transaction_type);
                END IF;
         END IF;
      END IF;

   END LOOP;

 ELSE      /* po number is given */

     OPEN  get_trans_type(v_po_no);
     FETCH get_trans_type INTO get_trans_type_rec;
     CLOSE get_trans_type;

	IF get_trans_type_rec.type_lookup_code = 'STANDARD' THEN

	    OPEN  get_synch_failed_rows_PO(get_trans_type_rec.po_header_id);
            FETCH get_synch_failed_rows_PO INTO get_synch_failed_rows_PO_rec;
	    CLOSE get_synch_failed_rows_PO;

	    v_po_header_id    := get_synch_failed_rows_PO_rec.po_header_id;
	    v_po_line_id      := get_synch_failed_rows_PO_rec.po_line_id;
	    v_line_location_id:= get_synch_failed_rows_PO_rec.line_location_id;

            po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,NULL,get_trans_type_rec.type_lookup_code);

	ELSE

	     FOR get_synch_failed_rows_PO_rec IN get_synch_failed_rows_PO(get_trans_type_rec.po_header_id)

	     LOOP

	     	IF v_po_header_id IS NULL THEN

			inserted_ind := 'N';
			v_po_header_id    := get_synch_failed_rows_PO_rec.po_header_id;
			v_po_line_id      := get_synch_failed_rows_PO_rec.po_line_id;
			v_line_location_id:= get_synch_failed_rows_PO_rec.line_location_id;
			v_po_release_id	  := get_synch_failed_rows_PO_rec.po_release_id;

			po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,v_po_release_id,get_trans_type_rec.type_lookup_code);


		ELSE
			IF get_synch_failed_rows_PO_rec.po_header_id = v_po_header_id AND
			   get_synch_failed_rows_PO_rec.po_release_id =  NVL(v_po_release_id,0)
			   AND inserted_ind = 'Y' THEN
				NULL;
			ELSE
			   inserted_ind := 'N';
			   v_po_header_id     := get_synch_failed_rows_PO_rec.po_header_id;
			   v_po_line_id       := get_synch_failed_rows_PO_rec.po_line_id;
			   v_line_location_id := get_synch_failed_rows_PO_rec.line_location_id;
			   v_po_release_id    := get_synch_failed_rows_PO_rec.po_release_id;

			   po_resub_insert(v_po_header_id,v_po_line_id,v_line_location_id,v_po_release_id,get_trans_type_rec.type_lookup_code);

	                END IF;
	        END IF;

	     END LOOP;
	END IF;
  END IF;

  /* Fire the CPG Purchasing Synchronization Concurrent Request */
  GML_PO_CON_REQ.fire_request;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    Err_Msg := SUBSTRB(SQLERRM, 1, 1000);
    retcode:=1;
    RAISE_APPLICATION_ERROR(-20098, Err_Msg);

END po_resub;

/*==========================================================================
| PROCEDURE NAME        recv_resub                                         |
|                                                                          |
| DESCRIPTION	        Resubmission procedure which resubmits the         |
|                       receiving and returning information corresponding  |
|                       to the given PO.                                   |
|                                                                          |
| MODIFICATION HISTORY                                                     |
|                                                                          |
|   30-JAN-99  Tony Ricci                                                  |
===========================================================================*/

/* Notice: resubmission is contingent upon the correct status in the */
/* mapping table */
/*Preetam B Commented this out as it is no longer used.To solve the problems
of the invalid objects*/
/*
 PROCEDURE recv_resub
(errbuf  out NOCOPY varchar2,
 retcode out NOCOPY number,
 v_po_no IN VARCHAR2)
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);

  CURSOR line_cur IS
  SELECT po_id, line_id
  FROM   po_ordr_dtl
  WHERE  po_id = (SELECT po_id
                  FROM   po_ordr_hdr
                  WHERE  po_no = v_po_no)
  ORDER BY line_id;

BEGIN

    retcode :=0;
    FOR v_line IN line_cur LOOP
       gml_cpg_receiving_interface.store_id(v_line.po_id, v_line.line_id);
       IF gml_cpg_receiving_interface.check_mapping THEN
         gml_cpg_receiving_interface.sum_recv;
       END IF;
    END LOOP;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    retcode :=1;
    errbuf  := 'Error IN recv_resub';
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END recv_resub;
*/
END GML_PO_CON_REQ;

/
