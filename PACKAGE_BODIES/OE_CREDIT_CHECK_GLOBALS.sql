--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_GLOBALS" AS
-- $Header: OEXGCRCB.pls 120.0 2005/05/31 22:42:16 appldev noship $


---------------------------
------- CONSTANTS
---------------------------
  G_PKG_NAME CONSTANT VARCHAR2(30) :=  'OE_Credit_Check_globals' ;

--------------------
-- TYPE DECLARATIONS
--------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
-----------------------------------------------------------------------------
--  FUNCTION: GET_MCC_project_version
--  COMMENT    : Returns the G_MCC_project_version
--
------------------------------------------------------------------------------
FUNCTION GET_MCC_project_version
RETURN NUMBER
IS

l_version NUMBER := 0 ;

BEGIN

  OE_DEBUG_PUB.ADD('IN OEXGCRCB: GET_MCC_project_version ');

  l_version := NVL(OE_Credit_Check_globals.G_MCC_project_version,0);

  OE_DEBUG_PUB.ADD('Return l_version => ' || l_version );

  RETURN ( l_version );

EXCEPTION
WHEN OTHERS THEN
    OE_DEBUG_PUB.ADD('ERROR= '|| SUBSTRB(sqlerrm,1,200));

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_MCC_project_version'
      );
    END IF;
    RAISE;
END GET_MCC_project_version ;


END OE_Credit_Check_globals;

/
