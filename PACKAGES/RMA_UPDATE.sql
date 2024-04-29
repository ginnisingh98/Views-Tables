--------------------------------------------------------
--  DDL for Package RMA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RMA_UPDATE" AUTHID CURRENT_USER AS
/* $Header: INVRMAUS.pls 120.1 2005/06/11 12:42:13 appldev  $ */
Procedure update_rma_receipts(header_id_value number, trx_rma_id number,
success OUT NOCOPY /* file.sql.39 change */ boolean);
Procedure update_rma_receipts_rpc(header_id_value number, trx_rma_id number,
success OUT NOCOPY /* file.sql.39 change */ boolean);
Procedure update_rma_returns(header_id_value number, trx_rma_id number,
success OUT NOCOPY /* file.sql.39 change */ boolean);
Procedure update_rma_returns_rpc(header_id_value number, trx_rma_id number,
success OUT NOCOPY /* file.sql.39 change */ boolean);
Procedure gen_sales_order_id(r_number varchar2, r_type varchar2,
r_source_code varchar2, r_id OUT NOCOPY /* file.sql.39 change */ number) ;
END rma_update;

 

/
