--------------------------------------------------------
--  DDL for Package Body IGS_EN_IVR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_IVR_PUB" AS
/* $Header: IGSEN95B.pls 120.5 2006/08/24 07:31:03 bdeviset ship $ */
/*
  ||==============================================================================||
  ||  Created By : Nalin Kumar                                                    ||
  ||  Created On : 16-Jan-2003                                                    ||
  ||  Purpose    : Created this object as per IVR Build. Bug# 2745985             ||
  ||  Known limitations, enhancements or remarks :                                ||
  ||  Change History :                                                            ||
  ||  Who             When            What                                        ||
  || vvutukur  05-Aug-2003 Enh#3045069.PSP Enh Build. Modified update_enroll_stats
  || ctyagi   22-sept-2005  Added p_enroll_from_waitlsit_flag  as a part of bug   ||
                            4580204
  ||ctyagi   26-sept-2005  Removed p_enroll_from_waitlsit_flag  as a part of bug   ||
                            4580204
  ||  (reverse chronological order - newest change first)                         ||
  ||==============================================================================||
*/
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_EN_IVR_PUB';

  PROCEDURE add_to_cart (
    p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    p_commit           IN   VARCHAR2,
    p_person_number    IN   VARCHAR2,
    p_career           IN   VARCHAR2,
    p_program_code     IN   VARCHAR2,
    p_term_alt_code    IN   VARCHAR2,
    p_call_number      IN   NUMBER,
    p_audit_ind        IN   VARCHAR2,
    p_waitlist_ind     OUT NOCOPY  VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 20JAN2003
  ||  Purpose    : The procedure will add a section to the students cart.
  ||               It will accept the call number of section to added .
  ||               It will check if seats are available in the section. If seats are not available it will return error status.
  ||               Also check if waitlist is allowed and depending on that the return indicator for waitlist is to be set.
  ||               The IVR would have to check with the student for waitlisting.
  ||               If seats are available and section can be enrolled via IVR then unit steps validation would be performed.
  ||               If they are successful then the section will be added to cart with 'UNCONFIRM' status and CART as 'I'.
  ||               As first step it perform person step validations also.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-Jul-2003     Call to rollback is added to the procedure if igs_en_gen_017.add_to_cart_waitlist
  ||                                  sets the out p_ret_status parameter to false. Bug : 3036949
  ||  (reverse chronological order - newest change first)
  */
    l_api_name           CONSTANT VARCHAR2(30) := 'ADDTOCART';
    l_ret_status         VARCHAR2(6);
    l_message_count      NUMBER;
    l_message_data       VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  ADDTOCART_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (1.0,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Invoke the procedure add_to_cart_waitlist by passing the relevant parameters.
    --Parameter p_action should be 'CART' .
    --The invoke source parameter should have 'IVR' as the input.
    igs_en_gen_017.add_to_cart_waitlist (
        p_person_number => p_person_number,
        p_career        => p_career,
        p_program_code  => p_program_code,
        p_term_alt_code => p_term_alt_code,
        p_call_number   => p_call_number,
        p_audit_ind     => p_audit_ind,
        p_waitlist_ind  => p_waitlist_ind,
        p_action        => 'CART',
        p_error_message => l_message_data,
        p_ret_status    => l_ret_status);

    --If return status is FALSE above then log error message and RETURN.
    IF l_ret_status = 'FALSE' THEN
        ROLLBACK TO ADDTOCART_PUB;
        igs_en_gen_017.enrp_msg_string_to_list (
             p_message_string => l_message_data,
             p_delimiter      => ';',
             p_init_msg_list  => FND_API.G_FALSE,
             x_message_count  => l_message_count,
             x_message_data   => l_message_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := l_message_data;
        x_msg_count := l_message_count;
    ELSE
        IF FND_API.TO_BOOLEAN( p_commit ) THEN
              COMMIT WORK;
        END IF;
    END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO ADDTOCART_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO ADDTOCART_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO ADDTOCART_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data );
  END add_to_cart;

  PROCEDURE enroll_cart(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2,
    p_commit           IN  VARCHAR2,
    p_person_number    IN  VARCHAR2,
    p_career           IN  VARCHAR2,
    p_program_code     IN  VARCHAR2,
    p_term_alt_code    IN  VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER,
    x_msg_data     OUT NOCOPY VARCHAR2) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 23JAN2003
  ||  Purpose    : The procedure will enroll all the sections in the cart
  ||               for students selected program/career and term.
  ||
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || stutta     11-Feb-2004    Passing new parameter p_enrolled_dt as SYSDATE in
  ||                           call to validate_enroll_validate.
  || bdeviset   23-Aug-2006    Passed extra param p_ss_session_id for enrp_ss_val_person_step added as part of bug# 5306874
  ||  (reverse chronological order - newest change first)
  */
    l_api_name           VARCHAR2(30) := 'ENROLL_CART';

    l_person_id          igs_pe_person_base_v.person_id%TYPE;
    l_person_type        igs_pe_typ_instances.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_ps_ver.course_cd%TYPE;
    l_primary_version    igs_ps_ver.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_error_message      VARCHAR2(2000);
    l_ret_status         VARCHAR2(6);
    l_message_count      NUMBER;
    l_message_data       VARCHAR2(2000) := NULL;
    l_deny_warn          igs_en_cpd_ext.notification_flag%TYPE;
    l_dummy_bool         BOOLEAN;
    l_step_eval_result   VARCHAR2(6);
    l_enr_method_type    igs_en_method_type.enr_method_type%TYPE;
    l_conc_uoo_id        VARCHAR2(2000);

    CURSOR c_us_in_cart IS
    SELECT sua.uoo_id,
           sua.enr_method_type,
           sua.cart
    FROM   igs_en_su_attempt sua
    WHERE  sua.person_id = l_person_id
    AND    sua.course_cd = l_primary_code
    AND    (sua.cal_type, sua.ci_sequence_number) IN (SELECT teach_cal_type,teach_ci_sequence_number
                                                     FROM   igs_ca_load_to_teach_v
                                                     WHERE  load_cal_type = l_cal_type
                                                     AND    load_ci_sequence_number = l_ci_sequence_number)
    AND    sua.unit_attempt_status  IN ('INVALID','UNCONFIRM') ;

  BEGIN

    SAVEPOINT  ENROL_CART_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (1.0,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Validate the input parameters and if valid, also fetch the internal calculated
    --values. Pass the Validation level as No Call Number.
    igs_en_gen_017.enrp_validate_input_parameters(
        p_person_number       => p_person_number,
        p_career              => p_career,
        p_program_code        => p_program_code,
        p_term_alt_code       => p_term_alt_code,
        p_call_number         => NULL,
        p_validation_level    => 'NOCALLNUM',
        p_person_id           => l_person_id,
        p_person_type         => l_person_type,
        p_cal_type            => l_cal_type,
        p_ci_sequence_number  => l_ci_sequence_number,
        p_primary_code        => l_primary_code,
        p_primary_version     => l_primary_version,
        p_uoo_id              => l_uoo_id,
        p_error_message       => l_message_data,
        p_ret_status          => l_ret_status );

    --If there is any invalid parameter then log it and return with error status
    IF l_ret_status = 'FALSE' THEN
        igs_en_gen_017.enrp_msg_string_to_list (
                 p_message_string => l_message_data,
                 p_delimiter      => ';',
                 p_init_msg_list  => FND_API.G_FALSE,
                 x_message_count  => x_msg_count,
                 x_message_data   => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

    l_ret_status := NULL;
    l_error_message := NULL;
    --If the parameters are valid, then call the below procedure to evaluate Person Steps.
    igs_ss_en_wrappers.enrp_ss_val_person_step(
         p_person_id               => l_person_id,
         p_person_type             => l_person_type,
         p_load_cal_type           => l_cal_type,
         p_load_ci_sequence_number => l_ci_sequence_number,
         p_program_cd              => l_primary_code,
         p_program_version         => l_primary_version,
         p_message_name            => l_error_message,
         p_deny_warn               => l_deny_warn,
         p_step_eval_result        => l_step_eval_result,
         p_calling_obj             => 'JOB',
         p_create_warning          => 'N',
         p_ss_session_id           =>  NULL );

    --If step evaluation result is FALSE then log the error message and return with error status
    IF l_step_eval_result = 'FALSE' THEN
         igs_en_gen_017.enrp_msg_string_to_list (
                    p_message_string => l_error_message,
                    p_delimiter      => ';',
                    p_init_msg_list  => FND_API.G_FALSE,
                    x_message_count  => l_message_count,
                    x_message_data   => l_message_data);
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data := l_message_data;
         x_msg_count := l_message_count;
         RETURN;
    END IF;

    l_ret_status := NULL;
    l_error_message := NULL;
    --Fetch the enrollment method
    igs_en_gen_017.enrp_get_enr_method(
         p_enr_method_type => l_enr_method_type,
         p_error_message   => l_error_message,
         p_ret_status      => l_ret_status);

    --If error occured during fetching then log it end Return with error status
    IF l_ret_status = 'FALSE' THEN
         igs_en_gen_017.enrp_msg_string_to_list (
                    p_message_string => l_error_message,
                    p_delimiter      => ';',
                    p_init_msg_list  => FND_API.G_FALSE,
                    x_message_count  => l_message_count,
                    x_message_data   => l_message_data);
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data := l_message_data;
         x_msg_count := l_message_count;
         RETURN;
    END IF;

    --Loop through all the unit sections in the cart
    FOR l_us_in_cart IN c_us_in_cart LOOP
         --For each Unit Section check the Cart is null or not.
         --If the cart is null then this indicates that the unit was added by Batch Pre Enrollment
         --and the unit step validations are to be performed
         IF l_us_in_cart.cart IS NULL THEN
            l_deny_warn := NULL;
            l_dummy_bool:= igs_en_enroll_wlst.validate_unit_steps (
                                  p_person_id          => l_person_id,
                                  p_cal_type           => l_cal_type,
                                  p_ci_sequence_number => l_ci_sequence_number,
                                  p_uoo_id             => l_us_in_cart.uoo_id,
                                  p_course_cd          => l_primary_code,
                                  p_enr_method_type    => l_enr_method_type,
                                  p_message_name       => l_error_message,
                                  p_deny_warn          => l_deny_warn,
                                  p_calling_obj        => 'JOB'
                                 );
            --If the unit step validation returns Deny then log the error message and return with Error status
            IF l_deny_warn = 'DENY' THEN
                    igs_en_gen_017.enrp_msg_string_to_list (
                            p_message_string => l_error_message,
                            p_delimiter      => ';',
                            p_init_msg_list  => FND_API.G_FALSE,
                            x_message_count  => l_message_count,
                            x_message_data   => l_message_data);

                            x_return_status := FND_API.G_RET_STS_ERROR;
                            x_msg_data := l_message_data;
                            x_msg_count := l_message_count;
                            RETURN;
            ELSE
                  --If the unit step validation not returns Deny then concatenate the uoo_id to the local_variable l_conc_uoo_id
                  IF l_conc_uoo_id IS NULL THEN
                            l_conc_uoo_id := l_us_in_cart.uoo_id;
                  ELSE
                  l_conc_uoo_id := l_conc_uoo_id ||','|| l_us_in_cart.uoo_id;
                  END IF;
            END IF;
         ELSE
                  --If the cart is having any value then concatenate the uoo_id to the local variable l_conc_uoo_id
                  IF l_conc_uoo_id IS NULL THEN
                       l_conc_uoo_id := l_us_in_cart.uoo_id;
                  ELSE
                       l_conc_uoo_id := l_conc_uoo_id ||','|| l_us_in_cart.uoo_id;
                  END IF;
         END IF;
    END LOOP;

    --Perform the program steps validation and change the status of unit section in the cart to Enrolled status.
    --Pass the concatenated uoo_ids to the procedure, so that it will enroll all those unit sections.
    igs_ss_en_wrappers.validate_enroll_validate (
         p_person_id               => l_person_id,
         p_load_cal_type           => l_cal_type,
         p_load_ci_sequence_number => l_ci_sequence_number,
         p_uoo_ids                 => l_conc_uoo_id,
         p_program_cd              => l_primary_code,
         p_message_name            => l_message_data,
         p_deny_warn               => l_deny_warn,
         p_return_status           => l_ret_status,
         p_enr_method              => l_enr_method_type,
         p_enrolled_dt             => SYSDATE);

    --If return status is Deny then log the error message and retrun with error status
    IF l_ret_status = 'DENY' THEN
         igs_en_gen_017.enrp_msg_string_to_list (
               p_message_string => l_message_data,
               p_delimiter      => ';',
               p_init_msg_list  => FND_API.G_FALSE,
               x_message_count  => l_message_count,
               x_message_data   => l_message_data);

         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data := l_message_data;
         x_msg_count := l_message_count;
    ELSE
         IF p_commit = FND_API.G_TRUE THEN
               COMMIT WORK;
         END IF;
    END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO ENROL_CART_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO ENROL_CART_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO ENROL_CART_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.COUNT_AND_GET (
                        p_count => x_msg_count,
                        p_data  => x_msg_data );
  END enroll_cart;

  PROCEDURE clean_up_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER  ,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : To clean up the cart.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'clean_up_cart';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(10);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;

    -- Cursor to fetch the row_id, to clean up the cart.
    CURSOR cur_sua (cp_person_id      igs_pe_person.person_id%TYPE,
                    cp_program_cd     igs_en_su_attempt.course_cd%TYPE,
                    cp_version_number igs_en_su_attempt.version_number%TYPE)IS
    SELECT sua.row_id
    FROM igs_en_su_attempt sua
    WHERE unit_attempt_status = 'UNCONFIRM' AND
          cart = 'I' AND
          person_id      = cp_person_id AND
          course_cd      = cp_program_cd AND
          version_number = cp_version_number;
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT clean_up_cart;

    --Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';

    --
    -- Main code logic begins
    --

    -- Validate the input parameters.
    igs_en_gen_017.enrp_validate_input_parameters(
      p_person_number      => p_person_number     ,
      p_career             => p_career            ,
      p_program_code       => p_program_code      ,
      p_term_alt_code      => p_term_alt_code     ,
      p_call_number        => NULL                ,
      p_validation_level   => 'NOCALLNUM'         ,
      p_person_id          => l_person_id         ,
      p_person_type        => l_person_type       ,
      p_cal_type           => l_cal_type          ,
      p_ci_sequence_number => l_ci_sequence_number,
      p_primary_code       => l_primary_code      ,
      p_primary_version    => l_primary_version   ,
      p_uoo_id             => l_uoo_id            ,
      p_error_message      => l_error_message     ,
      p_ret_status         => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_delimiter      => ';',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    -- Loop through the records and call the delete row to drop the cart.
    FOR rec_sua IN cur_sua(l_person_id, l_primary_code, l_primary_version) LOOP
      igs_en_su_attempt_pkg.delete_row(rec_sua.row_id);
    END LOOP;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO clean_up_cart;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO clean_up_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN OTHERS THEN
      ROLLBACK TO clean_up_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data );
  END clean_up_cart;

  PROCEDURE drop_all_section(
    p_api_version    IN         NUMBER  ,
    p_init_msg_list  IN         VARCHAR2,
    p_commit         IN         VARCHAR2,
    p_person_number  IN         VARCHAR2,
    p_career         IN         VARCHAR2,
    p_program_code   IN         VARCHAR2,
    p_term_alt_code  IN         VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count  OUT NOCOPY NUMBER  ,
    x_msg_data   OUT NOCOPY VARCHAR2 ) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : Drop all the sections of students for the career/program and term.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_api_name              CONSTANT VARCHAR2(30)  := 'drop_all_section';
    l_api_version           CONSTANT  NUMBER       := 1.0;

    l_cnst_all          CONSTANT VARCHAR2(5) := 'ALL';
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_return_status     VARCHAR2(10);
    l_error_message     VARCHAR2(1000);
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT drop_all_section;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';

    -- main code logic begins
    igs_en_gen_017.drop_section(
      p_person_number => p_person_number,
      p_career        => p_career       ,
      p_program_code  => p_program_code ,
      p_term_alt_code => p_term_alt_code,
      p_call_number   => NULL           , --This should be null because we want to drop all units.
      p_action        => l_cnst_all     ,
      p_drop_reason   => NULL           ,
      p_adm_status    => NULL           ,
      p_error_message => l_error_message,
      p_return_stat   => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status :=  FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
    END IF;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO drop_all_section;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO drop_all_section;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN OTHERS THEN
      ROLLBACK TO drop_all_section;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data );
  END drop_all_section;

  PROCEDURE drop_section_by_call_number(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    p_drop_reason      IN         VARCHAR2,
    p_adm_status       IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER  ,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : The procedure will drop the section indicated by the student for the selected program/career and term.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'drop_section_by_call_number';
    l_api_version       CONSTANT  NUMBER      := 1.0;

    l_cnst_one          CONSTANT VARCHAR2(5)  := 'ONE';
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_return_status     VARCHAR2(10);
    l_error_message     VARCHAR2(1000);
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT drop_section_by_call_number;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';

    -- main code logic begins
    igs_en_gen_017.drop_section(
      p_person_number => p_person_number,
      p_career        => p_career       ,
      p_program_code  => p_program_code ,
      p_term_alt_code => p_term_alt_code,
      p_call_number   => p_call_number  ,
      p_action        => l_cnst_one     ,
      p_drop_reason   => p_drop_reason  ,
      p_adm_status    => p_adm_status   ,
      p_error_message => l_error_message,
      p_return_stat   => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data
      );
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
    END IF;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO drop_section_by_call_number;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO drop_section_by_call_number;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data  );

    WHEN OTHERS THEN
      ROLLBACK TO drop_section_by_call_number;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => l_message_data );
  END drop_section_by_call_number;

  PROCEDURE evaluate_person_steps(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2,
    p_commit           IN   VARCHAR2,
    p_person_number IN  VARCHAR2,
    p_career        IN  VARCHAR2,
    p_program_code  IN  VARCHAR2,
    p_term_alt_code IN  VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data  OUT NOCOPY VARCHAR2) AS

  /*
  ||  Created By : Nishikant
  ||  Created On : 20JAN2003
  ||  Purpose    : The procedure will evaluate the person steps setup in the system for the
  ||               student to perform enrollment related activities.
  ||               This API is provided to give IVR an option that they can validate these
  ||               at start of Enrollment and if failing then do not allow the student to
  ||               proceed further with his enrollment activities/functions.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    l_api_name           CONSTANT VARCHAR2(30) := 'PERSON_STEPS';

    l_person_id          igs_pe_person_base_v.person_id%TYPE;
    l_person_type        igs_pe_typ_instances.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_ps_ver.course_cd%TYPE;
    l_primary_version    igs_ps_ver.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_message_data       VARCHAR2(2000);
    l_ret_status         VARCHAR2(6);
    l_deny_warn          igs_en_cpd_ext_v.notification_flag%TYPE;
    l_step_eval_result   VARCHAR2(6);

  BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (1.0,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Validate the input parameters and if valid would also fetch the internal calculated
    --values. Validation level here is No Call Number.
    igs_en_gen_017.enrp_validate_input_parameters(
        p_person_number       => p_person_number,
        p_career              => p_career,
        p_program_code        => p_program_code,
        p_term_alt_code       => p_term_alt_code,
        p_call_number         => NULL,
        p_validation_level    => 'NOCALLNUM',
        p_person_id           => l_person_id,
        p_person_type         => l_person_type,
        p_cal_type            => l_cal_type,
        p_ci_sequence_number  => l_ci_sequence_number,
        p_primary_code        => l_primary_code,
        p_primary_version     => l_primary_version,
        p_uoo_id              => l_uoo_id,
        p_error_message       => l_message_data,
        p_ret_status          => l_ret_status );

    --If there is any invalid parameter then log the error message and return with error status
    IF l_ret_status = 'FALSE' THEN
        igs_en_gen_017.enrp_msg_string_to_list (
                 p_message_string => l_message_data,
                 p_delimiter      => ';',
                 p_init_msg_list  => FND_API.G_FALSE,
                 x_message_count  => x_msg_count,
                 x_message_data   => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
        --If the parameters are valid, then call the below procedure to evaluate Person Steps.
        igs_ss_en_wrappers.enrp_ss_val_person_step(
             p_person_id               => l_person_id,
             p_person_type             => l_person_type,
             p_load_cal_type           => l_cal_type,
             p_load_ci_sequence_number => l_ci_sequence_number,
             p_program_cd              => l_primary_code,
             p_program_version         => l_primary_version,
             p_message_name            => l_message_data,
             p_deny_warn               => l_deny_warn,
             p_step_eval_result        => l_step_eval_result,
             p_calling_obj             => 'JOB',
             p_create_warning          => 'N',
             p_ss_session_id           => NULL);

        --If step evaluation result is FALSE then log the error message and return with error status
        IF l_step_eval_result = 'FALSE' THEN
             igs_en_gen_017.enrp_msg_string_to_list (
                   p_message_string => l_message_data,
                   p_delimiter      => ';',
                   p_init_msg_list  => FND_API.G_FALSE,
                   x_message_count  => x_msg_count,
                   x_message_data   => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    IF FND_API.TO_BOOLEAN( p_commit ) THEN
       COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data  );

    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data );
  END evaluate_person_steps;

  PROCEDURE list_schedule(
    p_api_version       IN         NUMBER  ,
    p_init_msg_list     IN         VARCHAR2,
    p_commit            IN         VARCHAR2,
    p_person_number     IN         VARCHAR2,
    p_career            IN         VARCHAR2,
    p_program_code      IN         VARCHAR2,
    p_term_alt_code     IN         VARCHAR2,
    x_schedule_tbl      OUT NOCOPY schedule_tbl_type,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER  ,
    x_msg_data      OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : Returns the student Schedule Details
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        29-04-2003      Modified the cur_schedule_type cursor due to change in the pk of
  ||                                  Student unit attempt w.r.t. bug number 2829262
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'list_schedule';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(10);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_rec_count          NUMBER(15);
    l_status_not_shown   VARCHAR2(100);

    CURSOR cur_schedule_type (
      cp_person_id               igs_pe_person.person_id%TYPE,
      cp_program_cd              igs_en_su_attempt.course_cd%TYPE,
      cp_load_cal_type           igs_ca_inst.cal_type%TYPE,
      cp_load_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
      cp_unit_status_not_shown   VARCHAR2)IS
    SELECT
     sua.unit_cd                                      unit_code              ,
     sua1.unit_class                                  unit_class             ,
     sua.version_number                               unit_version           ,
     ci.alternate_code                                teach_alternate_code   ,
     sua.call_number                                  call_number            ,
     SUBSTR(sua.gradingschema,1,10)                   grading_schema         ,
     sua.creditpoints                                 credit_points          ,
     sua.unit_attempt_status                          unit_attempt_status    ,
     sua.uas_meaning                                  uas_meaning            ,
     sua.uoo_id                                       uoo_id                 ,
     sua.administrative_priority                      administrative_priority
    FROM
     igs_ss_en_sua_dtls_v sua,
     igs_en_su_attempt sua1,
     igs_ca_inst ci
    WHERE
      ci.cal_type = sua.cal_type                  AND
      ci.sequence_number = sua.ci_sequence_number AND
      sua.person_id = cp_person_id                AND
      sua.course_cd = cp_program_cd               AND
      (sua.cal_type ,sua.ci_sequence_number) IN
            (SELECT teach_cal_type,teach_ci_sequence_number
             FROM igs_ca_load_to_teach_v
             WHERE load_cal_type           = cp_load_cal_type AND
                   load_ci_sequence_number = cp_load_ci_sequence_number) AND
      sua.unit_attempt_status NOT IN (cp_unit_status_not_shown) AND
      sua1.person_id          = sua.person_id AND
      sua1.course_cd          = sua.course_cd AND
      sua1.uoo_id             = sua.uoo_id;
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT list_schedule;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';
    l_rec_count := 0;

    --
    -- Main code logic begins
    --

    -- Validate the input parameters.
    igs_en_gen_017.enrp_validate_input_parameters(
      p_person_number      => p_person_number     ,
      p_career             => p_career            ,
      p_program_code       => p_program_code      ,
      p_term_alt_code      => p_term_alt_code     ,
      p_call_number        => NULL         ,
      p_validation_level   => 'NOCALLNUM' ,
      p_person_id          => l_person_id         ,
      p_person_type        => l_person_type       ,
      p_cal_type           => l_cal_type          ,
      p_ci_sequence_number => l_ci_sequence_number,
      p_primary_code       => l_primary_code      ,
      p_primary_version    => l_primary_version   ,
      p_uoo_id             => l_uoo_id            ,
      p_error_message      => l_error_message     ,
      p_ret_status         => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data
       );
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    IF NVL(FND_PROFILE.VALUE('IGS_EN_DISP_DUNIT_STUD'), 'N') = 'Y' THEN
      l_status_not_shown := '''UNCONFIRM''';
    ELSE
      l_status_not_shown := '''UNCONFIRM'', ''DROPPED''';
    END IF;

    FOR rec_schedule_type IN cur_schedule_type(l_person_id, l_primary_code, l_cal_type, l_ci_sequence_number, l_status_not_shown) LOOP
      l_rec_count := l_rec_count + 1;
      x_schedule_tbl(l_rec_count).p_unit_code               := rec_schedule_type.unit_code              ;
      x_schedule_tbl(l_rec_count).p_unit_class              := rec_schedule_type.unit_class             ;
      x_schedule_tbl(l_rec_count).p_unit_version            := rec_schedule_type.unit_version           ;
      x_schedule_tbl(l_rec_count).p_teach_alternate_code    := rec_schedule_type.teach_alternate_code   ;
      x_schedule_tbl(l_rec_count).p_call_Number             := rec_schedule_type.call_Number            ;
      x_schedule_tbl(l_rec_count).p_grading_Schema          := rec_schedule_type.grading_Schema         ;
      x_schedule_tbl(l_rec_count).p_credit_points           := rec_schedule_type.credit_points          ;
      x_schedule_tbl(l_rec_count).p_unit_attempt_status     := rec_schedule_type.unit_attempt_status    ;
      x_schedule_tbl(l_rec_count).p_uas_meaning             := rec_schedule_type.uas_meaning            ;
      x_schedule_tbl(l_rec_count).p_uoo_id                  := rec_schedule_type.uoo_id                 ;
      x_schedule_tbl(l_rec_count).p_administrative_priority := rec_schedule_type.administrative_priority;
    END LOOP;

    --If no records found then returm IGS_EN_NO_SECTION error message with ERROR status.
    IF l_rec_count = 0 THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => 'IGS_EN_NO_SECTION',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
    END IF;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO list_schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO list_schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN OTHERS THEN
      ROLLBACK TO list_schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data );
  END list_schedule;

  PROCEDURE list_section_in_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    x_call_number_tbl  OUT NOCOPY call_number_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER  ,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : Returns the cart contents of student
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'list_section_in_cart';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(10);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_rec_count          NUMBER(15);

    CURSOR cur_call_num (
      cp_person_id               igs_pe_person.person_id%TYPE,
      cp_program_cd              igs_en_su_attempt.course_cd%TYPE,
      cp_load_cal_type           igs_ca_inst.cal_type%TYPE,
      cp_load_ci_sequence_number igs_ca_inst.sequence_number%TYPE)IS
    SELECT sua.call_number
    FROM igs_ss_en_sua_dtls_v sua,
         igs_ca_inst ci
    WHERE
      ci.cal_type = sua.cal_type                  AND
      ci.sequence_number = sua.ci_sequence_number AND
      sua.person_id = cp_person_id                AND
      sua.course_cd = cp_program_cd               AND
      (sua.cal_type ,sua.ci_sequence_number) IN
            (SELECT teach_cal_type,teach_ci_sequence_number
             FROM igs_ca_load_to_teach_v
             WHERE load_cal_type = cp_load_cal_type                          AND
                   load_ci_sequence_number = cp_load_ci_sequence_number)     AND
                   sua.unit_attempt_status IN ('INVALID','UNCONFIRM');
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT list_section_in_cart;

    --Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';
    l_rec_count := 0;

    --
    -- Main code logic begins
    --

    -- Validate the input parameters.
    igs_en_gen_017.enrp_validate_input_parameters(
      p_person_number      => p_person_number     ,
      p_career             => p_career            ,
      p_program_code       => p_program_code      ,
      p_term_alt_code      => p_term_alt_code     ,
      p_call_number        => NULL                ,
      p_validation_level   => 'NOCALLNUM'         ,
      p_person_id          => l_person_id         ,
      p_person_type        => l_person_type       ,
      p_cal_type           => l_cal_type          ,
      p_ci_sequence_number => l_ci_sequence_number,
      p_primary_code       => l_primary_code      ,
      p_primary_version    => l_primary_version   ,
      p_uoo_id             => l_uoo_id            ,
      p_error_message      => l_error_message     ,
      p_ret_status         => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_delimiter      => ';',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    FOR rec_call_num IN cur_call_num(l_person_id, l_primary_code, l_cal_type, l_ci_sequence_number) LOOP
      l_rec_count := l_rec_count + 1;
      x_call_number_tbl(l_rec_count).p_call_number := rec_call_num.call_number;
    END LOOP;

    --If no records found then returm IGS_EN_NO_SECTION error message with ERROR status.
    IF l_rec_count = 0 THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => 'IGS_EN_NO_SECTION',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
    END IF;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO list_section_in_cart;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO list_section_in_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN OTHERS THEN
      ROLLBACK TO list_section_in_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data );
  END list_section_in_cart;

  PROCEDURE remove_from_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER  ,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : Returns the cart contents of student
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'remove_from_cart';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(10);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_rec_count          NUMBER(15);

    CURSOR cur_cart(
      cp_person_id igs_pe_person.person_id%TYPE,
      cp_course_cd igs_en_su_attempt_all.course_cd%TYPE,
      cp_uoo_id    igs_en_su_attempt_all.uoo_id%TYPE)IS
    SELECT sua.rowid
    FROM igs_en_su_attempt_all sua
    WHERE  person_id = cp_person_id AND
           course_cd = cp_course_cd AND
           uoo_id    = cp_uoo_id;
    l_rec_cart cur_cart%ROWTYPE;
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT remove_from_cart;

    --Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';
    l_rec_count := 0;

    --
    -- Main code logic begins
    --

    -- Validate the input parameters.
    igs_en_gen_017.enrp_validate_input_parameters(
      p_person_number      => p_person_number     ,
      p_career             => p_career            ,
      p_program_code       => p_program_code      ,
      p_term_alt_code      => p_term_alt_code     ,
      p_call_number        => p_call_number       ,
      p_validation_level   => 'WITHCALLNUM'       ,
      p_person_id          => l_person_id         ,
      p_person_type        => l_person_type       ,
      p_cal_type           => l_cal_type          ,
      p_ci_sequence_number => l_ci_sequence_number,
      p_primary_code       => l_primary_code      ,
      p_primary_version    => l_primary_version   ,
      p_uoo_id             => l_uoo_id            ,
      p_error_message      => l_error_message     ,
      p_ret_status         => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_delimiter      => ';',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    --
    -- To remove from the cart we need to call the igs_en_su_attempt.delete_row
    --
    OPEN cur_cart(l_person_id, l_primary_code, l_uoo_id);
    FETCH cur_cart INTO l_rec_cart;
      IF cur_cart%FOUND THEN
        igs_en_su_attempt_pkg.delete_row(x_rowid => l_rec_cart.rowid);
      END IF;
    CLOSE cur_cart;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO remove_from_cart;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO remove_from_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN OTHERS THEN
      ROLLBACK TO remove_from_cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data );
  END remove_from_cart;

  PROCEDURE update_enroll_stats(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER  ,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : To Update the statistic in enrollment.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sommukhe    27-JUL-2005  Bug#4344483,Modified the call to igs_ps_unit_ofr_opt_pkg.update_row
  ||                           to include new parameter abort_flag.
  ||  sarakshi    18-Sep-2003  Enh#3052452.Modified the call to igs_ps_unit_ofr_opt_pkg.update_row
  ||                           to include new parameter sup_uoo_id,relation_type,default_enroll_flag
  ||  vvutukur    05-Aug-2003  Enh#3045069.PSP Enh Build. Modified the call to
  ||                           igs_ps_unit_ofr_opt_pkg.update_row to include
  ||                           new parameter not_multiple_section_flag.
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'update_enroll_stats';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(10);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_cal_type           igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE;

    CURSOR cur_enroll_stat(cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE)IS
    SELECT puo.*
    FROM igs_ps_unit_ofr_opt puo
    WHERE puo.uoo_id    = cp_uoo_id;
    l_rec_enroll_stat cur_enroll_stat%ROWTYPE;
  BEGIN
    --Standard start of API savepoint
    SAVEPOINT update_enroll_stats;

    --Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';

    --
    -- Main code logic begins
    --

    -- Validate the input parameters.
    igs_en_gen_017.enrp_validate_input_parameters(
      p_person_number      => p_person_number     ,
      p_career             => p_career            ,
      p_program_code       => p_program_code      ,
      p_term_alt_code      => p_term_alt_code     ,
      p_call_number        => p_call_number       ,
      p_validation_level   => 'WITHCALLNUM'       ,
      p_person_id          => l_person_id         ,
      p_person_type        => l_person_type       ,
      p_cal_type           => l_cal_type          ,
      p_ci_sequence_number => l_ci_sequence_number,
      p_primary_code       => l_primary_code      ,
      p_primary_version    => l_primary_version   ,
      p_uoo_id             => l_uoo_id            ,
      p_error_message      => l_error_message     ,
      p_ret_status         => l_return_status);

    IF l_return_status = 'FALSE' THEN
      -- Add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_delimiter      => ';',
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    --
    -- Fetch the record from IGS_PS_UNIT_OFR_OPT for the fetched uoo_id to update INQ_NOT_WLST coulmn.
    --
    OPEN cur_enroll_stat(l_uoo_id);
    FETCH cur_enroll_stat INTO l_rec_enroll_stat;
    IF cur_enroll_stat%FOUND THEN
      BEGIN
        igs_ps_unit_ofr_opt_pkg.update_row(
          X_ROWID                        => l_rec_enroll_stat.row_id                     ,
          X_UNIT_CD                      => l_rec_enroll_stat.unit_cd                    ,
          X_VERSION_NUMBER               => l_rec_enroll_stat.version_number             ,
          X_CAL_TYPE                     => l_rec_enroll_stat.cal_type                   ,
          X_CI_SEQUENCE_NUMBER           => l_rec_enroll_stat.ci_sequence_number         ,
          X_LOCATION_CD                  => l_rec_enroll_stat.location_cd                ,
          X_UNIT_CLASS                   => l_rec_enroll_stat.unit_class                 ,
          X_UOO_ID                       => l_rec_enroll_stat.uoo_id                     ,
          X_IVRS_AVAILABLE_IND           => l_rec_enroll_stat.ivrs_available_ind         ,
          X_CALL_NUMBER                  => l_rec_enroll_stat.call_number                ,
          X_UNIT_SECTION_STATUS          => l_rec_enroll_stat.unit_section_status        ,
          X_UNIT_SECTION_START_DATE      => l_rec_enroll_stat.unit_section_start_date    ,
          X_UNIT_SECTION_END_DATE        => l_rec_enroll_stat.unit_section_end_date      ,
          X_ENROLLMENT_ACTUAL            => l_rec_enroll_stat.enrollment_actual          ,
          X_WAITLIST_ACTUAL              => l_rec_enroll_stat.waitlist_actual            ,
          X_OFFERED_IND                  => l_rec_enroll_stat.offered_ind                ,
          X_STATE_FINANCIAL_AID          => l_rec_enroll_stat.state_financial_aid        ,
          X_GRADING_SCHEMA_PRCDNCE_IND   => l_rec_enroll_stat.grading_schema_prcdnce_ind ,
          X_FEDERAL_FINANCIAL_AID        => l_rec_enroll_stat.federal_financial_aid      ,
          X_UNIT_QUOTA                   => l_rec_enroll_stat.unit_quota                 ,
          X_UNIT_QUOTA_RESERVED_PLACES   => l_rec_enroll_stat.unit_quota_reserved_places ,
          X_INSTITUTIONAL_FINANCIAL_AID  => l_rec_enroll_stat.institutional_financial_aid,
          X_UNIT_CONTACT                 => l_rec_enroll_stat.unit_contact               ,
          X_GRADING_SCHEMA_CD            => l_rec_enroll_stat.grading_schema_cd          ,
          X_GS_VERSION_NUMBER            => l_rec_enroll_stat.gs_version_number          ,
          X_OWNER_ORG_UNIT_CD            => l_rec_enroll_stat.owner_org_unit_cd          ,
          X_ATTENDANCE_REQUIRED_IND      => l_rec_enroll_stat.attendance_required_ind    ,
          X_RESERVED_SEATING_ALLOWED     => l_rec_enroll_stat.reserved_seating_allowed   ,
          X_SPECIAL_PERMISSION_IND       => l_rec_enroll_stat.special_permission_ind     ,
          X_SS_DISPLAY_IND               => l_rec_enroll_stat.ss_display_ind             ,
          X_SS_ENROL_IND                 => l_rec_enroll_stat.ss_enrol_ind               ,
          X_DIR_ENROLLMENT               => l_rec_enroll_stat.dir_enrollment             ,
          X_ENR_FROM_WLST                => l_rec_enroll_stat.enr_from_wlst              ,
          X_INQ_NOT_WLST                 => NVL(l_rec_enroll_stat.inq_not_wlst,0) + 1    ,
          X_REV_ACCOUNT_CD               => l_rec_enroll_stat.rev_account_cd             ,
          X_ANON_UNIT_GRADING_IND        => l_rec_enroll_stat.anon_unit_grading_ind      ,
          X_ANON_ASSESS_GRADING_IND      => l_rec_enroll_stat.anon_assess_grading_ind    ,
          X_NON_STD_USEC_IND             => l_rec_enroll_stat.non_std_usec_ind           ,
          X_AUDITABLE_IND                => l_rec_enroll_stat.auditable_ind              ,
          X_AUDIT_PERMISSION_IND         => l_rec_enroll_stat.audit_permission_ind       ,
          x_not_multiple_section_flag    => l_rec_enroll_stat.not_multiple_section_flag  ,
          x_sup_uoo_id                   => l_rec_enroll_stat.sup_uoo_id                 ,
          x_relation_type                => l_rec_enroll_stat.relation_type              ,
          x_default_enroll_flag          => l_rec_enroll_stat.default_enroll_flag        ,
          x_abort_flag                   => l_rec_enroll_stat.abort_flag
          );
      END;
    END IF;
    CLOSE cur_enroll_stat;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_enroll_stats;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_enroll_stats;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN OTHERS THEN
      ROLLBACK TO update_enroll_stats;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data );
  END update_enroll_stats;

  PROCEDURE validate_career_program(
    p_api_version     IN         NUMBER  ,
    p_init_msg_list   IN         VARCHAR2,
    p_commit          IN         VARCHAR2,
    p_person_number   IN         VARCHAR2,
    p_career          IN         VARCHAR2,
    p_program_code    IN         VARCHAR2,
    x_primary_code    OUT NOCOPY VARCHAR2,
    x_primary_version OUT NOCOPY NUMBER  ,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count   OUT NOCOPY NUMBER  ,
    x_msg_data    OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : Nalin Kumar
  ||  Created On : 16-Jan-2003
  ||  Purpose    : Validate that the career is valid for the student.
  ||             This procedure will validate the input career/program details.
  ||             It accepts the person and career/program details and verifies if
  ||             the career is active for student. (Active means that the program
  ||             attempt status with 'ENROLLED' or 'INACTIVE' status exists). If
  ||             valid then the procedure will return with success status and the
  ||             primary program code and version (for career mode) else will
  ||             return with error.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  stutta       27-NOV-2003    Changed the call to igs_ss_enr_details.enrp_get_prgm_for_career
  ||                              by passing in two new parameters.
  */
    l_api_name          CONSTANT VARCHAR2(30) := 'validate_career_program';
    l_api_version       CONSTANT  NUMBER      := 1.0;
    l_messaage_count    NUMBER(15);
    l_message_data      VARCHAR2(1000);
    l_error_message     VARCHAR2(1000);
    l_return_status     VARCHAR2(1000);

    l_person_id          igs_pe_person.person_id%TYPE;
    l_person_type        igs_pe_person_types.person_type_code%TYPE;
    l_primary_code       igs_en_su_attempt_all.course_cd%TYPE;
    l_primary_version    igs_en_su_attempt_all.version_number%TYPE;
    l_programlist        VARCHAR2(1000);

    CURSOR cur_get_ver(
      cp_person_id igs_pe_person.person_id%TYPE,
      cp_course_cd igs_en_su_attempt_all.course_cd%TYPE) IS
    SELECT version_number
    FROM igs_en_stdnt_ps_att
    WHERE person_id = cp_person_id AND
          course_cd = cp_course_cd;
    l_rec_ver cur_get_ver%ROWTYPE;

  BEGIN
    --Standard start of API savepoint
    SAVEPOINT validate_career_program;

    --Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'TRUE';

    --
    -- Main code logic begins
    --
    -- Validate Person Number
    igs_en_gen_017.enrp_validate_student(
      p_person_number => p_person_number,
      p_person_id     => l_person_id    ,
      p_person_type   => l_person_type  ,
      p_error_message => l_error_message,
      p_ret_status    => l_return_status);
    IF l_return_status = 'FALSE' THEN
      -- add to msg stack
      igs_en_gen_017.enrp_msg_string_to_list(
        p_message_string => l_error_message,
        p_init_msg_list  => FND_API.G_FALSE,
        x_message_count  => l_messaage_count,
        x_message_data   => l_message_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_messaage_count;
      x_msg_data  := l_message_data;
      RETURN;
    END IF;

    -- Check the career model, if it is enabled then get the primary program...
    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' THEN
      IF p_career IS NULL THEN
        igs_en_gen_017.enrp_msg_string_to_list(
          p_message_string => 'IGS_EN_NO_CAREER',
          p_init_msg_list  => FND_API.G_FALSE,
          x_message_count  => l_messaage_count,
          x_message_data   => l_message_data);

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_messaage_count;
        x_msg_data  := l_message_data;
        RETURN;
      END IF;

      -- Get the primary program and if not found then error out...
      igs_ss_enr_details.enrp_get_prgm_for_career(
        p_person_id               => l_person_id      ,
        p_carrer                  => p_career         ,
        p_primary_program         => l_primary_code   ,
        p_primary_program_version => l_primary_version,
        p_programlist             => l_programlist,
        p_term_cal_type           => NULL,
        p_term_sequence_number    => NULL);
      IF l_primary_code IS NULL THEN
        igs_en_gen_017.enrp_msg_string_to_list(
          p_message_string => 'IGS_SS_EN_NO_CAREER',
          p_init_msg_list  => FND_API.G_FALSE,
          x_message_count  => l_messaage_count,
          x_message_data   => l_message_data);

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_messaage_count;
        x_msg_data  := l_message_data;
        RETURN;
      END IF;
      x_primary_code    := l_primary_code;
      x_primary_version := l_primary_version;
    ELSE
      IF p_program_code IS NULL THEN
        igs_en_gen_017.enrp_msg_string_to_list(
          p_message_string => 'IGS_EN_NO_PROGRAM',
          p_init_msg_list  => FND_API.G_FALSE,
          x_message_count  => l_messaage_count,
          x_message_data   => l_message_data);

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_messaage_count;
        x_msg_data  := l_message_data;
        RETURN;
      END IF;

      -- Validate that the input person number and program correspond to a valid program attempt.
      OPEN cur_get_ver(l_person_id, p_program_code);
      FETCH cur_get_ver INTO l_rec_ver;
      IF cur_get_ver%NOTFOUND THEN
        igs_en_gen_017.enrp_msg_string_to_list(
          p_message_string => 'IGS_EN_NO_ACTIVE_PROGRAM',
          p_init_msg_list  => FND_API.G_FALSE,
          x_message_count  => l_messaage_count,
          x_message_data   => l_message_data);

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_messaage_count;
        x_msg_data  := l_message_data;
        RETURN;
      ELSE
        x_primary_code    := p_program_code;
        x_primary_version := l_rec_ver.version_number;
      END IF;
      CLOSE cur_get_ver;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := NULL;
      x_msg_data  := NULL;
      RETURN;
    END IF;

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => l_messaage_count,
      p_data  => l_message_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_career_program;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_career_program;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data  );

    WHEN OTHERS THEN
      ROLLBACK TO validate_career_program;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,l_api_name );
      END IF;
      FND_MSG_PUB.COUNT_AND_GET (
        p_count => x_msg_count,
        p_data  => x_msg_data );
  END validate_career_program;

  PROCEDURE validate_person_details(
       p_api_version                 IN NUMBER,
       p_init_msg_list               IN VARCHAR2 ,
       p_commit                      IN VARCHAR2 ,
       p_person_number               IN VARCHAR2 ,
       x_default_term_alt_code       OUT NOCOPY VARCHAR2,
       x_career_tbl                  OUT NOCOPY career_tbl_type,
       x_term_tbl                    OUT NOCOPY term_tbl_type,
       x_multiple_career_program     OUT NOCOPY VARCHAR2,
       x_return_status               OUT NOCOPY VARCHAR2,
       x_msg_count                   OUT NOCOPY NUMBER,
       x_msg_data                    OUT NOCOPY VARCHAR2
      )
  /******************************************************************************************
  ||  Created By : smanglm
  ||  Created On : 2003/01/15
  ||  Purpose : The procedure will validate the input person number.
  ||           (It will verify that we have an fnd user for input person, person is a valid
  ||           student). If not valid it will return error message and return status as error.
  ||           If valid then it will also return the default term, term list in pl/sql table,
  ||           program_career_list in pl/sql table and indicator whether single or multiple
  ||           career/program. These return values will help the 3rd party (IVR) in proceeding
  ||           further with getting the term and career/program selected by student with
  ||           minimum OSS interaction.
  ||           This procedure will also validate the basic assumption that term is setup for
  ||           IVR and student has at least one active career/program to perform enrollment
  ||           activities. If any of these were not valid it would return with error message.
  ||           This is an API published /available to 3rd party
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************************************/
  IS
  l_api_name              CONSTANT VARCHAR2(30)  := 'validate_person_details';
  l_api_version           CONSTANT  NUMBER       := 1.0;

  -- local variables
  l_person_id                 igs_pe_person.person_id%TYPE;
  l_person_type               igs_pe_typ_instances.person_type_code%TYPE;
  l_error_message             VARCHAR2(2000):= NULL;
  l_ret_status                VARCHAR2(10) := 'TRUE';

  l_message_count             NUMBER;
  l_message_data              VARCHAR2(4000);

  l_rec_count                 NUMBER:=0;

  /*
     cursor to get career mode details
  */
  CURSOR  c_career_mode  (lc_person_id igs_pe_person.person_id%TYPE) IS
          SELECT course_type,
           course_cd,
           version_number
    FROM   igs_en_sca_v
    WHERE  primary_program_type ='PRIMARY'
    AND Course_attempt_status IN ('ENROLLED','INACTIVE')
    AND person_id = lc_person_id;

  /*
     cursor to get program mode details
  */
  CURSOR  c_program_mode (lc_person_id igs_pe_person.person_id%TYPE) IS
          SELECT course_type,
           course_cd,
           version_number
    FROM   igs_en_sca_v
    WHERE  course_attempt_status IN ('ENROLLED','INACTIVE')
    AND person_id = lc_person_id;

  BEGIN  -- main begin

  --Standard start of API savepoint
        SAVEPOINT validate_person_details;

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
        /*
     validate person_number
  */
        igs_en_gen_017.enrp_validate_student
                (
           p_person_number => p_person_number,
           p_person_id     => l_person_id    ,
           p_person_type   => l_person_type  ,
           p_error_message => l_error_message,
           p_ret_status    => l_ret_status
        );
        IF l_ret_status = 'FALSE' THEN
           -- add to msg stack
     igs_en_gen_017.enrp_msg_string_to_list
                   (
                           p_message_string => l_error_message,
                           p_init_msg_list  => FND_API.G_FALSE,
                           x_message_count  => l_message_count,
                           x_message_data   => l_message_data
       );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
        END IF;

  /*
     determine default term
  */
  l_error_message := NULL;
  l_ret_status := 'TRUE';
  igs_en_gen_017.enrp_get_default_term(
    p_term_alt_code => x_default_term_alt_code,
    p_error_message => l_error_message,
    p_ret_status    => l_ret_status);
  /*
     no error loggin as x_default_term_alt_code is optional parameter
  */
  l_error_message := NULL;
  l_ret_status := 'TRUE';
  /*
   get list of term calendars
  */
  igs_en_gen_017.enrp_get_term_ivr_list
                      (
                  p_term_tbl  => x_term_tbl,
                        p_error_message => l_error_message,
                        p_ret_status    => l_ret_status
          );
        IF l_ret_status = 'FALSE' THEN
           -- add to msg stack
     igs_en_gen_017.enrp_msg_string_to_list
                   (
                           p_message_string => l_error_message,
                           p_init_msg_list  => FND_API.G_FALSE,
                           x_message_count  => l_message_count,
                           x_message_data   => l_message_data
       );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
        END IF;
  /*
            Determine if single or multiple program for the student
      and set the career_program pl/sql table
  */
        IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' THEN
           -- career
           FOR rec_career_mode IN c_career_mode(l_person_id)
     LOOP
        l_rec_count := l_rec_count + 1;
        x_career_tbl(l_rec_count).p_career := rec_career_mode.course_type;
        x_career_tbl(l_rec_count).p_program_code := rec_career_mode.course_cd;
        x_career_tbl(l_rec_count).p_version_number := rec_career_mode.version_number;
     END LOOP;
  ELSE
   FOR rec_program_mode IN c_program_mode(l_person_id)
     LOOP
        l_rec_count := l_rec_count + 1;
        x_career_tbl(l_rec_count).p_career := rec_program_mode.course_type;
        x_career_tbl(l_rec_count).p_program_code := rec_program_mode.course_cd;
        x_career_tbl(l_rec_count).p_version_number := rec_program_mode.version_number;
     END LOOP;
  END IF;
        IF l_rec_count = 0 THEN
     igs_en_gen_017.enrp_msg_string_to_list
                   (
                           p_message_string => 'IGS_SS_EN_NO_CONF_PRG',
                           p_init_msg_list  => FND_API.G_FALSE,
                           x_message_count  => l_message_count,
                           x_message_data   => l_message_data
       );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
        ELSIF l_rec_count = 1 THEN
     x_multiple_career_program := 'N';
  ELSIF l_rec_count >= 2 THEN
     x_multiple_career_program := 'Y';
  END IF;



  --Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

  --Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO validate_person_details;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                            p_count => x_msg_count,
                            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_person_details;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get(
                            p_count => x_msg_count,
                            p_data  => x_msg_data);
    WHEN OTHERS THEN
            ROLLBACK TO validate_person_details;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(
                            p_count => x_msg_count,
                            p_data  => x_msg_data);

  END validate_person_details;

  PROCEDURE validate_term(
                p_api_version     IN NUMBER,
                p_init_msg_list   IN VARCHAR2,
                p_commit           IN   VARCHAR2,
                p_term_alt_code   IN VARCHAR2,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count   OUT NOCOPY NUMBER  ,
                x_msg_data    OUT NOCOPY VARCHAR2) AS
    /*
    ||  Created By : Nishikant
    ||  Created On : 15JAN2003
    ||  Purpose    : The procedure is public  procedure to validate that the term
    ||               passed by 3rd party s/w is valid term in system or not.
    ||               If its a valid term calendar then return with null error message
    ||               Else return with error message.
    ||
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  l_api_name           CONSTANT VARCHAR2(30) := 'VALIDATE_TERM';
  l_api_version        CONSTANT NUMBER := 1.0;
  l_cal_type           igs_ca_inst.cal_type%TYPE;
  l_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_message            fnd_new_messages.message_name%TYPE;
  l_ret_status         VARCHAR2(6);
  l_message_count      NUMBER;
  l_message_data       VARCHAR2(2000);

  BEGIN

      -- Standard call to check for call compatibility.
      IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name ) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
           FND_MSG_PUB.INITIALIZE;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --Validate the p_term_alt_code parameter by calling the procedure enrp_validate_term_alt_code.
      --This procedure will validate the parameter and also return the cal_type and seq_number (which is of no use here.)
      igs_en_gen_017.enrp_validate_term_alt_code(
           p_term_alt_code      => p_term_alt_code,
           p_cal_type           => l_cal_type,
           p_ci_sequence_number => l_ci_sequence_number,
           p_error_message      => l_message,
           p_ret_status         => l_ret_status);

      IF l_ret_status = 'FALSE' THEN
      -- If the above function returns the l_ret_status parameter as FALSE then
      -- Call the function enrp_msg_string_to_list to set the error message. And set the return status to Error.
           igs_en_gen_017.enrp_msg_string_to_list (
                     p_message_string => l_message,
                     p_delimiter      => ';',
                     p_init_msg_list  => FND_API.G_FALSE,
                     x_message_count  => l_message_count,
                     x_message_data   => l_message_data);

           --Set the Message Count and Message Data parameters to the out parameter of the above procedure call;
           x_msg_count := l_message_count;
           x_msg_data := l_message_data;
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF FND_API.TO_BOOLEAN( p_commit ) THEN
         COMMIT WORK;
      END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data  );

    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.COUNT_AND_GET (
                    p_count => x_msg_count,
                    p_data  => x_msg_data );
  END validate_term;

  PROCEDURE waitlist(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2,
    p_commit             IN  VARCHAR2,
    p_person_number      IN  VARCHAR2,
    p_career             IN  VARCHAR2,
    p_program_code       IN  VARCHAR2,
    p_term_alt_code      IN  VARCHAR2,
    p_call_number        IN  NUMBER,
    p_audit_ind          IN  VARCHAR2,
    p_waitlist           IN  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2 ) AS
  /*
  ||  Created By : Nishikant
  ||  Created On : 23JAN2003
  ||  Purpose    : The procedure will waitlist the student in the section.
  ||               It will accept the call number of section to added
  ||               (along with other context parameters).
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-Jul-2003     Call to rollback is added to the procedure if igs_en_gen_017.add_to_cart_waitlist
  ||                                  sets the out p_ret_status parameter to false. Bug : 3036949
  ||  (reverse chronological order - newest change first)
  */
    l_api_name           CONSTANT VARCHAR2(30) := 'WAITLIST';
    l_ret_status         VARCHAR2(6) := NULL;
    l_message_data       VARCHAR2(2000);
    l_waitlist           VARCHAR2(1);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  WAITLIST_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (1.0,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_waitlist := p_waitlist;

    --Invoke the procedure add_to_cart_waitlist by passing the relevant parameters.
    --Parameter p_action should be 'WLIST' in this case and the parameter p_waitlist_ind
    --is an IN/OUT variable hance an out value can be expected, which can be ignored.
    --The invoke source parameter should have 'IVR' as the input.
    igs_en_gen_017.add_to_cart_waitlist (
        p_person_number => p_person_number,
        p_career        => p_career,
        p_program_code  => p_program_code,
        p_term_alt_code => p_term_alt_code,
        p_call_number   => p_call_number,
        p_audit_ind     => p_audit_ind,
        p_waitlist_ind  => l_waitlist,
        p_action        => 'WLIST',
        p_error_message => l_message_data,
        p_ret_status    => l_ret_status);

    --If return status is FALSE above then log error message and RETURN.
    IF l_ret_status = 'FALSE' THEN
        ROLLBACK TO WAITLIST_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        igs_en_gen_017.enrp_msg_string_to_list (
             p_message_string => l_message_data,
             p_delimiter      => ';',
             p_init_msg_list  => FND_API.G_FALSE,
             x_message_count  => x_msg_count,
             x_message_data   => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR ;
    ELSE
        IF FND_API.TO_BOOLEAN( p_commit ) THEN
              COMMIT WORK;
        END IF;
    END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO WAITLIST_PUB;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.COUNT_AND_GET (
                     p_count => x_msg_count,
                     p_data  => x_msg_data  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO WAITLIST_PUB;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.COUNT_AND_GET (
                     p_count => x_msg_count,
                     p_data  => x_msg_data  );

     WHEN OTHERS THEN
             ROLLBACK TO WAITLIST_PUB;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.COUNT_AND_GET (
                     p_count => x_msg_count,
                     p_data  => x_msg_data );
  END waitlist;

END igs_en_ivr_pub;

/
