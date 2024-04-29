--------------------------------------------------------
--  DDL for Package Body MSC_PERS_QUERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PERS_QUERIES" as
/* $Header: MSCPQB.pls 120.26.12010000.3 2009/09/07 12:38:07 skakani ship $ */

  procedure get_wl_groupby(p_query_id number,
                         p_groupby_cols1 in out nocopy varchar2,
                         p_groupby_cols2 in out nocopy varchar2,
                         p_groupby_cols3 in out nocopy varchar2);

  procedure Summarize_wklst_results( p_query_id IN NUMBER,
                                   p_plan_id IN NUMBER);

  procedure put_line(p_msg in varchar2) is
  begin
    --dbms_output.put_line(p_msg);
    --insert into msc_test values(p_msg);
    --commit;
    null;
  end put_line;

  procedure delete_from_results_table(p_query_id in number,
		p_plan_id in number) is
  BEGIN
    --KSA_DEBUG(SYSDATE,' p_query_id <> '||p_query_id,'delete_from_results_table');
    delete msc_pq_results
	where query_id = p_query_id
	  and plan_id = p_plan_id ;
  end delete_from_results_table;

  PROCEDURE delete_from_results_table(p_query_id IN NUMBER,
                                      p_plan_id IN NUMBER,
                                      p_detail_query_id IN NUMBER) IS
  BEGIN
    DELETE msc_pq_results
	WHERE query_id = p_query_id
	AND plan_id = p_plan_id
	AND detail_query_id =  p_detail_query_id;
  END delete_from_results_table;

  procedure populate_result_table(p_query_id in number,
                p_query_type in number,
                p_plan_id in number,
                p_where_clause in varchar2,
		p_execute_flag in BOOLEAN,
		P_MASTER_QUERY_ID in NUMBER DEFAULT NULL,
                p_sequence_id in NUMBER DEFAULT NULL) is
   l_sql_stmt varchar2(32000);

   l_insert_begin varchar2(1000) := 'INSERT INTO MSC_PQ_RESULTS ('
	|| ' QUERY_ID, PLAN_ID, ORGANIZATION_ID, SR_INSTANCE_ID, SUMMARY_DATA,';
   l_insert_end varchar2(1000) := 'created_by, creation_date, last_update_date, '||
        ' last_updated_by, last_update_login) ';

   l_insert_end_new  varchar2(1000) := 'sequence_id, created_by, creation_date, last_update_date, '||
        ' last_updated_by, last_update_login )  ';

   l_item_cols varchar2(1000)  := 'INVENTORY_ITEM_ID, CATEGORY_ID,PLANNER_CODE,';
   l_res_cols varchar2(1000)   := 'DEPARTMENT_ID, RESOURCE_ID,RESOURCE_TYPE,';
   l_supp_cols varchar2(1000)  := 'SUPPLIER_ID, SUPPLIER_SITE_ID,INVENTORY_ITEM_ID,';
   l_excp_cols varchar2(1000)  := 'EXCEPTION_TYPE, EXCEPTION_ID,';
   l_excp_cols2 varchar2(1000);
   l_shipment_cols varchar2(1000) := 'SHIPMENT_ID, FROM_ORG_ID, FROM_ORG_INSTANCE_ID, '||
		' TO_ORG_ID, TO_ORG_INSTANCE_ID,';
   l_Order_cols varchar2(1000)  := 'TRANSACTION_ID,INVENTORY_ITEM_ID,SUPPLIER_ID,SUPPLIER_SITE_ID,CATEGORY_ID,PLANNER_CODE, CUSTOMER_ID, CUSTOMER_SITE_ID,';
   l_Order_cols1 varchar2(1000)  := 'TRANSACTION_ID,INVENTORY_ITEM_ID,VENDOR_ID,VENDOR_SITE_ID,CATEGORY_ID,PLANNER_CODE, CUSTOMER_ID, CUSTOMER_SITE_ID,';
   l_summary_col constant varchar2(10) := '1,';
   l_summary_col2 constant varchar2(10) := '-99,';
   l_detail_col constant varchar2(10) := '2,';

  l_select_begin varchar2(1000) :=' select distinct '||to_char(p_query_id)
        ||', nvl(plan_id,-1), nvl(organization_id,-1), nvl(sr_instance_id,-1), ';

   l_who_cols varchar2(1000) := fnd_global.user_id||',sysdate,sysdate,'
	||fnd_global.user_id||', null';
   l_who_cols1 varchar2(1000);

   l_cp_context varchar2(200) := 'and ( COMPANY_ID= SYS_CONTEXT(''MSC'',''COMPANY_ID'') OR OWNING_COMPANY_ID= SYS_CONTEXT(''MSC'',''COMPANY_ID'') ) ';
   l_view varchar2(100);
   l_source_type number;

   CURSOR cur_priority(p_query_id NUMBER,p_detail_query_id NUMBER) IS
   SELECT NVL(priority,999)
   FROM msc_pq_types
   WHERE query_id= p_query_id
   AND NVL(detail_query_id,query_id) = p_detail_query_id;

   cursor c_groupby (l_query_id in number,
	l_source_type in number, l_object_type in number) is
   select group_by, sequence
   from msc_selection_criteria_v
   where folder_id = l_query_id
   and nvl(source_type, -1) = nvl(l_source_type, -1)
   and nvl(object_type, -1) = nvl(l_object_type, -1)
   and nvl(count_by, 2) = 1
   and nvl(active_flag,2) = 1
   order by sequence;

   CURSOR c_wl_groupby(l_query IN NUMBER) IS
   SELECT distinct ATTRIBUTE_NAME group_by
   FROM MSC_WORKLIST_GROUPBY
   WHERE QUERY_ID = l_query;

   cursor c_excp_types (l_query_id number) is
   select source_type, object_type, sequence_id,NVL(priority,999), frequency
   from msc_pq_types
   where query_id = l_query_id;

   CURSOR c_frequency(p_query_id NUMBER, p_detail_query_id IN NUMBER) is
   SELECT frequency
   FROM msc_pq_types
   WHERE query_id = p_query_id
   AND   detail_query_id = p_detail_query_id;

   l_group_by varchar2(30);
   l_seq number;
   l_seq_id number; -- sequence_id in msc_pq_types

   l_source number;
   l_object number;

   l_group_by_cols1 varchar2(100);
   l_group_by_cols2 varchar2(300);
   l_new_group_by_cols1 varchar2(300);
   l_new_group_by_cols2 varchar2(300);
   l_new_group_by_col1 varchar2(300);
   l_new_group_by_col2 varchar2(300);
   l_new_group_by_col boolean := false;
   l_worklist_cols VARCHAR2(300);
   l_group_by_count number;
   v_plan_type number;
   l_temp_query_id NUMBER;
   l_detail_query_id NUMBER;
   l_temp_query_type NUMBER;
   l_priority NUMBER;
   l_priority_wl NUMBER;
   l_frequency NUMBER;
   l_frequency_wl NUMBER;
   l_check_frequency VARCHAR2(500);
  begin
if (p_query_type <> 12 ) then
	if p_query_type = -99 then
        Summarize_wklst_results(p_query_id,p_plan_id);
        return;
    end if;
IF p_MASTER_QUERY_ID IS NOT NULL THEN
    DECLARE
		l_group_by_cols varchar2(2000);
		l_group_by_cols_excep varchar2(2000);
	BEGIN
		l_select_begin  :=' select distinct '||to_char(p_MASTER_QUERY_ID)
        ||', nvl(plan_id,-1), ';
		For rec_groupby in c_wl_groupby (p_MASTER_QUERY_ID) loop
			if rec_groupby.group_by = 'ORGANIZATION_CODE' then
				l_group_by_cols := 'nvl(organization_id,-1), nvl(sr_instance_id,-1),';
			end if;
			if rec_groupby.group_by = 'EXCEPTION_TYPE' then
				l_group_by_cols_excep := 'EXCEPTION_TYPE';
			end if;
		end loop;
		if l_group_by_cols is not null then
			l_select_begin  :=l_select_begin ||l_group_by_cols;
		else
			l_select_begin  :=l_select_begin ||'-1,-1,';
		end if;
		if l_group_by_cols_excep is not null then
			l_excp_cols2 := 'EXCEPTION_TYPE, EXCEPTION_ID,';
		else
			l_excp_cols2 := '-99, EXCEPTION_ID,';
		end if;

	END;
	l_detail_query_id := p_query_id;
    l_temp_query_id := p_MASTER_QUERY_ID;
    OPEN cur_priority(p_MASTER_QUERY_ID,l_detail_query_id);
    FETCH cur_priority INTO l_priority;
    CLOSE cur_priority;
    l_insert_end  := 'created_by, creation_date, last_update_date, '||
                     ' last_updated_by, last_update_login , detail_query_id,PRIORITY ) ';
    l_who_cols1 := l_who_cols;
    l_who_cols := l_who_cols||','||TO_CHAR(l_detail_query_id)||','||TO_CHAR(l_PRIORITY)||' ';

    -- delete_from_results_table(l_temp_query_id, p_plan_id, l_detail_query_id);
    l_temp_query_type := p_wl_type;
ELSE
    l_temp_query_id := p_query_id;
    l_temp_query_type := P_QUERY_TYPE;
    delete_from_results_table(p_query_id, p_plan_id);
END IF;
end if;

     if (p_query_type = p_item_type) then
       --KSA_DEBUG(SYSDATE,' p_query_type <> '||p_query_type,'populate_result_table');
       declare
          l_summary_col2 varchar2(10) := '-99,';
       begin
        if l_temp_query_type <> p_wl_type then
        l_summary_col2 := l_summary_col;
        end if;
        l_sql_stmt := l_insert_begin||l_item_cols||l_insert_end||
		l_select_begin||l_summary_col2||l_item_cols||l_who_cols||
		' FROM '||p_item_view||
                ' where plan_id = '||p_plan_id||' and  '||p_where_clause;
        put_line(l_sql_stmt);
        --KSA_DEBUG(SYSDATE,'*1* l_sql_stmt <> '||l_sql_stmt,'populate_result_table');
        msc_get_name.execute_dsql(l_sql_stmt);
       end;
     elsif (p_query_type = p_res_type) then
       l_sql_stmt := l_insert_begin||l_res_cols||l_insert_end||
		l_select_begin||l_summary_col||l_res_cols||l_who_cols||
		' FROM '||p_res_view||
                ' where plan_id = '||p_plan_id||' and  '||p_where_clause;
       put_line(l_sql_stmt);
       msc_get_name.execute_dsql(l_sql_stmt);
     elsif (p_query_type = p_supp_type) then
       l_sql_stmt := l_insert_begin||l_supp_cols||l_insert_end||
		l_select_begin||l_summary_col||l_supp_cols||l_who_cols||
		' FROM '||p_supp_view||
                ' where plan_id = '||p_plan_id||' and  '||p_where_clause;
       put_line(l_sql_stmt);
       msc_get_name.execute_dsql(l_sql_stmt);
     ELSIF (p_query_type = p_order_type) then
        declare
          l_summary_col2 varchar2(10) := '-99,';
        begin
            if l_temp_query_type <> p_wl_type then
                l_summary_col2 := l_summary_col;
            end if;
            l_sql_stmt := l_insert_begin||l_order_cols||l_insert_end||
		              l_select_begin||l_summary_col2||l_Order_cols1||l_who_cols||
		              ' FROM '||p_order_view||
                      ' WHERE plan_id = '||p_plan_id||' AND  '||p_where_clause;
            --KSA_DEBUG(SYSDATE,'l_sql_stmt is '||l_sql_stmt,'populate_result_table');
            put_line(l_sql_stmt);
            msc_get_name.execute_dsql(l_sql_stmt);
        end;
     elsif (p_query_type IN (p_excp_type,p_wl_type)) then
      --KSA_DEBUG(SYSDATE,' p_query_type <> '||p_query_type,'populate_result_table');
      IF l_temp_query_type = p_wl_type THEN
        IF p_query_type <> p_wl_type THEN
            OPEN c_frequency(l_temp_query_id,l_detail_query_id);
            FETCH c_frequency INTO l_frequency;
            IF c_frequency%FOUND AND l_frequency IS NOT NULL THEN
                --l_check_frequency := ' trunc(sysdate) > (nvl(ACTION_TAKEN_DATE,(SYSDATE-1)) + '||l_frequency||')';
                l_check_frequency := ' ACTION_TAKEN_DATE IS NULL OR '||
                                     ' sysdate > (ACTION_TAKEN_DATE + '||l_frequency||')';
            END IF;
            CLOSE c_frequency;
        END IF;
        OPEN c_excp_types(p_query_id);
        LOOP
	        FETCH c_excp_types INTO l_source, l_object, l_seq_id,l_priority_wl,l_frequency_wl;
            EXIT WHEN c_excp_types%NOTFOUND;

            l_group_by_count := 0;
            l_new_group_by_cols1 := null;
            l_new_group_by_cols2 := null;

            IF p_query_type = p_wl_type AND l_frequency_wl IS NOT NULL THEN
                --l_check_frequency := ' trunc(sysdate) > (nvl(ACTION_TAKEN_DATE,(SYSDATE-1)) + '||l_frequency_wl||')';
                l_check_frequency := ' ACTION_TAKEN_DATE IS NULL OR '||
                                     ' sysdate > (ACTION_TAKEN_DATE + '||l_frequency_wl||')';
            END IF;
            l_frequency_wl := NULL;

            OPEN c_wl_groupby (l_temp_query_id) ;
            LOOP
                FETCH c_wl_groupby INTO l_group_by;
                EXIT WHEN c_wl_groupby%NOTFOUND;
                --3631530 bug fix
                l_new_group_by_col := FALSE;
                IF l_group_by = 'ORGANIZATION_CODE' THEN
                    l_new_group_by_col1 := l_group_by;
                    l_new_group_by_col2 := 'GROUPBY_ORG';
                    l_new_group_by_col := true;
                ELSIF l_group_by = 'ITEM_SEGMENTS' THEN
                    l_new_group_by_col1 := 'INVENTORY_ITEM_ID';
                    l_new_group_by_col2 := 'INVENTORY_ITEM_ID';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'CATEGORY_NAME' THEN
                    l_new_group_by_col1 := 'CATEGORY_ID';
                    l_new_group_by_col2 := 'CATEGORY_ID';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'PLANNER_CODE' THEN
                    l_new_group_by_col1 := 'PLANNER_CODE';
                    l_new_group_by_col2 := 'PLANNER_CODE';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'CUSTOMER_NAME' THEN
                    l_new_group_by_col1 := 'CUSTOMER_ID';
                    l_new_group_by_col2 := 'CUSTOMER_ID';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'CUSTOMER_SITE' THEN
                    l_new_group_by_col1 := 'CUSTOMER_SITE_ID';
                    l_new_group_by_col2 := 'CUSTOMER_SITE_ID';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'SUPPLIER_NAME' THEN
                    l_new_group_by_col1 := 'SUPPLIER_ID';
                    l_new_group_by_col2 := 'SUPPLIER_ID';
                    l_new_group_by_col := TRUE;
                ELSIF l_group_by = 'EXCEPTION_TYPE' THEN
                    /*l_new_group_by_col1 := 'EXCEPTION_TYPE';
                    l_new_group_by_col2 := 'EXCEPTION_TYPE';*/
                    -- Not REQUIRED as this field will be there in the group by.
                    l_new_group_by_col := FALSE;
                ELSIF l_group_by = 'SUPPLIER_SITE' THEN
                    l_new_group_by_col1 := 'SUPPLIER_SITE_ID';
                    l_new_group_by_col2 := 'SUPPLIER_SITE_ID';
                    l_new_group_by_col := TRUE;
                END IF;
                IF (l_new_group_by_col) then
                    if l_new_group_by_cols1 is null then
                        l_new_group_by_cols1 := l_new_group_by_col2||', ';
                        l_new_group_by_cols2 := l_new_group_by_col1||', ';
                    else
                        l_new_group_by_cols1 := l_new_group_by_cols1||l_new_group_by_col2||', ';
                        l_new_group_by_cols2 := l_new_group_by_cols2||l_new_group_by_col1||', ';
                    end if;
                end if;
            end loop;
            close c_wl_groupby;

            select plan_type
                into v_plan_type
            from msc_plans
            where plan_id = p_plan_id;

            if p_plan_id = -1 then
	            l_view := p_cp_excp_view;
                l_source_type := 2;
                l_sql_stmt := l_insert_begin||'source_type ,'|| l_excp_cols || l_insert_end||
		        l_select_begin||l_detail_col||l_source_type||','||l_excp_cols || l_who_cols||
		        ' FROM '||l_view||
                ' where plan_id = '||p_plan_id||l_cp_context||' and  '||p_where_clause
		        ||' and ( source_type = 2 and exception_type = '||l_object||')';
            else
                if v_plan_type IN ( 5,8,9) then
                    l_view := 'MSC_DRP_EXC_DETAILS_V';
                else -- v_plan_type <> 5
	                l_view := p_excp_view;
                end if;
                l_source_type := 1;
                IF p_query_type = p_wl_type THEN
                    l_who_cols := l_who_cols1||','||TO_CHAR(l_detail_query_id)||','||TO_CHAR(l_priority_wl)||' ';
                END IF;
                --l_worklist_cols := ' INVENTORY_ITEM_ID,SUPPLIER_ID,SUPPLIER_SITE_ID,CUSTOMER_ID,CUSTOMER_SITE_ID,CATEGORY_ID,PLANNER_CODE, ';
                l_sql_stmt := l_insert_begin||'source_type , sequence_id, '||
                              l_excp_cols ||l_new_group_by_cols1|| --l_worklist_cols|| --l_new_group_by_cols1||
                              l_insert_end||
                              l_select_begin||l_detail_col||
                              l_source_type||','||l_seq_id||','||
                              l_excp_cols2 ||l_new_group_by_cols2|| --l_worklist_cols|| --l_new_group_by_cols2||
                              l_who_cols||
                              ' FROM '||l_view||' where plan_id = '||p_plan_id||
                              ' and  '||p_where_clause||
                              ' and ( source_type = 1 and exception_type = '||
                              l_object||')';
                IF l_check_frequency IS NOT NULL THEN
                    l_sql_stmt := l_sql_stmt||' and '||l_check_frequency;
                    l_check_frequency:= NULL;
                END IF;
            end if;
            put_line(l_sql_stmt);
            --KSA_DEBUG(SYSDATE,'*1* l_sql_stmt <> '||l_sql_stmt,'populate_result_table');
            msc_get_name.execute_dsql(l_sql_stmt);

        end loop;
        close c_excp_types;

	    INSERT INTO MSC_PQ_RESULTS(query_id,plan_id,sr_instance_id,
	                               organization_id,	exception_type,
	                               source_type, summary_data, sequence_id,
	                               exception_count, groupby_org,
	                               INVENTORY_ITEM_ID, --groupby_supply_item,
	                               CATEGORY_ID, PLANNER_CODE,
	                               CUSTOMER_iD, SUPPLIER_ID,
	                               CUSTOMER_SITE_ID, SUPPLIER_SITE_ID,
	                               created_by,creation_date,
	                               last_updated_by, last_update_date,
	                               detail_query_id,Priority)
	    SELECT l_temp_query_id, NVL(p_plan_id,-1), sr_instance_id,
	           organization_id, exception_type,
	           source_type,	-99, sequence_id,
	           COUNT(*), groupby_org,
	           INVENTORY_ITEM_ID, --groupby_supply_item,
	           CATEGORY_ID, PLANNER_CODE,
	           CUSTOMER_iD, SUPPLIER_ID,
	           CUSTOMER_SITE_ID, SUPPLIER_SITE_ID,
	           fnd_global.user_id, sysdate,
	           fnd_global.user_id, SYSDATE,
	           detail_query_id,PRIORITY
	    FROM MSC_PQ_RESULTS
	    WHERE query_id = l_temp_query_id
	    AND plan_id = p_plan_id
	    AND ((detail_query_id <> query_id
	         AND detail_query_id = l_detail_query_id)
	        OR detail_query_id = query_id)
	    GROUP BY query_id, plan_id, sr_instance_id,
	             organization_id, exception_type,
	             source_type, sequence_id,
	             groupby_org, INVENTORY_ITEM_ID,
	             CATEGORY_ID, PLANNER_CODE,
	             CUSTOMER_iD, SUPPLIER_ID,
	             CUSTOMER_SITE_ID, SUPPLIER_SITE_ID,
	             detail_query_id,PRIORITY;
      ELSE
      --(begin if not part of worklist

      open c_excp_types(p_query_id);
      loop
	fetch c_excp_types into l_source, l_object, l_seq_id,l_priority_wl,l_frequency_wl;
        exit when c_excp_types%notfound;

      l_group_by_count := 0;
      l_group_by_cols1 := null;
      l_group_by_cols2 := null;
      l_new_group_by_cols1 := null;
      l_new_group_by_cols2 := null;
      open c_groupby (p_query_id, l_source, l_object) ;
      loop
        fetch c_groupby into l_group_by, l_seq;
        exit when c_groupby%notfound;
        --3631530 bug fix
        l_new_group_by_col := false;
        if (l_group_by = 'ORGANIZATION_CODE') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_ORG';
          l_new_group_by_col := true;
        elsif (l_group_by = 'ITEM_SEGMENTS') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_ITEM';
          l_new_group_by_col := true;
        elsif (l_group_by = 'SUPPLY_ITEM_SEGMENTS') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_SUPPLY_ITEM';
          l_new_group_by_col := true;
        elsif (l_group_by = 'CATEGORY_NAME') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_CATEGORY';
          l_new_group_by_col := true;
        elsif (l_group_by = 'PLANNER_CODE') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_PLANNER';
          l_new_group_by_col := true;
        elsif (l_group_by = 'DEPARTMENT_LINE_CODE') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_DEPT';
          l_new_group_by_col := true;
        elsif (l_group_by = 'RESOURCE_CODE') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_RES';
          l_new_group_by_col := true;
        elsif (l_group_by = 'CUSTOMER_NAME') then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_CUSTOMER';
          l_new_group_by_col := true;
        elsif (l_group_by = 'SUPPLIER_NAME' ) then
          l_new_group_by_col1 := l_group_by;
          l_new_group_by_col2 := 'GROUPBY_SUPPLIER';
          l_new_group_by_col := true;
        else
          l_group_by_count := l_group_by_count + 1;
	  if l_group_by_cols1 is null then
            l_group_by_cols1 := ' CHAR'||to_char(l_group_by_count)||', ';
            l_group_by_cols2 := ' '||l_group_by||', ';
	  elsif l_group_by_count <=5 then
            l_group_by_cols1 := l_group_by_cols1||' CHAR'||to_char(l_group_by_count)||', ';
            l_group_by_cols2 := l_group_by_cols2||l_group_by||',';
          end if;
        end if;
        if (l_new_group_by_col) then
          if l_new_group_by_cols1 is null then
            l_new_group_by_cols1 := l_new_group_by_col2||', ';
            l_new_group_by_cols2 := l_new_group_by_col1||', ';
          else
            l_new_group_by_cols1 := l_new_group_by_cols1||l_new_group_by_col2||', ';
            l_new_group_by_cols2 := l_new_group_by_cols2||l_new_group_by_col1||', ';
          end if;
        end if;
       end loop;
      close c_groupby;

      select plan_type
        into v_plan_type
        from msc_plans
       where plan_id = p_plan_id;

       if p_plan_id = -1 then
	 l_view := p_cp_excp_view;
         l_source_type := 2;
         l_sql_stmt := l_insert_begin||'source_type , sequence_id, '|| l_excp_cols || l_group_by_cols1 ||l_insert_end||
		l_select_begin||l_detail_col||l_source_type||','||l_seq_id||','||l_excp_cols || l_group_by_cols2 ||l_who_cols||
		' FROM '||l_view||
                ' where plan_id = '||p_plan_id||l_cp_context||' and  '||p_where_clause
		||' and ( source_type = 2 and exception_type = '||l_object||')';

       else
         if v_plan_type IN (5,8,9) then
            l_view := 'MSC_DRP_EXC_DETAILS_V';
         else -- v_plan_type <> 5
	        l_view := p_excp_view;
         end if;
         l_source_type := 1;
         l_sql_stmt := l_insert_begin   || 'source_type , sequence_id, '||
                       l_excp_cols      || l_new_group_by_cols1||
                       l_group_by_cols1 || l_insert_end||
                       l_select_begin   || l_detail_col||
                       l_source_type    || ','||l_seq_id||','||
                       l_excp_cols      || l_new_group_by_cols2||
                       l_group_by_cols2 || l_who_cols||
                       ' FROM '||l_view|| ' where plan_id = '||
                       p_plan_id||' and  '||p_where_clause||
                       ' and ( source_type = 1 and exception_type = '||l_object||')';
       IF l_check_frequency IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt||' and '||l_check_frequency;
       END IF;
       end if;
       put_line(l_sql_stmt);
       --KSA_DEBUG(SYSDATE,'*2* l_sql_stmt <> '||l_sql_stmt,'populate_result_table');
       msc_get_name.execute_dsql(l_sql_stmt);

      end loop;
      close c_excp_types;

	INSERT INTO MSC_PQ_RESULTS (
		query_id,
		plan_id,
 		sr_instance_id,
		organization_id,
		exception_type,
                source_type,
		summary_data,
                sequence_id,
		exception_count,
	        groupby_org, groupby_item, groupby_supply_item, groupby_category,
                groupby_planner, groupby_dept, groupby_res, groupby_customer, groupby_supplier,
		char1,
		char2,
		char3,
		char4,
		char5,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date)
	SELECT l_temp_query_id, --p_query_id
		nvl(p_plan_id,-1),
		-1,
		-1,
		exception_type,
                source_type,
		1,
                sequence_id,
		count(*),
	        groupby_org, groupby_item, groupby_supply_item, groupby_category,
                groupby_planner, groupby_dept, groupby_res, groupby_customer, groupby_supplier,
		char1,
		char2,
		char3,
		char4,
		char5,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate
	FROM MSC_PQ_RESULTS
	WHERE query_id = l_temp_query_id --p_query_id
	  and plan_id = p_plan_id
	GROUP BY query_id, plan_id, source_type,exception_type,sequence_id,
	  groupby_org, groupby_item, groupby_supply_item, groupby_category,
          groupby_planner, groupby_dept, groupby_res, groupby_customer, groupby_supplier,
	  char1, char2, char3, char4, char5;
        END IF;
	    --) end If not part of the worklist
    elsif  (p_query_type = p_crit_type) then
           l_view := p_item_attributes_view;
           l_cp_context := null;
           l_source_type := 100;
           l_sql_stmt := l_insert_begin||l_item_cols||l_insert_end_new||
                l_select_begin||l_summary_col||' inventory_item_id , ' || p_master_query_id||' , ' ||
                 'NULL ' ||' , ' ||
                p_sequence_id || ' , ' ||
                l_who_cols||
                ' FROM '||p_item_attributes_view||
                ' where simulation_set_id is NULL and plan_id = '||p_plan_id||' and  '||p_where_clause;

             msc_get_name.execute_dsql(l_sql_stmt);

       return;

    elsif (p_query_type = p_shipment_type) then
       l_sql_stmt := l_insert_begin|| l_shipment_cols||l_insert_end||
		l_select_begin||l_summary_col||l_shipment_cols||l_who_cols||
		' FROM '||p_shipment_view||
                ' where plan_id = '||p_plan_id||' and  '||p_where_clause ||
		' GROUP BY PLAN_ID, SHIPMENT_ID, FROM_ORG_ID, FROM_ORG_INSTANCE_ID, '||
		' TO_ORG_ID, TO_ORG_INSTANCE_ID, ORGANIZATION_ID, SR_INSTANCE_ID ';
       put_line(l_sql_stmt);
       msc_get_name.execute_dsql(l_sql_stmt);
    end if;


    update msc_personal_queries
	set execute_flag = 1,
	    EXECUTION_DATE = TRUNC(SYSDATE)
	where query_id = l_temp_query_id ;
    --where query_id = p_query_id ;
  end populate_result_table;

procedure update_category( ERRBUF     OUT NOCOPY VARCHAR2,
                           RETCODE    OUT NOCOPY NUMBER,
                           p_query_id IN NUMBER) IS

cursor  item_exist(p_item number, p_org number, p_inst number) IS
select 1
from msc_item_attributes
where simulation_set_id = -1
and plan_id = -1
and inventory_item_id = p_item
and organization_id = p_org
and sr_instance_id = p_inst;

cursor  cat_id(p_item number, p_seq number , p_org number, p_inst number, p_query_id number) IS
select category_id
from msc_pq_results
where query_id = p_query_id
and  inventory_item_id = p_item
and organization_id = p_org
and sr_instance_id = p_inst
and sequence_id = p_seq;


type number_arr is table of NUMBER INDEX BY BINARY_INTEGER;
v_item_id number_arr;
v_cat_id number_arr;
v_seq number_arr;
v_org_id number_arr;
v_inst_id number_arr;
p_cat number;
p_exist number :=0;

begin

-- select the records with highest seq number so we do not pick
-- up overlapping items.

select inventory_item_id, organization_id, sr_instance_id, max(sequence_id)
bulk collect into  v_item_id, v_org_id, v_inst_id, v_seq
from msc_pq_results
where query_id = p_query_id
group by inventory_item_id, organization_id, sr_instance_id;


if  v_item_id.COUNT > 0 then
  for  j IN v_item_id.FIRST .. v_item_id.LAST  LOOP
   open item_exist(v_item_id(j), v_org_id(j), v_inst_id(j));
   fetch item_exist into p_exist;
   close item_exist;

   open cat_id(v_item_id(j), v_seq(j), v_org_id(j), v_inst_id(j), p_query_id);
   fetch cat_id into p_cat;
   close cat_id;

  if p_exist = 1  then
     update msc_item_attributes
     set criticality_category = p_cat
     where inventory_item_id = v_item_id(j)
     and organization_id = v_org_id(j)
     and sr_instance_id = v_inst_id(j)
     and simulation_set_id = -1
     and plan_id = -1;
  else
     insert into msc_item_attributes(simulation_set_id,
        inventory_item_id, organization_id,
        sr_instance_id, last_update_date,
        last_updated_by, creation_date, created_by,
        criticality_category, plan_id, updated_columns_count
        )  values
        ( -1 ,  v_item_id(j), v_org_id(j),
         v_inst_id(j), sysdate , -1,
         sysdate, -1, p_cat, -1, 1);
  end if;
   p_exist := 0;

  END LOOP;
   commit;
 end if;

EXCEPTION
  WHEN OTHERS THEN
  RAISE;
end update_category;

  function get_user(p_user_id in number) return varchar2 IS
    l_name fnd_user.user_name%type;
  begin
    select user_name
    into l_name
    from fnd_user
    where user_id = p_user_id;

    return l_name;
    exception
      when others then
 	return null;
  end get_user;

  function get_query_name(p_query_id in number) return varchar2 is
    l_name varchar2(80);
  begin
    select query_name
    into l_name
    from msc_personal_queries
    where query_id = p_query_id;

    return l_name;
    exception
      when others then
 	return null;
  end get_query_name;

  function get_query_type(p_query_id in number) return number is
    l_name number;
  begin
    select query_type
    into l_name
    from msc_personal_queries
    where query_id = p_query_id;

    return l_name;
    exception
      when others then
 	return null;
  end get_query_type;

 procedure populate_cp_temp_table(p_query_id in number) is
--  PRAGMA AUTONOMOUS_TRANSACTION;
 begin
  insert into msc_query (query_id, number1,
	LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
  select p_query_id, number1 ,
        sysdate, -1, sysdate, -1
  from msc_form_query
  where query_id = p_query_id;

  commit;
 end populate_cp_temp_table;

 FUNCTION copy_query(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number) return number is

   cursor c_pers_queries (p_query in number) is
   select  QUERY_ID, QUERY_NAME, DESCRIPTION,
	QUERY_TYPE, PUBLIC_FLAG, AND_OR_FLAG, EXECUTE_FLAG,
	CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,
	LAST_UPDATED_BY, LAST_UPDATE_LOGIN, PLAN_TYPE,
	AUTO_RELEASE,GROUP_ID,UPDATED_FLAG
   from msc_personal_queries
   where query_id = p_query;

   cursor c_pq_types (p_query in number) is
   select QUERY_ID, SOURCE_TYPE,  OBJECT_TYPE,
	SEQUENCE_ID, AND_OR_FLAG,  CREATION_DATE,
	LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CUSTOMIZED_TEXT, OBJECT_TYPE_TEXT, ACTIVE_FLAG,
        DETAIL_QUERY_ID,FREQUENCY,PRIORITY
   from msc_pq_types
   where query_id = p_query;

   cursor c_pers_criteria (p_query in number) is
   select SEQUENCE, FOLDER_ID, OBJECT_SEQUENCE_ID,
          FIELD_NAME, FIELD_TYPE,
	      HIDDEN_FROM_FIELD, CONDITION,
	 FROM_FIELD, TO_FIELD, FOLDER_OBJECT,
	 TREE_NODE, CREATION_DATE, CREATED_BY,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	 AND_OR, COUNT_BY, SEARCH_QUERY_ID,
	 SEARCH_QUERY_NAME, DEFAULT_FLAG,
	 PUBLIC_FLAG, FROM_FIELD_VALUE, TO_FIELD_VALUE,
	 OBJECT_TYPE, SOURCE_TYPE, ACTIVE_FLAG
   from msc_selection_criteria
   where folder_id = p_query;

   cursor c_among_criteria(p_query_id in number) is
   select SEQUENCE,FIELD_NAME, OR_VALUES,
          HIDDEN_VALUES,OBJECT_SEQUENCE,ORDER_BY_SEQUENCE,
                  CREATION_DATE, CREATED_BY,
         LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
   from msc_among_values
   where folder_id = p_query_id;

   cursor c_query is select msc_personal_queries_s.nextval from dual;
   --5746041 bugfix, changed from msc_form_query_s to msc_personal_queries_s

   CURSOR c_group_by(p_query_id IN NUMBER) IS
   SELECT distinct ATTRIBUTE_NAME group_by
   FROM MSC_WORKLIST_GROUPBY
   WHERE QUERY_ID = p_query_id;


   l_save_as_query_id number;

   rec_pers_queries c_pers_queries%ROWTYPE;
   rec_pers_criteria c_pers_criteria%ROWTYPE;


  begin
   open c_query;
   fetch c_query into l_save_as_query_id;
   close c_query;

   open c_pers_queries(p_query_id);
   fetch c_pers_queries into rec_pers_queries;
   close c_pers_queries;

   if rec_pers_queries.query_type not in (7,8)  then -- org/customer_list
      l_save_as_query_id := -1 * l_save_as_query_id;
   end if;

   INSERT INTO  msc_personal_queries( QUERY_ID, QUERY_NAME, DESCRIPTION,
	QUERY_TYPE, PUBLIC_FLAG, AND_OR_FLAG, EXECUTE_FLAG,
	CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,
	LAST_UPDATED_BY, LAST_UPDATE_LOGIN, PLAN_TYPE,
	AUTO_RELEASE,GROUP_ID,UPDATED_FLAG)
   VALUES (l_save_as_query_id, p_query_name, p_query_desc,
	rec_pers_queries.QUERY_TYPE, p_public_flag, rec_pers_queries.AND_OR_FLAG,
	2, rec_pers_queries.CREATED_BY, rec_pers_queries.CREATION_DATE,
	rec_pers_queries.LAST_UPDATE_DATE, rec_pers_queries.LAST_UPDATED_BY,
	rec_pers_queries.LAST_UPDATE_LOGIN, rec_pers_queries.PLAN_TYPE,
	rec_pers_queries.AUTO_RELEASE,rec_pers_queries.GROUP_ID,rec_pers_queries.UPDATED_FLAG);

   for rec_pq_types in c_pq_types(p_query_id)
   loop
     INSERT INTO MSC_PQ_TYPES (QUERY_ID, SOURCE_TYPE,  OBJECT_TYPE,
	SEQUENCE_ID, AND_OR_FLAG,  CREATION_DATE,
	LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CUSTOMIZED_TEXT, OBJECT_TYPE_TEXT, ACTIVE_FLAG,
        DETAIL_QUERY_ID,FREQUENCY,PRIORITY)
     VALUES (l_save_as_query_id, rec_pq_types.SOURCE_TYPE,  rec_pq_types.OBJECT_TYPE,
	rec_pq_types.SEQUENCE_ID, rec_pq_types.AND_OR_FLAG,
	rec_pq_types.CREATION_DATE, rec_pq_types.LAST_UPDATE_DATE,
	rec_pq_types.LAST_UPDATED_BY, rec_pq_types.LAST_UPDATE_LOGIN,
        rec_pq_types.CUSTOMIZED_TEXT, rec_pq_types.OBJECT_TYPE_TEXT, rec_pq_types.ACTIVE_FLAG,
        rec_pq_types.DETAIL_QUERY_ID,rec_pq_types.FREQUENCY,rec_pq_types.PRIORITY);
   end loop;

   if rec_pers_queries.query_type in (7,8)  then -- org/customer list
      return l_save_as_query_id;
   end if;

   for rec_pers_criteria in c_pers_criteria(p_query_id)
   loop
     INSERT INTO msc_selection_criteria
     (SEQUENCE, FOLDER_ID, OBJECT_SEQUENCE_ID, FIELD_NAME, FIELD_TYPE,
	HIDDEN_FROM_FIELD, CONDITION,
	FROM_FIELD, TO_FIELD, FOLDER_OBJECT,
	TREE_NODE, CREATION_DATE, CREATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	AND_OR, COUNT_BY, SEARCH_QUERY_ID,
	SEARCH_QUERY_NAME, DEFAULT_FLAG,
	PUBLIC_FLAG, FROM_FIELD_VALUE, TO_FIELD_VALUE,
	OBJECT_TYPE, SOURCE_TYPE, ACTIVE_FLAG)
     VALUES (rec_pers_criteria.SEQUENCE, l_save_as_query_id,
             rec_pers_criteria.OBJECT_SEQUENCE_ID ,
	rec_pers_criteria.FIELD_NAME, rec_pers_criteria.FIELD_TYPE,
	rec_pers_criteria.HIDDEN_FROM_FIELD, rec_pers_criteria.CONDITION,
	rec_pers_criteria.FROM_FIELD, rec_pers_criteria.TO_FIELD,
	rec_pers_criteria.FOLDER_OBJECT, rec_pers_criteria.TREE_NODE,
	rec_pers_criteria.CREATION_DATE, rec_pers_criteria.CREATED_BY,
	rec_pers_criteria.LAST_UPDATE_DATE, rec_pers_criteria.LAST_UPDATED_BY,
	rec_pers_criteria.LAST_UPDATE_LOGIN, rec_pers_criteria.AND_OR,
	rec_pers_criteria.COUNT_BY, rec_pers_criteria.SEARCH_QUERY_ID,
	rec_pers_criteria.SEARCH_QUERY_NAME, rec_pers_criteria.DEFAULT_FLAG,
	rec_pers_criteria.PUBLIC_FLAG, rec_pers_criteria.FROM_FIELD_VALUE,
	rec_pers_criteria.TO_FIELD_VALUE,rec_pers_criteria.OBJECT_TYPE,
	rec_pers_criteria.SOURCE_TYPE, rec_pers_criteria.ACTIVE_FLAG) ;
   end loop;

   for rec_among_criteria in c_among_criteria(p_query_id) loop
                INSERT INTO msc_among_values
                (FOLDER_ID,SEQUENCE,FIELD_NAME, OR_VALUES,
         HIDDEN_VALUES,OBJECT_SEQUENCE,ORDER_BY_SEQUENCE,
                 CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                 LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
                VALUES(l_save_as_query_id, rec_among_criteria.SEQUENCE,
                       rec_among_criteria.FIELD_NAME,
                           rec_among_criteria.OR_VALUES,
                           rec_among_criteria.HIDDEN_VALUES,
                           rec_among_criteria.OBJECT_SEQUENCE,
                           rec_among_criteria.ORDER_BY_SEQUENCE,
                           rec_among_criteria.CREATION_DATE,
                           rec_among_criteria.CREATED_BY,
                           rec_among_criteria.LAST_UPDATE_DATE,
                           rec_among_criteria.LAST_UPDATED_BY,
                           rec_among_criteria.LAST_UPDATE_LOGIN);
   END LOOP;

   INSERT INTO MSC_WORKLIST_GROUPBY(
                                    QUERY_ID                ,
                                    ATTRIBUTE_NAME          ,
                                    CHAR1                   ,
                                    CHAR2                   ,
                                    CHAR3                   ,
                                    CHAR4                   ,
                                    SEQUENCE                ,
                                    LAST_UPDATE_DATE        ,
                                    LAST_UPDATED_BY         ,
                                    CREATION_DATE           ,
                                    CREATED_BY              )
   SELECT               l_save_as_query_id                ,
                        ATTRIBUTE_NAME          ,
                        CHAR1                   ,
                        CHAR2                   ,
                        CHAR3                   ,
                        CHAR4                   ,
                        SEQUENCE                ,
                        LAST_UPDATE_DATE        ,
                        LAST_UPDATED_BY         ,
                        CREATION_DATE           ,
                        CREATED_BY
   FROM MSC_WORKLIST_GROUPBY
   WHERE query_id = p_query_id;
   return l_save_as_query_id;
  end copy_query;


  Procedure purge_plan(p_plan_id IN NUMBER) is
    l_sql_stmt varchar2(300);
    l_share_partition varchar2(5):= fnd_profile.value('MSC_SHARE_PARTITIONS');
  l_count number;

    l_msc_schema varchar2(30);
    l_status varchar2(50);
    l_industry varchar2(50);
    retval boolean;

  begin
    retval := fnd_installation.get_app_info_other('MSC', 'MSC',
	l_status, l_industry, l_msc_schema);

    if (not retval) then
      return;
    end if;

    SELECT  count(*) into l_count
    from ALL_TAB_PARTITIONS
    where TABLE_NAME = 'MSC_PQ_RESULTS' and TABLE_OWNER= l_msc_schema;

    l_sql_stmt :=
      'alter table '||l_msc_schema||'.msc_pq_results'||
      ' truncate partition PQ_RESULTS_'||to_char(p_plan_id);
     --5768202 partition name changed from pq_results_all_ to pq_results_

    if l_share_partition = 'N' and l_count >0 then
      EXECUTE IMMEDIATE l_sql_stmt;
    else
      delete from msc_pq_results
       where plan_id = p_plan_id;
    end if;
  end purge_plan;

  procedure delete_query(p_query_id in number,
        p_query_name in varchar2 default null) is
  PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    delete from msc_personal_queries
        where query_id = p_query_id;

    delete from msc_pq_types
        where query_id = p_query_id;

    delete from msc_selection_criteria
        where folder_id = p_query_id;

    delete from msc_among_values
        where folder_id = p_query_id;

    delete from msc_pq_results
        where query_id = p_query_id;

    commit;
  end delete_query;

procedure save_as(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number) is
    p_new_query_id number;
 BEGIN
     p_new_query_id :=
     copy_query(p_query_id,
	        p_query_name,
	        p_query_desc,
	        p_public_flag);
 END save_as;

FUNCTION save_as(p_query_id in number,
	p_query_name in varchar2,
	p_query_desc in varchar2,
	p_public_flag in number) return number is
    p_new_query_id number;
BEGIN
     p_new_query_id :=
     copy_query(p_query_id,
	        p_query_name,
	        p_query_desc,
	        p_public_flag);

     return p_new_query_id;
END save_as;

procedure Summarize_wklst_results( p_query_id IN NUMBER,
                                   p_plan_id IN NUMBER) IS
    l_sql_stmt varchar2(32000);
    l_Insert_stmt varchar2(32000);
    l_insert_begin varchar2(1000) := 'INSERT INTO MSC_PQ_RESULTS ('||
                                     ' QUERY_ID, PLAN_ID, ORGANIZATION_ID,'||
                                     ' SR_INSTANCE_ID, SUMMARY_DATA,';
    l_insert_end_new  varchar2(1000) := 'sequence_id, created_by, creation_date,'||
                                        ' last_update_date, last_updated_by,'||
                                        ' last_update_login )  ';

    l_new_group_by_cols1 varchar2(1000);
    l_new_group_by_cols2 varchar2(1000);
    l_new_group_by_cols3 varchar2(1000);
    l_new_group_by_cols4 varchar2(1000);

begin
    get_wl_groupby(p_query_id,l_new_group_by_cols1,l_new_group_by_cols2,l_new_group_by_cols3);
    --KSA_DEBUG(SYSDATE,' l_new_group_by_cols1 >> '||l_new_group_by_cols1,'Summarize_wklst_results');
    --KSA_DEBUG(SYSDATE,' l_new_group_by_cols2 >> '||l_new_group_by_cols2,'Summarize_wklst_results');
    IF l_new_group_by_cols2 IS NOT NULL THEN
        l_new_group_by_cols1 := ','||l_new_group_by_cols1;
        l_new_group_by_cols2 := ','||l_new_group_by_cols2;
        l_new_group_by_cols3 := ','||l_new_group_by_cols3;
        l_new_group_by_cols4 := ' GROUP BY MPR1.PLAN_ID,MPR1.SR_INSTANCE_ID, MPR1.ORGANIZATION_ID'||
                                l_new_group_by_cols3||' MPR1.QUERY_ID';
    ELSE
        l_new_group_by_cols1 := ',';
        l_new_group_by_cols2 := ',';
        l_new_group_by_cols3 := ',';
        l_new_group_by_cols4 := ' GROUP BY MPR1.QUERY_ID, MPR1.PLAN_ID,MPR1.SR_INSTANCE_ID, MPR1.ORGANIZATION_ID';
    END IF;
    l_sql_stmt := ' Select mpr1.query_id, mpr1.plan_id,'||
                        'mpr1.sr_instance_id, mpr1.organization_id,'||
                        'sum(mpr1.exception_count) exception_count,'||
                        'MIN(mpr1.priority) priority,'||1||
                        l_new_group_by_cols3||
                        fnd_global.user_id||', SYSDATE, '||
	                    fnd_global.user_id||', SYSDATE'||
                        ' from ( select mpr.query_id,       mpr.plan_id,'||
                                  'mpr.sr_instance_id, mpr.organization_id,'||
                                  'nvl(mpr.exception_count,1) exception_count,'||
                                  'mpr.priority'||
                                  l_new_group_by_cols1||
                                 '9999'||
                                 ' FROM msc_pq_results mpr '||
                                 ' WHERE  mpr.query_id = '||p_query_id ||
                                 ' AND mpr.plan_id = '||p_plan_id ||
                                 ' AND mpr.summary_data = -99 ) mpr1 '||
                    l_new_group_by_cols4;

    l_Insert_stmt:= 'Insert into MSC_PQ_RESULTS ( '||
                        'query_id,       plan_id,'||
                        'sr_instance_id, organization_id,'||
                        'exception_count, priority, summary_data'||
                        l_new_group_by_cols2||
                        'created_by, creation_date, '||
		                'last_updated_by,last_update_date)';
    msc_get_name.execute_dsql(l_Insert_stmt||l_sql_stmt);

exception
    when others then
    --KSA_DEBUG(SYSDATE,' l_Insert_stmt >> '||l_Insert_stmt,'Summarize_wklst_results');
    --KSA_DEBUG(SYSDATE,' l_sql_stmt >> '||l_sql_stmt,'Summarize_wklst_results');
    --KSA_DEBUG(SYSDATE,' Error >> '||sqlerrm(sqlcode),'Summarize_wklst_results');
    raise;
end Summarize_wklst_results;

procedure get_wl_groupby(p_query_id number,
                         p_groupby_cols1 in out nocopy varchar2,
                         p_groupby_cols2 in out nocopy varchar2,
                         p_groupby_cols3 in out nocopy varchar2) is
    l_new_group_by_col1 varchar2(300);
    l_new_group_by_col2 varchar2(300);
    l_new_group_by_col boolean := false;
    l_group_by varchar2(30);

    CURSOR c_wl_groupby(l_query IN NUMBER) IS
    SELECT distinct ATTRIBUTE_NAME group_by
    FROM MSC_WORKLIST_GROUPBY
    WHERE QUERY_ID = l_query;
begin
    OPEN c_wl_groupby (p_query_id) ;
    LOOP
        FETCH c_wl_groupby INTO l_group_by;
        EXIT WHEN c_wl_groupby%NOTFOUND;
        l_new_group_by_col := FALSE;
        IF l_group_by = 'ORGANIZATION_CODE' THEN
            l_new_group_by_col1 := 'GROUPBY_ORG';
            l_new_group_by_col1 := 'nvl(MPR.GROUPBY_ORG,
                                        msc_get_name.org_code
                                         (MPR.organization_id,
                                          MPR.sr_instance_id)) GROUPBY_ORG';
            l_new_group_by_col2 := 'GROUPBY_ORG';
            l_new_group_by_col := true;
        ELSIF l_group_by = 'ITEM_SEGMENTS' THEN
            l_new_group_by_col1 := 'MPR.INVENTORY_ITEM_ID';
            l_new_group_by_col2 := 'INVENTORY_ITEM_ID';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'CATEGORY_NAME' THEN
            l_new_group_by_col1 := 'MPR.CATEGORY_ID';
            l_new_group_by_col2 := 'CATEGORY_ID';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'PLANNER_CODE' THEN
            l_new_group_by_col1 := 'MPR.PLANNER_CODE';
            l_new_group_by_col2 := 'PLANNER_CODE';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'CUSTOMER_NAME' THEN
            l_new_group_by_col1 := 'MPR.CUSTOMER_ID';
            l_new_group_by_col2 := 'CUSTOMER_ID';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'CUSTOMER_SITE' THEN
            l_new_group_by_col1 := 'MPR.CUSTOMER_SITE_ID';
            l_new_group_by_col2 := 'CUSTOMER_SITE_ID';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'SUPPLIER_NAME' THEN
            l_new_group_by_col1 := 'MPR.SUPPLIER_ID';
            l_new_group_by_col2 := 'SUPPLIER_ID';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'EXCEPTION_TYPE' THEN
			l_new_group_by_col1 := 'MPR.SOURCE_TYPE,MPR.EXCEPTION_TYPE';
            l_new_group_by_col2 := 'SOURCE_TYPE,EXCEPTION_TYPE';
            l_new_group_by_col := TRUE;
        ELSIF l_group_by = 'SUPPLIER_SITE' THEN
            l_new_group_by_col1 := 'MPR.SUPPLIER_SITE_ID';
            l_new_group_by_col2 := 'SUPPLIER_SITE_ID';
            l_new_group_by_col := TRUE;
        END IF;
        IF (l_new_group_by_col) then
            if p_groupby_cols1 is null then
                --p_groupby_cols1 := l_new_group_by_col2||', ';
                p_groupby_cols1 := l_new_group_by_col1||', ';
                p_groupby_cols2 := l_new_group_by_col2||', ';
				IF l_group_by = 'EXCEPTION_TYPE' THEN
					p_groupby_cols3 := 'MPR1.SOURCE_TYPE,MPR1.EXCEPTION_TYPE, ';
				ELSE
					p_groupby_cols3 := 'MPR1.'||l_new_group_by_col2||', ';
				END IF;
            else
                p_groupby_cols1 := p_groupby_cols1||l_new_group_by_col1||', ';
                p_groupby_cols2 := p_groupby_cols2||l_new_group_by_col2||', ';
                IF l_group_by = 'EXCEPTION_TYPE' THEN
					p_groupby_cols3 := p_groupby_cols3||'MPR1.SOURCE_TYPE,MPR1.EXCEPTION_TYPE, ';
				ELSE
					p_groupby_cols3 := p_groupby_cols3||'MPR1.'||l_new_group_by_col2||', ';
				end if;
			end if;
        end if;
    end loop;
    close c_wl_groupby;
end get_wl_groupby;

end MSC_pers_queries;

/
