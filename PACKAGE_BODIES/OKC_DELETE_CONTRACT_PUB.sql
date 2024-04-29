--------------------------------------------------------
--  DDL for Package Body OKC_DELETE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DELETE_CONTRACT_PUB" as
/* $Header: OKCPDELB.pls 120.0 2005/05/26 09:42:45 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE delete_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_chrv_rec          IN OKC_CONTRACT_PUB.chrv_rec_type ) IS

     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name          VARCHAR2(30) := 'Delete_Contract';

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

   --Start activity;
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    OKC_DELETE_CONTRACT_PVT.delete_contract(
                     p_api_version         => p_api_version,
                     p_init_msg_list       => p_init_msg_list,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data,
                     p_chrv_rec            => p_chrv_rec);


    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

   EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

END Delete_Contract;

PROCEDURE delete_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_chrv_tbl          IN OKC_CONTRACT_PUB.chrv_tbl_type) IS

     i				NUMBER := 0;
     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name          VARCHAR2(30) := 'Delete_Contract';

 BEGIN

     x_return_status := OKC_API.G_RET_STS_SUCCESS;

   --Start activity;
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF p_chrv_tbl.COUNT > 0 THEN
       i := p_chrv_tbl.FIRST;
       LOOP
       	OKC_DELETE_CONTRACT_PUB.Delete_Contract(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_chrv_rec            => p_chrv_tbl(i));

       	IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         	   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           		x_return_status := l_return_status;
           		raise G_EXCEPTION_HALT_PROCESSING;
         	   ELSE
          		x_return_status := l_return_status;
         	   END IF;
       	END IF;
       	EXIT WHEN (i = p_chrv_tbl.LAST);
       	i := p_chrv_tbl.NEXT(i);
       END LOOP;
     END IF;

   OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

   EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Delete_Contract;

END OKC_DELETE_CONTRACT_PUB;

/
