--------------------------------------------------------
--  DDL for Package IRC_OFFER_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_NOTIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: irofrnotif.pkh 120.3.12010000.3 2009/09/04 13:41:30 amikukum ship $ */


-- ----------------------------------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------------------------------

--
-- -------------------------------------------------------------------------
-- |--------------------< get_view_offer_url >----------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_view_offer_url
  ( p_person_id          number
   ,p_apl_asg_id         number)
RETURN varchar2;
--
-- -------------------------------------------------------------------------
-- |------------------< get_manager_view_offer_url >--------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_manager_view_offer_url
  ( p_person_id          number
   ,p_apl_asg_id         number)
RETURN varchar2;
--
-- -------------------------------------------------------------------------
-- |------------------< get_extend_offer_duration_url >--------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_extend_offer_duration_url
  ( p_person_id          number
  , p_offer_id           number)
RETURN varchar2;
--
-- ----------------------------------------------------------------------------
--  send_rcvd_wf_notification                                                --
--     called internally to send offer received notification :               --
--     - retrieve the offer received message.                                --
--     - set the VACANCY_NAME & JOB_TITLE token.                             --
--     - build the offer details in HTML and TEXT format.                    --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_rcvd_wf_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
--  send_expiry_notification                                           --
--     called from concurrent process to send offer expiry notification :    --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_expiry_notification
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , p_number_of_days  in number);
--
--
--
-- ----------------------------------------------------------------------------
--  send_expired_notification                                          --
--     called from concurrent process to send offer expired notification :   --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_expired_notification
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number);
--
--
-- ----------------------------------------------------------------------------
--  send_applicant_response                                                  --
--     called internally to send offer acceptance notification :             --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_applicant_response(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2);

-- ----------------------------------------------------------------------------
--  send_applicant_response                                                  --
--     called internally to send notification about applicant response  :    --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_onhold_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2);

-- ----------------------------------------------------------------------------
--  send_withdrawal_notification                                             --
--  called internally to send notification about offer withdrawal  :         --
--  sends the notification to applicant and manager/recruiter                --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_withdrawal_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2);

-- ----------------------------------------------------------------------------
--  send_dcln_acptd_offer_notif                                             --
--  called internally to send notification about the applicant declining     --
--  offer after acceptance :
--  sends the notification to applicant and manager/recruiter                --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_dcln_acptd_offer_notif(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2);

END irc_offer_notifications_pkg;

/
