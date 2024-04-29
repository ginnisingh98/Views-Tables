--------------------------------------------------------
--  DDL for Package Body FND_CONC_WEB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_WEB_UTIL" AS
/* $Header: AFCPINRB.pls 120.8 2006/01/11 22:23:42 ddhulla noship $ */

  --Package global variables to hold the request_id
  --and Tool Tip text
  TOOL_TIP_TEXT  VARCHAR2(2000) := '';
  REQUEST_ID     NUMBER  := -1;

  -- Name
  --   GET_REQUEST_STATUS_IMAGE
  -- Purpose
  --   This function returns the iconic image name for a request
  --   based on the phase code and status code of the request.
  -- Arguments (input)
  --   request_id - Request id for which the iconic image name has to be returned.
  -- Return Value
  --   Image name which represent the phase and status of the request.

  FUNCTION GET_REQUEST_STATUS_IMAGE(P_REQUEST_ID NUMBER) RETURN VARCHAR2 AS

       l_request_id          number;
       l_phase               varchar2(400);
       l_status              varchar2(400);
       l_dev_status          varchar2(400);
       l_dev_phase           varchar2(400);
       l_message             varchar2(4000);

       l_image_name      varchar2(4000);
       l_result         boolean;

       v_running_processes	number;

  BEGIN

    --Storing the requestid in the package global variable.
    --It will be accessed from GET_REQUEST_STATUS_IMG_TIP function.
    REQUEST_ID := P_REQUEST_ID;

    l_image_name := '';
    l_request_id := P_REQUEST_ID;

    -- To get the request's pahse and status
    l_result := FND_CONCURRENT.GET_REQUEST_STATUS(
                                REQUEST_ID => l_request_id,
                                PHASE      => l_phase,
                                STATUS     => l_status,
                                DEV_PHASE  => l_dev_phase,
                                DEV_STATUS => l_dev_status,
                                MESSAGE    => l_message) ;


     TOOL_TIP_TEXT := l_status;

     --bug4598673
     --obtain manager status to detect manager-not-running condition
     --if manager is not running, we have to force no_manager condition
     --when the status is pending/normal
     --bug4923725
     --modified the query as there could be zero or more than 1 rows of managers
     --as the request could be waiting in multiple managers queue


     select nvl(sum(running_processes),0) into v_running_processes from fnd_concurrent_worker_requests where
     (CONTROL_CODE not in ('D', 'T', 'E', 'X', 'R', 'N') OR CONTROL_CODE is NULL)
     and request_id=P_REQUEST_ID;

     IF (l_dev_phase = 'PENDING') THEN

           IF ((l_dev_status = 'NORMAL') OR (l_dev_status = 'STANDBY') OR (l_dev_status = 'WAITING')) THEN
             IF v_running_processes = 0 THEN
                l_image_name := 'erroricon_active.gif';
             ELSE
                l_image_name := 'notstartedind_active.gif';
             END IF;
           ELSIF (l_dev_status = 'SCHEDULED')  THEN
             l_image_name := 'scheduled_active.gif';
           END IF;

     ELSIF (l_dev_phase = 'RUNNING') THEN

           IF ((l_dev_status = 'NORMAL') OR (l_dev_status = 'PAUSED') OR (l_dev_status = 'RESUMING')) THEN
             l_image_name := 'inprogressind_active.gif';
           ELSIF (l_dev_status = 'TERMINATING') THEN
             l_image_name := 'cancelind_active.gif';
           END IF;

     ELSIF (l_dev_phase = 'COMPLETE') THEN

           IF (l_dev_status = 'NORMAL') THEN
             l_image_name := 'completeind_active.gif';
           ELSIF (l_dev_status = 'ERROR') THEN
             l_image_name := 'erroricon_active.gif';
           ELSIF (l_dev_status = 'WARNING') THEN
             l_image_name := 'warningicon_status.gif';
           ELSIF ((l_dev_status = 'DELETED') OR (l_dev_status = 'TERMINATED')) THEN
	   --Here there are 2 deviation from Original Specification.
	   --Cancelled cahnged to DELETED and Terminating changed to TERMINATED
	   --Cancelled-  DELETED | Terminating - TERMINATED
             l_image_name := 'cancelind_active.gif';
           END IF;

     ELSIF (l_dev_phase = 'INACTIVE') THEN

           IF ((l_dev_status = 'DISABLED') OR (l_dev_status = 'NO_MANAGER')) THEN
             l_image_name := 'erroricon_active.gif';
           ELSIF (l_dev_status = 'ON_HOLD')  THEN
             l_image_name := 'onholdind_active.gif';
           END IF;

     END IF;

    RETURN l_image_name;
  END;



  -- Name
  --   GET_REQUEST_DETAILS_URL
  -- Purpose
  --   This function returns the URL  parameters for the
  --   view request details page.
  -- Arguments (input)
  --   request_id - Request id for which URL  parameters has to be returned.
  -- Return Value
  --   URL  parameters required for viewing the request details.

  FUNCTION GET_REQUEST_DETAILS_URL(P_REQUEST_ID NUMBER) RETURN VARCHAR2 AS

	l_url		varchar2(4000);
	l_request_id    number;
	l_phase         varchar2(400);
	l_status        varchar2(400);
	l_dev_status    varchar2(400);
	l_dev_phase     varchar2(400);
	l_message       varchar2(4000);
	l_result	boolean;

  BEGIN

    l_request_id := P_REQUEST_ID;

    if(nvl(l_request_id,0)=0) then
	return null;
    end if;

    l_result := FND_CONCURRENT.GET_REQUEST_STATUS(
                                REQUEST_ID => l_request_id,
                                PHASE      => l_phase,
                                STATUS     => l_status,
                                DEV_PHASE  => l_dev_phase,
                                DEV_STATUS => l_dev_status,
                                MESSAGE    => l_message) ;

    IF (l_result = FALSE) THEN
	return null;
    END IF;

    l_url := 'akRegionCode=FNDCPREQDETAILSTOPREGION'
             || '&' || 'akRegionApplicationId=0'
             || '&' || 'REQUESTID='|| TO_CHAR(P_REQUEST_ID)
	     || '&' || 'retainAM=Y'
	     || '&' || 'addBreadCrumb=Y';


    RETURN l_url;

  END;



  -- Name
  --   GET_REQUEST_STATUS_IMG_TIP
  -- Purpose
  --   This function returns the tool tip for the  request status image
  --   based on the phase code and status code of the request.
  -- Arguments (input)
  --   request_id - Request id for which the iconic image name has to be returned.
  -- Return Value
  --   Tool tip text which represent the phase and status of the request.

  FUNCTION GET_REQUEST_STATUS_IMG_TIP(P_REQUEST_ID NUMBER) RETURN VARCHAR2 AS

      l_img_name varchar2(4000);

  BEGIN

      IF (REQUEST_ID <> P_REQUEST_ID) THEN
        l_img_name := GET_REQUEST_STATUS_IMAGE(P_REQUEST_ID);
      END IF;

      return TOOL_TIP_TEXT;

  END;


END FND_CONC_WEB_UTIL;

/
