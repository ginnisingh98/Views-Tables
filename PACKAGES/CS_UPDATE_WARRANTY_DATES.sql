--------------------------------------------------------
--  DDL for Package CS_UPDATE_WARRANTY_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_UPDATE_WARRANTY_DATES" AUTHID CURRENT_USER as
/* $Header: csxsvuws.pls 115.0 99/07/16 09:09:30 porting ship $ */
--
--
--Returns FALSE on failure, else TRUE. Examine X_ErrBuf if returns FALSE.
--
  Procedure Update_Warranty_Dates (
			X_Customer_Product_ID		NUMBER,
			X_Start_Date			DATE,
			X_Day_UOM			VARCHAR2
			);
END CS_UPDATE_WARRANTY_DATES;

 

/
