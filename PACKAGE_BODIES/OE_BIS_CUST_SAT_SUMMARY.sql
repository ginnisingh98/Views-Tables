--------------------------------------------------------
--  DDL for Package Body OE_BIS_CUST_SAT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BIS_CUST_SAT_SUMMARY" AS
/*$Header: OEXBCSSB.pls 115.4 99/08/18 09:51:38 porting ship  $*/

g_userid 	NUMBER;
g_applicationid NUMBER;
g_debug		NUMBER := 0 ;
g_date_from DATE ;
g_date_to   DATE;
g_uom_code	VARCHAR2(10);


/* OE Contants  */

Procedure Load_Summary_Info IS
	x_errnum 	NUMBER;
	x_errmesg	VARCHAR2(240);
	errbuf 	VARCHAR2(240);
	retcode	VARCHAR2(240);
begin
	Populate_Summary_Table(x_errnum, x_errmesg);

	errbuf := x_errmesg ;
	retcode := to_char(x_errnum);

end Load_Summary_Info ;


Procedure Load_Summary_Info2 IS
	x_errnum 	NUMBER;
	x_errmesg	VARCHAR2(240);
	errbuf 	VARCHAR2(240);
	retcode	VARCHAR2(240);
begin
	Populate_Summary_Table2(x_errnum, x_errmesg);

	errbuf := x_errmesg ;
	retcode := to_char(x_errnum);

end Load_Summary_Info2;


Procedure Populate_Summary_Table(x_errnum  OUT NUMBER,
                                 x_errmesg OUT VARCHAR2)
/*                        p_ORGANIZATION_ID          IN  NUMBER,
                        p_INVENTORY_ITEM_ID   IN  NUMBER,
                        p_CUSTOMER_ID         IN  DATE,
                        p_TRANSACTION_DATE           IN  DATE,
                        p_DELIVERY_PERCENT     IN  NUMBER,
                        p_RETURN_PERCENT       IN  NUMBER,
                        p_NET_SALES            IN  NUMBER,
                        p_LAST_UPDATE_DATE     IN  NUMBER,
                        p_LAST_UPDATED_BY      IN NUMBER,
                        p_CREATION_DATE        IN VARCHAR2
                        p_CREATED_BY           IN   NUMBER
                        p_LAST_UPDATE_LOGIN    IN  NUMBER,
                        p_REQUEST_ID           IN  NUMBER,
                        p_PROGRAM_APPLICATION_ID IN NUMBER,
                        p_PROGRAM_ID             IN  NUMBER,
                        p_PROGRAM_UPDATE_DATE    IN  NUMBER */

IS
/* Local variables */
 x_temp varchar2(10);
 x_user_id   NUMBER := fnd_global.user_id;
 x_login_id  NUMBER := fnd_global.login_id;
 x_req_id    NUMBER := fnd_global.CONC_REQUEST_ID;
 x_prog_appl_id   NUMBER := fnd_global.PROG_APPL_ID;
 x_prog_id   NUMBER := fnd_global.CONC_PROGRAM_ID;
 app_col_name 	varchar2(100);

BEGIN

/*
ORGANIZATION_ID         Dimension 1                     NUMBER
INVENTORY_ITEM_ID       Dimension 2     NOT NULL        NUMBER
CUSTOMER_ID             Dimension 3                     NUMBER
TRANSACTION_DATE        Dimension 4     NOT NULL        DATE
DELIVERY_PERCENT        Measure 1                       NUMBER
RETURN_PERCENT          Measure 2                       NUMBER
NET_SALES               Measure 3                       NUMBER
LAST_UPDATE_DATE        Who Column      NOT NULL        DATE
LAST_UPDATED_BY         Who Column      NOT NULL        NUMBER
CREATION_DATE           Who Column      NOT NULL        DATE
CREATED_BY              Who Column      NOT NULL        NUMBER
LAST_UPDATE_LOGIN       Who Column                      NUMBER
REQUEST_ID              Who Column                      NUMBER
PROGRAM_APPLICATION_ID  Who Column                      NUMBER(15)
PROGRAM_ID              Who Column                      NUMBER(15)
PROGRAM_UPDATE_DATE     Who Column                      NUMBER(15)
*/


insert into oe_bis_cust_sat_t (
                                      ORGANIZATION_ID,
                                      INVENTORY_ITEM_ID,
                                      CUSTOMER_ID,
                                      TRANSACTION_DATE,
                                      DEL_flag,
                                      RETURN_flag,
                                      NET_SALES,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      REQUEST_ID,
                                      PROGRAM_APPLICATION_ID,
                                      PROGRAM_ID,
                                      PROGRAM_UPDATE_DATE,
                                      HEADER_ID,
                                      LINE_ID )
select sla.org_id,
      sla.inventory_item_id,
      sha.customer_id,
      nvl(sla.promise_date, sha.date_ordered),
      decode(sla.line_type_code, 'RETURN', NULL,decode(trunc(sla.promise_date),
             trunc(wd.date_closed), 'Y','N')) del_flag,
      NULL return_flag,
      decode(sla.line_type_code, 'RETURN',0,nvl(sla.selling_price,0) *
                (nvl(sla.ordered_quantity,0) - nvl(sla.cancelled_quantity,0))) net_sales,
      sysdate,      -- Last Update Date
      x_user_id,
      sysdate,      -- Creation Date
      x_user_id,
      x_login_id,
      x_req_id,
      x_prog_appl_id,
      x_prog_id,
      sysdate,      -- Program Update Date
      sha.header_id,
      sla.line_id
 from
      so_headers_all sha,
      so_lines_all sla,
      wsh_departures wd,
      so_picking_lines_all spla,
      so_picking_line_details spld
where sha.header_id = sla.header_id
  and sla.line_id = spla.order_line_id
  and spla.picking_line_id = spld.picking_line_id
  and spld.picking_line_detail_id in                 -- New
                    (select min(spld1.picking_line_detail_id)
                       from so_picking_line_details spld1
                      where spla.picking_line_id = spld1.picking_line_id)
  and spld.departure_id = wd.departure_id
  and (    sla.promise_date is not null
       or sla.schedule_date is not null );


/* FOR RETURNS */

insert into oe_bis_cust_sat_t (
                                      ORGANIZATION_ID,
                                      INVENTORY_ITEM_ID,
                                      CUSTOMER_ID,
                                      TRANSACTION_DATE,
                                      DEL_flag,
                                      RETURN_flag,
                                      NET_SALES,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      REQUEST_ID,
                                      PROGRAM_APPLICATION_ID,
                                      PROGRAM_ID,
                                      PROGRAM_UPDATE_DATE,
                                      HEADER_ID,
                                      LINE_ID )
select sla.org_id,
      sla.inventory_item_id,
      sha.customer_id,
      nvl(sla.promise_date, sha.date_ordered),
      NULL del_flag,
      decode(sla.line_type_code, 'RETURN','Y',NULL) return_flag,
      decode(sla.line_type_code, 'RETURN', nvl(sla.selling_price,0) *
               (nvl(sla.ordered_quantity,0) -
                nvl(sla.cancelled_quantity,0)) * -1,nvl(sla.selling_price,0) *
                (nvl(sla.ordered_quantity,0) -
                 nvl(sla.cancelled_quantity,0))) net_sales,
       sysdate,      -- Last Update Date
       x_user_id,
       sysdate,      -- Creation Date
       x_user_id,
       x_login_id,
       x_req_id,
       x_prog_appl_id,
       x_prog_id,
       sysdate,      -- Program Update Date
       sha.header_id,
       sla.line_id
from
      so_headers_all sha,
      so_lines_all sla
where
      sha.header_id = sla.header_id and
      sla.line_type_code = 'RETURN';

 COMMIT;

Exception

        when others then

                if g_debug = 1 then
                        fnd_file.put_line(fnd_file.log, SQLCODE);
                        fnd_file.put_line(fnd_file.log,SQLERRM);
                end if ;
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                x_errnum := -1 ;
                x_errmesg := substr(SQLERRM,1,150);
                commit ;
                return ;


 x_errnum  := 0;
 x_errmesg := 'NOERROR';  -- Replace this with the actual error later


END Populate_Summary_Table;






Procedure Populate_Summary_Table2(x_errnum  OUT NUMBER,
                                 x_errmesg OUT VARCHAR2) IS
/* Local variables */
 x_temp varchar2(10);
 x_user_id   NUMBER := fnd_global.user_id;
 x_login_id  NUMBER := fnd_global.login_id;
 x_req_id    NUMBER := fnd_global.CONC_REQUEST_ID;
 x_prog_appl_id   NUMBER := fnd_global.PROG_APPL_ID;
 x_prog_id   NUMBER := fnd_global.CONC_PROGRAM_ID;
 app_col_name 	varchar2(100);
 sql_stmt varchar2(10000);

BEGIN

/* Populating the second table */

   begin
	select 	'hl.' || application_column_name
	into 	app_col_name
	from 	bis_flex_mappings_v
	where 	flex_field_type = 'D' and
      		flex_field_name = 'Additional Location Details' and
	     	level_id = 127;
   exception
     	when others then
		app_col_name := ' ';
   end;


   if app_col_name = ' ' then

      sql_stmt := 'insert into oe_bis_cust_sat_t2 ( SET_OF_BOOKS_ID,
				SET_OF_BOOKS_NAME,
				LEGAL_ENTITY_ID,
				LEGAL_ENTITY_NAME,
				OPERATING_UNIT_ID,
				OPERATING_UNIT_NAME,
				ORGANIZATION_ID,
				ORGANIZATION_NAME,
				INVENTORY_ITEM_ID,
				CATEGORY_ID,
				CATEGORY_DESC,
				ITEM_DESCRIPTION,
				INVENTORY_ITEM_NAME,
				CUSTOMER_ID,
				SALES_CHANNEL_CODE,
				CUSTOMER_NAME,
				AREA,
				COUNTRY,
				TRANSACTION_DATE,
				DEL_SALES,
				RET_SALES,
				NET_SALES,
				PERIOD_SET_NAME,
				YEAR_PERIOD,
				QUARTER_PERIOD,
				MONTH_PERIOD,
				HEADER_ID,
				LINE_ID,
				LOCATION_ID,
				LOCATION_CODE)
select ood.set_of_books_id,  				-- set_of_books_id,
       gsob.name,  					-- set_of_books_name,
       hle.organization_id, 				-- legal_entity_id,
       hle.name, 					-- legal_entity_name,
       haou.organization_id, 				-- operating_unit_id,
       haou.name, 					-- operating_unit_name,
       obcs.organization_id,
       ood.organization_name,
       obcs.inventory_item_id,
       mc.category_id,
       mc.segment1 || ''.'' || mc.segment2, 		-- as category_desc,
       msi.description, 				-- as item_description,
       mif.item_number, 				-- as inventory_item_name,
       obcs.customer_id,
       nvl(rc.sales_channel_code,''Unspecified''), 	-- sales_channel_code,
       rc.customer_name,
       bth.parent_territory_code, 			-- area,
       hl.country,
       obcs.transaction_date,
       decode(obcs.del_flag,''Y'',obcs.net_sales,0), 			-- del_sales,
       decode(obcs.return_flag,''Y'',(obcs.net_sales) * -1,0),  	-- ret_sales,
       decode(obcs.return_flag, ''Y'',0,obcs.net_sales),  		-- net_sales,
       year.period_set_name,
       year.period_name, 				-- year_period ,
       quarter.period_name, 				-- quarter_period,
       month.period_name, 				-- month_period,
       obcs.header_id, 					-- header_id,
       obcs.line_id, 					-- line_id,
       hl.location_id, 					-- location_id,
       hl.location_code 		      		-- location_code,
from
       gl_periods year,
       gl_periods quarter,
       gl_periods month,
       gl_sets_of_books gsob,
       oe_bis_cust_sat_t obcs,
       org_organization_definitions ood,
       ra_customers rc,
       hr_all_organization_units haou,
       hr_locations_v hl,
       hr_legal_entities hle,
       mtl_item_categories mic,
       mtl_categories mc,
       mtl_default_category_sets mdcs,
       mtl_system_items msi,
       mtl_item_flexfields mif,
       bis_territory_hierarchies bth
where
       obcs.organization_id = ood.organization_id and
       obcs.customer_id = rc.customer_id and
       haou.organization_id = ood.organization_id and
       haou.location_id = hl.location_id and
       ood.legal_entity = hle.organization_id and
       ood.set_of_books_id = hle.set_of_books_id and
       obcs.organization_id = mic.organization_id and
       obcs.inventory_item_id = msi.inventory_item_id and
       obcs.organization_id = msi.organization_id and
       obcs.inventory_item_id = mic.inventory_item_id and
       mdcs.functional_area_id = 7 and
       mdcs.category_set_id = mic.category_set_id and
       mic.category_id = mc.category_id  and
       mif.organization_id = obcs.organization_id and
       mif.inventory_item_id = obcs.inventory_item_id and
       hl.country = bth.child_territory_code and
       bth.parent_territory_type = ''AREA'' and
       gsob.set_of_books_id = ood.set_of_books_id and
       obcs.net_sales <> 0 and
       year.period_set_name = gsob.period_set_name and
       quarter.period_set_name = gsob.period_set_name and
       month.period_set_name = gsob.period_set_name and
       year.period_type = ''Year'' and
       quarter.period_type = ''Quarter'' and
       month.period_type = ''Month''  and
       year.adjustment_period_flag = ''N'' and
       quarter.adjustment_period_flag = ''N'' and
       month.adjustment_period_flag =  ''N'' and
       year.period_year = to_char(obcs.transaction_date, ''YYYY'') and
       trunc(obcs.transaction_date) between trunc(quarter.start_date) and trunc(quarter.end_date) and
       trunc(obcs.transaction_date) between trunc(month.start_date) and trunc(month.end_date) ' ;
   else

   sql_stmt := 'insert into oe_bis_cust_sat_t2 ( SET_OF_BOOKS_ID,
				SET_OF_BOOKS_NAME,
				LEGAL_ENTITY_ID,
				LEGAL_ENTITY_NAME,
				OPERATING_UNIT_ID,
				OPERATING_UNIT_NAME,
				ORGANIZATION_ID,
				ORGANIZATION_NAME,
				INVENTORY_ITEM_ID,
				CATEGORY_ID,
				CATEGORY_DESC,
				ITEM_DESCRIPTION,
				INVENTORY_ITEM_NAME,
				CUSTOMER_ID,
				SALES_CHANNEL_CODE,
				CUSTOMER_NAME,
				AREA,
				COUNTRY,
				TRANSACTION_DATE,
				DEL_SALES,
				RET_SALES,
				NET_SALES,
				PERIOD_SET_NAME,
				YEAR_PERIOD,
				QUARTER_PERIOD,
				MONTH_PERIOD,
				HEADER_ID,
				LINE_ID,
				LOCATION_ID,
				LOCATION_CODE,
				REGION)
select ood.set_of_books_id,  				-- set_of_books_id,
       gsob.name,  					-- set_of_books_name,
       hle.organization_id, 				-- legal_entity_id,
       hle.name, 					-- legal_entity_name,
       haou.organization_id, 				-- operating_unit_id,
       haou.name, 					-- operating_unit_name,
       obcs.organization_id,
       ood.organization_name,
       obcs.inventory_item_id,
       mc.category_id,
       mc.segment1 || ''.'' || mc.segment2, 		-- as category_desc,
       msi.description, 				-- as item_description,
       mif.item_number, 				-- as inventory_item_name,
       obcs.customer_id,
       nvl(rc.sales_channel_code,''Unspecified''), 	-- sales_channel_code,
       rc.customer_name,
       bth.parent_territory_code, 			-- area,
       hl.country,
       obcs.transaction_date,
       decode(obcs.del_flag,''Y'',obcs.net_sales,0), 			-- del_sales,
       decode(obcs.return_flag,''Y'',(obcs.net_sales) * -1,0),  	-- ret_sales,
       decode(obcs.return_flag, ''Y'',0,obcs.net_sales),  		-- net_sales,
       year.period_set_name,
       year.period_name, 				-- year_period ,
       quarter.period_name, 				-- quarter_period,
       month.period_name, 				-- month_period,
       obcs.header_id, 					-- header_id,
       obcs.line_id, 					-- line_id,
       hl.location_id, 					-- location_id,
       hl.location_code, 				-- location_code,
       '||app_col_name||' 				-- region
from
       gl_periods year,
       gl_periods quarter,
       gl_periods month,
       gl_sets_of_books gsob,
       oe_bis_cust_sat_t obcs,
       org_organization_definitions ood,
       ra_customers rc,
       hr_all_organization_units haou,
       hr_locations_v hl,
       hr_legal_entities hle,
       mtl_item_categories mic,
       mtl_categories mc,
       mtl_default_category_sets mdcs,
       mtl_system_items msi,
       mtl_item_flexfields mif,
       bis_territory_hierarchies bth
where
       obcs.organization_id = ood.organization_id and
       obcs.customer_id = rc.customer_id and
       haou.organization_id = ood.organization_id and
       haou.location_id = hl.location_id and
       ood.legal_entity = hle.organization_id and
       ood.set_of_books_id = hle.set_of_books_id and
       obcs.organization_id = mic.organization_id and
       obcs.inventory_item_id = msi.inventory_item_id and
       obcs.organization_id = msi.organization_id and
       obcs.inventory_item_id = mic.inventory_item_id and
       mdcs.functional_area_id = 7 and
       mdcs.category_set_id = mic.category_set_id and
       mic.category_id = mc.category_id  and
       mif.organization_id = obcs.organization_id and
       mif.inventory_item_id = obcs.inventory_item_id and
       hl.country = bth.child_territory_code and
       bth.parent_territory_type = ''AREA'' and
       gsob.set_of_books_id = ood.set_of_books_id and
       obcs.net_sales <> 0 and
       year.period_set_name = gsob.period_set_name and
       quarter.period_set_name = gsob.period_set_name and
       month.period_set_name = gsob.period_set_name and
       year.period_type = ''Year'' and
       quarter.period_type = ''Quarter'' and
       month.period_type = ''Month''  and
       year.adjustment_period_flag = ''N'' and
       quarter.adjustment_period_flag = ''N'' and
       month.adjustment_period_flag =  ''N'' and
       year.period_year = to_char(obcs.transaction_date, ''YYYY'') and
       trunc(obcs.transaction_date) between trunc(quarter.start_date) and trunc(quarter.end_date) and
       trunc(obcs.transaction_date) between trunc(month.start_date) and trunc(month.end_date) ' ;
   end if;

execute immediate sql_stmt;

Exception

   when others then

        if g_debug = 1 then
           fnd_file.put_line(fnd_file.log, SQLCODE);
           fnd_file.put_line(fnd_file.log,SQLERRM);
        end if ;
        x_errnum := -1 ;
        x_errmesg := substr(SQLERRM,1,150);
        commit ;
        return ;


 x_errnum  := 0;
 x_errmesg := 'NOERROR';  -- Replace this with the actual error later


END Populate_Summary_Table2;


END OE_BIS_CUST_SAT_SUMMARY;

/
