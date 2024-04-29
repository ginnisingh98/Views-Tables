--------------------------------------------------------
--  DDL for Package Body ICX_POR_JOB_TRACK_VALIDATION_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_JOB_TRACK_VALIDATION_S" as
/* $Header: ICXJVALB.pls 115.5 2001/06/29 18:03:56 pkm ship       $ */

g_error_message varchar2(1000) := '';

procedure Debug(p_message in varchar2) is
begin
  g_error_message := substr(g_error_message || p_message, 1000);
end;

procedure update_job_status(p_jobno in number,
                            p_new_status in varchar2,
                            p_loaded_items in number,
                            p_failed_items in number) is
  l_progress varchar2(10) := '000';
begin
  l_progress := '001';
  update icx_por_batch_jobs
  set    job_status = p_new_status,
         start_datetime = decode(p_new_status, 'RUNNING', sysdate, start_datetime),
         items_loaded = p_loaded_items,
         items_failed = p_failed_items
  where  job_number = p_jobno;

  l_progress := '002';
exception
  when others then
      Debug('[update_job_status-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.update_job_status(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

procedure complete_job(p_jobno in number) is
  l_progress varchar2(10) := '000';
begin
  l_progress := '001';
  update icx_por_batch_jobs
  set    job_status = decode(items_failed, 0, 'COMPLETED', 'COMPLETED W/ERRORS'),
         completion_datetime = sysdate
  where  job_number = p_jobno;

  l_progress := '002';
exception
  when others then
    Debug('[complete_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.complete_job(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

procedure fail_job(p_jobno in number,
                   p_error_message in varchar2) is
  l_progress varchar2(10) := '000';
begin
  l_progress := '001';
  update icx_por_batch_jobs
  set    job_status = 'FAILED',
         completion_datetime = sysdate,
         failure_message = p_error_message
  where  job_number = p_jobno;

  l_progress := '002';
  -- update the intermedia index for the failed job to
  -- index those items that were successfully inserted
  icx_por_populate_desc.populateCtxDescAll(p_jobno, 'N');


exception
  when others then
    Debug('[fail_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.fail_job(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

procedure InsertError(p_jobno in out number,
                      p_descriptor_key in varchar2,
                      p_message_name in varchar2,
                      p_line_number in number
 ) is
  l_progress varchar2(10) := '000';
begin
  l_progress := '001';
  if (p_jobno is null) then
    l_progress := '002';
    select icx_por_batch_jobs_s.nextval
    into   p_jobno
    from   sys.dual;
  end if;

  l_progress := '004';
  insert into icx_por_failed_line_messages (
    job_number,
    descriptor_key,
    message_name,
    line_number
  ) values (
    p_jobno,
    p_descriptor_key,
    p_message_name,
    p_line_number
  );

  l_progress := '005';
exception
  when others then
    Debug('[InsertError-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.InsertError(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

function validate_item_price(p_jobno in out number,
                             p_action in varchar2,
                             p_row_type in varchar2,
                             p_supplier_id in number,
                             p_supplier in varchar2,
                             p_supplier_part_num in varchar2,
                             p_description in varchar2,
                             p_unspsc in varchar2,
                             p_lead_time in number,
                             p_availability in varchar2,
                             p_item_type in varchar2,
                             p_buyer in varchar2,
                             p_uom in varchar2,
                             p_price in number,
                             p_currency_code in varchar2,
                             p_line_number in number,
                             p_job_supplier_name in varchar2,
                             p_business_group_id in number,
                             p_supplier_site in varchar2) return varchar2 is
  l_progress varchar2(10) := '000';
  l_need_commit boolean := false;
  l_foo varchar2(1) := null;
  l_valid boolean := true;
  l_buyer_id number := -1;
  l_supplier_id number := -1;
begin
  l_need_commit := (p_jobno is null);

  if (p_row_type in ('ITEM_PRICE', 'ITEM')) then
    l_progress := '010';
    if (p_supplier is null) then
      l_progress := '012';
      l_valid := false;
      InsertError(p_jobno, 'SUPPLIER', 'ICX_POR_SUPPLIER_REQD',
                  p_line_number);
    /* We don't need to validate suppliers
    else
      if (p_supplier <> p_job_supplier_name) then
      -- Supplier specified in item does not match supplier submitting
      -- the job. Fail the item.
        InsertError(p_jobno, 'SUPPLIER','ICX_POR_DIFFERENT_SUPPLIER',
                    p_line_number);
        l_valid := false;
      else
      */
    else
        begin
          l_progress := '014';
          select vendor_id
          into   l_supplier_id
          from   po_vendors
          where  vendor_name = p_supplier
          and    rownum = 1;
        exception
          when no_data_found then
            l_progress := '018';
            l_valid := false;
            InsertError(p_jobno, 'SUPPLIER', 'ICX_POR_INVALID_SUPPLIER',
                        p_line_number);
        end;

     /*end if;*/

    end if;

    l_progress := '020';
    if (p_supplier_part_num is null) then
      l_progress := '022';
      l_valid := false;
      InsertError(p_jobno, 'SUPPLIER_PART_NUM', 'ICX_POR_SUPPLIER_PART_REQD',
                  p_line_number);
    elsif (p_action in ('ADD','UPDATE')) then
      begin
        l_progress := '024';
        select 'Y'
        into   l_foo
        from   icx_por_items
        where  a3 = p_supplier_part_num
        and    a1 = p_supplier
        and    rownum = 1;

        if (p_action = 'ADD') then
          l_progress := '028';
          l_valid := false;
          InsertError(p_jobno, 'SUPPLIER_PART_NUM', 'ICX_POR_DUP_SUPPLIER_PART',
                      p_line_number);
        end if;

        -- bug 1791053
        if ( length(p_supplier_part_num) > 25 ) then
          l_valid := false;
          InsertError(p_jobno, 'SUPPLIER_PART_NUM',
                      'ICX_POR_MAX_SUP_PART_LEN', p_line_number);
        end if;
        l_progress := '029';


      exception
        when no_data_found then
          if (p_action = 'UPDATE') then
            l_valid := false;
            InsertError(p_jobno, 'SUPPLIER_PART_NUM',
                        'ICX_POR_PRC_INVALID_SUP_PART', p_line_number);
          end if;
          l_progress := '018';
      end;
    end if;

    -- bug 1791053
    if ( p_action in ('ADD', 'UPDATE') AND
	 length(p_supplier_part_num) > 25 ) then
          l_valid := false;
          InsertError(p_jobno, 'SUPPLIER_PART_NUM',
                      'ICX_POR_MAX_SUP_PART_LEN', p_line_number);
    end if;

    l_progress := '030';
    if (p_description is null AND p_action = 'ADD') then
      l_progress := '032';
      l_valid := false;
      InsertError(p_jobno, 'DESCRIPTION', 'ICX_POR_INVALID_DESCRIPTION',
                  p_line_number);
    end if;


	/*
	 * bug 1364308 - we don't need to validate unspsc codes anymore
	 *
    l_progress := '040';
    if p_unspsc is not null then
      begin
        l_progress := '042';
        select 'Y'
        into   l_foo
        from   icx_unspsc_codes
        where  unspsc_code = p_unspsc
        and    rownum = 1;
      exception
        when no_data_found then
          l_progress := '048';
          l_valid := false;
          InsertError(p_jobno, 'UNSPSC', 'ICX_POR_INVALID_UNSPSC',
                      p_line_number);
      end;
    end if;
	*/

    l_progress := '050';
    if (p_lead_time is not null) then
      if (p_lead_time <= 0) then
        l_progress := '052';
        l_valid := false;
        InsertError(p_jobno, 'LEAD_TIME', 'ICX_POR_INVALID_LEAD_TIME',
                    p_line_number);
      end if;
    end if;

    l_progress := '060';
    if (p_availability is not null) then
      begin
        l_progress := '062';
        select 'Y'
        into   l_foo
        from   fnd_lookups
        where  lookup_type = 'ICX_CATALOG_AVAILABILITY'
        and    lookup_code = p_availability
        and    rownum = 1;
      exception
        when no_data_found then
          l_progress := '068';
          l_valid := false;
          InsertError(p_jobno, 'AVAILABILITY', 'ICX_POR_INVALID_AVAILABILITY',
                      p_line_number);
      end;
    end if;

    l_progress := '070';
    if (p_item_type is not null) then
      begin
        l_progress := '072';
        select 'Y'
        into   l_foo
        from   fnd_lookups
        where  lookup_type = 'ICX_CATALOG_ITEM_TYPE'
        and    lookup_code = p_item_type
        and    rownum = 1;
      exception
        when no_data_found then
          l_progress := '078';
          l_valid := false;
          InsertError(p_jobno, 'ITEM_TYPE', 'ICX_POR_INVALID_ITEM_TYPE',
                      p_line_number);
      end;
   end if;

  end if;

  l_progress := '100';

  if (p_row_type in ('PRICE')) then

    l_progress := '110';
    if (p_supplier is null) then
      l_progress := '112';
      l_valid := false;
      InsertError(p_jobno, 'SUPPLIER', 'ICX_POR_PRC_SUPPLIER_REQD',
                  p_line_number);
    /* We don't need to validate supplier
    else
      if (p_supplier <> p_job_supplier_name) then
        InsertError(p_jobno, 'SUPPLIER','ICX_POR_PRC_DIFF_SUPPLIER',
                    p_line_number);
        l_valid := false;
      else
      */
    else
        begin
          l_progress := '114';
          select vendor_id
          into   l_supplier_id
          from   po_vendors
          where  vendor_name = p_supplier
          and    rownum = 1;
        exception
          when no_data_found then
            l_progress := '118';
            l_valid := false;
            InsertError(p_jobno, 'SUPPLIER', 'ICX_POR_PRC_INVALID_SUPPLIER',
                        p_line_number);
        end;

      /*end if;*/

    end if;


    l_progress := '120';
    if (p_supplier_part_num is null) then
      l_progress := '122';
      l_valid := false;
      InsertError(p_jobno, 'SUPPLIER_PART_NUM', 'ICX_POR_PRC_SUP_PART_REQD',
                  p_line_number);
    elsif (p_action = 'ADD') then
      begin
        l_progress := '124';
        select 'Y'
        into   l_foo
        from   icx_por_items
        where  a3 = p_supplier_part_num
        and    a1 = p_supplier
        and    rownum = 1;

        l_progress := '128';

      exception
        when no_data_found then
          l_progress := '118';
          l_valid := false;
          InsertError(p_jobno, 'SUPPLIER_PART_NUM',
                      'ICX_POR_PRC_INVALID_SUP_PART',
                      p_line_number);
      end;
    end if;

  end if;

  l_progress := '200';

  if ((p_row_type in ('ITEM_PRICE', 'PRICE')) OR
      (p_row_type in ('ITEM') and p_action in ('ADD'))) then

    l_progress := '230';
    if (p_buyer is null) then
    /* This is allowed since in single-org setup
       there won't be any operating unit
      l_progress := '231';
      l_valid := false;
      InsertError(p_jobno, 'BUYER', 'ICX_POR_BUYER_REQD',
                  p_line_number);
    */
      null;
    else
      begin
        l_progress := '232';
        /*l_buyer_id := to_number(p_buyer);*/

        -- Only need to check if not the default buyer
        /*if l_buyer_id <> -1 then*/
          select organization_id
          into   l_buyer_id
          from    hr_all_organization_units
          /*where   organization_id = l_buyer_id*/
          where   name = p_buyer
          and     business_group_id = p_business_group_id
          and     rownum = 1;
        /*end if;*/

      exception
        when no_data_found then
          l_progress := '248';
          l_valid := false;
          InsertError(p_jobno, 'BUYER', 'ICX_POR_INVALID_BUYER',
                      p_line_number);
      end;
    end if;

    l_progress := '235';
    if (l_supplier_id <> -1 and p_supplier_site is not null) then
      -- Check if supplier site exists

      if (l_buyer_id = -1) then
        begin
          select 'Y'
          into l_foo
          from po_vendor_sites_all
          where vendor_id = l_supplier_id
          and vendor_site_code = p_supplier_site
          and rownum = 1;

        exception
          when no_data_found then
            l_progress := '235_0';
            l_valid := false;
            InsertError(p_jobno, 'SUPPLIER_SITE','ICX_POR_INVALID_SUPP_SITE',
                        p_line_number);
        end;

      else
        begin
          l_progress := '235_1';
          select 'Y'
          into l_foo
          from po_vendor_sites_all
          where vendor_id = l_supplier_id
          and vendor_site_code = p_supplier_site
          and org_id = l_buyer_id
          and rownum = 1;

        exception
          when no_data_found then
            l_progress := '235_2';
            l_valid := false;
            InsertError(p_jobno, 'SUPPLIER_SITE','ICX_POR_INVALID_SUPP_SITE',
                        p_line_number);
        end;
      end if;
    end if;

    l_progress := '240';
    if (p_uom is null) then
      l_progress := '241';
      l_valid := false;
      InsertError(p_jobno, 'UOM', 'ICX_POR_UOM_REQD',
                  p_line_number);
    end if;

/* UOM now validated in OracleCatalogCreator.java
    else
      begin
        l_progress := '242';
        select 'Y'
        into   l_foo
        from   mtl_units_of_measure
        where  uom_code = p_uom
        and    rownum = 1;
      exception
        when no_data_found then
          l_progress := '248';
          l_valid := false;
          InsertError(p_jobno, 'UOM', 'ICX_POR_INVALID_UOM',
                      p_line_number);
      end;
    end if;
*/

    l_progress := '250';
    if (p_price is null) then
      l_progress := '251';
      l_valid := false;
      InsertError(p_jobno, 'PRICE', 'ICX_POR_PRICE_REQD',
                  p_line_number);
    /* price == 0 is valid */
    -- elsif (p_price <= 0) then
    elsif (p_price < 0) then
      l_progress := '252';
      l_valid := false;
      InsertError(p_jobno, 'PRICE', 'ICX_POR_INVALID_PRICE',
                  p_line_number);
    end if;


    l_progress := '260';
    if (p_currency_code is null) then
      l_progress := '261';
      l_valid := false;
      InsertError(p_jobno, 'CURRENCY_CODE', 'ICX_POR_CURRENCY_REQD',
                  p_line_number);
    else
      begin
        l_progress := '262';
        select 'Y'
        into   l_foo
        from   fnd_currencies
        where  currency_code = p_currency_code
        and    rownum = 1;
      exception
        when no_data_found then
          l_progress := '268';
          l_valid := false;
          InsertError(p_jobno, 'CURRENCY_CODE', 'ICX_POR_INVALID_CURRENCY',
                      p_line_number);
      end;
    end if;

  end if;

  l_progress := '300';
  if (l_need_commit) then
    commit;
  end if;

  l_progress := '301';
  if (l_valid) then
    return 'Y';
  else
    return 'N';
  end if;

exception
  when others then
    Debug('[validate_item_price-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.validate_item_price(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

procedure get_next_job(p_jobno out number,
                       p_exchange_file_name out varchar2,
                       p_supplier_id out number,
                       p_supplier_name out varchar2,
                       p_host_ip_address in varchar2,
                       p_exchange_operator out varchar2) is
  l_progress varchar2(10) := '000';
begin
  l_progress := '010';
  begin
    select min(job_number)
    into p_jobno
    from icx_por_batch_jobs
    where job_status='PENDING'
    and host_ip_address = p_host_ip_address;
  exception
    when no_data_found then
      l_progress := '010';
  end;
  l_progress := '020';
  if (p_jobno is not null) then

    select jb.exchange_file_name,
           jb.supplier_id,
           /*pt.vendor_name,*/
           'DEFAULT_SUPPLIER_NAME',
           jb.exchange_operator_name
    into p_exchange_file_name,
         p_supplier_id,
         p_supplier_name,
         p_exchange_operator
    /* from po_vendors pt, */
    from icx_por_batch_jobs jb
    where job_number = p_jobno;
    -- and jb.supplier_id = pt.vendor_id;

    update icx_por_batch_jobs
    set job_status = 'RUNNING',
        start_datetime = sysdate
    where  job_number = p_jobno;

  end if;
  l_progress := '030';
exception
  when others then
    Debug('[get_next_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.get_next_job(E
rrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

function create_job(p_supplier_id in number,
                    p_supplier_file in varchar2,
                    p_exchange_file in varchar2,
                    p_host_ip_address in varchar2,
                    p_exchange_operator in varchar2) return number is
  l_progress varchar2(10) := '000';
  l_jobno number;
begin

  l_progress := '001';
  select icx_por_batch_jobs_s.nextval
  into   l_jobno
  from   sys.dual;

  l_progress := '002';
  insert into icx_por_batch_jobs (
    job_number,
    supplier_id,
    supplier_file_name,
    exchange_file_name,
    items_loaded,
    items_failed,
    job_status,
    submission_datetime,
    start_datetime,
    completion_datetime,
    failure_message,
    host_ip_address,
    exchange_operator_name)
  values (
    l_jobno,
    p_supplier_id,
    p_supplier_file,
    p_exchange_file,
    0,
    0,
    'PENDING',
    sysdate,
    null,
    null,
    null,
    p_host_ip_address,
    p_exchange_operator
  );

  l_progress := '003';
   return l_jobno;

exception
  when others then
      Debug('[create_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_job_track_validation_s.create_job(Err
Loc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

end icx_por_job_track_validation_s;

/
