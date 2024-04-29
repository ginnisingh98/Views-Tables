--------------------------------------------------------
--  DDL for Package Body OKC_ASSENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ASSENT_PVT" AS
/* $Header: OKCCASTB.pls 120.0 2005/05/25 19:27:07 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE add_language IS
  BEGIN
    okc_sts_pvt.add_language;
  END;

  --------------------------------------
  --PROCEDURE create_assent
  --------------------------------------
  PROCEDURE create_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type,
     x_astv_rec                     OUT NOCOPY astv_rec_type) IS
  BEGIN
     OKC_AST_PVT.Insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec,
                         x_astv_rec);
  END create_assent;

  --------------------------------------
  --PROCEDURE create_assent
  --------------------------------------
  PROCEDURE create_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN  astv_tbl_type,
     x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS
  BEGIN
     OKC_AST_PVT.Insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_tbl,
                         x_astv_tbl);
  END create_assent;

  --------------------------------------
  --PROCEDURE update_assent
  --------------------------------------
  PROCEDURE update_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN  astv_rec_type,
     x_astv_rec                     OUT NOCOPY astv_rec_type) IS
  BEGIN
     OKC_AST_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec,
                         x_astv_rec);
  END update_assent;

  --------------------------------------
  --PROCEDURE update_assent
  --------------------------------------
  PROCEDURE update_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN  astv_tbl_type,
     x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS
  BEGIN
     OKC_AST_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_tbl,
                         x_astv_tbl);
  END update_assent;

  --------------------------------------
  --PROCEDURE delete_assent
  --------------------------------------
  PROCEDURE delete_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN  astv_rec_type) IS
  BEGIN
     OKC_AST_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec);
  END delete_assent;

  --------------------------------------
  --PROCEDURE delete_assent
  --------------------------------------
  PROCEDURE delete_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
  BEGIN
     OKC_AST_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_tbl);
  END delete_assent;

  --------------------------------------
  --PROCEDURE validate_assent
  --------------------------------------
  PROCEDURE validate_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type) IS
  BEGIN
     OKC_AST_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec);
  END validate_assent;

  --------------------------------------
  --PROCEDURE validate_assent
  --------------------------------------
  PROCEDURE validate_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
  BEGIN
     OKC_AST_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_tbl);
  END validate_assent;

  --------------------------------------
  --PROCEDURE lock_assent
  --------------------------------------
  PROCEDURE lock_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_rec                     IN astv_rec_type) IS
  BEGIN
     OKC_AST_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_rec);
  END lock_assent;

  --------------------------------------
  --PROCEDURE lock_assent
  --------------------------------------
  PROCEDURE lock_assent(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_astv_tbl                     IN astv_tbl_type) IS
  BEGIN
     OKC_AST_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_astv_tbl);
  END lock_assent;

  --------------------------------------
  -- FUNCTION header_operation_allowed
  --------------------------------------
  FUNCTION header_operation_allowed(
    p_header_id                    IN NUMBER,
    p_opn_code                     IN VARCHAR2,
    p_crt_id                       IN NUMBER) return varchar2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    l_return_status := OKC_AST_PVT.header_operation_allowed(
                                                           p_header_id,
                                                           p_opn_code,
											    p_crt_id);
    Return(l_return_status);
  END header_operation_allowed;

  --------------------------------------
  -- FUNCTION line_operation_allowed
  --------------------------------------
  FUNCTION line_operation_allowed(
    p_line_id                      IN NUMBER,
    p_opn_code                     IN VARCHAR2) return varchar2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    l_return_status := OKC_AST_PVT.line_operation_allowed(
                                                         p_line_id,
                                                         p_opn_code);
    Return(l_return_status);
  END line_operation_allowed;

  --------------------------------------
  --PROCEDURE create_status
  --------------------------------------
  PROCEDURE create_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type,
     x_stsv_rec                     OUT NOCOPY stsv_rec_type) IS
  BEGIN
     OKC_STS_PVT.Insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec,
                         x_stsv_rec);
  END create_status;

  --------------------------------------
  --PROCEDURE create_status
  --------------------------------------
  PROCEDURE create_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type,
     x_stsv_tbl                     OUT NOCOPY stsv_tbl_type) IS
  BEGIN
     OKC_STS_PVT.Insert_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_tbl,
                         x_stsv_tbl);
  END create_status;

  --------------------------------------
  --PROCEDURE update_status
  --------------------------------------
  PROCEDURE update_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type,
     x_stsv_rec                     OUT NOCOPY stsv_rec_type) IS
  BEGIN
     OKC_STS_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec,
                         x_stsv_rec);
  END update_status;

  --------------------------------------
  --PROCEDURE update_status
  --------------------------------------
  PROCEDURE update_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type,
     x_stsv_tbl                     OUT NOCOPY stsv_tbl_type) IS
  BEGIN
     OKC_STS_PVT.update_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_tbl,
                         x_stsv_tbl);
  END update_status;

  --------------------------------------
  --PROCEDURE delete_status
  --------------------------------------
  PROCEDURE delete_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS
  BEGIN
     OKC_STS_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
  END delete_status;

  --------------------------------------
  --PROCEDURE delete_status
  --------------------------------------
  PROCEDURE delete_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
  BEGIN
     OKC_STS_PVT.delete_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_tbl);
  END delete_status;

  --------------------------------------
  --PROCEDURE lock_status
  --------------------------------------
  PROCEDURE lock_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS
  BEGIN
     OKC_STS_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
  END lock_status;

  --------------------------------------
  --PROCEDURE lock_status
  --------------------------------------
  PROCEDURE lock_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
  BEGIN
     OKC_STS_PVT.lock_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_tbl);
  END lock_status;

  --------------------------------------
  --PROCEDURE validate_status
  --------------------------------------
  PROCEDURE validate_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_rec                     IN stsv_rec_type) IS
  BEGIN
     OKC_STS_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_rec);
  END validate_status;

  --------------------------------------
  --PROCEDURE validate_status
  --------------------------------------
  PROCEDURE validate_status(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 ,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stsv_tbl                     IN  stsv_tbl_type) IS
  BEGIN
     OKC_STS_PVT.validate_row(
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_stsv_tbl);
  END validate_status;

  PROCEDURE get_default_status(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_status_type                  IN VARCHAR2,
    x_status_code                  OUT NOCOPY VARCHAR2) IS
  BEGIN
     OKC_STS_PVT.get_default_status(
                            x_return_status,
                            p_status_type,
                            x_status_code);
  END get_default_status;

  PROCEDURE validate_unique_code(
    p_stsv_rec          IN stsv_rec_type,
    x_return_status     OUT NOCOPY VARCHAR2) IS
  BEGIN
	OKC_STS_PVT.validate_unique_code(
				p_stsv_rec,
				x_return_status);
  END validate_unique_code;

  PROCEDURE validate_unique_meaning(
    p_stsv_rec          IN stsv_rec_type,
    x_return_status     OUT NOCOPY VARCHAR2) IS
  BEGIN
        OKC_STS_PVT.validate_unique_meaning(
                                p_stsv_rec,
                                x_return_status);
  END validate_unique_meaning;

END okc_assent_pvt;


/
