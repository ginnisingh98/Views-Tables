--------------------------------------------------------
--  DDL for Package Body MSC_ATP_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_REFRESH" AS
/* $Header: MSCATPRB.pls 120.0.12010000.1 2010/03/17 20:54:44 hulu noship $  */


procedure RefreshATPSnapshot (	userId IN NUMBER,
                     		respId IN NUMBER,
                     		appId IN NUMBER)
IS
l_request_id                    NUMBER;
BEGIN


	  --fnd_global.apps_initialize(1068,21634,724);

	  fnd_global.apps_initialize(userId,respId,appId);

          l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'MSC',
                                        'MSCREFMV',
                                        NULL,   -- description
                                        NULL,   -- start time
                                        FALSE,  -- sub request
                                        'MSC_ATP_PLAN_SN',
                                        724);
         Commit;

         dbms_output.put_line('ReqId = ' || l_request_id);

	 --return requestId  ;
EXCEPTION
   WHEN OTHERS THEN
             msc_util.msc_log ('Conc. program error : ' || sqlcode || ':' || sqlerrm);
	     --return -1;

   END;


END MSC_ATP_REFRESH;


/
