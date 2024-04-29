--------------------------------------------------------
--  DDL for Package QP_MODIFIER_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIER_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVDISS.pls 120.1 2005/06/14 22:00:28 appldev  $ */

  G_LIST_TYPE_CODE 				CONSTANT VARCHAR2(3) := 'DLT';
  G_LIST_LINE_TYPE_CODE 			CONSTANT VARCHAR2(3) := 'DIS';
  G_SURCHARGE_CODE 				CONSTANT VARCHAR2(3) := 'SUR';
  G_PRICE_BREAK_LINE_TYPE_CODE 	CONSTANT VARCHAR2(3) := 'PBH';
  G_ORDER_LEVEL          		CONSTANT VARCHAR2(5) := 'ORDER';
  G_LINE_LEVEL           		CONSTANT VARCHAR2(5) := 'LINE';

  PROCEDURE Create_Parallel_Slabs(l_workers IN NUMBER);

  PROCEDURE Create_Discounts(l_worker IN NUMBER := 1) ;

  PROCEDURE Get_Context_Attributes( p_entity_id              NUMBER,
						      x_context           OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
						      x_attribute         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
							 x_product_flag      OUT NOCOPY /* file.sql.39 change */  BOOLEAN,
							 x_pricing_flag	 OUT NOCOPY /* file.sql.39 change */	 BOOLEAN,
							 x_qualifier_flag    OUT NOCOPY /* file.sql.39 change */  BOOLEAN);
END QP_Modifier_Upgrade_PVT;

 

/
