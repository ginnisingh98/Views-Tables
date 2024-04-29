--------------------------------------------------------
--  DDL for Package PER_DB_PER_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DB_PER_SETUP" AUTHID CURRENT_USER AS
/* $Header: pesetupd.pkh 115.1 99/07/18 15:05:26 porting ship  $ */
/*
/*
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
 Name        : per_db_per_setup  (HEADER)

 Description : This package declares procedures required to
               create all 'set up' entities in Personnel.
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
 70.8    11-MAR-93 NKHAn		Added 'exit' to the enD
115.1    14-May-1999 mmillmor           multi-radix fix to working_hours on position
 ================================================================= */
--
 FUNCTION  insert_org_information
  ( P_ORGANIZATION_ID                 NUMBER
   ,P_ORG_INFORMATION_CONTEXT         VARCHAR2
   ,P_ORG_INFORMATION1                VARCHAR2
   ,P_ORG_INFORMATION2                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION3                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION4                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION5                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION6                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION7                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION8                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION9                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION10               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION11               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION12               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION13               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION14               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION15               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION16               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION17               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION18               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION19               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION20               VARCHAR2 DEFAULT null
  ) return NUMBER ;
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
   ,P_GRADE_STRUCTURE                 VARCHAR2  DEFAULT 'Grade Volume Data'
   ,P_PEOPLE_GROUP_STRUCTURE          VARCHAR2
                                        DEFAULT 'People Group Volume Data'
   ,P_JOB_STRUCTURE                   VARCHAR2  DEFAULT 'Job Volume Data'
   ,P_COST_ALLOCATION_STRUCTURE       VARCHAR2
                                        DEFAULT 'Cost Allocation Volume Data'
   ,P_POSITION_STRUCTURE              VARCHAR2  DEFAULT 'Position Volume Data'
   ,P_LEGISLATION_CODE                VARCHAR2  DEFAULT 'GB'
   ,P_CURRENCY_CODE                   VARCHAR2  DEFAULT 'GBP'
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
  ) return NUMBER;
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
--
end per_db_per_setup;

 

/
