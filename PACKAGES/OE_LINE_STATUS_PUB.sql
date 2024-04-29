--------------------------------------------------------
--  DDL for Package OE_LINE_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPLNSS.pls 120.0 2005/05/31 23:09:30 appldev noship $ */


PROCEDURE Get_Closed_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Closed_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);

PROCEDURE Get_Cancelled_status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_Cancelled_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);


PROCEDURE Get_Purchase_Release_status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_Purchase_Release_status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);

PROCEDURE Get_ship_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_ship_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);

PROCEDURE Get_pick_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_pick_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_picked_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_picked_quantity_uom OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Received_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Received_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);

PROCEDURE Get_Invoiced_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Invoiced_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);


FUNCTION Get_Line_Status
( p_line_id                  IN   NUMBER
 ,p_flow_status_code         IN   VARCHAR2)
RETURN VARCHAR2;

END OE_LINE_STATUS_PUB;

 

/
