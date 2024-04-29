--------------------------------------------------------
--  DDL for Package RCV_RMA_HEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RMA_HEADERS" 
/* $Header: RCVRMAHS.pls 120.0.12010000.1 2008/07/24 14:36:41 appldev ship $ */
AUTHID CURRENT_USER AS
   PROCEDURE derive_rma_header(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_rma_header(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE validate_rma_header(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE insert_rma_header(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   /* Private helper procedures */
   PROCEDURE derive_customer_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE derive_customer_site_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_customer_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_customer_site_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_trx_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_shipment_num(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE validate_receipt_source_code(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE validate_customer_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE validate_customer_site_info(
      p_header_record   IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type
   );

END RCV_RMA_HEADERS;

/
