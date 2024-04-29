--------------------------------------------------------
--  DDL for Package Body FWK_TBX_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FWK_TBX_SEED" as
/* $Header: fwktbx_seedb.pls 120.2 2005/12/18 20:57:28 nigoel noship $ */

procedure insert_lookup_type(p_lookup_type varchar2,
                             p_display_name varchar2,
                             p_description varchar2)
is
begin

  insert into fwk_tbx_lookup_types_tl (
    lookup_type,
    display_name,
    description,
    language,
    source_lang
  )
  select p_lookup_type,
         p_display_name,
         p_description,
         'US',
         'US'
  from dual
  where not exists
    (select null
     from fwk_tbx_lookup_types_tl t
     where t.lookup_type = p_lookup_type
     and   t.language = 'US');


end insert_lookup_type;




procedure insert_lookup_code(p_lookup_type varchar2,
                             p_lookup_code varchar2,
                             p_meaning varchar2,
                             p_description varchar2,
                             p_start_date date,
                             p_end_date date)
is
begin

  insert into fwk_tbx_lookup_codes_b (
    lookup_type,
    lookup_code,
    start_date_active,
    end_date_active
  )
  select p_lookup_type,
         p_lookup_code,
         p_start_date,
         p_end_date
  from dual
  where not exists (select null
                    from fwk_tbx_lookup_codes_b
                    where lookup_type = p_lookup_type
                    and   lookup_code = p_lookup_code);

  insert into fwk_tbx_lookup_codes_tl (
    lookup_type,
    lookup_code,
    meaning,
    description,
    language,
    source_lang
  )
  select p_lookup_type,
         p_lookup_code,
         p_meaning,
         p_description,
         'US',
         'US'
  from dual
  where not exists
    (select null
     from fwk_tbx_lookup_codes_tl t
     where t.lookup_type = p_lookup_type
     and   t.lookup_code = p_lookup_code
     and   t.language = 'US');


end insert_lookup_code;

procedure update_lookup_type(p_lookup_type varchar2,
                             p_display_name varchar2,
                             p_description varchar2)
is
begin

update fwk_tbx_lookup_types_tl set
    lookup_type = p_lookup_type,
    display_name = p_display_name,
    description = p_description,
    source_lang  =  userenv('LANG')
where lookup_type = p_lookup_type
and userenv('LANG') in (language,source_lang);

if (sql%notfound) then
raise no_data_found;
end if;

end update_lookup_type;


procedure update_lookup_code(p_lookup_type varchar2,
                             p_lookup_code varchar2,
                             p_meaning varchar2,
                             p_description varchar2,
                             p_start_date date,
                             p_end_date date)
is
begin

update fwk_tbx_lookup_codes_b set
    lookup_type = p_lookup_type,
    lookup_code = p_lookup_code,
    start_date_active = p_start_date,
    end_date_active = p_end_date
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code;

if (sql%notfound) then
raise no_data_found;
end if;

update fwk_tbx_lookup_codes_tl set
    lookup_type = p_lookup_type,
    lookup_code = p_lookup_code,
    meaning = p_meaning,
    description = p_description,
    source_lang = userenv('LANG')
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code
and userenv('LANG') in (language,source_lang);

if (sql%notfound) then
raise no_data_found;
end if;

end update_lookup_code;


procedure delete_lookup_type(p_lookup_type varchar2)
is
begin

delete from fwk_tbx_lookup_types_tl
where lookup_type = p_lookup_type;

if (sql%notfound) then
raise no_data_found;
end if;

end delete_lookup_type;


procedure delete_lookup_code(p_lookup_type varchar2,
                             p_lookup_code varchar2)
is
begin

delete from fwk_tbx_lookup_codes_b
where lookup_type = p_lookup_type
and     lookup_code = p_lookup_code;

if (sql%notfound) then
raise no_data_found;
end if;

delete from fwk_tbx_lookup_codes_tl
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code;

if (sql%notfound) then
raise no_data_found;
end if;

end delete_lookup_code;


procedure insert_employee(p_employee_id number,
                          p_title varchar2,
                          p_first_name varchar2,
                          p_middle_names varchar2,
                          p_last_name varchar2,
                          p_email_address varchar2,
                          p_manager_id number,
                          p_position_code varchar2,
                          p_salary number,
                          p_start_date date,
                          p_end_date date)
is
begin

    insert into fwk_tbx_employees
        (employee_id,
         title,
         first_name,
         middle_names,
         last_name,
         full_name,
         email_address,
         manager_id,
         position_code,
         salary,
         start_date,
         end_date,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_employee_id,
           p_title,
           p_first_name,
           p_middle_names,
           p_last_name,
           p_last_name||', '||p_first_name||' '||p_middle_names,
           p_email_address,
           p_manager_id,
           p_position_code,
           p_salary,
           p_start_date,
           p_end_date,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_employees
                      where employee_id = p_employee_id);

end insert_employee;


procedure insert_address(p_address_id number,
                         p_address_name varchar2,
                         p_address_line_1 varchar2,
                         p_address_line_2 varchar2,
                         p_address_line_3 varchar2,
                         p_description varchar2,
                         p_email_address varchar2,
                         p_country varchar2,
                         p_town_or_city varchar2,
                         p_postal_code varchar2,
                         p_start_date date,
                         p_end_date date,
                         p_telephone_number_1 varchar2,
                         p_telephone_number_2 varchar2,
                         p_telephone_number_3 varchar2)
is
begin

    insert into fwk_tbx_addresses
        (address_id,
         address_name,
         address_line_1,
         address_line_2,
         address_line_3,
         description,
         email_address,
         country,
         town_or_city,
         postal_code,
         start_date,
         end_date,
         telephone_number_1,
         telephone_number_2,
         telephone_number_3,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_address_id,
           p_address_name,
           p_address_line_1,
           p_address_line_2,
           p_address_line_3,
           p_description,
           p_email_address,
           p_country,
           p_town_or_city,
           p_postal_code,
           p_start_date,
           p_end_date,
           p_telephone_number_1,
           p_telephone_number_2,
           p_telephone_number_3,
           sysdate,
           0,
           sysdate,
           0
     from dual
     where not exists (select null
                       from fwk_tbx_addresses
                       where address_id = p_address_id);

end insert_address;


procedure insert_supplier(p_supplier_id number,
                          p_name varchar2,
                          p_on_hold_flag varchar2,
                          p_start_date date,
                          p_end_date date)
is
begin

    insert into fwk_tbx_suppliers
        (supplier_id,
         name,
         on_hold_flag,
         start_date,
         end_date,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_supplier_id,
           p_name,
           p_on_hold_flag,
           p_start_date,
           p_end_date,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_suppliers
                      where supplier_id = p_supplier_id);

end insert_supplier;


procedure insert_supplier_site(p_supplier_site_id number,
                               p_supplier_id number,
                               p_site_name varchar2,
                               p_payment_terms_code varchar2,
                               p_carrier_code varchar2,
                               p_purchasing_site_flag varchar2,
                               p_address_id number,
                               p_start_date	date,
                               p_end_date date)
is
begin

    insert into fwk_tbx_supplier_sites
        (supplier_id,
         supplier_site_id,
         site_name,
         payment_terms_code,
         carrier_code,
         purchasing_site_flag,
         address_id,
         start_date,
         end_date,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_supplier_id,
           p_supplier_site_id,
           p_site_name,
           p_payment_terms_code,
           p_carrier_code,
           p_purchasing_site_flag,
           p_address_id,
           p_start_date,
           p_end_date,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_supplier_sites
                      where supplier_site_id = p_supplier_site_id);

end insert_supplier_site;


procedure insert_item(p_item_id number,
                      p_item_description varchar2,
                      p_start_date_active date,
                      p_end_date_active date,
                      p_enabled_flag varchar2,
                      p_summary_flag varchar2,
                      p_segment1 varchar2,
                      p_segment2 varchar2,
                      p_segment3 varchar2,
                      p_segment4 varchar2,
                      p_fwkitem_id number,
                      p_fwkitem_structure_id number)
is
begin

    insert into fwk_tbx_items
        (item_id,
         item_description,
         start_date_active,
         end_date_active,
         enabled_flag,
         summary_flag,
         segment1,
         segment2,
         segment3,
         segment4,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         fwkitem_id,
         fwkitem_structure_id)
    select p_item_id,
           p_item_description,
           p_start_date_active,
           p_end_date_active,
           p_enabled_flag,
           p_summary_flag,
           p_segment1,
           p_segment2,
           p_segment3,
           p_segment4,
           sysdate,
           0,
           sysdate,
           0,
           p_fwkitem_id,
           p_fwkitem_structure_id
    from dual
    where not exists (select null
                      from fwk_tbx_items
                      where item_id = p_item_id);

end insert_item;



procedure insert_po_header(p_header_id number,
                           p_description varchar2,
                           p_status_code varchar2,
                           p_confirm_flag varchar2,
                           p_supplier_id number,
                           p_supplier_site_id number,
                           p_currency_code varchar2,
                           p_buyer_id number,
                           p_payment_terms_code varchar2,
                           p_carrier_code varchar2,
                           p_ship_to_address_id number,
                           p_bill_to_address_id number,
                           p_rate number)
is
begin

    insert into fwk_tbx_po_headers
        (header_id,
         description,
         status_code,
         confirm_flag,
         supplier_id,
         supplier_site_id,
         currency_code,
         buyer_id,
         payment_terms_code,
         carrier_code,
         ship_to_address_id,
         bill_to_address_id,
         rate,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by)
    select p_header_id,
           p_description,
           p_status_code,
           p_confirm_flag,
           p_supplier_id,
           p_supplier_site_id,
           p_currency_code,
           p_buyer_id,
           p_payment_terms_code,
           p_carrier_code,
           p_ship_to_address_id,
           p_bill_to_address_id,
           p_rate,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_po_headers
                      where header_id = p_header_id);


end insert_po_header;



procedure insert_po_line(p_line_id number,
                         p_header_id number,
                         p_line_number number,
                         p_item_id number,
                         p_item_description varchar2,
                         p_unit_of_measure varchar2,
                         p_quantity number,
                         p_unit_price number)
is
begin

    insert into fwk_tbx_po_lines
        (line_id,
         header_id,
         line_number,
         item_id,
         item_description,
         unit_of_measure,
         quantity,
         unit_price,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_line_id,
           p_header_id,
           p_line_number,
           p_item_id,
           p_item_description,
           p_unit_of_measure,
           p_quantity,
           p_unit_price,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_po_lines
                      where line_id = p_line_id);

end insert_po_line;


procedure insert_po_shipment(p_shipment_id number,
                             p_line_id number,
                             p_shipment_number number,
                             p_need_by_date date,
                             p_promise_date date,
                             p_receipt_quantity number,
                             p_order_quantity number,
                             p_ship_to_address_id number,
                             p_receipt_date date)
is
begin

    insert into fwk_tbx_po_shipments
        (shipment_id,
         line_id,
         shipment_number,
         need_by_date,
         promise_date,
         receipt_quantity,
         order_quantity,
         ship_to_address_id,
         receipt_date,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
    select p_shipment_id,
           p_line_id,
           p_shipment_number,
           p_need_by_date,
           p_promise_date,
           p_receipt_quantity,
           p_order_quantity,
           p_ship_to_address_id,
           p_receipt_date,
           sysdate,
           0,
           sysdate,
           0
    from dual
    where not exists (select null
                      from fwk_tbx_po_shipments
                      where shipment_id = p_shipment_id);

end insert_po_shipment;


procedure insert_item_ccids(p_fwkitem_id number,
                               p_fwkitem_structure_id number,
                               p_summary_flag varchar2,
                               p_enabled_flag varchar2,
                               p_segment1 varchar2,
                               p_segment2 varchar2,
                               p_segment3 varchar2,
                               p_segment4 varchar2,
                               p_segment5 varchar2,
                               p_segment6 varchar2,
                               p_segment7 varchar2,
                               p_segment8 varchar2,
                               p_segment9 varchar2,
                               p_segment10 varchar2)
is
begin

  insert into fwk_tbx_item_ccids (
    FWKITEM_ID,
    FWKITEM_STRUCTURE_ID,
    SUMMARY_FLAG,
    ENABLED_FLAG,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    start_date_active,
    end_date_active,
    creation_date,
    created_by,
    last_update_login,
    last_update_date,
    last_updated_by
  )
  select p_fwkitem_id,
         p_fwkitem_structure_id,
         p_summary_flag,
         p_enabled_flag,
         p_segment1,
         p_segment2,
         p_segment3,
         p_segment4,
         p_segment5,
         p_segment6,
         p_segment7,
         p_segment8,
         p_segment9,
         p_segment10,
         sysdate,
         to_date(null),
         sysdate,
         0,
         0,
         sysdate,
         0
  from dual
  where not exists (select null
         from fwk_tbx_item_ccids
         where fwkitem_id = p_fwkitem_id);

end insert_item_ccids;


procedure insert_project_header(p_project_id number,
                                p_name varchar2,
                                p_start_date date,
                                p_completion_date date,
                                p_start_from date,
                                p_end_to date,
                                p_task_type varchar2,
                                p_text_right varchar2)
is
begin
  INSERT INTO FWK_TBX_PROJECT_HEADERS
    ( PROJECT_ID,
      NAME,
      START_DATE,
      COMPLETION_DATE,
      START_FROM,
      END_TO,
      TASK_TYPE,
      TEXT_RIGHT,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY )
  SELECT p_project_id,
         p_name,
         p_start_date,
         p_completion_date,
         p_start_from,
         p_end_to,
         p_task_type,
         p_text_right,
         sysdate,
         0,
         sysdate,
         0
  FROM DUAL
  WHERE not exists (SELECT null
                      FROM FWK_TBX_PROJECT_HEADERS
                      WHERE PROJECT_ID = p_project_id);

end insert_project_header;

procedure insert_project_detail(p_project_id number,
                                p_top_task_id number,
                                p_task_id number,
                                p_task_number varchar2,
                                p_task_name varchar2,
                                p_start_from date,
                                p_end_to date,
                                p_task_type varchar2,
                                p_text_right varchar2)
is
begin
  INSERT INTO FWK_TBX_PROJECT_DETAILS
    ( PROJECT_ID,
      TOP_TASK_ID,
      TASK_ID,
      TASK_NUMBER,
      TASK_NAME,
      START_FROM,
      END_TO,
      TASK_TYPE,
      TEXT_RIGHT,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY )
  SELECT p_project_id,
         p_top_task_id,
         p_task_id,
         p_task_number,
         p_task_name,
         p_start_from,
         p_end_to,
         p_task_type,
         p_text_right,
         sysdate,
         0,
         sysdate,
         0
  FROM DUAL
  WHERE not exists (SELECT null
                    FROM FWK_TBX_PROJECT_DETAILS
                    WHERE TASK_ID = p_task_id);

end insert_project_detail;

end fwk_tbx_seed;

/
