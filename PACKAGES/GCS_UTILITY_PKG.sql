--------------------------------------------------------
--  DDL for Package GCS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: gcsutils.pls 120.6 2007/06/29 00:58:47 skamdar noship $ */


  -- Definition of Global Data Types and Variables

   -- Action types for writing module information to the log file.
   g_module_enter         CONSTANT VARCHAR2 (3)        := '>> ';
   g_module_success       CONSTANT VARCHAR2 (3)        := '<< ';
   g_module_failure       CONSTANT VARCHAR2 (3)        := '<x ';
   -- A newline character. Included for convenience when writing long strings.
   g_nl                   CONSTANT VARCHAR2 (1)        := fnd_global.newline;

   -- return codes for sub processes
   g_ret_sts_success CONSTANT VARCHAR2(1) := 'S';
   g_ret_sts_unexp_error CONSTANT VARCHAR2(1) := 'U';
   g_ret_sts_error CONSTANT VARCHAR2(1) := 'E';
   g_ret_sts_warn CONSTANT VARCHAR2(1) := 'W';

   -- Records, Associative Arrays, and Variables to store attribute information
   TYPE r_dimension_attr_info IS RECORD
    				(dimension_id 			NUMBER(15),
     				 attribute_id 			NUMBER(15),
     				 column_name			VARCHAR2(30),
     				 attribute_varchar_label        VARCHAR2(30),
     				 attribute_value_column_name    VARCHAR2(30),
     				 version_id			NUMBER);

   TYPE t_hash_dimension_attr_info IS
     				TABLE OF r_dimension_attr_info INDEX BY VARCHAR2(200);

   g_dimension_attr_info t_hash_dimension_attr_info;

   -- Records, Associative Arrays, and Variables to store dimensionality information
   TYPE r_gcs_dimension_info IS RECORD
      				(column_name 			VARCHAR2(30),
      				 dimension_id                   NUMBER(15),
      				 associated_value_set_id        NUMBER(15),
      				 required_for_gcs               VARCHAR2(1),
      				 required_for_fem		VARCHAR2(1),
      				 default_value                  NUMBER,
      				 detail_value_set_id            NUMBER(15),
				 dim_b_table_name		VARCHAR2(30),
				 dim_vl_view_name		VARCHAR2(30),
				 dim_member_col			VARCHAR2(30),
				 dim_member_display_code	VARCHAR2(30));

   TYPE t_hash_gcs_dimension_info IS
      				TABLE OF r_gcs_dimension_info INDEX BY VARCHAR2(30);

   g_gcs_dimension_info t_hash_gcs_dimension_info;


   -- Bugfix 5707630: Records, Associative Arrays, and Variables to store historical rates
   -- dimensionality information
   TYPE r_hrate_dim_info IS RECORD
                                (column_name 			VARCHAR2(30),
                                 required_for_hrate             VARCHAR2(1));

   TYPE t_hash_hrate_dim_info IS TABLE OF r_hrate_dim_info INDEX BY VARCHAR2(30);

   g_hrate_dim_info t_hash_hrate_dim_info;

   -- end bugfix 5707630


   -- Record to store current and prior calendar period information
   TYPE r_cal_period_info IS RECORD
      			     (cal_period_id  			NUMBER,
      			      cal_period_number                 NUMBER(15),
      			      cal_period_year                   NUMBER(15),
      			      prev_cal_period_id                NUMBER,
      			      prev_cal_period_number            NUMBER(15),
      			      prev_cal_period_year              NUMBER(15),
      			      next_cal_period_id                NUMBER,
      			      next_cal_period_number            NUMBER(15),
      			      next_cal_period_year              NUMBER(15),
      			      cal_periods_per_year              NUMBER(15));

   -- Record to store entry name and description (Added by STK 1/12/03)
   TYPE r_entry_header    IS RECORD
   			     (name				VARCHAR2(80),
   			      description			VARCHAR2(240));

  -- Added global variables (STK 2/17/04)
  g_dataprep_obj_id		NUMBER(9)	:=	1002;
  g_xlate_obj_id		NUMBER(9)	:=	1003;
  g_aggregation_obj_id		NUMBER(9)	:=	1004;
  g_intracompany_obj_id		NUMBER(9)	:=	1005;
  g_oper_adj_obj_id		NUMBER(9)	:=	1006;
  g_acq_dis_obj_id		NUMBER(9)	:=	1007;
  g_pre_interco_obj_id		NUMBER(9)	:=	1008;
  g_interco_obj_id		NUMBER(9)	:=	1009;
  g_post_interco_obj_id		NUMBER(9)	:=	1010;
  g_minority_int_obj_id		NUMBER(9)	:=	1011;
  g_pre_dataprep_obj_id		NUMBER(9)	:=	1012;
  g_pre_aggregation_obj_id	NUMBER(9)	:=	1013;
  g_gcs_source_system_code	NUMBER		:=	70;
  g_avg_fin_elem		NUMBER		:=	140;
  g_fch_global_vs_combo_id	NUMBER(9);

  --
  -- Procedure
  --   init_dimension_attr_info
  -- Purpose
  --   stores the attribute name, attribute surrogate key within a hashtable to avoid joins
  --   between GCS Modules and FEM_DIM_ATTRIBUTES_B.
  -- Arguments
  -- Notes

  PROCEDURE init_dimension_attr_info;

  --
  -- Procedure
  -- Purpose
  --   determines the associations between dimensions within FEM_BALANCES and the application GCS.
  --   (i.e. default values, part of GCS processing key, etc).
  -- Arguments
  -- Notes

  PROCEDURE init_dimension_info;



  --
  -- Procedure
  --   get_cal_period_details()
  -- Purpose
  --   extracts period attribute information for the specified period, and details for the prior period.
  -- Arguments
  --   p_cal_period_id		Reference Calendar Period
  --   p_cal_period_record	Record structure storing period attribution for refernce and previous period
  -- Notes
  --

  PROCEDURE get_cal_period_details(p_cal_period_id 	NUMBER,
  				   p_cal_period_record	IN OUT NOCOPY r_cal_period_info);


  -- STK 1/12/04
  -- Procedure
  --   get_entry_header()
  -- Purpose
  --   generates a unique name, and appropriate description for all automated GCS II processes
  -- Arguments
  --   p_process_type_code	Automated Process Values: Data Prep, Translation, Aggregation,Acquisitions and Disposals,
  --							  Pre-Intercompany, Intercompany, Post-Intercompany,
  --							  Minority Interest, Post-Minority Interest
  --   p_entry_id		Entry ID
  --   p_entity_id		Entity ID associated with process (parent entity in case of rules)
  --   p_rule_id		Required Only for Automated Rules
  -- Notes
  --
  PROCEDURE get_entry_header(	p_process_type_code	VARCHAR2,
  				p_entry_id 		NUMBER,
  				p_entity_id		NUMBER,
  				p_currency_code		VARCHAR2,
  				p_rule_id		NUMBER DEFAULT NULL,
  				p_entry_header	IN OUT NOCOPY r_entry_header);

  --
  -- Function
  --   Get_Dimension_Required
  -- Purpose
  --   Get whether or not this dimension is required. Return 'Y' or 'N'.
  -- Arguments
  --   p_dim_col	 Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Dimension_Required
  -- Notes
  --
  FUNCTION Get_Dimension_Required(p_dim_col VARCHAR2) RETURN VARCHAR2;

  --
  -- Function
  --   Get_Fem_Dim_Required
  -- Purpose
  --   Get whether or not this dimension is required for FEM. Return 'Y' or 'N'.
  -- Arguments
  --   p_dim_col	 Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Fem_Dim_Required
  -- Notes
  --
  FUNCTION Get_Fem_Dim_Required(p_dim_col VARCHAR2) RETURN VARCHAR2;


  --
  -- Function
  --   Get_Hrate_Dim_Required
  -- Purpose
  --   Get whether or not this dimension is required for Historical rates. Return 'Y' or 'N'.
  -- Arguments
  --   p_dim_col	 Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Hrate_Dim_Required
  -- Notes
  --
  FUNCTION Get_Hrate_Dim_Required(p_dim_col VARCHAR2) RETURN VARCHAR2;


  --
  -- Function
  --   Get_Default_Value
  -- Purpose
  --   Get default value for the dimension
  -- Arguments
  --   p_dim_col	 Dimension column name
  -- Example
  --   GCS_UTILITY_PKG.Get_Default_Value
  -- Notes
  --
  FUNCTION Get_Default_Value(p_dim_col VARCHAR2) RETURN NUMBER;

  --
  -- Function
  --   Get_Dimension_Attribute
  -- Purpose
  --   Get attribute_id for the dimension-attribute
  -- Arguments
  --   p_dim_attr Dimension attribute
  -- Example
  --   GCS_UTILITY_PKG.Get_Dimension_Attribute('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
  -- Notes
  --
  FUNCTION Get_Dimension_Attribute(p_dim_attr VARCHAR2) RETURN NUMBER;


  --
  -- Function
  --   Get_Org_Id(p_entity_id NUMBER, p_hierarchy_id NUMBER, p_relationship_id NUMBER) RETURN NUMBER
  -- Purpose
  --   Get org_id for the given entity. If no org_id is found, then look
  --   for org_id for the associated operating entity for this consolidation
  --   entity.  If no org_id is found, then look for org_id for any one of the
  --   child entities
  -- Arguments
  --   p_entity_id	   Entity Id
  --   p_hierarchy_id      Hierarchy Id
  --   p_relationship_id   Relationship Id
  -- Example
  --   GCS_UTILITY_PKG.Get_Org_Id
  -- Notes
  --
  FUNCTION Get_Org_Id (p_entity_id NUMBER , p_hierarchy_id NUMBER) RETURN NUMBER;

 --
  -- PROCEDURE
  --   Get_Conversion_Rate
  -- Purpose
  --   Get the conversion rate.
  --
  --
  --
  -- Arguments
  --   p_source_currency	 Source Currency
  --   p_target_currency         Target Currency
  --   p_cal_period_id           Cal Period Id
  -- Example
  --   GCS_UTILITY_PKG.Get_Conversion_Rate('EUR', 'USD',
  --                                        24528210000000000000061000200140,
  --                                        l_errbuf,
  --                                        l_errcode);
  -- Notes
  --

 PROCEDURE  get_conversion_rate (P_Source_Currency IN	 	VARCHAR2,
                                 P_Target_Currency IN     	VARCHAR2,
  			         p_cal_period_Id   IN		NUMBER,
                                 p_conversion_rate IN OUT NOCOPY      NUMBER,
                                 P_errbuf     IN OUT  NOCOPY   	VARCHAR2,
                                 p_errcode    IN OUT   NOCOPY  	NUMBER);

  --
  -- Function
  --   Get_Associated_Value_Set_Id
  -- Purpose
  --   Get associated_value_set_id for the dimension
  -- Arguments
  --   p_dim_col Dimension
  -- Example
  --   GCS_UTILITY_PKG.Get_Associated_Value_Set_Id('LINE_ITEM_ID')
  -- Notes
  --

  FUNCTION Get_Associated_Value_Set_Id(p_dim_col VARCHAR2) RETURN NUMBER;

  --
  -- Procedure
  --   populate_calendar_map_details
  -- Purpose
  --   Takes the source calendar period and maps it to the target calendar period
  -- Arguments
  --   p_source_cal_period_id	Calendar Period
  --   p_source_period_flag	Source Period
  -- Example
  -- Notes
  --

  PROCEDURE populate_calendar_map_details(p_cal_period_id       IN      NUMBER,
                                          p_source_period_flag  IN      VARCHAR2,
					  p_greater_than_flag	IN	VARCHAR2);


  --Bugfix 6160542: Making Get_Base_Org_Id to public
  -- Function
  --   Get_Base_Org_Id(p_entity_id NUMBER) RETURN NUMBER
  -- Purpose
  --   Get org_id for the given entity.
  -- Arguments
  --   p_entity_id         Entity Id
  -- Example
  --   GCS_UTILITY_PKG.Get_Org_Id
  -- Notes
  --   This is a private function, only called by the public Get_Org_Id().
  -- History
  --   23-Jun-2004  J Huang  BaseOrg enhancement. (Bug 3711204)
  --

  FUNCTION Get_Base_Org_Id(p_entity_id NUMBER) RETURN NUMBER;


END GCS_UTILITY_PKG;

/
