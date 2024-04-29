--------------------------------------------------------
--  DDL for Package Body MSC_UPDATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_UPDATE_RESOURCE" AS
/* $Header: MSCFNAVB.pls 120.4.12010000.7 2009/09/29 16:46:52 eychen ship $ */

TYPE ResRecTyp IS RECORD (
        TRANSACTION_ID                           NUMBER,
	PARENT_ID				 NUMBER,
	AGGREGATE_RESOURCE_ID		         NUMBER,
        SIMULATION_SET                           VARCHAR2(10),
 	FROM_TIME                                NUMBER,
 	TO_TIME                                  NUMBER,
 	CAPACITY_UNITS                           NUMBER,
 	STATUS                                   NUMBER,
 	APPLIED                                  NUMBER,
 	UPDATED                          	 NUMBER,
 	LAST_UPDATE_DATE                 	 DATE,
 	LAST_UPDATED_BY                  	 NUMBER,
 	CREATION_DATE                   	 DATE,
 	CREATED_BY                       	 NUMBER,
 	LAST_UPDATE_LOGIN                        NUMBER,
	shift_date                               DATE,
	shift_number                             NUMBER);

TYPE ResTabTyp IS TABLE OF ResRecTyp
	INDEX by binary_integer;

TYPE ChangeRecTyp IS RECORD (
	OPERATION				 NUMBER,
	ORGANIZATION_ID				 NUMBER,
        SR_INSTANCE_ID                           NUMBER,
	DEPARTMENT_ID				 NUMBER,
	RESOURCE_ID				 NUMBER,
        SHIFT_DATE                               DATE,
        SHIFT_NUMBER                             NUMBER,
 	FROM_TIME                                NUMBER,
 	TO_TIME                                  NUMBER,
 	CAPACITY_UNITS                           NUMBER,
     	LAST_UPDATED_BY                  	 NUMBER,
        RES_INST_ID                              NUMBER,
	SERIAL_NUMBER                            VARCHAR2(2000));

g_resource_exist        boolean;
g_res_inst_set_data     boolean;
g_error_stat		VARCHAR2(300);
g_plan_id               NUMBER;
g_simulation_set	VARCHAR2(10);
g_res_group		VARCHAR2(30);
g_cutoff_date		DATE;
g_query_id		NUMBER;
g_org_id		NUMBER;
g_instance_id           NUMBER;
g_department_id		NUMBER;
g_resource_id		NUMBER;
g_res_inst_id           NUMBER;
g_serial_number         VARCHAR2(2000);
g_shift_date            DATE;
g_shift_number          NUMBER;
g_from_time             NUMBER;
g_to_time               NUMBER;
g_units                 NUMBER;
g_change_rec 		ChangeRecTyp;
g_res_tab		ResTabTyp;
g_res_inst_tab		ResTabTyp;
g_tmp_tab		ResTabTyp;
i 			binary_integer;
j                       binary_integer;
k 			binary_integer;
OP_ADD_DAY		CONSTANT INTEGER :=0;
OP_ADD                  CONSTANT INTEGER :=1;
OP_DEL                  CONSTANT INTEGER :=2;
OP_SET			CONSTANT INTEGER :=3;
OP_DEL_DAY		CONSTANT INTEGER :=4;

CURSOR C_MFQ IS
       SELECT
			NUMBER1,
			NUMBER2,
			NUMBER3,
			NUMBER4,
			NUMBER5,
                        DATE1,
                        NUMBER6,
                        NUMBER7,
                        NUMBER8,
                        NUMBER9,
                        LAST_UPDATED_BY,
                        NUMBER10, CHAR1
	FROM Msc_FORM_QUERY
	WHERE query_id = g_query_id
	ORDER BY number2, number3, number4, number5, date1,
                 number6, number7,number1;

CURSOR C_CAR  IS
       SELECT
              transaction_id,
	      parent_id,
	      aggregate_resource_id,
              simulation_set,
              from_time,
              to_time,
              capacity_units,
	      status,
   	      applied,
              updated,
 	LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
	shift_date,
	shift_num
        FROM  MSC_NET_RESOURCE_AVAIL
        WHERE plan_id=g_plan_id
	AND organization_id = g_org_id
        AND sr_instance_id =g_instance_id
        AND department_id = g_department_id
        AND resource_id = g_resource_id
        and shift_date = g_shift_date
        and decode(resource_id,-1,-1,shift_num) =
              decode(resource_id,-1,-1,g_shift_number)
        and capacity_units >=0
        and nvl(parent_id,0) <> -1
	order by from_time;

CURSOR c_car_inst  IS
       SELECT
              inst_transaction_id transaction_id,
	      parent_id,
	      to_number(null) aggregate_resource_id,
              simulation_set,
              from_time,
              to_time,
              nvl(capacity_units,1) capacity_units,
	      status,
   	      applied,
              updated,
 	LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
	shift_date,
	shift_num
        FROM  msc_net_res_inst_avail
        WHERE plan_id=g_plan_id
	AND organization_id = g_org_id
        AND sr_instance_id =g_instance_id
        AND department_id = g_department_id
        AND resource_id = g_resource_id
	and res_instance_id = g_res_inst_id
	and serial_number = g_serial_number
        and shift_date = g_shift_date
        and decode(resource_id,-1,-1,shift_num) = decode(resource_id,-1,-1,g_shift_number)
        and nvl(capacity_units,1) >=0
        and nvl(parent_id,0) <> -1
	order by from_time;

CURSOR date_range IS
        SELECT distinct mra.shift_date
        FROM msc_net_resource_avail mra,
             msc_form_query mfq
        WHERE mra.plan_id = g_plan_id
        and mra.organization_id = g_org_id
        and mra.sr_instance_id = g_instance_id
        and mra.department_id = g_department_id
        and mra.resource_id = g_resource_id
        and nvl(mra.parent_id,0) <> -1
        and mra.capacity_units >=0
        and mfq.query_id = g_query_id
        and trunc(mra.shift_date) between
                trunc(mfq.date1) and trunc(mfq.date2)
ORDER BY mra.shift_date;

-- global variable for move_resource
  Type NumTab IS TABLE of number INDEX BY BINARY_INTEGER;
  Type DateTab IS TABLE of DATE INDEX BY BINARY_INTEGER;
  p_start_time dateTab;
  p_end_time dateTab;
  p_resource_units numTab;
  p_trans_id numTab;

  TYPE simu_res_type IS RECORD (
    org_id numTab,
    inst_id numTab,
    dept_id numTab,
    res_id numTab,
    assign_units numTab,
    res_hours numTab,
    op_seq_id numTab,
    rt_seq_id numTab
  );

  sim_res simu_res_type;


---------------------------------------------------------------
-- apply change
---------------------------------------------------------------
PROCEDURE apply_change( p_query_id IN NUMBER,
			p_plan_id IN NUMBER ) IS

l_work_day  number;

  CURSOR NWD is
   SELECT nvl(dates.seq_num, -1)
  FROM msc_trading_partners mtp,
       msc_calendar_dates dates
  WHERE dates.calendar_date = trunc(g_shift_date)
    AND dates.calendar_code = mtp.calendar_code
    AND dates.exception_set_id = mtp.calendar_exception_set_id
    AND dates.sr_instance_id = mtp.sr_instance_id
    AND mtp.partner_type = 3
    AND mtp.sr_tp_id = g_org_id
    AND mtp.sr_instance_id = g_instance_id;

BEGIN
   g_plan_id :=p_plan_id;
   g_query_id := p_query_id;
   g_org_id                :=0;
   g_instance_id           :=0;
   g_department_id         :=0;
   g_resource_id           :=0;
   g_shift_date            :=to_date(null);
   g_shift_number          :=null;

  -- load from mrp_form_query for the changes, if the resource changes
  -- re-query data from msc_net_resource_avail

   OPEN C_MFQ;
   LOOP
     FETCH C_MFQ INTO g_change_rec;
     EXIT WHEN C_MFQ%NOTFOUND;
           g_org_id :=g_change_rec.organization_id;
           g_instance_id := g_change_rec.sr_instance_id;
           g_department_id :=g_change_rec.department_id;
           g_resource_id :=g_change_rec.resource_id;
           g_res_inst_id := g_change_rec.res_inst_id;
	   g_serial_number := g_change_rec.serial_number;
           g_shift_number :=g_change_rec.shift_number;
	   g_from_time := g_change_rec.from_time;
           g_to_time := g_change_rec.to_time;
	   g_units := g_change_rec.capacity_units;

	   if (g_change_rec.res_inst_id is not null and g_change_rec.operation = OP_SET) then
	     g_res_inst_set_data := true;
	   else
	     g_res_inst_set_data := false;
	   end if;

       OPEN date_range;
       LOOP
          FETCH date_range into g_shift_date;
          EXIT WHEN date_range%NOTFOUND;

           OPEN NWD;
           FETCH NWD into l_work_day;
           CLOSE NWD;
           if ( l_work_day <> -1 ) then
	     initialize_table;
   	     calculate_change;
             update_table;
           end if;
       END LOOP;
       CLOSE date_range;
   END LOOP;
   CLOSE C_MFQ;
   commit;
EXCEPTION when others THEN

   IF (C_MFQ%ISOPEN) THEN
	close C_MFQ;
   END IF;
  IF date_range%ISOPEN THEN
        close date_range;
  END IF;
   raise_application_error(-20000, sqlerrm);
END apply_change;

---------------------------------------------------------------------
-- to get the values into PL/SQL tables
---------------------------------------------------------------------
PROCEDURE initialize_table IS
l_ctr number :=0;
BEGIN

   -- load from crp_available_resources for all the records
   -- related to the same resource
j :=0;
g_res_tab.delete;

   OPEN C_CAR;
   LOOP
	   j := j+1;
	   FETCH C_CAR INTO g_res_tab(j);
	   if C_CAR%NOTFOUND then
             if C_CAR%ROWCOUNT=0 then
               g_resource_exist :=false;
             end if;
             exit;
           end if;

   END LOOP;
   IF C_CAR%ROWCOUNT >0 THEN
     g_resource_exist :=true;
   END IF;
   CLOSE C_CAR;

   if (g_res_inst_set_data) then
   g_res_inst_tab.delete;
   open c_car_inst;
   loop
	   l_ctr := l_ctr +1;
	   fetch c_car_inst into g_res_inst_tab(l_ctr);
	   if c_car_inst%notfound then
             exit;
           end if;
   end loop;
   close c_car_inst;
   end if;

EXCEPTION WHEN others THEN
  IF (C_CAR%ISOPEN) THEN
	close C_CAR;
  END IF;

END initialize_table;

Function insert_undo_data(undo_type number,
                         j number default null,
                         v_undo_parent_id number default null) return number is
  v_undo_id number;
  net_res_columns msc_undo.changeRGType;
  x_return_sts varchar2(100);
  x_msg_count number;
  x_msg_data varchar2(200);
  i number;
begin

     select msc_undo_summary_s.nextval
       into v_undo_id
       from dual;

     if undo_type = 2 then -- update

          i := 1;
        if g_res_tab(j).capacity_units <>
              g_tmp_tab(k).capacity_units then
          net_res_columns(i).column_changed := 'CAPACITY_UNITS';
          net_res_columns(i).column_changed_text := 'Capacity Units';
          net_res_columns(i).old_value := to_char(g_res_tab(j).capacity_units);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(g_tmp_tab(k).capacity_units);
          i := i+1;
          if (g_res_inst_set_data) then
	    g_tmp_tab(k).capacity_units := g_res_tab(j).capacity_units;
	  end if;
        end if;

        if g_res_tab(j).from_time <>
              g_tmp_tab(k).from_time then
          net_res_columns(i).column_changed := 'FROM_TIME';
          net_res_columns(i).column_changed_text := 'From Time';
          net_res_columns(i).old_value := to_char(g_res_tab(j).from_time);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(g_tmp_tab(k).from_time);
          i := i+1;
        end if;

        if g_res_tab(j).to_time <>
              g_tmp_tab(k).to_time then
          net_res_columns(i).column_changed := 'TO_TIME';
          net_res_columns(i).column_changed_text := 'To Time';
          net_res_columns(i).old_value := to_char(g_res_tab(j).to_time);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(g_tmp_tab(k).to_time);
        end if;

     end if;

     msc_undo.store_undo(4, --means msc_net_resource_avail
                undo_type,  --2 is update , 1 is insert a record
                g_tmp_tab(k).transaction_id,
                g_plan_id,
                g_instance_id,
                v_undo_parent_id,
                net_res_Columns,
                x_return_sts,
                x_msg_count,
                x_msg_data,
                v_undo_id);

      return v_undo_id;

end insert_undo_data;

Function insert_res_inst_undo_data(undo_type number,
			 v_trx_id number,
                         v_old_shift_date varchar2, v_new_shift_date varchar2,
			 v_old_shift_number varchar2, v_new_shift_number varchar2,
			 v_old_from_time varchar2, v_new_from_time varchar2,
			 v_old_to_time varchar2, v_new_to_time varchar2,
			 v_old_units varchar2, v_new_units varchar2,
                         v_undo_parent_id number default null) return number is
  v_undo_id number;
  net_res_columns msc_undo.changeRGType;
  x_return_sts varchar2(100);
  x_msg_count number;
  x_msg_data varchar2(200);
begin
     select msc_undo_summary_s.nextval
       into v_undo_id
       from dual;

     if undo_type = 2 then -- update

          i := 1;
          net_res_columns(i).column_changed := 'SHIFT_DATE';
          net_res_columns(i).column_changed_text := 'Shift Date';
          net_res_columns(i).old_value := v_old_shift_date;
          net_res_columns(i).column_type := 'DATE';
          net_res_columns(i).new_value := v_new_shift_date;

          i := i+1;
          net_res_columns(i).column_changed := 'SHIFT_NUM';
          net_res_columns(i).column_changed_text := 'Shift Number';
          net_res_columns(i).old_value := to_char(v_old_shift_number);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(v_new_shift_number);

          i := i+1;
          net_res_columns(i).column_changed := 'FROM_TIME';
          net_res_columns(i).column_changed_text := 'From Time';
          net_res_columns(i).old_value := to_char(v_old_from_time);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(v_new_to_time);

          i := i+1;
          net_res_columns(i).column_changed := 'TO_TIME';
          net_res_columns(i).column_changed_text := 'To Time';
          net_res_columns(i).old_value := to_char(v_old_to_time);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(v_new_to_time);

          i := i+1;
          net_res_columns(i).column_changed := 'CAPACITY_UNITS';
          net_res_columns(i).column_changed_text := 'Capacity Units';
          net_res_columns(i).old_value := to_char(v_old_units);
          net_res_columns(i).column_type := 'NUMBER';
          net_res_columns(i).new_value := to_char(v_new_units);
     end if;

     msc_undo.store_undo(8, --means msc_net_resource_avail
                undo_type,  --2 is update , 1 is insert a record
                v_trx_id,
                g_plan_id,
                g_instance_id,
                v_undo_parent_id,
                net_res_Columns,
                x_return_sts,
                x_msg_count,
                x_msg_data,
                v_undo_id);
      return nvl(v_undo_parent_id,v_undo_id);

end insert_res_inst_undo_data;

---------------------------------------------------------------------
-- to
---------------------------------------------------------------------
PROCEDURE calculate_change IS
v_start_record 		number;
v_end_record            number;
v_undo_id number;
v_undo_parent_id number;
BEGIN

IF g_resource_exist THEN
-- try to find which records in res_tab are affected by the change

    -- try to find which record the change start date falls

 j:=g_res_tab.FIRST;
 IF (g_change_rec.from_time <
	g_res_tab(j).from_time ) THEN
     -- the change record starts before the range
	v_start_record :=0;
 ELSE
    --find the first record whose start date is greater than change's start date
    --then the previous record will be where the change starts
	While (j is not null) and
	   (    g_change_rec.from_time >=
		g_res_tab(j).from_time    )
	LOOP
	   j:=g_res_tab.next(j);
	END LOOP;
   IF j is null THEN
	-- if j is null, then the change is on or outside the last record
	i :=g_res_tab.LAST;
	IF ( g_res_tab(i).to_time is null ) THEN
	   v_start_record :=g_res_tab.LAST;
	   v_end_record :=g_res_tab.LAST;
	ELSE
	  IF (g_change_rec.from_time <=
		g_res_tab(i).to_time ) THEN
	        v_start_record :=g_res_tab.LAST;
           	v_end_record :=g_res_tab.LAST;
	   ELSE
	  	v_start_record :=g_res_tab.LAST+1;
          	v_end_record :=g_res_tab.LAST+1;

	   END IF;
	END IF;
   ELSE
	-- otherwise, the change is inside the range
	-- but it could be on a record or in a gap between two records
	IF (g_change_rec.from_time <=
                g_res_tab(j-1).to_time ) THEN
	--change falls on the previos record
		v_start_record := j-1;
	ELSE
	--change falls on the gap between record j-1 and record j
		v_start_record := j-0.5;
	END IF;
	--go to the previous record to find where change ends
	j:=j-1;
   END IF;
 END IF;

-- try to find which record the change end date fall

 -- if the change does not have end date, the change extends till the end
 -- but it could be on the last record, or outside the range
 IF ( g_change_rec.to_time is null ) THEN
        i :=g_res_tab.LAST;
        IF ( g_res_tab(i).to_time is null ) THEN
	-- falls on the last record
           v_end_record :=g_res_tab.LAST;
        ELSE
	--falls outside the last record
          v_end_record :=g_res_tab.LAST+1;
        END IF;

 ELSE
     IF (    g_change_rec.to_time <=
	     g_res_tab(1).from_time    ) THEN
	-- the change ends before the first record
	v_end_record :=0;
     ELSE

        While (j is not null) and
           	 (   g_change_rec.to_time >
                     g_res_tab(j).from_time    )
        LOOP
              j:=g_res_tab.next(j);
        END LOOP;

        IF j is null THEN
	-- if j is null, then the change ends on or outside the last record
           i :=g_res_tab.LAST;
           IF ( g_res_tab(i).to_time is null ) THEN
              v_end_record :=g_res_tab.LAST;
           ELSE
          	IF (g_change_rec.to_time <=
                	g_res_tab(i).to_time ) THEN
                	v_end_record :=g_res_tab.LAST;
           	ELSE
              		v_end_record :=g_res_tab.LAST+1;
           	END IF;
	   END IF;

        ELSE
	   IF (g_change_rec.to_time <=
                g_res_tab(j-1).to_time ) THEN
	   -- change ends on the previous record
	        v_end_record := j-1;
	   ELSE
	   -- change ends in the gap between record j-1 and record j
		v_end_record := j-0.5;
	   END IF;
   	END IF;
     END IF;
 END IF;

-- flush the records to tmp_tab
   k:=0;
   g_tmp_tab.delete;

 IF g_change_rec.operation <> OP_SET THEN

    IF ( v_start_record =0 ) THEN
	   IF g_change_rec.operation not in (OP_DEL, OP_DEL_DAY) THEN
                add_new_record(1,false,false);
                v_undo_id :=insert_undo_data(1); -- insert
	   	IF (v_end_record <> 0) THEN
	      		g_tmp_tab(k).to_time :=
			g_res_tab(1).from_time;
	   	END IF;

		-- if add non working day, set the updated field as 1
		-- so that when re-plan, it will be treated as work day

	 	IF g_change_rec.operation = OP_ADD_DAY THEN
			g_tmp_tab(k).updated :=1;
		END IF;
	   END IF;
   END IF;

   j:=g_res_tab.FIRST;
   While (j is not null)
   LOOP

      v_undo_parent_id := null;

      IF (j < v_start_record) or (j > v_end_record) THEN
		-- no change, just copy the old record
                add_new_record(j, true,true);

      ELSIF (j > v_start_record) and (j<v_end_record) THEN
	       -- the whole record is affected, change the qty
                       add_new_record(j, true,true);
       IF g_change_rec.operation = OP_ADD THEN
          g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units +
                              g_change_rec.capacity_units ;
       ELSIF g_change_rec.operation = OP_DEL THEN
          g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units -
                              g_change_rec.capacity_units ;

       END IF;
           v_undo_id :=insert_undo_data(2,j); -- update
      ELSIF (j=v_start_record) and (j = v_end_record) THEN
		   -- need to cut the record into three records
             IF (g_change_rec.from_time <>
                        g_res_tab(j).from_time ) THEN
                        -- need to change the date for the first record
                       add_new_record(j, true,true); -- retain old tran_id
                        g_tmp_tab(k).to_time:=
                             g_change_rec.from_time;
                        v_undo_parent_id :=insert_undo_data(2,j); --update

	     END IF;

	     -- add a new record
	     -- delete work day and add non working day would be caught
	     -- here only if it falls inside the range and not in a gap,
             --	because v_start_record will always = v_end_record in these cases

	     IF g_change_rec.operation <> OP_DEL_DAY THEN
                        if v_undo_parent_id is not null then
                           add_new_record(j,false,false);
                        else -- retain old transaction_id
                           add_new_record(j,false,true);
                        end if;
                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units +
                              g_change_rec.capacity_units ;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units -
                              g_change_rec.capacity_units ;

			-- don't add onto the quantity of the original record
			ELSIF g_change_rec.operation = OP_ADD_DAY THEN
			   g_tmp_tab(k).updated :=1;

                        END IF;
                        if v_undo_parent_id is not null then
                           v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
                        else
                           v_undo_parent_id:=insert_undo_data(2,j); -- update
                        end if;
	     END IF;

             IF (g_change_rec.to_time <>
                        g_res_tab(j).to_time ) or
		( g_res_tab(j).to_time is null and
		g_change_rec.to_time is not null) THEN
                        -- need to change the date for the third record
                        if v_undo_parent_id is not null then
                           add_new_record(j,true,false);
                        else -- retain old transaction_id
                           add_new_record(j,true,true);
                        end if;
                        g_tmp_tab(k).from_time:=
                             g_change_rec.to_time;
                        if v_undo_parent_id is not null then
                           v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
                        else
                           v_undo_parent_id:=insert_undo_data(2,j); -- update
                        end if;
	     END IF;

      ELSIF (j=v_start_record) and (j <> v_end_record) THEN
		   -- need to cut the record
             IF (g_change_rec.from_time <>
                        g_res_tab(j).from_time ) THEN
                        -- need to change the date
                        add_new_record(j,true,true);
                        g_tmp_tab(k).to_time:=
                             g_change_rec.from_time;
                        v_undo_parent_id :=insert_undo_data(2,j); --update
	     END IF;

			-- and add a new record
                        if v_undo_parent_id is not null then
                           add_new_record(j,false,false);
                        else -- retain old transaction_id
                           add_new_record(j,false,true);
                        end if;
                        g_tmp_tab(k).to_time:=
                             g_res_tab(j).to_time;
                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units +
                              g_change_rec.capacity_units ;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units -
                              g_change_rec.capacity_units ;
                        END IF;
                        if v_undo_parent_id is not null then
                           v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
                        else
                           v_undo_parent_id:=insert_undo_data(2,j); -- update
                        end if;

      ELSIF (j=v_end_record) and (j <> v_start_record) THEN
		   -- need to cut the record
			--  add a new record
                        add_new_record(j,false,true);
                        g_tmp_tab(k).from_time:=
                             g_res_tab(j).from_time;
                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units +
                              g_change_rec.capacity_units ;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).capacity_units :=
                              g_res_tab(j).capacity_units -
                              g_change_rec.capacity_units ;
                        END IF;
                        v_undo_parent_id :=insert_undo_data(2,j);
             IF (g_change_rec.to_time <>
                        g_res_tab(j).to_time ) or
		(g_change_rec.to_time is not null and
		g_res_tab(j).to_time is null )THEN
                        -- need to change the date
                        add_new_record(j,true,false);
                        g_tmp_tab(k).from_time:=
                             g_change_rec.to_time;
                        v_undo_id :=insert_undo_data(1,j,v_undo_parent_id);
	     END IF;
      END IF;

      -- if change starts or ends in the gap, need to insert new row
      IF g_change_rec.operation not in  (OP_DEL_DAY, OP_DEL) THEN

         IF (v_start_record >j ) and (v_start_record <j+1 ) THEN
               add_new_record(j,false,false);
               v_undo_id :=insert_undo_data(1);
	    IF (g_change_rec.to_time >=
                        g_res_tab(j+1).from_time or
		g_change_rec.to_time is null) THEN
		--the change extends over the gap, need to change the end date
		g_tmp_tab(k).to_time:=
			g_res_tab(j+1).from_time;
	    END IF;

	 ELSIF (v_end_record >j ) and (v_end_record <j+1 ) THEN
            add_new_record(j,false,false);
            v_undo_id :=insert_undo_data(1);
            IF (g_change_rec.from_time <=
                        g_res_tab(j).to_time ) THEN
                --the change extends over the gap, need to change start date
                g_tmp_tab(k).from_time:=
                        g_res_tab(j).to_time;
            END IF;
	 END IF;
      END IF;

      j:=g_res_tab.next(j);
   END LOOP;

   -- if the record falls outside the original range, add a new row
   i := g_res_tab.LAST;
   IF (v_end_record = i+1) THEN
	   IF g_change_rec.operation not in (OP_DEL_DAY, OP_DEL) THEN
                add_new_record(i,false,false);
                v_undo_id :=insert_undo_data(1,j,v_undo_parent_id);
	   	IF (v_start_record <> i +1 ) THEN
           		g_tmp_tab(k).from_time:=
				g_res_tab(i).to_time;
	   	END IF;
	 	IF g_change_rec.operation = OP_ADD_DAY THEN
			g_tmp_tab(k).updated :=1;
		END IF;
	   END IF;
   END IF;

 ELSIF g_change_rec.operation= OP_SET THEN

        i := g_res_tab.LAST;

	IF (v_start_record = 0) THEN

	--if change falls before the range, add a row, go to the end record
	--cut record if needed, then go to the next record
           add_new_record(1,false,false);
           v_undo_id :=insert_undo_data(1);
	   -- if the set record ends outside the range, don't have to loop
	   IF (v_end_record = i+1) THEN
		j:='';
	   ELSIF (v_end_record=0) THEN
	   -- the change ends before the range, loop from record1
		j:=g_res_tab.FIRST;
	   ELSIF (v_end_record > trunc(v_end_record)) THEN
	   -- change falls on a gap, go to the record after the gap
		j:=trunc(v_end_record)+1;
	  -- if the set record ends outside the range, don't have to loop
	   ELSIF (v_end_record < i+1) THEN
	   -- go to where the set record ends and add row if needed
             	j:=v_end_record;

             IF (g_change_rec.to_time <
                        g_res_tab(j).to_time ) or
		(g_res_tab(j).to_time is null and
		g_change_rec.to_time is not null) THEN

                -- need to add row for the date change
                add_new_record(j,true,false);
                g_tmp_tab(k).from_time :=
                        g_change_rec.to_time;
                v_undo_id :=insert_undo_data(1);
             END IF;
    	     --go to the next record, and ready for loop
	     j:=j+1;
	   END IF;
	ELSE
	   j:=g_res_tab.FIRST;
	END IF;

        IF j < i+1 THEN
	While ( j is not null ) LOOP
	   IF (j < v_start_record) or (j > v_end_record) THEN
		-- no change
                   add_new_record(j,true,true);
	   ELSIF (j=v_start_record) THEN
 	     v_undo_parent_id := null;
	     IF (g_change_rec.from_time >
			g_res_tab(j).from_time ) THEN
		-- need to insert row with date change only first
                add_new_record(j,true,true);
		g_tmp_tab(k).to_time :=
			g_change_rec.from_time;
                v_undo_parent_id :=insert_undo_data(2,j);
	     END IF;

	     -- add new row
             if v_undo_parent_id is not null then
                    add_new_record(j,false,false);
                    v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
             else -- retain old transaction_id
                    add_new_record(j,false,true);
                    v_undo_parent_id := insert_undo_data(2,j);
             end if;

	     IF (v_end_record > trunc(v_end_record)) THEN
             -- change ends on a gap,
               j:=trunc(v_end_record);
             ELSIF (v_end_record < i+1) THEN
	     -- go the where the set record ends, and add row if needed
	        j:=v_end_record;
                IF (g_change_rec.to_time <
                        g_res_tab(j).to_time ) or
		   (g_change_rec.to_time is not null and
		    g_res_tab(j).to_time is null) THEN

                -- need to add row for the date change
                   add_new_record(j,true,false);
                   g_tmp_tab(k).from_time :=
                        g_change_rec.to_time;
                   v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
		END IF;
             END IF;

	   END IF;

	   -- if change starts on a gap
	   IF (v_start_record > j) and (v_start_record < j+1) THEN
             -- add new row
             add_new_record(j,false,true);
             v_undo_parent_id :=insert_undo_data(2,j);
	     IF (v_end_record > trunc(v_end_record)) THEN
              -- change ends on a gap,
                j:=trunc(v_end_record);
             ELSIF (v_end_record < i+1) THEN
             -- go to where the set record ends, and add row if needed
                j:=v_end_record;
                IF (g_change_rec.to_time <
                        g_res_tab(j).to_time ) or
		   (g_change_rec.to_time is not null and
		    g_res_tab(j).to_time is null)  THEN

                -- need to add row for the date change
                   add_new_record(j,true,false);
                   g_tmp_tab(k).from_time :=
                        g_change_rec.to_time;
                   v_undo_id :=
                             insert_undo_data(1,j,v_undo_parent_id); -- insert
	        END IF;
             END IF;
	   END IF;

	   j:=g_res_tab.next(j);
	END LOOP;
       END IF;

	-- if the set record starts outside the range
	i:=g_res_tab.LAST;
	IF (v_start_record = i+1 ) THEN
               -- need to add row for the date change
                add_new_record(i,false,false);
                v_undo_id :=insert_undo_data(1);
	END IF;
 END IF;

ELSE --user enters a resource which is not in msc_net_resource_avail table
   g_tmp_tab.delete;
   add_new_record(0,false,false);
   v_undo_id :=insert_undo_data(1);
END IF;

 g_res_tab :=g_tmp_tab;

END calculate_change;

FUNCTION get_inst_trx_id RETURN NUMBER IS
  v_trx_id NUMBER;
BEGIN
     select msc_net_res_inst_avail_s.nextval
     into v_trx_id
     from dual;
    return v_trx_id;
END;
------------------------------------------------------------------------
--to update msc_net_resource_avail table
-----------------------------------------------------------------------------
PROCEDURE update_table IS
CURSOR bucket IS
        SELECT mpb.bkt_start_date, mpb.bkt_end_date
        FROM   msc_plan_buckets mpb,
               msc_plans mp
        where  mp.plan_id = g_plan_id
          and  mp.plan_id = mpb.plan_id
          and  mp.organization_id = mpb.organization_id
          and  mp.sr_instance_id = mpb.sr_instance_id
          and  mpb.curr_flag =1
          and  g_shift_date between mpb.bkt_start_date and mpb.bkt_end_date;

m 	INTEGER;
v_start_date DATE;
v_end_date   DATE;
v_capacity_units NUMBER;

  l_units number;
  l_res_inst_trx_id number;
  l_res_inst_units number;
  l_res_inst_undo_id number;
BEGIN
  if g_resource_exist then

     for m in 1..g_res_tab.LAST loop
/*
dbms_output.put_line('del for tran='||to_char(g_res_tab(m).transaction_id));
dbms_output.put_line('capacity_units='||to_char(g_res_tab(m).capacity_units));
*/
       delete from msc_net_resource_avail
        where plan_id = g_plan_id
          and transaction_id = g_res_tab(m).transaction_id
          and g_res_tab(m).from_time <> g_res_tab(m).to_time;
     end loop;

     update msc_net_resource_avail
        set capacity_units = -1,
            status =0,
            applied =2,
            from_time = from_time+1,
            to_time = to_time +1
	where plan_id = g_plan_id
	and   organization_id = g_org_id
        and   sr_instance_id = g_instance_id
        AND   department_id = g_department_id
        AND   resource_id = g_resource_id
        AND   nvl(parent_id, 0) <> -1
        AND   shift_date = g_shift_date
        AND   decode(resource_id, -1,-1,shift_num) =
                 decode(resource_id,-1,-1,g_shift_number) ;
  end if;

  if (g_res_inst_set_data) then
   For m in 1 .. g_res_inst_tab.LAST LOOP
       update msc_net_res_inst_avail
       set capacity_units = 0,
            status =0,
            applied =2
	where plan_id = g_plan_id
          and inst_transaction_id = g_res_inst_tab(m).transaction_id
          and g_res_inst_tab(m).from_time <> g_res_inst_tab(m).to_time;
   end loop;
  end if;


   For m in 1 .. g_res_tab.LAST LOOP

      IF g_res_tab(m).from_time <> g_res_tab(m).to_time THEN
/*
dbms_output.put_line('insert for tran='||to_char(g_res_tab(m).transaction_id));
dbms_output.put_line('date='||g_shift_date);
dbms_output.put_line('from='||to_char(g_res_tab(m).from_time));
dbms_output.put_line('to='||to_char(g_res_tab(m).to_time));
dbms_output.put_line('simulation='||to_char(g_res_tab(m).simulation_set));
dbms_output.put_line('capacity_units='||to_char(g_res_tab(m).capacity_units));
*/
        l_units := greatest(g_res_tab(m).capacity_units,0);
        --dbms_output.put_line('capacity_units 1='||l_units);
	if (g_res_inst_set_data) then
	  if (g_from_time = g_res_tab(m).from_time and g_to_time = g_res_tab(m).to_time) then
            if (g_units = 0) then
	      l_units := greatest(g_res_tab(m).capacity_units,0);
	      l_res_inst_units := 0;
	    else -- g_units = 1
	      l_units := greatest(g_res_tab(m).capacity_units+1,0);
	      l_res_inst_units := 1;
	    end if;
	  else
	      begin
	      l_res_inst_units := g_res_inst_tab(m).capacity_units;
	      exception
	        when others then
	          if (l_units = 0) then
  	            l_res_inst_units := 0;
                  else
  	            l_res_inst_units := 1;
	          end if;
	      end;
  	  end if;
	end if;
        --dbms_output.put_line('capacity_units 2 ='||l_units);

	INSERT INTO msc_net_resource_avail
                (plan_id,
                 parent_id,
                 transaction_id,
                 organization_id,
                 sr_instance_id,
                 department_id,
                 resource_id,
                 shift_date,
                 shift_num,
                 from_time,
                 to_time,
                 capacity_units,
                 simulation_set,
                 status,
                 applied,
		 updated,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login)
               VALUES
                (g_plan_id,
                 -2,
                 g_res_tab(m).transaction_id,
                 g_org_id,
                 g_instance_id,
                 g_department_id,
                 g_resource_id,
		 g_shift_date,
                 decode(g_resource_id, -1, null,g_shift_number),
                 g_res_tab(m).from_time,
                 g_res_tab(m).to_time,
                 l_units,
                 g_res_tab(m).simulation_set,
              	 g_res_tab(m).status,
                 g_res_tab(m).applied,
		 g_res_tab(m).updated,
                 g_res_tab(m).last_update_date,
                 g_res_tab(m).last_updated_by,
                 g_res_tab(m).creation_date,
                 g_res_tab(m).created_by,
                 g_res_tab(m).last_update_login);

/*
dbms_output.put_line('RESOURCE -inst trx/shift/from/to/units '|| g_res_tab(m).transaction_id
  ||' - '||g_shift_number||' - '||g_res_tab(m).from_time||' - '||g_res_tab(m).to_time||' - '|| l_units);
*/

       if (g_res_inst_set_data) then
       if (m <= g_res_inst_tab.last) then
/*
dbms_output.put_line('INSTANCE res-inst trx/shift/from/to/units '||g_res_inst_tab(m).transaction_id
  ||' - '||g_shift_number||' - '||g_res_tab(m).from_time||' - '||g_res_tab(m).to_time||' - '|| l_res_inst_units);
*/

       update msc_net_res_inst_avail
       set capacity_units = l_res_inst_units,
	    shift_date = g_shift_date,
            shift_num = g_shift_number,
	    from_time = g_res_tab(m).from_time,
	    to_time = g_res_tab(m).to_time,
            status =0,
            applied =2
	where plan_id = g_plan_id
          and inst_transaction_id = g_res_inst_tab(m).transaction_id;

        if (sql%rowcount <> 0) then
	  l_res_inst_undo_id :=  insert_res_inst_undo_data(2,
			 g_res_inst_tab(m).transaction_id,
                         fnd_date.date_to_canonical(g_res_inst_tab(m).shift_date),
			 fnd_date.date_to_canonical(g_shift_date),
                         g_res_inst_tab(m).shift_number, g_shift_number,
                         g_res_inst_tab(m).from_time, g_res_tab(m).from_time,
                         g_res_inst_tab(m).to_time, g_res_tab(m).to_time,
                         g_res_inst_tab(m).capacity_units, l_res_inst_units,
                         null);
        end if;
	end if;

        if (sql%rowcount = 0 or m > g_res_inst_tab.last) then
	  l_res_inst_trx_id := get_inst_trx_id;
         insert into msc_net_res_inst_avail (
           inst_transaction_id,
           last_update_date, last_updated_by, creation_date, created_by, last_update_login,
	   plan_id, sr_instance_id, organization_id, department_id, resource_id,
	   res_instance_id, serial_number, shift_num, shift_date,
           from_time, to_time, simulation_set, capacity_units)
         values (
           l_res_inst_trx_id,
           sysdate, fnd_global.user_id, sysdate,fnd_global.user_id, fnd_global.user_id,
           g_plan_id, g_instance_id, g_org_id, g_department_id, g_resource_id, g_res_inst_id,
	   g_serial_number, g_shift_number, g_shift_date,
	   g_res_tab(m).from_time, g_res_tab(m).to_time, g_res_tab(m).simulation_set, l_res_inst_units);

	   --dbms_output.put_line('res-inst insert '||l_res_inst_trx_id||' - '||g_shift_number
	     --||' - '||g_res_tab(m).from_time||' - '||g_res_tab(m).to_time||' - '|| l_res_inst_units);
	  l_res_inst_undo_id :=  insert_res_inst_undo_data(1,
			 l_res_inst_trx_id,
                         null, null,
                         null, null,
                         null, null,
                         null, null,
                         null, null,
                         null);

	end if;

	end if;
	END IF;
   END LOOP;

  -- update the parent record

   OPEN bucket;
   FETCH bucket into v_start_date, v_end_date;
   CLOSE bucket;

     v_capacity_units :=0;
     begin
      select round(sum(decode(sign(to_time-from_time),1,(to_time - from_time),
                                    (to_time+86400-from_time)
                             )/3600*capacity_units),6)
      into v_capacity_units
      from msc_net_resource_avail
      where plan_id = g_plan_id
	and   organization_id = g_org_id
        and   sr_instance_id = g_instance_id
        AND   department_id = g_department_id
        AND   resource_id = g_resource_id
        and   nvl(parent_id, 0) <> -1
        and   capacity_units >0
        and   shift_date between v_start_date and v_end_date;
     exception when no_data_found then
        v_capacity_units :=0;
     end;

     v_capacity_units := nvl(v_capacity_units,0);

 -- update the resource units for parent record
     update msc_net_resource_avail
     set capacity_units = v_capacity_units,
         status =0,
         applied =2,
         updated =2
     where  plan_id = g_plan_id
	and   organization_id = g_org_id
        and   sr_instance_id = g_instance_id
        AND   department_id = g_department_id
        AND   resource_id = g_resource_id
        and   shift_date = v_start_date
        and   parent_id =-1;

-- update the parent_id for the added record
     update msc_net_resource_avail
     set parent_id = g_res_tab(1).parent_id
     where  plan_id = g_plan_id
	and   organization_id = g_org_id
        and   sr_instance_id = g_instance_id
        AND   department_id = g_department_id
        AND   resource_id = g_resource_id
        and   parent_id = -2 ;

END update_table;

------------------------------------------------------------------------
--to get transaction_id from msc_net_resource_avail table
-----------------------------------------------------------------------------
FUNCTION get_transaction_id RETURN NUMBER IS
  v_transaction_id NUMBER;
BEGIN
    select msc_net_resource_avail_s.nextval
    into v_transaction_id
    from dual;

    return v_transaction_id;
END;

------------------------------------------------------------------------
--to get transaction_id from msc_net_resource_avail table
-----------------------------------------------------------------------------
PROCEDURE add_new_record(m NUMBER, retain_old boolean default false,
                         retain_id boolean default false) IS

  l_units number;
BEGIN
    k :=k +1;
    if retain_id then
       g_tmp_tab(k).transaction_id := g_res_tab(m).transaction_id;
    else
       g_tmp_tab(k).transaction_id := get_transaction_id;
    end if;
    g_tmp_tab(k).parent_id := g_res_tab(m).parent_id;
    g_tmp_tab(k).aggregate_resource_id :=
               g_res_tab(m).aggregate_resource_id;
    g_tmp_tab(k).simulation_set := g_res_tab(m).simulation_set;
    if retain_old then
       g_tmp_tab(k).from_time := g_res_tab(m).from_time;
       g_tmp_tab(k).to_time := g_res_tab(m).to_time;
       g_tmp_tab(k).capacity_units := g_res_tab(m).capacity_units;
    else
       g_tmp_tab(k).from_time := g_change_rec.from_time;
       g_tmp_tab(k).to_time := g_change_rec.to_time;
       if (g_res_inst_set_data) then
         if (g_change_rec.capacity_units = 0 ) then
	    l_units := -1;
	 else
	    l_units := 1;
	 end if;
         g_tmp_tab(k).capacity_units := greatest(g_res_tab(m).capacity_units + l_units,0);
       else
         g_tmp_tab(k).capacity_units := g_change_rec.capacity_units;
       end if;
    end if;
    g_tmp_tab(k).status := 0;
    g_tmp_tab(k).applied := 2;
--    g_tmp_tab(k).updated := 2;
    g_tmp_tab(k).last_update_date := sysdate;
    g_tmp_tab(k).last_updated_by := g_change_rec.last_updated_by;
    g_tmp_tab(k).creation_date := sysdate;
    g_tmp_tab(k).created_by := g_change_rec.last_updated_by;

/*
dbms_output.put_line('add_new_record tmp-trx-from-to-units '||g_tmp_tab(k).transaction_id||' - '||
  g_tmp_tab(k).from_time||' - '||g_tmp_tab(k).to_time||' - '||g_tmp_tab(k).capacity_units);

dbms_output.put_line('add_new_record res-trx-from-to-units '||g_res_tab(m).transaction_id||' - '||
  g_res_tab(m).from_time||' - '||g_res_tab(m).to_time||' - '||g_res_tab(m).capacity_units);
*/
END;


-------------------------------------------------------------------
-- to group the child record to parent record
-------------------------------------------------------------------
PROCEDURE aggregate_child_records(v_plan_id NUMBER) IS

 CURSOR net_resource IS
   SELECT res.department_id, res.resource_id,
          res.organization_id, res.sr_instance_id
   FROM   msc_department_resources res
   WHERE  plan_id = v_plan_id;

 TYPE resource_table IS RECORD
 (   dept_id NUMBER,
     res_id NUMBER,
     org_id NUMBER,
     instance_id NUMBER);

 v_res_table resource_table;

 v_dept_id number:=0;
 v_res_id number:=0;
 v_org_id number:=0;
 v_instance_id number:=0;

BEGIN

   -- loop thru each dept/resource

   open net_resource;
   LOOP
     FETCH net_resource into v_res_table;
     EXIT WHEN net_resource%NOTFOUND;

   -- for each new dept/resource

      v_dept_id := v_res_table.dept_id;
      v_res_id := v_res_table.res_id;
      v_org_id := v_res_table.org_id;
      v_instance_id := v_res_table.instance_id;

   -- delete old parent record first

     delete from msc_net_resource_avail
     where plan_id = v_plan_id
     AND organization_id = v_org_id
     AND sr_instance_id =v_instance_id
     AND department_id = v_dept_id
     AND resource_id = v_res_id
     and parent_id =-1;

      aggregate_one_resource(v_plan_id, v_org_id, v_instance_id,
                             v_dept_id, v_res_id);
   END LOOP;
   close net_resource;
END;

PROCEDURE aggregate_some_resources(v_plan_id NUMBER,
                                  p_org_instance_list varchar2,
                                  p_dept_class_list VARCHAR2,
                                  p_res_group_list VARCHAR2,
                                  p_dept_list varchar2,
                                  p_res_list  varchar2,
                                  p_line_list VARCHAR2) IS
  where_statement varchar2(1000);
  TYPE res_cursor_type IS REF CURSOR;
  res_cursor res_cursor_type;
  sql_statement varchar2(1500);

 TYPE resource_table IS RECORD
 (   dept_id NUMBER,
     res_id NUMBER,
     org_id NUMBER,
     instance_id NUMBER);

 v_res_table resource_table;

BEGIN



  IF p_dept_list IS NOT NULL THEN
    where_statement := where_statement ||
        ' and department_id in (' || p_dept_list || ')';
  ELSIF p_dept_class_list IS NOT NULL THEN
    where_statement := where_statement ||
        ' and department_id in (select distinct department_id ' ||
        ' from msc_department_resources where NVL(department_class,''@@@'') '||
        ' in (' || p_dept_class_list || ') and plan_id = '
           ||to_char(v_plan_id)||
        ' and (sr_instance_id, organization_id) in ('||p_org_instance_list ||'))';
  ELSIF p_res_group_list IS NOT NULL THEN
    where_statement := where_statement ||
        ' and (department_id, resource_id) in (select '||
        ' department_id, resource_id from msc_department_resources where ' ||
        ' NVL(resource_group_name,''@@@'') in ('
        || p_res_group_list || ') and '||
        ' plan_id = '||to_char(v_plan_id)||
        ' and (sr_instance_id, organization_id) in ('||
        p_org_instance_list ||'))';
  END IF;
  IF p_line_list IS NOT NULL THEN
    where_statement := where_statement ||
        ' and department_id IN (' || p_line_list || ')';
  END IF;
  IF p_res_list IS NOT NULL THEN
    where_statement := where_statement ||
        ' and resource_id IN (' || p_res_list || ')';
  END IF;

  where_statement := where_statement ||
       ' ORDER BY organization_id, sr_instance_id, department_id, resource_id';
  if p_org_instance_list is not null then
    sql_statement :=
        'SELECT distinct department_id, resource_id, '||
                       'organization_id, sr_instance_id '||
        'FROM msc_net_resource_avail '||
        'WHERE plan_id = '||to_char(v_plan_id) ||
         ' AND nvl(parent_id, 0) <> -1 ' ||
         ' AND (sr_instance_id, organization_id) in ('||
                    p_org_instance_list ||')' || where_statement;
  else
     sql_statement :=
        'SELECT distinct department_id, resource_id, '||
                       'organization_id, sr_instance_id '||
        'FROM msc_net_resource_avail '||
        'WHERE plan_id = '||to_char(v_plan_id) ||
         ' AND nvl(parent_id, 0) <> -1 ' || where_statement;
  end if;


  OPEN res_cursor FOR sql_statement;
  LOOP
  FETCH res_cursor INTO v_res_table;
     EXIT WHEN res_cursor%NOTFOUND;
     aggregate_one_resource(v_plan_id, v_res_table.org_id,
                            v_res_table.instance_id,v_res_table.dept_id,
                            v_res_table.res_id);
  END LOOP;
  CLOSE res_cursor;

END;

PROCEDURE aggregate_one_resource(v_plan_id NUMBER,
                                  p_org_id NUMBER,
                                  p_instance_id NUMBER,
                                  p_dept_id NUMBER,
                                  p_res_id  NUMBER) IS
 CURSOR bucket IS
   SELECT mpb.bkt_start_date, mpb.bkt_end_date
   FROM   msc_plan_buckets mpb,
          msc_plans mp
   WHERE  mp.plan_id = v_plan_id
     and  mp.plan_id = mpb.plan_id
     and  mp.sr_instance_id = mpb.sr_instance_id
     and  mp.organization_id = mpb.organization_id
     and  mpb.curr_flag =1
   order by mpb.bucket_index;

 v_new_capacity_units number;
 i number;
 v_transaction_id number;

  TYPE BucketRecTyp IS RECORD (
         start_date  DATE,
         end_date    DATE);

  TYPE BucketTabTyp IS TABLE OF BucketRecTyp INDEX BY BINARY_INTEGER;
  v_bucket   BucketTabTyp;

 dummy number;

 CURSOR parent_record IS
    select 1
    from msc_net_resource_avail
    where plan_id = v_plan_id
      and sr_instance_id = p_instance_id
      and organization_id = p_org_id
      and department_id = p_dept_id
      and resource_id = p_res_id
      and parent_id =-1
      and rownum <2;

 CURSOR time_record(v_start_date DATE, v_end_date DATE) IS
     select sum(decode(sign(to_time-from_time),-1,(to_time+86400 - from_time),
                            (to_time-from_time)
                       )/3600*capacity_units)
       from msc_net_resource_avail
       where plan_id = v_plan_id
       and   sr_instance_id = p_instance_id
       and   organization_id = p_org_id
        AND   department_id = p_dept_id
        AND   resource_id = p_res_id
        and   capacity_units >0
        and   nvl(parent_id,0) <> -1
        and   trunc(shift_date) between trunc(v_start_date)
                    and trunc(v_end_date);

 v_agg_resource number;
 CURSOR agg_resource IS
   SELECT aggregate_resource_flag
     from msc_department_resources
    where plan_id = v_plan_id
       and   sr_instance_id = p_instance_id
       and   organization_id = p_org_id
        AND   department_id = p_dept_id
        AND   resource_id = p_res_id;
/*
CURSOR agg_record(v_start_date DATE, v_end_date DATE) IS
     select sum(capacity_units)
       from msc_net_resource_avail
       where plan_id = v_plan_id
       and   sr_instance_id = p_instance_id
       and   organization_id = p_org_id
        AND   department_id = p_dept_id
        AND   resource_id = p_res_id
        and   capacity_units >0
        and   trunc(shift_date) between trunc(v_start_date)
                    and trunc(v_end_date);
*/

BEGIN

   -- if it is an aggregate resource, don't create parent record
    OPEN agg_resource;
    FETCH agg_resource INTO v_agg_resource;
    CLOSE agg_resource;

IF nvl(v_agg_resource,2) =2 THEN
   -- check if the parent record is created already

    OPEN parent_record;
    FETCH parent_record into dummy;
    CLOSE parent_record;
IF dummy is null THEN

   -- populate the bucket dates
   i :=1;
   open bucket;
   LOOP
       FETCH bucket into v_bucket(i);
       EXIT WHEN bucket%NOTFOUND;
       i := i+1;
   END LOOP;
   close bucket;

   For i in 1 .. v_bucket.COUNT LOOP
     -- calculate the new capacity units for each bucket
/*
    if v_agg_resource = 1 then
     OPEN agg_record(v_bucket(i).start_date, v_bucket(i).end_date);
     FETCH agg_record into v_new_capacity_units;
     CLOSE agg_record;

    else
*/
     OPEN time_record(v_bucket(i).start_date, v_bucket(i).end_date);
     FETCH time_record into v_new_capacity_units;
     CLOSE time_record;

      v_new_capacity_units:=nvl(v_new_capacity_units,0);
--    end if;

-- we will insert one for each bucket, even the resource_units is 0

--      if nvl(v_new_capacity_units,0) <>0 then

          select msc_net_resource_avail_s.nextval
          into v_transaction_id
          from dual;

   -- insert parent record

          insert into msc_net_resource_avail
           ( TRANSACTION_ID,
             parent_id,
             PLAN_ID        ,
             ORGANIZATION_ID,
             SR_INSTANCE_ID     ,
             DEPARTMENT_ID                   ,
             RESOURCE_ID                     ,
             SHIFT_DATE                      ,
             CAPACITY_UNITS                 ,
             LAST_UPDATE_DATE               ,
             LAST_UPDATED_BY                ,
             CREATION_DATE                  ,
            CREATED_BY
           )
      values (
         v_transaction_id,
         -1,
         v_plan_id,
         p_org_id,
         p_instance_id,
         p_dept_id,
         p_res_id,
         v_bucket(i).start_date,
         v_new_capacity_units,
         sysdate,
         1,
         sysdate,
         1);

        -- now update the parent_id for the child records
           update msc_net_resource_avail
           set parent_id = v_transaction_id
           where plan_id = v_plan_id
           and   sr_instance_id = p_instance_id
           and   organization_id = p_org_id
           AND   department_id = p_dept_id
           AND   resource_id = p_res_id
           and   capacity_units >=0
           AND   nvl(parent_id,0) <> -1
           and   trunc(shift_date) between trunc(v_bucket(i).start_date)
                    and trunc(v_bucket(i).end_date);
--        end if;
       END LOOP;
       commit;
END IF;
END IF;

END;

PROCEDURE refresh_parent_record(p_plan_id number,
                                p_instance_id number,
                                p_transaction_id number) IS
  cursor c_net_res_avail is
    select organization_id,
           department_id,
           resource_id,
           shift_date
      from msc_net_resource_avail
     where plan_id = p_plan_id
       and transaction_id = p_transaction_id
       and sr_instance_id = p_instance_id;

   v_start_date DATE;
   v_end_date   DATE;
   v_capacity_units NUMBER;
   v_org_id number;
   v_dept_id number;
   v_res_id number;
   v_shift_date date;

   CURSOR bucket IS
        SELECT mpb.bkt_start_date, mpb.bkt_end_date
        FROM   msc_plan_buckets mpb,
               msc_plans mp
        where  mp.plan_id = p_plan_id
          and  mp.plan_id = mpb.plan_id
          and  mp.organization_id = mpb.organization_id
          and  mp.sr_instance_id = mpb.sr_instance_id
          and  mpb.curr_flag =1
          and  v_shift_date between mpb.bkt_start_date and mpb.bkt_end_date;
BEGIN

   OPEN c_net_res_avail;
   FETCH c_net_res_avail into v_org_id, v_dept_id, v_res_id,v_shift_date;
   CLOSE c_net_res_avail;

   OPEN bucket;
   FETCH bucket into v_start_date, v_end_date;
   CLOSE bucket;

     v_capacity_units :=0;
     begin
      select round(sum(decode(sign(to_time-from_time),1,(to_time - from_time),
                                    (to_time+86400-from_time)
                             )/3600*capacity_units),6)
      into v_capacity_units
      from msc_net_resource_avail
      where plan_id = p_plan_id
	and   organization_id = v_org_id
        and   sr_instance_id = p_instance_id
        AND   department_id = v_dept_id
        AND   resource_id = v_res_id
        and   nvl(parent_id, 0) <> -1
        and   capacity_units >0
        and   shift_date between v_start_date and v_end_date;
     exception when no_data_found then
        v_capacity_units :=0;
     end;

     v_capacity_units := nvl(v_capacity_units,0);

 -- update the resource units for parent record
     update msc_net_resource_avail
     set capacity_units = v_capacity_units,
         status =0,
         applied =2,
         updated =2
     where  plan_id = p_plan_id
	and   organization_id = v_org_id
        and   sr_instance_id = p_instance_id
        AND   department_id = v_dept_id
        AND   resource_id = v_res_id
        and   shift_date = v_start_date
        and   parent_id =-1;

END refresh_parent_record;

FUNCTION isFirstOP(p_plan_id number,
                                p_supply_id number,
                                p_changed_op number,
                                p_changed_res number) RETURN boolean IS
  cursor op_c is
    select operation_seq_num,resource_seq_num
      from msc_resource_requirements
      where plan_id = p_plan_id
        and supply_id = p_supply_id
        and parent_id = 2
       order by operation_seq_num,resource_seq_num;
   v_op number;
   v_res number;
BEGIN
   OPEN op_c;
   FETCH op_c INTO v_op, v_res;
   CLOSE op_c;

   if p_changed_op = v_op and p_changed_res = v_res then
      return true;
   else
      return false;
   end if;
END isFirstOP;

PROCEDURE reset_changes IS
BEGIN
  if p_trans_id is not null then
     p_trans_id.delete;
     p_start_time.delete;
     p_end_time.delete;
     p_resource_units.delete;
  end if;
END reset_changes;

PROCEDURE set_sim_res_times(p_plan_id NUMBER,
                           p_avail_checked number,
                           p_sim_start date,
                           p_sim_end date,
                           p_new_start out nocopy date,
                           p_new_end out nocopy date,
                           p_error_status out nocopy varchar2) IS
   p_sim_new_start date;
   p_sim_new_end date;

BEGIN

   FOR a in 1..nvl(sim_res.org_id.last,0) LOOP
     if a <> p_avail_checked then
           -- bug5969889, don't use res_units from routing for simultaneous res
           get_new_time(p_plan_id, sim_res.org_id(a), sim_res.inst_id(a),
                        sim_res.dept_id(a), sim_res.res_id(a),
                        p_sim_start,
                        sim_res.res_hours(a), sim_res.assign_units(a),
                        false,
                        p_new_start, p_new_end, p_error_status);
           if p_error_status =  'NO_RES_AVAIL' then
              exit;
           end if;
     end if;

     if p_new_start <> p_sim_start or
        p_new_end <> p_sim_end then
-- res(a) can not start/end at the same time as other res
        p_sim_new_start := p_new_start;
        p_sim_new_end := p_new_end;
        set_sim_res_times(p_plan_id, a, p_sim_new_start,p_sim_new_end,
                          p_new_start,p_new_end,p_error_status);
        exit;
     end if;

   END LOOP;

END set_sim_res_times;

PROCEDURE reset_sim_res IS
BEGIN
   sim_res.org_id.delete;
   sim_res.inst_id.delete;
   sim_res.dept_id.delete;
   sim_res.res_id.delete;
   sim_res.res_hours.delete;
   sim_res.assign_units.delete;
   sim_res.op_seq_id.delete;
   sim_res.rt_seq_id.delete;

END reset_sim_res;


PROCEDURE calculate_ops(p_plan_id NUMBER,
                                p_supply_id number,
                                p_changed_op number,
                                p_changed_res number,
                                p_changed_date date,
                                p_new_end_date date,
                                p_status out nocopy varchar2 ) IS

  cursor time_c is
    select transaction_id, operation_seq_num,resource_seq_num,
           organization_id,sr_instance_id,department_id,resource_id,
           resource_hours,assigned_units,
           nvl(firm_start_date,start_date),
           nvl(firm_end_date,end_date),
           operation_sequence_id,
           routing_sequence_id
      from msc_resource_requirements
      where plan_id = p_plan_id
        and supply_id = p_supply_id
        and parent_id = 2
       order by operation_seq_num,resource_seq_num;


  p_op numTab;
  p_res numTab;
  p_org_id numTab;
  p_inst_id numTab;
  p_dept_id numTab;
  p_res_id numTab;
  p_res_hours numTab;
  p_assign_units numTab;
  p_op_seq_id numTab;
  p_rt_seq_id numTab;

  p_new_start date;
  p_new_end date;
  p_current_op number;
  p_current_res number;

  p_sim_start date;
  p_sim_end date;

  k number := 0;
  p_effective_date date;
  p_disable_date date;
BEGIN

  reset_changes;

  OPEN time_c;
  FETCH time_c BULK COLLECT INTO p_trans_id, p_op, p_res,
                       p_org_id, p_inst_id, p_dept_id, p_res_id,
                       p_res_hours, p_assign_units,p_start_time, p_end_time,
                       p_op_seq_id, p_rt_seq_id;
  CLOSE time_c;

  FOR a in 1..nvl(p_op.last,0) LOOP

     p_resource_units(a) := routing_res_unit(p_plan_id, p_op_seq_id(a),
                       p_rt_seq_id(a), p_res_id(a),p_assign_units(a));

     if a = 1 then
        p_current_op := p_op(a);
        p_current_res := p_res(a);
        p_new_start := p_changed_date;
        p_new_end := p_new_end_date;

     end if;-- if a = 1 then

     if p_op(a) <> p_current_op or
        p_res(a) <> p_current_res then  -- new op/res

        p_current_op := p_op(a);
        p_current_res := p_res(a);

        if k > 0 then -- calculate simultaneous resources times
--dbms_output.put_line('k='||k);
           set_sim_res_times(p_plan_id,1,
                       p_sim_start, p_sim_end,
                       p_new_start, p_new_end, p_status);
           for i in 1..nvl(sim_res.org_id.last,0) loop
                 p_start_time(a-i) := p_new_start;
                 p_end_time(a-i) := p_new_end;
                 p_resource_units(a-i) := p_assign_units(a-i);
           end loop;
           k :=0;
           reset_sim_res;
        end if;
            -- use end time of prev op as start time

        get_new_time(p_plan_id, p_org_id(a), p_inst_id(a),
                       p_dept_id(a), p_res_id(a),
                       p_end_time(a-1), p_res_hours(a), p_resource_units(a),
                       false,
                       p_new_start, p_new_end, p_status);
      elsif a > 1 then -- simultaneous resources
          k := k+1;
--dbms_output.put_line('k='||k||', a='||a);
          if k = 1 then -- get the first sim res
             sim_res.org_id(k) := p_org_id(a-1);
             sim_res.inst_id(k) := p_inst_id(a-1);
             sim_res.dept_id(k) := p_dept_id(a-1);
             sim_res.res_id(k) := p_res_id(a-1);
             sim_res.res_hours(k) := p_res_hours(a-1);
             sim_res.assign_units(k) := p_assign_units(a-1);
             sim_res.op_seq_id(k) := p_op_seq_id(a-1);
             sim_res.rt_seq_id(k) := p_rt_seq_id(a-1);
             p_sim_start :=  p_start_time(a-1);
             p_sim_end :=  p_end_time(a-1);
             k := k+1;
          end if;
          sim_res.org_id(k) := p_org_id(a);
          sim_res.inst_id(k) := p_inst_id(a);
          sim_res.dept_id(k) := p_dept_id(a);
          sim_res.res_id(k) := p_res_id(a);
          sim_res.res_hours(k) := p_res_hours(a);
          sim_res.assign_units(k) := p_assign_units(a);
          sim_res.op_seq_id(k) := p_op_seq_id(a);
          sim_res.rt_seq_id(k) := p_rt_seq_id(a);

      end if;

      p_start_time(a) := p_new_start;
      p_end_time(a) := p_new_end;

 -- dbms_output.put_line(a||','||to_char(p_start_time(a),'MM/DD/RRRR HH24:MI')||','||to_char(p_end_time(a),'MM/DD/RRRR HH24:MI')||','||p_res_hours(a));

  END LOOP;

  --5578138,
   ProcessDates(p_plan_id, p_supply_id, p_effective_date, p_disable_date );
  if p_new_end > p_disable_date or
     p_new_end < p_effective_date then
     p_status := 'SUPPLY_OUTSIDE_PROCESS_DATE';
  end if;

END calculate_ops;

PROCEDURE move_res_req(p_plan_id number,
                                p_supply_id number) IS
  a number;
BEGIN

  forall a in 1..p_trans_id.count
        update msc_resource_requirements
           set firm_start_date = p_start_time(a),
               firm_end_date = p_end_time(a),
               assigned_units = p_resource_units(a), --bug 5973698
               status = 0,
               applied =2,
               firm_flag = 7
         where plan_id = p_plan_id
           and transaction_id = p_trans_id(a);
--dbms_output.put_line('new due date='||to_char(p_new_end,'MM/DD/RRRR HH24:MI'));

  a := nvl(p_trans_id.last,0);
  if a > 0 then
     update msc_supplies
     set       status = 0,
               applied =2,
               firm_planned_type = 1,
               firm_date = p_end_time(a),
               firm_quantity = new_order_quantity
    where plan_id = p_plan_id
           and transaction_id = p_supply_id;
  end if;

END move_res_req;

PROCEDURE get_new_time(p_plan_id NUMBER,
                                  p_org_id NUMBER,
                                  p_inst_id NUMBER,
                                  p_dept_id NUMBER,
                                  p_res_id  NUMBER,
                                  p_changed_date date,
                                  p_res_hours number,
                                  p_assign_units number,
                                  p_first_activity boolean,
                                  p_new_start out nocopy date,
                                  p_new_end out nocopy date,
                                  p_error_status out nocopy varchar2) IS
  p_valid_start boolean := false;

  p_cum  number := 0;
  p_start date;
  p_end date;

  cursor avail_c is
    select shift_date, from_time, to_time, capacity_units
       from msc_net_resource_avail
      where plan_id = p_plan_id
        and organization_id = p_org_id
        and sr_instance_id = p_inst_id
        and department_id = p_dept_id
        and resource_id = p_res_id
        and capacity_units > 0
        and nvl(parent_id, 0) <> -1
        and shift_date >= trunc(p_changed_date)
      order by shift_date, from_time, to_time;

 cursor infinite_c is
    select 1
       from msc_net_resource_avail
      where plan_id = p_plan_id
        and organization_id = p_org_id
        and sr_instance_id = p_inst_id
        and department_id = p_dept_id
        and resource_id = p_res_id
        and nvl(parent_id, 0) <> -1;

  avail_rec avail_c%ROWTYPE;
  v_infinite number;
  v_res_minutes_per_unit number;
  v_res_minutes number;

BEGIN
--dbms_output.put_line(p_org_id||','||p_inst_id||','||p_dept_id||','||p_res_id);
--dbms_output.put_line('get new time: '||to_char(p_changed_date,'MM/DD/RRRR HH24:MI')||','||p_res_hours||','||p_assign_units);
  OPEN infinite_c;
  FETCH infinite_c INTO v_infinite;
  CLOSE infinite_c;

  --bug5973236, need to run up to minute level
  v_res_minutes := round(p_res_hours*60,0);

  if nvl(p_assign_units,0) <> 0 then
     --bug5973236, need to ceil to minute level for per unit time
     v_res_minutes_per_unit := ceil(v_res_minutes/p_assign_units);
  else
     v_res_minutes_per_unit :=  v_res_minutes;
  end if;

  if v_infinite is null then
     -- dbms_output.put_line('infinite resource');
     p_new_start := p_changed_date;
     p_new_end := p_new_start + (v_res_minutes_per_unit/(24*60));
     return;
  end if;

  OPEN avail_c;
  LOOP
     FETCH avail_c INTO avail_rec;
     EXIT WHEN avail_c%NOTFOUND;

        p_start := avail_rec.shift_date + avail_rec.from_time/86400 ;
        if avail_rec.to_time > avail_rec.from_time then
           p_end := avail_rec.shift_date + avail_rec.to_time/86400 ;
        else
           p_end := avail_rec.shift_date + avail_rec.to_time/86400 + 1;
        end if;
--dbms_output.put_line('avail dates '||to_char(p_start,'MM/DD/RRRR HH24:MI')||','||to_char(p_end,'MM/DD/RRRR HH24:MI'));

        if p_start <= p_changed_date and -- p_changed_date is not in break
            p_changed_date <= p_end and
            p_assign_units <= avail_rec.capacity_units then
           p_valid_start := true;
           p_start := p_changed_date;
           p_new_start := p_changed_date;
--dbms_output.put_line('p_changed_start='||to_char(p_new_start,'MM/DD/RRRR HH24:MI'));
        end if;

        if not(p_valid_start) and
           p_changed_date < p_start and  -- p_new_date is in a break
           p_assign_units <= avail_rec.capacity_units then
           if p_first_activity then -- can start in a break
              p_error_status := 'START_IN_BREAK';
           end if; -- if p_first_activity then
              p_new_start := p_start;  -- need to move the date
              p_valid_start := true;
--dbms_output.put_line('p_new_start='||to_char(p_new_start,'MM/DD/RRRR HH24:MI'));
        end if; -- if not(p_valid_start) and

        if p_valid_start then -- find the end time
 --dbms_output.put_line(round(p_cum,2)||','||to_char(p_start,'MM/DD/RRRR HH24:MI')||','||to_char(p_end,'MM/DD/RRRR HH24:MI'));
           if v_res_minutes_per_unit <= p_cum + (p_end-p_start)*24*60 then
              p_new_end := p_start +
                              (v_res_minutes_per_unit - p_cum)/(24*60);
--dbms_output.put_line('p_new_end='||to_char(p_new_end,'MM/DD/RRRR HH24:MI'));
              exit;
           else
              p_cum := p_cum + (p_end - p_start)*24*60;
           end if;
        end if; -- if p_valid_start then
  END LOOP;

  CLOSE avail_c;
--dbms_output.put_line(to_char(p_start,'MM/DD/RRRR HH24:MI')||','||to_char(p_end,'MM/DD/RRRR HH24:MI')||','||to_char(p_new_start,'MM/DD/RRRR HH24:MI')||','||to_char(p_new_end,'MM/DD/RRRR HH24:MI'));
  if p_new_end is null or p_new_start is null then
  -- no avail resource found, use the last avail res end time
     p_new_start := nvl(p_new_start, nvl(p_start,p_changed_date));
     p_new_end := nvl(p_new_end, nvl(p_end, p_new_start+1/60));
     p_error_status := 'NO_RES_AVAIL';
  end if;

END get_new_time;

Procedure ProcessDates(p_plan_id in number,
                            p_supply_id in number,
                            p_effective_date out nocopy date,
                            p_disable_date out nocopy date) IS
  CURSOR eff_c IS
   select mpe.effectivity_date, mpe.disable_date
     from msc_process_effectivity mpe,
          msc_supplies ms
    where ms.plan_id = p_plan_id
      and ms.transaction_id = p_supply_id
      and mpe.plan_id = ms.plan_id
      and mpe.process_sequence_id = ms.process_seq_id;
BEGIN
       OPEN eff_c;
       FETCH eff_c INTO p_effective_date, p_disable_date;
       CLOSE eff_c;
END ProcessDates;

FUNCTION routing_res_unit(p_plan_id number, p_op_seq_id number,
                      p_rt_seq_id number, p_res_id number,
                      p_assign_units number) RETURN number IS
  --bug 5846499, get assign_units from routing
  CURSOR unit_c IS
   select nvl(resource_units, max_resource_units)
     from msc_operation_resources
    where plan_id = p_plan_id
      and operation_sequence_id = p_op_seq_id
      and routing_sequence_id = p_rt_seq_id
      and resource_id = p_res_id;
  v_assign_units number;
BEGIN

  OPEN unit_c;
  FETCH unit_c INTO v_assign_units;
  CLOSE unit_c;

  /* bug8835167, if units from routing is greater than res_req table, use
     the one from res_req  */
  if v_assign_units > p_assign_units then
     return  p_assign_units;
  end if;

  return nvl(v_assign_units,p_assign_units);
END routing_res_unit;

PROCEDURE verify_data(p_plan_id number, p_supply_id number) IS
  p_org_id NUMBER;
  p_inst_id NUMBER;
  p_dept_id NUMBER;
  p_res_id  NUMBER;
  p_start_date date;
  p_end_date date;
  p_start_time date;
  p_end_time date;

  cursor mrr_c is
    select transaction_id, operation_seq_num,resource_seq_num, assigned_units,
           organization_id,sr_instance_id,department_id,resource_id,
          to_char(firm_start_date,'MM/DD/RRRR HH24:MI') firm_start_time,
           to_char(firm_end_date,'MM/DD/RRRR HH24:MI') firm_end_time,
           to_char(start_date,'MM/DD/RRRR HH24:MI') start_time,
           to_char(end_date,'MM/DD/RRRR HH24:MI') end_time,
           resource_hours, overloaded_capacity
      from msc_resource_requirements
      where plan_id = p_plan_id
        and supply_id = p_supply_id
        and parent_id = 2
       order by operation_seq_num,resource_seq_num;

  cursor avail_c is
    select shift_date, from_time, to_time, capacity_units
       from msc_net_resource_avail
      where plan_id = p_plan_id
        and organization_id = p_org_id
        and sr_instance_id = p_inst_id
        and department_id = p_dept_id
        and resource_id = p_res_id
        and capacity_units > 0
        and nvl(parent_id, 0) <> -1
        and shift_date >= trunc(p_start_time)
        and shift_date <= trunc(p_end_time)
      order by 1,2,3;

  avail_rec avail_c%ROWTYPE;
  mrr_rec mrr_c%ROWTYPE;

BEGIN
 -- dbms_output.put_line(p_plan_id||','||p_supply_id);
  OPEN mrr_c;
  LOOP
   FETCH mrr_c INTO mrr_rec;
   EXIT WHEN mrr_c%NOTFOUND;
--dbms_output.put_line('req');
      if to_date(mrr_rec.firm_start_time,'MM/DD/RRRR HH24:MI') <
         to_date(mrr_rec.start_time,'MM/DD/RRRR HH24:MI') then
        p_start_time := to_date(mrr_rec.firm_start_time,'MM/DD/RRRR HH24:MI');
      else
        p_start_time := to_date(mrr_rec.start_time,'MM/DD/RRRR HH24:MI');
      end if;
      if to_date(mrr_rec.firm_end_time,'MM/DD/RRRR HH24:MI') >
         to_date(mrr_rec.end_time,'MM/DD/RRRR HH24:MI') then
        p_end_time := to_date(mrr_rec.firm_end_time,'MM/DD/RRRR HH24:MI');
      else
        p_end_time := to_date(mrr_rec.end_time,'MM/DD/RRRR HH24:MI');
      end if;
/*
     dbms_output.put_line(mrr_rec.operation_seq_num||','||
                          mrr_rec.resource_seq_num||',au:'||
                          mrr_rec.assigned_units||',rh:'||
                          mrr_rec.resource_hours||','||
                          mrr_rec.firm_start_time||','||
                          mrr_rec.firm_end_time||','||
                          mrr_rec.start_time||','||
                          mrr_rec.end_time);
*/
       p_org_id := mrr_rec.organization_id;
       p_inst_id := mrr_rec.sr_instance_id;
       p_dept_id := mrr_rec.department_id;
       p_res_id := mrr_rec.resource_id;

-- dbms_output.put_line('avail ');
  OPEN avail_c;
  LOOP
   FETCH avail_c INTO avail_rec;
   EXIT WHEN avail_c%NOTFOUND;

        p_start_date := avail_rec.shift_date + avail_rec.from_time/86400 ;
        if avail_rec.to_time > avail_rec.from_time then
           p_end_date := avail_rec.shift_date + avail_rec.to_time/86400 ;
        else
           p_end_date := avail_rec.shift_date + avail_rec.to_time/86400 + 1;
        end if;
/*
     dbms_output.put_line(avail_rec.shift_date||','||
                          avail_rec.from_time||','||
                          avail_rec.to_time||','||
                          avail_rec.capacity_units||','||
                          to_char(p_start_date,'MM/DD/RRRR HH24:MI')||','||
                          to_char(p_end_date,'MM/DD/RRRR HH24:MI'));
*/
  END LOOP;
  CLOSE avail_c;
  END LOOP;
  CLOSE mrr_c;
END verify_data;

END;

/
