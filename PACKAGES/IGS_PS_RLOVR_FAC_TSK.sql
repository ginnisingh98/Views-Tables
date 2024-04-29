--------------------------------------------------------
--  DDL for Package IGS_PS_RLOVR_FAC_TSK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_RLOVR_FAC_TSK" AUTHID CURRENT_USER AS
/* $Header: IGSPS83S.pls 120.1 2005/10/04 00:29:21 appldev ship $ */

--who        when            what
--
--============================================================================


  FUNCTION crsp_chk_inst_time_conft(
    p_start_dt_1  IN DATE ,
    p_end_dt_1  IN DATE,
    p_monday_1  IN VARCHAR2 ,
    p_tuesday_1  IN VARCHAR2 ,
    p_wednesday_1 IN VARCHAR2 ,
    p_thursday_1  IN VARCHAR2 ,
    p_friday_1  IN VARCHAR2 ,
    p_saturday_1  IN VARCHAR2 ,
    p_sunday_1  IN VARCHAR2 ,
    p_start_dt_2  IN DATE ,
    p_end_dt_2  IN DATE,
    p_monday_2  IN VARCHAR2 ,
    p_tuesday_2  IN VARCHAR2 ,
    p_wednesday_2 IN VARCHAR2 ,
    p_thursday_2  IN VARCHAR2 ,
    p_friday_2  IN VARCHAR2 ,
    p_saturday_2  IN VARCHAR2 ,
    p_sunday_2 IN VARCHAR2
  ) RETURN BOOLEAN ;

  --
  FUNCTION crsp_instrct_time_conflct(
    p_person_id  IN NUMBER ,
    p_unit_section_occurrence_id  IN NUMBER ,
    p_monday  IN VARCHAR2 ,
    p_tuesday  IN VARCHAR2 ,
    p_wednesday  IN VARCHAR2 ,
    p_thursday  IN VARCHAR2 ,
    p_friday  IN VARCHAR2 ,
    p_saturday  IN VARCHAR2 ,
    p_sunday  IN VARCHAR2 ,
    p_start_time  IN DATE ,
    p_end_time  IN DATE ,
    p_start_date IN DATE ,
    p_end_date IN DATE ,
    p_calling_module  IN VARCHAR2 ,
    p_message_name  OUT NOCOPY  VARCHAR2
  ) RETURN BOOLEAN ;

  --
  PROCEDURE  crsp_prc_inst_time_cft(
    p_person_id IN NUMBER ,
    p_cal_type IN VARCHAR2 ,
    p_sequence_number IN NUMBER
  ) ;

  --
  PROCEDURE  rollover_fac_task(
    errbuf  OUT NOCOPY VARCHAR2 ,
    retcode OUT NOCOPY NUMBER ,
    p_person_id  IN NUMBER ,
    p_source_cal_type  IN VARCHAR2 ,
    p_dest_cal_type  IN VARCHAR2 ,
    p_org_id  IN NUMBER
  ) ;


END igs_ps_rlovr_fac_tsk;

 

/
