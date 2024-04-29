--------------------------------------------------------
--  DDL for Package Body PN_REC_ARCL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_ARCL_DTL_PKG" AS
/* $Header: PNRACLHB.pls 120.2 2005/11/30 23:30:33 appldev noship $ */


-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
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
             x_last_update_login      pn_rec_arcl_dtl.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtl_pkg.insert_row';

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_arcl_all
    WHERE area_class_id = x_area_class_id;

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

   INSERT INTO pn_rec_arcl_dtl_all
   (
      org_id,
      area_class_id,
      area_class_dtl_id,
      as_of_date,
      from_date,
      to_date,
      status,
      total_assignable_area,
      total_occupied_area,
      total_occupied_area_ovr,
      total_occupied_area_exc,
      total_vacant_area,
      total_vacant_area_ovr,
      total_vacant_area_exc,
      total_weighted_avg,
      total_weighted_avg_ovr,
      total_weighted_avg_exc,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login)
   VALUES(
      l_org_id,
      x_area_class_id,
      pn_rec_arcl_dtl_s.nextval,
      x_as_of_date,
      x_from_date,
      x_to_date,
      x_status,
      x_ttl_assignable_area,
      x_ttl_occupied_area,
      x_ttl_occupied_area_ovr,
      x_ttl_occupied_area_exc,
      x_ttl_vacant_area,
      x_ttl_vacant_area_ovr,
      x_ttl_vacant_area_exc,
      x_ttl_weighted_avg,
      x_ttl_weighted_avg_ovr,
      x_ttl_weighted_avg_exc,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login)
   RETURNING area_class_dtl_id INTO x_area_class_dtl_id;

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
             x_last_update_login      pn_rec_arcl_dtl.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtl_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_arcl_dtl_all
   SET
      area_class_id                    = x_area_class_id,
      as_of_date                       = x_as_of_date,
      from_date                        = x_from_date,
      to_date                          = x_to_date,
      status                           = x_status,
      total_assignable_area            = x_ttl_assignable_area,
      total_occupied_area              = x_ttl_occupied_area,
      total_occupied_area_ovr          = x_ttl_occupied_area_ovr,
      total_occupied_area_exc          = x_ttl_occupied_area_exc,
      total_vacant_area                = x_ttl_vacant_area,
      total_vacant_area_ovr            = x_ttl_vacant_area_ovr,
      total_vacant_area_exc            = x_ttl_vacant_area_exc,
      total_weighted_avg               = x_ttl_weighted_avg,
      total_weighted_avg_ovr           = x_ttl_weighted_avg_ovr,
      total_weighted_avg_exc           = x_ttl_weighted_avg_exc,
      last_update_date                 = x_last_update_date,
      last_updated_by                  = x_last_updated_by,
      creation_date                    = x_creation_date,
      created_by                       = x_created_by,
      last_update_login                = x_last_update_login
   WHERE area_class_dtl_id             = x_area_class_dtl_id;

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
PROCEDURE delete_row(x_area_class_dtl_id    pn_rec_arcl_dtl.area_class_dtl_id%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_arcl_dtl_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_arcl_dtl_all
   WHERE  area_class_dtl_id = x_area_class_dtl_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END delete_row;

END pn_rec_arcl_dtl_pkg;

/
