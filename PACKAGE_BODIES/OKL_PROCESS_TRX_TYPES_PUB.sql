--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_TRX_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_TRX_TYPES_PUB" AS
/* $Header: OKLPTXTB.pls 115.2 2002/02/18 20:12:17 pkm ship       $ */

  PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.insert_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec,
                                        x_tryv_rec                     => x_tryv_rec);



END;




  PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.insert_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl,
                                        x_tryv_tbl                     => x_tryv_tbl);



END;



  PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.update_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec,
                                        x_tryv_rec                     => x_tryv_rec);



END;



  PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.update_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl,
                                        x_tryv_tbl                     => x_tryv_tbl);



END;


  PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.delete_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec);



END;



  PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type)

IS

l_api_version  NUMBER := 1.0;

BEGIN

     OKL_PROCESS_TRX_TYPES_PVT.delete_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => x_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl);



END;


END OKL_PROCESS_TRX_TYPES_PUB;

/
