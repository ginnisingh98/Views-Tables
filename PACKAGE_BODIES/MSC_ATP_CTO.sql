--------------------------------------------------------
--  DDL for Package Body MSC_ATP_CTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_CTO" AS
/* $Header: MSCCTOPB.pls 120.9.12010000.3 2010/01/21 09:51:18 aksaxena ship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'MSC_ATP_CTO';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Check_Lines_For_CTO_ATP (
  p_atp_rec             IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
  p_session_id          IN   number,
  p_dblink              IN   varchar2,
  p_instance_id         IN   Number,
  x_return_status       OUT      NoCopy VARCHAR2
) IS

l_atp_supply_demand  MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period         MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details        MRP_ATP_PUB.ATP_Details_Typ;
l_msg_data           VARCHAR2(30);
l_msg_count          VARCHAR2(30);
l_return_status      VARCHAR2(30);
l_atp_count          number;
l_error_code         number;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** Begin Check_Lines_For_CTO_ATP  *****');
   END IF;

   --- put data in mrp_atp_schedule_temp, call put_into_temp
   MSC_ATP_UTILS.put_into_temp_table(
                   NULL,
                   p_session_id,
                   p_atp_rec,
                   l_atp_supply_demand,
                   l_atp_period,
                   l_atp_details,
                   MSC_ATP_UTILS.REQUEST_MODE,
                   l_return_status,
                   l_msg_data,
                   l_msg_count);


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** After putting the data into temp table   *****');
   END IF;
   ----now call CTO for matching and option dependent sourcing
   --IF MSC_ATP_PVT.G_INV_CTP = 4 then -- call matching API for both ODS and PDS
   IF NOT( MSC_ATP_PVT.G_CALLING_MODULE = 724) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('***** Call Matching *****');
      END IF;

      MSC_ATP_CTO.Match_CTO_Lines(p_session_id, p_dblink, p_instance_id, l_return_status);

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('***** l_return_status := ' || l_return_status);
          msc_sch_wb.atp_debug('*** G_RET_STS_SUCCESS := ' || FND_API.G_RET_STS_SUCCESS);
      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('***** Error Occured While Matching *****');
         END IF;
         l_error_code := MSC_ATP_PVT.ERROR_WHILE_MATCHING;
         p_atp_rec.error_code(1) := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
         RAISE FND_API.G_EXC_ERROR ;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('***** AFTER Call Matching *****');

      END IF;

      ---now transfer data into CTO BOM
      --we do this step when we need to make it
      --populate_cto_bom(p_session_id, p_dblink);
   ELSE
      --- Call from 724. Always enable ATP
      MSC_ATP_PUB.G_ATP_CHECK := 'Y';
   END IF;

   ---now check if non atpable item  exist or not
   IF MSC_ATP_PUB.G_ATP_CHECK = 'N' THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('***** Check if any ATPAble item exisst or not ****');
       END IF;
       select count(*)
       into l_atp_count
       from mrp_atp_schedule_temp
       where session_id = p_session_id
       and   order_line_id = NVL(ato_model_line_id, order_line_id)
       --bug 3378648
       and   status_flag in (99,4) --4658238
       ---Bug 3687934
       --- GOP for non-atpable items: We go to destination if source organization is not provided.
       and   (NVL(atp_flag, 'N') <> 'N' or atp_components_flag <> 'N' or source_organization_id is null);

       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('***** After check for ATPable item, l_atp_count := ' || l_atp_count );
       END IF;

       IF l_atp_count > 0 THEN
          MSC_ATP_PUB.G_ATP_CHECK := 'Y';
       END IF;


   END IF;


   --- now we need to populte the data back into atp_rec_type if
   --- 1. single database setup
   --- 2. distributed setup and no items are atpable

   IF (p_dblink is null and MSC_ATP_PVT.G_CALLING_MODULE <> 724) or MSC_ATP_PUB.G_ATP_CHECK = 'N' THEN
      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('***** db link is null or no itmes are atpable, get the data');
      END IF;

      MSC_ATP_UTILS.Get_From_Temp_Table(
                   null,
                   p_session_id,
                   p_atp_rec,
                   l_atp_supply_demand,
                   l_atp_period,
                   l_atp_details,
                   MSC_ATP_UTILS.REQUEST_MODE,
                   l_return_status,
                   l_msg_data,
                   l_msg_count,
                   2);  -- details_flag
     IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('*****  number of records := ' || p_atp_rec.inventory_item_id.count );
      END IF;

   END IF;
EXCEPTION

   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('*****  Errror Occured in Check_Lines_For_CTO_ATP');
           msc_sch_wb.atp_debug('Sql Error := ' || SQLERRM);
      END IF;
      p_atp_rec.error_code(1) :=  MSC_ATP_PVT.ATP_PROCESSING_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;

END Check_Lines_For_CTO_ATP;

Procedure Match_CTO_Lines(P_session_id IN Number,
                          p_dblink IN varchar2,
                          p_instance_id IN number,
                          x_return_status OUT NOCOPY VARCHAR2)
IS

l_cto_lines_for_match CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE;
l_cto_sources  CTO_OSS_SOURCE_PK.OSS_ORGS_LIST_REC_TYPE;
i number;
l_return_status varchar2(30);
l_msg_count number;
l_msg_data  varchar2(100);
l_action    varchar2(10);
l_match_found varchar2(1);
l_source varchar2(10);

BEGIN

   ---first check if there are any ATPable Models/ATO items or not

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Inside Call Matching');
       msc_sch_wb.atp_debug('P_session_id := ' || P_session_id);
      msc_sch_wb.atp_debug('p_dblink := ' || p_dblink);
      msc_sch_wb.atp_debug('p_instance_id := '|| p_instance_id);
   END IF;
   --- distinct is needed because for GOP, UI calls same
   -- lines with different warehouse.
   -- CTO has unique index on line id. If distinct in not used
   -- the CTO is called with multiple lines with same line id.
   -- This fails the unique index they have
   select distinct
   mast.order_line_id,
   mast.Parent_line_id,
   mast.ATO_Model_Line_Id,
   mast.Top_Model_line_id,
   mast.inventory_item_id,
   mast.Component_Code,
   mast.Component_Sequence_ID,
   mast.validation_org,
   mast.Quantity_Ordered,
   mast.UOM_CODE,
   -- 3555026: pass  source organization id to CTO only when call comes from SO pad
   decode(NVL(mast.calling_module, -1), -1, null, mast.source_organization_id)
   bulk collect into
   l_cto_lines_for_match.line_id,
   l_cto_lines_for_match.LINK_TO_LINE_ID,
   l_cto_lines_for_match.ATO_LINE_ID,
   l_cto_lines_for_match.TOP_MODEL_LINE_ID,
   l_cto_lines_for_match.INVENTORY_ITEM_ID,
   l_cto_lines_for_match.COMPONENT_CODE,
   l_cto_lines_for_match.COMPONENT_SEQUENCE_ID ,
   l_cto_lines_for_match.VALIDATION_ORG,
   l_cto_lines_for_match.ORDERED_QUANTITY,
   l_cto_lines_for_match.ORDER_QUANTITY_UOM,
   --pass source org to CTO
   l_cto_lines_for_match.SHIP_FROM_ORG_ID
   from mrp_atp_schedule_temp mast
   where  Session_id = p_session_id and
   --bug 3378648: Look only at ATP inserted data
   status_flag in (99,4) and --4658238
   Ato_model_line_id in
         (select mast_1.ato_model_line_id from
         mrp_atp_schedule_temp mast_1
         where mast_1.session_id = p_session_id
          --bug 3378648
          and status_flag in (99,4) --4658238
          and mast_1.order_line_id = mast_1.ato_model_line_id
          and (mast_1.atp_flag <> 'N' or mast_1.atp_components_flag <> 'N')
          and mast_1.QUANTITY_ORDERED > 0)
    order by mast.order_line_id; --required by cto fix 5971615

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' after SQL to see if ATPable models are there or not');
      msc_sch_wb.atp_debug('Number of ATPAble components := '
                                             || l_cto_lines_for_match.line_id.count);
   END IF;
   ---- Now see if we have any atpable CTO Models or not


   IF l_cto_lines_for_match.inventory_item_id.count > 0 THEN
      --- we found some lines to match. Some Top level ATPable models are present
      -- call CTO
      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug(' ATPable models are present, call cto api for matching');
      END IF;
      BEGIN
         --some atpable model is there. We need to go to destonation. st the atp check flag
         MSC_ATP_PUB.G_ATP_CHECK := 'Y';
          --CTO team has asked for this. The need to differentiate between calls from GOP or other modules

         l_source := 'GOP';
         --call cto api for matching and other information
         CTO_GOP_INTERFACE_PK.CTO_GOP_WRAPPER_API(
                                 l_action,
                                 l_source,
                                 l_cto_lines_for_match,
                                 l_cto_sources,
                                 l_return_status,
                                 l_msg_count,
                                 l_msg_data);

         IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug(' l_return_status := ' || l_return_status);
         END IF;


         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug(' Unhandeled ecpetion occured in call to CTO API');
                 msc_sch_wb.atp_debug('Error := ' || sqlerrm);
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR ;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug(' Unhandeled ecpetion occured in call to CTO API');
                 msc_sch_wb.atp_debug('Error := ' || sqlerrm);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR ;
            ---match fail
      END;

      -- update mrp_atp_schedule_temp with match info Praent_ato_lin_id information
      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug(' l_cto_lines_for_match count := ' || l_cto_lines_for_match.inventory_item_id.count);
          msc_sch_wb.atp_debug('matched_item_id count := ' || l_cto_lines_for_match.config_item_id.count);
          msc_sch_wb.atp_debug('gop_parent_ato_line_id count := ' || l_cto_lines_for_match.gop_parent_ato_line_id.count);
          msc_sch_wb.atp_debug('wip_supply_type count := ' || l_cto_lines_for_match.wip_supply_type.count);
          msc_sch_wb.atp_debug('oss_error_code count := ' || l_cto_lines_for_match.oss_error_code.count);
          FOR i in 1..l_cto_lines_for_match.inventory_item_id.count LOOP
            msc_sch_wb.atp_debug('counter := ' || i);
            msc_sch_wb.atp_debug('item id := ' || l_cto_lines_for_match.inventory_item_id(i));
            msc_sch_wb.atp_debug('gop_parent_ato_line_id := ' || l_cto_lines_for_match.gop_parent_ato_line_id(i));
            msc_sch_wb.atp_debug('matched_item_id := ' || l_cto_lines_for_match.config_item_id(i));
            msc_sch_wb.atp_debug('wip_supply_type := ' || l_cto_lines_for_match.wip_supply_type(i));
            msc_sch_wb.atp_debug('oss_error_code := ' || l_cto_lines_for_match.oss_error_code(i));
          END LOOP;

      END IF;
      --update information returned by match API
      FORALL i in 1..l_cto_lines_for_match.inventory_item_id.count
      UPDATE mrp_atp_schedule_temp
      SET ATO_Parent_Model_Line_Id = l_cto_lines_for_match.gop_parent_ato_line_id(i),
          match_item_id = l_cto_lines_for_match.config_item_id(i),
          wip_supply_type = l_cto_lines_for_match.wip_supply_type(i),
          oss_error_code  = l_cto_lines_for_match.oss_error_code(i),
          error_code = l_cto_lines_for_match.oss_error_code(i)
      WHERE session_id = p_session_id
      --bug 3378648:
      and status_flag in (99,4) --4658238
      and order_line_id = l_cto_lines_for_match.line_id(i);

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug(' After Update of CTO data');
          msc_sch_wb.atp_debug('Lines updated := ' || SQL%ROWCOUNT);
          msc_sch_wb.atp_debug('Process CTO sources, count := ' || l_cto_sources.org_id.count);
      END IF;

      ---transfer option specific data
      Process_CTO_Sources(p_dblink,
                          p_session_id,
                          l_cto_sources,
                          p_instance_id);

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug(' After processing CTO sources');
      END IF;

   END IF; --IF l_cto_lines_for_match.inventory_item_id.count > 0 TH
EXCEPTION
   WHEN OTHERS THEN
      msc_sch_wb.atp_debug('Error Occured := ' || SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;

END Match_CTO_Lines;

Procedure Process_CTO_Sources(p_dblink      IN varchar2,
                              p_session_id  IN number,
                              p_cto_sources IN CTO_OSS_SOURCE_PK.OSS_ORGS_LIST_REC_TYPE,
                              p_instance_id IN NUMBER)
IS
l_dblink varchar2(30);
l_sql_stmt varchar2(10000);
i number;
l_user_id number;
l_sysdate date;
i number;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Inside Process CTO Source');
       msc_sch_wb.atp_debug('Print CTO OSS Data');
       FOR i in 1..p_cto_sources.Inventory_item_id.count LOOP
          msc_sch_wb.atp_debug('Source # := ' || i);
          msc_sch_wb.atp_debug('Line_id := ' || p_cto_sources.line_id(i));
          msc_sch_wb.atp_debug('Inventory_item_id := ' || p_cto_sources.Inventory_item_id(i));
          msc_sch_wb.atp_debug('Org_id := '|| p_cto_sources.Org_id(i));
          msc_sch_wb.atp_debug('Vendor_id := ' || p_cto_sources.Vendor_id(i));
           msc_sch_wb.atp_debug('Vendor_site := ' || p_cto_sources.Vendor_site(i));
          msc_sch_wb.atp_debug('ato_line_id := ' || p_cto_sources.ato_line_id(i));
          msc_sch_wb.atp_debug('make_flag := ' || p_cto_sources.make_flag(i));
       END LOOP;
   END IF;
   --code to transfer data from pl/sql to CTO source table.
   l_user_id := FND_GLOBAL.user_id;
   l_sysdate := sysdate;

   l_dblink := '@' || p_dblink;

   /*s_cto_rearch: 24x7 --now CTO sources is session specific. We donot need to maintain sattsu flag
   IF p_dblink is null then
      update msc_cto_sources
      set    status_flag = 2
      where  ato_line_id in (select order_line_id
                         from mrp_atp_schedule_temp
                         where session_id = p_session_id
                         and   order_line_id = ato_model_line_id);
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Number of rows updated := ' || SQL%ROWCOUNT);
      END IF;
   Else
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Delete CTO Sources locally');
      END IF;
      delete msc_cto_sources
      where  line_id in (select order_line_id
                         from mrp_atp_schedule_temp
                         where session_id = p_session_id
                         and   order_line_id = ato_model_line_id);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Number of rows deleted := ' || SQL%ROWCOUNT);
         msc_sch_wb.atp_debug('Update CTO Sources across DB');
      END IF;
      l_sql_stmt := 'Update msc_cto_sources' || l_dblink;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('sql stmt := ' || l_sql_stmt);
      END IF;
      l_sql_stmt := l_sql_stmt || ' set status_flag = 2 '
                               || ' where  ato_line_id in (select order_line_id '
                               || ' from mrp_atp_schedule_temp '
                               || ' where session_id = :p_session_id '
                               || ' and   order_line_id = ato_model_line_id)';
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('sql stmt := ' || l_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE l_sql_stmt using p_session_id;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' After Updating CTO Sources across DB');
         msc_sch_wb.atp_debug('Number of rows updated := ' || SQL%ROWCOUNT);
      END IF;
   END IF;

   e_cto_rearch: 24x7 */

   IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Now Insert New data');
   END IF;

   IF p_cto_sources.line_id.count > 0 THEN
      --now insert the latest data into msc_cto_sources
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Now Insert New data in Local Tbale');
      END IF;

      FORALL i in 1..p_cto_sources.line_id.count --LOOP
          insert into msc_cto_sources
             (line_id,
              inventory_item_id,
              organization_id,
              supplier_id,
              supplier_site_code,
              status_flag,
              sr_instance_id,
              ato_line_id,
              make_flag,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              refresh_number,
              session_id)
          values
            ( p_cto_sources.line_id(i),
              p_cto_sources.Inventory_item_id(i),
              p_cto_sources.Org_id(i),
              p_cto_sources.Vendor_id(i),
              p_cto_sources.Vendor_site(i),
              1,
              p_instance_id,
              p_cto_sources.ato_line_id(i),
              p_cto_sources.make_flag(i),
              l_user_id,
              l_sysdate,
              l_user_id,
              l_sysdate,
              MSC_ATP_PVT.G_REFRESH_NUMBER,
              p_session_id);
       --END LOOP;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('After Insert New data in Local Table');
          msc_sch_wb.atp_debug('Number of rows inserted := ' || SQL%ROWCOUNT);
       END IF;

       If p_dblink is not null THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Transfer Data Across DBLink');
          END IF;
          --now transfer the data across dblink
          l_sql_stmt := 'Insert into msc_cto_sources' || l_dblink;
          l_sql_stmt := l_sql_stmt || ' ( LINE_ID, ORGANIZATION_ID, SUPPLIER_ID,
                                        SUPPLIER_SITE_CODE, STATUS_FLAG, INVENTORY_ITEM_ID,
                                        SR_INSTANCE_ID, ATO_LINE_ID, CREATION_DATE,
                                        CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_DATE,
                                        MAKE_FLAG, refresh_number, session_id)
                                        Select LINE_ID, ORGANIZATION_ID, SUPPLIER_ID,
                                        SUPPLIER_SITE_CODE, STATUS_FLAG, INVENTORY_ITEM_ID,
                                        SR_INSTANCE_ID, ATO_LINE_ID, CREATION_DATE,
                                        CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_DATE,
                                        MAKE_FLAG, refresh_number, session_id from msc_cto_sources
                                        where session_id =  :p_session_id
                                        and   line_id in (select order_line_id
                                                          from mrp_atp_schedule_temp
                                                          where session_id = :p_session_id
                                                          --bug 3378648
                                                          and status_flag = 99
                                                          and   order_line_id = ato_model_line_id)';
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('l_sql_stmt := ' || l_sql_stmt);
          END IF;
          EXECUTE IMMEDIATE l_sql_stmt using p_session_id, p_session_id;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('After Transfering Data Across DBLink');
             msc_sch_wb.atp_debug('Number of rows transfered across dblink := ' || SQL%ROWCOUNT);
          END IF;

       END IF;
   END IF;
END Process_CTO_Sources;


Procedure Get_Mandatory_Components(p_plan_id              IN NUMBER,
                                   p_instance_id          IN NUMBER,
                                   p_organization_id      IN NUMBER,
                                   p_sr_inventory_item_id IN NUMBER,
                                   p_quantity             IN NUMBER,
                                   p_request_date         IN DATE,
                                   p_dest_inv_item_id     IN NUMBER,
                                   x_mand_comp_info_rec   OUT NOCOPY MSC_ATP_CTO.mand_comp_info_rec
                                   )

IS
l_inventory_item_id number;
l_process_seq_id    number;
l_routing_seq_id    number;
l_bill_seq_id       number;
l_op_seq_id         number;
l_return_status     varchar2(30);
i                   number;
l_sysdate           date; --4137608
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Mandatory_Components: Inside Get Mandatory Components');
       msc_sch_wb.atp_debug('Get_Mandatory_Components: p_dest_inv_item_id := ' || p_dest_inv_item_id);
       msc_sch_wb.atp_debug('Get_Mandatory_Components:p_sr_inventory_item_id := ' || p_sr_inventory_item_id);
       msc_sch_wb.atp_debug('Get_Mandatory_Components: p_plan_id := ' || p_plan_id);
       msc_sch_wb.atp_debug('p_instance_id := ' || p_instance_id);
       msc_sch_wb.atp_debug('p_quantity := '|| p_quantity);
       msc_sch_wb.atp_debug('p_request_date := ' || p_request_date);
       msc_sch_wb.atp_debug('MSC_ATP_PVT.G_PTF_DATE := '|| MSC_ATP_PVT.G_PTF_DATE); --4137608
       --l_sysdate := trunc(sysdate); --4137608 --bug 8585385, remove this statement from the debug block
   END IF;
   l_sysdate := trunc(sysdate); --4137608, 8585385
   ----first get the destination inventory_item_id
   IF p_dest_inv_item_id is not null THEN
      l_inventory_item_id := p_dest_inv_item_id;
   ELSE
      l_inventory_item_id := MSC_ATP_FUNC. get_inv_item_id(p_instance_id,
                                                        p_sr_inventory_item_id,
                                                        null,
                                                        p_organization_id);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Mandatory_Components: l_inventory_item_id := ' || l_inventory_item_id);
   END IF;

   ---- Now get the process effectivity
   MSC_ATP_PROC.get_process_effectivity(
                                p_plan_id,
                                l_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                p_request_date,
                                p_quantity,
                                l_process_seq_id,
                                l_routing_seq_id,
                                l_bill_seq_id,
                                l_op_seq_id, --4570421
                                l_return_status);


   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Mandatory_Components: l_bill_seq_id := ' || l_bill_seq_id);
       msc_sch_wb.atp_debug('Get_Mandatory_Components: l_op_seq_id := ' || l_op_seq_id); --4570421
   END IF;
   --- now get the components
   BEGIN
      SELECT msi.sr_inventory_item_id,
             --4570421
             --round(mbc.usage_quantity * p_quantity, 6),
             ROUND ((decode (NVL (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,1), MSC_ATP_PVT.DISCRETE_ORG, decode ( nvl(mbc.scaling_type, 1), 1, (MBC.USAGE_QUANTITY*p_quantity),
	                                                                                                                               2, MBC.USAGE_QUANTITY),
	                                                                       MSC_ATP_PVT.OPM_ORG, decode (nvl (mbc.scaling_type, 1), 0, MBC.USAGE_QUANTITY,
	                                                                                                                               1, (MBC.USAGE_QUANTITY*p_quantity),
	                                                                                                                               2, MBC.USAGE_QUANTITY,
	                                                                                                                               3, (MBC.USAGE_QUANTITY*p_quantity),
	                                                                                                                               4, (MBC.USAGE_QUANTITY*p_quantity),
	                                                                                                                               5, (MBC.USAGE_QUANTITY*p_quantity))
	               ))--/NVL (mbc.component_yield_factor, 1) --4767982
	               ,6),
             msi.atp_flag,
             msi.atp_components_flag,
             msi.aggregate_time_fence_date, -- For time_phased_atp
             msi.bom_item_type,
             msi.fixed_lead_time,
             msi.variable_lead_time,
             msi.inventory_item_id,
             msi.uom_code,
             --4570421
             mbc.scaling_type,
             mbc.scale_multiple,
             mbc.scale_rounding_variance,
             mbc.rounding_direction,
             mbc.component_yield_factor, --4570421
             MBC.USAGE_QUANTITY*mbc.component_yield_factor, --4775920
             NVL (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,1) --4775920
      BULK COLLECT INTO
             x_mand_comp_info_rec.sr_inventory_item_id,
             x_mand_comp_info_rec.quantity,
             x_mand_comp_info_rec.atp_flag,
             x_mand_comp_info_rec.atp_components_flag,
             x_mand_comp_info_rec.atf_date, --For time_phased_atp
             x_mand_comp_info_rec.bom_item_type,
             x_mand_comp_info_rec.fixed_lead_time,
             x_mand_comp_info_rec.variable_lead_time,
             x_mand_comp_info_rec.dest_inventory_item_id,
             x_mand_comp_info_rec.uom_code,
             --4570421
             x_mand_comp_info_rec.scaling_type,
             x_mand_comp_info_rec.scale_multiple,
             x_mand_comp_info_rec.scale_rounding_variance,
             x_mand_comp_info_rec.rounding_direction,
             x_mand_comp_info_rec.component_yield_factor, --4570421
             x_mand_comp_info_rec.usage_qty, --4775920
             x_mand_comp_info_rec.organization_type --4775920

      FROM MSC_SYSTEM_ITEMS  MSI,
           MSC_BOM_COMPONENTS MBC
      WHERE Mbc.plan_id = p_plan_id
      AND mbc.sr_instance_id = p_instance_id
      AND mbc.bill_sequence_id = l_bill_seq_id
      AND mbc.using_assembly_id = l_inventory_item_id
      AND mbc.organization_id = p_organization_id
      AND mbc.optional_component = 2  --- choose mandatory comps
      -- do not honor atp_flag for smcs
      ---AND mbc.ATP_FLAG = 1       --- chose ATPable components
      AND mbc.USAGE_QUANTITY > 0
      AND msi.inventory_item_id = mbc.inventory_item_id
      AND msi.organization_Id = mbc.organization_id
      AND msi.plan_id = mbc.plan_id
      AND msi.sr_instance_id = mbc.sr_instance_id
      AND msi.bom_item_type = 4 -- chose always standard comp as option class will be passed by OM
      AND (msi.atp_flag <> 'N' or msi.atp_components_flag <> 'N')
      --4137608
      -- effective date should be greater than or equal to greatest of PTF date, sysdate and request date
      -- disable date should be less than or equal to greatest of PTF date, sysdate and request date
      AND      TRUNC(NVL(MBC.DISABLE_DATE, GREATEST(p_request_date, l_sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >=
        	         	TRUNC(GREATEST(p_request_date, l_sysdate, MSC_ATP_PVT.G_PTF_DATE))
      AND      TRUNC(MBC.EFFECTIVITY_DATE) <=
         	      	TRUNC(GREATEST(p_request_date, l_sysdate, MSC_ATP_PVT.G_PTF_DATE));
      --4137608
      /*AND trunc(mbc.effectivity_date) <= trunc(p_request_date)
      AND nvl(trunc(mbc.disable_date), trunc(p_request_date))
                                          >= trunc(p_request_date);*/
   EXCEPTION
      WHEN OTHERS THEN
          IF  PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Mandatory_Components: Error in get mand comp := ' || sqlerrm);
          END IF;

   END;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Get_Mandatory_Components: mand comp count := ' || x_mand_comp_info_rec.sr_inventory_item_id.count);
      FOR i in 1..x_mand_comp_info_rec.sr_inventory_item_id.count LOOP
          msc_sch_wb.atp_debug('Get_Mandatory_Components: i := ' || i);
          msc_sch_wb.atp_debug('Get_Mandatory_Components: sr_inv_id := ' || x_mand_comp_info_rec.sr_inventory_item_id(i));
          msc_sch_wb.atp_debug('Get_Mandatory_Components: quantity := ' || x_mand_comp_info_rec.quantity(i));
      END LOOP;
      msc_sch_wb.atp_debug('Get_Mandatory_Components: End Get_mandatory_components');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF  PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Error in get mand comp := ' || sqlerrm);
      END IF;
END Get_Mandatory_Components;

Procedure Validate_CTO_Sources (P_SOURCE_LIST   IN OUT NOCOPY MRP_ATP_PVT.Atp_Source_Typ,
                                p_line_ids      IN MRP_ATP_PUB.number_arr,
                                p_instance_id   IN number,
                                p_session_id    IN number,
                                x_return_status OUT NOCOPY varchar2)
IS

l_cto_source_list MRP_ATP_PVT.Atp_Source_Typ;

l_match_source_list MRP_ATP_PVT.Atp_Source_Typ;

l_count number;

l_parent_src_cntr   number;
l_cto_source_cntr   number;
l_cto_source_found  number;
l_item_count number;
i            number;

l_org_id    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_line_id   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_sup_id    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Validate CTO Source');
      msc_sch_wb.atp_debug('p_line_ids.count := ' || p_line_ids.count);
      FOR i in 1..P_SOURCE_LIST.organization_id.count LOOP
           msc_sch_wb.atp_debug('Source # := ' || i);
           msc_sch_wb.atp_debug('Organization_Id := ' || P_SOURCE_LIST.organization_id(i));
           msc_sch_wb.atp_debug('Instance_Id := ' || P_SOURCE_LIST.Instance_Id(i));
           msc_sch_wb.atp_debug('Supplier_Id := ' || P_SOURCE_LIST.Supplier_Id(i));
           msc_sch_wb.atp_debug('Supplier_Site_Id := ' || P_SOURCE_LIST.Supplier_Site_Id(i));
           msc_sch_wb.atp_debug('Rank := ' || P_SOURCE_LIST.rank(i));
      END LOOP;
   END IF;

   IF p_line_ids.count = 1 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('line count := 1');
      END IF;
      select organization_id,
             tp_id,
             partner_site_id,
             make_flag
      bulk collect into
      l_cto_source_list.organization_id,
      l_cto_source_list.supplier_id,
      l_cto_source_list.supplier_site_id,
      l_cto_source_list.make_flag
      from
      (
      select mcs.organization_id,
             /* bug 3628958: if null is directly used in union clause then error is raised that datatype do not match
             null tp_id,
             null partner_site_id,
             */
             to_number(null) tp_id,
             to_number(null) partner_site_id,
             make_flag
      from msc_cto_sources mcs
      where mcs.line_id = p_line_ids(1)
      and   mcs.sr_instance_id = p_instance_id
      --and   mcs.status_flag = 1
      and   mcs.session_id = p_session_id
      and   mcs.organization_id is not null

      UNION ALL
      --bug 3628958
      --select null organization_id,
      select to_number(null) organization_id,
             mtil.tp_id,
             mtps.partner_site_id,
             make_flag
      from msc_cto_sources mcs,
           msc_tp_id_lid mtil,
           msc_trading_partner_sites mtps
      where mcs.line_id = p_line_ids(1)
      and   mcs.sr_instance_id = p_instance_id
      --and   mcs.status_flag = 1
      and   mcs.session_id = p_session_id
      and   mcs.supplier_id is not null
      and   mcs.supplier_site_code is not null
      and   mcs.supplier_id = mtil.sr_tp_id
      and   mtil.partner_type = 1
      and   mcs.sr_instance_id = mtil.sr_instance_id
      and   mtil.tp_id = mtps.partner_id
      and   mtps.partner_type = 1
      and   mcs.supplier_site_code = mtps.tp_site_code
      );
      /* select nvl(mcs.organization_id,0),
             nvl(mtil.tp_id,0),
             nvl(mtps.partner_site_id, 0),
             make_flag
      bulk collect into
      l_cto_source_list.organization_id,
      l_cto_source_list.supplier_id,
      l_cto_source_list.supplier_site_id,
      l_cto_source_list.make_flag
      from msc_cto_sources mcs,
           msc_tp_id_lid mtil,
           msc_trading_partner_sites mtps
      where mcs.line_id = p_line_ids(1)
      and   mcs.sr_instance_id = p_instance_id
      and   mcs.status_flag = 1
      and   ( mcs.organization_id is not null
              or (       mcs.supplier_id is not null
                   and   mcs.supplier_site_code is not null
                   and   mcs.supplier_id = mtil.sr_tp_id
                   and   mtil.partner_type = 1
                   and   mcs.sr_instance_id = mtil.sr_instance_id
                   and   mtil.tp_id = mtps.partner_id
                   and   mtps.partner_type = 1
                   and   mcs.supplier_site_code = mtps.tp_site_code
                   ));
      */
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('CTO sources count := ' || l_cto_source_list.organization_id.count);
      END IF;

   ELSE

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Number of line > 1');
      END IF;

      BEGIN
         ---first find out how many items have OSS specific rules
         select count(distinct mcs.line_id)
         into   l_item_count
         from   msc_cto_sources mcs,
                msc_ship_set_temp msst
         where mcs.line_id =  msst.line_id
         and   mcs.sr_instance_id = p_instance_id
         --and   mcs.status_flag = 1;
         and session_id = p_session_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_item_count := 0;
      END;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Number of lines having OSS rule := ' || l_item_count);
      END IF;

      --now select common orgs for the itmes which have OSS

      IF l_item_count > 0 THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            select mcs.line_id,
                   nvl(mcs.organization_id, -1),
                   mcs.supplier_id
            bulk collect into
                   l_line_id,
                   l_org_id,
                   l_sup_id
            from   msc_cto_sources mcs,
                   msc_ship_set_temp msst
            where  mcs.line_id =  msst.line_id
            and   mcs.sr_instance_id = p_instance_id
            --and   mcs.status_flag = 1;
            and   mcs.session_id = p_session_id;

            FOR i in 1..l_line_id.count LOOP
                msc_sch_wb.atp_debug(' OSS # := ' || i);
                msc_sch_wb.atp_debug('Line id := ' || l_line_id(i));
                msc_sch_wb.atp_debug(' Org := ' || l_org_id(i));
                msc_sch_wb.atp_debug('sup id := ' || l_sup_id(i));
            END LOOP;

         END IF;
         select nvl(mcs.organization_id,0),
                null,
                null,
                null
         bulk collect into
         l_cto_source_list.organization_id,
         l_cto_source_list.supplier_id,
         l_cto_source_list.supplier_site_id,
         l_cto_source_list.make_flag
         from msc_cto_sources mcs,
              msc_ship_set_temp msst
         where mcs.line_id =  msst.line_id
         and   mcs.sr_instance_id = p_instance_id
         --and   mcs.status_flag = 1
         and  mcs.session_id = p_session_id
         and    mcs.organization_id is not null
         -- here we dont link on suppliers as we could have
         --more than one item only at top level. Since drop ship is not supported
         -- we can safely ignore suppliers
         group by mcs.organization_id
         having count(*) = l_item_count;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('CTO sources count := ' || l_cto_source_list.organization_id.count);
      END IF;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       FOR i in 1..l_cto_source_list.organization_id.count LOOP
           msc_sch_wb.atp_debug('CTO Sources');
           msc_sch_wb.atp_debug('Organization_id := ' || l_cto_source_list.organization_id(i));
           msc_sch_wb.atp_debug('Supplier _ID := ' || l_cto_source_list.Supplier_Id(i));
           msc_sch_wb.atp_debug('supplier Site Id := ' || l_cto_source_list.Supplier_site_id(i));
       END LOOP;
   END IF;

   IF p_line_ids.count > 1 and  l_item_count > 0 and l_cto_source_list.organization_id.count = 0 THEN

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Ship set, but no common OSS sources');
       END IF;
       --null out output table
       P_SOURCE_LIST := l_match_source_list;
       x_return_status := MSC_ATP_PVT.CTO_OSS_ERROR;

   ELSIF l_cto_source_list.organization_id.count > 0 THEN
       FOR l_parent_src_cntr in 1..p_source_list.organization_id.count LOOP
           IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('l_parent_src_cntr := ' || l_parent_src_cntr);
                msc_sch_wb.atp_debug('Model Source org := ' || p_source_list.organization_id(l_parent_src_cntr));
           END IF;
           FOR l_cto_source_cntr in 1..l_cto_source_list.organization_id.count LOOP

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('l_cto_source_cntr := ' || l_cto_source_cntr);
                  msc_sch_wb.atp_debug('CTO Source org := ' || l_cto_source_list.organization_id(l_cto_source_cntr));
               END IF;
               IF ( p_source_list.organization_id(l_parent_src_cntr) =
                                   l_cto_source_list.organization_id(l_cto_source_cntr) OR
                  (p_source_list.supplier_id(l_parent_src_cntr) =
                                   l_cto_source_list.supplier_id(l_cto_source_cntr) AND
                   p_source_list.supplier_site_id(l_parent_src_cntr) =
                                   l_cto_source_list.supplier_site_id(l_cto_source_cntr))) AND
                   p_source_list.instance_id(l_parent_src_cntr) = p_instance_id THEN

                   IF p_source_list.Source_Type(l_parent_src_cntr) = MSC_ATP_PVT.MAKE AND
                           NVL(l_cto_source_list.make_flag(l_cto_source_cntr), 'Y') = 'N' THEN

                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('Source Type := ' || p_source_list.Source_Type(l_parent_src_cntr));
                         msc_sch_wb.atp_debug('Make flag from CTO := ' ||l_cto_source_list.make_flag(l_cto_source_cntr));
                         msc_sch_wb.atp_debug('OSS Restricted source, cannot make in this org');
                      END IF;

                   ELSE

                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('Matching org found');
                         msc_sch_wb.atp_debug('Extend sources array and add org to it');
                      END IF;

                      --a matching source found
                      MSC_ATP_CTO.Extend_Sources_Rec(l_match_source_list);

                      l_count := l_match_source_list.Organization_Id.count;

                      l_match_source_list.Organization_Id(l_count) :=
                                                         p_source_list.Organization_Id(l_parent_src_cntr);
                      l_match_source_list.Instance_Id(l_count) :=
                                                         p_source_list.Instance_Id(l_parent_src_cntr);
                      l_match_source_list.Supplier_Id(l_count) :=
                                                         p_source_list.Supplier_Id(l_parent_src_cntr);
                      l_match_source_list.Supplier_Site_Id(l_count) :=
                                                         p_source_list.Supplier_Site_Id(l_parent_src_cntr);
                      l_match_source_list.Rank(l_count) :=
                                                         p_source_list.Rank(l_parent_src_cntr);
                      l_match_source_list.Source_Type(l_count) :=
                                                         p_source_list.Source_Type(l_parent_src_cntr);
                      l_match_source_list.Lead_Time(l_count) :=
                                                         p_source_list.Lead_Time(l_parent_src_cntr);
                      l_match_source_list.Ship_Method(l_count) :=
                                                         p_source_list.Ship_Method(l_parent_src_cntr);
                      l_match_source_list.Preferred(l_count) :=
                                                         p_source_list.Preferred(l_parent_src_cntr);

                      EXIT;

                   END IF;
               END IF;
           END LOOP;

       END LOOP;  -- FOR l_parent_src_cntr in 1..p_source_list.organization_id.count LOOP

       P_SOURCE_LIST := l_match_source_list;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Number of sources returned from validate CTO sources := '
                                                                || P_SOURCE_LIST.organization_id.count);
       END IF;
       IF l_match_source_list.organization_id.count = 0 THEN

           x_return_status := MSC_ATP_PVT.CTO_OSS_ERROR;
       END IF;

   END IF; -- IF l_cto_source_list.organization_id.count >



END Validate_CTO_Sources;

Procedure Extend_Sources_Rec(P_Source_Rec IN OUT  NOCOPY MRP_ATP_PVT.Atp_Source_Typ)
IS
BEGIN
   P_Source_Rec.Organization_Id.extend;
   P_Source_Rec.Instance_Id.extend;
   P_Source_Rec.Supplier_Id.extend;
   P_Source_Rec.Supplier_Site_Id.extend;
   P_Source_Rec.Rank.extend;
   P_Source_Rec.Source_Type.extend;
   P_Source_Rec.Lead_Time.extend;
   P_Source_Rec.Ship_Method.extend;
   P_Source_Rec.Preferred.extend;
   P_Source_Rec.make_flag.extend;
   P_Source_Rec.Sup_Cap_Type.extend;
END Extend_Sources_Rec;

procedure Populate_Cto_Bom(p_session_id IN number,
                           p_refresh_number IN number,
                           p_dblink     IN varchar2)
IS
l_dblink varchar2(30);
l_sql_stmt varchar2(1000);
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Inside Populate_Cto_Bom');
       msc_sch_wb.atp_debug('p_session_id := ' || p_session_id);
    END IF;

    --delete data for old session
    delete msc_cto_bom where session_id = p_session_id;
    ---first insert into local database
    insert into msc_cto_bom
    (SR_INVENTORY_ITEM_ID,
     inventory_item_id,
     LINE_ID,
     TOP_MODEL_LINE_ID,
     ATO_PARENT_MODEL_LINE_ID,
     ATO_MODEL_LINE_ID,
     MATCH_ITEM_ID,
     WIP_SUPPLY_TYPE,
     SESSION_ID,
     BOM_ITEM_TYPE,
     QUANTITY,
     PARENT_LINE_ID,
     sr_instance_id,
     refresh_number)
    SELECT distinct
           mast.inventory_item_id sr_inventory_item_id,
           mil.inventory_item_id  inventory_item_id,
           mast.ORDER_LINE_ID,
           mast.top_model_line_id,
           mast.ato_parent_model_line_id,
           mast.ato_model_line_id,
           mast.match_item_id,
           mast.wip_supply_type,
           mast.session_id,
           mast.BOM_ITEM_TYPE,
           mast.QUANTITY_ORDERED,
           mast.parent_line_id,
           MSC_ATP_PVT.G_INSTANCE_ID,
           p_refresh_number
    FROM   mrp_atp_schedule_temp mast,
           msc_item_id_lid mil
    where  session_id = p_session_id
    --bug 3378648
    and    status_flag = 99
    and    ato_model_line_id is not null -- transfer ATO model enteties only;
    and    mil.sr_instance_id = mast.sr_instance_id (+)
    and    mil.sr_inventory_item_id = mast.inventory_item_id (+);
           -- we need outer join just in case item is not collected

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Rows Inserted := ' || SQL%ROWCOUNT);
    END IF;

    IF p_dblink is not null THEN
       -- now transfer the data accross the database link
       --- in case of distributed transaction
       l_dblink := '@' || p_dblink;
       l_sql_stmt := 'Insert into Msc_CTO_Bom' || l_dblink;
       l_sql_stmt := l_sql_stmt ||
                     ' Select * from Msc_CTO_Bom where session_id = :p_session_id';


       EXECUTE IMMEDIATE l_sql_stmt USING p_session_id;
    END IF;


END Populate_Cto_Bom;


Procedure Get_CTO_BOM(p_session_id      IN NUMBER,
                      p_comp_rec        OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                      p_line_id         IN NUMBER,
                      p_request_date    IN DATE,
                      p_request_quantity  IN NUMBER,
                      p_parent_so_quantity   IN NUMBER,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id IN NUMBER,
                      p_plan_id         IN NUMBER,
                      p_instance_id     IN NUMBER,
                      p_fixed_lt        IN NUMBER,
                      p_variable_lt     IN NUMBER)
IS

l_lead_time   number;
l_mso_lead_time_factor number;
i number;
l_process_seq_id NUMBER; --4929084
l_routing_seq_id NUMBER;
l_bill_seq_id NUMBER;
l_op_seq_id NUMBER;
l_return_status VARCHAR2(1);
l_inventory_item_id NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_CTO_BOM: Inside get_cto_bom');
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_line_id := ' || p_line_id);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_request_date := ' || p_request_date);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_request_quantity := ' || p_request_quantity);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_parent_so_quantity := ' || p_parent_so_quantity);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_inventory_item_id := ' || p_inventory_item_id);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_organization_id := ' || p_organization_id);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_plan_id := ' || p_plan_id);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_instance_id := ' || p_instance_id);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_fixed_lt := ' || p_fixed_lt);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_variable_lt := ' || p_variable_lt);
       msc_sch_wb.atp_debug('Get_CTO_BOM: p_session_id := ' || p_session_id);
    END IF;
    --first get the lead time from msc_system_itmes
    --- this query can't be put with the query below there are no common linking columns
    /* BEGIN
       select fixed_lead_time, variable_lead_time
       into   l_fixed_lt, l_variable_lt
       from   msc_system_items
       where  plan_id = p_plan_id
       and    sr_instance_id = p_instance_id
       and    sr_inventory_item_id = p_inventory_item_id
       and    organization_id = p_organization_id;
    EXCEPTION
       WHEN OTHERS THEN
         l_fixed_lt := 0;
         l_variable_lt := 0;
    END;
    */

    --4929084
    l_inventory_item_id := MSC_ATP_FUNC. get_inv_item_id(p_instance_id,
                                                        p_inventory_item_id,
                                                        null,
                                                        p_organization_id);

   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_CTO_BOM: l_inventory_item_id := ' || l_inventory_item_id);
   END IF;

   ---- Now get the process effectivity
   MSC_ATP_PROC.get_process_effectivity(
                                p_plan_id,
                                l_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                p_request_date,
                                p_request_quantity,
                                l_process_seq_id,
                                l_routing_seq_id,
                                l_bill_seq_id,
                                l_op_seq_id, --4570421
                                l_return_status);


    l_mso_lead_time_factor := MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR;

    l_lead_time := CEIL((NVL(p_fixed_lt,0) + NVL(p_variable_lt, 0)* p_request_quantity)*
                                                       (1 + l_mso_lead_time_factor));

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_CTO_BOM: l_lead_time := ' || l_lead_time);
        msc_sch_wb.atp_debug('Get_CTO_BOM: G_INSTANCE_ID := ' || MSC_ATP_PVT.G_INSTANCE_ID);
    END IF;

    SELECT   mcb.sr_INVENTORY_ITEM_ID,
             (mcb.quantity / p_parent_so_quantity) * p_request_quantity ,
             c2.calendar_date,
             l_lead_time,
             mcb.wip_supply_type,
             mcb.LINE_ID,
             mcb.parent_line_id,
             mcb.TOP_MODEL_LINE_ID,
             mcb.ATO_PARENT_MODEL_LINE_ID,
             mcb.ATO_MODEL_LINE_ID,
             mcb.MATCH_ITEM_ID,
             mcb.BOM_ITEM_TYPE,
             mcb.quantity,
             NVL(msi.fixed_lead_time, 0),
             NVL(msi.variable_lead_time, 0),
             mcb.oss_error_code,
             msi.atp_flag,
             msi.atp_components_flag,
             msi.aggregate_time_fence_date, -- For time_phased_atp
             msi.inventory_item_id,
             msi.uom_code, --bug3110023
             mbc.usage_quantity*mbc.component_yield_factor, --4775920
             NVL (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,1) --4775920
    BULK COLLECT INTO
             p_comp_rec.inventory_item_id,
             p_comp_rec.comp_usage,
             p_comp_rec.requested_date,
             p_comp_rec.lead_time,
             p_comp_rec.wip_supply_type,
             p_comp_rec.assembly_identifier,
             p_comp_rec.parent_line_id,
             p_comp_rec.TOP_MODEL_LINE_ID,
             p_comp_rec.ATO_PARENT_MODEL_LINE_ID,
             p_comp_rec.ATO_MODEL_LINE_ID,
             p_comp_rec.MATCH_ITEM_ID,
             p_comp_rec.BOM_ITEM_TYPE,
             p_comp_rec.parent_so_quantity,
             p_comp_rec.fixed_lt,
             p_comp_rec.variable_lt,
             p_comp_rec.oss_error_code,
             p_comp_rec.atp_flag,
             p_comp_rec.atp_components_flag,
             p_comp_rec.atf_date, -- For time_phased_atp
             p_comp_rec.dest_inventory_item_id,
             p_comp_rec.comp_uom, --bug3110023
             p_comp_rec.usage_qty, --4775920
             p_comp_rec.organization_type --4775920
    FROM  msc_cto_bom mcb,
          msc_calendar_dates c1,
          msc_calendar_dates c2,
          msc_trading_partners tp,
          msc_system_items msi,
          msc_bom_components mbc,
          MSC_OPERATION_COMPONENTS MOC
    WHERE mcb.session_id = p_session_id
    AND   mcb.sr_instance_id = MSC_ATP_PVT.G_INSTANCE_ID -- this is the instance id of the calling module
    AND   mcb.PARENT_LINE_ID = p_line_id
    AND   mcb.sr_inventory_item_id = msi.sr_inventory_item_id (+)
    AND   p_organization_id = msi.organization_id (+)
    AND   p_instance_id = msi.sr_instance_id (+)
    AND   p_plan_id = msi.plan_id(+)
    ---bug 3644238: truncate date else appropriate date wouldn't be found in msc_calendar tables.
    AND   c1.calendar_date = trunc(p_request_date)
    AND   c1.sr_instance_id = tp.sr_instance_id
    AND   c1.calendar_code = tp.calendar_code
    AND   c1.exception_set_id = tp.calendar_exception_set_id
    AND   tp.sr_instance_id = p_instance_id -- instance id of the org id from which we are calling
    AND   tp.sr_tp_id = p_organization_id
    AND   tp.partner_type = 3
    AND   c2.seq_num = c1.prior_seq_num - l_lead_time
    AND   c2.calendar_code = tp.calendar_code
    AND   c2.sr_instance_id = tp.sr_instance_id
    AND   c2.exception_set_id = tp.calendar_exception_set_id
    and   mbc.inventory_item_id = msi.inventory_item_id ---4570421
    and   mbc.plan_id = msi.plan_id
    and   mbc.sr_instance_id = msi.sr_instance_id
    and   mbc.bill_sequence_id  = l_bill_seq_id
    and   MOC.PLAN_ID(+) =  p_plan_id --4929084
    and   MOC.SR_INSTANCE_ID(+) = p_instance_id
    and   MOC.ORGANIZATION_ID(+)  = p_organization_id
    and   MOC.BILL_SEQUENCE_ID(+) = l_bill_seq_id
    and   MOC.ROUTING_SEQUENCE_ID(+) = l_routing_seq_id
    and   MOC.COMPONENT_SEQUENCE_ID(+) = mbc.COMPONENT_SEQUENCE_ID
    and   MOC.OPERATION_SEQUENCE_ID(+) = l_op_seq_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_CTO_BOM: components retrieved := ' || p_comp_rec.inventory_item_id.count);
       FOR i in 1..p_comp_rec.inventory_item_id.count LOOP
           msc_sch_wb.atp_debug('Get_CTO_BOM: Component # ' || i || ': ' || p_comp_rec.inventory_item_id(i));
           msc_sch_wb.atp_debug('Get_CTO_BOM: fixed lead time :=' || p_comp_rec.fixed_lt(i));
           msc_sch_wb.atp_debug('Get_CTO_BOM: variable lead time := ' || p_comp_rec.variable_lt(i));
           msc_sch_wb.atp_debug('Get_CTO_BOM: uom code := ' || p_comp_rec.comp_uom(i)); --bug3110023
       END LOOP;
       msc_sch_wb.atp_debug('Get_CTO_BOM: END get_cto_bom');
    END IF;

END Get_CTO_BOM;

Procedure Maintain_OS_Sourcing(p_instance_id IN Number,
                               p_atp_rec     IN MRP_ATP_PUB.atp_rec_typ,
                               p_status    IN Number)
IS
i number;
BEGIN

   IF p_status = MSC_ATP_CTO.Success THEN
      -- delete the old data
      FORALL i in 1..p_atp_rec.inventory_item_id.count
        Delete from msc_cto_sources
        where sr_instance_id = p_instance_id
        and   ato_line_id = p_atp_rec.identifier(i)
        and   status_flag = 2;

   ELSIF p_status = MSC_ATP_CTO.FAIL THEN
      --first delete the new data
      FORALL i in 1..p_atp_rec.inventory_item_id.count
        Delete from msc_cto_sources
        where sr_instance_id = p_instance_id
        and   ato_line_id = p_atp_rec.identifier(i)
        and   status_flag = 1;

      --update the status flag to 1 on the old data
      FORALL i in 1..p_atp_rec.inventory_item_id.count
         UPDATE msc_cto_sources
         set status_flag = 1
         where sr_instance_id = p_instance_id
         and ato_line_id = p_atp_rec.identifier(i)
         and status_flag = 2;

   END IF;

END Maintain_OS_Sourcing;


PROCEDURE Check_Base_Model_For_Cap_Check(p_config_inventory_item_id       IN  NUMBER,
                                              p_base_model_id             IN  NUMBER,
                                              p_request_date              IN  DATE,
                                              p_instance_id               IN  NUMBER,
                                              p_plan_id                   IN  NUMBER,
                                              p_organization_id           IN  NUMBER,
                                              p_quantity                  IN  NUMBER,
                                              x_model_sr_inv_id           OUT NOCOPY NUMBER,
                                              x_check_model_capacity_flag OUT NOCOPY NUMBER)

IS

l_process_seq_id number;
l_routing_seq_id number;
l_bill_seq_id   number;
l_op_seq_id     number; --4570421
l_return_status  varchar2(1);
l_atp_flag  varchar2(1);
l_atp_comp_flag varchar2(1);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Inside Check_Base_Model_For_Cap_Check');
  END IF;
  --first get base model's flags
  Select atp_flag, atp_components_flag, sr_inventory_item_id
  into   l_atp_flag, l_atp_comp_flag, x_model_sr_inv_id
  from   msc_system_items msi
  where  msi.inventory_item_id = p_base_model_id
  and    msi.sr_instance_id = p_instance_id
  and    msi.plan_id = p_plan_id
  and    msi.organization_id = p_organization_id;

  IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('ATP flag for base model is := ' || l_atp_flag );
       msc_sch_wb.atp_debug('ATP comp flag for base model is := ' || l_atp_comp_flag);
  END IF;

  IF NOT (l_atp_flag = 'Y' and l_atp_comp_flag = 'N') THEN

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('ATP Flag for model is set to not check just the model capacity');
     END IF;
     x_check_model_capacity_flag := 2;
  ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('ATP Flag for model is set to check the model capacity');
        msc_sch_wb.atp_debug('Check Model bom level attribute');
     END IF;

     ---- Now get the process effectivity
     MSC_ATP_PROC.get_process_effectivity(
                                p_plan_id,
                                p_config_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                p_request_date,
                                p_quantity,
                                l_process_seq_id,
                                l_routing_seq_id,
                                l_bill_seq_id,
                                l_op_seq_id, --4570421
                                l_return_status);

    IF PG_DEBUG in ('Y', 'C') THEN

        msc_sch_wb.atp_debug('After Selecting process effectivity');
        msc_sch_wb.atp_debug('l_process_seq_id := ' || l_process_seq_id);
        msc_sch_wb.atp_debug('l_routing_seq_id := ' || l_routing_seq_id);
        msc_sch_wb.atp_debug('l_bill_seq_id := ' || l_bill_seq_id);
        msc_sch_wb.atp_debug('l_op_seq_id := ' || l_op_seq_id);
        msc_sch_wb.atp_debug('l_return_status := ' || l_return_status);

    END IF;

    ---now select the bom level atp flag to see if we need need to do capacity check
    SELECT NVL(mbc.atp_flag, 2)
    INTO   x_check_model_capacity_flag
    from   msc_bom_components mbc
    where  mbc.BILL_SEQUENCE_ID = l_bill_seq_id
    and    mbc.PLAN_ID = p_plan_id
    and    mbc.SR_INSTANCE_ID = p_instance_id
    and    mbc.ORGANIZATION_ID = p_organization_id
    and    mbc.INVENTORY_ITEM_ID = p_base_model_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('After Selectng bom level atp flag');
        msc_sch_wb.atp_debug('x_check_model_capacity_flag := ' || x_check_model_capacity_flag);
    END IF;


  END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('END Check_Base_Model_For_Cap_Check');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('No data found in Check_Base_Model_For_Capacity_Check');
     END IF;

     x_check_model_capacity_flag := 2;

END Check_Base_Model_For_Cap_Check;

END MSC_ATP_CTO;

/
