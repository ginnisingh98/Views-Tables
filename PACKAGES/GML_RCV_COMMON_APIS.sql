--------------------------------------------------------
--  DDL for Package GML_RCV_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RCV_COMMON_APIS" AUTHID CURRENT_USER AS
  /* $Header: GMLRCVAS.pls 120.0 2005/05/25 16:46:05 appldev noship $*/

TYPE trans_rec_type IS RECORD
  (transaction_id NUMBER,
   primary_quantity NUMBER,
   item_no  VARCHAR2(40),
   unit_of_measure  VARCHAR2(100));

TYPE trans_rec_tb_tp IS TABLE OF trans_rec_type
  INDEX BY BINARY_INTEGER;


  PROCEDURE insert_mtlt(p_mtlt_rec mtl_transaction_lots_temp%ROWTYPE);

  FUNCTION break_lots_only(p_original_tid IN mtl_transaction_lots_temp.transaction_temp_id%TYPE,
                           p_new_transactions_tb IN trans_rec_tb_tp)
    RETURN BOOLEAN;

  PROCEDURE BREAK(
    p_original_tid        IN mtl_transaction_lots_temp.transaction_temp_id%TYPE
  , p_new_transactions_tb IN trans_rec_tb_tp
  , p_lot_control_code    IN NUMBER
  , p_serial_control_code IN NUMBER
  );

END GML_RCV_COMMON_APIS;

 

/
