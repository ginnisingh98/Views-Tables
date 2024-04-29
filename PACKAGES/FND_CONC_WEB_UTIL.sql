--------------------------------------------------------
--  DDL for Package FND_CONC_WEB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_WEB_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFCPINRS.pls 120.4 2005/09/26 06:04:50 susghosh noship $ */

  -- Name
  --   GET_REQUEST_STATUS_IMAGE
  -- Purpose
  --   This function returns the iconic image name for a request
  --   based on the phase code and status code of the request.
  -- Arguments (input)
  --   request_id - Request id for which the iconic image name has to be returned.
  -- Return Value
  --   Image name which represent the phase and status of the request.

  FUNCTION GET_REQUEST_STATUS_IMAGE(P_REQUEST_ID NUMBER) RETURN VARCHAR2;



  -- Name
  --   GET_REQUEST_DETAILS_URL
  -- Purpose
  --   This function returns the URL  parameters for the
  --   view request details page.
  -- Arguments (input)
  --   request_id - Request id for which URL  parameters has to be returned.
  -- Return Value
  --   URL  parameters required for viewing the request details.

  FUNCTION GET_REQUEST_DETAILS_URL(P_REQUEST_ID NUMBER) RETURN VARCHAR2;


  -- Name
  --   GET_REQUEST_STATUS_IMG_TIP
  -- Purpose
  --   This function returns the tool tip for the  request status image
  --   based on the phase code and status code of the request.
  -- Arguments (input)
  --   request_id - Request id for which the iconic image name has to be returned.
  -- Return Value
  --   Tool tip text which represent the phase and status of the request.

  FUNCTION GET_REQUEST_STATUS_IMG_TIP(P_REQUEST_ID NUMBER) RETURN VARCHAR2;

END FND_CONC_WEB_UTIL;

 

/
