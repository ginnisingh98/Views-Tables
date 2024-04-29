--------------------------------------------------------
--  DDL for Package Body PN_REC_ARCL_DTLLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_ARCL_DTLLN_PKG" AS
/* $Header: PNRACLDB.pls 120.2 2005/11/30 23:29:12 appldev noship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
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
             x_last_update_login       pn_rec_arcl_dtlln.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtlln_pkg.insert_row';

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_arcl_dtl_all
    WHERE area_class_dtl_id = x_area_class_dtl_id ;

    l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_rec_arcl_dtlln_all
   (
      org_id,
      area_class_dtl_id,
      area_class_dtl_line_id,
      from_date,
      to_date,
      location_id,
      property_id,
      cust_space_assign_id,
      cust_account_id,
      lease_id,
      assignable_area,
      assigned_area,
      assigned_area_ovr,
      occupancy_pct,
      occupied_area,
      occupied_area_ovr,
      vacant_area,
      vacant_area_ovr,
      weighted_avg,
      weighted_avg_ovr,
      exclude_area_flag,
      exclude_area_ovr_flag,
      exclude_prorata_flag,
      exclude_prorata_ovr_flag,
      include_flag,
      recovery_space_std_code,
      recovery_type_code,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )VALUES
   (
      l_org_id,
      x_area_class_dtl_id,
      pn_rec_arcl_dtlln_s.nextval,
      x_from_date,
      x_to_date,
      x_location_id,
      x_property_id,
      x_cust_space_assign_id,
      x_cust_account_id,
      x_lease_id,
      x_assignable_area,
      x_assigned_area,
      x_assigned_area_ovr,
      x_occupancy_pct,
      x_occupied_area,
      x_occupied_area_ovr,
      x_vacant_area,
      x_vacant_area_ovr,
      x_weighted_avg,
      x_weighted_avg_ovr,
      x_exclude_area_flag,
      x_exclude_area_ovr_flag,
      x_exclude_prorata_flag,
      x_exclude_prorata_ovr_flag,
      x_include_flag,
      x_recovery_space_std_code,
      x_recovery_type_code,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
    )RETURNING area_class_dtl_line_id INTO x_area_class_dtl_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END insert_row;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-------------------------------------------------------------------------------
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
             x_last_update_login       pn_rec_arcl_dtlln.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtlln_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_arcl_dtlln_all
   SET
      from_date                        = x_from_date,
      to_date                          = x_to_date,
      location_id                      = x_location_id,
      property_id                      = x_property_id,
      cust_space_assign_id             = x_cust_space_assign_id,
      cust_account_id                  = x_cust_account_id,
      assignable_area                  = x_assignable_area,
      assigned_area                    = x_assigned_area,
      assigned_area_ovr                = x_assigned_area_ovr,
      occupancy_pct                    = x_occupancy_pct,
      occupied_area                    = x_occupied_area,
      occupied_area_ovr                = x_occupied_area_ovr,
      vacant_area                      = x_vacant_area,
      vacant_area_ovr                  = x_vacant_area_ovr,
      weighted_avg                     = x_weighted_avg,
      weighted_avg_ovr                 = x_weighted_avg_ovr,
      exclude_area_flag                = x_exclude_area_flag,
      exclude_area_ovr_flag            = x_exclude_area_ovr_flag,
      exclude_prorata_flag             = x_exclude_prorata_flag,
      exclude_prorata_ovr_flag         = x_exclude_prorata_ovr_flag,
      include_flag                     = x_include_flag,
      recovery_space_std_code          = x_recovery_space_std_code,
      recovery_type_code               = x_recovery_type_code,
      last_update_date                 = x_last_update_date,
      last_updated_by                  = x_last_updated_by,
      creation_date                    = x_creation_date,
      created_by                       = x_created_by,
      last_update_login                = x_last_update_login
   WHERE area_class_dtl_line_id        = x_area_class_dtl_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END update_row;


-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row(x_area_class_dtl_line_id    pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtlln_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_arcl_dtlln_all
   WHERE  area_class_dtl_line_id = x_area_class_dtl_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END delete_row;

END pn_rec_arcl_dtlln_pkg;

/
