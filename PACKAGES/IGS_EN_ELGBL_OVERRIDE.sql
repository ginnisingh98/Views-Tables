--------------------------------------------------------
--  DDL for Package IGS_EN_ELGBL_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ELGBL_OVERRIDE" AUTHID CURRENT_USER AS
/* $Header: IGSEN77S.pls 120.1 2006/05/02 01:45:33 amuthu noship $ */

-- ================================================================================

PROCEDURE enrp_elgbl_override(
/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created:
--
--Purpose:
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--kkillams    05-11-2002         As part of sevis build two new parameters are added.
--                               bug no # 2641905
--svanukur    13-jun-03          Changed the UI and validations for this job as part of
--                                validations setup CR
--ckasu       11-APR-2006        Modified as a part of Sevis Build bug# 5140084.
------------------------------------------------------------------  */
errbuf                     OUT NOCOPY VARCHAR2,
retcode                    OUT NOCOPY NUMBER,
p_trm_teach_cal_type_comb  IN  VARCHAR2,
p_program_cd_comb          IN  VARCHAR2,
p_location_cd              IN  VARCHAR2,
p_attendance_mode          IN  VARCHAR2,
p_attendance_type          IN  VARCHAR2,
p_unit_cd_comb             IN  VARCHAR2,
p_unit_set_comb            IN  VARCHAR2,
p_class_standing           IN  VARCHAR2,
p_org_unit_cd              IN  VARCHAR2,
p_person_id_group          IN  VARCHAR2,
p_person_id                IN  NUMBER,
p_program_attempt_status   IN  VARCHAR2,
p_person_step_1            IN  VARCHAR2,
p_program_step_1           IN  VARCHAR2,
p_over_credit_point_1      IN  NUMBER,
p_unit_step_1              IN  VARCHAR2,
p_unit_cd_1                IN  VARCHAR2,
p_unit_section_1           IN  NUMBER,
p_person_step_2            IN  VARCHAR2,
p_program_step_2           IN  VARCHAR2,
p_over_credit_point_2      IN  NUMBER,
p_unit_step_2              IN  VARCHAR2,
p_unit_cd_2                IN  VARCHAR2,
p_unit_section_2           IN  NUMBER,
p_person_step_3            IN  VARCHAR2,
p_program_step_3           IN  VARCHAR2,
p_unit_step_3              IN  VARCHAR2,
p_unit_cd_3                IN  VARCHAR2,
p_unit_section_3           IN  NUMBER,
p_person_step_4            IN  VARCHAR2,
p_program_step_4           IN  VARCHAR2,
p_unit_step_4              IN  VARCHAR2,
p_unit_cd_4                IN  VARCHAR2,
p_unit_section_4           IN  NUMBER,
p_person_ovr_step_1        IN  VARCHAR2,
p_unit_ovr_step_1          IN  VARCHAR2,
p_over_credit_point_3      IN  NUMBER,
p_unit_cd_ovr_1            IN  VARCHAR2,
p_unit_section_ovr_1       IN  NUMBER,
p_person_ovr_step_2        IN  VARCHAR2,
p_unit_ovr_step_2          IN  VARCHAR2,
p_over_credit_point_4      IN  NUMBER,
p_unit_cd_ovr_2            IN  VARCHAR2,
p_unit_section_ovr_2       IN  NUMBER,
p_person_ovr_step_3        IN  VARCHAR2,
p_unit_ovr_step_3          IN  VARCHAR2,
p_unit_cd_ovr_3            IN  VARCHAR2,
p_unit_section_ovr_3       IN  NUMBER,
p_person_ovr_step_4        IN  VARCHAR2,
p_unit_ovr_step_4          IN  VARCHAR2,
p_unit_cd_ovr_4            IN  VARCHAR2,
p_unit_section_ovr_4       IN  NUMBER,
p_org_id                   IN  NUMBER,
p_sevis_auth_cd            IN  VARCHAR2,
p_comments                 IN  VARCHAR2
);

END IGS_EN_ELGBL_OVERRIDE;

 

/
