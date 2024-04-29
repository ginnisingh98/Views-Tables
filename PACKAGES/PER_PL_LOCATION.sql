--------------------------------------------------------
--  DDL for Package PER_PL_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_LOCATION" AUTHID CURRENT_USER AS
/* $Header: pepllhla.pkh 120.0.12000000.1 2007/01/22 01:39:53 appldev noship $ */
--
--
--
PROCEDURE check_pl_location (
                            p_address_line_1       IN VARCHAR2
                            ,p_address_line_2       IN VARCHAR2);
--
PROCEDURE create_pl_location (p_style              IN VARCHAR2
                            ,p_address_line_1       IN VARCHAR2
                            ,p_address_line_2       IN VARCHAR2);
--
PROCEDURE update_pl_location (p_style               IN VARCHAR2
                            ,p_address_line_1       IN VARCHAR2
                            ,p_address_line_2       IN VARCHAR2);
--
END per_pl_location;

 

/
