--------------------------------------------------------
--  DDL for Package OE_BULK_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: OEBSVATS.pls 120.0.12010000.2 2008/11/18 03:28:10 smusanna ship $ */

-- Global to maintain Error Record Count
G_ERROR_COUNT  NUMBER := 0;

---------------------------------------------------------------------
-- PROCEDURE Pre_Process
--
-- This API does all the order import pre-processing validations on
-- the interface tables for orders in this batch.
-- It will insert error messages for all validation failures.
---------------------------------------------------------------------

PROCEDURE PRE_PROCESS( p_batch_id  IN NUMBER);


---------------------------------------------------------------------
-- PROCEDURE Attributes
--
-- This API does all attribute validations on interface tables for
-- orders in this batch.
-- It will insert error messages for all validation failures.
---------------------------------------------------------------------

PROCEDURE ATTRIBUTES
           (p_batch_id            IN NUMBER
           ,p_adjustments_exist   IN VARCHAR2 DEFAULT 'N');

---------------------------------------------------------------------
-- PROCEDURE Validate_BOM
--
-- This API does BOM validations on the OE_CONFIG_DETAILS_TMP table
-- for lines in this batch.
-- It will insert error messages for all validation failures.
---------------------------------------------------------------------

PROCEDURE Validate_BOM;

---------------------------------------------------------------------
-- PROCEDURE Mark_Interface_Error
--
-- This procedure sets error_flag on order header interface table
-- if any entity of this order (header, line, adjustments etc.)
-- fail pre-processing checks or attribute validation.
---------------------------------------------------------------------

PROCEDURE MARK_INTERFACE_ERROR(p_batch_id NUMBER);

END OE_BULK_VALIDATE;

/
