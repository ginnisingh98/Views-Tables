--------------------------------------------------------
--  DDL for Package Body OKL_VP_AGRMNT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_AGRMNT_APPROVAL_PVT" AS
/* $Header: OKLRVAAB.pls 120.0 2005/07/28 11:44:04 sjalasut noship $ */

  G_AGR_NOT_PASSED_FOR_APPROVE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_AGR_NOT_PASS_APPROVE';

  G_PENDING_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PENDING_APPROVAL';
  G_REJECTED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'REJECTED';
  G_PASSED_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'PASSED';
  G_ACTIVE_STS_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ACTIVE';

  PROCEDURE submit_oa_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okc_k_headers_b.scs_code%TYPE
                                  ) IS
    CURSOR c_get_oa_sts_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT sts_code
          ,contract_number
      FROM okc_k_headers_b
     WHERE id = cp_chr_id;
    lv_oa_sts_code okc_k_headers_b.sts_code%TYPE;
    lv_agreement_number okc_k_headers_b.contract_number%TYPE;
    l_approval_process VARCHAR2(30);
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_OA_FOR_APPROVAL';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_AGRMNT_APPROVAL_PVT.SUBMIT_OA_FOR_APPROVAL';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVAAB.pls call submit_oa_for_approval');
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

    -- basic validation. oa should be in status passed before it can be submitted for approval
    OPEN c_get_oa_sts_csr (p_chr_id); FETCH c_get_oa_sts_csr INTO lv_oa_sts_code, lv_agreement_number;
    CLOSE c_get_oa_sts_csr;
    IF(lv_oa_sts_code <> G_PASSED_STS_CODE)THEN
      OKL_API.set_message(G_APP_NAME, G_AGR_NOT_PASSED_FOR_APPROVE,'AGR_NUMBER',lv_agreement_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- now that the validation has passed, set the OUT status as PENDING, this is the default case
    x_status_code := G_PENDING_STS_CODE;
    -- read the profile OKL: Operating Agreement Approval Process
    l_approval_process := fnd_profile.value('OKL_VP_OA_APPROVAL_PROCESS');
    IF(NVL(l_approval_process,'NONE')='NONE')THEN
      -- since no option is set at the profile, approve the operating agreement by default
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => G_ACTIVE_STS_CODE
                                                    ,p_chr_id        => p_chr_id
                                                     );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status G_ACTIVE_STS_CODE returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- the approval process profile option is not set, since we are activating the agreement in this case,
      -- the OUT variable should be populated accordingly.
      x_status_code := G_ACTIVE_STS_CODE;
    ELSIF(l_approval_process IN ('AME','WF'))THEN
      -- for the case of workflow or Approvals Management profile option, the agreement is set to status
      -- G_PENDING_STS_CODE
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => G_PENDING_STS_CODE
                                                    ,p_chr_id        => p_chr_id
                                                     );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status G_PENDING_STS_CODE returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      okl_vp_oa_wf.raise_oa_event_approval(p_api_version    => p_api_version
                                          ,p_init_msg_list  => p_init_msg_list
                                          ,x_return_status  => x_return_status
                                          ,x_msg_count      => x_msg_count
                                          ,x_msg_data       => x_msg_data
                                          ,p_chr_id         => p_chr_id);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_vp_oa_wf.raise_oa_event_approval returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of NVL(l_approval_process,'NONE')='NONE'

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVAAB.pls call submit_oa_for_approval');
    END IF;

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
  END submit_oa_for_approval;

  PROCEDURE submit_pa_for_approval(p_api_version   IN NUMBER
                                  ,p_init_msg_list IN VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                  ,x_status_code   OUT NOCOPY okc_k_headers_b.scs_code%TYPE
                                  ) IS
    CURSOR c_get_pa_sts_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT sts_code
          ,contract_number
      FROM okc_k_headers_b
     WHERE id = cp_chr_id;
    lv_pa_sts_code okc_k_headers_b.sts_code%TYPE;
    lv_agreement_number okc_k_headers_b.contract_number%TYPE;
    l_approval_process fnd_lookups.lookup_code%TYPE;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_PA_FOR_APPROVAL';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_AGRMNT_APPROVAL_PVT.SUBMIT_PA_FOR_APPROVAL';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVAAB.pls call submit_pa_for_approval');
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

    -- basic validation. oa should be in status passed before it can be submitted for approval
    OPEN c_get_pa_sts_csr (p_chr_id); FETCH c_get_pa_sts_csr INTO lv_pa_sts_code, lv_agreement_number;
    CLOSE c_get_pa_sts_csr;
    IF(lv_pa_sts_code <> G_PASSED_STS_CODE)THEN
      OKL_API.set_message(G_APP_NAME, G_AGR_NOT_PASSED_FOR_APPROVE,'AGR_NUMBER',lv_agreement_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- now that the validation has passed, set the OUT status as PENDING, this is the default case
    x_status_code := G_PENDING_STS_CODE;
    -- read the profile OKL: Program Agreement Approval Process
    l_approval_process := fnd_profile.value('OKL_VP_PA_APPROVAL_PROCESS');
    IF(NVL(l_approval_process,'NONE')='NONE')THEN
      -- since no option is set at the profile, approve the operating agreement by default
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => G_ACTIVE_STS_CODE
                                                    ,p_chr_id        => p_chr_id
                                                     );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- the approval process profile option is not set, since we are activating the agreement in this case,
      -- the OUT variable should be populated accordingly.
      x_status_code := G_ACTIVE_STS_CODE;
    ELSIF(l_approval_process IN ('AME','WF'))THEN
      -- for the case of workflow or Approvals Management profile option, the agreement is set to status
      -- G_PENDING_STS_CODE
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => G_PENDING_STS_CODE
                                                    ,p_chr_id        => p_chr_id
                                                     );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_contract_status_pub.update_contract_status G_PENDING_STS_CODE returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      x_status_code := G_PENDING_STS_CODE;
      okl_vp_pa_wf.raise_pa_event_approval(p_api_version    => p_api_version
                                          ,p_init_msg_list  => p_init_msg_list
                                          ,x_return_status  => x_return_status
                                          ,x_msg_count      => x_msg_count
                                          ,x_msg_data       => x_msg_data
                                          ,p_chr_id         => p_chr_id);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                ' okl_vp_pa_wf.raise_pa_event_approval returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of NVL(l_approval_process,'NONE')='NONE'

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVAAB.pls call submit_pa_for_approval');
    END IF;

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
  END submit_pa_for_approval;

END okl_vp_agrmnt_approval_pvt;

/
