--------------------------------------------------------
--  DDL for Package Body RCV_SHIPMENT_LINE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SHIPMENT_LINE_SV" AS
/* $Header: RCVTHCB.pls 120.0.12010000.2 2010/01/25 23:33:00 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          create_shipment_line()                           |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE create_shipment_line
                  (X_cascaded_table		IN OUT	NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
		   n				IN OUT	NOCOPY binary_integer,
		   X_header_id			IN	rcv_headers_interface.header_interface_id%type,
		   X_asn_type			IN	rcv_headers_interface.asn_type%type,
                   V_header_record              IN OUT NOCOPY  rcv_shipment_header_sv.headerrectype) IS

 x_parent_id		number;
 X_progress		varchar2(3);
 X_error_record		rcv_shipment_object_sv.errorrectype;
 x_start_indice		binary_integer	:= null;
 i			binary_integer	:= null;
 used_for_cascaded_rows rcv_shipment_object_sv.cascaded_trans_tab_type;


 BEGIN

   IF (g_asn_debug = 'Y') THEN
      ASN_DEBUG.PUT_LINE('Enter create shipment line');
   END IF;

   IF (g_asn_debug = 'Y') THEN
      ASN_DEBUG.PUT_LINE('Initialize the table structure used for storing the cascaded rows');
   END IF;

   -- delete all records from used_for_cascaded_rows

   for m in 1..used_for_cascaded_rows.count loop

       used_for_cascaded_rows.delete(m);

   end loop;

   X_progress		:=  '000';
   x_start_indice	:= n;

	   -- derive IDs and also explode rows

   rcv_transactions_interface_sv.derive_shipment_line (X_cascaded_table, n, used_for_cascaded_rows, V_header_record);

   IF (g_asn_debug = 'Y') THEN
      ASN_DEBUG.PUT_LINE('Back from derive routine with ' || to_char(used_for_cascaded_rows.count) || ' rows');
      ASN_DEBUG.PUT_LINE('Error Status ' || x_cascaded_table(n).error_status);
      ASN_DEBUG.PUT_LINE('Error Message ' || x_cascaded_table(n).error_message);
   END IF;

   X_progress		:=  '010';

   if (X_cascaded_table(n).error_status in ('S','W')) and
       used_for_cascaded_rows.count > 0 then                -- we have returned with a cascaded table

	for i in 1..used_for_cascaded_rows.count loop

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.PUT_LINE('Defaulting for cascaded row ' || to_char(i));
                END IF;
		rcv_transactions_interface_sv.default_shipment_line (used_for_cascaded_rows, i, X_header_id, V_header_record);

		X_progress      :=  '020';

		used_for_cascaded_rows(i).error_status	:= 'S';
		used_for_cascaded_rows(i).error_message	:= null;

		rcv_transactions_interface_sv.validate_shipment_line (used_for_cascaded_rows, i, X_asn_type, V_header_record);

		X_progress      :=  '030';

		if (used_for_cascaded_rows(i).error_status not in ('S','W')) then
			used_for_cascaded_rows(i).processing_status_code	:= 'ERROR';
			X_cascaded_table(n).processing_status_code	        := 'ERROR';
                        X_cascaded_table(n).error_status                        := used_for_cascaded_rows(i).error_status;
                        X_cascaded_table(n).error_message                       := used_for_cascaded_rows(i).error_message;

                        IF (g_asn_debug = 'Y') THEN
                           ASN_DEBUG.PUT_LINE('Have hit error condition in validation');
                           ASN_DEBUG.PUT_LINE('Mark needed flags and error message');
                           ASN_DEBUG.PUT_LINE('Delete the cascaded rows');
                        END IF;

                        for j in 1..used_for_cascaded_rows.count loop

                           used_for_cascaded_rows.delete(j);

                        end loop;

			exit;
		end if;

	end loop;

        IF X_cascaded_table(n).processing_status_code = 'ERROR' THEN

           IF (g_asn_debug = 'Y') THEN
              ASN_DEBUG.PUT_LINE('Have hit error condition in validation');
              ASN_DEBUG.PUT_LINE('Mark needed flags and error message');
              ASN_DEBUG.PUT_LINE('Delete the cascaded rows');
           END IF;

           for j in 1..used_for_cascaded_rows.count loop

               used_for_cascaded_rows.delete(j);

           end loop;

        ELSE

           IF (g_asn_debug = 'Y') THEN
              ASN_DEBUG.PUT_LINE('Have finished default and validation');
              ASN_DEBUG.PUT_LINE('Process has encountered no fatal errors');
              ASN_DEBUG.PUT_LINE('Will write the cascaded rows into actual table');
              ASN_DEBUG.PUT_LINE('Count of cascaded rows ' || to_char(used_for_cascaded_rows.count));
           END IF;

           for j in 1..used_for_cascaded_rows.count loop

               IF (g_asn_debug = 'Y') THEN
                  ASN_DEBUG.PUT_LINE('Current counter in actual table is at ' || to_char(n));
               END IF;
               X_cascaded_table(n) := used_for_cascaded_rows(j);
               used_for_cascaded_rows.delete(j);
               n := n + 1;

           end loop;

               IF (g_asn_debug = 'Y') THEN
                  ASN_DEBUG.PUT_LINE('Current counter before decrementing in actual table is at ' || to_char(n));
               END IF;
               n := n -1;   -- Get the counter in sync
               IF (g_asn_debug = 'Y') THEN
                  ASN_DEBUG.PUT_LINE('Current counter in actual table is at ' || to_char(n));
               END IF;

        END IF;


   else
	X_cascaded_table(n).processing_status_code	:= 'ERROR';  --  changed (i) -> (n)
	return;
   end if;

   IF (g_asn_debug = 'Y') THEN
      ASN_DEBUG.PUT_LINE('Exit create shipment line');
   END IF;

 END create_shipment_line;

END RCV_SHIPMENT_LINE_SV;


/
