--------------------------------------------------------
--  DDL for Package WSMPCNST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPCNST" AUTHID CURRENT_USER AS
/* $Header: WSMCNSTS.pls 115.15 2003/11/21 01:53:07 vjambhek ship $ */

---------- DATETIME FMT CONSTANTS ------------------------
C_DATETIME_FMT         CONSTANT VARCHAR2(22) := 'DD-MON-YYYY HH24:MI:SS';

---------- ROUNDING CONSTANTS ------------------------

NUMBER_OF_DECIMALS CONSTANT NUMBER := 6;

--------- WIP LOT TXNS TYPE ---------------------------

SPLIT                  CONSTANT  NUMBER  := 1;
MERGE                  CONSTANT  NUMBER  := 2;
UPDATE_ASSEMBLY        CONSTANT  NUMBER  := 3;
BONUS                  CONSTANT  NUMBER  := 4;
UPDATE_ROUTING         CONSTANT  NUMBER  := 5;
UPDATE_QUANTITY        CONSTANT  NUMBER  := 6;
UPDATE_LOT_NAME        CONSTANT  NUMBER  := 7;

------------------------------------------------------

FUTURE_OPERATIONS      CONSTANT  NUMBER  := 1;
PRIOR_OPERATIONS       CONSTANT  NUMBER  := 2;

------------------------------------------------------
COPY                   CONSTANT  NUMBER  := 1;

------------------------------------------------------
STARTING_FM_FWD        CONSTANT  NUMBER  := 4;

------------------------------------------------------

END WSMPCNST;

 

/
