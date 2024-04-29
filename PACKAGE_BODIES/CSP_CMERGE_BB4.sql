--------------------------------------------------------
--  DDL for Package Body CSP_CMERGE_BB4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CMERGE_BB4" AS
/* $Header: cscm104b.pls 115.2 99/07/16 08:47:44 porting ship  $ */

/* -----------------  Local Procedures ----------------------------------------*/

PROCEDURE CS_MERGE_SYS_INSTALL_SITE_ID ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
                                         process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_SYS_SHIP_SITE_ID    ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
                                         process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_CP_INSTALL_SITE_ID  ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
                                         process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_CP_SHIP_SITE_ID     ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
            				 process_mode IN VARCHAR2 );

PROCEDURE CS_MERGE_CUSTOMER_ID         ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
					 process_mode IN VARCHAR2 );

PROCEDURE CS_CHECK_MERGE_DATA          ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
					 process_mode IN VARCHAR2 );

/* ------------------- End Local Procedures ------------------------------------ */

/* This procedure handles the merge process for the CS_TEMPLATES_INTERFACE.
   It calls 5 seperate procedures to accomplish the task. The tasts are listed
   below:
    1) Update the system_ship_to_site_use_id
    2) Update the system_install_site_use_id
    3) Update the cp_ship_to_site_use_id
    4) Update the cp_install_site_use_id
    5) Update the customer_id

 ---------------------------------------------------------------------------- */

PROCEDURE MERGE ( req_id       IN NUMBER,
                  set_number   IN NUMBER,
                  process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

  BEGIN

/* Put the header in the report to identify the block to be run */

        arp_message.set_line('CP_CMERGE_BB4.MERGE()+');

        IF ( process_mode = 'LOCK' ) Then
	        arp_message.set_name('AR', 'AR_LOCKING_TABLE');
     	  	arp_message.set_token('TABLE_NAME', 'CS_TEMPLATES_INTERFACE',FALSE );
        	message_text := 'The locking is done in block CSP_CMERGE_BB4';
        	arp_message.set_line(message_text);
        ELSE
        	arp_message.set_name('AR', 'AR_UPDATING_TABLE');
        	arp_message.set_token('TABLE_NAME', 'CS_TEMPLATES_INTERFACE',FALSE );
        	message_text := 'The merge is done in block CSP_CMERGE_BB4';
        	arp_message.set_line(message_text);
        END IF;

/* merge the CS_TEMPLATES_INTERFACE table update system ship to site use id */

        message_text := '***-- Procedure CS_MERGE_SYS_SHIP_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_SYS_SHIP_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_SYS_SHIP_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_TEMPLATES_INTERFACE table update system install site use id */

        message_text := '***-- Procedure CS_MERGE_SYS_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_SYS_INSTALL_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_SYS_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_TEMPLATES_INTERFACE table update cp ship to site use id */

        message_text := '***-- Procedure CS_MERGE_CP_SHIP_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_CP_SHIP_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_CP_SHIP_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_TEMPLATES_INTERFACE table update cp install site use id */

        message_text := '***-- Procedure CS_MERGE_CP_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_CP_INSTALL_SITE_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_CP_INSTALL_SITE_ID --**';
        arp_message.set_line(message_text);

/* merge the CS_TEMPLATES_INTERFACE table update the customer_id */

        message_text := '***-- Procedure CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

        CS_MERGE_CUSTOMER_ID( req_id, set_number, process_mode );

        message_text := '***-- End CS_MERGE_CUSTOMER_ID --**';
        arp_message.set_line(message_text);

/* That the merge of CS_TEMPLATES_INTERFACE is complete, use a cursor to
   check to make sure all data has been updated. If not report it to the
   log file.  */

        CS_CHECK_MERGE_DATA ( req_id, set_number, process_mode );

/* Report that the process for CS_TEMPLATES_INTERFACE is complete */

        IF ( process_mode = 'LOCK' ) Then
        	message_text := '** LOCKING completed for table CS_TEMPLATES_INTERFACE **';
        	arp_message.set_line(message_text);
        ELSE
        	message_text := '** MERGE completed for table CS_TEMPLATES_INTERFACE **';
        	arp_message.set_line(message_text);
        END IF;

        arp_message.set_line('CP_CMERGE_BB4.MERGE()-');

 END MERGE;

/* -----------------------------------------------------------------------------*/

/* Update the ship use site id of CS_TEMPLATES_INTERFACE */

PROCEDURE CS_MERGE_SYS_SHIP_SITE_ID( req_id       IN NUMBER,
                                     set_number   IN NUMBER,
     				     process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_SYS_SHIP_USE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT system_ship_to_site_use_id
        FROM   CS_TEMPLATES_INTERFACE yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.system_ship_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                		  FROM   RA_CUSTOMER_MERGES RACM
                                		  WHERE  RACM.PROCESS_FLAG = 'N'
                                 		  AND    RACM.REQUEST_ID   = req_id
                                 		  AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
        FOR UPDATE NOWAIT;


  BEGIN

        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the system_ship_to_site_use_id ( 1/5 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_SYS_SHIP_USE_ID ( req_id, set_number );
             CLOSE LOCK_SYS_SHIP_USE_ID;

             message_text := 'Locked the system_ship_to_site_use_id';
             arp_message.set_line(message_text);

       ELSE

             message_text := 'Updating the system_ship_to_site_use_id ( 1/5 )';
             arp_message.set_line(message_text);

             UPDATE CS_TEMPLATES_INTERFACE yt
             SET
               yt.system_ship_to_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.system_ship_to_site_use_id
                                         = RACM.DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
             WHERE
               yt.system_ship_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                  		  FROM   RA_CUSTOMER_MERGES RACM
                                  		  WHERE  RACM.PROCESS_FLAG = 'N'
                                 		  AND    RACM.REQUEST_ID   = req_id
                                 		  AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of system_ship_to_site_use_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text :=
                         'System_ship_to_site_use_id NOT found -- proceeding *** ';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of system_ship_to_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_SYS_SHIP_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_SYS_SHIP_SITE_ID;

/* Update the ship use site id of CS_TEMPLATES_INTERFACE */

PROCEDURE CS_MERGE_SYS_INSTALL_SITE_ID ( req_id       IN NUMBER,
                                         set_number   IN NUMBER,
					 process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_SYS_INSTALL_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT system_install_site_use_id
        FROM   CS_TEMPLATES_INTERFACE yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.system_install_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                		  FROM   RA_CUSTOMER_MERGES RACM
                                		  WHERE  RACM.PROCESS_FLAG = 'N'
                                 		  AND    RACM.REQUEST_ID   = req_id
                                 		  AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the system_install_site_use_id ( 2/5 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_SYS_INSTALL_SITE_ID ( req_id, set_number );
             CLOSE LOCK_SYS_INSTALL_SITE_ID;

             message_text := 'Done locking system_install_site_use_id';
             arp_message.set_line(message_text);

        ELSE

             message_text :=
                     'Starting to update the system_install_site_use_id ( 2/5 )';
             arp_message.set_line(message_text);

             UPDATE CS_TEMPLATES_INTERFACE yt
             SET
               yt.system_install_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.system_install_site_use_id
                                         = DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
             WHERE
               yt.system_install_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                                  FROM   RA_CUSTOMER_MERGES RACM
                                                  WHERE  RACM.PROCESS_FLAG = 'N'
                                   		  AND    RACM.REQUEST_ID   = req_id
                                  		  AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of system_install_site_use_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text :=
                         'System_install_site_use_id NOT found -- proceeding ***';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of system_install_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_SYS_INSTALL_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_SYS_INSTALL_SITE_ID;

/* Update the ship use site id of CS_TEMPLATES_INTERFACE */

PROCEDURE CS_MERGE_CP_SHIP_SITE_ID( req_id       IN NUMBER,
                                    set_number   IN NUMBER,
				    process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_CP_SHIP_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT cp_ship_to_site_use_id
        FROM   CS_TEMPLATES_INTERFACE yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.cp_ship_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                               		      FROM   RA_CUSTOMER_MERGES RACM
                                              WHERE  RACM.PROCESS_FLAG = 'N'
                                 	      AND    RACM.REQUEST_ID   = req_id
                                 	      AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the cp_ship_to_site_use_id ( 3/5 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_CP_SHIP_SITE_ID ( req_id, set_number );
             CLOSE LOCK_CP_SHIP_SITE_ID;

             message_text := 'Done locking cp_ship_to_site_use_id';
             arp_message.set_line(message_text);

       ELSE

             message_text := 'Starting to update the cp_ship_to_site_use_id ( 3/5 )';
             arp_message.set_line(message_text);

             UPDATE CS_TEMPLATES_INTERFACE yt
             SET
               yt.cp_ship_to_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.cp_ship_to_site_use_id
                                         = DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
             WHERE
               yt.cp_ship_to_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                   	      FROM   RA_CUSTOMER_MERGES RACM
                                  	      WHERE  RACM.PROCESS_FLAG = 'N'
                                   	      AND    RACM.REQUEST_ID   = req_id
                                   	      AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of cp_ship_to_site_use_id';
             arp_message.set_line(message_text);

       END IF;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text := 'Cp_ship_to_site_use_id NOT found -- proceeding ***';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of cp_ship_to_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_CP_SHIP_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_CP_SHIP_SITE_ID;

/* Update the ship use site id of CS_TEMPLATES_INTERFACE */

PROCEDURE CS_MERGE_CP_INSTALL_SITE_ID ( req_id       IN NUMBER,
                                        set_number   IN NUMBER,
					process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_CP_INSTALL_SITE_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT cp_install_site_use_id
        FROM   CS_TEMPLATES_INTERFACE yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.cp_install_site_use_id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                	      FROM   RA_CUSTOMER_MERGES RACM
                                	      WHERE  RACM.PROCESS_FLAG = 'N'
                                              AND    RACM.REQUEST_ID   = req_id
                                 	      AND    RACM.SET_NUMBER   = set_number )
        AND    yt.customer_id <> RACM.DUPLICATE_ID
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the cp_install_site_use_id ( 4/5 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_CP_INSTALL_SITE_ID ( req_id, set_number );
             CLOSE LOCK_CP_INSTALL_SITE_ID;

             message_text := 'Done locking cp_install_site_use_id';
             arp_message.set_line(message_text);

        ELSE

             message_text :=
                     'Starting to update the cp_install_site_use_id ( 4/5 )';
             arp_message.set_line(message_text);

             UPDATE CS_TEMPLATES_INTERFACE yt
             SET
               yt.cp_install_site_use_id =
                                ( SELECT DISTINCT RACM.CUSTOMER_SITE_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.cp_install_site_use_id
                                         = DUPLICATE_SITE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
             WHERE
               yt.cp_install_site_use_Id IN ( SELECT RACM.DUPLICATE_SITE_ID
                                              FROM   RA_CUSTOMER_MERGES RACM
                                  	      WHERE  RACM.PROCESS_FLAG = 'N'
                                  	      AND    RACM.REQUEST_ID   = req_id
                                	      AND    RACM.SET_NUMBER   = set_number );

             arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
             number_of_rows := sql%rowcount;
             arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
             message_text := 'Done with the update of cp_install_site_use_id';
             arp_message.set_line(message_text);

        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

              message_text := 'cp_install_site_use_id NOT found -- proceeding *** ';
              arp_message.set_line(message_text);
              arp_message.set_name( 'CS', 'CS_ROWS_UPDATED');
              number_of_rows := sql%rowcount;
              arp_message.set_token( 'NUM_ROWS',to_char( number_of_rows) );
              message_text := 'Done with the update of cp_install_site_use_id';
              arp_message.set_line(message_text);

          WHEN OTHERS THEN

              message_text := SUBSTR(SQLERRM,1,70);
              arp_message.set_error('CS_MERGE_CP_INSTALL_SITE_ID',
                                     message_text);
              raise;

 END CS_MERGE_CP_INSTALL_SITE_ID;

/* This process updates the customer_id of the CS_TEMPLATES_INTERFACE table */

PROCEDURE CS_MERGE_CUSTOMER_ID (req_id       IN NUMBER,
                                set_number   IN NUMBER,
 				process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;

        Cursor LOCK_CUSTOMER_ID ( req_id NUMBER, set_number NUMBER ) IS
        SELECT yt.customer_id
        FROM   CS_TEMPLATES_INTERFACE yt, RA_CUSTOMER_MERGES RACM
        WHERE
               yt.customer_id IN ( SELECT RACM.DUPLICATE_ID
                                   FROM   RA_CUSTOMER_MERGES RACM
                                   WHERE  RACM.PROCESS_FLAG = 'N'
                                   AND    RACM.REQUEST_ID   = req_id
                                   AND    RACM.SET_NUMBER   = set_number )
	FOR UPDATE NOWAIT;

  BEGIN
        IF ( process_mode = 'LOCK' ) Then

             message_text := 'LOCKING the customer_id ( 5/5 )';
             arp_message.set_line(message_text);

             OPEN  LOCK_CUSTOMER_ID ( req_id, set_number );
             CLOSE LOCK_CUSTOMER_ID;

             message_text := 'Done locking customer_id';
             arp_message.set_line(message_text);

        ELSE

             message_text := 'Starting to update the customer_id ( 5/5 )';
             arp_message.set_line(message_text);

             UPDATE CS_TEMPLATES_INTERFACE yt
             SET
               yt.customer_id = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                  FROM   RA_CUSTOMER_MERGES RACM
                                  WHERE  yt.customer_id    = DUPLICATE_ID
                                  AND    RACM.PROCESS_FLAG = 'N'
                                  AND    RACM.REQUEST_ID   = req_id
                                  AND    RACM.SET_NUMBER   = set_number )
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

/* Loop through using a cursor and try to identify for customer_id's unmerged
   records. For each record that should have been merged report it to the
   log file.*/

PROCEDURE CS_CHECK_MERGE_DATA ( req_id       IN NUMBER,
                                set_number   IN NUMBER,
                                process_mode IN VARCHAR2 ) IS

/* templaray storage location for identifing the record in error */

        templates_interface_id NUMBER;

/* used to store a free form text to be written to the log file */

        message_text          char(80);

/* number of rows updated */

        number_of_rows        NUMBER;


       CURSOR CS_CHECK  IS
              SELECT
               DISTINCT
                cs.templates_interface_id
     	      FROM CS_TEMPLATES_INTERFACE CS,
      	           RA_CUSTOMER_MERGES RACM
              WHERE
                RACM.PROCESS_FLAG = 'N'        AND
                RACM.REQUEST_ID   = req_id     AND
                RACM.SET_NUMBER   = set_number AND
            ((( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.system_ship_to_site_use_id <> racm.customer_site_id AND
                cs.system_ship_to_site_use_id IS NOT NULL ) AND
              ( cs.customer_id NOT IN ( select racm.customer_id
                                        from CS_TEMPLATES_INTERFACE CS,
					     RA_CUSTOMER_MERGES RACM
                                        where cs.customer_id  = RACM.CUSTOMER_ID AND
                                        cs.system_ship_to_site_use_id = racm.customer_site_id or
                                        cs.system_ship_to_site_use_id IS NULL ))) AND
             (( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.system_install_site_use_id <> racm.customer_site_id   AND
                cs.system_install_site_use_id IS NOT NULL  ) AND
              ( cs.customer_id NOT IN ( select racm.customer_id
                                        from CS_TEMPLATES_INTERFACE CS,
					     RA_CUSTOMER_MERGES RACM
                                        where cs.customer_id  = RACM.CUSTOMER_ID AND
                                        cs.system_install_site_use_id = racm.customer_site_id or
                                        cs.system_install_site_use_id IS NULL ))) AND
             (( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.cp_install_site_use_id     <> racm.customer_site_id   AND
                cs.cp_install_site_use_id     IS NOT NULL )  AND
              ( cs.customer_id NOT IN ( select racm.customer_id
                                        from CS_TEMPLATES_INTERFACE CS,
					     RA_CUSTOMER_MERGES RACM
                                        where cs.customer_id  = RACM.CUSTOMER_ID AND
                                        cs.cp_install_site_use_id = racm.customer_site_id or
                                        cs.cp_install_site_use_id IS NULL ))) AND
             (( cs.customer_id  = RACM.CUSTOMER_ID AND
                cs.cp_ship_to_site_use_id     <> racm.customer_site_id   AND
                cs.cp_ship_to_site_use_id     IS NOT NULL ) AND
              ( cs.customer_id NOT IN ( select racm.customer_id
                                        from CS_TEMPLATES_INTERFACE CS,
					     RA_CUSTOMER_MERGES RACM
                                        where cs.customer_id  = RACM.CUSTOMER_ID AND
                                        cs.cp_ship_to_site_use_id = racm.customer_site_id or
                                        cs.cp_ship_to_site_use_id IS NULL ))) );
    BEGIN
        IF ( process_mode <> 'LOCK' ) Then

          message_text := '***-- Procedure CS_CHECK_MERGE_DATA --**';
          arp_message.set_line(message_text);


          OPEN CS_CHECK;

          LOOP
              FETCH CS_CHECK
               INTO
   	    	       	templates_interface_id;

              EXIT WHEN  CS_CHECK%NOTFOUND;
              message_text :=
                  'WARNING, Following access templates interface id has address(s) not merged ';
              arp_message.set_line(message_text);
              message_text := templates_interface_id;
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

END CSP_CMERGE_BB4;

/
