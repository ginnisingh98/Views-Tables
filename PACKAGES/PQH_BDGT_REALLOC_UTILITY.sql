--------------------------------------------------------
--  DDL for Package PQH_BDGT_REALLOC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_REALLOC_UTILITY" AUTHID CURRENT_USER as
/* $Header: pqbreutl.pkh 120.2 2006/02/03 14:15:33 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
FUNCTION get_entity_name
(
 p_entity_id              IN    pqh_bdgt_pool_realloctions.entity_id%TYPE,
 p_entity_type            IN    pqh_budget_pools.entity_type%TYPE
) RETURN  VARCHAR;
--
FUNCTION GET_PRD_REALLOC_RESERVED_AMT
(
 p_budget_period_id       IN    pqh_budget_periods.budget_period_id%TYPE  Default NULL,
 p_budget_unit_id         IN    pqh_budgets.budget_unit1_id%TYPE,
 p_transaction_type       IN   pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD',
 p_approval_status        IN    varchar2,
 p_amount_type            IN    varchar2,
 p_entity_type            IN    varchar2,
 p_entity_id              IN    number DEFAULT NULL,
 p_start_date             IN    date default null,
 p_end_date               IN    date default null

) RETURN  NUMBER;

FUNCTION GET_TRNX_LEVEL_TRANS_AMT
(
 p_transaction_id         IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_txn_amt_balance_flag    IN    varchar2
) RETURN  NUMBER;

FUNCTION GET_FOLDER_LEVEL_TRANS_AMT
(
 p_folder_id             IN    pqh_budget_pools.pool_id%TYPE
) RETURN  NUMBER;

FUNCTION GET_DTL_REALLOC_RESERVED_AMT
(
 p_budget_detail_id       IN    pqh_budget_details.budget_detail_id%TYPE default null,
 p_budget_unit_id         IN    pqh_budgets.budget_unit1_id%TYPE,
 p_transaction_type       IN    pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD',
 p_approval_status        IN    varchar2,
 p_amount_type            IN    varchar2,
 p_entity_type  IN varchar2,
 p_entity_id              IN    number default null,
 p_start_date             IN    date  default null,
 p_end_date               IN    date default null

)
RETURN  NUMBER;

FUNCTION GET_TRNX_DNR_REVR_COUNT
(
 p_transaction_id             IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_transaction_type       IN    pqh_bdgt_pool_realloctions.transaction_type%TYPE
) RETURN  NUMBER;
PROCEDURE CHK_RECV_EXISTS
(
	p_trans_id	IN	pqh_bdgt_pool_realloctions.pool_id%TYPE,
	p_entity_id	IN	pqh_bdgt_pool_realloctions.entity_id%TYPE,
	p_detail_id	OUT NOCOPY	pqh_bdgt_pool_realloctions.reallocation_id%TYPE
);
FUNCTION CHK_APPROVED_FOLDER
(
 p_budget_version_id      IN    pqh_budget_pools.budget_version_id%TYPE,
 p_budget_unit_id                IN    pqh_budget_pools.budget_unit_id%TYPE,
 p_entity_type            IN    pqh_budget_pools.entity_type%TYPE,
 p_approval_status        IN    pqh_budget_pools.approval_status%Type) RETURN  NUMBER;
FUNCTION GET_TRNX_LEVEL_RESERVED_AMT
(
 p_transaction_id         IN    pqh_bdgt_pool_realloctions.reallocation_id%TYPE,
 p_transaction_type       IN    pqh_bdgt_pool_realloctions.transaction_type%TYPE DEFAULT 'DD'
) RETURN  NUMBER;
FUNCTION GET_LOCATION_CODE
(
 p_entity_code		IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_organization_id	IN    pqh_budget_details.organization_id%TYPE,
 p_business_group_id    IN    hr_organization_units_v.business_group_id%TYPE
) RETURN  VARCHAR;

PROCEDURE APP_NEXT_USER
(p_trans_id              in pqh_routing_history.transaction_id%type,
p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
p_cur_user_id           in out nocopy fnd_user.user_id%type,
p_cur_user_name         in out nocopy fnd_user.user_name%type,
p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
p_user_active_role_name in out nocopy pqh_roles.role_name%type,
p_routing_category_id      out nocopy pqh_routing_categories.routing_category_id%type,
p_member_cd                out nocopy pqh_transaction_categories.member_cd%type,
p_routing_list_id          out nocopy pqh_routing_lists.routing_list_id%type,
p_member_role_id           out nocopy pqh_roles.role_id%type,
p_member_user_id           out nocopy fnd_user.user_id%type,
p_person_id                out nocopy fnd_user.employee_id%type,
p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
p_position_id              out nocopy pqh_position_transactions.position_id%type,
p_cur_person_id            out nocopy fnd_user.employee_id%type,
p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
p_cur_position_id          out nocopy pqh_position_transactions.position_id%type,
p_pos_str_ver_id           out nocopy pqh_routing_history.pos_structure_version_id%type,
p_assignment_id            out nocopy per_assignments_f.assignment_id%type,
p_cur_assignment_id        out nocopy per_assignments_f.assignment_id%type,
p_next_user                out nocopy varchar2,
p_next_user_display        out nocopy varchar2,
p_status_flag              out nocopy number,
p_can_approve              out nocopy number);
procedure get_next_user(p_member_cd           in pqh_transaction_categories.member_cd%type,
			p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                        p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
			p_trans_id            in pqh_routing_history.transaction_id%type,
			p_cur_assignment_id   in per_assignments_f.assignment_id%type,
			p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
			p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
			p_cur_position_id     in pqh_position_transactions.position_id%type,
			p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
			p_next_position_id       out nocopy pqh_position_transactions.position_id%type,
			p_next_member_id         out nocopy pqh_routing_list_members.routing_list_member_id%type,
                        p_next_role_id           out nocopy number,
                        p_next_user_id           out nocopy number,
			p_next_assignment_id     out nocopy per_assignments_f.assignment_id%type,
			p_status_flag            out nocopy number,
                        p_next_user              out nocopy varchar2,
                        p_next_user_display      out nocopy varchar2) ;
PROCEDURE FND_NEXT_USER
(
p_member_cd                IN pqh_transaction_categories.member_cd%type,
p_position_id              IN pqh_position_transactions.position_id%type,
p_assignment_id            IN per_assignments_f.assignment_id%type,
p_member_role_id           IN pqh_roles.role_id%type,
p_member_user_id           IN fnd_user.user_id%type,
p_next_name		  OUT NOCOPY VARCHAR,
p_next_name_display	  OUT NOCOPY VARCHAR
);
-- ----------------------------------------------------------------------------
-- |------------------------< apply_transaction >------------------------|
-- ----------------------------------------------------------------------------

function apply_transaction
(  p_transaction_id    in  NUMBER,
   p_validate_only              in varchar2 default 'NO'
) return varchar2;
-- ----------------------------------------------------------------------------
-- |------------------------< reject_transaction >------------------------|
-- ----------------------------------------------------------------------------

function reject_transaction
(  p_transaction_id    in  NUMBER,
   p_validate_only     in varchar2 default 'NO'
) return varchar2;
--------------------------------------------------------------------------------
FUNCTION entity_id
( p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE,
p_entity_type    IN pqh_budgets.budgeted_entity_cd%TYPE
)RETURN NUMBER;
--------------------------------------------------------------------------------

FUNCTION respond_notification( p_transaction_id in number) RETURN varchar2 ;
FUNCTION warning_notification( p_transaction_id in number) RETURN varchar2 ;
FUNCTION reject_notification( p_transaction_id in number) RETURN varchar2 ;
FUNCTION apply_notification( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------
FUNCTION url_builder(p_transaction_id in number) RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |------------------------< notify_bgt_manager_users >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE notify_bgt_manager_users
(
 p_transaction_id number,
 p_transaction_name varchar2
) ;

-- ----------------------------------------------------------------------------
-- |----------------------------< fyi_notification >---------------------------|
-- ----------------------------------------------------------------------------

FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |-------------------< update_folder_approval_status >----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE update_folder_approval_status(p_transaction_id in number, p_action_flag in varchar2);

-- ----------------------------------------------------------------------------
-- |----------------------< bgt_dummy_folder_delete >--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE bgt_dummy_folder_delete(p_business_group_id IN number);

-- ----------------------------------------------------------------------------
-- |----------------------< chk_bpr_route_catg_exist >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_bpr_route_catg_exist(p_business_group_id IN Number,
                                   p_status  OUT nocopy varchar2);

-- ----------------------------------------------------------------------------
-- |----------------------< bpr_process_user_action >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE  bpr_process_user_action(
             	  p_transaction_id                IN  NUMBER
	         ,p_transaction_category_id       IN  NUMBER
	         ,p_route_to_user                 IN  VARCHAR2
	         ,p_routing_category_id           IN  NUMBER
	         ,p_pos_structure_version_id      IN  NUMBER
	         ,p_user_action_cd                IN  VARCHAR2
	         ,p_forwarded_to_user_id          IN  NUMBER
	         ,p_forwarded_to_role_id          IN  NUMBER
	         ,p_forwarded_to_position_id      IN  NUMBER
	         ,p_forwarded_to_assignment_id    IN  NUMBER
	         ,p_forwarded_to_member_id        IN  NUMBER
	         ,p_forwarded_by_user_id          IN  NUMBER
	         ,p_forwarded_by_role_id          IN  NUMBER
	         ,p_forwarded_by_position_id      IN  NUMBER
	         ,p_forwarded_by_assignment_id    IN  NUMBER
	         ,p_forwarded_by_member_id        IN  NUMBER
	         ,p_effective_date                IN  DATE
	         ,p_approval_cd                   IN  VARCHAR2
	         ,p_member_cd                     In  VARCHAR2
	         ,p_transaction_name              IN  VARCHAR2
	         ,p_apply_error_mesg              OUT NOCOPY VARCHAR2
       		 ,p_apply_error_num               OUT NOCOPY NUMBER
       		 ,p_warning_mesg                  OUT NOCOPY VARCHAR2
       		 );

-- ----------------------------------------------------------------------------
-- |----------------------< check_approver_skip >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_approver_skip(p_transaction_category_id IN NUMBER)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |----------------------< valid_user_opening >-------------------------------|
-- | Wrapper on top of pqh_workflow.valid_user_openingto allow multi messaging |
-- ----------------------------------------------------------------------------

procedure valid_user_opening(p_business_group_id           in number    default null,
                             p_short_name                  in varchar2  ,
                             p_transaction_id              in number    default null,
                             p_routing_history_id          in number    default null,
                             p_wf_transaction_category_id     out nocopy number,
                             p_glb_transaction_category_id    out nocopy number,
                             p_role_id                        out nocopy number,
                             p_role_template_id               out nocopy number,
                             p_status_flag                    out nocopy varchar2) ;

-- ----------------------------------------------------------------------------
-- |------------------------< get_folder_unit >-------------------------------|
-- | Function to return Folder Unit Desciption for Bdgt_Unit_Id. Bug #3027076.|
-- ----------------------------------------------------------------------------
FUNCTION get_folder_unit (p_budget_unit_id IN NUMBER)
RETURN  VARCHAR2;

End pqh_bdgt_realloc_utility;

 

/
