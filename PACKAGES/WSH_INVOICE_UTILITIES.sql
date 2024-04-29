--------------------------------------------------------
--  DDL for Package WSH_INVOICE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INVOICE_UTILITIES" AUTHID CURRENT_USER as
/* $Header: WSHARINS.pls 115.0 99/07/16 08:17:45 porting ship $ */
--
-- Package
--   WSH_INVOICE_UTILITIES
-- Purpose
--   Will contains server side routines for Delivery Style AR Interface
-- History
--   04-FEB-97	ANEOGI	Created

  --
  -- PUBLIC VARIABLES
  --

  --
  -- PUBLIC FUNCTIONS
  --

  -- Name
  --   update_numbers
  -- Purpose
  --   It looks in ra_interface_lines table for the lines inserted for
  --   this run of Receivables Interface and updates them with an Invoice
  --   Number based on the delivery name
  -- Arguments
  --   org_id

  PROCEDURE update_numbers( x_org_id NUMBER,
			    x_request_id IN NUMBER,
			    err_msg IN OUT VARCHAR2 );

END WSH_INVOICE_UTILITIES;

 

/
