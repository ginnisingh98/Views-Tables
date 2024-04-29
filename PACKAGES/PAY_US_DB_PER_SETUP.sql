--------------------------------------------------------
--  DDL for Package PAY_US_DB_PER_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DB_PER_SETUP" AUTHID CURRENT_USER AS
/* $Header: pyusuelt.pkh 115.2 99/07/17 06:47:19 porting ship  $
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : pay_us_db_per_setup  (HEADER)

 Description : This package declares procedures required to
               create all 'set up' entities in Personnel for US
	       payroll testing.
               That is:

                    Business Groups,
                    HR Organizations,
                    Legal Companies,
                    Positions,
                    Jobs,
                    Grades,
 Change List
 -----------
 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
( History of pesutupd.pkh, ie. db_per_setup :-
 70.0    19-NOV-92 SZWILLIA             Date Created
 70.1    21-DEC-92 SZWILLIA             Added Person Building Blocks
 70.2    04-JAN-93 SZWILLIA             Create Applicant added.
 70.3    11-JAN-93 SZWILLIA             Corrected date defaulting
 70.4    11-JAN-93 SZWILLIA             Moved person and assignment
                                         procedures to db_per_additional
 70.5    11-JAN-93 SZWILLIA             Changed create_business_group to
                                         accept structure names not
                                         numbers
 70.6    04-MAR-93 SZWILLIA             Changed parameters to be correct
                                         format for DATEs
 70.7    09-MAR-93 SZWILLIA             Made insert_org_information public.
 70.8    11-MAR-93 NKHAn		Added 'exit' to the enD )

*** 05-AUG-93 us_pesutupd.pkh created, ie. copied from pesutupd.pkh ***
 40.0    05-AUG-93 MSWANSON		Date us_pesutupd.pkh created, ie.
                                        copied pesutupd.pkh and
                                        altered for US testing.
 40.1    08-APR-93 AKELLY     New parameters added to create_pay_ legal_company
                              to allow insert of 'Federal Tax Rules' and 'Work
                              Schedule' ddf info.  Added new procedure
                              create_company_state_rules.
 40.2    19-APR-94            Add scl dets to create_pay_legal_company.
****
 40.0    31-MAY-94 MGILMORE   Renamed.
 40.1    03-JUL-94 AROUSSEL   Tidyied up for 10G install
 40.2    01-MAR-95 MSWANSON   Add/Change for EEO and VETS100 system
			      test data creation:
				- create_est_organization,
				- create_eeo_hierarchy,
			        - create_eeo_hierarchy_version,
			        - create_eeo_hierarchy_element.
 40.3	 28-Sep-95 Akelly     Added new functions INSERT_WC_FUND,
			      INSERT_WC_RATE, CREATE_WC_CARRIER and
			      CREATE_US_LOCATION
 40.4    01-Nov-95 JThuring   Removed error checking from end of script
 115.2   14-May-1999 mmillmor multi radix fix to positions
 ================================================================= */
--
--
 FUNCTION  insert_organization_unit
  ( P_GROUP                           VARCHAR2
   ,P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP_ID               NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID      NUMBER
   ,P_LOCATION_ID                     NUMBER
   ,P_SOFT_CODING_KEYFLEX_ID          NUMBER
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2
   ,P_TYPE                            VARCHAR2
  ) return NUMBER;
--
--
  FUNCTION  create_business_group
  ( P_GROUP                           VARCHAR2  DEFAULT 'Y'
   ,P_NAME                            VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_DEFAULT_START_TIME              VARCHAR2  DEFAULT '08:00'
   ,P_DEFAULT_END_TIME                VARCHAR2  DEFAULT '17:30'
   ,P_WORKING_HOURS                   VARCHAR2  DEFAULT '37.5'
   ,P_FREQUENCY                       VARCHAR2  DEFAULT 'W'
   ,P_SHORT_NAME                      VARCHAR2
   ,P_METHOD_OF_GENERATION_EMP_NUM    VARCHAR2  DEFAULT 'A'
   ,P_METHOD_OF_GENERATION_APL_NUM    VARCHAR2  DEFAULT 'A'
   ,P_GRADE_STRUCTURE                 VARCHAR2  DEFAULT 'Grade Flexfield'
   ,P_PEOPLE_GROUP_STRUCTURE          VARCHAR2
                                        DEFAULT 'People Group Flexfield'
   ,P_JOB_STRUCTURE                   VARCHAR2  DEFAULT 'Job Flexfield'
   ,P_COST_ALLOCATION_STRUCTURE       VARCHAR2
                                        DEFAULT 'Cost Allocation Flexfield'
   ,P_POSITION_STRUCTURE              VARCHAR2  DEFAULT 'Position Flexfield'
   ,P_LEGISLATION_CODE                VARCHAR2  DEFAULT 'US'
   ,P_CURRENCY_CODE                   VARCHAR2  DEFAULT 'USD'
   ,P_FISCAL_YEAR_START               VARCHAR2  DEFAULT null
   ,P_ASSIGNMENT_STATUS_1             VARCHAR2  DEFAULT null
   ,P_ASSIGNMENT_STATUS_2             VARCHAR2  DEFAULT null
   ,P_EMPLOYMENT_CATEGORY_1	      VARCHAR2  DEFAULT null
   ,P_EMPLOYMENT_CATEGORY_2	      VARCHAR2  DEFAULT null
  ) return NUMBER;

--
--
  FUNCTION  create_per_organization
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_DEFAULT_START_TIME              VARCHAR2  DEFAULT '08:00'
   ,P_DEFAULT_END_TIME                VARCHAR2  DEFAULT '17:30'
   ,P_WORKING_HOURS                   VARCHAR2  DEFAULT '37.5'
   ,P_FREQUENCY                       VARCHAR2  DEFAULT 'W'
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
  ) return NUMBER;
--
--
 FUNCTION  create_est_organization
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
   ,P_EEO1_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_VETS100_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_REPORTING_NAME			VARCHAR2  DEFAULT null
   ,P_VETS100_REPORTING_NAME			VARCHAR2  DEFAULT null
   ,P_SIC				NUMBER    DEFAULT null
   ,P_ACTIVITY_LINE1			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE2			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE3			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE4			VARCHAR2  DEFAULT null
   ,P_APPRENTICES_EMPLOYED		VARCHAR2  DEFAULT null
  ) return NUMBER;
--
--
  FUNCTION  create_pay_legal_company
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
   ,P_COMPANY_FEDERAL_IDENTIFIER      VARCHAR2  DEFAULT null
   ,P_NACHA_COMPANY_NAME              VARCHAR2  DEFAULT null
   ,P_NACHA_IDENTIFIER                VARCHAR2  DEFAULT null
   ,P_NACHA_DISCRETIONARY_CODE        VARCHAR2  DEFAULT null
   ,P_SS_SELF_ADJUST_METHOD           VARCHAR2  DEFAULT null
   ,P_MED_SELF_ADJUST_METHOD          VARCHAR2  DEFAULT null
   ,P_FUTA_SELF_ADJUST_METHOD         VARCHAR2  DEFAULT null
   ,P_TYPE_OF_EMPLOYMENT              VARCHAR2  DEFAULT null
   ,P_TAX_GROUP                       VARCHAR2  DEFAULT null
   ,P_SUPPLEMENTAL_CALC_METHOD        VARCHAR2  DEFAULT null
   ,P_WORK_SCHEDULE_TABLE            VARCHAR2  DEFAULT 'COMPANY WORK SCHEDULES'
   ,P_WORK_SCHEDULE_NAME              VARCHAR2  DEFAULT null
   ,P_EEO1_UNIT_NUMBER                     VARCHAR2  DEFAULT null
   ,P_VETS100_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_REPORTING_NAME                  VARCHAR2  DEFAULT null
   ,P_VETS100_REPORTING_NAME                  VARCHAR2  DEFAULT null
   ,P_SIC                             VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE1                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE2                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE3                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE4                  VARCHAR2  DEFAULT null
   ,P_APPRENTICES_EMPLOYED            VARCHAR2  DEFAULT null
   ,P_EEO1_IDENTIFICATION_NUMBER      VARCHAR2  DEFAULT null
   ,P_VETS100_COMPANY_NUMBER	      VARCHAR2  DEFAULT null
   ,P_DUN_AND_BRADSTREET_NUMBER       VARCHAR2  DEFAULT null
   ,P_GRE_REPORTING_NAME                  VARCHAR2  DEFAULT null
   ,P_AFFILIATED                      VARCHAR2  DEFAULT null
   ,P_GOVERNMENT_CONTRACTOR           VARCHAR2  DEFAULT null
   ,P_ORG_TYPE	                      VARCHAR2  DEFAULT null
  ) return NUMBER;
--
--
FUNCTION create_eeo_hierarchy
  (p_hierarchy_name               VARCHAR2
  ,p_business_group_id            NUMBER
  ,p_primary_structure_flag       VARCHAR2
  ) RETURN NUMBER;
--
--
FUNCTION create_eeo_hierarchy_version
  (p_business_group_id          NUMBER
  ,p_date_from                    VARCHAR2
  ,p_organization_structure_id    NUMBER
  ,p_version_number               NUMBER
  ) return NUMBER;
--
--
FUNCTION create_eeo_hierarchy_element
  (p_business_group_id        NUMBER
  ,p_organization_id_parent   NUMBER
  ,p_org_structure_version_id NUMBER
  ,p_organization_id_child    NUMBER
  ) RETURN NUMBER;
--
--
 PROCEDURE create_company_state_rules
  (p_legal_company_id             IN NUMBER
  ,p_state_code                   IN VARCHAR2
  ,p_sui_company_state_id         IN VARCHAR2
  ,p_sit_company_state_id         IN VARCHAR2
  ,p_sui_self_adjust_method       IN VARCHAR2 DEFAULT null
  ,p_sdi_self_adjust_method       IN VARCHAR2 DEFAULT null
  ,p_sui_er_experience_rate_1     IN VARCHAR2 DEFAULT null
  ,p_sui_er_experience_rate_2     IN VARCHAR2 DEFAULT null
  ,p_wc_carrier_name              IN VARCHAR2 DEFAULT null
  ,p_employers_liability_rate     IN VARCHAR2 DEFAULT null
  ,p_experience_modification_rate IN VARCHAR2 DEFAULT null
  ,p_premium_discount_rate        IN VARCHAR2 DEFAULT null
  );
--
--
  FUNCTION create_job
  (p_default                VARCHAR2  DEFAULT 'Y'
  ,p_name                   VARCHAR2
  ,p_business_group         VARCHAR2
  ,p_date_from              DATE
  ,p_date_to                DATE      DEFAULT null
  ,p_segment1               VARCHAR2  DEFAULT null
  ,p_segment2               VARCHAR2  DEFAULT null
  ,p_segment3               VARCHAR2  DEFAULT null
  ,p_segment4               VARCHAR2  DEFAULT null
  ,p_segment5               VARCHAR2  DEFAULT null
  ,p_segment6               VARCHAR2  DEFAULT null
  ,p_segment7               VARCHAR2  DEFAULT null
  ,p_segment8               VARCHAR2  DEFAULT null
  ,p_segment9               VARCHAR2  DEFAULT null
  ,p_segment10              VARCHAR2  DEFAULT null
  ,p_segment11              VARCHAR2  DEFAULT null
  ,p_segment12              VARCHAR2  DEFAULT null
  ,p_segment13              VARCHAR2  DEFAULT null
  ,p_segment14              VARCHAR2  DEFAULT null
  ,p_segment15              VARCHAR2  DEFAULT null
  ,p_segment16              VARCHAR2  DEFAULT null
  ,p_segment17              VARCHAR2  DEFAULT null
  ,p_segment18              VARCHAR2  DEFAULT null
  ,p_segment19              VARCHAR2  DEFAULT null
  ,p_segment20              VARCHAR2  DEFAULT null
  ,p_segment21              VARCHAR2  DEFAULT null
  ,p_segment22              VARCHAR2  DEFAULT null
  ,p_segment23              VARCHAR2  DEFAULT null
  ,p_segment24              VARCHAR2  DEFAULT null
  ,p_segment25              VARCHAR2  DEFAULT null
  ,p_segment26              VARCHAR2  DEFAULT null
  ,p_segment27              VARCHAR2  DEFAULT null
  ,p_segment28              VARCHAR2  DEFAULT null
  ,p_segment29              VARCHAR2  DEFAULT null
  ,p_segment30              VARCHAR2  DEFAULT null
  ,p_context                VARCHAR2  DEFAULT null
  ,p_eeo_category           VARCHAR2  DEFAULT null
  ) return NUMBER;
--
--
FUNCTION create_position
  (p_default                VARCHAR2  DEFAULT 'Y'
  ,p_name                   VARCHAR2
  ,p_business_group         VARCHAR2
  ,p_date_effective         DATE
  ,p_date_end               DATE      DEFAULT null
  ,p_job                    VARCHAR2
  ,p_organization           VARCHAR2
  ,p_location               VARCHAR2  DEFAULT null
  ,p_time_normal_start      VARCHAR2  DEFAULT '08:00'
  ,p_time_normal_finish     VARCHAR2  DEFAULT '17:30'
  ,p_working_hours          NUMBER    DEFAULT 37.5
  ,p_frequency              VARCHAR2  DEFAULT 'W'
  ,p_probation_period       VARCHAR2  DEFAULT null
  ,p_probation_units        VARCHAR2  DEFAULT null
  ,p_relief_position        VARCHAR2  DEFAULT null
  ,p_replacement_required   VARCHAR2  DEFAULT 'N'
  ,p_successor_position     VARCHAR2  DEFAULT null
  ,p_segment1               VARCHAR2  DEFAULT null
  ,p_segment2               VARCHAR2  DEFAULT null
  ,p_segment3               VARCHAR2  DEFAULT null
  ,p_segment4               VARCHAR2  DEFAULT null
  ,p_segment5               VARCHAR2  DEFAULT null
  ,p_segment6               VARCHAR2  DEFAULT null
  ,p_segment7               VARCHAR2  DEFAULT null
  ,p_segment8               VARCHAR2  DEFAULT null
  ,p_segment9               VARCHAR2  DEFAULT null
  ,p_segment10              VARCHAR2  DEFAULT null
  ,p_segment11              VARCHAR2  DEFAULT null
  ,p_segment12              VARCHAR2  DEFAULT null
  ,p_segment13              VARCHAR2  DEFAULT null
  ,p_segment14              VARCHAR2  DEFAULT null
  ,p_segment15              VARCHAR2  DEFAULT null
  ,p_segment16              VARCHAR2  DEFAULT null
  ,p_segment17              VARCHAR2  DEFAULT null
  ,p_segment18              VARCHAR2  DEFAULT null
  ,p_segment19              VARCHAR2  DEFAULT null
  ,p_segment20              VARCHAR2  DEFAULT null
  ,p_segment21              VARCHAR2  DEFAULT null
  ,p_segment22              VARCHAR2  DEFAULT null
  ,p_segment23              VARCHAR2  DEFAULT null
  ,p_segment24              VARCHAR2  DEFAULT null
  ,p_segment25              VARCHAR2  DEFAULT null
  ,p_segment26              VARCHAR2  DEFAULT null
  ,p_segment27              VARCHAR2  DEFAULT null
  ,p_segment28              VARCHAR2  DEFAULT null
  ,p_segment29              VARCHAR2  DEFAULT null
  ,p_segment30              VARCHAR2  DEFAULT null
  ,p_comments		    LONG      DEFAULT NULL
  ) return NUMBER ;
--
--
FUNCTION create_grade
(p_default                VARCHAR2  DEFAULT 'Y'
,p_name                   VARCHAR2
,p_business_group         VARCHAR2
,p_date_from              DATE
,p_date_to                DATE      DEFAULT null
,p_sequence               VARCHAR2  DEFAULT null
,p_segment1               VARCHAR2  DEFAULT null
,p_segment2               VARCHAR2  DEFAULT null
,p_segment3               VARCHAR2  DEFAULT null
,p_segment4               VARCHAR2  DEFAULT null
,p_segment5               VARCHAR2  DEFAULT null
,p_segment6               VARCHAR2  DEFAULT null
,p_segment7               VARCHAR2  DEFAULT null
,p_segment8               VARCHAR2  DEFAULT null
,p_segment9               VARCHAR2  DEFAULT null
,p_segment10              VARCHAR2  DEFAULT null
,p_segment11              VARCHAR2  DEFAULT null
,p_segment12              VARCHAR2  DEFAULT null
,p_segment13              VARCHAR2  DEFAULT null
,p_segment14              VARCHAR2  DEFAULT null
,p_segment15              VARCHAR2  DEFAULT null
,p_segment16              VARCHAR2  DEFAULT null
,p_segment17              VARCHAR2  DEFAULT null
,p_segment18              VARCHAR2  DEFAULT null
,p_segment19              VARCHAR2  DEFAULT null
,p_segment20              VARCHAR2  DEFAULT null
,p_segment21              VARCHAR2  DEFAULT null
,p_segment22              VARCHAR2  DEFAULT null
,p_segment23              VARCHAR2  DEFAULT null
,p_segment24              VARCHAR2  DEFAULT null
,p_segment25              VARCHAR2  DEFAULT null
,p_segment26              VARCHAR2  DEFAULT null
,p_segment27              VARCHAR2  DEFAULT null
,p_segment28              VARCHAR2  DEFAULT null
,p_segment29              VARCHAR2  DEFAULT null
,p_segment30              VARCHAR2  DEFAULT null
) return NUMBER;
--
FUNCTION INSERT_WC_FUND( P_BUSINESS_GROUP_ID NUMBER,
                      P_CARRIER_ID        NUMBER,
                      P_LOCATION_ID       NUMBER DEFAULT NULL,
                      P_STATE_CODE        VARCHAR2) return NUMBER;
--
FUNCTION insert_wc_rate
	(p_fund_id	NUMBER
	,p_business_group_id	NUMBER
	,p_rate			NUMBER
	) return NUMBER;
--
FUNCTION create_us_location
  ( p_location_code		VARCHAR2
   ,p_address_line_1		VARCHAR2
   ,p_address_line_2		VARCHAR2 default null
   ,p_address_line_3            VARCHAR2 default null
   ,p_town_or_city		VARCHAR2 default null
   ,p_county			VARCHAR2 default null
   ,p_state			VARCHAR2 default null
   ,p_zip_code			VARCHAR2 default null
   ,p_telephone			VARCHAR2 default null
   ,p_fax			VARCHAR2 default null
  ) return NUMBER;
--
FUNCTION  create_wc_carrier
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
  ) return NUMBER;
--
--
end pay_us_db_per_setup;

 

/
