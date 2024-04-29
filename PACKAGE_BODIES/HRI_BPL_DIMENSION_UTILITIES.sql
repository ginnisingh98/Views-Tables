--------------------------------------------------------
--  DDL for Package Body HRI_BPL_DIMENSION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_DIMENSION_UTILITIES" AS
/* $Header: hribdimu.pkb 120.0 2005/05/29 07:02:36 appldev noship $ */
--
-- -----------------------------------------------------------------------------
-- Function to fetch the value for ID column in the perfromance dimension view
-- for not reated performers
-- -----------------------------------------------------------------------------
--
FUNCTION get_not_rated_id RETURN NUMBER
IS
  --
  --
BEGIN
  --
  RETURN -5;
  --
END get_not_rated_id;
--
END HRI_BPL_DIMENSION_UTILITIES;

/
