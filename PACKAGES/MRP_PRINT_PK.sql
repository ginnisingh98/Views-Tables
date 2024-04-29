--------------------------------------------------------
--  DDL for Package MRP_PRINT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_PRINT_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPTISS.pls 115.0 99/07/16 12:35:02 porting ship $ */
    PROCEDURE   stop_watch(
                arg_request_id      IN NUMBER,
                arg_transaction_id  IN NUMBER);
    PROCEDURE   stop_watch(
                arg_request_id      IN NUMBER,
                arg_transaction_id  IN NUMBER,
                arg_row_count       IN NUMBER);
    FUNCTION    start_watch(
                arg_message_name    VARCHAR2,
                arg_request_id      NUMBER,
                arg_user_id         NUMBER,
                arg_token1          VARCHAR2,
                arg_token_value1    VARCHAR2,
                arg_translate1      VARCHAR2,
                arg_token2          VARCHAR2,
                arg_token_value2    VARCHAR2,
                arg_translate2      VARCHAR2) RETURN NUMBER;
    FUNCTION    start_watch(
                arg_message_name    VARCHAR2,
                arg_request_id      NUMBER,
                arg_user_id         NUMBER,
                arg_token1          VARCHAR2,
                arg_token_value1    VARCHAR2,
                arg_translate1      VARCHAR2) RETURN NUMBER;
    FUNCTION    start_watch(
                arg_message_name    VARCHAR2,
                arg_request_id      NUMBER,
                arg_user_id         NUMBER) RETURN NUMBER;
    PROCEDURE   mrprint(
                arg_message_name    VARCHAR2,
                arg_request_id      NUMBER,
                arg_user_id         NUMBER);
    PROCEDURE   clear_messages(
                arg_request_id      NUMBER);
    /*-------------------------------------------------------------------------+
    |   Defined constants                                                      |
    +-------------------------------------------------------------------------*/
    VERSION                 CONSTANT CHAR(80) :=
        '$Header: MRPPTISS.pls 115.0 99/07/16 12:35:02 porting ship $';

    SYS_YES             CONSTANT INTEGER := 1;      /* sys yes no */
    SYS_NO              CONSTANT INTEGER := 2;
END mrp_print_pk;

 

/
