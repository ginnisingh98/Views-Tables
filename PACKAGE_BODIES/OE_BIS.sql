--------------------------------------------------------
--  DDL for Package Body OE_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BIS" AS
/* $Header: OEXBISRB.pls 115.6 2003/04/02 02:25:49 sphatarp ship $ */
function get_daily_value_shipped (p_day IN DATE,
                                  p_warehouse_id IN NUMBER,
				  p_currency  IN VARCHAR2)
   return NUMBER IS

p_daily_value	NUMBER;

BEGIN

/*
	select sum(
       decode(gl_currency_api.rate_exists(line_currency,p_currency,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, p_currency,
                                     trunc(sysdate),'Corporate'),
       1) *
            shipment_value)
        into p_daily_value
	from wsh_bis_fill_rate_v
	where date_closed = p_day
          and warehouse_id = p_warehouse_id;
*/
	select sum(shipment_value)
        into p_daily_value
	from wsh_bis_fill_rate_v
	where date_closed = p_day
          and warehouse_id = p_warehouse_id;

	return( p_daily_value);

  EXCEPTION
    WHEN OTHERS THEN
	return (0);

END;

function get_days_top_returns (p_day IN DATE,
                               p_org_id IN NUMBER)
   return NUMBER IS

p_days_bookings	NUMBER;
p_days_returns  NUMBER;

BEGIN

     begin
	select count(*)
        into p_days_bookings
        from oe_bis_bookings_v
        where customer_id in
 	(select customer_id from oe_bis_top_customers)
        and trunc(booking_date) = p_day
        and nvl(p_org_id,ou_id) = ou_id;

     exception
	WHEN NO_DATA_FOUND THEN
           p_days_bookings :=0;
      end;

     begin
	select count(*)
        into p_days_returns
        from so_lines_all l, so_headers_all h
        where h.customer_id in
	 	(select customer_id from oe_bis_top_customers)
        and l.creation_date = p_day
        and nvl(p_org_id,l.org_id) = l.org_id
        and l.line_type_code = 'RETURN';

     exception
	WHEN NO_DATA_FOUND THEN
           p_days_returns :=0;
      end;

	return( p_days_returns/ p_days_bookings * 100);

  EXCEPTION
    WHEN OTHERS THEN
	return (0);

END;


function get_days_top_deliveries (p_day IN DATE,
                                  p_org_id IN NUMBER)
   return NUMBER IS

delivery_percent	NUMBER;

BEGIN

     begin
         select sum(decode(trunc(promise_date),
                           trunc(date_closed),1,0)) /
                           count(*) * 100
 	 into delivery_percent
         from wsh_bis_fill_rate_v
        where customer_id in
	 	(select customer_id
		 from oe_bis_top_customers)
          and promise_date = p_day
          and nvl(p_org_id,ou_id) = ou_id;

     exception
	WHEN NO_DATA_FOUND THEN
           delivery_percent :=0;
      end;

	return( delivery_percent);

  EXCEPTION
    WHEN OTHERS THEN
	return (0);

END;



Procedure GET_TOP_CUSTOMERS     ( P_PERIOD_START DATE,
			          P_PERIOD_END   DATE,
                                  P_CURRENCY     VARCHAR2,
                                  P_ORG_ID       NUMBER ) IS

cursor cust is
	select 	customer_id,
              	sum(
       decode(gl_currency_api.rate_exists(line_currency,p_currency,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, p_currency,
                                     trunc(sysdate),'Corporate'),
       1) *
                   (ordered_quantity - cancelled_quantity) *
                   unit_selling_price)  sales
 	from oe_bis_bookings_v
        where booking_date between
              to_date('01-01-'||to_char(sysdate,'YYYY'),'DD-MM-YYYY')
              and sysdate
          and nvl(p_org_id,ou_id) = ou_id
	group by customer_id
	order by sales desc;

counter number :=0;

begin

--   lock table oe_bis_top_customers in exclusive mode nowait;

   delete from oe_bis_top_customers;
   commit;

   FOR custrec in cust LOOP

	insert into oe_bis_top_customers (
			customer_id,
			ytd_sales,
                        currency_code,
                        period_start,
                        period_end,
                        organization_id,
			creation_date)
                values
		       (custrec.customer_id,
                        custrec.sales,
                        p_currency,
                        p_period_start,
                        p_period_end,
                        p_org_id,
			sysdate );


         counter := counter + 1;
      IF (counter = 10) then
        EXIT;
      END IF;


   END LOOP;

         update oe_bis_top_customers c
	   set period_bookings =
		(select sum(
       decode(gl_currency_api.rate_exists(line_currency,p_currency,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, p_currency,
                                     trunc(sysdate),'Corporate'),
       1) *
                line_selling_price)
		 from oe_bis_bookings_v
		 where booking_date between p_period_start and p_period_end
                   and nvl(p_org_id,ou_id) = ou_id
                   and customer_id = c.customer_id);

         update oe_bis_top_customers c set
               period_billings =
                 (select sum(
       decode(gl_currency_api.rate_exists(line_currency,p_currency,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, p_currency,
                                     trunc(sysdate),'Corporate'),
       1) *
                invoiced_selling_price)
                   from oe_bis_billings_v
                 where invoicing_date between p_period_start and p_period_end
                   and nvl(p_org_id,ou_id) = ou_id
                   and  customer_id = c.customer_id);

         update oe_bis_top_customers c set
               current_backlog =
		  (select sum(
       decode(gl_currency_api.rate_exists(line_currency,p_currency,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, p_currency,
                                     trunc(sysdate),'Corporate'),
       1) *
                 bl_selling_price)
                    from oe_bis_backlog_v
                   where customer_id = c.customer_id
                   and nvl(p_org_id,ou_id) = ou_id);

--lchen remove alias on_time_perent from following subquery to fix bug 1753574

         update oe_bis_top_customers c set
               on_time_deliveries =
                   (select sum(decode(trunc(promise_date),
                           trunc(date_closed),1,0)) /
                           count(*) * 100
                     from wsh_bis_fill_rate_v
                     where customer_id = c.customer_id
                     and promise_date between p_period_start and p_period_end);

         update oe_bis_top_customers c set
                return_lines  =
                  (select count(*)
                     from so_lines_all l, so_headers_all h
                     where l.header_id = h.header_id
                     and h.customer_id = c.customer_id
                     and l.line_type_code = 'RETURN'
                     and l.org_id = nvl(p_org_id,l.org_id)
                     and l.creation_date between
                            p_period_start and p_period_end);

         update oe_bis_top_customers c set
                 order_lines =
                   (select count(distinct line_id)
		     from oe_bis_bookings_v
		      where customer_id = c.customer_id
                      and ou_id = nvl(p_org_id,ou_id)
                      and booking_date between p_period_start and p_period_end);

	commit;

exception
when others then
-- dbms_output.put_line(SQLERRM);
 null;
end get_top_customers;


Procedure GET_BBB_INFO          ( P_PERIOD_START DATE,
			          P_PERIOD_END   DATE,
                                  P_CURRENCY     VARCHAR2,
                                  P_ORG_ID       NUMBER ) IS

begin

	delete from oe_bis_bbb_info;

	insert into oe_bis_bbb_info ( period_year,
				      period_num,
				      period_name,
				      period_start,
	 			      period_end,
                                      currency_code,
                                      ou_id )
	select 	gp.period_year,
		gp.period_num,
		gp.period_name,
	       gp.start_date,
		gp.end_date,
		p_currency,
		p_org_id
	from gl_periods gp
	where gp.period_type = 'Month'
        and gp.adjustment_period_flag = 'N'
	and gp.period_set_name = 'Accounting'
	and ((p_period_start <= gp.start_date
	and p_period_end >= gp.end_date)
	or (p_period_end between gp.start_date and gp.end_date));

         update oe_bis_bbb_info bbb
	   set bookings =
		(select sum(
       decode(gl_currency_api.rate_exists(line_currency, bbb.currency_code,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, bbb.currency_code,
                                     trunc(sysdate),'Corporate'),
       1) *
                line_selling_price)
		 from oe_bis_bookings_v
		 where booking_date between bbb.period_start and bbb.period_end
                   and nvl(p_org_id,ou_id) = ou_id);

         update oe_bis_bbb_info bbb set
               billings =
                 (select sum(
       decode(gl_currency_api.rate_exists(line_currency,bbb.currency_code,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, bbb.currency_code,
                                     trunc(sysdate),'Corporate'),
       1) *
                invoiced_selling_price)
                   from oe_bis_billings_v
                 where invoicing_date between bbb.period_start and bbb.period_end
                   and nvl(p_org_id,ou_id) = ou_id);

         update oe_bis_bbb_info bbb set
               adjustments =
                 (select sum(
       decode(gl_currency_api.rate_exists(currency_code,bbb.currency_code,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(currency_code, bbb.currency_code,
                                     trunc(sysdate),'Corporate'),
       1) *
                selling_price * cancelled_quantity)
                   from oe_bis_cancelled_bookings_v
                 where cancel_date between bbb.period_start and bbb.period_end
                   and nvl(p_org_id,ou_id) = ou_id);


         update oe_bis_bbb_info bbb set
               closing_backlog =
		  (select sum(
       decode(gl_currency_api.rate_exists(line_currency, bbb.currency_code,
                                          trunc(sysdate),'Corporate'),
       'Y', gl_currency_API.get_rate(line_currency, bbb.currency_code,
                                     trunc(sysdate),'Corporate'),
       1) *
                 bl_selling_price)
                    from oe_bis_backlog_v
                   where (invoiced_flag = 'N' or invoiced_date > bbb.period_end)
		   and booked_date <= bbb.period_end+1
                   and nvl(p_org_id,ou_id) = ou_id);


	commit;

exception
when others then
 -- dbms_output.put_line(SQLERRM);
 null;
end get_bbb_info;



END;

/
