--------------------------------------------------------
--  DDL for Package Body POS_CANCEL_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_CANCEL_ASN" AS
/* $Header: POSASNCB.pls 120.4 2006/08/14 20:27:18 pkapoor noship $*/

/** Local Procedure Definition **/

PROCEDURE remove_from_interface (
	p_shipment_num		IN 	VARCHAR2,
 	p_vendor_id		IN	NUMBER,
	p_vendor_site_id	IN	NUMBER,
 	p_result		IN OUT NOCOPY 	NUMBER,
 	p_error_code		IN OUT NOCOPY 	VARCHAR2 );

PROCEDURE cancel_invoice (
	p_invoice_id 		IN 	NUMBER );

PROCEDURE cancel_asn_line (
	p_shipment_line_id 	IN 	NUMBER,
	p_vendor_id		IN 	NUMBER,
	p_error_code		IN OUT NOCOPY 	VARCHAR2 );

PROCEDURE cancel_invoice_new (
	p_invoice_id 		IN	NUMBER,
	p_set_of_books_id	IN	NUMBER,
	p_gl_date		IN	DATE,
	P_period_name		IN	VARCHAR2 );

PROCEDURE cancel_invoice_old (
	p_invoice_id 		IN	NUMBER,
	p_set_of_books_id	IN	NUMBER,
	p_gl_date		IN	DATE,
	P_period_name		IN	VARCHAR2 );


--
-- Procedure that cancels the specific shipment.
--
PROCEDURE cancel_asn  (
	p_shipment_num		IN 	VARCHAR2,
        p_invoice_num		IN	VARCHAR2,
        p_processing_status	IN	VARCHAR2,
 	p_vendor_id		IN	NUMBER,
	p_vendor_site_id	IN	NUMBER,
 	p_result		IN OUT NOCOPY 	NUMBER,
 	p_error_code		IN OUT NOCOPY 	VARCHAR2 )
IS

   l_count		NUMBER := 0;
   l_receipt_count	NUMBER := 0;  -- Number of receipts created
   l_shipment_line_id	NUMBER := NULL;
   l_invoice_id		NUMBER := NULL;
   l_org_id		NUMBER := NULL;

   CURSOR c_asn_line IS
     select  rsl.shipment_line_id
       from  RCV_SHIPMENT_LINES rsl,
             RCV_SHIPMENT_HEADERS rsh
      where  rsh.shipment_num = p_shipment_num
        and  rsh.shipment_header_id = rsl.shipment_header_id
	and  rsh.vendor_id = p_vendor_id
	and  rsh.vendor_site_id = p_vendor_site_id;

   CURSOR c_invoice IS
     select  invoice_id, org_id
       from  AP_INVOICES_ALL
      where  invoice_num = p_invoice_num
        and  vendor_id = p_vendor_id
	and  vendor_site_id = p_vendor_site_id;

BEGIN

   IF (p_processing_status = 'PENDING' or p_processing_status = 'ERROR') THEN

      BEGIN

        POS_ASN_NOTIF.generate_notif (	p_shipment_num,
					'CANCEL',
					p_vendor_id,
					p_vendor_site_id,
					fnd_global.user_id );

      EXCEPTION
        WHEN OTHERS THEN
          p_result := 0;
          p_error_code := 'POS_CANCEL_NOTIF_ERROR';
          raise;
      END;

      remove_from_interface( p_shipment_num,
			     p_vendor_id,
			     p_vendor_site_id,
			     p_result,
			     p_error_code );
      p_result := 1;
      return;
   END IF;


   -- Check if shipment already exists in Maintain Shipments view
   select count(*)
     into l_count
     from RCV_SHIPMENT_HEADERS
    where shipment_num = p_shipment_num
      and vendor_id = p_vendor_id
      and vendor_site_id = p_vendor_site_id;

   if (l_count = 0) then
      p_result := 0;
      p_error_code := 'POS_ASN_NOT_FOUND';
      return;
   END IF;

   -- Check if any receipts have been recorded.
   select count(*)
     into l_receipt_count
     from rcv_shipment_headers
    where shipment_num = p_shipment_num
      and vendor_id = p_vendor_id
      and vendor_site_id = p_vendor_site_id
      and receipt_num is not null;

   IF (l_receipt_count > 0) THEN
      p_result := 0;
      p_error_code := 'POS_ASN_RECEIPT_EXIST';
      return;
   END IF;


   OPEN c_asn_line;
   LOOP
     FETCH c_asn_line INTO l_shipment_line_id;
     EXIT WHEN c_asn_line%NOTFOUND;

     if get_line_status(l_shipment_line_id) = 'OK' then
        cancel_asn_line(l_shipment_line_id,
			p_vendor_id,
			p_error_code );
     end if;
   END LOOP;
   CLOSE c_asn_line;

   -- Cancel invoice in case of ASBN
   if (p_invoice_num is not null) then
      OPEN c_invoice;
      LOOP
        FETCH c_invoice INTO l_invoice_id, l_org_id;
        EXIT WHEN c_invoice%NOTFOUND;

        if (l_invoice_id is not null) then
           --fnd_client_info.set_org_context(to_char(l_org_id));
           PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
           cancel_invoice(l_invoice_id);
        end if;

      END LOOP;
      CLOSE c_invoice;
   end if;

   BEGIN
     POS_ASN_NOTIF.generate_notif( p_shipment_num,
				   'CANCEL',
				   p_vendor_id,
				   p_vendor_site_id,
				   fnd_global.user_id );

   EXCEPTION
   WHEN OTHERS THEN
      p_result := 0;
      p_error_code := 'POS_CANCEL_NOTIF_ERROR';
      raise;
   END;

   p_result := 1;
   commit;

   EXCEPTION
     WHEN OTHERS THEN
       p_result := 0;
       p_error_code := 'POS_ASN_CANCEL_EXCEPTION';
       raise;
END cancel_asn;


--
-- Get the processing status of the entire ASN entry
--
FUNCTION get_processing_status  (
	p_shipment_num		VARCHAR2,
 	p_vendor_id		NUMBER,
	p_vendor_site_id	NUMBER	)
return VARCHAR2 IS

   l_asn_status		varchar2(25) := NULL;
   l_processing_status	varchar2(25) := NULL;
   l_transaction_type	varchar2(25) := NULL;
   l_total_count	NUMBER := 0;
   l_pending_count	NUMBER := 0;
   l_success_count	NUMBER := 0;
   l_error_count	NUMBER := 0;
   l_rsl_line_count NUMBER := 0;

   CURSOR c_ASN_status IS
     select  processing_status_code, transaction_type
       from  RCV_HEADERS_INTERFACE
      where  shipment_num = p_shipment_num
        and  vendor_id = p_vendor_id
        and  vendor_site_id = p_vendor_site_id;

BEGIN

    OPEN c_ASN_status;
    LOOP
      FETCH c_ASN_status INTO l_processing_status, l_transaction_type;
      EXIT WHEN c_ASN_status%NOTFOUND;

      l_total_count := l_total_count + 1;

      -- Status is RUNNING if any header status is running.
      if (l_processing_status = 'RUNNING') then
         l_asn_status := 'RUNNING';
         exit;
      end if;

      if (l_processing_status = 'PENDING' and l_transaction_type = 'NEW') then
         l_pending_count := l_pending_count + 1;
      elsif (l_processing_status = 'ERROR' and l_transaction_type = 'NEW') then
         l_error_count := l_error_count + 1;
      elsif (l_processing_status = 'SUCCESS' and l_transaction_type = 'NEW') then
         l_success_count := l_success_count + 1;
      end if;

    END LOOP;
    CLOSE c_ASN_status;

    if (l_asn_status = 'RUNNING' or l_total_count = 0) then
       return l_asn_status;
    end if;

    if (l_error_count = l_total_count) then  --All are in error
       l_asn_status := 'ERROR';
    elsif (l_pending_count + l_error_count = l_total_count) then
       l_asn_status := 'PENDING';
    elsif (l_success_count = l_total_count) then
       BEGIN
       -- fix for bug 3358908
       -- for "successful" ASNs make sure that there exists at least one record in rcv_shipment_lines
       select count(*)
       into l_rsl_line_count
       from rcv_shipment_lines
       where shipment_header_id in
             (select shipment_header_id from rcv_shipment_headers
              where shipment_num = p_shipment_num
              and vendor_id = p_vendor_id and vendor_site_id = p_vendor_site_id);

       if (l_rsl_line_count > 0) then
         l_asn_status := 'SUCCESS';
       else
         l_asn_status := 'ERROR';
       end if;
       END;
    else
       l_asn_status := 'MULTIPLE';
    end if;

    return l_asn_status;

    EXCEPTION
      WHEN OTHERS THEN
        raise;
END get_processing_status;


--
-- For unprocessed ASN or ASN in error, the cancellation will
-- directly remove the relevant records from interface tables.
--
PROCEDURE remove_from_interface (
	p_shipment_num		IN 	VARCHAR2,
	p_vendor_id		IN 	NUMBER,
	p_vendor_site_id	IN 	NUMBER,
 	p_result		IN OUT NOCOPY 	NUMBER,
 	p_error_code		IN OUT NOCOPY 	VARCHAR2 )
IS

   x_header_interface_id	NUMBER;

   CURSOR C_header_interface IS
     select header_interface_id
       from rcv_headers_interface
      where shipment_num = p_shipment_num
        and vendor_id = p_vendor_id
        and vendor_site_id = p_vendor_site_id;

   /* FPJ ASN attachment */
   l_asn_attach_id		NUMBER;
   l_return_status 		VARCHAR2(1);
   l_msg_count     		number;
   l_msg_data      		varchar2(2400);


   CURSOR C_asn_attach (l_header_intf_id NUMBER) IS
     select distinct rti.asn_attach_id
       from rcv_transactions_interface rti,
            fnd_attached_documents fad
      where rti.header_interface_id = l_header_intf_id
        and rti.asn_attach_id is not null
        and to_char(rti.asn_attach_id) = fad.PK1_value
        and fad.entity_name = 'ASN_ATTACH';


BEGIN

   -- Delete records in transaction interface table.
   OPEN C_header_interface;
   LOOP
     FETCH c_header_interface INTO x_header_interface_id;
     EXIT WHEN c_header_interface%NOTFOUND;

     if (x_header_interface_id is not null) then

        /* Delete ASN attachment if exists. */
        OPEN C_asn_attach (x_header_interface_id);
        LOOP
          FETCH C_asn_attach INTO l_asn_attach_id;
          EXIT WHEN C_asn_attach%NOTFOUND;

          if (l_asn_attach_id is not null) then

            RCV_ASN_ATTACHMENT_PKG.delete_line_attachment (
		p_api_version 	=> 1.0,
		p_init_msg_list => 'F',
		x_return_status	=> l_return_status,
		x_msg_count	=> l_msg_count,
		x_msg_data	=> l_msg_data,
		p_asn_attach_id => l_asn_attach_id );

          end if;

        END LOOP;
        CLOSE C_asn_attach;

        /* Delete ASN line from interface table. */
        delete
          from RCV_TRANSACTIONS_INTERFACE
         where header_interface_id = x_header_interface_id;

     end if;

   END LOOP;
   CLOSE C_header_interface;

   -- Delete records in header interface table.
   delete
     from RCV_HEADERS_INTERFACE
    where shipment_num = p_shipment_num
      and vendor_id = p_vendor_id
      and vendor_site_id = p_vendor_site_id;

   p_result := 1;
   commit;

    EXCEPTION
      WHEN OTHERS THEN
        raise;
END remove_from_interface;


--
-- Get the cancellation status of the whole ASN entry.
--
FUNCTION get_cancellation_status (
	p_shipment_num		VARCHAR2,
 	p_vendor_id		NUMBER,
	p_vendor_site_id	NUMBER	)
RETURN VARCHAR2 IS

   x_total_lines	NUMBER := 0;
   x_cancelled_lines	NUMBER := 0;
   x_pending_cancel	NUMBER := 0;

BEGIN

   /* Get total number of lines */
   select count(*)
     into x_total_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id;

   if (x_total_lines = 0) then
      return '';
   end if;

   /* Get total number of cancelled lines */
   select count(*)
     into x_cancelled_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id
      and rsl.shipment_line_status_code = 'CANCELLED';

   /* Get total number of lines pending cancellation */
   select count(*)
     into x_pending_cancel
     from RCV_TRANSACTIONS_INTERFACE rti,
          RCV_SHIPMENT_HEADERS rsh
    where rti.transaction_type = 'CANCEL'
      and rti.shipment_header_id = rsh.shipment_header_id
      and rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rti.processing_status_code ='PENDING'; /*4946276 : Performance fix and */
                 /*we should consider only the lines which are not yet processed*/

   if (x_total_lines = x_cancelled_lines) then
      return 'CANCELLED';
   elsif (x_total_lines = x_cancelled_lines + x_pending_cancel) then
      return 'PENDING_CANCEL';
   elsif ((x_total_lines > x_cancelled_lines + x_pending_cancel)
          and (x_cancelled_lines + x_pending_cancel > 0)) then
      return 'PARTIALLY_CANCELLED';
   else
      return '';
   end if;

   EXCEPTION
     WHEN OTHERS THEN
       raise;
END get_cancellation_status;


PROCEDURE find_processing_cancellation (
       p_shipment_num  IN      VARCHAR2,
       p_header_id IN NUMBER,
       p_vendor_id     IN      NUMBER,
       p_vendor_site_id   IN   NUMBER,
       x_processing_status OUT NOCOPY VARCHAR2,
       x_processing_dsp OUT NOCOPY VARCHAR2,
       x_cancellation_status OUT NOCOPY VARCHAR2,
       x_cancellation_dsp OUT NOCOPY VARCHAR2) is

   l_asn_status		varchar2(25) := NULL;
   l_processing_status	varchar2(25) := NULL;
   l_transaction_type	varchar2(25) := NULL;
   l_rti_error    varchar2(1) := NULL;
   l_total_count	NUMBER := 0;
   l_pending_count	NUMBER := 0;
   l_success_count	NUMBER := 0;
   l_error_count	NUMBER := 0;
   l_rsl_line_count  NUMBER := 0;
   l_rti_line_count  NUMBER := 0;


   CURSOR c_ASN_status IS
     select  processing_status_code, transaction_type
       from  RCV_HEADERS_INTERFACE
      where  shipment_num = p_shipment_num
       and header_interface_id = p_header_id
        and  vendor_id = p_vendor_id
        and  vendor_site_id = p_vendor_site_id;

   l_total_lines	NUMBER := 0;
   l_cancelled_lines	NUMBER := 0;
   l_pending_cancel	NUMBER := 0;

BEGIN

    OPEN c_ASN_status;
    LOOP
      FETCH c_ASN_status INTO l_processing_status, l_transaction_type;
      EXIT WHEN c_ASN_status%NOTFOUND;

      l_total_count := l_total_count + 1;

      -- Status is RUNNING if any header status is running.
      if (l_processing_status = 'RUNNING') then
         l_asn_status := 'RUNNING';
         exit;
      end if;

      if (l_processing_status = 'PENDING' and l_transaction_type = 'NEW') then
         l_pending_count := l_pending_count + 1;
      elsif (l_processing_status = 'ERROR' and l_transaction_type = 'NEW') then
         l_error_count := l_error_count + 1;
      elsif (l_processing_status = 'SUCCESS' and l_transaction_type = 'NEW') then
         l_success_count := l_success_count + 1;
      end if;

    END LOOP;
    CLOSE c_ASN_status;


    if (l_total_count = 0) then

	select count(*)
	into l_rsl_line_count
	from rcv_shipment_lines
	where  shipment_header_id = p_header_id;

	if (l_rsl_line_count > 0) then
	 l_asn_status := 'SUCCESS';
	else
	 l_asn_status := 'ERROR';
	end if;

	x_processing_status := l_asn_status;

    elsif (l_asn_status = 'RUNNING') then

      x_processing_status := l_asn_status;

    else

      if (l_error_count = l_total_count) then  -- check whether all are in error
        if (l_total_count > 0) then
          l_asn_status := 'ERROR';
        else
          l_asn_status := '';
        end if;
      elsif (l_pending_count + l_error_count = l_total_count) then
        l_asn_status := 'PENDING';
      elsif (l_success_count = l_total_count) then

       begin

       l_rti_error := 'N';

       select count(*)
       into l_rti_line_count
       from rcv_transactions_interface
       where HEADER_INTERFACE_ID = p_header_id;

       select 'Y'  into l_rti_error
       from dual
       where exists
         (select 1 from rcv_transactions_interface
          where HEADER_INTERFACE_ID = p_header_id
          and (processing_status_code = 'ERROR' or
               transaction_status_code = 'ERROR'));

       exception
         when no_data_found then null;
       end;

       if (l_rti_line_count > 0) then
         if (l_rti_error = 'Y') then
           l_asn_status := 'ERROR';
         else
           l_asn_status := 'RUNNING';
         end if;
       else
         l_asn_status := 'SUCCESS';
       end if;



      else
        l_asn_status := 'MULTIPLE';
      end if;

      x_processing_status := l_asn_status;

   end if;   -- end of new else block


    if (x_processing_status = 'RUNNING') then

      select fnd_message_cache.get_string('POS', 'POS_RUNNING')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'PENDING') then

      select fnd_message_cache.get_string('POS', 'POS_PENDING')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'ERROR') then

      select fnd_message_cache.get_string('POS', 'POS_ERROR')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'MULTIPLE') then

      select fnd_message_cache.get_string('POS', 'POS_MULTIPLE')
      into x_processing_dsp
      from dual;

    else

     x_processing_dsp := '';

    end if;



    /* Get total number of lines */
   select count(*)
     into l_total_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id;

   if (l_total_lines = 0) then

     x_cancellation_status := '';

   else  -- check in rcv_shipment tables

     /* Get total number of cancelled lines */
     select count(*)
     into l_cancelled_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
      where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id
      and rsl.shipment_line_status_code = 'CANCELLED';

     /* Get total number of lines pending cancellation */
     select count(*)
     into l_pending_cancel
     from RCV_TRANSACTIONS_INTERFACE rti,
          RCV_SHIPMENT_HEADERS rsh
      where rti.transaction_type = 'CANCEL'
      and rti.shipment_header_id = rsh.shipment_header_id
      and rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id;

   if (l_total_lines = l_cancelled_lines) then
      x_cancellation_status := 'CANCELLED';
   elsif (l_total_lines = l_cancelled_lines + l_pending_cancel) then
      x_cancellation_status := 'PENDING_CANCEL';
   elsif ((l_total_lines > l_cancelled_lines + l_pending_cancel)
          and (l_cancelled_lines + l_pending_cancel > 0)) then
      x_cancellation_status := 'PARTIALLY_CANCELLED';
   else
      x_cancellation_status := '';
   end if;

  end if;   -- whether need to check in rcv_shipment tables

  /*
  decode(CANCELLATION_STATUS, 'CANCELLED', fnd_message.get_string('POS','POS_CANCELLED'),
        'PENDING_CANCEL', fnd_message.get_string('POS','POS_PENDING_CANCEL'),
        'PARTIALLY_CANCELLED', fnd_message.get_string('POS','POS_PARTIALLY_CANCELLED'), '') CANCELLATION_STATUS_DSP
  */

   if (x_cancellation_status = 'CANCELLED') then

      select fnd_message_cache.get_string('POS', 'POS_CANCELLED')
      into x_cancellation_dsp
      from dual;

    elsif (x_cancellation_status = 'PENDING_CANCEL') then

      select fnd_message_cache.get_string('POS', 'POS_ASN_PENDING_CANCEL')
      into x_cancellation_dsp
      from dual;

    elsif (x_cancellation_status = 'PARTIALLY_CANCELLED') then

      select fnd_message_cache.get_string('POS', 'POS_PARTIALLY_CANCELLED')
      into x_cancellation_dsp
      from dual;

    else

      x_cancellation_dsp := '';

    end if;

EXCEPTION
  WHEN OTHERS THEN
       raise;
END find_processing_cancellation;


--abhi: deprecated, replaced by an overloaded funcation

PROCEDURE find_processing_cancellation (
       p_shipment_num  IN      VARCHAR2,
       p_vendor_id     IN      NUMBER,
       p_vendor_site_id   IN   NUMBER,
       x_processing_status OUT NOCOPY VARCHAR2,
       x_processing_dsp OUT NOCOPY VARCHAR2,
       x_cancellation_status OUT NOCOPY VARCHAR2,
       x_cancellation_dsp OUT NOCOPY VARCHAR2) is

   l_asn_status		varchar2(25) := NULL;
   l_processing_status	varchar2(25) := NULL;
   l_transaction_type	varchar2(25) := NULL;
   l_total_count	NUMBER := 0;
   l_pending_count	NUMBER := 0;
   l_success_count	NUMBER := 0;
   l_error_count	NUMBER := 0;
   l_rsl_line_count  NUMBER := 0;

   CURSOR c_ASN_status IS
     select  processing_status_code, transaction_type
       from  RCV_HEADERS_INTERFACE
      where  shipment_num = p_shipment_num
        and  vendor_id = p_vendor_id
        and  vendor_site_id = p_vendor_site_id;

   l_total_lines	NUMBER := 0;
   l_cancelled_lines	NUMBER := 0;
   l_pending_cancel	NUMBER := 0;

BEGIN

    OPEN c_ASN_status;
    LOOP
      FETCH c_ASN_status INTO l_processing_status, l_transaction_type;
      EXIT WHEN c_ASN_status%NOTFOUND;

      l_total_count := l_total_count + 1;

      -- Status is RUNNING if any header status is running.
      if (l_processing_status = 'RUNNING') then
         l_asn_status := 'RUNNING';
         exit;
      end if;

      if (l_processing_status = 'PENDING' and l_transaction_type = 'NEW') then
         l_pending_count := l_pending_count + 1;
      elsif (l_processing_status = 'ERROR' and l_transaction_type = 'NEW') then
         l_error_count := l_error_count + 1;
      elsif (l_processing_status = 'SUCCESS' and l_transaction_type = 'NEW') then
         l_success_count := l_success_count + 1;
      end if;

    END LOOP;
    CLOSE c_ASN_status;

    if (l_asn_status = 'RUNNING' or l_total_count = 0) then

      x_processing_status := l_asn_status;

    else

      if (l_error_count = l_total_count) then  -- check whether all are in error
        if (l_total_count > 0) then
          l_asn_status := 'ERROR';
        else
          l_asn_status := '';
        end if;
      elsif (l_pending_count + l_error_count = l_total_count) then
        l_asn_status := 'PENDING';
      elsif (l_success_count = l_total_count) then

       BEGIN
       -- fix for bug 3358908
       -- for "successful" ASNs make sure that there exists at least one record in rcv_shipment_lines
       select count(*)
       into l_rsl_line_count
       from rcv_shipment_lines
       where shipment_header_id in
             (select shipment_header_id from rcv_shipment_headers
              where shipment_num = p_shipment_num
              and vendor_id = p_vendor_id and vendor_site_id = p_vendor_site_id);

       if (l_rsl_line_count > 0) then
         l_asn_status := 'SUCCESS';
       else
         l_asn_status := 'ERROR';
       end if;
       END;

      else
        l_asn_status := 'MULTIPLE';
      end if;

      x_processing_status := l_asn_status;

   end if;   -- end of new else block


    /*
    decode(PROCESSING_STATUS, 'RUNNING', fnd_message.get_string('POS','POS_RUNNING'),
        'PENDING', fnd_message.get_string('POS','POS_PENDING'),
        'ERROR', fnd_message.get_string('POS','POS_ERROR'),
        'MULTIPLE', fnd_message.get_string('POS','POS_MULTIPLE'), '') PROCESSING_STATUS_DSP
    */

    if (x_processing_status = 'RUNNING') then

      select fnd_message_cache.get_string('POS', 'POS_RUNNING')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'PENDING') then

      select fnd_message_cache.get_string('POS', 'POS_PENDING')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'ERROR') then

      select fnd_message_cache.get_string('POS', 'POS_ERROR')
      into x_processing_dsp
      from dual;

    elsif (x_processing_status = 'MULTIPLE') then

      select fnd_message_cache.get_string('POS', 'POS_MULTIPLE')
      into x_processing_dsp
      from dual;

    else

     x_processing_dsp := '';

    end if;



    /* Get total number of lines */
   select count(*)
     into l_total_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id;

   if (l_total_lines = 0) then

     x_cancellation_status := '';

   else  -- check in rcv_shipment tables

     /* Get total number of cancelled lines */
     select count(*)
     into l_cancelled_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
      where rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id
      and rsh.shipment_header_id = rsl.shipment_header_id
      and rsl.shipment_line_status_code = 'CANCELLED';

     /* Get total number of lines pending cancellation */
     select count(*)
     into l_pending_cancel
     from RCV_TRANSACTIONS_INTERFACE rti,
          RCV_SHIPMENT_HEADERS rsh
      where rti.transaction_type = 'CANCEL'
      and rti.shipment_header_id = rsh.shipment_header_id
      and rsh.shipment_num = p_shipment_num
      and rsh.vendor_id = p_vendor_id
      and rsh.vendor_site_id = p_vendor_site_id;

   if (l_total_lines = l_cancelled_lines) then
      x_cancellation_status := 'CANCELLED';
   elsif (l_total_lines = l_cancelled_lines + l_pending_cancel) then
      x_cancellation_status := 'PENDING_CANCEL';
   elsif ((l_total_lines > l_cancelled_lines + l_pending_cancel)
          and (l_cancelled_lines + l_pending_cancel > 0)) then
      x_cancellation_status := 'PARTIALLY_CANCELLED';
   else
      x_cancellation_status := '';
   end if;

  end if;   -- whether need to check in rcv_shipment tables

  /*
  decode(CANCELLATION_STATUS, 'CANCELLED', fnd_message.get_string('POS','POS_CANCELLED'),
        'PENDING_CANCEL', fnd_message.get_string('POS','POS_PENDING_CANCEL'),
        'PARTIALLY_CANCELLED', fnd_message.get_string('POS','POS_PARTIALLY_CANCELLED'), '') CANCELLATION_STATUS_DSP
  */

   if (x_cancellation_status = 'CANCELLED') then

      select fnd_message_cache.get_string('POS', 'POS_CANCELLED')
      into x_cancellation_dsp
      from dual;

    elsif (x_cancellation_status = 'PENDING_CANCEL') then

      select fnd_message_cache.get_string('POS', 'POS_ASN_PENDING_CANCEL')
      into x_cancellation_dsp
      from dual;

    elsif (x_cancellation_status = 'PARTIALLY_CANCELLED') then

      select fnd_message_cache.get_string('POS', 'POS_PARTIALLY_CANCELLED')
      into x_cancellation_dsp
      from dual;

    else

      x_cancellation_dsp := '';

    end if;

EXCEPTION
  WHEN OTHERS THEN
       raise;
END find_processing_cancellation;



--
-- Get the cancellation status of the single ASN line.
--
FUNCTION get_line_status  (
	p_shipment_line_id	NUMBER)
RETURN VARCHAR2 IS

   x_line_status_code	VARCHAR2(30) := NULL;
   x_transaction_type	VARCHAR2(25) := NULL;

   CURSOR c_line_status IS
     Select nvl(shipment_line_status_code, '')
       From RCV_SHIPMENT_LINES
      Where shipment_line_id = p_shipment_line_id;

   CURSOR c_transaction_type IS
     select nvl(transaction_type, '')
       from RCV_TRANSACTIONS_INTERFACE
      where shipment_line_id = p_shipment_line_id;

BEGIN

   OPEN c_line_status;
   LOOP
     FETCH c_line_status INTO x_line_status_code;
     EXIT WHEN c_line_status%NOTFOUND;
   END LOOP;
   CLOSE c_line_status;

   if (x_line_status_code = 'CANCELLED') then
      return 'CANCELLED';
   end if;

   OPEN c_transaction_type;
   LOOP
     FETCH c_transaction_type INTO x_transaction_type;
     EXIT WHEN c_transaction_type%NOTFOUND;
   END LOOP;
   CLOSE c_transaction_type;

   if (x_transaction_type = 'CANCEL') then
      return 'PENDING_CANCEL';
   end if;

   return 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       raise;
END get_line_status;


--
-- Cancel the individual ASN line.
--
PROCEDURE cancel_asn_line (
	p_shipment_line_id 	IN 	NUMBER,
	p_vendor_id		IN 	NUMBER,
	p_error_code		IN OUT NOCOPY	VARCHAR2 )
IS

   x_group_id			NUMBER;
   X_po_header_id		NUMBER;
   X_po_release_id		NUMBER;
   X_po_line_id			NUMBER;
   X_shipment_header_id		NUMBER;
   X_po_line_location_id	NUMBER;
   X_deliver_to_location_id	NUMBER;
   X_to_organization_id		NUMBER;
   X_item_id			NUMBER;
   X_quantity_shipped		NUMBER;
   X_source_document_code	VARCHAR2(25);
   X_category_id		NUMBER;
   X_unit_of_measure		VARCHAR2(25);
   X_item_description		VARCHAR2(240);
   X_employee_id		NUMBER;
   X_destination_type_code   	VARCHAR2(25);
   X_destination_context     	VARCHAR2(30);
   X_subinventory            	VARCHAR2(10);
   X_routing_header_id       	NUMBER;
   X_primary_unit_of_measure  	VARCHAR2(25);
   X_ship_to_location_id     	NUMBER;
   X_operating_unit_id          MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;

BEGIN
   SELECT rcv_interface_groups_s.nextval
   INTO   x_group_id
   FROM   dual;

   select
	RSL.PO_HEADER_ID,
	RSL.PO_RELEASE_ID,
	RSL.PO_LINE_ID,
	RSL.SHIPMENT_HEADER_ID,
	RSL.PO_LINE_LOCATION_ID,
	RSL.DELIVER_TO_LOCATION_ID,
	RSL.TO_ORGANIZATION_ID,
	RSL.ITEM_ID,
	RSL.QUANTITY_SHIPPED,
	RSL.SOURCE_DOCUMENT_CODE,
	RSL.CATEGORY_ID,
	RSL.UNIT_OF_MEASURE,
	RSL.ITEM_DESCRIPTION,
	RSL.EMPLOYEE_ID,
	RSL.DESTINATION_TYPE_CODE,
	RSL.DESTINATION_CONTEXT,
	RSL.TO_SUBINVENTORY,
	RSL.ROUTING_HEADER_ID,
	RSL.PRIMARY_UNIT_OF_MEASURE,
	RSL.SHIP_TO_LOCATION_ID,
        POHA.ORG_ID
     into
	X_po_header_id,
   	X_po_release_id,
   	X_po_line_id,
   	X_shipment_header_id,
   	X_po_line_location_id,
   	X_deliver_to_location_id,
   	X_to_organization_id,
   	X_item_id,
   	X_quantity_shipped,
   	X_source_document_code,
   	X_category_id,
   	X_unit_of_measure,
   	X_item_description,
   	X_employee_id,
   	X_destination_type_code,
   	X_destination_context,
   	X_subinventory,
   	X_routing_header_id,
   	X_primary_unit_of_measure,
   	X_ship_to_location_id,
        X_operating_unit_id
     from
	RCV_SHIPMENT_LINES  RSL,
        PO_HEADERS_ALL POHA
    where
	rsl.shipment_line_id = p_shipment_line_id
        and rsl.po_header_id = poha.po_header_id;

   RCV_INSERT_RTI_SV.insert_into_rti(
                                x_group_id,
                                'CANCEL',
                                sysdate,
                                'PENDING',
                      	        'BATCH',
                                'PENDING',
                               	SYSDATE,
                               	1,
                               	1,
				'RCV',
                                SYSDATE,
                                1,
				'CANCEL',
				'VENDOR',
				X_po_header_id,
				X_po_release_id,
				X_po_line_id,
				p_shipment_line_id,
				X_shipment_header_id,
				X_po_line_location_id,
				X_deliver_to_location_id,
				X_to_organization_id,
				X_item_id,
				X_quantity_shipped,
				X_source_document_code,
				X_category_id,
				X_unit_of_measure,
				X_item_description,
				X_employee_id,
				X_destination_type_code,
				X_destination_context,
				X_subinventory,
				X_routing_header_id,
				X_primary_unit_of_measure,
				X_ship_to_location_id,
				p_vendor_id,
                                X_operating_unit_id);

   EXCEPTION
     WHEN OTHERS THEN
       p_error_code := 'POS_ASN_CANCEL_EXCEPTION';
       raise;
END cancel_asn_line;


--
-- This procedure will be compatible with AP minipack F or above.
--
PROCEDURE cancel_invoice_new (
	p_invoice_id 		IN	NUMBER,
	p_set_of_books_id	IN	NUMBER,
	p_gl_date		IN	DATE,
	P_period_name		IN	VARCHAR2 )
IS

   plsql_block_old		VARCHAR2(1000);
   plsql_block_new		VARCHAR2(1000);

   l_message_name		FND_NEW_MESSAGES.message_name%TYPE;
   l_invoice_amount		AP_INVOICES.invoice_amount%TYPE;
   l_base_amount		AP_INVOICES.base_amount%TYPE;
   l_tax_amount 		AP_INVOICES.tax_amount%TYPE;
   l_temp_cancelled_amount 	AP_INVOICES.temp_cancelled_amount%TYPE;
   l_cancelled_by 		AP_INVOICES.cancelled_by%TYPE;
   l_cancelled_amount 		AP_INVOICES.cancelled_amount%TYPE;
   l_cancelled_date 		AP_INVOICES.cancelled_date%TYPE;
   l_last_update_date 		AP_INVOICES.last_update_date%TYPE;
   l_dummy_amount		NUMBER;
   l_token              VARCHAR2(1000);
   l_pay_curr_invoice_amount 	AP_INVOICES.pay_curr_invoice_amount%TYPE;

BEGIN

   /* plsql_block_new has one more binding argument than plsql_block_old. */
   plsql_block_old := 	' BEGIN if (AP_CANCEL_PKG.Ap_Cancel_Single_Invoice( ' ||
		   	' :v1,  :v2,  :v3,  :v4,  :v5, :v6, :v7, :v8, :v9, '  ||
		  	' :v10, :v11, :v12, :v13, :v14, :v15, :v16, null, '   ||
		   	' ''POSASNCB'')) then null; end if; END; ';

   plsql_block_new := 	' BEGIN if (AP_CANCEL_PKG.Ap_Cancel_Single_Invoice( ' ||
		   	' :v1,  :v2,  :v3,  :v4,  :v5, :v6, :v7, :v8, :v9, '  ||
		   	' :v10, :v11, :v12, :v13, :v14,    '   ||
		   	' :v15, ''POSASNCB'')) then null; end if;  END; ';
   BEGIN
      /* Cancel the invoice using function with new signature. */
      EXECUTE IMMEDIATE plsql_block_new USING
		IN	p_invoice_id,
		IN	1,
		IN	1,
		IN	p_gl_date,
		OUT 	l_message_name,
		OUT 	l_invoice_amount,
		OUT 	l_base_amount,
		OUT 	l_temp_cancelled_amount,
		OUT 	l_cancelled_by,
		OUT 	l_cancelled_amount,
		OUT 	l_cancelled_date,
		OUT 	l_last_update_date,
		OUT 	l_dummy_amount,
		OUT 	l_pay_curr_invoice_amount,
		OUT 	l_token;

   EXCEPTION
     WHEN OTHERS THEN

       /** If the exception is due to the wrong number of arguments in call
          to 'AP_CANCEL_SINGLE_INVOICE', we'll try the old signature. **/
       IF (SQLCODE = -6550) THEN
          BEGIN
             EXECUTE IMMEDIATE plsql_block_old USING
		IN	p_invoice_id,
		IN	1,
		IN	1,
		IN	p_set_of_books_id,
		IN	p_gl_date,
		IN	p_period_name,
		OUT 	l_message_name,
		OUT 	l_invoice_amount,
		OUT 	l_base_amount,
		OUT 	l_tax_amount,
		OUT 	l_temp_cancelled_amount,
		OUT 	l_cancelled_by,
		OUT 	l_cancelled_amount,
		OUT 	l_cancelled_date,
		OUT 	l_last_update_date,
		OUT 	l_dummy_amount;

          EXCEPTION
             WHEN OTHERS THEN
              raise;
          END;

       ELSE
          raise;   -- Raise other types of exception.
       END IF;
   END;

END cancel_invoice_new;


--
-- This procedure will be compatible with AP minipack A to D.
--
PROCEDURE cancel_invoice_old (
	p_invoice_id 		IN	NUMBER,
	p_set_of_books_id	IN	NUMBER,
	p_gl_date		IN	DATE,
	P_period_name		IN	VARCHAR2 )
IS

   plsql_block_old		VARCHAR2(1000);
   plsql_block_new		VARCHAR2(1000);

   l_message_name		FND_NEW_MESSAGES.message_name%TYPE;
   l_invoice_amount		AP_INVOICES.invoice_amount%TYPE;
   l_base_amount		AP_INVOICES.base_amount%TYPE;
   l_tax_amount 		AP_INVOICES.tax_amount%TYPE;
   l_temp_cancelled_amount 	AP_INVOICES.temp_cancelled_amount%TYPE;
   l_cancelled_by 		AP_INVOICES.cancelled_by%TYPE;
   l_cancelled_amount 		AP_INVOICES.cancelled_amount%TYPE;
   l_cancelled_date 		AP_INVOICES.cancelled_date%TYPE;
   l_last_update_date 		AP_INVOICES.last_update_date%TYPE;
   l_dummy_amount		NUMBER;
   l_token              VARCHAR2(1000);
   l_pay_curr_invoice_amount 	AP_INVOICES.pay_curr_invoice_amount%TYPE;

BEGIN

   /* plsql_block_new has one more binding argument than plsql_block_old. */
   plsql_block_old := 	' BEGIN if (AP_CANCEL_PKG.Ap_Cancel_Single_Invoice( ' ||
		   	' :v1,  :v2,  :v3,  :v4,  :v5, :v6, :v7, :v8, :v9, '  ||
		   	' :v10, :v11, :v12, :v13, :v14, :v15, :v16, null, '   ||
		   	' ''POSASNCB'')) then null; end if; END; ';

   plsql_block_new :=   ' BEGIN if (AP_CANCEL_PKG.Ap_Cancel_Single_Invoice( ' ||
            ' :v1,  :v2,  :v3,  :v4,  :v5, :v6, :v7, :v8, :v9, '  ||
            ' :v10, :v11, :v12, :v13, :v14,    '   ||
            ' :v15, ''POSASNCB'')) then null; end if;  END; ';

   BEGIN
      EXECUTE IMMEDIATE plsql_block_old USING
		IN	p_invoice_id,
		IN	1,
		IN	1,
		IN	p_set_of_books_id,
		IN	p_gl_date,
		IN	p_period_name,
		OUT 	l_message_name,
		OUT 	l_invoice_amount,
		OUT 	l_base_amount,
		OUT 	l_tax_amount,
		OUT 	l_temp_cancelled_amount,
		OUT 	l_cancelled_by,
		OUT 	l_cancelled_amount,
		OUT 	l_cancelled_date,
		OUT 	l_last_update_date,
		OUT 	l_dummy_amount;

   EXCEPTION
     WHEN OTHERS THEN

       /** If the exception is due to the wrong number of arguments in call
          to 'AP_CANCEL_SINGLE_INVOICE', we'll try the new signature. **/
       IF (SQLCODE = -6550) THEN
      BEGIN
      /* Cancel the invoice using function with new signature. */
      EXECUTE IMMEDIATE plsql_block_new USING
        IN  p_invoice_id,
        IN  1,
        IN  1,
        IN  p_gl_date,
        OUT     l_message_name,
        OUT     l_invoice_amount,
        OUT     l_base_amount,
        OUT     l_temp_cancelled_amount,
        OUT     l_cancelled_by,
        OUT     l_cancelled_amount,
        OUT     l_cancelled_date,
        OUT     l_last_update_date,
        OUT     l_dummy_amount,
        OUT     l_pay_curr_invoice_amount,
        OUT     l_token;

          EXCEPTION
             WHEN OTHERS THEN
              raise;
          END;

       ELSE
          raise;  -- Raise other types of exception.
       END IF;
   END;

END cancel_invoice_old;



--
-- Call the AP package to cancel the single invoice.
--
PROCEDURE cancel_invoice (
	p_invoice_id IN NUMBER )
IS

   l_ap_patch_level 	VARCHAR2(30);
   l_set_of_books_id	NUMBER;
   l_gl_date		DATE;
   l_period_name	gl_period_statuses.period_name%TYPE;

BEGIN

   select set_of_books_id, gl_date
     into l_set_of_books_id, l_gl_date
     from ap_invoices_all
    where invoice_id = p_invoice_id;

   l_period_name := AP_INVOICES_PKG.GET_PERIOD_NAME(l_gl_date);

   /** Get AP's patch level in the enviroment **/
   BEGIN
     ad_version_util.get_product_patch_level(200, l_ap_patch_level);
   EXCEPTION
     WHEN OTHERS THEN
       l_ap_patch_level := null;
   END;

   /** If AP's patch level is not registered or below AP.F. **/
   IF (l_ap_patch_level is null or l_ap_patch_level in ('11i.AP.A',
       '11i.AP.B', '11i.AP.C', '11i.AP.D', '11i.AP.E')) THEN

      cancel_invoice_old ( P_invoice_id,
			   l_set_of_books_id,
			   l_gl_date,
			   l_period_name );

   ELSE  -- AP's patch level is F or above
      cancel_invoice_new ( P_invoice_id,
			   l_set_of_books_id,
			   l_gl_date,
			   l_period_name );
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
       raise;
END cancel_invoice;


END POS_CANCEL_ASN;

/
