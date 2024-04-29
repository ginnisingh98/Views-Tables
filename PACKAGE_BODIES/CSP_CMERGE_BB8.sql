--------------------------------------------------------
--  DDL for Package Body CSP_CMERGE_BB8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CMERGE_BB8" AS
/* $Header: cscm108b.pls 115.3 99/07/16 08:48:11 porting ship  $ */

/* ---------------  Local Procedures ----------------------------------------*/

PROCEDURE CS_MERGE_BILL_TO_SITE_ID       ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
                                           process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_INSTALL_SITE_ID       ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
                                           process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_SHIP_TO_SITE_ID       ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
                                           process_mode IN VARCHAR2 );


PROCEDURE CS_MERGE_CUSTOMER_ID           ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
               					   process_mode IN VARCHAR2 );

PROCEDURE CS_CHECK_MERGE_DATA            ( req_id       IN NUMBER,
                                           set_number   IN NUMBER,
		                      		   process_mode IN VARCHAR2 );

/* -------------- End Local Procedures ------------------------------- */

/* This procedure handles the merge process for the CS_INCIDENTS.
   It calls 4 seperate procedures to accomplish the task. The tasks are listed
   below:
    1) Update the bill_to_site_use_id
    2) Update the install_site_use_id
    3) Update the ship_to_site_use_id
    4) Update the customer_id

---------------------------------------------------------------------- */

PROCEDURE MERGE ( req_id       IN NUMBER,
                  set_number   IN NUMBER,
                  process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

  BEGIN

/* Put the header in the report to identify the block to be run */

        arp_message.set_line('CP_CMERGE_BB8.MERGE()+');

        IF ( process_mode = 'LOCK' ) Then
	        arp_message.set_name('AR', 'AR_LOCKING_TABLE');
     	  	arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS',FALSE );
        	message_text := 'The locking is done in block CSP_CMERGE_BB8';
        	arp_message.set_line(message_text);
        ELSE
        	arp_message.set_name('AR', 'AR_UPDATING_TABLE');
        	arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS',FALSE );
        	message_text := 'The merge is done in block CSP_CMERGE_BB8';
        	arp_message.set_line(message_text);
        END IF;

/* merge the CS_INCIDENTS table update bill_to_site_use_id */

        message_text := '***-- Procedure CS_MERGE_BILL_TO_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_BILL_TO_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_BILL_TO_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_INCIDENTS table update install_site_use_id */

        message_text := '***-- Procedure CS_MERGE_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_INSTALL_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_INCIDENTS table update ship_to_site_use_id */

        message_text := '***-- Procedure CS_MERGE_SHIP_TO_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_SHIP_TO_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_SHIP_TO_SITE_ID --**';
        arp_message.set_line(message_text);


/* merge the CS_INCIDENTS table update the customer_id */

        message_text := '***-- Procedure CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_CUSTOMER_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

/* The merge of CS_INCIDENTS is complete, use a cursor to
   check to make sure all data has been updated. If not report it to the
   log file.  */

        CS_CHECK_MERGE_DATA ( req_id, set_number, process_mode );

/* Report that the process for CS_INCIDENTS is complete */

        IF ( process_mode = 'LOCK' ) Then
       	message_text := '** LOCKING completed for table CS_INCIDENTS **';
       	arp_message.set_line(message_text);
        ELSE
       	message_text := '** MERGE completed for table CS_INCIDENTS **';
       	arp_message.set_line(message_text);
        END IF;

        arp_message.set_line('CP_CMERGE_BB8.MERGE()-');

 END MERGE;

/* ------------------------------------------------------------------------*/

/* Update the bill to  site use id of CS_INCIDENTS */

PROCEDURE CS_MERGE_BILL_TO_SITE_ID ( req_id       IN NUMBER,
                                     set_number   IN NUMBER,
     				     process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text         varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_BILL_TO_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT bill_to_site_use_id
        FROM   CS_INCIDENTS yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.bill_to_site_use_id IN        ( SELECT RACM.DUPLICATE_SITE_ID
                                		  FROM   RA_CUSTOMER_MERGES RACM
                                		  WHERE  RACM.PROCESS_FLAG = 'N'
                                 		  AND    RACM.REQUEST_ID   = req_id
                                 		  AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
        FOR UPDATE NOWAIT;


  BEGIN

        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the bill_to_site_use_id ( 1/6 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_BILL_TO_SITE_ID ( req_id, set_number );
             CLOSE LOCK_BILL_TO_SITE_ID;

             message_text := 'Locked the bill_to_site_use_id';
             arp_message.set_line(message_text);

       ELSE

             message_text := 'Updating the bill_to_site_use_id ( 1/6 )';
             arp_message.set_line(message_text);

             UPDATE CS_INCIDENTS yt
             SET
               yt.bill_to_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.bill_to_site_use_id
                                         = RACM.DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number ),
               yt.LAST_UPDATE_DATE       = SYSDATE,
               yt.LAST_UPDATED_BY        = ARP_STANDARD.PROFILE.USER_ID,
               yt.LAST_UPDATE_LOGIN      = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
             WHERE
               yt.bill_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                  		  FROM   RA_CUSTOMER_MERGES RACM
                                  		  WHERE  RACM.PROCESS_FLAG = 'N'
                                 		  AND    RACM.REQUEST_ID   = req_id
                                 		  AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of bill_to_site_use_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text :=
                         'Bill_to_site_use_id NOT found -- proceeding *** ';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of bill_to_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_BILL_TO_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_BILL_TO_SITE_ID;

/* Update the install site use id of CS_INCIDENTS */

 PROCEDURE CS_MERGE_INSTALL_SITE_ID    ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
					 process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_INSTALL_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT install_site_use_id
        FROM   CS_INCIDENTS yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.install_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                               		   FROM   RA_CUSTOMER_MERGES RACM
                                           WHERE  RACM.PROCESS_FLAG = 'N'
                                 	   AND    RACM.REQUEST_ID   = req_id
                                 	   AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the install_site_use_id ( 2/6 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_INSTALL_SITE_ID ( req_id, set_number );
             CLOSE LOCK_INSTALL_SITE_ID;

             message_text := 'Done locking Install_site_use_id';
             arp_message.set_line(message_text);

        ELSE

             message_text :=
                     'Starting to update the install_site_use_id ( 2/6 )';
             arp_message.set_line(message_text);

             UPDATE CS_INCIDENTS yt
             SET
               yt.install_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.install_site_use_id
                                         = DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number ),
               LAST_UPDATE_DATE       = SYSDATE,
               LAST_UPDATED_BY        = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN      = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
             WHERE
               yt.install_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                           FROM   RA_CUSTOMER_MERGES RACM
                                           WHERE  RACM.PROCESS_FLAG = 'N'
                                  	   AND    RACM.REQUEST_ID   = req_id
                                  	   AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of Install_site_use_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text :=
                         'Install_site_use_id NOT found -- proceeding ***';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of Install_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_INSTALL_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_INSTALL_SITE_ID;

/* Update the ship to site id of CS_INCIDENTS */

PROCEDURE CS_MERGE_SHIP_TO_SITE_ID( req_id       IN NUMBER,
                                    set_number   IN NUMBER,
				    process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_SHIP_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT ship_to_site_use_id
        FROM   CS_INCIDENTS yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.ship_to_site_use_id IN    ( SELECT RACM.DUPLICATE_SITE_ID
                               		      FROM   RA_CUSTOMER_MERGES RACM
                                              WHERE  RACM.PROCESS_FLAG = 'N'
                                 	      AND    RACM.REQUEST_ID   = req_id
                                 	      AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the ship_to_site_use_id ( 3/6 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_SHIP_SITE_ID ( req_id, set_number );
             CLOSE LOCK_SHIP_SITE_ID;

             message_text := 'Done locking ship_to_site_use_id';
             arp_message.set_line(message_text);

       ELSE

             message_text := 'Starting to update the ship_to_site_use_id ( 3/6 )';
             arp_message.set_line(message_text);

             UPDATE CS_INCIDENTS yt
             SET
               yt.ship_to_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.ship_to_site_use_id
                                         = DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number ),
               LAST_UPDATE_DATE       = SYSDATE,
               LAST_UPDATED_BY        = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN      = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
             WHERE
               yt.ship_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                   	   FROM   RA_CUSTOMER_MERGES RACM
                                  	   WHERE  RACM.PROCESS_FLAG = 'N'
                                   	   AND    RACM.REQUEST_ID   = req_id
                                   	   AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of ship_to_site_use_id';
             arp_message.set_line(message_text);

       END IF;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text := 'ship_to_site_use_id NOT found -- proceeding ***';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of ship_to_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_SHIP_TO_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_SHIP_TO_SITE_ID;

/* This process updates the customer_id of the CS_INCIDENTS table */

PROCEDURE CS_MERGE_CUSTOMER_ID (req_id       IN NUMBER,
                                set_number   IN NUMBER,
 				process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_CUSTOMER_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT yt.customer_id
        FROM   CS_INCIDENTS yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.customer_id IN ( SELECT RACM.DUPLICATE_ID
                                   FROM   RA_CUSTOMER_MERGES RACM
                                   WHERE  RACM.PROCESS_FLAG = 'N'
                                   AND    RACM.REQUEST_ID   = req_id
                                   AND    RACM.SET_NUMBER   = set_number )
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the customer_id ( 6/6 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_CUSTOMER_ID ( req_id, set_number );
             CLOSE LOCK_CUSTOMER_ID;

             message_text := 'Done locking customer_id';
             arp_message.set_line(message_text);

        ELSE

             message_text := 'Starting to update the customer_id ( 6/6 )';
             arp_message.set_line(message_text);

             UPDATE CS_INCIDENTS yt
             SET
               yt.customer_id = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.customer_id    = DUPLICATE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number ),
               LAST_UPDATE_DATE       = SYSDATE,
               LAST_UPDATED_BY        = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN      = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
             WHERE
               yt.customer_id IN ( SELECT RACM.DUPLICATE_ID
                                   FROM   RA_CUSTOMER_MERGES RACM
                                   WHERE  RACM.PROCESS_FLAG = 'N'
                                   AND    RACM.REQUEST_ID   = req_id
                                   AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of customer_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text := 'Customer_id NOT found -- proceeding *** ';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of customer_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_CUSTOMER_ID',
                                     message_text);
              raise;

 END CS_MERGE_CUSTOMER_ID;

/* Loop through using a cursor and try to identify for a request_Id un merged
   records. For each record that should have been merged report it to the
   log file.*/

PROCEDURE CS_CHECK_MERGE_DATA ( req_id       IN NUMBER,
                                set_number   IN NUMBER,
                                process_mode IN VARCHAR2 ) IS

/* templaray storage location for identifing the record in error */

        current_serial_number varchar2(10);

/* used to store a free form text to be written to the log file */

        message_text          varchar2(255);

/* number of rows updated */

        number_of_rows        NUMBER;


       CURSOR CS_CHECK  IS
              SELECT
               DISTINCT
                cs.incident_id
     	      FROM CS_INCIDENTS CS,
      	           RA_CUSTOMER_MERGES RACM
              WHERE
                RACM.PROCESS_FLAG = 'N'        AND
                RACM.REQUEST_ID   = req_id     AND
                RACM.SET_NUMBER   = set_number AND
            ((( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.bill_to_site_use_id <> racm.customer_site_id AND
                cs.bill_to_site_use_id IS NOT NULL ) AND
              ( cs.customer_id NOT IN ( select racm.customer_id
                                        from CS_INCIDENTS CS,
					     RA_CUSTOMER_MERGES RACM
                       where cs.customer_id  = RACM.CUSTOMER_ID AND
                             cs.bill_to_site_use_id = racm.customer_site_id OR
                                        cs.bill_to_site_use_id IS NULL ))) AND
             (( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.install_site_use_id <> racm.customer_site_id   AND
                cs.install_site_use_id IS NOT NULL  ) AND
         ( cs.customer_id NOT IN ( select racm.customer_id
                                   from CS_INCIDENTS CS,
                		    RA_CUSTOMER_MERGES RACM
                              WHERE cs.customer_id  = RACM.CUSTOMER_ID AND
                              cs.install_site_use_id = racm.customer_site_id OR
                                        cs.install_site_use_id IS NULL ))) AND
             (( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.ship_to_site_use_id     <> racm.customer_site_id   AND
                cs.ship_to_site_use_id     IS NOT NULL )  AND
         ( cs.customer_id NOT IN ( select racm.customer_id
                                   from CS_INCIDENTS CS,
	         		     RA_CUSTOMER_MERGES RACM
                              WHERE cs.customer_id  = RACM.CUSTOMER_ID AND
                              cs.ship_to_site_use_id = racm.customer_site_id OR
                              cs.ship_to_site_use_id IS NULL ))));

    BEGIN
        IF ( process_mode <> 'LOCK' ) Then

          message_text := '***-- Procedure CS_CHECK_MERGE_DATA --**';
          arp_message.set_line(message_text);


          OPEN CS_CHECK;

          LOOP
              FETCH CS_CHECK
               INTO
   	    	      current_serial_number;

              EXIT WHEN  CS_CHECK%NOTFOUND;
              message_text :=
                  'WARNING, Following Product Serial Num. has address(s) not merged ';
              arp_message.set_line(message_text);
              message_text := current_serial_number;
              arp_message.set_line(message_text);

          END LOOP;

	  CLOSE CS_CHECK;

          message_text := '***-- End CS_CHECK_MERGE_DATA --**';
          arp_message.set_line(message_text);

        END IF;

        EXCEPTION

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_CHECK_MERGE_DATA',
                                     message_text);
              raise;

    END CS_CHECK_MERGE_DATA;


END CSP_CMERGE_BB8;


/
