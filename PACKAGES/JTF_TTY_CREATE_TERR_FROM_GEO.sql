--------------------------------------------------------
--  DDL for Package JTF_TTY_CREATE_TERR_FROM_GEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_CREATE_TERR_FROM_GEO" AUTHID CURRENT_USER AS
/* $Header: jtfctfgs.pls 120.1 2005/09/22 00:14:45 vbghosh noship $ */
--    Start of Comments
--    PURPOSE
--       For creating/updating equivalent territory for each geo territory created
--      or updated
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      09/20/05   Vbghosh  Created.
--    End of Comments
----

PROCEDURE CREATE_TERR (p_geo_terr_id        IN NUMBER,
		               p_geo_parent_terr_id IN NUMBER,
		               p_geo_terr_name      IN VARCHAR2);




END JTF_TTY_CREATE_TERR_FROM_GEO;

 

/
