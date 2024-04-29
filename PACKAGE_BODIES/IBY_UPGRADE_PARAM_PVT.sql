--------------------------------------------------------
--  DDL for Package Body IBY_UPGRADE_PARAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_UPGRADE_PARAM_PVT" AS
/* $Header: ibyupgpb.pls 120.0 2005/05/03 22:42:07 jleybovi noship $ */


--
-- Name: update_account
-- Args:
--       p_bep_account_id => the BEP account ID (type)
--       p_bepid_ => The bep ID
--       p_merchant_account_names => names of merchant account optionss
--       p_merchant_account_values => values of merchant account options
--       p_online_param_names    => names of online transmission parameters
--       p_online_param_values  => values of online transmission parameters
--       p_online_param_types   => types of online transmission parameters
--       p_settle_param_names    => names of settle transmission parameters
--       p_settle_param_values  => values of settle transmission parameters
--       p_settle_param_types   => types of settle transmission parameters
--       p_query_param_names    => names of query transmission parameters
--       p_query_param_values  => values of query transmission parameters
--       p_query_param_types   => types of online transmission parameters
--       p_commit => flag to indicate whether to commit
--
PROCEDURE update_account
          (
          p_bep_account_id          IN NUMBER,
	  p_bepid                   IN NUMBER,
          p_merchant_account_names  IN JTF_VARCHAR2_TABLE_100,
          p_merchant_account_values IN JTF_VARCHAR2_TABLE_100,
          p_online_param_names      IN JTF_VARCHAR2_TABLE_100,
          p_online_param_values     IN JTF_VARCHAR2_TABLE_100,
          p_online_param_types      IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_names      IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_values     IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_types      IN JTF_VARCHAR2_TABLE_100,
          p_query_param_names       IN JTF_VARCHAR2_TABLE_100,
          p_query_param_values      IN JTF_VARCHAR2_TABLE_100,
          p_query_param_types       IN JTF_VARCHAR2_TABLE_100,
          p_commit                  IN VARCHAR2 DEFAULT 'N'
          )
IS

l_user_id    NUMBER;
l_online_config_id NUMBER;
l_settle_config_id NUMBER;
l_query_config_id  NUMBER;
l_dummy       VARCHAR2(100);

CURSOR c_user_pf (ci_bep_account_id IBY_FNDCPT_USER_CC_PF_B.BEP_ACCOUNT_ID%TYPE) IS
        SELECT ONLINE_AUTH_TRANS_CONFIG_ID,
               SETTLEMENT_TRANS_CONFIG_ID,
               QUERY_TRANS_CONFIG_ID
        FROM   IBY_FNDCPT_USER_CC_PF_B
        WHERE  BEP_ACCOUNT_ID=ci_bep_account_id;

CURSOR c_acct_opt_exists(ci_bepid IBY_BEP_ACCT_OPT_VALS.BEPID%TYPE,
                         ci_bep_account_id IBY_BEP_ACCT_OPT_VALS.BEP_ACCOUNT_ID%TYPE)
IS     SELECT 1
       FROM   IBY_BEP_ACCT_OPT_VALS
       WHERE  BEPID=ci_bepid
       AND    BEP_ACCOUNT_ID=ci_bep_account_id;

CURSOR c_trans_config_exists(
ci_online_trans_config_id IBY_TRANSMIT_VALUES.TRANSMIT_CONFIGURATION_ID%TYPE,
ci_settle_trans_config_id IBY_TRANSMIT_VALUES.TRANSMIT_CONFIGURATION_ID%TYPE,
ci_query_trans_config_id IBY_TRANSMIT_VALUES.TRANSMIT_CONFIGURATION_ID%TYPE)
IS    SELECT  1
      FROM   IBY_TRANSMIT_VALUES
      WHERE  TRANSMIT_CONFIGURATION_ID IN (ci_online_trans_config_id,
	ci_settle_trans_config_id,ci_query_trans_config_id);


BEGIN

l_user_id :=fnd_global.user_id;

if l_user_id is null then
l_user_id:=1;

end if;

-- Check the merchant account exists

   IF (c_acct_opt_exists%ISOPEN) THEN
      CLOSE c_acct_opt_exists;
   END IF;


  OPEN c_acct_opt_exists(p_bepid, p_bep_account_id);

   FETCH c_acct_opt_exists into l_dummy;

     IF (c_acct_opt_exists%NOTFOUND) THEN
     -- Not found any merchant account options
     -- do upgrade


        IF (p_merchant_account_names.count<>0) THEN

              -- loop the merchant account
            FOR i IN p_merchant_account_names.FIRST .. p_merchant_account_names.LAST LOOP
              -- insert into the merchant account table


              IF ((NOT (TRIM(p_merchant_account_names(i)) is null))) THEN

                  INSERT INTO IBY_BEP_ACCT_OPT_VALS(
                  BEP_ACCOUNT_ID,
                  BEPID,
                  ACCOUNT_OPTION_CODE,
                  ACCOUNT_OPTION_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  p_bep_account_id,
                  p_bepid,
                  p_merchant_account_names(i),
                  p_merchant_account_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

	       END IF;
            END LOOP;
         END IF;
      END IF;

    CLOSE c_acct_opt_exists;


-- Check the tranmission parameters
   -- obtain the transmission config ID

   IF (c_user_pf%ISOPEN) THEN
      CLOSE c_user_pf;
   END IF;

   OPEN c_user_pf(p_bep_account_id);

   FETCH c_user_pf INTO l_online_config_id,
                        l_settle_config_id,
                        l_query_config_id;


     IF (NOT c_user_pf%NOTFOUND) THEN
        IF (c_trans_config_exists%ISOPEN) THEN
        CLOSE c_trans_config_exists;
        END IF;

        OPEN c_trans_config_exists(l_online_config_id,
                        l_settle_config_id,
                        l_query_config_id);

          FETCH c_trans_config_exists into l_dummy;

          IF (c_trans_config_exists%NOTFOUND) THEN

            IF (p_online_param_names.count<>0) THEN

              -- loop the online param
            FOR i IN p_online_param_names.FIRST .. p_online_param_names.LAST LOOP
              -- insert into online config table
              --varchar2 case

             IF(UPPER(TRIM(p_online_param_types(i)))='VARCHAR2') THEN
               IF ((NOT (TRIM(p_online_param_names(i)) is null))) THEN


                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_VARCHAR2_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_online_config_id,
                  p_online_param_names(i),
                  p_online_param_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
             END IF;
             --number case

             IF(UPPER(TRIM(p_online_param_types(i)))='NUMBER') THEN
               IF ((NOT (TRIM(p_online_param_names(i)) is null))) THEN


                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_NUMBER_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_online_config_id,
                  p_online_param_names(i),
                  TO_NUMBER(p_online_param_values(i)),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;

             --Date case

             IF(UPPER(TRIM(p_online_param_types(i)))='DATE') THEN
               IF ((NOT (TRIM(p_online_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_DATE_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_online_config_id,
                  p_online_param_names(i),
                  TO_DATE(p_online_param_values(i), 'YYYY/MM/DD'),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;


            END LOOP;
         END IF;

           -- settlement case
           IF (p_settle_param_names.count<>0) THEN

              -- loop the settle param
            FOR i IN p_settle_param_names.FIRST .. p_settle_param_names.LAST LOOP
              -- insert into settle config table
              --varchar2 case

             IF(UPPER(TRIM(p_settle_param_types(i)))='VARCHAR2') THEN
               IF ((NOT (TRIM(p_settle_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_VARCHAR2_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_settle_config_id,
                  p_settle_param_names(i),
                  p_settle_param_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
             END IF;
             --number case

             IF(UPPER(TRIM(p_settle_param_types(i)))='NUMBER') THEN
               IF ((NOT (TRIM(p_settle_param_names(i)) is null))) THEN


                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_NUMBER_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_settle_config_id,
                  p_settle_param_names(i),
                  p_settle_param_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;

             --Date case

             IF(UPPER(TRIM(p_settle_param_types(i)))='DATE') THEN
               IF ((NOT (TRIM(p_settle_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_DATE_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_settle_config_id,
                  p_settle_param_names(i),
                  TO_DATE(p_settle_param_values(i), 'YYYY/MM/DD'),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;


            END LOOP;
         END IF;

-- end of settlement case

-- query case

           IF (p_query_param_names.count<>0) THEN

              -- loop the query param
            FOR i IN p_query_param_names.FIRST .. p_query_param_names.LAST LOOP
              -- insert into query config table
              --varchar2 case

             IF(UPPER(TRIM(p_query_param_types(i)))='VARCHAR2') THEN
               IF ((NOT (TRIM(p_query_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_VARCHAR2_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_query_config_id,
                  p_query_param_names(i),
                  p_query_param_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
             END IF;
             --number case

             IF(UPPER(TRIM(p_query_param_types(i)))='NUMBER') THEN
               IF ((NOT (TRIM(p_query_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_NUMBER_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_query_config_id,
                  p_query_param_names(i),
                  p_query_param_values(i),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;

             --Date case

             IF(UPPER(TRIM(p_query_param_types(i)))='DATE') THEN
               IF ((NOT (TRIM(p_query_param_names(i)) is null))) THEN

                  INSERT INTO IBY_TRANSMIT_VALUES(
                  TRANSMIT_VALUE_ID,
                  TRANSMIT_CONFIGURATION_ID,
                  TRANSMIT_PARAMETER_CODE,
                  TRANSMIT_DATE_VALUE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATED_BY,
                  OBJECT_VERSION_NUMBER)
                VALUES(
                  iby_transmit_values_s.nextval,
                  l_query_config_id,
                  p_query_param_names(i),
                  TO_DATE(p_query_param_values(i), 'YYYY/MM/DD'),
                  l_user_id,
                  sysdate,
                  sysdate,
                  l_user_id,
                  l_user_id,
                  1);

              END IF;
            END IF;


            END LOOP;
         END IF;

-- end of query case

           END IF;
     CLOSE c_trans_config_exists;

     END IF;

     CLOSE c_user_pf;
     commit;


END;

END IBY_UPGRADE_PARAM_PVT;

/
