--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSAD02S.pls 120.6 2005/11/02 18:42:22 appldev ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --knag        04-Oct-02       Bug 2602096 : Created the function Admp_Get_Appl_ID to return Application ID
  --                                          and the function Admp_Get_Fee_Status to return Appl Fee Status
  --anwest      20-Jul-05       IGS.M ADTD003:Created for the Submitted
  --                                          Applications Reusable Component
  --                                          to further derive the PENDING fee
  --                                          status
  --anwest		03-Nov-05		IGS.M ADTD002:Created function Is_EntQualCode_Allowed
 -------------------------------------------------------------------------------------------

Procedure Admp_Ext_Tac_Arts(
  p_input_file IN VARCHAR2 ,
  p_output_file IN VARCHAR2 ,
  p_directory IN VARCHAR2 );



Procedure Admp_Ext_Vtac_Return(
  errbuf OUT NOCOPY VARCHAR2 ,
  retcode OUT NOCOPY NUMBER ,
  p_acad_perd IN VARCHAR2,
  p_input_file IN VARCHAR2,
  p_org_id     IN NUMBER);

Function Admp_Get_Aal_Sent_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN DATE;

Function Admp_Get_Aa_Aas(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2;

Procedure Admp_Get_Aa_Created(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_create_who OUT NOCOPY VARCHAR2 ,
  p_create_on OUT NOCOPY DATE );

Procedure Admp_Get_Aa_Dtl(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_admission_cat OUT NOCOPY VARCHAR2 ,
  p_s_admission_process_type OUT NOCOPY VARCHAR2 ,
  p_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_appl_dt OUT NOCOPY DATE ,
  p_adm_appl_status OUT NOCOPY VARCHAR2 ,
  p_adm_fee_status OUT NOCOPY VARCHAR2 );

Function Admp_Get_Acai_Acadcd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Admp_Get_Acai_Acadcd,WNDS);

Function Admp_Get_Acai_Aos_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN DATE;



Procedure ADMS_EXT_TAC_ARTS  (

             errbuf          out NOCOPY  varchar2,

             retcode         out NOCOPY  number,

             p_input_file    IN VARCHAR2 ,
             p_org_id        IN NUMBER);

Function Admp_Get_Appl_ID(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER)
RETURN NUMBER;

Function Admp_Get_Fee_Status(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER)
RETURN VARCHAR2;

PROCEDURE check_adm_appl_inst_stat(
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE  DEFAULT NULL,
  p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE DEFAULT NULL,
  p_updateable VARCHAR2 DEFAULT 'N'                                      -- apadegal - TD001 - IGS.M.
 );


-- This function will return true if  for this application at least one application instance has an application offer response
--  status of 'Accepted' OR the offer response status is 'Deffered' with the deferment status as 'Confirmed'. For all other
--  cases it will return false.  -- rghosh (bug#2901627)
FUNCTION   valid_ofr_resp_status(
                                       p_person_id igs_ad_ps_appl_inst.person_id%TYPE ,
               p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE)
               RETURN BOOLEAN ;

-- 20-Jul-2005  ANWEST  Created for the Submitted Applications Reusable Component
--                      (ADTD003) in IGS.M
FUNCTION res_pending_fee_status
(
    p_application_id IN NUMBER
)
RETURN VARCHAR2;

PROCEDURE Admp_resub_inst(
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
  p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
  p_do_commit VARCHAR2 DEFAULT NULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2
  );

--Begin  apadegal TD001 IGS.M

FUNCTION check_any_offer_inst
                (p_person_id  IGS_AD_PS_APPL_INST.person_id%TYPE,
                 p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                 p_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE DEFAULT NULL,
                 p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE DEFAULT NULL
                 )
RETURN BOOLEAN;

FUNCTION Is_App_Inst_Complete (
      p_person_id IN NUMBER ,
      p_admission_appl_number IN NUMBER ,
      p_nominated_course_cd IN VARCHAR2,
      p_sequence_number IN NUMBER
     )
RETURN VARCHAR2;

PROCEDURE Is_inst_recon_allowed ( p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
          p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
          p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
          p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
          p_success out nocopy VARCHAR2,
                                  p_message_name out nocopy VARCHAR2
        );
FUNCTION Is_inst_recon_allowed (  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
          p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
          p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
          p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE
             )
RETURN VARCHAR2;


PROCEDURE Reconsider_Appl_Inst (
        p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
        p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
        p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
        p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
        p_interface           VARCHAR2  -- Interface which has raised reconsideration ( Forms,Self service, Import process)
                          ) ;


PROCEDURE Recon_Appl_inst (
                           p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
         p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
         p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
         p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
         p_interface            VARCHAR2  -- Interface which has raised reconsideration ( Forms,Self service, Import process)
      ); --- this procedure would be invoked from

FUNCTION  check_adm_appl_inst_stat(                           -- An overloaded function - would be invoked in Self Service
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE  DEFAULT NULL,
  p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE DEFAULT NULL,
  p_updateable VARCHAR2 DEFAULT 'N'                                                 -- apadegal - TD001 - IGS.M.
  )
  RETURN VARCHAR2;


 PROCEDURE ins_dummy_pend_hist_rec ( p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
            p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
            p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE
          ) ;

--End  apadegal TD001 IGS.m

-- 02-NOV-05 ANWEST Created for IGS.M ADTD002 AT Testing Issue #327
FUNCTION Is_EntQualCode_Allowed (p_person_id IN NUMBER ,
                                 p_admission_appl_number IN NUMBER ,
                                 p_nominated_course_cd IN VARCHAR2,
                                 p_sequence_number IN NUMBER)
RETURN VARCHAR2;

END IGS_AD_GEN_002;

 

/
