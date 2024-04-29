--------------------------------------------------------
--  DDL for Package MSC_CL_EXCHANGE_PARTTBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_EXCHANGE_PARTTBL" AUTHID CURRENT_USER AS
/* $Header: MSCCLJAS.pls 120.14.12010000.2 2010/03/19 12:55:27 vsiyer ship $ */

   TYPE TblNmTblTyp IS TABLE OF VARCHAR2(30);
   TYPE IndNmTblTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

   TYPE rec_type IS RECORD
    ( l_index_type         varchar2(27),
      l_column_name        varchar2(4000),
      l_column_expression  varchar2(5000),
      l_column_position    number);

   TYPE IndCharTblTyp IS TABLE OF rec_type
                           INDEX BY BINARY_INTEGER;

   TYPE stg_ods_swap_rec_type
      IS RECORD (
      ods_table_name       varchar2(50),
      stg_table_name       varchar2(50),
      temp_table_name      varchar2(50),
      stg_table_partn_name varchar2(50),
      entity_name          varchar2(50),
      column_name          varchar2(50)
   );

    TYPE stg_ods_swap_tab_type IS TABLE OF stg_ods_swap_rec_type index by BINARY_INTEGER;

   SYS_YES   NUMBER:= 1;
   SYS_NO    NUMBER:= 2;

--agmcont:
   SYS_INCR                      CONSTANT NUMBER := 3; -- incr refresh
   SYS_TGT			 CONSTANT NUMBER := 4; -- targeted refresh
-- added for procedures purge_instance_plan_data, purge_instance_data and purge_plan_data
  TYPE tblTyp IS TABLE OF NUMBER;
  G_SUCCESS                    CONSTANT NUMBER := 0;
  G_WARNING                    CONSTANT NUMBER := 1;
  G_ERROR                      CONSTANT NUMBER := 2;
--
   FUNCTION Initialize( p_instance_id   IN NUMBER,
                        p_instance_code IN VARCHAR2,
                        p_is_so_cmp_rf  IN BOOLEAN)
     RETURN BOOLEAN;

FUNCTION Initialize_SWAP_Tbl_List( p_instance_id   IN NUMBER,
                                   p_instance_code IN VARCHAR2)
RETURN BOOLEAN;

   FUNCTION Create_Temp_Tbl        RETURN BOOLEAN;
   FUNCTION Exchange_Partition     RETURN BOOLEAN;
   FUNCTION Drop_Temp_Tbl          RETURN BOOLEAN;
   FUNCTION Create_Unique_Index    RETURN BOOLEAN;
   FUNCTION Create_NonUnique_Index RETURN BOOLEAN;
   FUNCTION Analyse_Temp_Tbl       RETURN BOOLEAN;

   --- PREPLACE CHANGE START ---

   TYPE CollParamREC is RECORD (
        purge_ods_flag           NUMBER,
        app_supp_cap_flag        NUMBER,
        atp_rules_flag           NUMBER,
        bom_flag                 NUMBER,
        bor_flag                 NUMBER,
        calendar_flag            NUMBER,
        demand_class_flag        NUMBER,
        item_subst_flag          NUMBER,
        forecast_flag            NUMBER,
        item_flag                NUMBER,
        kpi_bis_flag             NUMBER,
        mds_flag                 NUMBER,
        mps_flag                 NUMBER,
        oh_flag                  NUMBER,
        parameter_flag           NUMBER,
        planner_flag             NUMBER,
        project_flag             NUMBER,
        po_flag                  NUMBER,
        reserves_flag            NUMBER,
        resource_nra_flag        NUMBER,
        saf_stock_flag           NUMBER,
        sales_order_flag         NUMBER,
        source_hist_flag         NUMBER,
        sourcing_rule_flag       NUMBER,
        sub_inventory_flag       NUMBER,
        tp_customer_flag         NUMBER,
        tp_vendor_flag           NUMBER,
        unit_number_flag         NUMBER,
        uom_flag                 NUMBER,
        user_supply_demand_flag  NUMBER,
        wip_flag                 NUMBER,
        user_company_flag	 NUMBER,
        po_receipts_flag         NUMBER,
-- agmcont
-- added for continuous collections
        bom_sn_flag              number,
        bor_sn_flag              number,
        item_sn_flag             number,
        oh_sn_flag               number,
        usup_sn_flag             number,
        udmd_sn_flag             number,
        so_sn_flag               number,
        fcst_sn_flag             number,
        wip_sn_flag              number,
        supcap_sn_flag           number,
        po_sn_flag               number,
        mds_sn_flag              number,
        mps_sn_flag              number,
        nosnap_flag              number,
		supplier_response_flag   number,
		/* CP-AUTO */
		suprep_sn_flag           number,
		org_group_flag           varchar2(30),
		threshold                number   ,
		trip_flag                NUMBER,
		trip_sn_flag             NUMBER,
		ds_mode	                 NUMBER,
		sales_channel_flag       NUMBER,
		fiscal_calendar_flag     NUMBER,
		internal_repair_flag     NUMBER,
		external_repair_flag     NUMBER,
		payback_demand_supply_flag     NUMBER,
		currency_conversion_flag    NUMBER,
		delivery_details_flag    NUMBER,
		CMRO_flag    NUMBER
        );
-- Modified for bug 5935273

--agmcont
   FUNCTION Exchange_Partition  (prec CollParamREC,
                                 p_is_cont_refresh in boolean)
                                       RETURN BOOLEAN;


   FUNCTION EXCHANGE_SINGLE_TAB_PARTN ( pPartitionedTableName    IN VARCHAR2,
                                        pPartitionName           IN VARCHAR2,
                                        pUnPartitionedTableName  IN VARCHAR2,
                                        pIncludeIndexes          IN NUMBER DEFAULT MSC_UTIL.SYS_YES ) RETURN BOOLEAN;

   FUNCTION UNDO_STG_ODS_SWAP RETURN BOOLEAN;

   v_swapTblList         stg_ods_swap_tab_type;

   FUNCTION Get_Table_Index (p_table_name   VARCHAR2)
                                         RETURN INTEGER;

   FUNCTION Get_SWAP_Table_Index (p_table_name   VARCHAR2)
                                         RETURN INTEGER;

   PRAGMA RESTRICT_REFERENCES (Get_Table_Index, WNDS, WNPS);

   ---  PREPLACE CHANGE END  ---

   SPLIT_PARTITION CONSTANT  NUMBER := 1;
   ADD_PARTITION CONSTANT  NUMBER := 2;

   PROCEDURE create_partition(p_table_name    IN VARCHAR2,
                              p_part_name     IN VARCHAR2,
                              p_part_type     IN NUMBER,
                              p_high_value    IN VARCHAR2);

   PROCEDURE create_st_partition (p_instance_id IN NUMBER);

   PROCEDURE drop_st_partition (p_instance_id IN NUMBER);

   PROCEDURE modify_st_partition_add (p_instance_id IN NUMBER);

   PROCEDURE modify_st_partition_drop (p_instance_id IN NUMBER);

   FUNCTION create_temp_table_index( p_uniqueness 	IN VARCHAR2,
                                  p_part_table 	IN VARCHAR2,
                                  p_temp_table 	IN VARCHAR2,
                                  p_instance_code 	IN VARCHAR2,
                                  p_instance_id 	IN NUMBER,
                                  p_is_plan		IN NUMBER,
                                  p_error_level		IN NUMBER
                                 )
   RETURN NUMBER;


PROCEDURE list_create_def_part_stg ( ERRBUF        OUT NOCOPY VARCHAR2,
                                      RETCODE       OUT NOCOPY NUMBER,
                                      p_mode number default 0);

PROCEDURE list_drop_bad_staging_part ( ERRBUF        OUT NOCOPY VARCHAR2,
                    RETCODE       OUT NOCOPY NUMBER,
                    p_mode number default 0); -- 0 -- List; 1-  repair

PROCEDURE list_drop_bad_ods_inst_part ( ERRBUF        OUT NOCOPY VARCHAR2,
                    RETCODE       OUT NOCOPY NUMBER,
                    p_mode number default 0);

PROCEDURE list_create_missing_ods_partn(  ERRBUF        OUT NOCOPY VARCHAR2,
                                          RETCODE       OUT NOCOPY NUMBER,
                                          p_mode          number default 0);

PROCEDURE list_create_missing_stg_part(  ERRBUF        OUT NOCOPY VARCHAR2,
                                          RETCODE       OUT NOCOPY NUMBER,
                                          p_mode          number default 0);

PROCEDURE Clean_Instance_partitions(  ERRBUF        OUT NOCOPY VARCHAR2,
                                    RETCODE       OUT NOCOPY NUMBER,
                                    p_mode          number default 0);

FUNCTION get_next_high_val_part(powner varchar2,
                                p_tab varchar2,
                                p_high_val  varchar2) return VARCHAR2 ;

FUNCTION COMPARE_PARTITION_BOUND(powner IN VARCHAR2,
                                 pobject_name IN VARCHAR2,
                                 pobject_type IN VARCHAR2,
                                 phval1 IN VARCHAR2,
                                 phval2 IN VARCHAR2) RETURN NUMBER;

END MSC_CL_EXCHANGE_PARTTBL;

/
