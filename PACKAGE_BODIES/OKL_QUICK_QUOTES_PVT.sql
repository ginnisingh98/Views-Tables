--------------------------------------------------------
--  DDL for Package Body OKL_QUICK_QUOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QUICK_QUOTES_PVT" AS
/* $Header: OKLRQQHB.pls 120.37.12010000.3 2008/11/13 13:33:45 kkorrapo ship $ */
  -- subtype records used during pricing
  SUBTYPE pricing_results_tbl_type IS OKL_PRICING_UTILS_PVT.pricing_results_tbl_type;
  SUBTYPE yields_rec IS OKL_PRICING_UTILS_PVT.yields_rec;
  SUBTYPE so_cash_flows_rec_type IS OKL_PRICING_UTILS_PVT.so_cash_flows_rec_type;
  SUBTYPE so_cash_flow_details_tbl_type IS OKL_PRICING_UTILS_PVT.so_cash_flow_details_tbl_type;
  SUBTYPE qa_results_tbl_type IS OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type;

  user_exception exception;

  FUNCTION validate_header(p_qqhv_rec_type  IN  qqhv_rec_type) RETURN VARCHAR2 IS

   CURSOR chk_uniquness IS
      SELECT 'x'
      FROM okl_quick_quotes_b
      WHERE  reference_number = p_qqhv_rec_type.reference_number
      AND    id <> NVL(p_qqhv_rec_type.id, -9999);

    l_dummy_var              VARCHAR2(1);
    x_return_status          VARCHAR2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT VARCHAR2(61) := g_pkg_name || '.' || 'validate_header';
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

  BEGIN

    OPEN chk_uniquness; -- QQ Reference Number should be unique
    FETCH chk_uniquness INTO l_dummy_var;
    CLOSE chk_uniquness;  -- if l_dummy_var is 'x' then Ref Num already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             'OKL_DUPLICATE_CURE_REQUEST'
                         ,p_token1       =>             'COL_NAME'
                         ,p_token1_value =>             p_qqhv_rec_type.reference_number);
      RAISE okl_api.g_exception_error;
    END IF;

    RETURN x_return_status;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                l_msg_count
                                                    ,x_msg_data  =>                l_msg_data
                                                    ,p_api_type  =>                g_api_type);
        RETURN x_return_status;
  END validate_header;

  PROCEDURE create_qqh(p_api_version    IN             NUMBER
		      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
		      ,x_return_status     OUT NOCOPY  VARCHAR2
		      ,x_msg_count         OUT NOCOPY  NUMBER
		      ,x_msg_data          OUT NOCOPY  VARCHAR2
		      ,p_qqhv_rec_type  IN             qqhv_rec_type
		      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type ) IS

    lp_qqhv_rec_type               qqhv_rec_type;
    lx_qqhv_rec_type               qqhv_rec_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.CREATE_QQH';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'create_qqh';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := nvl(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call create_qqh');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);

    lp_qqhv_rec_type := p_qqhv_rec_type;

    l_return_status := validate_header(lp_qqhv_rec_type);  --validate header
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN -- write to log
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Function okl_quick_quotes_pvt.validate_header returned with status ' ||
                              l_return_status);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    okl_qqh_pvt.insert_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_qqhv_rec_type
                          ,lx_qqhv_rec_type);  -- write to log

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_qqh_pvt.insert_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    x_qqhv_rec_type := lx_qqhv_rec_type;

    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call create_qqh');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END create_qqh;

  PROCEDURE create_qql(p_api_version            IN             NUMBER
			      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
			      ,x_return_status     OUT NOCOPY  VARCHAR2
			      ,x_msg_count         OUT NOCOPY  NUMBER
			      ,x_msg_data          OUT NOCOPY  VARCHAR2
			      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
			      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type) IS

    lp_qqlv_tbl_type               qqlv_tbl_type;
    lx_qqlv_tbl_type               qqlv_tbl_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.CREATE_QQL';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'create_qql';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := nvl(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call create_qql');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    lp_qqlv_tbl_type := p_qqlv_tbl_type;

      okl_qql_pvt.insert_row(p_api_version
                            ,okl_api.g_false
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,lp_qqlv_tbl_type
                            ,lx_qqlv_tbl_type);  -- write to log

      IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'okl_qql_pvt.insert_row returned with status ' ||
                                l_return_status ||
                                ' x_msg_data ' ||
                                x_msg_data);

      END IF;  -- end of l_debug_enabled ='Y'

      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

    --Assign value to OUT variables
    x_qqlv_tbl_type := lx_qqlv_tbl_type;

    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call create_qql');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END create_qql;

  PROCEDURE create_quick_qte(p_api_version      IN             NUMBER
			      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
			      ,x_return_status     OUT NOCOPY  VARCHAR2
			      ,x_msg_count         OUT NOCOPY  NUMBER
			      ,x_msg_data          OUT NOCOPY  VARCHAR2
			      ,p_qqhv_rec_type  IN             qqhv_rec_type
			      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type
			      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
			      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type) IS

    lp_qqhv_rec_type               qqhv_rec_type;
    lx_qqhv_rec_type               qqhv_rec_type;
    lp_qqlv_tbl_type               qqlv_tbl_type;
    lx_qqlv_tbl_type               qqlv_tbl_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.CREATE_QUICK_QTE';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'create_quick_qte';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;
    i                              NUMBER;

  BEGIN
    l_debug_enabled := nvl(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call create_quick_qte');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    lp_qqhv_rec_type := p_qqhv_rec_type;
    lp_qqlv_tbl_type := p_qqlv_tbl_type;

	okl_quick_quotes_pvt.create_qqh(
	               p_api_version    => p_api_version
		      ,p_init_msg_list  => okl_api.g_false
		      ,x_return_status  => l_return_status
		      ,x_msg_count      => x_msg_count
		      ,x_msg_data       => x_msg_data
		      ,p_qqhv_rec_type  => lp_qqhv_rec_type
		      ,x_qqhv_rec_type  => lx_qqhv_rec_type);


    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_quick_quotes_pvt.create_qqh returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    -- populate the foreign key
    FOR i in lp_qqlv_tbl_type.first..lp_qqlv_tbl_type.last LOOP
      lp_qqlv_tbl_type(i).quick_quote_id:=lx_qqhv_rec_type.id;
    END LOOP;

       okl_quick_quotes_pvt.create_qql(
                 p_api_version   => p_api_version
		,p_init_msg_list => okl_api.g_false
		,x_return_status => l_return_status
		,x_msg_count     => x_msg_count
		,x_msg_data      => x_msg_data
		,p_qqlv_tbl_type => lp_qqlv_tbl_type
		,x_qqlv_tbl_type => lx_qqlv_tbl_type);

      IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'okl_quick_quotes_pvt.create_qql returned with status ' ||
                                l_return_status ||
                                ' x_msg_data ' ||
                                x_msg_data);
      END IF;  -- end of l_debug_enabled ='Y'

      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

    x_qqhv_rec_type := lx_qqhv_rec_type;
    x_qqlv_tbl_type := lx_qqlv_tbl_type;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call create_qq');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END create_quick_qte;

  PROCEDURE update_qqh (p_api_version   IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqhv_rec_type  IN             qqhv_rec_type
                      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type) IS
    lp_qqhv_rec_type               qqhv_rec_type;
    lx_qqhv_rec_type               qqhv_rec_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.UPDATE_QQH';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'update_qqh';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call update_qqh');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    lp_qqhv_rec_type := p_qqhv_rec_type;

		-- schodava Bug # 4923350
		-- Nulling out Rate Template/Card depending on the
		-- structured pricing value
		IF (lp_qqhv_rec_type.structured_pricing = 'Y') THEN
			-- For Standard Rate Template, nullify LRF
			IF lp_qqhv_rec_type.rate_template_id IS NOT NULL THEN
				lp_qqhv_rec_type.lease_rate_factor := fnd_api.g_miss_num;
			END IF;
			lp_qqhv_rec_type.rate_template_id := fnd_api.g_miss_num;
			lp_qqhv_rec_type.rate_card_id := fnd_api.g_miss_num;
		ELSIF (lp_qqhv_rec_type.structured_pricing = 'N') THEN
			lp_qqhv_rec_type.lease_rate_factor := fnd_api.g_miss_num;
			-- For Standard Rate Template, nullify Rate Card Id and vice versa
			IF lp_qqhv_rec_type.rate_template_id IS NOT NULL THEN
				lp_qqhv_rec_type.rate_card_id := fnd_api.g_miss_num;
			ELSE
				lp_qqhv_rec_type.rate_template_id := fnd_api.g_miss_num;
			END IF;
		END IF;

    okl_qqh_pvt.update_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_qqhv_rec_type
                          ,lx_qqhv_rec_type);  -- write to log

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_qqh_pvt.update_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    x_qqhv_rec_type := lx_qqhv_rec_type;

    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call update_qqh');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END update_qqh;
--start abhsaxen 22-Dec-2005
  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By     : abhsaxen
    -- Procedure Name : cancel_quick_quote
    -- Description    : Procedure functions to apply change in status of
    --                  quick quote from active to cancel
    -- Dependencies   :
    -- Parameters     :
    -- Version        : 1.0
    -- End of Comments
  -----------------------------------------------------------------------------

procedure cancel_quick_quote(p_api_version   IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqhv_rec_type  IN             qqhv_rec_type
                      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type) IS
    lp_qqhv_rec_type               qqhv_rec_type;
    lx_qqhv_rec_type               qqhv_rec_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.CANCEL_QUICK_QUOTE';
    QQ_CANCELLED          CONSTANT okl_quick_quotes_b.sts_code%TYPE := 'CANCELLED';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'cancel_quick_quote';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call cancel_quick_quote');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    lp_qqhv_rec_type := p_qqhv_rec_type;
    lp_qqhv_rec_type.sts_code := QQ_CANCELLED;
    okl_qqh_pvt.update_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_qqhv_rec_type
                          ,lx_qqhv_rec_type);  -- write to log

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_qqh_pvt.update_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    x_qqhv_rec_type := lx_qqhv_rec_type;

    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call cancel_quick_quote');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
END cancel_quick_quote;


--end abhsaxen 22-Dec-2005



  PROCEDURE update_qql (p_api_version   IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
                      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type) IS

    lp_qqlv_tbl_type               qqlv_tbl_type := p_qqlv_tbl_type;  --dkagrawa assigned the in value
    lx_qqlv_tbl_type               qqlv_tbl_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.UPDATE_QQL';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'update_qql';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call update_qql');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    IF lp_qqlv_tbl_type.COUNT > 0 THEN

        okl_qql_pvt.update_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_qqlv_tbl_type
                              ,lx_qqlv_tbl_type);  -- write to log
        IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_qql_pvt.update_row returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of l_debug_enabled ='Y'
        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;

    END IF;

    --Assign value to OUT variables

    x_qqlv_tbl_type := lx_qqlv_tbl_type;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call update_qql');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END update_qql;

  PROCEDURE update_quick_qte(p_api_version      IN             NUMBER
			      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
			      ,x_return_status     OUT NOCOPY  VARCHAR2
			      ,x_msg_count         OUT NOCOPY  NUMBER
			      ,x_msg_data          OUT NOCOPY  VARCHAR2
			      ,p_qqhv_rec_type  IN             qqhv_rec_type
			      ,x_qqhv_rec_type      OUT NOCOPY qqhv_rec_type
			      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
			      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type) IS

    lp_qqhv_rec_type               qqhv_rec_type;
    lx_qqhv_rec_type               qqhv_rec_type;
    lp_qqlv_tbl_type               qqlv_tbl_type;
    lx_qqlv_tbl_type               qqlv_tbl_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.UPDATE_QUICK_QTE';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'update_quick_qte';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call update_quick_qte');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    lp_qqhv_rec_type := p_qqhv_rec_type;
    lp_qqlv_tbl_type := p_qqlv_tbl_type;

	okl_quick_quotes_pvt.update_qqh(
	         p_api_version   => p_api_version
		,p_init_msg_list => okl_api.g_false
		,x_return_status => l_return_status
		,x_msg_count     => x_msg_count
		,x_msg_data      => x_msg_data
		,p_qqhv_rec_type => lp_qqhv_rec_type
		,x_qqhv_rec_type => lx_qqhv_rec_type
		);

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_quick_quotes_pvt.update_qqh returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

	okl_quick_quotes_pvt.update_qql(
	           p_api_version   => p_api_version
		  ,p_init_msg_list => okl_api.g_false
		  ,x_return_status => l_return_status
		  ,x_msg_count     => x_msg_count
		  ,x_msg_data      => x_msg_data
		  ,p_qqlv_tbl_type => lp_qqlv_tbl_type
		  ,x_qqlv_tbl_type => lx_qqlv_tbl_type
		  );

        IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_quick_quotes_pvt.update_qql returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of l_debug_enabled ='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;

    x_qqhv_rec_type := lx_qqhv_rec_type;
    x_qqlv_tbl_type := lx_qqlv_tbl_type;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call update_quick_qte');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END update_quick_qte;

  PROCEDURE delete_qql(p_api_version    IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqlv_rec_type   IN            qqlv_rec_type) IS

  l_api_name		CONSTANT VARCHAR2(30) := 'delete_qql';
  l_api_version		CONSTANT NUMBER       := 1.0;
  l_return_status		 VARCHAR2(1)   := okl_api.g_ret_sts_success;
  l_qqlv_rec			 qqlv_rec_type := p_qqlv_rec_type;
  l_module		CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.DELETE_QQL';
  l_debug_enabled		 VARCHAR2(10);
  is_debug_procedure_on          BOOLEAN;
  is_debug_statement_on          BOOLEAN;

BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call delete_qql');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                             ,p_pkg_name      => g_pkg_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,l_api_version   => l_api_version
                                             ,p_api_version   => p_api_version
                                             ,p_api_type      => g_api_type
                                             ,x_return_status => x_return_status);  -- check if activity started successfully

      okl_qql_pvt.delete_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_qqlv_rec      => l_qqlv_rec);

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_qql_pvt.delete_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    x_return_status := l_return_status;
    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call delete_qql');
    END IF;

EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END delete_qql;

  PROCEDURE delete_qql(p_api_version    IN             NUMBER
                      ,p_init_msg_list  IN             VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  VARCHAR2
                      ,x_msg_count         OUT NOCOPY  NUMBER
                      ,x_msg_data          OUT NOCOPY  VARCHAR2
                      ,p_qqlv_tbl_type  IN             qqlv_tbl_type) IS

  l_api_name		CONSTANT VARCHAR2(30) := 'delete_qql';
  l_api_version		CONSTANT NUMBER       := 1.0;
  l_return_status		 VARCHAR2(1) := okl_api.g_ret_sts_success;
  l_qqlv_tbl			 qqlv_tbl_type := p_qqlv_tbl_type;
  l_module		CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.DELETE_QQL';
  l_debug_enabled		 VARCHAR2(10);
  is_debug_procedure_on          BOOLEAN;
  is_debug_statement_on          BOOLEAN;

BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call delete_qql');
    END IF;  -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                             ,p_pkg_name      => g_pkg_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,l_api_version   => l_api_version
                                             ,p_api_version   => p_api_version
                                             ,p_api_type      => g_api_type
                                             ,x_return_status => x_return_status);  -- check if activity started successfully

      okl_qql_pvt.delete_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_qqlv_tbl      => l_qqlv_tbl);

    IF (l_debug_enabled = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_qql_pvt.delete_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of l_debug_enabled ='Y'

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    x_return_status := l_return_status;
    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call delete_qql');
    END IF;

EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END delete_qql;

--method to create or update the quick quote
PROCEDURE handle_quick_quote(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_qqhv_rec_type  IN             qqhv_rec_type
                      ,p_qqlv_tbl_type  IN             qqlv_tbl_type
                      ,p_cfh_rec_type   IN             cashflow_hdr_rec
                      ,p_cfl_tbl_type   IN             cashflow_level_tbl
                      ,p_commit         IN             varchar2
                      ,create_yn        IN             varchar2
                      ,x_payment_rec       OUT NOCOPY  payment_rec_type
                      ,x_rent_payments_tbl OUT NOCOPY  rent_payments_tbl
                      ,x_fee_payments_tbl  OUT NOCOPY  fee_service_payments_tbl
                      ,x_item_tbl          OUT NOCOPY  item_order_estimate_tbl
                      ,x_qqhv_rec_type     OUT NOCOPY  qqhv_rec_type
                      ,x_qqlv_tbl_type     OUT NOCOPY  qqlv_tbl_type
                      ) IS

  l_api_name		CONSTANT VARCHAR2(30) := 'handle_quick_quote';
  QQ_ACTIVE		CONSTANT okl_quick_quotes_b.sts_code%TYPE :='ACTIVE';
  l_api_version		CONSTANT NUMBER       := 1.0;
  l_return_status		 VARCHAR2(1) := okl_api.g_ret_sts_success;

  l_qqhv_rec_type			 qqhv_rec_type := p_qqhv_rec_type;
  l_qqlv_tbl_type            qqlv_tbl_type := p_qqlv_tbl_type;
  l_cfh_rec_type            cashflow_hdr_rec := p_cfh_rec_type;
  l_cfl_tbl_type            cashflow_level_tbl := p_cfl_tbl_type;
  l_cfh_other_rec            cashflow_hdr_rec ;
  l_cfl_other_tbl            cashflow_level_tbl ;
  lx_qqhv_rec_type			 qqhv_rec_type;
  lx_qqlv_tbl_type            qqlv_tbl_type;
  lxx_qqlv_tbl_type          qqlv_tbl_type;
  lp_qqlv_rec                qqlv_rec_type;
  lx_qqlv_rec                qqlv_rec_type;

  l_module		CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.handle_quick_quote';
  l_debug_enabled		 VARCHAR2(10);
  is_debug_procedure_on          BOOLEAN;
  is_debug_statement_on          BOOLEAN;
  l_item_name           VARCHAR2(240);
  l_description         VARCHAR2(240);
  l_so_details          so_cash_flow_details_tbl_type;

  l_update_cfh_rec      cashflow_hdr_rec;
  l_update_cfl_tbl      cashflow_level_tbl;
  l_cf_update_flag      VARCHAR2(1):='N';
  count_num             NUMBER;

  i NUMBER;
  j NUMBER :=1;
  k NUMBER;
  l_rate NUMBER;
  l_frequency VARCHAR2(1);
  line_number NUMBER;
  no_of_lines NUMBER;
  l_rate_factor NUMBER;
  l_total_asset_cost NUMBER:=0;
  l_total_rent_payment NUMBER:=0;
  rate_card_num NUMBER:=1;
  l_months_factor NUMBER;
  l_precision NUMBER;
  yield_prec  NUMBER :=4;
  l_oty_code VARCHAR2(100);
  l_count NUMBER;
  l_line_no NUMBER;
  l_cost NUMBER;

  l_yields_rec           yields_rec;
  sub_yields_rec         yields_rec;
  pricing_results_table  pricing_results_tbl_type;
  x_qa_result_tbl       qa_results_tbl_type;
  x_qa_result            VARCHAR2(10);

  -- cursor to get the frequency from SRT
  CURSOR get_srt(template_id IN NUMBER) IS
  SELECT hdr.frequency_code, ver.srt_rate
  FROM okl_fe_std_rt_tmp_all_b hdr, okl_fe_Std_rt_tmp_vers ver
  WHERE ver.std_rate_tmpl_ver_id = template_id AND
           hdr.std_rate_tmpl_id = ver.std_rate_tmpl_id;

  -- cursor to get the frequency from LRS
  CURSOR get_lrs(rate_card_id IN NUMBER) IS
   SELECT hdr.frq_code, ver.arrears_yn
   FROM okl_ls_rt_fctr_sets_v hdr,
         okl_fe_rate_set_versions_v ver
    WHERE ver.rate_set_id = hdr.id
     AND  ver.rate_set_version_id = rate_card_id;

  -- cursor to get the category name, descriotion for a category
   CURSOR get_cat_name(cp_category_id IN NUMBER) IS
   SELECT category_concat_segs item_name,
          description description
   FROM   mtl_categories_v
   WHERE  category_id  = cp_category_id;

  -- cursor to fetch the cashflow line details
  CURSOR get_cashflow_dtls(p_qqh_id IN NUMBER) IS
  SELECT levels.id LEVEL_ID,
         levels.amount AMOUNT,
         levels.number_of_periods NUMBER_OF_PERIODS,
         levels.stub_days STUB_DAYS,
         levels.stub_amount STUB_AMOUNT,
         levels.start_date START_DATE,
         levels.object_version_number ovn,
         ql.basis BASIS,
         flow.cft_code CFT_CODE,
         obj.id OBJ_ID,
         flow.id FLOW_ID,
         ql.id LINE_ID,
         levels.rate,
         ql.value VALUE
  FROM okl_cash_flow_objects obj, okl_cash_flows flow, okl_cash_flow_levels levels,
  okl_quick_quotes_b qh, okl_quick_quote_lines_b ql
  where obj.id= flow.cfo_id
  AND flow.id= levels.caf_id
  AND qh.id= ql.quick_quote_id
  AND obj.source_table='OKL_QUICK_QUOTE_LINES_B'
  AND obj.source_id= ql.id
  AND (ql.basis='ASSET_COST' or ql.basis='RENT')
  AND qh.id=p_qqh_id;

  --dkagrawa strat
  CURSOR get_precision_csr(p_currency_code VARCHAR2)
  IS
  SELECT NVL(cur.precision,0) precision
  FROM fnd_currencies cur
  WHERE cur.currency_code = p_currency_code;
  --dkagrawa end


  CURSOR get_oty_code(qql_id IN NUMBER) IS
  SELECT oty_code FROM okl_cash_flow_objects
  WHERE source_table= 'OKL_QUICK_QUOTE_LINES_B' AND source_id= qql_id;
  -- cursor to fetch the quick quote line ids for a particualr quick quote header
  CURSOR get_qq_lines(qqh_id IN NUMBER) IS
  SELECT id FROM okl_quick_quote_lines_b where quick_quote_id=qqh_id;

  -- cursor to fetch the fees and services
/* sosharma 08-Feb-2008 bug 6692055
Modified the cursor query get_line_dtls in OKL_QUICK_QUOTES_PVT.handle_quick_quote, so
that the composite index would be used.
Start Changes
*/
/*
  CURSOR get_line_dtls(p_qqh_id IN NUMBER) IS
  SELECT levels.amount AMOUNT,
         levels.number_of_periods NUMBER_OF_PERIODS,
         levels.start_date START_DATE,
         ql.TYPE TYPE
  FROM okl_cash_flow_objects obj, okl_cash_flows flow, okl_cash_flow_levels levels,
  okl_quick_quotes_b qh, okl_quick_quote_lines_b ql
  where obj.id= flow.cfo_id
  AND flow.id= levels.caf_id
  AND qh.id= ql.quick_quote_id
  AND obj.source_table='OKL_QUICK_QUOTE_LINES_B'
  AND obj.source_id= ql.id
  AND ql.type IN ('FEE_EXPENSE','FEE_PAYMENT','INSURANCE','TAX','SERVICE')
  AND qh.id=p_qqh_id;
*/
 CURSOR get_line_dtls(p_qqh_id IN NUMBER) IS
 SELECT LEVELS.AMOUNT AMOUNT, LEVELS.NUMBER_OF_PERIODS NUMBER_OF_PERIODS,
         LEVELS.START_DATE START_DATE, QL.TYPE TYPE
  FROM
    OKL_QUICK_QUOTES_B QH,
    OKL_QUICK_QUOTE_LINES_B QL,
    OKL_CASH_FLOW_OBJECTS OBJ,
    OKL_CASH_FLOWS FLOW,
    OKL_CASH_FLOW_LEVELS LEVELS,
    FND_LOOKUPS  LKP
  WHERE OBJ.ID= FLOW.CFO_ID
   AND FLOW.ID= LEVELS.CAF_ID
   AND QH.ID= QL.QUICK_QUOTE_ID
   AND LKP.LOOKUP_TYPE = 'OKL_CF_OBJECT_TYPE'
   /* The following 3 obj columns are part of the composite index CFO_COMP_I */
   AND OBJ.OTY_CODE = LKP.LOOKUP_CODE
   AND OBJ.SOURCE_TABLE='OKL_QUICK_QUOTE_LINES_B'
   AND OBJ.SOURCE_ID= QL.ID
   AND QL.TYPE IN ('FEE_EXPENSE','FEE_PAYMENT','INSURANCE','TAX','SERVICE')
   AND QH.ID=p_qqh_id;
/* sosharma end changes */


BEGIN
    l_debug_enabled := NVL(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call handle_quick_quote');
    END IF;
    -- check for logging at STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                             ,p_pkg_name      => g_pkg_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,l_api_version   => l_api_version
                                             ,p_api_version   => p_api_version
                                             ,p_api_type      => g_api_type
                                             ,x_return_status => x_return_status);  -- check if activity started successfully

    -- establish a savepoint to rollback when p_commit is N
    DBMS_TRANSACTION.SAVEPOINT('quick_quote_savepoint');

    -- calculate the total asset cost except for solve for financed amount
    FOR i in l_qqlv_tbl_type.FIRST..l_qqlv_tbl_type.LAST LOOP
      IF (l_qqhv_rec_type.pricing_method<>'SF' and l_qqlv_tbl_type(i).TYPE='ITEM_CATEGORY' ) THEN
        l_total_asset_cost:=l_total_asset_cost+ l_qqlv_tbl_type(i).VALUE;
      END IF;
    END LOOP;

    -- calculate the total rent payment except solve for rent payment
    IF (l_cfl_tbl_type.COUNT >0) THEN
    FOR i in l_cfl_tbl_type.FIRST..l_cfl_tbl_type.LAST LOOP
      IF (l_qqhv_rec_type.pricing_method<>'SP' AND l_qqhv_rec_type.pricing_method<>'RC' AND l_qqhv_rec_type.pricing_method<>'TR') THEN
			  -- Added check for stub amount to be added to the rent payment.
        IF (l_cfl_tbl_type(i).periodic_amount IS NOT NULL AND l_cfl_tbl_type(i).periods IS NOT NULL)THEN
          l_total_rent_payment:=l_total_rent_payment + l_cfl_tbl_type(i).periodic_amount*l_cfl_tbl_type(i).periods;
        ELSIF (l_cfl_tbl_type(i).stub_amount IS NOT NULL AND l_cfl_tbl_type(i).stub_days IS NOT NULL) THEN
          l_total_rent_payment:=l_total_rent_payment + l_cfl_tbl_type(i).stub_amount;
        END IF;
      END IF;
    END LOOP;
    --Fix Bug # 5184245 ssdeshpa start
    ELSIF(l_qqhv_rec_type.rate_template_id IS NOT NULL) THEN
      l_total_rent_payment:= l_qqhv_rec_type.term * nvl(l_qqhv_rec_type.target_amount,0);
    END IF;
    --Fix Bug # 5184245 ssdeshpa end
    IF l_qqhv_rec_type.target_frequency IS NOT NULL
    THEN
      -- getting the value of the frequency for the correspoding code
      l_months_factor := okl_stream_generator_pvt.get_months_factor(
                            p_frequency       =>   l_qqhv_rec_type.target_frequency,
                            x_return_status   =>   x_return_status);
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;
    -- Pricing Method:rate card and pricing option : Structured pricing
    IF (l_qqhv_rec_type.pricing_method='RC' AND l_qqhv_rec_type.structured_pricing= 'Y') THEN
      l_rate_factor:=l_qqhv_rec_type.lease_rate_factor;
      -- line level pricing
      IF(l_qqhv_rec_type.line_level_pricing='Y') THEN
         FOR i in l_qqlv_tbl_type.FIRST.. l_qqlv_tbl_type.LAST LOOP
           IF (l_qqlv_tbl_type(i).type= 'ITEM_CATEGORY' and l_qqlv_tbl_type(i).lease_rate_factor is null) THEN
              l_qqlv_tbl_type(i).lease_rate_factor := l_rate_factor;
           END IF;
         END LOOP;
      -- line level pricing disabled
      ELSE
        FOR i in l_qqlv_tbl_type.FIRST.. l_qqlv_tbl_type.LAST LOOP
           IF (l_qqlv_tbl_type(i).type= 'ITEM_CATEGORY' ) THEN
              l_qqlv_tbl_type(i).lease_rate_factor := l_rate_factor;
           END IF;
         END LOOP;
      END IF;
    END IF;

    -- populating the target period in the case of Pricing Method 'Target Rate'
    IF (l_qqhv_rec_type.pricing_method='TR'or l_qqhv_rec_type.pricing_method='RC' or
        l_qqhv_rec_type.rate_template_id is not null) THEN
       IF (l_qqhv_rec_type.rate_card_id is not null) THEN
          -- lease rate set
          OPEN get_lrs(l_qqhv_rec_type.rate_card_id);
          FETCH get_lrs INTO l_frequency, l_qqhv_rec_type.TARGET_ARREARS;
          CLOSE get_lrs;

          l_months_factor := okl_stream_generator_pvt.get_months_factor(
                            p_frequency       =>   l_frequency,
                            x_return_status   =>   x_return_status);
          l_qqhv_rec_type.target_periods := l_qqhv_rec_type.term/l_months_factor;

       ELSIF (l_qqhv_rec_type.rate_template_id is not null) THEN
          -- for an SRT , populate the target periods column
          OPEN get_srt(l_qqhv_rec_type.rate_template_id);
          FETCH get_srt INTO l_frequency, l_rate;
          CLOSE get_srt;

          l_months_factor := okl_stream_generator_pvt.get_months_factor(
                            p_frequency       =>   l_frequency,
                            x_return_status   =>   x_return_status);

          l_qqhv_rec_type.target_periods := l_qqhv_rec_type.term/l_months_factor;
       ELSE
          l_qqhv_rec_type.target_periods := l_qqhv_rec_type.term/l_months_factor;
          -- setting the value of l_frequency
          l_frequency:=l_qqhv_rec_type.target_frequency;

       END IF;
    END IF;

    --dkagrawa strat
    IF l_qqhv_rec_type.currency_code IS NOT NULL
    THEN
      OPEN  get_precision_csr(l_qqhv_rec_type.currency_code);
      FETCH get_precision_csr INTO l_precision;
      CLOSE get_precision_csr;
    END IF;
    --dkagrawa end

    IF (create_yn = 'Y') THEN
      -- create the quick quote
      -- Start added abhsaxen 24-Dec-2005
      l_qqhv_rec_type.sts_code := QQ_ACTIVE;
      -- end added abhsaxen 24-Dec-2005
      create_quick_qte(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_qqhv_rec_type,
                   lx_qqhv_rec_type,
                   l_qqlv_tbl_type,
                   lx_qqlv_tbl_type);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;

    ELSIF (create_yn ='N') THEN
      -- update the quick quote
      --dkagrawa removed the call to update_quick_qte and added following statements
      --because in case of update you need to get the lock on underlying tables
      --update_quick_qte call is there in the end, so it will update in db
      -- viselvar deleting the quick quotes and creating again
      -- viselvar making the call to update of the quick quotes
      -- update the quick quote

			update_qqh(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_qqhv_rec_type,
                   lx_qqhv_rec_type);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;

      l_line_no :=1;
      -- delete the existing rows of quick quote lines for the header
      FOR quick_quote_line_id IN get_qq_lines(lx_qqhv_rec_type.id) LOOP
        lxx_qqlv_tbl_type(l_line_no).id := quick_quote_line_id.id;
        l_line_no := l_line_no +1;
      END LOOP;

      okl_qql_pvt.delete_row(p_api_version,
                             p_init_msg_list,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             lxx_qqlv_tbl_type);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;


      -- if there is a new quick quote line that is added, insert it separately
      FOR l_count IN l_qqlv_tbl_type.first .. l_qqlv_tbl_type.last LOOP
       --  IF (l_qqlv_tbl_type(l_count).id is null) THEN
            l_qqlv_tbl_type(l_count).quick_quote_id:=lx_qqhv_rec_type.id;
            -- insert the record
            okl_qql_pvt.insert_row(p_api_version
                            ,okl_api.g_false
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_qqlv_tbl_type(l_count)
                            ,lx_qqlv_tbl_type(l_count));

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
      END LOOP;
      -- call to cash flow delete API to delete the cash flows
      -- delete the cash flows for the quote type
      FOR i in l_qqlv_tbl_type.FIRST.. l_qqlv_tbl_type.LAST LOOP
        OPEN get_oty_code(l_qqlv_tbl_type(i).id);
        FETCH get_oty_code INTO l_oty_code;
        CLOSE get_oty_code;

        IF (l_oty_code IS NOT NULL) THEN

         OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
          l_api_version
         ,p_init_msg_list
         ,OKL_API.G_FALSE
         ,l_oty_code    --dkagrawa changed source table name to soucrce object code
         ,l_qqlv_tbl_type(i).id
         ,x_return_status
         ,x_msg_count
         ,x_msg_data
        );
        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
        END IF;

       END IF;
      END LOOP;

      -- delete cash flows for the header
      OKL_LEASE_QUOTE_CASHFLOW_PVT.delete_cashflows (
         l_api_version
        ,p_init_msg_list
        ,OKL_API.G_FALSE
        ,'QUICK_QUOTE'        --dkagrawa changed source table name to soucrce object code
        ,l_qqhv_rec_type.id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
      -- delete the quick quote lines
      -- viselvar updated. Instead of deletion and creating the quick quotes,
      -- updation of the quick quotes is done
      /*delete_qql(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_qqlv_tbl_type);

     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- delete the quick quote header
      okl_qqh_pvt.delete_row(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_qqhv_rec_type);


      -- create the quick quote
      create_quick_qte(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_qqhv_rec_type,
                   lx_qqhv_rec_type,
                   l_qqlv_tbl_type,
                   lx_qqlv_tbl_type);*/
    END IF;

    -- create cash flows for the rent stream
    IF (l_qqhv_rec_type.rate_template_id is not null) THEN
       -- standard rate template

       -- populate cash flow header record
       l_cfh_rec_type.type_code :='INFLOW';
       l_cfh_rec_type.stream_type_id := null;
       l_cfh_rec_type.arrears_flag := l_qqhv_rec_type.TARGET_ARREARS;
       l_cfh_rec_type.parent_object_code := 'QUICK_QUOTE';
       l_cfh_rec_type.parent_object_id := lx_qqhv_rec_type.id;
       l_cfh_rec_type.frequency_code:= l_frequency;
       l_cfh_rec_type.quote_type_code:='QQ';
       l_cfh_rec_type.quote_id:=lx_qqhv_rec_type.id;
       -- populate cash flow levels
       l_cfl_tbl_type(1).periods :=l_qqhv_rec_type.target_periods;
       l_cfl_tbl_type(1).periodic_amount :=l_qqhv_rec_type.TARGET_AMOUNT;
       l_cfl_tbl_type(1).record_mode := 'CREATE';

        --populate the out record
       x_rent_payments_tbl(1).rate := l_rate;
       x_rent_payments_tbl(1).periods := l_cfl_tbl_type(1).periods;
       -- For Solve for Payment pricing method, the target amount will be null
       x_rent_payments_tbl(1).periodic_amount := round(l_qqhv_rec_type.TARGET_AMOUNT,l_precision);
       x_rent_payments_tbl(1).start_date :=l_qqhv_rec_type.expected_start_date;
     ELSIF (l_qqhv_rec_type.structured_pricing='Y' and l_qqhv_rec_type.pricing_method<>'RC') THEN
       l_frequency:= p_cfh_rec_type.frequency_code;
       l_cfh_rec_type.quote_type_code:='QQ';
       l_cfh_rec_type.quote_id:=lx_qqhv_rec_type.id;
       l_cfh_rec_type.parent_object_id:=lx_qqhv_rec_type.id;
        --populate the out record
       FOR k in l_cfl_tbl_type.FIRST..l_cfl_tbl_type.LAST LOOP
        x_rent_payments_tbl(k).rate :=l_cfl_tbl_type(k).rate ;
        x_rent_payments_tbl(k).periods := l_cfl_tbl_type(k).periods;
        x_rent_payments_tbl(k).periodic_amount := round(l_cfl_tbl_type(k).periodic_amount,l_precision);
        x_rent_payments_tbl(k).stub_amt := round(l_cfl_tbl_type(k).stub_amount,l_precision);
        x_rent_payments_tbl(k).stub_days :=l_cfl_tbl_type(k).stub_days;
        x_rent_payments_tbl(k).start_date :=l_cfl_tbl_type(k).start_date;
       END LOOP;
     END IF;
     -- create the cahflows for the rent stream other than the rate card method
     if (l_qqhv_rec_type.pricing_method <>'RC' and l_qqhv_rec_type.pricing_method <>'TR') THEN
       OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_cfh_rec_type,
                                                    l_cfl_tbl_type,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                                                    );

     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;

     end if;
     -- create the cash flows necessary for the quick quote
     FOR i IN lx_qqlv_tbl_type.FIRST.. lx_qqlv_tbl_type.LAST LOOP
       -- set the parameters common for FEE_EXPENSE, FEE_PAYMENT, TAX, INSURANCE,SERVICE
       l_cfh_other_rec.arrears_flag := l_qqhv_rec_type.TARGET_ARREARS;
       l_cfh_other_rec.frequency_code:= l_frequency;
       l_cfh_other_rec.parent_object_id := lx_qqlv_tbl_type(i).id;
       l_cfh_other_rec.stream_type_id := null;


       -- the payment frequency
       IF l_qqhv_rec_type.target_frequency IS NOT NULL THEN
         l_cfl_other_tbl(1).periods :=l_qqhv_rec_type.TERM/l_months_factor;
       ELSE
         l_cfl_other_tbl(1).periods := l_qqhv_rec_type.TARGET_PERIODS;
       END IF;

       if (lx_qqlv_tbl_type(i).basis = 'FIXED') THEN
         l_cfl_other_tbl(1).periodic_amount :=l_qqlv_tbl_type(i).VALUE;
       ELSIF(lx_qqlv_tbl_type(i).basis = 'ASSET_COST') THEN
         l_cfl_other_tbl(1).periodic_amount :=l_qqlv_tbl_type(i).VALUE *l_total_asset_cost*.01 ;
         -- viselvar added for Bug 5106098
         l_cfl_other_tbl(1).periods :=1;
       ELSE
         l_cfl_other_tbl(1).periodic_amount :=l_qqlv_tbl_type(i).VALUE *l_total_rent_payment*.01/l_cfl_other_tbl(1).periods;
       END IF;

       -- set the amount as zero
       IF ((l_qqhv_rec_type.pricing_method ='SP' OR l_qqhv_rec_type.pricing_method ='RC'
           OR(l_qqhv_rec_type.pricing_method ='TR')) AND (lx_qqlv_tbl_type(i).basis ='RENT')) THEN
          l_cfl_other_tbl(1).periodic_amount :=0;
          -- update of the cashflow is required if basis is percentage and the amount is not available
          l_cf_update_flag := 'Y';
       END IF;
       IF (l_qqhv_rec_type.pricing_method ='SF' AND lx_qqlv_tbl_type(i).basis ='ASSET_COST') THEN
          l_cfl_other_tbl(1).periodic_amount :=0;
          -- update of the cashflow is required if basis is percentage and the amount is not available
          l_cf_update_flag := 'Y';
       END IF;

       l_cfh_other_rec.quote_id:=lx_qqhv_rec_type.id;
       l_cfh_other_rec.quote_type_code:='QQ';
       l_cfl_other_tbl(1).record_mode := 'CREATE';
       -- fee expennse
       IF (l_qqlv_tbl_type(i).TYPE = 'FEE_EXPENSE' ) THEN
         l_cfh_other_rec.type_code:='OUTFLOW';
         l_cfh_other_rec.parent_object_code := 'QUICK_QUOTE_FEE';
       -- fee payment
       ELSIF (l_qqlv_tbl_type(i).TYPE = 'FEE_PAYMENT' ) THEN
         l_cfh_other_rec.type_code:='INFLOW';
         l_cfh_other_rec.parent_object_code := 'QUICK_QUOTE_FEE';
       -- insurance
       ELSIF (l_qqlv_tbl_type(i).TYPE = 'INSURANCE' ) THEN
         l_cfh_other_rec.type_code:='INFLOW';
         l_cfh_other_rec.parent_object_code := 'QUICK_QUOTE_INSURANCE';
       -- Tax
       ELSIF (l_qqlv_tbl_type(i).TYPE = 'TAX' ) THEN
         l_cfh_other_rec.type_code:='INFLOW';
         l_cfh_other_rec.parent_object_code := 'QUICK_QUOTE_TAX';
       -- Service
       ELSIF (l_qqlv_tbl_type(i).TYPE = 'SERVICE' ) THEN
         l_cfh_other_rec.type_code:='INFLOW';
         l_cfh_other_rec.parent_object_code := 'QUICK_QUOTE_SERVICE';
       END IF;

       IF (l_qqlv_tbl_type(i).TYPE = 'FEE_EXPENSE' or l_qqlv_tbl_type(i).TYPE = 'FEE_PAYMENT' or
           l_qqlv_tbl_type(i).TYPE = 'INSURANCE' or l_qqlv_tbl_type(i).TYPE = 'TAX' or
           l_qqlv_tbl_type(i).TYPE = 'SERVICE') THEN

       -- create the cahflows for the correspoding streams
       OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_cfh_other_rec,
                                                    l_cfl_other_tbl,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;

       END IF;
     END LOOP;
    -- get the number of lines in the quick quote lines table +1 for usage in solve for subsidy
    no_of_lines :=l_qqlv_tbl_type.LAST +1;
    -- call the API for pricing the quote

    /*make a call to the validation API to validate Quick Quotes before pricing
    */
    okl_sales_quote_qa_pvt.run_qa_checker(
                                    p_api_version  => l_api_version,
                                    p_init_msg_list=> p_init_msg_list,
                                    p_object_type  => 'QUICKQUOTE',
                                    p_object_id    => lx_qqhv_rec_type.id,
                                    x_return_status=> x_return_status,
                                    x_msg_count    => x_msg_count,
                                    x_msg_data     => x_msg_data,
                                    x_qa_result    => x_qa_result,
                                    x_qa_result_tbl => x_qa_result_tbl
                                    );

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- viselvar added
    IF (x_qa_result= 'E') THEN
      count_num:=0;
      FOR num_of_row IN x_qa_result_tbl.first .. x_qa_result_tbl.last LOOP
        IF (x_qa_result_tbl(num_of_row).result_code = 'ERROR' ) THEN
           count_num:= count_num +1;
           okl_api.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => x_qa_result_tbl(num_of_row).message_code );
        END IF;
        if (count_num = 3) then
          exit;
        end if;
      END LOOP;
      -- raise the exception
      RAISE okl_api.g_exception_error;
    END IF;

    okl_pricing_utils_pvt.price_quick_quote(
                                l_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                lx_qqhv_rec_type.id,
                                l_yields_rec,
                                sub_yields_rec,
                                pricing_results_table
                                );

     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;

    FOR i IN pricing_results_table.FIRST ..pricing_results_table.LAST LOOP
      IF (pricing_results_table(i).LINE_TYPE='FREE_FORM1') THEN
      -- populating the output record

          line_number := i;
          x_payment_rec.subsidy_amount := round(pricing_results_table(i).subsidy,l_precision);
          x_payment_rec.financed_amount := round(pricing_results_table(i).financed_amount);
          -- viselvar modified for bug 5124375
          --                                 - nvl(pricing_results_table(i).subsidy,0)
          --                                 - nvl(pricing_results_table(i).down_payment,0)
          --                                 - nvl(pricing_results_table(i).trade_in,0),l_precision);
          x_payment_rec.arrears_yn:=l_qqhv_rec_type.TARGET_ARREARS;
          x_payment_rec.frequency_code := l_frequency;
          x_payment_rec.pre_tax_irr    := round(l_yields_rec.pre_tax_irr*100,yield_prec);
          x_payment_rec.after_tax_irr  := round(l_yields_rec.after_tax_irr*100,yield_prec);
          x_payment_rec.book_yield     := round(l_yields_rec.bk_yield*100,yield_prec);
          x_payment_rec.iir            := round(l_yields_rec.iir*100,yield_prec);
          x_payment_rec.sub_pre_tax_irr:= round(sub_yields_rec.pre_tax_irr*100,yield_prec);
          x_payment_rec.sub_after_tax_irr:= round(sub_yields_rec.after_tax_irr*100,yield_prec);
          x_payment_rec.sub_book_yield:= round(sub_yields_rec.bk_yield*100,yield_prec);
          x_payment_rec.sub_iir       := round(sub_yields_rec.iir*100,yield_prec);
          -- solve for yields
          -- irrespective of the pricing method populating the yields in the quick quote header table
          lx_qqhv_rec_type.iir:= round(l_yields_rec.iir*100,yield_prec);
          lx_qqhv_rec_type.booking_yield:= round(l_yields_rec.bk_yield*100,yield_prec);
          lx_qqhv_rec_type.pirr:= round(l_yields_rec.pre_tax_irr*100,yield_prec);
          lx_qqhv_rec_type.airr:= round(l_yields_rec.after_tax_irr*100,yield_prec);
          lx_qqhv_rec_type.sub_iir:= round(sub_yields_rec.iir*100,yield_prec);
          lx_qqhv_rec_type.sub_booking_yield:= round(sub_yields_rec.bk_yield*100,yield_prec);
          lx_qqhv_rec_type.sub_pirr:= round(sub_yields_rec.pre_tax_irr*100,yield_prec);
          lx_qqhv_rec_type.sub_airr:= round(sub_yields_rec.after_tax_irr*100,yield_prec);
          -- solve for subsidy
          IF (p_qqhv_rec_type.pricing_method = 'SS') THEN
            -- viselvar added an explicit create for subsidy lines
            lp_qqlv_rec.TYPE:='SUBSIDY';
            lp_qqlv_rec.BASIS:='FIXED';
            lp_qqlv_rec.VALUE:=round(pricing_results_table(i).subsidy, l_precision);
            lp_qqlv_rec.quick_quote_id:=lx_qqhv_rec_type.id;

            okl_qql_pvt.insert_row(p_api_version
                            ,okl_api.g_false
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,lp_qqlv_rec
                            ,lx_qqlv_rec);

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
             ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
             END IF;
          END IF;
          -- rate card pricing method
          IF (p_qqhv_rec_type.pricing_method = 'RC') THEN
             OPEN get_cat_name(pricing_results_table(i).item_category_id);
             FETCH get_cat_name INTO l_item_name, l_description;
             CLOSE get_cat_name;

             FOR n in lx_qqlv_tbl_type.first .. lx_qqlv_tbl_type.last LOOP
               IF (lx_qqlv_tbl_type(n).id = pricing_results_table(i).line_id) THEN
                 l_cost :=lx_qqlv_tbl_type(n).value;
                 exit;
               END IF;
             END LOOP;
             l_so_details:=pricing_results_table(i).cash_flow_level_tbl;
             x_item_tbl(rate_card_num).item_category:= l_item_name;
             x_item_tbl(rate_card_num).description:= l_description;
             x_item_tbl(rate_card_num).cost:= l_cost;
             x_item_tbl(rate_card_num).rate_factor :=l_so_details(1).rate;
             x_item_tbl(rate_card_num).periods:=l_so_details(1).number_of_periods;
             x_item_tbl(rate_card_num).periodic_amt:=round(l_so_details(1).amount,l_precision);
             x_item_tbl(rate_card_num).start_date:=l_so_details(1).start_date;
             -- insert into the cash flow table
             -- populate cash flow header record
             l_cfh_rec_type.type_code:='INFLOW';
             l_cfh_rec_type.stream_type_id := null;
             l_cfh_rec_type.arrears_flag := lx_qqhv_rec_type.TARGET_ARREARS;
             -- as of now passing it as QUICK_QUOTE..has to be passed as QUICK_QUOTE_ASSET
             l_cfh_rec_type.parent_object_code := 'QUICK_QUOTE_ASSET';
             l_cfh_rec_type.parent_object_id := pricing_results_table(i).line_id;
             IF (l_frequency is not null) THEN
              l_cfh_rec_type.frequency_code:= l_frequency;
             ELSE
              l_cfh_rec_type.frequency_code:=lx_qqhv_rec_type.TARGET_FREQUENCY;
             END IF;
             l_cfh_rec_type.quote_id:=lx_qqhv_rec_type.id;
             l_cfh_rec_type.quote_type_code:='QQ';

             --populate cash flow lines
             l_cfl_tbl_type(1).periods :=l_so_details(1).number_of_periods;
             l_cfl_tbl_type(1).periodic_amount :=l_so_details(1).amount;
             l_cfl_tbl_type(1).start_date:=l_so_details(1).start_date;
             l_cfl_tbl_type(1).record_mode := 'CREATE';

             -- total rent payment
             --Fix Bug # 5184214 ssdeshpa start
             l_total_rent_payment := l_total_rent_payment + l_so_details(1).amount*l_so_details(1).number_of_periods;
             --Fix Bug # 5184214 ssdeshpa end

             OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_cfh_rec_type,
                                                    l_cfl_tbl_type,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                                                    );

             IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
             ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
             END IF;

            rate_card_num:= rate_card_num + 1;
          END IF;
      END IF;
    END LOOP;

    --viselvar fixed Bug 5045505
    --when Standard Rate Template is picked
    IF (l_qqhv_rec_type.rate_template_id is not null) THEN

     l_cfl_tbl_type(1).rate:=pricing_results_table(1).cash_flow_level_tbl(1).rate;
     x_rent_payments_tbl(1).rate:=l_cfl_tbl_type(1).rate;

    END IF;

    -- solve for financed amount
    IF (p_qqhv_rec_type.pricing_method = 'SF') THEN
      FOR i in l_qqlv_tbl_type.FIRST.. l_qqlv_tbl_type.LAST LOOP
        IF (lx_qqlv_tbl_type(i).TYPE= 'ITEM_CATEGORY') THEN
				  -- Added multiplication factor of 0.01, as value should be amount, not percentage.
          lx_qqlv_tbl_type(i).VALUE :=round(lx_qqlv_tbl_type(i).percentage_of_total_cost*pricing_results_table(line_number).financed_amount*0.01,l_precision);
          OPEN get_cat_name(lx_qqlv_tbl_type(i).item_category_id);
          FETCH get_cat_name INTO l_item_name, l_description;
          CLOSE get_cat_name;
          x_item_tbl(i).Item_Category:= l_item_name;
          x_item_tbl(i).description:= l_description;
          x_item_tbl(i).cost:= lx_qqlv_tbl_type(i).VALUE;
          x_item_tbl(i).purchase_option_value := round(lx_qqlv_tbl_type(i).end_of_term_value,l_precision);
        END IF;
      END LOOP;
    END IF;
    -- solve for payments
    IF (p_qqhv_rec_type.pricing_method = 'SP') THEN
     l_so_details:=pricing_results_table(line_number).cash_flow_level_tbl;
     FOR k in l_cfl_tbl_type.first .. l_cfl_tbl_type.last LOOP
        l_cfl_tbl_type(k).start_date:= l_so_details(k).start_date;
        -- calculate the total payment amount
        l_total_rent_payment := l_total_rent_payment + l_so_details(k).amount*l_so_details(k).number_of_periods;
        x_rent_payments_tbl(k).start_date :=l_cfl_tbl_type(k).start_date;
        -- Bug 5085836 viselvar added
        IF (l_so_details(k).stub_days is not null) THEN
         l_cfl_tbl_type(k).stub_amount:= l_so_details(k).amount;
         x_rent_payments_tbl(k).stub_amt := round(l_so_details(k).amount,l_precision);
        ELSE
         l_cfl_tbl_type(k).periodic_amount:= l_so_details(k).amount;
         x_rent_payments_tbl(k).periodic_amount := round(l_cfl_tbl_type(k).periodic_amount,l_precision);
        END IF;
     END LOOP;
    END IF;
    -- solve for target rate
    IF (p_qqhv_rec_type.pricing_method = 'TR') THEN
     l_so_details:=pricing_results_table(line_number).cash_flow_level_tbl;
     -- populate cash flow header record
     l_cfh_rec_type.type_code:='INFLOW';
     l_cfh_rec_type.stream_type_id := null;
     l_cfh_rec_type.arrears_flag := l_qqhv_rec_type.TARGET_ARREARS;
     l_cfh_rec_type.parent_object_code := 'QUICK_QUOTE';
     l_cfh_rec_type.parent_object_id := lx_qqhv_rec_type.id;
     l_cfh_rec_type.frequency_code:= l_frequency;
     l_cfh_rec_type.quote_id:=lx_qqhv_rec_type.id;
     l_cfh_rec_type.quote_type_code:= 'QQ';

      -- populate cash flow levels
     l_cfl_tbl_type(1).periods :=l_so_details(1).number_of_periods;
     l_cfl_tbl_type(1).periodic_amount :=l_so_details(1).amount;
     l_cfl_tbl_type(1).rate :=lx_qqhv_rec_type.target_rate;
     l_cfl_tbl_type(1).start_date:=l_so_details(1).start_date;
     l_cfl_tbl_type(1).record_mode:='CREATE';

     -- populate the target amount in the quote header
     lx_qqhv_rec_type.target_amount :=l_so_details(1).amount;
     -- total rent payment
     l_total_rent_payment := l_so_details(1).amount*l_so_details(1).number_of_periods;

     -- populate the out record
     x_rent_payments_tbl(1).rate := lx_qqhv_rec_type.target_rate;
     x_rent_payments_tbl(1).periods := l_so_details(1).number_of_periods;
     x_rent_payments_tbl(1).periodic_amount := round(l_so_details(1).amount,l_precision);
     x_rent_payments_tbl(1).start_date :=l_so_details(1).start_date;

     OKL_LEASE_QUOTE_CASHFLOW_PVT.create_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_cfh_rec_type,
                                                    l_cfl_tbl_type,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                                                    );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

    END IF;

    -- viselvar added for Bug 5085836
    IF(p_qqhv_rec_type.pricing_method = 'SF' OR p_qqhv_rec_type.pricing_method = 'SY'
       OR p_qqhv_rec_type.pricing_method = 'SS') THEN
       l_so_details:=pricing_results_table(line_number).cash_flow_level_tbl;
       FOR i in l_so_details.first..l_so_details.last LOOP
         -- set the rate and the start date
         x_rent_payments_tbl(i).start_date :=l_so_details(i).start_date;
       END LOOP;
    END IF;

    IF (l_cf_update_flag='Y') THEN
      FOR cashflow_dtl_rec IN get_cashflow_dtls(lx_qqhv_rec_type.id) LOOP
         IF (cashflow_dtl_rec.cft_code = 'OUTFLOW_SCHEDULE') THEN
           l_update_cfh_rec.TYPE_code :='OUTFLOW';
         ELSE
           l_update_cfh_rec.TYPE_code :='INFLOW';
         END IF;
         l_update_cfh_rec.arrears_flag:=l_qqhv_rec_type.TARGET_ARREARS;
         l_update_cfh_rec.frequency_code:= l_frequency;
--         l_update_cfh_rec.parent_object_code:= ;
         l_update_cfh_rec.parent_object_id:=cashflow_dtl_rec.line_id;
         l_update_cfh_rec.quote_type_code:= 'QQ';
         l_update_cfh_rec.quote_id :=lx_qqhv_rec_type.id;
         l_update_cfh_rec.cashflow_header_id:=cashflow_dtl_rec.flow_id;
         l_update_cfh_rec.cashflow_object_id:=cashflow_dtl_rec.obj_id;
         l_update_cfh_rec.cashflow_header_ovn:=1;

         l_update_cfl_tbl(1).cashflow_level_id:=cashflow_dtl_rec.level_id;
         l_update_cfl_tbl(1).start_date:=cashflow_dtl_rec.start_date;
         l_update_cfl_tbl(1).rate:=cashflow_dtl_rec.rate;
         l_update_cfl_tbl(1).stub_amount:=cashflow_dtl_rec.stub_amount;
         l_update_cfl_tbl(1).stub_days:=cashflow_dtl_rec.stub_days;
         l_update_cfl_tbl(1).periods:=cashflow_dtl_rec.number_of_periods;
         if (cashflow_dtl_rec.basis='ASSET_COST') THEN
           l_update_cfl_tbl(1).periodic_amount:=cashflow_dtl_rec.value * .01
                                               *pricing_results_table(line_number).financed_amount;
         else
           l_update_cfl_tbl(1).periodic_amount:=cashflow_dtl_rec.value * .01*l_total_rent_payment
                                                /cashflow_dtl_rec.number_of_periods;
         end if;
         l_update_cfl_tbl(1).cashflow_level_ovn:=1;
         l_update_cfl_tbl(1).record_mode:='UPDATE';

         -- updating the cash flows for fees and services for basis other than fixed

         OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_update_cfh_rec,
                                                    l_update_cfl_tbl,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                                                    );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
           RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
           RAISE okl_api.g_exception_error;
         END IF;

      END LOOP;
    END IF;

    j:=1;
    FOR fee_payment_rec IN get_line_dtls(lx_qqhv_rec_type.id) LOOP
       -- populate the out record
       x_fee_payments_tbl(j).payment_type :=  fee_payment_rec.TYPE ;
       x_fee_payments_tbl(j).periods      :=  fee_payment_rec.number_of_periods;
       x_fee_payments_tbl(j).periodic_amt :=  round(fee_payment_rec.amount,l_precision);
       x_fee_payments_tbl(j).start_date   :=  fee_payment_rec.start_date;
       j:=j+1;
    END LOOP;
    -- set the out parameters
    x_qqhv_rec_type := lx_qqhv_rec_type;
    x_qqlv_tbl_type := lx_qqlv_tbl_type;
    IF (p_commit = 'N') THEN
      -- rollback the transaction
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('quick_quote_savepoint');
    ELSIF (p_commit='Y') THEN
      -- update the data in the lease quote tables
      update_quick_qte(l_api_version,
                   p_init_msg_list,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   lx_qqhv_rec_type,
                   x_qqhv_rec_type,
                   lx_qqlv_tbl_type,
                   x_qqlv_tbl_type);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- create the data in the cash flow tables if not already created
      l_cfh_rec_type.cashflow_header_ovn:=1;
      for i in l_cfl_tbl_type.first..l_cfl_tbl_type.last loop
       l_cfl_tbl_type(i).cashflow_level_ovn:=1;
      end loop;

      IF (p_qqhv_rec_type.pricing_method <> 'SY' and p_qqhv_rec_type.pricing_method <> 'TR' and p_qqhv_rec_type.pricing_method<>'RC'
          and p_qqhv_rec_type.pricing_method <> 'SS') THEN
        FOR t IN l_cfl_tbl_type.FIRST .. l_cfl_tbl_type.LAST
        LOOP
          l_cfl_tbl_type(t).record_mode := 'UPDATE';
        END LOOP;
          OKL_LEASE_QUOTE_CASHFLOW_PVT.update_cashflow(l_api_version,
                                                    p_init_msg_list,
                                                    OKL_API.G_FALSE,
                                                    l_cfh_rec_type,
                                                    l_cfl_tbl_type,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                                                    );

          IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;

      END IF;
      -- commit the transaction
      COMMIT;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRQQHB.pls call handle_quick_quote');
    END IF;
EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);

 END handle_quick_quote;

  --------------------------------
  -- PROCEDURE get_quick_quote
  --------------------------------
  PROCEDURE get_quick_quote(p_quote_id      IN  okl_quick_quotes_b.id%type,
														x_qqhv_rec			OUT NOCOPY qqhv_rec_type,
														x_qqlv_tbl			OUT NOCOPY qqlv_tbl_type,
														x_return_status OUT NOCOPY  VARCHAR2)
	  IS

		CURSOR c_qqh(p_id IN okl_quick_quotes_b.id%TYPE) IS
		SELECT id,
			object_version_number,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			reference_number,
			expected_start_date,
			org_id,
			inv_org_id,
			currency_code,
			term,
			end_of_term_option_id,
			pricing_method,
			lease_opportunity_id,
			originating_vendor_id,
			program_agreement_id,
			sales_rep_id,
			sales_territory_id,
			structured_pricing,
			line_level_pricing,
			rate_template_id,
			rate_card_id,
			lease_rate_factor,
			target_rate_type,
			target_rate,
			target_amount,
			target_frequency,
			target_arrears,
			target_periods,
			iir,
			sub_iir,
			booking_yield,
			sub_booking_yield,
			pirr,
			sub_pirr,
			airr,
			sub_airr,
			sts_code,
			short_description,
			description,
			comments
		FROM   okl_quick_quotes_v
		WHERE  id = p_id;

		CURSOR c_qql(p_id IN okl_quick_quote_lines_b.quick_quote_id%TYPE) IS
		SELECT id,
					 object_version_number,
					 attribute_category,
					 attribute1,
					 attribute2,
					 attribute3,
					 attribute4,
					 attribute5,
					 attribute6,
					 attribute7,
					 attribute8,
					 attribute9,
					 attribute10,
					 attribute11,
					 attribute12,
					 attribute13,
					 attribute14,
					 attribute15,
					 quick_quote_id,
					 type,
					 basis,
					 value,
					 end_of_term_value_default,
					 end_of_term_value,
					 percentage_of_total_cost,
					 item_category_id,
					 item_category_set_id,
					 lease_rate_factor,
					 short_description,
					 description,
					 comments
		FROM   okl_quick_quote_lines_v
		WHERE  quick_quote_id = p_id;

    i pls_integer := 1;
  BEGIN

		x_return_status := okl_api.g_ret_sts_success;

		OPEN c_qqh(p_id => p_quote_id);
		FETCH c_qqh INTO
					x_qqhv_rec.id,
					x_qqhv_rec.object_version_number,
					x_qqhv_rec.attribute_category,
					x_qqhv_rec.attribute1,
					x_qqhv_rec.attribute2,
					x_qqhv_rec.attribute3,
					x_qqhv_rec.attribute4,
					x_qqhv_rec.attribute5,
					x_qqhv_rec.attribute6,
					x_qqhv_rec.attribute7,
					x_qqhv_rec.attribute8,
					x_qqhv_rec.attribute9,
					x_qqhv_rec.attribute10,
					x_qqhv_rec.attribute11,
					x_qqhv_rec.attribute12,
					x_qqhv_rec.attribute13,
					x_qqhv_rec.attribute14,
					x_qqhv_rec.attribute15,
					x_qqhv_rec.reference_number,
					x_qqhv_rec.expected_start_date,
					x_qqhv_rec.org_id,
					x_qqhv_rec.inv_org_id,
					x_qqhv_rec.currency_code,
					x_qqhv_rec.term,
					x_qqhv_rec.end_of_term_option_id,
					x_qqhv_rec.pricing_method,
					x_qqhv_rec.lease_opportunity_id,
					x_qqhv_rec.originating_vendor_id,
					x_qqhv_rec.program_agreement_id,
					x_qqhv_rec.sales_rep_id,
					x_qqhv_rec.sales_territory_id,
					x_qqhv_rec.structured_pricing,
					x_qqhv_rec.line_level_pricing,
					x_qqhv_rec.rate_template_id,
					x_qqhv_rec.rate_card_id,
					x_qqhv_rec.lease_rate_factor,
					x_qqhv_rec.target_rate_type,
					x_qqhv_rec.target_rate,
					x_qqhv_rec.target_amount,
					x_qqhv_rec.target_frequency,
					x_qqhv_rec.target_arrears,
					x_qqhv_rec.target_periods,
					x_qqhv_rec.iir,
					x_qqhv_rec.sub_iir,
					x_qqhv_rec.booking_yield,
					x_qqhv_rec.sub_booking_yield,
					x_qqhv_rec.pirr,
					x_qqhv_rec.sub_pirr,
					x_qqhv_rec.airr,
					x_qqhv_rec.sub_airr,
					x_qqhv_rec.sts_code,
					x_qqhv_rec.short_description,
					x_qqhv_rec.description,
					x_qqhv_rec.comments;
         --viselvar modified code

	 --Bug 7022258-Changed by kkorrapo
	 --SELECT OKL_QQH_REF_SEQ.nextval INTO x_qqhv_rec.reference_number FROM DUAL;
 	 x_qqhv_rec.reference_number := okl_util.get_next_seq_num('OKL_QQH_REF_SEQ','OKL_QUICK_QUOTES_B','REFERENCE_NUMBER');
         --Bug 7022258--Change end

		IF c_qqh%NOTFOUND THEN
		  x_return_status := okl_api.g_ret_sts_error;
	  END IF;
		CLOSE c_qqh;

		FOR l_qql IN c_qql(p_id => p_quote_id) LOOP
		  x_qqlv_tbl(i).id  := l_qql.id;
   		x_qqlv_tbl(i).object_version_number := l_qql.object_version_number;
			x_qqlv_tbl(i).attribute_category :=l_qql.attribute_category;
			x_qqlv_tbl(i).attribute1 := l_qql.attribute1;
			x_qqlv_tbl(i).attribute2								:= l_qql.attribute2;
			x_qqlv_tbl(i).attribute3								:= l_qql.attribute3;
			x_qqlv_tbl(i).attribute4								:= l_qql.attribute4;
			x_qqlv_tbl(i).attribute5								:= l_qql.attribute5;
			x_qqlv_tbl(i).attribute6								:= l_qql.attribute6;
			x_qqlv_tbl(i).attribute7								:= l_qql.attribute7;
			x_qqlv_tbl(i).attribute8								:= l_qql.attribute8;
			x_qqlv_tbl(i).attribute9								:= l_qql.attribute9;
			x_qqlv_tbl(i).attribute10								:= l_qql.attribute10;
			x_qqlv_tbl(i).attribute11								:= l_qql.attribute11;
			x_qqlv_tbl(i).attribute12							  := l_qql.attribute12;
			x_qqlv_tbl(i).attribute13							  := l_qql.attribute13;
			x_qqlv_tbl(i).attribute14							  := l_qql.attribute14;
			x_qqlv_tbl(i).attribute15							  := l_qql.attribute15;
			x_qqlv_tbl(i).quick_quote_id						:= l_qql.quick_quote_id;
			x_qqlv_tbl(i).type											:= l_qql.type;
			x_qqlv_tbl(i).basis	  									:= l_qql.basis;
			x_qqlv_tbl(i).value                     := l_qql.value;
			x_qqlv_tbl(i).end_of_term_value_default := l_qql.end_of_term_value_default;
			x_qqlv_tbl(i).end_of_term_value         := l_qql.end_of_term_value;
			x_qqlv_tbl(i).percentage_of_total_cost  := l_qql.percentage_of_total_cost;
			x_qqlv_tbl(i).item_category_id          := l_qql.item_category_id;
			x_qqlv_tbl(i).item_category_set_id      := l_qql.item_category_set_id;
			x_qqlv_tbl(i).lease_rate_factor         := l_qql.lease_rate_factor;
			x_qqlv_tbl(i).short_description         := l_qql.short_description;
			x_qqlv_tbl(i).description               := l_qql.description;
			x_qqlv_tbl(i).comments     							:= l_qql.comments;

			i := i+1;
		END LOOP;

  END get_quick_quote;
  ------------------------------------------------------------------------------
  -- PROCEDURE duplicate_quick_qte
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : duplicate_quick_qte
  -- Description     : This procedure is a wrapper that duplicates estimates of a
  --                   particular lease opportunity
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-feb-2006 viselvar created
  --
  -- End of comments

  PROCEDURE duplicate_estimate ( p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2,
                                 source_lopp_id        IN  NUMBER,
                                 target_lopp_id        IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_quote_rec            qqhv_rec_type;
    l_quote_lines_tbl      qqlv_tbl_type;
    x_quick_qte_rec        qqhv_rec_type;
    x_quick_qte_lines_tbl  qqlv_tbl_type;

    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_QUICK_QUOTES_PVT.DUPLICATE_QUICK_QTE';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    is_debug_statement_on          BOOLEAN;
    l_api_name            CONSTANT VARCHAR2(30) := 'duplicate_quick_qte';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status                VARCHAR2(1) := okl_api.g_ret_sts_success;

    -- cursor to get the estimates of a particular lease opportunity
    CURSOR get_estimates(l_lopp_id IN NUMBER) IS
    SELECT ID FROM OKL_QUICK_QUOTES_B
    WHERE LEASE_OPPORTUNITY_ID = l_lopp_id;

  BEGIN

    l_debug_enabled := nvl(okl_debug_pub.check_log_enabled,'N');
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRQQHB.pls call duplicate_quick_qte');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>    l_api_name
                                             ,p_pkg_name      =>    g_pkg_name
                                             ,p_init_msg_list =>    p_init_msg_list
                                             ,l_api_version   =>    l_api_version
                                             ,p_api_version   =>    p_api_version
                                             ,p_api_type      =>    g_api_type
                                             ,x_return_status =>    x_return_status);

    FOR quote_id IN get_estimates(source_lopp_id) LOOP

    get_quick_quote ( p_quote_id      => quote_id.id,
                      x_qqhv_rec      => l_quote_rec,
              x_qqlv_tbl      => l_quote_lines_tbl,
              x_return_status => l_return_status );

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- set the target lease opportunity id
    l_quote_rec.lease_opportunity_id:=target_lopp_id;

    create_quick_qte (p_api_version           => p_api_version,
                      p_init_msg_list          => p_init_msg_list,
                      x_return_status          => l_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data,
                      p_qqhv_rec_type          => l_quote_rec,
                      x_qqhv_rec_type          => x_quick_qte_rec,
                      p_qqlv_tbl_type          => l_quote_lines_tbl,
                      x_qqlv_tbl_type          => x_quick_qte_lines_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    END LOOP;

    x_return_status := okl_api.g_ret_sts_success;

  EXCEPTION

      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);

  END duplicate_estimate;



END okl_quick_quotes_pvt;

/
