--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_INVOICE_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_INVOICE_PRICE" AS
/* $Header: gmfinvpb.pls 115.7 2002/12/04 17:04:23 umoogala ship $ */
  CURSOR cur_ap_get_invoice_price1 (
        startdate       in      date,
        enddate         in      date,
        invoicenum      in      varchar2,
        invoicelineno   in      number,
        invoiceid       in      number,
        vendorid        in      number,
        invoicetype     in      varchar2,
        linetype        in      varchar2 ) IS
  SELECT DISTINCT
        i.invoice_num,
        id.distribution_line_number,
        i.invoice_id,
        i.vendor_id,
        i.invoice_type_lookup_code,
        i.approval_status,
        id.parent_invoice_id,
        pl.po_header_id,
        pl.po_line_id,
        pd.line_location_id,
        id.line_type_lookup_code,
        msi.segment1,
        pl.item_description,
        id.quantity_invoiced,
        pl.unit_meas_lookup_code,
        id.amount,
        id.base_amount,
        msi.list_price_per_unit,
        id.unit_price,
        i.invoice_currency_code,
        sob.currency_code,
        id.exchange_rate,
        i.invoice_date,
        i.gl_date,
        id.creation_date,
        id.created_by,
        id.last_update_date,
        id.last_updated_by,
				i.cancelled_date
  FROM
        ap_invoices_all i,
        ap_invoice_distributions_all id,
        po_distributions_all pd,
	cpg_oragems_mapping map,
        po_lines_all pl,
        mtl_system_items msi,
        gl_sets_of_books sob
  WHERE i.invoice_num = invoicenum
    AND i.invoice_id LIKE NVL ( invoiceid, i.invoice_id)
    AND i.vendor_id LIKE NVL ( vendorid, i.vendor_id)
    AND i.invoice_type_lookup_code = invoicetype
    AND i.invoice_id = id.invoice_id
    AND id.distribution_line_number LIKE
          NVL ( invoicelineno, id.distribution_line_number)
    AND id.po_distribution_id = pd.po_distribution_id
    AND id.line_type_lookup_code LIKE
          NVL( linetype, id.line_type_lookup_code)
    AND i.set_of_books_id = sob.set_of_books_id
    AND pl.po_line_id = pd.po_line_id
    AND pl.item_id = msi.inventory_item_id
    AND map.po_line_location_id = pd.line_location_id
    AND map.po_line_id = pd.po_line_id
    AND map.po_header_id = pd.po_header_id
    AND id.last_update_date BETWEEN
          NVL( startdate, id.last_update_date) AND
          NVL( enddate, id.last_update_date);

  CURSOR cur_ap_get_invoice_price2 (
        startdate       in      date,
        enddate         in      date,
        invoicenum      in      varchar2,
        invoicelineno   in      number,
        invoiceid       in      number,
        vendorid        in      number,
        invoicetype     in      varchar2,
        linetype        in      varchar2 ) IS
  SELECT DISTINCT
        i.invoice_num,
        id.distribution_line_number,
        i.invoice_id,
        i.vendor_id,
        i.invoice_type_lookup_code,
        i.approval_status,
        id.parent_invoice_id,
        pl.po_header_id,
        pl.po_line_id,
        pd.line_location_id,
        id.line_type_lookup_code,
        msi.segment1,
        pl.item_description,
        id.quantity_invoiced,
        pl.unit_meas_lookup_code,
        id.amount,
        id.base_amount,
        msi.list_price_per_unit,
        id.unit_price,
        i.invoice_currency_code,
        sob.currency_code,
        id.exchange_rate,
        i.invoice_date,
        i.gl_date,
        id.creation_date,
        id.created_by,
        id.last_update_date,
        id.last_updated_by,
				i.cancelled_date
  FROM
        ap_invoices_all i,
        ap_invoice_distributions_all id,
        po_distributions_all pd,
	cpg_oragems_mapping map,
        po_lines_all pl,
        mtl_system_items msi,
        gl_sets_of_books sob
  WHERE i.invoice_num LIKE NVL( invoicenum, i.invoice_num)
    AND i.invoice_id LIKE NVL ( invoiceid, i.invoice_id)
    AND i.vendor_id LIKE NVL ( vendorid, i.vendor_id)
    AND i.invoice_type_lookup_code = invoicetype
    AND i.invoice_id = id.invoice_id
    AND id.distribution_line_number LIKE
          NVL ( invoicelineno, id.distribution_line_number)
    AND id.po_distribution_id = pd.po_distribution_id
    AND id.line_type_lookup_code LIKE
          NVL( linetype, id.line_type_lookup_code)
    AND i.set_of_books_id = sob.set_of_books_id
    AND pl.po_line_id = pd.po_line_id
    AND pl.item_id = msi.inventory_item_id
    AND map.po_line_location_id = pd.line_location_id
    AND map.po_line_id = pd.po_line_id
    AND map.po_header_id = pd.po_header_id
    AND id.last_update_date BETWEEN
          NVL( startdate, id.last_update_date) AND
          NVL( enddate, id.last_update_date);

PROCEDURE proc_ap_get_invoice_price (
  start_date            in      date,
  end_date              in      date,
  invoicenum           in out nocopy  varchar2,
  invoice_line_no       in out nocopy  number,
  invoiceid            in out nocopy  number,
  vendor_id             in out nocopy  number,
  invoice_type          in out nocopy  varchar2,
  previous_invoice_num     out nocopy  varchar2,
  invoice_status        in out nocopy  varchar2,
  po_header_id          in out nocopy  number,
  po_line_id            in out nocopy  number,
  po_line_location_id   in out nocopy  number,
  line_type             in out nocopy  varchar2,
  item_no                  out nocopy  varchar2,
  item_desc                out nocopy  varchar2,
  invoice_qty              out nocopy  number,
  invoice_uom              out nocopy  varchar2,
  invoice_amount           out nocopy  number,
  invoice_base_amount      out nocopy  number,
  base_unit_price          out nocopy  number,
  unit_price               out nocopy  number,
  billing_currency         out nocopy  varchar2,
  base_currency            out nocopy  varchar2,
  exchange_rate            out nocopy  number,
  invoice_date             out nocopy  date,
  gl_date                  out nocopy  date,
  creation_date              out nocopy  date,
  created_by                 out nocopy  number,
  last_update_date           out nocopy  date,
  last_updated_by            out nocopy  number ,
	t_cancelled_date      in out nocopy  date,
	t_match_status_flag   in out nocopy  varchar2,
  t_hold_count          in out nocopy  number,
	approval                 out nocopy  varchar2,
  statuscode               out nocopy  number,
  rowtofetch            in out nocopy  number) IS
/*  created_by            number;*/
/*  last_updated_by       number;*/
  tmp_invoice_id        number;
  t_match_status_flag2  varchar2(3);
/** MC BUG# 1554483 **/
/** UOM CONVERSION... create a variable to hold unit_of_measure and a cursor **/
  t_unit_of_measure     MTL_UNITS_OF_MEASURE.unit_of_measure%type;

CURSOR cr_um_code is
SELECT um_code from sy_uoms_mst
WHERE  unit_of_measure = t_unit_of_measure ;

BEGIN
  IF invoicenum IS NOT NULL THEN
    IF NOT cur_ap_get_invoice_price1%ISOPEN THEN
      OPEN cur_ap_get_invoice_price1(
            start_date,
            end_date,
            invoicenum,
            invoice_line_no,
            invoiceid,
            vendor_id,
            invoice_type,
            line_type);
    END IF;
  ELSE
    IF NOT cur_ap_get_invoice_price2%ISOPEN THEN
      OPEN cur_ap_get_invoice_price2(
            start_date,
            end_date,
            invoicenum,
            invoice_line_no,
            invoiceid,
            vendor_id,
            invoice_type,
            line_type);
    END IF;
  END IF;

  IF invoicenum IS NOT NULL THEN
    BEGIN
    FETCH       cur_ap_get_invoice_price1
    INTO        invoicenum,
                invoice_line_no,
                invoiceid,
                vendor_id,
                invoice_type,
                invoice_status,
                tmp_invoice_id,
                po_header_id,
                po_line_id,
                po_line_location_id,
                line_type,
                item_no,
                item_desc,
                invoice_qty,
                t_unit_of_measure, -- MC BUG# 1554483 invoice_uom,
                invoice_amount,
                invoice_base_amount,
                base_unit_price,
                unit_price,
                billing_currency,
                base_currency,
                exchange_rate,
                invoice_date,
                gl_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
								t_cancelled_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          statuscode := 100;
        WHEN OTHERS THEN
          statuscode := SQLCODE;
    END;
    IF ( cur_ap_get_invoice_price1%NOTFOUND ) THEN
      statuscode := 100;
    END IF;
    IF (cur_ap_get_invoice_price1%NOTFOUND) OR rowtofetch = 1 THEN
      CLOSE cur_ap_get_invoice_price1;
    END IF;
  ELSE
    BEGIN
    FETCH       cur_ap_get_invoice_price2
    INTO        invoicenum,
                invoice_line_no,
                invoiceid,
                vendor_id,
                invoice_type,
                invoice_status,
                tmp_invoice_id,
                po_header_id,
                po_line_id,
                po_line_location_id,
                line_type,
                item_no,
                item_desc,
                invoice_qty,
                t_unit_of_measure, -- MC BUG# 1554483 invoice_uom,
                invoice_amount,
                invoice_base_amount,
                base_unit_price,
                unit_price,
                billing_currency,
                base_currency,
                exchange_rate,
                invoice_date,
                gl_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
								t_cancelled_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          statuscode := 100;
        WHEN OTHERS THEN
          statuscode := SQLCODE;
    END;
    IF ( cur_ap_get_invoice_price2%NOTFOUND ) THEN
      statuscode := 100;
    END IF;
    IF (cur_ap_get_invoice_price2%NOTFOUND) OR rowtofetch = 1 THEN
      CLOSE cur_ap_get_invoice_price2;
    END IF;
 END IF;

    IF tmp_invoice_id IS NOT NULL THEN
      SELECT    invoice_num
      INTO      previous_invoice_num
      FROM      ap_invoices_all
      WHERE     invoice_id = tmp_invoice_id;
    END IF;
/** MC BUG# 1554483  **/
    OPEN cr_um_code;
    FETCH cr_um_code into invoice_uom;
    CLOSE cr_um_code;

/*    added_by := pkg_gl_get_currencies.get_name ( created_by );*/
/*    modified_by := pkg_gl_get_currencies.get_name (last_updated_by);*/
      t_hold_count := 0;

    IF invoicenum IS NOT NULL THEN
      select count(*)
      into t_hold_count
      from ap_holds_all aph, ap_invoices_all api
      where
	api.invoice_num = invoicenum
	and api.invoice_id = aph.invoice_id
	and aph.release_lookup_code is null;
    ELSE
	/* Bug 2539636 : This condition never occurs. Also, this sql is the top one
			 performance repository.
      		select count(*)
      		into t_hold_count
      		from ap_holds_all aph, ap_invoices_all api
      		where
		api.invoice_id = aph.invoice_id
		and aph.release_lookup_code is null;
	*/
	NULL;
    END IF;

	/**
	* 25-Feb-2000 Rajesh Seshadri Bug 1172792 - CBO changes
	* changed "column_name = nvl(input, column_name)" clause
	* to "(column_name = input_value or input_value is null)"
	* and in the second query modified the inner query to
	* refer to the outer table also.
	*/

    IF invoiceid IS NOT NULL THEN
      select min(decode(match_status_flag, 'N', '1N', 'T', '2T',
		                                   'A', '3A', '4'))
      into   t_match_status_flag
      from   ap_invoice_distributions_all
      where  invoice_id = invoiceid;
    ELSE
	/* Bug 2539636 : This condition never occurs. Also, this sql is the top one
			 performance repository.
      		select min(decode(match_status_flag, 'N', '1N', 'T', '2T',
		                                   'A', '3A', '4'))
      		into   t_match_status_flag
      		from   ap_invoice_distributions_all;
	*/
	NULL;
    END IF;

      BEGIN
      IF invoiceid IS NOT NULL THEN
      select distinct '1N'		/* Need just one value ONLY (if it exist)!!! */
      into   t_match_status_flag2
      from   ap_invoice_distributions_all
      where  invoice_id = invoiceid
      and    match_status_flag is null
      and    exists (select 'There are tested and untested lines'
		                 from   ap_invoice_distributions_all
		                 where  invoice_id = invoiceid
		                 and    match_status_flag in ('T', 'A'));
      ELSE
	/* Bug 2539636 : This condition never occurs. Also, this sql is the top one
			 performance repository.
      		select distinct '1N'		Need just one value ONLY (if it exist)!!!
      		into   t_match_status_flag2
      		from   ap_invoice_distributions_all
      		where  match_status_flag is null
      		and    exists (select 'There are tested and untested lines'
		                 	from   ap_invoice_distributions_all
		                 	where  match_status_flag in ('T', 'A')
						and rownum < 2);
	*/
	NULL;
      END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          t_match_status_flag2 := '4';
      END;
      if t_match_status_flag > t_match_status_flag2 then
         t_match_status_flag := t_match_status_flag2;
      end if;
      if t_match_status_flag in ('3A', '2T') and t_hold_count = 0 then
	       approval := 'Approved';
			elsif t_match_status_flag = '1N' then
			   approval := 'Needs Reapproval';
			elsif t_match_status_flag in ('4', '') then
			   approval := 'Never Approved';
			else
			   approval := 'Invoice Does Not Exist ';
			end if;
      if t_cancelled_date is null then
	       null;
      else
	      approval := 'Cancelled';
      end if;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       statuscode := 100;
     WHEN OTHERS THEN
       statuscode := SQLCODE;
  END proc_ap_get_invoice_price;
END GMF_AP_GET_INVOICE_PRICE;

/
