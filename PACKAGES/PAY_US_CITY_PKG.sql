--------------------------------------------------------
--  DDL for Package PAY_US_CITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_CITY_PKG" AUTHID CURRENT_USER as
/* $Header: pyusukno.pkh 120.1 2005/08/17 09:47:24 rmonge noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
   pay_us_city_pkg
  Purpose
	Supports the city block in the form pyusukcy (US CITIES).
  Notes

  History
    21-AGU-95  F. Assadi   40.0         Date created.
    08-Dec-97  K.Mundair   40.4(110.1)  Altered parameters to create_unkn_city
					Bug 509120
    12-AUG-05  Rosie Monge 115.5        Modified to add a new procedure
                                        create_new_geocode as part of the
                                        enhacement done to the CITIES
                                        form (US) only to allow users
                                        to add new GEOCODEs.

 ============================================================================*/
--------------------------------------------------------------------------
-- Name
-- Validate_City
-- Purpose
-- To check whether the city is an unknown city and hence it is updateable.
-- Notes
--
----------------------------------------------------------------------------
--
 -----------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a new city via    --
 --   the create city form.                                                 --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(p_city_code       IN OUT   NOCOPY VARCHAR2,
		      p_zprowid		IN OUT   NOCOPY	VARCHAR2,
		      p_cirowid		IN OUT	 NOCOPY VARCHAR2,
		      p_gerowid		IN OUT	 NOCOPY VARCHAR2,
		      p_state_code			VARCHAR2,
		      p_county_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
                      p_disable                         VARCHAR2);
--
 PROCEDURE Lock_Row(  p_zprowid                         VARCHAR2,
		      p_cirowid				VARCHAR2,
		      p_gerowid				VARCHAR2,
		      p_state_code		        VARCHAR2,
		      p_county_code		        VARCHAR2,
		      p_city_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2);
--
 PROCEDURE Update_Row(p_zprowid                         VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
		      p_state_code		        VARCHAR2,
		      p_county_code		        VARCHAR2,
		      p_city_code			VARCHAR2,
                      p_city_name                       VARCHAR2,
                      p_disable                         VARCHAR2);
--
 PROCEDURE Delete_Row(p_zprowid 			VARCHAR2,
		      p_cirowid 			VARCHAR2,
		      p_gerowid 			VARCHAR2);
--
PROCEDURE chk_city_in_addr(p_state_abbrev		VARCHAR2,
			   p_county_name		VARCHAR2,
			   p_city_name			VARCHAR2);


PROCEDURE create_new_geocode (p_city_code       IN OUT   NOCOPY VARCHAR2,
		      p_zprowid		IN OUT   NOCOPY	VARCHAR2,
		      p_cirowid		IN OUT	 NOCOPY VARCHAR2,
		      p_gerowid		IN OUT	 NOCOPY VARCHAR2,
		      p_state_code			VARCHAR2,
		      p_county_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
                      p_disable                         VARCHAR2);


PROCEDURE create_unkn_city (p_ci_code    		IN OUT NOCOPY varchar2,
                            p_st_name        		IN varchar2,
		  	    p_co_name        		IN varchar2,
		  	    p_ci_name        		IN varchar2,
			    p_zi_start      		IN OUT NOCOPY varchar2,
			    p_zi_end        		IN OUT NOCOPY varchar2,
                            p_disable                   IN varchar2);

END PAY_US_CITY_PKG;

 

/
