--------------------------------------------------------
--  DDL for Package CSI_CTR_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_GEN_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: csivctus.pls 120.0.12010000.4 2008/11/07 18:52:39 mashah ship $ */

g_sid       NUMBER;
g_osuser    VARCHAR2(30);
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSI_CTR_GEN_UTILITY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivctus.pls';
g_debug_level            number;
g_debug_file             varchar2(30);
g_debug_file_path        varchar2(540);
g_stop_on_debug_error    VARCHAR2(10);

FUNCTION G_MISS_NUM RETURN NUMBER;

FUNCTION G_MISS_CHAR RETURN VARCHAR2;

FUNCTION G_MISS_DATE RETURN DATE;

PROCEDURE put_line(p_message IN VARCHAR2);

PROCEDURE read_debug_profiles;

Procedure ExitWithErrMsg
(   p_msg_name		in	varchar2,
    p_token1_name	in	varchar2	:=	null,
    p_token1_val	in	varchar2	:=	null,
    p_token2_name	in	varchar2	:=	null,
    p_token2_val	in	varchar2	:=	null,
    p_token3_name	in	varchar2	:=	null,
    p_token3_val	in	varchar2	:=	null,
    p_token4_name	in	varchar2	:=	null,
    p_token4_val	in	varchar2	:=	null
);

PROCEDURE Initialize_Desc_Flex
(   p_desc_flex	IN OUT NOCOPY  csi_ctr_datastructures_pub.dff_rec_type
);


PROCEDURE Is_DescFlex_Valid
(
   p_api_name			IN	VARCHAR2,
   p_appl_short_name		IN	VARCHAR2	:=	'CSI',
   p_desc_flex_name		IN	VARCHAR2,
   p_seg_partial_name		IN	VARCHAR2,
   p_num_of_attributes		IN	NUMBER,
   p_seg_values			IN	csi_ctr_datastructures_pub.dff_rec_type,
   p_stack_err_msg		IN	BOOLEAN	:=	TRUE
);

PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_appl_short_name	IN	VARCHAR2,
    p_desc_flex_name	IN	VARCHAR2,
    p_column_name1	IN	VARCHAR2,
    p_column_name2	IN	VARCHAR2,
    p_column_name3	IN	VARCHAR2,
    p_column_name4	IN	VARCHAR2,
    p_column_name5	IN	VARCHAR2,
    p_column_name6	IN	VARCHAR2,
    p_column_name7	IN	VARCHAR2,
    p_column_name8	IN	VARCHAR2,
    p_column_name9	IN	VARCHAR2,
    p_column_name10	IN	VARCHAR2,
    p_column_name11	IN	VARCHAR2,
    p_column_name12	IN	VARCHAR2,
    p_column_name13	IN	VARCHAR2,
    p_column_name14	IN	VARCHAR2,
    p_column_name15	IN	VARCHAR2,
    p_column_name16	IN	VARCHAR2,
    p_column_name17	IN	VARCHAR2,
    p_column_name18	IN	VARCHAR2,
    p_column_name19	IN	VARCHAR2,
    p_column_name20	IN	VARCHAR2,
    p_column_name21	IN	VARCHAR2,
    p_column_name22	IN	VARCHAR2,
    p_column_name23	IN	VARCHAR2,
    p_column_name24	IN	VARCHAR2,
    p_column_name25	IN	VARCHAR2,
    p_column_name26	IN	VARCHAR2,
    p_column_name27	IN	VARCHAR2,
    p_column_name28	IN	VARCHAR2,
    p_column_name29	IN	VARCHAR2,
    p_column_name30	IN	VARCHAR2,
    p_column_value1	IN	VARCHAR2,
    p_column_value2	IN	VARCHAR2,
    p_column_value3	IN	VARCHAR2,
    p_column_value4	IN	VARCHAR2,
    p_column_value5	IN	VARCHAR2,
    p_column_value6	IN	VARCHAR2,
    p_column_value7	IN	VARCHAR2,
    p_column_value8	IN	VARCHAR2,
    p_column_value9	IN	VARCHAR2,
    p_column_value10	IN	VARCHAR2,
    p_column_value11	IN	VARCHAR2,
    p_column_value12	IN	VARCHAR2,
    p_column_value13	IN	VARCHAR2,
    p_column_value14	IN	VARCHAR2,
    p_column_value15	IN	VARCHAR2,
    p_column_value16	IN	VARCHAR2,
    p_column_value17	IN	VARCHAR2,
    p_column_value18	IN	VARCHAR2,
    p_column_value19	IN	VARCHAR2,
    p_column_value20	IN	VARCHAR2,
    p_column_value21	IN	VARCHAR2,
    p_column_value22	IN	VARCHAR2,
    p_column_value23	IN	VARCHAR2,
    p_column_value24	IN	VARCHAR2,
    p_column_value25	IN	VARCHAR2,
    p_column_value26	IN	VARCHAR2,
    p_column_value27	IN	VARCHAR2,
    p_column_value28	IN	VARCHAR2,
    p_column_value29	IN	VARCHAR2,
    p_column_value30	IN	VARCHAR2,
    p_context_value	IN	VARCHAR2,
    p_resp_appl_id	IN	NUMBER,
    p_resp_id		IN	NUMBER,
    x_return_status	OUT	NOCOPY VARCHAR2 );

PROCEDURE VALIDATE_FORMULA_CTR
(
   p_api_version        IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2	:= FND_API.G_FALSE,
   p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
   p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
   x_return_status		OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT     NOCOPY  NUMBER,
   x_msg_data		OUT     NOCOPY  VARCHAR2,
   p_counter_id		IN	NUMBER,
   x_valid_flag		OUT     NOCOPY  VARCHAR2
);

PROCEDURE VALIDATE_GRPOP_CTR
(
    p_api_version	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2	:= FND_API.G_FALSE,
    p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
    p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT     NOCOPY VARCHAR2,
    x_msg_count		OUT	NOCOPY NUMBER,
    x_msg_data		OUT	NOCOPY VARCHAR2,
    p_counter_id	IN	NUMBER,
    x_valid_flag		OUT     NOCOPY VARCHAR2
);

FUNCTION Is_StartEndDate_Valid
(
    p_st_dt              IN      DATE,
    p_end_dt             IN      DATE,
    p_stack_err_msg      IN      BOOLEAN := TRUE
) RETURN BOOLEAN;

PROCEDURE Initialize_Desc_Flex_For_Upd
(
	l_ctr_derived_filters_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec,
	l_old_ctr_derived_filters_rec IN		CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec
);

PROCEDURE check_ib_active;

PROCEDURE dump_ctr_grp_rec
   (p_counter_groups_rec IN  csi_ctr_datastructures_pub.counter_groups_rec);

PROCEDURE dump_ctr_grp_tbl
   (p_counter_groups_tbl IN  csi_ctr_datastructures_pub.counter_groups_tbl);

PROCEDURE dump_ctr_template_rec
   (p_counter_template_rec IN  csi_ctr_datastructures_pub.counter_template_rec);

PROCEDURE dump_ctr_template_tbl
   (p_counter_template_tbl IN  csi_ctr_datastructures_pub.counter_template_tbl);

PROCEDURE dump_ctr_item_assoc_rec
   (p_ctr_item_associations_rec IN  csi_ctr_datastructures_pub.ctr_item_associations_rec);

PROCEDURE dump_ctr_item_assoc_tbl
   (p_ctr_item_associations_tbl IN  csi_ctr_datastructures_pub.ctr_item_associations_tbl);

PROCEDURE dump_ctr_relationship_rec
   (p_counter_relationships_rec IN  csi_ctr_datastructures_pub.counter_relationships_rec);

PROCEDURE dump_ctr_relationship_tbl
   (p_counter_relationships_tbl IN  csi_ctr_datastructures_pub.counter_relationships_tbl);

PROCEDURE dump_ctr_property_template_rec
   (p_ctr_property_template_rec IN  csi_ctr_datastructures_pub.ctr_property_template_rec);

PROCEDURE dump_ctr_property_template_tbl
   (p_ctr_property_template_tbl IN  csi_ctr_datastructures_pub.ctr_property_template_tbl);

PROCEDURE dm_ctr_estimation_methods_rec
   (p_ctr_estimation_methods_rec IN  csi_ctr_datastructures_pub.ctr_estimation_methods_rec);

PROCEDURE dm_ctr_estimation_methods_tbl
   (p_ctr_estimation_methods_tbl IN  csi_ctr_datastructures_pub.ctr_estimation_methods_tbl);

PROCEDURE dump_ctr_derived_filters_rec
   (p_ctr_derived_filters_rec IN  csi_ctr_datastructures_pub.ctr_derived_filters_rec);

PROCEDURE dump_ctr_derived_filters_tbl
   (p_ctr_derived_filters_tbl IN  csi_ctr_datastructures_pub.ctr_derived_filters_tbl);

PROCEDURE dump_counter_instance_rec
   (p_counter_instance_rec IN  csi_ctr_datastructures_pub.counter_instance_rec);

PROCEDURE dump_counter_instance_tbl
   (p_counter_instance_tbl IN  csi_ctr_datastructures_pub.counter_instance_tbl);

PROCEDURE dump_ctr_properties_rec
   (p_ctr_properties_rec IN  csi_ctr_datastructures_pub.ctr_properties_rec);

PROCEDURE dump_ctr_properties_tbl
   (p_ctr_properties_tbl IN  csi_ctr_datastructures_pub.ctr_properties_tbl);

PROCEDURE dump_counter_associations_rec
   (p_counter_associations_rec IN  csi_ctr_datastructures_pub.counter_associations_rec);

PROCEDURE dump_counter_associations_tbl
   (p_counter_associations_tbl IN  csi_ctr_datastructures_pub.counter_associations_tbl);

PROCEDURE dump_counter_readings_rec
   (p_counter_readings_rec IN  csi_ctr_datastructures_pub.counter_readings_rec);

PROCEDURE dump_counter_readings_tbl
   (p_counter_readings_tbl IN  csi_ctr_datastructures_pub.counter_readings_tbl);

PROCEDURE dump_ctr_property_readings_rec
   (p_ctr_property_readings_rec IN  csi_ctr_datastructures_pub.ctr_property_readings_rec);

PROCEDURE dump_ctr_property_readings_tbl
   (p_ctr_property_readings_tbl IN  csi_ctr_datastructures_pub.ctr_property_readings_tbl);

PROCEDURE dump_ctr_usage_forecast_rec
   (p_ctr_usage_forecast_rec IN  csi_ctr_datastructures_pub.ctr_usage_forecast_rec);

PROCEDURE dump_ctr_usage_forecast_tbl
   (p_ctr_usage_forecast_tbl IN  csi_ctr_datastructures_pub.ctr_usage_forecast_tbl);

PROCEDURE dump_ctr_reading_lock_rec
   (p_ctr_reading_lock_rec IN  csi_ctr_datastructures_pub.ctr_reading_lock_rec);

PROCEDURE dump_ctr_reading_lock_tbl
   (p_ctr_reading_lock_tbl IN  csi_ctr_datastructures_pub.ctr_reading_lock_tbl);

PROCEDURE dm_ctr_estimated_readings_rec
   (p_ctr_estimated_readings_rec IN  csi_ctr_datastructures_pub.ctr_estimated_readings_rec);

PROCEDURE dm_ctr_estimated_readings_tbl
   (p_ctr_estimated_readings_tbl IN  csi_ctr_datastructures_pub.ctr_estimated_readings_tbl);

PROCEDURE dm_ctr_readings_interface_rec
   (p_ctr_readings_interface_rec IN  csi_ctr_datastructures_pub.ctr_readings_interface_rec);

PROCEDURE dm_ctr_readings_interface_tbl
   (p_ctr_readings_interface_tbl IN  csi_ctr_datastructures_pub.ctr_readings_interface_tbl);

PROCEDURE dm_ctr_read_prop_interface_rec
   (p_ctr_read_prop_interface_rec IN  csi_ctr_datastructures_pub.ctr_read_prop_interface_rec);

PROCEDURE dm_ctr_read_prop_interface_tbl
   (p_ctr_read_prop_interface_tbl IN  csi_ctr_datastructures_pub.ctr_read_prop_interface_tbl);

PROCEDURE dump_txn_rec
   (p_txn_rec   IN  csi_datastructures_pub.transaction_rec);

PROCEDURE dump_txn_tbl
   (p_txn_tbl   IN  csi_datastructures_pub.transaction_tbl);

END CSI_CTR_GEN_UTILITY_PVT;

/
