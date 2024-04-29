--------------------------------------------------------
--  DDL for Package CZ_IMP_IM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_IM_MAIN" AUTHID CURRENT_USER AS
/*	$Header: cziimmns.pls 120.1 2006/06/22 16:26:59 asiaston ship $		*/

PROCEDURE CND_ITEM_MASTER (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					);
PROCEDURE CND_ITEM_PROPERTY_VALUE (     inRUN_ID        IN      PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					);
PROCEDURE CND_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					);
PROCEDURE CND_ITEM_TYPE_PROPERTY (      inRUN_ID        IN      PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					);
PROCEDURE CND_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					);


PROCEDURE MAIN_ITEM_MASTER (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                              DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
PROCEDURE MAIN_ITEM_PROPERTY_VALUE(     inRUN_ID        IN      PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                              DUPS              IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
PROCEDURE MAIN_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
PROCEDURE MAIN_ITEM_TYPE_PROPERTY (     inRUN_ID        IN      PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					);
PROCEDURE MAIN_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
                              COMMIT_SIZE       IN    PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                              DUPS              IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2,
                              p_rp_folder_id IN  NUMBER

					);

PROCEDURE RPT_ITEM_MASTER(inRUN_ID IN PLS_INTEGER);

PROCEDURE RPT_ITEM_PROPERTY_VALUE(inRUN_ID IN PLS_INTEGER);

PROCEDURE RPT_ITEM_TYPE(inRUN_ID IN PLS_INTEGER);

PROCEDURE RPT_ITEM_TYPE_PROPERTY(inRUN_ID IN PLS_INTEGER);

PROCEDURE RPT_PROPERTY(inRUN_ID IN PLS_INTEGER);
/* constants*/
cnDefSrcAppId                 CONSTANT NUMBER:=-1;
cnDefSrcTypeCode              CONSTANT NUMBER:=-1;
END CZ_IMP_IM_MAIN;

 

/
