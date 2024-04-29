--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_012" AUTHID CURRENT_USER AS
/* $Header: IGSAD12S.pls 120.0 2005/06/01 20:11:59 appldev noship $ */
 /****************************************************************************
  Created By :
  Date Created On :
  Purpose :

  Change History
  Who             When            What
  sjlaport        18-FEB-2005     Removed function get_inq_stat_id for IGR Migration
  rboddu          13-FEB-2003     removed PROCEDURE Admp_Upd_Eap_Avail. Moved this to
                                  igs_rc_gen_001 package. Bug:2664699
  (reverse chronological order - newest change first)
  *****************************************************************************/

FUNCTION Admp_Upd_Acai_Comm(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_prpsd_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

PROCEDURE Admp_Upd_Acai_Defer(
  p_log_creation_dt OUT NOCOPY DATE );

PROCEDURE Admp_Upd_Acai_Lapsed(
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_org_id IN NUMBER );

PROCEDURE Admp_Upd_Acai_Recon(
  p_log_creation_dt OUT NOCOPY DATE );

PROCEDURE Admp_Upd_Adm_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_adm_acad_cal_type IN VARCHAR2 ,
  p_adm_acad_ci_sequence_number IN NUMBER ,
  p_adm_adm_cal_type IN VARCHAR2 ,
  p_adm_adm_ci_sequence_number IN NUMBER ,
  p_adm_admission_cat IN VARCHAR2 ,
  p_adm_s_admission_process_type IN VARCHAR2 );

PROCEDURE Admp_Upd_Enq_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_enq_acad_cal_type IN VARCHAR2 ,
  p_enq_acad_ci_sequence_number IN NUMBER ,
  p_enq_adm_cal_type IN VARCHAR2 ,
  p_enq_adm_ci_sequence_number IN NUMBER );

FUNCTION Adms_Get_Acaiu_Uv(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;

FUNCTION ret_group_cd RETURN VARCHAR2;

--removed the function get_inq_stat_id for IGR migration (bug 2664699) sjlaport

END igs_ad_gen_012;

 

/
