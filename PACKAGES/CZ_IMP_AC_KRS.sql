--------------------------------------------------------
--  DDL for Package CZ_IMP_AC_KRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_AC_KRS" AUTHID CURRENT_USER AS
/*	$Header: cziackrs.pls 115.13 2002/12/03 14:44:25 askhacha ship $		*/

PROCEDURE KRS_CONTACT      (       inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                                   inXFR_GROUP     IN      VARCHAR2
                                   ) ;

PROCEDURE KRS_CUSTOMER     (       inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                                   inXFR_GROUP     IN      VARCHAR2
                                   );

PROCEDURE KRS_ADDRESS(	      inRUN_ID 		IN 	PLS_INTEGER,
			            COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE KRS_ADDRESS_USES(	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE KRS_CUSTOMER_END_USER(inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);


PROCEDURE KRS_END_USER (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE KRS_END_USER_GROUP (inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);


PROCEDURE KRS_USER_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER,
					DUPS			  OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);


END CZ_IMP_AC_KRS;

 

/
