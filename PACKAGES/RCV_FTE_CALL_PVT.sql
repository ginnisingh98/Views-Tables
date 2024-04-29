--------------------------------------------------------
--  DDL for Package RCV_FTE_CALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_FTE_CALL_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVFTECS.pls 115.5 2003/10/02 08:32:59 bfreeman noship $ */

PROCEDURE call_fte(
    p_action                IN VARCHAR2,
    p_shipment_header_id    IN NUMBER,
    p_shipment_line_id      IN NUMBER DEFAULT NULL,
    p_interface_id          IN NUMBER DEFAULT NULL);

PROCEDURE aggregate_calls;

END RCV_FTE_CALL_PVT;

 

/
