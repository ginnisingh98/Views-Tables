--------------------------------------------------------
--  DDL for Package CSI_DIAGNOSTICS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_DIAGNOSTICS_PKG" AUTHID CURRENT_USER as
/* $Header: csidiags.pls 120.5.12000000.1 2007/01/16 15:30:48 appldev ship $ */

  l_global_warning_flag varchar2(1) := 'N';
  l_global_sync_flag    varchar2(1) := 'N';

  TYPE T_DATE  is TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE T_NUM   is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE T_V1    is TABLE OF VARCHAR(01) INDEX BY BINARY_INTEGER;
  TYPE T_V3    is TABLE OF VARCHAR(03) INDEX BY BINARY_INTEGER;
  TYPE T_V10   is TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  TYPE T_V15   is TABLE OF VARCHAR(15) INDEX BY BINARY_INTEGER;
  TYPE T_V20   is TABLE OF VARCHAR(20) INDEX BY BINARY_INTEGER;
  TYPE T_V25   is TABLE OF VARCHAR(25) INDEX BY BINARY_INTEGER;
  TYPE T_V30   is TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  TYPE T_V35   is TABLE OF VARCHAR(35) INDEX BY BINARY_INTEGER;
  TYPE T_V40   is TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
  TYPE T_V50   is TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
  TYPE T_V60   is TABLE OF VARCHAR(60) INDEX BY BINARY_INTEGER;
  TYPE T_V80   is TABLE OF VARCHAR(80) INDEX BY BINARY_INTEGER;
  TYPE T_V85   is TABLE OF VARCHAR(85) INDEX BY BINARY_INTEGER;
  TYPE T_V150  is TABLE OF VARCHAR(150) INDEX BY BINARY_INTEGER;
  TYPE T_V240  is TABLE OF VARCHAR(240) INDEX BY BINARY_INTEGER;
  TYPE T_V360  is TABLE OF VARCHAR(360) INDEX BY BINARY_INTEGER;
  TYPE T_V1000 is TABLE OF VARCHAR(1000) INDEX BY BINARY_INTEGER;
  TYPE T_V2000 is TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  --
  TYPE INSTANCE_REC_TAB IS RECORD
     (
	INSTANCE_ID                  T_NUM
       ,INSTANCE_NUMBER              T_V30
       ,EXTERNAL_REFERENCE           T_V30
       ,INVENTORY_ITEM_ID            T_NUM
       ,VLD_ORGANIZATION_ID          T_NUM
       ,INVENTORY_REVISION           T_V3
       ,INV_MASTER_ORGANIZATION_ID   T_NUM
       ,SERIAL_NUMBER                T_V30
       ,MFG_SERIAL_NUMBER_FLAG       T_V1
       ,LOT_NUMBER                   T_V80
       ,QUANTITY                     T_NUM
       ,UNIT_OF_MEASURE              T_V3
       ,ACCOUNTING_CLASS_CODE        T_V10
       ,INSTANCE_CONDITION_ID        T_NUM
       ,INSTANCE_STATUS_ID           T_NUM
       ,CUSTOMER_VIEW_FLAG           T_V1
       ,MERCHANT_VIEW_FLAG           T_V1
       ,SELLABLE_FLAG                T_V1
       ,SYSTEM_ID                    T_NUM
       ,INSTANCE_TYPE_CODE           T_V30
       ,ACTIVE_START_DATE            T_DATE
       ,ACTIVE_END_DATE              T_DATE
       ,LOCATION_TYPE_CODE           T_V30
       ,LOCATION_ID                  T_NUM
       ,INV_ORGANIZATION_ID          T_NUM
       ,INV_SUBINVENTORY_NAME        T_V10
       ,INV_LOCATOR_ID               T_NUM
       ,PA_PROJECT_ID                T_NUM
       ,PA_PROJECT_TASK_ID           T_NUM
       ,IN_TRANSIT_ORDER_LINE_ID     T_NUM
       ,WIP_JOB_ID                   T_NUM
       ,PO_ORDER_LINE_ID             T_NUM
       ,LAST_OE_ORDER_LINE_ID        T_NUM
       ,LAST_OE_RMA_LINE_ID          T_NUM
       ,LAST_PO_PO_LINE_ID           T_NUM
       ,LAST_OE_PO_NUMBER            T_V50
       ,LAST_WIP_JOB_ID              T_NUM
       ,LAST_PA_PROJECT_ID           T_NUM
       ,LAST_PA_TASK_ID              T_NUM
       ,LAST_OE_AGREEMENT_ID         T_NUM
       ,INSTALL_DATE                 T_DATE
       ,MANUALLY_CREATED_FLAG        T_V1
       ,RETURN_BY_DATE               T_DATE
       ,ACTUAL_RETURN_DATE           T_DATE
       ,CREATION_COMPLETE_FLAG       T_V1
       ,COMPLETENESS_FLAG            T_V1
       ,VERSION_LABEL                T_V240
       ,VERSION_LABEL_DESCRIPTION    T_V240
       ,CONTEXT                      T_V30
       ,ATTRIBUTE1                   T_V240
       ,ATTRIBUTE2                   T_V240
       ,ATTRIBUTE3                   T_V240
       ,ATTRIBUTE4                   T_V240
       ,ATTRIBUTE5                   T_V240
       ,ATTRIBUTE6                   T_V240
       ,ATTRIBUTE7                   T_V240
       ,ATTRIBUTE8                   T_V240
       ,ATTRIBUTE9                   T_V240
       ,ATTRIBUTE10                  T_V240
       ,ATTRIBUTE11                  T_V240
       ,ATTRIBUTE12                  T_V240
       ,ATTRIBUTE13                  T_V240
       ,ATTRIBUTE14                  T_V240
       ,ATTRIBUTE15                  T_V240
       ,OBJECT_VERSION_NUMBER        T_NUM
       ,LAST_TXN_LINE_DETAIL_ID      T_NUM
       ,INSTALL_LOCATION_TYPE_CODE   T_V30
       ,INSTALL_LOCATION_ID          T_NUM
       ,INSTANCE_USAGE_CODE          T_V30
       ,CHECK_FOR_INSTANCE_EXPIRY    T_V1
       ,CALL_CONTRACTS               T_V1
       ,GRP_CALL_CONTRACTS           T_V1
       ,CONFIG_INST_HDR_ID           T_NUM
       ,CONFIG_INST_REV_NUM          T_NUM
       ,CONFIG_INST_ITEM_ID          T_NUM
       ,CONFIG_VALID_STATUS          T_V30
       ,INSTANCE_DESCRIPTION         T_V240
     );
  --
  TYPE ii_relationship_rec_tab IS RECORD
    (
       RELATIONSHIP_ID               T_NUM
      ,RELATIONSHIP_TYPE_CODE        T_V30
      ,OBJECT_ID                     T_NUM
      ,SUBJECT_ID                    T_NUM
      ,SUBJECT_HAS_CHILD             T_V1
      ,POSITION_REFERENCE            T_V30
      ,ACTIVE_START_DATE             T_DATE
      ,ACTIVE_END_DATE               T_DATE
      ,DISPLAY_ORDER                 T_NUM
      ,MANDATORY_FLAG                T_V1
      ,CONTEXT                       T_V30
      ,ATTRIBUTE1                    T_V150
      ,ATTRIBUTE2                    T_V150
      ,ATTRIBUTE3                    T_V150
      ,ATTRIBUTE4                    T_V150
      ,ATTRIBUTE5                    T_V150
      ,ATTRIBUTE6                    T_V150
      ,ATTRIBUTE7                    T_V150
      ,ATTRIBUTE8                    T_V150
      ,ATTRIBUTE9                    T_V150
      ,ATTRIBUTE10                   T_V150
      ,ATTRIBUTE11                   T_V150
      ,ATTRIBUTE12                   T_V150
      ,ATTRIBUTE13                   T_V150
      ,ATTRIBUTE14                   T_V150
      ,ATTRIBUTE15                   T_V150
      ,OBJECT_VERSION_NUMBER         T_NUM
  );
  TYPE VERSION_LABEL_REC_TAB IS RECORD
     (
	version_label_id            T_NUM
       ,instance_id                 T_NUM
       ,version_label               T_V240
       ,description                 T_V240
       ,date_time_stamp             T_DATE
       ,active_start_date           T_DATE
       ,active_end_date             T_DATE
       ,context                     T_V30
       ,attribute1                  T_V150
       ,attribute2                  T_V150
       ,attribute3                  T_V150
       ,attribute4                  T_V150
       ,attribute5                  T_V150
       ,attribute6                  T_V150
       ,attribute7                  T_V150
       ,attribute8                  T_V150
       ,attribute9                  T_V150
       ,attribute10                 T_V150
       ,attribute11                 T_V150
       ,attribute12                 T_V150
       ,attribute13                 T_V150
       ,attribute14                 T_V150
       ,attribute15                 T_V150
       ,object_version_number       T_NUM
     );
  --
  TYPE PARTY_REC_TAB IS RECORD
     (
	instance_party_id                      T_NUM
	,instance_id                           T_NUM
	,party_source_table                    T_V30
	,party_id                              T_NUM
	,relationship_type_code                T_V30
	,contact_flag                          T_V1
	,contact_ip_id                         T_NUM
	,active_start_date                     T_DATE
	,active_end_date                       T_DATE
	,context                               T_V30
	,attribute1                            T_V150
	,attribute2                            T_V150
	,attribute3                            T_V150
	,attribute4                            T_V150
	,attribute5                            T_V150
	,attribute6                            T_V150
	,attribute7                            T_V150
	,attribute8                            T_V150
	,attribute9                            T_V150
	,attribute10                           T_V150
	,attribute11                           T_V150
	,attribute12                           T_V150
	,attribute13                           T_V150
	,attribute14                           T_V150
	,attribute15                           T_V150
	,object_version_number                 T_NUM
	,primary_flag                          T_V1
	,preferred_flag                        T_V1
     );
  --
  TYPE ACCOUNT_REC_TAB IS RECORD
     (
	ip_account_id                 T_NUM
       ,parent_tbl_index              T_NUM
       ,instance_party_id             T_NUM
       ,party_account_id              T_NUM
       ,relationship_type_code        T_V30
       ,bill_to_address               T_NUM
       ,ship_to_address               T_NUM
       ,active_start_date             T_DATE
       ,active_end_date               T_DATE
       ,context                       T_V30
       ,attribute1                    T_V150
       ,attribute2                    T_V150
       ,attribute3                    T_V150
       ,attribute4                    T_V150
       ,attribute5                    T_V150
       ,attribute6                    T_V150
       ,attribute7                    T_V150
       ,attribute8                    T_V150
       ,attribute9                    T_V150
       ,attribute10                   T_V150
       ,attribute11                   T_V150
       ,attribute12                   T_V150
       ,attribute13                   T_V150
       ,attribute14                   T_V150
       ,attribute15                   T_V150
       ,object_version_number         T_NUM
       ,call_contracts                T_V1
       ,vld_organization_id           T_NUM
       ,expire_flag                   T_V1
     );
  --
  TYPE org_units_rec_tab IS RECORD
     (
	instance_ou_id                 T_NUM
       ,instance_id                    T_NUM
       ,operating_unit_id              T_NUM
       ,relationship_type_code         T_V30
       ,active_start_date              T_DATE
       ,active_end_date                T_DATE
       ,context                        T_V30
       ,attribute1                     T_V150
       ,attribute2                     T_V150
       ,attribute3                     T_V150
       ,attribute4                     T_V150
       ,attribute5                     T_V150
       ,attribute6                     T_V150
       ,attribute7                     T_V150
       ,attribute8                     T_V150
       ,attribute9                     T_V150
       ,attribute10                    T_V150
       ,attribute11                    T_V150
       ,attribute12                    T_V150
       ,attribute13                    T_V150
       ,attribute14                    T_V150
       ,attribute15                    T_V150
       ,object_version_number          T_NUM
     );
  --
  TYPE extend_attrib_values_rec_tab IS RECORD
   (
       attribute_value_id      T_NUM,
       instance_id             T_NUM,
       attribute_id            T_NUM,
       attribute_code          T_V30,
       attribute_value         T_V240,
       active_start_date       T_DATE,
       active_end_date         T_DATE,
       context                 T_V30,
       attribute1              T_V150,
       attribute2              T_V150,
       attribute3              T_V150,
       attribute4              T_V150,
       attribute5              T_V150,
       attribute6              T_V150,
       attribute7              T_V150,
       attribute8              T_V150,
       attribute9              T_V150,
       attribute10             T_V150,
       attribute11             T_V150,
       attribute12             T_V150,
       attribute13             T_V150,
       attribute14             T_V150,
       attribute15             T_V150,
       object_version_number   T_NUM
  );
  --
  TYPE instance_asset_rec_tab IS RECORD
   (
       instance_asset_id          T_NUM,
       instance_id                T_NUM,
       fa_asset_id                T_NUM,
       fa_book_type_code          T_V15,
       fa_location_id             T_NUM,
       asset_quantity             T_NUM,
       update_status              T_V30,
       active_start_date          T_DATE,
       active_end_date            T_DATE,
       object_version_number      T_NUM,
       check_for_instance_expiry  T_V1
  );
  --
  TYPE PRICING_ATTRIBS_REC_TAB IS RECORD
  (
    pricing_attribute_id            T_NUM
   ,instance_id                     T_NUM
   ,active_start_date               T_DATE
   ,active_end_date                 T_DATE
   ,pricing_context                 T_V30
   ,pricing_attribute1              T_V150
   ,pricing_attribute2              T_V150
   ,pricing_attribute3              T_V150
   ,pricing_attribute4              T_V150
   ,pricing_attribute5              T_V150
   ,pricing_attribute6              T_V150
   ,pricing_attribute7              T_V150
   ,pricing_attribute8              T_V150
   ,pricing_attribute9              T_V150
   ,pricing_attribute10              T_V150
   ,pricing_attribute11              T_V150
   ,pricing_attribute12              T_V150
   ,pricing_attribute13              T_V150
   ,pricing_attribute14              T_V150
   ,pricing_attribute15              T_V150
   ,pricing_attribute16              T_V150
   ,pricing_attribute17              T_V150
   ,pricing_attribute18              T_V150
   ,pricing_attribute19              T_V150
   ,pricing_attribute20              T_V150
   ,pricing_attribute21              T_V150
   ,pricing_attribute22              T_V150
   ,pricing_attribute23              T_V150
   ,pricing_attribute24              T_V150
   ,pricing_attribute25              T_V150
   ,pricing_attribute26              T_V150
   ,pricing_attribute27              T_V150
   ,pricing_attribute28              T_V150
   ,pricing_attribute29              T_V150
   ,pricing_attribute30              T_V150
   ,pricing_attribute31              T_V150
   ,pricing_attribute32              T_V150
   ,pricing_attribute33              T_V150
   ,pricing_attribute34              T_V150
   ,pricing_attribute35              T_V150
   ,pricing_attribute36              T_V150
   ,pricing_attribute37              T_V150
   ,pricing_attribute38              T_V150
   ,pricing_attribute39              T_V150
   ,pricing_attribute40              T_V150
   ,pricing_attribute41              T_V150
   ,pricing_attribute42              T_V150
   ,pricing_attribute43              T_V150
   ,pricing_attribute44              T_V150
   ,pricing_attribute45              T_V150
   ,pricing_attribute46              T_V150
   ,pricing_attribute47              T_V150
   ,pricing_attribute48              T_V150
   ,pricing_attribute49              T_V150
   ,pricing_attribute50              T_V150
   ,pricing_attribute51              T_V150
   ,pricing_attribute52              T_V150
   ,pricing_attribute53              T_V150
   ,pricing_attribute54              T_V150
   ,pricing_attribute55              T_V150
   ,pricing_attribute56              T_V150
   ,pricing_attribute57              T_V150
   ,pricing_attribute58              T_V150
   ,pricing_attribute59              T_V150
   ,pricing_attribute60              T_V150
   ,pricing_attribute61              T_V150
   ,pricing_attribute62              T_V150
   ,pricing_attribute63              T_V150
   ,pricing_attribute64              T_V150
   ,pricing_attribute65              T_V150
   ,pricing_attribute66              T_V150
   ,pricing_attribute67              T_V150
   ,pricing_attribute68              T_V150
   ,pricing_attribute69              T_V150
   ,pricing_attribute70              T_V150
   ,pricing_attribute71              T_V150
   ,pricing_attribute72              T_V150
   ,pricing_attribute73              T_V150
   ,pricing_attribute74              T_V150
   ,pricing_attribute75              T_V150
   ,pricing_attribute76              T_V150
   ,pricing_attribute77              T_V150
   ,pricing_attribute78              T_V150
   ,pricing_attribute79              T_V150
   ,pricing_attribute80              T_V150
   ,pricing_attribute81              T_V150
   ,pricing_attribute82              T_V150
   ,pricing_attribute83              T_V150
   ,pricing_attribute84              T_V150
   ,pricing_attribute85              T_V150
   ,pricing_attribute86              T_V150
   ,pricing_attribute87              T_V150
   ,pricing_attribute88              T_V150
   ,pricing_attribute89              T_V150
   ,pricing_attribute90              T_V150
   ,pricing_attribute91              T_V150
   ,pricing_attribute92              T_V150
   ,pricing_attribute93              T_V150
   ,pricing_attribute94              T_V150
   ,pricing_attribute95              T_V150
   ,pricing_attribute96              T_V150
   ,pricing_attribute97              T_V150
   ,pricing_attribute98              T_V150
   ,pricing_attribute99              T_V150
   ,pricing_attribute100              T_V150
   ,context                          T_V30
   ,attribute1                       T_V150
   ,attribute2                       T_V150
   ,attribute3                       T_V150
   ,attribute4                       T_V150
   ,attribute5                       T_V150
   ,attribute6                       T_V150
   ,attribute7                       T_V150
   ,attribute8                       T_V150
   ,attribute9                       T_V150
   ,attribute10                      T_V150
   ,attribute11                      T_V150
   ,attribute12                      T_V150
   ,attribute13                      T_V150
   ,attribute14                      T_V150
   ,attribute15                      T_V150
   ,object_version_number            T_NUM
  );

   --Type rma_txn_rec is added for bug 5248037--
  TYPE rma_txn_rec is RECORD(
    Txn_error_id        number,
    Mtl_Txn_id          number,
    Item_id             number,
    organization_id     number,
    mtl_src_line_id     number,
    mtl_creation_date   date,
    mtl_txn_qty         number,
    serial_code         number,
    owner_acct          number,
    ordered_qty         number,
    ordered_uom         varchar2(30),
    party_id            number
  );

  TYPE rma_txn_tbl is TABLE OF rma_txn_rec INDEX BY BINARY_INTEGER;

  --Type instance_rec is added for bug 5248037--
  TYPE instance_rec is RECORD(
    Instance_id           number,
    Quantity              number,
    Active_start_date     date
  );

  TYPE instance_tbl IS TABLE OF instance_rec INDEX BY BINARY_INTEGER;
  PROCEDURE insert_full_dump(p_instance_id  IN NUMBER);
  --

  PROCEDURE forward_sync;
  --
  PROCEDURE stage_soiship_instances;
  --

  PROCEDURE get_rma_owner(
    p_serial_number     in  varchar2,
    p_inventory_item_id in  number,
    p_organization_id   in  number,
    x_change_owner_flag out nocopy varchar2,
    x_owner_party_id    out nocopy number,
    x_owner_account_id  out nocopy number);

  --
  -- Data fix routines
  PROCEDURE Delete_Dup_Relationship;
  PROCEDURE Delete_Dup_Srl_Inv_Instance;
  PROCEDURE Update_Instance_Usage;
  PROCEDURE Update_Full_dump_flag;
  PROCEDURE Del_API_Dup_Srl_Instance;
  PROCEDURE Update_Vld_Organization;
  PROCEDURE Update_Revision;
  PROCEDURE Update_Dup_Srl_Instance;
  PROCEDURE Delete_Dup_Account;
  PROCEDURE Update_Instance_Party_Source;
  PROCEDURE Update_Contact_Party_Record;
  PROCEDURE Revert_Party_Rel_Type_Update;
  PROCEDURE Update_Master_Organization_ID;
  PROCEDURE Missing_MTL_Txn_ID_In_CSI;
  PROCEDURE Delete_Dup_Org_Assignments;

  --
  PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl);
  --
  PROCEDURE Get_Children
    (p_object_id     IN  NUMBER,
     p_rel_tbl       OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl);
  --
  PROCEDURE Call_Parallel_Expire(
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY NUMBER,
    p_process_code IN VaRCHAR2);

  PROCEDURE decode_queue;

  PROCEDURE get_srldata(
    p_single_error_flag  IN  varchar2 default 'N',
    p_mtl_txn_id         IN  number default null);

  PROCEDURE preprocess_srldata;
  PROCEDURE spool_srldata(p_mode in varchar2 default 'ALL');
  PROCEDURE fix_srldata;
  PROCEDURE sync_inv_serials;

  -- Non-serial specs
  PROCEDURE Expire_Non_Trackable_Instance;
  PROCEDURE Update_No_ctl_Srl_Lot_Inst;
  PROCEDURE Create_or_Update_Shipping_Inst;
  PROCEDURE IB_INV_Synch_Non_srl;
  PROCEDURE Mark_Error_Transactions;
  PROCEDURE Reverse_IB_INV_Synch;

  PROCEDURE fix_wip_usage;
  PROCEDURE delete_dup_nsrl_wip_instances;
  PROCEDURE get_nl_trackable_report;
  PROCEDURE pump_all_missing_txns;
  PROCEDURE pump_err_missing_txns;

  TYPE diag_txn_rec is RECORD(
    diag_seq_id         number,
    serial_number       varchar2(80),
    item_id             number,
    organization_id     number,
    mtl_txn_id          number,
    mtl_txn_date        date,
    mtl_txn_qty         number,
    mtl_creation_date   date,
    mtl_xfer_txn_id     number,
    serial_code         number,
    lot_code            number,
    revision_code       number,
    csi_txn_id          number,
    csi_txn_type_id     number,
    internal_party_id   number,
    wip_job_id          number,
    source_type         varchar2(30),
    inst_id             number,
    create_flag         varchar2(1),
    expire_flag         varchar2(1),
    error_flag          varchar2(1),
    marked_flag         varchar2(1),
    process_flag        varchar2(1),
    process_code        varchar2(10),
    temp_message        varchar2(2000));

  TYPE diag_txn_tbl is TABLE OF diag_txn_rec INDEX BY BINARY_INTEGER;

 PROCEDURE Get_Non_Srl_RMA_Report
   ( p_show_instances  IN   VARCHAR2);

  PROCEDURE MERGE_NON_SRL_INV_INSTANCE;

  PROCEDURE check_org_uniqueness;

  PROCEDURE fix_srlsoi_returned_serials;

  PROCEDURE fix_txn_error_rec;

  PROCEDURE IB_SYNC(
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_show_instances IN  VARCHAR2,
    p_mode           IN  VARCHAR2 default 'R', -- default is now 'R' shegde
    p_force_data_fix IN  VARCHAR2 default 'N');
PROCEDURE create_oper_upd_manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  );
PROCEDURE create_oper_upd_worker
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   x_batch_size     IN   NUMBER,
   x_worker_id      IN   NUMBER,
   x_num_workers    IN   NUMBER
  );
END csi_diagnostics_pkg;

 

/
