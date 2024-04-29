--------------------------------------------------------
--  DDL for Package PN_REC_ARCL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_ARCL_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRACLHS.pls 115.3 2003/05/23 16:44:13 ftanudja noship $ */

PROCEDURE insert_row(
             x_org_id                 pn_rec_arcl_dtl.org_id%TYPE,
             x_area_class_id          pn_rec_arcl_dtl.area_class_id%TYPE,
             x_area_class_dtl_id      IN OUT NOCOPY pn_rec_arcl_dtl.area_class_dtl_id%TYPE,
             x_as_of_date             pn_rec_arcl_dtl.as_of_date%TYPE,
             x_from_date              pn_rec_arcl_dtl.from_date%TYPE,
             x_to_date                pn_rec_arcl_dtl.to_date%TYPE,
             x_status                 pn_rec_arcl_dtl.status%TYPE,
             x_ttl_assignable_area    pn_rec_arcl_dtl.total_assignable_area%TYPE,
             x_ttl_occupied_area      pn_rec_arcl_dtl.total_occupied_area%TYPE,
             x_ttl_occupied_area_ovr  pn_rec_arcl_dtl.total_occupied_area_ovr%TYPE,
             x_ttl_occupied_area_exc  pn_rec_arcl_dtl.total_occupied_area_exc%TYPE,
             x_ttl_vacant_area        pn_rec_arcl_dtl.total_vacant_area%TYPE,
             x_ttl_vacant_area_ovr    pn_rec_arcl_dtl.total_vacant_area_ovr%TYPE,
             x_ttl_vacant_area_exc    pn_rec_arcl_dtl.total_vacant_area_exc%TYPE,
             x_ttl_weighted_avg       pn_rec_arcl_dtl.total_weighted_avg%TYPE,
             x_ttl_weighted_avg_ovr   pn_rec_arcl_dtl.total_weighted_avg_ovr%TYPE,
             x_ttl_weighted_avg_exc   pn_rec_arcl_dtl.total_weighted_avg_exc%TYPE,
             x_last_update_date       pn_rec_arcl_dtl.last_update_date%TYPE,
             x_last_updated_by        pn_rec_arcl_dtl.last_updated_by%TYPE,
             x_creation_date          pn_rec_arcl_dtl.creation_date%TYPE,
             x_created_by             pn_rec_arcl_dtl.created_by%TYPE,
             x_last_update_login      pn_rec_arcl_dtl.last_update_login%TYPE);


PROCEDURE update_row(
             x_area_class_id          pn_rec_arcl_dtl.area_class_id%TYPE,
             x_area_class_dtl_id      pn_rec_arcl_dtl.area_class_dtl_id%TYPE,
             x_as_of_date             pn_rec_arcl_dtl.as_of_date%TYPE,
             x_from_date              pn_rec_arcl_dtl.from_date%TYPE,
             x_to_date                pn_rec_arcl_dtl.to_date%TYPE,
             x_status                 pn_rec_arcl_dtl.status%TYPE,
             x_ttl_assignable_area    pn_rec_arcl_dtl.total_assignable_area%TYPE,
             x_ttl_occupied_area      pn_rec_arcl_dtl.total_occupied_area%TYPE,
             x_ttl_occupied_area_ovr  pn_rec_arcl_dtl.total_occupied_area_ovr%TYPE,
             x_ttl_occupied_area_exc  pn_rec_arcl_dtl.total_occupied_area_exc%TYPE,
             x_ttl_vacant_area        pn_rec_arcl_dtl.total_vacant_area%TYPE,
             x_ttl_vacant_area_ovr    pn_rec_arcl_dtl.total_vacant_area_ovr%TYPE,
             x_ttl_vacant_area_exc    pn_rec_arcl_dtl.total_vacant_area_exc%TYPE,
             x_ttl_weighted_avg       pn_rec_arcl_dtl.total_weighted_avg%TYPE,
             x_ttl_weighted_avg_ovr   pn_rec_arcl_dtl.total_weighted_avg_ovr%TYPE,
             x_ttl_weighted_avg_exc   pn_rec_arcl_dtl.total_weighted_avg_exc%TYPE,
             x_last_update_date       pn_rec_arcl_dtl.last_update_date%TYPE,
             x_last_updated_by        pn_rec_arcl_dtl.last_updated_by%TYPE,
             x_creation_date          pn_rec_arcl_dtl.creation_date%TYPE,
             x_created_by             pn_rec_arcl_dtl.created_by%TYPE,
             x_last_update_login      pn_rec_arcl_dtl.last_update_login%TYPE
       );

PROCEDURE delete_row(x_area_class_dtl_id    pn_rec_arcl_dtl.area_class_dtl_id%TYPE);

END pn_rec_arcl_dtl_pkg;

 

/
