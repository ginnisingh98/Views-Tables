--------------------------------------------------------
--  DDL for Package PJI_PAGE_LAYOUTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PAGE_LAYOUTS" AUTHID CURRENT_USER as
/*  $Header: PJIPGLYTS.pls 120.0 2005/05/29 12:32:44 appldev noship $  */

FUNCTION PJI_PAGE_ID(
			p_project_id IN Number,
			p_page_type_code IN varchar2
			)  return number;


FUNCTION PJI_PAGE_NAME(
			p_project_id IN Number,
			p_page_type_code IN varchar2
			)  return varchar2;

END PJI_PAGE_LAYOUTS;

 

/
