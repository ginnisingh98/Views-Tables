--------------------------------------------------------
--  DDL for Package IGS_AD_WRKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_WRKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADC6S.pls 115.2 2003/06/06 23:14:57 tmajumde noship $ */

PROCEDURE   Extract_Applications
                       (  errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER ,
                          p_person_id                   IN   hz_parties.party_id%TYPE,
			  p_person_id_group		IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                          p_calendar_details            IN   VARCHAR2,
                          p_apc                         IN   VARCHAR2,
                          p_appl_type                   IN   VARCHAR2,
                          p_prog_code                   IN   VARCHAR2,
                          p_location                    IN   VARCHAR2,
                          p_att_type                    IN   VARCHAR2,
                          p_att_mode                    IN   VARCHAR2,
                          p_appl_no_calendar            IN   VARCHAR2,
                          p_appl_range                  IN   VARCHAR2
                        );

PROCEDURE  Wf_Inform_Applicant_INAP
                       (  p_applicant_id       IN   NUMBER,
                          p_applicant_name     IN   VARCHAR2,
                          p_applicant_full_name IN   VARCHAR2
                        );

PROCEDURE wf_set_url_inap  (itemtype    IN  VARCHAR2  ,
                        itemkey     IN  VARCHAR2  ,
                        actid       IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
                        resultout   OUT NOCOPY VARCHAR2
                       );

PROCEDURE   Adm_Application_Req
                       (  errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER ,
                          p_person_id                   IN   hz_parties.party_id%TYPE,
                          p_person_id_group             IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                          p_appl_id                     IN   igs_ad_appl.application_id%Type,
                          p_calendar_details            IN   VARCHAR2,
                          p_tracking_type               IN   VARCHAR2,
                          p_apc                         IN   VARCHAR2,
                          p_appl_type                   IN   VARCHAR2,
                          p_prog_code                   IN   VARCHAR2,
                          p_location                    IN   VARCHAR2,
                          p_att_type                    IN   VARCHAR2,
                          p_att_mode                    IN   VARCHAR2
                        );

PROCEDURE  Wf_Admission_Req
                       (  p_applicant_id     		IN   NUMBER,
			  p_applicant_name      	IN   VARCHAR2,
			  p_applicant_display_name     	IN   VARCHAR2,
                          p_alt_code_acad            	IN   VARCHAR2,
                          p_alt_code_adm             	IN   VARCHAR2
                        );

PROCEDURE  Wf_Post_Adm_Req
                       (  p_applicant_id		IN   NUMBER,
			  p_applicant_name      	IN   VARCHAR2,
			  p_applicant_display_name      IN   VARCHAR2,
                          p_alt_code_acad            	IN   VARCHAR2,
                          p_alt_code_adm             	IN   VARCHAR2
                        );

END IGS_AD_WRKFLOW_PKG;

 

/
