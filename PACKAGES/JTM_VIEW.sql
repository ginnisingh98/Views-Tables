--------------------------------------------------------
--  DDL for Package JTM_VIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_VIEW" AUTHID CURRENT_USER AS
/* $Header: jtmviews.pls 120.1 2005/08/24 02:19:21 saradhak noship $ */

FUNCTION get_fnd_profile_options_name (p_profile_option_name VARCHAR2) RETURN VARCHAR2;
FUNCTION get_fnd_profile_options_desc (p_profile_option_name VARCHAR2) RETURN VARCHAR2;
FUNCTION get_fnd_lookup_types_mean (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER) RETURN VARCHAR2;
FUNCTION get_fnd_lookup_types_desc (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER) RETURN VARCHAR2;
FUNCTION get_fnd_descriptive_flexs_titl (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2;
FUNCTION get_fnd_descriptive_flexs_prom (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2;
FUNCTION get_fnd_descriptive_flexs_desc (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2;

END jtm_view;

 

/
