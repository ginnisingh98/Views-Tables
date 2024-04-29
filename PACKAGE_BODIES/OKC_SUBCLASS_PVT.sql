--------------------------------------------------------
--  DDL for Package Body OKC_SUBCLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SUBCLASS_PVT" AS
/* $Header: OKCCSCSB.pls 120.0 2005/05/25 19:34:51 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 PROCEDURE add_language IS
 BEGIN
   okc_scs_pvt.add_language;
 END;

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS
 BEGIN
    okc_scs_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec,
                x_scsv_rec);
 END create_subclass;

 PROCEDURE create_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS
 BEGIN
    okc_scs_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl,
                x_scsv_tbl);
 END create_subclass;


 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS
 BEGIN
    okc_scs_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec,
                x_scsv_rec);
 END update_subclass;


 PROCEDURE update_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS
 BEGIN
    okc_scs_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl,
                x_scsv_tbl);
 END update_subclass;

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
 BEGIN
    okc_scs_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
 END delete_subclass;

 PROCEDURE delete_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
 BEGIN
    okc_scs_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl);
 END delete_subclass;

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
 BEGIN
    okc_scs_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
 END lock_subclass;

 PROCEDURE lock_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
 BEGIN
    okc_scs_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl);
 END lock_subclass;

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS
 BEGIN
    okc_scs_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_rec);
 END validate_subclass;

 PROCEDURE validate_subclass(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN  scsv_tbl_type) IS
 BEGIN
    okc_scs_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scsv_tbl);
 END validate_subclass;

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS
 BEGIN
    okc_sre_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec,
                x_srev_rec);
 END create_subclass_roles;

 PROCEDURE create_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS
 BEGIN
    okc_sre_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl,
                x_srev_tbl);
 END create_subclass_roles;

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS
 BEGIN
    okc_sre_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec,
                x_srev_rec);
 END update_subclass_roles;

 PROCEDURE update_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS
 BEGIN
    okc_sre_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl,
                x_srev_tbl);
 END update_subclass_roles;

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
 BEGIN
    okc_sre_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
 END delete_subclass_roles;

 PROCEDURE delete_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
 BEGIN
    okc_sre_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl);
 END delete_subclass_roles;

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
 BEGIN
    okc_sre_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
 END lock_subclass_roles;

 PROCEDURE lock_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
 BEGIN
    okc_sre_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl);
 END lock_subclass_roles;

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS
 BEGIN
    okc_sre_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_rec);
 END validate_subclass_roles;

 PROCEDURE validate_subclass_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN  srev_tbl_type) IS
 BEGIN
    okc_sre_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srev_tbl);
 END validate_subclass_roles;

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type) IS
 BEGIN
    okc_srd_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec,
                x_srdv_rec);
 END create_subclass_rg_defs;

 PROCEDURE create_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type) IS
 BEGIN
    okc_srd_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl,
                x_srdv_tbl);
 END create_subclass_rg_defs;

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type,
    x_srdv_rec                     OUT NOCOPY srdv_rec_type) IS
 BEGIN
    okc_srd_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec,
                x_srdv_rec);
 END update_subclass_rg_defs;

 PROCEDURE update_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type,
    x_srdv_tbl                     OUT NOCOPY srdv_tbl_type) IS
 BEGIN
    okc_srd_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl,
                x_srdv_tbl);
 END update_subclass_rg_defs;

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
 BEGIN
    okc_srd_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
 END delete_subclass_rg_defs;

 PROCEDURE delete_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
 BEGIN
    okc_srd_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl);
 END delete_subclass_rg_defs;

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
 BEGIN
    okc_srd_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
 END lock_subclass_rg_defs;

 PROCEDURE lock_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
 BEGIN
    okc_srd_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl);
 END lock_subclass_rg_defs;

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_rec                     IN srdv_rec_type) IS
 BEGIN
    okc_srd_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_rec);
 END validate_subclass_rg_defs;

 PROCEDURE validate_subclass_rg_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srdv_tbl                     IN  srdv_tbl_type) IS
 BEGIN
    okc_srd_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srdv_tbl);
 END validate_subclass_rg_defs;

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS
 BEGIN
    okc_rrd_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec,
                x_rrdv_rec);
 END create_rg_role_defs;

 PROCEDURE create_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS
 BEGIN
    okc_rrd_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl,
                x_rrdv_tbl);
 END create_rg_role_defs;

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type,
    x_rrdv_rec                     OUT NOCOPY rrdv_rec_type) IS
 BEGIN
    okc_rrd_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec,
                x_rrdv_rec);
 END update_rg_role_defs;

 PROCEDURE update_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type,
    x_rrdv_tbl                     OUT NOCOPY rrdv_tbl_type) IS
 BEGIN
    okc_rrd_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl,
                x_rrdv_tbl);
 END update_rg_role_defs;

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
 BEGIN
    okc_rrd_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
 END delete_rg_role_defs;

 PROCEDURE delete_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
 BEGIN
    okc_rrd_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl);
 END delete_rg_role_defs;

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
 BEGIN
    okc_rrd_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
 END lock_rg_role_defs;

 PROCEDURE lock_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
 BEGIN
    okc_rrd_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl);
 END lock_rg_role_defs;

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_rec                     IN rrdv_rec_type) IS
 BEGIN
    okc_rrd_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_rec);
 END validate_rg_role_defs;

 PROCEDURE validate_rg_role_defs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rrdv_tbl                     IN  rrdv_tbl_type) IS
 BEGIN
    okc_rrd_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_rrdv_tbl);
 END validate_rg_role_defs;

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS
 BEGIN
    okc_stl_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec,
                x_stlv_rec);
 END create_subclass_top_line;

 PROCEDURE create_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS
 BEGIN
    okc_stl_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl,
                x_stlv_tbl);
 END create_subclass_top_line;

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS
 BEGIN
    okc_stl_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec,
                x_stlv_rec);
 END update_subclass_top_line;

 PROCEDURE update_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS
 BEGIN
    okc_stl_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl,
                x_stlv_tbl);
 END update_subclass_top_line;

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
 BEGIN
    okc_stl_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
 END delete_subclass_top_line;

 PROCEDURE delete_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
 BEGIN
    okc_stl_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl);
 END delete_subclass_top_line;

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
 BEGIN
    okc_stl_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
 END lock_subclass_top_line;

 PROCEDURE lock_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
 BEGIN
    okc_stl_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl);
 END lock_subclass_top_line;

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS
 BEGIN
    okc_stl_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_rec);
 END validate_subclass_top_line;

 PROCEDURE validate_subclass_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN  stlv_tbl_type) IS
 BEGIN
    okc_stl_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_stlv_tbl);
 END validate_subclass_top_line;

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type) IS
 BEGIN
    okc_lsr_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec,
                x_lsrv_rec);
 END create_line_style_roles;

 PROCEDURE create_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type) IS
 BEGIN
    okc_lsr_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl,
                x_lsrv_tbl);
 END create_line_style_roles;

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type,
    x_lsrv_rec                     OUT NOCOPY lsrv_rec_type) IS
 BEGIN
    okc_lsr_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec,
                x_lsrv_rec);
 END update_line_style_roles;

 PROCEDURE update_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type,
    x_lsrv_tbl                     OUT NOCOPY lsrv_tbl_type) IS
 BEGIN
    okc_lsr_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl,
                x_lsrv_tbl);
 END update_line_style_roles;

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
 BEGIN
    okc_lsr_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
 END delete_line_style_roles;

 PROCEDURE delete_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
 BEGIN
    okc_lsr_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl);
 END delete_line_style_roles;

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
 BEGIN
    okc_lsr_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
 END lock_line_style_roles;

 PROCEDURE lock_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
 BEGIN
    okc_lsr_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl);
 END lock_line_style_roles;

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_rec                     IN lsrv_rec_type) IS
 BEGIN
    okc_lsr_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_rec);
 END validate_line_style_roles;

 PROCEDURE validate_line_style_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsrv_tbl                     IN  lsrv_tbl_type) IS
 BEGIN
    okc_lsr_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lsrv_tbl);
 END validate_line_style_roles;

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type) IS
 BEGIN
    okc_lrg_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec,
                x_lrgv_rec);
 END create_lse_rule_groups;

 PROCEDURE create_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type) IS
 BEGIN
    okc_lrg_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl,
                x_lrgv_tbl);
 END create_lse_rule_groups;

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type,
    x_lrgv_rec                     OUT NOCOPY lrgv_rec_type) IS
 BEGIN
    okc_lrg_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec,
                x_lrgv_rec);
 END update_lse_rule_groups;

 PROCEDURE update_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type,
    x_lrgv_tbl                     OUT NOCOPY lrgv_tbl_type) IS
 BEGIN
    okc_lrg_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl,
                x_lrgv_tbl);
 END update_lse_rule_groups;

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
 BEGIN
    okc_lrg_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
 END delete_lse_rule_groups;

 PROCEDURE delete_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
 BEGIN
    okc_lrg_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl);
 END delete_lse_rule_groups;

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
 BEGIN
    okc_lrg_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
 END lock_lse_rule_groups;

 PROCEDURE lock_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
 BEGIN
    okc_lrg_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl);
 END lock_lse_rule_groups;

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_rec                     IN lrgv_rec_type) IS
 BEGIN
    okc_lrg_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_rec);
 END validate_lse_rule_groups;

 PROCEDURE validate_lse_rule_groups(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lrgv_tbl                     IN  lrgv_tbl_type) IS
 BEGIN
    okc_lrg_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_lrgv_tbl);
 END validate_lse_rule_groups;

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type) IS
 BEGIN
    okc_sra_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec,
                x_srav_rec);
 END create_subclass_resps;

 PROCEDURE create_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type) IS
 BEGIN
    okc_sra_pvt.insert_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl,
                x_srav_tbl);
 END create_subclass_resps;

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type,
    x_srav_rec                     OUT NOCOPY srav_rec_type) IS
 BEGIN
    okc_sra_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec,
                x_srav_rec);
 END update_subclass_resps;

 PROCEDURE update_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type,
    x_srav_tbl                     OUT NOCOPY srav_tbl_type) IS
 BEGIN
    okc_sra_pvt.update_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl,
                x_srav_tbl);
 END update_subclass_resps;

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
 BEGIN
    okc_sra_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
 END delete_subclass_resps;

 PROCEDURE delete_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
 BEGIN
    okc_sra_pvt.delete_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl);
 END delete_subclass_resps;

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
 BEGIN
    okc_sra_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
 END lock_subclass_resps;

 PROCEDURE lock_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
 BEGIN
    okc_sra_pvt.lock_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl);
 END lock_subclass_resps;

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_rec                     IN srav_rec_type) IS
 BEGIN
    okc_sra_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_rec);
 END validate_subclass_resps;

 PROCEDURE validate_subclass_resps(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srav_tbl                     IN  srav_tbl_type) IS
 BEGIN
    okc_sra_pvt.validate_row(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_srav_tbl);
 END validate_subclass_resps;

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
------------------------------------------------------------------------
*/

PROCEDURE copy_category(
                         p_api_version                  IN NUMBER,
                         p_init_msg_list                IN VARCHAR2 ,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_copy_from_scs_code           IN VARCHAR2,
                         p_new_scs_name                 IN VARCHAR2,
	                 p_new_scs_desc                 IN VARCHAR2,
                         x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS


/* Cursor to get existing Subclass Information */

CURSOR c_get_sublass(b_scs_code varchar2) IS
	 SELECT
	 cls_code,
	 meaning ,
         description,
	 start_date,
         end_date ,
	 create_opp_yn ,
	 access_level
FROM okc_subclasses_v
WHERE code=b_scs_code;

/* Cursor to get existing Subclass Role Information */

CURSOR c_get_scs_role(b_scs_code varchar2) IS
 SELECT
  id,
  rle_code  ,
  scs_code  ,
  start_date ,
  end_date ,
  access_level
FROM okc_subclass_roles_v
WHERE scs_code=b_scs_code;

/* Cursor to get existing Subclass Rule Group Information */
CURSOR c_get_scs_rg_defs(b_scs_code varchar2)IS
SELECT
  id,
  rgd_code,
  scs_code,
  start_date,
  end_date,
  access_level
FROM okc_subclass_rg_defs_v
WHERE scs_code=b_scs_code;

/* Cursor to get existing Subclass Rule Group Role Information */

CURSOR c_get_rg_role_defs(b_scs_code varchar2)IS
SELECT
  srd_id,
  sre_id,
  subject_object_flag,
  optional_yn,
  attribute_category,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  access_level
FROM okc_rg_role_defs_v
WHERE srd_id IN
	  ( SELECT id FROM okc_subclass_rg_defs_v WHERE scs_code=b_scs_code)
AND sre_id IN
    (SELECT id FROM  okc_subclass_roles_v WHERE scs_code=b_scs_code);


/* Cursor to get existing Subclass Top Line Information */

CURSOR c_get_subclass_top_line(b_scs_code varchar2)IS
SELECT
 lse_id,
 scs_code,
 start_date,
 end_date,
 access_level
FROM okc_subclass_top_line_v
WHERE scs_code=b_scs_code;


/* Cursor to get existing Subclass Top Line Role Information */

CURSOR c_get_LINE_STYLE_ROLES(b_scs_code varchar2)IS
SELECT
   lse_id,
   sre_id,
   access_level
FROM OKC_LINE_STYLE_ROLES_v
WHERE sre_id IN
    (SELECT id FROM  okc_subclass_roles_v WHERE scs_code=b_scs_code);


/* Cursor to get existing Subclass Top Line Rule Group Information */

CURSOR c_get_LSE_RULE_GROUPS(b_scs_code varchar2)IS
SELECT
     lse_id,
     srd_id,
     access_level
FROM OKC_LSE_RULE_GROUPS_v
WHERE srd_id IN
   ( SELECT id FROM okc_subclass_rg_defs_v WHERE scs_code=b_scs_code);


/* Cursor to get existing Subclass Responsibility Information */

CURSOR c_get_subclass_resps(b_scs_code varchar2)IS
SELECT
 resp_id,
 scs_code,
 access_level,
 start_date,
 end_date
FROM OKC_subclass_resps_v
WHERE scs_code=b_scs_code;


/* Cursor to get existing Subclass Status and Operation Information */

CURSOR c_get_assents(b_scs_code varchar2) IS
SELECT
 sts_code,
 opn_code,
 ste_code,
 scs_code,
 allowed_yn ,
 attribute_category ,
 attribute1,
 attribute2,
 attribute3,
 attribute4,
 attribute5,
 attribute6,
 attribute7,
 attribute8,
 attribute9,
 attribute10,
 attribute11,
 attribute12,
 attribute13,
 attribute14,
 attribute15
 FROM okc_assents_v
 WHERE scs_code=b_scs_code;


TYPE srd_relationship_type IS RECORD (
	 old_srd_id      NUMBER,
	 new_srd_id      NUMBER);

TYPE srd_relationship_tbl_type IS TABLE OF srd_relationship_type INDEX BY BINARY_INTEGER;

srd_relationship_tbl srd_relationship_tbl_type;  -- table to store Relationship betwen old and New SRD Id.

TYPE sre_relationship_type IS RECORD (
	 old_sre_id      NUMBER,
	 new_sre_id      NUMBER);

TYPE sre_relationship_tbl_type IS TABLE OF sre_relationship_type INDEX BY BINARY_INTEGER;

sre_relationship_tbl sre_relationship_tbl_type; -- Table to store Information between Old and New SRE id.

l_scsv_rec  scsv_rec_type;
lx_scsv_rec scsv_rec_type;

l_srev_tbl  srev_tbl_type;
lx_srev_tbl srev_tbl_type;

l_srdv_tbl  srdv_tbl_type;
lx_srdv_tbl srdv_tbl_type;

l_rrdv_tbl  rrdv_tbl_type;
lx_rrdv_tbl rrdv_tbl_type;

l_stlv_tbl  stlv_tbl_type;
lx_stlv_tbl stlv_tbl_type;

l_lsrv_tbl  lsrv_tbl_type;
lx_lsrv_tbl lsrv_tbl_type;

l_lrgv_tbl  lrgv_tbl_type;
lx_lrgv_tbl lrgv_tbl_type;

l_srav_tbl  srav_tbl_type;
lx_srav_tbl srav_tbl_type;

l_astv_tbl   okc_ast_pvt.astv_tbl_type ;
lx_astv_tbl  okc_ast_pvt.astv_tbl_type ;


l_return_status VARCHAR2(1);
l_cnt           Number := 0;

l_scs_role           c_get_scs_role%ROWTYPE;
l_scs_rg_defs        c_get_scs_rg_defs%ROWTYPE;
l_rg_role_defs       c_get_rg_role_defs%ROWTYPE;
l_subclass_top_line  c_get_subclass_top_line%ROWTYPE;
l_line_style_roles   c_get_line_style_roles%ROWTYPE;
l_lse_rule_groups    c_get_lse_rule_groups%ROWTYPE;
l_subclass_resps     c_get_subclass_resps%ROWTYPE;
l_assents            c_get_assents %ROWTYPE;


/* Start  Function to get New SRD id from PL/SQL table for old SRD id */

FUNCTION get_new_srd_id (
                        p_old_srd_id 	IN Number,
                        p_srd_relationship_tbl srd_relationship_tbl_type
	        	) RETURN number IS

l_new_srd_id number := 0;

BEGIN


 FOR i in p_srd_relationship_tbl.FIRST..p_srd_relationship_tbl.LAST LOOP

      IF p_srd_relationship_tbl(i).old_srd_id = p_old_srd_id THEN

		  l_new_srd_id := p_srd_relationship_tbl(i).new_srd_id ;
		  EXIT;

      END IF;

 END LOOP;

 return l_new_srd_id;
END;

/* End : Function to get New SRD id from PL/SQL table for old SRD id */



/* Start  Function to get New SRE id from PL/SQL table for old SRE id */

FUNCTION get_new_sre_id (
                        p_old_sre_id 	IN Number,
                        p_sre_relationship_tbl sre_relationship_tbl_type
	         	) RETURN number IS

l_new_sre_id number := 0;

BEGIN

 FOR i in p_sre_relationship_tbl.FIRST..p_sre_relationship_tbl.LAST LOOP

      IF p_sre_relationship_tbl(i).old_sre_id = p_old_sre_id THEN
		  l_new_sre_id := p_sre_relationship_tbl(i).new_sre_id ;
		  EXIT;
      END IF;

 END LOOP;

 return l_new_sre_id;
END;

/* End : Function to get New SRE id from PL/SQL table for old SRE id */

BEGIN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1000 : Starting OKC_SUBCLASS_PVT.Copy_category ', 2);
END IF;

sre_relationship_tbl.delete;
srd_relationship_tbl.delete;

/* Start Copying Subclass Header  */

OPEN c_get_sublass(p_copy_from_scs_code);

FETCH  c_get_sublass into l_scsv_rec.cls_code,
				         l_scsv_rec.meaning,
				         l_scsv_rec.description ,
				         l_scsv_rec.start_date,
				         l_scsv_rec.end_date,
				         l_scsv_rec.create_opp_yn,
				         l_scsv_rec.access_level;

l_scsv_rec.start_date  := trunc(sysdate); -- Start date for new Category will be todays date.
l_scsv_rec.end_date    := null;

l_scsv_rec.meaning     := p_new_scs_name;
l_scsv_rec.description := p_new_scs_desc;

ClOSE c_get_sublass;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1003 : Calling OKC_SUBCLASS_PVT.create_subclass ', 2);
END IF;

create_subclass(
               p_api_version    => p_api_version ,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => l_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_scsv_rec       => l_scsv_rec,
               x_scsv_rec       => lx_scsv_rec);

 IF (l_debug = 'Y') THEN
    OKC_DEBUG.log('1004 : Exit OKC_SUBCLASS_PVT.create_subclass '||l_return_status, 2);
 END IF;

 IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	   x_return_status := l_return_status;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
       	   x_return_status := l_return_status;
           RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

/* End Copying Subclass Header  */


/* Start : Copying Subclass Party Role  */

    l_srev_tbl.delete;
    lx_srev_tbl.delete;
    l_cnt := 0;

 OPEN c_get_scs_role(p_copy_from_scs_code);
 LOOP

    FETCH c_get_scs_role INTO  l_scs_role;


    EXIT WHEN c_get_scs_role%NOTFOUND;
    l_cnt := l_cnt + 1;

    sre_relationship_tbl(l_cnt).old_sre_id := l_scs_role.id; -- Population SRE relationship table with existing SRE ID

    l_srev_tbl(l_cnt).rle_code     := l_scs_role.rle_code;
    l_srev_tbl(l_cnt).end_date     := null;
    l_srev_tbl(l_cnt).access_level := l_scs_role.access_level;
    l_srev_tbl(l_cnt).scs_code     := lx_scsv_rec.code;
    l_srev_tbl(l_cnt).start_date   := trunc(sysdate);

  END LOOP;
  CLOSE c_get_scs_role;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1007 : Calling OKC_SUBCLASS_PVT.create_subclass_roles ', 2);
       END IF;

       create_subclass_roles(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
          	            x_msg_data       => x_msg_data,
                            p_srev_tbl       => l_srev_tbl,
                            x_srev_tbl       => lx_srev_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1008 : Exit OKC_SUBCLASS_PVT.create_subclass_roles '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
            	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;


		IF sre_relationship_tbl.count > 0 then
  		   FOR i in sre_relationship_tbl.FIRST..sre_relationship_tbl.LAST LOOP
                      sre_relationship_tbl(i).new_sre_id := lx_srev_tbl(i).id;  -- Populating SRE relationship table with new SRE Id.
                   END LOOP;
		END IF;
 END IF;

/* End : Copying Subclass Party Role */

/* Start : Copying Subclass Rule Group   */

    l_srdv_tbl.delete;
    lx_srdv_tbl.delete;
    l_cnt := 0;

 OPEN c_get_scs_rg_defs(p_copy_from_scs_code );
 LOOP

    FETCH c_get_scs_rg_defs INTO l_scs_rg_defs;


    EXIT WHEN c_get_scs_rg_defs%NOTFOUND;
    l_cnt := l_cnt + 1;

    srd_relationship_tbl(l_cnt).old_srd_id :=  l_scs_rg_defs.id;  -- Populating SRD relationship table with existing SRD ID


    l_srdv_tbl(l_cnt).rgd_code :=  l_scs_rg_defs.rgd_code;
    l_srdv_tbl(l_cnt).end_date :=  null;
    l_srdv_tbl(l_cnt).access_level :=  l_scs_rg_defs.access_level;
    l_srdv_tbl(l_cnt).scs_code    := lx_scsv_rec.code;
    l_srdv_tbl(l_cnt).start_date  := trunc(sysdate);

  END LOOP;
  CLOSE c_get_scs_rg_defs;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1009 : Calling OKC_SUBCLASS_PVT.create_subclass_rg_defs ', 2);
       END IF;

       create_subclass_rg_defs(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
          	            x_msg_data       => x_msg_data,
                            p_srdv_tbl       => l_srdv_tbl,
                            x_srdv_tbl       => lx_srdv_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1010 : Exit OKC_SUBCLASS_PVT.create_subclass_rg_defs '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        	   x_return_status := l_return_status;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
            	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;

		IF srd_relationship_tbl.count > 0 then
		    FOR i in srd_relationship_tbl.FIRST..srd_relationship_tbl.LAST LOOP
                         srd_relationship_tbl(i).new_srd_id := lx_srdv_tbl(i).id; -- Populating SRD relationship table with New SRD Id.
		    END LOOP;
		END IF;

 END IF;

/* End : Copying Subclass Rule Group   */


/* Start : Copying Subclass Rule Group Role  */

    l_rrdv_tbl.delete;
    lx_rrdv_tbl.delete;
    l_cnt := 0;

 OPEN c_get_rg_role_defs(p_copy_from_scs_code);
 LOOP

    FETCH c_get_rg_role_defs INTO l_rg_role_defs;


    EXIT WHEN c_get_rg_role_defs%NOTFOUND;
    l_cnt := l_cnt + 1;

    l_rrdv_tbl(l_cnt).srd_id := l_rg_role_defs.srd_id;
    l_rrdv_tbl(l_cnt).sre_id := l_rg_role_defs.sre_id;
    l_rrdv_tbl(l_cnt).subject_object_flag := l_rg_role_defs.subject_object_flag;
    l_rrdv_tbl(l_cnt).optional_yn := l_rg_role_defs.optional_yn;
    l_rrdv_tbl(l_cnt).attribute_category := l_rg_role_defs.attribute_category;
    l_rrdv_tbl(l_cnt).attribute1 := l_rg_role_defs.attribute1;
    l_rrdv_tbl(l_cnt).attribute2 := l_rg_role_defs.attribute2;
    l_rrdv_tbl(l_cnt).attribute3 := l_rg_role_defs.attribute3;
    l_rrdv_tbl(l_cnt).attribute4 := l_rg_role_defs.attribute4;
    l_rrdv_tbl(l_cnt).attribute5 := l_rg_role_defs.attribute5;
    l_rrdv_tbl(l_cnt).attribute6 := l_rg_role_defs.attribute6;
    l_rrdv_tbl(l_cnt).attribute7 := l_rg_role_defs.attribute7;
    l_rrdv_tbl(l_cnt).attribute8 := l_rg_role_defs.attribute8;
    l_rrdv_tbl(l_cnt).attribute9 := l_rg_role_defs.attribute9;
    l_rrdv_tbl(l_cnt).attribute10 := l_rg_role_defs.attribute10;
    l_rrdv_tbl(l_cnt).attribute11 := l_rg_role_defs.attribute11;
    l_rrdv_tbl(l_cnt).attribute12 := l_rg_role_defs.attribute12;
    l_rrdv_tbl(l_cnt).attribute13 := l_rg_role_defs.attribute13;
    l_rrdv_tbl(l_cnt).attribute14 := l_rg_role_defs.attribute14;
    l_rrdv_tbl(l_cnt).attribute15 := l_rg_role_defs.attribute15;
    l_rrdv_tbl(l_cnt).access_level := l_rg_role_defs.access_level;

    l_rrdv_tbl(l_cnt).srd_id     := get_new_srd_id(l_rrdv_tbl(l_cnt).srd_id,srd_relationship_tbl);
    l_rrdv_tbl(l_cnt).sre_id     := get_new_sre_id(l_rrdv_tbl(l_cnt).sre_id,sre_relationship_tbl);


  END LOOP;
  CLOSE c_get_rg_role_defs;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1011 : Calling OKC_SUBCLASS_PVT.create_rg_role_defs ', 2);
       END IF;

       create_rg_role_defs(
              	            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
          	            x_msg_data       => x_msg_data,
                            p_rrdv_tbl       => l_rrdv_tbl,
                            x_rrdv_tbl       => lx_rrdv_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1012 : Exit OKC_SUBCLASS_PVT.create_rg_role_defs '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
            	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;

 END IF;

/* End : Copying Subclass Rule Group Role  */


/* Start : Copying Subclass Top Line Styles  */

    l_stlv_tbl.delete;
    lx_stlv_tbl.delete;
    l_cnt := 0;

 OPEN c_get_subclass_top_line(p_copy_from_scs_code );
 LOOP

    FETCH c_get_subclass_top_line INTO  l_subclass_top_line;

    EXIT WHEN c_get_subclass_top_line%NOTFOUND;
    l_cnt := l_cnt + 1;

    l_stlv_tbl(l_cnt).lse_id := l_subclass_top_line.lse_id;
    l_stlv_tbl(l_cnt).end_date := null;
    l_stlv_tbl(l_cnt).access_level := l_subclass_top_line.access_level;
    l_stlv_tbl(l_cnt).scs_code    := lx_scsv_rec.code;
    l_stlv_tbl(l_cnt).start_date  := trunc(sysdate);

  END LOOP;
  CLOSE c_get_subclass_top_line;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1013 : Calling OKC_SUBCLASS_PVT.create_subclass_top_line ', 2);
       END IF;

       create_subclass_top_line(
              	            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
         	            x_msg_data       => x_msg_data,
                            p_stlv_tbl       => l_stlv_tbl,
                            x_stlv_tbl       => lx_stlv_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1014 : Exit OKC_SUBCLASS_PVT.create_subclass_top_line '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
            	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;

END IF;

/* End : Copying Subclass Top Line Styles  */



/* Start : Copying Subclass Line Style Role */

    l_lsrv_tbl.delete;
    lx_lsrv_tbl.delete;
    l_cnt := 0;

 OPEN c_get_line_style_roles(p_copy_from_scs_code );
 LOOP

    FETCH c_get_line_style_roles INTO  l_line_style_roles;


    EXIT WHEN  c_get_line_style_roles%NOTFOUND;
    l_cnt := l_cnt + 1;

    l_lsrv_tbl(l_cnt).lse_id :=  l_line_style_roles.lse_id;
    l_lsrv_tbl(l_cnt).sre_id :=  l_line_style_roles.sre_id;
    l_lsrv_tbl(l_cnt).access_level :=  l_line_style_roles.access_level;

    l_lsrv_tbl(l_cnt).sre_id     := get_new_sre_id(l_lsrv_tbl(l_cnt).sre_id,sre_relationship_tbl);

  END LOOP;
  CLOSE c_get_line_style_roles;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1015 : Calling OKC_SUBCLASS_PVT.create_line_style_roles ', 2);
       END IF;

       create_line_style_roles(
              	              p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
          	              x_msg_data       => x_msg_data,
                              p_lsrv_tbl       => l_lsrv_tbl,
                              x_lsrv_tbl       => lx_lsrv_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1016 : Exit OKC_SUBCLASS_PVT.create_line_style_roles '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
            	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
       END IF;

END IF;

/* End : Copying Subclass Line Style Role */


/* Start : Copying Subclass Line Style Rule Group*/

    l_lrgv_tbl.delete;
    lx_lrgv_tbl.delete;
    l_cnt := 0;

 OPEN c_get_lse_rule_groups(p_copy_from_scs_code );
 LOOP

    FETCH c_get_lse_rule_groups INTO  l_lse_rule_groups;

    EXIT WHEN  c_get_lse_rule_groups%NOTFOUND;
    l_cnt := l_cnt + 1;

    l_lrgv_tbl(l_cnt).lse_id       := l_lse_rule_groups.lse_id;
    l_lrgv_tbl(l_cnt).srd_id       := l_lse_rule_groups.srd_id;
    l_lrgv_tbl(l_cnt).access_level := l_lse_rule_groups.access_level;

    l_lrgv_tbl(l_cnt).srd_id     := get_new_srd_id(l_lrgv_tbl(l_cnt).srd_id,srd_relationship_tbl);

  END LOOP;
  CLOSE c_get_lse_rule_groups;

  IF l_cnt > 0 Then

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1017 : Calling OKC_SUBCLASS_PVT.create_lse_rule_groups ', 2);
       END IF;

      create_lse_rule_groups(
                              p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
          	              x_msg_data       => x_msg_data,
                              p_lrgv_tbl       => l_lrgv_tbl,
                              x_lrgv_tbl       => lx_lrgv_tbl);

       IF (l_debug = 'Y') THEN
          OKC_DEBUG.log('1018 : Exit OKC_SUBCLASS_PVT.create_lse_rule_groups '||l_return_status, 2);
       END IF;

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           ELSE
            	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;

           END IF;
       END IF;

END IF;

/* End : Copying Subclass Line Style Rule Group*/


/* Start : Copying Subclass Responsibility */

    l_srav_tbl.delete;
    lx_srav_tbl.delete;
    l_cnt :=  0;

 OPEN c_get_subclass_resps(p_copy_from_scs_code );
 LOOP
    FETCH c_get_subclass_resps into l_subclass_resps;


    EXIT WHEN c_get_subclass_resps%NOTFOUND;
    l_cnt := l_cnt+1;

    l_srav_tbl(l_cnt).resp_id := l_subclass_resps.resp_id;
    l_srav_tbl(l_cnt).access_level := l_subclass_resps.access_level;
    l_srav_tbl(l_cnt).end_date := null;
    l_srav_tbl(l_cnt).scs_code := lx_scsv_rec.code;
    l_srav_tbl(l_cnt).start_date := trunc(sysdate);

  END LOOP;
  CLOSE c_get_subclass_resps;

  IF l_cnt > 0 Then

      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('1019 : Calling OKC_SUBCLASS_PVT.create_subclass_resps ', 2);
      END IF;

       create_subclass_resps(
               	          p_api_version    => p_api_version ,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => l_return_status,
                          x_msg_count      => x_msg_count,
          	          x_msg_data       => x_msg_data,
                          p_srav_tbl       => l_srav_tbl,
                          x_srav_tbl       => lx_srav_tbl);

         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('1020 : Exit OKC_SUBCLASS_PVT.create_subclass_resps '||l_return_status, 2);
         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             ELSE
          	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_ERROR;

             END IF;

         END IF;
 END IF;

/* End : Copying Subclass Responsibility */


/* Start : Copying Status and Operation for category */

    l_astv_tbl.delete;
    lx_astv_tbl.delete;
    l_cnt :=  0;

 OPEN c_get_assents(p_copy_from_scs_code);
 LOOP
    FETCH c_get_assents INTO  l_assents;


    EXIT WHEN c_get_assents%NOTFOUND;
    l_cnt := l_cnt+1;

    l_astv_tbl(l_cnt).sts_code := l_assents.sts_code;
    l_astv_tbl(l_cnt).opn_code := l_assents.opn_code;
    l_astv_tbl(l_cnt).ste_code := l_assents.ste_code;
    l_astv_tbl(l_cnt).allowed_yn := l_assents.allowed_yn;
    l_astv_tbl(l_cnt).attribute_category := l_assents.attribute_category;
    l_astv_tbl(l_cnt).attribute1 := l_assents.attribute1;
    l_astv_tbl(l_cnt).attribute2 := l_assents.attribute2;
    l_astv_tbl(l_cnt).attribute3 := l_assents.attribute3;
    l_astv_tbl(l_cnt).attribute4 := l_assents.attribute4;
    l_astv_tbl(l_cnt).attribute5 := l_assents.attribute5;
    l_astv_tbl(l_cnt).attribute6 := l_assents.attribute6;
    l_astv_tbl(l_cnt).attribute7 := l_assents.attribute7;
    l_astv_tbl(l_cnt).attribute8 := l_assents.attribute8;
    l_astv_tbl(l_cnt).attribute9 := l_assents.attribute9;
    l_astv_tbl(l_cnt).attribute10 := l_assents.attribute10;
    l_astv_tbl(l_cnt).attribute11 := l_assents.attribute11;
    l_astv_tbl(l_cnt).attribute12 := l_assents.attribute12;
    l_astv_tbl(l_cnt).attribute13 := l_assents.attribute13;
    l_astv_tbl(l_cnt).attribute14 := l_assents.attribute14;
    l_astv_tbl(l_cnt).attribute15 := l_assents.attribute15;

    l_astv_tbl(l_cnt).scs_code := lx_scsv_rec.code;

  END LOOP;
  CLOSE c_get_assents;

  IF l_cnt > 0 Then

      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('1021 : Calling OKC_ASSENT_PUB.create_assent ', 2);
      END IF;

       OKC_ASSENT_PUB.create_assent(
               	                   p_api_version    => p_api_version ,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => l_return_status,
                                   x_msg_count      => x_msg_count,
          	                   x_msg_data       => x_msg_data,
                                   p_astv_tbl       => l_astv_tbl,
                                   x_astv_tbl       => lx_astv_tbl);

         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('1022 : Exit OKC_SUBCLASS_PVT.create_subclass_resps '||l_return_status, 2);
         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          	   x_return_status := l_return_status;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSE
         	  x_return_status := l_return_status;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF;

END IF;

/* End : Copying Status and Operation for category */

x_return_status := OKC_API.G_RET_STS_SUCCESS;
x_scsv_rec := lx_scsv_rec;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1050 : End OKC_SUBCLASS_PVT.Copy_category......Status '||x_return_status, 2);
END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

IF c_get_sublass%ISOPEN THEN
   CLOSE c_get_sublass;
END IF;

IF c_get_scs_role%ISOPEN THEN
   CLOSE c_get_scs_role;
END IF;

IF c_get_scs_rg_defs%ISOPEN THEN
   CLOSE c_get_scs_rg_defs;
END IF;

IF c_get_rg_role_defs%ISOPEN THEN
   CLOSE c_get_rg_role_defs;
END IF;

IF c_get_subclass_top_line%ISOPEN THEN
   CLOSE c_get_subclass_top_line;
END IF;

IF c_get_line_style_roles%ISOPEN THEN
   CLOSE c_get_line_style_roles;
END IF;

IF c_get_lse_rule_groups%ISOPEN THEN
   CLOSE c_get_lse_rule_groups;
END IF;

IF c_get_subclass_resps%ISOPEN THEN
   CLOSE c_get_subclass_resps;
END IF;

IF c_get_assents%ISOPEN THEN
   CLOSE c_get_assents;
END IF;

x_return_status := FND_API.G_RET_STS_ERROR;
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1050 : End with Error...OKC_SUBCLASS_PVT.Copy_category......Status '||x_return_status, 2);
END IF;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF c_get_sublass%ISOPEN THEN
   CLOSE c_get_sublass;
END IF;

IF c_get_scs_role%ISOPEN THEN
   CLOSE c_get_scs_role;
END IF;

IF c_get_scs_rg_defs%ISOPEN THEN
   CLOSE c_get_scs_rg_defs;
END IF;

IF c_get_rg_role_defs%ISOPEN THEN
   CLOSE c_get_rg_role_defs;
END IF;

IF c_get_subclass_top_line%ISOPEN THEN
   CLOSE c_get_subclass_top_line;
END IF;

IF c_get_line_style_roles%ISOPEN THEN
   CLOSE c_get_line_style_roles;
END IF;

IF c_get_lse_rule_groups%ISOPEN THEN
   CLOSE c_get_lse_rule_groups;
END IF;

IF c_get_subclass_resps%ISOPEN THEN
   CLOSE c_get_subclass_resps;
END IF;

IF c_get_assents%ISOPEN THEN
   CLOSE c_get_assents;
END IF;

x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1050 : End with Unexpected Error...OKC_SUBCLASS_PVT.Copy_category......Status '||x_return_status, 2);
END IF;

END;
END okc_subclass_pvt;

/
