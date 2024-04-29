--------------------------------------------------------
--  DDL for Package Body PN_LOC_STATUS_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LOC_STATUS_CHANGE_PKG" AS
  -- $Header: PNLOCSTB.pls 120.1 2005/07/25 06:43:12 appldev noship $

--------------------------------------------------------------------------------------------
--  CURSOR     : ACTDEACT_MAIN_CUR
--  DESCRIPTION: This cursor fetches Building/Floor Location information for all the
--               Building/Floor being Activated/De-activated FROM and TO Location Code.
--  NOTE       :
--  24-APR-2002  Satish Tripathi o Created.
--  22-JAN-2004  ftanudja        o Added act stdt in csr select. 3359371.
--------------------------------------------------------------------------------------------
   CURSOR actdeact_main_cur (p_loc_type       VARCHAR2,
                             p_loc_code_low   VARCHAR2,
                             p_loc_code_high  VARCHAR2)
   IS
      SELECT loc.ROWID row_id,
             loc.location_id,
             loc.active_start_date,
             loc.last_update_date,
             loc.last_updated_by,
             loc.creation_date,
             loc.created_by,
             loc.last_update_login,
             loc.location_park_id,
             loc.location_type_lookup_code,
             loc.location_code,
             loc.location_alias,
             loc.building,
             loc.lease_or_owned,
             loc.floor,
             loc.office,
             loc.address_id,
             loc.max_capacity,
             loc.optimum_capacity,
             loc.rentable_area,
             loc.usable_area,
             loc.allocate_cost_center_code,
             loc.uom_code,
             loc.description,
             loc.parent_location_id,
             loc.interface_flag,
             loc.request_id,
             loc.program_application_id,
             loc.program_id,
             loc.program_update_date,
             loc.status,
             loc.space_type_lookup_code,
             loc.attribute_category,
             loc.attribute1,
             loc.attribute2,
             loc.attribute3,
             loc.attribute4,
             loc.attribute5,
             loc.attribute6,
             loc.attribute7,
             loc.attribute8,
             loc.attribute9,
             loc.attribute10,
             loc.attribute11,
             loc.attribute12,
             loc.attribute13,
             loc.attribute14,
             loc.attribute15,
             loc.source,
             loc.property_id,
             loc.class,
             loc.status_type,
             loc.suite,
             loc.gross_area,
             loc.assignable_area,
             loc.common_area,
             loc.common_area_flag,
             loc.function_type_lookup_code,
             loc.standard_type_lookup_code
      FROM   pn_locations loc                                                           /*sdm?? Location Code lies in a range*/
      WHERE  loc.location_type_lookup_code = p_loc_type
      AND    loc.location_code BETWEEN p_loc_code_low and p_loc_code_high;


--------------------------------------------------------------------------------------------
--  CURSOR     : CHILD_LOC_CUR
--  DESCRIPTION: This cursor fetches Child Location information for a Parent Location Id.
--  24-APR-2002  Satish Tripathi o Created.
--------------------------------------------------------------------------------------------
   CURSOR child_loc_cur (p_location_id   VARCHAR2)
   IS
      SELECT cld.ROWID row_id,
             cld.location_id,
             cld.last_update_date,
             cld.last_updated_by,
             cld.creation_date,
             cld.created_by,
             cld.last_update_login,
             cld.location_park_id,
             cld.location_type_lookup_code,
             cld.location_code,
             cld.location_alias,
             cld.building,
             cld.lease_or_owned,
             cld.floor,
             cld.office,
             cld.address_id,
             cld.max_capacity,
             cld.optimum_capacity,
             cld.rentable_area,
             cld.usable_area,
             cld.allocate_cost_center_code,
             cld.uom_code,
             cld.description,
             cld.parent_location_id,
             cld.interface_flag,
             cld.request_id,
             cld.program_application_id,
             cld.program_id,
             cld.program_update_date,
             cld.status,
             cld.space_type_lookup_code,
             cld.attribute_category,
             cld.attribute1,
             cld.attribute2,
             cld.attribute3,
             cld.attribute4,
             cld.attribute5,
             cld.attribute6,
             cld.attribute7,
             cld.attribute8,
             cld.attribute9,
             cld.attribute10,
             cld.attribute11,
             cld.attribute12,
             cld.attribute13,
             cld.attribute14,
             cld.attribute15,
             cld.source,
             cld.property_id,
             cld.class,
             cld.status_type,
             cld.suite,
             cld.gross_area,
             cld.assignable_area,
             cld.common_area,
             cld.common_area_flag,
             cld.function_type_lookup_code,
             cld.standard_type_lookup_code
      FROM   pn_locations_all cld                                       /*sdm14jul*/
      WHERE  cld.location_id <> p_location_id
      AND    cld.location_id IN (SELECT location_id
                                 FROM   pn_locations_all                /*sdm14jul*/
                                 START WITH location_id = p_location_id
                                 CONNECT BY PRIOR location_id = parent_location_id
                                );


--------------------------------------------------------------------------------------------
--  PROCEDURE  : ACTIVATE_DEACT_LOCATION
--  DESCRIPTION: This is the MAIN procedure in this Package.
--               It's referenced in the Concurrent Program executable definition - PNLOCACT
--               It calls all the other procedures/functions in this Package.
--  Args:
--   errbuf:           Needed for all PL/SQL Concurrent Programs
--   retcode:          Needed for all PL/SQL Concurrent Programs
--   p_action:         Operation/Action type (one of ACTIVATE, DEACTIVATE)
--   p_loc_type:       Location Type (one of BUILDING. FLOOR).
--   p_loc_code_low:   Activate/De-activate Location FROM Location Code.
--   p_loc_code_high:  Activate/De-activate Location TO Location Code.
--
--  24-APR-2002  Satish Tripathi  o Created.
--  04-JUN-2002  Kiran Hegde      o Fix for Bug#2390805.
--                                  Removed the comments parameter.
--------------------------------------------------------------------------------------------
PROCEDURE activate_deact_location (
                             errbuf                         OUT NOCOPY VARCHAR2
                            ,retcode                        OUT NOCOPY VARCHAR2
                            ,p_action                           VARCHAR2
                            ,p_loc_type                         VARCHAR2
                            ,p_loc_code_low                     VARCHAR2
                            ,p_loc_code_high                    VARCHAR2
                            )
IS

   l_loc_status                   VARCHAR2(1) := NULL;
   l_loc_active_status            VARCHAR2(1) := 'N';
   l_loc                          VARCHAR2(100);
   l_err_code                     VARCHAR2(256);
   l_rowcount                     NUMBER;

BEGIN

   pnp_debug_pkg.put_log_msg('+---------------------------------------------------------------------------+');
   pnp_debug_pkg.log('Activate_DeAct_Location : -Start- (+)');
   pnp_debug_pkg.log('Action              : '||p_action);
   pnp_debug_pkg.log('Location Type       : '||p_loc_type);
   pnp_debug_pkg.log('Location Code Low   : '||p_loc_code_low);
   pnp_debug_pkg.log('Location Code High  : '||p_loc_code_high);

   -- Check Valid P_ACTION.
   IF p_action IN ('ACTIVATE', 'DEACTIVATE') THEN

      IF p_action = 'ACTIVATE' THEN
         l_loc_status := 'A';
      ELSIF p_action = 'DEACTIVATE' THEN
         l_loc_status := 'I';
      END IF;

      -- Start Main Loc Loop
      FOR actdeact_main IN actdeact_main_cur(p_loc_type       => p_loc_type,
                                             p_loc_code_low   => p_loc_code_low,
                                             p_loc_code_high  => p_loc_code_high)
      LOOP

         l_rowcount := 0;
         l_loc_active_status := 'N';
         l_loc := actdeact_main.location_code||' ('||actdeact_main.location_type_Lookup_code||')';
         pnp_debug_pkg.log(p_action||' Main Location: '||l_loc||' (+)');

         -- Check Main Loc has Active assignments.
         IF p_action = 'DEACTIVATE' AND
            (pnp_util_func.get_space_assigned_status(actdeact_main.location_id, actdeact_main.active_start_date)) THEN

            --If Active Assignment found, can't De-activate Bldg.
            l_loc_active_status := 'Y';

         ELSE

            -- Child Loc Loop
            FOR child_loc IN child_loc_cur(actdeact_main.location_id)
            LOOP

               -- Activate/De-Activate Child Loc
               IF child_loc.status <> l_loc_status THEN
                  UPDATE pn_locations_all
                  SET    status = l_loc_status
                  WHERE  ROWID = child_loc.row_id;              /*sdm14jul*/
                  l_rowcount := l_rowcount + 1;
               END IF;

            END LOOP; -- End Child Loc Loop

         END IF; -- End Check Main Loc has Active assignments.

         -- Activate/De-Activate Bldg
         IF l_loc_active_status = 'Y' THEN

            fnd_message.set_name ('PN','PN_LOCST_MAIN');
            fnd_message.set_token ('LOC_CODE', l_loc);
            pnp_debug_pkg.put_log_msg(fnd_message.get);


         ELSE
            IF actdeact_main.status <> l_loc_status THEN
               UPDATE pn_locations_all                          /*sdm14jul*/
               SET    status = l_loc_status
               WHERE  ROWID = actdeact_main.row_id;
               l_rowcount := l_rowcount + 1;
            END IF;

            fnd_message.set_name ('PN','PN_LOCST_PROC_ROWS ');
            fnd_message.set_token ('ACTION', p_action);
            fnd_message.set_token ('NUM', l_rowcount);
            fnd_message.set_token ('LOC_CODE', l_loc);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

         END IF; -- End Activate/De-Activate Bldg

         pnp_debug_pkg.log(p_action||' Main Location: '||l_loc||' (-)');

      END LOOP; -- End Main Loc Loop

   ELSE
      pnp_debug_pkg.log('Error, Invalid Action passed: '||p_action);

   END IF; -- End Check Valid P_ACTION.

   pnp_debug_pkg.log('Activate_DeAct_Location : -End- (-)');
   pnp_debug_pkg.put_log_msg('+---------------------------------------------------------------------------+');

EXCEPTION

   WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      Retcode := 2;
      ROLLBACK;
      RAISE;

END activate_deact_location;

---------------------------------------------------------------------------------------
-- End of Pkg
---------------------------------------------------------------------------------------
END pn_loc_status_change_pkg;

/
