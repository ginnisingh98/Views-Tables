--------------------------------------------------------
--  DDL for Package WIP_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CONSTANTS" AUTHID CURRENT_USER AS
 /* $Header: wipconss.pls 120.3.12000000.4 2007/10/17 06:53:46 mraman ship $ */

  ----------------------
  -- Global Variables --
  ----------------------
  WIP_MOVE_WORKER VARCHAR2(1) := 'N';

  MAX_NUMBER_PRECISION    CONSTANT NUMBER := 38;
  MAX_DISPLAYED_PRECISION CONSTANT NUMBER := 6;
  INV_MAX_PRECISION       CONSTANT NUMBER := 6;
  ------------------
  -- Lookup Codes --
  ------------------

  -- BASIS_TYPE -- component requirement basis type lookup code   /* LBM Project */
  ITEM_BASED_MTL CONSTANT NUMBER := 1;
  LOT_BASED_MTL CONSTANT NUMBER := 2;


  -- PREFER INHERITANCE
  PREF_INHERITED CONSTANT NUMBER := 1;
  PREF_NOT_INHERITED CONSTANT NUMBER := 2;


  -- BOM_ACTION
  DELETE_WKDY CONSTANT NUMBER := 1;
  MODIFY_WKDY CONSTANT NUMBER := 2;
  ADD_WKDY    CONSTANT NUMBER := 3;

  -- BOM_AUTOCHARGE_TYPE
  WIP_MOVE   CONSTANT NUMBER := 1;
  MANUAL     CONSTANT NUMBER := 2;
  PO_RECEIPT CONSTANT NUMBER := 3;
  PO_MOVE    CONSTANT NUMBER := 4;

  -- BOM_RESOURCE_SCHEDULE_TYPE
  SCHED_YES   CONSTANT NUMBER := 1;
  SCHED_NO    CONSTANT NUMBER := 2;
  SCHED_PRIOR CONSTANT NUMBER := 3;
  SCHED_NEXT  CONSTANT NUMBER := 4;

  -- BOM_COUNT_POINT_TYPE
  YES_AUTO  CONSTANT NUMBER := 1;
  NO_AUTO   CONSTANT NUMBER := 2;
  NO_DIRECT CONSTANT NUMBER := 3;

  -- MCG_COUNT_POINT
--  YES_AUTO      CONSTANT NUMBER := 1; duplicate constant definition
--  NO_AUTO       CONSTANT NUMBER := 2; duplicate constant definition
  NO_MANUAL     CONSTANT NUMBER := 3;

  -- BOM RESOURCE TYPE
  RES_MACHINE CONSTANT NUMBER := 1;
  RES_PERSON  CONSTANT NUMBER := 2;
  RES_SPACE   CONSTANT NUMBER := 3;
  RES_MISC    CONSTANT NUMBER := 4;
  RES_AMOUNT  CONSTANT NUMBER := 5;

  -- BOM ASSEMBLY TYPE
  MANUFACTURING_BILL CONSTANT NUMBER := 1;
  ENGINEERING_BILL CONSTANT NUMBER := 2 ;

  -- CST_BASIS
  PER_ITEM     CONSTANT NUMBER := 1;
  PER_LOT      CONSTANT NUMBER := 2;
  PER_RESUNITS CONSTANT NUMBER := 3;
  PER_RESVALUE CONSTANT NUMBER := 4;
  PER_TOTVALUE CONSTANT NUMBER := 5;
  PER_ACTUNITS CONSTANT NUMBER := 6;

  -- CST_WIP_TRANSACTION_TYPE
  RES_TXN       CONSTANT NUMBER := 1;
  OVHD_TXN      CONSTANT NUMBER := 2;
  OSP_TXN       CONSTANT NUMBER := 3;
  COST_UPD_TXN  CONSTANT NUMBER := 4;
  PER_CLOSE_TXN CONSTANT NUMBER := 5;
  JOB_CLOSE_TXN CONSTANT NUMBER := 6;

  -- WIP_MOVE_TRANSACTION_TYPE
  MOVE_TXN      CONSTANT NUMBER := 1;  -- Normal move transaction
  COMP_TXN      CONSTANT NUMBER := 2;  -- Easy completion transaction
  RET_TXN       CONSTANT NUMBER := 3;  -- Easy return transaction


  -- MTL_ENG_QUANTITY
  NO_REV        CONSTANT NUMBER := 1;
  REV           CONSTANT NUMBER := 2;

  -- MTL_ITEM_LOCATOR_CONTROL
  NO_CONTROL    CONSTANT NUMBER := 1;
  PRESPECIFIED  CONSTANT NUMBER := 2;
  DYNAMIC       CONSTANT NUMBER := 3;

  -- MTL_LOT_CONTROL
  NO_LOT        CONSTANT NUMBER := 1;
  LOT           CONSTANT NUMBER := 2;

  -- MTL_LOT_GENERATION
  ORG_LEVEL     CONSTANT NUMBER := 1;
  ITEM_LEVEL    CONSTANT NUMBER := 2;
  USER_DEFINED  CONSTANT NUMBER := 3;

  -- MTL_SERIAL_NUMBER
  NO_SN         CONSTANT NUMBER := 1;
  FULL_SN       CONSTANT NUMBER := 2;
  DYN_RCV_SN    CONSTANT NUMBER := 5;
  DYN_SO_SN     CONSTANT NUMBER := 6;

  -- MTL_SERIAL_NUMBER.CURRENT_STATUS
  DEF_NOT_USED  CONSTANT NUMBER := 1;
  IN_STORES     CONSTANT NUMBER := 3;
  OUT_OF_STORES CONSTANT NUMBER := 4;
  IN_TRANSIT    CONSTANT NUMBER := 5;

  -- SHELF_LIFE_CODE
  SHELF_LIFE       CONSTANT NUMBER := 2;
  USER_DEFINED_EXP CONSTANT NUMBER := 4;

  -- SYS_YES_NO
  YES           CONSTANT NUMBER := 1;
  NO            CONSTANT NUMBER := 2;

  -- TRANSACTION PROCESS MODES
  NO_PROCESSING CONSTANT NUMBER := -1;
  ONLINE        CONSTANT NUMBER := 1;
  IMMED_CONC    CONSTANT NUMBER := 2;
  BACKGROUND    CONSTANT NUMBER := 3;
  FORM_LEVEL    CONSTANT NUMBER := 4;

  -- SOURCE CODE
  SOURCE_CODE   CONSTANT VARCHAR2(14) := 'OA Transaction';

  --MTL_TRANSACTIONS_INTERFACE PROCESS FLAG VALUES
  MTI_INVENTORY CONSTANT NUMBER := 1;
  MTI_NO        CONSTANT NUMBER := 2;
  MTI_ERROR     CONSTANT NUMBER := 3;
  MTI_WIP       CONSTANT NUMBER := 4;

  --MTL_MATERIAL_TRANSACTIONS_TEMP PROCESS FLAG VALUES
  MMTT_INVENTORY CONSTANT VARCHAR2(1) := 'Y';
  MMTT_NO        CONSTANT VARCHAR2(1) := 'N';
  MMTT_ERROR     CONSTANT VARCHAR2(1) := 'E';
  MMTT_WIP       CONSTANT VARCHAR2(1) := 'W';

  -- WIP_BACKFLUSH_LOT_ENTRY
  MAN_ENTRY    CONSTANT NUMBER := 1; -- Manual selection, verify all
  RECDATE_FULL CONSTANT NUMBER := 2; -- Receipt date fifo, verify all
  RECDATE_EXC  CONSTANT NUMBER := 3; -- Receipt date fifo, verify exceptions
  EXPDATE_FULL CONSTANT NUMBER := 4; -- Expiration date fifo, verify all
  EXPDATE_EXC  CONSTANT NUMBER := 5; -- Expiration date fifo, verify exceptions
/* Added for Wilson Greatbatch Enhancement */
  TXNHISTORY_FULL CONSTANT NUMBER := 6 ; --Transaction History lifo , verify all
  TXNHISTORY_EXC CONSTANT NUMBER := 7 ;-- Transaction History lifo, verify exceptions

  -- WIP_CLASS_TYPE
  DISC_CLASS              CONSTANT NUMBER := 1;
  REP_CLASS               CONSTANT NUMBER := 2;
  NS_ASSET_CLASS          CONSTANT NUMBER := 3;
  NS_EXPENSE_CLASS        CONSTANT NUMBER := 4;
  LOT_CLASS               CONSTANT NUMBER := 5;
  EAM_CLASS               CONSTANT NUMBER := 6;
  NS_LOT_EXPENSE_CLASS    CONSTANT NUMBER := 7;

  -- WIP_CHARGE
  DISC_CHARGING CONSTANT NUMBER := 1; -- discrete charging only
  FLOW_CHARGING CONSTANT NUMBER := 3; -- assembly flow charging

  -- WIP_COST_DISTRIBUTION
  ELEM_COST CONSTANT NUMBER := 3; -- Elemental value

  -- WIP_DISCRETE_JOB
  STANDARD       CONSTANT NUMBER := 1;
  NONSTANDARD    CONSTANT NUMBER := 3;

  -- WIP_ENTITY_TYPE
  DISCRETE    CONSTANT NUMBER := 1;
  REPETITIVE  CONSTANT NUMBER := 2;
  CLOSED_DISC CONSTANT NUMBER := 3;
  FLOW        CONSTANT NUMBER := 4;
  LOTBASED    CONSTANT NUMBER := 5;
  EAM         CONSTANT NUMBER := 6;
  CLOSED_EAM  CONSTANT NUMBER := 7;
  CLOSED_OSFM CONSTANT NUMBER := 8;

  -- WIP_INTRAOPERATION_STEP
  QUEUE  CONSTANT NUMBER := 1;
  RUN    CONSTANT NUMBER := 2;
  TOMOVE CONSTANT NUMBER := 3;
  REJECT CONSTANT NUMBER := 4;
  SCRAP  CONSTANT NUMBER := 5;

  -- WIP_JOB_STATUS
  UNRELEASED  CONSTANT NUMBER :=  1; -- Unreleased - no charges allowed
  SIMULATED   CONSTANT NUMBER :=  2; -- Simulated
  RELEASED    CONSTANT NUMBER :=  3; -- Released - charges allowed
  COMP_CHRG   CONSTANT NUMBER :=  4; -- Complete - charges allowed
  COMP_NOCHRG CONSTANT NUMBER :=  5; -- Complete - no charges allowed
  HOLD        CONSTANT NUMBER :=  6; -- Hold - no charges allowed
  CANCELLED   CONSTANT NUMBER :=  7; -- Cancelled - no charges allowed
  PEND_BOM    CONSTANT NUMBER :=  8; -- Pending bill of material load
  FAIL_BOM    CONSTANT NUMBER :=  9; -- Failed bill of material load
  PEND_ROUT   CONSTANT NUMBER := 10; -- Pending routing load
  FAIL_ROUT   CONSTANT NUMBER := 11; -- Failed routing load
  CLOSED      CONSTANT NUMBER := 12; -- Closed - no charges allowed
  PEND_REPML  CONSTANT NUMBER := 13; -- Pending - repetitively mass loaded
  PEND_CLOSE  CONSTANT NUMBER := 14; -- Pending Close
  FAIL_CLOSE  CONSTANT NUMBER := 15; -- Failed Close
  PEND_SCHED  CONSTANT NUMBER := 16; -- Pending Scheduling  /* FS */
  DRAFT       CONSTANT NUMBER := 17; -- Draft

  -- WIP_LIE_SCHED_TYPE
  RATEBASE CONSTANT NUMBER := 1; -- Rate-based scheduling
  ROUTBASE CONSTANT NUMBER := 2; -- Routing-based scheduling

  -- WIP_LOAD_TYPE
  CREATE_JOB      CONSTANT NUMBER := 1;      -- Create a standard discrete job
  CREATE_SCHED    CONSTANT NUMBER := 2;      -- Create a repetitive schedule
  RESCHED_JOB     CONSTANT NUMBER := 3;      -- Reschedule a discrete job
  CREATE_NS_JOB   CONSTANT NUMBER := 4;      -- Create a non-standard discrete job
  CREATE_LOT_JOB  CONSTANT NUMBER := 5;      -- Create Lot based job
  RESCHED_LOT_JOB CONSTANT NUMBER := 6;      -- Reschedule a lot based job
  CREATE_EAM_JOB  CONSTANT NUMBER := 7;      -- Create an EAM job
  RESCHED_EAM_JOB CONSTANT NUMBER := 8;      -- Reschedule an EAM job

  MI_NUM_LOAD_TYPES  CONSTANT NUMBER := 8;  -- The number of load types

  -- WIP_LOT_DEFAULT
  DEFAULT_JOB CONSTANT NUMBER := 1;
  DEFAULT_INV CONSTANT NUMBER := 2;
  NO_DEFAULT  CONSTANT NUMBER := 3;

  -- WIP_ML_PROCESS_PHASE
  ML_VALIDATION    CONSTANT NUMBER := 2;
  ML_EXPLOSION     CONSTANT NUMBER := 3;
  ML_INSERTION     CONSTANT NUMBER := 5;
  ML_COMPLETE      CONSTANT NUMBER := 4;

  -- WIP_ML_VALIDATION_LEVEL
  FULL          CONSTANT NUMBER := 0;
  MRP           CONSTANT NUMBER := 1;
  ATO           CONSTANT NUMBER := 2;
  INV           CONSTANT NUMBER := 3;
  SERVICE       CONSTANT NUMBER := 4;

  -- WIP_MOVE_PROCESS_PHASE
  MOVE_VAL   CONSTANT NUMBER := 1;
  MOVE_PROC  CONSTANT NUMBER := 2;
  BF_SETUP   CONSTANT NUMBER := 3;

  -- WIP_MRP_CONTROL
  SUPPLY_NET CONSTANT NUMBER := 1;
  DEMAND_NET CONSTANT NUMBER := 2;
  NO_NET     CONSTANT NUMBER := 3;

  -- WIP_PO_CREATION_TIME
  AT_JOB_SCHEDULE_RELEASE       CONSTANT NUMBER := 1;
  AT_OPERATION                  CONSTANT NUMBER := 2;
  MANUAL_CREATION               CONSTANT NUMBER := 3;

  -- WIP_PROCESS_STATUS
  PENDING    CONSTANT NUMBER := 1;
  RUNNING    CONSTANT NUMBER := 2;
  ERROR      CONSTANT NUMBER := 3;
  COMPLETED  CONSTANT NUMBER := 4;
  WARNING    CONSTANT NUMBER := 5;

  -- WIP_RESCHEDULE
  ENDPOINT   CONSTANT NUMBER := 1;       -- Endpoint rescheduling
  MIDPOINT   CONSTANT NUMBER := 2;       -- Midpoint rescheduling

  -- WIP_RESOURCE_PROCESS_PHASE
  RES_VAL    CONSTANT NUMBER := 1;
  RES_PROC   CONSTANT NUMBER := 2;

  -- WIP_SCHED_DIRECTION
  FORWARDS           CONSTANT NUMBER := 1;
  BACKWARDS          CONSTANT NUMBER := 4;
  NONE               CONSTANT NUMBER := 5;
--  MIDPOINT           CONSTANT NUMBER := 2; --this is defined above
  MIDPOINT_FORWARDS  CONSTANT NUMBER := 7;
  MIDPOINT_BACKWARDS CONSTANT NUMBER := 8;
  CURRENT_OP         CONSTANT NUMBER := 9;
  CURRENT_OP_RES     CONSTANT NUMBER := 10;
  CURRENT_SUB_GRP    CONSTANT NUMBER := 11;
  -- WIP_SCHEDULE_DIRECTION
  FUSD   CONSTANT NUMBER := 1;
  FUCD   CONSTANT NUMBER := 2;
  LUSD   CONSTANT NUMBER := 3;
  LUCD   CONSTANT NUMBER := 4;

  -- WIP_SCHEDULING_LEVEL
  OPLEVEL  CONSTANT NUMBER := 1;
  RESLEVEL CONSTANT NUMBER := 2;

  -- WIP_SCHEDULE_METHOD
  ROUTING   CONSTANT NUMBER := 1;
  LEADTIME  CONSTANT NUMBER := 2;
  ML_MANUAL CONSTANT NUMBER := 3;

  -- WIP_SO_CHANGE_TYPE
  NEVER      CONSTANT NUMBER := 1;
  ALWAYS     CONSTANT NUMBER := 2;
  ONETOONE   CONSTANT NUMBER := 3;

  -- WIP_SUPPLY
  PUSH         CONSTANT NUMBER := 1; -- Material pushed
  ASSY_PULL    CONSTANT NUMBER := 2; -- Assembly completion pull
  OP_PULL      CONSTANT NUMBER := 3; -- Operation pull
  BULK         CONSTANT NUMBER := 4;
  VENDOR       CONSTANT NUMBER := 5;
  PHANTOM      CONSTANT NUMBER := 6; -- Component is a phantom bill
  BASED_ON_BOM CONSTANT NUMBER := 7; -- Supply based on bill of material

  -- REPETITIVE ROLL FORWARD TYPES
  ROLL_EC_IMP   CONSTANT NUMBER := 1;
  ROLL_COMPLETE CONSTANT NUMBER := 2;
  ROLL_CANCEL   CONSTANT NUMBER := 3;

  -- COST METHODS
  COST_STD CONSTANT NUMBER := 1;
  COST_AVG CONSTANT NUMBER := 2;
  COST_FIFO CONSTANT NUMBER := 5;
  COST_LIFO CONSTANT NUMBER := 6;

  -- COST SOURCES
  COST_SRC_SYS CONSTANT NUMBER := 1; -- System Calculated
  COST_SRC_USR CONSTANT NUMBER := 2; -- User Defined

  -- Backflush constants
  WBF_NOBF      CONSTANT NUMBER := 0; -- No components to backflush
  WBF_BF_NOPAGE CONSTANT NUMBER := 1; -- Some backflush components; no BF page
  WBF_BF_PAGE   CONSTANT NUMBER := 2; -- Some backflush components; BF page

  -- Completion constants
  WASSY_COMPLETION CONSTANT NUMBER := 1;
  WASSY_RETURN     CONSTANT NUMBER := 2;

  -----------------------
  -- Constants
  -----------------------

  EXPLODED_PHANT CONSTANT NUMBER := -99; -- As an op_seq indicates that
                                         -- the phantom is exploded
                                         -- use only with phantoms
  UNKNOWN_USER   CONSTANT NUMBER := -1;  -- value for WHO column if user
                                         -- is not known

  -- Constant for Warning Status
   WARN CONSTANT VARCHAR2(1) := 'W';/* For Bug 5860709 : Constant for Warning Status*/

  --Constants for WIP WO Scheduling Relationships
  --Constants for Relationship Type
  G_REL_TYPE_CONSTRAINED      CONSTANT    NUMBER := 1;
  G_REL_TYPE_DEPENDENT        CONSTANT    NUMBER := 2;

  --Constants for Object Type
  G_Obj_TYPE_WO               CONSTANT    NUMBER := 1;

  --Constants for Relationship Status
  G_REL_Status_Pending        CONSTANT    NUMBER := 0;
  G_REL_Status_Processing     CONSTANT    NUMBER := 1;
  G_REL_Status_Valid          CONSTANT    NUMBER := 2;
  G_REL_Status_Invalid        CONSTANT    NUMBER := 3;


  -- Material Transaction Actions
  ISSCOMP_ACTION CONSTANT NUMBER :=  1;  -- Components taken out of INV
  SUBTRFR_ACTION CONSTANT NUMBER :=  2;  -- Subinventory Transfer
  COSTUPD_ACTION CONSTANT NUMBER := 24;  -- Cost update
  RETCOMP_ACTION CONSTANT NUMBER := 27;  -- Components put into INV
  SCRASSY_ACTION CONSTANT NUMBER := 30;  -- Assembly scrap
  CPLASSY_ACTION CONSTANT NUMBER := 31;  -- Assemblies put into INV
  RETASSY_ACTION CONSTANT NUMBER := 32;  -- Assemblies taken out of INV
  ISSNEGC_ACTION CONSTANT NUMBER := 33;  -- Negative component issue
  RETNEGC_ACTION CONSTANT NUMBER := 34;  -- Negative component return

  -- Material Transaction Types
  ISSCOMP_TYPE CONSTANT NUMBER := 35;    -- Components taken out of INV
  BFLREPL_TYPE CONSTANT NUMBER := 51;    -- Backflush replenishment
  COSTUPD_TYPE CONSTANT NUMBER := 25;    -- Cost update
  RETCOMP_TYPE CONSTANT NUMBER := 43;    -- Components put into INV
  SCRASSY_TYPE CONSTANT NUMBER := 90;    -- Assembly scrap
  RETSCRA_TYPE CONSTANT NUMBER := 91;    -- Return from scrap
  CPLASSY_TYPE CONSTANT NUMBER := 44;    -- Assemblies put into INV
  RETASSY_TYPE CONSTANT NUMBER := 17;    -- Assemblies taken out of INV
  ISSNEGC_TYPE CONSTANT NUMBER := 38;    -- Negative component issue
  RETNEGC_TYPE CONSTANT NUMBER := 48;    -- Negative component return

  -- Overcompletion Tolerance Types
  PERCENT       CONSTANT NUMBER := 1;   -- Tolerance expressed as a percent
  AMOUNT        CONSTANT NUMBER := 2;   -- Tolerance expressed as a number
  INFINITY      CONSTANT NUMBER := -1;  -- Tolerance value = -1

  -- Overcompletion Transaction Types
  normal_txn    CONSTANT NUMBER := 1;
  child_txn     CONSTANT NUMBER := 2;
  parent_txn    CONSTANT NUMBER := 3;


  -- Finite Scheduling
  USE_FINITE_SCHEDULER     CONSTANT NUMBER := 1;
  USE_MATERIAL_CONSTRAINTS CONSTANT NUMBER := 1;
  WPS_BACKWARD_SCHEDULE    CONSTANT NUMBER := 1;
  WPS_FORWARD_SCHEDULE     CONSTANT NUMBER := 2;
  WPS_MIDPOINT_SCHEDULE    CONSTANT NUMBER := 3;

  -- Eam Item Types
  ASSET_GROUP_TYPE    CONSTANT NUMBER := 1;
  ASSET_ACTIVITY_TYPE CONSTANT NUMBER := 2;
  REBUILD_ITEM_TYPE   CONSTANT NUMBER := 3;

  -- Bom Item Types
  MODEL_TYPE           CONSTANT NUMBER := 1;
  OPTION_CLASS_TYPE    CONSTANT NUMBER := 2;
  PLANNING_TYPE        CONSTANT NUMBER := 3;
  STANDARD_TYPE        CONSTANT NUMBER := 4;
  PLANNING_FAMILY_TYPE CONSTANT NUMBER := 5;

  -- Priority
  DEFAULT_PRIORITY    CONSTANT NUMBER := 10;

  --MSI Revision Control Code
  REVISION_CONTROLLED CONSTANT NUMBER := 2;

  --MSI Pegging Constants
  PEG_SOFT CONSTANT VARCHAR2(1) := 'A';
  PEG_END_ASSM_SOFT CONSTANT VARCHAR2(1) := 'B';
  PEG_HARD CONSTANT VARCHAR2(1) := 'I';
  PEG_END_ASSM_HARD CONSTANT VARCHAR2(1) := 'X';
  PEG_END_ASSM CONSTANT VARCHAR2(1) := 'Y';
  PEG_NONE CONSTANT VARCHAR2(1) := 'N';

  --Loggging constants. They are associated with the
  --'FND: Debug Log Level' profile
  NO_LOGGING    CONSTANT NUMBER := fnd_log.level_unexpected + 1;
  TRACE_LOGGING CONSTANT NUMBER := fnd_log.level_procedure;
  FULL_LOGGING  CONSTANT NUMBER := fnd_log.level_statement;

  --transaction_batch_seq values
  ASSY_BATCH_SEQ      CONSTANT NUMBER := 1;
  COMPONENT_BATCH_SEQ CONSTANT NUMBER := 2;

  --table names
  MTI_TBL  CONSTANT VARCHAR2(3) := 'MTI';
  MMTT_TBL CONSTANT VARCHAR2(4) := 'MMTT';

  --patchset level
  DMF_PATCHSET_LEVEL CONSTANT NUMBER := 115.10;
  DMF_PATCHSET_I_VALUE CONSTANT NUMBER := 115.09;
  DMF_PATCHSET_J_VALUE CONSTANT NUMBER := 115.10;

  -- Date Formats
  -- Note:  We need these hard-coded.  They are not to be used to support
  --        flexible
  --        date formats.  They are needed to support the fact that Forms 4.5
  --        automatically uses DD-MON-YYYY when doing name_in and copy.
  --        Use routines in the WIP_DATETIMES package for flexible date formats
  -- DATETIME_FMT   CONSTANT VARCHAR2(22) := 'DD-MON-YYYY HH24:MI:SS';
  -- DATE_FMT       CONSTANT VARCHAR2(11) := 'DD-MON-YYYY';
  -- DATETRUNC_FMT  CONSTANT VARCHAR2(9)  := 'DD-MON-YY';
  -- TIME_FMT    CONSTANT VARCHAR2(7)  := 'HH24:MI';
  -- TIMESEC_FMT    CONSTANT VARCHAR2(10) := 'HH24:MI:SS';
  -- C_DATETIME_FMT CONSTANT VARCHAR2(17) := 'DD-MON-RR HH24:MI';
  -- C_DATE_FMT     CONSTANT VARCHAR2(9)  := 'DD-MON-RR';
  DATETIME_FMT   CONSTANT VARCHAR2(22) := 'YYYY/MM/DD HH24:MI:SS';
  DATE_FMT       CONSTANT VARCHAR2(11) := 'YYYY/MM/DD';
  TIME_FMT       CONSTANT VARCHAR2(7)  := 'HH24:MI';
  TIMESEC_FMT    CONSTANT VARCHAR2(10) := 'HH24:MI:SS';
  DT_NOSEC_FMT   CONSTANT VARCHAR2(22) := 'YYYY/MM/DD HH24:MI';

  -----------------------
  -- Column Lengths
  -----------------------
  TABLE_NAME_LEN  CONSTANT NUMBER :=  31;  -- Table name
  COLUMN_NAME_LEN CONSTANT NUMBER :=  31;  -- Column name
  DATE_LEN        CONSTANT NUMBER :=  10;  -- Date
  DATETIME_LEN    CONSTANT NUMBER :=  19;  -- Date and time
  TIME_LEN        CONSTANT NUMBER :=   8;  -- Time (24-hour clock)
  DEPT_LEN        CONSTANT NUMBER :=  11;  -- Department
  REV_LEN         CONSTANT NUMBER :=   4;  -- Revision
  LOT_LEN         CONSTANT NUMBER :=  31;  -- Lot number
  SN_LEN          CONSTANT NUMBER :=  31;  -- Serial number
  PREFIX_LEN      CONSTANT NUMBER :=  31;  -- Lot/SN alpha prefix
  DESC_LEN        CONSTANT NUMBER := 241;  -- Descriptive Text
  SDESC_LEN       CONSTANT NUMBER :=  51;  -- Shorter Description
  CLASS_LEN       CONSTANT NUMBER :=  11;  -- Class Code
  DESIG_LEN       CONSTANT NUMBER :=  11;  -- Bom or Routing Designator
  SUBINV_LEN      CONSTANT NUMBER :=  11;  -- Subinventory
  ATT_CAT_LEN     CONSTANT NUMBER :=  31;  -- Attribute Category
  ATT_LEN         CONSTANT NUMBER := 151;  -- Attribute
  FLAG_LEN        CONSTANT NUMBER :=   2;  -- Flag
  SEGMENT_LEN     CONSTANT NUMBER :=  16;  -- Segment
  COMMENT_LEN     CONSTANT NUMBER :=  11;  -- Job Comment Code
  OP_LEN          CONSTANT NUMBER :=   5;  -- Operation Code
  RES_LEN         CONSTANT NUMBER :=  11;  -- Resource Code
  LINE_LEN        CONSTANT NUMBER :=  11;  -- Line Code
  UOM_LEN         CONSTANT NUMBER :=   4;  -- Unit Of Measure Code
  UOMCLASS_LEN    CONSTANT NUMBER :=  11;  -- Unit Of Measure Class
  OVH_LEN         CONSTANT NUMBER :=  11;  -- Overhead Code
  SF_STATUS_LEN   CONSTANT NUMBER :=  11;  -- Shop Floor Status Code
  ACT_LEN         CONSTANT NUMBER :=  11;  -- Activity name
  REASON_LEN      CONSTANT NUMBER :=  31;  -- Reason name
  SRC_LEN         CONSTANT NUMBER :=  31;  -- Source code
  ORG_LEN         CONSTANT NUMBER :=   4;  -- Organization code
  CAL_LEN         CONSTANT NUMBER :=  11;  -- Calendar codes
  CONCSEG_LEN     CONSTANT NUMBER := 241;  -- Concatenated segments
  JOB_LEN         CONSTANT NUMBER := 241;  -- Job name length
  FLAG_LEN        CONSTANT NUMBER :=   2;  -- Flags
  PROFILE_LEN     CONSTANT NUMBER := 241;  -- Profile
  ROWID_LEN       CONSTANT NUMBER :=  31;  -- Rowid
  SOURCE_CODE_LEN CONSTANT NUMBER :=  31;  -- Source code
  ALT_LEN         CONSTANT NUMBER :=  11;  -- Alternate designator
  ERR_CODE_LEN    CONSTANT NUMBER := 241;  -- Error code length
  ERR_LEN         CONSTANT NUMBER := 241;  -- Error length
  ORDLINE_LEN     CONSTANT NUMBER :=  31;  -- Sales Order Line
  ORDDEL_LEN      CONSTANT NUMBER :=  31;  -- Sales Order Delivery

/*=====================================================================+
 | PROCEDURE
 |   GET_ORA_ERROR
 |
 | PURPOSE
 |   Get the values of SQLCODE and SQLERRM and places a message on the
 |   message stack upon error
 |
 | ARGUMENTS
 |   IN
 |     application          Name of application; e.g. WIP, INV
 |     proc_name            Name of procedure or function where error occurred
 |
 | EXCEPTIONS
 |   Sets generic SQL error message and then calls FND_MESSAGE.ERROR to raise
 |   an exception.
 |
 | NOTES
 |
 +=====================================================================*/
  procedure get_ora_error (application VARCHAR2, proc_name VARCHAR2);

/*=====================================================================+
 | PROCEDURE
 |   INITIALIZE
 |
 | PURPOSE
 |   To instantiate the WIP_CONSTANTS package.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |   This procedure simply returns upon being called.  This is to initialize
 |   all the constants in this package.
 |
 +=====================================================================*/
  procedure initialize;

  --define the records locked exception
  RECORDS_LOCKED  EXCEPTION;
  PRAGMA EXCEPTION_INIT (RECORDS_LOCKED, -0054);

END WIP_CONSTANTS;

 

/
