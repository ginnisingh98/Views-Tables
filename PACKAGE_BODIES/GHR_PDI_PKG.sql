--------------------------------------------------------
--  DDL for Package Body GHR_PDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_PKG" AS
/* $Header: ghrwspdi.pkb 120.0.12010000.2 2009/05/26 10:57:38 vmididho noship $ */


PROCEDURE get_last_routing_list(p_position_description_id     IN     ghr_position_descriptions.position_description_id%TYPE
                           ,p_routing_list_id      OUT NOCOPY ghr_routing_lists.routing_list_id%TYPE
                           ,p_routing_list_name    OUT NOCOPY ghr_routing_lists.name%TYPE
                           ,p_next_seq_number      OUT NOCOPY ghr_routing_list_members.seq_number%TYPE
                           ,p_next_user_name       OUT NOCOPY ghr_routing_list_members.user_name%TYPE
                           ,p_next_groupbox_id     OUT NOCOPY ghr_routing_list_members.groupbox_id%TYPE
                           ,p_broken            IN OUT NOCOPY BOOLEAN) IS

CURSOR cur_pdh_last_rli IS
  SELECT rli.routing_list_id
        ,rli.name
        ,pdh.routing_seq_number
        ,pdh.pd_routing_history_id
  FROM   ghr_routing_lists      rli
        ,ghr_pd_routing_history pdh
  WHERE  pdh.position_description_id = p_position_description_id
  AND    pdh.routing_list_id = rli.routing_list_id
  ORDER BY pdh.pd_routing_history_id DESC;

-- The order by makes sure the first one we get is the last in the history
-- By joing to routing_list forces us to have a routing_list (since we didn't doan outer join)


-- Just get the last record so we can see if the cursor above got us the last record


CURSOR cur_pdh_last IS
  SELECT pdh.pd_routing_history_id
  FROM   ghr_pd_routing_history  pdh
  WHERE  pdh.position_description_id = p_position_description_id
  ORDER BY pdh.pd_routing_history_id DESC;
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
  -- Go and get the last routing list to be used
  FOR cur_pdh_last_rli_rec IN cur_pdh_last_rli LOOP
    p_routing_list_id   := cur_pdh_last_rli_rec.routing_list_id;
    p_routing_list_name := cur_pdh_last_rli_rec.name;
    -- See if the routing list has been broken
    FOR cur_pdh_last_rec IN cur_pdh_last LOOP
      IF cur_pdh_last_rec.pd_routing_history_id = cur_pdh_last_rli_rec.pd_routing_history_id THEN


        p_broken := FALSE;
      ELSE
        p_broken := TRUE;
      END IF;
      EXIT;  -- Only want the first record therfore exit after we have got it
    END LOOP;
    -- If it is not broken then get the next sequence in the routing list
    --
    IF NOT p_broken THEN
      FOR cur_rlm_rec IN cur_rlm(cur_pdh_last_rli_rec.routing_list_id, cur_pdh_last_rli_rec.routing_seq_number)  LOOP


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
END get_last_routing_list;


PROCEDURE get_roles (p_position_description_id     in number
                    ,p_routing_group_id  in number
                    ,p_user_name         in varchar2 default null
                    ,p_initiator_flag    in out NOCOPY varchar2
                    ,p_requester_flag    in out NOCOPY varchar2
                    ,p_authorizer_flag   in out NOCOPY varchar2
                    ,p_personnelist_flag in out NOCOPY varchar2
                    ,p_approver_flag     in out NOCOPY varchar2
                    ,p_reviewer_flag     in out NOCOPY varchar2) IS

l_groupbox_id       ghr_pd_routing_history.groupbox_id%TYPE;
l_user_name         ghr_pd_routing_history.user_name%TYPE;

CURSOR cur_gp_user IS
  select pdh.groupbox_id
        ,pdh.user_name
  from   ghr_pd_routing_history pdh
  where  pdh.position_description_id = p_position_description_id
  order by pdh.pd_routing_history_id desc;

CURSOR cur_first_user IS
  select pdh.groupbox_id
  from   ghr_pd_routing_history pdh
  where  pdh.position_description_id = p_position_description_id
  and    pdh.user_name = l_user_name
  and    pdh.groupbox_id is not NULL
  and    not exists (select 1
                     from   ghr_pd_routing_history pdh2
                     where  pdh2.position_description_id = p_position_description_id
                     and    pdh2.user_name <> l_user_name
                     and    pdh2.pd_routing_history_id > pdh.pd_routing_history_id)
  order by pdh.pd_routing_history_id asc;

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
        ,gru.authorizer_flag
        ,gru.personnelist_flag
        ,gru.approver_flag
        ,gru.reviewer_flag
	,gru.requester_flag
  from   ghr_groupbox_users gru
  where  gru.groupbox_id = l_groupbox_id
  and    gru.user_name   = p_user_name;

BEGIN
  -- First get the last history record for given position_description_id
  FOR c_rec in cur_gp_user LOOP
    l_groupbox_id      := c_rec.groupbox_id;
    l_user_name        := c_rec.user_name;
    EXIT;
  END LOOP;

  -- If it is for a group box then definitely use the group box roles and that is it!
  IF l_groupbox_id is not null THEN
    FOR C_rec in cur_gpbox_user_roles LOOP
      p_initiator_flag    := c_rec.initiator_flag;
      p_authorizer_flag   := c_rec.authorizer_flag;
      p_personnelist_flag := c_rec.personnelist_flag;
      p_approver_flag     := c_rec.approver_flag;
      p_reviewer_flag     := c_rec.reviewer_flag;
      p_requester_flag    := c_rec.requester_flag;
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
        p_authorizer_flag   := c_rec.authorizer_flag;
        p_personnelist_flag := c_rec.personnelist_flag;
        p_approver_flag     := c_rec.approver_flag;
        p_reviewer_flag     := c_rec.reviewer_flag;
	p_requester_flag    := c_rec.requester_flag;
        EXIT;
      END LOOP;
    ELSE
      -- definitely get the user roles
      FOR c_rec in cur_user_roles LOOP
        p_initiator_flag    := c_rec.initiator_flag;
        p_authorizer_flag   := c_rec.authorizer_flag;
        p_personnelist_flag := c_rec.personnelist_flag;
        p_approver_flag     := c_rec.approver_flag;
        p_reviewer_flag     := c_rec.reviewer_flag;
        p_requester_flag    := c_rec.requester_flag;
      END LOOP;
    END IF;
  END IF;

END get_roles;

END ghr_pdi_pkg;

/
