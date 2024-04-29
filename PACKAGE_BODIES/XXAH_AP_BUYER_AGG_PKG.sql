--------------------------------------------------------
--  DDL for Package Body XXAH_AP_BUYER_AGG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_BUYER_AGG_PKG" 
IS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_BUYER_AGG_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Interface
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 30-APR-2015        1.0       Sunil Thamke    Initial
   * 03-May-2017        1.1       Sunil Thamke    RFC0101 Contract interface eBS-Coupa
   * 09-JUN-2017        1.2       Sunil Thamke    VAT_REGISTRATION_NUM
   * 23-OCT-2020        1.3          Karthick B      RFCC19-311 Add attributes to Contract staging table
   ****************************************************************************/
   PROCEDURE P_MAIN (p_retcode OUT NUMBER, p_errbuff OUT VARCHAR2)
   IS
      g_request_id    NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
      l_rec_count     NUMBER;
      l_REQUEST_ID    NUMBER := NULL;
      l_last_update   DATE;
      l_timestamp     DATE;
      l_cur_name      VARCHAR (10);
      l_count         NUMBER;

      CURSOR c_rec (l_last_update_date DATE)
      IS
         SELECT xecc.*
           FROM XXAH_EBS_COUPA_CONT_VW xecc
          WHERE last_update_date >= l_last_update_date;

      CURSOR c_rec_first (l_last_updt_date DATE)
      IS
         SELECT xecc.*
           FROM XXAH_EBS_COUPA_CONT_VW xecc;
   BEGIN
      l_last_update := SYSDATE;

      BEGIN
         SELECT MAX (CONC_REQUEST_ID)
           INTO l_REQUEST_ID
           FROM XXAH_EBS_PARAMETERS;
      EXCEPTION
         WHEN OTHERS
         THEN
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               '+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               'Error -CONC_REQUEST_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
            FND_FILE.PUT_LINE (
               FND_FILE.LOG,
               '+---------------------------------------------------------------------------+');
            l_REQUEST_ID := NULL;
      END;

      IF l_REQUEST_ID IS NOT NULL
      THEN
         SELECT TIMESTAMP
           INTO l_timestamp
           FROM XXAH_EBS_PARAMETERS
          WHERE CONC_REQUEST_ID = l_REQUEST_ID;
      ELSE
         l_timestamp := NULL;
      END IF;

      FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_timestamp ' || l_timestamp);

      IF l_timestamp IS NULL
      THEN
         FOR r_rec_first IN c_rec_first (l_timestamp)
         LOOP
            EXIT WHEN c_rec_first%NOTFOUND;

            fnd_file.PUT_LINE (
               fnd_file.LOG,
               'Total records for processing : ' || c_rec_first%ROWCOUNT);
            FND_FILE.PUT_LINE (FND_FILE.LOG, '5');

            IF c_rec_first%ROWCOUNT > 0
            THEN
               BEGIN
                  INSERT
                    INTO XXAH_EBS_COUPA_BUY_CONT (AGREEMENT_NUMBER,
                                                  SUPPLIER_NUMBER,
                                                  SUPPLIER_NAME,
                                                  BUYER_NAME,        --<1.1>--
                                                  BUYER_CONTACT,
                                                  DESCRIPTION,       --<1.1>--
                                                  VAT_REGISTRATION_NUM, --<1.2>--
                                                  SUPPLIER_SITE_ID,
                                                  SUPPLIER_SITE_NAME,
                                                  SUPPLIER_TYPE,
                                                  SUPPLIER_SITE_TYPE,
                                                  SITE_COUPA_CONTENT_GROUP,
                                                  SUPPLIER_END_DATE_ACTIVE,
                                                  SUPPLIER_SITE_INACTIVE_DATE,
                                                  AGREEMENT_START_DATE,
                                                  AGREEMENT_END_DATE,
                                                  AGREEMENT_STATUS,
                                                  CURRENCY_CODE,
                                                  CATEGORY_NAME,
                                                  SUB_CATEGORY_NAME,
                                                  STATUS_FLAG,
                                                  CREATED_BY,
                                                  CREATION_DATE,
                                                  LAST_UPDATED_BY,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATE_LOGIN,
                                                  CONC_REQUEST_ID)
                  VALUES (r_rec_first.AGREEMENT_NUMBER,
                          r_rec_first.SUPPLIER_NUMBER,
                          r_rec_first.SUPPLIER_NAME,
                          r_rec_first.BUYER_NAME,                    --<1.1>--
                          r_rec_first.BUYER_CONTACT,
                          r_rec_first.DESCRIPTION,                   --<1.1>--
                          r_rec_first.VAT_REGISTRATION_NUM,          --<1.2>--
                          r_rec_first.SUPPLIER_SITE_ID,
                          r_rec_first.SUPPLIER_SITE_NAME,
                          r_rec_first.SUPPLIER_TYPE,
                          r_rec_first.SUPPLIER_SITE_TYPE,
                          r_rec_first.SITE_COUPA_CONTENT_GROUP,
                          TRUNC (r_rec_first.SUPPLIER_END_DATE_ACTIVE),
                          TRUNC (r_rec_first.SUPPLIER_SITE_INACTIVE_DATE),
                          TRUNC (r_rec_first.AGREEMENT_START_DATE),
                          TRUNC (r_rec_first.AGREEMENT_END_DATE),
                          r_rec_first.AGREEMENT_STATUS,
                          r_rec_first.CURRENCY_CODE,
                          r_rec_first.CATEGORY_NAME,
                          r_rec_first.SUB_CATEGORY_NAME,
                          'U',
                          TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                          SYSDATE,
                          TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                          SYSDATE,
                          TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                          g_request_id);

                  COMMIT;
                  fnd_file.PUT_LINE (
                     fnd_file.LOG,
                        'PO#'
                     || r_rec_first.AGREEMENT_NUMBER
                     || ' inserted successfully');
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Error => '
                        || SQLERRM
                        || 'for PO#'
                        || r_rec_first.AGREEMENT_NUMBER);
               END;
            END IF;
         END LOOP;
      ---------
      ELSE
         FOR r_rec IN c_rec (l_timestamp)
         LOOP
            --EXIT WHEN c_rec%NOTFOUND;

            fnd_file.PUT_LINE (
               fnd_file.LOG,
               'Total c_rec records for processing : ' || c_rec%ROWCOUNT);

            IF c_rec%ROWCOUNT > 0
            THEN
               --<Insert Check>--
               SELECT COUNT (*)
                 INTO l_rec_count
                 FROM XXAH_EBS_COUPA_BUY_CONT
                WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;

               IF l_rec_count = 0 OR l_rec_count IS NULL
               THEN
                  BEGIN
                     INSERT
                       INTO XXAH_EBS_COUPA_BUY_CONT (
                               AGREEMENT_NUMBER,
                               SUPPLIER_NUMBER,
                               SUPPLIER_NAME,
                               BUYER_NAME,                           --<1.1>--
                               BUYER_CONTACT,
                               DESCRIPTION,                          --<1.1>--
                               VAT_REGISTRATION_NUM,                 --<1.2>--
                               SUPPLIER_SITE_ID,
                               SUPPLIER_SITE_NAME,
                               SUPPLIER_TYPE,
                               SUPPLIER_SITE_TYPE,
                               SITE_COUPA_CONTENT_GROUP,
                               SUPPLIER_END_DATE_ACTIVE,
                               SUPPLIER_SITE_INACTIVE_DATE,
                               AGREEMENT_START_DATE,
                               AGREEMENT_END_DATE,
                               AGREEMENT_STATUS,
                               CURRENCY_CODE,
                               CATEGORY_NAME,
                               SUB_CATEGORY_NAME,
                               STATUS_FLAG,
                               CREATED_BY,
                               CREATION_DATE,
                               LAST_UPDATED_BY,
                               LAST_UPDATE_DATE,
                               LAST_UPDATE_LOGIN,
                               CONC_REQUEST_ID)
                     VALUES (r_rec.AGREEMENT_NUMBER,
                             r_rec.SUPPLIER_NUMBER,
                             r_rec.SUPPLIER_NAME,
                             r_rec.BUYER_NAME,                       --<1.1>--
                             r_rec.BUYER_CONTACT,
                             r_rec.DESCRIPTION,                      --<1.1>--
                             r_rec.VAT_REGISTRATION_NUM,             --<1.2>--
                             r_rec.SUPPLIER_SITE_ID,
                             r_rec.SUPPLIER_SITE_NAME,
                             r_rec.SUPPLIER_TYPE,
                             r_rec.SUPPLIER_SITE_TYPE,
                             r_rec.SITE_COUPA_CONTENT_GROUP,
                             TRUNC (r_rec.SUPPLIER_END_DATE_ACTIVE),
                             TRUNC (r_rec.SUPPLIER_SITE_INACTIVE_DATE),
                             TRUNC (r_rec.AGREEMENT_START_DATE),
                             TRUNC (r_rec.AGREEMENT_END_DATE),
                             r_rec.AGREEMENT_STATUS,
                             r_rec.CURRENCY_CODE,
                             r_rec.CATEGORY_NAME,
                             r_rec.SUB_CATEGORY_NAME,
                             'U',
                             TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                             SYSDATE,
                             TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                             SYSDATE,
                             TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                             g_request_id);

                     COMMIT;
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'PO#'
                        || r_rec.AGREEMENT_NUMBER
                        || ' inserted successfully');
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        fnd_file.PUT_LINE (
                           fnd_file.LOG,
                              'Error => '
                           || SQLERRM
                           || 'for PO#'
                           || r_rec.AGREEMENT_NUMBER);
                  END;
               ELSE
                  fnd_file.PUT_LINE (
                     fnd_file.LOG,
                        'Executing update check for PO#'
                     || r_rec.AGREEMENT_NUMBER);
                  --<Check SUPPLIER_NUMBER>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_NUMBER = r_rec.SUPPLIER_NUMBER;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Number for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_NUMBER = r_rec.SUPPLIER_NUMBER,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_NAME>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_NAME = r_rec.SUPPLIER_NAME;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Name for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_NAME = r_rec.SUPPLIER_NAME,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<1.1>-- --<Check BUYER_NAME>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND BUYER_NAME = r_rec.BUYER_NAME;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Buyer Name for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET BUYER_NAME = r_rec.BUYER_NAME,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<1.1>-- --<Check BUYER_CONTACT>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND BUYER_CONTACT = r_rec.BUYER_CONTACT;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Buyer Name for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET BUYER_CONTACT = r_rec.BUYER_CONTACT,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;


                  --<1.1>-- --<Check DESCRIPTION>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND DESCRIPTION = r_rec.DESCRIPTION;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating PO DESCRIPTION for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET DESCRIPTION = r_rec.DESCRIPTION,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;


                  --<1.2>-- --<Check VAT_REGISTRATION_NUM>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND VAT_REGISTRATION_NUM =
                                r_rec.VAT_REGISTRATION_NUM;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating PO VAT_REGISTRATION_NUM for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET VAT_REGISTRATION_NUM = r_rec.VAT_REGISTRATION_NUM,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_SITE_ID>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_SITE_ID = r_rec.SUPPLIER_SITE_ID;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Agreement Number for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_SITE_ID = r_rec.SUPPLIER_SITE_ID,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_SITE_NAME>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_SITE_NAME = r_rec.SUPPLIER_SITE_NAME;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Site Name for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_SITE_NAME = r_rec.SUPPLIER_SITE_NAME,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_TYPE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_TYPE = r_rec.SUPPLIER_TYPE;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Type for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_TYPE = r_rec.SUPPLIER_TYPE,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_SITE_TYPE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUPPLIER_SITE_TYPE = r_rec.SUPPLIER_SITE_TYPE;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Type for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_SITE_TYPE = r_rec.SUPPLIER_SITE_TYPE,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SITE_COUPA_CONTENT_GROUP>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SITE_COUPA_CONTENT_GROUP =
                                r_rec.SITE_COUPA_CONTENT_GROUP;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating Supplier Type for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SITE_COUPA_CONTENT_GROUP =
                               r_rec.SITE_COUPA_CONTENT_GROUP,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_END_DATE_ACTIVE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND TRUNC (SUPPLIER_END_DATE_ACTIVE) =
                                TRUNC (r_rec.SUPPLIER_END_DATE_ACTIVE);

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating SUPPLIER_END_DATE_ACTIVE for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_END_DATE_ACTIVE =
                               TRUNC (r_rec.SUPPLIER_END_DATE_ACTIVE),
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUPPLIER_SITE_INACTIVE_DATE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND TRUNC (SUPPLIER_SITE_INACTIVE_DATE) =
                                TRUNC (r_rec.SUPPLIER_SITE_INACTIVE_DATE);

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating SUPPLIER_SITE_INACTIVE_DATE for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUPPLIER_SITE_INACTIVE_DATE =
                               TRUNC (r_rec.SUPPLIER_SITE_INACTIVE_DATE),
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check AGREEMENT_START_DATE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND TRUNC (AGREEMENT_START_DATE) =
                                TRUNC (r_rec.AGREEMENT_START_DATE);

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating AGREEMENT_START_DATE for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET AGREEMENT_START_DATE =
                               TRUNC (r_rec.AGREEMENT_START_DATE),
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check AGREEMENT_END_DATE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND TRUNC (AGREEMENT_END_DATE) =
                                TRUNC (r_rec.AGREEMENT_END_DATE);

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating AGREEMENT_END_DATE for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET AGREEMENT_END_DATE =
                               TRUNC (r_rec.AGREEMENT_END_DATE),
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check AGREEMENT_STATUS>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND AGREEMENT_STATUS = r_rec.AGREEMENT_STATUS;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating AGREEMENT_STATUS for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET AGREEMENT_STATUS = r_rec.AGREEMENT_STATUS,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check CURRENCY_CODE>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND CURRENCY_CODE = r_rec.CURRENCY_CODE;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating CURRENCY_CODE for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET CURRENCY_CODE = r_rec.CURRENCY_CODE,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check CATEGORY_NAME>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND CATEGORY_NAME = r_rec.CATEGORY_NAME;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating CATEGORY_NAME for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET CATEGORY_NAME = r_rec.CATEGORY_NAME,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  --<Check SUB_CATEGORY_NAME>--
                  l_count := NULL;

                  SELECT COUNT (*)
                    INTO l_count
                    FROM XXAH_EBS_COUPA_BUY_CONT
                   WHERE     AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER
                         AND SUB_CATEGORY_NAME = r_rec.SUB_CATEGORY_NAME;

                  IF l_count = 0 OR l_count IS NULL
                  THEN
                     fnd_file.PUT_LINE (
                        fnd_file.LOG,
                           'Updating SUB_CATEGORY_NAME for PO#'
                        || r_rec.AGREEMENT_NUMBER);

                     UPDATE XXAH_EBS_COUPA_BUY_CONT
                        SET SUB_CATEGORY_NAME = r_rec.SUB_CATEGORY_NAME,
                            STATUS_FLAG = 'U',
                            LAST_UPDATED_BY =
                               TO_NUMBER (FND_PROFILE.VALUE ('USER_ID')),
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN =
                               TO_NUMBER (FND_PROFILE.VALUE ('LOGIN_ID')),
                            CONC_REQUEST_ID = g_request_id
                      WHERE AGREEMENT_NUMBER = r_rec.AGREEMENT_NUMBER;
                  END IF;

                  COMMIT;
               END IF;
            END IF;
         END LOOP;
      END IF;

      BEGIN
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            'Executing procedure P_EBS_PARAMETERS ');
         P_EBS_PARAMETERS (g_request_id);
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Executing procedure P_REPORT ');
         P_REPORT (g_request_id);
         --<Archive 2 years back data>--
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            'Executing procedure P_ARCHIVE_DATA ');
         P_ARCHIVE_DATA;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Error at P_MAIN ' || SQLCODE || ' -ERROR- ' || SQLERRM);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
   END P_MAIN;

   PROCEDURE P_ARCHIVE_DATA
   IS
      CURSOR c_arc_data
      IS
         SELECT *
           FROM XXAH_EBS_COUPA_BUY_CONT
          WHERE TRUNC (AGREEMENT_END_DATE) <
                   TRUNC (ADD_MONTHS (SYSDATE, -24)); -- Vema changed AGREEMENT_END_DATE from last_update_date
   BEGIN
      FOR r_arc_data IN c_arc_data
      LOOP
         fnd_file.PUT_LINE (
            fnd_file.LOG,
            'Total archive records for processing : ' || c_arc_data%ROWCOUNT);

         IF c_arc_data%ROWCOUNT > 0
         THEN
            INSERT
              INTO XXAH_EBS_COUPA_BC_HISTORY (AGREEMENT_NUMBER,
                                              SUPPLIER_NUMBER,
                                              SUPPLIER_NAME,
                                              BUYER_NAME,            --<1.1>--
                                              DESCRIPTION,           --<1.1>--
                                              VAT_REGISTRATION_NUM,
                                              SUPPLIER_SITE_ID,
                                              SUPPLIER_SITE_NAME,
                                              SUPPLIER_TYPE,
                                              SUPPLIER_END_DATE_ACTIVE,
                                              SUPPLIER_SITE_INACTIVE_DATE,
                                              AGREEMENT_START_DATE,
                                              AGREEMENT_END_DATE,
                                              AGREEMENT_STATUS,
                                              CURRENCY_CODE,
                                              CATEGORY_NAME,
                                              SUB_CATEGORY_NAME,
                                              STATUS_FLAG,
                                              CREATION_DATE,
                                              CREATED_BY,
                                              LAST_UPDATED_BY,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATE_LOGIN,
                                              CONC_REQUEST_ID)
            VALUES (r_arc_data.AGREEMENT_NUMBER,
                    r_arc_data.SUPPLIER_NUMBER,
                    r_arc_data.SUPPLIER_NAME,
                    r_arc_data.BUYER_NAME,                           --<1.1>--
                    r_arc_data.DESCRIPTION,                          --<1.1>--
                    r_arc_data.VAT_REGISTRATION_NUM,                 --<1.2>--
                    r_arc_data.SUPPLIER_SITE_ID,
                    r_arc_data.SUPPLIER_SITE_NAME,
                    r_arc_data.SUPPLIER_TYPE,
                    r_arc_data.SUPPLIER_END_DATE_ACTIVE,
                    r_arc_data.SUPPLIER_SITE_INACTIVE_DATE,
                    r_arc_data.AGREEMENT_START_DATE,
                    r_arc_data.AGREEMENT_END_DATE,
                    r_arc_data.AGREEMENT_STATUS,
                    r_arc_data.CURRENCY_CODE,
                    r_arc_data.CATEGORY_NAME,
                    r_arc_data.SUB_CATEGORY_NAME,
                    r_arc_data.STATUS_FLAG,
                    r_arc_data.CREATION_DATE,
                    r_arc_data.CREATED_BY,
                    r_arc_data.LAST_UPDATED_BY,
                    r_arc_data.LAST_UPDATE_DATE,
                    r_arc_data.LAST_UPDATE_LOGIN,
                    r_arc_data.CONC_REQUEST_ID);

            COMMIT;
         END IF;
      END LOOP;

      DELETE FROM XXAH_EBS_COUPA_BUY_CONT
            WHERE TRUNC (AGREEMENT_END_DATE) <
                     TRUNC (ADD_MONTHS (SYSDATE, -24));

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Error at P_ARCHIVE_DATA ' || SQLCODE || ' -ERROR- ' || SQLERRM);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
   END P_ARCHIVE_DATA;

   PROCEDURE P_EBS_PARAMETERS (l_req_id IN NUMBER)
   IS
   BEGIN
      FND_FILE.PUT_LINE (
         FND_FILE.LOG,
         'Inserting Last run record into XXAH_EBS_PARAMETERS');

      INSERT INTO XXAH_EBS_PARAMETERS (PARM_CODE,
                                       PARM_DESCRIPTION,
                                       TYPE,
                                       TIMESTAMP,
                                       NUMERIC,
                                       ALPHANUMERIC,
                                       CONC_REQUEST_ID)
           VALUES ('TIMESTAMP_LAST_RUN_COUPA_BUYCON ' || l_req_id,
                   ' The last run timestamp of Coupa Buycon job',
                   'D',
                   SYSDATE,
                   NULL,
                   NULL,
                   l_req_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Error at P_EBS_PARAMETERS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            '+---------------------------------------------------------------------------+');
   END P_EBS_PARAMETERS;


   PROCEDURE P_REPORT (l_con_req_id IN NUMBER)
   IS
      CURSOR c_report (l_reqs_id IN NUMBER)
      IS
         SELECT *
           FROM XXAH_EBS_COUPA_BUY_CONT
          WHERE CONC_REQUEST_ID = l_reqs_id;
   BEGIN
      fnd_file.put_line (fnd_file.OUTPUT, '  ');
      fnd_file.put_line (
         fnd_file.OUTPUT,
         ' "Ahold EBS to COUPA ? Interface on Buying Agreements...');
      fnd_file.put_line (
         fnd_file.OUTPUT,
         ' =================================================');
      fnd_file.put_line (fnd_file.OUTPUT, '  ');
      fnd_file.put_line (fnd_file.OUTPUT, '  ');
      fnd_file.put_line (
         fnd_file.OUTPUT,
            'AGREEMENT_NUMBER'
         || ' '
         || 'SUPPLIER_NUMBER'
         || ' '
         || 'SUPPLIER_NAME'
         || ' '
         || 'SUPPLIER_SITE_ID'
         || '    '
         || 'SUPPLIER_SITE_NAME'
         || '        '
         || 'SUPPLIER_TYPE'
         || '    '
         || 'SUPPLIER_END_DATE_ACTIVE'
         || '    '
         || 'SUPPLIER_SITE_INACTIVE_DATE'
         || '        '
         || 'AGREEMENT_START_DATE'
         || '    '
         || 'AGREEMENT_END_DATE'
         || '    '
         || 'AGREEMENT_STATUS'
         || '    '
         || 'CURRENCY_CODE'
         || '    '
         || 'CATEGORY_NAME'
         || '    '
         || 'SUB_CATEGORY_NAME'
         || '    '
         || 'STATUS_FLAG'
         || '        '
         || 'CREATION_DATE'
         || '    '
         || 'LAST_UPDATE_DATE');

      FOR r_report IN c_report (l_con_req_id)
      LOOP
         fnd_file.put_line (
            fnd_file.OUTPUT,
               r_report.AGREEMENT_NUMBER
            || '     '
            || r_report.SUPPLIER_NUMBER
            || '     '
            || r_report.SUPPLIER_NAME
            || '    '
            || r_report.SUPPLIER_SITE_ID
            || ' '
            || r_report.SUPPLIER_SITE_NAME
            || '        '
            || r_report.SUPPLIER_TYPE
            || '    '
            || r_report.SUPPLIER_END_DATE_ACTIVE
            || '        '
            || r_report.SUPPLIER_SITE_INACTIVE_DATE
            || '        '
            || r_report.AGREEMENT_START_DATE
            || '        '
            || r_report.AGREEMENT_END_DATE
            || '    '
            || r_report.AGREEMENT_STATUS
            || '    '
            || r_report.CURRENCY_CODE
            || '    '
            || r_report.CATEGORY_NAME
            || '    '
            || r_report.SUB_CATEGORY_NAME
            || '    '
            || r_report.STATUS_FLAG
            || '        '
            || r_report.CREATION_DATE
            || '    '
            || r_report.LAST_UPDATE_DATE);
      END LOOP;
   END P_REPORT;
END XXAH_AP_BUYER_AGG_PKG;

/
