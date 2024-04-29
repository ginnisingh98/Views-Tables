--------------------------------------------------------
--  DDL for Package Body PERIOD_SUMMARY_TRANSFER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PERIOD_SUMMARY_TRANSFER_UTIL" AS
/* $Header: INVPSTUB.pls 120.1 2005/06/11 12:24:58 appldev  $ */

-- global constant
g_pkg_name                     VARCHAR2(100) := 'Period Summary Transfer(INV - WMS)';


PROCEDURE period_summary_transfer(
          p_organization_id     IN   MTL_PARAMETERS.organization_id%TYPE,
          x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS

CURSOR org_cursor IS
	SELECT mps.acct_period_id,
               mps.organization_id,
               mps.inventory_type,
               sum(mps.inventory_value) sumvalue,
               msi.default_cost_group_id
        FROM   mtl_period_summary mps, mtl_secondary_inventories msi
        WHERE  mps.organization_id     = p_organization_id
        AND    mps.organization_id     = msi.organization_id
        AND    mps.secondary_inventory = msi.secondary_inventory_name
        GROUP BY mps.acct_period_id,
                 mps.organization_id,
                 mps.inventory_type,
                 msi.default_cost_group_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  SAVEPOINT   period_summary_transfer;
  x_return_status := fnd_api.g_ret_sts_success;

  FOR l_record IN org_cursor LOOP

  IF (l_debug = 1) THEN
     INV_TRX_UTIL_PUB.trace('organization_id = ' || l_record.organization_id, g_pkg_name,9);
     INV_TRX_UTIL_PUB.trace('= ' || l_record.acct_period_id, g_pkg_name,9);
     INV_TRX_UTIL_PUB.trace('= ' || l_record.organization_id, g_pkg_name,9);
     INV_TRX_UTIL_PUB.trace('= ' || l_record.inventory_type, g_pkg_name,9);
     INV_TRX_UTIL_PUB.trace('= ' || l_record.sumvalue, g_pkg_name,9);
     INV_TRX_UTIL_PUB.trace('= ' || l_record.default_cost_group_id, g_pkg_name,9);
  END IF;
  INSERT INTO
         mtl_period_cg_summary(acct_period_id,
                                    organization_id,
                                    inventory_type,
                                    inventory_value,
                                    cost_group_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    last_update_login,
                                    request_id,
                                    program_application_id,
                                    program_id,
                                    program_update_date)
  VALUES (l_record.acct_period_id,
          l_record.organization_id,
          l_record.inventory_type,
          l_record.sumvalue,
          l_record.default_cost_group_id,
          SYSDATE,
          fnd_global.user_id,
          SYSDATE,
          fnd_global.user_id,
          fnd_global.login_id,
          fnd_global.conc_request_id,
          fnd_global.prog_appl_id,
          fnd_global.conc_program_id,
          SYSDATE);

  END LOOP;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX  THEN
       fnd_message.set_name('INV', 'INV_SAVE_FAILURE');
       fnd_msg_pub.add;
       ROLLBACK TO period_summary_transfer ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
                         (p_encoded   =>      FND_API.G_FALSE,
                          p_count     =>      x_msg_count,
                          p_data      =>      x_msg_data);
    WHEN OTHERS THEN
         ROLLBACK TO period_summary_transfer ;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg (g_pkg_name,
                                     'period_summary_transfer' );
         END IF;
       FND_MSG_PUB.Count_And_Get
                         (p_encoded   =>      FND_API.G_FALSE,
                          p_count     =>      x_msg_count,
                          p_data      =>      x_msg_data);

END period_summary_transfer;
--
END period_summary_TRANSFER_UTIL;

/
