--------------------------------------------------------
--  DDL for Package GHR_NFC_POSITION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NFC_POSITION_EXTRACTS" AUTHID CURRENT_USER As
/* $Header: ghrnfcpext.pkh 120.0 2005/06/24 07:30:09 appldev noship $ */


g_proc_name  Varchar2(200) :='GHR_NFC_POSITION_EXTRACTS.';

TYPE r_pqp_rules IS RECORD           (rep_attribute_name  VARCHAR2(80)
                                     ,record_indicator    VARCHAR2(2)
                                     , db_column_name      VARCHAR2(80)
                                     ,sequence            NUMBER
                                     );

TYPE t_pqp_rules is Table OF r_pqp_rules
                   INDEX BY BINARY_INTEGER;

TYPE r_pqp_metadata_master IS RECORD ( context_name        VARCHAR2(80)
                                     , segment_name        VARCHAR2(80)
                                     , db_column_name      VARCHAR2(80)
                                     , rep_attribute_name  VARCHAR2(80)
                                     , record_indicator    VARCHAR2(2)
                                     , rule                VARCHAR2(1)
                                     , sequence            NUMBER);

TYPE t_pqp_metadata_master is Table OF r_pqp_metadata_master
                   INDEX BY BINARY_INTEGER;


TYPE r_pqp_record_values IS RECORD ( sequence            NUMBER
                                    ,attribute_name      VARCHAR2(160)
                                    ,attribute_value     VARCHAR2(80)
                                    ,rule                VARCHAR2(1));

TYPE t_pqp_record_values is Table OF r_pqp_record_values
                   INDEX BY BINARY_INTEGER;


TYPE r_interdisciplinary_metadata  IS RECORD
                                    (int_series_code      VARCHAR2(80)
                                    ,int_title_code       VARCHAR2(80)
                                    ,int_title_suffix     VARCHAR2(80)
                                    ,int_title_prefix     VARCHAR2(80));

TYPE t_interdisciplinary_metadata  is Table OF r_interdisciplinary_metadata
                   INDEX BY BINARY_INTEGER;


TYPE valtabtyp IS TABLE OF ben_ext_rslt_dtl.val_01%TYPE
                INDEX BY BINARY_INTEGER ;

g_per_people_f              t_pqp_metadata_master;
g_per_assignments_f         t_pqp_metadata_master;
g_per_positions             t_pqp_metadata_master;
g_per_assignment_extra_info t_pqp_metadata_master;
g_per_people_extra_info     t_pqp_metadata_master;
g_per_position_extra_info   t_pqp_metadata_master;
g_ghr_pa_history            t_pqp_metadata_master;
g_position_kff              t_pqp_metadata_master;
g_grade_kff                 t_pqp_metadata_master;
g_job_kff                   t_pqp_metadata_master;
g_master_data               t_pqp_record_values;
g_individual_data           t_pqp_record_values;
g_position_id               NUMBER;
g_business_group_id         per_all_assignments_f.business_group_id%TYPE;
g_user_id                   VARCHAR2(20);
g_dept_code                 VARCHAR2(20);
g_agency_code               VARCHAR2(20);
g_poi                       VARCHAR2(20);
g_person_exist              VARCHAR2(2);
g_master_position_exist     VARCHAR2(2);
g_conc_request_id           NUMBER;
g_pqp_rules                 t_pqp_rules;
g_int_data                  t_pqp_record_values;
g_int_metadata              t_interdisciplinary_metadata;
g_ext_dtl_rcd_id         ben_ext_rcd.ext_rcd_id%type;

TYPE extract_params IS RECORD
      (session_id             number
      ,business_group_id      per_business_groups.business_group_id%TYPE
      ,concurrent_req_id      ben_ext_rslt.request_id%TYPE
      ,ext_dfn_id             ben_ext_dfn.ext_dfn_id%TYPE
      ,transmission_type      varchar2(30)
      ,date_criteria          varchar2(30)
      ,from_date              date
      ,to_date                date
      ,agency_code            varchar2(30)
      ,personnel_office_id    varchar2(90)
      ,transmission_indicator varchar2(90)
      ,signon_identification  varchar2(30)
      ,user_id                varchar2(30)
      ,dept_code              varchar2(30)
      ,payroll_id             NUMBER
      ,notify                 varchar2(90)
      );
TYPE t_extract_params IS TABLE OF extract_params INDEX BY Binary_Integer;
g_extract_params  t_extract_params;

-- =============================================================================
-- ~ NFC_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================

PROCEDURE NFC_JCL_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_extract_name                IN     VARCHAR2
	   ,p_effective_date              IN     VARCHAR2
           ,p_business_group_id           IN     NUMBER
 	   ,p_user_id                     IN     VARCHAR2
           ,p_dept_code                   IN     VARCHAR2
           ,p_agency_code                 IN     VARCHAR2
           ,p_poi                         IN     VARCHAR2
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) ;


-- =============================================================================
-- ~ NFC_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE NFC_Position_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_business_group_id           IN     NUMBER
           ,p_benefit_action_id           IN     NUMBER
           ,p_ext_dfn_id                  IN     NUMBER
	   ,p_ext_jcl_id                  IN     NUMBER
           ,p_ext_dfn_typ_id              IN     VARCHAR2
           ,p_ext_dfn_data_typ            IN     VARCHAR2
           ,p_transmission_type           IN     VARCHAR2
           ,p_date_criteria               IN     VARCHAR2
	   ,p_dummy1			  IN     VARCHAR2
	   ,p_dummy2			  IN     VARCHAR2
	   ,p_dummy3			  IN     VARCHAR2
           ,p_from_date                   IN     VARCHAR2
           ,p_to_date                     IN     VARCHAR2
           ,p_agency_code                 IN     VARCHAR2
           ,p_personnel_office_id         IN     VARCHAR2
           ,p_transmission_indicator      IN     VARCHAR2
           ,p_signon_identification       IN     VARCHAR2
           ,p_user_id                     IN     VARCHAR2
	   ,p_dept_code                   IN     VARCHAR2
	   ,p_payroll_id                  IN     NUMBER
	   ,p_notify     		  IN     VARCHAR2
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) ;


-- =============================================================================
-- Create Build_Element_Valuese
-- =============================================================================
PROCEDURE Build_Element_Values
                (p_position_id            IN per_all_positions.position_id%type
                ,p_business_group_id      IN per_all_positions.business_group_id%type
                ,p_effective_start_date   IN date  default sysdate
                ,p_effective_end_date     IN date  default sysdate
                ,p_record_indicator       IN VARCHAR2);
-- =============================================================================
-- Get_Interface_Attribute_Value
-- =============================================================================
FUNCTION Get_Interface_Attribute_Value
                       (p_Indicator          VARCHAR2
                       ,p_Attribute_name     VARCHAR2
                       ,p_sequence           NUMBER) RETURN VARCHAR2;

-- Check_Position_Type:
-- =============================================================================
FUNCTION Check_Position_Type
          (p_sub_header_type  IN VARCHAR2
          ,p_error_message    OUT NOCOPY Varchar2
           ) RETURN Varchar2;

-- Position_Sub_Header_Criteria: The Main extract criteria that would be used
-- for the position extract.
-- =============================================================================

FUNCTION Position_Sub_Header_Criteria
          (p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
	  ,p_position_id          IN hr_all_positions_f.position_id%TYPE
          ,p_warning_message      OUT NOCOPY Varchar2
          ,p_error_message        OUT NOCOPY Varchar2
           ) RETURN Varchar2 ;

-- =============================================================================
-- ~ Evaluate_SubHeader_Formula:
-- =============================================================================
FUNCTION Evaluate_SubHeader_Formula
        (p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )RETURN VARCHAR2;

-- =============================================================================
-- ~ Evaluate_SubPosition_Formula:
-- =============================================================================
FUNCTION Evaluate_SubPosition_Formula
        (p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )RETURN VARCHAR2;
-- =============================================================================
-- ~ Del_Post_Process_Recs:
-- =============================================================================
FUNCTION Del_Post_Process_Recs
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
           )RETURN NUMBER;
-- =============================================================================
-- ~ Evaluate_Detail_Rcd_Formula:
-- =============================================================================
FUNCTION Evaluate_Detail_Rcd_Formula
        (p_assignment_id       IN         NUMBER
        ,p_business_group_id   IN         NUMBER
 	,p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2) RETURN VARCHAR2;

-- =============================================================================
-- ~ Position_Person_Main_Criteria:
-- =============================================================================
FUNCTION Position_Person_Main_Criteria
          (p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN Date
	  ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
          ,p_warning_message      OUT NOCOPY Varchar2
          ,p_error_message        OUT NOCOPY Varchar2
           ) RETURN Varchar2 ;
-- =============================================================================
-- ~ Get_NFC_ConcProg_Information: Common function to get the conc.prg parameters
-- =============================================================================
FUNCTION Get_NFC_ConcProg_Information
                     (p_header_type IN VARCHAR2
                     ,p_error_message OUT NOCOPY VARCHAR2) RETURN Varchar2;


END GHR_NFC_POSITION_EXTRACTS;

 

/
