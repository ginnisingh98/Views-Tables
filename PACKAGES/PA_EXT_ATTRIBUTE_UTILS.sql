--------------------------------------------------------
--  DDL for Package PA_EXT_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXT_ATTRIBUTE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAEXTUTS.pls 115.2 2003/08/14 20:59:07 syao noship $ */

-- This function is used to retrieve names of all the attribute groups
-- given a classification code

Function get_attribute_groups
  (
   p_classfication_code IN VARCHAR2
   )  RETURN VARCHAR2  ;

-- This function is used to retrieve names of all the page regions
-- given a classification code
Function get_page_regions
  (
   p_classfication_code IN VARCHAR2
   )  RETURN VARCHAR2  ;

FUNCTION check_object_page_region
  (
   p_object_type VARCHAR2,
   p_object_id   NUMBER,
   p_page_id NUMBER
   ) RETURN VARCHAR2;


END PA_ext_attribute_Utils;


 

/
