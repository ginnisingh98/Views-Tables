--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_SEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_SEQ_PUB" as
/* $Header: OKCPKSQB.pls 120.0 2005/05/25 19:25:25 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.create_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec,
	    x_ksqv_rec);
  END create_seq_header;

  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.create_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl,
	    x_ksqv_tbl);
  END create_seq_header;

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.update_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec,
	    x_ksqv_rec);
  END update_seq_header;

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.update_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl,
	    x_ksqv_tbl);
  END update_seq_header;

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.delete_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
  END delete_seq_header;

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.delete_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
  END delete_seq_header;

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.lock_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
  END lock_seq_header;

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.lock_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
  END lock_seq_header;

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.validate_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
  END validate_seq_header;

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.validate_seq_header(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
  END validate_seq_header;

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.create_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec,
	    x_lsqv_rec);
  END create_seq_lines;

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.create_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl,
	    x_lsqv_tbl);
  END create_seq_lines;

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.update_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec,
	    x_lsqv_rec);
  END update_seq_lines;

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.update_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl,
	    x_lsqv_tbl);
  END update_seq_lines;

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.delete_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
  END delete_seq_lines;

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.delete_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
  END delete_seq_lines;

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.lock_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
  END lock_seq_lines;

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.lock_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
  END lock_seq_lines;

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    okc_contract_seq_pvt.validate_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
  END validate_seq_lines;

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    okc_contract_seq_pvt.validate_seq_lines(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
  END validate_seq_lines;

  PROCEDURE Is_K_Autogenerated(
    p_scs_code Varchar2,
    x_return_status OUT NOCOPY Varchar2) IS
  BEGIN
    okc_contract_seq_pvt.Is_K_Autogenerated(
            p_scs_code,
            x_return_status);
  END Is_K_Autogenerated;

  PROCEDURE Get_K_Number(
    p_scs_code                     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_contract_number              OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
  BEGIN
    okc_contract_seq_pvt.Get_K_Number(
            p_scs_code,
            p_contract_number_modifier,
            x_contract_number,
            x_return_status);
  END Get_K_Number;

END okc_contract_seq_pub;

/
