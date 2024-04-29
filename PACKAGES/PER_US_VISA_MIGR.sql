--------------------------------------------------------
--  DDL for Package PER_US_VISA_MIGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VISA_MIGR" AUTHID CURRENT_USER AS
/* $Header: peusvsmi.pkh 120.0 2005/05/31 22:46:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< convert_visa >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   convert visa_type from Person record to visa_code in visa EIT
--
-- In Parameters:
--   bg_id:  Business Group Id
--
--
Procedure convert_visa(p_bg_id    number);
--
--
end PER_US_VISA_MIGR;

 

/
