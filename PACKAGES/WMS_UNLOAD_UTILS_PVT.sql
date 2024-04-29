--------------------------------------------------------
--  DDL for Package WMS_UNLOAD_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_UNLOAD_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: WMSUNLDS.pls 120.0.12000000.1 2007/01/16 06:57:59 appldev ship $ */

  PROCEDURE unload_task
  ( x_ret_value  OUT NOCOPY  NUMBER
  , x_message    OUT NOCOPY  VARCHAR2
  , p_temp_id    IN          NUMBER
  );

  PROCEDURE unload_bulk_task
  ( x_next_temp_id   OUT NOCOPY  NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  , p_txn_temp_id    IN          NUMBER
  );

END WMS_UNLOAD_UTILS_PVT;

 

/
