--------------------------------------------------------
--  DDL for Package OE_FTE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FTE_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVFTES.pls 120.0 2005/05/31 23:31:24 appldev noship $ */


PROCEDURE Process_FTE_Action
( p_header_id             IN      NUMBER
 ,p_line_id               IN      NUMBER
 ,p_ui_flag               IN      VARCHAR2
 ,p_action                IN      VARCHAR2
 ,p_call_pricing_for_FR   IN      VARCHAR2
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
 ,x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER
 ,x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

END OE_FTE_INTEGRATION_PVT;

 

/
