--------------------------------------------------------
--  DDL for Package OEXPURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXPURGE" AUTHID CURRENT_USER AS
/* $Header: OEXPURGS.pls 115.3 99/07/16 08:15:28 porting shi $ */

PROCEDURE select_purge_orders
          (  dummy_1 		IN	varchar2
         ,   dummy_2 		IN	varchar2
         ,   p_low_order_number  IN 	NUMBER
         ,   p_high_order_number IN	NUMBER
         ,   p_low_cdate        IN	DATE
         ,   p_high_cdate       IN	DATE
         ,   p_low_ddate        IN 	DATE
         ,   p_high_ddate       IN 	DATE
         ,   p_order_category   IN 	VARCHAR2
         ,   p_order_type_id    IN 	NUMBER
         ,   p_customer_id      IN 	NUMBER
          );

  FUNCTION so_check_open_invoiced_orders
             ( p_order_number            IN VARCHAR2,
               p_order_type_name         IN VARCHAR2 )  RETURN NUMBER;

  FUNCTION so_check_open_demand_orders
             ( p_order_number            IN VARCHAR2,
               p_order_type_name         IN VARCHAR2 )  RETURN NUMBER;

  FUNCTION so_check_open_orders
             ( p_order_number            IN VARCHAR2,
               p_order_type_name         IN VARCHAR2 )  RETURN NUMBER;

  FUNCTION so_check_open_returns
              ( p_order_number           IN NUMBER,
		p_order_type_name        IN VARCHAR2 )  RETURN NUMBER;


  PROCEDURE so_order_purge
              ( p_dummy_1                IN VARCHAR2,
		p_dummy_2		 IN VARCHAR2,
                p_commit_point           IN NUMBER );

  FUNCTION so_purge_freight_charges
              ( p_picking_header_id      IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_headers
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_hold_releases
              ( p_release_id             IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_hold_sources
              ( p_source_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_line_approvals
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_line_details
              ( p_line_id                IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_line_service_details
              ( p_line_id                IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_lines
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_note_references
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_order_approvals
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_order_cancel_lines
              ( p_line_id                IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_mtl_so_rma_interface
              ( p_line_id                IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_mtl_so_rma_receipts
              ( p_rma_interface_id                IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_order_cancellations
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_order_holds
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_batches
              ( p_batch_id               IN NUMBER,
                p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_cancellations
              ( p_picking_line_id        IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_headers
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_line_details
              ( p_picking_line_id        IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_lines
              ( p_picking_header_id      IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_backorder_cancelled
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_picking_rules
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_price_adjustments
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  FUNCTION so_purge_sales_credits
              ( p_header_id              IN NUMBER,
                p_request_id             IN NUMBER )  RETURN NUMBER;

  PROCEDURE so_record_errors
              ( p_return_status          IN NUMBER,
                p_request_id             IN NUMBER,
                p_id_number              IN NUMBER,
                p_context                IN VARCHAR2,
                p_error_message          IN VARCHAR2 );

END OEXPURGE;  -- specification

 

/
