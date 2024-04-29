--------------------------------------------------------
--  DDL for Package CSI_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GEN_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: csivgus.pls 120.4.12000000.2 2007/06/18 14:11:48 sdandapa ship $ */

g_pkg_name              VARCHAR2(30) := 'CSI_GEN_UTILITY_PVT';

g_audsid           NUMBER;
g_cse_install      VARCHAR2(1) := NULL;
g_debug_level            number;
g_debug_file             varchar2(30);
g_debug_file_path        varchar2(540);

--
PROCEDURE put_line(p_message IN VARCHAR2);

FUNCTION enable_trace (l_trace_flag IN VARCHAR2) RETURN VARCHAR2;

FUNCTION dump_error_stack RETURN varchar2;

PROCEDURE dump_txn_rec
     (p_txn_rec                  IN  csi_datastructures_pub.transaction_rec);

PROCEDURE dump_txn_tbl
     (p_txn_tbl                  IN  csi_datastructures_pub.transaction_tbl);

PROCEDURE dump_txn_query_rec
     (p_txn_query_rec            IN  csi_datastructures_pub.transaction_query_rec);

PROCEDURE dump_txn_sort_rec
     (p_txn_sort_rec             IN  csi_datastructures_pub.transaction_sort_rec);

PROCEDURE dump_txn_error_rec
     (p_txn_error_rec            IN  csi_datastructures_pub.transaction_error_rec);

PROCEDURE dump_rel_rec
     (p_rel_rec                  IN  csi_datastructures_pub.ii_relationship_rec);

PROCEDURE dump_rel_tbl
     (p_rel_tbl                  IN  csi_datastructures_pub.ii_relationship_tbl);

PROCEDURE dump_rel_query_rec
     (p_rel_query_rec            IN  csi_datastructures_pub.relationship_query_rec);

PROCEDURE dump_sys_rec
     (P_system_rec               IN  csi_datastructures_pub.system_rec);

PROCEDURE dump_sys_tbl
     (p_systems_tbl              IN  csi_datastructures_pub.systems_tbl);

PROCEDURE dump_sys_query_rec
     (p_system_query_rec         IN  csi_datastructures_pub.system_query_rec);

PROCEDURE dump_ext_attrib_rec
     (p_ext_attrib_rec           IN  csi_datastructures_pub.ext_attrib_rec);

PROCEDURE dump_instance_rec
     (p_instance_rec       IN  csi_datastructures_pub.instance_rec);

PROCEDURE dump_instance_query_rec
     (p_instance_query_rec       IN  csi_datastructures_pub.instance_query_rec);

PROCEDURE dump_instance_header_rec
     (p_instance_header_rec  IN  csi_datastructures_pub.instance_header_rec);

PROCEDURE dump_inst_party_id
     (p_instance_party_id_lst IN  csi_datastructures_pub.id_tbl);

PROCEDURE dump_instance_asset_rec
     (p_instance_asset_rec  IN  csi_datastructures_pub.instance_asset_rec);

PROCEDURE dump_ou_query_rec
     (p_ou_query_rec        IN  csi_datastructures_pub.organization_unit_query_rec);

PROCEDURE dump_organization_unit_rec
     (p_org_unit_rec        IN  csi_datastructures_pub.organization_units_rec);

PROCEDURE dump_organization_unit_tbl
     (p_org_unit_tbl        IN  csi_datastructures_pub.organization_units_tbl);


PROCEDURE dump_pricing_attribs_query_rec
        (pricing_attribs_query_rec  IN  csi_datastructures_pub.pricing_attribs_query_rec);

PROCEDURE dump_pricing_attribs_rec
        (p_pricing_attribs_rec  IN  csi_datastructures_pub.pricing_attribs_rec);

PROCEDURE dump_pricing_attribs_tbl
        (p_pricing_attribs_tbl  IN  csi_datastructures_pub.pricing_attribs_tbl);

PROCEDURE dump_party_rec
        (p_party_rec            IN  csi_datastructures_pub.party_rec);

PROCEDURE dump_version_label_rec
        (p_version_label_rec    IN  csi_datastructures_pub.version_label_rec);

PROCEDURE dump_party_query_rec
        (p_party_query_rec      IN  csi_datastructures_pub.party_query_rec);

PROCEDURE dump_party_tbl
        (p_party_tbl            IN  csi_datastructures_pub.party_tbl);

PROCEDURE dump_version_label_tbl
        (p_version_label_tbl            IN  csi_datastructures_pub.version_label_tbl);

PROCEDURE dump_party_account_tbl
        (p_party_account_tbl            IN  csi_datastructures_pub.party_account_tbl);

PROCEDURE dump_party_account_rec
        (p_party_account_rec            IN  csi_datastructures_pub.party_account_rec);

PROCEDURE dump_ext_attrib_values_rec
     (p_ext_attrib_values_rec       IN  csi_datastructures_pub.extend_attrib_values_rec);

 PROCEDURE dump_ext_attrib_values_tbl
     (p_ext_attrib_values_tbl      IN  csi_datastructures_pub.extend_attrib_values_tbl);

PROCEDURE dump_ext_attrib_query_rec
     (p_ext_attrib_query_rec       IN  csi_datastructures_pub.extend_attrib_query_rec);

PROCEDURE dump_account_query_rec
     (p_account_query_rec          IN  csi_datastructures_pub.party_account_query_rec);

PROCEDURE dump_asset_query_rec
     (p_asset_query_rec           IN  csi_datastructures_pub.instance_asset_query_rec);

PROCEDURE dump_ver_label_query_rec
     (p_version_label_query_rec   IN  csi_datastructures_pub.version_label_query_rec);


PROCEDURE dump_id_tbl
        (id_tbl  IN  csi_datastructures_pub.id_tbl);

PROCEDURE dump_x_msg_data
        (p_msg_count in number, x_msg_data out NOCOPY varchar2);

PROCEDURE dump_oks_txn_inst_tbl(p_oks_txn_inst_tbl   IN oks_ibint_pub.txn_instance_tbl);
--
PROCEDURE dump_call_batch_val
     ( p_api_version           IN    NUMBER
      ,p_init_msg_list         IN    VARCHAR2
      ,p_parameter_name        IN    csi_datastructures_pub.parameter_name
      ,p_parameter_value       IN    csi_datastructures_pub.parameter_value
      );

PROCEDURE Populate_Install_Param_Rec;

FUNCTION IB_ACTIVE RETURN BOOLEAN;

FUNCTION is_eib_installed RETURN VARCHAR2;

END CSI_GEN_UTILITY_PVT;


 

/
