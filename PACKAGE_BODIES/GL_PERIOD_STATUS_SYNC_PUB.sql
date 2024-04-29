--------------------------------------------------------
--  DDL for Package Body GL_PERIOD_STATUS_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PERIOD_STATUS_SYNC_PUB" AS
/* $Header: glpssysb.pls 120.4.12010000.1 2009/12/16 11:56:23 sommukhe noship $ */
/*================================================================================|
| FILENAME                                                                        |
|    glpssysb.pls                                                                 |
|                                                                                 |
| PACKAGE NAME                                                                    |
|    GL_PERIOD_STATUS_SYNC_PUB                                                    |
|                                                                                 |
| DESCRIPTION                                                                     |
|     This is a GL Period Synchronization which is used to Open a GL period for   |
|     Primary and its Secondary and Reporting Ledgers with in a gieven date range.|
|     Also this Program used to close the period which is beyond the date range   |
|     if the periods already opened.                                              |
|                                                                                 |
|     In case of any error in any stage of the program will stop the process. And |
|     error will be notified to AIA through business event.                       |
|                                                                                 |
|     Existing concurrent Program used to change the Period statuses.             |
|                                                                                 |
|     This is a package Body                                                      |
|                                                                                 |
|                                                                                 |
| SUB PROGRAMS                                                                    |
| ------------                                                                    |
| PROCEDURE period_status_sync                                                    |
|                                                                                 |
| PARAMETER DESCRIPTION                                                           |
| ---------------------                                                           |
| p_ledger_short_name   IN  short_name from gl_ledgers table.                     |
| p_start_date          IN      start_date of the period from gl_period_statuses  |
| p_end_date            IN  end_date of the period from gl_period_statuses        |
| errbuf                OUT      Default out parameter to capture error message   |
| retcode               OUT      Default out parameter to capture error code      |
| x_return_status       OUT  Default out parameter to capture status              |
| HISTORY                                                                         |
| -------                                                                         |
| 25-JUN-08  KARTHIK M P    Created                                               |
| 15-SEP-08  Vamshidhar G   Modified for the Validations.                         |
| 06-OCT-08  Vamshidhar G   Fix for the Bug No 7439499 and 7453185.               |
| 24-OCT-08  Vamshidhar G   Fix for the Bug No 7454214 and 7453834.               |
+=================================================================================*/
   PROCEDURE period_status_sync (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2,
      p_ledger_short_name   IN              VARCHAR2,
      p_start_date          IN              DATE,
      p_end_date            IN              DATE
   )
   IS
----------------------------------------------------------------------------------
---------------------------****Declaring Cursor****-------------------------------
----------------------------------------------------------------------------------

      --Cursor to get Primary and its Secondary and ALC ledgers
      CURSOR c_get_ledgers_rec (
         c_ledger_short_name           VARCHAR2,
         c_object_type_code            VARCHAR2,
         c_application_id              NUMBER,
         c_relationship_enabled_flag   VARCHAR2
      )
      IS
         SELECT *
           FROM gl_ledgers
          WHERE ledger_id IN (
                   SELECT gll2.ledger_id
                     FROM gl_ledgers gll1,
                          gl_ledgers gll2,
                          gl_ledger_relationships glrs
                    WHERE gll1.short_name = c_ledger_short_name
                      AND glrs.primary_ledger_id = gll1.ledger_id
                      AND gll2.object_type_code = c_object_type_code
                      AND glrs.target_ledger_id = gll2.ledger_id
                      AND glrs.application_id = c_application_id
                      AND glrs.relationship_enabled_flag =
                                                   c_relationship_enabled_flag);

      --Cursor to get the periods for open
      CURSOR c_get_period_open_rec (
         c_application_id   NUMBER,
         c_closing_status   VARCHAR2,
         c_ledger_id        NUMBER,
         c_start_date       DATE,
         c_end_date         DATE
      )
      IS
         SELECT *
           FROM gl_period_statuses
          WHERE application_id = c_application_id                        --101
            AND closing_status <> c_closing_status                       --'O'
            AND ledger_id = c_ledger_id
            AND start_date >= c_start_date
            AND end_date <= c_end_date;

      --Cursor to get the periods for closing
      CURSOR c_get_period_close_rec (
         c_application_id   NUMBER,
         c_closing_status   VARCHAR2,
         c_ledger_id        NUMBER,
         c_start_date       DATE,
         c_end_date         DATE
      )
      IS
         SELECT *
           FROM gl_period_statuses
          WHERE application_id = c_application_id
            AND closing_status = c_closing_status
            AND ledger_id = c_ledger_id
            AND (start_date < c_start_date OR end_date > c_end_date);

      --Cursor to get the Period Status After Submit Request
      CURSOR c_check_open_status_rec (
         c_ledger_id        IN   NUMBER,
         c_application_id   IN   NUMBER,
         c_period_name      IN   VARCHAR2
      )
      IS
         SELECT closing_status
           FROM gl_period_statuses
          WHERE ledger_id = c_ledger_id
            AND application_id = c_application_id
            AND period_name = c_period_name;

      --Cursor to fetch the Ledger Short Name
      CURSOR c_get_short_name
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (SELECT short_name
                          FROM gl_ledgers
                         WHERE short_name = p_ledger_short_name);

      --Cursor to fetch the start_date
      CURSOR c_start_date (
         c_ledger_short_name   IN   VARCHAR2,
         c_application_id      IN   NUMBER,
         c_start_date          IN   DATE
      )
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM gl_period_statuses gps, gl_ledgers gl
                    WHERE gl.ledger_id = gps.ledger_id
                      AND gps.application_id = c_application_id
                      AND gl.short_name = c_ledger_short_name
                      AND gps.start_date = c_start_date);

      --Cursor to fetch the end_date
      CURSOR c_end_date (
         c_ledger_short_name   IN   VARCHAR2,
         c_application_id      IN   NUMBER,
         c_end_date            IN   DATE
      )
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM gl_period_statuses gps, gl_ledgers gl
                    WHERE gl.ledger_id = gps.ledger_id
                      AND gps.application_id = c_application_id
                      AND gl.short_name = c_ledger_short_name
                      AND gps.end_date = c_end_date);

--------------------------------------------------
--------****Declaring Local Variables****---------
--------------------------------------------------

      --Declaring Local Variables
      l_request_id             NUMBER (15);
      l_conc_request_id        NUMBER (15);
      l_chart_of_accounts_id   NUMBER (15);
      l_ledger_name            VARCHAR2 (30);
      l_ledger_short_name      VARCHAR2 (1);
      l_access_set_id          NUMBER (15);
      l_phase                  VARCHAR2 (240);
      l_status                 VARCHAR2 (240);
      l_dev_phase              VARCHAR2 (240);
      l_dev_status             VARCHAR2 (240);
      l_message                VARCHAR2 (1500);
      l_wait_for_request       BOOLEAN;
      l_period_name            VARCHAR2 (30);
      l_message_ps             VARCHAR2 (100);
      l_ledger_id              NUMBER;
      l_user_id                NUMBER;
      l_resp_id                NUMBER;
      l_apps_id                NUMBER;
      l_closing_status         VARCHAR2 (1);
      l_con_status             VARCHAR2 (30);
      l_process_status_msg     VARCHAR2 (1000);
      l_be_message             VARCHAR2 (1000);
      l_business_event_type    VARCHAR2 (30);
      l_rec_type               gl_ledgers%ROWTYPE;
      l_start_date             VARCHAR2 (1);
      l_end_date               VARCHAR2 (1);
   BEGIN
--Initializing Concurrent Parameteres
      x_return_status := 'S';
      retcode := 0;

      OPEN c_get_short_name;

      FETCH c_get_short_name
       INTO l_ledger_short_name;

      IF l_ledger_short_name = 'Y'
      THEN
         IF p_start_date < p_end_date
         THEN
            fnd_file.put_line (fnd_file.LOG, '');
            fnd_file.put_line
               (fnd_file.LOG,
                '+---------------------------------------------------------------------------+'
               );
            fnd_file.put_line
               (fnd_file.LOG,
                '+--------------------****GL OPEN PERIOD SYNCHRONIZATION****-----------------+'
               );
            fnd_file.put_line
               (fnd_file.LOG,
                '+---------------------------------------------------------------------------+'
               );
            fnd_file.put_line (fnd_file.LOG, '');
--Difinitions
            fnd_file.put_line (fnd_file.LOG, 'DEFINITIONS');
            fnd_file.put_line (fnd_file.LOG, '-----------');
            fnd_file.put_line
                      (fnd_file.LOG,
                       '  GLPSL : GL PERIOD STATUS SYNCHRONIZATION LOG(LINES)'
                      );
            fnd_file.put_line
                           (fnd_file.LOG,
                            '  GLPSL : GL PERIOD STATUS SYNCHRONIZATION ERROR'
                           );
            fnd_file.put_line (fnd_file.LOG, 'RESP ID : RESPONSIBILITY ID');
            fnd_file.put_line (fnd_file.LOG, 'APPS ID : APPLICATION ID');
            fnd_file.put_line (fnd_file.LOG, '      C : CLOSED');
            fnd_file.put_line (fnd_file.LOG, '      O : OPENED');
            fnd_file.put_line (fnd_file.LOG, '');
            fnd_file.put_line (fnd_file.LOG, 'GLPSL: Program Begins...');
            fnd_file.put_line (fnd_file.LOG, '');
--Find the Concurrent Request Id for Period Synchronization
            fnd_file.put_line
               (fnd_file.LOG,
                'GLPSL: Get The Concurrent request ID for Period Synchronization....'
               );
            l_conc_request_id := fnd_global.conc_request_id;
            fnd_file.put_line (fnd_file.LOG,
                                  'GLPSL: Concurrent Request ID = '
                               || l_conc_request_id
                              );
--------------------------------------------------
------****Initializing Global Parameters****------
--------------------------------------------------
            fnd_file.put_line (fnd_file.LOG,
                               'GLPSL: Initializing Global Parameters.......'
                              );
--FND_GLOBAL.APPS_INITIALIZE(1001530,50553,101);
            l_user_id := fnd_global.user_id;                            --1318
            l_resp_id := fnd_global.resp_id;                           --50553
            l_apps_id := fnd_global.resp_appl_id;                        --101
--FND_GLOBAL.APPS_INITIALIZE(1318,50553,101);
            fnd_global.apps_initialize (l_user_id, l_resp_id, l_apps_id);
/*fnd_global.apps_initialize
(fnd_profile.value('USER_ID'),
 fnd_profile.value('RESP_ID'),
 fnd_profile.value('RESP_APPL_ID'));*/--commented by Vamshi
            l_access_set_id := fnd_profile.VALUE ('GL_ACCESS_SET_ID');
            fnd_file.put_line (fnd_file.LOG,
                                  'GLPSL: USER ID : '
                               || l_user_id
                               || ', '
                               || 'RESP ID : '
                               || l_resp_id
                               || ', '
                               || 'APPS ID : '
                               || l_apps_id
                               || ', '
                               || 'Access Set ID : '
                               || l_access_set_id
                              );
            fnd_file.put_line (fnd_file.LOG, '');

            OPEN c_start_date (p_ledger_short_name, l_apps_id, p_start_date);

            FETCH c_start_date
             INTO l_start_date;

            OPEN c_end_date (p_ledger_short_name, l_apps_id, p_end_date);

            FETCH c_end_date
             INTO l_end_date;

/*--If The given start/end date mathces with the EBS Periods start/end dates*/
            IF (l_start_date = 'Y' AND l_end_date = 'Y')
            THEN
/*--If there are no records or the Ledger Short Name is Invalid then set the Error Code to 'E'
OPEN c_get_ledgers_rec (p_ledger_short_name,
                             'L',
                             l_apps_id,
                             'Y');
FETCH c_get_ledgers_rec INTO l_rec_type;
IF c_get_ledgers_rec%FOUND THEN*/

               --------------------------------------------------
--Get the Primary, its secondary and ALC Ledgers--
--------------------------------------------------
               fnd_file.put_line (fnd_file.LOG, '');
               fnd_file.put_line
                  (fnd_file.LOG,
                   'GLPSL: GETS INTO PRIMARY, ITS SECONDARY AND ALC LEDGER RECORDS'
                  );
               fnd_file.put_line (fnd_file.LOG, '');

               FOR c1 IN c_get_ledgers_rec (p_ledger_short_name,
                                            'L',
                                            l_apps_id,
                                            'Y'
                                           )
               LOOP
                  IF c1.ledger_id IS NOT NULL
                  THEN
                     FOR c2 IN c_get_period_open_rec (l_apps_id,
                                                      'O',
                                                      c1.ledger_id,
                                                      p_start_date,
                                                      p_end_date
                                                     )
                     LOOP
                        IF c2.period_name IS NOT NULL
                        THEN
                           fnd_file.put_line
                              (fnd_file.LOG,
                               '-----**Open Period for the Given Date Range**-----'
                              );
                           fnd_file.put_line (fnd_file.LOG, '');
                           fnd_file.put_line
                              (fnd_file.LOG,
                               'GLPSL: Nullifying request_id for open period Process'
                              );
                           l_request_id := NULL;
                           fnd_file.put_line
                              (fnd_file.LOG,
                                  'GLPSL: Submit the Open Period request for the Period of '
                               || c2.period_name
                              );
                           fnd_file.put_line
                                         (fnd_file.LOG,
                                          'GLPSL: Submit Concurrent GLOOAP...'
                                         );
                           l_request_id :=
                              fnd_request.submit_request
                                            ('SQLGL',
                                             'GLOOAP',
                                             '',
                                             '',
                                             FALSE,
                                             c1.NAME,
                                             TO_CHAR (l_access_set_id),
                                             TO_CHAR (c2.ledger_id),
                                             TO_CHAR (c1.chart_of_accounts_id),
                                             TO_CHAR (c2.application_id),
                                             'P',
                                             c2.period_name,
                                             CHR (0),
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
					     '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '','','','','','','','','','',
                                             '',''
                                            );
                           COMMIT;
                           fnd_file.put_line
                                        (fnd_file.LOG,
                                         'GLPSL: Commit to get the Request ID'
                                        );
                           fnd_file.put_line (fnd_file.LOG,
                                                 'GLPSL: Request ID = '
                                              || l_request_id
                                             );
                           fnd_file.put_line (fnd_file.LOG, '');

                           IF l_request_id > 0
                           THEN
    --------------------------------------------------
---**Monitoring Request Status on Open Period**---
    --------------------------------------------------
                              fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSL: Monitoring Request Status on Open Period'
                                 );
                              fnd_file.put_line
                                    (fnd_file.LOG,
                                     'GLPSL: Open Period Monitoring Loop.....'
                                    );
                              fnd_file.put_line
                                   (fnd_file.LOG,
                                    'GLPSL: Wait Untill request complete.....'
                                   );

                              LOOP
                                 l_phase := NULL;
                                 l_status := NULL;
                                 l_dev_phase := NULL;
                                 l_dev_status := NULL;
                                 l_message := NULL;
                                 l_wait_for_request :=
                                    fnd_concurrent.wait_for_request
                                                 (request_id      => l_request_id,
                                                  INTERVAL        => 20,
                                                  max_wait        => 5,
                                                  phase           => l_phase,
                                                  status          => l_status,
                                                  dev_phase       => l_dev_phase,
                                                  dev_status      => l_dev_status,
                                                  MESSAGE         => l_message
                                                 );
                                 EXIT WHEN l_phase = 'Completed';
                              END LOOP;

                              fnd_file.put_line (fnd_file.LOG,
                                                    'GLPSL: Phase    : '
                                                 || l_phase
                                                 || '  '
                                                 || 'Status    : '
                                                 || l_status
                                                );
                           ELSE
                              fnd_file.put_line
                                              (fnd_file.LOG,
                                               'GLPSL: Request Not Submitted'
                                              );
                           END IF;

                           FOR c IN c_check_open_status_rec (c2.ledger_id,
                                                             l_apps_id,
                                                             c2.period_name
                                                            )
                           LOOP
                              l_closing_status := c.closing_status;
                              fnd_file.put_line
                                              (fnd_file.LOG,
                                                  'GLPSL: CLOSING STATUS OF '
                                               || c2.period_name
                                               || ' IS '
                                               || l_closing_status
                                              );
                              fnd_file.put_line (fnd_file.LOG, '');
                           END LOOP;

                           IF l_closing_status <> 'O'
                           THEN
                              l_con_status := 'FAILURE';
                              l_process_status_msg :=
                                    'GLPSE: Execution Failed in Open Period '
                                 || c2.period_name
                                 || ' of Ledger '
                                 || c1.short_name;
                              fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSE: Error and Exiting From Open Period Loop'
                                 );
                              fnd_file.put_line (fnd_file.LOG,
                                                    'GLPSE: Error IN '
                                                 || c2.period_name
                                                 || ' Period of '
                                                 || c1.NAME
                                                );
                              EXIT;
                           END IF;
                        ELSE
                           fnd_file.put_line
                              (fnd_file.LOG,
                                  'GLPSL: There Are No periods To Process for '
                               || c1.NAME
                              );
                        END IF;
                     END LOOP;

                     IF l_closing_status <> 'O'
                     THEN
                        fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSE: Error and Exiting From Ledger Loop'
                                 );
                        EXIT;
                     END IF;

------------********************************************************************---------------
                          --**Closing Period Beyond the Given Date Range**--
                     FOR c3 IN c_get_period_close_rec (l_apps_id,
                                                       'O',
                                                       c1.ledger_id,
                                                       p_start_date,
                                                       p_end_date
                                                      )
                     LOOP
                        IF c3.period_name IS NOT NULL
                        THEN
                           fnd_file.put_line
                              (fnd_file.LOG,
                               '--**Closing Period Beyond the Given Date Range**--'
                              );
                           fnd_file.put_line (fnd_file.LOG, '');
                           fnd_file.put_line
                              (fnd_file.LOG,
                               'GLPSL: Nullifying request_id for open period Process'
                              );
                           l_request_id := NULL;
                           fnd_file.put_line
                              (fnd_file.LOG,
                                  'GLPSL: Submit the Open Period request for the Period of '
                               || c3.period_name
                              );
                           fnd_file.put_line
                                         (fnd_file.LOG,
                                          'GLPSL: Submit Concurrent GLOCPP...'
                                         );
                           l_request_id :=
                              fnd_request.submit_request ('SQLGL',
                                                          'GLOCPP',
                                                          '',
                                                          '',
                                                          FALSE,
                                                          c1.NAME,
                                                          l_access_set_id,
                                                          c3.ledger_id,
                                                          c3.period_name,
                                                          'N',
                                                          'C',
                                                          c3.application_id,
                                                          CHR (0),
                                                          '','','','','','','','','','',
							  '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '','','','','','','','','','',
                                                          '',''
                                                         );
                           COMMIT;
                           fnd_file.put_line
                                        (fnd_file.LOG,
                                         'GLPSL: Commit to get the Request ID'
                                        );
                           fnd_file.put_line (fnd_file.LOG,
                                                 'GLPSL: Request ID : '
                                              || l_request_id
                                             );
                           fnd_file.put_line (fnd_file.LOG, '');

                           IF l_request_id > 0
                           THEN
    --------------------------------------------------
--**Monitoring Request Status for Close Period**--
    --------------------------------------------------
                              fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSL: Monitoring Request Status on Close Period'
                                 );
                              fnd_file.put_line
                                   (fnd_file.LOG,
                                    'GLPSL: Wait Untill request complete.....'
                                   );

                              LOOP
                                 l_phase := NULL;
                                 l_status := NULL;
                                 l_dev_phase := NULL;
                                 l_dev_status := NULL;
                                 l_message := NULL;
                                 l_wait_for_request :=
                                    fnd_concurrent.wait_for_request
                                                 (request_id      => l_request_id,
                                                  INTERVAL        => 20,
                                                  max_wait        => 5,
                                                  phase           => l_phase,
                                                  status          => l_status,
                                                  dev_phase       => l_dev_phase,
                                                  dev_status      => l_dev_status,
                                                  MESSAGE         => l_message
                                                 );
                                 EXIT WHEN l_phase = 'Completed';
                              END LOOP;

                              fnd_file.put_line (fnd_file.LOG,
                                                    'GLPSL: Phase    : '
                                                 || l_phase
                                                 || '  '
                                                 || 'Status    : '
                                                 || l_status
                                                );
                           ELSE
                              fnd_file.put_line
                                              (fnd_file.LOG,
                                               'GLPSE : Reuest Not Submitted'
                                              );
                           END IF;

                           FOR c IN c_check_open_status_rec (c3.ledger_id,
                                                             l_apps_id,
                                                             c3.period_name
                                                            )
                           LOOP
                              l_closing_status := c.closing_status;
                              fnd_file.put_line
                                              (fnd_file.LOG,
                                                  'GLPSL: CLOSING STATUS OF '
                                               || c3.period_name
                                               || ' IS '
                                               || l_closing_status
                                              );
                              fnd_file.put_line (fnd_file.LOG, '');
                           END LOOP;

                           IF l_closing_status <> 'C'
                           THEN
                              --
                              l_con_status := 'FAILURE';
                              l_process_status_msg :=
                                    'GLPSE: Execution Failed in Open Period '
                                 || c3.period_name
                                 || ' of Ledger '
                                 || c1.short_name;
                              fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSE: Error and Exiting From Open Period Loop'
                                 );
                              fnd_file.put_line (fnd_file.LOG,
                                                    'GLPSE: Error IN '
                                                 || c3.period_name
                                                 || ' Period of '
                                                 || c1.NAME
                                                );
                              fnd_file.put_line
                                 (fnd_file.LOG,
                                  'GLPSE: Error and Exiting From Close Period Loop'
                                 );
                              EXIT;
                           END IF;

                           l_closing_status := 'O';
                        ELSE
                           fnd_file.put_line
                              (fnd_file.LOG,
                                  'GLPSE: There Are No Periods To Close for '
                               || c1.NAME
                              );
                        END IF;

                        fnd_file.put_line
                                       (fnd_file.LOG,
                                        'GLPSL: END of Close Period Loop.....'
                                       );
                     END LOOP;
--IF l_closing_status <> 'C' THEN
--fnd_file.put_line( fnd_file.log,'Error and Exiting From Ledger Loop');
--EXIT;
--END IF;
                  ELSE
                     fnd_file.put_line
                             (fnd_file.LOG,
                              'GLPSE: There are No Ledger Records To Process'
                             );
                  END IF;

                  fnd_file.put_line (fnd_file.LOG, '');
               END LOOP;

               IF l_con_status = 'FAILURE'
               THEN
                  retcode := 2;
                  x_return_status := 'E';
                  l_be_message := l_process_status_msg;
                  fnd_file.put_line (fnd_file.LOG, 'TRANSACTION FAILURE');
               ELSE
                  l_con_status := 'SUCCESS';
                  l_be_message :=
                        'Open Period Synchronization Process Successfully Completed for Ledger '
                     || p_ledger_short_name
                     || ' Date Range Between '
                     || p_start_date
                     || ' and '
                     || p_end_date;
                  fnd_file.put_line (fnd_file.LOG, 'SUCESSFULL TRANSACTION');
               END IF;
/*fnd_file.put_line( fnd_file.log,'');

fnd_file.put_line( fnd_file.log,'GLPSL: **** RAISING '||l_con_Status||' BUSINESS EVENT ****');


gl_business_events.raise(
p_event_name       => 'oracle.apps.gl.ProcessPeriodStatus.complete',
p_event_key        => to_char(l_conc_request_id),
p_parameter_name1  => 'STATUS',
p_parameter_value1 => l_con_Status,
p_parameter_name2  => 'STATUS MESSAGE',
p_parameter_value2 => l_be_message);*/--commented by Vamshi
            ELSE
               retcode := 2;
               x_return_status := 'E';
               errbuf :=
                  'Given Start Date/ End Date Does not Match with the EBS Periods';
               fnd_file.put_line
                  (fnd_file.LOG,
                   'GLPSE: Given Start Date/ End Date Does not Match with the EBS Periods'
                  );
            END IF;
         ELSE
            retcode := 2;
            x_return_status := 'E';
            errbuf := 'Strat Date is Greater Than End Date';
            fnd_file.put_line
                    (fnd_file.LOG,
                     'GLPSE: Given Start Date is Greater than Given End Date'
                    );
         END IF;
      ELSE
         retcode := 2;
         x_return_status := 'E';
         errbuf := 'Ledger short name is not valid';
         fnd_file.put_line (fnd_file.LOG,
                            'GLPSE: Given Ledger Short Name is not Valid'
                           );
      END IF;

      fnd_file.put_line (fnd_file.LOG, '');
      fnd_file.put_line
         (fnd_file.LOG,
          '+---------------------------------------------------------------------------+'
         );
      fnd_file.put_line
         (fnd_file.LOG,
          '+----------------------------------END--------------------------------------+'
         );
      fnd_file.put_line
         (fnd_file.LOG,
          '+---------------------------------------------------------------------------+'
         );
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         retcode := 2;
         x_return_status := 'E';
         fnd_file.put_line (fnd_file.LOG, SQLERRM);
         errbuf := fnd_message.get_string ('GL', 'GLPSE: Unexpected Error');
         fnd_file.put_line (fnd_file.LOG, '');
         fnd_file.put_line
            (fnd_file.LOG,
             '+---------------------------------------------------------------------------+'
            );
         fnd_file.put_line
            (fnd_file.LOG,
             '+----------------------------------END--------------------------------------+'
            );
         fnd_file.put_line
            (fnd_file.LOG,
             '+---------------------------------------------------------------------------+'
            );
   END period_status_sync;
------------********************************************************************---------------
END gl_period_status_sync_pub;
------------********************************************************************---------------
------------********************************************************************---------------

/
