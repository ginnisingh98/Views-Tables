--------------------------------------------------------
--  DDL for Package CZ_IMP_PR_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_PR_MAIN" AUTHID CURRENT_USER AS
/*	$Header: cziprmns.pls 115.14 2002/12/03 14:47:51 askhacha ship $		*/
PROCEDURE CND_PRICE (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					);
PROCEDURE CND_PRICE_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					);

PROCEDURE MAIN_PRICE (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
PROCEDURE MAIN_PRICE_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE RPT_PRICE (inRUN_ID IN PLS_INTEGER);

PROCEDURE RPT_PRICE_GROUP (inRUN_ID IN PLS_INTEGER);

END CZ_IMP_PR_MAIN;

 

/
