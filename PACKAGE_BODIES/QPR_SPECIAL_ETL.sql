--------------------------------------------------------
--  DDL for Package Body QPR_SPECIAL_ETL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_SPECIAL_ETL" AS
/* $Header: QPRUSPLB.pls 120.5 2008/01/04 13:14:44 bhuchand noship $ */

procedure collect_cost(
                        errbuf  OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY VARCHAR2,
                        p_from_date	    varchar2,
                        p_to_date	    varchar2,
                        p_instance_id number ) is
l_sql varchar2(10000);
date_from date;
date_to date;
l_rows number := 1000;
l_ctr number := 0;
l_cost_alloc_perc number := 0;
first_time number := 1;
l_dummy number;
b_data_present boolean := true;

l_user_id number := FND_GLOBAL.USER_ID;
d_sysdate date := sysdate;
l_login_id number := FND_GLOBAL.LOGIN_ID;
l_request_id number := FND_GLOBAL.conc_request_id;

c_measures SYS_REFCURSOR;
c_cost_data COST_REC_TYPE;
t_meas_id num_type;
t_ord_val num_type;
t_ord_meas num_type;
t_cost num_type;
t_cost_level char240_type;

cursor c_sales(p_date_from date, p_date_to date) is
select measure_value_id, ord_level_value
from qpr_measure_data where instance_id = p_instance_id
and measure_type_code = 'SALESDATA'
and time_level_value between p_date_from and p_date_to
and measure1_char in ('STANDARD','SERVICE');

cursor c_sales_mdl(p_date_from date, p_date_to date) is
select measure_value_id, ord_level_value
from qpr_measure_data where instance_id = p_instance_id
and measure_type_code = 'SALESDATA'
and time_level_value between p_date_from and p_date_to
and measure1_char not in ('STANDARD','SERVICE');

/********** Mapping info in qpr_plan_measures *********
  price_plan_id = Request_id
  price_plan_meas_grp_id = 999
  price_plan_meas_grp_name = COST
  date_attribute = booked_date
  attribute_1 = inventory_item_id
  attribute_2 = cost_level_value
  attribute_3 = ord_level_value
  attribute_4 = top_model_line_id
  attribute_5 = link_to_line_id
  attribute_6 = item_type_code
  attribute_7 = component_code
  attribute_8 = ato_line_id
  attribute_9 = unit_cost
  attribute_10 = unit list price
  attribute_11 = ordered quantity
*/
cursor c_kit is
select m2.attribute_3 ord, null, m2.attribute_2,
        nvl(decode(m2.attribute_6,
        'INCLUDED', 0,
        'KIT', (case when (to_number(m2.attribute_9) <> 0) then
                      to_number(m2.attribute_9)
                else
                    (select sum(m3.attribute_9)
                    from qpr_plan_measures m3
                    where m3.price_plan_id= l_request_id
                    and m3.price_plan_meas_grp_id = 999
                    and m3.attribute_6 = 'INCLUDED'
                    and m3.attribute_5 = m2.attribute_4)
                end)
            ) * (m2.attribute_11), 0) cost
from qpr_plan_measures m1, qpr_plan_measures m2
where m1.price_plan_id= l_request_id
and m1.price_plan_meas_grp_id = 999
and m2.price_plan_id= l_request_id
and m2.price_plan_meas_grp_id = 999
and m1.attribute_6 = 'KIT'
and m1.attribute_5 is null
and m2.attribute_4 = m1.attribute_3;

cursor c_ato(p_cost_mrg number) is
select m2.attribute_3 ord, null, m2.attribute_2,
       nvl(decode(m2.attribute_6,
                  'OPTION', m2.attribute_9,
                  'CONFIG', 0,
                  (select
                    case when nvl(t.cost_to_alloc,0) = 0 then
                      -1 * p_cost_mrg * to_number( m2.attribute_10)
                    else
                      decode(t1.list_price_rev, 0 , 0,
                            (t.cost_to_alloc * m2.attribute_10 * m2.attribute_11
                              / t1.list_price_rev))
                    end
                  from
                  (select nvl(sum(c.attribute_9)/count(c.attribute_9) -
                              sum(o.attribute_9) , 0) cost_to_alloc,
                          o.attribute_8
                  from qpr_plan_measures c, qpr_plan_measures o
                  where o.price_plan_id= l_request_id
                  and o.price_plan_meas_grp_id = 999
                  and o.attribute_6 = 'OPTION'
                  and o.attribute_8 is not null
                  and o.attribute_9 <> 0
                  and o.attribute_8 = c.attribute_8(+)
                  and c.price_plan_id(+) = l_request_id
                  and c.price_plan_meas_grp_id(+) = 999
                  and c.attribute_6(+) = 'CONFIG'
                  group by o.attribute_8) t,
                  (select sum(m3.attribute_10 * m3.attribute_11) list_price_rev,
                          m3.attribute_8
                  from qpr_plan_measures m3
                  where m3.price_plan_id= l_request_id
                  and m3.price_plan_meas_grp_id = 999
                  and m3.attribute_6 in('ATOMODEL', 'ATOCLASS')
                  group by m3.attribute_8) t1
                  where t1.attribute_8 = m2.attribute_8
                  and t.attribute_8(+) = t1.attribute_8
                  )
          ) * (m2.attribute_11) , 0) cost
from qpr_plan_measures m1, qpr_plan_measures m2
where m1.price_plan_id= l_request_id
and m1.price_plan_meas_grp_id = 999
and m2.price_plan_id= l_request_id
and m2.price_plan_meas_grp_id = 999
and m1.attribute_6 = 'ATOMODEL'
and m1.attribute_5 is null
and m2.attribute_8 = m1.attribute_8;

cursor c_pto(p_cost_mrg number) is
select m2.attribute_3 ord,  null, m2.attribute_2,
      nvl((case when (m2.attribute_6 = 'INCLUDED') then 0
           when (m2.attribute_6 = 'OPTION') then to_number(m2.attribute_9)
           when (m2.attribute_6 = 'CONFIG') then 0
           when (m2.attribute_6 = 'PTOMODEL') or (m2.attribute_6 = 'PTOCLASS')
           then
              (select case when nvl(t.cost_to_alloc,0) = 0 then
                        -1* p_cost_mrg * to_number(m2.attribute_10)
                      else
                        decode(t1.list_price_rev, 0 , 0,
                               (t.cost_to_alloc * m2.attribute_10 *
                               m2.attribute_11 / t1.list_price_rev))
                      end
              from
              (select nvl(sum(c.attribute_9) , 0) cost_to_alloc , c.attribute_4
              from qpr_plan_measures c
              where c.price_plan_id = l_request_id
              and c.price_plan_meas_grp_id = 999
              and c.attribute_6 = 'INCLUDED'
              group by c.attribute_4
              ) t,
              (select sum(m3.attribute_10 * m3.attribute_11) list_price_rev,
                      m3.attribute_4
              from qpr_plan_measures m3
              where m3.price_plan_id= l_request_id
              and m3.price_plan_meas_grp_id = 999
              and m3.attribute_6 in('PTOMODEL', 'PTOCLASS')
              group by m3.attribute_4) t1
              where t1.attribute_4 = m2.attribute_4
              and t.attribute_4(+) = t1.attribute_4
              )
           else
              (select case when nvl(t.cost_to_alloc,0) = 0 then
                        -1 * p_cost_mrg * to_number( m2.attribute_10)
                      else
                        decode(t1.list_price_rev, 0 , 0,
                              (t.cost_to_alloc * m2.attribute_10 *
                              m2.attribute_11 / t1.list_price_rev))
                      end
              from
              ( select nvl(sum(c.attribute_9)/count(c.attribute_9) -
                        sum(o.attribute_9) , 0) cost_to_alloc
              , o.attribute_8
              from qpr_plan_measures c, qpr_plan_measures o
              where o.price_plan_id = l_request_id
              and o.price_plan_meas_grp_id = 999
              and o.attribute_6 = 'OPTION'
              and o.attribute_8 is not null
              and o.attribute_9 <> 0
              and o.attribute_8 = c.attribute_8(+)
              and c.price_plan_id(+) = l_request_id
              and c.price_plan_meas_grp_id(+) = 999
              and c.attribute_6(+) = 'CONFIG'
              group by o.attribute_8) t,
              (select sum(m3.attribute_10 * m3.attribute_11) list_price_rev,
                      m3.attribute_8
              from qpr_plan_measures m3
              where m3.price_plan_id= l_request_id
              and m3.price_plan_meas_grp_id = 999
              and m3.attribute_6 in('ATOMODEL', 'ATOCLASS')
              group by m3.attribute_8) t1
              where t1.attribute_8 = m2.attribute_8
              and t.attribute_8(+) = t1.attribute_8
              )
           end
         )  * m2.attribute_11 , 0) cost
from qpr_plan_measures m1, qpr_plan_measures m2
where m1.price_plan_id= l_request_id
and m1.price_plan_meas_grp_id = 999
and m2.price_plan_id= l_request_id
and m2.price_plan_meas_grp_id = 999
and m1.attribute_6 = 'PTOMODEL'
and m1.attribute_5 is null
and m2.attribute_4 = m1.attribute_4;

procedure handle_kit_items is
begin
fnd_file.put_line(fnd_file.log, 'Handle kit items...');
open c_kit;
loop
  t_ord_val.delete;
  t_meas_id.delete;
  t_cost.delete;
  t_cost_level.delete;

  l_ctr := 0;

  fetch c_kit bulk collect into
  t_ord_val, t_meas_id,t_cost_level, t_cost
  limit l_rows;
  exit when t_ord_val.count=0;

  fnd_file.put_line(fnd_file.log, 'Records to process:'||t_ord_val.count);

  for i in 1..t_ord_val.count loop
    if t_ord_meas.exists(t_ord_val(i)) then
      t_meas_id(i) := t_ord_meas(t_ord_val(i));
      l_ctr := l_ctr + 1;
    end if;
  end loop;

  if l_ctr > 0 then
    fnd_file.put_line(fnd_file.log, 'Updating kit items...');
    FORALL I IN 1..t_ord_val.COUNT
      update qpr_measure_data
      set measure15_number = t_cost(i),
      cos_level_value = t_cost_level(i),
      LAST_UPDATE_DATE = d_sysdate,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = l_login_id,
      request_id = l_request_id
      where measure_value_id = t_meas_id(i)
      and t_meas_id(i) is not null;
  else
    fnd_file.put_line(fnd_file.log, 'No Sales data found');
  end if;
end loop;
close c_kit;
exception
 when OTHERS then
    fnd_file.put_line(fnd_file.log, 'Error in kit item cost updation');
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    raise;
end handle_kit_items;

procedure handle_ato_items is
begin
fnd_file.put_line(fnd_file.log, 'Handle ato model items...');
open c_ato(l_cost_alloc_perc);
loop
  t_ord_val.delete;
  t_meas_id.delete;
  t_cost.delete;
  t_cost_level.delete;

  l_ctr := 0;

  fetch c_ato bulk collect into
  t_ord_val, t_meas_id,t_cost_level, t_cost
  limit l_rows;
  exit when t_ord_val.count=0;

  fnd_file.put_line(fnd_file.log, 'Records to process:'||t_ord_val.count);

  for i in 1..t_ord_val.count loop
    if t_ord_meas.exists(t_ord_val(i)) then
      t_meas_id(i) := t_ord_meas(t_ord_val(i));
      l_ctr := l_ctr + 1;
    end if;
  end loop;

  if l_ctr > 0 then
    fnd_file.put_line(fnd_file.log, 'Updating ato model items...');
    FORALL I IN 1..t_ord_val.COUNT
      update qpr_measure_data
      set measure15_number = t_cost(i),
      cos_level_value = t_cost_level(i),
      LAST_UPDATE_DATE = d_sysdate,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = l_login_id,
      request_id = l_request_id
      where measure_value_id = t_meas_id(i)
      and t_meas_id(i) is not null;
  else
    fnd_file.put_line(fnd_file.log, 'No Sales data found');
  end if;
end loop;
close c_ato;
exception
 when OTHERS then
    fnd_file.put_line(fnd_file.log, 'Error in ato model item cost updation');
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    raise;
end handle_ato_items;

procedure handle_pto_items is
begin
fnd_file.put_line(fnd_file.log, 'Handle pto model items...');
open c_pto(l_cost_alloc_perc);
loop
  t_ord_val.delete;
  t_meas_id.delete;
  t_cost.delete;
  t_cost_level.delete;

  l_ctr := 0;

  fetch c_pto bulk collect into
  t_ord_val, t_meas_id,t_cost_level, t_cost
  limit l_rows;
  exit when t_ord_val.count=0;

  fnd_file.put_line(fnd_file.log, 'Records to process:'||t_ord_val.count);

  for i in 1..t_ord_val.count loop
    if t_ord_meas.exists(t_ord_val(i)) then
      t_meas_id(i) := t_ord_meas(t_ord_val(i));
      l_ctr := l_ctr + 1;
    end if;
  end loop;

  if l_ctr > 0 then
    fnd_file.put_line(fnd_file.log, 'Updating pto model items...');
    FORALL I IN 1..t_ord_val.COUNT
      update qpr_measure_data
      set measure15_number = t_cost(i),
      cos_level_value = t_cost_level(i),
      LAST_UPDATE_DATE = d_sysdate,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = l_login_id,
      request_id = l_request_id
      where measure_value_id = t_meas_id(i)
      and t_meas_id(i) is not null;
  else
    fnd_file.put_line(fnd_file.log, 'No Sales data found');
  end if;
end loop;
close c_pto;
exception
 when OTHERS then
    fnd_file.put_line(fnd_file.log, 'Error in pto model item cost updation');
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    raise;
end handle_pto_items;

/* main method begins*/
begin
date_from := fnd_date.canonical_to_date(p_from_date);
date_to := fnd_date.canonical_to_date(p_to_date);

l_sql:= ' select ord_level_value, booked_date, cos_level_value, unit_cost, '||
' unit_list_price, top_model_line_id, link_to_line_id, item_type_code, '||
' inventory_item_id, component_code, ato_line_id , order_quantity' ||
' from qpr_sr_cost_data_v'|| qpr_sr_util.get_dblink(p_instance_id)||
' where booked_date between :1 and :2 ' ||
' and item_type_code in (''STANDARD'',''SERVICE'')';

fnd_file.put_line(fnd_file.log, 'Process Standard and service items..');
open c_sales(date_from, date_to);
fetch c_sales bulk collect into t_meas_id, t_ord_val;
close c_sales;

if t_ord_val.count > 0 then
  for j in t_ord_val.first..t_ord_val.last loop
    t_ord_meas(t_ord_val(j)):= t_meas_id(j);
  end loop;
  t_meas_id.delete;
  t_ord_val.delete;
end if;

if t_ord_meas.count > 0 then
fnd_file.put_line(fnd_file.log, 'Sales Records to update:' || t_ord_meas.count);
  open c_measures for l_sql using date_from, date_to;
  loop
    c_cost_data.ord_level_value.delete;
    c_cost_data.booked_date.delete;
    c_cost_data.cos_level_value.delete;
    c_cost_data.cost_value.delete;
    c_cost_data.unit_list_price.delete;
    c_cost_data.TOP_MODEL_LINE_ID.delete;
    c_cost_data.LINK_TO_LINE_ID.delete;
    c_cost_data.ITEM_TYPE_CODE.delete;
    c_cost_data.INVENTORY_ITEM_ID.delete;
    c_cost_data.COMPONENT_CODE.delete;
    c_cost_data.ato_line_id.delete;
    c_cost_data.ord_quantity.delete;

    l_ctr := 0;

    fetch c_measures bulk collect into
    c_cost_data.ord_level_value,
    c_cost_data.booked_date,
    c_cost_data.cos_level_value,
    c_cost_data.cost_value,
    c_cost_data.unit_list_price,
    c_cost_data.TOP_MODEL_LINE_ID,
    c_cost_data.LINK_TO_LINE_ID,
    c_cost_data.ITEM_TYPE_CODE,
    c_cost_data.INVENTORY_ITEM_ID,
    c_cost_data.COMPONENT_CODE,
    c_cost_data.ato_line_id,
    c_cost_data.ord_quantity
    limit l_rows;

    exit when c_cost_data.ord_level_value.count=0;
    fnd_file.put_line(fnd_file.log,
          'Iteration...Records to process:' ||c_cost_data.ord_level_value.count);

    ----- Insert Dimension ----
    FOR I IN 1..c_cost_data.ord_level_value.count LOOP
      if first_time = 1 then
        begin
          select 1 into l_dummy
          from qpr_dimension_values
          where dim_code = 'COS'
          and hierarchy_code = 'COSTING'
          and level1_value = c_cost_data.cos_level_value(I)
          and instance_id = p_instance_id;
          fnd_file.put_line(fnd_file.log,'Cost dim present');
        exception
          WHEN NO_DATA_FOUND THEN
            begin
              fnd_file.put_line(fnd_file.log,
                'Inserting Cost dim :' || c_cost_data.cos_level_value(I));
              INSERT INTO
              qpr_dimension_values(instance_id,
              dim_value_id,
              dim_code,
              hierarchy_code,
              level1_value,
              level1_desc,
              level2_value,
              level2_desc,
              level3_value,
              level3_desc,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              REQUEST_ID) values
              (p_instance_id,
              qpr_dimension_values_s.nextval,
              'COS',
              'COSTING',
              c_cost_data.cos_level_value(I),
              c_cost_data.cos_level_value(I),
              to_char(qpr_sr_util.get_null_pk),
              qpr_sr_util.get_cost_type_desc,
              to_char(qpr_sr_util.get_all_cos_pk),
              qpr_sr_util.get_all_cos_desc,
              d_sysdate,
              l_user_id,
              d_sysdate,
              l_user_id,
              l_login_id,
              l_request_id);
            exception
              when others then
                retcode := 2;
                errbuf  := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log,
                                  dbms_utility.format_error_backtrace);
                return;
            end;
        end;
        first_time :=0;
      end if;
      exit when first_time=0;
    end loop;

    fnd_file.put_line(fnd_file.log,'Associating order and measure value id...');
    for i in c_cost_data.ord_level_value.first..
             c_cost_data.ord_level_value.last loop
      if t_ord_meas.exists(c_cost_data.ord_level_value(i)) then
        c_cost_data.measure_val_id(i) := t_ord_meas(
                                          c_cost_data.ord_level_value(i)) ;
        l_ctr := l_ctr + 1;
      end if;
    end loop;

    if l_ctr > 0 then
      fnd_file.put_line(fnd_file.log,'Updating sales data with cost measure...');
      FORALL I IN 1..c_cost_data.ord_level_value.COUNT
        update qpr_measure_data
        set measure15_number = (c_cost_data.cost_value(I) *
        c_cost_data.ord_quantity(I)),
        cos_level_value = c_cost_data.cos_level_value(I),
        LAST_UPDATE_DATE = d_sysdate,
        LAST_UPDATED_BY = l_user_id,
        LAST_UPDATE_LOGIN = l_login_id,
        request_id = l_request_id
        where measure_value_id = c_cost_data.measure_val_id(i)
        and c_cost_data.measure_val_id(i) is not null;
    else
      fnd_file.put_line(fnd_file.log, 'Sales data not found.No update done');
    end if;
  end loop;
  close c_measures;
else
  b_data_present := false;
end if;
t_ord_meas.delete;

commit;

fnd_file.put_line(fnd_file.log, 'Process Model and kit items..');

l_sql:= ' select ord_level_value, booked_date, cos_level_value, unit_cost, '||
' unit_list_price, top_model_line_id, link_to_line_id, item_type_code, '||
' inventory_item_id, component_code, ato_line_id , order_quantity' ||
' from qpr_sr_cost_data_v'||qpr_sr_util.get_dblink(p_instance_id)||
' where booked_date between :1 and :2 ' ||
' and item_type_code not in (''STANDARD'',''SERVICE'')';

open c_sales_mdl(date_from, date_to);
fetch c_sales_mdl bulk collect into t_meas_id, t_ord_val;
close c_sales_mdl;

if t_ord_val.count > 0 then
  for j in t_ord_val.first..t_ord_val.last loop
    t_ord_meas(t_ord_val(j)):= t_meas_id(j);
  end loop;
  t_meas_id.delete;
  t_ord_val.delete;
else
  if b_data_present = false then
    retcode := 1;
    fnd_file.put_line(fnd_file.log,
	'Salesdata measures not found.Cost measures cannot be updated.');
    fnd_file.put_line(fnd_file.log,
        'Try again after extracting Salesdata measures for given date range.');
    return;
  end if;
end if;

if t_ord_meas.count > 0 then
fnd_file.put_line(fnd_file.log, 'Sales Records to update:' || t_ord_meas.count);
  open c_measures for l_sql using date_from, date_to;
  loop
    c_cost_data.ord_level_value.delete;
    c_cost_data.booked_date.delete;
    c_cost_data.cos_level_value.delete;
    c_cost_data.cost_value.delete;
    c_cost_data.unit_list_price.delete;
    c_cost_data.TOP_MODEL_LINE_ID.delete;
    c_cost_data.LINK_TO_LINE_ID.delete;
    c_cost_data.ITEM_TYPE_CODE.delete;
    c_cost_data.INVENTORY_ITEM_ID.delete;
    c_cost_data.COMPONENT_CODE.delete;
    c_cost_data.ato_line_id.delete;
    c_cost_data.ord_quantity.delete;

    l_ctr := 0;

    fetch c_measures bulk collect into
    c_cost_data.ord_level_value,
    c_cost_data.booked_date,
    c_cost_data.cos_level_value,
    c_cost_data.cost_value,
    c_cost_data.unit_list_price,
    c_cost_data.TOP_MODEL_LINE_ID,
    c_cost_data.LINK_TO_LINE_ID,
    c_cost_data.ITEM_TYPE_CODE,
    c_cost_data.INVENTORY_ITEM_ID,
    c_cost_data.COMPONENT_CODE,
    c_cost_data.ato_line_id,
    c_cost_data.ord_quantity
    limit l_rows;

    exit when c_cost_data.ord_level_value.count=0;
    fnd_file.put_line(fnd_file.log,
    'Iteration...records to process:'||c_cost_data.ord_level_value.count);

    ----- Insert Dimension ----
    FOR I IN 1..c_cost_data.ord_level_value.count LOOP
      if first_time = 1 then
        begin
          select 1 into l_dummy
          from qpr_dimension_values
          where dim_code = 'COS'
          and hierarchy_code = 'COSTING'
          and level1_value = c_cost_data.cos_level_value(I)
          and instance_id = p_instance_id;
          fnd_file.put_line(fnd_file.log,'Cost dim present');
        exception
          WHEN NO_DATA_FOUND THEN
            begin
              fnd_file.put_line(fnd_file.log,
                'Inserting Cost dim :' || c_cost_data.cos_level_value(I));
              INSERT INTO
              qpr_dimension_values(instance_id,
              dim_value_id,
              dim_code,
              hierarchy_code,
              level1_value,
              level1_desc,
              level2_value,
              level2_desc,
              level3_value,
              level3_desc,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              REQUEST_ID) values
              (p_instance_id,
              qpr_dimension_values_s.nextval,
              'COS',
              'COSTING',
              c_cost_data.cos_level_value(I),
              c_cost_data.cos_level_value(I),
              to_char(qpr_sr_util.get_null_pk),
              qpr_sr_util.get_cost_type_desc,
              to_char(qpr_sr_util.get_all_cos_pk),
              qpr_sr_util.get_all_cos_desc,
              d_sysdate,
              l_user_id,
              d_sysdate,
              l_user_id,
              l_login_id,
              l_request_id);
            exception
              when others then
                retcode := 2;
                errbuf  := FND_MESSAGE.GET;
                fnd_file.put_line(fnd_file.log,
                                  dbms_utility.format_error_backtrace);
                return;
            end;
        end;
        first_time :=0;
      end if;
      exit when first_time=0;
    end loop;

    fnd_file.put_line(fnd_file.log, 'Inserting fact records in staging table');
    forall i in c_cost_data.ord_level_value.first..
      c_cost_data.ord_level_value.last
      insert into qpr_plan_measures(price_plan_data_id,
      price_plan_id,
      price_plan_meas_grp_id,
      price_plan_meas_grp_name,
      date_attribute,
      attribute_1,
      attribute_2,
      attribute_3,
      attribute_4,
      attribute_5,
      attribute_6,
      attribute_7,
      attribute_8,
      attribute_9,
      attribute_10,
      attribute_11,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID)
      values(qpr_plan_measures_s.nextval,
      l_request_id,
      999, 'COST',
      c_cost_data.booked_date(i),
      c_cost_data.INVENTORY_ITEM_ID(i),
      c_cost_data.cos_level_value(i),
      c_cost_data.ord_level_value(i),
      c_cost_data.TOP_MODEL_LINE_ID(i),
      c_cost_data.LINK_TO_LINE_ID(i),
      c_cost_data.ITEM_TYPE_CODE(i),
      c_cost_data.COMPONENT_CODE(i),
      c_cost_data.ato_line_id(i),
      c_cost_data.cost_value(i),
      c_cost_data.unit_list_price(i),
      c_cost_data.ord_quantity(i),
      d_sysdate,
      l_user_id,
      d_sysdate,
      l_user_id,
      l_login_id,
      l_request_id);
  end loop;
  commit;
  close c_measures;
  fnd_file.put_line(fnd_file.log, 'Staging complete...');

  fnd_file.put_line(fnd_file.log, 'Calculate costs for model/kit items...');
  l_cost_alloc_perc := to_number(nvl(qpr_sr_util.read_parameter(
                        'QPR_MODEL_COST_MRG_PERC'),0))/100;
  handle_kit_items;
  handle_ato_items;
  handle_pto_items;

  commit;
  t_ord_meas.delete;

  fnd_file.put_line(fnd_file.log, 'Deleting staging table records ..');
  begin
    delete qpr_plan_measures temp
    where temp.price_plan_meas_grp_id=999
    and temp.price_plan_id = l_request_id;
    fnd_file.put_line(fnd_file.log, 'Deleted '||sql%rowcount ||'records');
  end;

  commit;
end if;
exception
 when OTHERS then
    retcode := 2;
    errbuf  := 'ERROR: ' || substr(sqlerrm, 1, 1000);
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end collect_cost;


procedure collect_offadj(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_TRX_TYP_NAME        VARCHAR2,
--			P_TRX_TYPE 	    VARCHAR2,
			P_h_reason_code     VARCHAR2,
			P_l_reason_code     VARCHAR2,
			p_from_trx_date	    VARCHAR2,
			p_to_trx_date	    VARCHAR2,
			p_from_date	    VARCHAR2,
			p_to_date	    VARCHAR2,
			p_instance_id number ) is
l_sql varchar2(500);
c_measures QPRREFCUR;
c_offadj_data OFFADJ_REC_TYPE;
l_rows natural :=1000;
--l_dummy number;
--l_next_seq number;
--first_time number:=1;
l_iterator number := 0;
date_from date;
date_to date;
date_to_trx date;
date_from_trx date;
-- who columns ---
l_user_id number := FND_GLOBAL.USER_ID;
d_sysdate date := sysdate;
l_login_id number := FND_GLOBAL.LOGIN_ID;
l_request_id number := FND_GLOBAL.conc_request_id;

begin

date_from := fnd_date.canonical_to_date(nvl(p_from_date, p_from_trx_date));
date_to := fnd_date.canonical_to_date(nvl(p_to_date, p_to_trx_date));
date_from_trx := fnd_date.canonical_to_date(p_from_trx_date);
date_to_trx := fnd_date.canonical_to_date(p_to_trx_date);

----- Collect Data ---
l_sql:=	' SELECT '||
	' CUSTOMER_TRX_LINE_ID, TRX_TYP_NAME, SOLD_TO_CUSTOMER_ID,'||
	' ORG_ID, INVENTORY_ITEM_ID, H_REASON_CODE, L_REASON_CODE, ' ||
	' TRX_NUMBER || ''-'' || LINE_NUMBER,' ||
	' CUST_TRX_TYPE_ID, QUANTITY_ORDERED,'||
	' UNIT_SELLING_PRICE, EXTENDED_AMOUNT, TRX_DATE '||
	' from qpr_sr_offinv_ar_v'||qpr_sr_util.get_dblink(p_instance_id)||
	' where TRX_TYP_NAME = '||''''||p_trx_typ_name||''''||' and'||
--	' TRX_TYPE = '||''''||p_trx_type||''''||' and'||
	' TRX_DATE between '||''''||date_from_trx||''''||' and '||''''||date_to_trx||'''';
if p_h_reason_code is not null then
	l_sql:= l_sql|| ' and H_REASON_CODE = '||''''||p_h_reason_code||'''';
end if;
if p_l_reason_code is not null then
	l_sql:= l_sql|| ' and L_REASON_CODE = '||''''||p_l_reason_code||'''';
end if;
fnd_file.put_line(fnd_file.log,'SQL: '||l_sql);

open c_measures for l_sql;
loop
	c_offadj_data.level1_value.delete;
	c_offadj_data.level2_value.delete;
	c_offadj_data.level3_value.delete;
	c_offadj_data.level4_value.delete;
	c_offadj_data.level5_value.delete;
	c_offadj_data.level6_value.delete;
	c_offadj_data.level7_value.delete;
	c_offadj_data.level8_value.delete;
	c_offadj_data.level9_value.delete;
	c_offadj_data.measure1_value.delete;
	c_offadj_data.measure2_value.delete;
	c_offadj_data.measure3_value.delete;
	c_offadj_data.date_value.delete;

	fetch c_measures bulk collect into
	c_offadj_data.level1_value,
	c_offadj_data.level2_value,
	c_offadj_data.level3_value,
	c_offadj_data.level4_value,
	c_offadj_data.level5_value,
	c_offadj_data.level6_value,
	c_offadj_data.level7_value,
	c_offadj_data.level8_value,
	c_offadj_data.level9_value,
	c_offadj_data.measure1_value,
	c_offadj_data.measure2_value,
	c_offadj_data.measure3_value,
	c_offadj_data.date_value
	limit l_rows;

        exit when c_offadj_data.level1_value.count = 0;
        l_iterator := l_iterator + 1;
	fnd_file.put_line(fnd_file.log,'Iteration...' || l_iterator);
----- Insert Dimension ----
        fnd_file.put_line(fnd_file.log,
                          'Deleting overlapping dimension values...');
        FORALL I IN 1..c_offadj_data.level1_value.count
          delete qpr_dimension_values
          where dim_code = 'OAD'
          and hierarchy_code = 'OFFINVADJ'
          and level1_value = c_offadj_data.level1_value(I)
          and instance_id = p_instance_id;

        fnd_file.put_line(fnd_file.log,
                        'Inserting Offinvoice Adjustment dimension values...');
        FORALL I IN 1..c_offadj_data.level1_value.count
          INSERT INTO qpr_dimension_values(instance_id,
				dim_value_id,
				dim_code,
				hierarchy_code,
				level1_value,
				level1_desc,
                                level1_attribute1,
                                level1_attribute2,
                                level1_attribute3,
                                level1_attribute4,
                                level1_attribute5,
				level2_value,
				level2_desc,
				level3_value,
				level3_desc,
                                level4_value,
                                level4_desc,
                                level5_value,
                                level5_desc,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				REQUEST_ID) values
				(p_instance_id,
				qpr_dimension_values_s.nextval,
				'OAD',
				'OFFINVADJ',
				c_offadj_data.level1_value(I), --level1 val
				c_offadj_data.level2_value(I)||'-'||c_offadj_data.level8_value(I), --level1 desc
				c_offadj_data.level2_value(I), --attr1:trx name
				nvl(c_offadj_data.level7_value(I),
					c_offadj_data.level6_value(I)), --attr2:reason code
                                null,null,null,		-- attr3, attr4, attr5
                                'Rebate-'||c_offadj_data.level9_value(I),		--level2 val
                                c_offadj_data.level2_value(I), 		--level2 desc
                                qpr_sr_util.get_oad_ar_cm_type_pk, 	--level3 val
                                qpr_sr_util.get_oad_ar_cm_type_desc, 	--level3 desc
				qpr_sr_util.get_oad_ar_group_pk, 	--level4 val
				qpr_sr_util.get_oad_ar_group_desc, 	--level4 desc
				to_char(qpr_sr_util.get_all_oad_pk),	--level5 (all) val
				qpr_sr_util.get_all_oad_desc,		--level5 (all) desc
				d_sysdate,
				l_user_id,
				d_sysdate,
				l_user_id,
				l_login_id,
				l_request_id);



----- Update Measure data ---
	fnd_file.put_line(fnd_file.log,'Staging Measure data...');
	FORALL I IN
	c_offadj_data.level1_value.FIRST..c_offadj_data.level1_value.LAST
	        insert into QPR_MEASURE_DATA(MEASURE_VALUE_ID,
                                  INSTANCE_ID,
                                  MEASURE_TYPE_CODE,
                                  ADJ_LEVEL_VALUE,
                                  TIME_LEVEL_VALUE,
                                  CUS_LEVEL_VALUE,
                                  PRD_LEVEL_VALUE,
                                  ORG_LEVEL_VALUE,
                                  MEASURE1_NUMBER ,
                                  MEASURE2_NUMBER ,
                                  MEASURE3_NUMBER ,
                                  CREATION_DATE ,
                                  CREATED_BY ,
                                  LAST_UPDATE_DATE ,
                                  LAST_UPDATED_BY ,
                                  LAST_UPDATE_LOGIN ,
                                  REQUEST_ID)
		values (QPR_MEASURE_DATA_S.nextval,
                            -999,
                            'OFFADJDATA',
			     c_offadj_data.level1_value(I),
			     c_offadj_data.date_value(I),
			     c_offadj_data.level3_value(I),
			     c_offadj_data.level5_value(I),
			     c_offadj_data.level4_value(I),
			     c_offadj_data.measure1_value(I),
			     c_offadj_data.measure2_value(I),
			     c_offadj_data.measure3_value(I),
				d_sysdate,
				l_user_id,
				d_sysdate,
				l_user_id,
				l_login_id,
				l_request_id);
	fnd_file.put_line(fnd_file.log,'No of rows processed: '||sql%rowcount);
commit;
end loop;

allocate_offinvoice_adj(errbuf, retcode,
			date_from,
			date_to,
			p_instance_id );

exception
 WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    fnd_file.put_line(fnd_file.log,'Unexpected error '||substr(sqlerrm,1200));
end;

procedure allocate_offinvoice_adj(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_from_date	    date,
			p_to_date	    date,
			p_instance_id number ) is
cursor c_offadj is
select temp.ADJ_LEVEL_VALUE,
  om_alloc.ord_level_value,
  om_alloc.prd_level_value,
  om_alloc.geo_level_value,
  om_alloc.cus_level_value,
  om_alloc.org_level_value,
  om_alloc.rep_level_value,
  om_alloc.chn_level_value,
  om_alloc.vlb_level_value,
  om_alloc.dsb_level_value,
  om_alloc.time_level_value,
  temp.MEASURE1_NUMBER, --qty_ordered
  temp.MEASURE2_NUMBER, --unit_selling_price
  temp.MEASURE3_NUMBER, --extended_amount
  (select sum(om.measure2_number) from qpr_measure_data om where om.instance_id=p_instance_id
	and om.measure_type_code = 'SALESDATA'
	and om.time_level_value between p_from_date and p_to_date
	and om.cus_level_value = temp.cus_level_value
	and om.prd_level_value = nvl(temp.prd_level_value, om.prd_level_value)
	and om.org_level_value = nvl(temp.org_level_value, om.org_level_value)
	) as total_amount,
   om_alloc.measure1_number,
   om_alloc.measure2_number
from qpr_measure_data temp, qpr_measure_data om_alloc
where temp.instance_id=-999
and temp.measure_type_code = 'OFFADJDATA'
and temp.request_id = fnd_global.conc_request_id
and om_alloc.instance_id=p_instance_id
and om_alloc.measure_type_code = 'SALESDATA'
and om_alloc.time_level_value between p_from_date and p_to_date
and om_alloc.cus_level_value = temp.cus_level_value
and om_alloc.prd_level_value = nvl(temp.prd_level_value, om_alloc.prd_level_value)
and om_alloc.org_level_value = nvl(temp.org_level_value, om_alloc.org_level_value);
c_offadj_data OFFADJ_REC_TYPE;
l_rows natural :=1000;

-- who columns ---
l_user_id number := FND_GLOBAL.USER_ID;
d_sysdate date := sysdate;
l_login_id number:= FND_GLOBAL.LOGIN_ID;
l_request_id number:= FND_GLOBAL.conc_request_id;

begin
	fnd_file.put_line(fnd_file.log,'Allocation ');

open c_offadj ;
loop
	c_offadj_data.level1_value.delete;
	c_offadj_data.level2_value.delete;
	c_offadj_data.level3_value.delete;
	c_offadj_data.level4_value.delete;
	c_offadj_data.level5_value.delete;
	c_offadj_data.level6_value.delete;
	c_offadj_data.level7_value.delete;
	c_offadj_data.level8_value.delete;
	c_offadj_data.level9_value.delete;
	c_offadj_data.level10_value.delete;
	c_offadj_data.date_value.delete;
	c_offadj_data.measure1_value.delete;
	c_offadj_data.measure2_value.delete;
	c_offadj_data.measure3_value.delete;
	c_offadj_data.measure4_value.delete;
	c_offadj_data.measure5_value.delete;
	c_offadj_data.measure6_value.delete;

	fetch c_offadj bulk collect into
	c_offadj_data.level1_value,
	c_offadj_data.level2_value,
	c_offadj_data.level3_value,
	c_offadj_data.level4_value,
	c_offadj_data.level5_value,
	c_offadj_data.level6_value,
	c_offadj_data.level7_value,
	c_offadj_data.level8_value,
	c_offadj_data.level9_value,
	c_offadj_data.level10_value,
	c_offadj_data.date_value,
	c_offadj_data.measure1_value,
	c_offadj_data.measure2_value,
	c_offadj_data.measure3_value,
	c_offadj_data.measure4_value,
	c_offadj_data.measure5_value,
	c_offadj_data.measure6_value
	limit l_rows;
	fnd_file.put_line(fnd_file.log,
            'Number of rows fetched- '||c_offadj_data.level1_value.count);
      if c_offadj_data.level1_value.count>0 then
	fnd_file.put_line(fnd_file.log,'Deleting measures if exists ');
            begin
	    forall I in 1..c_offadj_data.level1_value.count
		delete qpr_measure_data
		where instance_id=p_instance_id
		and measure_type_code= 'OFFADJDATA'
		and ord_level_value=c_offadj_data.level2_value(I)
		and adj_level_value=c_offadj_data.level1_value(I);
		fnd_file.put_line(fnd_file.log, 'Deleted '||
				sql%rowcount ||' records');
	    exception
		when others then
			null;
            end;
            begin
	    fnd_file.put_line(fnd_file.log,'Inserting measures ');
	    forall I in 1..c_offadj_data.level1_value.count
	      insert into QPR_MEASURE_DATA(
			  MEASURE_VALUE_ID,
			  MEASURE_TYPE_CODE,
			  INSTANCE_ID,
			  ORD_LEVEL_VALUE,
			  PRD_LEVEL_VALUE,
			  GEO_LEVEL_VALUE,
			  CUS_LEVEL_VALUE,
			  ORG_LEVEL_VALUE,
			  REP_LEVEL_VALUE,
			  CHN_LEVEL_VALUE,
			  ADJ_LEVEL_VALUE,
			  TIME_LEVEL_VALUE,
			  MEASURE1_NUMBER ,
			  CREATION_DATE ,
			  CREATED_BY ,
			  LAST_UPDATE_DATE ,
			  LAST_UPDATED_BY ,
			  LAST_UPDATE_LOGIN ,
			  REQUEST_ID) values
		(QPR_MEASURE_DATA_S.nextval,
			'OFFADJDATA',
			p_instance_id,
			c_offadj_data.level2_value(I),
			c_offadj_data.level3_value(I),
			c_offadj_data.level4_value(I),
			c_offadj_data.level5_value(I),
			c_offadj_data.level6_value(I),
			c_offadj_data.level7_value(I),
			c_offadj_data.level8_value(I),
			c_offadj_data.level1_value(I),
			c_offadj_data.date_value(I),
			-1 * decode(nvl(c_offadj_data.measure4_value(I), 0), 0, 0,
				c_offadj_data.measure3_value(I)*
			c_offadj_data.measure6_value(I)/c_offadj_data.measure4_value(I)),
-- When total gross revenue is null or 0, the off adjustment amount is 0, otherwise the allocated extended_amount.
-- Allocation of extended amount: when the quantity from the AR table is not null, the extended amount is
-- This extended amount is multiplied with the gross revenue
-- of the order line and divided with the total gross amount.
                        d_sysdate,
                        l_user_id,
                        d_sysdate,
                        l_user_id,
                        l_login_id,
                        l_request_id);
		fnd_file.put_line(fnd_file.log, 'Inserted '||
				sql%rowcount ||' records');
	    exception
	     when others then
		errbuf := substr(SQLERRM,1,150);
		retcode := -1;
		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	    end;
      end if;
      commit;

   exit when c_offadj%NOTFOUND;

   end loop; --c_offadj

   close c_offadj;
   begin
	delete qpr_measure_data temp
	where temp.instance_id=-999
	and temp.measure_type_code = 'OFFADJDATA'
	and temp.request_id = l_request_id;
	fnd_file.put_line(fnd_file.log, 'Deleted '|| sql%rowcount ||' temp records');
   end;
   commit;
exception
 WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    fnd_file.put_line(fnd_file.log,'Unexpected error '||substr(sqlerrm,1200));
End;

procedure consolidate_upd_sales_meas(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id in number,
			p_from_date in varchar2,
			p_to_date in varchar2) is

l_offadj_rev number;
l_margin_perc number;
l_pocket_price number;
l_pocket_price_rev number;
lctr pls_integer;
lrows number := 1000;
date_from date := fnd_date.canonical_to_date(p_from_date);
date_to  date :=  fnd_date.canonical_to_date(p_to_date);

type sales_rec is record(MEASURE_VALUE_ID num_type,
                         MEASURE1 num_type,
                         MEASURE2 num_type,
                         MEASURE3 num_type,
                         MEASURE4 num_type,
                         MEASURE5 num_type,
                         MEASURE6 num_type);

cursor c_get_margin_det is
select md.MEASURE_VALUE_ID,
       nvl(md.measure1_number,0) as order_qty,
       nvl(md.measure3_number,0) * nvl(md.measure1_number,0) as listpricerev,
       nvl(md.measure15_number,0) as cost,
       nvl(md2.offadj_amt, 0) as offadj_amt,
       nvl(md.measure2_number, 0 ) as gross_revenue,
       nvl(md1.freight_amount, 0) as freight_amount
from qpr_measure_data md,
     (select sum(m1.measure1_number) freight_amount, m1.ord_level_Value,
      m1.time_level_Value
      from qpr_measure_data m1
      where m1.instance_id = p_instance_id
      and m1.measure_type_code = 'ADJUSTMENT'
      and m1.measure1_char = 'FREIGHT_CHARGE'
      and m1.time_level_value between date_from and date_to
      group by m1.ord_level_value, m1.time_level_value) md1,
      (select sum(m2.measure1_number) offadj_amt, m2.ord_level_value,
      m2.time_level_value
      from qpr_measure_data m2
      where m2.measure_type_code = 'OFFADJDATA'
      and m2.instance_id = p_instance_id
      and m2.TIME_LEVEL_VALUE between date_from and date_to
      group by m2.ORD_LEVEL_VALUE, m2.TIME_LEVEL_VALUE) md2
where md.measure_type_code = 'SALESDATA'
and md.instance_id = p_instance_id
and md.time_level_value between date_from and date_to
and md.ord_level_value = md1.ord_level_value(+)
and md.time_level_value = md1.time_level_Value(+)
and md.ord_level_value = md2.ord_level_value(+)
and md.time_level_value = md2.time_level_Value(+);

rec_mrg_det sales_rec;
rec_upd_det sales_rec;
begin
    fnd_file.put_line(fnd_file.log,
'Consolidating offinvoice adjustments & updating relevant sales measures ...');
    open c_get_margin_det;
    loop
      fetch c_get_margin_det bulk collect into rec_mrg_det limit lrows;
      exit when rec_mrg_det.measure_value_id.count = 0;
      lctr := 0;
      -- measure1 = order qty, measure2 =listprice rev, measure3 = cost
      -- measure4 = total off adj, measure5 = gross_rev
      -- measure6 = freight_amount
      for i in rec_mrg_det.measure_value_id.first..
      					rec_mrg_det.measure_value_id.last loop
        l_offadj_rev := nvl(rec_mrg_det.measure4(i), 0);
        l_pocket_price_rev := rec_mrg_det.measure5(i) - (-1*l_offadj_rev);
        if rec_mrg_det.measure1(i) <> 0 then
          l_pocket_price := l_pocket_price_rev/rec_mrg_det.measure1(i);
        else
          l_pocket_price := 0;
        end if;
        if rec_mrg_det.measure2(i) <> 0 then
          l_margin_perc := 100 * (l_pocket_price_rev -
                        (-1 * rec_mrg_det.measure3(i)))/rec_mrg_det.measure2(i);
        else
          l_margin_perc := 100;
        end if;
        rec_upd_det.measure_value_id(lctr) := rec_mrg_det.measure_value_id(i);
        rec_upd_det.measure1(lctr) := l_pocket_price;
        rec_upd_det.measure2(lctr) := l_offadj_rev;
        rec_upd_det.measure3(lctr) := l_margin_perc;
        rec_upd_det.measure4(lctr) := rec_mrg_det.measure6(i);
        lctr := lctr + 1;
      end loop;

      fnd_file.put_line(fnd_file.log,
            'Updated Records=' || rec_upd_det.measure_value_id.count);
      forall i in rec_upd_det.measure_value_id.first..rec_upd_det.measure_value_id.last
        update qpr_measure_data
        set measure5_number = rec_upd_det.measure1(i),
            measure14_number = rec_upd_det.measure2(i),
            measure17_number = rec_upd_det.measure3(i),
            measure20_number = rec_upd_det.measure4(i),
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id
        where measure_value_id = rec_upd_det.measure_value_id(i);

      rec_upd_det.measure_value_id.delete;
      rec_upd_det.measure1.delete;
      rec_upd_det.measure2.delete;
      rec_upd_det.measure3.delete;
      rec_upd_det.measure4.delete;

      rec_mrg_det.measure_value_id.delete;
      rec_mrg_det.measure1.delete;
      rec_mrg_det.measure2.delete;
      rec_mrg_det.measure3.delete;
      rec_mrg_det.measure4.delete;
      rec_mrg_det.measure5.delete;
      rec_mrg_det.measure6.delete;
    end loop;

    close c_get_margin_det;
    commit;
exception
  when OTHERS then
    retcode := 2;
    errbuf  := 'ERROR: ' || substr(SQLERRM,1,1000);
    fnd_file.put_line(fnd_file.log,
	'Unable to update sales measures');
    fnd_file.put_line(fnd_file.log, 'ERROR: ' || substr(SQLERRM,1,1000));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    rollback;
end consolidate_upd_sales_meas;

procedure update_pr_segment(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id in number,
                        p_from_date in varchar2,
                        p_to_date in varchar2) is

cursor c_measures(p_date_from date, p_date_to date) is
select measure_value_id,cus_level_value, geo_level_value, org_level_value,
prd_level_value, chn_level_value ,rep_level_value , ord_level_value,
time_level_value
from qpr_measure_data
where instance_id = p_instance_id
and measure_type_code = 'SALESDATA'
and time_level_value between p_date_from and p_date_to
order by cus_level_value, geo_level_value, org_level_value,
prd_level_value, chn_level_value ,rep_level_value;


t_meas_val_id num_type;
t_cus char240_type;
t_geo char240_type;
t_org char240_type;
t_prd char240_type;
t_chn char240_type;
t_rep char240_type;
t_ord char240_type;
t_psg_val num_type;
t_time date_type;

l_rows number := 1000;
l_prev_cus varchar2(240);
l_prev_geo varchar2(240);
l_prev_org varchar2(240);
l_prev_prd varchar2(240);
l_prev_chn varchar2(240);
l_prev_rep varchar2(240);
l_pr_segment_id number;
l_pr_segment_desc varchar2(240);
l_pol_importance varchar2(30);

l_dummy number;
date_from date;
date_to date;

begin
date_from := fnd_date.canonical_to_date(p_from_date);
date_to := fnd_date.canonical_to_date(p_to_date);

open c_measures(date_from, date_to);
loop
  fetch c_measures bulk collect into t_meas_val_id, t_cus, t_geo, t_org,
                           t_prd, t_chn, t_rep, t_ord, t_time limit l_rows;
  exit when t_meas_val_id.count = 0;
  fnd_file.put_line(fnd_file.log, 'count: ' || t_meas_val_id.count);
  for i in t_meas_val_id.first..t_meas_val_id.last loop

    if l_prev_cus = t_cus(i)
    and l_prev_geo = t_geo(i)
    and l_prev_org = t_org(i)
    and l_prev_prd = t_prd(i)
    and l_prev_chn = t_chn(i)
    and l_prev_rep = t_rep(i) then
      t_psg_val(i) := l_pr_segment_id;
    else
      qpr_policy_eval.get_pricing_segment_id(p_instance_id,
                                        null,
                                        null,
                                        t_prd(i),
                                        t_geo(i),
                                        t_cus(i),
                                        t_org(i),
                                        t_rep(i),
                                        t_chn(i),
                                        null,
                                        l_pr_segment_id,
                                        l_pol_importance);
      t_psg_val(i) := l_pr_segment_id;
/*
      if l_pr_segment_id is not null then
        begin
          select 1 into l_dummy
          from qpr_dimension_values
          where dim_code = 'PSG'
          and hierarchy_code = 'PR_SEGMENT'
          and level1_value = l_pr_segment_id
          and instance_id = p_instance_id
          and rownum < 2;
        exception
          WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.log,'inserting psg:' || l_pr_segment_id);
            begin
              select name into l_pr_segment_desc
              from qpr_pr_segments_vl
              where pr_segment_id = l_pr_segment_id
              and rownum < 2;
            exception
              when no_data_found then
                l_pr_segment_id := null;
                l_pr_segment_desc:= null;
            end;
--TODO: All level to be added
            insert into qpr_dimension_values(DIM_VALUE_ID,
                                        INSTANCE_ID,
                                        DIM_CODE,
                                        HIERARCHY_CODE,
                                        LEVEL1_VALUE,
                                        LEVEL1_DESC,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN)
            values(qpr_dimension_values_s.nextval,
                p_instance_id,
                'PSG',
                'PR_SEGMENT',
                l_pr_segment_id,
                l_pr_segment_desc,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id);
        end;
      end if; */

    end if;

    l_prev_cus := t_cus(i);
    l_prev_geo := t_geo(i);
    l_prev_org := t_org(i);
    l_prev_prd := t_prd(i);
    l_prev_chn := t_chn(i);
    l_prev_rep := t_rep(i);
  end loop;

  fnd_file.put_line(fnd_file.log,
          'updating pricing segments for measuretype:salesdata');
  forall i in t_meas_val_id.first..t_meas_val_id.last
    update qpr_measure_data set psg_level_value = t_psg_val(i),
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    request_id = fnd_global.conc_request_id
    where measure_value_id = t_meas_val_id(i);

  fnd_file.put_line(fnd_file.log,'Updating measuretypes:ADJUSTMENT,OFFADJDATA');
  forall i in t_meas_val_id.first..t_meas_val_id.last
    update qpr_measure_data set psg_level_value = t_psg_val(i),
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    request_id = fnd_global.conc_request_id
    where instance_id = p_instance_id
    and measure_type_code in ('ADJUSTMENT', 'OFFADJDATA')
    and ord_level_value = t_ord(i)
    and time_level_value = t_time(i);

  t_meas_val_id.delete;
  t_geo.delete;
  t_org.delete;
  t_prd.delete;
  t_chn.delete;
  t_rep.delete;
  t_psg_val.delete;
  t_ord.delete;
  t_time.delete;
end loop;
close c_measures;

exception
when others then
  errbuf := sqlerrm;
  retcode := 2;
  fnd_file.put_line(fnd_file.log, 'Unable to update pricing segment');
  fnd_file.put_line(fnd_file.log, dbms_utility.format_error_backtrace);
end update_pr_segment;


END QPR_SPECIAL_ETL;

/
