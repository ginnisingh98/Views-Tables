--------------------------------------------------------
--  DDL for Package WMS_TASK_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: WMSTSKUS.pls 120.1.12000000.1 2007/01/16 06:57:50 appldev ship $ */

subtype mmtt_type is mtl_material_transactions_temp%ROWTYPE;
TYPE MMTT_TB IS TABLE OF  mmtt_type INDEX BY  BINARY_INTEGER;


subtype mtlt_type is mtl_transaction_lots_temp%ROWTYPE;
TYPE MTLT_TB IS TABLE OF  mtlt_type INDEX BY  BINARY_INTEGER;

subtype msnt_type is mtl_serial_numbers_temp%ROWTYPE;
TYPE MSNT_TB IS TABLE OF  msnt_type INDEX BY  BINARY_INTEGER;


subtype mmt_type is mtl_material_transactions%ROWTYPE;


subtype mtln_type is mtl_transaction_lot_numbers%ROWTYPE;


subtype mut_type is mtl_unit_transactions%ROWTYPE;

g_qty_not_avail EXCEPTION;

  PROCEDURE unload_task
(
     x_ret_value           OUT NOCOPY NUMBER
   , x_message             OUT NOCOPY VARCHAR2
   , p_temp_id             IN NUMBER );

PROCEDURE mydebug(msg in varchar2) ;


FUNCTION can_drop(p_lpn_id IN NUMBER)
  return VARCHAR2;


PROCEDURE Is_task_processed
  (
   x_processed           OUT NOCOPY VARCHAR2
   , p_header_id             IN NUMBER);



PROCEDURE generate_next_task
   (
    x_return_status	   OUT   NOCOPY VARCHAR2,
    x_msg_count       	   OUT   NOCOPY NUMBER,
    x_msg_data        	   OUT   NOCOPY VARCHAR2,
    x_ret_code             OUT   NOCOPY VARCHAR2,
    p_old_header_id        IN    NUMBER,
    p_mo_line_id           IN    NUMBER,
    p_old_sub_CODE         IN    VARCHAR2,
    p_old_loc_id           IN    NUMBER,
    p_wms_task_type        IN    NUMBER
    );

PROCEDURE get_temp_tables
  ( p_set_id               IN NUMBER ,
    x_mmtt                 OUT NOCOPY mmtt_tb,
    x_mtlt                 OUT NOCOPY mtlt_tb,
    x_msnt                 OUT NOCOPY msnt_tb
    );



PROCEDURE cancel_task
(
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_emp_id       IN NUMBER,
     p_temp_id        IN NUMBER,
     p_previous_task_status IN NUMBER := -1/*added for 3602199*/);

/*****************************************************************/
--This function is called from the currentTasksFListener on pressing
--the Unload button,
--returns Y if you can continue with the unload,
--returns E,U if an error occurred in this api
--returns N if you cannot unload and puts the appropriate error in the stack
--returns M if you cannot unload because lpn has multiple allocations
/*****************************************************************/

FUNCTION can_unload(p_temp_id IN NUMBER)
  return VARCHAR2;

/* over loaded the procedure can_unload to resolve the JDBC error */
PROCEDURE can_unload(x_can_unload out  NOCOPY VARCHAR2, p_temp_id IN NUMBER);

END  wms_TASK_UTILS_pvt;

 

/
