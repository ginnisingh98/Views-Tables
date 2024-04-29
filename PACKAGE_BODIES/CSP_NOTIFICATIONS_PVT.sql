--------------------------------------------------------
--  DDL for Package Body CSP_NOTIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_NOTIFICATIONS_PVT" AS
/* $Header: cspvpnob.pls 120.0 2005/05/25 11:25:56 appldev noship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_NOTIFICATIONS_PVT';
PROCEDURE calculate_loop
( p_api_version           IN      NUMBER,
  p_parts_loop_id         IN      NUMBER,
  p_inventory_item_id     IN      NUMBER,
  p_include_intransit_mo          VARCHAR2 ,
  p_include_interorg_transfers    VARCHAR2 ,
  p_include_sales_orders          VARCHAR2 ,
  p_include_move_orders           VARCHAR2 ,
  p_include_requisitions          VARCHAR2 ,
  p_include_purchase_orders       VARCHAR2 ,
  p_include_work_orders           VARCHAR2 ,
  p_include_onhand_good           VARCHAR2 ,
  p_include_onhand_bad            VARCHAR2 ,
  p_tolerance_percent             NUMBER   ,
  x_above                  OUT NOCOPY    NUMBER,
  x_below                  OUT NOCOPY    NUMBER,
  x_not_enough_good_parts  OUT NOCOPY    NUMBER,
  x_quantity_level         OUT NOCOPY    NUMBER,
  x_onhand_good            OUT NOCOPY    NUMBER,
  x_min_good               OUT NOCOPY    NUMBER,
  x_total_loop_quantity    OUT NOCOPY    NUMBER,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2
)
IS
  l_api_name            CONSTANT  VARCHAR2(30)   := 'calculate_loop';
  l_api_version         CONSTANT  NUMBER         := 1.0;
  l_quantity_level                NUMBER;
  l_above                         NUMBER;
  l_below                         NUMBER;
  l_negp                          NUMBER;
  l_onhand_good                   NUMBER;
  l_min_good                      NUMBER;
  l_total_loop_quantity           NUMBER;
  l_include_intransit_mo          csp_loop_calc_rules_b.include_intransit_move_orders%TYPE;
  l_include_move_orders           csp_loop_calc_rules_b.include_move_orders%TYPE;
  l_include_work_orders           csp_loop_calc_rules_b.include_work_orders%TYPE;
  l_include_purchase_orders       csp_loop_calc_rules_b.include_purchase_orders%TYPE;
  l_include_requisitions          csp_loop_calc_rules_b.include_requisitions%TYPE;
  l_include_interorg_transfers    csp_loop_calc_rules_b.include_interorg_transfers%TYPE;
  l_include_onhand_good           csp_loop_calc_rules_b.include_onhand_good%TYPE;
  l_include_onhand_bad            csp_loop_calc_rules_b.include_onhand_bad%TYPE;
  l_include_sales_orders          csp_loop_calc_rules_b.include_sales_orders%TYPE;
  l_tolerance_percent             csp_loop_calc_rules_b.tolerance_percent%TYPE;

  CURSOR c_calculation_rule IS
  SELECT clcrb.include_sales_orders
  ,      clcrb.include_move_orders
  ,      clcrb.include_work_orders
  ,      clcrb.include_purchase_orders
  ,      clcrb.include_requisitions
  ,      clcrb.include_interorg_transfers
  ,      clcrb.include_onhand_good
  ,      clcrb.include_onhand_bad
  ,      clcrb.include_intransit_move_orders
  ,      clcrb.tolerance_percent
  FROM   csp_loop_calc_rules_b clcrb
  ,      csp_parts_loops_b cplb
  WHERE  cplb.parts_loop_id = p_parts_loop_id
  AND    cplb.calculation_rule_id = clcrb.calculation_rule_id;

  /*CURSOR c_supply_demand IS
  SELECT decode(l_include_intransit_mo,'Y',nvl(ccsds.intransit_move_orders,0),0)
  +      decode(l_include_interorg_transfers,'Y',nvl(ccsds.open_interorg_transf_in,0)-nvl(ccsds.open_interorg_transf_out,0),0)
  +      decode(l_include_sales_orders,'Y',nvl(ccsds.open_sales_orders,0),0)
  +      decode(l_include_move_orders,'Y',nvl(ccsds.open_move_orders_in,0)-nvl(ccsds.open_move_orders_out,0),0)
  +      decode(l_include_requisitions,'Y',nvl(ccsds.open_requisitions,0),0)
  +      decode(l_include_purchase_orders,'Y',nvl(ccsds.open_purchase_orders,0),0)
  +      decode(l_include_work_orders,'Y',nvl(ccsds.open_work_orders,0),0)
  +      decode(l_include_onhand_good,'Y',nvl(ccsds.onhand_good,0),0)
  +      decode(l_include_onhand_bad,'Y',nvl(ccsds.onhand_bad,0),0) quantity_level
  ,      ccsds.onhand_good
  ,      cmsi.total_loop_min_good_quantity
  ,      cmsi.total_loop_quantity
  FROM   csp_mstrstck_lists_itms cmsi
  ,      csp_curr_sup_dem_sums ccsds
  WHERE  parts_loop_id = p_parts_loop_id
  AND    subinventory_code is null
  AND    ccsds.parts_loop_id = cmsi.parts_loops_id
  AND    ccsds.inventory_item_id = cmsi.inventory_item_id
  AND    ccsds.inventory_item_id = nvl(p_inventory_item_id,ccsds.inventory_item_id);*/
/*
  CURSOR c_supply_demand IS
  SELECT decode(l_include_intransit_mo,'Y',nvl(ccsds.intransit_move_orders,0),0)
  +      decode(l_include_interorg_transfers,'Y',nvl(ccsds.open_interorg_transf_in,0)-nvl(ccsds.open_interorg_transf_out,0),0)
  +      decode(l_include_sales_orders,'Y',nvl(ccsds.open_sales_orders,0),0)
  +      decode(l_include_move_orders,'Y',nvl(ccsds.open_move_orders_in,0)-nvl(ccsds.open_move_orders_out,0),0)
  +      decode(l_include_requisitions,'Y',nvl(ccsds.open_requisitions,0),0)
  +      decode(l_include_purchase_orders,'Y',nvl(ccsds.open_purchase_orders,0),0)
  +      decode(l_include_work_orders,'Y',nvl(ccsds.open_work_orders,0),0)
  +      decode(l_include_onhand_good,'Y',nvl(ccsds.onhand_good,0),0)
  +      decode(l_include_onhand_bad,'Y',nvl(ccsds.onhand_bad,0),0) quantity_level
  ,      nvl(ccsds.onhand_good,0)
  ,      nvl(cmsi.total_loop_min_good_quantity,0)
  ,      nvl(cmsi.total_loop_quantity,0)
  FROM   csp_mstrstck_lists_itms cmsi
  ,      csp_curr_sup_dem_sums ccsds
  WHERE  cmsi.parts_loops_id = p_parts_loop_id
  AND    ccsds.parts_loop_id(+) = cmsi.parts_loops_id
  AND    ccsds.subinventory_code(+) is null
  AND    cmsi.inventory_item_id = p_inventory_item_id
  AND    ccsds.inventory_item_id(+) = cmsi.inventory_item_id;
*/
  CURSOR c_supply_demand IS
  SELECT decode(l_include_intransit_mo,'Y',nvl(ccsds.intransit_move_orders,0),0)
  +      decode(l_include_interorg_transfers,'Y',nvl(ccsds.interorg_transf_in,0)-nvl(ccsds.interorg_transf_out,0),0)
  +      decode(l_include_sales_orders,'Y',nvl(ccsds.sales_orders,0),0)
  +      decode(l_include_move_orders,'Y',nvl(ccsds.move_orders_in,0)-nvl(ccsds.move_orders_out,0),0)
  +      decode(l_include_requisitions,'Y',nvl(ccsds.requisitions,0),0)
  +      decode(l_include_purchase_orders,'Y',nvl(ccsds.purchase_orders,0),0)
  +      decode(l_include_work_orders,'Y',nvl(ccsds.work_orders,0),0)
  +      decode(l_include_onhand_good,'Y',nvl(ccsds.onhand_good,0),0)
  +      decode(l_include_onhand_bad,'Y',nvl(ccsds.onhand_bad,0),0) quantity_level
  ,      nvl(ccsds.onhand_good,0)
  ,      nvl(cmsi.total_loop_min_good_quantity,0)
  ,      nvl(cmsi.total_loop_quantity,0)
  FROM   csp_mstrstck_lists_itms cmsi
  ,      CSP_SUP_DEM_PL_MV ccsds
  WHERE  cmsi.parts_loops_id = p_parts_loop_id
  AND    ccsds.parts_loop_id(+) = cmsi.parts_loops_id
  AND    cmsi.inventory_item_id = p_inventory_item_id
  AND    ccsds.inventory_item_id(+) = cmsi.inventory_item_id;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   calculate_loop_pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version   ,
                                        p_api_version   ,
                                        l_api_name      ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_include_move_orders is null THEN
      OPEN  c_calculation_rule;
      FETCH c_calculation_rule into
        l_include_sales_orders
      , l_include_move_orders
      , l_include_work_orders
      , l_include_purchase_orders
      , l_include_requisitions
      , l_include_interorg_transfers
      , l_include_onhand_good
      , l_include_onhand_bad
      , l_include_intransit_mo
      , l_tolerance_percent;
      CLOSE c_calculation_rule;
    ELSE
      l_include_sales_orders            := p_include_sales_orders;
      l_include_move_orders             := p_include_move_orders;
      l_include_work_orders             := p_include_work_orders;
      l_include_purchase_orders         := p_include_purchase_orders;
      l_include_requisitions            := p_include_requisitions;
      l_include_interorg_transfers      := p_include_interorg_transfers;
      l_include_onhand_good             := p_include_onhand_good;
      l_include_onhand_bad              := p_include_onhand_bad;
      l_include_intransit_mo            := p_include_intransit_mo;
      l_tolerance_percent               := p_tolerance_percent;
    END IF;

    OPEN  c_supply_demand;
    FETCH c_supply_demand into l_quantity_level, l_onhand_good, l_min_good, l_total_loop_quantity;
    CLOSE c_supply_demand;

    x_above := l_quantity_level - (l_total_loop_quantity*(1+nvl(l_tolerance_percent,0)/100));
    x_below := l_total_loop_quantity - (l_total_loop_quantity*nvl(l_tolerance_percent,0)/100) - l_quantity_level;
    x_not_enough_good_parts  := l_min_good - l_onhand_good;
    x_quantity_level := l_quantity_level;
    x_onhand_good := l_onhand_good;
    x_min_good := l_min_good;
    x_total_loop_quantity := l_total_loop_quantity;

    /*dbms_output.put_line(p_inventory_item_id || '   ' || 'x_above' || x_above || 'x_below ' || x_below ||
                         x_not_enough_good_parts || '   ' ||  x_quantity_level || '  ' || x_onhand_good);*/

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count            =>      x_msg_count ,
         p_data             =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO calculate_loop_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count ,
             p_data             =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO calculate_loop_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count ,
             p_data             =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO calculate_loop_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME  ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count ,
             p_data             =>      x_msg_data
            );
END calculate_loop;

PROCEDURE create_notifications
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id       IN  NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'create_notifications';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_parts_loop_id                csp_parts_loops_b.parts_loop_id%TYPE;
  l_above                        NUMBER;
  l_below                        NUMBER;
  l_not_enough_good_parts        NUMBER;
  l_quantity_level               NUMBER;
  l_onhand_good                  NUMBER;
  l_min_good                     NUMBER;
  l_total_loop_quantity          NUMBER;
  l_return_status                VARCHAR2(1);
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_notification_id              NUMBER;
  l_cursor                      NUMBER;
  l_ddl_string                  VARCHAR2(100);
  l_planner_code			  VARCHAR2(10);
  l_temp_inv_item_id          NUMBER;

  CURSOR c_parts_loops IS
  SELECT cplb.parts_loop_id
  ,      cplb.planner_code
  ,      cplb.organization_id
  ,      clcrb.include_sales_orders
  ,      clcrb.include_move_orders
  ,      clcrb.include_work_orders
  ,      clcrb.include_purchase_orders
  ,      clcrb.include_requisitions
  ,      clcrb.include_interorg_transfers
  ,      clcrb.include_onhand_good
  ,      clcrb.include_onhand_bad
  ,      clcrb.include_intransit_move_orders
  ,      clcrb.tolerance_percent
  FROM   csp_loop_calc_rules_b clcrb
  ,      csp_parts_loops_b cplb
  WHERE  cplb.calculation_rule_id = clcrb.calculation_rule_id;

  /*CURSOR c_items(c_parts_loop_id NUMBER) IS
  SELECT ccsds.inventory_item_id
  FROM   csp_curr_sup_dem_sums ccsds
  WHERE  parts_loop_id = c_parts_loop_id
  AND    subinventory_code is null;*/

  CURSOR c_items(c_parts_loop_id NUMBER) IS
  SELECT INVENTORY_ITEM_ID inventory_item_id
  FROM   CSP_MSTRSTCK_LISTS_ITMS
  WHERE  PARTS_LOOPS_ID =  c_parts_loop_id;

  CURSOR get_planner(c_parts_loop_id        number,
                     c_inventory_item_id    number) IS
  SELECT planner_code
  FROM   csp_mstrstck_lists_itms
  WHERE  parts_loops_id = c_parts_loop_id
  AND    inventory_item_id = c_inventory_item_id;
     l_get_app_info           boolean;
     l_status                 varchar2(1);
     l_industry               varchar2(1);
     l_oracle_schema          varchar2(30);
BEGIN
    l_get_app_info := fnd_installation.get_app_info('CSP',l_status,l_industry, l_oracle_schema);
    l_ddl_string := 'truncate table '||l_oracle_schema||'.csp_notifications';
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor,l_ddl_string,dbms_sql.native);
    dbms_sql.close_cursor(l_cursor);

    -- Standard Start of API savepoint
    SAVEPOINT   create_notifications_pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version   ,
                                        p_api_version   ,
                                        l_api_name      ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
--    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cr IN c_parts_loops LOOP
      FOR curs IN c_items(cr.parts_loop_id) LOOP

        open  get_planner(cr.parts_loop_id,curs.inventory_item_id);
        fetch get_planner into l_planner_code;
        close get_planner;

        csp_notifications_pvt.calculate_loop(
          p_api_version                     => 1.0,
          p_parts_loop_id                   => cr.parts_loop_id,
          p_inventory_item_id               => curs.inventory_item_id,
          p_include_intransit_mo            => cr.include_intransit_move_orders,
          p_include_interorg_transfers      => cr.include_interorg_transfers,
          p_include_sales_orders            => cr.include_sales_orders,
          p_include_move_orders             => cr.include_move_orders,
          p_include_requisitions            => cr.include_requisitions,
          p_include_purchase_orders         => cr.include_purchase_orders,
          p_include_work_orders             => cr.include_work_orders,
          p_include_onhand_good             => cr.include_onhand_good,
          p_include_onhand_bad              => cr.include_onhand_bad,
          p_tolerance_percent               => cr.tolerance_percent,
          x_above                           => l_above,
          x_below                           => l_below,
          x_not_enough_good_parts           => l_not_enough_good_parts,
          x_quantity_level                  => l_quantity_level,
          x_onhand_good                     => l_onhand_good,
          x_min_good                        => l_min_good,
          x_total_loop_quantity             => l_total_loop_quantity,
          x_return_status                   => l_return_status,
          x_msg_count                       => l_msg_count,
          x_msg_data                        => l_msg_data
        );

        IF l_above > 0 THEN
          l_notification_id := null;
          csp_notifications_pkg.insert_row(
            px_notification_id  => l_notification_id,
            p_created_by        => fnd_global.user_id,
            p_creation_date     => sysdate,
            p_last_updated_by   => fnd_global.user_id,
            p_last_update_date  => sysdate,
            p_last_update_login => null,
            p_planner_code      => l_planner_code,
            p_parts_loop_id     => cr.parts_loop_id,
            p_organization_id   => cr.organization_id,
            p_inventory_item_id => curs.inventory_item_id,
            p_notification_date => sysdate,
            p_reason            => 'A',
            p_status            => '1',
            p_quantity          => l_quantity_level - l_total_loop_quantity,
            p_attribute_category=> null,
            p_attribute1        => null,
            p_attribute2        => null,
            p_attribute3        => null,
            p_attribute4        => null,
            p_attribute5        => null,
            p_attribute6        => null,
            p_attribute7        => null,
            p_attribute8        => null,
            p_attribute9        => null,
            p_attribute10       => null,
            p_attribute11       => null,
            p_attribute12       => null,
            p_attribute13       => null,
            p_attribute14       => null,
            p_attribute15       => null);
        END IF;
        IF l_below > 0 THEN
          l_notification_id := null;
          csp_notifications_pkg.insert_row(
            px_notification_id  => l_notification_id,
            p_created_by        => fnd_global.user_id,
            p_creation_date     => sysdate,
            p_last_updated_by   => fnd_global.user_id,
            p_last_update_date  => sysdate,
            p_last_update_login => null,
            p_planner_code      => l_planner_code,
            p_parts_loop_id     => cr.parts_loop_id,
            p_organization_id   => cr.organization_id,
            p_inventory_item_id => curs.inventory_item_id,
            p_notification_date => sysdate,
            p_reason            => 'B',
            p_status            => '1',
            p_quantity          => l_total_loop_quantity - l_quantity_level,
            p_attribute_category=> null,
            p_attribute1        => null,
            p_attribute2        => null,
            p_attribute3        => null,
            p_attribute4        => null,
            p_attribute5        => null,
            p_attribute6        => null,
            p_attribute7        => null,
            p_attribute8        => null,
            p_attribute9        => null,
            p_attribute10       => null,
            p_attribute11       => null,
            p_attribute12       => null,
            p_attribute13       => null,
            p_attribute14       => null,
            p_attribute15       => null);
        END IF;
        IF l_not_enough_good_parts > 0 THEN
          l_notification_id := null;
          csp_notifications_pkg.insert_row(
            px_notification_id  => l_notification_id,
            p_created_by        => fnd_global.user_id,
            p_creation_date     => sysdate,
            p_last_updated_by   => fnd_global.user_id,
            p_last_update_date  => sysdate,
            p_last_update_login => null,
            p_planner_code      => l_planner_code,
            p_parts_loop_id     => cr.parts_loop_id,
            p_organization_id   => cr.organization_id,
            p_inventory_item_id => curs.inventory_item_id,
            p_notification_date => sysdate,
            p_reason            => 'N',
            p_status            => '1',
            p_quantity          => l_not_enough_good_parts,
            p_attribute_category=> null,
            p_attribute1        => null,
            p_attribute2        => null,
            p_attribute3        => null,
            p_attribute4        => null,
            p_attribute5        => null,
            p_attribute6        => null,
            p_attribute7        => null,
            p_attribute8        => null,
            p_attribute9        => null,
            p_attribute10       => null,
            p_attribute11       => null,
            p_attribute12       => null,
            p_attribute13       => null,
            p_attribute14       => null,
            p_attribute15       => null);
        END IF;
      END LOOP;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
--    FND_MSG_PUB.Count_And_Get
--        (p_count            =>      x_msg_count ,
--        p_data             =>      x_msg_data
--        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_notifications_pvt;
--        x_return_status := FND_API.G_RET_STS_ERROR ;
--        FND_MSG_PUB.Count_And_Get
--            (p_count            =>      x_msg_count ,
--             p_data             =>      x_msg_data
--            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_notifications_pvt;
--        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--        FND_MSG_PUB.Count_And_Get
--            (p_count            =>      x_msg_count ,
--             p_data             =>      x_msg_data
--            );
    WHEN OTHERS THEN
        ROLLBACK TO create_notifications_pvt;
--        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME  ,
                        l_api_name
                );
        END IF;
--        FND_MSG_PUB.Count_And_Get
--            (p_count            =>      x_msg_count ,
--             p_data             =>      x_msg_data
--            );
END create_notifications;
END csp_notifications_pvt;

/
