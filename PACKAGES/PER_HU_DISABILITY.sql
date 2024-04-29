--------------------------------------------------------
--  DDL for Package PER_HU_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_DISABILITY" AUTHID CURRENT_USER as
/* $Header: pehudisp.pkh 120.0.12000000.1 2007/01/21 23:14:53 appldev ship $ */
PROCEDURE check_hu_disability(p_category varchar2
                             ,p_degree number);
PROCEDURE create_hu_disability(p_category varchar2
                              ,p_degree number);
PROCEDURE update_hu_disability(p_category varchar2
                              ,p_degree number);
END PER_HU_DISABILITY;

 

/
