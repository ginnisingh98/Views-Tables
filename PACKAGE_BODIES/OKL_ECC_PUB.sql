--------------------------------------------------------
--  DDL for Package Body OKL_ECC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_PUB" AS
/* $Header: OKLPECUB.pls 120.1 2005/08/23 05:41:52 asawanka noship $ */

  /**
      THis function is a wrapper over okl_ec_evaluate_pvt.validate which
      validates the eligibility criteria present on source object.
      The fields in p_okl_ec_rec, corressponding to the eligibility criteria category
      applicable to the source type, should be filled in p_okl_ec_rec.
  **/

  PROCEDURE evaluate_eligibility_criteria(
                                          p_api_version                  IN              number
                                         ,p_init_msg_list                IN              varchar2 DEFAULT okl_api.g_false
                                         ,x_return_status                     OUT nocopy varchar2
                                         ,x_msg_count                         OUT nocopy number
                                         ,x_msg_data                          OUT nocopy varchar2
                                         ,p_okl_ec_rec                   IN   OUT nocopy okl_ec_rec_type
                                         ,x_eligible                          OUT nocopy boolean
                                         ) IS
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ecc_pub.evaluate_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLPECVB.pls call evaluate_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    --Now call the validate procedure
    okl_ec_evaluate_pvt.validate(
                                 p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_okl_ec_rec    => p_okl_ec_rec,
                                 x_eligible      => x_eligible
                                );

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPECVB.pls call evaluate_eligibility_criteria');
    END IF;
    x_return_status := okl_api.g_ret_sts_success;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.g_ret_sts_error;

      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.g_ret_sts_unexp_error;

      WHEN OTHERS THEN
        -- unexpected error
        OKL_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);

  END evaluate_eligibility_criteria;

/**
    This function is a wrapper over okl_ec_evaluate_pvt.compare_eligibility_criteria
    which checks the existenace of at lease one scenario wherein
    common eligibility criteria defined on both the sources can be passed
    successfully.If such scenario exists function returns true else false.
    If there are no common eligibility criteria no comparison is done and
    function returns true.
**/

  FUNCTION compare_eligibility_criteria(p_source_id1    IN  number
                                       ,p_source_type1  IN  varchar2
                                       ,p_source_id2    IN  number
                                       ,p_source_type2  IN  varchar2) RETURN boolean IS
    l_ret                          boolean;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ecc_pub.compare_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLPECVB.pls call compare_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    --Now call the compare_eligibility_criteria function

    l_ret := okl_ec_evaluate_pvt.compare_eligibility_criteria(p_source_id1
                                                             ,p_source_type1
                                                             ,p_source_id2
                                                             ,p_source_type2);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPECVB.pls call compare_eligibility_criteria');
    END IF;
    RETURN l_ret;
  END compare_eligibility_criteria;

END okl_ecc_pub;

/
