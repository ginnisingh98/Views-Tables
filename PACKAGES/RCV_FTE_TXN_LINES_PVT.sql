--------------------------------------------------------
--  DDL for Package RCV_FTE_TXN_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_FTE_TXN_LINES_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVFTXLS.pls 115.3 2003/10/20 06:45:10 bfreeman noship $ */

PROCEDURE insert_row(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_txn_id        IN NUMBER,
    p_action        IN VARCHAR2,
    p_status        IN VARCHAR2 DEFAULT 'N');

PROCEDURE update_record_to_reported(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2);

PROCEDURE update_record_to_failed(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2);

PROCEDURE update_record_to_unreported(
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_action        IN VARCHAR2);

END RCV_FTE_TXN_LINES_PVT;

 

/
