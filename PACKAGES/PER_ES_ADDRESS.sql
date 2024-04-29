--------------------------------------------------------
--  DDL for Package PER_ES_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_ADDRESS" AUTHID CURRENT_USER AS
/* $Header: peespadp.pkh 120.0.12000000.1 2007/01/21 22:29:24 appldev ship $ */

--
PROCEDURE check_es_address (p_postal_code         IN VARCHAR2
                           ,p_region_2            IN VARCHAR2);
--
PROCEDURE create_es_address (p_style              IN VARCHAR2
                            ,p_postal_code        IN VARCHAR2
                            ,p_region_2           IN VARCHAR2);
--
PROCEDURE update_es_address (p_address_id         IN NUMBER
                            ,p_postal_code        IN VARCHAR2
                            ,p_region_2           IN VARCHAR2);
--
PROCEDURE update_es_address_style(p_address_id    IN NUMBER
                                 ,p_postal_code   IN VARCHAR2
                                 ,p_region_2      IN VARCHAR2
                                 ,p_style         IN VARCHAR2);
--
END per_es_address;

 

/
