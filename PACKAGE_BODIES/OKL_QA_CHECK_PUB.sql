--------------------------------------------------------
--  DDL for Package Body OKL_QA_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QA_CHECK_PUB" AS
/* $Header: OKLPQAKB.pls 120.12 2007/05/14 17:18:36 rpillay noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;


  PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY msg_tbl_type,
    p_call_mode                    IN  VARCHAR2 DEFAULT 'ACTUAL')
  IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'execute_qa_check_list';
    l_msg_tbl                      OKC_QA_CHECK_PUB.msg_tbl_type;
    i NUMBER;

    -- Bug# 3477560
    CURSOR khr_sts_csr (p_chr_id IN NUMBER) is
    SELECT STS_CODE,
           SCS_CODE,
           CONTRACT_NUMBER
    FROM   OKC_K_HEADERS_B
    WHERE  ID = p_chr_id;
    l_khr_sts         OKC_K_HEADERS_B.STS_CODE%TYPE;
    l_khr_scs_code    OKC_K_HEADERS_B.SCS_CODE%Type;
    l_khr_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

    CURSOR check_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT count(1)
    FROM   okl_rbk_selected_contract
    WHERE  khr_id = p_chr_id
    AND    NVL(status,'NEW') = 'UNDER REVISION';
    l_mrbk NUMBER;

    CURSOR chr_qcl_csr (p_chr_id IN NUMBER) is
    SELECT 'Y'
    FROM   OKC_K_HEADERS_B
    WHERE  ID = p_chr_id
    AND QCL_ID IS NOT NULL;
    l_qcl_yn VARCHAR2(1) := null;

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
--    g_qclv_rec := p_qclv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug# 5142890 - Check for missing qcl id
    l_qcl_yn := null;
    OPEN chr_qcl_csr (p_chr_id => p_chr_id);
    FETCH chr_qcl_csr INTO l_qcl_yn;
    CLOSE chr_qcl_csr;

    IF (l_qcl_yn IS NULL) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     =>  'OKL_MISSING_QCL_ID');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug# 3477560 - Do not allow modification when contract status is
    -- PENDING_APPROVAL
    IF (p_call_mode = 'ACTUAL') THEN
        OPEN khr_sts_csr (p_chr_id => p_chr_id);
        FETCH khr_sts_csr into
              l_khr_sts,
              l_khr_scs_code,
              l_khr_contract_number;
        IF khr_sts_csr%FOUND THEN
          IF l_khr_scs_code = 'LEASE' AND l_khr_sts = 'PENDING_APPROVAL' THEN
            OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                                p_msg_name     =>  'OKL_LLA_PENDING_APPROVAL',
                                p_token1       =>  'CONTRACT_NUMBER',
                                p_token1_value =>  l_khr_contract_number);
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          l_mrbk := 0;
          OPEN check_csr (p_chr_id);
          FETCH check_csr INTO l_mrbk;
          CLOSE check_csr;

          IF (l_mrbk = 0) THEN -- not a mass rebook contract
            IF (l_khr_sts <> 'NEW' AND l_khr_sts <> 'INCOMPLETE' ) THEN
              OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                                p_msg_name     =>  'OKL_QA_ALREADY_VAL');
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END IF;

        -- Sales Tax, dedey
        -- Call tax engine to calculate Sales Tax
        --
        -- Sales Tax calculation moved to a separate step in
        -- contract booking flow.

    END IF;

    OKC_QA_CHECK_PUB.execute_qa_check_list(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_qcl_id                   => p_qcl_id,
      p_chr_id                   => p_chr_id,
      x_msg_tbl                  => l_msg_tbl);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     --migrate okc output to okl output
     i := 1;
     Loop
        x_msg_tbl(i).severity := l_msg_tbl(i).severity;
        x_msg_tbl(i).name     := l_msg_tbl(i).name;
        x_msg_tbl(i).description := l_msg_tbl(i).description;
        x_msg_tbl(i).package_name := l_msg_tbl(i).package_name;
        x_msg_tbl(i).procedure_name := l_msg_tbl(i).procedure_name;

        -- Added by dedey
        x_msg_tbl(i).data         := l_msg_tbl(i).data;
        x_msg_tbl(i).error_status := l_msg_tbl(i).error_status;
        -- Added by dedey

        If l_msg_tbl.LAST = i Then
           Exit;
        Else
           i := i + 1;
        End If;
     End Loop;
--     g_qclv_rec := x_qclv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END execute_qa_check_list;


END okl_qa_check_pub;

/
