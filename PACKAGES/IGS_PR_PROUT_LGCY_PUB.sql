--------------------------------------------------------
--  DDL for Package IGS_PR_PROUT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_PROUT_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPPR1S.pls 120.1 2006/01/17 03:54:01 ijeddy noship $ */
/*#
 * The Progression Outcome Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_PR_LGCY_SPO_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Progression Outcome
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
  --
  -- Start of comments
  --   API name        : igs_pr_prout_lgcy_pub
  --   Type            : Public
  --   Function        :
  --   Pre-reqs        : None
  --   Parameters      :
  --   IN              :
  --     p_api_version           IN NUMBER       Required
  --     p_init_msg_list         IN VARCHAR2     Optional Default FND_API.G_FALSE
  --     p_commit                IN VARCHAR2     Optional Default FND_API.G_FALSE
  --     p_validation_level      IN NUMBER       Optional Default FND_API.G_VALID_LEVEL_FULL
  --
  --   OUT             :
  --     x_return_status         OUT     VARCHAR2(1)
  --     x_msg_count             OUT     NUMBER
  --     x_msg_data              OUT     VARCHAR2(2000)
  --
  --   IN OUT          :
  --     p_lgcy_grd_rec          OUT     lgcy_grd_rec_type%TYPE
  --
  --   Version         : Initial version       1.0
  --
  --   Notes           : Import Progression Outcome information from Legacy System into OSS
  --
  -- End of comments
  --
  TYPE lgcy_prout_rec_type IS RECORD (
    person_number                  igs_pr_lgcy_spo_int.person_number%TYPE,
    program_cd                     igs_pr_lgcy_spo_int.program_cd%TYPE,
    prg_cal_alternate_code         igs_pr_lgcy_spo_int.prg_cal_alternate_code%TYPE,
    progression_outcome_type       igs_pr_lgcy_spo_int.progression_outcome_type%TYPE,
    duration                       igs_pr_lgcy_spo_int.duration%TYPE,
    duration_type                  igs_pr_lgcy_spo_int.duration_type%TYPE,
    decision_status                igs_pr_lgcy_spo_int.decision_status%TYPE,
    decision_dt                    igs_pr_lgcy_spo_int.decision_dt%TYPE,
    decision_org_unit_cd           igs_pr_lgcy_spo_int.decision_org_unit_cd%TYPE,
    show_cause_expiry_dt           igs_pr_lgcy_spo_int.show_cause_expiry_dt%TYPE,
    show_cause_dt                  igs_pr_lgcy_spo_int.show_cause_dt%TYPE,
    show_cause_outcome_dt          igs_pr_lgcy_spo_int.show_cause_outcome_dt%TYPE,
    show_cause_outcome_type        igs_pr_lgcy_spo_int.show_cause_outcome_type%TYPE,
    appeal_expiry_dt               igs_pr_lgcy_spo_int.appeal_expiry_dt%TYPE,
    appeal_dt                      igs_pr_lgcy_spo_int.appeal_dt%TYPE,
    appeal_outcome_dt              igs_pr_lgcy_spo_int.appeal_outcome_dt%TYPE,
    appeal_outcome_type            igs_pr_lgcy_spo_int.appeal_outcome_type%TYPE,
    encmb_program_group_cd         igs_pr_lgcy_spo_int.encmb_program_group_cd%TYPE,
    restricted_enrolment_cp        igs_pr_lgcy_spo_int.restricted_enrolment_cp%TYPE,
    restricted_attendance_type     igs_pr_lgcy_spo_int.restricted_attendance_type%TYPE,
    comments                       igs_pr_lgcy_spo_int.comments%TYPE,
    show_cause_comments            igs_pr_lgcy_spo_int.show_cause_comments%TYPE,
    appeal_comments                igs_pr_lgcy_spo_int.appeal_comments%TYPE,
    expiry_dt                      igs_pr_lgcy_spo_int.expiry_dt%TYPE,
    award_cd                       igs_pr_lgcy_spo_int.award_cd%TYPE,
    spo_program_cd                 igs_pr_lgcy_spo_int.spo_program_cd%TYPE,
    unit_cd                        igs_pr_lgcy_spo_int.unit_cd%TYPE,
    s_unit_type                    igs_pr_lgcy_spo_int.s_unit_type%TYPE,
    unit_set_cd                    igs_pr_lgcy_spo_int.unit_set_cd%TYPE,
    us_version_number              igs_pr_lgcy_spo_int.us_version_number%TYPE,
    --anilk, Bug# 3021236, adding fund_code
    fund_code                      igs_pr_lgcy_spo_int.fund_code%TYPE
  );
  --
/*#
 * The Progression Outcome Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_PR_LGCY_SPO_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @param p_lgcy_prout_rec Legacy Progression Outcome record type. Refer to IGS_PR_LGCY_SPO_INT for detail column descriptions.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Progression Outcome
 */
  PROCEDURE create_outcome (
    p_api_version                  IN     NUMBER,
    p_init_msg_list                IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                       IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level             IN     NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2,
    p_lgcy_prout_rec               IN OUT NOCOPY lgcy_prout_rec_type
  );
  --
END igs_pr_prout_lgcy_pub;

 

/
