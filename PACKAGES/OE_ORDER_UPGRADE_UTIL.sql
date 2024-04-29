--------------------------------------------------------
--  DDL for Package OE_ORDER_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_UPGRADE_UTIL" AUTHID CURRENT_USER as
/* $Header: OEXUUPGS.pls 120.0 2005/06/01 00:02:59 appldev noship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_ORDER_UPGRADE_UTIL';

FUNCTION Get_entity_Scolumn_value (
	  p_entity_type IN VARCHAR2,
	  p_entity_key IN NUMBER,
	  p_SColumn_name IN VARCHAR2)
RETURN NUMBER;


PROCEDURE Get_Invoice_Status_Code(
	p_line_id  IN NUMBER,
x_invoice_status_code OUT NOCOPY VARCHAR2);


PROCEDURE Get_Demand_Interface_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER);


PROCEDURE Get_Mfg_Release_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER);


PROCEDURE Get_Pur_Rel_Status(
p_line_id	IN  NUMBER,
x_result OUT NOCOPY NUMBER);


PROCEDURE Get_responsibility_application(
	p_user_id             IN  NUMBER,
	p_org_id              IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_error_message OUT NOCOPY VARCHAR2,

x_responsibility_id OUT NOCOPY NUMBER,

x_application_id OUT NOCOPY NUMBER);


END OE_ORDER_UPGRADE_UTIL;

 

/
