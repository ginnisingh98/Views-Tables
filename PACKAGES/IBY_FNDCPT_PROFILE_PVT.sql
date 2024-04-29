--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_PROFILE_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyfcpfs.pls 120.0 2005/05/03 22:41:54 jleybovi noship $ */

  --
  -- Name: Get_Profile_Code
  --
  --
  PROCEDURE Get_Profile_Code
  (
  p_bepid          IN     iby_bepinfo.bepid%TYPE,
  p_payeeid        IN     iby_bepkeys.ownerid%TYPE,
  p_bepkey         IN     iby_bepkeys.key%TYPE,
  p_instr_type     IN     VARCHAR2,
  x_profile_code   OUT NOCOPY VARCHAR2
  );

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
  );

  PROCEDURE Delete_User_Profiles
  (
  p_commit           IN   VARCHAR2,
  p_cc_profile_code  IN   iby_fndcpt_user_cc_pf_vl.user_cc_profile_code%TYPE,
  p_eft_profile_code IN   iby_fndcpt_user_eft_pf_vl.user_eft_profile_code%TYPE,
  p_dc_profile_code  IN   iby_fndcpt_user_dc_pf_vl.user_dc_profile_code%TYPE
  );

END IBY_FNDCPT_PROFILE_PVT;

 

/
