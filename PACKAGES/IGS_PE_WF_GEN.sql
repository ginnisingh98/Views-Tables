--------------------------------------------------------
--  DDL for Package IGS_PE_WF_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_WF_GEN" AUTHID CURRENT_USER AS
/* $Header: IGSPE07S.pls 120.4 2006/05/26 05:39:17 vskumar ship $ */

/******************************************************************
 Created By         : Vinay Chappidi
 Date Created By    : 20-Sep-2001
 Purpose            : Workflow General package for Person Module
 remarks            :
 Change History
 Who      When        What
 sarakshi 23-Jan-2006 Bug#4938278, created TYPE t_addr_chg_persons and three procedures process_addr_sync,write_addr_sync_message and addr_bulk_synchronization
 asbala  1-SEP-03    Created procedures get_res_details and process_residency and modified change_residence
 gmaheswa 1-Nov-2004 Created a procedure change_housing_status for raising an event in case of insert/update of housing status
 pkpatel   9-Nov-2004  Bug 3993967 (Modified signature of procedure CHANGE_RESIDENCE)
 pkpatel  19=Sep-2005 Bug 4618459 (Removed the reference of HZ_PARAM_TAB. Commented the procedure get_address_dtls.
 gmaheswa  17-Jan-20076 Bug 4938278: Removed comments code.
 vskumar   24-May-2006 Bug 5211157 Added two procdeures specs raise_acad_intent_event and process_acad_intent
******************************************************************/

  TYPE t_addr_chg_persons IS TABLE OF hz_parties.party_id%TYPE INDEX BY PLS_INTEGER;
  ti_addr_chg_persons t_addr_chg_persons;


  PROCEDURE change_residence(p_resident_details_id IN NUMBER,
							 p_old_res_status IN VARCHAR2,
							 p_old_evaluator IN VARCHAR2,
							 p_old_evaluation_date IN VARCHAR2,
							 p_old_comment IN VARCHAR2,
							 p_action IN VARCHAR2);

  PROCEDURE change_address  ( p_person_number IN VARCHAR2, p_full_name IN VARCHAR2);

  PROCEDURE get_res_details( p_person_id IN NUMBER, p_res_class IN VARCHAR2,
                             p_res_dtls_rec OUT NOCOPY igs_pe_res_dtls_v%ROWTYPE,
                             p_ind IN VARCHAR2 DEFAULT 'NEW');

  PROCEDURE process_residency(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                              funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2);

  PROCEDURE address_create(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                              funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2);

  PROCEDURE address_update(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                              funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2);

  PROCEDURE primary_address_ind_update(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                              funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2);

  PROCEDURE change_housing_status(p_person_id IN NUMBER,
                                  p_housing_status IN VARCHAR2,
                		  P_CALENDER_TYPE  IN VARCHAR2,
                		  P_CAL_SEQ_NUM    IN NUMBER,
            			  P_TEACHING_PERIOD_ID IN NUMBER,
                  		  P_ACTION         IN VARCHAR2 );

  PROCEDURE process_addr_sync(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2
                                );

  PROCEDURE write_addr_sync_message(document_id    IN VARCHAR2,
                                    display_type   IN VARCHAR2,
                                    document       IN OUT NOCOPY CLOB,
                                    document_type  IN OUT NOCOPY  VARCHAR2
                                     );

  PROCEDURE addr_bulk_synchronization (p_persons_processes IN OUT NOCOPY t_addr_chg_persons);

 PROCEDURE raise_acad_intent_event(P_ACAD_INTENT_ID IN NUMBER,
                                       P_PERSON_ID IN NUMBER,
                                       P_CAL_TYPE  IN VARCHAR2,
                                       P_CAL_SEQ_NUMBER  IN NUMBER,
                                       P_ACAD_INTENT_CODE IN VARCHAR2,
                                       P_OLD_ACAD_INTENT_CODE IN VARCHAR2 );

 PROCEDURE process_acad_intent(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER,
                                 funcmode IN VARCHAR2, resultout OUT NOCOPY VARCHAR2);

END igs_pe_wf_gen;

 

/
