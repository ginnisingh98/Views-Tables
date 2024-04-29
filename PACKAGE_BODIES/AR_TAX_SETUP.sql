--------------------------------------------------------
--  DDL for Package Body AR_TAX_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TAX_SETUP" AS
/* $Header: ARTXPROB.pls 115.2 2002/11/15 23:33:57 thwon ship $ */

-- PUBLIC PROCEDURES
-------------------------------------------------------------------
PROCEDURE GET
	(NAME		IN VARCHAR2,
         ORG_ID         IN NUMBER default null,
	 VAL		OUT NOCOPY VARCHAR2
	)
IS
l_active_profile 			VARCHAR2(80);
AR_INVALID_INTEROP_PROFILE	EXCEPTION;
BEGIN

	l_active_profile := NAME;


     IF UPPER(l_active_profile) = 'AR_CALCULATE_TAX_ON_CM'  THEN
        -- Tax: Calculate Tax on Credit Memos

--	    FND_PROFILE.GET(l_active_profile,VAL);
           val:=arp_global.sysparam.CALC_TAX_ON_CREDIT_MEMO_FLAG;
     else
        -- put exceptions
       RAISE AR_INVALID_INTEROP_PROFILE;
     END IF;
END GET;


-------------------------------------------------------------------
FUNCTION VALUE
	(NAME 		IN VARCHAR2,
         ORG_ID        IN NUMBER default null
	)
RETURN VARCHAR2
IS
AR_INVALID_INTEROP_PROFILE	EXCEPTION;
l_active_profile 			VARCHAR2(80);
l_profile_value				VARCHAR2(255);
BEGIN

	l_active_profile := NAME;

     IF UPPER(l_active_profile) = 'AR_CALCULATE_TAX_ON_CM'   THEN
        -- Tax: Calculate Tax on credit Memos

--	    l_profile_value := FND_PROFILE.VALUE(l_active_profile);
       l_profile_value :=arp_global.sysparam.CALC_TAX_ON_CREDIT_MEMO_FLAG;

     ELSE
        -- put exceptions
      RAISE AR_INVALID_INTEROP_PROFILE;

     END IF;

	RETURN(l_profile_value);
END VALUE;

BEGIN

    ARP_GLOBAL.INIT_GLOBAL;
    --initialze sysparam again


END AR_TAX_SETUP;

/
