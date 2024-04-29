--------------------------------------------------------
--  DDL for Package FND_APPS_MODE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APPS_MODE_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFOAMAPMDS.pls 115.1 2004/09/02 19:26:22 rmohan noship $ */

---Common Constants
MAINTENANCE_MODE CONSTANT VARCHAR2(20) := 'MAINT';
NORMAL_MODE CONSTANT VARCHAR2(20) := 'NORMAL';
FUZZY_MODE CONSTANT VARCHAR2(20) := 'FUZZY';
DISABLEDL_MODE CONSTANT VARCHAR2(20) := 'DISABLED';


  /**
    * This function will return true if Application System is in Maintenance Mode
    * else false
    **/
  function  IS_IN_MAINTENANCE_MODE   return boolean;


   /**
    * This function will return true if Application System is in Normal Mode
    * else false.
    **/
  function  IS_IN_NORMAL_MODE   return boolean;


  /**
    * This function will return current mode of the Application System.
    **/
  function  GET_CURRENT_MODE   return varchar2;


  /**
    *  It will set the Application System in Normal Mode.
    *  param retcode out type - values 0, 1
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_TO_NORMAL_MODE(retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2);


  /**
    *  It will set the Application System in Maintenance Mode.
    *  param retcode out type - values 0, 1
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_TO_MAINTENANCE_MODE(retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2);


  /**
    * Do not use this API because this APIS is for internal fnd usage
    * to accmodate following cases during patching.
    *     If Instance doesn't have APPS_MAINTENANCE_MODE profile option
    *  still we want to disable the workflow event.
    *     If profile option exist it will be set to MAINT.
    *
    *     It will set the Application System in Maintenance Mode.
    *  param retcode out type - values 0, 1.
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_MAINT_MODE_PATCH_MP11510(retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2);

  /**
    * Do not use this API because this APIS is for internal fnd usage
    * to accmodate following cases during patching.
    *     If Instance doesn't have APPS_MAINTENANCE_MODE profile option
    *  still we want to enable the workflow event.
    *     If profile option exist it will be set to NORMAL.
    *
    *  It will set the Application System in Normal Mode.
    *  param retcode out type - values 0, 1.
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_NORMAL_MODE_PATCH_MP11510(retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2);



  /**
    * For Testing all API's
    * After testing it will put the Apps mode in the original state.
    **/
  ---procedure TEST;


 END FND_APPS_MODE_UTIL;

 

/
