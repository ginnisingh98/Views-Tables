--------------------------------------------------------
--  DDL for Package CZ_IMP_IM_XFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_IM_XFR" AUTHID CURRENT_USER AS
/*	$Header: cziimxfs.pls 120.1 2006/06/22 16:26:02 asiaston ship $		*/


PROCEDURE XFR_ITEM_MASTER (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE XFR_ITEM_PROPERTY_VALUE (	inRUN_ID    IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE XFR_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
				);

PROCEDURE XFR_ITEM_TYPE_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);

PROCEDURE XFR_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2,
                              p_rp_folder_id IN  NUMBER
					);
/* Constant Declarations */
cnDefSrcAppId                 CONSTANT NUMBER:=-1;
cnDefSrcTypeCode              CONSTANT NUMBER:=-1;
END CZ_IMP_IM_XFR;

 

/
