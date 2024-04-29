--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_PROFILE_PVT" AS
/* $Header: ibyfcpfb.pls 120.0 2005/05/03 22:41:51 jleybovi noship $ */

  PROCEDURE Insert_Trans_Config
  (
   p_profile_name  IN VARCHAR2,
   p_protocol_code IN iby_transmit_configs_vl.transmit_protocol_code%TYPE,
   x_config_id     OUT NOCOPY iby_transmit_configs_b.transmit_configuration_id%TYPE
   )
  IS
    l_rowid     ROWID;
  BEGIN

    SELECT iby_transmit_configs_s.nextval
    INTO x_config_id
    FROM dual;

    iby_pp_mlsutl_pvt.trans_config_insert_row
    (
    X_ROWID => l_rowid,
    X_TRANSMIT_CONFIGURATION_ID => x_config_id,
    X_OBJECT_VERSION_NUMBER => 1,
    X_TUNNELING_TRANS_CONFIG_ID => null,
    X_TRANSMIT_PROTOCOL_CODE => p_protocol_code,
    X_INACTIVE_DATE => null,
    X_TRANSMIT_CONFIGURATION_NAME => p_profile_name || ' ' || p_protocol_code,
    X_CREATION_DATE => sysdate,
    X_CREATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );
  END Insert_Trans_Config;

  PROCEDURE Delete_Trans_Config
  (p_config_id   IN  iby_transmit_configs_b.transmit_configuration_id%TYPE)
  IS
  BEGIN

    IF (p_config_id IS NULL) THEN
      RETURN;
    END IF;

    DELETE
    FROM iby_transmit_values
    WHERE (transmit_configuration_id=p_config_id);

    iby_pp_mlsutl_pvt.trans_config_delete_row(p_config_id);

  END Delete_Trans_Config;

  PROCEDURE Get_Profile_Code
  (
  p_bepid          IN     iby_bepinfo.bepid%TYPE,
  p_payeeid        IN     iby_bepkeys.ownerid%TYPE,
  p_bepkey         IN     iby_bepkeys.key%TYPE,
  p_instr_type     IN     VARCHAR2,
  x_profile_code   OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN

    x_profile_code := NULL;

    IF (p_instr_type in ( 'CREDITCARD', 'PURCHASECARD')) THEN

      SELECT user_cc_profile_code
      INTO x_profile_code
      FROM iby_fndcpt_user_cc_pf_b prof, iby_bepkeys key
      WHERE (prof.bep_account_id = key.bep_account_id)
        AND (key.bepid = p_bepid)
        AND (key.ownertype = 'PAYEE')
        AND (key.ownerid = p_payeeid)
        AND (key.key = p_bepkey);

    ELSIF (p_instr_type = 'BANKACCOUNT') THEN

      SELECT user_eft_profile_code
      INTO x_profile_code
      FROM iby_fndcpt_user_eft_pf_b prof, iby_bepkeys key
      WHERE (prof.bep_account_id = key.bep_account_id)
        AND (key.bepid = p_bepid)
        AND (key.ownertype = 'PAYEE')
        AND (key.ownerid = p_payeeid)
        AND (key.key = p_bepkey);

    ELSIF (p_instr_type = 'PINLESSDEBITCARD') THEN

      SELECT user_dc_profile_code
      INTO x_profile_code
      FROM iby_fndcpt_user_dc_pf_b prof, iby_bepkeys key
      WHERE (prof.bep_account_id = key.bep_account_id)
        AND (key.bepid = p_bepid)
        AND (key.ownertype = 'PAYEE')
        AND (key.ownerid = p_payeeid)
        AND (key.key = p_bepkey);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_profile_code := NULL;
  END Get_Profile_Code;

  PROCEDURE Create_User_Profiles
  (
  p_bepid            IN   iby_bepinfo.bepid%TYPE,
  p_bep_acct_id      IN   iby_bepkeys.bep_account_id%TYPE,
  p_cc_profile_code  IN   iby_fndcpt_user_cc_pf_vl.user_cc_profile_code%TYPE,
  p_cc_profile_name  IN   iby_fndcpt_user_cc_pf_vl.user_cc_profile_name%TYPE,
  p_eft_profile_code IN   iby_fndcpt_user_eft_pf_vl.user_eft_profile_code%TYPE,
  p_eft_profile_name IN   iby_fndcpt_user_eft_pf_vl.user_eft_profile_name%TYPE,
  p_dc_profile_code  IN   iby_fndcpt_user_dc_pf_vl.user_dc_profile_code%TYPE,
  p_dc_profile_name  IN   iby_fndcpt_user_dc_pf_vl.user_dc_profile_name%TYPE,
  x_cc_online_cfg_id OUT NOCOPY
                     iby_fndcpt_user_cc_pf_vl.online_auth_trans_config_id%TYPE,
  x_cc_settle_cfg_id OUT NOCOPY
                     iby_fndcpt_user_cc_pf_vl.settlement_trans_config_id%TYPE,
  x_cc_query_cfg_id  OUT NOCOPY
                     iby_fndcpt_user_cc_pf_vl.query_trans_config_id%TYPE,
  x_eft_verify_cfg_id OUT NOCOPY
                     iby_fndcpt_user_eft_pf_vl.verify_trans_config_id%TYPE,
  x_eft_xfer_cfg_id  OUT NOCOPY
                     iby_fndcpt_user_eft_pf_vl.funds_xfer_trans_config_id%TYPE,
  x_eft_query_cfg_id OUT NOCOPY
                     iby_fndcpt_user_eft_pf_vl.query_trans_config_id%TYPE,
  x_dc_online_cfg_id OUT NOCOPY
                     iby_fndcpt_user_dc_pf_vl.online_deb_trans_config_id%TYPE,
  x_dc_settle_cfg_id OUT NOCOPY
                     iby_fndcpt_user_dc_pf_vl.settlement_trans_config_id%TYPE,
  x_dc_query_cfg_id  OUT NOCOPY
                     iby_fndcpt_user_dc_pf_vl.query_trans_config_id%TYPE
  )
  IS
    l_rowid              ROWID;

    l_profile_code       VARCHAR2(30);
    l_online_trans_code  VARCHAR2(30);
    l_settle_trans_code  VARCHAR2(30);
    l_query_trans_code   VARCHAR2(30);

    l_online_trans_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;
    l_settle_trans_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;
    l_query_trans_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;

    CURSOR c_sys_cc_profile
    (ci_bepid iby_bepinfo.bepid%TYPE)
    IS
      SELECT sys_cc_profile_code,online_auth_trans_prtcl_code,
        settlement_trans_prtcl_code,query_trans_prtcl_code
      FROM iby_fndcpt_sys_cc_pf_b profs
      WHERE profs.payment_system_id = ci_bepid
      AND NVL(inactive_date,SYSDATE+30)>SYSDATE;

    CURSOR c_sys_eft_profile
    (ci_bepid iby_bepinfo.bepid%TYPE)
    IS
      SELECT sys_eft_profile_code,verify_trans_prtcl_code,
        funds_xfer_trans_prtcl_code,query_trans_prtcl_code
      FROM iby_fndcpt_sys_eft_pf_b profs
      WHERE profs.payment_system_id = ci_bepid
      AND NVL(inactive_date,SYSDATE+30)>SYSDATE;

    CURSOR c_sys_dc_profile
    (ci_bepid iby_bepinfo.bepid%TYPE)
    IS
      SELECT sys_dc_profile_code,online_deb_trans_prtcl_code,
        settlement_trans_prtcl_code,query_trans_prtcl_code
      FROM iby_fndcpt_sys_dc_pf_b profs
      WHERE profs.payment_system_id = ci_bepid
      AND NVL(inactive_date,SYSDATE+30)>SYSDATE;

  BEGIN

    IF (c_sys_cc_profile%ISOPEN) THEN
      CLOSE c_sys_cc_profile;
    END IF;
    IF (c_sys_eft_profile%ISOPEN) THEN
      CLOSE c_sys_eft_profile;
    END IF;
    IF (c_sys_dc_profile%ISOPEN) THEN
      CLOSE c_sys_dc_profile;
    END IF;

    -- cursors for system profiles assume there is only a single
    -- profile per payment system

    -- create credit card user profiles for the payment system
    OPEN c_sys_cc_profile(p_bepid);
    FETCH c_sys_cc_profile INTO l_profile_code,l_online_trans_code,
      l_settle_trans_code,l_query_trans_code;
    IF (NOT c_sys_cc_profile%NOTFOUND) THEN
      IF (NOT l_online_trans_code IS NULL) THEN
        Insert_Trans_Config(p_cc_profile_name,l_online_trans_code,
          l_online_trans_cfg_id);
      END IF;
      IF (NOT l_settle_trans_code IS NULL) THEN
        Insert_Trans_Config(p_cc_profile_name,l_settle_trans_code,
          l_settle_trans_cfg_id);
      END IF;
      IF (NOT l_query_trans_code IS NULL) THEN
        Insert_Trans_Config(p_cc_profile_name,l_query_trans_code,
          l_query_trans_cfg_id);
      END IF;

      iby_fndcpt_mlsutl_pvt.user_cc_prof_insert_row
      (
      X_ROWID => l_rowid,
      X_USER_CC_PROFILE_CODE => p_cc_profile_code,
      X_OBJECT_VERSION_NUMBER => 1,
      X_BEP_ACCOUNT_ID => p_bep_acct_id,
      X_SYS_CC_PROFILE_CODE => l_profile_code,
      X_INACTIVE_DATE => null,
      X_QUERY_TRANS_CONFIG_ID => l_query_trans_cfg_id,
      X_ONLINE_AUTH_TRANS_CONFIG_ID => l_online_trans_cfg_id,
      X_SETTLEMENT_TRANS_CONFIG_ID => l_settle_trans_cfg_id,
      X_USER_CC_PROFILE_NAME => p_cc_profile_name,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
      );

    END IF;
    CLOSE c_sys_cc_profile;

    -- create eft user profiles for the payment system
    OPEN c_sys_eft_profile(p_bepid);
    FETCH c_sys_eft_profile INTO l_profile_code,l_online_trans_code,
      l_settle_trans_code,l_query_trans_code;
    IF (NOT c_sys_eft_profile%NOTFOUND) THEN
      IF (NOT l_online_trans_code IS NULL) THEN
        Insert_Trans_Config(p_eft_profile_name,l_online_trans_code,
          l_online_trans_cfg_id);
      END IF;
      IF (NOT l_settle_trans_code IS NULL) THEN
        Insert_Trans_Config(p_eft_profile_name,l_settle_trans_code,
          l_settle_trans_cfg_id);
      END IF;
      IF (NOT l_query_trans_code IS NULL) THEN
        Insert_Trans_Config(p_eft_profile_name,l_query_trans_code,
          l_query_trans_cfg_id);
      END IF;

      iby_fndcpt_mlsutl_pvt.user_eft_prof_insert_row
      (
      X_ROWID => l_rowid,
      X_USER_EFT_PROFILE_CODE => p_eft_profile_code,
      X_OBJECT_VERSION_NUMBER => 1,
      X_BEP_ACCOUNT_ID => p_bep_acct_id,
      X_SYS_EFT_PROFILE_CODE => l_profile_code,
      X_INACTIVE_DATE => null,
      X_QUERY_TRANS_CONFIG_ID => l_query_trans_cfg_id,
      X_VERIFY_TRANS_CONFIG_ID => l_online_trans_cfg_id,
      X_FUNDS_XFER_TRANS_CONFIG_ID => l_settle_trans_cfg_id,
      X_USER_EFT_PROFILE_NAME => p_eft_profile_name,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
      );

    END IF;
    CLOSE c_sys_eft_profile;

    -- create debit card user profiles for the payment system
    OPEN c_sys_dc_profile(p_bepid);
    FETCH c_sys_dc_profile INTO l_profile_code,l_online_trans_code,
      l_settle_trans_code,l_query_trans_code;
    IF (NOT c_sys_dc_profile%NOTFOUND) THEN
      IF (NOT l_online_trans_code IS NULL) THEN
        Insert_Trans_Config(p_dc_profile_name,l_online_trans_code,
          l_online_trans_cfg_id);
      END IF;
      IF (NOT l_settle_trans_code IS NULL) THEN
        Insert_Trans_Config(p_dc_profile_name,l_settle_trans_code,
          l_settle_trans_cfg_id);
      END IF;
      IF (NOT l_query_trans_code IS NULL) THEN
        Insert_Trans_Config(p_dc_profile_name,l_query_trans_code,
          l_query_trans_cfg_id);
      END IF;

      iby_fndcpt_mlsutl_pvt.user_dc_prof_insert_row
      (
      X_ROWID => l_rowid,
      X_USER_DC_PROFILE_CODE => p_dc_profile_code,
      X_OBJECT_VERSION_NUMBER => 1,
      X_BEP_ACCOUNT_ID => p_bep_acct_id,
      X_SYS_DC_PROFILE_CODE => l_profile_code,
      X_INACTIVE_DATE => null,
      X_QUERY_TRANS_CONFIG_ID => l_query_trans_cfg_id,
      X_ONLINE_DEB_TRANS_CONFIG_ID => l_online_trans_cfg_id,
      X_SETTLEMENT_TRANS_CONFIG_ID => l_settle_trans_cfg_id,
      X_USER_DC_PROFILE_NAME => p_dc_profile_name,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
      );

    END IF;
    CLOSE c_sys_dc_profile;

    COMMIT;
  END Create_User_Profiles;

  PROCEDURE Delete_User_Profiles
  (
  p_commit           IN   VARCHAR2,
  p_cc_profile_code  IN   iby_fndcpt_user_cc_pf_vl.user_cc_profile_code%TYPE,
  p_eft_profile_code IN   iby_fndcpt_user_eft_pf_vl.user_eft_profile_code%TYPE,
  p_dc_profile_code  IN   iby_fndcpt_user_dc_pf_vl.user_dc_profile_code%TYPE
  )
  IS
    l_online_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;
    l_settle_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;
    l_query_cfg_id iby_transmit_configs_b.transmit_configuration_id%TYPE;

    CURSOR c_cc_user_prof
    (ci_profile_code  iby_fndcpt_user_cc_pf_b.user_cc_profile_code%TYPE)
    IS
      SELECT online_auth_trans_config_id, settlement_trans_config_id,
        query_trans_config_id
      FROM iby_fndcpt_user_cc_pf_b
      WHERE (user_cc_profile_code=ci_profile_code);

    CURSOR c_eft_user_prof
    (ci_profile_code  iby_fndcpt_user_eft_pf_b.user_eft_profile_code%TYPE)
    IS
      SELECT verify_trans_config_id, funds_xfer_trans_config_id,
        query_trans_config_id
      FROM iby_fndcpt_user_eft_pf_b
      WHERE (user_eft_profile_code=ci_profile_code);

    CURSOR c_dc_user_prof
    (ci_profile_code  iby_fndcpt_user_dc_pf_b.user_dc_profile_code%TYPE)
    IS
      SELECT online_deb_trans_config_id, settlement_trans_config_id,
        query_trans_config_id
      FROM iby_fndcpt_user_dc_pf_b
      WHERE (user_dc_profile_code=ci_profile_code);

  BEGIN

  IF (c_cc_user_prof%ISOPEN) THEN
    CLOSE c_cc_user_prof;
  END IF;
  IF (c_eft_user_prof%ISOPEN) THEN
    CLOSE c_eft_user_prof;
  END IF;
  IF (c_dc_user_prof%ISOPEN) THEN
    CLOSE c_dc_user_prof;
  END IF;

  OPEN c_cc_user_prof(p_cc_profile_code);
  FETCH c_cc_user_prof INTO
    l_online_cfg_id, l_settle_cfg_id, l_query_cfg_id;
  IF (NOT c_cc_user_prof%NOTFOUND) THEN
    Delete_Trans_Config(l_online_cfg_id);
    Delete_Trans_Config(l_settle_cfg_id);
    Delete_Trans_Config(l_query_cfg_id);

    DELETE
    FROM iby_fndcpt_user_cc_pf_b
    WHERE (user_cc_profile_code=p_cc_profile_code);
  END IF;
  CLOSE c_cc_user_prof;

  OPEN c_eft_user_prof(p_eft_profile_code);
  FETCH c_eft_user_prof INTO
    l_online_cfg_id, l_settle_cfg_id, l_query_cfg_id;
  IF (NOT c_eft_user_prof%NOTFOUND) THEN
    Delete_Trans_Config(l_online_cfg_id);
    Delete_Trans_Config(l_settle_cfg_id);
    Delete_Trans_Config(l_query_cfg_id);

    DELETE
    FROM iby_fndcpt_user_eft_pf_b
    WHERE (user_eft_profile_code=p_eft_profile_code);
  END IF;
  CLOSE c_eft_user_prof;

  OPEN c_dc_user_prof(p_dc_profile_code);
  FETCH c_dc_user_prof INTO
    l_online_cfg_id, l_settle_cfg_id, l_query_cfg_id;
  IF (NOT c_dc_user_prof%NOTFOUND) THEN
    Delete_Trans_Config(l_online_cfg_id);
    Delete_Trans_Config(l_settle_cfg_id);
    Delete_Trans_Config(l_query_cfg_id);

    DELETE
    FROM iby_fndcpt_user_dc_pf_b
    WHERE (user_dc_profile_code=p_dc_profile_code);
  END IF;
  CLOSE c_dc_user_prof;

  COMMIT;

  END Delete_User_Profiles;

END IBY_FNDCPT_PROFILE_PVT;

/
