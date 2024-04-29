--------------------------------------------------------
--  DDL for Package Body MRP_ATP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ATP_UTILS" AS
/* $Header: MRPUATPB.pls 115.39 2004/03/16 00:43:33 vghiya ship $  */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE put_into_temp_table(
   x_dblink		IN   VARCHAR2,
   x_session_id         IN   NUMBER,
   x_atp_rec            IN   MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  IN   MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         IN   MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        IN   MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN   NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER
   ) IS
      -- PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	MSC_ATP_UTILS.put_into_temp_table(
		x_dblink,
		x_session_id,
		x_atp_rec,
		x_atp_supply_demand,
		x_atp_period,
		x_atp_details,
		x_mode,
		x_return_status,
		x_msg_data,
		x_msg_count);
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Error in MRPUATPB.pls '||substr(sqlerrm,1,100));
      END IF;
      x_msg_data := substr(sqlerrm,1,100);
      x_return_status := FND_API.G_RET_STS_ERROR;
END put_into_temp_table;


PROCEDURE get_from_temp_table(
   x_dblink		IN    VARCHAR2,
   x_session_id         IN    NUMBER,
   x_atp_rec            OUT   NoCopy MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN    NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER
   ) IS
BEGIN
	MSC_ATP_UTILS.get_from_temp_table(
		x_dblink,
		x_session_id,
		x_atp_rec,
		x_atp_supply_demand,
		x_atp_period,
		x_atp_details,
		x_mode,
		x_return_status,
		x_msg_data,
		x_msg_count,
		1);
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END get_from_temp_table;

FUNCTION Call_ATP_11(
		     p_group_id      NUMBER,
		     p_session_id    NUMBER,
		     p_insert_flag   NUMBER,
		     p_partial_flag  NUMBER,
		     p_err_message   IN OUT NoCopy VARCHAR2)
RETURN NUMBER is

v_dummy			NUMBER := 0;
x_atp_rec               MRP_ATP_PUB.atp_rec_typ;
x_atp_rec_out           MRP_ATP_PUB.atp_rec_typ;
x_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
x_return_status         VARCHAR2(1);
x_msg_data              VARCHAR2(200);
x_msg_count             NUMBER;
x_session_id            NUMBER;

ato_exists VARCHAR2(1) := 'N';
j NUMBER;

BEGIN
    --bug 3346564: null out the function as its not used any more.
    return null;
EXCEPTION
   WHEN OTHERS THEN
      p_err_message := substr(sqlerrm,1,100);
      return(INV_EXTATP_GRP.G_RETURN_ERROR);
End Call_ATP_11;

PROCEDURE extend_mast( mast_rec     IN OUT  NoCopy mrp_atp_schedule_temp_typ,
		       x_ret_code   OUT NoCopy varchar2,
		       x_ret_status OUT NoCopy varchar2) IS
BEGIN
   mast_rec.rowid_char.extend(1);
   mast_rec.sequence_number.extend(1);
   mast_rec.firm_flag.extend(1);
   mast_rec.order_line_number.extend(1);
   mast_rec.option_number.extend(1);
   mast_rec.shipment_number.extend(1);
   mast_rec.item_desc.extend(1);
   mast_rec.customer_name.extend(1);
   mast_rec.customer_location.extend(1);
   mast_rec.ship_set_name.extend(1);
   mast_rec.arrival_set_name.extend(1);
   mast_rec.requested_ship_date.extend(1);
   mast_rec.requested_arrival_date.extend(1);
   mast_rec.old_line_schedule_date.extend(1);
   mast_rec.old_source_organization_code.extend(1);
   mast_rec.firm_source_org_id.extend(1);
   mast_rec.firm_source_org_code.extend(1);
   mast_rec.firm_ship_date.extend(1);
   mast_rec.firm_arrival_date.extend(1);
   mast_rec.ship_method_text.extend(1);
   mast_rec.ship_set_id.extend(1);
   mast_rec.arrival_set_id.extend(1);
   mast_rec.project_id.extend(1);
   mast_rec.task_id.extend(1);
   mast_rec.project_number.extend(1);
   mast_rec.task_number.extend(1);
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in extend_mast : '||Substr(Sqlerrm,1,100));
      END IF;
END extend_mast;


PROCEDURE trim_mast( mast_rec     IN OUT  NoCopy mrp_atp_schedule_temp_typ,
		       x_ret_code   OUT NoCopy varchar2,
		       x_ret_status OUT NoCopy varchar2) IS
BEGIN
   mast_rec.rowid_char.trim(1);
   mast_rec.sequence_number.trim(1);
   mast_rec.firm_flag.trim(1);
   mast_rec.order_line_number.trim(1);
   mast_rec.option_number.trim(1);
   mast_rec.shipment_number.trim(1);
   mast_rec.item_desc.trim(1);
   mast_rec.customer_name.trim(1);
   mast_rec.customer_location.trim(1);
   mast_rec.ship_set_name.trim(1);
   mast_rec.arrival_set_name.trim(1);
   mast_rec.requested_ship_date.trim(1);
   mast_rec.requested_arrival_date.trim(1);
   mast_rec.old_line_schedule_date.trim(1);
   mast_rec.old_source_organization_code.trim(1);
   mast_rec.firm_source_org_id.trim(1);
   mast_rec.firm_source_org_code.trim(1);
   mast_rec.firm_ship_date.trim(1);
   mast_rec.firm_arrival_date.trim(1);
   mast_rec.ship_method_text.trim(1);
   mast_rec.ship_set_id.trim(1);
   mast_rec.arrival_set_id.trim(1);
   mast_rec.project_id.trim(1);
   mast_rec.task_id.trim(1);
   mast_rec.project_number.trim(1);
   mast_rec.task_number.trim(1);
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in trim_mast : '||Substr(Sqlerrm,1,100));
      END IF;
END trim_mast;

PROCEDURE test(x_session_id NUMBER) IS
      j NUMBER := 1;
      l_dynstring VARCHAR2(128) := NULL;
      sql_stmt    VARCHAR2(10000);
      mast_rec mrp_atp_schedule_temp_typ;
      mast_rec_insert mrp_atp_schedule_temp_typ;
      TYPE mastcurtyp IS REF CURSOR;
      mast_cursor mastcurtyp;
      x_ret_code VARCHAR2(1);
      x_ret_status VARCHAR2(100);

BEGIN

	    sql_stmt :=
	      ' SELECT '||
	      '     rowidtochar(rowid),'||
	      '     sequence_number,'||
	      '     firm_flag,'||
	      '     order_line_number,'||
	      '     option_number,'||
	      '     shipment_number,'||
	      '     item_desc,'||
	      '     customer_name,'||
	      '     customer_location,'||
	      '     ship_set_name,'||
	      '     arrival_set_name,'||
	      '     old_line_schedule_date,'||
	      '     old_source_organization_code,'||
	      '     project_id,'||
	      '     task_id,'||
	      '     project_number,'||
	      '     task_number '||
	      '     FROM '||
	      '     mrp_atp_schedule_temp'||l_dynstring||
	      '     WHERE session_id = :x_session_id '||
	      '     AND status_flag = 1';

	    OPEN mast_cursor FOR sql_stmt using x_session_id;

	    LOOP
	       IF PG_DEBUG in ('Y', 'C') THEN
	          msc_sch_wb.atp_debug('test: ' || ' Retrieved record from mast ');
	       END IF;
	       extend_mast(mast_rec, x_ret_code, x_ret_status);
	       IF PG_DEBUG in ('Y', 'C') THEN
	          msc_sch_wb.atp_debug('test: ' || ' error code '||x_ret_status||' '||x_ret_code);
	       END IF;
	       FETCH mast_cursor INTO
		 mast_rec.rowid_char(j),
		 mast_rec.sequence_number(j),
		 mast_rec.firm_flag(j),
		 mast_rec.order_line_number(j),
		 mast_rec.option_number(j),
		 mast_rec.shipment_number(j),
		 mast_rec.item_desc(j),
		 mast_rec.customer_name(j),
		 mast_rec.customer_location(j),
		 mast_rec.ship_set_name(j),
		 mast_rec.arrival_set_name(j),
		 mast_rec.old_line_schedule_date(j),
		 mast_rec.old_source_organization_code(j),
		 mast_rec.project_id(j),
		 mast_rec.task_id(j),
		 mast_rec.project_number(j),
		 mast_rec.task_number(j);
	       EXIT WHEN mast_cursor%notfound;
	    END LOOP;
	    trim_mast(mast_rec,x_ret_code, x_ret_status);
	    IF PG_DEBUG in ('Y', 'C') THEN
	       msc_sch_wb.atp_debug('test: ' || ' Count '||mast_rec.rowid_char.COUNT);
	    END IF;

END test;


END MRP_ATP_UTILS;

/
