--------------------------------------------------------
--  DDL for Package GHR_PDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDI_PKG" AUTHID CURRENT_USER AS
/* $Header: ghrwspdi.pkh 120.0.12010000.3 2009/05/26 12:08:45 utokachi noship $ */

PROCEDURE get_last_routing_list(p_position_description_id  IN ghr_position_descriptions.position_description_id%TYPE
                                 ,p_routing_list_id      OUT NOCOPY ghr_routing_lists.routing_list_id%TYPE
                                 ,p_routing_list_name    OUT NOCOPY ghr_routing_lists.name%TYPE
                                 ,p_next_seq_number      OUT NOCOPY ghr_routing_list_members.seq_number%TYPE
                                 ,p_next_user_name       OUT NOCOPY ghr_routing_list_members.user_name%TYPE
                                 ,p_next_groupbox_id     OUT NOCOPY ghr_routing_list_members.groupbox_id%TYPE
                                 ,p_broken            IN OUT NOCOPY BOOLEAN);

PROCEDURE get_roles (p_position_description_id     in number
                      ,p_routing_group_id  in number
                      ,p_user_name         in varchar2 default null
                      ,p_initiator_flag    in out NOCOPY varchar2
                      ,p_requester_flag    in out NOCOPY varchar2
                      ,p_authorizer_flag   in out NOCOPY varchar2
                      ,p_personnelist_flag in out NOCOPY varchar2
                      ,p_approver_flag     in out NOCOPY varchar2
                      ,p_reviewer_flag     in out NOCOPY varchar2);
END;

/
