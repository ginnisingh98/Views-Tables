--------------------------------------------------------
--  DDL for Package PER_ES_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_LOCATION" AUTHID CURRENT_USER AS
/* $Header: peesladp.pkh 120.0.12000000.1 2007/01/21 22:29:05 appldev ship $ */
  g_package  VARCHAR2(33) := 'per_es_location.';

PROCEDURE check_es_location (p_style              IN VARCHAR2
                            ,p_postal_code        IN VARCHAR2
                            ,p_region_2           IN VARCHAR2);

PROCEDURE create_es_location (p_style             IN VARCHAR2
                             ,p_postal_code       IN VARCHAR2
                             ,p_region_2          IN VARCHAR2);

PROCEDURE update_es_location (p_style             IN VARCHAR2
                             ,p_postal_code       IN VARCHAR2
                             ,p_region_2          IN VARCHAR2);

END per_es_location;

 

/
