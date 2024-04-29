--------------------------------------------------------
--  DDL for Package Body OKL_CPY_PDT_RULS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CPY_PDT_RULS_PUB" AS
/* $Header: OKLPPCOB.pls 115.2 2004/04/13 10:55:09 rnaik noship $ */
--start of comments
--API Name      : Copy Product rules
--Description   : This Api will take the product option rules from
--                selected options and will copy them on to the contract
--                at header or line level as per the setup
-- Parameters   : IN parameter - p_khr_id contract header id of the contract
--end of comments
Procedure Copy_Product_Rules(p_api_version     IN  NUMBER,
	                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                         x_return_status   OUT NOCOPY VARCHAR2,
	                         x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             p_khr_id          IN  NUMBER,
                             p_pov_id          IN  NUMBER) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'COPY_PRODUCT_RULES';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --Customer pre-processing Section
     --Vertical Industry pre-processing Section
     -- call pvt api to copy option rules
     OKL_CPY_PDT_RULS_PVT.Copy_Product_Rules
                          (p_api_version   => p_api_version,
	                       p_init_msg_list => p_init_msg_list,
	                       x_return_status => x_return_status,
	                       x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_khr_id        => p_khr_id,
                           p_pov_id        => p_pov_id);

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
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End Copy_Product_Rules;
END OKL_CPY_PDT_RULS_PUB;

/
