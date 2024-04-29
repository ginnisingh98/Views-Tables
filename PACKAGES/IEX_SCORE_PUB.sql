--------------------------------------------------------
--  DDL for Package IEX_SCORE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpscrs.pls 120.14 2006/08/24 17:23:42 raverma ship $ */
/*#
 * Scoring APIs allow the user to manage scoring engines in Oracle Collections.
 * @rep:scope public
 * @rep:product IEX
 * @rep:lifecycle active
 * @rep:displayname Scoring API
 * @rep:category BUSINESS_ENTITY IEX_COLLECTION_SCORE
 */


  -- this will be passed back by the get_components procedure
  TYPE SCORE_ENG_COMP_REC IS RECORD(
    SCORE_ID               NUMBER        ,
    SCORE_COMPONENT_ID     NUMBER        ,
    SCORE_COMP_WEIGHT      NUMBER        ,
    SCORE_COMP_VALUE       VARCHAR2(2000));

  TYPE SCORE_ENG_COMP_TBL IS TABLE OF SCORE_ENG_COMP_REC INDEX BY binary_integer;

  TYPE SCORE_REC_TYPE IS RECORD(
    SCORE_ID               NUMBER        ,
    -- clchang updated 08/22/03
    --SCORE_NAME             VARCHAR2(50)  := FND_API.G_MISS_CHAR,
    SCORE_NAME             VARCHAR2(256) ,
    LAST_UPDATE_DATE       DATE          ,
    LAST_UPDATED_BY        NUMBER        ,
    CREATION_DATE          DATE          ,
    CREATED_BY             NUMBER        ,
    LAST_UPDATE_LOGIN      NUMBER        ,
    SCORE_DESCRIPTION      VARCHAR2(150) ,
    ENABLED_FLAG           VARCHAR2(1)   ,
    VALID_FROM_DT          DATE          ,
    VALID_TO_DT            DATE          ,
    CAMPAIGN_SCHED_ID      NUMBER        ,
    JTF_OBJECT_CODE        VARCHAR2(25)  ,
    CONCURRENT_PROG_ID     NUMBER        ,
    CONCURRENT_PROG_NAME   VARCHAR2(30)  ,
    SECURITY_GROUP_ID      NUMBER        ,
    REQUEST_ID             NUMBER        ,
    PROGRAM_APPLICATION_ID NUMBER        ,
    PROGRAM_ID             NUMBER        ,
    PROGRAM_UPDATE_DATE    DATE          ,
    STATUS_DETERMINATION   VARCHAR2(1)   ,
    WEIGHT_REQUIRED        VARCHAR2(3)   ,
    SCORE_RANGE_LOW        VARCHAR2(1000)   ,
    SCORE_RANGE_HIGH       VARCHAR2(1000)   ,
    OUT_OF_RANGE_RULE      VARCHAR2(20)   );


  TYPE SCORE_TBL_TYPE IS TABLE OF SCORE_REC_TYPE INDEX BY binary_integer;

  G_MISS_SCORE_REC          IEX_SCORE_PUB.SCORE_REC_TYPE;
  G_MISS_SCORE_TBL          IEX_SCORE_PUB.SCORE_TBL_TYPE;

  TYPE SCORE_COMP_REC_TYPE IS RECORD (
    SCORE_COMPONENT_ID       NUMBER        ,
    SCORE_COMP_WEIGHT        NUMBER(3,2)   := 0,
    SCORE_ID                 NUMBER        ,
    ENABLED_FLAG             VARCHAR2(10)  ,
    SCORE_COMP_TYPE_ID       NUMBER        ,
    LAST_UPDATE_DATE         DATE          ,
    LAST_UPDATED_BY          NUMBER        ,
    CREATION_DATE            DATE          ,
    CREATED_BY               NUMBER        ,
    LAST_UPDATE_LOGIN        NUMBER        );

  TYPE SCORE_COMP_TBL_TYPE IS TABLE OF SCORE_COMP_REC_TYPE
              INDEX BY binary_integer;

    G_MISS_SCORE_COMP_REC          IEX_SCORE_PUB.SCORE_COMP_REC_TYPE;
    G_MISS_SCORE_COMP_TBL          IEX_SCORE_PUB.SCORE_COMP_TBL_TYPE;



  -- clchang added new column 'NEW_VALUE' 09/22/2004

  TYPE SCORE_COMP_DET_REC_TYPE IS RECORD (
    SCORE_COMP_DET_ID      NUMBER        ,
    RANGE_LOW              NUMBER        ,
    RANGE_HIGH             NUMBER        ,
    VALUE                  NUMBER        ,
    NEW_VALUE              VARCHAR2(2000),
    SCORE_COMPONENT_ID     NUMBER        ,
    OBJECT_VERSION_NUMBER  NUMBER        ,
    PROGRAM_ID             NUMBER        ,
    LAST_UPDATE_DATE       DATE          ,
    LAST_UPDATED_BY        NUMBER        ,
    CREATION_DATE          DATE          ,
    CREATED_BY             NUMBER        ,
    LAST_UPDATE_LOGIN      NUMBER        );


  TYPE SCORE_COMP_DET_TBL_TYPE IS TABLE OF SCORE_COMP_DET_REC_TYPE
                                  INDEX BY binary_integer;

    G_MISS_SCORE_COMP_DET_REC      IEX_SCORE_PUB.SCORE_COMP_DET_REC_TYPE;
    G_MISS_SCORE_COMP_DET_TBL      IEX_SCORE_PUB.SCORE_COMP_DET_TBL_TYPE;

 -- updated by clchang 04/19/2004 for 11i.IEX.H
 -- added new column METRIC_FLAG
 -- updated by jypark 11/05/2004 for 11i.IEX.H
 -- added new column DISPLAY_ORDER

  TYPE SCORE_COMP_TYPE_REC_TYPE IS RECORD (
    SCORE_COMP_TYPE_ID     NUMBER           ,
    OBJECT_VERSION_NUMBER  NUMBER           ,
    PROGRAM_ID             NUMBER           ,
    SECURITY_GROUP_ID      NUMBER           ,
    LAST_UPDATE_DATE       DATE             ,
    LAST_UPDATED_BY        NUMBER           ,
    LAST_UPDATE_LOGIN      NUMBER           ,
    CREATION_DATE          DATE             ,
    CREATED_BY             NUMBER           ,
    SCORE_COMP_VALUE       VARCHAR2(2000)   ,
    ACTIVE_FLAG            VARCHAR2(10)     ,
    JTF_OBJECT_CODE        VARCHAR2(25)     ,
    SOURCE_LANG            VARCHAR2(4)      ,
    SCORE_COMP_NAME        VARCHAR2(45)     ,
    DESCRIPTION            VARCHAR2(80)     ,
    FUNCTION_FLAG          VARCHAR2(1)      ,
    METRIC_FLAG            VARCHAR2(1)      ,
    DISPLAY_ORDER          NUMBER);


  TYPE SCORE_COMP_TYPE_TBL_TYPE IS TABLE OF SCORE_COMP_TYPE_REC_TYPE
                                  INDEX BY binary_integer;

    G_MISS_SCORE_COMP_TYPE_REC      IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_TYPE;
    G_MISS_SCORE_COMP_TYPE_TBL      IEX_SCORE_PUB.SCORE_COMP_TYPE_TBL_TYPE;


  TYPE SCORE_ID_TBL IS TABLE OF NUMBER INDEX BY binary_integer;

  TYPE SCORE_COMP_ID_TBL IS TABLE OF NUMBER INDEX BY binary_integer;

  TYPE SCORE_COMP_DET_ID_TBL IS TABLE OF NUMBER INDEX BY binary_integer;

/*
  -- Start of comments
  -- API name   : Init_AST_SCORE_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by AST_SCORE_PUB
  -- Parameters : None
  -- Returns    : IEX_SCORE_PUB.SCORE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION Init_IEX_SCORE_Rec RETURN IEX_SCORE_PUB.SCORE_REC_TYPE;


  -- Start of comments
  -- API name   : Init_IEX_SCORE_COMP_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by IEX_SCORE_PUB
  -- Parameters : None
  -- Returns    : IEX_SCORE_PUB.SCORE_COMP_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION Init_IEX_SCORE_COMP_Rec RETURN IEX_SCORE_PUB.SCORE_COMP_REC_TYPE;


  -- Start of comments
  -- API name   : Init_IEX_SCORE_COMP_TBL
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by IEX_SCORE_PUB
  -- Parameters : None
  -- Returns    : IEX_SCORE_PUB.SCORE_COMP_TBL_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION Init_IEX_SCORE_COMP_Tbl RETURN IEX_SCORE_PUB.SCORE_COMP_TBL_TYPE;

*/

/*#
 * Creates scoring engines.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_rec Collections Scoring Engine table
 * @param x_dup_status    duplicate flag
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param x_score_id      scoring engine identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Scoring Engines
 */
Procedure Create_Score
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_REC               IN IEX_SCORE_PUB.SCORE_REC_TYPE  ,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            X_SCORE_ID                OUT NOCOPY NUMBER);


/*#
 * updates scoring engines.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_tbl     Scoring Engine table
 * @param x_dup_status    duplicate flag
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Scoring Engines
 */
Procedure Update_Score
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_TBL               IN IEX_SCORE_PUB.SCORE_TBL_TYPE ,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



/*#
 * Deletes scoring engines.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_id_tbl Scoring Engine Identifier table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Scoring Engines
 */
Procedure Delete_Score
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_ID_TBL            IN IEX_SCORE_PUB.SCORE_ID_TBL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



/*#
 * creates scoring engine components.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_rec Scoring Component table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param x_score_comp_id  Scoring component identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Scoring Engine Components
 */
Procedure Create_SCORE_COMP
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_COMP_Rec          IN IEX_SCORE_PUB.SCORE_COMP_REC_Type,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_SCORE_COMP_ID           OUT NOCOPY NUMBER);

/*#
 * updates scoring engine components.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_tbl Scoring component table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Scoring Engine Components
 */
Procedure Update_SCORE_COMP
	    ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_TBL          IN IEX_SCORE_PUB.SCORE_COMP_TBL_Type ,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

/*#
 * Deletes scoring engine components.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_id  scoring engine identifier
 * @param p_score_comp_id_tbl Scoring component identifier table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Scoring Engine Components
 */
Procedure Delete_SCORE_COMP
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_ID                IN NUMBER,
        p_SCORE_COMP_ID_TBL       IN IEX_SCORE_PUB.SCORE_COMP_ID_TBL,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2);

/*#
 * creates scoring engine component types.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_type_rec Scoring component type table
 * @param x_dup_status  duplicate flag
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param x_score_comp_type_id   Scoring component type identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Scoring Engine Component Types
 */
Procedure Create_SCORE_COMP_TYPE
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_COMP_TYPE_Rec     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_Type,
        x_dup_status              OUT NOCOPY VARCHAR2,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_SCORE_COMP_TYPE_ID      OUT NOCOPY NUMBER);

/*#
 * updates scoring engine component types.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_type_tbl Scoring component type table
 * @param x_dup_status  duplicate flag
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Scoring Engine Component Types
 */
Procedure Update_SCORE_COMP_TYPE
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_TYPE_TBL     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_TBL_TYPE,
              x_dup_status              OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

/*#
 * deletes scoring engine component types.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_type_tbl Scoring component type table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Scoring Engine Component Types
 */
Procedure Delete_SCORE_COMP_TYPE
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_COMP_TYPE_TBL     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_TBL_TYPE ,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2);



/*#
 * creates scoring engine component details.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param px_score_comp_det_tbl Scoring component details table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Scoring Engine Component Details
 */
Procedure Create_SCORE_COMP_DET
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              px_SCORE_COMP_DET_TBL     IN OUT NOCOPY IEX_SCORE_PUB.SCORE_COMP_DET_TBL_Type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

/*#
 * updates scoring engine component details.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_comp_det_tbl Scoring component details table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Scoring Engine Component Details
 */
Procedure Update_SCORE_COMP_DET
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_COMP_DET_TBL      IN IEX_SCORE_PUB.SCORE_COMP_DET_TBL_Type ,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2);



/*#
 * deletes scoring engine component details.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_Score_comp_id   Associated scoring component identifier
 * @param p_score_comp_det_id_tbl Scoring component details table
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Scoring Engine Component Details
 */
Procedure Delete_SCORE_COMP_DET
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2 ,
        p_commit                  IN VARCHAR2 ,
        p_SCORE_COMP_ID           IN NUMBER,
        p_SCORE_COMP_DET_ID_TBL   IN IEX_SCORE_PUB.SCORE_COMP_DET_ID_TBL,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2);


/* 12/09/2002 clchang added
 * new function to make a copy of scoring engine.
 */
/*#
 * copies scoring engine including filters, components and component details.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_id    Original score identifier
 * @param x_score_id    Identifier for copied score
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Scoring Engine
 */
Procedure Copy_ScoringEngine
                   (p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER DEFAULT NULL,
                    x_score_id      OUT NOCOPY NUMBER ,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2);



/*#
 * generates scores for a special scoring engine.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_score_id      Score identifier used to score
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Score
 */
Procedure Get_Score(p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2,
                    p_score_id      IN  NUMBER DEFAULT NULL,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2);


END IEX_SCORE_PUB;

/
