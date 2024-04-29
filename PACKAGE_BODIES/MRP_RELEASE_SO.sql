--------------------------------------------------------
--  DDL for Package Body MRP_RELEASE_SO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_RELEASE_SO" AS
/*$Header: MRPRLSOB.pls 120.1.12010000.2 2008/12/12 15:50:00 eychen ship $ */

PROCEDURE release_so_program
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_batch_id IN NUMBER,
p_dblink in varchar2,
p_instance_id in number
) IS

 TYPE type_cursor IS REF CURSOR;
 so_cursor type_cursor;
 sql_stmt varchar2(2000);
 x_return_status varchar2(1) :=FND_API.G_RET_STS_SUCCESS;
 x_crm_return_status varchar2(1) :=FND_API.G_RET_STS_SUCCESS;
 a number;
 p_so_table OE_SCHEDULE_GRP.Sch_Tbl_Type;
 p_crm_so_table AHL_LTP_ASCP_ORDERS_PVT.Sched_Orders_Tbl;

 CURSOR header_c(p_line_id number) is
  select header_id
    from oe_order_lines
   where line_id = p_line_id;


 CURSOR populate_ou(p_line_id number)  is
  select org_id
  from oe_order_lines_all
  where line_id = p_line_id;

 p_status number;
 p_user_name varchar2(30) :=FND_PROFILE.VALUE('USERNAME');
 p_need_notify boolean := false;
 p_request_id number;
 l_file_name varchar2(1000);
 so_count number :=0;
 crm_so_count number :=0;
begin



  FND_FILE.PUT_LINE(FND_FILE.LOG, 'batch_id='||p_batch_id||', instance_id='||p_instance_id||', dblink='||p_dblink);

 retcode :=0;

-- release so with source_type = null thru oe package
 sql_stmt:=
   ' select schedule_ship_date,'||
          ' schedule_arrival_date,'||
          ' earliest_ship_date, '||
          ' header_id,'||
          ' line_id,'||
          ' org_id,'||
          ' operating_unit,'||
          ' delivery_lead_time,'||
          ' ship_method, '||
          ' orig_schedule_ship_date,'||
          ' orig_schedule_arrival_date,'||
          ' orig_org_id,'||
          ' orig_ship_method, '||
          ' quantity, '||
          ' decode(firm_flag,1,''Y'',''N''), '||
          ' orig_item_id, '||
          ' inventory_item_id '||
 ' from msc_sales_order_interface'||p_dblink||
 ' where sr_instance_id = : p_instance_id '||
   ' and source_type is null '||
   ' and batch_id = :p_batch_id ';

   a :=1;
   OPEN so_cursor FOR sql_stmt using p_instance_id, p_batch_id;
   LOOP
      FETCH so_cursor INTO p_so_table(a).schedule_ship_date,
                        p_so_table(a).schedule_arrival_date,
                        p_so_table(a).earliest_ship_date,
                        p_so_table(a).header_id,
                        p_so_table(a).line_id,
                        p_so_table(a).Ship_from_org_id,
                        p_so_table(a).org_id,
                        p_so_table(a).delivery_lead_time,
                        p_so_table(a).shipping_method_code,
                        p_so_table(a).orig_schedule_ship_date,
                        p_so_table(a).orig_schedule_arrival_date,
                        p_so_table(a).orig_ship_from_org_id,
                        p_so_table(a).orig_shipping_method_code,
                        p_so_table(a).orig_ordered_quantity,
                        p_so_table(a).firm_demand_flag,
                        p_so_table(a).orig_inventory_item_id,
                        p_so_table(a).inventory_item_id;
       EXIT WHEN so_cursor%NOTFOUND;
       so_count := so_count +1;
FND_FILE.PUT_LINE(FND_FILE.LOG,'schedule_ship_date='||to_char(p_so_table(a).schedule_ship_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'schedule_arrival_date='||to_char(p_so_table(a).schedule_arrival_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'earliest_ship_date='||to_char(p_so_table(a).earliest_ship_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'line_id='||p_so_table(a).line_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Ship_from_org_id='||p_so_table(a).Ship_from_org_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'delivery_lead_time='||p_so_table(a).delivery_lead_time);
FND_FILE.PUT_LINE(FND_FILE.LOG,'shipping_method_code='||p_so_table(a).shipping_method_code);
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_schedule_ship_date='||to_char(p_so_table(a).orig_schedule_ship_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_schedule_arrival_date='||to_char(p_so_table(a).orig_schedule_arrival_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_ship_from_org_id='||p_so_table(a).orig_ship_from_org_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_shipping_method_code='||p_so_table(a).orig_shipping_method_code);
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_ordered_quantity='||p_so_table(a).orig_ordered_quantity);
FND_FILE.PUT_LINE(FND_FILE.LOG,'firm_demand_flag='||p_so_table(a).firm_demand_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'orig_inventory_item_id='||p_so_table(a).orig_inventory_item_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'inventory_item_id='||p_so_table(a).inventory_item_id);
       if p_so_table(a).header_id is null then
          OPEN header_c(p_so_table(a).line_id);
          FETCH header_c INTO p_so_table(a).header_id;
          CLOSE header_c;
FND_FILE.PUT_LINE(FND_FILE.LOG,'header_id='||p_so_table(a).header_id);
       end if;


     -- populating correct OU
          OPEN populate_ou(p_so_table(a).line_id);
          FETCH populate_ou INTO p_so_table(a).org_id;
          CLOSE populate_ou;
FND_FILE.PUT_LINE(FND_FILE.LOG,'org_id='||p_so_table(a).org_id);

       a := a+1;
   END LOOP;
   CLOSE so_cursor;

-- release so with source_type =100 thru crm package
 sql_stmt:=
   ' select schedule_ship_date,'||
          ' schedule_arrival_date,'||
          ' earliest_ship_date, '||
          ' header_id,'||
          ' line_id,'||
          ' org_id,'||
          ' quantity '||
 ' from msc_sales_order_interface'||p_dblink||
 ' where sr_instance_id = : p_instance_id '||
   ' and source_type =100 '||
   ' and batch_id = :p_batch_id ';

   a :=1;
   OPEN so_cursor FOR sql_stmt using p_instance_id, p_batch_id;
   LOOP
      FETCH so_cursor INTO p_crm_so_table(a).schedule_ship_date,
                        p_crm_so_table(a).schedule_arrival_date,
                        p_crm_so_table(a).earliest_ship_date,
                        p_crm_so_table(a).header_id,
                        p_crm_so_table(a).order_line_id,
                        p_crm_so_table(a).org_id,
                        p_crm_so_table(a).quantity_by_due_date;
       EXIT WHEN so_cursor%NOTFOUND;
       crm_so_count := crm_so_count +1;
FND_FILE.PUT_LINE(FND_FILE.LOG,'schedule_ship_date='||to_char(p_crm_so_table(a).schedule_ship_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'schedule_arrival_date='||to_char(p_crm_so_table(a).schedule_arrival_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'earliest_ship_date='||to_char(p_crm_so_table(a).earliest_ship_date,'MM-DD-RRRR HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'line_id='||p_crm_so_table(a).order_line_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'org_id='||p_crm_so_table(a).org_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'qty='||p_crm_so_table(a).quantity_by_due_date);
       a := a+1;
   END LOOP;
   CLOSE so_cursor;

  if p_dblink is not null and p_dblink <> ' ' then
            commit;
            begin
               sql_stmt:= ' alter session close database link '||
                                    ltrim(p_dblink,'@');
               execute immediate sql_stmt;
            exception when others then
                 null;
            end;
  end if;



   IF p_so_table.count > 0 then
         mo_global.init('ONT');
         OE_SCHEDULE_GRP.Update_Scheduling_Results(
              p_so_table,
              p_batch_id,
              x_return_status);
         commit;
   END IF;



   IF p_crm_so_table.count >0 then
      AHL_LTP_ASCP_ORDERS_PVT.Update_Scheduling_Results(
              1.0,
              FND_API.g_false,
              FND_API.g_false,
              FND_API.g_valid_level_full,
              p_crm_so_table,
              x_crm_return_status);
       commit;
   END IF;


      -- send workflow notification for the failed so
   for a in 1..so_count loop
      if nvl(p_so_table(a).x_return_status, FND_API.G_RET_STS_ERROR) <>
             FND_API.G_RET_STS_SUCCESS or
         p_so_table(a).x_override_atp_date_code = 'Y' then
            sql_stmt:=
                ' update msc_sales_order_interface'||p_dblink||
                 '   set return_status = :p_status '||
                 ' where sr_instance_id = :p_instance_id '||
                   ' and batch_id = :p_batch_id '||
                   ' and line_id = :p_line_id ';
            if nvl(p_so_table(a).x_return_status, FND_API.G_RET_STS_ERROR) <>
               FND_API.G_RET_STS_SUCCESS then
FND_FILE.PUT_LINE(FND_FILE.LOG,'update fails for line id '||p_so_table(a).line_id||', om return status ='||p_so_table(a).x_return_status);
               p_status := 2; -- fails
               retcode :=2;
            else
FND_FILE.PUT_LINE(FND_FILE.LOG,'atp override for line id'||p_so_table(a).line_id);
               p_status := 1; -- override
            end if;
          EXECUTE IMMEDIATE sql_stmt using p_status, p_instance_id, p_batch_id,
                                    p_so_table(a).line_id;
          p_need_notify := true;
      else
FND_FILE.PUT_LINE(FND_FILE.LOG,'update scceeds for line id'||p_so_table(a).line_id);
      end if;

   end loop;

   IF nvl(x_crm_return_status, FND_API.G_RET_STS_ERROR) <>
             FND_API.G_RET_STS_SUCCESS THEN
      p_status := 2; -- fails
      retcode :=2;
      sql_stmt:=
                ' update msc_sales_order_interface'||p_dblink||
                 '   set return_status = :p_status '||
                 ' where sr_instance_id = :p_instance_id '||
                   ' and batch_id = :p_batch_id '||
                   ' and source_type = 100 ';
      EXECUTE IMMEDIATE sql_stmt using p_status, p_instance_id, p_batch_id;
      commit;
      for a in 1..crm_so_count loop
        FND_FILE.PUT_LINE(FND_FILE.LOG,'update fails for line id '||p_crm_so_table(a).order_line_id);
      end loop;
   ELSE
      for a in 1..crm_so_count loop
        FND_FILE.PUT_LINE(FND_FILE.LOG,'update successfully for line id '||p_crm_so_table(a).order_line_id);
      end loop;
   END IF;

   sql_stmt:=
                ' delete from msc_sales_order_interface'||p_dblink||
                 ' where sr_instance_id = :p_instance_id '||
                   ' and batch_id = :p_batch_id '||
                   ' and return_status is null ';
   EXECUTE IMMEDIATE sql_stmt using p_instance_id, p_batch_id;
   commit;

   if p_need_notify then
       sql_stmt:=
           'BEGIN'
        ||'  msc_rel_wf.so_release_workflow_program'||p_dblink||'('
                                          ||'   :p_batch_id, '
                                          ||' :p_instance_id,'
                                          ||' :p_planner,'
                                          ||' :p_request_id);'
        ||' END;';
       EXECUTE IMMEDIATE sql_stmt using in p_batch_id,in p_instance_id,
                                        in p_user_name, out p_request_id ;
       commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'send workflow notification to planner '||p_user_name||', request id='||p_request_id);
   end if;
exception when others then
 retcode :=2;
 raise;

END release_so_program;

end mrp_release_so;

/
