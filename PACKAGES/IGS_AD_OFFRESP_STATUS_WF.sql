--------------------------------------------------------
--  DDL for Package IGS_AD_OFFRESP_STATUS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_OFFRESP_STATUS_WF" AUTHID CURRENT_USER AS
/* $Header: IGSADD0S.pls 115.0 2003/10/13 16:18:32 rboddu noship $ */
---------------------------------------------------------------------------------------------------
--  Created By : rboddu
--  Date Created On : 07-OCT-2003
--  Purpose : 3132406
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
---------------------------------------------------------------------------------------------------

  PROCEDURE adm_offer_response_changed (
       p_person_id              IN igs_ad_ps_appl_inst_all.person_id%TYPE,
       p_admission_appl_number  IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
       p_nominated_course_cd    IN igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
       p_sequence_number        IN igs_ad_ps_appl_inst_all.sequence_number%TYPE,
       p_old_offresp_status     IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
       p_new_offresp_status     IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE
       );

   PROCEDURE wf_get_person_attributes(
                       itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2 ) ;

  PROCEDURE check_single_response  (
                        itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2
		       );

END igs_ad_offresp_status_wf;

 

/
