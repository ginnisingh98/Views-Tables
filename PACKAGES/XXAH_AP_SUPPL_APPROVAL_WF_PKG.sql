--------------------------------------------------------
--  DDL for Package XXAH_AP_SUPPL_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_SUPPL_APPROVAL_WF_PKG" 
AS

/***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPL_APPROVAL_WF_PKG
   * DESCRIPTION       : PACKAGE for Supplier Approval Workflow
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           COMMENTS
   * 04-NOV-2019        1.0       Anish Hussain     Initial Package
   ****************************************************************************/

 TYPE t_split_array IS TABLE OF VARCHAR2(4000);
 FUNCTION xx_capture_event_parameters(p_subscription_guid IN RAW,
                                      p_event             IN OUT NOCOPY wf_event_t)
 RETURN VARCHAR2;

 PROCEDURE xx_debug_log (p_text IN VARCHAR2);

 PROCEDURE xx_update_status(p_party_id IN hz_parties.party_id%TYPE
                            ,p_status IN VARCHAR2
                            ,p_action IN VARCHAR2
                            ,p_user_id IN fnd_user.user_id%TYPE);
 PROCEDURE Update_supplier_bank_details(p_party_id IN hz_parties.party_id%TYPE
                                        ,p_action IN VARCHAR2
                                        ,p_user_id IN fnd_user.user_id%TYPE);
 PROCEDURE Update_payment_terms_details(p_party_id IN hz_parties.party_id%TYPE
                                        ,p_action IN VARCHAR2
                                        ,p_user_id IN fnd_user.user_id%TYPE);
 PROCEDURE xx_reset_approval_flag(p_party_id IN hz_parties.party_id%TYPE
                                  ,p_user_id  IN fnd_user.user_id%TYPE);

END XXAH_AP_SUPPL_APPROVAL_WF_PKG;

/
