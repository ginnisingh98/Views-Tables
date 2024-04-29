--------------------------------------------------------
--  DDL for Package PAY_PPMV4_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPMV4_SS" AUTHID CURRENT_USER as
/* $Header: pyppmwrs.pkh 120.2.12010000.2 2009/09/30 17:00:47 pgongada ship $ */
---------------------------------------------------------------------------
---------------------------------- CONSTANTS ------------------------------
---------------------------------------------------------------------------
C_COMMA constant varchar2(4) default ',';
--
-- Amount Type Codes.
--
C_PERCENTAGE      constant varchar2(64)
default pay_pss_tx_steps_pkg.C_PERCENTAGE;
C_MONETARY        constant varchar2(64)
default pay_pss_tx_steps_pkg.C_MONETARY;
C_REMAINING_PAY   constant varchar2(64)
default pay_pss_tx_steps_pkg.C_REMAINING_PAY;
--
-- Amount Type Combinations.
--
C_PERCENTAGE_ONLY constant varchar2(64) default 'PERCENTAGE_ONLY';
C_EITHER_AMOUNT   constant varchar2(64) default 'EITHER_AMOUNT';
C_MONETARY_ONLY   constant varchar2(64) default 'MONETARY_ONLY';
--
-- Payment Method tables.
--
C_PAY_PERSONAL_PAYMENT_METHODS constant varchar2(2000)
default pay_pss_tx_steps_pkg.C_PAY_PERSONAL_PAYMENT_METHODS;
--
-- Transaction entry states.
--
C_STATE_NEW      constant varchar2(64)
default pay_pss_tx_steps_pkg.C_STATE_NEW;
C_STATE_FREED    constant varchar2(64)
default pay_pss_tx_steps_pkg.C_STATE_FREED;
C_STATE_EXISTING constant varchar2(64)
default pay_pss_tx_steps_pkg.C_STATE_EXISTING;
C_STATE_DELETED  constant varchar2(64)
default pay_pss_tx_steps_pkg.C_STATE_DELETED;
C_STATE_UPDATED  constant varchar2(64)
default pay_pss_tx_steps_pkg.C_STATE_UPDATED;
--
-- Payment Type Codes.
--
C_CASH    constant varchar2(2000) default pay_pss_tx_steps_pkg.C_CASH;
C_CHECK   constant varchar2(2000) default pay_pss_tx_steps_pkg.C_CHECK;
C_DEPOSIT constant varchar2(2000) default pay_pss_tx_steps_pkg.C_DEPOSIT;
--
-- Payment Type Combinations.
--
C_CASH_ONLY         constant varchar2(64) default 'CASH_ONLY';
C_CHECK_ONLY        constant varchar2(64) default 'CHECK_ONLY';
C_DEPOSIT_ONLY      constant varchar2(64) default 'DEPOSIT_ONLY';
C_CASH_AND_CHECK    constant varchar2(64) default 'CASH_AND_CHECK';
C_CASH_AND_DEPOSIT  constant varchar2(64) default 'CASH_AND_DEPOSIT';
C_CHECK_AND_DEPOSIT constant varchar2(64) default 'CHECK_AND_DEPOSIT';
C_ALL               constant varchar2(64) default 'ALL';
--
-- Configuration options.
--
C_BRANCH_VALIDATION       constant varchar2(64) default 'C_BRANCH_VALIDATION';
C_CURRENT_ASSIGNMENT_ID   constant varchar2(64) default 'P_ASSIGNMENT_ID';
C_CASH_LIST               constant varchar2(64) default 'CASH_LIST';
C_CHECK_LIST              constant varchar2(64) default 'CHECK_LIST';
C_DEPOSIT_LIST            constant varchar2(64) default 'DEPOSIT_LIST';
C_EFFECTIVE_DATE          constant varchar2(64) default 'P_EFFECTIVE_DATE';
C_MAXIMUM_PAYMENT_METHODS constant varchar2(64) default 'MAXIMUM_PAYMENT_METHODS';
C_OBSCURE_ACCOUNT_NUMBER  constant varchar2(64) default 'OBSCURE_ACCOUNT_NUMBER';
C_PERMITTED_AMOUNT_TYPES  constant varchar2(64) default 'PERMITTED_AMOUNT_TYPES';
C_PERMITTED_PAYMENT_TYPES constant varchar2(64) default 'PERMITTED_PAYMENT_TYPES';
C_CURRENT_PERSON_ID       constant varchar2(64) default 'CURRENT_PERSON_ID';
C_SUMMARY_BANK_DETAILS    constant varchar2(64) default 'SUMMARY_BANK_DETAILS';
C_VIEW_ONLY               constant varchar2(64) default 'VIEW_ONLY';
--
-- Configuration NULL value.
--
C_CONFIG_NULL             constant varchar2(64) default 'NULL';
--
C_MAX_PAYMENT_METHODS     constant number default 10;
C_MIN_PAYMENT_METHODS     constant number default 1;
C_DEFAULT_PAYMENT_METHODS constant number default 5;
--
C_LIST_SEPARATOR          constant varchar2(64) default '|';
--
-- Page labels.
--
C_SUMMARY_PAGE            constant varchar2(64) default 'SUMMARY';
C_REVIEW_PAGE             constant varchar2(64) default 'REVIEW';
--
-- Workflow item attributes for Payments self-service.
--
C_PSS_TXID_WF_ATTRIBUTE    constant varchar2(64) default
'PAY_PSS_TRANSACTION_ID';
C_BUS_GROUP_ID_WF_ATTR constant varchar2(64) default
'PAY_PSS_BUS_GROUP_ID';
C_BRANCH_CODE_CHK_WF_ATTR constant varchar2(64) default
'PAY_PSS_BRANCH_CODE_CHK';
C_LEG_CODE_WF_ATTR constant varchar2(64) default
'PAY_PSS_LEG_CODE';
C_ID_FLEX_NUM_WF_ATTR constant varchar2(64) default
'PAY_PSS_ID_FLEX_NUM';
C_FLEX_STRUCT_CODE_WF_ATTR constant varchar2(64) default
'PAY_PSS_FLEX_STRUCT_CODE';
C_DEF_PAYMENT_TYPE_WF_ATTR constant varchar2(64) default
'PAY_PSS_DEFAULT_PAYMENT_TYPE';
C_PRENOTE_REQUIRED_WF_ATTR constant varchar2(64) default
'PAY_PSS_PRENOTE_REQUIRED';
C_USE_CHECK_WF_ATTR constant varchar2(64) default
'PAY_PSS_USE_CHECK';
C_VIEW_ONLY_WF_ATTR constant varchar2(64) default
'PAY_PSS_VIEW_ONLY';
C_PAYMENT_TYPES_WF_ATTR constant varchar2(64) default
'PAY_PSS_PAYMENT_TYPES';
C_AMOUNT_TYPES_WF_ATTR constant varchar2(64) default
'PAY_PSS_AMOUNT_TYPES';
C_MAX_PAY_METHODS_WF_ATTR constant varchar2(64) default
'PAY_PSS_MAX_PAY_METHODS';
C_CA_OPM_ID_WF_ATTR constant varchar2(64) default
'PAY_PSS_CA_OPM_ID';
C_CH_OPM_ID_WF_ATTR constant varchar2(64) default
'PAY_PSS_CH_OPM_ID';
C_MT_OPM_ID_WF_ATTR constant varchar2(64) default
'PAY_PSS_MT_OPM_ID';
C_PREPAYMENTS_WF_ATTR constant varchar2(64) default
'PAY_PSS_PREPAYMENTS';
--
-- Flags to for different stages of getting the configuration.
--
C_GOT_CONFIG1_WF_ATTR      constant varchar2(64) default
'PAY_PSS_GOT_CONFIG1';
C_GOT_CONFIG2_WF_ATTR      constant varchar2(64) default
'PAY_PSS_GOT_CONFIG2';

--
--Foriegn Account Enhancement Variables
--

C_FACCT_ALWD_WF_ATTR   constant varchar2(64) default 'PAY_PSS_FACCT_ALWD';
C_FAA_CH_OPMID_LST_WF_ATTR constant varchar2(64) default 'PAY_PSS_FAA_CH_OPMID_LST';
C_FAA_CA_OPMID_LST_WF_ATTR constant varchar2(64) default 'PAY_PSS_FAA_CA_OPMID_LST';
C_FAA_MT_OPMID_LST_WF_ATTR constant varchar2(64) default 'PAY_PSS_FAA_MT_OPMID_LST';
C_PAYROLL_ID constant varchar2(64) default 'PAY_PSS_PAYROLL_ID';
C_YES constant varchar2(64) default 'Y';
C_NO constant varchar2(64) default 'N';

--
-- HR transaction tables TRANSACTION_ID.
--
C_HR_TXID_WF_ATTRIBUTE     constant varchar2(64) default 'TRANSACTION_ID';
---------------------------------------------------------------------------
-------------------------------- DATA TYPES -------------------------------
---------------------------------------------------------------------------
type t_number_tbl is table of number index by binary_integer;
---------------------------------------------------------------------------
----------------------- FUNCTIONS AND PROCEDURES --------------------------
---------------------------------------------------------------------------
------------------------------< include_in_page >--------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Called at the end of an operation such as DELETE or SORT-BY-PRIORITY
--   to update the Remaining Pay PPM, if necessary. This is necessary when
--   the Remaining Pay PPM is deleted or is moved up the priority order.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   'Y' if the PPM should be included in the page.
--   'N' if the PPM should not be included in the page.
--
-- Post Failure:
--   Should not occur.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function include_in_page
(p_page  in varchar2
,p_state in varchar2
) return varchar2;
----------------------------< post_submit_work >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Carries out additional updates after the user has clicked Continue
--   on the Summary Page. The updates in question are:
--   * Update the HR Transaction Tables.
--   * Update the real priority values for the user's changes.
--   These updates are not performed if no changes have been made.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   p_return_status = FND_MSG_PUB.G_RET_STS_SUCCESS
--   A new lowest priority PPM is updated to become the Remaining Pay PPM.
--
-- Post Failure:
--   p_return_status <> FND_MSG_PUB.G_RET_STS_SUCCESS
--   p_msg_count > 0
--   p_msg_data contains error information
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure post_submit_work
(p_item_type       in     varchar2
,p_item_key        in     varchar2
,p_activity_id     in     varchar2
,p_login_person_id in     varchar2
,p_transaction_id  in     varchar2
,p_assignment_id   in     varchar2
,p_effective_date  in     varchar2
,p_return_status      out nocopy varchar2
,p_msg_count          out nocopy number
,p_msg_data           out nocopy varchar2
);
------------------------< update_remaining_pay_ppm >-----------------------
--
-- {Start Of Comments}
--
-- Description:
--   Called at the end of an operation such as DELETE or SORT-BY-PRIORITY
--   to update the Remaining Pay PPM, if necessary. This is necessary when
--   the Remaining Pay PPM is deleted or is moved up the priority order.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   A new lowest priority PPM is updated to become the Remaining Pay PPM.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_remaining_pay_ppm
(p_transaction_id in number
);
----------------------------------< db2tts >-------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Reads the user's existing PPMs and creates transaction table
--   entries for them. db2tts is only called once per for each
--   payments self-service session.
--
-- Prerequisites:
--   Assumes that the user has no future-dated PPM changes and that
--   the user's PPMs are consistent with the Amount Type configuration
--   (P_AMOUNT_TYPE).
--
-- Post Success:
--   p_return_status = FND_MSG_PUB.G_RET_STS_SUCCESS
--
--   The transaction tables are populated with values from the user's
--   existing PPMs.
--   P_PREPAYMENTS:
--     Y - there are future-dated prepayments.
--     N - there are no future-dated prepayments.
--   P_TRANSACTION_ID:
--     The transaction_id to be used in view object queries.
--
-- Post Failure:
--   p_return_status <> FND_MSG_PUB.G_RET_STS_SUCCESS
--   p_msg_count > 0
--   p_msg_data contains error information
--
--   The transaction tables are not affected.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure db2tts
(p_assignment_id        in     varchar2
,p_effective_date       in     varchar2
,p_amount_type          in     varchar2
,p_item_type            in     varchar2 default null
,p_item_key             in     varchar2 default null
,p_run_type_id          in     varchar2 default null
,p_transaction_id          out nocopy varchar2
,p_prepayments             out nocopy varchar2
,p_return_status           out nocopy varchar2
,p_msg_count               out nocopy number
,p_msg_data                out nocopy varchar2
);
---------------------------------< getconfig >-----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Reads and validates the PSS configuration. Also, checks that the
--   configuration options are consistent with the employees's PPMs.
--
--   This routine must be called before any other PLSQL code.
--
-- Prerequisites:
--   The calling code is executing within the context of a workflow.
--
-- Post Success:
--   p_return_status = FND_MSG_PUB.G_RET_STS_SUCCESS
--
--   The configuration values are returned in the OUT parameters.
--     P_VIEW_ONLY:
--       Y - view only.
--       N - editing is allowed.
--     P_PAYMENT_TYPES:
--       C_CASH_ONLY
--       C_CHECK_ONLY
--       C_DEPOSIT_ONLY
--       C_CASH_AND_CHECK
--       C_CASH_AND_DEPOSIT
--       C_CHECK_AND_DEPOSIT
--       C_ALL
--     P_AMOUNT_TYPE:
--       C_PERCENTAGE_ONLY
--       C_MONETARY_ONLY
--       C_EITHER_AMOUNT
--     P_PRENOTE_REQUIRED:
--       Y - prenotification is required on the payroll.
--       N - prenotification is not required on the payroll.
--     P_USE_CHECK:
--       Y - Use US spelling "Check" instead of "Cheque".
--
-- Post Failure:
--   p_return_status <> FND_MSG_PUB.G_RET_STS_SUCCESS
--   p_msg_count > 0
--   p_msg_data contains error information
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure getconfig
(p_item_type           in     varchar2
,p_item_key            in     varchar2
,p_activity_id         in     varchar2
,p_person_id           in     varchar2
,p_assignment_id       in     varchar2
,p_effective_date      in     varchar2
,p_run_type_id         in     varchar2          default null
,p_business_group_id      out nocopy varchar2
,p_territory_code         out nocopy varchar2
,p_id_flex_num            out nocopy varchar2
,p_flex_struct_code       out nocopy varchar2
,p_default_payment_type   out nocopy varchar2
,p_prenote_required       out nocopy varchar2
,p_use_check              out nocopy varchar2
,p_view_only              out nocopy varchar2
,p_payment_types          out nocopy varchar2
,p_amount_types           out nocopy varchar2
,p_max_pay_methods        out nocopy varchar2
,p_cash_opmid             out nocopy varchar2
,p_check_opmid            out nocopy varchar2
,p_deposit_opmid          out nocopy varchar2
,p_obscure_prompt         out nocopy varchar2
,p_obscure_digits         out nocopy varchar2
,p_obscure_char           out nocopy varchar2
,p_return_status          out nocopy varchar2
,p_msg_count              out nocopy number
,p_msg_data               out nocopy varchar2
,p_branch_validation      out nocopy varchar2
,p_show_paymthd_lov       out nocopy varchar2
,p_faa_ch_opmid_list  out nocopy varchar2
,p_faa_ca_opmid_list   out nocopy varchar2
,p_faa_mt_opmid_list out nocopy varchar2
,p_payroll_id out nocopy varchar2
);
--------------------------------< gettxstepids >---------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Returns a comma-separated list of transaction_step_ids for PPMs
--   according to a flag.
--   P_SUMMARY_PAGE:
--     TRUE - get the transaction_step_ids for PPMs to be displayed on
--            the Summary Page. The list is ordered by logical_priority.
--   P_REVIEW_PAGE:
--     TRUE  - get the transaction_step_ids for PPMs to be displayed on
--             the Review (and Confirmation) Page. The list is ordered
--             by logical priority for non-deleted PPMs.
--   P_FREED:
--     TRUE  - get the transaction_step_ids for freed PPMs i.e. PPMs that
--             correspond to newly created PPMs that are subsequently
--             deleted.
--   One (and only one) of these flags must be set to TRUE.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The transaction_step_id list is returned (it's NULL if there are
--   no transaction_step_ids).
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function gettxstepids
(p_transaction_id in varchar2
,p_review_page    in boolean default false
,p_summary_page   in boolean default false
,p_freed          in boolean default false
) return varchar2;
-----------------------------< alloc_real_priorities >---------------------
--
-- {Start Of Comments}
--
-- Description:
--   Allocates real priorities to the PPMs that would exist if the user's
--   changes were committed.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   p_success is set to true.
--   The transaction table entries are updated with the new real priority
--   values.
--
-- Post Failure:
--   p_success is set to false.
--   An exception is raised if there was an unhandled exception.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure alloc_real_priorities
(p_transaction_id  in     varchar2
,p_assignment_id   in     varchar2
,p_effective_date  in     varchar2
,p_success            out nocopy boolean
);
----------------------------< update_logical_priority >--------------------
--
-- {Start Of Comments}
--
-- Description:
--   Updates a transaction table entry with a new logical priority value.
--   Does any necessary update of state. p_logical_priority is set
--   internally - it has a valid value.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The transaction table entry is updated with the new logical priority
--   value.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_logical_priority
(p_transaction_step_id in varchar2
,p_logical_priority    in varchar2
,p_amount_type         in varchar2
);
----------------------------------< enter_ppm >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Handles validation of user changes and saving of the transaction data
--   when a PPM is created or updated.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   P_USER_ERROR:
--     Y - the validation of the user's changes revealed errors.
--     N - the user's changed were okay and the transaction data was saved.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure enter_ppm
(p_transaction_id        in     varchar2
,p_transaction_step_id   in out nocopy varchar2
,p_source_table          in     varchar2
default pay_pss_tx_steps_pkg.C_PAY_PERSONAL_PAYMENT_METHODS
,p_assignment_id         in     varchar2
,p_payment_type          in     varchar2
,p_currency_code         in     varchar2
,p_org_payment_method_id in     varchar2
,p_territory_code        in     varchar2
,p_effective_date        in     varchar2
,p_amount_type           in     varchar2
,p_amount                in     number
,p_external_account_id   in     number   default null
,p_attribute_category    in     varchar2 default null
,p_attribute1            in     varchar2 default null
,p_attribute2            in     varchar2 default null
,p_attribute3            in     varchar2 default null
,p_attribute4            in     varchar2 default null
,p_attribute5            in     varchar2 default null
,p_attribute6            in     varchar2 default null
,p_attribute7            in     varchar2 default null
,p_attribute8            in     varchar2 default null
,p_attribute9            in     varchar2 default null
,p_attribute10           in     varchar2 default null
,p_attribute11           in     varchar2 default null
,p_attribute12           in     varchar2 default null
,p_attribute13           in     varchar2 default null
,p_attribute14           in     varchar2 default null
,p_attribute15           in     varchar2 default null
,p_attribute16           in     varchar2 default null
,p_attribute17           in     varchar2 default null
,p_attribute18           in     varchar2 default null
,p_attribute19           in     varchar2 default null
,p_attribute20           in     varchar2 default null
,p_run_type_id           in     varchar2 default null
,p_ppm_information_category in  varchar2 default null
,p_ppm_information1      in     varchar2 default null
,p_ppm_information2      in     varchar2 default null
,p_ppm_information3      in     varchar2 default null
,p_ppm_information4      in     varchar2 default null
,p_ppm_information5      in     varchar2 default null
,p_ppm_information6      in     varchar2 default null
,p_ppm_information7      in     varchar2 default null
,p_ppm_information8      in     varchar2 default null
,p_ppm_information9      in     varchar2 default null
,p_ppm_information10     in     varchar2 default null
,p_ppm_information11     in     varchar2 default null
,p_ppm_information12     in     varchar2 default null
,p_ppm_information13     in     varchar2 default null
,p_ppm_information14     in     varchar2 default null
,p_ppm_information15     in     varchar2 default null
,p_ppm_information16     in     varchar2 default null
,p_ppm_information17     in     varchar2 default null
,p_ppm_information18     in     varchar2 default null
,p_ppm_information19     in     varchar2 default null
,p_ppm_information20     in     varchar2 default null
,p_ppm_information21     in     varchar2 default null
,p_ppm_information22     in     varchar2 default null
,p_ppm_information23     in     varchar2 default null
,p_ppm_information24     in     varchar2 default null
,p_ppm_information25     in     varchar2 default null
,p_ppm_information26     in     varchar2 default null
,p_ppm_information27     in     varchar2 default null
,p_ppm_information28     in     varchar2 default null
,p_ppm_information29     in     varchar2 default null
,p_ppm_information30     in     varchar2 default null
,p_return_status            out nocopy varchar2
,p_msg_count                out nocopy number
,p_msg_data                 out nocopy varchar2
);
---------------------------------< delete_ppm >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Updates transaction tables following delete of a PPM.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The transaction tables are updated.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_ppm
(p_transaction_step_id    in         varchar2
,p_return_status          out nocopy varchar2
,p_msg_count              out nocopy number
,p_msg_data               out nocopy varchar2
);
--------------------------------< process_api >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Reads transaction tables and makes the Personal Payment Methods API
--   call.
--
-- Prerequisites:
--   The HR and Payments self-service tables must be set up correctly.
--
-- Post Success:
--   The API call is successfully made.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure process_api
(p_transaction_step_id in number
,p_validate            in boolean default false
);
------------------------< delete_pss_transactions >----------------------
--
-- {Start Of Comments}
--
-- Description:
--   Deletes all Payments self-service transaction steps whose transaction_id
--   is stored in the workflow attribute C_PSS_TXID_WF_ATTRIBUTE.
--
-- Prerequisites:
--   The workflow attribute, C_PSS_TXID_WF_ATTRIBUTE, must contain
--   the value of a valid transaction_id.
--
-- Post Success:
--   The transaction steps are deleted.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_ppm_transactions
(item_type in     varchar2
,item_key  in     varchar2
,actid     in     number
,funmode   in     varchar2
,result       out nocopy varchar2
);
-------------------------< resequence_priorities >-----------------------
--
-- {Start Of Comments}
--
-- Description:
--   17-OCT-2001 This function call has been obsoleted now. Its
--   functionality has been moved to a more appropriate place within the
--   API processing. It is retained to avoid changing the workflow
--   definition.
--
--   This is effectively a stub function.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   Always returns success.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure resequence_priorities
(item_type in     varchar2
,item_key  in     varchar2
,actid     in     number
,funmode   in     varchar2
,result       out nocopy varchar2
);

-------------------------< get_ppm_country >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the Country associated with the PPM
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns the Terirory code associated with the PPM
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_ppm_country
(p_org_payment_method_id IN number,
 p_business_group_id IN     number,
 p_return_desc IN VARCHAR2 default 'N'

)return varchar2;


-------------------------< get_bank_flexcode >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the Bank Flex Structure Code
-- for country with the Payment Type Country if it is Non Generic
-- Payment Types and BG County for Generic Payment Types.
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns the required Bank Flex Structure Code.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_bank_flexcode
(p_org_payment_method_id IN number,
 p_business_group_id IN     number
)return varchar2;

-------------------------< get_org_method_name >-----------------------
--
-- {Start Of Comments}
--
-- Description:
-- 11-12-2006 This function gets the ORG Payment Method Name
--
--
-- Prerequisites:
--   None.
--
-- Post Success:
--  Always returns Organization Payment Method Name.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_org_method_name
(p_org_payment_method_id IN number,
 p_business_group_id IN     number
)return varchar2;

function is_foreign_transaction(
p_opm_id in number, p_effective_date DATE) return varchar;
function get_payment_type_name(p_opm_id number,
                               p_effective_date date) RETURN  varchar2;
procedure store_session(p_effective_date DATE);

end pay_ppmv4_ss;

/
