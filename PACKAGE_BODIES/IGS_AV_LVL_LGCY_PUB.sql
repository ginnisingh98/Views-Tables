--------------------------------------------------------
--  DDL for Package Body IGS_AV_LVL_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_LVL_LGCY_PUB" AS
/* $Header: IGSPAV1B.pls 120.8 2006/08/07 08:33:03 amanohar ship $ */
/**************************************************************************
Created By -
Purpose
History
Who             When              Why
Aiyer           03-jan-2003       The function validate_lvl_db_cons,
                                  create_adv_stnd_level have been modified
				  as per the bug #2732975.
****************************************************************************/


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_AV_LVL_LGCY_PUB';

PROCEDURE initialise ( p_lgcy_adstlvl_rec IN OUT NOCOPY lgcy_adstlvl_rec_type )
IS
BEGIN
        p_lgcy_adstlvl_rec.person_number              := NULL;
        p_lgcy_adstlvl_rec.program_cd                 := NULL;
        p_lgcy_adstlvl_rec.total_exmptn_approved      := NULL;
        p_lgcy_adstlvl_rec.total_exmptn_granted       := NULL;
        p_lgcy_adstlvl_rec.total_exmptn_perc_grntd    := NULL;
        p_lgcy_adstlvl_rec.exemption_institution_cd   := NULL;
        p_lgcy_adstlvl_rec.unit_level                 := NULL;
        p_lgcy_adstlvl_rec.prog_group_ind             := NULL;
        p_lgcy_adstlvl_rec.load_cal_alt_code          := NULL;
        p_lgcy_adstlvl_rec.institution_cd             := NULL;
        p_lgcy_adstlvl_rec.s_adv_stnd_granting_status := NULL;
        p_lgcy_adstlvl_rec.credit_points              := NULL;
        p_lgcy_adstlvl_rec.approved_dt                := NULL;
        p_lgcy_adstlvl_rec.authorising_person_number  := NULL;
        p_lgcy_adstlvl_rec.granted_dt                 := NULL;
        p_lgcy_adstlvl_rec.expiry_dt                  := NULL;
        p_lgcy_adstlvl_rec.cancelled_dt               := NULL;
        p_lgcy_adstlvl_rec.revoked_dt                 := NULL;
        p_lgcy_adstlvl_rec.comments                   := NULL;
        p_lgcy_adstlvl_rec.qual_exam_level            := NULL;
        p_lgcy_adstlvl_rec.qual_subject_code          := NULL;
        p_lgcy_adstlvl_rec.qual_year                  := NULL;
        p_lgcy_adstlvl_rec.qual_sitting               := NULL;
        p_lgcy_adstlvl_rec.qual_awarding_body         := NULL;
        p_lgcy_adstlvl_rec.approved_result            := NULL;
        p_lgcy_adstlvl_rec.prev_unit_cd               := NULL;
        p_lgcy_adstlvl_rec.prev_term                  := NULL;
        p_lgcy_adstlvl_rec.start_date                 := NULL;
        p_lgcy_adstlvl_rec.end_date                   := NULL;
        p_lgcy_adstlvl_rec.tst_admission_test_type    := NULL;
        p_lgcy_adstlvl_rec.tst_test_date              := NULL;
        p_lgcy_adstlvl_rec.test_segment_name          := NULL;
        p_lgcy_adstlvl_rec.basis_program_type         := NULL;
        p_lgcy_adstlvl_rec.basis_year                 := NULL;
        p_lgcy_adstlvl_rec.basis_completion_ind       := NULL;
	p_lgcy_adstlvl_rec.unit_level_mark            := NULL;

END initialise;

-- forward declaration of procedure/function used in this package

/*
  validate_parameters function checks all the mandatory parameters
  for the passed record type are not null
*/
FUNCTION validate_parameters
         (
           p_lgcy_adstlvl_rec   IN lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;

/*
  derive_level_data procedure derives advanced standing unit level data like: -
  1. Derive Person_id from person_number .
  2. Derive cal_type and sequence_number from load_cal_alt_code
  3. Set Unit_level parameter
  4. Derive the  authorizing_person_id from authorizing_person_number
  5. Derive Unit_details_id , tst_rslt_dtls_id and qual_dets_id
*/

PROCEDURE derive_level_data
         (
           p_lgcy_adstlvl_rec          IN          lgcy_adstlvl_rec_type,
           p_person_id                 OUT NOCOPY  igs_pe_person.person_id%type,
           p_s_adv_stnd_unit_level     OUT NOCOPY  igs_av_stnd_unit_lvl.s_adv_stnd_type%type,
           p_cal_type                  OUT NOCOPY  igs_ca_inst.cal_type%type,
           p_sequence_number           OUT NOCOPY  igs_ca_inst.sequence_number%type,
           p_auth_pers_id              OUT NOCOPY  igs_pe_person.person_id%type,
           p_unit_details_id           OUT NOCOPY  igs_ad_term_unitdtls.unit_details_id%type,
           p_tst_rslt_dtls_id          OUT NOCOPY  igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
           p_qual_dets_id              OUT NOCOPY  igs_uc_qual_dets.qual_dets_id%type,
           p_as_version_number         OUT NOCOPY  igs_en_stdnt_ps_att.version_number%type
         );

/*
  validate_adv_std_db_cons function performs all the data integrity validation
*/
FUNCTION validate_adv_std_db_cons
         (
           p_person_id          IN  igs_pe_person.person_id%type,
           p_version_number     IN  igs_ps_ver_all.version_number%type,
           p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;

/*
  validate_adv_stnd function validates all the business rules before
  inserting a record in the table IGS_AV_ADV_STANDING_ALL
*/
FUNCTION validate_adv_stnd
         (
           p_person_id          IN  igs_pe_person.person_id%type,
           p_version_number     IN  igs_ps_ver.version_number%type,
           p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;

/*
  validate_lvl_db_cons function performs all the data integrity validation
  before entering into the table  IGS_AV_STND_UNIT_LVL_ALL
*/
FUNCTION validate_lvl_db_cons
         (
           p_person_id              IN igs_pe_person.person_id%type,
           p_s_adv_stnd_unit_level  IN igs_ps_unit_level.unit_level%type,
           p_cal_type               IN igs_ca_inst.cal_type%type,
           p_seq_number             IN igs_ca_inst.sequence_number%type,
           p_auth_pers_id           IN igs_pe_person.person_id%type,
           p_unit_details_id        IN igs_ad_term_unitdtls.unit_details_id%type,
           p_tst_rslt_dtls_id       IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
           p_qual_dets_id           IN igs_uc_qual_dets.qual_dets_id%type,
           p_course_version         IN igs_ps_ver.version_number%type,
           p_lgcy_adstlvl_rec       IN lgcy_adstlvl_rec_type,
           p_av_stnd_unit_lvl_id   OUT NOCOPY igs_av_std_ulvlbasis_all.av_stnd_unit_lvl_id%type
         )
RETURN  BOOLEAN;

/*
  validate_level function performs all the business validations before
  inserting a record into the table  IGS_AV_STND_UNIT_LVL_ALL
*/
FUNCTION validate_level
         (
           p_person_id           IN igs_pe_person.person_id%type,
           p_unit_level          IN igs_ps_unit_level.unit_level%type,
           p_cal_type            IN igs_ca_inst.cal_type%type,
           p_seq_number          IN igs_ca_inst.sequence_number%type,
           p_auth_pers_id        IN igs_pe_person.person_id%type,
           p_unit_details_id     IN igs_ad_term_unitdtls.unit_details_id%type,
           p_tst_rslt_dtls_id    IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
           p_qual_dets_id        IN igs_uc_qual_dets.qual_dets_id%type,
           p_course_version      IN igs_ps_ver.version_number%type,
           p_lgcy_adstlvl_rec    IN lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;

/*
  create_post_lvl function performs all the Post Insert business
  validations on the table  IGS_AV_STND_UNIT_LVL_ALL
*/
FUNCTION create_post_lvl
         (
           p_person_id          IN  igs_pe_person.person_id%type,
           p_course_version     IN  igs_ps_ver.version_number%type,
           p_unit_details_id     IN igs_ad_term_unitdtls.unit_details_id%type,
           p_tst_rslt_dtls_id    IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
           p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;

/*
  validate_lvl_bas_db_cons function performs all the data integrity validation
  before inserting  into the table  IGS_AV_STD_ULVLBASIS_ALL
*/
FUNCTION validate_lvl_bas_db_cons
         (
           p_person_id           IN  igs_pe_person.person_id%type,
           p_av_stnd_unit_lvl_id IN  igs_av_std_ulvlbasis_all.av_stnd_unit_lvl_id%type,
           p_lgcy_adstlvl_rec    IN  lgcy_adstlvl_rec_type
         )
RETURN VARCHAR2;

/*
  validate_lvl_bas function performs all the business validation before
  inserting  into the table  IGS_AV_STD_ULVLBASIS_ALL
*/
FUNCTION validate_lvl_bas
         (
           p_course_version     IN  igs_ps_ver.version_number%type,
           p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
         )
RETURN BOOLEAN;



/*===================================================================+
 | PROCEDURE                                                         |
 |              create_adv_stnd_level                                |
 |                                                                   |
 | DESCRIPTION                                                       |
 |              Creates advanced standing unit level                 |
 |                                                                   |
 | SCOPE - PUBLIC                                                    |
 |                                                                   |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                           |
 |                                                                   |
 | ARGUMENTS  : IN:                                                  |
 |                    p_api_version                                  |
 |                    p_init_msg_list                                |
 |                    p_commit                                       |
 |                    p_lgcy_adstlvl_rec                             |
 |              OUT:                                                 |
 |                    x_return_status                                |
 |                    x_msg_count                                    |
 |                    x_msg_data                                     |
 |          IN/ OUT:                                                 |
 |                                                                   |
 | RETURNS    : NONE                                                 |
 |                                                                   |
 | NOTES                                                             |
 |                                                                   |
 | MODIFICATION HISTORY                                              |
 | smanglm   11-11-2002  Created                                     |
 | kdande    03-Jan-2003 Added check for s_adv_stnd_granting_status =|
 |                       'EXPIRED' and expiry_dt IS NULL             |
 |Aiyer      07-Jan-2002 Code modified as a part of the fix for      |
 |                        the bug #2732975.			     |
 |                        If l_av_stnd_unit_lvl_id is null then set a|
 |			  warning that Advanced Standing unit level  |
 |			  records already exists.                    |
 |								     |
 +===================================================================*/

  PROCEDURE create_adv_stnd_level
            (p_api_version                 IN NUMBER,
             p_init_msg_list               IN VARCHAR2,
             p_commit                      IN VARCHAR2,
             p_validation_level            IN VARCHAR2,
             p_lgcy_adstlvl_rec            IN OUT NOCOPY lgcy_adstlvl_rec_type,
             x_return_status               OUT NOCOPY VARCHAR2,
             x_msg_count                   OUT NOCOPY NUMBER,
             x_msg_data                    OUT NOCOPY VARCHAR2
            )
  IS
        l_api_name              CONSTANT VARCHAR2(30) := 'create_adv_stnd_level';
        l_api_version           CONSTANT  NUMBER       := 1.0;

        -- variables declared to fetch data from derive_level_data
        l_person_id                 igs_pe_person.person_id%type;
        l_s_adv_stnd_unit_level     igs_av_stnd_unit_lvl.s_adv_stnd_type%type;
        l_cal_type                  igs_ca_inst.cal_type%type;
        l_sequence_number           igs_ca_inst.sequence_number%type;
        l_auth_pers_id              igs_pe_person.person_id%type;
        l_unit_details_id           igs_ad_term_unitdtls.unit_details_id%type;
        l_tst_rslt_dtls_id          igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type;
        l_qual_dets_id              igs_uc_qual_dets.qual_dets_id%type;
        l_as_version_number         igs_en_stdnt_ps_att.version_number%type;

        -- variable declared to fetch data from validate_lvl_db_cons
        l_av_stnd_unit_lvl_id       igs_av_std_ulvlbasis_all.av_stnd_unit_lvl_id%type;

        l_check       VARCHAR2(1) := 'N';  -- check whether to insert into parent
        l_skip        VARCHAR2(1) := 'N';  -- check whether to to skip the steps
        l_return      VARCHAR2(1) ;

  BEGIN  -- main begin
  --Standard start of API savepoint
        SAVEPOINT create_adv_stnd_level;

  --Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

  --Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- main code logic begins
        -- ensure UPPER case
        p_lgcy_adstlvl_rec.basis_program_type          := UPPER(p_lgcy_adstlvl_rec.basis_program_type) ;
        p_lgcy_adstlvl_rec.program_cd                  := UPPER(p_lgcy_adstlvl_rec.program_cd)   ;
        p_lgcy_adstlvl_rec.exemption_institution_cd    := UPPER(p_lgcy_adstlvl_rec.exemption_institution_cd)  ;
        p_lgcy_adstlvl_rec.unit_level                  := UPPER(p_lgcy_adstlvl_rec.unit_level)         ;
        p_lgcy_adstlvl_rec.prog_group_ind              := UPPER(p_lgcy_adstlvl_rec.prog_group_ind)     ;
        p_lgcy_adstlvl_rec.s_adv_stnd_granting_status  := UPPER(p_lgcy_adstlvl_rec.s_adv_stnd_granting_status);
        -- call validate_parameters
        IF validate_parameters(p_lgcy_adstlvl_rec => p_lgcy_adstlvl_rec) THEN
                   -- call derive_level_data
                   derive_level_data (
                                        p_lgcy_adstlvl_rec          => p_lgcy_adstlvl_rec     ,
                                        p_person_id                 => l_person_id            ,
                                        p_s_adv_stnd_unit_level     => l_s_adv_stnd_unit_level,
                                        p_cal_type                  => l_cal_type             ,
                                        p_sequence_number           => l_sequence_number      ,
                                        p_auth_pers_id              => l_auth_pers_id         ,
                                        p_unit_details_id           => l_unit_details_id      ,
                                        p_tst_rslt_dtls_id          => l_tst_rslt_dtls_id     ,
                                        p_qual_dets_id              => l_qual_dets_id         ,
                                        p_as_version_number         => l_as_version_number
                                     );
                   -- call validate_adv_std_db_cons
                   IF validate_adv_std_db_cons
                      (
                        p_person_id          => l_person_id,
                        p_version_number     => l_as_version_number,
                        p_lgcy_adstlvl_rec   => p_lgcy_adstlvl_rec
                      ) THEN
                                -- call validate_adv_stnd
                                IF validate_adv_stnd
                                   (
                                     p_person_id          => l_person_id,
                                     p_version_number     => l_as_version_number,
                                     p_lgcy_adstlvl_rec   => p_lgcy_adstlvl_rec
                                   ) THEN
                                           /*
                                                Validate that  the current record is already present in the
                                                tables IGS_AV_ADV_STANDING_ALL and IGS_AV_STND_UNIT_LVL_ALL
                                           */
                                              /*
                                                  Check that the Primary Key for the table
                                                  IGS_AV_ADV_STANDING_ALL does not exists
                                              */
                                               IF IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION
                                                            (
                                                               x_person_id                => l_person_id,
                                                               x_course_cd                => p_lgcy_adstlvl_rec.program_cd,
                                                               x_version_number           => l_as_version_number,
                                                               x_exemption_institution_cd => p_lgcy_adstlvl_rec.exemption_institution_cd
                                                             ) THEN
                                                   /*
                                                       Check that the unique key combination for the table
                                                       IGS_AV_STND_UNIT_LVL_ALL does not already exist
                                                   */
                                                   IF IGS_AV_STND_UNIT_LVL_PKG.GET_UK_FOR_VALIDATION
                                                                 (
                                                                    x_person_id         => l_person_id,
                                                                    x_exemption_institution_cd    => p_lgcy_adstlvl_rec.exemption_institution_cd,
                                                                    x_unit_details_id   => l_unit_details_id,
                                                                    x_tst_rslt_dtls_id  => l_tst_rslt_dtls_id,
                                                                    x_unit_level        => p_lgcy_adstlvl_rec.unit_level,
                                                                    x_as_course_cd      => p_lgcy_adstlvl_rec.program_cd,
                                                                    x_as_version_number => l_as_version_number,
                                                                    x_qual_dets_id      => l_qual_dets_id,
                                                                    X_S_ADV_STND_TYPE   => l_s_adv_stnd_unit_level,
                                                                    X_CRS_GROUP_IND     => NVL(UPPER(p_lgcy_adstlvl_rec.prog_group_ind),'N')
                                                                 )
                                                    THEN

						      /*
                                                         This code has been added as a part of the fix for the bug #2732975.
							 If l_av_stnd_unit_lvl_id is null then set a warning that Advanced Standing
							 unit level records already exists.
						      */

                                                      IF l_av_stnd_unit_lvl_id IS NULL THEN
                                                        FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADV_STND_ALREADY_EXISTS');
                                                        FND_MSG_PUB.ADD;
                                                        x_return_status := 'W';
                                                        -- skip to end
                                                        l_skip := 'Y';
                                                      ELSE
                                                        l_return := validate_lvl_bas_db_cons
                                                                                (
                                                                                   p_person_id           => l_person_id,
                                                                                   p_av_stnd_unit_lvl_id => l_av_stnd_unit_lvl_id,
                                                                                   p_lgcy_adstlvl_rec    => p_lgcy_adstlvl_rec
                                                                                );
                                                         IF l_return = 'S' THEN
                                                           IF validate_lvl_bas
                                                                          (
                                                                            p_course_version   => l_as_version_number,
                                                                            p_lgcy_adstlvl_rec => p_lgcy_adstlvl_rec
                                                                          )
                                                           THEN
                                                             /*
                                                                   insert into IGS_AV_STD_ULVLBASIS_ALL
                                                             */
                                                              INSERT INTO IGS_AV_STD_ULVLBASIS_ALL (
                                                                AV_STND_UNIT_LVL_ID,
                                                                BASIS_COURSE_TYPE,
                                                                BASIS_YEAR,
                                                                BASIS_COMPLETION_IND,
                                                                CREATION_DATE,
                                                                CREATED_BY,
                                                                LAST_UPDATE_DATE,
                                                                LAST_UPDATED_BY,
                                                                LAST_UPDATE_LOGIN,
                                                                ORG_ID
                                                                )
								VALUES (
                                                                l_av_stnd_unit_lvl_id,
                                                                UPPER(p_lgcy_adstlvl_rec.basis_program_type),
                                                                p_lgcy_adstlvl_rec.basis_year,
                                                                p_lgcy_adstlvl_rec.basis_completion_ind,
                                                                SYSDATE,
                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                SYSDATE,
                                                                NVL(FND_GLOBAL.USER_ID,-1),
                                                                NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                igs_ge_gen_003.get_org_id
                                                                );

                                                             ELSE  -- validate_lvl_bas
                                                               x_return_status := l_return; --it can be either E or W
                                                             END IF; -- validate_lvl_bas
                                                           ELSE -- l_return
                                                              x_return_status := FND_API.G_RET_STS_ERROR;
                                                           END IF;
                                                           -- skip to end
                                                           l_skip := 'Y';
                                                        END IF; -- End of l_av_stnd_unit_lvl_id is not null
                                                     ELSE
                                                       l_check := 'Y';
                                                     END IF; -- IGS_AV_STND_UNIT_LVL_PKG.GET_UK_FOR_VALIDATION
                                               ELSE --   IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION
                                                   l_check := 'N';
                                               END IF; --   IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION

                                               IF l_skip = 'N' THEN
                                                       IF l_check = 'N' THEN
                                                          -- insert into IGS_AV_ADV_STANDING_ALL
                                                          INSERT INTO IGS_AV_ADV_STANDING_ALL (
                                                            PERSON_ID,
                                                            COURSE_CD,
                                                            VERSION_NUMBER,
                                                            TOTAL_EXMPTN_APPROVED,
                                                            TOTAL_EXMPTN_GRANTED,
                                                            TOTAL_EXMPTN_PERC_GRNTD,
                                                            EXEMPTION_INSTITUTION_CD,
                                                            CREATION_DATE,
                                                            CREATED_BY,
                                                            LAST_UPDATE_DATE,
                                                            LAST_UPDATED_BY,
                                                            LAST_UPDATE_LOGIN,
                                                            ORG_ID
                                                          ) VALUES (
                                                            l_person_id,
                                                            UPPER(p_lgcy_adstlvl_rec.program_cd),
                                                            l_as_version_number,
                                                            p_lgcy_adstlvl_rec.total_exmptn_approved,
                                                            p_lgcy_adstlvl_rec.total_exmptn_granted,
                                                            p_lgcy_adstlvl_rec.total_exmptn_perc_grntd,
                                                            UPPER(p_lgcy_adstlvl_rec.exemption_institution_cd),
                                                            SYSDATE,
                                                            NVL(FND_GLOBAL.USER_ID,-1),
                                                            SYSDATE,
                                                            NVL(FND_GLOBAL.USER_ID,-1),
                                                            NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                            igs_ge_gen_003.get_org_id
                                                          );
                                                       END IF; --l_check = 'Y'
                                                       -- step 8 of TD
                                                       /*
                                                          call to VALIDATE_LVL_DB_CONS
                                                       */
                                                       IF validate_lvl_db_cons
                                                              (
                                                                 p_person_id             => l_person_id,
                                                                 p_s_adv_stnd_unit_level => p_lgcy_adstlvl_rec.unit_level,
                                                                 p_cal_type              => l_cal_type,
                                                                 p_seq_number            => l_sequence_number,
                                                                 p_auth_pers_id          => l_auth_pers_id,
                                                                 p_unit_details_id       => l_unit_details_id,
                                                                 p_tst_rslt_dtls_id      => l_tst_rslt_dtls_id,
                                                                 p_qual_dets_id          => l_qual_dets_id,
                                                                 p_course_version        => l_as_version_number,
                                                                 p_lgcy_adstlvl_rec      => p_lgcy_adstlvl_rec,
                                                                 p_av_stnd_unit_lvl_id   => l_av_stnd_unit_lvl_id
                                                              ) THEN
                                                              IF validate_level
                                                                      (
                                                                         p_person_id        => l_person_id,
                                                                         p_unit_level       => p_lgcy_adstlvl_rec.unit_level,
                                                                         p_cal_type         => l_cal_type,
                                                                         p_seq_number       => l_sequence_number,
                                                                         p_auth_pers_id     => l_auth_pers_id,
                                                                         p_unit_details_id  => l_unit_details_id,
                                                                         p_tst_rslt_dtls_id => l_tst_rslt_dtls_id,
                                                                         p_qual_dets_id     => l_qual_dets_id,
                                                                         p_course_version   => l_as_version_number,
                                                                         p_lgcy_adstlvl_rec => p_lgcy_adstlvl_rec
                                                                      ) THEN
                                                                  /*
                                                                     insert into IGS_AV_STND_UNIT_LVL_ALL
                                                                  */
                                                                  INSERT INTO IGS_AV_STND_UNIT_LVL_ALL (
                                                                    PERSON_ID,
                                                                    AS_COURSE_CD,
                                                                    AS_VERSION_NUMBER,
                                                                    S_ADV_STND_TYPE,
                                                                    UNIT_LEVEL,
                                                                    CRS_GROUP_IND,
                                                                    EXEMPTION_INSTITUTION_CD,
                                                                    S_ADV_STND_GRANTING_STATUS,
                                                                    CREDIT_POINTS,
                                                                    APPROVED_DT,
                                                                    AUTHORISING_PERSON_ID,
                                                                    GRANTED_DT,
                                                                    EXPIRY_DT,
                                                                    CANCELLED_DT,
                                                                    REVOKED_DT,
                                                                    COMMENTS,
                                                                    AV_STND_UNIT_LVL_ID,
                                                                    CAL_TYPE,
                                                                    CI_SEQUENCE_NUMBER,
                                                                    INSTITUTION_CD,
                                                                    UNIT_DETAILS_ID,
                                                                    TST_RSLT_DTLS_ID,
                                                                    CREATION_DATE,
                                                                    CREATED_BY,
                                                                    LAST_UPDATE_DATE,
                                                                    LAST_UPDATED_BY,
                                                                    LAST_UPDATE_LOGIN,
                                                                    REQUEST_ID,
                                                                    PROGRAM_ID,
                                                                    PROGRAM_APPLICATION_ID,
                                                                    PROGRAM_UPDATE_DATE,
                                                                    ORG_ID,
                                                                    DEG_AUD_DETAIL_ID,
                                                                    QUAL_DETS_ID,
								    UNIT_LEVEL_MARK
                                                                  ) VALUES (
                                                                    l_person_id,
                                                                    UPPER(p_lgcy_adstlvl_rec.program_cd),
                                                                    l_as_version_number,
                                                                    l_s_adv_stnd_unit_level,
                                                                    UPPER(p_lgcy_adstlvl_rec.unit_level),
                                                                    NVL(UPPER(p_lgcy_adstlvl_rec.prog_group_ind),'N'),
                                                                    UPPER(p_lgcy_adstlvl_rec.exemption_institution_cd),
                                                                    UPPER(p_lgcy_adstlvl_rec.s_adv_stnd_granting_status),
                                                                    p_lgcy_adstlvl_rec.credit_points,
                                                                    p_lgcy_adstlvl_rec.approved_dt,
                                                                    l_auth_pers_id,
                                                                    p_lgcy_adstlvl_rec.granted_dt,
                                                                    p_lgcy_adstlvl_rec.expiry_dt,
                                                                    p_lgcy_adstlvl_rec.cancelled_dt,
                                                                    p_lgcy_adstlvl_rec.revoked_dt,
                                                                    p_lgcy_adstlvl_rec.comments,
                                                                    l_av_stnd_unit_lvl_id,
                                                                    l_cal_type,
                                                                    l_sequence_number,
                                                                    p_lgcy_adstlvl_rec.institution_cd,
                                                                    l_unit_details_id,
                                                                    l_tst_rslt_dtls_id,
                                                                    SYSDATE,
                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                    SYSDATE,
                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                    NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                    DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
                                                                    DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
                                                                    DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
                                                                    DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                                                                    igs_ge_gen_003.get_org_id,
                                                                    NULL, -- aiyer NEW_REFERENCES.DEG_AUD_DETAIL_ID,
                                                                    l_qual_dets_id,
								    p_lgcy_adstlvl_rec.UNIT_LEVEL_MARK
                                                                  );

                                                                  /*
                                                                     post insert validation create_post_lvl
                                                                  */
                                                                  IF create_post_lvl
                                                                       (
                                                                          p_person_id         => l_person_id,
                                                                          p_course_version    => l_as_version_number,
                                                                          p_unit_details_id   => l_unit_details_id,
                                                                          p_tst_rslt_dtls_id  => l_tst_rslt_dtls_id,
                                                                          p_lgcy_adstlvl_rec  => p_lgcy_adstlvl_rec
                                                                       ) THEN
                                                                       l_return := validate_lvl_bas_db_cons
                                                                                          (
                                                                                             p_person_id           => l_person_id,
                                                                                             p_av_stnd_unit_lvl_id => l_av_stnd_unit_lvl_id,
                                                                                             p_lgcy_adstlvl_rec    => p_lgcy_adstlvl_rec
                                                                                          );
                                                                       IF l_return = 'S' THEN
                                                                          IF validate_lvl_bas
                                                                                  (
                                                                                    p_course_version   => l_as_version_number,
                                                                                    p_lgcy_adstlvl_rec => p_lgcy_adstlvl_rec
                                                                                  ) THEN
                                                                              /*
                                                                                 insert into IGS_AV_STD_ULVLBASIS_ALL
                                                                              */
                                                                                  INSERT INTO IGS_AV_STD_ULVLBASIS_ALL (
                                                                                    AV_STND_UNIT_LVL_ID,
                                                                                    BASIS_COURSE_TYPE,
                                                                                    BASIS_YEAR,
                                                                                    BASIS_COMPLETION_IND,
                                                                                    CREATION_DATE,
                                                                                    CREATED_BY,
                                                                                    LAST_UPDATE_DATE,
                                                                                    LAST_UPDATED_BY,
                                                                                    LAST_UPDATE_LOGIN,
                                                                                    ORG_ID
                                                                                  ) VALUES (
                                                                                    l_av_stnd_unit_lvl_id,
                                                                                    UPPER(p_lgcy_adstlvl_rec.basis_program_type),
                                                                                    p_lgcy_adstlvl_rec.basis_year,
                                                                                    p_lgcy_adstlvl_rec.basis_completion_ind,
                                                                                    SYSDATE,
                                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                                    SYSDATE,
                                                                                    NVL(FND_GLOBAL.USER_ID,-1),
                                                                                    NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                                    igs_ge_gen_003.get_org_id
                                                                                  );
                                                                          ELSE  -- validate_lvl_bas
                                                                              x_return_status := l_return; --it can be either E or W
                                                                          END IF; -- validate_lvl_bas
                                                                       ELSE -- l_return
                                                                           x_return_status := FND_API.G_RET_STS_ERROR;
                                                                       END IF;
                                                                  ELSE --create_post_lvl
                                                                       x_return_status := FND_API.G_RET_STS_ERROR;
                                                                  END IF; --create_post_lvl
                                                              ELSE -- validate level
                                                                  x_return_status := FND_API.G_RET_STS_ERROR;
                                                              END IF; -- validate level
                                                       ELSE -- VALIDATE_LVL_DB_CONS
                                                           x_return_status := FND_API.G_RET_STS_ERROR;
                                                       END IF; -- VALIDATE_LVL_DB_CONS
                                               END IF; -- l_skip
                                ELSE -- validate_adv_stnd
                                     x_return_status := FND_API.G_RET_STS_ERROR;
                                END IF; --validate_adv_stnd
                   ELSE -- validate_adv_std_db_cons
                        x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF; -- validate_adv_std_db_cons
        ELSE  -- validate_parameters(p_lgcy_adstlvl_rec)
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF; -- validate_parameters(p_lgcy_adstlvl_rec)

  --rollback if the x_return_status is set to E (FND_API.G_RET_STS_ERROR) or W
        IF x_return_status IN (FND_API.G_RET_STS_ERROR,'W','E') THEN
           ROLLBACK TO create_adv_stnd_level;
        END IF;

  --Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                commit;
        END IF;

  --Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_adv_stnd_level;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_adv_stnd_level;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO create_adv_stnd_level;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_adv_stnd_level;


  FUNCTION validate_parameters
           (
             p_lgcy_adstlvl_rec   IN lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_parameters function checks all the mandatory
            parameters for the passed record type are not null
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  shimitta      2005/11/9      BUG#4723892 :added a check for unit_level_mark
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;

     IF p_lgcy_adstlvl_rec.unit_level_mark < 0
        OR  p_lgcy_adstlvl_rec.unit_level_mark > 100 THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_INV_UNT_LVL_MARK');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF; -- shimitta
     IF p_lgcy_adstlvl_rec.person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.total_exmptn_approved IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_TOT_EXMPT_APPR_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.total_exmptn_granted IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_TOT_EXMPT_GRNT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.total_exmptn_perc_grntd IS NULL OR
        p_lgcy_adstlvl_rec.total_exmptn_perc_grntd < 0 OR
        p_lgcy_adstlvl_rec.total_exmptn_perc_grntd > 100 THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_TOT_EXT_PER_GRNT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.exemption_institution_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLVL_EX_INS_CD_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.unit_level IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLVL_UNIT_LVL_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLVL_GRNT_STAT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.credit_points IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLVL_CRD_PNTS_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.approved_dt IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLVL_APPR_DT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_adstlvl_rec.authorising_person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLV_AUTH_PERNUM_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
        Validate that the record parameter qual_exam_level if NOT NULL then all
        the releavnt should also be not null
     */
     IF p_lgcy_adstlvl_rec.qual_exam_level IS NOT NULL THEN
             IF p_lgcy_adstlvl_rec.qual_subject_code IS NULL OR
                p_lgcy_adstlvl_rec.qual_year IS NULL OR
                p_lgcy_adstlvl_rec.qual_sitting IS NULL OR
                p_lgcy_adstlvl_rec.qual_awarding_body IS NULL OR
                p_lgcy_adstlvl_rec.approved_result IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_ADLV_QUL_DET_NOT_NULL');
                FND_MSG_PUB.ADD;
                x_return_status := FALSE;
             END IF;
     END IF;
     /*
        Validate that the record parameter prev_unit_cd if NOT NULL then the
        field prev_term should also be not null
     */
     IF p_lgcy_adstlvl_rec.prev_unit_cd IS NOT NULL THEN
             IF p_lgcy_adstlvl_rec.prev_term IS NULL OR
                p_lgcy_adstlvl_rec.start_date IS NULL OR
                p_lgcy_adstlvl_rec.end_date IS NULL OR
                p_lgcy_adstlvl_rec.institution_cd IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_PREV_UNT_DET_NOT_NULL');
                FND_MSG_PUB.ADD;
                x_return_status := FALSE;
             END IF;
     END IF;
     /*
        Validate that the record parameter TST_ADMISSION_TEST_TYPE if NOT NULL
        then the fields TST_TEST_DATE and TEST_SEGMENT_NAME should also be not null
     */
     IF p_lgcy_adstlvl_rec.tst_admission_test_type IS NOT NULL THEN
             IF p_lgcy_adstlvl_rec.tst_test_date IS NULL OR
                p_lgcy_adstlvl_rec.test_segment_name IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_TST_ADM_DET_NOT_NULL');
                FND_MSG_PUB.ADD;
                x_return_status := FALSE;
             END IF;
     END IF;
     /*
        Validate that if s_adv_stnd_granting_status is granted then granting date cannot be not null.
        if s_adv_stnd_granting_status is cancelled then cancelled date cannot be not null.
        if s_adv_stnd_granting_status is revoked then revoked date cannot be not null.
     */
     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'GRANTED' AND
        p_lgcy_adstlvl_rec.granted_dt IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_GRANTDT_NOT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'CANCELLED' AND
        p_lgcy_adstlvl_rec.cancelled_dt IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_CANCDT_NOT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'REVOKED' AND
        p_lgcy_adstlvl_rec.revoked_dt IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_REVDT_NOT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'EXPIRED' AND
        p_lgcy_adstlvl_rec.expiry_dt IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AV_STUNT_EXPDT_TOBE_SET');
       FND_MSG_PUB.ADD;
       x_return_status := FALSE;
     END IF;

     /*
        validate that when advanced standing granting status if granted -> revoked and cancelled  dates are null
        when advanced standing granting status if revoked then granted and cancelled  dates are null
        when advanced standing granting status if cancelled then revoked and granted  dates are null
     */
     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'GRANTED' AND
          (p_lgcy_adstlvl_rec.revoked_dt IS NOT NULL OR
             p_lgcy_adstlvl_rec.cancelled_dt IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'CANCELLED' AND
          (p_lgcy_adstlvl_rec.revoked_dt    IS NOT NULL OR
             p_lgcy_adstlvl_rec.granted_dt    IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status = 'REVOKED' AND
          (p_lgcy_adstlvl_rec.granted_dt    IS NOT NULL OR
             p_lgcy_adstlvl_rec.cancelled_dt    IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CORR_DT_STATUS');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     /*
        return the value of x_return_status
     */
     return x_return_status;
  END validate_parameters;


  PROCEDURE derive_level_data
           (
             p_lgcy_adstlvl_rec          IN          lgcy_adstlvl_rec_type,
             p_person_id                 OUT NOCOPY  igs_pe_person.person_id%type,
             p_s_adv_stnd_unit_level     OUT NOCOPY  igs_av_stnd_unit_lvl.s_adv_stnd_type%type,
             p_cal_type                  OUT NOCOPY  igs_ca_inst.cal_type%type,
             p_sequence_number           OUT NOCOPY  igs_ca_inst.sequence_number%type,
             p_auth_pers_id              OUT NOCOPY  igs_pe_person.person_id%type,
             p_unit_details_id           OUT NOCOPY  igs_ad_term_unitdtls.unit_details_id%type,
             p_tst_rslt_dtls_id          OUT NOCOPY  igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
             p_qual_dets_id              OUT NOCOPY  igs_uc_qual_dets.qual_dets_id%type,
             p_as_version_number         OUT NOCOPY  igs_en_stdnt_ps_att.version_number%type
           )
   IS
   /*****************************************************************************************************************
   Created By : smanglm
   Date Created on : 2002/11/13
   Purpose :
            derive_level_data procedure derives advanced standing unit level data like: -
            1. Derive Person_id from person_number .
            2. Derive cal_type and sequence_number from load_cal_alt_code
            3. Set Unit_level parameter
            4. Derive the  authorizing_person_id from authorizing_person_number
            5. Derive Unit_details_id , tst_rslt_dtls_id and qual_dets_id
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
   Aiyer          03-jan-2003     This procedure has been modified as a part of the fix for
                                  the bug #2732975
                                  Made the derivation of Qualification detail ID , Unit details ID ,
                                  Test result Details ID conditional based on whether its corresponding fields have a
                                  value specified for it.
   ********************************************************************************************************************/
     x_return_status BOOLEAN;
   BEGIN
     x_return_status := TRUE;
     p_s_adv_stnd_unit_level := 'LEVEL';
     /*
        get person_id
     */
     p_person_id := IGS_GE_GEN_003.GET_PERSON_ID(p_lgcy_adstlvl_rec.person_number);
     IF p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
        get cal_type and sequence_number
     */
     DECLARE
        l_start_dt       igs_ca_inst.start_dt%TYPE;
        l_end_dt         igs_ca_inst.end_dt%TYPE;
        l_return_status  VARCHAR2(2000);
     BEGIN
       IGS_GE_GEN_003.GET_CALENDAR_INSTANCE
                      (
                        P_ALTERNATE_CD       => p_lgcy_adstlvl_rec.load_cal_alt_code,
                        P_S_CAL_CATEGORY     => NULL,
                        P_CAL_TYPE           => p_cal_type,
                        P_CI_SEQUENCE_NUMBER => p_sequence_number,
                        P_START_DT           => l_start_dt,
                        P_END_DT             => l_end_dt,
                        P_RETURN_STATUS      => l_return_status
                      );
       IF p_cal_type IS NULL THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;
     /*
        derive p_authorizing_person_id
     */
     p_auth_pers_id := IGS_GE_GEN_003.GET_PERSON_ID(p_lgcy_adstlvl_rec.authorising_person_number);

     /*
        derive p_qual_dets_id
        Code modified for the bug #2732975.
        Added the following If clauses before deriving the value for qual_dets_id
   */

      IF p_lgcy_adstlvl_rec.qual_exam_level  IS NOT NULL THEN

       DECLARE
          -- cursor to get qual_dets_id
          CURSOR c_qual_dets_id (cp_person_id        igs_uc_qual_dets.person_id%TYPE,
                                 cp_exam_level       igs_uc_qual_dets.exam_level%TYPE,
                                 cp_subject_code     igs_uc_qual_dets.subject_code%TYPE,
                                 cp_year             igs_uc_qual_dets.year%TYPE,
                                 cp_sitting          igs_uc_qual_dets.sitting%TYPE,
                                 cp_awarding_body    igs_uc_qual_dets.awarding_body%TYPE,
                                 cp_approved_result  igs_uc_qual_dets.approved_result%TYPE ) IS
                 SELECT qual_dets_id
                 FROM   igs_uc_qual_dets
                 WHERE  person_id       = cp_person_id
                 AND    exam_level      = cp_exam_level
                 AND    subject_code    = cp_subject_code
                 AND    year            = cp_year
                 AND    sitting         = cp_sitting
                 AND    awarding_body   = cp_awarding_body
                 AND    approved_result = cp_approved_result;
       BEGIN
         OPEN  c_qual_dets_id (p_person_id,
                                p_lgcy_adstlvl_rec.qual_exam_level,
                                p_lgcy_adstlvl_rec.qual_subject_code,
                                p_lgcy_adstlvl_rec.qual_year,
                                p_lgcy_adstlvl_rec.qual_sitting,
                                p_lgcy_adstlvl_rec.qual_awarding_body,
                                p_lgcy_adstlvl_rec.approved_result);
          FETCH c_qual_dets_id INTO p_qual_dets_id;

          IF c_qual_dets_id%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_NOPREV_EDU_QUAL_EXISTS');
            FND_MSG_PUB.ADD;
            x_return_status := FALSE;
          END IF;
         CLOSE c_qual_dets_id;
     END;
   END IF;

     /*
        derive p_unit_details_id
     */
   /*
     Code modified for the bug #2732975.
     Added the following IF clauses before deriving the value for unit details ID
   */
   IF p_lgcy_adstlvl_rec.prev_unit_cd IS NOT NULL THEN
     DECLARE
        CURSOR c_unit_details_id (cp_unit            igs_ad_term_unitdtls.unit%TYPE,
                                  cp_prev_term       igs_av_lgcy_lvl_int.prev_term%TYPE,
                                  cp_start_date      igs_av_lgcy_lvl_int.start_date%TYPE,
                                  cp_end_date        igs_av_lgcy_lvl_int.end_date%TYPE,
                                  cp_person_id       igs_pe_person.person_id%TYPE,
                                  cp_inst_cd         igs_av_acad_history_v.institution_code%TYPE) IS
               SELECT  ahv.unit_details_id
               FROM    igs_av_acad_history_v ahv,
                       igs_ad_term_details   td
               WHERE   ahv.term_details_id = td.term_details_id
               AND     ahv.term=td.term
               AND     td.term = cp_prev_term
               AND     td.start_date = cp_start_date
               AND     td.end_date = cp_end_date
               AND     ahv.unit = cp_unit
               AND     ahv.person_id = cp_person_id
               AND     ahv.institution_code = cp_inst_cd;

        l_count  NUMBER := 0;
     BEGIN
        OPEN  c_unit_details_id (p_lgcy_adstlvl_rec.prev_unit_cd,
                                 p_lgcy_adstlvl_rec.prev_term,
                                 p_lgcy_adstlvl_rec.start_date,
                                 p_lgcy_adstlvl_rec.end_date,
                                 p_person_id,
                                 p_lgcy_adstlvl_rec.institution_cd);
        LOOP
           FETCH c_unit_details_id INTO p_unit_details_id;
           EXIT WHEN c_unit_details_id%NOTFOUND;
           l_count := c_unit_details_id%ROWCOUNT;
        END LOOP;
        CLOSE c_unit_details_id;
        -- set p_unit_details_id in case no data or too many rows
        IF l_count = 0 OR l_count >=2 THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_AV_TERM_UNTDTLS_NOT_EXISTS');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
        END IF;
     END;
   END IF;
    /*
        Derive p_tst_rslt_dtls_id
        Code modified for the bug #2732975.
        Added the following If clauses before deriving the value for tst_rslt_dtls_id
   */

     IF p_lgcy_adstlvl_rec.tst_admission_test_type IS NOT NULL THEN
       DECLARE
         CURSOR c_tst_rslt_dtls_id (cp_admission_test_type  igs_ad_test_results.admission_test_type%TYPE,
                                    cp_test_date            igs_ad_test_results.test_date%TYPE,
                                    cp_test_segment_name    igs_ad_test_segments.test_segment_name%TYPE,
                                    cp_person_id            igs_ad_test_results.person_id%TYPE
                                   ) IS
                 SELECT  b.tst_rslt_dtls_id
                 FROM    igs_ad_test_results a,
                         igs_ad_tst_rslt_dtls b,
                         igs_ad_test_segments c
                 WHERE   a.test_results_id = b.test_results_id
                 AND     b.test_segment_id = c.test_segment_id
                 AND     c.admission_test_type = cp_admission_test_type
                 AND     a.admission_test_type = cp_admission_test_type
                 AND     a.test_date           = cp_test_date
                 AND     c.test_segment_name   = cp_test_segment_name
                 AND     a.person_id           = cp_person_id;
          l_count  NUMBER := 0;
       BEGIN
          OPEN  c_tst_rslt_dtls_id ( p_lgcy_adstlvl_rec.tst_admission_test_type,
                                     p_lgcy_adstlvl_rec.tst_test_date,
                                     p_lgcy_adstlvl_rec.test_segment_name,
                                     p_person_id
                                    );
          LOOP
             FETCH c_tst_rslt_dtls_id INTO p_tst_rslt_dtls_id;
             EXIT WHEN c_tst_rslt_dtls_id%NOTFOUND;
             l_count := c_tst_rslt_dtls_id%ROWCOUNT;
          END LOOP;
          CLOSE c_tst_rslt_dtls_id;
          -- set p_unit_details_id in case no data or too many rows
          IF l_count = 0 OR l_count >=2 THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADM_TST_RSLT_NOT_EXISTS');
            FND_MSG_PUB.ADD;
            x_return_status := FALSE;
          END IF;
       END;
     END IF;

       /*
        derive p_as_version_number
     */
     p_as_version_number := IGS_GE_GEN_003.GET_PROGRAM_VERSION
                                   (
                                     p_person_id  => p_person_id,
                                     p_program_cd => p_lgcy_adstlvl_rec.program_cd
                                   );


     /*
        check for x_return_status, in this way you can capture all
        failures at one go
     */

     IF NOT x_return_status THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   END derive_level_data;

  FUNCTION validate_adv_std_db_cons
           (
             p_person_id          IN  igs_pe_person.person_id%type,
             p_version_number     IN  igs_ps_ver_all.version_number%type,
             p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_adv_std_db_cons function performs
            all the data integrity validation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;
     IF NOT IGS_PS_VER_PKG.GET_PK_FOR_VALIDATION
                       (
                         x_course_cd      => p_lgcy_adstlvl_rec.program_cd,
                         x_version_number => p_version_number
                       ) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_PRG_CD_NOT_EXISTS');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
     END IF;
     return x_return_status;
  END validate_adv_std_db_cons;

  FUNCTION validate_adv_stnd
           (
             p_person_id          IN  igs_pe_person.person_id%type,
             p_version_number     IN  igs_ps_ver.version_number%type,
             p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_adv_stnd function validates all the business
            rules before inserting a record in the table
            IGS_AV_ADV_STANDING_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;
     /*
        check whether person is deceased or not
     */
     DECLARE
        CURSOR c_ind (cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
               SELECT deceased_ind
               FROM   igs_pe_hz_parties
               WHERE  party_id = cp_party_id;
        l_ind  igs_pe_hz_parties.deceased_ind%TYPE;
     BEGIN
        OPEN  c_ind (p_person_id);
        FETCH c_ind INTO l_ind;
        CLOSE c_ind;
        IF upper(l_ind) = 'Y' THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_PERSON_DECEASED');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
        END IF;
     END;
     /*
        check whether exemtion_inst_cd is valid or not
     */
     DECLARE
        CURSOR c_exists (cp_exemption_institution_cd igs_or_inst_exempt_v.exemption_institution_cd%TYPE) IS
		  SELECT 'x'
		  FROM hz_parties hp, igs_pe_hz_parties ihp
		 WHERE hp.party_id = ihp.party_id
		   AND ihp.inst_org_ind = 'I'
		   AND ihp.oi_govt_institution_cd IS NOT NULL
		   AND ihp.oi_institution_status = 'ACTIVE'
		   AND ihp.oss_org_unit_cd = cp_exemption_institution_cd;
        l_exists VARCHAR2(1);
     BEGIN
        OPEN c_exists(p_lgcy_adstlvl_rec.exemption_institution_cd);
        FETCH c_exists INTO l_exists;
        IF c_exists%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_STND_EXMPT_INVALID');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
        END IF;
        CLOSE c_exists;
     END;
     /*
        check whether program_cd is valid or not
     */
     DECLARE
        l_message_name VARCHAR2(2000);
     BEGIN
        IF NOT IGS_AV_VAL_AS.ADVP_VAL_AS_CRS
                        (
                           p_person_id      => p_person_id,
                           p_course_cd      => p_lgcy_adstlvl_rec.program_cd,
                           p_version_number => p_version_number,
                           p_message_name   => l_message_name
                         ) THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_HE_EXT_SPA_DTL_NOT_FOUND');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
         END IF;
     END;
     /*
        validation for exemption credit points
     */

     DECLARE
           CURSOR c_local_inst_ind (cp_ins_cd igs_or_institution.institution_cd%type) IS
                       SELECT  ins.local_institution_ind
                       FROM    igs_or_institution ins
                       WHERE   ins.institution_cd = cp_ins_cd;

           CURSOR cur_program_exempt_totals (
                               cp_course_cd      igs_ps_ver.course_cd%type,
                               cp_version_number igs_ps_ver.version_number%type,
                   cp_local_ind      VARCHAR2) IS
                 SELECT  DECODE (cp_local_ind, 'N', NVL (cv.external_adv_stnd_limit, -1),
                                                NVL (cv.internal_adv_stnd_limit, -1)) adv_stnd_limit
                 FROM    igs_ps_ver cv
                 WHERE   cv.course_cd    = cp_course_cd
                 AND     cv.version_number   = cp_version_number;

            rec_cur_program_exempt_totals cur_program_exempt_totals%ROWTYPE;
            rec_local_inst_ind c_local_inst_ind%ROWTYPE;
            l_message_name fnd_new_messages.message_name%TYPE;

     BEGIN
         OPEN c_local_inst_ind (p_lgcy_adstlvl_rec.exemption_institution_cd);
         FETCH c_local_inst_ind INTO rec_local_inst_ind;
                 IF (c_local_inst_ind%NOTFOUND) THEN
                   rec_local_inst_ind.local_institution_ind := 'N';
                 END IF;
         CLOSE c_local_inst_ind;
         IF (rec_local_inst_ind.local_institution_ind = 'N') THEN
           l_message_name := 'IGS_AV_EXCEEDS_PRGVER_EXT_LMT';
         ELSE
           l_message_name := 'IGS_AV_EXCEEDS_PRGVER_INT_LMT';
         END IF;

         OPEN cur_program_exempt_totals (
                p_lgcy_adstlvl_rec.program_cd,
                p_version_number,
                rec_local_inst_ind.local_institution_ind);
         FETCH cur_program_exempt_totals INTO rec_cur_program_exempt_totals;
         CLOSE cur_program_exempt_totals;

         IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
              IF p_lgcy_adstlvl_rec.total_exmptn_approved < 0 OR
                 p_lgcy_adstlvl_rec.total_exmptn_approved > rec_cur_program_exempt_totals.adv_stnd_limit THEN
                 FND_MESSAGE.SET_NAME('IGS',l_message_name);
                 FND_MSG_PUB.ADD;
                 x_return_status := FALSE;
              END IF;
         END IF;

         IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
               IF p_lgcy_adstlvl_rec.total_exmptn_granted < 0 OR
                 p_lgcy_adstlvl_rec.total_exmptn_granted > rec_cur_program_exempt_totals.adv_stnd_limit THEN
                 FND_MESSAGE.SET_NAME('IGS',l_message_name);
                 FND_MSG_PUB.ADD;
                 x_return_status := FALSE;
               END IF;
         END IF;
     END;
     /*
        check the course_attempt_status
     */
     DECLARE
        CURSOR c_exists (cp_person_id    igs_en_stdnt_ps_att.person_id%TYPE,
                         cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE ) IS
               SELECT 'x'
               FROM   igs_en_stdnt_ps_att
               WHERE  person_id = cp_person_id
               AND    course_cd = cp_course_cd
               AND    course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT','UNCONFIRM','DISCONTIN','COMPLETED');
         l_exists VARCHAR2(1);
     BEGIN
         OPEN c_exists (p_person_id,
                        p_lgcy_adstlvl_rec.program_cd);
         FETCH c_exists INTO l_exists;
         IF c_exists%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_PRG_ATTMPT_INVALID');
            FND_MSG_PUB.ADD;
            x_return_status := FALSE;
         END IF;
         CLOSE c_exists;
     END;


     return x_return_status;

  END validate_adv_stnd;


  FUNCTION validate_lvl_db_cons
           (
             p_person_id              IN igs_pe_person.person_id%type,
             p_s_adv_stnd_unit_level  IN igs_ps_unit_level.unit_level%type,
             p_cal_type               IN igs_ca_inst.cal_type%type,
             p_seq_number             IN igs_ca_inst.sequence_number%type,
             p_auth_pers_id           IN igs_pe_person.person_id%type,
             p_unit_details_id        IN igs_ad_term_unitdtls.unit_details_id%type,
             p_tst_rslt_dtls_id       IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
             p_qual_dets_id           IN igs_uc_qual_dets.qual_dets_id%type,
             p_course_version         IN igs_ps_ver.version_number%type,
             p_lgcy_adstlvl_rec       IN lgcy_adstlvl_rec_type,
             p_av_stnd_unit_lvl_id   OUT NOCOPY igs_av_std_ulvlbasis_all.av_stnd_unit_lvl_id%type
           )
  RETURN  BOOLEAN
  /******************************************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_lvl_db_cons function performs all the data
            integrity validation  before entering into the table
            IGS_AV_STND_UNIT_LVL_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  Aiyer           03-jan-2003     This Function has been modified as per the bug #2732975
                                  Changed the if conditition i.e if both institution code and
                                  tst_rslt_dtls_id are not nulls then show the error message
                                  IGS_AV_INST_RLID_BOTH_NOT_NULL.
                                  Also removed the foreign key condition check for qualification details ID,
                                  Unit Details ID ,Test Result details ID. Instead these have been added in the procedure
                                  derive_level_data
  Lkaki           22-Mar-2005     The range while checking the credit points entered is changed from 100 to 999
                                  as part of the bug : 4253919
  ***********************************************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;
     /*
        primary key validation
     */
     SELECT IGS_AV_STND_UNIT_LVL_S.NEXTVAL INTO p_av_stnd_unit_lvl_id FROM dual;
     IF IGS_AV_STND_UNIT_LVL_PKG.GET_PK_FOR_VALIDATION (p_av_stnd_unit_lvl_id) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_ADV_STND_ALREADY_EXISTS');
        FND_MSG_PUB.ADD;
        p_av_stnd_unit_lvl_id := NULL;
        x_return_status := FALSE;
     END IF;

     /*
         Foreign Key with Table IGS_AV_ADV_STANDING_PKG
     */
     IF NOT IGS_AV_ADV_STANDING_PKG.GET_PK_FOR_VALIDATION
                   (
                     x_person_id                => p_person_id,
                     x_course_cd                => p_lgcy_adstlvl_rec.program_cd,
                     x_version_number           => p_course_version,
                     x_exemption_institution_cd => p_lgcy_adstlvl_rec.exemption_institution_cd
                   ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_NO_ADV_STND_DET_EXIST');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Foreign Key with AUTHORIZING_PERSON_ID exists in table IGS_PE_PERSON
     */
     IF p_auth_pers_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_INVALID_PERS_AUTH_NUM');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Valid s_adv_granting_status exists
     */
     IF NOT IGS_LOOKUPS_VIEW_PKG.GET_PK_FOR_VALIDATION
                    (
                      x_lookup_type => 'ADV_STND_GRANTING_STATUS',
                      x_lookup_code => p_lgcy_adstlvl_rec.s_adv_stnd_granting_status
                    ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CANNOT_DTR_GRNT_STAT');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Foreign Key with Table IGS_PS_UNIT_LEVEL
     */
     IF NOT IGS_PS_UNIT_LEVEL_PKG.GET_PK_FOR_VALIDATION
                    (
                       x_unit_level => p_s_adv_stnd_unit_level
                    ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_TYPE_MUSTBE_LEVEL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Credit points between 0 and 999
     */
     BEGIN
        IF to_number(p_lgcy_adstlvl_rec.credit_points) < 0 OR
           to_number(p_lgcy_adstlvl_rec.credit_points) > 999 THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_AV_CRD_POINTS_BET_0_99');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_AV_CRD_POINTS_BET_0_99');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
     END;
     /*
         program_group_ind should be Y or N
     */
     IF p_lgcy_adstlvl_rec.prog_group_ind NOT IN ('Y','N') THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CRS_GRP_IN_Y_N');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Validate that if institution_cd is not null then one of
         unit_details_id or QUAL_DETS_ID needs to have a not null value
     */
     IF p_lgcy_adstlvl_rec.institution_cd IS NOT NULL THEN
        IF p_unit_details_id IS NULL AND
           p_qual_dets_id IS NULL THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_AV_UDID_QDID_CAN_NOT_NULL');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
        END IF;
     END IF;
     /*
         Validate that if both institution_cd and tst_rslt_dtls_id
         are not nulls then raise an error message
         This code has been modfied as per the bug #2732975
         Changed condition from null to not null for both institution code and tst_rslt_dtls_id
     */
     IF p_lgcy_adstlvl_rec.institution_cd IS NOT NULL AND
        p_tst_rslt_dtls_id IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_INST_RLID_BOTH_NOT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Validate that  One and only one of qualification details,
         unit details or test result details can be
         entered (all the three cannot be Not Nulls simultaneously)
     */
     IF NOT
     (
       ( p_unit_details_id IS NOT NULL AND
         p_tst_rslt_dtls_id IS NULL AND
         p_qual_dets_id IS NULL
       )
       OR
       ( p_unit_details_id IS NULL AND
         p_tst_rslt_dtls_id IS NOT NULL AND
         p_qual_dets_id IS NULL
       )
       OR
       ( p_unit_details_id IS NULL AND
         p_tst_rslt_dtls_id IS NULL AND
         p_qual_dets_id IS NOT NULL
       )
     ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_ATLEAST_ONE_NOT_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Validate that  valid values for the record parameter
         s_adv_stnd_granting_status are in
         'CANCELLED','GRANTED','APPROVED','EXPIRED','REVOKED'
     */
     IF p_lgcy_adstlvl_rec.s_adv_stnd_granting_status NOT IN
        ('CANCELLED','GRANTED','APPROVED','EXPIRED','REVOKED') THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_CANNOT_DTR_GRNT_STAT');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     /*
        Unit level marks between 0 and 100
     */
     BEGIN
        IF to_number(p_lgcy_adstlvl_rec.unit_level_mark) < 0 OR
           to_number(p_lgcy_adstlvl_rec.unit_level_mark) > 100 THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GR_MARK_INV_0_100');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GR_MARK_INV_0_100');
           FND_MSG_PUB.ADD;
           x_return_status := FALSE;
     END;

     return x_return_status;

  END validate_lvl_db_cons;


  FUNCTION validate_level
           (
             p_person_id           IN igs_pe_person.person_id%type,
             p_unit_level          IN igs_ps_unit_level.unit_level%type,
             p_cal_type            IN igs_ca_inst.cal_type%type,
             p_seq_number          IN igs_ca_inst.sequence_number%type,
             p_auth_pers_id        IN igs_pe_person.person_id%type,
             p_unit_details_id     IN igs_ad_term_unitdtls.unit_details_id%type,
             p_tst_rslt_dtls_id    IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
             p_qual_dets_id        IN igs_uc_qual_dets.qual_dets_id%type,
             p_course_version      IN igs_ps_ver.version_number%type,
             p_lgcy_adstlvl_rec    IN lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_level function performs all the business
            validations before inserting a record into the table
            IGS_AV_STND_UNIT_LVL_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;
     /*
         Validate that the approved date is greater than current date
     */
     IF p_lgcy_adstlvl_rec.approved_dt >= SYSDATE THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_APRVDT_LE_CURDT');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Validate whether the granted date, cancelled date or
         revoked date  are greater than or equal to the approved
         date for the same record
     */
     IF p_lgcy_adstlvl_rec.granted_dt <= p_lgcy_adstlvl_rec.approved_dt OR
        p_lgcy_adstlvl_rec.cancelled_dt <= p_lgcy_adstlvl_rec.approved_dt OR
        p_lgcy_adstlvl_rec.revoked_dt <= p_lgcy_adstlvl_rec.approved_dt THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_DTASSO_LE_APPRVDT');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
         Validate whether auth person is staff or not
     */
     DECLARE
        l_message VARCHAR2(2000);
     BEGIN
       IF NOT IGS_AD_VAL_ACAI.GENP_VAL_STAFF_PRSN
                             (
                                p_person_id    => p_auth_pers_id,
                                p_message_name => l_message
                             ) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_NOT_STAFF_MEMBER');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;
     /*
         Validate inst cd
     */
     DECLARE
        l_message VARCHAR2(2000);
     BEGIN
       IF NOT IGS_AV_VAL_ASU.ADVP_VAL_ASU_INST
                             (
                               p_exempt_inst  => p_lgcy_adstlvl_rec.exemption_institution_cd,
                               p_message_name => l_message
                             ) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_AV_INST_CODE_INVALID');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;
     /*
         Validate whether the advanced standing approved / granted has not
         exceeded the advanced standing internal or external limits of
         the Program version
     */
     DECLARE
        l_message VARCHAR2(2000);
        l_total_exmptn_approved        NUMBER;
        l_total_exmptn_granted         NUMBER;
        l_total_exmptn_perc_grntd      NUMBER;

     BEGIN
       IF NOT IGS_AV_VAL_ASU.ADVP_VAL_AS_TOTALS
                             (
                                p_person_id                    => p_person_id,
                                p_course_cd                    => p_lgcy_adstlvl_rec.program_cd,
                                p_version_number               => p_course_version,
                                p_include_approved             => TRUE,
                                p_asu_unit_cd                  => NULL,
                                p_asu_version_number           => NULL,
                                p_asu_advstnd_granting_status  => NULL,
                                p_asul_unit_level              => p_lgcy_adstlvl_rec.unit_level,
                                p_asul_exmptn_institution_cd   => p_lgcy_adstlvl_rec.exemption_institution_cd,
                                p_asul_advstnd_granting_status => p_lgcy_adstlvl_rec.s_adv_stnd_granting_status,
                                p_total_exmptn_approved        => l_total_exmptn_approved,
                                p_total_exmptn_granted         => l_total_exmptn_granted,
                                p_total_exmptn_perc_grntd      => l_total_exmptn_perc_grntd,
                                p_message_name                 => l_message,
                                p_unit_details_id              => p_unit_details_id,
                                p_tst_rslt_dtls_id             => p_tst_rslt_dtls_id
                             ) THEN
          FND_MESSAGE.SET_NAME('IGS',l_message);
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;

     /*
         check for person hold
     */
     DECLARE
        l_message VARCHAR2(2000);
     BEGIN
       IF NOT IGS_EN_VAL_ENCMB.ENRP_VAL_EXCLD_PRSN
                             (
                                p_person_id     => p_person_id,
                                p_course_cd     => p_lgcy_adstlvl_rec.program_cd,
                                p_effective_dt  => p_lgcy_adstlvl_rec.approved_dt,
                                p_message_name  => l_message
                             ) THEN
          FND_MESSAGE.SET_NAME('IGS',l_message);
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;
     /*
         Validate that the approved date is less than the expiry date
     */
     IF p_lgcy_adstlvl_rec.approved_dt >= p_lgcy_adstlvl_rec.expiry_dt THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_APRVDT_NOT_GT_EXPDT');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
        check the course_attempt_status
     */
     DECLARE
        CURSOR c_exists (cp_person_id    igs_en_stdnt_ps_att.person_id%TYPE,
                         cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE ) IS
               SELECT 'x'
               FROM   igs_en_stdnt_ps_att
               WHERE  person_id = cp_person_id
               AND    course_cd = cp_course_cd
               AND    course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT','UNCONFIRM','DISCONTIN','COMPLETED');
         l_exists VARCHAR2(1);
     BEGIN
         OPEN c_exists (p_person_id,
                        p_lgcy_adstlvl_rec.program_cd);
         FETCH c_exists INTO l_exists;
         IF c_exists%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AV_PRG_ATTMPT_INVALID');
            FND_MSG_PUB.ADD;
            x_return_status := FALSE;
         END IF;
         CLOSE c_exists;
     END;
     return x_return_status;

  END validate_level;


  FUNCTION create_post_lvl
           (
             p_person_id          IN  igs_pe_person.person_id%type,
             p_course_version     IN  igs_ps_ver.version_number%type,
             p_unit_details_id     IN igs_ad_term_unitdtls.unit_details_id%type,
             p_tst_rslt_dtls_id    IN igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%type,
             p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : create_post_lvl function performs all the Post
            Insert business validations on the table
            IGS_AV_STND_UNIT_LVL_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
     l_message VARCHAR2(2000);
     l_total_exmptn_approved        NUMBER;
     l_total_exmptn_granted         NUMBER;
     l_total_exmptn_perc_grntd      NUMBER;

  BEGIN
     x_return_status := TRUE;
     /*
         Validate whether the advanced standing approved / granted has not
         exceeded the advanced standing internal or external limits of
         the Program version
     */
     IF NOT IGS_AV_VAL_ASU.ADVP_VAL_AS_TOTALS
                             (
                                p_person_id                    => p_person_id,
                                p_course_cd                    => p_lgcy_adstlvl_rec.program_cd,
                                p_version_number               => p_course_version,
                                p_include_approved             => TRUE,
                                p_asu_unit_cd                  => NULL,
                                p_asu_version_number           => NULL,
                                p_asu_advstnd_granting_status  => NULL,
                                p_asul_unit_level              => p_lgcy_adstlvl_rec.unit_level,
                                p_asul_exmptn_institution_cd   => p_lgcy_adstlvl_rec.exemption_institution_cd,
                                p_asul_advstnd_granting_status => p_lgcy_adstlvl_rec.s_adv_stnd_granting_status,
                                p_total_exmptn_approved        => l_total_exmptn_approved,
                                p_total_exmptn_granted         => l_total_exmptn_granted,
                                p_total_exmptn_perc_grntd      => l_total_exmptn_perc_grntd,
                                p_message_name                 => l_message,
                                p_unit_details_id              => p_unit_details_id,
                                p_tst_rslt_dtls_id             => p_tst_rslt_dtls_id,
				p_asu_exmptn_institution_cd    => p_lgcy_adstlvl_rec.exemption_institution_cd
                             ) THEN
          FND_MESSAGE.SET_NAME('IGS',l_message);
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
     END IF;  -- function returns TRUE
     /*
      update IGS_AV_ADV_STANDING_ALL  with above obtained values for
      total_exmptn_approved, total_exmptn_granted   and total_exmptn_perc_grntd
     */
     IF x_return_status THEN
       UPDATE IGS_AV_ADV_STANDING_ALL
       SET    TOTAL_EXMPTN_APPROVED        = l_total_exmptn_approved,
              TOTAL_EXMPTN_GRANTED         = l_total_exmptn_granted,
              TOTAL_EXMPTN_PERC_GRNTD      = l_total_exmptn_perc_grntd
       WHERE  PERSON_ID                    = p_person_id
       AND    COURSE_CD                    = p_lgcy_adstlvl_rec.program_cd
       AND    VERSION_NUMBER               = p_course_version
       AND    EXEMPTION_INSTITUTION_CD     = p_lgcy_adstlvl_rec.exemption_institution_cd;
     END IF;
     return x_return_status;
  END create_post_lvl;


  FUNCTION validate_lvl_bas_db_cons
           (
             p_person_id           IN  igs_pe_person.person_id%type,
             p_av_stnd_unit_lvl_id IN  igs_av_std_ulvlbasis_all.av_stnd_unit_lvl_id%type,
             p_lgcy_adstlvl_rec    IN  lgcy_adstlvl_rec_type
           )
  RETURN VARCHAR2
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose :
          validate_lvl_bas_db_cons function performs all the
          data integrity validation before inserting
          into the table IGS_AV_STD_ULVLBASIS_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  swaghmar	19-Oct-2005	Changed for bug# 4676359
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  VARCHAR2(1);
  BEGIN
     x_return_status := 'S';
     /*
        Primary key validation
     */

     IF IGS_AV_STD_ULVLBASIS_PKG.GET_PK_FOR_VALIDATION
                            (
                              x_av_stnd_unit_lvl_id => p_av_stnd_unit_lvl_id
                            ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_ULVLBS_ALREADY_EXISTS');
        FND_MSG_PUB.ADD;
        x_return_status := 'W';
        return x_return_status;
     END IF;
     /*
        Foreign Key with IGS_AV_STND_UNIT_LVL_ALL
     */
     IF NOT IGS_AV_STND_UNIT_LVL_PKG.GET_PK_FOR_VALIDATION
                            (
                              x_av_stnd_unit_lvl_id => p_av_stnd_unit_lvl_id
                            ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_NO_ADV_STND_DET_EXIST');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
     END IF;
     /*
        Foreign Key with IGS_PS_TYPE_ALL
     */
     IF ((p_lgcy_adstlvl_rec.basis_program_type IS NOT NULL) AND NOT IGS_PS_TYPE_PKG.GET_PK_FOR_VALIDATION(
								      x_course_type => p_lgcy_adstlvl_rec.basis_program_type
								    )) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_BAS_CRS_TYP_FK_EXISTS');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
     END IF;
     /*
        Validate that the record parameter BASIS_YEAR
        is greater than 1900 and less than 2100
     */
     IF ((p_lgcy_adstlvl_rec.basis_year IS NOT NULL) AND ( p_lgcy_adstlvl_rec.basis_year <= 1900 OR
							   p_lgcy_adstlvl_rec.basis_year >= 2100)) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_BS_YR_BET_1900_2100');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
     END IF;
     /*
        Validate that the record parameter BASIS_COMPLETION_IND
        must be either 'Y' or 'N'
     */
     IF ((p_lgcy_adstlvl_rec.basis_completion_ind IS NOT NULL) AND (p_lgcy_adstlvl_rec.basis_completion_ind NOT IN ('Y','N'))) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AV_BS_CMPL_IND_IN_Y_N');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
     END IF;

     return x_return_status;

  END validate_lvl_bas_db_cons;

  FUNCTION validate_lvl_bas
           (
             p_course_version     IN  igs_ps_ver.version_number%type,
             p_lgcy_adstlvl_rec   IN  lgcy_adstlvl_rec_type
           )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose :
          validate_lvl_bas function performs all the business
          validation before inserting  into the table
          IGS_AV_STD_ULVLBASIS_ALL
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
     l_message_name   VARCHAR2(2000);
     l_return_type    VARCHAR2(2000);

  BEGIN
     x_return_status := TRUE;

     x_return_status := IGS_AV_VAL_ASULEB.ADVP_VAL_BASIS_YEAR
                            (
                              p_basis_year     => p_lgcy_adstlvl_rec.basis_year,
                              p_course_cd      => p_lgcy_adstlvl_rec.program_cd,
                              p_version_number => p_course_version,
                              p_message_name   => l_message_name,
                              p_return_type    => l_return_type
                             );
     IF NOT x_return_status THEN
                FND_MESSAGE.SET_NAME('IGS', l_message_name);
                FND_MSG_PUB.ADD;
     END IF;
     return x_return_status;
  END validate_lvl_bas;

END igs_av_lvl_lgcy_pub;

/
