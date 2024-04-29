--------------------------------------------------------
--  DDL for Package JTF_TERR_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_DENORM_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftrdns.pls 115.0 2000/01/05 20:37:57 pkm ship      $ */

PROCEDURE Populate_API(
		  P_ERROR_CODE      OUT  NUMBER
		, P_ERROR_MSG       OUT  VARCHAR2
            , P_SOURCE_ID       IN   NUMBER
	);

END JTF_TERR_DENORM_PVT;

 

/
