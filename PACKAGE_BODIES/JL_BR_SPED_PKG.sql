--------------------------------------------------------
--  DDL for Package Body JL_BR_SPED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_SPED_PKG" AS
/* $Header: jlspedab.pls 120.0.12010000.5 2009/08/06 09:53:44 mkandula ship $ */


/*
	Function Name: IS_INVOICE_FINAL.
	Description  : This function will return T - True if the country code is not Brazil.
	If the country code is Brazil the function will return T - True if the electronic invoice
        issuing source is not enabled for the invoice, or if the electronic invoicing issuing
        source for the invoice is enabled and the electronic invoice status is either
        Finalized or Contingency.

*/
     FUNCTION IS_INVOICE_FINAL
                  (P_CUSTOMER_TRX_ID  IN NUMBER) RETURN VARCHAR2

     IS

      -- Declaration part

        CURSOR C_BATCH_SOURCE IS
                SELECT NVL(B.GLOBAL_ATTRIBUTE5, 'N') GLOBAL_ATTRIBUTE5
                FROM RA_BATCH_SOURCES B, RA_CUSTOMER_TRX T
                WHERE T.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                AND B.BATCH_SOURCE_ID = T.BATCH_SOURCE_ID;

        CURSOR C_CUST_EXT IS
                SELECT COUNT(*) as CTR
                FROM JL_BR_CUSTOMER_TRX_EXTS
                WHERE ELECTRONIC_INV_STATUS IN ('2','7')
                AND CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                AND NOT EXISTS ( SELECT 'X' FROM AR_PAYMENT_SCHEDULES
                WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                AND SELECTED_FOR_RECEIPT_BATCH_ID = -999);

        l_proceed_flag VARCHAR2(1) := 'F';
        l_country_code VARCHAR2(30);

      BEGIN

            FND_PROFILE.GET('JGZZ_COUNTRY_CODE', l_country_code);

            IF (l_country_code = 'BR') THEN

              FOR batch_source_rec IN C_BATCH_SOURCE LOOP

                  IF  batch_source_rec.GLOBAL_ATTRIBUTE5 = 'Y' THEN

                      FOR cust_ext_rec IN C_CUST_EXT LOOP
                          IF cust_ext_rec.CTR = 0 THEN
                              l_proceed_flag := 'F';
                          ELSE
                              l_proceed_flag := 'T';
                          END IF;
                      END LOOP;
                  ELSE
                      l_proceed_flag := 'T';
                  END IF;
              END LOOP;

            ELSE
                        l_proceed_flag := 'T';
            END IF;

      RETURN l_proceed_flag;

    EXCEPTION
          WHEN OTHERS THEN
                l_proceed_flag := 'F';
                RETURN l_proceed_flag;
    END IS_INVOICE_FINAL;


    PROCEDURE Set_Trx_Lock_Status(p_customer_trx_id IN NUMBER) IS

    CURSOR C_BATCH_SOURCE IS
          SELECT NVL(B.GLOBAL_ATTRIBUTE5, 'N') GLOBAL_ATTRIBUTE5
                   FROM RA_BATCH_SOURCES B, RA_CUSTOMER_TRX T
                   WHERE T.CUSTOMER_TRX_ID = p_customer_trx_id
                         AND B.BATCH_SOURCE_ID = T.BATCH_SOURCE_ID;
    l_country_code varchar2(30);
    BEGIN
         FND_PROFILE.GET('JGZZ_COUNTRY_CODE', l_country_code);

         IF (l_country_code = 'BR') THEN

          FOR BATCH_SOURCE_REC IN C_BATCH_SOURCE LOOP
            IF  BATCH_SOURCE_REC.GLOBAL_ATTRIBUTE5 = 'Y' THEN
                UPDATE AR_PAYMENT_SCHEDULES_ALL
                      SET SELECTED_FOR_RECEIPT_BATCH_ID = -999
                      WHERE CUSTOMER_TRX_ID = p_customer_trx_id;
            END IF;
          END LOOP;
         END IF;
    END Set_Trx_Lock_Status;

    /* Function Name : Copy_GDF_Attributes
       Description   : This function will be called from the core AR Autoinvoice program and the Copy Transactions program
                       for inserting the Electronic Invoice attributes in the  JL_BR_CUSTOMER_TRX_EXTS extension table*/
    FUNCTION COPY_GDF_ATTRIBUTES (P_REQUEST_ID IN NUMBER, P_CALLED_FROM IN VARCHAR2) RETURN NUMBER IS

            TYPE HEADER_GDF_ATTR_TYPE  IS TABLE OF RA_INTERFACE_LINES_ALL.HEADER_GDF_ATTRIBUTE1%TYPE;

            TYPE CUSTOMER_TRX_ID_TYPE IS TABLE OF RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE;

            TYPE LEGAL_PROCESS_CODE_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.LEGAL_PROCESS_CODE%TYPE;
            TYPE LEGAL_PROCESS_SOURCE_IND_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.LEGAL_PROCESS_SOURCE_IND%TYPE;
            TYPE VEHICLE_PLATE_STATE_CODE_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.VEHICLE_PLATE_STATE_CODE%TYPE;
            TYPE VEHICLE_ANTT_INSCRIPTION_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.VEHICLE_ANTT_INSCRIPTION%TYPE;
            TYPE TOWING_VEH_PLATE_NUMBER_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.TOWING_VEH_PLATE_NUMBER%TYPE;
            TYPE TOWING_VEH_PLATE_STATE_CODE_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.TOWING_VEH_PLATE_STATE_CODE%TYPE;
            TYPE TOWING_VEH_ANTT_INSCRIPTION_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.TOWING_VEH_ANTT_INSCRIPTION%TYPE;
            TYPE SEAL_NUMBER_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.SEAL_NUMBER%TYPE;
            TYPE ELECTRONIC_INV_WEB_ADDRESS_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.ELECTRONIC_INV_WEB_ADDRESS%TYPE;
            TYPE ELECTRONIC_INV_ACCESS_KEY_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.ELECTRONIC_INV_ACCESS_KEY%TYPE;
            TYPE ELECTRONIC_INV_PROTOCOL_T IS TABLE OF JL_BR_CUSTOMER_TRX_EXTS.ELECTRONIC_INV_PROTOCOL%TYPE;

            AUTO_CUSTOMER_TRX_ID CUSTOMER_TRX_ID_TYPE;
            COPY_CUSTOMER_TRX_ID CUSTOMER_TRX_ID_TYPE;

            HEADER_GDF_ATTRIBUTE19 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE20 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE21 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE22 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE23 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE24 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE25 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE26 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE27 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE29 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE30 HEADER_GDF_ATTR_TYPE;

            LEGAL_PROCESS_CODE LEGAL_PROCESS_CODE_T;
            LEGAL_PROCESS_SOURCE_INDICATOR LEGAL_PROCESS_SOURCE_IND_T;
            VEHICLE_PLATE_STATE_CODE VEHICLE_PLATE_STATE_CODE_T;
            VEHICLE_ANTT_INSCRIPTION VEHICLE_ANTT_INSCRIPTION_T;
            TOWING_VEH_PLATE_NUMBER TOWING_VEH_PLATE_NUMBER_T;
            TOWING_VEH_PLATE_STATE_CODE TOWING_VEH_PLATE_STATE_CODE_T;
            TOWING_VEH_ANTT_INSCRIPTION TOWING_VEH_ANTT_INSCRIPTION_T;
            SEAL_NUMBER SEAL_NUMBER_T;
            ELECTRONIC_INV_WEB_ADDRESS ELECTRONIC_INV_WEB_ADDRESS_T;
            ELECTRONIC_INV_ACCESS_KEY ELECTRONIC_INV_ACCESS_KEY_T;
            ELECTRONIC_INV_PROTOCOL ELECTRONIC_INV_PROTOCOL_T;

            CURSOR C_AUTOINV_ATTR IS SELECT
                    GT.CUSTOMER_TRX_ID,
                    GT.HEADER_GDF_ATTRIBUTE19,
                    GT.HEADER_GDF_ATTRIBUTE20,
                    GT.HEADER_GDF_ATTRIBUTE21,
                    GT.HEADER_GDF_ATTRIBUTE22,
                    GT.HEADER_GDF_ATTRIBUTE23,
                    GT.HEADER_GDF_ATTRIBUTE24,
                    GT.HEADER_GDF_ATTRIBUTE25,
                    GT.HEADER_GDF_ATTRIBUTE26,
                    GT.HEADER_GDF_ATTRIBUTE27,
                    GT.HEADER_GDF_ATTRIBUTE29,
                    GT.HEADER_GDF_ATTRIBUTE30
                    FROM RA_INTERFACE_LINES_GT GT,
                         RA_CUSTOMER_TRX TRX
                    WHERE TRX.REQUEST_ID = P_REQUEST_ID
                          AND GT.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                          AND GT.INTERFACE_LINE_ID = (SELECT MIN(GT_2.INTERFACE_LINE_ID)
                                                      FROM RA_INTERFACE_LINES_GT GT_2
                                                      WHERE  GT_2.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID) ;


              CURSOR C_COPYINV_ATTR IS SELECT
                    NEW_TRX.CUSTOMER_TRX_ID
                    ,OLD_TRX.LEGAL_PROCESS_CODE
                    ,OLD_TRX.LEGAL_PROCESS_SOURCE_IND
                    ,OLD_TRX.VEHICLE_PLATE_STATE_CODE
                    ,OLD_TRX.VEHICLE_ANTT_INSCRIPTION
                    ,OLD_TRX.TOWING_VEH_PLATE_NUMBER
                    ,OLD_TRX.TOWING_VEH_PLATE_STATE_CODE
                    ,OLD_TRX.TOWING_VEH_ANTT_INSCRIPTION
                    ,OLD_TRX.SEAL_NUMBER
                    ,OLD_TRX.ELECTRONIC_INV_WEB_ADDRESS
                    ,OLD_TRX.ELECTRONIC_INV_ACCESS_KEY
                    ,OLD_TRX.ELECTRONIC_INV_PROTOCOL
                    FROM JL_BR_CUSTOMER_TRX_EXTS OLD_TRX,
                    (SELECT TRX_NUMBER, CUSTOMER_TRX_ID,RECURRED_FROM_TRX_NUMBER,BATCH_SOURCE_ID
                     FROM RA_CUSTOMER_TRX
                     WHERE REQUEST_ID = P_REQUEST_ID) NEW_TRX
                     WHERE OLD_TRX.CUSTOMER_TRX_ID = (SELECT CUSTOMER_TRX_ID FROM RA_CUSTOMER_TRX
					 WHERE TRX_NUMBER = NEW_TRX.RECURRED_FROM_TRX_NUMBER
					 AND BATCH_SOURCE_ID = NEW_TRX.BATCH_SOURCE_ID);

            L_COUNTRY_CODE      VARCHAR2(30);

    BEGIN
            FND_PROFILE.GET('JGZZ_COUNTRY_CODE', L_COUNTRY_CODE);

            IF L_COUNTRY_CODE = 'BR' THEN
                    IF P_CALLED_FROM = 'RAXTRX' THEN

                            OPEN C_AUTOINV_ATTR;
                            FETCH C_AUTOINV_ATTR BULK COLLECT INTO
                                    AUTO_CUSTOMER_TRX_ID,
                                    HEADER_GDF_ATTRIBUTE19,
                                    HEADER_GDF_ATTRIBUTE20,
                                    HEADER_GDF_ATTRIBUTE21,
                                    HEADER_GDF_ATTRIBUTE22,
                                    HEADER_GDF_ATTRIBUTE23,
                                    HEADER_GDF_ATTRIBUTE24,
                                    HEADER_GDF_ATTRIBUTE25,
                                    HEADER_GDF_ATTRIBUTE26,
                                    HEADER_GDF_ATTRIBUTE27,
                                    HEADER_GDF_ATTRIBUTE29,
                                    HEADER_GDF_ATTRIBUTE30;
                            CLOSE C_AUTOINV_ATTR;

                            IF AUTO_CUSTOMER_TRX_ID.COUNT > 0 THEN

                               FOR I IN 1..AUTO_CUSTOMER_TRX_ID.COUNT
                               LOOP
                               INSERT INTO JL_BR_CUSTOMER_TRX_EXTS
                                    (CUSTOMER_TRX_ID
                                    ,LEGAL_PROCESS_CODE
                                    ,LEGAL_PROCESS_SOURCE_IND
                                    ,VEHICLE_PLATE_STATE_CODE
                                    ,VEHICLE_ANTT_INSCRIPTION
                                    ,TOWING_VEH_PLATE_NUMBER
                                    ,TOWING_VEH_PLATE_STATE_CODE
                                    ,TOWING_VEH_ANTT_INSCRIPTION
                                    ,SEAL_NUMBER
                                    ,ELECTRONIC_INV_WEB_ADDRESS
                                    ,ELECTRONIC_INV_ACCESS_KEY
                                    ,ELECTRONIC_INV_PROTOCOL
                                    ,LAST_UPDATE_DATE
                                    ,LAST_UPDATED_BY
                                    ,LAST_UPDATE_LOGIN
                                    ,CREATION_DATE
                                    ,CREATED_BY)
                                    VALUES(
                                    AUTO_CUSTOMER_TRX_ID(I),
                                    HEADER_GDF_ATTRIBUTE19(I),
                                    HEADER_GDF_ATTRIBUTE20(I),
                                    HEADER_GDF_ATTRIBUTE21(I),
                                    HEADER_GDF_ATTRIBUTE22(I),
                                    HEADER_GDF_ATTRIBUTE23(I),
                                    HEADER_GDF_ATTRIBUTE24(I),
                                    HEADER_GDF_ATTRIBUTE25(I),
                                    HEADER_GDF_ATTRIBUTE26(I),
                                    HEADER_GDF_ATTRIBUTE27(I),
                                    HEADER_GDF_ATTRIBUTE29(I),
                                    HEADER_GDF_ATTRIBUTE30(I),
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.LOGIN_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID);
                               Set_Trx_Lock_Status(AUTO_CUSTOMER_TRX_ID(I));
                               END LOOP;
                            END IF;

                    ELSIF P_CALLED_FROM = 'ARXREC' THEN

                            OPEN C_COPYINV_ATTR;
                                    FETCH C_COPYINV_ATTR BULK COLLECT INTO
                                    COPY_CUSTOMER_TRX_ID,
                                    LEGAL_PROCESS_CODE,
                                    LEGAL_PROCESS_SOURCE_INDICATOR,
                                    VEHICLE_PLATE_STATE_CODE,
                                    VEHICLE_ANTT_INSCRIPTION,
                                    TOWING_VEH_PLATE_NUMBER ,
                                    TOWING_VEH_PLATE_STATE_CODE,
                                    TOWING_VEH_ANTT_INSCRIPTION,
                                    SEAL_NUMBER,
                                    ELECTRONIC_INV_WEB_ADDRESS,
                                    ELECTRONIC_INV_ACCESS_KEY,
                                    ELECTRONIC_INV_PROTOCOL;
                            CLOSE C_COPYINV_ATTR;

                            IF COPY_CUSTOMER_TRX_ID.COUNT > 0 THEN

                            FOR I IN 1..COPY_CUSTOMER_TRX_ID.COUNT
                            LOOP
                            INSERT INTO JL_BR_CUSTOMER_TRX_EXTS
                                    (CUSTOMER_TRX_ID
                                    ,LEGAL_PROCESS_CODE
                                    ,LEGAL_PROCESS_SOURCE_IND
                                    ,VEHICLE_PLATE_STATE_CODE
                                    ,VEHICLE_ANTT_INSCRIPTION
                                    ,TOWING_VEH_PLATE_NUMBER
                                    ,TOWING_VEH_PLATE_STATE_CODE
                                    ,TOWING_VEH_ANTT_INSCRIPTION
                                    ,SEAL_NUMBER
                                    --,ELECTRONIC_INV_WEB_ADDRESS
                                    --,ELECTRONIC_INV_ACCESS_KEY
                                    --,ELECTRONIC_INV_PROTOCOL
                                    ,LAST_UPDATE_DATE
                                    ,LAST_UPDATED_BY
                                    ,LAST_UPDATE_LOGIN
                                    ,CREATION_DATE
                                    ,CREATED_BY)
                                    VALUES(
                                    COPY_CUSTOMER_TRX_ID(I)
                                    ,LEGAL_PROCESS_CODE(I)
                                    ,LEGAL_PROCESS_SOURCE_INDICATOR(I)
                                    ,VEHICLE_PLATE_STATE_CODE(I)
                                    ,VEHICLE_ANTT_INSCRIPTION(I)
                                    ,TOWING_VEH_PLATE_NUMBER(I)
                                    ,TOWING_VEH_PLATE_STATE_CODE(I)
                                    ,TOWING_VEH_ANTT_INSCRIPTION(I)
                                    ,SEAL_NUMBER(I)
                                    --,ELECTRONIC_INV_WEB_ADDRESS(I)
                                    --,ELECTRONIC_INV_ACCESS_KEY(I)
                                    --,ELECTRONIC_INV_PROTOCOL(I)
                                    ,SYSDATE
                                    ,FND_GLOBAL.USER_ID
                                    ,FND_GLOBAL.LOGIN_ID
                                    ,SYSDATE
                                    ,FND_GLOBAL.USER_ID);
                            Set_Trx_Lock_Status(COPY_CUSTOMER_TRX_ID(I));
                            END LOOP;
                            END IF;
                    END IF;
            END IF;
            RETURN 1;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN 0;
    END COPY_GDF_ATTRIBUTES;


    /*Function name : Copy_GDF_Attributes_API
      Description   : This function will be called from the core AR Invoice API
                      This function will insert the Electronic Invoice attributes IN THE JL_BR_CUSTOMER_TRX_EXTS
                      the the extension table */
    FUNCTION COPY_GDF_ATTRIBUTES_API (P_CUSTOMER_TRX_ID IN NUMBER) RETURN NUMBER IS

            TYPE HEADER_GDF_ATTR_TYPE  IS TABLE OF RA_INTERFACE_LINES_ALL.HEADER_GDF_ATTRIBUTE1%TYPE;
            TYPE CUSTOMER_TRX_ID_TYPE IS TABLE OF RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE;
            CUSTOMER_TRX_ID CUSTOMER_TRX_ID_TYPE;
            HEADER_GDF_ATTRIBUTE19 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE20 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE21 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE22 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE23 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE24 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE25 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE26 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE27 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE29 HEADER_GDF_ATTR_TYPE;
            HEADER_GDF_ATTRIBUTE30 HEADER_GDF_ATTR_TYPE;

            CURSOR C_APIINV_ATTR IS SELECT
                    GT.CUSTOMER_TRX_ID,
                    GT.GLOBAL_ATTRIBUTE19,
                    GT.GLOBAL_ATTRIBUTE20,
                    GT.GLOBAL_ATTRIBUTE21,
                    GT.GLOBAL_ATTRIBUTE22,
                    GT.GLOBAL_ATTRIBUTE23,
                    GT.GLOBAL_ATTRIBUTE24,
                    GT.GLOBAL_ATTRIBUTE25,
                    GT.GLOBAL_ATTRIBUTE26,
                    GT.GLOBAL_ATTRIBUTE27,
                    GT.GLOBAL_ATTRIBUTE29,
                    GT.GLOBAL_ATTRIBUTE30
                    FROM AR_TRX_HEADER_GT GT
                    WHERE GT.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
            L_COUNTRY_CODE      VARCHAR2 (30);
    BEGIN

            FND_PROFILE.GET ('JGZZ_COUNTRY_CODE', L_COUNTRY_CODE);
            IF L_COUNTRY_CODE = 'BR' THEN
                    OPEN C_APIINV_ATTR;
                    FETCH C_APIINV_ATTR BULK COLLECT INTO
                    CUSTOMER_TRX_ID,
                    HEADER_GDF_ATTRIBUTE19,
                    HEADER_GDF_ATTRIBUTE20,
                    HEADER_GDF_ATTRIBUTE21,
                    HEADER_GDF_ATTRIBUTE22,
                    HEADER_GDF_ATTRIBUTE23,
                    HEADER_GDF_ATTRIBUTE24,
                    HEADER_GDF_ATTRIBUTE25,
                    HEADER_GDF_ATTRIBUTE26,
                    HEADER_GDF_ATTRIBUTE27,
                    HEADER_GDF_ATTRIBUTE29,
                    HEADER_GDF_ATTRIBUTE30;
                    CLOSE C_APIINV_ATTR;

            FOR I IN 1..CUSTOMER_TRX_ID.COUNT
            LOOP
                    INSERT INTO JL_BR_CUSTOMER_TRX_EXTS
                    (CUSTOMER_TRX_ID
                    ,LEGAL_PROCESS_CODE
                    ,LEGAL_PROCESS_SOURCE_IND
                    ,VEHICLE_PLATE_STATE_CODE
                    ,VEHICLE_ANTT_INSCRIPTION
                    ,TOWING_VEH_PLATE_NUMBER
                    ,TOWING_VEH_PLATE_STATE_CODE
                    ,TOWING_VEH_ANTT_INSCRIPTION
                    ,SEAL_NUMBER
                    ,ELECTRONIC_INV_WEB_ADDRESS
                    ,ELECTRONIC_INV_ACCESS_KEY
                    ,ELECTRONIC_INV_PROTOCOL
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,CREATION_DATE
                    ,CREATED_BY)
                    VALUES(
                    CUSTOMER_TRX_ID(I),
                    HEADER_GDF_ATTRIBUTE19(I),
                    HEADER_GDF_ATTRIBUTE20(I),
                    HEADER_GDF_ATTRIBUTE21(I),
                    HEADER_GDF_ATTRIBUTE22(I),
                    HEADER_GDF_ATTRIBUTE23(I),
                    HEADER_GDF_ATTRIBUTE24(I),
                    HEADER_GDF_ATTRIBUTE25(I),
                    HEADER_GDF_ATTRIBUTE26(I),
                    HEADER_GDF_ATTRIBUTE27(I),
                    HEADER_GDF_ATTRIBUTE29(I),
                    HEADER_GDF_ATTRIBUTE30(I),
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID);
            Set_Trx_Lock_Status(CUSTOMER_TRX_ID(I));
            END LOOP;
          END IF;

          RETURN 1;

    EXCEPTION
            WHEN OTHERS THEN
            RETURN 0;
    END COPY_GDF_ATTRIBUTES_API;

    FUNCTION Create_Void_CM (p_inv_customer_trx_id IN NUMBER,p_trx_type_id IN NUMBER,p_CM_amount IN NUMBER) RETURN NUMBER IS

    l_trx_status NUMBER(15);
    l_trx_amount NUMBER;
    l_CM_type    VARCHAR2(20);
    l_CM_status  VARCHAR2(20);
    CURSOR C_trx_details( p_trx_id IN NUMBER ) IS
           SELECT selected_for_receipt_batch_id, sum(amount_due_remaining) FROM ar_payment_schedules WHERE customer_trx_id = p_trx_id
                                                 GROUP BY customer_trx_id,selected_for_receipt_batch_id;
    CURSOR C_CM_Details( p_type_id IN NUMBER ) IS
           SELECT TYPE, DEFAULT_STATUS FROM ra_cust_trx_types WHERE cust_trx_type_id = p_type_id;
    L_COUNTRY_CODE varchar2(30);
    BEGIN
    FND_PROFILE.GET ('JGZZ_COUNTRY_CODE', L_COUNTRY_CODE);
    IF L_COUNTRY_CODE = 'BR' THEN

            OPEN C_trx_details(p_inv_customer_trx_id);
            FETCH C_trx_details INTO l_trx_status,l_trx_amount;
            CLOSE C_trx_details;

            OPEN C_CM_Details(p_trx_type_id);
            FETCH C_CM_Details INTO l_CM_type, l_CM_status;
            CLOSE C_CM_Details;

        IF l_trx_status = -999 THEN
              IF l_CM_type = 'CM' AND l_CM_status = 'VD' AND (l_trx_amount + p_CM_amount) = 0 THEN
                  UPDATE ar_payment_schedules
                      SET selected_for_receipt_batch_id = NULL
                      WHERE selected_for_receipt_batch_id = -999 AND
                      customer_trx_id = p_inv_customer_trx_id;
                      RETURN 1;
              ELSE
                      RETURN 0;
              END IF;
        ELSE
              RETURN 1;
        END IF;

    ELSE
       RETURN 1;
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
             RETURN 0;

    END Create_Void_CM;

END JL_BR_SPED_PKG;




/
