--------------------------------------------------------
--  DDL for Package Body MSC_REL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_REL_WF" AS
/*$Header: MSCRLWFB.pls 120.11.12010000.5 2010/05/10 20:21:30 hulu ship $ */

  g_item_type varchar2(10) := 'MSCRELWF';


PROCEDURE release_supplies
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER
, arg_plan_id			IN      NUMBER
, arg_org_id 	   	IN 	NUMBER
, arg_instance           IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER) IS


   CURSOR po_res IS
    SELECT s.transaction_id, s.sr_instance_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    where   s.release_errors is NULL
    AND   s.po_line_id is not null
    AND   s.plan_id = orgs.plan_id
    and   s.load_type = PURCHASE_ORDER_RESCHEDULE
    and   s.order_type = PURCHASE_ORDER
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.planned_organization = decode(arg_org_id,
                        arg_owning_org_id, orgs.planned_organization,
                        arg_org_id)
    AND   orgs.sr_instance_id = decode(arg_instance,
                        arg_owning_instance, orgs.sr_instance_id,
                        arg_instance);

   CURSOR req_res IS
    SELECT s.transaction_id, s.sr_instance_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    where   s.release_errors is NULL
    AND   s.plan_id = orgs.plan_id
    and   s.load_type = PURCHASE_REQ_RESCHEDULE
    and   s.order_type = PURCHASE_REQ
    AND   s.po_line_id IS NOT NULL
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.planned_organization = decode(arg_org_id,
                        arg_owning_org_id, orgs.planned_organization,
                        arg_org_id)
    AND   orgs.sr_instance_id = decode(arg_instance,
                        arg_owning_instance, orgs.sr_instance_id,
                        arg_instance);

   CURSOR instances_cur IS
    SELECT distinct mai.instance_id,
           decode(mai.m2a_dblink, null,' ','@'||m2a_dblink),
           mai.instance_code
     FROM msc_apps_instances mai,
          msc_plan_organizations_v orgs
    where orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.planned_organization = decode(arg_org_id,
                        arg_owning_org_id, orgs.planned_organization,
                        arg_org_id)
    AND   orgs.sr_instance_id = decode(arg_instance,
                        arg_owning_instance, orgs.sr_instance_id,
                        arg_instance)
    AND   orgs.sr_instance_id = mai.instance_id;

    v_transaction_id number;
    v_instance_id number;
    v_load_type number;
    v_dblink varchar2(128);
    v_instance_code varchar2(5);

    cursor batch_cur IS
    SELECT distinct load_type
      from msc_supplies
     where plan_id = arg_plan_id
       and sr_instance_id = v_instance_id
       and load_type in (WIP_DIS_MASS_LOAD,WIP_REP_MASS_LOAD,
                         LOT_BASED_JOB_LOAD,LOT_BASED_JOB_RESCHEDULE,
                         WIP_DIS_MASS_RESCHEDULE,PURCHASE_REQ_MASS_LOAD,
                         EAM_DIS_MASS_RESCHEDULE);
BEGIN
     retcode :=0;
      msc_util.msc_debug('****** Start of Program ******');
      -- launch wf for purchase order reschedule
      OPEN po_res;
      LOOP
      FETCH po_res INTO v_transaction_id, v_instance_id;
      EXIT WHEN po_res%NOTFOUND;
         msc_util.msc_debug('start workflow to reschedule Purchase Order, transaction_id ='||v_transaction_id);
         start_reschedule_po_wf(arg_plan_id, v_transaction_id,
                             v_instance_id, PURCHASE_ORDER_RESCHEDULE);
      END LOOP;
      CLOSE po_res;

      -- launch wf for purchase req reschedule
      OPEN req_res;
      LOOP
      FETCH req_res INTO v_transaction_id, v_instance_id;
      EXIT WHEN req_res%NOTFOUND;
         msc_util.msc_debug('start workflow to reschedule Purchase Req, transaction_id='||v_transaction_id);
         start_reschedule_po_wf(arg_plan_id, v_transaction_id,
                             v_instance_id, PURCHASE_REQ_RESCHEDULE);
      END LOOP;
      CLOSE req_res;

      -- lauch workflow for releasing supplies in batch process
      open instances_cur;  -- loop thru each instance
      LOOP
        FETCH instances_cur INTO v_instance_id, v_dblink, v_instance_code;
        EXIT WHEN instances_cur%NOTFOUND;
        OPEN batch_cur; -- launch one workflow for each load type
        LOOP
          FETCH batch_cur INTO v_load_type;
          EXIT WHEN batch_cur%NOTFOUND;
            msc_util.msc_debug('start workflow for batch update');
            start_release_batch_wf(arg_plan_id, arg_org_id, v_instance_id,
                       arg_owning_org_id, arg_owning_instance,v_dblink,
                       v_load_type, v_instance_code);
          END LOOP;
          close batch_cur;

      END LOOP;
      close instances_cur;

exception when others then
  retcode :=2;
  raise;
END release_supplies;

Procedure start_reschedule_po_wf(p_plan_id number,
                              p_transaction_id number,
                              p_instance_id number,
                              p_load_type number) IS

  p_item_key varchar2(30) := to_char(p_plan_id)||'-'||
                                    to_char(p_transaction_id);
   p_process varchar2(30);
   p_dblink varchar2(128);
   p_instance_code varchar2(5);

   CURSOR instance_cur IS
    SELECT decode(mai.m2a_dblink, null,' ','@'||m2a_dblink),
           mai.instance_code
     FROM msc_apps_instances mai
    WHERE mai.instance_id = p_instance_id;
BEGIN
    deleteActivities(p_item_key);

    OPEN instance_cur;
    FETCH instance_cur INTO p_dblink, p_instance_code;
    CLOSE instance_cur;

    if p_dblink is not null then
      deleteActivities(p_item_key,p_dblink);
    end if;

    p_process := 'RES_PO';

    wf_engine.CreateProcess( itemtype => g_item_type,
                             itemkey  => p_item_key,
                             process  => p_process);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'PLAN_ID',
                                 avalue   => p_plan_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'TRANSACTION_ID',
                                 avalue   => p_transaction_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'SR_INSTANCE_ID',
                                 avalue   => p_instance_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'LOAD_TYPE',
                                 avalue   => p_load_type);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'DBLINK',
                                 avalue   => p_dblink);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'INSTANCE_CODE',
                                 avalue   => p_instance_code);

    wf_engine.StartProcess( itemtype => g_item_type,
                          itemkey  => p_item_key);

    reset_load_type(p_plan_id, p_transaction_id);
exception when others then
   raise;
END start_reschedule_po_wf;

Procedure notify_planner_program(p_plan_id number,
                                p_transaction_id number,
                                p_planner varchar2,
                                p_process varchar2) IS
  p_result boolean;
  p_request_id number;
Begin
   msc_rel_wf.init_db(p_planner);
    p_result := fnd_request.set_mode(true);
      -- this will call mrp_rel_wf.reschedule_po_wf

    p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCNTFPN',
                         null,
                         null,
                         false,
                         p_plan_id,
                         p_transaction_id,
                         p_planner,
                         p_process);

exception when others then
 p_request_id :=0;
 raise;
End notify_planner_program;

Procedure notify_planner_decline(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                                p_plan_id number,
                                p_transaction_id number,
                                p_planner varchar2,
                                p_process varchar2) IS

  p_item_key varchar2(100) := to_char(p_plan_id)
                                       ||'-'||to_char(p_transaction_id)
                                       ||'-'||p_process;

  Cursor po_attri IS
   select mp.compile_designator,
          msi.item_name,
          msc_get_name.org_code(ms.organization_id,ms.sr_instance_id),
          msc_get_name.supplier(ms.supplier_id),
          DECODE(ms.order_type,5,to_char(ms.transaction_id),ms.order_number),
          msc_get_name.lookup_meaning('MRP_ORDER_TYPE',ms.order_type),
          ms.new_schedule_date,
          ms.implement_date,
          ms.new_order_quantity,
          msi.buyer_name
    from msc_plans mp,
         msc_system_items msi,
         msc_supplies ms
    where ms.plan_id = p_plan_id
      and ms.transaction_id = p_transaction_id
      and mp.plan_id = ms.plan_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
;

   l_plan_name varchar2(20);
   l_item_name varchar2(40);
   l_org_code varchar2(7);
   l_supplier varchar2(80);
   l_buyer varchar2(80);
   l_order varchar2(80);
   l_order_type varchar2(80);
   l_old_date date;
   l_new_date date;
   l_qty number;
BEGIN

    OPEN po_attri;
    FETCH po_attri INTO l_plan_name,
                        l_item_name,
                        l_org_code,
                        l_supplier,
                        l_order,
                        l_order_type,
                        l_old_date,
                        l_new_date,
                        l_qty,
                        l_buyer;
    wf_engine.CreateProcess( itemtype => g_item_type,
                             itemkey  => p_item_key,
                             process  => p_process);

    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'PLANNER',
                                 avalue   => p_planner);

    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'BUYER',
                                 avalue   => l_buyer);

    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'PLAN_NAME',
                                 avalue   => l_plan_name);

    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ITEM_NAME',
                                 avalue   => l_item_name);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORG_CODE',
                                 avalue   => l_org_code);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'SUPPLIER',
                                 avalue   => l_supplier);

    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORDER_NAME',
                                 avalue   => l_order);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORDER_TYPE',
                                 avalue   => l_order_type);
    wf_engine.SetItemAttrDate( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORDER_DATE',
                                 avalue   => l_old_date);
    wf_engine.SetItemAttrDate( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'NEW_ORDER_DATE',
                                 avalue   => l_new_date);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORDER_QTY',
                                 avalue   => l_qty);

    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'PLAN_ID',
                                 avalue   => p_plan_id);

    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'TRANSACTION_ID',
                                 avalue   => p_transaction_id);

    wf_engine.StartProcess( itemtype => g_item_type,
                          itemkey  => p_item_key);
exception when others then
    wf_core.context('MSC_REL_WF', 'notify planner', p_item_key,g_item_type);
    raise;
END notify_planner_decline;

PROCEDURE Select_buyer_supplier( itemtype  in varchar2,
                         itemkey   in varchar2,
                         actid     in number,
                         funcmode  in varchar2,
                         resultout out NOCOPY varchar2 ) is
   p_plan_id number;
   p_transaction_id number;
   p_load_type number;
   lv_sql_stmt varchar2(2000);
   l_supplier varchar2(100);
   p_dblink	varchar2(30);
   p_process	varchar2(30);
   l_buyer varchar2(50);
   p_request_id number;
   p_query_id number;
   l_plan_name varchar2(20);
   l_load_type number;
   p_instance_code varchar2(20);
   l_item_name varchar2(40);
   l_org_code varchar2(7);
   l_order varchar2(80);
   l_order_type varchar2(80);
   l_old_date date;
   l_new_date date;
   l_qty number;
   l_planner varchar2(40) := FND_PROFILE.VALUE('USERNAME');
   l_resp_name varchar2(80) :=FND_GLOBAL.RESP_NAME;
   TYPE PoCurTyp IS REF CURSOR;
   poCur PoCurTyp;

   CURSOR buyer_c IS
   select mpc.name
     from msc_supplies ms,
          msc_system_items msi,
          msc_partner_contacts mpc
    where  ms.plan_id = p_plan_id
      and ms.transaction_id = p_transaction_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and msi.sr_instance_id = mpc.sr_instance_id
      and msi.buyer_id = mpc.partner_id
      and mpc.partner_type =4;

   CURSOR supplier_c IS
   select mpc.name
     from msc_supplies ms,
          msc_partner_contacts mpc
    where  ms.plan_id = p_plan_id
      and ms.transaction_id = p_transaction_id
      and ms.sr_instance_id = mpc.sr_instance_id
      and ms.supplier_id = mpc.partner_id
      and mpc.partner_type =1;

  Cursor detail_attri IS
   select mp.compile_designator,
          msc_get_name.item_name(ms.inventory_item_id, null,null,null),
          msc_get_name.org_code(ms.organization_id,ms.sr_instance_id),
          DECODE(ms.order_type,5,to_char(ms.transaction_id),ms.order_number),
          msc_get_name.lookup_meaning('MRP_ORDER_TYPE',ms.order_type),
          ms.new_schedule_date,
          ms.implement_date,
          ms.new_order_quantity
    from msc_plans mp,
         msc_supplies ms
    where ms.plan_id = p_plan_id
      and ms.transaction_id = p_transaction_id
      and mp.plan_id = ms.plan_id
;

BEGIN

  if (funcmode = 'RUN') then
      p_plan_id :=
      wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_ID');

      p_transaction_id :=
      wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TRANSACTION_ID');

      p_load_type :=
      wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOAD_TYPE');

      p_dblink :=
      wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'DBLINK');

      p_instance_code :=
      wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'INSTANCE_CODE');

      OPEN buyer_c;
      FETCH buyer_c INTO l_buyer;
      CLOSE buyer_c;




   if p_load_type = PURCHASE_ORDER_RESCHEDULE then
      OPEN supplier_c;
      FETCH supplier_c INTO l_supplier;
      CLOSE supplier_c;
      msc_util.msc_debug('supplier is '||l_supplier);
   end if;
-- l_buyer := 'MFG';
-- l_buyer := null;
-- l_supplier := 'MFG';
-- l_supplier :=null;
      msc_util.msc_debug('buyer is '||l_buyer);
      if (p_load_type = PURCHASE_ORDER_RESCHEDULE and
          l_supplier is not null) or
         (p_load_type = PURCHASE_REQ_RESCHEDULE and
          l_buyer is not null) then
        lv_sql_stmt:=
          'select mrp_form_query_s.nextval'||p_dblink||
          ' from dual';

        OPEN poCur FOR lv_sql_stmt;
        FETCH poCur INTO p_query_id;
        CLOSE poCur;

        get_supply_data(p_plan_id, p_transaction_id, p_query_id, p_dblink);
        commit;
        -- start the workflow in the source instance thru concurrent program
        lv_sql_stmt:=
           'BEGIN'
        ||'  mrp_rel_wf.start_workflow_program'||p_dblink||'('
                                          ||'   :p_process,'
                                          ||'   :p_resp,'
                                          ||'   :p_plan_id,'
                                          ||'   :p_transaction_id,'
                                          ||'   :p_buyer, '
                                          ||'   :p_supplier, '
                                          ||'   :p_query_id, '
                                          ||' :p_request_id);'
        ||' END;';

        if p_load_type = PURCHASE_ORDER_RESCHEDULE then
           p_process := 'RES_PO_IN_SOURCE';
        else
           p_process := 'RES_REQ_IN_SOURCE';
        end if;

        EXECUTE IMMEDIATE lv_sql_stmt
                USING
                       IN p_process,
                       IN l_planner,
                       IN p_plan_id,
                       IN p_transaction_id,
                       IN l_buyer,
                       IN l_supplier,
                       IN p_query_id,
                       OUT p_request_id;
       commit;
       msc_util.msc_debug('launch concurrent program in the source '||p_instance_code);
       msc_util.msc_debug('request_id ='||p_request_id);
       resultout := 'COMPLETE:FOUND';

      else

        open detail_attri;
        FETCH detail_attri INTO l_plan_name,
                        l_item_name,
                        l_org_code,
                        l_order,
                        l_order_type,
                        l_old_date,
                        l_new_date,
                        l_qty;
        CLOSE detail_attri;

        msc_util.msc_debug('notify planner no buyer/supplier found');
    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PLAN_NAME',
                                 avalue   => l_plan_name);

    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ITEM_NAME',
                                 avalue   => l_item_name);
    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PLANNER',
                                 avalue   => l_planner);
    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORG_CODE',
                                 avalue   => l_org_code);

    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_NAME',
                                 avalue   => l_order);

    wf_engine.SetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_TYPE',
                                 avalue   => l_order_type);

    wf_engine.SetItemAttrDate( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_DATE',
                                 avalue   => l_old_date);

    wf_engine.SetItemAttrDate( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'NEW_ORDER_DATE',
                                 avalue   => l_new_date);

    wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_QTY',
                                 avalue   => l_qty);

        resultout := 'COMPLETE:NOT_FOUND';
      end if;
   end if;
  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
  end if;
END select_buyer_supplier;

PROCEDURE DeleteActivities( p_item_key varchar2,
                            p_dblink varchar2 default null) IS

   TYPE DelExpType is REF CURSOR;
   delete_activities_c DelExpType;

  l_item_key		varchar2(240);
  sql_stmt              varchar2(500);
  a number;
BEGIN

    sql_stmt := ' SELECT item_key ' ||
                ' FROM wf_items' || p_dblink ||
                ' WHERE item_type = :item_type' ||
                ' AND   item_key like '''|| p_item_key || '%''';
    OPEN delete_activities_c for sql_stmt USING g_item_type;
    LOOP

      FETCH DELETE_ACTIVITIES_C INTO l_item_key;
      EXIT WHEN DELETE_ACTIVITIES_C%NOTFOUND;

      sql_stmt :=
      'update wf_notifications' || p_dblink ||
      ' set    end_date = sysdate - 450' ||
      ' where  group_id in ' ||
      '  (select notification_id' ||
      '  from wf_item_activity_statuses' ||p_dblink ||
      '  where item_type = :item_type' ||
      '  and item_key = :l_item_key' ||
      '  union' ||
      '  select notification_id' ||
      '  from wf_item_activity_statuses_h' || p_dblink ||
      '  where item_type = :item_type' ||
      '  and item_key = :l_item_key)';

      EXECUTE IMMEDIATE sql_stmt USING g_item_type,l_item_key,
                                       g_item_type,l_item_key;

      sql_stmt :=
      ' update wf_items' || p_dblink ||
      ' set end_date = sysdate - 450' ||
      ' where item_type = :item_type'||
      ' and item_key = :l_item_key';

      EXECUTE IMMEDIATE sql_stmt USING g_item_type,l_item_key;

      sql_stmt :=
      ' update wf_item_activity_statuses'|| p_dblink ||
      ' set end_date = sysdate - 450' ||
      ' where item_type = :item_type'||
      ' and item_key = :l_item_key';
      EXECUTE IMMEDIATE sql_stmt USING g_item_type,l_item_key;

      sql_stmt :=
      ' update wf_item_activity_statuses_h'|| p_dblink ||
      ' set end_date = sysdate - 450' ||
      ' where item_type = :item_type'||
      ' and item_key = :l_item_key';

      EXECUTE IMMEDIATE sql_stmt USING g_item_type,l_item_key;

      sql_stmt :=
      'begin wf_purge.total'|| p_dblink||
      '( :item_type,:l_item_key,sysdate - 450);end;';
      EXECUTE IMMEDIATE sql_stmt USING g_item_type,l_item_key;

    END LOOP; -- for the itemkey loop
    CLOSE delete_activities_c;


EXCEPTION
  when others then
    msc_util.msc_debug('Error in delete activities:'|| to_char(sqlcode) || ':' || substr(sqlerrm,1,100));
      return;
END DeleteActivities;

Procedure reset_load_type (p_plan_id number, p_transaction_id number) IS
BEGIN
           UPDATE MSC_SUPPLIES
              SET implement_date = NULL,
                  release_status = NULL,
                  load_type = NULL
            WHERE transaction_id= p_transaction_id
              AND plan_id= p_plan_id;
         commit;
end reset_load_type;

FUNCTION GET_DOCK_DATE(p_instance_id NUMBER,
                         p_receiving_calendar VARCHAR2,
                         p_delivery_calendar VARCHAR2,
                         p_implement_date DATE,
                         p_lead_time NUMBER ) RETURN date IS

dock_date Date;

BEGIN

-- first use receiving calendar to offset the post processing lead time

     dock_date := msc_rel_wf.get_offset_date(p_receiving_calendar,
                                             p_instance_id,
                                        -1*p_lead_time, p_implement_date);

     dock_date := msc_drp_util.get_work_day('PREV',p_receiving_calendar,
                                            p_instance_id,dock_date);

  -- then find the working date using receiving calendar,
  if p_delivery_calendar is not null then
     dock_date := msc_drp_util.get_work_day('PREV',p_delivery_calendar,
                                            p_instance_id,dock_date);

  end if;
     if dock_date < sysdate then
        dock_date := sysdate;
     end if;
RETURN(dock_date);
END GET_DOCK_DATE;

PROCEDURE reschedule_purchase_orders
( arg_plan_id			IN      NUMBER
, arg_org_id 		IN 	NUMBER
, arg_instance              IN      NUMBER
, arg_owning_org 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_count                     OUT NOCOPY NUMBER
, arg_released_instance         IN OUT NOCOPY NumTblTyp
, arg_po_res_id 		IN OUT NOCOPY NumTblTyp
, arg_po_res_count              IN OUT NOCOPY NumTblTyp
, arg_po_pwb_count              IN OUT NOCOPY NumTblTyp) IS

  p_user_id number := FND_PROFILE.value('USER_ID');
  p_release_by_user varchar2(3) :=
                      nvl(FND_PROFILE.value('MSC_RELEASED_BY_USER_ONLY'),'N');

   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE DateTab  IS TABLE OF Date INDEX BY BINARY_INTEGER;
   TYPE CharTab  IS TABLE OF varchar2(240) INDEX BY BINARY_INTEGER;

  p_new_need_by_date DateTab;
  p_old_need_by_date DateTab;
  p_po_line_id NumTab;
  p_po_header_id NumTab;
  p_po_number CharTab;
  p_po_quantity NumTab;
  p_po_instance_id NumTab;
  p_plan_id NumTab;
  p_action NumTab;
  p_shipment_id     NumTab;
  p_distribution_id NumTab;
  p_operating_unit  numtab;
  p_dest_dblink varchar2(128);

-- xml fix
  p_source_line_id NumTab;
  p_uom_code       CharTab;

  p_timestamp number:=1439/1440;
  CURSOR instance_cur IS
   select  distinct mp.sr_instance_id,
           decode(mai.M2A_dblink,null,' ','@'||mai.M2A_dblink),
           nvl(mai.A2M_dblink, '-1'),
           mai.instance_code
   from    msc_plan_organizations mp,
           msc_apps_instances mai
   where   plan_id = arg_plan_id
     and   mp.sr_instance_id = mai.instance_id
     and   mai.instance_type <> 3    -- xml fix
     and   nvl(mai.apps_ver,1) <> 1; -- not back port to 107 yet

  CURSOR leg_instance_cur IS
   select  distinct mp.sr_instance_id
   from    msc_plan_organizations mp,
           msc_apps_instances mai
   where   plan_id = arg_plan_id
     and   mp.sr_instance_id = mai.instance_id
     and   mai.instance_type = 3;    -- xml fix

    p_user_name varchar2(30) :=FND_GLOBAL.USER_NAME; --FND_PROFILE.VALUE('USERNAME');
    p_resp_name varchar2(80) :=FND_GLOBAL.RESP_NAME;
    p_dblink varchar2(128);
    p_instance_id number;
    p_instance_code varchar2(3);
    lv_sql_stmt varchar2(2000);
    p_request_id number:=0;
    v_batch_id number;
    v_temp number;
    v_temp2 number;
    v_autorelease number;
    null_date date := null;

  CURSOR c_plan_type(p_plan_id number) IS
     select plan_type
       from msc_plans a
       where
       plan_id = p_plan_id;

  p_plan_type NUMBER;
BEGIN

     arg_count :=0;

     OPEN c_plan_type(arg_plan_id);
     FETCH c_plan_type INTO p_plan_type;
     CLOSE c_plan_type;
     begin  -- xml fix

      if (p_plan_type>100) then   -- rp plan
       SELECT  s.sr_instance_id,
                -- trunc(nvl(s.promised_date,s.need_by_date)) +p_timestamp old_need_by_date,
                trunc(nvl(s.promised_date,s.original_need_by_date)) old_need_by_date,
                trunc(min(get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time,0))))+ p_timestamp new_need_by_date,
                s.disposition_id po_header_id,
                s.po_line_id po_line_id,
                s.order_number po_number,
                min(s.implement_quantity) qty,
                s.po_line_location_id shipment_id,
                s.po_distribution_id distribution_id,
                nvl(s.implement_uom_code,msi.uom_code) uom,
                mp.operating_unit operating_unit,
		s.disposition_status_type action
        BULK COLLECT INTO
                p_po_instance_id,
                p_old_need_by_date,
                p_new_need_by_date,
                p_po_header_id,
                p_po_line_id,
                p_po_number,
                p_po_quantity,
                p_shipment_id,
                p_distribution_id,
                p_uom_code,
                p_operating_unit,
		p_action
        FROM    msc_apps_instances mai,                         -- xml fix
                msc_system_items msi,
                msc_trading_partners mp,
                msc_supplies s
        WHERE   msi.inventory_item_id = s.inventory_item_id
        AND     msi.plan_id = s.plan_id
        AND     msi.organization_id = s.organization_id
        and     msi.sr_instance_id = s.sr_instance_id
        AND     mp.sr_tp_id = msi.organization_id
        AND     mp.sr_instance_id = msi.sr_instance_id
        AND     mp.partner_type= 3
        and     mai.instance_id = s.sr_instance_id             -- xml fix
        and     mai.instance_type <> 3                         -- xml fix- only for non legacy
        AND     s.plan_id = arg_plan_id
        AND     s.release_errors is NULL
        and     s.load_type = 20
        and     s.order_type = 1
        and     s.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                s.last_updated_by)
        group by s.sr_instance_id,
                trunc(nvl(s.promised_date,s.original_need_by_date)) ,
                --  trunc(nvl(s.promised_date,s.need_by_date))+p_timestamp,
                 s.disposition_id,
          s.po_line_id, s.order_number, s.disposition_status_type,
          s.po_line_location_id, po_distribution_id,
          nvl(s.implement_uom_code,msi.uom_code), mp.operating_unit;



      else

        SELECT  s.sr_instance_id,
                nvl(s.promised_date,s.need_by_date) old_need_by_date,
                min(get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time,0))) new_need_by_date,
                s.disposition_id po_header_id,
                s.po_line_id po_line_id,
                s.order_number po_number,
                min(s.implement_quantity) qty,
                s.po_line_location_id shipment_id,
                s.po_distribution_id distribution_id,
                nvl(s.implement_uom_code,msi.uom_code) uom,
                mp.operating_unit operating_unit,
		s.disposition_status_type action
        BULK COLLECT INTO
                p_po_instance_id,
                p_old_need_by_date,
                p_new_need_by_date,
                p_po_header_id,
                p_po_line_id,
                p_po_number,
                p_po_quantity,
                p_shipment_id,
                p_distribution_id,
                p_uom_code,
                p_operating_unit,
		p_action
        FROM    msc_apps_instances mai,                         -- xml fix
                msc_system_items msi,
                msc_trading_partners mp,
                msc_supplies s
        WHERE   msi.inventory_item_id = s.inventory_item_id
        AND     msi.plan_id = s.plan_id
        AND     msi.organization_id = s.organization_id
        and     msi.sr_instance_id = s.sr_instance_id
        AND     mp.sr_tp_id = msi.organization_id
        AND     mp.sr_instance_id = msi.sr_instance_id
        AND     mp.partner_type= 3
        and     mai.instance_id = s.sr_instance_id             -- xml fix
        and     mai.instance_type <> 3                         -- xml fix- only for non legacy
        AND     s.plan_id = arg_plan_id
        AND     s.release_errors is NULL
        and     s.load_type = 20
        and     s.order_type = 1
        and     s.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                s.last_updated_by)
        group by s.sr_instance_id,nvl(s.promised_date,s.need_by_date),
                 s.disposition_id,
          s.po_line_id, s.order_number, s.disposition_status_type,
          s.po_line_location_id, po_distribution_id,
          nvl(s.implement_uom_code,msi.uom_code), mp.operating_unit;


     end if;
     select msc_form_query_s.nextval
      into v_batch_id
      from dual;
     forall a in 1..p_po_instance_id.count
        insert into msc_purchase_order_interface
           (last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            batch_id,
            sr_instance_id,
            old_need_by_date,
            new_need_by_date,
            po_header_id,
            po_line_id,
            po_number,
            po_quantity,
	    action,
            po_line_location_id,
            po_distribution_id,
            uom,
            operating_unit)
        values
            (sysdate,
             p_user_id,
             sysdate,
             p_user_id,
             v_batch_id,
             p_po_instance_id(a),
             p_old_need_by_date(a),
             p_new_need_by_date(a),
             p_po_header_id(a),
             p_po_line_id(a),
             p_po_number(a),
             p_po_quantity(a),
	     p_action(a),
             p_shipment_id(a),
             p_distribution_id(a),
             p_uom_code(a),
             p_operating_unit(a));

      commit;
     exception
      when VALUE_ERROR then
      null;
      when COLLECTION_IS_NULL then
          null;
      when NO_DATA_FOUND then
          null;
     end;

--  xml fix : for legacy instances insert into msc_po_reschedule_interface

      begin
       if (p_plan_type>100) then --- rp plan
        SELECT  s.sr_instance_id,
                s.transaction_id,                         -- xml fix
                nvl(s.implement_uom_code,msi.uom_code),   -- xml fix
                trunc(nvl(s.promised_date,s.need_by_date))+p_timestamp old_need_by_date,
                trunc(get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,
                                        s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time, 0)))+p_timestamp  new_need_by_date,
                s.disposition_id po_header_id,
                s.po_line_id po_line_id,
                s.order_number po_number,
                min(s.implement_quantity) qty,
                s.plan_id
        BULK COLLECT INTO
                p_po_instance_id,
                p_source_line_id,                         -- xml fix
                p_uom_code,                               -- xml fix
                p_old_need_by_date,
                p_new_need_by_date,
                p_po_header_id,
                p_po_line_id,
                p_po_number,
                p_po_quantity,
                p_plan_id
        FROM    msc_apps_instances mai,
                msc_system_items msi,
                msc_supplies s
        WHERE   msi.inventory_item_id = s.inventory_item_id
        AND     msi.plan_id = s.plan_id
        AND     msi.organization_id = s.organization_id
        and     msi.sr_instance_id = s.sr_instance_id
        and     mai.instance_id = s.sr_instance_id             -- xml fix
        and     mai.instance_type = 3                          -- xml fix
        AND     s.plan_id = arg_plan_id
        AND     s.release_errors is NULL
        and     s.load_type = 20
        and     s.order_type = 1
        and     s.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                s.last_updated_by)
        group by s.sr_instance_id, s.transaction_id,
                 nvl(s.implement_uom_code,msi.uom_code),
                 trunc(nvl(s.promised_date,s.need_by_date))+p_timestamp,
                 trunc(get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,
                                        s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time, 0)))+p_timestamp,
                 s.disposition_id,s.po_line_id, s.order_number,s.plan_id;



      else

        SELECT  s.sr_instance_id,
                s.transaction_id,                         -- xml fix
                nvl(s.implement_uom_code,msi.uom_code),   -- xml fix
                nvl(s.promised_date,s.need_by_date) old_need_by_date,
                get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,
                                        s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time, 0)) new_need_by_date,
                s.disposition_id po_header_id,
                s.po_line_id po_line_id,
                s.order_number po_number,
                min(s.implement_quantity) qty,
                s.plan_id
        BULK COLLECT INTO
                p_po_instance_id,
                p_source_line_id,                         -- xml fix
                p_uom_code,                               -- xml fix
                p_old_need_by_date,
                p_new_need_by_date,
                p_po_header_id,
                p_po_line_id,
                p_po_number,
                p_po_quantity,
                p_plan_id
        FROM    msc_apps_instances mai,
                msc_system_items msi,
                msc_supplies s
        WHERE   msi.inventory_item_id = s.inventory_item_id
        AND     msi.plan_id = s.plan_id
        AND     msi.organization_id = s.organization_id
        and     msi.sr_instance_id = s.sr_instance_id
        and     mai.instance_id = s.sr_instance_id             -- xml fix
        and     mai.instance_type = 3                          -- xml fix
        AND     s.plan_id = arg_plan_id
        AND     s.release_errors is NULL
        and     s.load_type = 20
        and     s.order_type = 1
        and     s.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                s.last_updated_by)
        group by s.sr_instance_id, s.transaction_id,
                 nvl(s.implement_uom_code,msi.uom_code),
                 nvl(s.promised_date,s.need_by_date),
                 get_dock_date(s.sr_instance_id,
                              s.receiving_calendar,
                              s.intransit_calendar,
                              NVL(s.implement_date,
                                        s.new_schedule_date),
                        NVL(msi.postprocessing_lead_time, 0)),
                 s.disposition_id,s.po_line_id, s.order_number,s.plan_id;
      end if;

     forall a in 1..p_po_instance_id.count
        INSERT INTO msc_po_reschedule_interface
           (process_id,
            quantity,
            need_by_date,
            line_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            purchase_order_id,
            po_number,
            source_line_id,
            uom,
            SR_INSTANCE_ID,
            plan_id)
        VALUES (
            NULL,
            p_po_quantity(a),
            p_new_need_by_date(a),
            p_po_line_id(a),
            SYSDATE,
            p_user_id,
            SYSDATE,
            p_user_id,
            p_po_header_id(a),
            p_po_number(a),
            p_source_line_id(a),
            p_uom_code(a),
            p_po_instance_id(a),
            p_plan_id(a));

      commit;

     -- send xml
      for cur in leg_instance_cur loop

          v_temp :=0;

          select count(*)
          into v_temp
          from msc_po_reschedule_interface
          where sr_instance_id =  cur.sr_instance_id;

          if v_temp > 0 then
           arg_po_res_id.extend(1);
           arg_released_instance.extend(1);
           arg_po_res_count.extend(1);
           arg_po_pwb_count.extend(1);
           arg_count := arg_count+1;

           lv_sql_stmt :=
            ' BEGIN'
          ||' MSC_A2A_XML_WF.LEGACY_RELEASE (:p_arg_org_instance);'
          ||' END;';

           EXECUTE IMMEDIATE lv_sql_stmt USING  cur.sr_instance_id;

         arg_po_res_id(arg_count) := 0;
         arg_released_instance(arg_count) := cur.sr_instance_id;
         arg_po_res_count(arg_count) := v_temp;

         select count(*)
           into v_temp2
           from msc_supplies
           where   plan_id = arg_plan_id
           anD     release_errors is NULL
           and     load_type = 20
           and     order_type = 1
           and     sr_instance_id = cur.sr_instance_id
           and     last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                last_updated_by);

          arg_po_pwb_count(arg_count) := v_temp2;

         end if;
      end loop;

     exception
      when VALUE_ERROR then
          null;
      when COLLECTION_IS_NULL then
          null;
      when NO_DATA_FOUND then
          null;
     end;
   OPEN instance_cur;
   LOOP
   FETCH instance_cur INTO p_instance_id, p_dblink, p_dest_dblink,p_instance_code;
   EXIT WHEN instance_cur%NOTFOUND;
      v_temp :=0;
      select count(*)
       into v_temp
        from msc_purchase_order_interface
        where sr_instance_id = p_instance_id
          and batch_id = v_batch_id;
      if v_temp > 0 then
        arg_po_res_id.extend(1);
        arg_released_instance.extend(1);
        arg_po_res_count.extend(1);
        arg_po_pwb_count.extend(1);
        arg_count := arg_count+1;

        IF p_plan_type = 5 THEN
           begin
              lv_sql_stmt :=
                'BEGIN ' ||
                'MRP_PO_RESCHEDULE.LAUNCH_RESCHEDULE_PO'||p_dblink||
                '(:lv_user, :lv_resp, :v_batch_id,:p_instance_id,:p_instance_code,:p_dest_dblink, :arg_req_resched_id); ' ||
                'END;';
              EXECUTE IMMEDIATE lv_sql_stmt
                USING
                IN p_user_name,
                IN 'Advanced Supply Chain Planner',
                --IN p_resp_name,
                IN  v_batch_id,
                IN  p_instance_id,
                IN  p_instance_code,
                IN  p_dest_dblink,
                OUT p_request_id;
           EXCEPTION WHEN OTHERS THEN
              p_request_id := 0;
           END;
        ELSE
           begin
              lv_sql_stmt:=
                 'BEGIN'
                ||'  mrp_rel_wf.launch_po_program'||p_dblink||'('
                ||'   :lv_old_need_by_date,'
                ||'   :lv_new_need_by_date,'
                ||'   :lv_po_header_id,'
                ||'   :lv_po_line_id,'
                ||'   :lv_po_number,'
                ||'   :lv_user,'
                ||'   :lv_resp,'
                ||'   :lv_qty,'
                ||' :out);'
                ||' END;';
           EXECUTE IMMEDIATE lv_sql_stmt
                USING
                       IN null_date,
                       IN null_date,
                       IN v_batch_id,
                       IN p_instance_id,
                       IN p_dest_dblink,
                       IN p_user_name,
                       IN p_resp_name,
                       IN 1,
                       OUT p_request_id;
-- dbms_output.put_line(p_dest_dblink||','||p_instance_id||','||v_batch_id);
        exception when others then
           EXECUTE IMMEDIATE lv_sql_stmt
                USING
                       IN sysdate,
                       IN sysdate,
                       IN v_batch_id,
                       IN p_instance_id,
                       IN p_dest_dblink,
                       IN p_user_name,
                       IN p_resp_name,
                       IN 1,
                       OUT p_request_id;
        end;
        END IF;
        if p_request_id <> 0 then
           commit;
         end if;

         arg_po_res_id(arg_count) := p_request_id;
         arg_released_instance(arg_count) := p_instance_id;
         arg_po_res_count(arg_count) := v_temp;

         select count(*)
           into v_temp2
           from msc_supplies
          where plan_id = arg_plan_id
        AND     release_errors is NULL
        and     load_type = 20
        and     order_type = 1
        and     sr_instance_id = p_instance_id
        and     last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                last_updated_by);

        arg_po_pwb_count(arg_count) := v_temp2;

      end if;
   END LOOP;
   CLOSE instance_cur;

   /* for auto-release we do not want applied and status to be updated */

   SELECT release_reschedules
   INTO  v_autorelease
   FROM msc_plans
   WHERE plan_id=arg_plan_id;
   UPDATE MSC_SUPPLIES
     SET  implement_date = NULL,
          release_status = decode(sign(p_plan_type-100),1,
                                   decode(release_status,11,21,
                                                         12,22,
                                                         13,23),
                                   NULL),
          load_type = NULL,
          applied = decode(v_autorelease,1,applied,2),
          status = decode(v_autorelease,1,status,0)
     WHERE plan_id= arg_plan_id
        and release_errors is NULL
        and load_type = 20
        and order_type =1
        and last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                last_updated_by);

     commit;

END reschedule_purchase_orders;

PROCEDURE release_sales_orders
( arg_plan_id			IN      NUMBER
, arg_org_id 		IN 	NUMBER
, arg_instance              IN      NUMBER
, arg_owning_org 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_released_instance         IN OUT NOCOPY NumTblTyp
, arg_so_rel_id 		IN OUT NOCOPY NumTblTyp
, arg_so_rel_count              IN OUT NOCOPY NumTblTyp
, arg_so_pwb_count              IN OUT NOCOPY NumTblTyp) IS

  -- p_user_id number := FND_PROFILE.value('USER_ID');
  p_user_id number := FND_GLOBAL.USER_ID;
  p_resp_id number := FND_GLOBAL.RESP_ID;
  p_release_by_user varchar2(3) :=
                      nvl(FND_PROFILE.value('MSC_RELEASED_BY_USER_ONLY'),'N');

   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE DateTab  IS TABLE OF Date INDEX BY BINARY_INTEGER;
   TYPE CharTab  IS TABLE OF varchar2(240) INDEX BY BINARY_INTEGER;

  p_earliest_ship_date DateTab;
  p_ship_date DateTab;
  p_arrival_date datetab;
  p_ship_method CharTab;
  p_lead_time numTab;
  p_operating_unit NumTab;
  p_so_line_id NumTab;
  p_so_org_id NumTab;
  p_so_instance_id NumTab;
  p_instance_id NumTab;
  p_so_header_id NumTab;
  p_demand_id NumTab;
  p_order_number CharTab;
  p_source_type NumTab;
  p_orig_ship_date DateTab;
  p_orig_arrival_date datetab;
  p_orig_ship_method CharTab;
  p_orig_lead_time numTab;
  p_orig_org_id NumTab;
  p_qty NumTab;
  p_implement_firm NumTab;
  p_original_item_id NumTab;
  p_substitute_item_id NumTab;
  p_org_id NumTab;
  a number;

  CURSOR instance_cur IS
   select  distinct mp.sr_instance_id,
           decode(mai.M2A_dblink,null,' ','@'||mai.M2A_dblink),
           decode(mai.A2M_dblink,null,' ','@'||mai.A2M_dblink)
   from    msc_plan_organizations mp,
           msc_apps_instances mai
   where   plan_id = arg_plan_id
     and   mp.sr_instance_id = mai.instance_id
--     and   mai.instance_type <> 3    -- xml fix
     and   nvl(mai.apps_ver,1) <> 1; -- not back port to 107 yet

    -- p_user_name varchar2(30) :=FND_PROFILE.VALUE('USERNAME');
    p_user_name varchar2(80) :=FND_GLOBAL.USER_NAME;
    p_resp_name varchar2(80) :=FND_GLOBAL.RESP_NAME;
    p_dblink varchar2(128);
    p_aps_dblink varchar2(128);
    p_inst_id number;
    lv_sql_stmt varchar2(2000);
    p_request_id number:=0;
    v_batch_id number;
    v_temp number;
    v_temp2 number;
    crm_char varchar2(100);
    TYPE CRMCurTyp IS REF CURSOR;
    crm_cur CRMCurTyp;
    p_count number;
    v_item_id number;
    p_timestamp number:=1439/1440;  --- (1-1/(24*60))

    CURSOR source_item_c(l_inst_id number, l_org_id number,
                         l_item_id number) IS
      select sr_inventory_item_id
        from msc_system_items msi
       where msi.plan_id = arg_plan_id
      and msi.organization_id =l_org_id
      and msi.sr_instance_id = l_inst_id
      and msi.inventory_item_id = l_item_id;

 CURSOR c_plan_type(p_plan_id number) IS
     select plan_type
       from msc_plans a
       where
       plan_id = p_plan_id;
p_plan_type NUMBER;
BEGIN
   OPEN c_plan_type(arg_plan_id);
     FETCH c_plan_type INTO p_plan_type;
     CLOSE c_plan_type;
     p_count :=0;

     begin
       if (p_plan_type >100) then   -- this is rp plans
	     SELECT  md.sr_instance_id,
                NVL(md.sales_order_line_id,0),
                md.implement_org_id,
                md.implement_instance_id,
                trunc(md.implement_earliest_date) + p_timestamp,  -- Earliest ship date
                trunc(md.implement_ship_date)+p_timestamp,
                trunc(nvl(md.implement_arrival_date,md.schedule_ship_date)) +p_timestamp,
                mtp.operating_unit,
                md.demand_id,
                md.ship_method,
                NVL(md.intransit_lead_time,0),
                nvl(md.implement_firm,2),
                NVL(nvl(md.prev_subst_org,md.original_org_id),
                        md.organization_id),
                trunc(md.schedule_arrival_date) + p_timestamp,
                trunc(md.schedule_ship_date)+p_timestamp,
                md.orig_shipping_method_code,
                NVL(md.orig_intransit_lead_time,0),
                md.order_number,
                decode(md.customer_id, null, 100, to_number(null)),
                decode(md.customer_id, null,
                       nvl(md.quantity_by_due_date,
                           md.using_requirement_quantity),
                       md.using_requirement_quantity),
                nvl(nvl(md.prev_subst_item,md.original_item_id),
                        md.inventory_item_id),
                md.inventory_item_id,
                md.organization_id
          BULK COLLECT INTO
                p_instance_id,
                p_so_line_id,
                p_so_org_id,
                p_so_instance_id,
                p_earliest_ship_date,
                p_ship_date,
                p_arrival_date,
                p_operating_unit,
                p_demand_id,
                p_ship_method,
                p_lead_time,
                p_implement_firm,
                p_orig_org_id,
                p_orig_arrival_date,
                p_orig_ship_date,
                p_orig_ship_method,
                p_orig_lead_time,
                p_order_number,
                p_source_type,
                p_qty,
                p_original_item_id,
                p_substitute_item_id,
                p_org_id
       FROM     msc_demands md,
                msc_trading_partners mtp
      WHERE     md.plan_id = arg_plan_id
        AND     md.release_errors is NULL
        and     md.load_type = 30
        and     md.origination_type = 30
        and     md.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                md.last_updated_by)
        AND     mtp.sr_tp_id = md.organization_id
        AND     mtp.sr_instance_id = md.sr_instance_id
        AND     mtp.partner_type= 3
        order by mtp.operating_unit, md.order_number, md.arrival_set_id,md.ship_set_id;

     else

             SELECT  md.sr_instance_id,
                NVL(md.sales_order_line_id,0),
                md.implement_org_id,
                md.implement_instance_id,
                md.implement_earliest_date,  -- Earliest ship date
                md.implement_ship_date,
                nvl(md.implement_arrival_date,md.schedule_ship_date),
                mtp.operating_unit,
                md.demand_id,
                md.ship_method,
                NVL(md.intransit_lead_time,0),
                nvl(md.implement_firm,2),
                NVL(nvl(md.prev_subst_org,md.original_org_id),
                        md.organization_id),
                md.schedule_arrival_date,
                md.schedule_ship_date,
                md.orig_shipping_method_code,
                NVL(md.orig_intransit_lead_time,0),
                md.order_number,
                decode(md.customer_id, null, 100, to_number(null)),
                decode(md.customer_id, null,
                       nvl(md.quantity_by_due_date,
                           md.using_requirement_quantity),
                       md.using_requirement_quantity),
                nvl(nvl(md.prev_subst_item,md.original_item_id),
                        md.inventory_item_id),
                md.inventory_item_id,
                md.organization_id
        BULK COLLECT INTO
                p_instance_id,
                p_so_line_id,
                p_so_org_id,
                p_so_instance_id,
                p_earliest_ship_date,
                p_ship_date,
                p_arrival_date,
                p_operating_unit,
                p_demand_id,
                p_ship_method,
                p_lead_time,
                p_implement_firm,
                p_orig_org_id,
                p_orig_arrival_date,
                p_orig_ship_date,
                p_orig_ship_method,
                p_orig_lead_time,
                p_order_number,
                p_source_type,
                p_qty,
                p_original_item_id,
                p_substitute_item_id,
                p_org_id
       FROM     msc_demands md,
                msc_trading_partners mtp
      WHERE     md.plan_id = arg_plan_id
        AND     md.release_errors is NULL
        and     md.load_type = 30
        and     md.origination_type = 30
        and     md.last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                md.last_updated_by)
        AND     mtp.sr_tp_id = md.organization_id
        AND     mtp.sr_instance_id = md.sr_instance_id
        AND     mtp.partner_type= 3
       order by mtp.operating_unit, md.order_number, md.arrival_set_id,md.ship_set_id;
     end if;
   select msc_form_query_s.nextval
      into v_batch_id
      from dual;

     for a in 1..p_so_instance_id.count loop

        v_item_id := p_substitute_item_id(a);
        OPEN source_item_c(p_instance_id(a), p_org_id(a),v_item_id);
        FETCH source_item_c INTO p_substitute_item_id(a);
        CLOSE source_item_c;

        IF p_original_item_id(a) <> v_item_id THEN
           v_item_id := p_original_item_id(a);
           OPEN source_item_c(p_instance_id(a), p_orig_org_id(a),v_item_id);
           FETCH source_item_c INTO p_original_item_id(a);
           CLOSE source_item_c;
        ELSE
           p_original_item_id(a) := p_substitute_item_id(a);
        END IF;

        insert into msc_sales_order_interface
           (last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            batch_id,
            sr_instance_id,
            line_id,
            operating_unit,
            header_id,
            org_id,
            schedule_ship_date,
            schedule_arrival_date,
            earliest_ship_date,
            delivery_lead_time,
            ship_method,
            orig_org_id,
            orig_schedule_ship_date,
            orig_schedule_arrival_date,
            orig_lead_time,
            orig_ship_method,
            quantity,
            firm_flag,
            source_type,
            order_number,
            demand_id,
            plan_id,
            orig_item_id,
            inventory_item_id)
        values
            (sysdate,
             p_user_id,
             sysdate,
             p_user_id,
             v_batch_id,
             p_instance_id(a),
             p_so_line_id(a),
             p_operating_unit(a),
             null, -- so_header_id: we don't hv this in destination
             p_so_org_id(a),
             p_ship_date(a),
             p_arrival_date(a),
             p_earliest_ship_date(a),
             p_lead_time(a),
             p_ship_method(a),
             p_orig_org_id(a),
             p_orig_ship_date(a),
             p_orig_arrival_date(a),
             p_orig_lead_time(a),
             p_orig_ship_method(a),
             p_qty(a),
             p_implement_firm(a),
             p_source_type(a),
             p_order_number(a),
             p_demand_id(a),
             arg_plan_id,
             p_original_item_id(a),
             p_substitute_item_id(a));

      end loop;

      commit;
     exception
      when VALUE_ERROR then
          null;
      when COLLECTION_IS_NULL then
          null;
      when NO_DATA_FOUND then
          null;
     end;

   OPEN instance_cur;
   LOOP
   FETCH instance_cur INTO p_inst_id, p_dblink, p_aps_dblink;
   EXIT WHEN instance_cur%NOTFOUND;
      v_temp :=0;
      select count(*)
       into v_temp
        from msc_sales_order_interface
        where sr_instance_id = p_inst_id
          and batch_id = v_batch_id;
      if v_temp > 0 then
        arg_so_rel_id.extend(1);
        arg_released_instance.extend(1);
        arg_so_rel_count.extend(1);
        arg_so_pwb_count.extend(1);
        p_count := p_count+1;

        begin
          -- customer_id could be null for reqular so,
          -- but order_number for CRMO always ends with 'CMRO'
          lv_sql_stmt:= 'select meaning from fnd_lookups'||p_dblink||
                        ' where lookup_type = :p_type '||
                        ' and lookup_code = :p_code ';

          OPEN crm_cur FOR lv_sql_stmt USING 'AHL_APS_APPLICATION', 'CMRO';
          FETCH crm_cur INTO crm_char;
          CLOSE crm_cur;

          -- if customer_id is null but order_number not ends with 'CMRO',
          -- it is not a CMRO
          UPDATE msc_sales_order_interface
             set source_type = null,
                 quantity = null
           where source_type =100  -- customer_id is null
             and order_number not like '%'||crm_char
             and sr_instance_id = p_inst_id
             and batch_id = v_batch_id;
          commit;

          lv_sql_stmt:=
            'BEGIN'
               ||'  mrp_rel_wf.launch_so_program'||p_dblink||'('
                                          ||'   :batch_id,'
                                          ||'   :db_link,'
                                          ||'   :instance_id,'
                                          ||'   :lv_user,'
                                          ||'   :lv_resp,'
                                          ||'   :out);'
                ||' END;';

           MSC_LOG.string ( FND_LOG.LEVEL_ERROR,
                            'msc_rel_wf.release_sales_orders',
                            'sql statement is : '||lv_sql_stmt);


           EXECUTE IMMEDIATE lv_sql_stmt
                USING
                       IN v_batch_id,
                       IN p_aps_dblink,
                       IN p_inst_id,
                       IN p_user_name,
                       IN p_resp_name,
                       OUT p_request_id;
        exception when others then
            raise;
        end;
         if p_request_id <> 0 then
           commit;
         end if;

         arg_so_rel_id(p_count) := p_request_id;
         arg_released_instance(p_count) := p_inst_id;
         arg_so_rel_count(p_count) := v_temp;

         v_temp2 :=0;

         select count(*)
           into v_temp2
           from msc_demands
           where   plan_id = arg_plan_id
           anD     release_errors is NULL
           and     load_type = 30
           and     sr_instance_id = p_inst_id
           and     last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                last_updated_by);

          arg_so_pwb_count(p_count) := v_temp2;

     end if; -- if v_temp >0 then
   END LOOP;
   CLOSE instance_cur;

   UPDATE MSC_DEMANDS
     SET  /* implement_date = NULL,
          implement_ship_date = NULL,
          implement_earliest_date = NULL,
          implement_arrival_date = NULL,
          implement_org_id = NULL,
          implement_instance_id = NULL,
          implement_firm = null, */
          release_status = decode(sign(p_plan_type-100),1,
                                   decode(release_status,11,21,
                                                         12,22,
                                                         13,23),
                                   NULL),
---       release_status = NULL,
          load_type = NULL,
          applied = 2,
          status =0
     WHERE plan_id= arg_plan_id
        and release_errors is NULL
        and last_updated_by = decode(p_release_by_user,'Y', p_user_id,
                last_updated_by)
        and load_type = 30;
     commit;

END release_sales_orders;

Function get_job_seq_from_source(p_instance_id number) RETURN number IS
  CURSOR db_cur IS
  select decode(M2A_dblink,null,' ','@'||M2A_dblink)
    from msc_apps_instances
   where instance_id = p_instance_id;

  db_link varchar2(128);
  seq_num number;
  TYPE JobCurTyp IS REF CURSOR;
  JobCur JobCurTyp;

  sql_stmt varchar2(200);
BEGIN
   OPEN db_cur;
   FETCH db_cur INTO db_link;
   CLOSE db_cur;

   sql_stmt := 'SELECT wip_job_number_s.nextval'||db_link||' from dual';

   OPEN JobCur FOR sql_stmt;
   FETCH JobCur INTO seq_num;
   CLOSE JobCur;

   return seq_num;

END get_job_seq_from_source;

FUNCTION  is_pjm_valid(p_org_id          NUMBER,
                       p_project_id      NUMBER,
                       p_task_id         NUMBER,
                       p_start_date      DATE,
                       p_completion_date DATE,
                       p_instance_id     NUMBER) RETURN NUMBER  IS

l_valid     varchar2(80):= 'S';
l_error     varchar2(1000) := NULL;


db_link varchar2(128);

sql_stmt varchar2(500);


BEGIN
    msc_rel_wf.validate_proj_in_source( p_org_id,
                                        p_project_id,
                                        p_task_id,
                                        p_start_date,
                                        null, -- no date for completion date
                                        p_instance_id,
                                        l_valid,
                                        l_error);



  IF l_valid = 'S'  then
      return  1;
   ELSE
      return  0;
   END IF;

END  is_pjm_valid;




-- cnazarma
PROCEDURE validate_proj_in_source(
                                  p_org_id          NUMBER,
                                  p_project_id      NUMBER,
                                  p_task_id         NUMBER,
                                  p_start_date      DATE,
                                  p_completion_date DATE,
                                  p_instance_id     NUMBER,
                                  p_valid           OUT NOCOPY VARCHAR2,
                                  p_error           OUT NOCOPY VARCHAR2)  IS



  --l_user_name varchar2(30) :=FND_PROFILE.VALUE('USERNAME');
  l_user_name varchar2(30) := FND_GLOBAL.USER_NAME;


CURSOR db_cur IS
select decode(M2A_dblink,null,' ','@'||M2A_dblink),
apps_ver
from msc_apps_instances
where instance_id = p_instance_id;

db_link varchar2(128);
apps_version number;

sql_stmt varchar2(500);
v_valid VARCHAR2(80);

l_user_id number := FND_GLOBAL.USER_ID;
l_resp_id number := FND_GLOBAL.RESP_ID;
l_application_id number;

BEGIN



   OPEN db_cur;
   FETCH db_cur INTO db_link, apps_version;
   CLOSE db_cur;

 -- remember the initial context
 -- because validate_pjm will change the context to PJM oper unit
        SELECT APPLICATION_ID
        INTO l_application_id
        FROM FND_APPLICATION_VL
       WHERE APPLICATION_SHORT_NAME = 'MSC'
         and rownum =1 ;

-- calling validate_pjm for 11.5 sources only
 if apps_version > 2 then
  sql_stmt :=
   'BEGIN        mrp_rel_wf.validate_pjm'||db_link||
                               '( :p_org,'||
                               '  :p_project_id,'||
                               '  :p_task_id,' ||
                               '  :p_start_date,'||
                               '  :p_completion_date,' ||
                               '  :p_user_name,'||
                               '  :p_valid,'||
                               '  :p_error ); END; ';
   EXECUTE IMMEDIATE sql_stmt USING
                             IN p_org_id,
                             IN p_project_id,
                             IN p_task_Id,
                             IN p_start_date,
                             IN p_completion_date,
                             IN l_user_name,
                             IN OUT  p_valid,
                             IN OUT  p_error;

else
       p_valid := 'S';
 end if;

  -- initialize context back to what it was initially
    fnd_global.apps_initialize(l_user_id, l_resp_id, l_application_id);


exception when others then
raise;

END  validate_proj_in_source;


FUNCTION get_acc_class_from_source(p_org_id number, p_item_id number,
             p_project_id number, p_instance_id number) RETURN varchar2 IS
  CURSOR db_cur IS
  select decode(M2A_dblink,null,' ','@'||M2A_dblink),apps_ver

    from msc_apps_instances
   where instance_id = p_instance_id;

  db_link varchar2(128);

v_err_mesg1 VARCHAR2(200);
v_err_class1 VARCHAR2(200);
v_err_mesg2 VARCHAR2(200);
v_err_class2 VARCHAR2(200);
v_default_acc_class varchar2(200);
sql_stmt varchar2(500);
v_apps_ver number;
BEGIN

   OPEN db_cur;
   FETCH db_cur INTO db_link,v_apps_ver;
   CLOSE db_cur;

IF  v_apps_ver <> 1 THEN
  sql_stmt :=
   'BEGIN :v_class := wip_common.default_acc_class'||db_link||
                               '( :p_org, :p_item, 1, :p_project,' ||
                                ' :p_err_msg_1, :p_err_class_1,' ||
                                ' :p_err_msg_2, :p_err_class_2); END; ';

  EXECUTE IMMEDIATE sql_stmt USING
                             OUT v_default_acc_class,
                             IN p_org_id,
                             IN p_item_id,
                             IN p_project_Id,
                             OUT v_err_mesg1,
                             OUT v_err_class1,
                             OUT v_err_mesg2,
                             OUT v_err_class2;
 ELSE
     sql_stmt := 'SELECT DEFAULT_DISCRETE_CLASS
                 FROM   WIP_PARAMETERS'||db_link||
                 ' WHERE  ORGANIZATION_ID = :p_org_id';

    EXECUTE IMMEDIATE sql_stmt INTO v_default_acc_class USING p_org_id ;
  END IF;

    return v_default_acc_class;
exception when others then
    return null;
END get_acc_class_from_source;

Function is_source_db_up(p_instance_id number) RETURN boolean IS
  CURSOR db_cur IS
  select decode(M2A_dblink,null,' ','@'||M2A_dblink)
    from msc_apps_instances
   where instance_id = p_instance_id;

  db_link varchar2(128);
  seq_num number;
  TYPE JobCurTyp IS REF CURSOR;
  JobCur JobCurTyp;

  sql_stmt varchar2(200);
BEGIN
   OPEN db_cur;
   FETCH db_cur INTO db_link;
   CLOSE db_cur;

   sql_stmt := 'SELECT 1 from dual'||db_link;

   OPEN JobCur FOR sql_stmt;
   FETCH JobCur INTO seq_num;
   CLOSE JobCur;

   return true;
exception when others then
   return false;

END is_source_db_up;

Procedure get_load_type(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 )  IS
  p_load_type number;
BEGIN
  if (funcmode = 'RUN') then
      p_load_type :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOAD_TYPE');
      if p_load_type = PURCHASE_ORDER_RESCHEDULE then
         resultout := 'COMPLETE:PO';
      elsif p_load_type = PURCHASE_REQ_RESCHEDULE then
         resultout := 'COMPLETE:REQ';
/*
      elsif p_load_type = WIP_DIS_MASS_LOAD then
         resultout := 'COMPLETE:LOAD_JOB';
      elsif p_load_type = WIP_REP_MASS_LOAD then
         resultout := 'COMPLETE:LOAD_REP';
      elsif p_load_type = WIP_DIS_MASS_RESCHEDULE then
         resultout := 'COMPLETE:RES_JOB';
      elsif p_load_type = PURCHASE_REQ_MASS_LOAD then
         resultout := 'COMPLETE:LOAD_REQ';
      elsif p_load_type = LOT_BASED_JOB_LOAD then
         resultout := 'COMPLETE:LOAD_LOT';
      elsif p_load_type = LOT_BASED_JOB_RESCHEDULE then
         resultout := 'COMPLETE:RES_LOT';
*/
      end if;
  end if;
  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
  end if;
END get_load_type;

Procedure start_release_batch_wf(p_plan_id number,
                              p_org_id number,
                              p_instance_id number,
                              p_owning_org number,
                              p_owning_instance number,
                              p_dblink varchar2,
                              p_load_type number,
                              p_instance_code varchar2) IS

  p_item_key varchar2(50) := to_char(p_plan_id)||'-'||
                                    to_char(p_org_id) ||'-'||
                                    to_char(p_instance_id)||'-'||
                                    to_char(p_load_type);
   p_process varchar2(30);

BEGIN
    deleteActivities(p_item_key);

    if p_dblink is not null then
      deleteActivities(p_item_key,p_dblink);
    end if;

    p_process := 'BATCH_UPDATE';

    wf_engine.CreateProcess( itemtype => g_item_type,
                             itemkey  => p_item_key,
                             process  => p_process);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'PLAN_ID',
                                 avalue   => p_plan_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'ORG_ID',
                                 avalue   => p_org_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'SR_INSTANCE_ID',
                                 avalue   => p_instance_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'OWNING_ORG_ID',
                                 avalue   => p_owning_org);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'OWNING_INSTANCE_ID',
                                 avalue   => p_instance_id);
    wf_engine.SetItemAttrNumber( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'LOAD_TYPE',
                                 avalue   => p_load_type);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'DBLINK',
                                 avalue   => p_dblink);
    wf_engine.SetItemAttrText( itemtype => g_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'INSTANCE_CODE',
                                 avalue   => p_instance_code);

--dbms_output.put_line('item_key='||p_item_key);
    wf_engine.StartProcess( itemtype => g_item_type,
                          itemkey  => p_item_key);

    update msc_supplies
              SET implement_demand_class = NULL,
                  implement_date = NULL,
                  implement_quantity = NULL,
                  implement_firm = NULL,
                  implement_wip_class_code = NULL,
                  implement_job_name = NULL,
                  implement_status_code = NULL,
                  implement_location_id = NULL,
                  implement_source_org_id = NULL,
                  implement_supplier_id = NULL,
                  implement_supplier_site_id = NULL,
                  implement_project_id = NULL,
                  implement_task_id = NULL,
                  release_status = NULL,
                  load_type = NULL,
                  implement_as = NULL,
                  implement_unit_number = NULL,
                  implement_schedule_group_id = NULL,
                  implement_build_sequence = NULL,
                  implement_line_id = NULL,
                  implement_alternate_bom = NULL,
                  implement_alternate_routing = NULL
            WHERE organization_id IN
                    (select planned_organization
                     from msc_plan_organizations_v
                     where organization_id = p_owning_org
                     and  owning_sr_instance = p_owning_instance
                     and plan_id = p_plan_id
                     AND planned_organization = decode(p_org_id,
                                       p_owning_org, planned_organization,
               			       p_org_id)
                     AND sr_instance_id = p_instance_id )
              AND sr_instance_id= p_instance_id
              AND plan_id =  p_plan_id
	      AND release_errors IS NULL
              AND load_type = p_load_type;

exception when others then
   raise;
END start_release_batch_wf;

Procedure insert_temp_table(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 )  IS
  p_plan_id number;
  p_org_id number;
  p_instance_id number;
  p_owning_org number;
  p_owning_instance number;
  p_load_type number;
  p_count number :=0;
  p_apps_ver varchar2(10);
  p_wip_group_id number;
  p_po_group_by number;
  p_po_batch_number number;
  p_instance_code varchar2(10);

  cursor apps_ver_cur IS
    select apps_ver
      from msc_apps_instances
     where instance_id = p_instance_id;
BEGIN
  if (funcmode = 'RUN') then
      p_load_type :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOAD_TYPE');
      p_plan_id :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_ID');
      p_org_id :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORG_ID');
      p_instance_id :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SR_INSTANCE_ID');
      p_owning_org :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'OWNING_ORG_ID');
      p_owning_instance :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'OWNING_INSTANCE_ID');
        open apps_ver_cur;
         fetch apps_ver_cur into p_apps_ver;
         close apps_ver_cur;

     msc_util.msc_debug('insert temp table now');
     msc_util.msc_debug('load type='||p_load_type);
     msc_util.msc_debug('org id='||p_org_id);
     msc_util.msc_debug('instance id='||p_instance_id);
     msc_util.msc_debug('owning org id='||p_owning_org);
     msc_util.msc_debug('owning instance id='||p_owning_instance);

      if p_load_type = WIP_DIS_MASS_LOAD then

         p_count := msc_rel_plan_pub.load_wip_discrete_jobs(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_wip_group_id,
                    null,
                    null,
                    p_apps_ver);

      elsif p_load_type = WIP_REP_MASS_LOAD then
         p_count := msc_rel_plan_pub.load_repetitive_schedules(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_wip_group_id,
                    null,
                    null);

      elsif p_load_type = WIP_DIS_MASS_RESCHEDULE then
        p_count := msc_rel_plan_pub.reschedule_wip_discrete_jobs(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_wip_group_id,
                    null,
                    null,
                    p_apps_ver,
                    p_load_type);
      elsif p_load_type = PURCHASE_REQ_MASS_LOAD then

           --fix for the bug#2539212
        get_profile_value(p_profile_name   => 'MRP_LOAD_REQ_GROUP_BY',
                          p_instance_id    => p_instance_id,
                          p_calling_source => 'PACKAGE',
                          p_profile_value  => p_po_group_by);

        p_count := msc_rel_plan_pub.load_po_requisitions(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_po_group_by,
                    p_po_batch_number,
                    null,
                    null);
      elsif p_load_type = LOT_BASED_JOB_LOAD then
        p_count := msc_rel_plan_pub.load_osfm_lot_jobs(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_wip_group_id,
                    null,
                    null,
                    p_apps_ver);
      elsif p_load_type = LOT_BASED_JOB_RESCHEDULE then
        p_count := msc_rel_plan_pub.reschedule_osfm_lot_jobs(
                    p_plan_id,
                    p_org_id,
                    p_instance_id,
                    p_owning_org,
                    p_owning_instance,
                    fnd_global.user_id,
                    p_wip_group_id,
                    null,
                    null);
      end if;
      if p_count >0 then
        msc_util.msc_debug('# of rows updated:'|| p_count);
        resultout := 'COMPLETE:FOUND';
      else
        msc_util.msc_debug('no rows are inserted');
        resultout := 'COMPLETE:NOT_FOUND';
      end if;
  end if;
  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
  end if;
END insert_temp_table;

Procedure start_source_program(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 )  IS
  p_load_type number;
  p_instance number;
  p_request_id number;
  p_dblink varchar2(128);
  p_po_group_by number;
  po_group_by_name varchar2(20);
  lv_sql_stmt varchar2(2000);
  p_instance_code varchar2(10);
Begin
  if (funcmode = 'RUN') then
      p_load_type :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOAD_TYPE');
      p_instance :=
      wf_engine.GetItemAttrNUMBER( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SR_INSTANCE_ID');
      p_instance_code :=
      wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'INSTANCE_CODE');
      p_dblink :=
      wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DBLINK');

--commenting out the foll code as this procedure is not being used anywhere.
/*
      lv_sql_stmt:=
              'BEGIN'
               ||' MRP_AP_REL_PLAN_PUB.INITIALIZE'
               ||p_dblink
               ||'( :p_user, :p_resp, :p_app );'
            ||' END;';
           EXECUTE IMMEDIATE lv_sql_stmt
                USING FND_GLOBAL.USER_NAME,
                      FND_GLOBAL.RESP_NAME,
                      FND_GLOBAL.APPLICATION_NAME;

      msc_util.msc_debug('start reschedule in instance '||p_instance_code);
      if p_load_type in (WIP_DIS_MASS_LOAD,WIP_REP_MASS_LOAD,
                         WIP_DIS_MASS_RESCHEDULE) then

            lv_sql_stmt:=
              'BEGIN'
               ||' MRP_AP_REL_PLAN_PUB.LD_WIP_JOB_SCHEDULE_INTERFACE'
               ||p_dblink
               ||'( :arg_wip_req_id );'
            ||' END;';

           EXECUTE IMMEDIATE lv_sql_stmt
                USING OUT p_request_id;

           DELETE msc_wip_job_schedule_interface
               WHERE sr_instance_id= p_instance;

           DELETE MSC_WIP_JOB_DTLS_INTERFACE
               WHERE sr_instance_id= p_instance;

      elsif p_load_type in (LOT_BASED_JOB_LOAD,LOT_BASED_JOB_RESCHEDULE) then
            lv_sql_stmt:=
              'BEGIN'
               ||' MRP_AP_REL_PLAN_PUB.LD_LOT_JOB_SCHEDULE_INTERFACE'
               ||p_dblink
               ||'( :arg_wip_req_id );'
            ||' END;';

           EXECUTE IMMEDIATE lv_sql_stmt
                USING OUT p_request_id;

           DELETE msc_wip_job_schedule_interface
               WHERE sr_instance_id= p_instance;

           DELETE MSC_WIP_JOB_DTLS_INTERFACE
               WHERE sr_instance_id= p_instance;
     elsif p_load_type = PURCHASE_REQ_MASS_LOAD then
        IF p_po_group_by = 1 THEN
          po_group_by_name := 'ALL';
        ELSIF p_po_group_by = 2 THEN
          po_group_by_name := 'ITEM';
        ELSIF p_po_group_by = 3 THEN
          po_group_by_name := 'BUYER';
        ELSIF p_po_group_by = 4 THEN
          po_group_by_name := 'PLANNER';
        ELSIF p_po_group_by = 5 THEN
          po_group_by_name := 'VENDOR';
        ELSIF p_po_group_by = 6 THEN
          po_group_by_name := 'ONE-EACH';
        ELSIF p_po_group_by = 7 THEN
          po_group_by_name := 'CATEGORY';
        END IF;

        lv_sql_stmt:=
           'BEGIN'
         ||' MRP_AP_REL_PLAN_PUB.LD_PO_REQUISITIONS_INTERFACE'||p_dblink
                  ||'( :po_group_by_name,'
                  ||'  :arg_req_load_id );'
         ||' END;';

         EXECUTE IMMEDIATE lv_sql_stmt
                 USING  IN po_group_by_name,
                       OUT p_request_id;

        DELETE MSC_PO_REQUISITIONS_INTERFACE
         WHERE sr_instance_id= p_instance;

      end if;

      msc_util.msc_debug('request id is '||p_request_id
                       ||', in instance '||p_instance_code);

      wf_engine.SetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUEST_ID',
                             avalue   => p_request_id);
      commit;
      */
  end if;
  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
  end if;
END start_source_program;

Procedure get_supply_data(p_plan_id in number,
                      p_transaction_id in number,
                      p_query_id in number,
                      p_dblink in varchar2) IS
   cursor supply_cur IS
     select msc_get_name.org_code(s.organization_id,s.sr_instance_id),
            msc_get_name.supplier(s.supplier_id),
            msc_get_name.supplier_site(s.supplier_site_id),
            msc_get_name.lookup_meaning('MRP_ORDER_TYPE',s.order_type),
            DECODE(s.order_type,5,to_char(s.transaction_id),s.order_number),
            s.new_schedule_date,
            s.new_order_quantity,
            mp.compile_designator,
            msi.item_name,
            msi.buyer_name,
            decode(s.order_type, 1, s.disposition_id, null),
            s.po_line_id,
            s.implement_quantity,
            cal2.calendar_date
       from msc_supplies s,
            msc_system_items msi,
            msc_plans mp,
            msc_calendar_dates cal1,
            msc_calendar_dates cal2,
            msc_trading_partners mtp
      where s.plan_id = p_plan_id
        and s.transaction_id =p_transaction_id
        and s.plan_id = mp.plan_id
        and s.plan_id = msi.plan_id
        and s.organization_id = msi.organization_id
        and s.sr_instance_id = msi.sr_instance_id
        and s.inventory_item_id = msi.inventory_item_id
        and cal1.sr_instance_id = mtp.sr_instance_id
        AND cal1.calendar_code = mtp.calendar_code
        AND cal1.exception_set_id = mtp.calendar_exception_set_id
        AND cal1.calendar_date = trunc(NVL(s.implement_date,s.new_schedule_date))
        AND cal2.sr_instance_id = cal1.sr_instance_id
        AND cal2.calendar_code = cal1.calendar_code
        AND cal2.exception_set_id = cal1.exception_set_id
        AND cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -
                  NVL(msi.postprocessing_lead_time, 0))
        AND mtp.sr_tp_id = msi.organization_id
        AND mtp.sr_instance_id = msi.sr_instance_id
        AND mtp.partner_type= 3;

   CURSOR need_by_date_cur IS
    SELECT new_dock_date
      FROM msc_supplies
     WHERE plan_id = -1
       AND transaction_id = p_transaction_id;

   l_plan_name varchar2(20);
   l_item_name varchar2(40);
   l_org_code varchar2(20);
   l_supplier varchar2(80);
   l_supplier_site varchar2(15);
   l_order varchar2(80);
   l_order_type varchar2(80);
   l_buyer varchar2(80);
   l_old_need_by_date date;
   l_new_need_by_date date;
   l_new_due_date date;
   l_qty number;
   l_impl_qty number;
   l_po_header_id number;
   l_po_line_id number;

   lv_sql_stmt varchar2(3000);
BEGIN
    OPEN supply_cur;
    FETCH supply_cur INTO l_org_code,
                          l_supplier,
                          l_supplier_site,
                          l_order_type,
                          l_order,
                          l_new_due_date,
                          l_qty,
                          l_plan_name,
                          l_item_name,
                          l_buyer,
                          l_po_header_id,
                          l_po_line_id,
                          l_impl_qty,
                          l_new_need_by_date;
    CLOSE supply_cur;

    OPEN need_by_date_cur;
    FETCH need_by_date_cur INTO l_old_need_by_date;
    CLOSE need_by_date_cur;

    lv_sql_stmt:=
     'insert into mrp_form_query'||p_dblink||
     ' (query_id,'||
      ' last_update_date,'||
      ' last_updated_by,'||
      ' creation_date,'||
      ' created_by,'||
      ' char1,'||
      ' char2,'||
      ' char3,'||
      ' char4,'||
      ' char5,'||
      ' char6,'||
      ' char7,'||
      ' char8,'||
      ' date1,'||
      ' date2,'||
      ' date3,'||
      ' number1,'||
      ' number2,'||
      ' number3,'||
      ' number4)'||
      ' VALUES('||
      ' :p_query_id,'||
      ' sysdate,'||
      ' -1,'||
       ' sysdate,'||
       ' -1,'||
       ' :l_org_code,'||
       ' :l_supplier,'||
       ' :l_supplier_site,'||
       ' :l_order_type,'||
       ' :l_order,'||
       ' :l_plan_name,'||
       ' :l_item_name,'||
       ' :l_buyer,'||
       ' :l_new_due_date,'||
       ' :l_new_need_by_date,'||
       ' :l_old_need_by_date,'||
       ' :l_qty,'||
       ' :l_impl_qty,'||
       ' :l_po_header_id,'||
       ' :l_po_line_id)';

     EXECUTE IMMEDIATE lv_sql_stmt
         USING p_query_id,
          l_org_code,
          l_supplier,
          l_supplier_site,
          l_order_type,
          l_order,
          l_plan_name,
          l_item_name,
          l_buyer,
          l_new_due_date,
          l_new_need_by_date,
          l_old_need_by_date,
          l_qty,
          l_impl_qty,
          l_po_header_id,
          l_po_line_id;

exception when others then
raise;
END get_supply_data;

PROCEDURE init_db(p_user_name varchar2) IS
    l_user_id number;
    l_resp_id number;
    l_application_id number;
BEGIN
     select user_id
       into l_user_id
       from fnd_user
      where user_name = p_user_name;

  begin
      SELECT APPLICATION_ID
        INTO l_application_id
        FROM FND_APPLICATION_VL
       WHERE APPLICATION_SHORT_NAME = 'MSC'
         and rownum =1 ;

      SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
          and rownum =1 ;

   exception when no_data_found then

     SELECT APPLICATION_ID
     INTO l_application_id
     FROM FND_APPLICATION_VL
     WHERE APPLICATION_SHORT_NAME = 'MRP'
     and rownum = 1;

      SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
          and rownum =1 ;
   end;

      fnd_global.apps_initialize(l_user_id, l_resp_id, l_application_id);
END init_db;

PROCEDURE close_dblink(p_dblink varchar2) IS
  lv_sql_stmt          VARCHAR2(2000);
  DBLINK_NOT_OPEN      EXCEPTION;
  PRAGMA               EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);

BEGIN
  IF p_dblink <> ' ' then
    -- mark distributed transaction boundary
    -- will need to do a manual clean up (commit) of the distributed
    -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
    commit;

    lv_sql_stmt := 'alter session close database link ' ||p_dblink;

    EXECUTE IMMEDIATE lv_sql_stmt;

  END IF;

EXCEPTION
  WHEN DBLINK_NOT_OPEN THEN
    NULL;
END close_dblink;


--This procedure is added to fix the issue#2539212
PROCEDURE get_profile_value(p_profile_name   IN   varchar2,
                            p_instance_id    IN   number,
                            p_calling_source IN   varchar2 default 'FORM',
                            p_profile_value  OUT  NOCOPY varchar2
                           ) IS
  lv_user_name         VARCHAR2(100):= NULL;
  lv_resp_name         VARCHAR2(100):= NULL;
  lv_application_name  VARCHAR2(240):= NULL;
  lv_appl_short_name   VARCHAR2(10):= NULL;
  lv_dblink            VARCHAR2(128);
  lv_dblink2            VARCHAR2(128);
  lv_sql_stmt          VARCHAR2(2000);

  cursor appl_short_name (p_appl_name IN VARCHAR2) IS
  select application_short_name
  from fnd_application_vl
  where application_name = p_appl_name;

 BEGIN

  SELECT DECODE( M2A_DBLINK, NULL, ' ', '@'||M2A_DBLINK),
         DECODE( M2A_DBLINK, NULL, ' ', M2A_DBLINK)
  INTO   lv_dblink, lv_dblink2
  FROM   msc_apps_instances
  WHERE  instance_id = p_instance_id;

  SELECT FND_GLOBAL.USER_NAME,
         FND_GLOBAL.RESP_NAME,
         FND_GLOBAL.APPLICATION_NAME
  INTO   lv_user_name,
         lv_resp_name,
         lv_application_name
  FROM   dual;

  open appl_short_name(lv_application_name);
  fetch appl_short_name into lv_appl_short_name;
  close appl_short_name;




  lv_sql_stmt:= 'SELECT mrp_rel_wf.get_profile_value'||lv_dblink||'('||
                ':1, :2, :3, :4) from dual';

  EXECUTE IMMEDIATE lv_sql_stmt
          INTO      p_profile_value
          USING     p_profile_name,
                    lv_user_name,
                    lv_resp_name,
                    lv_appl_short_name;

close_dblink(lv_dblink2);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    close_dblink(lv_dblink2);
    p_profile_value := NULL;

  WHEN others THEN
    IF p_calling_source = 'FORM' THEN
      fnd_message.set_name('MSC',sqlerrm);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
END get_profile_value;

FUNCTION get_offset_date(p_calendar_code in varchar2,
                         p_inst_id       in number,
                         p_lead_time     in number,
                         p_date          in date) return date is
  p_return_date date;

begin


  if P_calendar_code is null or p_calendar_code = MSC_CALENDAR.FOC then

    -- shipping/receiving calendar hierarchy [if no CRC, then 24x7]
    p_return_date := p_date + nvl(p_lead_time,0);

  else

    p_return_date := msc_calendar.date_offset
                     ( p_calendar_code
                     , p_inst_id
                     , p_date
                     , nvl(p_lead_time,0)
                     , null -- association_type
                     );

    -- msc_calendar.date_offset  will remove the timestamp
    if to_char(p_return_date,'HH24:MI:SS') = '00:00:00' and
       to_char(p_date,'HH24:MI:SS') <> '00:00:00' then
       p_return_date := to_date(to_char(p_return_date, 'MM/DD/RR')||' '||
                                to_char(p_date,'HH24:MI:SS'),
                                'MM/DD/RR HH24:MI:SS');

    end if;
  end if;
  return p_return_date;
end get_offset_date;

PROCEDURE update_so_dates(p_plan_id number, p_demand_id number,
                           p_inst_id number, p_implement_date date,
                           p_ship_date out nocopy date,
                           p_arrival_date out nocopy date,
                           p_earliest_date out nocopy date) IS

   TYPE NumArr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE DateArr  IS TABLE OF DATE INDEX BY BINARY_INTEGER;

   v_set_demand_id NumArr;
   v_lead_time NumArr;
   v_org_id NumArr;
   v_inst_id NumArr;
   v_ship_date DateArr;
   v_arrival_date DateArr;
   v_planned_ship_date DateArr;
   v_planned_arrival_date DateArr;
   v_earliest_date DateArr;
   v_request_date DateArr;
   v_schedule_date DateArr;
   v_vic_cal_code msc_calendars.calendar_code%type;
   v_association_type number;

   cursor so_c is
     select order_number,
            organization_id org_id,
            sr_instance_id inst_id,
            origination_type demand_type,
            ship_set_id, arrival_set_id,
            dmd_satisfied_date  earliest_ship_date,
            nvl(planned_ship_date,dmd_satisfied_date) planned_ship_date,
            planned_arrival_date,
            nvl(p_implement_date,nvl(firm_date, nvl(planned_ship_date,
                                     dmd_satisfied_date))) ship_date,
            order_date_type_code order_type,
            decode(order_date_type_code, 1, request_ship_date,
                    request_date) request_date,
            decode(order_date_type_code, 1, schedule_ship_date,
                    schedule_arrival_date) schedule_date,
            intransit_lead_time lead_time,
            inventory_item_id,
            ship_method,
            customer_id,
            customer_site_id
      from msc_demands
     where plan_id = p_plan_id
       and demand_id = p_demand_id
       and sr_instance_id = p_inst_id;

   so_rec so_c%ROWTYPE;

    -- release all lines in a ship/arrival set and use max date

   cursor ship_set(p_ship_set_id number) is
     select
            md.demand_id,
            md.dmd_satisfied_date, --earliest ship date,
            decode(md.demand_id, p_demand_id,
                 nvl(p_implement_date, --plan ship date
                    nvl(firm_date, nvl(md.planned_ship_date,
                                          md.dmd_satisfied_date))),
                 nvl(implement_date,
                    nvl(firm_date, nvl(md.planned_ship_date,
                                          md.dmd_satisfied_date)))),
            md.request_ship_date,
            md.schedule_ship_date,
            nvl(md.planned_ship_date,md.dmd_satisfied_date),
            md.planned_arrival_date,
            md.intransit_lead_time
      from msc_demands md,
           msc_system_items msi
     where md.plan_id = p_plan_id
       and md.ship_set_id = p_ship_set_id
       and msi.plan_id = md.plan_id
       and msi.organization_id = md.organization_id
       and msi.sr_instance_id = md.sr_instance_id
       and msi.inventory_item_id = md.inventory_item_id
       and nvl(msi.bom_item_type,4) <> 5; -- not a product family

   cursor arrival_set(p_arrival_set_id number) is
     select
            md.demand_id,
            md.dmd_satisfied_date, --earliest ship date
            decode(md.demand_id, p_demand_id, --plan ship date
                 nvl(p_implement_date,
                      nvl(firm_date, nvl(md.planned_ship_date,
                                            md.dmd_satisfied_date))),
                 nvl(implement_date,
                      nvl(firm_date, nvl(md.planned_ship_date,
                                            md.dmd_satisfied_date)))),
            md.request_date,
            md.schedule_arrival_date,
            md.intransit_lead_time,
            md.organization_id,
            md.sr_instance_id,
            nvl(md.planned_ship_date,md.dmd_satisfied_date),
            md.planned_arrival_date
      from msc_demands md,
           msc_system_items msi
     where md.plan_id = p_plan_id
       and md.arrival_set_id = p_arrival_set_id
       and msi.plan_id = md.plan_id
       and msi.organization_id = md.organization_id
       and msi.sr_instance_id = md.sr_instance_id
       and msi.inventory_item_id = md.inventory_item_id
       and nvl(msi.bom_item_type,4) <> 5; -- not a product family

   v_temp number;
   p_new_earliest_date date;

   CURSOR c_plan_type(p_plan_id number) IS
     select plan_type
       from msc_plans a
       where
       plan_id = p_plan_id;

  p_plan_type NUMBER;
BEGIN

   OPEN c_plan_type(p_plan_id);
   FETCH c_plan_type INTO p_plan_type;
   CLOSE c_plan_type;


   OPEN  so_c;
   FETCH so_c INTO so_rec;
   CLOSE so_c;

   begin
     v_vic_cal_code := msc_calendar.get_calendar_code
                      ( p_inst_id
                      , null
                      , null
                      , null
                      , null
                      , 4 -- partner type [in transit]
                      , null
                      , so_rec.ship_method
                      , MSC_CALENDAR.VIC
                      , v_association_type
                      );
    exception when others then
       v_vic_cal_code := null;
    end;

   if so_rec.ship_set_id is not null then
      OPEN ship_set(so_rec.ship_set_id);
      FETCH ship_set BULK COLLECT INTO
                                    v_set_demand_id, v_earliest_date,
                                    v_ship_date,
                                    v_request_date, v_schedule_date,
                                    v_planned_ship_date,
                                    v_planned_arrival_date, v_lead_time;
      CLOSE ship_set;

      for a in 1..v_set_demand_id.count loop

     -- find the max earliest ship date
        if a = 1 then
           p_earliest_date := v_earliest_date(a);
        else
           p_earliest_date := greatest(p_earliest_date,v_earliest_date(a));
        end if;

      v_ship_date(a) := verify_so_dates(v_schedule_date(a),
                                         v_request_date(a),v_ship_date(a));

        -- find the max ship date
        if a = 1 then
           p_ship_date := v_ship_date(a);
        else
           p_ship_date := greatest(p_ship_date,v_ship_date(a));
        end if;

      end loop;

   -- will use max date for the whole set

      for a in 1..v_set_demand_id.count loop
       if p_ship_date <> v_planned_ship_date(a) or
          v_planned_arrival_date(a) is null then
          -- recalculate arrival date
          v_planned_arrival_date(a) := get_offset_date ( v_vic_cal_code
                                                       , p_inst_id
                                                       , v_lead_time(a)
                                                       , p_ship_date);
       end if;

       if v_set_demand_id(a) <> p_demand_id then
          update msc_demands
          set implement_ship_date = p_ship_date, -- sche ship date
              implement_date = nvl(implement_date, nvl(firm_date,
                                   nvl(planned_ship_date,dmd_satisfied_date))),
              implement_earliest_date = p_earliest_date, -- earliest ship date
              implement_arrival_date = v_planned_arrival_date(a),
              implement_org_id = organization_id,
              implement_instance_id = sr_instance_id,
              implement_firm = nvl(implement_firm, org_firm_flag),
              load_type = 30,
              reschedule_flag = 1,
              release_status =  decode(sign(p_plan_type-100),1,13,1),
              --- for rp, 13= mark for release
              status = 0,
              applied =2,
              last_updated_by = fnd_global.user_id
         where plan_id = p_plan_id
           and demand_id = v_set_demand_id(a);
       else -- if v_set_demand_id(a) = p_demand_id then
           p_arrival_date :=  v_planned_arrival_date(a);
       end if;
      end loop;

   end if; -- end of if p_ship_set_id is not null then

   if so_rec.arrival_set_id is not null then
      OPEN arrival_set(so_rec.arrival_set_id);
      FETCH arrival_set BULK COLLECT INTO
                                    v_set_demand_id, v_earliest_date,
                                    v_ship_date,
                                    v_request_date, v_schedule_date,
                                    v_lead_time,
                                    v_org_id, v_inst_id,
                                    v_planned_ship_date,
                                    v_planned_arrival_date;
      CLOSE arrival_set;

      for a in 1..v_set_demand_id.count loop
        -- if user does not change implement_date(ie. = planned_ship_date)
        -- no need to recalculate arrival date, just use planned_arrival_date
        if v_ship_date(a) <> v_planned_ship_date(a) then
        -- offset sch_ship_date with lead time to get sch_arrival_date

           v_arrival_date(a) := get_offset_date
                                       ( v_vic_cal_code
                                       , v_inst_id(a)
                                       , v_lead_time(a)
                                       , v_ship_date(a)
                                       );
        else
           v_arrival_date(a) := v_planned_arrival_date(a);
        end if;
        -- find the max date for earliest_date
        if a = 1 then
           p_earliest_date := get_offset_date
                                       ( v_vic_cal_code
                                       , v_inst_id(a)
                                       , v_lead_time(a)
                                       , v_earliest_date(a)
                                       );
        else
           p_earliest_date := greatest(p_earliest_date,
                                 get_offset_date
                                       ( v_vic_cal_code
                                       , v_inst_id(a)
                                       , v_lead_time(a)
                                       , v_earliest_date(a)
                                       ));
        end if;

        v_arrival_date(a) := verify_so_dates(v_schedule_date(a),
                                             v_request_date(a),
                                             v_arrival_date(a));
        -- find the max date for schedule_arrival_date
        if a = 1 then
           p_arrival_date := v_arrival_date(a);
        else
           p_arrival_date := greatest(p_arrival_date,v_arrival_date(a));
        end if;

      end loop;

   -- will use max date for the whole set
      for a in 1..v_set_demand_id.count loop
         if p_arrival_date <> v_planned_arrival_date(a) then
         -- offset max(sch_arrival_date) with lead time to get sch_ship_date
            v_ship_date(a) := msc_rel_wf.get_offset_date
                             ( v_vic_cal_code
                             , v_inst_id(a)
                             , v_lead_time(a)*-1
                             , p_arrival_date);
          else
            v_ship_date(a) := v_planned_ship_date(a);

          end if;
          v_earliest_date(a) := msc_rel_wf.get_offset_date
                                ( v_vic_cal_code
                                , v_inst_id(a)
                                , v_lead_time(a)*-1
                                , p_earliest_date);
        if v_set_demand_id(a) <> p_demand_id then
          update msc_demands
          set implement_arrival_date = p_arrival_date,
              implement_earliest_date = v_earliest_date(a),
              implement_ship_date = v_ship_date(a), -- sche ship date
              implement_date = nvl(implement_date, nvl(firm_date,
                                   nvl(planned_ship_date,dmd_satisfied_date))),
              implement_org_id = organization_id,
              implement_instance_id = sr_instance_id,
              implement_firm = nvl(implement_firm, org_firm_flag),
              load_type = 30,
              reschedule_flag = 1,
              release_status = decode(sign(p_plan_type-100),1,13,1),
              status = 0,
              applied =2,
              last_updated_by = fnd_global.user_id
         where plan_id = p_plan_id
           and demand_id = v_set_demand_id(a);
        else -- if v_set_demand_id(a) = p_demand_id then
           p_ship_date := v_ship_date(a);
           p_new_earliest_date := v_earliest_date(a);
        end if;
      end loop;

      p_earliest_date := p_new_earliest_date;

   end if; -- end of if p_arrival_set_id is not null then

   if so_rec.ship_set_id is null and so_rec.arrival_set_id is null then
        if so_rec.order_type = 1 then -- ship
           p_earliest_date := so_rec.earliest_ship_date;
           p_ship_date := verify_so_dates(so_rec.schedule_date,
                                          so_rec.request_date,
                                          so_rec.ship_date);
           if p_ship_date <> so_rec.planned_ship_date then
              p_arrival_date := msc_rel_wf.get_offset_date
                              ( v_vic_cal_code
                              , so_rec.inst_id
                              , so_rec.lead_time
                              , p_ship_date);
           else
              p_arrival_date := so_rec.planned_arrival_date;
           end if;
        else -- arrival
           if so_rec.ship_date <> so_rec.planned_ship_date then
              p_arrival_date := msc_rel_wf.get_offset_date
                               ( v_vic_cal_code
                               , so_rec.inst_id
                               , so_rec.lead_time
                               , so_rec.ship_date);
           else
              p_arrival_date := so_rec.planned_arrival_date;
           end if;
           p_arrival_date := verify_so_dates(so_rec.schedule_date,
                                          so_rec.request_date,
                                          p_arrival_date);
           p_earliest_date := so_rec.earliest_ship_date;
           if p_arrival_date <> so_rec.planned_arrival_date then
              p_ship_date := msc_rel_wf.get_offset_date
                           ( v_vic_cal_code
                           , so_rec.inst_id
                           , so_rec.lead_time*-1
                           , p_arrival_date);
           else
              p_ship_date := so_rec.planned_ship_date;
           end if;

        end if;
    end if; --if so_rec.ship_set_id is null and so_rec.arrival_set_id is null
        update msc_demands
          set implement_earliest_date = p_earliest_date
        where plan_id = p_plan_id
           and demand_id = p_demand_id;

END update_so_dates;

PROCEDURE unrelease_so_set(p_plan_id number, p_demand_id number,
                           p_instance_id number) IS
    cursor set_id is
     select ship_set_id, arrival_set_id
       from msc_demands
      where plan_id = p_plan_id
        and demand_id = p_demand_id
        and sr_instance_id = p_instance_id;
    p_ship_set_id number;
    p_arrival_set_id number;
BEGIN
    OPEN set_id;
    FETCH set_id into p_ship_set_id, p_arrival_set_id;
    CLOSE set_id;

if p_ship_set_id is not null then
   UPDATE MSC_DEMANDS
     SET  implement_date = NULL,
          implement_ship_date = NULL,
          implement_earliest_date = NULL,
          implement_arrival_date = NULL,
          implement_org_id = NULL,
          implement_instance_id = NULL,
          implement_firm = null,
          release_status = NULL,
          reschedule_flag = null,
          load_type = NULL,
          applied = 2,
          status =0
     WHERE plan_id= p_plan_id
       AND origination_type = 30
       AND ship_set_id = p_ship_set_id
       AND demand_id <> p_demand_id;
end if;

if p_arrival_set_id is not null then
   UPDATE MSC_DEMANDS
     SET  implement_date = NULL,
          implement_ship_date = NULL,
          implement_earliest_date = NULL,
          implement_arrival_date = NULL,
          implement_org_id = NULL,
          implement_instance_id = NULL,
          implement_firm = null,
          reschedule_flag = null,
          release_status = NULL,
          load_type = NULL,
          applied = 2,
          status =0
     WHERE plan_id= p_plan_id
       AND origination_type = 30
       AND arrival_set_id = p_arrival_set_id
       AND demand_id <> p_demand_id;
end if;

END unrelease_so_set;

FUNCTION verify_so_release(p_plan_id number, p_demand_id number,
                           p_inst_id number)
         RETURN varchar2 IS

   TYPE NumArr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   v_subst_item NumArr;

   cursor so_c is
     select order_number,
            organization_id org_id,
            origination_type demand_type,
            ship_set_id, arrival_set_id,
            decode(nvl(prev_subst_item,0),
                inventory_item_id, 0,0,0,1) subst_item
      from msc_demands
     where plan_id = p_plan_id
       and demand_id = p_demand_id
       and sr_instance_id = p_inst_id;

   so_rec so_c%ROWTYPE;

   -- can not have multiple sources for one sales order
   cursor check_source(p_order_number varchar2,
                       p_order_type number,
                       p_org_id number) is
    select 1
      from msc_demands
     where plan_id = p_plan_id
       and order_number = p_order_number
       and origination_type = p_order_type
       and organization_id <> p_org_id
       and using_requirement_quantity <> 0;

   -- can not have multiple sources for ship set

   cursor check_ship_source(p_ship_set_id number,
                            p_org_id number)  is
    select 1
      from msc_demands
     where plan_id = p_plan_id
       and ship_set_id = p_ship_set_id
       and organization_id <> p_org_id ;

    -- release all lines in a ship/arrival set and use max date

   cursor ship_set(p_ship_set_id number) is
     select
            decode(nvl(original_item_id,0), inventory_item_id, 0,0,0,1)
      from msc_demands
     where plan_id = p_plan_id
       and ship_set_id = p_ship_set_id;

   cursor arrival_set(p_arrival_set_id number) is
     select
            decode(nvl(original_item_id,0), inventory_item_id, 0,0,0,1)
      from msc_demands
     where plan_id = p_plan_id
       and arrival_set_id = p_arrival_set_id;

   v_error_msg varchar2(80);
   v_temp number;
BEGIN

   OPEN  so_c;
   FETCH so_c INTO so_rec;
   CLOSE so_c;

/* GE enhancement, will allow release Sales Order with item substitution
   if so_rec.subst_item =1 then
      v_error_msg := 'MSC_REL_SO_SUBST_ITEM';
      return v_error_msg;
   end if;
*/
   v_temp :=0;
   OPEN check_source(so_rec.order_number, so_rec.demand_type,so_rec.org_id);
   FETCH check_source INTO v_temp;
   CLOSE check_source;

   if v_temp = 1 then
      v_error_msg := 'MSC_REL_SO_MULTI_SOURCES';
      return v_error_msg;
   end if;

   if so_rec.ship_set_id is not null then

      v_temp :=0;
      OPEN check_ship_source(so_rec.ship_set_id, so_rec.org_id);
      FETCH check_ship_source INTO v_temp;
      CLOSE check_ship_source;

      if v_temp = 1 then
         v_error_msg := 'MSC_REL_SHIP_SET_MULTI_SOURCES';
         return v_error_msg;
      end if;
/*
      OPEN ship_set(so_rec.ship_set_id);
      FETCH ship_set BULK COLLECT INTO v_subst_item;
      CLOSE ship_set;

      for a in 1..v_subst_item.count loop

        if v_subst_item(a) = 1 then
           v_error_msg := 'MSC_REL_SO_SUBST_ITEM_IN_A_SET';
           return v_error_msg;
        end if;

      end loop;
*/
   end if; -- end of if p_ship_set_id is not null then
/*
   if so_rec.arrival_set_id is not null then
      OPEN arrival_set(so_rec.arrival_set_id);
      FETCH arrival_set BULK COLLECT INTO v_subst_item;
      CLOSE arrival_set;

      for a in 1..v_subst_item.count loop

        if v_subst_item(a) = 1 then
           v_error_msg := 'MSC_REL_SO_SUBST_ITEM_IN_A_SET';
           return v_error_msg;
        end if;

      end loop;

   end if; -- end of if p_arrival_set_id is not null then
*/
   return v_error_msg;

END verify_so_release;

FUNCTION verify_so_dates(p_old_schedule_date date,
                         p_request_date date,
                         p_new_schedule_date date) RETURN date IS
  p_new_date date;
BEGIN
   -- if new schedule date >= old schedule date, new date = new schedule date
   -- else
   --   if old scheduld date < request date, new date = old schedule date
   --   else
   --       if new schedule date > request date, new date = new schedule date
   --       else new date = request date

   if p_old_schedule_date is null or p_request_date is null then
      return p_new_schedule_date;
   end if;
   if p_new_schedule_date >= p_old_schedule_date then
      return p_new_schedule_date;
   else -- if p_new_schedule_date < p_old_schedule_date then
      if p_old_schedule_date < p_request_date then
         return p_old_schedule_date;
      else -- if p_old_schedule_date >= p_request_date then
         if p_new_schedule_date > p_request_date then
            return p_new_schedule_date;
         else
            return p_request_date;
         end if;
      end if; -- if p_old_schedule_date < p_request_date then
   end if; -- if p_new_schedule_date >= p_old_schedule_date then

END verify_so_dates;

PROCEDURE so_release_workflow_program(p_batch_id in number,
                                    p_instance_id in number,
                                    p_planner in varchar2,
                                    p_request_id out nocopy number) IS
  p_result boolean;
begin
  msc_rel_wf.init_db(p_planner);
    p_result := fnd_request.set_mode(true);
      -- this will call msc_rel_wf.start_so_release_workflow

    p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCRLSOWF',
                         null,
                         null,
                         false,
                         p_batch_id,
                         p_instance_id);

exception when others then
 p_request_id :=0;
 raise;
end so_release_workflow_program;

PROCEDURE start_so_release_workflow(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_batch_id number,
p_instance_id number) IS

  l_process varchar2(50) := 'EXCEPTION_PROCESS3';
  item_type varchar2(50) :='MSCEXPWF';
  item_key varchar2(50);

  cursor all_c is
   select msi.item_name,
          md.order_number,
          msi.description item_desc,
          msc_get_name.customer(md.customer_id) customer_name,
          msc_get_name.customer_site(md.customer_site_id) customer_site,
          msc_get_name.org_code(nvl(md.prev_subst_org, md.original_org_id),
                              md.original_inst_id) org_code,
          msc_get_name.org_code(md.organization_id,md.sr_instance_id) to_org,
          msoi.schedule_ship_date new_ship_date,
          md.schedule_ship_date old_ship_date,
          msoi.schedule_arrival_date new_arrival_date,
          md.schedule_arrival_date old_arrival_date,
          msoi.ship_method new_ship_method,
          md.orig_shipping_method_code old_ship_method,
          md.orig_intransit_lead_time old_lead_time,
          msoi.delivery_lead_time new_lead_time,
          msoi.earliest_ship_date earliest_ship_date,
          msoi.return_status,
          md.demand_id,
          md.inventory_item_id,
          md.organization_id,
          md.sr_instance_id,
          md.plan_id,
          mp.compile_designator plan_name,
          msoi.line_number line_number,
          msc_get_name.lookup_meaning('SYS_YES_NO',msoi.return_status) atp_override_flag,
          msc_get_name.item_name(nvl(md.prev_subst_item,md.original_item_id),
                                 null,null,null)
                                 orig_item_name,
          msc_get_name.item_desc(nvl(md.prev_subst_item,md.original_item_id),
                                 nvl(md.prev_subst_org, md.original_org_id),
                                 md.plan_id,md.original_inst_id)
                                 orig_item_desc
     from msc_system_items msi,
          msc_plans mp,
          msc_demands md,
          msc_sales_order_interface msoi
    where msoi.batch_id = p_batch_id
      and msoi.sr_instance_id = p_instance_id
      and msoi.plan_id = md.plan_id
      and msoi.demand_id = md.demand_id
      and msoi.return_status is not null
      and msi.plan_id = md.plan_id
      and msi.organization_id = md.organization_id
      and msi.sr_instance_id = md.sr_instance_id
      and msi.inventory_item_id = md.inventory_item_id
      and mp.plan_id = msoi.plan_id;

   all_rec all_c%ROWTYPE;

BEGIN

OPEN all_c;
LOOP
 FETCH all_c INTO all_rec;
 EXIT WHEN all_c%NOTFOUND;

  select to_char(mrp_form_query_s.nextval)
    into item_key
   from dual;

  wf_engine.CreateProcess( itemtype => item_type,
			    itemkey  => item_key,
                             process => l_process);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_TYPE_ID',
			       avalue   => 70);  -- new exception type

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORDER_TYPE_CODE',
			       avalue   => -30);  -- from release so

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'TRANSACTION_ID',
			       avalue   => all_rec.demand_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'INVENTORY_ITEM_ID',
			       avalue   => all_rec.inventory_item_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORGANIZATION_ID',
			       avalue   => all_rec.organization_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'INSTANCE_ID',
			       avalue   => all_rec.sr_instance_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'SUPPLIER_ID',
			       avalue   => p_batch_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'PLAN_ID',
			       avalue   => all_rec.plan_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'PRE_PRSNG_LEAD_TIME',
			       avalue   => all_rec.old_lead_time);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'POST_PRSNG_LEAD_TIME',
			       avalue   => all_rec.new_lead_time);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORGANIZATION_CODE',
			     avalue   => all_rec.org_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PLAN_NAME',
			     avalue   => all_rec.plan_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DEPARTMENT_LINE_CODE',
			     avalue   => all_rec.to_org);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ITEM_DISPLAY_NAME',
			     avalue   => all_rec.item_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ITEM_DESCRIPTION',
			     avalue   => all_rec.item_desc);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'FROM_DATE',
			     avalue   => all_rec.old_ship_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_DATE',
			     avalue   => all_rec.new_ship_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE1',
			     avalue   => all_rec.old_arrival_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE2',
			     avalue   => all_rec.new_arrival_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE3',
			     avalue   => all_rec.earliest_ship_date);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'CUSTOMER_NAME',
			     avalue   => all_rec.customer_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'RESOURCE_CODE',
			     avalue   => all_rec.customer_site);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_NAME',
			     avalue   => all_rec.old_ship_method);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_SITE_CODE',
			     avalue   => all_rec.new_ship_method);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORDER_NUMBER',
			     avalue   => all_rec.order_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'LOT_NUMBER',
			     avalue   => all_rec.line_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PLANNING_GROUP',
			     avalue   => all_rec.atp_override_flag);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ITEM_DISPLAY_NAME',
			     avalue   => all_rec.orig_item_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ITEM_DESCRIPTION',
			     avalue   => all_rec.orig_item_desc);

  wf_engine.StartProcess( itemtype => item_type,
			    itemkey  => item_key);
FND_FILE.PUT_LINE(FND_FILE.LOG,'item_key='||item_key||', item_type='||item_type);

END LOOP;
CLOSE all_c;

END start_so_release_workflow;

FUNCTION date_offset(p_org_id number, p_instance_id number,
                     p_bucket_type number,
                     p_date date, p_offset_days number) return date is
  p_new_date date;
  p_new_offset number;
  p_minutes number := 0;
BEGIN
  -- 6142627, msc_calendar.date_offset will round up offset_days
   if ceil(p_offset_days) <> p_offset_days then
      p_new_offset := floor(p_offset_days);
   else
      p_new_offset := p_offset_days;
   end if;

   p_new_date := msc_calendar.date_offset(
                 p_org_id,
                 p_instance_id,
                 p_bucket_type,
                 p_date,
                 p_new_offset);

--dbms_output.put_line('p_new_date='||p_new_date);

    -- msc_calendar.date_offset  will remove the timestamp
    if to_char(p_date,'HH24:MI:SS') <> '00:00:00' then
       p_minutes := (p_date - trunc(p_date)) *24*60;
--dbms_output.put_line('timestamp: p_minutes='||p_minutes);
    end if;

    if p_new_offset <> p_offset_days then
      -- need to calculate the partial day offset in minutes
       p_minutes := p_minutes +
                   (p_offset_days - p_new_offset) *24*60;
--dbms_output.put_line('partial offset: p_minutes='||p_minutes);
    end if;

    if p_minutes > 0 then
       if p_minutes >= 24*60 then
         -- greater than one day, should find the next working day
          p_new_date :=
                msc_calendar.date_offset(
                 p_org_id,
                 p_instance_id,
                 p_bucket_type,
                 p_new_date,
                 1);
         p_minutes := p_minutes - 24*60;
--dbms_output.put_line('partial more than a day: p_minutes='||p_minutes||',p_new_date='||p_new_date);
       end if; -- if p_minutes >= 24*60
       p_new_date := p_new_date + ceil(p_minutes)/(24*60);
--dbms_output.put_line('p_minutes='||p_minutes||',p_new_date='||p_new_date);
    end if; -- if p_minutes > 0 then

  return p_new_date;
END date_offset;

END msc_rel_wf;

/
