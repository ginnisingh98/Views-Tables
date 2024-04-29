--------------------------------------------------------
--  DDL for Package HR_H2PI_BG_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_BG_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: hrh2pibg.pkh 120.0 2005/05/31 00:38:29 appldev noship $ */

g_to_business_group_id NUMBER(15);
g_request_id NUMBER(15);

PROCEDURE upload_location (p_from_client_id NUMBER);
PROCEDURE upload_hr_organization (p_from_client_id NUMBER);
PROCEDURE upload_element_type (p_from_client_id NUMBER);
FUNCTION  org_exists (p_from_client_id NUMBER,
                      p_org_id NUMBER,
                      p_table  NUMBER) RETURN NUMBER;

FUNCTION get_id_from_value (p_org_information_id in NUMBER,
                            p_org_info_number    in NUMBER)  return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(org_exists, WNDS);


END hr_h2pi_bg_upload;

 

/
