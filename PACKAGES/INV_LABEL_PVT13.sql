--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT13
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT13" AUTHID CURRENT_USER AS
  /* $Header: INVLA13S.pls 120.1 2006/05/08 22:41:32 rahugupt noship $ */

  g_pkg_name CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT13';
  g_lpn_id            NUMBER       := -1;


-- Record type to get batch and product information.

TYPE batch_label_type_rec is RECORD
(
 	  organization     VARCHAR2(3),
      subinventory_code     VARCHAR2(10),
	  locator            VARCHAR2(204) ,
	  item 	  			 VARCHAR2(40) ,
	  batch_no 			 VARCHAR2(32),
	  quantity 			 NUMBER ,
      transaction_uom 	 VARCHAR2(3),
      secondary_quantity NUMBER,
	  uom2 				 VARCHAR2(3) ,
	  reason_name        VARCHAR2(30),
      org_id    		 NUMBER,
	  item_id  			 NUMBER,
	  locator_id         NUMBER,
	  reason_id  		 NUMBER,
      batch_id 		     NUMBER,
      formula_no         VARCHAR2(32),
	  routing_no         VARCHAR2(32),
	  creation_date 	 VARCHAR2(100),
	  planned_start_date VARCHAR2(100),
	  actual_start_date  VARCHAR2(100),
	  due_date   		 VARCHAR2(100),
	  planned_completion_date    VARCHAR2(100),
	  actual_completion_date     VARCHAR2(100),
	  batch_close_date   VARCHAR2(100),
	  material_detail_id NUMBER,
	  planned_quantity 	 NUMBER,
	  item_uom           VARCHAR2(3),
	  actual_quantity    NUMBER	,
	  hazard_class       VARCHAR2(40),
	  lot_number         VARCHAR2(80),
	  parent_lot_number  VARCHAR2(80),
	  grade_code         VARCHAR2(150),
	  status             VARCHAR2(250),
	  lot_creation_date  VARCHAR2(100),
	  lot_expiration_date 	 VARCHAR2(100),
	  lot_quantity	  NUMBER,
	  lot_quantity2	  NUMBER,
	  batch_line			varchar2(200)
);

  TYPE batch_table_type IS TABLE OF batch_label_type_rec
    INDEX BY BINARY_INTEGER;


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
END inv_label_pvt13;

 

/
