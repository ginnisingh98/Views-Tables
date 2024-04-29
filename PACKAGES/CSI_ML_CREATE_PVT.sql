--------------------------------------------------------
--  DDL for Package CSI_ML_CREATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_CREATE_PVT" AUTHID CURRENT_USER AS
-- $Header: csimcrts.pls 120.3 2006/02/03 15:40:25 sguthiva noship $

PROCEDURE get_iface_create_recs
 (
   p_txn_from_date         IN     VARCHAR2,
   p_txn_to_date           IN     VARCHAR2,
   p_source_system_name    IN     VARCHAR2,
   p_worker_id             IN     NUMBER,
   p_commit_recs           IN     NUMBER,
   p_instance_tbl          OUT NOCOPY CSI_DATASTRUCTURES_PUB.INSTANCE_TBL,
   p_party_tbl             OUT NOCOPY CSI_DATASTRUCTURES_PUB.PARTY_TBL,
   p_account_tbl           OUT NOCOPY CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL,
   p_ext_attrib_tbl        OUT NOCOPY CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL,
   p_price_tbl             OUT NOCOPY CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL,
   p_org_assign_tbl        OUT NOCOPY CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL,
   p_txn_tbl               OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL,
   p_party_contact_tbl     OUT NOCOPY CSI_ML_UTIL_PVT.PARTY_CONTACT_TBL_TYPE,
   x_asset_assignment_tbl  OUT NOCOPY csi_datastructures_pub.instance_asset_tbl,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_error_message         OUT NOCOPY VARCHAR2
 );

PROCEDURE get_iface_rel_recs
 (
   p_txn_from_date         IN  VARCHAR2,
   p_txn_to_date           IN  VARCHAR2,
   p_source_system_name    IN  VARCHAR2,
   p_relationship_tbl      OUT NOCOPY CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL,
   p_txn_tbl               OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_error_message         OUT NOCOPY VARCHAR2
 );

END CSI_ML_CREATE_PVT;

 

/
