--------------------------------------------------------
--  DDL for Package RCV_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ERROR_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVERRS.pls 120.0 2005/06/02 01:17:19 appldev noship $*/

/* rcv_error_pkg has two major functions.
   log_interface_error and
   log_interface_warning.
   these procedure are nearly identical.
   Before you call these procedures, the setup is to first call
   set_error_msg with the error or warning message tag
   and then call set_token for each token in that string.
   Build an exception handler for this block for RCV_ERROR_PKG.e_fatal_error
   calling log_interface_error will raise this exception
   For warnings it will not raise an exception,

   The overall flow should be:

   begin transaction loop
     rcv_error_pkg.initialize(int_type,g_id,h_id,l_id); -- to reset the error stack
     derive_record is
     begin
       derive_field is
       begin
         if field_error
           rcv_error_pkg.set_error_message('RCV_FIELD_ERROR');
           rcv_error_pkg.log_interface_error('TABLE','FIELDNAME');
         elsif field_warning
           rcv_error_pkg.set_error_message('RCV_FIELD_WARNING');
           rcv_error_pkg.set_token('TKN','VALUE');
           rcv_error_pkg.log_interface_warning('TABLE','FIELDNAME');
           x_cascaded_table(n).error_status:=rcv_error_pkg.g_ret_sts_warning;
         end if;
       exception
         when rcv_error_pkg.e_fatal_error then
           x_cascaded_table(n).error_status:=rcv_error_pkg.g_ret_sts_error;
       end;
       if (rcv_error_pkg.check_and_reset_result()=true) then --to stop processing on child error
         raise;
       end if;
     end;

     error_count := rcv_error_pkg.get_error_count();
     last_error := rcv_error_pkg.get_last_error();
     error_msgs := rcv_error_pkg.get_all_errors();
   end transaction loop;
*/

/* E_FATAL_ERROR is the exception that should be raised when a terminal
   condition has been discovered
*/
   e_fatal_error                  EXCEPTION;
/* The following status are similar to the fnd_api status, but include the
   addition of G_RET_STS_WARNING as 'W'
*/
   g_ret_sts_success     CONSTANT VARCHAR2(1) := 'S';
   g_ret_sts_error       CONSTANT VARCHAR2(1) := 'E';
   g_ret_sts_warning     CONSTANT VARCHAR2(1) := 'W';
   g_ret_sts_unexp_error CONSTANT VARCHAR2(1) := 'U';

/* log_interface_error should only be called inside the
   WHEN RCV_ERROR_PKG.e_fatal_error THEN
   exception handler.
   Inside the body first call set_error_message, then call set_token for
   each token, then call log_interface_error.
   This procedure does these things:
   1) add a row into po_interace_errors
   2) adds the parsed message to the error stack
   3) increases the error counter
   4) resets the token stack
   5) sets the result flag to 'E'
*/
   PROCEDURE log_interface_error(
      p_table       IN VARCHAR2,
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN DEFAULT TRUE
   );

   PROCEDURE log_interface_error(
      p_table       IN VARCHAR2,
      p_column      IN VARCHAR2,
      p_batch_id    IN NUMBER,
      p_header_id   IN NUMBER,
      p_line_id     IN NUMBER,
      p_raise_error IN BOOLEAN DEFAULT TRUE
   );

/* This log_interface_error call assumes p_table = 'RCV_TRANSACTIONS_INTERFACE' */
   PROCEDURE log_interface_error(
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN DEFAULT TRUE
   );

/* log_interface_error_message is for .lpc file style calls */
   PROCEDURE log_interface_error_message(
      p_error_message IN VARCHAR2
   );

   PROCEDURE log_interface_warning(
      p_table  IN VARCHAR2,
      p_column IN VARCHAR2
   );

/* This log_interface_warning call assumes p_table = 'RCV_TRANSACTIONS_INTERFACE' */
   PROCEDURE log_interface_warning(
      p_column IN VARCHAR2
   );

/* log_interface_message takes an indicator variable and logs error/warning/ignore as appropriate*/
   PROCEDURE log_interface_message(
      p_error_status IN VARCHAR2,
      p_table        IN VARCHAR2,
      p_column       IN VARCHAR2,
      p_raise_error  IN BOOLEAN DEFAULT TRUE
   );

/* This log_interface_message call assumes p_table = 'RCV_TRANSACTIONS_INTERFACE' */
   PROCEDURE log_interface_message(
      p_error_status IN VARCHAR2,
      p_column       IN VARCHAR2,
      p_raise_error  IN BOOLEAN DEFAULT TRUE
   );

/* This log_interface_message call ues the internal error flag what kind of message to log */
   PROCEDURE log_interface_message(
      p_column      IN VARCHAR2,
      p_raise_error IN BOOLEAN DEFAULT TRUE
   );

   PROCEDURE set_error_message(
      p_message IN VARCHAR2
   );

   PROCEDURE set_error_message(
      p_message  IN            VARCHAR2,
      p_variable IN OUT NOCOPY VARCHAR2
   );

/* set_token is overloaded for varchar2, number and date */
   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN VARCHAR2
   );

   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN NUMBER
   );

   PROCEDURE set_token(
      p_token IN VARCHAR2,
      p_value IN DATE
   );

/* set_sql_error_message is a convenience function that sets the
   error message and tokens as appropriate - equivalent to
   calling set_error_message and set_tokens */
   PROCEDURE set_sql_error_message(
      p_procedure IN VARCHAR2,
      p_progress  IN VARCHAR2
   );

/* test_is_null is a convenience function that tests if the value passed
   is null, if so then it calls log_interface_error */
   PROCEDURE test_is_null(
      p_value         IN VARCHAR2,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   );

   PROCEDURE test_is_null(
      p_value         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2 DEFAULT NULL
   );

   PROCEDURE test_is_null(
      p_value         IN NUMBER,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   );

   PROCEDURE test_is_null(
      p_value         IN NUMBER,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2 DEFAULT NULL
   );

   PROCEDURE test_is_null(
      p_value         IN DATE,
      p_table         IN VARCHAR2,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2
   );

   PROCEDURE test_is_null(
      p_value         IN DATE,
      p_column        IN VARCHAR2,
      p_error_message IN VARCHAR2 DEFAULT NULL
   );

   FUNCTION check_and_reset_result
      RETURN VARCHAR2;

   FUNCTION check_and_noreset_result
      RETURN VARCHAR2;

   FUNCTION has_errors
      RETURN BOOLEAN;

   PROCEDURE initialize(
      p_interface_type IN VARCHAR2,
      p_batch_id       IN NUMBER,
      p_header_id      IN NUMBER,
      p_line_id        IN NUMBER
   );

   PROCEDURE initialize(
      p_batch_id  IN NUMBER,
      p_header_id IN NUMBER,
      p_line_id   IN NUMBER
   );

   PROCEDURE clear_messages;

   FUNCTION get_last_message
      RETURN VARCHAR2;

   PROCEDURE default_and_check(
      p_src_value IN            VARCHAR2,
      p_dst_value IN OUT NOCOPY VARCHAR2,
      p_column    IN            VARCHAR2
   );

   PROCEDURE default_and_check(
      p_src_value IN            NUMBER,
      p_dst_value IN OUT NOCOPY NUMBER,
      p_column    IN            VARCHAR2
   );

   PROCEDURE default_and_check(
      p_src_value IN            DATE,
      p_dst_value IN OUT NOCOPY DATE,
      p_column    IN            VARCHAR2
   );
END rcv_error_pkg;

 

/
