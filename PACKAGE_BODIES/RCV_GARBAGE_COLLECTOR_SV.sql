--------------------------------------------------------
--  DDL for Package Body RCV_GARBAGE_COLLECTOR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_GARBAGE_COLLECTOR_SV" AS
/* $Header: RCVGARBB.pls 120.0.12010000.2 2010/01/25 22:40:03 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

/*===========================================================================

  PROCEDURE NAME:	collect_garbage()

===========================================================================*/

PROCEDURE collect_garbage (p_request_id IN NUMBER,
                           p_group_id   IN NUMBER) IS

/* FPJ WMS CHANGE.
* We now support ROI for all the processing modes. Hence change
* the sql to support all modes. For online mode request id is null. Hence
* consider it as -999 if it is null for p_request_id.
*/
-- Bug 3549318 added or condition to collect rows with no source id specified
CURSOR c1 IS
SELECT   rhi.header_interface_id,
         COUNT (rti.interface_transaction_id) error_count
FROM     rcv_transactions_interface rti,
         rcv_headers_interface rhi
WHERE    rhi.header_interface_id = rti.header_interface_id
AND      rhi.processing_status_code = 'PENDING'
AND      (rti.document_num IS NOT NULL OR rti.oe_order_num IS NOT NULL)
AND      NOT EXISTS (SELECT 'x'
                     FROM   po_headers_all poha
                     WHERE  poha.segment1 = rti.document_num)
AND      rhi.GROUP_ID = DECODE (p_group_id, 0, rhi.GROUP_ID, p_group_id)
AND      (   rhi.processing_request_id IS NULL
          OR rhi.processing_request_id = p_request_id
         )
GROUP BY rhi.header_interface_id;

/* Bug 2393443 - Modified the filter condition on segment1
   in the above cursor from" poha.segment1 = nvl(rti.document_num,'!0')"
   to "poha.segment1 = nvl(rti.document_num,poha.segment1)"
   so that records from other operating units are not picked up .
*/

-- Bug 2626270 - We will only consider the records that belong to
-- a specific group_id, if it is specified.


v_total_count number := 0;

begin
   -- For Bug 2367174
   -- Part 1

   -- Mark all rcv_transactions_interface rows to RUNNING that have the
   -- the header_interface_row set to RUNNING so all the
   -- transaction_interface rows get picked up.

   -- An ASN with multiple OU POs will thus be not supported.

      /* FPJ WMS CHANGE.
       * We now support ROI for all the processing modes. Hence change
       * the sql to support all modes.
      */
      update rcv_transactions_interface rti
      SET    rti.processing_status_code = 'RUNNING',
             rti.processing_request_id =decode(p_request_id,null,null,
							p_request_id)
      where exists (select 'x' from rcv_headers_interface rhi
                    where rhi.header_interface_id = rti.header_interface_id and
                          rhi.processing_status_code = 'RUNNING' and
                          (rhi.processing_request_id is null or
                          rhi.processing_request_id = p_request_id)) and
	     rti.group_id = decode(p_group_id, 0, rti.group_id, p_group_id) and
             rti.processing_status_code = 'PENDING' ;

   -- Part 2

   -- select all header_interface rows that have either missing or
   -- invalid po numbers (document_num)

   -- if all the rows for an ASN are invalid from above then we need to
   -- process this ASN in this session. Mark the ASN as RUNNING and
   -- update the request_id so the pre-processor will pick up this ASN
   -- This handles the case where we could have an ASN with all lines
   -- invalid due to either missing po numbers or invalid po numbers

   for c1_rec in c1 loop

     select count(*)
     into v_total_count
     from rcv_transactions_interface rti
     where
        rti.header_interface_id = c1_rec.header_interface_id;

     if c1_rec.error_count = v_total_count then

        IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('The ASN '  || to_char(c1_rec.header_interface_id) || ' has only errored rows');
           asn_debug.put_line('Need to mark the ASN and all transactions to RUNNING');
        END IF;

        -- update the header to running with the right request_id

      /* FPJ WMS CHANGE.
       * We now support ROI for all the processing modes. Hence change
       * the sql to support all modes.
	*/
        update rcv_headers_interface
	set processing_status_code = 'RUNNING',
	 processing_request_id = decode(p_request_id,null,null, p_request_id)
        where processing_status_code  = 'PENDING' and
              header_interface_id = c1_rec.header_interface_id;

        -- update the transactions to running with the right request_id

      /* FPJ WMS CHANGE.
       * We now support ROI for all the processing modes. Hence change
       * the sql to support all modes.
	*/
        update rcv_transactions_interface
        SET    processing_status_code = 'RUNNING',
               processing_request_id = decode(p_request_id,null,null,
						p_request_id)
	WHERE 	processing_status_code = 'PENDING'
	AND   	(processing_request_id is null OR
	   	processing_request_id  = p_request_id)
	AND    group_id = decode(p_group_id,0,group_id,p_group_id)
        AND     header_interface_id = c1_rec.header_interface_id;

     else

        IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Should be picked up in some other session');
           asn_debug.put_line('The ASN ' || to_char(c1_rec.header_interface_id) || ' may have some valid rows');
           asn_debug.put_line('We do nothing in this case');
        END IF;

     end if;

  end loop;

END collect_garbage;

END RCV_GARBAGE_COLLECTOR_SV;

/
