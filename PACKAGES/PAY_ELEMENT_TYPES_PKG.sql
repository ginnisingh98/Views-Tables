--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: pyelt.pkh 120.2.12010000.1 2008/07/27 22:31:25 appldev ship $ */

--------------------------------------------------------------------------------
procedure validate_translation (element_type_id IN    number,
				language IN             varchar2,
                                element_name IN  varchar2,
                               reporting_name IN  varchar2,
				description IN varchar2);
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
function ELEMENT_START_DATE (p_element_type_id	number) return date;
--------------------------------------------------------------------------------
function ELEMENT_END_DATE (p_element_type_id	number) return date;
--------------------------------------------------------------------------------
procedure CHECK_FOR_PAYLINK_BATCHES (
--
p_element_type_id	number,
p_element_name		varchar2);
--------------------------------------------------------------------------------
procedure RECREATE_DB_ITEMS (
--
p_element_type_id	number,
p_effective_start_date	date	default to_date ('01/01/0001','DD/MM/YYYY'));
--------------------------------------------------------------------------------
procedure INSERT_ROW(
--
p_rowid 		in out 	nocopy varchar2,
p_element_type_id	in out	nocopy number,
p_effective_start_date 		date,
p_effective_end_date   		date,
p_business_group_id    		number,
p_legislation_code     		varchar2,
p_formula_id           		number,
p_input_currency_code  		varchar2,
p_output_currency_code          varchar2,
p_classification_id             number,
p_benefit_classification_id     number,
p_additional_entry_allowed 	varchar2,
p_adjustment_only_flag          varchar2,
p_closed_for_entry_flag         varchar2,
p_element_name                  varchar2,
-- --
p_base_element_name                  varchar2,
-- --
p_indirect_only_flag            varchar2,
p_multiple_entries_allowed 	varchar2,
p_multiply_value_flag           varchar2,
p_post_termination_rule         varchar2,
p_process_in_run_flag           varchar2,
p_processing_priority           number,
p_processing_type               varchar2,
p_standard_link_flag            varchar2,
p_comment_id                    number,
p_description                   varchar2,
p_legislation_subgroup          varchar2,
p_qualifying_age                number,
p_qualifying_length_of_service  number,
p_qualifying_units              varchar2,
p_reporting_name                varchar2,
p_attribute_category            varchar2,
p_attribute1                    varchar2,
p_attribute2                    varchar2,
p_attribute3                    varchar2,
p_attribute4                    varchar2,
p_attribute5                    varchar2,
p_attribute6                    varchar2,
p_attribute7                    varchar2,
p_attribute8                    varchar2,
p_attribute9                    varchar2,
p_attribute10                   varchar2,
p_attribute11                   varchar2,
p_attribute12                   varchar2,
p_attribute13                   varchar2,
p_attribute14                   varchar2,
p_attribute15                   varchar2,
p_attribute16                   varchar2,
p_attribute17                   varchar2,
p_attribute18                   varchar2,
p_attribute19                   varchar2,
p_attribute20                   varchar2,
p_element_information_category  varchar2,
p_element_information1          varchar2,
p_element_information2          varchar2,
p_element_information3          varchar2,
p_element_information4          varchar2,
p_element_information5          varchar2,
p_element_information6          varchar2,
p_element_information7          varchar2,
p_element_information8          varchar2,
p_element_information9          varchar2,
p_element_information10         varchar2,
p_element_information11         varchar2,
p_element_information12         varchar2,
p_element_information13         varchar2,
p_element_information14         varchar2,
p_element_information15         varchar2,
p_element_information16         varchar2,
p_element_information17         varchar2,
p_element_information18         varchar2,
p_element_information19         varchar2,
p_element_information20         varchar2,
p_non_payments_flag		varchar2,
p_default_benefit_uom           varchar2,
p_contributions_used            varchar2,
p_third_party_pay_only_flag	varchar2,
p_retro_summ_ele_id		number default null,
p_iterative_flag                varchar2 default null,
p_iterative_formula_id          number default null,
p_iterative_priority            number default null,
p_process_mode                  varchar2 default null,
p_grossup_flag                  varchar2 default null,
p_advance_indicator             varchar2 default null,
p_advance_payable               varchar2 default null,
p_advance_deduction             varchar2 default null,
p_process_advance_entry         varchar2 default null,
p_proration_group_id            number default null,
--Code added by prsundar for Continous calculation enhancement
p_proration_formula_id 		number default null,
p_recalc_event_group_id		number default null,
p_once_each_period_flag         varchar2 default null,
-- Added for FLSA Dynamic Period Allocation
p_time_definition_type		varchar2 default null,
p_time_definition_id		varchar2 default null,
-- Added for Advance Pay Enhancement
p_advance_element_type_id	number default null,
p_deduction_element_type_id	number default null
);
--------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW(
--
p_rowid 				varchar2,
p_element_type_id               	number,
p_effective_start_date          	date,
p_effective_end_date            	date,
p_business_group_id             	number,
p_legislation_code              	varchar2,
p_formula_id                    	number,
p_input_currency_code           	varchar2,
p_output_currency_code          	varchar2,
p_classification_id             	number,
p_benefit_classification_id     	number,
p_additional_entry_allowed 		varchar2,
p_adjustment_only_flag          	varchar2,
p_closed_for_entry_flag         	varchar2,
p_element_name                  	varchar2,
p_indirect_only_flag            	varchar2,
p_multiple_entries_allowed 		varchar2,
p_multiply_value_flag           	varchar2,
p_post_termination_rule         	varchar2,
p_process_in_run_flag           	varchar2,
p_processing_priority           	number,
p_processing_type               	varchar2,
p_standard_link_flag            	varchar2,
p_comment_id                    	number,
p_description                   	varchar2,
p_legislation_subgroup          	varchar2,
p_qualifying_age                	number,
p_qualifying_length_of_service  	number,
p_qualifying_units              	varchar2,
p_reporting_name                	varchar2,
p_attribute_category            	varchar2,
p_attribute1                    	varchar2,
p_attribute2                    	varchar2,
p_attribute3                    	varchar2,
p_attribute4                    	varchar2,
p_attribute5                    	varchar2,
p_attribute6                    	varchar2,
p_attribute7                    	varchar2,
p_attribute8                    	varchar2,
p_attribute9                    	varchar2,
p_attribute10                   	varchar2,
p_attribute11                   	varchar2,
p_attribute12                   	varchar2,
p_attribute13                   	varchar2,
p_attribute14                   	varchar2,
p_attribute15                   	varchar2,
p_attribute16                   	varchar2,
p_attribute17                   	varchar2,
p_attribute18                   	varchar2,
p_attribute19                   	varchar2,
p_attribute20                   	varchar2,
p_element_information_category  	varchar2,
p_element_information1          	varchar2,
p_element_information2          	varchar2,
p_element_information3          	varchar2,
p_element_information4          	varchar2,
p_element_information5          	varchar2,
p_element_information6          	varchar2,
p_element_information7          	varchar2,
p_element_information8          	varchar2,
p_element_information9          	varchar2,
p_element_information10         	varchar2,
p_element_information11         	varchar2,
p_element_information12         	varchar2,
p_element_information13         	varchar2,
p_element_information14         	varchar2,
p_element_information15         	varchar2,
p_element_information16         	varchar2,
p_element_information17         	varchar2,
p_element_information18         	varchar2,
p_element_information19         	varchar2,
p_element_information20         	varchar2,
p_third_party_pay_only_flag		varchar2,
p_retro_summ_ele_id			number   default null,
p_iterative_flag                        varchar2 default null,
p_iterative_formula_id                  number default null,
p_iterative_priority                    number default null,
p_process_mode                          varchar2 default null,
p_grossup_flag                          varchar2 default null,
p_advance_indicator                     varchar2 default null,
p_advance_payable                       varchar2 default null,
p_advance_deduction                     varchar2 default null,
p_process_advance_entry                 varchar2 default null,
p_proration_group_id                    number default null,
p_base_element_name                     varchar2,
--Code added by prsundar for Continous calculation enhancement
p_proration_formula_id			number default null,
p_recalc_event_group_id			number default null,
p_once_each_period_flag                 varchar2 default null,
-- Added for FLSA Dynamic Period Allocation
p_time_definition_type			varchar2 default null,
p_time_definition_id			varchar2 default null,
-- Added for Advance Pay Enhancement
p_advance_element_type_id		number default null,
p_deduction_element_type_id		number default null
 );
--------------------------------------------------------------------------------
procedure DELETE_ROW (
--
p_element_type_id	number,
p_rowid			varchar2,
p_processing_priority	number,
p_delete_mode		varchar2	default 'DELETE',
p_session_date		date		default trunc (sysdate),
p_validation_start_date	date		default to_date ('01/01/0001',
								'DD/MM/YYYY'),
p_validation_end_date	date		default to_date ('31/12/4712',
								'DD/MM/YYYY'));
--------------------------------------------------------------------------------
procedure LOCK_ROW(
--
p_rowid varchar2,
p_element_type_id               	number,
p_effective_start_date          	date,
p_effective_end_date            	date,
p_business_group_id             	number,
p_legislation_code              	varchar2,
p_formula_id                    	number,
p_input_currency_code           	varchar2,
p_output_currency_code          	varchar2,
p_classification_id             	number,
p_benefit_classification_id     	number,
p_additional_entry_allowed 		varchar2,
p_adjustment_only_flag          	varchar2,
p_closed_for_entry_flag         	varchar2,
--p_element_name                  	varchar2,
-- --
p_base_element_name                  	varchar2,
-- --
p_indirect_only_flag            	varchar2,
p_multiple_entries_allowed 		varchar2,
p_multiply_value_flag           	varchar2,
p_post_termination_rule         	varchar2,
p_process_in_run_flag           	varchar2,
p_processing_priority           	number,
p_processing_type               	varchar2,
p_standard_link_flag            	varchar2,
p_comment_id                    	number,
p_description                   	varchar2,
p_legislation_subgroup          	varchar2,
p_qualifying_age                	number,
p_qualifying_length_of_service  	number,
p_qualifying_units              	varchar2,
p_reporting_name                	varchar2,
p_attribute_category            	varchar2,
p_attribute1                    	varchar2,
p_attribute2                    	varchar2,
p_attribute3                    	varchar2,
p_attribute4                    	varchar2,
p_attribute5                    	varchar2,
p_attribute6                    	varchar2,
p_attribute7                    	varchar2,
p_attribute8                    	varchar2,
p_attribute9                    	varchar2,
p_attribute10                   	varchar2,
p_attribute11                   	varchar2,
p_attribute12                   	varchar2,
p_attribute13                   	varchar2,
p_attribute14                   	varchar2,
p_attribute15                   	varchar2,
p_attribute16                   	varchar2,
p_attribute17                   	varchar2,
p_attribute18                   	varchar2,
p_attribute19                   	varchar2,
p_attribute20                   	varchar2,
p_element_information_category  	varchar2,
p_element_information1          	varchar2,
p_element_information2          	varchar2,
p_element_information3          	varchar2,
p_element_information4          	varchar2,
p_element_information5          	varchar2,
p_element_information6          	varchar2,
p_element_information7          	varchar2,
p_element_information8          	varchar2,
p_element_information9          	varchar2,
p_element_information10         	varchar2,
p_element_information11         	varchar2,
p_element_information12         	varchar2,
p_element_information13         	varchar2,
p_element_information14         	varchar2,
p_element_information15         	varchar2,
p_element_information16         	varchar2,
p_element_information17         	varchar2,
p_element_information18         	varchar2,
p_element_information19         	varchar2,
p_element_information20         	varchar2,
p_third_party_pay_only_flag		varchar2,
p_retro_summ_ele_id			number   default null,
p_iterative_flag                        varchar2 default null,
p_iterative_formula_id                  number default null,
p_iterative_priority                    number default null,
p_process_mode                          varchar2 default null,
p_grossup_flag                          varchar2 default null,
p_advance_indicator                     varchar2 default null,
p_advance_payable                       varchar2 default null,
p_advance_deduction                     varchar2 default null,
p_process_advance_entry                 varchar2 default null,
p_proration_group_id                    number default null,
--Code added by prsundar for Continous calculation enhancement
p_proration_formula_id			number default null,
p_recalc_event_group_id			number default null,
p_once_each_period_flag                 varchar2 default null,
-- Added for FLSA Dynamic Period Allocation
p_time_definition_type			varchar2 default null,
p_time_definition_id			varchar2 default null,
-- Added for Advance Pay Enhancement
p_advance_element_type_id		number default null,
p_deduction_element_type_id		number default null
);
-----------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
p_element_type_id 	number,
p_rowid 		varchar2,
p_error_if_true		boolean		default FALSE) return boolean;
-----------------------------------------------------------------------
function STOP_ENTRY_RULES_EXIST (
--
p_element_type_id 	number,
p_validation_start_date	date 	default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date 	default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------
function RUN_RESULTS_EXIST (
--
p_element_type_id	 	number,
p_validation_start_date	date default to_date ('01/01/0001', 'DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712', 'DD/MM/YYYY'),
p_DML_action_being_checked	varchar2 default 'UPDATE',
p_error_if_true			boolean	default FALSE) return boolean;
-----------------------------------------------------------------------
function FED_BY_INDIRECT_RESULTS (
--
p_element_type_id 	number,
p_validation_start_date	date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------
function UPDATE_RECURRING_RULES_EXIST (
--
p_element_type_id 	number,
p_validation_start_date	date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------------
procedure CHECK_RELATIONSHIPS (
--
p_element_type_id 	number,
p_rowid 		varchar2,
p_validation_start_date	date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712','DD/MM/YYYY'),
p_run_results			out 	nocopy boolean,
p_element_links			out 	nocopy boolean,
p_indirect_results		out 	nocopy boolean,
p_dated_updates			out 	nocopy boolean,
p_update_recurring		out 	nocopy boolean,
p_pay_basis			out	nocopy boolean,
p_stop_entry_rules		out	nocopy boolean);
-----------------------------------------------------------------------------
function ELEMENT_IS_IN_AN_ELEMENT_SET (
--
p_element_type_id	number,
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------------
function LINKS_EXIST (
--
p_element_type_id		number,
p_validation_start_date	date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712','DD/MM/YYYY'),
p_DML_action_being_checked	varchar2	default 'UPDATE',
p_error_if_true			boolean		default FALSE) return boolean ;
-----------------------------------------------------------------------------
function COBRA_BENEFITS_EXIST (
--
p_element_type_id	number,
p_validation_start_date	date	default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date	default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------------
function DELETION_ALLOWED (
--
p_element_type_id	number,
p_processing_priority	number,
p_validation_start_date	date default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date default to_date ('31/12/4712','DD/MM/YYYY'),
p_delete_mode		varchar2	default 'ZAP') return boolean;
-----------------------------------------------------------------------------
function PRIORITY_RESULT_RULE_VIOLATED (
--
p_element_type_id	number,
p_processing_priority	number,
p_validation_start_date	date	default to_date ('01/01/0001','DD/MM/YYYY'),
p_validation_end_date	date	default to_date ('31/12/4712','DD/MM/YYYY'),
p_error_if_true		boolean	default FALSE) return boolean;
-------------------------------------------------------------------------------
function NAME_IS_NOT_UNIQUE (
--
p_element_name		varchar2,
p_element_type_id			number	default null,
p_business_group_id	number		default null,
p_legislation_code	varchar2	default null,
p_error_if_true		boolean		default FALSE) return boolean;
-----------------------------------------------------------------------------
function ELEMENT_ENTRIES_EXIST (
--
p_element_type_id	number,
p_error_if_true		boolean	default FALSE) return boolean;
-----------------------------------------------------------------------------
procedure ADD_LANGUAGE;
-----------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_E_ELEMENT_NAME in varchar2,
   X_E_LEGISLATION_CODE in varchar2,
   X_E_EFFECTIVE_START_DATE in date,
   X_E_EFFECTIVE_END_DATE in date,
   X_ELEMENT_NAME in varchar2,
   X_REPORTING_NAME in varchar2,
   X_DESCRIPTION in varchar2,
   X_OWNER in varchar2
);
-----------------------------------------------------------------------------
end PAY_ELEMENT_TYPES_PKG;

/
