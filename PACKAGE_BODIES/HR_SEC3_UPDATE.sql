--------------------------------------------------------
--  DDL for Package Body HR_SEC3_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SEC3_UPDATE" AS
/* $Header: hrsec3.pkb 115.3 2002/12/05 12:49:17 apholt ship $ */

  --
  -- PRIVATE FUNCTIONS AND PROCEDURES
  --

  --
  debug_mode_on    boolean  := FALSE ;

  --
   custom_schema  boolean := FALSE ;
  -- Raise an internal error. Not translated.
  --
  procedure raise_error( p_message in varchar2 ) is
  begin
     raise_application_error(-20001, p_message) ;
  end raise_error;

  procedure debug_on is
  begin
     debug_mode_on := TRUE ;
  end debug_on ;

  procedure debug_off is
  begin
     debug_mode_on := FALSE;
  end debug_off ;

  --
  -- Outputs a line if debug mode on or if force output
  --
  procedure output_line (p_message       in varchar2,
                         p_always_output in boolean default false ) is
  begin

--   if ( p_always_output or debug_mode_on ) then
      hr_utility.trace(p_message) ;
--   end if;

  end output_line ;

  --
  -- PUBLIC FUNCTIONS AND PROCEDURES
  --

 PROCEDURE set_profile_options IS
 --
 type bg_sp is record (
     business_group_id     per_business_groups.business_group_id%type,
     bg_name               per_business_groups.name%type,
     security_profile_id   per_security_profiles.security_profile_id%type,
     security_profile_name per_security_profiles.security_profile_name%type  ) ;

 l_site_value   varchar2(80) ;
 l_appl_value   varchar2(80) ;
 l_resp_value   varchar2(80) ;
 l_defined      boolean := false ;
 l_appl_defined boolean := false ;
 l_resp_defined boolean := false ;
 l_spa_defined  boolean := false ;
 l_sp_id        number(15);
 --
 -- These records contain the bg and sp values derived from the given
 -- profile option
 --
 bg_profile bg_sp ;
 sp_profile bg_sp ;


 --
 -- Returns details of the business group and its associated view
 -- all security profile option
 --
 procedure get_details ( p_sp_id in varchar2 default null,
                         p_bg_id in varchar2 default null ,
                         p_output out nocopy bg_sp  ) is
 cursor c1 is
   select bg.business_group_id,
          bg.name,
          sp.security_profile_id,
          sp.security_profile_name
   from   per_security_profiles sp,
          per_business_groups   bg
   where  sp.security_profile_id = nvl(p_sp_id,sp.security_profile_id)
   and    sp.business_group_id   = nvl(p_bg_id,sp.business_group_id)
   and    sp.business_group_id   = bg.business_group_id
   and    sp.view_all_flag       = decode(bg.business_group_id,null,
                                          sp.view_all_flag,'Y') ;

 begin
    open  c1 ;
    fetch c1 into p_output ;
    close c1 ;
 end ;
 --
 --
 procedure get_sec_profile_assignment ( p_resp_id in varchar2 default null,
                         p_sp_id out nocopy number,
			 defined out nocopy boolean) is
 cursor c1 is
   select distinct (responsibility_id),
	  security_profile_id
   from   per_sec_profile_assignments
   where  responsibility_id      = p_resp_id;
 l_resp1 number;

 begin
    open  c1 ;
    fetch c1 into l_resp1, p_sp_id ;
    defined := c1%found;
    close c1 ;
 end ;
 --
 --
 -- Gets the Responsibility Level setting of the given profile option
 --
 procedure get_resp_level ( option_name  in varchar2,
		            appl_id      in number,
		            resp_id      in number,
                            option_value out nocopy varchar2 ,
                            defined out nocopy  boolean ) is
  cursor c1 is
       select V.PROFILE_OPTION_VALUE
       from   FND_PROFILE_OPTIONS O, FND_PROFILE_OPTION_VALUES V
       where  O.PROFILE_OPTION_NAME = option_name
       and    V.LEVEL_ID = 10003 and V.LEVEL_VALUE = to_char(resp_id)
       and    V.LEVEL_VALUE_APPLICATION_ID = to_char(appl_id)
       and    O.PROFILE_OPTION_ID = V.PROFILE_OPTION_ID
       and    O.APPLICATION_ID    = V.APPLICATION_ID ;

 begin

    open c1 ;
    fetch c1 into option_value ;
    defined := c1%found ;
    close c1 ;

 end get_resp_level ;

 --
 --
 begin

    hr_utility.set_trace_options('TRACE_DEST:DBMS_OUTPUT');
    hr_utility.trace_on;
     --
     -- Get site level setting of business group. If it is set and the
     -- security profile is not then set the security profile to be the
     -- view all profile associated with that business group.
     --
     --
     -- Loop through each responsibility.
     --
     -- If the Business Group Profile option was set at Responsibility
     -- then do the following:
     -- 1.   Does a restricted security profile assignment exists
     --      for the responsibility.
     --         If yes then use this SP to set the SP profile option for
     --            the responsibility
     --         else
     --           use the View ALL SP for and set the SP profile option.
     --         end if;
     --
     --
        for resp in ( select responsibility_id,
                             responsibility_name,
			     application_id
		      from   fnd_responsibility_vl
                      order by responsibility_name )
        loop

             get_resp_level (
                option_name  => 'PER_BUSINESS_GROUP_ID',
                appl_id      => resp.application_id,
                resp_id      => resp.responsibility_id,
                option_value => l_resp_value,
                defined      => l_resp_defined ) ;

             if ( l_resp_defined = true  ) then

                 get_details(p_bg_id => l_resp_value , p_output => bg_profile);

                 output_line('resp. '||rpad(resp.responsibility_name,30) ||
                                      ' BG Profile value '||l_resp_value||'.'||
                                      bg_profile.bg_name ) ;
             --
             -- Get restricted security profile assignments if any.
             --
                 get_sec_profile_assignment(p_resp_id => resp.responsibility_id,
					    p_sp_id   => l_sp_id,
					    defined   => l_spa_defined);
             --
             -- If a restricted SP to set at this at responsibility else
             -- use the View ALL for the BG.
             --
                 if NOT l_spa_defined then
                    l_sp_id := bg_profile.security_profile_id;
		 end if;
                --
                -- Set the security profile to the responsibility setting
                --
                  output_line( 'Setting Security Profile for Resp '||
                               rpad(resp.responsibility_name,30),true) ;
                --
                if NOT  fnd_profile.save ( 'PER_SECURITY_PROFILE_ID',
						 l_sp_id,
						 'RESP',
						 resp.responsibility_id,
						 resp.application_id )
                   then
		  raise_error('ERROR - Setting Security Profile option '
                                      ||'at RESP level') ;
		end if;
                --
/*                -- Remove the business group responsibility setting.
                --
                  output_line( 'Removing Business Group Profile for Resp '||
                               rpad(resp.responsibility_name,30),true) ;
                --
                --
                if NOT  fnd_profile.save ( 'PER_BUSINESS_GROUP_ID',
						 null,
						 'RESP',
						 resp.responsibility_id,
						 resp.application_id )
                   then
		  raise_error('ERROR - Setting Security Profile option '
                                      ||'at RESP level') ;
		end if;
*/
           end if;

        end loop ;

end set_profile_options ;
--
end HR_SEC3_UPDATE;

/
