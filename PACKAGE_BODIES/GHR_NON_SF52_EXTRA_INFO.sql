--------------------------------------------------------
--  DDL for Package Body GHR_NON_SF52_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NON_SF52_EXTRA_INFO" AS
/* $Header: ghddfdef.pkb 120.45.12010000.13 2009/10/22 05:37:15 vmididho ship $ */

g_package varchar2(33) :=  '  GHR_SF52_DDF_INFO.';


Procedure term_ret_grade
( p_pa_request_id in ghr_pa_requests.pa_request_id%type,
  p_person_id     in per_people_f.person_id%type,
  p_first_noa_id  in ghr_pa_requests.first_noa_id%type,
  p_second_noa_id  in ghr_pa_requests.second_noa_id%type,
  p_effective_date in ghr_pa_requests.effective_date%type,
  p_refresh_flag   in varchar2 )
is

    --Begin Bug 5923620
    CURSOR GET_ASSIGNEMNT_ID IS
        SELECT assignment_id
        FROM per_all_assignments_f
        WHERE person_id = p_person_id
        AND p_effective_date between effective_start_date AND effective_end_date;

    l_assignment_id       per_assignments_f.assignment_id%type;
    l_asg_ei_data         per_assignment_extra_info%rowtype;
    l_session             ghr_history_api.g_session_var_type;
    l_session1            ghr_history_api.g_session_var_type;
    --End Bug 5923620

      l_pei_id    per_people_extra_info.person_extra_info_id%type;
      l_rei_rec   ghr_pa_request_extra_info%rowtype ;
      l_org_rec   ghr_pa_request_ei_shadow%rowtype;
      l_ret_grade1 ghr_pa_request_extra_info.rei_information4%type;
      l_noa_code  ghr_nature_of_actions.code%type;
      l_first_noa_code  ghr_nature_of_actions.code%type;
      l_second_noa_code  ghr_nature_of_actions.code%type;
      l_existed   BOOLEAN := FALSE;
      l_altered_pa_request_id ghr_pa_requests.altered_pa_request_id%type;
      l_retained_grade_rec          ghr_pay_calc.retained_grade_rec_type;

      cursor c_noa_code(p_noa_id in ghr_pa_requests.first_noa_id%type) is
      select code from ghr_nature_of_actions
      where nature_of_action_id =  p_noa_id;

      Cursor c_702 is
      SELECT pei_information1 From_Date,
             pei_information2 To_date,
	     pei_information3,
	     pei_information4,
	     pei_information5,
	     pei_information6,
	     pei_information7,
	     pei_information8,
	     pei_information9,
             person_extra_info_id
      FROM   per_people_extra_info pei,
              pay_user_tables put
      WHERE  pei.person_id = p_person_id
      AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
      AND    put.user_table_id = ghr_general.return_number(pei.pei_information6)
      AND    NVL(fnd_date.canonical_to_date(pei.pei_information1) ,p_effective_date)
             <= p_effective_date
      AND     nvl(fnd_date.canonical_to_date(pei.pei_information2),p_effective_date)
                                       >= p_effective_date
      UNION
      SELECT pei_information1 From_Date,
             pei_information2 To_date,
	     pei_information3,
	     pei_information4,
	     pei_information5,
	     pei_information6,
	     pei_information7,
	     pei_information8,
	     pei_information9,
             person_extra_info_id
      FROM   per_people_extra_info pei2, ghr_pa_request_extra_info rei,
             pay_user_tables put
      WHERE  pei2.information_type = 'GHR_US_RETAINED_GRADE'
      AND    rei.information_type  = 'GHR_US_PAR_TERM_RG_PROMO'
      AND    pei2.person_extra_info_id
                 = ghr_general.return_number(rei.rei_information3)
      AND    (rei.rei_information5     = 'Y' or rei.rei_information5 is NULL )
      AND    put.user_table_id
                = ghr_general.return_number(pei2.pei_information6)
      AND    rei.pa_request_id        = l_altered_pa_request_id
      order by 1;

      Cursor c_866(p_person_extra_info_id in
                     per_people_extra_info.person_extra_info_id%type) is
      SELECT pei_information1,
              pei_information2,
              pei_information3,
	      pei_information4,
              pei_information5,
	      pei_information6,
              pei_information7,
	      pei_information8,
              pei_information9,
               person_extra_info_id
      FROM   per_people_extra_info pei
      WHERE  pei.person_extra_info_id = p_person_extra_info_id;

      cursor c_866_rei_correct is
      SELECT  pei_information1,
              pei_information2,
              pei_information3,
	      pei_information4,
              pei_information5,
	      pei_information6,
              pei_information7,
	      pei_information8,
              pei_information9,
               person_extra_info_id
      FROM   per_people_extra_info pei
      WHERE  pei.person_extra_info_id in (
               SELECT rei_information3
               FROM ghr_pa_request_extra_info
               WHERE pa_request_id = l_altered_pa_request_id
               AND information_type = 'GHR_US_PAR_TERM_RET_GRADE');


      Cursor c_740_pei is
      SELECT  pei_information1 From_Date,
              pei_information2 To_date,
              pei_information3 ,
	      pei_information4,
              pei_information5,
	      pei_information6,
	      pei_information7,
	      pei_information8,
	      pei_information9,
              person_extra_info_id,
	      null terminate_flag,
	      null original_rpa
      FROM   per_people_extra_info pei,pay_user_tables put
      WHERE  pei.person_id = p_person_id
      AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
      AND    put.user_table_id    = pei.pei_information6
      AND    p_effective_date
             BETWEEN NVL(fnd_date.canonical_to_date(pei.pei_information1) ,p_effective_date)
             AND NVL(fnd_date.canonical_to_date(pei.pei_information2),p_effective_date)
      UNION
      SELECT  pei_information1 From_Date,
              pei_information2 To_date,
              pei_information3,
	      pei_information4,
              pei_information5,
	      pei_information6,
	      pei_information7,
	      pei_information8,
	      pei_information9,
              person_extra_info_id,
	      rei_information5 terminate_flag,
	      'Original RPA' origianl_rpa
      FROM   per_people_extra_info pei2, ghr_pa_request_extra_info rei,
             pay_user_tables put
      WHERE  pei2.information_type = 'GHR_US_RETAINED_GRADE'
      AND    rei.information_type  = 'GHR_US_PAR_TERM_RG_POSN_CHG'
      AND    pei2.person_extra_info_id
              = ghr_general.return_number(rei.rei_information3)
      AND    put.user_table_id
              = ghr_general.return_number(pei2.pei_information6)
      AND    rei.rei_information5     = 'Y'
      AND    rei.pa_request_id        = l_altered_pa_request_id
      order by 1;

      cursor c_740_rei is
       select rei_information3,rei_information4
       from ghr_pa_request_extra_info
       where pa_request_id = p_pa_request_id
       and information_type = 'GHR_US_PAR_TERM_RG_POSN_CHG';

      cursor c_702_rei is
       select rei_information3,rei_information4
       from ghr_pa_request_extra_info
       where pa_request_id = p_pa_request_id
       and information_type = 'GHR_US_PAR_TERM_RG_PROMO';

    cursor c_altered_par_rec is
      select altered_pa_request_id from ghr_pa_requests
      where pa_request_id = p_pa_request_id;

	--Bug#4126188 Begin
	cursor c_position(p_pa_req_id in number) is
	SELECT from_position_id,to_position_id
	FROM ghr_pa_requests
	WHERE pa_request_id = p_pa_req_id;

	l_pos_ei_data         per_position_extra_info%rowtype;
	l_from_position_id    ghr_pa_requests.from_position_id%type;
	l_to_position_id      ghr_pa_requests.to_position_id%type;
	l_from_poid           ghr_pa_requests.personnel_office_id%type;
	l_to_poid             ghr_pa_requests.personnel_office_id%type;
	--Bug#4126188 End


    BEGIN
       IF p_person_id IS NOT NULL THEN
        --Begin Bug 5923620
        FOR C_GET_ASSIGNMENNT_ID IN GET_ASSIGNEMNT_ID LOOP
            l_assignment_id := C_GET_ASSIGNMENNT_ID.assignment_id;
        end loop;
        --end Bug 5923620
         -- Get Altered PA Request ID to find out Retain Grade records
         -- terminated in Original Action
         for altered_par_rec in c_altered_par_rec loop
           l_altered_pa_request_id := altered_par_rec.altered_pa_request_id;
         end loop;
         FOR noa_code IN c_noa_code(p_first_noa_id) LOOP
           l_first_noa_code := noa_code.code;
           exit;
         END LOOP;
         FOR noa_code IN c_noa_code(p_second_noa_id) LOOP
           l_second_noa_code := noa_code.code;
           exit;
         END LOOP;

         hr_utility.set_location('first noa code '||l_first_noa_code , 1);
         hr_utility.set_location('second noa code '||l_second_noa_code, 2);
         IF l_first_noa_code = '002' THEN
            l_noa_code := l_second_noa_code;
         ELSE
            l_noa_code := l_first_noa_code;
         END IF;
         hr_utility.set_location('l_noa_code is '||l_noa_code, 2);
         -- Delete the RPA EI if there is a change in Effective Date or
         -- Person
         IF p_refresh_flag = 'N' THEN
             IF (nvl(p_effective_date,hr_api.g_date)
                <> nvl(ghr_par_shd.g_old_rec.effective_date,hr_api.g_date)) or
                (nvl(p_person_id,hr_api.g_number)
                <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number)) then
               hr_utility.set_location('Inside the Delete IF '||l_noa_code, 2);
               -- Delete from ghr_pa_request_extra_info
               DELETE ghr_pa_request_extra_info
               WHERE INFORMATION_TYPE in ( 'GHR_US_PAR_TERM_RET_GRADE',
                                             'GHR_US_PAR_TERM_RG_PROMO',
                                             'GHR_US_PAR_TERM_RG_POSN_CHG')
               AND   PA_REQUEST_ID = p_pa_request_id;

               -- Delete from ghr_pa_request_ei_shadow
               DELETE ghr_pa_request_ei_shadow
               WHERE INFORMATION_TYPE in ( 'GHR_US_PAR_TERM_RET_GRADE',
                                             'GHR_US_PAR_TERM_RG_PROMO',
                                             'GHR_US_PAR_TERM_RG_POSN_CHG')
               AND   PA_REQUEST_ID = p_pa_request_id;
             END IF;
         END IF;
         IF l_noa_code IN ( '866' ,'890')  THEN
             hr_utility.set_location('Inside the c_866 loop'||l_noa_code, 3);
             -- Delete from ghr_pa_request_extra_info
             DELETE ghr_pa_request_extra_info
             WHERE INFORMATION_TYPE = 'GHR_US_PAR_TERM_RET_GRADE'
             AND   PA_REQUEST_ID = p_pa_request_id;

             -- Delete from ghr_pa_request_ei_shadow
             DELETE ghr_pa_request_ei_shadow
             WHERE INFORMATION_TYPE = 'GHR_US_PAR_TERM_RET_GRADE'
             AND   PA_REQUEST_ID = p_pa_request_id;
	     --8288066 Added the below or condition for dual actions
         ELSIF l_noa_code = '702'  or (l_noa_code not in ('001','002') and l_second_noa_code  = '702') THEN
           FOR pei_id IN c_702_rei LOOP
             hr_utility.set_location('Inside the c_702_rei loop'||l_noa_code, 3);
             -- Delete from ghr_pa_request_extra_info
             DELETE ghr_pa_request_extra_info
             WHERE INFORMATION_TYPE = 'GHR_US_PAR_TERM_RG_PROMO'
             AND   PA_REQUEST_ID = p_pa_request_id;

             -- Delete from ghr_pa_request_ei_shadow
             DELETE ghr_pa_request_ei_shadow
             WHERE INFORMATION_TYPE = 'GHR_US_PAR_TERM_RG_PROMO'
             AND   PA_REQUEST_ID = p_pa_request_id;
             EXIT;
           END LOOP;
	   --8288066 Added the below or condition for dual actions
        ELSIF l_noa_code = '740' or (l_noa_code not in ('001','002') and l_second_noa_code  = '740') THEN
           hr_utility.set_location('Inside the 740 processing'||l_noa_code, 3);
           l_existed := FALSE;
           for pei_rec in c_740_pei loop
               hr_utility.set_location('PEI rec id'||pei_rec.person_extra_info_id, 4);
             for rei_rec in c_740_rei loop
               hr_utility.set_location('   REI rec id'||rei_rec.rei_information3, 5);
               IF pei_rec.person_extra_info_id = rei_rec.rei_information3 THEN
                 l_existed := TRUE;
                 EXIT;
               ELSE
                 l_existed := FALSE;
               END IF;
             end loop;
             IF not l_existed THEN
               -- Insert into RPA Extra Info
               l_rei_rec.rei_information3   :=  pei_rec.person_extra_info_id;
	       --l_rei_rec.rei_information4   :=  pei_rec.ret_grade;
               l_rei_rec.rei_information5   :=  nvl(pei_rec.terminate_flag,'N'); -- Terminate Record
               l_rei_rec.rei_information30  :=  pei_rec.original_rpa;
               l_rei_rec.information_type   :=  'GHR_US_PAR_TERM_RG_POSN_CHG';
               l_rei_rec.pa_request_id      :=  p_pa_request_id;
	       l_rei_rec.rei_information7   :=  pei_rec.From_Date;
	       l_rei_rec.rei_information8   :=  pei_rec.To_Date;
	       l_rei_rec.rei_information9   :=  pei_rec.pei_information3;
	       l_rei_rec.rei_information10   :=  pei_rec.pei_information4;
	       l_rei_rec.rei_information11   :=  pei_rec.pei_information5;
	       l_rei_rec.rei_information12  :=  pei_rec.pei_information6;
	       l_rei_rec.rei_information13  :=  pei_rec.pei_information8;
	       l_rei_rec.rei_information14  :=  pei_rec.pei_information9;

			--Bug#4126188 Begin
			FOR c_posn_to_frm IN c_position(p_pa_req_id => p_pa_request_id) LOOP
				l_from_position_id :=c_posn_to_frm.from_position_id;
				l_to_position_id := c_posn_to_frm.to_position_id;
			END LOOP;

			--Bug # 8340229
      		        If l_to_position_id is null and l_first_noa_code = '002' then
             		   for c_orig_posn in c_position(p_pa_req_id => l_altered_pa_request_id) LOOP
		               l_to_position_id := c_orig_posn.to_position_id;
                  	   END LOOP;
              		end if;
			ghr_history_fetch.fetch_positionei
			(p_position_id            =>  l_from_position_id,
			p_information_type       =>  'GHR_US_POS_GRP1',
			p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
			p_pos_ei_data            =>  l_pos_ei_data
			);
			l_from_poid := l_pos_ei_data.poei_information3;

			ghr_history_fetch.fetch_positionei
				(p_position_id        =>  l_to_position_id,
				p_information_type   =>  'GHR_US_POS_GRP1',
				p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
				p_pos_ei_data        =>  l_pos_ei_data
				);
				l_to_poid := l_pos_ei_data.poei_information3;
			--Begin Bug 5923620
            IF l_from_poid = l_to_poid THEN

                IF l_first_noa_code = '002' THEN
                    ghr_history_api.get_g_session_var(l_session);
                    l_session1 := l_session;
                    l_session.noa_id_correct := NULL;
                    ghr_history_api.reinit_g_session_var;
                    ghr_history_api.set_g_session_var(l_session);
                    ghr_history_fetch.fetch_asgei
                    (p_assignment_id          => l_assignment_id,
                    p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
                    p_date_effective         =>  p_effective_date-1,
                    p_asg_ei_data       	  =>  l_asg_ei_data );

                    ghr_history_api.reinit_g_session_var;
                    ghr_history_api.set_g_session_var(l_session1);
                ELSE
                    ghr_history_fetch.fetch_asgei
                    (p_assignment_id          =>  l_assignment_id,
                    p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
                    p_date_effective         =>  p_effective_date,
                    p_asg_ei_data       	  =>  l_asg_ei_data);
                END IF;
		set_ei(l_org_rec.rei_information15,l_asg_ei_data.aei_information3,l_rei_rec.rei_information15,'Y');
                --end Bug 5923620
            ELSIF l_from_poid <> l_to_poid THEN
                set_ei(l_org_rec.rei_information15,fnd_date.date_to_canonical(p_effective_date),
                l_rei_rec.rei_information15,'Y');
            END IF;
			--Bug#4126188 End

               generic_populate_extra_info
                (p_rei_rec    =>  l_rei_rec,
                 p_org_rec    =>  l_org_rec,
                 p_flag       =>  'C'
                );
               l_existed := FALSE;
             END IF;
           end loop;
         END IF;
         hr_utility.set_location('Before creating RPA EI'||l_noa_code, 4);
	 -- 8288066 Added the below or condition for dual actions
        IF l_noa_code = '702' or (l_noa_code not in ('001','002') and l_second_noa_code  = '702') THEN
           FOR pei_id IN c_702 LOOP
             hr_utility.set_location('In side creation of RPA EI'||l_noa_code, 4);
             l_rei_rec.rei_information3   :=  pei_id.person_extra_info_id;
             --l_rei_rec.rei_information4   :=  pei_id.ret_grade;
             l_rei_rec.rei_information5   :=  null;
             l_rei_rec.information_type   := 'GHR_US_PAR_TERM_RG_PROMO';
             l_rei_rec.pa_request_id      :=  p_pa_request_id;
	     l_rei_rec.rei_information8   :=  pei_id.From_Date;
	     l_rei_rec.rei_information9   :=  pei_id.To_Date;
	     l_rei_rec.rei_information10   :=  pei_id.pei_information3;
	     l_rei_rec.rei_information11   :=  pei_id.pei_information4;
	     l_rei_rec.rei_information12  :=  pei_id.pei_information5;
	     l_rei_rec.rei_information13  :=  pei_id.pei_information6;
	     l_rei_rec.rei_information14  :=  pei_id.pei_information8;
	     l_rei_rec.rei_information15  :=  pei_id.pei_information9;


             generic_populate_extra_info
            (p_rei_rec    =>  l_rei_rec,
             p_org_rec    =>  l_org_rec,
             p_flag       =>  'C'
              );
           END LOOP;
         ELSIF l_noa_code IN ('866', '890')  THEN
           IF l_altered_pa_request_id is not null THEN
             FOR pei_id IN c_866_rei_correct LOOP
               hr_utility.set_location('866 rei correct ' , 1);
	       l_ret_grade1 :=  pei_id.pei_information1 || '..'|| pei_id.pei_information2 ||
              '..' || pei_id.pei_information3 || '..' || pei_id.pei_information4 ||
              '..' || pei_id.pei_information5 || '..' || pei_id.pei_information6 ||
              '..' || pei_id.pei_information7 || '..' || pei_id.pei_information8
              || '..' || pei_id.pei_information9;
               l_rei_rec.rei_information3   :=  pei_id.person_extra_info_id;
               l_rei_rec.rei_information4   :=  l_ret_grade1;
               l_rei_rec.rei_information5   :=  null;
       	       l_rei_rec.rei_information6   := pei_id.pei_information1;
       	       l_rei_rec.rei_information7   := pei_id.pei_information2;
       	       l_rei_rec.rei_information8   := pei_id.pei_information3;
      	       l_rei_rec.rei_information9   := pei_id.pei_information4;
       	       l_rei_rec.rei_information10  := pei_id.pei_information5;
       	       l_rei_rec.rei_information11  := pei_id.pei_information6;
       	       l_rei_rec.rei_information12  := pei_id.pei_information7;
       	       l_rei_rec.rei_information13  := pei_id.pei_information8;
       	       l_rei_rec.rei_information14  := pei_id.pei_information9;
               l_rei_rec.information_type   := 'GHR_US_PAR_TERM_RET_GRADE';
               l_rei_rec.pa_request_id      := p_pa_request_id;
               generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_rec,
               p_flag       =>  'C'
                );
             END LOOP;
           ELSE
			 ---------- Bug# 2569180 To avoid PL/SQL Error
			 BEGIN
				 l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
								  (p_person_id       =>   p_person_id,
								   p_effective_date  =>   p_effective_date,
								   p_pa_request_id   =>   p_pa_request_id
								  );
			 EXCEPTION
				WHEN ghr_pay_calc.pay_calc_message THEN
					NULL;
			 END;
			 ---------- Bug# 2569180 To avoid PL/SQL Error

             hr_utility.set_location('866 non correct ' , 2);
             FOR pei_id IN c_866(l_retained_grade_rec.person_extra_info_id) LOOP
	       l_ret_grade1 := pei_id.pei_information1 || '..'|| pei_id.pei_information2 ||
              '..' || pei_id.pei_information3 || '..' || pei_id.pei_information4 ||
              '..' || pei_id.pei_information5 || '..' || pei_id.pei_information6 ||
              '..' || pei_id.pei_information7 || '..' || pei_id.pei_information8
              || '..' || pei_id.pei_information9;

               l_rei_rec.rei_information3   :=  pei_id.person_extra_info_id;
               l_rei_rec.rei_information4   :=  l_ret_grade1;
               l_rei_rec.rei_information5   :=  null;
	       l_rei_rec.rei_information6   := pei_id.pei_information1;
       	       l_rei_rec.rei_information7   := pei_id.pei_information2;
       	       l_rei_rec.rei_information8   := pei_id.pei_information3;
      	       l_rei_rec.rei_information9   := pei_id.pei_information4;
       	       l_rei_rec.rei_information10  := pei_id.pei_information5;
       	       l_rei_rec.rei_information11  := pei_id.pei_information6;
       	       l_rei_rec.rei_information12  := pei_id.pei_information7;
       	       l_rei_rec.rei_information13  := pei_id.pei_information8;
       	       l_rei_rec.rei_information14  := pei_id.pei_information9;
               l_rei_rec.information_type   :=  'GHR_US_PAR_TERM_RET_GRADE';
               l_rei_rec.pa_request_id      :=  p_pa_request_id;
               generic_populate_extra_info
                (p_rei_rec    =>  l_rei_rec,
                p_org_rec    =>  l_org_rec,
                p_flag       =>  'C'
               );
             END LOOP;
           END IF;
         END IF;
       END IF;
     END term_ret_grade;

Procedure populate_noa_spec_extra_info
(p_pa_request_id        in   number						,
 p_first_noa_id         in   number 			  		,
 p_second_noa_id        in   number 			   		,
 p_person_id      	in   per_people_f.person_id%type 		,
 p_assignment_id  	in   per_assignments_f.assignment_id%type ,
 p_position_id    	in   per_positions.position_id%type 	,
 p_effective_date 	in   ghr_pa_requests.effective_date%type 	,
 p_refresh_flag         in   varchar2 	default 'Y'
)
is
l_proc                  varchar2(72) := g_package || 'populate_noa_spec_extra_info';
l_information_type      ghr_pa_request_extra_info.information_type%type;
l_dum_information_type  ghr_pa_request_extra_info.information_type%type;
l_flag                  varchar2(1);
l_rei_rec               ghr_pa_request_extra_info%rowtype;
l_org_rec               ghr_pa_request_ei_shadow%rowtype;
l_new_rei_rec           ghr_pa_request_extra_info%rowtype;
l_refresh_flag          varchar2(1);

cursor c_rei_rec is
      select rei.pa_request_extra_info_id,
             rei.object_version_number
      from   ghr_pa_request_extra_info rei
      where  rei.pa_request_id    = p_pa_request_id
      and    rei.information_type NOT IN ('GHR_US_PAR_PAYROLL_TYPE',
                                          'GHR_US_PAR_PERF_APPRAISAL',
                                          'GHR_US_PAR_GEN_AGENCY_DATA',
                                          'GHR_US_PD_GEN_EMP')
      and    rei.information_type not in
            (Select  pit.information_type
             from    ghr_pa_request_info_types  pit,
                     ghr_noa_families           nfa,
                     ghr_families               fam
             where   nfa.nature_of_action_id  in (p_first_noa_id, p_second_noa_id)
             and     nfa.noa_family_code      = fam.noa_family_code
             and     fam.pa_info_type_flag    = 'Y'
             and     pit.noa_family_code      = fam.noa_family_code);
           ----  and     pit.information_type     LIKE 'GHR_US%');

      cursor c_noa_code(p_noa_id in ghr_pa_requests.first_noa_id%type) is
      select code from ghr_nature_of_actions
      where nature_of_action_id =  p_noa_id;

    cursor c_altered_par_rec is
      select altered_pa_request_id from ghr_pa_requests
      where pa_request_id = p_pa_request_id;

      l_noa_code  ghr_nature_of_actions.code%type;
      l_first_noa_code  ghr_nature_of_actions.code%type;
      l_second_noa_code  ghr_nature_of_actions.code%type;
      l_altered_pa_request_id   ghr_pa_requests.pa_request_id%type;

 cursor c_orig_rei_rec is
      select *
      from   ghr_pa_request_extra_info a
      where  a.pa_request_id    = l_altered_pa_request_id
      and    a.information_type like 'GHR_US%'
      and    a.information_type not in (
       select information_type from
        ghr_pa_request_extra_info b
       where b.pa_request_id = p_pa_request_id );

Begin
  hr_utility.set_location('Entering   '  || l_proc,5);
  FOR noa_code IN c_noa_code(p_first_noa_id) LOOP
    l_first_noa_code := noa_code.code;
    exit;
  END LOOP;
  FOR noa_code IN c_noa_code(p_second_noa_id) LOOP
    l_second_noa_code := noa_code.code;
    exit;
  END LOOP;
  hr_utility.set_location('first noa code '||l_first_noa_code , 1);
  hr_utility.set_location('second noa code '||l_second_noa_code, 2);
  IF l_first_noa_code = '002' THEN
    l_noa_code := l_second_noa_code;
  ELSE
    l_noa_code := l_first_noa_code;
  END IF;
  hr_utility.set_location('l_noa_code is '||l_noa_code, 2);
  --Added the OR condition for dual actions
  IF (l_second_noa_code in ('702','866','890','740') and l_first_noa_code = '002' ) OR
     l_first_noa_code in ('702','866','890','740')  OR (l_first_noa_code not in ('001','002')
     and l_second_noa_code in ('702','866','890','740'))
  THEN
    -- New Processing for Termination of Retain Grade
    -- Start
    term_ret_grade(p_pa_request_id      => p_pa_request_id,
                        p_person_id      => p_person_id,
                        p_first_noa_id   => p_first_noa_id,
                        p_second_noa_id  => p_second_noa_id,
                        p_effective_date => p_effective_date,
                        p_refresh_flag   =>  p_refresh_flag );
    -- End
  END IF;
  If p_first_noa_id is not null then
    hr_utility.set_location(l_proc,30);
    hr_utility.set_location('PER ID'||p_person_id,30);
    --
    fetch_noa_spec_extra_info
        (p_pa_request_id        =>  p_pa_request_id,
         p_noa_id               =>  p_first_noa_id,
         p_person_id            =>  p_person_id,
         p_assignment_id        =>  p_assignment_id,
         p_position_id          =>  p_position_id,
         p_effective_date       =>  trunc(nvl(p_effective_date,sysdate)),
         p_refresh_flag         =>  p_refresh_flag
         );
    hr_utility.set_location(l_proc,65);
  End if;

    hr_utility.set_location('PER ID' || p_person_id,65);
    hr_utility.set_location('Second NOa ID ' || p_second_noa_id,65);
  If p_second_noa_id is not null then
     --Bug#4089400 commented second-noa-code not in 702,866,740 clause
     IF l_first_noa_code = '002'  then   --(l_second_noa_code not in ('702','866','740')) and
         for altered_par_rec in c_altered_par_rec loop
           l_altered_pa_request_id := altered_par_rec.altered_pa_request_id;
         end loop;
         hr_utility.set_location('Creation of new RPA EI Records' ,67);
      -- Fetch the original rpa extra information and create new RPA Extra info records
      -- with current PA request id
         FOR orig_rei_rec IN c_orig_rei_rec LOOP
               l_new_rei_rec := orig_rei_rec;
               l_new_rei_rec.pa_request_id            := p_pa_request_id;
               l_new_rei_rec.pa_request_extra_info_id := NULL;
               hr_utility.set_location('Creation of new RPA EI Records'||l_new_rei_rec.information_type ,65);
               generic_populate_extra_info
              (p_rei_rec    =>  l_new_rei_rec,
               p_org_rec    =>  l_org_rec,
               p_flag       =>  'C'
                );
          END LOOP;

  end if;
    fetch_noa_spec_extra_info
        (p_pa_request_id       =>  p_pa_request_id,
         p_noa_id               =>  p_second_noa_id,
         p_person_id            =>  p_person_id,
         p_assignment_id        =>  p_assignment_id,
         p_position_id          =>  p_position_id,
         p_effective_date       =>  trunc(nvl(p_effective_date,sysdate)),
         p_refresh_flag         =>  p_refresh_flag
         );
    hr_utility.set_location(l_proc,150);
  End if;
  --
  -- delete all the extra info records which are not required for the new noa code
  --
  for rei_rec in c_rei_rec loop
     l_rei_rec.pa_request_extra_info_id :=  rei_rec.pa_request_extra_info_id ;
     l_rei_rec.object_version_number    :=  rei_rec.object_version_number ;
     l_flag := 'D';
     hr_utility.set_location(l_proc,160);
     generic_populate_extra_info
     (p_rei_rec    =>  l_rei_rec,
      p_org_rec    =>  l_org_rec,
      p_flag       =>  l_flag
     );
  end loop;

  --
  hr_utility.set_location('Leaving   ' || l_proc,135);
  --
End  populate_noa_spec_extra_info;


Procedure fetch_noa_spec_extra_info
(p_pa_request_id        in   number,
 p_noa_id    		in   number,
 p_person_id      	in   per_people_f.person_id%type,
 p_assignment_id  	in   per_assignments_f.assignment_id%type,
 p_position_id    	in   per_positions.position_id%type,
 p_effective_date 	in   ghr_pa_requests.effective_date%type,
 p_refresh_flag         in   varchar2 default 'Y'
)
 is

 l_per_ei_data         per_people_extra_info%rowtype;
 l_asg_ei_data         per_assignment_extra_info%rowtype;
 l_pos_ei_data         per_position_extra_info%rowtype;
 l_multiple_error_flag boolean;
 l_noa_id              ghr_nature_of_actions.nature_of_action_id%type;
 l_proc                varchar2(72):=  g_package || 'noa_spec_extra_info';
 l_information_type    ghr_pa_request_info_types.information_type%type;
 l_update_rei          varchar2(1) := 'N';
 l_exists              boolean     :=  FALSE;
 l_value               varchar2(30);
 l_rei_rec             ghr_pa_request_extra_info%rowtype;  -- as in the ddf and then subsequently overwrittwn with data to be updated
 l_org_rec             ghr_pa_request_ei_shadow%rowtype;  -- original from the duplicate table
 l_old_rei_rec         ghr_pa_request_extra_info%rowtype;
 l_flag                varchar2(1);
 l_refresh_flag        varchar2(1);
 l_rei_rec_exists      varchar2(1);
 l_person_id           per_people_f.person_id%type;
 l_assignment_id       per_assignments_f.assignment_id%type;
 l_ret_review_date     varchar2(30);
 l_eff_date     date;
 l_position_id         per_positions.position_id%type;
 l_per_refresh_flag    varchar2(1);
 l_asg_refresh_flag    varchar2(1);
 l_pos_refresh_flag    varchar2(1);
 -- Bug#4089400
 l_noa_family_code       ghr_noa_families.noa_family_code%type;
 -- Bug#5039072 Added the following two parameters.
 l_first_noa_code        ghr_pa_requests.first_noa_code%type;
 l_la_code1              ghr_pa_requests.first_action_la_code1%type;
 l_payment_option        ghr_pa_requests.pa_incentive_payment_option%type;
 l_application_id fnd_application.application_id%type;
 l_resp_id fnd_responsibility.responsibility_id%type;

  -- Begin Bug#4126188
 l_from_position_id    ghr_pa_requests.from_position_id%type;
 l_to_position_id      ghr_pa_requests.to_position_id%type;
 l_second_noa_code     ghr_pa_requests.second_noa_code%type;
 l_from_poid           ghr_pa_requests.personnel_office_id%type;
 l_to_poid             ghr_pa_requests.personnel_office_id%type;
 l_session             ghr_history_api.g_session_var_type;
 l_session1            ghr_history_api.g_session_var_type;

 CURSOR c_pa_req_2noa_dtls is
        SELECT second_noa_code
        FROM ghr_pa_requests
        WHERE  pa_request_id = p_pa_request_id;
-- End Bug#4126188

 cursor c_rei_rec is
      select pa_request_extra_info_id,
             rei_information1,
             rei_information2,
             rei_information3,
             rei_information4,
             rei_information5,
             rei_information6,
             rei_information7,
             rei_information8,
             rei_information9,
             rei_information10,
             rei_information11,
             rei_information12,
		 rei_information13,
             rei_information14,
             rei_information15,
             rei_information16,
             rei_information17,
             rei_information18,
             rei_information19,
             rei_information20,
             rei_information21,
             rei_information22,
		 rei_information23,
             rei_information24,
             rei_information25,
             rei_information26,
             rei_information27,
             rei_information28,
             rei_information29,
             rei_information30,
             object_version_number
      from   ghr_pa_request_extra_info
      where  pa_request_id    = p_pa_request_id
      and    information_type = l_information_type;

cursor c_org_rei_rec is
      select pa_request_extra_info_id,
             rei_information1,
             rei_information2,
             rei_information3,
             rei_information4,
             rei_information5,
             rei_information6,
             rei_information7,
             rei_information8,
             rei_information9,
             rei_information10,
             rei_information11,
             rei_information12,
		 rei_information13,
             rei_information14,
             rei_information15,
             rei_information16,
             rei_information17,
             rei_information18,
             rei_information19,
             rei_information20,
             rei_information21,
             rei_information22,
		 rei_information23,
             rei_information24,
             rei_information25,
             rei_information26,
             rei_information27,
             rei_information28,
             rei_information29,
             rei_information30
      from   ghr_pa_request_ei_shadow
      where  pa_request_extra_info_id = l_rei_rec.pa_request_extra_info_id;

   -- Bug#3941541 Added effective date condition to the cursor.
   Cursor c_info_types(c_application_id fnd_application.application_id%type,c_resp_id fnd_responsibility.responsibility_id%type) is
     Select  pit.information_type
     from    ghr_pa_request_info_types  pit,
             ghr_noa_families           nfa,
             ghr_families               fam
     where   nfa.nature_of_action_id  = p_noa_id
     and     nfa.noa_family_code      = fam.noa_family_code
     and     p_effective_date between NVL(nfa.start_date_active,p_effective_date)
                                  and NVL(nfa.end_date_active,p_effective_date)
     and     fam.pa_info_type_flag    = 'Y'
     and     pit.noa_family_code      = fam.noa_family_code
     and     pit.information_type     like 'GHR_US%'
     --Bug#3942126 Added the following clause.
     and     pit.active_inactive_flag = 'Y'
	 and      pit.information_type IN
     (SELECT information_type
        from per_info_type_security
        where application_id = c_application_id
        and responsibility_id = c_resp_id);


   cursor c_get_effective_date is
     Select effective_date
       from ghr_pa_requests
     where pa_request_id = p_pa_request_id;

 -- Bug#4089400
 cursor c_noa_fam_code  is
        select par.noa_family_code noa_family_code,
               par.first_noa_code  first_noa_code,
               par.first_action_la_code1 la_code1,
               par.pa_incentive_payment_option payment_option
        from   ghr_pa_requests par
        where  pa_request_id = p_pa_request_id;

     cursor c_noac_1xx is
        SELECT par.effective_date
        FROM ghr_nature_of_actions noa,
             ghr_pa_requests par,
             ghr_pay_plans pp
        WHERE  noa.nature_of_action_id = par.first_noa_id
         and   par.pa_request_id = p_pa_request_id
         and pp.pay_plan = par.to_pay_plan
         and pp.equivalent_pay_plan in ('GS','FW')
         and substr(noa.code,1,1) = '1'
         AND noa.code <> '130';

     cursor c_noac_5xx is
        SELECT par.effective_date
        FROM ghr_nature_of_actions noa,
             ghr_pa_requests par,
             ghr_pay_plans pp
        WHERE  (noa.nature_of_action_id = par.first_noa_id
               ---Bug# 8263918
               OR
	      (noa.nature_of_action_id = par.second_noa_id
	       and
	       par.first_noa_code not in ('001','002')))
           ---Bug# 8263918
         and   par.pa_request_id = p_pa_request_id
         and pp.pay_plan = par.to_pay_plan
         and pp.equivalent_pay_plan in ('GS','FW')
         and substr(noa.code,1,1) = '5'
         AND noa.code not in  ('542','543','546','548','549');

     cursor c_noac_130 is
        SELECT par.effective_date
        FROM ghr_nature_of_actions noa,
             ghr_pa_requests par,
             ghr_pay_plans pp
        WHERE  noa.nature_of_action_id = par.first_noa_id
         and   par.pa_request_id = p_pa_request_id
         and pp.pay_plan = par.to_pay_plan
         and pp.equivalent_pay_plan in ('GS','FW')
         AND noa.code = '130'
         AND par.first_action_la_code1 = 'KVM';

     cursor c_noac_sal_chg is
       SELECT par.effective_date
       FROM ghr_nature_of_actions noa,
            ghr_pa_requests par,
            ghr_pay_plans pp
        WHERE (noa.nature_of_action_id = par.first_noa_id
        ---Bug# 8263918
               OR
	      (noa.nature_of_action_id = par.second_noa_id
	       and
	       par.first_noa_code not in ('001','002')))
           ---Bug# 8263918
        AND par.pa_request_id = p_pa_request_id
        AND pp.pay_plan = par.to_pay_plan
        AND pp.equivalent_pay_plan in ('GS','FW')
        AND code in  ('702','703','891','893');

     -- Bug#5657744 Created the cursor
     CURSOR c_afhr_noac_sal_chg IS
     SELECT par.effective_date
       FROM ghr_pa_requests par
      WHERE par.pa_request_id = p_pa_request_id
        AND par.first_noa_code IN  ('890','891','892','893');


     cursor c_pp_and_grade is
        SELECT to_pay_plan,to_grade_or_level,
               from_pay_plan,from_grade_or_level
        FROM ghr_pa_requests
        WHERE pa_request_id = p_pa_request_id;

     -- Bug 4280026
cursor c_position is
	SELECT from_position_id,to_position_id
	FROM ghr_pa_requests
	WHERE pa_request_id = p_pa_request_id;


l_dummy                 varchar2(1);
l_dlei_date             date := null;
-- Bug#5657744
l_psi                   VARCHAR2(10);

cursor c_req_num is
   select request_number from ghr_pa_requests
   where pa_request_id = p_pa_request_id;
 /*Start - BUG 6129752-DATE ARRIVED PERSONNEL OFFICE CHANGING TO WRONG DATE ON CORRECTION TO PROMOTION
Following cursor has been added to fetch assignment id when p_assignment_id is null. */

CURSOR GET_ASSIGNEMNT_ID IS
SELECT assignment_id
	FROM per_all_assignments_f
	WHERE person_id = p_person_id
		AND p_effective_date between effective_start_date AND effective_end_date;
/*End Bug -6129752 */
-- populate rei_information with appt_info

 Procedure appt_info is
   Begin

   -- Read from history if person id is not null
      hr_utility.set_location('Person inside appt_info is  ' || to_char(l_person_id),1);
     If l_person_id is not null then
      hr_utility.set_location('Person inside appt_info is  ' || to_char(l_person_id),1);
          -- if the person_id is not the same as the old person_id then do the foll.
       -- If l_person_id <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) then
       -- a) Get PER_GROUP1 Information
      l_refresh_flag   :=  l_per_refresh_flag;
       ghr_history_fetch.fetch_peopleei
       (p_person_id          =>  l_person_id,
        p_information_type   =>  'GHR_US_PER_GROUP1',
        p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
        p_per_ei_data        =>  l_per_ei_data
       );
       --  set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
	--   l_org_rec.rei_information3  :=  l_per_ei_data.pei_information3;
         -- Bug 1371770
         IF l_per_ei_data.pei_information11 is null THEN
             l_rei_rec.rei_information8 := '05';
         ELSE
             set_ei(l_org_rec.rei_information8,l_per_ei_data.pei_information11,l_rei_rec.rei_information8,l_refresh_flag);
             l_org_rec.rei_information8  :=  l_per_ei_data.pei_information11;
         END IF;
/*
         set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information8,l_rei_rec.rei_information10,l_refresh_flag);
         l_org_rec.rei_information10 :=  l_per_ei_data.pei_information8;
         set_ei(l_org_rec.rei_information11,l_per_ei_data.pei_information9,l_rei_rec.rei_information11,l_refresh_flag);
         l_org_rec.rei_information11 :=  l_per_ei_data.pei_information9;
*/
         set_ei(l_org_rec.rei_information16,l_per_ei_data.pei_information5,l_rei_rec.rei_information16,l_refresh_flag);
         l_org_rec.rei_information16 :=  l_per_ei_data.pei_information5;
         set_ei(l_org_rec.rei_information17,l_per_ei_data.pei_information4,l_rei_rec.rei_information17,l_refresh_flag);
         l_org_rec.rei_information17 :=  l_per_ei_data.pei_information4;

       l_per_ei_data               :=  null;

        -- b) Get PER_UNIFORMED_SERVICES Information
       ghr_history_fetch.fetch_peopleei
       (p_person_id          =>  l_person_id,
        p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
        p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
        p_per_ei_data        =>  l_per_ei_data
       );
          set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information5,l_rei_rec.rei_information4,l_refresh_flag);
         l_org_rec.rei_information4   := l_per_ei_data.pei_information5;
       l_per_ei_data               :=  null;

         -- c) Get PER_SEPARATE_RETIRE Information
       ghr_history_fetch.fetch_peopleei
       (p_person_id          =>  l_person_id,
        p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
        p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
        p_per_ei_data        =>  l_per_ei_data
       );
         hr_utility.set_location('per_sep_retire' ,1);
         set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information5,l_rei_rec.rei_information7,l_refresh_flag);
                  hr_utility.set_location('per_sep_retire' || l_rei_rec.rei_information7 ,2);
       l_org_rec.rei_information7  :=  l_per_ei_data.pei_information5;
         set_ei(l_org_rec.rei_information14,l_per_ei_data.pei_information4,l_rei_rec.rei_information14,l_refresh_flag);
        l_org_rec.rei_information14 :=  l_per_ei_data.pei_information4;
         set_ei(l_org_rec.rei_information19,l_per_ei_data.pei_information3,l_rei_rec.rei_information19,l_refresh_flag);
        l_org_rec.rei_information19 :=  l_per_ei_data.pei_information3;

       l_per_ei_data               :=  null;









	   IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
         --  Get PER_LEAVE Information
				 hr_utility.set_location('per_leave_info' ,1);
			   ghr_history_fetch.fetch_peopleei
			   (p_person_id          =>  l_person_id,
				p_information_type   =>  'GHR_US_PER_LEAVE_INFO',
				p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
				p_per_ei_data        =>  l_per_ei_data
			   );
				IF l_per_ei_data.pei_information4 is NULL THEN
				   l_rei_rec.rei_information20 := 'N';
				ELSE
				 set_ei(l_org_rec.rei_information20,l_per_ei_data.pei_information4,l_rei_rec.rei_information20,l_refresh_flag);
				END IF;
			   l_per_ei_data               :=  null;

			  --Gain Or Lose
				 set_ei(l_org_rec.rei_information21,'1B',l_rei_rec.rei_information21,l_refresh_flag);
		END IF;
    End if;

     If l_assignment_id is not null then

        -- Get ASG_NON_SF52 data
         l_refresh_flag  := l_asg_refresh_flag;
         ghr_history_fetch.fetch_asgei
         (p_assignment_id          =>  l_assignment_id,
          p_information_type       =>  'GHR_US_ASG_NON_SF52',
          p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
          p_asg_ei_data            =>  l_asg_ei_data
         );

     -- added on 02-oct-98 by skutteti to autopopulate with the effective date
     --  set_ei(l_org_rec.rei_information5,fnd_date.date_to_canonical(p_effective_date),
     --        l_rei_rec.rei_information5,l_refresh_flag);
     --  set_ei(l_org_rec.rei_information5,l_asg_ei_data.aei_information3,
     --        l_rei_rec.rei_information5,l_refresh_flag);
     --  l_org_rec.rei_information5   :=  l_asg_ei_data.aei_information3;

     --  added on 3-dec-99 -- Refer bug 963634
       for c_get_eff_rec in c_get_effective_date  loop
         set_ei(l_org_rec.rei_information5,fnd_date.date_to_canonical(c_get_eff_rec.effective_date),
                l_rei_rec.rei_information5,l_refresh_flag);
         exit;
       end loop;

         set_ei(l_org_rec.rei_information9,l_asg_ei_data.aei_information6,l_rei_rec.rei_information9,l_refresh_flag);
           l_org_rec.rei_information9   :=  l_asg_ei_data.aei_information6;
         set_ei(l_org_rec.rei_information12,l_asg_ei_data.aei_information8,l_rei_rec.rei_information12,l_refresh_flag);
           l_org_rec.rei_information12  :=  l_asg_ei_data.aei_information8;
         set_ei(l_org_rec.rei_information15,l_asg_ei_data.aei_information9,l_rei_rec.rei_information15,l_refresh_flag);
           l_org_rec.rei_information15  :=  l_asg_ei_data.aei_information9;
         l_asg_ei_data                :=  null;
     End if;

     If l_position_id is not null then
        l_refresh_flag := l_pos_refresh_flag;
         ghr_history_fetch.fetch_positionei
         (p_position_id            =>  l_position_id,
          p_information_type       =>  'GHR_US_POS_GRP1',
          p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
          p_pos_ei_data            =>  l_pos_ei_data
         );
         set_ei(l_org_rec.rei_information13,l_pos_ei_data.poei_information12,l_rei_rec.rei_information13,l_refresh_flag);
           l_org_rec.rei_information13  :=  l_pos_ei_data.poei_information12;
           hr_utility.set_location('posei in test ei - ' || l_pos_ei_data.poei_information12,2);
         l_pos_ei_data                :=  null;
     End if;
     hr_utility.set_location('Appt_info Family Code: '||l_noa_family_code,10);
     IF NVL(l_noa_family_code,'C') <> 'CORRECT' THEN
         OPEN c_noac_1xx;
         FETCH c_noac_1xx INTO l_dlei_date;
           IF l_dlei_date is not null THEN
             set_ei(l_org_rec.rei_information18,
               fnd_date.date_to_canonical(l_dlei_date),
                    l_rei_rec.rei_information18,'Y');
           ELSE
             set_ei(l_org_rec.rei_information18,
               null,l_rei_rec.rei_information18,'Y');
           END IF;
          CLOSE c_noac_1xx;
      END IF;
   End appt_info;

Procedure appt_benefits is
      l_tenure   ghr_pa_requests.tenure%type;
      l_retirement_plan ghr_pa_requests.retirement_plan%type;
      l_noa_code  ghr_pa_requests.first_noa_code%type;
      l_fegli    ghr_pa_requests.fegli%type;
      l_prev_fegli    ghr_pa_requests.fegli%type;
      l_scd      ghr_pa_requests.SERVICE_COMP_DATE%type;
      l_payroll_id pay_payrolls_f.payroll_id%type;
      l_pa_request_id ghr_pa_requests.pa_request_id%type;
      l_effective_date ghr_pa_requests.effective_date%type;
      l_start_date per_time_periods.start_date%type;
	  l_family_code ghr_pa_requests.noa_family_code%type;
	  l_new_element_name pay_element_types_f.element_name%type;
	  l_bus_group_id per_all_people_f.business_group_id%type;
	  l_fehb_exists BOOLEAN;
	  l_tsp_exists BOOLEAN;
	  l_health_plan pay_element_entry_values_f.screen_entry_value%type;
	  l_enrollment_option pay_element_entry_values_f.screen_entry_value%type;
	  l_pre_tax_waiver pay_element_entry_values_f.screen_entry_value%type;
	  l_date_temp_elig date;
	  l_tsp_status pay_element_entry_values_f.screen_entry_value%type;
	  l_tsp_status_date date;
	  l_agency_contrib_date date;
	  l_second_noa_code ghr_pa_requests.second_noa_code%type;
     --8793163
     l_second_noa_id   ghr_pa_requests.second_noa_id%type;
     l_second_noa_family_code ghr_pa_requests.noa_family_code%type;
      --8793163

     CURSOR c_pa_req_details is
        SELECT *
        FROM ghr_pa_requests
        WHERE  pa_request_id = p_pa_request_id;

	 CURSOR c_payroll_id(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information3 payroll_id
	  FROM   ghr_pa_request_extra_info
	  WHERE  pa_request_id       =   c_pa_request_id
	  AND    information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

     CURSOR c_start_date(c_payroll_id pay_payrolls_f.payroll_id%type, c_year varchar2, c_month varchar2) IS
        SELECT min(start_date) start_date
	   FROM per_time_periods
	   WHERE payroll_id = c_payroll_id
	   AND TO_CHAR(start_date,'YYYY') = c_year
	   AND TO_CHAR(start_date,'MM') = c_month;

	CURSOR c_element_entry(c_assignment_id pay_element_entries_f.assignment_id%type,
							c_element_name pay_element_types_f.element_name%type,
							c_effective_date pay_element_entries_f.effective_start_date%type) IS
	SELECT 1
		FROM pay_element_entries_f ele
		WHERE ele.assignment_id = c_assignment_id
		AND c_effective_date BETWEEN ele.effective_start_date AND effective_end_date
		AND ele.element_type_id = (SELECT elt.element_type_id
									FROM pay_element_types_f elt
									WHERE element_name = c_element_name
									AND c_effective_date BETWEEN elt.effective_start_date AND elt.effective_end_date);

	CURSOR c_element_value (c_element_name pay_element_types_f.element_name%type,
				 c_assignment_id per_all_assignments_f.assignment_id%type,
				 c_effective_date pay_element_entries_f.effective_start_date%type
				 ) is
          SELECT a.element_name           element_name,
                 b.NAME                   ipv_name,
                 f.input_value_id         input_value_id,
                 e.effective_start_date   effective_start_date,
                 e.effective_end_date     effective_end_date,
                 e.element_entry_id       element_entry_id,
                 e.assignment_id          assignment_id,
                 e.object_version_number  object_version_number,
                 f.element_entry_value_id element_entry_value_id,
                 f.screen_entry_value     screen_entry_value
            FROM pay_element_types_f        a,
                 pay_input_values_f         b,
                 pay_element_entries_f      e,
                 pay_element_entry_values_f f
           WHERE a.element_type_id = b.element_type_id AND
                 e.element_type_id = a.element_type_id AND
                 f.element_entry_id = e.element_entry_id AND
                 f.input_value_id = b.input_value_id AND
                 e.assignment_id = c_assignment_id AND a.element_name = c_element_name AND
                 c_effective_date BETWEEN e.effective_start_date AND e.effective_end_date AND
/*Start Bug#6082557 Added three more condition in the where clause.*/
                 c_effective_date BETWEEN b.effective_start_date AND b.effective_end_date AND
                 c_effective_date BETWEEN a.effective_start_date AND a.effective_end_date AND
                 c_effective_date BETWEEN f.effective_start_date AND f.effective_end_date;
/*End Bug#6082557 */

  BEGIN
       l_noa_code := NULL;
       FOR pa_rec in c_pa_req_details LOOP
         l_noa_code        := pa_rec.first_noa_code;
		 l_family_code     := pa_rec.noa_family_code;
         l_tenure          := pa_rec.tenure;
         l_retirement_plan := pa_rec.retirement_plan;
         l_fegli           := pa_rec.fegli;
         l_scd             := pa_rec.service_comp_date;
	     l_pa_request_id   := pa_rec.pa_request_id;
	     l_effective_date  := NVL(pa_rec.effective_date,SYSDATE);
		 l_person_id       := pa_rec.person_id;
		 l_second_noa_code := pa_rec.second_noa_code;
		 --8793163
		 l_second_noa_id   := pa_rec.second_noa_id;
		 l_second_noa_family_code := ghr_pa_requests_pkg.get_noa_pm_family (l_second_noa_id,p_effective_date);
		 --8793163
       END LOOP;

	   l_fehb_exists := FALSE;
	   l_tsp_exists := FALSE;
           -- 6976435 added the below condition for defaulting health benefits for dual actions
   	   IF l_second_noa_code IS NULL or (l_noa_code not in ('001','002') and l_second_noa_code IS NOT NULL) THEN
		IF l_family_code = 'APP' THEN

		-- Date FEHB Eligibility Expires
		-- Enrollment
		-- Pre Tax Waiver
		   IF l_noa_code in
			 ( '100', '101', '107', '108', '120',
			 '124', '140', '141',
			 '142', '143', '146',
			 '148','170', '190' ) THEN
			 set_ei(l_org_rec.rei_information3,
			  fnd_date.date_to_canonical(nvl(p_effective_date,sysdate)+60),
			 l_rei_rec.rei_information3,'Y');
			 set_ei(l_org_rec.rei_information6, 'X',
			 l_rei_rec.rei_information6,'Y');
		   ELSE
			 set_ei(l_org_rec.rei_information3,
			 NULL,l_rei_rec.rei_information3,'Y');
			 set_ei(l_org_rec.rei_information6, 'Z',
			 l_rei_rec.rei_information6,'Y');
		   END IF; -- IF l_noa_code in

		   -- Pre tax waiver -- Bug 4653096
			IF l_noa_code in
			 ( '100', '101', '107', '108', '120',
			 '124', '130','132', '140', '141',
			 '142', '143', '145','146', '147',
			 '148','170', '190' ) THEN
				 set_ei(l_org_rec.rei_information9, 'N',
				 l_rei_rec.rei_information9,'Y');
			ELSE
				 set_ei(l_org_rec.rei_information9,NULL,
					 l_rei_rec.rei_information9,'Y');
			END IF;


		-- Health Plan
		   set_ei(l_org_rec.rei_information5, 'ZZ',
			 l_rei_rec.rei_information5,'Y');
		-- Date Temp Eligibility FEHB
		   IF l_noa_code in
			 ( '115', '122', '149', '171') and
			   nvl(l_tenure,hr_api.g_varchar2) = '0' THEN
			 set_ei(l_org_rec.rei_information4,
			  fnd_date.date_to_canonical(add_months(nvl(p_effective_date,TRUNC(sysdate)),12)+1),
			 l_rei_rec.rei_information4,'Y');
		   ELSE
			 set_ei(l_org_rec.rei_information4,
			 NULL,l_rei_rec.rei_information4,'Y');
		   END IF; -- IF l_noa_code in Date Temp Eligibility FEHB

		-- FEGLI Eligibility Expiration
		   IF nvl(l_fegli,hr_api.g_varchar2) <> 'A0' AND
		   l_noa_code NOT IN ('130','132','145','147','115', '122', '149', '171') THEN -- Bug 4669419
			 set_ei(l_org_rec.rei_information10,
			  fnd_date.date_to_canonical(nvl(p_effective_date,TRUNC(sysdate))+31),
			 l_rei_rec.rei_information10,'Y');
		   ELSE
			 set_ei(l_org_rec.rei_information10,NULL,
			 l_rei_rec.rei_information10,'Y');
		   END IF;
		 -- TSP SCD
			IF nvl(l_retirement_plan,hr_api.g_varchar2)
			  in ('D','K','L','M','N','P') THEN
			 set_ei(l_org_rec.rei_information12,
			 fnd_date.date_to_canonical(nvl(l_scd,TRUNC(sysdate))),
			 l_rei_rec.rei_information12,'Y');
			ELSE
			 set_ei(l_org_rec.rei_information12,NULL,
			 l_rei_rec.rei_information12,'Y');
			END IF; -- IF nvl(l_retirement_pl
		 -- TSP Status
			IF nvl(l_retirement_plan,hr_api.g_varchar2)
			  in ('D','K','L','M','N','P') THEN
			 set_ei(l_org_rec.rei_information15,'E',
			 l_rei_rec.rei_information15,'Y');-- Bug# 8622486 modified I to E
			ELSIF nvl(l_retirement_plan,hr_api.g_varchar2)
			  in ('2','4','5') THEN
			 set_ei(l_org_rec.rei_information15,NULL,
			 l_rei_rec.rei_information15,'Y');
			ELSIF nvl(l_retirement_plan,hr_api.g_varchar2)
			  in ('1','3','8','9','C','E','F','G','H','R','T',
				  'W' ) THEN
			 set_ei(l_org_rec.rei_information15,'E',
			 l_rei_rec.rei_information15,'Y');
			ELSE
			 set_ei(l_org_rec.rei_information15,NULL,
			 l_rei_rec.rei_information15,'Y');
			END IF; -- IF nvl(l_retirement_plan,hr_api.
		 -- TSP Status Date
			IF NVL(l_retirement_plan,hr_api.g_varchar2)
			NOT IN ('2','4','5') THEN
					set_ei(l_org_rec.rei_information16,fnd_date.date_to_canonical(l_effective_date),
					l_rei_rec.rei_information16,'Y');
					set_ei(l_org_rec.rei_information18,NULL,l_rei_rec.rei_information18,'Y'); --  TSP Emp Contrib Elig Date
			ELSE
				 set_ei(l_org_rec.rei_information16,NULL, l_rei_rec.rei_information16,'Y');
				 set_ei(l_org_rec.rei_information18,NULL,l_rei_rec.rei_information18,'Y');  -- TSP Emp Contrib Elig Date
			END IF; -- -- TSP Status Date
		--Begin Bug# 8622486
		 -- TSP Agency Contrib Elig Date
			IF NVL(l_retirement_plan,hr_api.g_varchar2) IN ('D', 'K', 'L', 'M', 'N', 'P') THEN
			set_ei(l_org_rec.rei_information17,fnd_date.date_to_canonical(l_effective_date), l_rei_rec.rei_information17,'Y');
			/*
			 -- Get Payroll ID
				FOR l_cur_payroll_id IN c_payroll_id(l_pa_request_id) LOOP
					l_payroll_id := l_cur_payroll_id.payroll_id;
				END LOOP;
			--Bug#6312182 Changed the logic to determine TSP Agency Contribution Eligibilty date.
				IF to_number(to_char(l_effective_date,'MM')) BETWEEN 6 AND 11 THEN
					FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(l_effective_date+365,'YYYY'), '06') LOOP
						l_start_date := l_cur_start_date.start_date;
					END LOOP;
				ELSE
					FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(l_effective_date+31,'YYYY'), '12') LOOP
						l_start_date := l_cur_start_date.start_date;
					END LOOP;
				END IF; -- IF to_number(to_char(l_effective_date,'MM'))
			--Bug#6312182
				set_ei(l_org_rec.rei_information17,fnd_date.date_to_canonical(l_start_date), l_rei_rec.rei_information17,'Y');
			*/
			--End Bug# 8622486
			ELSE
				set_ei(l_org_rec.rei_information17,NULL,l_rei_rec.rei_information17,'Y');
			END IF; -- IF NVL(l_retirement_plan,hr_a
		 -- TSP Emp Contrib Elig Date

		END IF; -- If Family code is Appointment

		/*
			############ For Conversion to Appointment and Extension action #################
		*/

                 --8793163 For Dual Actions Benefits need to defaulted even if second action is conversion to appointment
		IF (l_family_code = 'CONV_APP' OR nvl(l_second_noa_family_code,hr_api.g_varchar2) = 'CONV_APP') OR l_family_code = 'EXT_NTE' THEN
			fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bus_group_id);
			-- Check if FEHB exists
			l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name('Health Benefits',l_bus_group_id,l_effective_date,null);
			FOR l_element_entry_cur IN c_element_entry(p_assignment_id , l_new_element_name, l_effective_date)  LOOP
				l_fehb_exists := TRUE;
				hr_utility.set_location('Health benefits present',111);
				EXIT;
			END LOOP;
			-- Check if FEHB Pre tax exists
			IF l_fehb_exists = FALSE THEN
				l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name('Health Benefits Pre tax',l_bus_group_id,l_effective_date,null);
				FOR l_element_entry_cur IN c_element_entry(p_assignment_id , l_new_element_name, l_effective_date)  LOOP
					l_fehb_exists := TRUE;
					hr_utility.set_location('Health benefits pre tax present',111);
					EXIT;
				END LOOP;
			END IF;

			IF l_fehb_exists = TRUE THEN
				FOR l_cur_element IN c_element_value(l_new_element_name,p_assignment_id, l_effective_date) LOOP
					  IF l_cur_element.ipv_name = 'Enrollment' THEN
						l_enrollment_option := l_cur_element.screen_entry_value;
					  ELSIF l_cur_element.ipv_name = 'Health Plan' THEN
						l_health_plan := l_cur_element.screen_entry_value;
					  ELSIF l_cur_element.ipv_name = 'Pre tax Waiver' THEN
						l_pre_tax_waiver := l_cur_element.screen_entry_value;
					  END IF;
				END LOOP;
			END IF;
-- Bug 4702325
   l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name('FEGLI',l_bus_group_id,l_effective_date,null);
   FOR l_cur_element IN c_element_value(l_new_element_name,p_assignment_id, l_effective_date) LOOP
     IF l_cur_element.ipv_name = 'FEGLI' THEN
       l_prev_fegli:= l_cur_element.screen_entry_value;
     END IF;
   END LOOP;

			hr_utility.set_location('Option' || l_enrollment_option,111);
			hr_utility.set_location('Health Plan' || l_health_plan,111);
			hr_utility.set_location('Prev. FEGLI ' || l_prev_fegli,111);
			hr_utility.set_location('l_person_id ' || l_person_id,111);
			hr_utility.set_location('p_effective_date ' || p_effective_date,111);

			 ghr_history_fetch.fetch_peopleei
						(p_person_id          =>  l_person_id,
						 p_information_type   =>  'GHR_US_PER_BENEFIT_INFO',
						 p_date_effective     =>  nvl(l_effective_date,trunc(sysdate)),
						 p_per_ei_data        =>  l_per_ei_data
						 );

			l_date_temp_elig := fnd_date.canonical_to_date(l_per_ei_data.pei_information5);
			l_agency_contrib_date := fnd_date.canonical_to_date(l_per_ei_data.pei_information14);

			hr_utility.set_location('l_date_temp_elig' || l_per_ei_data.pei_information5,111);
			--8793163 For Dual Actions Benefits need to defaulted even if second action is conversion to appointment
			IF l_family_code = 'CONV_APP' OR nvl(l_second_noa_family_code,hr_api.g_varchar2) = 'CONV_APP' THEN
				IF l_fehb_exists = FALSE OR (l_fehb_exists = TRUE AND NVL(l_enrollment_option,'Z') = 'Z') THEN
					-- FEHB Eligibility expires

					--8793163 Added for second noa code
					IF l_noa_code IN ('500', '501', '507', '508', '520', '524', '540', '541', '542', '543', '546', '548', '570', '590') OR
					   l_second_noa_code IN ('500', '501', '507', '508', '520', '524', '540', '541', '542', '543', '546', '548', '570', '590') THEN
						hr_utility.set_location('inside 1st',121);
						set_ei(l_org_rec.rei_information3, fnd_date.date_to_canonical(nvl(p_effective_date,sysdate)+60),l_rei_rec.rei_information3,'Y');
					END IF;

 				        --8793163 Added for second noa code
					-- FEHB Temp eligibility expires
					IF l_noa_code IN ('515','522','549','571') OR
					   l_second_noa_code IN ('515','522','549','571')  THEN
						 set_ei(l_org_rec.rei_information4,
						  fnd_date.date_to_canonical(add_months(nvl(l_effective_date,TRUNC(sysdate)),12)+1),l_rei_rec.rei_information4,'Y');
					END IF;
					-- Health Plan
					IF NVL(l_health_plan,'ZZ') = 'ZZ' THEN
						set_ei(l_org_rec.rei_information5, 'ZZ', l_rei_rec.rei_information5,'Y');
					END IF; -- Health Plan IF l_fehb_exists = FALSE OR (l_fehb_
					-- Enrollment
					set_ei(l_org_rec.rei_information6, 'X', l_rei_rec.rei_information6,'Y');
					-- Pre Tax waiver

					--8793163 Added for second noa code
					IF l_noa_code IN ('500','501','507','508','520','524','540','541','542','543','546','548','570','590') OR
					   l_second_noa_code IN ('500','501','507','508','520','524','540','541','542','543','546','548','570','590') THEN
						set_ei(l_org_rec.rei_information9, 'N', l_rei_rec.rei_information9,'Y');
					END IF;
				END IF; -- IF l_fehb_exists = FALSE OR

				-- FEGLI Eligibility expires
				IF NVL(l_fegli,hr_api.g_varchar2) <> 'A0' AND
       NVL(l_prev_fegli,hr_api.g_varchar2) = 'A0'  THEN
					set_ei(l_org_rec.rei_information10, fnd_date.date_to_canonical(nvl(l_effective_date,TRUNC(sysdate))+31), l_rei_rec.rei_information10,'Y');
				END IF;

				-- Check if TSP exists
				l_new_element_name := NULL;
				l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name('TSP',l_bus_group_id,l_effective_date,null);
				FOR l_element_entry_cur IN c_element_entry(p_assignment_id , l_new_element_name, l_effective_date)  LOOP
					l_tsp_exists := TRUE;
					hr_utility.set_location('TSP present',111);
					EXIT;
				END LOOP;

				IF l_tsp_exists = TRUE THEN
					FOR l_cur_element IN c_element_value(l_new_element_name,p_assignment_id, l_effective_date) LOOP
					  IF l_cur_element.ipv_name = 'Status' then
						l_tsp_status := substr(l_cur_element.screen_entry_value,1,1);
					  ELSIF l_cur_element.ipv_name = 'Status Date' then
						l_tsp_status_date := fnd_date.canonical_to_date(l_cur_element.screen_entry_value);
					  END IF;
					END LOOP;
				END IF; -- IF l_tsp_exists = TRUE TH

				-- TSP SCD
				IF nvl(l_retirement_plan,hr_api.g_varchar2) IN ('D','K','L','M','N','P') AND l_tsp_status IS NULL THEN
				 set_ei(l_org_rec.rei_information12, fnd_date.date_to_canonical(nvl(l_scd,TRUNC(sysdate))), l_rei_rec.rei_information12,'Y');
				ELSE
				 set_ei(l_org_rec.rei_information12,NULL, l_rei_rec.rei_information12,'Y');
				END IF; -- IF nvl(l_retirement_pl

			 -- TSP Status
				 hr_utility.set_location('TSP status' || l_tsp_status,111);
				IF nvl(l_retirement_plan,hr_api.g_varchar2) IN ('D','K','L','M','N','P') AND l_tsp_status IS NULL THEN
					 set_ei(l_org_rec.rei_information15,'E', l_rei_rec.rei_information15,'Y');--Begin Bug# 8622486 modified I to E
				ELSIF nvl(l_retirement_plan,hr_api.g_varchar2) IN ('2','4','5') THEN
					 set_ei(l_org_rec.rei_information15,NULL, l_rei_rec.rei_information15,'Y');
				ELSIF nvl(l_retirement_plan,hr_api.g_varchar2) IN ('1','3','8','9','C','E','F','G','H','R','T','W' ) and l_tsp_status IS NULL THEN
					 set_ei(l_org_rec.rei_information15,'E', l_rei_rec.rei_information15,'Y');
				ELSE
					 set_ei(l_org_rec.rei_information15,NULL, l_rei_rec.rei_information15,'Y');
				END IF; -- IF nvl(l_retirement_plan,hr_api.

			 -- TSP Status Date
				IF NVL(l_retirement_plan,hr_api.g_varchar2) NOT IN ('2','4','5') AND l_tsp_status_date IS NULL THEN
					set_ei(l_org_rec.rei_information16,fnd_date.date_to_canonical(l_effective_date), l_rei_rec.rei_information16,'Y');
				ELSE
					set_ei(l_org_rec.rei_information16,NULL, l_rei_rec.rei_information16,'Y');
				END IF; -- -- TSP Status Date
			 --Begin Bug# 8622486
			 -- TSP Agency Contrib Elig Date
				IF NVL(l_retirement_plan,hr_api.g_varchar2) IN ('D', 'K', 'L', 'M', 'N', 'P') AND l_agency_contrib_date IS NULL THEN
				set_ei(l_org_rec.rei_information17,fnd_date.date_to_canonical(l_effective_date), l_rei_rec.rei_information17,'Y');
				/*
				 -- Get Payroll ID
					FOR l_cur_payroll_id IN c_payroll_id(l_pa_request_id) LOOP
						l_payroll_id := l_cur_payroll_id.payroll_id;
					END LOOP;
				--Bug#6312182 Changed the logic to determine TSP Agency Contribution Eligibilty date.
				        IF to_number(to_char(l_effective_date,'MM')) BETWEEN 6 AND 11 THEN
                   		          	FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(l_effective_date+365,'YYYY'), '06') LOOP
							l_start_date := l_cur_start_date.start_date;
						END LOOP;
				        ELSE
				          	FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(l_effective_date+31,'YYYY'), '12') LOOP
							l_start_date := l_cur_start_date.start_date;
						END LOOP;

                                        END IF; -- IF to_number(to_char(l_effective_date,'MM'))
				--Bug#6312182
					set_ei(l_org_rec.rei_information17,fnd_date.date_to_canonical(l_start_date), l_rei_rec.rei_information17,'Y');
				*/
				--end Bug# 8622486
				ELSE
					set_ei(l_org_rec.rei_information17,NULL,l_rei_rec.rei_information17,'Y');
				END IF; -- IF NVL(l_retirement_plan,hr_a

			ELSIF l_family_code = 'EXT_NTE' THEN
				IF l_noa_code IN ('760','762') THEN
					hr_utility.set_location('l_enrollment_option ' || l_enrollment_option,121);
					hr_utility.set_location('l_date_temp_elig ' || to_char(l_date_temp_elig,'dd/mm/yyyy'),121);
					IF l_fehb_exists = TRUE AND NVL(l_enrollment_option,'Z') = 'Z' THEN
						-- FEHB Eligibility date
						hr_utility.set_location('Inside l_enrollment_option ' || l_enrollment_option,121);
						set_ei(l_org_rec.rei_information3,fnd_date.date_to_canonical(l_date_temp_elig+1),l_rei_rec.rei_information3,'Y');
						-- Enrollment
						IF l_date_temp_elig <= l_effective_date THEN
							set_ei(l_org_rec.rei_information6, 'X', l_rei_rec.rei_information6,'Y');
						END IF; -- IF l_date_temp_elig

					END IF; -- IF l_fehb_exists = TRUE
				END IF; -- IF l_noa_code IN ('760','762') THEN

				-- Health Plan
				IF l_fehb_exists = FALSE THEN
					set_ei(l_org_rec.rei_information5, 'ZZ', l_rei_rec.rei_information5,'Y');
				END IF; -- IF l_fehb_exists = FALSE THEN
			END IF; -- IF l_family_code = 'CONV_APP' THEN
		END IF; -- IF l_family_code = 'CONV_APP' OR l_family_code = 'EXT_NTE'
	END IF; -- If l_second_noa_code is not null
  END appt_benefits;
---Title38 Requirement...
-- populate rei_information with mddds_pay
-- GHR_US_PAR_MD_DDS_PAY
--

 Procedure mddds_pay is
   Begin

   -- Read from history if person id is not null
      hr_utility.set_location('Person inside mddds_pay is  ' || to_char(l_person_id),1);
     If l_assignment_id is not null then
      hr_utility.set_location('Person inside mddds_pay is  ' || to_char(l_person_id),1);

      l_refresh_flag   :=  l_per_refresh_flag;

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Full Time Status',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information9,  l_value,  l_rei_rec.rei_information9,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Length of Service',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information10, l_value,  l_rei_rec.rei_information10, l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Scarce Specialty',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information3,  l_value,  l_rei_rec.rei_information3,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Specialty or Board Certification',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information4,  l_value,  l_rei_rec.rei_information4,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Geographic Location',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information5,  l_value,  l_rei_rec.rei_information5,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Exceptional Qualifications',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information6,  l_value,  l_rei_rec.rei_information6,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Executive Position',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information7,  l_value,  l_rei_rec.rei_information7,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Dentist Post Graduate Training',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information8,  l_value,  l_rei_rec.rei_information8,  l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'Amount',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information11, l_value,  l_rei_rec.rei_information11, l_refresh_flag);

      if l_rei_rec.rei_information11 is null then
         l_rei_rec.rei_information11 := 0;
      end if;

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'MDDDS Special Pay',
           p_input_value_name     => 'MDDDS Special Pay NTE Date',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information12, l_value,  l_rei_rec.rei_information12, l_refresh_flag);

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'Premium Pay',
           p_input_value_name     => 'Premium Pay Ind',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information13, l_value,  l_rei_rec.rei_information13, l_refresh_flag);

    End if;
End mddds_pay;


--Title 38 requirement
-- Populate Premium_pay_ind for 855.
Procedure premium_pay_ind IS

BEGIN

   If l_assignment_id is not null then
      hr_utility.set_location('Person inside premium_pay_ind is  ' || to_char(l_person_id),1);
      l_refresh_flag   :=  l_per_refresh_flag;

      ghr_api.retrieve_element_entry_value
          (p_element_name         => 'Premium Pay',
           p_input_value_name     => 'Premium Pay Ind',
           p_assignment_id        =>  l_assignment_id,
           p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
           p_value                =>  l_value,
           p_multiple_error_flag  =>  l_multiple_error_flag
              );
      set_ei(l_org_rec.rei_information3, l_value,  l_rei_rec.rei_information3, l_refresh_flag);

   End If;

END premium_pay_ind;

      Procedure appt_transfer is                       -- set / reset l_update_rei
     Begin
          -- Read from history if person id is not null
       hr_utility.set_location('appt_transfer - person id  ' || l_person_id,1);
       --Bug 3128526. Changed p_person_id -> l_person_id
       If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
            ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_GROUP1',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
             --
             set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information7,l_rei_rec.rei_information3,l_refresh_flag);
             l_org_rec.rei_information3  :=  l_per_ei_data.pei_information7;
             --
             --set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information3,l_rei_rec.rei_information4,l_refresh_flag);
             --l_org_rec.rei_information4  :=  l_per_ei_data.pei_information3;

            --Bug 3128526. Added IF..ELSE to default the handicap code

             IF l_per_ei_data.pei_information11 is null THEN
               l_rei_rec.rei_information10 := '05';
             ELSE
               set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information11,l_rei_rec.rei_information10,l_refresh_flag);
               l_org_rec.rei_information10  :=  l_per_ei_data.pei_information11;
             END IF;
/*

	       set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information8,l_rei_rec.rei_information12,l_refresh_flag);
             l_org_rec.rei_information12 :=  l_per_ei_data.pei_information8;

             set_ei(l_org_rec.rei_information13,l_per_ei_data.pei_information9,l_rei_rec.rei_information13,l_refresh_flag);
             l_org_rec.rei_information13 :=  l_per_ei_data.pei_information9;
*/

             set_ei(l_org_rec.rei_information18,l_per_ei_data.pei_information5,l_rei_rec.rei_information18,l_refresh_flag);
             l_org_rec.rei_information18 :=  l_per_ei_data.pei_information5;

             hr_utility.set_location('RINO ' || l_rei_rec.rei_information17,1);
             hr_utility.set_location('RINO _CORE ' || l_per_ei_data.pei_information5,2);

             set_ei(l_org_rec.rei_information19,l_per_ei_data.pei_information4,l_rei_rec.rei_information19,l_refresh_flag);
             l_org_rec.rei_information19 :=  l_per_ei_data.pei_information4;

           l_per_ei_data               :=  null;

		 ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
              set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information5,l_rei_rec.rei_information6,l_refresh_flag);
              l_org_rec.rei_information6   := l_per_ei_data.pei_information5;

              l_per_ei_data               :=  null;

             ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
            hr_utility.set_location('original ' || l_org_rec.rei_information3,1);
            hr_utility.set_location(' person' || l_per_ei_data.pei_information7,1);
            hr_utility.set_location('rei ' || l_rei_rec.rei_information3,1);

             -- This seems wrong ???? set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information7,l_rei_rec.rei_information3,l_refresh_flag);
            -- l_org_rec.rei_information3  :=  l_per_ei_data.pei_information7;

            hr_utility.set_location('original ' || l_org_rec.rei_information3,1);
            hr_utility.set_location(' person' || l_per_ei_data.pei_information7,1);
            hr_utility.set_location('rei ' || l_rei_rec.rei_information3,1);

             set_ei(l_org_rec.rei_information9,l_per_ei_data.pei_information5,l_rei_rec.rei_information9,l_refresh_flag);
             l_org_rec.rei_information9  :=  l_per_ei_data.pei_information5;

             set_ei(l_org_rec.rei_information16,l_per_ei_data.pei_information4,l_rei_rec.rei_information16,l_refresh_flag);
             l_org_rec.rei_information16 :=  l_per_ei_data.pei_information4;
             set_ei(l_org_rec.rei_information21,l_per_ei_data.pei_information3,l_rei_rec.rei_information21,l_refresh_flag);
             l_org_rec.rei_information21 :=  l_per_ei_data.pei_information3;

             l_per_ei_data               :=  null;

 --bug 4443968
	   ghr_history_fetch.fetch_peopleei
             (p_person_id          =>  l_person_id,
              p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
              p_date_effective     =>  nvl (p_effective_date, trunc(sysdate)),
              p_per_ei_data        =>  l_per_ei_data
             );

	set_ei(l_org_rec.rei_information25,l_per_ei_data.pei_information12,l_rei_rec.rei_information25,l_refresh_flag);
               l_org_rec.rei_information25 := l_per_ei_data.pei_information12;

	l_per_ei_data  :=  null;


	IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
			 --  Get PER_LEAVE Information
			 hr_utility.set_location('per_leave_info' ,1);
		   ghr_history_fetch.fetch_peopleei
		   (p_person_id          =>  l_person_id,
			p_information_type   =>  'GHR_US_PER_LEAVE_INFO',
			p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
			p_per_ei_data        =>  l_per_ei_data
		   );
			IF l_per_ei_data.pei_information4 is NULL THEN
			   l_rei_rec.rei_information22 := 'N';
			ELSE
			 set_ei(l_org_rec.rei_information22,l_per_ei_data.pei_information4,l_rei_rec.rei_information22,l_refresh_flag);
			END IF;
		   l_per_ei_data               :=  null;
		  --Gain Or Lose
			 set_ei(l_org_rec.rei_information23,'1B',l_rei_rec.rei_information23,l_refresh_flag);
		END IF;		-- IF ghr_utility.is_ghr_nfc = 'TRUE'
       End if;
        If l_assignment_id is not null then
          l_refresh_flag := l_asg_refresh_flag;
            ghr_history_fetch.fetch_asgei
            (p_assignment_id          =>  l_assignment_id,
             p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
             p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
             p_asg_ei_data       	  =>  l_asg_ei_data
             );

          -- added on 2-oct-98 to autopopulate date arrived personnel office by the
          -- effective date
          --    set_ei(l_org_rec.rei_information7,fnd_date.date_to_canonical(p_effective_date),
          --           l_rei_rec.rei_information7,l_refresh_flag);
          --  set_ei(l_org_rec.rei_information7,l_asg_ei_data.aei_information3,
          --         l_rei_rec.rei_information7,l_refresh_flag);
          --  l_org_rec.rei_information7   :=  l_asg_ei_data.aei_information3;

         -- added on 3-dec-99 -- Refer bug 963634
       for c_get_eff_rec in c_get_effective_date  loop
          set_ei(l_org_rec.rei_information7,fnd_date.date_to_canonical(c_get_eff_rec.effective_date),
             l_rei_rec.rei_information7,l_refresh_flag);
          exit;
       end loop;
              set_ei(l_org_rec.rei_information11,l_asg_ei_data.aei_information6,l_rei_rec.rei_information11,l_refresh_flag);
              l_org_rec.rei_information11  :=  l_asg_ei_data.aei_information6;
-- 3 to 8
              set_ei(l_org_rec.rei_information14,l_asg_ei_data.aei_information8,l_rei_rec.rei_information14,l_refresh_flag);
              l_org_rec.rei_information14  :=  l_asg_ei_data.aei_information8;

              set_ei(l_org_rec.rei_information17,l_asg_ei_data.aei_information9,l_rei_rec.rei_information17,l_refresh_flag);
              l_org_rec.rei_information17  :=  l_asg_ei_data.aei_information9;

            l_asg_ei_data                :=  null;
             /*ghr_api.retrieve_element_entry_value
              (p_element_name         => 'Within Grade Increase',
               p_input_value_name     => 'Date Due',
               p_assignment_id        =>  l_assignment_id,
               p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
               p_value                =>  l_value,
               p_multiple_error_flag  =>  l_multiple_error_flag
              );
                set_ei(l_org_rec.rei_information7,l_value,l_rei_rec.rei_information6,l_refresh_flag);
                l_org_rec.rei_information7 := l_value; */
          End if;
          --Check whether the follwing assignment would work correct in all cases
          If l_position_id is not null then
            l_refresh_flag := l_pos_refresh_flag;
              ghr_history_fetch.fetch_positionei
              (p_position_id            =>  l_position_id,
               p_information_type  	  =>  'GHR_US_POS_GRP1',
               p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
               p_pos_ei_data       	  =>  l_pos_ei_data
              );
              If l_pos_ei_data.position_extra_info_id is not null then
                set_ei(l_org_rec.rei_information15,l_pos_ei_data.poei_information12,l_rei_rec.rei_information15,l_refresh_flag);
                l_org_rec.rei_information15  :=  l_pos_ei_data.poei_information12;
              End if;
              l_pos_ei_data                :=  null;
          End if;
           hr_utility.set_location('Appt_transfer Family Code: '||l_noa_family_code,10);
      IF NVL(l_noa_family_code,'C') <> 'CORRECT' THEN
          OPEN c_noac_130;
          FETCH c_noac_130 INTO l_dlei_date;
            IF l_dlei_date is not null THEN
              set_ei(l_org_rec.rei_information20,
               fnd_date.date_to_canonical(l_dlei_date),
                    l_rei_rec.rei_information20,'Y');
            ELSE
              set_ei(l_org_rec.rei_information20,
                null,l_rei_rec.rei_information20,'Y');
            END IF;
          CLOSE c_noac_130;
      END IF;
    End appt_transfer;


    Procedure conv_appt is
       Begin
          -- Read from history if person id is not null
           If l_person_id is not null then
             l_refresh_flag := l_per_refresh_flag;
             ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_GROUP1',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
               set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
               l_org_rec.rei_information3  :=  l_per_ei_data.pei_information3;
               set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information11,l_rei_rec.rei_information7,l_refresh_flag);
               l_org_rec.rei_information7  :=  l_per_ei_data.pei_information11;
               set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information5,l_rei_rec.rei_information12,l_refresh_flag);
               l_org_rec.rei_information12 :=  l_per_ei_data.pei_information5;
               set_ei(l_org_rec.rei_information13,l_per_ei_data.pei_information4,l_rei_rec.rei_information13,l_refresh_flag);
               l_org_rec.rei_information13 :=  l_per_ei_data.pei_information4;
             l_per_ei_data               :=  null;

		 ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
                set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information5,l_rei_rec.rei_information4,l_refresh_flag);
                l_org_rec.rei_information4   := l_per_ei_data.pei_information5;
             l_per_ei_data               :=  null;
             ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
               set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information5,l_rei_rec.rei_information6,l_refresh_flag);
               l_org_rec.rei_information6  :=  l_per_ei_data.pei_information5;
               set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information4,l_rei_rec.rei_information10,l_refresh_flag);
               l_org_rec.rei_information10 :=  l_per_ei_data.pei_information4;
             set_ei(l_org_rec.rei_information21,l_per_ei_data.pei_information3,l_rei_rec.rei_information21,l_refresh_flag);
             l_org_rec.rei_information21 :=  l_per_ei_data.pei_information3;
              l_per_ei_data               :=  null;
             ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
             p_information_type   =>  'GHR_US_PER_CONVERSIONS',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
          --
          -- commented out the following as autopopulating is not required for these fields
          -- 13-oct-98 by skutteti for the conversion rpa ddf update requirement
          --   set_ei(l_org_rec.rei_information14,l_per_ei_data.pei_information3,l_rei_rec.rei_information14,l_refresh_flag);
          --   l_org_rec.rei_information14 :=  l_per_ei_data.pei_information3;
          --   set_ei(l_org_rec.rei_information15,l_per_ei_data.pei_information4,l_rei_rec.rei_information15,l_refresh_flag);
          --   l_org_rec.rei_information15 :=  l_per_ei_data.pei_information4;
          --   set_ei(l_org_rec.rei_information16,l_per_ei_data.pei_information5,l_rei_rec.rei_information16,l_refresh_flag);
          --   l_org_rec.rei_information16 :=  l_per_ei_data.pei_information5;
          --   set_ei(l_org_rec.rei_information17,l_per_ei_data.pei_information7,l_rei_rec.rei_information17,l_refresh_flag);
          --   l_org_rec.rei_information17 :=  l_per_ei_data.pei_information7;
          --   set_ei(l_org_rec.rei_information18,l_per_ei_data.pei_information6,l_rei_rec.rei_information18,l_refresh_flag);
          --   l_org_rec.rei_information18 :=  l_per_ei_data.pei_information6;
             l_per_ei_data               :=  null;
         --  Get PER_LEAVE Information
         hr_utility.set_location('per_leave_info' ,1);
		IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
		   ghr_history_fetch.fetch_peopleei
		   (p_person_id          =>  l_person_id,
			p_information_type   =>  'GHR_US_PER_LEAVE_INFO',
			p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
			p_per_ei_data        =>  l_per_ei_data
		   );
			IF l_per_ei_data.pei_information4 is NULL THEN
			   l_rei_rec.rei_information22 := 'N';
			ELSE
			 set_ei(l_org_rec.rei_information22,l_per_ei_data.pei_information4,l_rei_rec.rei_information22,l_refresh_flag);
		   END IF;
		   l_per_ei_data               :=  null;
        END IF; -- IF ghr_utility.is_ghr_nfc = 'TR
  End if;
          If NVL(l_assignment_id,p_assignment_id) is not null then
             l_refresh_flag := l_asg_refresh_flag;
            ghr_history_fetch.fetch_asgei
            (p_assignment_id          =>  l_assignment_id,
             p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
             p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
             p_asg_ei_data       	  =>  l_asg_ei_data
             );
             --Begin Bug#4126188
			--set_ei(l_org_rec.rei_information5,l_asg_ei_data.aei_information3,l_rei_rec.rei_information5,l_refresh_flag);
			 --End Bug#4126188
			set_ei(l_org_rec.rei_information8,l_asg_ei_data.aei_information8,l_rei_rec.rei_information8,l_refresh_flag);
			set_ei(l_org_rec.rei_information11,l_asg_ei_data.aei_information9,l_rei_rec.rei_information11,l_refresh_flag);
             -- Start Bug 1318341

             --Bug#5527363 Modified the l_assignment_id parameter passed.
             ghr_api.retrieve_element_entry_value
              (p_element_name         => 'Within Grade Increase',
               p_input_value_name     => 'Date Due',
               p_assignment_id        =>  NVL(l_assignment_id,p_assignment_id),
               p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
               p_value                =>  l_value,
               p_multiple_error_flag  =>  l_multiple_error_flag
              );

                set_ei(l_org_rec.rei_information19,l_value,l_rei_rec.rei_information19,l_refresh_flag);
             -- End Bug 1318341
             l_asg_ei_data                :=  null;
          End if;
          --Check whether the follwing assignment would work correct in all cases
          If l_position_id is not null then
             l_refresh_flag := l_pos_refresh_flag;
           -- Make sure that the foll. check is correct
            ghr_history_fetch.fetch_positionei
            (p_position_id            =>  l_position_id,
             p_information_type  	  =>  'GHR_US_POS_GRP1',
             p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
             p_pos_ei_data       	  =>  l_pos_ei_data
             );
              set_ei(l_org_rec.rei_information9,l_pos_ei_data.poei_information12,l_rei_rec.rei_information9,l_refresh_flag);
             l_pos_ei_data                :=  null;
          End if;
		  --Bug#4126188 Begin
		FOR c_posn_to_frm IN c_position LOOP
			l_from_position_id :=c_posn_to_frm.from_position_id;
			l_to_position_id := c_posn_to_frm.to_position_id;
		END LOOP;

			ghr_history_fetch.fetch_positionei
			(p_position_id            =>  l_from_position_id,
			p_information_type       =>  'GHR_US_POS_GRP1',
			p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
			p_pos_ei_data            =>  l_pos_ei_data
			);
			l_from_poid := l_pos_ei_data.poei_information3;
			l_pos_ei_data := NULL;

			ghr_history_fetch.fetch_positionei
			(p_position_id            =>  l_to_position_id,
			p_information_type       =>  'GHR_US_POS_GRP1',
			p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
			p_pos_ei_data            =>  l_pos_ei_data
			);
			l_to_poid := l_pos_ei_data.poei_information3;
			l_pos_ei_data := NULL;
			IF l_from_poid = l_to_poid THEN
				IF l_noa_family_code = 'CORRECT' THEN
					ghr_history_api.get_g_session_var(l_session);
					l_session1 := l_session;
					l_session.noa_id_correct := NULL;
					ghr_history_api.reinit_g_session_var;
					ghr_history_api.set_g_session_var(l_session);
					ghr_history_fetch.fetch_asgei
						(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
						 p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
						 p_date_effective         =>  p_effective_date-1,
						 p_asg_ei_data       	  =>  l_asg_ei_data );
					ghr_history_api.reinit_g_session_var;
					ghr_history_api.set_g_session_var(l_session1);
				ELSE
					ghr_history_fetch.fetch_asgei
					(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
					p_information_type  	  =>  'GHR_US_ASG_NON_SF52',
					p_date_effective         =>  p_effective_date,
					p_asg_ei_data       	  =>  l_asg_ei_data);
				END IF;
				set_ei(l_org_rec.rei_information5,l_asg_ei_data.aei_information3,l_rei_rec.rei_information5,l_refresh_flag);
		/*Start - Bug 7295154*/
			ELSIF l_to_poid IS NULL AND l_noa_family_code = 'CORRECT'  THEN
			  ghr_history_fetch.fetch_asgei
				(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
				p_information_type       =>  'GHR_US_ASG_NON_SF52',
				p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
				p_asg_ei_data            =>  l_asg_ei_data
				);
			 set_ei(l_org_rec.rei_information5,l_asg_ei_data.aei_information3,l_rei_rec.rei_information5,'Y');
		/*End - Bug 7295154*/
			ELSE
				FOR c_get_eff_rec in c_get_effective_date
				LOOP
					IF (l_rei_rec.rei_information5 IS NULL) OR
					(l_noa_family_code = 'CORRECT'  AND l_rei_rec.rei_information5 IS NOT NULL) THEN
					set_ei(l_org_rec.rei_information5,fnd_date.date_to_canonical(c_get_eff_rec.effective_date),
					l_rei_rec.rei_information5,l_refresh_flag);
					END IF;
					exit;
				END LOOP;
			END IF;
		--Bug#4126188 End
          hr_utility.set_location('conv_Appt Family Code: '||l_noa_family_code,10);
          IF NVL(l_noa_family_code,'C') <> 'CORRECT' THEN
              OPEN c_noac_5xx;
              FETCH c_noac_5xx INTO l_dlei_date;
              IF l_dlei_date is not null THEN
                FOR get_pay_grd  in c_pp_and_grade LOOP
                  IF nvl(get_pay_grd.to_grade_or_level,0)
                    > nvl(get_pay_grd.from_grade_or_level,1)
                   and get_pay_grd.to_pay_plan = get_pay_grd.from_pay_plan
                  THEN
                    set_ei(l_org_rec.rei_information20,
                      fnd_date.date_to_canonical(l_dlei_date),
                      l_rei_rec.rei_information20,'Y');
                  END IF;
                END LOOP;
              ELSE
                set_ei(l_org_rec.rei_information20,
                  null,l_rei_rec.rei_information20,'Y');
              END IF;
              CLOSE c_noac_5xx;
          END IF;
       End conv_appt;

       Procedure return_to_duty
       is
       Begin

         If l_person_id  is not null then
          l_refresh_flag := l_per_refresh_flag;
             ghr_history_fetch.fetch_peopleei
             (p_person_id          =>  l_person_id,
              p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
              p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
              p_per_ei_data        =>  l_per_ei_data
             );
               set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information5,l_rei_rec.rei_information3,l_refresh_flag);
             l_per_ei_data  := null;

             ghr_history_fetch.fetch_peopleei
             (p_person_id          =>  l_person_id,
              p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
              p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
              p_per_ei_data        =>  l_per_ei_data
              );
               set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);

             -- Bug 3966783 changes
             IF NVL(l_noa_family_code,'C') = 'CORRECT' THEN
                ghr_history_fetch.fetch_peopleei
                (p_person_id          =>  l_person_id,
                 p_information_type   =>  'GHR_US_PER_GROUP1',
                 p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
                 p_per_ei_data        =>  l_per_ei_data
                 );
                 set_ei(l_org_rec.rei_information8,l_per_ei_data.pei_information4,l_rei_rec.rei_information8,l_refresh_flag);
              END IF;
              l_per_ei_data  := null;
         End if;

        If l_assignment_id is not null then
          l_refresh_flag := l_asg_refresh_flag;
            ghr_history_fetch.fetch_asgei
            (p_assignment_id      =>  l_assignment_id,
             p_information_type   =>  'GHR_US_ASG_NON_SF52',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_asg_ei_data        =>  l_asg_ei_data
            );
               set_ei(l_org_rec.rei_information6,l_asg_ei_data.aei_information6,l_rei_rec.rei_information6,l_refresh_flag);
               set_ei(l_org_rec.rei_information7,l_asg_ei_data.aei_information8,l_rei_rec.rei_information7,l_refresh_flag);

            l_asg_ei_data  := null;
            -- do not populate within grade increase.

          End if;
      End return_to_duty;

     Procedure  reassignment is
     Begin
       If l_assignment_id is not null then
          l_refresh_flag := l_asg_refresh_flag;
           ghr_history_fetch.fetch_asgei
           (p_assignment_id      =>  l_assignment_id,
            p_information_type   =>  'GHR_US_ASG_NON_SF52',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_asg_ei_data        =>  l_asg_ei_data
           );
               set_ei(l_org_rec.rei_information4,l_asg_ei_data.aei_information8,l_rei_rec.rei_information4,l_refresh_flag);
               set_ei(l_org_rec.rei_information6,l_asg_ei_data.aei_information9,l_rei_rec.rei_information6,l_refresh_flag);

          l_asg_ei_data  := null;
       End if;
       If l_position_id is not null then
          l_refresh_flag := l_pos_refresh_flag;
           ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_position_id,
            p_information_type   =>  'GHR_US_POS_GRP1',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
            );
             set_ei(l_org_rec.rei_information5,l_pos_ei_data.poei_information12,l_rei_rec.rei_information5,l_refresh_flag);
		   l_pos_ei_data := null;

        /* Bug # 1794090

           ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_position_id,
            p_information_type   =>  'GHR_US_POS_GRP2',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
            );
             set_ei(l_org_rec.rei_information3,l_pos_ei_data.poei_information12,l_rei_rec.rei_information3,l_refresh_flag);

           l_pos_ei_data := null;
      */
       End if;
	   --Bug#4126188 Begin
		FOR c_posn_to_frm IN c_position LOOP
			l_from_position_id :=c_posn_to_frm.from_position_id;
			l_to_position_id := c_posn_to_frm.to_position_id;
		END LOOP;
			ghr_history_fetch.fetch_positionei
			(p_position_id            =>  l_from_position_id,
			p_information_type       =>  'GHR_US_POS_GRP1',
			p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
			p_pos_ei_data            =>  l_pos_ei_data
			);
			l_from_poid := l_pos_ei_data.poei_information3;
			l_pos_ei_data := NULL;

			ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_to_position_id,
            p_information_type   =>  'GHR_US_POS_GRP1',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
            );
			l_to_poid := l_pos_ei_data.poei_information3;
			l_pos_ei_data := NULL;
			IF l_from_poid = l_to_poid THEN
				IF nvl(l_noa_family_code,'C') = 'CORRECT' THEN

	              ghr_history_api.get_g_session_var(l_session);
				  l_session1 := l_session;
                  l_session.noa_id_correct := NULL;
				  ghr_history_api.reinit_g_session_var;
				  ghr_history_api.set_g_session_var(l_session);
					ghr_history_fetch.fetch_asgei
						(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
						p_information_type       =>  'GHR_US_ASG_NON_SF52',
						p_date_effective         =>  p_effective_date-1,
						p_asg_ei_data            =>  l_asg_ei_data
						);
						ghr_history_api.reinit_g_session_var;
						ghr_history_api.set_g_session_var(l_session1);
				ELSE
					ghr_history_fetch.fetch_asgei
						(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
						p_information_type       =>  'GHR_US_ASG_NON_SF52',
						p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
						p_asg_ei_data            =>  l_asg_ei_data
						);
				END IF;
				set_ei(l_org_rec.rei_information7,l_asg_ei_data.aei_information3,l_rei_rec.rei_information7,l_refresh_flag);
			ELSE
				FOR c_get_eff_rec in c_get_effective_date
				LOOP
				IF l_org_rec.rei_information7 IS NULL THEN
					set_ei(l_org_rec.rei_information7,fnd_date.date_to_canonical(c_get_eff_rec.effective_date),
					l_rei_rec.rei_information7,l_refresh_flag);
				ELSIF (nvl(l_noa_family_code,'C') = 'CORRECT' AND l_org_rec.rei_information7 IS NOT NULL) THEN
					set_ei(l_org_rec.rei_information7,fnd_date.date_to_canonical(c_get_eff_rec.effective_date),
					l_rei_rec.rei_information7,l_refresh_flag);
				END IF;
				exit;
				END LOOP;
			END IF;
		--Bug#4126188 End
     End reassignment;

      -- Added realign procedure to fix bug 3593584
     Procedure  realign is
     Begin
       -- Bug#3593584 The following variable is used in procedure realign
       -- to populate the Extra info only when noa_family_code = 'CORRECT'
       hr_utility.set_location('l_noa_family_code '|| l_noa_family_code,10);
       -- Bug#4089400 Moved the cursor to the begining of the main procedure.
       IF NVL(l_noa_family_code,'C') = 'CORRECT' THEN
         If l_assignment_id is not null then
          l_refresh_flag := l_asg_refresh_flag;
           ghr_history_fetch.fetch_asgei
           (p_assignment_id      =>  l_assignment_id,
            p_information_type   =>  'GHR_US_ASG_NON_SF52',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_asg_ei_data        =>  l_asg_ei_data
           );
               set_ei(l_org_rec.rei_information3,l_asg_ei_data.aei_information3,l_rei_rec.rei_information3,l_refresh_flag);
               l_asg_ei_data  := null;
       End if;
       If l_position_id is not null then
          l_refresh_flag := l_pos_refresh_flag;
           ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_position_id,
            p_information_type   =>  'GHR_US_POS_GRP1',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
            );
           set_ei(l_org_rec.rei_information4,l_pos_ei_data.poei_information18,l_rei_rec.rei_information4,l_refresh_flag);
	   set_ei(l_org_rec.rei_information5,l_pos_ei_data.poei_information3,l_rei_rec.rei_information5,l_refresh_flag);
	   set_ei(l_org_rec.rei_information6,l_pos_ei_data.poei_information4,l_rei_rec.rei_information6,l_refresh_flag);
	   --Bug 3593584 Populate positions' organization,
	   set_ei(l_org_rec.rei_information8,l_pos_ei_data.poei_information21,l_rei_rec.rei_information8,l_refresh_flag);
	   set_ei(l_org_rec.rei_information11,l_pos_ei_data.poei_information5,l_rei_rec.rei_information11,l_refresh_flag);

	   l_pos_ei_data := null;

           ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_position_id,
            p_information_type   =>  'GHR_US_POS_GRP2',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
            );
           set_ei(l_org_rec.rei_information7,l_pos_ei_data.poei_information4,l_rei_rec.rei_information7,l_refresh_flag);
           l_pos_ei_data := null;

       End if;
     END IF;
     End realign;
     -- Added realign procedure to fix bug 3593584

  Procedure chg_data_element is
	cursor c_bg is
	SELECT 	business_group_id
	FROM		per_positions
	WHERE		position_id = l_position_id;
	l_agency_code	ghr_pa_requests.agency_code%type;
	l_bg_id		per_positions.business_group_id%type;
     Begin
       If  l_position_id is not null then
          l_refresh_flag := l_pos_refresh_flag;
	     ghr_history_fetch.fetch_positionei
           (p_position_id        =>  l_position_id,
            p_information_type   =>  'GHR_US_POS_GRP1',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_pos_ei_data        =>  l_pos_ei_data
           );
             set_ei(l_org_rec.rei_information3,l_pos_ei_data.poei_information3,l_rei_rec.rei_information3,l_refresh_flag);
           l_pos_ei_data := null;
		FOR c_bg_id	in c_bg LOOP
			l_bg_id := c_bg_id.business_group_id;
		END LOOP;
		l_agency_code	:= ghr_api.get_position_agency_code_pos
						(p_position_id		=>	l_position_id
						,p_business_group_id	=>	l_bg_id
                        ,p_effective_date       => nvl(p_effective_date,trunc(sysdate)));
            set_ei(l_org_rec.rei_information4,l_agency_code,l_rei_rec.rei_information4,l_refresh_flag);
			-- Begin Bug# 4126188
			set_ei(l_org_rec.rei_information5,fnd_date.date_to_canonical(p_effective_date),l_rei_rec.rei_information5,l_refresh_flag);
			-- End Bug# 4126188
       End if;

     End chg_data_element;

     Procedure chg_retire_plan is
     Begin
       If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
             set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information5,l_rei_rec.rei_information3,l_refresh_flag);
           l_per_ei_data  := null;

           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
             set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information3,l_rei_rec.rei_information4,l_refresh_flag);
             set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);
             set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information4,l_rei_rec.rei_information6,l_refresh_flag);
           l_per_ei_data  := null;
       End if;
     End chg_retire_plan;
     --
     --
     Procedure chg_scd is
     Begin
       If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
	   --Modified for EHRI reports 3675673
	     set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information5,l_rei_rec.rei_information3,l_refresh_flag);
             set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information4,l_rei_rec.rei_information4,l_refresh_flag);
     	     set_ei(l_org_rec.rei_information8,l_per_ei_data.pei_information7,l_rei_rec.rei_information8,l_refresh_flag);
			  set_ei(l_org_rec.rei_information9,l_per_ei_data.pei_information6,l_rei_rec.rei_information9,l_refresh_flag);
	     -- SCD Retirement

		  -- Bug 4164083 eHRI New Attribution Changes
       	     set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information8,l_rei_rec.rei_information10,l_refresh_flag);
 		     set_ei(l_org_rec.rei_information11,l_per_ei_data.pei_information9,l_rei_rec.rei_information11,l_refresh_flag);

		  -- End eHRI New Attribution Changes

	   --bug 4443968
	     set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information12,l_rei_rec.rei_information12,l_refresh_flag);

	     l_per_ei_data  := null;

           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
             set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);
           l_per_ei_data  := null;

           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
             set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information5,l_rei_rec.rei_information6,l_refresh_flag);
             set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information4,l_rei_rec.rei_information7,l_refresh_flag);
           l_per_ei_data  := null;

      End if;
     End chg_scd;
    --
    --Bug#2146912
    --
    Procedure scd_tsp is
    begin

      If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
           hr_utility.set_location('l_refresh_flag is ' || l_refresh_flag,1);
           ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
           );
             set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information6,
                    l_rei_rec.rei_information12,l_refresh_flag);
           l_per_ei_data  := null;

      End if;
    End scd_tsp;
    --
    --
    Procedure non_pay_duty  is
      l_special_info       ghr_api.special_information_type;
    begin

      If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
          hr_utility.set_location('l_refresh_flag is ' || l_refresh_flag,4);
          IF NVL(l_noa_family_code,'C') = 'CORRECT' THEN
             ghr_history_fetch.fetch_peopleei
             (p_person_id          =>  l_person_id,
              p_information_type   =>  'GHR_US_PER_GROUP1',
              p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
              p_per_ei_data        =>  l_per_ei_data
             );
             set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information4,l_rei_rec.rei_information3,l_refresh_flag);
          END IF;
          l_per_ei_data  := null;

      End if;
    End non_pay_duty;
    --
    --
    Procedure lwop_info  is
      l_special_info       ghr_api.special_information_type;
    begin

      If l_person_id is not null then
          l_refresh_flag := l_per_refresh_flag;
          hr_utility.set_location('l_refresh_flag is ' || l_refresh_flag,5);
          IF NVL(l_noa_family_code,'C') = 'CORRECT' THEN
             ghr_history_fetch.fetch_peopleei
             (p_person_id          =>  l_person_id,
              p_information_type   =>  'GHR_US_PER_GROUP1',
              p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
              p_per_ei_data        =>  l_per_ei_data
             );
             set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information4,l_rei_rec.rei_information3,l_refresh_flag);
          END IF;
          l_per_ei_data  := null;

      End if;
    End lwop_info;
    --
    --
    Procedure gov_awards  is
     cursor c_bg1 is
        SELECT  business_group_id
        FROM            per_positions
        WHERE           position_id = p_position_id;
     cursor c_noa_code is
        SELECT 'X'
        FROM ghr_nature_of_actions
        WHERE  nature_of_action_id = p_noa_id
         and code in ('825','840','841','842','843','844','845','846',
                        '847','848','849','878','879' ); -- Bug 3266198 Added 848 and 849 to the NOA codes.
     l_agency_code   ghr_pa_requests.agency_code%type;
     l_bg_id         per_positions.business_group_id%type;

    --
    begin
       --
       -- populate the date award earned field with the effective_date
       --
     IF NVL(l_noa_family_code,'C') <> 'CORRECT' THEN  -- Bug 2836175
       l_refresh_flag   :=  l_per_refresh_flag;
       hr_utility.set_location('eff. date is  '  || fnd_date.date_to_canonical(p_effective_date),1);

       --set_ei(l_org_rec.rei_information9, fnd_date.date_to_canonical(p_effective_date), l_rei_rec.rei_information9, l_refresh_flag);
       --Bug 2833942
       set_ei(l_org_rec.rei_information9, NVL(l_rei_rec.rei_information9,fnd_date.date_to_canonical(p_effective_date)), l_rei_rec.rei_information9, l_refresh_flag);

       hr_utility.set_location('Eff date ' || p_effective_date,1);
       hr_utility.set_location('Info9 for Gov Awards ' || l_org_rec.rei_information9,1);
       -- Start Bug 1379280
       FOR c_noa_code1 in c_noa_code LOOP
       IF p_position_id is NOT NULL then
         FOR c_bg_id     in c_bg1 LOOP
           l_bg_id := c_bg_id.business_group_id;
         END LOOP;
         l_agency_code   := ghr_api.get_position_agency_code_pos
                          (p_position_id          =>      p_position_id
                          ,p_business_group_id    =>      l_bg_id);
         set_ei(l_org_rec.rei_information3, substr(l_agency_code,1,2), l_rei_rec.rei_information3, l_refresh_flag);
       END IF;
       END LOOP;
       IF l_position_id is not null then
         l_refresh_flag := l_pos_refresh_flag;
         ghr_history_fetch.fetch_positionei
         (p_position_id        =>  l_position_id,
         p_information_type   =>  'GHR_US_POS_GRP2',
         p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
         p_pos_ei_data        =>  l_pos_ei_data);
         set_ei(l_org_rec.rei_information10,l_pos_ei_data.poei_information13,l_rei_rec.rei_information10,l_refresh_flag);
       END IF;
     END IF;

       -- End Bug 1379280
       --
    End gov_awards;
    --
    -- Bug#5039072 Added procedure service_obligation.
    Procedure service_obligation IS
        l_serv_oblig_code VARCHAR2(50);
        l_serv_oblig_stdt DATE;
        l_serv_oblig_enddt DATE;
    BEGIN
        --
        hr_utility.set_location('Entering Service Obligation. l_person_id '||l_person_id,0);
        hr_utility.set_location('shadow type code '||l_org_rec.rei_information3,1);
        hr_utility.set_location('shadow start date '||l_org_rec.rei_information5,1);
        hr_utility.set_location('shadow end date '||l_org_rec.rei_information4,1);
        hr_utility.set_location('RPAEIT type code '||l_rei_rec.rei_information3,1);
        hr_utility.set_location('RPAEIT start date '||l_rei_rec.rei_information5,1);
        hr_utility.set_location('RPAEIT end date '||l_rei_rec.rei_information4,1);

        l_serv_oblig_code := NULL;
        l_serv_oblig_stdt := NULL;
        l_serv_oblig_enddt := NULL;

        If p_person_id is not null then
            l_refresh_flag := l_per_refresh_flag;

            IF l_first_noa_code IN ('815','816') THEN
                IF l_la_code1 IN ('V8V') THEN
                    l_serv_oblig_code := 'A4';
                ELSE
                    l_serv_oblig_code := '04';
                END IF;
            ELSE
                IF l_la_code1 IN ('VPR','VPS') AND
                   NVL(l_payment_option,'B') <> 'B' THEN
                    l_serv_oblig_code := 'A1';
                END IF;
            END IF;

        -- Bug#5132121 Service Obligation for Student Loan and MD/DDS
        IF l_first_noa_code IN ('817') THEN
          l_serv_oblig_code := '02';
        END IF;
        IF l_first_noa_code IN ('850') THEN
          l_serv_oblig_code := 'A3';
        END IF;
        IF l_first_noa_code IN ('480') THEN
          l_serv_oblig_code := 'A5';
        END IF;
        -- Bug#5132121 Service Obligation for Student Loan and MD/DDS

            set_ei(l_org_rec.rei_information3,l_serv_oblig_code,l_rei_rec.rei_information3,l_refresh_flag);
            -- Bug#5039072 If the Service Oblig Type is NULL THEN Don't default the Start Date.
            IF  l_serv_oblig_code IS NULL THEN
                set_ei(l_org_rec.rei_information4,l_serv_oblig_stdt,l_rei_rec.rei_information4,l_refresh_flag);
                set_ei(l_org_rec.rei_information5,l_serv_oblig_enddt,l_rei_rec.rei_information5,l_refresh_flag);
            ELSE
                set_ei(l_org_rec.rei_information4,fnd_date.date_to_canonical(p_effective_date),l_rei_rec.rei_information4,l_refresh_flag);
                set_ei(l_org_rec.rei_information5,l_serv_oblig_enddt,l_rei_rec.rei_information5,l_refresh_flag);
            END IF;
            l_per_ei_data  := null;
        End if;
    END service_obligation;
    --
    --
    Procedure  chg_sched_hours is
        -- Bug#2468297
        Cursor c_work_sch is
               select work_schedule
               from ghr_pa_requests
               where pa_request_id = p_pa_request_id;

        l_work_schedule ghr_pa_requests.work_schedule%type;
    Begin
       If l_assignment_id is not null then
          l_refresh_flag := l_asg_refresh_flag;
           ghr_history_fetch.fetch_asgei
           (p_assignment_id      =>  l_assignment_id,
            p_information_type   =>  'GHR_US_ASG_NON_SF52',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_asg_ei_data        =>  l_asg_ei_data
           );
          --Bug#2468297
          FOR work_sch in c_work_sch
          LOOP
             l_work_schedule := work_sch.work_schedule;
          END LOOP;

          If l_work_schedule in ('B','F','G','I','J') then
             l_asg_ei_data.aei_information8:=NULL;
          End If;

            set_ei(l_org_rec.rei_information7,l_asg_ei_data.aei_information8,
                   l_rei_rec.rei_information7,l_refresh_flag);
          l_asg_ei_data  := null;
       End if;
    End chg_sched_hours;
    --
    Procedure chg_in_tenure  is
    --

    begin
       --
          -- Read from history if person id is not null
          IF p_person_id is not null THEN
            l_refresh_flag := l_per_refresh_flag;
            ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  p_person_id,
             p_information_type   =>  'GHR_US_PER_GROUP1',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
            set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
            l_org_rec.rei_information3  :=  l_per_ei_data.pei_information3;
          END IF;
	  l_per_ei_data := NULL;
       --
    End chg_in_tenure;
    -- Bug#2759379 Added procedure chg_in_fegli
    Procedure chg_in_fegli is
    --
    begin
       --
          -- Fetch the element entry value
          IF l_assignment_id is not null THEN
            l_refresh_flag := l_per_refresh_flag;
            ghr_api.retrieve_element_entry_value
              (p_element_name         => 'FEGLI',
               p_input_value_name     => 'Eligibility Expiration',
               p_assignment_id        =>  l_assignment_id,
               p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
               p_value                =>  l_value,
               p_multiple_error_flag  =>  l_multiple_error_flag
              );
                set_ei(l_org_rec.rei_information1,l_value,l_rei_rec.rei_information1,l_refresh_flag);
          END IF;
       --
    End chg_in_fegli;
    --
    Procedure nfc_separation is
    --
    begin
      IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
        set_ei(l_org_rec.rei_information12,'1B',l_rei_rec.rei_information12,l_refresh_flag);
      END IF;
    end nfc_separation;

    -- Bug 4724337 Race or National Origin changes
    procedure ethnic_race_info is
    begin
    	  l_per_ei_data := null;
    	  -- Read from history if person id is not null
          IF l_person_id IS NOT NULL THEN
            l_refresh_flag := l_per_refresh_flag;
            ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  p_person_id,
             p_information_type   =>  'GHR_US_PER_ETHNICITY_RACE',
             p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
             p_per_ei_data        =>  l_per_ei_data
             );
            set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
            set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information4,l_rei_rec.rei_information4,l_refresh_flag);
			set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);
			set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information6,l_rei_rec.rei_information6,l_refresh_flag);
			set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information7,l_rei_rec.rei_information7,l_refresh_flag);
			set_ei(l_org_rec.rei_information8,l_per_ei_data.pei_information8,l_rei_rec.rei_information8,l_refresh_flag);
		  END IF;
    end ethnic_race_info;

    -- End Bug 4724337 Race or National Origin changes


     -- Bug#3385386 Added procedure foreign_transfer_allowance
    Procedure fta is
    --
    begin
        --
        -- Fetch the element entry value
        IF l_assignment_id is not null THEN
            l_refresh_flag := l_per_refresh_flag;
             ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Last Action Code',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information3,  l_value,  l_rei_rec.rei_information3,  l_refresh_flag);
            l_value := NULL;
            ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Number Family Members',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information4,  l_value,  l_rei_rec.rei_information4,  l_refresh_flag);
            l_value := NULL;
            ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Miscellaneous Expense',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information5,  l_value,  l_rei_rec.rei_information5,  l_refresh_flag);
            l_value := NULL;
            ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Wardrobe Expense',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information6,  l_value,  l_rei_rec.rei_information6,  l_refresh_flag);
            l_value := NULL;
            ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Pre Departure Sub Expense',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information7,  l_value,  l_rei_rec.rei_information7,  l_refresh_flag);
            l_value := NULL;
            ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Lease Penalty Expense',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
            set_ei(l_org_rec.rei_information8,  l_value,  l_rei_rec.rei_information8,  l_refresh_flag);
                        l_value := NULL;
             ghr_api.retrieve_element_entry_value
            (p_element_name         => 'Foreign Transfer Allowance',
            p_input_value_name     => 'Amount',
            p_assignment_id        =>  l_assignment_id,
            p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
              );
             -- Bug#3754136 Added the format mask to the field l_value.
	     set_ei(l_org_rec.rei_information9, to_char(to_number(l_value),'FM999990.90'),
	                      l_rei_rec.rei_information9,  l_refresh_flag);
                        l_value := NULL;
        END IF;
       --
    End fta;
    --

    -- Bug 4280026
    Procedure key_emergency_essntl
    is
    Begin
       If l_noa_family_code = 'APP' then
          set_ei(l_org_rec.rei_information3,nvl(l_rei_rec.rei_information3,'0'),
                                     l_rei_rec.rei_information3,'Y');
       Else
          For get_pos in c_position
          Loop
             If nvl(get_pos.from_position_id,0) = nvl(get_pos.to_position_id,0) then
                If l_assignment_id is not null then
                   -- Get ASG_NON_SF52 data
                   l_refresh_flag := l_asg_refresh_flag;
                   ghr_history_fetch.fetch_asgei
                   (p_assignment_id          =>  l_assignment_id,
                    p_information_type       =>  'GHR_US_ASG_NON_SF52',
                    p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
                    p_asg_ei_data            =>  l_asg_ei_data
                   );
                   set_ei(l_org_rec.rei_information3,l_asg_ei_data.aei_information5,
                                     l_rei_rec.rei_information3,l_refresh_flag);
                   l_asg_ei_data :=  null;
                End If;
             Else
                set_ei(l_org_rec.rei_information3,nvl(l_rei_rec.rei_information3,'0'),
                                     l_rei_rec.rei_information3,'Y');
             End If;
          End Loop;
       End if;
    End key_emergency_essntl;


    -- Bug 5482191
    Procedure ghr_conv_dates is
   /* --Begin Bug# 4588575
    l_tenure       ghr_pa_requests.tenure%type;
    l_pos_occpied  ghr_pa_requests.position_occupied%type;
    l_pos_intel_pos VARCHAR(30);
    CURSOR c_pa_req_details is
    SELECT tenure,position_occupied
    FROM ghr_pa_requests
    WHERE  pa_request_id = p_pa_request_id;
   */ --Backout the changes done for Bug# 4588575

    Begin
       /* l_per_ei_data := null;
        If l_position_id is not null then
            ghr_history_fetch.fetch_positionei
                (p_position_id           =>  l_position_id,
                p_information_type       =>  'GHR_US_POS_GRP2',
                p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
                p_pos_ei_data            =>  l_pos_ei_data
                );
            l_pos_intel_pos := l_pos_ei_data.poei_information15;
            l_pos_ei_data := null;
        end if;
        FOR pa_rec in c_pa_req_details LOOP
            l_tenure        := pa_rec.tenure;
            l_pos_occpied   := pa_rec.position_occupied;
        END LOOP;
        --end Bug# 4588575
        */ --Backout the changes done for Bug# 4588575
        If l_person_id is not null then
            ghr_history_fetch.fetch_peopleei
                (p_person_id          =>  l_person_id,
                p_information_type   =>  'GHR_US_PER_CONVERSIONS',
                p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
                p_per_ei_data        =>  l_per_ei_data
                );
            l_refresh_flag := l_per_refresh_flag;
           /* --Begin Bug# 4588575
            IF  nvl(l_tenure,hr_api.g_varchar2) = '2' and
                nvl(l_pos_occpied,hr_api.g_varchar2) = '1' and
                nvl(l_pos_intel_pos,hr_api.g_varchar2) <> '2' THEN
                set_ei(l_org_rec.rei_information3,fnd_date.date_to_canonical(p_effective_date),
                l_rei_rec.rei_information3,l_refresh_flag);
            ELSE
                --end Bug# 4588575
                */ --Backout the changes done for Bug# 4588575
                set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,
                         l_rei_rec.rei_information3,l_refresh_flag);
           /* END IF;
            --Begin Bug# 4588575
            IF  nvl(l_tenure,hr_api.g_varchar2) = '2' and
                nvl(l_pos_occpied,hr_api.g_varchar2) = '1' and
                l_rei_rec.rei_information3 IS NOT NULL THEN
                set_ei(l_org_rec.rei_information4,
                fnd_date.date_to_canonical(add_months(p_effective_date,36)),
                l_rei_rec.rei_information4,l_refresh_flag);
            ELSE
                --End Bug# 4588575
                */ --Backout the changes done for Bug# 4588575
                set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information4,
                         l_rei_rec.rei_information4,l_refresh_flag);
           -- END IF;

            set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,
                     l_rei_rec.rei_information5,l_refresh_flag);
            /*--Begin Bug# 4588575
            IF  nvl(l_la_code1,hr_api.g_varchar2) = 'J8M'  THEN
                set_ei( l_org_rec.rei_information6,
                fnd_date.date_to_canonical(add_months(p_effective_date,24)),
                l_rei_rec.rei_information6,l_refresh_flag);
            ELSE
                --End Bug# 4588575
                */ --Backout the changes done for Bug# 4588575
                set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information6,
                         l_rei_rec.rei_information6,l_refresh_flag);
            --END IF;
            set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information7,
                     l_rei_rec.rei_information7,l_refresh_flag);

            hr_utility.set_location('rei_ei_data:'||l_rei_rec.rei_information7,0);
            l_per_ei_data :=  null;
        End If;
    End ghr_conv_dates;

   /* --Begin Bug# 4588575
    Procedure ghr_prob_info  is
        l_pos_occpied  ghr_pa_requests.position_occupied%type;
        CURSOR c_pa_req_details is
        SELECT position_occupied
        FROM ghr_pa_requests
        WHERE  pa_request_id = p_pa_request_id;
    Begin
        l_per_ei_data := null;
        If l_person_id is not null then
            ghr_history_fetch.fetch_peopleei
            (p_person_id          =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_PROBATIONS',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
            );
            l_refresh_flag := l_per_refresh_flag;
            IF l_first_noa_code not in('130','132','145','147') THEN
                set_ei(l_org_rec.rei_information10,fnd_date.date_to_canonical(p_effective_date),
                    l_rei_rec.rei_information10,l_refresh_flag);
            ELSE
                set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information3,
                    l_rei_rec.rei_information10,l_refresh_flag);
            END IF;
            FOR pa_rec in c_pa_req_details LOOP
                l_pos_occpied   := pa_rec.position_occupied;
            END LOOP;
            IF l_first_noa_code not in('130','132','145','147') and l_pos_occpied = '1' THEN
                set_ei(l_org_rec.rei_information11,
                    fnd_date.date_to_canonical(add_months(p_effective_date,12)),
                    l_rei_rec.rei_information11,l_refresh_flag);
            ELSIF l_first_noa_code not in('130','132','145','147') and l_pos_occpied = '2' THEN
                set_ei(l_org_rec.rei_information11,
                    fnd_date.date_to_canonical(add_months(p_effective_date,24)),
                    l_rei_rec.rei_information11,l_refresh_flag);
            ELSE
                set_ei(l_org_rec.rei_information11,
                    l_per_ei_data.pei_information4,
                    l_rei_rec.rei_information11,l_refresh_flag);
            END IF;
            l_pos_ei_data :=  null;
        end if;
    End ghr_prob_info;

    Procedure ghr_scd_info  is
        l_retirement_plan   ghr_pa_requests.retirement_plan%type;
        l_service_comp_date ghr_pa_requests.service_comp_date%type;
        CURSOR c_pa_req_details is
        SELECT retirement_plan,service_comp_date
        FROM ghr_pa_requests
        WHERE  pa_request_id = p_pa_request_id;
    Begin
        l_per_ei_data := null;
        If l_person_id is not null then
            ghr_history_fetch.fetch_peopleei
            (p_person_id         =>  l_person_id,
            p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_data
            );
            l_refresh_flag := l_per_refresh_flag;
             FOR pa_rec in c_pa_req_details LOOP
                l_retirement_plan       := pa_rec.retirement_plan;
                l_service_comp_date     := pa_rec.service_comp_date;
            END LOOP;
            IF l_first_noa_code not in('130','132','145','147') THEN
                set_ei(l_org_rec.rei_information10,fnd_date.date_to_canonical(l_service_comp_date),
                    l_rei_rec.rei_information10,l_refresh_flag);
                set_ei(l_org_rec.rei_information11,fnd_date.date_to_canonical(l_service_comp_date),
                    l_rei_rec.rei_information11,l_refresh_flag);
            ELSE
                set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information4,
                    l_rei_rec.rei_information10,l_refresh_flag);
                set_ei(l_org_rec.rei_information11,l_per_ei_data.pei_information5,
                    l_rei_rec.rei_information11,l_refresh_flag);
            END IF;
            IF l_retirement_plan in('2','4','5') AND l_first_noa_code not in('130','132','145','147') THEN
                set_ei(l_org_rec.rei_information12,fnd_date.date_to_canonical(l_service_comp_date),
                    l_rei_rec.rei_information12,l_refresh_flag);
            ELSE
                set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information7,
                    l_rei_rec.rei_information12,l_refresh_flag);
            END IF;
            l_pos_ei_data :=  null;
        end if;
    End ghr_scd_info;

    --end Bug# 4588575
*/ --Backout the changes done for Bug# 4588575
    Procedure set_refresh_flags is
    Begin

      If p_person_id is not null then
        if (p_person_id =  nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) and
           (l_rei_rec_exists = 'N' or
            trunc(nvl(p_effective_date,sysdate)) <> trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))) or
	  --Bug # 9006561 Added this condition to consider if the cancellation of one action and
	  -- correction of another action of the same effective date has been processed consecutively
	     (p_person_id   = nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) and
	      p_pa_request_id <> nvl(ghr_par_shd.g_old_rec.pa_request_id ,hr_api.g_number) and
 	      trunc(nvl(p_effective_date,sysdate)) = trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))
           then
           hr_utility.set_location('change in eff. date only',2);
           l_person_id := p_person_id;
           l_per_refresh_flag := 'Y';
        Elsif p_person_id     <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) then
           hr_utility.set_location('person id has changed',3);
           l_person_id        := p_person_id;
           l_per_refresh_flag := 'N';
        Else
            l_person_id := null;
        End if;
        hr_utility.set_location('person id in  the condition - refresh flag N ' || to_char(l_person_id),1);
      End if;
      If p_assignment_id is not null then
        if (p_assignment_id    = nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number)  and
           (l_rei_rec_exists = 'N' or
            trunc(nvl(p_effective_date,sysdate)) <> trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))) or
	   --Bug # 9006561 Added this condition to consider if the cancellation of one action and
	  -- correction of another action of the same effective date has been processed consecutively
	     (p_assignment_id   = nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number) and
	      p_pa_request_id <> nvl(ghr_par_shd.g_old_rec.pa_request_id ,hr_api.g_number) and
 	      trunc(nvl(p_effective_date,sysdate)) = trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))
           then
           l_assignment_id := p_assignment_id;
           l_asg_refresh_flag := 'Y';
        Elsif p_assignment_id <> nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number) then
           l_assignment_id    := p_assignment_id;
           l_asg_refresh_flag := 'N';
        Else
           l_assignment_id := null;
        End if;
      End if;
      If p_position_id is not null then
        if (p_position_id      =  nvl(ghr_par_shd.g_old_rec.to_position_id,hr_api.g_number) and
           (l_rei_rec_exists = 'N' or
            trunc(nvl(p_effective_date,sysdate)) <> trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))) or
	  --Bug # 9006561 Added this condition to consider if the cancellation of one action and
	  -- correction of another action of the same effective date has been processed consecutively
	     (p_position_id   = nvl(ghr_par_shd.g_old_rec.to_position_id,hr_api.g_number) and
	      p_pa_request_id <> nvl(ghr_par_shd.g_old_rec.pa_request_id ,hr_api.g_number) and
 	      trunc(nvl(p_effective_date,sysdate)) = trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate)))
           then
           l_position_id      := p_position_id;
           l_pos_refresh_flag := 'Y';
        Elsif p_position_id   <> nvl(ghr_par_shd.g_old_rec.to_position_id,hr_api.g_number) then
           l_position_id      := p_position_id;
           l_pos_refresh_flag := 'Y';
        Else
           l_position_id := null;
        End if;
      End if;
    End set_refresh_flags;
    --
    --
 --Start of Bug# 6312144
    procedure ipa_benefits_cont is
    begin
    	  l_per_ei_data := null;
    	  -- Read from history if person id is not null
          IF l_person_id IS NOT NULL THEN
             l_refresh_flag := l_per_refresh_flag;
             ghr_history_fetch.fetch_peopleei
                (p_person_id          =>  p_person_id,
                 p_information_type   =>  'GHR_US_PER_BENEFITS_CONT',
                 p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
                 p_per_ei_data        =>  l_per_ei_data
                 );
                  set_ei(l_org_rec.rei_information1,l_per_ei_data.pei_information1,l_rei_rec.rei_information1,l_refresh_flag);
                  set_ei(l_org_rec.rei_information2,l_per_ei_data.pei_information2,l_rei_rec.rei_information2,l_refresh_flag);
	   	  set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
		  set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information4,l_rei_rec.rei_information4,l_refresh_flag);
		  set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);
		  set_ei(l_org_rec.rei_information6,l_per_ei_data.pei_information6,l_rei_rec.rei_information6,l_refresh_flag);
		  set_ei(l_org_rec.rei_information7,l_per_ei_data.pei_information7,l_rei_rec.rei_information7,l_refresh_flag);
  		  set_ei(l_org_rec.rei_information12,l_per_ei_data.pei_information12,l_rei_rec.rei_information12,l_refresh_flag);
		  set_ei(l_org_rec.rei_information8,l_per_ei_data.pei_information8,l_rei_rec.rei_information8,l_refresh_flag);
		  set_ei(l_org_rec.rei_information9,l_per_ei_data.pei_information9,l_rei_rec.rei_information9,l_refresh_flag);
		  set_ei(l_org_rec.rei_information10,l_per_ei_data.pei_information10,l_rei_rec.rei_information10,l_refresh_flag);
		  set_ei(l_org_rec.rei_information11,l_per_ei_data.pei_information11,l_rei_rec.rei_information11,l_refresh_flag);
	    END IF;
    end ipa_benefits_cont;

    procedure retirement_system_info is
    begin
    	  l_per_ei_data := null;
    	  -- Read from history if person id is not null
          IF l_person_id IS NOT NULL THEN
            l_refresh_flag := l_per_refresh_flag;
            ghr_history_fetch.fetch_peopleei
                (p_person_id          =>  p_person_id,
                 p_information_type   =>  'GHR_US_PER_RETIRMENT_SYS_INFO',
                 p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
                 p_per_ei_data        =>  l_per_ei_data
                 );
                  set_ei(l_org_rec.rei_information1,l_per_ei_data.pei_information1,l_rei_rec.rei_information1,l_refresh_flag);
                  set_ei(l_org_rec.rei_information2,l_per_ei_data.pei_information2,l_rei_rec.rei_information2,l_refresh_flag);
	   	  set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information3,l_rei_rec.rei_information3,l_refresh_flag);
		  set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information4,l_rei_rec.rei_information4,l_refresh_flag);
		  set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information5,l_rei_rec.rei_information5,l_refresh_flag);
	  END IF;
    end retirement_system_info;

    procedure par_benefits is
    begin
    -- Read from history if person id is not null
          IF l_person_id IS NOT NULL THEN
            l_refresh_flag := l_per_refresh_flag;
            ghr_history_fetch.fetch_peopleei
                (p_person_id          =>  p_person_id,
                 p_information_type   =>  'GHR_US_PER_BENEFIT_INFO',
                 p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
                 p_per_ei_data        =>  l_per_ei_data
                 );
                  set_ei(l_org_rec.rei_information1,l_per_ei_data.pei_information16,l_rei_rec.rei_information1,l_refresh_flag);
                  set_ei(l_org_rec.rei_information2,l_per_ei_data.pei_information17,l_rei_rec.rei_information2,l_refresh_flag);
	   	  set_ei(l_org_rec.rei_information3,l_per_ei_data.pei_information18,l_rei_rec.rei_information3,l_refresh_flag);
		  set_ei(l_org_rec.rei_information4,l_per_ei_data.pei_information19,l_rei_rec.rei_information4,l_refresh_flag);
		  set_ei(l_org_rec.rei_information5,l_per_ei_data.pei_information20,l_rei_rec.rei_information5,l_refresh_flag);
	  END IF;
    end par_benefits;
   --End of Bug# 6312144

Begin

     -- Bug#4089400 Getting the Family code to restrict DLEI calculation for Correction Actions.
     FOR c_noa_fam_code_rec IN c_noa_fam_code
     LOOP
        l_noa_family_code := c_noa_fam_code_rec.noa_family_code;
        -- Bug#5039072 RRR Changes.
        l_first_noa_code  := c_noa_fam_code_rec.first_noa_code;
        l_la_code1        := c_noa_fam_code_rec.la_code1;
        l_payment_option  := c_noa_fam_code_rec.payment_option;
     END LOOP;
     hr_utility.set_location('l_noa_family_code '|| l_noa_family_code,10);
   l_resp_id := fnd_profile.value('RESP_ID');
   l_application_id := fnd_profile.value('RESP_APPL_ID');
     hr_utility.set_location('Resp id '|| l_resp_id,10);
     hr_utility.set_location('appl id '|| l_application_id,10);
   for c_info_type_rec in c_info_types(l_application_id,l_resp_id) loop
      l_information_type :=  c_info_type_rec.information_type;
      l_rei_rec := NULL;
	  l_org_rec := NULL; -- Bug 4691293
      l_rei_rec_exists   := 'N';

      -- first populate l_rei_rec with existing values on pa_request_extra_info, if any

      for rei_rec in c_rei_rec loop
        l_rei_rec.pa_request_extra_info_id := rei_rec.pa_request_extra_info_id;
        l_rei_rec.rei_information1  := rei_rec.rei_information1;
        l_rei_rec.rei_information2  := rei_rec.rei_information2;
        l_rei_rec.rei_information3  := rei_rec.rei_information3;
        l_rei_rec.rei_information4  := rei_rec.rei_information4;
        l_rei_rec.rei_information5  := rei_rec.rei_information5;
        l_rei_rec.rei_information6  := rei_rec.rei_information6;
        l_rei_rec.rei_information7  := rei_rec.rei_information7;
        l_rei_rec.rei_information8  := rei_rec.rei_information8;
        l_rei_rec.rei_information9  := rei_rec.rei_information9;
        l_rei_rec.rei_information10 := rei_rec.rei_information10;
        l_rei_rec.rei_information11 := rei_rec.rei_information11;
        l_rei_rec.rei_information12 := rei_rec.rei_information12;
        l_rei_rec.rei_information13 := rei_rec.rei_information13;
        l_rei_rec.rei_information14 := rei_rec.rei_information14;
        l_rei_rec.rei_information15 := rei_rec.rei_information15;
        l_rei_rec.rei_information16 := rei_rec.rei_information16;
        l_rei_rec.rei_information17 := rei_rec.rei_information17;
        l_rei_rec.rei_information18 := rei_rec.rei_information18;
        l_rei_rec.rei_information19 := rei_rec.rei_information19;
        l_rei_rec.rei_information20 := rei_rec.rei_information20;
        l_rei_rec.rei_information21 := rei_rec.rei_information21;
        l_rei_rec.rei_information22 := rei_rec.rei_information22;
        l_rei_rec.rei_information23 := rei_rec.rei_information23;
        l_rei_rec.rei_information24 := rei_rec.rei_information24;
        l_rei_rec.rei_information25 := rei_rec.rei_information25;
        l_rei_rec.rei_information26 := rei_rec.rei_information26;
        l_rei_rec.rei_information27 := rei_rec.rei_information27;
        l_rei_rec.rei_information28 := rei_rec.rei_information28;
        l_rei_rec.rei_information29 := rei_rec.rei_information29;
        l_rei_rec.rei_information30 := rei_rec.rei_information30;
        l_rei_rec_exists := 'Y';  -- will be used in set_refresh_flags
      End loop;

      for rei_rec in c_org_rei_rec loop
        l_org_rec.rei_information1  := rei_rec.rei_information1;
        l_org_rec.rei_information2  := rei_rec.rei_information2;
        l_org_rec.rei_information3  := rei_rec.rei_information3;
        l_org_rec.rei_information4  := rei_rec.rei_information4;
        l_org_rec.rei_information5  := rei_rec.rei_information5;
        l_org_rec.rei_information6  := rei_rec.rei_information6;
        l_org_rec.rei_information7  := rei_rec.rei_information7;
        l_org_rec.rei_information8  := rei_rec.rei_information8;
        l_org_rec.rei_information9  := rei_rec.rei_information9;
        l_org_rec.rei_information10 := rei_rec.rei_information10;
        l_org_rec.rei_information11 := rei_rec.rei_information11;
        l_org_rec.rei_information12 := rei_rec.rei_information12;
        l_org_rec.rei_information13 := rei_rec.rei_information13;
        l_org_rec.rei_information14 := rei_rec.rei_information14;
        l_org_rec.rei_information15 := rei_rec.rei_information15;
        l_org_rec.rei_information16 := rei_rec.rei_information16;
        l_org_rec.rei_information17 := rei_rec.rei_information17;
        l_org_rec.rei_information18 := rei_rec.rei_information18;
        l_org_rec.rei_information19 := rei_rec.rei_information19;
        l_org_rec.rei_information20 := rei_rec.rei_information20;
        l_org_rec.rei_information21 := rei_rec.rei_information21;
        l_org_rec.rei_information22 := rei_rec.rei_information22;
        l_org_rec.rei_information23 := rei_rec.rei_information23;
        l_org_rec.rei_information24 := rei_rec.rei_information24;
        l_org_rec.rei_information25 := rei_rec.rei_information25;
        l_org_rec.rei_information26 := rei_rec.rei_information26;
        l_org_rec.rei_information27 := rei_rec.rei_information27;
        l_org_rec.rei_information28 := rei_rec.rei_information28;
        l_org_rec.rei_information29 := rei_rec.rei_information29;
        l_org_rec.rei_information30 := rei_rec.rei_information30;
      End loop;


      -- call the procedure to set the refresh flags
      If p_refresh_flag = 'N' then
          set_refresh_flags;
      Else
        hr_utility.set_location('p_refresh_flag is Y',3);
        l_per_refresh_flag := 'Y';
        l_asg_refresh_flag := 'Y';
        l_pos_refresh_flag := 'Y';
      End if;
      --
      hr_utility.set_location('INFO_TYPE_IS'|| l_information_type,0);
      hr_utility.set_location('PER ID is'|| l_person_id,0);
      if l_information_type = 'GHR_US_PAR_APPT_INFO' then
        hr_utility.set_location(l_proc,5);
        hr_utility.set_location('info type ' || l_information_type,1);
        appt_info;
      elsif l_information_type =  'GHR_US_PAR_MD_DDS_PAY' then
        hr_utility.set_location(l_proc,15);
        hr_utility.set_location('info type ' || l_information_type,3);
        mddds_pay;
      elsif l_information_type =  'GHR_US_PAR_PREMIUM_PAY_IND' then
        hr_utility.set_location(l_proc,15);
        hr_utility.set_location('info type ' || l_information_type,3);
        premium_pay_ind;

      elsif l_information_type =  'GHR_US_PAR_APPT_TRANSFER' then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_location('info type ' || l_information_type,2);
        for c_req_num_rec in c_req_num loop
	--Bug 3128526. Added 'NVL' to handle NULL values
          if nvl(c_req_num_rec.request_number,hr_api.g_number) <> 'MTI'||to_char(p_pa_request_id) then
            appt_transfer;
          end if;
        end loop;
      elsif l_information_type =  'GHR_US_PAR_CONV_APP' then
        hr_utility.set_location(l_proc,15);
        hr_utility.set_location('info type ' || l_information_type,3);
        conv_appt;
      elsif l_information_type = 'GHR_US_PAR_RETURN_TO_DUTY' then
        hr_utility.set_location(l_proc,20);
        hr_utility.set_location('info type ' || l_information_type,4);
        return_to_duty;
	elsif l_information_type = 'GHR_US_PAR_REASSIGNMENT' then
        hr_utility.set_location(l_proc,25);
        hr_utility.set_location('info type ' || l_information_type,4);
        reassignment;
      elsif l_information_type = 'GHR_US_PAR_REALIGNMENT' then
        hr_utility.set_location(l_proc,30);
        hr_utility.set_location('info type ' || l_information_type,4);
        realign;
      elsif l_information_type =  'GHR_US_PAR_CHG_DATA_ELEMENT' then
        hr_utility.set_location(l_proc,45);
        hr_utility.set_location('info type ' || l_information_type,4);
        chg_data_element;
      elsif  l_information_type =  'GHR_US_PAR_CHG_RETIRE_PLAN' then
        hr_utility.set_location(l_proc,50);
        hr_utility.set_location('info type ' || l_information_type,4);
        chg_retire_plan;
      elsif  l_information_type =  'GHR_US_PAR_CHG_SCD' then
        hr_utility.set_location(l_proc,55);
        hr_utility.set_location('info type ' || l_information_type,4);
        chg_scd;
      --Bug#2146912  Added condition for GHR_US_PAR_TSP
      elsif  l_information_type =  'GHR_US_PAR_TSP' then
        hr_utility.set_location(l_proc,60);
        hr_utility.set_location('info type ' || l_information_type,4);
        scd_tsp;
      elsif  l_information_type =  'GHR_US_PAR_NON_PAY_DUTY_STATUS' then
        hr_utility.set_location(l_proc,80);
        hr_utility.set_location('info type ' || l_information_type,4);
        non_pay_duty;
      elsif  l_information_type = 'GHR_US_PAR_LWOP_INFO' then
        hr_utility.set_location(l_proc,90);
        lwop_info;
      elsif  l_information_type = 'GHR_US_PAR_AWARDS_BONUS' then
        hr_utility.set_location(l_proc,95);
        gov_awards;
      elsif  l_information_type = 'GHR_US_PAR_CHG_HOURS' then
        hr_utility.set_location(l_proc,100);
        chg_sched_hours;
      elsif  l_information_type = 'GHR_US_PAR_CHG_TEN' then
        hr_utility.set_location(l_proc,110);
        chg_in_tenure;
      --  Bug#2759379 Added condition for GHR_US_PAR_FEGLI
      elsif  l_information_type = 'GHR_US_PAR_FEGLI'   then
        hr_utility.set_location(l_proc,120);
        chg_in_fegli;
      -- Bug#3385386 Added the following if condition.
      elsif  l_information_type = 'GHR_US_PAR_FOR_TRANSER_ALLOW'   then
        hr_utility.set_location(l_proc,125);
        fta;
      elsif  l_information_type = 'GHR_US_PAR_NFC_SEPARATION_INFO'   then
        hr_utility.set_location(l_proc,130);
        nfc_separation;
      elsif l_information_type = 'GHR_US_PAR_ETHNICITY_RACE'   then
      	hr_utility.set_location(l_proc,120);
		hr_utility.set_location('info type ' || l_information_type,1);
        ethnic_race_info;
	  elsif  l_information_type = 'GHR_US_PAR_BENEFITS'   then
        hr_utility.set_location(l_proc,125);
		hr_utility.set_location('info type ' || l_information_type,1);
        appt_benefits;
      --Bug# 5039072 Added procedure service_obligation.
      elsif  l_information_type = 'GHR_US_PAR_SERVICE_OBLIGATION'   then
        hr_utility.set_location(l_proc,130);
		hr_utility.set_location('info type ' || l_information_type,1);
        service_obligation;
      -- Bug 4280026
      elsif  l_information_type = 'GHR_US_PAR_EMERG_ESSNTL_ASG'   then
        hr_utility.set_location(l_proc,135);
        hr_utility.set_location('info type ' || l_information_type,1);
        key_emergency_essntl;
      -- Bug 5482191
      elsif  l_information_type = 'GHR_US_PAR_CONVERSION_DATES'   then
        hr_utility.set_location(l_proc,140);
        hr_utility.set_location('info type ' || l_information_type,1);
        ghr_conv_dates;
      /*      --Begin Bug# 4588575
      elsif l_information_type = 'GHR_US_PAR_PROBATION_INFO' then
            hr_utility.set_location(l_proc,270);
            hr_utility.set_location('info type ' || l_information_type,270);
            ghr_prob_info;
      elsif l_information_type = 'GHR_US_PAR_SCD_INFO' then
            hr_utility.set_location(l_proc,280);
            hr_utility.set_location('info type ' || l_information_type,280);
            ghr_scd_info;
            --end Bug# 4588575
            */ --Backout the changes done for Bug# 4588575
-- Modifications related to Bug#6312144 -- New RPA EIT Benefits
      elsif l_information_type = 'GHR_US_PAR_BENEFITS_CONT' then
       hr_utility.set_location(l_proc,5);
       hr_utility.set_location('info type ' || l_information_type,1);
       ipa_benefits_cont;
      elsif l_information_type = 'GHR_US_PAR_RETIRMENT_SYS_INFO' then
       hr_utility.set_location(l_proc,5);
       hr_utility.set_location('info type ' || l_information_type,1);
       retirement_system_info;
      elsif l_information_type = 'GHR_US_PAR_BENEFIT_INFO' then
       hr_utility.set_location(l_proc,5);
       hr_utility.set_location('info type ' || l_information_type,1);
       par_benefits;
-- Modifications related to Bug#6312144 -- New RPA EIT Benefits
      end if;

      --  No defaulting reqd. for the families (Recruitment Bonus, Relocation Bonus,
      --  Gov. Awards,salary_chg, denial_wgi,realignment,chg_hours,posn_chg
      --  because for these it makes no sense to default existing details
      --  as the user will have to enter only the current data and
      --  would not want to see the existing data.
      -- Bug#4089400 Added condition to skip the DLEI Processing for Correction Actions.
      IF l_information_type = 'GHR_US_PAR_SALARY_CHG' THEN
        IF NVL(l_noa_family_code,'C') <> 'CORRECT' THEN
            l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator
                     (p_position_id,
                      p_effective_date);

            IF l_psi <> '00' THEN
                OPEN c_afhr_noac_sal_chg;
                FETCH c_afhr_noac_sal_chg INTO l_dlei_date;
                IF l_dlei_date is not null THEN
                    set_ei(l_org_rec.rei_information5,
                      fnd_date.date_to_canonical(l_dlei_date),
                        l_rei_rec.rei_information5,'Y');
                ELSE
                    -- Bug 3263140
                    --Setting the value to NULL only if the original value is NULL
                    IF l_org_rec.rei_information5 IS NULL THEN
                         set_ei(l_org_rec.rei_information5,
                           null,l_rei_rec.rei_information5,'Y');
                    END IF;
                END IF;
                CLOSE c_afhr_noac_sal_chg;

            ELSE

                OPEN c_noac_sal_chg;
                FETCH c_noac_sal_chg INTO l_dlei_date;
                IF l_dlei_date is not null THEN
                    set_ei(l_org_rec.rei_information5,
                      fnd_date.date_to_canonical(l_dlei_date),
                        l_rei_rec.rei_information5,'Y');
                ELSE
                    -- Bug 3263140
                    --Setting the value to NULL only if the original value is NULL
                    IF l_org_rec.rei_information5 IS NULL THEN
                         set_ei(l_org_rec.rei_information5,
                           null,l_rei_rec.rei_information5,'Y');
                    END IF;
                END IF;
                CLOSE c_noac_sal_chg;
            END IF;
        END IF;
		-- Bug#4126188 Populating Date Arrived Personnel office
		FOR c_posn_to_frm IN c_position LOOP
			l_from_position_id :=c_posn_to_frm.from_position_id;
			l_to_position_id := c_posn_to_frm.to_position_id;
		END LOOP;
		FOR pa_rec in c_pa_req_2noa_dtls LOOP
			l_second_noa_code := pa_rec.second_noa_code;
		END LOOP;
        IF l_first_noa_code IN ('702','703','713') OR
           (l_noa_family_code = 'CORRECT' AND l_second_noa_code IN ('702','703','713')) OR
           ---Bug# 8263918
	    (l_first_noa_code is not null and l_second_noa_code is not null and l_second_noa_code in ('702','703','713')) THEN
        ---Bug# 8263918
			ghr_history_fetch.fetch_positionei
				(p_position_id            =>  l_from_position_id,
				p_information_type       =>  'GHR_US_POS_GRP1',
				p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
				p_pos_ei_data            =>  l_pos_ei_data
				);
			l_from_poid := l_pos_ei_data.poei_information3;
			l_pos_ei_data := NULL;
			ghr_history_fetch.fetch_positionei
				(p_position_id            =>  l_to_position_id,
				p_information_type       =>  'GHR_US_POS_GRP1',
				p_date_effective         =>  trunc(nvl(p_effective_date,sysdate)),
				p_pos_ei_data            =>  l_pos_ei_data
				);
			l_to_poid := l_pos_ei_data.poei_information3;
/*Start - Bug 6129752*/
    			IF p_assignment_id IS NULL THEN
			   FOR C_GET_ASSIGNMENNT_ID IN GET_ASSIGNEMNT_ID LOOP
	   			l_assignment_id := C_GET_ASSIGNMENNT_ID.assignment_id;
				IF ( hr_utility.debug_enabled()) THEN
			  	  hr_utility.set_location(' P_Assignment id is null and l_assignment is'||l_assignment_id,1733);
				END IF;
			   END LOOP;
			END IF;
/*End - Bug 6129752*/
			IF l_from_poid = l_to_poid THEN
				IF l_noa_family_code = 'CORRECT' THEN
	              ghr_history_api.get_g_session_var(l_session);
				  l_session1 := l_session;
                  l_session.noa_id_correct := NULL;
				  ghr_history_api.reinit_g_session_var;
				  ghr_history_api.set_g_session_var(l_session);
					ghr_history_fetch.fetch_asgei
						(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
						p_information_type       =>  'GHR_US_ASG_NON_SF52',
						p_date_effective         =>  p_effective_date-1,
						p_asg_ei_data            =>  l_asg_ei_data
						);
						ghr_history_api.reinit_g_session_var;
						ghr_history_api.set_g_session_var(l_session1);
				ELSE
					ghr_history_fetch.fetch_asgei
						(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
						p_information_type       =>  'GHR_US_ASG_NON_SF52',
						p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
						p_asg_ei_data            =>  l_asg_ei_data
						);
				END IF;
			set_ei(l_org_rec.rei_information6,l_asg_ei_data.aei_information3,l_rei_rec.rei_information6,'Y');
		/*Start - Bug 6129752*/
			ELSIF l_to_poid IS NULL AND l_noa_family_code = 'CORRECT'  THEN
			  ghr_history_fetch.fetch_asgei
				(p_assignment_id          =>  NVL(l_assignment_id,p_assignment_id),
				p_information_type       =>  'GHR_US_ASG_NON_SF52',
				p_date_effective         =>  nvl(p_effective_date,trunc(sysdate)),
				p_asg_ei_data            =>  l_asg_ei_data
				);
			 set_ei(l_org_rec.rei_information6,l_asg_ei_data.aei_information3,l_rei_rec.rei_information6,'Y');
		/*End - Bug 6129752*/
			ELSE
				FOR c_get_eff_rec in c_get_effective_date
				  LOOP
					 set_ei(l_org_rec.rei_information6,fnd_date.date_to_canonical(c_get_eff_rec.effective_date), l_rei_rec.rei_information6,'Y');
					  exit;
				  END LOOP;
			END IF;
        END IF;
        --Bug#4126188 End
      END IF;

      l_rei_rec.information_type  :=   l_information_type;
      l_rei_rec.pa_request_id     :=   p_pa_request_id;

        hr_utility.set_location('Test Null EI',110);
      If l_rei_rec.rei_information1  is not null or  l_rei_rec.rei_information2   is not null or
         l_rei_rec.rei_information3  is not null or  l_rei_rec.rei_information4   is not null or
         l_rei_rec.rei_information5  is not null or  l_rei_rec.rei_information6   is not null or
         l_rei_rec.rei_information7  is not null or  l_rei_rec.rei_information8   is not null or
         l_rei_rec.rei_information9  is not null or  l_rei_rec.rei_information10  is not null or
         l_rei_rec.rei_information11 is not null or  l_rei_rec.rei_information12  is not null or
         l_rei_rec.rei_information13 is not null or  l_rei_rec.rei_information14  is not null or
         l_rei_rec.rei_information15 is not null or  l_rei_rec.rei_information16  is not null or
         l_rei_rec.rei_information17 is not null or  l_rei_rec.rei_information18  is not null or
         l_rei_rec.rei_information19 is not null or  l_rei_rec.rei_information20  is not null or
         l_rei_rec.rei_information21 is not null or  l_rei_rec.rei_information22  is not null or
         l_rei_rec.rei_information23 is not null or  l_rei_rec.rei_information24  is not null or
         l_rei_rec.rei_information25 is not null or  l_rei_rec.rei_information26  is not null or
         l_rei_rec.rei_information27 is not null or  l_rei_rec.rei_information28  is not null or
         l_rei_rec.rei_information29 is not null or  l_rei_rec.rei_information30  is not null  then
         hr_utility.set_location('l_update_rei is Y ',1);
        l_update_rei := 'Y';
      Else
        l_update_rei     := 'N';
        hr_utility.set_location('l_update_rei is N ',1);
      End if;

        hr_utility.set_location('Test Null EI',110);
      determine_operation
      (p_pa_request_id            =>  p_pa_request_id,
       p_information_type         =>  l_information_type,
       p_update_rei               =>  l_update_rei,
       p_rei_rec                  =>  l_rei_rec,
       p_operation_flag           =>  l_flag,
       p_pa_request_extra_info_id =>  l_rei_rec.pa_request_extra_info_id,
       p_object_version_number    =>  l_rei_rec.object_version_number
      );

      hr_utility.set_location('PAR ' || to_char(l_rei_rec.pa_request_id),1);
      hr_utility.set_location('Info type ' || l_rei_rec.information_type,2);
      hr_utility.set_location('Flag ' || l_flag ,3);

      generic_populate_extra_info
      (p_rei_rec    =>  l_rei_rec,
       p_org_rec    =>  l_org_rec,
       p_flag       =>  l_flag
      );
  --
  end loop;
  --
end fetch_noa_spec_extra_info;
--
--
--
    Procedure fetch_generic_extra_info
    (p_pa_request_id        in  number,
     p_person_id            in  number,
     p_assignment_id        in  number,
     p_effective_date       in  date  ,
     p_refresh_flag         in  varchar2 default 'Y'
    )
     is
     l_perf_appraisal          ghr_api.special_information_type;
     l_update_rei              varchar2(1) := 'N';
     l_exists                  boolean  := FALSE;
     l_flag                    varchar2(1) := null;
     l_rei_rec                 ghr_pa_request_extra_info%rowtype;
     l_org_rec                 ghr_pa_request_ei_shadow%rowtype;
     l_person_id               per_people_f.person_id%type;
     l_assignment_id           per_assignments_f.assignment_id%type;
     l_per_refresh_flag        varchar2(1);
     l_asg_refresh_flag        varchar2(1);
     l_business_group_id       per_assignments_f.business_group_id%type;
     l_noa_family_code         ghr_noa_families.noa_family_code%type;

     l_proc                    varchar2(72) := g_package || 'fetch_gneric_extra_info';
     l_information_type        ghr_pa_request_extra_info.information_type%type;
     l_person_type             per_person_types.system_person_type%type := hr_api.g_varchar2;

     cursor  c_bus_gp is
       select business_group_id
       from   per_people_f
       where  person_id = p_person_id
       and    nvl(p_effective_date,sysdate) between
             effective_start_date and effective_end_date;

      cursor c_rei_rec is
      select pa_request_extra_info_id,
             rei_information1,
             rei_information2,
             rei_information3,
             rei_information4,
             rei_information5,
             rei_information6,
             rei_information7,
             rei_information8,
             rei_information9,
             rei_information10,
             rei_information11,
             rei_information12,
		 rei_information13,
             rei_information14,
             rei_information15,
             rei_information16,
             rei_information17,
             rei_information18,
             rei_information19,
             rei_information20,
             rei_information21,
             rei_information22,
		 rei_information23,
             rei_information24,
             rei_information25,
             rei_information26,
             rei_information27,
             rei_information28,
             rei_information29,
             rei_information30,
             object_version_number
      from   ghr_pa_request_extra_info
      where  pa_request_id    = p_pa_request_id
      and    information_type = l_information_type;

   cursor c_org_rei_rec is
      select pa_request_extra_info_id,
             rei_information1,
             rei_information2,
             rei_information3,
             rei_information4,
             rei_information5,
             rei_information6,
             rei_information7,
             rei_information8,
             rei_information9,
             rei_information10,
             rei_information11,
             rei_information12,
		 rei_information13,
             rei_information14,
             rei_information15,
             rei_information16,
             rei_information17,
             rei_information18,
             rei_information19,
             rei_information20,
             rei_information21,
             rei_information22,
		 rei_information23,
             rei_information24,
             rei_information25,
             rei_information26,
             rei_information27,
             rei_information28,
             rei_information29,
             rei_information30
      from   ghr_pa_request_ei_shadow
      where  pa_request_extra_info_id = l_rei_rec.pa_request_extra_info_id;

     cursor c_payroll is
       select   payroll_id
       from     per_assignments_f asg
       where    asg.assignment_id = l_assignment_id
       and      trunc(nvl(p_effective_date,sysdate))
       between  asg.effective_start_date
       and      asg.effective_end_date;

    cursor c_noa_fam  is
     select par.noa_family_code
     from   ghr_pa_requests par
     where  pa_request_id = p_pa_request_id;

    Cursor c_def_payroll is
     select  pay.payroll_id
     from    pay_payrolls_f pay
     where   payroll_name  = 'Biweekly'
     and     nvl(p_effective_date,sysdate) between
             pay.effective_start_date and pay.effective_end_date
     and     business_group_id   =  l_business_group_id;

-- Added by Venkat -- Bug # 1236354
 cursor   c_person_type is
   select  ppt.system_person_type
   from    per_person_types  ppt,
           per_people_f      ppf
   where   ppf.person_id       =  p_person_id
   and     ppt.person_type_id  =  ppf.person_type_id
   and     p_effective_date
   between ppf.effective_start_date
   and     ppf.effective_end_date;



     begin
       hr_utility.set_location('Entering fetch generic ',1);
       hr_utility.set_location('Entering  ' || l_proc,5);
       l_update_rei       := 'N';
       l_flag             := null;
       l_person_id        := p_person_id;
       l_assignment_id    := p_assignment_id;
       l_per_refresh_flag := p_refresh_flag;
       l_asg_refresh_flag := p_refresh_flag;

       l_flag :=  p_refresh_flag;

       for fam_code in c_noa_fam loop
         l_noa_family_code := fam_code.noa_family_code;
       end loop;

       If l_noa_family_code =  'APP' then
          l_flag             := 'Y';
          l_asg_refresh_flag := 'Y';
       End if;

       If p_refresh_flag = 'N' then
         l_person_id := p_person_id;
         If p_person_id is null  then
            If l_flag = 'N' then
            -- check if earlier had information and delete it
             l_information_type :=  'GHR_US_PAR_PAYROLL_TYPE' ;
             l_rei_rec          :=  Null;
             l_org_rec          :=  Null;
             for  rei_rec in c_rei_rec loop
               l_rei_rec.pa_request_extra_info_id  :=  rei_rec.pa_request_extra_info_id;
               l_rei_rec.object_version_number     :=  rei_rec.object_version_number;
             end loop;
             If l_rei_rec.pa_request_extra_info_id is not null then
               generic_populate_extra_info
               (p_rei_rec      => l_rei_rec,
 	          p_org_rec      => l_org_rec,
                p_flag         => 'D'
                );
              End if;
            End if;


           l_information_type :=  'GHR_US_PAR_PERF_APPRAISAL' ;
           l_rei_rec          :=  Null;
           l_org_rec          :=  Null;

           for  rei_rec in c_rei_rec loop
             l_rei_rec.pa_request_extra_info_id  :=  rei_rec.pa_request_extra_info_id;
             l_rei_rec.object_version_number     :=  rei_rec.object_version_number;
           end loop;
           If l_rei_rec.pa_request_extra_info_id is not null then
             generic_populate_extra_info
             (p_rei_rec      => l_rei_rec,
 	        p_org_rec      => l_org_rec,
              p_flag         => 'D'
             );
           End if;

           l_information_type  :=  Null;
           l_rei_rec           := Null;
           l_org_rec           := Null;
         End if;

         If p_person_id is not null then
            if  p_person_id      =  nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) and
                trunc(nvl(p_effective_date,sysdate)) <> trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate))
                then
              l_person_id    := p_person_id;
              l_per_refresh_flag := 'Y';
            Elsif p_person_id  <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number) then
              l_person_id      := p_person_id;
              l_per_refresh_flag   := 'N';
            Else
              l_person_id := null;
            End if;
         End if;


        If p_assignment_id is not null and l_flag = 'N' then
          if  p_assignment_id      =  nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number)    and
                 trunc(nvl(p_effective_date,sysdate)) <> trunc(nvl(ghr_par_shd.g_old_rec.effective_date,sysdate))
                then
              l_assignment_id    := p_assignment_id;
              l_asg_refresh_flag := 'Y';
            Elsif p_assignment_id  <> nvl(ghr_par_shd.g_old_rec.employee_assignment_id,hr_api.g_number) then
              --and  l_noa_family_code <> 'APP'
              l_assignment_id      := p_assignment_id;
              l_asg_refresh_flag   := 'N';
            Else
              l_assignment_id := null;
            End if;
     End if;

    End if;

     -- 1. For 'GHR_US_PAR_PAYROLL_TYPE'

       if l_assignment_id is not null
           or l_noa_family_code = 'APP' then
         l_information_type := 'GHR_US_PAR_PAYROLL_TYPE';
         for rei_rec in c_rei_rec loop
           l_rei_rec.pa_request_extra_info_id := rei_rec.pa_request_extra_info_id;
           l_rei_rec.rei_information1  := rei_rec.rei_information1;
           l_rei_rec.rei_information2  := rei_rec.rei_information2;
           l_rei_rec.rei_information3  := rei_rec.rei_information3;
           l_rei_rec.rei_information4  := rei_rec.rei_information4;
           l_rei_rec.rei_information5  := rei_rec.rei_information5;
           l_rei_rec.rei_information6  := rei_rec.rei_information6;
           l_rei_rec.rei_information7  := rei_rec.rei_information7;
           l_rei_rec.rei_information8  := rei_rec.rei_information8;
           l_rei_rec.rei_information9  := rei_rec.rei_information9;
           l_rei_rec.rei_information10 := rei_rec.rei_information10;
           l_rei_rec.rei_information11 := rei_rec.rei_information11;
           l_rei_rec.rei_information12 := rei_rec.rei_information12;
           l_rei_rec.rei_information13 := rei_rec.rei_information13;
           l_rei_rec.rei_information14 := rei_rec.rei_information14;
           l_rei_rec.rei_information15 := rei_rec.rei_information15;
           l_rei_rec.rei_information16 := rei_rec.rei_information16;
           l_rei_rec.rei_information17 := rei_rec.rei_information17;
           l_rei_rec.rei_information18 := rei_rec.rei_information18;
           l_rei_rec.rei_information19 := rei_rec.rei_information19;
           l_rei_rec.rei_information20 := rei_rec.rei_information20;
           l_rei_rec.rei_information21 := rei_rec.rei_information21;
           l_rei_rec.rei_information22 := rei_rec.rei_information22;
           l_rei_rec.rei_information23 := rei_rec.rei_information23;
           l_rei_rec.rei_information24 := rei_rec.rei_information24;
           l_rei_rec.rei_information25 := rei_rec.rei_information25;
           l_rei_rec.rei_information26 := rei_rec.rei_information26;
           l_rei_rec.rei_information27 := rei_rec.rei_information27;
           l_rei_rec.rei_information28 := rei_rec.rei_information28;
           l_rei_rec.rei_information29 := rei_rec.rei_information29;
           l_rei_rec.rei_information30 := rei_rec.rei_information30;
         End loop;


         for rei_rec in c_org_rei_rec loop
           l_org_rec.rei_information1  := rei_rec.rei_information1;
           l_org_rec.rei_information2  := rei_rec.rei_information2;
           l_org_rec.rei_information3  := rei_rec.rei_information3;
           l_org_rec.rei_information4  := rei_rec.rei_information4;
           l_org_rec.rei_information5  := rei_rec.rei_information5;
           l_org_rec.rei_information6  := rei_rec.rei_information6;
           l_org_rec.rei_information7  := rei_rec.rei_information7;
           l_org_rec.rei_information8  := rei_rec.rei_information8;
           l_org_rec.rei_information9  := rei_rec.rei_information9;
           l_org_rec.rei_information10 := rei_rec.rei_information10;
           l_org_rec.rei_information11 := rei_rec.rei_information11;
           l_org_rec.rei_information12 := rei_rec.rei_information12;
           l_org_rec.rei_information13 := rei_rec.rei_information13;
           l_org_rec.rei_information14 := rei_rec.rei_information14;
           l_org_rec.rei_information15 := rei_rec.rei_information15;
           l_org_rec.rei_information16 := rei_rec.rei_information16;
           l_org_rec.rei_information17 := rei_rec.rei_information17;
           l_org_rec.rei_information18 := rei_rec.rei_information18;
           l_org_rec.rei_information19 := rei_rec.rei_information19;
           l_org_rec.rei_information20 := rei_rec.rei_information20;
           l_org_rec.rei_information21 := rei_rec.rei_information21;
           l_org_rec.rei_information22 := rei_rec.rei_information22;
           l_org_rec.rei_information23 := rei_rec.rei_information23;
           l_org_rec.rei_information24 := rei_rec.rei_information24;
           l_org_rec.rei_information25 := rei_rec.rei_information25;
           l_org_rec.rei_information26 := rei_rec.rei_information26;
           l_org_rec.rei_information27 := rei_rec.rei_information27;
           l_org_rec.rei_information28 := rei_rec.rei_information28;
           l_org_rec.rei_information29 := rei_rec.rei_information29;
           l_org_rec.rei_information30 := rei_rec.rei_information30;
         end loop;


         hr_utility.set_location(l_proc,10);
         l_exists := FALSE;

         If nvl(l_noa_family_code,hr_api.g_varchar2) = 'APP'  then
           hr_utility.set_location(l_proc,11);
           l_asg_refresh_flag :=  'Y';
           If p_person_id is not null then
             for bus_gp in c_bus_gp loop
                hr_utility.set_location('bus gp is  ' || bus_gp.business_group_id,12);
                l_business_group_id  := bus_gp.business_group_id;
             end loop;
           Else
             fnd_profile.get('PER_BUSINESS_GROUP_ID',l_business_group_id);
             hr_utility.set_location('bus gp is  ' || l_business_group_id,13);
           End if;
           for def_payroll in c_def_payroll loop
              hr_utility.set_location(l_proc,14);
              l_exists := TRUE;
              set_ei(l_org_rec.rei_information3,to_char(def_payroll.payroll_id),l_rei_rec.rei_information3,l_asg_refresh_flag);
              l_rei_rec.information_type := 'GHR_US_PAR_PAYROLL_TYPE';
              exit;
           end  loop;
         ELSE  -- For conversion of exemployee defaults to 'Biweekly' -- Bug # 1236354
            hr_utility.set_location(l_proc,15);
            FOR person_type_rec in c_person_type LOOP
              l_person_type :=   person_type_rec.system_person_type;
              hr_utility.set_location(' Person Type is ' || l_person_type,16);
              EXIT;
            END LOOP;
            IF l_noa_family_code = 'CONV_APP' and  l_person_type = 'EX_EMP' THEN
              l_asg_refresh_flag :=  'Y';
              IF p_person_id is not null THEN
                FOR bus_gp in c_bus_gp LOOP
                  hr_utility.set_location('bus gp is  ' || bus_gp.business_group_id,17);
                  l_business_group_id  := bus_gp.business_group_id;
                END LOOP;
              END IF;
              FOR def_payroll in c_def_payroll LOOP
                hr_utility.set_location(l_proc,18);
                l_exists := TRUE;
                set_ei(l_org_rec.rei_information3,to_char(def_payroll.payroll_id),l_rei_rec.rei_information3,l_asg_refresh_flag);
                l_rei_rec.information_type := 'GHR_US_PAR_PAYROLL_TYPE';
                exit;
              END LOOP;
            ELSE -- fetch payroll from employee's assignment record
              FOR payroll in C_payroll LOOP
                hr_utility.set_location(l_proc,19);
                l_exists := TRUE;
                set_ei(l_org_rec.rei_information3,to_char(payroll.payroll_id),l_rei_rec.rei_information3,l_asg_refresh_flag);
                l_rei_rec.information_type := 'GHR_US_PAR_PAYROLL_TYPE';
              END LOOP;
            END IF;
          END IF;

          If l_rei_rec.rei_information3 is not null then
            hr_utility.set_location(l_proc,20);
            l_update_rei           := 'Y';
          End if;

          l_rei_rec.pa_request_id      :=  p_pa_request_id;
           hr_utility.set_location(l_proc,25);
           determine_operation
	     (p_pa_request_id            =>  p_pa_request_id,
            p_information_type         =>  'GHR_US_PAR_PAYROLL_TYPE',
            p_update_rei               =>  l_update_rei,
            p_rei_rec                  =>  l_rei_rec,
            p_operation_flag           =>  l_flag,
	      p_pa_request_extra_info_id => l_rei_rec.pa_request_extra_info_id,
            p_object_version_number    => l_rei_rec.object_version_number
            );

           hr_utility.set_location(l_proc,30);
           generic_populate_extra_info
           (p_rei_rec            =>  l_rei_rec,
            p_org_rec            =>  l_org_rec,
            p_flag               =>  l_flag
            );
       End if;

       l_rei_rec := null;
       l_org_rec := null;

      --2. p_information_type = 'GHR_US_PAR_PERF_APPRAISAL' then

       l_update_rei := 'N';
       l_flag       := null;
       l_exists     := FALSE;


       If l_person_id is not null then
          l_information_type := 'GHR_US_PAR_PERF_APPRAISAL' ;
        for rei_rec in c_rei_rec loop
        l_exists := TRUE;
        l_rei_rec.pa_request_extra_info_id := rei_rec.pa_request_extra_info_id;
        l_rei_rec.rei_information1  := rei_rec.rei_information1;
        l_rei_rec.rei_information2  := rei_rec.rei_information2;
        l_rei_rec.rei_information3  := rei_rec.rei_information3;
        l_rei_rec.rei_information4  := rei_rec.rei_information4;
        l_rei_rec.rei_information5  := rei_rec.rei_information5;
        l_rei_rec.rei_information6  := rei_rec.rei_information6;
        l_rei_rec.rei_information7  := rei_rec.rei_information7;
        l_rei_rec.rei_information8  := rei_rec.rei_information8;
        l_rei_rec.rei_information9  := rei_rec.rei_information9;
        l_rei_rec.rei_information10 := rei_rec.rei_information10;
        l_rei_rec.rei_information11 := rei_rec.rei_information11;
        l_rei_rec.rei_information12 := rei_rec.rei_information12;
        l_rei_rec.rei_information13 := rei_rec.rei_information13;
        l_rei_rec.rei_information14 := rei_rec.rei_information14;
        l_rei_rec.rei_information15 := rei_rec.rei_information15;
        l_rei_rec.rei_information16 := rei_rec.rei_information16;
        l_rei_rec.rei_information17 := rei_rec.rei_information17;
        l_rei_rec.rei_information18 := rei_rec.rei_information18;
        l_rei_rec.rei_information19 := rei_rec.rei_information19;
        l_rei_rec.rei_information20 := rei_rec.rei_information20;
        l_rei_rec.rei_information21 := rei_rec.rei_information21;
        l_rei_rec.rei_information22 := rei_rec.rei_information22;
        l_rei_rec.rei_information23 := rei_rec.rei_information23;
        l_rei_rec.rei_information24 := rei_rec.rei_information24;
        l_rei_rec.rei_information25 := rei_rec.rei_information25;
        l_rei_rec.rei_information26 := rei_rec.rei_information26;
        l_rei_rec.rei_information27 := rei_rec.rei_information27;
        l_rei_rec.rei_information28 := rei_rec.rei_information28;
        l_rei_rec.rei_information29 := rei_rec.rei_information29;
        l_rei_rec.rei_information30 := rei_rec.rei_information30;
      End loop;

      for rei_rec in c_org_rei_rec loop
        l_org_rec.rei_information1  := rei_rec.rei_information1;
        l_org_rec.rei_information2  := rei_rec.rei_information2;
        l_org_rec.rei_information3  := rei_rec.rei_information3;
        l_org_rec.rei_information4  := rei_rec.rei_information4;
        l_org_rec.rei_information5  := rei_rec.rei_information5;
        l_org_rec.rei_information6  := rei_rec.rei_information6;
        l_org_rec.rei_information7  := rei_rec.rei_information7;
        l_org_rec.rei_information8  := rei_rec.rei_information8;
        l_org_rec.rei_information9  := rei_rec.rei_information9;
        l_org_rec.rei_information10 := rei_rec.rei_information10;
        l_org_rec.rei_information11 := rei_rec.rei_information11;
        l_org_rec.rei_information12 := rei_rec.rei_information12;
        l_org_rec.rei_information13 := rei_rec.rei_information13;
        l_org_rec.rei_information14 := rei_rec.rei_information14;
        l_org_rec.rei_information15 := rei_rec.rei_information15;
        l_org_rec.rei_information16 := rei_rec.rei_information16;
        l_org_rec.rei_information17 := rei_rec.rei_information17;
        l_org_rec.rei_information18 := rei_rec.rei_information18;
        l_org_rec.rei_information19 := rei_rec.rei_information19;
        l_org_rec.rei_information20 := rei_rec.rei_information20;
        l_org_rec.rei_information21 := rei_rec.rei_information21;
        l_org_rec.rei_information22 := rei_rec.rei_information22;
        l_org_rec.rei_information23 := rei_rec.rei_information23;
        l_org_rec.rei_information24 := rei_rec.rei_information24;
        l_org_rec.rei_information25 := rei_rec.rei_information25;
        l_org_rec.rei_information26 := rei_rec.rei_information26;
        l_org_rec.rei_information27 := rei_rec.rei_information27;
        l_org_rec.rei_information28 := rei_rec.rei_information28;
        l_org_rec.rei_information29 := rei_rec.rei_information29;
        l_org_rec.rei_information30 := rei_rec.rei_information30;
       end loop;


         hr_utility.set_location(l_proc,40);
         ghr_api.return_special_information
         (p_person_id            => l_person_id,
          p_structure_name       => 'US Fed Perf Appraisal',
          p_effective_date       =>  nvl(p_effective_date,trunc(sysdate)),
          p_special_info         =>  l_perf_appraisal
         );
           hr_utility.set_location(l_proc,45);
        -- use set_ei
           set_ei(l_org_rec.rei_information3,l_perf_appraisal.segment2,l_rei_rec.rei_information3,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information4,l_perf_appraisal.segment4,l_rei_rec.rei_information4,l_per_refresh_flag);

--Bug 3209817
--For autopopulating 'Rating of Record Level' field
      IF ( l_noa_family_code IN ('APP','APPT_TRANS') )  THEN
           set_ei(l_org_rec.rei_information5,nvl(l_perf_appraisal.segment5,'X'),l_rei_rec.rei_information5,l_per_refresh_flag);
      ELSE
	   set_ei(l_org_rec.rei_information5,l_perf_appraisal.segment5,l_rei_rec.rei_information5,l_per_refresh_flag);
       END IF;
	   set_ei(l_org_rec.rei_information6,l_perf_appraisal.segment6,l_rei_rec.rei_information6,l_per_refresh_flag);
           -- added by skutteti on 6/10/98
           set_ei(l_org_rec.rei_information7,l_perf_appraisal.segment1,l_rei_rec.rei_information7,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information8,l_perf_appraisal.segment14,l_rei_rec.rei_information8,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information9,l_perf_appraisal.segment3,l_rei_rec.rei_information9,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information10,l_perf_appraisal.segment7,l_rei_rec.rei_information10,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information11,l_perf_appraisal.segment8,l_rei_rec.rei_information11,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information12,l_perf_appraisal.segment9,l_rei_rec.rei_information12,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information13,l_perf_appraisal.segment10,l_rei_rec.rei_information13,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information14,l_perf_appraisal.segment11,l_rei_rec.rei_information14,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information15,l_perf_appraisal.segment12,l_rei_rec.rei_information15,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information16,l_perf_appraisal.segment13,l_rei_rec.rei_information16,l_per_refresh_flag);
           set_ei(l_org_rec.rei_information17,l_perf_appraisal.segment15,l_rei_rec.rei_information17,l_per_refresh_flag);
	   set_ei(l_org_rec.rei_information18,l_perf_appraisal.segment16,l_rei_rec.rei_information18,l_per_refresh_flag);
	  -- added by vmididho (4753117) on 05/mar/2007
           set_ei(l_org_rec.rei_information19,l_perf_appraisal.segment17,l_rei_rec.rei_information19,l_per_refresh_flag);



          -- l_rei_rec.rei_information3  :=   l_perf_appraisal.segment2;
          -- l_rei_rec.rei_information4  :=   l_perf_appraisal.segment4;
          -- l_rei_rec.rei_information5  :=   l_perf_appraisal.segment5;
          -- l_rei_rec.rei_information6  :=   l_perf_appraisal.segment6;
          -- l_rei_rec.information_type  :=   'GHR_US_PAR_PERF_APPRAISAL' ;

    /* If
            l_rei_rec.rei_information3  is not null or  l_rei_rec.rei_information4   is not null or
            l_rei_rec.rei_information5  is not null or  l_rei_rec.rei_information6   is not null or
            l_rei_rec.rei_information7  is not null or  l_rei_rec.rei_information8   is not null or
            l_rei_rec.rei_information9  is not null or  l_rei_rec.rei_information10  is not null or
            l_rei_rec.rei_information11 is not null or  l_rei_rec.rei_information12  is not null or
            l_rei_rec.rei_information13 is not null or  l_rei_rec.rei_information14  is not null or
            l_rei_rec.rei_information15 is not null or  l_rei_rec.rei_information16  is not null or
            l_rei_rec.rei_information17 is not null or  l_rei_rec.rei_information18  is not null then

            hr_utility.set_location(l_proc,50);
            l_update_rei    := 'Y';
         Else
           hr_utility.set_location(l_proc,55);
           l_update_rei     := 'N';
         End if;*/
	 --Commented the above IF condition since 'US Fed Perf Appraisal' is a mandatory SIT
	 -- and we will never have to delete this record from the Extra info table.!!
         ---Added for bug 3187894
         l_update_rei    := 'Y';
	 ---
         l_rei_rec.pa_request_id    :=  p_pa_request_id;
         l_rei_rec.information_type :=  'GHR_US_PAR_PERF_APPRAISAL';

          hr_utility.set_location(l_proc,60);

         determine_operation
	   (p_pa_request_id      	 =>  p_pa_request_id,
          p_information_type   	 =>  'GHR_US_PAR_PERF_APPRAISAL',
          p_update_rei               =>  l_update_rei,
          p_rei_rec                  =>  l_rei_rec,
          p_operation_flag           =>  l_flag,
	    p_pa_request_extra_info_id =>  l_rei_rec.pa_request_extra_info_id,
          p_object_version_number    =>  l_rei_rec.object_version_number
          );

         hr_utility.set_location(l_proc,65);
         generic_populate_extra_info
         (p_rei_rec            =>  l_rei_rec,
          p_org_rec            =>  l_org_rec,
          p_flag               =>  l_flag
         );
         End if;
       hr_utility.set_location('Leaving ' || l_proc,70);
    End fetch_generic_extra_info;


-- Get Information Type
   Procedure get_information_type
   (p_noa_id            in   ghr_nature_of_actions.nature_of_action_id%type,
    p_information_type  out NOCOPY ghr_pa_request_info_types.information_type%type
   )
   is

   l_proc    varchar2(72) := g_package  || 'get_information_type';

   Cursor c_info_type is
     Select  pit.information_type
     from    ghr_pa_request_info_types  pit,
             ghr_noa_families           nfa,
             ghr_families               fam
     where   nfa.nature_of_action_id  = p_noa_id
     and     nfa.noa_family_code      = fam.noa_family_code
     and     fam.pa_info_type_flag    = 'Y'
     and     pit.noa_family_code      = fam.noa_family_code
     and     pit.information_type    like 'GHR_US%';


   Begin
     If p_noa_id is not null then
       for info_type in  c_info_type loop
         p_information_type :=  info_type.information_type;
       end loop;
     Else
       p_information_type := null;
     End if;

 End get_information_type;

 Procedure determine_operation
 (p_pa_request_id        in    ghr_pa_requests.pa_request_id%type,
  p_information_type     in    ghr_pa_request_info_types.information_type%type,
  p_update_rei           in    varchar2,
  p_rei_rec              in    ghr_pa_request_extra_info%rowtype,
  p_operation_flag       out NOCOPY  varchar2,
  p_pa_request_extra_info_id out NOCOPY  ghr_pa_request_extra_info.pa_request_extra_info_id%type,
  p_object_version_number    out NOCOPY ghr_pa_requests.object_version_number%type
  ) is

   l_proc                      varchar2(72) :=  'determine_operation';
   l_object_version_number     ghr_pa_requests.object_version_number%type;
   l_pa_request_extra_info_id  ghr_pa_request_extra_info.pa_request_extra_info_id%type;
   l_exists                    boolean := FALSE;
   l_dummy                     ghr_pa_request_extra_info%rowtype;
   l_rei_rec                   ghr_pa_request_extra_info%rowtype;
   cursor c_rei_rec is
      select rei.pa_request_extra_info_id,
             rei.object_version_number,
             rei.rei_information1,
             rei.rei_information2,
             rei.rei_information3,
             rei.rei_information4,
             rei.rei_information5,
             rei.rei_information6,
             rei.rei_information7,
             rei.rei_information8,
             rei.rei_information9,
             rei.rei_information10,
             rei.rei_information11,
             rei.rei_information12,
             rei.rei_information13,
             rei.rei_information14,
             rei.rei_information15,
             rei.rei_information16,
             rei.rei_information17,
             rei.rei_information18,
             rei.rei_information19,
             rei.rei_information20,
             rei.rei_information21,
             rei.rei_information22,
             rei.rei_information23,
             rei.rei_information24,
             rei.rei_information25,
             rei.rei_information26,
             rei.rei_information27,
             rei.rei_information28,
             rei.rei_information29,
             rei.rei_information30
      from   ghr_pa_request_extra_info rei
      where  rei.pa_request_id    = p_pa_request_id
      and    rei.information_type = p_information_type;

   Begin
     hr_utility.set_location('Entering '|| l_proc,10);
     l_rei_rec      :=   p_rei_rec;

     for  rei_rec in c_rei_rec loop
       p_object_version_number     := rei_rec.object_version_number;
       p_pa_request_extra_info_id  := rei_rec.pa_request_extra_info_id;
--       l_dummy.rei_information1    := rei_rec.rei_information1;
--       l_dummy.rei_information2    := rei_rec.rei_information2;
       l_dummy.rei_information3    := rei_rec.rei_information3;
       l_dummy.rei_information4    := rei_rec.rei_information4;
       l_dummy.rei_information5    := rei_rec.rei_information5;
       l_dummy.rei_information6    := rei_rec.rei_information6;
       l_dummy.rei_information7    := rei_rec.rei_information7;
       l_dummy.rei_information8    := rei_rec.rei_information8;
       l_dummy.rei_information9    := rei_rec.rei_information9;
       l_dummy.rei_information10   := rei_rec.rei_information10;
       l_dummy.rei_information11    := rei_rec.rei_information11;
       l_dummy.rei_information12    := rei_rec.rei_information12;
       l_dummy.rei_information13    := rei_rec.rei_information13;
       l_dummy.rei_information14    := rei_rec.rei_information14;
       l_dummy.rei_information15    := rei_rec.rei_information15;
       l_dummy.rei_information16    := rei_rec.rei_information16;
       l_dummy.rei_information17    := rei_rec.rei_information17;
       l_dummy.rei_information18    := rei_rec.rei_information18;
       l_dummy.rei_information19    := rei_rec.rei_information19;
       l_dummy.rei_information20   := rei_rec.rei_information20;
       l_dummy.rei_information21    := rei_rec.rei_information21;
       l_dummy.rei_information22    := rei_rec.rei_information22;
       l_dummy.rei_information23    := rei_rec.rei_information23;
       l_dummy.rei_information24    := rei_rec.rei_information24;
       l_dummy.rei_information25    := rei_rec.rei_information25;
       l_dummy.rei_information26    := rei_rec.rei_information26;
       l_dummy.rei_information27    := rei_rec.rei_information27;
       l_dummy.rei_information28    := rei_rec.rei_information28;
       l_dummy.rei_information29    := rei_rec.rei_information29;
       l_dummy.rei_information30    := rei_rec.rei_information30;
       hr_utility.set_location(l_proc,20);
       l_exists := true;
     end loop;

  -- If non-sf52 data already exists, then as a result of the new changes, there might be need to update/ delete it.
  --    If there are changes, then update else do nothing.
  --    If the update_flag (update_rei) is 'N' , then delete the existing data.
  -- Else if non-sf52 does not exists, then if update_rei = 'Y', then Create. else do nothing.


     If l_exists then
       hr_utility.set_location(' rei exists ',1);
       If p_update_rei = 'Y' then
         hr_utility.set_location(' Update ',1);
         If nvl(l_dummy.rei_information3,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information3,hr_api.g_varchar2)   or
			nvl(l_dummy.rei_information4,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information4,hr_api.g_varchar2)   or
			nvl(l_dummy.rei_information5,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information5,hr_api.g_varchar2)   or
				nvl(l_dummy.rei_information6,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information6,hr_api.g_varchar2)   or
			  nvl(l_dummy.rei_information7,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information7,hr_api.g_varchar2)   or
				nvl(l_dummy.rei_information8,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information8,hr_api.g_varchar2)   or
			nvl(l_dummy.rei_information9,hr_api.g_varchar2)  <> nvl(l_rei_rec.rei_information9,hr_api.g_varchar2)   or
				nvl(l_dummy.rei_information10,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information10,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information11,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information11,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information12,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information12,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information13,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information13,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information14,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information14,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information15,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information15,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information16,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information16,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information17,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information17,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information18,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information18,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information19,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information19,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information20,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information20,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information21,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information21,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information22,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information22,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information23,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information23,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information24,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information24,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information25,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information25,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information26,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information26,hr_api.g_varchar2)  or
			  nvl(l_dummy.rei_information27,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information27,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information28,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information28,hr_api.g_varchar2)  or
			nvl(l_dummy.rei_information29,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information29,hr_api.g_varchar2)  or
				nvl(l_dummy.rei_information30,hr_api.g_varchar2) <> nvl(l_rei_rec.rei_information30,hr_api.g_varchar2) then
           hr_utility.set_location('operation is Update',1);
           p_operation_flag   := 'U';
           hr_utility.set_location(l_proc,25);
         End if;
       Else
         hr_utility.set_location(' Delete ',1);
          hr_utility.set_location(l_proc,30);
         p_operation_flag   := 'D';
       End if;
     Else
       If p_update_rei = 'Y' then
         hr_utility.set_location(l_proc,35);
         hr_utility.set_location(' Create ',1);
         p_operation_flag  := 'C';
       Else
         hr_utility.set_location(' Null ',1);
          hr_utility.set_location(l_proc,40);
         p_operation_flag  := null;
       End if;
     End if;
    End determine_operation;

Procedure generic_populate_extra_info
(p_rei_rec           in      ghr_pa_request_extra_info%rowtype,
 p_org_rec           in      ghr_pa_request_ei_shadow%rowtype,
 p_flag              in       varchar2
)
is

  l_flag      varchar2(1) := p_flag;
  l_rei_rec   ghr_pa_request_extra_info%rowtype := p_rei_rec;
  l_org_rec   ghr_pa_request_ei_shadow%rowtype;
  l_proc      varchar2(72) := 'generic_populate_extra_info';

Begin
hr_utility.set_location('Entering ' || l_proc,10);
hr_utility.set_location('Flag  := ' || l_flag,1);

-- l_flag :
-- C    - Create
-- U    - Update
-- D    - Delete
-- Null - do nothing

If l_flag is not null then
   hr_utility.set_location(l_proc,15);

   If l_flag = 'C' then
      hr_utility.set_location(l_proc,20);
      ghr_par_extra_info_api.create_pa_request_extra_info
     (p_pa_request_id             =>  l_rei_rec.pa_request_id,
      p_information_type          =>  l_rei_rec.information_type,  -- to be replaced by the info_type returned by the get_infor._type
      p_rei_information_category  =>  l_rei_rec.information_type,
      p_rei_information1          =>  l_rei_rec.rei_information1,
      p_rei_information2          =>  l_rei_rec.rei_information2,
      p_rei_information3          =>  l_rei_rec.rei_information3,
      p_rei_information4          =>  l_rei_rec.rei_information4,
      p_rei_information5          =>  l_rei_rec.rei_information5,
      p_rei_information6          =>  l_rei_rec.rei_information6,
      p_rei_information7          =>  l_rei_rec.rei_information7,
      p_rei_information8          =>  l_rei_rec.rei_information8,
      p_rei_information9          =>  l_rei_rec.rei_information9,
      p_rei_information10         =>  l_rei_rec.rei_information10,
      p_rei_information11         =>  l_rei_rec.rei_information11,
      p_rei_information12         =>  l_rei_rec.rei_information12,
      p_rei_information13         =>  l_rei_rec.rei_information13,
      p_rei_information14         =>  l_rei_rec.rei_information14,
      p_rei_information15         =>  l_rei_rec.rei_information15,
      p_rei_information16         =>  l_rei_rec.rei_information16,
      p_rei_information17         =>  l_rei_rec.rei_information17,
      p_rei_information18         =>  l_rei_rec.rei_information18,
      p_rei_information19         =>  l_rei_rec.rei_information19,
      p_rei_information20         =>  l_rei_rec.rei_information20,
      p_rei_information21         =>  l_rei_rec.rei_information21,
      p_rei_information22         =>  l_rei_rec.rei_information22,
      p_rei_information23         =>  l_rei_rec.rei_information23,
      p_rei_information24         =>  l_rei_rec.rei_information24,
      p_rei_information25         =>  l_rei_rec.rei_information25,
      p_rei_information26         =>  l_rei_rec.rei_information26,
      p_rei_information27         =>  l_rei_rec.rei_information27,
      p_rei_information28         =>  l_rei_rec.rei_information28,
      p_rei_information29         =>  l_rei_rec.rei_information29,
      p_rei_information30         =>  l_rei_rec.rei_information30,
      P_PA_REQUEST_EXTRA_INFO_ID  =>  l_rei_rec.pa_request_extra_info_id,
      P_OBJECT_VERSION_NUMBER     =>  l_rei_rec.object_version_number
      );

      insert into ghr_pa_request_ei_shadow
      (
      pa_request_extra_info_id ,
      pa_request_id  ,
      information_type,
      rei_information1 ,
      rei_information2 ,
      rei_information3 ,
      rei_information4 ,
      rei_information5 ,
      rei_information6 ,
      rei_information7 ,
      rei_information8 ,
      rei_information9 ,
      rei_information10 ,
      rei_information11 ,
      rei_information12 ,
      rei_information13 ,
      rei_information14 ,
      rei_information15 ,
      rei_information16 ,
      rei_information17 ,
      rei_information18 ,
      rei_information19 ,
      rei_information20 ,
      rei_information21 ,
      rei_information22 ,
      rei_information23 ,
      rei_information24 ,
      rei_information25 ,
      rei_information26 ,
      rei_information27 ,
      rei_information28 ,
      rei_information29 ,
      rei_information30
      ) values
      (l_rei_rec.pa_request_extra_info_id,
      l_rei_rec.pa_request_id,
      l_rei_rec.information_type,
      l_rei_rec.rei_information1,
      l_rei_rec.rei_information2,
      l_rei_rec.rei_information3,
      l_rei_rec.rei_information4,
      l_rei_rec.rei_information5,
      l_rei_rec.rei_information6,
      l_rei_rec.rei_information7,
      l_rei_rec.rei_information8,
      l_rei_rec.rei_information9,
      l_rei_rec.rei_information10,
      l_rei_rec.rei_information11,
      l_rei_rec.rei_information12,
      l_rei_rec.rei_information13,
      l_rei_rec.rei_information14,
      l_rei_rec.rei_information15,
      l_rei_rec.rei_information16,
      l_rei_rec.rei_information17,
      l_rei_rec.rei_information18,
      l_rei_rec.rei_information19,
      l_rei_rec.rei_information20,
      l_rei_rec.rei_information21,
      l_rei_rec.rei_information22,
      l_rei_rec.rei_information23,
      l_rei_rec.rei_information24,
      l_rei_rec.rei_information25,
      l_rei_rec.rei_information26,
      l_rei_rec.rei_information27,
      l_rei_rec.rei_information28,
      l_rei_rec.rei_information29,
      l_rei_rec.rei_information30
     );

   Elsif l_flag = 'U' then
      hr_utility.set_location(l_proc,25);
      hr_utility.set_location('update extra info',1);
      ghr_par_extra_info_api.update_pa_request_extra_info
     (P_PA_REQUEST_EXTRA_INFO_ID  =>  l_rei_rec.pa_request_extra_info_id,
      P_OBJECT_VERSION_NUMBER     =>  l_rei_rec.object_version_number ,
      p_rei_information1          =>  l_rei_rec.rei_information1,
      p_rei_information2          =>  l_rei_rec.rei_information2,
      p_rei_information3          =>  l_rei_rec.rei_information3,
      p_rei_information4          =>  l_rei_rec.rei_information4,
      p_rei_information5          =>  l_rei_rec.rei_information5,
      p_rei_information6          =>  l_rei_rec.rei_information6,
      p_rei_information7          =>  l_rei_rec.rei_information7,
      p_rei_information8          =>  l_rei_rec.rei_information8,
      p_rei_information9          =>  l_rei_rec.rei_information9,
      p_rei_information10         =>  l_rei_rec.rei_information10,
      p_rei_information11         =>  l_rei_rec.rei_information11,
      p_rei_information12         =>  l_rei_rec.rei_information12,
      p_rei_information13         =>  l_rei_rec.rei_information13,
      p_rei_information14         =>  l_rei_rec.rei_information14,
      p_rei_information15         =>  l_rei_rec.rei_information15,
      p_rei_information16         =>  l_rei_rec.rei_information16,
      p_rei_information17         =>  l_rei_rec.rei_information17,
      p_rei_information18         =>  l_rei_rec.rei_information18,
      p_rei_information19         =>  l_rei_rec.rei_information19,
      p_rei_information20         =>  l_rei_rec.rei_information20,
      p_rei_information21         =>  l_rei_rec.rei_information21,
      p_rei_information22         =>  l_rei_rec.rei_information22,
      p_rei_information23         =>  l_rei_rec.rei_information23,
      p_rei_information24         =>  l_rei_rec.rei_information24,
      p_rei_information25         =>  l_rei_rec.rei_information25,
      p_rei_information26         =>  l_rei_rec.rei_information26,
      p_rei_information27         =>  l_rei_rec.rei_information27,
      p_rei_information28         =>  l_rei_rec.rei_information28,
      p_rei_information29         =>  l_rei_rec.rei_information29,
      p_rei_information30         =>  l_rei_rec.rei_information30
      );
     hr_utility.set_location('bef upd of shad ' || 'ovn ' ||  l_rei_rec.object_version_number,2);

     update ghr_pa_request_ei_shadow set
      rei_information1          =  p_org_rec.rei_information1,
      rei_information2          =  p_org_rec.rei_information2,
      rei_information3          =  p_org_rec.rei_information3,
      rei_information4          =  p_org_rec.rei_information4,
      rei_information5          =  p_org_rec.rei_information5,
      rei_information6          =  p_org_rec.rei_information6,
      rei_information7          =  p_org_rec.rei_information7,
      rei_information8          =  p_org_rec.rei_information8,
      rei_information9          =  p_org_rec.rei_information9,
      rei_information10         =  p_org_rec.rei_information10,
      rei_information11         =  p_org_rec.rei_information11,
      rei_information12         =  p_org_rec.rei_information12,
      rei_information13         =  p_org_rec.rei_information13,
      rei_information14         =  p_org_rec.rei_information14,
      rei_information15         =  p_org_rec.rei_information15,
      rei_information16         =  p_org_rec.rei_information16,
      rei_information17         =  p_org_rec.rei_information17,
      rei_information18         =  p_org_rec.rei_information18,
      rei_information19         =  p_org_rec.rei_information19,
      rei_information20         =  p_org_rec.rei_information20,
      rei_information21         =  p_org_rec.rei_information21,
      rei_information22         =  p_org_rec.rei_information22,
      rei_information23         =  p_org_rec.rei_information23,
      rei_information24         =  p_org_rec.rei_information24,
      rei_information25         =  p_org_rec.rei_information25,
      rei_information26         =  p_org_rec.rei_information26,
      rei_information27         =  p_org_rec.rei_information27,
      rei_information28         =  p_org_rec.rei_information28,
      rei_information29         =  p_org_rec.rei_information29,
      rei_information30         =  p_org_rec.rei_information30
     where pa_request_extra_info_id = l_rei_rec.pa_request_extra_info_id;


   Elsif l_flag = 'D' then
      hr_utility.set_location(l_proc,30);
      hr_utility.set_location('delete extra info',1);

       ghr_par_extra_info_api.delete_pa_request_extra_info
       (p_pa_request_extra_info_id    => l_rei_rec.pa_request_extra_info_id,
        p_object_version_number       => l_rei_rec.object_version_number
       );
        delete from ghr_pa_request_ei_shadow
        where pa_request_extra_info_id = l_rei_rec.pa_request_extra_info_id;
   End if;
 End if;
 hr_utility.set_location('Leaving ' || l_proc,40);
end generic_populate_extra_info ;

Procedure set_ei
(p_original     in out NOCOPY   varchar2,
 p_as_in_core   in     varchar2,
 p_as_in_ddf    in out NOCOPY varchar2,
 p_refresh_flag in     varchar2 default 'Y')
is

begin

  If p_refresh_flag = 'Y' then
    hr_utility.set_location('in set ei  - Y ',5);
    If nvl(p_as_in_ddf,hr_api.g_varchar2) <>  nvl(p_as_in_core,hr_api.g_varchar2) and
       nvl(p_as_in_ddf,hr_api.g_varchar2)  =   nvl(p_original,hr_api.g_varchar2) then
      p_as_in_ddf := p_as_in_core;
    End if;
  Else
     hr_utility.set_location('in set ei  - N ',6);
     p_as_in_ddf := p_as_in_core;
  End if;
    p_original := p_as_in_core;
End set_ei;

--6850492
procedure dual_extra_info_refresh(p_first_corr_pa_request_id in number,
                                  p_second_corr_pa_request_id in number,
			          p_first_noa_code in varchar2,
  			          p_second_noa_code in varchar2,
				  p_upd_info_type  in varchar2,
				  p_dual_corr_yn in varchar)
is
  cursor c_get_extra_info_details(p_pa_request_id in number,
                                  p_information_type in varchar2)
      is
      select *
      from   ghr_pa_request_extra_info
      where  pa_request_id    = p_pa_request_id
      and    information_type = p_information_type;

  cursor c_shadow_extra_info(p_pa_request_id in number,
                             p_information_type in varchar2)
      is
      select *
      from   ghr_pa_request_ei_shadow
      where  pa_request_id    = p_pa_request_id
      and    information_type = p_information_type;

  cursor get_ord_of_eit(p_information_type1 in varchar2,
                        p_information_type2 in varchar2)
      is
      select a.noa_family_code, a.information_type
      from GHR_PA_REQUEST_INFO_TYPES a,ghr_noa_families b, ghr_nature_of_actions c
      where b.nature_of_action_id= c.nature_of_action_id
      and a.noa_family_code= b.noa_family_code
      and c.code in (p_first_noa_code,p_second_noa_code)
      and a.information_type in (p_information_type1,p_information_type2)
      order by a.noa_family_code;

      l_rei_rec  ghr_pa_request_extra_info%rowtype;
      sc_rei_rec ghr_pa_request_extra_info%rowtype;
      fc_rei_rec ghr_pa_request_extra_info%rowtype;
      l_org_sc_rec  ghr_pa_request_ei_shadow%rowtype;
      l_org_fc_rec  ghr_pa_request_ei_shadow%rowtype;
      l_information_type1 ghr_pa_request_extra_info.information_type%type;
      l_information_type2 ghr_pa_request_extra_info.information_type%type;


begin
  -- Handling common segments between Conversion to Appointment and Change in Work Schedule
  l_information_type1 := NULL;
  l_information_type2 := NULL;
  --Return to Duty and Conversion to Appointment
  if p_first_noa_code in ('280','292') and substr(p_second_noa_code,1,1) = '5' then
     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	l_information_type2 := 'GHR_US_PAR_CONV_APP';
     else
       if p_upd_info_type = 'GHR_US_PAR_RETURN_TO_DUTY'  then
	  l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	  l_information_type2 := 'GHR_US_PAR_CONV_APP';
       elsif p_upd_info_type = 'GHR_US_PAR_CONV_APP' then
	  l_information_type1 := 'GHR_US_PAR_CONV_APP';
 	  l_information_type2 := 'GHR_US_PAR_RETURN_TO_DUTY';
       end if;
     end if;

     if l_information_type1 is not null and l_information_type2 is not null then
         open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                       p_information_type => l_information_type1);
         fetch c_get_extra_info_details into fc_rei_rec;
         close c_get_extra_info_details;

         open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                       p_information_type => l_information_type2);
         fetch c_get_extra_info_details into sc_rei_rec;
         if c_get_extra_info_details%found then
  	   open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                    p_information_type => l_information_type1);
	   fetch c_shadow_extra_info into l_org_fc_rec;
	   close  c_shadow_extra_info;

	   open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                    p_information_type => l_information_type2);
	   fetch c_shadow_extra_info into l_org_sc_rec;
	   close  c_shadow_extra_info;

	   l_rei_rec := sc_rei_rec;
         if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_CONV_APP' then
	   -- Part time indicator
	   set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information19,l_rei_rec.rei_information19);
	   -- Creditable Military Service
	   set_dual_ei(l_org_fc_rec.rei_information3,fc_rei_rec.rei_information3,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
           -- Frozen Service
 	   set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information6,l_rei_rec.rei_information6);
           -- Type of Employment
	   set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information13,l_rei_rec.rei_information13);
         elsif l_information_type1 = 'GHR_US_PAR_CONV_APP' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
           -- Part time indicator
	   set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information19,fc_rei_rec.rei_information19,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	   -- Creditable Military Service
	   set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information3,l_rei_rec.rei_information3);
           -- Frozen Service
 	   set_dual_ei(l_org_fc_rec.rei_information6,fc_rei_rec.rei_information6,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
           -- Type of Employment
	   set_dual_ei(l_org_fc_rec.rei_information13,fc_rei_rec.rei_information13,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
          end if;

	  generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
      else

	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;
	if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_CONV_APP' then
  	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information19,l_rei_rec.rei_information19);
	  -- Creditable Military Service
	  set_dual_ei(l_org_fc_rec.rei_information3,fc_rei_rec.rei_information3,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
          -- Frozen Service
	  set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information6,l_rei_rec.rei_information6);
          -- Type of Employment
	  set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information13,l_rei_rec.rei_information13);
	elsif l_information_type1 = 'GHR_US_PAR_CONV_APP' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
           -- Part time indicator
	   set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information19,fc_rei_rec.rei_information19,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	   -- Creditable Military Service
	   set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information3,l_rei_rec.rei_information3);
           -- Frozen Service
 	   set_dual_ei(l_org_fc_rec.rei_information6,fc_rei_rec.rei_information6,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
           -- Type of Employment
	   set_dual_ei(l_org_fc_rec.rei_information13,fc_rei_rec.rei_information13,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
        end if;
	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

     end if;
     close c_get_extra_info_details;
     end if;
  end if;

  --Return to Duty and Promotion
  if p_first_noa_code in ('280','292') and p_second_noa_code in ('702','703','713') then
     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	l_information_type2 := 'GHR_US_PAR_SALARY_CHG';
     else
         if p_upd_info_type = 'GHR_US_PAR_RETURN_TO_DUTY'  then
	    l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	    l_information_type2 := 'GHR_US_PAR_SALARY_CHG';
	 elsif p_upd_info_type = 'GHR_US_PAR_SALARY_CHG' then
	    l_information_type1 := 'GHR_US_PAR_SALARY_CHG';
 	    l_information_type2 := 'GHR_US_PAR_RETURN_TO_DUTY';
	 end if;
     end if;

     if l_information_type1 is not null and l_information_type2 is not null then

      open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                    p_information_type => l_information_type1);
      fetch c_get_extra_info_details into fc_rei_rec;
      close c_get_extra_info_details;

      open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                    p_information_type => l_information_type2);
      fetch c_get_extra_info_details into sc_rei_rec;
      if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type => l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type => l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

	if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_SALARY_CHG' then
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	elsif l_information_type1 = 'GHR_US_PAR_SALARY_CHG' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;


	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
      else
	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;

        if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_SALARY_CHG' then
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	elsif l_information_type1 = 'GHR_US_PAR_SALARY_CHG' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;

--Return to Duty and Reassignment
  if p_first_noa_code in ('280','292') and p_second_noa_code in ('721') then

     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	l_information_type2 := 'GHR_US_PAR_REASSIGNMENT';
     else
         if p_upd_info_type = 'GHR_US_PAR_RETURN_TO_DUTY'  then
	    l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	    l_information_type2 := 'GHR_US_PAR_REASSIGNMENT';
	 elsif p_upd_info_type = 'GHR_US_PAR_REASSIGNMENT' then
	    l_information_type1 := 'GHR_US_PAR_REASSIGNMENT';
 	    l_information_type2 := 'GHR_US_PAR_RETURN_TO_DUTY';
	 end if;
     end if;

    if l_information_type1 is not null and l_information_type2 is not null then
     open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                   p_information_type => l_information_type1);
     fetch c_get_extra_info_details into fc_rei_rec;
     close c_get_extra_info_details;

     open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                   p_information_type => l_information_type2);
     fetch c_get_extra_info_details into sc_rei_rec;
     if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type => l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type => l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

        if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_REASSIGNMENT' then
	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	elsif l_information_type1 = 'GHR_US_PAR_REASSIGNMENT' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	end if;


	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
    else
	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;

	if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_REASSIGNMENT' then
  	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	elsif l_information_type1 = 'GHR_US_PAR_REASSIGNMENT' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
   	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;

    --Return to Duty and Change in WorkSchedule or Change in Hours
  if p_first_noa_code in ('280','292') and p_second_noa_code in ('781','782') then

     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
     else
         if p_upd_info_type = 'GHR_US_PAR_RETURN_TO_DUTY'  then
	    l_information_type1 := 'GHR_US_PAR_RETURN_TO_DUTY';
	    l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
	 elsif p_upd_info_type = 'GHR_US_PAR_CHG_HOURS' then
	    l_information_type1 := 'GHR_US_PAR_CHG_HOURS';
 	    l_information_type2 := 'GHR_US_PAR_RETURN_TO_DUTY';
	 end if;
     end if;

    if l_information_type1 is not null and l_information_type2 is not null then
     open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                   p_information_type => l_information_type1);
     fetch c_get_extra_info_details into fc_rei_rec;
     close c_get_extra_info_details;

     open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                   p_information_type => l_information_type2);
     fetch c_get_extra_info_details into sc_rei_rec;
     if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type =>l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type =>l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

	if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
   	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;

	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
    else

	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;

	if l_information_type1 = 'GHR_US_PAR_RETURN_TO_DUTY' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
  	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
 	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_RETURN_TO_DUTY' then
           -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
 	  set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;

 --- Conversion to Appointment and Change in WorkSchedule/Part Time Hours
  if substr(p_first_noa_code,1,1) = '5' and p_second_noa_code in ('781','782') then

     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_CONV_APP';
	l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
     else
         if p_upd_info_type = 'GHR_US_PAR_CONV_APP'  then
	    l_information_type1 := 'GHR_US_PAR_CONV_APP';
	    l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
	 elsif p_upd_info_type = 'GHR_US_PAR_CHG_HOURS' then
	    l_information_type1 := 'GHR_US_PAR_CHG_HOURS';
 	    l_information_type2 := 'GHR_US_PAR_CONV_APP';
	 end if;
     end if;

    if l_information_type1 is not null and l_information_type2 is not null then
     open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                   p_information_type => l_information_type1);
     fetch c_get_extra_info_details into fc_rei_rec;
     close c_get_extra_info_details;

     open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                   p_information_type => l_information_type2);
     fetch c_get_extra_info_details into sc_rei_rec;
     if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type => l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type => l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

        if l_information_type1 = 'GHR_US_PAR_CONV_APP' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
   	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information19,fc_rei_rec.rei_information19,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_CONV_APP' then
          -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information19,l_rei_rec.rei_information19);
	end if;

	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
    else
	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;

	 if l_information_type1 = 'GHR_US_PAR_CONV_APP' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
   	  -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information8,fc_rei_rec.rei_information8,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information19,fc_rei_rec.rei_information19,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_CONV_APP' then
          -- Part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information8,l_rei_rec.rei_information8);
	  -- WGI Due Date
	  set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information19,l_rei_rec.rei_information19);
	end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;

   --- Promotion and Change in WorkSchedule/Part Time Hours
  if p_first_noa_code in ('702','703','713') and p_second_noa_code in ('781','782') then

     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_SALARY_CHG';
	l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
     else
         if p_upd_info_type = 'GHR_US_PAR_SALARY_CHG'  then
	    l_information_type1 := 'GHR_US_PAR_SALARY_CHG';
	    l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
	 elsif p_upd_info_type = 'GHR_US_PAR_CHG_HOURS' then
	    l_information_type1 := 'GHR_US_PAR_CHG_HOURS';
 	    l_information_type2 := 'GHR_US_PAR_SALARY_CHG';
	 end if;
     end if;

    if l_information_type1 is not null and l_information_type2 is not null then
     open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                   p_information_type => l_information_type1);
     fetch c_get_extra_info_details into fc_rei_rec;
     close c_get_extra_info_details;

     open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                   p_information_type => l_information_type2);
     fetch c_get_extra_info_details into sc_rei_rec;
     if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type => l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type => l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

        if l_information_type1 = 'GHR_US_PAR_SALARY_CHG' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
  	   -- Date WGI Postpone Effective
	   set_dual_ei(l_org_fc_rec.rei_information3,fc_rei_rec.rei_information3,l_org_sc_rec.rei_information6,l_rei_rec.rei_information6);
  	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif  l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_SALARY_CHG' then
           -- Date WGI Postpone Effective
	   set_dual_ei(l_org_fc_rec.rei_information6,fc_rei_rec.rei_information6,l_org_sc_rec.rei_information3,l_rei_rec.rei_information3);
  	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;
	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
    else
	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;


	if l_information_type1 = 'GHR_US_PAR_SALARY_CHG' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
  	   -- Date WGI Postpone Effective
	   set_dual_ei(l_org_fc_rec.rei_information3,fc_rei_rec.rei_information3,l_org_sc_rec.rei_information6,l_rei_rec.rei_information6);
  	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information5,l_rei_rec.rei_information5);
	elsif  l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_SALARY_CHG' then
           -- Date WGI Postpone Effective
	   set_dual_ei(l_org_fc_rec.rei_information6,fc_rei_rec.rei_information6,l_org_sc_rec.rei_information3,l_rei_rec.rei_information3);
  	   -- WGI Due Date
	   set_dual_ei(l_org_fc_rec.rei_information5,fc_rei_rec.rei_information5,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
	end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;

  --- Reassignment and Change in WorkSchedule/Part Time Hours
  if p_first_noa_code in ('721') and p_second_noa_code in ('781','782') then

     if NVL(p_dual_corr_yn,'N') = 'Y' then
        l_information_type1 := 'GHR_US_PAR_REASSIGNMENT';
	l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
     else
         if p_upd_info_type = 'GHR_US_PAR_REASSIGNMENT'  then
	    l_information_type1 := 'GHR_US_PAR_REASSIGNMENT';
	    l_information_type2 := 'GHR_US_PAR_CHG_HOURS';
	 elsif p_upd_info_type = 'GHR_US_PAR_CHG_HOURS' then
	    l_information_type1 := 'GHR_US_PAR_CHG_HOURS';
 	    l_information_type2 := 'GHR_US_PAR_REASSIGNMENT';
	 end if;
     end if;

    if l_information_type1 is not null and l_information_type2 is not null then
     open c_get_extra_info_details(p_pa_request_id => p_first_corr_pa_request_id,
                                   p_information_type => l_information_type1);
     fetch c_get_extra_info_details into fc_rei_rec;
     close c_get_extra_info_details;

     open c_get_extra_info_details(p_pa_request_id => p_second_corr_pa_request_id,
                                   p_information_type => l_information_type2);
     fetch c_get_extra_info_details into sc_rei_rec;
     if c_get_extra_info_details%found then
	open c_shadow_extra_info(p_pa_request_id => p_first_corr_pa_request_id,
                                 p_information_type => l_information_type1);
	fetch c_shadow_extra_info into l_org_fc_rec;
	close  c_shadow_extra_info;

	open c_shadow_extra_info(p_pa_request_id => p_second_corr_pa_request_id,
                                 p_information_type => l_information_type2);
	fetch c_shadow_extra_info into l_org_sc_rec;
	close  c_shadow_extra_info;

	l_rei_rec := sc_rei_rec;

       if l_information_type1 = 'GHR_US_PAR_REASSIGNMENT' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
	  -- part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
       elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_REASSIGNMENT' then
	  -- part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
       end if;

	generic_populate_extra_info
                    (p_rei_rec            =>  l_rei_rec,
                     p_org_rec            =>  l_org_sc_rec,
                     p_flag               =>  'U');
    else
	l_rei_rec.pa_request_id := p_second_corr_pa_request_id;
	l_rei_rec.information_type := l_information_type2;

	if l_information_type1 = 'GHR_US_PAR_REASSIGNMENT' and l_information_type2 = 'GHR_US_PAR_CHG_HOURS' then
	  -- part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information4,fc_rei_rec.rei_information4,l_org_sc_rec.rei_information7,l_rei_rec.rei_information7);
        elsif l_information_type1 = 'GHR_US_PAR_CHG_HOURS' and l_information_type2 = 'GHR_US_PAR_REASSIGNMENT' then
	  -- part time indicator
	  set_dual_ei(l_org_fc_rec.rei_information7,fc_rei_rec.rei_information7,l_org_sc_rec.rei_information4,l_rei_rec.rei_information4);
        end if;

	generic_populate_extra_info
              (p_rei_rec    =>  l_rei_rec,
               p_org_rec    =>  l_org_sc_rec,
               p_flag       =>  'C'
                );

   end if;
	 close c_get_extra_info_details;
    end if;
   end if;
 end;

 Procedure set_dual_ei
(p_first_original     in     varchar2,
 p_first_as_in_ddf    in     varchar2,
 p_sec_original       in     varchar2,
 p_sec_as_in_ddf      in out NOCOPY varchar2)
is

begin

  if nvl(p_first_as_in_ddf,'-1') <> nvl(p_first_original,'-1') and
     nvl(p_first_as_in_ddf,'-1') <> nvl(p_sec_as_in_ddf,'-1') then
     p_sec_as_in_ddf := p_first_as_in_ddf;
  end if;

  if nvl(p_first_as_in_ddf,'-1') = nvl(p_first_original,'-1') and
     nvl(p_sec_as_in_ddf,'-1') <> nvl(p_sec_original,'-1') then
     p_sec_as_in_ddf := p_sec_original;
  end if;
End set_dual_ei;
--6850492

end GHR_NON_SF52_EXTRA_INFO;

/
