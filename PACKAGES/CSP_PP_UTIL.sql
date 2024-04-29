--------------------------------------------------------
--  DDL for Package CSP_PP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PP_UTIL" AUTHID CURRENT_USER AS
/* $Header: cspgtpps.pls 115.4 2002/11/26 06:42:47 hhaugeru ship $ */


TYPE g_mmtt_tbl_type IS TABLE OF mtl_material_transactions_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;
TYPE g_mtlt_tbl_type IS TABLE OF mtl_transaction_lots_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;
TYPE g_msnt_tbl_type IS TABLE OF mtl_serial_numbers_temp%ROWTYPE
  INDEX BY BINARY_INTEGER;

PROCEDURE insert_mtlt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_mtlt_tbl       IN  g_mtlt_tbl_type
   ,p_mtlt_tbl_size  IN  INTEGER
   );
--
-- insert record into mtl_serial_numbers_temp
-- who columns will be derived in the procedure
PROCEDURE insert_msnt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_msnt_tbl       IN  g_msnt_tbl_type
   ,p_msnt_tbl_size  IN  INTEGER
   );
--
-- Start of comments
-- Name        : split_prefix_num
-- Function    : Separates prefix and numeric part of a serial number
-- Pre-reqs    : none
-- Parameters  :
--  p_serial_number        in     varchar2
--  p_prefix               in/out varchar2      the prefix
--  x_num                  out    varchar2(30)  the numeric portion
-- Notes       : privat procedure for internal use only
--               needed only once serial numbers are supported
-- End of comments
--
PROCEDURE split_prefix_num
  (
    p_serial_number        IN     VARCHAR2
   ,p_prefix               IN OUT NOCOPY VARCHAR2
   ,x_num                  OUT NOCOPY    VARCHAR2
   );
--
-- For serial number support
FUNCTION subtract_serials
  (
   p_operand1      IN VARCHAR2,
   p_operand2      IN VARCHAR2
   ) RETURN NUMBER;

FUNCTION get_item_name (p_item_id NUMBER)
    RETURN VARCHAR2;

END csp_pp_util;

 

/
