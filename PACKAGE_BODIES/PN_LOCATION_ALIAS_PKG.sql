--------------------------------------------------------
--  DDL for Package Body PN_LOCATION_ALIAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LOCATION_ALIAS_PKG" AS
/* $Header: PNLCALSB.pls 120.2.12010000.2 2008/11/27 04:24:49 rthumma ship $ */

TYPE id_tbl IS TABLE OF pn_locations.location_id%TYPE INDEX BY BINARY_INTEGER;
TYPE code_tbl IS TABLE OF pn_locations.location_code%TYPE INDEX BY BINARY_INTEGER;
TYPE alias_tbl IS TABLE OF pn_locations.location_alias%TYPE INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------+
-- FUNCTION   : get_parent_location_code
--
-- DESCRIPTION:
-- 1. Finds location code from p_cd_tbl given a location id that matches.
--
-- HISTORY:
-- 18-JUN-03 ftanudja o created.
-- 20-JUN-03 ftanudja o rewrote to avoid loc separator impact.
------------------------------------------------------------------------------+

FUNCTION get_parent_location_code(
            p_cd_tbl    IN code_tbl,
            p_id_tbl    IN id_tbl,
            p_loc_id    IN pn_locations.location_id%TYPE) RETURN VARCHAR2
IS
   l_info        VARCHAR2(300);
   l_desc        VARCHAR2(300) := 'pn_location_alias_pkg.get_parent_location_code';
   l_result      pn_locations.location_code%TYPE := '';
BEGIN
   pnp_debug_pkg.debug(l_desc ||' (+)');

   l_info := 'starting loop ';
   FOR i IN REVERSE 0 .. p_id_tbl.COUNT - 1 LOOP
      IF p_id_tbl(i) = p_loc_id THEN
         l_result := p_cd_tbl(i);
         exit;
      END IF;
   END LOOP;

   RETURN l_result;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END get_parent_location_code;

------------------------------------------------------------------------------+
-- PROCEDURE  : change_alias
-- DESCRIPTION: main extraction program for changing location code alias names
-- 1. Given : some location code and a new alias.
-- 2. Change alias and loc code for that location as well as its descendants.
--
-- HISTORY:
-- 18-JUN-03 ftanudja o created.
-- 20-JUN-03 ftanudja o rewrote to avoid loc separator impact.
-- 09-OCT-06 acprakas o Bug#5571818 - Changed Cursor definition for impacted_loc
--                      to pick up the locations of specified type.
--                      Added check to see whether any location already exists
--                      having the specified location code.
-- 27-Nov-08 rthumma  o Bug 6735518 : Modified cursor impacted_loc and 'Update'
--                      statement. Changes are tagged with bug number.
------------------------------------------------------------------------------+

PROCEDURE change_alias(
            errbuf           OUT NOCOPY VARCHAR2,
            retcode          OUT NOCOPY VARCHAR2,
            p_location_type  IN pn_locations.location_type_lookup_code%TYPE,
            p_location_code  IN pn_locations.location_code%TYPE,
            p_new_alias      IN pn_locations.location_alias%TYPE)
IS
   CURSOR impacted_loc IS
    SELECT location_id,
           parent_location_id,
           location_code,
           location_alias
    FROM pn_locations_all           /*sdm14jul*/
    WHERE NVL(TRUNC(ACTIVE_END_DATE), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)  /* Bug 6735518 */
    START WITH location_id =  (SELECT location_id FROM
                              (SELECT location_id
                               FROM pn_locations_all
                               WHERE location_type_lookup_code = p_location_type
                               AND location_code = p_location_code
                               ORDER BY ACTIVE_START_DATE DESC)
                               WHERE ROWNUM = 1)                 /* Bug 6735518 */
    CONNECT BY PRIOR location_id = parent_location_id
    ORDER BY 3;

   loc_id_tbl    id_tbl;
   als_nm_tbl    alias_tbl;
   old_cd_tbl    code_tbl;
   new_cd_tbl    code_tbl;

   l_info        VARCHAR2(300);
   l_desc        VARCHAR2(300) := 'pn_location_alias_pkg.change_alias';
   l_count       NUMBER;
   l_uniq_loc_count NUMBER := 0; --Bug#5571818
   INVALID_LOC_CODE EXCEPTION; --Bug#5571818

BEGIN
   pnp_debug_pkg.debug(l_desc ||' (+)');

   l_info := 'initializing pl/sql tables ';
   loc_id_tbl.delete;
   als_nm_tbl.delete;
   old_cd_tbl.delete;
   new_cd_tbl.delete;

   l_info := 'checking location code uniqueness';

   --Bug#5571818
   SELECT COUNT(1)
   INTO   l_uniq_loc_count
   FROM   pn_locations_all
   WHERE  location_code = p_new_alias;

   IF l_uniq_loc_count <> 0 THEN
   raise INVALID_LOC_CODE;
   END IF;

   l_info := 'fetching information ';
   FOR init_tbl_cur IN impacted_loc LOOP

      l_count := loc_id_tbl.COUNT;
      loc_id_tbl(l_count) := init_tbl_cur.location_id;
      old_cd_tbl(l_count) := init_tbl_cur.location_code;

      IF init_tbl_cur.location_code = p_location_code THEN
         als_nm_tbl(l_count)   := p_new_alias;
         new_cd_tbl(l_count)   := SUBSTR(init_tbl_cur.location_code, 1,
                                  LENGTH(init_tbl_cur.location_code) -
                                  LENGTH(init_tbl_cur.location_alias))
                                  || p_new_alias;

      ELSE
         als_nm_tbl(l_count) := init_tbl_cur.location_alias;
         new_cd_tbl(l_count) := get_parent_location_code(
                                    p_cd_tbl => new_cd_tbl,
                                    p_id_tbl => loc_id_tbl,
                                    p_loc_id => init_tbl_cur.parent_location_id) ||
                                 SUBSTR(init_tbl_cur.location_code,
                                 LENGTH(get_parent_location_code(
                                           p_cd_tbl => old_cd_tbl,
                                           p_id_tbl => loc_id_tbl,
                                           p_loc_id => init_tbl_cur.parent_location_id)) + 1,
                                 LENGTH(init_tbl_cur.location_code));
      END IF;

   END LOOP;

   l_info := 'updating table with new values ';
   FORALL i IN 0 ..  loc_id_tbl.COUNT - 1
      UPDATE pn_locations_all                   /*sdm14jul*/
         SET location_code = new_cd_tbl(i),
             location_alias = als_nm_tbl(i),
             last_update_date = SYSDATE,
             last_updated_by = nvl(fnd_profile.value('USER_ID'), -1),
             last_update_login = nvl(fnd_profile.value('USER_ID'), -1)
       WHERE location_id = loc_id_tbl(i)
       AND NVL(TRUNC(ACTIVE_END_DATE), TRUNC(SYSDATE)) >= TRUNC(SYSDATE);  /* Bug 6735518 */

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
  --Bug#5571818
  WHEN INVALID_LOC_CODE THEN
       fnd_message.set_name ('PN','PN_LOCN_TYPE_CODE_DUP');
       pnp_debug_pkg.put_log_msg(fnd_message.get);
       raise;
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END change_alias;

END pn_location_alias_pkg;

/
