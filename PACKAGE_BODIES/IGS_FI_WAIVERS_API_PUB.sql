--------------------------------------------------------
--  DDL for Package Body IGS_FI_WAIVERS_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_WAIVERS_API_PUB" AS
/* $Header: IGSFI94B.pls 120.3 2005/10/31 10:33:51 appldev noship $ */
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 29 July 2005
--
--Purpose: Public Waiver API
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--
------------------------------------------------------------------
  g_pkg_name     CONSTANT VARCHAR2(30) := 'igs_fi_waivers_api_pub';

  -- Procedure for validating all inbound parameters to API
  PROCEDURE validate_parameters(
    p_fee_cal_type        IN  igs_ca_inst_all.cal_type%TYPE        ,
    p_fee_ci_seq_number   IN  igs_ca_inst_all.sequence_number%TYPE ,
    p_waiver_name         IN  igs_fi_waiver_pgms.waiver_name%TYPE  ,
    p_person_id           IN  igs_fi_credits_all.party_id%TYPE     ,
    p_waiver_amount       IN  igs_fi_credits_all.amount%TYPE       ,
    p_currency_cd         IN  igs_fi_credits_all.currency_cd%TYPE  ,
    p_gl_date             IN  igs_fi_credits_all.gl_date%TYPE      ,
    p_source_credit_id    IN  igs_fi_credits_all.credit_id%TYPE    ,
    p_b_return_status     OUT  NOCOPY  BOOLEAN
  );

  -- Procedure for enabling statement level logging
  PROCEDURE log_to_fnd (
    p_v_module IN VARCHAR2,
    p_v_string IN VARCHAR2
  );

  CURSOR c_waiver_pgms  (
    cp_v_fee_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
    cp_n_fee_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
    cp_v_waiver_name         IN  igs_fi_waiver_pgms.waiver_name%TYPE
  ) IS
  SELECT  fwp.fee_cal_type
         ,fwp.fee_ci_sequence_number
         ,fwp.waiver_name
         ,fwp.waiver_method_code
         ,fwp.waiver_status_code
         ,fwp.credit_type_id
         ,fwp.target_fee_type
         ,fwp.adjustment_fee_type
         ,fwp.waiver_mode_code
  FROM    igs_fi_waiver_pgms fwp
  WHERE   fwp.fee_cal_type           =  cp_v_fee_cal_type
  AND     fwp.fee_ci_sequence_number =  cp_n_fee_sequence_number
  AND     fwp.waiver_name            =  cp_v_waiver_name;



PROCEDURE create_manual_waivers(
  p_api_version           IN           NUMBER                                ,
  p_init_msg_list         IN           VARCHAR2                              ,
  p_commit                IN           VARCHAR2                              ,
  x_return_status         OUT  NOCOPY  VARCHAR2                              ,
  x_msg_count             OUT  NOCOPY  NUMBER                                ,
  x_msg_data              OUT  NOCOPY  VARCHAR2                              ,
  p_fee_cal_type          IN           igs_ca_inst_all.cal_type%TYPE         ,
  p_fee_ci_seq_number     IN           igs_ca_inst_all.sequence_number%TYPE  ,
  p_waiver_name           IN           igs_fi_waiver_pgms.waiver_name%TYPE   ,
  p_person_id             IN           igs_fi_credits_all.party_id%TYPE      ,
  p_waiver_amount         IN           igs_fi_credits_all.amount%TYPE        ,
  p_currency_cd           IN           igs_fi_credits_all.currency_cd%TYPE   ,
  p_exchange_rate         IN           igs_fi_credits_all.exchange_rate%TYPE ,
  p_gl_date               IN           igs_fi_credits_all.gl_date%TYPE       ,
  p_source_credit_id      IN           igs_fi_credits_all.credit_id%TYPE     ,
  x_waiver_credit_id      OUT  NOCOPY  NUMBER                                ,
  x_waiver_adjustment_id  OUT  NOCOPY  NUMBER
) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 29 July 2005
--
-- Purpose     : procedure for importing Waiver Credits and
--               Waiver Charge Adjustments
-- Invoked     : from  External Source
-- Function    :
--
-- Parameters  : p_api_version          : IN parameter. Required.
--               p_init_msg_list        : IN parameter
--               p_commit               : IN parameter
--               x_return_status        : OUT parameter
--               x_msg_count            : OUT parameter
--               x_msg_data             : OUT parameter
--               p_fee_cal_type         : IN parameter. Required
--               p_fee_ci_seq_number    : IN parameter. Required
--               p_waiver_name          : IN parameter. Required.
--               p_person_id            : IN parameter. Required.
--               p_waiver_amount        : IN parameter. Required
--               p_currency_cd          : IN parameter. Required
--               p_exchange_rate        : IN parameter. Required
--               p_gl_date              : IN parameter. Required
--               p_source_credit_id     : IN parameter. Optional
--               x_waiver_credit_id     : OUT parameter
--               x_waiver_adjustment_id : OUT parameter
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'create_manual_waivers';

  rec_c_waiver_pgms            c_waiver_pgms%ROWTYPE;

  l_v_manage_accounts          igs_fi_control_all.manage_accounts%TYPE;
  l_v_message_name             fnd_new_messages.message_name%TYPE;
  l_v_return_status            VARCHAR2(1);

  l_n_conv_process_run_ind     igs_fi_control_all.conv_process_run_ind%TYPE;
  l_n_version_number           igs_fi_balance_rules.version_number%TYPE;
  l_n_balance_rule_id          igs_fi_balance_rules.balance_rule_id%TYPE;
  l_n_credit_id                igs_fi_credits_all.credit_id%TYPE;
  l_n_invoice_id               igs_fi_inv_int_all.invoice_id%TYPE;

  l_d_last_conversion_date     DATE;

  l_b_return_status            BOOLEAN;
BEGIN
  --Standard start of API savepoint
  SAVEPOINT create_manual_waivers_pub;

  log_to_fnd(p_v_module => 'create_manual_waivers',
             p_v_string => ' Entered Procedure create_manual_waivers: The input parameters are '||
                           ' p_api_version         : '  ||p_api_version          ||
                           ' p_init_msg_list       : '  ||p_init_msg_list        ||
                           ' p_commit              : '  ||p_commit               ||
                           ' p_fee_cal_type        : '  ||p_fee_cal_type         ||
                           ' p_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                           ' p_waiver_name         : '  ||p_waiver_name          ||
                           ' p_person_id           : '  ||p_person_id            ||
                           ' p_waiver_amount       : '  ||p_waiver_amount        ||
                           ' p_currency_cd         : '  ||p_currency_cd          ||
                           ' p_exchange_rate       : '  ||p_exchange_rate        ||
                           ' p_gl_date             : '  ||p_gl_date              ||
                           ' p_source_credit_id    : '  ||p_source_credit_id
            );

  --Standard call to check for call compatibility
  IF NOT fnd_api.compatible_api_call(
    p_current_version_number => l_api_version,
    p_caller_version_number  => p_api_version,
    p_api_name               => l_api_name,
    p_pkg_name               => g_pkg_name
  ) THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  --Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  ----------------------- Start of API Body---------------------------

  -- Verify the value of Manage Accounts set in System Options form.
  -- If this value is either NULL or OTHER, API would error out
  igs_fi_com_rec_interface.chk_manage_account (
    p_v_manage_acc   => l_v_manage_accounts,
    p_v_message_name => l_v_message_name
  );
  IF (l_v_manage_accounts IS NULL OR l_v_manage_accounts = 'OTHER') THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name ( 'IGS', l_v_message_name );
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  -- Verify if holds conversion process is currently being executed
  -- The API would error out if holds conversion process is currently
  -- being executed
  l_v_message_name := NULL;
  igs_fi_gen_007.finp_get_conv_prc_run_ind(
    p_n_conv_process_run_ind => l_n_conv_process_run_ind,
    p_v_message_name         => l_v_message_name
  );
  IF l_n_conv_process_run_ind = 1 AND l_v_message_name IS NULL THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;
  IF l_v_message_name IS NOT NULL THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  -- Verify if active balance rule for holds balance type has been set up
  -- in the balance rules form
  igs_fi_gen_007.finp_get_balance_rule(
    p_v_balance_type         => 'HOLDS',
    p_v_action               => 'ACTIVE',
    p_n_balance_rule_id      => l_n_balance_rule_id,
    p_d_last_conversion_date => l_d_last_conversion_date,
    p_n_version_number       => l_n_version_number
  );
  --If no active holds balance rule exists, API would error out
  IF l_n_version_number = 0 THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS','IGS_FI_CANNOT_CRT_TXN');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  -- Validate all the inbound parameters to API
  validate_parameters(
    p_fee_cal_type        =>  p_fee_cal_type      ,
    p_fee_ci_seq_number   =>  p_fee_ci_seq_number ,
    p_waiver_name         =>  p_waiver_name       ,
    p_person_id           =>  p_person_id         ,
    p_waiver_amount       =>  p_waiver_amount     ,
    p_currency_cd         =>  p_currency_cd       ,
    p_gl_date             =>  p_gl_date           ,
    p_source_credit_id    =>  p_source_credit_id  ,
    p_b_return_status     =>  l_b_return_status
  );
  IF NOT (l_b_return_status) THEN
      RAISE fnd_api.g_exc_error;
  END IF;

  OPEN c_waiver_pgms (
    cp_v_fee_cal_type        => p_fee_cal_type      ,
    cp_n_fee_sequence_number => p_fee_ci_seq_number ,
    cp_v_waiver_name         => p_waiver_name
  );
  FETCH c_waiver_pgms INTO rec_c_waiver_pgms;
  CLOSE c_waiver_pgms;

  IF p_waiver_amount > 0 THEN

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Invoking Procedure igs_fi_wav_utils_002.call_credits_api with input parameters '||
                             ' p_n_person_id           : '  ||p_person_id            ||
                             ' p_v_fee_cal_type        : '  ||p_fee_cal_type         ||
                             ' p_n_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                             ' p_v_waiver_name         : '  ||p_waiver_name          ||
                             ' p_n_credit_type_id      : '  ||rec_c_waiver_pgms.credit_type_id ||
                             ' p_v_currency_cd         : '  ||p_currency_cd          ||
                             ' p_n_waiver_amt          : '  ||p_waiver_amount        ||
                             ' p_d_gl_date             : '  ||p_gl_date
              );

    -- invoke the credits api to create the waiver credit
    igs_fi_wav_utils_002.call_credits_api (
      p_n_person_id          =>  p_person_id                           ,
      p_v_fee_cal_type       =>  p_fee_cal_type                        ,
      p_n_fee_ci_seq_number  =>  p_fee_ci_seq_number                   ,
      p_v_waiver_name        =>  p_waiver_name                         ,
      p_n_credit_type_id     =>  rec_c_waiver_pgms.credit_type_id      ,
      p_v_currency_cd        =>  p_currency_cd                         ,
      p_n_waiver_amt         =>  p_waiver_amount                       ,
      p_d_gl_date            =>  p_gl_date                             ,
      p_n_credit_id          =>  l_n_credit_id                         ,
      x_return_status        =>  l_v_return_status
    );
    IF l_v_return_status <> 'S' THEN
      log_to_fnd(p_v_module => 'create_manual_waivers',
                 p_v_string => ' Procedure igs_fi_wav_utils_002.call_credits_api errored out'
                );
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Procedure igs_fi_wav_utils_002.call_credits_api returned success'||
                             ' p_n_credit_id           : '  ||l_n_credit_id
              );

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Invoking Procedure igs_fi_wav_utils_001.apply_waivers with input parameters '||
                             ' p_n_person_id           : '  ||p_person_id            ||
                             ' p_v_fee_cal_type        : '  ||p_fee_cal_type         ||
                             ' p_n_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                             ' p_v_waiver_name         : '  ||p_waiver_name          ||
                             ' p_v_target_fee_type     : '  ||rec_c_waiver_pgms.target_fee_type     ||
                             ' p_v_adj_fee_type        : '  ||rec_c_waiver_pgms.adjustment_fee_type ||
                             ' p_v_waiver_method_code  : '  ||rec_c_waiver_pgms.waiver_method_code  ||
                             ' p_v_waiver_mode_code    : '  ||rec_c_waiver_pgms.waiver_mode_code    ||
                             ' p_v_currency_cd         : '  ||p_currency_cd          ||
                             ' p_d_gl_date             : '  ||p_gl_date
              );

    l_v_return_status := NULL;

    -- invoke apply waiver routine
    igs_fi_wav_utils_001.apply_waivers (
      p_n_person_id          =>  p_person_id                           ,
      p_v_fee_cal_type       =>  p_fee_cal_type                        ,
      p_n_fee_ci_seq_number  =>  p_fee_ci_seq_number                   ,
      p_v_waiver_name        =>  p_waiver_name                         ,
      p_v_target_fee_type    =>  rec_c_waiver_pgms.target_fee_type     ,
      p_v_adj_fee_type       =>  rec_c_waiver_pgms.adjustment_fee_type ,
      p_v_waiver_method_code =>  rec_c_waiver_pgms.waiver_method_code  ,
      p_v_waiver_mode_code   =>  rec_c_waiver_pgms.waiver_mode_code    ,
      p_n_source_credit_id   =>  l_n_credit_id                         ,
      p_n_source_invoice_id  =>  NULL                                  ,
      p_v_currency_cd        =>  p_currency_cd                         ,
      p_d_gl_date            =>  p_gl_date                             ,
      x_return_status        =>  l_v_return_status
    );

    IF l_v_return_status <> 'S' THEN
      log_to_fnd(p_v_module => 'create_manual_waivers',
                 p_v_string => ' Procedure igs_fi_wav_utils_001.apply_waivers errored out'
                );
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_waiver_credit_id := l_n_credit_id;

  ELSIF p_waiver_amount < 0 THEN

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Invoking Procedure igs_fi_wav_utils_002.call_charges_api with input parameters '||
                             ' p_n_person_id           : '  ||p_person_id            ||
                             ' p_v_fee_cal_type        : '  ||p_fee_cal_type         ||
                             ' p_n_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                             ' p_v_waiver_name         : '  ||p_waiver_name          ||
                             ' p_v_adj_fee_type        : '  ||rec_c_waiver_pgms.adjustment_fee_type ||
                             ' p_v_currency_cd         : '  ||p_currency_cd          ||
                             ' p_n_waiver_amt          : '  ||p_waiver_amount        ||
                             ' p_d_gl_date             : '  ||p_gl_date
              );

    -- invoke the charges api to create the waiver adjustment charge
    igs_fi_wav_utils_002.call_charges_api (
      p_n_person_id          =>  p_person_id                           ,
      p_v_fee_cal_type       =>  p_fee_cal_type                        ,
      p_n_fee_ci_seq_number  =>  p_fee_ci_seq_number                   ,
      p_v_waiver_name        =>  p_waiver_name                         ,
      p_v_adj_fee_type       =>  rec_c_waiver_pgms.adjustment_fee_type ,
      p_v_currency_cd        =>  p_currency_cd                         ,
      p_n_waiver_amt         =>  ABS(p_waiver_amount)                  ,
      p_d_gl_date            =>  p_gl_date                             ,
      p_n_invoice_id         =>  l_n_invoice_id                        ,
      x_return_status        =>  l_v_return_status
    );

    IF l_v_return_status <> 'S' THEN
      log_to_fnd(p_v_module => 'create_manual_waivers',
                 p_v_string => ' Procedure igs_fi_wav_utils_002.call_charges_api errored out'
                );
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Procedure igs_fi_wav_utils_002.call_charges_api returned success'||
                             ' p_n_invoice_id           : '  ||l_n_invoice_id
              );

    log_to_fnd(p_v_module => 'create_manual_waivers',
               p_v_string => ' Invoking Procedure igs_fi_wav_utils_001.apply_waivers with input parameters '||
                             ' p_n_person_id           : '  ||p_person_id            ||
                             ' p_v_fee_cal_type        : '  ||p_fee_cal_type         ||
                             ' p_n_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                             ' p_v_waiver_name         : '  ||p_waiver_name          ||
                             ' p_v_target_fee_type     : '  ||rec_c_waiver_pgms.target_fee_type     ||
                             ' p_v_adj_fee_type        : '  ||rec_c_waiver_pgms.adjustment_fee_type ||
                             ' p_v_waiver_method_code  : '  ||rec_c_waiver_pgms.waiver_method_code  ||
                             ' p_v_waiver_mode_code    : '  ||rec_c_waiver_pgms.waiver_mode_code    ||
                             ' p_v_currency_cd         : '  ||p_currency_cd          ||
                             ' p_d_gl_date             : '  ||p_gl_date
              );

    l_v_return_status := NULL;

    -- invoke apply waiver routine
    igs_fi_wav_utils_001.apply_waivers (
      p_n_person_id          =>  p_person_id                           ,
      p_v_fee_cal_type       =>  p_fee_cal_type                        ,
      p_n_fee_ci_seq_number  =>  p_fee_ci_seq_number                   ,
      p_v_waiver_name        =>  p_waiver_name                         ,
      p_v_target_fee_type    =>  rec_c_waiver_pgms.target_fee_type     ,
      p_v_adj_fee_type       =>  rec_c_waiver_pgms.adjustment_fee_type ,
      p_v_waiver_method_code =>  rec_c_waiver_pgms.waiver_method_code  ,
      p_v_waiver_mode_code   =>  rec_c_waiver_pgms.waiver_mode_code    ,
      p_n_source_credit_id   =>  p_source_credit_id                    ,
      p_n_source_invoice_id  =>  NULL                                  ,
      p_v_currency_cd        =>  p_currency_cd                         ,
      p_d_gl_date            =>  p_gl_date                             ,
      x_return_status        =>  l_v_return_status
    );

    IF l_v_return_status <> 'S' THEN
      log_to_fnd(p_v_module => 'create_manual_waivers',
                 p_v_string => ' Procedure igs_fi_wav_utils_001.apply_waivers errored out'
                );
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    x_waiver_adjustment_id := l_n_invoice_id;
  END IF;

  ----------------------- End of API Body---------------------------

  -- Standard check of p_commit
  IF fnd_api.to_boolean( p_commit) THEN
    COMMIT WORK;
  END IF;

  --Standard call to get message count and if count is 1, get message info.
  fnd_msg_pub.count_and_get(
    p_count  => x_msg_count,
    p_data   => x_msg_data
  );
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO  create_manual_waivers_pub;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(
      p_count  => x_msg_count ,
      p_data   => x_msg_data
    );
  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO create_manual_waivers_pub ;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(
      p_count  => x_msg_count ,
      p_data   => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO create_manual_waivers_pub ;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_waivers_api_pub.create_manual_waivers.exception','Error : ' || SQLERRM);
    END IF;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name        => g_pkg_name,
        p_procedure_name  => l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get(
      p_count  => x_msg_count ,
      p_data   => x_msg_data
    );
END create_manual_waivers;

PROCEDURE validate_parameters(
  p_fee_cal_type        IN  igs_ca_inst_all.cal_type%TYPE        ,
  p_fee_ci_seq_number   IN  igs_ca_inst_all.sequence_number%TYPE ,
  p_waiver_name         IN  igs_fi_waiver_pgms.waiver_name%TYPE  ,
  p_person_id           IN  igs_fi_credits_all.party_id%TYPE     ,
  p_waiver_amount       IN  igs_fi_credits_all.amount%TYPE       ,
  p_currency_cd         IN  igs_fi_credits_all.currency_cd%TYPE  ,
  p_gl_date             IN  igs_fi_credits_all.gl_date%TYPE      ,
  p_source_credit_id    IN  igs_fi_credits_all.credit_id%TYPE    ,
  p_b_return_status     OUT  NOCOPY  BOOLEAN
) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 04 August 2005
--
-- Purpose:
-- Invoked     : from within create_manual_waivers procedure
-- Function    : Private procedure for validating all the inbound parametere
--               to API
--
-- Parameters  : p_fee_cal_type        : IN parameter. Required.
--               p_fee_ci_seq_number   : IN parameter. Required.
--               p_waiver_name         : IN parameter. Required.
--               p_person_id           : IN parameter. Required.
--               p_waiver_amount       : IN parameter. Required.
--               p_currency_cd         : IN parameter. Required.
--               p_gl_date             : IN parameter. Required.
--               p_source_credit_id    : IN parameter. Optional
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--smadathi   28-Oct-2005      Bug 4704177: Enhancement for Tuition Waiver
--                            CCR. Added check for the Error Account = 'Y
------------------------------------------------------------------

  rec_c_waiver_pgms c_waiver_pgms%ROWTYPE;

  CURSOR c_credits (
    cp_n_credit_id           IN  igs_fi_credits_all.credit_id%TYPE,
    cp_v_fee_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
    cp_n_fee_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
    cp_v_waiver_name         IN  igs_fi_waiver_pgms.waiver_name%TYPE
  ) IS
  SELECT  crd.fee_cal_type
         ,crd.fee_ci_sequence_number
         ,crd.waiver_name
         ,crd.credit_id
         ,crd.status
         ,crd.amount
         ,crd.unapplied_amount
  FROM    igs_fi_credits_all crd
  WHERE   crd.credit_id              = cp_n_credit_id
  AND     crd.fee_cal_type           = cp_v_fee_cal_type
  AND     crd.fee_ci_sequence_number = cp_n_fee_sequence_number
  AND     crd.waiver_name            = cp_v_waiver_name;

  rec_c_credits c_credits%ROWTYPE;

  CURSOR c_waiver_adj_appl (
    cp_n_credit_id           IN  igs_fi_credits_all.credit_id%TYPE,
    cp_v_fee_cal_type        IN  igs_ca_inst_all.cal_type%TYPE,
    cp_n_fee_sequence_number IN  igs_ca_inst_all.sequence_number%TYPE,
    cp_v_waiver_name         IN  igs_fi_waiver_pgms.waiver_name%TYPE
  ) IS
  SELECT   appl.amount_applied
  FROM     igs_fi_applications appl,
           igs_fi_inv_int_all inv
  WHERE    appl.credit_id             = cp_n_credit_id
  AND      appl.invoice_id            = inv.invoice_id
  AND      appl.application_type      = 'APP'
  AND      inv.fee_cal_type           = cp_v_fee_cal_type
  AND      inv.fee_ci_sequence_number = cp_n_fee_sequence_number
  AND      inv.waiver_name            = cp_v_waiver_name
  AND      inv.transaction_type       = 'WAIVER_ADJ';

  rec_c_waiver_adj_appl c_waiver_adj_appl%ROWTYPE;

  l_b_ret_status           BOOLEAN;
  l_b_validation_success   BOOLEAN;
  l_b_chr_err_account      NUMBER;

  l_v_message_name         fnd_new_messages.message_name%TYPE;
  l_v_ld_cal_type          igs_ca_inst.cal_type%TYPE;
  l_v_ld_ci_seq_number     igs_ca_inst.sequence_number%TYPE;
  l_v_closing_status       gl_period_statuses.closing_status%TYPE;
  l_v_return_status        VARCHAR2(1);

  l_n_eligible_amount      igs_fi_credits_all.amount%TYPE;
  l_n_wavadj_amt           igs_fi_credits_all.amount%TYPE;
BEGIN

  log_to_fnd(p_v_module => 'validate_parameters',
             p_v_string => ' Entered Procedure validate_parameters: The input parameters are '||
                           ' p_fee_cal_type        : '  ||p_fee_cal_type         ||
                           ' p_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                           ' p_waiver_name         : '  ||p_waiver_name          ||
                           ' p_person_id           : '  ||p_person_id            ||
                           ' p_waiver_amount       : '  ||p_waiver_amount        ||
                           ' p_currency_cd         : '  ||p_currency_cd          ||
                           ' p_gl_date             : '  ||p_gl_date              ||
                           ' p_source_credit_id    : '  ||p_source_credit_id
            );
  -- initialize the return status to TRUE
  l_b_validation_success := TRUE;

  -- Verify if al the mandatory parameters have been supplied to the API
  IF ( p_fee_cal_type   IS NULL OR p_fee_ci_seq_number IS NULL OR
       p_waiver_name    IS NULL OR p_person_id         IS NULL OR
       p_gl_date        IS NULL OR p_currency_cd       IS NULL
      )THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Verify if the Fee Calendar Type and Fee Sequence number passed as inbound parameters
  -- to the API is a valid value or not
  IF NOT igs_fi_crdapi_util.validate_cal_inst (
    p_v_cal_type           => p_fee_cal_type,
    p_n_ci_sequence_number => p_fee_ci_seq_number,
    p_v_s_cal_cat          => 'FEE'
  ) THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_FCI_NOTFOUND');
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Verify load calendar mapping exists in the calendar subsystem for the Fee Calendar Type and
  -- Fee Sequence number passed as inbound parameters to the API
  IF p_fee_cal_type IS NOT NULL AND p_fee_ci_seq_number IS NOT NULL THEN
    igs_fi_crdapi_util.validate_fci_lci_reln (
      p_v_fee_cal_type           => p_fee_cal_type,
      p_n_fee_ci_sequence_number => p_fee_ci_seq_number,
      p_v_ld_cal_type            => l_v_ld_cal_type,
      p_n_ld_ci_sequence_number  => l_v_ld_ci_seq_number,
      p_v_message_name           => l_v_message_name,
      p_b_return_stat            => l_b_ret_status
    ) ;
    IF NOT (l_b_ret_status) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', l_v_message_name);
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
  END IF;

  -- Verify if inbound parameter p_waiver_name holds a value or not
  IF p_waiver_name IS NULL THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_WAV_PGM_INVALID');
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Validate if Waiver program exists for the combination of Fee calendar Type,
  -- Fee Calendar sequence number and waiver program passed as inbound parameters
  -- to the API
  IF (p_fee_cal_type IS NOT NULL AND p_fee_ci_seq_number IS NOT NULL AND p_waiver_name IS NOT NULL) THEN
    OPEN c_waiver_pgms (
      cp_v_fee_cal_type        => p_fee_cal_type      ,
      cp_n_fee_sequence_number => p_fee_ci_seq_number ,
      cp_v_waiver_name         => p_waiver_name
    );
    FETCH c_waiver_pgms INTO rec_c_waiver_pgms;
    IF c_waiver_pgms%NOTFOUND THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_FEE_CAL_INST');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
    CLOSE c_waiver_pgms;

    -- Validate the status of waiver program retrieved by the cusor
    -- API should process only waiver programs of status "Active"
    IF rec_c_waiver_pgms.waiver_status_code <> 'ACTIVE' THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_PGM_INACTIVE');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

    -- Validate if the Waiver program belongs to category "Manual"
    -- API should process Manual waiver programs
    IF rec_c_waiver_pgms.waiver_method_code <> 'MANUAL' THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_METHOD_INVALID');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

    -- Validate the Manual waiver program is of type Fee Level
    -- API should process Manual waiver program is of type Fee Level
    IF rec_c_waiver_pgms.waiver_mode_code <> 'FEE_LEVEL' THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_MODE_INVALID');
        fnd_message.set_token('WAIV_PGM',rec_c_waiver_pgms.waiver_name);
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
  END IF;

  -- Validate if the person id passed as inbound parameter to the API is valid or not
  IF igs_fi_gen_007.validate_person ( p_person_id) = 'N' THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_INVALID_PERSON');
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  --  Validate if the value of the inbound parameter P_GL_DATE is within an Open or Future period
  l_v_message_name := NULL;
  igs_fi_gen_gl.get_period_status_for_date(
    p_d_date           => p_gl_date,
    p_v_closing_status => l_v_closing_status,
    p_v_message_name   => l_v_message_name
  );

  IF l_v_message_name IS NOT NULL THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', l_v_message_name);
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  IF l_v_closing_status NOT IN ('O','F') THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_INVALID_GL_DATE');
      fnd_message.set_token('GL_DATE',p_gl_date);
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Validate if value of the inbound parameter P_CURRENCY_CD is active in the System
  IF NOT igs_fi_crdapi_util.validate_curr ( p_v_currency_cd => p_currency_cd) THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_INVALID_CUR');
      fnd_message.set_token('CUR_CD', p_currency_cd);
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Validate the waiver amount
  IF p_waiver_amount = 0 OR p_waiver_amount IS NULL THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS', 'IGS_FI_WAV_INVALID_AMT');
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  -- Check if the Charge transactions for the Person, Fee Type and Fee Period combination
   -- have the Error Account flag set.
  l_b_chr_err_account := igs_fi_wav_utils_002.check_chg_error_account (
                           p_n_person_id         => p_person_id,
                           p_v_fee_type          => rec_c_waiver_pgms.target_fee_type,
                           p_v_fee_cal_type      => p_fee_cal_type,
                           p_n_fee_ci_seq_number => p_fee_ci_seq_number
                         );
  IF (l_b_chr_err_account=1) THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS','IGS_FI_WAV_CHG_ERR');
      fnd_message.set_token('PERSON',igs_fi_gen_008.get_party_number(p_n_party_id => p_person_id));
      fnd_message.set_token('FEE_TYPE',rec_c_waiver_pgms.target_fee_type);
      fnd_message.set_token('FEE_PERIOD',
                            igs_ca_gen_001.calp_get_alt_cd(p_cal_type => p_fee_cal_type,
                                                           p_sequence_number => p_fee_ci_seq_number)
                           );
      fnd_msg_pub.add;
      l_b_validation_success := FALSE;
    END IF;
  END IF;

  IF NVL(p_waiver_amount,0) > 0 THEN
    IF p_source_credit_id IS NOT NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_CRD_TXN_ID');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

    -- Determine the maximum amount that can be actually waived for the Person Id, target fee type
    -- the value of TARGET_FEE_TYPE column obtained from the cursor c_waiver_pgms select list )
    -- and Fee calendar instance combination.
    log_to_fnd(p_v_module => 'validate_parameters',
               p_v_string => ' Invoking Procedure igs_fi_wav_utils_001.get_eligible_waiver_amt with input parameters '||
                             ' p_n_person_id           : '  ||p_person_id            ||
                             ' p_v_fee_cal_type        : '  ||p_fee_cal_type         ||
                             ' p_n_fee_ci_seq_number   : '  ||p_fee_ci_seq_number    ||
                             ' p_v_waiver_name         : '  ||p_waiver_name          ||
                             ' p_v_target_fee_type     : '  ||rec_c_waiver_pgms.target_fee_type     ||
                             ' p_v_waiver_method_code  : '  ||rec_c_waiver_pgms.waiver_method_code  ||
                             ' p_v_waiver_mode_code    : '  ||rec_c_waiver_pgms.waiver_mode_code
              );

    igs_fi_wav_utils_001.get_eligible_waiver_amt(
      p_n_person_id               =>  p_person_id                          ,
      p_v_fee_cal_type            =>  p_fee_cal_type                       ,
      p_n_fee_ci_seq_number       =>  p_fee_ci_seq_number                  ,
      p_v_waiver_name             =>  p_waiver_name                        ,
      p_v_target_fee_type         =>  rec_c_waiver_pgms.target_fee_type    ,
      p_v_waiver_method_code      =>  rec_c_waiver_pgms.waiver_method_code ,
      p_v_waiver_mode_code        =>  rec_c_waiver_pgms.waiver_mode_code   ,
      p_n_source_invoice_id       =>  NULL                                 ,
      x_return_status             =>  l_v_return_status                    ,
      x_eligible_amount           =>  l_n_eligible_amount
    );

    IF l_v_return_status = 'E' THEN
      log_to_fnd(p_v_module => 'validate_parameters',
                 p_v_string => ' The Procedure igs_fi_wav_utils_001.get_eligible_waiver_amt returned a status of error '
                );
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_ELIG_AMT_FAIL');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

      log_to_fnd(p_v_module => 'validate_parameters',
                 p_v_string => ' The Procedure igs_fi_wav_utils_001.get_eligible_waiver_amt returned a status of error '||
                               ' Eligible waiver amount     : '  ||NVL(l_n_eligible_amount,0)
                );

    IF ((NVL(p_waiver_amount,0) - NVL(l_n_eligible_amount,0))>0) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_GREATER_AMT');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

  ELSIF NVL(p_waiver_amount,0) < 0 THEN
    IF p_source_credit_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_SRC_CRD_MAND');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
    -- Determine if a waiver credit record already exists in the system for the P_SOURCE_CREDIT_ID
    -- passed as inbound parameter to the API
    OPEN c_credits (
      cp_n_credit_id           => p_source_credit_id  ,
      cp_v_fee_cal_type        => p_fee_cal_type      ,
      cp_n_fee_sequence_number => p_fee_ci_seq_number ,
      cp_v_waiver_name         => p_waiver_name
    );
    FETCH c_credits INTO rec_c_credits;
    IF c_credits%NOTFOUND THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_SRC_CRD_INVALID');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
    CLOSE c_credits;

    -- Validate the status of the waiver credit
    IF rec_c_credits.status <> 'CLEARED' THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_SRC_CRD_REVERSED');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;

    -- The amount of Waiver Charge Adjustment to be created should be less than the
    -- Waiver Credit amount less any prior waiver charge adjustments applied to it
    l_n_wavadj_amt := 0;
    FOR rec_c_waiver_adj_appl IN c_waiver_adj_appl (
      cp_n_credit_id           =>  p_source_credit_id  ,
      cp_v_fee_cal_type        =>  p_fee_cal_type      ,
      cp_n_fee_sequence_number =>  p_fee_ci_seq_number ,
      cp_v_waiver_name         =>  p_waiver_name
    )
    LOOP
      l_n_wavadj_amt := NVL(l_n_wavadj_amt,0) + rec_c_waiver_adj_appl.amount_applied ;
    END LOOP;

    log_to_fnd(p_v_module => 'validate_parameters',
               p_v_string => ' p_waiver_amount                  : '  ||p_waiver_amount   ||
                             ' prior waiver charge adjustments  : '  ||l_n_wavadj_amt
              );

    IF ABS(p_waiver_amount) > (NVL(rec_c_credits.amount,0) - l_n_wavadj_amt) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS', 'IGS_FI_WAV_ADJ_AMT_GREATER');
        fnd_msg_pub.add;
        l_b_validation_success := FALSE;
      END IF;
    END IF;
  END IF;

  IF NOT (l_b_validation_success) THEN
    log_to_fnd(p_v_module => 'validate_parameters',
               p_v_string => ' Procedure returning status of failure '
              );
    p_b_return_status := FALSE;
  END IF;

END validate_parameters;


PROCEDURE log_to_fnd (
  p_v_module IN VARCHAR2,
  p_v_string IN VARCHAR2
) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 04 August 2005
--
-- Purpose:
-- Invoked     : from within API
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_fi_waivers_api_pub.'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;

END igs_fi_waivers_api_pub;

/
