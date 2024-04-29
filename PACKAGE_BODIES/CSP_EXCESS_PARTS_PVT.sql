--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_PARTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_PARTS_PVT" AS
/* $Header: cspvpexb.pls 120.3.12010000.22 2014/01/24 19:52:46 hhaugeru ship $ */
 G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_EXCESS_PARTS_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(30):='cspvpexb.pls';

 g_node_level_id Varchar2(2000):= 1;

  PROCEDURE NODE_LEVEL_ID(p_level_id IN VARCHAR2)
  IS
  BEGIN
    g_node_level_id := p_level_id;
  End;

  FUNCTION NODE_LEVEL_ID return VARCHAR2 is
  BEGIN
    return(g_node_level_id);
  End;

  Procedure excess_parts
     ( errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_org_id                 IN NUMBER
      ,P_level_id               IN VARCHAR2
      ,p_level			IN NUMBER
      ,P_SUBINV_ENABLE_FLAG     IN NUMBER
      ,p_subinv                 IN VARCHAR2
      ,p_selection              IN NUMBER
      ,p_cat_set_id             IN NUMBER
      ,p_catg_struct_id	        IN NUMBER
      ,p_Catg_lo                IN VARCHAR2
      ,p_catg_hi                IN VARCHAR2
      ,p_item_lo                IN VARCHAR2
      ,p_item_hi                IN VARCHAR2
      ,p_planner_lo             IN VARCHAR2
      ,p_planner_hi             IN VARCHAR2
      ,p_buyer_lo               IN VARCHAR2
      ,p_buyer_hi               IN VARCHAR2
      ,p_sort                   IN VARCHAR2
      ,p_d_cutoff               IN VARCHAR2
      ,p_d_cutoff_rel           IN NUMBER
      ,p_s_cutoff               IN VARCHAR2
      ,p_s_cutoff_rel           IN NUMBER
      ,p_user_id                IN NUMBER
      ,p_restock                IN NUMBER
      ,p_handle_rep_item        IN NUMBER
      ,p_dd_loc_id              IN NUMBER
      ,p_net_unrsv              IN NUMBER
      ,p_net_rsv                IN NUMBER
      ,p_net_wip                IN NUMBER
      ,p_include_po             IN NUMBER
      ,p_include_wip            IN NUMBER
      ,p_include_if             IN NUMBER
      ,p_include_nonnet         IN NUMBER
      ,p_lot_ctl                IN NUMBER
      ,p_display_mode           IN NUMBER
      ,p_show_desc              IN NUMBER
      ,p_pur_revision           IN NUMBER
      ,p_called_from            IN VARCHAR2
     ) IS

  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'Create Excess Parts';
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
  l_org_name                VARCHAR2(2000);
  l_encum_flag              VARCHAR2(30) := 'N';
  l_cal_code                VARCHAR2(30);
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

  l_level			       NUMBER;
  p_organization_id         NUMBER;
  p_subinventory_code       VARCHAR2(2000);
  p_condition_type          VARCHAR2(200);
  l_item_id Number;

  l_total_onhand      number := 0;
  l_onhand            number := 0;
  l_demand            number := 0;
  l_previous_item_id  number;
  l_excess            number := 0;
  l_max               number := 0;
  x_excess_line_id    number;
  l_excess_rule_id    number;
  L_LOC_ASSIGNMENT_ID number;

  -- bug # 8518127
  v_excess_part CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE  :=  CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
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

    l_item_attr_rec     item_attr_cur%ROWTYPE;

    CURSOR PLANNING_NODE_REC IS
    SELECT cpp.NODE_TYPE,cpp.ORGANIZATION_ID,cpp.SECONDARY_INVENTORY,cpp.CONDITION_TYPE,
           cpp.planning_parameters_id,cpp.level_id,csin.parts_loop_id,csin.hierarchy_node_id,
           csin.owner_resource_id, csin.owner_resource_type
    FROM   CSP_PLANNING_PARAMETERS cpp,csp_sec_inventories csin
    WHERE  LEVEL_ID LIKE p_level_id||'%'
    and    cpp.organization_id = csin.organization_id(+)
    and    cpp.secondary_inventory = csin.secondary_inventory_name(+);

    cursor effective_subinv(p_resource_id Number,
                            p_resource_type varchar2,
                            p_organization_id  Number,
                            p_subinventory_code Varchar2)
    is
    select CSP_INV_LOC_ASSIGNMENT_ID from csp_inv_loc_assignments
    where resource_id = p_resource_id and
          resource_type = p_resource_type and
          organization_id = p_organization_id and
          SUBINVENTORY_CODE = p_subinventory_code and
          (EFFECTIVE_DATE_END is null or trunc(EFFECTIVE_DATE_END) > trunc(sysdate));

    Cursor INV_MIN_MAX_TEMP IS
     SELECT ITEM_SEGMENTS,MIN_QTY,MAX_QTY,ONHAND_QTY,SUPPLY_QTY,DEMAND_QTY,
            TOT_AVAIL_QTY,MIN_ORD_QTY,MAX_ORD_QTY,FIX_MULT,REORD_QTY
       FROM INV_MIN_MAX_TEMP
      WHERE NVL(TOT_AVAIL_QTY,0) - NVL(MAX_QTY,0) > 0;

    cursor c_org_items is
    select  distinct moq.inventory_item_id,
            nvl(msib.max_minmax_quantity,0) max,
            revision_qty_control_code
    from    mtl_onhand_quantities_detail moq,
            mtl_system_items_b msib
    where   moq.organization_id = p_organization_id
    and     msib.organization_id = moq.organization_id
    and     msib.inventory_item_id = moq.inventory_item_id
    and     nvl(msib.INVENTORY_PLANNING_CODE,6) = 6;

    cursor c_org_subinventories(c_inventory_item_id number) is
    select  distinct moq.subinventory_code
    from    mtl_onhand_quantities moq,
            csp_planning_parameters cpp
    where   moq.organization_id = p_organization_id
    and     moq.inventory_item_id = c_inventory_item_id
    and     cpp.organization_id  = moq.organization_id
    and     cpp.secondary_inventory  = moq.subinventory_code
    and     cpp.condition_type = 'G';

    cursor c_subinventories is
    select msi.secondary_inventory_name
    from   mtl_secondary_inventories msi,
           csp_planning_parameters cpp
    where  msi.organization_id = p_organization_id
    and    msi.secondary_inventory_name = nvl(p_subinventory_code,msi.secondary_inventory_name)
    and    cpp.organization_id = msi.organization_id
    and    cpp.secondary_inventory = msi.secondary_inventory_name
    and    cpp.condition_type = 'G';

    cursor c_sub_items(c_subinventory_code varchar2) is
    select  mosv.inventory_item_id,
            nvl(misi.max_minmax_quantity,0) max,
            msib.revision_qty_control_code
    from    mtl_onhand_sub_v mosv,
            mtl_item_sub_inventories misi,
            mtl_system_items_b msib
    where   mosv.organization_id = p_organization_id
    and     mosv.subinventory_code = c_subinventory_code
    and     misi.organization_id(+) = mosv.organization_id
    and     misi.inventory_item_id(+) = mosv.inventory_item_id
    and     misi.secondary_inventory(+) = mosv.subinventory_code
    and     msib.organization_id = mosv.organization_id
    and     msib.inventory_item_id = mosv.inventory_item_id
    and     nvl(misi.INVENTORY_PLANNING_CODE,6) = 6
/* Added to avoid duplicate rows of revision controled item */
group by    mosv.inventory_item_id,
            misi.max_minmax_quantity,
            msib.revision_qty_control_code;
Begin
    SAVEPOINT Create_excess_parts_PUB;

    SELECT Sysdate INTO l_today FROM dual;
    l_user_id := nvl(fnd_global.user_id, 0) ;
    l_login_id := nvl(fnd_global.login_id, -1);

FOR Rec IN PLANNING_NODE_REC LOOP
IF (Rec.NODE_TYPE <> 'REGION' AND Rec.ORGANIZATION_ID is NOT NULL) THEN

    If (Rec.owner_resource_id is NOT NULL and
        Rec.NODE_TYPE = 'SUBINVENTORY' and
        Rec.SECONDARY_INVENTORY is NOT NULL) THEN

        open effective_subinv(Rec.owner_resource_id,Rec.owner_resource_type,Rec.ORGANIZATION_ID,Rec.SECONDARY_INVENTORY);
        fetch effective_subinv into L_LOC_ASSIGNMENT_ID;
        close effective_subinv;
    End if;

    If (Rec.NODE_TYPE = 'ORGANIZATION_WH') OR
       (Rec.NODE_TYPE = 'SUBINVENTORY' and
        Rec.SECONDARY_INVENTORY is NOT NULL and
         (Rec.owner_resource_id is NULL or
            (Rec.owner_resource_id is NOT NULL and
             L_LOC_ASSIGNMENT_ID is NOT NULL)
         )
       )
    THEN

    IF (Rec.NODE_TYPE = 'SUBINVENTORY' and Rec.SECONDARY_INVENTORY is NOT NULL) THEN
      p_organization_id := Rec.ORGANIZATION_ID;
      l_level	 := 2;
      p_subinventory_code := Rec.SECONDARY_INVENTORY;
      p_condition_type := REC.CONDITION_TYPE;
    Elsif (Rec.NODE_TYPE = 'ORGANIZATION_WH') THEN
      p_organization_id := Rec.ORGANIZATION_ID;
      l_level	 := 1;
      p_subinventory_code := Null;
      p_condition_type := Null;
    End if;

    --Delete remaining open excess lines from previous run
    if p_called_from = 'STD' then
      clean_up(p_organization_id   => p_organization_id,
             p_subinventory_code => p_subinventory_code,
             p_condition_type    => p_condition_type);
    end if;
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
    end if;

    -- get employee id
    OPEN employee_id_cur;
    FETCH employee_id_cur INTO l_employee_id;
    CLOSE employee_id_cur;

    l_d_cutoff := to_date(p_d_cutoff,'YYYY/MM/DD HH24:MI:SS');
    l_s_cutoff := to_date(p_s_cutoff,'YYYY/MM/DD HH24:MI:SS');
    l_D_CUTOFF := NVL(l_D_CUTOFF, SYSDATE);
    l_S_CUTOFF := NVL(l_S_CUTOFF, SYSDATE);

    IF (P_D_CUTOFF_REL IS NOT NULL) THEN
 	    l_D_CUTOFF := NVL(l_D_CUTOFF, sysdate) + P_D_CUTOFF_REL;
    END IF;

    IF (P_S_CUTOFF_REL IS NOT NULL) THEN
	    l_S_CUTOFF := NVL(l_S_CUTOFF, sysdate) + P_S_CUTOFF_REL;
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
    IF (p_cat_set_id is not null and p_catg_struct_id is not null) then
      SELECT STRUCTURE_ID
      into l_mcat_struct_id
      FROM MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = p_cat_set_id;
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
        , p_cat_lo           => p_Catg_lo
        , p_cat_hi           => p_catg_hi
        , p_item_lo          => p_item_lo
        , p_item_hi          => p_item_hi
        , p_planner_lo       => p_planner_lo
        , p_planner_hi       => p_planner_hi
        , p_lot_ctl          => p_lot_Ctl
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

    if p_called_from <> 'PART_STATUS' and nvl(p_condition_type,'B') = 'B' then
       defective_return(p_organization_id,
                        p_subinventory_code,
                        rec.planning_parameters_id,
                        rec.level_id,
                        rec.parts_loop_id,
                        rec.hierarchy_node_id,
                        p_called_from);
    end if;

    if nvl(p_condition_type,'G') = 'G' then
       CSP_MINMAX_PVT.run_min_max_plan(
              p_item_select     => l_item_select
            , p_handle_rep_item => p_handle_rep_item
            , p_pur_revision    => nvl(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)
            , p_cat_select      => l_Cat_select
            , p_cat_set_id      => nvl(p_Cat_set_id,l_category_set_id)
            , p_mcat_struct     => l_mcat_struct_id
            , p_level           => l_level
            , p_restock         => 2
            , p_include_nonnet  => p_include_nonnet
            , p_include_po      => p_include_po
            , p_include_wip     => p_include_wip
            , p_include_if      => p_include_if
            , p_net_rsv         => p_net_rsv
            , p_net_unrsv       => p_net_unrsv
            , p_net_wip         => p_net_wip
            , p_org_id          => p_organization_id
            , p_user_id         => l_user_id
            , p_employee_id     => l_employee_id
            , p_subinv          => p_subinventory_code
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
            , p_s_cutoff        => l_s_cutoff
            , p_d_cutoff        => l_d_cutoff
            , p_order_by        => l_order_by
            , p_encum_flag      => l_encum_flag
            , p_cal_code        => l_cal_code
            , p_exception_set_id => l_exception_set_id
            , x_return_status   => l_Return_status
            , x_msg_data        => l_msg_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

     --ORGANIZATION Level
   --if l_level = 1 then

        For INV_REC IN INV_MIN_MAX_TEMP LOOP

        Begin
        SELECT msik.inventory_item_id
        INTO l_item_id
        FROM mtl_system_items_kfv msik
        WHERE msik.concatenated_segments = inv_rec.item_segments
        AND msik.organization_id = p_organization_id;
        Exception
        When no_data_found then
          l_item_id := Null;
        End;

        if p_called_from = 'PART_STATUS' then
          insert into csp_sup_dem_sub_temp(
            inventory_item_id,
            organization_id,
            subinventory_code,
            planning_parameters_id,
            level_id,
            parts_loop_id,
            hierarchy_node_id,
            excess_quantity)
          values(
            l_item_id,
            p_organization_id,
            p_subinventory_code,
            rec.planning_parameters_id,
            rec.level_id,
            rec.parts_loop_id,
            rec.hierarchy_node_id,
            NVL(inv_rec.TOT_AVAIL_QTY,0) - NVL(inv_rec.MAX_QTY,0));
        else
        x_excess_line_id := null;
        /*
        csp_excess_lists_pkg.Insert_Row(
            px_EXCESS_LINE_ID     => x_excess_line_id,
            p_CREATED_BY          => fnd_global.user_id,
            p_CREATION_DATE       => sysdate,
            p_LAST_UPDATED_BY     => fnd_global.user_id,
            p_LAST_UPDATE_DATE    => sysdate,
            p_LAST_UPDATE_LOGIN   => null,
            p_ORGANIZATION_ID     => p_organization_id,
            p_SUBINVENTORY_CODE   => p_subinventory_code,
            p_CONDITION_CODE      => 'G',
            p_INVENTORY_ITEM_ID   => l_item_id,
            p_EXCESS_QUANTITY     => NVL(inv_rec.TOT_AVAIL_QTY,0) - NVL(inv_rec.MAX_QTY,0),
            p_EXCESS_STATUS       => 'P',
            p_REQUISITION_LINE_ID => null,
            p_RETURNED_QUANTITY   => null,
            p_current_return_qty  => null,
            p_ATTRIBUTE_CATEGORY  => null,
            p_ATTRIBUTE1          => null,
            p_ATTRIBUTE2          => null,
            p_ATTRIBUTE3          => null,
            p_ATTRIBUTE4          => null,
            p_ATTRIBUTE5          => null,
            p_ATTRIBUTE6          => null,
            p_ATTRIBUTE7          => null,
            p_ATTRIBUTE8          => null,
            p_ATTRIBUTE9          => null,
            p_ATTRIBUTE10         => null,
            p_ATTRIBUTE11         => null,
            p_ATTRIBUTE12         => null,
            p_ATTRIBUTE13         => null,
            p_ATTRIBUTE14         => null,
            p_ATTRIBUTE15         => null);
            */


            v_excess_part := CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
            v_excess_part.CREATED_BY := fnd_global.user_id;
            v_excess_part.CREATION_DATE := sysdate;
            v_excess_part.LAST_UPDATED_BY := fnd_global.user_id;
            v_excess_part.LAST_UPDATE_DATE := sysdate;
            v_excess_part.ORGANIZATION_ID := p_organization_id;
            v_excess_part.SUBINVENTORY_CODE := p_subinventory_code;
            v_excess_part.CONDITION_CODE := 'G';
            v_excess_part.INVENTORY_ITEM_ID := l_item_id;
            v_excess_part.EXCESS_QUANTITY := NVL(inv_rec.TOT_AVAIL_QTY,0) - NVL(inv_rec.SUPPLY_QTY,0) - NVL(inv_rec.MAX_QTY,0);
            v_excess_part.EXCESS_STATUS := 'P';

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_EXCESS_PARTS_PVT.excess_parts',
                          'Calling populate_excess_list 1');
            end if;

            populate_excess_list(v_excess_part);

         end if;
       End loop;

       update CSP_SEC_INVENTORIES
       set last_excess_run_date = sysdate
       where organization_id = p_organization_id
       and secondary_inventory_name = nvl(p_subinventory_code, secondary_inventory_name);


     --ORGANIZATION Level

     if l_level = 1 then
        for coi in c_org_items loop
        l_total_onhand := 0;
        l_onhand := 0;
        l_demand := 0;
        l_excess := 0;

        --for cos in c_org_subinventories(coi.inventory_item_id) loop
          l_onhand := csp_excess_parts_pvt.onhand(
                        p_organization_id     => p_organization_id,
                        p_inventory_item_id   => coi.inventory_item_id,
                        --p_subinventory_code   => cos.subinventory_code,
                        p_subinventory_code   => NULL,
                        p_revision_qty_control_code => coi.revision_qty_control_code,
                        p_include_nonnet		=> p_include_nonnet,
                        p_planning_level		=> l_level);

          l_total_onhand := l_total_onhand + l_onhand;
        --end loop;

        l_demand := csp_excess_parts_pvt.demand(
                      p_organization_id   => p_organization_id,
                      p_inventory_item_id => coi.inventory_item_id,
                      p_subinventory_code => null,
                      p_include_nonnet    => p_include_nonnet,
                      p_planning_level    => l_level,
                      p_net_unreserved    => p_net_unrsv,
                      p_net_reserved      => p_net_rsv,
                      p_net_wip           => p_net_wip,
                      p_demand_cutoff     => P_D_CUTOFF_REL); -- number of days

        l_excess := nvl(l_total_onhand,0) - nvl(l_demand,0);

        if l_excess > 0 then
          if p_called_from = 'PART_STATUS' then
            insert into csp_sup_dem_sub_temp(
              inventory_item_id,
              organization_id,
              subinventory_code,
              planning_parameters_id,
              level_id,
              parts_loop_id,
              hierarchy_node_id,
              excess_quantity)
            values(
              coi.inventory_item_id,
              p_organization_id,
              null,
              rec.planning_parameters_id,
              rec.level_id,
              rec.parts_loop_id,
              rec.hierarchy_node_id,
              l_excess);
          else
          x_excess_line_id := null;
          /*
          csp_excess_lists_pkg.Insert_Row(
            px_EXCESS_LINE_ID     => x_excess_line_id,
            p_CREATED_BY          => fnd_global.user_id,
            p_CREATION_DATE       => sysdate,
            p_LAST_UPDATED_BY     => fnd_global.user_id,
            p_LAST_UPDATE_DATE    => sysdate,
            p_LAST_UPDATE_LOGIN   => null,
            p_ORGANIZATION_ID     => p_organization_id,
            p_SUBINVENTORY_CODE   => null,
            p_CONDITION_CODE      => 'G',
            p_INVENTORY_ITEM_ID   => coi.inventory_item_id,
            p_EXCESS_QUANTITY     => l_excess,
            p_EXCESS_STATUS       => 'P',
            p_REQUISITION_LINE_ID => null,
            p_RETURNED_QUANTITY   => null,
            p_current_return_qty  => null,
            p_ATTRIBUTE_CATEGORY  => null,
            p_ATTRIBUTE1          => null,
            p_ATTRIBUTE2          => null,
            p_ATTRIBUTE3          => null,
            p_ATTRIBUTE4          => null,
            p_ATTRIBUTE5          => null,
            p_ATTRIBUTE6          => null,
            p_ATTRIBUTE7          => null,
            p_ATTRIBUTE8          => null,
            p_ATTRIBUTE9          => null,
            p_ATTRIBUTE10         => null,
            p_ATTRIBUTE11         => null,
            p_ATTRIBUTE12         => null,
            p_ATTRIBUTE13         => null,
            p_ATTRIBUTE14         => null,
            p_ATTRIBUTE15         => null);
            */

            v_excess_part := CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
            v_excess_part.CREATED_BY := fnd_global.user_id;
            v_excess_part.CREATION_DATE := sysdate;
            v_excess_part.LAST_UPDATED_BY := fnd_global.user_id;
            v_excess_part.LAST_UPDATE_DATE := sysdate;
            v_excess_part.ORGANIZATION_ID := p_organization_id;
            v_excess_part.CONDITION_CODE := 'G';
            v_excess_part.INVENTORY_ITEM_ID := coi.inventory_item_id;
            v_excess_part.EXCESS_QUANTITY := l_excess;
            v_excess_part.EXCESS_STATUS := 'P';

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                          'csp.plsql.CSP_EXCESS_PARTS_PVT.excess_parts',
                          'Calling populate_excess_list 2');
            end if;

            populate_excess_list(v_excess_part);

          end if;
        end if;

      end loop;

      update CSP_SEC_INVENTORIES
      set last_excess_run_date = sysdate
      where organization_id = p_organization_id;

    end if;

  -- SUBINVENTORY Level
    if l_level = 2 then
      for curs in c_subinventories loop
        for csin in c_sub_items(curs.secondary_inventory_name) loop
          l_onhand := csp_excess_parts_pvt.onhand(
                        p_organization_id     => p_organization_id,
                        p_inventory_item_id   => csin.inventory_item_id,
                        p_subinventory_code   => curs.secondary_inventory_name,
                        p_revision_qty_control_code => csin.revision_qty_control_code,
                        p_include_nonnet      => p_include_nonnet,
                        p_planning_level      => l_level);

          l_demand := csp_excess_parts_pvt.demand(
                        p_organization_id   => p_organization_id,
                        p_inventory_item_id => csin.inventory_item_id,
                        p_subinventory_code => curs.secondary_inventory_name,
                        p_include_nonnet    => p_include_nonnet,
                        p_planning_level    => l_level,
                        p_net_unreserved    => p_net_unrsv,
                        p_net_reserved      => p_net_rsv,
                        p_net_wip           => p_net_wip,
                        p_demand_cutoff     => P_D_CUTOFF_REL);

          l_excess := nvl(l_onhand,0) - nvl(l_demand,0);

          if nvl(l_excess,0) > 0 then
            if p_called_from = 'PART_STATUS' then
              insert into csp_sup_dem_sub_temp(
                inventory_item_id,
                organization_id,
                subinventory_code,
                planning_parameters_id,
                level_id,
                parts_loop_id,
                hierarchy_node_id,
                excess_quantity)
              values(
                csin.inventory_item_id,
                p_organization_id,
                curs.secondary_inventory_name,
                rec.planning_parameters_id,
                rec.level_id,
                rec.parts_loop_id,
                rec.hierarchy_node_id,
                l_excess);
            else
            x_excess_line_id := null;
            /*
            csp_excess_lists_pkg.Insert_Row(
              px_EXCESS_LINE_ID     => x_excess_line_id,
              p_CREATED_BY          => fnd_global.user_id,
              p_CREATION_DATE       => sysdate,
              p_LAST_UPDATED_BY     => fnd_global.user_id,
              p_LAST_UPDATE_DATE    => sysdate,
              p_LAST_UPDATE_LOGIN   => null,
              p_ORGANIZATION_ID     => p_organization_id,
              p_SUBINVENTORY_CODE   => curs.secondary_inventory_name,
              p_CONDITION_CODE      => 'G',
              p_INVENTORY_ITEM_ID   => csin.inventory_item_id,
              p_EXCESS_QUANTITY     => l_excess,
              p_EXCESS_STATUS       => 'P',
              p_REQUISITION_LINE_ID => null,
              p_RETURNED_QUANTITY   => null,
              p_current_return_qty  => null,
              p_ATTRIBUTE_CATEGORY  => null,
              p_ATTRIBUTE1          => null,
              p_ATTRIBUTE2          => null,
              p_ATTRIBUTE3          => null,
              p_ATTRIBUTE4          => null,
              p_ATTRIBUTE5          => null,
              p_ATTRIBUTE6          => null,
              p_ATTRIBUTE7          => null,
              p_ATTRIBUTE8          => null,
              p_ATTRIBUTE9          => null,
              p_ATTRIBUTE10         => null,
              p_ATTRIBUTE11         => null,
              p_ATTRIBUTE12         => null,
              p_ATTRIBUTE13         => null,
              p_ATTRIBUTE14         => null,
              p_ATTRIBUTE15         => null);
              */

              v_excess_part := CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
              v_excess_part.CREATED_BY := fnd_global.user_id;
              v_excess_part.CREATION_DATE := sysdate;
              v_excess_part.LAST_UPDATED_BY := fnd_global.user_id;
              v_excess_part.LAST_UPDATE_DATE := sysdate;
              v_excess_part.ORGANIZATION_ID := p_organization_id;
              v_excess_part.SUBINVENTORY_CODE := curs.secondary_inventory_name;
              v_excess_part.CONDITION_CODE := 'G';
              v_excess_part.INVENTORY_ITEM_ID := csin.inventory_item_id;
              v_excess_part.EXCESS_QUANTITY := l_excess;
              v_excess_part.EXCESS_STATUS := 'P';

              if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'csp.plsql.CSP_EXCESS_PARTS_PVT.excess_parts',
                            'Calling populate_excess_list 3');
              end if;

              populate_excess_list(v_excess_part);
            end if;
          end if;

        end loop;

         update CSP_SEC_INVENTORIES
         set last_excess_run_date = sysdate
         where organization_id = p_organization_id
         and secondary_inventory_name = nvl(curs.secondary_inventory_name, secondary_inventory_name);

      end loop;
    end if;
    if p_called_from <> 'PART_STATUS' then
       l_excess_rule_id := get_business_rule(
                              p_organization_id   => p_organization_id,
                              p_subinventory_code => p_subinventory_code);

       if l_excess_rule_id is not null then
           csp_excess_parts_pvt.apply_business_rules(
           p_organization_id   => p_organization_id,
           p_subinventory_code => p_subinventory_code,
           p_excess_rule_id    => l_excess_rule_id);
       else
            update csp_excess_lists
            set excess_status = 'O'
            where excess_status = 'P';
            commit;
       end if;
     end if;
  end if;
 end if;
End if;
  Delete from INV_MIN_MAX_TEMP;
End loop;

exception
  when others then
  null;
end;

procedure apply_business_rules(
  p_organization_id     number,
  p_subinventory_code   varchar2,
  p_excess_rule_id      number) as


  cursor business_rule is
  select  cerb.excess_rule_id,
          cerb.total_max_excess,
          cerb.line_max_excess,
          cerb.total_excess_value,
          cerb.days_since_receipt,
          cerb.top_excess_lines,
          cerb.category_set_id,
          cerb.category_id
  from    csp_excess_rules_b cerb
  where   excess_rule_id = p_excess_rule_id;

  br_rec      business_rule%rowtype;

  cursor  excess_value is
  select  sum(cel.excess_quantity * NVL(ITEM_COST,0))
  from    CST_ITEM_COSTS cic,
          CST_COST_TYPES cct,
          csp_excess_lists cel
  where   cic.ORGANIZATION_ID   = cel.organization_id
  and     cic.inventory_item_id = cel.inventory_item_id
  and     cic.COST_TYPE_ID      = cct.COST_TYPE_ID
  and     cct.COST_TYPE_ID      = cct.DEFAULT_COST_TYPE_ID
  and     cel.excess_status     = 'P';

  cursor org_max_value is
  select  sum(msib.max_minmax_quantity * NVL(ITEM_COST,0))
  from    CST_ITEM_COSTS cic,
          CST_COST_TYPES cct,
          mtl_system_items_b msib
  where   msib.organization_id   = p_organization_id
  and     cic.ORGANIZATION_ID   = msib.organization_id
  and     cic.inventory_item_id = msib.inventory_item_id
  and     cic.COST_TYPE_ID      = cct.COST_TYPE_ID
  and     cct.COST_TYPE_ID      = cct.DEFAULT_COST_TYPE_ID
  and     msib.max_minmax_quantity > 0;

  cursor sub_max_value is
  select sum(misi.max_minmax_quantity * nvl(cic.item_cost,0))
  from cst_item_costs cic,
          cst_cost_types cct,
          mtl_item_sub_inventories misi
  where   misi.organization_id = p_organization_id
  and     misi.secondary_inventory = p_subinventory_code
  and     cic.organization_id = misi.organization_id
  and     cic.inventory_item_id = misi.inventory_item_id
  and     cic.cost_type_id = cct.cost_type_id
  and     cct.cost_type_id = cct.default_cost_type_id
  and     misi.max_minmax_quantity > 0;

  cursor org_line_quantity is
  select  cel.excess_line_id,
          cel.excess_quantity,
          msib.max_minmax_quantity
  from    csp_excess_lists cel,
          mtl_system_items_b  msib
  where   cel.organization_id = p_organization_id
  and     cel.organization_id = msib.organization_id
  and     cel.inventory_item_id = msib.inventory_item_id
  and     cel.excess_status     = 'P';

  cursor sub_line_quantity is
  select  cel.excess_line_id,
          cel.excess_quantity,
          misi.max_minmax_quantity
  from    csp_excess_lists cel,
          mtl_item_sub_inventories misi
  where   cel.organization_id = p_organization_id
  and     cel.organization_id = misi.organization_id
  and     cel.subinventory_code = misi.secondary_inventory
  and     cel.inventory_item_id = misi.inventory_item_id
  and     cel.excess_status     = 'P';

  cursor org_recently_received(p_inventory_item_id number) is
  select  mmt.transaction_date
  from    mtl_material_transactions mmt
  where   mmt.organization_id = p_organization_id
  and     mmt.inventory_item_id = p_inventory_item_id
  and     mmt.transaction_action_id in (2,3,12,27,31)
  and     mmt.transaction_quantity > 0
  and     mmt.transaction_date > sysdate - br_rec.days_since_receipt;

  cursor sub_recently_received(p_inventory_item_id number) is
  select  mmt.transaction_date
  from    mtl_material_transactions mmt
  where   mmt.organization_id = p_organization_id
  and     mmt.subinventory_code = p_subinventory_code
  and     mmt.inventory_item_id = p_inventory_item_id
  and     mmt.transaction_action_id in (2,3,12,27,31)
  and     mmt.transaction_quantity > 0
  and     mmt.transaction_date > sysdate - br_rec.days_since_receipt;

  cursor excess_lines is
  select  cel.excess_line_id,
          cel.inventory_item_id
  from    csp_excess_lists cel
  where   cel.organization_id = p_organization_id
  and     cel.excess_status     = 'P';

  cursor excess_line_value is
  select  cel.excess_line_id,
          cel.excess_quantity * NVL(ITEM_COST,0) value
  from    CST_ITEM_COSTS cic,
          CST_COST_TYPES cct,
          csp_excess_lists cel
  where   cel.organization_id   = p_organization_id
  and     cic.ORGANIZATION_ID   = cel.organization_id
  and     cic.inventory_item_id = cel.inventory_item_id
  and     cic.COST_TYPE_ID      = cct.COST_TYPE_ID
  and     cct.COST_TYPE_ID      = cct.DEFAULT_COST_TYPE_ID
  and     cel.excess_status     = 'P'
  order by value desc;


  l_excess_value        number;
  l_max_value           number;
  l_excess_percentage   number;
  l_line_quantity       number;
  l_received_date       date;
  l_days_since_receipt  number;
  l_counter             number;
  l_value		number;


begin
-- Fetch business rules
  open  business_rule;
  fetch business_rule into br_rec;
  close business_rule;

  if br_rec.category_set_id is not null then
    delete from csp_excess_lists cel
    where  cel.excess_status = 'P'
    and    cel.inventory_item_id in
          (select inventory_item_id
           from   mtl_item_categories
           where  category_set_id = br_rec.category_set_id
           and    category_id = nvl(br_rec.category_id,category_id)
           and    organization_id = cel.organization_id);
  end if;


-- % OF MAX VALUE
  if br_rec.total_max_excess is not null then
    open  excess_value;
    fetch excess_value into l_excess_value;
    close excess_value;

    if p_subinventory_code is null then
      open  org_max_value;
      fetch org_max_value into l_max_value;
      close org_max_value;
    else
      open  sub_max_value;
      fetch sub_max_value into l_max_value;
      close sub_max_value;
    end if;

    if nvl(l_max_value,0) > 0 then
      l_excess_percentage := nvl(l_excess_value,0) / l_max_value * 100;

      if l_excess_percentage < br_rec.total_max_excess then
        delete from csp_excess_lists
        where  excess_status = 'P';
        null; --exit;
      end if;
    end if;
  end if;

-- % of line quantity PL dependent
  if br_rec.line_max_excess is not null then
    if p_subinventory_code is null then
      for olq in org_line_quantity loop
        -- Avoid divisor equal to zero
        if nvl(olq.max_minmax_quantity,0) <> 0 then
          l_line_quantity := nvl(olq.excess_quantity,0) / nvl(olq.max_minmax_quantity,1) * 100;
          if l_line_quantity < nvl(br_rec.line_max_excess,0) then
            delete from csp_excess_lists
            where  excess_line_id = olq.excess_line_id;
          end if;
        end if;
      end loop;
    else
      for slq in sub_line_quantity loop
        -- Avoid divisor equal to zero
        if nvl(slq.max_minmax_quantity,0) <> 0 then
          l_line_quantity := nvl(slq.excess_quantity,0) / nvl(slq.max_minmax_quantity,1) * 100;
          if l_line_quantity < nvl(br_rec.line_max_excess,0) then
            delete from csp_excess_lists
            where  excess_line_id = slq.excess_line_id;
          end if;
        end if;
      end loop;
    end if;
  end if;

-- Recently Received PL dependent
  if br_rec.days_since_receipt is not null then
    for el in excess_lines loop
      if p_subinventory_code is null then
        l_received_date := null;
        open  org_recently_received(el.inventory_item_id);
        fetch org_recently_received into l_received_date;
        close org_recently_received;
        if l_received_date is not null then
          delete from csp_excess_lists
          where  excess_line_id = el.excess_line_id;
        end if;
      else
        l_received_date := null;
        open  sub_recently_received(el.inventory_item_id);
        fetch sub_recently_received into l_received_date;
        close sub_recently_received;
        if l_received_date is not null then
          delete from csp_excess_lists
          where  excess_line_id = el.excess_line_id;
        end if;
      end if;
    end loop;
  end if;

-- % of the total excess value
  if nvl(br_rec.total_excess_value,0) > 0 then
    open  excess_value;
    fetch excess_value into l_excess_value;
    close excess_value;

    if nvl(l_excess_value,0) > 0 then
      l_excess_percentage := 0;
      l_value := 0;
      for elv in excess_line_value loop
        if l_excess_percentage > br_rec.total_excess_value then
          delete from csp_excess_lists
          where  excess_line_id = elv.excess_line_id;
        end if;
        l_value := l_value + nvl(elv.value,0);
        l_excess_percentage := l_value / l_excess_value * 100;
      end loop;
    end if;
  end if;

-- Top X list
  if  nvl(br_rec.top_excess_lines,0) > 0 then
    l_counter := 0;
    for elv in excess_line_value loop
      l_counter := l_counter + 1;
      if l_counter <= br_rec.top_excess_lines then
        update csp_excess_lists
        set    excess_status = 'O'
        where  excess_line_id = elv.excess_line_id;
      else
        exit;
      end if;
    end loop;
    delete from csp_excess_lists
    where  excess_status = 'P';
  end if;
-- Remaining excess lines will be comitted
  update csp_excess_lists
  set excess_status = 'O'
  where excess_status = 'P';
  commit;
end apply_business_rules;

procedure defective_return(
  p_organization_id        number,
  p_subinventory_code      varchar2,
  p_planning_parameters_id number,
  p_level_id               varchar2,
  p_parts_loop_id          number,
  p_hierarchy_node_id      number,
  p_called_from            varchar2) is

  cursor defectives is
  select  mosv.organization_id,
          mosv.subinventory_code,
          mosv.inventory_item_id,
          total_qoh excess_quantity
  from    mtl_onhand_sub_v mosv,
          csp_sec_inventories csin
  where   mosv.organization_id = p_organization_id
  and     csin.organization_id = mosv.organization_id
  and     csin.secondary_inventory_name = mosv.subinventory_code
  and     csin.condition_type = 'B'
  and     csin.secondary_inventory_name = nvl(p_subinventory_code,csin.secondary_inventory_name)
  and     total_qoh > 0;

  x_excess_line_id      number;

  v_excess_part CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE  :=  CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
begin

  for d in defectives loop
    if p_called_from = 'PART_STATUS' then
      insert into csp_sup_dem_sub_temp(
        inventory_item_id,
        organization_id,
        subinventory_code,
        planning_parameters_id,
        level_id,
        parts_loop_id,
        hierarchy_node_id,
        excess_quantity)
      values(
        d.inventory_item_id,
        d.organization_id,
        d.subinventory_code,
        p_planning_parameters_id,
        p_level_id,
        p_parts_loop_id,
        p_hierarchy_node_id,
        d.excess_quantity);
    else
    x_excess_line_id := null;
    /*
    csp_excess_lists_pkg.Insert_Row(
      px_EXCESS_LINE_ID     => x_excess_line_id,
      p_CREATED_BY          => fnd_global.user_id,
      p_CREATION_DATE       => sysdate,
      p_LAST_UPDATED_BY     => fnd_global.user_id,
      p_LAST_UPDATE_DATE    => sysdate,
      p_LAST_UPDATE_LOGIN   => null,
      p_ORGANIZATION_ID     => d.organization_id,
      p_SUBINVENTORY_CODE   => d.subinventory_code,
      p_CONDITION_CODE      => 'B',
      p_INVENTORY_ITEM_ID   => d.inventory_item_id,
      p_EXCESS_QUANTITY     => d.excess_quantity,
      p_EXCESS_STATUS       => 'O',
      p_REQUISITION_LINE_ID => null,
      p_RETURNED_QUANTITY   => null,
      p_current_return_qty  => null,
      p_ATTRIBUTE_CATEGORY  => null,
      p_ATTRIBUTE1          => null,
      p_ATTRIBUTE2          => null,
      p_ATTRIBUTE3          => null,
      p_ATTRIBUTE4          => null,
      p_ATTRIBUTE5          => null,
      p_ATTRIBUTE6          => null,
      p_ATTRIBUTE7          => null,
      p_ATTRIBUTE8          => null,
      p_ATTRIBUTE9          => null,
      p_ATTRIBUTE10         => null,
      p_ATTRIBUTE11         => null,
      p_ATTRIBUTE12         => null,
      p_ATTRIBUTE13         => null,
      p_ATTRIBUTE14         => null,
      p_ATTRIBUTE15         => null);
      */

      v_excess_part := CSP_EXCESS_LISTS_PKG.G_MISS_EXCESS_REC;
      v_excess_part.CREATED_BY := fnd_global.user_id;
      v_excess_part.CREATION_DATE := sysdate;
      v_excess_part.LAST_UPDATED_BY := fnd_global.user_id;
      v_excess_part.LAST_UPDATE_DATE := sysdate;
      v_excess_part.ORGANIZATION_ID := d.organization_id;
      v_excess_part.SUBINVENTORY_CODE := d.subinventory_code;
      v_excess_part.CONDITION_CODE := 'B';
      v_excess_part.INVENTORY_ITEM_ID := d.inventory_item_id;
      v_excess_part.EXCESS_QUANTITY := d.excess_quantity;
      v_excess_part.EXCESS_STATUS := 'O';

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.CSP_EXCESS_PARTS_PVT.excess_parts',
                    'Calling populate_excess_list 4');
      end if;

      populate_excess_list(v_excess_part);
    end if;
  end loop;

  -- update CSP_SEC_INVENTORIES
  update CSP_SEC_INVENTORIES
  set last_excess_run_date = sysdate
  where organization_id = p_organization_id
  and secondary_inventory_name = nvl(p_subinventory_code, secondary_inventory_name);

  commit;
  exception
  when others then
    null;
end;

procedure clean_up(
  p_organization_id     number,
  p_subinventory_code   varchar2,
  p_condition_type      varchar2) is
begin
  if p_subinventory_code is null then
    delete from csp_excess_lists
    where  organization_id = p_organization_id
    and    condition_code = nvl(p_condition_type,condition_code)
    and    excess_status = 'O';
  else
    delete from csp_excess_lists
    where  organization_id = p_organization_id
    and    subinventory_code = nvl(p_subinventory_code,subinventory_code)
    and    condition_code = nvl(p_condition_type,condition_code)
    and    excess_status = 'O';
  end if;
  commit;
exception
  when no_data_found then
    null;
  when others then
    null;
end;

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
        l_mstk_segs := l_mstk_segs||'||'||l_structure_rec.segment_separator;
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
        l_mstk_segs := l_mstk_segs||'||'||l_structure_rec.segment_separator;
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

FUNCTION get_business_rule(
  p_organization_id         IN NUMBER,
  p_subinventory_code       IN VARCHAR2)
return number is

l_excess_rule_id    number;

cursor  subinventory_br is
select  cpp.excess_rule_id
from    csp_planning_parameters cpp
where   cpp.organization_id = p_organization_id
and     cpp.secondary_inventory = p_subinventory_code;

cursor  organization_br is
select  cpp.excess_rule_id
from    csp_planning_parameters cpp
where   cpp.organization_id = p_organization_id
and     cpp.secondary_inventory is null;

begin

 If p_organization_id is not null and p_subinventory_code is not null then
  open  subinventory_br;
  fetch subinventory_br into l_excess_rule_id;
  close subinventory_br;
 elsif p_organization_id is not null and p_subinventory_code is null then
  open  organization_br;
  fetch organization_br into l_excess_rule_id;
  close organization_br;
 end if;
 return(l_excess_rule_id);
end;

FUNCTION onhand
(   p_organization_id           IN  NUMBER,
    p_inventory_item_id         IN  NUMBER,
    p_subinventory_code         IN  VARCHAR2,
    p_revision_qty_control_code IN  NUMBER,
    p_include_nonnet		    IN  NUMBER,
    p_planning_level            IN  NUMBER
)
return number is

  x_return_status           VARCHAR2(1);
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(2000);
  l_onhand_source           NUMBER := 3;
  l_subinventory_code       VARCHAR2(30);
  l_qoh                     NUMBER;
  l_rqoh                    NUMBER;
  l_qr                      NUMBER;
  l_qs                      NUMBER;
  l_att                     NUMBER;
  l_atr                     NUMBER;
  l_total_qoh               NUMBER := null;

  cursor revisions is
  select revision
  from   mtl_item_revisions
  where  organization_id   = p_organization_id
  and    inventory_item_id = p_inventory_item_id;

BEGIN

  IF (p_include_nonnet = 2) THEN
      l_onhand_source := 2;
  END IF;

  if p_revision_qty_control_code = 2 then -- Revision control

    for r in revisions loop
      inv_quantity_tree_pub.query_quantities
       ( p_api_version_number => 1.0
       , p_organization_id  => p_organization_id
       , p_inventory_item_id => p_inventory_item_id
       , p_subinventory_code => p_subinventory_code
       , x_qoh     => l_qoh
       , x_atr     => l_atr
       , p_init_msg_lst   => fnd_api.g_false
       , p_tree_mode   => inv_quantity_tree_pvt.g_transaction_mode
       , p_is_revision_control => TRUE
       , p_is_lot_control  => NULL
       , p_is_serial_control => NULL
       , p_revision    => r.revision
       , p_lot_number   => NULL
       , p_locator_id   => NULL
       , x_rqoh     => l_rqoh
       , x_qr     => l_qr
       , x_qs     => l_qs
       , x_att     => l_att
       , x_return_status  => x_return_status
       , x_msg_count   => x_msg_count
       , x_msg_data    => x_msg_data
       );

--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     att          available to transact
--     atr          available to reserve

     --l_total_qoh := nvl(l_total_qoh,0) + nvl(l_qoh,0);
       l_total_qoh := nvl(l_total_qoh,0) + nvl(l_atr,0);
    end loop;
    return(l_total_qoh);

  else  -- Not revision controlled item

   Inv_quantity_tree_pub.query_quantities
   ( p_api_version_number => 1.0
   , p_organization_id  => p_organization_id
   , p_inventory_item_id => p_inventory_item_id
   , p_subinventory_code => p_subinventory_code
   , x_qoh     => l_qoh
   , x_atr     => l_atr
   , p_init_msg_lst   => fnd_api.g_false
   , p_tree_mode   => inv_quantity_tree_pvt.g_transaction_mode
   , p_is_revision_control => NULL
   , p_is_lot_control  => NULL
   , p_is_serial_control => NULL
   , p_revision    => NULL
   , p_lot_number   => NULL
   , p_locator_id   => NULL
   , x_rqoh     => l_rqoh
   , x_qr     => l_qr
   , x_qs     => l_qs
   , x_att     => l_att
   , x_return_status  => x_return_status
   , x_msg_count   => x_msg_count
   , x_msg_data    => x_msg_data
   );
    if x_return_status = 'S' then
      return(l_atr);
    else
      return(0);
    end if;
  end if;
end;

function demand(
    p_organization_id   number,
    p_inventory_item_id number,
    p_subinventory_code varchar2,
    p_include_nonnet    number, -- 2
    p_planning_level    number, -- 2
    p_net_unreserved    number, -- 1
    p_net_reserved      number, -- 1
    p_net_wip           number, -- 1
    p_demand_cutoff     number) -- number of days
    return Number is

   qty                  number;
   total                number;
   l_total_demand_qty   number;
   l_demand_qty         number;
   l_total_reserve_qty  number;


begin
   total := 0;
   l_total_demand_qty := 0;
   l_demand_qty := 0;
   l_total_reserve_qty := 0;

   -- select unreserved qty from mtl_demand for non oe rows.
   select sum(PRIMARY_UOM_QUANTITY- GREATEST(NVL(RESERVATION_QUANTITY,0),nvl(COMPLETED_QUANTITY,0)))
     into   qty
     from   mtl_demand
     WHERE RESERVATION_TYPE = 1
     AND  p_net_unreserved = 1
     AND  parent_demand_id IS NULL
     AND  ORGANIZATION_ID = p_organization_id
     and  PRIMARY_UOM_QUANTITY > GREATEST(NVL(RESERVATION_QUANTITY,0),
					  nvl(COMPLETED_QUANTITY,0))

     and  INVENTORY_ITEM_ID = p_inventory_item_id
     and  REQUIREMENT_DATE <= sysdate + p_demand_cutoff
     and  demand_source_type not in (2,8,12)
     and  (p_planning_level = 1  or
	   SUBINVENTORY = p_subinventory_code)   -- Included later for ORG Level
     and  (SUBINVENTORY is null or
	   p_planning_level = 2 or
	   EXISTS (SELECT 1
		   FROM   MTL_SECONDARY_INVENTORIES S
		   WHERE  S.ORGANIZATION_ID = p_organization_id
		   AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
		   AND    S.availability_type = DECODE(p_include_nonnet,
						       1,
						       S.availability_type,
						       1)));

   total := total + nvl(qty,0);


   -- select the reserved quantity from mtl_reservations for non OE rows
   select sum(PRIMARY_RESERVATION_QUANTITY)
     into   qty
     from   mtl_reservations
     where  p_net_reserved = 1
     and    ORGANIZATION_ID = p_organization_id
     and    INVENTORY_ITEM_ID = p_inventory_item_id
     and    REQUIREMENT_DATE <= sysdate + p_demand_cutoff
     and    demand_source_type_id not in (2,8,12)
     and    (p_planning_level = 1  or
	     SUBINVENTORY_CODE = p_subinventory_code) -- Included later for ORG Level
     and    (SUBINVENTORY_CODE is null or
	     p_planning_level = 2 or
	     EXISTS (SELECT 1
		     FROM   MTL_SECONDARY_INVENTORIES S
		     WHERE  S.ORGANIZATION_ID = p_organization_id
		     AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
		     AND    S.availability_type = DECODE(p_include_nonnet,
							 1,
							 S.availability_type,
							 1)));

   total := total + nvl(qty,0);


   -- get the total demand which is the difference between the
   -- ordered qty. and the shipped qty.
   -- This gives the total demand including the reserved
   -- and the unreserved material.
   if p_net_unreserved = 1 then
      select SUM(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SHIP_FROM_ORG_ID,
			     INVENTORY_ITEM_ID, ORDER_QUANTITY_UOM, Nvl(ordered_quantity,0)) -
		         get_shipped_qty(p_organization_id,p_inventory_item_id, ool.line_id))
	into   l_total_demand_qty
	from   oe_order_lines_all ool
	where  ship_from_org_id = p_organization_id
	and    open_flag = 'Y'
	and    INVENTORY_ITEM_ID = p_inventory_item_id
	and    schedule_ship_date <= sysdate + p_demand_cutoff
	AND    DECODE(OOL.SOURCE_DOCUMENT_TYPE_ID, 10, 8,DECODE(OOL.LINE_CATEGORY_CODE, 'ORDER',2,12)) IN (2,8,12)
	and    ((p_planning_level = 1  AND DECODE(OOL.SOURCE_DOCUMENT_TYPE_ID, 10, 8,DECODE(OOL.LINE_CATEGORY_CODE, 'ORDER',2,12)) <> 8 ) OR
		SUBINVENTORY = p_subinventory_code)  -- Included later for ORG Level
        and    (SUBINVENTORY is null or
	       p_planning_level = 2 or
	       EXISTS (SELECT 1
	 	       FROM   MTL_SECONDARY_INVENTORIES S
		       WHERE  S.ORGANIZATION_ID = p_organization_id
		       AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
		       AND    S.availability_type = DECODE(p_include_nonnet,
		 					   1,
							   S.availability_type,
							   1)));

   end if;

   -- find out the reserved qty for the material from mtl_reservations
   if ((p_net_reserved = 1 or p_net_unreserved = 1) and
       (nvl(p_net_reserved,0) <> 1 and nvl(p_net_unreserved,0) <> 1)) then
      select sum(PRIMARY_RESERVATION_QUANTITY)
        into   l_total_reserve_qty
        from   mtl_reservations
       WHERE   ORGANIZATION_ID = p_organization_id
        and    INVENTORY_ITEM_ID = p_inventory_item_id
        and    REQUIREMENT_DATE <= sysdate + p_demand_cutoff
        and    demand_source_type_id in (2,8,12)
        and    ((p_planning_level = 1 AND demand_source_type_id <> 8 ) OR
   	         SUBINVENTORY_CODE = p_subinventory_code)  -- Included later for ORG Level
        and    (SUBINVENTORY_CODE is null or
	        p_planning_level = 2 or
	        EXISTS (SELECT 1
	  	        FROM   MTL_SECONDARY_INVENTORIES S
		        WHERE  S.ORGANIZATION_ID = p_organization_id
		        AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
		        AND    S.availability_type = DECODE(p_include_nonnet,
			 				    1,
							    S.availability_type,
							    1)));
   end if;

   -- total demand is calculated as follows:
   -- if we have to consider both unreserved matl and reserved matl. then the
	-- demand is simply the total demand = ordered qty - shipped qty.
   -- elsif we have to take into account only reserved matl. then the
	-- demand is simply the reservations from mtl_reservations for the matl.
   -- elsif we have to take into account just the unreserved matl. then the
	-- demand is total demand - the reservations for the material.
   if p_net_unreserved = 1 and p_net_reserved = 1 then
      l_demand_qty := Nvl(l_total_demand_qty,0);
   elsif p_net_reserved = 1 then
      l_demand_qty := Nvl(l_total_reserve_qty,0);
   elsif p_net_unreserved = 1 then
      l_demand_qty := Nvl(l_total_demand_qty,0) - Nvl(l_total_reserve_qty,0);
   end if;
   total := total + nvl(l_demand_qty,0);


   -- Take care of internal orders for org level planning
   if p_planning_level = 1 then
      l_total_demand_qty := 0;
      l_demand_qty := 0;
      l_total_reserve_qty := 0;

      -- get the total demand which is the difference between the
      -- ordered qty. and the shipped qty.
      -- This gives the total demand including the reserved
      -- and the unreserved material.
      if p_net_unreserved = 1 then
         select SUM(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SHIP_FROM_ORG_ID,
					  INVENTORY_ITEM_ID, ORDER_QUANTITY_UOM, Nvl(ordered_quantity,0)) -
		              get_shipped_qty(p_organization_id,p_inventory_item_id, so.line_id))
	   into   l_total_demand_qty
	   from   oe_order_lines_all so,
	          po_requisition_headers_all poh,
                  po_requisition_lines_all pol
	   where  so.ORIG_SYS_DOCUMENT_REF = poh.segment1
	   and    poh.requisition_header_id = pol .requisition_header_id
	   and    so.orig_sys_line_ref = pol.line_num
	   and  ( pol.DESTINATION_ORGANIZATION_ID <> p_organization_id or
	          (pol.DESTINATION_ORGANIZATION_ID = p_organization_id and  -- Added code Bug#1012179
	  	   pol.DESTINATION_TYPE_CODE = 'EXPENSE')
	        )
	   and    so.ship_from_org_ID = p_organization_id
	   and    so.open_flag = 'Y'
	   and    so.INVENTORY_ITEM_ID = p_inventory_item_id
	   and    schedule_ship_date <= sysdate + p_demand_cutoff
	   and    DECODE(so.SOURCE_DOCUMENT_TYPE_ID, 10, 8,DECODE(so.LINE_CATEGORY_CODE, 'ORDER',2,12)) = 8
           and    (SUBINVENTORY is null or
	          EXISTS (SELECT 1
	 	          FROM   MTL_SECONDARY_INVENTORIES S
		          WHERE  S.ORGANIZATION_ID = p_organization_id
		          AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
		          AND    S.availability_type = DECODE(p_include_nonnet,
		 	  				      1,
							      S.availability_type,
							      1)));
      end if;

      -- find out the reserved qty for the material from mtl_reservations
      if ((p_net_reserved = 1 or p_net_unreserved = 1) and
          (nvl(p_net_reserved,0) <> 1 and nvl(p_net_unreserved,0) <> 1)) then
         -- Include the reserved demand from mtl_reservations
         select sum(PRIMARY_RESERVATION_QUANTITY)
  	   into   l_total_reserve_qty
	   from   mtl_reservations md, oe_order_lines_all so,
	          po_req_distributions_all pod,
	          po_requisition_lines_all pol
	   where  md.DEMAND_SOURCE_LINE_ID = so.LINE_ID
	   and    so.ORIG_SYS_LINE_REF = pod.DISTRIBUTION_ID
	   and    pod.REQUISITION_LINE_ID = pol.REQUISITION_LINE_ID
	   and   (pol.DESTINATION_ORGANIZATION_ID <> p_organization_id or
	          (pol.DESTINATION_ORGANIZATION_ID = p_organization_id
		   and  -- Added code Bug#1012179
		   pol.DESTINATION_TYPE_CODE = 'EXPENSE')
	         )
	   and    ORGANIZATION_ID = p_organization_id
	   and    md.INVENTORY_ITEM_ID = p_inventory_item_id
	   and    REQUIREMENT_DATE <= sysdate + p_demand_cutoff
	   and    demand_source_type_id = 8
	   and    (SUBINVENTORY_CODE is null or
	          EXISTS (SELECT 1
	   	          FROM   MTL_SECONDARY_INVENTORIES S
		          WHERE  S.ORGANIZATION_ID = p_organization_id
		          AND    S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
		          AND    S.availability_type = DECODE(p_include_nonnet,
							      1,
							      S.availability_type,
							      1)));

      end if;

      -- total demand is calculated as follows:
      -- if we have to consider both unreserved matl and reserved matl. then the
   	   -- demand is simply the total demand = ordered qty - shipped qty.
      -- elsif we have to take into account only reserved matl. then the
	   -- demand is simply the reservations from mtl_reservations for the matl.
      -- elsif we have to take into account just the unreserved matl. then the
	   -- demand is total demand - the reservations for the material.
      if p_net_unreserved = 1 and p_net_reserved = 1 then
         l_demand_qty := Nvl(l_total_demand_qty,0);
      elsif p_net_reserved = 1 then
         l_demand_qty := Nvl(l_total_reserve_qty,0);
      elsif p_net_unreserved = 1 then
         l_demand_qty := Nvl(l_total_demand_qty,0) - Nvl(l_total_reserve_qty,0);
      end if;
      total := total + nvl(l_demand_qty,0);
   end if;

  -- WIP Reservations from mtl_demand
  select sum(PRIMARY_UOM_QUANTITY - GREATEST(NVL(RESERVATION_QUANTITY,0),
         nvl(COMPLETED_QUANTITY,0)))
  into   qty
  from   mtl_demand
  where  RESERVATION_TYPE = 3
  and    ORGANIZATION_ID = p_organization_id
  and    PRIMARY_UOM_QUANTITY > GREATEST(NVL(RESERVATION_QUANTITY,0),
         nvl(COMPLETED_QUANTITY,0))
  and    INVENTORY_ITEM_ID = p_inventory_item_id
  and    REQUIREMENT_DATE <= sysdate + p_demand_cutoff
  and    p_net_reserved = 1
  and    p_planning_level = 1;

  -- SUBINVENTORY IS Always expected to be Null when Reservation_type is 3.

  total := total + nvl(qty,0);

  -- Wip Components are to be included at the Org Level Planning only
  -- Qty Issued Substracted from the Qty Required
  if (p_net_wip = 1 and p_planning_level = 1)
  then
    select sum(o.required_quantity - o.quantity_issued)
    into   qty
    from   wip_discrete_jobs d, wip_requirement_operations o
    where  o.wip_entity_id     = d.wip_entity_id
    and    o.organization_id   = d.organization_id
    and    d.organization_id   = p_organization_id
    and    o.inventory_item_id = p_inventory_item_id
    and    o.date_required    <= sysdate + p_demand_cutoff
    and    o.required_quantity > 0
    and    o.required_quantity > o.quantity_issued
    and    o.operation_seq_num > 0
    and    d.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
    and    o.wip_supply_type <> 6;
    total := total + nvl(qty,0);
    -- Demand Qty to be added for a released repetitve schedule
    -- Bug#691471
    select sum(o.required_quantity - o.quantity_issued)
    into   qty
    from   wip_repetitive_schedules r, wip_requirement_operations o
    where  o.wip_entity_id     = r.wip_entity_id
    and    o.organization_id   = r.organization_id
    and    r.organization_id   = p_organization_id
    and    o.inventory_item_id = p_inventory_item_id
    and    o.date_required    <= sysdate + p_demand_cutoff
    and    o.required_quantity > 0
    and    o.required_quantity > o.quantity_issued
    and    o.operation_seq_num > 0
    and    r.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
    and    o.wip_supply_type <> 6;
    total := total + nvl(qty,0);
  end if;


  -- Include move orders
  -- leave out the closed or cancelled lines
  -- select only the issue from stores for org level planning
  -- Also select those lines for the sub level planning.
/*  SELECT sum(quantity - Nvl(quantity_delivered,0))
    INTO qty
    FROM mtl_txn_request_lines_v
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id
     AND line_status NOT IN (5,6)
     AND transaction_action_id = 1
     AND (p_planning_level = 1  or
          from_subinventory_code = p_subinventory_code)  -- Included later for ORG Level
     AND ( from_subinventory_code is null or
         p_planning_level = 2 or
          EXISTS (SELECT 1
	          FROM   MTL_SECONDARY_INVENTORIES S
		  WHERE  S.ORGANIZATION_ID = p_organization_id
		  AND    S.SECONDARY_INVENTORY_NAME = from_subinventory_code
		  AND    S.availability_type = DECODE(p_include_nonnet,
					       1,S.availability_type,1)))
     AND date_required <= sysdate + p_demand_cutoff;
*/

SELECT  SUM(MTRL.QUANTITY - NVL(MTRL.QUANTITY_DELIVERED,0))
  INTO  qty
  FROM  MTL_TXN_REQUEST_LINES MTRL,
        MTL_TRANSACTION_TYPES MTT
 WHERE  MTT.TRANSACTION_TYPE_ID = MTRL.TRANSACTION_TYPE_ID
 AND    MTRL.ORGANIZATION_ID = p_organization_id
 AND    MTRL.INVENTORY_ITEM_ID = p_inventory_item_id
 AND    MTRL.LINE_STATUS NOT IN (5,6)
 AND    MTT.TRANSACTION_ACTION_ID = 1
 AND    (p_planning_level = 1  OR
         MTRL.FROM_SUBINVENTORY_CODE = p_subinventory_code)
 AND    (MTRL.FROM_SUBINVENTORY_CODE IS NULL OR
         p_planning_level = 2  OR
         EXISTS (SELECT 1
                 FROM MTL_SECONDARY_INVENTORIES S
                 WHERE   S.ORGANIZATION_ID = p_organization_id
                 AND     S.SECONDARY_INVENTORY_NAME = MTRL.FROM_SUBINVENTORY_CODE
                 AND     S.AVAILABILITY_TYPE = DECODE(p_include_nonnet,
                                               1,S.AVAILABILITY_TYPE,1)))
 AND MTRL.DATE_REQUIRED <= sysdate + p_demand_cutoff;


  total := total + Nvl(qty,0);

  -- Include the sub transfer and the staging transfer move orders
  -- for sub level planning
  SELECT sum(quantity - Nvl(quantity_delivered,0))
    INTO qty
    FROM mtl_txn_request_lines_v
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id
     AND line_status NOT IN (5,6)
     AND transaction_action_id IN (2,28)
     AND p_planning_level = 2
     AND from_subinventory_code = p_subinventory_code
     AND date_required <= sysdate + p_demand_cutoff;
  total := total + Nvl(qty,0);

  return(total);
exception
when others then
  return(0);
end;

function get_shipped_qty
  (p_organization_id	IN	NUMBER,
   p_inventory_item_id	IN	NUMBER,
   p_order_line_id      IN      NUMBER
   ) return NUMBER
  IS
     l_shipped_qty NUMBER := 0;
BEGIN
   BEGIN
      SELECT SUM(primary_quantity)
	INTO l_shipped_qty
	FROM mtl_material_transactions
       WHERE transaction_action_id = 1
	 AND source_line_id = p_order_line_id
	 AND organization_id = p_organization_id
	 AND inventory_item_id = p_inventory_item_id;
   EXCEPTION
      WHEN OTHERS THEN
	 l_shipped_qty := 0;
   END ;

   IF l_shipped_qty IS NULL THEN l_shipped_qty := 0;
    ELSE l_shipped_qty := -1 * l_shipped_qty;
   END IF;

   RETURN l_shipped_qty;
END get_shipped_qty;

-- added by htank for Reverse Logistic project
PROCEDURE populate_excess_list (
  p_excess_part IN OUT nocopy CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE,
  p_is_insert_record IN VARCHAR2 default 'Y'
  ) IS

  CURSOR c_get_return_info (cv_ORGANIZATION_ID NUMBER,
                            cv_SUBINVENTORY_CODE VARCHAR2) IS
  select
    CSI.RETURN_ORGANIZATION_ID,
    CSI.RETURN_SUBINVENTORY_NAME
  from
    CSP_SEC_INVENTORIES CSI
  where
    CSI.SECONDARY_INVENTORY_NAME = cv_SUBINVENTORY_CODE
    and CSI.ORGANIZATION_ID      = cv_ORGANIZATION_ID;

  v_ret_org_id      NUMBER;
  v_ret_sub_inv     VARCHAR2(10);
  v_excess_records  CSP_EXCESS_LISTS_PKG.EXCESS_TBL_TYPE;
  v_excess_part     CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE;
  x_excess_line_id  NUMBER;

  -- routing rule change
  v_return_rule_id	number;
  v_return_type 	varchar2(1);
  x_return_status	varchar2(1);
  x_msg_count		number;
  x_msg_data		varchar2(4000);
  v_rule_dest_org_id	number;
  v_rule_dest_subinv	varchar2(30);

  cursor get_rule_destination is
	SELECT dest_org_id,
	  dest_subinv
	FROM csp_return_routing_rules
	WHERE rule_id = v_return_rule_id;
BEGIN

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                'Begin...');
  end if;

  IF p_excess_part.ORGANIZATION_ID IS NOT NULL THEN

    -- set default return information

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'Fetching return information from c_get_return_info');
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'p_excess_part.ORGANIZATION_ID = '
                  || p_excess_part.ORGANIZATION_ID);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'p_excess_part.SUBINVENTORY_CODE = '
                  || p_excess_part.SUBINVENTORY_CODE);
    end if;

    OPEN c_get_return_info(p_excess_part.ORGANIZATION_ID,
                          p_excess_part.SUBINVENTORY_CODE);
    FETCH c_get_return_info INTO v_ret_org_id, v_ret_sub_inv;
    CLOSE c_get_return_info;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'Return information from c_get_return_info');
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'v_ret_org_id = ' || v_ret_org_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'v_ret_sub_inv = ' || v_ret_sub_inv);
    end if;

    -- call custom code to override return information if any
    v_excess_part := p_excess_part;
    v_excess_part.RETURN_ORGANIZATION_ID := v_ret_org_id;
    v_excess_part.RETURN_SUBINVENTORY_NAME := v_ret_sub_inv;

	-- New Retun Routing Rules
	-- After populating Destination Based on the Setup at
	-- Resource Addresses and Subinventort form, we will override it
	-- if we found any return routing rule for the given inputs

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'Calling find_best_routing_rule....');
    end if;

	if v_excess_part.CONDITION_CODE = 'G' then
		v_return_type := 'E';	-- Excess
	elsif v_excess_part.CONDITION_CODE = 'A' then
		v_return_type := 'A';	-- DOA
	else
		v_return_type := 'D';	-- Defective
	end if;

	find_best_routing_rule (
		p_source_type		=>		'I'		-- Always Internal Source
		, p_source_org_id	=>		v_excess_part.ORGANIZATION_ID
		, p_source_subinv	=>		v_excess_part.SUBINVENTORY_CODE
		, p_source_terr_id	=>		NULL
		, p_ret_trans_type	=>		v_return_type
		, p_item_id			=>		v_excess_part.INVENTORY_ITEM_ID
		, x_rule_id			=>		v_return_rule_id
		, x_return_status	=>		x_return_status
		, x_msg_count		=>		x_msg_count
		, x_msg_data		=>		x_msg_data
	);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'returned from find_best_routing_rule with x_return_status = ' || x_return_status
				  || ' and v_return_rule_id = ' || v_return_rule_id);
    end if;

	if v_return_rule_id is not null then
		open get_rule_destination;
		fetch get_rule_destination into v_rule_dest_org_id, v_rule_dest_subinv;
		close get_rule_destination;

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
					  'Destination for rule is: v_rule_dest_org_id=' || v_rule_dest_org_id
					  || ', v_rule_dest_subinv=' || v_rule_dest_subinv);
		end if;

		if v_rule_dest_org_id is not null then
			v_excess_part.RETURN_ORGANIZATION_ID := v_rule_dest_org_id;
			v_excess_part.RETURN_SUBINVENTORY_NAME := v_rule_dest_subinv;
		end if;
	end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'Calling custom code...CSP_EXCESS_PARTS_CUST.excess_parts');
    end if;

    v_excess_records := CSP_EXCESS_PARTS_CUST.excess_parts(v_excess_part);

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                  'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                  'Got v_excess_records with count = ' || v_excess_records.count);
    end if;

    FOR i IN 1..v_excess_records.count LOOP
        v_excess_part :=  v_excess_records(i);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
			'p_is_insert_record = ' || p_is_insert_record);
	end if;

	if nvl(p_is_insert_record, 'N') = 'Y' then

          if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        'csp.plsql.CSP_EXCESS_PARTS_PVT.populate_excess_list',
                        'Calling csp_excess_lists_pkg.Insert_Row for i = ' || i);
          end if;

          csp_excess_lists_pkg.Insert_Row(
            px_EXCESS_LINE_ID     => x_excess_line_id,
            p_CREATED_BY          => v_excess_part.CREATED_BY,
            p_CREATION_DATE       => v_excess_part.CREATION_DATE,
            p_LAST_UPDATED_BY     => v_excess_part.LAST_UPDATED_BY,
            p_LAST_UPDATE_DATE    => v_excess_part.LAST_UPDATE_DATE,
            p_LAST_UPDATE_LOGIN   => v_excess_part.LAST_UPDATE_LOGIN,
            p_ORGANIZATION_ID     => v_excess_part.ORGANIZATION_ID,
            p_SUBINVENTORY_CODE   => v_excess_part.SUBINVENTORY_CODE,
            p_CONDITION_CODE      => v_excess_part.CONDITION_CODE,
            p_INVENTORY_ITEM_ID   => v_excess_part.INVENTORY_ITEM_ID,
            p_EXCESS_QUANTITY     => v_excess_part.EXCESS_QUANTITY,
            p_EXCESS_STATUS       => v_excess_part.EXCESS_STATUS,
            p_RETURN_ORG_ID       => v_excess_part.RETURN_ORGANIZATION_ID,
            p_RETURN_SUB_INV      => v_excess_part.RETURN_SUBINVENTORY_NAME,
            p_REQUISITION_LINE_ID => v_excess_part.REQUISITION_LINE_ID,
            p_RETURNED_QUANTITY   => v_excess_part.RETURNED_QUANTITY,
            p_current_return_qty  => v_excess_part.CURRENT_RETURN_QTY,
            p_ATTRIBUTE_CATEGORY  => v_excess_part.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1          => v_excess_part.ATTRIBUTE1,
            p_ATTRIBUTE2          => v_excess_part.ATTRIBUTE2,
            p_ATTRIBUTE3          => v_excess_part.ATTRIBUTE3,
            p_ATTRIBUTE4          => v_excess_part.ATTRIBUTE4,
            p_ATTRIBUTE5          => v_excess_part.ATTRIBUTE5,
            p_ATTRIBUTE6          => v_excess_part.ATTRIBUTE6,
            p_ATTRIBUTE7          => v_excess_part.ATTRIBUTE7,
            p_ATTRIBUTE8          => v_excess_part.ATTRIBUTE8,
            p_ATTRIBUTE9          => v_excess_part.ATTRIBUTE9,
            p_ATTRIBUTE10         => v_excess_part.ATTRIBUTE10,
            p_ATTRIBUTE11         => v_excess_part.ATTRIBUTE11,
            p_ATTRIBUTE12         => v_excess_part.ATTRIBUTE12,
            p_ATTRIBUTE13         => v_excess_part.ATTRIBUTE13,
            p_ATTRIBUTE14         => v_excess_part.ATTRIBUTE14,
            p_ATTRIBUTE15         => v_excess_part.ATTRIBUTE15);

          x_excess_line_id := null;
        end if;
    END LOOP;

  END IF;

  p_excess_part := v_excess_part;

END;  -- End of populate_excess_list

-- This procedure will return the best match Return Routing
-- Rule ID for given inputs
-- This will be called by the Setup UI's simulation process
-- and also, it will be called by the actual destination default
-- process.
procedure find_best_routing_rule (
		p_source_type				IN	VARCHAR2
		, p_source_org_id			IN	NUMBER
		, p_source_subinv			IN	VARCHAR2
		, p_source_terr_id			IN	NUMBER
		, p_ret_trans_type			IN	VARCHAR2
		, p_item_id					IN	NUMBER
		, x_rule_id					OUT	NOCOPY	NUMBER
		, x_return_status             OUT  NOCOPY  VARCHAR2
		, x_msg_count                 OUT  NOCOPY  NUMBER
		, x_msg_data                  OUT  NOCOPY  VARCHAR2
	) IS

	v_match_rule_id			number;
	v_match_rule_weight		number;

	cursor c_Scan_Subinv
	(
		v_source_org_id		number,
		v_source_subinv		varchar2,
		v_ret_trans_type	varchar2,
		v_item_id			number
	)
	is
	select * from (
		select distinct
		  (decode(r.source_org_id, v_source_org_id, 1, 0)+
		  decode(r.source_subinv, v_source_subinv, 2, 0)+
		  decode(r.return_type, v_ret_trans_type, 4, 0)+
		  decode(r.inv_cat_set_id, mtl.category_set_id, 8, 0)+
		  decode(r.inv_cat_id, mtl.category_id, 16, 0)+
		  decode(r.inv_item_id, v_item_id, 32, 0)) as weigth,
		  r.rule_id
		from
		  (
			select rule_id from csp_return_routing_rules where source_org_id = v_source_org_id
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules where source_subinv = v_source_subinv
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules where return_type = v_ret_trans_type
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where inv_cat_set_id in (select distinct category_set_id
								from MTL_ITEM_CATEGORIES
								where inventory_item_id = v_item_id
								and organization_id = v_source_org_id)
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where inv_cat_id in (select distinct category_id
								from MTL_ITEM_CATEGORIES
								where inventory_item_id = v_item_id
								and organization_id = v_source_org_id)
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules where inv_item_id = v_item_id
				and nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where nvl(source_type, 'I') = 'I' and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
				and decode(source_org_id, 0, null, source_org_id) is null
				and source_subinv is null
				and return_type is null
				and decode(inv_cat_set_id, 0, null, inv_cat_set_id) is null
				and decode(inv_cat_id, 0, null, inv_cat_id) is null
				and decode(inv_item_id, 0, null, inv_item_id) is null
		  ) prob,
		  csp_return_routing_rules r,
		  MTL_ITEM_CATEGORIES mtl
		where r.rule_id = prob.rule_id
		and mtl.inventory_item_id = v_item_id
		and mtl.organization_id = v_source_org_id
		and nvl(decode(r.source_org_id, 0, null, r.source_org_id), v_source_org_id) = v_source_org_id
		and nvl(r.source_subinv, nvl(v_source_subinv, 'NULL')) = nvl(v_source_subinv, 'NULL')
		and nvl(r.return_type, v_ret_trans_type) = v_ret_trans_type
		and nvl(decode(r.inv_cat_set_id, 0, null, r.inv_cat_set_id), mtl.category_set_id) = mtl.category_set_id
		and nvl(decode(r.inv_cat_id, 0, null, r.inv_cat_id), mtl.category_id) = mtl.category_id
		and nvl(decode(r.inv_item_id, 0, null, r.inv_item_id), v_item_id) = v_item_id
		order by 1 desc
	) intable where rownum = 1;

	cursor c_Scan_Terr
	(
		v_source_terr_id	number,
		v_source_terr_type	varchar2,
		v_ret_trans_type	varchar2,
		v_item_id			number
	)
	is
	select * from (
		select distinct
		  (decode(r.source_terr_id, v_source_terr_id, 1, 0)+
		  decode(r.return_type, v_ret_trans_type, 4, 0)+
		  decode(r.inv_cat_set_id, mtl.category_set_id, 8, 0)+
		  decode(r.inv_cat_id, mtl.category_id, 16, 0)+
		  decode(r.inv_item_id, v_item_id, 32, 0)) as weigth,
		  r.rule_id
		from
		  (
			select rule_id from csp_return_routing_rules where source_terr_id = v_source_terr_id
				and nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules where return_type = v_ret_trans_type
				and nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where inv_cat_set_id in (select distinct category_set_id
								from MTL_ITEM_CATEGORIES
								where inventory_item_id = v_item_id
								and organization_id = cs_std.get_item_valdn_orgzn_id)
				and nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where inv_cat_id in (select distinct category_id
								from MTL_ITEM_CATEGORIES
								where inventory_item_id = v_item_id
								and organization_id = cs_std.get_item_valdn_orgzn_id)
				and nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules where inv_item_id = v_item_id
				and nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
			union
			select rule_id from csp_return_routing_rules
				where nvl(source_type, v_source_terr_type) = v_source_terr_type and enabled = 'Y'
				and sysdate between nvl(start_active_date, sysdate)
				and nvl(end_active_date, sysdate + 1)
				and decode(source_terr_id, 0, null, source_terr_id) is null
				and return_type is null
				and decode(inv_cat_set_id, 0, null, inv_cat_set_id) is null
				and decode(inv_cat_id, 0, null, inv_cat_id) is null
				and decode(inv_item_id, 0, null, inv_item_id) is null
		  ) prob,
		  csp_return_routing_rules r,
		  MTL_ITEM_CATEGORIES mtl
		where r.rule_id = prob.rule_id
		and mtl.inventory_item_id = v_item_id
		and mtl.organization_id = cs_std.get_item_valdn_orgzn_id
		and nvl(decode(r.source_terr_id, 0, null, r.source_terr_id), v_source_terr_id) = v_source_terr_id
		and nvl(r.return_type, v_ret_trans_type) = v_ret_trans_type
		and nvl(decode(r.inv_cat_set_id, 0, null, r.inv_cat_set_id), mtl.category_set_id) = mtl.category_set_id
		and nvl(decode(r.inv_cat_id, 0, null, r.inv_cat_id), mtl.category_id) = mtl.category_id
		and nvl(decode(r.inv_item_id, 0, null, r.inv_item_id), v_item_id) = v_item_id
		order by 1 desc
	) intable where rownum = 1;

	cursor c_Source_Org_Type (v_org_id number, v_subinv varchar2) is
	select
		nvl(stocking_site_type, 'MANNED')
	from csp_planning_parameters
	where organization_id = v_org_id
	and nvl(secondary_inventory, 'NULL') = nvl(v_subinv, 'NULL');

	l_Source_Org_Type varchar2(20);
	l_city varchar2(60);
	l_postal_code	varchar2(60);
	l_state	varchar2(60);
	l_province	varchar2(60);
	l_county	varchar2(60);
	l_country	varchar2(60);

	cursor c_get_tech_add (v_org_id number, v_subinv varchar2) is
        SELECT HLOC.CITY,
          HLOC.POSTAL_CODE,
          HLOC.STATE,
          HLOC.PROVINCE,
          HLOC.COUNTY,
          HLOC.COUNTRY
        FROM csp_sec_inventories CINV,
          HZ_LOCATIONS HLOC,
          csp_rs_cust_relations rcr,
          hz_cust_acct_sites_All cas,
          hz_cust_site_uses_all csu,
          hz_party_sites ps
        WHERE CINV.ORGANIZATION_ID        = v_org_id
        AND CINV.secondary_inventory_name = v_subinv
        AND CINV.owner_resource_id        = rcr.RESOURCE_ID
        AND CINV.owner_resource_type      = rcr.RESOURCE_TYPE
        AND rcr.customer_id               = cas.cust_account_id
        AND cas.cust_acct_site_id         = csu.cust_acct_site_id
        AND csu.site_use_code             = 'SHIP_TO'
        AND csu.PRIMARY_FLAG              = 'Y'
        AND csu.STATUS                    = 'A'
        AND cas.status                    = 'A'
        AND cas.party_site_id             = ps.party_site_id
        AND HLOC.LOCATION_ID              = ps.location_id
        AND rownum                        = 1;

	l_hz_location_id number;

	cursor c_get_ware_hz_loc (v_org_id number, v_subinv varchar2) is
	select
	  c.hz_location_id,
	  h.city,
	  h.postal_code,
	  h.state,
	  h.province,
	  h.county,
	  h.country
	from
	  csp_planning_parameters c,
	  hz_locations h
	where c.organization_id = v_org_id
	  and nvl(c.secondary_inventory, 'NULL') = nvl(v_subinv, 'NULL')
	  and c.hz_location_id = h.location_id;

	cursor c_get_ware_hr_loc (v_org_id number, v_subinv varchar2) is
	select
	  hrloc.town_or_city as city,
	  hrloc.postal_code as postal_code,
	  null as state,
	  null as province,
	  null as county,
	  hrloc.country as country
	from
	  MTL_SECONDARY_INVENTORIES sub,
	  hr_all_organization_units org,
	  hr_locations_all hrloc
	where org.organization_id = v_org_id
	  and org.organization_id = sub.organization_id(+)
	  and sub.secondary_inventory_name(+) = v_subinv
	  and nvl(sub.location_id, org.location_id) = hrloc.location_id;

	cursor c_terr_result is
	select
	  tall.terr_id
	from
	  jtf_terr_all tall,
	  jtf_terr_results_gt_mt tmt,
	  JTF_TERR_TYPES_ALL tty
	where
	  tall.terr_id = tmt.terr_id
	  and tty.application_short_name = 'CSP'
	  and tty.org_id = tall.org_id
	  and tall.territory_type_id = tty.terr_type_id
	  and tty.enabled_flag = 'Y'
	  and tall.enabled_flag = 'Y'
	  and tall.start_date_active <= sysdate
	  and nvl(tall.end_date_active, sysdate+1) > sysdate
	order by tmt.absolute_rank desc;

	l_sr_rec JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type;
	l_source_terr_id	number;

BEGIN

	x_return_status := 'S';

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
				'Begin...');
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
				'p_source_type=' || p_source_type
				|| ', p_source_org_id=' || p_source_org_id
				|| ', p_source_subinv=' || p_source_subinv
				|| ', p_source_terr_id=' || p_source_terr_id
				|| ', p_ret_trans_type=' || p_ret_trans_type
				|| ', p_item_id=' || p_item_id);
	end if; -- End of FND Logger If block

	v_match_rule_id := null;
	v_match_rule_weight := null;

	if p_source_type = 'I' then

		open c_Scan_Subinv (p_source_org_id,
							p_source_subinv,
							p_ret_trans_type,
							p_item_id);
		fetch c_Scan_Subinv into v_match_rule_weight, v_match_rule_id;
		close c_Scan_Subinv;

		-- if no rule found based on source organization and subinv
		-- then find out the territory id for this source
		-- and then search for Internal Territory type
		-- rules for this territory source

		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
				'v_match_rule_id=' || v_match_rule_id
				|| ', v_match_rule_weight=' || v_match_rule_weight);
		end if; -- End of FND Logger If block

		if v_match_rule_id is null then
			open c_Source_Org_Type(p_source_org_id, p_source_subinv);
			fetch c_Source_Org_Type into l_Source_Org_Type;
			close c_Source_Org_Type;

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
					'l_Source_Org_Type=' || l_Source_Org_Type);
			end if; -- End of FND Logger If block

			if l_Source_Org_Type = 'TECHNICIAN' then

				open c_get_tech_add(p_source_org_id, p_source_subinv);
				fetch c_get_tech_add into l_city,
										l_postal_code,
										l_state,
										l_province,
										l_county,
										l_country;
				close c_get_tech_add;

			else	-- it is a warehouse

				-- first try to get HZ_location mentioned in the planner's desktop
				-- if not found then get hr_location for the organization
				l_hz_location_id := null;
				open c_get_ware_hz_loc(p_source_org_id, p_source_subinv);
				fetch c_get_ware_hz_loc into l_hz_location_id,
										l_city,
										l_postal_code,
										l_state,
										l_province,
										l_county,
										l_country;
				close c_get_ware_hz_loc;

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
						'l_hz_location_id=' || l_hz_location_id);
				end if; -- End of FND Logger If block

				-- no hz_location_id found? then check for hr_location
				if l_hz_location_id is null then

					open c_get_ware_hr_loc(p_source_org_id, p_source_subinv);
					fetch c_get_ware_hr_loc into l_city,
										l_postal_code,
										l_state,
										l_province,
										l_county,
										l_country;
					close c_get_ware_hr_loc;

				end if;	-- end of if l_hz_location_id is null

			end if; -- end if if l_Source_Org_Type = 'TECHNICIAN'

			if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
					'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
					'l_city=' || l_city
					|| ', l_postal_code=' || l_postal_code
					|| ', l_state=' || l_state
					|| ', l_province=' || l_province
					|| ', l_county=' || l_county
					|| ', l_country=' || l_country);
			end if; -- End of FND Logger If block

			if l_country is not null then

				-- so, we have geographycal data now
				-- call territory API to get all matching territories
				-- and find the best one

				l_sr_rec.CITY := l_city;
				l_sr_rec.POSTAL_CODE := l_postal_code;
				l_sr_rec.STATE := l_state;
				l_sr_rec.PROVINCE := l_province;
				l_sr_rec.COUNTY := l_county;
				l_sr_rec.COUNTRY := l_country;

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
						'Calling JTY_TERR_SPARES_PVT.process_match_terr_spares ...');
				end if; -- End of FND Logger If block

				JTY_TERR_SPARES_PVT.process_match_terr_spares (
											p_api_version_number => 1.0,
											p_init_msg_list => fnd_api.g_true,
											p_TerrServReq_Rec => l_sr_rec,
											p_Resource_Type => null,
											p_Role => null,
											p_plan_start_date => null,
											p_plan_end_date => null,
											x_return_status => x_return_status,
											x_msg_count => x_msg_count,
											X_msg_data => X_msg_data
										);

				if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
						'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
						'Status returned from  JTY_TERR_SPARES_PVT.process_match_terr_spares = '
						|| x_return_status);
				end if; -- End of FND Logger If block

				if x_return_status = 'S' then

					begin
						for c_terr in c_terr_result loop

							if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
								FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
									'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
									'c_terr.terr_id =' || c_terr.terr_id);
							end if; -- End of FND Logger If block

							l_source_terr_id := c_terr.terr_id;

							if l_source_terr_id is not null then

								open c_Scan_Terr (l_source_terr_id,
													'T',
													p_ret_trans_type,
													p_item_id);
								fetch c_Scan_Terr into v_match_rule_weight, v_match_rule_id;
								close c_Scan_Terr;

								exit when v_match_rule_id is not null;

							end if;		-- if l_source_terr_id is not null

						end loop;	-- for c_terr in c_terr_result loop

						if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
							FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
								'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
								'FOR loop ended with v_match_rule_id = ' || v_match_rule_id);
						end if; -- End of FND Logger If block

					exception
						when NO_DATA_FOUND then
							v_match_rule_id := null;
					end;

				end if;	-- end of if x_return_status = 'S'

			end if; -- end of if l_country is not null

		end if;	-- end for if v_match_rule_id is null condition

	elsif p_source_type = 'C' then  -- Else of if p_source_type = 'I' (p_source_type = 'C')

		open c_Scan_Terr (p_source_terr_id,
							'C',
							p_ret_trans_type,
							p_item_id);
		fetch c_Scan_Terr into v_match_rule_weight, v_match_rule_id;
		close c_Scan_Terr;

	elsif p_source_type = 'T' then  -- Else of if p_source_type = 'I' (p_source_type = 'C')

		open c_Scan_Terr (p_source_terr_id,
							'T',
							p_ret_trans_type,
							p_item_id);
		fetch c_Scan_Terr into v_match_rule_weight, v_match_rule_id;
		close c_Scan_Terr;

	end if;	-- End of if p_source_type = 'I'

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
				'csp.plsql.CSP_EXCESS_PARTS_PVT.find_best_routing_rule',
				'v_match_rule_id=' || v_match_rule_id
				|| ', v_match_rule_weight=' || v_match_rule_weight);
	end if; -- End of FND Logger If block

	if v_match_rule_id is not null then
		x_rule_id := v_match_rule_id;
	end if;

END;	-- End of procedure find_best_routing_rule

procedure charges_return_routing(
            p_return_type       in  varchar2,
            p_hz_location_id    in  number,
            p_item_id           in  number,
            x_operating_unit    out nocopy number,
            x_organization_id   out nocopy number,
            x_subinventory_code out nocopy varchar2,
            x_hz_location_id    out nocopy number,
            x_hr_location_id    out nocopy number,
            x_return_status     out nocopy varchar2,
            x_msg_count         out nocopy number,
            x_msg_data          out nocopy varchar2) is

  cursor c_terr_results is
  select tall.terr_id
  from   jtf_terr_all tall,
         jtf_terr_results_gt_mt tmt,
         jtf_terr_types_all tty
  where  tall.terr_id = tmt.terr_id
  and    tty.application_short_name = 'CSP'
  and    tty.org_id = tall.org_id
  and    tall.territory_type_id = tty.terr_type_id
  and    tty.enabled_flag = 'Y'
  and    tall.enabled_flag='Y'
  and    tall.start_date_active <=sysdate
  and    nvl(tall.end_date_active,sysdate+1) >= sysdate
  order by tmt.absolute_rank desc;

  cursor c_address is
  select hl.city,hl.postal_code,hl.state,hl.province,hl.county,hl.country
  from   hz_locations hl
  where  hl.location_id = p_hz_location_id;

  cursor c_destination(p_return_rule_id number) is
  select crrr.dest_org_id,
         crrr.dest_subinv,
         cpp.hz_location_id,
         hoa.location_id,
         ood.operating_unit
  from   csp_return_routing_rules crrr,
         hr_organization_units hoa,
         csp_planning_parameters cpp,
         org_organization_definitions ood
  where  crrr.rule_id = p_return_rule_id
  and    crrr.dest_subinv is null
  and    crrr.dest_org_id = hoa.organization_id
  and    ood.organization_id = hoa.organization_id
  and    cpp.organization_id (+) = crrr.dest_org_id
  and    cpp.secondary_inventory (+) = crrr.dest_subinv
  union
  select crrr.dest_org_id,
         crrr.dest_subinv,
         cpp.hz_location_id,
         msi.location_id,
         ood.operating_unit
  from   csp_return_routing_rules crrr,
         mtl_secondary_inventories msi,
         csp_planning_parameters cpp,
         org_organization_definitions ood
  where  crrr.rule_id = p_return_rule_id
  and    crrr.dest_org_id = msi.organization_id
  and    crrr.dest_subinv = msi.secondary_inventory_name
  and    ood.organization_id = msi.organization_id
  and    cpp.organization_id (+) = crrr.dest_org_id
  and    cpp.secondary_inventory (+) = crrr.dest_subinv
  and    crrr.dest_subinv is not null;

  l_sr_rec JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type;
  x_return_rule_id number := null;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Find Territory
  open  c_address;
  fetch c_address into l_sr_rec.city,
                       l_sr_rec.postal_code,
                       l_sr_rec.state,
                       l_sr_rec.province,
                       l_sr_rec.county,
                       l_sr_rec.country;
  close c_address;

  jty_terr_spares_pvt.process_match_terr_spares(
    p_api_version_number => 1.0,
    p_init_msg_list => fnd_api.g_true,
    p_terrservreq_rec => l_sr_rec,
    p_resource_type => null,
    p_role => null,
    p_plan_start_date => null,
    p_plan_end_date => null,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);

-- Loop through territories
  for ctr in c_terr_results loop
-- Look for routing rule for territory
    find_best_routing_rule(
      p_source_type => 'T',
      p_source_org_id => null,
      p_source_subinv => null,
      p_source_terr_id => ctr.terr_id,
      p_ret_trans_type => p_return_type,
      p_item_id => p_item_id,
      x_rule_id => x_return_rule_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
    if x_return_rule_id is not null then
      exit;
    end if;
  end loop;

  if x_return_rule_id is not null then
    open  c_destination(x_return_rule_id);
    fetch c_destination into x_organization_id,
                             x_subinventory_code,
                             x_hz_location_id,
                             x_hr_location_id,
                             x_operating_unit;
    close c_destination;
  else
    fnd_message.set_name('CSP', 'CSP_NO_ROUTING_RULE');
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

end charges_return_routing;

end;

/
