--------------------------------------------------------
--  DDL for Package Body INV_INTER_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INTER_INVOICE" AS
   /* $Header: INVITCIB.pls 120.4 2006/11/11 16:00:09 ankulkar noship $ */
   g_version_printed BOOLEAN := FALSE;
   g_pkg_name  CONSTANT VARCHAR2(30)   := 'INV:inliar';

   Procedure print_debug(p_message IN VARCHAR2,
		      p_module IN VARCHAR2)
   IS
   BEGIN
      IF NOT g_version_printed THEN
            INV_TRX_UTIL_PUB.TRACE('$Header: INVITCIB.pls 120.4 2006/11/11 16:00:09 ankulkar noship $',G_PKG_NAME, 9);
            g_version_printed := TRUE;
         END IF;
         inv_log_util.trace(p_message, p_module);
   END;

  PROCEDURE update_invoice_flag(p_header_id IN NUMBER, p_line_id IN NUMBER) IS
    x_return_status      VARCHAR2(30);
    --g_pkg_name  CONSTANT VARCHAR2(30)   := 'INV:inliar';
    d_sql_p              INTEGER        := NULL;
    d_sql_rows_processed INTEGER        := NULL;
    d_sql_stmt           VARCHAR2(6000) := NULL;
    d_priceadjustmentid  NUMBER;
    l_debug              NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_module             VARCHAR2(50)   := 'INV_INTER_INVOICE.update_invoice_flag';
  BEGIN
    IF l_debug = 1 THEN
      /*inv_log_util.TRACE('Parameters Passed ', l_module);
      inv_log_util.TRACE('p_header_id :' || p_header_id, l_module);
      inv_log_util.TRACE('p_line_id :' || p_line_id, l_module);*/
      print_debug('Parameters Passed ', l_module);
      print_debug('p_header_id :' || p_header_id, l_module);
      print_debug('p_line_id :' || p_line_id, l_module);
    END IF;

    d_sql_p               := DBMS_SQL.open_cursor;
    d_sql_stmt            :=
         'select  price_adjustment_id '
      || 'FROM oe_price_adjustments WHERE '
      || '( line_id =  :line_id OR '
      || '(header_id = :header_id AND line_id IS NULL) )'
      || 'AND nvl(interco_invoiced_flag,''N'') = ''N'' ';
    DBMS_SQL.parse(d_sql_p, d_sql_stmt, DBMS_SQL.native);
    DBMS_SQL.define_column(d_sql_p, 1, d_priceadjustmentid);
    DBMS_SQL.bind_variable(d_sql_p, 'line_id', p_line_id);
    DBMS_SQL.bind_variable(d_sql_p,'header_id',p_header_id);
    d_sql_rows_processed  := DBMS_SQL.EXECUTE(d_sql_p);

    LOOP
      IF (DBMS_SQL.fetch_rows(d_sql_p) > 0) THEN
        DBMS_SQL.column_value(d_sql_p, 1, d_priceadjustmentid);

        IF l_debug = 1 THEN
          /*inv_log_util.TRACE('Calling OE_INVOICE_UTIL.Update_Interco_Invoiced_Flag for d_priceAdjustmentId :' || d_priceadjustmentid
          , l_module);*/
           print_debug('Calling OE_INVOICE_UTIL.Update_Interco_Invoiced_Flag for d_priceAdjustmentId :' || d_priceadjustmentid
          , l_module);
        END IF;

        oe_invoice_util.update_interco_invoiced_flag(d_priceadjustmentid, x_return_status);
      ELSE
        -- No more rows in cursor
        DBMS_SQL.close_cursor(d_sql_p);
        EXIT;
      END IF;
    END LOOP;

    IF DBMS_SQL.is_open(d_sql_p) THEN
      DBMS_SQL.close_cursor(d_sql_p);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.is_open(d_sql_p) THEN
        DBMS_SQL.close_cursor(d_sql_p);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        oe_msg_pub.add_exc_msg(g_pkg_name, 'Update_Invoiced_flag');
        /*inv_log_util.TRACE ('Unexpected Error occured while calling OE_INVOICE_UTIL.Update_Interco_Invoiced_Flag for d_priceAdjustmentId :'|| d_priceadjustmentid, l_module);        */
        print_debug('Unexpected Error occured while calling OE_INVOICE_UTIL.Update_Interco_Invoiced_Flag for d_priceAdjustmentId :'|| d_priceadjustmentid, l_module);
      END IF;
  END update_invoice_flag;



END inv_inter_invoice;

/
