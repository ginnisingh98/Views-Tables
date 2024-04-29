--------------------------------------------------------
--  DDL for Package CSI_ML_REPLACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_REPLACE_PVT" AUTHID CURRENT_USER AS
-- $Header: csimrpls.pls 115.7 2003/01/08 21:56:51 jpwilson noship $

PROCEDURE process_replace(
        p_txn_identifier IN VARCHAR2,
        p_source_system_name IN VARCHAR2,
        x_instance_tbl     OUT NOCOPY csi_datastructures_pub.instance_tbl,
        x_party_tbl        OUT NOCOPY csi_datastructures_pub.party_tbl,
        x_account_tbl      OUT NOCOPY csi_datastructures_pub.party_account_tbl,
        x_eav_tbl    OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
        x_price_tbl  OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
        x_org_assign_tbl   OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_error_message    OUT NOCOPY VARCHAR2);

END CSI_ML_REPLACE_PVT;

 

/
