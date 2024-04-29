--------------------------------------------------------
--  DDL for Package Body PN_VAR_UPG_VOL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_UPG_VOL_PKG" AS
-- $Header: PNUPGVOB.pls 120.0.12010000.1 2009/10/19 07:07:59 rrambati noship $

--------------------------------------------------------------------------------
--
--  NAME         : vr_update_volume_status
--  DESCRIPTION  : Main procedure called from Upgrade of VR agreements
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  07-AUG-2007  pikhar o Created
--------------------------------------------------------------------------------
PROCEDURE vr_update_volume_status ( errbuf                OUT NOCOPY  VARCHAR2,
                                     retcode               OUT NOCOPY  VARCHAR2,
                                     p_property_code       IN  VARCHAR2,
                                     p_property_name       IN  VARCHAR2,
                                     p_location_code_from  IN  VARCHAR2,
                                     p_location_code_to    IN  VARCHAR2,
                                     p_lease_num_from      IN  VARCHAR2,
                                     p_lease_num_to        IN  VARCHAR2,
                                     p_vrent_num_from      IN  VARCHAR2,
                                     p_vrent_num_to        IN  VARCHAR2)

IS

CURSOR csr_get_vrent_wprop IS
SELECT pvr.var_rent_id
FROM   pn_leases            pl,
       pn_var_rents_all      pvr,
       pn_locations_all      ploc
WHERE  pl.lease_id = pvr.lease_id
AND    ploc.location_id = pvr.location_id
AND    ploc.location_id IN (SELECT location_id
                             FROM  pn_locations_all
                           START WITH location_id
                                              IN
                                                (SELECT location_id
                                                   FROM pn_locations_all
                                                  WHERE property_id IN(SELECT property_id
                                                                       FROM pn_properties_all
                                                                      WHERE property_code=NVL(p_property_code,property_code)
                                                                        AND property_name=NVL(p_property_name,property_name))
                                                )
                          CONNECT BY PRIOR location_id=parent_location_id)
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    ploc.location_code >= NVL(p_location_code_from, ploc.location_code)
AND    ploc.location_code <= NVL(p_location_code_to, ploc.location_code)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_vrent_wloc IS
SELECT pvr.var_rent_id
FROM   pn_leases           pl,
       pn_var_rents_all      pvr,
       pn_locations_all      ploc
WHERE  pl.lease_id = pvr.lease_id
AND    ploc.location_id = pvr.location_id
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    ploc.location_code >= NVL(p_location_code_from, ploc.location_code)
AND    ploc.location_code <= NVL(p_location_code_to, ploc.location_code)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_vrent_woloc IS
SELECT pvr.var_rent_id
FROM   pn_var_rents_all      pvr,
       pn_leases_all         pl
WHERE  pl.lease_id = pvr.lease_id
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
ORDER BY pl.lease_id, pvr.var_rent_id;


l_var_rent_id NUMBER;

BEGIN

  pnp_debug_pkg.log
  ('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  pnp_debug_pkg.log('+++++++++ vr_upgrade_batch_process START +++++++++++');
  pnp_debug_pkg.log(' ');
  pnp_debug_pkg.log('p_property_code     '||p_property_code      );
  pnp_debug_pkg.log('p_property_name     '||p_property_name      );
  pnp_debug_pkg.log('p_lease_num_from    '||p_lease_num_from     );
  pnp_debug_pkg.log('p_lease_num_to      '||p_lease_num_to       );
  pnp_debug_pkg.log('p_location_code_from'||p_location_code_from );
  pnp_debug_pkg.log('p_location_code_to  '||p_location_code_to   );
  pnp_debug_pkg.log('p_vrent_num_from    '||p_vrent_num_from     );
  pnp_debug_pkg.log('p_vrent_num_to      '||p_vrent_num_to       );

  IF p_property_code IS NOT NULL OR p_property_name IS NOT NULL THEN

    FOR rec IN csr_get_vrent_wprop  LOOP
      PN_VAR_UPG_VOL_PKG.process_vr_upgrade
          ( p_var_rent_id => rec.var_rent_id);
    END LOOP;

  ELSIF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN

    FOR rec IN csr_get_vrent_wloc  LOOP
      PN_VAR_UPG_VOL_PKG.process_vr_upgrade
          ( p_var_rent_id => rec.var_rent_id);
    END LOOP;

  ELSE

    FOR rec IN csr_get_vrent_woloc  LOOP
      PN_VAR_UPG_VOL_PKG.process_vr_upgrade
          ( p_var_rent_id => rec.var_rent_id);
    END LOOP;

  END IF;

  pnp_debug_pkg.log(' ++++++++++++++ vr_upgrade_batch_process - END
+++++++++++++');

EXCEPTION

  WHEN OTHERS THEN
    raise_application_error ('-20001','Error ' || to_char(sqlcode)||'   error
message '||SQLERRM);

END vr_update_volume_status;



--------------------------------------------------------------------------------
--
--  NAME         : process_vr_upgrade
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : vr_update_volumen_status
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  07-AUG-2007  pikhar o Created
--------------------------------------------------------------------------------
PROCEDURE process_vr_upgrade( p_var_rent_id IN NUMBER)
IS

CURSOR csr_get_period IS
SELECT period_id
FROM   pn_var_periods_all
WHERE  var_rent_id = p_var_rent_id;

BEGIN

  pnp_debug_pkg.log(' ++++++++++++++ process_vr_upgrade - START +++++++++++++');

     FOR rec IN csr_get_period LOOP

        UPDATE PN_VAR_VOL_HIST_ALL vol
        SET vol_hist_status_code = 'APPROVED'
        WHERE period_id = rec.period_id;

     END LOOP;

  pnp_debug_pkg.log(' ++++++++++++++ process_vr_upgrade - END +++++++++++++');

EXCEPTION

  WHEN OTHERS THEN
    raise_application_error ('-20001','Error ' || to_char(sqlcode)||'   error
message '||SQLERRM);

END process_vr_upgrade;

END PN_VAR_UPG_VOL_PKG;


/
