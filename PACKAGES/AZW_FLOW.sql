--------------------------------------------------------
--  DDL for Package AZW_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZW_FLOW" AUTHID CURRENT_USER AS
/* $Header: AZWFLOWS.pls 115.2 99/07/16 19:28:01 porting sh $ */

--
-- Name:        populate_product_flows
-- Description: inserts implementation flows from WF tables into
--              AZ_PRODUCT_FLOWS table
-- Parameters:  none
--

  PROCEDURE populate_product_flows;

END AZW_FLOW;

 

/
