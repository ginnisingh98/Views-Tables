--------------------------------------------------------
--  DDL for Package PQH_TCT_WIZARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCT_WIZARD_PKG" AUTHID CURRENT_USER as
/* $Header: pqtctwiz.pkh 120.1 2005/10/12 20:20:17 srajakum noship $ */
--
type warnings_rec is record(message_text fnd_new_messages.message_text%type);

type warnings_tab is table of warnings_rec index by binary_integer;
--
-----------------------------------------------------------------------------
--
-- This function checks if standard setup is already complete for the
-- transaction category and returns TRUE  if standard setup is complete .
-- It returns FALSE  if standard setup has not yet been done.
--
Function  chk_if_setup_finish(p_transaction_category_id  in   number,
                              p_setup_type               out nocopy varchar2)
Return Boolean;

--
-----------------------------------------------------------------------------
--
Function generate_rule_name
Return Varchar2;
--
-----------------------------------------------------------------------------
--
PROCEDURE create_default_hierarchy
(  p_validate                       in boolean    default false
  ,p_routing_category_id            out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id               in  number    default null
  ,p_override_user_id               in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
);

--
-----------------------------------------------------------------------------
--
PROCEDURE update_default_hierarchy
(
   p_validate                       in  boolean    default false
  ,p_old_routing_category_id        in  number
  ,p_routing_category_id            in out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id               in  number    default null
  ,p_override_user_id               in  number    default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
);

--
-----------------------------------------------------------------------------
--
PROCEDURE create_default_approver
(
   p_validate                       in boolean    default false
  ,p_attribute_range_id             out nocopy number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in out nocopy  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
);

--
-----------------------------------------------------------------------------
--
PROCEDURE update_default_approver
(
   p_validate                       in  boolean   default false
  ,p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
);
--
--------------------------------------------------------------------------
--
PROCEDURE delete_default_approver
(
   p_validate                       in boolean    default false
  ,p_attribute_range_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
);
--
--
-----------------------------------------------------------------------------
--
PROCEDURE select_routing_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number) ;
--
--
PROCEDURE unselect_routing_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number);
--
--
PROCEDURE select_authorization_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number);
--
--
PROCEDURE unselect_auth_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number) ;
--
--
PROCEDURE Refresh_routing_rules(p_transaction_category_id     in     number);
--
--
PROCEDURE Refresh_authorization_rules(p_transaction_category_id in number);
--
--
PROCEDURE disable_rout_hier_if_no_attr(p_transaction_category_id in number);
--
--
FUNCTION chk_rules_exist (p_routing_category_id in number)
RETURN BOOLEAN;
--
--
FUNCTION chk_routing_history_exists (p_routing_category_id in number)
RETURN BOOLEAN;
--
PROCEDURE get_all_attribute_range_id(p_routing_category_id    in   number,
                                     p_range_name             in   varchar2,
                                     p_rule_type              in   varchar2,
                                     p_all_attribute_range_id out nocopy  varchar2);
--
PROCEDURE create_routing_rule(p_transaction_category_id in number,
                              p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_delete_flag            in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_all_attribute_range_id out nocopy  varchar2);
--
--
PROCEDURE update_routing_rule(p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_approver_flag          in   varchar2 default NULL,
                              p_delete_flag            in   varchar2 default NULL,
                              p_all_attribute_range_id in   varchar2);
--
--
PROCEDURE delete_routing_rule(p_routing_category_id    in   number,
                              p_all_attribute_range_id in   varchar2);
--
--
PROCEDURE create_approver (  p_transaction_category_id in number,
                              p_routing_category_id    in   number,
                              p_routing_list_member_id in   number,
                              p_position_id            in   number,
                              p_assignment_id          in   number,
                              p_approver_flag          in   varchar2,
                              p_gen_sys_rule_name     out nocopy   varchar2);
--
--
PROCEDURE update_approver  (p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number,
                            p_approver_flag          in   varchar2 );
--
--
PROCEDURE delete_approver  (p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number );
--
--
PROCEDURE create_authorization_rule (
                              p_transaction_category_id in  number,
                              p_routing_category_id    in   number,
                              p_routing_list_member_id in   number,
                              p_position_id            in   number,
                              p_assignment_id          in   number,
                              p_approver_flag          in   varchar2,
                              p_delete_flag            in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_range_name             in   varchar2,
                              p_all_attribute_range_id out nocopy  varchar2);
--
--
PROCEDURE update_authorization_rule
                             (p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_approver_flag          in   varchar2 default NULL,
                              p_delete_flag            in   varchar2 default NULL,
                              p_all_attribute_range_id in   varchar2) ;
--
--
PROCEDURE delete_authorization_rule (p_routing_category_id    in   number,
                                     p_all_attribute_range_id in   varchar2);
-----------------------------------------------------------------------------
PROCEDURE create_local_setup(p_transaction_category_id in  out nocopy NUMBER,
                             p_language                in  varchar2,
                             p_business_group_id       in  number);
-----------------------------------------------------------------------------
PROCEDURE freeze_category (p_transaction_category_id       in   number,
                           p_setup_type_cd                 in   varchar2,
                           p_freeze_status_cd              in   varchar2);
----------------------------------------------------------------------------
FUNCTION  chk_range_name_unique (p_routing_category_id  in number,
                                 p_range_name           in varchar2,
                                 p_attribute_id_list    in varchar2,
                                 p_primary_flag         in varchar2)
RETURN BOOLEAN ;
--
-- --------------------------------------------------------------------------
--

PROCEDURE load_row (
					 p_canvas_name          in varchar2,
					 p_form_name            in varchar2,
					 p_current_item         in varchar2,
					 p_previous_item        in varchar2,
					 p_next_item            in varchar2,
					 p_enable_finish_flag   in varchar2,
					 p_post_flag            in varchar2,
					 p_seq_no               in number,
					 p_finish_item          in varchar2,
					 p_refresh_msg_flag     in varchar2,
					 p_image_name           in varchar2,
					 p_warning_item         in varchar2,
					 p_image_item           in varchar2,
					 p_line_size            in number,
					 p_owner	        in varchar2,
                                         p_last_update_date     in varchar2 ) ;

--
Function check_errors_in_std_setup(p_transaction_category_id  in  number,
                                   p_error_messages          out nocopy  warnings_tab)
RETURN boolean;
--
FUNCTION check_errors_in_adv_setup(p_transaction_category_id in number,
                                   p_error_messages          out nocopy  warnings_tab)
RETURN boolean;
--
FUNCTION check_if_adv_setup_started(p_transaction_category_id in number)
RETURN BOOLEAN;
--
Function chk_valid_rout_hier_exists(p_transaction_category_id     in number,
                                    p_routing_type                in varchar2,
                                    p_error_messages             out nocopy warnings_tab,
                                    p_no_errors                  out nocopy varchar2)
RETURN BOOLEAN ;
--
------------------------------------------------------------------------
FUNCTION chk_mem_overlap_on_freeze(
          p_transaction_category_id in number,
          p_routing_type            in varchar2,
          p_routing_category_id     in number default NULL,
          p_error_routing_cat       out nocopy varchar2,
          p_member_name             out nocopy varchar2,
          p_overlap_range_1         out nocopy varchar2,
          p_overlap_range_2         out nocopy varchar2)
--
RETURN BOOLEAN;
--
------------------------------------------------------------------------
Procedure delete_hierarchy_and_rules(p_transaction_category_id  in  number,
                                     p_routing_style            in  varchar2);
--
------------------------------------------------------------------------
FUNCTION return_approver_status(p_routing_category_id   in  number,
                                p_approver_id           in  number,
                                p_routing_style         in  varchar2)
RETURN varchar2;
--
------------------------------------------------------------------------
PROCEDURE update_approver_flag(p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number,
                            p_approver_flag          in   varchar2 );
------------------------------------------------------------------------
FUNCTION return_person_name(p_assignment_id   in  number)
RETURN varchar2;
--
END;

 

/
