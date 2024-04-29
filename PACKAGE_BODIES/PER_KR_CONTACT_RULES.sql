--------------------------------------------------------
--  DDL for Package Body PER_KR_CONTACT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_CONTACT_RULES" as
/* $Header: pekrceiv.pkb 120.0.12010000.4 2009/08/28 06:51:28 pnethaga ship $ */
l_count		NUMBER;
l_year          VARCHAR2(4);
--
 procedure yea_details_exists_for_year(
        P_CONTACT_EXTRA_INFO_ID          in number,
        P_CONTACT_RELATIONSHIP_ID        in number,
        P_INFORMATION_TYPE               in varchar2,
        P_EFFECTIVE_START_DATE           in date,
        P_EFFECTIVE_END_DATE             in date)
 is

	cursor csr_check_contact_details is
           select count(contact_extra_info_id)
              from per_contact_extra_info_f cei
              where cei.contact_relationship_id = P_CONTACT_RELATIONSHIP_ID
	        and cei.information_type = P_INFORMATION_TYPE
                and to_char(P_EFFECTIVE_START_DATE,'yyyy') = to_char(cei.effective_start_date,'yyyy');
 begin

     IF P_INFORMATION_TYPE = 'KR_DPNT_EXPENSE_INFO' then
	 --
	 l_year := to_char(P_EFFECTIVE_START_DATE,'YYYY');
	 open csr_check_contact_details;
         fetch csr_check_contact_details into l_count;
         IF l_count >= 2 then
               fnd_message.set_name('PAY', 'PAY_KR_YEA_CONT_EXPENSE_EXISTS');
               fnd_message.set_token('YEAR',l_year);
               fnd_message.raise_error;
         end if;
     END IF;
 end;
--
-------------------------------------------------------------------------------
-- Bug 6849941: Credit Card validation checks for the Dependents
-------------------------------------------------------------------------------
 procedure yea_credit_exp_allowed(
 	 p_effective_date             in date
 	,p_contact_relationship_id    in number
 	,p_cei_information7           in varchar2
 	,p_cei_information8           in varchar2
 	,p_information_type           in varchar2)
 is

   l_itax_law 		varchar2(2);
   l_cont_type 		varchar2(2);
   l_kr_cont_type	varchar2(2);

   cursor csr_dpnt is
   select ctr.cont_information2 itax_law,
   	  nvl(ctr.cont_information11, '0') kr_cont_type,
   	  decode(ctr.contact_type,   'P',   '1',   'S',   '3',   'A',   '4',   'C',   '4',   'R',   '4',   'O',   '4',   'T',   '4',  '6') cont_type
     from per_contact_relationships	ctr
    where ctr.cont_information_category = 'KR'
      and ctr.cont_information1 = 'Y'
      and ((ctr.cont_information9 ='D' and p_effective_date between nvl(date_start, p_effective_date) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_effective_date))
          or (nvl(ctr.cont_information9,'XXX') <>'D' and p_effective_date between nvl(date_start, p_effective_date) and nvl(date_end, p_effective_date))
          )
      and ctr.contact_relationship_id = p_contact_relationship_id;

  begin

  	IF p_information_type = 'KR_DPNT_EXPENSE_INFO' then
 	    open csr_dpnt;
	    fetch csr_dpnt into l_itax_law, l_kr_cont_type, l_cont_type;
	    close csr_dpnt;
	    --
	    -- Bug 8644512: Added code for Child(Other than Immediate) to enable the fields
	    if (   (   l_cont_type in ('1','2','3','4')
	            or l_kr_cont_type in ('1','2','3','4','7')
	           )
	       and (   l_itax_law = 'Y' )
	       ) then
		null;
	    else
	        if ((p_cei_information7 is not null) or (p_cei_information8 is not null)) then
	    		fnd_message.set_name('PAY', 'PAY_KR_YEA_CONT_CARD_EXP_ENBLD');
	        	fnd_message.raise_error;
	        end if;
	    end if;
	 --
	 END IF;
  end;
-----------------------------------------------------------------------------------------------
-- Bug 7142612: Validating the Dependents for the Donation fields for Extra Contact Information
-----------------------------------------------------------------------------------------------
 procedure enable_donation_fields(
 	 p_effective_date             in date
 	,p_contact_relationship_id    in number
 	,p_cei_information14           in varchar2
 	,p_cei_information15           in varchar2
 	,p_information_type           in varchar2)
 is

   l_itax_law 		varchar2(2);
   l_cont_type 		varchar2(2);
   l_kr_cont_type	varchar2(2);

   cursor csr_dpnt is
   select ctr.cont_information2 itax_law,
   	  nvl(ctr.cont_information11, '0') kr_cont_type,
   	  decode(ctr.contact_type,   'P',   '1',   'S',   '3',   'A',   '4',   'C',   '4',   'R',   '4',   'O',   '4',   'T',   '4',  '6') cont_type
     from per_contact_relationships	ctr
    where ctr.cont_information_category = 'KR'
      and ctr.cont_information1 = 'Y'
      and ((ctr.cont_information9 ='D' and p_effective_date between nvl(date_start, p_effective_date) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_effective_date))
          or (nvl(ctr.cont_information9,'XXX') <>'D' and p_effective_date between nvl(date_start, p_effective_date) and nvl(date_end, p_effective_date))
          )
      and ctr.contact_relationship_id = p_contact_relationship_id;

  begin

  	IF p_information_type = 'KR_DPNT_EXPENSE_INFO' then
 	    open csr_dpnt;
	    fetch csr_dpnt into l_itax_law, l_kr_cont_type, l_cont_type;
	    close csr_dpnt;
	    --
	    -- Bug 8644512: Added code for Child(Other than Immediate) to enable the fields
	    if (   (   l_cont_type in ('3','4') or l_kr_cont_type in ('3','4','7')
	           )
	       and (   l_itax_law = 'Y' )
	       ) then
		null;
	    else
	        if ((p_cei_information14 is not null) or (p_cei_information15 is not null)) then
	    		fnd_message.set_name('PAY', 'PAY_KR_YEA_CONT_DON_EXP_ENBLD');
	        	fnd_message.raise_error;
	        end if;
	    end if;
	 --
	 END IF;
  end;
-- End of Bug 7142612
end;

/
