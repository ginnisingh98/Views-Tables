--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_APPROVAL_PVT" AS
/* $Header: OKLRSICB.pls 120.1 2005/10/30 03:17:05 appldev noship $ */

  -- Global Message Constants
  G_INVALID_POOL_STATUS CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_STATUS_INVALID';
  G_POOL_HAS_NO_LINES CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_HAS_NO_LINES';
  G_POOL_HAS_MORE_LINES CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_HAS_MORE_LINES';
  G_POOL_LINE_INVALID CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_LINE_INVALID';
  G_POOL_IS_NOT_ACTIVE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_STS_NOT_ACTIVE';
  G_SUB_POOL_EXIPRED_WF CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUBSIDY_POOL_EXPIRED_WF';
  G_POOL_LINE_INVALID_AMT CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_LINE_AMT_BALANCE';
  G_POOL_NO_SUB_ASSOC CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_HAS_NO_SUBSIDY';
  G_BUDGET_IS_NOT_NEW CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_HAS_NO_SUBSIDY';
  -- Global Constants
  G_PENDING_STATUS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PENDING';
  G_ACTIVE_STATUS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ACTIVE';

  PROCEDURE submit_pool_for_approval(p_api_version     IN 	NUMBER
                                    ,p_init_msg_list   IN  VARCHAR2
                                    ,x_return_status   OUT NOCOPY VARCHAR2
                                    ,x_msg_count       OUT NOCOPY NUMBER
                                    ,x_msg_data        OUT NOCOPY VARCHAR2
                                    ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                    ,x_pool_status     OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE
                                    ,x_total_budgets  OUT NOCOPY okl_subsidy_pools_b.total_budgets%TYPE) IS
    CURSOR c_get_pool_details_csr IS
    SELECT decision_status_code
          ,pool_type_code
          ,subsidy_pool_name
          ,effective_from_date
          ,effective_to_date
          ,id
      FROM okl_subsidy_pools_b
     WHERE id = p_subsidy_pool_id;
    cv_pool_details_csr c_get_pool_details_csr%ROWTYPE;

    CURSOR c_get_pool_line_number IS
    SELECT count(*) number_of_lines
      FROM okl_subsidy_pool_budgets_b
     WHERE subsidy_pool_id = p_subsidy_pool_id;
    lv_number_of_lines NUMBER;

    CURSOR c_get_pool_line_details_csr IS
    SELECT id
          ,budget_type_code
          ,decision_status_code
          ,budget_amount
      FROM okl_subsidy_pool_budgets_b
     WHERE subsidy_pool_id = p_subsidy_pool_id;
    cv_get_pool_line_details_csr c_get_pool_line_details_csr%ROWTYPE;

    CURSOR c_chk_subsidy_assoc_csr IS
    SELECT 'X'
      FROM okl_subsidies_b
     WHERE subsidy_pool_id = p_subsidy_pool_id;
    lv_dummy_var VARCHAR2(1);

    l_approval_process VARCHAR2(30);
    l_pool_status okl_subsidy_pools_b.decision_status_code%TYPE;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_POOL_FOR_APPROVAL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_APPROVAL_PVT.SUBMIT_POOL_FOR_APPROVAL';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSICB.pls call submit_pool_for_approval');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
       p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);

    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    x_total_budgets := 0;
    -- validate if subsidy pool id passed is valid
    IF(p_subsidy_pool_id IS NULL OR p_subsidy_pool_id = OKL_API.G_MISS_NUM)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'p_subsidy_pool_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- get the subsidy pool details to process
    OPEN c_get_pool_details_csr; FETCH c_get_pool_details_csr INTO cv_pool_details_csr;
    CLOSE c_get_pool_details_csr;

    -- if the pool status is not new, then error out. initial pool approval should have the pool status and the line status as NEW
    IF(cv_pool_details_csr.decision_status_code <> 'NEW')THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_POOL_STATUS, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for pool expiration here. pool could be logically expired by the time user submits for approval.
    -- in such a case, expire the pool and throw the error
    IF(TRUNC(SYSDATE) > NVL(cv_pool_details_csr.effective_to_date,okl_accounting_util.g_final_date))THEN
      okl_subsidy_pool_pvt.expire_sub_pool(p_api_version     => p_api_version
                                       ,p_init_msg_list   => p_init_msg_list
                                       ,x_return_status   => x_return_status
                                       ,x_msg_count       => x_msg_count
                                       ,x_msg_data        => x_msg_data
                                       ,p_subsidy_pool_id => cv_pool_details_csr.id
                                      );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'expiring subsidy pool '||cv_pool_details_csr.subsidy_pool_name||' with effective end date '||cv_pool_details_csr.effective_to_date
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- cannot submit pool for approval while the pool is expired.
      OKL_API.set_message(G_APP_NAME, G_SUB_POOL_EXIPRED_WF, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- verify if the subsidy pool has been associated with any subsidy. for approval, the pool should be associated to
    -- at least one subsidy
    OPEN c_chk_subsidy_assoc_csr; FETCH c_chk_subsidy_assoc_csr INTO lv_dummy_var;
    CLOSE c_chk_subsidy_assoc_csr;
    IF(NVL(lv_dummy_var,'N')<> 'X')THEN
      OKC_API.set_message(G_APP_NAME, G_POOL_NO_SUB_ASSOC, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- get the number of subsidy pool budget lines
    lv_number_of_lines:=0;
    OPEN c_get_pool_line_number; FETCH c_get_pool_line_number INTO lv_number_of_lines;
    CLOSE c_get_pool_line_number;
    IF(lv_number_of_lines = 0)THEN
      OKC_API.set_message(G_APP_NAME, G_POOL_HAS_NO_LINES, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF(lv_number_of_lines > 1)THEN -- for initial pool approval, only one budget line is allowed.
      OKC_API.set_message(G_APP_NAME, G_POOL_HAS_MORE_LINES, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the budget line details
    OPEN c_get_pool_line_details_csr; FETCH c_get_pool_line_details_csr INTO cv_get_pool_line_details_csr;
    CLOSE c_get_pool_line_details_csr;
    IF(cv_get_pool_line_details_csr.budget_type_code <> 'ADDITION' OR cv_get_pool_line_details_csr.budget_amount <= 0
      OR cv_get_pool_line_details_csr.decision_status_code <> 'NEW')THEN
      OKC_API.set_message(G_APP_NAME, G_POOL_LINE_INVALID, 'POOL_NAME', cv_pool_details_csr.subsidy_pool_name
                          ,'AMOUNT',cv_get_pool_line_details_csr.budget_amount);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- now that all the required validations are passed, update the pool and line status to pending approval
    l_pool_status := G_PENDING_STATUS_CODE;
    okl_subsidy_pool_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                  ,p_init_msg_list   => p_init_msg_list
                                                  ,x_return_status   => x_return_status
                                                  ,x_msg_count       => x_msg_count
                                                  ,x_msg_data        => x_msg_data
                                                  ,p_subsidy_pool_id => p_subsidy_pool_id
                                                  ,p_decision_status_code => l_pool_status
                                                 );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_subsidy_pool_pvt.set_decision_status_code to pending returned with status '||x_return_status|| ' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_pool_status := G_PENDING_STATUS_CODE;
    okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                         ,p_init_msg_list   => p_init_msg_list
                                                         ,x_return_status   => x_return_status
                                                         ,x_msg_count       => x_msg_count
                                                         ,x_msg_data        => x_msg_data
                                                         ,p_sub_pool_budget_id => cv_get_pool_line_details_csr.id
                                                         ,p_decision_status_code => l_pool_status
                                                        );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_subsidy_pool_budget_pvt.set_decision_status_code to pending returned with status '||x_return_status|| ' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- copy this value back to the out parameter once pending for approval is set successfully
    x_pool_status := G_PENDING_STATUS_CODE;
    -- read the profile OKL: Subsidy Pool Approval Process Access
    l_approval_process := fnd_profile.value('OKL_SUBSIDY_POOL_APPROVAL_PROCESS');

    IF(NVL(l_approval_process,'NONE')='NONE')THEN
      -- since no approval process is selected in the profile, approve the pool by default
      l_pool_status := G_ACTIVE_STATUS_CODE;
      okl_subsidy_pool_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                    ,p_init_msg_list   => p_init_msg_list
                                                    ,x_return_status   => x_return_status
                                                    ,x_msg_count       => x_msg_count
                                                    ,x_msg_data        => x_msg_data
                                                    ,p_subsidy_pool_id => p_subsidy_pool_id
                                                    ,p_decision_status_code => l_pool_status
                                                   );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_pvt.set_decision_status_code to active returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- since no approval process is selected, approve the line by default
      l_pool_status := G_ACTIVE_STATUS_CODE;
      okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                           ,p_init_msg_list   => p_init_msg_list
                                                           ,x_return_status   => x_return_status
                                                           ,x_msg_count       => x_msg_count
                                                           ,x_msg_data        => x_msg_data
                                                           ,p_sub_pool_budget_id => cv_get_pool_line_details_csr.id
                                                           ,p_decision_status_code => l_pool_status
                                                          );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_budget_pvt.set_decision_status_code to active returned with status '||x_return_status||' x_msg_data ' ||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- since this is the initial approval, the total budget amount equals the budget amount on the line
      okl_subsidy_pool_pvt.update_total_budget(p_api_version     => p_api_version
                                              ,p_init_msg_list   => p_init_msg_list
                                              ,x_return_status   => x_return_status
                                              ,x_msg_count       => x_msg_count
                                              ,x_msg_data        => x_msg_data
                                              ,p_subsidy_pool_id => p_subsidy_pool_id
                                              ,p_total_budget_amt => cv_get_pool_line_details_csr.budget_amount);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_pvt.update_total_budget returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- copy this value back to the out parameter once activated successfully
      x_pool_status := G_ACTIVE_STATUS_CODE;
      x_total_budgets := cv_get_pool_line_details_csr.budget_amount;
    ELSIF(l_approval_process in ('AME','WF'))THEN
      -- raise subsidy pool approval event, which will then process via AME or workflow
      okl_subsidy_pool_wf.raise_pool_event_approval(p_api_version    => p_api_version
                                                   ,p_init_msg_list  => p_init_msg_list
                                                   ,x_return_status  => x_return_status
                                                   ,x_msg_count      => x_msg_count
                                                   ,x_msg_data       => x_msg_data
                                                   ,p_subsidy_pool_id => p_subsidy_pool_id);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_wf.raise_pool_event_approval returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSICB.pls call submit_pool_for_approval');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END submit_pool_for_approval;

  PROCEDURE submit_budget_for_approval(p_api_version     IN 	NUMBER
                                  ,p_init_msg_list   IN  VARCHAR2
                                  ,x_return_status   OUT NOCOPY VARCHAR2
                                  ,x_msg_count       OUT NOCOPY NUMBER
                                  ,x_msg_data        OUT NOCOPY VARCHAR2
                                  ,p_subsidy_pool_budget_id IN okl_subsidy_pool_budgets_b.id%TYPE
                                  ,x_pool_budget_status OUT NOCOPY okl_subsidy_pool_budgets_b.decision_status_code%TYPE) IS
    CURSOR c_get_pool_info_csr IS
    SELECT pool.subsidy_pool_name
          ,pool.decision_status_code pool_status
          ,pool.effective_from_date pool_start_date
          ,pool.effective_to_date pool_end_date
          ,pool.total_budgets
          ,pool.id pool_id
          ,line.budget_amount
          ,line.budget_type_code
          ,line.decision_status_code line_status
          ,line.id budget_line_id
      FROM okl_subsidy_pools_b pool
          ,okl_subsidy_pool_budgets_b line
     WHERE pool.id = line.subsidy_pool_id
       AND line.id = p_subsidy_pool_budget_id;
    cv_get_pool_info c_get_pool_info_csr%ROWTYPE;

    l_approval_process VARCHAR2(30);

    l_budget_status okl_subsidy_pool_budgets_b.decision_status_code%TYPE;
    lv_calc_total_budget okl_subsidy_pools_b.total_budgets%TYPE;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_BUDGET_APPROVAL';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_APPROVAL_PVT.SUBMIT_BUDGET_FOR_APPROVAL';
    l_debug_enabled VARCHAR2(10);
    l_level_procedure fnd_log_messages.log_level%TYPE;
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSICB.pls call submit_budget_for_approval');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
       p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);

    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    -- validate if subsidy pool budget id passed is valid
    IF(p_subsidy_pool_budget_id IS NULL OR p_subsidy_pool_budget_id = OKL_API.G_MISS_NUM)THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'p_subsidy_pool_budget_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the pool and the budget line information
    OPEN c_get_pool_info_csr; FETCH c_get_pool_info_csr INTO cv_get_pool_info;
    CLOSE c_get_pool_info_csr;

    -- check if the pool status is ACTIVE, if not ACTIVE, throw error
    IF(cv_get_pool_info.pool_status <> 'ACTIVE')THEN
      OKC_API.set_message(G_APP_NAME, G_POOL_IS_NOT_ACTIVE, 'POOL_NAME', cv_get_pool_info.subsidy_pool_name);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for pool expiration here. pool could be logically expired by the time user submits line for approval.
    -- in such a case, expire the pool and throw the error
    IF(TRUNC(SYSDATE) > NVL(cv_get_pool_info.pool_end_date,okl_accounting_util.g_final_date))THEN
      okl_subsidy_pool_pvt.expire_sub_pool(p_api_version => p_api_version
                                          ,p_init_msg_list  => p_init_msg_list
                                          ,x_return_status  => x_return_status
                                          ,x_msg_count      => x_msg_count
                                          ,x_msg_data       => x_msg_data
                                          ,p_subsidy_pool_id => cv_get_pool_info.pool_id
                                           );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'expiring subsidy pool '||cv_get_pool_info.subsidy_pool_name||' with effective end date '||cv_get_pool_info.pool_end_date
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- cannot submit pool for approval while the pool is expired.
      OKL_API.set_message(G_APP_NAME, G_SUB_POOL_EXIPRED_WF, 'POOL_NAME', cv_get_pool_info.subsidy_pool_name);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- check if the line status is NEW, if not throw an error. this check is required as the user might resubmit the same
    -- line for approval, by clicking on the refresh icon (even when the submit for approval is disabled)
    IF(cv_get_pool_info.line_status <> 'NEW')THEN
      OKC_API.set_message(G_APP_NAME, G_POOL_LINE_INVALID, 'POOL_NAME', cv_get_pool_info.subsidy_pool_name
                          ,'AMOUNT',cv_get_pool_info.budget_amount);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- now that the validations have been passed, set the budget line to pending for approval
    l_budget_status := G_PENDING_STATUS_CODE;
    okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                         ,p_init_msg_list   => p_init_msg_list
                                                         ,x_return_status   => x_return_status
                                                         ,x_msg_count       => x_msg_count
                                                         ,x_msg_data        => x_msg_data
                                                         ,p_sub_pool_budget_id => cv_get_pool_info.budget_line_id
                                                         ,p_decision_status_code => l_budget_status
                                                        );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'okl_subsidy_pool_budget_pvt.set_decision_status_code to pending returned with status '||x_return_status||' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check if the operation is of type REDUCTION, in which case the budget amount is reduced from the total budget immediately.
    -- if this REDUCTION request is subsequently rejected, then the amount is added back to the total budget
    IF(cv_get_pool_info.budget_type_code = 'REDUCTION')THEN
      lv_calc_total_budget := 0;
      lv_calc_total_budget := cv_get_pool_info.total_budgets - cv_get_pool_info.budget_amount;
      IF(lv_calc_total_budget <= 0)THEN
        OKL_API.set_message(G_APP_NAME, G_POOL_LINE_INVALID_AMT, 'AMOUNT', cv_get_pool_info.budget_amount);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
        okl_subsidy_pool_pvt.update_total_budget(p_api_version     => p_api_version
                                                ,p_init_msg_list   => p_init_msg_list
                                                ,x_return_status   => x_return_status
                                                ,x_msg_count       => x_msg_count
                                                ,x_msg_data        => x_msg_data
                                                ,p_subsidy_pool_id => cv_get_pool_info.pool_id
                                                ,p_total_budget_amt => lv_calc_total_budget);
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_pvt.update_total_budget with lv_calc_total_budget '||lv_calc_total_budget||' returned with '||x_return_status||
                                  ' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF; -- end of cv_get_pool_info.budget_type_code = 'REDUCTION'

    x_pool_budget_status := G_PENDING_STATUS_CODE;
    -- read the profile OKL: Subsidy Pool Approval Process Access
    l_approval_process := fnd_profile.value('OKL_SUBSIDY_POOL_APPROVAL_PROCESS');

    IF(NVL(l_approval_process,'NONE')='NONE')THEN
      -- since no approval process is selected in the profile, approve the pool budget line by default
      l_budget_status := G_ACTIVE_STATUS_CODE;
      okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version     => p_api_version
                                                           ,p_init_msg_list   => p_init_msg_list
                                                           ,x_return_status   => x_return_status
                                                           ,x_msg_count       => x_msg_count
                                                           ,x_msg_data        => x_msg_data
                                                           ,p_sub_pool_budget_id => cv_get_pool_info.budget_line_id
                                                           ,p_decision_status_code => l_budget_status
                                                          );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_budget_pvt.set_decision_status_code to active returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF(cv_get_pool_info.budget_type_code = 'ADDITION')THEN
        lv_calc_total_budget := 0;
        lv_calc_total_budget := cv_get_pool_info.total_budgets + cv_get_pool_info.budget_amount;

        okl_subsidy_pool_pvt.update_total_budget(p_api_version     => p_api_version
                                                ,p_init_msg_list   => p_init_msg_list
                                                ,x_return_status   => x_return_status
                                                ,x_msg_count       => x_msg_count
                                                ,x_msg_data        => x_msg_data
                                                ,p_subsidy_pool_id => cv_get_pool_info.pool_id
                                                ,p_total_budget_amt => lv_calc_total_budget);
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_pvt.update_total_budget with lv_calc_total_budget '||lv_calc_total_budget||' status '||x_return_status||
                                  ' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      x_pool_budget_status := G_ACTIVE_STATUS_CODE;
    ELSIF(l_approval_process in ('AME','WF'))THEN
      -- raise subsidy pool budget approval event, which will then process via AME or workflow
      okl_subsidy_pool_wf.raise_budget_event_approval(p_api_version    => p_api_version
                                                     ,p_init_msg_list  => p_init_msg_list
                                                     ,x_return_status  => x_return_status
                                                     ,x_msg_count      => x_msg_count
                                                     ,x_msg_data       => x_msg_data
                                                     ,p_subsidy_pool_budget_id => p_subsidy_pool_budget_id);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_wf.raise_budget_event_approval returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSICB.pls call submit_budget_for_approval');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END submit_budget_for_approval;

END okl_subsidy_pool_approval_pvt;

/
