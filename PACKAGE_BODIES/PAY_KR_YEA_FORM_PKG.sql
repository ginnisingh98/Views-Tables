--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_FORM_PKG" as
/* $Header: pykryeaf.pkb 120.5.12010000.2 2008/11/26 16:28:54 vaisriva ship $ */
-------------------------------------------------------------------------------------------------------
procedure chk_detail_medical_record
        (
          p_effective_date           in date,
          p_assignment_id            in per_assignment_extra_info.assignment_id%type,
          p_provider_reg_no          in per_assignment_extra_info.aei_information1%type,
          p_provider_reg_name        in per_assignment_extra_info.aei_information1%type,
          p_res_reg_no               in per_assignment_extra_info.aei_information1%type,
          p_relationship             in per_assignment_extra_info.aei_information1%type,
          p_disabled_aged            in per_assignment_extra_info.aei_information1%type,
          p_total_employee           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_dependent          in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_aged               in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_disabled           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_card_exp           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_inv_provider_name        out  nocopy  varchar2,
          p_inv_relationship         out  nocopy  varchar2,
          p_inv_aged_disabled        out  nocopy  varchar2
        )
is
    cursor csr_dup_provider_name is
      select 'Y'
      from per_assignment_extra_info
      where
         assignment_id       =  p_assignment_id and
         information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO' and
         aei_information5    =  p_provider_reg_no and
         aei_information6    <>  p_provider_reg_name and
         trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                                trunc(p_effective_date, 'YYYY');

    cursor csr_dup_relation_aged_disabled is
      select
         decode(aei_information7,p_relationship,'N','Y')   inv_relationship,
         decode(aei_information9,p_disabled_aged,'N','Y')  inv_aged_disabled
      from per_assignment_extra_info
      where
         assignment_id       =  p_assignment_id and
         information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO' and
         aei_information8    =  p_res_reg_no and
         trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                                trunc(p_effective_date, 'YYYY');

    Cursor csr_medical_totals is
      select aei_information24,  -- employee
	aei_information7,  -- dependent
	aei_information9,  -- aged
	aei_information8   -- disabled
      from per_assignment_extra_info pai
      where
         pai.assignment_id    = p_assignment_id and
         pai.information_type = 'KR_YEA_SP_TAX_EXEM_INFO' and
	 trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                               trunc(p_effective_date, 'YYYY');
    -- Bug 4704848
    Cursor csr_total_card_exp is
      select aei_information3  -- card expense
      from per_assignment_extra_info pai
      where
         pai.assignment_id    = p_assignment_id and
         pai.information_type = 'KR_YEA_SP_TAX_EXEM_INFO2' and
	 trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                               trunc(p_effective_date, 'YYYY');

Begin
    --
    p_inv_provider_name  := 'N';
    p_inv_relationship   := 'N';
    p_inv_aged_disabled  := 'N';

    open csr_dup_provider_name;
    fetch csr_dup_provider_name into
       p_inv_provider_name;
       --
       if csr_dup_provider_name%notfound then
          p_inv_provider_name := 'N';
       end if;
    close csr_dup_provider_name;

    open csr_dup_relation_aged_disabled;
    fetch csr_dup_relation_aged_disabled into
      p_inv_relationship, p_inv_aged_disabled;
       --
       if csr_dup_relation_aged_disabled%notfound then
           p_inv_relationship := 'N';
           p_inv_aged_disabled := 'N';
       end if;
    close csr_dup_relation_aged_disabled;

    if (p_inv_provider_name = 'Y' or p_inv_relationship = 'Y' or p_inv_aged_disabled = 'Y') then
       open csr_medical_totals;
       fetch csr_medical_totals into
          p_total_employee,
          p_total_dependent,
          p_total_aged,
          p_total_disabled;

       -- Bug 4704848
       open csr_total_card_exp;
       fetch csr_total_card_exp into p_total_card_exp;

          if csr_medical_totals%notfound then
             p_total_employee   := null;
             p_total_dependent  := null;
             p_total_aged       := null;
             p_total_disabled   := null;
          end if;

	  if csr_total_card_exp%notfound then
	     p_total_card_exp := null;
	  end if;
      --
      close csr_medical_totals;
      close csr_total_card_exp;
   end if;
End;
-------------------------------------------------------------------------------------------------------
function chk_dup_recipient_name (
          p_effective_date 	in	date,
          p_assignment_id	in	per_assignment_extra_info.assignment_id%type,
          p_recipient_reg_no	in	per_assignment_extra_info.aei_information1%type,
          p_recipient_name	in	per_assignment_extra_info.aei_information1%type,
	  p_stat_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_pol_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_prom_fund_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_tax_redn_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_specified_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_religious_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_esoa_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_others_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_public_legal_total  in out nocopy per_assignment_extra_info.aei_information1%type
) return varchar2  -- Bug 7142612
is
	cursor csr_dup_recipient_name is
		select 	'Y'
		from 	per_assignment_extra_info
		where
			assignment_id       	=  p_assignment_id
			and information_type    =  'KR_YEA_DETAIL_DONATION_INFO'
			and aei_information7    =  p_recipient_reg_no
			and aei_information8    <> p_recipient_name
			and trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
		--
	Cursor csr_don_totals1 is
		select 	aei_information18,  -- Statutory
			aei_information20,  -- Political
			aei_information22,  -- Specified
			aei_information23,  -- Tax Reduction Law
			aei_information30   -- ESOA
      		from 	per_assignment_extra_info pai
      		where
         		pai.assignment_id    = p_assignment_id
         		and pai.information_type = 'KR_YEA_SP_TAX_EXEM_INFO'
	 		and trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                               trunc(p_effective_date, 'YYYY');
	--
	Cursor csr_don_totals2 is
		select 	aei_information4,   -- Promotional Fund
			aei_information5,   -- Religious
			aei_information6,   -- Others
			aei_information7    -- Public Legal Entity Donation Trust -- Bug 7142612
      		from 	per_assignment_extra_info pai
      		where
         		pai.assignment_id    = p_assignment_id
         		and pai.information_type = 'KR_YEA_SP_TAX_EXEM_INFO2'
	 		and trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
                               trunc(p_effective_date, 'YYYY');
	--
	l_dup_found varchar2(1) ;
	--
begin
	--
	l_dup_found := 'N' ;
	--
	open 	csr_dup_recipient_name ;
	fetch 	csr_dup_recipient_name into l_dup_found ;
	--
	if csr_dup_recipient_name%notfound then
		l_dup_found := 'N' ;
	end if ;
	--
	close 	csr_dup_recipient_name ;
	--
	 if l_dup_found = 'Y' then
	 	open 	csr_don_totals1 ;
		fetch 	csr_don_totals1 into p_stat_total, p_pol_total, p_specified_total, p_tax_redn_total, p_esoa_total ;
		--
		if 	csr_don_totals1%notfound then
			p_stat_total := '0' ;
			p_pol_total := '0' ;
			p_specified_total := '0' ;
			p_tax_redn_total := '0' ;
			p_esoa_total := '0' ;
		end if ;
		--
		close 	csr_don_totals1 ;
		--
		--
	 	open 	csr_don_totals2 ;
		fetch 	csr_don_totals2 into p_prom_fund_total, p_religious_total, p_others_total, p_public_legal_total ;
		--
		if 	csr_don_totals2%notfound then
			p_prom_fund_total := '0' ;
			p_religious_total := '0' ;
			p_others_total := '0' ;
			p_public_legal_total := '0' ;  -- Bug 7142612
		end if ;
		--
		close 	csr_don_totals2 ;
		--
	 end if ;
	--
	return l_dup_found ;
end chk_dup_recipient_name ;
-------------------------------------------------------------------------------------------------------
function get_donation_tax_break(p_effective_date IN VARCHAR2,
				p_political_donation IN NUMBER) return number
is
--
l_political_tax_brk_lim2004	NUMBER;
l_donation_tax_break		NUMBER;
l_effective_date                DATE ;
--
cursor csr_ff_global(p_glbvar in VARCHAR2) is
    select glb.global_value
    from   ff_globals_f glb
     where glb.global_name = p_glbvar
      and  l_effective_date between glb.effective_start_date and glb.effective_end_date;
begin
        l_effective_date := fnd_date.canonical_to_date(p_effective_date) ;

	OPEN csr_ff_global('KR_YEA_POLITICAL_DONATION_TAX_BREAK_LIM');
	FETCH csr_ff_global into l_political_tax_brk_lim2004;
	CLOSE csr_ff_global;
	--
	l_donation_tax_break := nvl(p_political_donation,0) - greatest(0,p_political_donation - l_political_tax_brk_lim2004);
	--
	return l_donation_tax_break;
--
end get_donation_tax_break;
-------------------------------------------------------------------------------------------------------
end pay_kr_yea_form_pkg;

/
