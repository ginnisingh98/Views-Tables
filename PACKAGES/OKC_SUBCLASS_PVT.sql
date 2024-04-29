--------------------------------------------------------
--  DDL for Package OKC_SUBCLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SUBCLASS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCSCSS.pls 120.0 2005/05/26 09:57:05 appldev noship $ */

 subtype scsv_rec_type is okc_scs_pvt.scsv_rec_type;
 subtype scsv_tbl_type is okc_scs_pvt.scsv_tbl_type;
 subtype srev_rec_type is okc_sre_pvt.srev_rec_type;
 subtype srev_tbl_type is okc_sre_pvt.srev_tbl_type;
 subtype srdv_rec_type is okc_srd_pvt.srdv_rec_type;
 subtype srdv_tbl_type is okc_srd_pvt.srdv_tbl_type;
 subtype rrdv_rec_type is okc_rrd_pvt.rrdv_rec_type;
 subtype rrdv_tbl_type is okc_rrd_pvt.rrdv_tbl_type;
 subtype stlv_rec_type is okc_stl_pvt.stlv_rec_type;
 subtype stlv_tbl_type is okc_stl_pvt.stlv_tbl_type;
 subtype lsrv_rec_type is okc_lsr_pvt.lsrv_rec_type;
 subtype lsrv_tbl_type is okc_lsr_pvt.lsrv_tbl_type;
 subtype lrgv_rec_type is okc_lrg_pvt.lrgv_rec_type;
 subtype lrgv_tbl_type is okc_lrg_pvt.lrgv_tbl_type;
 subtype srav_rec_type is okc_sra_pvt.srav_rec_type;
 subtype srav_tbl_type is okc_sra_pvt.srav_tbl_type;

 PROCEDURE add_language;

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type);

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type);

 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type);

 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type);

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type);

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type);

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type);

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type);

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type);

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type);

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type);

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type);

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type);

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type);

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type);

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type);

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type);

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type);

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type);

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type);

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type);

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type);

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type);

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type);

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type);

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type);

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type);

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type);

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type);

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type);

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type);

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type);

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type);

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type);

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type);

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type);

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type);

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type);

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type);

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type);

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type);

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type);

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type);

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type);

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type);

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type);

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type);

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type);

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type);

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type);

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type);

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type);

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type);

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type);

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type);

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type);

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type);

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type);

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type);

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type);

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type);

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type);

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type);

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type);

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type);

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type);

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type);

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type);

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type);

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type);

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type);

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type);

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type);

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type);

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type);

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type);

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type);

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type);

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type);

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type);

/*
------------------------------------------------------------------------
| This API will copy One category to another one.                      |
|                                                                      |
|This will copy all the category related informations from foll. views |
|                     OKC_SUBCLASSES_V                                 |
|                     OKC_SUBCLASS_ROLES_V                             |
|                     OKC_SUBCLASS_RG_DEFS_V                           |
|                     OKC_RG_ROLE_DEFS_V                               |
|                     OKC_SUBCLASS_TOP_LINE_V                          |
|                     OKC_LINE_STYLE_ROLES_V                           |
|                     OKC_LSE_ROLE_GROUPS_V                            |
|                     OKC_SUBCLASS_RESPS_V                             |
|                     OKC_ASSENST_V  -- Status and Operation           |
|                                                                      |
|In parameters :                                                       |
|p_copy_from_scs_code ==> Category to be copied.                       |
|p_new_scs_name       ==> Name of new category                         |
|p_new_scs_desc       ==> Desc of new category                         |
|                                                                      |
|Out Parameter :                                                       |
|x_scsv_rec           ==> New subclass Record                          |
|                                                                      |
------------------------------------------------------------------------
*/
PROCEDURE copy_category(
	 p_api_version                  IN NUMBER,
	 p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
	 p_copy_from_scs_code           IN VARCHAR2,
	 p_new_scs_name                 IN VARCHAR2,
	 p_new_scs_desc                 IN VARCHAR2,
         x_scsv_rec                     OUT NOCOPY scsv_rec_type);

END okc_subclass_pvt;

 

/
