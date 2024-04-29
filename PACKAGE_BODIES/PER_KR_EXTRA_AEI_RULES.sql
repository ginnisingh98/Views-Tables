--------------------------------------------------------
--  DDL for Package Body PER_KR_EXTRA_AEI_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_EXTRA_AEI_RULES" as
/* $Header: pekrexae.pkb 120.0.12010000.12 2010/01/27 13:46:33 vaisriva ship $ */
--
procedure chk_information_type_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2)
is
  l_effective_date  date;
  l_dummy           varchar2(1);
  cursor csr_lck is
    select  null
    from    per_periods_of_service  pds,
            per_assignments_f       asg
    where   asg.assignment_id = p_assignment_id
    and     l_effective_date
            between effective_start_date and effective_end_date
    and     pds.period_of_service_id = asg.period_of_service_id
    for update of pds.period_of_service_id nowait;
  cursor csr_unique is
    select  'Y'
    from    dual
    where   not exists(
              select  null
              from    per_assignment_extra_info
              where   assignment_id = p_assignment_id
              and     assignment_extra_info_id <> p_assignment_extra_info_id
              and     information_type = p_information_type
              and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(l_effective_date, 'YYYY'));
begin
  if p_information_type in ('KR_YEA_SP_TAX_EXEM_INFO',
                            'KR_YEA_TAX_EXEM_INFO',
                            'KR_YEA_TAX_BREAK_INFO',
                            'KR_YEA_OVS_TAX_BREAK_INFO') then
    l_effective_date := fnd_date.canonical_to_date(p_aei_information1);
    --
    -- Lock first assignment record in this calendar year
    -- to guarantee uniqueness.
    --
    open csr_lck;
    close csr_lck;
    --
    -- Check whether the information_type is unique.
    --
    open csr_unique;
    fetch csr_unique into l_dummy;
    if csr_unique%NOTFOUND then
      close csr_unique;
      fnd_message.set_name('PAY', 'PAY_KR_AEI_TYPE_UNIQUE_ERROR');
      fnd_message.raise_error;
    end if;
    close csr_unique;
  end if;
end chk_information_type_unique;
-----------------------------------------------------------------------------
-- Bug 7142612
-----------------------------------------------------------------------------
procedure chk_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information3          in varchar2,
            p_aei_information12          in varchar2,
            p_aei_information13          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(l_aei_information12 in varchar2,l_aei_information13 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information12 = l_aei_information12
	and     aei_information13 = l_aei_information13
	and     aei_information15 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(l_aei_information12 in varchar2,l_aei_information13 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information12 = l_aei_information12
	and     aei_information13 = l_aei_information13
	and     aei_information15 = '2'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	contact_relationship_id, national_identifier,
        decode(nvl(cont_information11,decode(contact_type, 'S','3',
		'A','4','C','4','R','4','O','4','T','4','6') ),'4','3','3','2','7','3','6') code		-- Bug 9213683
	from    pay_kr_contact_v
	where   assignment_id = p_assignment_id;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
     and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_rel_code varchar2(10);
	l_ni_number varchar2(20);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type = 'KR_YEA_DETAIL_DONATION_INFO' and p_aei_information12 in ('3','2','1') then
	--
           l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1),'YYYY'),12) - 1;
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			l_rel_code    := i.code;
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_nts_amt,
				      	             p_cei_information15        => l_oth_amt,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_nts_amt,
				      	             p_cei_information15        => l_oth_amt,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	end if;
	--
end chk_insert_update;
--
-----------------------------------------------------------------------------
-- Bug 7142612
-----------------------------------------------------------------------------
procedure chk_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2,
            p_aei_information3_o          in varchar2,
            p_aei_information12_o          in varchar2,
            p_aei_information13_o          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(l_aei_information12 in varchar2,l_aei_information13 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information12 = l_aei_information12
	and     aei_information13 = l_aei_information13
	and     aei_information15 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(l_aei_information12 in varchar2,l_aei_information13 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information12 = l_aei_information12
	and     aei_information13 = l_aei_information13
	and     aei_information15 = '2'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	contact_relationship_id, national_identifier,
        decode(nvl(cont_information11,decode(contact_type, 'S','3',
		'A','4','C','4','R','4','O','4','T','4','6') ),'4','3','3','2','7','3','6') code		-- Bug 9213683
	from    pay_kr_contact_v
	where   assignment_id = p_assignment_id_o;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
     and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_rel_code varchar2(10);
	l_ni_number varchar2(20);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type_o = 'KR_YEA_DETAIL_DONATION_INFO' and p_aei_information12_o in ('3','2','1') then
	--
          l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1_o),'YYYY'),12) - 1;
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			l_rel_code    := i.code;
			--
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_nts_amt,
				      	             p_cei_information15        => l_oth_amt,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_nts_amt,
				      	             p_cei_information15        => l_oth_amt,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	end if;
	--
end chk_delete;
--
-----------------------------------------------------------------------------
-- Bug 7633302
-----------------------------------------------------------------------------
procedure chk_taxation_period_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information2          in varchar2,
            p_aei_information3          in varchar2,
            p_aei_information4          in varchar2,
            p_aei_information5          in varchar2,
            p_aei_information7          in varchar2)
is
  l_effective_date  date;
  l_dummy           number;
  l_year            varchar2(10);

  cursor csr_unique is
    select  count(aei_information2)
    from    per_assignment_extra_info
    where   assignment_id = p_assignment_id
    and     assignment_extra_info_id <> p_assignment_extra_info_id
    and     information_type = p_information_type
    and     aei_information2 = p_aei_information2
    and     aei_information7 = p_aei_information7		-- Bug 9213683
    and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(l_effective_date, 'YYYY');
    --
begin
  if (p_information_type = 'KR_YEA_DONATION_TYPE_DETAIL') then
    l_effective_date := fnd_date.canonical_to_date(p_aei_information1);
    l_year := to_char(fnd_date.canonical_to_date(p_aei_information1), 'YYYY');
    if (fnd_number.canonical_to_number(p_aei_information2) < 2008 or
        fnd_number.canonical_to_number(p_aei_information2) > fnd_number.canonical_to_number(l_year)) then
       fnd_message.set_name('PAY', 'PAY_KR_TAX_PD_OUT_OF_RANGE');
       fnd_message.raise_error;
    end if;
    --
    -- Check whether the taxation_period is unique.
    --
    open csr_unique;
    fetch csr_unique into l_dummy;
    close csr_unique;

    if l_dummy > 0 then
      fnd_message.set_name('PAY', 'PAY_KR_TAX_PERIOD_UNIQUE_ERROR');
      fnd_message.set_token('YEAR',p_aei_information2);
      fnd_message.raise_error;
    end if;

    if (fnd_number.canonical_to_number(p_aei_information3) < 0 or
        fnd_number.canonical_to_number(p_aei_information4) < 0 or
        fnd_number.canonical_to_number(p_aei_information5) < 0 ) then
        fnd_message.set_name('PAY' , 'PAY_KR_YEA_NEG_VAL_ERR');
	fnd_message.raise_error;
    end if;

    if (fnd_number.canonical_to_number(p_aei_information2) = l_year) then		-- Bug 9213683
       if fnd_number.canonical_to_number(p_aei_information3) > 0 then
          fnd_message.set_name('PAY', 'PAY_KR_CARRY_OVER_BAL_VAL_ERR');
	  fnd_message.raise_error;
       end if;
    end if;

  end if;

end chk_taxation_period_unique;
--
-----------------------------------------------------------------------------
-- Bug 8200240
-----------------------------------------------------------------------------
procedure chk_med_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(p_aei_information8 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0) + nvl(aei_information11,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information8 = p_aei_information8
	and     aei_information13 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(p_aei_information8 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0) + nvl(aei_information11,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information8 = p_aei_information8
	and     aei_information13 <> '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	distinct pkc.contact_relationship_id, pkc.national_identifier
	from    pay_kr_contact_v pkc
	where   pkc.assignment_id = p_assignment_id;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
             and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_ni_number varchar2(20);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO' then
	--
           l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1),'YYYY'),12) - 1;
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_nts_amt,
				  		     p_cei_information4         => l_oth_amt,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_nts_amt,
				  		     p_cei_information4         => l_oth_amt,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	end if;
	--
end chk_med_insert_update;
--
-----------------------------------------------------------------------------
-- Bug 8200240
-----------------------------------------------------------------------------
procedure chk_med_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(p_aei_information8 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information8 = p_aei_information8
	and     aei_information13 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(p_aei_information8 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information3,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information8 = p_aei_information8
	and     aei_information13 <> '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	distinct contact_relationship_id, national_identifier
	from    pay_kr_contact_v pkc
	where   pkc.assignment_id = p_assignment_id_o;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
     and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_ni_number varchar2(20);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type_o = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO' then
	--
          l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1_o),'YYYY'),12) - 1;
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			--
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_nts_amt,
				  		     p_cei_information4         => l_oth_amt,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_nts_amt,
				  		     p_cei_information4         => l_oth_amt,
				  		     p_cei_information5         => l_cei_information5,
				  		     p_cei_information6         => l_cei_information6,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	end if;
	--
end chk_med_delete;
--
-------------------------------------------------------------------------------
-- Bug 8644512: Added the procedure chk_ntax_earn_unique() to validate the
--   		uniqueness of the 'non-taxable code' and 'business registration
--		number' pair.
-------------------------------------------------------------------------------
procedure chk_ntax_earn_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information2          in varchar2,
            p_aei_information4          in varchar2)
is
  l_effective_date  date;
  l_dummy           number;
  l_year            varchar2(10);

  cursor csr_unique is
    select  count(aei_information2)
    from    per_assignment_extra_info
    where   assignment_id = p_assignment_id
    and     assignment_extra_info_id <> p_assignment_extra_info_id
    and     information_type = p_information_type
    and     aei_information2 = p_aei_information2
    and	    aei_information4 = p_aei_information4
    and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(l_effective_date, 'YYYY');
    --
begin
  if (p_information_type = 'KR_YEA_NON_TAXABLE_EARN_DETAIL') then
    l_effective_date := fnd_date.canonical_to_date(p_aei_information1);
    l_year := to_char(fnd_date.canonical_to_date(p_aei_information1), 'YYYY');
    --
    -- Check whether the 'Non-Taxable Earnings' and 'Business Registration No.' pair is unique.
    --
    open csr_unique;
    fetch csr_unique into l_dummy;
    close csr_unique;

    if l_dummy > 0 then
      fnd_message.set_name('PAY', 'PAY_KR_NTAX_EARN_UNIQUE_ERROR');
      fnd_message.set_token('NTAX_CODE',p_aei_information2);
      fnd_message.set_token('BUS_REG_NUM',p_aei_information4);
      fnd_message.raise_error;
    end if;

  end if;

end chk_ntax_earn_unique;
--
-----------------------------------------------------------------------------
-- Bug 9079450
-----------------------------------------------------------------------------
procedure chk_dpnt_educ_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information6          in varchar2,
            p_aei_information7          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(l_aei_information2 in varchar2,l_aei_information5 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information4,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information2 = l_aei_information2
	and     aei_information5 = l_aei_information5
	and     aei_information6 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(l_aei_information2 in varchar2,l_aei_information5 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information4,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id
	and     information_type = p_information_type
	and     aei_information2 = l_aei_information2
	and     aei_information5 = l_aei_information5
	and     aei_information6 = '2'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	contact_relationship_id, national_identifier,
            nvl(cont_information11,decode(contact_type,'P','1','S','3',
		'A','4','C','4','R','4','O','4','T','4','BROTHER','5','SISTER','5','6') ) code
	from    pay_kr_contact_v
	where   assignment_id = p_assignment_id;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
     and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_rel_code varchar2(10);
	l_ni_number varchar2(20);
	l_year number(4);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type = 'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO' then
	--
           l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1),'YYYY'),12) - 1;
           l_year := to_number(to_char(l_effective_date,'YYYY'));
           if l_year > 2008 then
		--
		if (p_aei_information6 is null) or (p_aei_information7 is null) then
		   fnd_message.set_name('PAY', 'PAY_KR_YEA_EDUCATION_REQ_ERR');
                   fnd_message.raise_error;
                end if;
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			l_rel_code    := i.code;
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_nts_amt,
				  		     p_cei_information6         => l_oth_amt,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_nts_amt,
				  		     p_cei_information6         => l_oth_amt,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	    end if;
	    --
	end if;
	--
end chk_dpnt_educ_insert_update;
--
-----------------------------------------------------------------------------
-- Bug 9079450
-----------------------------------------------------------------------------
procedure chk_dpnt_educ_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2)
-----------------------------------------------------------------------------
is
	l_nts_amt 	number;
	l_oth_amt 	number;
	l_cont_rel_id 	number;
	l_cei_ovn 		NUMBER;
	l_contact_extra_info_id NUMBER;
	l_effective_date	DATE;

	l_cei_information1 varchar2(30);
	l_cei_information2 varchar2(30);
	l_cei_information3 varchar2(30);
	l_cei_information4 varchar2(30);
	l_cei_information5 varchar2(30);
	l_cei_information6 varchar2(30);
	l_cei_information7 varchar2(30);
	l_cei_information8 varchar2(30);
	l_cei_information9 varchar2(30);
	l_cei_information10 varchar2(30);
	l_cei_information11 varchar2(30);
	l_cei_information12 varchar2(30);
	l_cei_information13 varchar2(30);
	l_cei_information14 varchar2(30);
	l_cei_information15 varchar2(30);
	l_object_version_number number;
	l_effective_start_date date;
	l_effective_end_date   date;
	--
	cursor 	csr_nts(l_aei_information2 in varchar2,l_aei_information5 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information4,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information2 = l_aei_information2
	and     aei_information5 = l_aei_information5
	and     aei_information6 = '1'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_oth(l_aei_information2 in varchar2,l_aei_information5 in varchar2, p_effective_date in date) is
	select  sum(nvl(aei_information4,0))
	from    per_assignment_extra_info
	where   assignment_id = p_assignment_id_o
	and     information_type = p_information_type_o
	and     aei_information2 = l_aei_information2
	and     aei_information5 = l_aei_information5
	and     aei_information6 = '2'
        and     trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
        --
        cursor 	csr_cont_rel_id is
        select 	contact_relationship_id, national_identifier,
                nvl(cont_information11,decode(contact_type,'P','1','S','3',
		'A','4','C','4','R','4','O','4','T','4','BROTHER','5','SISTER','5','6')) code
	from    pay_kr_contact_v
	where   assignment_id = p_assignment_id_o;
	--
	cursor 	csr_cei_exists(p_cont_rel_id in number,p_effective_date in date) is
	select cei.contact_extra_info_id,
	         cei.cei_information1,
	         cei.cei_information2,
	         cei.cei_information3,
		 cei.cei_information4,
		 cei.cei_information5,
		 cei.cei_information6,
		 cei.cei_information7,
		 cei.cei_information8,
		 cei.cei_information9,
		 cei.cei_information10,
		 cei.cei_information11,
	         cei.cei_information12,
	         cei.cei_information13,
		 cei.cei_information14,
		 cei.cei_information15,
		 cei.object_version_number,
		 cei.effective_start_date,
		 cei.effective_end_date
	    from per_contact_extra_info_f cei
	   where cei.contact_relationship_id = p_cont_rel_id
	     and cei.information_type = 'KR_DPNT_EXPENSE_INFO'
     and to_char(cei.effective_start_date, 'YYYY') = to_char(p_effective_date,'YYYY');
        --
	l_rel_code varchar2(10);
	l_ni_number varchar2(20);
	l_year number(4);
----------------------------------------------------------------------------------------------
begin
--
	if p_information_type_o = 'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO' then
	--
          l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1_o),'YYYY'),12) - 1;
          l_year := to_number(to_char(l_effective_date,'YYYY'));
          if l_year > 2008 then
		--
		for i in csr_cont_rel_id loop
			l_cont_rel_id := i.contact_relationship_id;
			l_ni_number   := i.national_identifier;
			l_rel_code    := i.code;
			--
			-- Initialized all local variables to null
			l_contact_extra_info_id := null;
	         	l_cei_information1 	:= null;
	         	l_cei_information2 	:= null;
	         	l_cei_information3 	:= null;
		 	l_cei_information4 	:= null;
		 	l_cei_information5 	:= null;
		 	l_cei_information6 	:= null;
		 	l_cei_information7 	:= null;
		 	l_cei_information8 	:= null;
		 	l_cei_information9 	:= null;
		 	l_cei_information10 	:= null;
		 	l_cei_information11 	:= null;
	    		l_cei_information12 	:= null;
	         	l_cei_information13 	:= null;
		 	l_cei_information14 	:= null;
		 	l_cei_information15 	:= null;
		 	l_object_version_number := null;
		 	l_effective_start_date 	:= null;
		 	l_effective_end_date 	:= null;
			l_cei_ovn 		:= null;
			l_nts_amt 		:= null;
			l_oth_amt 		:= null;
			--
			open csr_cei_exists(l_cont_rel_id,l_effective_date);
			fetch csr_cei_exists into l_contact_extra_info_id,
	         			l_cei_information1,
	         			l_cei_information2,
	         			l_cei_information3,
		 			l_cei_information4,
		 			l_cei_information5,
		 			l_cei_information6,
		 			l_cei_information7,
		 			l_cei_information8,
		 			l_cei_information9,
		 			l_cei_information10,
		 			l_cei_information11,
	         			l_cei_information12,
	         			l_cei_information13,
		 			l_cei_information14,
		 			l_cei_information15,
		 			l_object_version_number,
		 			l_effective_start_date,
		 			l_effective_end_date;
			close csr_cei_exists;
			--
			if l_contact_extra_info_id is not null then

		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.upd_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_object_version_number,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_nts_amt,
				  		     p_cei_information6         => l_oth_amt,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			else
 			--
		   	   open csr_nts(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_nts into l_nts_amt;
		           close csr_nts;
			--
			   open csr_oth(l_rel_code,l_ni_number,l_effective_date);
		           fetch csr_oth into l_oth_amt;
		           close csr_oth;

			   	  pay_kr_entries_pkg.create_contact_extra_info
				                     ( p_effective_date         => l_effective_date,
				  		     p_contact_extra_info_id    => l_contact_extra_info_id,
				  		     p_contact_relationship_id  => l_cont_rel_id,
				  		     p_contact_ovn              => l_cei_ovn,
				  		     p_cei_information1         => l_cei_information1,
				  		     p_cei_information2         => l_cei_information2,
				  		     p_cei_information3         => l_cei_information3,
				  		     p_cei_information4         => l_cei_information4,
				  		     p_cei_information5         => l_nts_amt,
				  		     p_cei_information6         => l_oth_amt,
				  		     p_cei_information7         => l_cei_information7,
				  		     p_cei_information8         => l_cei_information8,
				  		     p_cei_information9         => l_cei_information9,
				  		     p_cei_information10        => l_cei_information10,
				  		     p_cei_information11        => l_cei_information11,
				      	             p_cei_information12        => l_cei_information12,
				      	             p_cei_information13        => l_cei_information13,
				      	             p_cei_information14        => l_cei_information14,
				      	             p_cei_information15        => l_cei_information15,
				  		     p_cei_effective_start_date => l_effective_start_date,
				  		     p_cei_effective_end_date   => l_effective_end_date
 		  				    );
			--
			end if;
			--
		end loop;
		--
	    end if;
	end if;
	--
end chk_dpnt_educ_delete;
--
-----------------------------------------------------------------------------
-- Bug 9079450: The medical expense exemption for aged employee/dependents
--              will only be if they are of age 65 or older
-----------------------------------------------------------------------------
procedure eligible_for_med_exem_aged(
            p_aei_information7 		in varchar2,
            p_aei_information8 		in varchar2,
            p_aei_information9 		in varchar2,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2)
is
  l_effective_date  date;
  l_dummy           varchar2(2);
  l_year            number(4);

  cursor csr is
  select pay_kr_ff_functions_pkg.aged_flag(p_aei_information8,l_effective_date)
  from dual;
  --
begin
--
if (p_information_type = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO') then

     l_effective_date := add_months(trunc(fnd_date.canonical_to_date(p_aei_information1),'YYYY'),12) - 1;
     l_year := to_number(to_char(l_effective_date,'YYYY'));

  if (p_aei_information7 <> '0') and (l_year > 2008) then

    if p_aei_information9 = 'B' then
      --
      open csr;
      fetch csr into l_dummy;
      close csr;
      --
      if l_dummy = 'N' then
        fnd_message.set_name('PAY', 'PAY_KR_ELIGIBLE_MED_AGED_ERROR');
        fnd_message.set_token('DPNT_NUM',p_aei_information8);
        fnd_message.raise_error;
      end if;

    end if;

  end if;

end if;

end eligible_for_med_exem_aged;
-----------------------------------------------------------------------------
end per_kr_extra_aei_rules;

/
