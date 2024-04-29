--------------------------------------------------------
--  DDL for Package PN_REC_ARCL_DTLLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_ARCL_DTLLN_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRACLDS.pls 115.4 2003/06/13 02:01:44 ftanudja noship $ */

PROCEDURE insert_row(
             x_org_id                  pn_rec_arcl_dtlln.org_id%TYPE,
             x_area_class_dtl_id       pn_rec_arcl_dtlln.area_class_dtl_id%TYPE,
             x_area_class_dtl_line_id  IN OUT NOCOPY pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE,
             x_from_date               pn_rec_arcl_dtlln.from_date%TYPE,
             x_to_date                 pn_rec_arcl_dtlln.to_date%TYPE,
             x_location_id             pn_rec_arcl_dtlln.location_id%TYPE,
             x_property_id             pn_rec_arcl_dtlln.property_id%TYPE,
             x_cust_space_assign_id    pn_rec_arcl_dtlln.cust_space_assign_id%TYPE,
             x_cust_account_id         pn_rec_arcl_dtlln.cust_space_assign_id%TYPE,
             x_lease_id                pn_rec_arcl_dtlln.lease_id%TYPE,
             x_assignable_area         pn_rec_arcl_dtlln.assignable_area%TYPE,
             x_assigned_area           pn_rec_arcl_dtlln.assigned_area%TYPE,
             x_assigned_area_ovr       pn_rec_arcl_dtlln.assigned_area_ovr%TYPE,
             x_occupancy_pct           pn_rec_arcl_dtlln.occupancy_pct%TYPE,
             x_occupied_area           pn_rec_arcl_dtlln.occupied_area%TYPE,
             x_occupied_area_ovr       pn_rec_arcl_dtlln.occupied_area_ovr%TYPE,
             x_vacant_area             pn_rec_arcl_dtlln.vacant_area%TYPE,
             x_vacant_area_ovr         pn_rec_arcl_dtlln.vacant_area_ovr%TYPE,
             x_weighted_avg            pn_rec_arcl_dtlln.weighted_avg%TYPE,
             x_weighted_avg_ovr        pn_rec_arcl_dtlln.weighted_avg_ovr%TYPE,
             x_exclude_area_flag       pn_rec_arcl_dtlln.exclude_area_flag%TYPE,
             x_exclude_area_ovr_flag   pn_rec_arcl_dtlln.exclude_area_ovr_flag%TYPE,
             x_exclude_prorata_flag    pn_rec_arcl_dtlln.exclude_prorata_flag%TYPE,
             x_exclude_prorata_ovr_flag pn_rec_arcl_dtlln.exclude_prorata_ovr_flag%TYPE,
             x_include_flag            pn_rec_arcl_dtlln.include_flag%TYPE,
             x_recovery_space_std_code pn_rec_arcl_dtlln.recovery_space_std_code%TYPE,
             x_recovery_type_code      pn_rec_arcl_dtlln.recovery_type_code%TYPE,
             x_last_update_date        pn_rec_arcl_dtlln.last_update_date%TYPE,
             x_last_updated_by         pn_rec_arcl_dtlln.last_updated_by%TYPE,
             x_creation_date           pn_rec_arcl_dtlln.creation_date%TYPE,
             x_created_by              pn_rec_arcl_dtlln.created_by%TYPE,
             x_last_update_login       pn_rec_arcl_dtlln.last_update_login%TYPE);

PROCEDURE update_row(
             x_area_class_dtl_line_id  pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE,
             x_from_date               pn_rec_arcl_dtlln.from_date%TYPE,
             x_to_date                 pn_rec_arcl_dtlln.to_date%TYPE,
             x_location_id             pn_rec_arcl_dtlln.location_id%TYPE,
             x_property_id             pn_rec_arcl_dtlln.property_id%TYPE,
             x_cust_space_assign_id    pn_rec_arcl_dtlln.cust_space_assign_id%TYPE,
             x_cust_account_id         pn_rec_arcl_dtlln.cust_space_assign_id%TYPE,
             x_lease_id                pn_rec_arcl_dtlln.lease_id%TYPE,
             x_assignable_area         pn_rec_arcl_dtlln.assignable_area%TYPE,
             x_assigned_area           pn_rec_arcl_dtlln.assigned_area%TYPE,
             x_assigned_area_ovr     pn_rec_arcl_dtlln.assigned_area_ovr%TYPE,
             x_occupancy_pct           pn_rec_arcl_dtlln.occupancy_pct%TYPE,
             x_occupied_area           pn_rec_arcl_dtlln.occupied_area%TYPE,
             x_occupied_area_ovr       pn_rec_arcl_dtlln.occupied_area_ovr%TYPE,
             x_vacant_area             pn_rec_arcl_dtlln.vacant_area%TYPE,
             x_vacant_area_ovr         pn_rec_arcl_dtlln.vacant_area_ovr%TYPE,
             x_weighted_avg            pn_rec_arcl_dtlln.weighted_avg%TYPE,
             x_weighted_avg_ovr        pn_rec_arcl_dtlln.weighted_avg_ovr%TYPE,
             x_exclude_area_flag       pn_rec_arcl_dtlln.exclude_area_flag%TYPE,
             x_exclude_area_ovr_flag   pn_rec_arcl_dtlln.exclude_area_ovr_flag%TYPE,
             x_exclude_prorata_flag    pn_rec_arcl_dtlln.exclude_prorata_flag%TYPE,
             x_exclude_prorata_ovr_flag pn_rec_arcl_dtlln.exclude_prorata_ovr_flag%TYPE,
             x_include_flag            pn_rec_arcl_dtlln.include_flag%TYPE,
             x_recovery_space_std_code pn_rec_arcl_dtlln.recovery_space_std_code%TYPE,
             x_recovery_type_code      pn_rec_arcl_dtlln.recovery_type_code%TYPE,
             x_last_update_date        pn_rec_arcl_dtlln.last_update_date%TYPE,
             x_last_updated_by         pn_rec_arcl_dtlln.last_updated_by%TYPE,
             x_creation_date           pn_rec_arcl_dtlln.creation_date%TYPE,
             x_created_by              pn_rec_arcl_dtlln.created_by%TYPE,
             x_last_update_login       pn_rec_arcl_dtlln.last_update_login%TYPE);

PROCEDURE delete_row(x_area_class_dtl_line_id    pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE);

END pn_rec_arcl_dtlln_pkg;

 

/
