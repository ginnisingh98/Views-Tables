--------------------------------------------------------
--  DDL for Package Body CSP_USAGE_HISTORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_USAGE_HISTORIES_PVT" AS
/* $Header: cspvpuhb.pls 115.26 2004/04/07 22:49:19 hhaugeru ship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_USAGE_HISTORIES_PVT';


PROCEDURE create_usage_history
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id	    IN  NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_usage_history';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_usage_id                    NUMBER;
  l_organization_id             NUMBER;
  l_quantity                    NUMBER;
  l_cursor                      NUMBER;
  l_ddl_string                  VARCHAR2(100);
  l_msg_data                    VARCHAR2(2000);
  l_msg_count                   NUMBER;
  l_return_status               VARCHAR2(2000);
  l_string 			            VARCHAR2(2000);
  l_start_date                  DATE;
  l_parts_loop_id               NUMBER;
  l_period_size                 NUMBER;

  cursor c_parts_loop is
  select cplb.parts_loop_id,
         cfrb.period_size,
         cfrb.history_periods
  from   csp_parts_loops_b cplb,
         csp_forecast_rules_b cfrb
  where  cplb.forecast_rule_id = cfrb.forecast_rule_id;

  cursor c_transactions is
  select decode(mmt.transaction_type_id,52,33,mmt.transaction_type_id) transaction_type_id,
         mmt.inventory_item_id,
         mmt.organization_id,
         trunc(sysdate) - round((to_number(trunc(sysdate) - mmt.transaction_date)/l_period_size+0.5)) * l_period_size period_start_date,
         mmt.subinventory_code,
         sum(mmt.primary_quantity) * -1 primary_quantity
  from   mtl_material_transactions mmt,
         csp_sec_inventories csi
  where  csi.parts_loop_id = l_parts_loop_id
  and    mmt.subinventory_code = csi.secondary_inventory_name
  and    mmt.organization_id = csi.organization_id
  and    mmt.transaction_date >= l_start_date
  and    mmt.transaction_type_id in (52,93)
  and    mmt.primary_quantity < 0
  group by mmt.transaction_type_id,
         mmt.inventory_item_id,
         mmt.organization_id,
         trunc(sysdate) - round((to_number(trunc(sysdate) - mmt.transaction_date)/l_period_size+0.5)) * l_period_size,
         mmt.subinventory_code;

  cursor c_sum_parts_loop is
  select cuh.inventory_item_id,
         cuh.period_start_date,
         cuh.transaction_type_id,
         cuh.parts_loop_id,
         cuh.organization_id,
         sum(cuh.quantity) quantity
  from   csp_usage_histories cuh
  where  nvl(cuh.history_data_type,0) = 0
  group by cuh.inventory_item_id,
         cuh.period_start_date,
         cuh.transaction_type_id,
         cuh.parts_loop_id,
         cuh.organization_id;

BEGIN
 -- Delete from Csp_Usage_Histories
	    EXECUTE IMMEDIATE 'DELETE FROM CSP_USAGE_HISTORIES WHERE HISTORY_DATA_TYPE = 0' ;

  -- Standard Start of API savepoint
  SAVEPOINT  create_usage_history_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version   ,
                                      p_api_version   ,
                                      l_api_name      ,
                                      G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
--  Initialize API return status to success
--  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for curs in c_parts_loop loop
    l_parts_loop_id := curs.parts_loop_id;
    l_start_date    := sysdate - curs.history_periods * curs.period_size;
    l_period_size   := curs.period_size;

    for ct in c_transactions loop
--      insert using table handler

      l_usage_id := null;
      csp_usage_histories_pkg.insert_row(
        px_usage_id           => l_usage_id,
        p_created_by          => fnd_global.user_id,
        p_creation_date       => sysdate,
        p_last_updated_by     => fnd_global.user_id,
        p_last_update_date    => sysdate,
        p_last_update_login   => null,
        p_inventory_item_id   => ct.inventory_item_id,
        p_organization_id     => ct.organization_id,
        p_period_type         => 2,
        p_period_start_date   => ct.period_start_date,
        p_quantity            => ct.primary_quantity,
        p_request_id          => null,
        p_program_application_id => null,
        p_program_id          => null,
        p_program_update_date => null,
        p_subinventory_code   => ct.subinventory_code,
        p_transaction_type_id => ct.transaction_type_id,
        p_hierarchy_node_id   => null,
        p_parts_loop_id       => curs.parts_loop_id,
        p_history_data_type   => 0,
        p_attribute_category  => null,
        p_attribute1          => null,
        p_attribute2          => null,
        p_attribute3          => null,
        p_attribute4          => null,
        p_attribute5          => null,
        p_attribute6          => null,
        p_attribute7          => null,
        p_attribute8          => null,
        p_attribute9          => null,
        p_attribute10         => null,
        p_attribute11         => null,
        p_attribute12         => null,
        p_attribute13         => null,
        p_attribute14         => null,
        p_attribute15         => null);
        commit;
      end loop;
  end loop;

-- Insert records for Part Loop level
  for cr in c_sum_parts_loop loop
-- insert using table handler
    l_usage_id := null;
    csp_usage_histories_pkg.insert_row(
        px_usage_id           => l_usage_id,
        p_created_by          => fnd_global.user_id,
        p_creation_date       => sysdate,
        p_last_updated_by     => fnd_global.user_id,
        p_last_update_date    => sysdate,
        p_last_update_login   => null,
        p_inventory_item_id   => cr.inventory_item_id,
        p_organization_id     => cr.organization_id,
        p_period_type         => 2,
        p_period_start_date   => cr.period_start_date,
        p_quantity            => cr.quantity,
        p_request_id          => null,
        p_program_application_id => null,
        p_program_id          => null,
        p_program_update_date => null,
        p_subinventory_code   => '-',
        p_transaction_type_id => cr.transaction_type_id,
        p_hierarchy_node_id   => null,
        p_parts_loop_id       => cr.parts_loop_id,
        p_history_data_type   => 0,
        p_attribute_category  => null,
        p_attribute1          => null,
        p_attribute2          => null,
        p_attribute3          => null,
        p_attribute4          => null,
        p_attribute5          => null,
        p_attribute6          => null,
        p_attribute7          => null,
        p_attribute8          => null,
        p_attribute9          => null,
        p_attribute10         => null,
        p_attribute11         => null,
        p_attribute12         => null,
        p_attribute13         => null,
        p_attribute14         => null,
        p_attribute15         => null);
    commit;
  end loop;

  FND_MSG_PUB.Count_And_Get
        (p_count            =>      l_msg_count ,
         p_data             =>      errbuf
        );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_usage_history_pvt;
    retcode := 2;
    FND_MSG_PUB.Count_And_Get
            (p_count            =>      l_msg_count ,
             p_data             =>      errbuf
            );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_usage_history_pvt;
    retcode := 2;
    FND_MSG_PUB.Count_And_Get
            (p_count            =>      l_msg_count ,
             p_data             =>      errbuf
            );
  WHEN OTHERS THEN
    ROLLBACK TO create_usage_history_pvt;
    retcode := 2;
    IF  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME  ,
                 l_api_name
             );
    END IF;
    FND_MSG_PUB.Count_And_Get
            (p_count            =>      l_msg_count ,
             p_data             =>      errbuf
            );
END create_usage_history;

END csp_usage_histories_pvt;

/
