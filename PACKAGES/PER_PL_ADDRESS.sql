--------------------------------------------------------
--  DDL for Package PER_PL_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_ADDRESS" AUTHID CURRENT_USER AS
/* $Header: pepllhpa.pkh 120.0.12000000.1 2007/01/22 01:39:57 appldev noship $ */
--
--
--
PROCEDURE check_address_unique
( p_address_ID              NUMBER ,
  p_address_type            VARCHAR2,
  p_date_from               DATE,
  p_date_to                 DATE,
  p_person_id               NUMBER,
  p_pradd_ovlapval_override       in     boolean default FALSE);
--
PROCEDURE check_pl_address (
                            p_address_ID              NUMBER ,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_person_id               NUMBER,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2,
					p_pradd_ovlapval_override       in     boolean
                           ) ;
--
PROCEDURE create_pl_address (p_style        IN VARCHAR2,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_person_id               NUMBER,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2,
					p_pradd_ovlapval_override       in     boolean
                           );
--
PROCEDURE update_pl_address (p_address_id   IN NUMBER,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2);
--
PROCEDURE update_pl_address_style(p_address_id   IN NUMBER,
                            p_style             IN VARCHAR2,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2);
--
END per_pl_address;

 

/
