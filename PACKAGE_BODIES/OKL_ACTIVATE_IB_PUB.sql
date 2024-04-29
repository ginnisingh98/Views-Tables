--------------------------------------------------------
--  DDL for Package Body OKL_ACTIVATE_IB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACTIVATE_IB_PUB" as
/* $Header: OKLPAIBB.pls 115.2 2004/04/13 10:28:03 rnaik noship $ */
PROCEDURE   ACTIVATE_IB_INSTANCE(p_api_version   IN  NUMBER,
	                             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                             x_return_status   OUT NOCOPY VARCHAR2,
	                             x_msg_count       OUT NOCOPY NUMBER,
	                             x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chrv_id         IN  NUMBER,
                                 p_call_mode       IN  VARCHAR2,
                                 x_cimv_tbl        OUT NOCOPY cimv_tbl_type) is

l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name          CONSTANT VARCHAR2(30) := 'ACTIVATE_IB_INSTANCE';
l_api_version	    CONSTANT NUMBER	:= 1.0;

begin
-----
    --start activity
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Customer pre-processing Section
    --Vertical Industry pre-processing Section
    --Business Logic
    OKL_ACTIVATE_IB_PVT.Activate_ib_instance
                                (p_api_version    => p_api_version,
	                             p_init_msg_list  => p_init_msg_list,
	                             x_return_status  => x_return_status,
	                             x_msg_count      => x_msg_count,
	                             x_msg_data       => x_msg_data,
                                 p_chrv_id        => p_chrv_id,
                                 p_call_mode      => p_call_mode,
                                 x_cimv_tbl       => x_cimv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Vertical post-processing Section
    --Customer post-processing Section
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

   WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      --OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
END ACTIVATE_IB_INSTANCE;
END OKL_ACTIVATE_IB_PUB;

/
