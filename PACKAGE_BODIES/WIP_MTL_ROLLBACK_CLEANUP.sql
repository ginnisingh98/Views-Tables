--------------------------------------------------------
--  DDL for Package Body WIP_MTL_ROLLBACK_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTL_ROLLBACK_CLEANUP" AS
/* $Header: wipmtrbb.pls 115.5 2002/12/13 08:07:20 rmahidha ship $ */
Procedure DELETE_ROWS (trx_header_id NUMBER) IS
BEGIN
      -- Delete predefined serial numbers
      delete mtl_serial_numbers
      where group_mark_id = trx_header_id ;

      -- Unmark serial numbers
      update mtl_serial_numbers
      set group_mark_id = null,
          line_mark_id = null,
          lot_line_mark_id = null
      where group_mark_id = trx_header_id;

      -- Delete lot and serial records from temp tables
      delete mtl_serial_numbers_temp
      where group_header_id = trx_header_id;

      delete mtl_transaction_lots_temp
      where group_header_id = trx_header_id;

      delete mtl_material_transactions_temp
      where transaction_header_id = trx_header_id;

      commit;

      EXCEPTION
        WHEN others then
          null;
end DELETE_ROWS;

end WIP_MTL_ROLLBACK_CLEANUP ;

/
