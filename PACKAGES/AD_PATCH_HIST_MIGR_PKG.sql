--------------------------------------------------------
--  DDL for Package AD_PATCH_HIST_MIGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_HIST_MIGR_PKG" AUTHID CURRENT_USER as
/* $Header: adphmigs.pls 115.6 2002/02/26 17:12:54 pkm ship      $ */

procedure load_patch_driver
(
  p_src_ptch_drvr_id        number,
  p_chksum                  number,
  p_fil_size                number,
  p_drv_fil_nm              varchar2,
  p_src_cd                  varchar2,
  p_drv_typ_cflag           varchar2,
  p_drv_typ_dflag           varchar2,
  p_drv_typ_gflag           varchar2,
  p_plat                    varchar2,
  p_platver                 varchar2,
  p_orig_ptch_nm            varchar2,
  p_merged_driver_flag      varchar2,
  p_merge_date              date,
  p_src_ap_app_ptch_id      number,
  p_ap_ptch_nm              varchar2,
  p_ap_ptch_typ             varchar2,
  p_ap_mtpk_lvl             varchar2,
  p_ap_src_cd               varchar2,
  p_exported_from_db        varchar2,
  p_ap_rapid_installed_flag varchar2
);

procedure load_patch_driver_minipk
(
  p_src_cd                  varchar2,
  p_chksum                  number,
  p_fil_size                number,
  p_drv_fil_nm              varchar2,
  p_src_ptch_drvr_id        number,
  p_exported_from_db        varchar2,
  p_app_short_name          varchar2,
  p_patch_level             varchar2
);

procedure load_patch_driver_lang
(
  p_src_cd                  varchar2,
  p_chksum                  number,
  p_fil_size                number,
  p_drv_fil_nm              varchar2,
  p_src_ptch_drvr_id        number,
  p_exported_from_db        varchar2,
  p_language                varchar2
);

procedure load_comprising_patch
(
  p_src_cd                  varchar2,
  p_chksum                  number,
  p_fil_size                number,
  p_drv_fil_nm              varchar2,
  p_src_ptch_drvr_id        number,
  p_exported_from_db        varchar2,
  p_bug_number              varchar2,
  p_aru_release_name        varchar2
);

procedure load_patch_run
(
  p_start_date              date,
  p_at_nm                   varchar,
  p_apps_sys_nm             varchar,
  p_cache_appl_top_id       boolean,
  p_chksum                  number,
  p_filsiz                  number,
  p_filnm                   varchar,
  p_pd_src_cd               varchar,
  p_pr_patch_driver_id      number,
  p_exported_from_db        varchar,
  p_maj_v                   number,
  p_min_v                   number,
  p_tap_v                   number,
  p_rapid_install_flag      varchar,
  p_upd_to_maj_v            number,
  p_upd_to_min_v            number,
  p_upd_to_tap_v            number,
  p_patch_top               varchar,
  p_end_date                date,
  p_src_patch_run_id        number,
  p_patch_action_options    varchar,
  p_server_type_admin_flag  varchar,
  p_server_type_forms_flag  varchar,
  p_server_type_node_flag   varchar,
  p_server_type_web_flag    varchar,
  p_source_code             varchar,
  p_success_flag            varchar,
  p_failure_comments        varchar,
  p_record_against_rlse     varchar
);

procedure update_current_view_snapshot
(
  p_use_cache               boolean,
  p_start_date              date,
  p_at_nm                   varchar,
  p_apps_sys_nm             varchar,
  p_chksum                  number,
  p_filsiz                  number,
  p_filnm                   varchar,
  p_pd_src_cd               varchar,
  p_pr_patch_driver_id      number,
  p_exported_from_db        varchar
);

end ad_patch_hist_migr_pkg;

 

/
