--------------------------------------------------------
--  DDL for Package IEX_SCORE_NEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_NEW_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvscfs.pls 120.9.12010000.3 2009/12/21 15:43:33 barathsr ship $ */

type Scores_tbl is table of number
    index by binary_integer;

  -- this will be passed back by the get_components procedure
  TYPE SCORE_ENG_COMP_REC IS RECORD(
    SCORE_ID               NUMBER         ,
    SCORE_COMPONENT_ID     NUMBER         ,
    SCORE_COMP_WEIGHT      NUMBER         ,
    SCORE_COMP_VALUE       VARCHAR2(2000) ,
    FUNCTION_FLAG          VARCHAR2(1));

  -- this will be used for new getScoreHistory function
  Type SCORE_HISTORY_REC IS RECORD
    (SCORE_HISTORY_ID   NUMBER,
     SCORE_ID           NUMBER,
     SCORE_VALUE        NUMBER,
     CREATION_DATE      DATE);

  TYPE SCORE_ENG_COMP_TBL IS TABLE OF SCORE_ENG_COMP_REC INDEX BY binary_integer;
  TYPE SCORE_HISTORY_TBL IS TABLE OF SCORE_HISTORY_REC INDEX BY binary_integer;

type SCORE_OBJECTS_TBL is table of number index by binary_integer;
type NEW_SCORES_TBL is table of number index by binary_integer;

/*
|| Overview:   validates any given objectID/Object_type pair
||
|| Parameter:  Object_ID PK of object you wish to score
||             Object_Type Type of Object you wish to score
||      Alternatively if you wish to score another TYPE of object not listed pass the following as well:
||             p_col_name name of colum you wish to select on
||             p_table_name name of table to select from
||
|| Return value:  True =OK; Falso=Error
||
|| Source Tables: IEX_DELINQUENCIES_ALL, IEX_CASES_B_ALL, HZ_PARTIES, AR_PAYMENT_SCHEDULES
||
|| Target Tables:
||
|| Creation date:       01/14/02 3:25:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
function validateObjectID (p_object_id in number,
                           p_object_type in varchar2,
                           p_col_name in varchar2 default null,
                           p_table_name in varchar2 default null) return BOOLEAN;

/*
|| Overview:  compares whether the score engine being used for this object is of valid type
||
|| Parameter:  p_score_id => scoring engine; p_object_type => type of object you wish to score
||
|| Return value: true=OK; FALSE=error
||
|| Source Tables:  IEX_SCORES
||
|| Target Tables:  NA
||
|| Creation date:  01/14/02 4:47:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
function checkObject_Compatibility(p_score_id in number,
                                   p_object_type in varchar2) return BOOLEAN;


/*
|| Overview:  Validate Score_Engine
||
|| Parameter:
||
|| Source Tables:
||
|| Target Tables:
||
|| Creation date:       01/14/02 3:08:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
PROCEDURE Validate_Score_Engine(p_score_id in number);


/*
 * clchang added this new procedure 10/18/04 for 11.5.11.
 * this procedure will get the score_range_low, score_range_high,
 * out_of_range_rule for a given score engine, and update the
 * global variables: G_MIN_SCORE, G_MAX_SCORE, G_RULE.
 *
 * Parameter: P_SCORE_ID   Scoring_Engine
 * Major Modifications:
 *      when            who                       what
 *     10/18/04        clchang                  created
 ******/
PROCEDURE getScoreRange(P_SCORE_ID       IN NUMBER);



/*
|| this procedure will get all components for a given score engine
||  and return them as a tbl
||
|| Parameter: P_SCORE_ID   Scoring_Engine
||            X_SCORE_COMP_TBL = table of components attached to the Scoring engine
||
|| Return value: select statement for the Universe
||
|| Source Tables: IEX_SCORES, IEX_SCORE_COMPONENTS, IEX_SCORE_COMP_TYPES_B/TL
||
|| Target Tables: none
||
|| Creation date:  01/14/02 1:55:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma             created
||                      03/12/02        raverma             added function_flag to return tbl
*/
PROCEDURE getComponents(P_SCORE_ID       IN NUMBER,
                        X_SCORE_COMP_TBL OUT NOCOPY IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL);


/*
|| Overview:   This is the "main" scoring function.  It will score any objects using the
||             table of components passed to.  The assumption is that any validation has been done already AND
||             the table of components passed here is appropriate for the universe of IDS
||
|| Parameter:  p_score_comp_tbl => components to use for scoring execution
||             t_object_ids     => universe of object_ids you wish to score
||                  (this universe MUST be valid for the components definition)
||             x_scores_tbl     => table of scores for the IDs passed
||
|| Source Tables: iex_score_comp_det
||
|| Target Tables: NA
||
|| Creation date:       01/14/02 5:27:PM
||
|| Major Modifications: when            who                       what
||
*/
procedure getScores(p_score_comp_tbl IN IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL,
                    t_object_ids     IN IEX_FILTER_PUB.UNIVERSE_IDS,
                    x_scores_tbl     OUT NOCOPY IEX_SCORE_NEW_PVT.SCORES_TBL);

/*
|| Overview:    score all objects for a given scoring engine
||
|| Parameter:   p_score_id => scoring engine ID
||
|| Source Tables:   IEX_SCORES, IEX_SCORE_COMPONENTS_VL, IEX_SCORE_COMP_TYPES, IEX_SCORE_COMP_DET,
||                  IEX_OBJECT_FILTERS
||
|| Target Tables:
||
|| Creation date:       01/22/02 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/22/02        raverma             created
*/
procedure scoreObjects(p_api_version    IN NUMBER := 1.0,
                       p_init_msg_list  IN VARCHAR2 ,
                       p_commit         IN VARCHAR2 ,
                       P_SCORE_ID       IN NUMBER,
		       p_unv_obj_id in varchar2 default null,--Added for Bug 8933776 17-Dec-2009 barathsr
		       p_limit_rows_val in number default null,--Added for Bug 8933776 17-Dec-2009 barathsr
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2);

/*
|| Overview:    score a single object given it's ID, it's Type, and it's Scoring Engine
||
|| Parameter:   p_score_id => scoring engine ID
||
|| Source Tables:   IEX_SCORES, IEX_SCORE_COMPONENTS_VL, IEX_SCORE_COMP_TYPES, IEX_SCORE_COMP_DET,
||                  IEX_OBJECT_FILTERS
||
|| Target Tables:  will return a -1 in case of error
||
|| Creation date:       01/22/02 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/22/02        raverma             created
*/
function scoreObject(p_commit         IN VARCHAR2 ,
                     P_OBJECT_ID      IN NUMBER,
                     P_OBJECT_TYPE    IN VARCHAR2,
                     P_SCORE_ID       IN NUMBER) RETURN NUMBER;

/* this will be called by the concurrent program to score customers
 */
Procedure Score_Concur(ERRBUF      OUT NOCOPY VARCHAR2,
                       RETCODE     OUT NOCOPY VARCHAR2,
		       P_ORG_ID     IN NUMBER default null, --Added for MOAC
                       P_SCORE_ID1  IN NUMBER,
                       P_Score_ID2  IN NUMBER default null,
                       P_Score_ID3  IN NUMBER default null,
                       P_Score_ID4  IN NUMBER default null,
                       P_Score_ID5  IN NUMBER default null,
		       p_show_output in varchar2 default null, --Added for Bug 8933776 30-Nov-2009 barathsr
		       p_object_id in varchar2 default null,--Added for Bug 8933776 17-Dec-2009 barathsr
		       p_limit_rows in number default null);--Added for Bug 8933776 17-Dec-2009 barathsr


/*
|| Overview:    delete rows from IEX_SCORE_HISTORIES to improve performance
||
|| Parameter:   p_score_object_code => score_object_code to erase
||              p_from_date         => remove from this date
||              p_to_Date           => remove up to this date
||              p_request_id        => remove this request
||              p_save_last_run     => save the last run of the object type
||
|| Source Tables:
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:  01/28/03 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/28/03        raverma                created
*/
Procedure eraseScores(ERRBUF              OUT NOCOPY VARCHAR2,
                      RETCODE             OUT NOCOPY VARCHAR2,
                      P_TRUNCATE          IN VARCHAR2,  -- fix a bug 5765878 to truncate table to perform better by Ehuh 02.19.2007
                      P_SCORE_OBJECT_ID   IN NUMBER default null,
                      P_SCORE_OBJECT_CODE IN VARCHAR2 default null,
                      P_FROM_DATE         IN varchar2 default null,
                      P_TO_DATE           IN varchar2 default null,
                      P_REQUEST_ID        IN NUMBER default null,
                      P_SAVE_LAST_RUN     IN VARCHAR2 ,
                      P_BATCH_SIZE        IN NUMBER);

/*
|| Overview:    Returns an array of score values for a given objectID/Type
||
|| Parameter:    p_score_object_id   object scored in IEX_SCORE_HISTORIES required
||               p_score_object_code object_code in IEX_SCORE_HISTORIES required
||               p_begin_Date  begin date restriction optional
||               p_end_date    end date restriction optional
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:  SCORE_HISTORY_ID  -> PK to IEX_SCORE_HISTORIES
||                SCORE_ID          -> scoreEngine used to calculate score
||                SCORE_VALUE       -> score of object
||                CREATION_DATE     -> date object was scored
||
|| Source Tables:  IEX_SCORE_HISTORIES
||
|| Target Tables:  NA
||
|| Creation date:       04/22/2003 4:03PM
||
|| Major Modifications: when               who                      what
||                      04/22/2003 4:03PM  raverma               created
*/
function getScoreHistory (p_score_object_id    IN NUMBER,
                          p_score_object_code  IN VARCHAR2,
                          p_from_date          IN DATE default null,
                          p_to_date            IN DATE default null,
                          p_score_id           IN NUMBER default null) return IEX_SCORE_NEW_PVT.SCORE_HISTORY_TBL;


--
--- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
--
/*
|| Overview:    Stores the score history given a table of records
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:       11/02/2004
||
|| Major Modifications: when               who                      what
||
*/
procedure storeScoreHistory ( p_score_id     IN NUMBER default null,
			      p_objects_tbl  IN IEX_SCORE_NEW_PVT.SCORE_OBJECTS_TBL,
			      p_scores_tbl   IN IEX_SCORE_NEW_PVT.NEW_SCORES_TBL) ;

/*
|| Overview:    Stores the score history given a table of records
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:       11/02/2004
||
|| Major Modifications: when               who                      what
||
*/
procedure storeDelBuffers ( p_score_id     IN NUMBER default null,
			      p_objects_tbl  IN IEX_SCORE_NEW_PVT.SCORE_OBJECTS_TBL,
			      p_scores_tbl   IN IEX_SCORE_NEW_PVT.NEW_SCORES_TBL,
			      p_bridge       IN NUMBER default null) ;

/*
|| Overview:    Scores 1 item and returns the value
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  None
||
|| Creation date:       11/03/2004
||
|| Major Modifications: when               who                      what
||
*/
function get1Score ( p_score_comp_tbl IN IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL, p_object_id IN NUMBER ) return NUMBER;

IEX_UNIVERSE_SIZE_ZERO_ERROR EXCEPTION;



END IEX_SCORE_NEW_PVT;


/
