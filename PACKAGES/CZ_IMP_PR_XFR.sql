--------------------------------------------------------
--  DDL for Package CZ_IMP_PR_XFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_PR_XFR" AUTHID CURRENT_USER AS
/*	$Header: cziprxfs.pls 115.14 2002/12/03 14:48:07 askhacha ship $		*/
PROCEDURE XFR_PRICE	 (	inRUN_ID 	IN 	PLS_INTEGER,
				COMMIT_SIZE	IN	PLS_INTEGER,
				MAX_ERR		IN 	PLS_INTEGER,
				INSERTS		  OUT NOCOPY PLS_INTEGER,
				UPDATES		  OUT NOCOPY PLS_INTEGER,
				FAILED		  OUT NOCOPY PLS_INTEGER,
                        inXFR_GROUP       IN    VARCHAR2);
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE XFR_PRICE_GROUP (	inRUN_ID	IN 	PLS_INTEGER,
				COMMIT_SIZE	IN	PLS_INTEGER,
				MAX_ERR		IN 	PLS_INTEGER,
				INSERTS		  OUT NOCOPY PLS_INTEGER,
				UPDATES		  OUT NOCOPY PLS_INTEGER,
				FAILED		  OUT NOCOPY PLS_INTEGER,
                        inXFR_GROUP       IN    VARCHAR2);

END CZ_IMP_PR_XFR;

 

/
