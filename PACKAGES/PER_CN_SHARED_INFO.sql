--------------------------------------------------------
--  DDL for Package PER_CN_SHARED_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_SHARED_INFO" AUTHID CURRENT_USER AS
/* $Header: pecnshin.pkh 120.0.12010000.3 2010/04/15 12:12:10 dduvvuri noship $ */

 FUNCTION get_lookup_meaning(p_code IN VARCHAR2, p_type IN VARCHAR2)
 RETURN VARCHAR2;

Function cn_get_doc_details
(p_person_id IN NUMBER,
 p_date IN DATE,
 p_type IN VARCHAR2
)
RETURN VARCHAR2 ;

Function get_parent_org_id
(p_organization_id IN NUMBER
)
RETURN NUMBER ;

Function get_cadre_job_details(p_person_id IN NUMBER , p_date IN DATE)
return VARCHAR2;

Function get_tech_post_details(p_person_id IN NUMBER , p_date IN DATE)
return VARCHAR2;

END per_cn_shared_info;

/
