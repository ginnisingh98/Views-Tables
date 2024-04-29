--------------------------------------------------------
--  DDL for Package Body WSH_RLM_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RLM_INTERFACE" as
/* $Header: WSHRLMIB.pls 120.2.12000000.2 2007/04/09 10:15:31 sunilku ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RLM_INTERFACE';

g_col_tab RLM_CORE_SV.t_dynamic_tab;

PROCEDURE BuildQuery(
   p_customer_id              IN  NUMBER,
   p_ship_to_location_id      IN  NUMBER,
   p_intmed_ship_to_org_id    IN  NUMBER,--Bugfix 5911991
   p_ship_from_location_id    IN  NUMBER,
   p_inventory_item_id        IN  NUMBER,
   p_customer_item_id	      IN  NUMBER,
   p_order_header_id          IN  NUMBER,
   p_blanket_number	      IN  NUMBER,
   p_org_id                   IN  NUMBER,
   p_schedule_type	      IN  VARCHAR2,
   p_match_within_rule	      IN  RLM_CORE_SV.t_match_rec,
   p_match_across_rule	      IN  RLM_CORE_SV.t_match_rec,
   p_optional_match_rec       IN  t_optional_match_rec,
   x_c_transit_detail         OUT NOCOPY VARCHAR2)
IS
  v_select_clause             VARCHAR2(32000);
  v_where_clause              VARCHAR2(32000);
  v_request_date_str          VARCHAR2(30);
  v_schedule_date_str         VARCHAR2(30);
BEGIN
 --
 rlm_core_sv.dlog('Entering WSH_RLM_INTERFACE.BuildQuery');
 --
 -- Starting where-clause

 v_where_clause :=

 'WHERE s.stop_id = dl.pick_up_stop_id'||
 ' AND dl.delivery_id = nd.delivery_id'||
 ' AND nd.delivery_id = da.delivery_id'||
 ' AND da.delivery_detail_id = dd.delivery_detail_id'||
 ' AND s.stop_location_id = nd.initial_pickup_location_id'||
 ' AND dd.customer_id = :customer_id' ||
 ' AND dd.ship_to_location_id = :ship_to_location_id' ||
 ' AND NVL(ol.intmed_ship_to_org_id,'||k_NNULL||') = NVL(:intmed_ship_to_org_id,'||k_NNULL||')'|| --Bugfix 5911991
 ' AND dd.inventory_item_id = :inventory_item_id' ||
 ' AND dd.customer_item_id = :customer_item_id' ||
 ' AND dd.source_line_id = ol.line_id' ||
 ' AND dd.source_code = ''OE''' ||
 ' AND s.actual_departure_date IS NOT NULL' ||
 ' AND ol.shipped_quantity IS NOT NULL';

 g_col_tab(g_col_tab.COUNT+1) := p_customer_id;
 g_col_tab(g_col_tab.COUNT+1) := p_ship_to_location_id;
 g_col_tab(g_col_tab.COUNT+1) := p_intmed_ship_to_org_id; --Bugfix 5911991
 g_col_tab(g_col_tab.COUNT+1 ):= p_inventory_item_id;
 g_col_tab(g_col_tab.COUNT+1) := p_customer_item_id;
 --
 IF p_org_id IS NOT NULL THEN
  --
  v_where_clause := v_where_clause || ' AND ol.org_id = :org_id ';
  g_col_tab(g_col_tab.COUNT+1) := p_org_id;
  --
 END IF;
 --
 -- global_atp
 IF p_ship_from_location_id IS NOT NULL THEN

   v_where_clause := v_where_clause ||
   ' AND dd.ship_from_location_id = :ship_from_location_id';

   g_col_tab(g_col_tab.COUNT+1):=p_ship_from_location_id;

 END IF;

 v_request_date_str := TO_CHAR(p_optional_match_rec.request_date,'RRRR/MM/DD HH24:MI:SS');
 v_schedule_date_str := TO_CHAR(p_optional_match_rec.schedule_date,'RRRR/MM/DD HH24:MI:SS');



 IF p_match_across_rule.request_date = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND dd.date_requested = TO_DATE(:v_request_date_str,''RRRR/MM/DD HH24:MI:SS'')';

   g_col_tab(g_col_tab.COUNT+1):=v_request_date_str;
   --
 ELSE
   --
   IF p_match_within_rule.request_date = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND dd.date_requested = DECODE(ol.rla_schedule_type_code, :schedule_type, TO_DATE(:v_request_date_str,''RRRR/MM/DD HH24:MI:SS'')'||', dd.date_requested)';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=v_request_date_str;
     --
   END IF;
   --
 END IF;
 --
 IF p_match_across_rule.schedule_date = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND dd.date_scheduled = TO_DATE(:v_schedule_date_str,''RRRR/MM/DD HH24:MI:SS'')';

   g_col_tab(g_col_tab.COUNT+1):=v_schedule_date_str;
   --
 ELSE
   --
   IF p_match_within_rule.schedule_date = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND dd.date_scheduled = DECODE(ol.rla_schedule_type_code,:schedule_typ, TO_DATE(:v_schedule_date_str,''RRRR/MM/DD HH24:MI:SS'')'||', dd.date_scheduled)';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=v_schedule_date_str;
     --
   END IF;
   --
 END IF;
 --


 IF p_match_across_rule.cust_production_line = 'Y' THEN
   --
    v_where_clause := v_where_clause ||
     ' AND NVL(ol.customer_production_line,'''||k_VNULL||
     ''') = NVL(:cust_production_line,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_production_line;

   --
 ELSE
   --
   IF p_match_within_rule.cust_production_line = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.customer_production_line,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:cust_production_line,'''||k_VNULL||'''), NVL(ol.customer_production_line,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_production_line;
     --
   END IF;
   --
 END IF;


 --
 IF p_match_across_rule.customer_dock_code = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.customer_dock_code,'''||k_VNULL||''') = NVL(:customer_dock_code,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_dock_code;
   --
 ELSE
   --
   IF p_match_within_rule.customer_dock_code = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.customer_dock_code,'''||k_VNULL||''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:customer_dock_code,'''||k_VNULL||'''),NVL(dd.customer_dock_code,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_dock_code;

     --
   END IF;
   --
 END IF;

 --
 IF p_match_across_rule.cust_po_number = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.cust_po_number,'''||k_VNULL||''') = NVL(:cust_po_number,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_po_number;
   --
 ELSE
   --
   IF p_match_within_rule.cust_po_number = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.cust_po_number,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:cust_po_number,'''||k_VNULL||'''),NVL(dd.cust_po_number,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_po_number;

     --
   END IF;
   --
 END IF;

 --
 IF p_match_across_rule.customer_item_revision = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.revision,'''||k_VNULL||''') = NVL(:customer_item_revision,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_item_revision;
   --
 ELSE
   --
   IF p_match_within_rule.customer_item_revision = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.revision,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:customer_item_revision,'''||k_VNULL||'''),NVL(dd.revision,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_item_revision;

     --
   END IF;
   --
 END IF;
 --

 --
 IF p_match_across_rule.customer_job = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.customer_job,'''||k_VNULL||''') = NVL(:customer_job,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_job;
   --
 ELSE
   --
   IF p_match_within_rule.customer_job = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.customer_job,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:customer_job,'''||k_VNULL||'''),NVL(ol.customer_job,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.customer_job;

     --
   END IF;
   --
 END IF;
 --


 --
 IF p_match_across_rule.cust_model_serial_number = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.cust_model_serial_number,'''||k_VNULL||''') = NVL(:cust_model_serial_number,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_model_serial_number;
   --
 ELSE
   --
   IF p_match_within_rule.cust_model_serial_number = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.cust_model_serial_number,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:cust_model_serial_number,'''||k_VNULL||'''),NVL(ol.cust_model_serial_number,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_model_serial_number;

     --
   END IF;
   --
 END IF;
 --

 --
 IF p_match_across_rule.cust_production_seq_num = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.customer_prod_seq,'''||k_VNULL||''') = NVL(:cust_production_seq_num,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_production_seq_num;
   --
 ELSE
   --
   IF p_match_within_rule.cust_production_seq_num = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.customer_prod_seq,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:cust_production_seq_num,'''||k_VNULL||'''),NVL(dd.customer_prod_seq,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.cust_production_seq_num;

     --
   END IF;
   --
 END IF;
 --

 --
 IF p_match_across_rule.industry_attribute1 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute1,'''||k_VNULL||''') = NVL(:industry_attribute1,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute1;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute1 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute1,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute1,'''||k_VNULL||'''),NVL(ol.industry_attribute1,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute1;

     --
   END IF;
   --
 END IF;
 --
--
 IF p_match_across_rule.industry_attribute2 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute2,'''||k_VNULL||''') = NVL(:industry_attribute2,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute2;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute2 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute2,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute2,'''||k_VNULL||'''),NVL(ol.industry_attribute2,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute2;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute4 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute4,'''||k_VNULL||''') = NVL(:industry_attribute4,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute4;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute4 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute4,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute4,'''||k_VNULL||'''),NVL(ol.industry_attribute4,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute4;

     --
   END IF;
   --
 END IF;
 --

 --
 IF p_match_across_rule.industry_attribute5 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute5,'''||k_VNULL||''') = NVL(:industry_attribute5,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute5;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute5 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute5,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute5,'''||k_VNULL||'''),NVL(ol.industry_attribute5,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute5;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute6 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute6,'''||k_VNULL||''') = NVL(:industry_attribute6,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute6;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute6 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute6,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute6,'''||k_VNULL||'''),NVL(ol.industry_attribute6,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute6;

     --
   END IF;
   --
 END IF;
 --

 --
 IF p_match_across_rule.industry_attribute10 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute10,'''||k_VNULL||''') = NVL(:industry_attribute10,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute10;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute10 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute10,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute10,'''||k_VNULL||'''),NVL(ol.industry_attribute10,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute10;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute11 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute11,'''||k_VNULL||''') = NVL(:industry_attribute11,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute11;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute11 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute11,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute11,'''||k_VNULL||'''),NVL(ol.industry_attribute11,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute11;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute12 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute12,'''||k_VNULL||''') = NVL(:industry_attribute12,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute12;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute12 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute12,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute12,'''||k_VNULL||'''),NVL(ol.industry_attribute12,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute12;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute13 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute13,'''||k_VNULL||''') = NVL(:industry_attribute13,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute13;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute13 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute13,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute13,'''||k_VNULL||'''),NVL(ol.industry_attribute13,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute13;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.industry_attribute14 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(ol.industry_attribute14,'''||k_VNULL||''') = NVL(:industry_attribute14,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute14;
   --
 ELSE
   --
   IF p_match_within_rule.industry_attribute14 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(ol.industry_attribute14,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute14,'''||k_VNULL||'''),NVL(ol.industry_attribute14,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.industry_attribute14;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute1 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute1,'''||k_VNULL||''') = NVL(:attribute1,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute1;
   --
 ELSE
   --
   IF p_match_within_rule.attribute1 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute1,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute1,'''||k_VNULL||'''),NVL(dd.attribute1,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute1;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute2 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute2,'''||k_VNULL||''') = NVL(:attribute2,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute2;
   --
 ELSE
   --
   IF p_match_within_rule.attribute2 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute2,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute2,'''||k_VNULL||'''),NVL(dd.attribute2,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute2;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute3 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute3,'''||k_VNULL||''') = NVL(:attribute3,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute3;
   --
 ELSE
   --
   IF p_match_within_rule.attribute3 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute3,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute3,'''||k_VNULL||'''),NVL(dd.attribute3,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute3;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute4 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute4,'''||k_VNULL||''') = NVL(:attribute4,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute4;
   --
 ELSE
   --
   IF p_match_within_rule.attribute4 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute4,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute4,'''||k_VNULL||'''),NVL(dd.attribute4,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute4;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute5 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute5,'''||k_VNULL||''') = NVL(:attribute5,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute5;
   --
 ELSE
   --
   IF p_match_within_rule.attribute5 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute5,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute5,'''||k_VNULL||'''),NVL(dd.attribute5,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute5;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute6 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute6,'''||k_VNULL||''') = NVL(:attribute6,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute6;
   --
 ELSE
   --
   IF p_match_within_rule.attribute6 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute6,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute6,'''||k_VNULL||'''),NVL(dd.attribute6,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute6;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute7 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute7,'''||k_VNULL||''') = NVL(:attribute7,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute7;
   --
 ELSE
   --
   IF p_match_within_rule.attribute7 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute7,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute7,'''||k_VNULL||'''),NVL(dd.attribute7,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute7;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute8 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute8,'''||k_VNULL||''') = NVL(:attribute8,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute8;
   --
 ELSE
   --
   IF p_match_within_rule.attribute8 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute8,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute8,'''||k_VNULL||'''),NVL(dd.attribute8,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute8;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute9 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute9,'''||k_VNULL||''') = NVL(:attribute9,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute9;
   --
 ELSE
   --
   IF p_match_within_rule.attribute9 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute9,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute9,'''||k_VNULL||'''),NVL(dd.attribute9,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute9;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute10 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute10,'''||k_VNULL||''') = NVL(:attribute10,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute10;
   --
 ELSE
   --
   IF p_match_within_rule.attribute10 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute10,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute10,'''||k_VNULL||'''),NVL(dd.attribute10,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute10;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute11 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute11,'''||k_VNULL||''') = NVL(:attribute11,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute11;
   --
 ELSE
   --
   IF p_match_within_rule.attribute11 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute11,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute11,'''||k_VNULL||'''),NVL(dd.attribute11,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute11;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute12 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute12,'''||k_VNULL||''') = NVL(:attribute12,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute12;
   --
 ELSE
   --
   IF p_match_within_rule.attribute12 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute12,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute12,'''||k_VNULL||'''),NVL(dd.attribute12,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute12;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute13 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute13,'''||k_VNULL||''') = NVL(:attribute13,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute13;
   --
 ELSE
   --
   IF p_match_within_rule.attribute13 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute13,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute13,'''||k_VNULL||'''),NVL(dd.attribute13,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute13;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute14 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute14,'''||k_VNULL||''') = NVL(:attribute14,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute14;
   --
 ELSE
   --
   IF p_match_within_rule.attribute14 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute14,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute14,'''||k_VNULL||'''),NVL(dd.attribute14,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute14;

     --
   END IF;
   --
 END IF;
 --
 --
 IF p_match_across_rule.attribute15 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(dd.attribute15,'''||k_VNULL||''') = NVL(:attribute15,'''||k_VNULL||''')';

   g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute15;
   --
 ELSE
   --
   IF p_match_within_rule.attribute15 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(dd.attribute15,'''||k_VNULL||
       ''')  = DECODE(ol.rla_schedule_type_code, :schedule_type, NVL(:attribute15,'''||k_VNULL||'''),NVL(dd.attribute15,'''||k_VNULL||'''))';

     g_col_tab(g_col_tab.COUNT+1):=p_schedule_type;
     g_col_tab(g_col_tab.COUNT+1):=p_optional_match_rec.attribute15;

     --
   END IF;
   --
 END IF;
 --

/*end of matching attributes*/

 --
 IF p_blanket_number = k_NNULL THEN
   --
   v_select_clause :=

   'SELECT dd.delivery_detail_id,s.stop_id,s.actual_departure_date,'||
   'nd.name,dd.shipped_quantity, NULL, ol.ordered_item_id, ol.header_id order_hdr_id '||
   'FROM wsh_delivery_Details dd,wsh_trip_stops s,wsh_delivery_legs dl,'||
   'wsh_delivery_assignments_v da,wsh_new_deliveries nd,oe_order_lines_all ol ';
   --
   v_where_clause := v_where_clause ||
   ' AND dd.source_header_id = :order_header_id';

   g_col_tab(g_col_tab.COUNT+1):=p_order_header_id;


   --
 ELSE
   --
   v_select_clause :=

   'SELECT dd.delivery_detail_id,s.stop_id,s.actual_departure_date,'||
   'nd.name,dd.shipped_quantity,ol.blanket_number,ol.ordered_item_id,'||
   'ol.header_id order_hdr_id '||
   'FROM wsh_delivery_Details dd,wsh_trip_stops s,wsh_delivery_legs dl,'||
   'wsh_delivery_assignments_v da,wsh_new_deliveries nd,oe_order_lines_all ol ';
   --
   v_where_clause := v_where_clause ||
   ' AND ol.blanket_number = :blanket_number' ||
   ' AND dd.source_header_id IN (select rso_hdr_id FROM rlm_blanket_rso '||
   ' WHERE blanket_number = :blanket_number' ||
   ' AND customer_id = dd.customer_id '||
   ' AND (customer_item_id = dd.customer_item_id '||
   ' OR	customer_item_id = '''|| k_NNULL|| '''))';

   g_col_tab(g_col_tab.COUNT+1):=p_blanket_number;
   g_col_tab(g_col_tab.COUNT+1):=p_blanket_number;

 END IF;
 --
 x_c_transit_detail := v_select_clause || v_where_clause;
 --
 rlm_core_sv.dlog('g_col_tab.count', g_col_tab.COUNT);
 rlm_core_sv.dlog('x_c_transit_detail', substr(x_c_transit_detail,1,800));
 rlm_core_sv.dlog('x_c_transit_detail Contd.', substr(x_c_transit_detail,801,1600));
 rlm_core_sv.dlog('x_c_transit_detail Contd.', substr(x_c_transit_detail,1601,2400));
 rlm_core_sv.dlog('x_c_transit_detail Contd.', substr(x_c_transit_detail,2401,3200));
 rlm_core_sv.dlog('x_c_transit_detail Contd.', substr(x_c_transit_detail,3201,4000));
 rlm_core_sv.dlog('Exiting WSH_RLM_INTERFACE.BuildQuery');
 --
EXCEPTION
  --
  WHEN OTHERS THEN
    rlm_core_sv.dlog('When others exception');
    RAISE;

END BuildQuery;

PROCEDURE Get_In_Transit_Qty(
   p_source_code              IN  VARCHAR2 DEFAULT 'OE',
   p_customer_id              IN  NUMBER,
   p_ship_to_org_id           IN  NUMBER,
   p_intmed_ship_to_org_id    IN  NUMBER, --Bugfix 5911991
   p_ship_from_org_id         IN  NUMBER,
   p_inventory_item_id        IN  NUMBER,
   p_customer_item_id	      IN  NUMBER,
   p_order_header_id          IN  NUMBER,
   p_blanket_number           IN  NUMBER,
   p_org_id                   IN  NUMBER DEFAULT NULL,
   p_schedule_type	      IN  VARCHAR2,
   p_shipper_recs             IN  t_shipper_rec,
   p_shipment_date            IN  DATE,
   p_match_within_rule	      IN  RLM_CORE_SV.t_match_rec,
   p_match_across_rule	      IN  RLM_CORE_SV.t_match_rec,
   p_optional_match_rec       IN  t_optional_match_rec,
   x_in_transit_qty           OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY   VARCHAR2)

IS
   --
   l_ship_to_location_id 	NUMBER;
   l_ship_from_location_id 	NUMBER;
   invalid_org 			EXCEPTION;
   invalid_cust_site 		EXCEPTION;
   l_location_status 		VARCHAR2(30);
   l_total_qty_in_transit 	NUMBER;
   l_departure_date 		DATE;
   l_latest_departure_date 	DATE;
   --
   CURSOR c_get_actual_departure_date(c_del_name VARCHAR ) IS
   SELECT MIN(STP.ACTUAL_DEPARTURE_DATE)
   FROM WSH_TRIP_STOPS STP
   WHERE STP.STOP_ID in
        	( SELECT distinct(LEG.PICK_UP_STOP_ID)
          	  FROM
	            WSH_DELIVERY_DETAILS             DET,
        	    WSH_NEW_DELIVERIES               DEL,
            	    WSH_DELIVERY_LEGS                LEG,
	            wsh_delivery_assignments_v         ASG
        	   WHERE
		    DEL.DELIVERY_ID                 = ASG.DELIVERY_ID AND
         	    ASG.DELIVERY_DETAIL_ID          = DET.DELIVERY_DETAIL_ID AND
         	    LEG.DELIVERY_ID                 = DEL.DELIVERY_ID AND
	 	    DEL.NAME                        = c_del_name
         	)
   AND STP.ACTUAL_DEPARTURE_DATE IS NOT NULL;
   --
   TYPE t_transit_detail IS RECORD(
     delivery_detail_id    NUMBER,
     stop_id               NUMBER,
     actual_departure_date DATE,
     name                  VARCHAR2(30),
     shipped_quantity      NUMBER,
     blanket_number        NUMBER,
     ordered_item_id       NUMBER,
     order_hdr_id          NUMBER
   );
   --
   l_transit_detail 		t_transit_detail;
   x_c_transit_detail           VARCHAR2(32000);
   --
   TYPE t_Cursor_ref IS REF CURSOR;
   c_transit_detail             t_Cursor_ref;
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_IN_TRANSIT_QTY';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_ORG_ID',P_SHIP_TO_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INTMED_SHIP_TO_ORG_ID',P_INTMED_SHIP_TO_ORG_ID);  --Bugfix 5911991
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG_ID',P_SHIP_FROM_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ITEM_ID',P_CUSTOMER_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_BLANKET_NUMBER',P_BLANKET_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_TYPE',P_SCHEDULE_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_DATE',P_SHIPMENT_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUST_PRODUCTION_LINE',P_OPTIONAL_MATCH_REC.CUST_PRODUCTION_LINE);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUSTOMER_DOCK_CODE',P_OPTIONAL_MATCH_REC.CUSTOMER_DOCK_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUST_PO_NUMBER',P_OPTIONAL_MATCH_REC.CUST_PO_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUSTOMER_JOB',P_OPTIONAL_MATCH_REC.CUSTOMER_JOB);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUST_MODEL_SERIAL_NUMBER',P_OPTIONAL_MATCH_REC.CUST_MODEL_SERIAL_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_OPTIONAL_MATCH_REC.CUST_PRODUCTION_SEQ_NUM',P_OPTIONAL_MATCH_REC.CUST_PRODUCTION_SEQ_NUM);
   END IF;
   --
   rlm_core_sv.dlog('Entering WSH_RLM_INTERFACE.Get_In_Transit_Qty');
   rlm_core_sv.dlog('Blanket Number = ' || p_blanket_number);
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_total_qty_in_transit := 0;
   --
   IF p_ship_from_org_id IS NULL THEN
     -- global_atp
     l_ship_from_location_id := NULL;
     l_location_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     --
     rlm_core_sv.dlog('Intransit Calculation for ATP Item');
   ELSE
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.get_location_id('ORG',p_ship_from_org_id,
	  			   l_ship_from_location_id,
				   l_location_status,
                                   FALSE);
   END IF;

   IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       IF (l_location_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
        AND (l_ship_from_location_id IS NULL) THEN
           x_in_transit_qty := 0 ;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'X_INTRANSIT_QTY',
                                                          x_in_transit_qty);
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
       ELSE
           raise INVALID_ORG;
       END IF;
   END IF;

   IF p_source_code = 'OE' THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.get_location_id('CUSTOMER SITE',p_ship_to_org_id,
				      l_ship_to_location_id,
				      l_location_status,
                                      FALSE);
      --
      IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF (l_location_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
          AND (l_ship_to_location_id IS NULL) THEN
             x_in_transit_qty := 0 ;
             x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'X_INTRANSIT_QTY', x_in_transit_qty);
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             RETURN;
         ELSE
             raise invalid_cust_site;
         END IF;
      END IF;

	IF (p_shipper_Recs.shipper_id1 is not null) THEN
            --
	    rlm_core_sv.dlog('Shipper ID1 = ' || p_shipper_Recs.shipper_id1);
            OPEN c_get_actual_departure_date(p_shipper_Recs.shipper_id1);
	    FETCH c_get_actual_departure_date INTO l_departure_date;
	    CLOSE c_get_actual_departure_date;
	    IF l_departure_date IS NOT NULL THEN
	       l_latest_departure_date := l_departure_date;
            END IF;
	    --
      	END IF;

	IF (p_shipper_Recs.shipper_id2 is not null) THEN
	   --
	   rlm_core_sv.dlog('Shipper ID2 = '|| p_shipper_Recs.shipper_id2);
	   l_departure_date := NULL;
	   OPEN c_get_actual_departure_date(p_shipper_Recs.shipper_id2);
	   FETCH c_get_actual_departure_date INTO l_departure_date;
	   CLOSE c_get_actual_departure_date;
	   l_latest_departure_date := NVL(l_latest_departure_date, l_departure_date);
	   IF l_departure_date IS NOT NULL AND
		  l_departure_date > l_latest_departure_date THEN
	      l_latest_departure_date := l_departure_date;
	   END IF;
           --
      	END IF;

	IF (p_shipper_Recs.shipper_id3 is not null) THEN
           --
	   rlm_core_sv.dlog('Shipper ID3 = '|| p_shipper_Recs.shipper_id3);
	   l_departure_date := NULL;
	   OPEN c_get_actual_departure_date(p_shipper_Recs.shipper_id3);
	   FETCH c_get_actual_departure_date INTO l_departure_date;
	   CLOSE c_get_actual_departure_date;
	   l_latest_departure_date := NVL(l_latest_departure_date, l_departure_date);
	   IF l_departure_date > l_latest_departure_date  THEN
		l_latest_departure_date := l_departure_date;
           END IF;
	   --
	END IF;

	IF (p_shipper_Recs.shipper_id4 is not null) THEN
           --
	   rlm_core_sv.dlog('Shipper ID4 = '|| p_shipper_Recs.shipper_id4);
	   l_departure_date := NULL;
	   OPEN c_get_actual_departure_date(p_shipper_Recs.shipper_id4);
	   FETCH c_get_actual_departure_date INTO l_departure_date;
	   CLOSE c_get_actual_departure_date;
	   l_latest_departure_date := NVL(l_latest_departure_date, l_departure_date);
	   IF l_departure_date > l_latest_departure_date THEN
		l_latest_departure_date := l_departure_date;
	   END IF;
	   --
	END IF;

	IF (p_shipper_Recs.shipper_id5 is not null) THEN
	   --
	   rlm_core_sv.dlog('Shipper ID5 = '|| p_shipper_Recs.shipper_id5);
	   l_departure_date := NULL;
	   OPEN c_get_actual_departure_date(p_shipper_Recs.shipper_id5);
	   FETCH c_get_actual_departure_date INTO l_departure_date;
	   CLOSE c_get_actual_departure_date;
	   l_latest_departure_date := NVL(l_latest_departure_date, l_departure_date);
	   IF l_departure_date is not NULL and
		  l_departure_date > l_latest_departure_date THEN
	     l_latest_departure_date := l_departure_date;
	   END IF;
	   --
	END IF;

	IF (l_latest_departure_date IS NULL) AND (p_shipment_date IS NOT NULL) THEN
            l_latest_departure_date := p_shipment_date;
        END IF;
	--
	rlm_core_sv.dlog('Latest Departure date ' ||
		to_char(l_latest_departure_date, 'MM/DD/YYYY HH24:MI:SS'));
        --
        IF (l_latest_departure_date IS NOT NULL ) THEN
          --
          rlm_core_sv.dlog('Get intransits for this Order : ' || p_order_header_id);
	  --
          g_col_tab.DELETE; /* Bug 2946919 */
          --
          BuildQuery(p_customer_id,
                     l_ship_to_location_id,
                     p_intmed_ship_to_org_id,--Bugfix 5911991
                     l_ship_from_location_id,
                     p_inventory_item_id,
                     p_customer_item_id,
                     p_order_header_id,
                     p_blanket_number,
                     p_org_id,
                     p_schedule_type,
                     p_match_within_rule,
                     p_match_across_rule,
                     p_optional_match_rec,
                     x_c_transit_detail);
          --
          RLM_CORE_SV.OpenDynamicCursor(c_transit_detail,x_c_transit_detail,g_col_tab);
          --
          FETCH c_transit_detail INTO l_transit_detail;
          --
          WHILE c_transit_detail%FOUND LOOP
            --
	    rlm_core_sv.dlog('Delivery name ' || l_transit_detail.name);
	    rlm_core_sv.dlog('Actual dep date ' ||
		to_char(l_transit_detail.actual_departure_date, 'MM/DD/YYYY HH24:MI:SS'));
     	    rlm_core_sv.dlog('Quantity shipped ' || l_transit_detail.shipped_quantity);
	    --
	    IF l_transit_detail.actual_departure_date > l_latest_departure_date THEN
	       --
	       l_total_qty_in_transit := l_total_qty_in_transit + l_transit_detail.shipped_quantity;
	       --
	    END IF;
	    --
	    FETCH c_transit_Detail INTO l_transit_Detail;
	    --
	  END LOOP;
          --
	  CLOSE c_transit_detail;
	  --
   	  x_in_transit_qty := l_total_qty_in_transit;
	  --
        ELSE
	   --
	   x_in_transit_qty := 0;
	   --
        END IF;

     ELSE
	--
   	x_in_transit_qty := 0;
	--
     END IF;  /* source code = 'OE' */
     --
     rlm_core_sv.dlog('intransit qty = '|| x_in_transit_qty);
     rlm_core_sv.dlog('Exiting WSH_RLM_INTERFACE.get_in_transit_qty');
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'X_INTRANSIT_QTY',x_in_transit_qty);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
EXCEPTION

   WHEN invalid_org THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_ORG');
	 WSH_UTIL_CORE.add_message (x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_ORG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_ORG');
	 END IF;
	 --
   WHEN invalid_cust_site THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_SITE');
	 WSH_UTIL_CORE.add_message (x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_CUST_SITE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_CUST_SITE');
	 END IF;
	 --
   WHEN others THEN
	 wsh_util_core.default_handler('WSH_RLM_INTERFACE.Get_In_Transit_Qty');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_In_Transit_Qty;


END WSH_RLM_INTERFACE;

/
