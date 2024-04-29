--------------------------------------------------------
--  DDL for Package PER_GB_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_DISABILITY" AUTHID CURRENT_USER AS
/* $Header: pegbdisp.pkh 120.1 2007/02/20 09:40:09 npershad noship $ */

PROCEDURE validate_create_disability(p_category    in  varchar2,
                                     p_person_id in  number,
				     p_effective_date in date);

PROCEDURE validate_update_disability(p_category    in  varchar2,
				     p_disability_id number,
				     p_effective_date in date);

END per_gb_disability;

/
