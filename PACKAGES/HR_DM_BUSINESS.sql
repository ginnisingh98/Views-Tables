--------------------------------------------------------
--  DDL for Package HR_DM_BUSINESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_BUSINESS" AUTHID CURRENT_USER AS
/* $Header: perdmbiz.pkh 120.0 2005/05/31 17:05:16 appldev noship $ */

--


--
FUNCTION last_migration_date(
  r_migration_data IN hr_dm_utility.r_migration_rec)
  RETURN DATE;
FUNCTION validate_migration(
  r_migration_data IN hr_dm_utility.r_migration_rec)
  RETURN VARCHAR2;

--


END hr_dm_business;

 

/
