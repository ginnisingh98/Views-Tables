--------------------------------------------------------
--  DDL for Package Body QA_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULTS_PKG" as
/* $Header: qltrestb.plb 120.3.12010000.2 2010/04/26 17:16:38 ntungare ship $ */

--
-- Modified the proc signature and implementation
-- to include the database columns added for ASO support.
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--
--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

-- Modified the signature to include NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


-- Modified the signature to include CAR Hardcode Elements.
-- anagarwa Thu Nov 14 13:03:35 PST 2002
--

-- Modified the signature to include new hardcoded element followup activity, transfer license plate number
-- saugupta

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Collection_Id                  NUMBER,
                       X_Occurrence                     IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Qa_Last_Update_Date            DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Qa_Last_Updated_By             NUMBER,
                       X_Creation_Date                  DATE,
                       X_Qa_Creation_Date               DATE,
                       X_Created_By                     NUMBER,
                       X_Qa_Created_By                  NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Transaction_Number             NUMBER,
                       X_Txn_Header_Id                  NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Plan_Id                        NUMBER,
                       X_Spec_Id                        NUMBER,
                       X_Transaction_Id                 NUMBER,
                       X_Department_Id                  NUMBER,
                       X_To_Department_Id               NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Quantity                       NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Uom                            VARCHAR2,
                       X_Revision                       VARCHAR2,
                       X_Subinventory                   VARCHAR2,
                       X_Locator_Id                     NUMBER,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Comp_Item_Id                   NUMBER,
                       X_Comp_Uom                       VARCHAR2,
                       X_Comp_Revision                  VARCHAR2,
                       X_Comp_Subinventory              VARCHAR2,
                       X_Comp_Locator_Id                NUMBER,
                       X_Comp_Lot_Number                VARCHAR2,
                       X_Comp_Serial_Number             VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Line_Id                        NUMBER,
                       X_To_Op_Seq_Num                  NUMBER,
                       X_From_Op_Seq_Num                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Receipt_Num                    VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       -- bug 9652549 CLM changes
                       X_Po_Line_Num                    VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Po_Shipment_Num                NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_So_Header_Id                   NUMBER,
                       X_Rma_Header_Id                  NUMBER,
		       X_Transaction_Date		DATE,
 		       X_Status           	        VARCHAR2,
                       X_Project_Id                     Number ,
                       X_Task_Id                        Number ,
		       X_LPN_ID				Number,
		       X_XFR_LPN_ID                     NUMBER,
		       X_Contract_ID			Number,
		       X_Contract_Line_ID		Number,
		       X_Deliverable_ID			Number,
		       X_Asset_Group_ID			NUMBER,
		       X_Asset_Number			VARCHAR2,
		       X_Asset_Instance_ID  NUMBER, --dgupta: R12 EAM Integration. Bug 4345492
		       X_Asset_Activity_ID		NUMBER,
		       X_Followup_Activity_ID		NUMBER,
		       X_Work_Order_ID			NUMBER,
                       X_Character1                     VARCHAR2,
                       X_Character2                     VARCHAR2,
                       X_Character3                     VARCHAR2,
                       X_Character4                     VARCHAR2,
                       X_Character5                     VARCHAR2,
                       X_Character6                     VARCHAR2,
                       X_Character7                     VARCHAR2,
                       X_Character8                     VARCHAR2,
                       X_Character9                     VARCHAR2,
                       X_Character10                    VARCHAR2,
                       X_Character11                    VARCHAR2,
                       X_Character12                    VARCHAR2,
                       X_Character13                    VARCHAR2,
                       X_Character14                    VARCHAR2,
                       X_Character15                    VARCHAR2,
                       X_Character16                    VARCHAR2,
                       X_Character17                    VARCHAR2,
                       X_Character18                    VARCHAR2,
                       X_Character19                    VARCHAR2,
                       X_Character20                    VARCHAR2,
                       X_Character21                    VARCHAR2,
                       X_Character22                    VARCHAR2,
                       X_Character23                    VARCHAR2,
                       X_Character24                    VARCHAR2,
                       X_Character25                    VARCHAR2,
                       X_Character26                    VARCHAR2,
                       X_Character27                    VARCHAR2,
                       X_Character28                    VARCHAR2,
                       X_Character29                    VARCHAR2,
                       X_Character30                    VARCHAR2,
                       X_Character31                    VARCHAR2,
                       X_Character32                    VARCHAR2,
                       X_Character33                    VARCHAR2,
                       X_Character34                    VARCHAR2,
                       X_Character35                    VARCHAR2,
                       X_Character36                    VARCHAR2,
                       X_Character37                    VARCHAR2,
                       X_Character38                    VARCHAR2,
                       X_Character39                    VARCHAR2,
                       X_Character40                    VARCHAR2,
                       X_Character41                    VARCHAR2,
                       X_Character42                    VARCHAR2,
                       X_Character43                    VARCHAR2,
                       X_Character44                    VARCHAR2,
                       X_Character45                    VARCHAR2,
                       X_Character46                    VARCHAR2,
                       X_Character47                    VARCHAR2,
                       X_Character48                    VARCHAR2,
                       X_Character49                    VARCHAR2,
                       X_Character50                    VARCHAR2,
                       X_Character51                    VARCHAR2,
                       X_Character52                    VARCHAR2,
                       X_Character53                    VARCHAR2,
                       X_Character54                    VARCHAR2,
                       X_Character55                    VARCHAR2,
                       X_Character56                    VARCHAR2,
                       X_Character57                    VARCHAR2,
                       X_Character58                    VARCHAR2,
                       X_Character59                    VARCHAR2,
                       X_Character60                    VARCHAR2,
                       X_Character61                    VARCHAR2,
                       X_Character62                    VARCHAR2,
                       X_Character63                    VARCHAR2,
                       X_Character64                    VARCHAR2,
                       X_Character65                    VARCHAR2,
                       X_Character66                    VARCHAR2,
                       X_Character67                    VARCHAR2,
                       X_Character68                    VARCHAR2,
                       X_Character69                    VARCHAR2,
                       X_Character70                    VARCHAR2,
                       X_Character71                    VARCHAR2,
                       X_Character72                    VARCHAR2,
                       X_Character73                    VARCHAR2,
                       X_Character74                    VARCHAR2,
                       X_Character75                    VARCHAR2,
                       X_Character76                    VARCHAR2,
                       X_Character77                    VARCHAR2,
                       X_Character78                    VARCHAR2,
                       X_Character79                    VARCHAR2,
                       X_Character80                    VARCHAR2,
                       X_Character81                    VARCHAR2,
                       X_Character82                    VARCHAR2,
                       X_Character83                    VARCHAR2,
                       X_Character84                    VARCHAR2,
                       X_Character85                    VARCHAR2,
                       X_Character86                    VARCHAR2,
                       X_Character87                    VARCHAR2,
                       X_Character88                    VARCHAR2,
                       X_Character89                    VARCHAR2,
                       X_Character90                    VARCHAR2,
                       X_Character91                    VARCHAR2,
                       X_Character92                    VARCHAR2,
                       X_Character93                    VARCHAR2,
                       X_Character94                    VARCHAR2,
                       X_Character95                    VARCHAR2,
                       X_Character96                    VARCHAR2,
                       X_Character97                    VARCHAR2,
                       X_Character98                    VARCHAR2,
                       X_Character99                    VARCHAR2,
                       X_Character100                   VARCHAR2,
                       X_Sequence1                      VARCHAR2,
                       X_Sequence2                      VARCHAR2,
                       X_Sequence3                      VARCHAR2,
                       X_Sequence4                      VARCHAR2,
                       X_Sequence5                      VARCHAR2,
                       X_Sequence6                      VARCHAR2,
                       X_Sequence7                      VARCHAR2,
                       X_Sequence8                      VARCHAR2,
                       X_Sequence9                      VARCHAR2,
                       X_Sequence10                     VARCHAR2,
                       X_Sequence11                     VARCHAR2,
                       X_Sequence12                     VARCHAR2,
                       X_Sequence13                     VARCHAR2,
                       X_Sequence14                     VARCHAR2,
                       X_Sequence15                     VARCHAR2,
                       X_Comment1                       VARCHAR2,
                       X_Comment2                       VARCHAR2,
                       X_Comment3                       VARCHAR2,
                       X_Comment4                       VARCHAR2,
                       X_Comment5                       VARCHAR2,
		       X_Party_Id                       NUMBER,
                       X_Csi_Instance_Id                NUMBER,
                       X_Counter_Id                     NUMBER,
                       X_Counter_Reading_Id             NUMBER,
                       X_Ahl_Mr_Id                      NUMBER,
                       X_Cs_Incident_Id                 NUMBER,
                       X_Wip_Rework_Id                  NUMBER,
                       X_Disposition_Source             VARCHAR2,
                       X_Disposition                    VARCHAR2,
                       X_Disposition_Action             VARCHAR2,
                       X_Disposition_Status             VARCHAR2,
                       X_Mti_Transaction_Header_Id      NUMBER,
                       X_Mti_Transaction_Interface_Id   NUMBER,
                       X_Mmt_Transaction_Id             NUMBER,
                       X_Wjsi_Group_Id                  NUMBER,
                       X_Wmti_Group_Id                  NUMBER,
                       X_Wmt_Transaction_Id             NUMBER,
                       X_Rti_Interface_Transaction_Id   NUMBER,
                       X_Maintenance_Op_Seq             NUMBER,
                       X_Bill_Reference_Id              NUMBER,
                       X_Routing_Reference_Id           NUMBER,
                       X_To_Subinventory                VARCHAR2,
                       X_To_Locator_Id                  NUMBER,
                       X_Concurrent_Request_Id          NUMBER,
                       X_Lot_Status_Id                  NUMBER,
                       X_Serial_Status_Id               NUMBER,
                       X_Nonconformance_Source          VARCHAR2,
                       X_Nonconform_Severity            VARCHAR2,
                       X_Nonconform_Priority            VARCHAR2,
                       X_Nonconformance_Type            VARCHAR2,
                       X_Nonconformance_Code            VARCHAR2,
                       X_Nonconformance_Status          VARCHAR2,
                       X_Date_Opened                    DATE,
                       X_Date_Closed                    DATE,
                       X_Days_To_Close                  NUMBER,
                       X_Rcv_Transaction_Id             NUMBER,
                       X_Request_Source                 VARCHAR2,
                       X_Request_Priority               VARCHAR2,
                       X_Request_Severity               VARCHAR2,
                       X_Request_Status                 VARCHAR2,
                       X_Eco_Name                       VARCHAR2,
                       /* R12 DR Integration. Bug 4345489 Start */
                       X_REPAIR_LINE_ID                 NUMBER,
                       X_JTF_TASK_ID                    NUMBER,
                       /* R12 DR Integration. Bug 4345489 End*/

                       -- R12 OPM Deviations. Bug 4345503 Start
                     X_PROCESS_BATCH_ID               NUMBER,
	               X_PROCESS_BATCHSTEP_ID           NUMBER,
	               X_PROCESS_OPERATION_ID           NUMBER,
	               X_PROCESS_ACTIVITY_ID            NUMBER,
	               X_PROCESS_RESOURCE_ID            NUMBER,
	               X_PROCESS_PARAMETER_ID           NUMBER
                       -- R12 OPM Deviations. Bug 4345503 End


  ) IS
    CURSOR C IS SELECT rowid FROM QA_RESULTS
                 WHERE plan_id = x_plan_id
                 AND   collection_id = X_Collection_Id
		 and occurrence = X_Occurrence;
      CURSOR C2 IS SELECT qa_occurrence_s.nextval FROM dual;
   BEGIN
      if (X_Occurrence is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Occurrence;
        CLOSE C2;
      end if;

-- Modified the signature to include new hardcoded element followup activity, transfer license plate number
-- saugupta

       INSERT INTO QA_RESULTS(
              collection_id,
              occurrence,
              last_update_date,
              qa_last_update_date,
              last_updated_by,
              qa_last_updated_by,
              creation_date,
              qa_creation_date,
              created_by,
              qa_created_by,
              last_update_login,
              transaction_number,
              txn_header_id,
              organization_id,
              plan_id,
              spec_id,
              transaction_id,
              department_id,
	      to_department_id,
              resource_id,
              quantity,
              item_id,
              uom,
              revision,
              subinventory,
              locator_id,
              lot_number,
              serial_number,
              comp_item_id,
              comp_uom,
              comp_revision,
              comp_subinventory,
              comp_locator_id,
              comp_lot_number,
              comp_serial_number,
              wip_entity_id,
              line_id,
              to_op_seq_num,
              from_op_seq_num,
              vendor_id,
              receipt_num,
              po_header_id,
              po_line_num,
              po_release_id,
              po_shipment_num,
              customer_id,
              so_header_id,
              rma_header_id,
	      transaction_date,
              status ,
              Project_Id,
              Task_Id,
	      LPN_ID,
	      XFR_LPN_ID,
	      Contract_ID,
	      Contract_Line_ID,
	      Deliverable_ID,
	      Asset_Group_ID,
	      Asset_Number,
	      Asset_Instance_ID, --dgupta: R12 EAM Integration. Bug 4345492
	      Asset_Activity_ID,
	      Followup_Activity_ID,
	      Work_order_ID,
              character1,
              character2,
              character3,
              character4,
              character5,
              character6,
              character7,
              character8,
              character9,
              character10,
              character11,
              character12,
              character13,
              character14,
              character15,
              character16,
              character17,
              character18,
              character19,
              character20,
              character21,
              character22,
              character23,
              character24,
              character25,
              character26,
              character27,
              character28,
              character29,
              character30,
              character31,
              character32,
              character33,
              character34,
              character35,
              character36,
              character37,
              character38,
              character39,
              character40,
	      character41,
              character42,
	      character43,
	      character44,
	      character45,
	      character46,
	      character47,
	      character48,
	      character49,
	      character50,
              character51,
              character52,
              character53,
              character54,
              character55,
              character56,
              character57,
              character58,
              character59,
              character60,
              character61,
              character62,
              character63,
              character64,
              character65,
              character66,
              character67,
              character68,
              character69,
              character70,
              character71,
              character72,
              character73,
              character74,
              character75,
              character76,
              character77,
              character78,
              character79,
              character80,
              character81,
              character82,
              character83,
              character84,
              character85,
              character86,
              character87,
              character88,
              character89,
              character90,
	      character91,
              character92,
	      character93,
	      character94,
	      character95,
	      character96,
	      character97,
	      character98,
	      character99,
	      character100,
	      sequence1,
              sequence2,
              sequence3,
              sequence4,
              sequence5,
              sequence6,
              sequence7,
              sequence8,
              sequence9,
              sequence10,
              sequence11,
              sequence12,
              sequence13,
              sequence14,
              sequence15,
              comment1,
              comment2,
              comment3,
              comment4,
              comment5,
	      party_id,
	      csi_instance_id,
	      counter_id,
              counter_reading_id,
	      ahl_mr_id,
	      cs_incident_id,
	      wip_rework_id,
	      disposition_source,
	      disposition,
	      disposition_action,
	      disposition_status,
	      mti_transaction_header_id,
	      mti_transaction_interface_id,
	      mmt_transaction_id,
	      wjsi_group_id,
	      wmti_group_id,
	      wmt_transaction_id,
	      rti_interface_transaction_id,
	      maintenance_op_seq,
              bill_reference_id,
              routing_reference_id,
              to_subinventory,
              to_locator_id,
              concurrent_request_id,
              lot_status_id,
              serial_status_id,
              nonconformance_source,
              nonconform_severity,
              nonconform_priority,
              nonconformance_type,
              nonconformance_code,
              nonconformance_status,
              date_opened,
              date_closed,
              days_to_close,
              rcv_transaction_id,
              request_source,
              request_priority,
              request_severity,
              request_status,
              eco_name,
	      /* R12 DR Integration. Bug 4345489 Start */
              repair_line_id,
              jtf_task_id,
	      /* R12 DR Integration. Bug 4345489 End */
           -- R12 OPM Deviations. Bug 4345503 Start
              PROCESS_BATCH_ID,
	      PROCESS_BATCHSTEP_ID,
	      PROCESS_OPERATION_ID,
	      PROCESS_ACTIVITY_ID,
	      PROCESS_RESOURCE_ID,
	      PROCESS_PARAMETER_ID
           -- R12 OPM Deviations. Bug 4345503 End
             ) VALUES (
              X_Collection_Id,
              X_Occurrence,
              X_Last_Update_Date,
              X_Qa_Last_Update_Date,
              X_Last_Updated_By,
              X_Qa_Last_Updated_By,
              X_Creation_Date,
              X_Qa_Creation_Date,
              X_Created_By,
              X_Qa_Created_By,
              X_Last_Update_Login,
              X_Transaction_Number,
              X_Txn_Header_Id,
              X_Organization_Id,
              X_Plan_Id,
              X_Spec_Id,
              X_Transaction_Id,
              X_Department_Id,
              X_To_Department_Id,
              X_Resource_Id,
              X_Quantity,
              X_Item_Id,
              X_Uom,
              X_Revision,
              X_Subinventory,
              X_Locator_Id,
              X_Lot_Number,
              X_Serial_Number,
              X_Comp_Item_Id,
              X_Comp_Uom,
              X_Comp_Revision,
              X_Comp_Subinventory,
              X_Comp_Locator_Id,
              X_Comp_Lot_Number,
              X_Comp_Serial_Number,
              X_Wip_Entity_Id,
              X_Line_Id,
              X_To_Op_Seq_Num,
              X_From_Op_Seq_Num,
              X_Vendor_Id,
              X_Receipt_Num,
              X_Po_Header_Id,
              X_Po_Line_Num,
              X_Po_Release_Id,
              X_Po_Shipment_Num,
              X_Customer_Id,
              X_So_Header_Id,
              X_Rma_Header_Id,
	      X_Transaction_Date,
              X_Status ,
              X_Project_Id,
              X_Task_Id ,
              X_LPN_ID,
	      X_XFR_LPN_ID,
	      X_Contract_ID,
	      X_Contract_Line_ID,
	      X_Deliverable_ID,
	      X_Asset_Group_ID,
	      X_Asset_Number,
	      X_Asset_Instance_ID, --dgupta: R12 EAM Integration. Bug 4345492
	      X_Asset_Activity_ID,
	      X_Followup_Activity_ID,
	      X_Work_Order_ID,
              X_Character1,
              X_Character2,
              X_Character3,
              X_Character4,
              X_Character5,
              X_Character6,
              X_Character7,
              X_Character8,
              X_Character9,
              X_Character10,
              X_Character11,
              X_Character12,
              X_Character13,
              X_Character14,
              X_Character15,
              X_Character16,
              X_Character17,
              X_Character18,
              X_Character19,
              X_Character20,
              X_Character21,
              X_Character22,
              X_Character23,
              X_Character24,
              X_Character25,
              X_Character26,
              X_Character27,
              X_Character28,
              X_Character29,
              X_Character30,
              X_Character31,
              X_Character32,
              X_Character33,
              X_Character34,
              X_Character35,
              X_Character36,
              X_Character37,
              X_Character38,
              X_Character39,
              X_Character40,
              X_Character41,
              X_Character42,
              X_Character43,
              X_Character44,
              X_Character45,
              X_Character46,
              X_Character47,
              X_Character48,
              X_Character49,
              X_Character50,
              X_Character51,
              X_Character52,
              X_Character53,
              X_Character54,
              X_Character55,
              X_Character56,
              X_Character57,
              X_Character58,
              X_Character59,
              X_Character60,
              X_Character61,
              X_Character62,
              X_Character63,
              X_Character64,
              X_Character65,
              X_Character66,
              X_Character67,
              X_Character68,
              X_Character69,
              X_Character70,
              X_Character71,
              X_Character72,
              X_Character73,
              X_Character74,
              X_Character75,
              X_Character76,
              X_Character77,
              X_Character78,
              X_Character79,
              X_Character80,
              X_Character81,
              X_Character82,
              X_Character83,
              X_Character84,
              X_Character85,
              X_Character86,
              X_Character87,
              X_Character88,
              X_Character89,
              X_Character90,
              X_Character91,
              X_Character92,
              X_Character93,
              X_Character94,
              X_Character95,
              X_Character96,
              X_Character97,
              X_Character98,
              X_Character99,
              X_Character100,
	      X_Sequence1,
	      X_Sequence2,
              X_Sequence3,
              X_Sequence4,
              X_Sequence5,
              X_Sequence6,
              X_Sequence7,
              X_Sequence8,
              X_Sequence9,
              X_Sequence10,
              X_Sequence11,
              X_Sequence12,
              X_Sequence13,
              X_Sequence14,
              X_Sequence15,
              X_Comment1,
              X_Comment2,
              X_Comment3,
              X_Comment4,
              X_Comment5,
	      X_Party_Id,
	      X_Csi_Instance_Id,
	      X_Counter_Id,
              X_Counter_Reading_Id,
	      X_Ahl_Mr_Id,
	      X_Cs_Incident_Id,
	      X_Wip_Rework_Id,
	      X_Disposition_Source,
	      X_Disposition,
	      X_Disposition_Action,
	      X_Disposition_Status,
	      X_Mti_Transaction_Header_Id,
	      X_Mti_Transaction_Interface_Id,
	      X_Mmt_Transaction_Id,
	      X_Wjsi_Group_Id,
	      X_Wmti_Group_Id,
	      X_Wmt_Transaction_Id,
	      X_Rti_Interface_Transaction_Id,
	      X_Maintenance_Op_Seq,
              X_Bill_Reference_Id,
              X_Routing_Reference_Id,
              X_To_Subinventory,
              X_To_Locator_Id,
              X_Concurrent_Request_Id,
              X_Lot_Status_Id,
              X_Serial_Status_Id,
              X_Nonconformance_Source,
              X_Nonconform_Severity,
              X_Nonconform_Priority,
              X_Nonconformance_Type,
              X_Nonconformance_Code,
              X_Nonconformance_Status,
              X_Date_Opened,
              X_Date_Closed,
              X_Days_To_Close,
              X_Rcv_Transaction_Id,
              X_Request_Source,
              X_Request_Priority,
              X_Request_Severity,
              X_Request_Status,
              X_Eco_Name,
              /* R12 DR Integration. Bug 4345489 Start */
              X_REPAIR_LINE_ID,
              X_JTF_TASK_ID,
              /* R12 DR Integration. Bug 4345489 End */
           -- R12 OPM Deviations. Bug 4345503 Start
              X_PROCESS_BATCH_ID,
	      X_PROCESS_BATCHSTEP_ID,
	      X_PROCESS_OPERATION_ID,
	      X_PROCESS_ACTIVITY_ID,
	      X_PROCESS_RESOURCE_ID,
	      X_PROCESS_PARAMETER_ID
           -- R12 OPM Deviations. Bug 4345503 End
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

--
-- Modified the proc signature and implementation
-- to include the database columns added for ASO support.
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--
--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

-- Modified the signature to include NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

-- Modified the signature to include CAR Hardcode Elements.
-- anagarwa Thu Nov 14 13:03:35 PST 2002

-- modified the signature for new hardcoded elements followup_activity, transfer license plate number
-- saugupta

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Collection_Id                    NUMBER,
                     X_Occurrence                       NUMBER,
                     X_Qa_Last_Update_Date              DATE,
                     X_Qa_Last_Updated_By               NUMBER,
                     X_Qa_Creation_Date                 DATE,
                     X_Qa_Created_By                    NUMBER,
                     X_Transaction_Number               NUMBER,
                     X_Txn_Header_Id                    NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Plan_Id                          NUMBER,
                     X_Spec_Id                          NUMBER,
                     X_Transaction_Id                   NUMBER,
                     X_Department_Id                    NUMBER,
                     X_To_Department_Id                    NUMBER,
                     X_Resource_Id                      NUMBER,
                     X_Quantity                         NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Uom                              VARCHAR2,
                     X_Revision                         VARCHAR2,
                     X_Subinventory                     VARCHAR2,
                     X_Locator_Id                       NUMBER,
                     X_Lot_Number                       VARCHAR2,
                     X_Serial_Number                    VARCHAR2,
                     X_Comp_Item_Id                     NUMBER,
                     X_Comp_Uom                         VARCHAR2,
                     X_Comp_Revision                    VARCHAR2,
                     X_Comp_Subinventory                VARCHAR2,
                     X_Comp_Locator_Id                  NUMBER,
                     X_Comp_Lot_Number                  VARCHAR2,
                     X_Comp_Serial_Number               VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Line_Id                          NUMBER,
                     X_To_Op_Seq_Num                    NUMBER,
                     X_From_Op_Seq_Num                  NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Receipt_Num                      VARCHAR2,
                     X_Po_Header_Id                     NUMBER,
                     -- bug 9652549 CLM changes
                     X_Po_Line_Num                      VARCHAR2,
                     X_Po_Release_Id                    NUMBER,
                     X_Po_Shipment_Num                  NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_So_Header_Id                     NUMBER,
                     X_Rma_Header_Id                    NUMBER,
		     X_Transaction_Date			DATE,
                     X_Status                           VARCHAR2,
                     X_Project_Id                       NUMBER ,
                     X_Task_Id                          NUMBER ,
		     X_LPN_ID				NUMBER,
		     X_XFR_LPN_ID                       NUMBER,
		     X_Contract_ID			Number,
		     X_Contract_Line_ID			Number,
		     X_Deliverable_ID			Number,
		     X_Asset_Group_ID			NUMBER,
		     X_Asset_Number			VARCHAR2,
		     X_Asset_Instance_ID            NUMBER, --dgupta: R12 EAM Integration. Bug 4345492
		     X_Asset_Activity_ID		NUMBER,
		     X_Followup_Activity_ID		NUMBER,
		     X_Work_Order_ID			NUMBER,
                     X_Character1                       VARCHAR2,
                     X_Character2                       VARCHAR2,
                     X_Character3                       VARCHAR2,
                     X_Character4                       VARCHAR2,
                     X_Character5                       VARCHAR2,
                     X_Character6                       VARCHAR2,
                     X_Character7                       VARCHAR2,
                     X_Character8                       VARCHAR2,
                     X_Character9                       VARCHAR2,
                     X_Character10                      VARCHAR2,
                     X_Character11                      VARCHAR2,
                     X_Character12                      VARCHAR2,
                     X_Character13                      VARCHAR2,
                     X_Character14                      VARCHAR2,
                     X_Character15                      VARCHAR2,
                     X_Character16                      VARCHAR2,
                     X_Character17                      VARCHAR2,
                     X_Character18                      VARCHAR2,
                     X_Character19                      VARCHAR2,
                     X_Character20                      VARCHAR2,
                     X_Character21                      VARCHAR2,
                     X_Character22                      VARCHAR2,
                     X_Character23                      VARCHAR2,
                     X_Character24                      VARCHAR2,
                     X_Character25                      VARCHAR2,
                     X_Character26                      VARCHAR2,
                     X_Character27                      VARCHAR2,
                     X_Character28                      VARCHAR2,
                     X_Character29                      VARCHAR2,
                     X_Character30                      VARCHAR2,
                     X_Character31                      VARCHAR2,
                     X_Character32                      VARCHAR2,
                     X_Character33                      VARCHAR2,
                     X_Character34                      VARCHAR2,
                     X_Character35                      VARCHAR2,
                     X_Character36                      VARCHAR2,
                     X_Character37                      VARCHAR2,
                     X_Character38                      VARCHAR2,
                     X_Character39                      VARCHAR2,
                     X_Character40                      VARCHAR2,
                     X_Character41                      VARCHAR2,
                     X_Character42                      VARCHAR2,
                     X_Character43                      VARCHAR2,
                     X_Character44                      VARCHAR2,
                     X_Character45                      VARCHAR2,
                     X_Character46                      VARCHAR2,
                     X_Character47                      VARCHAR2,
                     X_Character48                      VARCHAR2,
                     X_Character49                      VARCHAR2,
                     X_Character50                      VARCHAR2,
                     X_Character51                      VARCHAR2,
                     X_Character52                      VARCHAR2,
                     X_Character53                      VARCHAR2,
                     X_Character54                      VARCHAR2,
                     X_Character55                      VARCHAR2,
                     X_Character56                      VARCHAR2,
                     X_Character57                      VARCHAR2,
                     X_Character58                      VARCHAR2,
                     X_Character59                      VARCHAR2,
                     X_Character60                      VARCHAR2,
                     X_Character61                      VARCHAR2,
                     X_Character62                      VARCHAR2,
                     X_Character63                      VARCHAR2,
                     X_Character64                      VARCHAR2,
                     X_Character65                      VARCHAR2,
                     X_Character66                      VARCHAR2,
                     X_Character67                      VARCHAR2,
                     X_Character68                      VARCHAR2,
                     X_Character69                      VARCHAR2,
                     X_Character70                      VARCHAR2,
                     X_Character71                      VARCHAR2,
                     X_Character72                      VARCHAR2,
                     X_Character73                      VARCHAR2,
                     X_Character74                      VARCHAR2,
                     X_Character75                      VARCHAR2,
                     X_Character76                      VARCHAR2,
                     X_Character77                      VARCHAR2,
                     X_Character78                      VARCHAR2,
                     X_Character79                      VARCHAR2,
                     X_Character80                      VARCHAR2,
                     X_Character81                      VARCHAR2,
                     X_Character82                      VARCHAR2,
                     X_Character83                      VARCHAR2,
                     X_Character84                      VARCHAR2,
                     X_Character85                      VARCHAR2,
                     X_Character86                      VARCHAR2,
                     X_Character87                      VARCHAR2,
                     X_Character88                      VARCHAR2,
                     X_Character89                      VARCHAR2,
                     X_Character90                      VARCHAR2,
                     X_Character91                      VARCHAR2,
                     X_Character92                      VARCHAR2,
                     X_Character93                      VARCHAR2,
                     X_Character94                      VARCHAR2,
                     X_Character95                      VARCHAR2,
                     X_Character96                      VARCHAR2,
                     X_Character97                      VARCHAR2,
                     X_Character98                      VARCHAR2,
                     X_Character99                      VARCHAR2,
                     X_Character100                     VARCHAR2,
                     X_Sequence1                        VARCHAR2,
                     X_Sequence2                        VARCHAR2,
                     X_Sequence3                        VARCHAR2,
                     X_Sequence4                        VARCHAR2,
                     X_Sequence5                        VARCHAR2,
                     X_Sequence6                        VARCHAR2,
                     X_Sequence7                        VARCHAR2,
                     X_Sequence8                        VARCHAR2,
                     X_Sequence9                        VARCHAR2,
                     X_Sequence10                       VARCHAR2,
                     X_Sequence11                       VARCHAR2,
                     X_Sequence12                       VARCHAR2,
                     X_Sequence13                       VARCHAR2,
                     X_Sequence14                       VARCHAR2,
                     X_Sequence15                       VARCHAR2,
                     X_Comment1                         VARCHAR2,
                     X_Comment2                         VARCHAR2,
                     X_Comment3                         VARCHAR2,
                     X_Comment4                         VARCHAR2,
                     X_Comment5                         VARCHAR2,
                     X_Party_Id                         NUMBER,
                     X_Csi_Instance_Id                  NUMBER,
                     X_Counter_Id                       NUMBER,
                     X_Counter_Reading_Id               NUMBER,
                     X_Ahl_Mr_Id                        NUMBER,
                     X_Cs_Incident_Id                   NUMBER,
                     X_Wip_Rework_Id                    NUMBER,
                     X_Disposition_Source               VARCHAR2,
                     X_Disposition                      VARCHAR2,
                     X_Disposition_Action               VARCHAR2,
                     X_Disposition_Status               VARCHAR2,
                     X_Mti_Transaction_Header_Id        NUMBER,
                     X_Mti_Transaction_Interface_Id     NUMBER,
                     X_Mmt_Transaction_Id               NUMBER,
                     X_Wjsi_Group_Id                    NUMBER,
                     X_Wmti_Group_Id                    NUMBER,
                     X_Wmt_Transaction_Id               NUMBER,
                     X_Rti_Interface_Transaction_Id     NUMBER,
		     X_Maintenance_Op_Seq               NUMBER,
                     X_Bill_Reference_Id                NUMBER,
                     X_Routing_Reference_Id             NUMBER,
                     X_To_Subinventory                  VARCHAR2,
                     X_To_Locator_Id                    NUMBER,
                     X_Concurrent_Request_Id            NUMBER,
                     X_Lot_Status_Id                    NUMBER,
                     X_Serial_Status_Id                 NUMBER,
                       X_Nonconformance_Source          VARCHAR2,
                       X_Nonconform_Severity            VARCHAR2,
                       X_Nonconform_Priority            VARCHAR2,
                       X_Nonconformance_Type            VARCHAR2,
                       X_Nonconformance_Code            VARCHAR2,
                       X_Nonconformance_Status          VARCHAR2,
                       X_Date_Opened                    DATE,
                       X_Date_Closed                    DATE,
                       X_Days_To_Close                  NUMBER,
                       X_Rcv_Transaction_Id             NUMBER,
                       X_Request_Source                 VARCHAR2,
                       X_Request_Priority               VARCHAR2,
                       X_Request_Severity               VARCHAR2,
                       X_Request_Status                 VARCHAR2,
                       X_Eco_Name                       VARCHAR2,
                       /* R12 DR Integration. Bug 4345489 Start */
                       X_REPAIR_LINE_ID                 NUMBER,
                       X_JTF_TASK_ID                    NUMBER,
                       /* R12 DR Integration. Bug 4345489 End */
                       -- R12 OPM Deviations. Bug 4345503 Start
                       X_PROCESS_BATCH_ID               NUMBER,
	               X_PROCESS_BATCHSTEP_ID           NUMBER,
	               X_PROCESS_OPERATION_ID           NUMBER,
	               X_PROCESS_ACTIVITY_ID            NUMBER,
	               X_PROCESS_RESOURCE_ID            NUMBER,
	               X_PROCESS_PARAMETER_ID           NUMBER
                       -- R12 OPM Deviations. Bug 4345503 End
  ) IS
    CURSOR C IS
        SELECT *
        FROM   QA_RESULTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Occurrence NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.collection_id =  X_Collection_Id)
           AND (Recinfo.occurrence =  X_Occurrence)
           AND (Recinfo.qa_last_update_date =  X_Qa_Last_Update_Date)
           AND (Recinfo.qa_last_updated_by =  X_Qa_Last_Updated_By)
           AND (Recinfo.qa_creation_date =  X_Qa_Creation_Date)
           AND (Recinfo.qa_created_by =  X_Qa_Created_By)
           AND (   (Recinfo.transaction_number =  X_Transaction_Number)
                OR (    (Recinfo.transaction_number IS NULL)
                    AND (X_Transaction_Number IS NULL)))
           AND (   (Recinfo.txn_header_id =  X_Txn_Header_Id)
                OR (    (Recinfo.txn_header_id IS NULL)
                    AND (X_Txn_Header_Id IS NULL)))
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.plan_id =  X_Plan_Id)
           AND (   (Recinfo.spec_id =  X_Spec_Id)
                OR (    (Recinfo.spec_id IS NULL)
                    AND (X_Spec_Id IS NULL)))
           AND (   (Recinfo.transaction_id =  X_Transaction_Id)
                OR (    (Recinfo.transaction_id IS NULL)
                    AND (X_Transaction_Id IS NULL)))
           AND (   (Recinfo.department_id =  X_Department_Id)
                OR (    (Recinfo.department_id IS NULL)
                    AND (X_Department_Id IS NULL)))
           AND (   (Recinfo.to_department_id =  X_To_Department_Id)
                OR (    (Recinfo.to_department_id IS NULL)
                    AND (X_To_Department_Id IS NULL)))
           AND (   (Recinfo.resource_id =  X_Resource_Id)
                OR (    (Recinfo.resource_id IS NULL)
                    AND (X_Resource_Id IS NULL)))
           AND (   (Recinfo.quantity =  X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL)))
           AND (   (Recinfo.item_id =  X_Item_Id)
                OR (    (Recinfo.item_id IS NULL)
                    AND (X_Item_Id IS NULL)))
           AND (   (Recinfo.uom =  X_Uom)
                OR (    (Recinfo.uom IS NULL)
                    AND (X_Uom IS NULL)))
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (   (Recinfo.subinventory =  X_Subinventory)
                OR (    (Recinfo.subinventory IS NULL)
                    AND (X_Subinventory IS NULL)))
           AND (   (Recinfo.locator_id =  X_Locator_Id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_Locator_Id IS NULL)))
           AND (   (Recinfo.lot_number =  X_Lot_Number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.comp_item_id =  X_Comp_Item_Id)
                OR (    (Recinfo.comp_item_id IS NULL)
                    AND (X_Comp_Item_Id IS NULL)))
           AND (   (Recinfo.comp_uom =  X_Comp_Uom)
                OR (    (Recinfo.comp_uom IS NULL)
                    AND (X_Comp_Uom IS NULL)))
           AND (   (Recinfo.comp_revision =  X_Comp_Revision)
                OR (    (Recinfo.comp_revision IS NULL)
                    AND (X_Comp_Revision IS NULL)))
           AND (   (Recinfo.comp_subinventory =  X_Comp_Subinventory)
                OR (    (Recinfo.comp_subinventory IS NULL)
                    AND (X_Comp_Subinventory IS NULL)))
           AND (   (Recinfo.comp_locator_id =  X_Comp_Locator_Id)
                OR (    (Recinfo.comp_locator_id IS NULL)
                    AND (X_Comp_Locator_Id IS NULL)))
           AND (   (Recinfo.comp_lot_number =  X_Comp_Lot_Number)
                OR (    (Recinfo.comp_lot_number IS NULL)
                    AND (X_Comp_Lot_Number IS NULL)))
           AND (   (Recinfo.comp_serial_number =  X_Comp_Serial_Number)
                OR (    (Recinfo.comp_serial_number IS NULL)
                    AND (X_Comp_Serial_Number IS NULL)))
           AND (   (Recinfo.wip_entity_id =  X_Wip_Entity_Id)
                OR (    (Recinfo.wip_entity_id IS NULL)
                    AND (X_Wip_Entity_Id IS NULL)))
           AND (   (Recinfo.line_id =  X_Line_Id)
                OR (    (Recinfo.line_id IS NULL)
                    AND (X_Line_Id IS NULL)))
           AND (   (Recinfo.to_op_seq_num =  X_To_Op_Seq_Num)
                OR (    (Recinfo.to_op_seq_num IS NULL)
                    AND (X_To_Op_Seq_Num IS NULL)))
           AND (   (Recinfo.from_op_seq_num =  X_From_Op_Seq_Num)
                OR (    (Recinfo.from_op_seq_num IS NULL)
                    AND (X_From_Op_Seq_Num IS NULL)))
           AND (   (Recinfo.vendor_id =  X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.receipt_num =  X_Receipt_Num)
                OR (    (Recinfo.receipt_num IS NULL)
                    AND (X_Receipt_Num IS NULL)))
           AND (   (Recinfo.po_header_id =  X_Po_Header_Id)
                OR (    (Recinfo.po_header_id IS NULL)
                    AND (X_Po_Header_Id IS NULL)))
           AND (   (Recinfo.po_line_num =  X_Po_Line_Num)
                OR (    (Recinfo.po_line_num IS NULL)
                    AND (X_Po_Line_Num IS NULL)))
           AND (   (Recinfo.po_release_id =  X_Po_Release_Id)
                OR (    (Recinfo.po_release_id IS NULL)
                    AND (X_Po_Release_Id IS NULL)))
           AND (   (Recinfo.po_shipment_num =  X_Po_Shipment_Num)
                OR (    (Recinfo.po_shipment_num IS NULL)
                    AND (X_Po_Shipment_Num IS NULL)))
           AND (   (Recinfo.customer_id =  X_Customer_Id)
                OR (    (Recinfo.customer_id IS NULL)
                    AND (X_Customer_Id IS NULL)))
           AND (   (Recinfo.so_header_id =  X_So_Header_Id)
                OR (    (Recinfo.so_header_id IS NULL)
                    AND (X_So_Header_Id IS NULL)))
           AND (   (Recinfo.rma_header_id =  X_Rma_Header_Id)
                OR (    (Recinfo.rma_header_id IS NULL)
                    AND (X_Rma_Header_Id IS NULL)))
           AND (   (Recinfo.transaction_date =  X_Transaction_Date)
                OR (    (Recinfo.transaction_date IS NULL)
                    AND (X_Transaction_Date IS NULL)))
           AND (   (Recinfo.status = X_Status )
                OR (    (Recinfo.status IS NULL)
                    AND ( X_Status IS NULL)))
           AND (   (Recinfo.Project_Id = X_Project_Id )
                OR (    (Recinfo.Project_Id IS NULL)
                    AND ( X_Project_Id IS NULL)))
           AND (   (Recinfo.Task_Id = X_Task_Id )
                OR (    (Recinfo.Task_Id IS NULL)
                    AND ( X_Task_Id IS NULL)))
           AND (   (Recinfo.LPN_ID = X_LPN_ID )
                OR (    (Recinfo.LPN_ID IS NULL)
                    AND ( X_LPN_ID IS NULL)))
           AND (   (Recinfo.XFR_LPN_ID = X_XFR_LPN_ID )
                OR (    (Recinfo.XFR_LPN_ID IS NULL)
                    AND ( X_XFR_LPN_ID IS NULL)))
           AND (   (Recinfo.Contract_ID = X_Contract_ID )
                OR (    (Recinfo.Contract_ID IS NULL)
                    AND ( X_Contract_ID IS NULL)))
           AND (   (Recinfo.Contract_Line_ID = X_Contract_Line_ID )
                OR (    (Recinfo.Contract_Line_ID IS NULL)
                    AND ( X_Contract_Line_ID IS NULL)))
           AND (   (Recinfo.Deliverable_ID = X_Deliverable_ID )
                OR (    (Recinfo.Deliverable_ID IS NULL)
                    AND ( X_Deliverable_ID IS NULL)))
           AND (   (Recinfo.Asset_Group_ID = X_Asset_Group_ID )
                OR (    (Recinfo.Asset_Group_ID IS NULL)
                    AND ( X_Asset_Group_ID IS NULL)))
           AND (   (Recinfo.Asset_Number = X_Asset_Number )
                OR (    (Recinfo.Asset_Number IS NULL)
                    AND ( X_Asset_Number IS NULL)))
           --dgupta: Start R12 EAM Integration. Bug 4345492
           AND (   (Recinfo.Asset_Instance_ID = X_Asset_Instance_ID )
                OR (    (Recinfo.Asset_Instance_ID IS NULL)
                    AND ( X_Asset_Instance_ID IS NULL)))
           --dgupta: End R12 EAM Integration. Bug 4345492
           AND (   (Recinfo.Asset_Activity_ID = X_Asset_Activity_ID )
                OR (    (Recinfo.Asset_Activity_ID IS NULL)
                    AND ( X_Asset_Activity_ID IS NULL)))
           AND (   (Recinfo.Followup_Activity_ID = X_Followup_Activity_ID )
                OR (    (Recinfo.Followup_Activity_ID IS NULL)
                    AND ( X_Followup_Activity_ID IS NULL)))
           AND (   (Recinfo.Work_Order_ID = X_Work_Order_ID )
                OR (    (Recinfo.Work_Order_ID IS NULL)
                    AND ( X_Work_Order_ID IS NULL)))

           /* R12 DR Integration. Bug 4345489 Start */
           AND (   (Recinfo.Repair_line_ID = X_REPAIR_LINE_ID )
                OR (    (Recinfo.Repair_line_ID IS NULL)
                    AND ( X_Repair_Line_ID IS NULL)))
	     AND (   (Recinfo.Jtf_task_ID = X_JTF_TASK_ID )
                OR (    (Recinfo.Jtf_Task_ID IS NULL)
                    AND ( X_Jtf_Task_ID IS NULL)))
           /* R12 DR Integration. Bug 4345489 End */

           -- R12 OPM Deviations. Bug 4345503 Start
           AND (   (Recinfo.PROCESS_BATCH_ID =  X_PROCESS_BATCH_ID)
                OR (    (Recinfo.PROCESS_BATCH_ID IS NULL)
                    AND (X_PROCESS_BATCH_ID IS NULL)))
	   AND (   (Recinfo.PROCESS_BATCHSTEP_ID =  X_PROCESS_BATCHSTEP_ID)
	        OR (    (Recinfo.PROCESS_BATCHSTEP_ID IS NULL)
	            AND (X_PROCESS_BATCHSTEP_ID IS NULL)))
	   AND (   (Recinfo.PROCESS_OPERATION_ID =  X_PROCESS_OPERATION_ID)
	        OR (    (Recinfo.PROCESS_OPERATION_ID IS NULL)
	            AND (X_PROCESS_OPERATION_ID IS NULL)))
           AND (   (Recinfo.PROCESS_ACTIVITY_ID =  X_PROCESS_ACTIVITY_ID)
	        OR (    (Recinfo.PROCESS_ACTIVITY_ID IS NULL)
	            AND (X_PROCESS_ACTIVITY_ID IS NULL)))
	   AND (   (Recinfo.PROCESS_RESOURCE_ID =  X_PROCESS_RESOURCE_ID)
	        OR (    (Recinfo.PROCESS_RESOURCE_ID IS NULL)
	            AND (X_PROCESS_RESOURCE_ID IS NULL)))
	   AND (   (Recinfo.PROCESS_PARAMETER_ID =  X_PROCESS_PARAMETER_ID)
	        OR (    (Recinfo.PROCESS_PARAMETER_ID IS NULL)
	            AND (X_PROCESS_PARAMETER_ID IS NULL)))
           -- R12 OPM Deviations. Bug 4345503 Start
           ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (       (   (Recinfo.character2 =  X_Character2)
                OR (    (Recinfo.character2 IS NULL)
                    AND (X_Character2 IS NULL)))
           AND (   (Recinfo.character3 =  X_Character3)
                OR (    (Recinfo.character3 IS NULL)
                    AND (X_Character3 IS NULL)))
           AND (   (Recinfo.character4 =  X_Character4)
                OR (    (Recinfo.character4 IS NULL)
                    AND (X_Character4 IS NULL)))
           AND (   (Recinfo.character5 =  X_Character5)
                OR (    (Recinfo.character5 IS NULL)
                    AND (X_Character5 IS NULL)))
           AND (   (Recinfo.character6 =  X_Character6)
                OR (    (Recinfo.character6 IS NULL)
                    AND (X_Character6 IS NULL)))
           AND (   (Recinfo.character7 =  X_Character7)
                OR (    (Recinfo.character7 IS NULL)
                    AND (X_Character7 IS NULL)))
           AND (   (Recinfo.character8 =  X_Character8)
                OR (    (Recinfo.character8 IS NULL)
                    AND (X_Character8 IS NULL)))
           AND (   (Recinfo.character9 =  X_Character9)
                OR (    (Recinfo.character9 IS NULL)
                    AND (X_Character9 IS NULL)))
           AND (   (Recinfo.character10 =  X_Character10)
                OR (    (Recinfo.character10 IS NULL)
                    AND (X_Character10 IS NULL)))
           AND (   (Recinfo.character11 =  X_Character11)
                OR (    (Recinfo.character11 IS NULL)
                    AND (X_Character11 IS NULL)))
           AND (   (Recinfo.character12 =  X_Character12)
                OR (    (Recinfo.character12 IS NULL)
                    AND (X_Character12 IS NULL)))
           AND (   (Recinfo.character13 =  X_Character13)
                OR (    (Recinfo.character13 IS NULL)
                    AND (X_Character13 IS NULL)))
           AND (   (Recinfo.character14 =  X_Character14)
                OR (    (Recinfo.character14 IS NULL)
                    AND (X_Character14 IS NULL)))
           AND (   (Recinfo.character15 =  X_Character15)
                OR (    (Recinfo.character15 IS NULL)
                    AND (X_Character15 IS NULL)))
           AND (   (Recinfo.character16 =  X_Character16)
                OR (    (Recinfo.character16 IS NULL)
                    AND (X_Character16 IS NULL)))
           AND (   (Recinfo.character17 =  X_Character17)
                OR (    (Recinfo.character17 IS NULL)
                    AND (X_Character17 IS NULL)))
           AND (   (Recinfo.character18 =  X_Character18)
                OR (    (Recinfo.character18 IS NULL)
                    AND (X_Character18 IS NULL)))
           AND (   (Recinfo.character19 =  X_Character19)
                OR (    (Recinfo.character19 IS NULL)
                    AND (X_Character19 IS NULL)))
           AND (   (Recinfo.character20 =  X_Character20)
                OR (    (Recinfo.character20 IS NULL)
                    AND (X_Character20 IS NULL)))
           AND (   (Recinfo.character21 =  X_Character21)
                OR (    (Recinfo.character21 IS NULL)
                    AND (X_Character21 IS NULL)))
           AND (   (Recinfo.character22 =  X_Character22)
                OR (    (Recinfo.character22 IS NULL)
                    AND (X_Character22 IS NULL)))
           AND (   (Recinfo.character23 =  X_Character23)
                OR (    (Recinfo.character23 IS NULL)
                    AND (X_Character23 IS NULL)))
           AND (   (Recinfo.character24 =  X_Character24)
                OR (    (Recinfo.character24 IS NULL)
                    AND (X_Character24 IS NULL)))
           AND (   (Recinfo.character25 =  X_Character25)
                OR (    (Recinfo.character25 IS NULL)
                    AND (X_Character25 IS NULL)))
           AND (   (Recinfo.character26 =  X_Character26)
                OR (    (Recinfo.character26 IS NULL)
                    AND (X_Character26 IS NULL)))
           AND (   (Recinfo.character27 =  X_Character27)
                OR (    (Recinfo.character27 IS NULL)
                    AND (X_Character27 IS NULL)))
           AND (   (Recinfo.character28 =  X_Character28)
                OR (    (Recinfo.character28 IS NULL)
                    AND (X_Character28 IS NULL)))
           AND (   (Recinfo.character29 =  X_Character29)
                OR (    (Recinfo.character29 IS NULL)
                    AND (X_Character29 IS NULL)))
           AND (   (Recinfo.character30 =  X_Character30)
                OR (    (Recinfo.character30 IS NULL)
                    AND (X_Character30 IS NULL)))
           AND (   (Recinfo.character31 =  X_Character31)
                OR (    (Recinfo.character31 IS NULL)
                    AND (X_Character31 IS NULL)))
           AND (   (Recinfo.character32 =  X_Character32)
                OR (    (Recinfo.character32 IS NULL)
                    AND (X_Character32 IS NULL)))
           AND (   (Recinfo.character33 =  X_Character33)
                OR (    (Recinfo.character33 IS NULL)
                    AND (X_Character33 IS NULL)))
           AND (   (Recinfo.character34 =  X_Character34)
                OR (    (Recinfo.character34 IS NULL)
                    AND (X_Character34 IS NULL)))
           AND (   (Recinfo.character35 =  X_Character35)
                OR (    (Recinfo.character35 IS NULL)
                    AND (X_Character35 IS NULL)))
           AND (   (Recinfo.character36 =  X_Character36)
                OR (    (Recinfo.character36 IS NULL)
                    AND (X_Character36 IS NULL)))
           AND (   (Recinfo.character37 =  X_Character37)
                OR (    (Recinfo.character37 IS NULL)
                    AND (X_Character37 IS NULL)))
           AND (   (Recinfo.character38 =  X_Character38)
                OR (    (Recinfo.character38 IS NULL)
                    AND (X_Character38 IS NULL)))
           AND (   (Recinfo.character39 =  X_Character39)
                OR (    (Recinfo.character39 IS NULL)
                    AND (X_Character39 IS NULL)))
           AND (   (Recinfo.character40 =  X_Character40)
                OR (    (Recinfo.character40 IS NULL)
                    AND (X_Character40 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (       (   (Recinfo.character41 =  X_Character41)
                OR (    (Recinfo.character41 IS NULL)
                    AND (X_Character41 IS NULL)))
	   AND (   (Recinfo.character42 =  X_Character42)
                OR (    (Recinfo.character42 IS NULL)
                    AND (X_Character42 IS NULL)))
           AND (   (Recinfo.character43 =  X_Character43)
                OR (    (Recinfo.character43 IS NULL)
                    AND (X_Character43 IS NULL)))
           AND (   (Recinfo.character44 =  X_Character44)
                OR (    (Recinfo.character44 IS NULL)
                    AND (X_Character44 IS NULL)))
           AND (   (Recinfo.character45 =  X_Character45)
                OR (    (Recinfo.character45 IS NULL)
                    AND (X_Character45 IS NULL)))
           AND (   (Recinfo.character46 =  X_Character46)
                OR (    (Recinfo.character46 IS NULL)
                    AND (X_Character46 IS NULL)))
           AND (   (Recinfo.character47 =  X_Character47)
                OR (    (Recinfo.character47 IS NULL)
                    AND (X_Character47 IS NULL)))
           AND (   (Recinfo.character48 =  X_Character48)
                OR (    (Recinfo.character48 IS NULL)
                    AND (X_Character48 IS NULL)))
           AND (   (Recinfo.character49 =  X_Character49)
                OR (    (Recinfo.character49 IS NULL)
                    AND (X_Character49 IS NULL)))
           AND (   (Recinfo.character50 =  X_Character50)
                OR (    (Recinfo.character50 IS NULL)
                    AND (X_Character50 IS NULL)))
           AND (   (Recinfo.character51 =  X_Character51)
                OR (    (Recinfo.character51 IS NULL)
                    AND (X_Character51 IS NULL)))
           AND (   (Recinfo.character52 =  X_Character52)
                OR (    (Recinfo.character52 IS NULL)
                    AND (X_Character52 IS NULL)))
           AND (   (Recinfo.character53 =  X_Character53)
                OR (    (Recinfo.character53 IS NULL)
                    AND (X_Character53 IS NULL)))
           AND (   (Recinfo.character54 =  X_Character54)
                OR (    (Recinfo.character54 IS NULL)
                    AND (X_Character54 IS NULL)))
           AND (   (Recinfo.character55 =  X_Character55)
                OR (    (Recinfo.character55 IS NULL)
                    AND (X_Character55 IS NULL)))
           AND (   (Recinfo.character56 =  X_Character56)
                OR (    (Recinfo.character56 IS NULL)
                    AND (X_Character56 IS NULL)))
           AND (   (Recinfo.character57 =  X_Character57)
                OR (    (Recinfo.character57 IS NULL)
                    AND (X_Character57 IS NULL)))
           AND (   (Recinfo.character58 =  X_Character58)
                OR (    (Recinfo.character58 IS NULL)
                    AND (X_Character58 IS NULL)))
           AND (   (Recinfo.character59 =  X_Character59)
                OR (    (Recinfo.character59 IS NULL)
                    AND (X_Character59 IS NULL)))
           AND (   (Recinfo.character60 =  X_Character60)
                OR (    (Recinfo.character60 IS NULL)
                    AND (X_Character60 IS NULL)))
           AND (   (Recinfo.character61 =  X_Character61)
                OR (    (Recinfo.character61 IS NULL)
                    AND (X_Character61 IS NULL)))
           AND (   (Recinfo.character62 =  X_Character62)
                OR (    (Recinfo.character62 IS NULL)
                    AND (X_Character62 IS NULL)))
           AND (   (Recinfo.character63 =  X_Character63)
                OR (    (Recinfo.character63 IS NULL)
                    AND (X_Character63 IS NULL)))
           AND (   (Recinfo.character64 =  X_Character64)
                OR (    (Recinfo.character64 IS NULL)
                    AND (X_Character64 IS NULL)))
           AND (   (Recinfo.character65 =  X_Character65)
                OR (    (Recinfo.character65 IS NULL)
                    AND (X_Character65 IS NULL)))
           AND (   (Recinfo.character66 =  X_Character66)
                OR (    (Recinfo.character66 IS NULL)
                    AND (X_Character66 IS NULL)))
           AND (   (Recinfo.character67 =  X_Character67)
                OR (    (Recinfo.character67 IS NULL)
                    AND (X_Character67 IS NULL)))
           AND (   (Recinfo.character68 =  X_Character68)
                OR (    (Recinfo.character68 IS NULL)
                    AND (X_Character68 IS NULL)))
           AND (   (Recinfo.character69 =  X_Character69)
                OR (    (Recinfo.character69 IS NULL)
                    AND (X_Character69 IS NULL)))
           AND (   (Recinfo.character70 =  X_Character70)
                OR (    (Recinfo.character70 IS NULL)
                    AND (X_Character70 IS NULL)))
           AND (   (Recinfo.character71 =  X_Character71)
                OR (    (Recinfo.character71 IS NULL)
                    AND (X_Character71 IS NULL)))
           AND (   (Recinfo.character72 =  X_Character72)
                OR (    (Recinfo.character72 IS NULL)
                    AND (X_Character72 IS NULL)))
           AND (   (Recinfo.character73 =  X_Character73)
                OR (    (Recinfo.character73 IS NULL)
                    AND (X_Character73 IS NULL)))
           AND (   (Recinfo.character74 =  X_Character74)
                OR (    (Recinfo.character74 IS NULL)
                    AND (X_Character74 IS NULL)))
           AND (   (Recinfo.character75 =  X_Character75)
                OR (    (Recinfo.character75 IS NULL)
                    AND (X_Character75 IS NULL)))
           AND (   (Recinfo.character76 =  X_Character76)
                OR (    (Recinfo.character76 IS NULL)
                    AND (X_Character76 IS NULL)))
           AND (   (Recinfo.character77 =  X_Character77)
                OR (    (Recinfo.character77 IS NULL)
                    AND (X_Character77 IS NULL)))
           AND (   (Recinfo.character78 =  X_Character78)
                OR (    (Recinfo.character78 IS NULL)
                    AND (X_Character78 IS NULL)))
           AND (   (Recinfo.character79 =  X_Character79)
                OR (    (Recinfo.character79 IS NULL)
                    AND (X_Character79 IS NULL)))
           AND (   (Recinfo.character80 =  X_Character80)
                OR (    (Recinfo.character80 IS NULL)
                    AND (X_Character80 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (       (   (Recinfo.character81 =  X_Character81)
                OR (    (Recinfo.character81 IS NULL)
                    AND (X_Character81 IS NULL)))
	   AND (   (Recinfo.character82 =  X_Character82)
                OR (    (Recinfo.character82 IS NULL)
                    AND (X_Character82 IS NULL)))
           AND (   (Recinfo.character83 =  X_Character83)
                OR (    (Recinfo.character83 IS NULL)
                    AND (X_Character83 IS NULL)))
           AND (   (Recinfo.character84 =  X_Character84)
                OR (    (Recinfo.character84 IS NULL)
                    AND (X_Character84 IS NULL)))
           AND (   (Recinfo.character85 =  X_Character85)
                OR (    (Recinfo.character85 IS NULL)
                    AND (X_Character85 IS NULL)))
           AND (   (Recinfo.character86 =  X_Character86)
                OR (    (Recinfo.character86 IS NULL)
                    AND (X_Character86 IS NULL)))
           AND (   (Recinfo.character87 =  X_Character87)
                OR (    (Recinfo.character87 IS NULL)
                    AND (X_Character87 IS NULL)))
           AND (   (Recinfo.character88 =  X_Character88)
                OR (    (Recinfo.character88 IS NULL)
                    AND (X_Character88 IS NULL)))
           AND (   (Recinfo.character89 =  X_Character89)
                OR (    (Recinfo.character89 IS NULL)
                    AND (X_Character89 IS NULL)))
           AND (   (Recinfo.character90 =  X_Character90)
                OR (    (Recinfo.character90 IS NULL)
                    AND (X_Character90 IS NULL)))
           AND (   (Recinfo.character91 =  X_Character91)
                OR (    (Recinfo.character91 IS NULL)
                    AND (X_Character91 IS NULL)))
           AND (   (Recinfo.character92 =  X_Character92)
                OR (    (Recinfo.character92 IS NULL)
                    AND (X_Character92 IS NULL)))
           AND (   (Recinfo.character93 =  X_Character93)
                OR (    (Recinfo.character93 IS NULL)
                    AND (X_Character93 IS NULL)))
           AND (   (Recinfo.character94 =  X_Character94)
                OR (    (Recinfo.character94 IS NULL)
                    AND (X_Character94 IS NULL)))
           AND (   (Recinfo.character95 =  X_Character95)
                OR (    (Recinfo.character95 IS NULL)
                    AND (X_Character95 IS NULL)))
           AND (   (Recinfo.character96 =  X_Character96)
                OR (    (Recinfo.character96 IS NULL)
                    AND (X_Character96 IS NULL)))
           AND (   (Recinfo.character97 =  X_Character97)
                OR (    (Recinfo.character97 IS NULL)
                    AND (X_Character97 IS NULL)))
           AND (   (Recinfo.character98 =  X_Character98)
                OR (    (Recinfo.character98 IS NULL)
                    AND (X_Character98 IS NULL)))
           AND (   (Recinfo.character99 =  X_Character99)
                OR (    (Recinfo.character99 IS NULL)
                    AND (X_Character99 IS NULL)))
           AND (   (Recinfo.character100 =  X_Character100)
                OR (    (Recinfo.character100 IS NULL)
                    AND (X_Character100 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (       (   (Recinfo.sequence1 =  X_Sequence1)
                OR (    (Recinfo.sequence1 IS NULL)
                    AND (X_Sequence1 IS NULL)))
           AND (   (Recinfo.sequence2 =  X_Sequence2)
                OR (    (Recinfo.sequence2 IS NULL)
                    AND (X_Sequence2 IS NULL)))
           AND (   (Recinfo.sequence3 =  X_Sequence3)
                OR (    (Recinfo.sequence3 IS NULL)
                    AND (X_Sequence3 IS NULL)))
           AND (   (Recinfo.sequence4 =  X_Sequence4)
                OR (    (Recinfo.sequence4 IS NULL)
                    AND (X_Sequence4 IS NULL)))
           AND (   (Recinfo.sequence5 =  X_Sequence5)
                OR (    (Recinfo.sequence5 IS NULL)
                    AND (X_Sequence5 IS NULL)))
           AND (   (Recinfo.sequence6 =  X_Sequence6)
                OR (    (Recinfo.sequence6 IS NULL)
                    AND (X_Sequence6 IS NULL)))
           AND (   (Recinfo.sequence7 =  X_Sequence7)
                OR (    (Recinfo.sequence7 IS NULL)
                    AND (X_Sequence7 IS NULL)))
           AND (   (Recinfo.sequence8 =  X_Sequence8)
                OR (    (Recinfo.sequence8 IS NULL)
                    AND (X_Sequence8 IS NULL)))
           AND (   (Recinfo.sequence9 =  X_Sequence9)
                OR (    (Recinfo.sequence9 IS NULL)
                    AND (X_Sequence9 IS NULL)))
           AND (   (Recinfo.sequence10 =  X_Sequence10)
                OR (    (Recinfo.sequence10 IS NULL)
                    AND (X_Sequence10 IS NULL)))
           AND (   (Recinfo.sequence11 =  X_Sequence11)
                OR (    (Recinfo.sequence11 IS NULL)
                    AND (X_Sequence11 IS NULL)))
           AND (   (Recinfo.sequence12 =  X_Sequence12)
                OR (    (Recinfo.sequence12 IS NULL)
                    AND (X_Sequence12 IS NULL)))
           AND (   (Recinfo.sequence13 =  X_Sequence13)
                OR (    (Recinfo.sequence13 IS NULL)
                    AND (X_Sequence13 IS NULL)))
           AND (   (Recinfo.sequence14 =  X_Sequence14)
                OR (    (Recinfo.sequence14 IS NULL)
                    AND (X_Sequence14 IS NULL)))
           AND (   (Recinfo.sequence15 =  X_Sequence15)
                OR (    (Recinfo.sequence15 IS NULL)
                    AND (X_Sequence15 IS NULL)))
           AND (   (Recinfo.comment1 =  X_Comment1)
                OR (    (Recinfo.comment1 IS NULL)
                    AND (X_Comment1 IS NULL)))
           AND (   (Recinfo.comment2 =  X_Comment2)
                OR (    (Recinfo.comment2 IS NULL)
                    AND (X_Comment2 IS NULL)))
           AND (   (Recinfo.comment3 =  X_Comment3)
                OR (    (Recinfo.comment3 IS NULL)
                    AND (X_Comment3 IS NULL)))
           AND (   (Recinfo.comment4 =  X_Comment4)
                OR (    (Recinfo.comment4 IS NULL)
                    AND (X_Comment4 IS NULL)))
           AND (   (Recinfo.comment5 =  X_Comment5)
                OR (    (Recinfo.comment5 IS NULL)
                    AND (X_Comment5 IS NULL)))
           AND (   (Recinfo.party_id =  X_Party_Id)
                OR (    (Recinfo.party_id IS NULL)
                    AND (X_Party_Id IS NULL)))
           AND (   (Recinfo.csi_instance_id =  X_Csi_Instance_Id)
                OR (    (Recinfo.csi_instance_id IS NULL)
                    AND (X_Csi_Instance_Id IS NULL)))
           AND (   (Recinfo.counter_id =  X_Counter_Id)
                OR (    (Recinfo.counter_id IS NULL)
                    AND (X_Counter_Id IS NULL)))
           AND (   (Recinfo.counter_reading_id =  X_Counter_Reading_Id)
                OR (    (Recinfo.counter_reading_id IS NULL)
                    AND (X_Counter_Reading_Id IS NULL)))
           AND (   (Recinfo.ahl_mr_id =  X_Ahl_Mr_Id)
                OR (    (Recinfo.ahl_mr_id IS NULL)
                    AND (X_Ahl_Mr_Id IS NULL)))
           AND (   (Recinfo.cs_incident_id =  X_Cs_Incident_Id)
                OR (    (Recinfo.cs_incident_id IS NULL)
                    AND (X_Cs_Incident_Id IS NULL)))
           AND (   (Recinfo.wip_rework_id =  X_Wip_Rework_Id)
                OR (    (Recinfo.wip_rework_id IS NULL)
                    AND (X_Wip_Rework_Id IS NULL)))
           AND (   (Recinfo.disposition_source =  X_Disposition_Source)
                OR (    (Recinfo.disposition_source IS NULL)
                    AND (X_Disposition_Source IS NULL)))
           AND (   (Recinfo.disposition =  X_Disposition)
                OR (    (Recinfo.disposition IS NULL)
                    AND (X_Disposition IS NULL)))
           AND (   (Recinfo.disposition_action =  X_Disposition_Action)
                OR (    (Recinfo.disposition_action IS NULL)
                    AND (X_Disposition_Action IS NULL)))
           AND (   (Recinfo.disposition_status =  X_Disposition_Status)
                OR (    (Recinfo.disposition_status IS NULL)
                    AND (X_Disposition_Status IS NULL)))
           AND (   (Recinfo.mti_transaction_header_id =  X_Mti_Transaction_Header_Id)
                OR (    (Recinfo.mti_transaction_header_id IS NULL)
                    AND (X_Mti_Transaction_Header_Id IS NULL)))
           AND (   (Recinfo.mti_transaction_interface_id =  X_Mti_Transaction_Interface_Id)
                OR (    (Recinfo.mti_transaction_interface_id IS NULL)
                    AND (X_Mti_Transaction_Interface_Id IS NULL)))
           AND (   (Recinfo.mmt_transaction_id =  X_Mmt_Transaction_Id)
                OR (    (Recinfo.mmt_transaction_id IS NULL)
                    AND (X_Mmt_Transaction_Id IS NULL)))
           AND (   (Recinfo.wjsi_group_id =  X_Wjsi_Group_Id)
                OR (    (Recinfo.wjsi_group_id IS NULL)
                    AND (X_Wjsi_Group_Id IS NULL)))
           AND (   (Recinfo.wmti_group_id =  X_Wmti_Group_Id)
                OR (    (Recinfo.wmti_group_id IS NULL)
                    AND (X_Wmti_Group_Id IS NULL)))
           AND (   (Recinfo.wmt_transaction_id =  X_Wmt_Transaction_Id)
                OR (    (Recinfo.wmt_transaction_id IS NULL)
                    AND (X_Wmt_Transaction_Id IS NULL)))
           AND (   (Recinfo.rti_interface_transaction_id =  X_Rti_Interface_Transaction_Id)
                OR (    (Recinfo.rti_interface_transaction_id IS NULL)
                    AND (X_Rti_Interface_Transaction_Id IS NULL)))
           AND (   (Recinfo.maintenance_op_seq = X_Maintenance_Op_Seq)
		OR (    (Recinfo.maintenance_op_seq IS NULL)
		    AND (X_Maintenance_Op_Seq IS NULL)))
          AND (   (Recinfo.bill_reference_id =  X_Bill_Reference_Id)
                OR (    (Recinfo.bill_reference_id IS NULL)
                    AND (X_Bill_Reference_Id IS NULL)))
          AND (   (Recinfo.routing_reference_id =  X_Routing_Reference_Id)
                OR (    (Recinfo.routing_reference_id IS NULL)
                    AND (X_Routing_Reference_Id IS NULL)))
          AND (   (Recinfo.to_subinventory =  X_To_Subinventory)
                OR (    (Recinfo.to_subinventory IS NULL)
                    AND (X_To_Subinventory IS NULL)))
          AND (   (Recinfo.to_locator_id =  X_To_Locator_Id)
                OR (    (Recinfo.to_locator_id IS NULL)
                    AND (X_To_Locator_Id IS NULL)))
           AND (   (Recinfo.concurrent_request_id = X_Concurrent_Request_Id )
                OR (    (Recinfo.concurrent_request_id IS NULL)
                    AND (X_Concurrent_Request_Id IS NULL)))
           AND (   (Recinfo.lot_status_id = X_Lot_Status_Id)
                OR (    (Recinfo.lot_status_id IS NULL)
                    AND (X_Lot_Status_Id IS NULL)))
           AND (   (Recinfo.serial_status_id = X_Serial_Status_Id)
                OR (    (Recinfo.serial_status_id IS NULL)
                    AND (X_Serial_Status_Id IS NULL)))
           AND (   (Recinfo.nonconformance_source = X_Nonconformance_Source)
                OR (    (Recinfo.nonconformance_source IS NULL)
                    AND (X_Nonconformance_Source IS NULL)))
           AND (   (Recinfo.nonconform_severity = X_Nonconform_Severity)
                OR (    (Recinfo.nonconform_severity IS NULL)
                    AND (X_Nonconform_Severity IS NULL)))
           AND (   (Recinfo.nonconform_priority = X_Nonconform_Priority)
                OR (    (Recinfo.nonconform_priority IS NULL)
                    AND (X_Nonconform_Priority IS NULL)))
           AND (   (Recinfo.nonconformance_type = X_Nonconformance_Type)
                OR (    (Recinfo.nonconformance_type IS NULL)
                    AND (X_Nonconformance_Type IS NULL)))
           AND (   (Recinfo.nonconformance_code = X_Nonconformance_Code)
                OR (    (Recinfo.nonconformance_code IS NULL)
                    AND (X_Nonconformance_Code IS NULL)))
           AND (   (Recinfo.nonconformance_status = X_Nonconformance_Status)
                OR (    (Recinfo.nonconformance_status IS NULL)
                    AND (X_Nonconformance_Status IS NULL)))
           AND (   (Recinfo.date_opened = X_Date_Opened)
                OR (    (Recinfo.date_opened IS NULL)
                    AND (X_Date_Opened IS NULL)))
           AND (   (Recinfo.date_closed = X_Date_Closed)
                OR (    (Recinfo.date_closed IS NULL)
                    AND (X_Date_Closed IS NULL)))
           AND (   (Recinfo.days_to_close = X_Days_To_Close)
                OR (    (Recinfo.days_to_close IS NULL)
                    AND (X_Days_To_Close IS NULL)))
           AND (   (Recinfo.rcv_transaction_id = X_Rcv_Transaction_Id)
                OR (    (Recinfo.rcv_transaction_id IS NULL)
                    AND (X_Rcv_Transaction_Id IS NULL)))
           AND (   (Recinfo.request_source = X_Request_Source)
                OR (    (Recinfo.request_source IS NULL)
                    AND (X_Request_Source IS NULL)))
           AND (   (Recinfo.request_priority = X_Request_Priority)
                OR (    (Recinfo.request_priority IS NULL)
                    AND (X_Request_Priority IS NULL)))
           AND (   (Recinfo.request_severity = X_Request_Severity)
                OR (    (Recinfo.request_severity IS NULL)
                    AND (X_Request_Severity IS NULL)))
           AND (   (Recinfo.request_status = X_Request_Status)
                OR (    (Recinfo.request_status IS NULL)
                    AND (X_Request_Status IS NULL)))
           AND (   (Recinfo.eco_name = X_Eco_Name )
                OR (    (Recinfo.eco_name IS NULL)
                    AND (X_Eco_Name IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;


--
-- Modified the proc signature and implementation
-- to include the database columns added for ASO support.
-- rkunchal Thu Jul 25 01:43:48 PDT 2002
--
--
-- See Bug 2588213
-- To support the element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--

-- Modified the signature to include NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

-- Modified the signature to include CAR Hardcode Elements.
-- anagarwa Thu Nov 14 13:03:35 PST 2002

-- Modified the signature to include new hardcoded elements followup activity, Transfer license plate number
-- saugupta

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Collection_Id                  NUMBER,
                       X_Occurrence                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Qa_Last_Update_Date            DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Qa_Last_Updated_By             NUMBER,
                       X_Qa_Creation_Date               DATE,
                       X_Qa_Created_By                  NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Transaction_Number             NUMBER,
                       X_Txn_Header_Id                  NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Plan_Id                        NUMBER,
                       X_Spec_Id                        NUMBER,
                       X_Transaction_Id                 NUMBER,
                       X_Department_Id                  NUMBER,
                       X_To_Department_Id               NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Quantity                       NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Uom                            VARCHAR2,
                       X_Revision                       VARCHAR2,
                       X_Subinventory                   VARCHAR2,
                       X_Locator_Id                     NUMBER,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Comp_Item_Id                   NUMBER,
                       X_Comp_Uom                       VARCHAR2,
                       X_Comp_Revision                  VARCHAR2,
                       X_Comp_Subinventory              VARCHAR2,
                       X_Comp_Locator_Id                NUMBER,
                       X_Comp_Lot_Number                VARCHAR2,
                       X_Comp_Serial_Number             VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Line_Id                        NUMBER,
                       X_To_Op_Seq_Num                  NUMBER,
                       X_From_Op_Seq_Num                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Receipt_Num                    VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       -- bug 9652549 CLM changes
                       X_Po_Line_Num                    VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Po_Shipment_Num                NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_So_Header_Id                   NUMBER,
                       X_Rma_Header_Id                  NUMBER,
		       X_Transaction_Date		DATE,
                       X_Status                         VARCHAR2,
                       X_Project_Id                     NUMBER ,
                       X_Task_ID                        NUMBER,
		       X_LPN_ID				NUMBER,
		       X_XFR_LPN_ID			NUMBER,
		       X_Contract_ID			NUMBER,
		       X_Contract_Line_ID		NUMBER,
		       X_Deliverable_ID			NUMBER,
		       X_Asset_Group_ID			NUMBER,
		       X_Asset_Number			VARCHAR2,
		       X_Asset_Instance_ID  NUMBER, --dgupta: R12 EAM Integration. Bug 4345492
		       X_Asset_Activity_ID		NUMBER,
		       X_Followup_Activity_ID		NUMBER,
		       X_Work_Order_ID			NUMBER,
                       X_Character1                     VARCHAR2,
                       X_Character2                     VARCHAR2,
                       X_Character3                     VARCHAR2,
                       X_Character4                     VARCHAR2,
                       X_Character5                     VARCHAR2,
                       X_Character6                     VARCHAR2,
                       X_Character7                     VARCHAR2,
                       X_Character8                     VARCHAR2,
                       X_Character9                     VARCHAR2,
                       X_Character10                    VARCHAR2,
                       X_Character11                    VARCHAR2,
                       X_Character12                    VARCHAR2,
                       X_Character13                    VARCHAR2,
                       X_Character14                    VARCHAR2,
                       X_Character15                    VARCHAR2,
                       X_Character16                    VARCHAR2,
                       X_Character17                    VARCHAR2,
                       X_Character18                    VARCHAR2,
                       X_Character19                    VARCHAR2,
                       X_Character20                    VARCHAR2,
                       X_Character21                    VARCHAR2,
                       X_Character22                    VARCHAR2,
                       X_Character23                    VARCHAR2,
                       X_Character24                    VARCHAR2,
                       X_Character25                    VARCHAR2,
                       X_Character26                    VARCHAR2,
                       X_Character27                    VARCHAR2,
                       X_Character28                    VARCHAR2,
                       X_Character29                    VARCHAR2,
                       X_Character30                    VARCHAR2,
                       X_Character31                    VARCHAR2,
                       X_Character32                    VARCHAR2,
                       X_Character33                    VARCHAR2,
                       X_Character34                    VARCHAR2,
                       X_Character35                    VARCHAR2,
                       X_Character36                    VARCHAR2,
                       X_Character37                    VARCHAR2,
                       X_Character38                    VARCHAR2,
                       X_Character39                    VARCHAR2,
                       X_Character40                    VARCHAR2,
                       X_Character41                    VARCHAR2,
                       X_Character42                    VARCHAR2,
                       X_Character43                    VARCHAR2,
                       X_Character44                    VARCHAR2,
                       X_Character45                    VARCHAR2,
                       X_Character46                    VARCHAR2,
                       X_Character47                    VARCHAR2,
                       X_Character48                    VARCHAR2,
                       X_Character49                    VARCHAR2,
                       X_Character50                    VARCHAR2,
                       X_Character51                    VARCHAR2,
                       X_Character52                    VARCHAR2,
                       X_Character53                    VARCHAR2,
                       X_Character54                    VARCHAR2,
                       X_Character55                    VARCHAR2,
                       X_Character56                    VARCHAR2,
                       X_Character57                    VARCHAR2,
                       X_Character58                    VARCHAR2,
                       X_Character59                    VARCHAR2,
                       X_Character60                    VARCHAR2,
                       X_Character61                    VARCHAR2,
                       X_Character62                    VARCHAR2,
                       X_Character63                    VARCHAR2,
                       X_Character64                    VARCHAR2,
                       X_Character65                    VARCHAR2,
                       X_Character66                    VARCHAR2,
                       X_Character67                    VARCHAR2,
                       X_Character68                    VARCHAR2,
                       X_Character69                    VARCHAR2,
                       X_Character70                    VARCHAR2,
                       X_Character71                    VARCHAR2,
                       X_Character72                    VARCHAR2,
                       X_Character73                    VARCHAR2,
                       X_Character74                    VARCHAR2,
                       X_Character75                    VARCHAR2,
                       X_Character76                    VARCHAR2,
                       X_Character77                    VARCHAR2,
                       X_Character78                    VARCHAR2,
                       X_Character79                    VARCHAR2,
                       X_Character80                    VARCHAR2,
                       X_Character81                    VARCHAR2,
                       X_Character82                    VARCHAR2,
                       X_Character83                    VARCHAR2,
                       X_Character84                    VARCHAR2,
                       X_Character85                    VARCHAR2,
                       X_Character86                    VARCHAR2,
                       X_Character87                    VARCHAR2,
                       X_Character88                    VARCHAR2,
                       X_Character89                    VARCHAR2,
                       X_Character90                    VARCHAR2,
                       X_Character91                    VARCHAR2,
                       X_Character92                    VARCHAR2,
                       X_Character93                    VARCHAR2,
                       X_Character94                    VARCHAR2,
                       X_Character95                    VARCHAR2,
                       X_Character96                    VARCHAR2,
                       X_Character97                    VARCHAR2,
                       X_Character98                    VARCHAR2,
                       X_Character99                    VARCHAR2,
                       X_Character100                   VARCHAR2,
                       X_Sequence1                      VARCHAR2,
                       X_Sequence2                      VARCHAR2,
                       X_Sequence3                      VARCHAR2,
                       X_Sequence4                      VARCHAR2,
                       X_Sequence5                      VARCHAR2,
                       X_Sequence6                      VARCHAR2,
                       X_Sequence7                      VARCHAR2,
                       X_Sequence8                      VARCHAR2,
                       X_Sequence9                      VARCHAR2,
                       X_Sequence10                     VARCHAR2,
                       X_Sequence11                     VARCHAR2,
                       X_Sequence12                     VARCHAR2,
                       X_Sequence13                     VARCHAR2,
                       X_Sequence14                     VARCHAR2,
                       X_Sequence15                     VARCHAR2,
                       X_Comment1                       VARCHAR2,
                       X_Comment2                       VARCHAR2,
                       X_Comment3                       VARCHAR2,
                       X_Comment4                       VARCHAR2,
                       X_Comment5                       VARCHAR2,
                       X_Party_Id                       NUMBER,
                       X_Csi_Instance_Id                NUMBER,
                       X_Counter_Id                     NUMBER,
                       X_Counter_Reading_Id             NUMBER,
                       X_Ahl_Mr_Id                      NUMBER,
                       X_Cs_Incident_Id                 NUMBER,
                       X_Wip_Rework_Id                  NUMBER,
                       X_Disposition_Source             VARCHAR2,
                       X_Disposition                    VARCHAR2,
                       X_Disposition_Action             VARCHAR2,
                       X_Disposition_Status             VARCHAR2,
                       X_Mti_Transaction_Header_Id      NUMBER,
                       X_Mti_Transaction_Interface_Id   NUMBER,
                       X_Mmt_Transaction_Id             NUMBER,
                       X_Wjsi_Group_Id                  NUMBER,
                       X_Wmti_Group_Id                  NUMBER,
                       X_Wmt_Transaction_Id             NUMBER,
                       X_Rti_Interface_Transaction_Id   NUMBER,
		       X_Maintenance_Op_Seq             NUMBER,
                       X_Bill_Reference_Id              NUMBER,
                       X_Routing_Reference_Id           NUMBER,
                       X_To_Subinventory                VARCHAR2,
                       X_To_Locator_Id                  NUMBER,
                       X_Concurrent_Request_Id          NUMBER,
                       X_Lot_Status_Id                  NUMBER,
                       X_Serial_Status_Id               NUMBER,
                       X_Nonconformance_Source          VARCHAR2,
                       X_Nonconform_Severity            VARCHAR2,
                       X_Nonconform_Priority            VARCHAR2,
                       X_Nonconformance_Type            VARCHAR2,
                       X_Nonconformance_Code            VARCHAR2,
                       X_Nonconformance_Status          VARCHAR2,
                       X_Date_Opened                    DATE,
                       X_Date_Closed                    DATE,
                       X_Days_To_Close                  NUMBER,
                       X_Rcv_Transaction_Id             NUMBER,
                       X_Request_Source                 VARCHAR2,
                       X_Request_Priority               VARCHAR2,
                       X_Request_Severity               VARCHAR2,
                       X_Request_Status                 VARCHAR2,
                       X_Eco_Name                       VARCHAR2,
		           /* R12 DR Integration. Bug 4345489 Start*/
          		     X_REPAIR_LINE_ID                 NUMBER,
			     X_JTF_TASK_ID                    NUMBER,
        	           /* R12 DR Integration. Bug 4345489 End*/

                       -- R12 OPM Deviations. Bug 4345503 Start
                       X_PROCESS_BATCH_ID               NUMBER,
	               X_PROCESS_BATCHSTEP_ID           NUMBER,
	               X_PROCESS_OPERATION_ID           NUMBER,
	               X_PROCESS_ACTIVITY_ID            NUMBER,
	               X_PROCESS_RESOURCE_ID            NUMBER,
	               X_PROCESS_PARAMETER_ID           NUMBER
                       -- R12 OPM Deviations. Bug 4345503 End
  ) IS
  BEGIN
    UPDATE QA_RESULTS
    SET
       collection_id                   =     X_Collection_Id,
       occurrence                      =     X_Occurrence,
       last_update_date                =     X_Last_Update_Date,
       qa_last_update_date             =     X_Qa_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       qa_last_updated_by              =     X_Qa_Last_Updated_By,
       qa_creation_date                =     X_Qa_Creation_Date,
       qa_created_by                   =     X_Qa_Created_By,
       last_update_login               =     X_Last_Update_Login,
       transaction_number              =     X_Transaction_Number,
       txn_header_id                   =     X_Txn_Header_Id,
       organization_id                 =     X_Organization_Id,
       plan_id                         =     X_Plan_Id,
       spec_id                         =     X_Spec_Id,
       transaction_id                  =     X_Transaction_Id,
       department_id                   =     X_Department_Id,
       to_department_id                =     X_To_Department_Id,
       resource_id                     =     X_Resource_Id,
       quantity                        =     X_Quantity,
       item_id                         =     X_Item_Id,
       uom                             =     X_Uom,
       revision                        =     X_Revision,
       subinventory                    =     X_Subinventory,
       locator_id                      =     X_Locator_Id,
       lot_number                      =     X_Lot_Number,
       serial_number                   =     X_Serial_Number,
       comp_item_id                    =     X_Comp_Item_Id,
       comp_uom                        =     X_Comp_Uom,
       comp_revision                   =     X_Comp_Revision,
       comp_subinventory               =     X_Comp_Subinventory,
       comp_locator_id                 =     X_Comp_Locator_Id,
       comp_lot_number                 =     X_Comp_Lot_Number,
       comp_serial_number              =     X_Comp_Serial_Number,
       wip_entity_id                   =     X_Wip_Entity_Id,
       line_id                         =     X_Line_Id,
       to_op_seq_num                   =     X_To_Op_Seq_Num,
       from_op_seq_num                 =     X_From_Op_Seq_Num,
       vendor_id                       =     X_Vendor_Id,
       receipt_num                     =     X_Receipt_Num,
       po_header_id                    =     X_Po_Header_Id,
       po_line_num                     =     X_Po_Line_Num,
       po_release_id                   =     X_Po_Release_Id,
       po_shipment_num                 =     X_Po_Shipment_Num,
       customer_id                     =     X_Customer_Id,
       so_header_id                    =     X_So_Header_Id,
       rma_header_id                   =     X_Rma_Header_Id,
       transaction_date		       =     X_Transaction_Date,
       status                          =     X_Status ,
       Project_Id                      =     X_Project_Id,
       Task_Id                         =     X_Task_Id ,
       LPN_ID			       =     X_LPN_ID,
       XFR_LPN_ID      		       =     X_XFR_LPN_ID,
       Contract_ID		       =     X_Contract_ID,
       Contract_Line_ID		       =     X_Contract_Line_ID,
       Deliverable_ID		       =     X_Deliverable_ID,
       Asset_Group_ID		       =     X_Asset_Group_ID,
       Asset_Number		       =     X_Asset_Number,
       Asset_Instance_ID             =     X_Asset_Instance_ID, --dgupta: R12 EAM Integration. Bug 4345492
       Asset_Activity_ID	       =     X_Asset_Activity_ID,
       Followup_Activity_ID	       =     X_Followup_Activity_ID,
       Work_Order_ID		       =     X_Work_Order_ID,
       character1                      =     X_Character1,
       character2                      =     X_Character2,
       character3                      =     X_Character3,
       character4                      =     X_Character4,
       character5                      =     X_Character5,
       character6                      =     X_Character6,
       character7                      =     X_Character7,
       character8                      =     X_Character8,
       character9                      =     X_Character9,
       character10                     =     X_Character10,
       character11                     =     X_Character11,
       character12                     =     X_Character12,
       character13                     =     X_Character13,
       character14                     =     X_Character14,
       character15                     =     X_Character15,
       character16                     =     X_Character16,
       character17                     =     X_Character17,
       character18                     =     X_Character18,
       character19                     =     X_Character19,
       character20                     =     X_Character20,
       character21                     =     X_Character21,
       character22                     =     X_Character22,
       character23                     =     X_Character23,
       character24                     =     X_Character24,
       character25                     =     X_Character25,
       character26                     =     X_Character26,
       character27                     =     X_Character27,
       character28                     =     X_Character28,
       character29                     =     X_Character29,
       character30                     =     X_Character30,
       character31                     =     X_Character31,
       character32                     =     X_Character32,
       character33                     =     X_Character33,
       character34                     =     X_Character34,
       character35                     =     X_Character35,
       character36                     =     X_Character36,
       character37                     =     X_Character37,
       character38                     =     X_Character38,
       character39                     =     X_Character39,
       character40                     =     X_Character40,
       character41                      =     X_Character41,
       character42                      =     X_Character42,
       character43                      =     X_Character43,
       character44                      =     X_Character44,
       character45                      =     X_Character45,
       character46                      =     X_Character46,
       character47                      =     X_Character47,
       character48                      =     X_Character48,
       character49                      =     X_Character49,
       character50                     =     X_Character50,
       character51                     =     X_Character51,
       character52                     =     X_Character52,
       character53                     =     X_Character53,
       character54                     =     X_Character54,
       character55                     =     X_Character55,
       character56                     =     X_Character56,
       character57                     =     X_Character57,
       character58                     =     X_Character58,
       character59                     =     X_Character59,
       character60                     =     X_Character60,
       character61                     =     X_Character61,
       character62                     =     X_Character62,
       character63                     =     X_Character63,
       character64                     =     X_Character64,
       character65                     =     X_Character65,
       character66                     =     X_Character66,
       character67                     =     X_Character67,
       character68                     =     X_Character68,
       character69                     =     X_Character69,
       character70                     =     X_Character70,
       character71                     =     X_Character71,
       character72                     =     X_Character72,
       character73                     =     X_Character73,
       character74                     =     X_Character74,
       character75                     =     X_Character75,
       character76                     =     X_Character76,
       character77                     =     X_Character77,
       character78                     =     X_Character78,
       character79                     =     X_Character79,
       character80                     =     X_Character80,
       character81                      =     X_Character81,
       character82                      =     X_Character82,
       character83                      =     X_Character83,
       character84                      =     X_Character84,
       character85                      =     X_Character85,
       character86                      =     X_Character86,
       character87                      =     X_Character87,
       character88                      =     X_Character88,
       character89                      =     X_Character89,
       character90                     =     X_Character90,
       character91                     =     X_Character91,
       character92                     =     X_Character92,
       character93                     =     X_Character93,
       character94                     =     X_Character94,
       character95                     =     X_Character95,
       character96                     =     X_Character96,
       character97                     =     X_Character97,
       character98                     =     X_Character98,
       character99                     =     X_Character99,
       character100                     =     X_Character100,
       sequence1			=     X_Sequence1,
       sequence2                        =     X_Sequence2,
       sequence3                        =     X_Sequence3,
       sequence4                        =     X_Sequence4,
       sequence5                        =     X_Sequence5,
       sequence6                        =     X_Sequence6,
       sequence7                        =     X_Sequence7,
       sequence8                        =     X_Sequence8,
       sequence9                        =     X_Sequence9,
       sequence10                       =     X_Sequence10,
       sequence11                       =     X_Sequence11,
       sequence12                       =     X_Sequence12,
       sequence13                       =     X_Sequence13,
       sequence14                       =     X_Sequence14,
       sequence15                       =     X_Sequence15,
       comment1                         =     X_Comment1,
       comment2                         =     X_Comment2,
       comment3                         =     X_Comment3,
       comment4                         =     X_Comment4,
       comment5                         =     X_Comment5,
       party_id                         =     X_Party_Id,
       csi_instance_id                  =     X_Csi_Instance_Id,
       counter_id                       =     X_Counter_Id,
       counter_reading_id               =     X_Counter_Reading_Id,
       ahl_mr_id                        =     X_Ahl_Mr_Id,
       cs_incident_id                   =     X_Cs_Incident_Id,
       wip_rework_id                    =     X_Wip_Rework_Id,
       disposition_source               =     X_Disposition_Source,
       disposition                      =     X_Disposition,
       disposition_action               =     X_Disposition_Action,
       disposition_status               =     X_Disposition_Status,
       mti_transaction_header_id        =     X_Mti_Transaction_Header_Id,
       mti_transaction_interface_id     =     X_Mti_Transaction_Interface_Id,
       mmt_transaction_id               =     X_Mmt_Transaction_Id,
       wjsi_group_id                    =     X_Wjsi_Group_Id,
       wmti_group_id                    =     X_Wmti_Group_Id,
       wmt_transaction_id               =     X_Wmt_Transaction_Id,
       rti_interface_transaction_id     =     X_Rti_Interface_Transaction_Id,
       maintenance_op_seq               =     X_Maintenance_Op_Seq,
       bill_reference_id                =     X_Bill_Reference_Id,
       routing_reference_id             =     X_Routing_Reference_Id,
       to_subinventory                  =     X_To_Subinventory,
       to_locator_id                    =     X_To_Locator_Id,
       concurrent_request_id            =     X_Concurrent_Request_Id,
       lot_status_id                    =     X_Lot_Status_Id,
       serial_status_id                 =     X_Serial_Status_Id,
       nonconformance_source            =     X_Nonconformance_Source,
       nonconform_severity              =     X_Nonconform_Severity,
       nonconform_priority              =     X_Nonconform_Priority,
       nonconformance_type              =     X_Nonconformance_Type,
       nonconformance_code              =     X_Nonconformance_Code,
       nonconformance_status            =     X_Nonconformance_Status,
       date_opened                      =     X_Date_Opened,
       date_closed                      =     X_Date_Closed,
       days_to_close                    =     X_Days_To_Close,
       rcv_transaction_id               =     X_Rcv_Transaction_Id,
       request_source                   =     X_Request_Source,
       request_priority                 =     X_Request_Priority,
       request_severity                 =     X_Request_Severity,
       request_status                   =     X_Request_Status,
       eco_name                         =     X_Eco_Name,
       /* R12 DR Integration. Bug 4345489 Start */
       repair_line_id                   =     X_REPAIR_LINE_ID,
       jtf_task_id			    =     X_JTF_TASK_ID,
       /* R12 DR Integration. Bug 4345489 End */

       -- R12 OPM Deviations. Bug 4345503 Start
       PROCESS_BATCH_ID                 =     X_PROCESS_BATCH_ID,
       PROCESS_BATCHSTEP_ID             =     X_PROCESS_BATCHSTEP_ID,
       PROCESS_OPERATION_ID             =     X_PROCESS_OPERATION_ID,
       PROCESS_ACTIVITY_ID              =     X_PROCESS_ACTIVITY_ID,
       PROCESS_RESOURCE_ID              =     X_PROCESS_RESOURCE_ID,
       PROCESS_PARAMETER_ID             =     X_PROCESS_PARAMETER_ID
       -- R12 OPM Deviations. Bug 4345503 End
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM QA_RESULTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END QA_RESULTS_PKG;

/
