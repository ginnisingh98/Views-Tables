--------------------------------------------------------
--  DDL for Package PJI_PORTAL_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PORTAL_DFLT_PARAMS" AUTHID CURRENT_USER AS
/* $Header: PJIRX06S.pls 120.1 2005/12/22 14:35:53 appldev noship $ */

FUNCTION get_dbi_params( p_Report_Type VARCHAR2 DEFAULT 'FM') RETURN VARCHAR2;

FUNCTION get_dbi_organization RETURN VARCHAR2;

END PJI_PORTAL_DFLT_PARAMS;

 

/
