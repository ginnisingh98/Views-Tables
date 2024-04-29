--------------------------------------------------------
--  DDL for Package Body MRP_RESCHEDULE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_RESCHEDULE_PO" AS
/*$Header: MRPRSPOB.pls 120.3.12010000.4 2010/03/19 19:01:49 cnazarma ship $ */

Type CharTab is TABLE of varchar2(2);
Type LongCharTab is TABLE of varchar2(240);
Type NumTab IS TABLE of number;
Type DateTab IS TABLE of DATE;

PROCEDURE reschedule_po_program
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_old_need_by_date IN DATE,
p_new_need_by_date IN DATE,
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_qty IN NUMBER
) IS

    p_instance_id number;
 p_dblink varchar2(128);
sql_stmt varchar2(2000);
 p_result boolean;

 v_old_need_by_date dateTab;
 v_new_need_by_date dateTab;
 v_po_header_id  numTab;
 v_po_line_id  numTab;
 --v_po_line_id2  numTab;
 v_po_line_location_id numTab;
 v_po_number LongCharTab;
 v_po_location_id  number;
 v_action  numTab;


 TYPE type_cursor IS REF CURSOR;
 po_cursor type_cursor;
 p_batch_id number;

first_left_pare_pos number;
first_right_pare_pos number;
second_left_pare_pos number;
second_right_pare_pos number;
third_left_pare_pos number;
third_right_pare_pos number;

l_doc_type VARCHAR2(30);
l_doc_subtype VARCHAR2(30);
p_allow_release number;
p_instance_code varchar2(10);
v_release_num number;
l_derived_status number := null;

 cursor check_rel_flag is
    select ALLOW_RELEASE_FLAG, instance_code
      from MRP_AP_APPS_INSTANCES_ALL
     where instance_id = p_instance_id
       and nvl(A2M_DBLINK, '-1') = p_dblink;

 X_need_by_dates_old 	   po_tbl_date := po_tbl_date();
 X_need_by_dates 	   po_tbl_date := po_tbl_date();
 X_po_line_ids 		   po_tbl_number := po_tbl_number();
 X_shipment_nums 	   po_tbl_number := po_tbl_number();
 X_estimated_pickup_dates  po_tbl_date := po_tbl_date();
 X_ship_methods		   po_tbl_varchar30 := po_tbl_varchar30();
 a number :=0;
 p_result_output         po_tbl_number := po_tbl_number();

 last_po_number varchar2(250);
 last_po_header_id number;
 p_result_success boolean := false;
 p_result_error boolean := false;
 p_result_warning boolean := false;

BEGIN

 FND_FILE.PUT_LINE(FND_FILE.LOG,'starting ...');
 p_batch_id := p_po_header_id;
 p_instance_id := p_po_line_id;
 p_dblink := p_po_number;

 retcode :=0;
   p_allow_release :=0;

   OPEN check_rel_flag;
   FETCH check_rel_flag INTO p_allow_release, p_instance_code;
   CLOSE check_rel_flag;

     if p_dblink = '-1' then
          p_dblink := ' ';
     else
          p_dblink := '@'||p_dblink;
     end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'instance_code:'||p_instance_code||' dblink: '|| p_po_number ||', instance_id='||p_instance_id||', batch_id='||p_batch_id||',allow_release_flag ='||p_allow_release);


 if p_allow_release = 1 THEN
    mo_global.INIT('PO');
 sql_stmt:=
   ' select old_need_by_date,'||
          ' new_need_by_date,'||
          ' po_header_id,'||
          ' po_line_id,'||
          ' po_number,'||
          ' action'||
 ' from msc_purchase_order_interface'||p_dblink||
 ' where sr_instance_id = '||p_instance_id||
   ' and batch_id ='||p_batch_id ||
   ' order by action, po_number ';

  OPEN po_cursor FOR sql_stmt;
  FETCH po_cursor BULK COLLECT INTO v_old_need_by_date,
                                    v_new_need_by_date,
                                    v_po_header_id,
                                    v_po_line_id,
                                    v_po_number,
                                    v_action;
  CLOSE po_cursor;

  FOR i in 1..nvl(v_po_line_id.LAST, 0) LOOP

/* in R12, order number(release number)(line number)(shipment number),
   but release number could be empty,
   in 11.5.10 and prior,
    order number(release number)(shipment number) -- blanket PO or
    order number(shipment number)  -- standard PO                   */

       first_left_pare_pos := instr(v_po_number(i), '(');
       second_left_pare_pos := instr(v_po_number(i), '(',1,2);
       third_left_pare_pos := instr(v_po_number(i), '(',1,3);
  if third_left_pare_pos > 0 then -- in R12
       first_right_pare_pos := instr(v_po_number(i), ')');
       third_right_pare_pos := instr(v_po_number(i), ')', 1,3);
       v_po_location_id := substr(v_po_number(i),
                third_left_pare_pos+1,third_right_pare_pos -
                   third_left_pare_pos -1);

       begin
          v_release_num :=  substr(v_po_number(i),
                first_left_pare_pos+1,first_right_pare_pos -
                   first_left_pare_pos -1);
       exception when others then
              v_release_num :=null;
       end;

       if v_release_num is null then
            l_doc_type := 'PO';
            l_doc_subtype := 'STANDARD';
            v_po_number(i) := substr(v_po_number(i), 1,first_left_pare_pos -1);
       else
            l_doc_type := 'RELEASE';
            l_doc_subtype := 'BLANKET';
            v_po_number(i) := substr(v_po_number(i),1,second_left_pare_pos -1);
       end if;
  else -- in 11.5.10 or prior
       -- -------------------------------------------------
       -- Bug#4013684 - 16-dec-2004.
       -- l_doc_type and l_doc_subtype will be derived here
       -- and will be passed to 'Cancel PO' api.
       -- -------------------------------------------------
       if first_left_pare_pos > 0 then -- should not be 0, just in case
         first_right_pare_pos := instr(v_po_number(i), ')');
         if second_left_pare_pos = 0 then  -- standard po
           v_po_location_id := substr(v_po_number(i),
                first_left_pare_pos+1,first_right_pare_pos -
                   first_left_pare_pos -1);
           v_po_number(i) := substr(v_po_number(i), 1,first_left_pare_pos -1);
            l_doc_type := 'PO';
            l_doc_subtype := 'STANDARD';
         else -- blanket po
           second_right_pare_pos := instr(v_po_number(i), ')', 1,2);
           v_po_location_id := substr(v_po_number(i),
                second_left_pare_pos+1,second_right_pare_pos -
                   second_left_pare_pos -1);
           v_po_number(i) := substr(v_po_number(i),1,second_left_pare_pos -1);
           l_doc_type := 'RELEASE';
           l_doc_subtype := 'BLANKET';
         end if;
       end if;
    end if; -- if third_left_pare_pos > 0

	-- cancel the PO if action = 2 else reschedule it.
if v_action(i) = 2 then
           mrp_cancel_po.cancel_po_program(v_po_header_id(i), v_po_line_id(i),
                                           v_po_number(i), v_po_location_id,
                                           l_doc_type , l_doc_subtype);
else
   --5137694, for standard po, group by po_header_id,
   -- for blanket po, group by po_header_id and shipment number

   if i <> nvl(v_po_line_id.FIRST, 0) and
        v_po_number(i) <> v_po_number(i-1) then
       --call PO api
       p_result := reschedule_po(X_need_by_dates_old,
                         X_need_by_dates,
                         v_po_header_id(i-1),
                         X_po_line_ids,
                         v_po_number(i-1),
                         X_shipment_nums,
                         X_estimated_pickup_dates,
                         X_ship_methods,
                         l_derived_status);
             if not(p_result) then
               retcode :=2;
             end if;

           p_result_output.extend;
           p_result_output(p_result_output.last):= set_result(p_result, l_derived_status);

             -- reset po table
             a := 0;
             x_need_by_dates_old.delete;
             X_need_by_dates.delete;
             X_po_line_ids.delete;
             X_shipment_nums.delete;
             x_estimated_pickup_dates.delete;
             x_ship_methods.delete;
   end if; -- if i <> nvl(v_po_line_id.FIRST, 0) and
   -- init po tables
       a := a+1;
       x_need_by_dates_old.extend;
       x_need_by_dates_old(a) := v_old_need_by_date(i);
       X_need_by_dates.extend;
       X_need_by_dates(a) := v_new_need_by_date(i);
       X_po_line_ids.extend;
       X_po_line_ids(a) := v_po_line_id(i);
       X_shipment_nums.extend;
       X_shipment_nums(a) := v_po_location_id;
       x_estimated_pickup_dates.extend;
       x_estimated_pickup_dates(a) := null;
       x_ship_methods.extend;
       x_ship_methods(a) := null;
       last_po_header_id := v_po_header_id(i);
       last_po_number := v_po_number(i);
  end if; -- if v_action = 2 then

 FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
 END LOOP; -- FOR i in 1..nvl(v_po_line_id.LAST, 0) LOOP

  if a <> 0 then
            p_result := reschedule_po(X_need_by_dates_old,
                         X_need_by_dates,
                         last_po_header_id,
                         X_po_line_ids,
                         last_po_number,
                         X_shipment_nums,
                         X_estimated_pickup_dates,
                         X_ship_methods,
                         l_derived_status);
             if not(p_result) then
               retcode :=2;
             end if;

          p_result_output.extend;
          p_result_output(p_result_output.last):= set_result(p_result, l_derived_status);

   end if; -- if a <> 0

      -- set the retcode correctly to ERROR, WARNING or SUCCESS
    for b in 1..nvl(p_result_output.last,0) loop
         if (p_result_output(b)= 0) then
            p_result_success := true;
         elsif (p_result_output(b) = 1) then
            p_result_warning := true;
         elsif (p_result_output(b) = 2) then
            p_result_error := true;
         end if;
   END LOOP;

  if (p_result_success) AND not(p_result_warning) AND not(p_result_error) then
       retcode := 0;
   elsif (p_result_warning)  OR
         (  p_result_success AND p_result_error) then
        retcode := 1;  -- warning
   elsif not(p_result_success)
         AND not(p_result_warning)
         and (p_result_error) then
        retcode := 2; -- error
   end if;

else -- not allow release
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'instance '||p_instance_code||' does not allow release ');
end if; -- if p_allow_release = 1 then
 sql_stmt:= ' delete from msc_purchase_order_interface'||p_dblink||
             ' where sr_instance_id = :p_instance_id '||
             ' and batch_id = :p_batch_id ';

 EXECUTE IMMEDIATE sql_stmt using p_instance_id, p_batch_id;

 commit;

exception
when others then
 retcode :=2;
 raise;
END reschedule_po_program;


FUNCTION set_result(p_result boolean,
                    l_derived_output number)
return number IS
BEGIN
         if(p_result) then
                return  0;  -- success
         elsif not(p_result) then
                return l_derived_output;
         end if;

END set_result;


FUNCTION get_request_status(
                             x_error_messages po_tbl_varchar2000)
return number IS
/*
 * this call will be executed only for p_result = FALSE
 * if x_error_message contains all nulls -> return 0 , means ERROR
 * if x_error_message contains some nulls -> return 1, means WARNING
 * */
WARNING number := 1;
ERROR number := 2;
my_return number:= null;
BEGIN
 FND_FILE.PUT_LINE(FND_FILE.LOG,' IN get_request_status x_error_messages count =
' || x_error_messages.count);

my_return := ERROR;

for i in 1..x_error_messages.count LOOP
 if (x_error_messages(i) <> null) then
    my_return:= WARNING;
    return my_return;
 end if;
END LOOP;


return my_return;

END get_request_status;




FUNCTION reschedule_po( X_old_need_by_dates      po_tbl_date,
                         X_new_need_by_dates      po_tbl_date,
                         X_po_header_id           number,
                         X_po_line_ids            po_tbl_number,
                         X_po_number              varchar2,
                         X_shipment_nums          po_tbl_number,
                         X_estimated_pickup_dates po_tbl_date,
                         X_ship_methods           po_tbl_varchar30,
                         l_derived_status IN OUT NOCOPY number)
  return boolean IS

  p_result boolean;
 v_promised_date dateTab;
 v_need_by_date dateTab;
 v_rec NumTab;
 v_date_changed boolean;
 v_date date;
 x_error_messages po_tbl_varchar2000 := po_tbl_varchar2000();
 p_show_msg varchar2(3) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

 cursor po_cur(v_line_id number, v_header_id number, v_ship_num number) is
      select nvl(poll.promised_date,poll.need_by_date),1
      from   po_line_locations_all poll
      where  poll.po_line_id = v_line_id
        and  poll.po_header_id = v_header_id
        and  poll.shipment_num = nvl(v_ship_num,poll.shipment_num);
 v_old_need_by_dates      po_tbl_date := po_tbl_date();

            CURSOR cur_org(p_po_header_id IN number) IS
            SELECT org_id
            FROM po_headers_all
            WHERE po_header_id = p_po_header_id;

            l_document_org_id NUMBER;
            l_access_mode     VARCHAR2(1);
            l_current_org_id  NUMBER;
 l_error_message varchar2(1000);
 PROCEDURE show_po_details IS
 cursor po_details (p_line_id number) is
 select line_num
 from po_lines_all
 where po_line_id = p_line_id;

 l_po_line_number number;

 BEGIN
    for i in 1..nvl(X_po_line_ids.last, 0) loop
      open po_details(x_po_line_ids(i));
      fetch po_details into l_po_line_number;
      close po_details;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '***** PO line details *****');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'old date in planner workbench: '||
                   to_char(x_old_need_by_dates(i),'MM/DD/RR HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'new date: '||
                   to_char(x_new_need_by_dates(i),'MM/DD/RR HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'header: '||x_po_header_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'line: '||x_po_line_ids(i));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'line number : ' || l_po_line_number);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'po number: '||x_po_number);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'shipment no: '||X_shipment_nums(i));
    end loop;
 END show_po_details;

BEGIN

-- p_show_msg := 'Y';

  begin

            OPEN cur_org(x_po_header_id);
            FETCH cur_org INTO l_document_org_id;
            CLOSE cur_org;

            l_access_mode := mo_global.Get_access_mode();
            l_current_org_id := mo_global.get_current_org_id();

            mo_global.set_policy_context('S',l_document_org_id);


 p_result :=po_reschedule_pkg.reschedule
                        (X_old_need_by_dates,
                         X_new_need_by_dates,
                         X_po_header_id,
                         X_po_line_ids,
                         X_po_number,
                         X_shipment_nums,
                         X_estimated_pickup_dates,
                         X_ship_methods,
                         x_error_messages);
           Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,
                                          p_org_id => l_current_org_id);
  exception when others then
     FND_FILE.PUT_LINE(FND_FILE.LOG,' error while calling po_reschedule_pkg.reschedule '||sqlerrm);
     Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,
                                              p_org_id => l_current_org_id);
     show_po_details;
  end;

 if p_result is null then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'the call to  po_reschedule_pkg.reschedule return null value');
 end if;

 p_result := nvl(p_result, false);

 if not(p_result) then -- p_result is false
   -- 5030537, it might fail because our PO does not carry seconds,
    v_date_changed := false;
    for i in 1..nvl(X_po_line_ids.last, 0) loop
      if v_rec is not null then
         v_promised_date.delete;
         v_rec.delete;
      end if;
      v_old_need_by_dates.extend;
      v_old_need_by_dates(i) := x_old_need_by_dates(i);
      OPEN po_cur(x_po_line_ids(i), X_po_header_id,X_shipment_nums(i));
      FETCH po_cur BULK COLLECT INTO
               v_promised_date, v_rec;
      CLOSE po_cur;

      For a in 1..nvl(v_rec.last,0) LOOP
           v_date := v_promised_date(a);
           if to_date(to_char(x_old_need_by_dates(i), 'MM/DD/RRRR HH24:MI'),
                 'MM/DD/RRRR HH24:MI') =
              to_date(to_char(v_date, 'MM/DD/RRRR HH24:MI'),
                 'MM/DD/RRRR HH24:MI') then
              if x_old_need_by_dates(i) <> v_date then
FND_FILE.PUT_LINE(FND_FILE.LOG,' call reschedule again by modifying old_need_by_date from '||to_char(x_old_need_by_dates(i), 'MM/DD/RRRR HH24:MI:SS')||
' to '||to_char(v_date, 'MM/DD/RRRR HH24:MI:SS'));
                  v_old_need_by_dates(i) := v_date;
                  v_date_changed := true;
              end if;
               exit;
           end if;
      END LOOP; -- For a in 1..nvl(v_rec.last,0) LOOP
    end loop; -- for i in 1..nvl(X_po_line_ids.last, 0) loop

    if v_date_changed then
       -- call reschedule again with updated old_need_by_date
      x_error_messages := null;
       p_result :=po_reschedule_pkg.reschedule
                        (v_old_need_by_dates,
                         X_new_need_by_dates,
                         X_po_header_id,
                         X_po_line_ids,
                         X_po_number,
                         X_shipment_nums,
                         X_estimated_pickup_dates,
                         X_ship_methods,
                         x_error_messages);
    end if; -- if v_date_changed then
 end if; -- if not(p_result) then

    p_result := nvl(p_result, false);

    if p_result then
         -- set l_derived_status correctly.
         -- PO can return success , even if one of the line failed
         l_derived_status := get_request_status(x_error_messages);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'reschedule succeeds for PO header id ' || X_po_header_id);
        for i in 1..x_error_messages.count loop
            FND_FILE.PUT_LINE(FND_FILE.LOG,' Error returned from PO api : ' || x_error_messages(i));
         end loop;
    else
         l_derived_status := 2;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'reschedule fails for PO header id' || X_po_header_id);
      for i in 1..x_error_messages.count loop
         FND_FILE.PUT_LINE(FND_FILE.LOG,' Error returned from PO api : ' || x_error_messages(i));
         end loop;

    end if;

if (p_result and p_show_msg = 'Y') or
       not(p_result) then
   show_po_details;
end if;

  return p_result;
exception when others then
  FND_FILE.PUT_LINE(FND_FILE.LOG,'error in reschedule_po, error is: '||sqlerrm);
  show_po_details;
  l_derived_status := 2;
  return false;
END reschedule_po;

END mrp_reschedule_po;

/
