--------------------------------------------------------
--  DDL for Package Body ARP_LOCKBOX_HOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_LOCKBOX_HOOK_PVT" AS
/*$Header: ARRLBHPB.pls 120.10.12010000.7 2009/07/03 12:03:06 aghoraka ship $*/
--
/* Private variables */
g_okl_installed boolean := FALSE;
g_custom_llca_installed boolean := FALSE;
g_second_validation_pvt boolean := FALSE;
g_second_validation_pub boolean := FALSE;
--
/*----------------------------------------------------------------------------
   proc_before_validation

   This procedure will be called before the validation is called from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that some processing had taken place in this
     procedure and it returned success. It will proceed with validation then.
   If this procedure returns 2,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.
   If out_insert_records is returned as 'Y', the first validation will
     insert the records into ar_interim_cash_receipt and receipt_line.
     In non-custom mode, this parameter returns 'Y', because we do not call
     validation second time. However, if you are planning to call the second
     validation, for customising lockbox,  assign this variable as 'N'.

 ----------------------------------------------------------------------------*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2) IS
--
l_okl_flag  varchar2(1) := 'N';
pvt_errorbuf varchar2(255);
pvt_errorcode varchar2(255);
pvt_insert_records varchar2(1);
pub_errorbuf varchar2(255);
pub_errorcode varchar2(255);
pub_insert_records varchar2(1);
l_org_id number;
l_line_level_cash_app_rule varchar2(2);
--
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook_pvt.proc_before_validation()+');
  END IF;

  BEGIN
    select nvl(a.LINE_LEVEL_CASH_APP_RULE,'N') into l_line_level_cash_app_rule
    from ar_lockboxes_all a, ar_transmissions_all b
    where b.transmission_request_id = in_trans_req_id
    and   a.lockbox_id = b.requested_lockbox_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Lockbox Number is given through the data file');
      END IF;
      /* * Bug 7504497 Line Level Cash Application Rule is fetched from ar_lockboxes *
         * using Lockbox_number provided in the data file. However the data in the   *
	 * interface table will not be trimmed at this point which might fail in     *
	 * fetching data from ar_lockboxes. Hence trimmed Lockbox number here. The   *
	 * data in interface table will be trimmed later in arlvtr.lpc.              * */
      BEGIN
        UPDATE ar_payments_interface pi
        SET pi.lockbox_number =
          (SELECT decode(ff.justification_lookup_code,
                         'LEFT', RTRIM(pi.lockbox_number, decode(ff.fill_character_lookup_code, 'ZERO', '0', 'BLANK', ' ')),
                         'RIGHT', LTRIM(pi.lockbox_number,decode(ff.fill_character_lookup_code, 'ZERO', '0', 'BLANK', ' ')))
           FROM ar_transmissions tr,
             ar_trans_field_formats ff,
             ar_trans_record_formats rf
           WHERE tr.transmission_id = pi.transmission_id
           AND ff.transmission_format_id = tr.requested_trans_format_id
           AND rf.record_format_id = ff.record_format_id
           AND rf.record_identifier = pi.record_type
           AND ff.field_type_lookup_code IN('LB NUM'))
        WHERE pi.transmission_request_id = in_trans_req_id
        AND pi.lockbox_number IS NOT NULL;

        /* Lockbox Number can be present on any record. Hence changed the logic
	   to fetch Lockbox Number from interface wherever it is available. Earlier
	   Lockbox Number is fetched only from LB Hdr/LB Trl records. */

        select distinct( nvl(a.line_level_cash_app_rule, 'N'))
        into l_line_level_cash_app_rule
        from ar_lockboxes a
        where a.lockbox_number  in ( select distinct(lockbox_number)
                                    from ar_payments_interface
                                    where transmission_request_id = in_trans_req_id
                                    and lockbox_number is not null );
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Multiple Lockboxes are present with different LLCA Rules');
          END IF;
          RAISE;
        WHEN NO_DATA_FOUND THEN
          IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('No matching Lockbox found.');
          END IF;
          /* Bug 7648756 : There cannot be a case where Lockbox number is neither provided
	     in the flat file nor in the request submission window, unless the customer is
	     running an empty transmission file to close the transmission. If the customer
	     really has submitted it wrong, then it would be caught at the later stages.
	     So suppressing the error here. */
	  l_line_level_cash_app_rule := 'N';
          -- RAISE;
	WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Error in fetching Line Level Cash Application Rule.');
  	  arp_util.debug('Error Message '||SQLERRM);
  	END IF;
	  RAISE;
      END;

  END;

  /* Check if custom code for LLCA is installed. */
  if l_line_level_cash_app_rule = 'C' then
	g_custom_llca_installed := TRUE;
  end if;

  -- Check if OKL is installed
  BEGIN
    l_org_id := to_number(arp_standard.sysparm.org_id);

    if okl_cash_appl_rules.okl_installed(l_org_id) and l_line_level_cash_app_rule = 'L' THEN
        	l_okl_flag := 'Y';
    else
		l_okl_flag := 'N';
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('proc_before_validation: ' || 'Exception in checking if OKL is installed');
      END IF;
      l_okl_flag := 'N';
  END;

  IF l_okl_flag = 'Y' THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('proc_before_validation: ' || 'OKL is installed');
    END IF;
    g_okl_installed := TRUE;
  END IF;

  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    -- Removed ARTA logic as functionality is obsolete in R12
    --  See Bug 4936298
    NULL; -- Do Nothing
  ELSIF g_okl_installed THEN
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'N';
  ELSIF g_custom_llca_installed THEN
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'N';
  ELSE
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'Y';
  END IF;

  IF pvt_insert_records = 'N' THEN
    g_second_validation_pvt := TRUE;
  END IF;

  -- Now call public hook
  arp_lockbox_hook.proc_before_validation(pub_errorbuf,pub_errorcode,in_trans_req_id,pub_insert_records);

  IF pub_insert_records = 'N' THEN
    g_second_validation_pub := TRUE;
  END IF;

  IF pvt_errorcode = 0 THEN
    out_errorcode := pub_errorcode;
    out_errorbuf := pub_errorbuf;
  ELSE
    out_errorcode := pvt_errorcode;
    out_errorbuf := pvt_errorbuf;
  END IF;

  IF pvt_insert_records = 'N' THEN
    out_insert_records := 'N';
  ELSE
    out_insert_records := pub_insert_records;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook_pvt.proc_before_validation()-');
  END IF;
END proc_before_validation;
--
/*----------------------------------------------------------------------------
   proc_after_validation

   This procedure will be called after the validation is over from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that some processing had taken place in this
     procedure and arlplb.opc will fire the validation (arlval) again.
   If this procedure returns 2,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.
   If this procedure returns 9,
     arlplb.opc will not fire the validation second time and will go ahead
     with arlprt(). This is the same path as it was taking in base Rel 10.7
   If out_insert_records is returned as 'Y', the second validation will
     insert the records into ar_interim_cash_receipt and receipt_line.
     In non-custom mode, this parameter returns 'N', because we do not call
     validation second time. However, if you are planning to call the second
     validation and you have returned out_insert_records as 'N' in the
     proc_before_validation, you should return 'Y' here. This parameter is
     considered only if the out_errorcode was returned as 0.

 ----------------------------------------------------------------------------*/
PROCEDURE proc_after_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2) IS
--
l_okl_block  varchar2(1000);
pvt_errorbuf varchar2(255);
pvt_errorcode varchar2(255);
pvt_insert_records varchar2(1);
pub_errorbuf varchar2(255);
pub_errorcode varchar2(255);
pub_insert_records varchar2(1);
p_api_version                    NUMBER := 1;
p_init_msg_list                  VARCHAR2(1) := 'F';
x_return_status          VARCHAR2(1);
x_msg_count                              NUMBER;
x_msg_data                               VARCHAR(2000);
--
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('proc_after_validation: ' || 'arp_lockbox_hook_pvt.proc_after_validation()+');
  END IF;
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    -- Removed ARTA logic as functionality is obsolete in R12
    --  See Bug 4936298
    NULL; -- Do Nothing
  ELSIF g_okl_installed THEN
    BEGIN
      l_okl_block :=
      'BEGIN ' ||
      'OKL_LCKBX_CSH_APP_PUB.handle_auto_pay ( :1 ' ||
                                             ',:2 ' ||
                                             ',:3 ' ||
                                             ',:4 ' ||
                                             ',:5 ' ||
                                             ',:6 ' ||
                                            '); ' ||
      'END;';
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Calling OKL proc_after_validation');
      END IF;
      EXECUTE IMMEDIATE l_okl_block USING p_api_version, p_init_msg_list, OUT x_return_status, OUT x_msg_count, OUT x_msg_data, in_trans_req_id;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Returned from OKL proc_after_validation');
      END IF;
    EXCEPTION
      -- We ignore any error in OKL and
      -- continue the process as if OKL is not installed
      WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Exception in OKL proc_after_validation');
	END IF;
	null;
    END;
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'Y';
  ELSIF g_custom_llca_installed THEN
    /* Call the procedure for custom LLCA. */
    proc_for_custom_llca(in_trans_req_id);

    /* Ignore any error in Custom Code and proceed as if no custom code installed. */
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'Y';
  ELSE
    pvt_errorcode := 9;
    pvt_errorbuf := NULL;
    pvt_insert_records := 'N';
  END IF;

  -- Now call the public hook
  arp_lockbox_hook.proc_after_validation(pub_errorbuf,pub_errorcode,in_trans_req_id,pub_insert_records);

  IF g_second_validation_pvt AND g_second_validation_pub THEN
    IF pvt_errorcode = 0 THEN
      out_errorcode := pub_errorcode;
      out_errorbuf := pub_errorbuf;
      out_insert_records := pub_insert_records;
    ELSE
      out_errorcode := pvt_errorcode;
      out_errorbuf := pvt_errorbuf;
      out_insert_records := pvt_insert_records;
    END IF;
  ELSIF g_second_validation_pvt THEN
    out_errorcode := pvt_errorcode;
    out_errorbuf := pvt_errorbuf;
    out_insert_records := pvt_insert_records;
  ELSE
    out_errorcode := pub_errorcode;
    out_errorbuf := pub_errorbuf;
    out_insert_records := pub_insert_records;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('proc_after_validation: ' || 'arp_lockbox_hook_pvt.proc_after_validation()-');
  END IF;
END proc_after_validation;
--
/*----------------------------------------------------------------------------
   proc_after_second_validation

   This procedure will be called after the second validation and before printing
   Lockbox execution report. It is called from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that this procedure returned success.
     It will proceed with printing report then.
   If this procedure returns anything other than 0,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.

 ----------------------------------------------------------------------------*/
PROCEDURE proc_after_second_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2) IS
pvt_errorbuf varchar2(255);
pvt_errorcode varchar2(255);
pub_errorbuf varchar2(255);
pub_errorcode varchar2(255);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook_pvt.proc_after_second_validation()+');
  END IF;
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    -- Removed ARTA logic as functionality is obsolete in R12
    --  See Bug 4936298
    NULL; -- Do Nothing
  ELSIF g_okl_installed THEN
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
  ELSIF g_custom_llca_installed THEN
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
  ELSE
    pvt_errorcode := 0;
    pvt_errorbuf := NULL;
  END IF;

  -- Now call the public hook
  arp_lockbox_hook.proc_after_second_validation(pub_errorbuf,pub_errorcode,in_trans_req_id);

  IF pvt_errorcode = 0 THEN
    out_errorcode := pub_errorcode;
    out_errorbuf := pub_errorbuf;
  ELSE
    out_errorcode := pvt_errorcode;
    out_errorbuf := pvt_errorbuf;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook_pvt.proc_after_second_validation()-');
  END IF;
END proc_after_second_validation;
--
/*----------------------------------------------------------------------------
   proc_for_custom_llca  (Added for Bug 6866475)

   This procedure will be called from proc_after_validation if the setup for
   line level cash application is selected to be custom in lockbox setup.

   This procedure calls the custom package which gives the line level application
   details, which will be processed in this proc and will be inserted in lockbox
   interface tables.

 ----------------------------------------------------------------------------*/
 PROCEDURE proc_for_custom_llca(in_trans_req_id IN NUMBER) IS
l_invoice_array          invoice_array;
    l_line_array             line_array;
    l_unres_inv_array	         invoice_array;

    l_transmission_rec_id_of    number;
    l_last_invoice_index        number;
    l_last_line_index           number;
    l_unres_invoice_index       number;
    l_res_invoice_index         number;
    l_sum_amount_applied_from   number;
    l_rem_amt_applied_from      number;
    i			                number;
    j                           number;
    k                           number := 1;
    l_trans_format_id		    number;
    l_overflow_rec			    varchar2(2);
    l_transmission_id		    number;
    l_lockbox_number		    varchar2(30);
    l_batch_name			    varchar2(30);
    l_format_amount			    varchar2(2);
    l_currency_code			    varchar2(4);
    l_precision			        number;
    l_inv_precision             number;
    l_org_id			        number;
    l_overflow_seq			    number := 1;
    l_overflow_indicator		varchar2(1) := '1';
    l_final_rec_overflow_ind    varchar2(1);
    format_amount_app           varchar2(2);
    format_amount_app1          varchar2(2);
    format_amount_app2          varchar2(2);
    format_amount_app3          varchar2(2);
    format_amount_app4          varchar2(2);
    format_amount_app5          varchar2(2);
    format_amount_app6          varchar2(2);
    format_amount_app7          varchar2(2);
    format_amount_app8          varchar2(2);
    format_amount1              varchar2(2);
    format_amount2              varchar2(2);
    format_amount3              varchar2(2);
    format_amount4              varchar2(2);
    format_amount5              varchar2(2);
    format_amount6              varchar2(2);
    format_amount7              varchar2(2);
    format_amount8              varchar2(2);
    l_batches                   varchar2(1);
    l_resolved_number           number;
    l_sql_stmt                  varchar2(2000);
    l_upd_stmt                  varchar2(2000);
    l_amount_applied_from       number;
    l_trans_to_receipt_rate     number;
    l_invoice_currency_code     varchar2(15);
    l_amount_applied            number;
    l_matching_date             date;
    l_error_flag                varchar2(1);
    l_pay_unrelated_invoices    varchar2(1);
    l_customer_id               ar_payments_interface.customer_id%type;

    cursor distinct_item_num( req_id in number ) is
        select distinct item_number
        from ar_payments_interface_all
        where transmission_request_id = req_id;

    cursor overflow_records( request_id in number,
                        itm_num in number,
                        rec_type in varchar) is
        select transmission_record_id
        from ar_payments_interface_all
        where transmission_request_id = request_id
        and   item_number = itm_num
        and   record_type = rec_type
        order by transmission_record_id;

    CURSOR get_applications( req_id IN NUMBER ) IS
        SELECT  transmission_record_id,
                trim(item_number) item_number,
                trim(record_type) record_type,
                trim(invoice1) invoice1,
                trim(invoice2) invoice2,
                trim(invoice3) invoice3,
                trim(invoice4) invoice4,
                trim(invoice5) invoice5,
                trim(invoice6) invoice6,
                trim(invoice7) invoice7,
                trim(invoice8) invoice8,
                amount_applied1,
                amount_applied2,
                amount_applied3,
                amount_applied4,
                amount_applied5,
                amount_applied6,
                amount_applied7,
                amount_applied8,
                batch_name
        FROM    ar_payments_interface_all
        WHERE   transmission_request_id = req_id
        AND     record_type in ( select a.record_identifier from ar_trans_record_formats a, ar_transmissions_all b
        where b.transmission_request_id = req_id
        and   b.requested_trans_format_id = a.transmission_format_id
        and   a.record_type_lookup_code in ('PAYMENT','OVRFLW PAYMENT') );
 BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('arp_lockbox_hook_pvt.proc_for_custom_llca()+');
    END IF;
    /* Check if the format includes batches */
    BEGIN
        SELECT distinct 'Y'
        INTO   l_batches
        FROM   ar_trans_field_formats
        WHERE  transmission_format_id = (SELECT transmission_format_id
        FROM   ar_transmission_formats a,
        ar_transmissions_all b
        WHERE  a.transmission_format_id = b.requested_trans_format_id
        AND    b.transmission_request_id = in_trans_req_id )
        AND    field_type_lookup_code = 'BATCH NAME';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        arp_util.debug('No batches present in the transmission');
        l_batches := 'N';
    END;
    /* Get Pay_unrelated_invoices_Flag from ar_system_parameters */
    BEGIN
        SELECT nvl(pay_unrelated_invoices_flag, 'N')
        INTO   l_pay_unrelated_invoices
        FROM   ar_system_parameters;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_pay_unrelated_invoices := 'N';
    END;
    /* Populate the l_unres_inv_arr to be passed to the custom procedure
    with mathcing numbers to be resolved. */
    FOR app_rec IN get_applications( in_trans_req_id ) LOOP
        format_amount1 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 1');
        format_amount2 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 2');
        format_amount3 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 3');
        format_amount4 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 4');
        format_amount5 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 5');
        format_amount6 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 6');
        format_amount7 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 7');
        format_amount8 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                    app_rec.transmission_record_id,'AMT APP 8');
        format_amount_app1 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 1');
        format_amount_app2 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 2');
        format_amount_app3 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 3');
        format_amount_app4 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 4');
        format_amount_app5 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 5');
        format_amount_app6 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 6');
        format_amount_app7 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 7');
        format_amount_app8 := ARP_PROCESS_LOCKBOX.get_format_amount(in_trans_req_id,
                                app_rec.transmission_record_id,'AMT APP FROM 8');
        format_amount_app  := format_amount_app1;

        select max(fc.precision)
        into l_precision
        from fnd_currencies fc
        where fc.currency_code =
                (select max(pi.currency_code)
                from ar_payments_interface pi,
                     ar_payments_interface pi1
                where pi.item_number = pi1.item_number
                and   pi1.transmission_request_id = in_trans_req_id
                and   pi1.transmission_record_id  = app_rec.transmission_record_id);

        if app_rec.invoice1 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice1;
            if format_amount1 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                        app_rec.amount_applied1/power(10,l_precision),
                                        l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied1;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice2 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice2;
            if format_amount2 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied2/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied2;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice3 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice3;
            if format_amount3 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied3/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied3;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice4 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice4;
            if format_amount4 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied4/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied4;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice5 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice5;
            if format_amount5 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied5/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied5;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice6 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice6;
            if format_amount6 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied6/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied6;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice7 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice7;
            if format_amount7 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied7/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied7;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

        if app_rec.invoice8 is not null then
            l_unres_inv_array(k).item_number := app_rec.item_number;
            l_unres_inv_array(k).matching_number := app_rec.invoice8;
            if format_amount8 = 'Y' then
                l_unres_inv_array(k).amount_applied := round(
                                    app_rec.amount_applied8/power(10,l_precision),
                                    l_precision);
            else
                l_unres_inv_array(k).amount_applied := app_rec.amount_applied8;
            end if;
            l_unres_inv_array(k).invoice_number := NULL;
            l_unres_inv_array(k).batch_name := app_rec.batch_name;
            l_unres_inv_array(k).record_type := app_rec.record_type;
            k := k + 1;
        end if;

    END LOOP;

	/* Calling the custom code to return the resolved matching numbers and LLCA Data. */
	ARP_LOCKBOX_HOOK.cursor_for_custom_llca(l_unres_inv_array,
                                            l_invoice_array,
                                            l_line_array);

	l_last_invoice_index   := l_invoice_array.last;
	l_unres_invoice_index  := l_unres_inv_array.last;

    IF l_unres_invoice_index IS NOT NULL THEN
    IF l_last_invoice_index IS NOT NULL THEN

        SELECT overflow_rec_indicator
        INTO   l_overflow_indicator
        FROM   ar_trans_field_formats a, ar_transmissions_all b
        WHERE  b.requested_trans_format_id = a.transmission_format_id
        AND    b.transmission_request_id   = in_trans_req_id
        AND    a.FIELD_TYPE_LOOKUP_CODE	   = 'OVRFLW IND';

        IF l_overflow_indicator = '0' THEN
            l_final_rec_overflow_ind := '1';
        ELSE
            l_final_rec_overflow_ind := '0';
        END IF;

        SELECT  b.record_identifier,
                b.transmission_format_id,
                a.transmission_id
        INTO    l_overflow_rec, l_trans_format_id, l_transmission_id
        FROM    ar_transmissions_all a,
                ar_trans_record_formats b
        WHERE   a.requested_trans_format_id = b.transmission_format_id
        AND     a.transmission_request_id = in_trans_req_id
        AND     b.record_type_lookup_code = 'OVRFLW PAYMENT';

    /*
    * The logic below is like this. For each (matching) number in unresolved array we check   *
    * if it has been resolved. If so, we popualte the resolved array for all those            *
    * (resolved) numbers. If they pass through cross currency validations, if this a cross    *
    * currency application, then a record is inserted into ar_payments_interface              *
    * for each resolved number along with their line level details in ar_pmts_                *
    * interface_line_details, if any. If a record failed in validation then  a record is      *
    * inserted into ar_payments_interface for the matching number, which would eventually fail*
    * in validation.
    */
        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Number of Invoices inside custom code :' || l_last_invoice_index);
        END IF;
        FOR i in 1..l_unres_invoice_index LOOP
            k := 1;
            DECLARE
                l_resolved_array         invoice_array;
            BEGIN
            FOR j in 1..l_last_invoice_index LOOP
                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('For '|| l_unres_inv_array(i).matching_number);
                  arp_util.debug('And '|| l_invoice_array(j).matching_number);
                  arp_util.debug('And '|| l_invoice_array(j).invoice_number);
                  arp_util.debug('Size :'||l_resolved_array.last || 'K :' ||k);
                END IF;
                IF l_unres_inv_array(i).matching_number = l_invoice_array(j).matching_number
                AND l_unres_inv_array(i).item_number = l_invoice_array(j).item_number THEN
                    IF l_batches = 'Y' THEN
                        IF l_unres_inv_array(i).batch_name = l_invoice_array(j).batch_name THEN
                        l_resolved_array(k).matching_number := l_invoice_array(j).matching_number;
                        l_resolved_array(k).item_number := l_invoice_array(j).item_number;
                        l_resolved_array(k).invoice_number := l_invoice_array(j).invoice_number;
                        l_resolved_array(k).amount_applied := l_invoice_array(j).amount_applied;
                        l_resolved_array(k).amount_applied_from := l_invoice_array(j).amount_applied_from;
                        l_resolved_array(k).trans_to_receipt_rate := l_invoice_array(j).trans_to_receipt_rate;
                        l_resolved_array(k).invoice_currency_code := l_invoice_array(j).invoice_currency_code;
                        l_resolved_array(k).batch_name := l_invoice_array(j).batch_name;
                        k := k+1;
                        END IF;
                    ELSE
                        l_resolved_array(k).matching_number := l_invoice_array(j).matching_number;
                        l_resolved_array(k).item_number := l_invoice_array(j).item_number;
                        l_resolved_array(k).invoice_number := l_invoice_array(j).invoice_number;
                        l_resolved_array(k).amount_applied := l_invoice_array(j).amount_applied;
                        l_resolved_array(k).amount_applied_from := l_invoice_array(j).amount_applied_from;
                        l_resolved_array(k).trans_to_receipt_rate := l_invoice_array(j).trans_to_receipt_rate;
                        l_resolved_array(k).invoice_currency_code := l_invoice_array(j).invoice_currency_code;
                        l_resolved_array(k).batch_name := l_invoice_array(j).batch_name;
                        k := k+1;
                    END IF; /* End l_batches */
                END IF; /* End Populate Resolved Array */
            END LOOP; /* End inner For */
        l_res_invoice_index := l_resolved_array.last;
        l_inv_precision     := 0;

        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Custom Number '||l_unres_inv_array(i).matching_number||' has been resolved into ');
          arp_util.debug(nvl(l_res_invoice_index, 0)||' invoices.');
        END IF;

        IF  l_res_invoice_index IS NOT NULL THEN
            SELECT a
            INTO  l_resolved_number
            FROM
                (SELECT decode(l_unres_inv_array(i).matching_number,
                                invoice1, 1,
                                invoice2, 2,
                                invoice3, 3,
                                invoice4, 4,
                                invoice5, 5,
                                invoice6, 6,
                                invoice7, 7,
                                invoice8, 8) a
                FROM  ar_payments_interface_all
                WHERE transmission_request_id = in_trans_req_id
                AND   item_number	     = l_unres_inv_array(i).item_number
                AND   record_type        = l_unres_inv_array(i).record_type
                AND   NVL(batch_name, -1)= NVL(l_unres_inv_array(i).batch_name, -1))
            where a IS NOT NULL;

            l_sql_stmt := 'SELECT amount_applied_from'||l_resolved_number||', trans_to_receipt_rate'
            ||l_resolved_number||', invoice_currency_code'||l_resolved_number||', customer_id'
            ||', amount_applied'||l_resolved_number||', matching'||l_resolved_number||'_date'
            ||' FROM ar_payments_interface_all WHERE transmission_request_id = :1'
            ||' AND item_number = :2'
            ||' AND record_type = :3'
            ||' AND invoice'||l_resolved_number ||'= :4'
            ||' AND NVL(batch_name, -1) = :5';

            EXECUTE IMMEDIATE l_sql_stmt
            INTO   l_amount_applied_from,
            l_trans_to_receipt_rate,
            l_invoice_currency_code,
            l_customer_id,
            l_amount_applied,
            l_matching_date
            USING  in_trans_req_id,
            l_unres_inv_array(i).item_number,
            l_unres_inv_array(i).record_type,
            l_unres_inv_array(i).matching_number,
            nvl(l_unres_inv_array(i).batch_name, -1);

            IF l_resolved_number = 1 AND format_amount_app1 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 2 AND format_amount_app2 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 3 AND format_amount_app3 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 4 AND format_amount_app4 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 5 AND format_amount_app5 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 6 AND format_amount_app6 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 7 AND format_amount_app7 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            ELSIF l_resolved_number = 8 AND format_amount_app8 = 'Y' THEN
                l_amount_applied_from := round(
                                l_amount_applied_from/power(10,l_precision),
                                l_precision);
            END IF;


            IF l_invoice_currency_code IS NOT NULL
            OR l_trans_to_receipt_rate IS NOT NULL
            OR l_amount_applied_from IS NOT NULL THEN
            /* In case where Invoice_currency_code and/or trans_to_receipt_rate is mentioned at
            the matching number, then they should be the same at the resolved numbers also */
            FOR j IN 1..l_res_invoice_index LOOP
            IF (l_trans_to_receipt_rate IS NOT NULL
                AND l_resolved_array(j).trans_to_receipt_rate IS NOT NULL
                AND l_trans_to_receipt_rate <> l_resolved_array(j).trans_to_receipt_rate) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Trans_to_receipt_rate cannot be different to the rate specified at the matching number.');
                  arp_util.debug('For Matching Number '||l_unres_inv_array(i).matching_number);
                  arp_util.debug('For Resolved Number '||l_resolved_array(j).invoice_number);
                END IF;
                l_error_flag := 'T';
                exit;
            END IF; /* End TTR check */
            IF (l_invoice_currency_code IS NOT NULL
                AND l_resolved_array(j).invoice_currency_code IS NOT NULL
                AND l_invoice_currency_code <> l_resolved_array(j).invoice_currency_code) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Invoice currency code cannot be different to the currency code specified at the matching number.');
                  arp_util.debug('For Matching Number '||l_unres_inv_array(i).matching_number);
                  arp_util.debug('For Resolved Number '||l_resolved_array(j).invoice_number);
                END IF;
                l_error_flag := 'T';
                exit;
            END IF; /* End currency code check */
            END LOOP;

            /* In any case if amount_applied_from/invoice_currency_code/trans_to_receipt_rate is mentioned
            at the header level then all the resolved numbers matching this number must be of the same
            currency(= invoice_currency_code at the matching number, if provided) */

            DECLARE
                l_res_currency_code VARCHAR2(15);
                l_currency_code1    VARCHAR2(15);
            BEGIN
                l_res_currency_code := trim(l_invoice_currency_code);
                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('For Matching Number '||l_unres_inv_array(i).matching_number);
                  arp_util.debug('Currency Code '||l_res_currency_code);
                END IF;
                FOR j in 1..l_res_invoice_index LOOP
                    SELECT  distinct(invoice_currency_code)
                    INTO    l_currency_code1
                    FROM    ar_payment_schedules ps,
                            ra_cust_trx_types    tt
                    WHERE   ps.trx_number = l_resolved_array(j).invoice_number
                    AND     ps.trx_date = nvl(l_matching_date, ps.trx_date)
                    AND     ps.status = decode(tt.allow_overapplication_flag,
                                                'N', 'OP',
                                                ps.status)
                    AND     ps.class NOT IN ('PMT','GUAR')
                    AND     (ps.customer_id  IN
                    (
                    select l_customer_id from dual
                    union
                    select related_cust_account_id
                    from   hz_cust_acct_relate rel
                    where  rel.cust_account_id = l_customer_id
                    and    rel.status = 'A'
                    and    rel.bill_to_flag = 'Y'
                    union
                    select rel.related_cust_account_id
                    from   ar_paying_relationships_v rel,
                    hz_cust_accounts acc
                    where  rel.party_id = acc.party_id
                    and    acc.cust_account_id = l_customer_id
                    )
                    or
                    l_pay_unrelated_invoices = 'Y'
                    )
                    AND     ps.cust_trx_type_id = tt.cust_trx_type_id;

                    l_resolved_array(j).invoice_currency_code := trim(l_currency_code1);
                    l_res_currency_code := nvl(l_res_currency_code, trim(l_currency_code1));

                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('For Resolved Number '||l_resolved_array(j).invoice_number);
                      arp_util.debug('Currency Code '|| l_currency_code1);
                    END IF;
                    IF l_res_currency_code <> trim(l_currency_code1) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                          arp_util.debug('All Resolved invoices does not belong to the same currency for matching number '||l_invoice_array(i).matching_number);
                        END IF;
                        l_error_flag := 'T';
                    exit;
                    END IF;
                    l_invoice_currency_code := trim(l_currency_code1);
                END LOOP;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Invalid Application Number '||l_resolved_array(j).invoice_number);
                    END IF;
                    l_error_flag := 'T';
                    WHEN TOO_MANY_ROWS THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Too many applications exist with name '||l_resolved_array(j).invoice_number);
                    END IF;
                    l_error_flag := 'T';
                    WHEN OTHERS THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Exception occured in resolving '||l_resolved_array(j).invoice_number);
                      arp_util.debug('Error Message '||SQLERRM);
                    END IF;
                    l_error_flag := 'T';
            END;  /* End check currency code when not provided */

            IF l_error_flag <> 'T' AND l_invoice_currency_code IS NOT NULL THEN
                SELECT decode(format_amount_app, 'Y', d.precision, 0)
                INTO   l_inv_precision
                FROM   fnd_currencies d
                WHERE  d.currency_code = trim(l_invoice_currency_code);
            END IF;

            /* If amount_applied_from is mentioned at both the matching number and resolved number
            then sum of amount_applied_from's at the resolved numbers must be equal to the amount
            _applied_from at the mathcing number */
            IF l_amount_applied_from IS NOT NULL THEN
                FOR j in 1..l_res_invoice_index LOOP
                    l_sum_amount_applied_from := l_sum_amount_applied_from +
                                nvl(l_resolved_array(j).amount_applied_from, 0);
                END LOOP;
                IF l_sum_amount_applied_from <> 0
                    AND l_sum_amount_applied_from <> l_amount_applied_from THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Sum of amount_applied_from at the resolved invoices is not equal to the amount_applied_from specified at matching number.');
                      arp_util.debug('For Matching Number '||l_unres_inv_array(i).matching_number);
                    END IF;
                    l_error_flag := 'T';
                END IF;
            END IF;/* Check Sum of amount_applied_from */

            /* Prorate Amount_applied_from to the resolved invoices if not provided in custom hook */
            l_rem_amt_applied_from := nvl(l_amount_applied_from, 0);
                IF l_error_flag <> 'T' THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Amount_applied_From '||l_amount_applied_from);
                    END IF;
                If l_amount_applied_from IS NOT NULL THEN
                FOR j in 1..l_res_invoice_index LOOP
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Prorating Amount_applied_from');
                    END IF;
                    IF l_resolved_array(j).amount_applied_from IS NULL THEN
                        l_resolved_array(j).amount_applied_from := ROUND(
                            (l_resolved_array(j).amount_applied/l_amount_applied)
                            *l_amount_applied_from);
                    l_rem_amt_applied_from := l_rem_amt_applied_from -
                                        l_resolved_array(j).amount_applied_from;
                    END IF;
                END LOOP;
                l_resolved_array(l_res_invoice_index).amount_applied_from :=
                    l_resolved_array(l_res_invoice_index).amount_applied_from
                                            + l_rem_amt_applied_from;
                END IF;
                END IF;/* End prorate amount_applied_from */

            END IF;/* End all validations */

            IF l_error_flag = 'T' THEN

                SELECT ar_payments_interface_s.nextval
                INTO l_transmission_rec_id_of
                FROM dual;

                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Validation failed for '||l_unres_inv_array(i).matching_number);
                END IF;

                /* The Exchange rate info provided at the matching number level does not match
                with the details provided at the resolved invoice level. So insert the Custom
                number into the interface tables instead of resolved numbers as an invalid
                application. */

                l_upd_stmt := 'UPDATE ar_payments_interface_all'
                ||' SET invoice'||l_resolved_number||'status = ''AR_PLB_INVALID_MATCH'''
                ||' WHERE transmission_request_id = :1 AND item_number = :2'
                ||' AND record_type = :3'
                ||' AND invoice'||l_resolved_number ||'= :4'
                ||' AND NVL(batch_name, -1) = :5';

                EXECUTE IMMEDIATE l_upd_stmt
                USING in_trans_req_id,
                l_unres_inv_array(i).item_number,
                l_unres_inv_array(i).record_type,
                l_unres_inv_array(i).matching_number,
                nvl(l_unres_inv_array(i).batch_name, -1);

            ELSE
                l_upd_stmt := 'UPDATE ar_payments_interface_all'
                ||' SET invoice'||l_resolved_number||' = NULL'
                ||', amount_applied'||l_resolved_number||' = NULL'
                ||' WHERE transmission_request_id = :1 AND item_number = :2'
                ||' AND record_type = :3'
                ||' AND invoice'||l_resolved_number ||'= :4'
                ||' AND NVL(batch_name, -1) = :5';

                EXECUTE IMMEDIATE l_upd_stmt
                USING in_trans_req_id,
                l_unres_inv_array(i).item_number,
                l_unres_inv_array(i).record_type,
                l_unres_inv_array(i).matching_number,
                nvl(l_unres_inv_array(i).batch_name, -1);

                SELECT	a.org_id,
                a.lockbox_number,
                a.batch_name,
                a.currency_code,
                decode(format_amount1,'Y',d.precision,0)
                INTO    l_org_id, l_lockbox_number, l_batch_name, l_currency_code, l_precision
                FROM    ar_payments_interface_all a,
                        ar_transmissions_all b,
                        ar_trans_record_formats c,
                        fnd_currencies d
                WHERE   a.transmission_request_id = b.transmission_request_id
                AND	    b.requested_trans_format_id = c.transmission_format_id
                AND     c.record_identifier = a.record_type
                AND     d.currency_code = a.currency_code
                AND     a.transmission_request_id = in_trans_req_id
                AND	    c.record_type_lookup_code = 'PAYMENT'
                AND     a.item_number = l_unres_inv_array(i).item_number
                AND     NVL(a.batch_name, -1) = NVL(l_unres_inv_array(i).batch_name, -1);

                IF format_amount_app <> 'Y' THEN
                    l_inv_precision := 0;
                END IF;

                FOR j in 1..l_res_invoice_index LOOP

                SELECT ar_payments_interface_s.nextval
                INTO l_transmission_rec_id_of
                FROM dual;

                /* Insert a new overflow record for the new invoice number resolved. */
                INSERT INTO ar_payments_interface_all(
                            transmission_record_id,
                            item_number,
                            record_type,
                            status,
                            transmission_id,
                            transmission_request_id,
                            lockbox_number,
                            batch_name,
                            invoice1,
                            amount_applied1,
                            amount_applied_from1,
                            trans_to_receipt_rate1,
                            invoice_currency_code1,
                            org_id,
                            creation_date,
                            last_update_date)
                VALUES(
                            l_transmission_rec_id_of,
                            l_resolved_array(j).item_number,
                            l_overflow_rec,
                            'AR_PLB_NEW_RECORD',
                            l_transmission_id,
                            in_trans_req_id,
                            l_lockbox_number,
                            l_batch_name,
                            l_resolved_array(j).invoice_number,
                            l_resolved_array(j).amount_applied * power(10,l_inv_precision),
                            l_resolved_array(j).amount_applied_from * power(10,l_precision),
                            nvl(l_resolved_array(j).trans_to_receipt_rate,
                            l_trans_to_receipt_rate),
                            trim(nvl(l_resolved_array(j).invoice_currency_code,
                            l_invoice_currency_code)),
                            l_org_id,
                            sysdate,
                            trunc(sysdate));

                l_last_line_index := l_line_array.last;
                /* Check for any line details poulated in the line details table. */
                IF l_last_line_index IS NOT NULL THEN
                /* Transfer the line level details to the interface_table. */
                    FOR k IN 1..l_last_line_index LOOP
                    IF  l_resolved_array(j).invoice_number = l_line_array(k).invoice_number
                        AND l_resolved_array(j).item_number = l_line_array(k).item_number
                        AND NVL(l_resolved_array(j).batch_name, -1) = NVL(l_line_array(k).batch_name, -1)THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                      arp_util.debug('Inserting lines for '|| l_resolved_array(j).invoice_number);
                    END IF;
                    INSERT INTO  AR_PMTS_INTERFACE_LINE_DETAILS (
                        status,
                        transmission_request_id,
                        transmission_record_id,
                        invoice_number,
                        apply_to,
                        amount_applied,
                        allocated_receipt_amount,
                        line_amount,
                        tax,
                        freight,
                        charges )
                    VALUES (
                        'AR_PLB_NEW_RECORD',
                        in_trans_req_id,
                        l_transmission_rec_id_of,
                        l_line_array(k).invoice_number,
                        l_line_array(k).apply_to,
                        l_line_array(k).amount_applied,
                        l_line_array(k).allocated_receipt_amount,
                        l_line_array(k).line_amount,
                        l_line_array(k).tax_amount,
                        l_line_array(k).freight,
                        l_line_array(k).charges
                    );
                    END IF;
                    END LOOP;
                END IF;	 /* Insert line Records */
                END LOOP; /* Insert Resolved Records */
            END IF; /* Insert Overflow records */
        END IF; /* End Process Resolved records */
        END;
    END LOOP; /* End Outer For */

    /* Delete the old overflow records for all the receipts, where all the matching numbers in
    the overflow record are resolved in custom code i.e, no use in having overflow
    records with all invoice1 to invoice8 columns null. */

    delete from ar_payments_interface_all
    where transmission_request_id = in_trans_req_id
    and invoice1 is null
    and invoice2 is null
    and invoice3 is null
    and invoice4 is null
    and invoice5 is null
    and invoice6 is null
    and invoice7 is null
    and invoice8 is null
    and record_type = l_overflow_rec;

    /* Update the interface table overflow records for correct overflow sequence and
    indicators value. */

    FOR item_num IN distinct_item_num( in_trans_req_id ) LOOP
    l_overflow_seq := 1;
    FOR record_id IN overflow_records(in_trans_req_id, item_num.item_number, l_overflow_rec ) LOOP
    update ar_payments_interface_all
    set     overflow_sequence = l_overflow_seq,
    overflow_indicator = l_overflow_indicator
    where   transmission_record_id = record_id.transmission_record_id;

    l_overflow_seq := l_overflow_seq + 1;
    END LOOP;

    /* Overflow the last overflow record's overflow indicator to indicate
    there are no more further overflow records for the receipt. */

    update ar_payments_interface_all
    set 	 overflow_indicator = l_final_rec_overflow_ind
    where  transmission_record_id = (
        select max(transmission_record_id)
        from   ar_payments_interface_all
        where  transmission_request_id = in_trans_req_id
        and    item_number = item_num.item_number
        and    record_type = l_overflow_rec );
    END LOOP;

    /* Update the transmission record count with correct value if there are
    transmission header or trailer records in the transmission. */

    update  ar_payments_interface_all
    set     transmission_record_count = (
        select count(*) from ar_payments_interface_all
        where  transmission_request_id = in_trans_req_id )
        where   transmission_request_id = in_trans_req_id
        and     record_type in ( select a.record_identifier
        from ar_trans_record_formats a, ar_transmissions_all b
        where  b.transmission_request_id = in_trans_req_id
        and    b.requested_trans_format_id = a.transmission_format_id
        and    a.record_type_lookup_code in ('TRANS HDR','TRANS TRL') );

    END IF;
    END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('arp_lockbox_hook_pvt.proc_for_custom_llca()-');
	END IF;
 EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
			arp_util.debug('Exception in proc_for_custom_llca');
			arp_util.debug('Error : '||SQLERRM);
		END IF;
		RAISE;
 END proc_for_custom_llca;
--
END arp_lockbox_hook_pvt;

/
