--------------------------------------------------------
--  DDL for Package OE_SO_II_EXPLODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SO_II_EXPLODE" AUTHID CURRENT_USER AS
/* $Header: oesoiits.pls 115.1 99/07/16 08:28:17 porting shi $ */

  PROCEDURE Copy_Exploded_BOM (

		P_II_BOM_Explosion_Group_Id	OUT	NUMBER,
		P_II_Session_Id			IN	NUMBER,
		P_II_Inventory_Item_Id		IN	NUMBER,
		P_II_Top_Component_Code		IN	VARCHAR2,
		P_II_Std_Comp_Freeze_Date	IN	DATE,
		P_II_Line_Id			IN	NUMBER,
		P_Result			OUT	VARCHAR2
		);

  PROCEDURE Explode_Manually (
		P_II_BOM_Explosion_Group_Id	IN OUT	NUMBER,
		P_II_Top_Component_Code		IN	VARCHAR2,
		P_II_Session_Id			IN	NUMBER,
		P_II_Line_Id			IN	NUMBER,
		P_Result			OUT	VARCHAR2
		);



END OE_SO_II_EXPLODE;

 

/
