--------------------------------------------------------
--  DDL for Package Body HR_CM_STAGE_END_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CM_STAGE_END_PKG" AS
/* $Header: hrcmstge.pkb 115.3 2002/01/04 07:05:42 pkm ship       $ */

FUNCTION gl_du_dp_stage_end
return varchar2 IS

  l_success    BOOLEAN;
  l_warning    BOOLEAN;
  l_batch_name varchar2(240);
  l_req_id     number;
  submit_exception exception;
begin

  --
  -- Get information from the completed stage....
  --
  for stage_data in fnd_request_set.stage_request_info
  loop
    if stage_data.exit_status = 'E'
    then
      --
      -- The Datauploader stage failed so return error...
      --
      return 'E';
    elsif stage_data.exit_status = 'W'
    then
       --
       -- Note the warning and continue. We will return warning if we get
       -- no further errors...
       --
       l_warning := TRUE;
    end if;
    --
    -- Now get the request_data information
    --
    l_batch_name := stage_data.request_data;
  end loop;
  --
  -- We've got no errors so we'll continue ...
  --
  -- ... and reset the link_value column for all our batch lines...
  --
  UPDATE hrdpv_create_company_cost_cent
     set link_value = batch_line_id
   where batch_id = to_number(l_batch_name);

  -- ....and submit the request set to call datapump etc
  --
  -- Set the context for the request set.
  --
  l_success := fnd_submit.set_request_set(application => 'PER'
                                         ,request_set => 'HRDPEXC'
	 				 );
  if (l_success)
  then
    l_success := fnd_submit.submit_program(
                           application => 'PER'
			  ,program     => 'DATAPUMP'
			  ,stage       => 'STAGE10'
			  ,argument1   => l_batch_name
			  ,argument2   => 'Yes');
    if not l_success
    then
      raise submit_exception;
    end if;
    l_success := fnd_submit.submit_program(
                           application => 'PER'
			  ,program     => 'PERPMPXC'
			  ,stage       => 'STAGE20'
			  ,argument1   => l_batch_name);
    if not l_success
    then
      raise submit_exception;
    end if;
    l_req_id := fnd_submit.submit_set(
                           start_time  => null
			  ,sub_request => TRUE
			  );
  else
    raise submit_exception;
  end if;
  return 'S';

exception
  when submit_exception then
     return 'E';
end gl_du_dp_stage_end;

end hr_cm_stage_end_pkg;

/
