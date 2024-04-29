--------------------------------------------------------
--  DDL for Package IGS_AD_TI_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TI_COMP" AUTHID CURRENT_USER AS
/* $Header: IGSADA3S.pls 120.1 2005/10/25 03:32:36 appldev ship $ */

g_called_from VARCHAR2(1);
  PROCEDURE upd_trk_itm_st(
                           ERRBUF                         OUT NOCOPY  VARCHAR2,
                           RETCODE                        OUT NOCOPY  NUMBER,
                           p_person_id                    IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_person_id_group              IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                           p_admission_appl_number        IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                    IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number              IN   igs_ad_ps_appl_inst.sequence_number%TYPE,
                           p_calendar_details             IN   VARCHAR2,
                           p_admission_process_category   IN   VARCHAR2,
                           p_org_id                       IN   igs_pe_prsid_grp_mem_all.org_id%TYPE
                          );

END igs_ad_ti_comp;

 

/
