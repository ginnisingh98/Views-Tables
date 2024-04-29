--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_UTILS" AS
/* $Header: hrscutl.pkb 115.1 99/07/17 16:59:38 porting ship $ */

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

   if ( p_always_output or debug_mode_on ) then
      -- Bug#885806
      -- dbms_output.put_line(p_message) ;
      hr_utility.trace(p_message) ;
   end if;

  end output_line ;

  --
  -- PUBLIC FUNCTIONS AND PROCEDURES
  --

 PROCEDURE check_profile_options IS
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
                         p_output out bg_sp  ) is
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
 -- Gets the Responsibility Level setting of the given profile option
 --
 procedure get_resp_level ( option_name  in varchar2,
		            appl_id      in number,
		            resp_id      in number,
                            option_value out varchar2 ,
                            defined out  boolean ) is
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
 -- Gets the Application Level setting of the given profile option
 -- Note that the GET_ functions in the FND_PROFILE package does
 -- not detect whether the profile option is set already
 --
 procedure get_app_level ( option_name  in varchar2,
		           appl_id      in number,
                           option_value out varchar2 ,
                           defined out  boolean ) is
  cursor c1 is
       select V.PROFILE_OPTION_VALUE
       from  FND_PROFILE_OPTIONS O, FND_PROFILE_OPTION_VALUES V
       where O.PROFILE_OPTION_NAME = option_name
       and   V.LEVEL_ID = 10002 and V.LEVEL_VALUE = to_char(appl_id)
       and    O.PROFILE_OPTION_ID = V.PROFILE_OPTION_ID
       and    O.APPLICATION_ID    = V.APPLICATION_ID ;

 begin

    open c1 ;
    fetch c1 into option_value ;
    defined := c1%found ;
    close c1 ;

 end get_app_level ;

 begin

     dbms_output.enable(1000000) ;

     --
     -- Get site level setting of business group. If it is set and the
     -- security profile is not then set the security profile to be the
     -- view all profile associated with that business group.
     --

     l_site_value := fnd_profile.value_specific(name =>'PER_BUSINESS_GROUP_ID');

     if l_site_value is not null then

        get_details ( p_bg_id => l_site_value , p_output => bg_profile ) ;

        l_site_value := fnd_profile.value_specific(
                                 name=>'PER_SECURITY_PROFILE_ID');
        output_line('Site Level :business group profile is '||
                      bg_profile.bg_name) ;

         if ( l_site_value is null or l_site_value = 0 ) then

             output_line('Setting site level security profile',true) ;
             if NOT fnd_profile.save ( 'PER_SECURITY_PROFILE_ID',
                                       bg_profile.security_profile_id,
                                       'SITE' )
             then
                raise_error('ERROR - Setting Security Profile at SITE level') ;
             end if;

         end if;

     end if;

     --
     -- Loop through each application and responsibility.
     --
     -- 1. If the Business Group Profile option was set at Application level
     --    then clear it setting this value for each linked responsibility
     --    which does not already have a value set.
     --
     -- 2. If the Security Profile profile option is not set for a given
     --    responsibility then set it to be the View All security profile
     --    for the given business group
     --
     for rec in ( select application_id,
                         application_short_name,
                         application_name
                  from   fnd_application_vl
                  order  by application_name )
     loop

       output_line(rec.application_name||' ('||
                   rec.application_short_name||') ... ',true );
       get_app_level (
            option_name  => 'PER_BUSINESS_GROUP_ID',
            appl_id      => rec.application_id,
            option_value => l_appl_value,
            defined      => l_appl_defined ) ;

        if ( l_appl_defined = true  ) then

            get_details(p_bg_id => l_appl_value , p_output => bg_profile ) ;
            output_line(' Appl. '||rec.application_short_name ||
                                 ' BG Value '||l_appl_value||'.  '||
                                 bg_profile.bg_name ) ;

        end if;

        for resp in ( select responsibility_id,
                             responsibility_name
		      from   fnd_responsibility_vl
                      where  application_id = rec.application_id
                      order by responsibility_name )
        loop

             get_resp_level (
                option_name  => 'PER_BUSINESS_GROUP_ID',
                appl_id      => rec.application_id,
                resp_id      => resp.responsibility_id,
                option_value => l_resp_value,
                defined      => l_resp_defined ) ;

             if ( l_resp_defined = true  ) then

                 get_details(p_bg_id => l_resp_value , p_output => bg_profile);

                 output_line('resp. '||rpad(resp.responsibility_name,30) ||
                                      ' BG Profile value '||l_resp_value||'.'||
                                      bg_profile.bg_name ) ;

             elsif ( l_appl_defined = true ) then

                --
                -- Set the business group profile to the application setting
                --

                output_line( 'Setting Business Group profile for resp '||
                             rpad(resp.responsibility_name,30),true) ;
                if NOT fnd_profile.save (  'PER_BUSINESS_GROUP_ID',
                                           l_appl_value,
                                           'RESP',
                                           resp.responsibility_id,
                                           rec.application_id )
                then
                   raise_error('ERROR - Setting Business Group profile option'||
                               'at RESP level') ;
                end if;

            end if;

            --
            -- If the business group profile option was defined for this
            -- responsibility then check that the security profile option
            -- has been set.
            --
            if ( l_resp_defined or l_appl_defined ) then
		    get_resp_level (
			    option_name  => 'PER_SECURITY_PROFILE_ID',
			    appl_id      => rec.application_id,
			    resp_id      => resp.responsibility_id,
			    option_value => l_resp_value,
			    defined      => l_defined ) ;

		    if ( l_defined = true ) then

		       get_details ( p_sp_id => l_resp_value ,
                                     p_output => sp_profile ) ;
		       output_line('Resp '||rpad(resp.responsibility_name,30)||
					    ' SP Value '||l_resp_value||'.  '||
					    sp_profile.security_profile_name );

		    else

                       output_line( 'Setting Security Profile for Resp '||
                                    rpad(resp.responsibility_name,30),true) ;
		       if NOT fnd_profile.save ( 'PER_SECURITY_PROFILE_ID',
						 bg_profile.security_profile_id,
						 'RESP',
						 resp.responsibility_id,
						 rec.application_id )
		       then
			  raise_error('ERROR - Setting Security Profile option '
                                      ||'at RESP level') ;
		       end if;

		    end if;
	      end if;

        end loop ;

        --
        -- Remove application level business group profile option setting
        --

        if ( l_appl_defined = true ) then

            output_line('Clearing Application level Business Group profile '
                        ||'option value',true);
	    if NOT fnd_profile.save ('PER_BUSINESS_GROUP_ID',
				      NULL,
				      'APPL',
				      rec.application_id )
	    then
	       raise_error('ERROR - Clearing Business Group profile option at '
                           ||'APPL level') ;
	    end if;

        end if;

        output_line('',true);

  end loop ;

end check_profile_options ;


function is_custom_schema return boolean is
begin
  return custom_schema ;
end ;

procedure set_custom_schema is
begin
  custom_schema := true ;
end ;

end HR_SECURITY_UTILS;

/
