--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_INTERFACE_PUB" AS
/* $Header: OKLPTIFB.pls 115.3 2003/03/11 17:26:50 rabhupat noship $ */

PROCEDURE termination_interface(err_buf  OUT NOCOPY VARCHAR2,
                                ret_code OUT NOCOPY NUMBER) IS
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_init_msg_list         VARCHAR2(1)            := OKC_API.G_TRUE;
l_api_version           CONSTANT NUMBER        := 1;
l_api_name              VARCHAR2(30)           := 'TERMINATION_INTERFACE';
BEGIN
     OKL_AM_TERMNT_INTERFACE_PVT.termination_interface(p_api_version    => l_api_version
                                                      ,p_init_msg_list  => l_init_msg_list
                                                      ,x_msg_data       => l_msg_data
                                                      ,x_msg_count      => l_msg_count
                                                      ,x_return_status  => l_return_status
                                                      ,err_buf          => err_buf
                                                      ,ret_code         => ret_code);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                   G_PKG_NAME,
                                                  'OKC_API.G_RET_STS_ERROR',
                                                   l_msg_count,
                                                   l_msg_data,
                                                  '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status :=OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                  G_PKG_NAME,
                                                  'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                  l_msg_count,
                                                  l_msg_data,
                                                  '_PVT');
     WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
END termination_interface;

END OKL_AM_TERMNT_INTERFACE_PUB;

/
