--------------------------------------------------------
--  DDL for Package Body JL_BR_SPED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_SPED_PUB" AS
/* $Header: jlspedpb.pls 120.0.12010000.3 2009/08/10 10:44:10 mbarrett noship $ */

--  Global Constant variable for holding Package Name

    G_PKG_NAME	CONSTANT    VARCHAR2(20):=  'JL_BR_SPED_PUB';

-- Declare VARRAY

  TYPE token_array IS TABLE OF VARCHAR2(25) INDEX BY binary_integer;
  TYPE value_for_token IS TABLE OF VARCHAR2(25) INDEX BY binary_integer;


-- Function REPLACE_TOKEN for replacing tokens with actual value

FUNCTION REPLACE_TOKEN(
  msg IN VARCHAR2,
  tokens IN token_array,
  tokenValues IN value_for_token) RETURN VARCHAR2 IS

  message VARCHAR2(1000);

  BEGIN
    message := msg;
    FOR iNtex IN tokens.FIRST .. tokens.LAST LOOP
    message := replace(message,tokens(iNtex),tokenValues(iNtex));
    END LOOP;

  RETURN message;

END REPLACE_TOKEN;

-- UPDATE_ATTRIBUTES Procedure - To update the attributes

PROCEDURE UPDATE_ATTRIBUTES (
  P_API_VERSION	              IN	    NUMBER      DEFAULT 1.0,
  P_COMMIT	              IN	    VARCHAR2    DEFAULT FND_API.G_FALSE,
  P_CUSTOMER_TRX_ID           IN	    NUMBER,
  P_ELECT_INV_WEB_ADDRESS     IN	    VARCHAR2,
  P_ELECT_INV_STATUS          IN	    VARCHAR2,
  P_ELECT_INV_ACCESS_KEY      IN            VARCHAR2,
  P_ELECT_INV_PROTOCOL        IN	    VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2)

  IS

  -- Declaration part

    CURSOR C_EXT IS
      SELECT COUNT(*) as cnt FROM JL_BR_CUSTOMER_TRX_EXTS
      WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

    CURSOR C_TRX IS
      SELECT 'Yes' as isExist
      FROM JL_BR_CUSTOMER_TRX_EXTS
      WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
      AND ELECTRONIC_INV_STATUS IN ('2','7');

    CURSOR C_CUST_TRX_EXIST IS
      SELECT 'Yes' as isExist FROM RA_CUSTOMER_TRX_ALL
      WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

    CURSOR C_VALID_EI_STATUS IS
      SELECT 'Yes' as isExist FROM FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'JLBR_EI_STATUS'
      AND LOOKUP_CODE = P_ELECT_INV_STATUS;

  l_count                     NUMBER;
  isExist                     VARCHAR2(5)  := 'No';
  l_api_name                  VARCHAR2(30) := 'UPDATES_ATTRIBUTES';
  l_api_version               NUMBER       := 1.0;
  inv_status_final            EXCEPTION;
  invalid_cust_trx_id         EXCEPTION;
  invalid_ei_status           EXCEPTION;
  incompatible_apiversion     EXCEPTION;
  invalid_commit_param        EXCEPTION;
  invalid_apiversion          EXCEPTION;

  tok_arr  token_array;
  val_for_token  value_for_token;

  BEGIN

   X_RETURN_STATUS   :=  FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, P_API_VERSION, l_api_name, G_PKG_NAME) THEN
                 tok_arr(1) := '&'||'CURR_VER_NUM';
                 tok_arr(2) := '&'||'API_NAME';
                 tok_arr(3) := '&'||'PKG_NAME';
                 tok_arr(4) := '&'||'CALLER_VER_NUM';
                 val_for_token(1) := l_api_version;
                 val_for_token(2) := l_api_name;
                 val_for_token(3) := G_PKG_NAME;
                 val_for_token(4) := P_API_VERSION;
          IF TRUNC(l_api_version) > TRUNC(P_API_VERSION) THEN
                 RAISE incompatible_apiversion;
          ELSE
                 RAISE invalid_apiversion;
          END IF;
    END IF;


    FOR cust_trx_exist_rec IN C_CUST_TRX_EXIST  LOOP
        isExist := cust_trx_exist_rec.isExist;
    END LOOP;

    /* If Valid customer Trx ID is passed */
    IF  isExist = 'Yes' THEN

          isExist := 'No'; -- Reinitializing the var

          FOR ei_status_rec IN C_VALID_EI_STATUS LOOP
              isExist := ei_status_rec.isExist;
          END LOOP;

          /* If Valid Electronic Invoice Staus is passed */
          IF isExist = 'Yes' THEN
                  FOR ext_rec IN C_EXT  LOOP
                      l_count := ext_rec.cnt;
                  END LOOP;

                  IF l_count = 0 THEN
                      -- Create an entry in JL_BR_CUSTOMER_TRX_EXTS table
                      INSERT INTO JL_BR_CUSTOMER_TRX_EXTS(
                                CUSTOMER_TRX_ID,
                                ELECTRONIC_INV_WEB_ADDRESS,
                                ELECTRONIC_INV_STATUS,
                                ELECTRONIC_INV_ACCESS_KEY,
                                ELECTRONIC_INV_PROTOCOL,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN,
                                CREATED_BY,
                                CREATION_DATE)
                      VALUES (
                                P_CUSTOMER_TRX_ID,
                                P_ELECT_INV_WEB_ADDRESS,
                                P_ELECT_INV_STATUS,
                                P_ELECT_INV_ACCESS_KEY,
                                P_ELECT_INV_PROTOCOL,
                                SYSDATE,
                                -1,
                                -1,
                                -1,
                                SYSDATE);
                  ELSE

                      -- Bug 8780811
                      If p_elect_inv_status <> '4' Then
                         FOR trx_rec IN  C_TRX LOOP
                            RAISE inv_status_final;
                         END LOOP;
                      End If;
                      -- Bug 8780811

                      UPDATE JL_BR_CUSTOMER_TRX_EXTS
                      SET ELECTRONIC_INV_WEB_ADDRESS = P_ELECT_INV_WEB_ADDRESS,
                          ELECTRONIC_INV_STATUS = P_ELECT_INV_STATUS,
                          ELECTRONIC_INV_ACCESS_KEY = P_ELECT_INV_ACCESS_KEY,
                          ELECTRONIC_INV_PROTOCOL = P_ELECT_INV_PROTOCOL,
                          LAST_UPDATE_DATE = SYSDATE,
                          LAST_UPDATED_BY = -1,
                          LAST_UPDATE_LOGIN = -1
                      WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

                  END IF;

                  IF P_ELECT_INV_STATUS IN ('2','7') THEN
                        UPDATE AR_PAYMENT_SCHEDULES_ALL
                        SET SELECTED_FOR_RECEIPT_BATCH_ID = NULL
                        WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
                  END IF;


                  BEGIN
                      IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
                          COMMIT;
                      ELSE
                          ROLLBACK;
                      END IF;
                  EXCEPTION
                      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                      RAISE invalid_commit_param;
                  END;


          ELSE   /* If Invalid Electronic Invoice Status is passed */
               tok_arr(1) := '&'||'INV_STATUS';
               val_for_token(1) := P_ELECT_INV_STATUS;
              RAISE invalid_ei_status;
          END IF;
    ELSE     /* If Invalid customer Trx ID is passed */
           tok_arr(1) := '&'||'TRX_ID';
           val_for_token(1) := P_CUSTOMER_TRX_ID;
           RAISE invalid_cust_trx_id;
    END IF;

EXCEPTION

    WHEN invalid_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INVALID_VER_NUM',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN incompatible_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INCOMPATIBLE_API_CALL',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN invalid_cust_trx_id THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INVALID_CUST_TRX_ID',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN invalid_ei_status THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INVALID_EI_STATUS',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN inv_status_final THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_EI_FINALIZED',NULL);

    WHEN invalid_commit_param THEN
      ROLLBACK;
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_API_COMMIT',NULL);

    WHEN OTHERS THEN
      ROLLBACK;
      tok_arr(1) := 'ERRMSG';
      val_for_token(1) := SQLERRM;
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_UNEXP_ERROR;
      X_MSG_DATA :=  FND_MESSAGE.GET_STRING('JL','JL_BR_API_ERROR',NULL);
      X_MSG_DATA :=  REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

END UPDATE_ATTRIBUTES;

-- INSERT_LOG Procedure - To insert the log

PROCEDURE INSERT_LOG (
  P_API_VERSION	              IN	    NUMBER    DEFAULT 1.0,
  P_COMMIT	              IN	    VARCHAR2  DEFAULT FND_API.G_FALSE,
  P_CUSTOMER_TRX_ID           IN	    NUMBER,
  P_OCCURRENCE_DATE           IN	    DATE,
  P_ELECT_INV_STATUS          IN	    VARCHAR2,
  P_MESSAGE_TEXT              IN            VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2)

  IS

  -- Declaration part

  CURSOR C_INV_STATUS IS
    SELECT ELECTRONIC_INV_STATUS
    FROM JL_BR_CUSTOMER_TRX_EXTS
    WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

  CURSOR C_CUST_TRX_EXIST IS
    SELECT 'Yes' as isExist FROM RA_CUSTOMER_TRX_ALL
    WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

  CURSOR C_VALID_EI_STATUS IS
    SELECT 'Yes' as isExist FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'JLBR_EI_STATUS'
    AND LOOKUP_CODE = P_ELECT_INV_STATUS;

  l_api_name          VARCHAR2(30)  := 'INSERT_LOG';
  l_api_version       NUMBER        := 1.0;
  isExist             VARCHAR2(5)      :='No';
  inv_status_differs  EXCEPTION;
  invalid_cust_trx_id EXCEPTION;
  invalid_ei_status   EXCEPTION;
  incompatible_apiversion     EXCEPTION;
  invalid_commit_param        EXCEPTION;
  invalid_apiversion          EXCEPTION;

  tok_arr  token_array;
  val_for_token  value_for_token;

  BEGIN

  X_RETURN_STATUS   :=  FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, P_API_VERSION, l_api_name, G_PKG_NAME) THEN
                 tok_arr(1) := '&'||'CURR_VER_NUM';
                 tok_arr(2) := '&'||'API_NAME';
                 tok_arr(3) := '&'||'PKG_NAME';
                 tok_arr(4) := '&'||'CALLER_VER_NUM';
                 val_for_token(1) := l_api_version;
                 val_for_token(2) := l_api_name;
                 val_for_token(3) := G_PKG_NAME;
                 val_for_token(4) := P_API_VERSION;
          IF TRUNC(l_api_version) > TRUNC(P_API_VERSION) THEN
                 RAISE incompatible_apiversion;
          ELSE
                 RAISE invalid_apiversion;
          END IF;
    END IF;


  FOR cust_trx_exist_rec IN C_CUST_TRX_EXIST  LOOP
      isExist := cust_trx_exist_rec.isExist;
  END LOOP;

  /* If Valid customer Trx ID is passed */
  IF  isExist = 'Yes' THEN

        isExist := 'No'; -- Reinitializing the var

        FOR ei_status_rec IN C_VALID_EI_STATUS  LOOP
            isExist := ei_status_rec.isExist;
        END LOOP;

        /* If Valid Electronic Invoice Staus is passed */
        IF isExist = 'Yes' THEN

            FOR inv_status_rec IN C_INV_STATUS LOOP
                IF inv_status_rec.ELECTRONIC_INV_STATUS <>  P_ELECT_INV_STATUS THEN
                    RAISE inv_status_differs;
                END IF;
            END LOOP;


            -- Create an entry in JL_BR_EILOG table
            INSERT INTO JL_BR_EILOG (
                    OCCURRENCE_ID,
                    OCCURRENCE_DATE,
                    CUSTOMER_TRX_ID,
                    ELECTRONIC_INV_STATUS,
                    MESSAGE_TXT,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY)
            VALUES
                    (JL_BR_EILOG_S.NEXTVAL,
                    P_OCCURRENCE_DATE,
                    P_CUSTOMER_TRX_ID,
                    P_ELECT_INV_STATUS,
                    P_MESSAGE_TEXT,
                    SYSDATE,
                    -1,
                    -1,
                    SYSDATE,
                    -1);

            BEGIN
                IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
                    COMMIT;
                ELSE
                    ROLLBACK;
                END IF;
            EXCEPTION
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                RAISE invalid_commit_param;
            END;

      ELSE   /* If Invalid Electronic Invoice Status is passed */
          tok_arr(1) := '&'||'INV_STATUS';
          val_for_token(1) := P_ELECT_INV_STATUS;
          RAISE invalid_ei_status;
      END IF;
  ELSE     /* If Invalid customer Trx ID is passed */
         tok_arr(1) := '&'||'TRX_ID';
         val_for_token(1) := P_CUSTOMER_TRX_ID;
         RAISE invalid_cust_trx_id;
  END IF;


EXCEPTION

    WHEN invalid_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INVALID_VER_NUM',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN incompatible_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INCOMPATIBLE_API_CALL',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN invalid_cust_trx_id THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INVALID_CUST_TRX_ID',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN invalid_ei_status THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INVALID_EI_STATUS',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN inv_status_differs THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INV_STATUS_DIFFERS',NULL);

    WHEN invalid_commit_param THEN
      ROLLBACK;
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_API_COMMIT',NULL);

    WHEN OTHERS THEN
      ROLLBACK;
      tok_arr(0) := 'ERRMSG';
      val_for_token(0) := SQLERRM;
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_UNEXP_ERROR;
      X_MSG_DATA :=  FND_MESSAGE.GET_STRING('JL','JL_BR_API_ERROR',NULL);
      X_MSG_DATA :=  REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

END INSERT_LOG;


-- GET_IBGE_CODES Procedure - To retrieve IBGE code for a given Location

PROCEDURE GET_IBGE_CODES (
  P_API_VERSION	              IN	    NUMBER    DEFAULT 1.0,
  P_LOCATION_ID               IN	    NUMBER      ,
  X_STATE_CODE                OUT   NOCOPY  VARCHAR2,
  X_CITY_CODE                 OUT   NOCOPY  VARCHAR2,
  X_CENTRAL_BANK_CODE         OUT   NOCOPY  VARCHAR2,
  X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
  X_MSG_DATA                  OUT   NOCOPY  VARCHAR2)

  IS

  -- Declaration part

	  CURSOR get_state_code IS
		SELECT
		      identifier_value state
		FROM
		      hz_geography_identifiers geo_ident,
		      hz_geo_name_references geo_ref,
		      hz_locations loc
		WHERE
		      loc.location_id = P_LOCATION_ID
			  and loc.location_id = geo_ref.location_id
			  and geo_ref.geography_type = 'STATE'
			  and geo_ident.identifier_subtype = 'IBGE'
			  and geo_ident.geography_id = geo_ref.geography_id
			  and geo_ident.geography_type = 'STATE';


	CURSOR get_city_code IS
		SELECT
			  identifier_value city
		FROM
			  hz_geography_identifiers geo_ident,
			  hz_geo_name_references geo_ref,
			  hz_locations loc
		WHERE
			  loc.location_id = P_LOCATION_ID
			  and loc.location_id = geo_ref.location_id
			  and geo_ref.geography_type = 'CITY'
			  and geo_ident.identifier_subtype = 'IBGE'
			  and geo_ident.geography_id = geo_ref.geography_id
			  and geo_ident.geography_type = 'CITY';

	CURSOR get_bank_code IS
		  SELECT meaning
		  FROM FND_LOOKUPS
		  WHERE lookup_type = 'JLBR_CBANK_COUNTRY_CODES'
						 and lookup_code = (SELECT country
						 FROM hz_locations
						 WHERE location_id = P_LOCATION_ID);

    CURSOR c_valid_location IS
		  SELECT
				'Yes' as isexist
		  FROM 	HZ_LOCATIONS
		  WHERE
				location_id = P_LOCATION_ID;


  l_api_name          VARCHAR2(30)  := 'GET_IBGE_CODES';
  l_api_version       NUMBER        := 1.0;
  isExist             VARCHAR2(5)   := 'No';
  invalid_loc_id      EXCEPTION;
  incompatible_apiversion     EXCEPTION;
  invalid_apiversion          EXCEPTION;
  l_state_col varchar2(30);
  l_city_col varchar2(30);

  tok_arr  token_array;
  val_for_token  value_for_token;

  BEGIN

  X_RETURN_STATUS   :=  FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, P_API_VERSION, l_api_name, G_PKG_NAME) THEN
                 tok_arr(1) := '&'||'CURR_VER_NUM';
                 tok_arr(2) := '&'||'API_NAME';
                 tok_arr(3) := '&'||'PKG_NAME';
                 tok_arr(4) := '&'||'CALLER_VER_NUM';
                 val_for_token(1) := l_api_version;
                 val_for_token(2) := l_api_name;
                 val_for_token(3) := G_PKG_NAME;
                 val_for_token(4) := P_API_VERSION;
          IF TRUNC(l_api_version) > TRUNC(P_API_VERSION) THEN
                 RAISE incompatible_apiversion;
          ELSE
                 RAISE invalid_apiversion;
          END IF;
    END IF;


    FOR location_rec IN c_valid_location LOOP
        isExist := location_rec.isExist;
    END LOOP;

    /* If Valid Location ID is passed */
    IF isExist = 'Yes' THEN

        -- get state code
	    FOR c_state_code_rec IN get_state_code LOOP
	        X_STATE_CODE := c_state_code_rec.state;
	    END LOOP;

        -- get city code

	    FOR c_city_code_rec IN get_city_code LOOP
		    X_CITY_CODE := c_city_code_rec.city;
	    END LOOP;

	    -- get bank code
	    FOR c_bank_code_rec IN get_bank_code LOOP
		    X_CENTRAL_BANK_CODE := c_bank_code_rec.meaning;
	    END LOOP;

    ELSE
      tok_arr(1) := '&'||'LOC_ID';
      val_for_token(1) := P_LOCATION_ID;
      RAISE invalid_loc_id;
    END IF;

EXCEPTION

    WHEN invalid_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INVALID_VER_NUM',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN incompatible_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INCOMPATIBLE_API_CALL',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN invalid_loc_id THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('JL','JL_BR_INVALID_LOC_ID',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN OTHERS THEN
      ROLLBACK;
      tok_arr(1) := 'ERRMSG';
      val_for_token(1) := SQLERRM;
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_UNEXP_ERROR;
      X_MSG_DATA :=  FND_MESSAGE.GET_STRING('JL','JL_BR_API_ERROR',NULL);
      X_MSG_DATA :=  REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

END GET_IBGE_CODES;

END JL_BR_SPED_PUB;

/
