--------------------------------------------------------
--  DDL for Package GMF_PROFILE_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_PROFILE_STUB" AUTHID CURRENT_USER AS
/* $Header: GMFPRFLS.pls 115.0 2003/09/10 14:43:29 sschinch noship $ */
FUNCTION get_profile_value(pprofile_name IN VARCHAR2) RETURN NUMBER;

END GMF_PROFILE_STUB;

 

/
