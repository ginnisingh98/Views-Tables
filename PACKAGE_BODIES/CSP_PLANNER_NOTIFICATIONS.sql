--------------------------------------------------------
--  DDL for Package Body CSP_PLANNER_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PLANNER_NOTIFICATIONS" AS
/* $Header: cspvppnb.pls 120.0.12010000.2 2009/03/09 16:37:29 hhaugeru ship $ */
--
-- Purpose: This package will hold all APIs related to the creation of
--          planner notifications and recommendations for the notifications
--
-- MODIFICATION HISTORY
-- Person      Date              Comments
-- phegde      16th April 2002   Created new Package body

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csp_planner_notification';

  -- Start of Forward declarations

  PROCEDURE Build_Range_Sql
        ( p_cat_structure_id IN            NUMBER
        , p_cat_lo           IN            VARCHAR2
        , p_cat_hi           IN            VARCHAR2
        , p_item_lo          IN            VARCHAR2
        , p_item_hi          IN            VARCHAR2
        , p_planner_lo       IN            VARCHAR2
        , p_planner_hi       IN            VARCHAR2
        , p_lot_ctl          IN            NUMBER
        , x_range_sql        OUT NOCOPY           VARCHAR2
        );

  PROCEDURE Build_item_cat_select(p_Cat_structure_id IN NUMBER
                                 ,x_item_select   OUT NOCOPY VARCHAR2
                                 ,x_cat_Select    OUT NOCOPY VARCHAR2
                                 );

  PROCEDURE re_po(  item_id          IN   NUMBER
                   , qty              IN   NUMBER
                   , nb_time          IN   DATE
                   , uom              IN   VARCHAR2
                   , accru_acct       IN   NUMBER
                   , ipv_acct         IN   NUMBER
                   , budget_acct      IN   NUMBER
                   , charge_acct      IN   NUMBER
                   , purch_flag       IN   VARCHAR2
                   , order_flag       IN   VARCHAR2
                   , transact_flag    IN   VARCHAR2
                   , unit_price       IN   NUMBER
                   , user_id          IN   NUMBER
                   , sysd             IN   DATE
                   , organization_id  IN   NUMBER
                   , approval         IN   NUMBER
                   , src_type         IN   NUMBER
                   , encum_flag       IN   VARCHAR2
                   , customer_id      IN   NUMBER
                   , employee_id      IN   NUMBER
                   , description      IN   VARCHAR2
                   , src_org          IN   NUMBER
                   , src_subinv       IN   VARCHAR2
                   , subinv           IN   VARCHAR2
                   , location_id      IN   NUMBER
                   , po_org_id        IN   NUMBER
                   , p_pur_revision   IN   NUMBER
                   , x_ret_stat       OUT NOCOPY  VARCHAR2
                   , x_ret_mesg       OUT NOCOPY  VARCHAR2);

  PROCEDURE re_wip( item_id          IN   NUMBER
                  , qty              IN   NUMBER
                  , nb_time          IN   DATE
                  , uom              IN   VARCHAR2
                  , wip_id           IN   NUMBER
                  , user_id          IN   NUMBER
                  , sysd             IN   DATE
                  , organization_id  IN   NUMBER
                  , approval         IN   NUMBER
                  , build_in_wip     IN   VARCHAR2
                  , pick_components  IN   VARCHAR2
                  , x_ret_stat       OUT NOCOPY  VARCHAR2
                  , x_ret_mesg       OUT NOCOPY  VARCHAR2) ;

  PROCEDURE Create_Notification_Details(
                 p_source_type      IN  VARCHAR2
                ,p_order_by_dt      IN  DATE := sysdate
                ,p_notification_id  IN  NUMBER
                ,p_parts_rec        IN  csp_planner_notifications.excess_parts_rectype);

  PROCEDURE Generate_Repair_Recomm(
                 p_notification_id   IN     NUMBER
                ,p_organization_id   IN     NUMBER
                ,p_inventory_item_id IN     NUMBER
                ,p_order_by_date     IN     DATE
                ,p_supercess_item_yn IN     VARCHAR2
                );

  PROCEDURE Cleanup_Notifications(p_organization_id   NUMBER);

  -- End of forward declarations

  PROCEDURE Create_Notifications
     ( errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_api_version            IN NUMBER
      ,p_organization_id        IN NUMBER
      ,p_level			        IN NUMBER
      ,p_notif_for_io           IN NUMBER
      ,p_notif_for_po           IN NUMBER
      ,p_notif_for_wip          IN NUMBER
      ,p_category_set_id        IN NUMBER
      ,p_category_struct_id	    IN NUMBER
      ,p_Category_lo            IN VARCHAR2
      ,p_category_hi            IN VARCHAR2
      ,p_item_lo                IN VARCHAR2
      ,p_item_hi                IN VARCHAR2
      ,p_planner_lo             IN VARCHAR2
      ,p_planner_hi             IN VARCHAR2
      ,p_buyer_lo               IN VARCHAR2
      ,p_buyer_hi               IN VARCHAR2
      ,p_d_cutoff_date          IN VARCHAR2
      ,p_d_offset               IN NUMBER
      ,p_s_cutoff_date          IN VARCHAR2
      ,p_s_offset               IN NUMBER
      ,p_restock                IN NUMBER
      ,p_repitem                IN VARCHAR2
      ,p_dd_loc_id              IN NUMBER  -- default deliver to loc
      ,p_net_rsv                IN NUMBER
      ,p_net_unrsv              IN NUMBER
      ,p_net_wip                IN NUMBER
      ,p_include_po             IN NUMBER
      ,p_include_wip            IN NUMBER
      ,p_include_iface_sup      IN NUMBER
      ,p_include_nonnet_sub     IN NUMBER
      ,p_lot_control            IN NUMBER
      ,p_sort                   IN VARCHAR2 := '1'
  ) IS
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'create_notifications';
  l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_user_id                 NUMBER;
  l_login_id                NUMBER;
  l_today                   DATE;
  l_employee_id             NUMBER;
  l_Restock                 NUMBER;
  l_d_cutoff                DATE;
  l_s_cutoff                DATE;
  l_po_org_id               NUMBER;
  l_org_name                VARCHAR2(240);
  l_encum_flag              VARCHAR2(30) := 'N';
  l_cal_code                VARCHAR2(240);
  l_exception_set_id        NUMBER;
  l_mcat_struct_id          NUMBER;
  l_category_set_id         NUMBER;
  l_range_buyer             VARCHAR2(240) := '1=1';
  l_range_sql               VARCHAR2(2000);
  l_item_select             VARCHAr2(800);
  l_Cat_Select              VARCHAR2(800);
  l_order_by                VARCHAr2(30);
  l_cust_id                 NUMBER;
  l_wip_batch_id            NUMBER;
  error_message             VARCHAR2(80);
  l_need_by_date            DATE;
  l_order_by_date           DATE;
  l_est_date                DATE;
  l_lead_time               NUMBER;
  l_notification_id         NUMBER;
  l_count                   NUMBER;
  l_header_rec              csp_parts_requirement.header_Rec_type;
  l_line_Tbl                csp_parts_requirement.line_tbl_type;
  l_related_item            NUMBER;

  CURSOR employee_id_cur IS
     SELECT employee_id
     FROM fnd_user
     WHERE user_id = l_user_id;

  CURSOR minmax_rslts_cur IS
    SELECT   ITEM_SEGMENTS
           , DESCRIPTION
           , ERROR
           , SORTEE
           , MIN_QTY
           , MAX_QTY
           , ONHAND_QTY
           , SUPPLY_QTY
           , DEMAND_QTY
           , TOT_AVAIL_QTY
           , MIN_ORD_QTY
           , MAX_ORD_QTY
           , FIX_MULT
           , REORD_QTY
    FROM INV_MIN_MAX_TEMP;

  l_minmax_rslts_rec  minmax_rslts_cur%ROWTYPE;

  CURSOR item_attr_cur(p_item_Segments VARCHAR2,
                       p_organization_id NUMBER) IS
    SELECT c.description                     description,
           c.repetitive_planning_flag        repetitive_planned_item,
           c.fixed_lead_time                 fixed_lead_time,
           c.variable_lead_time              variable_lead_time,
           NVL(c.preprocessing_lead_time, 0) +
           NVL(c.full_lead_time, 0) +
           NVL(c.postprocessing_lead_time, 0) buying_lead_time,
           c.primary_uom_code                primary_uom,
           p.ap_accrual_account              accru_acct,
           p.invoice_price_var_account       ipv_acct,
           NVL(c.encumbrance_account, p.encumbrance_account)  budget_acct,
           DECODE(c.inventory_asset_flag, 'Y', p.material_account,
                  NVL(c.expense_account, p.expense_account))  charge_acct,
           NVL(c.source_type, p.source_type) src_type,
           DECODE(c.source_type, NULL,
                  DECODE(p.source_type, NULL, NULL, p.source_organization_id),
                         c.source_organization_id)   src_org,
           DECODE(c.source_type, NULL,
                  DECODE(p.source_type, NULL, NULL, p.source_subinventory),
                            c.source_subinventory)   src_subinv,
           c.purchasing_enabled_flag         purch_flag,
           c.internal_order_enabled_flag     order_flag,
           c.mtl_transactions_enabled_flag   transact_flag,
           c.list_price_per_unit             unit_price,
           c.planning_make_buy_code          mbf,
           c.inventory_item_id               item_id,
           c.planner_code                    planner,
           build_in_wip_flag                 build_in_wip,
           pick_components_flag              pick_components
    FROM mtl_system_items_kfv c,
         mtl_parameters p
    WHERE c.concatenated_segments = p_item_Segments
    AND   c.organization_id = p.organization_id
    AND   p.organization_id = p_organization_id;

    CURSOR open_notifs_cur IS
      SELECT notification_id,
             inventory_item_id,
             notification_type,
             quantity,
             need_date
      FROM csp_notifications
      WHERE organization_id = p_organization_id;

    CURSOR supercess_items_cur(p_item_id NUMBER) IS
    SELECT inventory_item_id
    FROM mtl_related_items_view
    WHERE relationship_type_id = 18
    AND related_item_id = p_item_id;

    l_item_attr_rec     item_attr_cur%ROWTYPE;

  BEGIN
    SAVEPOINT Create_Notifications_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize return status, get audit columns
    --x_return_status := FND_API.G_RET_STS_SUCCESS;
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id := nvl(fnd_global.user_id, 0) ;
    l_login_id := nvl(fnd_global.login_id, -1);

    Cleanup_Notifications(p_organization_id);

    IF (p_notif_for_io = 2 and p_notif_for_po = 2 and
        p_notif_for_wip = 2 and p_restock = 2) THEN
    -- no notifications, no restock, so just return
      return;
    ELSIF (p_notif_for_io = 2 and p_notif_for_po = 2 and
           p_notif_for_wip = 2 and p_Restock = 1) THEN
    -- no notifications, restock = yes, just call run min_mx with restock = yes
      l_restock := 1;
    ELSE
    -- notifications for atleast one type is yes, call run min_max with
    -- restock = no, create notifications after min_max is run.
      l_restock := 2;
    END IF;

    -- 1. get values of all parameters for calling run_min_max_plan
    if p_restock = 1 and p_dd_loc_id is null then
    begin
      Select MEANING
      into error_message
      FROM MFG_LOOKUPS
      WHERE LOOKUP_TYPE='INV_MMX_RPT_MSGS'
      and LOOKUP_CODE = 4;
    exception
      when others then
        null;
    end;
      --x_Return_status := 'E';
    end if;

    -- get employee id
    OPEN employee_id_cur;
    FETCH employee_id_cur INTO l_employee_id;
    CLOSE employee_id_cur;
    l_d_cutoff := to_date(p_d_cutoff_date,'YYYY/MM/DD HH24:MI:SS');
    l_s_cutoff := to_date(p_s_cutoff_date,'YYYY/MM/DD HH24:MI:SS');
    l_D_CUTOFF := NVL(l_D_CUTOFF, SYSDATE);
    l_S_CUTOFF := NVL(l_S_CUTOFF, SYSDATE);

    IF (P_D_OFFSET IS NOT NULL) THEN
	  l_D_CUTOFF := NVL(l_D_CUTOFF, sysdate) + P_D_OFFSET;
    END IF;

    IF (P_S_OFFSET IS NOT NULL) THEN
	  l_S_CUTOFF := NVL(l_S_CUTOFF, sysdate) + P_S_OFFSET;
    END IF;

    /* get encum flag, org name, PO org ID */
    declare
      l_operating_unit number;
    begin

      select operating_unit, substr(organization_name,1,30), operating_unit
      into l_operating_unit, l_org_name, l_po_org_id
      from org_organization_definitions
      where organization_id = p_organization_id;

      select nvl(req_encumbrance_flag, 'N')
      into l_encum_flag
      from financials_system_params_all
      where  nvl(org_id,-11)=nvl(l_operating_unit,-11);

    end;

    /* get calendar */
    select p.calendar_code, p.calendar_exception_set_id
    into l_cal_code, l_exception_set_id
    from mtl_parameters p
    where p.organization_id = p_organization_id;

    /* Validate cat set and MCAT struct */
    IF (p_category_set_id is not null and p_category_struct_id is not null) then
      SELECT STRUCTURE_ID
      into l_mcat_struct_id
      FROM MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = p_category_set_id;
    ELSE
      SELECT CSET.CATEGORY_SET_ID, CSET.STRUCTURE_ID
      INTO l_category_set_id, l_mcat_struct_id
      FROM   MTL_CATEGORY_SETS CSET,
      MTL_DEFAULT_CATEGORY_SETS DEF
      WHERE  DEF.CATEGORY_SET_ID = CSET.CATEGORY_SET_ID
      AND    DEF.FUNCTIONAL_AREA_ID = 1;
    END IF;

    IF p_buyer_lo is not null and p_buyer_hi is not null then
      L_RANGE_BUYER := 'v.full_name between ' ||''''||P_BUYER_LO||
                       '''' || ' and ' || ''''||P_BUYER_HI||'''';
    ELSIF p_BUYER_lo is not null then
      L_RANGE_BUYER := 'v.full_name >= ' ||''''||P_BUYER_LO||'''';
    ELSIF p_BUYER_hi is not null then
      L_RANGE_BUYER := 'v.full_name <= ' ||''''||P_BUYER_HI||'''';
    END IF;

    /* set order by clause */

    IF P_sort=1 then
      l_order_by := ' order by 1';
    ELSIF P_sort = 2  then
      l_order_by := ' order by 13,1';
    ELSIF P_sort = 3  then
      l_order_by := ' order by 11,1';
    ELSIF P_sort = 4  then
      l_order_by := ' order by 12,1';
    END IF;

    Build_item_cat_select(
            p_Cat_Structure_id => l_mcat_struct_id,
            x_item_select => l_item_Select,
            x_cat_Select => l_cat_select);

    Build_range_sql(
          p_cat_structure_id => l_mcat_Struct_id
        , p_cat_lo           => p_Category_lo
        , p_cat_hi           => p_category_hi
        , p_item_lo          => p_item_lo
        , p_item_hi          => p_item_hi
        , p_planner_lo       => p_planner_lo
        , p_planner_hi       => p_planner_hi
        , p_lot_ctl          => p_lot_Control
        , x_range_sql        => l_range_sql);

    IF p_dd_loc_id is not null THEN
      -- get customer id
      BEGIN
        select customer_id
        into l_cust_id
        from po_location_associations
        where location_id = P_dd_loc_id;
      EXCEPTION
        when no_data_found then
          l_cust_id := 0;
      END;
    END IF;

    select WIP_JOB_SCHEDULE_INTERFACE_S.nextval
    into l_WIP_BATCH_ID
    from dual;

    -- call to min_max API
    CSP_MINMAX_PVT.run_min_max_plan (
              p_item_select     => l_item_select
            , p_handle_rep_item => p_repitem
            , p_pur_revision    => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
            , p_cat_select      => l_Cat_select
            , p_cat_set_id      => p_Category_set_id
            , p_mcat_struct     => l_mcat_struct_id
            , p_level           => 1   -- always run at organization level
            , p_restock         => l_Restock
            , p_include_nonnet  => p_include_nonnet_sub
            , p_include_po      => p_include_po
            , p_include_wip     => p_include_wip
            , p_include_if      => p_include_iface_sup
            , p_net_rsv         => p_net_rsv
            , p_net_unrsv       => p_net_unrsv
            , p_net_wip         => p_net_wip
            , p_org_id          => p_organization_id
            , p_user_id         => l_user_id
            , p_employee_id     => l_employee_id
            , p_subinv          => null
            , p_dd_loc_id       => p_dd_loc_id
            , p_wip_batch_id    => l_wip_batch_id
            , p_approval        => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
            , p_buyer_hi        => p_buyer_hi
            , p_buyer_lo        => p_buyer_lo
            , p_range_buyer     => l_range_buyer
            , p_cust_id         => l_cust_id
            , p_po_org_id       => l_po_org_id
            , p_range_sql       => l_range_Sql
            , p_sort            => p_sort
            , p_selection       => 1    -- items under minimum quantity
            , p_sysdate         => l_today
            , p_s_cutoff        => l_s_cutoff
            , p_d_cutoff        => l_d_cutoff
            , p_order_by        => l_order_by
            , p_encum_flag      => l_encum_flag
            , p_cal_code        => l_cal_code
            , p_exception_set_id => l_exception_set_id
            , x_return_status   => l_Return_status
            , x_msg_data        => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 3. if p_restock is 'yes', and notifications for any src type is yes
    -- create notifications for that src type and restock the rest

    IF (l_Restock = 2) THEN -- inventory min-max did not restock

      FOR l_index IN minmax_rslts_cur LOOP
        OPEN item_Attr_cur(l_index.ITEM_SEGMENTS, p_organization_id);
        FETCH item_Attr_cur into l_item_attr_rec;
        CLOSE item_attr_cur;

        -- check if item is on a suppressed notification
        begin
          SELECT count(inventory_item_id)
          INTO l_count
          FROM csp_notifications
          WHERE organization_id = p_organization_id
          AND   inventory_item_id = l_item_attr_rec.item_id
          AND   nvl(suppress_end_date, sysdate) >= sysdate;
        exception
          when others then
            null;
        end;

        IF (l_count = 0) THEN -- only if item is not on suppresses notif
          -- calculate need by date based on usage
          csp_auto_aslmsl_pvt.calculate_needby_date
                (p_api_version_number   => 1.0,
                 p_init_msg_list        => FND_API.G_FALSE,
                 p_commit               => FND_API.G_FALSE,
                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                 p_inventory_item_id    => l_item_attr_rec.item_id,
                 p_organization_id      => p_organization_id,
                 p_onhand_quantity      => l_index.tot_Avail_qty,
                 x_needby_date          => l_need_by_date,
                 x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_item_attr_rec.repetitive_planned_item = 'Y' AND p_repitem = 1) OR
             (l_item_attr_rec.repetitive_planned_item = 'N' AND l_item_attr_rec.mbf = 2) THEN
            IF (l_need_by_date IS NULL) THEN
              SELECT c1.calendar_date
              INTO   l_need_by_date
              FROM bom_calendar_dates c1,
                   bom_calendar_dates c
              WHERE  c1.calendar_code    = c.calendar_code
              AND  c1.exception_set_id = c.exception_set_id
              AND  c1.seq_num          = c.next_seq_num + CEIL(l_item_attr_rec.buying_lead_time)
              AND  c.calendar_code     = l_cal_code
              AND  c.exception_set_id  = l_exception_set_id
              AND  c.calendar_date     = trunc(sysdate);

            END If;

            -- since we are planning at org level, if source_type is Subinventory
            -- no action is taken
            IF l_item_attr_rec.src_type = 3 THEN
              null;
            ELSIF (l_item_Attr_Rec.src_type = 1) THEN
            -- if source type is 1-Inventory, internal purchase req
              IF (p_notif_for_io = 1) THEN
                -- create notifications for IO
                l_notification_id := null;
                csp_notifications_pkg.insert_row(
                    px_notification_id  => l_notification_id,
                    p_created_by        => l_user_id,
                    p_creation_date     => sysdate,
                    p_last_updated_by   => l_user_id,
                    p_last_update_date  => sysdate,
                    p_last_update_login => l_login_id,
                    p_planner_code      => l_item_attr_rec.planner,
                    p_parts_loop_id     => null,
                    p_organization_id   => p_organization_id,
                    p_inventory_item_id => l_item_attr_rec.item_id,
                    p_notification_date => sysdate,
                    p_reason            => 'N',
                    p_status            => '1',
                    p_quantity          => l_index.reord_qty,
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
                    p_attribute15       => null,
                    p_need_date         => l_need_by_date,
                    p_suppress_end_date => null,
                    p_notification_type => 'IO');

              ELSIF (p_Restock = 1) THEN -- restock only if p_restock is yes.
                -- call process_order for creating internal orders
                l_header_rec.dest_organization_id :=  p_organization_id;
                l_header_Rec.need_by_date := l_need_by_date;
                l_header_rec.operation := 'CREATE';
                l_header_rec.ship_to_location_id := p_dd_loc_id;
                FND_PROFILE.GET('CSP_ORDER_TYPE', l_header_rec.order_type_id);

                l_line_tbl(1).line_num := 1;
                l_line_tbl(1).inventory_item_id := l_item_attr_rec.item_id;
                l_line_tbl(1).quantity := l_index.reord_qty;
                l_line_tbl(1).ordered_quantity := l_index.reord_qty;
                l_line_Tbl(1).unit_of_measure := l_item_Attr_rec.primary_uom;
                l_line_Tbl(1).source_organization_id := l_item_Attr_rec.src_org;
                l_line_Tbl(1).source_subinventory := l_item_attr_Rec.src_subinv;
                l_line_tbl(1).booked_flag := 'Y';

                -- call process order
                csp_parts_order.process_order(
                     p_api_version              => l_api_Version_number
                    ,p_Init_Msg_List           => null
                    ,p_commit                  => null
                    ,px_header_rec             => l_header_Rec
                    ,px_line_table             => l_Line_Tbl
                    ,p_process_type            => 'BOTH'
                    ,x_return_status           => l_return_status
                    ,x_msg_count               => l_msg_count
                    ,x_msg_data                => l_msg_data
                );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
              END IF;
            ELSIF (l_item_attr_rec.src_type = 2) THEN
            -- if source type is 2-Supplier, external purchase req.
              IF (p_notif_for_po = 1) THEN
                -- create notifications for PO
                l_notification_id := null;
                csp_notifications_pkg.insert_row(
                    px_notification_id  => l_notification_id,
                    p_created_by        => l_user_id,
                    p_creation_date     => sysdate,
                    p_last_updated_by   => l_user_id,
                    p_last_update_date  => sysdate,
                    p_last_update_login => l_login_id,
                    p_planner_code      => l_item_attr_rec.planner,
                    p_parts_loop_id     => null,
                    p_organization_id   => p_organization_id,
                    p_inventory_item_id => l_item_attr_rec.item_id,
                    p_notification_date => sysdate,
                    p_reason            => 'N',
                    p_status            => '1',
                    p_quantity          => l_index.reord_qty,
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
                    p_attribute15       => null,
                    p_need_date         => l_need_by_date,
                    p_suppress_end_date => null,
                    p_notification_type => 'PO');

              ELSIF (p_restock = 1) THEN
                -- call re_po for creating pur req.
                re_po(
                     item_id          => l_item_attr_rec.item_id
                   , qty              => l_index.reord_qty
                   , nb_time          => l_need_by_date
                   , uom              => l_item_Attr_rec.primary_uom
                   , accru_acct       => l_item_attr_rec.accru_acct
                   , ipv_acct         => l_item_attr_rec.ipv_Acct
                   , budget_acct      => l_item_attr_rec.budget_acct
                   , charge_acct      => l_item_attr_rec.charge_Acct
                   , purch_flag       => l_item_attr_rec.purch_flag
                   , order_flag       => l_item_attr_Rec.order_flag
                   , transact_flag    => l_item_attr_rec.transact_flag
                   , unit_price       => l_item_Attr_rec.unit_price
                   , user_id          => l_user_id
                   , sysd             => sysdate
                   , organization_id  => p_organization_id
                   , approval         => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                   , src_type         => l_item_attr_rec.src_Type
                   , encum_flag       => l_encum_flag
                   , customer_id      => l_cust_id
                   , employee_id      => l_employee_id
                   , description      => l_item_attr_rec.description
                   , src_org          => l_item_Attr_rec.src_org
                   , src_subinv       => l_item_attr_Rec.src_subinv
                   , subinv           => null
                   , location_id      => p_dd_loc_id
                   , po_org_id        => l_po_org_id
                   , p_pur_revision   => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
                   , x_ret_stat       => l_return_status
                   , x_ret_mesg       => l_msg_data);

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;
              END IF;
            ELSE
              -- no source type defined, create a notification with source missing.
              l_notification_id := null;
              csp_notifications_pkg.insert_row(
                    px_notification_id  => l_notification_id,
                    p_created_by        => l_user_id,
                    p_creation_date     => sysdate,
                    p_last_updated_by   => l_user_id,
                    p_last_update_date  => sysdate,
                    p_last_update_login => l_login_id,
                    p_planner_code      => l_item_attr_rec.planner,
                    p_parts_loop_id     => null,
                    p_organization_id   => p_organization_id,
                    p_inventory_item_id => l_item_attr_rec.item_id,
                    p_notification_date => sysdate,
                    p_reason            => 'N',
                    p_status            => '1',
                    p_quantity          => l_index.reord_qty,
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
                    p_attribute15       => null,
                    p_need_date         => null, --l_need_by_date,
                    p_suppress_end_date => null,
                    p_notification_type => 'NS');
            END IF;
          ELSE -- wip item
            IF (l_need_by_date IS NULL) THEN  -- need by date is null
                l_lead_time := nvl(l_item_attr_rec.fixed_lead_time, 0) +
                               (l_index.reord_qty * nvl(l_item_attr_rec.variable_lead_time,0));
              BEGIN
                SELECT c1.calendar_date
                INTO l_need_by_date
                FROM bom_calendar_dates c1,
                     bom_calendar_dates c
                WHERE  c1.calendar_code    = c.calendar_code
                AND  c1.exception_set_id = c.exception_set_id
                AND  c1.seq_num          = (c.next_seq_num + CEIL(l_lead_time))
                AND  c.calendar_code     = l_cal_code
                AND  c.exception_set_id  = l_exception_set_id
                AND  c.calendar_date     = trunc(sysdate);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_need_by_date := sysdate;
              END;
            END If;

            IF (p_notif_for_wip = 1) THEN
              -- create notifications for make items
              l_notification_id := null;
              csp_notifications_pkg.insert_row(
                    px_notification_id  => l_notification_id,
                    p_created_by        => l_user_id,
                    p_creation_date     => sysdate,
                    p_last_updated_by   => l_user_id,
                    p_last_update_date  => sysdate,
                    p_last_update_login => l_login_id,
                    p_planner_code      => l_item_attr_rec.planner,
                    p_parts_loop_id     => null,
                    p_organization_id   => p_organization_id,
                    p_inventory_item_id => l_item_attr_rec.item_id,
                    p_notification_date => sysdate,
                    p_reason            => 'N',
                    p_status            => '1',
                    p_quantity          => l_index.reord_qty,
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
                    p_attribute15       => null,
                    p_need_date         => l_need_by_date,
                    p_suppress_end_date => null,
                    p_notification_type => 'WIP');

            ELSIF (p_restock = 1) THEN
              -- call re_wip
              re_wip( item_id          => l_item_attr_rec.item_id
                  , qty              => l_index.REORD_QTY
                  , nb_time          => null
                  , uom              => l_item_Attr_rec.primary_uom
                  , wip_id           => l_wip_batch_id
                  , user_id          => l_user_id
                  , sysd             => sysdate
                  , organization_id  => p_organization_id
                  , approval         => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                  , build_in_wip     => l_item_attr_rec.build_in_wip
                  , pick_components  => l_item_attr_rec.pick_components
                  , x_ret_stat       => l_return_status
                  , x_ret_mesg       => l_msg_data);
            END IF;
          END IF;
        END IF;
      END LOOP;
      -- cleanup INV_MIN_MAX_TEMP table
      delete from INV_MIN_MAX_TEMP;
    END IF;

    -- create notifications for excess on order

    -- call min max api with selection as above max qty
    CSP_MINMAX_PVT.run_min_max_plan (
              p_item_select     => l_item_select
            , p_handle_rep_item => p_repitem
            , p_pur_revision    => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
            , p_cat_select      => l_Cat_select
            , p_cat_set_id      => p_Category_set_id
            , p_mcat_struct     => l_mcat_struct_id
            , p_level           => 1   -- always run at organization level
            , p_restock         => 2
            , p_include_nonnet  => p_include_nonnet_sub
            , p_include_po      => p_include_po
            , p_include_wip     => p_include_wip
            , p_include_if      => p_include_iface_sup
            , p_net_rsv         => p_net_rsv
            , p_net_unrsv       => p_net_unrsv
            , p_net_wip         => p_net_wip
            , p_org_id          => p_organization_id
            , p_user_id         => l_user_id
            , p_employee_id     => l_employee_id
            , p_subinv          => null
            , p_dd_loc_id       => p_dd_loc_id
            , p_wip_batch_id    => l_wip_batch_id
            , p_approval        => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
            , p_buyer_hi        => p_buyer_hi
            , p_buyer_lo        => p_buyer_lo
            , p_range_buyer     => l_range_buyer
            , p_cust_id         => l_cust_id
            , p_po_org_id       => l_po_org_id
            , p_range_sql       => l_range_Sql
            , p_sort            => p_sort
            , p_selection       => 2    -- items above maximum quantity
            , p_sysdate         => l_today
            , p_s_cutoff        => (l_s_cutoff + 10000)
            , p_d_cutoff        => l_d_cutoff
            , p_order_by        => l_order_by
            , p_encum_flag      => l_encum_flag
            , p_cal_code        => l_cal_code
            , p_exception_set_id => l_exception_set_id
            , x_return_status   => l_Return_status
            , x_msg_data        => l_msg_data);

    -- for all records in inv_min_max_temp with supply qty > 0
    -- create EOO notifications
    declare
      l_item_id      NUMBER;
      l_planner      VARCHAR2(30);
      l_edq_multiple NUMBER;
      l_min_value    NUMBER;
      l_Edq          NUMBER;
      l_item_cost    NUMBER;
      l_limit        NUMBER;
      l_EOO_Qty      NUMBER;
      l_supply_qty   NUMBER;
      l_tot_avail_qty NUMBER;
    begin
      FOR mrc in minmax_rslts_cur LOOP
        SELECT msik.planner_code,
               msik.inventory_item_id
        INTO   l_planner,
               l_item_id
        FROM mtl_system_items_kfv msik
        WHERE msik.concatenated_segments = mrc.item_segments
        AND msik.organization_id = p_organization_id;

        -- check if item is on a suppressed notification
        l_count := 0;
        begin
          SELECT count(inventory_item_id)
          INTO l_count
          FROM csp_notifications
          WHERE organization_id = p_organization_id
          AND   inventory_item_id = l_item_id
          AND   nvl(suppress_end_date, sysdate) >= sysdate;
        exception
          when others then
            null;
        end;

       IF (l_count = 0) THEN -- only if item is not on suppresses notif

        BEGIN
          SELECT sum(pol.quantity)
          INTO l_supply_qty
          FROM po_requisition_headers_all poh,
               po_requisition_lines_all pol
          WHERE poh.authorization_status = 'INCOMPLETE'
          AND pol.requisition_header_id = poh.requisition_header_id
          AND pol.destination_type_code = 'INVENTORY'
          AND pol.item_id = l_item_id
          AND pol.destination_organization_id = p_organization_id;
        EXCEPTION
          when no_Data_found then
            l_supply_qty := 0;
        END;

        l_tot_Avail_qty := nvl(mrc.TOT_AVAIL_QTY,0) + nvl(l_supply_qty, 0);
        l_supply_qty := nvl(l_supply_qty,0) + nvl(mrc.supply_qty,0);

        IF (nvl(l_SUPPLY_QTY,0) > 0) THEN
            select edq_multiple,
                   minimum_Value
            into   l_Edq_multiple,
                   l_min_Value
            from   csp_planning_parameters
            where  organization_id = p_organization_id
            and secondary_inventory is null;

            l_edq := mrc.MAX_QTY - mrc.MIN_QTY;
            l_limit := (mrc.min_qty + (l_edq * nvl(l_edq_multiple, 1)));
            IF ((l_TOT_AVAIL_QTY - l_limit) >= l_supply_qty) THEN
              l_EOO_Qty := l_SUPPLY_QTY;
            ELSE
              l_EOO_Qty := l_TOT_AVAIL_QTY - l_limit;
            END IF;

            IF (l_EOO_qty > 0) THEN
             BEGIN
                SELECT cic.item_cost
                INTO   l_item_cost
                FROM   cst_item_costs cic,
                     mtl_parameters mp
                WHERE cic.inventory_item_id = l_item_id
                AND cic.organization_id = mp.organization_id
                AND cic.cost_type_id = mp.primary_cost_method
                AND mp.organization_id = p_organization_id;
              EXCEPTION
                WHEN no_data_found then
                  l_item_cost := 0;
              END;

              IF ((nvl(l_item_cost,0) * l_EOO_qty) > nvl(l_min_Value, 0)) THEN
                l_notification_id := null;
                csp_notifications_pkg.insert_row(
                    px_notification_id  => l_notification_id,
                    p_created_by        => l_user_id,
                    p_creation_date     => sysdate,
                    p_last_updated_by   => l_user_id,
                    p_last_update_date  => sysdate,
                    p_last_update_login => l_login_id,
                    p_planner_code      => l_planner,
                    p_parts_loop_id     => null,
                    p_organization_id   => p_organization_id,
                    p_inventory_item_id => l_item_id,
                    p_notification_date => sysdate,
                    p_reason            => 'N',
                    p_status            => '1',
                    p_quantity          => l_EOO_qty,
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
                    p_attribute15       => null,
                    p_need_date         => null,
                    p_suppress_end_date => null,
                    p_notification_type => 'EOO');
              END IF;
            END IF;
        END IF;
       END IF;
      END LOOP;
    end;
    -- cleanup minmax temp tbl
    DELETE FROM INV_MIN_MAX_TEMP;

    -- For all IO/PO/WIP notifs in notifications tbl,
    -- create recommendations for excess, repair and new buy/make
    -- For all EOO notifications,
    -- 1. go thru requisitions and req interface tbls for IO and
    --    PO cancel recommendations
    -- 2. go thru wip interface and wip jobs tbls for make cancel recomm
    FOR onc IN open_notifs_cur LOOP
      IF (onc.notification_type <> 'EOO') THEN

        declare
          l_item_rec      CSP_PLANNER_NOTIFICATIONS.item_list_rectype;
          l_excess_parts_tbl CSP_PLANNER_NOTIFICATIONS.excess_parts_tbl;
          l_fixed_lt      NUMBER;
          l_variable_lt   NUMBER;
          l_buying_lt     NUMBER;
        begin
          l_item_rec.inventory_item_id := onc.inventory_item_id;
          l_item_rec.category_set_id   := p_Category_set_id;
          l_item_rec.d_cutoff          := l_d_cutoff;
          l_item_rec.s_cutoff          := l_s_cutoff;
          l_item_rec.repitem           := p_repitem;
          l_item_rec.net_rsv           := p_net_rsv;
          l_item_rec.net_unrsv         := p_net_unrsv;
          l_item_rec.net_wip           := p_net_wip;
          l_item_Rec.include_po        := p_include_po;
          l_item_rec.include_wip       := p_include_wip;
          l_item_rec.include_iface_sup := p_include_iface_sup;
          l_item_rec.include_nonnet_sub := 2;
          l_item_rec.lot_control       := p_lot_control;
          l_item_Rec.employee_id       := l_employee_id;

          select c.fixed_lead_time                 fixed_lead_time,
                 c.variable_lead_time              variable_lead_time,
                 NVL(c.preprocessing_lead_time, 0) +
                 NVL(c.full_lead_time, 0) +
                 NVL(c.postprocessing_lead_time, 0) buying_lead_time
          into l_fixed_lt,
               l_Variable_lt,
               l_buying_lt
          from mtl_system_items c
          where c.inventory_item_id = onc.inventory_item_id
          and organization_id = p_organization_id;

          IF (onc.notification_type IN ('IO', 'PO')) THEN
            --
            -- Lead time for buy items is sum of POSTPROCESSING_LEAD_TIME,
            -- PREPROCESSING_LEAD_TIME AND PROCESSING_LEAD_TIME (sub level)
            -- OR POSTPROCESSING_LEAD_TIME, PREPROCESSING_LEAD_TIME
            -- AND FULL_LEAD_TIME (item level)
            --
            -- Here, total lead time is the total buying Lead time
            --

              BEGIN
                SELECT c1.calendar_date
                INTO l_est_date
                FROM bom_calendar_dates c1,
                     bom_calendar_dates c
                WHERE  c1.calendar_code    = c.calendar_code
                AND  c1.exception_set_id = c.exception_set_id
                AND  c1.seq_num          = c.prior_seq_num - CEIL(l_buying_lt)
                AND  c.calendar_code     = l_cal_code
                AND  c.exception_set_id  = l_exception_set_id
                AND  c.calendar_date     = trunc(onc.need_date);

                IF (l_est_date >= trunc(sysdate)) THEN
                  l_order_by_date := l_est_date;
                ELSE
                  l_order_by_date := trunc(sysdate);
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN -- need by date not defined in calendar
                  l_order_by_date := l_need_by_date - CEIL(l_buying_lt);
                WHEN OTHERS THEN
                  null;
              END;
            ELSIF (onc.notification_type = 'WIP') THEN
              l_lead_time := NVL(l_fixed_lt,0) +
                             NVL(l_variable_lt,0) * onc.quantity;
              BEGIN
                  SELECT c1.calendar_date
                  INTO l_est_date
                  FROM bom_calendar_dates c1,
                       bom_calendar_dates c
                  WHERE  c1.calendar_code    = c.calendar_code
                  AND  c1.exception_set_id = c.exception_set_id
                  AND  c1.seq_num          = (c.prior_seq_num - CEIL(l_lead_time))
                  AND  c.calendar_code     = l_cal_code
                  AND  c.exception_set_id  = l_exception_set_id
                  AND  c.calendar_date     = trunc(onc.need_date);

                  IF (l_est_date >= trunc(sysdate)) THEN
                    l_order_by_date := l_est_date;
                  ELSE
                    l_order_by_date := trunc(sysdate);
                  END IF;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN -- need by date not defined in calendar
                    l_order_by_date := l_need_by_date - CEIL(l_lead_time);
                  WHEN OTHERS THEN
                    null;
              END;
            END IF;

          -- generate excess recommendations
          Calculate_Excess(
               p_organization_id   => p_organization_id
              ,p_item_rec          => l_item_Rec
              ,p_called_from       => 'NOTIF'
              ,p_notification_id   => onc.notification_id
              ,p_order_by_date     => l_order_by_date
              ,x_excess_parts_tbl  => l_Excess_parts_Tbl
              ,x_return_status     => l_return_status
              ,x_msg_data          => l_msg_Data
              ,x_msg_count         => l_msg_count);

          -- generate repair recommendations
          -- check to see if item can be repaired to itself
          begin
            SELECT related_item_id
            INTO l_related_item
            FROM mtl_related_items_view
            WHERE relationship_type_id = 18
            AND inventory_item_id = onc.inventory_item_id;
          exception
            when NO_DATA_FOUND then
              Generate_Repair_Recomm(
                 p_notification_id   => onc.notification_id
                ,p_organization_id   => p_organization_id
                ,p_inventory_item_id => onc.inventory_item_id
                ,p_order_by_date     => l_order_by_date
                ,p_supercess_item_yn => 'N'
                );
            when TOO_MANY_ROWS then
              null;
          end;
          -- generate repair recommendations for all superceded items
          FOR sic IN supercess_items_cur(onc.inventory_item_id) LOOP
            Generate_Repair_Recomm(
                 p_notification_id   => onc.notification_id
                ,p_organization_id   => p_organization_id
                ,p_inventory_item_id => sic.inventory_item_id
                ,p_order_by_date     => l_order_by_date
                ,p_supercess_item_yn => 'Y'
                );
          END LOOP;

          -- generate new buy recommendations if notifications type is not
          -- 'No source Notification'
          IF (onc.notification_type <> 'NS') THEN
          declare
            l_parts_rec         CSP_PLANNER_NOTIFICATIONS.excess_parts_rectype;
            l_business_rule_rec CSP_PLANNER_NOTIFICATIONS.business_rule_rectype;
            l_source_type       VARCHAR2(30) := 'IO';
            l_business_rule_id  NUMBER;
            l_create_notif      VARCHAR2(1) := 'Y';
            l_total_excess      NUMBER;
            l_total_repair      NUMBER;
            l_item_cost         NUMBER;
            l_tracking_signal   NUMBER;

            CURSOR tracking_signal_cur IS
              SELECT tracking_signal
              FROM csp_usage_headers
              WHERE organization_id = p_organization_id
              AND inventory_item_id = onc.inventory_item_id
              AND header_Data_type = 4;

            CURSOR item_attr_cur1(p_item_id NUMBER) IS
              SELECT c.description                     description,
                c.repetitive_planning_flag        repetitive_planned_item,
                c.fixed_lead_time                 fixed_lead_time,
                c.variable_lead_time              variable_lead_time,
                NVL(c.preprocessing_lead_time, 0) +
                NVL(c.full_lead_time, 0) +
                NVL(c.postprocessing_lead_time, 0) buying_lead_time,
                c.primary_uom_code                primary_uom,
                p.ap_accrual_account              accru_acct,
                p.invoice_price_var_account       ipv_acct,
                NVL(c.encumbrance_account, p.encumbrance_account)  budget_acct,
                DECODE(c.inventory_asset_flag, 'Y', p.material_account,
                      NVL(c.expense_account, p.expense_account))  charge_acct,
                NVL(c.source_type, p.source_type) src_type,
                DECODE(c.source_type, NULL,
                      DECODE(p.source_type, NULL, NULL, p.source_organization_id),
                             c.source_organization_id)   src_org,
                DECODE(c.source_type, NULL,
                      DECODE(p.source_type, NULL, NULL, p.source_subinventory),
                                c.source_subinventory)   src_subinv,
                c.purchasing_enabled_flag         purch_flag,
                c.internal_order_enabled_flag     order_flag,
                c.mtl_transactions_enabled_flag   transact_flag,
                c.list_price_per_unit             unit_price,
                c.planning_make_buy_code          mbf,
                c.planner_code                    planner,
                build_in_wip_flag                 build_in_wip,
                pick_components_flag              pick_components
              FROM mtl_system_items_kfv c,
                   mtl_parameters p
              WHERE c.inventory_item_id = p_item_id
              AND   c.organization_id = p.organization_id
              AND   p.organization_id = p_organization_id;

              l_item_attr_rec1     item_attr_cur1%ROWTYPE;
          begin
            -- If restock = 'Y', look at the business rules for automating the notification.
            IF (p_restock = 1) THEN
              begin
              SELECT notification_rule_id
              INTO l_business_rule_id
              FROM csp_planning_parameters
              WHERE organization_id = p_organization_id
              AND node_type = 'ORGANIZATION_WH';

              IF l_business_rule_id IS NOT NULL THEN
                SELECT IO_Excess_Value
                    ,IO_Repair_Value
                    ,IO_Recommend_Value
                    ,IO_Tracking_Signal_Max
                    ,IO_Tracking_Signal_Min
                    ,REQ_Excess_Value
                    ,REQ_Repair_Value
                    ,REQ_Recommend_Value
                    ,REQ_Tracking_Signal_Max
                    ,REQ_Tracking_Signal_Min
                    ,WIP_Order_Excess_Value
                    ,WIP_Order_Repair_Value
                    ,WIP_Order_Recommend_Value
                    ,WIP_Order_Tracking_Signal_Max
                    ,WIP_Order_Tracking_Signal_Min
                INTO l_business_rule_rec
                FROM csp_notification_rules_vl
                WHERE notification_rule_id = l_business_rule_id;

                begin
                  SELECT cic.item_cost
                  INTO   l_item_cost
                  FROM   cst_item_costs cic,
                         mtl_parameters mp
                  WHERE cic.inventory_item_id = onc.inventory_item_id
                  AND cic.organization_id = mp.organization_id
                  AND cic.cost_type_id = mp.primary_cost_method
                  AND mp.organization_id = p_organization_id;
                exception
                  when no_data_found THEN
                    l_item_cost := 0;
                end;

                SELECT nvl(SUM(DECODE(cnd.source_type, 'EXCESS', cnd.available_quantity, null)), 0) AS Excess_Qty,
                       nvl(SUM(DECODE(cnd.source_type, 'REPAIR', cnd.available_quantity, null)), 0) AS Repair_Qty
                INTO l_total_excess, l_total_repair
                FROM csp_notification_details cnd
                WHERE notification_id = onc.notification_id;

                IF (onc.notification_type = 'IO') THEN
                  IF (((l_total_excess * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.IO_Excess_Value,0)) AND
                      ((l_total_repair * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.IO_Repair_Value,0)) AND
                      ((onc.quantity * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.IO_recommend_value,0))) THEN
                      -- calculate tracking signal and test
                      OPEN tracking_signal_cur;
                      FETCH tracking_signal_cur INTO l_Tracking_signal;
                      CLOSE tracking_Signal_cur;

                      IF ((nvl(l_Tracking_signal,0) >= nvl(l_business_rule_rec.IO_Tracking_Signal_Min, 0)) AND
                          (nvl(l_Tracking_signal,0) <= nvl(l_business_rule_rec.IO_Tracking_Signal_Max,0))) THEN

                          l_create_notif := 'N';

                          OPEN item_attr_cur1(onc.inventory_item_id);
                          FETCH item_attr_cur1 INTO l_item_attr_rec1;
                          CLOSE item_Attr_cur1;

                          -- call process_order for creating internal orders
                          l_header_rec.dest_organization_id :=  p_organization_id;
                          l_header_Rec.need_by_date := onc.need_Date;
                          l_header_rec.operation := 'CREATE';
                          l_header_rec.ship_to_location_id := p_dd_loc_id;
                          FND_PROFILE.GET('CSP_ORDER_TYPE', l_header_rec.order_type_id);

                          l_line_tbl(1).line_num := 1;
                          l_line_tbl(1).inventory_item_id := onc.inventory_item_id;
                          l_line_tbl(1).quantity := onc.quantity;
                          l_line_tbl(1).ordered_quantity := onc.quantity;
                          l_line_Tbl(1).unit_of_measure := l_item_Attr_rec1.primary_uom;
                          l_line_Tbl(1).source_organization_id := l_item_Attr_rec1.src_org;
                          l_line_Tbl(1).source_subinventory := l_item_attr_Rec1.src_subinv;
                          l_line_tbl(1).booked_flag := 'Y';

                          -- call process order
                          csp_parts_order.process_order(
                             p_api_version             => l_api_Version_number
                            ,p_Init_Msg_List           => null
                            ,p_commit                  => null
                            ,px_header_rec             => l_header_Rec
                            ,px_line_table             => l_Line_Tbl
                            ,p_process_type            => 'BOTH'
                            ,x_return_status           => l_return_status
                            ,x_msg_count               => l_msg_count
                            ,x_msg_data                => l_msg_data
                          );

                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE FND_API.G_EXC_ERROR;
                           ELSE
                             update csp_notifications
                             set status = 5
                             where notification_id = onc.notification_id;

                             IF ((l_total_excess > 0) OR (l_total_repair > 0)) THEN
                               DELETE FROM csp_notification_Details
                               WHERE notification_id = onc.notification_id;
                             END IF;
                           END IF;
                      ELSE
                        l_create_notif := 'Y';
                      END IF;
                  ELSE
                    l_create_notif := 'Y';
                  END IF;
                ELSIF (onc.notification_type = 'PO') THEN
                  -- check PO parameters
                  IF (((l_total_excess * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.REQ_Excess_Value,0)) AND
                      ((l_total_repair * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.REQ_Repair_Value,0)) AND
                      ((onc.quantity * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.REQ_recommend_value,0))) THEN
                      -- calculate tracking signal and test
                      OPEN tracking_signal_cur;
                      FETCH tracking_signal_cur INTO l_Tracking_signal;
                      CLOSE tracking_Signal_cur;

                      IF ((nvl(l_Tracking_signal,0) >= nvl(l_business_rule_rec.REQ_Tracking_Signal_Min, 0)) AND
                          (nvl(l_Tracking_signal, 0) <= nvl(l_business_rule_rec.REQ_Tracking_Signal_Max, 0))) THEN

                          l_create_notif := 'N';

                          OPEN item_attr_cur1(onc.inventory_item_id);
                          FETCH item_attr_cur1 INTO l_item_attr_rec1;
                          CLOSE item_Attr_cur1;

                          re_po(
                             item_id          => onc.inventory_item_id
                           , qty              => onc.quantity
                           , nb_time          => onc.need_date
                           , uom              => l_item_Attr_rec1.primary_uom
                           , accru_acct       => l_item_attr_rec1.accru_acct
                           , ipv_acct         => l_item_attr_rec1.ipv_Acct
                           , budget_acct      => l_item_attr_rec1.budget_acct
                           , charge_acct      => l_item_attr_rec1.charge_Acct
                           , purch_flag       => l_item_attr_rec1.purch_flag
                           , order_flag       => l_item_attr_Rec1.order_flag
                           , transact_flag    => l_item_attr_rec1.transact_flag
                           , unit_price       => l_item_Attr_rec1.unit_price
                           , user_id          => l_user_id
                           , sysd             => sysdate
                           , organization_id  => p_organization_id
                           , approval         => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                           , src_type         => l_item_attr_rec1.src_Type
                           , encum_flag       => l_encum_flag
                           , customer_id      => l_cust_id
                           , employee_id      => l_employee_id
                           , description      => l_item_attr_rec1.description
                           , src_org          => l_item_Attr_rec1.src_org
                           , src_subinv       => l_item_attr_Rec1.src_subinv
                           , subinv           => null
                           , location_id      => p_dd_loc_id
                           , po_org_id        => l_po_org_id
                           , p_pur_revision   => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
                           , x_ret_stat       => l_return_status
                           , x_ret_mesg       => l_msg_data);

                           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE FND_API.G_EXC_ERROR;
                           ELSE
                             update csp_notifications
                             set status = 5
                             where notification_id = onc.notification_id;

                             IF ((l_total_excess > 0) OR (l_total_repair > 0)) THEN
                               DELETE FROM csp_notification_Details
                               WHERE notification_id = onc.notification_id;
                             END IF;
                           END IF;
                      ELSE
                        l_create_notif := 'Y';
                      END IF;
                  ELSE
                    l_create_notif := 'Y';
                  END IF;
                ELSIF (onc.notification_type = 'WIP') THEN
                  IF (((l_total_excess * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.WIP_Excess_Value,0)) AND
                      ((l_total_repair * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.WIP_Repair_Value,0)) AND
                      ((onc.quantity * nvl(l_item_cost,0)) <= nvl(l_business_rule_rec.WIP_Recommend_value,0))) THEN
                      -- calculate tracking signal and test
                      OPEN tracking_signal_cur;
                      FETCH tracking_signal_cur INTO l_Tracking_signal;
                      CLOSE tracking_Signal_cur;

                      IF ((nvl(l_Tracking_signal,0) >= nvl(l_business_rule_rec.WIP_Tracking_Signal_Min, 0)) AND
                          (nvl(l_Tracking_signal,0) <= nvl(l_business_rule_rec.WIP_Tracking_Signal_Max, 0))) THEN

                          l_create_notif := 'N';

                          OPEN item_attr_cur1(onc.inventory_item_id);
                          FETCH item_attr_cur1 INTO l_item_attr_rec1;
                          CLOSE item_Attr_cur1;

                          re_wip(   item_id          => onc.inventory_item_id
                                  , qty              => onc.quantity
                                  , nb_time          => null
                                  , uom              => l_item_Attr_rec1.primary_uom
                                  , wip_id           => l_wip_batch_id
                                  , user_id          => l_user_id
                                  , sysd             => sysdate
                                  , organization_id  => p_organization_id
                                  , approval         => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                                  , build_in_wip     => l_item_attr_rec1.build_in_wip
                                  , pick_components  => l_item_attr_rec1.pick_components
                                  , x_ret_stat       => l_return_status
                                  , x_ret_mesg       => l_msg_data);
                          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE FND_API.G_EXC_ERROR;
                          ELSE
                             update csp_notifications
                             set status = 5
                             where notification_id = onc.notification_id;

                             IF ((l_total_excess > 0) OR (l_total_repair > 0)) THEN
                               DELETE FROM csp_notification_Details
                               WHERE notification_id = onc.notification_id;
                             END IF;
                          END IF;
                      ELSE
                        l_create_notif := 'Y';
                      END IF;
                  ELSE
                    l_create_notif := 'Y';
                  END IF;
                END IF;
              ELSE
                l_Create_notif := 'Y';
              END IF;
              exception
                when no_data_found then
                  l_create_notif := 'Y';
              end;
            END IF;
            IF (l_Create_notif = 'Y') THEN
              l_parts_rec.inventory_item_id := onc.inventory_item_id;
              l_parts_rec.quantity := onc.quantity;
              l_source_type := onc.notification_type;

              select DECODE(c.source_type, NULL,
                        DECODE(p.source_type, NULL, NULL, p.source_organization_id),
                               c.source_organization_id)   src_org,
                     DECODE(c.source_type, NULL,
                        DECODE(p.source_type, NULL, NULL, p.source_subinventory),
                               c.source_subinventory)   src_subinv
              into l_parts_rec.source_org_id,
                   l_parts_rec.source_subinv
              from mtl_system_items c,
                   mtl_parameters p
              where c.inventory_item_id = l_parts_rec.inventory_item_id
              and c.organization_id = p.organization_id
              and p.organization_id = p_organization_id;

              Create_Notification_Details(
                     p_source_type      => l_source_type
                    ,p_order_by_dt      => l_order_by_date
                    ,p_notification_id  => onc.notification_id
                    ,p_parts_rec        => l_parts_rec);
            END IF;
          end;
        END IF;
        end;
      END IF;
    END LOOP;

 END Create_Notifications;

  PROCEDURE Build_Range_Sql
        ( p_cat_structure_id IN            NUMBER
        , p_cat_lo           IN            VARCHAR2
        , p_cat_hi           IN            VARCHAR2
        , p_item_lo          IN            VARCHAR2
        , p_item_hi          IN            VARCHAR2
        , p_planner_lo       IN            VARCHAR2
        , p_planner_hi       IN            VARCHAR2
        , p_lot_ctl          IN            NUMBER
        , x_range_sql        OUT NOCOPY           VARCHAR2
        )
  IS
  l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
  l_structure_rec  FND_FLEX_KEY_API.structure_type;
  l_segment_rec    FND_FLEX_KEY_API.segment_type;
  l_segment_tbl    FND_FLEX_KEY_API.segment_list;
  l_segment_number NUMBER;
  l_mstk_segs      VARCHAR2(850);
  l_mcat_segs      VARCHAR2(850);
  --l_mcat_w        VARCHAR2(2000);
  --l_mstk_w         VARCHAR2(2000);
  l_range_sql      VARCHAr2(2000);
  lx_range_sql     VARCHAR2(4000) := '1=1';
  BEGIN

    FND_FLEX_KEY_API.set_session_mode('customer_data');

    -- retrieve system item concatenated flexfield
    l_mstk_segs := '';
    l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MSTK');
    l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, 101);
    FND_FLEX_KEY_API.get_segments
      ( flexfield => l_flexfield_rec
      , structure => l_structure_rec
      , nsegments => l_segment_number
      , segments  => l_segment_tbl
      );
    FOR l_idx IN 1..l_segment_number LOOP
      l_segment_rec := FND_FLEX_KEY_API.find_segment
                        ( l_flexfield_rec
                        , l_structure_rec
                        , l_segment_tbl(l_idx)
                        );
      l_mstk_segs := l_mstk_segs ||'C.'||l_segment_rec.column_name;
      IF l_idx < l_segment_number THEN
        l_mstk_segs := l_mstk_segs||'||'||''''||
                       l_structure_rec.segment_separator||''''||'||';
      END IF;
    END LOOP;

    -- retrieve item category concatenated flexfield
    l_mcat_segs := '';
    l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MCAT');
    l_structure_rec := FND_FLEX_KEY_API.find_structure
                        ( l_flexfield_rec
                        , p_cat_structure_id
                        );
    FND_FLEX_KEY_API.get_segments
      ( flexfield => l_flexfield_rec
      , structure => l_structure_rec
      , nsegments => l_segment_number
      , segments  => l_segment_tbl
      );
    FOR l_idx IN 1..l_segment_number LOOP
      l_segment_rec := FND_FLEX_KEY_API.find_segment
                        ( l_flexfield_rec
                        , l_structure_rec
                        , l_segment_tbl(l_idx)
                        );
      l_mcat_segs   := l_mcat_segs ||'B.'||l_segment_rec.column_name;
      IF l_idx < l_segment_number THEN
        l_mcat_segs := l_mcat_segs||'||'||''''||
                       l_structure_rec.segment_separator||''''||'||';
      END IF;
    END LOOP;

    IF p_item_lo IS NOT NULL AND p_item_hi IS NOT NULL THEN
      l_range_sql := l_mstk_segs||' BETWEEN '''||p_item_lo||''''||
                                          ' AND '''||p_item_hi||'''';
    ELSIF p_item_lo IS NOT NULL AND p_item_hi IS NULL THEN
      l_range_sql := l_mstk_segs||' >= '''||p_item_lo||'''';
    ELSIF p_item_lo IS NULL AND p_item_hi IS NOT NULL THEN
      l_range_sql := l_mstk_segs||' <= '''||p_item_hi||'''';
    END IF;

    IF (l_range_sql is not null) THEN
      lx_range_sql := l_range_sql;
      l_range_sql := null;
    END IF;

    IF p_cat_lo IS NOT NULL AND p_cat_hi IS NOT NULL THEN
      l_range_sql := l_mcat_segs||' BETWEEN '''||p_cat_lo||''''||
                                        ' AND '''||p_cat_hi||'''';
    ELSIF p_cat_lo IS NOT NULL AND p_cat_hi IS NULL THEN
      l_range_Sql := l_mcat_segs||' >= '''||p_cat_lo||'''';
    ELSIF p_cat_lo IS NULL AND p_cat_hi IS NOT NULL THEN
      l_range_sql := l_mcat_segs||' <= '''||p_cat_hi||'''';
    END IF;

    IF (l_range_Sql is not null) THEN
      lx_range_sql := lx_Range_sql || ' and' || l_range_Sql;
      l_range_sql := null;
    END IF;

    if p_planner_lo is not null and p_planner_hi is not null then
      l_RANGE_SQL := 'c.planner_code between ' ||''''||P_planner_LO||'''' ||
                     ' and '|| ''''||P_planner_HI||'''';
    elsif p_planner_lo is not null then
		l_RANGE_SQL := 'c.planner_code >= ' ||''''||P_planner_LO||'''';
    elsif p_PLANNER_hi is not null then
		l_RANGE_SQL := 'c.planner_code <= ' ||''''||P_PLANNER_HI||'''';
    end if;

    if l_range_sql is not null then
       lx_range_sql := lx_range_sql||' and '|| l_range_sql;
       l_range_sql := null;
    end if;

    if P_LOT_CTL = 1 then
       l_RANGE_SQL := 'c.lot_control_code = 2';
    elsif P_LOT_CTL = 2 then
       l_RANGE_SQL := 'c.lot_control_code <> 2';
    end if;

    if l_range_sql is not null then
       lx_range_sql := lx_range_sql||' and '|| l_range_sql;
       l_range_sql := null;
    end if;

    x_range_Sql := lx_range_sql;

  END;

  PROCEDURE Build_Item_Cat_Select(p_Cat_structure_id IN NUMBER
                                 ,x_item_select   OUT NOCOPY VARCHAR2
                                 ,x_cat_Select    OUT NOCOPY VARCHAR2
                                 ) IS
  l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
  l_structure_rec  FND_FLEX_KEY_API.structure_type;
  l_segment_rec    FND_FLEX_KEY_API.segment_type;
  l_segment_tbl    FND_FLEX_KEY_API.segment_list;
  l_segment_number NUMBER;
  l_mstk_segs      VARCHAR2(850);
  l_mcat_segs      VARCHAR2(850);
  BEGIN
    FND_FLEX_KEY_API.set_session_mode('customer_data');

    -- retrieve system item concatenated flexfield
    l_mstk_segs := '';
    l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MSTK');
    l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, 101);
    FND_FLEX_KEY_API.get_segments
      ( flexfield => l_flexfield_rec
      , structure => l_structure_rec
      , nsegments => l_segment_number
      , segments  => l_segment_tbl
      );
    FOR l_idx IN 1..l_segment_number LOOP
      l_segment_rec := FND_FLEX_KEY_API.find_segment
                        ( l_flexfield_rec
                        , l_structure_rec
                        , l_segment_tbl(l_idx)
                        );
      l_mstk_segs := l_mstk_segs ||'C.'||l_segment_rec.column_name;
      IF l_idx < l_segment_number THEN
        l_mstk_segs := l_mstk_segs||'||'||''''||
                       l_structure_rec.segment_separator||''''||'||';

      END IF;
    END LOOP;

    -- retrieve item category concatenated flexfield
    l_mcat_segs := '';
    l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MCAT');
    l_structure_rec := FND_FLEX_KEY_API.find_structure
                        ( l_flexfield_rec
                        , p_cat_structure_id
                        );
    FND_FLEX_KEY_API.get_segments
      ( flexfield => l_flexfield_rec
      , structure => l_structure_rec
      , nsegments => l_segment_number
      , segments  => l_segment_tbl
      );
    FOR l_idx IN 1..l_segment_number LOOP
      l_segment_rec := FND_FLEX_KEY_API.find_segment
                        ( l_flexfield_rec
                        , l_structure_rec
                        , l_segment_tbl(l_idx)
                        );
      l_mcat_segs   := l_mcat_segs ||'B.'||l_segment_rec.column_name;
      IF l_idx < l_segment_number THEN
        l_mcat_segs := l_mcat_segs||'||'||''''||
                       l_structure_rec.segment_separator||''''||'||';
      END IF;
    END LOOP;

    x_item_select := '('||l_mstk_Segs||')';
    x_cat_select := '('||l_mcat_Segs||')';

  END;

  PROCEDURE re_po( item_id          IN   NUMBER
                   , qty              IN   NUMBER
                   , nb_time          IN   DATE
                   , uom              IN   VARCHAR2
                   , accru_acct       IN   NUMBER
                   , ipv_acct         IN   NUMBER
                   , budget_acct      IN   NUMBER
                   , charge_acct      IN   NUMBER
                   , purch_flag       IN   VARCHAR2
                   , order_flag       IN   VARCHAR2
                   , transact_flag    IN   VARCHAR2
                   , unit_price       IN   NUMBER
                   , user_id          IN   NUMBER
                   , sysd             IN   DATE
                   , organization_id  IN   NUMBER
                   , approval         IN   NUMBER
                   , src_type         IN   NUMBER
                   , encum_flag       IN   VARCHAR2
                   , customer_id      IN   NUMBER
                   , employee_id      IN   NUMBER
                   , description      IN   VARCHAR2
                   , src_org          IN   NUMBER
                   , src_subinv       IN   VARCHAR2
                   , subinv           IN   VARCHAR2
                   , location_id      IN   NUMBER
                   , po_org_id        IN   NUMBER
                   , p_pur_revision   IN   NUMBER
                   , x_ret_stat       OUT NOCOPY  VARCHAR2
                   , x_ret_mesg       OUT NOCOPY  VARCHAR2) IS

        item_rev_ctl  NUMBER := 0;
        item_rev      VARCHAR2(4) := '@@@';
        profile_val   NUMBER;
        orgn_id       NUMBER := organization_id;

        po_exc        EXCEPTION;

  BEGIN
        --
        -- Do not create a requisition if any of the following apply:
        -- 1. Source type (Inventory/Supplier/Subinventory) is not specified
        -- 2. Item is not transactable
        -- 3. Source type is Inventory (1) but "Internal Orders Enabled"
        --    is not checked
        -- 4. Source type is Supplier (2) but "Purchasable" flag unchecked
        --
        IF (src_type IS NULL)
           OR
           (transact_flag <> 'Y')
           OR
           (src_type = 1 AND order_flag <> 'Y')
           OR
           (src_type = 2 AND purch_flag <> 'Y')
        THEN
           /* print_debug('Null src type or invalid transact_flag, order_flag or purch_flag'
                        , 're_po', 9);
           */
            RAISE po_exc;
        END IF;

        IF (charge_acct IS NULL)
            OR (accru_acct IS NULL)
            OR (ipv_acct IS NULL)
            OR ((encum_flag <> 'N') AND (budget_acct is NULL))
        THEN
            --print_debug('Charge/accrual/IPV/budget accts not setup correctly.', 're_po', 9);
            RAISE po_exc;
        END IF;

        IF NVL(customer_id,0) < 0
        THEN
            --print_debug('Invalid customer ID: ' || to_char(customer_id), 're_po', 9);
            RAISE po_exc;
        END IF;

        --
        -- Fix for bug 774532:
        -- To get the item revisions, if profile is Yes
        -- or if profile is NULL AND item is revision controlled
        --

        IF (p_pur_revision IS NULL)
        THEN
            SELECT MAX(revision_qty_control_code)
              INTO item_rev_ctl
              FROM mtl_system_items msi
             WHERE msi.organization_id   = orgn_id
               AND msi.inventory_item_id = item_id;
        END IF ;

        --print_debug('Rev ctl: ' || to_char(item_rev_ctl), 're_po', 9);

        IF (p_pur_revision = 1
           OR ((p_pur_revision IS NULL) AND ( item_rev_ctl = 2)))
        THEN
            SELECT MAX(revision)
              INTO item_rev
              FROM mtl_item_revisions mir
             WHERE inventory_item_id = item_id
               AND organization_id   = orgn_id
               AND effectivity_date  < SYSDATE
               AND effectivity_date  =
                   (
                    SELECT MAX(effectivity_date)
                      FROM mtl_item_revisions mir1
                     WHERE mir1.inventory_item_id = mir.inventory_item_id
                       AND mir1.organization_id   = mir.organization_id
                       AND effectivity_date       < SYSDATE
                   );
            --print_debug('Item rev: ' || item_rev, 're_po', 9);
        END IF;

        IF (src_type <> 3 )
        THEN
            --print_debug('Inserting into PO_REQUISITIONS_INTERFACE_ALL', 're_po', 9);

            INSERT INTO po_requisitions_interface_all(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                ITEM_DESCRIPTION,
                CREATION_DATE,
                CREATED_BY,
                PREPARER_ID,
                INTERFACE_SOURCE_CODE,
                REQUISITION_TYPE,
                AUTHORIZATION_STATUS,
                SOURCE_TYPE_CODE,
                SOURCE_ORGANIZATION_ID,
                SOURCE_SUBINVENTORY,
                DESTINATION_ORGANIZATION_ID,
                DESTINATION_SUBINVENTORY,
                DELIVER_TO_REQUESTOR_ID,
                DESTINATION_TYPE_CODE,
                UOM_CODE,
                DELIVER_TO_LOCATION_ID,
                ITEM_ID,
                ITEM_REVISION,
                QUANTITY,
                NEED_BY_DATE,
                GL_DATE,
                CHARGE_ACCOUNT_ID,
                ACCRUAL_ACCOUNT_ID,
                VARIANCE_ACCOUNT_ID,
                BUDGET_ACCOUNT_ID,
                AUTOSOURCE_FLAG,
                ORG_ID)
            VALUES (
                sysdate,
                user_id,
                description,
                sysdate,
                user_id,
                employee_id,
                'INV',
                DECODE(src_type, 1, 'INTERNAL', 'PURCHASE'),
                DECODE(APPROVAL,1,'INCOMPLETE',2,'APPROVED'),
                DECODE(src_type, 1, 'INVENTORY', 'VENDOR'),
                src_org,
                src_subinv,
                organization_id,
                subinv,
                employee_id,
                'INVENTORY',
                uom,
                location_id,
                item_id,
                DECODE(item_rev,'@@@',NULL,item_rev),
                qty,
                trunc(nb_time),
                SYSDATE,
                charge_acct,
                accru_acct,
                ipv_acct,
                budget_acct,
                'P',
                po_org_id);

        END IF;

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

  EXCEPTION
      WHEN OTHERS THEN
            --print_debug(sqlcode || ', ' || sqlerrm, 're_po', 1);

            SELECT meaning
            INTO x_ret_mesg
            FROM mfg_lookups
            WHERE lookup_type = 'INV_MMX_RPT_MSGS'
            AND lookup_code = 1;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
  END re_po;

  PROCEDURE re_wip( item_id          IN   NUMBER
                  , qty              IN   NUMBER
                  , nb_time          IN   DATE
                  , uom              IN   VARCHAR2
                  , wip_id           IN   NUMBER
                  , user_id          IN   NUMBER
                  , sysd             IN   DATE
                  , organization_id  IN   NUMBER
                  , approval         IN   NUMBER
                  , build_in_wip     IN   VARCHAR2
                  , pick_components  IN   VARCHAR2
                  , x_ret_stat       OUT NOCOPY  VARCHAR2
                  , x_ret_mesg       OUT NOCOPY  VARCHAR2) IS

        wip_exc  EXCEPTION;

  BEGIN
      IF build_in_wip <> 'Y' OR pick_components <> 'N' THEN
            RAISE wip_exc;
      ELSE
          -- print_debug('Inserting into WIP_JOB_SCHEDULE_INTERFACE', 're_wip', 9);
          INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                LAST_UNIT_COMPLETION_DATE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,
                STATUS_TYPE)
          VALUES(
               sysd,
               user_id,
               sysd,
               user_id,
               WIP_ID,
               2,
               1,
               organization_id,
               1,
               nb_time,
               item_id,
               qty,
               DECODE(approval,1,1,2,3));
        END IF;

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

  EXCEPTION
        WHEN OTHERS THEN
            --print_debug(sqlcode || ', ' || sqlerrm, 're_wip', 1);

            SELECT meaning
            INTO x_ret_mesg
            FROM mfg_lookups
            WHERE lookup_type = 'INV_MMX_RPT_MSGS'
            AND lookup_code = 2;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
  END re_wip;

  PROCEDURE Calculate_Excess(
               p_organization_id   IN NUMBER
              ,p_item_rec          IN csp_planner_notifications.item_list_rectype
              ,p_called_from       IN VARCHAR2 := 'NOTIF'
              ,p_notification_id   IN NUMBER := null
              ,p_order_by_date     IN DATE := sysdate
              ,x_excess_parts_tbl  OUT NOCOPY csp_planner_notifications.excess_parts_tbl
              ,x_return_status     OUT NOCOPY VARCHAR2
              ,x_msg_data          OUT NOCOPY VARCHAR2
              ,x_msg_count         OUT NOCOPY NUMBER) IS
    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_data          VARCHAR2(1000);
    l_msg_count         NUMBER;
    l_api_name          CONSTANT VARCHAR2(30) := 'calculate_excess';

    l_mcat_struct_id NUMBER;
    l_category_Set_id   NUMBER;
    l_item_select       VARCHAR2(800);
    l_cat_select        VARCHAR2(800);
    l_item              VARCHAR2(800);
    l_range_sql         VARCHAR2(2000);
    l_order_by          VARCHAR2(50);
    l_user_id           NUMBER;
    l_employee_id       NUMBER;
    l_Excess_qty        NUMBER;
    l_organization_type VARCHAR2(10);
    l_condition_type    VARCHAR2(10);
    idx                 NUMBER := 1;
    l_item_minmax_flag  NUMBER;
    l_sub_minmax_flag   NUMBER;

    l_onhand_source     NUMBER := 3;
    l_qoh               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_att               NUMBER;
    l_atr               NUMBER;

    CURSOR excess_sources_cur IS
       select misl.source_organization_id
       from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
       where cpp.organization_id = p_organization_id
       and misl.organization_id = cpp.organization_id
       and misl.assignment_set_id =cpp.usable_assignment_set_id
       and inventory_item_id = p_item_rec.inventory_item_id
       and SOURCE_TYPE       = 1
       and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                             where organization_id = p_organization_id
                             and assignment_set_id =  cpp.usable_assignment_set_id
                             and inventory_item_id = p_item_rec.inventory_item_id
                             and sourcing_level not in (2,9));

    CURSOR u_wrhs_subinv_cur(p_orgn_id NUMBER) IS
      SELECT secondary_inventory_name
      FROM mtl_secondary_inventories
      WHERE organization_id = p_orgn_id
      AND availability_type = 1;
   /*   AND secondary_inventory_name NOT IN
        (SELECT secondary_inventory_name
         FROM csp_sec_inventories
         WHERE condition_type = 'B'
         AND organization_id = p_orgn_id);
   */

    CURSOR d_wrhs_subinv_cur(p_orgn_id NUMBER) IS
      SELECT secondary_inventory_name
      FROM csp_sec_inventories
      WHERE organization_id = p_orgn_id
      AND condition_type = 'G';

    CURSOR employee_id_cur IS
      SELECT employee_id
      FROM fnd_user
      WHERE user_id = l_user_id;

  BEGIN
    SAVEPOINT Calculate_Excess_PUB;
    --initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Validate cat set and MCAT struct */
    IF p_item_rec.category_set_id is not null then
      SELECT STRUCTURE_ID
      into l_mcat_struct_id
      FROM MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = p_item_rec.category_set_id;
    ELSE
      SELECT CSET.CATEGORY_SET_ID, CSET.STRUCTURE_ID
      INTO l_category_set_id, l_mcat_struct_id
      FROM   MTL_CATEGORY_SETS CSET,
      MTL_DEFAULT_CATEGORY_SETS DEF
      WHERE  DEF.CATEGORY_SET_ID = CSET.CATEGORY_SET_ID
      AND    DEF.FUNCTIONAL_AREA_ID = 1;
    END IF;

    Build_item_cat_Select(l_mcat_struct_id,
                          l_item_Select,
                          l_cat_select);

    l_order_by := ' order by 1' ;
    l_user_id := nvl(fnd_global.user_id, 0) ;
    IF (p_item_rec.employee_id IS NOT NULL) THEN
      OPEN employee_id_cur;
      FETCH employee_id_cur INTO l_employee_id;
      CLOSE employee_id_cur;
    ELSE
      l_employee_id := p_item_rec.employee_id;
    END IF;

    Begin
        SELECT concatenated_segments
        INTO l_item
        FROM mtl_system_items_kfv
        WHERE inventory_item_id = p_item_rec.inventory_item_id;
    Exception
        WHEN OTHERS THEN
          null;
    END;

     Build_range_sql(
          p_cat_structure_id => l_mcat_struct_id
        , p_cat_lo           => null
        , p_cat_hi           => null
        , p_item_lo          => l_item
        , p_item_hi          => l_item
        , p_planner_lo       => null
        , p_planner_hi       => null
        , p_lot_ctl          => nvl(p_item_rec.lot_control, 3)
        , x_range_sql        => l_range_sql);

      idx := 1;

      FOR esc IN excess_sources_cur LOOP
        l_excess_qty := 0;

        BEGIN
          SELECT organization_type,
                 condition_type
          INTO l_organization_type,
               l_condition_type
          FROM csp_planning_parameters
          WHERE organization_id = esc.source_organization_id
          AND secondary_inventory IS NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_organization_type := 'F';
          WHEN OTHERS THEN
            l_organization_type := null;
        END;
        -- Find out if item is min-max planned in source or not.
        -- If not, calculate ATT for all source orgn and subinv
        -- Else, call Inventory API to calculate max.
        BEGIN
          SELECT inventory_planning_code
          INTO l_item_minmax_flag
          FROM mtl_system_items
          where organization_id = esc.source_organization_id
          and inventory_item_id = p_item_rec.inventory_item_id;
        EXCEPTION
          when no_data_found then
            l_item_minmax_flag := 0;
        END;

        IF (l_organization_type = 'W') THEN
          IF (l_item_minmax_flag <> 2) THEN   -- not minmax planned
            l_onhand_source := 2; --only nettable subinvs
            INV_Quantity_Tree_PUB.Query_Quantities
                ( p_api_version_number   => 1.0
                , p_init_msg_lst         => 'F'
                , x_return_status        => l_return_status
                , x_msg_count            => l_msg_count
                , x_msg_data             => l_msg_data
                , p_organization_id      => esc.source_organization_id
                , p_inventory_item_id    => p_item_Rec.inventory_item_id
                , p_tree_mode            => 2
                , p_onhand_source        => l_onhand_source
                , p_is_revision_control  => FALSE
                , p_is_lot_control       => FALSE
                , p_is_serial_control    => FALSE
                , p_lot_expiration_date  => sysdate
                , p_revision             => NULL
                , p_lot_number           => NULL
                , p_subinventory_code    => NULL
                , p_locator_id           => NULL
                , x_qoh                  => l_qoh
                , x_rqoh                 => l_rqoh
                , x_qr                   => l_qr
                , x_qs                   => l_qs
                , x_att                  => l_att
                , x_atr                  => l_atr
                );
            l_excess_qty := l_att;
          ELSE
            CSP_MINMAX_PVT.run_min_max_plan (
                  p_item_select     => l_item_select
                , p_handle_rep_item => 2
                , p_pur_revision    => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
                , p_cat_select      => l_Cat_select
                , p_cat_set_id      => nvl(p_item_rec.Category_set_id, l_category_set_id)
                , p_mcat_struct     => l_mcat_struct_id
                , p_level           => 1   -- run at orgn level
                , p_restock         => 2   -- no restock
                , p_include_nonnet  => 2   -- do not include non nettable subinv
                , p_include_po      => nvl(p_item_rec.include_po, 1)
                , p_include_wip     => nvl(p_item_rec.include_wip, 1)
                , p_include_if      => nvl(p_item_rec.include_iface_sup, 1)
                , p_net_rsv         => nvl(p_item_rec.net_rsv, 1)
                , p_net_unrsv       => nvl(p_item_rec.net_unrsv, 1)
                , p_net_wip         => nvl(p_item_rec.net_wip, 1)
                , p_org_id          => esc.source_organization_id
                , p_user_id         => l_user_id
                , p_employee_id     => l_employee_id
                , p_subinv          => null
                , p_dd_loc_id       => p_item_rec.dd_loc_id
                , p_wip_batch_id    => null --l_wip_batch_id
                , p_approval        => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                , p_buyer_hi        => null --p_buyer_hi
                , p_buyer_lo        => null --p_buyer_lo
                , p_range_buyer     => null --l_range_buyer
                , p_cust_id         => null --l_cust_id
                , p_po_org_id       => null --l_po_org_id
                , p_range_sql       => l_range_Sql
                , p_sort            => 1 --p_sort
                , p_selection       => 2    -- items above maximum quantity
                , p_sysdate         => sysdate
                , p_s_cutoff        => nvl(p_item_rec.s_cutoff, sysdate)
                , p_d_cutoff        => nvl(p_item_rec.d_cutoff, sysdate)
                , p_order_by        => l_order_by
                , p_encum_flag      => null --l_encum_flag
                , p_cal_code        => null --l_cal_code
                , p_exception_set_id => null --l_exception_set_id
                , x_return_status   => l_Return_status
                , x_msg_data        => l_msg_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                BEGIN
                  SELECT (tot_avail_qty - max_qty) excess_qty
                  INTO l_excess_qty
                  FROM INV_MIN_MAX_TEMP
                  WHERE item_Segments = l_item;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_Excess_qty := -1;
                  WHEN OTHERS THEN
                    l_Excess_qty := -2;
                  END;

                -- cleanup inv_min_max_Temp
                DELETE FROM INV_MIN_MAX_TEMP;
            END IF;
          END IF;
          IF (nvl(l_excess_qty, 0) > 0) THEN
            x_excess_parts_tbl(idx).quantity := l_excess_qty;
            x_excess_parts_tbl(idx).inventory_item_id := p_item_rec.inventory_item_id;
            x_excess_parts_tbl(idx).source_org_id := esc.source_organization_id;
            x_excess_parts_tbl(idx).source_subinv := null;

            IF (p_called_from = 'NOTIF') THEN
              Create_Notification_Details(
                p_notification_id => p_notification_id,
                p_order_by_dt     => p_order_by_date,
                p_source_type     => 'EXCESS',
                p_parts_rec       => x_excess_parts_tbl(idx));
            END If;
            idx := idx + 1;
          END If;
        ELSIF (l_organization_type = 'F') THEN
          -- field engineers organization, loop thru all usable subinv and
          -- run min max at subinv level for all subinvs if item is minmax planned
          -- else calculate ATT for each usable subinv
          FOR rsc IN d_wrhs_subinv_cur(esc.source_organization_id) LOOP
            BEGIN
              SELECT inventory_planning_code
              INTO   l_sub_minmax_flag
              FROM   mtl_item_sub_inventories
              WHERE organization_id = esc.source_organization_id
              AND secondary_inventory = rsc.secondary_inventory_name
              AND inventory_item_id = p_item_rec.inventory_item_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_sub_minmax_flag := 0;
            END;

            l_Excess_qty := 0;
            IF (l_item_minmax_flag = 2 AND l_sub_minmax_flag = 2) THEN
                -- minmax planned
                CSP_MINMAX_PVT.run_min_max_plan (
                  p_item_select     => l_item_select
                , p_handle_rep_item => 2
                , p_pur_revision    => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
                , p_cat_select      => l_Cat_select
                , p_cat_set_id      => nvl(p_item_rec.Category_set_id, l_category_set_id)
                , p_mcat_struct     => l_mcat_struct_id
                , p_level           => 2   -- run at organization level
                , p_restock         => 2   -- no restock
                , p_include_nonnet  => 1   -- include non nettable subinv
                , p_include_po      => nvl(p_item_rec.include_po, 1)
                , p_include_wip     => nvl(p_item_rec.include_wip, 1)
                , p_include_if      => nvl(p_item_rec.include_iface_sup, 1)
                , p_net_rsv         => nvl(p_item_rec.net_rsv, 1)
                , p_net_unrsv       => nvl(p_item_rec.net_unrsv, 1)
                , p_net_wip         => nvl(p_item_rec.net_wip, 1)
                , p_org_id          => esc.source_organization_id
                , p_user_id         => l_user_id
                , p_employee_id     => l_employee_id
                , p_subinv          => rsc.secondary_inventory_name
                , p_dd_loc_id       => p_item_rec.dd_loc_id
                , p_wip_batch_id    => null --l_wip_batch_id
                , p_approval        => to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'1'))
                , p_buyer_hi        => null --p_buyer_hi
                , p_buyer_lo        => null --p_buyer_lo
                , p_range_buyer     => null --l_range_buyer
                , p_cust_id         => null --l_cust_id
                , p_po_org_id       => null --l_po_org_id
                , p_range_sql       => l_range_Sql
                , p_sort            => 1 --p_sort
                , p_selection       => 2    -- items above maximum quantity
                , p_sysdate         => sysdate
                , p_s_cutoff        => nvl(p_item_rec.s_cutoff, sysdate)
                , p_d_cutoff        => nvl(p_item_rec.d_cutoff, sysdate)
                , p_order_by        => l_order_by
                , p_encum_flag      => null --l_encum_flag
                , p_cal_code        => null --l_cal_code
                , p_exception_set_id => null --l_exception_set_id
                , x_return_status   => l_Return_status
                , x_msg_data        => l_msg_data);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSE
                  BEGIN
                    SELECT (tot_avail_qty - max_qty) excess_qty
                    INTO l_excess_qty
                    FROM INV_MIN_MAX_TEMP
                    WHERE item_Segments = l_item;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_Excess_qty := -1;
                    WHEN OTHERS THEN
                      l_Excess_qty := -1;
                  END;
                  -- cleanup inv_min_max_Temp
                  DELETE FROM INV_MIN_MAX_TEMP;
                END If;
            ELSE
                INV_Quantity_Tree_PUB.Query_Quantities
                    ( p_api_version_number   => 1.0
                    , p_init_msg_lst         => 'F'
                    , x_return_status        => l_return_status
                    , x_msg_count            => l_msg_count
                    , x_msg_data             => l_msg_data
                    , p_organization_id      => esc.source_organization_id
                    , p_inventory_item_id    => p_item_Rec.inventory_item_id
                    , p_tree_mode            => 2
                    , p_onhand_source        => l_onhand_source
                    , p_is_revision_control  => FALSE
                    , p_is_lot_control       => FALSE
                    , p_is_serial_control    => FALSE
                    , p_lot_expiration_date  => sysdate
                    , p_revision             => NULL
                    , p_lot_number           => NULL
                    , p_subinventory_code    => rsc.secondary_inventory_name
                    , p_locator_id           => NULL
                    , x_qoh                  => l_qoh
                    , x_rqoh                 => l_rqoh
                    , x_qr                   => l_qr
                    , x_qs                   => l_qs
                    , x_att                  => l_att
                    , x_atr                  => l_atr
                    );
                l_excess_qty := l_att;

            END IF;

            IF (nvl(l_excess_qty, 0) > 0) THEN
              -- create output record
              x_excess_parts_tbl(idx).quantity := l_Excess_qty;
              x_excess_parts_tbl(idx).inventory_item_id := p_item_rec.inventory_item_id;
              x_excess_parts_tbl(idx).source_org_id := esc.source_organization_id;
              x_excess_parts_tbl(idx).source_subinv := rsc.secondary_inventory_name;
              IF (p_called_from = 'NOTIF') THEN
                  Create_Notification_Details(
                    p_notification_id => p_notification_id,
                    p_order_by_dt     => p_order_by_date,
                    p_source_type     => 'EXCESS',
                    p_parts_rec       => x_excess_parts_tbl(idx));
              END If;
              idx := idx + 1;
            END IF;
          END LOOP;
        END IF;
      END LOOP;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN

      Rollback to calculate_excess_pub;
      FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  PROCEDURE Generate_Repair_Recomm(
                 p_notification_id   IN     NUMBER
                ,p_organization_id   IN     NUMBER
                ,p_inventory_item_id IN     NUMBER
                ,p_order_by_Date     IN     DATE
                ,p_supercess_item_yn IN     VARCHAR2
                ) IS

    CURSOR repair_sources_cur IS
       select misl.source_organization_id
       from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
       where cpp.organization_id = p_organization_id
       and misl.organization_id = cpp.organization_id
       and misl.assignment_set_id =cpp.defective_assignment_set_id
       and inventory_item_id = p_inventory_item_id
       and SOURCE_TYPE       = 1
       and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                             where organization_id = p_organization_id
                             and assignment_set_id =  cpp.defective_assignment_set_id
                             and inventory_item_id = p_inventory_item_id
                             and sourcing_level not in (2,9));

    CURSOR repair_suppliers_cur IS
      select misl.source_type, misl.source_organization_id
       from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
       where cpp.organization_id = p_organization_id
       and misl.organization_id = cpp.organization_id
       and misl.assignment_set_id =cpp.repair_assignment_set_id
       and inventory_item_id = p_inventory_item_id
       and SOURCE_TYPE       in (1,3)
       and sourcing_level = (select min(sourcing_level) from MRP_ITEM_SOURCING_LEVELS_V
                             where organization_id = p_organization_id
                             and assignment_set_id =  cpp.repair_assignment_set_id
                             and inventory_item_id = p_inventory_item_id
                             and sourcing_level not in (2,9))
       order by misl.rank;

    CURSOR d_wrhs_subinv_cur(p_orgn_id NUMBER) IS
      SELECT secondary_inventory_name
      FROM mtl_secondary_inventories
      WHERE organization_id = p_orgn_id
      AND secondary_inventory_name NOT IN
        (SELECT secondary_inventory_name
         FROM csp_sec_inventories
         WHERE condition_type = 'G'
         AND organization_id = p_orgn_id);

    CURSOR u_wrhs_subinv_cur(p_orgn_id NUMBER) IS
      SELECT secondary_inventory_name
      FROM csp_sec_inventories
      WHERE organization_id = p_orgn_id
      AND condition_type = 'B';

    l_onhand_source     NUMBER := 3;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(1000);
    l_qoh               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_att               NUMBER;
    l_atr               NUMBER;
    l_repair_qty        NUMBER;
    l_organization_type VARCHAR2(10);
    l_condition_type    VARCHAR2(10);
    l_parts_rec         csp_planner_notifications.excess_parts_rectype;

    l_Serviceable       VARCHAR2(30);
    l_repair_supplier_id  NUMBER;
    l_source_type       VARCHAR2(30):= 'REPAIR';
  BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Find repair supplier for the warehouse
    FOR rsc IN repair_suppliers_cur LOOP
         IF (rsc.source_type = 1) THEN
           BEGIN
             select serv_req_enabled_code
             into l_Serviceable
             from mtl_system_items
             where inventory_item_id = p_inventory_item_id
             and organization_id = rsc.source_organization_id;
           EXCEPTION
             when no_data_found then
               null;
           END;
           IF l_serviceable = 'E' THEN
             l_repair_supplier_id := rsc.source_organization_id;
             l_source_type := 'REPAIR';
             exit;
           END IF;
         ELSE
           l_source_type := 'EXTREPAIR';
           exit;
         END IF;
     END LOOP;

     FOR rep IN repair_sources_cur LOOP
        BEGIN
          SELECT organization_type,
                 nvl(condition_type, 'G')
          INTO l_organization_type,
               l_condition_type
          FROM csp_planning_parameters
          WHERE organization_id = rep.source_organization_id
          AND secondary_inventory IS NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_organization_type := 'F';
          WHEN OTHERS THEN
            l_organization_type := null;
        END;

        IF (l_organization_type = 'W') THEN
          l_repair_qty := 0;
          IF (l_condition_type = 'B') THEN
            FOR wsc IN d_wrhs_subinv_cur(rep.source_organization_id) LOOP
              INV_Quantity_Tree_PUB.Query_Quantities
                ( p_api_version_number   => 1.0
                , p_init_msg_lst         => 'F'
                , x_return_status        => l_return_status
                , x_msg_count            => l_msg_count
                , x_msg_data             => l_msg_data
                , p_organization_id      => rep.source_organization_id
                , p_inventory_item_id    => p_inventory_item_id
                , p_tree_mode            => 2
                , p_onhand_source        => l_onhand_source   -- need to check out
                , p_is_revision_control  => FALSE
                , p_is_lot_control       => FALSE
                , p_is_serial_control    => FALSE
                , p_lot_expiration_date  => sysdate
                , p_revision             => NULL
                , p_lot_number           => NULL
                , p_subinventory_code    => wsc.secondary_inventory_name
                , p_locator_id           => NULL
                , x_qoh                  => l_qoh
                , x_rqoh                 => l_rqoh
                , x_qr                   => l_qr
                , x_qs                   => l_qs
                , x_att                  => l_att
                , x_atr                  => l_atr
                );
              IF (l_att > 0) THEN
                l_repair_qty := l_repair_qty + l_att;
              END IF;
            END LOOP;
            IF (l_repair_qty > 0) THEN
                -- call create notification details
                l_parts_rec.inventory_item_id := p_inventory_item_id;
                l_parts_Rec.source_org_id := rep.source_organization_id;
                l_parts_rec.source_subinv := null;
                l_parts_rec.quantity := l_repair_qty;
                l_parts_rec.repair_supplier_id := l_repair_supplier_id;

                Create_Notification_Details(
                  p_source_type       => l_source_type
                 ,p_order_by_dt       => p_order_by_date
                 ,p_notification_id   => p_notification_id
                 ,p_parts_rec         => l_parts_Rec);
            END IF;
          ELSE -- if warehouse is usable
            FOR wsc IN u_wrhs_subinv_cur(rep.source_organization_id) LOOP
              INV_Quantity_Tree_PUB.Query_Quantities
                ( p_api_version_number   => 1.0
                , p_init_msg_lst         => 'F'
                , x_return_status        => l_return_status
                , x_msg_count            => l_msg_count
                , x_msg_data             => l_msg_data
                , p_organization_id      => rep.source_organization_id
                , p_inventory_item_id    => p_inventory_item_id
                , p_tree_mode            => 2
                , p_onhand_source        => l_onhand_source   -- need to check out
                , p_is_revision_control  => FALSE
                , p_is_lot_control       => FALSE
                , p_is_serial_control    => FALSE
                , p_lot_expiration_date  => sysdate
                , p_revision             => NULL
                , p_lot_number           => NULL
                , p_subinventory_code    => wsc.secondary_inventory_name
                , p_locator_id           => NULL
                , x_qoh                  => l_qoh
                , x_rqoh                 => l_rqoh
                , x_qr                   => l_qr
                , x_qs                   => l_qs
                , x_att                  => l_att
                , x_atr                  => l_atr
                );
              IF (l_att > 0) THEN
                l_repair_qty := l_repair_qty + l_att;
              END IF;
            END LOOP;
            IF (l_repair_qty > 0) THEN
                -- call create notification details
                l_parts_rec.inventory_item_id := p_inventory_item_id;
                l_parts_Rec.source_org_id := rep.source_organization_id;
                l_parts_rec.source_subinv := null;
                l_parts_rec.quantity := l_repair_qty;
                l_parts_rec.repair_supplier_id := l_repair_supplier_id;

                Create_Notification_Details(
                  p_source_type       => l_source_type
                 ,p_order_by_dt       => p_order_by_date
                 ,p_notification_id   => p_notification_id
                 ,p_parts_rec         => l_parts_Rec);
            END IF;
          END IF;
        ELSE -- if FE organization
          FOR rsc IN u_wrhs_subinv_cur(rep.source_organization_id) LOOP
            --calculate ATT for each of the defective subinvs
            INV_Quantity_Tree_PUB.Query_Quantities
                ( p_api_version_number   => 1.0
                , p_init_msg_lst         => 'F'
                , x_return_status        => l_return_status
                , x_msg_count            => l_msg_count
                , x_msg_data             => l_msg_data
                , p_organization_id      => rep.source_organization_id
                , p_inventory_item_id    => p_inventory_item_id
                , p_tree_mode            => 2
                , p_onhand_source        => l_onhand_source   -- need to check out
                , p_is_revision_control  => FALSE
                , p_is_lot_control       => FALSE
                , p_is_serial_control    => FALSE
                , p_lot_expiration_date  => sysdate
                , p_revision             => NULL
                , p_lot_number           => NULL
                , p_subinventory_code    => rsc.secondary_inventory_name
                , p_locator_id           => NULL
                , x_qoh                  => l_qoh
                , x_rqoh                 => l_rqoh
                , x_qr                   => l_qr
                , x_qs                   => l_qs
                , x_att                  => l_att
                , x_atr                  => l_atr
                );
            IF (l_Att > 0) THEN
              -- call create notification details
              l_parts_rec.inventory_item_id := p_inventory_item_id;
              l_parts_Rec.source_org_id := rep.source_organization_id;
              l_parts_rec.source_subinv := rsc.secondary_inventory_name;
              l_parts_rec.quantity := l_att;
              l_parts_rec.repair_supplier_id := l_repair_supplier_id;

              Create_Notification_Details(
                p_source_type       => l_source_type
               ,p_order_by_dt       => p_order_by_date
               ,p_notification_id   => p_notification_id
               ,p_parts_rec         => l_parts_Rec);
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    -- elsif supercessed_item,
    IF (p_supercess_item_yn = 'Y') THEN
      -- calculate repair quantity in current organization.
      INV_Quantity_Tree_PUB.Query_Quantities
            ( p_api_version_number   => 1.0
            , p_init_msg_lst         => 'F'
            , x_return_status        => l_return_status
            , x_msg_count            => l_msg_count
            , x_msg_data             => l_msg_data
            , p_organization_id      => p_organization_id
            , p_inventory_item_id    => p_inventory_item_id
            , p_tree_mode            => 2
            , p_onhand_source        => l_onhand_source   -- need to check out
            , p_is_revision_control  => FALSE
            , p_is_lot_control       => FALSE
            , p_is_serial_control    => FALSE
            , p_lot_expiration_date  => sysdate
            , p_revision             => NULL
            , p_lot_number           => NULL
            , p_subinventory_code    => NULL
            , p_locator_id           => NULL
            , x_qoh                  => l_qoh
            , x_rqoh                 => l_rqoh
            , x_qr                   => l_qr
            , x_qs                   => l_qs
            , x_att                  => l_att
            , x_atr                  => l_atr
            );
        IF (l_att > 0) THEN
          -- call create notification details
          l_parts_rec.inventory_item_id := p_inventory_item_id;
          l_parts_Rec.source_org_id := p_organization_id;
          l_parts_rec.source_subinv := NULL; --rep.source_subinventory;
          l_parts_rec.quantity := l_att;
          l_parts_rec.repair_supplier_id := l_repair_supplier_id;

          Create_Notification_Details(
            p_source_type       => l_source_type
           ,p_order_by_Dt       => p_order_by_date
           ,p_notification_id   => p_notification_id
           ,p_parts_rec         => l_parts_Rec);
        END IF;
      END IF;

  END;

  PROCEDURE Cleanup_Notifications(p_organization_id   NUMBER) IS
  BEGIN
    DELETE FROM csp_notification_Details
    WHERE notification_id in
         (SELECT notification_id
          FROM csp_notifications
          WHERE trunc(nvl(suppress_end_date, sysdate)) <= trunc(sysdate)
          AND organization_id = p_organization_id);

    DELETE FROM csp_notifications
    WHERE trunc(nvl(suppress_end_date, sysdate)) <= trunc(sysdate)
    AND organization_id = p_organization_id;
  END;

  PROCEDURE Create_Notification_Details(
                 p_source_type      IN  VARCHAR2
                ,p_order_by_dt      IN  DATE := sysdate
                ,p_notification_id  IN  NUMBER
                ,p_parts_rec        IN  csp_planner_notifications.excess_parts_rectype) IS
  l_notif_detail_id NUMBER;
  BEGIN

       l_notif_detail_id := NULL;
       CSP_Notification_Details_PKG.Insert_Row(
            px_NOTIFICATION_DETAIL_ID   => l_notif_detail_id
           ,p_NOTIFICATION_ID           => p_notification_id
           ,p_INVENTORY_ITEM_ID         => p_parts_rec.inventory_item_id
           ,p_AVAILABLE_QUANTITY        => p_parts_rec.quantity
           ,p_ORDER_BY_DATE             => nvl(p_order_by_dt,sysdate)
           ,p_SOURCE_TYPE               => p_source_type
           ,p_SOURCE_ORGANIZATION_ID    => p_parts_rec.source_org_id
           ,p_SOURCE_SUBINVENTORY       => p_parts_rec.source_subinv
           ,p_CREATED_BY                => nvl(fnd_global.user_id, 0)
           ,p_CREATION_DATE             => sysdate
           ,p_LAST_UPDATED_BY           => nvl(fnd_global.user_id, 0)
           ,p_LAST_UPDATE_DATE          => sysdate
           ,p_LAST_UPDATE_LOGIN         => nvl(fnd_global.login_id, -1)
           ,p_ATTRIBUTE_CATEGORY        => null
           ,p_ATTRIBUTE1                => null
           ,p_ATTRIBUTE2                => null
           ,p_ATTRIBUTE3                => null
           ,p_ATTRIBUTE4                => null
           ,p_ATTRIBUTE5                => null
           ,p_ATTRIBUTE6                => null
           ,p_ATTRIBUTE7                => null
           ,p_ATTRIBUTE8                => null
           ,p_ATTRIBUTE9                => null
           ,p_ATTRIBUTE10               => null
           ,p_ATTRIBUTE11               => null
           ,p_ATTRIBUTE12               => null
           ,p_ATTRIBUTE13               => null
           ,p_ATTRIBUTE14               => null
           ,p_ATTRIBUTE15               => null
           ,p_REPAIR_SUPPLIER_ID        => p_parts_rec.repair_supplier_id
           ,p_ORDER_NUMBER              => NULL
         );
  END;
END;

/
