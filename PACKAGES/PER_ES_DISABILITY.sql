--------------------------------------------------------
--  DDL for Package PER_ES_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_DISABILITY" AUTHID CURRENT_USER AS
/* $Header: peesdisp.pkh 120.0.12000000.1 2007/01/21 22:25:44 appldev ship $ */
PROCEDURE check_es_disability(p_category  VARCHAR2
                             ,p_degree    NUMBER);
PROCEDURE create_es_disability(p_category VARCHAR2
                              ,p_degree   NUMBER);
PROCEDURE update_es_disability(p_category VARCHAR2
                              ,p_degree   NUMBER);
END per_es_disability;

 

/
