--------------------------------------------------------
--  DDL for Package WSH_SC_DETAILS_REQUIRED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_DETAILS_REQUIRED_PKG" AUTHID CURRENT_USER as
/* $Header: WSHSCDRS.pls 115.0 99/07/16 08:20:44 porting ship $ */

--
-- Package
--   	WSH_SC_DETAILS_REQUIRED_PKG
-- Purpose
--      Determine if Details are required during Ship Confirm
-- History
--      04-mar-97 troveda  Created
--

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Name
  --   Details Required
  -- Purpose
  --   Evaluates if a particular batch requires details or not
  -- Arguments
  -- Notes
  --


  PROCEDURE Details_Required(X_Entity_Id 		IN     NUMBER,
			     X_Mode			IN     VARCHAR2,
			     X_Action			IN     VARCHAR2,
			     X_Reservations 	    	IN     VARCHAR2,
			     X_Warehouse_id          	IN     NUMBER,
			     X_Order_Category		IN     VARCHAR2,
			     X_Details_Req              IN OUT VARCHAR2
                             );

END WSH_SC_DETAILS_REQUIRED_PKG;

 

/
