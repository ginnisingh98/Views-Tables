--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_APPROVAL_PUB" AS
/* $Header: OKLPCAVB.pls 115.5 2002/03/21 18:03:28 pkm ship       $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_APPROVAL_PUB';
-- Start of comments
--
-- Procedure Name  : start_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE start_process(p_api_version IN number,
                          p_init_msg_list IN varchar2,
                          x_return_status OUT NOCOPY varchar2,
                          x_msg_count OUT NOCOPY number,
                          x_msg_data OUT NOCOPY varchar2,
                          p_contract_id IN number,
                          p_status IN VARCHAR2,
                          p_do_commit IN VARCHAR2) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'start_process';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
 OKL_CONTRACT_APPROVAL_PVT.start_process(p_api_version,
               p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               p_contract_id,
               p_status,
               p_do_commit);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END;

-- Start of comments
--
-- Procedure Name  : stop_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE stop_process(p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_contract_id IN NUMBER,
                       p_do_commit IN VARCHAR2) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'stop_process';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKL_CONTRACT_APPROVAL_PVT.stop_process(p_api_version,
               p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               p_contract_id,
               p_do_commit);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END;

-- Start of comments
--
-- Procedure Name  : populate_active_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE populate_active_process(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_contract_number IN VARCHAR2,
                          p_contract_number_modifier IN VARCHAR2,
                          x_wf_name OUT NOCOPY VARCHAR2,
                          x_wf_process_name OUT NOCOPY VARCHAR2,
                          x_package_name OUT NOCOPY VARCHAR2,
                          x_procedure_name OUT NOCOPY VARCHAR2,
                          x_usage OUT NOCOPY VARCHAR2,
                          x_activeyn OUT NOCOPY VARCHAR2) IS
l_api_name                     CONSTANT VARCHAR2(30) := 'populate_active_process';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKL_CONTRACT_APPROVAL_PVT.populate_active_process(p_api_version,
                          p_init_msg_list,
                          x_return_status,
                          x_msg_count,
                          x_msg_data,
                          p_contract_number,
                          p_contract_number_modifier,
                          x_wf_name,
                          x_wf_process_name,
                          x_package_name,
                          x_procedure_name,
                          x_usage,
                          x_activeyn);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END;

-- Start of comments
--
-- Procedure Name  : monitor_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
FUNCTION monitor_process(p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_contract_id IN NUMBER,
                         p_pdf_id IN NUMBER) RETURN VARCHAR2 IS
url VARCHAR2(300);
l_api_name                     CONSTANT VARCHAR2(30) := 'monitor_process';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := OKC_API.START_ACTIVITY(SUBSTR(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
url := OKL_CONTRACT_APPROVAL_PVT.monitor_process(p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_contract_id,
                         p_pdf_id);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (SUBSTR(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
RETURN url;
END;
END; -- Package Body OKL_CONTRACT_APPROVAL_PUB

/
