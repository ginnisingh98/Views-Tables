--------------------------------------------------------
--  DDL for Package HR_COMPLETE_APPRAISAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPLETE_APPRAISAL_SS" AUTHID CURRENT_USER AS
/* $Header: hrcpappr.pkh 120.0.12010000.2 2010/02/16 14:24:25 psugumar ship $*/

  gv_appr_compl_status varchar2(50) := 'HR_APPR_COMPL_STATUS';
  gv_upd_appr_status_log   varchar2(50) := 'HR_UPD_APPR_STATUS';
  gv_apply_asses_comps_log varchar2(50) := 'HR_APPLY_ASSESS_COMPS';
  gv_create_event_log      varchar2(50) := 'HR_CREATE_EVENT';
  gv_upd_trn_act_status_log varchar2(50) := 'HR_TRAIN_ACT_STATUS';

PROCEDURE COMPLETE_APPR
   ( item_type IN varchar2,
     item_key IN varchar2,
     p_result_out in out nocopy varchar2);


PROCEDURE SEND_NOTIFICATION
   ( p_item_type IN varchar2,
     p_item_key IN varchar2,
     p_result_out in out nocopy varchar2) ;

PROCEDURE change_appr_status
    ( appr_id per_appraisals.appraisal_id%TYPE,
      item_type IN varchar2,
      item_key IN varchar2,
      p_log  in out nocopy varchar2,
      chg_appr_status in out nocopy varchar2 ) ;

PROCEDURE COMPLETE_APPR_HR
   ( item_type IN varchar2,
     item_key IN varchar2,
     p_result_out in out nocopy varchar2);

END HR_COMPLETE_APPRAISAL_SS; -- Package spec


/
