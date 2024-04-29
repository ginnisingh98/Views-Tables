--------------------------------------------------------
--  DDL for Package Body HR_UPDATE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UPDATE_UTILITY" AS
/* $Header: hruptutil.pkb 120.0 2005/05/31 23:59:15 appldev noship $ */

-- ----------------------------------------------------------------------------
-- |----------------------------< submitRequest >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure submitRequest
   (p_app_shortname      in     varchar2
   ,p_update_name        in     varchar2
   ,p_validate_proc      in     varchar2
   ,p_business_group_id  in     number   default null
   ,p_legislation_code   in     varchar2 default null
   ,p_argument1          in     varchar2 default chr(0)
   ,p_argument2          in     varchar2 default chr(0)
   ,p_argument3          in     varchar2 default chr(0)
   ,p_argument4          in     varchar2 default chr(0)
   ,p_argument5          in     varchar2 default chr(0)
   ,p_argument6          in     varchar2 default chr(0)
   ,p_argument7          in     varchar2 default chr(0)
   ,p_argument8          in     varchar2 default chr(0)
   ,p_argument9          in     varchar2 default chr(0)
   ,p_argument10         in     varchar2 default chr(0)
   ,p_request_id            out nocopy number) is

  l_usr_id  number;
  l_resp_id  number;
  l_resp_appl_id number;

  l_update_process varchar2(5);

  l_request_id number := null;

  l_sql_stmt varchar2(250);

  l_upg_def_id pay_upgrade_definitions.upgrade_definition_id%type;
  l_upg_lvl    pay_upgrade_definitions.upgrade_level%type;
  l_upg_mthd   pay_upgrade_definitions.upgrade_method%type;

  /*
  ** Local variables for use by get_request_status
  */
  l_phase      varchar2(100);
  l_status     varchar2(100);
  l_dev_phase  varchar2(20);
  l_dev_status varchar2(20);
  l_message    varchar2(100);
  l_return     boolean;

  cursor csr_get_resp_details is
         select application_id, responsibility_id
	   from fnd_responsibility
	  where responsibility_key='SYSTEM_ADMINISTRATOR';

  cursor csr_get_user_details is
         select user_id
	   from fnd_user
	  where user_name = 'SYSADMIN';

  cursor csr_get_update_details is
         select upgrade_definition_id,
	        upgrade_level,
		upgrade_method
           from pay_upgrade_definitions
	  where short_name = p_update_name;

  /*
  ** This cursor is used to get the status of a GUP
  ** based process.  In this case the CP will be submitted multiple
  ** times but any check to prevent duplicate submission needs to
  ** look at the individual parameter values passed to determine whether
  ** a duplicate process to the one about to be submitted is already
  ** running.  In this case the critical parameters are BG id(argument7)
  ** and the upgrade name(argument12).  Ideally this check should be
  ** supported within the AOL layer but until such time....
  */
  cursor csr_get_conc_req_status is
         select cr.phase_code dev_phase,
		cr.status_code dev_status,
		cr.request_id request_id
           from fnd_concurrent_programs cp,
	        fnd_concurrent_requests cr,
		fnd_application a
          where a.application_short_name = p_app_shortname
            and a.application_id = cp.application_id
	    and cp.concurrent_program_name = 'PAY_GEN_UPG'
            and cp.concurrent_program_id = cr.concurrent_program_id
            and cr.argument7 = p_business_group_id
            and cr.argument12 = 'UPG_DEF_NAME='||p_update_name
	 order by cr.request_date desc;

begin

  p_request_id := null;
  /*
  ** Execute the procedure to determine whether the conc request is
  ** required.
  */
  l_sql_stmt := 'begin '||p_validate_proc||'( :a ); end;';
  execute immediate l_sql_stmt using out l_update_process;

  if l_update_process = 'TRUE' then
    /*
    ** The update is required so submit a request for the SYSADMIN user using
    ** the System Administrator responsibility.
    */

    /* Get the required IDs...
    */
    open csr_get_user_details;
    fetch csr_get_user_details into l_usr_id;
    close csr_get_user_details;

    open csr_get_resp_details;
    fetch csr_get_resp_details into l_resp_appl_id, l_resp_id;
    close csr_get_resp_details;

    /* Get some details of the update being submitted to determine
    ** the correct submission mechanism.
    */
    open csr_get_update_details;
    fetch csr_get_update_details into l_upg_def_id, l_upg_lvl,
                                      l_upg_mthd;
    if csr_get_update_details%NOTFOUND then
      hr_utility.set_message(800, 'PER_51775_UPD_NAME_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    close csr_get_update_details;

    /* Initiate an APPS session as SYSADMIN
    */
    fnd_global.apps_initialize(user_id      => l_usr_id,
                               resp_id      => l_resp_id,
			       resp_appl_id => l_resp_appl_id);

    if l_upg_mthd = 'SQLPLUS' then

      /* The update_name passed holds the name of the concurrent program
      ** to be submitted.
      **
      ** First look to see if a request for this CP is waiting to run.  If so
      ** then don't submit another one.
      */
      l_return := fnd_concurrent.get_request_status(
			request_id => l_request_id,
			appl_shortname => p_app_shortname,
			program => p_update_name,
			phase => l_phase,
			status => l_status,
			dev_phase => l_dev_phase,
			dev_status => l_dev_status,
			message => l_message);

      /* The get_request_status returns FALSE if no request is found for the
      ** specified program.  Therefore submit a request.
      ** The get_request_status returns TRUE if a request is found.  The
      ** dev_status holds the execution status of the request.  Submit a new
      ** request if there is no request for the CP waiting to run(dev_status of
      ** PENDING.
      **/


      if  l_return = FALSE or
         (l_return = TRUE and (l_dev_phase <> 'PENDING' and
	                       l_dev_phase <> 'RUNNING' )) then


   	/*
   	** We need to submit the request and pass out the request ID for
   	** reference.
   	*/
   	l_request_id := fnd_request.submit_request(
   			   application => p_app_shortname,
   			   program => p_update_name,
   			   argument1 => p_argument1,
   			   argument2 => p_argument2,
   			   argument3 => p_argument3,
   			   argument4 => p_argument4,
   			   argument5 => p_argument5,
   			   argument6 => p_argument6,
   			   argument7 => p_argument7,
   			   argument8 => p_argument8,
   			   argument9 => p_argument9,
   			   argument10 => p_argument10);

   	p_request_id := l_request_id;

      else

	/*
	** Program either running or waiting to run so return request ID.
	*/
	p_request_id := l_request_id;

      end if;

    else

   	/* The update is defined as a PYUGEN based update.  Submit PYUGEN
   	** passing the name of the update.
   	**
	** Check to see if a duplicate process is already running...
   	*/
	open csr_get_conc_req_status;
	fetch csr_get_conc_req_status
	      into l_dev_phase, l_dev_status, l_request_id;

	if  csr_get_conc_req_status%NOTFOUND or
	   (csr_get_conc_req_status%FOUND and (l_dev_phase <> 'P' and
	                                       l_dev_phase <> 'R')) then

          close csr_get_conc_req_status;

     	  l_request_id := fnd_request.submit_request (
   	       application => 'PER',
   	       program     => 'PAY_GEN_UPG',
   	       argument1   => 'ARCHIVE',			   -- Process Name
   	       argument2   => 'GENERIC_UPGRADE',		   -- Report Type
   	       argument3   => 'DEFAULT',			   -- Rpt Qual
   	       argument4   => fnd_date.date_to_canonical(sysdate), -- Start Date
   	       argument5   => fnd_date.date_to_canonical(sysdate), -- End Date
   	       argument6   => 'PROCESS',			   -- Rpt Category
   	       argument7   => to_Char(p_business_group_id),	   -- Business Grp
   	       argument8   => '',				   -- Mag File Nme
   	       argument9   => '',				   -- Rep File Nme
   	       argument10  => to_char(l_upg_def_id),		   -- ID
   	       argument11  => p_update_name,			   -- Short Name
   	       argument12  => 'UPG_DEF_NAME='||p_update_name	   -- Upgrade Name
   	       );

   	  p_request_id := l_request_id;

	else

          close csr_get_conc_req_status;

  	  /*
	  ** Program either running or waiting to run so return request ID.
	  */
	  p_request_id := l_request_id;

   	end if;
    end if; /* l_upg_mthd */

  else

    /* The update is not required for this customer.  Set the status to
    ** indicate this.  This is acheived by first setting the status to
    ** processing and then to complete due to validation within the GUP
    ** infrastructure code.
    ** Only do this if the process is not already at a Complete status.
    */
    if isUpdateComplete(p_app_shortname,
                        NULL,
                        p_business_group_id,
                        p_update_name) = 'FALSE' then

      setUpdateProcessing(p_update_name,
                          p_business_group_id,
			  p_legislation_code);
      setUpdateComplete(p_update_name,
                        p_business_group_id,
		        p_legislation_code);

    end if;

  end if;

end submitRequest;


-- ----------------------------------------------------------------------------
-- |--------------------------< isUpdateComplete >---------------------------|
-- ----------------------------------------------------------------------------
--
function isUpdateComplete
   (p_app_shortname      varchar2
   ,p_function_name      varchar2
   ,p_business_group_id  number
   ,p_update_name        varchar2) return varchar2 is

l_status varchar2(20);

begin

  pay_core_utils.get_upgrade_status(
            p_bus_grp_id => p_business_group_id,
	    p_short_name => p_update_name,
	    p_status     => l_status,
	    p_raise_error => FALSE
	    );

  if    l_status = 'Y' then
    /* The upgrade is complete if the last procedure returned a status of 'Y'
    */
    return 'TRUE';
  else
    return 'FALSE';
  end if;

/*
exception
  when no_data_found then
     return 'FALSE';
*/
end isUpdateComplete;

-- ----------------------------------------------------------------------------
-- |--------------------------< setUpdateProcessing >------------------------|
-- ----------------------------------------------------------------------------
--
procedure setUpdateProcessing
   (p_update_name        varchar2,
    p_business_group_id  number default null,
    p_legislation_code   varchar2 default null) is

  cursor csr_get_update_details is
         select upgrade_definition_id,
	        upgrade_level
           from pay_upgrade_definitions
	  where short_name = p_update_name;

  l_upg_def_id pay_upgrade_definitions.upgrade_definition_id%type;
  l_upg_lvl    pay_upgrade_definitions.upgrade_level%type;

begin


  /* Get some details of the update being submitted to determine
  ** the correct submission mechanism.
  */
  open csr_get_update_details;
  fetch csr_get_update_details into l_upg_def_id, l_upg_lvl;
  close csr_get_update_details;

  pay_generic_upgrade.set_upgrade_status(
                           p_upg_def_id => l_upg_def_id,
			   p_upg_lvl    => l_upg_lvl,
			   p_bus_grp    => p_business_group_id,
			   p_leg_code   => p_legislation_code,
			   p_status     => 'P');

end setUpdateProcessing;

-- ----------------------------------------------------------------------------
-- |--------------------------< setUpdateComplete >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure setUpdateComplete
   (p_update_name        varchar2,
    p_business_group_id  number default null,
    p_legislation_code   varchar2 default null) is

  cursor csr_get_update_details is
         select upgrade_definition_id,
	        upgrade_level
           from pay_upgrade_definitions
	  where short_name = p_update_name;

  l_upg_def_id pay_upgrade_definitions.upgrade_definition_id%type;
  l_upg_lvl    pay_upgrade_definitions.upgrade_level%type;

begin


  /* Get some details of the update being submitted to determine
  ** the correct submission mechanism.
  */
  open csr_get_update_details;
  fetch csr_get_update_details into l_upg_def_id, l_upg_lvl;
  close csr_get_update_details;

  pay_generic_upgrade.set_upgrade_status(
                           p_upg_def_id => l_upg_def_id,
			   p_upg_lvl    => l_upg_lvl,
			   p_bus_grp    => p_business_group_id,
			   p_leg_code   => p_legislation_code,
			   p_status     => 'C');

end setUpdateComplete;

end hr_update_utility;

/
