--------------------------------------------------------
--  DDL for Package Body OKC_OPERATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OPERATION_PUB" AS
/* $Header: OKCPOPNB.pls 120.0 2005/05/26 09:48:47 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_operation_pvt.add_language;
  END;

  PROCEDURE insert_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_rec                     IN opnv_rec_type,
    x_opnv_rec                     OUT NOCOPY opnv_rec_type) IS
  BEGIN
    okc_operation_pvt.insert_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_rec,
            x_opnv_rec);
  END;

  PROCEDURE insert_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_tbl                     IN opnv_tbl_type,
    x_opnv_tbl                     OUT NOCOPY opnv_tbl_type) IS
  BEGIN
    okc_operation_pvt.insert_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_tbl,
            x_opnv_tbl);
  END;

  PROCEDURE lock_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_rec                     IN opnv_rec_type) IS
  BEGIN
    okc_operation_pvt.lock_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_rec);
  END;

  PROCEDURE lock_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_tbl                     IN opnv_tbl_type) IS
  BEGIN
    okc_operation_pvt.lock_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_tbl);
  END;

  PROCEDURE update_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_rec                     IN opnv_rec_type,
    x_opnv_rec                     OUT NOCOPY opnv_rec_type) IS
  BEGIN
    okc_operation_pvt.update_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_rec,
            x_opnv_rec);
  END;

  PROCEDURE update_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_tbl                     IN opnv_tbl_type,
    x_opnv_tbl                     OUT NOCOPY opnv_tbl_type) IS
  BEGIN
    okc_operation_pvt.update_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_tbl,
            x_opnv_tbl);
  END;

  PROCEDURE delete_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_rec                     IN opnv_rec_type) IS
  BEGIN
    okc_operation_pvt.delete_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_rec);
  END;

  PROCEDURE delete_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_tbl                     IN opnv_tbl_type) IS
  BEGIN
    okc_operation_pvt.delete_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_tbl);
  END;

  PROCEDURE validate_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_rec                     IN opnv_rec_type) IS
  BEGIN
    okc_operation_pvt.validate_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_rec);
  END;

  PROCEDURE validate_operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opnv_tbl                     IN opnv_tbl_type) IS
  BEGIN
    okc_operation_pvt.validate_operation(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_opnv_tbl);
  END;

END OKC_OPERATION_PUB;

/
