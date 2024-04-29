--------------------------------------------------------
--  DDL for Package IGF_GR_PELL_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_PELL_CALC" AUTHID CURRENT_USER AS
/* $Header: IGFGR11S.pls 120.2 2005/09/26 08:41:08 appldev ship $ */

 -- Pell award and its disbursements will be returned via this PL/SQL Table
 TYPE pell_rec IS RECORD(
                            process_id                      NUMBER,
                            sl_number                       NUMBER,
                            fund_id                         NUMBER,
                            base_id                         NUMBER,
                            disb_dt                           DATE,
                            ld_cal_type               VARCHAR2(10),
                            ld_sequence_number              NUMBER,
                            tp_cal_type               VARCHAR2(10),
                            tp_sequence_number              NUMBER,
                            offered_amt                     NUMBER,
                            accepted_amt                    NUMBER,
                            paid_amt                        NUMBER,
                            app_trans_num_txt          VARCHAR2(30),
                            adplans_id                      NUMBER,
                            DISB_EXP_DT                       DATE,
                            MIN_CREDIT_PTS                  NUMBER,
                            VERF_ENFR_DT                      DATE,
                            SHOW_ON_BILL              VARCHAR2(30),
                            ATTENDANCE_TYPE_CODE      VARCHAR2(30),
                            BASE_ATTENDANCE_TYPE_CODE VARCHAR2(30),
                            term_amt                        NUMBER
                       );

 TYPE pell_tab IS TABLE OF pell_rec;


  PROCEDURE get_pell_setup ( cp_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_course_cd       IN  igf_gr_pell_setup_all.course_cd%TYPE,
                             cp_version_number  IN igf_gr_pell_setup_all.version_number%TYPE,
			     cp_cal_type        IN igs_ca_inst.cal_type%TYPE,
			     cp_sequence_number IN igs_ca_inst.sequence_number%TYPE,
			     cp_pell_setup_rec  IN OUT NOCOPY igf_gr_pell_setup_all%ROWTYPE ,
			     cp_message         OUT NOCOPY VARCHAR2,
			     cp_return_status   OUT NOCOPY VARCHAR2
			     );

   PROCEDURE get_pell_coa_efc (
                               cp_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE,
                               cp_attendance_type    IN  igf_ap_attend_map.attendance_type%TYPE,
			       cp_pell_setup_rec     IN  igf_gr_pell_setup_all%ROWTYPE ,
			       cp_coa                OUT NOCOPY NUMBER,
			       cp_efc                OUT NOCOPY NUMBER,
			       cp_pell_schedule_code OUT NOCOPY VARCHAR2,
			       cp_message            OUT NOCOPY VARCHAR2,
			       cp_return_status      OUT NOCOPY VARCHAR2
			     );

   PROCEDURE get_pell_attendance_type (
                                cp_base_id              IN igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_ld_cal_type          IN igs_ca_inst.cal_type%TYPE,
				cp_ld_sequence_number   IN igs_ca_inst.sequence_number%TYPE,
 			        cp_pell_setup_rec       IN  igf_gr_pell_setup_all%ROWTYPE ,
                                cp_attendance_type      IN OUT NOCOPY igf_ap_attend_map.attendance_type%TYPE,
  			        cp_message              OUT NOCOPY VARCHAR2,
			        cp_return_status        OUT NOCOPY VARCHAR2
			     ) ;

PROCEDURE get_pell_matrix_amt(
                     cp_cal_type      IN igs_ca_inst.cal_type%TYPE,
                     cp_sequence_num  IN igs_ca_inst.sequence_number%TYPE,
                     cp_efc           IN NUMBER,
                     cp_pell_schd     IN VARCHAR2,
                     cp_enrl_stat     IN VARCHAR2,
                     cp_pell_coa      IN NUMBER,
                     cp_pell_alt_exp  IN NUMBER,
                     cp_called_from   IN VARCHAR2,
		     cp_return_status IN OUT NOCOPY VARCHAR2,
		     cp_message       IN OUT NOCOPY VARCHAR2,
                     cp_aid           IN OUT NOCOPY NUMBER );

PROCEDURE calc_pell(
                                cp_fund_id       IN igf_aw_fund_mast_all.fund_id%TYPE,
				cp_plan_id       IN igf_aw_awd_dist_plans.adplans_id%TYPE,
                                cp_base_id       IN igf_ap_fa_base_rec.base_id%TYPE,
				cp_aid           IN OUT NOCOPY NUMBER,
				cp_pell_tab      IN OUT NOCOPY pell_tab,
				cp_return_status IN OUT NOCOPY VARCHAR2,
				cp_message       IN OUT NOCOPY VARCHAR2,
				cp_called_from   IN VARCHAR2,
                                cp_pell_seq_id   OUT NOCOPY igf_gr_pell_setup_all.pell_seq_id%TYPE,
                                cp_pell_schedule_code OUT NOCOPY VARCHAR2
                                );


PROCEDURE pell_elig( cp_base_id       IN igf_ap_fa_base_rec.base_id%TYPE,
		     cp_return_status IN OUT NOCOPY VARCHAR2
                    );


PROCEDURE calc_term_pell(
                    cp_base_id            IN igf_ap_fa_base_rec.base_id%TYPE,
                    cp_attendance_type    IN  igf_ap_attend_map.attendance_type%TYPE,
                    cp_ld_cal_type        IN igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                    cp_term_aid           IN OUT NOCOPY NUMBER,
                    cp_return_status      IN OUT NOCOPY VARCHAR2,
                    cp_message            IN OUT NOCOPY VARCHAR2,
                    cp_called_from        IN VARCHAR2,
                    cp_pell_schedule_code OUT NOCOPY VARCHAR2
                    );

PROCEDURE calc_ft_max_pell(
                    cp_base_id          IN igf_ap_fa_base_rec.base_id%TYPE,
                    cp_cal_type         IN igf_ap_fa_base_rec.ci_cal_type%TYPE,
                    cp_sequence_number  IN igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                    cp_flag             IN VARCHAR2,
                    cp_aid              IN OUT NOCOPY NUMBER,
                    cp_ft_aid           IN OUT NOCOPY NUMBER,
                    cp_return_status    IN OUT NOCOPY VARCHAR2,
                    cp_message          IN OUT NOCOPY VARCHAR2
                    );

FUNCTION num_disb(
                  p_adplans_id          igf_aw_awd_dist_plans.adplans_id%TYPE,
                  p_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                  p_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                 ) RETURN NUMBER;
END igf_gr_pell_calc;

 

/
