--------------------------------------------------------
--  DDL for Package Body GHR_APPROVED_PA_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_APPROVED_PA_REQUESTS" AS
/* $Header: ghparapr.pkb 120.14.12010000.10 2009/10/14 07:05:33 vmididho ship $ */
g_package_name varchar2(31) := 'GHR_APPROVED_PA_REQUESTS.';
procedure create_pa_request_extra_info (
              p_new_pa_request_id  IN NUMBER
             ,p_old_pa_request_id  IN NUMBER)
IS
    CURSOR c_rei IS
        SELECT *
          FROM ghr_pa_request_extra_info
         WHERE pa_request_id = p_old_pa_request_id;
    v_ovn                         NUMBER;
    v_pa_request_extra_info_id    NUMBER;
   l_proc                         varchar2(61) := g_package_name || 'CREATE_PA_REQUEST_EXTRA_INFO';
BEGIN
    hr_utility.set_location('Entering  '|| l_proc, 10);
    FOR r_rei IN c_rei LOOP
        ghr_par_extra_info_api.create_pa_request_extra_info(
          p_pa_request_id                =>  p_new_pa_request_id
         ,p_information_type             =>  r_rei.information_type
         ,p_rei_attribute_category       =>  r_rei.rei_attribute_category
         ,p_rei_attribute1               =>  r_rei.rei_attribute1
         ,p_rei_attribute2               =>  r_rei.rei_attribute2
         ,p_rei_attribute3               =>  r_rei.rei_attribute3
         ,p_rei_attribute4               =>  r_rei.rei_attribute4
         ,p_rei_attribute5               =>  r_rei.rei_attribute5
         ,p_rei_attribute6               =>  r_rei.rei_attribute6
         ,p_rei_attribute7               =>  r_rei.rei_attribute7
         ,p_rei_attribute8               =>  r_rei.rei_attribute8
         ,p_rei_attribute9               =>  r_rei.rei_attribute9
         ,p_rei_attribute10              =>  r_rei.rei_attribute10
         ,p_rei_attribute11              =>  r_rei.rei_attribute11
         ,p_rei_attribute12              =>  r_rei.rei_attribute12
         ,p_rei_attribute13              =>  r_rei.rei_attribute13
         ,p_rei_attribute14              =>  r_rei.rei_attribute14
         ,p_rei_attribute15              =>  r_rei.rei_attribute15
         ,p_rei_attribute16              =>  r_rei.rei_attribute16
         ,p_rei_attribute17              =>  r_rei.rei_attribute17
         ,p_rei_attribute18              =>  r_rei.rei_attribute18
         ,p_rei_attribute19              =>  r_rei.rei_attribute19
         ,p_rei_attribute20              =>  r_rei.rei_attribute20
         ,p_rei_information_category     =>  r_rei.rei_information_category
         ,p_rei_information1             =>  r_rei.rei_information1
         ,p_rei_information2             =>  r_rei.rei_information2
         ,p_rei_information3             =>  r_rei.rei_information3
         ,p_rei_information4             =>  r_rei.rei_information4
         ,p_rei_information5             =>  r_rei.rei_information5
         ,p_rei_information6             =>  r_rei.rei_information6
         ,p_rei_information7             =>  r_rei.rei_information7
         ,p_rei_information8             =>  r_rei.rei_information8
         ,p_rei_information9             =>  r_rei.rei_information9
         ,p_rei_information10            =>  r_rei.rei_information10
         ,p_rei_information11            =>  r_rei.rei_information11
         ,p_rei_information12            =>  r_rei.rei_information12
         ,p_rei_information13            =>  r_rei.rei_information13
         ,p_rei_information14            =>  r_rei.rei_information14
         ,p_rei_information15            =>  r_rei.rei_information15
         ,p_rei_information16            =>  r_rei.rei_information16
         ,p_rei_information17            =>  r_rei.rei_information17
         ,p_rei_information18            =>  r_rei.rei_information18
         ,p_rei_information19            =>  r_rei.rei_information19
         ,p_rei_information20            =>  r_rei.rei_information20
         ,p_rei_information21            =>  r_rei.rei_information21
         ,p_rei_information22            =>  r_rei.rei_information22
         ,p_rei_information23            =>  r_rei.rei_information23
         ,p_rei_information24            =>  r_rei.rei_information24
         ,p_rei_information25            =>  r_rei.rei_information25
         ,p_rei_information26            =>  r_rei.rei_information26
         ,p_rei_information27            =>  r_rei.rei_information27
         ,p_rei_information28            =>  r_rei.rei_information28
         ,p_rei_information29            =>  r_rei.rei_information29
         ,p_rei_information30            =>  r_rei.rei_information30
         ,p_pa_request_extra_info_id     =>  v_pa_request_extra_info_id
         ,p_object_version_number        =>  v_ovn
        );
    END LOOP;
    hr_utility.set_location('Exiting  '|| l_proc, 100);
end;
-- -------------------------------------------------
   PROCEDURE get_roles
-- -------------------------------------------------
                    (p_routing_group_id    IN             NUMBER
                    ,p_user_name           IN             VARCHAR2
                    ,p_initiator_flag      IN OUT  nocopy VARCHAR2
                    ,p_requester_flag      IN OUT  nocopy VARCHAR2
                    ,p_authorizer_flag     IN OUT  nocopy VARCHAR2
                    ,p_personnelist_flag   IN OUT  nocopy VARCHAR2
                    ,p_approver_flag       IN OUT  nocopy VARCHAR2
                    ,p_reviewer_flag       IN OUT  nocopy VARCHAR2
) IS

l_proc                varchar2(61) := g_package_name || 'GET_ROLES';
l_initiator_flag      VARCHAR2(150);
l_requester_flag      VARCHAR2(150);
l_authorizer_flag     VARCHAR2(150);
l_personnelist_flag   VARCHAR2(150);
l_approver_flag       VARCHAR2(150);
l_reviewer_flag       VARCHAR2(150);

CURSOR c_user_roles IS
  SELECT pei.pei_information4 initiator_flag
        ,pei.pei_information5 requester_flag
        ,pei.pei_information6 authorizer_flag
        ,pei.pei_information7 personnelist_flag
        ,pei.pei_information8 approver_flag
        ,pei.pei_information9 reviewer_flag
  FROM   per_people_extra_info pei
        ,fnd_user              usr
  WHERE  usr.user_name        = p_user_name
  AND    pei.person_id        = usr.employee_id
  AND    pei.information_type = 'GHR_US_PER_WF_ROUTING_GROUPS'
  AND    pei.pei_information3 = p_routing_group_id;

BEGIN

   l_initiator_flag      := p_initiator_flag;
   l_requester_flag      := p_requester_flag;
   l_authorizer_flag     := p_authorizer_flag;
   l_personnelist_flag   := p_personnelist_flag;
   l_approver_flag       := p_approver_flag;
   l_reviewer_flag       := p_reviewer_flag;

   hr_utility.set_location('Entering  '|| l_proc, 5);

   OPEN c_user_roles;
   FETCH c_user_roles INTO
                        p_initiator_flag
                       ,p_requester_flag
                       ,p_authorizer_flag
                       ,p_personnelist_flag
                       ,p_approver_flag
                       ,p_reviewer_flag;

   CLOSE c_user_roles;
   hr_utility.set_location('Exiting  '|| l_proc, 15);

EXCEPTION
WHEN OTHERS THEN
	p_initiator_flag      := l_initiator_flag;
	p_requester_flag      := l_requester_flag;
	p_authorizer_flag     := l_authorizer_flag;
	p_personnelist_flag   := l_personnelist_flag;
	p_approver_flag       := l_approver_flag;
	p_reviewer_flag       := l_reviewer_flag;

END;

-- ---------------------------------
   PROCEDURE can_cancel_or_correct(
-- ---------------------------------
  p_pa_request_id              in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar
, p_total_actions              in out nocopy number
, p_corrections                in out nocopy number
, p_rpas                       in out nocopy number
)
IS
  l_proc                         varchar2(61) := g_package_name || 'CAN_CANCEL_OR_CORRECT';
  l_first_pa_request_rec              ghr_pa_requests%ROWTYPE;
  l_last_pa_request_rec               ghr_pa_requests%ROWTYPE;


--5725885 vmididho to improve performance
--5725885 modified the cursor instead of using view changed to use the query getting
-- a particular person records to improve the performance
/*  CURSOR c_pa_requests(p_person_id     IN NUMBER
--                     , p_pa_request_id IN NUMBER
                     , p_effective_date IN DATE) IS
  --SELECT *
SELECT PA_NOTIFICATION_ID
  FROM GHR_PA_REQUESTS_V1
  WHERE person_id    = p_person_id
    AND effective_date >= p_effective_date;*/

  CURSOR c_pa_requests(p_person_id     IN NUMBER)
    IS
    select PA_NOTIFICATION_ID,effective_date
    from   ghr_pa_requests par
    where  (level = 1 and pa_notification_id is not null) or (level > 1 and ( nvl(status, 'CANCELED') <> 'CANCELED'
    AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL' AND first_noa_code <> '001' ) )
    start with altered_pa_request_id is null
           and person_id = p_person_id
	   and NVL(first_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
           and first_noa_canc_pa_request_id is null
    connect by prior pa_request_id = altered_pa_request_id
               and
	       prior decode(first_noa_code, '002', second_noa_code, '001' , second_noa_code ,first_noa_code) = second_noa_code
    UNION ALL
    select PA_NOTIFICATION_ID,effective_date
    from ghr_pa_requests par
    where (level = 1 and pa_notification_id is not null)
       or (level > 1 and ( nvl(status, 'CANCELED') <> 'CANCELED'
      AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL' AND first_noa_code <> '001' ) )
    start with altered_pa_request_id is null
           and person_id = p_person_id
	   and NVL(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
           and second_noa_code is not null and second_noa_canc_pa_request_id is null
    connect by prior pa_request_id = altered_pa_request_id
               and
	       prior second_noa_code = second_noa_code;

  -- Bug# 4005884 Added cursor to verify the prior person type.
  Cursor c_prior_person_type(p_Person_id NUMBER, p_effective_Date DATE) is
   select  'EX_EMP'  system_person_type
   from    ghr_pa_requests pa
   where   pa.noa_family_code = 'SEPARATION'
     and   pa.effective_date < p_effective_date
     and   pa.person_id = p_person_id
     and   exists (select '1'
	             from ghr_pa_history pah
  		     where pah.pa_request_id = pa.pa_request_id);

  l_system_type    per_person_types.system_person_type%type;
  l_total_actions  number;
  l_corrections    number;
  l_rpas           number;
BEGIN
  hr_utility.set_location('Entering  '|| l_proc, 5);
  l_total_actions  := p_total_actions;
  l_corrections    := p_corrections;
  l_rpas           := p_rpas;
  p_total_actions := 0;
  p_rpas := 0;
  p_corrections := 0;
  find_last_request(p_pa_request_id              => p_pa_request_id
                  , p_which_noa                  => p_which_noa
                  , p_row_id                     => p_row_id
                  , p_first_pa_request_rec       => l_first_pa_request_rec
                  , p_last_pa_request_rec        => l_last_pa_request_rec
                  , p_number_of_requests         => p_corrections);
  IF l_last_pa_request_rec.pa_notification_id IS NULL THEN
     p_corrections := -1;
     return;
  END IF;
--
--
 -- Bug# 4005884
    If  l_first_pa_request_rec.noa_family_code = 'CONV_APP' then
	   -- check to see if the person was an EX_EMP prior to the effective date of this action.
		for prior_person_type in c_prior_person_type(l_first_pa_request_rec.person_id,
                                                     l_first_pa_request_rec.effective_date)
        loop
		  l_system_type :=  prior_person_type.system_person_type;
		  exit;
		end loop;
	End if;
  -- Bug# 1295751, Added CONV_APP to get subsequent actions
  -- Bug# 4005884 Modified the CONV_APP condition to populate message only in case of PRIOR EX_EMP.
  IF (l_first_pa_request_rec.noa_family_code = 'APP' OR
       (l_first_pa_request_rec.noa_family_code = 'CONV_APP' AND l_system_type = 'EX_EMP')
      )THEN
     -- Get all subsequent action
     FOR r_pa_requests IN c_pa_requests(p_person_id     => l_first_pa_request_rec.person_id)
                                      -- , p_pa_request_id => l_first_pa_request_rec.pa_request_id
                                      -- , p_effective_date => l_first_pa_request_rec.effective_date)
     LOOP
     --5725885 modified to compare effective date inside the loop
         IF r_pa_requests.effective_date >= l_first_pa_request_rec.effective_date then
            p_total_actions := p_total_actions + 1;

            IF r_pa_requests.pa_notification_id IS NULL THEN
               p_rpas := p_rpas + 1;
            END IF;
	 END IF;
     END LOOP;
  END IF;
/*
  p_total_actions := p_total_actions - (p_rpas + p_corrections + 1);
  IF p_total_actions > 0 THEN
     IF p_corrections > 0 THEN
       fnd_message.set_name('GHR', 'GHR_CANCEL_APP_WITH_CORRECTION');
       fnd_message.set_token('CORRECT', p_corrections);
       fnd_message.set_token('ORIGINAL', p_total_actions);
     ELSE
       fnd_message.set_name('GHR', 'GHR_CANCEL_APP');
       fnd_message.set_token('ORIGINAL', p_total_actions);
     END IF;
   ELSIF p_corrections > 0 THEN
       fnd_message.set_name('GHR', 'GHR_CANCEL_ANY_ACTION');
       fnd_message.set_token('CORRECT', p_corrections);
   END IF;
*/

   hr_utility.set_location(l_proc || ' First Pa Request ID : '  || to_char(l_first_pa_request_rec.pa_request_id), 10);
   hr_utility.set_location(l_proc || ' Last Pa Request ID : '  || to_char(l_last_pa_request_rec.pa_request_id), 20);
   hr_utility.set_location('Exiting  '|| l_proc, 500);
EXCEPTION
  WHEN OTHERS THEN
    p_total_actions  := l_total_actions;
    p_corrections    := l_corrections;
    p_rpas           := l_rpas;
END;

-- ---------------------------------
   PROCEDURE find_last_request(
-- ---------------------------------
  p_pa_request_id              in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar
, p_first_pa_request_rec       in out nocopy GHR_PA_REQUESTS%ROWTYPE
, p_last_pa_request_rec        in out nocopy GHR_PA_REQUESTS%ROWTYPE
, p_number_of_requests         in out nocopy number
)
is
   l_proc                         varchar2(61) := g_package_name || 'FIND_LAST_REQUEST';
   l_pa_req                       GHR_PA_REQUESTS%ROWTYPE;

   -- 5925784 The below cursor is splitted into two due to UnionALL performance in 10g
/*   CURSOR c_get_last_request IS
   SELECT
     effective_date
   , DECODE(first_noa_code, '002', second_noa_code
                          , '001', second_noa_code
                                 , first_noa_code)                noa_code
   , ROWNUM                                                       row_num
   , LEVEL                                                        hierarchy_level
   , pa_request_id
   , pa_notification_id
   , approval_date
   , person_id
   , employee_assignment_id
   , 1                                                            WHICH_NOA
   , ROWID                                                        ROW_ID
   , DECODE(pa_notification_id, NULL, 'Routed', 'Processed')      action_type
   , altered_pa_request_id
   , status
   FROM ghr_pa_requests par
   WHERE (LEVEL = 1 and pa_notification_id IS NOT NULL)
   or    (level > 1
        and (   nvl(status, 'CANCELED') <> 'CANCELED'
             AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
             AND first_noa_code <> '001'
		)
      )
   START WITH altered_pa_request_id IS NULl
   AND NVL(first_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
   AND ROWID = CHARTOROWID(p_row_id)
   AND p_which_noa = 1
   AND first_noa_canc_pa_request_id IS NULL
   CONNECT BY PRIOR pa_request_id = altered_pa_request_id
   AND PRIOR DECODE(first_noa_code, '002', second_noa_code, '001', second_noa_code ,first_noa_code) = second_noa_code
   UNION ALL
   SELECT
     effective_date
   , second_noa_code
   , ROWNUM
   , LEVEL
   , pa_request_id
   , pa_notification_id
   , approval_date
   , par.person_id
   , par.employee_assignment_id
   , 2 which_noa
   , par.ROWID
   , DECODE(pa_notification_id, NULL, 'Routed', 'Processed')
   , altered_pa_request_id
   , par.status
   FROM ghr_pa_requests par
   WHERE (LEVEL = 1 AND pa_notification_id IS NOT NULL)
      or    (level > 1
        and (   nvl(status, 'CANCELED') <> 'CANCELED'
             AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
             AND first_noa_code <> '001'
                )
      )
   START WITH altered_pa_request_id IS NULL
   AND NVL(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
   AND second_noa_code IS NOT NULL
   AND ROWID = chartorowid(p_row_id)
   AND p_which_noa = 2
   AND second_noa_canc_pa_request_id IS NULL
   CONNECT BY PRIOR pa_request_id = altered_pa_request_id
   AND PRIOR second_noa_code = second_noa_code
   ORDER BY 1, 2, 3;*/


CURSOR c_get_last_request_1 IS
   SELECT
     effective_date
   , DECODE(first_noa_code, '002', second_noa_code
                          , '001', second_noa_code
                                 , first_noa_code)                noa_code
   , ROWNUM                                                       row_num
   , LEVEL                                                        hierarchy_level
   , pa_request_id
   , pa_notification_id
   , approval_date
   , person_id
   , employee_assignment_id
   , 1                                                            WHICH_NOA
   , ROWID                                                        ROW_ID
   , DECODE(pa_notification_id, NULL, 'Routed', 'Processed')      action_type
   , altered_pa_request_id
   , status
   FROM ghr_pa_requests par
   WHERE (LEVEL = 1 and pa_notification_id IS NOT NULL)
   or    (level > 1
        and (   nvl(status, 'CANCELED') <> 'CANCELED'
             AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
             AND first_noa_code <> '001'
		)
      )
   START WITH altered_pa_request_id IS NULl
   AND NVL(first_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
   AND ROWID = CHARTOROWID(p_row_id)
--   AND p_which_noa = 1
   AND first_noa_canc_pa_request_id IS NULL
   CONNECT BY PRIOR pa_request_id = altered_pa_request_id
   AND PRIOR DECODE(first_noa_code, '002', second_noa_code, '001', second_noa_code ,first_noa_code) = second_noa_code
   ORDER BY 1, 2, 3;

 CURSOR c_get_last_request_2 IS
   SELECT
     effective_date
   , second_noa_code
   , ROWNUM
   , LEVEL
   , pa_request_id
   , pa_notification_id
   , approval_date
   , par.person_id
   , par.employee_assignment_id
   , 2 which_noa
   , par.ROWID
   , DECODE(pa_notification_id, NULL, 'Routed', 'Processed')
   , altered_pa_request_id
   , par.status
   FROM ghr_pa_requests par
   WHERE (LEVEL = 1 AND pa_notification_id IS NOT NULL)
      or    (level > 1
        and (   nvl(status, 'CANCELED') <> 'CANCELED'
             AND nvl(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
             AND first_noa_code <> '001'
                )
      )
   START WITH altered_pa_request_id IS NULL
   AND NVL(second_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
   AND second_noa_code IS NOT NULL
   AND ROWID = chartorowid(p_row_id)
--   AND p_which_noa = 2
   AND second_noa_canc_pa_request_id IS NULL
   CONNECT BY PRIOR pa_request_id = altered_pa_request_id
   AND PRIOR second_noa_code = second_noa_code
   ORDER BY 1, 2, 3;

--
   CURSOR c_pa_request(p_rowid IN ROWID) IS
   SELECT *
   FROM ghr_pa_requests
   WHERE ROWID = p_rowid;
--
  l_last_row                c_get_last_request_1%ROWTYPE;
  l_first_pa_request_rec    GHR_PA_REQUESTS%ROWTYPE;
  l_last_pa_request_rec     GHR_PA_REQUESTS%ROWTYPE;
  l_number_of_requests      number;

BEGIN

   hr_utility.set_location('Entering  '|| l_proc, 5);
   l_first_pa_request_rec := p_first_pa_request_rec;
   l_last_pa_request_rec  := p_last_pa_request_rec;
   l_number_of_requests   := p_number_of_requests;

   OPEN c_pa_request(chartorowid(p_row_id));
   FETCH c_pa_request INTO p_first_pa_request_rec;
   CLOSE c_pa_request;
   hr_utility.set_location(l_proc || ' First PA Request id  ' || p_first_pa_request_rec.pa_request_id, 15);
   hr_utility.set_location(l_proc || ' First Family Code   ' || p_first_pa_request_rec.noa_family_code, 25);
   hr_utility.set_location(l_proc || ' First Person Id   ' || p_first_pa_request_rec.person_id, 35);
   hr_utility.set_location(l_proc || ' First ROW Id   ' || rowidtochar(p_row_id), 40);
   hr_utility.set_location(l_proc || ' Which NOA  ' || p_which_noa, 43);

   p_number_of_requests := -1;
/*
  FOR r_get_last_request IN c_get_last_request LOOP
      p_number_of_requests := p_number_of_requests + 1;
      l_last_row := r_get_last_request;
  END LOOP;*/

  -- 5925784  Code change related to the performance issue on UNION ALL
  -- breaking single into two different queries

   If p_which_noa = 1 then
      FOR r_get_last_request IN c_get_last_request_1 LOOP
          p_number_of_requests := p_number_of_requests + 1;
          l_last_row := r_get_last_request;
      END LOOP;
   Elsif p_which_noa = 2 then
       FOR r_get_last_request IN c_get_last_request_2 LOOP
          p_number_of_requests := p_number_of_requests + 1;
          l_last_row := r_get_last_request;
       END LOOP;
   End If;

   OPEN c_pa_request(l_last_row.row_id);
   FETCH c_pa_request INTO p_last_pa_request_rec;
   CLOSE c_pa_request;
   hr_utility.set_location(l_proc || ' last PA Request id  ' || p_last_pa_request_rec.pa_request_id, 45);
   hr_utility.set_location(l_proc || ' Last ROW Id   ' || rowidtochar(l_last_row.row_id), 55);
   hr_utility.set_location('Exiting  '|| l_proc, 500);
EXCEPTION
  WHEN OTHERS THEN
    p_first_pa_request_rec := l_first_pa_request_rec;
    p_last_pa_request_rec  := l_last_pa_request_rec;
    p_number_of_requests   := l_number_of_requests;

END;

------------------------
-- Cancelation
------------------------
function ghr_cancel_sf52 (
  p_pa_request_id              in     number
, p_par_object_version_number  in out nocopy number
, p_noa_id                     in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar2
, p_username                   in     varchar2
, p_which_action               in     varchar2 default 'SUBSEQUENT'
, p_cancel_legal_authority     in     varchar2)
return number
is
--
   l_proc                         varchar2(61) := g_package_name || 'GHR_CANCEL_SF52';
   l_pa_req_rec                   ghr_pa_requests%rowtype;
   l_par_object_version_number    number;
   l_1_pa_routing_history_id      number;
   l_1_prh_object_version_number  number;
   l_2_pa_routing_history_id      number;
   l_2_prh_object_version_number  number;
   l_noa_cancel_or_correct        varchar2(10);
   l_U_PRH_OBJECT_VERSION_NUMBER  number;
   l_i_pa_routing_history_id      number;
   L_I_PRH_OBJECT_VERSION_NUMBER  number;
   l_par_object_version_number1    number;
   l_dummy			  number;
   --Begin Bug# 8344672
   l_first_action_la_code1         ghr_pa_request_shadow.first_action_la_code1%type;
   l_first_action_la_code2         ghr_pa_request_shadow.first_action_la_code2%type;
   l_second_action_la_code1        ghr_pa_request_shadow.second_action_la_code1%type;
   l_second_action_la_code2        ghr_pa_request_shadow.second_action_la_code2%type;

    cursor c_lac_shadow is
   select first_action_la_code1,first_action_la_code2,second_action_la_code1,second_action_la_code2
   from ghr_pa_request_shadow
   where pa_request_id = p_pa_request_id;
   --End Bug# 8344672
--
   cursor c_pa_req is
   select *
   from ghr_pa_requests
   where rowid = chartorowid(p_row_id);
--
   cursor C_noa_id(p_noa_code varchar2, p_effective_date date) is
   select nature_of_action_id, description
   from ghr_nature_of_actions
   where code = p_noa_code
   and   p_effective_date between date_from and nvl(date_to, p_effective_date);
--
   cursor c_noa_code (p_noa_id number)is
   select code
   from ghr_nature_of_actions where nature_of_action_id = p_noa_id;
--
-- Added this cursor for bug # 2951865 to check if the person is persent in the system !!
   CURSOR chk_person ( p_person_id NUMBER ) IS
   SELECT person_id
   FROM per_all_people_f
   WHERE person_id = p_person_id ;
--
   v_old_pa_request_id  NUMBER;
--
begin
   hr_utility.set_location('Entering  '|| l_proc, 5);
   l_par_object_version_number1 := p_par_object_version_number;

-- Get PA Request
   open c_pa_req;
   fetch c_pa_req into l_pa_req_rec;
   close c_pa_req;

    --Begin Bug# 8344672
   for l_lac_shadow in c_lac_shadow loop
	l_first_action_la_code1  := l_lac_shadow.first_action_la_code1;
	l_first_action_la_code2  := l_lac_shadow.first_action_la_code2;
	l_second_action_la_code1 := l_lac_shadow.second_action_la_code1;
	l_second_action_la_code2 := l_lac_shadow.second_action_la_code2;
   end loop;
   --End Bug# 8344672
-- -------------------------------------------
-- Populate Second Noa Detail
-- -------------------------------------------
   if p_which_noa = 1 then
       l_pa_req_rec.second_action_la_code1  := l_pa_req_rec.first_action_la_code1;
       l_pa_req_rec.second_action_la_code2  := l_pa_req_rec.first_action_la_code2;
       l_pa_req_rec.second_action_la_desc1  := l_pa_req_rec.first_action_la_desc1;
       l_pa_req_rec.second_action_la_desc2  := l_pa_req_rec.first_action_la_desc2;
       l_pa_req_rec.second_noa_code         := l_pa_req_rec.first_noa_code;
       l_pa_req_rec.second_noa_desc         := l_pa_req_rec.first_noa_desc;
       l_pa_req_rec.second_noa_id           := l_pa_req_rec.first_noa_id;
        -- Bug#5036997 Added the information columns
       l_pa_req_rec.second_lac1_information1 := l_pa_req_rec.first_lac1_information1;
       l_pa_req_rec.second_lac1_information2 := l_pa_req_rec.first_lac1_information2;
       l_pa_req_rec.second_lac1_information3 := l_pa_req_rec.first_lac1_information3; ----Bug 8792086
       l_pa_req_rec.second_lac2_information1 := l_pa_req_rec.first_lac2_information1;
       l_pa_req_rec.second_lac2_information2 := l_pa_req_rec.first_lac2_information2;
       l_pa_req_rec.second_lac2_information3 := l_pa_req_rec.first_lac2_information3; ----Bug 8792086
       --Begin Bug# 8344672
	l_second_action_la_code1 := l_first_action_la_code1;
	l_second_action_la_code2 := l_first_action_la_code2;
	--End Bug# 8344672
   end if;
-- -------------------------------------------
-- Populate First Noa Detail
-- -------------------------------------------
-- Cancellation NOA
   l_pa_req_rec.first_noa_code := '001';
-- Get NOA Id
   Open c_noa_id(l_pa_req_rec.first_noa_code, l_pa_req_rec.effective_date);
   fetch c_noa_id into l_pa_req_rec.first_noa_id, l_pa_req_rec.first_noa_desc;
   close c_noa_id;
--
   hr_utility.set_location('First NOA Id '|| to_char(l_pa_req_rec.first_noa_id), 10);
--
   l_pa_req_rec.first_action_la_code1  := p_cancel_legal_authority;
   l_pa_req_rec.first_action_la_code2  := null;
   l_pa_req_rec.first_action_la_desc1  := null;
   l_pa_req_rec.first_action_la_desc2  := null;
   v_old_pa_request_id                 := l_pa_req_rec.pa_request_id;
   l_pa_req_rec.pa_request_id          := null;
   l_pa_req_rec.second_noa_id	       := p_noa_id;
   --Begin Bug# 8344672
   l_first_action_la_code1  := null;
   l_first_action_la_code2  := null;
   --end Bug# 8344672

   open c_noa_code(p_noa_id);
   fetch c_noa_code into l_pa_req_rec.second_noa_code;
   close c_noa_code;
--
   l_pa_req_rec.altered_pa_request_id := p_pa_request_id;
   l_pa_req_rec.noa_family_code :=
            ghr_pa_requests_pkg.get_noa_pm_family(l_pa_req_rec.first_noa_id);
--   l_pa_req_rec.notification_id := null;
--
-- Added these checks for bug #2951865
-- Check if additional_info person is present

   OPEN chk_person(l_pa_req_rec.additional_info_person_id );
   FETCH chk_person INTO l_dummy;
    IF chk_person%NOTFOUND THEN
     l_pa_req_rec.additional_info_person_id :=NULL;
     l_pa_req_rec.additional_info_tel_number :=NULL ;
    END IF;
   CLOSE chk_person;

-- Check if Authorizer is present

  OPEN chk_person(l_pa_req_rec.authorized_by_person_id );
   FETCH chk_person INTO l_dummy;
    IF chk_person%NOTFOUND THEN
     l_pa_req_rec.authorized_by_person_id :=NULL;
     l_pa_req_rec.authorized_by_title :=NULL ;
    END IF;
   CLOSE chk_person;

---- Check if Requester is present

  OPEN chk_person(l_pa_req_rec.requested_by_person_id );
   FETCH chk_person INTO l_dummy;
    IF chk_person%NOTFOUND THEN
     l_pa_req_rec.requested_by_person_id :=NULL;
     l_pa_req_rec.requested_by_title :=NULL ;
    END IF;
   CLOSE chk_person;

---END Bug # 2951865

  l_pa_req_rec.custom_pay_calc_flag         := 'N';
--
  hr_utility.set_location('Creating SF52 - p_username '||p_username || '-'|| l_proc, 15);
--
  Ghr_sf52_api.create_sf52(
      p_noa_family_code                      => l_pa_req_rec.noa_family_code
    , p_routing_group_id                     => l_pa_req_rec.routing_group_id
    , p_proposed_effective_asap_flag         => l_pa_req_rec.proposed_effective_asap_flag
    , p_academic_discipline                  => l_pa_req_rec.academic_discipline
    , p_additional_info_person_id            => l_pa_req_rec.additional_info_person_id
    , p_additional_info_tel_number           => l_pa_req_rec.additional_info_tel_number
    , p_altered_pa_request_id                => l_pa_req_rec.altered_pa_request_id
    , p_annuitant_indicator                  => l_pa_req_rec.annuitant_indicator
    , p_annuitant_indicator_desc             => l_pa_req_rec.annuitant_indicator_desc
    , p_appropriation_code1                  => l_pa_req_rec.appropriation_code1
    , p_appropriation_code2                  => l_pa_req_rec.appropriation_code2
    , p_authorized_by_person_id              => l_pa_req_rec.authorized_by_person_id
    , p_authorized_by_title                  => l_pa_req_rec.authorized_by_title
    , p_award_amount                         => l_pa_req_rec.award_amount
    , p_award_uom                            => l_pa_req_rec.award_uom
    , p_bargaining_unit_status               => l_pa_req_rec.bargaining_unit_status
    , p_citizenship                          => l_pa_req_rec.citizenship
    , p_concurrence_date                     => l_pa_req_rec.concurrence_date
    , p_custom_pay_calc_flag                 => l_pa_req_rec.custom_pay_calc_flag
    , p_duty_station_code                    => l_pa_req_rec.duty_station_code
    , p_duty_station_desc                    => l_pa_req_rec.duty_station_desc
    , p_duty_station_id                      => l_pa_req_rec.duty_station_id
    , p_duty_station_location_id             => l_pa_req_rec.duty_station_location_id
    , p_education_level                      => l_pa_req_rec.education_level
    , p_effective_date                       => l_pa_req_rec.effective_date
    , p_employee_assignment_id               => l_pa_req_rec.employee_assignment_id
    , p_employee_date_of_birth               => l_pa_req_rec.employee_date_of_birth
    , p_employee_first_name                  => l_pa_req_rec.employee_first_name
    , p_employee_last_name                   => l_pa_req_rec.employee_last_name
    , p_employee_middle_names                => l_pa_req_rec.employee_middle_names
    , p_employee_national_identifier         => l_pa_req_rec.employee_national_identifier
    , p_fegli                                => l_pa_req_rec.fegli
    , p_fegli_desc                           => l_pa_req_rec.fegli_desc
    , p_first_action_la_code1                => l_pa_req_rec.first_action_la_code1
    , p_first_action_la_code2                => l_pa_req_rec.first_action_la_code2
    , p_first_action_la_desc1                => l_pa_req_rec.first_action_la_desc1
    , p_first_action_la_desc2                => l_pa_req_rec.first_action_la_desc2
--    , p_first_noa_cancel_or_correct          => l_pa_req_rec.first_noa_cancel_or_correct
    , p_first_noa_code                       => l_pa_req_rec.first_noa_code
    , p_first_noa_desc                       => l_pa_req_rec.first_noa_desc
    , p_first_noa_id                         => l_pa_req_rec.first_noa_id
--    , p_first_noa_pa_request_id              => l_pa_req_rec.first_noa_pa_request_id
    , p_flsa_category                        => l_pa_req_rec.flsa_category
    , p_forwarding_address_line1             => l_pa_req_rec.forwarding_address_line1
    , p_forwarding_address_line2             => l_pa_req_rec.forwarding_address_line2
    , p_forwarding_address_line3             => l_pa_req_rec.forwarding_address_line3
    , p_forwarding_country                   => l_pa_req_rec.forwarding_country
    , p_forwarding_country_short_nam         => l_pa_req_rec.forwarding_country_short_name
    , p_forwarding_postal_code               => l_pa_req_rec.forwarding_postal_code
    , p_forwarding_region_2                  => l_pa_req_rec.forwarding_region_2
    , p_forwarding_town_or_city              => l_pa_req_rec.forwarding_town_or_city
    , p_from_adj_basic_pay                   => l_pa_req_rec.from_adj_basic_pay
    , p_from_basic_pay                       => l_pa_req_rec.from_basic_pay
    , p_from_grade_or_level                  => l_pa_req_rec.from_grade_or_level
    , p_from_locality_adj                    => l_pa_req_rec.from_locality_adj
    , p_from_occ_code                        => l_pa_req_rec.from_occ_code
    , p_from_other_pay_amount                => l_pa_req_rec.from_other_pay_amount
    , p_from_pay_basis                       => l_pa_req_rec.from_pay_basis
    , p_from_pay_plan                        => l_pa_req_rec.from_pay_plan
    -- FWFA Changes Bug#4444609
    , p_input_pay_rate_determinant            => l_pa_req_rec.input_pay_rate_determinant
    , p_from_pay_table_identifier            => l_pa_req_rec.from_pay_table_identifier
    -- FWFA Changes
    , p_from_position_id                     => l_pa_req_rec.from_position_id
    , p_from_position_org_line1              => l_pa_req_rec.from_position_org_line1
    , p_from_position_org_line2              => l_pa_req_rec.from_position_org_line2
    , p_from_position_org_line3              => l_pa_req_rec.from_position_org_line3
    , p_from_position_org_line4              => l_pa_req_rec.from_position_org_line4
    , p_from_position_org_line5              => l_pa_req_rec.from_position_org_line5
    , p_from_position_org_line6              => l_pa_req_rec.from_position_org_line6
    , p_from_position_number                 => l_pa_req_rec.from_position_number
    , p_from_position_seq_no                 => l_pa_req_rec.from_position_seq_no
    , p_from_position_title                  => l_pa_req_rec.from_position_title
    , p_from_step_or_rate                    => l_pa_req_rec.from_step_or_rate
    , p_from_total_salary                    => l_pa_req_rec.from_total_salary
    , p_functional_class                     => l_pa_req_rec.functional_class
    , p_notepad                              => l_pa_req_rec.notepad
    , p_part_time_hours                      => l_pa_req_rec.part_time_hours
    , p_pay_rate_determinant                 => l_pa_req_rec.pay_rate_determinant
    , p_person_id                            => l_pa_req_rec.person_id
    , p_position_occupied                    => l_pa_req_rec.position_occupied
    , p_proposed_effective_date              => l_pa_req_rec.proposed_effective_date
    , p_requested_by_person_id               => l_pa_req_rec.requested_by_person_id
    , p_requested_by_title                   => l_pa_req_rec.requested_by_title
    , p_requested_date                       => l_pa_req_rec.requested_date
    , p_requesting_office_remarks_de         => l_pa_req_rec.requesting_office_remarks_desc
    , p_requesting_office_remarks_fl         => l_pa_req_rec.requesting_office_remarks_flag
    , p_request_number                       => l_pa_req_rec.request_number
    , p_resign_and_retire_reason_des         => l_pa_req_rec.resign_and_retire_reason_desc
    , p_retirement_plan                      => l_pa_req_rec.retirement_plan
    , p_retirement_plan_desc                 => l_pa_req_rec.retirement_plan_desc
    , p_second_action_la_code1               => l_pa_req_rec.second_action_la_code1
    , p_second_action_la_code2               => l_pa_req_rec.second_action_la_code2
    , p_second_action_la_desc1               => l_pa_req_rec.second_action_la_desc1
    , p_second_action_la_desc2               => l_pa_req_rec.second_action_la_desc2
--    , p_second_noa_cancel_or_correct         => l_pa_req_rec.second_noa_cancel_or_correct
    , p_second_noa_code                      => l_pa_req_rec.second_noa_code
    , p_second_noa_desc                      => l_pa_req_rec.second_noa_desc
    , p_second_noa_id                        => l_pa_req_rec.second_noa_id
--    , p_second_noa_pa_request_id             => l_pa_req_rec.second_noa_pa_request_id
    , p_service_comp_date                    => l_pa_req_rec.service_comp_date
    , p_supervisory_status                   => l_pa_req_rec.supervisory_status
    , p_tenure                               => l_pa_req_rec.tenure
    , p_to_adj_basic_pay                     => l_pa_req_rec.to_adj_basic_pay
    , p_to_basic_pay                         => l_pa_req_rec.to_basic_pay
    , p_to_grade_id                          => l_pa_req_rec.to_grade_id
    , p_to_grade_or_level                    => l_pa_req_rec.to_grade_or_level
    , p_to_job_id                            => l_pa_req_rec.to_job_id
    , p_to_locality_adj                      => l_pa_req_rec.to_locality_adj
    , p_to_occ_code                          => l_pa_req_rec.to_occ_code
    , p_to_organization_id                   => l_pa_req_rec.to_organization_id
    , p_to_other_pay_amount                  => l_pa_req_rec.to_other_pay_amount
    , p_to_au_overtime                       => l_pa_req_rec.to_au_overtime
    , p_to_auo_premium_pay_indicator         => l_pa_req_rec.to_auo_premium_pay_indicator
    , p_to_availability_pay                  => l_pa_req_rec.to_availability_pay
    , p_to_ap_premium_pay_indicator          => l_pa_req_rec.to_ap_premium_pay_indicator
    , p_to_retention_allowance               => l_pa_req_rec.to_retention_allowance
    , p_to_supervisory_differential          => l_pa_req_rec.to_supervisory_differential
    , p_to_staffing_differential             => l_pa_req_rec.to_staffing_differential
    , p_to_pay_basis                         => l_pa_req_rec.to_pay_basis
    , p_to_pay_plan                          => l_pa_req_rec.to_pay_plan
     -- FWFA Changes Bug#4444609
    , p_to_pay_table_identifier            => l_pa_req_rec.to_pay_table_identifier
    -- FWFA Changes
    , p_to_position_id                       => l_pa_req_rec.to_position_id
    , p_to_position_org_line1                => l_pa_req_rec.to_position_org_line1
    , p_to_position_org_line2                => l_pa_req_rec.to_position_org_line2
    , p_to_position_org_line3                => l_pa_req_rec.to_position_org_line3
    , p_to_position_org_line4                => l_pa_req_rec.to_position_org_line4
    , p_to_position_org_line5                => l_pa_req_rec.to_position_org_line5
    , p_to_position_org_line6                => l_pa_req_rec.to_position_org_line6
    , p_to_position_number                   => l_pa_req_rec.to_position_number
    , p_to_position_seq_no                   => l_pa_req_rec.to_position_seq_no
    , p_to_position_title                    => l_pa_req_rec.to_position_title
    , p_to_step_or_rate                      => l_pa_req_rec.to_step_or_rate
    , p_to_total_salary                      => l_pa_req_rec.to_total_salary
    , p_veterans_preference                  => l_pa_req_rec.veterans_preference
    , p_veterans_pref_for_rif                => l_pa_req_rec.veterans_pref_for_rif
    , p_veterans_status                      => l_pa_req_rec.veterans_status
    , p_work_schedule                        => l_pa_req_rec.work_schedule
    , p_work_schedule_desc                   => l_pa_req_rec.work_schedule_desc
    , p_year_degree_attained                 => l_pa_req_rec.year_degree_attained
    , p_first_noa_information1               => l_pa_req_rec.first_noa_information1
    , p_first_noa_information2               => l_pa_req_rec.first_noa_information2
    , p_first_noa_information3               => l_pa_req_rec.first_noa_information3
    , p_first_noa_information4               => l_pa_req_rec.first_noa_information4
    , p_first_noa_information5               => l_pa_req_rec.first_noa_information5
    , p_second_lac1_information1             => l_pa_req_rec.second_lac1_information1
    , p_second_lac1_information2             => l_pa_req_rec.second_lac1_information2
    , p_second_lac1_information3             => l_pa_req_rec.second_lac1_information3
    , p_second_lac1_information4             => l_pa_req_rec.second_lac1_information4
    , p_second_lac1_information5             => l_pa_req_rec.second_lac1_information5
    , p_second_lac2_information1             => l_pa_req_rec.second_lac2_information1
    , p_second_lac2_information2             => l_pa_req_rec.second_lac2_information2
    , p_second_lac2_information3             => l_pa_req_rec.second_lac2_information3
    , p_second_lac2_information4             => l_pa_req_rec.second_lac2_information4
    , p_second_lac2_information5             => l_pa_req_rec.second_lac2_information5
    , p_second_noa_information1              => l_pa_req_rec.second_noa_information1
    , p_second_noa_information2              => l_pa_req_rec.second_noa_information2
    , p_second_noa_information3              => l_pa_req_rec.second_noa_information3
    , p_second_noa_information4              => l_pa_req_rec.second_noa_information4
    , p_second_noa_information5              => l_pa_req_rec.second_noa_information5
    , p_first_lac1_information1              => l_pa_req_rec.first_lac1_information1
    , p_first_lac1_information2              => l_pa_req_rec.first_lac1_information2
    , p_first_lac1_information3              => l_pa_req_rec.first_lac1_information3
    , p_first_lac1_information4              => l_pa_req_rec.first_lac1_information4
    , p_first_lac1_information5              => l_pa_req_rec.first_lac1_information5
    , p_first_lac2_information1              => l_pa_req_rec.first_lac2_information1
    , p_first_lac2_information2              => l_pa_req_rec.first_lac2_information2
    , p_first_lac2_information3              => l_pa_req_rec.first_lac2_information3
    , p_first_lac2_information4              => l_pa_req_rec.first_lac2_information4
    , p_first_lac2_information5              => l_pa_req_rec.first_lac2_information5
    , p_attribute_category                   => l_pa_req_rec.attribute_category
    , p_attribute1                           => l_pa_req_rec.attribute1
    , p_attribute2                           => l_pa_req_rec.attribute2
    , p_attribute3                           => l_pa_req_rec.attribute3
    , p_attribute4                           => l_pa_req_rec.attribute4
    , p_attribute5                           => l_pa_req_rec.attribute5
    , p_attribute6                           => l_pa_req_rec.attribute6
    , p_attribute7                           => l_pa_req_rec.attribute7
    , p_attribute8                           => l_pa_req_rec.attribute8
    , p_attribute9                           => l_pa_req_rec.attribute9
    , p_attribute10                          => l_pa_req_rec.attribute10
    , p_attribute11                          => l_pa_req_rec.attribute11
    , p_attribute12                          => l_pa_req_rec.attribute12
    , p_attribute13                          => l_pa_req_rec.attribute13
    , p_attribute14                          => l_pa_req_rec.attribute14
    , p_attribute15                          => l_pa_req_rec.attribute15
    , p_attribute16                          => l_pa_req_rec.attribute16
    , p_attribute17                          => l_pa_req_rec.attribute17
    , p_attribute18                          => l_pa_req_rec.attribute18
    , p_attribute19                          => l_pa_req_rec.attribute19
    , p_attribute20                          => l_pa_req_rec.attribute20
    , p_1_user_name_acted_on                 => p_username
    , p_1_action_taken                       => 'INITIATED'
    , P_2_user_name_routed_to                => p_username
    --Pradeep added for Bug#3650351
    , p_award_percentage                     => l_pa_req_rec.award_percentage
-- out
    , p_pa_request_id                        => l_pa_req_rec.pa_request_id
    , p_par_object_version_number            => l_par_object_version_number
    , p_1_pa_routing_history_id              => l_1_pa_routing_history_id
    , p_1_prh_object_version_number          => l_1_prh_object_version_number
    , p_2_pa_routing_history_id              => l_2_pa_routing_history_id
    , p_2_prh_object_version_number          => l_2_prh_object_version_number
      -- Bug#4486823 RRR Changes
    , p_payment_option                       => l_pa_req_rec.pa_incentive_payment_option
  );
--
  hr_utility.set_location('Created SF52 - OVN '||to_char(l_par_object_version_number)|| '-'|| l_proc, 20);
--
    create_pa_request_extra_info(
          p_new_pa_request_id => l_pa_req_rec.pa_request_id
         ,p_old_pa_request_id => v_old_pa_request_id);
    insert into ghr_pa_request_shadow (
      pa_request_id,
      academic_discipline,
      annuitant_indicator,
      appropriation_code1,
      appropriation_code2,
      bargaining_unit_status,
      citizenship,
      duty_station_id,
      duty_station_location_id,
      education_level,
      fegli,
      flsa_category,
      forwarding_address_line1,
      forwarding_address_line2,
      forwarding_address_line3,
      forwarding_country_short_name,
      forwarding_postal_code,
      forwarding_region_2,
      forwarding_town_or_city,
      functional_class,
      part_time_hours,
      pay_rate_determinant,
      position_occupied,
      retirement_plan,
      service_comp_date,
      supervisory_status,
      tenure,
      to_ap_premium_pay_indicator,
      to_auo_premium_pay_indicator,
      to_occ_code,
      to_position_id,
      to_retention_allowance,
      to_staffing_differential,
      to_step_or_rate,
      to_supervisory_differential,
      veterans_preference,
      veterans_pref_for_rif,
      veterans_status,
      work_schedule,
      year_degree_attained,
	employee_first_name,
	employee_last_name,
	employee_middle_names,
	employee_national_identifier,
	employee_date_of_birth,
	first_action_la_code1, --Begin Bug# 8344672
	first_action_la_code2,
	second_action_la_code1,
	second_action_la_code2) --End Bug# 8344672
    values
    (
      l_pa_req_rec.pa_request_id,
      l_pa_req_rec.academic_discipline,
      l_pa_req_rec.annuitant_indicator,
      l_pa_req_rec.appropriation_code1,
      l_pa_req_rec.appropriation_code2,
      l_pa_req_rec.bargaining_unit_status,
      l_pa_req_rec.citizenship,
      l_pa_req_rec.duty_station_id,
      l_pa_req_rec.duty_station_location_id,
      l_pa_req_rec.education_level,
      l_pa_req_rec.fegli,
      l_pa_req_rec.flsa_category,
      l_pa_req_rec.forwarding_address_line1,
      l_pa_req_rec.forwarding_address_line2,
      l_pa_req_rec.forwarding_address_line3,
      l_pa_req_rec.forwarding_country_short_name,
      l_pa_req_rec.forwarding_postal_code,
      l_pa_req_rec.forwarding_region_2,
      l_pa_req_rec.forwarding_town_or_city,
      l_pa_req_rec.functional_class,
      l_pa_req_rec.part_time_hours,
      l_pa_req_rec.pay_rate_determinant,
      l_pa_req_rec.position_occupied,
      l_pa_req_rec.retirement_plan,
      l_pa_req_rec.service_comp_date,
      l_pa_req_rec.supervisory_status,
      l_pa_req_rec.tenure,
      l_pa_req_rec.to_ap_premium_pay_indicator,
      l_pa_req_rec.to_auo_premium_pay_indicator,
      l_pa_req_rec.to_occ_code,
      l_pa_req_rec.to_position_id,
      l_pa_req_rec.to_retention_allowance,
      l_pa_req_rec.to_staffing_differential,
      l_pa_req_rec.to_step_or_rate,
      l_pa_req_rec.to_supervisory_differential,
      l_pa_req_rec.veterans_preference,
      l_pa_req_rec.veterans_pref_for_rif,
      l_pa_req_rec.veterans_status,
      l_pa_req_rec.work_schedule,
      l_pa_req_rec.year_degree_attained,
	l_pa_req_rec.employee_first_name,
	l_pa_req_rec.employee_last_name,
	l_pa_req_rec.employee_middle_names,
	l_pa_req_rec.employee_national_identifier,
	l_pa_req_rec.employee_date_of_birth,
      l_first_action_la_code1,--Begin Bug# 8344672
      l_first_action_la_code2,
      l_second_action_la_code1,
      l_second_action_la_code2); --end Bug# 8344672
--
  hr_utility.set_location('Created SF52 Shadow ' || l_proc, 22);
--
    if l_pa_req_rec.first_noa_code = '002' then
       l_noa_cancel_or_correct := ghr_history_api.g_correct;
    else
       l_noa_cancel_or_correct := ghr_history_api.g_cancel;
    end if;
  hr_utility.set_location('Created SF52 - Pa REQUEST ID '||to_char(l_pa_req_rec.pa_request_id)|| '-'|| l_proc, 22);
  hr_utility.set_location('Updating SF52 - OVN '||to_char(p_par_object_version_number)|| '-'|| l_proc, 25);
  hr_utility.set_location(l_proc || 'Which NOA and Action ' || to_char(p_which_noa) || ' '|| p_which_action, 35);
    if p_which_noa = 1 then
      IF p_which_action = 'ORIGINAL' THEN
           ghr_par_upd.upd(
              P_PA_REQUEST_ID                     => p_pa_request_id
            , P_OBJECT_VERSION_NUMBER             => p_par_object_version_number
            , p_first_noa_canc_pa_request_id      => l_pa_req_rec.pa_request_id
           );
      ELSE
           ghr_par_upd.upd(
              P_PA_REQUEST_ID                => p_pa_request_id
            , P_OBJECT_VERSION_NUMBER        => p_par_object_version_number
            , p_first_noa_pa_request_id      => l_pa_req_rec.pa_request_id
            , p_first_noa_cancel_or_correct  => l_noa_cancel_or_correct
           );
      END IF;
    else
      IF p_which_action = 'ORIGINAL' THEN
           ghr_par_upd.upd(
              P_PA_REQUEST_ID                     => p_pa_request_id
            , P_OBJECT_VERSION_NUMBER             => p_par_object_version_number
            , p_second_noa_canc_pa_request_i      => l_pa_req_rec.pa_request_id
           );
      ELSE
           ghr_par_upd.upd(
              P_PA_REQUEST_ID                => p_pa_request_id
            , P_OBJECT_VERSION_NUMBER        => p_par_object_version_number
            , p_second_noa_pa_request_id     => l_pa_req_rec.pa_request_id
            , p_second_noa_cancel_or_correct => l_noa_cancel_or_correct
           );
      END IF;
    end if;
  hr_utility.set_location('Updated SF52 - OVN '||to_char(p_par_object_version_number)|| '-'|| l_proc, 45);
--    commit;
    hr_utility.set_location('Exiting  '|| l_proc, 50);
    return l_pa_req_rec.PA_REQUEST_ID;
  EXCEPTION
    WHEN OTHERS THEN
      p_par_object_version_number := l_par_object_version_number1;
  end;
---------------------
-- Correction
---------------------
function ghr_correct_sf52 (
  p_pa_request_id              in     number
, p_par_object_version_number  in     number
, p_noa_id                     in     number
, p_which_noa                  in     number
, p_row_id                     in     varchar
, p_username                   in     varchar)
return number -- PA Request ID
is
--
   l_proc                         varchar2(61) := g_package_name || 'GHR_CORRECT_SF52';
   l_pa_req_rec                   ghr_pa_requests%rowtype;
   l_noa_cancel_or_correct        varchar2(10);
   l_1_pa_routing_history_id      number;
   l_1_prh_object_version_number  number;
   l_2_pa_routing_history_id      number;
   l_2_prh_object_version_number  number;
   l_U_PRH_OBJECT_VERSION_NUMBER  number;
   l_I_PA_ROUTING_HISTORY_ID      number;
   l_I_PRH_OBJECT_VERSION_NUMBER  number;
   l_par_object_version_number    number;
   l_retro_pa_request_id           ghr_pa_requests.pa_request_id%type;
   --Begin Bug# 8344672
   l_first_action_la_code1         ghr_pa_request_shadow.first_action_la_code1%type;
   l_first_action_la_code2         ghr_pa_request_shadow.first_action_la_code2%type;
   l_second_action_la_code1         ghr_pa_request_shadow.second_action_la_code1%type;
   l_second_action_la_code2         ghr_pa_request_shadow.second_action_la_code2%type;

    cursor c_lac_shadow is
   select first_action_la_code1,first_action_la_code2,second_action_la_code1,second_action_la_code2
   from ghr_pa_request_shadow
   where pa_request_id = l_pa_req_rec.pa_request_id;
   --End Bug# 8344672
--   l_U_PRH_OBJECT_VERSION_NUMBER  number;
--
   cursor c_pa_req(p_pa_request_id NUMBER) is
   select *
   from ghr_pa_requests
   where pa_request_id = p_pa_request_id;

cursor c_retro_pa_req is
   select * from ghr_pa_requests
   where pa_request_id = l_retro_pa_request_id;


-- Cursor for Bug 3381960
-- Need to find the RPA previous to the cancellation action
l_prev_retro_pa_rec ghr_pa_requests%rowtype;
--Bug#4116407 Modified the cursor. Added second_noa_cancel_or_correct CONDITION.
	CURSOR c_pa_before_retro(c_retro_eff_date IN ghr_pa_requests.effective_date%type,
						 c_person_id ghr_pa_requests.person_id%type) IS
	SELECT *
		FROM ghr_pa_requests
		WHERE person_id = c_person_id
		AND pa_notification_id IS NOT NULL
		AND effective_date < c_retro_eff_date
		AND first_noa_code <> '001'
		AND NVL(first_noa_cancel_or_correct,'C') <> 'CANCEL'
		AND NVL(second_noa_cancel_or_correct,'C') <> 'CANCEL'
		ORDER BY pa_request_id desc;

   cursor c_pa_req1(p_par_id number ) is
   select pa_notification_id,noa_family_code,
          second_noa_code
    from ghr_pa_requests
   where pa_request_id = p_par_id;
--
   cursor C_noa_id(p_noa_code varchar2, p_effective_date date) is
   select nature_of_action_id, description
   from ghr_nature_of_actions
   where code = p_noa_code
   and   p_effective_date between date_from and nvl(date_to, p_effective_date);
--
   cursor c_noa_code (p_noa_id number)is
   select code
   from ghr_nature_of_actions where nature_of_action_id = p_noa_id;
--
   -- Bug#3941541 Added parameter p_effective_date.
   cursor c_noa_fam_code(p_noa_code varchar2,p_effective_date date)  is
     select noa_family_code  from ghr_noa_families
     where nature_of_action_id in
     ( select nature_of_action_id from ghr_nature_of_actions
       where code = p_noa_code )
     and noa_family_code in
     ( select noa_family_code from ghr_families
        where update_hr_flag = 'Y')
     and p_effective_date between NVL(start_date_active,p_effective_date)
                              and NVL(end_date_active,p_effective_date);

--


--
   l_first_pa_request_rec              ghr_pa_requests%ROWTYPE;
   l_last_pa_request_rec               ghr_pa_requests%ROWTYPE;
   l_corrections                       NUMBER;
   l_which_noa                         NUMBER;
   l_dummy_number                      NUMBER;
   l_dummy_varchar                     VARCHAR2(10);
   l_noa_id_correct                    NUMBER;
   l_altered_pa_request_id                NUMBER;
   l_effective_date                    ghr_pa_requests.effective_date%type;
   l_to_step_or_rate		       ghr_pa_requests.to_step_or_rate%type;
   l_pa_notification_id                ghr_pa_requests.pa_notification_id%type;
   l_noa_family_code                   ghr_pa_requests.noa_family_code%type;
   l_retro_noa_family_code                   ghr_pa_requests.noa_family_code%type;
   l_retro_first_noa                   ghr_nature_of_actions.code%type;
   l_retro_second_noa                   ghr_nature_of_actions.code%type;
   l_ia_flag                varchar2(30);
  --bug 5172710
   l_to_total_salary                   ghr_pa_requests.to_total_salary%type;
-- Bug 2681842 and 3191676 Added variables for To Position Org lines
l_to_position_org_line1 ghr_pa_requests.to_position_org_line1%type;
l_to_position_org_line2 ghr_pa_requests.to_position_org_line1%type;
l_to_position_org_line3 ghr_pa_requests.to_position_org_line1%type;
l_to_position_org_line4 ghr_pa_requests.to_position_org_line1%type;
l_to_position_org_line5 ghr_pa_requests.to_position_org_line1%type;
l_to_position_org_line6 ghr_pa_requests.to_position_org_line1%type;

CURSOR c_get_pos_org_lines(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
   SELECT to_position_org_line1,
	to_position_org_line2,
	to_position_org_line3,
	to_position_org_line4,
	to_position_org_line5,
	to_position_org_line6
  FROM ghr_pa_requests
  WHERE pa_request_id = c_pa_request_id;
-- End Bug 2681842 and 3191676

begin
--
   hr_utility.set_location('Entering  '|| l_proc, 5);

   find_last_request(p_pa_request_id              => p_pa_request_id
                   , p_which_noa                  => p_which_noa
                   , p_row_id                     => p_row_id
                   , p_first_pa_request_rec       => l_first_pa_request_rec
                   , p_last_pa_request_rec        => l_last_pa_request_rec
                   , p_number_of_requests         => l_corrections);
   hr_utility.set_location(l_proc || 'Last PA Request ID ' || to_char(l_last_pa_request_rec.pa_request_id), 15);
   IF l_last_pa_request_rec.pa_notification_id IS NULL THEN
      l_corrections := -1;
      fnd_message.set_name('GHR', 'GHR_CANCEL_INVALID');
      fnd_message.raise_error;
   END IF;

--
-- Get PA Request
/*
   open c_pa_req;
   fetch c_pa_req into l_pa_req_rec;
   close c_pa_req;
*/
   l_pa_req_rec := l_last_pa_request_rec;
   l_which_noa  := p_which_noa;
   if l_which_noa = 1 and l_pa_req_rec.first_noa_code = '002' then
      l_which_noa := 2;
   end if;
   --Begin Bug# 8344672
   for l_lac_shadow in c_lac_shadow loop
	l_first_action_la_code1  := l_lac_shadow.first_action_la_code1;
	l_first_action_la_code2  := l_lac_shadow.first_action_la_code2;
	l_second_action_la_code1 := l_lac_shadow.second_action_la_code1;
	l_second_action_la_code2 := l_lac_shadow.second_action_la_code2;
   end loop;
   --End Bug# 8344672
-- -------------------------------------------
-- Populate Second Noa Detail
-- -------------------------------------------
   if l_which_noa = 1 then
       l_pa_req_rec.second_action_la_code1  := l_pa_req_rec.first_action_la_code1;
       l_pa_req_rec.second_action_la_code2  := l_pa_req_rec.first_action_la_code2;
       l_pa_req_rec.second_action_la_desc1  := l_pa_req_rec.first_action_la_desc1;
       l_pa_req_rec.second_action_la_desc2  := l_pa_req_rec.first_action_la_desc2;
       l_pa_req_rec.second_noa_code         := l_pa_req_rec.first_noa_code;
       l_pa_req_rec.second_noa_desc         := l_pa_req_rec.first_noa_desc;
       l_pa_req_rec.second_noa_id           := l_pa_req_rec.first_noa_id;
       -- Bug#5036997 Added the information columns
       l_pa_req_rec.second_lac1_information1 := l_pa_req_rec.first_lac1_information1;
       l_pa_req_rec.second_lac1_information2 := l_pa_req_rec.first_lac1_information2;
       l_pa_req_rec.second_lac1_information3 := l_pa_req_rec.first_lac1_information3; ----Bug 8792086
       l_pa_req_rec.second_lac2_information1 := l_pa_req_rec.first_lac2_information1;
       l_pa_req_rec.second_lac2_information2 := l_pa_req_rec.first_lac2_information2;
       l_pa_req_rec.second_lac2_information3 := l_pa_req_rec.first_lac2_information3; ----Bug 8792086
	--Begin Bug# 8344672
	l_second_action_la_code1 := l_first_action_la_code1;
	l_second_action_la_code2 := l_first_action_la_code2;
	--End Bug# 8344672
   end if;
-- -------------------------------------------
-- Populate Second Noa Detail
-- -------------------------------------------
--   l_pa_req_rec.second_noa_code := l_pa_req_rec.first_noa_code;
--   l_pa_req_rec.second_noa_id  := p_noa_id;
-- -------------------------------------------
-- Populate First Noa Detail
-- -------------------------------------------
-- Correction NOA
   l_pa_req_rec.first_noa_code := '002';
-- Get NOA Id
   Open c_noa_id(l_pa_req_rec.first_noa_code, l_pa_req_rec.effective_date);
   fetch c_noa_id into l_pa_req_rec.first_noa_id, l_pa_req_rec.first_noa_desc;
   close c_noa_id;
   l_pa_req_rec.first_action_la_code1  := null;
   l_pa_req_rec.first_action_la_code2  := null;
   l_pa_req_rec.first_action_la_desc1  := null;
   l_pa_req_rec.first_action_la_desc2  := null;
   --Begin Bug# 8344672
   l_first_action_la_code1  := null;
   l_first_action_la_code2  := null;
   --end Bug# 8344672

--
   l_pa_req_rec.altered_pa_request_id := l_pa_req_rec.pa_request_id;
   l_pa_req_rec.pa_request_id          := null;
   l_pa_req_rec.noa_family_code :=
            ghr_pa_requests_pkg.get_noa_pm_family(l_pa_req_rec.first_noa_id);
-- --------
-- Pay Calc
-- --------
--  l_pa_req_rec.custom_pay_calc_flag         := 'Y';
--
    l_effective_date := NULL;
--
-- Determine Intervening Actions
--
--  First determine presence of retro active actions
     l_ia_flag := 'N';
--  Get the pa_notification_id from the original action
    FOR c_pa_rec1 IN c_pa_req1(p_pa_request_id)  LOOP
      l_pa_notification_id := c_pa_rec1.pa_notification_id;
      l_noa_family_code := c_pa_rec1.noa_family_code;
     END LOOP;
     -- Bug#3941541
      IF l_pa_req_rec.second_noa_code = '825'  THEN
          l_noa_family_code := 'GHR_INCENTIVE';
      END IF;
    hr_utility.set_location('noa family code is' || l_noa_family_code ,20);
  IF nvl(l_noa_family_code,hr_api.g_varchar2) not in
     ('APP','APPT_TRANS','APPT_INFO') THEN
    hr_utility.set_location('notification id is' || l_pa_req_rec.pa_notification_id,22 );
    --BUG # 7216635 Added the parameter p_noa_id_correct
     GHR_APPROVED_PA_REQUESTS.determine_ia(
                             p_pa_request_id => p_pa_request_id,
                             p_pa_notification_id => l_pa_notification_id,
                             p_person_id      => l_pa_req_rec.person_id,
                             p_effective_date => l_pa_req_rec.effective_date,
			     p_noa_id_correct => p_noa_id,
                             p_retro_pa_request_id => l_retro_pa_request_id,
                             p_retro_eff_date => l_effective_date,
                             p_retro_first_noa => l_retro_first_noa,
                             p_retro_second_noa => l_retro_second_noa);

    IF l_effective_date is NOT NULL THEN
      l_ia_flag := 'Y';
      hr_utility.set_location('Intervening Action '||l_effective_date,10);
      IF l_retro_first_noa = '866' then
        l_effective_date := l_effective_date + 1;
      END IF;
    END IF;

    IF l_ia_flag = 'Y' THEN
    FOR c_pa_rec1 IN c_pa_req1(l_retro_pa_request_id)  LOOP
      l_retro_noa_family_code := c_pa_rec1.noa_family_code;
      IF l_retro_noa_family_code = 'CORRECT' THEN
        FOR c_noa_fam IN c_noa_fam_code(l_retro_second_noa,l_effective_date)
        LOOP
          l_retro_noa_family_code := c_noa_fam.noa_family_code;
        END LOOP;
      END IF;
    END LOOP;
    hr_utility.set_location('IA Action ',11);
	-- Bug 3381960
	-- If the retro action is cancellation action, then consider the RPA
	-- previous to this Cancellation RPA and use that for populating
	-- from side of this correction action.

    IF NVL(l_retro_first_noa,hr_api.g_varchar2) = '001' THEN
		-- Get the To side of the RPA previous to this cancellation action
		-- Need to modify the cursor. Need to add Order of processing too
		hr_utility.set_location('Cancellation RPA',11);
		FOR l_pa_before_retro IN c_pa_before_retro(l_effective_date,l_pa_req_rec.person_id) LOOP
			l_prev_retro_pa_rec := l_pa_before_retro;
			EXIT;
		END LOOP;
	  --Bug #9006561  Added NVL if the intervening action is cancellation to consider From Value in case of NULL
	  l_pa_req_rec.from_position_id := NVL(l_prev_retro_pa_rec.to_position_id,l_prev_retro_pa_rec.from_position_id);
          l_pa_req_rec.from_position_title := NVL(l_prev_retro_pa_rec.to_position_title,l_prev_retro_pa_rec.from_position_title);
          l_pa_req_rec.from_position_number := NVL(l_prev_retro_pa_rec.to_position_number, l_prev_retro_pa_rec.from_position_number);
          l_pa_req_rec.from_position_seq_no := NVL(l_prev_retro_pa_rec.to_position_seq_no,l_prev_retro_pa_rec.from_position_seq_no);
          l_pa_req_rec.from_pay_plan := NVL(l_prev_retro_pa_rec.to_pay_plan,l_prev_retro_pa_rec.from_pay_plan);
          l_pa_req_rec.from_occ_code := NVL(l_prev_retro_pa_rec.to_occ_code,l_prev_retro_pa_rec.from_occ_code);
          l_pa_req_rec.from_grade_or_level := NVL(l_prev_retro_pa_rec.to_grade_or_level,l_prev_retro_pa_rec.from_grade_or_level);
          l_pa_req_rec.from_step_or_rate := NVL(l_prev_retro_pa_rec.to_step_or_rate,l_prev_retro_pa_rec.from_step_or_rate);
	  if  l_prev_retro_pa_rec.noa_family_code in ('GHR_INCENTIVE') then
              l_pa_req_rec.from_total_salary := l_prev_retro_pa_rec.from_total_salary;
	  else
	      l_pa_req_rec.from_total_salary := NVL(l_prev_retro_pa_rec.to_total_salary,l_prev_retro_pa_rec.from_total_salary);
	  end if;
          l_pa_req_rec.from_pay_basis := NVL(l_prev_retro_pa_rec.to_pay_basis,l_prev_retro_pa_rec.from_pay_basis);
          -- FWFA Changes Bug#4444609
          l_pa_req_rec.input_pay_rate_determinant := l_prev_retro_pa_rec.pay_rate_determinant;
          l_pa_req_rec.from_pay_table_identifier := NVL(l_prev_retro_pa_rec.to_pay_table_identifier,l_prev_retro_pa_rec.from_pay_table_identifier);
          -- FWFA Changes
          l_pa_req_rec.from_basic_pay := NVL(l_prev_retro_pa_rec.to_basic_pay,l_prev_retro_pa_rec.from_basic_pay);
          l_pa_req_rec.from_locality_adj := NVL(l_prev_retro_pa_rec.to_locality_adj,l_prev_retro_pa_rec.from_locality_adj);
          l_pa_req_rec.from_adj_basic_pay := NVL(l_prev_retro_pa_rec.to_adj_basic_pay,l_prev_retro_pa_rec.from_adj_basic_pay);
          l_pa_req_rec.from_other_pay_amount := NVL(l_prev_retro_pa_rec.to_other_pay_amount,l_prev_retro_pa_rec.from_other_pay_amount);
          l_pa_req_rec.from_position_org_line1 := NVL(l_prev_retro_pa_rec.to_position_org_line1,l_prev_retro_pa_rec.from_position_org_line1);
          l_pa_req_rec.from_position_org_line2 := NVL(l_prev_retro_pa_rec.to_position_org_line2,l_prev_retro_pa_rec.from_position_org_line2);
          l_pa_req_rec.from_position_org_line3 := NVL(l_prev_retro_pa_rec.to_position_org_line3,l_prev_retro_pa_rec.from_position_org_line3);
          l_pa_req_rec.from_position_org_line4 := NVL(l_prev_retro_pa_rec.to_position_org_line4,l_prev_retro_pa_rec.from_position_org_line4);
          l_pa_req_rec.from_position_org_line5 := NVL(l_prev_retro_pa_rec.to_position_org_line5,l_prev_retro_pa_rec.from_position_org_line5);
          l_pa_req_rec.from_position_org_line6 := NVL(l_prev_retro_pa_rec.to_position_org_line6,l_prev_retro_pa_rec.from_position_org_line6);
  	  --End of Bug #9006561  Added NVL if the intervening action is cancellation to consider From Value in case of NULL
	ELSIF
            l_retro_noa_family_code in
                     ( 'NON_PAY_DUTY_STATUS',
                      'SEPARATION',
                      'AWARD',
                      'GHR_INCENTIVE'
                      )
        THEN
        hr_utility.set_location('From Side data only MRPA',11);
        for c_ret_rec in c_retro_pa_req  loop
          l_pa_req_rec.from_position_id := c_ret_rec.from_position_id;
          l_pa_req_rec.from_position_title := c_ret_rec.from_position_title;
          l_pa_req_rec.from_position_number := c_ret_rec.from_position_number;
          l_pa_req_rec.from_position_seq_no := c_ret_rec.from_position_seq_no;
          l_pa_req_rec.from_pay_plan := c_ret_rec.from_pay_plan;
          l_pa_req_rec.from_occ_code := c_ret_rec.from_occ_code;
          l_pa_req_rec.from_grade_or_level := c_ret_rec.from_grade_or_level;
          l_pa_req_rec.from_step_or_rate := c_ret_rec.from_step_or_rate;
          l_pa_req_rec.from_total_salary := c_ret_rec.from_total_salary;
          l_pa_req_rec.from_pay_basis := c_ret_rec.from_pay_basis;
          -- FWFA Changes Bug#4444609
          -- Bug# 4696860
          l_pa_req_rec.input_pay_rate_determinant := c_ret_rec.input_pay_rate_determinant;
          l_pa_req_rec.from_pay_table_identifier := c_ret_rec.from_pay_table_identifier;
          -- FWFA Changes
          l_pa_req_rec.from_basic_pay := c_ret_rec.from_basic_pay;
          l_pa_req_rec.from_locality_adj := c_ret_rec.from_locality_adj;
          l_pa_req_rec.from_adj_basic_pay := c_ret_rec.from_adj_basic_pay;
          l_pa_req_rec.from_other_pay_amount := c_ret_rec.from_other_pay_amount;
          l_pa_req_rec.from_position_org_line1 := c_ret_rec.from_position_org_line1;
          l_pa_req_rec.from_position_org_line2 := c_ret_rec.from_position_org_line2;
          l_pa_req_rec.from_position_org_line3 := c_ret_rec.from_position_org_line3;
          l_pa_req_rec.from_position_org_line4 := c_ret_rec.from_position_org_line4;
          l_pa_req_rec.from_position_org_line5 := c_ret_rec.from_position_org_line5;
          l_pa_req_rec.from_position_org_line6 := c_ret_rec.from_position_org_line6;
          exit;
        end loop;
      ELSE
        hr_utility.set_location('Non Cancel MRPA: ',11);
        for c_ret_rec in c_retro_pa_req  loop
          l_pa_req_rec.from_position_id := c_ret_rec.to_position_id;
          l_pa_req_rec.from_position_title := c_ret_rec.to_position_title;
          l_pa_req_rec.from_position_number := c_ret_rec.to_position_number;
          l_pa_req_rec.from_position_seq_no := c_ret_rec.to_position_seq_no;
          l_pa_req_rec.from_pay_plan := c_ret_rec.to_pay_plan;
          l_pa_req_rec.from_occ_code := c_ret_rec.to_occ_code;
          l_pa_req_rec.from_grade_or_level := c_ret_rec.to_grade_or_level;
          l_pa_req_rec.from_step_or_rate := c_ret_rec.to_step_or_rate;
          l_pa_req_rec.from_total_salary := c_ret_rec.to_total_salary;
          l_pa_req_rec.from_pay_basis := c_ret_rec.to_pay_basis;
          -- FWFA Changes Bug#4444609
          l_pa_req_rec.input_pay_rate_determinant := c_ret_rec.pay_rate_determinant;
          l_pa_req_rec.from_pay_table_identifier := c_ret_rec.to_pay_table_identifier;
          -- FWFA Changes
          l_pa_req_rec.from_basic_pay := c_ret_rec.to_basic_pay;
          l_pa_req_rec.from_locality_adj := c_ret_rec.to_locality_adj;
          l_pa_req_rec.from_adj_basic_pay := c_ret_rec.to_adj_basic_pay;
          l_pa_req_rec.from_other_pay_amount := c_ret_rec.to_other_pay_amount;
          l_pa_req_rec.from_position_org_line1 := c_ret_rec.to_position_org_line1;
          l_pa_req_rec.from_position_org_line2 := c_ret_rec.to_position_org_line2;
          l_pa_req_rec.from_position_org_line3 := c_ret_rec.to_position_org_line3;
          l_pa_req_rec.from_position_org_line4 := c_ret_rec.to_position_org_line4;
          l_pa_req_rec.from_position_org_line5 := c_ret_rec.to_position_org_line5;
          l_pa_req_rec.from_position_org_line6 := c_ret_rec.to_position_org_line6;
          exit;
        end loop;
      END IF;
    ELSE
      hr_utility.set_location('non IA : '||l_pa_req_rec.pay_rate_determinant,11);
      l_noa_id_correct := hr_api.g_number;
      l_altered_pa_request_id := l_pa_req_rec.altered_pa_request_id;
      GHR_API.sf52_from_data_elements(
      p_person_id         => l_pa_req_rec.person_id
      ,p_assignment_id     => l_pa_req_rec.employee_assignment_id
      ,p_effective_date    => nvl(l_effective_date, l_pa_req_rec.effective_date)
      ,p_altered_pa_request_id => l_altered_pa_request_id
      ,p_noa_id_corrected    => l_noa_id_correct
      ,p_pa_history_id     => l_dummy_number
      ,p_position_id       => l_pa_req_rec.from_position_id
      ,p_position_title    => l_pa_req_rec.from_position_title
      ,p_position_number   => l_pa_req_rec.from_position_number
      ,p_position_seq_no   => l_pa_req_rec.from_position_seq_no
      ,p_pay_plan          => l_pa_req_rec.from_pay_plan
      ,p_job_id            => l_dummy_number
      ,p_occ_code          => l_pa_req_rec.from_occ_code
      ,p_grade_or_level    => l_pa_req_rec.from_grade_or_level
      ,p_grade_id          => l_dummy_number
      ,p_step_or_rate      => l_pa_req_rec.from_step_or_rate
      ,p_total_salary      => l_pa_req_rec.from_total_salary
      ,p_pay_basis         => l_pa_req_rec.from_pay_basis
      -- FWFA Chagnes Bug#4444609
      ,p_pay_table_identifier => l_pa_req_rec.from_pay_table_identifier
      -- FWFA Changes
      ,p_basic_pay         => l_pa_req_rec.from_basic_pay
      ,p_locality_adj      => l_pa_req_rec.from_locality_adj
      ,p_adj_basic_pay     => l_pa_req_rec.from_adj_basic_pay
      ,p_other_pay         => l_pa_req_rec.from_other_pay_amount
      ,p_au_overtime                 =>  l_dummy_number
      ,p_auo_premium_pay_indicator   => l_dummy_varchar
      ,p_availability_pay            => l_dummy_number
      ,p_ap_premium_pay_indicator    => l_dummy_varchar
      ,p_retention_allowance         => l_dummy_number
      ,p_retention_allow_percentage  => l_dummy_number
      ,p_supervisory_differential    => l_dummy_number
      ,p_supervisory_diff_percentage => l_dummy_number
      ,p_staffing_differential       => l_dummy_number
      ,p_staffing_diff_percentage  =>  l_dummy_number
      ,p_organization_id           => l_dummy_number
      ,p_position_org_line1        => l_pa_req_rec.from_position_org_line1
      ,p_position_org_line2        => l_pa_req_rec.from_position_org_line2
      ,p_position_org_line3        => l_pa_req_rec.from_position_org_line3
      ,p_position_org_line4        => l_pa_req_rec.from_position_org_line4
      ,p_position_org_line5        => l_pa_req_rec.from_position_org_line5
      ,p_position_org_line6        => l_pa_req_rec.from_position_org_line6
      ,p_duty_station_location_id  => l_dummy_number
      -- FWFA Changes Bug#4444609
      ,p_pay_rate_determinant      => l_pa_req_rec.input_pay_rate_determinant
      -- FWFA Changes
      ,p_work_schedule             => l_dummy_varchar
      );
    END IF;
  END IF;
--	Bug 2681842 and 3191676. Create SF52 including position org lines for 790 action
	IF (l_pa_req_rec.first_noa_code = '790' OR l_pa_req_rec.second_noa_code = '790') THEN
		FOR l_get_pos_org_lines IN c_get_pos_org_lines(l_pa_req_rec.altered_pa_request_id) LOOP
		   l_to_position_org_line1 := l_get_pos_org_lines.to_position_org_line1;
		   l_to_position_org_line2 := l_get_pos_org_lines.to_position_org_line2;
		   l_to_position_org_line3 := l_get_pos_org_lines.to_position_org_line3;
		   l_to_position_org_line4 := l_get_pos_org_lines.to_position_org_line4;
		   l_to_position_org_line5 := l_get_pos_org_lines.to_position_org_line5;
		   l_to_position_org_line6 := l_get_pos_org_lines.to_position_org_line6;
		END LOOP;
	END IF;
-- Bug 3263056 Add to side details for Correction to 892/893
-- Bug 4116407 Added code 867 in the IF Condition.
  IF l_pa_req_rec.second_noa_code IN ('867','892','893') THEN
          l_to_step_or_rate := l_pa_req_rec.from_step_or_rate;
  END IF;
    --Bug 5172710
  IF l_noa_family_code IN ('GHR_INCENTIVE') THEN
     l_to_total_salary := l_pa_req_rec.to_total_salary;
  END IF;


          Ghr_sf52_api.create_sf52(
        --  p_validate                     p_validate
            p_noa_family_code              => l_pa_req_rec.noa_family_code
          , p_routing_group_id             => l_pa_req_rec.routing_group_id
          , p_proposed_effective_asap_flag => l_pa_req_rec.proposed_effective_asap_flag
        --  , p_citizenship                  => l_pa_req_rec.citizenship
          , p_altered_pa_request_id        => l_pa_req_rec.altered_pa_request_id
          , p_custom_pay_calc_flag         => l_pa_req_rec.custom_pay_calc_flag
          , p_effective_date               => l_pa_req_rec.effective_date
          , p_employee_date_of_birth       => l_pa_req_rec.employee_date_of_birth
          , p_employee_first_name          => l_pa_req_rec.employee_first_name
          , p_employee_last_name           => l_pa_req_rec.employee_last_name
          , p_employee_middle_names        => l_pa_req_rec.employee_middle_names
          , p_employee_national_identifier => l_pa_req_rec.employee_national_identifier
          , p_employee_assignment_id       => l_pa_req_rec.employee_assignment_id
          , p_first_action_la_code1        => l_pa_req_rec.first_action_la_code1
          , p_first_action_la_code2        => l_pa_req_rec.first_action_la_code2
          , p_first_action_la_desc1        => l_pa_req_rec.first_action_la_desc1
          , p_first_action_la_desc2        => l_pa_req_rec.first_action_la_desc2
          , p_first_noa_code               => l_pa_req_rec.first_noa_code
          , p_first_noa_desc               => l_pa_req_rec.first_noa_desc
          , p_first_noa_id                 => l_pa_req_rec.first_noa_id
          , p_person_id                    => l_pa_req_rec.person_id
          , p_proposed_effective_date      => l_pa_req_rec.proposed_effective_date
          , p_second_action_la_code1       => l_pa_req_rec.second_action_la_code1
          , p_second_action_la_code2       => l_pa_req_rec.second_action_la_code2
          , p_second_action_la_desc1       => l_pa_req_rec.second_action_la_desc1
          , p_second_action_la_desc2       => l_pa_req_rec.second_action_la_desc2
          , p_second_noa_code              => l_pa_req_rec.second_noa_code
          , p_second_noa_desc              => l_pa_req_rec.second_noa_desc
          , p_second_noa_id                => l_pa_req_rec.second_noa_id
            ,p_from_position_id       => l_pa_req_rec.from_position_id
            ,p_from_position_title    => l_pa_req_rec.from_position_title
            ,p_from_position_number   => l_pa_req_rec.from_position_number
            ,p_from_position_seq_no   => l_pa_req_rec.from_position_seq_no
            ,p_from_pay_plan          => l_pa_req_rec.from_pay_plan
	    -- FWFA Changes Bug#4444609
        ,p_input_pay_rate_determinant => l_pa_req_rec.input_pay_rate_determinant
	    ,p_from_pay_table_identifier => l_pa_req_rec.from_pay_table_identifier
	    -- FWFA Changes
            ,p_from_occ_code          => l_pa_req_rec.from_occ_code
            ,p_from_step_or_rate      => l_pa_req_rec.from_step_or_rate
            ,p_from_grade_or_level    => l_pa_req_rec.from_grade_or_level
            ,p_from_total_salary      => l_pa_req_rec.from_total_salary
            ,p_from_pay_basis         => l_pa_req_rec.from_pay_basis
            ,p_from_basic_pay         => l_pa_req_rec.from_basic_pay
            ,p_from_locality_adj      => l_pa_req_rec.from_locality_adj
            ,p_from_adj_basic_pay     => l_pa_req_rec.from_adj_basic_pay
            ,p_from_other_pay_amount         => l_pa_req_rec.from_other_pay_amount
            ,p_from_position_org_line1        => l_pa_req_rec.from_position_org_line1
            ,p_from_position_org_line2        => l_pa_req_rec.from_position_org_line2
            ,p_from_position_org_line3        => l_pa_req_rec.from_position_org_line3
            ,p_from_position_org_line4        => l_pa_req_rec.from_position_org_line4
            ,p_from_position_org_line5        => l_pa_req_rec.from_position_org_line5
            ,p_from_position_org_line6        => l_pa_req_rec.from_position_org_line6
            -- Sundar 2681726 and 3191676 these values need to be populated for 790 action
            -- Bug#5036997 Added the information columns
            ,p_second_lac1_information1     => l_pa_req_rec.second_lac1_information1
            ,p_second_lac1_information2     => l_pa_req_rec.second_lac1_information2
            ,p_second_lac1_information3     => l_pa_req_rec.second_lac1_information3  ----Bug 8792086
            ,p_second_lac2_information1     => l_pa_req_rec.second_lac2_information1
            ,p_second_lac2_information2     => l_pa_req_rec.second_lac2_information2
            ,p_second_lac2_information3     => l_pa_req_rec.second_lac2_information3  ----Bug 8792086
			,p_to_position_org_line1        => l_to_position_org_line1
			,p_to_position_org_line2        => l_to_position_org_line2
			,p_to_position_org_line3        => l_to_position_org_line3
			,p_to_position_org_line4        => l_to_position_org_line4
			,p_to_position_org_line5        => l_to_position_org_line5
			,p_to_position_org_line6        => l_to_position_org_line6
			--Bug 5172710
			 , p_to_total_salary             => l_to_total_salary
			--Bug#3263056 Added to side details for 892,893
                        , p_to_step_or_rate              => l_to_step_or_rate
                          --Bug#3263056
          , p_1_user_name_acted_on         => p_username
          , p_1_action_taken               => 'INITIATED'
          , P_2_user_name_routed_to        => p_username
        -- out
          , p_pa_request_id                  => l_pa_req_rec.pa_request_id
          , p_par_object_version_number      => l_par_object_version_number
          , p_1_pa_routing_history_id        => l_1_pa_routing_history_id
          , p_1_prh_object_version_number    => l_1_prh_object_version_number
          , p_2_pa_routing_history_id        => l_2_pa_routing_history_id
          , p_2_prh_object_version_number    => l_2_prh_object_version_number
          , p_award_uom                      => l_pa_req_rec.award_uom
          -- Bug#4486823 RRR Changes
          , p_payment_option                 => l_pa_req_rec.pa_incentive_payment_option


          );

IF nvl(l_noa_family_code,hr_api.g_varchar2) = 'GHR_INCENTIVE' THEN
 hr_utility.set_location('Inserting incentive records',0);
 INSERT INTO ghr_pa_incentives( pa_incentive_id,
 pa_request_id ,
 pa_incentive_category,
 pa_incentive_category_percent  ,
 pa_incentive_category_amount,
 pa_incentive_category_pmnt_dt  ,
 pa_incentive_category_end_date)
 SELECT
 ghr_pa_incentives_s.nextval,
 l_pa_req_rec.pa_request_id,
 pa_incentive_category,
 pa_incentive_category_percent  ,
 pa_incentive_category_amount,
 pa_incentive_category_pmnt_dt ,
 pa_incentive_category_end_date
 FROM GHR_PA_INCENTIVES
 WHERE pa_request_id =  l_pa_req_rec.altered_pa_request_id;
 hr_utility.set_location('After Inserting incentive records',10);
END IF;
-- Bug#4486823 RRR Changes

  hr_utility.set_location('Created SF52 - Altered PA Request ID  '||to_char(l_pa_req_rec.altered_pa_request_id)|| '-'|| l_proc, 21);
  hr_utility.set_location('Created SF52 - PA request ID '||to_char(l_pa_req_rec.pa_request_id)|| '-'|| l_proc, 22);
    insert into ghr_pa_request_shadow (
      pa_request_id,
      academic_discipline,
      annuitant_indicator,
      appropriation_code1,
      appropriation_code2,
      bargaining_unit_status,
      citizenship,
      duty_station_id,
      duty_station_location_id,
      education_level,
      fegli,
      flsa_category,
      forwarding_address_line1,
      forwarding_address_line2,
      forwarding_address_line3,
      forwarding_country_short_name,
      forwarding_postal_code,
      forwarding_region_2,
      forwarding_town_or_city,
      functional_class,
      part_time_hours,
      pay_rate_determinant,
      position_occupied,
      retirement_plan,
      service_comp_date,
      supervisory_status,
      tenure,
      to_ap_premium_pay_indicator,
      to_auo_premium_pay_indicator,
      to_occ_code,
      to_position_id,
      to_retention_allowance,
      to_staffing_differential,
      to_step_or_rate,
      to_supervisory_differential,
      veterans_preference,
      veterans_pref_for_rif,
      veterans_status,
      work_schedule,
      year_degree_attained,
	employee_first_name,
	employee_last_name,
	employee_middle_names,
	employee_national_identifier,
	employee_date_of_birth,
	first_action_la_code1,  --Begin Bug# 8344672
	first_action_la_code2,
	second_action_la_code1,
	second_action_la_code2)	 --End Bug# 8344672

    values
    (
      l_pa_req_rec.pa_request_id,
      l_pa_req_rec.academic_discipline,
      l_pa_req_rec.annuitant_indicator,
      l_pa_req_rec.appropriation_code1,
      l_pa_req_rec.appropriation_code2,
      l_pa_req_rec.bargaining_unit_status,
      l_pa_req_rec.citizenship,
      l_pa_req_rec.duty_station_id,
      l_pa_req_rec.duty_station_location_id,
      l_pa_req_rec.education_level,
      l_pa_req_rec.fegli,
      l_pa_req_rec.flsa_category,
      l_pa_req_rec.forwarding_address_line1,
      l_pa_req_rec.forwarding_address_line2,
      l_pa_req_rec.forwarding_address_line3,
      l_pa_req_rec.forwarding_country_short_name,
      l_pa_req_rec.forwarding_postal_code,
      l_pa_req_rec.forwarding_region_2,
      l_pa_req_rec.forwarding_town_or_city,
      l_pa_req_rec.functional_class,
      l_pa_req_rec.part_time_hours,
      l_pa_req_rec.pay_rate_determinant,
      l_pa_req_rec.position_occupied,
      l_pa_req_rec.retirement_plan,
      l_pa_req_rec.service_comp_date,
      l_pa_req_rec.supervisory_status,
      l_pa_req_rec.tenure,
      l_pa_req_rec.to_ap_premium_pay_indicator,
      l_pa_req_rec.to_auo_premium_pay_indicator,
      l_pa_req_rec.to_occ_code,
      l_pa_req_rec.to_position_id,
      l_pa_req_rec.to_retention_allowance,
      l_pa_req_rec.to_staffing_differential,
      l_pa_req_rec.to_step_or_rate,
      l_pa_req_rec.to_supervisory_differential,
      l_pa_req_rec.veterans_preference,
      l_pa_req_rec.veterans_pref_for_rif,
      l_pa_req_rec.veterans_status,
      l_pa_req_rec.work_schedule,
      l_pa_req_rec.year_degree_attained,
      l_pa_req_rec.employee_first_name,
      l_pa_req_rec.employee_last_name,
      l_pa_req_rec.employee_middle_names,
      l_pa_req_rec.employee_national_identifier,
      l_pa_req_rec.employee_date_of_birth,
      l_first_action_la_code1,--Begin Bug# 8344672
      l_first_action_la_code2,
      l_second_action_la_code1,
      l_second_action_la_code2);--end Bug# 8344672
--
  hr_utility.set_location('Created SF52 Shadow ' || l_proc, 22);
--
    if l_pa_req_rec.first_noa_code = '002' then
       l_noa_cancel_or_correct := ghr_history_api.g_correct;
    else
       l_noa_cancel_or_correct := ghr_history_api.g_cancel;
    end if;
  hr_utility.set_location('Created SF52 - Pa REQUEST ID '||to_char(l_last_pa_request_rec.pa_request_id)|| '-'|| l_proc, 22);
  hr_utility.set_location(l_proc || ' Last rows object version # ' || to_char(l_last_pa_request_rec.object_version_number), 20);
  hr_utility.set_location('Updating SF52 - OVN '||to_char(l_last_pa_request_rec.object_version_number)|| '-'|| l_proc, 25);
  hr_utility.set_location('Updated SF52 - PA Request ID '||to_char(l_last_pa_request_rec.pa_request_id)|| '-'|| l_proc, 26);
    if l_which_noa = 1 then
      ghr_par_upd.upd(
         P_PA_REQUEST_ID                => l_last_pa_request_rec.pa_request_id
       , P_OBJECT_VERSION_NUMBER        => l_last_pa_request_rec.object_version_number
       , p_first_noa_pa_request_id     => l_last_pa_request_rec.pa_request_id
       , p_first_noa_cancel_or_correct => l_noa_cancel_or_correct
      );
    else
      ghr_par_upd.upd(
         P_PA_REQUEST_ID                => l_last_pa_request_rec.pa_request_id
       , P_OBJECT_VERSION_NUMBER        => l_last_pa_request_rec.object_version_number
       , p_second_noa_pa_request_id     => l_last_pa_request_rec.pa_request_id
       , p_second_noa_cancel_or_correct => l_noa_cancel_or_correct
      );
    end if;
  hr_utility.set_location('Updated SF52 - OVN '||to_char(l_last_pa_request_rec.object_version_number)|| '-'|| l_proc, 25);
--    commit;
--
    hr_utility.set_location('Exiting  '|| l_proc, 15);
--
    return l_pa_req_rec.PA_REQUEST_ID;

end;
---------------------
-- Re-route
---------------------
function ghr_reroute_sf52 (
  P_PA_REQUEST_ID              IN     NUMBER
, p_par_object_version_number  in out nocopy number
 ,P_ROUTING_GROUP_ID           IN     NUMBER
 ,P_USER_NAME                  IN     VARCHAR2
)
return boolean
is
--
   l_proc                         varchar2(61) := g_package_name || 'GHR_REROUTE_SF52';
   l_INITIATOR_FLAG               VARCHAR2(1);
   l_REQUESTER_FLAG               VARCHAR2(1);
   l_AUTHORIZER_FLAG              VARCHAR2(1);
   l_PERSONNELIST_FLAG            VARCHAR2(1);
   l_APPROVER_FLAG                VARCHAR2(1);
   l_REVIEWER_FLAG                VARCHAR2(1);
--
   l_return_value                 BOOLEAN;
--
   l_1_pa_routing_history_id      number;
   l_1_prh_object_version_number  number;
   l_2_pa_routing_history_id      number;
   l_2_prh_object_version_number  number;
   l_U_PRH_OBJECT_VERSION_NUMBER  number;
   l_I_PA_ROUTING_HISTORY_ID      number;
   l_I_PRH_OBJECT_VERSION_NUMBER  number;
   l_par_object_version_number    number;
   l_par_object_version_number1   number;
--
begin
--
   hr_utility.set_location('Entering  '|| l_proc, 5);
   l_par_object_version_number1 := p_par_object_version_number;
--
   get_roles(
             P_ROUTING_GROUP_ID     => P_ROUTING_GROUP_ID
           , P_USER_NAME            => P_USER_NAME
           , P_INITIATOR_FLAG       => L_INITIATOR_FLAG
           , P_REQUESTER_FLAG       => L_REQUESTER_FLAG
           , P_AUTHORIZER_FLAG      => L_AUTHORIZER_FLAG
           , P_PERSONNELIST_FLAG    => L_PERSONNELIST_FLAG
           , P_APPROVER_FLAG        => L_APPROVER_FLAG
           , P_REVIEWER_FLAG        => L_REVIEWER_FLAG
    );

-- FIX for 4145758
-- If these 2 flags are NULL it means the user is no more associated to
-- that RTG GRP anymore.
--
IF (L_APPROVER_FLAG IS NULL and L_PERSONNELIST_FLAG IS NULL ) THEN
     fnd_message.set_name('GHR','GHR_38926_RTGGRP_DSNT_EXST');
      return FALSE;
      -- set this message here to retrieve the same under form
END IF;

    hr_utility.set_location('after get_roles'||P_ROUTING_GROUP_ID ,123456);
--
   l_return_value :=  (L_APPROVER_FLAG = 'Y' AND L_PERSONNELIST_FLAG = 'Y');
--
   hr_utility.set_location('Roles  Approver = ' || L_APPROVER_FLAG ||
                           ' PERSONNELIST= ' || L_PERSONNELIST_FLAG || l_proc, 10);
--
   if l_return_value then
       hr_utility.set_location('l_return_value is TRUE',10);
       ghr_api.call_workflow(p_pa_request_id, 'CONTINUE');

       hr_utility.set_location('Re routed  '|| l_proc, 15);
       hr_utility.set_location('Updated PA Requests  '|| l_proc, 20);
   else
       -- return false otherwise instead of throwing error mesg
       -- Fix for 4145758
       hr_utility.set_location('l_return_value is FALSE',10);
       fnd_message.set_name('GHR', 'GHR_38550_REROUTE');
       return l_return_value;
   end if;
--
    hr_utility.set_location('Exiting  '|| l_proc, 25);
--
    return l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      p_par_object_version_number := l_par_object_version_number;
/*Bug:6624155: Added the missing "raise"*/
      RAISE;
end;
--

FUNCTION chk_intervene_seq (
     p_pa_request_id              in     number
   , p_pa_notification_id         in     number
   , p_person_id                  in     number
   , p_effective_date             in     date
   , p_noa_id_correct             in     number)
  return NUMBER IS
--

  cursor c_multi_ia  is
    select count(*)
    from ghr_pa_requests
    where pa_notification_id is not null
    and person_id      = p_person_id
    and effective_date = p_effective_date
    group by person_id
    having count(*) > 1
    ;
  cursor  c_out_of_seq  is
     select 'Y' from
     ghr_pa_requests a
     where person_id = p_person_id
     and   effective_date = p_effective_date
     and   pa_notification_id is not null
     and   pa_notification_id < p_pa_notification_id
     and   not exists ( select 'Y' from ghr_pa_requests b
     where b.person_id = a.person_id
     and   b.pa_notification_id is not null
     and   b.pa_notification_id > a.pa_notification_id
     and   b.altered_pa_request_id = a.pa_request_id
     and   b.first_noa_code = '002'
     and   b.second_noa_code = a.first_noa_code )
     ;

   l_proc   varchar2(61) := g_package_name || 'chk_intervene_seq';
   l_effective_date                    ghr_pa_requests.effective_date%type;
   l_retro_first_noa                   ghr_nature_of_actions.code%type;
   l_retro_second_noa                   ghr_nature_of_actions.code%type;
   l_retro_pa_request_id               ghr_pa_requests.pa_request_id%type;
BEGIN
    hr_utility.set_location('Entering  '|| l_proc, 5);
    -- Determine Intervening Action
        --BUG # 7216635 Added the parameter p_noa_id_correct
     GHR_APPROVED_PA_REQUESTS.determine_ia(
                             p_pa_request_id => p_pa_request_id,
                             p_pa_notification_id => p_pa_notification_id,
                             p_person_id      => p_person_id,
                             p_effective_date => p_effective_date,
			     p_noa_id_correct => p_noa_id_correct,
                             p_retro_eff_date => l_effective_date,
                             p_retro_pa_request_id => l_retro_pa_request_id,
                             p_retro_first_noa => l_retro_first_noa,
                             p_retro_second_noa => l_retro_second_noa);
    IF l_effective_date is not NULL THEN
    -- Check for the presence of multiple intervening actions
    FOR c_multi_ia_rec IN c_multi_ia
      LOOP
        -- Check for out of sequence
          hr_utility.set_location('Multiple IA action'|| l_proc, 15);
        FOR c_out_seq IN c_out_of_seq
        LOOP
          hr_utility.set_location('Out of Sequence Action'|| l_proc, 20);
         return 0;
        END LOOP;
        exit;
      END LOOP;
    END IF;
    hr_utility.set_location('Leaving  '|| l_proc, 25);
    return 1;
END;

procedure determine_ia (
     p_pa_request_id              in     number
   , p_pa_notification_id         in     number
   , p_person_id                  in     number
   , p_effective_date             in     date
   , p_noa_id_correct             in     number
   , p_retro_pa_request_id        out nocopy   number
   , p_retro_eff_date             out nocopy   date
   , p_retro_first_noa            out nocopy   varchar2
   , p_retro_second_noa           out nocopy   varchar2 ) is
--
--6850492 added the comparison for p_noa_id_correct
  cursor c_determine_ia  is
    select effective_date,first_noa_code,
           second_noa_code,pa_notification_id,pa_request_id,
	   first_noa_id,second_noa_id,rpa_type,mass_action_id
    from ghr_pa_requests a
    where pa_notification_id is not null
    and person_id = p_person_id
    and pa_notification_id > p_pa_notification_id
    and effective_date <= p_effective_date
   -- and first_noa_code not in ('001') -- Exclude all cancellations
   and pa_request_id not in (   -- Exclude all cancellation of correction actions
       select nvl(altered_pa_request_id,0)
       from ghr_pa_requests b
       where a.person_id = b.person_id
       and b.first_noa_code in ('001')
       and b.pa_notification_id is not null )
    and pa_request_id not in (  -- Exclude all the corrections on the current action
       select nvl(pa_request_id,0)
       from ghr_pa_requests c
       connect by prior pa_request_id = altered_pa_request_id
       start with altered_pa_request_id = p_pa_request_id )
    order by pa_notification_id desc;

  --BUG 7216635 Added the following cursor to check processing order of the intervening
  -- action found
   cursor chk_ord_of_proc(p_ia_noac in varchar2)
       is
       select 1
       from  ghr_nature_of_actions
       where nature_of_action_id = p_noa_id_correct
       and   order_of_processing < (select order_of_processing
                                     from  ghr_nature_of_actions
				     where code = p_ia_noac
				     and p_effective_date between nvl(date_from,p_effective_date)
				                          and nvl(date_to,p_effective_date)
				   );
  --6850492
   cursor get_parent_action(p_pa_request_id in number)
       is
       select min(pa_request_id)
       from   ghr_pa_requests
       where  pa_notification_id is not null
       and    altered_pa_request_id is null
       start with pa_request_id = p_pa_request_id
       connect by pa_request_id = prior altered_pa_request_id;

       l_ia_parent_action  number;
       l_corr_parent_action number;
  --6850492

   l_proc  varchar2(61) := g_package_name || 'determine_ia';
   chk_order boolean;

   l_ia_noac  ghr_pa_requests.first_noa_code%type;

BEGIN
    hr_utility.set_location('Entering  '|| l_proc, 5);

    p_retro_eff_date := NULL;
    -- Determine Intervening Action
    FOR c_det_ia_rec IN c_determine_ia
    LOOP
     chk_order := TRUE;
     IF c_det_ia_rec.effective_date = p_effective_date and c_det_ia_rec.first_noa_code not in ('002','001') then
     --BUG 7216635 Added the following code to check processing order of the intervening
     -- action found if processed on same effective date if it is less than the correction initiated
     -- no need to consider as intervening
     -- This need to be verified for dual actions.

       l_ia_noac :=  c_det_ia_rec.first_noa_code;

	for rec_chk_ord_of_proc in chk_ord_of_proc(p_ia_noac => l_ia_noac)
	loop
	   chk_order := FALSE;
	end loop;

      END IF;

      IF c_det_ia_rec.effective_date = p_effective_date and c_det_ia_rec.first_noa_code in ('002')
         and c_det_ia_rec.rpa_type = 'DUAL' and c_det_ia_rec.mass_action_id is not null then

	 open get_parent_action(p_pa_request_id => c_det_ia_rec.pa_request_id);
	 fetch get_parent_action into l_ia_parent_action;
	 close get_parent_action;

	 open get_parent_action(p_pa_request_id => p_pa_request_id);
	 fetch get_parent_action into l_corr_parent_action;
	 close get_parent_action;

	 if l_ia_parent_action = l_corr_parent_action then
  	    chk_order := FALSE;
	 end if;
      end if;

     if chk_order then
       p_retro_pa_request_id    := c_det_ia_rec.pa_request_id;
       p_retro_eff_date   := c_det_ia_rec.effective_date;
       p_retro_first_noa  := c_det_ia_rec.first_noa_code;
       p_retro_second_noa := c_det_ia_rec.second_noa_code;
       --8250381 removed exit before end loop and placed here as
       -- need to be exited once if chk_order is true
       exit;
     end if;
     --BUG # 7216635
       hr_utility.set_location('Intervening Action '|| c_det_ia_rec.pa_notification_id, 20);

    END LOOP;
    hr_utility.set_location('Leaving  '|| l_proc, 25);

EXCEPTION
WHEN OTHERS THEN
  p_retro_pa_request_id := NULL;
  p_retro_eff_date      := NULL;
  p_retro_first_noa     := NULL;
  p_retro_second_noa    := NULL;
END;

--6850492
procedure Update_Dual_Id(p_parent_pa_request_id in number,
                         p_first_dual_action_id in number,
			 p_second_dual_action_id in number)
is

l_ovn1 ghr_pa_requests.object_version_number%type;
l_ovn2 ghr_pa_requests.object_version_number%type;

cursor get_ovn(p_pa_request_id in number)
    is
select object_version_number
from   ghr_pa_requests
where  pa_request_id = 	p_pa_request_id;

begin

for  rec_get_ovn in get_ovn(p_pa_request_id => p_first_dual_action_id)
loop
  l_ovn1 :=   rec_get_ovn.object_version_number;
end loop;

for  rec_get_ovn in get_ovn(p_pa_request_id => p_second_dual_action_id)
loop
  l_ovn2 :=   rec_get_ovn.object_version_number;
end loop;


ghr_par_upd.upd(p_pa_request_id => p_first_dual_action_id
               ,p_object_version_number => l_ovn1
	       ,p_mass_action_id        => p_second_dual_action_id
	       ,p_rpa_type              => 'DUAL');

ghr_par_upd.upd(p_pa_request_id         => p_second_dual_action_id
               ,p_object_version_number => l_ovn2
	       ,p_mass_action_id        => p_first_dual_action_id
	       ,p_rpa_type              => 'DUAL');

end Update_Dual_Id;
--6850492

end GHR_APPROVED_PA_REQUESTS ;

/
