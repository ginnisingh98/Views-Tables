--------------------------------------------------------
--  DDL for Package Body AR_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_SETUP" AS
/* $Header: ARXPROFB.pls 115.6 2002/11/15 04:21:59 anukumar noship $ */

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


     IF UPPER(l_active_profile) = 'AR_SHOW_BILLING_NUMBER'  THEN
     --AR: Show Billing Number
           --	FND_PROFILE.GET(l_active_profile,VAL);
            val:=arp_global.sysparam.SHOW_BILLING_NUMBER_FLAG;

      ELSIF UPPER(l_active_profile) = 'AR_CROSS_CURRENCY_RATE_TYPE'  THEN
     --AR: Cross Currency Rate Type
         val:=arp_global.sysparam.CROSS_CURRENCY_RATE_TYPE;
     --FND_PROFILE.GET(l_active_profile,VAL);

      ELSIF UPPER(l_active_profile) = 'AR_DOC_SEQ_GEN_LEVEL'  THEN
      -- FND_PROFILE.GET(l_active_profile,VAL);
       Val:=arp_global.sysparam.DOCUMENT_SEQ_GEN_LEVEL;

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

     IF UPPER(l_active_profile) = 'AR_SHOW_BILLING_NUMBER'  THEN
     --AR: Show Billing Number
	  --  l_profile_value := FND_PROFILE.VALUE(l_active_profile);
        l_profile_value:=arp_global.sysparam.SHOW_BILLING_NUMBER_FLAG ;

      ELSIF UPPER(l_active_profile) = 'AR_CROSS_CURRENCY_RATE_TYPE'  THEN
     --AR: Cross Currency Rate Type
        l_profile_value:=arp_global.sysparam.CROSS_CURRENCY_RATE_TYPE ;
	--l_profile_value := FND_PROFILE.VALUE(l_active_profile);

      ELSIF UPPER(l_active_profile) = 'AR_DOC_SEQ_GEN_LEVEL'  THEN
        l_profile_value:=arp_global.sysparam.DOCUMENT_SEQ_GEN_LEVEL;
	--   l_profile_value := FND_PROFILE.VALUE(l_active_profile);

     ELSE
        -- put exceptions
      RAISE AR_INVALID_INTEROP_PROFILE;

     END IF;

	RETURN(l_profile_value);
END VALUE;
BEGIN

    ARP_GLOBAL.INIT_GLOBAL;
    --initialze sysparam again

END AR_SETUP;

/
