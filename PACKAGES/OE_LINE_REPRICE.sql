--------------------------------------------------------
--  DDL for Package OE_LINE_REPRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_REPRICE" AUTHID CURRENT_USER AS
/* $Header: OEXVREPS.pls 120.0.12010000.1 2008/07/25 08:06:52 appldev ship $ */

PROCEDURE Reprice_Line
(
	p_line_rec				IN	OE_Order_Pub.Line_Rec_Type DEFAULT OE_Order_Pub.G_MISS_LINE_REC
,	p_Repricing_date		IN	VARCHAR2
,	p_Repricing_event	IN	VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,       p_Honor_Price_Flag      IN      VARCHAR2 DEFAULT 'Y'
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Process_Repricing
(
	p_api_version_number	IN	NUMBER
,	p_line_id				IN	NUMBER
,	p_activity_id			IN	NUMBER
, x_result_out OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY VARCHAR2

, x_msg_data OUT NOCOPY VARCHAR2

);

procedure set_reprice_status (p_flow_status IN VARCHAR2,
                              p_line_id     IN NUMBER);

end OE_LINE_REPRICE;

/
