--------------------------------------------------------
--  DDL for Package Body FND_APPS_MODE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APPS_MODE_UTIL" AS
/* $Header: AFOAMAPMDB.pls 115.2 2004/09/02 19:26:26 rmohan noship $ */

---Common Constants
PROFILE_APPS_MAINTENANCE_MODE CONSTANT VARCHAR2(100) := 'APPS_MAINTENANCE_MODE';



procedure fdebug(msg in varchar2);


  /**
    * This function will return current mode of the Application System.
    **/
  function  GET_CURRENT_MODE   return varchar2
  is
  retu varchar2(100);
  begin
    fnd_profile.get(PROFILE_APPS_MAINTENANCE_MODE, retu);
    return retu;
  end;



  /**
    * This function will return true if Application System is in Maintenance Mode
    * else false
    **/
  function  COMPARE_MODE(pExpectedMode varchar2)   return boolean
  is
    retu boolean;
    lCurrentMode varchar2(100);
  begin
    lCurrentMode := GET_CURRENT_MODE;
    if(lCurrentMode = pExpectedMode) then
       retu := true;
    else
       retu := false;
    end if;
    return retu;
  end;

  /**
    * This function will return true if Application System is in Maintenance Mode
    * else false
    **/
  function  IS_IN_MAINTENANCE_MODE   return boolean
  is
  begin
    return COMPARE_MODE(MAINTENANCE_MODE);
  end;


   /**
    * This function will return true if Application System is in Normal Mode
    * else false.
    **/
  function  IS_IN_NORMAL_MODE   return boolean
  is
  begin
    return COMPARE_MODE(NORMAL_MODE);
  end;




  /**
    *  It will set the Application System in pMode
    *  param  pMode  New Mode of the System.
    *  param  pWFCode - Code to set in Workflow resource
    *  param retcode out type - values 0, 1
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_MODE (pMode varchar2, pWfCode varchar2, errbuf out NOCOPY varchar2,
                           retcode out NOCOPY number)
  is
  lretu boolean;
  begin
    lretu := FND_PROFILE.SAVE(PROFILE_APPS_MAINTENANCE_MODE, pMode, 'SITE');
    if lretu = TRUE then
      FND_PROFILE.put(PROFILE_APPS_MAINTENANCE_MODE, pMode);

    -- For Workflow To Enable: (when leaving maintenance mode)
      UPDATE wf_resources
       SET    text = pWfCode
        WHERE  type = 'WFTKN'
       AND    name = 'WF_SYSTEM_STATUS';
       commit;
       retcode := 0;
   else
       retcode := 1;
       errbuf := 'FND_PROFILE.SAVE returned false';
   end if;
   exception
      when others then
         retcode := 1;
         raise;
  end;


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
  procedure SET_TO_NORMAL_MODE (retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2)
  is
  begin
    SET_MODE(NORMAL_MODE, 'ENABLED', errbuf, retcode);
  end;

  /**
    *  It will set the Application System in Maintenance Mode.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    *  param retcode out type - values 0, 1
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    **/
  procedure SET_TO_MAINTENANCE_MODE (retcode out NOCOPY number
                           , errbuf out NOCOPY varchar2)
  is
  begin
    SET_MODE(MAINTENANCE_MODE, 'DISABLED', errbuf, retcode);
  end;



  /**
    *  Don't use this API
    *  It will set the Application System in pMode. If Profile Option doesn't
    *  exist, it will only change the setting for workflow event system.
    *  param  pMode  New Mode of the System.
    *  param  pWFCode - Code to set in Workflow resource
    *  param retcode out type - values 0, 1
    *         0  - Successful completion of procedure.
    *               errbuf will be null
    *         1 -  Error occurred and Application System mode is not changed.
    *               errbuf will have error message.
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  procedure SET_MODE_PATCH_MP11510(pMode varchar2, pWfCode varchar2
      , errbuf out NOCOPY varchar2, retcode out NOCOPY number)
  is
  lretu boolean;
  begin
    -- For Workflow
      UPDATE wf_resources
       SET    text = pWfCode
        WHERE  type = 'WFTKN'
       AND    name = 'WF_SYSTEM_STATUS';

    lretu := FND_PROFILE.SAVE(PROFILE_APPS_MAINTENANCE_MODE, pMode, 'SITE');
    if lretu = TRUE then
      FND_PROFILE.put(PROFILE_APPS_MAINTENANCE_MODE, pMode);
    end if;

    commit;
    retcode := 0;
   exception
      when others then
         retcode := 1;
         raise;
  end;



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
                           , errbuf out NOCOPY varchar2)
  is
  begin
    SET_MODE_PATCH_MP11510(MAINTENANCE_MODE, 'DISABLED', errbuf, retcode);
  end;


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
                           , errbuf out NOCOPY varchar2)
  is
  begin
    SET_MODE_PATCH_MP11510(NORMAL_MODE, 'ENABLED', errbuf, retcode);
  end;




  function toVarchar2(pBoolean boolean) return varchar2
  is
     retu varchar2(10);
  begin
     if(pBoolean = true) then
        retu := 'TRUE';
     else
        retu := 'FALSE';
     end if;
     return retu;
  end;

  /**
    * For Testing all API's
    * After testing it will put the Apps mode in the original state.
    **/
  procedure TEST
  is
  lString varchar2(1000);
  lExistingMode varchar2(1000);
  lBolValue boolean;
  retcode number;
  errbuf varchar2(1000);
  begin
    fdebug('Testing: GET_CURRENT_MODE');
    lExistingMode := GET_CURRENT_MODE;
    fdebug('lString=' || lExistingMode);

    fdebug('Testing: IS_IN_NORMAL_MODE');
    lBolValue := IS_IN_NORMAL_MODE;
    lString := toVarchar2(lBolValue);
    fdebug('lString=' || lString);

    fdebug('Testing: IS_IN_MAINTENANCE_MODE');
    lBolValue := IS_IN_MAINTENANCE_MODE;
    lString := toVarchar2(lBolValue);
    fdebug('lString=' || lString);

    fdebug('Testing: SET_TO_MAINTENANCE_MODE');
    SET_TO_MAINTENANCE_MODE(retcode, errbuf);
    lString := GET_CURRENT_MODE;
    fdebug('lString=' || lString || 'retcode=' || to_char(retcode) || ' errbuf=' || errbuf);

    fdebug('Testing: SET_TO_NORMAL_MODE');
    SET_TO_NORMAL_MODE(retcode, errbuf);
    lString := GET_CURRENT_MODE;
    fdebug('lString=' || lString || 'retcode=' || to_char(retcode) || ' errbuf=' || errbuf);

    fdebug('Test Done...Setting Back Profile to ' || lExistingMode);
    lBolValue := FND_PROFILE.SAVE(PROFILE_APPS_MAINTENANCE_MODE, lExistingMode, 'SITE');
    lString := GET_CURRENT_MODE;
    fdebug('lString=' || lString);
  end;




  /**
   * Debug method
   **/

  procedure fdebug(msg in varchar2)
  IS
  l_msg 		VARCHAR2(1000);
  BEGIN
     --l_msg := dbms_utility.get_time || '   ' || msg;
     ---dbms_output.put_line(dbms_utility.get_time || ' ' || msg);
     ---fnd_file.put_line( fnd_file.log, dbms_utility.get_time || ' ' || msg);
     l_msg := 'm';
  END fdebug;


 END FND_APPS_MODE_UTIL;

/
