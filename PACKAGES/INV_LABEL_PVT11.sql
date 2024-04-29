--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT11" AUTHID CURRENT_USER AS
  /* $Header: INVLA11S.pls 120.0 2005/06/21 02:38:00 fabdi noship $ */

  g_pkg_name CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT11';
  g_lpn_id            NUMBER       := -1;



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
END inv_label_pvt11;

 

/
