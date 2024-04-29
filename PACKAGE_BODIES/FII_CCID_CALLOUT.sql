--------------------------------------------------------
--  DDL for Package Body FII_CCID_CALLOUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CCID_CALLOUT" AS
/* $Header: FIIGLUCB.pls 120.1 2005/10/30 05:13:38 appldev noship $ */
  g_debug_mode   VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');


-- *******************************************************************
-- Procedure UPDATE_FC.
-- *******************************************************************

   PROCEDURE UPDATE_FC (p_from_ccid	IN	NUMBER,
		        p_to_ccid	IN	NUMBER
		       )  IS

   BEGIN

	IF (g_debug_mode = 'Y') THEN
           FII_MESSAGE.Func_Ent ('FII_CCID_CALLOUT.UPDATE_FC');
        END IF;

        -- Print the values of the parameters
        IF (g_debug_mode = 'Y') THEN
           FII_UTIL.Write_Log('Value of p_from_ccid : '||p_from_ccid);
           FII_UTIL.Write_Log('Value of p_to_ccid : '||p_to_ccid);
        end if;

        -----------------------------------------------------------------
	-- At this place the customised code will be put in place of NULL
	-- This piece of code will update records with CCID between
	-- p_from_ccid and p_to_ccid
	-----------------------------------------------------------------

	NULL;

        IF (g_debug_mode = 'Y') THEN
           FII_MESSAGE.Func_Succ(func_name => 'FII_CCID_CALLOUT.UPDATE_FC');
        end if;

   Exception
     When others then
        FII_UTIL.Write_Log ('Unexpected error when calling UPDATE_FC...');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
	raise;


   END UPDATE_FC;

END FII_CCID_CALLOUT;

/
