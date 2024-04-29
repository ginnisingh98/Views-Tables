--------------------------------------------------------
--  DDL for Package Body XXAH_CUST_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_CUST_INTERFACE_PKG" 
IS
  /***************************************************************************
  *                           IDENTIFICATION
  *                           ==============
  * NAME              : XXAH_CUST_INTERFACE_PKG
  * DESCRIPTION       : PACKAGE TO Customer Interface
  ****************************************************************************
  *                           CHANGE HISTORY
  *                           ==============
  * DATE             VERSION     DONE BY
  * 17-JAN-2022        1.0       Karthick B    Initial
  ****************************************************************************/
  PROCEDURE P_MAIN(
      p_retcode OUT NUMBER,
      p_errbuff OUT VARCHAR2)
  IS
    g_request_id  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_REQUEST_ID  NUMBER := 0;
    l_last_update DATE;
    l_timestamp   DATE   := SYSDATE;
    l_count       NUMBER := 0;
    CURSOR c_rec (l_last_update_date DATE)
    IS
      SELECT xecc.*
      FROM XXAH_CUSTOMER_PS_VW xecc
      WHERE bill_to_flag = 'Primary' and ship_to_flag = 'Primary'
	  and last_update_date >= l_last_update_date;
  BEGIN
    -- l_timestamp := SYSDATE - 1;
    BEGIN
      SELECT MAX (CONC_REQUEST_ID) INTO l_REQUEST_ID FROM XXAH_CUST_INTF_PARAMETERS;
    EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error -CONC_REQUEST_ID ' || SQLCODE || ' -ERROR- ' || SQLERRM);
      FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
      l_REQUEST_ID := NULL;
    END;
    IF l_REQUEST_ID IS NOT NULL THEN
      SELECT TIMESTAMP
      INTO l_timestamp
      FROM XXAH_CUST_INTF_PARAMETERS
      WHERE CONC_REQUEST_ID = l_REQUEST_ID;
    ELSE
      l_timestamp := NULL;
    END IF;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_timestamp ' || l_timestamp);
    IF l_timestamp IS NOT NULL THEN
      FOR r_rec IN c_rec (l_timestamp)
      LOOP
        EXIT
      WHEN c_rec%NOTFOUND;
        IF c_rec%ROWCOUNT > 0 THEN
          BEGIN
            INSERT
            INTO XXAH_CUSTOMER_PS_INT
              (
                CUSTOMER_ID,
                CUSTOMER_NAME,
                CUSTOMER_ACCOUNT_NUMBER,
                PEOPLESOFT_NUMBER,
                CUSTOMER_STATUS,
                ACCOUNT_STATUS,
                SITE_STATUS,
                ORG_ID,
                OPERATING_UNIT,
                BILL_TO_FLAG,
                SHIP_TO_FLAG,
                ADDRESS1,
                ADDRESS2,
                ADDRESS3,
                ADDRESS4,
                CITY,
                POSTAL_CODE,
                STATE,
                COUNTRY,
                CURRENCY,
                PAYMENT_TERM,
                KVK_NUMBER,
                VAT_ID,
                TAX_CODE,
                WEB_URL,
                WEB_URL_1,
                IBAN,
                Status,
                LAST_UPDATE_DATE,
                CREATION_DATE,
                Created_by
              )
              VALUES
              (
                r_rec.Registry_ID,
                r_rec.CUSTOMER_NAME,
                r_rec.CUSTOMER_ACCOUNT_NUMBER,
                r_rec.PEOPLESOFT_NUMBER,
                r_rec.CUSTOMER_STATUS,
                r_rec.Account_status,
                r_rec.site_status,
                r_rec.org_id,
                r_rec.Operating_Unit,
                r_rec.BILL_TO_FLAG,
                r_rec.SHIP_TO_FLAG,
                r_rec.ADDRESS1,
                r_rec.ADDRESS2,
                r_rec.ADDRESS3,
                r_rec.ADDRESS4,
                r_rec.CITY,
                r_rec.POSTAL_CODE,
                r_rec.STATE,
                r_rec.COUNTRY,
                r_rec.Currency,
                r_rec.PAYMENT_TERM,
                r_rec.KvK_Number,
                r_rec.VAT_RGSTRN_ID,
                r_rec.TAX_CODE,
                r_rec.BILLING_MAIL_ID,
                r_rec.BILLING_MAIL_ID_1,
                r_rec.IBAN,
                'N',
                r_rec.Last_update_date,
                r_rec.Creation_date,
                '1234'
              );
            COMMIT;
            fnd_file.PUT_LINE ( fnd_file.LOG, r_rec.Registry_ID || ':      ' || r_rec.PEOPLESOFT_NUMBER || ' inserted successfully');
            l_count := c_rec%ROWCOUNT;
          EXCEPTION
          WHEN OTHERS THEN
            fnd_file.PUT_LINE ( fnd_file.LOG, 'Error => ' || SQLERRM || r_rec.Registry_ID || ':      ' || r_rec.PEOPLESOFT_NUMBER);
          END;
        END IF;
      END LOOP;
	  FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
      fnd_file.PUT_LINE (fnd_file.LOG, 'Total Processed Records : ' || l_count);
	  FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
    END IF;
    BEGIN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Executing procedure XXAH_CUST_INTF_PARAMETERS ');
      XXAH_CUST_INTF_PARAMETERS (g_request_id);
      --FND_FILE.PUT_LINE (FND_FILE.LOG, 'Executing procedure P_REPORT ');
      --P_REPORT (g_request_id);
      --<Archive 2 Months back data>--
      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Executing procedure P_ARCHIVE_DATA ');
      P_ARCHIVE_DATA;
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.PUT_LINE ( fnd_file.LOG, 'Error => ' || SQLERRM || 'Data Purging process');
    END;
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
    FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error at P_MAIN ' || SQLCODE || ' -ERROR- ' || SQLERRM || '    ' || l_count);
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
  END P_MAIN;
  PROCEDURE P_ARCHIVE_DATA
  IS
    la_count NUMBER := 0;
    CURSOR c_arc_data
    IS
      SELECT *
      FROM XXAH_CUSTOMER_PS_INT
      WHERE TRUNC (LAST_UPDATE_DATE) < TRUNC (ADD_MONTHS (SYSDATE, -2));
  BEGIN
    FOR r_arc_data IN c_arc_data
    LOOP
      IF c_arc_data%ROWCOUNT > 0 THEN
        INSERT
        INTO XXAH_CUSTOMER_PS_INT_HISTORY
          (
            CUSTOMER_ID,
            CUSTOMER_NAME,
            CUSTOMER_ACCOUNT_NUMBER,
            PEOPLESOFT_NUMBER,
            CUSTOMER_STATUS,
            ACCOUNT_STATUS,
            SITE_STATUS,
            ORG_ID,
            OPERATING_UNIT,
            PARTY_SITE_NUMBER,
            BILL_TO_FLAG,
            SHIP_TO_FLAG,
            LOCATION,
            PRIMARY_FLAG,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            ADDRESS4,
            CITY,
            POSTAL_CODE,
            STATE,
            COUNTRY,
            CURRENCY,
            PAYMENT_TERM,
            KVK_NUMBER,
            VAT_ID,
            WEB_URL,
            WEB_URL_1,
            IBAN,
            TAX_CODE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ATTRIBUTE16,
            ATTRIBUTE17,
            ATTRIBUTE18,
            ATTRIBUTE19,
            ATTRIBUTE20,
            GLOBAL_ATTRIBUTE_CATEGORY,
            GLOBAL_ATTRIBUTE1,
            GLOBAL_ATTRIBUTE2,
            GLOBAL_ATTRIBUTE3,
            GLOBAL_ATTRIBUTE4,
            GLOBAL_ATTRIBUTE5,
            GLOBAL_ATTRIBUTE6,
            GLOBAL_ATTRIBUTE7,
            GLOBAL_ATTRIBUTE8,
            GLOBAL_ATTRIBUTE9,
            GLOBAL_ATTRIBUTE10,
            GLOBAL_ATTRIBUTE11,
            GLOBAL_ATTRIBUTE12,
            GLOBAL_ATTRIBUTE13,
            GLOBAL_ATTRIBUTE14,
            GLOBAL_ATTRIBUTE15,
            GLOBAL_ATTRIBUTE16,
            GLOBAL_ATTRIBUTE17,
            GLOBAL_ATTRIBUTE18,
            GLOBAL_ATTRIBUTE19,
            GLOBAL_ATTRIBUTE20,
            STATUS,
            WM_RESPONSE_MSG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY
          )
          VALUES
          (
            r_arc_data.CUSTOMER_ID,
            r_arc_data.CUSTOMER_NAME,
            r_arc_data.CUSTOMER_ACCOUNT_NUMBER,
            r_arc_data.PEOPLESOFT_NUMBER,
            r_arc_data.CUSTOMER_STATUS,
            r_arc_data.ACCOUNT_STATUS,
            r_arc_data.SITE_STATUS,
            r_arc_data.ORG_ID,
            r_arc_data.OPERATING_UNIT,
            r_arc_data.PARTY_SITE_NUMBER,
            r_arc_data.BILL_TO_FLAG,
            r_arc_data.SHIP_TO_FLAG,
            r_arc_data.LOCATION,
            r_arc_data.PRIMARY_FLAG,
            r_arc_data.ADDRESS1,
            r_arc_data.ADDRESS2,
            r_arc_data.ADDRESS3,
            r_arc_data.ADDRESS4,
            r_arc_data.CITY,
            r_arc_data.POSTAL_CODE,
            r_arc_data.STATE,
            r_arc_data.COUNTRY,
            r_arc_data.CURRENCY,
            r_arc_data.PAYMENT_TERM,
            r_arc_data.KVK_NUMBER,
            r_arc_data.VAT_ID,
            r_arc_data.WEB_URL,
            r_arc_data.WEB_URL_1,
            r_arc_data.IBAN,
            r_arc_data.TAX_CODE,
            r_arc_data.ATTRIBUTE_CATEGORY,
            r_arc_data.ATTRIBUTE1,
            r_arc_data.ATTRIBUTE2,
            r_arc_data.ATTRIBUTE3,
            r_arc_data.ATTRIBUTE4,
            r_arc_data.ATTRIBUTE5,
            r_arc_data.ATTRIBUTE6,
            r_arc_data.ATTRIBUTE7,
            r_arc_data.ATTRIBUTE8,
            r_arc_data.ATTRIBUTE9,
            r_arc_data.ATTRIBUTE10,
            r_arc_data.ATTRIBUTE11,
            r_arc_data.ATTRIBUTE12,
            r_arc_data.ATTRIBUTE13,
            r_arc_data.ATTRIBUTE14,
            r_arc_data.ATTRIBUTE15,
            r_arc_data.ATTRIBUTE16,
            r_arc_data.ATTRIBUTE17,
            r_arc_data.ATTRIBUTE18,
            r_arc_data.ATTRIBUTE19,
            r_arc_data.ATTRIBUTE20,
            r_arc_data.GLOBAL_ATTRIBUTE_CATEGORY,
            r_arc_data.GLOBAL_ATTRIBUTE1,
            r_arc_data.GLOBAL_ATTRIBUTE2,
            r_arc_data.GLOBAL_ATTRIBUTE3,
            r_arc_data.GLOBAL_ATTRIBUTE4,
            r_arc_data.GLOBAL_ATTRIBUTE5,
            r_arc_data.GLOBAL_ATTRIBUTE6,
            r_arc_data.GLOBAL_ATTRIBUTE7,
            r_arc_data.GLOBAL_ATTRIBUTE8,
            r_arc_data.GLOBAL_ATTRIBUTE9,
            r_arc_data.GLOBAL_ATTRIBUTE10,
            r_arc_data.GLOBAL_ATTRIBUTE11,
            r_arc_data.GLOBAL_ATTRIBUTE12,
            r_arc_data.GLOBAL_ATTRIBUTE13,
            r_arc_data.GLOBAL_ATTRIBUTE14,
            r_arc_data.GLOBAL_ATTRIBUTE15,
            r_arc_data.GLOBAL_ATTRIBUTE16,
            r_arc_data.GLOBAL_ATTRIBUTE17,
            r_arc_data.GLOBAL_ATTRIBUTE18,
            r_arc_data.GLOBAL_ATTRIBUTE19,
            r_arc_data.GLOBAL_ATTRIBUTE20,
            r_arc_data.STATUS,
            r_arc_data.WM_RESPONSE_MSG,
            r_arc_data.LAST_UPDATE_DATE,
            r_arc_data.LAST_UPDATED_BY,
            r_arc_data.CREATION_DATE,
            r_arc_data.CREATED_BY
          );
        COMMIT;
        fnd_file.PUT_LINE ( fnd_file.LOG, r_arc_data.CUSTOMER_ID || ':      ' || r_arc_data.PEOPLESOFT_NUMBER || ' Archived successfully');
        la_count := c_arc_data%ROWCOUNT;
      END IF;
    END LOOP;
    DELETE
    FROM XXAH_CUSTOMER_PS_INT
    WHERE TRUNC (LAST_UPDATE_DATE) < TRUNC (ADD_MONTHS (SYSDATE, -2));
    COMMIT;
	FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
    fnd_file.PUT_LINE (fnd_file.LOG, 'Total archived records : ' || la_count);
	FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
    FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error at P_ARCHIVE_DATA ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
  END P_ARCHIVE_DATA;
  PROCEDURE XXAH_CUST_INTF_PARAMETERS(
      l_req_id IN NUMBER)
  IS
  BEGIN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Inserting Last run record into XXAH_CUST_INTF_PARAMETERS');
    INSERT
    INTO XXAH_CUST_INTF_PARAMETERS
      (
        PARM_CODE,
        PARM_DESCRIPTION,
        TYPE,
        TIMESTAMP,
        NUMERIC,
        ALPHANUMERIC,
        CONC_REQUEST_ID
      )
      VALUES
      (
        'TIMESTAMP_LAST_RUN_CUST_INT '
        || l_req_id,
        ' The last run timestamp of Customer Interface',
        'D',
        SYSDATE,
        NULL,
        NULL,
        l_req_id
      );
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
    FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error at XXAH_CUST_INTF_PARAMETERS ' || SQLCODE || ' -ERROR- ' || SQLERRM);
    FND_FILE.PUT_LINE ( FND_FILE.LOG, '+---------------------------------------------------------------------------+');
  END XXAH_CUST_INTF_PARAMETERS;
END XXAH_CUST_INTERFACE_PKG;

/
