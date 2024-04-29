--------------------------------------------------------
--  DDL for Package QLTTRAWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTTRAWB" AUTHID CURRENT_USER as
/* $Header: qlttrawb.pls 120.0.12010000.3 2009/06/16 07:31:38 pdube ship $ */

-- 1/23/96 - CREATED
-- Paul Mishkin

  -- Gapless Sequence Proj Start. rponnusa Thu Jul  3 04:27:55 PDT 2003
  TYPE NUM_TABLE IS TABLE OF NUMBER;

  G_PLAN_ID_TAB           NUM_TABLE;
  G_COLLECTION_ID_TAB     NUM_TABLE;
  G_OCCURRENCE_TAB        NUM_TABLE;
  G_TXN_HEADER_ID_TAB     NUM_TABLE;

  -- Gapless Sequence Proj End

  -- Bug 2548710. rponnusa Mon Nov 18 03:49:15 PST 2002
  TYPE CHAR50_TABLE IS TABLE OF VARCHAR2(50);

  G_SEQ_TAB1     CHAR50_TABLE;
  G_SEQ_TAB2     CHAR50_TABLE;
  G_SEQ_TAB3     CHAR50_TABLE;
  G_SEQ_TAB4     CHAR50_TABLE;
  G_SEQ_TAB5     CHAR50_TABLE;
  G_SEQ_TAB6     CHAR50_TABLE;
  G_SEQ_TAB7     CHAR50_TABLE;
  G_SEQ_TAB8     CHAR50_TABLE;
  G_SEQ_TAB9     CHAR50_TABLE;
  G_SEQ_TAB10    CHAR50_TABLE;
  G_SEQ_TAB11    CHAR50_TABLE;
  G_SEQ_TAB12    CHAR50_TABLE;
  G_SEQ_TAB13    CHAR50_TABLE;
  G_SEQ_TAB14    CHAR50_TABLE;
  G_SEQ_TAB15    CHAR50_TABLE;

  G_INIT_SEQ_TAB NUMBER := 1;
  G_ROW_COUNT    NUMBER := 0;

  -- Bug 3765678. Component Item is not getiing validated if
  -- dependent on item. Introducing a new global variable
  -- to store ITEM_ID so COMP_ITEM can be verified against it.
  -- saugupta Thu, 15 Jul 2004 23:46:39 -0700 PDT

  -- Bug 3807782. Component Item validation is failing for bulk
  -- insert. G_ITEM_ID is no more used in the new logic.
  -- Hence commenting it out.
  -- srhariha. Wed Aug  4 23:33:07 PDT 2004.
  -- G_ITEM_ID NUMBER := NULL;

  PROCEDURE INIT_SEQ_TABLE(p_count IN NUMBER);

/*
  --
  -- should be private
  --
  FUNCTION TRANSACTION_WORKER(X_GROUP_ID NUMBER,
                              X_VAL_FLAG NUMBER,
                              X_DEBUG VARCHAR2,
                              TYPE_OF_TXN NUMBER) RETURN BOOLEAN;
*/

  PROCEDURE WRAPPER (ERRBUF OUT NOCOPY VARCHAR2,
                     RETCODE OUT NOCOPY VARCHAR2,
                     ARGUMENT1 IN VARCHAR2,
                     ARGUMENT2 IN VARCHAR2,
                     ARGUMENT3 IN VARCHAR2,
                     ARGUMENT4 IN VARCHAR2,
                     ARGUMENT5 IN VARCHAR2,
                     ARGUMENT6 IN VARCHAR2,
                     ARGUMENT7 IN VARCHAR2,
                     ARGUMENT8 IN VARCHAR2
                     );

-- Bug 8586750.Fp for 8321226.Added these three procedures for code reusability.
-- pdube Mon Jun 15 23:07:13 PDT 2009
PROCEDURE CHILD_CONC_REQ_CALL(P_TXN_HEADER_ID NUMBER);
PROCEDURE INSERT_AUTO_HIST_CHILD (P_TYPE_OF_TXN IN NUMBER,
                                  P_PLAN_ID IN NUMBER,
                                  P_TXN_HEADER_ID IN NUMBER);
PROCEDURE UPDATE_DELETE_QRI(P_REQUEST_ID IN NUMBER,
                            P_USER_ID IN NUMBER,
                            P_LAST_UPDATE_LOGIN IN NUMBER,
                            P_PROGRAM_APPLICATION_ID IN NUMBER,
                            P_PROGRAM_ID IN NUMBER,
                            P_GROUP_ID IN NUMBER,
			    P_DEBUG IN VARCHAR2);

END QLTTRAWB;


/
