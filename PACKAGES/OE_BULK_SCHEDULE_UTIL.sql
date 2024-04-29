--------------------------------------------------------
--  DDL for Package OE_BULK_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_SCHEDULE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEBUSCHS.pls 120.0.12010000.1 2008/07/25 07:44:36 appldev ship $ */

---------------------------------------------------------------------
-- PROCEDURE Schedule_Orders
--
-- This procedure schedules all lines eligible for auto-scheduling
-- in this order import batch.
-- Scheduling updates are done directly on the line record - p_line_rec.
---------------------------------------------------------------------

PROCEDURE Schedule_Orders
        (p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        ,p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,x_return_status       OUT NOCOPY VARCHAR2
        );
-- Pack J
---------------------------------------------------------------------
-- FUNCTION Get_Date_Type
--
-- This function will return date type of the order.
---------------------------------------------------------------------
FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2;

END OE_BULK_SCHEDULE_UTIL;

/
