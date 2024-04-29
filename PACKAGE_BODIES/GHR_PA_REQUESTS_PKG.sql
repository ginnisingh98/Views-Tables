--------------------------------------------------------
--  DDL for Package Body GHR_PA_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PA_REQUESTS_PKG" AS
/* $Header: ghparqst.pkb 120.4.12010000.1 2008/07/28 10:35:23 appldev ship $ */

-- For a particuar NOA Family this function returns the procesing method for a given
-- item in a form
PROCEDURE get_process_method(
                 p_noa_family_code    IN     ghr_noa_fam_proc_methods.noa_family_code%TYPE
                ,p_form_block_name    IN     ghr_pa_data_fields.form_block_name%TYPE
                ,p_form_field_name    IN     ghr_pa_data_fields.form_field_name%TYPE
                ,p_effective_date     IN     DATE
                ,p_process_method_code   OUT NOCOPY  VARCHAR2
                ,p_navigable_flag        OUT NOCOPY  VARCHAR2) IS

CURSOR cur_nfp IS
  SELECT nfp.process_method_code pm_code
        ,nfp.navigable_flag
  FROM   ghr_noa_fam_proc_methods nfp
        ,ghr_pa_data_fields       pdf
  WHERE  pdf.pa_data_field_id = nfp.pa_data_field_id
  AND    pdf.form_block_name  = p_form_block_name
  AND    pdf.form_field_name  = p_form_field_name
  AND    nfp.noa_family_code  = p_noa_family_code
  AND    nfp.enabled_flag   = 'Y'
  AND    NVL(p_effective_date,TRUNC(sysdate))
          BETWEEN NVL(nfp.start_date_active,NVL(p_effective_date,TRUNC(sysdate)))
          AND NVL(nfp.end_date_active,NVL(p_effective_date,TRUNC(sysdate)));

BEGIN
  FOR cur_nfp_rec IN cur_nfp LOOP
    p_process_method_code :=  cur_nfp_rec.pm_code;
    p_navigable_flag      :=  cur_nfp_rec.navigable_flag;
  END LOOP;

EXCEPTION

    -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_process_method_code := NULL;
   p_navigable_flag      := NULL;
  RAISE;

END get_process_method;

FUNCTION get_data_field_name(
                   p_form_block_name    IN     ghr_pa_data_fields.form_block_name%TYPE
                  ,p_form_field_name    IN     ghr_pa_data_fields.form_field_name%TYPE)
  RETURN VARCHAR2 IS
--
CURSOR cur_pdf IS
  SELECT pdf.name
  FROM   ghr_pa_data_fields       pdf
  WHERE  pdf.form_block_name  = p_form_block_name
  AND    pdf.form_field_name  = p_form_field_name;
  --
BEGIN
  FOR cur_pdf_rec IN cur_pdf LOOP
    RETURN(cur_pdf_rec.name);
  END LOOP;
  --
  RETURN (NULL);
  --
END get_data_field_name;
--
PROCEDURE get_restricted_process_method(
                   p_restricted_form     IN     ghr_restricted_proc_methods.restricted_form%TYPE
                  ,p_form_block_name     IN     ghr_pa_data_fields.form_block_name%TYPE
                  ,p_form_field_name     IN     ghr_pa_data_fields.form_field_name%TYPE
                  ,p_restricted_proc_method OUT NOCOPY VARCHAR2) IS

-- there is no need to pass in an effective data since the restricted form is for a user and is not
-- relevant to the 'effective date' on the SF52 we will do the restricted form as of todays date
CURSOR cur_rpm IS
  SELECT rpm.restricted_proc_method
  FROM   ghr_pa_data_fields          pdf
        ,ghr_restricted_proc_methods rpm
  WHERE  pdf.pa_data_field_id = rpm.pa_data_field_id
  AND    rpm.restricted_form  = p_restricted_form
  AND    pdf.form_block_name  = p_form_block_name
  AND    pdf.form_field_name  = p_form_field_name
  AND    rpm.enabled_flag   = 'Y'
  AND    TRUNC(sysdate)
          BETWEEN NVL(rpm.start_date_active,TRUNC(sysdate))
          AND NVL(rpm.end_date_active,TRUNC(sysdate));

BEGIN
  p_restricted_proc_method  := NULL;
  FOR cur_rpm_rec IN cur_rpm LOOP
    p_restricted_proc_method :=  cur_rpm_rec.restricted_proc_method;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
     p_restricted_proc_method := NULL;
  RAISE;

END get_restricted_process_method;

FUNCTION get_lookup_meaning(
                 p_application_id NUMBER
                ,p_lookup_type    hr_lookups.lookup_type%TYPE
                ,p_lookup_code    hr_lookups.lookup_code%TYPE)
  RETURN VARCHAR2 IS

CURSOR cur_loc IS
  SELECT loc.meaning
  FROM   hr_lookups loc
  WHERE  loc.lookup_type    = p_lookup_type
  AND    loc.lookup_code    = p_lookup_code;

BEGIN
  -- Previously this routine used to go directly in on FND_COMMON_LOOKUPS
  -- now it assumes it was only used for types with application id 800 and hence
  -- should use HR_LOOKUPS
  IF p_application_id = 800 THEN
    FOR cur_loc_rec IN cur_loc LOOP
      RETURN(cur_loc_rec.meaning);
    END LOOP;
  ELSE
    hr_utility.set_message(8301, 'GHR_38596_NOT_HR_LOOKUP');
    hr_utility.raise_error;
  END IF;

  RETURN(NULL);

END get_lookup_meaning;

FUNCTION get_lookup_description(
                 p_application_id NUMBER
                ,p_lookup_type    hr_lookups.lookup_type%TYPE
                ,p_lookup_code    hr_lookups.lookup_code%TYPE)
  RETURN VARCHAR2 IS

CURSOR cur_loc IS
  SELECT loc.description
  FROM   hr_lookups loc
  WHERE  loc.lookup_type    = p_lookup_type
  AND    loc.lookup_code    = p_lookup_code;

BEGIN
  -- Previously this routine used to go directly in on FND_COMMON_LOOKUPS
  -- now it assumes it was only used for types with application id 800 and hence
  -- should use HR_LOOKUPS
  IF p_application_id = 800 THEN
    FOR cur_loc_rec IN cur_loc LOOP
      RETURN(cur_loc_rec.description);
    END LOOP;
  ELSE
    -- cannot use hr_utility as it will violate the pragma we need therfore just return
    -- error!! -- This shouldn't happen anyway as this procedure should only be called for
    -- application id 800!
    RETURN('Error: GHR_38596_NOT_HR_LOOKUP');
  END IF;

  RETURN(NULL);

END get_lookup_description;

FUNCTION get_noa_family_name(
                 p_noa_family_code ghr_families.noa_family_code%TYPE)
  RETURN VARCHAR2 IS

l_ret_val ghr_families.name%TYPE := NULL;

CURSOR cur_fam IS
  SELECT fam.name
  FROM   ghr_families fam
  WHERE  fam.noa_family_code = p_noa_family_code;

BEGIN
  FOR cur_fam_rec IN cur_fam LOOP
    l_ret_val :=  cur_fam_rec.name;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_family_name;

FUNCTION get_routing_group_name(
                   p_routing_group_id  ghr_routing_groups.routing_group_id%TYPE)
  RETURN VARCHAR2 IS

l_ret_val ghr_routing_groups.name%TYPE := NULL;

CURSOR cur_rgr IS
  SELECT rgr.name
  FROM   ghr_routing_groups rgr
  WHERE  rgr.routing_group_id = p_routing_group_id;

BEGIN
  FOR cur_rgr_rec IN cur_rgr LOOP
    l_ret_val := cur_rgr_rec.name;
  END LOOP;

  RETURN(l_ret_val);

END get_routing_group_name;

FUNCTION get_full_name(
                 p_person_id      per_people_f.person_id%TYPE
                ,p_effective_date date)
  RETURN VARCHAR2 IS
l_ret_val VARCHAR2(240) := NULL;
-- last name is 40 long, first name is 20 long and middles names is 60 long
-- therfore plus ',' and ' ' max length is 122!

CURSOR cur_per IS
  SELECT per.last_name||','|| per.first_name||' '|| per.middle_names full_name
  FROM   per_people_f per
  WHERE  per.person_id = p_person_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between per.effective_start_date and per.effective_end_date;

BEGIN
  FOR cur_per_rec IN cur_per LOOP
    l_ret_val := substr(cur_per_rec.full_name,1,240);
  END LOOP;

  RETURN(l_ret_val);

END get_full_name;


FUNCTION get_full_name_unsecure(
                        p_person_id  per_people_f.person_id%TYPE
		       ,p_effective_date  date )
       RETURN VARCHAR2 IS
 l_ret_val VARCHAR2(240):=NULL;

-- last name is 40 long, first name is 20 long and middles names is 60 long
-- therfore plus ',' and ' ' max length is 122!

CURSOR cur_per IS
  SELECT per.last_name||','|| per.first_name||' '|| per.middle_names full_name
  FROM per_all_people_f per
  WHERE per.person_id = p_person_id
  AND  NVL(p_effective_date,TRUNC(sysdate)) BETWEEN per.effective_start_date AND per.effective_end_date;

BEGIN
  FOR cur_per_rec IN cur_per LOOP
  l_ret_val := substr(cur_per_rec.full_name,1,240);
  END LOOP;

  RETURN(l_ret_val);

END get_full_name_unsecure;


FUNCTION get_noa_descriptor(
                 p_nature_of_action_id IN     ghr_nature_of_actions.nature_of_action_id%TYPE)
  RETURN VARCHAR2 IS

l_ret_val ghr_nature_of_actions.description%TYPE := NULL;

CURSOR cur_noa IS
  SELECT noa.description
  FROM   ghr_nature_of_actions noa
  WHERE  noa.nature_of_action_id= p_nature_of_action_id;

BEGIN
  FOR cur_noa_rec IN cur_noa LOOP
    l_ret_val := cur_noa_rec.description;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_descriptor;

FUNCTION get_remark_descriptor(
                 p_remark_id IN     ghr_remarks.remark_id%TYPE)
  RETURN VARCHAR2 IS

l_ret_val ghr_remarks.description%TYPE := NULL;

CURSOR cur_rem IS
  SELECT rem.description
  FROM   ghr_remarks rem
  WHERE  rem.remark_id = p_remark_id;

BEGIN
  FOR cur_rem_rec IN cur_rem LOOP
    l_ret_val :=  cur_rem_rec.description;
  END LOOP;

  RETURN(l_ret_val);

END get_remark_descriptor;

 -- Bug#5482191 Added the function get_personnel_system_indicator
FUNCTION get_personnel_system_indicator(
			   p_position_id    hr_all_positions_f.position_id%TYPE
			  ,p_effective_date date)
RETURN VARCHAR2 IS
    l_pos_psi_data	per_position_extra_info%rowtype;
    l_personnel_system_indicator VARCHAR2(30);
BEGIN
    hr_utility.set_location('Entering get_psi',0);
	ghr_history_fetch.fetch_positionei(
                        p_position_id      => p_position_id,
                        p_information_type => 'GHR_US_POS_AFHR_DATA',
                        p_date_effective   => p_effective_date,
                        p_pos_ei_data      => l_pos_psi_data);
     IF l_pos_psi_data.position_extra_info_id is not null THEN
        l_personnel_system_indicator := l_pos_psi_data.poei_information3;
     ELSE
        l_personnel_system_indicator  := '00';
     END IF;
     hr_utility.set_location('Leaving get_psi',10);
     RETURN l_personnel_system_indicator;
EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('Leaving get_psi',20);
        RAISE;
END get_personnel_system_indicator;
--

PROCEDURE get_default_routing_group(p_user_name          IN     fnd_user.user_name%TYPE
                                   ,p_routing_group_id   IN OUT NOCOPY  NUMBER
                                   ,p_initiator_flag     IN OUT NOCOPY  VARCHAR2
                                   ,p_requester_flag     IN OUT NOCOPY  VARCHAR2
                                   ,p_authorizer_flag    IN OUT NOCOPY  VARCHAR2
                                   ,p_personnelist_flag  IN OUT NOCOPY  VARCHAR2
                                   ,p_approver_flag      IN OUT NOCOPY  VARCHAR2
                                   ,p_reviewer_flag      IN OUT NOCOPY  VARCHAR2) IS

    l_routing_group_id     NUMBER;
    l_initiator_flag       VARCHAR2(150);
    l_requester_flag       VARCHAR2(150);
    l_authorizer_flag      VARCHAR2(150);
    l_personnelist_flag    VARCHAR2(150);
    l_approver_flag        VARCHAR2(150);
    l_reviewer_flag        VARCHAR2(150);

CURSOR cur_rgr IS
-- Note: pei_information10 is a flag that indicates which is the defaulting routing_group
  SELECT pei.pei_information3 routing_group_id
        ,pei.pei_information4 initiator_flag
        ,pei.pei_information5 requester_flag
        ,pei.pei_information6 authorizer_flag
        ,pei.pei_information7 personnelist_flag
        ,pei.pei_information8 approver_flag
        ,pei.pei_information9 reviewer_flag
  FROM   per_people_extra_info  pei
        ,fnd_user               use
  WHERE use.user_name = p_user_name
  AND   pei.person_id = use.employee_id
  AND   pei.information_type = 'GHR_US_PER_WF_ROUTING_GROUPS'
  AND   pei.pei_information10 = 'Y';


BEGIN

   --Initialisation for NOCOPY Changes
    l_routing_group_id   :=p_routing_group_id;
    l_initiator_flag     :=p_initiator_flag;
    l_requester_flag     :=p_requester_flag;
    l_authorizer_flag    :=p_authorizer_flag;
    l_personnelist_flag  :=p_personnelist_flag;
    l_approver_flag      :=p_approver_flag;
    l_reviewer_flag      :=p_reviewer_flag;

  -- while we are here we may as well get the personal roles even though this maybe overwriten
  -- by the group box roles later
  FOR cur_rgr_rec IN cur_rgr LOOP
    p_routing_group_id   := cur_rgr_rec.routing_group_id;
    p_initiator_flag     := cur_rgr_rec.initiator_flag;
    p_requester_flag     := cur_rgr_rec.requester_flag;
    p_authorizer_flag    := cur_rgr_rec.authorizer_flag;
    p_personnelist_flag  := cur_rgr_rec.personnelist_flag;
    p_approver_flag      := cur_rgr_rec.approver_flag;
    p_reviewer_flag      := cur_rgr_rec.reviewer_flag;
  END LOOP;
EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
    p_routing_group_id   :=l_routing_group_id;
    p_initiator_flag     :=l_initiator_flag;
    p_requester_flag     :=l_requester_flag;
    p_authorizer_flag    :=l_authorizer_flag;
    p_personnelist_flag  :=l_personnelist_flag;
    p_approver_flag      :=l_approver_flag;
    p_reviewer_flag      :=l_reviewer_flag;
  RAISE;

END get_default_routing_group;

PROCEDURE get_last_routing_list(p_pa_request_id    IN              ghr_pa_requests.pa_request_id%TYPE
                               ,p_routing_list_id      OUT NOCOPY  ghr_routing_lists.routing_list_id%TYPE
                               ,p_routing_list_name    OUT NOCOPY  ghr_routing_lists.name%TYPE
                               ,p_next_seq_number      OUT NOCOPY  ghr_routing_list_members.seq_number%TYPE
                               ,p_next_user_name       OUT NOCOPY  ghr_routing_list_members.user_name%TYPE
                               ,p_next_groupbox_id     OUT NOCOPY  ghr_routing_list_members.groupbox_id%TYPE
                               ,p_broken            IN OUT NOCOPY  BOOLEAN) IS


     l_broken   BOOLEAN	;

-- need to select the last routing list used for the given pa request and determine
-- if that was the last record
CURSOR cur_prh_last_rli IS
  SELECT rli.routing_list_id
        ,rli.name
        ,prh.routing_seq_number
        ,prh.pa_routing_history_id
  FROM   ghr_routing_lists      rli
        ,ghr_pa_routing_history prh
  WHERE  prh.pa_request_id = p_pa_request_id
  AND    prh.routing_list_id = rli.routing_list_id
  ORDER BY prh.pa_routing_history_id DESC;
-- The order by makes sure the first one we get is the last in the history
-- By joing to routing_list forces us to have a routing_list (since we didn't do an outer join)

-- Just get the last record so we can see if the cursor above got us the last record
CURSOR cur_prh_last IS
  SELECT prh.pa_routing_history_id
  FROM   ghr_pa_routing_history  prh
  WHERE  prh.pa_request_id = p_pa_request_id
  ORDER BY prh.pa_routing_history_id DESC;
-- Again the order by saves us having to do a max

CURSOR cur_rlm (p_routing_list_id IN NUMBER
               ,p_seq_number      IN NUMBER) IS
  SELECT   rlm.seq_number
          ,rlm.user_name
          ,rlm.groupbox_id
  FROM     ghr_routing_list_members rlm
  WHERE    rlm.routing_list_id = p_routing_list_id
  AND      rlm.seq_number      > p_seq_number
  ORDER BY rlm.seq_number asc;

BEGIN

  l_broken  :=p_broken; --NOCOPY Changes

  -- Go and get the last routing list to be used
  FOR cur_prh_last_rli_rec IN cur_prh_last_rli LOOP
    p_routing_list_id   := cur_prh_last_rli_rec.routing_list_id;
    p_routing_list_name := cur_prh_last_rli_rec.name;

    -- See if the routing list has been broken
    FOR cur_prh_last_rec IN cur_prh_last LOOP
      IF cur_prh_last_rec.pa_routing_history_id = cur_prh_last_rli_rec.pa_routing_history_id THEN
        p_broken := FALSE;
      ELSE
        p_broken := TRUE;
      END IF;
      EXIT;  -- Only want the first record therfore exit after we have got it
    END LOOP;

    -- If it is not broken then get the next sequence in the routing list
    --
    IF NOT p_broken THEN
      FOR cur_rlm_rec IN cur_rlm(cur_prh_last_rli_rec.routing_list_id, cur_prh_last_rli_rec.routing_seq_number)  LOOP
        p_next_seq_number  := cur_rlm_rec.seq_number;
        p_next_user_name   := cur_rlm_rec.user_name;
        p_next_groupbox_id := cur_rlm_rec.groupbox_id;
        --
        -- When we get the first one exit
        EXIT;
      END LOOP;
    END IF;

    EXIT;  -- Only want the first record therfore exit after we have got it
  END LOOP;
EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
   WHEN others THEN
        p_routing_list_id   := NULL;
        p_routing_list_name := NULL;
        p_next_seq_number   := NULL;
        p_next_user_name    := NULL;
        p_next_groupbox_id  := NULL;
	p_broken            :=l_broken;
   RAISE;

END get_last_routing_list;

PROCEDURE get_roles (p_pa_request_id     in number
                    ,p_routing_group_id  in number
                    ,p_user_name         in varchar2 default null
                    ,p_initiator_flag    in out nocopy varchar2
                    ,p_requester_flag    in out nocopy varchar2
                    ,p_authorizer_flag   in out nocopy varchar2
                    ,p_personnelist_flag in out nocopy varchar2
                    ,p_approver_flag     in out nocopy varchar2
                    ,p_reviewer_flag     in out nocopy varchar2) IS

l_initiator_flag     varchar2(150);
l_requester_flag     varchar2(150);
l_authorizer_flag    varchar2(150);
l_personnelist_flag  varchar2(150);
l_approver_flag      varchar2(150);
l_reviewer_flag      varchar2(150);

l_groupbox_id       ghr_pa_routing_history.groupbox_id%TYPE;
l_user_name         ghr_pa_routing_history.user_name%TYPE;

CURSOR cur_gp_user IS
  select prh.groupbox_id
        ,prh.user_name
  from   ghr_pa_routing_history prh
  where  prh.pa_request_id = p_pa_request_id
  order by prh.pa_routing_history_id desc;

CURSOR cur_first_user IS
  select prh.groupbox_id
  from   ghr_pa_routing_history prh
  where  prh.pa_request_id = p_pa_request_id
  and    prh.user_name = l_user_name
  and    prh.groupbox_id is not NULL
  and    not exists (select 1
                     from   ghr_pa_routing_history prh2
                     where  prh2.pa_request_id = p_pa_request_id
                     and    prh2.user_name <> l_user_name
                     and    prh2.pa_routing_history_id > prh.pa_routing_history_id)
  order by prh.pa_routing_history_id asc;

CURSOR cur_user_roles IS
  select pei.pei_information4 initiator_flag
        ,pei.pei_information5 requester_flag
        ,pei.pei_information6 authorizer_flag
        ,pei.pei_information7 personnelist_flag
        ,pei.pei_information8 approver_flag
        ,pei.pei_information9 reviewer_flag
  from   per_people_extra_info pei
        ,fnd_user              usr
  where  usr.user_name        = l_user_name
  and    pei.person_id        = usr.employee_id
  and    pei.information_type = 'GHR_US_PER_WF_ROUTING_GROUPS'
  and    pei.pei_information3 = p_routing_group_id;

CURSOR cur_gpbox_user_roles IS
  select gru.initiator_flag
        ,gru.requester_flag
        ,gru.authorizer_flag
        ,gru.personnelist_flag
        ,gru.approver_flag
        ,gru.reviewer_flag
  from   ghr_groupbox_users gru
  where  gru.groupbox_id = l_groupbox_id
  and    gru.user_name   = p_user_name;

BEGIN

  -- Initialisation for NOCOPY Changes
    l_initiator_flag     :=p_initiator_flag;
    l_requester_flag     :=p_requester_flag;
    l_authorizer_flag    :=p_authorizer_flag;
    l_personnelist_flag  :=p_personnelist_flag;
    l_approver_flag      :=p_approver_flag;
    l_reviewer_flag      :=p_reviewer_flag;

  -- First get the last history record for given pa_request_id
  FOR c_rec in cur_gp_user LOOP
    l_groupbox_id      := c_rec.groupbox_id;
    l_user_name        := c_rec.user_name;
    EXIT;
  END LOOP;

  -- If it is for a group box then definitely use the group box roles and that is it!
  IF l_groupbox_id is not null THEN
    FOR C_rec in cur_gpbox_user_roles LOOP
      p_initiator_flag    := c_rec.initiator_flag;
      p_requester_flag    := c_rec.requester_flag;
      p_authorizer_flag   := c_rec.authorizer_flag;
      p_personnelist_flag := c_rec.personnelist_flag;
      p_approver_flag     := c_rec.approver_flag;
      p_reviewer_flag     := c_rec.reviewer_flag;
      EXIT;
    END LOOP;

  ELSE
    -- otherwise still need to work out if we use the individual roles or it was initially
    -- set to this user in a group box and they saved and held!
    IF l_user_name is null THEN
      l_user_name := p_user_name;
    END IF;
    FOR cur_first_user_rec in cur_first_user LOOP
      l_groupbox_id      := cur_first_user_rec.groupbox_id;
      EXIT;
    END LOOP;

    -- Again if it is for a group box then definitely use the group box roles
    -- Note: the l_groupbox_id will be null if the above cursor return no rows
    IF l_groupbox_id is not null THEN
      FOR C_rec in cur_gpbox_user_roles LOOP
        p_initiator_flag    := c_rec.initiator_flag;
        p_requester_flag    := c_rec.requester_flag;
        p_authorizer_flag   := c_rec.authorizer_flag;
        p_personnelist_flag := c_rec.personnelist_flag;
        p_approver_flag     := c_rec.approver_flag;
        p_reviewer_flag     := c_rec.reviewer_flag;
        EXIT;
      END LOOP;
    ELSE
      -- definitely get the user roles
      FOR c_rec in cur_user_roles LOOP
        p_initiator_flag    := c_rec.initiator_flag;
        p_requester_flag    := c_rec.requester_flag;
        p_authorizer_flag   := c_rec.authorizer_flag;
        p_personnelist_flag := c_rec.personnelist_flag;
        p_approver_flag     := c_rec.approver_flag;
        p_reviewer_flag     := c_rec.reviewer_flag;
      END LOOP;
    END IF;
  END IF;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
    p_initiator_flag     :=l_initiator_flag;
    p_requester_flag     :=l_requester_flag;
    p_authorizer_flag    :=l_authorizer_flag;
    p_personnelist_flag  :=l_personnelist_flag;
    p_approver_flag      :=l_approver_flag;
    p_reviewer_flag      :=l_reviewer_flag;
  RAISE;

END get_roles;

PROCEDURE get_person_details (p_person_id           IN     per_people_f.person_id%TYPE
                             ,p_effective_date      IN     DATE
                             ,p_national_identifier IN OUT NOCOPY  per_people_f.national_identifier%TYPE
                             ,p_date_of_birth       IN OUT NOCOPY  per_people_f.date_of_birth%TYPE
                             ,p_last_name           IN OUT NOCOPY  per_people_f.last_name%TYPE
                             ,p_first_name          IN OUT NOCOPY  per_people_f.first_name%TYPE
                             ,p_middle_names        IN OUT NOCOPY  per_people_f.middle_names%TYPE) IS

l_national_identifier   per_people_f.national_identifier%TYPE;
l_date_of_birth         per_people_f.date_of_birth%TYPE;
l_last_name             per_people_f.last_name%TYPE;
l_first_name            per_people_f.first_name%TYPE;
l_middle_names          per_people_f.middle_names%TYPE;

CURSOR cur_per IS
  SELECT per.national_identifier
        ,per.date_of_birth
        ,per.last_name
        ,per.first_name
        ,per.middle_names
  FROM   per_people_f per
  WHERE  per.person_id = p_person_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between per.effective_start_date and per.effective_end_date;

BEGIN
l_national_identifier :=p_national_identifier;
l_date_of_birth     :=p_date_of_birth;
l_last_name         :=p_last_name;
l_first_name        :=p_first_name;
l_middle_names      :=p_middle_names;

  FOR cur_per_rec IN cur_per LOOP
    p_national_identifier := cur_per_rec.national_identifier;
    p_date_of_birth       := cur_per_rec.date_of_birth;
    p_last_name           := cur_per_rec.last_name;
    p_first_name          := cur_per_rec.first_name;
    p_middle_names        := cur_per_rec.middle_names;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
	p_national_identifier :=l_national_identifier;
	p_date_of_birth       :=l_date_of_birth;
	p_last_name           :=l_last_name;
	p_first_name          :=l_first_name;
 	p_middle_names        :=l_middle_names;
  RAISE;

END get_person_details;

PROCEDURE get_duty_station_details (p_duty_station_id   IN     ghr_duty_stations_v.duty_station_id%TYPE
                                   ,p_effective_date    IN     DATE
                                   ,p_duty_station_code IN OUT NOCOPY  ghr_duty_stations_v.duty_station_code%TYPE
                                   ,p_duty_station_desc IN OUT NOCOPY  ghr_duty_stations_v.duty_station_desc%TYPE) IS

l_duty_station_code   ghr_duty_stations_v.duty_station_code%TYPE;
l_duty_station_desc   ghr_duty_stations_v.duty_station_desc%TYPE;

CURSOR cur_dstv IS
  SELECT dstv.duty_station_code
        ,dstv.duty_station_desc
  FROM   ghr_duty_stations_v dstv
  WHERE  dstv.duty_station_id = p_duty_station_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between dstv.effective_start_date and dstv.effective_end_date;
  --
BEGIN

   --Initialisation for NOCOPY Changes

  l_duty_station_code := p_duty_station_code;
  l_duty_station_desc := p_duty_station_desc;

  p_duty_station_code := NULL;
  p_duty_station_desc := NULL;
  FOR cur_dstv_rec IN cur_dstv LOOP
    p_duty_station_code := cur_dstv_rec.duty_station_code;
    p_duty_station_desc := cur_dstv_rec.duty_station_desc;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_duty_station_code := l_duty_station_code;
   p_duty_station_desc := l_duty_station_desc;
  RAISE;

END get_duty_station_details;
--
--
PROCEDURE get_SF52_person_ddf_details (p_person_id             IN  per_people_f.person_id%TYPE
                                      ,p_date_effective        IN  date       default sysdate
                                      ,p_citizenship           OUT NOCOPY varchar2
                                      ,p_veterans_preference   OUT NOCOPY varchar2
                                      ,p_veterans_pref_for_rif OUT NOCOPY varchar2
                                      ,p_veterans_status       OUT NOCOPY varchar2
                                      ,p_scd_leave             OUT NOCOPY varchar2) IS


-- Bug No 550117 Need seperate variable to store what is returned by the second
-- call to ghr_history_fetch.fetch_peopleei

l_per_ei_data      per_people_extra_info%rowtype;
l_per_ei_scd_data  per_people_extra_info%rowtype;

BEGIN

  ghr_history_fetch.fetch_peopleei(
    p_person_id         => p_person_id,
    p_information_type  => 'GHR_US_PER_SF52',
    p_date_effective    => p_date_effective,
    p_per_ei_data       => l_per_ei_data);

  if l_per_ei_data.person_extra_info_id is not null then
    p_citizenship           := l_per_ei_data.pei_information3;
    p_veterans_preference   := l_per_ei_data.pei_information4;
    p_veterans_pref_for_rif := l_per_ei_data.pei_information5;
    p_veterans_status       := l_per_ei_data.pei_information6;
  end if;

  ghr_history_fetch.fetch_peopleei(
    p_person_id         => p_person_id,
    p_information_type  => 'GHR_US_PER_SCD_INFORMATION',
    p_date_effective    => p_date_effective,
    p_per_ei_data       => l_per_ei_scd_data);

  if l_per_ei_scd_data.person_extra_info_id is not null then
    p_scd_leave           := l_per_ei_scd_data.pei_information3;
  end if;


EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
 WHEN others THEN
   p_citizenship           :=NULL;
   p_veterans_preference   :=NULL;
   p_veterans_pref_for_rif :=NULL;
   p_veterans_status       :=NULL;
   p_scd_leave             :=NULL;
 RAISE;

END get_SF52_person_ddf_details;

-- vsm
PROCEDURE get_SF52_asg_ddf_details (p_assignment_id         IN  per_assignments_f.assignment_id%TYPE
                                   ,p_date_effective        IN  date       default sysdate
                                   ,p_tenure                OUT NOCOPY varchar2
                                   ,p_annuitant_indicator   OUT NOCOPY varchar2
                                   ,p_pay_rate_determinant  OUT NOCOPY varchar2
                                   ,p_work_schedule         OUT NOCOPY varchar2
                                   ,p_part_time_hours       OUT NOCOPY varchar2) IS

  l_asgei_data    per_assignment_extra_info%rowtype;

BEGIN
  ghr_history_fetch.fetch_asgei (
    p_assignment_id     => p_assignment_id,
    p_information_type  => 'GHR_US_ASG_SF52',
    p_date_effective    => p_date_effective,
    p_asg_ei_data       => l_asgei_data) ;

  if l_asgei_data.assignment_extra_info_id is not null then
    p_tenure                := l_asgei_data.aei_information4;
    p_annuitant_indicator   := l_asgei_data.aei_information5;

    -- bit weird this but if it the PRD is stored as a 5 on the database when we retrieve it for
    -- future use we retrieve a 6 and if it is a 7 we retrieve a 0!!
    if l_asgei_data.aei_information6 = '5' then
      p_pay_rate_determinant  := '6';
    elsif l_asgei_data.aei_information6 = '7' then
      p_pay_rate_determinant  := '0';
    else
      p_pay_rate_determinant  := l_asgei_data.aei_information6;
    end if;

    p_work_schedule         := l_asgei_data.aei_information7;
    p_part_time_hours       := l_asgei_data.aei_information8;

  end if;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_tenure                :=NULL;
   p_annuitant_indicator   :=NULL;
   p_pay_rate_determinant  :=NULL;
   p_work_schedule         :=NULL;
   p_part_time_hours       :=NULL;
  RAISE;

END get_SF52_asg_ddf_details;

--vsm
PROCEDURE get_SF52_pos_ddf_details (p_position_id            IN  hr_all_positions_f.position_id%TYPE
                                   ,p_date_Effective         IN  date        default sysdate
                                   ,p_flsa_category          OUT NOCOPY  varchar2
                                   ,p_bargaining_unit_status OUT NOCOPY  varchar2
                                   ,p_work_schedule          OUT NOCOPY  varchar2
                                   ,p_functional_class       OUT NOCOPY  varchar2
                                   ,p_supervisory_status     OUT NOCOPY  varchar2
                                   ,p_position_occupied      OUT NOCOPY  varchar2
                                   ,p_appropriation_code1    OUT NOCOPY  varchar2
                                   ,p_appropriation_code2    OUT NOCOPY  varchar2
				   ,p_personnel_office_id    OUT NOCOPY  varchar2
				   ,p_office_symbol	     OUT NOCOPY  varchar2
                                   ,p_part_time_hours        OUT NOCOPY  number) IS

l_pos_ei_grp1_data	per_position_extra_info%rowtype;
l_pos_ei_grp2_data	per_position_extra_info%rowtype;
--l_dummy_posei	per_position_extra_info%rowtype;

BEGIN

  ghr_history_fetch.fetch_positionei(
    p_position_id      => p_position_id,
    p_information_type => 'GHR_US_POS_GRP1',
    p_date_effective   => p_date_effective,
    p_pos_ei_data      => l_pos_ei_grp1_data);

  if l_pos_ei_grp1_data.position_extra_info_id is not null then
    p_personnel_office_id    := l_pos_ei_grp1_data.poei_information3;
    p_office_symbol          := l_pos_ei_grp1_data.poei_information4;
    p_flsa_category          := l_pos_ei_grp1_data.poei_information7;
    p_bargaining_unit_status := l_pos_ei_grp1_data.poei_information8;
    p_work_schedule          := l_pos_ei_grp1_data.poei_information10;
    p_functional_class       := l_pos_ei_grp1_data.poei_information11;
    p_supervisory_status     := l_pos_ei_grp1_data.poei_information16;
    p_part_time_hours        := l_pos_ei_grp1_data.poei_information23;
  end if;

  ghr_history_fetch.fetch_positionei(
    p_position_id      => p_position_id,
    p_information_type => 'GHR_US_POS_GRP2',
    p_date_effective   => p_date_effective,
    p_pos_ei_data      => l_pos_ei_grp2_data);

  if l_pos_ei_grp2_data.position_extra_info_id is not null then
    p_position_occupied   := l_pos_ei_grp2_data.poei_information3;
    p_appropriation_code1 := l_pos_ei_grp2_data.poei_information13;
    p_appropriation_code2 := l_pos_ei_grp2_data.poei_information14;
  end if;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_flsa_category             :=NULL;
   p_bargaining_unit_status    :=NULL;
   p_functional_class          :=NULL;
   p_work_schedule             :=NULL;
   p_part_time_hours           :=NULL;
   p_supervisory_status        :=NULL;
   p_position_occupied         :=NULL;
   p_appropriation_code1       :=NULL;
   p_appropriation_code2       :=NULL;
   p_personnel_office_id       :=NULL;
   p_office_symbol             :=NULL;
  RAISE;

END get_SF52_pos_ddf_details;


PROCEDURE get_SF52_loc_ddf_details (p_location_id           IN  hr_locations.location_id%TYPE
                                   ,p_duty_station_id       OUT NOCOPY varchar2) IS

CURSOR cur_lei IS
  SELECT lei.lei_information3 duty_station_id
  FROM  hr_location_extra_info lei
  WHERE lei.location_id = p_location_id
  AND   lei.information_type = 'GHR_US_LOC_INFORMATION';

BEGIN
  FOR cur_lei_rec IN cur_lei LOOP
    p_duty_station_id := cur_lei_rec.duty_station_id;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_duty_station_id  :=NULL;
  RAISE;
END get_SF52_loc_ddf_details;


--vms
PROCEDURE get_address_details (p_person_id            IN  per_addresses.person_id%TYPE
                              ,p_effective_date       IN  DATE
                              ,p_address_line1        OUT NOCOPY  per_addresses.address_line1%TYPE
                              ,p_address_line2        OUT NOCOPY  per_addresses.address_line2%TYPE
                              ,p_address_line3        OUT NOCOPY  per_addresses.address_line3%TYPE
                              ,p_town_or_city         OUT NOCOPY  per_addresses.town_or_city%TYPE
                              ,p_region_2             OUT NOCOPY  per_addresses.region_2%TYPE
                              ,p_postal_code          OUT NOCOPY  per_addresses.postal_code%TYPE
                              ,p_country	      OUT NOCOPY  per_addresses.country%TYPE
                              ,p_territory_short_name OUT NOCOPY  varchar2) IS
CURSOR cur_adr IS
  SELECT adr.address_line1
        ,adr.address_line2
        ,adr.address_line3
        ,adr.town_or_city
        ,adr.region_2
        ,adr.postal_code
        ,adr.country
        ,ter.territory_short_name
  FROM  fnd_territories_vl ter
       ,per_addresses      adr
  WHERE adr.person_id = p_person_id
  AND   adr.primary_flag = 'Y'
  AND   NVL(p_effective_date, TRUNC(sysdate))
           BETWEEN adr.date_from AND NVL(adr.date_to,NVL(p_effective_date,TRUNC(sysdate)))
  AND   adr.country = ter.territory_code;
BEGIN

  FOR cur_adr_rec IN cur_adr LOOP
    p_address_line1        := cur_adr_rec.address_line1;
    p_address_line2        := cur_adr_rec.address_line2;
    p_address_line3        := cur_adr_rec.address_line3;
    p_town_or_city         := cur_adr_rec.town_or_city;
    p_region_2             := cur_adr_rec.region_2;
    p_postal_code          := cur_adr_rec.postal_code;
    p_country              := cur_adr_rec.country;
    p_territory_short_name := cur_adr_rec.territory_short_name;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
    p_address_line1        := NULL;
    p_address_line2        := NULL;
    p_address_line3        := NULL;
    p_town_or_city         := NULL;
    p_region_2             := NULL;
    p_postal_code          := NULL;
    p_country              := NULL;
    p_territory_short_name := NULL;
  RAISE;

END get_address_details;

PROCEDURE get_SF52_to_data_elements
                               (p_position_id              IN     hr_all_positions_f.position_id%TYPE
                               ,p_effective_date           IN     date       default sysdate
                               ,p_prd                      IN     ghr_pa_requests.pay_rate_determinant%TYPE
                               ,p_grade_id                 IN OUT NOCOPY  number
                               ,p_job_id                   IN OUT NOCOPY  number
                               ,p_organization_id          IN OUT NOCOPY  number
                               ,p_location_id              IN OUT NOCOPY  number
                               ,p_pay_plan                    OUT NOCOPY  varchar2
                               ,p_occ_code                    OUT NOCOPY  varchar2
                               ,p_grade_or_level              OUT NOCOPY  varchar2
                               ,p_pay_basis                   OUT NOCOPY  varchar2
                               ,p_position_org_line1          OUT NOCOPY  varchar2
                               ,p_position_org_line2          OUT NOCOPY  varchar2
                               ,p_position_org_line3          OUT NOCOPY  varchar2
                               ,p_position_org_line4          OUT NOCOPY  varchar2
                               ,p_position_org_line5          OUT NOCOPY  varchar2
                               ,p_position_org_line6          OUT NOCOPY  varchar2
                               ,p_duty_station_id             OUT NOCOPY  number
                               ) IS
--
l_business_group_id   hr_all_positions_f.business_group_id%type;
l_pos_ei_grade_data   per_position_extra_info%rowtype;
l_pos_ei_grp1_data    per_position_extra_info%rowtype;

l_pos_organization_id hr_organization_information.organization_id%TYPE;
l_assignment_id       per_all_assignments_f.assignment_id%type;
l_retained_grade          ghr_pay_calc.retained_grade_rec_type;
l_person_id           per_all_assignments_f.person_id%type;
l_prd                 VARCHAR2(30);
l_dummy               VARCHAR2(30);

l_grade_id                   number(15);
l_job_id                     number(15);
l_organization_id            number(15);
l_location_id                number(15);
--
CURSOR cur_ass_id IS
  SELECT assignment_id, person_id
  FROM  per_all_assignments_f
  WHERE position_id = p_position_id
  AND   assignment_type <> 'B'
  AND   primary_flag = 'Y'
  AND   p_effective_date
        between effective_start_date and effective_end_date;
--
--
CURSOR cur_pos_ids IS
  SELECT pos.job_id
        ,pos.business_group_id
        ,pos.organization_id
        ,pos.location_id
  FROM  hr_all_positions_f           pos  -- Venkat -- Position DT
  WHERE pos.position_id = p_position_id
   and p_effective_date between pos.effective_start_date
          and pos.effective_end_date ;
--
CURSOR cur_grd IS
  SELECT gdf.segment1 pay_plan
        ,gdf.segment2 grade_or_level
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id = p_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;
--
CURSOR cur_org (p_org_id number) IS
SELECT oi.org_information5  position_org_line1
      ,oi.org_information6  position_org_line2
      ,oi.org_information7  position_org_line3
      ,oi.org_information8  position_org_line4
      ,oi.org_information9  position_org_line5
      ,oi.org_information10 position_org_line6
FROM  hr_organization_information oi
WHERE oi.organization_id = p_org_id
AND   oi.org_information_context = 'GHR_US_ORG_REPORTING_INFO';

BEGIN

  --Initialisation for NOCOPY Changes

   l_grade_id    := p_grade_id;
   l_job_id      :=p_job_id;
   l_organization_id  :=p_organization_id;
   l_location_id      :=p_location_id;

  -- First lets get all the id's from the position passed in
  -- Note since we are ther already may as well get the pay basis also
  --
  FOR cur_ass_id_rec  IN cur_ass_id  LOOP
    l_assignment_id     := cur_ass_id_rec.assignment_id;
    l_person_id         := cur_ass_id_rec.person_id;
    EXIT;
  END LOOP;
  --

  IF l_assignment_id IS NOT NULL THEN
    ghr_pa_requests_pkg.get_SF52_asg_ddf_details
                     (p_assignment_id         => l_assignment_id
                     ,p_date_effective        => p_effective_date
                     ,p_tenure                => l_dummy
                     ,p_annuitant_indicator   => l_dummy
                     ,p_pay_rate_determinant  => l_prd
                     ,p_work_schedule         => l_dummy
                     ,p_part_time_hours       => l_dummy);
  END IF;
  if p_prd is not null then
      hr_utility.set_location('PRD BEF TO_DATA' || l_prd,1);
      l_prd := p_prd;
      hr_utility.set_location('PRD AFT TO_DATA' || l_prd,2);
  end if;

  FOR cur_pos_ids_rec IN cur_pos_ids LOOP
    p_job_id            := cur_pos_ids_rec.job_id;
    l_business_group_id := cur_pos_ids_rec.business_group_id;
    p_organization_id   := cur_pos_ids_rec.organization_id;
    p_location_id       := cur_pos_ids_rec.location_id;
  END LOOP;
  --
  -- Retive the Grade info and pay basis from the POI history table
  ghr_history_fetch.fetch_positionei(
    p_position_id      => p_position_id,
    p_information_type => 'GHR_US_POS_VALID_GRADE',
    p_date_effective   => p_effective_date,
    p_pos_ei_data      => l_pos_ei_grade_data);

  IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
    p_grade_id   := l_pos_ei_grade_data.poei_information3;
    p_pay_basis  := l_pos_ei_grade_data.poei_information6;
  ELSE
    p_grade_id   := null;
    p_pay_basis  := null;
  END IF;

 IF l_person_id is not null then
  IF l_prd IN ('A','B','E','F','U','V') THEN
    hr_utility.set_location('l_prd is  ' || l_prd,1);
    hr_utility.set_location('l_person_id is  ' || to_char(l_person_id),1);
    hr_utility.set_location('p_position_id is  ' || to_char(p_position_id),1);
    hr_utility.set_location('p_effective_date is  ' || to_char(p_effective_date,'YYYY/MM/DD'),2);
    p_pay_basis := get_upd34_pay_basis (p_person_id        => l_person_id
                             ,p_position_id      => p_position_id
                             ,p_prd              => l_prd
                             ,p_effective_date   => p_effective_date);
  END IF;
 END IF;

  --
  -- OK lets now get pay plan and grade or level for the grade id just retrieved this is in the
  -- Grade Key Flexfield
  --
  IF p_grade_id IS NOT NULL THEN
    FOR cur_grd_rec IN cur_grd LOOP
      p_pay_plan          := cur_grd_rec.pay_plan;
      p_grade_or_level    := cur_grd_rec.grade_or_level;
    END LOOP;
  END IF;
  --
  -- Use function in ghr_api package to get the occ_code, otherwise known as the job occupational_series
  -- It is found in the Job KFF and the Oragnization DDF tells us which segemnt of the KFF it is in
  IF p_job_id IS NOT NULL AND l_business_group_id IS NOT NULL THEN
    p_occ_code := ghr_api.get_job_occ_series_job(p_job_id
                                                ,l_business_group_id);
  END IF;
  --
  -- Retrieve the location details
  --
  --
  -- Retive the Grade info and pay basis from the POI history table
  ghr_history_fetch.fetch_positionei(
    p_position_id      => p_position_id,
    p_information_type => 'GHR_US_POS_GRP1',
    p_date_effective   => p_effective_date,
    p_pos_ei_data      => l_pos_ei_grp1_data);

  IF l_pos_ei_grp1_data.position_extra_info_id IS NOT NULL THEN
    l_pos_organization_id := TO_NUMBER(l_pos_ei_grp1_data.poei_information21);
  ELSE
    l_pos_organization_id := null;
  END IF;
  --
  IF l_pos_organization_id IS NOT NULL THEN
    FOR cur_org_rec IN cur_org (l_pos_organization_id) LOOP
      p_position_org_line1  := cur_org_rec.position_org_line1;
      p_position_org_line2  := cur_org_rec.position_org_line2;
      p_position_org_line3  := cur_org_rec.position_org_line3;
      p_position_org_line4  := cur_org_rec.position_org_line4;
      p_position_org_line5  := cur_org_rec.position_org_line5;
      p_position_org_line6  := cur_org_rec.position_org_line6;
    END LOOP;
  ELSE
    p_position_org_line1  := NULL;
    p_position_org_line2  := NULL;
    p_position_org_line3  := NULL;
    p_position_org_line4  := NULL;
    p_position_org_line5  := NULL;
    p_position_org_line6  := NULL;
  END IF;
  --
  -- Use the procedure already written to get the duty station id for the given location_id
  --
  IF p_location_id IS NOT NULL THEN
    get_SF52_loc_ddf_details (p_location_id
                             ,p_duty_station_id);
  END IF;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
   WHEN others THEN
	p_grade_id            :=l_grade_id;
	p_job_id              :=l_job_id;
	p_organization_id     :=l_organization_id;
	p_location_id         :=l_location_id;
	p_pay_basis           := null;
	p_pay_plan            := NULL;
        p_grade_or_level      := NULL;
	p_duty_station_id     :=NULL;
	p_occ_code            :=NULL;
	p_position_org_line1  := NULL;
        p_position_org_line2  := NULL;
        p_position_org_line3  := NULL;
        p_position_org_line4  := NULL;
        p_position_org_line5  := NULL;
        p_position_org_line6  := NULL;
   RAISE;
  --
END get_SF52_to_data_elements;

-- This procedure only really needs to be called for realignment. For this NOA the 6 'address' lines seen
-- on the to side should come from the 'position organization' on the PAR extra info (if given)
--
PROCEDURE get_rei_org_lines (p_pa_request_id       IN ghr_pa_requests.pa_request_id%TYPE
                            ,p_organization_id     IN OUT NOCOPY  VARCHAR2
                            ,p_position_org_line1  OUT NOCOPY  varchar2
                            ,p_position_org_line2  OUT NOCOPY  varchar2
                            ,p_position_org_line3  OUT NOCOPY  varchar2
                            ,p_position_org_line4  OUT NOCOPY  varchar2
                            ,p_position_org_line5  OUT NOCOPY  varchar2
                            ,p_position_org_line6  OUT NOCOPY  varchar2) IS

l_organization_id        VARCHAR2(150);

CURSOR cur_rei_org IS
  SELECT rei.rei_information8 org_id -- Bug 2681726 Changed information9 to 8 as we need to consider position's org
  FROM   ghr_pa_request_extra_info rei
  WHERE  pa_request_id = p_pa_request_id
  AND    rei.information_type = 'GHR_US_PAR_REALIGNMENT';

CURSOR cur_org (p_org_id number) IS
  SELECT oi.org_information5  position_org_line1
        ,oi.org_information6  position_org_line2
        ,oi.org_information7  position_org_line3
        ,oi.org_information8  position_org_line4
        ,oi.org_information9  position_org_line5
        ,oi.org_information10 position_org_line6
  FROM  hr_organization_information oi
  WHERE oi.organization_id = p_org_id
  AND   oi.org_information_context = 'GHR_US_ORG_REPORTING_INFO';

--l_pos_org_id NUMBER;

BEGIN

   l_organization_id  :=p_organization_id;  --NOCOPY Changes

  FOR cur_rei_org_rec IN cur_rei_org LOOP
    p_organization_id := cur_rei_org_rec.org_id;
  END LOOP;

  IF p_organization_id IS NOT NULL THEN
    FOR cur_org_rec IN cur_org(p_organization_id) LOOP
      p_position_org_line1  := cur_org_rec.position_org_line1;
      p_position_org_line2  := cur_org_rec.position_org_line2;
      p_position_org_line3  := cur_org_rec.position_org_line3;
      p_position_org_line4  := cur_org_rec.position_org_line4;
      p_position_org_line5  := cur_org_rec.position_org_line5;
      p_position_org_line6  := cur_org_rec.position_org_line6;
    END LOOP;
  END IF;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
	p_organization_id  :=l_organization_id;
	p_position_org_line1  := NULL;
        p_position_org_line2  := NULL;
        p_position_org_line3  := NULL;
        p_position_org_line4  := NULL;
        p_position_org_line5  := NULL;
        p_position_org_line6  := NULL;
  RAISE;

END get_rei_org_lines;

FUNCTION segments_defined (p_flexfield_name IN VARCHAR2
                          ,p_context_code   IN VARCHAR2)
  RETURN BOOLEAN IS
  --
CURSOR c_dfc IS
  SELECT 1
  FROM   fnd_descr_flex_contexts dfc
  WHERE  dfc.application_id = 8301
  AND    dfc.descriptive_flexfield_name = p_flexfield_name
  AND    dfc.descriptive_flex_context_code = p_context_code
  AND    dfc.enabled_flag = 'Y';  --to avoid insertion prompts for diabled contexts 5766626

BEGIN
  FOR c_dfc_rec IN c_dfc LOOP
    RETURN (TRUE);
  END LOOP;

  RETURN(FALSE);

END segments_defined;

FUNCTION get_noac_remark_req (p_first_noa_id        IN    ghr_noac_remarks.nature_of_action_id%TYPE
                             ,p_second_noa_id       IN    ghr_noac_remarks.nature_of_action_id%TYPE
                             ,p_remark_id           IN    ghr_noac_remarks.nature_of_action_id%TYPE
                             ,p_effective_date      IN    DATE)
  RETURN VARCHAR2 IS

CURSOR c_ncr IS
  SELECT 1
  FROM   ghr_noac_remarks ncr
  WHERE (ncr.nature_of_action_id = p_first_noa_id
     OR  ncr.nature_of_action_id = p_second_noa_id)
  AND    ncr.remark_id           = p_remark_id
  AND    ncr.required_flag = 'Y'
  AND    NVL(p_effective_date,TRUNC(sysdate))
     BETWEEN ncr.date_from AND NVL(ncr.date_to,NVL(p_effective_date,TRUNC(sysdate)));

BEGIN
  -- We need to know if it is required for either the first noa OR the second
  FOR c_ncr_rec IN c_ncr LOOP
    -- If we got in here then the required flag must be set for at least one of the NOA's given
    RETURN ('Y');
  END LOOP;

  RETURN('N');

END get_noac_remark_req;

FUNCTION get_user_person_id (p_user_name IN VARCHAR2)
  RETURN NUMBER IS
--
l_ret_val NUMBER(9) := NULL;
--
CURSOR c_use IS
  SELECT use.employee_id
  FROM   fnd_user use
  WHERE  use.user_name = p_user_name;

BEGIN
  FOR c_use_rec IN c_use LOOP
    l_ret_val := c_use_rec.employee_id;
  END LOOP;

  RETURN(l_ret_val);

END get_user_person_id;

PROCEDURE get_single_noac_for_fam (p_noa_family_code     IN     ghr_noa_families.noa_family_code%TYPE
                                  ,p_effective_date      IN     DATE
                                  ,p_nature_of_action_id IN OUT NOCOPY  ghr_nature_of_actions.nature_of_action_id%TYPE
                                  ,p_code                IN OUT NOCOPY  ghr_nature_of_actions.code%TYPE
                                  ,p_description         IN OUT NOCOPY  ghr_nature_of_actions.description%TYPE) IS


l_nature_of_action_id   ghr_nature_of_actions.nature_of_action_id%TYPE;
l_code                  ghr_nature_of_actions.code%TYPE;
l_description           ghr_nature_of_actions.description%TYPE;

l_record_found BOOLEAN := FALSE;

CURSOR cur_noa IS
  SELECT noa.nature_of_action_id
        ,noa.code
        ,noa.description
  FROM   ghr_nature_of_actions noa
        ,ghr_noa_families      naf
  WHERE  naf.noa_family_code = p_noa_family_code
  AND    naf.nature_of_action_id = noa.nature_of_action_id
  AND    naf.enabled_flag   = 'Y'
  AND    NVL(p_effective_date,trunc(sysdate))
    BETWEEN NVL(naf.start_date_active,NVL(p_effective_date,trunc(sysdate)))
    AND     NVL(naf.end_date_active,NVL(p_effective_date,trunc(sysdate))) ;

BEGIN

   --Initialisation for NOCOPY Changes

   l_nature_of_action_id := p_nature_of_action_id;
   l_code                := p_code;
   l_description         := p_description;

  FOR cur_noa_rec IN cur_noa LOOP
    IF l_record_found THEN
      p_nature_of_action_id := null;
      p_code                := null;
      p_description         := null;
      EXIT;
    ELSE
      l_record_found := TRUE;
      p_nature_of_action_id := cur_noa_rec.nature_of_action_id;
      p_code                := cur_noa_rec.code;
      p_description         := cur_noa_rec.description;
    END IF;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
	p_nature_of_action_id := l_nature_of_action_id;
	p_code                := l_code;
	p_description         := l_description;
  RAISE;

END get_single_noac_for_fam;


-- This procedure will return the Legal Authority Code and Description if there is only one for the given
-- NOAC, otherwise it returns null
PROCEDURE get_single_lac_for_noac (p_nature_of_action_id IN     ghr_noac_las.nature_of_action_id%TYPE
                                  ,p_effective_date      IN     DATE
                                  ,p_lac_code            IN OUT NOCOPY ghr_noac_las.lac_lookup_code%TYPE
                                  ,p_description         IN OUT NOCOPY VARCHAR2) IS

l_lac_code            ghr_noac_las.lac_lookup_code%TYPE;
l_description         VARCHAR2(240);
--
l_record_found BOOLEAN := FALSE;

CURSOR cur_nla IS
  SELECT hrl.lookup_code
        ,hrl.description
  FROM   hr_lookups   hrl
        ,ghr_noac_las nla
  WHERE  nla.nature_of_action_id = p_nature_of_action_id
  AND    nla.enabled_flag = 'Y'
  AND    nla.valid_first_lac_flag = 'Y'
  AND    NVL(p_effective_date,trunc(sysdate))
    BETWEEN nla.date_from
    AND     NVL(nla.date_to,NVL(p_effective_date,trunc(sysdate)))
  AND    hrl.lookup_code = nla.lac_lookup_code
  AND    hrl.lookup_type = 'GHR_US_LEGAL_AUTHORITY'
  AND    hrl.enabled_flag = 'Y'
  AND    NVL(p_effective_date,trunc(sysdate))
    BETWEEN NVL(hrl.start_date_active,NVL(p_effective_date,trunc(sysdate)))
    AND     NVL(hrl.end_date_active,NVL(p_effective_date,trunc(sysdate)));

BEGIN

  --Initialisation for NOCOPY Changes
  l_lac_code     := p_lac_code;
  l_description  := p_description;

  p_lac_code     := null;
  p_description  := null;
  --
  FOR cur_nla_rec IN cur_nla LOOP
    IF l_record_found THEN
      p_lac_code     := null;
      p_description  := null;
      EXIT;
    ELSE
      l_record_found := TRUE;
      p_lac_code     := cur_nla_rec.lookup_code;
      p_description  := cur_nla_rec.description;
    END IF;
  END LOOP;

EXCEPTION
   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
    p_lac_code     := l_lac_code;
    p_description  := l_description;
  RAISE;

END get_single_lac_for_noac;
--
--
FUNCTION get_restricted_form (p_person_id IN NUMBER)
  RETURN VARCHAR2 IS
--
l_ret_val VARCHAR2(30) := NULL;
--
CURSOR c_pei IS
  SELECT pei.pei_information3 restricted_form
  FROM   per_people_extra_info pei
  WHERE  pei.information_type = 'GHR_US_PER_USER_INFO'
  AND    pei.person_id = p_person_id;

BEGIN
  FOR c_pei_rec IN c_pei LOOP
    l_ret_val := c_pei_rec.restricted_form;
  END LOOP;

  RETURN(l_ret_val);

END get_restricted_form;

--
FUNCTION get_noa_pm_family (p_nature_of_action_id  IN     ghr_noa_families.nature_of_action_id%TYPE)
  RETURN VARCHAR2 IS
--
l_ret_val VARCHAR2(30) := NULL;
--
CURSOR c_naf IS
  SELECT naf.noa_family_code
  FROM   ghr_families     fam
        ,ghr_noa_families naf
  WHERE  fam.noa_family_code = naf.noa_family_code
  AND    naf.nature_of_action_id = p_nature_of_action_id
  AND    fam.proc_method_flag = 'Y';

BEGIN
  FOR c_naf_rec IN c_naf LOOP
    l_ret_val := c_naf_rec.noa_family_code;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_pm_family;

--
--
-- Bug#3941541 Overloaded function with effective date as another parameter
  FUNCTION get_noa_pm_family (p_nature_of_action_id  IN     ghr_noa_families.nature_of_action_id%TYPE,
                              p_effective_date       IN     DATE)
  RETURN VARCHAR2 IS
--
l_ret_val VARCHAR2(30) := NULL;
--
CURSOR c_naf IS
  SELECT naf.noa_family_code
  FROM   ghr_families     fam
        ,ghr_noa_families naf
  WHERE  fam.noa_family_code = naf.noa_family_code
  AND    naf.nature_of_action_id = p_nature_of_action_id
  AND    fam.proc_method_flag = 'Y'
  AND    p_effective_date between NVL(naf.start_date_active,p_effective_date)
                              and NVL(naf.end_date_active,p_effective_date);


BEGIN
  FOR c_naf_rec IN c_naf LOOP
    l_ret_val := c_naf_rec.noa_family_code;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_pm_family;
--

-- As above except pass in a noa code and it returns the family it is in
FUNCTION get_noa_pm_family (p_noa_code  IN     ghr_nature_of_actions.code%TYPE)
  RETURN VARCHAR2 IS
--
l_ret_val VARCHAR2(30) := NULL;
--
CURSOR c_naf IS
  SELECT naf.noa_family_code
  FROM   ghr_families          fam
        ,ghr_noa_families      naf
        ,ghr_nature_of_actions noa
  WHERE  fam.noa_family_code = naf.noa_family_code
  AND    naf.nature_of_action_id = noa.nature_of_action_id
  AND    noa.code = p_noa_code
  AND    fam.proc_method_flag = 'Y';

BEGIN
  FOR c_naf_rec IN c_naf LOOP
    l_ret_val := c_naf_rec.noa_family_code;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_pm_family;
--
-- Given a position_id and a date check to see if anybody has been assigned
-- that position at the date and return 'TRUE' if they have
FUNCTION position_assigned(p_position_id    IN NUMBER
                          ,p_effective_date IN DATE)
  RETURN VARCHAR2 IS
--
l_ret_val VARCHAR2(5) := 'FALSE';
--
CURSOR c_asg IS
  SELECT 1
  FROM   per_all_assignments_f asg
  WHERE  asg.position_id = p_position_id
  AND    NVL(p_effective_date,TRUNC(sysdate))
         BETWEEN asg.effective_start_date AND asg.effective_end_date
  AND    asg.assignment_type NOT IN ('A', 'B');

BEGIN
  FOR c_asg_rec IN c_asg LOOP
    l_ret_val := 'TRUE';
  END LOOP;

  RETURN(l_ret_val);

END position_assigned;

-- This function looks at the AOL table FND_CONCURRENT_PROGRAMS to return the defualt printer for the
-- given concurrent program , Doesn't pass in application ID as 8301 is assumed
FUNCTION get_default_printer (p_concurrent_program_name IN VARCHAR2)
  RETURN VARCHAR2 IS
--
CURSOR c_cop IS
  SELECT cop.printer_name
  FROM   fnd_concurrent_programs cop
  WHERE  cop.application_id = 8301
  AND    cop.concurrent_program_name = p_concurrent_program_name;
  --
  --Note: There is a uinque index on application id and concurrent_program_name
  --
BEGIN
  FOR c_cop_rec IN c_cop LOOP
    RETURN (c_cop_rec.printer_name);
  END LOOP;
  RETURN(NULL);
END get_default_printer;

-- This function returns TRUE if the PA Request passed in has an SF50 produced
FUNCTION SF50_produced (p_pa_request_id IN NUMBER)
  RETURN BOOLEAN IS
--
CURSOR c_par IS
  SELECT 1
  FROM   ghr_pa_requests par
  WHERE  par.pa_request_id = p_pa_request_id
  AND    par.pa_notification_id IS NOT NULL;
--
BEGIN
  FOR c_par_rec IN c_par LOOP
    RETURN (TRUE);
  END LOOP;
  RETURN (FALSE);
END SF50_produced;
--
-- This function returns TRUE if the person id passed in is valid for the given date
-- The noa_family_code determines what is a valid person on the SF52, i.e for APP
-- family they must be Applicant otherwise they must be Employees.
-- The select statements need to be the same as on the SF52 as this is only
-- checking the person is still valid in case the user alters the effective
-- date after they used the LOV in the form to pick up a person!
FUNCTION check_person_id_SF52 (p_person_id              IN NUMBER
                              ,p_effective_date         IN DATE
                              ,p_business_group_id      IN NUMBER
                              ,p_user_person_id         IN NUMBER
                              ,p_noa_family_code        IN VARCHAR2
                              ,p_second_noa_family_code IN VARCHAR2)
RETURN BOOLEAN IS
--
--Bug# 6711759 Included the person type EX_EMP_APL
CURSOR c_per_app IS
  SELECT 1
  FROM   per_person_types  pet
        ,per_people_f      per
  WHERE nvl(p_effective_date,trunc(sysdate)) between per.effective_start_date and per.effective_end_date
  AND   pet.person_type_id = per.person_type_id
  AND   pet.system_person_type in ('APL','EX_EMP','EX_EMP_APL')
  AND   per.business_group_id = p_business_group_id
  AND   per.person_id <> p_user_person_id
  AND   per.person_id = p_person_id;
--
-- Bug 4217510/	4377361 added person type EMP_APL also
CURSOR c_per_emp IS
  SELECT 1
  FROM   per_person_types  pet
        ,per_people_f      per
  WHERE  nvl(p_effective_date,trunc(sysdate)) between per.effective_start_date and per.effective_end_date
  AND    pet.person_type_id = per.person_type_id
  AND    (pet.system_person_type in ('EMP', 'EMP_APL')
    OR    (pet.system_person_type = 'EX_EMP' and p_noa_family_code = 'CONV_APP')
          )
  AND    per.business_group_id = p_business_group_id
  AND    per.person_id <> p_user_person_id
  AND    per.person_id = p_person_id;
--
BEGIN
  -- For cancel and correction families do not need to do the check so just return true
  IF p_noa_family_code IN ('CANCEL', 'CORRECT') THEN
    RETURN (TRUE);
  END IF;

  IF p_noa_family_code = 'APP' THEN
    FOR c_per_app_rec IN c_per_app LOOP
      RETURN (TRUE);
    END LOOP;
  ELSE
    FOR c_per_emp_rec IN c_per_emp LOOP
      RETURN (TRUE);
    END LOOP;
  END IF;
  RETURN (FALSE);

END check_person_id_SF52;
--
  FUNCTION check_valid_person_id (p_person_id              IN NUMBER
                                 ,p_effective_date         IN DATE
                                 ,p_business_group_id      IN NUMBER
                                 ,p_user_person_id         IN NUMBER
                                 ,p_noa_family_code        IN VARCHAR2
                                 ,p_second_noa_family_code IN VARCHAR2)
  RETURN VARCHAR2 IS
--
  l_proc               varchar2(72)  := 'check_valid_person_id';
  l_ret_val            VARCHAR2(5)   := 'FALSE';
--
CURSOR c_per_app IS
  SELECT 1
  FROM   per_person_types  pet
        ,per_people_f      per
  WHERE nvl(p_effective_date,trunc(sysdate)) between per.effective_start_date and per.effective_end_date
  AND   pet.person_type_id = per.person_type_id
  AND   pet.system_person_type in ('APL','EX_EMP')
  AND   per.business_group_id = p_business_group_id
  AND   per.person_id <> p_user_person_id
  AND   per.person_id = p_person_id;
--
-- Bug 4217510/4377361 added person type EMP_APL also
CURSOR c_per_emp IS
  SELECT 1
  FROM   per_person_types  pet
        ,per_people_f      per
  WHERE  nvl(p_effective_date,trunc(sysdate)) between per.effective_start_date and per.effective_end_date
  AND    pet.person_type_id = per.person_type_id
  AND    (pet.system_person_type in ('EMP', 'EMP_APL')
    OR    (pet.system_person_type = 'EX_EMP' and p_noa_family_code = 'CONV_APP')
          )
  AND    per.business_group_id = p_business_group_id
  AND    per.person_id <> p_user_person_id
  AND    per.person_id = p_person_id;
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc,5);
  -- For cancel and correction families do not need to do the check so just return true
  IF p_noa_family_code IN ('CANCEL', 'CORRECT') THEN
    l_ret_val := 'TRUE';
    hr_utility.set_location('Valid person for CORRECT or CANCEL ' ,6);
  END IF;

  IF p_noa_family_code = 'APP' THEN
--

    hr_utility.set_location( ' Input parameters for check person ',7);
    hr_utility.set_location( ' p_person_id              = '|| to_char(p_person_id),7);
    hr_utility.set_location( ' p_effective_date         = '|| to_char(p_effective_date,'DD-MON-YYYY'),7);
    hr_utility.set_location( ' p_business_group_id      = '|| to_char(p_business_group_id),7);
    hr_utility.set_location( ' p_user_person_id         = '|| to_char(p_user_person_id),7);
    hr_utility.set_location( ' p_noa_family_code        = '|| p_noa_family_code,7);
    hr_utility.set_location( ' p_second_noa_family_code = '|| p_second_noa_family_code,7);
--
    FOR c_per_app_rec IN c_per_app LOOP
      l_ret_val := 'TRUE';
    hr_utility.set_location('Valid person from c_per_app        ' ,8);
    END LOOP;
  ELSE
    FOR c_per_emp_rec IN c_per_emp LOOP
      l_ret_val := 'TRUE';
    hr_utility.set_location('Valid person from c_per_emp        ' ,8);
    END LOOP;
  END IF;
  if l_ret_val = 'FALSE' then
     hr_utility.set_location('Invalid person                       ' ,9);
  end if;
  hr_utility.set_location('Leaving ' || l_proc,10);
  RETURN(l_ret_val);

END check_valid_person_id;
--

PROCEDURE get_corr_other_pay(p_pa_request_id               IN  ghr_pa_requests.pa_request_id%TYPE
                            ,p_noa_code                    IN  ghr_nature_of_actions.code%TYPE
                            ,p_to_basic_pay                OUT NOCOPY  NUMBER
                            ,p_to_adj_basic_pay            OUT NOCOPY  NUMBER
                            ,p_to_auo_ppi                  OUT NOCOPY  VARCHAR2
                            ,p_to_auo                      OUT NOCOPY  NUMBER
                            ,p_to_ap_ppi                   OUT NOCOPY  VARCHAR2
                            ,p_to_ap                       OUT NOCOPY  NUMBER
                            ,p_to_retention_allowance      OUT NOCOPY  NUMBER
                            ,p_to_supervisory_differential OUT NOCOPY  NUMBER
                            ,p_to_staffing_differential    OUT NOCOPY  NUMBER
                            ,p_to_pay_basis                OUT NOCOPY  VARCHAR2
-- Corr Warn
                            ,p_pay_rate_determinant        OUT NOCOPY  VARCHAR2
                            ,p_pay_plan                    OUT NOCOPY  VARCHAR2
                            ,p_to_position_id              OUT NOCOPY  NUMBER
                            ,p_person_id                   OUT NOCOPY  NUMBER
                            ,p_locality_adj                OUT NOCOPY  NUMBER
-- Corr Warn
                            ) IS
--
---   ghr_pay_caps.do_pay_caps_main
---                (p_effective_date       =>    l_effective_date
---                ,p_pay_rate_determinant =>    :par.pay_rate_determinant  --
---                ,p_pay_plan             =>    :par.to_pay_plan    --
---                ,p_to_position_id       =>    :par.to_position_id    --
---                ,p_pay_basis            =>    :par.to_pay_basis
---                ,p_person_id            =>    :par.person_id    --
---                ,p_basic_pay            =>    :par.to_basic_pay
---                ,p_locality_adj         =>    :par.to_locality_adj    --
---                ,p_adj_basic_pay        =>    :par.to_adj_basic_pay
---                ,p_total_salary         =>    :par.to_total_salary
---                ,p_other_pay_amount     =>    :par.to_other_pay_amount
---                ,p_au_overtime          =>    :par.to_au_overtime
---                ,p_availability_pay     =>    :par.to_availability_pay
---                ,p_open_pay_fields      =>    l_open_pay_fields_caps
---                ,p_message_set          =>    l_message_set_caps);
---
---
l_ghr_pa_request_rec ghr_pa_requests%ROWTYPE;
BEGIN
  ghr_corr_canc_SF52.build_corrected_SF52(p_pa_request_id    => p_pa_request_id
                                         ,p_noa_code_correct => p_noa_code
                                         ,p_sf52_data_result => l_ghr_pa_request_rec);
  --
  p_to_basic_pay                := l_ghr_pa_request_rec.to_basic_pay;
  p_to_adj_basic_pay            := l_ghr_pa_request_rec.to_adj_basic_pay;
  p_to_auo_ppi                  := l_ghr_pa_request_rec.to_auo_premium_pay_indicator;
  p_to_auo                      := l_ghr_pa_request_rec.to_au_overtime;
  p_to_ap_ppi                   := l_ghr_pa_request_rec.to_ap_premium_pay_indicator;
  p_to_ap                       := l_ghr_pa_request_rec.to_availability_pay;
  p_to_retention_allowance      := l_ghr_pa_request_rec.to_retention_allowance;
  p_to_supervisory_differential := l_ghr_pa_request_rec.to_supervisory_differential;
  p_to_staffing_differential    := l_ghr_pa_request_rec.to_staffing_differential;
  p_to_pay_basis                := l_ghr_pa_request_rec.to_pay_basis;
-- Corr Warn
  p_pay_rate_determinant        := l_ghr_pa_request_rec.pay_rate_determinant;
  p_pay_plan                    := l_ghr_pa_request_rec.to_pay_plan;
  p_to_position_id              := l_ghr_pa_request_rec.to_position_id;
  p_person_id                   := l_ghr_pa_request_rec.person_id;
  p_locality_adj                := l_ghr_pa_request_rec.to_locality_adj;
-- Corr Warn
EXCEPTION

   -- Reset IN OUT parameters and set OUT parameters

  WHEN others THEN
   p_to_basic_pay                := NULL;
   p_to_adj_basic_pay            := NULL;
   p_to_auo_ppi                  := NULL;
   p_to_auo                      := NULL;
   p_to_ap_ppi                   := NULL;
   p_to_ap                       := NULL;
   p_to_retention_allowance      := NULL;
   p_to_supervisory_differential := NULL;
   p_to_staffing_differential    := NULL;
   p_to_pay_basis                := NULL;
   p_pay_rate_determinant        := NULL;
   p_pay_plan                    := NULL;
   p_to_position_id              := NULL;
   p_person_id                   := NULL;
   p_locality_adj                := NULL;
  RAISE;


 END get_corr_other_pay;

PROCEDURE get_corr_rpa_other_pay(p_pa_request_id        IN  ghr_pa_requests.pa_request_id%TYPE
                            ,p_noa_code                    IN  ghr_nature_of_actions.code%TYPE
                            ,p_from_basic_pay              OUT NOCOPY  NUMBER
                            ,p_to_basic_pay                OUT NOCOPY  NUMBER
                            ,p_to_adj_basic_pay            OUT NOCOPY  NUMBER
                            ,p_to_auo_ppi                  OUT NOCOPY  VARCHAR2
                            ,p_to_auo                      OUT NOCOPY  NUMBER
                            ,p_to_ap_ppi                   OUT NOCOPY  VARCHAR2
                            ,p_to_ap                       OUT NOCOPY  NUMBER
                            ,p_to_retention_allowance      OUT NOCOPY  NUMBER
                            ,p_to_supervisory_differential OUT NOCOPY  NUMBER
                            ,p_to_staffing_differential    OUT NOCOPY  NUMBER
                            ,p_to_pay_basis                OUT NOCOPY  VARCHAR2
-- Corr Warn
                            ,p_pay_rate_determinant        OUT NOCOPY  VARCHAR2
                            ,p_pay_plan                    OUT NOCOPY  VARCHAR2
                            ,p_to_position_id              OUT NOCOPY  NUMBER
                            ,p_person_id                   OUT NOCOPY  NUMBER
                            ,p_locality_adj                OUT NOCOPY  NUMBER
                            ,p_from_step_or_rate           OUT NOCOPY  VARCHAR2
                            ,p_to_step_or_rate             OUT NOCOPY  VARCHAR2
-- Corr Warn
                            ) IS
l_ghr_pa_request_rec ghr_pa_requests%ROWTYPE;
BEGIN
  ghr_corr_canc_SF52.build_corrected_SF52(p_pa_request_id    => p_pa_request_id
                                         ,p_noa_code_correct => p_noa_code
                                         ,p_sf52_data_result => l_ghr_pa_request_rec);
  --
  p_from_basic_pay              := l_ghr_pa_request_rec.from_basic_pay;
  p_to_basic_pay                := l_ghr_pa_request_rec.to_basic_pay;
  p_to_adj_basic_pay            := l_ghr_pa_request_rec.to_adj_basic_pay;
  p_to_auo_ppi                  := l_ghr_pa_request_rec.to_auo_premium_pay_indicator;
  p_to_auo                      := l_ghr_pa_request_rec.to_au_overtime;
  p_to_ap_ppi                   := l_ghr_pa_request_rec.to_ap_premium_pay_indicator;
  p_to_ap                       := l_ghr_pa_request_rec.to_availability_pay;
  p_to_retention_allowance      := l_ghr_pa_request_rec.to_retention_allowance;
  p_to_supervisory_differential := l_ghr_pa_request_rec.to_supervisory_differential;
  p_to_staffing_differential    := l_ghr_pa_request_rec.to_staffing_differential;
  p_to_pay_basis                := l_ghr_pa_request_rec.to_pay_basis;
-- Corr Warn
  p_pay_rate_determinant        := l_ghr_pa_request_rec.pay_rate_determinant;
  p_pay_plan                    := l_ghr_pa_request_rec.to_pay_plan;
  p_to_position_id              := l_ghr_pa_request_rec.to_position_id;
  p_person_id                   := l_ghr_pa_request_rec.person_id;
  p_locality_adj                := l_ghr_pa_request_rec.to_locality_adj;
  p_from_step_or_rate           := l_ghr_pa_request_rec.from_step_or_rate;
  p_to_step_or_rate             := l_ghr_pa_request_rec.to_step_or_rate;
-- Corr Warn
EXCEPTION

   -- Reset IN OUT parameters and set OUT parameters
  WHEN others THEN
   p_from_basic_pay              := NULL;
   p_to_basic_pay                := NULL;
   p_to_adj_basic_pay            := NULL;
   p_to_auo_ppi                  := NULL;
   p_to_auo                      := NULL;
   p_to_ap_ppi                   := NULL;
   p_to_ap                       := NULL;
   p_to_retention_allowance      := NULL;
   p_to_supervisory_differential := NULL;
   p_to_staffing_differential    := NULL;
   p_to_pay_basis                := NULL;
   p_pay_rate_determinant        := NULL;
   p_pay_plan                    := NULL;
   p_to_position_id              := NULL;
   p_person_id                   := NULL;
   p_locality_adj                := NULL;
   p_from_step_or_rate           := NULL;
   p_to_step_or_rate             := NULL;
  RAISE;

END get_corr_rpa_other_pay;

--
-- This procedure gets the amounts that are not displayed in a correction form that
-- are needed to do an award
PROCEDURE get_corr_award (p_pa_request_id     IN  ghr_pa_requests.pa_request_id%TYPE
                         ,p_noa_code          IN  ghr_nature_of_actions.code%TYPE
                         ,p_from_basic_pay    OUT NOCOPY NUMBER
                         ,p_from_pay_basis    OUT NOCOPY VARCHAR2
                         ) IS
--
l_ghr_pa_request_rec ghr_pa_requests%ROWTYPE;
BEGIN
  ghr_corr_canc_SF52.build_corrected_SF52(p_pa_request_id    => p_pa_request_id
                                         ,p_noa_code_correct => p_noa_code
                                         ,p_sf52_data_result => l_ghr_pa_request_rec);
  --
  p_from_basic_pay  := l_ghr_pa_request_rec.from_basic_pay;
  p_from_pay_basis  := l_ghr_pa_request_rec.from_pay_basis;

EXCEPTION

   -- Reset IN OUT parameters and set OUT parameters

  WHEN others THEN
   p_from_basic_pay  := NULL;
   p_from_pay_basis  := NULL;
  RAISE;

END get_corr_award;
--
FUNCTION get_position_work_title(p_position_id        in    number,
                                  p_effective_date  in    date default trunc(sysdate)
                                ) RETURN varchar2  IS


l_proc               varchar2(72)  := 'get_position_work_title';
l_pos_ei_data        per_position_extra_info%rowtype;
l_title              varchar2(150);


BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);

    ghr_history_fetch.fetch_positionei
    (p_position_id           =>   p_position_id     ,
     p_information_type      =>   'GHR_US_POS_GRP1' ,
     p_date_effective        =>   p_effective_date  ,
     p_pos_ei_data           =>   l_pos_ei_data
     );
     l_title    :=   l_pos_ei_data.poei_information12;

  return(l_title);

 hr_utility.set_location('Leaving   ' || l_proc,25);
End get_position_work_title;


FUNCTION get_position_work_title(p_person_id        in    varchar2,
                                  p_effective_date  in    date default trunc(sysdate)
                                ) RETURN varchar2  IS


l_proc               varchar2(72)  := 'get_position_work_title';
l_position_id        hr_all_positions_f.position_id%type;
l_pos_ei_data        per_position_extra_info%rowtype;
l_title              varchar2(150);

CURSOR      c_per_pos is
  SELECT    asg.position_id
  FROM      Per_assignments_f asg
  WHERE     asg.person_id   =  p_person_id
  AND       trunc(nvl(p_effective_date,sysdate))
            between asg.effective_start_date and asg.effective_end_date
  AND       asg.assignment_type <> 'B'
  AND       asg.primary_flag = 'Y';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);

 -- Get the person's Position (for his primary Assignment).

  for per_pos_id in C_per_pos loop
    hr_utility.set_location(l_proc,10);
    l_position_id  :=  per_pos_id.position_id;
  end loop;


  If l_position_id is not null then
    hr_utility.set_location(l_proc,15);
    ghr_history_fetch.fetch_positionei
    (p_position_id           =>   l_position_id     ,
     p_information_type      =>   'GHR_US_POS_GRP1' ,
     p_date_effective        =>   p_effective_date  ,
     p_pos_ei_data           =>   l_pos_ei_data
     );
     l_title    :=   l_pos_ei_data.poei_information12;
  End if;
  return(l_title);
 hr_utility.set_location('Leaving   ' || l_proc,25);
End get_position_work_title;


-- Function that returns fullname in the format (fml) i.e <First_name>  <Middle_name>.<Last Name>
FUNCTION get_full_name_fml(p_person_id       in    varchar2,
                           p_effective_date  in    date  default trunc(sysdate)
                          ) RETURN varchar2 IS

l_proc          varchar2(72)  :=  'get_person_full_name';
l_name          per_people_f.full_name%type;

CURSOR     c_full_name is
  SELECT   per.first_name ||  decode(per.middle_names,null,null, ' ' ||substr(per.middle_names,1,1)  || '.')  || ' ' ||per.last_name full_name
  FROM     per_people_f per
  WHERE    per.person_id   =  p_person_id
  AND      trunc(nvl(p_effective_date,sysdate))between per.effective_start_date and per.effective_end_date;


BEGIN
  hr_utility.set_location('Entering  ' || l_proc,5);
  for full_name in c_full_name loop
    hr_utility.set_location(l_proc,10);
    l_name   :=  substr(full_name.full_name,1,240);
  End loop;

  hr_utility.set_location('Leaving  ' || l_proc,15);
  return(l_name);
END get_full_name_fml;

FUNCTION get_upd34_pay_basis (p_person_id        IN    per_people_f.person_id%TYPE
                             ,p_position_id      IN    per_positions.position_id%type
                             ,p_prd              IN    ghr_pa_requests.pay_rate_determinant%TYPE
                             ,p_noa_code         IN    varchar2 DEFAULT NULL
                             ,p_pa_request_id    IN    NUMBER DEFAULT NULL
                             ,p_effective_date   IN    DATE)
  RETURN VARCHAR2 IS
l_retained_grade          ghr_pay_calc.retained_grade_rec_type;
l_update34_date           DATE;
l_pos_ei_grade_data   per_position_extra_info%rowtype;
BEGIN
    hr_utility.set_location('Entering get_upd34_pay_basis',10);
 begin
  l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (p_person_id
                                                                ,p_effective_date
                                                                ,p_pa_request_id);
EXCEPTION
  when others then
    hr_utility.set_location('Exception raised ' || sqlerrm(sqlcode),15);
  hr_utility.set_message(8301,'GHR_38255_MISSING_RETAINED_DET');
  hr_utility.raise_error;
  end;

  IF p_prd IN ('A','B','E','F')
     AND nvl(p_noa_code,'XXX') <> '740'
     AND l_retained_grade.temp_step IS NOT NULL THEN
     hr_utility.set_location('get from  positionei ',1);
    ghr_history_fetch.fetch_positionei(
      p_position_id      => p_position_id,
      p_information_type => 'GHR_US_POS_VALID_GRADE',
      p_date_effective   => p_effective_date,
      p_pos_ei_data      => l_pos_ei_grade_data);

    IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
       RETURN(l_pos_ei_grade_data.poei_information6);
    END IF;
  END IF;

l_update34_date := ghr_pay_caps.update34_implemented_date(p_person_id);
hr_utility.set_location('l_update34_date ' ||  l_update34_date,1);
If l_update34_date is null then
   hr_utility.set_location('update  34 is null',1);
   RETURN(l_retained_grade.pay_basis);
elsif p_effective_date >= l_update34_date then
   hr_utility.set_location('update  34 isnot   null and  effective_date is   ',1);
   RETURN(l_retained_grade.pay_basis);
else
   hr_utility.set_location('get from  positionei ',1);
  ghr_history_fetch.fetch_positionei(
    p_position_id      => p_position_id,
    p_information_type => 'GHR_US_POS_VALID_GRADE',
    p_date_effective   => p_effective_date,
    p_pos_ei_data      => l_pos_ei_grade_data);

  IF l_pos_ei_grade_data.position_extra_info_id IS NOT NULL THEN
     RETURN(l_pos_ei_grade_data.poei_information6);
  ELSE
     RETURN(null);
  END IF;
end if;

END get_upd34_pay_basis;

PROCEDURE update34_implement_cancel (p_person_id       IN NUMBER
                                    ,p_assignment_id   IN NUMBER
                                    ,p_date            IN DATE
                                    ,p_altered_pa_request_id in  NUMBER)
IS

l_effective_date        DATE;
l_update34_date         DATE;
l_per_ei_data           per_people_extra_info%rowtype;
l_person_extra_info_id  NUMBER;
l_object_version_number NUMBER;

l_tenure                VARCHAR2(150);
l_annuitant_indicator   VARCHAR2(150);
l_pay_rate_determinant  VARCHAR2(150);
l_work_schedule         VARCHAR2(150);
l_part_time_hours       VARCHAR2(150);
l_altered_pa_request_id NUMBER;
l_exists                BOOLEAN := false;
l_del_flag              varchar2(1);
l_upd_flag              varchar2(1);

CURSOR c_par is
   select par.effective_date effective_date,
          par.pa_request_id
   from   ghr_pa_requests par
   where  par.person_id = p_person_id
   and    par.effective_date >= p_date
   and    par.pa_notification_id is not null
   and    par.first_noa_code <> '001'
   and    par.pa_request_id <> nvl(p_altered_pa_request_id,par.pa_request_id)
   and    nvl(par.first_noa_cancel_or_correct,hr_api.g_varchar2) <> 'CANCEL'
   and    ((par.second_noa_code is null)
            or (par.second_noa_code is not null
               and  nvl(par.second_noa_cancel_or_correct,hr_api.g_varchar2) <> 'CANCEL'))
   order  by par.effective_date ,par.pa_request_id ;


/*CURSOR c_par IS
  SELECT par.effective_date effective_date
         ,par.altered_pa_request_id
  FROM   ghr_pa_routing_history prh
        ,ghr_pa_requests        par
  WHERE  par.person_id      = p_person_id
  AND    par.effective_date >= p_date
  AND    prh.pa_request_id  = par.pa_request_id
  AND    prh.pa_routing_history_id = (SELECT MAX(prh2.pa_routing_history_id)
                                      FROM   ghr_pa_routing_history prh2
                                      WHERE  prh2.pa_request_id = par.pa_request_id)
  AND    prh.action_taken IN ('FUTURE_ACTION','UPDATE_HR_COMPLETE')
  AND    par.NOA_FAMILY_CODE != 'CANCEL'
  AND (   ( par.second_noa_code IS NULL
        AND NVL(par.first_noa_cancel_or_correct,'X') != 'CANCEL'
          )
     OR  (  par.second_noa_code IS NOT NULL
        AND  par.NOA_FAMILY_CODE != 'CORRECT'
        AND ( NVL(par.first_noa_cancel_or_correct,'X') != 'CANCEL'
          OR NVL(par.second_noa_cancel_or_correct,'X') != 'CANCEL'
            )
         )
     OR  (  par.second_noa_code IS NOT NULL
        AND  par.NOA_FAMILY_CODE = 'CORRECT'
        AND  NVL(par.second_noa_cancel_or_correct,'X') != 'CANCEL'
         )
       )
  ORDER BY par.effective_date, par.pa_request_id;
*/

BEGIN

     for c_par_rec in c_par
     loop
         l_exists  :=  TRUE;
         l_effective_date := c_par_rec.effective_date;
         hr_utility.set_location('p_rpa'  ||  c_par_rec.pa_request_id,1);
         exit;
     end loop;

     l_update34_date := ghr_pay_caps.update34_implemented_date(p_person_id);

     If p_date = nvl(l_update34_date,hr_api.g_date) then
       If not l_exists then
          hr_utility.set_location('Not exists',1);
            l_effective_date := NULL;
            l_del_flag       := 'Y';
        Else
            hr_utility.set_location('Exists',1);
           if l_effective_date <> p_date then
             l_upd_flag := 'Y';
           end if;
        End if;

        ghr_history_fetch.fetch_peopleei
                     (p_person_id             => p_person_id
                     ,p_information_type      => 'GHR_US_PER_UPDATE34'
                     ,p_date_effective        => p_date
                     ,p_per_ei_data           => l_per_ei_data);

        l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
        l_object_version_number := l_per_ei_data.object_version_number;
        if l_person_extra_info_id is not null then
           hr_utility.set_location('PEID Exists',1);
           if l_del_flag = 'Y' then
             delete per_people_extra_info
             where person_extra_info_id = l_person_extra_info_id;

             delete from ghr_pa_history
             where table_name = 'PER_PEOPLE_EXTRA_INFO'
             and   information1 = l_person_extra_info_id;

           end if;

           if l_upd_flag = 'Y' then
             delete from ghr_pa_history
             where table_name = 'PER_PEOPLE_EXTRA_INFO'
             and   to_number(information4) = p_person_id
             and   information5            = 'GHR_US_PER_UPDATE34'
             and   pa_request_id = l_altered_pa_request_id ;

             ghr_person_extra_info_api.update_person_extra_info
             (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
             ,P_EFFECTIVE_DATE         => l_effective_date
             ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
             ,P_PEI_ATTRIBUTE_CATEGORY => 'GHR_US_PER_UPDATE34'
             ,p_pei_INFORMATION3       => fnd_date.date_to_canonical(l_effective_date)
             ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_UPDATE34'
             );
           end if;
         end if;
     end if;

END update34_implement_cancel;

FUNCTION temp_step_true (p_pa_request_id IN ghr_pa_requests.pa_request_id%type)
RETURN BOOLEAN IS

l_noa_code                  ghr_nature_of_actions.code%type;
l_temp_step                 VARCHAR2(60);

CURSOR cur_par IS
SELECT first_noa_code,second_noa_code
FROM ghr_pa_requests
WHERE pa_request_id = p_pa_request_id;

CURSOR cur_temp_step IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';

BEGIN
  ------- Start Temp Promotion Code changes for 703 and 866 NOACs.
  l_noa_code  := null;
  l_temp_step := null;
  IF p_pa_request_id is not null THEN
     FOR cur_par_rec IN cur_par LOOP
         if cur_par_rec.first_noa_code = '002' then
            l_noa_code := cur_par_rec.second_noa_code;
         else
            l_noa_code := cur_par_rec.first_noa_code;
         end if;
     EXIT;
     END LOOP;
     IF l_noa_code in ('703','866') THEN
        FOR cur_temp_step_rec IN cur_temp_step LOOP
            l_temp_step  := cur_temp_step_rec.temp_step;
        END LOOP;
     END IF;
  END IF;
  -------End  Temp Promotion Code changes for 703 and 866 NOACs.
  IF l_temp_step is not null THEN
     RETURN(TRUE);
  ELSE
    RETURN(FALSE);
  END IF;
END temp_step_true;


END ghr_pa_requests_pkg;

/
