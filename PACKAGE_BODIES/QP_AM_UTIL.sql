--------------------------------------------------------
--  DDL for Package Body QP_AM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_AM_UTIL" AS
/* $Header: QPXAMUTB.pls 120.0 2005/06/02 01:05:47 appldev noship $ */

--==============================================================================
--FUNCTION    - Attrmgr_Installed
--FUNC TYPE   - Public
--DESCRIPTION - Utility Function to return the istatus of Attribute
--              Manager Installation.
--=============================================================================
FUNCTION Attrmgr_Installed
RETURN VARCHAR2
IS

BEGIN

    RETURN 'Y';

END Attrmgr_Installed;

FUNCTION Use_Organizer_for_Query_Find
RETURN VARCHAR2
IS

BEGIN

    RETURN 'Y';

END Use_Organizer_for_Query_Find;


END QP_AM_UTIL;

/
