--------------------------------------------------------
--  DDL for Package PAY_PPMV4_UTILS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPMV4_UTILS_SS" AUTHID CURRENT_USER as
/* $Header: pyppmv4u.pkh 120.0.12010000.2 2009/09/26 06:32:52 pgongada ship $ */
---------------------------------------------------------------------------
---------------------------------- CONSTANTS ------------------------------
---------------------------------------------------------------------------
-- Priority values to use.
--
C_MAX_PRIORITY      constant number default 99;
C_MIN_PRIORITY      constant number default 1;
C_NO_PRIORITY       constant number default -1; -- Invalid value.
--
-- The API to be called for the PPM transactions.
--
C_PSS_API           constant varchar2(2000) default
'PAY_PPMV4_SS.PROCESS_API';
--
-- Workflow constants.
--
C_PROCESSED_FLAG_ARG   constant varchar2(2000) default 'P_PROCESSED_FLAG';
C_TX_STEP_ID_ARG       constant varchar2(2000) default 'P_TRANSACTION_STEP_ID';
C_REVIEW_PROC_CALL_ARG constant varchar2(2000) default 'P_REVIEW_PROC_CALL';
C_REVIEW_ACTID_ARG     constant varchar2(2000) default 'P_REVIEW_ACTID';
C_REVIEW_REGION_ITEM   constant varchar2(2000) default 'HR_REVIEW_REGION_ITEM';
C_ASSIGNMENT_ID        constant varchar2(2000) default 'PAY_PSS_ASSIGNMENT_ID';
C_EFFECTIVE_DATE       constant varchar2(2000) default
'PAY_PSS_EFFECTIVE_DATE';
---------------------------------------------------------------------------
-------------------------------- DATA TYPES -------------------------------
---------------------------------------------------------------------------
--
-- T_PPM
--
type t_ppmv4 is record
(transaction_id         pay_pss_transaction_steps.transaction_id%type
,transaction_step_id    pay_pss_transaction_steps.transaction_step_id%type
,source_table           pay_pss_transaction_steps.source_table%type
,state                  pay_pss_transaction_steps.state%type
,personal_payment_method_id
 pay_personal_payment_methods_f.personal_payment_method_id%type
,update_ovn
 pay_personal_payment_methods_f.object_version_number%type
,delete_ovn
 pay_personal_payment_methods_f.object_version_number%type
,update_datetrack_mode  pay_pss_transaction_steps.update_datetrack_mode%type
,delete_datetrack_mode  pay_pss_transaction_steps.delete_datetrack_mode%type
,delete_disabled        pay_pss_transaction_steps.delete_disabled%type
,effective_date         date
,org_payment_method_id  pay_org_payment_methods_f.org_payment_method_id%type
,assignment_id          pay_personal_payment_methods_f.assignment_id%type
,payment_type           pay_pss_transaction_steps.payment_type%type
,currency_code          pay_pss_transaction_steps.currency_code%type
,territory_code         pay_pss_transaction_steps.territory_code%type
--
-- Current data values.
--
,real_priority          pay_personal_payment_methods_f.priority%type
,logical_priority       pay_personal_payment_methods_f.priority%type
,amount_type            pay_pss_transaction_steps.amount_type%type
,amount                 pay_personal_payment_methods_f.amount%type
,external_account_id    pay_external_accounts.external_account_id%type
,attribute_category     pay_personal_payment_methods_f.attribute_category%type
,attribute1             pay_personal_payment_methods_f.attribute1%type
,attribute2             pay_personal_payment_methods_f.attribute2%type
,attribute3             pay_personal_payment_methods_f.attribute3%type
,attribute4             pay_personal_payment_methods_f.attribute4%type
,attribute5             pay_personal_payment_methods_f.attribute5%type
,attribute6             pay_personal_payment_methods_f.attribute6%type
,attribute7             pay_personal_payment_methods_f.attribute7%type
,attribute8             pay_personal_payment_methods_f.attribute8%type
,attribute9             pay_personal_payment_methods_f.attribute9%type
,attribute10            pay_personal_payment_methods_f.attribute10%type
,attribute11            pay_personal_payment_methods_f.attribute11%type
,attribute12            pay_personal_payment_methods_f.attribute12%type
,attribute13            pay_personal_payment_methods_f.attribute13%type
,attribute14            pay_personal_payment_methods_f.attribute14%type
,attribute15            pay_personal_payment_methods_f.attribute15%type
,attribute16            pay_personal_payment_methods_f.attribute16%type
,attribute17            pay_personal_payment_methods_f.attribute17%type
,attribute18            pay_personal_payment_methods_f.attribute18%type
,attribute19            pay_personal_payment_methods_f.attribute19%type
,attribute20            pay_personal_payment_methods_f.attribute20%type
--
-- Original data values.
--
,o_real_priority        pay_personal_payment_methods_f.priority%type
,o_logical_priority     pay_personal_payment_methods_f.priority%type
,o_amount_type          pay_pss_transaction_steps.o_amount_type%type
,o_amount               pay_personal_payment_methods_f.amount%type
,o_external_account_id  pay_external_accounts.external_account_id%type
,o_attribute_category   pay_personal_payment_methods_f.attribute_category%type
,o_attribute1           pay_personal_payment_methods_f.attribute1%type
,o_attribute2           pay_personal_payment_methods_f.attribute2%type
,o_attribute3           pay_personal_payment_methods_f.attribute3%type
,o_attribute4           pay_personal_payment_methods_f.attribute4%type
,o_attribute5           pay_personal_payment_methods_f.attribute5%type
,o_attribute6           pay_personal_payment_methods_f.attribute6%type
,o_attribute7           pay_personal_payment_methods_f.attribute7%type
,o_attribute8           pay_personal_payment_methods_f.attribute8%type
,o_attribute9           pay_personal_payment_methods_f.attribute9%type
,o_attribute10          pay_personal_payment_methods_f.attribute10%type
,o_attribute11          pay_personal_payment_methods_f.attribute11%type
,o_attribute12          pay_personal_payment_methods_f.attribute12%type
,o_attribute13          pay_personal_payment_methods_f.attribute13%type
,o_attribute14          pay_personal_payment_methods_f.attribute14%type
,o_attribute15          pay_personal_payment_methods_f.attribute15%type
,o_attribute16          pay_personal_payment_methods_f.attribute16%type
,o_attribute17          pay_personal_payment_methods_f.attribute17%type
,o_attribute18          pay_personal_payment_methods_f.attribute18%type
,o_attribute19          pay_personal_payment_methods_f.attribute19%type
,o_attribute20          pay_personal_payment_methods_f.attribute20%type
,run_type_id            pay_personal_payment_methods_f.run_type_id%type

,ppm_information_category pay_personal_payment_methods_f.ppm_information_category%type
,ppm_information1       pay_personal_payment_methods_f.ppm_information1%type
,ppm_information2       pay_personal_payment_methods_f.ppm_information2%type
,ppm_information3       pay_personal_payment_methods_f.ppm_information3%type
,ppm_information4       pay_personal_payment_methods_f.ppm_information4%type
,ppm_information5       pay_personal_payment_methods_f.ppm_information5%type
,ppm_information6       pay_personal_payment_methods_f.ppm_information6%type
,ppm_information7       pay_personal_payment_methods_f.ppm_information7%type
,ppm_information8       pay_personal_payment_methods_f.ppm_information8%type
,ppm_information9       pay_personal_payment_methods_f.ppm_information9%type
,ppm_information10      pay_personal_payment_methods_f.ppm_information10%type
,ppm_information11      pay_personal_payment_methods_f.ppm_information11%type
,ppm_information12      pay_personal_payment_methods_f.ppm_information12%type
,ppm_information13      pay_personal_payment_methods_f.ppm_information13%type
,ppm_information14      pay_personal_payment_methods_f.ppm_information14%type
,ppm_information15      pay_personal_payment_methods_f.ppm_information15%type
,ppm_information16      pay_personal_payment_methods_f.ppm_information16%type
,ppm_information17      pay_personal_payment_methods_f.ppm_information17%type
,ppm_information18      pay_personal_payment_methods_f.ppm_information18%type
,ppm_information19      pay_personal_payment_methods_f.ppm_information19%type
,ppm_information20      pay_personal_payment_methods_f.ppm_information20%type
,ppm_information21      pay_personal_payment_methods_f.ppm_information21%type
,ppm_information22      pay_personal_payment_methods_f.ppm_information22%type
,ppm_information23      pay_personal_payment_methods_f.ppm_information23%type
,ppm_information24      pay_personal_payment_methods_f.ppm_information24%type
,ppm_information25      pay_personal_payment_methods_f.ppm_information25%type
,ppm_information26      pay_personal_payment_methods_f.ppm_information26%type
,ppm_information27      pay_personal_payment_methods_f.ppm_information27%type
,ppm_information28      pay_personal_payment_methods_f.ppm_information28%type
,ppm_information29      pay_personal_payment_methods_f.ppm_information29%type
,ppm_information30      pay_personal_payment_methods_f.ppm_information30%type
,o_ppm_information_category pay_personal_payment_methods_f.ppm_information_category%type
,o_ppm_information1     pay_personal_payment_methods_f.ppm_information1%type
,o_ppm_information2     pay_personal_payment_methods_f.ppm_information2%type
,o_ppm_information3     pay_personal_payment_methods_f.ppm_information3%type
,o_ppm_information4     pay_personal_payment_methods_f.ppm_information4%type
,o_ppm_information5     pay_personal_payment_methods_f.ppm_information5%type
,o_ppm_information6     pay_personal_payment_methods_f.ppm_information6%type
,o_ppm_information7     pay_personal_payment_methods_f.ppm_information7%type
,o_ppm_information8     pay_personal_payment_methods_f.ppm_information8%type
,o_ppm_information9     pay_personal_payment_methods_f.ppm_information9%type
,o_ppm_information10    pay_personal_payment_methods_f.ppm_information10%type
,o_ppm_information11    pay_personal_payment_methods_f.ppm_information11%type
,o_ppm_information12    pay_personal_payment_methods_f.ppm_information12%type
,o_ppm_information13    pay_personal_payment_methods_f.ppm_information13%type
,o_ppm_information14    pay_personal_payment_methods_f.ppm_information14%type
,o_ppm_information15    pay_personal_payment_methods_f.ppm_information15%type
,o_ppm_information16    pay_personal_payment_methods_f.ppm_information16%type
,o_ppm_information17    pay_personal_payment_methods_f.ppm_information17%type
,o_ppm_information18    pay_personal_payment_methods_f.ppm_information18%type
,o_ppm_information19    pay_personal_payment_methods_f.ppm_information19%type
,o_ppm_information20    pay_personal_payment_methods_f.ppm_information20%type
,o_ppm_information21    pay_personal_payment_methods_f.ppm_information21%type
,o_ppm_information22    pay_personal_payment_methods_f.ppm_information22%type
,o_ppm_information23    pay_personal_payment_methods_f.ppm_information23%type
,o_ppm_information24    pay_personal_payment_methods_f.ppm_information24%type
,o_ppm_information25    pay_personal_payment_methods_f.ppm_information25%type
,o_ppm_information26    pay_personal_payment_methods_f.ppm_information26%type
,o_ppm_information27    pay_personal_payment_methods_f.ppm_information27%type
,o_ppm_information28    pay_personal_payment_methods_f.ppm_information28%type
,o_ppm_information29    pay_personal_payment_methods_f.ppm_information29%type
,o_ppm_information30    pay_personal_payment_methods_f.ppm_information30%type

);
--
-- T_PPM_TBL
--
type t_ppmv4_tbl is table of t_ppmv4 index by binary_integer;
--
-- T_BOOLEAN_TBL
--
type t_boolean_tbl is table of boolean index by binary_integer;
---------------------------------------------------------------------------
----------------------- FUNCTIONS AND PROCEDURES --------------------------
---------------------------------------------------------------------------
-------------------------------< seterror >--------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Cover for hr_utility.set_location call.
--   SETERRORSTAGE
--     P_PROC          - The procedure being called.
--     P_STAGE         - Where in the code is at this moment.
--     P_LOC           - Error location.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--
-- Post Failure:
--   Not applicable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure seterrorstage
(p_proc in varchar2
,p_stage in varchar2
,p_location in number
);
------------------------------< ppm2hrtt >---------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Writes PPM information to HR transaction tables.
--   P_TRANSACTION_STEP_ID is from PAY_PSS_TRANSACTION_STEPS.
--   P_FORCE_NEW_TRANSACTION forces a new transaction to be created.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The transaction table is populated.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure ppm2hrtt
(p_item_type             in varchar2
,p_item_key              in varchar2
,p_activity_id           in number
,p_login_person_id       in number
,p_review_proc_call      in varchar2
,p_transaction_step_id   in number
,p_force_new_transaction in boolean
);
--------------------------------< ppm2tt >---------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Writes a T_PPM record to the transaction tables.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The ppm values are saved to the transaction table. The save is committed.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure ppm2tt
(p_ppm             in out nocopy t_ppmv4
);
--------------------------------< tt2ppm >---------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Converts a transaction entry to a T_PPM record.
--
-- Prerequisites:
--   P_TRANSACTION_STEP_ID must point to a valid record.
--
-- Post Success:
--   The T_PPM record is populated using the supplied values.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure tt2ppm
(p_transaction_step_id in     number
,p_ppm                    out nocopy t_ppmv4
);
-----------------------------< changedppm >------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Detects whether or not a PPM has changed (original data values
--   differ from latest data values).
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   P_CHANGES is set to true if there are any differences.
--   P_BANK is set to true if the Bank Details differ.
--
-- Post Failure:
--   Not applicable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure changedppm
(p_ppm           in     t_ppmv4
,p_changes          out nocopy boolean
,p_bank             out nocopy boolean
);
-----------------------------< changedppm >------------------------
-- {Start Of Comments}
--
-- Description:
--   Overloaded version to use when comparing a new ppm with a saved
--   ppm. Differences in logical priority are overlooked in this
--   instance because it's used to compare an Added/Updated PPM with
--   a saved one to reduce unnecessary validation.
--
-- Post Success:
--   P_ORIGINAL:
--     TRUE  - P_NEW_PPM differs from the original version of
--             P_SAVED_PPM.
--     FALSE - P_NEW_PPM is the same as the original version of
--             P_SAVED_PPM.
--   P_CURRENT:
--     TRUE  - P_NEW_PPM differs from the current version of
--             P_SAVED_PPM.
--     FALSE - P_NEW_PPM is the same as the current version of
--             P_SAVED_PPM.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure changedppm
(p_new_ppm   in     t_ppmv4
,p_saved_ppm in     t_ppmv4
,p_original     out nocopy boolean
,p_current      out nocopy boolean
);
-----------------------------< nextentry >--------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Gets the next entry from a list whose entries are separated by
--   a given character. May return NULL.
--   p_start is set to 0 when the last entry in the list is reached.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The current list entry is returned. p_start is set to point at
--   the next entry in the list (or 0 if this list entry was the last
--   list entry).
--
-- Post Failure:
--   Not applicable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function nextentry
(p_list      in     varchar2
,p_separator in     varchar2
,p_start     in out nocopy number
) return varchar2;
------------------------< read_wf_config_option >------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Reads the value of an activity, or item attribute for the specified
--   workflow.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The value of the attribute is returned.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function read_wf_config_option
(p_item_type   in varchar2
,p_item_key    in varchar2
,p_activity_id in number   default null
,p_option      in varchar2
,p_number      in boolean  default false
) return varchar2;
----------------------< getpriorities >-----------------------
--
-- {Start Of Comments}
--
-- Description:
--   Returns a priority availability table that lists the PPM
--   priorities that are allocated to existing PPMs, and those
--   priorities that are free. Also, returns the first available
--   PPM priority.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--
-- Post Failure:
--   Raises an exception.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure getpriorities
(p_assignment_id  in     number
,p_effective_date in     date
,p_run_type_id    in     number default null
,p_priority_tbl      out nocopy t_boolean_tbl
,p_first_available   out nocopy number
);
-----------------------------< validateppm >------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Checks that changes to a PPM for validity for INSERT/UPDATE of
--   a complete PPM record.
--   Delete validation and priority validation are not required since
--   the system prevalidates for those cases.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   If there are user errors then the hr_errors_api error table is
--   written to. The caller should call hr_errors_api.errorexists to
--   check for errors.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure validateppm
(p_state                      in     varchar2
,p_personal_payment_method_id in     number   default null
,p_object_version_number      in     number   default null
,p_update_datetrack_mode      in     varchar2 default null
,p_effective_date             in     date     default null
,p_org_payment_method_id      in     number   default null
,p_assignment_id              in     number   default null
,p_run_type_id                in     number   default null
,p_payment_type               in     varchar2 default null
,p_territory_code             in     varchar2 default null
,p_amount_type                in     varchar2 default null
,p_amount                     in     number   default null
,p_external_account_id        in     number   default null
,p_attribute_category         in     varchar2 default null
,p_attribute1                 in     varchar2 default null
,p_attribute2                 in     varchar2 default null
,p_attribute3                 in     varchar2 default null
,p_attribute4                 in     varchar2 default null
,p_attribute5                 in     varchar2 default null
,p_attribute6                 in     varchar2 default null
,p_attribute7                 in     varchar2 default null
,p_attribute8                 in     varchar2 default null
,p_attribute9                 in     varchar2 default null
,p_attribute10                in     varchar2 default null
,p_attribute11                in     varchar2 default null
,p_attribute12                in     varchar2 default null
,p_attribute13                in     varchar2 default null
,p_attribute14                in     varchar2 default null
,p_attribute15                in     varchar2 default null
,p_attribute16                in     varchar2 default null
,p_attribute17                in     varchar2 default null
,p_attribute18                in     varchar2 default null
,p_attribute19                in     varchar2 default null
,p_attribute20                in     varchar2 default null
,p_segment1                   in     varchar2 default null
,p_segment2                   in     varchar2 default null
,p_segment3                   in     varchar2 default null
,p_segment4                   in     varchar2 default null
,p_segment5                   in     varchar2 default null
,p_segment6                   in     varchar2 default null
,p_segment7                   in     varchar2 default null
,p_segment8                   in     varchar2 default null
,p_segment9                   in     varchar2 default null
,p_segment10                  in     varchar2 default null
,p_segment11                  in     varchar2 default null
,p_segment12                  in     varchar2 default null
,p_segment13                  in     varchar2 default null
,p_segment14                  in     varchar2 default null
,p_segment15                  in     varchar2 default null
,p_segment16                  in     varchar2 default null
,p_segment17                  in     varchar2 default null
,p_segment18                  in     varchar2 default null
,p_segment19                  in     varchar2 default null
,p_segment20                  in     varchar2 default null
,p_segment21                  in     varchar2 default null
,p_segment22                  in     varchar2 default null
,p_segment23                  in     varchar2 default null
,p_segment24                  in     varchar2 default null
,p_segment25                  in     varchar2 default null
,p_segment26                  in     varchar2 default null
,p_segment27                  in     varchar2 default null
,p_segment28                  in     varchar2 default null
,p_segment29                  in     varchar2 default null
,p_segment30                  in     varchar2 default null
,p_ppm_information_category   in     varchar2 default null
,p_ppm_information1           in     varchar2 default null
,p_ppm_information2           in     varchar2 default null
,p_ppm_information3           in     varchar2 default null
,p_ppm_information4           in     varchar2 default null
,p_ppm_information5           in     varchar2 default null
,p_ppm_information6           in     varchar2 default null
,p_ppm_information7           in     varchar2 default null
,p_ppm_information8           in     varchar2 default null
,p_ppm_information9           in     varchar2 default null
,p_ppm_information10          in     varchar2 default null
,p_ppm_information11          in     varchar2 default null
,p_ppm_information12          in     varchar2 default null
,p_ppm_information13          in     varchar2 default null
,p_ppm_information14          in     varchar2 default null
,p_ppm_information15          in     varchar2 default null
,p_ppm_information16          in     varchar2 default null
,p_ppm_information17          in     varchar2 default null
,p_ppm_information18          in     varchar2 default null
,p_ppm_information19          in     varchar2 default null
,p_ppm_information20          in     varchar2 default null
,p_ppm_information21          in     varchar2 default null
,p_ppm_information22          in     varchar2 default null
,p_ppm_information23          in     varchar2 default null
,p_ppm_information24          in     varchar2 default null
,p_ppm_information25          in     varchar2 default null
,p_ppm_information26          in     varchar2 default null
,p_ppm_information27          in     varchar2 default null
,p_ppm_information28          in     varchar2 default null
,p_ppm_information29          in     varchar2 default null
,p_ppm_information30          in     varchar2 default null
,p_return_status                 out nocopy varchar2
,p_msg_count                     out nocopy number
,p_msg_data                      out nocopy varchar2
);
-----------------------------< process_api >------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Internal call to the PPM APIs.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The API call is made.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-----------------------------< process_api >------------------------
procedure process_api
(p_state                      in     varchar2 default null
,p_personal_payment_method_id in     number   default null
,p_object_version_number      in     number   default null
,p_delete_ovn                 in     number   default null
,p_update_datetrack_mode      in     varchar2 default null
,p_delete_datetrack_mode      in     varchar2 default null
,p_effective_date             in     date     default null
,p_org_payment_method_id      in     number   default null
,p_assignment_id              in     number   default null
,p_run_type_id                in     number   default null
,p_territory_code             in     varchar2 default null
,p_real_priority              in     number   default null
,p_amount_type                in     varchar2 default null
,p_amount                     in     number   default null
,p_attribute_category         in     varchar2 default null
,p_attribute1                 in     varchar2 default null
,p_attribute2                 in     varchar2 default null
,p_attribute3                 in     varchar2 default null
,p_attribute4                 in     varchar2 default null
,p_attribute5                 in     varchar2 default null
,p_attribute6                 in     varchar2 default null
,p_attribute7                 in     varchar2 default null
,p_attribute8                 in     varchar2 default null
,p_attribute9                 in     varchar2 default null
,p_attribute10                in     varchar2 default null
,p_attribute11                in     varchar2 default null
,p_attribute12                in     varchar2 default null
,p_attribute13                in     varchar2 default null
,p_attribute14                in     varchar2 default null
,p_attribute15                in     varchar2 default null
,p_attribute16                in     varchar2 default null
,p_attribute17                in     varchar2 default null
,p_attribute18                in     varchar2 default null
,p_attribute19                in     varchar2 default null
,p_attribute20                in     varchar2 default null
,p_segment1                   in     varchar2 default null
,p_segment2                   in     varchar2 default null
,p_segment3                   in     varchar2 default null
,p_segment4                   in     varchar2 default null
,p_segment5                   in     varchar2 default null
,p_segment6                   in     varchar2 default null
,p_segment7                   in     varchar2 default null
,p_segment8                   in     varchar2 default null
,p_segment9                   in     varchar2 default null
,p_segment10                  in     varchar2 default null
,p_segment11                  in     varchar2 default null
,p_segment12                  in     varchar2 default null
,p_segment13                  in     varchar2 default null
,p_segment14                  in     varchar2 default null
,p_segment15                  in     varchar2 default null
,p_segment16                  in     varchar2 default null
,p_segment17                  in     varchar2 default null
,p_segment18                  in     varchar2 default null
,p_segment19                  in     varchar2 default null
,p_segment20                  in     varchar2 default null
,p_segment21                  in     varchar2 default null
,p_segment22                  in     varchar2 default null
,p_segment23                  in     varchar2 default null
,p_segment24                  in     varchar2 default null
,p_segment25                  in     varchar2 default null
,p_segment26                  in     varchar2 default null
,p_segment27                  in     varchar2 default null
,p_segment28                  in     varchar2 default null
,p_segment29                  in     varchar2 default null
,p_segment30                  in     varchar2 default null
,p_o_real_priority            in     number   default null
,p_validate                   in     boolean  default false
,p_ppm_information_category   in     varchar2 default null
,p_ppm_information1           in     varchar2 default null
,p_ppm_information2           in     varchar2 default null
,p_ppm_information3           in     varchar2 default null
,p_ppm_information4           in     varchar2 default null
,p_ppm_information5           in     varchar2 default null
,p_ppm_information6           in     varchar2 default null
,p_ppm_information7           in     varchar2 default null
,p_ppm_information8           in     varchar2 default null
,p_ppm_information9           in     varchar2 default null
,p_ppm_information10          in     varchar2 default null
,p_ppm_information11          in     varchar2 default null
,p_ppm_information12          in     varchar2 default null
,p_ppm_information13          in     varchar2 default null
,p_ppm_information14          in     varchar2 default null
,p_ppm_information15          in     varchar2 default null
,p_ppm_information16          in     varchar2 default null
,p_ppm_information17          in     varchar2 default null
,p_ppm_information18          in     varchar2 default null
,p_ppm_information19          in     varchar2 default null
,p_ppm_information20          in     varchar2 default null
,p_ppm_information21          in     varchar2 default null
,p_ppm_information22          in     varchar2 default null
,p_ppm_information23          in     varchar2 default null
,p_ppm_information24          in     varchar2 default null
,p_ppm_information25          in     varchar2 default null
,p_ppm_information26          in     varchar2 default null
,p_ppm_information27          in     varchar2 default null
,p_ppm_information28          in     varchar2 default null
,p_ppm_information29          in     varchar2 default null
,p_ppm_information30          in     varchar2 default null
);
-------------------------< get_bank_segments >----------------------
--
-- {Start Of Comments}
--
-- Description:
--   Fetch the bank segments from PAY_EXTERNAL_ACCOUNTS.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The OUT parameters are populated with the segment values.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_bank_segments
(p_external_account_id in     number
,p_segment1               out nocopy varchar2
,p_segment2               out nocopy varchar2
,p_segment3               out nocopy varchar2
,p_segment4               out nocopy varchar2
,p_segment5               out nocopy varchar2
,p_segment6               out nocopy varchar2
,p_segment7               out nocopy varchar2
,p_segment8               out nocopy varchar2
,p_segment9               out nocopy varchar2
,p_segment10              out nocopy varchar2
,p_segment11              out nocopy varchar2
,p_segment12              out nocopy varchar2
,p_segment13              out nocopy varchar2
,p_segment14              out nocopy varchar2
,p_segment15              out nocopy varchar2
,p_segment16              out nocopy varchar2
,p_segment17              out nocopy varchar2
,p_segment18              out nocopy varchar2
,p_segment19              out nocopy varchar2
,p_segment20              out nocopy varchar2
,p_segment21              out nocopy varchar2
,p_segment22              out nocopy varchar2
,p_segment23              out nocopy varchar2
,p_segment24              out nocopy varchar2
,p_segment25              out nocopy varchar2
,p_segment26              out nocopy varchar2
,p_segment27              out nocopy varchar2
,p_segment28              out nocopy varchar2
,p_segment29              out nocopy varchar2
,p_segment30              out nocopy varchar2
);
--
end pay_ppmv4_utils_ss;

/
