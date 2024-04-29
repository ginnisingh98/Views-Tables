--------------------------------------------------------
--  DDL for Package Body RCV_824_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_824_SV" AS
/* $Header: RCV824B.pls 120.0.12000000.2 2007/04/12 06:29:28 kagupta ship $ */

/*==================================================================*/
PROCEDURE  RCV_824_INSERT (X_Interface_Header IN RCV_ROI_PREPROCESSOR.header_rec_type,
                           X_Type             IN VARCHAR2) IS

/* This is for creating the lines row for 824 */

cursor get_header_error_rows is
     select error_message, error_message_name
     from po_interface_errors pie
     where
           pie.interface_header_id = X_interface_header.header_record.header_interface_id and
           pie.interface_line_id is null;

/* This is for creating the lines row for 824 */
/* Bug 2533087 - The nvl on interface_header_id was causing a performance issue as
   index was not being used which resulted in a full table scan on po_interface_errors.
   The interface_header_id can be null only in the case of error messages inserted
   for transactions that are processed thru forms.
   But we generate Application advices for errors that occur while processing
   the ROI. Not for errors generated thru forms. So we can remove the nvl condition.
   Also added a condition pie.interface_header_id is not null. */


cursor get_line_error_rows is
     select item_num, document_num, document_line_num,
            barcode_label, error_message, error_message_name
     from rcv_transactions_interface rti, po_interface_errors pie
     where  pie.interface_line_id = rti.interface_transaction_id and
            pie.interface_header_id =
                X_interface_header.header_record.header_interface_id and
            pie.interface_line_id is not null and
            pie.interface_header_id is not null;

/*  NWANG 9/4/97 */
CURSOR get_receipt_line_rows IS
     SELECT msi.concatenated_segments, poh.segment1, pol.line_num, rsl.bar_code_label,
            error_message, error_message_name
     FROM   po_interface_errors pie, rcv_shipment_lines rsl ,
            mtl_system_items_kfv msi, po_headers poh, po_lines pol
     WHERE  pol.po_line_id = rsl.po_line_id
            AND poh.po_header_id = rsl.po_header_id
            AND msi.inventory_item_id (+)= rsl.item_id
            AND NVL(msi.organization_id, rsl.to_organization_id) = rsl.to_organization_id
            AND pie.interface_line_id = rsl.shipment_line_id
            AND NVL(pie.interface_header_id , X_interface_header.header_record.header_interface_id) =
                    X_interface_header.header_record.header_interface_id
            AND pie.interface_line_id is not null;


    X_progress		VARCHAR2(3);
    X_compl_code	VARCHAR2(1);

    x_api_version_number    number := 1;
    x_return_status         varchar2(25);
    x_msg_count             number;
    x_msg_data              varchar2(80);
    x_communication_method  varchar2(10) := 'EDI';
    x_related_document_id   varchar2(10) := 'ASNI';
    x_tp_header_id          number;
    x_tp_location_code      varchar2(35);
    x_document_type         varchar2(25) := 'ADVO';
    x_document_code         varchar2(25) := null;
    x_entity_code           varchar2(30) := null;
    x_entity_name           varchar2(80) := null;
--<UTF8 FPI START>
    x_entity_address1       po_vendor_sites.address_line1%type := null;
    x_entity_address2       po_vendor_sites.address_line2%type := null;
    x_entity_address3       po_vendor_sites.address_line3%type := null;
    x_entity_address4       varchar2(60) := null;
    x_entity_city           varchar2(30) := null;
    x_entity_postal_code    varchar2(30) := null;
    x_entity_country        po_vendor_sites.country%type := null;
    x_entity_state          po_vendor_sites.state%type := null;
    x_entity_province       po_vendor_sites.province%type := null;
    x_entity_county         varchar2(30) := null;
--<UTF8 FPI END>
    x_external_reference_1  varchar2(30) := null;
    x_external_reference_2  varchar2(30) := null;
    x_external_reference_3  varchar2(30) := null;
    x_external_reference_4  varchar2(30) := null;
    x_external_reference_5  varchar2(30) := null;
    x_external_reference_6  varchar2(30) := null;
    x_internal_reference_1  varchar2(30) := null;
    x_internal_reference_2  varchar2(30) := null;
    x_internal_reference_3  varchar2(30) := null;
    x_internal_reference_4  varchar2(30) := null;
    x_internal_reference_5  varchar2(30) := null;
    x_internal_reference_6  varchar2(30) := null;
    x_advice_status_code    varchar2(30) := null;
    x_advo_message_code     varchar2(60) := null;
    x_advo_message_desc     varchar2(240) := null;   -- bug 669568
    x_advo_data_bad         varchar2(60) := null;
    x_advo_data_good        varchar2(60) := null;

    x_advice_header_id      number;

BEGIN
         x_progress := '001';

         asn_debug.put_line('I am in 824 API');

         -- bug 569723 external_reference_1 should be the shipment number.

         x_external_reference_1 := X_interface_header.header_record.shipment_num;

         /* 2700139 - The internal reference1 is populated with shipment num for
            advice header creation.   */

         x_internal_reference_1 := X_interface_header.header_record.shipment_num;

         -- bug 569723 the rest should be null
        /*   x_external_reference_2 := X_interface_header.header_record.transaction_type;
             x_external_reference_3 := X_interface_header.header_record.vendor_name;
             x_external_reference_4 := X_interface_header.header_record.vendor_site_code;
             x_external_reference_5 := X_interface_header.header_record.invoice_num;
             x_external_reference_6 := X_interface_header.header_record.processing_status_code; */
         x_entity_code          := X_interface_header.header_record.vendor_num;
         x_entity_name          := X_interface_header.header_record.vendor_name;

         asn_debug.put_line('Vendor Site Id ' || to_char(X_interface_header.header_record.vendor_site_id));
         asn_debug.put_line('Vendor Site Code ' || X_interface_header.header_record.vendor_site_code);

         if X_interface_header.header_record.vendor_site_id is not null then

            asn_debug.put_line('Getting vendor_site information from vendor_site_id');

            begin
              select tp_header_id, address_line1, address_line2, address_line3,
                     city, zip, country, state, province, ece_tp_location_code
              into x_tp_header_id, x_entity_address1, x_entity_address2, x_entity_address3,
                   x_entity_city, x_entity_postal_code, x_entity_country, x_entity_state,
                   x_entity_province, x_tp_location_code
              from po_vendor_sites where po_vendor_sites.vendor_site_id = X_interface_header.header_record.vendor_site_id;

              asn_debug.put_line('TP header id ' || to_char(x_tp_header_id));

            exception

               when others then
                    asn_debug.put_line('Unable to locate vendor site record');

            end;
         else

            asn_debug.put_line('Need to handle vendor_site_code is not null and vendor_site_id is null');

         end if;


         asn_debug.put_line('Calling the create advice header ');

         asn_debug.put_line('p_api_version_number    ' || x_api_version_number);
         asn_debug.put_line('p_communication_method  ' || x_communication_method);
         asn_debug.put_line('p_related_document_id   ' || x_related_document_id);
         asn_debug.put_line('p_tp_header_id          ' || x_tp_header_id);
         asn_debug.put_line('p_tp_location_code      ' || x_tp_location_code);
         asn_debug.put_line('p_document_type         ' || x_document_type);
         asn_debug.put_line('p_document_code         ' || x_document_code);
         asn_debug.put_line('p_entity_code           ' || x_entity_code);
         asn_debug.put_line('p_entity_name           ' || x_entity_name);
         asn_debug.put_line('p_entity_address1       ' || x_entity_address1);
         asn_debug.put_line('p_entity_address2       ' || x_entity_address2);
         asn_debug.put_line('p_entity_address3       ' || x_entity_address3);
         asn_debug.put_line('p_entity_address4       ' || x_entity_address4);
         asn_debug.put_line('p_entity_city           ' || x_entity_city);
         asn_debug.put_line('p_entity_postal_code    ' || x_entity_postal_code);
         asn_debug.put_line('p_entity_country        ' || x_entity_country);
         asn_debug.put_line('p_entity_state          ' || x_entity_state);
         asn_debug.put_line('p_entity_province       ' || x_entity_province);
         asn_debug.put_line('p_entity_county         ' || x_entity_county);
         asn_debug.put_line('p_external_reference_1  ' || x_external_reference_1);
         asn_debug.put_line('p_external_reference_2  ' || x_external_reference_2);
         asn_debug.put_line('p_external_reference_3  ' || x_external_reference_3);
         asn_debug.put_line('p_external_reference_4  ' || x_external_reference_4);
         asn_debug.put_line('p_external_reference_5  ' || x_external_reference_5);
         asn_debug.put_line('p_external_reference_6  ' || x_external_reference_6);
         asn_debug.put_line('p_internal_reference_1  ' || x_internal_reference_1);
         asn_debug.put_line('p_internal_reference_2  ' || x_internal_reference_2);
         asn_debug.put_line('p_internal_reference_3  ' || x_internal_reference_3);
         asn_debug.put_line('p_internal_reference_4  ' || x_internal_reference_4);
         asn_debug.put_line('p_internal_reference_5  ' || x_internal_reference_5);
         asn_debug.put_line('p_internal_reference_6  ' || x_internal_reference_6);



         EC_APPLICATION_ADVICE_PUB.create_advice (p_api_version_number    => x_api_version_number,
                                              p_return_status         => x_return_status,
                                              p_msg_count             => x_msg_count,
                                              p_msg_data              => x_msg_data,
                                              p_communication_method  => x_communication_method,
                                              p_related_document_id   => x_related_document_id,
                                              p_tp_header_id          => x_tp_header_id,
                                              p_tp_location_code      => x_tp_location_code,
                                              p_document_type         => x_document_type,
                                              p_document_code         => x_document_code,
                                              p_entity_code           => x_entity_code,
                                              p_entity_name           => x_entity_name,
                                              p_entity_address1       => x_entity_address1,
                                              p_entity_address2       => x_entity_address2,
                                              p_entity_address3       => x_entity_address3,
                                              p_entity_address4       => x_entity_address4,
                                              p_entity_city           => x_entity_city,
                                              p_entity_postal_code    => x_entity_postal_code,
                                              p_entity_country        => x_entity_country,
                                              p_entity_state          => x_entity_state,
                                              p_entity_province       => x_entity_province,
                                              p_entity_county         => x_entity_county,
                                              p_external_reference_1  => x_external_reference_1,
                                              p_external_reference_2  => x_external_reference_2,
                                              p_external_reference_3  => x_external_reference_3,
                                              p_external_reference_4  => x_external_reference_4,
                                              p_external_reference_5  => x_external_reference_5,
                                              p_external_reference_6  => x_external_reference_6,
                           --bug 569723 the rest of the internal reference should just be NULL
                                              p_internal_reference_1  => x_internal_reference_1,
                                              p_internal_reference_2  => x_internal_reference_2,
                                              p_internal_reference_3  => x_internal_reference_3,
                                              p_internal_reference_4  => x_internal_reference_4,
                                              p_internal_reference_5  => x_internal_reference_5,
                                              p_internal_reference_6  => x_internal_reference_6,
                                              p_advice_header_id      => x_advice_header_id);

       asn_debug.put_line('Returned Advice header id ' || to_char(x_advice_header_id));
       asn_debug.put_line('Return Status ' || x_return_status);
       asn_debug.put_line('msg count ' || to_char(x_msg_count));
       asn_debug.put_line('msg data '  || x_msg_data);

       -- 824 header level errors

       for gher in get_header_error_rows loop

         asn_debug.put_line('Calling the advice lines api for header errors');

        /* 2700139 - The internal reference1 is populated with to_char(0) as external reference1
          for advice line creation.   */
         x_internal_reference_1 := to_char(0);


         x_external_reference_1 := to_char(0);  -- bug 569723, use 0 for header error;
         /*   x_external_reference_1 := X_interface_header.header_record.shipment_num;
              x_external_reference_2 := X_interface_header.header_record.vendor_name;
              x_external_reference_3 := X_interface_header.header_record.vendor_site_code;
              x_external_reference_4 := X_interface_header.header_record.invoice_num;
              x_external_reference_5 := X_interface_header.header_record.freight_carrier_code;
              x_external_reference_6 := null; */

         x_advice_status_code   := 'FATAL';
         x_advo_message_code    := gher.error_message_name;
         x_advo_message_desc    := substr(gher.error_message,1,240);  -- need this to be 2000


         EC_APPLICATION_ADVICE_PUB.create_advice_line (p_api_version_number    => x_api_version_number,
                                              p_return_status         => x_return_status,
                                              p_msg_count             => x_msg_count,
                                              p_msg_data              => x_msg_data,
                                              p_advice_header_id      => x_advice_header_id,
                                              p_advice_date_time      => sysdate,
                                              p_advice_status_code    => x_advice_status_code,
                                              p_external_reference_1  => x_external_reference_1,
                                              p_external_reference_2  => x_external_reference_2,
                                              p_external_reference_3  => x_external_reference_3,
                                              p_external_reference_4  => x_external_reference_4,
                                              p_external_reference_5  => x_external_reference_5,
                                              p_external_reference_6  => x_external_reference_6,
                                              p_internal_reference_1  => x_internal_reference_1,
                                              p_internal_reference_2  => x_internal_reference_2,
                                              p_internal_reference_3  => x_internal_reference_3,
                                              p_internal_reference_4  => x_internal_reference_4,
                                              p_internal_reference_5  => x_internal_reference_5,
                                              p_internal_reference_6  => x_internal_reference_6,
                                              p_advo_message_code     => x_advo_message_code,
                                              p_advo_message_desc     => x_advo_message_desc,
                                              p_advo_data_bad         => x_advo_data_bad,
                                              p_advo_data_good        => x_advo_data_good);

          asn_debug.put_line('Return Status ' || x_return_status);
          asn_debug.put_line('msg count ' || to_char(x_msg_count));
          asn_debug.put_line('msg data '  || x_msg_data);

       end loop;

       -- 824 line level errors

       /* NWANG 9-4-1997 */
       if (X_Type = 'DISCREPANT_SHIPMENT') then

         asn_debug.put_line('in discrepant_shipment');
         for grlr in get_receipt_line_rows loop

           x_external_reference_1 := grlr.concatenated_segments;
           x_external_reference_2 := grlr.segment1;
           x_external_reference_3 := grlr.line_num;
           x_external_reference_4 := grlr.bar_code_label;
           x_external_reference_5 := X_interface_header.header_record.shipment_num;
           x_external_reference_6 := X_interface_header.header_record.invoice_num;
           x_advice_status_code   := 'WARNING';
           x_advo_message_code    := substr(grlr.error_message_name,1,60); -- this should be 2000
           x_advo_message_desc    := substr(grlr.error_message,1,240);

           /* 2700139 - The internal reference1 is populated with document line num for
            advice line creation.   */

           x_internal_reference_1 := grlr.line_num;



           asn_debug.put_line('  before create line');

           asn_debug.put_line('line_api_version_number    ' || x_api_version_number);
           asn_debug.put_line('line_advice_header_id      ' || x_advice_header_id);
           asn_debug.put_line('line_advice_status_code    ' || x_advice_status_code);
           asn_debug.put_line('line_external_reference_1  ' || x_external_reference_1);
           asn_debug.put_line('line_external_reference_2  ' || x_external_reference_2);
           asn_debug.put_line('line_external_reference_3  ' || x_external_reference_3);
           asn_debug.put_line('line_external_reference_4  ' || x_external_reference_4);
           asn_debug.put_line('line_external_reference_5  ' || x_external_reference_5);
           asn_debug.put_line('line_external_reference_6  ' || x_external_reference_6);
           asn_debug.put_line('line_internal_reference_1  ' || x_internal_reference_1);
           asn_debug.put_line('line_internal_reference_2  ' || x_internal_reference_2);
           asn_debug.put_line('line_internal_reference_3  ' || x_internal_reference_3);
           asn_debug.put_line('line_internal_reference_4  ' || x_internal_reference_4);
           asn_debug.put_line('line_internal_reference_5  ' || x_internal_reference_5);
           asn_debug.put_line('line_internal_reference_6  ' || x_internal_reference_6);
           asn_debug.put_line('line_advo_message_code     ' || x_advo_message_code);
           asn_debug.put_line('line_advo_message_desc     ' || x_advo_message_desc);
           asn_debug.put_line('line_advo_data_bad         ' || x_advo_data_bad);
           asn_debug.put_line('line_advo_data_goog        ' || x_advo_data_good);

           EC_APPLICATION_ADVICE_PUB.create_advice_line (p_api_version_number    => x_api_version_number,
                                                p_return_status         => x_return_status,
                                                p_msg_count             => x_msg_count,
                                                p_msg_data              => x_msg_data,
                                                p_advice_header_id      => x_advice_header_id,
                                                p_advice_date_time      => sysdate,
                                                p_advice_status_code    => x_advice_status_code,
                                                p_external_reference_1  => x_external_reference_1,
                                                p_external_reference_2  => x_external_reference_2,
                                                p_external_reference_3  => x_external_reference_3,
                                                p_external_reference_4  => x_external_reference_4,
                                                p_external_reference_5  => x_external_reference_5,
                                                p_external_reference_6  => x_external_reference_6,
                                                p_internal_reference_1  => x_internal_reference_1,
                                                p_internal_reference_2  => x_internal_reference_2,
                                                p_internal_reference_3  => x_internal_reference_3,
                                                p_internal_reference_4  => x_internal_reference_4,
                                                p_internal_reference_5  => x_internal_reference_5,
                                                p_internal_reference_6  => x_internal_reference_6,
                                                p_advo_message_code     => x_advo_message_code,
                                                p_advo_message_desc     => x_advo_message_desc,
                                                p_advo_data_bad         => x_advo_data_bad,
                                                p_advo_data_good        => x_advo_data_good);

                  asn_debug.put_line('Return Status -- ' || x_return_status);
                  asn_debug.put_line('msg count -- ' || to_char(x_msg_count));
                  asn_debug.put_line('msg data -- '  || x_msg_data);
          end loop;

        else
         for gler in get_line_error_rows loop

           x_external_reference_1 := gler.document_line_num;  -- bug 569723, use line number to indicate
                                                              -- line errors
/* Added for bug 5769886
    Description : To show the Document number also in the ece_advo_details table  */
           x_external_reference_2 := gler.document_num;
         /*    x_external_reference_3 := gler.document_line_num;
             x_external_reference_4 := gler.barcode_label;
             x_external_reference_5 := X_interface_header.header_record.shipment_num;
             x_external_reference_6 := X_interface_header.header_record.invoice_num;  */
           x_advice_status_code   := 'FATAL';
           x_advo_message_code    := substr(gler.error_message_name,1,80); -- this should be 2000
           x_advo_message_desc    := substr(gler.error_message,1,240);  -- bug 669568

           /* 2700139 - The internal reference1 is populated with document line num for
            advice line creation.   */

           x_internal_reference_1 := gler.document_line_num;


           EC_APPLICATION_ADVICE_PUB.create_advice_line (p_api_version_number    => x_api_version_number,
                                                p_return_status         => x_return_status,
                                                p_msg_count             => x_msg_count,
                                                p_msg_data              => x_msg_data,
                                                p_advice_header_id      => x_advice_header_id,
                                                p_advice_date_time      => sysdate,
                                                p_advice_status_code    => x_advice_status_code,
                                                p_external_reference_1  => x_external_reference_1,
                                                p_external_reference_2  => x_external_reference_2,
                                                p_external_reference_3  => x_external_reference_3,
                                                p_external_reference_4  => x_external_reference_4,
                                                p_external_reference_5  => x_external_reference_5,
                                                p_external_reference_6  => x_external_reference_6,
                                                p_internal_reference_1  => x_internal_reference_1,
                                                p_internal_reference_2  => x_internal_reference_2,
                                                p_internal_reference_3  => x_internal_reference_3,
                                                p_internal_reference_4  => x_internal_reference_4,
                                                p_internal_reference_5  => x_internal_reference_5,
                                                p_internal_reference_6  => x_internal_reference_6,
                                                p_advo_message_code     => x_advo_message_code,
                                                p_advo_message_desc     => x_advo_message_desc,
                                                p_advo_data_bad         => x_advo_data_bad,
                                                p_advo_data_good        => x_advo_data_good);

                  asn_debug.put_line('Return Status ' || x_return_status);
                  asn_debug.put_line('msg count ' || to_char(x_msg_count));
                  asn_debug.put_line('msg data '  || x_msg_data);
         end loop;
       end if;

EXCEPTION
  WHEN others THEN
       asn_debug.put_line('RCV_824_S.RCV_824_INSERT ' || sqlcode);
END RCV_824_INSERT;

   PROCEDURE rcv_824_insert(
      x_interface_header IN rcv_shipment_header_sv.headerrectype,
      x_type             IN VARCHAR2
   ) IS
     x_temp rcv_roi_preprocessor.header_rec_type;
   BEGIN
      x_temp.header_record := x_interface_header.header_record;
      x_temp.error_record.error_status := x_interface_header.error_record.error_status;
      x_temp.error_record.error_message := x_interface_header.error_record.error_message;
      rcv_824_insert(x_temp,x_type);
   END rcv_824_insert;

END RCV_824_SV;

/
