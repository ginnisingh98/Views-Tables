--------------------------------------------------------
--  DDL for Package OKC_CONDITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONDITIONS_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCCNHS.pls 120.0 2005/05/25 18:00:18 appldev noship $ */

 subtype cnhv_rec_type is okc_cnh_pvt.cnhv_rec_type;
 subtype cnhv_tbl_type is okc_cnh_pvt.cnhv_tbl_type;
 subtype cnlv_rec_type is okc_cnl_pvt.cnlv_rec_type;
 subtype cnlv_tbl_type is okc_cnl_pvt.cnlv_tbl_type;
 subtype coev_rec_type is okc_coe_pvt.coev_rec_type;
 subtype coev_tbl_type is okc_coe_pvt.coev_tbl_type;
 subtype aavv_rec_type is okc_aav_pvt.aavv_rec_type;
 subtype aavv_tbl_type is okc_aav_pvt.aavv_tbl_type;
 subtype aalv_rec_type is okc_aal_pvt.aalv_rec_type;
 subtype aalv_tbl_type is okc_aal_pvt.aalv_tbl_type;
 subtype fepv_rec_type is okc_fep_pvt.fepv_rec_type;
 subtype fepv_tbl_type is okc_fep_pvt.fepv_tbl_type;
 subtype ocev_rec_type is okc_oce_pvt.ocev_rec_type;
 subtype ocev_tbl_type is okc_oce_pvt.ocev_tbl_type;
 subtype oatv_rec_type is okc_oat_pvt.oatv_rec_type;
 subtype oatv_tbl_type is okc_oat_pvt.oatv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONDITIONS_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE ADD_LANGUAGE;

 --Object type procedure for insert
 PROCEDURE create_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type);

 --Object type procedure for update
 PROCEDURE update_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type);

 --Object type procedure for validate
 PROCEDURE validate_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    p_cnlv_tbl                     IN cnlv_tbl_type);

 --Procedures for Condition Headers
 PROCEDURE create_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type);

 PROCEDURE create_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type);

 PROCEDURE lock_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

 PROCEDURE lock_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);

 PROCEDURE update_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type,
    x_cnhv_tbl                     OUT NOCOPY cnhv_tbl_type);

 PROCEDURE update_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type,
    x_cnhv_rec                     OUT NOCOPY cnhv_rec_type);

 PROCEDURE delete_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

 PROCEDURE delete_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);

  PROCEDURE validate_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_tbl                     IN cnhv_tbl_type);

 PROCEDURE validate_cond_hdrs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnhv_rec                     IN cnhv_rec_type);


 --Procedures for Condition Lines
 PROCEDURE create_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type);

 PROCEDURE create_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type,
    x_cnlv_rec                     OUT NOCOPY cnlv_rec_type);

 PROCEDURE lock_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type);

 PROCEDURE lock_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type);

 PROCEDURE update_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type,
    x_cnlv_tbl                     OUT NOCOPY cnlv_tbl_type);

 PROCEDURE update_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type,
    x_cnlv_rec                     OUT NOCOPY cnlv_rec_type);

 PROCEDURE delete_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type);

 PROCEDURE delete_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type);

 PROCEDURE validate_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_tbl                     IN cnlv_tbl_type);

 PROCEDURE validate_cond_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnlv_rec                     IN cnlv_rec_type);

 --Procedures for Condition Occurrences
 PROCEDURE create_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_tbl                     IN coev_tbl_type,
    x_coev_tbl                     OUT NOCOPY coev_tbl_type);

 PROCEDURE create_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_rec                     IN coev_rec_type,
    x_coev_rec                     OUT NOCOPY coev_rec_type);

 PROCEDURE delete_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_rec                     IN coev_rec_type);

 PROCEDURE delete_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_tbl                     IN coev_tbl_type);

 PROCEDURE validate_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_tbl                     IN coev_tbl_type);

 PROCEDURE validate_cond_occurs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coev_rec                     IN coev_rec_type);

 --Procedures for Action Attribute Values
 PROCEDURE create_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type,
    x_aavv_tbl                     OUT NOCOPY aavv_tbl_type);

 PROCEDURE create_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type,
    x_aavv_rec                     OUT NOCOPY aavv_rec_type);

 PROCEDURE delete_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type);

 PROCEDURE delete_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type);

 PROCEDURE validate_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_tbl                     IN aavv_tbl_type);

 PROCEDURE validate_act_att_vals(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aavv_rec                     IN aavv_rec_type);

 --Procedures for Action Attribute Lookups
 PROCEDURE create_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type,
    x_aalv_tbl                     OUT NOCOPY aalv_tbl_type);

 PROCEDURE create_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type,
    x_aalv_rec                     OUT NOCOPY aalv_rec_type);

 PROCEDURE lock_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type);

 PROCEDURE lock_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type);

 PROCEDURE update_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type,
    x_aalv_tbl                     OUT NOCOPY aalv_tbl_type);

 PROCEDURE update_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type,
    x_aalv_rec                     OUT NOCOPY aalv_rec_type);

 PROCEDURE delete_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type);

 PROCEDURE delete_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type);

 PROCEDURE validate_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type);

 PROCEDURE validate_act_att_lkps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type);

 --Procedures for Function Expression Parameters
 PROCEDURE create_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type,
    x_fepv_tbl                     OUT NOCOPY fepv_tbl_type);

 PROCEDURE create_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type,
    x_fepv_rec                     OUT NOCOPY fepv_rec_type);

 PROCEDURE lock_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type);

 PROCEDURE lock_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type);

 PROCEDURE update_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type,
    x_fepv_tbl                     OUT NOCOPY fepv_tbl_type);

 PROCEDURE update_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type,
    x_fepv_rec                     OUT NOCOPY fepv_rec_type);

 PROCEDURE delete_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type);

 PROCEDURE delete_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type);

 PROCEDURE validate_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type);

 PROCEDURE validate_func_exprs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type);

PROCEDURE valid_condition_lines(
    p_cnh_id                       IN okc_condition_headers_b.id%TYPE,
    x_string                       OUT NOCOPY VARCHAR2,
    x_valid_flag                   OUT NOCOPY VARCHAR2);

END okc_conditions_pvt;


 

/
