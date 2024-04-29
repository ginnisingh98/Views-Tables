--------------------------------------------------------
--  DDL for Package Body MSC_UNDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_UNDO" AS
/* $Header: MSCUNDOB.pls 120.1 2005/06/07 18:15:40 appldev  $ */

  procedure UNDO (undoId undoIdTblType,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2) IS

	i NUMBER;

	l_undo_id NUMBER;
	s_undo_id NUMBER;
	l_action NUMBER;
	l_table_changed NUMBER;
	l_transaction_id NUMBER;
	l_plan_id NUMBER;
	l_sr_instance_id NUMBER;
 	l_last_update_date DATE;

	l_column_changed VARCHAR2(240);
	l_new_Value VARCHAR2(240);
	l_old_value VARCHAR2(240);
        l_column_type VARCHAR2(20);

	count_flag number;

  cursor c_mst ( v_undo_id number) is
	select plan_id,
		transaction_id,
		sr_instance_id,
		table_changed,
		action,
		last_update_date
	from msc_undo_summary
	where undo_id = v_undo_id;

  cursor c_dtl(v_plan_id number, v_undo_id number)  is
	select column_changed,
		old_value,
		new_value,
		column_type
	from msc_undo_details
	where plan_id = v_plan_id
	and undo_id = v_undo_id;
  cursor c_supp (v_plan_id number, v_undo_id number) is
	select undo_id,transaction_id, sr_instance_id
	from msc_undo_summary
	where plan_id = v_plan_id
	and ( undo_id = v_undo_id
		or parent_id = v_undo_id )
	and table_changed = 3
	and action=2;
  begin
    -- initialize message list
    FND_MSG_PUB.initialize;
    set_Vars;
    IF undoid.count = 0  THEN
        x_return_status := fnd_api.g_ret_sts_success;
	return;
    END IF;
    i := undoid.first;
    LOOP
        l_undo_id := undoid(i).undo_id;
        l_undo_id := undo_validate(l_undo_id,
			x_return_status,
			x_msg_count,
			x_msg_data);
	if (l_undo_id > 0 ) then
	  open c_mst(l_undo_id);
 	  fetch c_mst into l_plan_id,
			l_transaction_id,
			l_sr_instance_id,
			l_table_changed,
			l_action,
			l_last_update_date;
	  close c_mst ;
	  if ( l_plan_id is not null and l_plan_id <> -1 ) then

	    if ( l_action = inserted ) then
	       --undo an inserted record
	       insert_table(l_undo_id , l_table_changed ,
			l_plan_id , l_transaction_id ,
			l_sr_instance_id, x_return_status,
			x_msg_count, x_msg_data );

	        Begin
	       -- if (l_table_changed in ( 3,4) ) then
               -- cholpon
                  if (l_table_changed in ( 3,4, 8 ) ) then
	          Delete from msc_undo_details
	          where plan_id = l_plan_id
		    and (undo_id = l_undo_id
		    or undo_id in ( select undo_id
				from msc_undo_summary
				where plan_id = l_plan_id
				and parent_id  = l_undo_id));

	     	  Delete from msc_undo_summary
	     	  where plan_id = l_plan_id
 	          and (undo_id = l_undo_id
		  or parent_id = l_undo_id);
	        else
	          Delete from msc_undo_summary
	          where plan_id = l_plan_id
		  and undo_id = l_undo_id;

	          Delete from msc_undo_summary
	          where plan_id = l_plan_id
		  and undo_id = l_undo_id;
	        end if;
                Exception
	          When others then
	        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                	FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'UNDO');
	        	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		    		p_data=>x_msg_data);
	        End ;
	    elsif ( l_action = updated ) then
	      if (l_table_changed = 3) then
	      open c_supp(l_plan_id, l_undo_id);
	      loop
		fetch c_supp into s_undo_id, l_transaction_id, l_sr_instance_id;
		exit when c_supp%notfound;

		open c_dtl(l_plan_id, s_undo_id);
		loop
	          fetch c_dtl into l_column_changed, l_old_value,
			l_new_value, l_column_type;
		  exit when c_dtl%notfound;

	           --undo an updated record from undo_details
   		   update_table(l_table_changed,
			l_column_changed,
			l_old_value, l_new_value,l_column_type,
			l_plan_id, l_sr_instance_id,
			l_transaction_id, x_return_status,
			x_msg_count, x_msg_data, s_undo_id );
	        end loop;
	        close c_dtl;
	      end loop;
	      close c_supp;
	     else
	       open c_dtl(l_plan_id, l_undo_id);
	       loop
	         fetch c_dtl into l_column_changed, l_old_value,
			l_new_value , l_column_type;
	         exit when c_dtl%notfound;

	         --undo an updated record from undo_details
 	         update_table(l_table_changed,
			l_column_changed,
			l_old_value, l_new_value,l_column_type,
			l_plan_id, l_sr_instance_id,
			l_transaction_id, x_return_status,
			x_msg_count, x_msg_data, l_undo_id );
	       end loop;
	       close c_dtl;
             end if;
	     --end undo update table
	     Begin
	     if (l_table_changed in (3,4) ) then

	       Delete from msc_undo_details
	       where plan_id = l_plan_id
		and (undo_id = l_undo_id
		or undo_id in ( select undo_id
				from msc_undo_summary
				where plan_id = l_plan_id
				and parent_id  = l_undo_id));

	       Delete from msc_undo_summary
	       where plan_id = l_plan_id
		and (undo_id = l_undo_id
		or parent_id = l_undo_id);
	     else
	       Delete from msc_undo_details
	       where plan_id = l_plan_id
		and undo_id = l_undo_id;

	       Delete from msc_undo_summary
	       where plan_id = l_plan_id
		and undo_id = l_undo_id;

	     end if;
	     -- end  delete undo_details

             Exception
	       When others then
	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              	FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'UNDO');
	        FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
			p_data=>x_msg_data);
	     End ;

	  elsif (l_action in (3)) then
	  Begin
	     Delete from msc_undo_summary
	     where plan_id = l_plan_id
		and undo_id = l_undo_id;
             Exception
	     When others then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'UNDO');
	     FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data=>x_msg_data);
	  End ;
  	end if;
      end if;
    end if;
    EXIT WHEN i = undoid.last ;
    i := undoid.next(i);

    END LOOP;
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
		p_data=>x_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'UNDO');
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data=>x_msg_data);
  end UNDO;

  procedure STORE_UNDO (table_changed NUMBER,
		action NUMBER,
		transaction_id NUMBER,
		plan_id NUMBER,
		sr_instance_id NUMBER,
		parent_id NUMBER,
		changed_values MSC_UNDO.ChangeRGType,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2,
		undo_id NUMBER DEFAULT NULL) IS
  i number;
  l_column_changed VARCHAR2(30);
  l_column_changed_text VARCHAR2(240);
  l_column_type VARCHAR2(10);
  l_old_value VARCHAR2(240);
  l_new_value  VARCHAR2(240);

  v_undo_id NUMBER;

  l_plan_id NUMBER := plan_id;
  l_parent_id NUMBER := parent_id;
  l_transaction_id NUMBER:= transaction_id;
  begin
    --Initializa message list
    FND_MSG_PUB.initialize;

    set_vars;

    if (plan_id is null or plan_id = -1 ) then
 	return;
    end if;

    if ( action not in (inserted, updated) ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.add_exc_msg('MSC_UNDO',
		'DEVELOPER ERROR : Invalid action passed to STORE_UNDO');
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data=>x_msg_data);
        Return ;
    end if;

    if ( (action = inserted) or (action = updated) ) then
        if ( action = updated) and (changed_values.count = 0) then
		x_return_status := fnd_api.g_ret_sts_success;
		return;
	end if;
	BEGIN
	if ( table_changed in (1,2,5,6,7) ) then
	  select MSC_UNDO_SUMMARY_S.nextval
	  into v_undo_id
	  from dual;
	else
	  v_undo_id := undo_id;
	end if;
	  --Insert a record into MSC_UNDO_SUMMARY
	  INSERT INTO MSC_UNDO_SUMMARY (
		undo_id,
		plan_id,
		sr_instance_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		table_changed,
		action,
		transaction_id,
		bookmark_name,
		parent_id )
	  VALUES (
		v_undo_id,
		plan_id,
		sr_instance_id,
		v_user_id,
		SYSDATE,
		v_user_id,
		SYSDATE,
		v_last_update_login,
		table_changed,
		action,
		transaction_id,
		NULL,
		parent_id);
	EXCEPTION
	  WHEN OTHERS THEN
	    ROLLBACK;
	    fnd_msg_pub.add_Exc_msg('MSC_UNDO', 'STORE_UNDO');
	    fnd_msg_pub.count_and_get(p_count=>x_msg_Count, p_data=>x_msg_data);
	END ;
    end if;
    if ( action = updated ) then

      i := changed_values.first;
      LOOP
	l_column_changed := changed_values(i).column_changed;
	l_column_changed_text := changed_values(i).column_changed_text;
	l_column_type := changed_values(i).column_type ;
	l_old_value :=  changed_values(i).Old_Value ;
	l_new_value :=    changed_values(i).New_Value ;

	BEGIN
	     INSERT INTO MSC_UNDO_DETAILS (
		UNDO_ID,
		PLAN_ID,
		COLUMN_CHANGED,
		COLUMN_CHANGED_TEXT,
		COLUMN_TYPE,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OLD_VALUE,
		NEW_VALUE )
	    VALUES (
		v_undo_id,
		plan_id,
		l_column_changed,
		l_column_changed_text,
		l_column_type,
		v_user_id,
		sysdate,
		v_user_id,
		sysdate,
		v_last_update_login,
		l_old_value,
		l_new_value );

        EXIT WHEN i = changed_values.last ;
        i := changed_values.next(i);

	EXCEPTION
	  WHEN OTHERS THEN
	    --ROLLBACK;
	    fnd_msg_pub.add_Exc_msg('MSC_UNDO', 'STORE_UNDO');
	    fnd_msg_pub.count_and_get(p_count=>x_msg_Count, p_data=>x_msg_data);
	END ;
      END LOOP;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  end STORE_UNDO;

  procedure ADD_BOOKMARK(bookmark_name VARCHAR2,
		action NUMBER,
		plan_id NUMBER,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2) IS

  v_undo_id number;

  begin
    set_vars;
    FND_MSG_PUB.Initialize;

    if (plan_id is null or plan_id = -1) then
	return;
    end if;

    IF ( action not in
	(bookmark, start_online, replan_start, replan_stop, stop_online) ) THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_msg_count := 1;
	x_msg_data := 'DEVELOPER ERROR : '
		||' Invalid Action passed to MSC_UNDO.add_bookmark';
	 FND_MSG_PUB.count_and_get(p_count =>x_msg_count,
		p_data=>x_msg_data );
    ELSE
        SELECT MSC_UNDO_SUMMARY_S.nextval
	INTO v_undo_id
	from dual;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Insert a record into MSC_UNDO_SUMMARY
	INSERT INTO MSC_UNDO_SUMMARY (
		undo_id,
		plan_id,
		sr_instance_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		table_changed,
		action,
		transaction_id,
		bookmark_name )
	VALUES (
		v_undo_id,
		plan_id,
		0,
		v_user_id,
		SYSDATE,
		v_user_id,
		SYSDATE,
		v_last_update_login,
		NULL,
		action,
		0,
		bookmark_name );
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'Add_Bookmark');
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);

  end ADD_BOOKMARK;


--Private procedures

PROCEDURE insert_table (p_undo_id NUMBER,
			p_table_changed NUMBER,
			p_plan_id NUMBER,
			p_transaction_id NUMBER,
			p_sr_instance_id NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2) IS

  cursor c_net_res (l_undo_id number) is
	select distinct a.sr_instance_id,
                        a.transaction_id,
		        b.old_value,
                        a.action,
                        b.column_changed
	from msc_undo_summary a,
	  msc_undo_details b
	where a.undo_id = b.undo_id (+)
	  and (a.undo_id = l_undo_id
	     or a.parent_id = l_undo_id);


 /*
  cursor c_demand_mds (l_plan number, l_instance number, l_trx number) is
	select origination_type
	from msc_demands
	where plan_id = l_plan
	and sr_instance_id = l_instance
	and demand_id = l_trx;
*/
  l_sr_instance_id NUMBER;
  l_transaction_id NUMBER;
  l_old_value NUMBER;
  l_action NUMBER;
  ll_undo_id NUMBER;
  l_column_name varchar2(30);

  l_order_type NUMBER;

BEGIN
	-- Initialize message list
	FND_MSG_PUB.initialize;

	--Set the User-id
	set_vars;

	  if ( p_table_changed = 1 ) then
	    --Msc_supplies
	   /*
	    Delete from msc_supplies
		where transaction_id = p_transaction_id
		and plan_id = p_plan_id
		and sr_instance_id = p_sr_instance_id ;
	   */
	    update msc_supplies
		set firm_quantity = 0,
		  firm_planned_type = 0,
		  status = 0,
		  applied = 2
		where transaction_id = p_transaction_id
		and plan_id = p_plan_id
		and sr_instance_id = p_sr_instance_id ;
	  elsif ( p_table_changed = 2 ) then
	    --Msc_demands
	    /*
	    open c_demand_mds(p_plan_id,p_sr_instance_id, p_transaction_id);
	    fetch c_demand_mds into l_order_type;
	    close c_demand_mds;
	    if (l_order_type = 8 ) then
	    */
	      update msc_demands
		set firm_quantity = 0,
		        status = 0,
			applied = 2
		where plan_id = p_plan_id
		  and demand_id = p_transaction_id
		  and sr_instance_id = p_sr_instance_id;
	    /*
	    else
	      Delete from msc_demands
		where demand_id = p_transaction_id
		and plan_id = p_plan_id
		and sr_instance_id = p_sr_instance_id ;
	    end if;
	    */
	  elsif ( p_table_changed = 3 ) then
	    --Msc_supplier_capacities
	    /*
	    Delete from msc_supplier_capacities
		where transaction_id in (select transaction_id
			from msc_undo_summary
			where plan_id = p_plan_id
			and (undo_id = p_undo_id or parent_id = p_undo_id))
		and plan_id = p_plan_id ;
	    */
		update msc_supplier_capacities
		  set capacity = 0,
			status = 0,
			applied = 2
		where plan_id = p_plan_id
		  and transaction_id in (select transaction_id
			from msc_undo_summary
			where plan_id = p_plan_id
			and (undo_id = p_undo_id or parent_id = p_undo_id));
	  elsif ( p_table_changed in ( 4, 8) ) then
	    --Msc_net_resource_Avail
	    -- bug 1314938 -  typical one .. do not delete the row,
            --instead update the capacity to zero, for this record and its parent record
/*
	    Delete from msc_net_resource_avail
		where transaction_id = p_transaction_id
		and plan_id = p_plan_id
		and sr_instance_id = p_sr_instance_id ;
*/
	      open c_net_res(p_undo_id);
	      loop
	        fetch c_net_res into l_sr_instance_id,
			l_transaction_id, l_old_value,
			l_action, l_column_name;
                exit when c_net_res%notfound;
 		if (l_action = 1) then
		  update msc_net_resource_avail
		    set capacity_units = -1,
		        status = 0,
			applied = 2
		    where plan_id = p_plan_id
		    and  sr_instance_id = l_sr_instance_id
		    and transaction_id = l_transaction_id;
		else
		  update msc_net_resource_avail
		    set capacity_units =
                          decode(l_column_name,'CAPACITY_UNITS',
                                    l_old_value,capacity_units),
                        from_time =
                          decode(l_column_name,'FROM_TIME',
                                    l_old_value,from_time),
                        to_time =
                          decode(l_column_name,'TO_TIME',
                                    l_old_value,to_time),
			status = 0,
			applied = 2
		  where plan_id = p_plan_id
		    and  sr_instance_id = l_sr_instance_id
		    and transaction_id = l_transaction_id;

                 --cholpon update resources as well
                  if (p_table_changed = 8) then
                       update msc_net_res_inst_avail
                        set capacity_units =
                          decode(l_column_name,'CAPACITY_UNITS',
                                    l_old_value,capacity_units),
                        from_time =
                          decode(l_column_name,'FROM_TIME',
                                    l_old_value,from_time),
                        to_time =
                          decode(l_column_name,'TO_TIME',
                                    l_old_value,to_time),
                        status = 0,
                        applied = 2
                     where plan_id = p_plan_id
                      and  sr_instance_id = l_sr_instance_id
                      and inst_transaction_id = l_transaction_id;
                  end if;

 		end if;

                -- need to recalculate the parent records

                msc_update_resource.refresh_parent_record(
                     p_plan_id,l_sr_instance_id, l_transaction_id);
	      end loop;
	      close c_net_res;


	  elsif ( p_table_changed = 5 ) then

	    --Msc_plans
	    Delete from msc_plans
		where plan_id = p_plan_id ;
	  elsif ( p_table_changed = 7 ) then
            -- Trips
             delete from msc_shipments
              where plan_id = p_plan_id
                and sr_instance_id = l_sr_instance_id
                and shipment_id = l_transaction_id;
	  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'INSERT_TABLE');
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
END insert_table ;

PROCEDURE set_vars IS
BEGIN

  v_user_id := FND_GLOBAL.user_id;
  v_last_update_login := FND_GLOBAL.login_id;

END set_vars;

PROCEDURE update_table(p_table_changed NUMBER,
			p_column_changed VARCHAR2,
			p_old_value VARCHAR2,
			p_new_value VARCHAR2,
			p_column_type VARCHAR2,
			p_plan_id NUMBER,
			p_sr_instance_id NUMBER,
			p_transaction_id NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2,
			p_undo_id NUMBER) IS

  update_str varchar2(500);
  set_str varchar2(500);
  where_str varchar2(500);
  sql_string VARCHAR2(1000);
  l_parent_id NUMBER;

  l_sr_instance_id number;
  l_transaction_id number;
  l_old_value number;
  l_action number;

  ll_undo_id NUMBER;

  cursor c_net_res (l_undo_id number) is select
	 distinct a.sr_instance_id,
                        a.transaction_id,
		        b.old_value,
                        a.action,
                        b.column_changed
	from msc_undo_summary a,
	  msc_undo_details b
	where a.undo_id = b.undo_id (+)
	  and (a.undo_id = l_undo_id
	     or a.parent_id = l_undo_id);
  l_column_name varchar2(30);

BEGIN
  -- Initialize message list
  FND_MSG_PUB.Initialize;

  --Set the user-id
  set_vars;

	    if (p_table_changed = 1) then
 		 update_str := 'UPDATE MSC_SUPPLIES SET STATUS=0, APPLIED=2, ';
		 if (p_column_type = 'DATE') then
		  set_str := p_column_changed
			||' = fnd_date.canonical_to_date(:p_old_value) ';
		else
		  set_str := p_column_changed||' = :p_old_value ';
		end if;
		 where_str := ' WHERE plan_id = :p_plan_id '
			||' AND transaction_id = :p_transaction_id '
			||' AND sr_instance_id = :p_sr_instance_id ';

		sql_string := update_str||' '||set_str||' '||where_str;
                Execute immediate sql_string
		using p_old_value, p_plan_id,
			p_transaction_id, p_sr_instance_id ;
	   elsif (p_table_changed = 2) then
 		update_str := 'UPDATE MSC_DEMANDS SET STATUS=0, APPLIED=2, ';
		if (p_column_type = 'DATE') then
		  set_str := p_column_changed
			||' = fnd_date.canonical_to_date(:p_old_value) ';
		else
		  set_str := p_column_changed||' = :p_old_value ';
		end if;
		 where_str := ' WHERE plan_id = :p_plan_id '
			||' AND demand_id = :p_transaction_id '
			||' AND sr_instance_id = :p_sr_instance_id ';

		sql_string := update_str||' '||set_str||' '||where_str;
 		Execute immediate sql_string
		using p_old_value, p_plan_id,
			p_transaction_id, p_sr_instance_id ;

	   elsif (p_table_changed = 3) then
 		update_str := 'UPDATE MSC_SUPPLIER_CAPACITIES SET ';
		update_str := update_str||' STATUS=0, APPLIED=2, ';
		if (p_column_type = 'DATE') then
		  set_str := p_column_changed
			||' = fnd_date.canonical_to_date(:p_old_value) ';
		else
		  set_str := p_column_changed||' = :p_old_value ';
		end if;
		 where_str := ' WHERE plan_id = :p_plan_id '
			||' AND transaction_id = :p_transaction_id ';

		sql_string := update_str||' '||set_str||' '||where_str;
		Execute immediate sql_string
		using p_old_value, p_plan_id, p_transaction_id ;
	   elsif (p_table_changed in ( 4, 8) ) then
	      open c_net_res(p_undo_id);
	      loop
	        fetch c_net_res into l_sr_instance_id,
			l_transaction_id, l_old_value,
			l_action, l_column_name;
                exit when c_net_res%notfound;
 		if (l_action = 1) then
		  update msc_net_resource_avail
		    set capacity_units = -1,
		        status = 0,
			applied = 2
		    where plan_id = p_plan_id
		    and  sr_instance_id = l_sr_instance_id
		    and transaction_id = l_transaction_id;
		else
		  update msc_net_resource_avail
		    set capacity_units =
                          decode(l_column_name,'CAPACITY_UNITS',
                                    l_old_value,capacity_units),
                        from_time =
                          decode(l_column_name,'FROM_TIME',
                                    l_old_value,from_time),
                        to_time =
                          decode(l_column_name,'TO_TIME',
                                    l_old_value,to_time),
			status = 0,
			applied = 2
		  where plan_id = p_plan_id
		    and  sr_instance_id = l_sr_instance_id
		    and transaction_id = l_transaction_id;
		end if;

                -- need to recalculate the parent records

                  if (p_table_changed = 8) then
                          update msc_net_res_inst_avail
                    set capacity_units =
                          decode(l_column_name,'CAPACITY_UNITS',
                                    l_old_value,capacity_units),
                        from_time =
                          decode(l_column_name,'FROM_TIME',
                                    l_old_value,from_time),
                        to_time =
                          decode(l_column_name,'TO_TIME',
                                    l_old_value,to_time),
                        status = 0,
                        applied = 2
                  where plan_id = p_plan_id
                    and  sr_instance_id = l_sr_instance_id
                    and inst_transaction_id = l_transaction_id;


                  end if;

                msc_update_resource.refresh_parent_record(
                     p_plan_id,l_sr_instance_id, l_transaction_id);
	      end loop;
	      close c_net_res;

	   elsif (p_table_changed = 5) then
 		update_str := 'UPDATE MSC_PLANS SET ';
	        set_str := p_column_changed||' = :p_old_value ';
		 where_str := ' WHERE plan_id = :p_plan_id ';
		sql_string := update_str||' '||set_str||' '||where_str;
		  Execute  immediate sql_string
			using p_old_value, p_plan_id ;
	   elsif (p_table_changed = 6) then
 		update_str := 'UPDATE MSC_RESOURCE_REQUIREMENTS SET ';
		update_str := update_str||' STATUS=0, APPLIED=2, ';
		if (p_column_type = 'DATE') then
		  set_str := p_column_changed
			||' = fnd_date.canonical_to_date(nvl(:p_old_value,null)) ';
		else
		  set_str := p_column_changed||' = :p_old_value ';
		end if;
		 where_str := ' WHERE plan_id = :p_plan_id '
			||' AND sr_instance_id = :p_sr_instance_id '
			||' AND transaction_id = :p_transaction_id ';

		sql_string := update_str||' '||set_str||' '||where_str;
		Execute immediate sql_string
		using p_old_value, p_plan_id,
			 p_sr_instance_id,p_transaction_id ;
           elsif (p_table_changed = 7) then
                update_str := 'UPDATE MSC_SHIPMENTS SET STATUS=0, APPLIED=2, ';
		if (p_column_type = 'DATE') then
		  set_str := p_column_changed
			||' = fnd_date.canonical_to_date(:p_old_value) ';
		else
		  set_str := p_column_changed||' = :p_old_value ';
		end if;
		where_str := ' WHERE plan_id = :p_plan_id '
			||' AND shipment_id = :p_transaction_id '
			||' AND sr_instance_id = :p_sr_instance_id ';

		sql_string := update_str||' '||set_str||' '||where_str;
                Execute immediate sql_string
		using p_old_value, p_plan_id,
			p_transaction_id, p_sr_instance_id ;

	   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
	--ROLLBACK;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg('MSC_UNDO', 'UPDATE_TABLE'
		||'  '||sql_string);
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
END update_table;

function undo_validate (v_undo_id number,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2) return number is

  cursor c_mst (l_undo_id NUMBER) is
  select plan_id, sr_instance_id, transaction_id, table_changed, action,
  	last_updated_by, last_update_date, identifier1_name, identifier2_name,
	identifier3_name
  from msc_undo_summary_v
  where undo_id = l_undo_id;

  cursor c_noundo_same1 (v_plan_id number,
			v_sr_instance_id number,
			v_table_changed number,
			v_user number,
			v_date date) is
  select count(undo_id)
  from msc_undo_summary
  where plan_id = v_plan_id
  and sr_instance_id = v_sr_instance_id
  and table_changed = v_table_changed
  and last_updated_by = v_user
  --and last_update_date > v_date
--  and parent_id is null
  and undo_id >v_undo_id;

  cursor c_noundo_same2 (v_plan_id number,
			v_sr_instance_id number,
			v_transaction_id number,
			v_table_changed number,
			v_user number,
			v_date date) is
  select count(undo_id)
  from msc_undo_summary
  where plan_id = v_plan_id
  and sr_instance_id = v_sr_instance_id
  and transaction_id = v_transaction_id
  and table_changed = v_table_changed
  and last_updated_by = v_user
  --and last_update_date > v_date
 -- and parent_id is null
  and undo_id > v_undo_id;

  cursor c_noundo_diff1 (v_plan_id number, v_sr_instance_id number,
			v_table_changed number, v_user number,
			v_date date) is
  select count(undo_id)
  from msc_undo_summary
  where plan_id = v_plan_id
  and sr_instance_id = v_sr_instance_id
  and table_changed = v_table_changed
  and last_updated_by <>  v_user
  --and last_update_date > v_date
  --and parent_id is null
  and undo_id > v_undo_id;

  cursor c_noundo_diff2 (v_plan_id number, v_sr_instance_id number,
			v_transaction_id number, v_table_changed number,
			v_user number, v_date date) is
  select count(undo_id)
  from msc_undo_summary
  where plan_id = v_plan_id
  and sr_instance_id = v_sr_instance_id
  and transaction_id = v_transaction_id
  and table_changed = v_table_changed
  and last_updated_by <>  v_user
  --and last_update_date > v_date
  --and parent_id is null
  and undo_id > v_undo_id;

  cursor c_nofirm (v_plan_id number, v_sr_instance_id number,
		v_transaction_id number) is
  select firm_planned_type
  from msc_supplies
  where transaction_id = v_transaction_id
  and sr_instance_id = v_sr_instance_id
  and plan_id = v_plan_id ;

cursor c_olprun (v_plan_id number) is
  select undo_id
  from msc_undo_summary
  where plan_id = v_plan_id
  and action = 4;

  v_temp number;
  l_count number;
  l_olprun_undo_id number;

  l_plan_id number;
  l_sr_instance_id number;
  l_transaction_id number;

  l_table_changed number;
  l_action number;
  l_last_updated_by number;
  l_last_update_date date;
  l_identifier1_name varchar2(250);
  l_identifier2_name varchar2(250);
  l_identifier3_name varchar2(250);

  l_token Varchar2(250);

  l_msg_text Varchar2(100);
  l_diff_user number;
begin
  open c_mst(v_undo_id);
  fetch c_mst into l_plan_id,
		l_sr_instance_id,
		l_transaction_id,
		l_table_changed,
		l_action,
		l_last_updated_by,
  		l_last_update_date,
		l_identifier1_name,
		l_identifier2_name,
		l_identifier3_name ;
  close c_mst ;

  l_token := l_identifier1_name||' '||l_identifier2_name||' '||
		l_identifier3_name;
  if (fnd_global.user_id <> l_last_updated_by ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('MSC', 'MSC_UNDO_OTHER_USERS');
	FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	FND_MSG_PUB.ADD;
	 FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	return -3;
   end if;

  if (l_table_changed = 5) then
    open c_noundo_diff1(l_plan_id, l_sr_instance_id,
		l_table_changed, l_last_updated_by,
		l_last_update_date);
    fetch c_noundo_diff1 into l_count;
    close c_noundo_diff1 ;

    if (l_count <> 0 ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('MSC', 'MSC_UNDO_REC_CHG_DIFF_USER');
	FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	FND_MSG_PUB.ADD;
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	return -1;
    end if;
  else
    open c_noundo_diff2(l_plan_id, l_sr_instance_id,
		l_transaction_id, l_table_changed, l_last_updated_by,
		l_last_update_date);
    fetch c_noundo_diff2 into l_count;
    close c_noundo_diff2 ;

    if (l_count <> 0 ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('MSC', 'MSC_UNDO_REC_CHG_DIFF_USER');
	FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	FND_MSG_PUB.ADD;
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	return -1;
    end if;
  end if;

  if ( l_table_changed = 5) then
    open c_noundo_same1(l_plan_id, l_sr_instance_id,
		l_table_changed, l_last_updated_by,
		l_last_update_date);
    fetch c_noundo_same1 into l_count;
    close c_noundo_same1 ;

    if (l_count <> 0 ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('MSC', 'MSC_UNDO_REC_CHG_SAME_USER');
	FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	FND_MSG_PUB.ADD;
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	return -2;
     end if;
  else
    open c_noundo_same2(l_plan_id, l_sr_instance_id,
		l_transaction_id, l_table_changed, l_last_updated_by,
		l_last_update_date);
    fetch c_noundo_same2 into l_count;
    close c_noundo_same2 ;

    if (l_count <> 0 ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('MSC', 'MSC_UNDO_REC_CHG_SAME_USER');
	FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	FND_MSG_PUB.ADD;
	FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	return -2;
     end if;
  end if;
   if (l_table_changed = 1 ) then
     l_olprun_undo_id := v_undo_id;
     open c_olprun(l_plan_id);
     fetch c_olprun into l_olprun_undo_id;
     close c_olprun;
     open c_nofirm(l_plan_id, l_sr_instance_id, l_transaction_id);
     fetch c_nofirm into l_count;
     if (l_olprun_undo_id > v_undo_id ) then
       if (l_count <> 1) then
	 x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.set_name('MSC', 'MSC_UNDO_UNFIRM');
	 FND_MESSAGE.SET_TOKEN('RECORD',l_token);
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.count_and_get(p_count=>x_msg_count,
		p_data => x_msg_data);
	 return -4;
       end if;
     end if;
   end if;
   return v_undo_id;
  end undo_validate ;
END MSC_UNDO;

/
