--------------------------------------------------------
--  DDL for Package IEO_SUM_AVB_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SUM_AVB_RECORD" AUTHID CURRENT_USER AS
/* $Header: IEOSRECS.pls 115.9 2003/01/02 17:08:59 dolee ship $ */

------------------------------------------------------------------------------
--  Function    : TOTAL_RECORD_FOR_IEO_CAMP
--  Description : calculate the total number of available records for one
--				  specified  campaign plus service
--  Parameters  :
--	IN			: LIST_SRV_NAME_Value 		IN  VARCHAR2		Required
--				  Name of campaign plus service
--  Return      : NUMBER
--                      Returns total number of available records
------------------------------------------------------------------------------
FUNCTION TOTAL_RECORD_FOR_IEO_CAMP(LIST_SRV_NAME_Value	IN  VARCHAR2) RETURN NUMBER;

------------------------------------------------------------------------------
--  Function    : TOTAL_RECORD_FOR_AMS_CAMP
--  Description : calculate the total number of available records for one
--				  specified campaign ID
--  Parameters  :
--	IN			: CAMPAIGN_ID_Value	IN  NUMBER		Required
--				  campaign ID
--  Return      : NUMBER
--                      Returns total number of available records
------------------------------------------------------------------------------
FUNCTION TOTAL_RECORD_FOR_AMS_CAMP(CAMPAIGN_ID_Value	IN  NUMBER) RETURN NUMBER;

END IEO_SUM_AVB_RECORD;

 

/
