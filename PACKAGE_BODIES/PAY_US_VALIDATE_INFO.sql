--------------------------------------------------------
--  DDL for Package Body PAY_US_VALIDATE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_VALIDATE_INFO" as
/* $Header: pymwsval.pkb 120.1 2005/10/05 03:47:57 sackumar noship $ */

 procedure validate_worksite_transmitter
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_err_code  		out nocopy number,
  p_err_msg		out nocopy varchar2
 ) is

 l_trans_flag 		varchar2(4);

 begin
	/* Check to see that only one transmitter GRE has been identified
	   for MWS Reporting */

	l_code := 1;

	select hoi.org_information1
	into l_trans_flag
	from HR_ORGANIZATION_INFORMATION hoi
	where hoi.org_information_context = p_context
	and   hoi.org_information1	      = 'Y'
    and exists (select null
    		    from hr_organization_information hoi1
	    	    where hoi1.organization_id = hoi.organization_id
                and  hoi1.org_information_context = 'CLASS'
                and hoi1.org_information1 = 'HR_LEGAL'
                and hoi1.org_information2 = 'Y')
	and  exists (select hou.organization_id
			from HR_ORGANIZATION_UNITS hou
			where hou.organization_id = hoi.organization_id
			and hou.business_group_id = p_business_group_id);


        p_err_code := 0;
	p_err_msg := 'Only one transmitter has been defined for MWS Reporting';

	return;

end validate_worksite_transmitter;

 procedure validate_worksite
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_err_code  		out nocopy number,
  p_err_msg		out nocopy varchar2
 ) is

 l_organization_id 	number(15);

 cursor get_worksite is
	select distinct hoi.org_information2,
			hoi.org_information3
	from HR_ORGANIZATION_INFORMATION hoi
	where hoi.org_information_context = p_context
    and exists (select null
	        from hr_organization_information hoi1
		    where hoi1.organization_id = hoi.organization_id
            and  hoi1.org_information_context = 'CLASS'
            and hoi1.org_information1 = 'HR_ESTAB'
            and hoi1.org_information2 = 'Y')
	and  exists (select hou.organization_id
			from HR_ORGANIZATION_UNITS hou
			where hou.organization_id = hoi.organization_id
			and hou.business_group_id = p_business_group_id);

 begin

	/* Check to see if a primary organization has been assigned for each
	   of the worksites to be reported . We will also check to see that
	   one and only one primary organization has been assigned to a
	   worksite */

	l_code := 2;

	/* Open the cursor to get the worksites */

        open get_worksite;

	/* Get each of the worksites that have been defined and check to see
	   if a primary organization has been assigned to each of the
	   worksites or not */

	p_err_code := 0;
	p_err_msg  := ' Primary Org. assigned for every worksite';

	loop


	  /* Get the SUI + RUN */
	  fetch get_worksite into l_sui_no,
				  l_run;

          exit when get_worksite%NOTFOUND;

	  /* Check if a primary organization has been assigned for the
	     SUI + RUN combination */

	  select hoi.organization_id
	  into   l_organization_id
	  from   HR_ORGANIZATION_INFORMATION hoi
	  where  hoi.org_information2 = l_sui_no
	  and    hoi.org_information3 = l_run
	  and    hoi.org_information1 = 'Y'
          and    hoi.org_information_context = p_context
	  and  exists (select hou.organization_id
			from HR_ORGANIZATION_UNITS hou
			where hou.organization_id = hoi.organization_id
			and hou.business_group_id = p_business_group_id);


        end loop;

	close get_worksite;

	return;

end validate_worksite;

 procedure validate
 (
  p_business_group_id   in  number ,
  p_context		in  varchar2,
  p_legislative_code    in varchar2,
  p_err_code  		out nocopy number,
  p_err_msg		out nocopy varchar2
 ) is

 l_context varchar2(240);

 begin

    if p_context = 'Multiple Worksite Reporting'
    then

	validate_worksite_transmitter(p_business_group_id,
			  p_context,
			  p_err_code,
			  p_err_msg);

    elsif p_context = 'Worksite Filing'
    then

	validate_worksite(p_business_group_id,
			  p_context,
			  p_err_code,
			  p_err_msg);

     end if;

     return;

 exception
 when no_data_found then
  if l_code = 1 then
	  p_err_code := 1;
	  p_err_msg  := 'Transmitter GRE for MWS has not been defined ';
  end if;

  if l_code = 2 then
	  p_err_code := 2;
	  p_err_msg  := 'Primary Org. not defined for SUI : ' ||
			l_sui_no || ' and RUN : ' || l_run;
  end if;
  return;

 when too_many_rows then
  if l_code = 1 then
	  p_err_code := 1;
	  p_err_msg := 'There can be only one transmitter for MWS Reporting';
  end if;

  if l_code = 2 then
	  p_err_code := 2;
	  p_err_msg  := 'Multiple Primary Org. for SUI : '
			 || l_sui_no || ' and RUN : ' || l_run;
  end if;
  return;

 when others then
	  p_err_code := sqlcode;

          if l_code = 1 then
 	    p_err_msg  := 'Getting transmitter :' ||substr(sqlerrm,1,80);
	  end if;

          if l_code = 2 then
 	    p_err_msg  := 'Getting Primary Org. :' ||substr(sqlerrm,1,80);
	  end if;
          return;
 end validate;

end pay_us_validate_info;

/
