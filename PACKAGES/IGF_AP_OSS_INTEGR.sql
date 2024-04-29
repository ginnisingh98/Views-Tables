--------------------------------------------------------
--  DDL for Package IGF_AP_OSS_INTEGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_OSS_INTEGR" AUTHID CURRENT_USER AS
/* $Header: IGFAP19S.pls 120.0 2005/06/01 14:41:58 appldev noship $ */

PROCEDURE get_pe_visa_type(p_person_id  IN  hz_parties.party_id%TYPE,
                           p_visa_type  OUT NOCOPY igs_pe_visa.visa_type%TYPE,
                           p_visa_desc  OUT NOCOPY fnd_lookup_values.meaning%TYPE,
                           p_multiple   OUT NOCOPY VARCHAR2);


PROCEDURE get_pe_active_holds(p_person_id    IN  hz_parties.party_id%TYPE,
                              p_encumb_type  OUT NOCOPY VARCHAR2,
                              p_encumb_desc  OUT NOCOPY VARCHAR2,
                              p_multiple     OUT NOCOPY VARCHAR2);


PROCEDURE get_pe_citizenship_stat(p_person_id        IN  hz_parties.party_id%TYPE,
                                  p_citizenship_stat OUT NOCOPY igs_lookups_view.lookup_code%TYPE,
                                  p_citizenship_desc OUT NOCOPY igs_lookups_view.meaning%TYPE);


PROCEDURE get_pe_mil_service_type(p_person_id        IN  hz_parties.party_id%TYPE,
                                  p_mil_service_type OUT NOCOPY igs_lookups_view.lookup_code%TYPE,
                                  p_mil_service_desc OUT NOCOPY igs_lookups_view.meaning%TYPE,
                                  p_multiple         OUT NOCOPY VARCHAR2);


PROCEDURE get_acad_cal_from_awd(p_awd_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                p_acad_cal_type OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                p_acad_seq_num  OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                                p_acad_alt_code OUT NOCOPY igs_ca_inst_all.alternate_code%TYPE);

PROCEDURE get_awd_cal_from_acad(p_acad_cal_type IN  igs_ca_inst_all.cal_type%TYPE,
                                p_acad_seq_num  IN  igs_ca_inst_all.sequence_number%TYPE,
                                p_awd_cal_type  OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num   OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                                p_awd_alt_code  OUT NOCOPY igs_ca_inst_all.alternate_code%TYPE);


--Made the p_adm_appl_number,p_course-cd,p_crv_version_number as IN OUT NOCOPY parameters From IN
--as per the FACCR001 DLD

PROCEDURE get_adm_appl_details( p_person_id                 IN       hz_parties.party_id%TYPE,
                                p_awd_cal_type              IN       igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num               IN       igs_ca_inst_all.sequence_number%TYPE,
                                p_ad_appl_row_id            OUT NOCOPY      ROWID,
                                p_ad_prog_appl_row_id       OUT NOCOPY      ROWID,
                                p_adm_appl_number           IN OUT NOCOPY   igs_ad_appl_all.admission_appl_number%TYPE,
                                p_course_cd                 IN OUT NOCOPY   igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                p_crv_version_number        IN OUT NOCOPY   igs_ad_ps_appl_inst_all.sequence_number%TYPE,
                                p_adm_offer_resp_stat       OUT NOCOPY      igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
                                p_adm_outcome_stat          OUT NOCOPY      igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
                                p_adm_appl_status           OUT NOCOPY      igs_ad_appl_all.adm_appl_status%TYPE,
                                p_multiple                  OUT NOCOPY      VARCHAR2   );


FUNCTION get_adm_appl_val(p_person_id    IN hz_parties.party_id%TYPE,
                          p_awd_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                          p_awd_seq_num  IN igs_ca_inst_all.sequence_number%TYPE)
RETURN ROWID;

FUNCTION get_adm_prog_appl_val(p_person_id    IN hz_parties.party_id%TYPE,
                               p_awd_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                               p_awd_seq_num  IN igs_ca_inst_all.sequence_number%TYPE)
RETURN ROWID;

PRAGMA RESTRICT_REFERENCES (get_pe_active_holds,     WNDS);
PRAGMA RESTRICT_REFERENCES (get_pe_visa_type,        WNDS);
PRAGMA RESTRICT_REFERENCES (get_pe_citizenship_stat, WNDS);
PRAGMA RESTRICT_REFERENCES (get_pe_mil_service_type, WNDS,WNPS,RNPS);
--PRAGMA RESTRICT_REFERENCES (get_acad_cal_from_awd,   WNDS,WNPS,RNPS);
--PRAGMA RESTRICT_REFERENCES (get_awd_cal_from_acad,   WNDS,WNPS,RNPS);
PRAGMA RESTRICT_REFERENCES (get_adm_appl_details,    WNDS,WNPS,RNPS);
PRAGMA RESTRICT_REFERENCES (get_adm_appl_val,        WNDS,WNPS,RNPS);
PRAGMA RESTRICT_REFERENCES (get_adm_prog_appl_val,   WNDS,WNPS,RNPS);

END igf_ap_oss_integr;

 

/
