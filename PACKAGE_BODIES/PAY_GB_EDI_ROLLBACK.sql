--------------------------------------------------------
--  DDL for Package Body PAY_GB_EDI_ROLLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EDI_ROLLBACK" as
/* $Header: pygbedir.pkb 120.2.12010000.10 2010/01/22 15:11:15 krreddy ship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name    :PAY_GB_EDI_ROLLBACK
 Purpose :Package to contol rollback process for
          P45, P45(3), P46, P46 Car, P46PENNOT, WNU and P11D

 History
 Date        Name          Version  Bug        Description
 ----------- ------------- -------- ---------- ------------------------------
 15-JUN-2006 K.Thampan     115.0               Created.
 28-JUN-2006 K.Thampan     115.1               Fix GSCC error
 09-AUG-2006 tukumar	   115.2	       WNU 3.0 5398360
 11-Aug-2008 namgoyal      115.3    7208046    Added logic to handle EDI Rollback
                                               for P46 EDI process version 5
 16-OCT-2008 dwkrishn      115.4    7433580    Added code for 2009 legislative changes
 28-NOV-2008 dwkrishn      115.4    7433580    Added Pennot Changes
 11-Feb-2009 krreddy       115.7    8216080    Modified the code to implement
                                               P46Expat Notification
 11-Feb-2009 krreddy       115.8    8216080    Modified the code to implement
                                               P46Expat Notification
 05-Jan-2010 namgoyal      115.9    9186359    Added rollback for eText based WNU3.0.
 				               This code would only be called for
				               release 12.1.3.
21-Jan-2010 namgoyal      115.10   9255173     Added rollback for eText based P46 V6
 				               This code would only be called for
				               release 12.1.3.
21-Jan-2010 krreddy       115.10   9255183     Added rollback for eText based P46EXP V6
 				               This code would only be called for
				               release 12.1.3.
============================================================================*/

g_package    CONSTANT VARCHAR2(20):= 'pay_gb_edi_rollback.';
--- PRIVATE PROCEDURE ---
FUNCTION get_version(p_assig_id  in  number,
                     p_type      in  varchar2,
                     p_aei_id    out nocopy number) return number
IS
     l_proc CONSTANT VARCHAR2(50):= g_package||'get_version';
     l_ovn  number;
     cursor csr_ovn is
     select object_version_number,
            assignment_extra_info_id
     from   per_assignment_extra_info
     where  assignment_id = p_assig_id
     and    information_type = p_type;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     open csr_ovn;
     fetch csr_ovn into l_ovn, p_aei_id;
     close csr_ovn;

     return l_ovn;
     hr_utility.set_location('Leaving: '||l_proc,999);
END;

PROCEDURE restored(p_type   in varchar2,
                   p_pactid in number)
IS
     l_proc   CONSTANT VARCHAR2(50):= g_package||'restored';
     l_ovn    number;
     l_aei_id number;

   --For bug 7208046: Start
     l_assignment_id  NUMBER;
   --For bug 7208046: End

     cursor csr_archive_details is
     select paa.assignment_id,
            pai.action_information1,
            pai.action_information2,
            pai.action_information3,
            pai.action_information4,
            pai.action_information5,
            pai.action_information6,
            pai.action_information7,
            pai.action_information8,
            pai.action_information9,
            pai.action_information10,
            pai.action_information11,
            pai.action_information12
     from   pay_assignment_actions paa,
            pay_action_information pai
     where  paa.payroll_action_id = p_pactid
     and    paa.assignment_action_id = pai.action_context_id
     and    pai.action_information_category = p_type
     and    pai.action_context_type = 'AAP';

   --For bug 7208046: Start
     CURSOR csr_extra_details(l_assignment_id IN NUMBER)
     IS
        SELECT pei.aei_information_category,
               pei.aei_information1,
	       pei.aei_information2,
	       pei.aei_information3,
	       pei.aei_information4,
	       pei.aei_information5,
	       pei.aei_information6
        FROM per_assignment_extra_info pei
        WHERE pei.assignment_id = l_assignment_id
          AND pei.information_type = 'GB_P46';
   --For bug 7208046: End

BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     if p_type = 'GB WNU EDI' then
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_WNU',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_WNU',
                       p_aei_information1         => archive_rec.action_information2,
                       p_aei_information2         => archive_rec.action_information3,
                       p_aei_information3         => archive_rec.action_information4);
            end if;
        end loop;
     end if;

     if p_type = 'GB P45(3) EDI' then
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_P45_3',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_P45_3',
                       p_aei_information1         => 'Y');
            end if;
        end loop;
     end if;
     /* EOY Changes P45(3) Version 6 Starts */
      if p_type = 'GB P45(3) EDI' then
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_P45_3',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_P45_3',
                       p_aei_information1         => 'Y');
            end if;
        end loop;
     end if;
     /* EOY Changes P45(3) Version 6 Ends */

     if p_type = 'GB P46 EDI' then
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_P46',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_P46',
                       p_aei_information1         => 'Y');
            end if;
        end loop;
     end if;

     /*Changes for P46EXP_Ver6 starts*/

     if p_type = 'GB P46EXP EDI' then
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_P46EXP',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_P46EXP',
                       p_aei_information1         => 'Y');
            end if;
        end loop;
     end if;

    /*Changes for P46EXP_Ver6 End*/

   --For bug 7208046: Start
     IF p_type = 'GB P46_5 EDI'
     THEN
          hr_utility.set_location(p_type,10);
          FOR archive_rec IN csr_archive_details
	  LOOP
	       FOR asg_extra IN csr_extra_details(archive_rec.assignment_id)
	       LOOP
                    l_ovn := get_version(archive_rec.assignment_id,'GB_P46',l_aei_id);

	            IF archive_rec.action_information4 = 'Y' --This is a default Rollback
		    THEN
		          IF (asg_extra.aei_information5 = 'N'
			      AND asg_extra.aei_information6 = 'Y')
		          THEN
			       IF (asg_extra.aei_information1 IS NULL
			           OR (asg_extra.aei_information1 = 'N'
				       AND asg_extra.aei_information3 <> 'Y'))
	                       THEN
			            --This is just a default rollback
                                    hr_assignment_extra_info_api.update_assignment_extra_info
                                      (p_validate                 => false,
		                       p_object_version_number    => l_ovn,
				       p_assignment_extra_info_id => l_aei_id,
		                       p_aei_information_category => 'GB_P46',
				       p_aei_information5         => 'Y');

			       ELSIF asg_extra.aei_information1 = 'Y'
			        THEN
			             --Remove the Send EDI flag also along with default rollback
				     hr_assignment_extra_info_api.update_assignment_extra_info
                                       (p_validate                 => false,
		                        p_object_version_number    => l_ovn,
				        p_assignment_extra_info_id => l_aei_id,
		                        p_aei_information_category => 'GB_P46',
					p_aei_information5         => 'Y',
					p_aei_information1         => NULL,
                                        p_aei_information3         => 'N');
			       ELSE
			            fnd_file.put_line(fnd_file.log,'P46 Run is there and it needs to be rollbacked first '
                                                      ||'for assignment_id : '||archive_rec.assignment_id);
                               END IF;
			  END IF;

		    ELSE --This is a send EDI  Rollback
		          IF (asg_extra.aei_information1 = 'N'
			      AND asg_extra.aei_information3 = 'Y')
		          THEN
                                hr_assignment_extra_info_api.update_assignment_extra_info
                                  (p_validate                 => false,
                                   p_object_version_number    => l_ovn,
		    	  	   p_assignment_extra_info_id => l_aei_id,
		                   p_aei_information_category => 'GB_P46',
		                   p_aei_information1         => 'Y');
                          END IF;
                    END IF;
               END LOOP;
	  END LOOP;
     END IF;
   --For bug 7208046: End

     if p_type = 'GB P46 PENNOT EDI' then ---GB P46 Pension EDI
        hr_utility.set_location(p_type,10);
        for archive_rec in csr_archive_details loop
            hr_utility.set_location(p_type,20);
            l_ovn := get_version(archive_rec.assignment_id,'GB_P46PENNOT',l_aei_id);
            if l_ovn is not null and not(l_ovn <> archive_rec.action_information1) then
               hr_utility.set_location(p_type,30);
               hr_assignment_extra_info_api.update_assignment_extra_info
                      (p_validate                 => false,
                       p_object_version_number    => l_ovn,
                       p_assignment_extra_info_id => l_aei_id,
                       p_aei_information_category => 'GB_P46PENNOT',
                       p_aei_information1         => 'Y');
            end if;
        end loop;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
END;
--- PUBLIC PROCEDURE ---
PROCEDURE edi_rollback(errbuf  out NOCOPY VARCHAR2,
                       retcode out NOCOPY NUMBER,
                       p_type  in  varchar2,
                       p_year  in  number,
                       p_actid in  number)
IS
     l_proc CONSTANT VARCHAR2(50):= g_package||'edi_rollback';
     l_id   number;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     hr_utility.set_location('Type : ' || p_type, 10);
     hr_utility.set_location('Year : ' || p_year, 10);
     hr_utility.set_location('Action : ' || p_actid, 10);
     -- If type is on of the following, do manual stuff first
     if p_type = 'GBEDIWNU' or p_type = 'GBEDIWNU3' or p_type = 'GBEDIWNU3ET' then  -- 5398360 --Added GBEDIWNU3ET for bug 9186359
        restored('GB WNU EDI',p_actid);
     end if;
     if p_type = 'P45_3_EDI' then
        restored('GB P45(3) EDI',p_actid);
     end if;
     /* EOY Changes P45(3) Version 6 Starts */
     if p_type = 'P45PT_3_VER6' then
        restored('GB P45(3) EDI',p_actid);
     end if;
     /* EOY Changes P45(3) Version 6 Ends */

     if p_type = 'GB_P46' then
        restored('GB P46 EDI',p_actid);
     end if;
	/*Changes for P46EXP_Ver6 starts*/
     if p_type in ('GB_P46EXP_V6','GB_P46EXP_V6ET') then --Added GB_P46EXP_V6ET for bug 9255183
        restored('GB P46EXP EDI',p_actid);
     end if;
	/*Changes for P46EXP_Ver6 End*/

   --For bug 7208046: Start
     --IF p_type = 'GB_P46_5'
     IF p_type in('GB_P46_5' ,'GB_P46_V6','GB_P46_V6ET') THEN --Added GB_P46_V6ET for bug 9255173
          restored('GB P46_5 EDI',p_actid);
     END IF;
   --For bug 7208046: End

     /*if p_type = 'P46_PENNOT_EDI' then
        restored('GB P46 Pension EDI',p_actid);
     end if;*/

      if p_type in ('P46_PENNOT_EDI','P46_5_PENNOT_EDI','P46_VER6_PENNOT') then
         restored('GB P46 PENNOT EDI',p_actid);
      end if;

     hr_utility.set_location('Calling Core Rollback routine',20);
     -- Next called the Core's ROLLBACK routine
     l_id := fnd_request.submit_request(application => 'PAY',
                                        program     => 'ROLLBACK',
                                        argument1   => 'ROLLBACK',
                                        argument2   => null,
                                        argument3   => null,
                                        argument4   => p_year,
                                        argument5   => 'X',     -- magnetic report
                                        argument6   => p_actid, -- payroll action_id
                                        argument7   => null,    -- assignmenet_set
                                        argument8   => 'PAYROLL_ACTION_ID='||p_actid,
                                        argument9   => null);
     hr_utility.set_location('Leaving: '||l_proc,999);
END edi_rollback;

END PAY_GB_EDI_ROLLBACK;

/
