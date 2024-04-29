--------------------------------------------------------
--  DDL for Package Body CSP_CMERGE_BB7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CMERGE_BB7" AS
/* $Header: cscm107b.pls 115.1 99/07/16 08:48:04 porting s $ */

/* -----------------  Local Procedures ----------------------------------------*/

PROCEDURE CS_MERGE_CUSTOMER_ID           ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
					                  process_mode IN VARCHAR2 );

/* ------------------- End Local Procedures ------------------------------------ */

/* This procedure handles the merge process for the CS_REPAIRS.
   It calls 1 seperate procedures to accomplish the task. The tasts are listed
   below:
    1) Update the customer_id

 ---------------------------------------------------------------------------- */

PROCEDURE MERGE ( req_id       IN NUMBER,
                  set_number   IN NUMBER,
                  process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          VARCHAR2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

  BEGIN

/* Put the header in the report to identify the block to be run */

        arp_message.set_line('CP_CMERGE_BB7.MERGE()+');

        IF ( process_mode = 'LOCK' ) Then
	        arp_message.set_name('AR', 'AR_LOCKING_TABLE');
     	  	arp_message.set_token('TABLE_NAME', 'CS_REPAIRS',FALSE );
        	message_text := 'The locking is done in block CSP_CMERGE_BB7';
        	arp_message.set_line(message_text);
        ELSE
        	arp_message.set_name('AR', 'AR_UPDATING_TABLE');
        	arp_message.set_token('TABLE_NAME', 'CS_REPAIRS',FALSE );
        	message_text := 'The merge is done in block CSP_CMERGE_BB7';
        	arp_message.set_line(message_text);
        END IF;

/* merge the CS_REPAIRS table update the customer_id */

        message_text := '***-- Procedure CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_CUSTOMER_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

/* Report that the process for CS_REPAIRS is complete */

        IF ( process_mode = 'LOCK' ) Then
        	message_text := '** LOCKING completed for table CS_REPAIRS **';
        	arp_message.set_line(message_text);
        ELSE
        	message_text := '** MERGE completed for table CS_REPAIRS **';
        	arp_message.set_line(message_text);
        END IF;

        arp_message.set_line('CP_CMERGE_BB7.MERGE()-');

 END MERGE;

/* -----------------------------------------------------------------------------*/

/* This process updates the customer_id of the CS_REPAIRS table */

PROCEDURE CS_MERGE_CUSTOMER_ID (req_id       IN NUMBER,
                                set_number   IN NUMBER,
 				process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          VARCHAR2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_CUSTOMER_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT yt.rma_customer_id
        FROM   CS_REPAIRS yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.rma_customer_id IN ( SELECT RACM.DUPLICATE_ID
                                   FROM   RA_CUSTOMER_MERGES RACM
                                   WHERE  RACM.PROCESS_FLAG = 'N'
                                   AND    RACM.REQUEST_ID   = req_id
                                   AND    RACM.SET_NUMBER   = set_number )
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the rma_customer_id ( 1/1 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_CUSTOMER_ID ( req_id, set_number );
             CLOSE LOCK_CUSTOMER_ID;

             message_text := 'Done locking rma_customer_id';
             arp_message.set_line(message_text);

        ELSE

             message_text := 'Starting to update the rma_customer_id ( 1/1 )';
             arp_message.set_line(message_text);

             UPDATE CS_REPAIRS yt
             SET
               yt.rma_customer_id = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.rma_customer_id    = DUPLICATE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
             WHERE
               yt.rma_customer_id IN ( SELECT RACM.DUPLICATE_ID
                                   FROM   RA_CUSTOMER_MERGES RACM
                                   WHERE  RACM.PROCESS_FLAG = 'N'
                                   AND    RACM.REQUEST_ID   = req_id
                                   AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of rma_customer_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text := 'RMA_Customer_id NOT found -- proceeding *** ';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of rma_customer_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_CUSTOMER_ID',
                                     message_text);
              raise;

 END CS_MERGE_CUSTOMER_ID;

END CSP_CMERGE_BB7;

/