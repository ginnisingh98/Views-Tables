--------------------------------------------------------
--  DDL for Package Body IGS_AS_SUARC_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SUARC_LGCY_PUB" AS
/* $Header: IGSPAS2B.pls 120.2 2005/10/20 23:56:17 appldev noship $ */
    g_pkg_name              CONSTANT VARCHAR2(30) := 'IGS_AS_SUARC_LGCY_PUB';
    g_suarc_status             VARCHAR2(10) := 'VALID';
    g_wlst_pri_pref_exists  BOOLEAN :=FALSE;
PROCEDURE validate_parameters(p_suarc_dtls_rec   IN   sua_refcd_rec_type ) AS
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_parameters                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              creation of a student Assessment unit  outcome record.       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_suarc_dtls_rec                                          |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  bradhakr   03-jul-2005                                                  |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
    -- Declare local variables and initialise parameters.
    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000);
    l_grade_msg     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
BEGIN
    -- Person Number is Mandatory
    IF p_suarc_dtls_rec.person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- Program Code is Mandatory
    IF p_suarc_dtls_rec.program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- Unit Code is Mandatory
    IF p_suarc_dtls_rec.unit_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNITCD_SPECIFIED');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- Calendar Alternate Code is Mandatory
    IF p_suarc_dtls_rec.teach_cal_alt_code  IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_CAL_TYP_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- Location Code is Mandatory
    IF p_suarc_dtls_rec.location_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_LOC_CD_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- Unit Class is Mandatory
    IF p_suarc_dtls_rec.unit_class IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNT_CLS_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
        -- Reference Code Type is Mandatory
    IF p_suarc_dtls_rec.reference_cd_type IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AS_REFERENCE_CD_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
        --  Reference Code is Mandatory
    IF p_suarc_dtls_rec.reference_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AS_REFERENCE_CD_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
        --  Applied Program Code is Mandatory
    IF p_suarc_dtls_rec.applied_program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AS_APPLIED_PROGRAM_CD_NULL');
        FND_MSG_PUB.Add;
        g_suarc_status  := 'INVALID';
    END IF;
    -- If Program Code is specified , it should be in Upper Case.
    IF p_suarc_dtls_rec.program_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                    column_name  => 'COURSE_CD' ,
                    column_value => p_suarc_dtls_rec.program_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PRGM_CD_UCASE');
                FND_MSG_PUB.ADD;
            g_suarc_status  := 'INVALID';
        END;
    END IF;
-- If Applied Program Code is specified , it should be in Upper Case.
    IF p_suarc_dtls_rec.program_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                    column_name  => 'COURSE_CD' ,
                    column_value => p_suarc_dtls_rec.applied_program_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PRGM_CD_UCASE');
                FND_MSG_PUB.ADD;
            g_suarc_status  := 'INVALID';
        END;
    END IF;
    -- If Unit Code is specified , it should be in Upper Case.
    IF p_suarc_dtls_rec.unit_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                        column_name  => 'UNIT_CD' ,
                        column_value => p_suarc_dtls_rec.unit_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                            p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_CD_UCASE');
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
        END;
    END IF;
    -- If Location Code is specified , it should be in Upper Case.
    IF p_suarc_dtls_rec.location_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                column_name  => 'LOCATION_CD' ,
                column_value => p_suarc_dtls_rec.location_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_LOC_CD_UCASE');
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
        END;
    END IF;
    -- If Unit class is specified , it should be in Upper Case.
    IF p_suarc_dtls_rec.unit_class IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                        column_name  => 'UNIT_CLASS' ,
                        column_value => p_suarc_dtls_rec.unit_class );
        EXCEPTION
                WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_CLS_UCASE');
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
        END;
    END IF;
  END validate_parameters;

PROCEDURE validate_db_cons( p_person_id             IN   NUMBER,
                            p_unit_version_number   IN   NUMBER,
                            p_uoo_id                IN   NUMBER ,
                           p_suarc_dtls_rec          IN   sua_refcd_rec_type
                           ) AS
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_db_cons                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is a public procedure and is responsible for the        |
 |              creation of a student Assessment unit  outcome record.       |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_person_id                                          |
 |                    p_unit_version_number                                        |
 |                    p_uoo_id                                               |
 |                    p_suarc_dtls_rec                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | CREATION     HISTORY :                                                    |
 |  bradhakr   03-jul-2005                                                        |
 | MODIFICATION HISTORY                                                      |
 +===========================================================================*/
l_indicator BOOLEAN := false;
l_number NUMBER;
    CURSOR get_ref_code_id
    IS
    SELECT refcd.reference_code_id
      FROM igs_ge_ref_cd refcd, igs_ge_ref_cd_type refcdt
     WHERE refcd.reference_cd_type = refcdt.reference_cd_type
       AND refcd.reference_cd = p_suarc_dtls_rec.reference_cd
       AND refcd.reference_cd_type = p_suarc_dtls_rec.reference_cd_type;

BEGIN
    -- derive ref_code_id
     OPEN  get_ref_code_id;
	 FETCH get_ref_code_id INTO l_number;
	 CLOSE get_ref_code_id;

   -- Check for UK validation.
      IF  igs_as_sua_ref_cds_pkg.get_uk_for_validation(
                    X_PERSON_ID => p_person_id,
                    X_COURSE_CD => p_suarc_dtls_rec.program_cd,
                       X_UOO_ID => p_uoo_id,
            X_REFERENCE_CODE_ID => l_number,
            X_APPLIED_COURSE_CD => p_suarc_dtls_rec.applied_program_cd,
                 X_DELETED_DATE => TO_DATE(null)
         ) THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_AS_UK_CHK_REF_CD' );
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
      END IF;

   -- Foreign Key Validation - Check if Location Code exists.
   IF NOT igs_ad_location_pkg.get_pk_for_validation ( x_location_cd => p_suarc_dtls_rec.location_cd) THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_LOC_CD_INV' );
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
   END IF;

  -- Foreign Key Validation - Check if Student Unit Attempt exists.
  IF NOT igs_en_su_attempt_pkg.get_pk_for_validation (
        x_person_id     =>  p_person_id,
        x_course_cd     =>  p_suarc_dtls_rec.program_cd,
       x_uoo_id => p_uoo_id) THEN
                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_FI_PRSNID_PRGCD_NOT_MATCH');
                    FND_MSG_PUB.ADD;
                    g_suarc_status  := 'INVALID';
  END IF ;

  -- Foreign Key Validation - Check if Student Program Attempt exists.
  IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
        x_person_id     =>  p_person_id,
        x_course_cd     =>  p_suarc_dtls_rec.program_cd) THEN
                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_FI_PRSNID_PRGCD_NOT_MATCH');
                    FND_MSG_PUB.ADD;
                    g_suarc_status  := 'INVALID';
  END IF ;

  -- Foreign Key Validation - Check if Student (Applied )Program Attempt exists.
  IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
        x_person_id     =>  p_person_id,
        x_course_cd     =>  p_suarc_dtls_rec.applied_program_cd)THEN
	                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_AS_NO_PROGRAM_ATTEMPT');
                    FND_MSG_PUB.ADD;
                    g_suarc_status  := 'INVALID';
  END IF ;

   -- Foreign Key Validation - Check if Unit Code exists.
  IF NOT igs_ps_unit_pkg.get_pk_for_validation ( x_unit_cd => p_suarc_dtls_rec.unit_cd)THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_IN_INVALID_UNIT_CODE');
                FND_MSG_PUB.ADD;
                g_suarc_status  := 'INVALID';
  END IF;

  -- Foreign Key Validation - Check if Unit Code / Version exists.
  IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
        x_unit_cd              => p_suarc_dtls_rec.unit_cd,
        x_version_number       => NVL ( p_suarc_dtls_rec.version_number,p_unit_version_number))   THEN
                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_PS_UNITCODE_UNITVER_NE');
                    FND_MSG_PUB.ADD;
                    g_suarc_status  := 'INVALID';
  END IF;
END validate_db_cons;

PROCEDURE create_suarc (    p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2 ,
                            p_commit                IN   VARCHAR2 ,
                            p_validation_level      IN   NUMBER  ,
                            p_suarc_dtls_rec          IN   sua_refcd_rec_type  ,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2) AS
    l_api_name              CONSTANT    VARCHAR2(30) := 'create_suarc';
    l_api_version           CONSTANT    NUMBER       := 1.0;
    l_insert_flag           BOOLEAN := TRUE;
    l_suar_id igs_as_sua_ref_cds.suar_id%TYPE;
    l_person_id igs_pe_person.person_id%TYPE;
    l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_cal_type igs_en_su_attempt.cal_type%TYPE;
    l_ci_sequence_number igs_en_su_attempt.ci_Sequence_number%TYPE;
    l_ci_start_dt igs_ca_inst.start_dt%TYPE;
    l_ci_end_dt igs_ca_inst.end_dt%TYPE;
    l_version_number igs_en_su_attempt.version_number%TYPE;
    l_reference_code_id igs_as_sua_ref_cds.reference_code_id%TYPE;
    l_reference_cd_type igs_as_sua_ref_cds.reference_cd_type%TYPE;
    l_reference_cd igs_as_sua_ref_cds.reference_cd%TYPE;
    l_applied_program_cd igs_as_sua_ref_cds.applied_course_cd%TYPE;
    l_return_status VARCHAR2(30);
    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000);
    l_org_unit_cd igs_or_unit.org_unit_cd%TYPE;
    l_ref_cd_id NUMBER;
    L_EXISTS VARCHAR2(30);
    l_sua_status igs_en_su_attempt_all.unit_attempt_status%TYPE;

    CURSOR cur_sua_status
    IS
    SELECT unit_attempt_status
      FROM igs_en_su_attempt_all
     where person_id = l_person_id
       AND course_cd =p_suarc_dtls_rec.program_cd
       AND uoo_id = l_uoo_id ;

    CURSOR cur_check_ref_cd
    IS
    SELECT 'X'
      FROM igs_ge_ref_cd refcd
     WHERE refcd.reference_cd = p_suarc_dtls_rec.reference_cd
       AND refcd.reference_cd_type = p_suarc_dtls_rec.reference_cd_type;

    CURSOR cur_check_ref_cd_section_abv
    IS
    SELECT 'X'
      FROM igs_ge_ref_cd refcd, igs_ge_ref_cd_type refcdt
     WHERE refcd.reference_cd_type = refcdt.reference_cd_type
       AND refcd.reference_cd = p_suarc_dtls_rec.reference_cd
       AND refcd.reference_cd_type = p_suarc_dtls_rec.reference_cd_type
       AND refcdt.UNIT_FLAG='Y'
       AND refcdt.UNIT_SECTION_FLAG='Y'
       AND refcdt.UNIT_SECTION_OCCURRENCE_FLAG='Y';

    CURSOR get_ref_code_id
    IS
    SELECT refcd.reference_code_id
      FROM igs_ge_ref_cd refcd
     WHERE refcd.reference_cd = p_suarc_dtls_rec.reference_cd
       AND refcd.reference_cd_type = p_suarc_dtls_rec.reference_cd_type;

    BEGIN
    -- Create a savepoint
    SAVEPOINT    CREATE_SUARC_PUB;
    -- Check for the Compatible API call
    IF NOT FND_API.COMPATIBLE_API_CALL(  l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- If the calling program has passed the parameter for initializing the message list
    IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;
    -- Set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_suarc_status  := 'VALID';
    --
    -- 1.Validate Parameters
    validate_parameters(p_suarc_dtls_rec => p_suarc_dtls_rec);
    -- 2.Derive all required parameters
    IF g_suarc_status <>  'INVALID' THEN
      -- Derive Person ID
      l_person_id := igs_ge_gen_003.get_person_id ( p_person_number => p_suarc_dtls_rec.person_number) ;
      IF l_person_id IS NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_GE_INVALID_PERSON_NUMBER');
                    FND_MSG_PUB.ADD;
                        g_suarc_status := 'INVALID';
            END IF;
    -- Derive Calendar Details.
      igs_ge_gen_003.get_calendar_instance(
            p_alternate_cd    => p_suarc_dtls_rec.teach_cal_alt_code ,
            p_s_cal_category  => '''TEACHING''',
            p_cal_type        => l_cal_type ,
            p_ci_sequence_number => l_ci_sequence_number ,
            p_start_dt        => l_ci_start_dt ,
            p_end_dt          => l_ci_end_dt ,
            p_return_status   => l_return_status );
        IF l_return_status = 'INVALID' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ALT_CD_NO_CAL_FND');
            FND_MSG_PUB.ADD;
                        g_suarc_status := 'INVALID';
            ELSIF l_return_status =  'MULTIPLE' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_MULTI_TCH_CAL_FND');
            FND_MSG_PUB.ADD;
                        g_suarc_status := 'INVALID';
            END IF ;
      -- Derive Unit version if parameter is NULL.
      IF p_suarc_dtls_rec.version_number IS NULL THEN
        IF NOT igs_en_gen_legacy.get_unit_ver (
                p_cal_type          =>  l_cal_type ,
                p_ci_sequence_number => l_ci_sequence_number ,
                p_unit_cd           =>  p_suarc_dtls_rec.unit_cd ,
                p_location_cd       =>  p_suarc_dtls_rec.location_cd ,
                P_unit_class        =>  p_suarc_dtls_rec.unit_class ,
                p_version_number    =>  l_version_number )  THEN
                        g_suarc_status := 'INVALID';
        END IF;
      END IF;
    -- Derive uoo_id
    IF NOT igs_en_gen_legacy.get_uoo_id (
                p_cal_type              =>  l_cal_type ,
                p_ci_sequence_number     => l_ci_sequence_number ,
                p_unit_cd               =>  p_suarc_dtls_rec.unit_cd ,
                p_location_cd           =>  p_suarc_dtls_rec.location_cd ,
                P_unit_class            =>  p_suarc_dtls_rec.unit_class ,
                p_version_number        =>  NVL ( p_suarc_dtls_rec.version_number,l_version_number) ,
                p_uoo_id                =>  l_uoo_id                ,
                p_owner_org_unit_cd     =>  l_org_unit_cd ) THEN
                g_suarc_status := 'INVALID';
    END IF;

   -- swaghmar 4327987 - To check for the status of the SUA
    OPEN cur_sua_status;
    FETCH cur_sua_status INTO l_sua_status;
     IF l_sua_status IN ('WAITLISTED','UNCONFIRM') THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_SUA_STS_NT_ALLOWED');
           FND_MSG_PUB.ADD;
           g_suarc_status := 'INVALID';
         END IF;
    CLOSE cur_sua_status;

    -- derive reference code id
    OPEN  get_ref_code_id;
	 FETCH get_ref_code_id INTO l_ref_cd_id;
	  CLOSE get_ref_code_id;
  --- check if reference code exists
   OPEN  cur_check_ref_cd;
	 FETCH cur_check_ref_cd INTO l_exists;
	 IF cur_check_ref_cd%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_REFERENCE_CD_NT_EXIST');
           FND_MSG_PUB.ADD;
           g_suarc_status := 'INVALID';
         END IF;
         CLOSE cur_check_ref_cd;
    -- check if reference code can be used for the unit set
   OPEN  cur_check_ref_cd_section_abv;
	 FETCH cur_check_ref_cd_section_abv INTO l_exists;
	 IF cur_check_ref_cd_section_abv%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_REFERENCE_CODE_NOT_SET');
           FND_MSG_PUB.ADD;
	   g_suarc_status := 'INVALID';
       END IF;
    CLOSE cur_check_ref_cd_section_abv;

    -- 3. The DB constraints are validated by making a call to validate_db_cons.
    validate_db_cons (  p_person_id                     => l_person_id ,
                        p_unit_version_number   => l_version_number ,
                        p_uoo_id                        => l_uoo_id ,
                        p_suarc_dtls_rec          => p_suarc_dtls_rec ) ;

  END IF ;
--swaghmar Bug #4327987
  SELECT IGS_AS_SUA_REF_CDS_S.nextval INTO l_suar_id from dual;

  IF g_suarc_status = 'VALID' THEN
          INSERT INTO IGS_AS_SUA_REF_CDS (
             SUAR_ID,
             person_id,
             course_cd,
             uoo_id,
             REFERENCE_CODE_ID,
             REFERENCE_CD_TYPE,
             REFERENCE_CD,
             APPLIED_COURSE_CD,
	          CREATED_BY,
              CREATION_DATE,
             last_update_date,
             last_updated_by,
             last_update_login
               )
             VALUES (
             l_suar_id,
             l_person_id,
             p_suarc_dtls_rec.program_cd,
             l_uoo_id,
	           l_ref_cd_id,
             p_suarc_dtls_rec.reference_cd_type,
             p_suarc_dtls_rec.reference_cd,
             p_suarc_dtls_rec.applied_program_cd,
             nvl(fnd_global.user_id,-1),
             SYSDATE,
             SYSDATE,
             NVL(fnd_global.user_id,-1),
             NVL(fnd_global.login_id,-1));
     END IF;
     --
    -- If the calling program has passed the parameter for committing the data and there
    -- have been no errors in calling the balances process, then commit the work
    IF ( (FND_API.To_Boolean(p_commit)) AND (g_suarc_status = 'VALID') ) THEN
      COMMIT WORK;
    END IF;
    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                               p_data    => x_msg_data);
    --
    -- Retutn Status to the calling program
    IF g_suarc_status = 'INVALID' THEN
        ROLLBACK TO CREATE_SUARC_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF g_suarc_status = 'WARNING' THEN
        ROLLBACK TO CREATE_SUARC_PUB;
        x_return_status := 'W';
    END IF ;
   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO CREATE_SUARC_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO CREATE_SUARC_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO CREATE_SUARC_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                    l_api_name);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
END create_suarc ;
END igs_as_suarc_lgcy_pub ;

/
