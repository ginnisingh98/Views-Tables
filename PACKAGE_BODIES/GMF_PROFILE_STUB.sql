--------------------------------------------------------
--  DDL for Package Body GMF_PROFILE_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_PROFILE_STUB" AS
/* $Header: GMFPRFLB.pls 115.1 2003/09/10 14:57:37 sschinch noship $ */

FUNCTION get_profile_value(pprofile_name IN VARCHAR2) RETURN NUMBER IS
BEGIN
	RETURN(NVL(FND_PROFILE.VALUE(pprofile_name),0));
END;
END GMF_PROFILE_STUB;

/
