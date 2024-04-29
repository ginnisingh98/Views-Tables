--------------------------------------------------------
--  DDL for Package JTF_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvhlds.pls 120.2 2005/08/18 22:55:11 stopiwal ship $ */

PROCEDURE load_loc_areas;

-- Start of Comments
--
-- NAME
--   Load_Locations
--
-- PURPOSE
--   This procedure is created to as a concurrent program wrapper which
--   will call the Load_Loc_Areas and will return errors if any
--
-- NOTES
--
--
-- HISTORY
--   05/03/1999      ptendulk    created
-- End of Comments

PROCEDURE Load_Locations
          (errbuf        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
           retcode       OUT NOCOPY /* file.sql.39 change */    NUMBER) ;

END JTF_Loc_PVT;

 

/
