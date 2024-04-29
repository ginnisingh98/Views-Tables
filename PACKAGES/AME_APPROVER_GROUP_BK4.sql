--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_BK4" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_approver_group_config_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_approver_group_config_b
                            (p_approval_group_id    in number
                            ,p_application_id       in number
                            ,p_voting_regime        in varchar2
                            ,p_order_number         in number
                            );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_approver_group_config_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_approver_group_config_a
                        (p_approval_group_id      in  number
                        ,p_application_id         in  number
                        ,p_voting_regime          in  varchar2
                        ,p_order_number           in  number
                        ,p_object_version_number  in  number
                        ,p_start_date             in  date
                        ,p_end_date               in  date
                        );
--
end ame_approver_group_bk4;

/
