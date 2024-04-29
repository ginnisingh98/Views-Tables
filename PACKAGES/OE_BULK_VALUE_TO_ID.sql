--------------------------------------------------------
--  DDL for Package OE_BULK_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: OEBSVIDS.pls 120.1 2006/05/15 05:30:28 mbhoumik noship $ */

---------------------------------------------------------------------
-- FUNCTION Get_Contact_ID
-- Used to retrieve contact ID based on contact name and
-- contact organization. E.g. for ship_to_contact_id, p_site_use_id
-- should be ship_to_org_id
---------------------------------------------------------------------

FUNCTION Get_Contact_ID
  (p_contact                  IN VARCHAR2
  ,p_site_use_id              IN NUMBER
  )
RETURN NUMBER;

--{ Bug 5054618
-- Function to get End customer site use id
   FUNCTION END_CUSTOMER_SITE
(   p_end_customer_site_address1              IN  VARCHAR2
,   p_end_customer_site_address2              IN  VARCHAR2
,   p_end_customer_site_address3              IN  VARCHAR2
,   p_end_customer_site_address4              IN  VARCHAR2
,   p_end_customer_site_location              IN  VARCHAR2
,   p_end_customer_site_org                   IN  VARCHAR2
,   p_end_customer_id                         IN  NUMBER
,   p_end_customer_site_city                  IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_state                 IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_postalcode            IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_country               IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_use_code              IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

-- Function to get end customer contact id
FUNCTION GET_END_CUSTOMER_CONTACT_ID
(  p_end_customer_contact IN VARCHAR2
,  p_end_customer_id      IN NUMBER
) RETURN NUMBER;
-- Bug 5054618}

---------------------------------------------------------------------
-- PROCEDURE Headers
--
-- Value to ID conversions on header interface table for orders in
-- this batch.
-- It sets error_flag to 'Y' and appends ATTRIBUTE_STATUS column with a
-- number identifying each attribute that fails value to ID conversion.
---------------------------------------------------------------------

PROCEDURE Headers(p_batch_id  IN NUMBER);


---------------------------------------------------------------------
-- PROCEDURE Lines
--
-- Value to ID conversions on lines interface table.
-- It sets error_flag to 'Y' and appends ATTRIBUTE_STATUS column with a
-- number identifying each attribute that fails value to ID conversion.
---------------------------------------------------------------------

PROCEDURE Lines(p_batch_id  IN NUMBER);


---------------------------------------------------------------------
-- PROCEDURE Adjustments
--
-- Value to ID conversions on adjustments interface table.
-- This procedure also does pre-processing/entity validation for
-- adjustments.
---------------------------------------------------------------------

PROCEDURE Adjustments(p_batch_id  IN NUMBER);


---------------------------------------------------------------------
-- PROCEDURE Insert_Error_Messages
--
-- This API uses ATTRIBUTE_STATUS column on headers and lines interface
-- tables to insert error messages for value to ID conversion failures.
---------------------------------------------------------------------

PROCEDURE Insert_Error_Messages(p_batch_id  IN NUMBER);


END OE_BULK_VALUE_TO_ID;

 

/
