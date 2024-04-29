--------------------------------------------------------
--  DDL for Package CZ_IMP_PS_NODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_PS_NODE" AUTHID CURRENT_USER AS
/*	$Header: czipsns.pls 120.1 2006/06/29 15:59:52 asiaston ship $		*/

PROCEDURE KRS_PS_NODE(inRUN_ID      IN 	 PLS_INTEGER,
			    COMMIT_SIZE	IN	 PLS_INTEGER,
			    MAX_ERR		IN 	 PLS_INTEGER,
			    INSERTS		IN   OUT NOCOPY  PLS_INTEGER,
			    UPDATES		IN OUT NOCOPY 	 PLS_INTEGER,
			    FAILED		IN   OUT NOCOPY  PLS_INTEGER,
			    DUPS		IN   OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			   );
PROCEDURE CND_PS_NODE(inRUN_ID 	IN 	 PLS_INTEGER,
			    COMMIT_SIZE	IN	 PLS_INTEGER,
			    MAX_ERR		IN 	 PLS_INTEGER,
			    FAILED		IN   OUT NOCOPY  PLS_INTEGER
			   );
PROCEDURE MAIN_PS_NODE(inRUN_ID 	IN 	 PLS_INTEGER,
			     COMMIT_SIZE	IN	 PLS_INTEGER,
			     MAX_ERR	IN 	 PLS_INTEGER,
			     INSERTS	IN OUT NOCOPY PLS_INTEGER,
			     UPDATES	IN OUT NOCOPY PLS_INTEGER,
			     FAILED		IN OUT NOCOPY PLS_INTEGER,
			     DUPS		IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			    );
PROCEDURE XFR_PS_NODE(inRUN_ID 	IN 	 PLS_INTEGER,
			    COMMIT_SIZE	IN	 PLS_INTEGER,
			    MAX_ERR		IN 	 PLS_INTEGER,
			    INSERTS		IN   OUT NOCOPY  PLS_INTEGER,
			    UPDATES		IN OUT NOCOPY 	 PLS_INTEGER,
			    FAILED		IN   OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			   );

PROCEDURE RPT_PS_NODE(inRUN_ID IN PLS_INTEGER);

PROCEDURE KRS_INTL_TEXT(inRUN_ID      IN 	   PLS_INTEGER,
			      COMMIT_SIZE	  IN	   PLS_INTEGER,
			      MAX_ERR	  IN 	   PLS_INTEGER,
			      INSERTS	  IN   OUT NOCOPY    PLS_INTEGER,
			      UPDATES	  IN   OUT NOCOPY    PLS_INTEGER,
			      FAILED	  IN   OUT NOCOPY    PLS_INTEGER,
			      DUPS		  IN   OUT NOCOPY    PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			     );
PROCEDURE CND_INTL_TEXT(inRUN_ID 	  IN 	   PLS_INTEGER,
			      COMMIT_SIZE	  IN	   PLS_INTEGER,
			      MAX_ERR	  IN 	   PLS_INTEGER,
			      FAILED	  IN   OUT NOCOPY    PLS_INTEGER
			     );
PROCEDURE MAIN_INTL_TEXT(inRUN_ID 	  IN 	   PLS_INTEGER,
			       COMMIT_SIZE  IN	   PLS_INTEGER,
			       MAX_ERR	  IN 	   PLS_INTEGER,
			       INSERTS	  IN OUT NOCOPY PLS_INTEGER,
			       UPDATES	  IN OUT NOCOPY PLS_INTEGER,
			       FAILED	  IN OUT NOCOPY PLS_INTEGER,
			       DUPS		  IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			      );
PROCEDURE XFR_INTL_TEXT(inRUN_ID 	  IN 	   PLS_INTEGER,
			      COMMIT_SIZE	  IN	   PLS_INTEGER,
			      MAX_ERR	  IN 	   PLS_INTEGER,
			      INSERTS	  IN   OUT NOCOPY    PLS_INTEGER,
			      UPDATES	  IN OUT NOCOPY    PLS_INTEGER,
			      FAILED	  IN   OUT NOCOPY    PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
			     );

PROCEDURE RPT_INTL_TEXT(inRUN_ID IN PLS_INTEGER);

PROCEDURE KRS_DEVL_PROJECT(inRUN_ID      IN 	PLS_INTEGER,
			         COMMIT_SIZE   IN	PLS_INTEGER,
			         MAX_ERR	     IN 	PLS_INTEGER,
			         INSERTS	     IN   OUT NOCOPY PLS_INTEGER,
			         UPDATES	     IN OUT NOCOPY 	PLS_INTEGER,
			         FAILED	     IN   OUT NOCOPY PLS_INTEGER,
			         DUPS	     IN   OUT NOCOPY PLS_INTEGER,
                           inXFR_GROUP   IN VARCHAR2
			        );
PROCEDURE CND_DEVL_PROJECT(inRUN_ID      IN 	PLS_INTEGER,
			         COMMIT_SIZE   IN	PLS_INTEGER,
			         MAX_ERR	     IN 	PLS_INTEGER,
			         FAILED	     IN   OUT NOCOPY PLS_INTEGER
			        );
PROCEDURE MAIN_DEVL_PROJECT(inRUN_ID     IN 	PLS_INTEGER,
			          COMMIT_SIZE  IN	PLS_INTEGER,
			          MAX_ERR	     IN 	PLS_INTEGER,
			          INSERTS	     IN OUT NOCOPY PLS_INTEGER,
			          UPDATES	     IN OUT NOCOPY PLS_INTEGER,
			          FAILED	     IN OUT NOCOPY PLS_INTEGER,
			          DUPS	     IN OUT NOCOPY PLS_INTEGER,
                      inXFR_GROUP  IN     VARCHAR2,
                      p_rp_folder_id  IN NUMBER -- sselahi rpf
			         );
PROCEDURE XFR_DEVL_PROJECT(inRUN_ID      IN 	PLS_INTEGER,
			         COMMIT_SIZE   IN	PLS_INTEGER,
			         MAX_ERR	     IN 	PLS_INTEGER,
			         INSERTS	     IN   OUT NOCOPY PLS_INTEGER,
			         UPDATES	     IN OUT NOCOPY 	PLS_INTEGER,
			         FAILED	     IN   OUT NOCOPY PLS_INTEGER,
                     inXFR_GROUP       IN    VARCHAR2,
			         P_rp_folder_id     IN 	NUMBER -- sselahi rpf
			        );

PROCEDURE RPT_DEVL_PROJECT(inRUN_ID IN PLS_INTEGER);

/* Constant Declarations */
cnOracleToMerlinOffset	      CONSTANT NUMBER:=256;		        /*Conversion Const*/
cnProduct		      CONSTANT NUMBER:=cnOracleToMerlinOffset+2;/*Product Type*/
cnComponent		      CONSTANT NUMBER:=cnOracleToMerlinOffset+3;/*Component Type*/
cnFeature		      CONSTANT NUMBER:=cnOracleToMerlinOffset+5;/*Feature Type*/
cnOption		      CONSTANT NUMBER:=cnOracleToMerlinOffset+6;/*Option Type*/
cnModel		              CONSTANT NUMBER:=1;                       /*Oracle Model Type*/
cnOptionClass	              CONSTANT NUMBER:=2;                       /*Oracle Option Class Type*/
cnStandard                    CONSTANT NUMBER:=4;                       /*Oracle Standard Type*/
cnReference                   CONSTANT NUMBER:=263;
cnConnector                   CONSTANT NUMBER:=264;
cnTotal                       CONSTANT NUMBER:=272;
cnResource                    CONSTANT NUMBER:=273;
bomModel                      CONSTANT NUMBER:=436; /*BOM Item Model type*/
bomOptionClass                CONSTANT NUMBER:=437; /*BOM Item OptionClass type*/
bomStandard                   CONSTANT NUMBER:=438; /*BOM Item Standard type*/
/* BOM_TREATMENT values */
cnNormal                      CONSTANT NUMBER:=0;
cnSkip	                      CONSTANT NUMBER:=1;
cnLeaf                        CONSTANT NUMBER:=2;
cnFlatten                     CONSTANT NUMBER:=3;
/* Oracle Yes/No values */
OraYes                        CONSTANT NUMBER:=1;
OraNo                         CONSTANT NUMBER:=2;
cnDefSrcAppId                 CONSTANT NUMBER:=-1;
cnDefSrcTypeCode              CONSTANT NUMBER:=-1;
--The segment length of the SORT_ORDER column, correlates with the value hardcoded in the bom_exploder
--procedure

n_SortWidth                   NUMBER := Bom_Common_Definitions.G_Bom_SortCode_Width;
gContractsModel               BOOLEAN := FALSE;  /* cz_contracts_api_grp.import_generic must set to true to allow seeded models */

END CZ_IMP_PS_NODE;

 

/
