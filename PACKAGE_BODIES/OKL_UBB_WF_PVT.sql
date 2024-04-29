--------------------------------------------------------
--  DDL for Package Body OKL_UBB_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UBB_WF_PVT" AS
/* $Header: OKLRUWFB.pls 120.4 2005/10/30 03:17:38 appldev noship $ */

  G_WF_EVT_UBB_CREATED CONSTANT VARCHAR2(55) := 'oracle.apps.okl.la.lease_contract.usage_billing_created';
  G_WF_EVT_UBB_UPDATED CONSTANT VARCHAR2(55) := 'oracle.apps.okl.la.lease_contract.usage_billing_updated';
  G_WF_EVT_UBB_REMOVE  CONSTANT VARCHAR2(55) := 'oracle.apps.okl.la.lease_contract.remove_usage_billing';
  G_WF_EVT_UBB_ADD_ASSET  CONSTANT VARCHAR2(55) := 'oracle.apps.okl.la.lease_contract.usage_asset_added';
  G_WF_EVT_UBB_REMOVE_ASSET  CONSTANT VARCHAR2(55) := 'oracle.apps.okl.la.lease_contract.usage_asset_removed';

  G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(15) := 'CONTRACT_ID';
  G_WF_ITM_UBB_ID CONSTANT VARCHAR2(10) := 'UBB_ID';
  G_WF_ITM_UBB_ASSET_ID CONSTANT VARCHAR2(15) := 'UBB_ASSET_ID';
  G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';

  PROCEDURE raise_create_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN NUMBER,
                         p_ubb_id         IN NUMBER)
  IS
    l_api_name         CONSTANT VARCHAR2(30)  := 'raise_create_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_parameter_list   wf_parameter_list_t;
    l_process          VARCHAR2(20);
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

        l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
  	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ID,p_ubb_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_UBB_CREATED,
								 p_parameters     => l_parameter_list);

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_create_event;

  PROCEDURE raise_update_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN NUMBER,
                         p_ubb_id         IN NUMBER)
  IS
    l_api_name                        CONSTANT VARCHAR2(30)  := 'raise_udpate_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_parameter_list           wf_parameter_list_t;
    l_process          VARCHAR2(20);
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

        l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
  	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ID,p_ubb_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_UBB_UPDATED,
								 p_parameters     => l_parameter_list);

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_update_event;

  PROCEDURE raise_delete_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN NUMBER,
                         p_ubb_id         IN NUMBER)
  IS
    l_api_name                        CONSTANT VARCHAR2(30)  := 'raise_delete_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_parameter_list           wf_parameter_list_t;
    l_process          VARCHAR2(20);
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

        l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
  	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ID,p_ubb_id,l_parameter_list);
        Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_UBB_REMOVE,
								 p_parameters     => l_parameter_list);

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_delete_event;


  PROCEDURE raise_add_asset_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN NUMBER,
                         p_ubb_id         IN NUMBER,
                         p_cle_id         IN NUMBER)
  IS
    l_api_name                        CONSTANT VARCHAR2(30)  := 'raise_add_asset_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_parameter_list           wf_parameter_list_t;
    l_process          VARCHAR2(20);
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

        l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
  	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ID,p_ubb_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ASSET_ID,p_cle_id,l_parameter_list);
        Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_UBB_ADD_ASSET,
								 p_parameters     => l_parameter_list);

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_add_asset_event;

  PROCEDURE raise_delete_asset_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN NUMBER,
                         p_ubb_id         IN NUMBER,
                         p_cle_id         IN NUMBER)
  IS
    l_api_name                        CONSTANT VARCHAR2(30)  := 'raise_delete_asset_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_parameter_list           wf_parameter_list_t;
    l_process          VARCHAR2(20);
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

        l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);
  	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ID,p_ubb_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_UBB_ASSET_ID,p_cle_id,l_parameter_list);
	Wf_Event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_UBB_REMOVE_ASSET,
								 p_parameters     => l_parameter_list);

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_delete_asset_event;


END OKL_UBB_WF_PVT;

/
