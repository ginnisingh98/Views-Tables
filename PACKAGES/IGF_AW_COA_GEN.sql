--------------------------------------------------------
--  DDL for Package IGF_AW_COA_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_GEN" AUTHID CURRENT_USER AS
/* $Header: IGFAW17S.pls 120.1 2005/08/10 01:27:18 appldev noship $ */
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 07-Oct-2004
--
--Purpose:Generic APIs for COA module
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

  FUNCTION coa_amount(
                      p_base_id           igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_awd_prd_code      igf_aw_award_prd.award_prd_cd%TYPE DEFAULT NULL,
                      p_use_direct_costs  igf_aw_coa_items.fixed_cost%TYPE DEFAULT 'N'
                     ) RETURN NUMBER;

  FUNCTION award_amount(
                        p_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_awd_prd_code igf_aw_award_prd.award_prd_cd%TYPE DEFAULT NULL,
                        p_award_id     igf_aw_award_all.award_id%TYPE DEFAULT NULL
                       ) RETURN NUMBER;

  FUNCTION isCoaLocked(
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                       p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                       p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                      ) RETURN BOOLEAN;

  FUNCTION doLock(
                  p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                  p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                  p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                 ) RETURN VARCHAR2;

  FUNCTION doUnlock(
                    p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                    p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                    p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                    p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                   ) RETURN VARCHAR2;

  TYPE base_details IS RECORD(
                              org_unit_cd          igf_aw_coa_rate_det.org_unit_cd%TYPE,
                              program_type      igf_aw_coa_rate_det.program_type%TYPE,
                              program_location_cd  igf_aw_coa_rate_det.program_location_cd%TYPE,
                              program_cd           igf_aw_coa_rate_det.program_cd%TYPE,
                              version_number         igs_en_spa_terms.program_version%TYPE,
                              class_standing    igf_aw_coa_rate_det.class_standing%TYPE,
                              residency_status_code  igf_aw_coa_rate_det.residency_status_code%TYPE,
                              housing_status_code    igf_aw_coa_rate_det.housing_status_code%TYPE,
                              attendance_type   igf_aw_coa_rate_det.attendance_type%TYPE,
                              attendance_mode   igf_aw_coa_rate_det.attendance_mode%TYPE,
                              months_enrolled_num    NUMBER,
                              credit_points_num      NUMBER
                             );

  FUNCTION getBaseDetails(
                          p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                          p_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                         ) RETURN base_details;

  PROCEDURE ins_coa_todo(
                          p_person_id      hz_parties.party_id%TYPE DEFAULT NULL,
                          p_calling_module VARCHAR2,
                          p_program_code   igs_ps_ver.course_cd%TYPE      DEFAULT NULL,
                          p_version_number igs_ps_ver.version_number%TYPE DEFAULT NULL
                         );
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  -- Inserts records into IGS_PE_STD_TODO and IGS_PE_STD_TODO_REF for the given person_id,
  -- thereby scheduling a COA Recomputation via concurrent process for the given person, in all open award years
  --
  -- Parameters:
  --  IN Parameters:
  --    1.p_person_id      - person_id of the student for whom COA needs to be recomputed
  --    2.p_calling_module - Module which schedules the COA recomputation because of a change in student attributes
  --    3.p_program_cd   - This is passed when the key program is changed for the person
  --    4.p_version_number - This is passed when the key program is changed for the person
  --  OUT Parameters:
  --    None
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  PROCEDURE get_coa_months(
                           p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                           p_start_dt     OUT NOCOPY DATE,
                           p_end_dt       OUT NOCOPY DATE,
                           p_coa_months   OUT NOCOPY NUMBER
                          );

  FUNCTION set_awd_proc_status(
                               p_base_id             IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_award_prd_code      IN  igf_aw_award_prd.award_prd_cd%TYPE DEFAULT NULL
                              ) RETURN VARCHAR2;

  PROCEDURE get_award_period_dates(
                                   p_ci_cal_type        IN  igs_ca_inst.cal_type%TYPE,
                                   p_ci_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
                                   p_award_prd_code     IN  igf_aw_awd_prd_term.award_prd_cd%TYPE,
                                   p_start_date         OUT NOCOPY DATE,
                                   p_end_date           OUT NOCOPY DATE
                                  );

  FUNCTION canUseAnticipVal RETURN BOOLEAN;

  PROCEDURE check_oss_attrib(
                             p_org_unit_code        IN  igf_ap_fa_ant_data.org_unit_cd%TYPE,
                             p_program_code         IN  igf_ap_fa_ant_data.program_cd%TYPE,
                             p_program_type         IN  igf_ap_fa_ant_data.program_type%TYPE,
                             p_program_location     IN  igf_ap_fa_ant_data.program_location_cd%TYPE,
                             p_attend_type          IN  igf_ap_fa_ant_data.attendance_type%TYPE,
                             p_attend_mode          IN  igf_ap_fa_ant_data.attendance_mode%TYPE,
                             p_ret_status           OUT NOCOPY VARCHAR2
                            );
  FUNCTION coa_duration(
                        p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                       ) RETURN NUMBER;
END igf_aw_coa_gen;

 

/
