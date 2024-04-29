--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_RULES_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_RULES_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcterutl.pkh 120.5 2006/12/08 09:16:38 sgadipal noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_time_entry_rules_utils_pkg.';
--

CURSOR	csr_get_rules ( p_terg_id        VARCHAR2
		,       p_start_date     DATE
		,       p_end_date       DATE ) IS
SELECT	dar.name
,       NVL( dar.description, dar.name ) ter_message_name
,       dar.rule_usage
,	dar.formula_id
,	dar.mapping_id
,	dar.attribute1
,	dar.attribute2
,	dar.attribute3
,	dar.attribute4
,	dar.attribute5
,	dar.attribute6
,	dar.attribute7
,	dar.attribute8
,	dar.attribute9
,	dar.attribute10
,	dar.attribute11
,	dar.attribute12
,	dar.attribute13
,	dar.attribute14
,	dar.attribute15
,	ff.formula_name
,	terc.attribute1 rule_outcome
FROM	ff_formulas_f ff
,	hxc_time_entry_rules dar
,	hxc_time_entry_rule_comps_v terc
WHERE
	terc.time_entry_rule_group_id	= TO_NUMBER(p_terg_id)
AND
	dar.time_entry_rule_id = terc.time_entry_rule_id AND
	( p_start_date BETWEEN
	  dar.start_date AND dar.end_date
	OR
	 p_end_date BETWEEN
	 dar.start_date AND dar.end_date )
AND
	ff.formula_id(+)	= dar.formula_id AND
	dar.start_date BETWEEN
	ff.effective_start_date(+) AND ff.effective_end_date(+)
ORDER BY
	dar.start_date;

CURSOR csr_get_period_info ( p_recurring_period_id NUMBER ) IS
SELECT
	period_type
,	duration_in_days
,	start_date
FROM
	hxc_recurring_periods
WHERE
	recurring_period_id = p_recurring_period_id;

-- record and table for period information

TYPE r_period IS RECORD ( period_start	DATE
			, period_end	DATE
			, db_pre_period_start	DATE
			, db_pre_period_end	DATE
			, db_post_period_start	DATE
			, db_post_period_end	DATE
			, db_ref_period_start	DATE
			, db_ref_period_end	DATE );

TYPE t_period IS TABLE OF r_period INDEX BY BINARY_INTEGER;

-- record for timecard information

TYPE r_timecard_info IS RECORD (
		start_date	hxc_time_building_blocks.start_time%TYPE
	,	end_date	hxc_time_building_blocks.stop_time%TYPE
	,	resource_id	hxc_time_building_blocks.resource_id%TYPE
	,	timecard_bb_id  hxc_time_building_blocks.time_building_block_id%TYPE
	,	timecard_ovn    hxc_time_building_blocks.object_version_number%TYPE
	,	approval_status hxc_time_building_blocks.approval_status%TYPE
	,	bg_id           per_business_groups.business_group_id%TYPE
        ,       new             varchar2(1)
        ,       deleted         varchar2(1) );

-- record for TER information

TYPE r_ter_record IS RECORD (     ter_name  hxc_time_entry_rules.name%TYPE,
                                  ter_message_name hxc_time_entry_rules.description%TYPE,
                                  ter_usage hxc_time_entry_rules.rule_usage%TYPE,
                                  ter_formula_name ff_formulas_f.formula_name%TYPE,
                                  ter_inc_pto_plan_id pay_accrual_plans.accrual_plan_id%TYPE );
g_ter_record r_ter_record;

TYPE r_assignment_info IS RECORD (
                  assignment_id   per_all_assignments_f.assignment_id%TYPE
               ,  submission_date DATE
               ,  start_date      DATE
               ,  end_date        DATE );

TYPE t_assignment_info IS TABLE OF r_assignment_info INDEX BY BINARY_INTEGER;

g_assignment_info t_assignment_info;

-- public procedure
--   get_timecard_info
--
-- description
--   gets the timecard info for a given TCO passed from the SS timecard
--   (see r_timecard_info TYPE defined above for what timecard info is retrieved)

PROCEDURE get_timecard_info (
		p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info );

-- public procedure
--   get_timecard_info
--
-- description
--   overloaded version of above procedure which does not use
--   the time attributes table - in this case the bg_id will not be populated.

PROCEDURE get_timecard_info (
		p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info );


-- public procedure
--   get_timecard_info
--
-- description
--   overloaded version of above procedure using new HXC_BLOCK_TABLE_TYPE

PROCEDURE get_timecard_info (
		p_time_building_blocks  HXC_BLOCK_TABLE_TYPE
	,	p_timecard_rec          IN OUT NOCOPY r_timecard_info );



-- public procedure
--   calc_timecard_periods
--
-- description
--   populates a table of periods based on a given period start and start time
--   duration in days and the timecard period start and stop time and calculates
--   which the windows which actually fall within the timecard start and stop time
--   This is used to determine which hours to sum from the TCO and which to sum
--   from the database

PROCEDURE calc_timecard_periods (
		p_timecard_period_start	DATE
	,	p_timecard_period_end	DATE
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_duration_in_days	NUMBER
	,	p_periods_tab		IN OUT NOCOPY t_period );


-- public procedure
--   calc_reference_periods
--
-- description
--   populates the same table of periods based on a given period start and start time
--   duration in days and the timecard period start and stop time and calculates
--   the windows which actually fall within the timecard start and stop time
--   for the reference periods
--   This is used to determine which hours to sum from the TCO and which to sum
--   from the database

PROCEDURE calc_reference_periods (
		p_timecard_period_start	DATE
	,	p_timecard_period_end	DATE
	,	p_ref_period_start      DATE
	,	p_ref_period_end	DATE
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_duration_in_days	NUMBER
	,	p_periods_tab		IN OUT NOCOPY t_period );


PROCEDURE add_error_to_table (
		p_message_table	in out nocopy HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE
	,	p_message_name  in     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
	,	p_message_token in     VARCHAR2
	,	p_message_level in     VARCHAR2
        ,	p_message_field in     VARCHAR2
	,	p_application_short_name IN VARCHAR2 default 'HXC'
	,	p_timecard_bb_id     in     NUMBER
	,	p_time_attribute_id  in     NUMBER
        ,       p_timecard_bb_ovn    in     NUMBER default null
        ,       p_time_attribute_ovn in     NUMBER default null
        ,	p_message_extent     in     VARCHAR2 default null);	--Bug#2873563


-- ----------------------------------------------------------------------------
-- |------------------------< execute_time_entry_rules >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- This procedure is used to intialise and call the Time Entry fast formula
-- defined for a user. It is intended to be called from the timecard submission
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--   function returns TRUE if period maximu not violated
--
-- Post Failure:
--
--   function returns FALSE if the period maximum violated
--
-- Access Status:
--   Public.
--

PROCEDURE execute_time_entry_rules (
		p_operation		VARCHAR2
	,	p_time_building_blocks	hxc_self_service_time_deposit.timecard_info
	,	p_time_attributes	hxc_self_service_time_deposit.building_block_attribute_info
	,	p_messages	        IN OUT NOCOPY hxc_self_service_time_deposit.message_table
        ,       p_resubmit              VARCHAR2
        ,       p_blocks                hxc_block_table_type
        ,       p_attributes            hxc_attribute_table_type );

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< period_maximum >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- This function returns 1 or -1 depending on whether or not the person
-- has exceeded the period maximum over a spcified period.
--
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type      Description
--
--   p_resource_id                  Yes  number    resource id of the person
--   p_submission_date		    Yes  varchar2  the date of the time being submitted
--   p_period_maximum               Yes  number    period maximum
--   p_period			    Yes  number    recurring_period_id of the period we are interested in
--   p_reference_period		    Yes  number    over how many periods
--   p_pre_period_start             Yes  varchar2  time card hrs on the db before timecard period start
--   p_pre_period_end               Yes  varchar2  time card hrs on the db before timecard period end
--   p_post_period_start             No  varchar2  time card hrs on the db after timecard period start
--   p_post_period_end               No  varchar2  time card hrs on the db after timecard period end
--   p_ref_period_start		     No  varchar2  time card hrs on the db for the reference period
--   p_ref_period_end		     No  varchar2  time card hrs on the db for the reference period
--   p_duration_in_days              No  number    the duration in days of the TER period
--   p_timecard_hrs                  No  number    the number of hours on the self service timecard
--
-- Post Success:
--
--   function returns 1 if period maximum not violated
--
-- Post Failure:
--
--   function returns -1 if the period maximum violated
--
-- Access Status:
--   Public.
--
FUNCTION period_maximum (
		p_resource_id		NUMBER
	,	p_submission_date	VARCHAR2
	,	p_period_maximum	NUMBER
	,	p_period		NUMBER default 1
	,	p_reference_period	NUMBER default 1
	,	p_pre_period_start	VARCHAR2
	,	p_pre_period_end	VARCHAR2
	,	p_post_period_start	VARCHAR2 default null
	,	p_post_period_end	VARCHAR2 default null
	,	p_ref_period_start	VARCHAR2 default null
	,	p_ref_period_end	VARCHAR2 default null
	,	p_duration_in_days	NUMBER default 1
	,	p_timecard_hrs		NUMBER default 0 ) RETURN NUMBER;
--

FUNCTION period_maximum (
		p_resource_id		NUMBER
	,	p_submission_date	VARCHAR2
	,	p_period_maximum	NUMBER
	,	p_period		NUMBER default 1
	,	p_reference_period	NUMBER default 1
	,	p_pre_period_start	VARCHAR2
	,	p_pre_period_end	VARCHAR2
	,	p_post_period_start	VARCHAR2 default null
	,	p_post_period_end	VARCHAR2 default null
	,	p_ref_period_start	VARCHAR2 default null
	,	p_ref_period_end	VARCHAR2 default null
	,	p_duration_in_days	NUMBER default 1
	,	p_timecard_hrs		NUMBER default 0
        ,       p_operator              VARCHAR2 ) RETURN NUMBER;


FUNCTION asg_status_id ( p_assignment_id  NUMBER
		,	 p_effective_date VARCHAR2 ) RETURN NUMBER;

PROCEDURE tc_edit_allowed (
                         p_timecard_id                  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
			,p_timecard_ovn                 HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
                        ,p_edit_allowed_preference      HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE
                        ,p_edit_allowed IN OUT nocopy   VARCHAR2
                        );

--
-- ----------------------------------------------------------------------------
-- |----------------------<     tc_edit_allowed     >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns true in the edit allowed return variable
--   if the user is allowed to edit this timecard based on their
--   status allowing edits preference.  This version of the function
--   is introduced to support this check from the self service timecard
--   and API, where the set up validation package is issued from the
--   timecard properties package, where the status has already been
--   obtained.  If the timecard id and ovn are known, but the status
--   is not known, you can either call this function passing NULL
--   for the status, or call the overloaded function.  The status must
--   correspond to the actual timecard status, as derived from
--   the application period building blocks, i.e. the value from
--   HXC_TIMECARD_SUMMARY, and not the value from the building block
--   table.
--
-- Prerequisites:
--   This function requires a valid timecard id and object version number
--   at minimum, and a valid value for the timecard edit allowed preference
--   e.g. NEW_WORKING_REJECTED, SUBMITTED, APPROVALS_INITIATED or RETRO.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_row_data                        N varchar2 Row data object, as built
--                                                when retrieving the
--                                                timecard.
--   p_timecard_id                     Y number   Timecard Id
--   p_timecard_ovn                    Y number   Timecard Ovn
--   p_timecard_status                 N varchar2 Timecard approval status
--   p_edit_allowed_preference         Y varchar2 Status allowing edits pref
--   p_edit_allowed IN OUT nocopy      Y boolean  Return variable.
--
-- Post Success:
--   True if the user is allowed to edit the timecard, false otherwise.
--
-- Post Failure:
--   If the timecard is not found, i.e. the timecard id and ovn are invalid,
--   then an error message is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   PROCEDURE tc_edit_allowed (
                         p_timecard_id                  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
			,p_timecard_ovn                 HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
                        ,p_timecard_status              HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE
                        ,p_edit_allowed_preference      HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE
                        ,p_edit_allowed IN OUT nocopy   VARCHAR2
                        );

-- public function
--   calc_timecard_hrs (Overloaded)
--
-- description
--   New time category phase II function

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        HXC_BLOCK_TABLE_TYPE
	,	p_tco_att	        HXC_ATTRIBUTE_TABLE_TYPE
        ,       p_time_category_id      NUMBER )
RETURN NUMBER;



FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info )
RETURN NUMBER;

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info
	,	p_time_category_name    VARCHAR2 )
RETURN NUMBER;

FUNCTION calc_timecard_hrs (
		p_hrs_period_start	DATE
	,	p_hrs_period_end	DATE
	,	p_tco_bb	        hxc_self_service_time_deposit.timecard_info
	,	p_tco_att	        hxc_self_service_time_deposit.building_block_attribute_info
	,	p_time_category_id      NUMBER )
RETURN NUMBER;

FUNCTION chk_pto_plan ( p_assignment_id   NUMBER
		,       p_accrual_plan_id NUMBER
		,	p_effective_date  VARCHAR2 )
RETURN NUMBER;

PROCEDURE EXECUTE_ELP_TIME_ENTRY_RULES( P_TIME_BUILDING_BLOCKS HXC_BLOCK_TABLE_TYPE
				       ,P_TIME_ATTRIBUTES HXC_ATTRIBUTE_TABLE_TYPE
				       ,P_MESSAGES in out NOCOPY hxc_self_service_time_deposit.MESSAGE_TABLE
				       ,P_TIME_ENTRY_RULE_GROUP_ID NUMBER);

PROCEDURE EXECUTE_CLA_TIME_ENTRY_RULES( P_TIME_BUILDING_BLOCKS hxc_self_service_time_deposit.timecard_info
				       ,P_TIME_ATTRIBUTES hxc_self_service_time_deposit.building_block_attribute_info
				       ,P_MESSAGES in out NOCOPY hxc_self_service_time_deposit.MESSAGE_TABLE
      				       ,P_TIME_ENTRY_RULE_GROUP_ID NUMBER);

Type  t_change_att_rec  is record
	    ( attribute_category   hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
	      changed_attribute    VARCHAR2(80),
	      field_name           hxc_mapping_components.field_name%TYPE,
	      org_attribute_category hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
	      org_changed_attribute  VARCHAR2(80)
             );

Type  t_change_att_tab  is table of t_change_att_rec index by binary_integer;

PROCEDURE GET_PROMPTS (p_block_id in NUMBER,
		      p_blk_ovn in NUMBER,
		      p_attribute in VARCHAR2,
		      p_blk_type in VARCHAR2,
		      p_prompt in out nocopy VARCHAR2);

-- public procedure
--   publish_message
--
-- description
--   populates the message structure used in Self Service as opposed to
--   setting a raising messages using fnd_message

--   To display the message at Page level leave the p_time_building_block_id
--   and p_time_attribute_id parameters NULL.

--   To display the message at the Field Level enter either a time building
--   block id or time attribute id

-- parameters
--   p_name              - the name of the message as defined in FND_NEW_MESSAGES
--   p_message_level     - What type of message?
--                         Valid values for message_level are ERROR, WARNING
--                          or BUSINESS_MESSAGE
--   p_token_name        - the token name associated with the message (if appropriate)
--   p_token_value       - the token value associated with the message (if appropriate)
--   NOTE: token value can be up to 2000 chars long but fnd message only supports
--         message text of 2000
--   p_application_short_name - the application short code the message is registered against.
--   p_time_building_block_id - the time building block id of the item associated with the error
--   p_time_attribute_id      - the time attribute id of the item associated with the error
--   p_message_extent         - if you want you error to appear at the page level then
--                              set this parameter to 'hxc_timecard.c_blk_children_extent'
--                              otherwise leave it NULL and it will appear against the time
--                              building block id or time attribute id specified.


PROCEDURE publish_message (
		p_name          in     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
        ,       p_message_level in   VARCHAR2 DEFAULT 'ERROR'
	,	p_token_name  in     VARCHAR2 DEFAULT NULL
	,	p_token_value in     VARCHAR2 DEFAULT NULL
	,	p_application_short_name  IN VARCHAR2 default 'HXC'
	,	p_time_building_block_id  in     NUMBER
        ,       p_time_attribute_id       in     NUMBER DEFAULT NULL
        ,       p_message_extent          in     VARCHAR2 DEFAULT NULL );


-- public procedure
--   publish_message
--
-- description
--   populates the message structure used in Self Service as opposed to
--   setting a raising messages using fnd_message

--   To display the message at Page level leave the p_time_building_block_id
--   and p_time_attribute_id parameters NULL.

--   To display the message at the Field Level enter either a time building
--   block id or time attribute id

-- parameters
--   p_name              - the name of the message as defined in FND_NEW_MESSAGES
--   p_message_level     - What type of message?
--                         Valid values for message_level are ERROR, WARNING
--                          or BUSINESS_MESSAGE
--   p_token_string       - a string containing token name / token value pairs in that order
--                          delimited by the ampersand character (&)
--   NOTE: token values embedded with this string  can be up to 2000 chars long but fnd message
--         only supports message text of 2000
--   p_application_short_name - the application short code the message is registered against.
--   p_time_building_block_id - the time building block id of the item associated with the error
--   p_time_attribute_id      - the time attribute id of the item associated with the error
--   p_message_extent         - if you want you error to appear at the page level then
--                              set this parameter to 'hxc_timecard.c_blk_children_extent'
--                              otherwise leave it NULL and it will appear against the time
--                              building block id or time attribute id specified.
PROCEDURE publish_message (
		p_name          in   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
        ,       p_message_level in   VARCHAR2 DEFAULT 'ERROR'
	,	p_token_string  in   VARCHAR2 DEFAULT NULL
	,	p_application_short_name  IN VARCHAR2 default 'HXC'
	,	p_time_building_block_id  in     NUMBER
        ,       p_time_attribute_id       in     NUMBER DEFAULT NULL
        ,       p_message_extent          in     VARCHAR2 DEFAULT NULL );

FUNCTION return_archived_status (p_period IN r_period)
RETURN BOOLEAN;

function check_valid_calc_date_accrual(
		p_resource_id NUMBER
	, 	p_calculate_date DATE) return varchar2;

end hxc_time_entry_rules_utils_pkg;



/
