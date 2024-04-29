--------------------------------------------------------
--  DDL for Package HR_PAY_RATE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_RATE_SS" AUTHID CURRENT_USER as
/* $Header: hrpaywrs.pkh 120.3.12010000.4 2009/08/18 09:01:28 gpurohit ship $*/


-- 05/14/2002 - Bug 2374140 Fix Begins
-- ------------------------------------------------------------------------
-- |------------------ < check_mid_pay_period_change > --------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if a mid pay period change was performed when a salary basis
--  was changed.  If yes, we need to set the WF item attribute
--  HR_MID_PAY_PERIOD_CHANGE ='Y' so that a notification will be sent to the
--  Payroll Contact.
--
--  This procedure is invoked by the WF HR_CHK_SAL_BASIS_MID_PAY_PERIOD process.
-- ------------------------------------------------------------------------
--
procedure check_mid_pay_period_change
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result         out nocopy varchar2 );

-- 05/14/2002 - Bug 2374140 Fix Ends

    /*===============================================================
  | Procedure: check_asg_txn_data
  | Function: This is a cover routine invoked by Java.
  |================================================================
  */
  PROCEDURE check_asg_txn_data
             (p_item_type                        in     varchar2
             ,p_item_key                         in     varchar2
             ,p_act_id                           in     number
             ,p_effective_date                   in     date
             ,p_assignment_id                    in     number
             ,p_asg_txn_step_id                  in out nocopy number
             ,p_get_defaults_date                in out nocopy date
             ,p_business_group_id                   out nocopy number
             ,p_currency                            out nocopy varchar2
             ,p_format_string                       out nocopy varchar2
             ,p_salary_basis_name                   out nocopy varchar2
             ,p_pay_basis_name                      out nocopy varchar2
             ,p_pay_basis                           out nocopy varchar2
             ,p_grade_basis                           out nocopy varchar2
             ,p_pay_annualization_factor            out nocopy number
             ,p_fte_factor            		out nocopy number
             ,p_grade                               out nocopy varchar2
             ,p_grade_annualization_factor          out nocopy number
             ,p_minimum_salary                      out nocopy number
             ,p_maximum_salary                      out nocopy number
             ,p_midpoint_salary                     out nocopy number
             ,p_prev_salary                         out nocopy number
             ,p_last_change_date                    out nocopy date
             ,p_element_entry_id                    out nocopy number
             ,p_basis_changed                       out nocopy number
             ,p_uom                                 out nocopy varchar2
             ,p_grade_uom                           out nocopy varchar2
             ,p_change_amount                       out nocopy number
             ,p_change_percent                      out nocopy number
             ,p_quartile                            out nocopy number
             ,p_comparatio                          out nocopy number
             ,p_last_pay_change                     out nocopy varchar2
             ,p_flsa_status                         out nocopy varchar2
             ,p_currency_symbol                     out nocopy varchar2
             ,p_precision                           out nocopy number
             ,p_excep_message                       out nocopy varchar2
             ,p_pay_proposal_id                     out nocopy number
             ,p_current_salary                      out nocopy number
             ,p_proposal_ovn                        out nocopy number
             ,p_api_mode                            out nocopy varchar2
             ,p_warning_message                     out nocopy varchar2
             ,p_new_pay_basis_id                    out nocopy number
             ,p_old_pay_basis_id                    out nocopy number
             ,p_old_pay_annualization_factor        out nocopy number
             ,p_old_fte_factor                      out nocopy number
             ,p_old_salary_basis_name               out nocopy varchar2
             ,p_salary_basis_change_type            out nocopy varchar2
             ,p_flow_mode                           in out nocopy  varchar2 -- 2355929
             ,p_element_type_id_changed             out nocopy varchar2
             ,p_old_currency_code                   out nocopy varchar2
             ,p_old_currency_symbol                 out nocopy varchar2
             ,p_old_pay_basis                       out nocopy varchar2 --4002387
             ,p_old_to_new_currency_rate            out nocopy number   --4002387
             ,p_offered_salary	            out nocopy number
             ,p_proc_sel_txn	                 in varchar2 default null
           );

   -- GSP changes
  /*===============================================================
  | Procedure: check_asg_txn_data_gsp
  | Function: This is a cover routine invoked by Java.
  |================================================================
  */
  PROCEDURE check_gsp_asg_txn_data
             (p_item_type                        in     varchar2
             ,p_item_key                         in     varchar2
             ,p_act_id                           in     number
             ,p_effective_date                   in     date
             ,p_assignment_id                    in     number

             ,p_asg_txn_step_id                  in  number
             ,p_get_defaults_date                in  date
             ,p_excep_message                       out nocopy varchar2
             ,p_flow_mode                           in  varchar2 -- 2355929
           );

  PROCEDURE MY_GET_DEFAULTS(p_assignment_id IN NUMBER
                        ,p_job_id             IN NUMBER
                        ,p_date               IN OUT NOCOPY DATE
                        ,p_business_group_id     OUT NOCOPY NUMBER
                        ,p_currency              OUT NOCOPY VARCHAR2
                        ,p_format_string         OUT NOCOPY VARCHAR2
                        ,p_salary_basis_name     OUT NOCOPY VARCHAR2
                        ,p_pay_basis_name        OUT NOCOPY VARCHAR2
                        ,p_pay_basis             OUT NOCOPY VARCHAR2
                        ,p_grade_basis             OUT NOCOPY VARCHAR2
                        ,p_pay_annualization_factor OUT NOCOPY NUMBER
                        ,p_fte_factor 		 OUT NOCOPY NUMBER
                        ,p_grade                 OUT NOCOPY VARCHAR2
                        ,p_grade_annualization_factor OUT NOCOPY NUMBER
                        ,p_minimum_salary        OUT NOCOPY NUMBER
                        ,p_maximum_salary        OUT NOCOPY NUMBER
                        ,p_midpoint_salary       OUT NOCOPY NUMBER
                        ,p_prev_salary           OUT NOCOPY NUMBER
                        ,p_last_change_date      OUT NOCOPY DATE
                        ,p_element_entry_id      OUT NOCOPY NUMBER
                        ,p_basis_changed         OUT NOCOPY number
                        ,p_uom                   OUT NOCOPY VARCHAR2
                        ,p_grade_uom             OUT NOCOPY VARCHAR2
                         ,p_change_amount                out nocopy number
                        ,p_change_percent               out nocopy number
                        , p_quartile                     out nocopy number
                        , p_comparatio                   out nocopy number
                        , p_last_pay_change              out nocopy varchar2
                        , p_flsa_status                  out nocopy varchar2
                        , p_currency_symbol              out nocopy varchar2
                        , p_precision                    out nocopy number);

  -------------------------------------------------
  -- Function
  -- get_rate_type
  --
  --
  -- Purpose
  --
  --  Returns the rate type given the business group, effective date and
  --  processing type
  --
  --  Returns NULL if no type found
  --
  --  Current processing types are:-
  --			              P - Payroll Processing
  --                                  R - General HRMS reporting
  --				      I - Business Intelligence System
  --
  -- History
  --  22/01/99	wkerr.uk	Created
  --
  --  Argumnents
  --  p_business_group_id	The business group
  --  p_conversion_date		The date for which to return the rate type
  --  p_processing_type		The processing type of which to return the rate
  --
  FUNCTION get_rate_type (
		p_business_group_id	NUMBER,
		p_conversion_date	DATE,
		p_processing_type	VARCHAR2 ) RETURN VARCHAR2;
  --
   --PRAGMA   RESTRICT_REFERENCES(get_rate_type,WNDS);
  --
 ------------------------------------------------------------------------


-- Function
  --   get_rate
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and rate type.
  --
  -- History
  --   22-Apr-98     wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_rate_type		Rate Type
  --
  FUNCTION get_rate (
		p_from_currency		VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_rate_type		VARCHAR2) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate,WNDS,WNPS);




-- Function
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and rate type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  -- History
  --   22-Apr-98      wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   p_rate_type		Rate Type
  --
  FUNCTION convert_amount (
		p_from_currency		VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_amount		NUMBER,
		p_rate_type		VARCHAR2) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_amount,WNDS,WNPS);

    -- define a type for salary proposal record
    TYPE lrt_salary_proposal is RECORD (
      pay_proposal_id       NUMBER,
      assignment_id         NUMBER,
      business_group_id     NUMBER,
      effective_date        DATE,
      comments              LONG,
      next_sal_review_date  DATE,
      salary_change_amount  NUMBER ,
      salary_change_percent NUMBER ,
      annual_change         NUMBER ,
      proposed_salary       NUMBER ,
      proposed_percent      NUMBER ,
      proposal_reason       VARCHAR2(30),
      ranking               NUMBER,
      current_salary        NUMBER,
      performance_review_id NUMBER,
      multiple_components   VARCHAR2(1),
      element_entry_id      NUMBER ,
      selection_mode        VARCHAR2(1),
      ovn                   NUMBER,
      currency              VARCHAR2(15),
      pay_basis_name        VARCHAR2(80),
      annual_equivalent     NUMBER ,
      total_percent        NUMBER ,
      quartile              NUMBER ,
      comparatio            NUMBER ,
      lv_selection_mode     VARCHAR2(1),
      attribute_category           VARCHAR2(150),
      attribute1            VARCHAR2(150),
      attribute2            VARCHAR2(150),
      attribute3            VARCHAR2(150),
      attribute4            VARCHAR2(150),
      attribute5            VARCHAR2(150),
      attribute6            VARCHAR2(150),
      attribute7            VARCHAR2(150),
      attribute8            VARCHAR2(150),
      attribute9            VARCHAR2(150),
      attribute10           VARCHAR2(150),
      attribute11           VARCHAR2(150),
      attribute12           VARCHAR2(150),
      attribute13           VARCHAR2(150),
      attribute14           VARCHAR2(150),
      attribute15           VARCHAR2(150),
      attribute16           VARCHAR2(150),
      attribute17           VARCHAR2(150),
      attribute18           VARCHAR2(150),
      attribute19           VARCHAR2(150),
      attribute20           VARCHAR2(150),
      no_of_components      NUMBER,
      salary_basis_change_type varchar2(30));


    -- define a type for salary component records
    TYPE lrt_salary_component is RECORD (
      component_id          NUMBER ,
      pay_proposal_id       NUMBER ,
      approved              VARCHAR2(30),
      component_reason      VARCHAR2(30),
      reason_meaning        VARCHAR2(80),
      change_amount         VARCHAR2(30) ,
      change_percent        NUMBER ,
      change_annual          NUMBER ,
      comments               VARCHAR2(2000),
      ovn                   NUMBER ,
      attribute_category    VARCHAR2(30),
      attribute1            VARCHAR2(150),
      attribute2            VARCHAR2(150),
      attribute3            VARCHAR2(150),
      attribute4            VARCHAR2(150),
      attribute5            VARCHAR2(150),
      attribute6            VARCHAR2(150),
      attribute7            VARCHAR2(150),
      attribute8            VARCHAR2(150),
      attribute9            VARCHAR2(150),
      attribute10           VARCHAR2(150),
      attribute11           VARCHAR2(150),
      attribute12           VARCHAR2(150),
      attribute13           VARCHAR2(150),
      attribute14           VARCHAR2(150),
      attribute15           VARCHAR2(150),
      attribute16           VARCHAR2(150),
      attribute17           VARCHAR2(150),
      attribute18           VARCHAR2(150),
      attribute19           VARCHAR2(150),
      attribute20           VARCHAR2(150),
      object_version_number NUMBER
      ) ;

    TYPE ltt_salary is table of lrt_salary_proposal  INDEX BY BINARY_INTEGER ;
    TYPE ltt_components is table of lrt_salary_component
                                    INDEX BY BINARY_INTEGER ;


     USER_DATE_FORMAT VARCHAR2(20) := 'RRRR-MM-DD';

    -- declare a table for storing txn steps
    gtt_transaction_steps  hr_transaction_ss.transaction_table ;

    --gtt_trans_steps  hr_transaction_ss.transaction_table ;

    gv_package_name          VARCHAR2(30) := 'HR_PAY_RATE_SS' ;

    gv_activity_name         wf_item_activity_statuses_v.activity_name%TYPE
                            :='HR_MAINTAIN_SALARY' ;
    gv_process_name          wf_process_activities.process_name%TYPE
                             := 'HR_SALARY_PRC' ;
Procedure start_transaction(itemtype     in     varchar2
                           ,itemkey      in     varchar2
                           ,actid        in     number
                           ,funmode      in     varchar2
                           ,p_creator_person_id in number
                           ,result         out nocopy  varchar2 );


/********************************************************/
/**** Implementation change using Oracle Object Types ***/
/********************************************************/
PROCEDURE validate_salary_details (
  p_assignment_id     IN VARCHAR2,
  p_bg_id             IN VARCHAR2,
  p_effective_date    IN VARCHAR2,
  p_payroll_id        IN VARCHAR2,
  p_old_pay_basis_id  in number  default null,
  p_new_pay_basis_id  in number  default null,
  excep_message       OUT NOCOPY VARCHAR2,
  p_pay_proposal_id   OUT NOCOPY NUMBER,
  p_current_salary    OUT NOCOPY NUMBER,
  p_ovn               OUT NOCOPY NUMBER,
  p_api_mode          OUT NOCOPY VARCHAR2,
  p_warning_message   OUT NOCOPY VARCHAR2,
  p_asg_type	in varchar2 default 'E'
  ) ;



PROCEDURE validate_salary_details (
  p_assignment_id   IN VARCHAR2,
  p_effective_date  IN date DEFAULT NULL,
  p_item_type IN VARCHAR2 DEFAULT NULL,
  p_item_key IN VARCHAR2 DEFAULT NULL,
  excep_message     OUT NOCOPY VARCHAR2,
  p_pay_proposal_id OUT NOCOPY NUMBER,
  p_current_salary OUT NOCOPY NUMBER,
  p_ovn OUT NOCOPY NUMBER,
  p_api_mode OUT NOCOPY VARCHAR2,
  p_proposal_change_date OUT NOCOPY DATE
  );

 PROCEDURE is_transaction_exists(p_item_type    IN VARCHAR2,
                              p_item_key        IN VARCHAR2,
                              p_act_id          IN VARCHAR2,
                              trans_exists      OUT NOCOPY VARCHAR2,
                              no_of_components  OUT NOCOPY NUMBER,
                              is_multiple_payrate     OUT NOCOPY VARCHAR2 );


 PROCEDURE get_transaction_step_details(p_item_type    IN VARCHAR2,
                              p_item_key        IN VARCHAR2,
                              p_transaction_step_id          IN VARCHAR2,
                              trans_exists      OUT NOCOPY VARCHAR2,
                              no_of_components  OUT NOCOPY NUMBER,
                              is_multiple_payrate     OUT NOCOPY VARCHAR2 );

PROCEDURE process_salary_java (
     p_item_type 	IN     VARCHAR ,
     p_item_key  	IN     VARCHAR2 ,
     p_act_id    	IN     VARCHAR2 ,
     ltt_salary_data    IN OUT NOCOPY sshr_sal_prop_tab_typ,
     ltt_component      IN OUT NOCOPY sshr_sal_comp_tab_typ,
     p_api_mode         IN     VARCHAR2,
     p_review_proc_call IN     VARCHAR2,
     p_save_mode        IN     VARCHAR2,
     p_flow_mode        in out nocopy varchar2,  -- 2355929
     p_step_id             OUT NOCOPY NUMBER,
     p_warning_msg_name IN OUT NOCOPY varchar2,
     p_error_msg_text   IN OUT NOCOPY varchar2,
     p_rptg_grp_id      IN varchar2 default null,
     p_plan_id          IN varchar2 default null,
     p_effective_date_option IN varchar2 default null
  );


-- GSP change
 PROCEDURE get_transaction_details (
    p_item_type       IN wf_items.item_type%type ,
    p_item_key        IN wf_items.item_key%TYPE ,
    p_Act_id          IN VARCHAR2,
    p_ltt_salary_data IN OUT NOCOPY sshr_sal_prop_tab_typ,
    p_ltt_component   IN OUT NOCOPY sshr_sal_comp_tab_typ );


 PROCEDURE get_txn_details_for_review (
    p_item_type       IN wf_items.item_type%type ,
    p_item_key        IN wf_items.item_key%TYPE ,
    p_transaction_step_id          IN VARCHAR2,
    p_ltt_salary_data IN OUT NOCOPY sshr_sal_prop_tab_typ,
    p_ltt_component   IN OUT NOCOPY sshr_sal_comp_tab_typ );

-- End of GSP change


procedure delete_transaction_step
             (p_transaction_id    in number,
              p_login_person_id   in number );


--PROCEDURE process_api_java (
/*
PROCEDURE PROCESS_API (
    p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%type,
    p_validate IN boolean default false,
    p_effective_date      in varchar2 default null
);
*/

PROCEDURE PROCESS_API (
    p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%type,
    p_effective_date      in varchar2 default null,
    p_validate IN boolean default false
);

procedure prate_applicant_hire
  (p_person_id in number,
   p_bg_id    in number,
   p_org_id   in number,
   p_effective_date in date default sysdate,
   p_salaray_basis_id out nocopy varchar,
   p_offered_salary out nocopy varchar,
   p_offered_salary_basis out nocopy varchar
   );


API_NAME VARCHAR(50) := 'HR_SALARY_WEB.PROCESS_API';

PACKAGE_NAME VARCHAR2(30) := 'HR_PAY_RATE_SS';

END hr_pay_rate_ss;

/
