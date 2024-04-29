--------------------------------------------------------
--  DDL for Package Body GML_REPROCESS_RCPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_REPROCESS_RCPTS" AS
/* $Header: GMLRRCTB.pls 120.1 2005/08/15 09:24:32 rakulkar noship $ */


/*========================================================================
|                                                                        |
| PROCEDURE NAME  update_records                                         |
|                                                                        |
| DESCRIPTION      Procedure to Update the PROCESSING_STATUS_CODE and 	 |
|		   TRANSACTION_STATUS_CODE in RCV_HEADERS_INTERFACE and	 |
|                  RCV_TRANSACTIONS_INTERFACE to PENDING and the 	 |
|		   VALIDATION_FLAG in both tables to 'Y' so that the   	 |
|		   receiving transaction processor will pick these     	 |
| 	   	   records up next time its run	    		         |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 12-OCT-00  	Preetam B -  Created.                                    |
| 							                 |
| 09-MAY-01 Uday Phadtare Bug1774591. Upadate po_revision_num
| 11-JUL-01 Uday Phadtare Procedure Update_Records modified as part of
|           Bug# 1878034 fix.
| 02-MAY-02 Uday Phadtare B2350663. Cursor Cr_get_rcpts modified so that records with
|           NULL header_interface_id are also processed.
| 24-JUL-02 Lakshmi Swamy B2462033. Included delete statements to po_interface_errors
|           so that multiple error messages for the same interface id are avoided.
| 12-AUG-02 Uday Phadtare B2470051. Update the status to 'PENDING' even if the
|           status is 'PRINT' in rcv_headers_interface and rcv_transactions_interface.
| 29-OCT-02 Uday Phadtare B2647879. Do not update the status to 'PENDING'
|           in rcv_headers_interface if the status is 'SUCCESS'.
=========================================================================*/

PROCEDURE Update_Records(errbufx OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2)
IS

  CURSOR  Cr_get_rcpts IS
  SELECT  h.header_interface_id hid,
          h.processing_status_code psc,
	  d.interface_transaction_id tid
  FROM	  rcv_headers_interface h, rcv_transactions_interface d
  WHERE   h.header_interface_id(+) = d.header_interface_id
  AND	  ( h.processing_Status_code IN('ERROR','PRINT') OR d.processing_Status_code IN('ERROR','PRINT')
	     OR d.transaction_status_code IN('ERROR','PRINT') )
  AND     d.comments LIKE 'OPM%';


BEGIN

	For Cr_get_rcpts_rec in Cr_get_rcpts
	Loop
	    IF Cr_get_rcpts_rec.hid IS NOT NULL THEN
	       IF Cr_get_rcpts_rec.psc <> 'SUCCESS' THEN
		  Update  RCV_HEADERS_INTERFACE
		  Set 	  PROCESSING_STATUS_CODE	= 'PENDING',
			  VALIDATION_FLAG		= 'Y'
		  Where	  HEADER_INTERFACE_ID 	= Cr_get_rcpts_rec.hid;
	       END IF;

                /* 2462033 - Included delete */

                DELETE  from po_interface_errors
                WHERE   interface_header_id = Cr_get_rcpts_rec.hid;

	    END IF;



		Update	RCV_TRANSACTIONS_INTERFACE RT
		Set 	PROCESSING_STATUS_CODE	= 'PENDING',
			TRANSACTION_STATUS_CODE = 'PENDING',
			VALIDATION_FLAG		= 'Y',
			PO_REVISION_NUM		= (select revision_num from po_headers_all where
						   po_header_id = rt.po_header_id)
		Where	INTERFACE_TRANSACTION_ID= Cr_get_rcpts_rec.tid;

                /* 2462033 - Included delete */
		DELETE  from po_interface_errors
                 WHERE   INTERFACE_TRANSACTION_ID= Cr_get_rcpts_rec.tid
                    OR   INTERFACE_LINE_ID = Cr_get_rcpts_rec.tid ;

	End Loop;

commit;

END;


/*========================================================================
|                                                                        |
| PROCEDURE NAME  reprocess_adjust_errors                                |
|                                                                        |
| DESCRIPTION      Procedure to Update the PROCESSING_STATUS_CODE and 	 |
|		   TRANSACTION_STATUS_CODE in RCV_HEADERS_INTERFACE and	 |
|                  RCV_TRANSACTIONS_INTERFACE to PENDING and the 	 |
|		   VALIDATION_FLAG in both tables to 'Y' so that the   	 |
|		   receiving transaction processor will pick these     	 |
| 	   	   records up next time its run	    		         |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 12-OCT-00  	Preetam B -  Created.                                    |
| 							                 |
|                                                                        |
=========================================================================*/

PROCEDURE reprocess_adjust_errors(errbufx  OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2)
IS

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN

    gml_recv_trans_pkg.gml_process_adjust_errors(retcode);



EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    errbufx := SUBSTRB(SQLERRM, 1, 100);

END;

END GML_REPROCESS_RCPTS;

/
