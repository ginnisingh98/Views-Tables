--------------------------------------------------------
--  DDL for Package WF_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_CACHE" AUTHID CURRENT_USER as
 /* $Header: WFCACHES.pls 120.2 2006/02/22 16:39:05 rwunderl ship $ */

/*======================================+
 |                                      |
 | Global Configuration Variables       |
 |                                      |
 +======================================+================================*/

 ErrorOnCollision       BOOLEAN := FALSE;

 MaxActivities             PLS_INTEGER  := 10000;
 MaxActivityAttrs          PLS_INTEGER  := 50000;
 MaxActivityAttrValues     PLS_INTEGER  := 50000;
 MaxItemAttributes         PLS_INTEGER  := 1000;
 MaxItemAttrValues         PLS_INTEGER  := 1000;
 MaxItemTypes              PLS_INTEGER  := 50;
 MaxProcessActivities      PLS_INTEGER  := 10000;
 MaxActivityTransitions    PLS_INTEGER  := 5000;
 MaxProcessStartActivities PLS_INTEGER := 10000;

 task_FAILED            CONSTANT PLS_INTEGER  := 1; -- WF_CACHE was not able to
                                                    -- complete the task.

 task_SUCCESS           CONSTANT PLS_INTEGER  := 0; -- WF_CACHE was able to
                                                    -- successfully complete
                                                    -- the task.

  TAB_Activities             CONSTANT PLS_INTEGER  := 1;
  TAB_ActivityAttributes     CONSTANT PLS_INTEGER  := 2;
  TAB_ActivityAttrValues     CONSTANT PLS_INTEGER  := 3;
  TAB_ItemAttributes         CONSTANT PLS_INTEGER  := 4;
  TAB_ItemTypes              CONSTANT PLS_INTEGER  := 5;
  TAB_ProcessActivities      CONSTANT PLS_INTEGER  := 6;
  TAB_NLSParameters          CONSTANT PLS_INTEGER  := 7;
  TAB_ItemAttrValues         CONSTANT PLS_INTEGER  := 8;
  TAB_ActivityTransitions    CONSTANT PLS_INTEGER  := 9;
  TAB_ProcessStartActivities CONSTANT PLS_INTEGER := 10;


/*======================================+
 |                                      |
 | PL/SQL Record and Table Types        |
 |                                      |
 +======================================+================================+
 | The meta-data stored in the design time tables are represented here   |
 | as records.  There is then a corresponding PL/SQL table of those      |
 | records.  The table type definition is used by the global cache.      |
 | The record definitions are used by consumers of the cache and are     |
 | passed and received to the accessor and manipulator apis.             |
 |                                                                       |
 +=======================================================================*/

/*============================+
 | WF_ACTIVITIES              |
 +============================*/

   TYPE ActivityREC IS RECORD (
                ITEM_TYPE         VARCHAR2(8),
                NAME              VARCHAR2(30),
                VERSION           NUMBER,
                TYPE              VARCHAR2(8),
                RERUN             VARCHAR2(8),
                EXPAND_ROLE       VARCHAR2(1),
                COST              NUMBER,
                ERROR_ITEM_TYPE   VARCHAR2(8),
                ERROR_PROCESS     VARCHAR2(30),
                FUNCTION          VARCHAR2(240),
                FUNCTION_TYPE     VARCHAR2(30),
                EVENT_NAME        VARCHAR2(240),
                MESSAGE           VARCHAR2(30),
                BEGIN_DATE        DATE,
                END_DATE          DATE,
                DIRECTION         VARCHAR2(30) );


   TYPE ActivityTAB IS TABLE OF ActivityREC index by binary_integer;


/*============================+
 | WF_ACTIVITY_ATTRIBUTES     |
 +============================*/

   TYPE ActivityAttributeREC IS RECORD (
            ACTIVITY_ITEM_TYPE    VARCHAR2(8),
            ACTIVITY_NAME         VARCHAR2(30),
            ACTIVITY_VERSION      NUMBER,
            NAME                  VARCHAR2(30),
            TYPE                  VARCHAR2(8),
            SUBTYPE               VARCHAR2(8),
            FORMAT                VARCHAR2(240) );

   TYPE ActivityAttributeTAB IS TABLE OF ActivityAttributeREC
        index by binary_integer;


/*============================+
 | WF_ACTIVITY_ATTR_VALUES    |
 +============================*/

   TYPE ActivityAttrValueREC IS RECORD (
            PROCESS_ACTIVITY_ID   NUMBER,
            NAME                  VARCHAR2(30),
            VALUE_TYPE            VARCHAR2(8),
            TEXT_VALUE            VARCHAR2(4000),
            NUMBER_VALUE          NUMBER,
            DATE_VALUE            DATE );

   TYPE ActivityAttrValueTAB IS TABLE OF ActivityAttrValueREC
        index by binary_integer;


/*============================+
 | WF_ACTIVITY_TRANSITIONS    |
 +============================*/

   TYPE ActivityTransitionREC IS RECORD (
            FROM_PROCESS_ACTIVITY NUMBER,
            RESULT_CODE           VARCHAR2(30),
            TO_PROCESS_ACTIVITY   NUMBER,
            PREV_LNK              NUMBER,
            NEXT_LNK              NUMBER );

   TYPE ActivityTransitionTAB IS TABLE OF ActivityTransitionREC
        index by binary_integer;


/*============================+
 | WF_ITEM_ATTRIBUTES         |
 +============================*/

   TYPE ItemAttributeREC IS RECORD (
            ITEM_TYPE             VARCHAR2(8),
            NAME                  VARCHAR2(30),
            TYPE                  VARCHAR2(8),
            SUBTYPE               VARCHAR2(8),
            FORMAT                VARCHAR2(240),
            TEXT_DEFAULT          VARCHAR2(4000),
            NUMBER_DEFAULT        NUMBER,
            DATE_DEFAULT          DATE);

    TYPE ItemAttributeTAB IS TABLE OF ItemAttributeREC
        index by binary_integer;

/*============================+
 | WF_ITEM_ATTRIBUTE_VALUES   |
 +============================*/

   TYPE ItemAttrValueREC IS RECORD (
            ITEM_TYPE             VARCHAR2(8),
            ITEM_KEY              VARCHAR2(240),
            NAME                  VARCHAR2(30),
            TEXT_VALUE            VARCHAR2(4000),
            NUMBER_VALUE          NUMBER,
            DATE_VALUE            DATE);

    TYPE ItemAttrValueTAB IS TABLE OF ItemAttrValueREC
        index by binary_integer;


/*============================+
 | WF_ITEM_TYPES              |
 +============================*/

   TYPE ItemTypeREC IS RECORD (
            NAME                  VARCHAR2(8),
            WF_SELECTOR           VARCHAR2(240) );

   TYPE ItemTypeTAB IS TABLE OF ItemTypeREC index by binary_integer;


/*============================+
 | WF_PROCESS_ACTIVITIES      |
 +============================*/

   TYPE ProcessActivityREC IS RECORD (
                PROCESS_ITEM_TYPE   VARCHAR2(8),
                PROCESS_NAME        VARCHAR2(30),
                PROCESS_VERSION     NUMBER,
                ACTIVITY_ITEM_TYPE  VARCHAR2(8),
                ACTIVITY_NAME       VARCHAR2(30),
                INSTANCE_ID         NUMBER,
                INSTANCE_LABEL      VARCHAR2(30),
                PERFORM_ROLE        VARCHAR2(320),
                PERFORM_ROLE_TYPE   VARCHAR2(8),
                START_END           VARCHAR2(8),
                DEFAULT_RESULT      VARCHAR2(30) );

   TYPE ProcessActivityTAB IS TABLE OF ProcessActivityREC
        index by binary_integer;

/*============================+
 | NLSParameters              | Runtime cache of NLS parameters.
 +============================*/

   TYPE NLSParameterREC IS RECORD (
               PARAMETER            VARCHAR2(64),
               VALUE                VARCHAR2(64));

   TYPE NLSParameterTAB IS TABLE OF NLSParameterREC
        index by binary_integer;


/*============================+
 | ProcessStartActivities     |
 +============================*/
   TYPE ProcessStartActivityREC IS RECORD (
                INSTANCE_ID         NUMBER,
                PROCESS_ITEM_TYPE   VARCHAR2(8),
                PROCESS_NAME        VARCHAR2(30),
                PROCESS_VERSION     NUMBER,
                PREV_LNK            NUMBER,
                NEXT_LNK            NUMBER );

   TYPE ProcessStartActivityTAB IS TABLE OF ProcessStartActivityREC
        index by binary_integer;


/*======================================+
 |                                      |
 | Global Cache Tables                  |
 |                                      |
 +======================================+================================*/

  Activities             ActivityTAB;
  ActivityAttributes     ActivityAttributeTAB;
  ActivityAttrValues     ActivityAttrValueTAB;
  ActivityTransitions    ActivityTransitionTAB;
  ItemAttributes         ItemAttributeTAB;
  ItemTypes              ItemTypeTAB;
  ProcessActivities      ProcessActivityTAB;
  NLSParameters          NLSParameterTAB;
  ItemAttrValues         ItemAttrValueTAB;
  ProcessStartActivities ProcessStartActivityTAB;


/*======================================+
 |                                      |
 | Functions                            |
 |                                      |
 +======================================+================================*/


/*===========================+
 | SetHashRange              |
 +===========================+===================+
 | IN:      p_HashBase in NUMBER,                |
 |          p_HashSize in NUMBER                 |
 +===============================================*/

  PROCEDURE SetHashRange ( p_HashBase in  NUMBER,
                           p_HashSize in  NUMBER );


/*===========================+
 | HashKey                   |
 +===========================+===================+
 | IN:      p_HashString in VARCHAR2             |
 +-----------------------------------------------+
 | RETURNS: number                               |
 +===============================================*/

  FUNCTION HashKey (p_HashString in varchar2) return number;


/*=====================================+
 |                                     |
 | Maintenance Procedures              |
 |                                     |
 +=====================================+================================+
 | Maintenance procedures perform administrative functions such as      |
 | clearing, initializing, and managing the cache.                      |
 |                                                                      |
 +======================================================================*/

/*===========================+
 | Clear                     |
 +===============================================*/
   PROCEDURE Clear;


/*===========================+
 | CacheManager              |
 +===========================+===================+
 | IN: p_TableName    (PLS_INTEGER)              |
 |                                               |
 +===============================================*/

   PROCEDURE CacheManager (TableName in  PLS_INTEGER,
                           NumRows   in  NUMBER default 0);


/*===========================+
 | MetaRefreshed             |
 +===========================+===================+
 | Returns                                       |
 |   BOOLEAN                                     |
 +-----------------------------------------------+
 |  This api checks to see if the p_itemType     |
 |  has been updated by wfload.                  |
 +===============================================*/

   FUNCTION MetaRefreshed return BOOLEAN;


/*===========================+
 | Reset                     |
 +===========================+===================+
 | This api will update the WFCACHE_META_UPD     |
 | resource token to the current sysdate to      |
 | cause any running caches to be cleared        |
 +===============================================*/

   PROCEDURE Reset;




/*=====================================+
 |                                     |
 | Accessor Procedures                 |
 |                                     |
 +=====================================+================================+
 | Accessor procedures are the apis that consumers use to access meta-  |
 | data from cache.  Each api will require as parameters the necessary  |
 | information to locate the record in cache as well as a record index. |
 |                                                                      |
 +======================================================================*/



/*===========================+
 | GetActivity               |
 +===========================+===================+
 | IN:   itemType     (VARCHAR2)                 |
 |       name         (VARCHAR2)                 |
 |       actdate      (DATE)                     |
 +-----------------------------------------------+
 | OUT:  status     (PLS_INTEGER)                |
 |       waIND      (NUMBER)                     |
 +===============================================*/

   PROCEDURE GetActivity ( itemType in             VARCHAR2,
                           name     in             VARCHAR2,
                           actdate  in             DATE,
                           status   out    NOCOPY  PLS_INTEGER,
                           waIND    out    NOCOPY  NUMBER);


/*===========================+
 | GetActivityAttr           |
 +===========================+===================+
 | IN:   itemType   (VARCHAR2)                   |
 |       name       (VARCHAR2)                   |
 |       actid      (NUMBER)                     |
 |       actdate    (DATE)                       |
 +-----------------------------------------------+
 | OUT:  status     (PLS_INTEGER)                |
 |       wa_index   (NUMBER)                     |
 |       waa_index  (NUMBER)                     |
 +===============================================*/

   PROCEDURE GetActivityAttr ( itemType  in             VARCHAR2,
                               name      in             VARCHAR2,
                               actid     in             NUMBER,
                               actdate   in             DATE,
                               status    out    NOCOPY  PLS_INTEGER,
                               wa_index  out    NOCOPY  NUMBER,
                               waa_index out    NOCOPY  NUMBER);



/*===========================+
 | GetActivityAttrValue      |
 +===========================+===================+
 | IN:   actID           (NUMBER)                |
 |       name            (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status          (PLS_INTEGER)           |
 |       waavIND         (NUMBER)                |
 +===============================================*/

   PROCEDURE GetActivityAttrValue (
                                  actid   in            NUMBER,
                                  name    in            VARCHAR2,
                                  status  out    NOCOPY PLS_INTEGER,
                                  waavIND out    NOCOPY NUMBER );


/*===========================+
 | GetActivityTransitions    |
 +===========================+===================+
 | IN:   FromActID       (NUMBER)                |
 |       result          (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status          (PLS_INTEGER)           |
 |       watIND          (NUMBER)                |
 +===============================================*/

   PROCEDURE GetActivityTransitions (
                                FromActID in            NUMBER,
                                result    in            VARCHAR2,
                                status    out    NOCOPY PLS_INTEGER,
                                watIND    out    NOCOPY NUMBER );


/*===========================+
 | GetItemAttribute          |
 +===========================+===================+
 | IN:   itemType         (VARCHAR2)             |
 |       name             (VARCHAR2)             |
 +-----------------------------------------------+
 | OUT:  status           (PLS_INTEGER)          |
 |       wiaIND           (NUMBER)               |
 +===============================================*/

   PROCEDURE GetItemAttribute (itemType in              VARCHAR2,
                               name     in              VARCHAR2,
                               status   out    NOCOPY   PLS_INTEGER,
                               wiaIND   out    NOCOPY   NUMBER);


/*===========================+
 | GetItemAttrValue          |
 +===========================+===================+
 | IN:   itemType         (VARCHAR2)             |
 |       itemKey          (VARCHAR2)             |
 |       name             (VARCHAR2)             |
 +-----------------------------------------------+
 | OUT:  status           (PLS_INTEGER)          |
 |       wiavIND          (NUMBER)               |
 +===============================================*/

   PROCEDURE GetItemAttrValue (itemType in              VARCHAR2,
                               itemKey  in              VARCHAR2,
                               name     in              VARCHAR2,
                               status   out    NOCOPY   PLS_INTEGER,
                               wiavIND  out    NOCOPY   NUMBER);


/*===========================+
 | GetItemType               |
 +===========================+===================+
 | IN:   itemType        (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status      (PLS_INTEGER)               |
 |       witIND      (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetItemType (itemType in             VARCHAR2,
                          status   out    NOCOPY  PLS_INTEGER,
                          witIND   out    NOCOPY  NUMBER);



/*===========================+
 | GetProcessActivity        |
 +===========================+===================+
 | IN:   actid         (NUMBER)                  |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 +===============================================*/

   PROCEDURE GetProcessActivity (actid  in            NUMBER,
                                 status out    NOCOPY PLS_INTEGER);


/*===========================+
 | GetProcessActivityInfo    |
 +===========================+===================+
 | IN:   actid         (NUMBER)                  |
 |       actdate       (DATE)                    |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 |          waIND    (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetProcessActivityInfo (actid   in            NUMBER,
                                     actdate in            DATE,
                                     status  out    NOCOPY PLS_INTEGER,
                                     waIND   out    NOCOPY NUMBER);


/*===========================+
 | GetNLSParameter           |
 +===========================+===================+
 | IN:   Parameter   (VARCHAR2)                  |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 |          nlsIND   (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetNLSParameter (Parameter  in            VARCHAR2,
                              status     out    NOCOPY PLS_INTEGER,
                              nlsIND     out    NOCOPY NUMBER);


/*===========================+
 | GetProcessStartActivities |
 +===========================+===================+
 | IN:      itemType (VARCHAR2)                  |
 |          name     (VARCHAR2)                  |
 |          version  (NUMBER)                    |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 |          psaIND   (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetProcessStartActivities (itemType  in            VARCHAR2,
                                        name      in            VARCHAR2,
                                        version   in            NUMBER,
                                        status    out    NOCOPY PLS_INTEGER,
                                        psaIND    out    NOCOPY NUMBER);

--
-- BeginTransaction
-- (PRIVATE)
--  Begins a trusted session where calls to Reset() will not have any effect.
--  Caller has to call EndTransaction() immediately before issuing commit.
--  Returns FALSE if transaction was already begun by a parent call.
   FUNCTION BeginTransaction return BOOLEAN;

--
-- EndTransaction
-- (PRIVATE)
-- Signals the end of a trusted session and calls Reset() to lock and update
-- WFCACHE_META_UPD.
--
   FUNCTION EndTransaction return BOOLEAN;

end WF_CACHE;


 

/
