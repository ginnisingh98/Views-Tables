--------------------------------------------------------
--  DDL for Package Body RCV_FTE_TXN_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_FTE_TXN_LINES_PVT" AS
/* $Header: RCVFTXLB.pls 115.4 2003/10/20 06:45:56 bfreeman noship $ */

PROCEDURE insert_row(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_txn_id        IN NUMBER,
    p_action        IN VARCHAR2,
    p_status        IN VARCHAR2 DEFAULT 'N')
IS
BEGIN
    INSERT INTO rcv_fte_transaction_lines(
        header_id,
        line_id,
        action,
        reported_flag,
        transaction_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
    VALUES(
        p_header_id,
        p_line_id,
        p_action,
        p_status,
        p_txn_id,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.login_id);
END insert_row;

PROCEDURE update_record_to_reported(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2)
IS
BEGIN
    IF (p_line_id IS NULL) THEN
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'Y',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id

        WHERE
            header_id = p_header_id
        AND action = p_action
        AND reported_flag = 'N';
    ELSE
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'Y',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id

        WHERE
            header_id = p_header_id
        AND line_id = p_line_id
        AND action = p_action
        AND reported_flag = 'N';
    END IF;
END update_record_to_reported;

PROCEDURE update_record_to_failed(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2)
IS
BEGIN
    IF (p_line_id IS NULL) THEN
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'F',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id

        WHERE
            header_id = p_header_id
        AND action = p_action
        AND reported_flag = 'N';
    ELSE
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'F',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id

        WHERE
            header_id = p_header_id
        AND line_id = p_line_id
        AND action = p_action
        AND reported_flag = 'N';
    END IF;
END update_record_to_failed;

PROCEDURE update_record_to_unreported(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2)
IS
BEGIN
    IF (p_line_id IS NULL) THEN
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'U',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id

        WHERE
            header_id = p_header_id
        AND action = p_action
        AND reported_flag = 'N';
    ELSE
        UPDATE rcv_fte_transaction_lines
        SET reported_flag = 'U',
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE
            header_id = p_header_id
        AND line_id = p_line_id
        AND action = p_action
        AND reported_flag = 'N';
    END IF;
END update_record_to_unreported;
END RCV_FTE_TXN_LINES_PVT;

/
