--------------------------------------------------------
--  DDL for Package Body MISC_TRANSACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MISC_TRANSACTIONS_UTIL" AS
/* $Header: INVTXUTB.pls 120.1 2005/06/17 17:52:40 appldev  $*/

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MISC_TRANSACTIONS_UTIL';
g_debug_init                  BOOLEAN := FALSE;
g_fd                          utl_file.file_type;
g_trace_on                    NUMBER := 0;          -- Log ON state


PROCEDURE init_misc_transaction_values(
      p_organization_id IN NUMBER,
      p_account_segments IN VARCHAR2 DEFAULT NULL,
      x_is_negative_quantity_allowed OUT NOCOPY VARCHAR2,
      x_is_wms_purchased OUT NOCOPY VARCHAR2,
      x_is_wms_installed OUT NOCOPY VARCHAR2,
      x_transaction_header_id OUT NOCOPY NUMBER,
      x_account_disposition_id OUT NOCOPY NUMBER,
      x_stock_locator_control_code OUT NOCOPY NUMBER,
      x_primary_cost_method OUT NOCOPY NUMBER
      )
  IS
   l_tmp_num NUMBER;
   l_tmp_vc VARCHAR2(100);
   l_return_status VARCHAR2(100);

BEGIN

   -- get stock locator, primary_cost_method, negative qty allowed --
   BEGIN
   SELECT Nvl(stock_locator_control_code, -1), primary_cost_method, Nvl(NEGATIVE_INV_RECEIPT_CODE, -1)
    INTO x_stock_locator_control_code, x_primary_cost_method, l_tmp_num
    FROM mtl_parameters
    WHERE organization_id = p_organization_id;
   IF (l_tmp_num = 1) THEN
    x_is_negative_quantity_allowed := 'TRUE';
   ELSE
    x_is_negative_quantity_allowed := 'FALSE';
   END IF;
   EXCEPTION
     WHEN OTHERS THEN
      x_stock_locator_control_code := -1;
      x_primary_cost_method := -1;
      x_is_negative_quantity_allowed := 'FALSE';
   END;

   -- get account disposition id --
   IF (p_account_segments IS NOT NULL) THEN
     BEGIN
     SELECT Nvl(disposition_id, -1)
      INTO x_account_disposition_id
      FROM mtl_generic_dispositions_kfv
      WHERE concatenated_segments = p_account_segments
       AND organization_id = p_organization_id;
     EXCEPTION
      WHEN OTHERS THEN
       x_account_disposition_id := -1;
     END;
   ELSE
     x_account_disposition_id := -1;
   END IF;

   -- get wms install info --
   -- passed out status, out msg_count, out msg_data, in org
   BEGIN
   IF wms_install.check_install(l_return_status, l_tmp_num, l_tmp_vc, p_organization_id) THEN
     x_is_wms_installed := 'TRUE';
   ELSE
     x_is_wms_installed := 'FALSE';
   END IF;
   EXCEPTION
    WHEN OTHERS THEN
     x_is_wms_installed := 'FALSE';
   END;


   -- get wms purchased info --
   -- passed out status, out msg_count, out msg_data, in org
   BEGIN
   IF wms_install.check_install(l_return_status, l_tmp_num, l_tmp_vc, NULL) THEN
     x_is_wms_purchased := 'TRUE';
   ELSE
     x_is_wms_purchased := 'FALSE';
   END IF;
   EXCEPTION
    WHEN OTHERS THEN
     x_is_wms_purchased := 'FALSE';
   END;


   -- get transaction_header_id --
   BEGIN
   SELECT mtl_material_transactions_s.nextval
    INTO x_transaction_header_id
    FROM DUAL;
   EXCEPTION
    WHEN OTHERS THEN
     x_transaction_header_id := -1;
   END;


END init_misc_transaction_values;
END MISC_TRANSACTIONS_UTIL;

/
