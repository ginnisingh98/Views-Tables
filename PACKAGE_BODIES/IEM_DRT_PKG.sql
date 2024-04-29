--------------------------------------------------------
--  DDL for Package Body IEM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DRT_PKG" AS
/* $Header: iemdrtpb.pls 120.0.12010000.3 2018/04/10 11:45:35 deeptiwa noship $*/
  l_package varchar2(33) DEFAULT 'IEM_DRT_PKG. ';
  --
  --- Implement log writter
  --
  PROCEDURE write_log
    (message       IN         varchar2
    ,stage       IN                 varchar2) IS
  BEGIN
                if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
                    fnd_log.string(fnd_log.level_procedure,message,stage);
                end if;
  END write_log;
  --
  --- Implement sub-sprogram add record corresponding to an error/warning/error
  --
/*
PROCEDURE add_to_results
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,status          IN         varchar2
    ,msgcode         IN         varchar2
    ,msgaplid        IN         number
    ,result_tbl      IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    n number(15);
  begin
    n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
  --  hr_utility.set_message(msgaplid,msgcode);
   --result_tbl(n).msgtext := hr_utility.get_message();
  end add_to_results;
 */
  --
  --- Implement Core HR specific DRC for HR entity type
  --
  PROCEDURE iem_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    l_proc varchar2(72) := l_package|| 'iem_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
    ---- Check DRC rule# 1
    --
        --
        --- Check whether email exists for the person yet to be resolved or not
        --
        --
		select count(*) into l_count
		from iem_rt_proc_emails a,hz_parties b,per_all_people_f c
		where c.person_id=p_person_id and c.party_id=b.party_id
		and  ((a.customer_id=b.party_id and b.party_type='PERSON') OR  (a.contact_id=b.party_id and b.party_type='PERSON'));

        if l_count > 0 then
	   	l_status:='E';
  --       l_msg:= 'This Employee Record has unprocessed Emails. Please resolve those before deleting the record';
	    l_msg_code:='IEM_EMP_LIVE_EMAIL';
	    else
	    	l_status:='S';
         end if;
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);

	l_count:= 0;
	    --
        --- Check whether email exists for the Employee which is resolved.
        --
        --
		select count(*) into l_count
		from iem_arch_msgdtls a,hz_parties b,per_all_people_f c
		where c.person_id=p_person_id
		and c.party_id=b.party_id
		and (a.contact_id=b.party_id and b.party_type='PERSON');

        if l_count > 0 then
	   	l_status:='W';
	    l_msg_code:='IEM_EMP_RES_EMAIL';
	    else
	    	l_status:='S';
         end if;
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);

    write_log ('Leaving:'|| l_proc,'999');
  END iem_hr_drc;
  --
  --- Implement Core Email Center specific DRC for TCA entity type
  --
  PROCEDURE iem_tca_drc
        (person_id       IN         number
        ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'iem_tca_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_result_tbl per_drt_pkg.result_tbl_type;
    l_count number;
    l_count1 number;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
		select count(*) into l_count
		from iem_rt_proc_emails a,hz_parties b where b.party_id=p_person_id
		and  ((a.customer_id=b.party_id and b.party_type='PERSON') OR  (a.contact_id=b.party_id and b.party_type='PERSON'));

		select count(*) into l_count1
		from iem_rt_proc_emails a,hz_relationships c
		where c.subject_id=p_person_id  and c.subject_type='PERSON' and c.party_id=a.customer_id ;

    if ((l_count > 0) OR (l_count1 > 0)) then
	   	l_status:='E';
       --  l_msg:= 'This Customer  Record has unprocessed Emails. Please resolve those before deleting the record';
	    l_msg_code:='IEM_CUST_LIVE_EMAIL';
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);
		end if;

		l_count:= 0;
		l_count1:= 0;
		select count(*) into l_count
		from iem_arch_msgdtls a,hz_parties b where b.party_id=p_person_id
		and  ((a.customer_id=b.party_id and b.party_type='PERSON')
				OR  (a.contact_id=b.party_id and b.party_type='PERSON'));

		select count(*) into l_count1
		from iem_arch_msgdtls a,hz_relationships c
		where c.subject_id=p_person_id  and c.subject_type='PERSON' and c.party_id=a.relationship_id ;

    if ((l_count > 0) OR (l_count1 > 0)) then
	   	l_status:='W';
	    l_msg_code:='IEM_CUST_RES_EMAIL';
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);
		end if;



--	IEM_DEFAULT_CUSTOMER_ID : IEM: Admin: Default Customer Party ID
--	IEM_DEFAULT_CUSTOMER_NUMBER : IEM: Admin: Default Customer Party Number
		l_count:= 0;
		l_count1:= 0;
		select count(*) into l_count
		from dual
		where exists (select profile_option_value
									from fnd_profile_option_values a,fnd_profile_options b
									where a.application_id= 680
									and a.profile_option_id = b.profile_option_id
									and b.profile_option_name='IEM_DEFAULT_CUSTOMER_ID'
									and profile_option_value=p_person_id);

		select count(*) into l_count1
		from dual
		where exists (select profile_option_value
									from fnd_profile_option_values a,fnd_profile_options b
									where a.application_id= 680
									and a.profile_option_id = b.profile_option_id
									and b.profile_option_name='IEM_DEFAULT_CUSTOMER_NUMBER'
									and profile_option_value=p_person_id);

    if ((l_count > 0) OR (l_count1 > 0)) then
	   	l_status:='E';
      l_msg_code:='IEM_PRF_DEF_CUST_PARTY_ID_NUM';
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);
		end if;

		if l_status<>'E' AND l_status<>'W' then
		  	l_status:='S';
		        per_drt_pkg.add_to_results
		           (person_id => p_person_id
		           ,entity_type => 'HR'
		           ,status => l_status
		           ,msgcode => ''
		           ,msgaplid =>680
		           ,result_tbl => result_tbl);
		end if;

  END iem_tca_drc;
  --
  --- Implement Core HR specific DRC for FND entity type
  --
  PROCEDURE iem_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'iem_fnd_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_result_tbl per_drt_pkg.result_tbl_type;
    l_count number;
    l_temp varchar2(20);
    l_status	varchar2(1);
    l_msg		varchar2(1000);
    l_msg_code		varchar2(100);
  BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
    --- PER and SSHR does not use FND User ID anywhere so no DRC rules
    --- If any product uses FND User ID then DRCs need to be written here */
    --

    select count(*) into l_count from iem_rt_proc_emails a,jtf_rs_resource_extns b,fnd_user  c
    where a.resource_id=b.resource_id and b.user_name=c.user_name  and c.user_id=p_person_id;

        if l_count > 0 then
	   	l_status:='E';
       --  l_msg:= 'This Resource  Record has unprocessed Emails Assigned. Please resolve those before deleting the record';
	    l_msg_code:='IEM_RES_LIVE_EMAIL';
	    else
	    	l_status:='S';
         end if;
            per_drt_pkg.add_to_results
              (person_id => p_person_id
              ,entity_type => 'HR'
              ,status => l_status
              ,msgcode => l_msg_code
              ,msgaplid =>680
              ,result_tbl => result_tbl);
    write_log ('Leaving: '|| l_proc,'80');
  END iem_fnd_drc;
END iem_drt_pkg;

/
