--------------------------------------------------------
--  DDL for Package OE_ADV_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ADV_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVAPRS.pls 120.2.12010000.1 2008/07/25 07:58:16 appldev ship $ */

G_STMT_NO			Varchar2(2000);

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ADV_PRICE_PVT';
G_SEEDED_PROM_ORDER_HOLD_ID    CONSTANT NUMBER := 30;
G_SEEDED_PROM_LINE_HOLD_ID     CONSTANT NUMBER := 31;


function check_notify_OC return boolean;


procedure process_adv_modifiers
(
x_return_status                 OUT NOCOPY /* file.sql.39 change */ Varchar2,
p_Control_Rec                   IN OE_ORDER_PRICE_PVT.Control_rec_type,
p_any_frozen_line               IN Boolean DEFAULT FALSE,
px_line_Tbl                     IN OUT NOCOPY     oe_Order_Pub.Line_Tbl_Type,
px_old_line_Tbl                 IN OUT NOCOPY     oe_order_pub.line_tbl_type,
p_header_id                     IN number,
p_line_id                       IN number,
p_header_rec                    IN oe_Order_Pub.header_rec_type,
p_pricing_events                IN varchar2
);

Procedure Insert_Adj(p_header_id in number default null);

end OE_ADV_PRICE_PVT;

/
