--------------------------------------------------------
--  DDL for Package Body OKL_EC_EVALUATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EC_EVALUATE_PVT" AS
/* $Header: OKLRECUB.pls 120.3 2005/08/23 05:38:27 asawanka noship $ */
/**
  This function returs the lookup meaning for the given lookup type and code.
**/
  FUNCTION get_lookup_meaning(p_lookup_type   fnd_lookups.lookup_type%TYPE
                             ,p_lookup_code   fnd_lookups.lookup_code%TYPE) RETURN varchar2 IS

    CURSOR fnd_lookup_csr(p_lookup_type   fnd_lookups.lookup_type%TYPE
                         ,p_lookup_code   fnd_lookups.lookup_code%TYPE) IS
      SELECT meaning
      FROM   fnd_lookups fnd
      WHERE  fnd.lookup_type = p_lookup_type
         AND fnd.lookup_code = p_lookup_code;
    l_return_value                 varchar2(200) := okl_api.g_miss_char;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_lookup_meaning';
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
                             ,'begin debug OKLRECUB.pls.pls call get_lookup_meaning');
    END IF;

    IF (p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL) THEN
      OPEN fnd_lookup_csr(p_lookup_type, p_lookup_code);
      FETCH fnd_lookup_csr INTO l_return_value ;
      CLOSE fnd_lookup_csr;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call evaluate_territory');
    END IF;
    RETURN l_return_value;
  END get_lookup_meaning;
/**
  This function sets the message name and tokens in fnd_message and returns the
  retrieved message text.
**/
  PROCEDURE set_fnd_message(p_msg_name  IN  varchar2
                           ,p_token1    IN  varchar2 DEFAULT NULL
                           ,p_value1    IN  varchar2 DEFAULT NULL
                           ,p_token2    IN  varchar2 DEFAULT NULL
                           ,p_value2    IN  varchar2 DEFAULT NULL
                           ,p_token3    IN  varchar2 DEFAULT NULL
                           ,p_value3    IN  varchar2 DEFAULT NULL
                           ,p_token4    IN  varchar2 DEFAULT NULL
                           ,p_value4    IN  varchar2 DEFAULT NULL) IS
    l_msg                          varchar2(2700);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.set_fnd_message';
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
                             ,'begin debug OKLRECUB.pls.pls call set_fnd_message');
    END IF;
    fnd_message.set_name(g_app_name, p_msg_name);

    IF (p_token1 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token1, value =>  p_value1);
    END IF;

    IF (p_token2 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token2, value =>  p_value2);
    END IF;

    IF (p_token3 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token3, value =>  p_value3);
    END IF;

    IF (p_token4 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token4, value =>  p_value4);
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call set_fnd_message');
    END IF;

  END set_fnd_message;
/**
  This function returns the message text for validation failure of eligibility criteria
  having value type SINGLE.
**/
  FUNCTION get_msg_single(p_ec_name   IN  varchar2
                         ,p_operator  IN  varchar2
                         ,p_val       IN  varchar2
                         ,p_src_name  IN  varchar2) RETURN varchar2 IS

    CURSOR get_op IS
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKL_FE_OPERATORS' AND lookup_code = p_operator;
    l_operator                     varchar2(30);
    l_msg                          varchar2(240);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_msg_single';
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
                             ,'begin debug OKLRECUB.pls.pls call get_msg_single');
    END IF;
    OPEN get_op;
    FETCH get_op INTO l_operator ;
    CLOSE get_op;
    set_fnd_message(p_msg_name =>  'OKL_EC_QA_SINGLE'
                   ,p_token1   =>  'EC'
                   ,p_value1   =>  p_ec_name
                   ,p_token2   =>  'OPERATOR'
                   ,p_value2   =>  l_operator
                   ,p_token3   =>  'VALUE'
                   ,p_value3   =>  p_val
                   ,p_token4   =>  'SOURCE'
                   ,p_value4   =>  p_src_name);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_msg_single');
    END IF;
    RETURN fnd_message.get;
  END get_msg_single;
/**
  This function returns the message text for validation failure of eligibility criteria
  having value type RANGE.
**/
  FUNCTION get_msg_range(p_ec_name   IN  varchar2
                        ,p_val1      IN  varchar2
                        ,p_val2      IN  varchar2
                        ,p_src_name  IN  varchar2) RETURN varchar2 IS
    l_msg                          varchar2(240);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_msg_range';
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
                             ,'begin debug OKLRECUB.pls.pls call get_msg_range');
    END IF;
    set_fnd_message(p_msg_name =>  'OKL_EC_QA_RANGE'
                   ,p_token1   =>  'EC'
                   ,p_value1   =>  p_ec_name
                   ,p_token2   =>  'VALUE1'
                   ,p_value2   =>  p_val1
                   ,p_token3   =>  'VALUE2'
                   ,p_value3   =>  p_val2
                   ,p_token4   =>  'SOURCE'
                   ,p_value4   =>  p_src_name);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_msg_range');
    END IF;
    RETURN fnd_message.get;
  END get_msg_range;
/**
  This function returns the message text for validation failure of eligibility criteria
  having value type MULTIPLE.
**/
  FUNCTION get_msg_multiple(p_ec_name   IN  varchar2
                           ,p_src_name  IN  varchar2) RETURN varchar2 IS
    l_msg                          varchar2(240);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_msg_multiple';
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
                             ,'begin debug OKLRECUB.pls.pls call get_msg_multiple');
    END IF;
    set_fnd_message(p_msg_name =>  'OKL_EC_QA_MULTIPLE'
                   ,p_token1   =>  'EC'
                   ,p_value1   =>  p_ec_name
                   ,p_token2   =>  'SOURCE'
                   ,p_value2   =>  p_src_name);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_msg_multiple');
    END IF;
    RETURN fnd_message.get;
  END get_msg_multiple;
/**
  This function returns the message text for validation failure of user defined
  eligibility criteria
**/
  FUNCTION get_msg_user(p_ec_name   IN  varchar2
                       ,p_src_name  IN  varchar2) RETURN varchar2 IS
    l_msg                          varchar2(240);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_msg_user';
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
                             ,'begin debug OKLRECUB.pls.pls call get_msg_user');
    END IF;
    set_fnd_message(p_msg_name =>  'OKL_EC_QA_USER'
                   ,p_token1   =>  'EC'
                   ,p_value1   =>  p_ec_name
                   ,p_token2   =>  'SOURCE'
                   ,p_value2   =>  p_src_name);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_msg_user');
    END IF;
    RETURN fnd_message.get;
  END get_msg_user;
/**
  This function returns the message text for validation succcess of eligibility criteria
**/
  FUNCTION get_msg_success(p_ec_name   IN  varchar2
                          ,p_src_name  IN  varchar2) RETURN varchar2 IS
    l_msg                          varchar2(240);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_msg_success';
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
                             ,'begin debug OKLRECUB.pls.pls call get_msg_success');
    END IF;
    set_fnd_message(p_msg_name =>  'OKL_EC_QA_SUCCESS'
                   ,p_token1   =>  'EC'
                   ,p_value1   =>  p_ec_name
                   ,p_token2   =>  'SOURCE'
                   ,p_value2   =>  p_src_name);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_msg_success');
    END IF;
    RETURN fnd_message.get;
  END get_msg_success;
/**
        This is the functions which validates the seeded eligibility criteria ADVANCE_RENT.
**/

  FUNCTION validate_advance_rent(p_operator_code  IN  varchar2
                                ,p_value1         IN  varchar2
                                ,p_advance_rent   IN  number) RETURN number IS
    l_numval1                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_advance_rent';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_advance_rent');
    END IF;
    l_numval1 := to_number(p_value1);

    IF p_operator_code = 'EQ' THEN
      IF p_advance_rent = l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'NE' THEN
      IF p_advance_rent <> l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'LT' THEN
      IF p_advance_rent < l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'GT' THEN
      IF p_advance_rent > l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_advance_rent');
        END IF;
        RETURN 0;
      END IF;
    END IF;

  END validate_advance_rent;
/**
        This is the functions which validates the seeded eligibility criteria DOWN_PAYMENT.
**/

  FUNCTION validate_down_payment(p_operator_code  IN  varchar2
                                ,p_value1         IN  varchar2
                                ,p_down_payment   IN  number) RETURN number IS
    l_numval1                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_down_payment';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_down_payment');
    END IF;
    l_numval1 := to_number(p_value1);

    IF p_operator_code = 'EQ' THEN
      IF p_down_payment = l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'NE' THEN
      IF p_down_payment <> l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'LT' THEN
      IF p_down_payment < l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 0;
      END IF;
    ELSIF p_operator_code = 'GT' THEN
      IF p_down_payment > l_numval1 THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 1;
      ELSE
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call validate_down_payment');
        END IF;
        RETURN 0;
      END IF;
    END IF;

  END validate_down_payment;
/**
        This is the functions which validates the seeded eligibility criteria TRADE_IN_VALUE.
**/

  FUNCTION validate_trade_in_value(p_operator_code   IN  varchar2
                                  ,p_value1          IN  varchar2
                                  ,p_value2          IN  varchar2
                                  ,p_trade_in_value  IN  number) RETURN number IS
    l_numval1                      number;
    l_numval2                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_trade_in_value';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_trade_in_value');
    END IF;
    l_numval1 := fnd_number.canonical_to_number(p_value1);
    l_numval2 := fnd_number.canonical_to_number(p_value2);

    IF (p_trade_in_value >= l_numval1 AND p_trade_in_value <= l_numval2) THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_trade_in_value');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_trade_in_value');
      END IF;
      RETURN 0;
    END IF;

  END validate_trade_in_value;

  FUNCTION validate_term(p_value_tbl       IN  okl_number_table_type
                        ,p_match_criteria  IN  varchar2
                        ,p_term            IN  number) RETURN number IS
    l_result                       varchar2(1);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_term';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_term');
    END IF;
    l_result := 'S';

    IF p_match_criteria = 'INCLUDE' THEN

      <<outer1>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP

          -- dbms_output.put_line('p_term_tbl(i)=  '||p_term_tbl(i)|| 'p_value_tbl(j) = '||p_value_tbl(j));

          IF p_term = p_value_tbl(j) THEN
            l_result := 'S';
            EXIT outer1;
          ELSE
            l_result := 'E';
          END IF;
        END LOOP;


    END IF;

    IF p_match_criteria = 'EXCLUDE' THEN

      <<outer2>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_term = p_value_tbl(j) THEN
            l_result := 'E';
            EXIT outer2;
          ELSE
            l_result := 'S';
          END IF;
        END LOOP;

    END IF;

    IF l_result = 'S' THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_term');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_term');
      END IF;
      RETURN 0;
    END IF;

  END validate_term;
/**
        This is the functions which validates the seeded eligibility criteria TERRITORY.
**/

  FUNCTION validate_territory(p_value_tbl       IN  okl_varchar2_table_type
                             ,p_match_criteria  IN  varchar2
                             ,p_territory       IN  varchar2) RETURN number IS
    l_result                       varchar2(1);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_territory';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_territory');
    END IF;
    l_result := 'S';

    IF p_match_criteria = 'INCLUDE' THEN

      <<outer1>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_territory = p_value_tbl(j) THEN
            l_result := 'S';
            EXIT outer1;
          ELSE
            l_result := 'E';
          END IF;
        END LOOP;

    END IF;

    IF p_match_criteria = 'EXCLUDE' THEN

      <<outer2>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_territory = p_value_tbl(j) THEN
            l_result := 'E';
            EXIT outer2;
          ELSE
            l_result := 'S';
          END IF;
        END LOOP;

    END IF;

    IF l_result = 'S' THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_territory');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_territory');
      END IF;
      RETURN 0;
    END IF;

  END validate_territory;
/**
        This is the functions which validates the seeded eligibility criteria CUSTOMER_CREDIT_CLASS.
**/

  FUNCTION validate_customer_credit_class(p_value_tbl              IN  okl_varchar2_table_type
                                         ,p_match_criteria         IN  varchar2
                                         ,p_cust_credit_class      IN  varchar2) RETURN number IS
    l_result                       varchar2(1);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_customer_credit_class';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_customer_credit_class');
    END IF;
    l_result := 'S';

    IF p_match_criteria = 'INCLUDE' THEN

      <<outer1>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_cust_credit_class = p_value_tbl(j) THEN
            l_result := 'S';
            EXIT outer1;
          ELSE
            l_result := 'E';
          END IF;
        END LOOP;

    END IF;

    IF p_match_criteria = 'EXCLUDE' THEN

      <<outer2>>
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_cust_credit_class = p_value_tbl(j) THEN
            l_result := 'E';
            EXIT outer2;
          ELSE
            l_result := 'S';
          END IF;
        END LOOP;

    END IF;

    IF l_result = 'S' THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_customer_credit_class');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_customer_credit_class');
      END IF;
      RETURN 0;
    END IF;

  END validate_customer_credit_class;
/**
        This is the functions which validates the seeded eligibility criteria ITEM.
**/

  FUNCTION validate_item(p_value_tbl           okl_number_table_type
                        ,p_match_criteria  IN  varchar2
                        ,p_item_tbl            okl_number_table_type) RETURN number IS
    l_result                       varchar2(1);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_item';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_item');
    END IF;
    l_result := 'S';

    IF p_match_criteria = 'INCLUDE' THEN

      <<outer1>>
      FOR i IN p_item_tbl.FIRST..p_item_tbl.LAST LOOP
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_item_tbl(i) = p_value_tbl(j) THEN
            l_result := 'S';
            EXIT outer1;
          ELSE
            l_result := 'E';
          END IF;
        END LOOP;
      END LOOP;

    END IF;

    IF p_match_criteria = 'EXCLUDE' THEN

      <<outer2>>
      FOR i IN p_item_tbl.FIRST..p_item_tbl.LAST LOOP
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_item_tbl(i) = p_value_tbl(j) THEN
            l_result := 'E';
            EXIT outer2;
          ELSE
            l_result := 'S';
          END IF;
        END LOOP;
      END LOOP;

    END IF;

    IF l_result = 'S' THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_item');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_item');
      END IF;
      RETURN 0;
    END IF;

  END validate_item;
/**
        This is the functions which validates the seeded eligibility criteria ITEM_CATEGORIES.
**/

  FUNCTION validate_item_categories(p_value_tbl                okl_number_table_type
                                   ,p_match_criteria       IN  varchar2
                                   ,p_item_categories_tbl      okl_number_table_type) RETURN number IS
    l_result                       varchar2(1);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_item_categories';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_item_categories');
    END IF;
    l_result := 'S';

    IF p_match_criteria = 'INCLUDE' THEN

      <<outer1>>
      FOR i IN p_item_categories_tbl.FIRST..p_item_categories_tbl.LAST LOOP
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_item_categories_tbl(i) = p_value_tbl(j) THEN
            l_result := 'S';
            EXIT outer1;
          ELSE
            l_result := 'E';
          END IF;
        END LOOP;
      END LOOP;

    END IF;

    IF p_match_criteria = 'EXCLUDE' THEN

      <<outer2>>
      FOR i IN p_item_categories_tbl.FIRST..p_item_categories_tbl.LAST LOOP
        FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP
          IF p_item_categories_tbl(i) = p_value_tbl(j) THEN
            l_result := 'E';
            EXIT outer2;
          ELSE
            l_result := 'S';
          END IF;
        END LOOP;
      END LOOP;

    END IF;

    IF l_result = 'S' THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_item_categories');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_item_categories');
      END IF;
      RETURN 0;
    END IF;

  END validate_item_categories;
/**
        This is the functions which validates the seeded eligibility criteria DEAL_SIZE.
**/

  FUNCTION validate_deal_size(p_value1     IN  varchar2
                             ,p_value2     IN  varchar2
                             ,p_deal_size  IN  number) RETURN number IS
    l_numval1                      number;
    l_numval2                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate_deal_size';
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
                             ,'begin debug OKLRECUB.pls.pls call validate_deal_size');
    END IF;
    l_numval1 := fnd_number.canonical_to_number(p_value1);
    l_numval2 := fnd_number.canonical_to_number(p_value2);

    IF (p_deal_size >= l_numval1 AND p_deal_size <= l_numval2) THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_deal_size');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate_deal_size');
      END IF;
      RETURN 0;
    END IF;

  END validate_deal_size;
/**
    This function evaluates the seeded adjustment category TERM
    This function evluates whether the p_term  passed is present
    in p_value_tbl.
    It returns the matching index in p_value_tbl. If no match found
    then it returns Zero. p_value_tbl contains the adjustment factor corressponding
    to different term values.
**/

  FUNCTION evaluate_term(p_value_tbl  IN  okl_number_table_type
                        ,p_term       IN  number) RETURN number IS
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.evaluate_term';
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
                             ,'begin debug OKLRECUB.pls.pls call evaluate_term');
    END IF;

    FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP

      -- dbms_output.put_line('p_term_tbl(i)=  '||p_term_tbl(i)|| 'p_value_tbl(j) = '||p_value_tbl(j));

      IF p_term = p_value_tbl(j) THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call evaluate_term');
        END IF;
        RETURN j;
      END IF;

    END LOOP;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call evaluate_term');
    END IF;
    RETURN 0;
  END evaluate_term;
/**
    This function evaluates the seeded adjustment category TERRITORY
    This function evaluates whether the p_territory  passed is present
    in p_value_tbl.
    It returns the matching index in p_value_tbl. If no match found
    then it returns Zero. p_value_tbl contains the adjustment factor corressponding
    to different term values.
**/

  FUNCTION evaluate_territory(p_value_tbl  IN  okl_varchar2_table_type
                             ,p_territory  IN  varchar2) RETURN number IS
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.evaluate_territory';
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
                             ,'begin debug OKLRECUB.pls.pls call evaluate_territory');
    END IF;

    FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP

      -- dbms_output.put_line('p_term_tbl(i)=  '||p_term_tbl(i)|| 'p_value_tbl(j) = '||p_value_tbl(j));

      IF p_territory = p_value_tbl(j) THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call evaluate_territory');
        END IF;
        RETURN j;
      END IF;

    END LOOP;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call evaluate_territory');
    END IF;
    RETURN 0;
  END evaluate_territory;
/**
    This function evaluates the seeded adjustment category CUSTOMER_CREDIT_CLASS
    This function evaluates whether the p_customer_credit_class  passed is present
    in p_value_tbl.
    It returns the matching index in p_value_tbl. If no match found
    then it returns Zero. p_value_tbl contains the adjustment factor corressponding
    to different term values.
**/

  FUNCTION evaluate_customer_credit_class(p_value_tbl              IN  okl_varchar2_table_type
                                         ,p_customer_credit_class  IN  varchar2) RETURN number IS
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.evaluate_customer_credit_class';
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
                             ,'begin debug OKLRECUB.pls.pls call evaluate_customer_credit_class');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    FOR j IN p_value_tbl.FIRST..p_value_tbl.LAST LOOP

      -- dbms_output.put_line('p_term_tbl(i)=  '||p_term_tbl(i)|| 'p_value_tbl(j) = '||p_value_tbl(j));

      IF p_customer_credit_class = p_value_tbl(j) THEN
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECUB.pls.pls call evaluate_customer_credit_class');
        END IF;
        RETURN j;
      END IF;

    END LOOP;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call evaluate_customer_credit_class');
    END IF;
    RETURN 0;
  END evaluate_customer_credit_class;
/**
    This function evaluates the seeded adjustment category DEAL_SIZE
    This function evluates whether the p_deal_size  passed is within
    range p_value1 to p_value2
    If yes Returns 1 else returns 0.
**/

  FUNCTION evaluate_deal_size(p_value1     IN  varchar2
                             ,p_value2     IN  varchar2
                             ,p_deal_size  IN  number) RETURN number IS
    l_numval1                      number;
    l_numval2                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.evaluate_deal_size';
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
                             ,'begin debug OKLRECUB.pls.pls call evaluate_deal_size');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    l_numval1 := fnd_number.canonical_to_number(p_value1);
    l_numval2 := fnd_number.canonical_to_number(p_value2);

    IF (p_deal_size >= l_numval1 AND p_deal_size <= l_numval2) THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call evaluate_deal_size');
      END IF;
      RETURN 1;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call evaluate_deal_size');
      END IF;
      RETURN 0;
    END IF;

  END evaluate_deal_size;
/**
    This procedure validates the eligibility criteria present on source object.
    The fields in p_okl_ec_rec, co.rressponding to the eligibility criteria category
    applicable to the source type, should be filled in p_okl_ec_rec.
**/

  PROCEDURE validate(
                    p_api_version                  IN              number
                   ,p_init_msg_list                IN              varchar2 DEFAULT okl_api.g_false
                   ,x_return_status                     OUT nocopy varchar2
                   ,x_msg_count                         OUT nocopy number
                   ,x_msg_data                          OUT nocopy varchar2
                   ,p_okl_ec_rec                   IN   OUT nocopy okl_ec_rec_type
                   ,x_eligible                          OUT nocopy boolean
                   ) IS

    CURSOR get_ec(src_id        IN  number
                 ,src_obj_code  IN  varchar2) IS
      SELECT ech.match_criteria_code mc_hdr
            ,ech.validation_code
            ,fun.name evaluation_function
            ,ecl.criteria_id
            ,ecl.match_criteria_code
            ,ecl.effective_from_date
            ,ecl.effective_to_date
            ,ecc.value_type_code
            ,ecc.seeded_yn
            ,ecc.crit_cat_name ec_name
      FROM   okl_fe_criteria_set ech
            ,okl_fe_criteria ecl
            ,okl_fe_crit_cat_def_v ecc
            ,okl_data_src_fnctns_v fun
      WHERE  ech.criteria_set_id = ecl.criteria_set_id
         AND ech.source_id = src_id
         AND ech.source_object_code = src_obj_code
         AND ecl.crit_cat_def_id = ecc.crit_cat_def_id
         AND ecc.ecc_ac_flag = 'ECC'
         AND ecc.function_id = fun.id;

    TYPE ec_tbl_type IS TABLE OF get_ec%ROWTYPE INDEX BY BINARY_INTEGER;

    CURSOR get_ec_values(ec_ln_id  IN  number) IS
      SELECT operator_code
            ,crit_cat_value1
            ,crit_cat_value2
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = ec_ln_id;
    ec_tbl                         ec_tbl_type;
    ret                            boolean;
    fun_ret                        number;
    call_user                      boolean;
    i                              number;
    k                              number;
    l_operator_code                varchar2(30);
    l_value1                       varchar2(240);
    l_value2                       varchar2(240);
    l_formatted_amt                varchar2(40);
    l_formatted_amt1               varchar2(40);
    l_formatted_amt2               varchar2(40);
    l_index                        number;
    l_varchar_value_tbl            okl_varchar2_table_type;
    l_ec_values_tbl                okl_ec_values_tbl_type;
    l_num_value_tbl                okl_number_table_type;
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count                    number;
    l_msg_data                     varchar2(2000);
    l_init_msg_list                varchar2(1) DEFAULT OKL_API.G_FALSE;
    l_function_name                okl_data_src_fnctns_v.name%TYPE;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.validate';
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
                             ,'begin debug OKLRECUB.pls.pls call validate');
    END IF;
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    --dbms_output.put_line('start of new ');

    --log the incoming values
    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,' p_okl_ec_rec.SRC_ID = '                || p_okl_ec_rec.SRC_ID                ||
                                ' p_okl_ec_rec.SOURCE_NAME = '           || p_okl_ec_rec.SOURCE_NAME           ||
                                ' p_okl_ec_rec.TARGET_ID = '             || p_okl_ec_rec.TARGET_ID             ||
                                ' p_okl_ec_rec.SRC_TYPE = '              || p_okl_ec_rec.SRC_TYPE              ||
                                ' p_okl_ec_rec.TARGET_TYPE = '           || p_okl_ec_rec.TARGET_TYPE           ||
                                ' p_okl_ec_rec.TARGET_EFF_FROM = '       || p_okl_ec_rec.TARGET_EFF_FROM       ||
                                ' p_okl_ec_rec.TERM = '                  || p_okl_ec_rec.TERM                  ||
                                ' p_okl_ec_rec.TERRITORY = '             || p_okl_ec_rec.TERRITORY             ||
                                ' p_okl_ec_rec.DEAL_SIZE = '             || p_okl_ec_rec.DEAL_SIZE             ||
                                ' p_okl_ec_rec.CUSTOMER_CREDIT_CLASS = ' || p_okl_ec_rec.CUSTOMER_CREDIT_CLASS ||
                                ' p_okl_ec_rec.DOWN_PAYMENT = '          || p_okl_ec_rec.DOWN_PAYMENT          ||
                                ' p_okl_ec_rec.ADVANCE_RENT = '          || p_okl_ec_rec.ADVANCE_RENT          ||
                                ' p_okl_ec_rec.TRADE_IN_VALUE = '        || p_okl_ec_rec.TRADE_IN_VALUE        ||
                                ' p_okl_ec_rec.ITEM_TABLE_COUNT = '      || p_okl_ec_rec.ITEM_TABLE.COUNT      ||
                                ' p_okl_ec_rec.item_cat_table_count  = ' || p_okl_ec_rec.item_categories_table.COUNT
                               );
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'



    ret := true;
    fun_ret := 1;

    --get all the ec defined on the source object of type= src_type

    i := 1;

    FOR ec_rec IN get_ec(p_okl_ec_rec.src_id, p_okl_ec_rec.src_type) LOOP
      ec_tbl(i).mc_hdr := ec_rec.mc_hdr;
      ec_tbl(i).match_criteria_code := ec_rec.match_criteria_code;
      ec_tbl(i).validation_code := ec_rec.validation_code;
      ec_tbl(i).evaluation_function := ec_rec.evaluation_function;
      ec_tbl(i).criteria_id := ec_rec.criteria_id;
      ec_tbl(i).effective_from_date := ec_rec.effective_from_date;
      ec_tbl(i).effective_to_date := ec_rec.effective_to_date;
      ec_tbl(i).value_type_code := ec_rec.value_type_code;
      ec_tbl(i).seeded_yn := ec_rec.seeded_yn;
      ec_tbl(i).ec_name := ec_rec.ec_name;
      i := i + 1;
    END LOOP;  -- For each ec defined on the source object do
    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');

    IF ec_tbl.COUNT > 0 THEN

      FOR i IN ec_tbl.FIRST..ec_tbl.LAST LOOP

        -- dbms_output.put_line('ec_tbl(i).EC_NAME =  ' || ec_tbl(i).EC_NAME);

        IF ec_tbl(i).seeded_yn = 'Y' THEN
          IF (ec_tbl(i).ec_name = 'ADVANCE RENT') THEN

            --dbms_output.put_line('ADV RENT p_okl_ec_rec.TARGET_EFF_FROM = '||p_okl_ec_rec.TARGET_EFF_FROM);
            --dbms_output.put_line('ADV RENT ec_tbl(i).effective_from_date = '||ec_tbl(i).effective_from_date);
            --dbms_output.put_line('ADV RENT ec_tbl(i).effective_to_date ='||ec_tbl(i).effective_to_date);

            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.advance_rent IS NOT NULL)) THEN

              --dbms_output.put_line('passed date validations ');

              OPEN get_ec_values(ec_tbl(i).criteria_id);
              FETCH get_ec_values INTO l_operator_code
                                      ,l_value1
                                      ,l_value2 ;
              CLOSE get_ec_values;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_advance_rent(l_operator_code
                                              ,l_value1
                                              ,p_okl_ec_rec.advance_rent);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  l_formatted_amt := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value1)
                                                                      ,p_okl_ec_rec.currency_code);
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_single(ec_tbl(i).ec_name
                                                                               ,l_operator_code
                                                                               ,l_formatted_amt
                                                                               ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'CUSTOMER CREDIT CLASS') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.customer_credit_class IS NOT NULL)) THEN
              k := 1;
              FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
                l_varchar_value_tbl(k) := ec_val_rec.crit_cat_value2;
                k := k + 1;
              END LOOP;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_customer_credit_class(l_varchar_value_tbl
                                                       ,ec_tbl(i).match_criteria_code
                                                       ,p_okl_ec_rec.customer_credit_class);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_multiple(ec_tbl(i).ec_name
                                                                                 ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'DEAL SIZE') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.deal_size IS NOT NULL)) THEN
              OPEN get_ec_values(ec_tbl(i).criteria_id);
              FETCH get_ec_values INTO l_operator_code
                                      ,l_value1
                                      ,l_value2 ;
              CLOSE get_ec_values;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_deal_size(l_value1
                                           ,l_value2
                                           ,p_okl_ec_rec.deal_size);  --dbms_output.put_line('fun_ret deal size =  '||fun_ret);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  l_formatted_amt1 := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value1)
                                                                       ,p_okl_ec_rec.currency_code);
                  l_formatted_amt2 := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value2)
                                                                       ,p_okl_ec_rec.currency_code);
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_range(ec_tbl(i).ec_name
                                                                              ,l_formatted_amt1
                                                                              ,l_formatted_amt2
                                                                              ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'DOWN PAYMENT') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.down_payment IS NOT NULL)) THEN
              OPEN get_ec_values(ec_tbl(i).criteria_id);
              FETCH get_ec_values INTO l_operator_code
                                      ,l_value1
                                      ,l_value2 ;
              CLOSE get_ec_values;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_down_payment(l_operator_code
                                              ,l_value1
                                              ,p_okl_ec_rec.down_payment);

              --dbms_output.put_line('fun_ret of down payment= '||fun_ret);
              --dbms_output.put_line('l_value1 = '||l_value1);

              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  l_formatted_amt := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value1)
                                                                      ,p_okl_ec_rec.currency_code);
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_single(ec_tbl(i).ec_name
                                                                               ,l_operator_code
                                                                               ,l_formatted_amt
                                                                               ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'ITEM') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.item_table.COUNT > 0)) THEN
              k := 1;
              FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
                l_num_value_tbl(k) := fnd_number.canonical_to_number(ec_val_rec.crit_cat_value2);
                k := k + 1;
              END LOOP;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_item(l_num_value_tbl
                                      ,ec_tbl(i).match_criteria_code
                                      ,p_okl_ec_rec.item_table);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_multiple(ec_tbl(i).ec_name
                                                                                 ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'ITEM CATEGORIES') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.item_categories_table.COUNT > 0)) THEN
              k := 1;
              FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
                l_num_value_tbl(k) := fnd_number.canonical_to_number(ec_val_rec.crit_cat_value2);
                k := k + 1;
              END LOOP;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_item_categories(l_num_value_tbl
                                                 ,ec_tbl(i).match_criteria_code
                                                 ,p_okl_ec_rec.item_categories_table);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_multiple(ec_tbl(i).ec_name
                                                                                 ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'TERM') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.term IS NOT NULL)) THEN
              k := 1;
              FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
                l_num_value_tbl(k) := fnd_number.canonical_to_number(ec_val_rec.crit_cat_value2);

                --dbms_output.put_line('l_num_value_tbl(k) =  '||l_num_value_tbl(k));

                k := k + 1;
              END LOOP;

              --dbms_output.put_line('ec_tbl(i).match_criteria_code= '||ec_tbl(i).match_criteria_code);
              --this validate function will return either 1 or 0 only

              fun_ret := validate_term(l_num_value_tbl
                                      ,ec_tbl(i).match_criteria_code
                                      ,p_okl_ec_rec.term);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN

                --dbms_output.put_line('ec_tbl(i).mc_hdr =  '||ec_tbl(i).mc_hdr || 'fun_ret = '|| fun_ret);

                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_multiple(ec_tbl(i).ec_name
                                                                                 ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'TERRITORY') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.territory IS NOT NULL)) THEN
              k := 1;
              FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
                l_varchar_value_tbl(k) := ec_val_rec.crit_cat_value2;
                k := k + 1;
              END LOOP;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_territory(l_varchar_value_tbl
                                           ,ec_tbl(i).match_criteria_code
                                           ,p_okl_ec_rec.territory);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_multiple(ec_tbl(i).ec_name
                                                                                 ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
          IF (ec_tbl(i).ec_name = 'TRADE IN VALUE') THEN
            IF ((p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ec_rec.trade_in_value IS NOT NULL)) THEN
              OPEN get_ec_values(ec_tbl(i).criteria_id);
              FETCH get_ec_values INTO l_operator_code
                                      ,l_value1
                                      ,l_value2 ;
              CLOSE get_ec_values;

              --this validate function will return either 1 or 0 only

              fun_ret := validate_trade_in_value(l_operator_code
                                                ,l_value1
                                                ,l_value2
                                                ,p_okl_ec_rec.trade_in_value);
              IF p_okl_ec_rec.validation_mode = 'LOV' THEN
                IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := true;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
                IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                  IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                    okl_debug_pub.log_debug(fnd_log.level_procedure
                                           ,l_module
                                           ,'end debug OKLRECUB.pls.pls call validate');
                  END IF;
                  x_eligible := false;
                  x_return_status := okl_api.g_ret_sts_success;
                  RETURN;
                END IF;
              END IF;
              IF p_okl_ec_rec.validation_mode = 'QA' THEN
                l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
                IF fun_ret = 0 THEN
                  l_formatted_amt1 := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value1)
                                                                       ,p_okl_ec_rec.currency_code);
                  l_formatted_amt2 := okl_accounting_util.format_amount(fnd_number.canonical_to_number(l_value2)
                                                                       ,p_okl_ec_rec.currency_code);
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_range(ec_tbl(i).ec_name
                                                                              ,l_formatted_amt1
                                                                              ,l_formatted_amt2
                                                                              ,p_okl_ec_rec.source_name);
                  IF ec_tbl(i).validation_code = 'WARNING' THEN
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'WARNING');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'WARNING');
                  ELSE
                    p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                    ,'ERROR');
                    p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                          ,'ERROR');
                  END IF;
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                                ,p_okl_ec_rec.source_name);
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
                END IF;
              END IF;
            ELSE
              fun_ret := 1;
            END IF;
          END IF;
        END IF;  --of Seeded_yn= Y
      END LOOP;

      --set G_EC_REC global variable to be used in user defined function to access values of p_okl_ec_rec

      g_ec_rec := p_okl_ec_rec;

      --call evaluation function attached to user defined criteria

      FOR i IN ec_tbl.FIRST..ec_tbl.LAST LOOP
        IF ec_tbl(i).seeded_yn = 'N' THEN
          IF (p_okl_ec_rec.target_eff_from BETWEEN ec_tbl(i).effective_from_date AND nvl(ec_tbl(i).effective_to_date
                                                                                        ,to_date('01-01-9999'
                                                                                                ,'dd-mm-yyyy'))) THEN
            k := 1;
            FOR ec_val_rec IN get_ec_values(ec_tbl(i).criteria_id) LOOP
              l_ec_values_tbl(k).operator_code := ec_val_rec.operator_code;
              l_ec_values_tbl(k).value1 := ec_val_rec.crit_cat_value1;
              l_ec_values_tbl(k).value2 := ec_val_rec.crit_cat_value2;
              l_ec_values_tbl(k).match_criteria_code := ec_tbl(i).match_criteria_code;
              k := k + 1;
            END LOOP;
            g_ec_values_tbl := l_ec_values_tbl;

            --call the execute function API
            l_function_name := ec_tbl(i).EVALUATION_FUNCTION;
            okl_execute_formula_pvt.execute_eligibility_criteria (   p_api_version   => l_api_version,
                                                                     p_init_msg_list => l_init_msg_list,
                                                                     x_return_status => x_return_status,
                                                                     x_msg_count     => x_msg_count,
                                                                     x_msg_data      => x_msg_data,
                                                                     p_function_name => l_function_name,
                                                                     x_value         => fun_ret
                                                                 );
            IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'okl_execute_formula_pvt.execute_eligibility_criteria returned with status ' ||
                                        x_return_status ||
                                        ' x_msg_data ' ||
                                        x_msg_data);
            END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
            END IF;

            IF p_okl_ec_rec.validation_mode = 'LOV' THEN
              IF (ec_tbl(i).mc_hdr = 'ONE' AND fun_ret = 1) THEN
                IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_procedure
                                         ,l_module
                                         ,'end debug OKLRECUB.pls.pls call validate');
                END IF;
                x_eligible := true;
                x_return_status := okl_api.g_ret_sts_success;
                RETURN;
              END IF;
              IF (ec_tbl(i).mc_hdr = 'ALL' AND fun_ret = 0) THEN
                IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_procedure
                                         ,l_module
                                         ,'end debug OKLRECUB.pls.pls call validate');
                END IF;
                x_eligible := false;
                x_return_status := okl_api.g_ret_sts_success;
                RETURN;
              END IF;
            END IF;
            IF p_okl_ec_rec.validation_mode = 'QA' THEN
              l_index := p_okl_ec_rec.qa_result_tbl.COUNT + 1;
              IF fun_ret = 0 THEN
                p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_user(ec_tbl(i).ec_name
                                                                           ,p_okl_ec_rec.source_name);
                IF ec_tbl(i).validation_code = 'WARNING' THEN
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                  ,'WARNING');
                  p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                        ,'WARNING');
                ELSE
                  p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                                  ,'ERROR');
                  p_okl_ec_rec.consolidated_status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT'
                                                                        ,'ERROR');
                END IF;
              ELSE
                p_okl_ec_rec.qa_result_tbl(l_index).message := get_msg_success(ec_tbl(i).ec_name
                                                                              ,p_okl_ec_rec.source_name);
                p_okl_ec_rec.qa_result_tbl(l_index).status := get_lookup_meaning('OKL_EC_VALIDATION_RESULT','SUCCESS');
              END IF;
            END IF;
          ELSE
            fun_ret := 1;
          END IF;
        END IF;  -- of Seeded_yn =N
      END LOOP;

    END IF;  -- of If ec_tbl.count > 0

    IF fun_ret = 1 THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate');
      END IF;
      x_return_status := okl_api.g_ret_sts_success;
      x_eligible := true;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECUB.pls.pls call validate');
      END IF;
      x_return_status := okl_api.g_ret_sts_success;
      x_eligible := false;
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        IF get_ec%ISOPEN THEN
          CLOSE get_ec;
        END IF;

        IF get_ec_values%ISOPEN THEN
          CLOSE get_ec_values;
        END IF;
        x_return_status := okl_api.g_ret_sts_error;

      WHEN okl_api.g_exception_unexpected_error THEN
        IF get_ec%ISOPEN THEN
          CLOSE get_ec;
        END IF;

        IF get_ec_values%ISOPEN THEN
          CLOSE get_ec_values;
        END IF;
        x_return_status := okl_api.g_ret_sts_unexp_error;

      WHEN OTHERS THEN

        IF get_ec%ISOPEN THEN
          CLOSE get_ec;
        END IF;

        IF get_ec_values%ISOPEN THEN
          CLOSE get_ec_values;
        END IF;
        -- unexpected error
        OKL_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);

  END validate;

  -- the fields in p_okl_ec_rec, corressponding to the ecc applicable to the source type,
  -- should be filled in p_okl_ec_rec


/**
          This procedure evaluates the adjustment categories attached to source object
          and returns the adjustment factor in out variable x_adjustment_factor.
  **/

  PROCEDURE get_adjustment_factor(
                                  p_api_version                  In              number
                                 ,P_init_msg_list                In              varchar2 Default Okl_api.G_false
                                 ,x_return_status                     Out Nocopy varchar2
                                 ,x_msg_count                         Out Nocopy number
                                 ,x_msg_data                          Out Nocopy varchar2
                                 ,p_okl_ac_rec                   In              okl_ac_rec_type
                                 ,x_adjustment_factor                 Out Nocopy number
                                 ) IS

    CURSOR get_ac(src_id        IN  number
                 ,src_obj_code  IN  varchar2) IS
      SELECT fun.name evaluation_function
            ,ecl.criteria_id
            ,ecl.effective_from_date
            ,ecl.effective_to_date
            ,ecc.value_type_code
            ,ecc.seeded_yn
            ,ecc.crit_cat_name ac_name
      FROM   okl_fe_criteria_set ech
            ,okl_fe_criteria ecl
            ,okl_fe_crit_cat_def_v ecc
            ,okl_data_src_fnctns_v fun
      WHERE  ech.criteria_set_id = ecl.criteria_set_id
         AND ech.source_id = src_id
         AND ech.source_object_code = src_obj_code
         AND ecl.crit_cat_def_id = ecc.crit_cat_def_id
         AND ecc.ecc_ac_flag = 'AC'
         AND ecc.function_id = fun.id;

    TYPE ac_tbl_type IS TABLE OF get_ac%ROWTYPE INDEX BY BINARY_INTEGER;

    CURSOR get_ac_values(ec_ln_id  IN  number) IS
      SELECT operator_code
            ,crit_cat_value1
            ,crit_cat_value2
            ,adjustment_factor
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = ec_ln_id;
    ac_tbl                            ac_tbl_type;
    ret                               boolean;
    fun_ret                           number;
    call_user                         boolean;
    i                                 number;
    k                                 number;
    l_operator_code                   varchar2(30);
    l_value1                          varchar2(240);
    l_value2                          varchar2(240);
    l_adjustment_factor               number;
    l_index                           number;
    l_varchar_value_tbl               okl_varchar2_table_type;
    l_num_value_tbl                   okl_number_table_type;
    l_adjustment_factors_tbl          okl_number_table_type;
    l_ac_values_tbl                   okl_ec_values_tbl_type;
    l_adj_fctr                        number;
    l_api_version            CONSTANT number := 1.0;
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count                       number;
    l_msg_data                        varchar2(2000);
    l_init_msg_list                   varchar2(1) DEFAULT OKL_API.G_FALSE;
    l_function_name                   okl_data_src_fnctns_v.name%TYPE;
    l_module                 CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.get_adjustment_factor';
    l_debug_enabled                   varchar2(10);
    is_debug_procedure_on             boolean;
    is_debug_statement_on             boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECUB.pls.pls call get_adjustment_factor');
    END IF;

    --dbms_output.put_line('start of new ');
    --log the incoming values
    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,' p_okl_ac_rec.SRC_ID = '                || p_okl_ac_rec.SRC_ID                ||
                                ' p_okl_ac_rec.SOURCE_NAME = '           || p_okl_ac_rec.SOURCE_NAME           ||
                                ' p_okl_ac_rec.TARGET_ID = '             || p_okl_ac_rec.TARGET_ID             ||
                                ' p_okl_ac_rec.SRC_TYPE = '              || p_okl_ac_rec.SRC_TYPE              ||
                                ' p_okl_ac_rec.TARGET_TYPE = '           || p_okl_ac_rec.TARGET_TYPE           ||
                                ' p_okl_ac_rec.TARGET_EFF_FROM = '       || p_okl_ac_rec.TARGET_EFF_FROM       ||
                                ' p_okl_ac_rec.TERM = '                  || p_okl_ac_rec.TERM                  ||
                                ' p_okl_ac_rec.TERRITORY = '             || p_okl_ac_rec.TERRITORY             ||
                                ' p_okl_ac_rec.DEAL_SIZE = '             || p_okl_ac_rec.DEAL_SIZE             ||
                                ' p_okl_ac_rec.CUSTOMER_CREDIT_CLASS = ' || p_okl_ac_rec.CUSTOMER_CREDIT_CLASS
                               );
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y

    ret := true;
    fun_ret := 1;
    l_adjustment_factor := 0;

    --get all the adjustment categories defined on the source object of type= source_type

    i := 1;

    FOR ac_rec IN get_ac(p_okl_ac_rec.src_id, p_okl_ac_rec.src_type) LOOP
      ac_tbl(i).evaluation_function := ac_rec.evaluation_function;
      ac_tbl(i).criteria_id := ac_rec.criteria_id;
      ac_tbl(i).effective_from_date := ac_rec.effective_from_date;
      ac_tbl(i).effective_to_date := ac_rec.effective_to_date;
      ac_tbl(i).value_type_code := ac_rec.value_type_code;
      ac_tbl(i).seeded_yn := ac_rec.seeded_yn;
      ac_tbl(i).ac_name := ac_rec.ac_name;
      i := i + 1;
    END LOOP;  -- For each ec defined on the source object do

    IF ac_tbl.COUNT > 0 THEN

      FOR i IN ac_tbl.FIRST..ac_tbl.LAST LOOP

        -- dbms_output.put_line('ec_tbl(i).EC_NAME =  ' || ec_tbl(i).EC_NAME);

        IF ac_tbl(i).seeded_yn = 'Y' THEN
          IF (ac_tbl(i).ac_name = 'CUSTOMER CREDIT CLASS') THEN
            IF ((p_okl_ac_rec.target_eff_from BETWEEN ac_tbl(i).effective_from_date AND nvl(ac_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ac_rec.customer_credit_class IS NOT NULL)) THEN
              k := 1;
              FOR ac_val_rec IN get_ac_values(ac_tbl(i).criteria_id) LOOP
                l_varchar_value_tbl(k) := ac_val_rec.crit_cat_value2;
                l_adjustment_factors_tbl(k) := ac_val_rec.adjustment_factor;
                k := k + 1;
              END LOOP;

              --this validate function will return either index in l_adjustment_factors_tbl
              --if match is found else it returns 0

              fun_ret := evaluate_customer_credit_class(l_varchar_value_tbl
                                                       ,p_okl_ac_rec.customer_credit_class);
              IF fun_ret <> 0 THEN
                l_adjustment_factor := l_adjustment_factor + l_adjustment_factors_tbl(fun_ret);
              END IF;
            END IF;
          END IF;
          IF (ac_tbl(i).ac_name = 'DEAL SIZE') THEN
            IF ((p_okl_ac_rec.target_eff_from BETWEEN ac_tbl(i).effective_from_date AND nvl(ac_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ac_rec.deal_size IS NOT NULL)) THEN
              OPEN get_ac_values(ac_tbl(i).criteria_id);
              FETCH get_ac_values INTO l_operator_code
                                      ,l_value1
                                      ,l_value2
                                      ,l_adj_fctr ;
              CLOSE get_ac_values;

              --this function will return either 1 or 0

              fun_ret := evaluate_deal_size(l_value1
                                           ,l_value2
                                           ,p_okl_ac_rec.deal_size);
              IF fun_ret <> 0 THEN
                l_adjustment_factor := l_adjustment_factor + l_adj_fctr;
              END IF;

            --dbms_output.put_line('fun_ret deal size =  '||fun_ret);

            END IF;
          END IF;
          IF (ac_tbl(i).ac_name = 'TERM') THEN
            IF ((p_okl_ac_rec.target_eff_from BETWEEN ac_tbl(i).effective_from_date AND nvl(ac_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ac_rec.term IS NOT NULL)) THEN
              k := 1;
              FOR ac_val_rec IN get_ac_values(ac_tbl(i).criteria_id) LOOP
                l_num_value_tbl(k) := fnd_number.canonical_to_number(ac_val_rec.crit_cat_value1);
                l_adjustment_factors_tbl(k) := ac_val_rec.adjustment_factor;

                --dbms_output.put_line('l_num_value_tbl(k) =  '||l_num_value_tbl(k));

                k := k + 1;
              END LOOP;

              --dbms_output.put_line('ac_tbl(i).match_criteria_code= '||ac_tbl(i).match_criteria_code);
              --this validate function will return either index in l_adjustment_factors_tbl
              --if match is found else it returns 0

              fun_ret := evaluate_term(l_num_value_tbl, p_okl_ac_rec.term);
              IF fun_ret <> 0 THEN
                l_adjustment_factor := l_adjustment_factor + l_adjustment_factors_tbl(fun_ret);
              END IF;
            END IF;
          END IF;
          IF (ac_tbl(i).ac_name = 'TERRITORY') THEN
            IF ((p_okl_ac_rec.target_eff_from BETWEEN ac_tbl(i).effective_from_date AND nvl(ac_tbl(i).effective_to_date
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy')))
                AND (p_okl_ac_rec.territory IS NOT NULL)) THEN
              k := 1;
              FOR ac_val_rec IN get_ac_values(ac_tbl(i).criteria_id) LOOP
                l_varchar_value_tbl(k) := ac_val_rec.crit_cat_value2;
                l_adjustment_factors_tbl(k) := ac_val_rec.adjustment_factor;
                k := k + 1;
              END LOOP;

              --this validate function will return either 1 or 0 only
              --this validate function will return either index in l_adjustment_factors_tbl
              --if match is found else it returns 0

              fun_ret := evaluate_territory(l_varchar_value_tbl
                                           ,p_okl_ac_rec.territory);
              IF fun_ret <> 0 THEN
                l_adjustment_factor := l_adjustment_factor + l_adjustment_factors_tbl(fun_ret);
              END IF;
            END IF;
          END IF;
        END IF;  --of Seeded_yn= Y
      END LOOP;

      --set G_ac_REC global variable to be used in user defined function to access values of p_okl_ac_rec

      g_ac_rec := p_okl_ac_rec;

      --call evaluation function attached to user defined criteri

      FOR i IN ac_tbl.FIRST..ac_tbl.LAST LOOP
        IF ac_tbl(i).seeded_yn = 'N' THEN
          IF (p_okl_ac_rec.target_eff_from BETWEEN ac_tbl(i).effective_from_date AND nvl(ac_tbl(i).effective_to_date
                                                                                        ,to_date('01-01-9999'
                                                                                                ,'dd-mm-yyyy'))) THEN
            k := 1;
            FOR ac_val_rec IN get_ac_values(ac_tbl(i).criteria_id) LOOP
              l_ac_values_tbl(k).operator_code := ac_val_rec.operator_code;
              l_ac_values_tbl(k).value1 := ac_val_rec.crit_cat_value1;
              l_ac_values_tbl(k).value2 := ac_val_rec.crit_cat_value2;
              l_adjustment_factors_tbl(k) := ac_val_rec.adjustment_factor;
              k := k + 1;
            END LOOP;
            g_ac_values_tbl := l_ac_values_tbl;

            --call the execute function API
            l_function_name := ac_tbl(i).EVALUATION_FUNCTION;
            okl_execute_formula_pvt.execute_eligibility_criteria (   p_api_version   => l_api_version,
                                                                     p_init_msg_list => l_init_msg_list,
                                                                     x_return_status => l_return_status,
                                                                     x_msg_count     => l_msg_count,
                                                                     x_msg_data      => l_msg_data,
                                                                     p_function_name => l_function_name,
                                                                     x_value         => fun_ret
                                                                 );
            IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'okl_execute_formula_pvt.execute_eligibility_criteria returned with status ' ||
                                        l_return_status ||
                                        ' x_msg_data ' ||
                                        l_msg_data);
            END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
            END IF;

            IF fun_ret <> 0 AND l_adjustment_factors_tbl.EXISTS(fun_ret) THEN
              l_adjustment_factor := l_adjustment_factor + l_adjustment_factors_tbl(fun_ret);
            END IF;
          END IF;
        END IF;  -- of Seeded_yn =N
      END LOOP;

    END IF;  -- of If ac_tbl.count > 0

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call get_adjustment_factor');
    END IF;
    x_adjustment_factor := l_adjustment_factor;
    x_return_status := okl_api.g_ret_sts_success;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        IF get_ac%ISOPEN THEN
          CLOSE get_ac;
        END IF;

        IF get_ac_values%ISOPEN THEN
          CLOSE get_ac_values;
        END IF;
        x_return_status := okl_api.g_ret_sts_error;

      WHEN okl_api.g_exception_unexpected_error THEN
        IF get_ac%ISOPEN THEN
          CLOSE get_ac;
        END IF;

        IF get_ac_values%ISOPEN THEN
          CLOSE get_ac_values;
        END IF;
        x_return_status := okl_api.g_ret_sts_unexp_error;

      WHEN OTHERS THEN

        IF get_ac%ISOPEN THEN
          CLOSE get_ac;
        END IF;

        IF get_ac_values%ISOPEN THEN
          CLOSE get_ac_values;
        END IF;
        -- unexpected error
        OKL_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);
  END get_adjustment_factor;
/**
    This function checks the existenace of at lease one scenario wherein
    common eligibility criteria defined on both the sources can be passed
    successfully.If such scenario exists function returns true else false.
    If there are no common eligibility criteria no comparison is done and
    function returns true.
**/

  FUNCTION compare_eligibility_criteria(p_source_id1    IN  number
                                       ,p_source_type1  IN  varchar2
                                       ,p_source_id2    IN  number
                                       ,p_source_type2  IN  varchar2) RETURN boolean IS

    CURSOR get_ec(src_id        IN  number
                 ,src_obj_code  IN  varchar2) IS
      SELECT a.validation_code
            ,b.criteria_id
            ,b.match_criteria_code
            ,b.effective_from_date
            ,b.effective_to_date
            ,c.value_type_code
            ,c.data_type_code
            ,c.crit_cat_name ec_name
            ,c.crit_cat_def_id
      FROM   okl_fe_criteria_set a
            ,okl_fe_criteria b
            ,okl_fe_crit_cat_def_v c
      WHERE  a.criteria_set_id = b.criteria_set_id AND a.source_id = src_id
         AND a.source_object_code = src_obj_code
         AND b.crit_cat_def_id = c.crit_cat_def_id
         AND c.ecc_ac_flag = 'ECC';

    TYPE ec_tbl_type IS TABLE OF get_ec%ROWTYPE INDEX BY BINARY_INTEGER;

    CURSOR get_ec_values(ec_ln_id  IN  number) IS
      SELECT operator_code
            ,crit_cat_value1
            ,crit_cat_value2
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = ec_ln_id;
    ec1_tbl                        ec_tbl_type;
    ec2_tbl                        ec_tbl_type;
    l_ec1_value_tbl                okl_varchar2_table_type;
    l_ec2_value_tbl                okl_varchar2_table_type;
    l_ec1_operator_code            varchar2(30);
    l_ec2_operator_code            varchar2(30);
    l_ec1_value1                   varchar2(240);
    l_ec2_value1                   varchar2(240);
    l_ec1_value2                   varchar2(240);
    l_ec2_value2                   varchar2(240);
    l_ec1_numval1                  number;
    l_ec2_numval1                  number;
    l_ec1_numval2                  number;
    l_ec2_numval2                  number;
    l_ec1_dateval1                 date;
    l_ec2_dateval1                 date;
    l_ec1_dateval2                 date;
    l_ec2_dateval2                 date;
    l_match_found                  boolean;
    i                              number;
    j                              number;
    k                              number;
    l                              number;
    m                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_evaluate_pvt.compare_eligibility_criteria';
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
                             ,'begin debug OKLRECUB.pls.pls call compare_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    i := 1;

    FOR ec_rec IN get_ec(p_source_id1, p_source_type1) LOOP
      ec1_tbl(i).match_criteria_code := ec_rec.match_criteria_code;
      ec1_tbl(i).validation_code := ec_rec.validation_code;
      ec1_tbl(i).criteria_id := ec_rec.criteria_id;
      ec1_tbl(i).effective_from_date := ec_rec.effective_from_date;
      ec1_tbl(i).effective_to_date := ec_rec.effective_to_date;
      ec1_tbl(i).value_type_code := ec_rec.value_type_code;
      ec1_tbl(i).data_type_code := ec_rec.data_type_code;
      ec1_tbl(i).ec_name := ec_rec.ec_name;
      ec1_tbl(i).crit_cat_def_id := ec_rec.crit_cat_def_id;
      i := i + 1;
    END LOOP;
    i := 1;

    FOR ec_rec IN get_ec(p_source_id2, p_source_type2) LOOP
      ec2_tbl(i).match_criteria_code := ec_rec.match_criteria_code;
      ec2_tbl(i).validation_code := ec_rec.validation_code;
      ec2_tbl(i).criteria_id := ec_rec.criteria_id;
      ec2_tbl(i).effective_from_date := ec_rec.effective_from_date;
      ec2_tbl(i).effective_to_date := ec_rec.effective_to_date;
      ec2_tbl(i).value_type_code := ec_rec.value_type_code;
      ec2_tbl(i).data_type_code := ec_rec.data_type_code;
      ec2_tbl(i).ec_name := ec_rec.ec_name;
      ec2_tbl(i).crit_cat_def_id := ec_rec.crit_cat_def_id;
      i := i + 1;
    END LOOP;

    --dbms_output.put_line('ec1_tbl.count= '||ec1_tbl.count);
    --dbms_output.put_line('ec2_tbl.count =  '||ec2_tbl.count);

    IF ec1_tbl.COUNT > 0 AND ec2_tbl.COUNT > 0 THEN
      IF ec1_tbl(1).validation_code = 'ERROR' AND ec2_tbl(1).validation_code = 'ERROR' THEN

        FOR i IN ec1_tbl.FIRST..ec1_tbl.LAST LOOP
          FOR j IN ec2_tbl.FIRST..ec2_tbl.LAST LOOP

            --dbms_output.put_line('ec1_tbl(i).crit_Cat_def_id = '||ec1_tbl(i).crit_Cat_def_id );
            --dbms_output.put_line(' ec2_tbl(j).crit_Cat_def_id = '||ec2_tbl(j).crit_Cat_def_id);

            IF ec1_tbl(i).crit_cat_def_id = ec2_tbl(j).crit_cat_def_id THEN
              IF ec1_tbl(i).effective_from_date BETWEEN ec2_tbl(j).effective_from_date AND nvl(ec2_tbl(j).effective_to_date
                                                                                              ,to_date('01-01-9999'
                                                                                                      ,'dd-mm-yyyy'))
                 OR ec2_tbl(j).effective_from_date BETWEEN ec1_tbl(i).effective_from_date AND nvl(ec1_tbl(i).effective_to_date
                                                                                                 ,to_date('01-01-9999'
                                                                                                         ,'dd-mm-yyyy')) THEN

                --dbms_output.put_line('Common EC Found ec1_tbl(i).crit_Cat_def_id = '||ec1_tbl(i).crit_Cat_def_id );

                IF ec1_tbl(i).value_type_code = 'RANGE' THEN

                  --dbms_output.put_line('value type= range ');

                  OPEN get_ec_values(ec1_tbl(i).criteria_id);
                  FETCH get_ec_values INTO l_ec1_operator_code
                                          ,l_ec1_value1
                                          ,l_ec1_value2 ;
                  CLOSE get_ec_values;
                  OPEN get_ec_values(ec2_tbl(j).criteria_id);
                  FETCH get_ec_values INTO l_ec2_operator_code
                                          ,l_ec2_value1
                                          ,l_ec2_value2 ;
                  CLOSE get_ec_values;
                  IF ec1_tbl(i).data_type_code = 'NUMBER' THEN

                    --dbms_output.put_line('datatype = number  ');

                    l_ec1_numval1 := fnd_number.canonical_to_number(l_ec1_value1);
                    l_ec1_numval2 := fnd_number.canonical_to_number(l_ec1_value2);
                    l_ec2_numval1 := fnd_number.canonical_to_number(l_ec2_value1);
                    l_ec2_numval2 := fnd_number.canonical_to_number(l_ec2_value2);

                    --dbms_output.put_line(' l_ec1_numval1= '||l_ec1_numval1);
                    --dbms_output.put_line(' l_ec1_numval2= '||l_ec1_numval2);
                    --dbms_output.put_line(' l_ec2_numval1= '||l_ec2_numval1);
                    --dbms_output.put_line(' l_ec2_numval2= '||l_ec2_numval2);

                    IF NOT (l_ec1_numval1 BETWEEN l_ec2_numval1 AND l_ec2_numval2
                            OR l_ec2_numval1 BETWEEN l_ec1_numval1 AND l_ec1_numval2) THEN
                      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                        okl_debug_pub.log_debug(fnd_log.level_procedure
                                               ,l_module
                                               ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                      END IF;
                      RETURN false;
                    END IF;
                  ELSIF ec1_tbl(i).data_type_code = 'DATE' THEN
                    l_ec1_dateval1 := fnd_date.canonical_to_date(l_ec1_value1);
                    l_ec1_dateval2 := fnd_date.canonical_to_date(l_ec1_value2);
                    l_ec2_dateval1 := fnd_date.canonical_to_date(l_ec2_value1);
                    l_ec2_dateval2 := fnd_date.canonical_to_date(l_ec2_value2);
                    IF NOT (l_ec1_dateval1 BETWEEN l_ec2_dateval1 AND l_ec2_dateval2
                            OR l_ec2_dateval1 BETWEEN l_ec1_dateval1 AND l_ec1_dateval2) THEN
                      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                        okl_debug_pub.log_debug(fnd_log.level_procedure
                                               ,l_module
                                               ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                      END IF;
                      RETURN false;
                    END IF;
                  END IF;
                ELSIF ec1_tbl(i).value_type_code = 'MULTIPLE' THEN
                  k := 1;
                  FOR ec_val_rec IN get_ec_values(ec1_tbl(i).criteria_id) LOOP
                    l_ec1_value_tbl(k) := ec_val_rec.crit_cat_value2;
                    k := k + 1;
                  END LOOP;
                  k := 1;
                  FOR ec_val_rec IN get_ec_values(ec2_tbl(j).criteria_id) LOOP
                    l_ec2_value_tbl(k) := ec_val_rec.crit_cat_value2;
                    k := k + 1;
                  END LOOP;
                  IF ec1_tbl(i).match_criteria_code = 'INCLUDE' AND ec2_tbl(j).match_criteria_code = 'INCLUDE' THEN
                    l_match_found := false;

                    <<loop1>>
                    FOR l IN l_ec1_value_tbl.FIRST..l_ec1_value_tbl.LAST LOOP
                      FOR m IN l_ec2_value_tbl.FIRST..l_ec2_value_tbl.LAST LOOP
                        IF l_ec1_value_tbl(l) = l_ec2_value_tbl(m) THEN
                          l_match_found := true;
                          EXIT loop1;
                        END IF;
                      END LOOP;
                    END LOOP;
                    IF NOT l_match_found THEN
                      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                        okl_debug_pub.log_debug(fnd_log.level_procedure
                                               ,l_module
                                               ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                      END IF;
                      RETURN false;
                    END IF;
                  ELSIF ec1_tbl(i).match_criteria_code = 'INCLUDE'
                        AND ec2_tbl(j).match_criteria_code = 'EXCLUDE' THEN

                    <<loop2>>
                    FOR l IN l_ec1_value_tbl.FIRST..l_ec1_value_tbl.LAST LOOP
                      l_match_found := false;
                      FOR m IN l_ec2_value_tbl.FIRST..l_ec2_value_tbl.LAST LOOP
                        IF l_ec1_value_tbl(l) = l_ec2_value_tbl(m) THEN
                          l_match_found := true;
                        END IF;
                      END LOOP;
                      IF NOT l_match_found THEN
                        EXIT loop2;
                      END IF;
                    END LOOP;
                    IF l_match_found THEN
                      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                        okl_debug_pub.log_debug(fnd_log.level_procedure
                                               ,l_module
                                               ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                      END IF;
                      RETURN false;
                    END IF;
                  ELSIF ec1_tbl(i).match_criteria_code = 'EXCLUDE'
                        AND ec2_tbl(j).match_criteria_code = 'INCLUDE' THEN

                    <<loop3>>
                    FOR l IN l_ec2_value_tbl.FIRST..l_ec2_value_tbl.LAST LOOP
                      l_match_found := false;
                      FOR m IN l_ec1_value_tbl.FIRST..l_ec1_value_tbl.LAST LOOP
                        IF l_ec2_value_tbl(l) = l_ec1_value_tbl(m) THEN
                          l_match_found := true;
                        END IF;
                      END LOOP;
                      IF NOT l_match_found THEN
                        EXIT loop3;
                      END IF;
                    END LOOP;
                    IF l_match_found THEN
                      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                        okl_debug_pub.log_debug(fnd_log.level_procedure
                                               ,l_module
                                               ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                      END IF;
                      RETURN false;
                    END IF;
                  END IF;
                ELSE  -- value_type= 'SINGLE'
                  OPEN get_ec_values(ec1_tbl(i).criteria_id);
                  FETCH get_ec_values INTO l_ec1_operator_code
                                          ,l_ec1_value1
                                          ,l_ec1_value2 ;
                  CLOSE get_ec_values;
                  OPEN get_ec_values(ec2_tbl(j).criteria_id);
                  FETCH get_ec_values INTO l_ec2_operator_code
                                          ,l_ec2_value1
                                          ,l_ec2_value2 ;
                  CLOSE get_ec_values;
                  IF ec1_tbl(i).data_type_code = 'NUMBER' THEN
                    l_ec1_numval1 := fnd_number.canonical_to_number(l_ec1_value1);
                    l_ec2_numval1 := fnd_number.canonical_to_number(l_ec2_value1);
                    IF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_numval1 <> l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'NE' THEN
                      IF l_ec1_numval1 >= l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'LT' THEN
                      IF l_ec1_numval1 >= l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'GT' THEN
                      IF l_ec1_numval1 <= l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'NE' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_numval1 = l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'LT' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_numval1 <= l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'LT' AND l_ec2_operator_code = 'GT' THEN
                      IF l_ec1_numval1 - l_ec2_numval1 <= 1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'GT' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_numval1 >= l_ec2_numval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'GT' AND l_ec2_operator_code = 'LT' THEN
                      IF l_ec2_numval1 - l_ec1_numval1 <= 1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    END IF;
                  ELSIF ec1_tbl(i).data_type_code = 'DATE' THEN
                    l_ec1_dateval1 := fnd_date.canonical_to_date(l_ec1_value1);
                    l_ec2_dateval1 := fnd_date.canonical_to_date(l_ec2_value1);
                    IF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_dateval1 <> l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'NE' THEN
                      IF l_ec1_dateval1 >= l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'LT' THEN
                      IF l_ec1_dateval1 >= l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'GT' THEN
                      IF l_ec1_dateval1 <= l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'NE' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_dateval1 = l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'LT' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_dateval1 <= l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'LT' AND l_ec2_operator_code = 'GT' THEN
                      IF l_ec1_dateval1 - l_ec2_dateval1 <= 1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'GT' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_dateval1 >= l_ec2_dateval1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'GT' AND l_ec2_operator_code = 'LT' THEN
                      IF l_ec2_dateval1 - l_ec1_dateval1 <= 1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    END IF;
                  ELSIF ec1_tbl(i).data_type_code = 'VARCHAR2' THEN
                    IF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_value1 <> l_ec2_value1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'EQ' AND l_ec2_operator_code = 'NE' THEN
                      IF l_ec1_value1 >= l_ec2_value1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    ELSIF l_ec1_operator_code = 'NE' AND l_ec2_operator_code = 'EQ' THEN
                      IF l_ec1_value1 = l_ec2_value1 THEN
                        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                          okl_debug_pub.log_debug(fnd_log.level_procedure
                                                 ,l_module
                                                 ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
                        END IF;
                        RETURN false;
                      END IF;
                    END IF;
                  END IF;  --of data type check
                END IF;  --of value type check
              END IF;  --of date overlap check
            END IF;  --of same ec check
          END LOOP;
        END LOOP;

      END IF;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call compare_eligibility_criteria');
    END IF;
    RETURN true;
  END compare_eligibility_criteria;

END okl_ec_evaluate_pvt;

/
