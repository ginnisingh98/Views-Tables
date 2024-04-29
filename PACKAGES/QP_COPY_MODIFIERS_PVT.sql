--------------------------------------------------------
--  DDL for Package QP_COPY_MODIFIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_COPY_MODIFIERS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCPMS.pls 120.2 2005/11/17 01:08:45 spgopal noship $ */

G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_COPY_MODIFIERS_PVT';

TYPE mapping_rec IS RECORD (
list_line_type_code     VARCHAR2(30),
old_list_line_id        NUMBER,
new_list_line_id        NUMBER
);

TYPE mapping_tbl IS TABLE OF mapping_rec
  INDEX BY BINARY_INTEGER;

PROCEDURE Copy_Discounts
(
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_from_list_header_id 	 	 NUMBER,
 p_new_price_list_name  IN    VARCHAR2,
 p_description          IN 	VARCHAR2,
 p_start_date_active    IN    VARCHAR2, --	DATE,  2752295
 p_end_date_active      IN    VARCHAR2, --	DATE,  2752295
 p_rounding_factor      IN 	NUMBER,
 p_effective_dates_flag IN 	VARCHAR2,
--added for moac bug 4673872
 p_global_flag IN VARCHAR2,
 p_org_id IN NUMBER
);
END QP_COPY_MODIFIERS_PVT;

 

/
