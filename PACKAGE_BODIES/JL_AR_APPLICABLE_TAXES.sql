--------------------------------------------------------
--  DDL for Package Body JL_AR_APPLICABLE_TAXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_APPLICABLE_TAXES" AS
/* $Header: jlarpatb.pls 120.1.12010000.3 2009/06/22 21:03:50 abuissa noship $ */

-------------------------------------------------------------------------------
--Global Variables
-------------------------------------------------------------------------------

  p_debug_log                           VARCHAR2(1)     := 'Y';
  l_AWT_TAX_TYPE                        VARCHAR2(10)    := 'TURN_BSAS';
  l_PERCEPTION_TAX_TYPE                 VARCHAR2(10)    := 'TOPBA';
  l_ORG_ID                              NUMBER(15)      := oe_profile.value('SO_ORGANIZATION_ID');
  g_current_runtime_level               CONSTANT NUMBER := fnd_log.g_current_runtime_level;
  g_level_statement                     CONSTANT NUMBER := fnd_log.level_statement;
  g_level_procedure                     CONSTANT NUMBER := fnd_log.level_procedure;
  g_level_event                         CONSTANT NUMBER := fnd_log.level_event;
  g_level_exception                     CONSTANT NUMBER := fnd_log.level_exception;
  g_level_error                         CONSTANT NUMBER := fnd_log.level_error;
  g_level_unexpected                    CONSTANT NUMBER := fnd_log.level_unexpected;
  l_RETURN_STATUS                       VARCHAR2(1);
  l_taxpayer                            VARCHAR2(1) := 'N';
  l_taxpayer_ar                         VARCHAR2(1) := 'N';


  PROCEDURE Insert_Row (l_PUBLISH_DATE          DATE,
                        l_START_DATE            DATE,
                        l_END_DATE              DATE,
                        l_TAXPAYER_ID           NUMBER,
                        l_CONTRIBUTOR_TYPE_CODE VARCHAR2,
                        l_NEW_CONTRIBUTOR_FLAG   VARCHAR2,
                        l_RATE_CHANGE_FLAG      VARCHAR2,
                        l_PERCEPTION_RATE        NUMBER,
                        l_WHT_RATE              NUMBER,
                        l_PERCEPTION_GROUP_NUM  NUMBER,
                        l_WHT_GROUP_NUM         NUMBER,
                        l_WHT_DEFAULT_FLAG      VARCHAR2,
                        l_CALLING_RESP          VARCHAR2
                        ) IS


  final_insert_check      VARCHAR2(1) := 'N';
  l_created_by            NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_creation_DATE         DATE := SYSDATE;
  l_last_UPDATEd_by       NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_last_UPDATE_DATE      DATE := SYSDATE;
  l_last_UPDATE_login     NUMBER(15) := NVL(fnd_global.conc_login_id, 1);


  BEGIN

    BEGIN
      SELECT 'Y' INTO final_insert_check FROM JL_AR_TURN_UPL
      WHERE TAXPAYER_ID = l_TAXPAYER_ID
      AND START_DATE = l_START_DATE
      AND END_DATE = l_END_DATE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      final_insert_check := 'N';
    END;

    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG, 'In Insert_Row, value of final_insert_check'|| final_insert_check);
    END IF;

    IF final_insert_check = 'N' THEN

      INSERT INTO JL_AR_TURN_UPL(
                                 ORG_ID,
                                 PUBLISH_DATE,
                                 START_DATE,
                                 END_DATE,
                                 TAXPAYER_ID,
                                 CONTRIBUTOR_TYPE_CODE,
                                 NEW_CONTRIBUTOR_FLAG,
                                 RATE_CHANGE_FLAG,
                                 PERCEPTION_RATE,
                                 WHT_RATE,
                                 PERCEPTION_GROUP_NUM,
                                 WHT_GROUP_NUM,
                                 WHT_DEFAULT_FLAG,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 CREATION_DATE,
                                 CREATED_BY)
      VALUES (
              l_ORG_ID, --ORG_ID
              l_PUBLISH_DATE, --PUBLISH_DATE
              l_START_DATE, --START_DATE
              l_END_DATE, --END_DATE
              l_TAXPAYER_ID, --TAXPAYER_ID
              l_CONTRIBUTOR_TYPE_CODE, --CONTRIBUTOR_TYPE_CODE
              l_NEW_CONTRIBUTOR_FLAG, --NEW_CONTRIBUTOR_FLAG
              l_RATE_CHANGE_FLAG, --RATE_CHANGE_FLAG
              l_PERCEPTION_RATE, --PERCEPTION_RATE
              l_WHT_RATE, --WHT_RATE
              l_PERCEPTION_GROUP_NUM, --PERCEPTION_GROUP_NUM
              l_WHT_GROUP_NUM, --WHT_GROUP_NUM
              l_WHT_DEFAULT_FLAG, --WHT_DEFAULT_FLAG
              l_last_UPDATE_DATE, --LAST_UPDATE_DATE
              l_last_UPDATEd_by, --LAST_UPDATED_BY
              l_last_UPDATE_login, --LAST_UPDATE_LOGIN
              l_creation_DATE, --CREATION_DATE
              l_created_by); --CREATED_BY

    ELSE

      IF l_CALLING_RESP = 'AP' THEN

        UPDATE JL_AR_TURN_UPL SET WHT_RATE = l_WHT_RATE, WHT_GROUP_NUM = l_WHT_GROUP_NUM, WHT_DEFAULT_FLAG = l_WHT_DEFAULT_FLAG
        WHERE TAXPAYER_ID = l_TAXPAYER_ID
        AND START_DATE = l_START_DATE
        AND END_DATE = l_END_DATE;

      ELSIF l_CALLING_RESP = 'AR' THEN

        UPDATE JL_AR_TURN_UPL SET PERCEPTION_RATE = l_PERCEPTION_RATE, PERCEPTION_GROUP_NUM = l_PERCEPTION_GROUP_NUM
        WHERE TAXPAYER_ID = l_TAXPAYER_ID
        AND START_DATE = l_START_DATE
        AND END_DATE = l_END_DATE;

      END IF;

    END IF;


  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE INSERTING INTO FINAL TABLE '|| SQLCODE || 'ERROR' || SQLERRM);
    END IF;
  END Insert_Row;





  FUNCTION FORMAT_DATE(INPUT_DATE IN DATE)
  RETURN DATE
  IS

  l_DATE DATE;

  BEGIN

   l_DATE := TO_DATE(INPUT_DATE, 'DD/MM/YYYY');
   RETURN l_DATE;

  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHEN VALIDATING DATE'|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END IF;
  END FORMAT_DATE;





  FUNCTION VALID_NUMBER(INPUT_NUM IN NUMBER)
  RETURN BOOLEAN
  IS
  l_valid_num NUMBER;

  BEGIN
    l_valid_num := TO_NUMBER(INPUT_NUM);
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHEN VALIDATING NUMBER'|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END IF;
    RETURN FALSE;
  END VALID_NUMBER;






  FUNCTION BASIC_VALIDATION(l_TAXPAYERID IN NUMBER)
  RETURN BOOLEAN
  IS

  l_PUBLISH_DATE            DATE;
  l_START_DATE              DATE;
  l_END_DATE                DATE;
  l_TAXPAYER_ID             NUMBER(15);
  l_CONTRIBUTOR_TYPE_CODE   VARCHAR2(1);
  l_NEW_CONTRIBUTOR_FLAG    VARCHAR2(1);
  l_RATE_CHANGE_FLAG        VARCHAR2(1);
  l_PERCEPTION_RATE         NUMBER(15,2);
  l_WHT_RATE                NUMBER(15,2);
  l_PERCEPTION_GROUP_NUM    NUMBER(15);
  l_WHT_GROUP_NUM           NUMBER(15);

  l_PUBLISHDATE_ALL         DATE;
  valid_flag                VARCHAR2(1) := 'Y';

  CURSOR C2 IS SELECT * FROM JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYERID;

  V_TEMPREC C2%ROWTYPE;



  BEGIN

    OPEN C2;
    LOOP
      FETCH C2 INTO V_TEMPREC;
      EXIT WHEN C2%NOTFOUND;

      l_PUBLISH_DATE            := V_TEMPREC.PUBLISH_DATE;
      l_START_DATE              := V_TEMPREC.START_DATE;
      l_END_DATE                := V_TEMPREC.END_DATE;

      l_TAXPAYER_ID             := V_TEMPREC.TAXPAYER_ID;
      l_CONTRIBUTOR_TYPE_CODE   := V_TEMPREC.CONTRIBUTOR_TYPE_CODE;
      l_NEW_CONTRIBUTOR_FLAG    := V_TEMPREC.NEW_CONTRIBUTOR_FLAG;
      l_RATE_CHANGE_FLAG        := V_TEMPREC.RATE_CHANGE_FLAG;
      l_PERCEPTION_RATE         := V_TEMPREC.PERCEPTION_RATE;
      l_WHT_RATE                := V_TEMPREC.WHT_RATE;
      l_PERCEPTION_GROUP_NUM    := V_TEMPREC.PERCEPTION_GROUP_NUM;
      l_WHT_GROUP_NUM           := V_TEMPREC.WHT_GROUP_NUM;


      BEGIN

        SELECT MAX(PUBLISH_DATE) INTO l_PUBLISHDATE_ALL FROM JL_AR_TURN_UPL
        WHERE TAXPAYER_ID = l_TAXPAYERID;

        IF (l_PUBLISH_DATE < l_PUBLISHDATE_ALL) AND (l_START_DATE > l_END_DATE) THEN
          valid_flag := 'N';
          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING DATE CHECK VALIDATION');
          END IF;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'NO PREVIOUS RECORD IN JL_AR_TURN_UPL');
        END IF;
      END;

      IF VALID_NUMBER(V_TEMPREC.TAXPAYER_ID) THEN
        l_TAXPAYER_ID := TO_NUMBER(V_TEMPREC.TAXPAYER_ID, '99999999999');
      ELSE
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED IN TAXPAYER ID (NUMBER) CHECK VALIDATION');
        END IF;
      END IF;


                                                                                        -- AP tax payer id available check

      BEGIN
        SELECT DISTINCT 'Y' INTO l_taxpayer FROM PO_VENDORS PV, PER_ALL_PEOPLE_F PAPF
        WHERE NVL(pv.employee_id, - 99) = papf.person_id (+)
        AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
        AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
        l_taxpayer := 'N';

        WHEN OTHERS THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'AN ERROR WAS ENCOUNTERED IN TAX_PAYER VALIDATION FOR AP '|| SQLCODE || 'ERROR' || SQLERRM);
        END IF;
        RETURN FALSE; -- fetch next record

      END;

                                                                                        -- AR tax payer id available check

      BEGIN

        SELECT DISTINCT 'Y' INTO l_taxpayer_ar
        FROM HZ_PARTIES HZP,
        HZ_CUST_ACCOUNTS_ALL HZCA,
        HZ_CUST_ACCT_SITES_ALL HZAS,
        HZ_CUST_SITE_USES_ALL HZSU
        WHERE HZCA.PARTY_ID = HZP.PARTY_ID
        AND HZCA.CUST_ACCOUNT_ID = HZAS.CUST_ACCOUNT_ID
        AND HZAS.CUST_ACCT_SITE_ID = HZSU.CUST_ACCT_SITE_ID
        AND HZSU.ORG_ID = l_ORG_ID
        AND HZP.JGZZ_FISCAL_CODE = TO_CHAR(l_TAXPAYER_ID);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_taxpayer_ar := 'N';

        WHEN OTHERS THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'AN ERROR WAS ENCOUNTERED IN TAX_PAYER VALIDATION FOR AR'|| SQLCODE || 'ERROR' || SQLERRM);
        END IF;
        RETURN FALSE; -- fetch next record

      END;



      IF l_taxpayer = 'N' AND l_taxpayer_ar = 'N' THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.put_line( FND_FILE.LOG,'TAXPAYER ID IS NOT AVAILABLE');
        END IF;
        UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_TAXPAYER_ID_NOT_AVAILABLE'
        WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
        RETURN FALSE;

      END IF;

      l_CONTRIBUTOR_TYPE_CODE := V_TEMPREC.CONTRIBUTOR_TYPE_CODE;
      l_NEW_CONTRIBUTOR_FLAG := V_TEMPREC.NEW_CONTRIBUTOR_FLAG;
      l_RATE_CHANGE_FLAG := V_TEMPREC.RATE_CHANGE_FLAG;


      IF (l_CONTRIBUTOR_TYPE_CODE NOT IN ('D', 'C')) THEN
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING CONTRIBUTOR TYPE CHECK VALIDATION');
        END IF;

      ELSIF (l_NEW_CONTRIBUTOR_FLAG NOT IN ('S', 'N', 'B')) THEN
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING NEW CONTRIBUTOR CHECK VALIDATION');
        END IF;

      ELSIF (l_RATE_CHANGE_FLAG NOT IN ('S', 'N')) THEN
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING RATE CHANGE FLAG CHECK VALIDATION');
        END IF;

      ELSE
        valid_flag := 'Y';
      END IF;


      IF VALID_NUMBER(V_TEMPREC.PERCEPTION_RATE) THEN
        l_PERCEPTION_RATE := TO_NUMBER(V_TEMPREC.PERCEPTION_RATE);

      ELSE
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING PERCEPTION_RATE CHECK VALIDATION');
        END IF;

      END IF;


      IF VALID_NUMBER(V_TEMPREC.WHT_RATE) THEN
        l_WHT_RATE := TO_NUMBER(V_TEMPREC.WHT_RATE);

      ELSE
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING WHT_RATE CHECK VALIDATION');
        END IF;

      END IF;


      IF VALID_NUMBER(NVL(V_TEMPREC.PERCEPTION_GROUP_NUM, 0)) THEN
        l_PERCEPTION_GROUP_NUM := TO_NUMBER(NVL(V_TEMPREC.PERCEPTION_GROUP_NUM, 0), '99');

      ELSE
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING PERCEPTION_GROUP_NUM CHECK VALIDATION');
        END IF;

      END IF;


      IF VALID_NUMBER(NVL(V_TEMPREC.WHT_GROUP_NUM, 0)) THEN
        l_WHT_GROUP_NUM := TO_NUMBER(NVL(V_TEMPREC.WHT_GROUP_NUM, 0), '99');

      ELSE
        valid_flag := 'N';
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING WHT_GROUP_NUM CHECK VALIDATION');
        END IF;

      END IF;


      IF (valid_flag = 'Y') THEN
        RETURN TRUE;

      ELSIF (valid_flag = 'N') THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'RECORD FAILED DURING BASIC CHECK VALIDATION, PLEASE REFER LOG FILE/REPORT ');
        END IF;
        UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_RECORD_FAIL_BASIC_CHECK'
        WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;

        RETURN FALSE;
      END IF;



    END LOOP;
    CLOSE C2;


  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'AN ERROR WAS ENCOUNTERED DURING BASIC CHECK VALIDATION'|| SQLCODE || 'ERROR' || SQLERRM);
    END IF;
    UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_RECORD_FAIL_BASIC_CHECK'
    WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;

    RETURN FALSE;

  END BASIC_VALIDATION;







  PROCEDURE FINAL_VALIDATION
  IS

  l_PUBLISH_DATE            DATE;
  l_START_DATE              DATE;
  l_END_DATE                DATE;
  l_TAXPAYER_ID             NUMBER(15);
  l_CONTRIBUTOR_TYPE_CODE   VARCHAR2(1);
  l_NEW_CONTRIBUTOR_FLAG    VARCHAR2(1);
  l_RATE_CHANGE_FLAG        VARCHAR2(1);
  l_PERCEPTION_RATE         NUMBER(15,2);
  l_WHT_RATE                NUMBER(15,2);
  l_PERCEPTION_GROUP_NUM    NUMBER(15);
  l_WHT_GROUP_NUM           NUMBER(15);
  l_WHT_DEFAULT_FLAG        VARCHAR2(1) := 'N';

  l_TAX_NAME_AP_AWT         NUMBER(15);
  l_TAX_RATE_AP_AWT         NUMBER(15);
  l_EFFECTIVE_START_DATE    DATE;
  l_EFFECTIVE_END_DATE      DATE;

  l_WHT_RATE_ALL                        AP_AWT_TAX_RATES_ALL.TAX_RATE%TYPE;
  l_WHT_GROUP_NUM_ALL                   AP_AWT_TAX_RATES_ALL.TAX_NAME%TYPE;

  l_SUPP_AWT_CODE_ID_CD                 JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_CODE_ID%TYPE;
  l_SUPP_AWT_TYPE_ID_CD                 JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_TYPE_ID%TYPE;
  l_SUPP_AWT_CODE_ID_SEQ                JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_CODE_ID%TYPE;
  l_SUPP_AWT_TYPE_ID_SEQ                JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_TYPE_ID%TYPE;
  l_tax_id                              ap_tax_codes.tax_id%TYPE;
  l_SUPP_AWT_TYPE_ID_TYPES              JL_ZZ_AP_SUPP_AWT_TYPES.SUPP_AWT_TYPE_ID%TYPE;
  l_VENDOR_ID                           PO_VENDORS.VENDOR_ID%TYPE;
  l_INV_DISTRIB_AWT_ID_INV              JL_ZZ_AP_INV_DIS_WH_ALL.INV_DISTRIB_AWT_ID%TYPE;
  l_INVOICE_ID_INA                      AP_INVOICES_ALL.INVOICE_ID%TYPE;
  l_DISTRIBUTION_LINE_NUMBER_IND        AP_INVOICE_DISTRIBUTIONS_ALL.DISTRIBUTION_LINE_NUMBER%TYPE;
  l_INVOICE_DISTRIBUTION_ID_IND         AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE;
  l_START_DATE_SEC_MAX                  DATE := NULL;
  l_END_DATE_SEC_MAX                    DATE := NULL;
  l_EFFECTIVE_START_DATE_COMP           DATE;
  l_INV_DISTRIB_AWT_ID_DIS              JL_ZZ_AP_INV_DIS_WH_ALL.INV_DISTRIB_AWT_ID%TYPE;


  CURSOR CUR3(l_TAXPAYERID_C NUMBER) IS
  SELECT APINA.INVOICE_ID, APIND.DISTRIBUTION_LINE_NUMBER,APIND.INVOICE_DISTRIBUTION_ID
  FROM PO_VENDORS PV, AP_INVOICES_ALL APINA,
  AP_INVOICE_DISTRIBUTIONS_ALL APIND, PER_ALL_PEOPLE_F PAPF
  WHERE PV.VENDOR_ID = APINA.VENDOR_ID
  AND NVL(pv.employee_id, - 99) = papf.person_id (+)
  AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
  AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
        --AND APIND.TAX_CODE_ID in (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name like 'TURN_BSAS_GRP%')
  AND APINA.INVOICE_ID = APIND.INVOICE_ID
  AND APIND.LINE_TYPE_LOOKUP_CODE = 'ITEM'
  AND APIND.GLOBAL_ATTRIBUTE3 IN
  (SELECT LOCATION_ID FROM HR_LOCATIONS_ALL WHERE UPPER(LOCATION_CODE) = 'BUENOS AIRES' --bug 8622329
   AND trunc(SYSDATE) <= NVL(inactive_DATE, trunc(SYSDATE)))
  AND NVL(APINA.INVOICE_AMOUNT,0) <> NVL(APINA.AMOUNT_PAID,0)
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYERID_C);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYERID_C);


  INV_REC CUR3%ROWTYPE;



  CURSOR C3 IS
  SELECT * FROM JL_AR_TURN_UPL_T;

                --WHERE start_DATE >= P_START_DATE and end_DATE <= P_END_DATE;

  V_TEMPREC C3%ROWTYPE;



--WHO COLUMNS:
----------------

  l_created_by            NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_creation_DATE         DATE       := SYSDATE;
  l_last_UPDATEd_by       NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_last_UPDATE_DATE      DATE       := SYSDATE;
  l_last_UPDATE_login     NUMBER(15) := NVL(fnd_global.conc_login_id, 1);
  l_ORG_ID                NUMBER(15) := oe_profile.value('SO_ORGANIZATION_ID'); -- :=   3687;


--FLAGS:
----------


  duplicate_check_count       NUMBER      := NULL;
  wht_check_unique            VARCHAR2(1) := 'Y';
  duplicate_check_flag        VARCHAR2(1) := 'N';
  same_rec_flag               VARCHAR2(1) := 'N';
  wht_check_flag              VARCHAR2(1) := 'N';
  exist_check_flag            VARCHAR2(1) := 'N';
  WHT_GROUP_NUM_rate_flag     VARCHAR2(1) := 'N';
  same_taxpayerid_flag        VARCHAR2(1) := 'N';
  taxtype_code_check          VARCHAR2(1) := 'N';
  AWT_CODE_INV_AVAIL_FLAG     VARCHAR2(1) := 'N';
  same_prev_rec_flag		      VARCHAR2(1) := 'N';


  BEGIN

                                                -- To ensure the single start_DATE/end_DATE in tmp table (9.4.A.2)

    SELECT COUNT(*) INTO duplicate_check_count FROM
    (SELECT DISTINCT PUBLISH_DATE, START_DATE, END_DATE FROM JL_AR_TURN_UPL_T) TMP;

    IF duplicate_check_count > 1 THEN
      duplicate_check_flag := 'Y';
      IF p_debug_log = 'Y' THEN
        FND_FILE.put_line( FND_FILE.LOG,'1 .Found more than one set of START_DATE or END_DATE');
      END IF;
      UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JL_AR_AP_WRONG_DATE'
      WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
      RAISE_APPLICATION_ERROR(- 20999,'Found more than one set of START_DATE / END_DATE'|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END IF; -- will Stop the process, because of duplicate PUBLISH_DATE, START_DATE, END_DATE in TMP table



    OPEN C3;
    LOOP
      FETCH C3 INTO V_TEMPREC;
      EXIT WHEN C3%NOTFOUND;

      BEGIN

        l_PUBLISH_DATE := V_TEMPREC.PUBLISH_DATE;
        l_START_DATE := V_TEMPREC.START_DATE;
        l_END_DATE := V_TEMPREC.END_DATE;

        l_TAXPAYER_ID := V_TEMPREC.TAXPAYER_ID;
        l_CONTRIBUTOR_TYPE_CODE := V_TEMPREC.CONTRIBUTOR_TYPE_CODE;
        l_NEW_CONTRIBUTOR_FLAG := V_TEMPREC.NEW_CONTRIBUTOR_FLAG;
        l_RATE_CHANGE_FLAG := V_TEMPREC.RATE_CHANGE_FLAG;
        l_PERCEPTION_RATE := V_TEMPREC.PERCEPTION_RATE;
        l_WHT_RATE := V_TEMPREC.WHT_RATE;
        l_PERCEPTION_GROUP_NUM := V_TEMPREC.PERCEPTION_GROUP_NUM;
        l_WHT_GROUP_NUM := V_TEMPREC.WHT_GROUP_NUM;


        INSERT INTO JGZZ_AR_TAX_GLOBAL_TMP(JG_INFO_N1, JG_INFO_D1, JG_INFO_D2, JG_INFO_V1)
        VALUES (l_TAXPAYER_ID, l_START_DATE, l_END_DATE, NULL);

        IF BASIC_VALIDATION(l_TAXPAYER_ID) THEN
          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'2 .RECORD PASSED IN BASIC VALIDATION FOR TAXPAYER: '|| l_TAXPAYER_ID);
          END IF;
        ELSE
          IF p_debug_log = 'Y' THEN
            FND_FILE.put_line( FND_FILE.LOG,'3 .RECORD FAILED DURING BASIC VALIDATION FOR TAXPAYER : '|| l_TAXPAYER_ID);
          END IF;
          GOTO L3;
        END IF;                                                                    -- AR Code Hook


        IF l_taxpayer_ar = 'Y' THEN

	   IF p_debug_log = 'Y' THEN
            FND_FILE.put_line( FND_FILE.LOG,'3 A .GOING TO START THE AR VALIDATION FOR TAXPAYER: '|| l_TAXPAYER_ID);
           END IF;

          BEGIN

            JL_ZZ_AR_UPLOAD_TAXES.JL_AR_UPDATE_CUST_SITE_TAX(l_TAXPAYER_ID,
                                                             l_AWT_TAX_TYPE,
                                                             l_PERCEPTION_TAX_TYPE,
                                                             l_ORG_ID,
                                                             l_PUBLISH_DATE,
                                                             l_START_DATE,
                                                             l_END_DATE,
                                                             l_RETURN_STATUS ); -- out parameter for status

            IF l_RETURN_STATUS = 'Y' THEN
              FND_FILE.put_line(FND_FILE.LOG,'58. AR validation completed successfully');
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line(FND_FILE.LOG,'AR VALIDATION FAILED WITH RETUN STATUS'|| l_RETURN_STATUS || SQLCODE || 'ERROR' || SQLERRM);
            END IF;
            RAISE_APPLICATION_ERROR(- 20999,'AR VALIDATION FAILED'|| SQLCODE ||' -ERROR- '|| SQLERRM);
          END;

        END IF;


                                                        -- If data present in AP tax payer id, then AP Validation starts here

        IF l_taxpayer = 'Y' THEN

           IF p_debug_log = 'Y' THEN
             FND_FILE.put_line( FND_FILE.LOG,'3 B .GOING TO START THE AP VALIDATION FOR TAXPAYER: '|| l_TAXPAYER_ID);
           END IF;

          BEGIN

            SELECT MAX(START_DATE) INTO l_START_DATE_SEC_MAX FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID AND
            START_DATE NOT IN (SELECT MAX(START_DATE) FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID);

            SELECT MAX(END_DATE) INTO l_END_DATE_SEC_MAX FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID AND
            END_DATE NOT IN (SELECT MAX(END_DATE) FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID);


          EXCEPTION

            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'4 .NO PREVIOUS RECORD AVAILABLE IN JL_AR_TURN_UPL TABLE');
            END IF;
          END;

          l_START_DATE_SEC_MAX := NVL(l_START_DATE_SEC_MAX, l_START_DATE);
          l_END_DATE_SEC_MAX := NVL(l_END_DATE_SEC_MAX, l_END_DATE);


                                            -- To check the WHT_GROUP_NUM + wht_rate (TDD 9.4.A.  Additional Check 1)

          BEGIN

            SELECT 'TURN_BSAS_GRP' || lpad(WHT_GROUP_NUM, 2, '0'), WHT_RATE INTO l_WHT_GROUP_NUM_ALL, l_WHT_RATE_ALL
            FROM JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID GROUP BY WHT_RATE, WHT_GROUP_NUM;

            SELECT 'Y' INTO WHT_GROUP_NUM_rate_flag FROM AP_AWT_TAX_RATES_ALL
            WHERE tax_name = l_WHT_GROUP_NUM_ALL AND tax_rate = l_WHT_RATE_ALL;

            SELECT tax_id INTO l_tax_id FROM AP_TAX_CODES_ALL WHERE name = l_WHT_GROUP_NUM_ALL AND tax_type = 'AWT';

          EXCEPTION

            WHEN TOO_MANY_ROWS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'4 .MORE THAN ONE WHT_RATE AND WHT_GROUP_NUM FOUND FOR A TAX_PAYER_ID');
            END IF;
            UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_MANY_WHT_RATE_GROUP'
            WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
            RAISE_APPLICATION_ERROR(- 20999,'AN ERROR WAS ENCOUNTERED IN WHT_GROUP_NUM AND WHT_RATE VALIDATION '|| SQLCODE ||' -ERROR- '|| SQLERRM);

            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'5 .Wht Rate and Wht group for this record from Government File doesnt match with AP Wht Tax Setup.');
            END IF;
            UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JL_AR_AP_GRP_NO_MATCH'
            WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
            RAISE_APPLICATION_ERROR(- 20999,'AN ERROR WAS ENCOUNTERED IN WHT_GROUP_NUM AND WHT_RATE VALIDATION '|| SQLCODE ||' -ERROR- '|| SQLERRM);
          END;



          IF WHT_GROUP_NUM_rate_flag = 'N' THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'6 .Wht Rate and Wht group for this record from Government File doesnt match with AP Wht Tax Setup.');
            END IF;
            UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JL_AR_AP_GRP_NO_MATCH'
            WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
            RAISE_APPLICATION_ERROR(- 20999,'WHT_RATE AND WHT_GROUP_NUM FROM GOVERNMENT FILE DOESNT MATCH WITH AP WHT TAX SETUP '|| SQLCODE ||' -ERROR- '|| SQLERRM);

          END IF;

         /*
                                                        -- To compare JL_AR_TURN_UPL_T Upload Table records with JL_AR_TURN_UPL (9.4.A.3)

          BEGIN

            same_prev_rec_flag  := 'N';   --Intialising the value of same_prev_rec_flag everytime to check whether the record available already

            SELECT DISTINCT 'Y' INTO same_prev_rec_flag FROM JL_AR_TURN_UPL WHERE
            PUBLISH_DATE = l_PUBLISH_DATE
            AND START_DATE = l_START_DATE
            AND END_DATE = l_END_DATE
            AND TAXPAYER_ID = l_TAXPAYER_ID
            AND CONTRIBUTOR_TYPE_CODE = l_CONTRIBUTOR_TYPE_CODE
            AND NEW_CONTRIBUTOR_FLAG = l_NEW_CONTRIBUTOR_FLAG
            AND RATE_CHANGE_FLAG = l_RATE_CHANGE_FLAG
            AND PERCEPTION_RATE = l_PERCEPTION_RATE
            AND WHT_RATE = l_WHT_RATE
            AND PERCEPTION_GROUP_NUM = l_PERCEPTION_GROUP_NUM
            AND WHT_GROUP_NUM = l_WHT_GROUP_NUM;


	    IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'7 .THE VALUE FOR SAME_PREV_RECORD_FLAG:'||same_prev_rec_flag);
            END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'7A .NO CORRESPONDING DATA IN JL_AR_TURN_UPL');
            END IF;
            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'8 .FAILED WHILE CHECKING THE CORRESPONDING DATA IN JL_AR_TURN_UPL');
            END IF;
          END;

          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'9 .VALUE OF SAME_PREV_RECORD_FLAG :'|| same_prev_rec_flag);
          END IF;

                                            --  For exactly same records simply copying that to ALL table FROM TMP and fetching next record (TDD 3.1)

	  IF same_prev_rec_flag = 'Y' then
		 FND_FILE.PUT_LINE( FND_FILE.LOG,'10. Going to fetch next record as Taxpayer Id was already present');
                 GOTO L3;                     -- If the same exact Taxpayer value was already present in final table then simply fetch next record
          END IF;

         ---/*

          IF same_rec_flag = 'Y' THEN

            Insert_Row (l_PUBLISH_DATE,
                        l_START_DATE,
                        l_END_DATE,
                        l_TAXPAYER_ID,
                        l_CONTRIBUTOR_TYPE_CODE,
                        l_NEW_CONTRIBUTOR_FLAG,
                        l_RATE_CHANGE_FLAG,
                        l_PERCEPTION_RATE,
                        l_WHT_RATE,
                        l_PERCEPTION_GROUP_NUM,
                        l_WHT_GROUP_NUM,
                        l_WHT_DEFAULT_FLAG,
                        'AP');


        --delete JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID;

            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'10 .INSERTED DATA IN JL_AR_TURN_UPL SAME_REC_FLAG IS Y AND DELETED FROM TMP TABLE');
            END IF;

            GOTO L3;
                --fetching next record
          END IF;

         */
                                --To check whether TMP taxpayer id present already in previous months in ALL table  (3.2)

          BEGIN

            SELECT DISTINCT 'Y' INTO same_taxpayerid_flag FROM JL_AR_TURN_UPL WHERE
            PUBLISH_DATE <> l_PUBLISH_DATE
            AND START_DATE <> l_START_DATE
            AND END_DATE <> l_END_DATE
            AND TAXPAYER_ID = l_TAXPAYER_ID;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'12 .NO CORRESPONDING TAXPAYER_ID IN JL_AR_TURN_UPL');
            END IF;

            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'13 .FAILED WHILE CHECKING THE CORRESPONDING TAXPAYER_ID IN JL_AR_TURN_UPL');
            END IF;

          END;




          IF same_taxpayerid_flag = 'Y' AND l_RATE_CHANGE_FLAG = 'S' THEN
            wht_check_flag := 'N';

            BEGIN

              SELECT 'Y' INTO wht_check_flag FROM JL_AR_TURN_UPL WHERE
              TAXPAYER_ID = l_TAXPAYER_ID
              AND WHT_GROUP_NUM = l_WHT_GROUP_NUM
              AND WHT_RATE = l_WHT_RATE
              AND START_DATE = l_START_DATE_SEC_MAX
              AND END_DATE = l_END_DATE_SEC_MAX;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'14. NO CORRESPONDING DATA FOR l_WHT_GROUP_NUM AND l_WHT_RATE');
              END IF;
              WHEN OTHERS THEN
              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'15 .FAILED WHILE CHECKING THE CORRESPONDING DATA IN l_WHT_GROUP_NUM AND l_WHT_RATE');
              END IF;
            END;

                                                                   -- for records of same wht group/wht rate, simply copy (TDD 3.2.1.1)
           IF wht_check_flag = 'Y' THEN

              Insert_Row (l_PUBLISH_DATE,
                          l_START_DATE,
                          l_END_DATE,
                          l_TAXPAYER_ID,
                          l_CONTRIBUTOR_TYPE_CODE,
                          l_NEW_CONTRIBUTOR_FLAG,
                          l_RATE_CHANGE_FLAG,
                          l_PERCEPTION_RATE,
                          l_WHT_RATE,
                          l_PERCEPTION_GROUP_NUM,
                          l_WHT_GROUP_NUM,
                          l_WHT_DEFAULT_FLAG,
                          'AP');

            -- delete JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID;

              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'16 .INSERTED DATA IN TABLE JL_AR_TURN_UPL WHEN WHT_CHECK_FLAG IS Y ');
              END IF;
              GOTO L3;

                                                 -- If the wht rate and wht group are different (3.2.1.2) then UPDATE the tax SETups
           ELSE

             BEGIN

              SELECT SAWT.SUPP_AWT_TYPE_ID
              INTO l_SUPP_AWT_TYPE_ID_CD
              FROM PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
              WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
              AND NVL(pv.employee_id, - 99) = papf.person_id (+)
              AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
              AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
              AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'17. EFFECTIVE_END_DATE (l_START_DATE-1) : '|| l_START_DATE);
                FND_FILE.put_line( FND_FILE.LOG,'17. l_tax_id : '|| l_tax_id || 'l_TAXPAYER_ID : '|| l_TAXPAYER_ID);
              END IF;


              SELECT jl_zz_ap_sup_awt_cd_s.nextval INTO l_SUPP_AWT_CODE_ID_SEQ FROM dual;

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'18. l_SUPP_AWT_CODE_ID_SEQ'|| l_SUPP_AWT_CODE_ID_SEQ);
                FND_FILE.put_line( FND_FILE.LOG,'18. l_SUPP_AWT_TYPE_ID_CD'|| l_SUPP_AWT_TYPE_ID_CD);
              END IF;


               BEGIN
                  SELECT 'Y', SAWTC.SUPP_AWT_CODE_ID INTO taxtype_code_check, l_SUPP_AWT_CODE_ID_CD
                  FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC
                  WHERE SAWTC.SUPP_AWT_TYPE_ID = l_SUPP_AWT_TYPE_ID_CD
                  AND SAWTC.TAX_ID = l_tax_id
                  AND (SAWTC.EFFECTIVE_START_DATE = l_START_DATE    OR    SAWTC.EFFECTIVE_END_DATE = l_END_DATE);

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  taxtype_code_check := 'N';
                  WHEN OTHERS THEN
                  taxtype_code_check := 'N';
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'21. Error occured while fetching data in JL_ZZ_AP_SUP_AWT_CD_ALL');
                END;

              EXCEPTION
               WHEN OTHERS THEN
               FND_FILE.PUT_LINE( FND_FILE.LOG,'21. No records fetched from JL_ZZ_AP_SUP_AWT_CD_ALL for Taxpayer Id :||l_TAXPAYER_ID');

              END;


            IF taxtype_code_check = 'Y' THEN

             FND_FILE.PUT_LINE( FND_FILE.LOG,'21. Records already present in JL_ZZ_AP_SUP_AWT_CD_ALL table, no modifications');
             FND_FILE.PUT_LINE( FND_FILE.LOG,'21 . L_TAX_ID'|| L_TAX_ID || 'l_SUPP_AWT_TYPE_ID_CD' || l_SUPP_AWT_TYPE_ID_CD);
             FND_FILE.PUT_LINE( FND_FILE.LOG,'21 . L_EFFECTIVE_START_DATE'|| l_START_DATE || 'EFFECTIVE_END_DATE' || l_END_DATE);

            ELSE

             BEGIN
                                                             -- CODE TO UPDATE THE EFFECTIVE_END_DATE FOR OTHER PRIMARY_TAX_FLAG = 'Y' AND OTHER L_TAX_ID
              UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC SET SAWTC.EFFECTIVE_END_DATE = l_START_DATE - 1
              WHERE SAWTC.primary_tax_flag = 'Y'
              AND SAWTC.SUPP_AWT_CODE_ID <> l_SUPP_AWT_CODE_ID_SEQ
              AND SAWTC.SUPP_AWT_TYPE_ID = l_SUPP_AWT_TYPE_ID_CD
                --AND SAWTC.TAX_ID <> l_tax_id -- other l_tax_id
              AND SAWTC.EFFECTIVE_END_DATE IS NULL;


              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'19 .UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR '|| SQL%ROWCOUNT || 'RECORDS');
                FND_FILE.PUT_LINE( FND_FILE.LOG,'19. EFFECTIVE_END_DATE (L_START_DATE-1) : '|| L_START_DATE);
                FND_FILE.PUT_LINE( FND_FILE.LOG,'19. L_TAX_ID : '|| L_TAX_ID || ' L_TAXPAYER_ID : '|| L_TAXPAYER_ID);
              END IF;



                INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL
                (SUPP_AWT_CODE_ID,
                 SUPP_AWT_TYPE_ID,
                 TAX_ID,
                 PRIMARY_TAX_FLAG,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN,
                 ORG_ID,
                 EFFECTIVE_START_DATE,
                 EFFECTIVE_END_DATE)
                VALUES
                (l_SUPP_AWT_CODE_ID_SEQ, --SUPP_AWT_CODE_ID
                 l_SUPP_AWT_TYPE_ID_CD, --SUPP_AWT_TYPE_ID
                 l_tax_id, --TAX_ID
                 'Y', --PRIMARY_TAX_FLAG
                 l_created_by, --CREATED_BY
                 l_creation_DATE, --CREATION_DATE
                 l_last_UPDATEd_by, --LAST_UPDATED_BY
                 l_last_UPDATE_DATE, --LAST_UPDATE_DATE
                 l_last_UPDATE_login, --LAST_UPDATE_LOGIN
                 l_ORG_ID, --ORG_ID
                 l_START_DATE, --EFFECTIVE_START_DATE
                 NULL); --EFFECTIVE_END_DATE


                IF p_debug_log = 'Y' THEN
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'21 . INSERTED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR '|| SQL%ROWCOUNT || 'RECORDS');
                END IF;


               EXCEPTION
                 WHEN OTHERS THEN

                IF p_debug_log = 'Y' THEN
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'21. INSERT NOT DONE IN JL_ZZ_AP_SUP_AWT_CD_ALL '|| SQLCODE ||' -ERROR- '|| SQLERRM);
                END IF;
              END;

            END IF;

                                                      -- CODE TO UPDATE/INSERT  JL_ZZ_AP_INV_DIS_WH_ALL (TDD 3.2.1.1)

              BEGIN
                                                      -- TO GET THE CURRENT MONTH SUPP_AWT_CODE_ID FOR THE PRESENT TAX_ID

                SELECT SAWTC.SUPP_AWT_CODE_ID INTO l_SUPP_AWT_CODE_ID_CD
                FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC,
                PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
                WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
                AND NVL(pv.employee_id, - 99) = papf.person_id (+)
                AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
                AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
                AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
                AND SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                --AND SAWTC.TAX_ID in (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name like 'TURN_BSAS_GRP%')
                AND SAWTC.TAX_ID = l_tax_id
                AND SAWTC.EFFECTIVE_START_DATE = l_START_DATE
                AND SAWTC.primary_tax_flag = 'Y'
                AND sawtc.effective_end_DATE IS NULL
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

                SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

              EXCEPTION
                WHEN OTHERS THEN
                IF p_debug_log = 'Y' THEN
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'22 B SELECT TAX CODE NOT DONE FOR JL_ZZ_AP_INV_DIS_WH_ALL - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
                END IF;
              END;

              OPEN CUR3(l_TAXPAYER_ID);
              LOOP
                FETCH CUR3 INTO INV_REC;
                EXIT WHEN CUR3%NOTFOUND;



                BEGIN

                  AWT_CODE_INV_AVAIL_FLAG := 'N';

                  SELECT 'Y', INV_DISTRIB_AWT_ID INTO AWT_CODE_INV_AVAIL_FLAG, l_INV_DISTRIB_AWT_ID_DIS
                  FROM JL_ZZ_AP_INV_DIS_WH_ALL
                  WHERE INVOICE_ID = INV_REC.INVOICE_ID
                  AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
		  AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
                  AND SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;
                 /*(SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
                   WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                   -- AND SAWTC.EFFECTIVE_START_DATE = l_START_DATE
                   AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%'));  */

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  AWT_CODE_INV_AVAIL_FLAG := 'N';
                  FND_FILE.put_line( FND_FILE.LOG,'22 B No earlier same tax code id in Inv Dist'|| SQLCODE ||' -ERROR- '|| SQLERRM);

                  WHEN OTHERS THEN
                  AWT_CODE_INV_AVAIL_FLAG := 'N';
                  FND_FILE.put_line( FND_FILE.LOG,'22 B Error in Inv Dist'|| SQLCODE ||' -ERROR- '|| SQLERRM);
                END;



                IF AWT_CODE_INV_AVAIL_FLAG = 'N' THEN

                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'22 B l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                    FND_FILE.put_line( FND_FILE.LOG,'22 B INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                    FND_FILE.put_line( FND_FILE.LOG,'22 B INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                    FND_FILE.put_line( FND_FILE.LOG,'22 B l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
                    FND_FILE.put_line( FND_FILE.LOG,'22 B INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
                  END IF;

                  BEGIN                                               ---code to insert data INTO  jl_zz_ap_inv_dis_wh_all

                    INSERT INTO JL_ZZ_AP_INV_DIS_WH_ALL
                    (INV_DISTRIB_AWT_ID,
                     INVOICE_ID,
                     DISTRIBUTION_LINE_NUMBER,
                     SUPP_AWT_CODE_ID,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN,
                     ORG_ID,
		     INVOICE_DISTRIBUTION_ID)
                    VALUES
                    (l_INV_DISTRIB_AWT_ID_INV, --INV_DISTRIB_AWT_ID
                     INV_REC.INVOICE_ID, --INVOICE_ID
                     INV_REC.DISTRIBUTION_LINE_NUMBER, --DISTRIBUTION_LINE_NUMBER
                     l_SUPP_AWT_CODE_ID_CD, --SUPP_AWT_CODE_ID
                     l_created_by, --CREATED_BY
                     l_creation_DATE, --CREATION_DATE
                     l_last_UPDATEd_by, --LAST_UPDATED_BY
                     l_last_UPDATE_DATE, --LAST_UPDATE_DATE
                     l_last_UPDATE_login, --LAST_UPDATE_LOGIN
                     l_ORG_ID, --ORG_ID
		     INV_REC.INVOICE_DISTRIBUTION_ID);   --Invoice distribution ID         -- R12 Changes



                    SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

                    IF p_debug_log = 'Y' THEN
                      FND_FILE.put_line( FND_FILE.LOG,'22. C '|| SQL%ROWCOUNT ||'Inserted records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                    END IF;

                  EXCEPTION
                    WHEN OTHERS THEN
                    IF p_debug_log = 'Y' THEN
                      FND_FILE.put_line( FND_FILE.LOG,'22. C Failed while Inserted records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                    END IF;
                  END;

                ELSE

                  BEGIN
                    IF p_debug_log = 'Y' THEN
                      FND_FILE.put_line( FND_FILE.LOG,'23 A l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                      FND_FILE.put_line( FND_FILE.LOG,'23 A INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                      FND_FILE.put_line( FND_FILE.LOG,'23 A INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                      FND_FILE.put_line( FND_FILE.LOG,'23 A l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
                      FND_FILE.put_line( FND_FILE.LOG,'23 A l_INV_DISTRIB_AWT_ID_DIS'|| l_INV_DISTRIB_AWT_ID_DIS);
                      FND_FILE.put_line( FND_FILE.LOG,'23 A INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
                    END IF;

                    /*SELECT INV_DISTRIB_AWT_ID INTO l_INV_DISTRIB_AWT_ID_DIS
                    FROM JL_ZZ_AP_INV_DIS_WH_ALL
                    WHERE INVOICE_ID = INV_REC.INVOICE_ID
                    AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
		    AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
                    AND SUPP_AWT_CODE_ID IN
                    (SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
                     WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                     AND SAWTC.primary_tax_flag = 'Y'
                     AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')
                     AND sawtc.effective_end_DATE IS NULL);*/


                    UPDATE JL_ZZ_AP_INV_DIS_WH_ALL SET SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD
                    WHERE INV_DISTRIB_AWT_ID = l_INV_DISTRIB_AWT_ID_DIS;

                    IF p_debug_log = 'Y' THEN
                      FND_FILE.put_line( FND_FILE.LOG,'23 B. Updated '|| SQL%ROWCOUNT ||' records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                      FND_FILE.put_line( FND_FILE.LOG,'23 B. l_SUPP_AWT_CODE_ID_CD:'|| l_SUPP_AWT_CODE_ID_CD);
                      FND_FILE.put_line( FND_FILE.LOG,'23 B. l_INV_DISTRIB_AWT_ID_DIS:'|| l_INV_DISTRIB_AWT_ID_DIS);
                    END IF;

                   EXCEPTION
                    WHEN OTHERS THEN
                    IF p_debug_log = 'Y' THEN
                      FND_FILE.put_line( FND_FILE.LOG,'23 B. Failed while updating records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                    END IF;
                  END;

                END IF;

              END LOOP;
              CLOSE CUR3;

              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'24. UPDATED DATA IN JL_ZZ_AP_INV_DIS_WH_ALL FOR SUPP_AWT_CODE_ID ');
              END IF;



              Insert_Row (l_PUBLISH_DATE,
                          l_START_DATE,
                          l_END_DATE,
                          l_TAXPAYER_ID,
                          l_CONTRIBUTOR_TYPE_CODE,
                          l_NEW_CONTRIBUTOR_FLAG,
                          l_RATE_CHANGE_FLAG,
                          l_PERCEPTION_RATE,
                          l_WHT_RATE,
                          l_PERCEPTION_GROUP_NUM,
                          l_WHT_GROUP_NUM,
                          l_WHT_DEFAULT_FLAG,
                          'AP');

               -- delete JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID;

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'26 . Inserted data in JL_AR_TURN_UPL for All Records ');
              END IF;

            END IF;

            GOTO L3;

                                                                  --code to insert in ALL table for rate_change_flag N  (TDD 3.2.2)

          ELSIF same_taxpayerid_flag = 'Y' AND l_RATE_CHANGE_FLAG = 'N' THEN

            Insert_Row (l_PUBLISH_DATE,
                        l_START_DATE,
                        l_END_DATE,
                        l_TAXPAYER_ID,
                        l_CONTRIBUTOR_TYPE_CODE,
                        l_NEW_CONTRIBUTOR_FLAG,
                        l_RATE_CHANGE_FLAG,
                        l_PERCEPTION_RATE,
                        l_WHT_RATE,
                        l_PERCEPTION_GROUP_NUM,
                        l_WHT_GROUP_NUM,
                        l_WHT_DEFAULT_FLAG,
                        'AP');

            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'28. Inserted data in JL_AR_TURN_UPL when same_rec_flag is N AND l_RATE_CHANGE_FLAG is N');
              FND_FILE.put_line( FND_FILE.LOG,'Fetching Record Record after Taxpayer Id '|| l_TAXPAYER_ID);
            END IF;
      --delete JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID;
              --GOTO L3;

          END IF;
                               -- To check the data EXIST in JL_AR_TURN_UPL_T, but DO NOT EXIST in JL_AR_TURN_UPL table  (TDD 3.3)


          BEGIN

            SELECT 'Y' INTO exist_check_flag FROM JL_AR_TURN_UPL
            WHERE TAXPAYER_ID NOT IN (SELECT TAXPAYER_ID FROM JL_AR_TURN_UPL_T WHERE START_DATE = l_START_DATE
                                      AND END_DATE = l_END_DATE
                                      AND PUBLISH_DATE = l_PUBLISH_DATE
                                      AND TAXPAYER_ID = l_TAXPAYER_ID);

          EXCEPTION

            WHEN NO_DATA_FOUND THEN
            exist_check_flag := 'Y';
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,' 29 . NO DATA EXIST IN TMP TABLE OTHER THAN ALL TABLE DATA');
            END IF;
            WHEN OTHERS THEN
            exist_check_flag := 'Y';
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,' 30 .FAILED IN EXIST_CHECK_FLAG VALIDATION'|| EXIST_CHECK_FLAG);
            END IF;

          END;

          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,' 31 . EXIST_CHECK_FLAG'|| EXIST_CHECK_FLAG);
          END IF;

          SELECT MAX(START_DATE) INTO l_START_DATE_SEC_MAX FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID AND
          START_DATE NOT IN (SELECT MAX(START_DATE) FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID);

          SELECT MAX(END_DATE) INTO l_END_DATE_SEC_MAX FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID AND
          END_DATE NOT IN (SELECT MAX(END_DATE) FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID);




          IF exist_check_flag = 'Y' THEN
            wht_check_unique := 'Y';

            BEGIN

              SELECT 'N' INTO wht_check_unique FROM JL_AR_TURN_UPL_T WHERE
              TAXPAYER_ID = l_TAXPAYER_ID
              AND WHT_GROUP_NUM = l_WHT_GROUP_NUM
              AND WHT_RATE = l_WHT_RATE;

            EXCEPTION

              WHEN NO_DATA_FOUND THEN
              wht_check_unique := 'N';

              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,' 32 .NO DATA IN WHT_CHECK_FLAG IN JL_AR_TURN_UPL');
              END IF;

              WHEN OTHERS THEN
              wht_check_unique := 'Y';
              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'33 .FAILED IN WHT_CHECK_FLAG VALIDATION');
              END IF;
              RAISE_APPLICATION_ERROR(- 20999,'FAILED IN WHT_CHECK_FLAG VALIDATION '|| SQLCODE ||' -ERROR- '|| SQLERRM);
            END;


          END IF;
          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,' 31 . WHT_CHECK_UNIQUE'|| WHT_CHECK_UNIQUE);
          END IF;
                                                              -- If the wht_rate/WHT_GROUP_NUM in TMP were not unique then raise error (3.3.1)

          IF wht_check_unique = 'Y' THEN

            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'  33  WHT_rate and WHT_GROUP_NUM FROM government file was not unique');
            END IF;

            UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JL_AR_GRP_NOT_UNIQUE'
            WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;
            RAISE_APPLICATION_ERROR(- 20999,'33  A An error was encountered in JL_AR_GRP_NOT_UNIQUE- '|| SQLCODE ||' -ERROR- '|| SQLERRM);
            GOTO L3;
                                                    --raise error and fetch next record.

          ELSE --- If wht unique then INSERT INTO JL_ZZ_AP_SUPP_AWT_TYPES  (3.3.2)

            BEGIN

              SELECT JL_ZZ_AP_SUPP_AWT_TYPES_s.nextval INTO l_SUPP_AWT_TYPE_ID_TYPES FROM dual;

              SELECT PV.VENDOR_ID INTO l_VENDOR_ID FROM PO_VENDORS PV, PER_ALL_PEOPLE_F PAPF
              WHERE NVL(pv.employee_id, - 99) = papf.person_id (+)
              AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
              AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'34 . l_SUPP_AWT_TYPE_ID_TYPES'|| l_SUPP_AWT_TYPE_ID_TYPES || 'and' || 'l_VENDOR_ID' || l_VENDOR_ID);
              END IF;

              INSERT INTO JL_ZZ_AP_SUPP_AWT_TYPES(
                                                  SUPP_AWT_TYPE_ID,
                                                  VENDOR_ID,
                                                  AWT_TYPE_CODE,
                                                  WH_SUBJECT_FLAG,
                                                  CREATED_BY,
                                                  CREATION_DATE,
                                                  LAST_UPDATED_BY,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATE_LOGIN)
              VALUES
              (l_SUPP_AWT_TYPE_ID_TYPES, --SUPP_AWT_TYPE_ID,
               l_VENDOR_ID, --VENDOR_ID
               'TURN_BSAS', --AWT_TYPE_CODE
               'Y', --WH_SUBJECT_FLAG
               l_created_by, --CREATED_BY
               l_creation_DATE, --CREATION_DATE
               l_last_UPDATEd_by, --LAST_UPDATED_BY
               l_last_UPDATE_DATE, --LAST_UPDATE_DATE
               l_last_UPDATE_login); --LAST_UPDATE_LOGIN

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'34 . Inserted data in JL_ZZ_AP_SUPP_AWT_TYPES for '|| SQL%ROWCOUNT ||' Records');
              END IF;

            EXCEPTION
              WHEN OTHERS THEN

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'35 .Insert in JL_ZZ_AP_SUPP_AWT_TYPES not done - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
              END IF;

            END;



            BEGIN
                                                                --- TO INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL   (3.3.2)

              SELECT SAWT.SUPP_AWT_TYPE_ID
              INTO l_SUPP_AWT_TYPE_ID_CD
              FROM PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
              WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
              AND NVL(pv.employee_id, - 99) = papf.person_id (+)
              AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
              AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
              AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'36. EFFECTIVE_END_DATE (l_START_DATE-1) : '|| l_START_DATE);
                FND_FILE.put_line( FND_FILE.LOG,'36. l_tax_id : '|| l_tax_id || 'l_TAXPAYER_ID : '|| l_TAXPAYER_ID);
              END IF;


              SELECT jl_zz_ap_sup_awt_cd_s.nextval INTO l_SUPP_AWT_CODE_ID_SEQ FROM dual;

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'37. l_SUPP_AWT_CODE_ID_SEQ'|| l_SUPP_AWT_CODE_ID_SEQ);
                FND_FILE.put_line( FND_FILE.LOG,'37. l_SUPP_AWT_TYPE_ID_CD'|| l_SUPP_AWT_TYPE_ID_CD);
              END IF;
                                                             -- code to UPDATE the EFFECTIVE_END_DATE for other primary_tax_flag = 'Y' and other l_tax_id

              UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC SET SAWTC.EFFECTIVE_END_DATE = l_START_DATE - 1
              WHERE SAWTC.primary_tax_flag = 'Y'
              AND SAWTC.SUPP_AWT_CODE_ID <> l_SUPP_AWT_CODE_ID_SEQ
              AND SAWTC.SUPP_AWT_TYPE_ID = l_SUPP_AWT_TYPE_ID_CD
                --AND SAWTC.TAX_ID <> l_tax_id -- other l_tax_id
              AND SAWTC.EFFECTIVE_END_DATE IS NULL;

              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'38 .UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR '|| SQL%ROWCOUNT || 'RECORDS');
                FND_FILE.PUT_LINE( FND_FILE.LOG,'38. EFFECTIVE_END_DATE (L_START_DATE-1) : '|| L_START_DATE);
                FND_FILE.PUT_LINE( FND_FILE.LOG,'38. L_TAX_ID : '|| L_TAX_ID || 'for  L_TAXPAYER_ID : '|| L_TAXPAYER_ID);

              END IF;


              INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL
              (SUPP_AWT_CODE_ID,
               SUPP_AWT_TYPE_ID,
               TAX_ID,
               PRIMARY_TAX_FLAG,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               ORG_ID,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE)
              VALUES
              (l_SUPP_AWT_CODE_ID_SEQ, --SUPP_AWT_CODE_ID
               l_SUPP_AWT_TYPE_ID_CD, --SUPP_AWT_TYPE_ID
               l_tax_id, --TAX_ID
               'Y', --PRIMARY_TAX_FLAG
               l_created_by, --CREATED_BY
               l_creation_DATE, --CREATION_DATE
               l_last_UPDATEd_by, --LAST_UPDATED_BY
               l_last_UPDATE_DATE, --LAST_UPDATE_DATE
               l_last_UPDATE_login, --LAST_UPDATE_LOGIN
               l_ORG_ID, --ORG_ID
               l_START_DATE, --EFFECTIVE_START_DATE
               NULL); --EFFECTIVE_END_DATE


              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'38 . Inserted data in JL_ZZ_AP_SUP_AWT_CD_ALL for '|| SQL%ROWCOUNT ||' Records and code id is :'|| l_SUPP_AWT_TYPE_ID_CD);
              END IF;

              COMMIT;


            EXCEPTION
              WHEN OTHERS THEN

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'39 . Failed to INSERT into JL_ZZ_AP_SUP_AWT_CD_ALL  Insert not done '|| SQLCODE || 'ERROR' || SQLERRM);
              END IF;


              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'39. l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
              END IF;

              BEGIN
                SELECT 'Y', SAWTC.SUPP_AWT_CODE_ID INTO taxtype_code_check, l_SUPP_AWT_CODE_ID_CD
                FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC
                WHERE SAWTC.SUPP_AWT_TYPE_ID = l_SUPP_AWT_TYPE_ID_CD
                AND SAWTC.TAX_ID = l_tax_id;
                --AND (SAWTC.EFFECTIVE_START_DATE = l_START_DATE    OR    SAWTC.EFFECTIVE_END_DATE = l_END_DATE);


              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                taxtype_code_check := 'N';
              END;

              IF taxtype_code_check = 'Y' THEN

                UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SET EFFECTIVE_END_DATE = NULL
                WHERE SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'40 Records already present in JL_ZZ_AP_SUP_AWT_CD_ALL table TYPE ID'|| l_SUPP_AWT_TYPE_ID_CD);
                FND_FILE.PUT_LINE( FND_FILE.LOG,'40. l_tax_id'|| l_tax_id || 'L_EFFECTIVE_START_DATE' || L_START_DATE);


                NULL;
              ELSE
                                                          ----If insertion fails, then will do the UPDATE in awt_cd_all
                UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SET
                TAX_ID = l_tax_id,
                PRIMARY_TAX_FLAG = 'Y',
                EFFECTIVE_START_DATE = l_START_DATE,
                EFFECTIVE_END_DATE = NULL
                WHERE SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;

              END IF;

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'41 . l_tax_id'|| l_tax_id || 'l_EFFECTIVE_START_DATE' || l_START_DATE);
                FND_FILE.PUT_LINE( FND_FILE.LOG,'41 . UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL for '|| SQL%ROWCOUNT ||' Records and code id is :'|| l_SUPP_AWT_TYPE_ID_CD);
              END IF;

            END;


            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'42 . l_tax_id'|| l_tax_id || 'l_SUPP_AWT_CODE_ID_CD' || l_SUPP_AWT_CODE_ID_CD || 'l_EFFECTIVE_START_DATE-1' || l_START_DATE);
              FND_FILE.PUT_LINE( FND_FILE.LOG,'42 . UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR PRIMARY_TAX_FLAG AS N AND EFFECTIVE_START_DATE FOR '|| SQL%ROWCOUNT ||' RECORDS');
            END IF;

                                                              -- Code to insert/UPDATE JL_ZZ_AP_INV_DIS_WH_ALL  (TDD 3.3.2)


            BEGIN
                                                              -- To get the current month Supp_Awt_Code_id for the present tax_id

              SELECT SAWTC.SUPP_AWT_CODE_ID INTO l_SUPP_AWT_CODE_ID_CD
              FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC,
              PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
              WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
              AND NVL(pv.employee_id, - 99) = papf.person_id (+)
              AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
              AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
              AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
              AND SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                --AND SAWTC.TAX_ID in (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name like 'TURN_BSAS_GRP%')
              AND SAWTC.TAX_ID = l_tax_id
              AND SAWTC.primary_tax_flag = 'Y'
              AND SAWTC.EFFECTIVE_START_DATE = l_START_DATE
              AND sawtc.effective_end_DATE IS NULL
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

              SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

            EXCEPTION
              WHEN OTHERS THEN
              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'43 UPDATE NOT DONE FOR JL_ZZ_AP_INV_DIS_WH_ALL - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
              END IF;
            END;

            OPEN CUR3(l_TAXPAYER_ID);
            LOOP
              FETCH CUR3 INTO INV_REC;
              EXIT WHEN CUR3%NOTFOUND;


              BEGIN

                AWT_CODE_INV_AVAIL_FLAG := 'N';

                SELECT 'Y', INV_DISTRIB_AWT_ID INTO AWT_CODE_INV_AVAIL_FLAG, l_INV_DISTRIB_AWT_ID_DIS
                FROM JL_ZZ_AP_INV_DIS_WH_ALL
                WHERE INVOICE_ID = INV_REC.INVOICE_ID
                AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
		AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
                AND SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;
                /*(SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
                 WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                 AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')); */

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                AWT_CODE_INV_AVAIL_FLAG := 'N';
                FND_FILE.put_line( FND_FILE.LOG,'44 No earlier data in Inv Dist for this Invoice'|| SQLCODE ||' -ERROR- '|| SQLERRM);

                WHEN OTHERS THEN
                AWT_CODE_INV_AVAIL_FLAG := 'N';
                FND_FILE.put_line( FND_FILE.LOG,'44 Error in Inv Dist select'|| SQLCODE ||' -ERROR- '|| SQLERRM);
              END;

              IF AWT_CODE_INV_AVAIL_FLAG = 'N' THEN

                IF p_debug_log = 'Y' THEN
                  FND_FILE.put_line( FND_FILE.LOG,'45 l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                  FND_FILE.put_line( FND_FILE.LOG,'45 INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                  FND_FILE.put_line( FND_FILE.LOG,'45 INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                  FND_FILE.put_line( FND_FILE.LOG,'45 l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
                  FND_FILE.put_line( FND_FILE.LOG,'45 INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
                END IF;
                                                                         ---code to insert data INTO  jl_zz_ap_inv_dis_wh_all
                BEGIN

                  INSERT INTO JL_ZZ_AP_INV_DIS_WH_ALL
                  (INV_DISTRIB_AWT_ID,
                   INVOICE_ID,
                   DISTRIBUTION_LINE_NUMBER,
                   SUPP_AWT_CODE_ID,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   ORG_ID,
		   INVOICE_DISTRIBUTION_ID)
                  VALUES
                  (l_INV_DISTRIB_AWT_ID_INV, --INV_DISTRIB_AWT_ID
                   INV_REC.INVOICE_ID, --INVOICE_ID
                   INV_REC.DISTRIBUTION_LINE_NUMBER, --DISTRIBUTION_LINE_NUMBER
                   l_SUPP_AWT_CODE_ID_CD, --SUPP_AWT_CODE_ID
                   l_created_by, --CREATED_BY
                   l_creation_DATE, --CREATION_DATE
                   l_last_UPDATEd_by, --LAST_UPDATED_BY
                   l_last_UPDATE_DATE, --LAST_UPDATE_DATE
                   l_last_UPDATE_login, --LAST_UPDATE_LOGIN
                   l_ORG_ID, --ORG_ID
                   INV_REC.INVOICE_DISTRIBUTION_ID);   --Invoice distribution ID         -- R12 Changes




                  SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'45 A. '|| SQL%ROWCOUNT ||'Inserted records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                  END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'45 A. Failed while Inserting records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                  END IF;
                END;
              ELSE
                BEGIN
                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'45 B l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                    FND_FILE.put_line( FND_FILE.LOG,'45 B INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                    FND_FILE.put_line( FND_FILE.LOG,'45 B INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                    FND_FILE.put_line( FND_FILE.LOG,'45 B l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
                    FND_FILE.put_line( FND_FILE.LOG,'45 B l_INV_DISTRIB_AWT_ID_DIS'|| l_INV_DISTRIB_AWT_ID_DIS);
                    FND_FILE.put_line( FND_FILE.LOG,'45 B INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
                  END IF;

                    /*SELECT INV_DISTRIB_AWT_ID INTO l_INV_DISTRIB_AWT_ID_DIS
                    FROM JL_ZZ_AP_INV_DIS_WH_ALL
                    WHERE INVOICE_ID = INV_REC.INVOICE_ID
                    AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
		    AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
                    AND SUPP_AWT_CODE_ID IN
                    (SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
                     WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                     AND SAWTC.primary_tax_flag = 'Y'
                     AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')
                     AND sawtc.effective_end_DATE IS NULL);*/


                  UPDATE JL_ZZ_AP_INV_DIS_WH_ALL SET SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD
                  WHERE INV_DISTRIB_AWT_ID = l_INV_DISTRIB_AWT_ID_DIS;

                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'46 A. Updated '|| SQL%ROWCOUNT ||' records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                    FND_FILE.put_line( FND_FILE.LOG,'46 A. l_SUPP_AWT_CODE_ID_CD:'|| l_SUPP_AWT_CODE_ID_CD);
                    FND_FILE.put_line( FND_FILE.LOG,'46 A. l_INV_DISTRIB_AWT_ID_DIS:'|| l_INV_DISTRIB_AWT_ID_DIS);
                  END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                  IF p_debug_log = 'Y' THEN
                    FND_FILE.put_line( FND_FILE.LOG,'46 B. Failed while updating records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                  END IF;
                END;

              END IF;

            END LOOP;
            CLOSE CUR3;

            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'46 C. UPDATED DATA IN JL_ZZ_AP_INV_DIS_WH_ALL FOR SUPP_AWT_CODE_ID ');
            END IF;



            Insert_Row (l_PUBLISH_DATE,
                        l_START_DATE,
                        l_END_DATE,
                        l_TAXPAYER_ID,
                        l_CONTRIBUTOR_TYPE_CODE,
                        l_NEW_CONTRIBUTOR_FLAG,
                        l_RATE_CHANGE_FLAG,
                        l_PERCEPTION_RATE,
                        l_WHT_RATE,
                        l_PERCEPTION_GROUP_NUM,
                        l_WHT_GROUP_NUM,
                        l_WHT_DEFAULT_FLAG,
                        'AP');

             -- delete JL_AR_TURN_UPL_T WHERE TAXPAYER_ID = l_TAXPAYER_ID;

            IF p_debug_log = 'Y' THEN
              FND_FILE.put_line( FND_FILE.LOG,'47 . Inserted data in JL_AR_TURN_UPL for All Records ');
            END IF;

          END IF;

        END IF; -- AP coding and validation was completed here


        <<L3>>

        NULL;

--Re Initialising the FLAGS:
-----------------------------

        duplicate_check_count     := NULL;
        wht_check_unique          := 'Y';
        duplicate_check_flag      := 'N';
        same_rec_flag             := 'N';
        wht_check_flag            := 'N';
        exist_check_flag          := 'N';
        WHT_GROUP_NUM_rate_flag   := 'N';
        same_taxpayerid_flag      := 'N';
        taxtype_code_check        := 'N';
        l_taxpayer                := 'N';
        l_taxpayer_ar             := 'N';
        AWT_CODE_INV_AVAIL_FLAG   := 'N';

      EXCEPTION
        WHEN OTHERS THEN
        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'49 .TAXPAYER ID FAILED IN FINAL VALIDATION, FETCHING NEXT RECORD - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
        END IF;
        UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_RECORD_FAILED_FINAL_CHECK'
        WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;

      END;


      COMMIT;

    END LOOP;
    CLOSE C3;




  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'49 .AN ERROR WAS ENCOUNTERED WHEN FINAL VALIDATION - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END IF;
    UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_RECORD_FAILED_FINAL_CHECK'
    WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;

  END FINAL_VALIDATION;



                                                                -- Default Setup for records not present in current TMP file (TDD 9.4.B)

  PROCEDURE VALIDATE_AWT_SETUP
  IS


  l_PUBLISH_DATE            DATE;
  l_START_DATE              DATE;
  l_END_DATE                DATE;
  l_TAXPAYER_ID             NUMBER(15);
  l_CONTRIBUTOR_TYPE_CODE   VARCHAR2(1);
  l_NEW_CONTRIBUTOR_FLAG    VARCHAR2(1);
  l_RATE_CHANGE_FLAG        VARCHAR2(1);
  l_PERCEPTION_RATE         NUMBER(15,2);
  l_WHT_RATE                NUMBER(15,2);
  l_PERCEPTION_GROUP_NUM    NUMBER(15);
  l_WHT_GROUP_NUM           NUMBER(15);
  l_WHT_DEFAULT_FLAG        VARCHAR2(1);

  l_TAXPAYER_ID_ALL         NUMBER(15);
  l_START_DATE_CURR_MAX     DATE;
  l_START_DATE_SEC_MAX      DATE := NULL;
  l_END_DATE_SEC_MAX        DATE := NULL;
  l_END_DATE_CURR_MAX       DATE;
  l_PUBLISH_DATE_CURR_MAX   DATE;
  l_EFFECTIVE_START_DATE    DATE;
  l_WHT_GROUP_NUM_DEF_NO    NUMBER;
  def_taxtype_code_check    VARCHAR2(1) := 'N';
  AWT_CODE_INV_AVAIL_FLAG   VARCHAR2(1) := 'N';

  l_WHT_GROUP_NUM_DEF_ATC               AP_TAX_CODES_ALL.NAME%TYPE;
  l_TAX_ID_DEF_ATC                      AP_TAX_CODES_ALL.TAX_ID%TYPE;
  l_WHT_RATE_DEF_ATR                    AP_AWT_TAX_RATES_ALL.TAX_RATE%TYPE;
  ALL_REC                               JL_AR_TURN_UPL%ROWTYPE;

  l_SUPP_AWT_CODE_ID_CD                 JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_CODE_ID%TYPE;
  l_SUPP_AWT_TYPE_ID_CD                 JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_TYPE_ID%TYPE;
  l_tax_id                              ap_tax_codes.tax_id%TYPE;
  l_SUPP_AWT_TYPE_ID_TYPES              JL_ZZ_AP_SUPP_AWT_TYPES.SUPP_AWT_TYPE_ID%TYPE;
  l_VENDOR_ID                           PO_VENDORS.VENDOR_ID%TYPE;
  l_INV_DISTRIB_AWT_ID_INV              JL_ZZ_AP_INV_DIS_WH_ALL.INV_DISTRIB_AWT_ID%TYPE;
  l_INVOICE_ID_INA                      AP_INVOICES_ALL.INVOICE_ID%TYPE;
  l_DISTRIBUTION_LINE_NUMBER_IND        AP_INVOICE_DISTRIBUTIONS_ALL.DISTRIBUTION_LINE_NUMBER%TYPE;
  l_INVOICE_DISTRIBUTION_ID_IND         AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE;
  l_INV_DISTRIB_AWT_ID_DIS              JL_ZZ_AP_INV_DIS_WH_ALL.INV_DISTRIB_AWT_ID%TYPE;
  l_SUPP_AWT_CODE_ID_SEQ                JL_ZZ_AP_SUP_AWT_CD_ALL.SUPP_AWT_CODE_ID%TYPE;


--WHO COLUMNS:
-----------------

  l_created_by          NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_creation_DATE       DATE := SYSDATE;
  l_last_UPDATEd_by     NUMBER(15) := NVL(fnd_profile.value('USER_ID'), 1);
  l_last_UPDATE_DATE    DATE := SYSDATE;
  l_last_UPDATE_login   NUMBER(15) := NVL(fnd_global.conc_login_id, 1);
  l_ORG_ID              NUMBER(15) := oe_profile.value('SO_ORGANIZATION_ID'); -- :=   3687;


  CURSOR CUR4(l_TAXPAYERID_C NUMBER) IS
  SELECT APINA.INVOICE_ID, APIND.DISTRIBUTION_LINE_NUMBER, APIND.INVOICE_DISTRIBUTION_ID
  FROM PO_VENDORS PV, AP_INVOICES_ALL APINA,
  AP_INVOICE_DISTRIBUTIONS_ALL APIND, PER_ALL_PEOPLE_F PAPF
  WHERE PV.VENDOR_ID = APINA.VENDOR_ID
  AND NVL(pv.employee_id, - 99) = papf.person_id (+)
  AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
  AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
        --AND APIND.TAX_CODE_ID in (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name like 'TURN_BSAS_GRP%')
  AND APINA.INVOICE_ID = APIND.INVOICE_ID
  AND APIND.LINE_TYPE_LOOKUP_CODE = 'ITEM'
  AND APIND.GLOBAL_ATTRIBUTE3 IN
  (SELECT LOCATION_ID FROM HR_LOCATIONS_ALL WHERE UPPER(LOCATION_CODE) = 'BUENOS AIRES' AND trunc(SYSDATE) <= NVL(inactive_DATE, trunc(SYSDATE))) --bug 8622329
  AND APINA.INVOICE_ID = APIND.INVOICE_ID
  AND NVL(APINA.INVOICE_AMOUNT,0) <> NVL(APINA.AMOUNT_PAID,0)
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYERID_C);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYERID_C);

  INV_REC CUR4%ROWTYPE;


                                                                -- To get the datas (having the MAX start DATE- current) FROM ALL table

  CURSOR C4(l_START_DATE_CURR_MAX DATE) IS
  SELECT * FROM JL_AR_TURN_UPL WHERE START_DATE <> l_START_DATE_CURR_MAX;

  V_ALLREC C4%ROWTYPE;




  BEGIN

    BEGIN
      SELECT MAX(START_DATE) INTO l_START_DATE_CURR_MAX FROM JL_AR_TURN_UPL;
      SELECT MAX(END_DATE) INTO l_END_DATE_CURR_MAX FROM JL_AR_TURN_UPL;
  --SELECT MAX(PUBLISH_DATE) INTO l_PUBLISH_DATE_CURR_MAX FROM JL_AR_TURN_UPL;
      SELECT name INTO l_WHT_GROUP_NUM_DEF_ATC FROM AP_TAX_CODES_ALL ATC WHERE global_attribute1 = 'Y' AND tax_type = 'AWT';
      SELECT tax_id INTO l_TAX_ID_DEF_ATC FROM AP_TAX_CODES_ALL WHERE name = l_WHT_GROUP_NUM_DEF_ATC AND tax_type = 'AWT';
      SELECT TAX_RATE INTO l_WHT_RATE_DEF_ATR FROM AP_AWT_TAX_RATES_ALL WHERE TAX_NAME = l_WHT_GROUP_NUM_DEF_ATC;

      SELECT TRIM(leading '0' FROM (SUBSTR(tax_name, 14, 2))) INTO l_WHT_GROUP_NUM_DEF_NO
      FROM AP_AWT_TAX_RATES_ALL WHERE tax_name = l_WHT_GROUP_NUM_DEF_ATC;

    EXCEPTION
      WHEN OTHERS THEN
      IF p_debug_log = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'50 .AN ERROR WAS ENCOUNTERED WHILE CHECKING DEFAULT AP TAX CODE FOR PREV MONTH- '|| SQLCODE ||' -ERROR- '|| SQLERRM);
      END IF;
    END;
    IF p_debug_log = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_START_DATE_CURR_MAX' || l_START_DATE_CURR_MAX);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_END_DATE_CURR_MAX' || l_END_DATE_SEC_MAX);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_WHT_GROUP_NUM_DEF_ATC' || l_WHT_GROUP_NUM_DEF_ATC);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_TAX_ID_DEF_ATC' || l_TAX_ID_DEF_ATC);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_WHT_RATE_DEF_ATR' || l_WHT_RATE_DEF_ATR);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_WHT_GROUP_NUM_DEF_NO' || l_WHT_GROUP_NUM_DEF_NO);
    END IF;


    OPEN C4(l_START_DATE_CURR_MAX);
    LOOP
      FETCH C4 INTO V_ALLREC;
      EXIT WHEN C4%NOTFOUND;


      l_PUBLISH_DATE          := V_ALLREC.PUBLISH_DATE;
      l_START_DATE            := V_ALLREC.START_DATE;
      l_END_DATE              := V_ALLREC.END_DATE;

      l_TAXPAYER_ID           := V_ALLREC.TAXPAYER_ID;
      l_CONTRIBUTOR_TYPE_CODE := V_ALLREC.CONTRIBUTOR_TYPE_CODE;
      l_NEW_CONTRIBUTOR_FLAG  := V_ALLREC.NEW_CONTRIBUTOR_FLAG;
      l_RATE_CHANGE_FLAG      := V_ALLREC.RATE_CHANGE_FLAG;
      l_PERCEPTION_RATE       := V_ALLREC.PERCEPTION_RATE;
      l_WHT_RATE              := V_ALLREC.WHT_RATE;
      l_PERCEPTION_GROUP_NUM  := V_ALLREC.PERCEPTION_GROUP_NUM;
      l_WHT_GROUP_NUM         := V_ALLREC.WHT_GROUP_NUM;


      IF p_debug_log = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Processing for TAXPAYER_ID'|| l_TAXPAYER_ID || SQLCODE || 'ERROR' || SQLERRM);
      END IF;
                                                                                -- AP tax payer id available check

      BEGIN
        SELECT DISTINCT 'Y' INTO l_taxpayer FROM PO_VENDORS PV, PER_ALL_PEOPLE_F PAPF
        WHERE NVL(pv.employee_id, - 99) = papf.person_id (+)
        AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
        AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
        l_taxpayer := 'N';

      END;
                                                                                -- AR tax payer id available check

      BEGIN

        SELECT DISTINCT 'Y' INTO l_taxpayer_ar
        FROM HZ_PARTIES HZP,
        HZ_CUST_ACCOUNTS_ALL HZCA,
        HZ_CUST_ACCT_SITES_ALL HZAS,
        HZ_CUST_SITE_USES_ALL HZSU
        WHERE HZCA.PARTY_ID = HZP.PARTY_ID
        AND HZCA.CUST_ACCOUNT_ID = HZAS.CUST_ACCOUNT_ID
        AND HZAS.CUST_ACCT_SITE_ID = HZSU.CUST_ACCT_SITE_ID
        AND HZSU.ORG_ID = l_ORG_ID
        AND HZP.JGZZ_FISCAL_CODE = TO_CHAR(l_TAXPAYER_ID);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_taxpayer_ar := 'N';

      END;

      IF l_taxpayer_ar = 'Y' THEN

                                                                           -- AR Code Hook
        BEGIN

          JL_ZZ_AR_UPLOAD_TAXES.JL_AR_UPDATE_CUST_SITE_TAX(l_TAXPAYER_ID,
                                                           l_AWT_TAX_TYPE,
                                                           l_PERCEPTION_TAX_TYPE,
                                                           l_ORG_ID,
                                                           l_PUBLISH_DATE,
                                                           l_START_DATE_CURR_MAX,
                                                           l_END_DATE_CURR_MAX,
                                                           l_RETURN_STATUS ); -- out parameter for status

          IF l_RETURN_STATUS = 'Y' THEN
            FND_FILE.put_line(FND_FILE.LOG,'58. AR validtion completed successfully');
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
          IF p_debug_log = 'Y' THEN
            FND_FILE.put_line(FND_FILE.LOG,'58. AR validation failed with return status'|| l_RETURN_STATUS || SQLCODE || 'ERROR' || SQLERRM);
          END IF;
          RAISE_APPLICATION_ERROR(- 20999,'AR validation failed'|| SQLCODE ||' -ERROR- '|| SQLERRM);
        END;


      END IF;

      IF l_taxpayer = 'Y' THEN -- AP validation starts here

        BEGIN -- To get the datas (having the Second MAX start DATE) FROM ALL table


          SELECT MAX(START_DATE) INTO l_START_DATE_SEC_MAX FROM JL_AR_TURN_UPL WHERE TAXPAYER_ID = l_TAXPAYER_ID;

          SELECT last_day(l_START_DATE_SEC_MAX) INTO l_END_DATE_SEC_MAX FROM dual;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'51 . NO DATA FOUND FOR TAXPAYER ID FOR PREV MONTH '|| L_TAXPAYER_ID);
          END IF;
        --GOTO L4;                                               --For current month data, will get no data found and fetching next record
          WHEN OTHERS THEN
          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'51 .FAILED IN CHECKING TAXPAYER ID AND DEF ATC FOR PREV MONTH- '|| SQLCODE ||' -ERROR- '|| SQLERRM);
          END IF;
        END;

        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'51 l_START_DATE_SEC_MAX'|| l_START_DATE_SEC_MAX ||'l_END_DATE_SEC_MAX '|| l_END_DATE_SEC_MAX);
        END IF;

        IF p_debug_log = 'Y' THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,'51 . TAXPAYER ID FOR PREV MONTH '|| L_TAXPAYER_ID);
        END IF;


                                                                        --- To process only the last month data and to avoid the current month taxpayer id if any
        IF l_START_DATE_SEC_MAX < l_START_DATE_CURR_MAX THEN
                                                                        --- code to UPDATE awt_cd  jl_zz_ap_sup_awt_cd_all          (9.4 B)
         BEGIN

          SELECT SAWTC.SUPP_AWT_TYPE_ID, SAWTC.SUPP_AWT_CODE_ID
          INTO l_SUPP_AWT_TYPE_ID_CD, l_SUPP_AWT_CODE_ID_CD
          FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC,
          PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
          WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
          AND NVL(pv.employee_id, - 99) = papf.person_id (+)
          AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
          AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
          AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
          AND SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
          AND SAWTC.primary_tax_flag = 'Y'
          --AND SAWT.WH_SUBJECT_FLAG = 'Y'                        -- Indicates whether the supplier is subject to the withholding tax type
          AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')
          AND SAWTC.EFFECTIVE_END_DATE IS NULL
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);


                                                                                  --code to UPDATE/insert JL_ZZ_AP_SUP_AWT_CD_ALL

          UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SET EFFECTIVE_END_DATE = l_END_DATE_SEC_MAX
          WHERE SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;

          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'52 .UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR '|| SQL%ROWCOUNT || 'RECORDS');
            FND_FILE.PUT_LINE( FND_FILE.LOG,'52. EFFECTIVE_END_DATE (l_END_DATE_SEC_MAX-1) :'||l_END_DATE_SEC_MAX||' FOR CODE_ID :'||l_SUPP_AWT_CODE_ID_CD);
            FND_FILE.PUT_LINE( FND_FILE.LOG,'52 l_TAX_ID_DEF_ATC : '|| l_TAX_ID_DEF_ATC || '   l_TAXPAYER_ID : '|| l_TAXPAYER_ID);
          END IF;


            SELECT jl_zz_ap_sup_awt_cd_s.nextval INTO l_SUPP_AWT_CODE_ID_SEQ FROM dual;


            INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL
            (SUPP_AWT_CODE_ID,
             SUPP_AWT_TYPE_ID,
             TAX_ID,
             PRIMARY_TAX_FLAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ORG_ID,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE)
            VALUES
            (l_SUPP_AWT_CODE_ID_SEQ, --SUPP_AWT_CODE_ID
             l_SUPP_AWT_TYPE_ID_CD, --SUPP_AWT_TYPE_ID
             l_TAX_ID_DEF_ATC,      -- default tax code id
             'Y',                   --PRIMARY_TAX_FLAG
             l_created_by, --CREATED_BY
             l_creation_DATE, --CREATION_DATE
             l_last_UPDATEd_by, --LAST_UPDATED_BY
             l_last_UPDATE_DATE, --LAST_UPDATE_DATE
             l_last_UPDATE_login, --LAST_UPDATE_LOGIN
             l_ORG_ID, --ORG_ID
             l_START_DATE_CURR_MAX, --EFFECTIVE_START_DATE
             NULL); --EFFECTIVE_END_DATE


            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'53 .INSERTED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR SUPP_AWT_CODE_ID '|| L_SUPP_AWT_CODE_ID_SEQ);
            END IF;

          EXCEPTION
            WHEN OTHERS THEN

            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'53. INSERTED NOT DONE FOR JL_ZZ_AP_SUP_AWT_CD_ALL '|| SQLCODE ||' -ERROR- '|| SQLERRM);
            END IF;
                                                       --If insertion fails, then will check already present in JL_ZZ_AP_SUP_AWT_CD_ALL

            BEGIN
              SELECT 'Y', SAWTC.SUPP_AWT_CODE_ID INTO def_taxtype_code_check, l_SUPP_AWT_CODE_ID_CD
              FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC
              WHERE SAWTC.SUPP_AWT_TYPE_ID = l_SUPP_AWT_TYPE_ID_CD
              AND SAWTC.TAX_ID = l_TAX_ID_DEF_ATC;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              def_taxtype_code_check := 'N';
            END;

            IF def_taxtype_code_check = 'Y' THEN
              UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SET EFFECTIVE_END_DATE = NULL
              WHERE SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;

              FND_FILE.PUT_LINE( FND_FILE.LOG,'53 Records already present in JL_ZZ_AP_SUP_AWT_CD_ALL table TYPE ID'|| l_SUPP_AWT_TYPE_ID_CD);
              FND_FILE.PUT_LINE( FND_FILE.LOG,'53. l_TAX_ID_DEF_ATC'|| l_TAX_ID_DEF_ATC || 'L_EFFECTIVE_START_DATE' || L_START_DATE);

            ELSE
                                                           ----If insertion fails, then will do the UPDATE in awt_cd_all
              UPDATE JL_ZZ_AP_SUP_AWT_CD_ALL SET
              TAX_ID = l_TAX_ID_DEF_ATC, --- default tax code id
              PRIMARY_TAX_FLAG = 'Y',
              EFFECTIVE_START_DATE = l_START_DATE_CURR_MAX,
              EFFECTIVE_END_DATE = NULL
              WHERE SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;

              IF p_debug_log = 'Y' THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG,'54 .UPDATED DATA IN JL_ZZ_AP_SUP_AWT_CD_ALL FOR SUPP_AWT_CODE_ID WITH OLD TAX_ID for CODE ID'|| l_SUPP_AWT_CODE_ID_CD);
              END IF;
            END IF;

          END;


                                                          -- code to UPDATE/insert  jl_zz_ap_inv_dis_wh_all

          BEGIN
                                                          -- To get the current month Supp_Awt_Code_id for the present tax_id

            SELECT SAWTC.SUPP_AWT_CODE_ID INTO l_SUPP_AWT_CODE_ID_CD
            FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC,
            PO_VENDORS PV, JL_ZZ_AP_SUPP_AWT_TYPES SAWT, PER_ALL_PEOPLE_F PAPF
            WHERE SAWT.VENDOR_ID = PV.VENDOR_ID
            AND NVL(pv.employee_id, - 99) = papf.person_id (+)
            AND NVL(papf.EFFECTIVE_START_DATE, SYSDATE) <= SYSDATE
            AND NVL(papf.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
            AND SAWT.AWT_TYPE_CODE = l_AWT_TAX_TYPE
            AND SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
            AND SAWTC.TAX_ID = l_TAX_ID_DEF_ATC -- to pick up the tax code WHERE tax id is def ATC
            AND SAWTC.primary_tax_flag = 'Y'
                        --AND SAWT.WH_SUBJECT_FLAG = 'Y'
            AND sawtc.effective_end_DATE IS NULL
        --bug 8530918 AND NVL(papf.national_identifier, NVL(pv.individual_1099, pv.num_1099)) = TO_CHAR(l_TAXPAYER_ID);
        AND rtrim(
              substr(
                replace(
                      nvl(papf.national_identifier,
                        nvl(pv.individual_1099,pv.num_1099)
                         ),
                    '-'),
                1,10)
                 ) ||
            substr(pv.global_attribute12,1,1) = TO_CHAR(l_TAXPAYER_ID);

            SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

          EXCEPTION
            WHEN OTHERS THEN
            IF p_debug_log = 'Y' THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'54 UPDATE NOT DONE FOR JL_ZZ_AP_INV_DIS_WH_ALL - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
            END IF;
          END;

          OPEN CUR4(l_TAXPAYER_ID);
          LOOP
            FETCH CUR4 INTO INV_REC;
            EXIT WHEN CUR4%NOTFOUND;

                                                                ---code to insert data INTO  jl_zz_ap_inv_dis_wh_all

            BEGIN

              AWT_CODE_INV_AVAIL_FLAG := 'N';

              SELECT 'Y', INV_DISTRIB_AWT_ID INTO AWT_CODE_INV_AVAIL_FLAG, l_INV_DISTRIB_AWT_ID_DIS
              FROM JL_ZZ_AP_INV_DIS_WH_ALL
              WHERE INVOICE_ID = INV_REC.INVOICE_ID
              AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
              AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
              AND SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD;
              /*(SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
               WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
               AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')); */

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              AWT_CODE_INV_AVAIL_FLAG := 'N';
              FND_FILE.put_line( FND_FILE.LOG,'54 A No earlier data in Inv Dist'|| SQLCODE ||' -ERROR- '|| SQLERRM);

              WHEN OTHERS THEN
              AWT_CODE_INV_AVAIL_FLAG := 'N';
              FND_FILE.put_line( FND_FILE.LOG,'54 A Error in Inv Dist'|| SQLCODE ||' -ERROR- '|| SQLERRM);
            END;

          IF AWT_CODE_INV_AVAIL_FLAG = 'N' THEN

              IF p_debug_log = 'Y' THEN
                FND_FILE.put_line( FND_FILE.LOG,'54 B l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                FND_FILE.put_line( FND_FILE.LOG,'54 B INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                FND_FILE.put_line( FND_FILE.LOG,'54 B INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                FND_FILE.put_line( FND_FILE.LOG,'54 B l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
		FND_FILE.put_line( FND_FILE.LOG,'54 B INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
              END IF;

              BEGIN

                INSERT INTO JL_ZZ_AP_INV_DIS_WH_ALL
                (INV_DISTRIB_AWT_ID,
                 INVOICE_ID,
                 DISTRIBUTION_LINE_NUMBER,
                 SUPP_AWT_CODE_ID,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN,
                 ORG_ID,
		 INVOICE_DISTRIBUTION_ID)
                VALUES
                (l_INV_DISTRIB_AWT_ID_INV, --INV_DISTRIB_AWT_ID
                 INV_REC.INVOICE_ID, --INVOICE_ID
                 INV_REC.DISTRIBUTION_LINE_NUMBER, --DISTRIBUTION_LINE_NUMBER
                 l_SUPP_AWT_CODE_ID_CD, --Def SUPP_AWT_CODE_ID
                 l_created_by, --CREATED_BY
                 l_creation_DATE, --CREATION_DATE
                 l_last_UPDATEd_by, --LAST_UPDATED_BY
                 l_last_UPDATE_DATE, --LAST_UPDATE_DATE
                 l_last_UPDATE_login, --LAST_UPDATE_LOGIN
                 l_ORG_ID, --ORG_ID
                 INV_REC.INVOICE_DISTRIBUTION_ID);   --Invoice distribution ID         -- R12 Changes


                SELECT JL_ZZ_AP_INV_DIS_WH_S.NEXTVAL INTO l_INV_DISTRIB_AWT_ID_INV FROM dual;

                IF p_debug_log = 'Y' THEN
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'55 A. INSERTED RECORDS INTO JL_ZZ_AP_INV_DIS_WH_S '|| SQL%ROWCOUNT || 'RECORDS' || SQLCODE ||' -ERROR- '|| SQLERRM);
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                IF p_debug_log = 'Y' THEN
                  FND_FILE.put_line( FND_FILE.LOG,'55 A. Failed while Inserted records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                END IF;
              END;

         ELSE

              BEGIN
                IF p_debug_log = 'Y' THEN
                  FND_FILE.put_line( FND_FILE.LOG,'55 B l_INV_DISTRIB_AWT_ID_INV'|| l_INV_DISTRIB_AWT_ID_INV);
                  FND_FILE.put_line( FND_FILE.LOG,'55 B INV_REC.INVOICE_ID'|| INV_REC.INVOICE_ID);
                  FND_FILE.put_line( FND_FILE.LOG,'55 B INV_REC.DISTRIBUTION_LINE_NUMBER'|| INV_REC.DISTRIBUTION_LINE_NUMBER);
                  FND_FILE.put_line( FND_FILE.LOG,'55 B l_SUPP_AWT_CODE_ID_CD'|| l_SUPP_AWT_CODE_ID_CD);
                  FND_FILE.put_line( FND_FILE.LOG,'55 B l_INV_DISTRIB_AWT_ID_DIS'|| l_INV_DISTRIB_AWT_ID_DIS);
		  FND_FILE.put_line( FND_FILE.LOG,'55 B INVOICE_DISTRIBUTION_ID'|| INV_REC.INVOICE_DISTRIBUTION_ID);
                END IF;

                    /*SELECT INV_DISTRIB_AWT_ID INTO l_INV_DISTRIB_AWT_ID_DIS
                    FROM JL_ZZ_AP_INV_DIS_WH_ALL
                    WHERE INVOICE_ID = INV_REC.INVOICE_ID
                    AND DISTRIBUTION_LINE_NUMBER = INV_REC.DISTRIBUTION_LINE_NUMBER
		    AND INVOICE_DISTRIBUTION_ID  = INV_REC.INVOICE_DISTRIBUTION_ID
                    AND SUPP_AWT_CODE_ID IN
                    (SELECT SUPP_AWT_CODE_ID FROM JL_ZZ_AP_SUP_AWT_CD_ALL SAWTC, JL_ZZ_AP_SUPP_AWT_TYPES SAWT
                     WHERE SAWT.SUPP_AWT_TYPE_ID = SAWTC.SUPP_AWT_TYPE_ID
                     AND SAWTC.primary_tax_flag = 'Y'
                     AND SAWTC.TAX_ID IN (SELECT TAX_ID FROM AP_TAX_CODES_ALL WHERE name LIKE 'TURN_BSAS_GRP%')
                     AND sawtc.effective_end_DATE IS NULL);*/

                UPDATE JL_ZZ_AP_INV_DIS_WH_ALL SET SUPP_AWT_CODE_ID = l_SUPP_AWT_CODE_ID_CD
                WHERE INV_DISTRIB_AWT_ID = l_INV_DISTRIB_AWT_ID_DIS;

                IF p_debug_log = 'Y' THEN
                  FND_FILE.PUT_LINE( FND_FILE.LOG,'55 C.UPDATED DATA IN JL_ZZ_AP_INV_DIS_WH_ALL FOR SUPP_AWT_CODE_ID WITH CURRENT (DEF) TAX_ID for'|| SQL%ROWCOUNT || 'RECORD' || SQLCODE ||' -ERROR- '|| SQLERRM);
                  FND_FILE.put_line( FND_FILE.LOG,'55 C l_INV_DISTRIB_AWT_ID_DIS:'|| l_INV_DISTRIB_AWT_ID_DIS || 'l_SUPP_AWT_CODE_ID_CD:' || l_SUPP_AWT_CODE_ID_CD);
                END IF;


              EXCEPTION
                WHEN OTHERS THEN
                IF p_debug_log = 'Y' THEN
                  FND_FILE.put_line( FND_FILE.LOG,'56. Failed while updating records in JL_ZZ_AP_INV_DIS_WH_ALL '|| SQLCODE || 'ERROR' || SQLERRM);
                END IF;
              END;

          END IF;

         END LOOP;
         CLOSE CUR4;

          IF p_debug_log = 'Y' THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,'56. UPDATED DATA IN JL_ZZ_AP_INV_DIS_WH_ALL FOR SUPP_AWT_CODE_ID ');
          END IF;



                                                             -- insert data in ALL table

          SELECT * INTO ALL_REC FROM JL_AR_TURN_UPL
          WHERE START_DATE = l_START_DATE_SEC_MAX AND TAXPAYER_ID = l_TAXPAYER_ID;


          Insert_Row (ALL_REC.PUBLISH_DATE, -- inserting the old original publish DATE FROM government
                      l_START_DATE_CURR_MAX, -- inserting the current max start and end DATEs
                      l_END_DATE_CURR_MAX,
                      ALL_REC.TAXPAYER_ID,
                      ALL_REC.CONTRIBUTOR_TYPE_CODE,
                      ALL_REC.NEW_CONTRIBUTOR_FLAG,
                      ALL_REC.RATE_CHANGE_FLAG,
                      ALL_REC.PERCEPTION_RATE,
                      l_WHT_RATE_DEF_ATR, -- inserting the defualt tax rate
                      ALL_REC.PERCEPTION_GROUP_NUM,
                      l_WHT_GROUP_NUM_DEF_NO, -- inserting the defualt tax group
                      'Y',
                      'AP');

          IF p_debug_log = 'Y' THEN
            FND_FILE.put_line( FND_FILE.LOG,'57 .Fetching Record Record after Taxpayer Id '|| l_TAXPAYER_ID);
          END IF;

        END IF;

      END IF; -- AP validation ends here

      <<L4>>

      NULL;


 --Reinitialising the local variables:
 --------------------------------------
      l_START_DATE_SEC_MAX    := NULL;
      l_taxpayer              := 'N';
      l_taxpayer_ar           := 'N';
      AWT_CODE_INV_AVAIL_FLAG := 'N';

      COMMIT;

    END LOOP;
    CLOSE C4;



  EXCEPTION
    WHEN OTHERS THEN
    IF p_debug_log = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'58 .AN ERROR WAS ENCOUNTERED IN VALIDATION_AWT_SETUP - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END IF;
    UPDATE JGZZ_AR_TAX_GLOBAL_TMP SET JG_INFO_V1 = 'JLZZ_RECORD_FAILED_AWT_SETUP'
    WHERE JG_INFO_N1 = l_TAXPAYER_ID AND JG_INFO_D1 = l_START_DATE AND JG_INFO_D2 = l_END_DATE;


  END VALIDATE_AWT_SETUP;




  FUNCTION beforeReport
  RETURN BOOLEAN
  IS

  BEGIN


    P_REV_TEMP_DATA     := UPPER(P_REV_TEMP_DATA);
    P_VALIDATION_DATA   := UPPER(P_VALIDATION_DATA);
    P_FINALIZE_DATA     := UPPER(P_FINALIZE_DATA);
    P_START_DATE        := to_DATE(P_START_DATE);
    P_END_DATE          := to_DATE(P_END_DATE);

    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'Starting PKG JL_AR_APPLICABLE_TAXES.beforeReport');
      FND_FILE.put_line( FND_FILE.LOG,'P_REV_TEMP_DATA   :'|| P_REV_TEMP_DATA);
      FND_FILE.put_line( FND_FILE.LOG,'P_VALIDATION_DATA :'|| P_VALIDATION_DATA);
      FND_FILE.put_line( FND_FILE.LOG,'P_FINALIZE_DATA   :'|| P_FINALIZE_DATA);
      FND_FILE.put_line( FND_FILE.LOG,'P_START_DATE      :'|| P_START_DATE);
      FND_FILE.put_line( FND_FILE.LOG,'P_END_DATE        :'|| P_END_DATE);
    END IF;

    IF (P_REV_TEMP_DATA = 'Y') AND (P_VALIDATION_DATA = 'N') AND  (P_FINALIZE_DATA = 'N')     THEN

    table_name  := 'JL_AR_TURN_UPL_T';			      -- will goto xml file and print the Temp Table Data output directly


    ELSIF (P_REV_TEMP_DATA = 'N') AND (P_VALIDATION_DATA = 'N') AND  (P_FINALIZE_DATA = 'N')  THEN

     table_name  := 'JL_AR_TURN_UPL';                               -- will goto xml file and print the FINAL ALL Table Data output directly


    ELSIF (P_REV_TEMP_DATA = 'Y') AND (P_VALIDATION_DATA = 'Y') AND  (P_FINALIZE_DATA = 'N')  THEN

    table_name  := 'JL_AR_TURN_UPL';			  -- will do validation for the govt flat file data and shows the valid and invalid records


       IF p_debug_log = 'Y' THEN
        FND_FILE.put_line( FND_FILE.LOG,'Starting the FINAL_VALIDATION procedure');
      END IF;

      DELETE JGZZ_AR_TAX_GLOBAL_TMP;        -- Truncating previous records, if any, in JGZZ_AR_TAX_GLOBAL_TMP table
      FINAL_VALIDATION;                     -- will goto FINAL_VALIDATION package and validate

      IF p_debug_log = 'Y' THEN
        FND_FILE.put_line( FND_FILE.LOG,'After the FINAL_VALIDATION procedure');
      END IF;

    ELSIF (P_FINALIZE_DATA = 'Y') AND (P_REV_TEMP_DATA = 'N') AND (P_VALIDATION_DATA = 'N')   THEN

      table_name  := 'JL_AR_TURN_UPL';		 -- will do final validation for the govt flat file data and defaulting will happens for missing taxpayerid

      IF p_debug_log = 'Y' THEN
        FND_FILE.put_line( FND_FILE.LOG,'Starting the VALIDATE_AWT_SETUP procedure');
      END IF;

      VALIDATE_AWT_SETUP;                   -- will goto VALIDATE_AWT_SETUP package and valiDATE and then print xml data

      IF p_debug_log = 'Y' THEN
        FND_FILE.put_line( FND_FILE.LOG,'After the VALIDATE_AWT_SETUP procedure');
      END IF;

    ELSE

       table_name  := 'JL_AR_TURN_UPL';

        IF p_debug_log = 'Y' THEN
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'--------------------------------------------------------------------------------------------------------');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,' --------------   E R R O R  :    P A R A M E T E R     W R O N G L Y     S E L E C T E D  -------------');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'---------------    PLEASE MAKE SURE TO RUN THE ARGENTINA AWT REPORT WITH VALID PARAMETERS  -------------');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'-------------------------------   VALID PARAMETER SELECTION CRITERIA   ---------------------------------');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
	 FND_FILE.put_line( FND_FILE.LOG,' To Review the Temporary Upload Data (without validation), Enter the Review Temporary Data as YES, Validate Temporary Data as NO, Finalize Data as NO');
 	 FND_FILE.put_line( FND_FILE.LOG,' To Validate the Temporary Upload Data, Enter the Review Temporary Data as YES, Validate Temporary Data as YES, Finalize Data as NO');
	 FND_FILE.put_line( FND_FILE.LOG,' To Finalize the Temporary Upload Data, Enter the Review Temporary Data as NO, Validate Temporary Data as NO, Finalize Data as YES');
 	 FND_FILE.put_line( FND_FILE.LOG,' To view only the Valid Data (After validation), Enter the Review Temporary Data as NO, Validate Temporary Data as NO, Finalize Data as NO and select the Responsibility and Dates Appropriately');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'----------------------------------------------------------------------------------------------------------');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
         FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
      END IF;

    END IF;


    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'Closing the PKG JL_AR_APPLICABLE_TAXES.beforeReport');
    END IF;

    IF (P_START_DATE IS NULL) THEN
      SELECT MAX(start_DATE) INTO P_START_DATE FROM JL_AR_TURN_UPL;
    END IF;

    IF (P_END_DATE IS NULL) THEN
      SELECT MAX(end_DATE) INTO P_END_DATE FROM JL_AR_TURN_UPL;
    END IF;
    IF p_debug_log = 'Y' THEN
      FND_FILE.put_line( FND_FILE.LOG,'Before Report  P_START_DATE  :'||  P_START_DATE ||'P_END_DATE   :'|| P_END_DATE);
      FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
      FND_FILE.put_line( FND_FILE.LOG,'                                                                                                                                                                             ');
    END IF;

         --DELETE JGZZ_AR_TAX_GLOBAL_TMP; -- Deleting previous records, if any in JGZZ_AR_TAX_GLOBAL_TMP table
         --FINAL_VALIDATION;
         --VALIDATE_AWT_SETUP;

    RETURN TRUE;
  END beforeReport;


END JL_AR_APPLICABLE_TAXES;


/
