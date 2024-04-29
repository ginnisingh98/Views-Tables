--------------------------------------------------------
--  DDL for Package Body INV_MGD_PURGE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_PURGE_CP" AS
/*  $Header: INVCPURB.pls 120.1 2005/06/21 06:20:16 appldev ship $ */
-- +======================================================================+
-- |             Copyright (c) 2001 Oracle Corporation                    |
-- |                     Redwood Shores, CA, USA                          |
-- |                       All rights reserved.                           |
-- +======================================================================+
-- | FILENAME                                                             |
-- |   INVCPURB.pls                                                       |
-- |                                                                      |
-- | DESCRIPTION                                                          |
-- |                                                                      |
-- |                                                                      |
-- | PROCEDURE LIST                                                       |
-- |     Purge                                                            |
-- |                                                                      |
-- | HISTORY                                                              |
-- |   08/28/00 vjavli          Created                                   |
-- |   12/11/00 vjavli          signature updated to p_org_hier_origin_id |
-- |                                                                      |
-- |   08/08/2001 vjavli        bug#1919163 fix request limit issue       |
-- |   08/14/2001 vjavli        bug#1936118 status should change to       |
-- |                            COMPLETE only after all the purge         |
-- |                              requested completed                     |
-- |   11/14/2001 vjavli        Updated with Get_Organization_List        |
-- |                            Performance enhancement                   |
-- |   11/26/2001 vjavli        p_include_origin flag set to 'Y'          |
-- |   11/21/2002 vma           Performance: modify code to print to log  |
-- |                            only if debug profile option is enabled   |
-- |   11/24/2002 tsimmond      UTF8: changed l_org_name to  VARCHAR2(240)|
-- |   01/07/2004 nkilleda      Changed program to invoke INVTMLPR conc.  |
-- |                             pgm instead of the PRO*C INCTPG. The     |
-- |                             PRO*C program is obsoleted from 11.5.9   |
-- |                             a)Commented cursor for getting org name  |
-- |                               as org name is passed only as desc and |
-- |                               is not a mandatory parameter.          |
-- |                             b)Corrected the Sleep logic. DBMS_SLEEP  |
-- |                               was being called after checking each   |
-- |                               request's status, however it should be |
-- |                               called after checking status for all   |
-- |                               requests.                              |
-- +======================================================================+

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_PURGE_CP';
g_log_level            NUMBER       := NULL;
g_log_mode             VARCHAR2(3)  := 'OFF'; -- possible values: OFF,SQL,SRS
G_DEBUG                VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--==================
-- PRIVATE PROCEDURES AND FUNCTIONS
--==================

--========================================================================
-- FUNCTION  : Has_Worker_Completed    PRIVATE
-- PARAMETERS: p_request_id            IN  NUMBER
-- RETURNS   : BOOLEAN
-- COMMENT   : Accepts a request ID. TRUE if the corresponding worker
--             has completed; FALSE otherwise
--=========================================================================
FUNCTION Has_Worker_Completed
( p_request_id  IN NUMBER
)
RETURN BOOLEAN
IS
  l_count   NUMBER;
  l_result  BOOLEAN;
BEGIN

  SELECT  COUNT(*)
    INTO  l_count
    FROM  fnd_concurrent_requests
    WHERE request_id = p_request_id
      AND phase_code = 'C';

  IF l_count = 1 THEN
    l_result := TRUE;
  ELSE
    l_result := FALSE;
  END IF;


  RETURN l_result;

END Has_Worker_Completed;

--=======================
-- GLOBAL PROCEDURES
--=======================

--========================================================================
-- PROCEDURE : Purge                   PUBLIC
-- PARAMETERS: x_retcode               return status
--             x_errbuff               return error message
--             p_org_hier_origin_id     IN NUMBER  Organization Hierarchy
--                                                Origin Id
--             p_org_hierarchy_id	IN Organization Hierarchy Id
--             p_purge_date		IN Purge Date
--             p_purge_name             IN Purge Name
--             p_request_limit          IN Number of request limit
--
--
-- COMMENT   : This is a wrapper procedure invokes core transaction purge
--             program repetitively for each organization in the organization
--             hierarchy origin list.  The procedure purges the transactions
--             across organizations
-- Updated:    Get_Organization_list included
--=========================================================================
PROCEDURE Purge(x_retcode               OUT	NOCOPY VARCHAR2,
		x_errbuff               OUT	NOCOPY VARCHAR2,
                p_org_hier_origin_id	IN	NUMBER,
   		p_org_hierarchy_id	IN	NUMBER,
		p_purge_date		IN	VARCHAR2,
		p_purge_name		IN	VARCHAR2,
                p_request_limit         IN      NUMBER)
IS

l_org_code_list INV_ORGHIERARCHY_PVT.OrgID_tbl_type;

l_orgid		hr_organization_units.organization_id%TYPE;
l_org_name      VARCHAR2(240) := NULL;
l_purge_req_id  NUMBER;
l_errorcode	NUMBER;
l_errortext	VARCHAR2(200);
l_return_status BOOLEAN;
l_req_status    BOOLEAN;
l_req_id        NUMBER;
l_req_num  NUMBER;
l_req_ind     BINARY_INTEGER;
l_status_ind  BINARY_INTEGER;
l_index       BINARY_INTEGER;
l_sleep_time  NUMBER := 5;
l_all_req_status BOOLEAN;

-- cursor to print the organization name
-- commented as it org_name is not a required parameter
-- while fixing bug 3326234
--
--CURSOR c_org_name(c_org_id NUMBER) IS
--SELECT ORGANIZATION_NAME
--FROM   ORG_ORGANIZATION_DEFINITIONS
--WHERE  ORGANIZATION_ID = c_org_id;

TYPE  l_reqstatus_table  IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
l_reqstatus_tbl_type   l_reqstatus_table;

submission_error_except 	EXCEPTION;
set_options_except              EXCEPTION;


BEGIN

-- initialize log
   INV_ORGHIERARCHY_PVT.Log_Initialize;

-- initialize the message stack
   FND_MSG_PUB.Initialize;

	INV_ORGHIERARCHY_PVT.Get_Organization_List(p_org_hierarchy_id,
	                                           p_org_hier_origin_id,
		                                   l_org_code_list,
                                                   'Y');

-- initialize request serial numbers
l_req_num  := 1;
l_req_ind  := 1;

l_index := l_org_code_list.LAST;

WHILE (l_index >= l_org_code_list.FIRST ) LOOP

  l_orgid := l_org_code_list(l_index);

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,'Organization Id: '|| to_char(l_orgid));
  END IF;

  -- check whether the request being submitted lies within the request limit
  IF (l_req_num  <=  p_request_limit)  THEN

     -- Set request options so that request not to be viewed on the end-user
     -- concurrent request form unless the request completes with a
     -- warning or an error
     l_return_status := FND_REQUEST.SET_OPTIONS(
                                   implicit => 'WARNING',
                                   protected => 'NO');

        IF (l_return_status ) THEN

        -- print organization name
        --   OPEN c_org_name(l_orgid);
        --   FETCH c_org_name
        --   INTO  l_org_name;
        --   IF (c_org_name%NOTFOUND AND G_DEBUG = 'Y') THEN
        --     INV_ORGHIERARCHY_PVT.Log
        --	    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	--          ,'Inventory Organization Name not found for'
        --      || to_char(l_orgid)
        --      );
        --   END IF;
        --   CLOSE c_org_name;

            l_purge_req_id := FND_REQUEST.SUBMIT_REQUEST(
                                application =>'INV',
                                program     =>'INVTMLPR',
                                argument1   => p_purge_date,
		                argument2   => l_orgid,
		                argument3   => p_purge_name);

            IF (l_purge_req_id = 0) THEN
              -- Handle submission error --
              RAISE submission_error_except;
            ELSE
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
    	          (INV_ORGHIERARCHY_PVT.G_LOG_EVENT
    	           ,'Request Id:' || to_char(l_purge_req_id) ||
                  ' Organization Id:'|| to_char(l_orgid) ||
                  ' Name:' || l_org_name ||
                  ' ' || 'Transaction Purge Submitted'
                );
              END IF;
	          commit;
	     END IF;
         ELSE
          -- handle set options error
          RAISE set_options_except;
         END IF;

      l_reqstatus_tbl_type(l_req_ind)  :=  l_purge_req_id;
      l_req_ind := l_req_ind + 1;
      l_req_num := l_req_num + 1;
      l_index   := l_index - 1; -- reduce the index to obtain previous organization id

  ELSE
   -- Wait until completion of any one of the submitted request.
   -- If one of the request completes, exit to submit new request
   -- for the next organization

       -- initialize check status number
       l_status_ind := 1;
       LOOP
          IF (l_status_ind > p_request_limit)  THEN
             -- sleep for l_sleep_time if all req.
             -- are running.
             DBMS_LOCK.sleep(l_sleep_time);

             -- reset the status number
             l_status_ind  := 1;
          END IF;

          --- Check the request status of the submitted requests
          l_req_id  := l_reqstatus_tbl_type(l_status_ind);
          l_req_status := INV_MGD_PURGE_CP.Has_Worker_Completed(l_req_id);

          IF (l_req_status )  THEN
          -- Assign the request id index to the completed request status num
          -- reduce the request number by 1 since one request completed

            l_req_ind  := l_status_ind;
            l_req_num := l_req_num - 1;


            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
  	        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	         ,'Request id:' || to_char(l_req_id) || ' Request Status: Completed'
              );
            END IF;

            EXIT;
          END IF;
          l_status_ind := l_status_ind + 1;

       END LOOP;  -- Wait status loop

  END IF; -- request within the limit


END LOOP;  -- organization list loop

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_EVENT
       ,'All the purge requests submitted successfully'
       );
  END IF;

-- Return Success only after all the submitted purge requests
-- got completed
l_all_req_status := FALSE;
WHILE (NOT l_all_req_status) LOOP
  FOR idx IN 1 .. l_reqstatus_tbl_type.COUNT LOOP
      l_req_id  := l_reqstatus_tbl_type(idx);
      l_all_req_status := INV_MGD_PURGE_CP.Has_Worker_Completed(l_req_id);
    IF (NOT l_all_req_status) THEN
      EXIT;
    END IF;

  END LOOP; -- end for loop

  DBMS_LOCK.sleep(l_sleep_time);
END LOOP; -- end while

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , 'All the purge requests completed'
    );
  END IF;

  -- SRS success
      x_errbuff := NULL;
      x_retcode := RETCODE_SUCCESS;

EXCEPTION
	WHEN submission_error_except THEN
  	l_errorcode := SQLCODE;
	  l_errortext := SUBSTR(SQLERRM,1,200);

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
   	  (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
    	 ,'submission error'
      );
      INV_ORGHIERARCHY_PVT.Log
    	(INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
  	   ,to_char(l_errorcode) || l_errortext
      );
    END IF;
  	x_retcode := RETCODE_ERROR;
  	x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);

  WHEN set_options_except THEN
	  l_errorcode := SQLCODE;
  	l_errortext := SUBSTR(SQLERRM,1,200);

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
    	 (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
    	  ,'set options error'
       );
      INV_ORGHIERARCHY_PVT.Log
    	 (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
  	   ,to_char(l_errorcode) || l_errortext
       );
    END IF;
  	x_retcode := RETCODE_ERROR;
	  x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Purge');
    END IF;
    x_retcode := RETCODE_ERROR;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);

END Purge;

END INV_MGD_PURGE_CP;

/
