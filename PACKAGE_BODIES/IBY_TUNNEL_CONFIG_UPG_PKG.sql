--------------------------------------------------------
--  DDL for Package Body IBY_TUNNEL_CONFIG_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TUNNEL_CONFIG_UPG_PKG" AS
/* $Header: ibytunlb.pls 120.3 2006/09/08 22:23:47 jleybovi noship $ */

  PROCEDURE CREATE_TUNNELING_CONFIGS
  IS
    lx_rowid      ROWID;
    l_config_id   NUMBER;
    l_config_name VARCHAR(100);
    l_tunnel_name VARCHAR(100);
    l_url         VARCHAR(1024);
    l_update_count NUMBER;

    CURSOR c_bep IS
      SELECT bepid, suffix, name, baseurl
      FROM iby_bepinfo
      WHERE (NOT baseurl IS NULL)
      ORDER BY last_update_date DESC;

  BEGIN
    IF (c_bep%ISOPEN) THEN CLOSE c_bep; END IF;

    SELECT transmit_protocol_name
    INTO l_tunnel_name
    FROM iby_transmit_protocols_vl
    WHERE transmit_protocol_code='IBY_DELIVERY_ENVELOPE';

    FOR bep_rec IN c_bep LOOP

      SELECT iby_transmit_configs_s.nextval INTO l_config_id FROM DUAL;

      -- cc profiles
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT online_auth_trans_config_id
         FROM iby_fndcpt_user_cc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT settlement_trans_config_id
         FROM iby_fndcpt_user_cc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
      AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT query_trans_config_id
         FROM iby_fndcpt_user_cc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;

      -- debit card profiles
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT online_deb_trans_config_id
         FROM iby_fndcpt_user_dc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT settlement_trans_config_id
         FROM iby_fndcpt_user_dc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT query_trans_config_id
         FROM iby_fndcpt_user_dc_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;

      -- eft profiles
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT verify_trans_config_id
         FROM iby_fndcpt_user_eft_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT funds_xfer_trans_config_id
         FROM iby_fndcpt_user_eft_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;
      UPDATE iby_transmit_configs_b
      SET tunneling_trans_config_id=l_config_id
      WHERE transmit_configuration_id IN
        (SELECT query_trans_config_id
         FROM iby_fndcpt_user_eft_pf_b p, iby_bepkeys k
         WHERE (p.bep_account_id = k.bep_account_id)
           AND (k.bepid = bep_rec.bepid)
        )
        AND (tunneling_trans_config_id IS NULL);
      l_update_count := l_update_count + SQL%ROWCOUNT;

      IF (l_update_count>0) THEN
        l_config_name := bep_rec.name || ' ' || l_tunnel_name;
        IF (SUBSTR(bep_rec.baseurl,-1) = '/') THEN
          l_url := bep_rec.baseurl || 'oramipp_' || bep_rec.suffix;
        ELSIF (SUBSTR(bep_rec.baseurl,-11,7) = 'oramipp') THEN
          l_url := bep_rec.baseurl;
        ELSE
          l_url := bep_rec.baseurl || '/oramipp_' || bep_rec.suffix;
        END IF;

        -- new servlet mount-point in R12 techstack
        l_url := REPLACE(l_url,'oa_servlets','OA_HTML');

        IBY_PP_MLSUTL_PVT.TRANS_CONFIG_INSERT_ROW
        (lx_rowid,l_config_id,1,null,'IBY_DELIVERY_ENVELOPE',
         null,l_config_name,sysdate,fnd_global.user_id,sysdate,
         fnd_global.user_id,fnd_global.login_id);

        INSERT INTO iby_transmit_values
        (transmit_value_id, transmit_configuration_id, transmit_parameter_code,
         transmit_varchar2_value, transmit_number_value, transmit_date_value,
         created_by, creation_date, last_updated_by, last_update_date,
         last_update_login, object_version_number)
        VALUES
        (iby_transmit_values_s.nextval, l_config_id, 'WEB_URL',
         l_url, null, null,
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.login_id, 1);
      END IF;

    END LOOP;

    COMMIT;
  END CREATE_TUNNELING_CONFIGS;

END IBY_TUNNEL_CONFIG_UPG_PKG;


/
