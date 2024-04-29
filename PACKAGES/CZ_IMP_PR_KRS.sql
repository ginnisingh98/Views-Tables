--------------------------------------------------------
--  DDL for Package CZ_IMP_PR_KRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_PR_KRS" AUTHID CURRENT_USER AS
/*	$Header: cziprkrs.pls 115.10 2002/12/03 14:47:37 askhacha ship $		*/
----------------------------------------------------------------------------------
PROCEDURE KRS_PRICE (		inRUN_ID		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED			  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
----------------------------------------------------------------------------------
PROCEDURE KRS_PRICE_GROUP (		inRUN_ID		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED			  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
-----------------------------------------------------------------------------------
END CZ_IMP_PR_KRS;

 

/
