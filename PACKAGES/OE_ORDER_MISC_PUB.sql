--------------------------------------------------------
--  DDL for Package OE_ORDER_MISC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_MISC_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPMISS.pls 120.0 2005/05/31 23:49:36 appldev noship $ */

FUNCTION GET_CONCAT_LINE_NUMBER
(
p_Line_Id  IN NUMBER
) RETURN VARCHAR2;

FUNCTION GET_CONCAT_HIST_LINE_NUMBER
(
p_Line_Id  IN NUMBER,
p_Version_Number  IN NUMBER
) RETURN VARCHAR2;

FUNCTION GET_CONCAT_HIST_LINE_NUMBER
(
p_Line_Id  IN NUMBER
) RETURN VARCHAR2;

END OE_ORDER_MISC_PUB;

 

/
