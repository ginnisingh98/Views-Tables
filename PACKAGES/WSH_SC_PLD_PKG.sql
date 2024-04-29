--------------------------------------------------------
--  DDL for Package WSH_SC_PLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_PLD_PKG" AUTHID CURRENT_USER as
/* $Header: WSHSCPDS.pls 115.0 99/07/16 08:20:51 porting ship $ */
--
-- Package
--      WSH_SC_PLD_PKG
--
-- Purpose
--     	This package is used by the confirm delivery form to update
--	serial number information (details) entered on a delivery line
--	and do the explosion of the serial numbers if necessary.
-- History
--	Version	1.0	03/01/97	RMANJUNA
--

  --
  -- Name
  -- 	Close_Details
  -- Purpose
  --    To update picking line details with information entered in the
  --    serial number window.
  --
PROCEDURE Close_Details(X_Delivery_Id	IN NUMBER);

  --
  -- Name
  -- 	Update_Details
  -- Purpose
  --    To update picking line details with information entered into the
  --    transaction block.

PROCEDURE Update_Details(  X_Trx_Src_Line_Id	IN	NUMBER,
			   X_Requested_Qty	IN	NUMBER,
			   X_Shipped_Qty	IN	NUMBER,
			   X_Serial		IN	VARCHAR2);
  --
  -- Name
  -- 	Insert_Details
  -- Purpose
  --    To insert new picking line details for details split on transaction
  --    block or entered in the serial number window.

PROCEDURE Insert_Details(  X_New_Detail_Id	IN	NUMBER,
			   X_Parent_Detail_Id	IN	NUMBER,
			   X_Trx_Qty		IN	NUMBER,
			   X_Req_Qty		IN	NUMBER,
			   X_Serial		IN	VARCHAR2,
			   X_Mode  		IN	VARCHAR2,
			   X_detail_type_code  	IN	VARCHAR2 DEFAULT 'NA');

--
-- Purpose
--  This the used for split delivery line function to create a new
--  picking line details
--
FUNCTION Insert_Splitted_Details( X_Parent_Detail_Id	IN	NUMBER,
			   	  X_Req_Qty		IN	NUMBER,
				  X_detail_type_code   	IN 	VARCHAR2)
RETURN NUMBER;

  --
  -- Name
  -- 	Create_Remainders
  -- Purpose
  --   To create a new detail for the remaining quantity when a partial quantity
  --   has been shipped for a reserved picking line.
  --

PROCEDURE Create_Remainders(X_Picking_Line_Detail_Id	NUMBER,
			    X_New_Requested		NUMBER );
  --
  -- Name
  --   Explode_Lines
  -- Purpose
  --   Takes individual lines from MTL_SERIAL_NUMBERS_TEMP that
  --   are under serial number control and explodes them into multiple
  --   lines based on the serial numbers entered.

PROCEDURE Explode_Lines( X_Picking_Line_Detail_Id	IN	NUMBER);

  --
  -- Name
  --   Next_Serial
  -- Purpose
  --   Takes a serial prefix, the length of the numeric portion of a serial
  --   number and the current value of the numeric portion and returns the
  --   next serial number.

FUNCTION Next_Serial (s_prefix      IN  VARCHAR2,
			s_num_length  IN  NUMBER,
			s_num_current IN  NUMBER
                       ) RETURN VARCHAR2 ;
  --
  -- Name
  -- 	Delete_From_Msnt
  -- Purpose
  --   To Delete the temporary records created in MSNT by the Serial Number Entry Form
  --

PROCEDURE Delete_From_Msnt(X_Delivery_Id	NUMBER );

END WSH_SC_PLD_PKG;

 

/
