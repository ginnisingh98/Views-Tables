--------------------------------------------------------
--  DDL for Package HR_WPM_MASS_SCORE_CARD_TRNSF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPM_MASS_SCORE_CARD_TRNSF" AUTHID CURRENT_USER AS
/* $Header: hrwpmtrnsf.pkh 120.0 2006/04/11 17:24:13 vbala noship $*/


   g_package varchar2(100) := 'HR_WPM_MASS_SCORE_CARD_TRNSF.';

   SC_LIST_WF_ATTR_NAME VARCHAR2(20) := 'HR_WPM_SCORE_CARDS';
   SC_PROCESSED_LIST_WF_ATTR_NAME VARCHAR2(30) := 'HR_WPM_SCORE_CRADS_PROCESSED';
   SC_PERFORMER_WF_ATTR_NAME VARCHAR2(30):= 'HR_WPM_SCORE_CARD_PERFORMER';
   SC_OVN_LIST_WF_ATTR_NAME VARCHAR2(30) := 'SC_OVN_LIST';
   SC_OVNS_PROCESSED_WF_ATTR_NAME VARCHAR2(30) := 'SC_OVNS_PROCESSED';

   TYPE score_card_type IS RECORD( scorecard_id per_personal_scorecards.scorecard_id%TYPE,
                          ovn per_personal_scorecards.object_version_number%TYPE);


   PROCEDURE MassScoreCardTransfer
     ( score_card_list IN VARCHAR2 DEFAULT null,
       sc_ovn_list IN VARCHAR2 DEFAULT null,
       txn_owner_person_id in per_all_people_f.person_id%TYPE,
       comments in varchar2,
       result_code out nocopy VARCHAR2 );

   PROCEDURE Defer(itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2);


   PROCEDURE IS_FINAL_SCORE_CARD (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2);

   PROCEDURE FAILED_SCORE_CARDS (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2);

   PROCEDURE PROCESS_SCORE_CARD (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2);

  PROCEDURE TEST_ACTIVITY (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2);

  procedure SEND_NTF(itemtype   in varchar2,
		  itemkey    in varchar2,
      	  actid      in number,
		  funcmode   in varchar2,
		  resultout  in out nocopy varchar2);


END HR_WPM_MASS_SCORE_CARD_TRNSF; -- Package spec


 

/
