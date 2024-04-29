--------------------------------------------------------
--  DDL for Package PER_FI_POPULATE_COUNTRIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FI_POPULATE_COUNTRIES" AUTHID CURRENT_USER as
/* $Header: perfipop.pkh 120.0 2005/05/31 17:49:27 appldev noship $ */
--
-- {Start Of Comments}
--
-- Purpose: To insert the countries into the user table
--
-- ----------------------------------------------------------------------------
-- |-------------------------< per_fi_populate_countries>--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE POPULATE_COUNTRIES(
		p_errbuf 	        OUT nocopy	VARCHAR2
	       ,p_retcode	        OUT nocopy	NUMBER
	       ,p_business_group_id     IN  NUMBER );
END PER_FI_POPULATE_COUNTRIES;

 

/
