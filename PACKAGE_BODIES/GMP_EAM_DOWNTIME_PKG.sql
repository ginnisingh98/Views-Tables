--------------------------------------------------------
--  DDL for Package Body GMP_EAM_DOWNTIME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_EAM_DOWNTIME_PKG" AS
/* $Header: GMPASUNB.pls 120.2.12010000.2 2009/04/13 15:24:56 rpatangy ship $ */

PROCEDURE insert_man_unavail
  (
        errbuf                   OUT  NOCOPY VARCHAR2,
        retcode                  OUT  NOCOPY NUMBER,
        p_organization_id        IN   NUMBER,
        p_include_unreleased     IN   NUMBER,   /* 3467386 */
        p_include_unfirmed       IN   NUMBER,   /* 3467386 */
        p_resources              IN   VARCHAR2  /* 3467386 */
  ) IS

  g_reason_code     VARCHAR2(4);
  l_user_id         NUMBER;
  l_resources       VARCHAR2(16);
  v_prod_id         NUMBER;
  i                 NUMBER;
  new_prod_org_flag NUMBER;
  prev_prod_org_id  NUMBER;
  NO_ROWS           EXCEPTION;

  /* B3467386 08-Mar-04 Namit Singhi. Cursor modified to have these new changes - Cursor
    should be able to give rows when no plant code is entered and when
    resources are enetered. */
  /* B4905308, The eam View contains the active organizations in it and hence HR
     table join is removed  */

CURSOR Cur_eam_rsrc_unavail (c_organization_id       NUMBER,
                             c_include_unreleased    NUMBER,
                             c_include_unfirmed      NUMBER,
                             c_resources             VARCHAR2
                            ) IS
SELECT  mp.organization_code  ORGANIZATION_CODE,
        mp.organization_id    mtl_organization_id,
        crd.resource_id       resource_id,
        gri.instance_id       instance_id,
        gri.instance_number   instance_number,
        eam.wip_entity_id     wip_entity_id,
        eam.op_seq            op_seq,
        eam.maint_org_id      maint_org_id,
        eam.workorder_number  workorder_number,
       	eam.from_date         from_date,
        eam.to_date           to_date,
        eam.eqp_serial_number  eqp_serial_number
FROM    eam_workorder_downtime_v   eam,
        gmp_resource_instances     gri,
        cr_rsrc_dtl                crd,
        mtl_parameters             mp
WHERE   mp.organization_id = nvl(c_organization_id,mp.organization_id)
  AND   mp.process_enabled_flag = 'Y'
  AND   eam.prod_org_id = mp.organization_id
  AND   eam.equipment_item_id = gri.equipment_item_id
  AND   eam.eqp_serial_number = gri.eqp_serial_number
  AND   crd.resource_id = gri.resource_id
  AND   crd.organization_id = mp.organization_id
  AND   ((c_include_unreleased = 1
        AND eam.status_type IN (1,3))  /* B3467386,Released and Unreleased  */
        OR ( c_include_unreleased <> 1
        AND eam.status_type = 3 ))     /* B3467386 Released Only */
  AND   ((c_include_unfirmed = 1
        AND eam.firm_flag IN (1,2))    /* 3467386 - Firm and Unfirm */
        OR (c_include_unfirmed <> 1
        AND eam.firm_flag = 1))        /* B3467386 - Firm only */
  AND   eam.to_date >= sysdate
  AND   eam.to_date > eam.from_date    /* Rows with no duration will not be selected */
  AND   crd.resources = nvl(c_resources,crd.resources)
  AND   crd.inactive_ind = 0
  -- B8416225 Rajesh Patangya
  AND   crd.schedule_ind in (1,2)      /* Schedule and Schedule to Instances */
  AND   crd.delete_mark = 0
  ORDER BY mp.organization_id, eam.wip_entity_id, gri.instance_number;

BEGIN
  g_reason_code     := 'NONE';
  l_resources       := '';
  v_prod_id         := 0 ;
  i                 := 0;
  new_prod_org_flag := 0;
  prev_prod_org_id  := 0;

    l_user_id :=  to_number(FND_PROFILE.VALUE('USER_ID')) ;

    /* B3467386 08-Mar-04 Namit Singhi. Cursor paramters included */
    FOR eam_unavail_dtl IN Cur_eam_rsrc_unavail(p_organization_id,
                                                p_include_unreleased,
                                                p_include_unfirmed,
                                                p_resources)
    LOOP

    /* B3467386 08-Mar-04 Namit Singhi. The following IF condition makes sure
    that Delete from gmp_rsrc_unavail_man happens only once for each Plant */

     IF(prev_prod_org_id = eam_unavail_dtl.mtl_organization_id) THEN
        new_prod_org_flag := 2;  -- False
     ELSE
        new_prod_org_flag := 1;  -- True. Execute delete statement.
     END IF;


     /* Delete from Resource Unavailability table to load a fresh
        The following Delete method has been agreed, though it has some
        Cost associated with it with respect to Performance issue
        Cannot Blindly delete the Wip_entity_id's that got loaded and
        had to use the following procedure, which uses sub queries. */

     IF new_prod_org_flag = 1 THEN
        DELETE
        FROM  gmp_rsrc_unavail_man  gmp
        WHERE  EXISTS  (
                    SELECT eam.wip_entity_id
                    FROM
                             eam_workorder_downtime_v  eam,
                             gmp_resource_instances     gri,
                             cr_rsrc_dtl                crd
                     WHERE eam.equipment_item_id = gri.equipment_item_id
                     AND   eam.eqp_serial_number = gri.eqp_serial_number
                     AND   crd.resource_id = gri.resource_id
                     AND   eam.firm_flag in (1,2)
                     AND   eam.prod_org_id = eam_unavail_dtl.mtl_organization_id
                     AND   crd.organization_id = eam_unavail_dtl.mtl_organization_id
                     AND   eam.wip_entity_id = gmp.wip_entity_id
                     AND   eam.to_date >= sysdate
                     AND   eam.to_date > eam.from_date
                  )
        AND gmp.to_date > sysdate  ;
     END IF;

     prev_prod_org_id := eam_unavail_dtl.mtl_organization_id;

     i := i + 1 ;
     IF i > 500 THEN
	COMMIT ;
	i := 0 ;
     END IF ;


    INSERT INTO gmp_rsrc_unavail_man
                  (
                   resource_id,
                   from_date,
                   to_date,
                   reason_code,
                   creation_date,
                   created_by,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   resource_units,
                   instance_id,
                   wip_entity_id,
                   maint_org_id,
                   op_seq
                  )
    Values (
                    eam_unavail_dtl.resource_id,
                    eam_unavail_dtl.from_date,
                    eam_unavail_dtl.to_date,
                    G_reason_code,
                    sysdate,
	            l_user_id ,
                    sysdate,
		    l_user_id ,
		    l_user_id ,
                    to_number(NULL),   /* instance_id is given */
                    eam_unavail_dtl.instance_id,
                    eam_unavail_dtl.wip_entity_id,
                    eam_unavail_dtl.maint_org_id,
                    eam_unavail_dtl.op_seq
            );

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Wip Entity Ids Inserted - '||eam_unavail_dtl.ORGANIZATION_CODE||'-'||eam_unavail_dtl.wip_entity_id);
    END LOOP;

    IF i = 0 THEN
       RAISE NO_ROWS;
    END IF;

EXCEPTION
    WHEN NO_ROWS  THEN
      errbuf := sqlerrm;
      FND_MESSAGE.SET_NAME('GMA','SY_NO_ROWS_SELECTED');
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'-'||FND_MESSAGE.GET);
      /* Setting the Concurrent Status to Warning instead of giving Error */
      IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
          NULL;
      END IF;
      retcode := '3';
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert Failed - Error Occured '||sqlerrm);

END insert_man_unavail;

END gmp_eam_downtime_pkg;

/
