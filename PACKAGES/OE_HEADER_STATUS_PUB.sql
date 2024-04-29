--------------------------------------------------------
--  DDL for Package OE_HEADER_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPHDSS.pls 120.0 2005/06/01 02:39:27 appldev noship $ */

PROCEDURE Get_Booked_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_Booked_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);


PROCEDURE Get_Closed_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Get_Closed_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE);


PROCEDURE Get_Cancelled_status(
p_header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_Cancelled_Status(
p_Header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date  OUT NOCOPY /* file.sql.39 change */ DATE);


END OE_HEADER_STATUS_PUB;

 

/
