--------------------------------------------------------
--  DDL for Package FND_SYSTEM_ALERT_INTG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SYSTEM_ALERT_INTG_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFOAMSAINGS.pls 120.0 2005/08/31 22:05:09 appldev noship $ */


  /**
    *  This function will return the System alert exception in XML format.
    *  param p_event_name in - Workflow Business Event Name
    *  param p_event_key  in - Workflow Business Event Key
    *  param wf_parameter_list_t  in - Event parameter List
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  function GET_EXCPETION_DETAILS(p_event_name in varchar2
           , p_event_key in varchar2
           , p_parameter_list in wf_parameter_list_t default null) return clob;


  /**
    * For Testing all API's
    **/
-- procedure TEST;


 END FND_SYSTEM_ALERT_INTG_UTIL;

 

/
