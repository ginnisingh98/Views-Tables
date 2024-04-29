--------------------------------------------------------
--  DDL for Package BEN_DM_BUSINESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_BUSINESS" AUTHID CURRENT_USER AS
/* $Header: benfdmdbiz.pkh 120.0 2006/06/13 14:55:13 nkkrishn noship $ */

--


--
FUNCTION last_migration_date(
  r_migration_data IN ben_dm_utility.r_migration_rec)
  RETURN DATE;
FUNCTION validate_migration(
  r_migration_data IN ben_dm_utility.r_migration_rec)
  RETURN VARCHAR2;

--


END ben_dm_business;

 

/
