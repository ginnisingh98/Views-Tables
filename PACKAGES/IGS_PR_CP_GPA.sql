--------------------------------------------------------
--  DDL for Package IGS_PR_CP_GPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_CP_GPA" AUTHID CURRENT_USER AS
/* $Header: IGSPR32S.pls 120.1 2005/09/15 03:19:53 appldev noship $ */
/*
  ||  Created By : prchandr
  ||  Created On : 24-NOV-2001
  ||  Purpose : Package Specification For Academic Statistics and GPA
  ||  Known limitations, enhancements or remarks :
  ||  (reverse chronological order - newest change first)
  ||  Change History :
  ||  Who      When        What
  ||  nalkumar 22-Apr-2004 Modified get_cp_stats, get_gpa_stats, get_sua_gpa, get_sua_cp and get_sua_all
  ||                       procedures and added p_use_released_grade parameter.
  ||                       This is to fix Bug# 3547126
  ||  jhanda   28-May-2003 Changed gpa , gpa_quality points ,
  ||                       gpa_credit_points procedure parameter types.
  ||  swaghmar 15-Sep-2005 Bug# 4491456 - Modified the signatures of get_all_stats_new(),
  ||				get_gpa_stats(), get_all_stats(), get_sua_gpa(),
  ||				get_sua_all()
*/

--
-- kdande; 23-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the PROCEDURE get_sua_all
--
PROCEDURE get_sua_all(
  p_person_id                 IN   igs_en_su_attempt.person_id%TYPE,
  p_course_cd                 IN   igs_en_su_attempt.course_cd%TYPE,
  p_unit_cd                   IN   igs_en_su_attempt.unit_cd%TYPE,
  p_unit_version_number       IN   igs_en_su_attempt.version_number%TYPE,
  p_teach_cal_type            IN   igs_en_su_attempt.cal_type%TYPE,
  p_teach_ci_sequence_number  IN   igs_en_su_attempt.ci_sequence_number%TYPE,
  p_stat_type                 IN   igs_pr_org_stat.stat_type%TYPE,
  p_system_stat               IN   VARCHAR2,
  p_earned_cp                 OUT NOCOPY  NUMBER,
  p_attempted_cp              OUT NOCOPY  NUMBER,
  p_gpa_value                 OUT NOCOPY  NUMBER,
  p_gpa_cp                    OUT NOCOPY  NUMBER,
  p_gpa_quality_points        OUT NOCOPY  NUMBER,
  p_init_msg_list             IN   VARCHAR2,
  p_return_status             OUT NOCOPY  VARCHAR2,
  p_msg_count                 OUT NOCOPY  NUMBER,
  p_msg_data                  OUT NOCOPY  VARCHAR2,
  p_uoo_id                    IN  NUMBER DEFAULT NULL,
  p_use_released_grade        IN  VARCHAR2 DEFAULT NULL);

--
-- kdande; 23-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION get_sua_cp
--
PROCEDURE get_sua_cp(
  p_person_id                IN  igs_en_stdnt_ps_att.person_id%TYPE,
  p_course_cd                IN  igs_en_stdnt_ps_att.course_cd%TYPE,
  p_unit_cd                  IN  igs_ps_unit_ver.unit_cd%TYPE,
  p_unit_version_number      IN  igs_ps_unit_ver.version_number%TYPE,
  p_teach_cal_type           IN  igs_ca_inst.cal_type%TYPE,
  p_teach_ci_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
  p_stat_type                IN  igs_pr_stat_type.stat_type%TYPE,
  p_system_stat              IN  VARCHAR2,
  p_earned_cp                OUT NOCOPY NUMBER,
  p_attempted_cp             OUT NOCOPY NUMBER,
  p_init_msg_list            IN  VARCHAR2 DEFAULT Fnd_Api.G_TRUE,
  p_return_status            OUT NOCOPY VARCHAR2,
  p_msg_count                OUT NOCOPY NUMBER,
  p_msg_data                 OUT NOCOPY VARCHAR2,
  p_uoo_id                   IN  NUMBER DEFAULT NULL,
  p_use_released_grade       IN  VARCHAR2 DEFAULT NULL);

--
-- kdande; 23-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION get_sua_gpa
--
PROCEDURE get_sua_gpa (
  p_person_id                IN   igs_en_stdnt_ps_att.person_id%TYPE,
  p_course_cd                IN   igs_en_stdnt_ps_att.course_cd%TYPE,
  p_unit_cd                  IN   igs_ps_unit_ver.unit_cd%TYPE,
  p_unit_version_number      IN   igs_ps_unit_ver.version_number%TYPE,
  p_teach_cal_type           IN   igs_ca_inst.cal_type%TYPE,
  p_teach_ci_sequence_number IN   igs_ca_inst.sequence_number%TYPE,
  p_stat_type                IN   igs_pr_stat_type.stat_type%TYPE,
  p_system_stat              IN   VARCHAR2,
  p_init_msg_list            IN   VARCHAR2 DEFAULT  FND_API.G_TRUE,
  p_gpa_value                OUT NOCOPY  NUMBER,
  p_gpa_cp                   OUT NOCOPY  NUMBER,
  p_gpa_quality_points       OUT NOCOPY  NUMBER,
  p_return_status            OUT NOCOPY  VARCHAR2,
  p_msg_count                OUT NOCOPY  NUMBER,
  p_msg_data                 OUT NOCOPY  VARCHAR2,
  p_uoo_id                   IN  NUMBER   DEFAULT NULL,
  p_use_released_grade       IN  VARCHAR2 DEFAULT NULL);


PROCEDURE get_all_stats(
  p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE ,
  p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE ,
  p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE ,
  p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE ,
  p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE ,
  p_system_stat             IN         VARCHAR2,
  p_cumulative_ind          IN         VARCHAR2,
  p_earned_cp               OUT NOCOPY NUMBER,
  p_attempted_cp            OUT NOCOPY NUMBER,
  p_gpa_value               OUT NOCOPY NUMBER,
  p_gpa_cp                  OUT NOCOPY NUMBER,
  p_gpa_quality_points      OUT NOCOPY NUMBER,
  p_init_msg_list           IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_return_status           OUT NOCOPY VARCHAR2,
  p_msg_count               OUT NOCOPY NUMBER,
  p_msg_data                OUT NOCOPY VARCHAR2,
  p_use_released_grade      IN         VARCHAR2 DEFAULT NULL);


PROCEDURE get_cp_stats(
  p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE,
  p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE,
  p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE,
  p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE,
  p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE,
  p_system_stat             IN         VARCHAR2,
  p_cumulative_ind          IN         VARCHAR2,
  p_earned_cp               OUT NOCOPY NUMBER,
  p_attempted_cp            OUT NOCOPY NUMBER,
  p_init_msg_list           IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_return_status           OUT NOCOPY VARCHAR2,
  p_msg_count               OUT NOCOPY NUMBER,
  p_msg_data                OUT NOCOPY VARCHAR2,
  p_use_released_grade      IN         VARCHAR2 DEFAULT NULL);


PROCEDURE get_gpa_stats(
  p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE,
  p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE,
  p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE,
  p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE,
  p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE,
  p_system_stat             IN         VARCHAR2,
  p_cumulative_ind          IN         VARCHAR2,
  p_gpa_value               OUT NOCOPY NUMBER,
  p_gpa_cp                  OUT NOCOPY NUMBER,
  p_gpa_quality_points      OUT NOCOPY NUMBER,
    p_init_msg_list         IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_return_status           OUT NOCOPY VARCHAR2,
  p_msg_count               OUT NOCOPY NUMBER,
  p_msg_data                OUT NOCOPY VARCHAR2,
  p_use_released_grade      IN         VARCHAR2 DEFAULT NULL);

--
-- jhanda; 1-Mar-2005; Bug# 3843525
-- Added get_all_stats_new procedure which stubs procedure get_all_stats
--

PROCEDURE get_all_stats_new(
  p_person_id               IN         igs_en_stdnt_ps_att.person_id%TYPE ,
  p_course_cd               IN         igs_en_stdnt_ps_att.course_cd%TYPE ,
  p_stat_type               IN         igs_pr_stat_type.stat_type%TYPE ,
  p_load_cal_type           IN         igs_ca_inst.cal_type%TYPE ,
  p_load_ci_sequence_number IN         igs_ca_inst.sequence_number%TYPE ,
  p_system_stat             IN         VARCHAR2,
  p_cumulative_ind          IN         VARCHAR2,
  p_earned_cp               OUT NOCOPY NUMBER,
  p_attempted_cp            OUT NOCOPY NUMBER,
  p_gpa_value               OUT NOCOPY NUMBER,
  p_gpa_cp                  OUT NOCOPY NUMBER,
  p_gpa_quality_points      OUT NOCOPY NUMBER,
  p_init_msg_list           IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_return_status           OUT NOCOPY VARCHAR2,
  p_msg_count               OUT NOCOPY NUMBER,
  p_msg_data                OUT NOCOPY VARCHAR2,
  p_use_released_grade      IN         VARCHAR2 DEFAULT NULL,
  p_enrolled_cp                 OUT NOCOPY igs_pr_stu_acad_stat.gpa_quality_points%TYPE);

 END igs_pr_cp_gpa;

 

/
