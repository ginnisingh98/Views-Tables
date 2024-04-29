--------------------------------------------------------
--  DDL for Package Body OKC_CLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CLASS_PUB" AS
/* $Header: OKCPCLSB.pls 120.0 2005/05/25 19:36:12 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_class_pvt.add_language;
  END;

  PROCEDURE insert_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS
  BEGIN
    okc_class_pvt.insert_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_rec,
              x_clsv_rec);
  END;

  PROCEDURE insert_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS
  BEGIN
    okc_class_pvt.insert_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_tbl,
              x_clsv_tbl);
  END;

  PROCEDURE lock_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS
  BEGIN
    okc_class_pvt.lock_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_rec);
  END;

  PROCEDURE lock_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS
  BEGIN
    okc_class_pvt.lock_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_tbl);
  END;

  PROCEDURE update_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS
  BEGIN
    okc_class_pvt.update_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_rec,
              x_clsv_rec);
  END;

  PROCEDURE update_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS
  BEGIN
    okc_class_pvt.update_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_tbl,
              x_clsv_tbl);
  END;

  PROCEDURE delete_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS
  BEGIN
    okc_class_pvt.delete_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_rec);
  END;

  PROCEDURE delete_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS
  BEGIN
    okc_class_pvt.delete_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_tbl);
  END;

  PROCEDURE validate_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS
  BEGIN
    okc_class_pvt.validate_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_rec);
  END;

  PROCEDURE validate_class(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS
  BEGIN
    okc_class_pvt.validate_class(
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_clsv_tbl);
  END;

END OKC_CLASS_PUB;

/
