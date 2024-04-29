--------------------------------------------------------
--  DDL for Package Body CSP_PP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PP_UTIL" AS
/* $Header: cspgtppb.pls 115.4 2002/11/26 06:43:30 hhaugeru noship $ */
--
-- File        : cspgtppb.pls
-- Content     :
-- Description :
-- Notes       :
-- Modified    : 07/31/99 bitang created
--
g_pkg_name VARCHAR2(30) := 'CSP_PP_UTIL';
g_file_name VARCHAR2(30) := 'cspgtppb.pls';
TYPE g_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--
-- insert record into mtl_transaction_lots_temp
PROCEDURE insert_mtlt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_mtlt_tbl       IN  g_mtlt_tbl_type
   ,p_mtlt_tbl_size  IN  INTEGER
   )
  IS
     l_api_name  CONSTANT VARCHAR2(30) := 'insert_mtlt';
     l_today     DATE;
     l_user_id   NUMBER;
     l_login_id  NUMBER;
     l_rowid     VARCHAR2(20);
BEGIN

   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF p_mtlt_tbl_size IS NULL OR p_mtlt_tbl_size < 1 THEN
      RETURN;
   END IF;
   --
   SELECT Sysdate INTO l_today FROM dual;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   FOR l_counter IN 1..p_mtlt_tbl_size LOOP
      INSERT INTO mtl_transaction_lots_temp
    (
      transaction_temp_id
     ,last_update_date
     ,last_updated_by
     ,creation_date
     ,created_by
     ,last_update_login
     ,request_id
     ,program_application_id
     ,program_id
     ,program_update_date
     ,transaction_quantity
     ,primary_quantity
     ,lot_number
     ,lot_expiration_date
     ,error_code
     ,serial_transaction_temp_id
     ,group_header_id
     ,put_away_rule_id
     ,pick_rule_id
     )
    VALUES
    (
      p_mtlt_tbl(l_counter).transaction_temp_id
     ,l_today
     ,l_user_id
     ,l_today
     ,l_user_id
     ,l_login_id
     ,p_mtlt_tbl(l_counter).request_id
     ,p_mtlt_tbl(l_counter).program_application_id
     ,p_mtlt_tbl(l_counter).program_id
     ,p_mtlt_tbl(l_counter).program_update_date
     ,p_mtlt_tbl(l_counter).transaction_quantity
     ,p_mtlt_tbl(l_counter).primary_quantity
     ,p_mtlt_tbl(l_counter).lot_number
     ,p_mtlt_tbl(l_counter).lot_expiration_date
     ,p_mtlt_tbl(l_counter).error_code
     ,p_mtlt_tbl(l_counter).serial_transaction_temp_id
     ,p_mtlt_tbl(l_counter).group_header_id
     ,p_mtlt_tbl(l_counter).put_away_rule_id
     ,p_mtlt_tbl(l_counter).pick_rule_id
     );
   END LOOP;
   --
EXCEPTION
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;
      --
   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   when others then
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      /*if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
      end if;*/
      --
END insert_mtlt;
--
-- insert record into mtl_serial_numbers_temp
PROCEDURE insert_msnt
  (
    x_return_status  OUT NOCOPY VARCHAR2
   ,p_msnt_tbl       IN  g_msnt_tbl_type
   ,p_msnt_tbl_size  IN  INTEGER
   )
  IS
     l_api_name  CONSTANT VARCHAR2(30) := 'Insert_MSNT';
     l_today     DATE;
     l_user_id   NUMBER;
     l_login_id  NUMBER;
     l_rowid     VARCHAR2(20);
BEGIN
   --
   -- Initialisize API return status to access
   x_return_status := fnd_api.g_ret_sts_success;
   IF p_msnt_tbl_size IS NULL OR p_msnt_tbl_size < 1 THEN
      RETURN;
   END IF;
   --
   SELECT Sysdate INTO l_today FROM dual;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;
   FOR l_counter IN 1..p_msnt_tbl_size LOOP
      INSERT INTO mtl_serial_numbers_temp
    (
      transaction_temp_id
     ,last_update_date
     ,last_updated_by
     ,creation_date
     ,created_by
     ,last_update_login
     ,request_id
     ,program_application_id
     ,program_id
     ,program_update_date
     ,vendor_serial_number
     ,vendor_lot_number
     ,fm_serial_number
     ,to_serial_number
     ,serial_prefix
     ,error_code
     ,group_header_id
     ,parent_serial_number
     ,end_item_unit_number
     )
    VALUES
    (
      p_msnt_tbl(l_counter).transaction_temp_id
     ,l_today
     ,l_user_id
     ,l_today
     ,l_user_id
     ,l_login_id
     ,p_msnt_tbl(l_counter).request_id
     ,p_msnt_tbl(l_counter).program_application_id
     ,p_msnt_tbl(l_counter).program_id
     ,p_msnt_tbl(l_counter).program_update_date
     ,p_msnt_tbl(l_counter).vendor_serial_number
     ,p_msnt_tbl(l_counter).vendor_lot_number
     ,p_msnt_tbl(l_counter).fm_serial_number
     ,p_msnt_tbl(l_counter).to_serial_number
     ,p_msnt_tbl(l_counter).serial_prefix
     ,p_msnt_tbl(l_counter).error_code
     ,p_msnt_tbl(l_counter).group_header_id
     ,p_msnt_tbl(l_counter).parent_serial_number
     ,p_msnt_tbl(l_counter).end_item_unit_number
     );

   END LOOP;

EXCEPTION
   when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;
      --
   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END insert_msnt;
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
   ) is
      l_counter                     number;
BEGIN
   IF p_prefix IS NOT NULL THEN
      x_num := SUBSTR(p_serial_number,length(p_prefix)+1);
    ELSE
      l_counter := length(p_serial_number);
      WHILE l_counter >= 0 AND SUBSTR(p_serial_number,l_counter,1) >= '0' AND
    SUBSTR(p_serial_number,l_counter,1) <= '9'
    LOOP
       l_counter := l_counter - 1;
    END LOOP;
    IF l_counter = 0 THEN
       p_prefix := NULL;
     ELSE
       p_prefix := SUBSTR(p_serial_number,1,l_counter);
    END IF;
    x_num := SUBSTR(p_serial_number,l_counter+1);
   END IF;
END split_prefix_num;
--
-- For serial number support
FUNCTION subtract_serials
  (
   p_operand1      IN VARCHAR2,
   p_operand2      IN VARCHAR2
   ) RETURN NUMBER IS
      l_prefix1       VARCHAR2(30);
      l_prefix2       VARCHAR2(30);
      l_num1          NUMBER;
      l_num2          NUMBER;
      l_return        NUMBER;
BEGIN
   split_prefix_num(p_operand1,l_prefix1,l_num1);
   split_prefix_num(p_operand2,l_prefix2,l_num2);
   IF l_prefix1 = l_prefix2
     OR l_prefix1 IS NULL AND l_prefix2 IS NULL THEN
      l_return := NVL(l_num2,0) - NVL(l_num1,0);
    ELSE
      l_return := 0;
   END IF;
   RETURN(l_return);
END subtract_serials;

FUNCTION get_item_name (p_item_id NUMBER)
    RETURN VARCHAR2
IS
    l_item_name VARCHAR2(50);

BEGIN
    SELECT distinct concatenated_segments INTO l_item_name
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_item_id;

    RETURN l_item_name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END get_item_name;



END csp_pp_util;

/
