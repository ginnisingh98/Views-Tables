--------------------------------------------------------
--  DDL for Package CSI_UTILITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_UTILITY_GRP" AUTHID CURRENT_USER AS
/* $Header: csigutls.pls 120.5 2007/02/08 23:12:12 jpwilson ship $ */
    --
    --
    g_pkg_name              VARCHAR2(30) := 'CSI_UTILITY_GRP';
    --

    TYPE T_NUM   is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE T_V3    is TABLE OF VARCHAR(03) INDEX BY BINARY_INTEGER;

  TYPE OM_TXN_INFO_REC IS RECORD
  (   LINE_ID	                NUMBER := FND_API.G_MISS_NUM,
      SHIP_FROM_ORG_ID	        NUMBER := FND_API.G_MISS_NUM,
      INV_VLD_ORGANIZATION_ID	NUMBER := FND_API.G_MISS_NUM,
      HEADER_ID	                NUMBER := FND_API.G_MISS_NUM,
      REQUEST_DATE	        DATE   := FND_API.G_MISS_DATE,
      SCHEDULE_SHIP_DATE	DATE   := FND_API.G_MISS_DATE,
      INVENTORY_ITEM_ID	        NUMBER := FND_API.G_MISS_NUM);

   TYPE OM_TXN_INFO_TBL is TABLE OF OM_TXN_INFO_REC INDEX BY BINARY_INTEGER;

    -- This Function can be used to check if Oracle Installed Base
    -- Product is Installed and Active at an Implementation. This
    -- would check for a freeze_flag in Install Parameters.
    --
    FUNCTION IB_ACTIVE RETURN BOOLEAN;
        PRAGMA RESTRICT_REFERENCES( ib_active, WNDS, WNPS);
    --
    -- This Function can be used to check if Oracle Installed Base
    -- Product is Installed and Active at an Implementation. This
    -- would check for a freeze_flag in Install Parameters.
    -- This function returns a VARCHAR2 in the form 'Y' or 'N'
    -- and can be used in a SQL statement in the predicate.
    --
    FUNCTION IB_ACTIVE_FLAG RETURN VARCHAR2;
        PRAGMA RESTRICT_REFERENCES( ib_active_flag, WNDS, WNPS);


    --
    -- This function returns the version of the Installed Base
    -- This would be 1150 when it is on pre 1156
    --
    FUNCTION IB_VERSION RETURN NUMBER;
        PRAGMA RESTRICT_REFERENCES( ib_version, WNDS, WNPS);

    --
    -- This procedure checks if the installation parameters are in
    -- a frozen state and populates an error message in the message queue
    -- if not frozen. It also raises the fnd_api.g_exc_error exception
    --
    PROCEDURE check_ib_active;

  TYPE config_session_key IS RECORD(
    session_hdr_id         number,
    session_rev_num        number,
    session_item_id        number);

  TYPE config_session_keys IS TABLE OF config_session_key INDEX BY BINARY_INTEGER;

  PROCEDURE get_config_key_for_om_line(
    p_line_id              IN  number,
    x_config_session_key   OUT NOCOPY config_session_key,
    x_return_status        OUT NOCOPY varchar2,
    x_return_message       OUT NOCOPY varchar2);

  TYPE config_instance_key IS RECORD(
    inst_hdr_id            number,
    inst_rev_num           number,
    inst_item_id           number,
    inst_baseline_rev_num  number);

  TYPE config_instance_keys IS TABLE OF config_instance_key INDEX BY BINARY_INTEGER;

  PROCEDURE get_config_inst_valid_status(
    p_instance_key         IN  config_instance_key,
    x_config_valid_status  OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2,
    x_return_message       OUT NOCOPY varchar2);

  FUNCTION is_network_component(
    p_order_line_id   IN number,
    x_return_status   OUT NOCOPY varchar2)
  RETURN boolean;

  PROCEDURE vld_item_ctrl_changes (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER   := fnd_api.g_valid_level_full
    ,p_inventory_item_id     IN   NUMBER
    ,p_organization_id       IN   NUMBER
    ,p_item_attr_name        IN   VARCHAR2
    ,p_new_item_attr_value   IN   VARCHAR2
    ,p_old_item_attr_value   IN   VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2);

  FUNCTION vld_exist_txn_errors (p_item_id IN NUMBER) RETURN BOOLEAN;

  FUNCTION vld_exist_mtl_iface_recs (p_item_id IN NUMBER,
                                     p_org_id  IN NUMBER) RETURN BOOLEAN;

  FUNCTION vld_exist_mtl_temp_recs (p_item_id IN NUMBER,
                                    p_org_id  IN NUMBER) RETURN BOOLEAN;

  FUNCTION vld_exist_sfm_events(p_item_id IN NUMBER) RETURN BOOLEAN;

  FUNCTION vld_active_ib_inst(p_item_id IN NUMBER) RETURN BOOLEAN;

  /********** Start New Functions for Inventory MACD validations **********/

  -- check_inv_serial_cz_keys will call the other 3 functions internally
  -- and will return either Y or N
  --
  -- N = Serial Number is NOT in a MACD Configuration
  --
  -- Y = Serial number IS in a MACD Configuration
  --
  --
  FUNCTION check_inv_serial_cz_keys (p_inventory_item_id IN   NUMBER,
                                     p_organization_id	 IN   NUMBER,
                                     p_serial_number	 IN   VARCHAR2) RETURN VARCHAR2;


  FUNCTION check_inv_inst_cz_keys (p_inventory_item_id	IN   NUMBER,
                                   p_organization_id	IN   NUMBER,
                                   p_serial_number	IN  VARCHAR2) RETURN BOOLEAN;

  FUNCTION check_inv_error_cz_keys (p_inventory_item_id	IN   NUMBER,
                                    p_organization_id	IN   NUMBER,
                                    p_serial_number	IN  VARCHAR2) RETURN BOOLEAN;

  FUNCTION check_inv_sfm_cz_keys (p_inventory_item_id	IN   NUMBER,
                                  p_organization_id	IN   NUMBER,
                                  p_serial_number	IN  VARCHAR2) RETURN BOOLEAN;


  /********** End New Functions for Inventory MACD validations **********/


--      Name           : txn_oks_rec
--      Description    : Holds the Table of OKS transaction types alongwith the source entity ID
--      Package name   : csi_item_instance_grp
--      Type           : rec type definition, Group
--      Description    : This holds the data that is passed on by OKS(Service Contracts)
--                       for both Mass Update and IB-OKS Usability R12 functionalities

 TYPE txn_oks_rec IS RECORD
    (
       transaction_type        T_V3,
       batch_id                NUMBER        :=  NULL,
       instance_id             NUMBER        := NULL
    );

--      Name           : txn_inst_rec
--      Description    : Holds the OKS transaction type with the table of item instances impacted for it
--      Package name   : csi_item_instance_grp
--      Type           : Table and rec type definition, Group
--      Description    : This holds the list of item instances that is passed on to OKS(Service Contracts)
--                       for a particular OKS transaction type/operation.It is used by both Mass Update
--                       and IB-OKS Usability R12 functionalities

 TYPE txn_inst_rec IS RECORD
    (
       transaction_type        VARCHAR2(3)   := NULL,
       instance_tbl            T_NUM
    );


 TYPE txn_inst_tbl IS TABLE OF txn_inst_rec INDEX BY BINARY_INTEGER;

--      Name           : get_impacted_item_instances
--      Description    : This API returns the set of item instances that are impacted for a given OKS
--                       related operation (Transaction type) that is performed through that source transaction
--                       and this transaction could be a Mass update Batch OR item instance UI update etc
--                       and it reads the inheritance rules of IB for the parent-child relationship to
--                       return back the result set.Current usage is by OKS (Service contracts) and in the
--                       context of the Mass Update and IB-OKS Usability R12 functionalities

PROCEDURE get_impacted_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,x_txn_inst_tbl          OUT  NOCOPY txn_inst_tbl
    ,p_txn_oks_rec           IN   txn_oks_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 );


PROCEDURE get_instances (p_txn_oks_rec          IN              TXN_OKS_REC,
                         x_txn_inst_tbl         OUT    NOCOPY   TXN_INST_TBL,
                         x_return_status        OUT  NOCOPY VARCHAR2,
                         x_msg_count            OUT  NOCOPY NUMBER,
                         x_msg_data             OUT  NOCOPY VARCHAR2);


  -- Procedures for INV/OM Transaction Data Purge
  PROCEDURE inv_txn_data_purge(
    p_inv_period_from_date   IN DATE,
    p_inv_period_to_date     IN DATE,
    p_organization_id	     IN NUMBER,
    x_return_status          OUT NOCOPY varchar2,
    x_return_message         OUT NOCOPY varchar2);

  PROCEDURE om_txn_data_purge(
    p_om_txn_info            IN csi_utility_grp.om_txn_info_tbl,
    x_return_status          OUT NOCOPY varchar2,
    x_return_message         OUT NOCOPY varchar2);

  PROCEDURE purge_txn_detail_tables (
     errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER);

END CSI_UTILITY_GRP;

/
