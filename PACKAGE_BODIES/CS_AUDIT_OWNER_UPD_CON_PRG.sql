--------------------------------------------------------
--  DDL for Package Body CS_AUDIT_OWNER_UPD_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_AUDIT_OWNER_UPD_CON_PRG" AS
/* $Header: csxaownb.pls 120.4 2005/08/15 17:58:15 allau noship $ */

PROCEDURE Create_Audit_Gen_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  ) IS
BEGIN
  -- Parent Processing
  AD_CONC_UTILS_PKG.submit_subrequests
    (x_errbuf     => x_errbuf,
     x_retcode    => x_retcode,
     x_workerconc_app_shortname  => 'CS', --l_product,
     x_workerconc_progname => 'CSSRAWGEN',
     x_batch_size           => 1000,
     x_num_workers          => 3
    );
END Create_Audit_Gen_Manager;

PROCEDURE Create_Audit_Gen_Worker
  (x_errbuf       OUT  NOCOPY VARCHAR2,
   x_retcode      OUT  NOCOPY VARCHAR2,
   x_batch_size    IN  NUMBER,
   x_worker_id     IN  NUMBER,
   x_num_workers   IN  NUMBER
  ) IS


-- Local Variables Declared
TYPE num_tbl_type  IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE row_tbl_type  IS TABLE OF ROWID         INDEX BY BINARY_INTEGER;
TYPE vr1_tbl_type  IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE vr2_tbl_type  IS TABLE OF VARCHAR2(3)   INDEX BY BINARY_INTEGER;
TYPE vr3_tbl_type  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;

rowid_arr             row_tbl_type;
inc_owner_id          num_tbl_type;
old_inc_owner_id      num_tbl_type;
change_own_flag       vr1_tbl_type;
res_type              vr3_tbl_type;
old_res_type          vr3_tbl_type;
change_res_type_flag  vr1_tbl_type;
grp_id                num_tbl_type;
old_grp_id            num_tbl_type;
change_grp_flag       vr1_tbl_type;
grp_type              vr3_tbl_type;
old_grp_type          vr3_tbl_type;
change_grp_type_flag  vr1_tbl_type;
inc_id                num_tbl_type;
upd_entity_code       vr3_tbl_type;
upd_entity_id         num_tbl_type;
inv_org_id1           num_tbl_type;
inv_org_id2           num_tbl_type;
eam_inst_id1          num_tbl_type;
eam_inst_id2          num_tbl_type;
master_org_id1        num_tbl_type;
master_org_id2        num_tbl_type;
cust_prod_id1         num_tbl_type;
cust_prod_id2         num_tbl_type;
maint_flag            vr2_tbl_type;
maint_org_id1         num_tbl_type;
maint_org_id2         num_tbl_type;

CURSOR c_all_audit_csr(c_start_rowid rowid,c_end_rowid rowid) IS
SELECT /*+ ordered rowid(a) use_nl(i t cii1 cii2 mp1 mp2) */
       a.rowid, a.incident_owner_id, a.old_incident_owner_id,
       a.change_incident_owner_flag, a.resource_type,
       a.old_resource_type, a.change_resource_type_flag,
       a.group_id, a.old_group_id, a.change_group_flag,
       a.group_type, a.old_group_type, a.change_group_type_flag,
       a.incident_id, a.updated_entity_code, a.updated_entity_id,
       a.inv_organization_id, a.old_inv_organization_id,
       cii1.instance_id, cii2.instance_id,
       mp1.master_organization_id, mp2.master_organization_id,
       a.customer_product_id, a.old_customer_product_id, t.maintenance_flag,
       a.maint_organization_id, a.old_maint_organization_id
FROM   cs_incidents_audit_b a,
       cs_incidents_all_b   i,
       cs_incident_types_b  t,
       csi_item_instances   cii1,
       csi_item_instances   cii2,
       mtl_parameters       mp1,
       mtl_parameters       mp2
WHERE  a.rowid between c_start_rowid and c_end_rowid
  AND  a.incident_id = i.incident_id
  AND  i.incident_type_id = t.incident_type_id
  AND  a.item_serial_number = cii1.serial_number (+)
  AND  a.inventory_item_id = cii1.inventory_item_id (+)
  AND  a.inv_organization_id = mp1.organization_id (+)
  AND  a.old_item_serial_number = cii2.serial_number (+)
  AND  a.old_inventory_item_id = cii2.inventory_item_id (+)
  AND  a.old_inv_organization_id = mp2.organization_id (+)
  AND  (a.resource_type   IN ('RS_GROUP', 'RS_TEAM')
   OR  a.old_resource_type IN ('RS_GROUP', 'RS_TEAM')
   OR  (a.updated_entity_code IS NULL
  AND  a.updated_entity_id IS NULL)
   OR  (a.maint_organization_id IS NULL
  AND  t.maintenance_flag = 'Y')
   OR  (a.old_incident_type_id IS NULL  -- 4438560, only for creation audit
  AND  a.group_type IS NULL
  AND  a.group_id IS NOT NULL));

l_worker_id             NUMBER;
l_product               VARCHAR2(30) := 'CS';
l_table_name            VARCHAR2(30) := 'CS_INCIDENTS_AUDIT_B';
l_table_owner           VARCHAR2(30);
l_update_name           VARCHAR2(30) := 'csxaownb.pls.120.0';
l_start_rowid           ROWID;
l_end_rowid             ROWID;
--l_rows_processed        NUMBER;
l_status                VARCHAR2(30);
l_industry              VARCHAR2(30);
l_retstatus             BOOLEAN;
l_any_rows_to_process   BOOLEAN;
l_cur_fetch             NUMBER := 0;

BEGIN
  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(
                    l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner IS NULL)) THEN
      RAISE_APPLICATION_ERROR(-20001,
         'Cannot get schema name for product : '||l_product);
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, '  X_Worker_Id : '||X_Worker_Id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

  --
  -- Worker processing
  --
  -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove
  -- build time dependencies as the processing could potentially reference
  -- some tables that could be obsoleted in the current release
  --
    BEGIN -- AB1
    ad_parallel_updates_pkg.initialize_rowid_range(
         ad_parallel_updates_pkg.ROWID_RANGE,
         l_table_owner,
         l_table_name,
         l_update_name,
         x_worker_id,
         x_num_workers,
         x_batch_size, 0);

    ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         x_batch_size,
         TRUE);


    WHILE (l_any_rows_to_process) LOOP --{Loop1
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing: l_start_row_id='||l_start_rowid
        || '; l_end_rowid=' || l_end_rowid);
      OPEN c_all_audit_csr(l_start_rowid,l_end_rowid);
      FETCH c_all_audit_csr BULK COLLECT INTO
             rowid_arr, inc_owner_id, old_inc_owner_id, change_own_flag,
             res_type, old_res_type, change_res_type_flag,
             grp_id, old_grp_id, change_grp_flag,
             grp_type, old_grp_type, change_grp_type_flag,
             inc_id,
             upd_entity_code, upd_entity_id, inv_org_id1, inv_org_id2,
             eam_inst_id1, eam_inst_id2, master_org_id1,
             master_org_id2, cust_prod_id1, cust_prod_id2, maint_flag,
             maint_org_id1, maint_org_id2;
      CLOSE c_all_audit_csr;
      l_cur_fetch := rowid_arr.COUNT;
      IF (rowid_arr.COUNT > 0) THEN
       FORALL i in rowid_arr.first..rowid_arr.last
       UPDATE cs_incidents_audit_b
       SET    incident_owner_id              = DECODE(res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      inc_owner_id(i)),
              old_incident_owner_id          = DECODE(old_res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      old_inc_owner_id(i)),
              change_incident_owner_flag   = DECODE(
                                               DECODE(res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      inc_owner_id(i)),
                                               DECODE(old_res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      old_inc_owner_id(i)),
                                               'N', 'Y'),

              resource_type                = DECODE(res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NULL,
                                                    res_type(i)),
              old_resource_type            = DECODE(old_res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NULL,
                                                    old_res_type(i)),
              change_resource_type_flag    = DECODE(
                                               DECODE(res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      res_type(i)),
                                               DECODE(old_res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NULL,
                                                      old_res_type(i)),
                                               'N', 'Y'),

              --item_serial_number           = NULL,
              --old_item_serial_number       = NULL,


              group_id                     = DECODE(res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NVL(grp_id(i), inc_owner_id(i)),
                                                    DECODE(grp_type(i), 'RS_TEAM', NULL, grp_id(i))),
              old_group_id                 = DECODE(old_res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NVL(old_grp_id(i), old_inc_owner_id(i)),
                                                    DECODE(old_grp_type(i), 'RS_TEAM', NULL, old_grp_id(i))),
              change_group_flag            = DECODE(
                                               DECODE(res_type(i),
                                                 'RS_TEAM', NULL,
                                                 'RS_GROUP', NVL(grp_id(i), inc_owner_id(i)),
                                                  DECODE(grp_type(i), 'RS_TEAM', NULL, grp_id(i))),
                                                DECODE(old_res_type(i),
                                                  'RS_TEAM', NULL,
                                                  'RS_GROUP', NVL(old_grp_id(i), old_inc_owner_id(i)),
                                                  DECODE(old_grp_type(i), 'RS_TEAM', NULL, old_grp_id(i))),
                                                'N', 'Y'),  --change_own_flag(i),
              group_type                   = DECODE(res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NVL(grp_type(i), res_type(i)),
                                                    DECODE(grp_type(i),
                                                      'RS_TEAM', NULL,
                                                      DECODE(old_incident_type_id, -- only for creation audit
                                                        NULL, DECODE(grp_id(i),
                                                                NULL, NULL, NVL(grp_type(i), 'RS_GROUP')), -- if group id is not null, set group type to RS_GROUP
                                                        grp_type(i)))),

              old_group_type               = DECODE(old_res_type(i),
                                                    'RS_TEAM', NULL,
                                                    'RS_GROUP', NVL(old_grp_type(i), old_res_type(i)),
                                                    decode(old_grp_type(i), 'RS_TEAM', NULL, old_grp_type(i))),
              change_group_type_flag       = DECODE(DECODE(res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NVL(grp_type(i), res_type(i)),
                                                      DECODE(grp_type(i),
                                                        'RS_TEAM', NULL,
                                                        DECODE(old_incident_type_id,
                                                          NULL, DECODE(grp_id(i),
                                                                  NULL, NULL, NVL(grp_type(i), 'RS_GROUP')),
                                                          grp_type(i)))),
                                                    DECODE(old_res_type(i),
                                                      'RS_TEAM', NULL,
                                                      'RS_GROUP', NVL(old_grp_type(i), old_res_type(i)),
                                                      DECODE(old_grp_type(i), 'RS_TEAM', NULL, old_grp_type(i))),
                                                    'N', 'Y'),  --change_res_type_flag(i),

              updated_entity_code          = NVL(upd_entity_code(i), 'SR_HEADER'),
              updated_entity_id            = NVL(upd_entity_id(i), inc_id(i)),

              maint_organization_id        = NVL(maint_org_id1(i),
                                                 DECODE(maint_flag(i), 'Y', inv_org_id1(i), NULL)),
              old_maint_organization_id    = NVL(maint_org_id2(i),
                                                 DECODE(maint_flag(i), 'Y', inv_org_id2(i), NULL)),

              inv_organization_id          = DECODE(maint_flag(i),
                                                    'Y', DECODE(maint_org_id1(i), NULL, master_org_id1(i), inv_org_id1(i)),
                                                    inv_org_id1(i)),
              old_inv_organization_id      = DECODE(maint_flag(i),
                                                    'Y', DECODE(maint_org_id2(i), NULL, master_org_id2(i), inv_org_id2(i)),
                                                    inv_org_id2(i)),
              change_inv_organization_flag = DECODE(
                                               DECODE(maint_flag(i), 'Y', DECODE(maint_org_id1(i), NULL, master_org_id1(i), inv_org_id1(i)), inv_org_id1(i)),
                                               DECODE(maint_flag(i), 'Y', DECODE(maint_org_id2(i), NULL, master_org_id2(i), inv_org_id2(i)), inv_org_id2(i)),
                                               'N',  'Y'),

              customer_product_id          = DECODE(maint_flag(i), 'Y', DECODE(maint_org_id1(i), NULL,  eam_inst_id1(i), cust_prod_id1(i)), cust_prod_id1(i)),
              old_customer_product_id      = DECODE(maint_flag(i), 'Y', DECODE(maint_org_id2(i), NULL, eam_inst_id2(i), cust_prod_id2(i)), cust_prod_id2(i)),
              change_customer_product_flag = DECODE(
                                               DECODE(maint_flag(i), 'Y', decode(maint_org_id1(i), NULL,  eam_inst_id1(i), cust_prod_id1(i)), cust_prod_id1(i)),
                                               DECODE(maint_flag(i), 'Y', decode(maint_org_id2(i), NULL, eam_inst_id2(i), cust_prod_id2(i)), cust_prod_id2(i)),
                                               'N', 'Y')
       WHERE  rowid = rowid_arr(i);

      END IF;
      x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

      ad_parallel_updates_pkg.processed_rowid_range(
       l_cur_fetch,
       l_end_rowid);

      COMMIT;

      ad_parallel_updates_pkg.get_rowid_range(
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       x_batch_size,
       FALSE);
    END LOOP; --}Loop2

  END; -- AB1
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
    RAISE;
END Create_Audit_Gen_Worker;

END CS_AUDIT_OWNER_UPD_CON_PRG;

/
