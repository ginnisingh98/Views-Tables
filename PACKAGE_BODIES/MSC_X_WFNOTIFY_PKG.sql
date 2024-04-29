--------------------------------------------------------
--  DDL for Package Body MSC_X_WFNOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_WFNOTIFY_PKG" AS
/*$Header: MSCXNFPB.pls 120.6 2007/07/19 08:34:58 vsiyer ship $ */

G_ORDER_FORECAST	CONSTANT INTEGER := 2;
G_SUPPLY_COMMIT		CONSTANT INTEGER := 3;

/*------------------------------------------------------------------------
  private function
-------------------------------------------------------------------------*/

--function returns 0 if a user has selected a exception for notifiaction else returns 1
function validate_block_notification(p_user_name in varchar2, p_exception_type in number) return number is
	cursor check_user(p_user in varchar2, p_excep_type number) is
	select 1
	from MSC_EXCEPTION_PREFERENCES ep,
	     fnd_user u
	where ep.user_id = u.user_id
	and u.user_name = p_user
	and exception_type_lookup_code = p_excep_type
	and rank > 0;
	l_select_flag number; --- Bug # 6242764
begin
	open check_user(p_user_name, p_exception_type);
	fetch check_user into l_select_flag;
	if check_user%found then
		close check_user;
		return 0; --dont block, validation failed
	end if;
	close check_user;
	return 1; --block notification
end validate_block_notification; ---Added for bug # 6175897

/*------------------------------------------------------------------------
  Workflow Procedures
-------------------------------------------------------------------------*/

PROCEDURE Launch_WF (p_errbuf OUT NOCOPY Varchar2,
                        p_retcode OUT NOCOPY Number) IS
--This cursor selects records inserted into msc_exception_details
--in the current planning run. Last update login column is set to -99
--to indicate this fact. When plan is selected for netting again, this
--column is reset to null in all records inserted into this table in prior runs.
--This mechanism prevents us from sending the planner multiple notifications
--for the same exception.
CURSOR wf_details_c IS
select  ex.exception_detail_id,
   ex.sr_instance_id,
        ex.company_id,
        ex.company_name,
        ex.company_site_id,
        ex.company_site_name,
        ex.inventory_item_id,
        ex.item_name,
        ex.item_description,
        ex.exception_group,
        ex.exception_type,
        ex.exception_type_name,
   	ex.supplier_id,
        ex.supplier_name,
        ex.supplier_site_id,
        ex.supplier_site_name,
        ex.trading_partner_item_name,
        ex.customer_id,
        ex.customer_name,
        ex.customer_site_id,
        ex.customer_site_name,
        ex.trading_partner_item_name,
        ex.number3,        --based item qty
        ex.transaction_id1,         --base item trx id
        ex.transaction_id2,         --pegged item trx id
        ex.number1,        --total supply/total intransit
        ex.number2,        --total demand/total onhand
        ex.threshold,         --lead time/itm min/itm max/threshold
        ex.lead_time,
        ex.item_min_qty,
        ex.item_max_qty,
        ex.date1,       --based item actual dt
        ex.date2,       --pegged item actual dt
        ex.date3,       --today's dt (sysdate)
        ex.date4,
        ex.date5,
        ex.exception_basis,
        ex.order_creation_date1, --based item creation dt
        ex.order_creation_date2, --pegged item creation date
        ex.order_number,
        ex.release_number,
        ex.line_number,
        ex.end_order_number,
        ex.end_order_rel_number,
        ex.end_order_line_number
from    msc_x_exception_details ex
where   ex.plan_id = -1
and   ex.exception_group in (1,2,3,4,5,6,7,8,9,10)    --exclude user define exceptions
and   ex.version = 'CURRENT';    --indicate the current run of the netting engine


/*----------------------------------------------
  Get the planner from the planner code only if
  the company is seeded which is company_id =1
  (OEM)
  -------------------------------------------*/
CURSOR planners_c(p_company_id in number,
      p_company_site_id in Number,
                  p_item_id in Number) IS
SELECT distinct pl.user_name
FROM     msc_system_items msi,
   msc_company_sites s,
   msc_trading_partner_maps map,
   msc_trading_partners part,
   msc_planners pl
WHERE    s.company_id = 1
AND   s.company_site_id = p_company_site_id
AND   map.map_type = 2
AND   map.company_key = s.company_site_id
AND   part.partner_id = map.tp_key
AND   msi.organization_id = part.sr_tp_id
AND   msi.sr_instance_id = part.sr_instance_id
AND   msi.plan_id = -1
AND   msi.inventory_item_id = p_item_id
AND   pl.sr_instance_id = part.sr_instance_id
AND   pl.planner_code = msi.planner_code
AND   pl.organization_id  = part.sr_tp_id;


/*--------------------------------------------------------
 Look for the partner contact by the site first
 If the site is not exist, then search by the company
 ---------------------------------------------------------*/
CURSOR partner_con_by_site_c(p_company_id in number,
      p_company_site_id in Number,p_oem_site_id in NUMBER,p_inventory_item_id in NUMBER) IS
SELECT   distinct con.name
FROM  msc_trading_partner_maps map,
      msc_trading_partner_maps map1,
      msc_company_sites site,
      msc_partner_contacts con
WHERE map.map_type = 3
AND   map.company_key = site.company_site_id
AND   map.tp_key = con.partner_site_id
AND   map1.company_key =p_oem_site_id
AND   map1.map_type= 2
AND   site.company_id = p_company_id
AND   site.company_site_id = p_company_site_id
AND exists ( select 1 from msc_system_items msi, msc_trading_partners mt
where msi.plan_id = -1 --- Bug # 6242764
and   msi.sr_instance_id = con.sr_instance_id
and   msi.inventory_item_id = p_inventory_item_id
and   mt.partner_id  = map1.tp_key
and   mt.sr_tp_id = msi.organization_id
and   mt.partner_type=3);     -- Bug #6242828

/*-------------------------------------------------------------------------------
Look for the partner contact by site independent of sr_instance_id clause.
---------------------------------------------------------------------------------*/

CURSOR partner_con_by_site_c1(p_company_id in NUMBER,
      p_company_site_id in NUMBER) IS
SELECT
    distinct con.name
FROM
   msc_trading_partner_maps map,
   msc_company_sites site,
   msc_partner_contacts con
WHERE    map.map_type = 3
AND   map.company_key = site.company_site_id
AND   map.tp_key = con.partner_site_id
AND   site.company_id = p_company_id
AND   site.company_site_id = p_company_site_id;  -- Bug #6242828

CURSOR partner_con_by_comp_c(p_company_id in number, p_oem_id in number,p_inventory_item_id in number) IS
SELECT  distinct con.name
FROM  msc_trading_partner_maps map,
      msc_trading_partner_maps map1,
      msc_company_relationships rel,
      msc_companies c,
      msc_partner_contacts con
WHERE map.map_type = 1        --company
AND   map.company_key = rel.relationship_id
AND   rel.relationship_type = 2     --supplier
AND   rel.object_id = c.company_id
AND   map.tp_key = con.partner_id
AND   map1.company_key =p_oem_id
AND   map1.map_type= 2
AND   con.partner_type = 1        --suplier
AND   c.company_id = p_company_id
AND exists ( select 1 from msc_system_items msi,msc_trading_partners mt
where msi.plan_id = -1 --- Bug # 6242764
and   msi.sr_instance_id = con.sr_instance_id
and   msi.inventory_item_id = p_inventory_item_id
and   mt.partner_id  = map1.tp_key
and   mt.sr_tp_id = msi.organization_id
and   mt.partner_type=3)
UNION
SELECT  distinct con.name
FROM  msc_trading_partner_maps map,
      msc_trading_partner_maps map1,
      msc_company_relationships rel,
      msc_companies c,
      msc_partner_contacts con
WHERE    map.map_type = 1        --company
AND   map.company_key = rel.relationship_id
AND   rel.relationship_type = 1     --customer
AND   rel.object_id = c.company_id
AND   con.partner_id = map.tp_key
AND   map1.company_key =p_oem_id
AND   map1.map_type= 2
AND   con.partner_type = 2        --customer
AND   c.company_id = p_company_id
AND exists ( select 1 from msc_system_items msi, msc_trading_partners mt
where msi.plan_id = -1 --- Bug # 6242764
and   msi.sr_instance_id = con.sr_instance_id
and   msi.inventory_item_id = p_inventory_item_id
and   mt.partner_id  = map1.tp_key
and   mt.sr_tp_id = msi.organization_id
and   mt.partner_type=3);    -- Bug #6242828

/*-------------------------------------------------------------------------------
Look for the partner contact by company independent of sr_instance_id
---------------------------------------------------------------------------------*/

CURSOR partner_con_by_comp_c1(p_company_id in number) IS
SELECT  distinct con.name
FROM  msc_trading_partner_maps map,
      msc_company_relationships rel,
      msc_companies c,
      msc_partner_contacts con
WHERE map.map_type = 1        --company
AND   map.company_key = rel.relationship_id
AND   rel.relationship_type = 2     --supplier
AND   rel.object_id = c.company_id
AND   map.tp_key =con.partner_id
AND   con.partner_type = 1        --suplier
AND   c.company_id = p_company_id
UNION
SELECT  distinct con.name
FROM  msc_trading_partner_maps map,
   msc_company_relationships rel,
   msc_companies c,
   msc_partner_contacts con
WHERE    map.map_type = 1        --company
AND   map.company_key = rel.relationship_id
AND   rel.relationship_type = 1     --customer
AND   rel.object_id = c.company_id
AND   con.partner_id = map.tp_key
AND   con.partner_type = 2        --customer
AND   c.company_id = p_company_id;  -- Bug #6242828


wf_type 		Varchar2(100);
wf_key  		Varchar2(100);
wf_process        	Varchar2(200);
l_user_id      		Number;
l_user_performer  	Varchar2(240);
l_real_name       	Varchar2(240);
l_exception_detail_id   Number;
l_sr_instance_id  	Number;
l_company_id      	Number;
l_company_name       	msc_sup_dem_entries.publisher_name%type;
l_company_site_id 	Number;
l_company_site_name  	msc_sup_dem_entries.publisher_site_name%type;
l_item_id      		Number;
l_item_name       	msc_items.item_name%type;
l_item_desc    		msc_x_exception_details.item_description%type;
l_exception_group 	Number;
l_exception_type     	Number;
l_exception_type_name   fnd_lookup_values.meaning%type;
l_supplier_id     	Number;
l_supplier_name      	msc_sup_dem_entries.supplier_name%type;
l_supplier_site_id   	Number;
l_supplier_site_name 	msc_sup_dem_entries.supplier_site_name%type;
l_supplier_item_name 	msc_sup_dem_entries.trading_partner_item_name%type;
l_customer_id     	Number;
l_customer_name      	msc_sup_dem_entries.customer_name%type;
l_customer_site_id   	Number;
l_customer_site_name 	msc_sup_dem_entries.customer_site_name%type;
l_customer_item_name 	msc_sup_dem_entries.trading_partner_item_name%type;
l_order_number          msc_sup_dem_entries.order_number%type;
l_release_number     	msc_sup_dem_entries.release_number%type;
l_line_number        	msc_sup_dem_entries.line_number%type;
l_end_order_number   	msc_sup_dem_entries.end_order_number%type;
l_end_order_rel_number  msc_sup_dem_entries.end_order_rel_number%type;
l_end_order_line_number msc_sup_dem_entries.end_order_line_number%type;
l_quantity        	Number;
l_transaction_id1 	Number;
l_transaction_id2 	Number;
l_quantity1       	Number;
l_quantity2       	Number;
l_threshold       	Number;
l_lead_time    		Number;
l_item_min_qty    	Number;
l_item_max_qty    	Number;
l_date1        		Date;
l_date2        		Date;
l_date3        		Date;
l_date4			Date;
l_date5			Date;
l_order_creation_date1  Date;
l_order_creation_date2  Date;
l_slogan       		Varchar2(240);
l_error_code      	Varchar2(1);
l_error_msg       	Varchar2(240);
l_operator_id     	Number;
l_language     		Varchar2(100);
l_planner_code   	Varchar2(500);
l_message_name    	Varchar2(100);
l_exist        		Number;
l_independent           NUMBER; -- Bug #6242828
l_exception_basis	msc_x_exception_details.exception_basis%type;

t_ex_detail_id  	number_arr;
t_sr_ins_id     	number_arr;
t_company_id   		number_arr;
t_company_site_id 	number_arr;
t_item_id  		number_arr;
t_supplier_id 		number_arr;
t_supplier_site_id 	number_arr;
t_customer_id 		number_arr;
t_customer_site_id 	number_arr;
t_trans_id1 		number_arr;
t_trans_id2  		number_arr;
t_quantity 		number_arr;
t_qty1   		number_arr;
t_qty2   		number_arr;
t_threshold 		number_arr;
t_lead_time 		number_arr;
t_item_min_qty 		number_arr;
t_item_max_qty 		number_arr;
t_date1 		date_arr;
t_date2 		date_arr;
t_date3 		date_arr;
t_date4			date_arr;
t_date5			date_arr;
t_order_date1 		date_arr;
t_order_date2 		date_arr;
t_company_name 		msc_x_netting_pkg.publisherList;
t_company_site_name 	msc_x_netting_pkg.pubsiteList;
t_item_name 		msc_x_netting_pkg.itemnameList;
t_item_desc 		msc_x_netting_pkg.itemdescList;
t_excep_group 		msc_x_netting_pkg.excepgroupList;
t_excep_type 		msc_x_netting_pkg.number_arr;
t_excep_type_name 	msc_x_netting_pkg.exceptypeList;
t_supplier_name 	msc_x_netting_pkg.supplierList;
t_supplier_site_name 	msc_x_netting_pkg.suppsiteList;
t_supplier_item_name 	msc_x_netting_pkg.tpitemnameList;
t_customer_name 	msc_x_netting_pkg.customerList;
t_customer_site_name 	msc_x_netting_pkg.custsiteList;
t_customer_item_name 	msc_x_netting_pkg.tpitemnameList;
t_order_number 		msc_x_netting_pkg.ordernumberList;
t_release_number 	msc_x_netting_pkg.releasenumList;
t_line_number 		msc_x_netting_pkg.linenumList;
t_end_order_num 	msc_x_netting_pkg.ordernumberList;
t_end_order_rel_num 	msc_x_netting_pkg.releasenumList;
t_end_order_line_num 	msc_x_netting_pkg.linenumList;
t_exception_basis	msc_x_netting_pkg.exceptbasisList;

l_inserted_record 	number;
l_oem_site_id           number;
l_oem_id                number; -- Bug #6242828
BEGIN

wf_type 		:= 'MSCSNDNT';
wf_process        	:= 'MSC_NOTIFICATION';
l_inserted_record 	:= 0;
l_exist        		:= 0;
l_independent           := 0;   -- Bug #6242828
t_ex_detail_id  	:= number_arr();
t_company_id   		:= number_arr();
t_company_site_id 	:= number_arr();
t_item_id  		:= number_arr();
t_supplier_id 		:= number_arr();
t_supplier_site_id 	:= number_arr();
t_customer_id 		:= number_arr();
t_customer_site_id 	:= number_arr();
t_trans_id1 		:= number_arr();
t_trans_id2  		:= number_arr();
t_quantity 		:= number_arr();
t_qty1   		:= number_arr();
t_qty2   		:= number_arr();
t_threshold 		:= number_arr();
t_lead_time 		:= number_arr();
t_item_min_qty 		:= number_arr();
t_item_max_qty 		:= number_arr();
t_date1 		:= date_arr();
t_date2 		:= date_arr();
t_date3 		:= date_arr();
t_date4			:= date_arr();
t_date5			:= date_arr();
t_order_date1 		:= date_arr();
t_order_date2 		:= date_arr();

--dbms_output.put_line('in workflow ');
    open wf_details_c;



      FETCH wf_details_c BULK COLLECT INTO
      t_ex_detail_id,
      t_sr_ins_id,
      t_company_id,
      t_company_name,
      t_company_site_id,
      t_company_site_name,
      t_item_id,
      t_item_name,
      t_item_desc,
        t_excep_group,
      t_excep_type,
      t_excep_type_name,
      t_supplier_id,
      t_supplier_name,
      t_supplier_site_id,
      t_supplier_site_name,
      t_supplier_item_name,
      t_customer_id,
        t_customer_name,
        t_customer_site_id,
        t_customer_site_name,
        t_customer_item_name,
      t_quantity,
      t_trans_id1,
      t_trans_id2,
      t_qty1,
      t_qty2,
      t_threshold,
      t_lead_time,
      t_item_min_qty,
      t_item_max_qty,
      t_date1,
      t_date2,
      t_date3,
      t_date4,
      t_date5,
      t_exception_basis,
      t_order_date1,
      t_order_date2,
      t_order_number,
      t_release_number,
      t_line_number,
      t_end_order_num,
      t_end_order_rel_num,
      t_end_order_line_num;

        CLOSE wf_details_c;


       /* Add an if statement to check for records */

--dbms_output.put_line('wf count ' || t_ex_detail_id.COUNT);
IF (t_ex_detail_id is not null and t_ex_detail_id.COUNT > 0) THEN

      FOR j in 1 .. t_ex_detail_id.COUNT
      LOOP

         l_message_name := getMessage(t_excep_type(j));
--dbms_output.put_line('message name ' || l_message_name);
           IF (t_company_id(j) = 1) THEN     --seeded company (OEM)
               open planners_c(t_company_id(j),
                        t_company_site_id(j),
                        t_item_id(j));

               loop
                  fetch planners_c into l_user_performer;
                  exit when planners_c%NOTFOUND;

  --dbms_output.put_line('user performer ' || l_user_performer);

       IF (l_user_performer is not null) and validate_block_notification(l_user_performer, t_excep_type(j)) = 0 then    ---Added for bug # 6175897
                     wf_key := t_excep_group(j) || '-' ||
                              to_char(t_excep_type(j)) || '-' ||
                                 to_char(t_item_id(j)) || '-' ||
                              to_char(t_company_id(j)) || '-' ||
                              to_char(t_company_site_id(j)) || '-' ||
                              to_char(t_customer_id(j)) || '-' ||
                              to_char(t_customer_site_id(j)) || '-' ||
                              to_char(t_supplier_id(j)) || '-' ||
                              to_char(t_supplier_site_id(j)) || '-' ||
                              to_char(t_ex_detail_id(j)) || '-' ||
                           l_user_performer;
               begin

      			SELECT substr(display_name,instr(display_name,',')+ 1) || ' ' ||
      				substr(display_name,1, instr(display_name,',') -1)
       			INTO	l_real_name
       			FROM 	wf_users
 			WHERE 	name = l_user_performer;
               exception
               		when others then
               		l_real_name := null;
               end;
               FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: user ' || l_real_name);
      --dbms_output.put_line('start 1');
               wfStart(wf_type,
                     wf_key,
                     wf_process,
                     l_user_performer,
                     l_real_name,
                     l_message_name,
                     t_excep_type(j),
                     t_excep_type_name(j),
                     --slogan,
                     t_item_id(j),
                     t_item_name(j),
                        t_item_desc(j),
                       t_company_id(j),
                     t_company_name(j),
                     t_company_site_id(j),
                     t_company_site_name(j),
                     t_supplier_id(j),
                     t_supplier_name(j),
                     t_supplier_site_id(j),
                     t_supplier_site_name(j),
                     t_supplier_item_name(j),
                     t_customer_id(j),
                     t_customer_name(j),
                     t_customer_site_id(j),
                     t_customer_site_name(j),
                     t_customer_item_name(j),
                     t_trans_id1(j),
                     t_trans_id2(j),
                     t_quantity(j),
                     t_qty1(j),
                     t_qty2(j),
                     t_threshold(j),
                     t_lead_time(j),
                     t_item_min_qty(j),
                     t_item_max_qty(j),
                     t_date1(j),
                     t_date2(j),
                     t_date3(j),
                     t_date4(j),
                     t_date5(j),
                     t_exception_basis(j),
                     t_order_date1(j),
                     t_order_date2(j),
                     t_order_number(j),
                     t_release_number(j),
                     t_line_number(j),
                     t_end_order_num(j),
                     t_end_order_rel_num(j),
                     t_end_order_line_num(j));
                     l_inserted_record := l_inserted_record + 1;
             END IF;       --user name is not null


          end loop;
          close planners_c;
   ELSE
      begin
         SELECT 1 into l_exist from dual
         WHERE    exists (SELECT 1
                               FROM  msc_trading_partner_maps map,
                                     msc_trading_partner_maps map1,
                                     msc_company_sites site,
                                     msc_partner_contacts con
                               WHERE  map.map_type = 3
                                AND   map.company_key = site.company_site_id
                                AND   map.tp_key = con.partner_site_id
                                AND   map1.company_key =decode(t_supplier_id(j),1,t_supplier_site_id(j),t_customer_site_id(j))
				                        AND   map1.map_type= 2
                                AND   site.company_id = t_company_id(j)
                                AND   site.company_site_id = t_company_site_id(j)
                                AND exists ( select 1 from msc_system_items msi, msc_trading_partners mt
					                                   where msi.plan_id = -1 --- Bug # 6242764
									   and   msi.sr_instance_id = con.sr_instance_id
					                                   and   msi.inventory_item_id = t_item_id(j)
					                                   and   mt.partner_id  = map1.tp_key
					                                   and   mt.sr_tp_id = msi.organization_id
					                                   and   mt.partner_type=3));

		       l_independent := 0 ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
            	SELECT 1 into l_exist
                FROM dual
                WHERE    exists (SELECT 1
                               FROM  msc_trading_partner_maps map,
                                     msc_company_sites site,
                                     msc_partner_contacts con
                               WHERE    map.map_type = 3
                                AND   map.company_key = site.company_site_id
                                AND   map.tp_key = con.partner_site_id
                                AND   site.company_id = t_company_id(j)
                                AND   site.company_site_id = t_company_site_id(j));   -- Bug #6242828
              l_independent := 1;

      exception
         when no_data_found then
            l_exist := 0;
      end;
   end;



      IF (l_exist = 1 ) THEN
         IF l_independent = 0 THEN

             select decode(t_supplier_id(j),1,t_supplier_site_id(j),t_customer_site_id(j))
             into l_oem_site_id
             from dual;

            --FND_FILE.PUT_LINE(FND_FILE.LOG,'After the sql----------------inside else part l_oem_site_id'|| l_oem_site_id);

             open partner_con_by_site_c(t_company_id(j), t_company_site_id(j),l_oem_site_id,t_item_id(j));
         ELSE
             open partner_con_by_site_c1(t_company_id(j), t_company_site_id(j));
         END IF;

         loop
	    IF l_independent = 0 THEN
               fetch partner_con_by_site_c into l_user_performer;
               exit when partner_con_by_site_c%NOTFOUND;
           ELSE
              fetch partner_con_by_site_c1 into l_user_performer;
              exit when partner_con_by_site_c1%NOTFOUND;
           END IF;

  --dbms_output.put_line('partner contact ' || l_user_performer);

 IF (l_user_performer is not null) and validate_block_notification(l_user_performer, t_excep_type(j)) = 0 then  ---Added for bug # 6175897
               wf_key :=  t_excep_group(j) || '-' ||
                     to_char(t_excep_type(j)) || '-' ||
                          to_char(t_item_id(j)) || '-' ||
                           to_char(t_company_id(j)) || '-' ||
                        to_char(t_company_site_id(j)) || '-' ||
                        to_char(t_customer_id(j)) || '-' ||
                        to_char(t_customer_site_id(j)) || '-' ||
                        to_char(t_supplier_id(j)) || '-' ||
                        to_char(t_supplier_site_id(j)) || '-' ||
                        to_char(t_ex_detail_id(j)) || '-' ||
                    l_user_performer;

               begin

      			SELECT substr(display_name,instr(display_name,',')+ 1) || ' ' ||
      				substr(display_name,1, instr(display_name,',') -1)
       			INTO	l_real_name
       			FROM 	wf_users
 			WHERE 	name = l_user_performer;
               exception
               		when others then
               		l_real_name := null;
               end;

             FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: user ' || l_real_name);
	--dbms_output.put_line('start 2');

         wfStart(wf_type,
                     wf_key,
                     wf_process,
                     l_user_performer,
                     l_real_name,
                     l_message_name,
                     t_excep_type(j),
                     t_excep_type_name(j),
                     --slogan,
                     t_item_id(j),
                     t_item_name(j),
                     t_item_desc(j),
                  t_company_id(j),
                     t_company_name(j),
                     t_company_site_id(j),
                     t_company_site_name(j),
                     t_supplier_id(j),
                     t_supplier_name(j),
                     t_supplier_site_id(j),
                     t_supplier_site_name(j),
                     t_supplier_item_name(j),
                     t_customer_id(j),
                     t_customer_name(j),
                     t_customer_site_id(j),
                     t_customer_site_name(j),
                     t_customer_item_name(j),
                     t_trans_id1(j),
                     t_trans_id2(j),
                     t_quantity(j),
                     t_qty1(j),
                     t_qty2(j),
                     t_threshold(j),
                     t_lead_time(j),
                     t_item_min_qty(j),
                     t_item_max_qty(j),
                     t_date1(j),
                     t_date2(j),
                     t_date3(j),
                     t_date4(j),
                     t_date5(j),
                     t_exception_basis(j),
                     t_order_date1(j),
                     t_order_date2(j),
                     t_order_number(j),
                     t_release_number(j),
                     t_line_number(j),
                     t_end_order_num(j),
                     t_end_order_rel_num(j),
                     t_end_order_line_num(j));
                     l_inserted_record := l_inserted_record + 1;
		 end if;
            end loop;
      IF l_independent = 0 THEN
      close partner_con_by_site_c;

      ELSE
      close partner_con_by_site_c1;
      END IF;

     ELSE -- Search by company

       BEGIN
          SELECT 0 into l_independent
          FROM dual
          WHERE    exists (SELECT 1
                           FROM  msc_trading_partner_maps map,
                                 msc_trading_partner_maps map1,
      				                   msc_company_relationships rel,
      			                     msc_companies c,
                                 msc_partner_contacts con
                           WHERE map.map_type = 1        --company
			                     AND   map.company_key = rel.relationship_id
			                     AND   (rel.relationship_type = 2     --supplier
                                  OR rel.relationship_type = 1)  --customer
			                     AND   rel.object_id = c.company_id
			                     AND   map.tp_key =  con.partner_id
			                     AND   map1.company_key =decode(t_supplier_id(j),1,t_supplier_id(j),t_customer_id(j))
		                       AND   map1.map_type= 2
			                     AND   (con.partner_type = 1        --suplier
			                            OR con.partner_type = 2)    --customer
			                     AND   c.company_id = t_company_id(j)
			                     AND exists ( SELECT 1
			                                  FROM msc_system_items msi,
			                                       msc_trading_partners mt
							  WHERE msi.plan_id = -1 --- Bug # 6242764
							  AND   msi.sr_instance_id = con.sr_instance_id
			                                  AND   msi.inventory_item_id = t_item_id(j)
			                                  AND   mt.partner_id  = map1.tp_key
			                                  AND   mt.sr_tp_id = msi.organization_id
			                                  AND   mt.partner_type=3) );  -- Bug #6242828
           l_exist := 1;
       EXCEPTION
      	  WHEN NO_DATA_FOUND THEN
      	     BEGIN
      	     SELECT 1 into l_independent
             FROM dual
             WHERE EXISTS (SELECT 1
                           FROM  msc_trading_partner_maps map,
                                 msc_company_relationships rel,
      			                     msc_companies c,
                                 msc_partner_contacts con
                           WHERE map.map_type = 1        --company
			                     AND   map.company_key = rel.relationship_id
			                     AND   (rel.relationship_type = 2     --supplier
                                  OR rel.relationship_type = 1)  --customer
			                     AND   rel.object_id = c.company_id
			                     AND   map.tp_key =con.partner_id
  		                     AND   c.company_id = t_company_id(j));
      	        l_exist := 1;
      	   EXCEPTION
      	        WHEN NO_DATA_FOUND THEN
      	         l_exist :=0;
      	   END;
       END;

       --FND_FILE.PUT_LINE(FND_FILE.LOG,'After the sql*************inside else part supplier id'||t_supplier_id(j) ||' customer_id'|| t_customer_id(j)||' company id'|| t_company_id(j) ||' item id '|| t_item_id(j));


       --FND_FILE.PUT_LINE(FND_FILE.LOG,'After the sql***************inside else part l_independent'|| l_independent);


       --FND_FILE.PUT_LINE(FND_FILE.LOG,'After the sql***************inside else part l_exist'|| l_exist);

      IF l_exist = 1 THEN
       IF l_independent = 0 THEN
             select decode(t_supplier_id(j),1,t_supplier_site_id(j),t_customer_site_id(j))
             into l_oem_id
             from dual;


             open partner_con_by_comp_c(t_company_id(j),l_oem_id,t_item_id(j));
       ELSE
             open partner_con_by_comp_c1(t_company_id(j));
       END IF;
            LOOP
               IF l_independent = 0 THEN
                 fetch partner_con_by_comp_c into l_user_performer;
                 exit when partner_con_by_comp_c%NOTFOUND;
               ELSE
         	       fetch partner_con_by_comp_c1 into l_user_performer;
                 exit when partner_con_by_comp_c1%NOTFOUND;
               END IF;

  --dbms_output.put_line('partner conact by site ' || l_user_performer);
  IF (l_user_performer is not null) and validate_block_notification(l_user_performer, t_excep_type(j)) = 0 then   ---Added for bug # 6175897
               wf_key :=  t_excep_group(j) || '-' ||
                       to_char(t_excep_type(j)) || '-' ||
                          to_char(t_item_id(j)) || '-' ||
                       to_char(t_company_id(j)) || '-' ||
                        to_char(t_company_site_id(j)) || '-' ||
                        to_char(t_customer_id(j)) || '-' ||
                        to_char(t_customer_site_id(j)) || '-' ||
                        to_char(t_supplier_id(j)) || '-' ||
                        to_char(t_supplier_site_id(j)) || '-' ||
                        to_char(t_ex_detail_id(j)) || '-' ||
                    l_user_performer;

               begin

      			SELECT substr(display_name,instr(display_name,',')+ 1) || ' ' ||
      				substr(display_name,1, instr(display_name,',') -1)
       			INTO	l_real_name
       			FROM 	wf_users
 			WHERE 	name = l_user_performer;
               exception
               		when others then
               		l_real_name := null;
               end;
             FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: user ' || l_real_name);
       --dbms_output.put_line('start 3');

            wfStart(wf_type,
                     wf_key,
                     wf_process,
                     l_user_performer,
                     l_real_name,
                     l_message_name,
                     t_excep_type(j),
                     t_excep_type_name(j),
                     --slogan,
                     t_item_id(j),
                     t_item_name(j),
                     t_item_desc(j),
                     t_company_id(j),
                     t_company_name(j),
                     t_company_site_id(j),
                     t_company_site_name(j),
                     t_supplier_id(j),
                     t_supplier_name(j),
                     t_supplier_site_id(j),
                     t_supplier_site_name(j),
                     t_supplier_item_name(j),
                     t_customer_id(j),
                     t_customer_name(j),
                     t_customer_site_id(j),
                     t_customer_site_name(j),
                     t_customer_item_name(j),
                     t_trans_id1(j),
                     t_trans_id2(j),
                     t_quantity(j),
                     t_qty1(j),
                     t_qty2(j),
                     t_threshold(j),
                     t_lead_time(j),
                     t_item_min_qty(j),
                     t_item_max_qty(j),
                     t_date1(j),
                     t_date2(j),
                     t_date3(j),
                     t_date4(j),
                     t_date5(j),
                     t_exception_basis(j),
                     t_order_date1(j),
                     t_order_date2(j),
                     t_order_number(j),
                     t_release_number(j),
                     t_line_number(j),
                     t_end_order_num(j),
                     t_end_order_rel_num(j),
                     t_end_order_line_num(j));
                     l_inserted_record := l_inserted_record + 1;
              end if;
            end loop;
        if l_independent = 0 then
           close partner_con_by_comp_c;
        else
           close partner_con_by_comp_c1;  -- Bug #6242828
        end if;
      end if;
     end if;
   end if;   --end of OEM company

   end loop;


   FND_FILE.PUT_LINE(FND_FILE.LOG,'Total WF notifications inserted: ' || l_inserted_record);



   --Reset the records for which the workflows have been
   --kicked off, to prevent the create duplicate wf items
   --dbms_output.put_line('Done with wf notifications');
   begin
         update msc_x_exception_details
         set version = null, last_update_login = null
         where plan_id = -1
         and version = 'CURRENT'
         and exception_group in (1,2,3,4,5,6,7,8,9,10);
   exception
         when others then
            ----dbms_output.put_line('Error in update ' || sqlerrm);
            null;
   end;
   END IF;

    commit;
EXCEPTION
   WHEN others then
   --dbms_output.put_line('error in launch wf ' || sqlerrm);
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_WFNOTIFY_PKG.launch_wf');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;
END Launch_WF;


--------------------------------------------------------------
--WFSTART
-------------------------------------------------------------
PROCEDURE wfStart(p_wf_type IN Varchar2,
               p_wf_key IN Varchar2,
               p_wf_process IN Varchar2,
               p_user_performer IN Varchar2,
               p_user_name IN Varchar2,
               p_message_name IN Varchar2,
               p_exception_type In Number,
               p_exception_type_name IN Varchar2,
               p_item_id In Number,
               p_item_name IN Varchar2,
               p_item_description IN Varchar2,
      		p_company_id In Number,
            p_company_name IN Varchar2,
            p_company_site_id IN Number,
            p_company_site_name In varchar2,
            p_supplier_id IN Number,
            p_supplier_name IN Varchar2,
            p_supplier_site_id IN Number,
            p_supplier_site_name In varchar2,
            p_supplier_item_name In varchar2,
            p_customer_id IN Number,
               p_customer_name IN Varchar2,
               p_customer_site_id IN Number,
               p_customer_site_name IN Varchar2,
      		p_customer_item_name In varchar2,
               p_transaction_id1 IN Number,
               p_transaction_id2 IN Number,
               p_quantity  In Number,
               p_quantity1 IN Number,
               p_quantity2 IN Number,
               p_threshold IN Number,
               p_lead_time In Number,
               p_item_min_qty In Number,
               p_item_max_qty In Number,
                  p_date1 IN Date,
               p_date2 IN Date,
               p_date3 IN Date,
               p_date4 IN Date,
               p_date5 IN Date,
               p_exception_basis IN Varchar2,
               p_order_creation_date1 IN Date,
               p_order_creation_date2 IN Date,
               p_order_number IN Varchar2,
               p_release_number IN Varchar2,
               p_line_number IN Varchar2,
               p_end_order_number IN Varchar2,
               p_end_order_rel_number IN Varchar2,
               p_end_order_line_number IN Varchar2) IS




l_event_name   		varchar2(100);
l_xml_event_key   	varchar2(100);
l_parameterlist   	wf_parameter_list_t;
l_planner   		varchar2(100);

BEGIN
l_event_name   		:= 'oracle.apps.msc.processing.netting';
l_parameterlist   	:= wf_parameter_list_t();
l_planner   		:= p_user_name;




--dbms_output.put_line('start in ');
   -- Now build the event key and raise the event
   l_xml_event_key := p_wf_key;


   wf_log_pkg.wf_debug_flag := TRUE;



   wf_event.AddParameterToList( p_name=>'FORWARD_TO_USERNAME',
                                 p_value=>p_user_performer,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'PLANNER',
                                 p_value=>p_user_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'MESSAGE_NAME',
                                 p_value=>p_message_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'EXCEPTION_TYPE',
                                 p_value=>p_exception_type,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'EXCEPTION_DESC',
                                 p_value=>p_exception_type_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'COMPANY_ID',
                                 p_value=> p_company_id,
                                 p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'COMPANY_NAME',
                                 p_value=> p_company_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'COMPANY_SITE_ID',
                                 p_value=> p_company_site_id,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'COMPANY_SITE_NAME',
                                 p_value=> p_company_site_name,
                                 p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'ITEM_ID',
                                 p_value=> p_item_id,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'ITEM_NAME',
                                 p_value=> p_item_name,
                                 p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'ITEM_DESC',
                                 p_value=> p_item_description,
                                 p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'SUPPLIER_ID',
                                 p_value=> p_supplier_id,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'SUPPLIER_NAME',
                                 p_value=> p_supplier_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'SUPPLIER_SITE_ID',
                                 p_value=> p_supplier_site_id,
                                 p_parameterlist=>l_parameterlist);

        wf_event.AddParameterToList( p_name=>'SUPPLIER_SITE_NAME',
                                 p_value=> p_supplier_site_name,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'SUPPLIER_ITEM_NAME',
                           p_value=> p_supplier_item_name,
                                 p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'CUSTOMER_ID',
                                 p_value=> p_customer_id,
                                 p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'CUSTOMER_NAME',
                                 p_value=> p_customer_name,
                                 p_parameterlist=>l_parameterlist);


        wf_event.AddParameterToList( p_name=>'CUSTOMER_SITE_ID',
                           p_value=> p_customer_site_id,
                        p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'CUSTOMER_SITE_NAME',
                     p_value=> p_customer_site_name,
                     p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'CUSTOMER_ITEM_NAME',
                           p_value=> p_customer_item_name,
                           p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'QUANTITY',
                                  p_value=> p_quantity,
                                  p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'TRANSACTION_ID1',
                                  p_value=> p_transaction_id1,
                                  p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'TRANSACTION_ID2',
                                  p_value=> p_transaction_id2,
                                  p_parameterlist=>l_parameterlist);


    wf_event.AddParameterToList( p_name=>'QUANTITY1',
                                  p_value=> p_quantity1,
                                  p_parameterlist=>l_parameterlist);


        wf_event.AddParameterToList( p_name=>'QUANTITY2',
                                  p_value=> p_quantity2,
                                  p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'THRESHOLD',
                                  p_value=> p_threshold,
                                  p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'LEAD_TIME',
                                  p_value=> p_lead_time,
                                  p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'ITEM_MIN_QTY',
                                  p_value=> p_item_min_qty,
                                  p_parameterlist=>l_parameterlist);

   wf_event.AddParameterToList( p_name=>'ITEM_MAX_QTY',
                                  p_value=> p_item_max_qty,
                                  p_parameterlist=>l_parameterlist);


   wf_event.AddParameterToList( p_name=>'DATE1',
                                  p_value=> to_char(p_date1,wf_core.canonical_date_mask),
                                  p_parameterlist=>l_parameterlist);


    wf_event.AddParameterToList( p_name=>'DATE2',
                                  p_value=> to_char(p_date2,wf_core.canonical_date_mask),
                                  p_parameterlist=>l_parameterlist);


    wf_event.AddParameterToList( p_name=>'DATE3',
                                     p_value=> to_char(p_date3,wf_core.canonical_date_mask),
                                     p_parameterlist=>l_parameterlist);

     wf_event.AddParameterToList( p_name=>'DATE4',
                                  p_value=> to_char(p_date4,wf_core.canonical_date_mask),
                                  p_parameterlist=>l_parameterlist);


        wf_event.AddParameterToList( p_name=>'DATE5',
                                     p_value=> to_char(p_date5,wf_core.canonical_date_mask),
                                     p_parameterlist=>l_parameterlist);

      wf_event.AddParameterToList( p_name=>'ORDER_CREATION_DATE1',
                                     p_value=> to_char(p_order_creation_date1,wf_core.canonical_date_mask),
                                     p_parameterlist=>l_parameterlist);


      wf_event.AddParameterToList( p_name=>'ORDER_CREATION_DATE2',
                                     p_value=> to_char(p_order_creation_date2,wf_core.canonical_date_mask),
                                     p_parameterlist=>l_parameterlist);

      wf_event.AddParameterToList( p_name=>'ORDER_NUMBER',
                                     p_value=> p_order_number,
                                     p_parameterlist=>l_parameterlist);

      wf_event.AddParameterToList( p_name=>'RELEASE_NUMBER',
                                     p_value=> p_release_number,
                                     p_parameterlist=>l_parameterlist);


      wf_event.AddParameterToList( p_name=>'LINE_NUMBER',
                                     p_value=> p_line_number,
                                     p_parameterlist=>l_parameterlist);


       wf_event.AddParameterToList( p_name=>'END_ORDER_NUMBER',
                                     p_value=> p_end_order_number,
                                     p_parameterlist=>l_parameterlist);



        wf_event.AddParameterToList( p_name=>'END_ORDER_REL_NUMBER',
                                     p_value=> p_end_order_rel_number,
                                     p_parameterlist=>l_parameterlist);


      wf_event.AddParameterToList( p_name=>'END_ORDER_LINE_NUMBER',
                                     p_value=> p_end_order_line_number,
                                     p_parameterlist=>l_parameterlist);

        wf_event.AddParameterToList( p_name=>'EXCEPTION_BASIS',
                                     p_value=> p_exception_basis,
                                     p_parameterlist=>l_parameterlist);

   wf_event.raise(p_event_name => l_event_name,
                            p_event_key => l_xml_event_key,
                            p_parameters => l_parameterlist
                            );


EXCEPTION
   when others then
      wf_core.context('msc_wfnotify_pub', 'wfStart',
                    p_wf_type, p_wf_key);
    raise;

END wfStart;

----------------------------------------------------------------------
-- GETMESSGAE
---------------------------------------------------------------------
FUNCTION getMessage(p_exception_code in Number) RETURN Varchar2 IS
    l_message   Varchar2(100);
BEGIN

    if p_exception_code = 1 then
        l_message := 'MSG_EXCEP_1';
    elsif p_exception_code = 2 then
        l_message := 'MSG_EXCEP_2';
    elsif p_exception_code = 3 then
        l_message := 'MSG_EXCEP_3';
    elsif p_exception_code = 4 then
        l_message := 'MSG_EXCEP_4';
    elsif p_exception_code = 5 then
        l_message := 'MSG_EXCEP_5';
    elsif p_exception_code = 6 then
        l_message := 'MSG_EXCEP_6';
    elsif p_exception_code = 7 then
        l_message := 'MSG_EXCEP_7';
    elsif p_exception_code = 8 then
        l_message := 'MSG_EXCEP_8';
    elsif p_exception_code = 9 then
        l_message := 'MSG_EXCEP_9';
    elsif p_exception_code = 10 then
        l_message := 'MSG_EXCEP_10';
    elsif p_exception_code = 11 then
        l_message := 'MSG_EXCEP_11';
    elsif p_exception_code = 12 then
        l_message := 'MSG_EXCEP_12';
    elsif p_exception_code = 13 then
        l_message := 'MSG_EXCEP_13';
    elsif p_exception_code = 14 then
        l_message := 'MSG_EXCEP_14';
    elsif p_exception_code = 15 then
        l_message := 'MSG_EXCEP_15';
    elsif p_exception_code = 16 then
        l_message := 'MSG_EXCEP_16';         -- will not have excep17 and 18
    elsif p_exception_code = 19 then
        l_message := 'MSG_EXCEP_19';
    elsif p_exception_code = 20 then
        l_message := 'MSG_EXCEP_20';
    elsif p_exception_code = 21 then
        l_message := 'MSG_EXCEP_21';
    elsif p_exception_code = 22 then
        l_message := 'MSG_EXCEP_22';
    elsif p_exception_code = 23 then
        l_message := 'MSG_EXCEP_23';
    elsif p_exception_code = 24 then
        l_message := 'MSG_EXCEP_24';
    elsif p_exception_code = 25 then
        l_message := 'MSG_EXCEP_25';
    elsif p_exception_code = 26 then
        l_message := 'MSG_EXCEP_26';
    elsif p_exception_code = 27 then
        l_message := 'MSG_EXCEP_27';
    elsif p_exception_code = 28 then
        l_message := 'MSG_EXCEP_28';
    elsif p_exception_code = 29 then
        l_message := 'MSG_EXCEP_29';
    elsif p_exception_code = 30 then
        l_message := 'MSG_EXCEP_30';
    elsif p_exception_code = 31 then
        l_message := 'MSG_EXCEP_31';
    elsif p_exception_code = 32 then
        l_message := 'MSG_EXCEP_32';
    elsif p_exception_code = 33 then
        l_message := 'MSG_EXCEP_33';
    elsif p_exception_code = 34 then
        l_message := 'MSG_EXCEP_34';
    elsif p_exception_code = 35 then
        l_message := 'MSG_EXCEP_35';
    elsif p_exception_code = 36 then
        l_message := 'MSG_EXCEP_36';
    elsif p_exception_code = 39 then
        l_message := 'MSG_EXCEP_39';
    elsif p_exception_code = 40 then
        l_message := 'MSG_EXCEP_40';
    elsif p_exception_code = 43 then
        l_message := 'MSG_EXCEP_43';
    elsif p_exception_code = 44 then
        l_message := 'MSG_EXCEP_44';
    elsif p_exception_code = 45 then
        l_message := 'MSG_EXCEP_45';
    elsif p_exception_code = 46 then
        l_message := 'MSG_EXCEP_46';
    elsif p_exception_code = 47 then
        l_message := 'MSG_EXCEP_47';
    elsif p_exception_code = 48 then
        l_message := 'MSG_EXCEP_48';
    elsif p_exception_code = 49 then
        l_message := 'MSG_EXCEP_49';
    elsif p_exception_code = 50 then
    	l_message := 'MSG_EXCEP_50';
    elsif p_exception_code = 51 then
    	l_message := 'MSG_EXCEP_51';
    end if;
   return l_message;
EXCEPTION
   WHEN others then
      l_message := null;
      null;
END getMessage;

/*------------------------------------------------------
  send publish notifications
  -----------------------------------------------------*/
PROCEDURE Launch_Publish_WF (p_errbuf OUT NOCOPY Varchar2,
                        p_retcode 		OUT NOCOPY Number,
                        p_designator 		IN Varchar2,
                        p_version  		In Number,
                        p_horizon_start 	IN date,
                        p_horizon_end		IN date,
                        p_plan_id		IN Number,
                        p_sr_instance_id 	IN Number,
                        p_org_id		IN Number,
                        p_item_id		IN Number,
                        p_supplier_id		IN Number,
                        p_supplier_site_id	IN Number,
                        p_customer_id		IN Number,
                        p_customer_site_id	IN Number,
  			p_planner_code          IN Varchar2,
  			p_abc_class             IN Varchar2,
  			p_planning_gp           IN Varchar2,
  			p_project_id            IN Number,
  			p_task_id               IN Number,
  			p_publish_program_type	IN Number) IS


CURSOR wf_publish_of_notify_c ( p_designator 	IN Varchar2,
                        p_version  		In Number,
                        p_horizon_start 	IN date,
                        p_horizon_end 		IN date,
                        p_plan_id		IN Number,
                        p_sr_instance_id 	IN Number,
                        p_org_id		IN Number,
                        p_item_id		IN Number,
                        p_supplier_id		IN Number,
                        p_supplier_site_id	IN Number,
  			p_planner_code          IN Varchar2,
  			p_abc_class             IN Varchar2,
  			p_planning_gp           IN Varchar2,
  			p_project_id            IN Number,
  			p_task_id               IN Number,
                        p_publish_program_type	In Number) IS

SELECT  distinct sd.publisher_id,
	sd.publisher_name,
	sd.publisher_site_id,
	sd.publisher_site_name,
	sd.supplier_id,
	sd.supplier_name,
	sd.supplier_site_id,
	sd.supplier_site_name,
	sd.customer_id,
	sd.customer_name,
	sd.customer_site_id,
	sd.customer_site_name
FROM	msc_sup_dem_entries sd
WHERE   sd.publisher_order_type = p_publish_program_type and
        sd.plan_id = -1 and
        sd.publisher_id = 1 and
        exists  (select cs.company_site_id
                                        from   msc_plan_organizations o,
                                               msc_company_sites cs,
                                               msc_trading_partner_maps m,
                                               msc_trading_partners p
                                        where  o.plan_id = p_plan_id
					       AND O.ORGANIZATION_ID = NVL(p_org_id , O.ORGANIZATION_ID)
					       AND O.SR_INSTANCE_ID = NVL(p_sr_instance_id , O.SR_INSTANCE_ID)
					       AND P.SR_TP_ID = O.ORGANIZATION_ID
					       AND P.SR_INSTANCE_ID = O.SR_INSTANCE_ID and
                                               p.partner_type = 3 and
                                               m.tp_key = p.partner_id and
                                               m.map_type = 2 and
                                               cs.company_site_id = m.company_key and
                                               cs.company_id = 1
					       and sd.publisher_site_id =cs.company_site_id and rownum=1)  and
        exists (select  c.company_id
          			from   	msc_companies c,
                 			msc_trading_partner_maps m,
                 			msc_company_relationships r
          			where  m.tp_key = nvl(p_supplier_id, m.tp_key) and
                 		m.map_type = 1 and
                		r.relationship_id = m.company_key and
                		r.subject_id = 1 and
                		r.relationship_type = 2 and
                 		c.company_id = r.object_id and
				sd.supplier_id =c.company_id and rownum=1) and
        exists (select s.company_site_id
          			from   msc_company_sites s,
                 		msc_trading_partner_maps m
          			where  m.tp_key = nvl(p_supplier_site_id, m.tp_key) and
                 		m.map_type = 3 and
                 		s.company_site_id = m.company_key and
                 		s.company_id = sd.supplier_id and
				sd.supplier_site_id=s.company_site_id and rownum=1) and
         exists (select nvl(i.base_item_id,i.inventory_item_id)
                                      from   msc_system_items i,
                                             msc_plan_organizations o
                                      where  o.plan_id = p_plan_id and
                                             i.plan_id = o.plan_id
					     AND O.ORGANIZATION_ID = NVL(p_org_id , O.ORGANIZATION_ID)
					     AND O.SR_INSTANCE_ID =NVL(p_sr_instance_id , O.SR_INSTANCE_ID)
					     AND I.ORGANIZATION_ID = O.ORGANIZATION_ID
					     AND I.SR_INSTANCE_ID = O.SR_INSTANCE_ID and
                                             NVL(i.planner_code,'-99') = NVL(p_planner_code,
                                                                 NVL(i.planner_code,'-99')) and
                                             NVL(i.abc_class_name,'-99') = NVL(p_abc_class,
                                                                 NVL(i.abc_class_name,'-99')) and
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id)
					    and NVL(sd.base_item_id, sd.inventory_item_id) = nvl(i.base_item_id,i.inventory_item_id)
					    and rownum=1)  and
        NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and
        NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
        NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
        NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99')) and
       	sd.designator = p_designator and
       	sd.version = p_version and
    	key_date between nvl(p_horizon_start, sysdate - 36500) and
        nvl(p_horizon_end, sysdate + 36500);


/*---------------------------------------------------------------
  Publish order forecast
  ---------------------------------------------------------------*/
CURSOR wf_publish_of_item_c ( p_designator 	IN Varchar2,
                        p_version  		In Number,
                        p_horizon_start 	IN date,
                        p_horizon_end 		IN date,
                        p_plan_id		IN Number,
                        p_sr_instance_id 	IN Number,
                        p_org_id		IN Number,
                        p_company_id		IN Number,
                        p_company_site_id	IN Number,
                        p_tp_company_id		IN Number,
                        p_tp_company_site_id	IN Number,
                        p_item_id		IN Number) IS

SELECT  distinct sd.inventory_item_id,
	sd.item_name,
	sd.item_description
FROM	msc_sup_dem_entries sd
WHERE   sd.publisher_order_type = 2 and
        sd.plan_id = -1 and
        sd.publisher_id = p_company_id and
        sd.publisher_site_id = p_company_site_id and
        sd.supplier_id = p_tp_company_id and
        sd.supplier_site_id = p_tp_company_site_id and
       	sd.designator = p_designator and
       	sd.version = p_version and
       	sd.inventory_item_id = nvl(p_item_id, sd.inventory_item_id) and
    	key_date between nvl(p_horizon_start, sysdate - 36500) and
           	nvl(p_horizon_end, sysdate + 36500);


/*------------------------------------------------------------------------
 publish supply commit
 ------------------------------------------------------------------------*/
CURSOR wf_publish_sc_notify_c ( p_designator 	IN Varchar2,
                        p_version  		In Number,
                        p_horizon_start 	IN date,
                        p_horizon_end 		IN date,
                        p_plan_id		IN Number,
                        p_sr_instance_id 	IN Number,
                        p_org_id		IN Number,
                        p_item_id		IN Number,
                        p_customer_id		IN Number,
                        p_customer_site_id	IN Number,
  			p_planner_code          IN Varchar2,
  			p_abc_class             IN Varchar2,
  			p_planning_gp           IN Varchar2,
  			p_project_id            IN Number,
  			p_task_id               IN Number,
                        p_publish_program_type	In Number) IS

SELECT  distinct sd.publisher_id,
	sd.publisher_name,
	sd.publisher_site_id,
	sd.publisher_site_name,
	sd.supplier_id,
	sd.supplier_name,
	sd.supplier_site_id,
	sd.supplier_site_name,
	sd.customer_id,
	sd.customer_name,
	sd.customer_site_id,
	sd.customer_site_name
FROM	msc_sup_dem_entries sd
WHERE   sd.publisher_order_type = p_publish_program_type and
        sd.plan_id = -1 and
        sd.publisher_id = 1 and
        sd.publisher_site_id IN (select cs.company_site_id
                                        from   msc_plan_organizations o,
                                               msc_company_sites cs,
                                               msc_trading_partner_maps m,
                                               msc_trading_partners p
                                        where  o.plan_id = p_plan_id and
                                               p.sr_tp_id = nvl(p_org_id, o.organization_id) and
                                               p.sr_instance_id = nvl(p_sr_instance_id,
                                                                      o.sr_instance_id) and
                                               p.partner_type = 3 and
                                               m.tp_key = p.partner_id and
                                               m.map_type = 2 and
                                               cs.company_site_id = m.company_key and
                                               cs.company_id = 1)  and
        sd.customer_id IN (select distinct c.company_id
          			from   	msc_companies c,
                 			msc_trading_partner_maps m,
                 			msc_company_relationships r
          			where  m.tp_key = nvl(p_customer_id, m.tp_key) and
                 		m.map_type = 1 and
                		r.relationship_id = m.company_key and
                		r.subject_id = 1 and
                		r.relationship_type = 1 and
                 		c.company_id = r.object_id) and
        sd.customer_site_id  IN (select s.company_site_id
          			from   msc_company_sites s,
                 		msc_trading_partner_maps m
          			where  m.tp_key = nvl(p_customer_site_id, m.tp_key) and
                 		m.map_type = 3 and
                 		s.company_site_id = m.company_key and
                 		s.company_id = sd.customer_id) and
         NVL(sd.base_item_id, sd.inventory_item_id) IN (select nvl(i.base_item_id,i.inventory_item_id)
                                      from   msc_system_items i,
                                             msc_plan_organizations o
                                      where  o.plan_id = p_plan_id and
                                             i.plan_id = o.plan_id and
                                             i.organization_id = nvl(p_org_id,
                                                                 o.organization_id) and
                                             i.sr_instance_id = nvl(p_sr_instance_id,
                                                                 o.sr_instance_id) and
                                             NVL(i.planner_code,'-99') = NVL(p_planner_code,
                                                                 NVL(i.planner_code,'-99')) and
                                             NVL(i.abc_class_name,'-99') = NVL(p_abc_class,
                                                                 NVL(i.abc_class_name,'-99')) and
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id))  and
        NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and
        NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
        NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
        NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99')) and
       	sd.designator = p_designator and
       	sd.version = p_version and
    	key_date between nvl(p_horizon_start, sysdate - 36500) and
           	nvl(p_horizon_end, sysdate + 36500);


 CURSOR wf_publish_sc_item_c ( p_designator 	IN Varchar2,
                         p_version  		In Number,
                         p_horizon_start 	IN date,
                         p_horizon_end 		IN date,
                         p_plan_id		IN Number,
                         p_sr_instance_id 	IN Number,
                         p_org_id		IN Number,
                         p_company_id		IN Number,
                         p_company_site_id	IN Number,
                         p_tp_company_id	IN Number,
                         p_tp_company_site_id	IN Number,
                         p_item_id		IN Number) IS

 SELECT  distinct sd.inventory_item_id,
 	sd.item_name,
 	sd.item_description
 FROM	msc_sup_dem_entries sd
 WHERE   sd.publisher_order_type = 3 and
         sd.plan_id = -1 and
         sd.publisher_id = p_company_id and
         sd.publisher_site_id = p_company_site_id and
         sd.customer_id = p_tp_company_id and
         sd.customer_site_id = p_tp_company_site_id and
        	sd.designator = p_designator and
        	sd.version = p_version and
        sd.inventory_item_id = nvl(p_item_id, sd.inventory_item_id) and
     	key_date between nvl(p_horizon_start, sysdate - 36500) and
            	nvl(p_horizon_end, sysdate + 36500);




/*-------------------------------------------------------------------
 get the receipient user name
 --------------------------------------------------------------------*/

CURSOR partner_con_by_site_c(p_company_id in number,
      			p_company_site_id in Number) IS
SELECT   distinct con.name
FROM  	msc_trading_partner_maps map,
   	msc_company_sites site,
   	msc_partner_contacts con
WHERE    map.map_type = 3
AND   	map.company_key = site.company_site_id
AND   	map.tp_key = con.partner_site_id
AND   	site.company_id = p_company_id
AND   	site.company_site_id = p_company_site_id;


/*
SELECT   distinct con.name
FROM  	msc_trading_partner_maps map,
   	msc_company_sites site,
   	msc_partner_contacts con,
   	msc_trading_partner_sites tps
WHERE    map.map_type = 3
AND   map.company_key = site.company_site_id
AND   map.tp_key = tps.partner_site_id
AND   tps.partner_site_id = con.partner_site_id
AND   tps.sr_instance_id = con.sr_instance_id
AND   site.company_id = p_company_id
AND   site.company_site_id = p_company_site_id;

*/

l_wf_type 		Varchar2(100);
l_wf_key  		Varchar2(100);
l_wf_process        	Varchar2(200);
l_user_id      		Number;
l_user_performer  	Varchar2(240);
l_real_name       	Varchar2(240);
l_item_name		Varchar2(4000);
l_item_desc		Varchar2(4000);


t_company_id   		number_arr;
t_company_site_id 	number_arr;
t_item_id  		number_arr;
t_supplier_id 		number_arr;
t_supplier_site_id 	number_arr;
t_customer_id 		number_arr;
t_customer_site_id 	number_arr;

t_company_name 		msc_x_netting_pkg.publisherList;
t_company_site_name 	msc_x_netting_pkg.pubsiteList;
t_item_name 		msc_x_netting_pkg.itemnameList;
t_item_desc		msc_x_netting_pkg.itemdescList;
t_supplier_name 	msc_x_netting_pkg.publisherList;
t_supplier_site_name 	msc_x_netting_pkg.pubsiteList;
t_customer_name 	msc_x_netting_pkg.publisherList;
t_customer_site_name 	msc_x_netting_pkg.pubsiteList;
t_version		number_arr;
t_designator		designatorList;


l_next_number		Number;

l_event_name   		varchar2(100);
l_xml_event_key   	varchar2(100);
l_parameterlist   	wf_parameter_list_t;


BEGIN

t_company_id   		:= number_arr();
t_company_site_id 	:= number_arr();
t_item_id  		:= number_arr();
t_supplier_id 		:= number_arr();
t_supplier_site_id 	:= number_arr();
t_customer_id 		:= number_arr();
t_customer_site_id 	:= number_arr();
t_version		:= number_arr();
l_event_name   		:= 'oracle.apps.msc.notification';
l_parameterlist   	:= wf_parameter_list_t();
l_wf_type 		:= 'MSCPUB';
l_wf_process        	:= 'MSC_PUB_NOTIFY';



select msc_cl_refresh_s.nextval into l_next_number from dual;
IF (p_publish_program_type = G_ORDER_FORECAST) THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Launch order forecast notification');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Designator ' || p_designator || ' version ' || p_version);

  open wf_publish_of_notify_c( p_designator,
                        p_version,
                        p_horizon_start,
                        p_horizon_end,
                        p_plan_id,
                        p_sr_instance_id,
                        p_org_id,
                        p_item_id,
                        p_supplier_id,
                        p_supplier_site_id,
  			p_planner_code,
  			p_abc_class,
  			p_planning_gp,
  			p_project_id,
  			p_task_id,
                        p_publish_program_type);

  FETCH wf_publish_of_notify_c BULK COLLECT INTO
      	t_company_id,
      	t_company_name,
      	t_company_site_id,
      	t_company_site_name,
      	t_supplier_id,
      	t_supplier_name,
      	t_supplier_site_id,
      	t_supplier_site_name,
      	t_customer_id,
      	t_customer_name,
      	t_customer_site_id,
      	t_customer_site_name;

   CLOSE wf_publish_of_notify_c;

FND_FILE.PUT_LINE(FND_FILE.LOG,'WF OF record fetched:= ' || t_company_id.COUNT);
   --dbms_output.put_line('wf count ' || t_company_id.COUNT);
   IF (t_company_id is not null and t_company_id.COUNT > 0) THEN

      	FOR j in 1 .. t_company_id.COUNT
      	LOOP
      	FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: Loop supp ' || t_supplier_id(j) || ' sup site ' || t_supplier_site_id(j));
	--dbms_output.put_line('Loop sup company ' || t_supplier_id(j) || ' sup site ' || t_supplier_site_id(j));
		/*--------------------------------------------------------------------
		append item
		--------------------------------------------------------------------*/
		open wf_publish_of_item_c( p_designator,
                        p_version,
                        p_horizon_start,
                        p_horizon_end,
                        p_plan_id,
                        p_sr_instance_id,
                        p_org_id,
                        t_company_id(j),
                        t_company_site_id(j),
                        t_supplier_id(j),
                        t_supplier_site_id(j),
                        p_item_id);

      		FETCH wf_publish_of_item_c BULK COLLECT INTO
      			t_item_id,
      			t_item_name,
      			t_item_desc;
      		CLOSE wf_publish_of_item_c;

		l_item_name := null;
		l_item_desc := null;

		FOR k in 1 .. t_item_id.COUNT LOOP
		   IF (t_item_id.COUNT = 1 or k = t_item_id.COUNT) THEN
			l_item_name :=  substr((l_item_name ||  t_item_name(k)),1,1000);
		   ELSIF (k = t_item_id.COUNT) THEN
			l_item_name :=  substr((l_item_name ||  t_item_name(k)),1,1000);
		   ELSE
			l_item_name :=  substr((l_item_name ||  t_item_name(k) || ','),1,1000);
		   END IF;
		END LOOP;



      		open partner_con_by_site_c(t_supplier_id(j),
                        	t_supplier_site_id(j));

               	loop
                  	fetch partner_con_by_site_c into l_user_performer;
                  	exit when partner_con_by_site_c%NOTFOUND;

  			--dbms_output.put_line('user performer ' || l_user_performer);

                  IF (l_user_performer is not null) THEN

                     	l_wf_key := 'OF' ||
                     		to_char(t_supplier_id(j)) || '-' ||
                              	to_char(t_supplier_site_id(j)) || '-' ||
                              	to_char(t_company_id(j)) || '-' ||
                              	to_char(t_company_site_id(j)) || '-' ||
                           	l_user_performer ||
                           	to_char(l_next_number) ;
              		 begin

      				SELECT substr(display_name,instr(display_name,',')+ 1) || ' ' ||
      				substr(display_name,1, instr(display_name,',') -1)
       				INTO	l_real_name
       				FROM 	wf_users
 				WHERE 	name = l_user_performer;
               		exception
               			when others then
               			l_real_name := null;
               		end;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: user ' || l_real_name);
        /**
	    dbms_output.put_line('start workflow process');
	    dbms_output.put_line('user ' || l_real_name);
	    dbms_output.put_line('company ' || t_company_name(j));
	    dbms_output.put_line('company site ' || t_company_site_name(j));
	    dbms_output.put_line('version' || p_version);
	    dbms_output.put_line('designator ' || p_designator);
	   -- dbms_output.put_line('item  ' || l_item_name);
	   **/

	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sending notification ');


	        	-- create a Workflow process for the (item/org/supplier)
	        	wf_engine.CreateProcess
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, process  => l_wf_process
	        	);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'FORWARD_TO_USERNAME'
	        	, avalue   => l_user_performer
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'MESSAGE_NAME'
	        	, avalue   => 'PUBLISH_ORDER_FORECAST'
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'COMPANY_NAME'
	        	, avalue   => t_company_name(j)
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'COMPANY_SITE_NAME'
	        	, avalue   => t_company_site_name(j)
    			);

	        	wf_engine.SetItemAttrNumber
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'VERSION'
	        	, avalue   => p_version
    			);

   			wf_engine.SetItemAttrText
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			, aname    => 'DESIGNATOR'
    			, avalue   => p_designator
    			);

   			wf_engine.SetItemAttrText
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			, aname    => 'ITEM_NAME'
    			, avalue   => l_item_name
    			);

   			-- start Workflow process for item/org/supplier
    			wf_engine.StartProcess
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			);


             	END IF;


          end loop;
          close partner_con_by_site_c;

 	END LOOP;
   END IF;

/*----------------------------------------------------------------------
  SUPPLY COMMIT;
  -----------------------------------------------------------------------*/
ELSIF (p_publish_program_type = G_SUPPLY_COMMIT) THEN
 open wf_publish_sc_notify_c( p_designator,
                        p_version,
                        p_horizon_start,
                        p_horizon_end,
                        p_plan_id,
                        p_sr_instance_id,
                        p_org_id,
                        p_item_id,
                        p_customer_id,
                        p_customer_site_id,
  			p_planner_code,
  			p_abc_class,
  			p_planning_gp,
  			p_project_id,
  			p_task_id,
                        p_publish_program_type);

      FETCH wf_publish_sc_notify_c BULK COLLECT INTO
      	t_company_id,
      	t_company_name,
      	t_company_site_id,
      	t_company_site_name,
      	t_supplier_id,
      	t_supplier_name,
      	t_supplier_site_id,
      	t_supplier_site_name,
      	t_customer_id,
      	t_customer_name,
      	t_customer_site_id,
      	t_customer_site_name;

      CLOSE wf_publish_sc_notify_c;

FND_FILE.PUT_LINE(FND_FILE.LOG,'WF SC record fetched:= ' || t_company_id.COUNT);
--dbms_output.put_line('wf count ' || t_company_id.COUNT);
IF (t_company_id is not null and t_company_id.COUNT > 0) THEN

      	FOR j in 1 .. t_company_id.COUNT
      	LOOP
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'WF: Loop cust ' || t_customer_id(j) || ' cust site ' || t_customer_site_id(j));
	--dbms_output.put_line('Loop cust company ' || t_customer_id(j) || ' cust site ' || t_customer_site_id(j));
		/*--------------------------------------------------------------------
		append item
		--------------------------------------------------------------------*/
		open wf_publish_sc_item_c( p_designator,
                        p_version,
                        p_horizon_start,
                        p_horizon_end,
                        p_plan_id,
                        p_sr_instance_id,
                        p_org_id,
                        t_company_id(j),
                        t_company_site_id(j),
                        t_customer_id(j),
                        t_customer_site_id(j),
                        p_item_id);

      		FETCH wf_publish_sc_item_c BULK COLLECT INTO
      			t_item_id,
      			t_item_name,
      			t_item_desc;
      		CLOSE wf_publish_sc_item_c;

		l_item_name := null;
		l_item_desc := null;

		FOR k in 1 .. t_item_id.COUNT LOOP
		   IF (t_item_id.COUNT = 1 or k = t_item_id.COUNT) THEN
			l_item_name :=  substr((l_item_name ||  t_item_name(k)),1,1000);
		   ELSIF (k = t_item_id.COUNT) THEN
			l_item_name :=  substr((l_item_name ||  t_item_name(k)),1,1000);
		   ELSE
			l_item_name :=  substr((l_item_name ||  t_item_name(k) || ','),1,1000);
		   END IF;
		END LOOP;



      		open partner_con_by_site_c(t_customer_id(j),
                        	t_customer_site_id(j));

               	loop
                  	fetch partner_con_by_site_c into l_user_performer;
                  	exit when partner_con_by_site_c%NOTFOUND;

  			--dbms_output.put_line('user performer ' || l_user_performer);

                  IF (l_user_performer is not null) THEN

                     	l_wf_key := 'SC' || to_char(t_customer_id(j)) || '-' ||
                              	to_char(t_customer_site_id(j)) || '-' ||
                              	to_char(t_company_id(j)) || '-' ||
                              	to_char(t_company_site_id(j)) || '-' ||
                           	l_user_performer ||
                           	to_char(l_next_number) ;
              		 begin

      				SELECT substr(display_name,instr(display_name,',')+ 1) || ' ' ||
      				substr(display_name,1, instr(display_name,',') -1)
       				INTO	l_real_name
       				FROM 	wf_users
 				WHERE 	name = l_user_performer;
               		exception
               			when others then
               			l_real_name := null;
               		end;

FND_FILE.PUT_LINE(FND_FILE.LOG,'WF: user ' || l_real_name);
        /*
	    dbms_output.put_line('start workflow process');
	    dbms_output.put_line('user ' || l_real_name);
	    dbms_output.put_line('company ' || t_company_name(j));
	    dbms_output.put_line('company site ' || t_company_site_name(j));
	    dbms_output.put_line('version' || p_version);
	    dbms_output.put_line('designator ' || p_designator);
	   -- dbms_output.put_line('item  ' || l_item_name);
	 */
	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sending notification ');


	        	-- create a Workflow process for the (item/org/supplier)
	        	wf_engine.CreateProcess
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, process  => l_wf_process
	        	);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'FORWARD_TO_USERNAME'
	        	, avalue   => l_user_performer
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'MESSAGE_NAME'
	        	, avalue   => 'PUBLISH_SUPPLY_COMMIT'
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'COMPANY_NAME'
	        	, avalue   => t_company_name(j)
    			);

	        	wf_engine.SetItemAttrText
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'COMPANY_SITE_NAME'
	        	, avalue   => t_company_site_name(j)
    			);

	        	wf_engine.SetItemAttrNumber
	        	( itemtype => l_wf_type
	        	, itemkey  => l_wf_key
	        	, aname    => 'VERSION'
	        	, avalue   => p_version
    			);

   			wf_engine.SetItemAttrText
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			, aname    => 'DESIGNATOR'
    			, avalue   => p_designator
    			);

   			wf_engine.SetItemAttrText
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			, aname    => 'ITEM_NAME'
    			, avalue   => l_item_name
    			);

   			-- start Workflow process for item/org/supplier
    			wf_engine.StartProcess
    			( itemtype => l_wf_type
    			, itemkey  => l_wf_key
    			);


             	END IF;


          end loop;
          close partner_con_by_site_c;

 	END LOOP;
   END IF;

END IF;

EXCEPTION
   when others then
      wf_core.context('msc_wfnotify_pub', 'wfStart',
                    l_wf_type, l_wf_key);

	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in msc_x_wfnotify_pkg.Launch_Publish_WF ' || sqlerrm);
    raise;

END Launch_Publish_WF;

END msc_x_wfnotify_pkg;

/
