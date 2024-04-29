--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_UPLOAD_TAXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_UPLOAD_TAXES" AS
/* $Header: jlzzutxb.pls 120.2.12010000.1 2009/02/05 07:25:36 nivnaray noship $ */

-------------------------------------------------------------------------------
--Global Variables
-------------------------------------------------------------------------------

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_exception       CONSTANT  NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
-- Variables for processing

  l_start_date_max             DATE;
  l_start_date_sec_max         DATE;
  l_end_date_sec_max           DATE;
  l_end_date_max               DATE;
  l_def_tax_code               AR_VAT_TAX_ALL.TAX_CODE%TYPE;
  l_def_tax_rate               AR_VAT_TAX_ALL.TAX_RATE%TYPE;
  l_exist_in_all               VARCHAR2(2);
  l_proper_tax_rate_code       VARCHAR2(2);
  l_exist_in_tmp               VARCHAR2(2);
  l_data_change_flag           VARCHAR2(2);
  l_def_tax_flag               VARCHAR2(2);

  PROCEDURE JL_AR_UPDATE_CUST_SITE_TAX
                                (P_TAXPAYER_ID   IN  NUMBER,
                                 P_TAX_TYPE      IN  VARCHAR2 := 'TURN_BSAS',
                                 P_CATEG         IN  VARCHAR2 := 'TOPBA',
                                 P_ORG_ID        IN  NUMBER,
                                 P_PUBLISH_DATE  IN  DATE,
                                 P_START_DATE    IN  DATE,
                                 P_END_DATE      IN  DATE,
                                 X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS

  CURSOR FIND_CT_FOR_TAXPAYER(C_TAXPAYER_ID NUMBER) IS
    SELECT CUST.CUST_ACCOUNT_ID
      FROM HZ_PARTIES PARTY,
           HZ_CUST_ACCOUNTS CUST
     WHERE CUST.PARTY_ID = PARTY.PARTY_ID
       AND PARTY.JGZZ_FISCAL_CODE = To_Char(C_TAXPAYER_ID);

  CURSOR GET_SITES_FOR_CT(C_CUSTOMER_ID NUMBER) IS
    SELECT HZSU.SITE_USE_ID
      FROM HZ_PARTIES HZP,
           HZ_CUST_ACCOUNTS HZCA,
           HZ_CUST_ACCT_SITES HZAS,
           HZ_CUST_SITE_USES HZSU
     WHERE HZCA.CUST_ACCOUNT_ID   = C_CUSTOMER_ID
       AND HZCA.PARTY_ID          = HZP.PARTY_ID
       AND HZCA.CUST_ACCOUNT_ID   = HZAS.CUST_ACCOUNT_ID
       AND HZAS.CUST_ACCT_SITE_ID = HZSU.CUST_ACCT_SITE_ID
       AND HZSU.ORG_ID            = P_ORG_ID
     ORDER BY HZSU.SITE_USE_ID;

  CURSOR GET_DATA_FROM_TMP(C_TAX_PAYER_ID NUMBER) IS
    SELECT * FROM JL_AR_TURN_UPL_T
     WHERE TAXPAYER_ID = C_TAX_PAYER_ID;

  l_all_valid_rec		GET_DATA_FROM_TMP%ROWTYPE;

  -- Variables to hold the data in final table

  l_publish_date	        DATE;
  l_start_date			DATE;
  l_end_date			DATE;
  l_taxpayer_id			NUMBER(15);
  l_contributor_type_code	VARCHAR2(1);
  l_new_contributor_flag	VARCHAR2(1);
  l_rate_change_flag	  	VARCHAR2(1);
  l_perception_rate		NUMBER(15,2);
  l_wht_rate			NUMBER(15,2);
  l_perception_group_num	NUMBER(15);
  l_wht_group_num		NUMBER(15);
  l_wht_default			VARCHAR2(1);

  -- Variables for Final Table updation

  l_site_use_id                 NUMBER;
  l_customer_id                 NUMBER;
  l_cust_site_use_rec           HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
  l_old_customer_profile_rec    HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
  x_msg_count                   NUMBER;
  x_msg_data                    VARCHAR2(1200);
  l_obj_version                 NUMBER;


BEGIN
  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES','JL_AR_UPDATE_CUST_SITE_TAX(+)');
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                        'I/P - Taxpayer ID: '||P_TAXPAYER_ID
                        ||',Tax Type: '||P_TAX_TYPE
                        ||',Category: '||P_CATEG
                        ||',Org ID: '||P_ORG_ID
                        ||',Start Date: '||P_START_DATE
                        ||',End Date: '||P_END_DATE
                        ||',Publish Date: '||P_PUBLISH_DATE);
  END IF;

  -- Initialization Section

  X_RETURN_STATUS := 'S';
  INITIALIZE;

  BEGIN -- Checking whether Taxpayer Exists in Current Month
    SELECT 'Y'
      INTO l_exist_in_tmp
      FROM JL_AR_TURN_UPL_T
     WHERE TAXPAYER_ID = P_TAXPAYER_ID;
  EXCEPTION
    WHEN No_Data_Found THEN
      l_exist_in_tmp := 'N';
    WHEN OTHERS THEN
      X_RETURN_STATUS := 'E';
      RAISE;
  END;

  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                           'Exists in Current Month: '||l_exist_in_tmp);
  END IF;

  IF l_exist_in_tmp = 'Y' THEN
    l_def_tax_flag := 'N'; -- SINCE WE WILL NOT ASSIGN THE DEF CODE IN THIS SCENARIO.

    OPEN GET_DATA_FROM_TMP(P_TAXPAYER_ID);
    FETCH GET_DATA_FROM_TMP INTO l_all_valid_rec;

    l_publish_date	 :=	l_all_valid_rec.publish_date;
    l_start_date	 :=	l_all_valid_rec.start_date;
    l_end_date		 :=	l_all_valid_rec.end_date;
    l_taxpayer_id	 :=	l_all_valid_rec.taxpayer_id;
    l_contributor_type_code	 :=	l_all_valid_rec.contributor_type_code;
    l_new_contributor_flag	 :=	l_all_valid_rec.new_contributor_flag;
    l_rate_change_flag	 :=	l_all_valid_rec.rate_change_flag;
    l_perception_rate	 :=	l_all_valid_rec.perception_rate;
    l_wht_rate		 :=	l_all_valid_rec.wht_rate;
    l_perception_group_num	 :=	l_all_valid_rec.perception_group_num;
    l_wht_group_num		 :=	l_all_valid_rec.wht_group_num;

    CLOSE GET_DATA_FROM_TMP;

    BEGIN
        SELECT 'Y'
          INTO l_proper_tax_rate_code
          FROM AR_VAT_TAX VAT,
               JL_ZZ_AR_TX_CATEG JZ
         WHERE VAT.ORG_ID 	     = P_ORG_ID
           AND VAT.GLOBAL_ATTRIBUTE1 = JZ.TAX_CATEGORY_ID
           AND VAT.ORG_ID      	     = JZ.ORG_ID
           AND JZ.TAX_CATEGORY 	     = P_CATEG
           AND VAT.ENABLED_FLAG      = 'Y'
           AND VAT.TAX_CODE          = P_TAX_TYPE||'_GRP'||l_perception_group_num
           AND VAT.TAX_RATE 	     = l_perception_rate
           AND VAT.START_DATE      <= P_START_DATE
           AND NVL(VAT.END_DATE,TO_DATE('31/12/4092','DD/MM/RRRR'))
                     >= NVL(P_END_DATE,LAST_DAY(P_START_DATE));
    EXCEPTION
        WHEN No_Data_Found THEN
          X_RETURN_STATUS := 'E';

          UPDATE JGZZ_AR_TAX_GLOBAL_TMP
             SET JG_INFO_V1 = 'JL_AR_AR_GRP_NO_MATCH'
           WHERE JG_INFO_N1 = P_TAXPAYER_ID
             AND JG_INFO_D1 = P_START_DATE
             AND JG_INFO_D2 = P_END_DATE;

          RAISE_APPLICATION_ERROR(- 20999,'Perception Rate and Group Combination was not proper - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
        WHEN OTHERS THEN
          X_RETURN_STATUS := 'E';
          RAISE_APPLICATION_ERROR(- 20999,'Failed during Rate and Group Combination Check - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END;

    -- CHECK WHETHER TAXPAYER ID EXISTS IN THE LAST MONTH FOR COMPARISION.

    BEGIN
      SELECT Max(JALL.START_DATE),Max(JALL.END_DATE)
        INTO l_start_date_sec_max,l_end_date_sec_max
        FROM JL_AR_TURN_UPL_ALL JALL
       WHERE JALL.TAXPAYER_ID = P_TAXPAYER_ID;
      IF l_start_date_sec_max IS NOT NULL THEN
        l_exist_in_all := 'Y';  -- IF EXISTS IN LAST MONTH
      ELSE
        l_exist_in_all := 'N';
      END IF;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_exist_in_all := 'N'; -- IF NOT EXISTS.
      WHEN OTHERS THEN
        X_RETURN_STATUS := 'E';
        RAISE;
    END;

    IF g_level_statement >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                      'Max Start Date in All table: '||l_start_date_sec_max
                      ||',Max End Date in All table: '||l_end_date_sec_max
                      ||',Tax Payer ID Exists in Previous Month?: '||l_exist_in_all
                      ||',Tax Rate and Group Info is proper?: '||l_proper_tax_rate_code);
    END IF;

    /* IF CT IS TRYING UPLOADING THE DATA FOR THE FIRST TIME (OR)
       THE TAXPAYER ID NOT EXISTS IN THE LAST MONTH THEN INSERT THE RECORDS
       INTO THE FINAL TABLE AND UPDATE THE CUST SITE WITH THE TAXC0DE GIVEN.*/

    IF l_exist_in_all = 'N' THEN
      IF Nvl(l_proper_tax_rate_code,'N') = 'Y' THEN
        l_data_change_flag := 'Y';
      END IF;  -- PROPER TAX RATE CODE CHECK
    ELSIF l_exist_in_all = 'Y' THEN
      IF Nvl(l_proper_tax_rate_code,'N') = 'Y' THEN
       	BEGIN
          SELECT DISTINCT 'Y'
            INTO l_data_change_flag
            FROM HZ_PARTIES HZP,
                 HZ_CUST_ACCOUNTS HZCA,
                 HZ_CUST_ACCT_SITES HZAS,
                 HZ_CUST_SITE_USES HZSU
           WHERE HZP.JGZZ_FISCAL_CODE   = To_Char(l_taxpayer_id)
             AND HZCA.PARTY_ID          = HZP.PARTY_ID
             AND HZCA.CUST_ACCOUNT_ID   = HZAS.CUST_ACCOUNT_ID
             AND HZAS.CUST_ACCT_SITE_ID = HZSU.CUST_ACCT_SITE_ID
             AND HZSU.ORG_ID            = P_ORG_ID
             AND (HZSU.TAX_CODE IS NULL OR
                  HZSU.TAX_CODE <> P_TAX_TYPE||'_GRP'||l_perception_group_num);
        EXCEPTION
          WHEN No_Data_Found THEN
            l_data_change_flag := 'N';
          WHEN OTHERS THEN
            X_RETURN_STATUS := 'E';
            RAISE;
        END;
      END IF;  -- PROPER TAX RATE CODE CHECK
    END IF;  -- EXISTS IN ALL TABLE CHECK
  ELSE  -- l_exist_in_tmp IS 'N'
    -- DO THE PROCESSING FOR THE RECORDS WHICH ARE NOT EXISTS IN CURRENT MONTH
    -- DATA FILE, BUT EXISTS IN PREVIOS MONTH.
      -- DERIVING THE DEFAULT TAX CODE AND VAT TAX ID
    BEGIN
      SELECT VAT.TAX_CODE, VAT.TAX_RATE
        INTO l_def_tax_code, l_def_tax_rate
        FROM AR_VAT_TAX VAT,
             JL_ZZ_AR_TX_CATEG JZ
       WHERE VAT.GLOBAL_ATTRIBUTE7 	= 'Y'
         AND VAT.ORG_ID 		= P_ORG_ID
         AND VAT.GLOBAL_ATTRIBUTE1 	= JZ.TAX_CATEGORY_ID
         AND VAT.ORG_ID 		= JZ.ORG_ID
         AND JZ.TAX_CATEGORY 		= P_CATEG
         AND VAT.ENABLED_FLAG 	        = 'Y'
         AND VAT.START_DATE      <= P_START_DATE
         AND NVL(VAT.END_DATE,TO_DATE('31/12/4092','DD/MM/RRRR'))
                     >= NVL(P_END_DATE,LAST_DAY(P_START_DATE));
    EXCEPTION
      WHEN No_Data_Found THEN
        X_RETURN_STATUS := 'E';

        UPDATE JGZZ_AR_TAX_GLOBAL_TMP
           SET JG_INFO_V1 = 'JL_AR_AR_NO_DFLT_FLAG_SET'
         WHERE JG_INFO_N1 = P_TAXPAYER_ID
           AND JG_INFO_D1 = P_START_DATE
           AND JG_INFO_D2 = P_END_DATE;

        RAISE_APPLICATION_ERROR(- 20999,'Define Atleast one Default Tax Code - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
      WHEN OTHERS THEN
        X_RETURN_STATUS := 'E';
        RAISE_APPLICATION_ERROR(- 20999,'Failed when fetching the Default Tax Code - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END;

    IF g_level_statement >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                                 'Default Tax Code: '||l_def_tax_code);
    END IF;

    l_def_tax_flag := 'Y';
    l_data_change_flag := 'Y';

    -- GET THE VALUES TO INSERT THE RECORD INTO _ALL TABLE.
    l_publish_date	     	:=			P_PUBLISH_DATE;
    l_start_date		:=			P_START_DATE;
    l_end_date			:=			P_END_DATE;
    l_taxpayer_id		:=			P_TAXPAYER_ID;
    l_perception_group_num 	:=			SubStr(l_def_tax_code,(Length(P_TAX_TYPE)+5));

    IF g_level_statement >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                          'Perception Group Number: '||l_perception_group_num);
    END IF;

    BEGIN
      SELECT Max(JALL.START_DATE),Max(JALL.END_DATE)
        INTO l_start_date_sec_max,l_end_date_sec_max
        FROM JL_AR_TURN_UPL_ALL JALL
       WHERE JALL.TAXPAYER_ID = P_TAXPAYER_ID;

      SELECT  CONTRIBUTOR_TYPE_CODE,
              NEW_CONTRIBUTOR_FLAG,
              PERCEPTION_RATE,
              WHT_RATE,
              WHT_GROUP_NUM
        INTO  l_contributor_type_code,
              l_new_contributor_flag,
              l_perception_rate,
              l_wht_rate,
              l_wht_group_num
        FROM JL_AR_TURN_UPL_ALL
       WHERE TAXPAYER_ID = P_TAXPAYER_ID
         AND START_DATE  = l_start_date_sec_max
         AND END_DATE    = l_end_date_sec_max;
    EXCEPTION
      WHEN No_Data_Found THEN
        X_RETURN_STATUS := 'E';
        RAISE_APPLICATION_ERROR(- 20999,'Taxpayer ID not exists in both tmp and all table - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
      WHEN OTHERS THEN
        X_RETURN_STATUS := 'E';
        RAISE_APPLICATION_ERROR(- 20999,'Failed when fetching the data from ALL table for given Taxpayer: '
                        ||l_taxpayer_id||' - '|| SQLCODE ||' -ERROR- '|| SQLERRM);
    END;

    IF l_perception_rate <> l_def_tax_rate THEN
      l_rate_change_flag	:=			'S';
      l_perception_rate	   	:=			l_def_tax_rate;
    ELSE
      l_rate_change_flag	:=			'N';
    END IF;

  END IF;  -- TAX PAYER ID CHECK IN TMP TABLE

  BEGIN
    JL_AR_APPLICABLE_TAXES.Insert_Row( l_publish_date,
                                       l_start_date,
                                       l_end_date,
 	                               l_taxpayer_id,
                                       l_contributor_type_code,
                                       l_new_contributor_flag,
                                       l_rate_change_flag,
                                       l_perception_rate,
                                       l_wht_rate,
                                       l_perception_group_num,
                                       l_wht_group_num,
                                       l_def_tax_flag,
                                       'AR');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = 0 THEN
        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                                  'Normal Completion Exception');
        END IF;
      ELSE
        X_RETURN_STATUS := 'E';
        RAISE_APPLICATION_ERROR(-20999,'Failed when inserting the details for given Taxpayer: '
                                ||l_taxpayer_id||' - '||SQLCODE||'- ERROR - '||SQLERRM);
      END IF;
  END;
  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                            'Data Change Flag: '||l_data_change_flag);
  END IF;
  IF l_data_change_flag = 'Y' THEN
    -- UPDATE THE TAX CODE AT SITE LEVEL.
    OPEN FIND_CT_FOR_TAXPAYER(l_taxpayer_id);
    LOOP
      FETCH FIND_CT_FOR_TAXPAYER INTO l_customer_id;
      IF g_level_statement >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                          'Customer Account ID for given Taxpayer ID: '||l_customer_id);
      END IF;
      EXIT WHEN FIND_CT_FOR_TAXPAYER%NOTFOUND;

      OPEN GET_SITES_FOR_CT(l_customer_id);
      LOOP
        FETCH GET_SITES_FOR_CT INTO l_site_use_id;
        EXIT WHEN GET_SITES_FOR_CT%NOTFOUND;
        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                              'Updated Site Use Ids:'||l_site_use_id);
        END IF;
        -- UPDATE THE TAX CODE AT SITE LEVELS.
        HZ_CUST_ACCOUNT_SITE_V2PUB.get_cust_site_use_rec (
                     p_site_use_id            => l_site_use_id,
                     x_cust_site_use_rec      => l_cust_site_use_rec,
                     x_customer_profile_rec   => l_old_customer_profile_rec,
                     x_return_status          => x_return_status,
                     x_msg_count              => x_msg_count,
                     x_msg_data               => x_msg_data);

        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                        'Return Status after getting the site use info:'||x_return_status);
        END IF;
        IF x_return_status = 'S' THEN
          BEGIN
            l_cust_site_use_rec.tax_code := P_TAX_TYPE||'_GRP'||l_perception_group_num;
            IF g_level_statement >= g_current_runtime_level THEN
              FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                        'Updating the Site with Tax Code: '||l_cust_site_use_rec.tax_code);
            END IF;

            BEGIN
              SELECT OBJECT_VERSION_NUMBER
                INTO l_obj_version
                FROM HZ_CUST_SITE_USES
               WHERE SITE_USE_ID = l_site_use_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_obj_version := NULL;
            END;
            IF g_level_statement >= g_current_runtime_level THEN
              FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES',
                                'Object Version for this Site: '||l_obj_version);
            END IF;

            HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_site_use (
                                        FND_API.G_TRUE,
                                        l_cust_site_use_rec,
                                        l_obj_version,
                                        x_return_status,
                                        x_msg_count,
                                        x_msg_data );
          EXCEPTION
            WHEN OTHERS THEN
              X_RETURN_STATUS := 'E';
              RAISE_APPLICATION_ERROR(-20999,'Failed when Updating Site Use Id: '
                               ||l_site_use_id||'WITH - '||SQLCODE||'-ERROR-'||SQLERRM);
          END;
        ELSE
          X_RETURN_STATUS := 'E';
          RAISE_APPLICATION_ERROR(-20999,'Failed when picking the data for Site Use Id: '
                               ||l_site_use_id||'WITH - '||SQLCODE||'-ERROR-'||SQLERRM);
        END IF;
      END LOOP;
      CLOSE GET_SITES_FOR_CT;
    END LOOP;
    CLOSE FIND_CT_FOR_TAXPAYER;
  END IF;
  -- COMMIT;
  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES','JL_AR_UPDATE_CUST_SITE_TAX(-)');
  END IF;
END JL_AR_UPDATE_CUST_SITE_TAX;

PROCEDURE INITIALIZE IS
BEGIN
  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES','Initialize(+)');
  END IF;
  l_start_date_max       := NULL;
  l_start_date_sec_max   := NULL;
  l_end_date_sec_max     := NULL;
  l_end_date_max         := NULL;
  l_def_tax_code         := NULL;
  l_def_tax_rate         := NULL;
  l_exist_in_all         := NULL;
  l_proper_tax_rate_code := NULL;
  l_exist_in_tmp         := NULL;
  l_data_change_flag     := NULL;
  l_def_tax_flag         := NULL;
  IF g_level_statement >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_APPLICABLE_TAXES','Initialize(-)');
  END IF;
END INITIALIZE;

END JL_ZZ_AR_UPLOAD_TAXES;

/
