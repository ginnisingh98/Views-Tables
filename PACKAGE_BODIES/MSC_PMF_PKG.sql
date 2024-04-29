--------------------------------------------------------
--  DDL for Package Body MSC_PMF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PMF_PKG" as
/* $Header: MSCXPMFB.pls 120.1 2007/10/10 10:42:41 hbinjola ship $ */


procedure process_pmf_thresholds(p_multiple_measures in boolean,
                                 p_measure_short_name in varchar2);


/* *****************************************************************
  get_threshold (exception_type)
  used for both seeded as well as user-defined exceptions

*/

function get_threshold(p_exception_type in number,
                       p_company_id in number,
		       p_company_site_id in number,
		       p_inventory_item_id in number,
		       p_supplier_id in number,
		       p_supplier_site_id in number,
		       p_customer_id in number,
		       p_customer_site_id in number,
		       p_excp_time in date)
		       return number

is

   l_thresh_value number;
   rec_found boolean;

begin

   --dbms_output.put_line('get_threshold:exception_type');

   if ((p_exception_type is null) or (p_company_id is null)) then
      -- TODO flag error
      return 0;
   end if;

   /*
       supplier-facing seeded exceptions order of processing:
       (specific to general)
       1. <company, company-site, item, supplier, supplier-site>
       2. <company, company-site, item, supplier, null>
       3. <company, null,         item, supplier, null>
       4. <company, null,         null, supplier, null>
       5. <company, null,         null, null,     null>


       customer-facing seeded exceptions order of processing:
       (specific to general)
       1. <company, company-site, item, customer, customer-site>
       2. <company, company-site, item, customer, null>
       3. <company, null,         item, customer, null>
       4. <company, null,         null, customer, null>
       5. <company, null,         null, null,     null>

       Since in the api call it is not specified whether the call is for a
       customer-facing or supplier-facing exception, we combine the above as
       follows:

       seeded exceptions order of processing: (specific to general)

       1. <company, company-site, item, supplier, supplier-site> or
          <company, company-site, item, customer, customer-site>

       2. <company, company-site, item, supplier, null> or
          <company, company-site, item, customer, null>

       3. <company, null,         item, supplier, null> or
          <company, null,         item, customer, null>

       4. <company, null,         null, supplier, null> or
          <company, null,         null, customer, null>

       5. <company, null,         null, null,     null> or
          <company, null,         null, null,     null>

   */


   l_thresh_value := 0;
   rec_found := false;

   /* case 1
       <company, company-site, item, supplier, supplier-site> or
       <company, company-site, item, customer, customer-site>
   */

   --dbms_output.put_line('get_threshold:case 1');

   if ((p_company_site_id is not null) and
       (p_inventory_item_id is not null) and
       (p_supplier_id is not null)     and
       (p_supplier_site_id is not null)) then

      begin
         rec_found := true;

         select value
         into l_thresh_value
         from msc_exception_threshold_values
         where exception_type = p_exception_type
         and   company_id = p_company_id
         and   company_site_id = p_company_site_id
         and   inventory_item_id = p_inventory_item_id
         and   supplier_id = p_supplier_id
         and   supplier_site_id = p_supplier_site_id;

      exception
         when no_data_found then
            rec_found := false;
         when too_many_rows then
            --TODO error processing
            null;
      end;

   elsif ((p_company_site_id is not null) and
          (p_inventory_item_id is not null) and
          (p_customer_id is not null)     and
          (p_customer_site_id is not null)) then

      begin
         rec_found := true;

         select value
         into l_thresh_value
         from msc_exception_threshold_values
         where exception_type = p_exception_type
         and   company_id = p_company_id
         and   company_site_id = p_company_site_id
         and   inventory_item_id = p_inventory_item_id
         and   customer_id = p_customer_id
         and   customer_site_id = p_customer_site_id;

      exception
         when no_data_found then
            rec_found := false;
         when too_many_rows then
            --TODO error processing
            null;
      end;

   end if;


   --dbms_output.put_line('get_threshold: done case 1');

   if (rec_found = false) then

      --dbms_output.put_line('get_threshold: case 2');
      /* case 2:
           <company, company-site, item, supplier, null> or
           <company, company-site, item, customer, null>
      */

      if ((p_company_site_id is not null) and
          (p_inventory_item_id is not null) and
          (p_supplier_id is not null)) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   company_site_id = p_company_site_id
            and   inventory_item_id = p_inventory_item_id
            and   supplier_id = p_supplier_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      elsif ((p_company_site_id is not null) and
             (p_inventory_item_id is not null) and
             (p_customer_id is not null)) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   company_site_id = p_company_site_id
            and   inventory_item_id = p_inventory_item_id
            and   customer_id = p_customer_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      end if;
   end if;

   --dbms_output.put_line('get_threshold: done case 2');

   if (rec_found = false) then

      --dbms_output.put_line('get_threshold: case 3');

      /* case 3:
           <company, null,         item, supplier, null> or
           <company, null,         item, customer, null>
      */

      if ((p_inventory_item_id is not null) and
          (p_supplier_id is not null)) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   inventory_item_id = p_inventory_item_id
            and   supplier_id = p_supplier_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      elsif ((p_inventory_item_id is not null) and
             (p_customer_id is not null)) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   inventory_item_id = p_inventory_item_id
            and   customer_id = p_customer_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      end if;
   end if;

   --dbms_output.put_line('get_threshold: done case 3');

   if (rec_found = false) then

      --dbms_output.put_line('get_threshold: case 4');

      /* case 4:
            <company, null,         null, supplier, null> or
            <company, null,         null, customer, null>
      */

      if (p_supplier_id is not null) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   supplier_id = p_supplier_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      elsif (p_customer_id is not null) then

         begin
            rec_found := true;

            select value
            into l_thresh_value
            from msc_exception_threshold_values
            where exception_type = p_exception_type
            and   company_id = p_company_id
            and   customer_id = p_customer_id;

         exception
            when no_data_found then
               rec_found := false;
            when too_many_rows then
               --TODO error processing
               null;
         end;

      end if;
   end if;

   --dbms_output.put_line('get_threshold: done case 4');

   if (rec_found = false) then

      --dbms_output.put_line('get_threshold: case 5');

      /* case 5:
          <company, null,         null, null,     null> or
          <company, null,         null, null,     null>
      */

      begin
         rec_found := true;

         select value
         into l_thresh_value
         from msc_exception_threshold_values
         where exception_type = p_exception_type
         and   company_id = p_company_id
         and   company_site_id is NULL
         and   inventory_item_id is NULL
         and   supplier_id is NULL
         and   supplier_site_id is NULL
         and   customer_id is NULL
         and   customer_site_id is NULL; ---Added for FP-bug#6472941;;

      exception
         when no_data_found then
            rec_found := false;
         when too_many_rows then
            --TODO error processing
            null;
         end;

   end if;

   --dbms_output.put_line('get_threshold: done case 5');

   --dbms_output.put_line('get_threshold:thresh_value=' || l_thresh_value);

   return l_thresh_value;

end;


/* *****************************************************************
  process_pmf_thresholds - deprecated

*/


procedure process_pmf_thresholds

is

begin

   process_pmf_thresholds(true, null);

end;



/* *****************************************************************
  process_pmf_thresholds - deprecated

*/

procedure process_pmf_thresholds(p_multiple_measures in boolean,
                                 p_measure_short_name in varchar2)
is


begin

  null;

end;



/* *****************************************************************
  get_threshold (measure_short_name) - deprecated

*/


function get_threshold(p_measure_short_name in varchar2,
                       p_company_id in number,
		       p_company_site_id in number,
		       p_inventory_item_id in number,
		       p_supplier_id in number,
		       p_supplier_site_id in number,
		       p_customer_id in number,
		       p_customer_site_id in number,
		       p_excp_time in date)
		       return number

is

begin

   --dbms_output.put_line('get_threshold:measure_short_name');

   return 0;

end;




/* *****************************************************************
  get_threshold (measure_short_name) - deprecated

*/


function get_threshold2(p_measure_short_name in varchar2,
                        p_company_id in number,
		        p_company_site_id in number,
		        p_inventory_item_id in number,
		        p_supplier_id in number,
		        p_supplier_site_id in number,
		        p_customer_id in number,
		        p_customer_site_id in number,
		        p_excp_time in date)
		        return number
is

begin
   --dbms_output.put_line('get_threshold2:measure_name');

   process_pmf_thresholds(false, p_measure_short_name);

   return 0;

end;


/* *****************************************************************
  get_threshold (exception_type) - deprecated

*/


function get_threshold2(p_exception_type in number,
                        p_company_id in number,
		        p_company_site_id in number,
		        p_inventory_item_id in number,
		        p_supplier_id in number,
		        p_supplier_site_id in number,
		        p_customer_id in number,
		        p_customer_site_id in number,
		        p_excp_time in date)
		        return number

is

begin
   --dbms_output.put_line('get_threshold2:exception_type');

   --process_pmf_thresholds(false, l_indicator_short_name);

   return 0;

end;




end MSC_PMF_PKG;

/
