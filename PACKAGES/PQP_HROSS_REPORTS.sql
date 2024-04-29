--------------------------------------------------------
--  DDL for Package PQP_HROSS_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_HROSS_REPORTS" AUTHID CURRENT_USER AS
 /* $Header: pqphrossrpt.pkh 120.5 2006/01/05 04:13 nkkrishn noship $ */

-- =============================================================================
-- ~ Declare Package Variables:
-- =============================================================================

--Lexical Reference Variable
GENERIC_WHERE                             VARCHAR2(250);
PERSON_TYPE_WHERE                         VARCHAR2(250);
ORGANNIZATION_NAME_WHERE                  VARCHAR2(250);
PAYROLL_NAME_WHERE                        VARCHAR2(250);
LOCATION_NAME_WHERE                       VARCHAR2(250);
LAST_NAME_WHERE                           VARCHAR2(250);
FIRST_NAME_WHERE                          VARCHAR2(250);
NATIONAL_IDENTIFIER_WHERE                 VARCHAR2(250);
STUDENT_NUMBER_WHERE                      VARCHAR2(250);
PERSON_ID_GROUP_QUERY_WHERE               VARCHAR2(250);
PERSON_ID_LIST_WHERE                      VARCHAR2(32000);
PERSON_END_DATE_WHERE                     VARCHAR2(32000);
--PERSON_END_DATE_WHERE2                    VARCHAR2(32000);
ASSIGNMENT_END_DATE_WHERE                 VARCHAR2(32000);
ADDRESS_END_DATE_WHERE                    VARCHAR2(1000);
ORDER_BY_CLAUSE                           VARCHAR2(1000);

--Parameters passed as input to the Data Template Wrapper Concurrent Program
--P_GROUP_QUERY                  VARCHAR2(32000);
P_PERSON_ID_GROUP_QUERY        VARCHAR2(32000);
P_BUSINESS_GROUP_NAME          VARCHAR2(240);
P_BUSINESS_GROUP_ID            VARCHAR2(50);
P_EFFECTIVE_START_DATE         VARCHAR2(20);
P_EFFECTIVE_END_DATE           VARCHAR2(20);
P_PERSON_TYPE                  VARCHAR2(50);
P_PERSON_TYPE_DESC             VARCHAR2(240);
P_ORGANIZATION_NAME            VARCHAR2(240);
P_ORGANIZATION_ID              VARCHAR2(50);
P_PAYROLL_NAME                 VARCHAR2(240);
P_PAYROLL_ID                   VARCHAR2(50);
P_LOCATION_VALUE               VARCHAR2(240);
P_LOCATION_ID                  VARCHAR2(50);
P_PERSON_ID_GROUP              VARCHAR2(240);
P_LAST_NAME                    VARCHAR2(240);
P_FIRST_NAME                   VARCHAR2(240);
P_NATIONAL_IDENTIFIER          VARCHAR2(240);
P_STUDENT_NUMBER               VARCHAR2(240);
P_REPORT_NAME                  VARCHAR2(240);
P_DATA_MATCH_FILTER            VARCHAR2(20);
P_REPORT_RUN_DATE              VARCHAR2(20);
P_DATA_MATCH_FILTER_DESC       VARCHAR2(240);
P_SORT_BY                      VARCHAR2(20);
P_SORT_BY_DESC                 VARCHAR2(240);

MATCHING_RECORDS_COUNTER       NUMBER;
MISMATCH_RECORDS_COUNTER       NUMBER;

--Package Global Variables
P_DATA_MISMATCH_FLAG           BOOLEAN;

-- =============================================================================
-- ~ Before_Report_Trigger:
-- =============================================================================
PROCEDURE Before_Report_Trigger;

-- =============================================================================
-- ~ Before_Report_Trigger:
-- =============================================================================
FUNCTION Before_Report_Trigger RETURN BOOLEAN;

-- =============================================================================
-- ~ Generate_Report:
-- =============================================================================
PROCEDURE Generate_Report
         (p_person_id_group_query  IN VARCHAR2
         ,p_business_group_name    IN VARCHAR2
         ,p_business_group_id      IN VARCHAR2
         ,p_effective_start_date   IN VARCHAR2
         ,p_effective_end_date     IN VARCHAR2
         ,p_person_type            IN VARCHAR2
         ,p_person_type_desc       IN VARCHAR2
         ,p_organization_name      IN VARCHAR2
         ,p_organization_id        IN VARCHAR2
         ,p_payroll_name           IN VARCHAR2
         ,p_payroll_id             IN VARCHAR2
         ,p_location_value         IN VARCHAR2
         ,p_location_id            IN VARCHAR2
         ,p_person_id_group        IN VARCHAR2
         ,p_last_name              IN VARCHAR2
         ,p_first_name             IN VARCHAR2
         ,p_national_identifier    IN VARCHAR2
         ,p_student_number         IN VARCHAR2
         ,p_template_code          IN VARCHAR2
         ,p_template_lang          IN VARCHAR2
         ,p_template_ter           IN VARCHAR2
         ,p_output_format          IN VARCHAR2
         ,p_report_name            IN VARCHAR2
         ,p_data_match_filter      IN VARCHAR2
         ,p_report_run_date        IN VARCHAR2
         ,p_data_match_filter_desc IN VARCHAR2
         ,p_sort_by                IN VARCHAR2
         ,p_sort_by_desc           IN VARCHAR2
         ,p_return_status          IN OUT NOCOPY VARCHAR2);

-- =============================================================================
-- ~ Compare_Values: Function to determine whether two strings are the same or
-- ~ different
-- =============================================================================
FUNCTION Compare_Values
         (p_parameter1     IN VARCHAR2
         ,p_parameter2    IN VARCHAR2
          ) RETURN VARCHAR2;

-- =============================================================================
-- ~ Get_Mismatch_Indicator_Flag: Function to return Mismatch Indicator Flag
-- =============================================================================
FUNCTION Get_Mismatch_Indicator_Flag RETURN VARCHAR2;

-- =============================================================================
-- ~ Record_Filter: Function to return Mismatch Indicator Flag
-- =============================================================================
FUNCTION Record_Filter(p_mismatch_indicator_flag  IN VARCHAR2
                      ,p_full_name  IN VARCHAR2) RETURN BOOLEAN;

-- =============================================================================
-- ~ Get_Date: Function to return date value in session format
-- =============================================================================
Function Get_Date(p_date  IN DATE) RETURN VARCHAR2;

-- =============================================================================
-- ~ Get_Count: Function to return the count of matching and mismatching records
-- =============================================================================
Function Get_Count(p_parameter  IN VARCHAR2) RETURN VARCHAR2;

-- =============================================================================
-- ~ Get_Primary_Telephone_Number: Returns the secondary telephone number
-- =============================================================================
Function Get_Primary_Telephone_Number(p_owner_table_id IN VARCHAR2) RETURN VARCHAR2;

-- =============================================================================
-- ~ Get_Secondary_Telephone_Number: Returns the secondary telephone number
-- =============================================================================
Function Get_Secondary_Telephone_Number(p_owner_table_id IN VARCHAR2) RETURN VARCHAR2;

END pqp_hross_reports;

 

/
