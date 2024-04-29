--------------------------------------------------------
--  DDL for Package PER_SSHR_CHANGE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSHR_CHANGE_PAY" AUTHID CURRENT_USER as
/* $Header: pepypshr.pkh 120.14.12010000.2 2010/01/12 10:39:17 vkodedal ship $ */
--
--
Procedure get_pay_transaction
 (p_item_type                    in varchar2,
  p_item_key                     in varchar2,
  p_activity_id                  in number,
  p_login_person_id              in number,
  p_api_name                     in varchar2,
  p_effective_date_option        in varchar2 default null,
  p_transaction_id              out nocopy number,
  p_transaction_step_id         out nocopy number,
  p_update_mode                 out nocopy boolean);
--
Procedure get_transaction_step
 (p_item_type                    in varchar2,
  p_item_key                     in varchar2,
  p_activity_id                  in number,
  p_login_person_id              in number,
  p_api_name                     in varchar2,
  p_transaction_id              out nocopy number,
  p_transaction_step_id         out nocopy number,
  p_update_mode                 out nocopy varchar2,
  p_effective_date_option        in varchar2);
--
Procedure process_pay_api(
  p_validate                    in varchar2,
  p_transaction_step_id         in number,
  p_effective_date              in date default null,
  p_new_hire_flag               in varchar2 default null,
  p_item_key                    in varchar2 default null,
  p_item_type                   in varchar2 default null,
  p_assignment_id               in varchar2 default null);
--
Procedure process_api(
  p_validate                    in boolean default false,
  p_transaction_step_id         in number,
  p_effective_date              in varchar2 default null);
--
PROCEDURE delete_transaction(p_assgn_id IN number,
                             p_effective_dt IN date,
                             p_transaction_id IN number,
                             p_transaction_step_id      IN number,
                             p_item_key IN varchar2,
                             p_item_type IN varchar2,
                             p_next_change_date in date,
                             p_changedt_curr IN date,
                             p_changedt_last IN date default Null,
                             p_failed_to_delete IN OUT NOCOPY varchar2,
                             p_busgroup_id      IN number);
--
Function update_component_transaction(
  p_pay_transaction_id  Number,
  p_ASSIGNMENT_ID  Number,
  p_change_date  date,
  p_prior_proposed_salary  Number default NUll,
  p_prior_proposal_id Number      default NUll,
  p_prior_transaction_id Number   default NUll,
  p_prior_pay_basis_id Number     default NUll,
  p_update_prior varchar2         default 'N',
  p_xchg_rate in Number
) return Number;
--
Procedure update_transaction(
  p_assgn_id IN number,
  p_transaction_id IN Number,
  p_changedate_curr IN date,
  p_last_change_date IN date,
  p_busgroup_id      IN number);
--
procedure rollback_transactions(p_assignment_id in Number,
                                p_item_type in varchar2,
                                p_item_key      in varchar2,
                                p_status  OUT NOCOPY varchar2);
--
PROCEDURE check_Salary_Basis_Change
        ( p_assignment_id in NUMBER
        , p_effective_date in DATE
        , p_item_key in varchar2
        , p_allow_change_date out NOCOPY varchar2
        , p_allow_basis_change out NOCOPY varchar2);
--
PROCEDURE create_salary_basis_chg_step
 (p_item_type                   in varchar2 ,
  p_item_key                    in varchar2 ,
  p_activity_id                 in number ,
  P_ASSIGNMENT_ID               IN NUMBER ,
  P_PAY_BASIS_ID                IN NUMBER ,
  P_DATETRACK_UPDATE_MODE       IN VARCHAR2 ,
  P_EFFECTIVE_DATE              IN DATE ,
  P_EFFECTIVE_DATE_OPTION       IN VARCHAR2 ,
  P_LOGIN_PERSON_ID             IN NUMBER ,
  P_APPROVER_ID                 IN NUMBER   default null,
  P_SAVE_MODE                   IN VARCHAR2 default null) ;
--
PROCEDURE get_create_date(p_assignment_id in NUMBER
                       ,p_effective_date in date
                       ,p_transaction_id in NUMBER
                       ,p_create_date out NOCOPY date
                       ,p_default_salary_basis_id out NOCOPY number
                       ,p_allow_basis_change out NOCOPY varchar2
                       ,p_min_create_date out NOCOPY date
                       ,p_allow_date_change out NOCOPY varchar2
                       ,p_allow_create out NOCOPY varchar2
                       ,p_status out NOCOPY NUMBER
                       ,p_basis_default_date out NOCOPY date
                       ,p_basis_default_min_date out NOCOPY date
                       ,p_orig_salary_basis_id out NOCOPY number);
--
PROCEDURE get_update_param
        ( p_assignment_id in Number
    	, p_transaction_id in Number
	    , p_current_date in Date
        , p_previous_date in Date
	    , p_proposal_exists in Varchar2
        , p_allow_basis_change out NOCOPY varchar2
        , p_min_update_date out NOCOPY date
        , p_allow_date_change out NOCOPY varchar2
	    , p_status out NOCOPY Number
	    , p_basis_default_date out NOCOPY date
	    , p_basis_default_min_date out NOCOPY date
        , p_orig_basis_id out NOCOPY Number);
--
Procedure get_Create_Date_old(p_assignment_id in NUMBER
                        ,p_effective_date in date
                        ,p_transaction_id in NUMBER
						,p_create_date out NOCOPY date
						,p_default_salary_basis_id out NOCOPY number
						,p_allow_basis_change out NOCOPY varchar2
                        ,p_min_create_date out NOCOPY date
                        ,p_allow_date_change out NOCOPY varchar2
                        ,p_allow_create out NOCOPY varchar2);

----12-Jan-2009 vkodedal Bug#9023204 added new proc process_new_hire
procedure process_new_hire(
  p_transaction_step_id         in number,
  p_item_key                    in varchar2 default null,
  p_item_type                   in varchar2 default null);
--
Function get_payroll_period(p_payroll_id in NUMBER)
RETURN VARCHAR2;
--
FUNCTION get_comp_flex(p_dff_name in varchar2)
return VARCHAR2;
--
FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE
                       ,p_transaction_id IN NUMBER)
return NUMBER;
--
function Check_GSP_Manual_Override(p_assignment_id in NUMBER
                                   ,p_effective_date in DATE
                                   ,p_transaction_id in NUMBER)
RETURN VARCHAR2;
--
--
END;

/
