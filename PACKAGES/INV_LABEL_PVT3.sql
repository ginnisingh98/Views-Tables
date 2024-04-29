--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT3" AUTHID CURRENT_USER AS
  /* $Header: INVLAP3S.pls 120.0.12010000.1 2008/07/24 01:37:40 appldev ship $ */
  g_pkg_name CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT3';
  g_lpn_id            NUMBER       := -1;

  /* Patchset J Project Label enhancements for inbound - Label printing is now called
   * with Group_Id rather than one RTI record, there may be multiple purchase orders
   * for a group of RTI records. So we need a new record and a table of this record type
   */
  TYPE rcv_label_type_rec IS RECORD(
    lpn_id                        NUMBER
  , purchase_order                VARCHAR2(20)
  , subinventory_code             VARCHAR2(30)
  , locator_id                    NUMBER);

  TYPE rcv_lpn_table_type IS TABLE OF rcv_label_type_rec
    INDEX BY BINARY_INTEGER;

-- Record type to hold LPN information specific to iSupplierPortal
TYPE rcv_isp_header_rec is RECORD
(
     asn_num                 VARCHAR2(30),
     shipment_date           DATE,
     expected_receipt_date   DATE,
     freight_terms           VARCHAR2(25),
     freight_carrier         VARCHAR2(25),
     num_of_containers       NUMBER,
     bill_of_lading          VARCHAR2(25),
     waybill_airbill_num     VARCHAR2(20),
     packing_slip            VARCHAR2(25),
     packaging_code          VARCHAR2(5),
     special_handling_code   VARCHAR2(3),
     locator_id              NUMBER,
     receipt_num             VARCHAR2(30),
     comments                VARCHAR2(240)
);

  -- Added p_transaction_identifier, for flow
    -- Depending on when it is called, the driving table might be different
    -- 1 means MMTT is the driving table
    -- 2 means MTI is the driving table
  -- 3 means Mtl_txn_request_lines is the driving table

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    LONG
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec DEFAULT NULL
  , p_transaction_id         IN            NUMBER DEFAULT NULL
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
        DEFAULT NULL
  , p_transaction_identifier IN            NUMBER DEFAULT 0
  );

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    inv_label.label_tbl_type
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec DEFAULT NULL
  , p_transaction_id         IN            NUMBER DEFAULT NULL
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
        DEFAULT NULL
  , p_transaction_identifier IN            NUMBER DEFAULT 0
  );
END inv_label_pvt3;

/
