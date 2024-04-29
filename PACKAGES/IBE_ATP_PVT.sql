--------------------------------------------------------
--  DDL for Package IBE_ATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ATP_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVATPS.pls 115.9 2003/08/29 09:08:57 nsultan ship $ */

  TYPE ATP_Line_Typ IS RECORD (
    quote_line_id         NUMBER,
    organization_id       NUMBER,
    inventory_item_id     NUMBER,
    quantity              NUMBER,
    uom_code              VARCHAR2(3),
    customer_id           NUMBER,
    ship_to_site_id		 NUMBER,
    ship_method_code      VARCHAR2(30),
    request_date          VARCHAR2(30),
    request_date_quantity NUMBER,
    available_date        VARCHAR2(30),
    error_code            NUMBER,
    error_message         VARCHAR2(2000)
  );

  TYPE ATP_Line_Tbl_Typ IS TABLE OF ATP_Line_Typ INDEX BY BINARY_INTEGER;

  PROCEDURE Check_Availability (
    p_quote_header_id              IN            NUMBER,
    p_date_format                  IN            VARCHAR2,
    p_lang_code                    IN            VARCHAR2,
    x_error_flag                   OUT NOCOPY    VARCHAR2,
    x_error_message                OUT NOCOPY    VARCHAR2,
    x_atp_line_tbl                 IN OUT NOCOPY ATP_Line_Tbl_Typ
  );

END IBE_ATP_PVT;

 

/
