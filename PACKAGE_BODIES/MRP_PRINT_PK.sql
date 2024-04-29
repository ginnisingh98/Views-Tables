--------------------------------------------------------
--  DDL for Package Body MRP_PRINT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PRINT_PK" AS
/* $Header: MRPPTISB.pls 115.0 99/07/16 12:34:58 porting ship $ */
PROCEDURE    stop_watch(arg_request_id      IN  NUMBER,
                        arg_transaction_id  IN  NUMBER,
                        arg_row_count       IN  NUMBER) IS
BEGIN
    UPDATE  mrp_messages_tmp
    SET     end_date = SYSDATE,
            row_count = arg_row_count
    WHERE   request_id = arg_request_id
      AND   transaction_id = arg_transaction_id;
END stop_watch;

PROCEDURE   stop_watch(arg_request_id       IN  NUMBER,
                       arg_transaction_id   IN  NUMBER) IS
BEGIN
    mrp_print_pk.stop_watch(arg_request_id,
                            arg_transaction_id,
                            NULL);
END stop_watch;


PROCEDURE   mrprint( arg_message_name  IN  VARCHAR2,
                   arg_request_id      IN  NUMBER,
                   arg_user_id         IN  NUMBER) IS

    var_dummy   NUMBER;
BEGIN
    var_dummy := start_watch( arg_message_name,
                        arg_request_id,
                        arg_user_id);
END mrprint;

-- ********************** start_watch *************************
FUNCTION   start_watch(
                            arg_message_name    IN  VARCHAR2,
                            arg_request_id      IN  NUMBER,
                            arg_user_id         IN  NUMBER,
                            arg_token1          IN  VARCHAR2,
                            arg_token_value1    IN  VARCHAR2,
                            arg_translate1      IN  VARCHAR2,
                            arg_token2          IN  VARCHAR2,
                            arg_token_value2    IN  VARCHAR2,
                            arg_translate2      IN  VARCHAR2) RETURN NUMBER IS
    var_transaction_id  NUMBER;
BEGIN
    SELECT  mrp_messages_tmp_s.nextval
    INTO    var_transaction_id
    FROM    dual;

    INSERT INTO mrp_messages_tmp
                (transaction_id,
                request_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                message_name,
                start_date,
                end_date,
                token1,
                token_value1,
                translate_token1,
                token2,
                token_value2,
                translate_token2,
                row_count)
    VALUES      (var_transaction_id,
                arg_request_id,
                SYSDATE,
                arg_user_id,
                SYSDATE,
                arg_user_id,
                -1,
                arg_message_name,
                SYSDATE,
                NULL,
                arg_token1,
                arg_token_value1,
                DECODE(arg_translate1, 'Y', SYS_YES, SYS_NO),
                arg_token2,
                arg_token_value2,
                DECODE(arg_translate2, 'Y', SYS_YES, SYS_NO),
                0);
--  we initialize row_count to 0 for a reason, If we do not need a row_count we
--  we will later update it to NULL

    return(var_transaction_id);
END start_watch;

FUNCTION   start_watch(
                            arg_message_name    IN  VARCHAR2,
                            arg_request_id      IN  NUMBER,
                            arg_user_id         IN  NUMBER,
                            arg_token1          IN  VARCHAR2,
                            arg_token_value1    IN  VARCHAR2,
                            arg_translate1      IN  VARCHAR2) RETURN NUMBER IS
    var_transaction_id  NUMBER;
BEGIN
    var_transaction_id := start_watch( arg_message_name,
                        arg_request_id,
                        arg_user_id,
                        arg_token1,
                        arg_token_value1,
                        arg_translate1,
                        NULL,
                        NULL,
                        NULL);
    return(var_transaction_id);
END start_watch;

FUNCTION   start_watch(
                            arg_message_name    IN  VARCHAR2,
                            arg_request_id      IN  NUMBER,
                            arg_user_id         IN  NUMBER) RETURN NUMBER IS
    var_transaction_id  NUMBER;
BEGIN
    var_transaction_id := start_watch( arg_message_name,
                        arg_request_id,
                        arg_user_id,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL);
    RETURN(var_transaction_id);
END start_watch;


PROCEDURE   clear_messages( arg_request_id      IN  NUMBER) IS
BEGIN

    DELETE FROM     mrp_messages_tmp
    WHERE           request_id = arg_request_id;

END clear_messages;

END; -- package

/
