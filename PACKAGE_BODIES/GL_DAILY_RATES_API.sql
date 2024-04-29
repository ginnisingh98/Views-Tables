--------------------------------------------------------
--  DDL for Package Body GL_DAILY_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DAILY_RATES_API" AS
/* $Header: gludlrab.pls 120.1 2005/05/05 01:37:32 kvora noship $ */

  FUNCTION SUBMIT_CONC_REQUEST RETURN NUMBER IS

    req_id NUMBER :=0;

  BEGIN

   -- FND_PROFILE.put('USER_ID', '0' );
   --  FND_PROFILE.put('RESP_ID', '50553');
   -- FND_PROFILE.put('RESP_APPL_ID','101');

     IF (run_conc_req_flag = TRUE) THEN


          req_id := FND_REQUEST.submit_request (
                            'SQLGL','GLTTRC','','',FALSE,
                  		'D','',chr(0),
                                '','','','','','','',
                             	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','',
                            	'','','','','','','','','','');



           run_conc_req_flag :=  FALSE;

      END IF;
    return (req_id);
  END;

END Gl_Daily_Rates_API;

/
