--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_SSHR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_SSHR_UTILS_PKG" 
/* $Header: pykryutl.pkb 120.8.12010000.14 2010/02/23 14:07:16 vaisriva ship $ */
as
--------------------------------------------------------------
g_debug  boolean  := hr_utility.debug_enabled;
--------------------------------------------------------------

  CURSOR csr_get_def_bal_id(p_bal_name IN varchar2) is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_defined_balances pdb,
         pay_balance_dimensions pbd
    where pbt.balance_type_id       = pdb.balance_type_id
      and pbt.balance_name      = p_bal_name
      and pdb.balance_dimension_id  = pbd.balance_dimension_id
      and pbd.dimension_name        in ('_ASG_YTD_MTH','_ASG_YTD_BON')
      and pbt.legislation_code      = 'KR'
      and pbd.legislation_code      = 'KR';

  CURSOR csr_get_def_bal_id_ytd(p_bal_name IN varchar2) is
      select pdb.defined_balance_id
      from pay_balance_types pbt,
           pay_defined_balances pdb,
           pay_balance_dimensions pbd
      where pbt.balance_type_id       = pdb.balance_type_id
        and pbt.balance_name      = p_bal_name
        and pdb.balance_dimension_id  = pbd.balance_dimension_id
        and pbd.dimension_name        = '_ASG_YTD'
        and pbt.legislation_code      = 'KR'
      and pbd.legislation_code      = 'KR';


    function yea_entry_status(p_assignment_id number, p_target_year varchar2) return varchar2
    is
        l_entry_status          VARCHAR2(2);

        cursor csr_get_entry_status is
               select ayi_information3
               from   per_kr_assignment_yea_info
               where  information_type = 'KR_YEA_ENTRY_STATUS'
               and    assignment_id    = p_assignment_id
               and    target_year      = p_target_year;
        begin

        OPEN csr_get_entry_status;
        FETCH csr_get_entry_status into l_entry_status;
        IF csr_get_entry_status%NOTFOUND then
           return 'N';
        ELSE
           return l_entry_status;
        END IF;
    end yea_entry_status;

    -----------------------------------------------------------------------------------
    -- This function takes Concurrent request ID, and output type as input parameters
    -- and it returns and URL for the Concurrent requests output  / log file.
    -----------------------------------------------------------------------------------

    function get_URL(p_file_type varchar2,
                     p_request_id number,
                     p_gwy_uid varchar2,
                     p_two_task varchar2) return varchar2
    is
      l_return_url    varchar2(256);
    begin
      --
      if p_file_type = 'OUTPUT' then
        l_return_url := fnd_webfile.get_url(fnd_webfile.request_out, p_request_id, p_gwy_uid, p_two_task, 15);
      elsif p_file_type = 'LOG' then
        l_return_url := fnd_webfile.get_url(fnd_webfile.request_log, p_request_id, p_gwy_uid, p_two_task, 15);
      else
        l_return_url := 'ERROR';
      end if;
      --
      return l_return_url;
    end get_URL;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- Function get_total_taxable returns the total taxable earnings of an employee's
    -- assignment as on an effective date.
    -----------------------------------------------------------------------------------
    function get_total_taxable(p_assignment_id number, p_effective_date date) return number
    is
      l_def_balance_id1     NUMBER;
      l_def_balance_id2     NUMBER;
      l_total_taxable       NUMBER;
    --
    begin

    OPEN csr_get_def_bal_id('TOTAL_TAXABLE_EARNINGS');
    FETCH csr_get_def_bal_id into l_def_balance_id1;
    FETCH csr_get_def_bal_id into l_def_balance_id2;
    if csr_get_def_bal_id%NOTFOUND then
       CLOSE csr_get_def_bal_id;
       raise no_data_found;
    end if;
    CLOSE csr_get_def_bal_id;

    l_total_taxable := nvl(pay_balance_pkg.get_value(l_def_balance_id1,p_assignment_id,p_effective_date),0)+
                       nvl(pay_balance_pkg.get_value(l_def_balance_id2,p_assignment_id,p_effective_date),0);

    return(l_total_taxable);
    end;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- Function get_total_itax returns the total income tax incurred for an employee's
    -- assignment as on an effective date.
    -----------------------------------------------------------------------------------
    function get_total_itax(p_assignment_id number, p_effective_date date) return number
    is
      l_def_balance_id1     NUMBER;
      l_def_balance_id2     NUMBER;
      l_total_itax          NUMBER;
    --
    begin

    OPEN csr_get_def_bal_id('ITAX');
    FETCH csr_get_def_bal_id into l_def_balance_id1;
    FETCH csr_get_def_bal_id into l_def_balance_id2;
    if csr_get_def_bal_id%NOTFOUND then
      CLOSE csr_get_def_bal_id;
      raise no_data_found;
    end if;
    CLOSE csr_get_def_bal_id;

    l_total_itax := nvl(pay_balance_pkg.get_value(l_def_balance_id1,p_assignment_id,p_effective_date),0)
                   +nvl(pay_balance_pkg.get_value(l_def_balance_id2,p_assignment_id,p_effective_date),0);

    return(l_total_itax);
    end;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- Function get_total_rtax returns the total resident tax incurred for an employee's
    -- assignment as on an effective date.
    -----------------------------------------------------------------------------------
    function get_total_rtax(p_assignment_id number, p_effective_date date) return number
    is
      l_def_balance_id1     NUMBER;
      l_def_balance_id2     NUMBER;
      l_total_rtax          NUMBER;

    --
    begin

      OPEN csr_get_def_bal_id('RTAX');
      FETCH csr_get_def_bal_id into l_def_balance_id1;
      FETCH csr_get_def_bal_id into l_def_balance_id2;
      if csr_get_def_bal_id%NOTFOUND then
        CLOSE csr_get_def_bal_id;
        raise no_data_found;
      end if;
      CLOSE csr_get_def_bal_id;
      l_total_rtax := nvl(pay_balance_pkg.get_value(l_def_balance_id1,p_assignment_id,p_effective_date),0)
                    +nvl(pay_balance_pkg.get_value(l_def_balance_id2,p_assignment_id,p_effective_date),0);
      return(l_total_rtax);
    end;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- Function get_total_stax returns the total special tax incurred for an employee's
    -- assignment as on an effective date.
    -----------------------------------------------------------------------------------
    function get_total_stax(p_assignment_id number, p_effective_date date) return number
    is
      l_def_balance_id1     NUMBER;
      l_def_balance_id2     NUMBER;
      l_total_stax          NUMBER;

    begin

      OPEN csr_get_def_bal_id('STAX');
      FETCH csr_get_def_bal_id into l_def_balance_id1;
      FETCH csr_get_def_bal_id into l_def_balance_id2;
      if csr_get_def_bal_id%NOTFOUND then
        CLOSE csr_get_def_bal_id;
        raise no_data_found;
      end if;
      CLOSE csr_get_def_bal_id;

       l_total_stax := nvl(pay_balance_pkg.get_value(l_def_balance_id1,p_assignment_id,p_effective_date),0)
                 +nvl(pay_balance_pkg.get_value(l_def_balance_id2,p_assignment_id,p_effective_date),0);
      return(l_total_stax);
    end;
    -----------------------------------------------------------------------------------
    -- Gets the YTD balance for Overseas Earnings
    -----------------------------------------------------------------------------------
    function get_ovs_processed(p_assignment_id number, p_effective_date date) return number
    is
      l_def_balance_id     NUMBER;
      l_ovs_bal            NUMBER;

    begin

      OPEN csr_get_def_bal_id_ytd('Overseas Earnings');
      FETCH csr_get_def_bal_id_ytd into l_def_balance_id;
      if csr_get_def_bal_id_ytd%NOTFOUND then
        CLOSE csr_get_def_bal_id_ytd;
        raise no_data_found;
      end if;
      CLOSE csr_get_def_bal_id_ytd;

      l_ovs_bal := nvl(pay_balance_pkg.get_value(l_def_balance_id,p_assignment_id,p_effective_date),0);

      return(l_ovs_bal);
    end;

    -----------------------------------------------------------------------------------
    -- This procedure will be used to transfer the data from intermediate table
    -- to the EIT table (PER_ASSIGNMENT_EXTRA_INFO)
    -----------------------------------------------------------------------------------
    procedure submit_yea_info(p_assignment_id    in varchar2,
                              p_target_year      in varchar2,
                              p_effective_date   in varchar2, -- expects canonical
                              p_return_status    out nocopy varchar2, -- S => Success, E => Error
                              p_return_message   out nocopy varchar2,
                              p_failed_record    out nocopy varchar2
                              )
    is
      l_proc_name       varchar2(50);
      l_effective_date  date;
      l_yea_data_exists varchar2(1);
      l_yea_fwtb_data_exists varchar2(1);
      l_aei_id          per_assignment_extra_info.assignment_extra_infO_id%type;
      l_ovn             per_assignment_extra_info.object_version_number%type;
      l_record_name     varchar2(50);
      l_person_id       number ;
      l_session_id	number ;
      --
      -- Bug 9326153
      --
      cursor csr_delete
      is
      select assignment_extra_info_id,object_version_number
      from per_assignment_extra_info
      where assignment_id = p_assignment_id
      and to_number(to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY')) = p_target_year
      And information_type in       ('KR_YEA_SP_TAX_EXEM_INFO'
                                    ,'KR_YEA_SP_TAX_EXEM_INFO2'
                                    ,'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
                                    ,'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
                                    ,'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
                                    ,'KR_YEA_PREV_ER_INFO'
                                    ,'KR_YEA_TAX_BREAK_INFO'
                                    ,'KR_YEA_TAX_EXEM_INFO'
                                    ,'KR_YEA_OVS_TAX_BREAK_INFO'
                                    ,'KR_YEA_DETAIL_DONATION_INFO'
                                    ,'KR_YEA_EMP_EXPENSE_DETAILS'
      				    ,'KR_YEA_TAX_GROUP_INFO'
      				    ,'KR_YEA_NON_TAXABLE_EARN_DETAIL'
				    ,'KR_YEA_DONATION_TYPE_DETAIL');
      --
      -- End of Bug 9326153
      --
      Cursor csr_yea_data_exists
      Is
        Select 'Y'
          From per_assignment_extra_info
         Where assignment_id = p_assignment_id
           And to_number(to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY')) = p_target_year
           And information_type in ('KR_YEA_SP_TAX_EXEM_INFO'
                                    ,'KR_YEA_SP_TAX_EXEM_INFO2'
                                    ,'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
                                    ,'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
                                    ,'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
                                    ,'KR_YEA_PREV_ER_INFO'
                                    ,'KR_YEA_TAX_BREAK_INFO'
                                    ,'KR_YEA_TAX_EXEM_INFO'
                                    ,'KR_YEA_OVS_TAX_BREAK_INFO'
                                    ,'KR_YEA_DETAIL_DONATION_INFO' -- Bug 3506170
                                    ,'KR_YEA_EMP_EXPENSE_DETAILS'  -- Bug 5372366
				    ,'KR_YEA_TAX_GROUP_INFO'       -- Bug 7361372
				    ,'KR_YEA_NON_TAXABLE_EARN_DETAIL' -- Bug 8880376
				    ,'KR_YEA_DONATION_TYPE_DETAIL') ; -- Bug 7142612

      Cursor csr_yea_fwtb_data_exists
      Is
        Select 'Y'
          From per_assignment_extra_info
         Where assignment_id = p_assignment_id
           And information_type ='KR_YEA_FW_TAX_BREAK_INFO';

      --
      Cursor csr_kr_assignment_yea_info
      Is
        select info.assignment_id,
            info.information_type,
            info.ayi_information1,
            info.ayi_information2,
            info.ayi_information3,
            info.ayi_information4,
            info.ayi_information5,
            info.ayi_information6,
            info.ayi_information7,
            info.ayi_information8,
            info.ayi_information9,
            info.ayi_information10,
            info.ayi_information11,
            info.ayi_information12,
            info.ayi_information13,
            info.ayi_information14,
            info.ayi_information15,
            info.ayi_information16,
            info.ayi_information17,
            info.ayi_information18,
            info.ayi_information19,
            info.ayi_information20,
            info.ayi_information21,
            info.ayi_information22,
            info.ayi_information23,
            info.ayi_information24,
            info.ayi_information25,
            info.ayi_information26,
            info.ayi_information27,
            info.ayi_information28,
            info.ayi_information29,
            info.ayi_information30
          from per_kr_assignment_yea_info info
         where assignment_id = p_assignment_id
           and target_year = p_target_year
           and information_type in ('KR_YEA_SP_TAX_EXEM_INFO'
                                    ,'KR_YEA_SP_TAX_EXEM_INFO2'
                                    ,'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
                                    ,'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
                                    ,'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
                                    ,'KR_YEA_PREV_ER_INFO'
                                    ,'KR_YEA_TAX_BREAK_INFO'
                                    ,'KR_YEA_TAX_EXEM_INFO'
                                    ,'KR_YEA_OVS_TAX_BREAK_INFO'
                                    ,'KR_YEA_EMP_EXPENSE_DETAILS'   -- Bug 5372366
				    ,'KR_YEA_TAX_GROUP_INFO')        -- Bug 7361372
         Union All
         select info.assignment_id,
            info.information_type,
            info.ayi_information1,
            info.ayi_information2,
            info.ayi_information3,
            info.ayi_information4,
            info.ayi_information5,
            info.ayi_information6,
            info.ayi_information7,
            info.ayi_information8,
            info.ayi_information9,
            info.ayi_information10,
            info.ayi_information11,
            info.ayi_information12,
            info.ayi_information13,
            info.ayi_information14,
            info.ayi_information15,
            info.ayi_information16,
            info.ayi_information17,
            info.ayi_information18,
            info.ayi_information19,
            info.ayi_information20,
            info.ayi_information21,
            info.ayi_information22,
            info.ayi_information23,
            info.ayi_information24,
            info.ayi_information25,
            info.ayi_information26,
            info.ayi_information27,
            info.ayi_information28,
            info.ayi_information29,
            info.ayi_information30
          from per_kr_assignment_yea_info info
         where assignment_id = p_assignment_id
           and information_type = 'KR_YEA_FW_TAX_BREAK_INFO';

	Cursor csr_kr_assignment_yea_info1
      	Is
        select info.assignment_yea_info_id,
	    info.assignment_id,
            info.information_type,
            info.ayi_information1,
            info.ayi_information2,
            info.ayi_information3,
            info.ayi_information4,
            info.ayi_information5,
            info.ayi_information6,
            info.ayi_information7,
            info.ayi_information8,
            info.ayi_information9,
            info.ayi_information10,
            info.ayi_information11,
            info.ayi_information12,
            info.ayi_information13,
            info.ayi_information14,
            info.ayi_information15,
            info.ayi_information16,
            info.ayi_information17,
            info.ayi_information18,
            info.ayi_information19,
            info.ayi_information20,
            info.ayi_information21,
            info.ayi_information22,
            info.ayi_information23,
            info.ayi_information24,
            info.ayi_information25,
            info.ayi_information26,
            info.ayi_information27,
            info.ayi_information28,
            info.ayi_information29,
            info.ayi_information30
          from per_kr_assignment_yea_info info
         where assignment_id = p_assignment_id
           and target_year = p_target_year
           and information_type = 'KR_YEA_DETAIL_DONATION_INFO';

	Cursor csr_kr_assignment_yea_info2(p_asgInfoId in varchar2)
	Is
	select info.assignment_id,
             info.information_type,
             info.ayi_information1,
             info.ayi_information2,
             info.ayi_information3,
             info.ayi_information4,
             info.ayi_information5,
             info.ayi_information6,
             info.ayi_information7,
             info.ayi_information8,
             info.ayi_information9,
             info.ayi_information10,
             info.ayi_information11,
             info.ayi_information12,
             info.ayi_information13,
             info.ayi_information14,
             info.ayi_information15,
             info.ayi_information16,
             info.ayi_information17,
             info.ayi_information18,
             info.ayi_information19,
             info.ayi_information20,
             info.ayi_information21,
             info.ayi_information22,
             info.ayi_information23,
             info.ayi_information24,
             info.ayi_information25,
             info.ayi_information26,
             info.ayi_information27,
             info.ayi_information28,
             info.ayi_information29,
             info.ayi_information30
           from per_kr_assignment_yea_info info
          where assignment_id = p_assignment_id
            and target_year = p_target_year
            and ayi_information6 = p_asgInfoId
            and information_type = 'KR_YEA_DONATION_TYPE_DETAIL';

    	Cursor csr_kr_assignment_yea_info3
      	Is
        select info.assignment_yea_info_id,
	    info.assignment_id,
            info.information_type,
            info.ayi_information1,
            info.ayi_information2,
            info.ayi_information3,
            info.ayi_information4,
            info.ayi_information5,
            info.ayi_information6,
            info.ayi_information7,
            info.ayi_information8,
            info.ayi_information9,
            info.ayi_information10,
            info.ayi_information11,
            info.ayi_information12,
            info.ayi_information13,
            info.ayi_information14,
            info.ayi_information15,
            info.ayi_information16,
            info.ayi_information17,
            info.ayi_information18,
            info.ayi_information19,
            info.ayi_information20,
            info.ayi_information21,
            info.ayi_information22,
            info.ayi_information23,
            info.ayi_information24,
            info.ayi_information25,
            info.ayi_information26,
            info.ayi_information27,
            info.ayi_information28,
            info.ayi_information29,
            info.ayi_information30
          from per_kr_assignment_yea_info info
         where assignment_id = p_assignment_id
           and target_year = p_target_year
           and information_type = 'KR_YEA_NON_TAXABLE_EARN_DETAIL';

	l_asgInfoId number;
      --
      -- Bug 4915940
      cursor csr_person_id(p_eff_date in date) is
      	select 	person_id
	from 	per_assignments_f
	where 	assignment_id = p_assignment_id
		and p_eff_date between effective_start_date and effective_end_date ;
      --
      cursor csr_get_session_id is
       select 	session_id
       from 	fnd_sessions
       where 	session_id = userenv('sessionid');

      -- End of 4915940
      --
    begin
      --
      l_proc_name := 'pay_kr_yea_sshr_utils_pkg.submit_yea_info';
      p_return_status := 'S';
      --
      --
      if g_debug then
        hr_utility.set_location(l_proc_name, 10);
      end if;
      --
      --
      if p_effective_date is null then
          l_effective_date := to_date('31/12/'||to_char(p_target_year), 'DD/MM/YYYY');
      else
          l_effective_date := fnd_date.canonical_to_date(p_effective_date);
      end if;
      --
      -- Bug 4915940: Setting profiles PER_PERSON_ID and PER_ASSIGNMENT_ID

      -- Insert a row into fnd_sessions if reqd
      open 	csr_get_session_id;
      fetch 	csr_get_session_id into l_session_id;
      if csr_get_session_id%notfound then
		insert into fnd_sessions(session_id,effective_date)
		values (userenv('sessionid'),l_effective_date);
      end if;
      close 	csr_get_session_id;

      open 	csr_person_id(l_effective_date) ;
      fetch 	csr_person_id into l_person_id ;
      close 	csr_person_id ;
      --
      fnd_profile.put('PER_ASSIGNMENT_ID', p_assignment_id ) ;
      fnd_profile.put('PER_PERSON_ID', to_char(l_person_id) ) ;
      -- End of 4915940
      --
      -- check if data has already been entered
      --
      open  csr_yea_data_exists;
      fetch csr_yea_data_exists into l_yea_data_exists;
        if csr_yea_data_exists%notfound then
          l_yea_data_exists := 'N';
        end if;
      close csr_yea_data_exists;

      open  csr_yea_fwtb_data_exists;
      fetch csr_yea_fwtb_data_exists into l_yea_fwtb_data_exists;
        if csr_yea_fwtb_data_exists%notfound then
          l_yea_fwtb_data_exists := 'N';
        end if;
      close csr_yea_fwtb_data_exists;
      --
      -- Bug 9326153
      --
      for i in csr_delete loop
      --
      hr_assignment_extra_info_api.delete_assignment_extra_info(
      		p_validate			=> false,
      		p_assignment_extra_info_id	=> i.assignment_extra_info_id,
		p_object_version_number		=> i.object_version_number);
      end loop;
      -- End of Bug 9326153
      --
      delete from per_assignment_extra_info
      where assignment_id = p_assignment_id
      And information_type = 'KR_YEA_FW_TAX_BREAK_INFO';

      --
      --
      for rec in csr_kr_assignment_yea_info loop
        --
        l_record_name := rec.information_type;
        -- skip any record which is empty
        if(NOT (rec.ayi_information1 is null and
           rec.ayi_information2 is null and
           rec.ayi_information3 is null and
           rec.ayi_information4 is null and
           rec.ayi_information5 is null and
           rec.ayi_information6 is null and
           rec.ayi_information7 is null and
           rec.ayi_information8 is null and
           rec.ayi_information9 is null and
           rec.ayi_information10 is null and
           rec.ayi_information11 is null and
           rec.ayi_information12 is null and
           rec.ayi_information13 is null and
           rec.ayi_information14 is null and
           rec.ayi_information15 is null and
           rec.ayi_information16 is null and
           rec.ayi_information17 is null and
           rec.ayi_information18 is null and
           rec.ayi_information19 is null and
           rec.ayi_information20 is null and
           rec.ayi_information21 is null and
           rec.ayi_information22 is null and
           rec.ayi_information23 is null and
           rec.ayi_information24 is null and
           rec.ayi_information25 is null and
           rec.ayi_information26 is null and
           rec.ayi_information27 is null and
           rec.ayi_information28 is null and
           rec.ayi_information29 is null and
           rec.ayi_information30 is null )) then

           hr_assignment_extra_info_api.create_assignment_extra_info(
                    p_validate          => false,
                    p_assignment_id         => rec.assignment_id,
                    p_information_type      => rec.information_type,
                    p_aei_information_category  => rec.information_type,
                    p_aei_information1      => rec.ayi_information1,
                    p_aei_information2      => rec.ayi_information2,
                    p_aei_information3      => rec.ayi_information3,
                    p_aei_information4      => rec.ayi_information4,
                    p_aei_information5      => rec.ayi_information5,
                    p_aei_information6      => rec.ayi_information6,
                    p_aei_information7      => rec.ayi_information7,
                    p_aei_information8      => rec.ayi_information8,
                    p_aei_information9      => rec.ayi_information9,
                    p_aei_information10     => rec.ayi_information10,
                    p_aei_information11     => rec.ayi_information11,
                    p_aei_information12     => rec.ayi_information12,
                    p_aei_information13     => rec.ayi_information13,
                    p_aei_information14     => rec.ayi_information14,
                    p_aei_information15     => rec.ayi_information15,
                    p_aei_information16     => rec.ayi_information16,
                    p_aei_information17     => rec.ayi_information17,
                    p_aei_information18     => rec.ayi_information18,
                    p_aei_information19     => rec.ayi_information19,
                    p_aei_information20     => rec.ayi_information20,
                    p_aei_information21     => rec.ayi_information21,
                    p_aei_information22     => rec.ayi_information22,
                    p_aei_information23     => rec.ayi_information23,
                    p_aei_information24     => rec.ayi_information24,
                    p_aei_information25     => rec.ayi_information25,
                    p_aei_information26     => rec.ayi_information26,
                    p_aei_information27     => rec.ayi_information27,
                    p_aei_information28     => rec.ayi_information28,
                    p_aei_information29     => rec.ayi_information29,
                    p_aei_information30     => rec.ayi_information30,
                    p_assignment_extra_info_id  => l_aei_id,
                    p_object_version_number     => l_ovn);
        end if;
      end loop;
      -- Bug 7633302
      for rec1 in csr_kr_assignment_yea_info1 loop
        --
        l_asgInfoId := null;
        l_record_name := rec1.information_type;
        -- skip any record which is empty
        if(NOT (rec1.ayi_information1 is null and
           rec1.ayi_information2 is null and
           rec1.ayi_information3 is null and
           rec1.ayi_information4 is null and
           rec1.ayi_information5 is null and
           rec1.ayi_information6 is null and
           rec1.ayi_information7 is null and
           rec1.ayi_information8 is null and
           rec1.ayi_information9 is null and
           rec1.ayi_information10 is null and
           rec1.ayi_information11 is null and
           rec1.ayi_information12 is null and
           rec1.ayi_information13 is null and
           rec1.ayi_information14 is null and
           rec1.ayi_information15 is null and
           rec1.ayi_information16 is null and
           rec1.ayi_information17 is null and
           rec1.ayi_information18 is null and
           rec1.ayi_information19 is null and
           rec1.ayi_information20 is null and
           rec1.ayi_information21 is null and
           rec1.ayi_information22 is null and
           rec1.ayi_information23 is null and
           rec1.ayi_information24 is null and
           rec1.ayi_information25 is null and
           rec1.ayi_information26 is null and
           rec1.ayi_information27 is null and
           rec1.ayi_information28 is null and
           rec1.ayi_information29 is null and
           rec1.ayi_information30 is null )) then

           hr_assignment_extra_info_api.create_assignment_extra_info(
                    p_validate          => false,
                    p_assignment_id         => rec1.assignment_id,
                    p_information_type      => rec1.information_type,
                    p_aei_information_category  => rec1.information_type,
                    p_aei_information1      => rec1.ayi_information1,
                    p_aei_information2      => rec1.ayi_information2,
                    p_aei_information3      => rec1.ayi_information3,
                    p_aei_information4      => rec1.ayi_information4,
                    p_aei_information5      => rec1.ayi_information5,
                    p_aei_information6      => rec1.ayi_information6,
                    p_aei_information7      => rec1.ayi_information7,
                    p_aei_information8      => rec1.ayi_information8,
                    p_aei_information9      => rec1.ayi_information9,
                    p_aei_information10     => rec1.ayi_information10,
                    p_aei_information11     => rec1.ayi_information11,
                    p_aei_information12     => rec1.ayi_information12,
                    p_aei_information13     => rec1.ayi_information13,
                    p_aei_information14     => rec1.ayi_information14,
                    p_aei_information15     => rec1.ayi_information15,
                    p_aei_information16     => rec1.ayi_information16,
                    p_aei_information17     => rec1.ayi_information17,
                    p_aei_information18     => rec1.ayi_information18,
                    p_aei_information19     => rec1.ayi_information19,
                    p_aei_information20     => rec1.ayi_information20,
                    p_aei_information21     => rec1.ayi_information21,
                    p_aei_information22     => rec1.ayi_information22,
                    p_aei_information23     => rec1.ayi_information23,
                    p_aei_information24     => rec1.ayi_information24,
                    p_aei_information25     => rec1.ayi_information25,
                    p_aei_information26     => rec1.ayi_information26,
                    p_aei_information27     => rec1.ayi_information27,
                    p_aei_information28     => rec1.ayi_information28,
                    p_aei_information29     => rec1.ayi_information29,
                    p_aei_information30     => rec1.ayi_information30,
                    p_assignment_extra_info_id  => l_asgInfoId,
                    p_object_version_number     => l_ovn);
        end if;

        for rec2 in csr_kr_assignment_yea_info2(rec1.assignment_yea_info_id) loop
        --
        l_record_name := rec2.information_type;
        -- skip any record which is empty
        if(NOT (rec2.ayi_information1 is null and
           rec2.ayi_information2 is null and
           rec2.ayi_information3 is null and
           rec2.ayi_information4 is null and
           rec2.ayi_information5 is null and
           rec2.ayi_information6 is null and
           rec2.ayi_information7 is null and
           rec2.ayi_information8 is null and
           rec2.ayi_information9 is null and
           rec2.ayi_information10 is null and
           rec2.ayi_information11 is null and
           rec2.ayi_information12 is null and
           rec2.ayi_information13 is null and
           rec2.ayi_information14 is null and
           rec2.ayi_information15 is null and
           rec2.ayi_information16 is null and
           rec2.ayi_information17 is null and
           rec2.ayi_information18 is null and
           rec2.ayi_information19 is null and
           rec2.ayi_information20 is null and
           rec2.ayi_information21 is null and
           rec2.ayi_information22 is null and
           rec2.ayi_information23 is null and
           rec2.ayi_information24 is null and
           rec2.ayi_information25 is null and
           rec2.ayi_information26 is null and
           rec2.ayi_information27 is null and
           rec2.ayi_information28 is null and
           rec2.ayi_information29 is null and
           rec2.ayi_information30 is null )) then

           hr_assignment_extra_info_api.create_assignment_extra_info(
                    p_validate          => false,
                    p_assignment_id         => rec2.assignment_id,
                    p_information_type      => rec2.information_type,
                    p_aei_information_category  => rec2.information_type,
                    p_aei_information1      => rec2.ayi_information1,
                    p_aei_information2      => rec2.ayi_information2,
                    p_aei_information3      => rec2.ayi_information3,
                    p_aei_information4      => rec2.ayi_information4,
                    p_aei_information5      => rec2.ayi_information5,
                    p_aei_information6      => rec2.ayi_information6,
                    p_aei_information7      => l_asgInfoId,
                    p_aei_information8      => rec2.ayi_information8,
                    p_aei_information9      => rec2.ayi_information9,
                    p_aei_information10     => rec2.ayi_information10,
                    p_aei_information11     => rec2.ayi_information11,
                    p_aei_information12     => rec2.ayi_information12,
                    p_aei_information13     => rec2.ayi_information13,
                    p_aei_information14     => rec2.ayi_information14,
                    p_aei_information15     => rec2.ayi_information15,
                    p_aei_information16     => rec2.ayi_information16,
                    p_aei_information17     => rec2.ayi_information17,
                    p_aei_information18     => rec2.ayi_information18,
                    p_aei_information19     => rec2.ayi_information19,
                    p_aei_information20     => rec2.ayi_information20,
                    p_aei_information21     => rec2.ayi_information21,
                    p_aei_information22     => rec2.ayi_information22,
                    p_aei_information23     => rec2.ayi_information23,
                    p_aei_information24     => rec2.ayi_information24,
                    p_aei_information25     => rec2.ayi_information25,
                    p_aei_information26     => rec2.ayi_information26,
                    p_aei_information27     => rec2.ayi_information27,
                    p_aei_information28     => rec2.ayi_information28,
                    p_aei_information29     => rec2.ayi_information29,
                    p_aei_information30     => rec2.ayi_information30,
                    p_assignment_extra_info_id  => l_aei_id,
                    p_object_version_number     => l_ovn);
         end if;

        end loop;
      end loop;
      -- End of Bug 7633302
      --
      for rec3 in csr_kr_assignment_yea_info3 loop
        -- Bug 8880376
        l_record_name := rec3.information_type;
        -- skip any record which is empty
        if(NOT (rec3.ayi_information1 is null and
           rec3.ayi_information2 is null and
           rec3.ayi_information3 is null and
           rec3.ayi_information4 is null and
           rec3.ayi_information5 is null and
           rec3.ayi_information6 is null and
           rec3.ayi_information7 is null and
           rec3.ayi_information8 is null and
           rec3.ayi_information9 is null and
           rec3.ayi_information10 is null and
           rec3.ayi_information11 is null and
           rec3.ayi_information12 is null and
           rec3.ayi_information13 is null and
           rec3.ayi_information14 is null and
           rec3.ayi_information15 is null and
           rec3.ayi_information16 is null and
           rec3.ayi_information17 is null and
           rec3.ayi_information18 is null and
           rec3.ayi_information19 is null and
           rec3.ayi_information20 is null and
           rec3.ayi_information21 is null and
           rec3.ayi_information22 is null and
           rec3.ayi_information23 is null and
           rec3.ayi_information24 is null and
           rec3.ayi_information25 is null and
           rec3.ayi_information26 is null and
           rec3.ayi_information27 is null and
           rec3.ayi_information28 is null and
           rec3.ayi_information29 is null and
           rec3.ayi_information30 is null )) then

           hr_assignment_extra_info_api.create_assignment_extra_info(
                    p_validate          => false,
                    p_assignment_id         => rec3.assignment_id,
                    p_information_type      => rec3.information_type,
                    p_aei_information_category  => rec3.information_type,
                    p_aei_information1      => rec3.ayi_information1,
                    p_aei_information2      => rec3.ayi_information2,
                    p_aei_information3      => rec3.ayi_information3,
                    p_aei_information4      => rec3.ayi_information4,
                    p_aei_information5      => rec3.ayi_information5,
                    p_aei_information6      => rec3.ayi_information6,
                    p_aei_information7      => rec3.ayi_information7,
                    p_aei_information8      => rec3.ayi_information8,
                    p_aei_information9      => rec3.ayi_information9,
                    p_aei_information10     => rec3.ayi_information10,
                    p_aei_information11     => rec3.ayi_information11,
                    p_aei_information12     => rec3.ayi_information12,
                    p_aei_information13     => rec3.ayi_information13,
                    p_aei_information14     => rec3.ayi_information14,
                    p_aei_information15     => rec3.ayi_information15,
                    p_aei_information16     => rec3.ayi_information16,
                    p_aei_information17     => rec3.ayi_information17,
                    p_aei_information18     => rec3.ayi_information18,
                    p_aei_information19     => rec3.ayi_information19,
                    p_aei_information20     => rec3.ayi_information20,
                    p_aei_information21     => rec3.ayi_information21,
                    p_aei_information22     => rec3.ayi_information22,
                    p_aei_information23     => rec3.ayi_information23,
                    p_aei_information24     => rec3.ayi_information24,
                    p_aei_information25     => rec3.ayi_information25,
                    p_aei_information26     => rec3.ayi_information26,
                    p_aei_information27     => rec3.ayi_information27,
                    p_aei_information28     => rec3.ayi_information28,
                    p_aei_information29     => rec3.ayi_information29,
                    p_aei_information30     => rec3.ayi_information30,
                    p_assignment_extra_info_id  => l_aei_id,
                    p_object_version_number     => l_ovn);
        end if;
      end loop;
      --
      -- End of bug 8880376
      --
      commit;
      --
    exception
      when others then
        rollback;
        p_failed_record   := l_record_name;
        p_return_status   := 'E';
        p_return_message  := sqlerrm;
    --
    end submit_yea_info;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- This functions determines whether an employee is allowed to update the YEA
    -- information provided by him based on the effective start and end dates for the
    -- entry of YEA information.
    -----------------------------------------------------------------------------------
    function update_allowed(p_business_group_id     in  number,
                            p_assignment_id         in  number,
                            p_target_year           in  number,
                            p_effective_date        in  date)
    return varchar2
    is

    -- cursor to get the Update Allowed Flag of the assignment
    cursor csr_update_allowed_flag is
    select nvl(aei_information2, 'Y')
      from per_assignment_extra_info
     where information_type     = 'KR_YEA_ENTRY_UPDATE'
       and aei_information1     = p_target_year
       and assignment_id        = p_assignment_id;


    -- cursor to check whether YEA for target year has been run for the assignment
    cursor csr_yea_exist is
    select 'Y'
      from pay_payroll_actions     ppa,
           pay_assignment_actions  paa
     where paa.assignment_id                 = p_assignment_id
       and paa.source_action_id is null
       and ppa.payroll_action_id             = paa.payroll_action_id
       and ppa.action_type                   = 'B'
       and ppa.action_status                 = 'C'
       and trunc(ppa.effective_date, 'YYYY') = trunc(p_effective_date, 'YYYY')
       and pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_TYPE', null) = 'YEA'
       and pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_QUALIFIER', null) = 'KR'
       and pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_CATEGORY', null) IN ('N','I');

    -- Cursor to get Org Structure version id of the Primary Hierarchy of the BG
    cursor csr_org_struct_version is
    select posv.org_structure_version_id
      from per_organization_structures      pos,
           per_org_structure_versions       posv
     where pos.primary_structure_flag       = 'Y'
       and pos.business_group_id            = p_business_group_id
       and pos.organization_structure_id    = posv.organization_structure_id
       and p_effective_date between posv.date_from and nvl(posv.date_to,p_effective_date);

    -- cursor fetches the entry periods of the organizations defined in the hierarchy
    -- in bottom to top order starting from the Employee's Organization.
    cursor csr_hierarchy_entry_period(p_version     in number,
                                      p_emp_org_id  in number) is
    select min(fnd_date.canonical_to_date(hoi.org_information2)),
           max(fnd_date.canonical_to_date(hoi.org_information3)),
           max(fnd_date.canonical_to_date(hoi.org_information4))
      from (select pose.organization_id_parent,
                   level hierarchy_level,
                   pose.organization_id_child
               from per_org_structure_elements pose
              start with pose.organization_id_child      = p_emp_org_id
                and pose.org_structure_version_id        = p_version
            connect by prior pose.organization_id_parent = organization_id_child
           ) org,
           hr_organization_information hoi
     where hoi.organization_id         = org.organization_id_parent
       and hoi.org_information1        = p_target_year
       and hoi.org_information_context = 'KR_YEA_ENTRY_PERIOD_ORG'
     group by organization_id_child, org.hierarchy_level
     order by org.hierarchy_level asc;

    -- cursor fetches the Entry Period defined in BG level
    cursor csr_bg_entry_period is
    select min(fnd_date.canonical_to_date(hoi.org_information2)),
           max(fnd_date.canonical_to_date(hoi.org_information3)),
           max(fnd_date.canonical_to_date(hoi.org_information4))
      from hr_organization_information hoi
     where hoi.organization_id         = p_business_group_id
       and hoi.org_information1        = p_target_year
       and hoi.org_information_context ='KR_YEA_ENTRY_PERIOD_BG';

    -- cursor fetches the Entry Period defined in Employee's Org level
    cursor csr_emp_org_entry_period (p_emp_org number) is
    select min(fnd_date.canonical_to_date(hoi.org_information2)),
           max(fnd_date.canonical_to_date(hoi.org_information3)),
           max(fnd_date.canonical_to_date(hoi.org_information4))
      from hr_organization_information hoi
     where hoi.organization_id         = p_emp_org
       and hoi.org_information1        = p_target_year
       and hoi.org_information_context ='KR_YEA_ENTRY_PERIOD_ORG';

    -- cursor to get organization id of the Employee.
    cursor csr_emp_org_id is
    select organization_id
      from per_assignments_f paf
     where assignment_id = p_assignment_id
       and p_effective_date between paf.effective_start_date and paf.effective_end_date;

    --
    l_update_allowed           varchar2(1);
    l_asg_update_allowed       varchar2(1);
    l_entry_start_date         date;
    l_entry_end_date           date;
    l_update_cut_off_date      date;
    l_emp_org_id               number;
    l_struct_version_id        number;
    l_flag                     varchar2(1);
    --
    begin

        if g_debug then
            hr_utility.set_location('pay_kr_yea_sshr_utils_pkg.update_allowed', 10);
        end if;

        l_update_allowed   := 'N';
        l_entry_start_date := null;
        l_entry_end_date   := null;

        -- check if YEA has been run for target year
        open csr_yea_exist;
        fetch csr_yea_exist into l_flag;

        if g_debug then
            hr_utility.trace('YEA Run Exists = '||l_flag);
        end if;

        if csr_yea_exist%NOTFOUND then

            -- check if Period defined in Employee's Organization.
            open csr_emp_org_id;
            fetch csr_emp_org_id into l_emp_org_id;
            close csr_emp_org_id;

            if g_debug then
                hr_utility.trace('fetching emp org entry period');
            end if;

            open csr_emp_org_entry_period(l_emp_org_id);
            fetch csr_emp_org_entry_period into
                  l_entry_start_date,
                  l_entry_end_date,
                  l_update_cut_off_date;
            close csr_emp_org_entry_period;

            if l_entry_start_date is null then
                if g_debug then
                    hr_utility.trace('Emp org entry period not found.');
                    hr_utility.trace('Fetching Entry Period from Hierarchy.');
                end if;

                -- check for periods of parent organizations in hierarchy
                open csr_org_struct_version;
                fetch csr_org_struct_version into l_struct_version_id;
                close csr_org_struct_version;

                -- check if primary hierarchy is defined
                if l_struct_version_id is not null then
                    if g_debug then
                        hr_utility.trace('Struct Version ID : ' || l_struct_version_id);
                    end if;

                    open csr_hierarchy_entry_period(l_struct_version_id,l_emp_org_id);

                    fetch csr_hierarchy_entry_period into
                          l_entry_start_date,
                          l_entry_end_date,
                          l_update_cut_off_date;
                    close csr_hierarchy_entry_period;

                end if; -- primary Hierarchy defined

                -- 4657745
                -- if entry period not found in Hierarchy, check BG Entry period
                if l_entry_start_date is null then
                    if g_debug then
                        hr_utility.trace('Entry period of Hierarchy not found.');
                        hr_utility.trace('Fetching Entry Period from BG.');
                    end if;

                    -- check for entry period of the BG
                    open csr_bg_entry_period;
                    fetch csr_bg_entry_period into
                          l_entry_start_date,
                          l_entry_end_date,
                          l_update_cut_off_date;
                    close csr_bg_entry_period;

                    if l_entry_start_date is null then

                       l_update_allowed   := 'N';

                    end if;

                end if;

            end if; -- emp org period exists.

            if g_debug then
                hr_utility.trace('l_entry_start_date    = '|| l_entry_start_date);
                hr_utility.trace('l_entry_end_date      = '|| l_entry_end_date);
                hr_utility.trace('l_update_cut_off_date = '|| l_update_cut_off_date);
            end if;


            -- compare employees effective entry period with current date
            if l_entry_start_date is null then  -- no entry period found
                l_update_allowed   := 'N';
            else
               -- if update cut-off is not defined assign last date of 4712
               if l_update_cut_off_date is null then
                  l_update_cut_off_date := to_date('31.12.4712','DD.MM.YYYY');
               end if;

               if p_effective_date between l_entry_start_date and l_entry_end_date then
                   l_update_allowed := 'Y';
               elsif p_effective_date between l_entry_end_date and l_update_cut_off_date then
                   -- check the assignment level update allowed flag.
                   l_asg_update_allowed := null;
                   open csr_update_allowed_flag;
                   fetch csr_update_allowed_flag into l_asg_update_allowed;
                   close csr_update_allowed_flag;

                   if l_asg_update_allowed = 'Y' then
                       l_update_allowed   := 'Y';
                   else
                       l_update_allowed   := 'N';
                   end if; -- assignment level update allowed

                   if g_debug then
                       hr_utility.trace('Assgn Level Update Allowed = '||l_update_allowed);
                   end if;

               end if; -- compare current date with entry period

            end if; -- entry period exists

        else
            l_update_allowed   := 'N';
        end if; -- YEA has been run

        close csr_yea_exist;

        return l_update_allowed;

    end update_allowed;
    -----------------------------------------------------------------------------------
    -- Bug : 4568233
    -- This procedure fires the fast formula KR_VAILDATE_YEA_DATE and passes few
    -- parameters for vaildation of YEA. The formula returns 10 error messages
    -- which are captured by this procedure and passed as OUT parameters.
    -----------------------------------------------------------------------------------
    procedure run_validation_formula(                                   --4644132
                        P_BUSINESS_GROUP_ID                 in varchar2,
                        P_ASSIGNMENT_ID                     in varchar2,
                        P_TARGET_YEAR                       in varchar2,
                        P_EFFECTIVE_DATE                    in varchar2,
                        P_RETURN_MESSAGE                    out nocopy varchar2,
                        P_RETURN_STATUS                     out nocopy varchar2,
                        P_FF_MESSAGE0                       out nocopy varchar2,
                        P_FF_MESSAGE1                       out nocopy varchar2,
                        P_FF_MESSAGE2                       out nocopy varchar2,
                        P_FF_MESSAGE3                       out nocopy varchar2,
                        P_FF_MESSAGE4                       out nocopy varchar2,
                        P_FF_MESSAGE5                       out nocopy varchar2,
                        P_FF_MESSAGE6                       out nocopy varchar2,
                        P_FF_MESSAGE7                       out nocopy varchar2,
                        P_FF_MESSAGE8                       out nocopy varchar2,
                        P_FF_MESSAGE9                       out nocopy varchar2,
                        P_FF_RETURN_STATUS                  out nocopy varchar2,
                        ---------------- Special tax ---------------------
                        P_EE_EDUC_EXP                       in varchar2,
                        P_HOUSING_SAVING_TYPE               in varchar2,
                        P_HOUSING_SAVING                    in varchar2,
                        P_HOUSING_PURCHASE_DATE             in varchar2,
                        P_HOUSING_LOAN_DATE                 in varchar2,
                        P_HOUSING_LOAN_REPAY                in varchar2,
                        P_LT_HOUSING_LOAN_DATE              in varchar2,
                        P_LT_HOUSING_LOAN_INTEREST_REP      in varchar2,
                        P_DONATION1                         in varchar2,
                        P_POLITICAL_DONATION1               in varchar2,
                        P_HI_PREM                           in varchar2,
                        P_POLITICAL_DONATION2               in varchar2,
                        P_POLITICAL_DONATION3               in varchar2,
                        P_DONATION2                         in varchar2,
                        P_DONATION3                         in varchar2,
                        P_MED_EXP_EMP                       in varchar2,
                        P_LT_HOUSING_LOAN_DATE_1            in varchar2,
                        P_LT_HOUSING_LOAN_INT_REPAY_1       in varchar2,
                        P_MFR_MARRIAGE_OCCASIONS            in varchar2,
                        P_MFR_FUNERAL_OCCASIONS             in varchar2,
                        P_MFR_RELOCATION_OCCASIONS          in varchar2,
                        P_EI_PREM                           in varchar2,
                        P_ESOA_DONATION                     in varchar2,
                        P_PERS_INS_NAME                     in varchar2,
                        P_PERS_INS_PREM                     in varchar2,
                        P_DISABLED_INS_PREM                 in varchar2,
                        P_MED_EXP                           in varchar2,
                        P_MED_EXP_DISABLED                  in varchar2,
                        P_MED_EXP_AGED                      in varchar2,
                        P_EE_OCCUPATION_EDUC_EXP            in varchar2,
                        ----------------- FW Tax Break --------------------
                        P_IMMIGRATION_PURPOSE               in varchar2,
                        P_CONTRACT_DATE                     in varchar2,
                        P_EXPIRY_DATE                       in varchar2,
                        P_STAX_APPLICABLE_FLAG              in varchar2,
                        P_FW_APPLICATION_DATE               in varchar2,
                        P_FW_SUBMISSION_DATE                in varchar2,
                        ----------------- OVS Tax Break -------------------
                        P_TAX_PAID_DATE                     in varchar2,
                        P_OVS_SUBMISSION_DATE               in varchar2,
                        P_KR_OVS_LOCATION                   in varchar2,
                        P_KR_OVS_WORK_PERIOD                in varchar2,
                        P_KR_OVS_RESPONSIBILITY             in varchar2,
                        P_TERRITORY_CODE                    in varchar2,
                        P_CURRENCY_CODE                     in varchar2,
                        P_TAXABLE                           in varchar2,
                        P_TAXABLE_SUBJ_TAX_BREAK            in varchar2,
                        P_TAX_BREAK_RATE                    in varchar2,
                        P_TAX_FOREIGN_CURRENCY              in varchar2,
                        P_TAX                               in varchar2,
                        P_OVS_APPLICATION_DATE              in varchar2,
                        ----------------- Tax Break Info ------------------
                        P_HOUSING_LOAN_INTEREST_REPAY       in varchar2,
                        P_STOCK_SAVING                      in varchar2,
                        P_LT_STOCK_SAVING1                  in varchar2,
                        P_LT_STOCK_SAVING2                  in varchar2,
                        ----------------- Tax Exems  ----------------------
                        P_DIRECT_CARD_EXP                   in varchar2,
                        P_DPNT_DIRECT_EXP                   in varchar2,
                        P_GIRO_TUITION_PAID_EXP             in varchar2,
                        P_CASH_RECEIPT_EXP                  in varchar2,
                        P_NP_PREM                           in varchar2,
                        P_PERS_PENSION_PREM                 in varchar2,
                        P_PERS_PENSION_SAVING               in varchar2,
                        P_INVEST_PARTNERSHIP_FIN1           in varchar2,
                        P_INVEST_PARTNERSHIP_FIN2           in varchar2,
                        P_CREDIT_CARD_EXP                   in varchar2,
                        P_EMP_STOCK_OWN_PLAN_CONTRI         in varchar2,
                        P_CREDIT_CARD_EXP_DPNT              in varchar2,
			P_PEN_PREM			    in varchar2,	-- Bug 6024342
                        P_LTCI_PREM                         in varchar2         -- Bug 7260606
              )
    is
    CURSOR csr_formula_exists(p_formula_name   VARCHAR2,
                              p_effective_date DATE)
    is
    select formula_id
    from ff_formulas_f
    where formula_name = upper(p_formula_name)
    and business_group_id = p_business_group_id
    and p_effective_date between effective_start_date and effective_end_date;
    --
    CURSOR csr_get_session_id
    is
    select session_id from fnd_sessions
    where session_id = userenv('sessionid');
    --
    CURSOR csr_get_person_id(p_assignment_id NUMBER)
    is
    select person_id
    from   per_assignments_f
    where assignment_id = p_assignment_id;
    --
    l_formula_id            NUMBER;
    l_inputs            ff_exec.inputs_t;
    l_outputs           ff_exec.outputs_t;
    l_counter           NUMBER  := 0;
    l_session_id            NUMBER  := 0;
    l_date_earned                   DATE;
    l_person_id         NUMBER ;
    l_cntr_loop         NUMBER  := 0;
    l_target_year           NUMBER  := 0;
    l_assignment_id         NUMBER;
    l_effective_date        DATE;
    l_year              NUMBER;
    --
    begin
      P_RETURN_STATUS := 'E';
      P_FF_RETURN_STATUS := 'INVALID';

      l_effective_date := fnd_date.canonical_to_date(p_effective_date);
      l_year := to_char(l_effective_date,'yyyy');
      l_assignment_id := p_assignment_id;

      OPEN csr_formula_exists('VALIDATE_YEA_DATA',l_effective_date); -- 4644132
      FETCH csr_formula_exists into l_formula_id;
      IF csr_formula_exists%NOTFOUND then
          P_RETURN_STATUS := 'S';
          return;
      END IF;
      CLOSE csr_formula_exists;
      --

      OPEN csr_get_session_id;
      FETCH csr_get_session_id into l_session_id;
      IF csr_get_session_id%NOTFOUND then
          insert into fnd_sessions(session_id,effective_date)
      values (userenv('sessionid'),l_effective_date);
      END IF;
      CLOSE csr_get_session_id;

      OPEN csr_get_person_id(l_assignment_id);
      FETCH csr_get_person_id into l_person_id;
      CLOSE csr_get_person_id;

      ff_exec.init_formula(
                  p_formula_id          =>  l_formula_id,
              p_effective_date  =>  l_effective_date,
          p_inputs      =>  l_inputs,
          p_outputs     =>  l_outputs
              );

      l_counter := l_inputs.first;
      if l_inputs is NOT NULL then
    while l_counter <= l_inputs.last loop

    if    l_inputs(l_counter).name = 'ASSIGNMENT_ID' then
          l_inputs(l_counter).value := l_assignment_id;
    elsif l_inputs(l_counter).name = 'DATE_EARNED' then
          l_inputs(l_counter).value := p_effective_date;
    elsif l_inputs(l_counter).name = 'TARGET_YEAR' then   -- 4657745
          l_inputs(l_counter).value := p_target_year;
    elsif l_inputs(l_counter).name = 'EFFECTIVE_DATE' then
          l_inputs(l_counter).value := p_effective_date;
    elsif l_inputs(l_counter).name = 'PERSON_ID' then
          l_inputs(l_counter).value := l_person_id;
    elsif l_inputs(l_counter).name = 'EE_EDUC_EXP' then
          l_inputs(l_counter).value := P_EE_EDUC_EXP;
    elsif l_inputs(l_counter).name = 'HOUSING_SAVING_TYPE' then
          l_inputs(l_counter).value := P_HOUSING_SAVING_TYPE;
    elsif l_inputs(l_counter).name = 'HOUSING_SAVING' then
          l_inputs(l_counter).value := P_HOUSING_SAVING;
    elsif l_inputs(l_counter).name = 'HOUSING_PURCHASE_DATE' then
          l_inputs(l_counter).value := P_HOUSING_PURCHASE_DATE;
    elsif l_inputs(l_counter).name = 'HOUSING_LOAN_DATE' then
          l_inputs(l_counter).value := P_HOUSING_LOAN_DATE;
    elsif l_inputs(l_counter).name = 'HOUSING_LOAN_REPAY' then
          l_inputs(l_counter).value := P_HOUSING_LOAN_REPAY;
    elsif l_inputs(l_counter).name = 'LT_HOUSING_LOAN_DATE' then
          l_inputs(l_counter).value := P_LT_HOUSING_LOAN_DATE;
    elsif l_inputs(l_counter).name = 'LT_HOUSING_LOAN_INTEREST_REPAY' then
          l_inputs(l_counter).value := P_LT_HOUSING_LOAN_INTEREST_REP;
    elsif l_inputs(l_counter).name = 'DONATION1' then
          l_inputs(l_counter).value := P_DONATION1;
    elsif l_inputs(l_counter).name = 'POLITICAL_DONATION1' then
          l_inputs(l_counter).value := P_POLITICAL_DONATION1;
    elsif l_inputs(l_counter).name = 'HI_PREM' then
          l_inputs(l_counter).value := P_HI_PREM;
    elsif l_inputs(l_counter).name = 'POLITICAL_DONATION2' then
          l_inputs(l_counter).value := P_POLITICAL_DONATION2;
    elsif l_inputs(l_counter).name = 'POLITICAL_DONATION3' then
          l_inputs(l_counter).value := P_POLITICAL_DONATION3;
    elsif l_inputs(l_counter).name = 'DONATION2' then
          l_inputs(l_counter).value := P_DONATION2;
    elsif l_inputs(l_counter).name = 'DONATION3' then
          l_inputs(l_counter).value := P_DONATION3;
    elsif l_inputs(l_counter).name = 'MED_EXP_EMP' then
          l_inputs(l_counter).value := P_MED_EXP_EMP;
    elsif l_inputs(l_counter).name = 'LT_HOUSING_LOAN_DATE_1' then
          l_inputs(l_counter).value := P_LT_HOUSING_LOAN_DATE_1;
    elsif l_inputs(l_counter).name = 'LT_HOUSING_LOAN_INT_REPAY_1' then
          l_inputs(l_counter).value := P_LT_HOUSING_LOAN_INT_REPAY_1;
    elsif l_inputs(l_counter).name = 'MFR_MARRIAGE_OCCASIONS' then
          l_inputs(l_counter).value := P_MFR_MARRIAGE_OCCASIONS;
    elsif l_inputs(l_counter).name = 'MFR_FUNERAL_OCCASIONS' then
          l_inputs(l_counter).value := P_MFR_FUNERAL_OCCASIONS;
    elsif l_inputs(l_counter).name = 'MFR_RELOCATION_OCCASIONS' then
          l_inputs(l_counter).value := P_MFR_RELOCATION_OCCASIONS;
    elsif l_inputs(l_counter).name = 'EI_PREM' then
          l_inputs(l_counter).value := P_EI_PREM;
    elsif l_inputs(l_counter).name = 'ESOA_DONATION' then
          l_inputs(l_counter).value := P_ESOA_DONATION;
    elsif l_inputs(l_counter).name = 'PERS_INS_NAME' then
          l_inputs(l_counter).value := P_PERS_INS_NAME;
    elsif l_inputs(l_counter).name = 'PERS_INS_PREM' then
          l_inputs(l_counter).value := P_PERS_INS_PREM;
    elsif l_inputs(l_counter).name = 'DISABLED_INS_PREM' then
          l_inputs(l_counter).value := P_DISABLED_INS_PREM;
    elsif l_inputs(l_counter).name = 'MED_EXP' then
          l_inputs(l_counter).value := P_MED_EXP;
    elsif l_inputs(l_counter).name = 'MED_EXP_DISABLED' then
          l_inputs(l_counter).value := P_MED_EXP_DISABLED;
    elsif l_inputs(l_counter).name = 'MED_EXP_AGED' then
          l_inputs(l_counter).value := P_MED_EXP_AGED;
    elsif l_inputs(l_counter).name = 'EE_OCCUPATION_EDUC_EXP' then
          l_inputs(l_counter).value := P_EE_OCCUPATION_EDUC_EXP;


    elsif l_inputs(l_counter).name = 'IMMIGRATION_PURPOSE' then
          l_inputs(l_counter).value := P_IMMIGRATION_PURPOSE;
    elsif l_inputs(l_counter).name = 'CONTRACT_DATE' then
          l_inputs(l_counter).value := P_CONTRACT_DATE;
    elsif l_inputs(l_counter).name = 'EXPIRY_DATE' then
          l_inputs(l_counter).value := P_EXPIRY_DATE;
    elsif l_inputs(l_counter).name = 'STAX_APPLICABLE_FLAG' then
          l_inputs(l_counter).value := P_STAX_APPLICABLE_FLAG;
    elsif l_inputs(l_counter).name = 'FWTB_APPLICATION_DATE' then
          l_inputs(l_counter).value := P_FW_APPLICATION_DATE;
    elsif l_inputs(l_counter).name = 'FWTB_SUBMISSION_DATE' then
          l_inputs(l_counter).value := P_FW_SUBMISSION_DATE;


    elsif l_inputs(l_counter).name = 'TAX_PAID_DATE' then
          l_inputs(l_counter).value := P_TAX_PAID_DATE;
    elsif l_inputs(l_counter).name = 'OTB_SUBMISSION_DATE' then
          l_inputs(l_counter).value := P_OVS_SUBMISSION_DATE;
    elsif l_inputs(l_counter).name = 'KR_OVS_LOCATION' then
          l_inputs(l_counter).value := P_KR_OVS_LOCATION;
    elsif l_inputs(l_counter).name = 'KR_OVS_WORK_PERIOD' then
          l_inputs(l_counter).value := P_KR_OVS_WORK_PERIOD;
    elsif l_inputs(l_counter).name = 'KR_OVS_RESPONSIBILITY' then
          l_inputs(l_counter).value := P_KR_OVS_RESPONSIBILITY;
    elsif l_inputs(l_counter).name = 'TERRITORY_CODE' then
          l_inputs(l_counter).value := P_TERRITORY_CODE;
    elsif l_inputs(l_counter).name = 'CURRENCY_CODE' then
          l_inputs(l_counter).value := P_CURRENCY_CODE;
    elsif l_inputs(l_counter).name = 'TAXABLE' then
          l_inputs(l_counter).value := P_TAXABLE;
    elsif l_inputs(l_counter).name = 'TAXABLE_SUBJ_TAX_BREAK' then
          l_inputs(l_counter).value := P_TAXABLE_SUBJ_TAX_BREAK;
    elsif l_inputs(l_counter).name = 'TAX_BREAK_RATE' then
          l_inputs(l_counter).value := P_TAX_BREAK_RATE;
    elsif l_inputs(l_counter).name = 'TAX_FOREIGN_CURRENCY' then
          l_inputs(l_counter).value := P_TAX_FOREIGN_CURRENCY;
    elsif l_inputs(l_counter).name = 'TAX' then
          l_inputs(l_counter).value := P_TAX;
    elsif l_inputs(l_counter).name = 'OTB_APPLICATION_DATE' then
          l_inputs(l_counter).value := P_OVS_APPLICATION_DATE;


    elsif l_inputs(l_counter).name = 'HOUSING_LOAN_INTEREST_REPAY' then
          l_inputs(l_counter).value := P_HOUSING_LOAN_INTEREST_REPAY;
    elsif l_inputs(l_counter).name = 'STOCK_SAVING' then
          l_inputs(l_counter).value := P_STOCK_SAVING;
    elsif l_inputs(l_counter).name = 'LT_STOCK_SAVING1' then
          l_inputs(l_counter).value := P_LT_STOCK_SAVING1;
    elsif l_inputs(l_counter).name = 'LT_STOCK_SAVING2' then
          l_inputs(l_counter).value := P_LT_STOCK_SAVING2;


    elsif l_inputs(l_counter).name = 'DIRECT_CARD_EXP' then
          l_inputs(l_counter).value := P_DIRECT_CARD_EXP;
    elsif l_inputs(l_counter).name = 'DPNT_DIRECT_EXP' then
          l_inputs(l_counter).value := P_DPNT_DIRECT_EXP;
    elsif l_inputs(l_counter).name = 'GIRO_TUITION_PAID_EXP' then
          l_inputs(l_counter).value := P_GIRO_TUITION_PAID_EXP;
    elsif l_inputs(l_counter).name = 'CASH_RECEIPT_EXP' then
          l_inputs(l_counter).value := P_CASH_RECEIPT_EXP;
    elsif l_inputs(l_counter).name = 'NP_PREM' then
          l_inputs(l_counter).value := P_NP_PREM;
    elsif l_inputs(l_counter).name = 'PERS_PENSION_PREM' then
          l_inputs(l_counter).value := P_PERS_PENSION_PREM;
    elsif l_inputs(l_counter).name = 'PERS_PENSION_SAVING' then
          l_inputs(l_counter).value := P_PERS_PENSION_SAVING;
    elsif l_inputs(l_counter).name = 'INVEST_PARTNERSHIP_FIN1' then
          l_inputs(l_counter).value := P_INVEST_PARTNERSHIP_FIN1;
    elsif l_inputs(l_counter).name = 'INVEST_PARTNERSHIP_FIN2' then
          l_inputs(l_counter).value := P_INVEST_PARTNERSHIP_FIN2;
    elsif l_inputs(l_counter).name = 'CREDIT_CARD_EXP' then
          l_inputs(l_counter).value := P_CREDIT_CARD_EXP;
    elsif l_inputs(l_counter).name = 'EMP_STOCK_OWN_PLAN_CONTRI' then
          l_inputs(l_counter).value := P_EMP_STOCK_OWN_PLAN_CONTRI;
    elsif l_inputs(l_counter).name = 'CREDIT_CARD_EXP_DPNT' then
          l_inputs(l_counter).value := P_CREDIT_CARD_EXP_DPNT;
    elsif l_inputs(l_counter).name = 'PEN_PREM' then			-- Bug 6024342
          l_inputs(l_counter).value := P_PEN_PREM;
    elsif l_inputs(l_counter).name = 'LTCI_PREM' then			-- Bug 7260606
          l_inputs(l_counter).value := P_LTCI_PREM;
    end if;
    l_counter := l_inputs.next(l_counter);
    end loop;
      end if;

      ff_exec.run_formula(l_inputs, l_outputs);
    --get outputs
      if l_outputs is not NULL then
    for l_counter in l_outputs.first..l_outputs.last loop
    if    l_outputs(l_counter).name = 'STATUS' then
        P_FF_RETURN_STATUS := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 0 then
        P_FF_MESSAGE0 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 1 then
        P_FF_MESSAGE1 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 2 then
        P_FF_MESSAGE2 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 3 then
        P_FF_MESSAGE3 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 4 then
        P_FF_MESSAGE4 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 5 then
        P_FF_MESSAGE5 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 6 then
        P_FF_MESSAGE6 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 7 then
        P_FF_MESSAGE7 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 8 then
        P_FF_MESSAGE8 := trim(l_outputs(l_counter).value);
    elsif  l_cntr_loop = 9 then
        P_FF_MESSAGE9 := trim(l_outputs(l_counter).value);
    end if;
    l_cntr_loop := l_cntr_loop + 1;
    end loop;
      end if;
      --
      if P_FF_RETURN_STATUS = 'VALID' then
     P_RETURN_STATUS := 'S';
      else
     P_RETURN_STATUS  := 'E';
         P_RETURN_MESSAGE := 'PAY_KR_YEA_DATA_INVALID_MSG';
      end if;

      --
      end run_validation_formula;
    -----------------------------------------------------------------------------------
    -- This procedure toggles the UPDATE_ALLOWED flag in the Extra Assignment Info
    -- Type KR_YEA_ENTRY_UPDATE
    -----------------------------------------------------------------------------------
    procedure change_access(P_ASSIGNMENT_ID                     in varchar2,
                            P_TARGET_YEAR                       in varchar2,
                            P_RESULT                            out nocopy varchar2)
    is
        cursor csr_access is
        select nvl(aei_information2,'Y') update_allowed,
               assignment_extra_info_id  info_id
        from  per_assignment_extra_info
        where assignment_id      = P_ASSIGNMENT_ID
        and   information_type   = 'KR_YEA_ENTRY_UPDATE'
        and   aei_information1   = P_TARGET_YEAR
        for update nowait;

        l_current_access  varchar2(5);
        l_future_access   varchar2(5);
        l_record_present  varchar2(5);
        l_info_id         number;

    begin
        open csr_access;
        fetch csr_access into l_current_access, l_info_id;
        if csr_access%NOTFOUND then
            l_record_present := 'N';
            l_current_access := 'N';
        else
            l_record_present := 'Y';
        end if;
        close csr_access;

        if l_record_present = 'N' then -- create a record
            insert into per_assignment_extra_info(
                assignment_extra_info_id,
                assignment_id,
                aei_information1,
                aei_information2,
                information_type,
                aei_information_category)
            values(
                per_assignment_extra_info_s.nextval,
                P_ASSIGNMENT_ID,
                P_TARGET_YEAR,
                'Y',
                'KR_YEA_ENTRY_UPDATE',
                'KR_YEA_ENTRY_UPDATE');
            P_RESULT  := 'Y';
        else    -- update the record
            if l_current_access = 'N' then
               l_future_access := 'Y';
            else
               l_future_access := 'N';
            end if;

            update per_assignment_extra_info
            set aei_information2 = l_future_access
            where assignment_extra_info_id = l_info_id;

            P_RESULT  := l_future_access;
        end if;
        commit;

        exception
          when others then rollback;
          raise;
    end change_access;
    -----------------------------------------------------------------------------------
    -- This procedure is used to fetch all the balance values required.
    -- Bug 5372366: Updated to fetch balances P_HI_PREM_EE and P_EI_PREM
    -----------------------------------------------------------------------------------
    procedure get_balances(P_ASSIGNMENT_ID                     in varchar2,
                           P_TARGET_YEAR                       in varchar2,
                           P_EFFECTIVE_DATE                    in varchar2,
                           P_ITAX                              out nocopy varchar2,
                           P_STAX                              out nocopy varchar2,
                           P_RTAX                              out nocopy varchar2,
                           P_TAXABLE                           out nocopy varchar2,
                           P_OVS_PROCESSED                     out nocopy varchar2,
                           P_TOTAL_TAXABLE_KRW                 out nocopy varchar2,
                           P_HI_PREM_EE                        out nocopy varchar2,  -- Bug 5372366
                           P_EI_PREM                           out nocopy varchar2,  -- Bug 5372366
                           P_NP_PREM_EE                        out nocopy varchar2,  -- Bug 5185309
			   P_PEN_PREM_BAL                      out nocopy varchar2,  -- Bug 6024342
                           P_LTCI_PREM_EE                      out nocopy varchar2)  -- Bug 7260606
    is
        --
        eff_date date ;
        l_def_bal_id    pay_defined_balances.defined_balance_id%type ;
        --
    begin
        eff_date := fnd_date.canonical_to_date(P_EFFECTIVE_DATE);
        --
        P_ITAX                     := get_total_itax(P_ASSIGNMENT_ID, eff_date);
        P_STAX                     := get_total_stax(P_ASSIGNMENT_ID, eff_date);
        P_RTAX                     := get_total_rtax(P_ASSIGNMENT_ID, eff_date);
        P_TAXABLE                  := get_total_taxable(P_ASSIGNMENT_ID, eff_date);
        P_OVS_PROCESSED            := get_ovs_processed(P_ASSIGNMENT_ID, eff_date);
        --
        open csr_get_def_bal_id_ytd('HI_PREM_EE') ;
        fetch csr_get_def_bal_id_ytd into l_def_bal_id ;
        if csr_get_def_bal_id_ytd%found then
                p_hi_prem_ee := pay_balance_pkg.get_value(l_def_bal_id,
                                        p_assignment_id, fnd_date.canonical_to_date(p_effective_date) ) ;
        end if ;
        close csr_get_def_bal_id_ytd ;
        --
        -- Bug 7260606
        open csr_get_def_bal_id_ytd('LTCI_PREM_EE') ;
        fetch csr_get_def_bal_id_ytd into l_def_bal_id ;
        if csr_get_def_bal_id_ytd%found then
                p_ltci_prem_ee := pay_balance_pkg.get_value(l_def_bal_id,
                                        p_assignment_id, fnd_date.canonical_to_date(p_effective_date) ) ;
        end if ;
        close csr_get_def_bal_id_ytd ;
        -- End of Bug 7260606
        --
        open csr_get_def_bal_id_ytd('EI_PREM') ;
        fetch csr_get_def_bal_id_ytd into l_def_bal_id ;
        if csr_get_def_bal_id_ytd%found then
                p_ei_prem := pay_balance_pkg.get_value(l_def_bal_id,
                                        p_assignment_id, fnd_date.canonical_to_date(p_effective_date) ) ;
        end if ;
        close csr_get_def_bal_id_ytd ;
        --
        open csr_get_def_bal_id_ytd('NP_PREM_EE') ;
        fetch csr_get_def_bal_id_ytd into l_def_bal_id ;
        if csr_get_def_bal_id_ytd%found then
                p_np_prem_ee := pay_balance_pkg.get_value(l_def_bal_id,
                                        p_assignment_id, fnd_date.canonical_to_date(p_effective_date) ) ;
        end if ;
        close csr_get_def_bal_id_ytd ;
        --
	-- Bug 6024342
	open csr_get_def_bal_id_ytd('Pension Premium') ;
        fetch csr_get_def_bal_id_ytd into l_def_bal_id ;
        if csr_get_def_bal_id_ytd%found then
                p_pen_prem_bal := pay_balance_pkg.get_value(l_def_bal_id,
                                        p_assignment_id, fnd_date.canonical_to_date(p_effective_date) ) ;
        end if ;
        close csr_get_def_bal_id_ytd ;
    --
    end get_balances;
    -----------------------------------------------------------------------------------
    -- This procedure delete the YEA Data for the target year of an assignment.
    -----------------------------------------------------------------------------------
    procedure delete_all_records(
                           P_ASSIGNMENT_ID                     in varchar2,
                           P_TARGET_YEAR                       in varchar2)
    is
    --
    -- Bug 9326153
    --
      cursor csr_delete
      is
      select assignment_extra_info_id,object_version_number
      from per_assignment_extra_info
      where assignment_id = p_assignment_id
      and to_number(to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY')) = p_target_year
      And information_type in       ('KR_YEA_SP_TAX_EXEM_INFO'
                                    ,'KR_YEA_SP_TAX_EXEM_INFO2'
                                    ,'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
                                    ,'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
                                    ,'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
                                    ,'KR_YEA_PREV_ER_INFO'
                                    ,'KR_YEA_TAX_BREAK_INFO'
                                    ,'KR_YEA_TAX_EXEM_INFO'
                                    ,'KR_YEA_OVS_TAX_BREAK_INFO'
                                    ,'KR_YEA_DETAIL_DONATION_INFO'
                                    ,'KR_YEA_EMP_EXPENSE_DETAILS'
      				    ,'KR_YEA_TAX_GROUP_INFO'
      				    ,'KR_YEA_NON_TAXABLE_EARN_DETAIL'
				    ,'KR_YEA_DONATION_TYPE_DETAIL');
    --
    begin
    --
    -- Bug 9326153
      for i in csr_delete loop
      --
      hr_assignment_extra_info_api.delete_assignment_extra_info(
      		p_validate			=> false,
      		p_assignment_extra_info_id	=> i.assignment_extra_info_id,
		p_object_version_number		=> i.object_version_number);
      end loop;
      --
      commit;
    end;
    -----------------------------------------------------------------------------------
    -- This procedure gets the Dependent Information for an Employee
    -----------------------------------------------------------------------------------
    procedure get_dependent_information(
                           P_ASSIGNMENT_ID                     in varchar2,
                           P_EFFECTIVE_DATE                    in varchar2,
                           P_SPOUSE_EXEM                       out nocopy varchar2,
                           P_AGED_DEPENDENTS                   out nocopy varchar2,
                           P_ADULT_DEPENDENTS                  out nocopy varchar2,
                           P_UNDERAGED_DEPENDENTS              out nocopy varchar2,
                           P_TOTAL_DEPENDENTS                  out nocopy varchar2,
                           P_TOTAL_AGEDS                       out nocopy varchar2,
                           P_TOTAL_DISABLED                    out nocopy varchar2,
                           P_FEMALE_EXEM                       out nocopy varchar2,
                           P_TOTAL_CHILDREN                    out nocopy varchar2,
                           P_TOTAL_SUPER_AGEDS                 out nocopy varchar2,
			   P_NEW_BORN_ADOPTED                  out nocopy varchar2, -- Bug  6705170
                           P_HOUSE_HOLDER                      out nocopy varchar2,
                           P_HOUSE_HOLDER_CODE                 out nocopy varchar2)
    is
        l_return_code		NUMBER;
        l_spouse_exem           VARCHAR2(1);
        l_aged_dependents       NUMBER;
        l_adult_dependents      NUMBER;
        l_underaged_dpnts       NUMBER;
        l_total_dependents      NUMBER;
        l_total_ageds           NUMBER;
        l_total_disableds       NUMBER;
        l_female_exem           VARCHAR2(1);
        l_total_children        NUMBER;
        l_total_super_ageds     NUMBER;
	l_new_born_adopted      NUMBER; -- Bug 6705170
	l_total_addtl_child     NUMBER; -- Bug 6784288
        l_nonresident_flag      VARCHAR2(1);

    CURSOR csr_get_non_resident_flag(p_assignment_id in number,
                                     p_effective_date in DATE) is
      select peev.screen_entry_value
      from pay_element_entries_f pee,
           pay_element_entry_values_f peev,
           pay_input_values_f piv,
           pay_element_types_f pet
      where pet.element_name = 'TAX'
        and pet.legislation_code = 'KR'
        and pee.entry_type = 'E'
        and pet.element_type_id = piv.element_type_id
        and piv.name = 'NON_RESIDENT_FLAG'
        and pee.element_entry_id = peev.element_entry_id
        and piv.input_value_id = peev.input_value_id
        and pee.assignment_id = p_assignment_id
        and p_effective_date between pee.effective_start_date and pee.effective_end_date
        and p_effective_date between peev.effective_start_date and peev.effective_end_date
        and p_effective_date between piv.effective_start_date and piv.effective_end_date;


    cursor csr_house_holder(p_assgn_id in number, p_eff_date in date) is
    select nvl(pei.PEI_INFORMATION3,'N')
      from PER_PEOPLE_EXTRA_INFO pei,
           per_assignments_f     paf
     where paf.assignment_id  = p_assgn_id
       and p_eff_date between paf.effective_start_date and paf.effective_end_DATE
       and pei.person_id      = paf.person_id
       and information_type   = 'PER_KR_RELATED_YEA_INFORMATION';

    --
    -- Bug 9246066: Updated to display terminated employee information in SSHR YEA
    --
    cursor csr_get_eff_date(p_assgn_id in number, p_eff_date in date) is
    select nvl(ppos.final_process_date,p_eff_date)
      from per_assignments_f		asg,
           per_periods_of_service       ppos
     where asg.assignment_id = p_assgn_id
       and ppos.period_of_service_id = asg.period_of_service_id
       and nvl(ppos.final_process_date,p_eff_date) between asg.effective_start_date and asg.effective_end_date;

    l_final_eff_date date;
    final_eff_date date;
    --
    begin

        -- Bug 9246066

	l_final_eff_date := null;
	final_eff_date := null;

        open csr_get_eff_date(p_assignment_id, fnd_date.canonical_to_date(p_effective_date));
        fetch csr_get_eff_date into l_final_eff_date;
        close csr_get_eff_date;

        if to_char(l_final_eff_date,'YYYY') = to_char(fnd_date.canonical_to_date(p_effective_date),'YYYY') then
            final_eff_date := l_final_eff_date;
        else
            final_eff_date := fnd_date.canonical_to_date(p_effective_date);
        end if;
        -- End of bug 9246066

	OPEN csr_get_non_resident_flag(to_number(P_ASSIGNMENT_ID),final_eff_date);        -- Bug 9246066
        FETCH csr_get_non_resident_flag into l_nonresident_flag;
        CLOSE csr_get_non_resident_flag;
        --

        p_house_holder_code := null;
        open csr_house_holder(p_assignment_id, final_eff_date);        -- Bug 9246066
        fetch csr_house_holder into p_house_holder_code;
        close csr_house_holder;

        if p_house_holder_code is null then
            p_house_holder_code := 'N';
        end if;

        p_house_holder := hr_general.decode_lookup('YES_NO', p_house_holder_code);

        l_return_code :=
            pay_kr_ff_functions_pkg.get_dependent_info(
                p_assignment_id          => to_number(P_ASSIGNMENT_ID),
                p_date_earned            => final_eff_date,        	-- Bug 9246066
                p_non_resident_flag      => l_nonresident_flag,
                p_dpnt_spouse_flag       => l_spouse_exem,
                p_num_of_aged_dpnts      => l_aged_dependents,
                p_num_of_adult_dpnts     => l_adult_dependents,
                p_num_of_underaged_dpnts => l_underaged_dpnts,
                p_num_of_dpnts	         => l_total_dependents,
                p_num_of_ageds           => l_total_ageds,
                p_num_of_disableds       => l_total_disableds,
                p_female_ee_flag         => l_female_exem,
                p_num_of_children        => l_total_children,
                p_num_of_super_ageds     => l_total_super_ageds,
		p_num_of_new_born_adopted => l_new_born_adopted,    -- Bug 6705170
		p_num_of_addtl_child     => l_total_addtl_child);   -- Bug 6784288
         --
         if l_return_code = 0 then
           P_SPOUSE_EXEM          := hr_general.decode_lookup('YES_NO',l_spouse_exem);
           P_AGED_DEPENDENTS      := to_char(l_aged_dependents);
           P_ADULT_DEPENDENTS     := to_char(l_adult_dependents);
           P_UNDERAGED_DEPENDENTS := to_char(l_underaged_dpnts);
           P_TOTAL_DEPENDENTS     := to_char(l_total_dependents);
           P_TOTAL_AGEDS          := to_char(l_total_ageds);
           P_TOTAL_DISABLED       := to_char(l_total_disableds);
           P_FEMALE_EXEM          := hr_general.decode_lookup('YES_NO',l_female_exem);
           P_TOTAL_CHILDREN       := to_char(l_total_children);
           P_TOTAL_SUPER_AGEDS    := to_char(l_total_super_ageds);
	   P_NEW_BORN_ADOPTED     := to_char(l_new_born_adopted);
        end if;
        --
      end;

    ------------------------------------------------------------------------------------
    -- This procedure updates House Holder flag. Creates Extra Info Records if necessary
    ------------------------------------------------------------------------------------

    procedure update_house_holder(p_person_id          in varchar2,
                                  p_house_holder_code  in varchar2)
    is

    cursor csr_record_exist(p_per_id in varchar2) is
    select person_extra_info_id, object_version_number
      from per_people_extra_info
     where person_id        = p_per_id
       and information_type = 'PER_KR_RELATED_YEA_INFORMATION';

    l_information_type   varchar2(100);
    l_pei_id             number;
    l_ovn                number;

    begin

        l_information_type := 'PER_KR_RELATED_YEA_INFORMATION';
        l_ovn              := null;
        l_pei_id           := null;

        open csr_record_exist(p_person_id);
        fetch csr_record_exist into l_pei_id,l_ovn;
        close csr_record_exist;

        if l_pei_id is null then  -- need to create a record
            hr_person_extra_info_api.create_person_extra_info(
                p_validate                      => false,
                p_person_id                     => p_person_id,
                p_information_type              => l_information_type,
                p_pei_information_category      => l_information_type,
                p_pei_information1              => 'N',
                p_pei_information2              => 'R',
                p_pei_information3              => p_house_holder_code,
                p_person_extra_info_id          => l_pei_id,
                p_object_version_number         => l_ovn);
        else
            hr_person_extra_info_api.update_person_extra_info(
                p_validate                      => false,
                p_person_extra_info_id          => l_pei_id,
                p_object_version_number         => l_ovn,
                p_pei_information3              => p_house_holder_code);

        end if;
        commit;

    exception
        when others then rollback;
        raise;
    end;

    ------------------------------------------------------------------------------------
    -- Bug 6849941: Credit Card Validation Checks
    ------------------------------------------------------------------------------------
    procedure enable_credit_card(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         varchar2,
	p_result			out nocopy varchar2)
    is
    begin

    p_result := pay_kr_ff_functions_pkg.enable_credit_card(
		p_person_id,
		p_contact_person_id,
		p_contact_relationship_id,
		to_date(p_date_earned,'YYYY-MM-DD'));

    end;
    ------------------------------------------------------------------------------------
    -- Bug 7142612
    ------------------------------------------------------------------------------------
    procedure enable_donation_fields(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         varchar2,
	p_result			out nocopy varchar2)
    is
    begin

    p_result := pay_kr_ff_functions_pkg.enable_donation_fields(
		p_person_id,
		p_contact_person_id,
		p_contact_relationship_id,
		to_date(p_date_earned,'YYYY-MM-DD'));
    end;
    ------------------------------------------------------------------------------------
    -- Bug 7142612
    ------------------------------------------------------------------------------------
    procedure validate_bus_reg_num(
	p_national_identifier in varchar2,
	p_result	      out nocopy varchar2)
    is
    begin
    p_result := pay_kr_ff_functions_pkg.validate_bus_reg_num(
		p_national_identifier);

    end;
    ------------------------------------------------------------------------------------
    -- Bug 7633302
    ------------------------------------------------------------------------------------
    procedure detail_exists(
    	p_ayi_information6		in	 number,
    	p_assignment_id			in	 number,
    	p_target_year			in	 number,
    	p_result			out nocopy varchar2)
    is
    	cursor csr is
    	select count(*)
    	from PER_KR_ASSIGNMENT_YEA_INFO
    	where assignment_id = p_assignment_id
    	and information_type = 'KR_YEA_DONATION_TYPE_DETAIL'
    	and target_year = p_target_year
    	and Ayi_information6 = p_ayi_information6;
    	--
	l_dummy number;
    --
    begin
    	l_dummy := 0;
    	open csr;
    	fetch csr into l_dummy;
    	close csr;

	if l_dummy > 0 then
	   p_result := 'Y';
	else
	   p_result := 'N';
	end if;

    end;
------------------------------------------------------------------------------------
-- Bug 7633302
------------------------------------------------------------------------------------
    procedure chk_taxation_period_unique(
    	p_assignment_yea_info_id	in	 number,
    	p_assignment_id			in	 number,
	p_ayi_information2		in	 varchar2,
	p_ayi_information6		in	 varchar2,	-- Bug 9213683
    	p_target_year			in	 number,
    	p_result			out nocopy varchar2)
    is

    	cursor csr is
    	select  count(ayi_information2)
    	from    per_kr_assignment_yea_info
    	where   assignment_id = p_assignment_id
    	and     assignment_yea_info_id <> p_assignment_yea_info_id
    	and     information_type = 'KR_YEA_DONATION_TYPE_DETAIL'
    	and     ayi_information2 = p_ayi_information2
	and 	ayi_information6 = p_ayi_information6	-- Bug 9213683
    	and     target_year = p_target_year;
    	--
	l_dummy number;
    --
    begin
    --
    	l_dummy := 0;
    	open csr;
    	fetch csr into l_dummy;
    	close csr;

	if l_dummy > 0 then
	   p_result := 'Y';
	else
	   p_result := 'N';
	end if;

    end;
--
------------------------------------------------------------------------------------
-- Bug 9079450
------------------------------------------------------------------------------------
procedure aged_flag(
		    p_national_identifier 	in varchar2,
                    p_effective_date		in varchar2,
		    p_result			out nocopy varchar2)
is

cursor csr is
select pay_kr_ff_functions_pkg.aged_flag(p_national_identifier,fnd_date.canonical_to_date(p_effective_date))
from dual;

begin

open csr;
fetch csr into p_result;
close csr;

end;
------------------------------------------------------------------------------------
/* 9294813 */
    procedure insert_fnd_sessions( p_effective_date   in varchar2
			      )
    is
       cursor csr_get_session_id is
       select 	session_id
       from 	fnd_sessions
       where 	session_id = userenv('sessionid');
       l_session_id	number ;
      begin

	-- Insert a row into fnd_sessions if reqd
      open 	csr_get_session_id;
      fetch 	csr_get_session_id into l_session_id;
      if csr_get_session_id%notfound then
		insert into fnd_sessions(session_id,effective_date)
		values (userenv('sessionid'),fnd_date.canonical_to_date(p_effective_date));
      end if;
      close 	csr_get_session_id;

  end insert_fnd_sessions;
--------------------------------------------------------------------------------------
end pay_kr_yea_sshr_utils_pkg;

/
