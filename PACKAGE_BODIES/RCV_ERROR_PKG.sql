--------------------------------------------------------
--  DDL for Package Body RCV_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ERROR_PKG" AS
/* $Header: RCVERRB.pls 120.1 2005/08/12 15:44:34 wkunz noship $*/
   pg_current_result                  VARCHAR2(1)                                    := g_ret_sts_success;
   pg_current_error_name              fnd_new_messages.message_name%TYPE;
   pg_current_error_text              fnd_new_messages.MESSAGE_TEXT%TYPE;
   pg_error_count                     NUMBER                                         := 0;
   pg_error_stack                     VARCHAR2(10000);
   pg_interface_type                  po_interface_errors.interface_type%TYPE;
   pg_batch_id                        po_interface_errors.batch_id%TYPE;
   pg_header_id                       po_interface_errors.interface_header_id%TYPE;
   pg_line_id                         po_interface_errors.interface_line_id%TYPE;
   pg_line_return                     VARCHAR2(2)                                    := fnd_global.local_chr(10);
   pg_message_pending                 BOOLEAN                                        := FALSE;
   pg_transactions_interface CONSTANT po_interface_errors.table_name%TYPE            := 'RCV_TRANSACTIONS_INTERFACE';
   pg_default_interface_type CONSTANT po_interface_errors.interface_type%TYPE        := 'RCV-856';

   PROCEDURE pop_error_message IS
   BEGIN
      pg_current_error_text  := fnd_message.get();
      pg_error_stack         := pg_error_stack || pg_line_return || pg_current_error_name;
      pg_error_count         := pg_error_count + 1;
      pg_message_pending     := FALSE;
   END pop_error_message;

   PROCEDURE po_interface_call(
      p_error_type  IN VARCHAR2,
      p_table_name  IN VARCHAR2,
      p_column_name IN VARCHAR2,
      p_batch_id    IN NUMBER DEFAULT pg_batch_id,
      p_header_id   IN NUMBER DEFAULT pg_header_id,
      p_line_id     IN NUMBER DEFAULT pg_line_id
   ) IS
      x_dummy_flag VARCHAR2(1);
      x_error_type_message VARCHAR2(100);
   BEGIN
      asn_debug.put_line('error stack from call to po_interface_call');
      asn_debug.print_stack;

      IF p_error_type = 'FATAL' THEN
         fnd_message.set_name('PO', 'PO_ERROR');
         x_error_type_message := fnd_message.get;
      ELSIF p_error_type = 'WARNING' THEN
         fnd_message.set_name('PO', 'PO_WARNING');
         x_error_type_message := fnd_message.get;
      END IF;

      po_interface_errors_sv1.handle_interface_errors_msg(NVL(pg_interface_type, pg_default_interface_type),
                                                          p_error_type,
                                                          p_batch_id,
                                                          p_header_id,
                                                          p_line_id,
                                                          x_error_type_message||' '||pg_current_error_text,
                                                          pg_current_error_name,
                                                          p_table_name,
                                                          p_column_name,
                                                          x_dummy_flag
                                                         );
   END po_interface_call;

   PROCEDURE log_interface_error(
      p_table       IN VARCHAR2,
      p_column      IN VARCHAR2,
      p_batch_id    IN NUMBER,
      p_header_id   IN NUMBER,
      p_line_id     IN NUMBER,
      p_raise_error IN BOOLEAN DEFAULT TRUE
   ) IS
   BEGIN
      IF (pg_message_pending = TRUE) THEN
         pop_error_message();
         asn_debug.put_line('logging error ' || pg_current_error_text || ' on column ' || p_column, fnd_log.level_error);
         pg_current_result  := g_ret_sts_error;
         po_interface_call('FATAL',
                           p_table,
                           p_column,
                           p_batch_id,
                           p_header_id,
                           p_line_id
                          );

         IF (p_raise_error = TRUE) THEN
            RAISE e_fatal_error;
         END IF;
      ELSE
         asn_debug.put_line('WARNING: log_interface_error called without setting an error', fnd_log.level_error);
      END IF;
   END log_interface_error;

   PROCEDURE log_interface_error(
      p_table       IN VARCHAR2,
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN
   ) IS
   BEGIN
      log_interface_error(p_table,
                          p_column,
                          pg_batch_id,
                          pg_header_id,
                          pg_line_id,
                          p_raise_error
                         );
   END log_interface_error;

   PROCEDURE log_interface_error(
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN
   ) IS
   BEGIN
      log_interface_error(pg_transactions_interface,
                          p_column,
                          p_raise_error
                         );
   END log_interface_error;

   PROCEDURE log_interface_error_message(
      p_error_message IN VARCHAR2
   ) IS
      x_dummy_flag VARCHAR2(1);
   BEGIN
      asn_debug.put_line('logging error ' || pg_current_error_text || ' on column INTERFACE_TRANSACTION_ID', fnd_log.level_error);
      asn_debug.put_line('error stack from call to po_interface_call');
      asn_debug.print_stack;
      pg_current_result  := g_ret_sts_error;
      po_interface_errors_sv1.handle_interface_errors_msg(NVL(pg_interface_type, pg_default_interface_type),
                                                          'FATAL',
                                                          pg_batch_id,
                                                          pg_header_id,
                                                          pg_line_id,
                                                          p_error_message,
                                                          NULL,
                                                          pg_transactions_interface,
                                                          'INTERFACE_TRANSACTION_ID',
                                                          x_dummy_flag
                                                         );
   END log_interface_error_message;

   PROCEDURE log_interface_warning(
      p_table  IN VARCHAR2,
      p_column IN VARCHAR2
   ) IS
   BEGIN
      IF (pg_message_pending = TRUE) THEN
         pop_error_message();
         pg_current_result  := g_ret_sts_warning;
         po_interface_call('WARNING',
                           p_table,
                           p_column
                          );
      ELSE
         asn_debug.put_line('WARNING: log_interface_warning called without setting a warning', fnd_log.level_error);
      END IF;
   END log_interface_warning;

/* This log_interface_message call ues the internal error flag what kind of message to log */
   PROCEDURE log_interface_message(
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN
   ) IS
   BEGIN
      log_interface_message(pg_current_result,
                            p_column,
                            p_raise_error
                           );
   END log_interface_message;

   PROCEDURE log_interface_warning(
      p_column IN VARCHAR2
   ) IS
   BEGIN
      log_interface_warning(pg_transactions_interface, p_column);
   END log_interface_warning;

/* log_interface_message takes an indicator variable and logs error/warning/ignore as appropriate*/
   PROCEDURE log_interface_message(
      p_error_status IN VARCHAR2,
      p_table        IN VARCHAR2,
      p_column       IN VARCHAR2,
      p_raise_error  IN BOOLEAN DEFAULT TRUE
   ) IS
   BEGIN
      IF (p_error_status IN(g_ret_sts_error, g_ret_sts_unexp_error)) THEN
         log_interface_error(p_table,
                             p_column,
                             p_raise_error
                            );
      ELSIF(p_error_status = g_ret_sts_warning) THEN
         log_interface_warning(p_table, p_column);
      END IF;
   END log_interface_message;

/* This log_interface_message call assumes p_table = 'RCV_TRANSACTIONS_INTERFACE' */
   PROCEDURE log_interface_message(
      p_error_status IN VARCHAR2,
      p_column       IN VARCHAR2,
      p_raise_error  IN BOOLEAN DEFAULT TRUE
   ) IS
   BEGIN
      log_interface_message(p_error_status,
                            pg_transactions_interface,
                            p_column,
                            p_raise_error
                           );
   END log_interface_message;

   PROCEDURE set_error_message(
      p_message IN VARCHAR2
   ) IS
   BEGIN
      IF (    pg_message_pending = TRUE
          AND pg_current_error_name <> p_message) THEN
         asn_debug.put_line('WARNING: message ' || pg_current_error_name || ' set but never used', fnd_log.level_error);
      END IF;

      asn_debug.put_line('set error message token = ' || p_message, fnd_log.level_error);
      asn_debug.put_line('error stack from call to set_error_message');
      asn_debug.print_stack;
      pg_current_error_name  := p_message;
      pg_message_pending     := TRUE;
      fnd_message.set_name('PO', pg_current_error_name);
   END set_error_message;

   PROCEDURE set_error_message(
      p_message  IN            VARCHAR2,
      p_variable IN OUT NOCOPY VARCHAR2
   ) IS
   BEGIN
      set_error_message(p_message);
      p_variable  := p_message;
   END set_error_message;

   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN VARCHAR2
   ) IS
   BEGIN
      fnd_message.set_token(p_token, p_value);
   END set_token;

   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN NUMBER
   ) IS
   BEGIN
      fnd_message.set_token(p_token, TO_CHAR(p_value));
   END set_token;

   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN DATE
   ) IS
   BEGIN
      fnd_message.set_token(p_token, TO_CHAR(p_value, 'DD-MON-YYYY'));
   END set_token;

   PROCEDURE set_sql_error_message(
      p_procedure IN VARCHAR2,
      p_progress  IN VARCHAR2
   ) IS
   BEGIN
      set_error_message('PO_ALL_SQL_ERROR');
      set_token('ROUTINE', p_procedure);
      /* Bug 3713013 : The following statement was having TO_CHAR(p_progress).
              since p_progress is varchar2 datatype, error was getting
              thrown in Oracle 8i database and the package body was rendered
              invalid. Removed the call to TO_CHAR().
      */
      set_token('ERR_NUMBER', p_progress);
      set_token('SQL_ERR', SQLCODE);
      set_token('LSQL_ERR', SQLERRM);
   END set_sql_error_message;

   PROCEDURE test_is_null(
      p_value         IN VARCHAR2,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      IF (p_value IS NULL) THEN
         asn_debug.put_line('fail assert test_is_null for column ' || p_column);

         IF (p_error_message IS NOT NULL) THEN
            set_error_message(p_error_message);
         ELSE
            set_error_message('PO_PDOI_COLUMN_NOT_NULL');
            set_token('COLUMN', p_column);
         END IF;

         log_interface_error(p_table, p_column);
      END IF;
   END test_is_null;

   PROCEDURE test_is_null(
      p_value         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      test_is_null(p_value,
                   pg_transactions_interface,
                   p_column,
                   p_error_message
                  );
   END test_is_null;

   PROCEDURE test_is_null(
      p_value         IN NUMBER,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      test_is_null(TO_CHAR(p_value),
                   p_table,
                   p_column,
                   p_error_message
                  );
   END test_is_null;

   PROCEDURE test_is_null(
      p_value         IN NUMBER,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      test_is_null(p_value,
                   pg_transactions_interface,
                   p_column,
                   p_error_message
                  );
   END test_is_null;

   PROCEDURE test_is_null(
      p_value         IN DATE,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      test_is_null(TO_CHAR(p_value, 'DD-MON-YYYY'),
                   p_table,
                   p_column,
                   p_error_message
                  );
   END test_is_null;

   PROCEDURE test_is_null(
      p_value         IN DATE,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   ) IS
   BEGIN
      test_is_null(p_value,
                   pg_transactions_interface,
                   p_column,
                   p_error_message
                  );
   END test_is_null;

   FUNCTION check_and_reset_result
      RETURN VARCHAR2 IS
      x_temp VARCHAR2(1);
   BEGIN
      x_temp             := pg_current_result;
      pg_current_result  := g_ret_sts_success;
      RETURN x_temp;
   END check_and_reset_result;

   FUNCTION check_and_noreset_result
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pg_current_result;
   END check_and_noreset_result;

   PROCEDURE initialize(
      p_interface_type IN VARCHAR2,
      p_batch_id       IN NUMBER,
      p_header_id      IN NUMBER,
      p_line_id        IN NUMBER
   ) IS
   BEGIN
      pg_interface_type  := p_interface_type;
      pg_batch_id        := p_batch_id;
      pg_header_id       := p_header_id;
      pg_line_id         := p_line_id;
      clear_messages();
   END initialize;

   PROCEDURE initialize(
      p_batch_id  IN NUMBER,
      p_header_id IN NUMBER,
      p_line_id   IN NUMBER
   ) IS
   BEGIN
      initialize(pg_default_interface_type,
                 p_batch_id,
                 p_header_id,
                 p_line_id
                );
   END initialize;

   PROCEDURE clear_messages IS
   BEGIN
      pg_current_result      := g_ret_sts_success;

      IF (pg_message_pending = TRUE) THEN
         asn_debug.put_line('WARNING: message ' || pg_current_error_name || ' set but never used', fnd_log.level_error);
      END IF;

      pg_current_error_name  := NULL;
      pg_current_error_text  := NULL;
      pg_message_pending     := FALSE;
      pg_error_count         := 0;
      pg_error_stack         := NULL;
   END clear_messages;

   FUNCTION has_errors
      RETURN BOOLEAN IS
   BEGIN
      IF (pg_error_count > 0) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END has_errors;

   FUNCTION get_last_message
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pg_current_error_name;
   END get_last_message;

   PROCEDURE default_and_check(
      p_src_value IN            VARCHAR2,
      p_dst_value IN OUT NOCOPY VARCHAR2,
      p_column    IN            VARCHAR2
   ) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         set_error_message('RCV_INVALID_ROI_VALUE');
         set_token('COLUMN', p_column);
         set_token('ROI_VALUE', p_dst_value);
         set_token('SYS_VALUE', p_src_value);
         log_interface_error(p_column);
      END IF;
   END default_and_check;

   PROCEDURE default_and_check(
      p_src_value IN            NUMBER,
      p_dst_value IN OUT NOCOPY NUMBER,
      p_column    IN            VARCHAR2
   ) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         set_error_message('RCV_INVALID_ROI_VALUE');
         set_token('COLUMN', p_column);
         set_token('ROI_VALUE', p_dst_value);
         set_token('SYS_VALUE', p_src_value);
         log_interface_error(p_column);
      END IF;
   END default_and_check;

   PROCEDURE default_and_check(
      p_src_value IN            DATE,
      p_dst_value IN OUT NOCOPY DATE,
      p_column    IN            VARCHAR2
   ) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         set_error_message('RCV_INVALID_ROI_VALUE');
         set_token('COLUMN', p_column);
         set_token('ROI_VALUE', p_dst_value);
         set_token('SYS_VALUE', p_src_value);
         log_interface_error(p_column);
      END IF;
   END default_and_check;
END rcv_error_pkg;

/
