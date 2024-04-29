--------------------------------------------------------
--  DDL for Package Body PN_RECOVERY_TENANCY_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_RECOVERY_TENANCY_UPG_PKG" AS
-- $Header: PNUPTENB.pls 120.3 2007/01/24 12:23:03 rdonthul ship $

---------------------------------------------------------------------------
-- PROCEDURE : tenancy_upgrade_batch
-- Referenced in the Concurrent Program executable definition.
--
-- HISTORY
-- 19-Jun-2003  Pooja Sidhu     o Created.
-- 22-AUG-2003  Satish Tripathi o Fixed for BUG# 3111676, Added parameter p_action
--                                when calling create_auto_space_assign.
-- 06-NOV-2003  Satish Tripathi o Modified for Multi Primary Tenancy Enhancement.
--                                Modified CURSOR c_mass_tenancies to Create assignments
--                                for all tenancies of Sublease/Third Party Leases.
-- 25-APR-04  atuppad         o Changed the cursor c_mass_tenancies to get the
--                              NVL(occupancy_date, estimated_occupancy_date) rather
--                              than direct estimated_occupancy_date. Bug#3592232
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_tenancies with _ALL table.
---------------------------------------------------------------------------
PROCEDURE tenancy_upgrade_batch ( errbuf                OUT NOCOPY VARCHAR2,
                                  retcode               OUT NOCOPY VARCHAR2,
                                  p_lease_num_from      IN VARCHAR2,
                                  p_lease_num_to        IN VARCHAR2,
                                  p_rec_space_std_code  IN VARCHAR2,
                                  p_rec_type_code       IN VARCHAR2,
                                  p_upd_customer        IN VARCHAR2,
                                  p_upd_fin_oblg_end_dt IN VARCHAR2) IS

CURSOR c_cust_info(p_lease_id NUMBER) IS
SELECT customer_id,
       customer_site_use_id
FROM   pn_payment_terms_all
WHERE  lease_id = p_lease_id
AND    rownum = 1;

CURSOR c_mass_tenancies IS
SELECT pt.tenancy_id,
       pt.customer_id,
       pt.customer_site_use_id,
       pt.fin_oblig_end_date,
       pt.allocated_area_pct,
       pt.recovery_type_code,
       pt.recovery_space_std_code,
       NVL(pt.occupancy_date, pt.estimated_occupancy_date),
       pt.expiration_date,
       pt.lease_id,
       pt.location_id,
       pt.org_id
FROM   pn_tenancies_all  pt,
       pn_leases pl
WHERE  pt.lease_id = pl.lease_id
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_class_code IN ('SUB_LEASE', 'THIRD_PARTY')
AND    NOT EXISTS (SELECT NULL
                   FROM   pn_space_assign_cust_all psc
                   WHERE  psc.tenancy_id = pt.tenancy_id);

TYPE t_tenancy_id IS
TABLE OF PN_TENANCIES_ALL.TENANCY_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_cust_id IS
TABLE OF PN_TENANCIES_ALL.CUSTOMER_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_cust_site_use_id IS
TABLE OF PN_TENANCIES_ALL.CUSTOMER_SITE_USE_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_fin_oblig_end_date IS
TABLE OF PN_TENANCIES_ALL.FIN_OBLIG_END_DATE%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_allocated_area_pct IS
TABLE OF PN_TENANCIES_ALL.ALLOCATED_AREA_PCT%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_recovery_type_code IS
TABLE OF PN_TENANCIES_ALL.RECOVERY_TYPE_CODE%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_recovery_space_std_code IS
TABLE OF PN_TENANCIES_ALL.RECOVERY_SPACE_STD_CODE%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_estimated_occupancy_date IS
TABLE OF PN_TENANCIES_ALL.ESTIMATED_OCCUPANCY_DATE%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_expiration_date IS
TABLE OF PN_TENANCIES_ALL.EXPIRATION_DATE%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_lease_id IS
TABLE OF PN_TENANCIES_ALL.LEASE_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_location_id IS
TABLE OF PN_TENANCIES_ALL.LOCATION_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_org_id IS
TABLE OF PN_TENANCIES_ALL.ORG_ID%TYPE
INDEX BY BINARY_INTEGER;

tenancy_id_tbl              t_tenancy_id;
cust_id_tbl                 t_cust_id;
cust_site_use_id_tbl        t_cust_site_use_id;
fin_oblig_end_date_tbl      t_fin_oblig_end_date;
allocated_area_pct_tbl      t_allocated_area_pct;
allocated_area_pct          t_allocated_area_pct;
recovery_type_code_tbl      t_recovery_type_code;
recovery_space_std_code_tbl t_recovery_space_std_code;
estm_occupancy_date_tbl     t_estimated_occupancy_date;
exp_date_tbl                t_expiration_date;
lease_id_tbl                t_lease_id;
location_id_tbl             t_location_id;
org_id_tbl                  t_org_id;

i                    NUMBER := 0;
l_count              NUMBER := 0;
l_total_count        NUMBER := 0;
l_count_spc_std      NUMBER := 0;
l_count_rec_type     NUMBER := 0;
l_count_cust         NUMBER := 0;
l_count_fin_end_dt   NUMBER := 0;
l_action             VARCHAR2(2000):= NULL;
l_msg                VARCHAR2(2000):= NULL;
l_context            VARCHAR2(200) := NULL;
l_cust_id            pn_tenancies_all.customer_id%type;
l_cust_site_id       pn_tenancies_all.customer_site_use_id%type;
l_date               pn_tenancies_all.fin_oblig_end_date%type;
l_customer_id        pn_tenancies_all.customer_id%type;
l_customer_site_id   pn_tenancies_all.customer_site_use_id%type;
l_rec_type_code      pn_tenancies_all.recovery_type_code%type;
l_rec_space_std_code pn_tenancies_all.recovery_space_std_code%type;
l_fin_oblig_end_date pn_tenancies_all.fin_oblig_end_date%type;

BEGIN
   pnp_debug_pkg.log('pn_recovery_tenancy_upg_pkg.tenancy_upgrade_batch (+)' );
   pnp_debug_pkg.log('Parameters       ' );
   pnp_debug_pkg.log('-------------------------------------------' );
   pnp_debug_pkg.log('Lease Num. From                      : ' || p_lease_num_from);
   pnp_debug_pkg.log('Lease Num. To                        : ' || p_lease_num_to);
   pnp_debug_pkg.log('Space Standard Code                  : ' || p_rec_space_std_code);
   pnp_debug_pkg.log('Recovery Type Code                   : ' || p_rec_type_code);
   pnp_debug_pkg.log('Update Customer                      : ' || p_upd_customer);
   pnp_debug_pkg.log('Update Financial Obligation End Date : ' || p_upd_fin_oblg_end_dt);

   tenancy_id_tbl.delete;
   cust_id_tbl.delete;
   cust_site_use_id_tbl.delete;
   fin_oblig_end_date_tbl.delete;
   allocated_area_pct_tbl.delete;
   recovery_type_code_tbl.delete;
   recovery_space_std_code_tbl.delete;
   estm_occupancy_date_tbl.delete;
   exp_date_tbl.delete;
   lease_id_tbl.delete;
   location_id_tbl.delete;
   org_id_tbl.delete;

   l_context := 'Opening c_mass_tenancies cursor';

   OPEN c_mass_tenancies;
   FETCH c_mass_tenancies BULK COLLECT
   INTO  tenancy_id_tbl,
         cust_id_tbl,
         cust_site_use_id_tbl,
         fin_oblig_end_date_tbl,
         allocated_area_pct_tbl,
         recovery_type_code_tbl,
         recovery_space_std_code_tbl,
         estm_occupancy_date_tbl,
         exp_date_tbl,
         lease_id_tbl,
         location_id_tbl,
         org_id_tbl;
   CLOSE c_mass_tenancies;

   pnp_debug_pkg.log('Processed Bulk Collect. Nof records found: '||tenancy_id_tbl.COUNT);

   FOR i IN 1..tenancy_id_tbl.COUNT
   LOOP
      pnp_debug_pkg.log('Processing record# '||i||', Tenancy_id : '||tenancy_id_tbl(i)||
                        ', Location_Id: '||location_id_tbl(i));
      l_context := 'Looping through pl/sql tables';
      l_cust_id            := NULL;
      l_cust_site_id       := NULL;
      l_date               := NULL;
      l_customer_id        := NULL;
      l_customer_site_id   := NULL;
      l_rec_type_code      := NULL;
      l_rec_space_std_code := NULL;
      l_fin_oblig_end_date := NULL;

      IF NVL(p_upd_customer,'N')='Y' AND cust_id_tbl(i) IS NULL THEN
         l_context := 'Opening c_cust_info cursor';
         OPEN c_cust_info(lease_id_tbl(i));
         FETCH c_cust_info into l_cust_id, l_cust_site_id;
         CLOSE c_cust_info;
      END IF;
      pnp_debug_pkg.log('Processed c_cust_info. Cust_id : '||l_cust_id);

      IF NVL(p_upd_fin_oblg_end_dt,'N')='Y' AND fin_oblig_end_date_tbl(i) IS NULL THEN
         l_date := exp_date_tbl(i);
      END IF;

      l_context := 'Updating pn_tenancies_all table';

      IF (recovery_type_code_tbl(i) IS NULL AND p_rec_type_code IS NOT NULL) OR
         (recovery_space_std_code_tbl(i) IS NULL AND
          p_rec_space_std_code IS NOT NULL) OR
         (l_cust_id IS NOT NULL) OR
         (l_date IS NOT NULL) THEN

         UPDATE pn_tenancies_all
         SET customer_id             = NVL(cust_id_tbl(i), l_cust_id),
             customer_site_use_id    = NVL(cust_site_use_id_tbl(i), l_cust_site_id),
             recovery_type_code      = NVL(recovery_type_code_tbl(i), p_rec_type_code),
             recovery_space_std_code = NVL(recovery_space_std_code_tbl(i),
                                           p_rec_space_std_code),
             fin_oblig_end_date      = NVL(fin_oblig_end_date_tbl(i), l_date),
             last_update_date        = SYSDATE,
             last_updated_by         = NVL(fnd_profile.value('USER_ID'),0)
         WHERE tenancy_id = tenancy_id_tbl(i)
         RETURNING customer_id,
                   customer_site_use_id,
                   recovery_type_code,
                   recovery_space_std_code,
                   fin_oblig_end_date
         INTO      l_customer_id,
                   l_customer_site_id,
                   l_rec_type_code,
                   l_rec_space_std_code,
                   l_fin_oblig_end_date;
         pnp_debug_pkg.log('Updated pn_tenancies.');

         IF l_customer_id IS NOT NULL AND
            NOT(cust_space_assign_exists(tenancy_id_tbl(i))) THEN

             l_context := 'Creating Space Assignment Record';
             pn_tenancies_pkg.create_auto_space_assign(
                       p_location_id             => location_id_tbl(i)
                      ,p_lease_id                => lease_id_tbl(i)
                      ,p_customer_id             => l_customer_id
                      ,p_cust_site_use_id        => l_customer_site_id
                      ,p_cust_assign_start_dt    => estm_occupancy_date_tbl(i)
                      ,p_cust_assign_end_dt      => exp_date_tbl(i)
                      ,p_recovery_space_std_code => l_rec_space_std_code
                      ,p_recovery_type_code      => l_rec_type_code
                      ,p_fin_oblig_end_date      => l_fin_oblig_end_date
                      ,p_allocated_pct           => allocated_area_pct_tbl(i)
                      ,p_tenancy_id              => tenancy_id_tbl(i)
                      ,p_org_id                  => org_id_tbl(i)
                      ,p_action                  => l_action
                      ,p_msg                     => l_msg);
         END IF;

         l_count       := l_count + 1;
         l_total_count := l_total_count + 1;

         IF l_count = 1000 THEN
            l_context := 'Commiting transaction';
            commit;
            l_count := 0;
         END IF;

       END IF; --(recovery_type_code_tbl(i)IS NULL ...

       IF (recovery_space_std_code_tbl(i) IS NULL AND
           l_rec_space_std_code IS NULL) THEN
          l_count_spc_std := l_count_spc_std + 1;
       END IF;
       IF (recovery_type_code_tbl(i) IS NULL AND l_rec_type_code IS NULL) THEN
          l_count_rec_type := l_count_rec_type + 1;
       END IF;
       IF (cust_id_tbl(i) IS NULL AND l_customer_id IS NULL) THEN
          l_count_cust := l_count_cust + 1;
       END IF;
       IF (fin_oblig_end_date_tbl(i) IS NULL AND l_fin_oblig_end_date IS NULL) THEN
          l_count_fin_end_dt := l_count_fin_end_dt + 1;
       END IF;


   END LOOP;


   pnp_debug_pkg.log('+------------------------------------------------------------+');
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_LEASE_SELECTED') ||' '||tenancy_id_tbl.COUNT);
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_LEASE_PROC')     ||' '||l_total_count);
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_NO_SPC_STD')     ||' '||l_count_spc_std);
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_NO_RECOV_TYPE')  ||' '||l_count_rec_type);
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_NO_CUST')        ||' '||l_count_cust);
   pnp_debug_pkg.put_log_msg(fnd_message.get_string('PN','PN_REC_UPG_NO_FIN_OBLIG_DT')||' '||l_count_fin_end_dt);
   pnp_debug_pkg.log('pn_recovery_tenancy_upg_pkg.tenancy_upgrade_batch (-)' );

EXCEPTION
when others THEN
   raise_application_error ('-20001','Error ' || TO_CHAR(sqlcode) || '- while ' || l_context );

END tenancy_upgrade_batch;

---------------------------------------------------------------------------------
-- FUNCTION: cust_space_assign_exists
--
-- HISTORY
-- 19-Jun-2003   Pooja Sidhu   o Created.
--
-- Returns true IF a row exists in pn_space_assign_cust_all for a tenancy_id
--
---------------------------------------------------------------------------
FUNCTION cust_space_assign_exists(p_tenancy_id NUMBER)
RETURN BOOLEAN
IS
CURSOR c_exists IS
SELECT 'Y'
FROM pn_space_assign_cust_all
WHERE tenancy_id = p_tenancy_id
AND rownum = 1;

l_exists VARCHAR2(1) := 'N';
BEGIN

   OPEN c_exists;
   FETCH c_exists INTO l_exists;
   CLOSE c_exists;

   IF l_exists = 'Y' THEN return TRUE;
   ELSE return FALSE;
   END IF;
END cust_space_assign_exists;


END pn_recovery_tenancy_upg_pkg;


/
