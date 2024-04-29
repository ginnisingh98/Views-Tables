--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_MED_EFILE_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_MED_EFILE_CONC_PKG" as
/*$Header: pykrymcon.pkb 120.1.12010000.2 2009/03/02 05:32:20 pnethaga ship $ */

/*************************************************************************
 * Procedure to submit e-file request indirectly
 *************************************************************************/

                     procedure submit_efile (errbuf          out nocopy  varchar2,
						retcode                         out nocopy  varchar2,
						p_business_place		in varchar2,
						p_REPORT_FOR			in varchar2,		--5069923
						p_magnetic_file_name	        in varchar2,
	                                        p_report_file_name		in varchar2,
						p_effective_date		in varchar2,
						p_PAYROLL_ACTION	in varchar2,
						p_ASSIGNMENT_SET	in varchar2,
						p_REPORT_TYPE	in varchar2,
						p_reported_date	in varchar2,
						p_TARGET_YEAR	in varchar2,
						p_CHARACTERSET	in varchar2,
						p_HOME_TAX_ID   in varchar2,
						p_ORG_STRUC_VERSION_ID   in varchar2			--5069923
				    )

	is

        l_req_id          		number;
	l_message			varchar2(2000);
	l_phase				varchar2(100);
	l_status			varchar2(100);
	l_action_completed		boolean;
        l_bg_id                         number;

	begin
        get_bg_id(p_business_place,l_bg_id);
    	l_req_id := fnd_request.submit_request (
			 APPLICATION          =>   'PAY'
			,PROGRAM              =>   'PYKRYEAM_MED_A'
			,DESCRIPTION          =>   'KR Detailed Medical Expense EFile - (Mag Tape)'
			,ARGUMENT1            =>   'pay_magtape_generic.new_formula'
			,ARGUMENT2            =>    p_magnetic_file_name
			,ARGUMENT3            =>    p_report_file_name
	        	,ARGUMENT4            =>    p_effective_date
			,ARGUMENT5            =>   'MAGTAPE_REPORT_ID=KR_YEA_MED_EFILE'
			,ARGUMENT6            =>   'PRIMARY_BP_ID='     || p_business_place
			,ARGUMENT7            =>   'REPORTED_DATE='     || p_reported_date
			,ARGUMENT8            =>   'PAYROLL_ACTION_ID=' || p_PAYROLL_ACTION
		        ,ARGUMENT9            =>   'ASSIGNMENT_SET_ID=' || p_ASSIGNMENT_SET
			,ARGUMENT10           =>   'REPORT_TYPE='       ||  p_REPORT_TYPE
			,ARGUMENT11           =>   'REPORT_DATE='       || p_reported_date
			,ARGUMENT12           =>   'TARGET_YEAR='       || p_TARGET_YEAR
			,ARGUMENT13           =>   'CHARACTER_SET='     || p_CHARACTERSET
			,ARGUMENT14           =>   'HOME_TAX_ID='       || p_HOME_TAX_ID
		        ,ARGUMENT15           =>   'BG_ID='             || (l_bg_id)
			,ARGUMENT16	      =>   'REPORT_FOR='	|| p_REPORT_FOR
			,ARGUMENT17	      =>   'ORG_STRUC_VERSION_ID=' 	|| p_ORG_STRUC_VERSION_ID
		        );

		if (l_req_id = 0) then
			retcode := 2;
			fnd_message.retrieve(errbuf);
		else
			commit;
		end if;
	end submit_efile;

 procedure get_bg_id
           ( p_business_place in  varchar2,
           l_bg_id out nocopy number)
	is

          cursor csr_a is
                select  hou.business_group_id
		from    hr_organization_units           hou
                where  hou.organization_id = p_business_place;
         begin
                open csr_a;
                fetch csr_a into l_bg_id;
                close csr_a;
	end get_bg_id;

   function validate_det_medical_rec
              ( p_assignment_id           in number,
                p_yea_date                in date
               )
              return varchar2
   is
        l_inv_relationship          number;
        l_inv_aged_disabled         number;
        l_inv_med_ser_prov_name     number;

        cursor csr_inv_relationship is
	select count(*) from
	(
	     select res_reg_no, count(*)
	     from
		 (
		      select
			  aei_information8    res_reg_no
			 ,aei_information7    relationship
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
		    group by
			 aei_information8
			,aei_information7
		 )
	    group by res_reg_no
	    having count(*) > 1
	);

        cursor csr_inv_aged_disabled is
	select count(*) from
	(
	     select res_reg_no, count(*)
	     from
		 (
		      select
			  aei_information8    res_reg_no
			 ,aei_information9    aged_disabled
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
		    group by
			 aei_information8
			,aei_information9
		 )
	    group by res_reg_no
	    having count(*) > 1
	);

        cursor csr_inv_med_ser_prov_name is
	select count(*) from
	(
	     select med_ser_prov_reg_no, count(*)
	     from
		 (
		      select
			  aei_information5    med_ser_prov_reg_no
			 ,aei_information6    med_ser_prov_name
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
                          and ( aei_information13 <> '1'  or (aei_information5 is not null and aei_information6 is not null)) -- Bug 8280944
		    group by
			 aei_information5
			,aei_information6
		 )
	    group by med_ser_prov_reg_no
	    having count(*) > 1
	);
   --
   begin
   --
        open csr_inv_relationship;
        fetch csr_inv_relationship into l_inv_relationship;
        close csr_inv_relationship;

        if l_inv_relationship > 0 then
          --
          return 'MULTI_RELATIONSHIP';
          --
        end if;

        open csr_inv_aged_disabled;
        fetch csr_inv_aged_disabled into l_inv_aged_disabled;
        close csr_inv_aged_disabled;

        if l_inv_aged_disabled > 0 then
          --
          return 'MULTI_DIS_AGED';
          --
        end if;

        open csr_inv_med_ser_prov_name;
        fetch csr_inv_med_ser_prov_name into l_inv_med_ser_prov_name;
        close csr_inv_med_ser_prov_name;

        if l_inv_med_ser_prov_name > 0 then
          --
          return 'MULTI_MED_SRV_PRVD_NAME';
          --
        end if;

        return null;
   --
   end validate_det_medical_rec;

   function get_medical_reg_no
              ( p_assignment_id           in number,
                p_yea_date                in date ,
                p_medical_reg_no          in varchar2
               )
              return varchar2
   is
       --
       l_validation       varchar2(50);
       l_medical_reg_no   varchar2(50);

        cursor csr_inv_med_ser_prov_no is
	select med_ser_prov_reg_no
	     from
		 (
		      select
			  aei_information5    med_ser_prov_reg_no
			 ,aei_information6    med_ser_prov_name
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
                          and ( aei_information13 <> '1'  or (aei_information5 is not null and aei_information6 is not null)) -- Bug 8280944
		    group by
			 aei_information5
			,aei_information6
		 )
        group by med_ser_prov_reg_no
        having count(*) > 1;
   --
   Begin
       --
       l_validation :=  pay_magtape_generic.get_parameter_value('VALIDATION');
       --
       if l_validation = 'MULTI_MED_SRV_PRVD_NAME' then
          --
          open csr_inv_med_ser_prov_no;
          fetch csr_inv_med_ser_prov_no into l_medical_reg_no;
          close csr_inv_med_ser_prov_no;
          --
       else
          --
          l_medical_reg_no := p_medical_reg_no;
          --
       end if;
       --
       return l_medical_reg_no;
       --
   end get_medical_reg_no;
   --
   --

   function get_resident_reg_no
              ( p_assignment_id           in number,
                p_yea_date                in date ,
                p_resident_reg_no         in varchar2
               )
              return varchar2
   is
       --
       l_validation        varchar2(50);
       l_resident_reg_no   varchar2(50);

       cursor csr_inv_relationship is
	select res_reg_no
	     from
		 (
		      select
			  aei_information8    res_reg_no
			 ,aei_information7    relationship
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
		    group by
			 aei_information8
			,aei_information7
		 )
	group by res_reg_no
	having count(*) > 1;

        cursor csr_inv_aged_disabled is
	select res_reg_no
	from
		 (
		      select
			  aei_information8    res_reg_no
			 ,aei_information9    aged_disabled
			 ,count(*)                 cnt
		     from
			  per_assignment_extra_info where assignment_id = p_assignment_id
			  and information_type    =  'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
			  and  trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') =
					       trunc(p_yea_date, 'yyyy')
		    group by
			 aei_information8
			,aei_information9
		 )
	group by res_reg_no
	having count(*) > 1;
   --
   Begin
       --
       l_validation :=  pay_magtape_generic.get_parameter_value('VALIDATION');
       --
       if l_validation = 'MULTI_RELATIONSHIP' then
          --
          open csr_inv_relationship;
          fetch csr_inv_relationship into l_resident_reg_no;
          close csr_inv_relationship;
          --
       elsif l_validation = 'MULTI_DIS_AGED' then
          --
          open csr_inv_aged_disabled;
          fetch csr_inv_aged_disabled into l_resident_reg_no;
          close csr_inv_aged_disabled;
          --
       else
          --
          l_resident_reg_no := p_resident_reg_no;
          --
       end if;
       --
       return l_resident_reg_no;
       --
   end get_resident_reg_no;
   --

end pay_kr_yea_med_efile_conc_pkg;

/
