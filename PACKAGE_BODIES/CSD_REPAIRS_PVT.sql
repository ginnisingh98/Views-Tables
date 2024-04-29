--------------------------------------------------------
--  DDL for Package Body CSD_REPAIRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIRS_PVT" AS
/* $Header: csdvdrab.pls 120.25.12010000.9 2010/06/09 18:24:27 nnadig ship $ */
--
-- Package name     : CSD_REPAIRS_PVT
-- Purpose          : This package contains the private APIs for creating,
--                    updating, deleting repair orders. Access is
--                    restricted to Oracle Depot Rapair Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         11/17/99   pkdas       Created.
-- 115.1         12/20/99   pkdas
-- 115.2         01/04/00   pkdas
-- 115.3         01/18/00   pkdas
-- 115.4         02/14/00   pkdas       Added p_REPAIR_LINE_ID as IN parameter in the Create_Repairs
--                                      procedure.
--                                      Added p_REPAIR_NUMBER as OUT parameter in the Create_Repairs
--                                      procedure.
--                                      Added validation logic.
-- 115.5         02/29/00   pkdas       Changed the procedure name
--                                      Create_Repairs -> Create_Repair_Order
--                                      Update_Repairs -> Update_Repair_Order
-- 115.6         04/26/00   pkdas       Modified some validation logic.
-- 115.7         05/10/00   pkdas       Removed defaulting received quantity.
-- 115.8         06/22/00   pkdas       In the Validate_Customer_Product_ID procedure
--                                      added a check to see whether ORG_ID is null
--                                      or not.
--
-- 115.12         07/25/01   jkuruvil    Commented out sr.org_id for Bug#1847161,1903177
--
-- 115.13       11/30/01   travi       Added AUTO_PROCESS_RMA, OBJECT_VERSION_NUMBER and REPAIR_MODE Col.
--                                     Added Logic to implement the Object_Version_Number
-- 115.14       01/14/02   travi       Added Item_REVISION Col.
-- 115.17       05/02/02   askumar     Added Validate_RO_GROUP_ID for 11.5.7.1
--                                     development
-- 115.27       23/01/03   saupadhy    Commmented proc Validate_Quantity_in_WIP
-- NOTE             :
--
--              09/01/04   saupadhy    made changes to Validate_repair procedure to not to
--                                     validate ib_ref_number when repair type is refurbished.
-- 115.45      05/19/05    vparvath    Adding update_ro_Status API for R12 development.
-- 			08/15/06	  rfieldma    Adding new error messages for update repair type and update repair status.
--                                     procedures update_repair_type, update_flow_status
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIRS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvdrab.pls';
g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;
--

G_USER_ID         NUMBER := Fnd_Global.USER_ID;
G_LOGIN_ID        NUMBER := Fnd_Global.CONC_LOGIN_ID;
G_REQUEST_ID      NUMBER := Fnd_Global.CONC_REQUEST_ID;
G_PROGRAM_ID      NUMBER := Fnd_Global.CONC_PROGRAM_ID;
G_PROG_APPL_ID    NUMBER := Fnd_Global.PROG_APPL_ID;
--
procedure debug(l_msg varchar2) is
--pragma autonomous_transaction;
begin
--dbms_output.put_line(msg);
--insert into apps.vijay_debug(log_msg,timestamp) values(l_msg, sysdate);
--commit;
null;
end;

PROCEDURE Create_Repair_Order(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID             IN   NUMBER       := Fnd_Api.G_MISS_NUM,
  P_REPLN_Rec                  IN   Csd_Repairs_Pub.REPLN_Rec_Type,
  X_REPAIR_LINE_ID             OUT NOCOPY  NUMBER,
  X_REPAIR_NUMBER              OUT NOCOPY  VARCHAR2,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  )
IS
--
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_Repair_Order';
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_rowid                   ROWID;
  l_repair_line_id          NUMBER;
  l_repair_number           VARCHAR2(30);
  -- Added following variables to fix bug 3435292 saupadhy
  l_Approval_required_flag  VARCHAR2(1) ;
  l_Auto_Process_RMA        VARCHAR2(1);
  l_Refurbish_Non_IO_Order  VARCHAR2(1);

  l_flow_status_id          NUMBER := NULL;
  l_flow_status_code        VARCHAR2(30) := NULL;
  l_flow_status             VARCHAR2(80) := NULL;
  l_status                  VARCHAR2(30) := NULL;
  l_date_closed             DATE;
  l_resolve_by_date         DATE; --rfieldma: 5355051
  l_business_process_id     NUMBER; -- rfieldma: 5355051
  l_severity_id             NUMBER; -- rfieldma: 5355051
  l_REPLN_Rec               Csd_Repairs_Pub.REPLN_Rec_Type; -- swai bug 7657379

-- bug#7043215, subhat
-- new DFF value rec.
  x_dff_value_rec           CSD_REPAIRS_UTIL.DEF_Rec_Type;
--
--
  CURSOR C1 IS
  SELECT CSD_REPAIRS_S1.NEXTVAL
  FROM sys.dual;
--
  CURSOR C2 IS
  SELECT CSD_REPAIRS_S2.NEXTVAL
  FROM sys.dual;
--
  CURSOR get_draft_status_details IS
  SELECT FS_B.flow_status_id,
         FS_B.flow_status_code,
         FS_LKUP.meaning flow_status,
         FS_B.status_code
  FROM   CSD_FLOW_STATUSES_B FS_B,
         FND_LOOKUPS FS_LKUP
  WHERE  FS_B.flow_status_code = 'D' AND
         FS_LKUP.lookup_type = 'CSD_REPAIR_FLOW_STATUS' AND
         FS_LKUP.lookup_code = FS_B.flow_status_code AND
         FS_LKUP.enabled_flag = 'Y' AND
         TRUNC(SYSDATE) BETWEEN
         TRUNC(NVL(FS_LKUP.start_date_active, SYSDATE)) AND
         TRUNC(NVL(FS_LKUP.end_date_active, SYSDATE));
--
  --rfieldma: 5355051
  CURSOR c_get_bus_proc_id(p_repair_type_id NUMBER) IS
    SELECT business_process_id
    FROM csd_repair_types_b b
    WHERE repair_type_id = p_repair_type_id;

  --rfieldma: 5355051
  CURSOR c_get_severity_id (p_incident_id NUMBER) IS
    SELECT incident_severity_id
    FROM csd_incidents_v a
    WHERE incident_id = p_incident_id;

BEGIN

-- Standard Start of API savepoint
  SAVEPOINT CREATE_REPAIR_ORDER_PVT;
-- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
           (l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- swai: bug 7657379
  -- move msg initialization further up, since call to DEFAULT_RO_ATTRS_FROM_RULE
  -- may add additional messages to the stack.
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- swai: bug 7657379
  -- Default fields in repln_rec from defauling rules before
  -- checking required params.
  l_REPLN_Rec := p_REPLN_Rec;
  Csd_Repairs_Util.DEFAULT_RO_ATTRS_FROM_RULE
  (               p_api_version    => 1.0,
                  p_commit         => fnd_api.g_false,
                  p_init_msg_list  => fnd_api.g_false,
                  px_repln_rec     => l_REPLN_Rec,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
  -- end swai: bug 7657379
  -- Note: From this point on, P_REPLN_REC has been replaced with l_REPLN_Rec

--
-- Check for required parameters
  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.incident_id,
   p_param_name  => 'P_REPLN_REC.INCIDENT_ID',
   p_api_name    => l_api_name
  );
  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.inventory_item_id,
   p_param_name  => 'P_REPLN_REC.INVENTORY_ITEM_ID',
   p_api_name    => l_api_name
  );

  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.unit_of_measure,
   p_param_name  => 'P_REPLN_REC.UNIT_OF_MEASURE',
   p_api_name    => l_api_name
  );
  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.quantity,
   p_param_name  => 'P_REPLN_REC.QUANTITY',
   p_api_name    => l_api_name
  );

  /* R12 Flex Flow change, vkjain.
  -- Status is no longer mandatory.
  -- One can either pass flow_status_id
  -- or just status.
  CSD_REPAIRS_UTIL.check_reqd_param
  (p_param_value => l_REPLN_Rec.status,
   p_param_name  => 'P_REPLN_REC.STATUS',
   p_api_name    => l_api_name
  );
  */

  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.currency_code,
   p_param_name  => 'P_REPLN_REC.CURRENCY_CODE',
   p_api_name    => l_api_name
  );

  -- Need to check if the status_reason_code is to be validated.

  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.approval_required_flag,
   p_param_name  => 'P_REPLN_REC.APPROVAL_REQUIRED_FLAG',
   p_api_name    => l_api_name
  );
  Csd_Repairs_Util.check_reqd_param
  (p_param_value => l_REPLN_Rec.repair_type_id,
   p_param_name  => 'P_REPLN_REC.REPAIR_TYPE_ID',
   p_api_name    => l_api_name
  );


-- API body

-- Validate Environment

  IF G_USER_ID IS NULL
  THEN
    IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
    THEN
      Fnd_Message.Set_Name('CSD', 'CSD_CANNOT_GET_PROFILE_VALUE');
      Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
      Fnd_Msg_Pub.ADD;
    END IF;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


-- Validate Repair Order Group id


-- Generate REPAIR_NUMBER

  IF l_REPLN_Rec.repair_number = Fnd_Api.G_MISS_CHAR
    OR l_REPLN_Rec.repair_number IS NULL THEN
    OPEN C2;
    FETCH C2 INTO l_REPAIR_NUMBER;
    CLOSE C2;
  ELSE
    l_repair_number := l_REPLN_Rec.repair_number;
  END IF;


--
-- Invoke validation procedures
-- added a new out parameter which is of type CSD_REPAIRS_UTIL.DEF_Rec_Type
-- this collection holds the validated/derived DFF values (only in create mode)
-- subhat, FP bug#7242791
--
    Validate_Repairs
    (
     P_Api_Version_Number => 1.0,
     p_validation_mode    => Jtf_Plsql_Api.G_CREATE,
     p_repair_line_id     => p_repair_line_id,
     P_REPLN_Rec          => l_REPLN_Rec,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data,
     --bug#7043215 subhat
     x_dff_rec            => x_dff_value_rec
    );

-- Check return status from the above procedure call
  IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
    ROLLBACK TO CREATE_REPAIR_ORDER_PVT;
    RETURN;
  END IF;

  -- Added for R12 Flex Flow, vkjain.

  -- The status will always be derived from the RT,
  -- with one exception when we want to create an RO
  -- in 'draft' status.
  IF (l_REPLN_Rec.flow_status_code = 'D' OR
      l_REPLN_Rec.status = 'D') THEN
     -- Get the corresponding information for the 'Draft' status.
     OPEN get_draft_status_details;
     FETCH get_draft_status_details INTO
                              l_flow_status_id,
                              l_flow_status_code,
                              l_flow_status,
                              l_status;

     CLOSE get_draft_status_details;

     IF l_flow_status_id IS NULL THEN
        -- Repair Order creation failed.
        -- Unable to get the draft status details.
        Fnd_Message.SET_NAME('CSD','CSD_RO_NO_DRAFT_STATUS_DTLS');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

  ELSE
     -- Get the start flow status from repair type
     Csd_Repair_Types_Pvt.get_start_flow_status(x_return_status => x_return_status,
                                                x_msg_count => x_msg_count,
                                                x_msg_data => x_msg_data,
                                                p_repair_type_id => l_REPLN_Rec.repair_type_id,
                                                x_start_flow_status_id => l_flow_status_id,
                                                x_start_flow_status_code => l_flow_status_code,
                                                x_start_flow_status_meaning => l_flow_status,
                                                x_status_code => l_status
                                                );
     IF x_return_status <> 'S' THEN
        -- Unexpected error. Raise an exception.
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  -- For R12 Flex Flow, date closed is set to a value
  -- if the Ro is created in Closed State. vkjain.
  IF l_status = 'C' THEN
     l_date_closed := SYSDATE;
  ELSE
     l_date_closed := l_REPLN_Rec.DATE_CLOSED;
  END IF;


-- Generate REPAIR_LINE_ID

  IF p_repair_line_id = Fnd_Api.G_MISS_NUM
    OR p_repair_line_id IS NULL THEN
    OPEN C1;
    FETCH C1 INTO l_REPAIR_LINE_ID;
    CLOSE C1;
  ELSE
    l_repair_line_id := p_repair_line_id;
  END IF;


  -- Check if Repair Type is Refurbish non IO
  -- This is to fix bug 3435292 saupadhy
  BEGIN
      SELECT 'Y'
    INTO l_Refurbish_Non_IO_Order
    FROM Csd_Repair_types_b
    WHERE Repair_type_id = l_REPLN_Rec.Repair_type_Id
    AND  repair_type_Ref = 'RF'
    AND  NVL(internal_order_flag,'N') = 'N' ;
      l_Approval_required_flag := 'N' ;
      l_Auto_Process_RMA := 'N';
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_Approval_required_flag := l_REPLN_Rec.Approval_required_flag ;
        l_Auto_Process_RMA := l_REPLN_Rec.Auto_Process_RMA;
        l_Refurbish_Non_IO_Order := 'N' ;
  END;

  -- rfieldma: 5355051
  -- Default Resolve By date if there is a contract and
  -- user want it to be derived
  -- if resolve_by_date = null => don't default
  -- if resolve_by_date = fnd_api.G_Miss_date => default
  -- else, (resolve_by_date is passed in) => use the passed in value

  l_resolve_by_date := l_REPLN_Rec.resolve_by_date;

  IF (l_resolve_by_date = FND_API.G_MISS_DATE) THEN
    -- only default if there is a default contract
    IF (    l_REPLN_Rec.contract_line_id IS NOT NULL
        AND l_REPLN_Rec.contract_line_id <> Fnd_Api.G_MISS_NUM) THEN
      -- get business process id
      OPEN c_get_bus_proc_id(l_REPLN_Rec.repair_type_id);
      FETCH c_get_bus_proc_id
         INTO l_business_process_id;
      CLOSE c_get_bus_proc_id;

      -- get severity id
      OPEN c_get_severity_id(l_REPLN_Rec.incident_id);
      FETCH c_get_severity_id
         INTO l_severity_id;
      CLOSE c_get_severity_id;

	 -- get resolve by date
	 csd_repairs_util.get_contract_resolve_by_date(
                         p_contract_line_id => l_REPLN_Rec.contract_line_id,
                         p_bus_proc_id      => l_business_process_id,
                         p_severity_id      => l_severity_id,
                         p_request_date     => sysdate,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         x_resolve_by_date  => l_resolve_by_date);

	 IF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
        RAISE Fnd_Api.G_EXC_ERROR ;
      ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
      END IF; -- end exception handling

    END IF; -- end contract line id is not null and not g_miss_num
  END IF; -- end resolve by date = g_miss_date

--
-- Invoke table handler(CSD_REPAIRS_PKG.Insert_Row)
--
  Csd_Repairs_Pkg.Insert_Row(
  px_REPAIR_LINE_ID  => l_REPAIR_LINE_ID,
  p_REQUEST_ID  => G_REQUEST_ID,
  p_PROGRAM_ID  => G_PROGRAM_ID,
  p_PROGRAM_APPLICATION_ID  => G_PROG_APPL_ID,
  p_PROGRAM_UPDATE_DATE  => SYSDATE,
  p_CREATED_BY  => G_USER_ID,
  p_CREATION_DATE  => SYSDATE,
  p_LAST_UPDATED_BY  => G_USER_ID,
  p_LAST_UPDATE_DATE  => SYSDATE,
  p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
  p_REPAIR_NUMBER  => l_REPAIR_NUMBER,
  p_INCIDENT_ID  => l_REPLN_Rec.INCIDENT_ID,
  p_INVENTORY_ITEM_ID  => l_REPLN_Rec.INVENTORY_ITEM_ID,
  p_CUSTOMER_PRODUCT_ID  => l_REPLN_Rec.CUSTOMER_PRODUCT_ID,
  p_UNIT_OF_MEASURE  => l_REPLN_Rec.UNIT_OF_MEASURE,
  p_REPAIR_TYPE_ID  => l_REPLN_Rec.REPAIR_TYPE_ID,
  p_RESOURCE_GROUP  => l_REPLN_Rec.RESOURCE_GROUP,
  p_RESOURCE_ID  => l_REPLN_Rec.RESOURCE_ID,
  p_INSTANCE_ID  => l_REPLN_Rec.INSTANCE_ID,
  p_PROJECT_ID  => l_REPLN_Rec.PROJECT_ID,
  p_TASK_ID  => l_REPLN_Rec.TASK_ID,
  p_UNIT_NUMBER => l_REPLN_Rec.UNIT_NUMBER, -- rfieldma, project integration
  p_CONTRACT_LINE_ID  => l_REPLN_Rec.CONTRACT_LINE_ID,
  p_QUANTITY  => l_REPLN_Rec.QUANTITY,
  -- p_STATUS  => l_REPLN_Rec.STATUS,
  p_STATUS  => l_status,  -- Modifed for R12 Flex Flow
  p_APPROVAL_REQUIRED_FLAG  => l_Approval_Required_Flag,
  p_DATE_CLOSED  => l_date_closed,
  p_QUANTITY_IN_WIP  => l_REPLN_Rec.QUANTITY_IN_WIP,
  p_APPROVAL_STATUS         => l_REPLN_Rec.APPROVAL_STATUS,
  p_QUANTITY_RCVD  => l_REPLN_Rec.QUANTITY_RCVD,
  p_QUANTITY_SHIPPED  => l_REPLN_Rec.QUANTITY_SHIPPED,
  p_CURRENCY_CODE  => l_REPLN_Rec.CURRENCY_CODE,
  p_DEFAULT_PO_NUM  => l_REPLN_Rec.DEFAULT_PO_NUM,
  p_SERIAL_NUMBER           => l_REPLN_Rec.SERIAL_NUMBER,
  p_PROMISE_DATE            => l_REPLN_Rec.PROMISE_DATE,
-- subhat, bug#7242791
  p_ATTRIBUTE_CATEGORY  => x_dff_value_rec.ATTRIBUTE_CATEGORY, --p_REPLN_rec.ATTRIBUTE_CATEGORY,
  p_ATTRIBUTE1  => x_dff_value_rec.ATTRIBUTE1, --p_REPLN_rec.ATTRIBUTE1,
  p_ATTRIBUTE2  => x_dff_value_rec.ATTRIBUTE2,--p_REPLN_rec.ATTRIBUTE2,
  p_ATTRIBUTE3  => x_dff_value_rec.ATTRIBUTE3,--p_REPLN_rec.ATTRIBUTE3,
  p_ATTRIBUTE4  => x_dff_value_rec.ATTRIBUTE4,--p_REPLN_rec.ATTRIBUTE4,
  p_ATTRIBUTE5  => x_dff_value_rec.ATTRIBUTE5,--p_REPLN_rec.ATTRIBUTE5,
  p_ATTRIBUTE6  => x_dff_value_rec.ATTRIBUTE6,--p_REPLN_rec.ATTRIBUTE6,
  p_ATTRIBUTE7  => x_dff_value_rec.ATTRIBUTE7,--p_REPLN_rec.ATTRIBUTE7,
  p_ATTRIBUTE8  => x_dff_value_rec.ATTRIBUTE8,--p_REPLN_rec.ATTRIBUTE8,
  p_ATTRIBUTE9  => x_dff_value_rec.ATTRIBUTE9,--p_REPLN_rec.ATTRIBUTE9,
  p_ATTRIBUTE10 => x_dff_value_rec.ATTRIBUTE10,--p_REPLN_rec.ATTRIBUTE10,
  p_ATTRIBUTE11 => x_dff_value_rec.ATTRIBUTE11,--p_REPLN_rec.ATTRIBUTE11,
  p_ATTRIBUTE12 => x_dff_value_rec.ATTRIBUTE12,--p_REPLN_rec.ATTRIBUTE12,
  p_ATTRIBUTE13 => x_dff_value_rec.ATTRIBUTE13,--p_REPLN_rec.ATTRIBUTE13,
  p_ATTRIBUTE14 => x_dff_value_rec.ATTRIBUTE14,--p_REPLN_rec.ATTRIBUTE14,
  p_ATTRIBUTE15 => x_dff_value_rec.ATTRIBUTE15,--p_REPLN_rec.ATTRIBUTE15,
  -- end bug#7242791, subhat.
  --bug#7497907, 12.1 FP, subhat
  p_ATTRIBUTE16 => x_dff_value_rec.ATTRIBUTE16,
  p_ATTRIBUTE17 => x_dff_value_rec.ATTRIBUTE17,
  p_ATTRIBUTE18 => x_dff_value_rec.ATTRIBUTE18,
  p_ATTRIBUTE19 => x_dff_value_rec.ATTRIBUTE19,
  p_ATTRIBUTE20 => x_dff_value_rec.ATTRIBUTE20,
  p_ATTRIBUTE21 => x_dff_value_rec.ATTRIBUTE21,
  p_ATTRIBUTE22 => x_dff_value_rec.ATTRIBUTE22,
  p_ATTRIBUTE23 => x_dff_value_rec.ATTRIBUTE23,
  p_ATTRIBUTE24 => x_dff_value_rec.ATTRIBUTE24,
  p_ATTRIBUTE25 => x_dff_value_rec.ATTRIBUTE25,
  p_ATTRIBUTE26 => x_dff_value_rec.ATTRIBUTE26,
  p_ATTRIBUTE27 => x_dff_value_rec.ATTRIBUTE27,
  p_ATTRIBUTE28 => x_dff_value_rec.ATTRIBUTE28,
  p_ATTRIBUTE29 => x_dff_value_rec.ATTRIBUTE29,
  p_ATTRIBUTE30 => x_dff_value_rec.ATTRIBUTE30,
  p_ORDER_LINE_ID  => l_REPLN_Rec.ORDER_LINE_ID,
  p_ORIGINAL_SOURCE_REFERENCE  => l_REPLN_Rec.ORIGINAL_SOURCE_REFERENCE,
  p_STATUS_REASON_CODE => l_REPLN_Rec.STATUS_REASON_CODE,
  p_OBJECT_VERSION_NUMBER  => 1, -- travi l_REPLN_Rec.OBJECT_VERSION_NUMBER,
  p_AUTO_PROCESS_RMA => l_Auto_Process_RMA,
  p_REPAIR_MODE => l_REPLN_Rec.REPAIR_MODE,
  p_ITEM_REVISION => l_REPLN_Rec.ITEM_REVISION,
  p_REPAIR_GROUP_ID => l_REPLN_Rec.REPAIR_GROUP_ID,
  p_RO_TXN_STATUS => l_REPLN_Rec.RO_TXN_STATUS,
  p_ORIGINAL_SOURCE_HEADER_ID  => l_REPLN_Rec.ORIGINAL_SOURCE_HEADER_ID,
  p_ORIGINAL_SOURCE_LINE_ID    => l_REPLN_Rec.ORIGINAL_SOURCE_LINE_ID,
  p_PRICE_LIST_HEADER_ID       => l_REPLN_Rec.PRICE_LIST_HEADER_ID,
  p_Supercession_Inv_Item_Id   => l_REPLN_Rec.Supercession_Inv_Item_Id,
  p_flow_status_Id     => l_flow_status_Id,
  p_Inventory_Org_Id   => l_REPLN_Rec.Inventory_Org_Id,
  p_PROBLEM_DESCRIPTION  => l_REPLN_Rec.PROBLEM_DESCRIPTION, -- swai: bug 4666344
  p_RO_PRIORITY_CODE     => l_REPLN_Rec.RO_PRIORITY_CODE,     -- swai: R12
  p_RESOLVE_BY_DATE      => l_resolve_by_date,      -- rfieldma: 5355051
  p_BULLETIN_CHECK_DATE  => l_REPLN_Rec.BULLETIN_CHECK_DATE,
  p_ESCALATION_CODE      => l_REPLN_Rec.ESCALATION_CODE,
  p_RO_WARRANTY_STATUS_CODE  => l_REPLN_Rec.RO_WARRANTY_STATUS_CODE,
  p_REPAIR_YIELD_QUANTITY   => l_REPLN_Rec.REPAIR_YIELD_QUANTITY   --bug#6692459
  );

  x_REPAIR_LINE_ID := l_REPAIR_LINE_ID;
  x_REPAIR_NUMBER := l_REPAIR_NUMBER;
--
-- End of API body
--
-- Standard check for p_commit
  IF Fnd_Api.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;
-- Standard call to get message count and if count is 1, get message info.
  Fnd_Msg_Pub.Count_And_Get
  (p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
  );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
    ( P_API_NAME => L_API_NAME
     ,P_PKG_NAME => G_PKG_NAME
     ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
     ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
     ,X_MSG_COUNT => X_MSG_COUNT
     ,X_MSG_DATA => X_MSG_DATA
     ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_REPAIR_ORDER_PVT;
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Jtf_Plsql_Api.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Repair_Order;

PROCEDURE Update_Repair_Order(
  P_Api_Version_Number     IN       NUMBER,
  P_Init_Msg_List          IN       VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                 IN       VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level       IN       NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID         IN       NUMBER,
  P_REPLN_Rec              IN OUT NOCOPY   Csd_Repairs_Pub.REPLN_Rec_Type,
  X_Return_Status          OUT NOCOPY      VARCHAR2,
  X_Msg_Count              OUT NOCOPY      NUMBER,
  X_Msg_Data               OUT NOCOPY      VARCHAR2
  )
IS

  CURSOR C_Get_repairs(p_REPAIR_LINE_ID    NUMBER) IS
  SELECT ROWID,
         REPAIR_LINE_ID,
         REPAIR_NUMBER,
         INCIDENT_ID,
         INVENTORY_ITEM_ID,
         CUSTOMER_PRODUCT_ID,
         UNIT_OF_MEASURE,
         REPAIR_TYPE_ID,
         OWNING_ORGANIZATION_ID,
         RESOURCE_ID,
         PROJECT_ID,
         TASK_ID,
         UNIT_NUMBER, -- rfieldma, prj integration
         CONTRACT_LINE_ID,
         AUTO_PROCESS_RMA,
         REPAIR_MODE,
         OBJECT_VERSION_NUMBER,
         ITEM_REVISION,
         INSTANCE_ID,
         STATUS,
         STATUS_REASON_CODE,
         DATE_CLOSED,
         APPROVAL_REQUIRED_FLAG,
         APPROVAL_STATUS,
         SERIAL_NUMBER,
         PROMISE_DATE,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         QUANTITY,
         QUANTITY_IN_WIP,
         QUANTITY_RCVD,
         QUANTITY_SHIPPED
        -- bug#7497907, 12.1 FP, subhat
         ,ATTRIBUTE16
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE20
         ,ATTRIBUTE21
         ,ATTRIBUTE22
         ,ATTRIBUTE23
         ,ATTRIBUTE24
         ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
  FROM  CSD_REPAIRS
  WHERE REPAIR_LINE_ID = p_REPAIR_LINE_ID
   FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  l_api_name                CONSTANT VARCHAR2(30) := 'Update_Repair_Order';
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_OLD_REPLN_rec           Csd_Repairs_Pub.REPLN_Rec_Type;
  l_NEW_REPLN_rec           Csd_Repairs_Pub.REPLN_Rec_Type := P_REPLN_Rec;
  l_rowid                   ROWID;
  l_repair_line_id          NUMBER;
  l_OBJECT_VERSION_NUMBER   NUMBER;

-- bug#7242791, 12.1 FP, subhat
-- new out parameter for validate_repairs API.
  x_dff_value_rec           csd_repairs_util.def_rec_type;

BEGIN

-- Standard Start of API savepoint
  SAVEPOINT UPDATE_REPAIR_ORDER_PVT;
-- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
         (l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- Check for required parameters
  Csd_Repairs_Util.check_reqd_param
  (p_param_value => p_repair_line_id,
   p_param_name  => 'P_REPAIR_LINE_ID',
   p_api_name    => l_api_name
  );

-- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
-- Initialize API return status to SUCCESS
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

-- Api body

-- Validate Environment

  IF G_USER_ID IS NULL
  THEN
    IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
    THEN
      Fnd_Message.Set_Name('CSD', 'CSD_CANNOT_GET_PROFILE_VALUE');
      Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
      Fnd_Msg_Pub.ADD;
    END IF;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  OPEN C_Get_repairs(p_REPAIR_LINE_ID);
  FETCH C_Get_repairs INTO
    l_rowid,
    l_REPAIR_LINE_ID,
    l_OLD_REPLN_rec.REPAIR_NUMBER,
    l_OLD_REPLN_rec.INCIDENT_ID,
    l_OLD_REPLN_rec.INVENTORY_ITEM_ID,
    l_OLD_REPLN_rec.CUSTOMER_PRODUCT_ID,
    l_OLD_REPLN_rec.UNIT_OF_MEASURE,
    l_OLD_REPLN_rec.REPAIR_TYPE_ID,
    l_OLD_REPLN_rec.RESOURCE_GROUP,
    l_OLD_REPLN_rec.RESOURCE_ID,
    l_OLD_REPLN_rec.PROJECT_ID,
    l_OLD_REPLN_rec.TASK_ID,
    l_OLD_REPLN_rec.UNIT_NUMBER, -- rfieldma, project integration
    l_OLD_REPLN_rec.CONTRACT_LINE_ID,
    l_OLD_REPLN_rec.AUTO_PROCESS_RMA,
    l_OLD_REPLN_rec.REPAIR_MODE,
    l_OLD_REPLN_rec.OBJECT_VERSION_NUMBER,
    l_OLD_REPLN_rec.ITEM_REVISION,
    l_OLD_REPLN_rec.INSTANCE_ID,
    l_OLD_REPLN_rec.STATUS,
    l_OLD_REPLN_rec.STATUS_REASON_CODE,
    l_OLD_REPLN_rec.DATE_CLOSED,
    l_OLD_REPLN_rec.APPROVAL_REQUIRED_FLAG,
    l_OLD_REPLN_rec.APPROVAL_STATUS,
    l_OLD_REPLN_rec.SERIAL_NUMBER,
    l_OLD_REPLN_rec.PROMISE_DATE,
    l_OLD_REPLN_rec.ATTRIBUTE_CATEGORY,
    l_OLD_REPLN_rec.ATTRIBUTE1,
    l_OLD_REPLN_rec.ATTRIBUTE2,
    l_OLD_REPLN_rec.ATTRIBUTE3,
    l_OLD_REPLN_rec.ATTRIBUTE4,
    l_OLD_REPLN_rec.ATTRIBUTE5,
    l_OLD_REPLN_rec.ATTRIBUTE6,
    l_OLD_REPLN_rec.ATTRIBUTE7,
    l_OLD_REPLN_rec.ATTRIBUTE8,
    l_OLD_REPLN_rec.ATTRIBUTE9,
    l_OLD_REPLN_rec.ATTRIBUTE10,
    l_OLD_REPLN_rec.ATTRIBUTE11,
    l_OLD_REPLN_rec.ATTRIBUTE12,
    l_OLD_REPLN_rec.ATTRIBUTE13,
    l_OLD_REPLN_rec.ATTRIBUTE14,
    l_OLD_REPLN_rec.ATTRIBUTE15,
    l_OLD_REPLN_rec.QUANTITY,
    l_OLD_REPLN_rec.QUANTITY_IN_WIP,
    l_OLD_REPLN_rec.QUANTITY_RCVD,
    l_OLD_REPLN_rec.QUANTITY_SHIPPED,
    -- bug#7497907, 12.1 FP, subhat
    l_OLD_REPLN_rec.ATTRIBUTE16,
    l_OLD_REPLN_rec.ATTRIBUTE17,
    l_OLD_REPLN_rec.ATTRIBUTE18,
    l_OLD_REPLN_rec.ATTRIBUTE19,
    l_OLD_REPLN_rec.ATTRIBUTE20,
    l_OLD_REPLN_rec.ATTRIBUTE21,
    l_OLD_REPLN_rec.ATTRIBUTE22,
    l_OLD_REPLN_rec.ATTRIBUTE23,
    l_OLD_REPLN_rec.ATTRIBUTE24,
    l_OLD_REPLN_rec.ATTRIBUTE25,
    l_OLD_REPLN_rec.ATTRIBUTE26,
    l_OLD_REPLN_rec.ATTRIBUTE27,
    l_OLD_REPLN_rec.ATTRIBUTE28,
    l_OLD_REPLN_rec.ATTRIBUTE29,
    l_OLD_REPLN_rec.ATTRIBUTE30
    ;

  IF (C_Get_repairs%NOTFOUND) THEN
    IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_API_MISSING_UPDATE_TARGET');
      Fnd_Message.Set_Token ('INFO', 'Repairs', FALSE);
      Fnd_Msg_Pub.ADD;
    END IF;
    CLOSE C_Get_repairs;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
  CLOSE C_Get_repairs;

/*
  if l_OLD_REPLN_Rec.status = 'C' then
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CSD', 'CSD_RO_CLOSED');
      FND_MESSAGE.Set_Token ('REP_NUM', l_OLD_REPLN_Rec.repair_number);
      FND_MSG_PUB.Add;
    END IF;
    raise FND_API.G_EXC_ERROR;
  end if;
*/

-- Invoke validation procedures
-- bug#7242791, 12.1 FP, subhat
-- new out DFF rec is added. Currently this rec will not be used in
-- update API.

    Validate_Repairs
    (
     P_Api_Version_Number => 1.0,
     p_validation_mode    => Jtf_Plsql_Api.G_UPDATE,
     p_repair_line_id     => p_repair_line_id,
     P_REPLN_Rec          => P_REPLN_Rec,
     P_OLD_REPLN_Rec      => l_OLD_REPLN_Rec,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data,
     x_dff_rec            => x_dff_value_rec
    );
--
-- Check return status from the above procedure call
  IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
    ROLLBACK TO UPDATE_REPAIR_ORDER_PVT;
    RETURN;
  END IF;

  l_OBJECT_VERSION_NUMBER  := p_REPLN_rec.OBJECT_VERSION_NUMBER + 1;

--
-- Invoke table handler(CSD_REPAIRS_PKG.Update_Row)
--
--
  Csd_Repairs_Pkg.Update_Row(
  p_REPAIR_LINE_ID  => p_REPAIR_LINE_ID,
  p_REQUEST_ID  => G_REQUEST_ID,
  p_PROGRAM_ID  => G_PROGRAM_ID,
  p_PROGRAM_APPLICATION_ID  => G_PROG_APPL_ID,
  p_PROGRAM_UPDATE_DATE  => SYSDATE,
  p_CREATED_BY  => G_USER_ID,
  p_CREATION_DATE  => Fnd_Api.G_MISS_DATE, -- swai ADS bug 3063922, changed from sysdate
  p_LAST_UPDATED_BY  => G_USER_ID,
  p_LAST_UPDATE_DATE  => SYSDATE,
  p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
  p_REPAIR_NUMBER  => p_REPLN_rec.REPAIR_NUMBER,
  p_INCIDENT_ID  => p_REPLN_rec.INCIDENT_ID,
  p_INVENTORY_ITEM_ID  => p_REPLN_rec.INVENTORY_ITEM_ID,
  p_CUSTOMER_PRODUCT_ID  => p_REPLN_rec.CUSTOMER_PRODUCT_ID,
  p_UNIT_OF_MEASURE  => p_REPLN_rec.UNIT_OF_MEASURE,
  p_REPAIR_TYPE_ID  => p_REPLN_rec.REPAIR_TYPE_ID,
  p_RESOURCE_GROUP  => p_REPLN_rec.RESOURCE_GROUP,
  p_RESOURCE_ID  => p_REPLN_rec.RESOURCE_ID,
  p_INSTANCE_ID  => p_REPLN_rec.INSTANCE_ID,
  p_PROJECT_ID  => p_REPLN_rec.PROJECT_ID,
  p_TASK_ID  => p_REPLN_rec.TASK_ID,
  p_UNIT_NUMBER  => p_REPLN_rec.UNIT_NUMBER, -- rfieldma, project integration
  p_CONTRACT_LINE_ID  => p_REPLN_rec.CONTRACT_LINE_ID,
  p_QUANTITY  => p_REPLN_rec.QUANTITY,
  p_STATUS  => p_REPLN_rec.STATUS,
  p_APPROVAL_REQUIRED_FLAG  => p_REPLN_rec.APPROVAL_REQUIRED_FLAG,
  p_DATE_CLOSED  => p_REPLN_rec.DATE_CLOSED,
  p_QUANTITY_IN_WIP  => p_REPLN_rec.QUANTITY_IN_WIP,
  p_APPROVAL_STATUS         => p_REPLN_rec.APPROVAL_STATUS,
  p_QUANTITY_RCVD  => p_REPLN_rec.QUANTITY_RCVD,
  p_QUANTITY_SHIPPED  => p_REPLN_rec.QUANTITY_SHIPPED,
  p_CURRENCY_CODE  => p_REPLN_rec.CURRENCY_CODE,
  p_DEFAULT_PO_NUM  => p_REPLN_rec.DEFAULT_PO_NUM,
  p_SERIAL_NUMBER           => p_REPLN_rec.SERIAL_NUMBER,
  p_PROMISE_DATE            => p_REPLN_rec.PROMISE_DATE,
  p_ATTRIBUTE_CATEGORY  => p_REPLN_rec.ATTRIBUTE_CATEGORY,
  p_ATTRIBUTE1  => p_REPLN_rec.ATTRIBUTE1,
  p_ATTRIBUTE2  => p_REPLN_rec.ATTRIBUTE2,
  p_ATTRIBUTE3  => p_REPLN_rec.ATTRIBUTE3,
  p_ATTRIBUTE4  => p_REPLN_rec.ATTRIBUTE4,
  p_ATTRIBUTE5  => p_REPLN_rec.ATTRIBUTE5,
  p_ATTRIBUTE6  => p_REPLN_rec.ATTRIBUTE6,
  p_ATTRIBUTE7  => p_REPLN_rec.ATTRIBUTE7,
  p_ATTRIBUTE8  => p_REPLN_rec.ATTRIBUTE8,
  p_ATTRIBUTE9  => p_REPLN_rec.ATTRIBUTE9,
  p_ATTRIBUTE10  => p_REPLN_rec.ATTRIBUTE10,
  p_ATTRIBUTE11  => p_REPLN_rec.ATTRIBUTE11,
  p_ATTRIBUTE12  => p_REPLN_rec.ATTRIBUTE12,
  p_ATTRIBUTE13  => p_REPLN_rec.ATTRIBUTE13,
  p_ATTRIBUTE14  => p_REPLN_rec.ATTRIBUTE14,
  p_ATTRIBUTE15  => p_REPLN_rec.ATTRIBUTE15,
  -- bug#7497907, 12.1 FP, subhat
  p_ATTRIBUTE16 => p_REPLN_rec.ATTRIBUTE16,
  p_ATTRIBUTE17 => p_REPLN_rec.ATTRIBUTE17,
  p_ATTRIBUTE18 => p_REPLN_rec.ATTRIBUTE18,
  p_ATTRIBUTE19 => p_REPLN_rec.ATTRIBUTE19,
  p_ATTRIBUTE20 => p_REPLN_rec.ATTRIBUTE20,
  p_ATTRIBUTE21 => p_REPLN_rec.ATTRIBUTE21,
  p_ATTRIBUTE22 => p_REPLN_rec.ATTRIBUTE22,
  p_ATTRIBUTE23 => p_REPLN_rec.ATTRIBUTE23,
  p_ATTRIBUTE24 => p_REPLN_rec.ATTRIBUTE24,
  p_ATTRIBUTE25 => p_REPLN_rec.ATTRIBUTE25,
  p_ATTRIBUTE26 => p_REPLN_rec.ATTRIBUTE26,
  p_ATTRIBUTE27 => p_REPLN_rec.ATTRIBUTE27,
  p_ATTRIBUTE28 => p_REPLN_rec.ATTRIBUTE28,
  p_ATTRIBUTE29 => p_REPLN_rec.ATTRIBUTE29,
  p_ATTRIBUTE30 => p_REPLN_rec.ATTRIBUTE30,
  p_ORDER_LINE_ID  => p_REPLN_rec.ORDER_LINE_ID,
  p_ORIGINAL_SOURCE_REFERENCE  => p_REPLN_rec.ORIGINAL_SOURCE_REFERENCE,
  p_STATUS_REASON_CODE => p_REPLN_rec.STATUS_REASON_CODE,
  p_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER,
  p_AUTO_PROCESS_RMA => p_REPLN_rec.AUTO_PROCESS_RMA,
  p_REPAIR_MODE => p_REPLN_rec.REPAIR_MODE,
  p_ITEM_REVISION => p_REPLN_rec.ITEM_REVISION,
  p_REPAIR_GROUP_ID => p_REPLN_rec.REPAIR_GROUP_ID,
  p_RO_TXN_STATUS => p_REPLN_rec.RO_TXN_STATUS,
  p_ORIGINAL_SOURCE_HEADER_ID  => p_REPLN_rec.ORIGINAL_SOURCE_HEADER_ID,
  p_ORIGINAL_SOURCE_LINE_ID    => p_REPLN_rec.ORIGINAL_SOURCE_LINE_ID,
  p_PRICE_LIST_HEADER_ID       => p_REPLN_rec.PRICE_LIST_HEADER_ID,
  p_PROBLEM_DESCRIPTION        => p_REPLN_rec.PROBLEM_DESCRIPTION, -- swai: bug 4666344
  p_RO_PRIORITY_CODE           => p_Repln_Rec.RO_PRIORITY_CODE,     -- swai: R12
  p_RESOLVE_BY_DATE            => p_Repln_rec.RESOLVE_BY_DATE,      -- rfieldma: 5355051
  p_BULLETIN_CHECK_DATE        => p_Repln_rec.BULLETIN_CHECK_DATE,
  p_ESCALATION_CODE            => p_Repln_rec.ESCALATION_CODE,
  p_RO_WARRANTY_STATUS_CODE    => p_Repln_rec.RO_WARRANTY_STATUS_CODE
  );


  p_REPLN_rec.object_version_number := l_object_version_number;

--
-- End of API body.
--
-- Standard check for p_commit
  IF Fnd_Api.to_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
-- Standard call to get message count and if count is 1, get message info.
  Fnd_Msg_Pub.Count_And_Get
  (p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
  );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Jtf_Plsql_Api.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
     ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Repair_Order;

PROCEDURE Delete_Repair_Order(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID             IN   NUMBER,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  )
IS

  l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Repair_Order';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN
--
-- Standard Start of API savepoint
  SAVEPOINT DELETE_REPAIR_ORDER_PVT;
-- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
         (l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;
-- Initialize API return status to SUCCESS
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
--
-- Api body
--
-- Invoke table handler(CSD_REPAIRS_PKG.Delete_Row)
  Csd_Repairs_Pkg.Delete_Row(
  p_REPAIR_LINE_ID  => p_REPAIR_LINE_ID);

-- End of API body

-- Standard check for p_commit
  IF Fnd_Api.to_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
-- Standard call to get message count and if count is 1, get message info.
  Fnd_Msg_Pub.Count_And_Get
    (p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
    );

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Jtf_Plsql_Api.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_Repair_Order;

--
-- Item-level validation procedures
--
PROCEDURE Validate_REPAIR_LINE_ID
  (
   P_REPAIR_LINE_ID     IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   CSD_REPAIRS dra
  WHERE  dra.repair_line_id = p_repair_line_id;

  l_dummy       VARCHAR2(1);
  l_valid       VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    RETURN;
  END IF;

  IF p_repair_line_id = Fnd_Api.G_MISS_NUM
    OR p_repair_line_id IS NULL THEN
    RETURN;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%FOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_REPLN_ID');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_REPAIR_LINE_ID;


PROCEDURE Validate_REPAIR_NUMBER
  (
   P_REPAIR_NUMBER       IN   VARCHAR2,
   P_OLD_REPAIR_NUMBER   IN   VARCHAR2,
   p_validation_mode     IN   VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   CSD_REPAIRS dra
  WHERE  dra.repair_number = p_repair_number;

  l_dummy       VARCHAR2(1);
  l_valid       VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_CREATE
    AND (p_repair_number = Fnd_Api.G_MISS_CHAR
    OR p_repair_number IS NULL) THEN
    RETURN;
  END IF;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_repair_number IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'REPAIR_NUMBER');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_repair_number = p_old_repair_number
        OR p_repair_number = Fnd_Api.G_MISS_CHAR THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%FOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_REPLN_NUMBER');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_REPAIR_NUMBER;


PROCEDURE Validate_INCIDENT_ID
  (
   P_INCIDENT_ID        IN   NUMBER,
   p_OLD_INCIDENT_ID    IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   cs_incidents_all_b sr
  WHERE  sr.incident_id = p_incident_id;  -- need to add more condition

  l_dummy    VARCHAR2(1);
  l_valid    VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_incident_id IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'INCIDENT_ID');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_incident_id = p_old_incident_id
        OR p_incident_id = Fnd_Api.G_MISS_NUM THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_INCIDENT_ID');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_INCIDENT_ID;


PROCEDURE Validate_INVENTORY_ITEM_ID
  (
   p_INVENTORY_ITEM_ID       IN   NUMBER,
   p_OLD_INVENTORY_ITEM_ID   IN   NUMBER,
   p_validation_mode         IN   VARCHAR2,
   x_return_status           OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   mtl_system_items_b mtl
  WHERE  mtl.inventory_item_id = p_inventory_item_id
  AND    mtl.organization_id = Cs_Std.get_item_valdn_orgzn_id;
  -- swai: forward port bug 2870951
  -- AND    mtl.serviceable_product_flag = 'Y';

  l_dummy    VARCHAR2(1);
  l_valid    VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_inventory_item_id IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'INVENTORY_ITEM_ID');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_inventory_item_id = p_old_inventory_item_id
        OR p_inventory_item_id = Fnd_Api.G_MISS_NUM THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_INVENTORY_ITEM');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_INVENTORY_ITEM_ID;


PROCEDURE Validate_CUSTOMER_PRODUCT_ID
  (
   P_CUSTOMER_PRODUCT_ID      IN   NUMBER,
   P_OLD_CUSTOMER_PRODUCT_ID  IN   NUMBER,
   P_INCIDENT_ID              IN   NUMBER,
   P_INVENTORY_ITEM_ID        IN   NUMBER,
   P_SERIAL_NUMBER            IN   VARCHAR2,
   p_validation_mode          IN   VARCHAR2,
   x_return_status            OUT NOCOPY  VARCHAR2
  )
IS
  /* Bug fix 9225852: Commented out old definition of cursor c1 and replaced with new one
  CURSOR c1 IS
  SELECT 'X'
  FROM   csi_item_instances cii,
        cs_incidents_all_b sr
  WHERE  sr.incident_id = p_incident_id
  AND    cii.instance_id = p_customer_product_id
  AND    cii.inventory_item_id = p_inventory_item_id
  AND    sr.customer_id = cii.owner_party_id
  AND    (p_serial_number IS NULL OR (p_serial_number IS NOT NULL AND
        cii.serial_number = p_serial_number));
  l_dummy                VARCHAR(1);
  l_valid                VARCHAR2(1) := 'Y';
  */
  CURSOR c1 IS
  SELECT 'X'
  FROM cs_incidents_all_b sr,
      csi_i_parties cip
  WHERE sr.incident_id = p_incident_id
  AND   cip.instance_id = p_customer_product_id
  AND   sr.customer_id  = cip.party_id
  AND  TRUNC(sysdate) BETWEEN TRUNC(NVL(cip.active_start_date,sysdate))
      AND TRUNC(NVL(cip.active_end_date,sysdate));

  l_dummy                VARCHAR(1);
  l_valid                VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_customer_product_id = Fnd_Api.G_MISS_NUM
    OR p_customer_product_id IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_customer_product_id = p_old_customer_product_id
        OR p_customer_product_id = Fnd_Api.G_MISS_NUM
        OR p_customer_product_id IS NULL) THEN
     RETURN;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_CUST_PROD');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_CUSTOMER_PRODUCT_ID;

-- Private procedure to validate customer product_id for refurbished non-IRO
-- saupadhy 11.5.10 01/29/2004

PROCEDURE Validate_INTERNAL_CUST_PROD_ID
  (
   P_CUSTOMER_PRODUCT_ID      IN   NUMBER,
   P_OLD_CUSTOMER_PRODUCT_ID  IN   NUMBER,
   P_INCIDENT_ID              IN   NUMBER,
   P_INVENTORY_ITEM_ID        IN   NUMBER,
   P_SERIAL_NUMBER            IN   VARCHAR2,
   p_validation_mode          IN   VARCHAR2,
   x_return_status            OUT NOCOPY  VARCHAR2
  )
IS

  l_Internal_Party_Id    NUMBER ;

  CURSOR c1 IS
  SELECT 'X'
  FROM   csi_item_instances cii,
        cs_incidents_all_b sr
  WHERE  sr.incident_id = p_incident_id
  AND    cii.instance_id = p_customer_product_id
  AND    cii.inventory_item_id = p_inventory_item_id
  AND    cii.owner_party_id IN (sr.customer_id , l_Internal_Party_Id )
  AND    (p_serial_number IS NULL OR (p_serial_number IS NOT NULL AND
        cii.serial_number = p_serial_number));
  l_dummy                VARCHAR(1);
  l_valid                VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_customer_product_id = Fnd_Api.G_MISS_NUM
    OR p_customer_product_id IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_customer_product_id = p_old_customer_product_id
        OR p_customer_product_id = Fnd_Api.G_MISS_NUM
        OR p_customer_product_id IS NULL) THEN
     RETURN;
  END IF;

  SELECT Internal_Party_id
  INTO l_Internal_party_id
  FROM csi_install_parameters
  WHERE ROWNUM = 1;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_CUST_PROD');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_Internal_CUST_PROD_ID;


PROCEDURE Validate_UNIT_OF_MEASURE
  (
   P_UNIT_OF_MEASURE     IN   VARCHAR2,
   P_INVENTORY_ITEM_ID   IN   NUMBER,
   p_validation_mode     IN   VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2
  )
IS
--
  CURSOR c1 IS
  SELECT 'X'
  FROM   aso_i_item_uoms_v uom
  WHERE  uom.uom_code = p_unit_of_measure
  AND    uom.inventory_item_id = p_inventory_item_id
  AND    uom.organization_id = Cs_Std.get_item_valdn_orgzn_id;

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_unit_of_measure IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'UNIT_OF_MEASURE');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_unit_of_measure = p_unit_of_measure
        OR p_unit_of_measure = Fnd_Api.G_MISS_CHAR THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_UOM');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_UNIT_OF_MEASURE;


PROCEDURE Validate_REPAIR_TYPE_ID
  (
   P_REPAIR_TYPE_ID     IN   NUMBER,
   P_OLD_REPAIR_TYPE_ID IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   CSD_REPAIR_TYPES_B TYPE
  WHERE  TYPE.repair_type_id = p_repair_type_id
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(TYPE.start_date_active, SYSDATE))
        AND TRUNC(NVL(TYPE.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_repair_type_id IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'REPAIR_TYPE_ID');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_repair_type_id = p_old_repair_type_id
        OR p_repair_type_id = Fnd_Api.G_MISS_NUM THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_REPAIR_TYPE');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_REPAIR_TYPE_ID;


PROCEDURE Validate_RESOURCE_ID
  (
   P_RESOURCE_GROUP     IN   NUMBER,
   P_RESOURCE_ID        IN   NUMBER,
   P_OLD_RESOURCE_ID    IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  -- swai: bug 7565999 - change cursor to take resorce group and resource id
  -- as params instead of relying on procedure parameters.
  CURSOR c1 (l_resource_group NUMBER, l_resource_id NUMBER) IS
  SELECT 'X'
  FROM   jtf_rs_resource_extns rs
  WHERE  l_resource_group IS NULL
  AND    rs.resource_id = l_resource_id
  AND    rs.category = 'EMPLOYEE'
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(rs.start_date_active, SYSDATE))
        AND TRUNC(NVL(rs.end_date_active, SYSDATE))
UNION

  SELECT 'X'
  FROM   jtf_rs_group_members rm, jtf_rs_resource_extns rs,jtf_rs_groups_b rg
  WHERE  l_resource_group IS NOT NULL
  AND    rm.resource_id = l_resource_id
  AND    rm.group_id = l_resource_group
  AND    rm.delete_flag <> 'Y'
  AND    rs.resource_id = rm.resource_id
  AND    rs.category = 'EMPLOYEE'
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(rs.start_date_active, SYSDATE))
        AND TRUNC(NVL(rs.end_date_active, SYSDATE))
  AND    rg.group_id = rm.group_id
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(rg.start_date_active, SYSDATE))
        AND TRUNC(NVL(rg.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';
  l_resource_group NUMBER;  -- swai: bug 7565999

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- swai: bug 7565999
  if(p_resource_group =  Fnd_Api.G_MISS_NUM) THEN
      l_resource_group := NULL;
  else
      l_resource_group := p_resource_group;
  end if;
  -- end swai: bug 7565999

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_resource_id = Fnd_Api.G_MISS_NUM
    OR p_resource_id IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_resource_id = p_old_resource_id
        OR p_resource_id = Fnd_Api.G_MISS_NUM
        OR p_resource_id IS NULL) THEN
     RETURN;
  END IF;

  OPEN c1 (l_resource_group, p_resource_id);  -- swai: bug 7565999
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_RESOURCE');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_RESOURCE_ID;
/************************************
Desc: Validates the resource group against the JTF tables.

**************************************/
PROCEDURE Validate_RESOURCE_GROUP
  (
   P_RESOURCE_GROUP        IN   NUMBER,
   P_OLD_RESOURCE_GROUP    IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   jtf_rs_group_usages rs, jtf_Rs_groups_b rg
  WHERE  rs.group_id = p_resource_group
  AND    rs.usage = 'REPAIR_ORGANIZATION'
  AND    rs.group_id = rg.group_id
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(rg.start_date_active, SYSDATE))
        AND TRUNC(NVL(rg.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_resource_group = Fnd_Api.G_MISS_NUM
    OR p_resource_group IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_resource_group = p_old_resource_group
        OR p_resource_group = Fnd_Api.G_MISS_NUM
        OR p_resource_group IS NULL) THEN
     RETURN;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_RS_GROUP');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_RESOURCE_GROUP;


PROCEDURE Validate_PROJECT_ID
  (
   P_PROJECT_ID         IN   NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  RETURN;

END Validate_PROJECT_ID;


PROCEDURE Validate_TASK_ID
  (
   P_TASK_ID            IN   NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS
--
BEGIN
--
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
--
  RETURN;
--
END Validate_TASK_ID;


PROCEDURE Validate_INSTANCE_ID
  (
   P_INSTANCE_ID        IN   NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  RETURN;

END Validate_INSTANCE_ID;


PROCEDURE Validate_STATUS
  (
   P_STATUS             IN   VARCHAR2,
   P_OLD_STATUS         IN   VARCHAR2,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   fnd_lookups fnd
  WHERE  fnd.lookup_code = p_status
  AND    fnd.lookup_type = 'CSD_REPAIR_STATUS'
  AND    fnd.enabled_flag = 'Y'
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(fnd.start_date_active, SYSDATE))
        AND TRUNC(NVL(fnd.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_status IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'STATUS');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_status = p_old_status
        OR p_status = Fnd_Api.G_MISS_CHAR THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_STATUS');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_STATUS;

PROCEDURE Validate_APPROVAL_REQD_FLAG
  (
   P_APPROVAL_REQUIRED_FLAG      IN   VARCHAR2,
   P_OLD_APPROVAL_REQUIRED_FLAG  IN   VARCHAR2,
   p_validation_mode             IN   VARCHAR2,
   x_return_status               OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   fnd_lookups fnd
  WHERE  fnd.lookup_code = p_approval_required_flag
  AND    fnd.lookup_type = 'YES_NO'
  AND    fnd.enabled_flag = 'Y'
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(fnd.start_date_active, SYSDATE))
        AND TRUNC(NVL(fnd.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_approval_required_flag IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'APPROVAL_REQUIRED_FLAG');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_approval_required_flag = p_old_approval_required_flag
        OR p_approval_required_flag = Fnd_Api.G_MISS_CHAR THEN
     RETURN;
    END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_APRVL_REQD_FLG');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_APPROVAL_REQD_FLAG;


PROCEDURE Validate_APPROVAL_STATUS
  (
   P_APPROVAL_STATUS      IN   VARCHAR2,
   P_OLD_APPROVAL_STATUS  IN   VARCHAR2,
   p_validation_mode      IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2
  )
IS

   -- Fix for Bug 3824988, sragunat, 11/16/04, Bind Variable fix,
   -- Introduced the following constants to use in Cursor cur_module_lookup
   -- query
   lc_appr_sts_lkp_typ    CONSTANT VARCHAR2(19) := 'CSD_APPROVAL_STATUS' ;
   lc_enabled             CONSTANT VARCHAR2(1)  := 'Y';


  CURSOR c1 IS
  SELECT 'X'
  FROM   fnd_lookups fnd
  WHERE  fnd.lookup_code = p_approval_status
  AND    fnd.lookup_type = lc_appr_sts_lkp_typ
  AND    fnd.enabled_flag = lc_enabled
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(fnd.start_date_active, SYSDATE))
        AND TRUNC(NVL(fnd.end_date_active, SYSDATE));

  l_dummy      VARCHAR2(1);
  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_approval_status = Fnd_Api.G_MISS_CHAR
    OR p_approval_status IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_approval_status = p_old_approval_status
        OR p_approval_status = Fnd_Api.G_MISS_CHAR
        OR p_approval_status IS NULL) THEN
     RETURN;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_APRVL_STATUS');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_APPROVAL_STATUS;


PROCEDURE Validate_SERIAL_NUMBER
  (
   P_SERIAL_NUMBER      IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  RETURN;

END Validate_SERIAL_NUMBER;


PROCEDURE Validate_PROMISE_DATE
  (
   P_PROMISE_DATE       IN   DATE,
   P_OLD_PROMISE_DATE   IN   DATE,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_promise_date = Fnd_Api.G_MISS_DATE
    OR p_promise_date IS NULL) THEN
    RETURN;
  END IF;

  IF (p_validation_mode = Jtf_Plsql_Api.G_UPDATE)
        AND (p_promise_date = p_old_promise_date
        OR p_promise_date = Fnd_Api.G_MISS_DATE
        OR p_promise_date IS NULL) THEN
     RETURN;
  END IF;

  IF p_promise_date < SYSDATE THEN
    l_valid := 'N';
  END IF;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_PROMISE_DATE');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_PROMISE_DATE;


PROCEDURE Validate_QUANTITY
  (
   P_QUANTITY           IN   NUMBER,
   P_OLD_QUANTITY       IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  l_valid      VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_quantity IS NULL THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'QUANTITY');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_quantity = p_old_quantity
        OR p_quantity = Fnd_Api.G_MISS_NUM THEN
     RETURN;
    END IF;
  END IF;

  IF p_quantity < 0 THEN
    l_valid := 'N';
  END IF;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_QUANTITY');
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_QUANTITY;


PROCEDURE Validate_QUANTITY_IN_WIP
  (
   P_QUANTITY_IN_WIP    IN   NUMBER,
   P_QUANTITY           IN   NUMBER,
   P_OLD_QUANTITY       IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  l_valid     VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
/*****************************************saupadhy
Following procedure will always return success , after JDSU enhancements,
user can submit quantities more then quantity received. i.e Quantity_in_WIP can
can be greater then Quantity_Rcvd ****************************
  if p_quantity_in_wip = FND_API.G_MISS_NUM
    or p_quantity_in_wip is null then
    return;
  end if;

  if p_validation_mode = JTF_PLSQL_API.G_CREATE then
    if p_quantity < p_quantity_in_wip then
      l_valid := 'N';
    end if;
  elsif p_validation_mode = JTF_PLSQL_API.G_UPDATE then
    if p_quantity = FND_API.G_MISS_NUM
      or p_quantity is null then
      if p_old_quantity < p_quantity_in_wip then
       l_valid := 'N';
      end if;
    else
      if p_quantity < p_quantity_in_wip then
        l_valid := 'N';
      end if;
    end if;
  end if;

  if l_valid = 'N' then
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CSD', 'CSD_INVALID_QTY_IN_WIP');
      FND_MSG_PUB.ADD;
    END IF;
  end if;
  Commented by saupadhy after JDSU enhancements
  **************************************************/

END Validate_QUANTITY_IN_WIP;


PROCEDURE Validate_QUANTITY_RCVD
  (
   P_QUANTITY_RCVD     IN   NUMBER,
   P_QUANTITY          IN   NUMBER,
   x_return_status     OUT NOCOPY  VARCHAR2
  )
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  RETURN;

END Validate_QUANTITY_RCVD;


PROCEDURE Validate_QUANTITY_SHIPPED
  (
   P_QUANTITY_SHIPPED  IN   NUMBER,
   P_QUANTITY          IN   NUMBER,
   x_return_status     OUT NOCOPY  VARCHAR2
  )
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  RETURN;

END Validate_QUANTITY_SHIPPED;

PROCEDURE Validate_OBJECT_VERSION_NUMBER
  (
   p_OBJECT_VERSION_NUMBER       IN   NUMBER,
   p_OLD_OBJECT_VERSION_NUMBER   IN   NUMBER,
   x_return_status               OUT NOCOPY  VARCHAR2
  )
IS
  l_valid                  VARCHAR2(1) := 'Y';


BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

-- Check if the current obj ver num from form and the obj ver num in db are different
   IF  (p_OBJECT_VERSION_NUMBER <> p_OLD_OBJECT_VERSION_NUMBER) THEN
       l_valid := 'N';
   END IF;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN

      -- travi this mesg need to be changed
-- travi      FND_MESSAGE.Set_Name('CSD', 'CSD_INVALID_OBJ_VER_NUM');
      Fnd_Msg_Pub.ADD;

    END IF;
  END IF;


  RETURN;

END Validate_OBJECT_VERSION_NUMBER;

-- New Code for 11.5.7.1
-- Purpose : Validate Repiar Group id
PROCEDURE Validate_RO_GROUP_ID
  (
   p_ro_group_id        IN   NUMBER,
   p_old_ro_group_id    IN   NUMBER,
   p_validation_mode    IN   VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2
  )
IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   csd_repair_order_groups crog
  WHERE  crog.repair_group_id = p_ro_group_id;

  l_dummy    VARCHAR2(1);
  l_valid    VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- travi fix
  IF p_validation_mode = Jtf_Plsql_Api.G_CREATE THEN
    IF (p_ro_group_id IS NULL) THEN
IF (g_debug > 0 ) THEN
       Csd_Gen_Utility_Pvt.ADD('Create_Repair_Order group_id is null : Validate_RO_GROUP_ID');
END IF;

IF (g_debug > 0 ) THEN
       Csd_Gen_Utility_Pvt.ADD('Create_Repair_Order group_id p_validation_mode : '||p_validation_mode);
END IF;

      RETURN;
    END IF;
  ELSIF p_validation_mode = Jtf_Plsql_Api.G_UPDATE THEN
    IF p_ro_group_id IS NULL THEN
IF (g_debug > 0 ) THEN
      Csd_Gen_Utility_Pvt.ADD('Update_Repair_Order group_id is null : Validate_RO_GROUP_ID');
END IF;

IF (g_debug > 0 ) THEN
       Csd_Gen_Utility_Pvt.ADD('Update_Repair_Order group_id p_validation_mode : '||p_validation_mode);
END IF;

      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      Fnd_Message.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      Fnd_Message.SET_TOKEN('NULL_PARAM', 'RO_GROUP_ID');
     Fnd_Msg_Pub.ADD;
     RETURN;
    ELSIF p_ro_group_id = p_old_ro_group_id
        OR p_ro_group_id = Fnd_Api.G_MISS_NUM THEN
IF (g_debug > 0 ) THEN
      Csd_Gen_Utility_Pvt.ADD('Update_Repair_Order group_id is not null or g_miss_num : Validate_RO_GROUP_ID');
END IF;

IF (g_debug > 0 ) THEN
       Csd_Gen_Utility_Pvt.ADD('Update_Repair_Order group_id p_validation_mode : '||p_validation_mode);
END IF;

     RETURN;
    END IF;
  END IF;

/* old code
  if p_validation_mode = JTF_PLSQL_API.G_UPDATE then
    if p_ro_group_id is null then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CSD', 'CSD_API_NULL_PARAM');
      FND_MESSAGE.SET_TOKEN('API_NAME', 'Update_Repair_Order');
      FND_MESSAGE.SET_TOKEN('NULL_PARAM', 'RO_GROUP_ID');
     FND_MSG_PUB.Add;
     return;
    elsif p_ro_group_id = p_old_ro_group_id
        or p_ro_group_id = FND_API.G_MISS_NUM then
     return;
    end if;
  end if;
*/

  IF (p_ro_group_id IS NOT NULL) OR
     (p_ro_group_id = Fnd_Api.G_MISS_NUM) THEN
IF (g_debug > 0 ) THEN
      Csd_Gen_Utility_Pvt.ADD('Create / update Repair_Order group_id is not null or g_miss_num : Validate_RO_GROUP_ID');
END IF;

IF (g_debug > 0 ) THEN
       Csd_Gen_Utility_Pvt.ADD('Create / update group_id p_validation_mode : '||p_validation_mode);
END IF;

      OPEN c1;
      FETCH c1 INTO l_dummy;
      IF c1%NOTFOUND THEN
        l_valid := 'N';
      END IF;
      CLOSE c1;

      IF l_valid = 'N' THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
          Fnd_Message.Set_Name('CSD', 'CSD_INVALID_RO_GROUP_ID');
          Fnd_Msg_Pub.ADD;
        END IF;
      END IF;
  END IF;

END Validate_RO_GROUP_ID;


PROCEDURE Validate_SOURCE
  (
   p_ORIGINAL_SOURCE_HEADER_ID  IN   NUMBER,
   p_ORIGINAL_SOURCE_LINE_ID    IN   NUMBER,
   p_ORIGINAL_SOURCE_REFERENCE  IN   VARCHAR2,
   p_validation_mode            IN   VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2
  ) IS

  CURSOR c1 IS
  SELECT 'X'
  FROM   oe_order_lines_all
  WHERE  line_id   = p_ORIGINAL_SOURCE_LINE_ID
  AND    header_id = p_ORIGINAL_SOURCE_HEADER_ID;

  l_dummy    VARCHAR2(1);
  l_valid    VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (p_validation_mode = Jtf_Plsql_Api.G_CREATE)
     AND (p_ORIGINAL_SOURCE_REFERENCE = Fnd_Api.G_MISS_CHAR
    OR p_ORIGINAL_SOURCE_REFERENCE IS NULL) THEN
    RETURN;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    l_valid := 'N';
  END IF;
  CLOSE c1;

  IF l_valid = 'N' THEN
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_Name('CSD', 'CSD_INVALID_SOURCE');
      Fnd_Message.SET_TOKEN('ORDER_LINE_ID', p_ORIGINAL_SOURCE_LINE_ID);
      Fnd_Message.SET_TOKEN('ORDER_HEADER_ID', p_ORIGINAL_SOURCE_HEADER_ID);
      Fnd_Msg_Pub.ADD;
    END IF;
  END IF;

END Validate_SOURCE;

--
-- bug#7242791,12. FP, subhat
-- added a new out parameter.ds
-- @param: x_dff_rec OUT NOCOPY CSD_REPAIRS_UTIL.DEF_Rec_Type
--
PROCEDURE Validate_Repairs
  (
   P_Api_Version_Number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN   NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
   P_Validation_mode            IN   VARCHAR2,
   p_repair_line_id             IN   NUMBER := Fnd_Api.G_MISS_NUM,
   P_REPLN_Rec                  IN   Csd_Repairs_Pub.REPLN_Rec_Type,
   P_OLD_REPLN_Rec              IN   Csd_Repairs_Pub.REPLN_Rec_Type := Csd_Repairs_Pub.G_MISS_REPLN_Rec,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   -- bug#7242791, subhat
   x_dff_rec                    OUT NOCOPY CSD_REPAIRS_UTIL.DEF_Rec_Type

  )
IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Repairs';
  l_api_version_number    CONSTANT NUMBER := 1.0;
  --l_DEF_Rec                        Csd_Repairs_Util.DEF_Rec_Type;
  l_valid_def_rec                  BOOLEAN;
  l_attribute_category             VARCHAR2(30);
  l_attribute1                     VARCHAR2(150);
  l_attribute2                     VARCHAR2(150);
  l_attribute3                     VARCHAR2(150);
  l_attribute4                     VARCHAR2(150);
  l_attribute5                     VARCHAR2(150);
  l_attribute6                     VARCHAR2(150);
  l_attribute7                     VARCHAR2(150);
  l_attribute8                     VARCHAR2(150);
  l_attribute9                     VARCHAR2(150);
  l_attribute10                    VARCHAR2(150);
  l_attribute11                    VARCHAR2(150);
  l_attribute12                    VARCHAR2(150);
  l_attribute13                    VARCHAR2(150);
  l_attribute14                    VARCHAR2(150);
  l_attribute15                    VARCHAR2(150);
   -- subhat, 15 new DFF columns(bug#7497907).
  l_attribute16                    VARCHAR2(150);
  l_attribute17                    VARCHAR2(150);
  l_attribute18                    VARCHAR2(150);
  l_attribute19                    VARCHAR2(150);
  l_attribute20                    VARCHAR2(150);
  l_attribute21                    VARCHAR2(150);
  l_attribute22                    VARCHAR2(150);
  l_attribute23                    VARCHAR2(150);
  l_attribute24                    VARCHAR2(150);
  l_attribute25                    VARCHAR2(150);
  l_attribute26                    VARCHAR2(150);
  l_attribute27                    VARCHAR2(150);
  l_attribute28                    VARCHAR2(150);
  l_attribute29                    VARCHAR2(150);
  l_attribute30                    VARCHAR2(150);

  l_ib_flag VARCHAR2(1):= '';
  l_refurbished_repair_type_flag     VARCHAR2(1);

BEGIN

-- Standard Start of API savepoint
  SAVEPOINT VALIDATE_REPAIRS_PVT;
-- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
           (l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
-- Initialize API return status to SUCCESS
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
--
-- API Body
--

-- New Code for 11.5.7.1
-- Purpose : Validate Repiar Group id
     Validate_RO_GROUP_ID
    (
     p_ro_group_id     => P_REPLN_Rec.repair_group_id,
     p_old_ro_group_id => P_OLD_REPLN_Rec.repair_group_id,
     p_validation_mode => p_validation_mode,
    x_return_status   => x_return_status
    );
-- Check return status from the above procedure call


    Validate_REPAIR_LINE_ID
    (
     p_REPAIR_LINE_ID => P_REPAIR_LINE_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_REPAIR_NUMBER
    (
     p_REPAIR_NUMBER => P_REPLN_Rec.REPAIR_NUMBER,
     p_OLD_REPAIR_NUMBER => P_OLD_REPLN_Rec.REPAIR_NUMBER,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_INCIDENT_ID
    (
     p_INCIDENT_ID => P_REPLN_Rec.INCIDENT_ID,
     p_OLD_INCIDENT_ID => P_OLD_REPLN_Rec.INCIDENT_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_INVENTORY_ITEM_ID
    (
     p_INVENTORY_ITEM_ID => P_REPLN_Rec.INVENTORY_ITEM_ID,
     p_OLD_INVENTORY_ITEM_ID => P_OLD_REPLN_Rec.INVENTORY_ITEM_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_UNIT_OF_MEASURE
    (
     p_UNIT_OF_MEASURE => P_REPLN_Rec.UNIT_OF_MEASURE,
    p_INVENTORY_ITEM_ID => P_REPLN_Rec.INVENTORY_ITEM_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_REPAIR_TYPE_ID
    (
     p_REPAIR_TYPE_ID => P_REPLN_Rec.REPAIR_TYPE_ID,
     p_OLD_REPAIR_TYPE_ID => P_OLD_REPLN_Rec.REPAIR_TYPE_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );

    -- Check if repair Type is Refurbished saupadhy 11.5.10
    -- If so set flag l_Refurbihed_repair_Type_Flag with value 'Y'
    BEGIN
       SELECT 'Y' INTO l_Refurbished_repair_Type_Flag
       FROM Csd_REpair_types_b
       WHERE Repair_type_Id = p_Repln_Rec.Repair_Type_Id
       AND  NVL(internal_order_Flag,'N') = 'N'
       AND repair_type_ref = 'RF' ;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_Refurbished_repair_Type_Flag := 'N' ;
    END;

-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_APPROVAL_STATUS
    (
     p_APPROVAL_STATUS => P_REPLN_Rec.APPROVAL_STATUS,
     p_OLD_APPROVAL_STATUS => P_OLD_REPLN_Rec.APPROVAL_STATUS,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    /* Commented for R12 Flex Flow
    -- No validation for Status required.
    Validate_STATUS
    (
     p_STATUS => P_REPLN_Rec.STATUS,
     p_OLD_STATUS => P_OLD_REPLN_Rec.STATUS,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    Validate_QUANTITY
    (
     p_QUANTITY   => P_REPLN_Rec.QUANTITY,
     p_OLD_QUANTITY   => P_OLD_REPLN_Rec.QUANTITY,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

-- travi new code to validate the object version number
  Validate_OBJECT_VERSION_NUMBER
  (
   p_OBJECT_VERSION_NUMBER       =>    P_REPLN_Rec.OBJECT_VERSION_NUMBER,
   p_OLD_OBJECT_VERSION_NUMBER   =>    P_OLD_REPLN_Rec.OBJECT_VERSION_NUMBER,
   x_return_status               =>    x_return_status
  );

-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

  IF (p_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL) THEN


    -- Do following validation only for non refurbished repair orders
    -- Validation for customer_product_id should not be done for
    -- refurbished repair orders saupadhy 11.5.10
    IF l_Refurbished_repair_Type_Flag = 'N' THEN
       Validate_CUSTOMER_PRODUCT_ID
       (
        p_CUSTOMER_PRODUCT_ID => P_REPLN_Rec.CUSTOMER_PRODUCT_ID,
        p_OLD_CUSTOMER_PRODUCT_ID => P_OLD_REPLN_Rec.CUSTOMER_PRODUCT_ID,
        p_INCIDENT_ID => P_REPLN_Rec.INCIDENT_ID,
        p_INVENTORY_ITEM_ID => P_REPLN_Rec.INVENTORY_ITEM_ID,
        p_SERIAL_NUMBER => P_REPLN_Rec.SERIAL_NUMBER,
        p_validation_mode => p_validation_mode,
        x_return_status => x_return_status);
    ELSE
       Validate_Internal_CUST_PROD_ID
       (
        p_CUSTOMER_PRODUCT_ID => P_REPLN_Rec.CUSTOMER_PRODUCT_ID,
        p_OLD_CUSTOMER_PRODUCT_ID => P_OLD_REPLN_Rec.CUSTOMER_PRODUCT_ID,
        p_INCIDENT_ID => P_REPLN_Rec.INCIDENT_ID,
        p_INVENTORY_ITEM_ID => P_REPLN_Rec.INVENTORY_ITEM_ID,
        p_SERIAL_NUMBER => P_REPLN_Rec.SERIAL_NUMBER,
        p_validation_mode => p_validation_mode,
        x_return_status => x_return_status);

    END IF;

    -- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_SOURCE
      (
      p_ORIGINAL_SOURCE_HEADER_ID  => P_REPLN_Rec.ORIGINAL_SOURCE_HEADER_ID,
      p_ORIGINAL_SOURCE_LINE_ID    => P_REPLN_Rec.ORIGINAL_SOURCE_LINE_ID,
      p_ORIGINAL_SOURCE_REFERENCE  => P_REPLN_Rec.ORIGINAL_SOURCE_REFERENCE,
        p_validation_mode            => Jtf_Plsql_Api.G_CREATE,
      x_return_status              => x_return_status);

     -- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
       RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --Vijay 10/28/2004 Begin

    Validate_RESOURCE_GROUP
    (
     p_RESOURCE_GROUP => P_REPLN_Rec.RESOURCE_GROUP,
     p_OLD_RESOURCE_GROUP => P_OLD_REPLN_Rec.RESOURCE_GROUP,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    --Vijay 10/28/2004 End

    Validate_RESOURCE_ID
    (
     p_RESOURCE_GROUP => P_REPLN_Rec.RESOURCE_GROUP,
     p_RESOURCE_ID => P_REPLN_Rec.RESOURCE_ID,
     p_OLD_RESOURCE_ID => P_OLD_REPLN_Rec.RESOURCE_ID,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_APPROVAL_REQD_FLAG
    (
     p_APPROVAL_REQUIRED_FLAG => P_REPLN_Rec.APPROVAL_REQUIRED_FLAG,
     p_OLD_APPROVAL_REQUIRED_FLAG => P_OLD_REPLN_Rec.APPROVAL_REQUIRED_FLAG,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;


    Validate_PROMISE_DATE
    (
     p_PROMISE_DATE   => P_REPLN_Rec.PROMISE_DATE,
     p_OLD_PROMISE_DATE   => P_OLD_REPLN_Rec.PROMISE_DATE,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );
-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    Validate_QUANTITY_IN_WIP
    (
     p_QUANTITY_IN_WIP   => P_REPLN_Rec.QUANTITY_IN_WIP,
    p_QUANTITY => P_REPLN_Rec.QUANTITY,
    p_OLD_QUANTITY => P_OLD_REPLN_Rec.QUANTITY,
     p_validation_mode => p_validation_mode,
    x_return_status => x_return_status
    );

-- Check return status from the above procedure call
    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- bugfix 3390579: p_repln_rec does not contain all the values. To validate
    -- DFF, we need proper values to be populated. Here, we will populate the
    -- appropriate values from p_old_repln_rec record structure so that
    -- validation happens correctly.

    IF (p_REPLN_Rec.attribute_category IS NULL) OR  (p_REPLN_Rec.attribute_category = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute_category,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute_category := p_old_repln_rec.attribute_category;
   END IF;
    ELSE
     l_attribute_category := p_REPLN_Rec.attribute_category;
    END IF;

    IF (p_REPLN_Rec.attribute1 IS NULL) OR (p_REPLN_Rec.attribute1 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute1,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute1 := p_old_repln_rec.attribute1;
   END IF;
    ELSE
     l_attribute1 := p_REPLN_Rec.attribute1;
    END IF;

    IF (p_REPLN_Rec.attribute2 IS NULL) OR (p_REPLN_Rec.attribute2 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute2,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute2 := p_old_repln_rec.attribute2;
   END IF;
    ELSE
     l_attribute2 := p_REPLN_Rec.attribute2;
    END IF;

    IF (p_REPLN_Rec.attribute3 IS NULL) OR (p_REPLN_Rec.attribute3 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute3,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute3 := p_old_repln_rec.attribute3;
   END IF;
    ELSE
     l_attribute3 := p_REPLN_Rec.attribute3;
    END IF;

    IF (p_REPLN_Rec.attribute4 IS NULL) OR (p_REPLN_Rec.attribute4 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute4,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute4 := p_old_repln_rec.attribute4;
   END IF;
    ELSE
     l_attribute4 := p_REPLN_Rec.attribute4;
    END IF;

    IF (p_REPLN_Rec.attribute5 IS NULL) OR (p_REPLN_Rec.attribute5 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute5,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute5 := p_old_repln_rec.attribute5;
   END IF;
    ELSE
     l_attribute5 := p_REPLN_Rec.attribute5;
    END IF;

    IF (p_REPLN_Rec.attribute6 IS NULL) OR (p_REPLN_Rec.attribute6 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute6,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute6 := p_old_repln_rec.attribute6;
   END IF;
    ELSE
     l_attribute6 := p_REPLN_Rec.attribute6;
    END IF;

    IF (p_REPLN_Rec.attribute7 IS NULL) OR (p_REPLN_Rec.attribute7 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute7,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute7 := p_old_repln_rec.attribute7;
   END IF;
    ELSE
     l_attribute7 := p_REPLN_Rec.attribute7;
    END IF;

    IF (p_REPLN_Rec.attribute8 IS NULL) OR (p_REPLN_Rec.attribute8 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute8,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute8 := p_old_repln_rec.attribute8;
   END IF;
    ELSE
     l_attribute8 := p_REPLN_Rec.attribute8;
    END IF;

    IF (p_REPLN_Rec.attribute9 IS NULL) OR (p_REPLN_Rec.attribute9 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute9,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute9 := p_old_repln_rec.attribute9;
   END IF;
    ELSE
     l_attribute9 := p_REPLN_Rec.attribute9;
    END IF;

    IF (p_REPLN_Rec.attribute10 IS NULL) OR (p_REPLN_Rec.attribute10 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute10,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute10 := p_old_repln_rec.attribute10;
   END IF;
    ELSE
     l_attribute10 := p_REPLN_Rec.attribute10;
    END IF;

    IF (p_REPLN_Rec.attribute11 IS NULL) OR (p_REPLN_Rec.attribute11 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute11,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute11 := p_old_repln_rec.attribute11;
   END IF;
    ELSE
     l_attribute11 := p_REPLN_Rec.attribute11;
    END IF;

    IF (p_REPLN_Rec.attribute12 IS NULL) OR (p_REPLN_Rec.attribute12 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute12,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute12 := p_old_repln_rec.attribute12;
   END IF;
    ELSE
     l_attribute12 := p_REPLN_Rec.attribute12;
    END IF;

    IF (p_REPLN_Rec.attribute13 IS NULL) OR (p_REPLN_Rec.attribute13 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute13,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute13 := p_old_repln_rec.attribute13;
   END IF;
    ELSE
     l_attribute13 := p_REPLN_Rec.attribute13;
    END IF;

    IF (p_REPLN_Rec.attribute14 IS NULL) OR (p_REPLN_Rec.attribute14 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute14,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute14 := p_old_repln_rec.attribute14;
   END IF;
    ELSE
     l_attribute14 := p_REPLN_Rec.attribute14;
    END IF;

    IF (p_REPLN_Rec.attribute15 IS NULL) OR (p_REPLN_Rec.attribute15 = Fnd_Api.G_MISS_CHAR) THEN
     IF NVL(p_old_repln_rec.attribute15,Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR THEN
        l_attribute15 := p_old_repln_rec.attribute15;
     END IF;
    ELSE
     l_attribute15 := p_REPLN_Rec.attribute15;
    END IF;

    --subhat, 15 new DFF columns(bug#7497907), 12.1 FP.
	IF (p_REPLN_Rec.attribute16 is null) or (p_REPLN_Rec.attribute16 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute16,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute16 := p_old_repln_rec.attribute16;
	END IF;
    ELSE
     l_attribute16 := p_REPLN_Rec.attribute16;
	END IF;

	IF (p_REPLN_Rec.attribute17 is null) or (p_REPLN_Rec.attribute17 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute17,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute17 := p_old_repln_rec.attribute17;
	END IF;
    ELSE
     l_attribute17 := p_REPLN_Rec.attribute17;
	END IF;

	IF (p_REPLN_Rec.attribute18 is null) or (p_REPLN_Rec.attribute18 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute18,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute18 := p_old_repln_rec.attribute18;
	END IF;
    ELSE
     l_attribute18 := p_REPLN_Rec.attribute18;
	END IF;

	IF (p_REPLN_Rec.attribute19 is null) or (p_REPLN_Rec.attribute19 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute19,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute19 := p_old_repln_rec.attribute19;
	END IF;
    ELSE
     l_attribute19 := p_REPLN_Rec.attribute19;
	END IF;

	IF (p_REPLN_Rec.attribute20 is null) or (p_REPLN_Rec.attribute20 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute20,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute20 := p_old_repln_rec.attribute20;
	END IF;
    ELSE
     l_attribute20 := p_REPLN_Rec.attribute20;
	END IF;

	IF (p_REPLN_Rec.attribute21 is null) or (p_REPLN_Rec.attribute21 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute21,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute21 := p_old_repln_rec.attribute21;
	END IF;
    ELSE
     l_attribute21 := p_REPLN_Rec.attribute21;
	END IF;

	IF (p_REPLN_Rec.attribute22 is null) or (p_REPLN_Rec.attribute22 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute22,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute22 := p_old_repln_rec.attribute22;
	END IF;
    ELSE
     l_attribute22 := p_REPLN_Rec.attribute22;
	END IF;

	IF (p_REPLN_Rec.attribute23 is null) or (p_REPLN_Rec.attribute23 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute23,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute23 := p_old_repln_rec.attribute23;
	END IF;
    ELSE
     l_attribute23 := p_REPLN_Rec.attribute23;
	END IF;

	IF (p_REPLN_Rec.attribute24 is null) or (p_REPLN_Rec.attribute24 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute24,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute24 := p_old_repln_rec.attribute24;
	END IF;
    ELSE
     l_attribute24 := p_REPLN_Rec.attribute24;
	END IF;

	IF (p_REPLN_Rec.attribute25 is null) or (p_REPLN_Rec.attribute25 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute25,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute25 := p_old_repln_rec.attribute25;
	END IF;
    ELSE
     l_attribute25 := p_REPLN_Rec.attribute25;
	END IF;

	IF (p_REPLN_Rec.attribute26 is null) or (p_REPLN_Rec.attribute26 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute26,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute26 := p_old_repln_rec.attribute26;
	END IF;
    ELSE
     l_attribute26 := p_REPLN_Rec.attribute26;
	END IF;

	IF (p_REPLN_Rec.attribute27 is null) or (p_REPLN_Rec.attribute27 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute27,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute27 := p_old_repln_rec.attribute27;
	END IF;
    ELSE
     l_attribute27 := p_REPLN_Rec.attribute27;
	END IF;

	IF (p_REPLN_Rec.attribute28 is null) or (p_REPLN_Rec.attribute28 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute28,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute28 := p_old_repln_rec.attribute28;
	END IF;
    ELSE
     l_attribute28 := p_REPLN_Rec.attribute28;
	END IF;

	IF (p_REPLN_Rec.attribute29 is null) or (p_REPLN_Rec.attribute29 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute29,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute29 := p_old_repln_rec.attribute29;
	END IF;
    ELSE
     l_attribute29 := p_REPLN_Rec.attribute29;
	END IF;

	IF (p_REPLN_Rec.attribute30 is null) or (p_REPLN_Rec.attribute30 = FND_API.G_MISS_CHAR) then
     IF nvl(p_old_repln_rec.attribute30,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
        l_attribute30 := p_old_repln_rec.attribute30;
	END IF;
    ELSE
     l_attribute30 := p_REPLN_Rec.attribute30;
	END IF;
    Csd_Repairs_Util.Convert_to_DEF_Rec_Type
    (p_attribute_category => l_attribute_category,
     p_attribute1 => l_attribute1,
     p_attribute2 => l_attribute2,
     p_attribute3 => l_attribute3,
     p_attribute4 => l_attribute4,
     p_attribute5 => l_attribute5,
     p_attribute6 => l_attribute6,
     p_attribute7 => l_attribute7,
     p_attribute8 => l_attribute8,
     p_attribute9 => l_attribute9,
     p_attribute10 => l_attribute10,
     p_attribute11 => l_attribute11,
     p_attribute12 => l_attribute12,
     p_attribute13 => l_attribute13,
     p_attribute14 => l_attribute14,
     p_attribute15 => l_attribute15,
     p_attribute16 => l_attribute16, --DFF changes, subhat(bug#7497907)
     p_attribute17 => l_attribute17,
     p_attribute18 => l_attribute18,
     p_attribute19 => l_attribute19,
     p_attribute20 => l_attribute20,
     p_attribute21 => l_attribute21,
     p_attribute22 => l_attribute22,
     p_attribute23 => l_attribute23,
     p_attribute24 => l_attribute24,
     p_attribute25 => l_attribute25,
     p_attribute26 => l_attribute26,
     p_attribute27 => l_attribute27,
     p_attribute28 => l_attribute28,
     p_attribute29 => l_attribute29,
     p_attribute30 => l_attribute30,
     x_DEF_Rec => x_DFF_Rec
    );

    -- bug#7242791, subhat (This FP also contains the fix provided in bug#7438725)
    -- the defaulting in the FND Flex API should happen only if the mode is
    -- create and profile CSD: Enable Flexfield Defaulting for Repair Orders Flexfield
    -- is set to Yes.
    IF p_validation_mode = Jtf_Plsql_Api.G_CREATE THEN
    if nvl(fnd_profile.value('CSD_RO_DFF_DEF'),'N') = 'Y' then
      l_valid_def_rec := Csd_Repairs_Util.Is_DescFlex_Valid
                     (p_api_name => 'Create_Repair_Order',
                      p_desc_flex_name => 'CSD_REPAIRS',
                      p_attr_values => x_dff_rec,
                      p_validate_only => FND_API.G_FALSE);
    else
        l_valid_def_rec := CSD_REPAIRS_UTIL.Is_DescFlex_Valid
                     (p_api_name => 'Create_Repair_Order',
                      p_desc_flex_name => 'CSD_REPAIRS',
                      p_attr_values => x_dff_rec,
                      p_validate_only => FND_API.G_TRUE
                      );
      end if;
    ELSE
        l_valid_def_rec := CSD_REPAIRS_UTIL.Is_DescFlex_Valid
                     (p_api_name => 'Update_Repair_Order',
                      p_desc_flex_name => 'CSD_REPAIRS',
                      p_attr_values => x_dff_rec,
                      p_validate_only => FND_API.G_TRUE
                      );
    END IF;
-- Check validation status from the above procedure call
    IF NOT (l_valid_def_rec) THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

  END IF; -- End of Validation Level IF Block
--
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
    ( P_API_NAME => L_API_NAME
     ,P_PKG_NAME => G_PKG_NAME
     ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
     ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
     ,X_MSG_COUNT => X_MSG_COUNT
     ,X_MSG_DATA => X_MSG_DATA
     ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Jtf_Plsql_Api.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_Repairs;

/*-------------------------------------------------------------------*/
/* procedure name: Copy_Attachments                                  */
/* description   : Thi procedure copies all the attachements from    */
/*                 the original repair order to the new repair       */
/*                 order.                                            */
/*                                                                   */
/*                                                                   */
/* p_api_version                Standard IN  param                   */
/* p_commit                     Standard IN  param                   */
/* p_init_msg_list              Standard IN  param                   */
/* p_validation_level           Standard IN  param                   */
/* p_original_ro_id             Original Repair Line Id              */
/* p_new_ro_id                  New Repair Line Id                   */
/* x_return_status              Standard OUT param                   */
/* x_msg_count                  Standard OUT param                   */
/* x_msg_data                   Standard OUT param                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
PROCEDURE Copy_Attachments
 ( p_api_version       IN            NUMBER,
   p_commit            IN            VARCHAR2,
   p_init_msg_list     IN            VARCHAR2,
   p_validation_level  IN            NUMBER,
   x_return_status     OUT NOCOPY    VARCHAR2,
   x_msg_count         OUT NOCOPY    NUMBER,
   x_msg_data          OUT NOCOPY    VARCHAR2,
   p_original_ro_id    IN            NUMBER,
   p_new_ro_id         IN            NUMBER)
IS
  CURSOR doclist IS
    SELECT  fad.seq_num,
      fad.document_id,
      fad.attached_document_id,
      fad.attribute_category,
      fad.attribute1,
      fad.attribute2,
      fad.attribute3,
      fad.attribute4,
      fad.attribute5,
      fad.attribute6,
      fad.attribute7,
      fad.attribute8,
      fad.attribute9,
      fad.attribute10,
      fad.attribute11,
      fad.attribute12,
      fad.attribute13,
      fad.attribute14,
      fad.attribute15,
      fad.column1,
      fad.automatically_added_flag,
      fd.datatype_id,
      fd.category_id,
      fd.security_type,
      fd.security_id,
      fd.publish_flag,
      fd.image_type,
      fd.storage_type,
      fd.usage_type,
      fd.start_date_active,
      fd.end_date_active,
      fd.request_id,
      fd.program_application_id,
      fd.program_id,
      fdtl.LANGUAGE,
      fdtl.description,
      fdtl.file_name,
      fdtl.media_id,
      fdtl.doc_attribute_category dattr_cat,
      fdtl.doc_attribute1  dattr1,
      fdtl.doc_attribute2  dattr2,
      fdtl.doc_attribute3  dattr3,
      fdtl.doc_attribute4  dattr4,
      fdtl.doc_attribute5  dattr5,
      fdtl.doc_attribute6  dattr6,
      fdtl.doc_attribute7  dattr7,
      fdtl.doc_attribute8  dattr8,
      fdtl.doc_attribute9  dattr9,
      fdtl.doc_attribute10 dattr10,
      fdtl.doc_attribute11 dattr11,
      fdtl.doc_attribute12 dattr12,
      fdtl.doc_attribute13 dattr13,
      fdtl.doc_attribute14 dattr14,
      fdtl.doc_attribute15 dattr15
    FROM fnd_attached_documents fad,
         fnd_documents fd,
         fnd_documents_tl fdtl
    WHERE fad.document_id = fd.document_id
    AND fd.document_id    = fdtl.document_id
    AND fdtl.LANGUAGE     = USERENV('LANG')
    AND fad.pk1_value     = TO_CHAR(p_original_ro_id);

  CURSOR shorttext (mid NUMBER) IS
    SELECT short_text
    FROM fnd_documents_short_text
    WHERE media_id = mid;

  CURSOR longtext (mid NUMBER) IS
    SELECT long_text
    FROM fnd_documents_long_text
    WHERE media_id = mid;

  CURSOR fnd_lobs_cur (mid NUMBER) IS
    SELECT file_id,
           file_name,
           file_content_type,
           upload_date,
           expiration_date,
           program_name,
           program_tag,
           file_data,
           LANGUAGE,
           oracle_charset,
           file_format
    FROM fnd_lobs
    WHERE file_id = mid;

  l_media_id_tmp      NUMBER;
  l_document_id_tmp   NUMBER;
  l_row_id_tmp        VARCHAR2(30);
  l_short_text_tmp    VARCHAR2(2000);
  l_long_text_tmp     LONG;
  l_fnd_lobs_rec      fnd_lobs_cur%ROWTYPE;
  l_api_name          CONSTANT VARCHAR2(30) := 'Copy_Attachments';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_debug_level       NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
  l_procedure_level   NUMBER := Fnd_Log.LEVEL_PROCEDURE;
  l_statement_level   NUMBER := Fnd_Log.LEVEL_STATEMENT;
  l_event_level       NUMBER := Fnd_Log.LEVEL_EVENT;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT copy_Attachments;

  IF(Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Entered Copy_Attachments API');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Validate Original Repair line id = '||p_original_ro_id);
  END IF;

  IF NOT (Csd_Process_Util.Validate_rep_line_id
            ( p_repair_line_id => p_original_ro_id)) THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Validation of Original Repair line id completed successfully');
  END IF;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Validate New Repair line id = '||p_new_ro_id);
  END IF;

  IF NOT (Csd_Process_Util.Validate_rep_line_id
            ( p_repair_line_id => p_new_ro_id)) THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Validation of New Repair line id completed successfully');
  END IF;

  -- Begin API Body
  -- Use cursor loop to get all attachments associated with
  -- the from_entity (Original Repair Order)

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Open main cursor');
  END IF;

  IF(Fnd_Log.Level_Event >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Event,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Started Copying of Attachments ');
  END IF;


  FOR docrec IN doclist LOOP

    IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Main cursor - Datatype id = '||docrec.datatype_id);

    END IF;

    -- Data type codes
    -- 1 = Short text
    -- 2 = Long text
    -- 6 = File
    -- 5 = Web page
    IF (docrec.usage_type = 'O'
   AND docrec.datatype_id IN (1,2,6,5) ) THEN
      --  Create Documents records

      IF ( Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level ) THEN
           Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Calling the FND_DOCUMENTS_PKG.Insert_Row');
      END IF;

      Fnd_Documents_Pkg.Insert_Row(l_row_id_tmp,
        l_document_id_tmp,
     SYSDATE,
     Fnd_Global.user_id,
     SYSDATE,
     Fnd_Global.user_id,
     Fnd_Global.user_id,
     docrec.datatype_id,
     docrec.category_id,
     docrec.security_type,
     docrec.security_id,
     docrec.publish_flag,
     docrec.image_type,
     docrec.storage_type,
     docrec.usage_type,
     docrec.start_date_active,
     docrec.end_date_active,
     docrec.request_id,
     docrec.program_application_id,
     docrec.program_id,
     SYSDATE,
     docrec.LANGUAGE,
     docrec.description,
     docrec.file_name,
     l_media_id_tmp,
     docrec.dattr_cat, docrec.dattr1,
     docrec.dattr2, docrec.dattr3,
     docrec.dattr4, docrec.dattr5,
     docrec.dattr6, docrec.dattr7,
     docrec.dattr8, docrec.dattr9,
     docrec.dattr10, docrec.dattr11,
     docrec.dattr12, docrec.dattr13,
     docrec.dattr14, docrec.dattr15);


      docrec.document_id := l_document_id_tmp;

      -- Insert data into media tables depending on
      -- the data type.
      -- 1.If datatype id = 1 (short text) then insert
      -- into fnd_documents_short_text.
      -- 2.If datatype id = 2 (Long text) then insert
      -- into fnd_documents_long_text.
      -- 3.If datatype id = 6 ( File ) then insert
      -- into fnd_lobs_cur.

      --  Duplicate short or long text
      IF (docrec.datatype_id = 1) THEN
      --  Handle short Text
      --  get original data
        OPEN shorttext(docrec.media_id);
        FETCH shorttext INTO l_short_text_tmp;
        CLOSE shorttext;

        IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
          Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Inserting into fnd_documents_short_text for
                    document id = '||docrec.document_id);
        END IF;

        INSERT INTO fnd_documents_short_text (
          media_id,
     short_text)
        VALUES (
          l_media_id_tmp,
          l_short_text_tmp);

        l_media_id_tmp := '';

      ELSIF (docrec.datatype_id = 2) THEN
        --  Handle long text
        --  get original data
        OPEN longtext(docrec.media_id);
        FETCH longtext INTO l_long_text_tmp;
        CLOSE longtext;

        IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
          Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Inserting into fnd_documents_long_text for
                    document id = '||docrec.document_id);
        END IF;

        INSERT INTO fnd_documents_long_text (
          media_id,
     long_text)
        VALUES (
          l_media_id_tmp,
          l_long_text_tmp);

        l_media_id_tmp := '';

      ELSIF (docrec.datatype_id=6) THEN

        OPEN fnd_lobs_cur(docrec.media_id);
        FETCH fnd_lobs_cur
        INTO l_fnd_lobs_rec.file_id,
          l_fnd_lobs_rec.file_name,
          l_fnd_lobs_rec.file_content_type,
          l_fnd_lobs_rec.upload_date,
          l_fnd_lobs_rec.expiration_date,
          l_fnd_lobs_rec.program_name,
          l_fnd_lobs_rec.program_tag,
          l_fnd_lobs_rec.file_data,
          l_fnd_lobs_rec.LANGUAGE,
          l_fnd_lobs_rec.oracle_charset,
          l_fnd_lobs_rec.file_format;
        CLOSE fnd_lobs_cur;

        IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
          Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
                   'Inserting into fnd_lobs for
                    document id = '||docrec.document_id);
        END IF;

        INSERT INTO fnd_lobs (
          file_id,
          file_name,
          file_content_type,
          upload_date,
          expiration_date,
          program_name,
          program_tag,
          file_data,
          LANGUAGE,
          oracle_charset,
          file_format)
        VALUES  (
          l_media_id_tmp,
          l_fnd_lobs_rec.file_name,
          l_fnd_lobs_rec.file_content_type,
          l_fnd_lobs_rec.upload_date,
          l_fnd_lobs_rec.expiration_date,
          l_fnd_lobs_rec.program_name,
          l_fnd_lobs_rec.program_tag,
          l_fnd_lobs_rec.file_data,
          l_fnd_lobs_rec.LANGUAGE,
          l_fnd_lobs_rec.oracle_charset,
          l_fnd_lobs_rec.file_format);

       l_media_id_tmp := '';

      END IF;  -- end of duplicating text

    END IF;   --  end if usage_type = 'O' and datatype in (1,2,6,5)


    IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Statement,
               'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
               'Inserting into fnd_attached_documents for
                document id = '||docrec.document_id);
    END IF;

    --  Create attachment record
    INSERT INTO fnd_attached_documents
      (attached_document_id,
      document_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      seq_num,
      entity_name,
      pk1_value,
      pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      automatically_added_flag,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      attribute_category,
      attribute1,  attribute2,
      attribute3,  attribute4,
      attribute5,  attribute6,
      attribute7,  attribute8,
      attribute9,  attribute10,
      attribute11, attribute12,
      attribute13, attribute14,
      attribute15,
      column1)
      (SELECT
      fnd_attached_documents_s.NEXTVAL,
      docrec.document_id,
      SYSDATE,
      Fnd_Global.user_id,
      SYSDATE,
      Fnd_Global.user_id,
      Fnd_Global.user_id,
      docrec.seq_num,
      entity_name,
      TO_CHAR(p_new_ro_id),
      pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      'Y',
      program_application_id,
      program_id,
      SYSDATE,
      request_id,
      docrec.attribute_category,
      docrec.attribute1,  docrec.attribute2,
      docrec.attribute3,  docrec.attribute4,
      docrec.attribute5,  docrec.attribute6,
      docrec.attribute7,  docrec.attribute8,
      docrec.attribute9,  docrec.attribute10,
      docrec.attribute11, docrec.attribute12,
      docrec.attribute13, docrec.attribute14,
      docrec.attribute15,
      docrec.column1
      FROM fnd_attached_documents
      WHERE attached_document_id = docrec.attached_document_id);

  END LOOP;  --  end of working through all attachments

  IF (shorttext%ISOPEN) THEN
    CLOSE shorttext;
  END IF;

  IF (longtext%ISOPEN) THEN
    CLOSE longtext;
  END IF;

  IF (fnd_lobs_cur%ISOPEN) THEN
    CLOSE fnd_lobs_cur;
  END IF;

  -- Api body ends here

  -- Standard check of p_commit.
  IF Fnd_Api.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  Fnd_Msg_Pub.Count_And_Get
  (p_count   => x_msg_count,
   p_data    => x_msg_data);

  IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
               'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
               'Copy Attachments completed successfully ');
  END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO Copy_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_ERROR ;
    Fnd_Msg_Pub.Count_And_Get
     (p_count  =>  x_msg_count,
      p_data   =>  x_msg_data
    );
    IF ( Fnd_Log.LEVEL_ERROR >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_ERROR,
               'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
               'EXC_ERROR ['||x_msg_data||']');
    END IF;

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Copy_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
    Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

    IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
               'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
               'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO Copy_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
    IF  Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
      Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;
    Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

    IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
               'CSD.PLSQL.csd_repairs_pvt.copy_attachments',
               'SQL Message ['||SQLERRM||']');
    END IF;

END Copy_Attachments;


/*------------------------------------------------------------------*/
/* procedure name: Delete_Attachments                               */
/* description   : This procedure deletes all the attachements      */
/*                 linked with the repair line id.                  */
/*                                                                  */
/* p_api_version                Standard IN  param                  */
/* p_commit                     Standard IN  param                  */
/* p_init_msg_list              Standard IN  param                  */
/* p_validation_level           Standard IN  param                  */
/* p_repair_line_id             Repair Line Id                      */
/* x_return_status              Standard OUT param                  */
/* x_msg_count                  Standard OUT param                  */
/* x_msg_data                   Standard OUT param                  */
/*                                                                  */
/*------------------------------------------------------------------*/
PROCEDURE Delete_Attachments
  (p_api_version           IN          NUMBER,
   p_commit                IN          VARCHAR2,
   p_init_msg_list         IN          VARCHAR2,
   p_validation_level      IN          NUMBER,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_repair_line_id        IN          NUMBER)
IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attachments';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_debug_level            NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
  l_procedure_level        NUMBER := Fnd_Log.LEVEL_PROCEDURE;
  l_statement_level        NUMBER := Fnd_Log.LEVEL_STATEMENT;
  l_event_level            NUMBER := Fnd_Log.LEVEL_EVENT;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_Attachments;

  IF(Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Entered Delete_Attachments API');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Validate Repair line id = '||p_repair_line_id);
  END IF;

  IF NOT (Csd_Process_Util.Validate_rep_line_id
            ( p_repair_line_id => p_repair_line_id)) THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Validation of Repair line id completed successfully');
  END IF;

  --
  -- Begin API Body
  --

  --  Delete from FND_DOCUMENTS_SHORT_TEXT table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_documents_short_text');
  END IF;

  IF(Fnd_Log.Level_Event >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Event,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Started Deleting of Attachments');
  END IF;


  DELETE FROM fnd_documents_short_text
  WHERE media_id IN
    (SELECT fdtl.media_id
     FROM fnd_documents_tl fdtl,
       fnd_documents fd,
          fnd_attached_documents fad
     WHERE fdtl.document_id = fd.document_id
     AND fd.document_id = fad.document_id
     AND fd.usage_type  = 'O'
     AND fd.datatype_id = 1
     AND fad.pk1_value  = TO_CHAR(p_repair_line_id));

  --  Delete from FND_DOCUMENTS_LONG_TEXT table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_documents_long_text');
  END IF;

  DELETE FROM fnd_documents_long_text
  WHERE media_id IN
    (SELECT fdtl.media_id
     FROM fnd_documents_tl fdtl,
       fnd_documents fd,
          fnd_attached_documents fad
     WHERE fdtl.document_id = fd.document_id
     AND fd.document_id = fad.document_id
     AND fd.usage_type  = 'O'
     AND fd.datatype_id = 2
     AND fad.pk1_value  = TO_CHAR(p_repair_line_id));

  --  Delete from FND_DOCUMENTS_LONG_RAW table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_documents_long_raw');
  END IF;

  DELETE FROM fnd_documents_long_raw
  WHERE media_id IN
    (SELECT fdtl.media_id
     FROM fnd_documents_tl fdtl,
       fnd_documents fd,
          fnd_attached_documents fad
     WHERE fdtl.document_id = fd.document_id
     AND fd.document_id = fad.document_id
     AND fd.usage_type  = 'O'
     AND fd.datatype_id IN (3,4)
     AND fad.pk1_value  = TO_CHAR(p_repair_line_id));


  --  Delete from FND_LOBS table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_lobs');
  END IF;

  DELETE FROM fnd_lobs
  WHERE file_id IN
    (SELECT fdtl.media_id
     FROM fnd_documents_tl fdtl,
       fnd_documents fd,
          fnd_attached_documents fad
     WHERE fdtl.document_id = fd.document_id
     AND fd.document_id = fad.document_id
     AND fd.usage_type  = 'O'
     AND fd.datatype_id = 6
     AND fad.pk1_value  = TO_CHAR(p_repair_line_id));

  --  Delete from FND_DOCUMENTS_TL table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_documents_tl');
  END IF;

  DELETE FROM fnd_documents_tl
  WHERE document_id IN
  (SELECT fad.document_id
   FROM fnd_attached_documents fad, fnd_documents fd
   WHERE fad.document_id = fd.document_id
   AND fd.usage_type   = 'O'
   AND fad.pk1_value   = TO_CHAR(p_repair_line_id));

  --  Delete from FND_DOCUMENTS table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_documents');
  END IF;

  DELETE FROM fnd_documents
  WHERE usage_type = 'O'
  AND document_id IN
  (SELECT document_id
   FROM fnd_attached_documents fad
   WHERE fad.pk1_value = TO_CHAR(p_repair_line_id));

  --  delete from FND_ATTACHED_DOCUMENTS table
  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Deleting from fnd_attached_documents');
  END IF;

  DELETE FROM fnd_attached_documents fad
  WHERE  fad.pk1_value = TO_CHAR(p_repair_line_id);

  -- Api body ends here

  -- Standard check of p_commit.
  IF Fnd_Api.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  Fnd_Msg_Pub.Count_And_Get
  (p_count   => x_msg_count,
   p_data    => x_msg_data);

  IF(Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                   'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
                   'Delete_Attachments completed successfully');
  END IF;

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO Delete_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_ERROR ;
    Fnd_Msg_Pub.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data
       );
    IF ( Fnd_Log.LEVEL_ERROR >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_ERROR,
               'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
               'EXC_ERROR ['||x_msg_data||']');
    END IF;

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Delete_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
    Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

    IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
               'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
               'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Attachments;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
    IF  Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
      Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;
    Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

    IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
               'CSD.PLSQL.csd_repairs_pvt.delete_attachments',
               'SQL Message ['||SQLERRM||']');
    END IF;


END Delete_Attachments;


-- R12 development changes begin...
--   *******************************************************
--   API Name:  update_ro_status
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version               IN     NUMBER,
--     p_commit                    IN     VARCHAR2,
--     p_init_msg_list             IN     VARCHAR2,
--     p_validation_level          IN     NUMBER,
--     p_repair_status_rec         IN     CSD_REPAIRS_PUB.REPAIR_STATUS_REC,
--     p_status_control_rec        IN     CSD_REPAIRS_PUB.STATUS_UPD_CONTROL_REC,
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--     x_object_version_number     OUT     NUMBER
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API updates the repair status to a given value.
--                 It checks for the open tasks/wipjobs based on the input
--                 flag p_check_task_wip in the status control record.
--
--
-- ***********************************************************
   PROCEDURE UPDATE_RO_STATUS
   (
      p_api_version               IN     NUMBER,
      p_commit                    IN     VARCHAR2,
      p_init_msg_list             IN     VARCHAR2,
      p_validation_level          IN     NUMBER,
      x_return_status             OUT    NOCOPY    VARCHAR2,
      x_msg_count                 OUT    NOCOPY    NUMBER,
      x_msg_data                  OUT    NOCOPY    VARCHAR2,
      p_repair_status_Rec         IN     Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
      p_status_control_rec        IN     Csd_Repairs_Pub.STATUS_UPD_CONTROL_REC_TYPE,
      x_object_version_number     OUT NOCOPY     NUMBER
   ) IS
      l_api_version_number   CONSTANT NUMBER                 := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)          := 'UPDATE_RO_STATUS';
      C_CLOSED_STATE         CONSTANT VARCHAR2 (1)           := 'C';
      l_return_status                 VARCHAR2 (1) ;
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
    l_incident_id                   NUMBER;
    l_repair_type_id                NUMBER;
    l_object_version_number         NUMBER;
    l_repair_status_Rec             Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE;

      --Define cursors

    --Get the flow status id from csd_repairs
    CURSOR ro_details_cur(p_repair_line_id NUMBER) IS
    SELECT FLOW_STATUS_ID, REPAIR_TYPE_ID
    FROM CSD_REPAIRS
    WHERE REPAIR_LINE_ID = p_repair_line_id;

    -- Get state, state is the status_code in the scehma. status is flow_status
    CURSOR flow_stat_cur(p_repair_status_id VARCHAR2) IS
    SELECT STATUS_CODE
    FROM CSD_FLOW_STATUSES_B
    WHERE FLOW_STATUS_ID = p_repair_status_id;


   BEGIN
   --------------------Standard stuff -------------------------
      IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level) THEN
      Fnd_Log.STRING (Fnd_Log.level_procedure,
               'csd.plsql.csd_repairs_pvt.update_ro_status.begin',
               'Entering update_ro_status private api');
      END IF;
      IF Fnd_Api.to_boolean (p_init_msg_list) THEN
         Fnd_Msg_Pub.initialize;
      END IF;
      IF NOT Fnd_Api.compatible_api_call(l_api_version_number, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      SAVEPOINT update_ro_status_pvt;

        l_repair_status_Rec := p_repair_status_rec;

   ------------Convert Values to Id----------------------------------------------
      IF (Fnd_Log.level_event >= Fnd_Log.g_current_runtime_level) THEN
          Fnd_Log.STRING (Fnd_Log.level_event,
                  'csd.plsql.csd_repairs_pvt.update_ro_status',
                  '-----step 1: Value to Id conversion');
        END IF;
      Csd_Repairs_Util.Convert_Status_Val_To_Id(p_repair_status_rec,
                              l_repair_status_rec,
                              l_return_status);

   ------------Default/Validate Input parameters----------------------------------------------
      IF (Fnd_Log.level_event >= Fnd_Log.g_current_runtime_level) THEN
          Fnd_Log.STRING (Fnd_Log.level_event,
                  'csd.plsql.csd_repairs_pvt.update_ro_status',
                  '-----step 2: Validate input ');
        END IF;

      IF (Fnd_Log.level_event >= Fnd_Log.g_current_runtime_level) THEN
          Fnd_Log.STRING (Fnd_Log.level_event,
                  'csd.plsql.csd_repairs_pvt.update_ro_status',
                  '-----step 3: get required repair order values for update private api,ro['
                  ||l_repair_status_rec.repair_line_id||'],status['
                  ||l_repair_status_rec.repair_status||']');

      END IF;

      OPEN ro_details_cur(l_repair_status_rec.repair_line_id);
      FETCH ro_Details_cur INTO l_repair_status_rec.from_status_id, l_repair_type_id;
      IF(ro_details_cur%NOTFOUND) THEN
         CLOSE ro_details_cur;
         Fnd_Message.SET_NAME('CSD','CSD_INVALID_REPAIR_ORDER');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE ro_details_cur;

      OPEN flow_stat_cur(l_repair_status_Rec.repair_status_id);
      FETCH flow_stat_cur INTO l_repair_status_rec.repair_state;
      IF(flow_stat_cur%NOTFOUND) THEN
         CLOSE flow_stat_cur;
         Fnd_Message.SET_NAME('CSD','CSD_INVALID_FLOW_STATUS');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE flow_stat_cur;

      IF (Fnd_Log.level_event >= Fnd_Log.g_current_runtime_level) THEN
          Fnd_Log.STRING (Fnd_Log.level_event,
                  'csd.plsql.csd_repairs_pvt.update_ro_status',
                  '-----step 4: Checking for open jobs/tasks,ro['
                  ||l_repair_status_rec.repair_line_id||'],state['
                  ||l_repair_status_rec.repair_state||']');
      END IF;
   ------------Validate Input parameters: record level validation------------------------------
      IF(p_status_control_Rec.check_task_wip = 'Y') THEN

         Csd_Repairs_Util.CHECK_TASK_N_WIPJOB (
            p_repair_line_id =>  l_repair_status_rec.repair_line_id,
            p_repair_status  =>  l_repair_status_rec.repair_state,
            x_return_status  =>  l_return_status,
            x_msg_count      =>  l_msg_count,
            x_msg_data       =>  l_msg_data  );

         IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;


      END IF;


   ------------Call other private api to perform the status update------------------------------
      /*----------------------Vinay says the api update_flow_Status has logic to close ro status.*/
         IF (Fnd_Log.level_event >= Fnd_Log.g_current_runtime_level) THEN
             Fnd_Log.STRING (Fnd_Log.level_event,
                     'csd.plsql.csd_repairs_pvt.update_ro_status',
                     '-----step 5a: Calling another private api to validate and update status');
         END IF;
         Csd_Repairs_Pvt.UPDATE_FLOW_STATUS (
               p_api_version            => 1.0,
               p_commit                 => Fnd_api.g_false,
               p_init_msg_list          => Fnd_Api.g_false,
               p_validation_level       => Fnd_Api.g_valid_level_full,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data,
               p_repair_line_id       => l_repair_status_rec.repair_line_id,
               p_repair_type_id       => l_repair_type_id,
               p_from_flow_status_id    => l_repair_status_rec.from_status_id,
               p_to_flow_status_id      => l_repair_status_rec.repair_status_id,
               p_reason_code            => l_repair_status_rec.reason_code,
               p_comments               => l_repair_status_rec.comments,
               p_check_access_flag      => 'Y',
               p_object_version_number  => l_repair_status_rec.object_version_number,
               x_object_version_number  => x_object_version_number) ;

         IF(l_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         END IF;


       -- Api body ends here

       -- Standard check of p_commit.
       IF Fnd_Api.to_boolean (p_commit) THEN
          COMMIT WORK;
       END IF;

       -- Standard call to get message count and IF count is  get message info.
       Fnd_Msg_Pub.count_and_get (p_count => x_msg_count, p_data  => x_msg_data);

       IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level) THEN
          Fnd_Log.STRING (Fnd_Log.level_procedure,
                  'csd.plsql.csd_repairs_pvt.update_ro_status',
                  'Leaving update_ro_Status private api');
       END IF;

      EXCEPTION
       WHEN Fnd_Api.g_exc_error
       THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          ROLLBACK TO update_ro_status_pvt;
          Fnd_Msg_Pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
          IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level) THEN
           Fnd_Log.STRING (Fnd_Log.level_error,
                     'csd.plsql.csd_repairs_pvt.update_ro_status',
                     'EXC_ERROR[' || x_msg_data || ']');
          END IF;
       WHEN Fnd_Api.g_exc_unexpected_error
       THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          ROLLBACK TO update_ro_status_pvt;
          Fnd_Msg_Pub.count_and_get (p_count      => x_msg_count, p_data       => x_msg_data);

          IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level) THEN
           Fnd_Log.STRING (Fnd_Log.level_exception,
                     'csd.plsql.csd_repairs_pvt.update_ro_status',
                     'EXC_UNEXP_ERROR[' || x_msg_data || ']');
          END IF;
       WHEN OTHERS
       THEN
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          ROLLBACK TO update_ro_status_pvt;

          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
           Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
          END IF;

          Fnd_Msg_Pub.count_and_get (p_count  => x_msg_count, p_data => x_msg_data);

          IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level) THEN
           Fnd_Log.STRING (Fnd_Log.level_exception,
                     'csd.plsql.csd_repairs_pvt.update_ro_status',
                     'SQL MEssage[' || SQLERRM || ']');
          END IF;
   END UPDATE_RO_STATUS;

   PROCEDURE Update_Flow_Status (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT   NOCOPY    VARCHAR2,
      x_msg_count             OUT   NOCOPY    NUMBER,
      x_msg_data              OUT   NOCOPY    VARCHAR2,
      p_repair_line_id     IN NUMBER,
      p_repair_type_id     IN NUMBER,
      p_from_flow_status_id   IN    NUMBER,
      p_to_flow_status_id  IN    NUMBER,
      p_reason_code     IN    VARCHAR2,
      p_comments        IN    VARCHAR2,
      p_check_access_flag  IN    VARCHAR2,
      p_object_version_number IN    NUMBER,
      x_object_version_number OUT   NOCOPY    NUMBER
      ) IS

   -- CONSTANTS --
   lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIRS_PVT.update_flow_status';
   lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_Flow_Status';
   lc_api_version           CONSTANT NUMBER         := 1.0;
   lc_update_fs_event_code  CONSTANT VARCHAR2(5)   := 'SC';
   lc_status_code_closed    CONSTANT VARCHAR2(1)   := 'C';

   -- VARIABLES --
   l_flwsts_tran_id         NUMBER := NULL;
   l_wf_item_type           VARCHAR2(8) := NULL;
   l_wf_process_name        VARCHAR2(30) := NULL;
   l_reason_required_flag   VARCHAR2(1) := NULL;
   l_capture_activity_flag  VARCHAR2(1) := NULL;
   l_allow_all_resp_flag    VARCHAR2(1) := NULL;
   l_to_status_code         VARCHAR2(30) := NULL;
   l_to_flow_status_code    VARCHAR2(30) := NULL;
   l_from_flow_status_code  VARCHAR2(30) := NULL;
   l_wf_item_key            VARCHAR2(240) := NULL;

   l_flwsts_wf_rec          Flwsts_Wf_Rec_Type;
   l_ro_status_bevent_rec   RO_STATUS_BEVENT_REC_TYPE;
   l_repair_milestone_rec   CSD_REPAIR_MILESTONES_PVT.REPAIR_MILESTONE_REC_TYPE;

   x_repair_history_id      NUMBER;
   x_repair_milestone_id    NUMBER;
   l_reason_meaning         VARCHAR2(80) := NULL;

   -- CURSOR --
   -- Gets all flow status transition details.
   CURSOR c_get_trans_details IS
   SELECT FS_TRANS.flwsts_tran_id,
          FS_TRANS.wf_item_type,
          FS_TRANS.wf_process_name,
          FS_TRANS.reason_required_flag,
          FS_TRANS.capture_activity_flag,
          FS_TRANS.allow_all_resp_flag,
          TO_FS_B.status_code,
          TO_FS_B.flow_status_code to_flow_status_code,
          FROM_FS_B.flow_status_code from_flow_status_code
   FROM   CSD_FLWSTS_TRANS_B FS_TRANS,
          CSD_FLOW_STATUSES_B TO_FS_B,
          CSD_FLOW_STATUSES_B FROM_FS_B
   WHERE  FS_TRANS.from_flow_status_id = p_from_flow_status_id AND
          FS_TRANS.to_flow_status_id = p_to_flow_status_id AND
          FS_TRANS.repair_type_id = p_repair_type_id AND
          TO_FS_B.flow_status_id = FS_TRANS.to_flow_status_id AND
          FROM_FS_B.flow_status_id = FS_TRANS.from_flow_status_id;

   -- Query to validate the reason code
   CURSOR c_check_status_reason IS
      SELECT  RSN_LKUP.meaning reason
      FROM    FND_LOOKUPS RSN_LKUP
      WHERE
              RSN_LKUP.lookup_type = 'CSD_REASON' AND
              RSN_LKUP.lookup_code = p_reason_code AND
              RSN_LKUP.enabled_flag = 'Y' AND
              TRUNC(SYSDATE) BETWEEN
              TRUNC(NVL(RSN_LKUP.start_date_active, SYSDATE)) AND
              TRUNC(NVL(RSN_LKUP.end_date_active, SYSDATE));

   -- Query to get all milestones codes
   CURSOR c_get_flwsts_miles (p_flwsts_tran_id NUMBER) IS
      SELECT milestone_code
      FROM   CSD_FLWSTS_TRAN_MILES
      WHERE  flwsts_tran_id = p_flwsts_tran_id;

   -- swai: bug 6937272( FP of 6882484)
   -- Query to get current object version number of repair order
   CURSOR c_get_object_version_number (p_repair_line_id NUMBER) IS
      SELECT object_version_number
      FROM   CSD_REPAIRS
      WHERE  repair_line_id = p_repair_line_id;

  BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT  Update_Flow_Status;

       -- Standard call to check for call compatibility.
       IF NOT Fnd_Api.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
           Fnd_Msg_Pub.initialize;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Update_Flow_Status');
       END IF;

       -- Initialize API return status to success
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

       -- Api body starts

       -- STEP 1: Validate Mandatory Parameters.

       -- Check the required parameters
       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       END IF;

       -- Check the required parameters
       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_repair_line_id,
         p_param_name     => 'P_REPAIR_LINE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_from_flow_status_id,
         p_param_name     => 'P_FROM_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

	  -- 5362259, p_flow_status_id will be checked later
   /*    Csd_Process_Util.Check_Reqd_Param
    *   ( p_param_value    => p_to_flow_status_id,
    *     p_param_name     => 'P_TO_FLOW_STATUS_ID',
    *     p_api_name    => lc_api_name);
    */

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_repair_type_id,
         p_param_name     => 'P_REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_object_version_number,
         p_param_name     => 'P_OBJECT_VERSION_NUMBER',
         p_api_name    => lc_api_name);


       -- STEP 2: Validate transition details, if one exists.
       -- 5362259, check to_flow_status_id
       IF P_TO_FLOW_STATUS_ID IS NULL THEN
	    -- "Unable to update repair status. A new status is required for the transition."
	    Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_TO_STATUS_REQD');
	    Fnd_Msg_Pub.ADD;
	    RAISE Fnd_Api.G_EXC_ERROR;
	  END IF;


       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Cursor c_get_trans_flags');
       END IF;

       OPEN c_get_trans_details;
       FETCH c_get_trans_details INTO l_flwsts_tran_id,
                                      l_wf_item_type,
                                      l_wf_process_name,
                                      l_reason_required_flag,
                                      l_capture_activity_flag,
                                      l_allow_all_resp_flag,
                                      l_to_status_code,
                                      l_to_flow_status_code,
                                      l_from_flow_status_code;
       CLOSE c_get_trans_details;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'After calling Cursor c_get_trans_details');
       END IF;

       -- Validate whether the set up exists for transition of
       -- FROM flow status to TO flow status for the repair_type_id
       -- In the process, also check if the return
       -- reason is required.
       IF l_to_status_code IS NULL THEN
          -- "Unable to update repair status. The status transition
          -- is not valid for the current repair type."
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_INVALID');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_reason_required_flag = 'Y') AND (p_reason_code IS NULL) THEN
          -- "Unable to update repair status. A reason is required for the transition."
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_REASON_REQD');
          Fnd_Msg_Pub.ADD;
		-- 5362259, chaging exception from G_EXC_UNEXPECTED_ERROR to G_EXC_ERROR
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- STEP 3: Check access if requested.

       -- We do not need to call the 'update allowed' function if the
       -- 'all resp' have access or we are requested to skip the check.
       IF (l_allow_all_resp_flag <> 'Y' AND p_check_access_flag = 'Y') THEN

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                             'Calling Is_Flwsts_Update_Allowed');
          END IF;

          IF NOT Is_Flwsts_Update_Allowed(p_repair_type_id => p_repair_type_id,
                                          p_from_flow_status_id => p_from_flow_status_id,
                                          p_to_flow_status_id => p_to_flow_status_id,
                                          p_responsibility_id  => Fnd_Global.resp_id
                                         ) THEN
             -- Unable to update repair status. The user does not
             -- have access to update the repair status.
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_NO_ACCESS');
             Fnd_Msg_Pub.ADD;
		   -- rfieldma, 5494587,
		   -- changing exception from G_EXC_UNEXPECTED_ERROR
		   -- to G_EXC_ERROR so that the extra developer's error
		   -- won't show.
             RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                             'After calling Is_Flwsts_Update_Allowed');
          END IF;
       END IF;

       -- STEP 4: Validate reason code.

       -- Validate reason code if passed
       IF p_reason_code IS NOT NULL THEN

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
             Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                          'Calling Cursor c_check_status_reason');
          END IF;

          OPEN c_check_status_reason;
          FETCH c_check_status_reason INTO l_reason_meaning;
          CLOSE c_check_status_reason;

          IF l_reason_meaning IS NULL THEN
             -- "Unable to update repair status.
             -- Invalid reason selected for the transition."
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_INVD_REASON');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       -- STEP 5: Launch Workflow.

       IF (l_wf_item_type IS NOT NULL) THEN

          SELECT TO_CHAR(CSD_WF_ITEM_KEY_S.NEXTVAL)
          INTO l_wf_item_key
          FROM DUAL;

          l_flwsts_wf_rec.repair_line_id := p_repair_line_id;
          l_flwsts_wf_rec.repair_type_id := p_repair_type_id;
          l_flwsts_wf_rec.from_flow_status_id := p_from_flow_status_id;
          l_flwsts_wf_rec.to_flow_status_id := p_to_flow_status_id;
          l_flwsts_wf_rec.object_version_number := p_object_version_number;
          l_flwsts_wf_rec.wf_item_type := l_wf_item_type;
          l_flwsts_wf_rec.wf_item_key := l_wf_item_key;
          l_flwsts_wf_rec.wf_process_name := l_wf_process_name;

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
             Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                          'Calling Launch_Flwsts_Wf');
          END IF;

          Launch_Flwsts_Wf (
                            p_api_version => 1.0,
                            p_commit => Fnd_Api.G_FALSE,
                            p_init_msg_list => Fnd_Api.G_FALSE,
                            p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                            x_return_status  => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            p_flwsts_wf_rec => l_flwsts_wf_rec
                           );

          IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
             -- "Unable to update repair status.
             -- Failed to create the workflow process."
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_WF_FAIL');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

       END IF;

       -- STEP 6: Update CSD_REPAIRS with status details.

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling update Repairs');
       END IF;

       --BEGIN

          UPDATE CSD_REPAIRS
          SET    flow_status_id = p_to_flow_status_id,
                 status = l_to_status_code,
                 status_reason_code = p_reason_code,
                 date_closed = DECODE(l_to_status_code, 'C', SYSDATE, NULL),
                 wf_item_key = NVL(l_wf_item_key, wf_item_key),
                 wf_item_type = NVL(l_wf_item_type, wf_item_type),
                 last_updated_by = Fnd_Global.USER_ID,
                 last_update_date = SYSDATE,
                 last_update_login = Fnd_Global.LOGIN_ID,
                 object_version_number = object_version_number + 1
          WHERE  repair_line_id = p_repair_line_id AND
                 flow_status_id = p_from_flow_status_id; -- swai: bug 6937272 (FP of 6882484)
                 -- object_version_number = p_object_version_number;

          --x_object_version_number := p_object_version_number + 1;

       --EXCEPTION
          -- Repair Order does not exist or user is
          -- trying to update older version.
          --WHEN NO_DATA_FOUND THEN
             -- Unable to update repair status. Another user may have
             -- updated the repair order. Please requery the
             -- original data and try again.
             --Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_OLD_VERSION');
             --Fnd_Msg_Pub.ADD;
             --RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       --END;

       if(sql%rowcount > 0) then
            -- swai: bug 6937272 (FP of 6882484)
            -- x_object_version_number := p_object_version_number + 1;
            OPEN c_get_object_version_number(p_repair_line_id);
            FETCH c_get_object_version_number INTO x_object_version_number;
            CLOSE c_get_object_version_number;
       else
             --debug('object_Version mismatch');
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_OLD_VERSION');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       end if;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'After calling update Repairs');
       END IF;

       -- STEP 7: Log 'Status Change' activity.

       -- Log an activity if setup to do so.
       IF l_capture_activity_flag = 'Y' THEN

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
             Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                          'Calling Repair History to log activity');
          END IF;


          Csd_To_Form_Repair_History.Validate_And_Write
             (p_Api_Version_Number => 1.0 ,
              p_init_msg_list => Fnd_Api.G_FALSE,
              p_commit => Fnd_Api.G_FALSE,
              p_validation_level => NULL,
              p_action_code => 0,
              px_REPAIR_HISTORY_ID => x_repair_history_id,
              p_OBJECT_VERSION_NUMBER       => NULL,
              p_REQUEST_ID    => NULL,
              p_PROGRAM_ID    => NULL,
              p_PROGRAM_APPLICATION_ID    => NULL,
              p_PROGRAM_UPDATE_DATE   => NULL,
              p_CREATED_BY    => Fnd_Global.USER_ID,
              p_CREATION_DATE => SYSDATE,
              p_LAST_UPDATED_BY  => Fnd_Global.USER_ID,
              p_LAST_UPDATE_DATE => SYSDATE,
              p_repair_line_id => p_repair_line_id,
              p_EVENT_CODE => lc_update_fs_event_code,
              p_EVENT_DATE => SYSDATE,
              -- p_QUANTITY  => p_quantity,
              p_PARAMN1     =>   NULL,
              p_PARAMN2    =>    NULL,
              p_PARAMN3    => NULL,
              p_PARAMN10   => Fnd_Global.USER_ID,
              p_PARAMC1    => l_to_flow_status_code,
              p_PARAMC2    => l_from_flow_status_code,
              p_PARAMC3    => l_reason_meaning,
              p_PARAMC4    => NULL,
              p_PARAMC5    => NULL,
              p_PARAMC6    => p_comments,
              p_PARAMC7    => l_wf_item_type,
              p_PARAMC8    => l_wf_item_key,
              p_PARAMC9    => l_wf_process_name,
              p_LAST_UPDATE_LOGIN    => Fnd_Global.CONC_LOGIN_ID,
              X_Return_Status        => x_return_status,
              X_Msg_Count            => x_msg_count,
              X_Msg_Data             => x_msg_data
              );

          IF x_return_status <> 'S' THEN
             -- Unable to update repair status. Adding repair activity
             -- process has failed.
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_ACTY_FAIL');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

       END IF;

       -- STEP 8: Close SR if RO is closed.
       -- The procedure will check if all ROs are closed
       -- and then, based on a profile, close SR.

   --debug('update_flow_status: Step 8');

       IF l_to_status_code = lc_status_code_closed THEN

          -- Incident Id must be NULL.
          Csd_Process_Pvt.Close_status
          ( p_api_version           => 1.0,
            p_commit                => Fnd_Api.G_FALSE,
            p_init_msg_list         => Fnd_Api.G_FALSE,
            p_validation_level      => Csd_Process_Util.G_VALID_LEVEL_FULL,
            p_incident_id           => NULL,
            p_repair_line_id        => p_repair_line_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
          );

          IF x_return_status <> 'S' THEN
             -- Unable to update repair status. Adding repair activity
             -- process has failed.
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_SR_FAIL');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       -- STEP 9: Launch the Business Event.
       -- Business Event is always launched (not optional).
   --debug('update_flow_status: Step 9');

       l_ro_status_bevent_rec.repair_line_id := p_repair_line_id;
       l_ro_status_bevent_rec.from_flow_status_id := p_from_flow_status_id;
       l_ro_status_bevent_rec.to_flow_status_id := p_to_flow_status_id;
       l_ro_status_bevent_rec.object_version_number := p_object_version_number;

       raise_ro_status_bevent
          ( p_ro_status_bevent_rec  => l_ro_status_bevent_rec,
            p_commit                => Fnd_Api.G_FALSE,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
          );
   --debug('update_flow_status: Step 10');

       IF x_return_status <> 'S' THEN
          -- Unable to update repair status. Failed
          -- to Initialize the business event.
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_BE_FAIL');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

   --debug('update_flow_status: Step 11');

       -- STEP 10: Log all milestones events for the transition.

       l_repair_milestone_rec.repair_line_id := p_repair_line_id;
       -- All event will have same datetime.
       l_repair_milestone_rec.milestone_date := SYSDATE;
       l_repair_milestone_rec.object_version_number := 1;

       FOR i_rec in c_get_flwsts_miles(l_flwsts_tran_id) LOOP
          -- Only code changes for each event.
          l_repair_milestone_rec.milestone_code := i_rec.milestone_code;

   --debug('update_flow_status: Step 12');
          CSD_REPAIR_MILESTONES_PVT.Create_Repair_Milestone
            ( p_api_version           => 1.0,
              p_commit                => Fnd_Api.G_FALSE,
              p_init_msg_list         => Fnd_Api.G_FALSE,
              p_validation_level      => Csd_Process_Util.G_VALID_LEVEL_FULL,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
              p_repair_milestone_rec  => l_repair_milestone_rec,
              x_repair_milestone_id   => x_repair_milestone_id
            );
   --debug('update_flow_status: Step 12');
       END LOOP;

      -- Api body ends here

   --debug('update_flow_status: Step 13');
      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;
   --debug('update_flow_status: Step 14');

      -- Standard call to get message count and IF count is  get message info.
      Fnd_Msg_Pub.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
        Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Update_Flow_Status');
      END IF;

  EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO Update_Flow_Status;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Flow_Status;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Update_Flow_Status;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||SQLERRM||']' );
          END IF;

   END Update_Flow_Status;


   FUNCTION Is_Rt_Update_Allowed (
      p_from_repair_type_id   IN    NUMBER,
      p_to_repair_type_id  IN    NUMBER,
      p_common_flow_status_id IN    NUMBER,
      p_responsibility_id  IN    NUMBER
      ) RETURN BOOLEAN IS

   -- CONSTANTS --
   lc_mod_name   CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIRS_PVT.Is_Rt_Update_Allowed';
   lc_api_name   CONSTANT VARCHAR2(30)   := 'Is_Rt_Update_Allowed';

   -- VARIABLES --
   l_dummy       VARCHAR2(1) := NULL;

   -- CURSORS --
   CURSOR c_is_rt_update_allowed IS
      SELECT  'x'
      FROM    CSD_RT_TRANS_B RT_B
      WHERE   RT_B.FROM_REPAIR_TYPE_ID = p_from_repair_type_id AND
              RT_B.TO_REPAIR_TYPE_ID = p_to_repair_type_id AND
              RT_B.COMMON_FLOW_STATUS_ID = p_common_flow_status_id AND
              ((RT_B.ALLOW_ALL_RESP_FLAG = 'Y') OR
                EXISTS
               (SELECT  'y'
                FROM    CSD_RT_TRAN_RESPS RESP
                WHERE   RESP.RT_TRAN_ID = RT_B.RT_TRAN_ID AND
                  RESP.RESPONSIBILITY_ID = p_responsibility_id)
              );

   BEGIN

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Is_Rt_Update_Allowed');
       END IF;

       -- Check the required parameters
       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       END IF;

       -- Check the required parameters
       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_from_repair_type_id,
         p_param_name     => 'P_FROM_REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_to_repair_type_id,
         p_param_name     => 'P_TO_REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_common_flow_status_id,
         p_param_name     => 'P_COMMON_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       OPEN c_is_rt_update_allowed;
       FETCH c_is_rt_update_allowed INTO l_dummy;
       CLOSE c_is_rt_update_allowed;

       -- If no records found then the responsibility
       -- does not have access to the transition
       IF l_dummy IS NULL THEN
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
         Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                        'Leaving Is_Rt_Update_Allowed');
       END IF;

   END Is_Rt_Update_Allowed;

   PROCEDURE Update_Repair_Type (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT   NOCOPY    VARCHAR2,
      x_msg_count             OUT   NOCOPY    NUMBER,
      x_msg_data              OUT   NOCOPY    VARCHAR2,
      p_repair_line_id        IN    NUMBER,
      p_from_repair_type_id   IN    NUMBER,
      p_to_repair_type_id  IN    NUMBER,
      p_common_flow_status_id IN    NUMBER,
      p_reason_code     IN    VARCHAR2,
      p_object_version_number IN    NUMBER,
      x_object_version_number OUT   NOCOPY NUMBER
      ) IS

   -- CONSTANTS --
   lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIRS_PVT.update_repair_type';
   lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_Repair_Type';
   lc_api_version           CONSTANT NUMBER         := 1.0;
   lc_update_rt_event_code  CONSTANT VARCHAR2(5)   := 'RTU';

   -- VARIABLES --
   l_reason_required_flag   VARCHAR2(1) := NULL;
   l_capture_activity_flag  VARCHAR2(1) := NULL;
   x_repair_history_id      NUMBER;
   l_dummy                  VARCHAR2(80) := NULL;
   l_from_repair_type       VARCHAR2(80);
   l_to_repair_type         VARCHAR2(80);

   -- CURSOR --
   CURSOR c_get_trans_flags IS
   SELECT RT_TRANS.reason_required_flag,
          RT_TRANS.capture_activity_flag
   FROM   CSD_RT_TRANS_B RT_TRANS
   WHERE  RT_TRANS.from_repair_type_id = p_from_repair_type_id AND
          RT_TRANS.to_repair_type_id = p_to_repair_type_id AND
          RT_TRANS.common_flow_status_id = p_common_flow_status_id;

   -- Query to validate the reason code
   CURSOR c_check_rt_reason IS
      SELECT  meaning
      FROM    FND_LOOKUPS RSN_LKUP
      WHERE
              RSN_LKUP.lookup_type = 'CSD_RT_TRANSITION_REASONS' AND
              RSN_LKUP.lookup_code = p_reason_code AND
              RSN_LKUP.enabled_flag = 'Y' AND
              TRUNC(SYSDATE) BETWEEN
              TRUNC(NVL(RSN_LKUP.start_date_active, SYSDATE)) AND
              TRUNC(NVL(RSN_LKUP.end_date_active, SYSDATE));

  -- Query to derive from and to repair type name
   CURSOR c_get_repair_types IS
      SELECT  CRTV.name name1, CRTV1.name name2
      FROM    CSD_REPAIR_TYPES_Vl CRTV, CSD_REPAIR_TYPES_Vl CRTV1
      WHERE
              CRTV.REPAIR_TYPE_Id = p_from_repair_type_id AND
              CRTV1.REPAIR_TYPE_Id = p_to_repair_type_id;

  BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT  Update_Repair_Type;

       -- Standard call to check for call compatibility.
       IF NOT Fnd_Api.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
           Fnd_Msg_Pub.initialize;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Update_Repair_Type');
       END IF;

       -- Initialize API return status to success
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       END IF;

       -- Check the required parameters
       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_repair_line_id,
         p_param_name     => 'P_REPAIR_LINE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_from_repair_type_id,
         p_param_name     => 'P_FROM_REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

	-- 5362259, repair type will be handled later with appropriate msg
     /*  Csd_Process_Util.Check_Reqd_Param
      * ( p_param_value    => p_to_repair_type_id,
      *   p_param_name     => 'P_TO_REPAIR_TYPE_ID',
      *   p_api_name    => lc_api_name);
	 */

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_common_flow_status_id,
         p_param_name     => 'P_COMMON_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_object_version_number,
         p_param_name     => 'P_OBJECT_VERSION_NUMBER',
         p_api_name    => lc_api_name);


       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Cursor c_get_trans_flags');
       END IF;

       OPEN c_get_trans_flags;
       FETCH c_get_trans_flags INTO l_reason_required_flag, l_capture_activity_flag;
       CLOSE c_get_trans_flags;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'After calling Cursor c_get_trans_flags');
       END IF;

       -- 5362259, validate p_to_repair_type_id and show error msg
	  IF (p_to_repair_type_id IS NULL) THEN
	  	-- "Unable to update repair type. A new repair type is required for the transition."
	  	Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_TO_RT_REQD');
	  	Fnd_Msg_Pub.ADD;
	  	RAISE Fnd_Api.G_EXC_ERROR;
	  END IF;


       -- Validate whether the set up exists for transition of
       -- FROM repair type to TO repair type for the current flow_status_id
       -- in CSD_REPAIRS. In the process, also check if the return
       -- reason is required.
       IF l_reason_required_flag IS NULL THEN
          -- "Unable to update repair type. The repair type transition
          -- is not valid for the current status."
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_TRANS_INVALID');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_reason_required_flag = 'Y') AND (p_reason_code IS NULL) THEN
          -- "Unable to update repair type. A reason is required for the transition."
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_REASON_REQD');
          Fnd_Msg_Pub.ADD;
		--5362259, changing exeception from G_EXC_UPEXPECTED_ERROR to G_EXC_ERROR
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Is_Rt_Update_Allowed');
       END IF;

       IF NOT Is_Rt_Update_Allowed(p_from_repair_type_id => p_from_repair_type_id,
                                   p_to_repair_type_id => p_to_repair_type_id,
                                   p_common_flow_status_id => p_common_flow_status_id,
                                   p_responsibility_id  => Fnd_Global.resp_id
                                  ) THEN
          -- Unable to update repair type. The user does not
          -- have access to update the repair type.
          Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_TRANS_NO_ACCESS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'After calling Is_Rt_Update_Allowed');
       END IF;


       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Cursor c_check_rt_reason');
       END IF;

       -- Validate reason code if passed
       IF p_reason_code IS NOT NULL THEN
          OPEN c_check_rt_reason;
          FETCH c_check_rt_reason INTO l_dummy;
          CLOSE c_check_rt_reason;

          IF l_dummy IS NULL THEN
             -- "Unable to update repair type.
             -- Invalid reason selected for the transition."
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_INVD_REASON');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'calling update for Repair Type');
       END IF;

       BEGIN

          UPDATE CSD_REPAIRS
          SET    repair_type_id = p_to_repair_type_id,
                 last_updated_by = Fnd_Global.USER_ID,
                 last_update_date = SYSDATE,
                 last_update_login = Fnd_Global.LOGIN_ID,
                 object_version_number = object_version_number + 1
          WHERE  repair_line_id = p_repair_line_id AND
                 object_version_number = p_object_version_number;

          x_object_version_number := p_object_version_number + 1;

       EXCEPTION
          -- Repair Order does not exist or user is
          -- trying to update older version.
          WHEN NO_DATA_FOUND THEN
             -- Unable to update repair type. Another user may have
             -- updated the repair order. Please requery the
             -- original data and try again.
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_TRANS_OLD_VERSION');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'After calling update for Repair Type');
       END IF;

       -- Log an activity if setup to do so.
       IF l_capture_activity_flag = 'Y' THEN

          IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
             Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                          'Calling Repair History to log activity');
          END IF;

      OPEN c_get_repair_types;
          FETCH c_get_repair_types INTO l_from_repair_type, l_to_repair_type;
          CLOSE c_get_repair_types;

        /*  Csd_To_Form_Repair_History.Validate_And_Write
             (p_Api_Version_Number       => 1.0 ,
              p_init_msg_list            => 'F',
              p_commit                   => 'F',
              p_validation_level         => NULL,
              p_action_code              => 0,
              px_REPAIR_HISTORY_ID       => x_repair_history_id,
              p_OBJECT_VERSION_NUMBER    => NULL,
              p_repair_line_id           => p_repair_line_id,
              p_EVENT_CODE               => lc_update_rt_event_code,
              p_EVENT_DATE               => SYSDATE,
              p_PARAMN1                  => p_from_repair_type_id,
              p_PARAMN2                  => p_to_repair_type_id,
              p_PARAMN3                  => Fnd_Global.USER_ID,
              p_PARAMC1                  => p_reason_code,
              X_Return_Status            => x_return_status,
              X_Msg_Count                => x_msg_count,
              X_Msg_Data                 => x_msg_data
             );*/
          Csd_To_Form_Repair_History.Validate_And_Write
             (p_Api_Version_Number       => 1.0 ,
           p_init_msg_list            => 'F',
           p_commit                   => 'F',
           p_validation_level         => NULL,
           p_action_code              => 0,
           px_REPAIR_HISTORY_ID       => x_repair_history_id,
           p_OBJECT_VERSION_NUMBER    => NULL,
           p_REQUEST_ID               => NULL,
           p_PROGRAM_ID               => NULL,
           p_PROGRAM_APPLICATION_ID   => NULL,
           p_PROGRAM_UPDATE_DATE      => NULL,
           p_CREATED_BY               => 1,
           p_CREATION_DATE            => SYSDATE,
           p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_DATE         => SYSDATE,
           p_repair_line_id           => p_repair_line_id,
           p_EVENT_CODE               => 'RTU',
           p_EVENT_DATE               => SYSDATE,
           p_QUANTITY                 => NULL,
           p_PARAMN1                  => p_from_repair_type_id,
           p_PARAMN2                  => p_to_repair_type_id,
           p_PARAMN3                  => fnd_global.user_id,--NULL,
           p_PARAMN4                  => NULL,
           p_PARAMN5                  => NULL,
           p_PARAMN6                  => NULL,
           p_PARAMN7                  => NULL,
           p_PARAMN8                  => NULL,
           p_PARAMN9                  => NULL,
           p_PARAMN10                 => NULL,
           p_PARAMC1                  => p_reason_code,
           p_PARAMC2                  => l_dummy, -- reason
           p_PARAMC3                  => l_from_repair_type,
           p_PARAMC4                  => l_to_repair_type,
           p_PARAMC5                  => NULL,
           p_PARAMC6                  => NULL,
           p_PARAMC7                  => NULL,
           p_PARAMC8                  => NULL,
           p_PARAMC9                  => NULL,
           p_PARAMC10                 => NULL,
           p_PARAMD1                  => NULL,
           p_PARAMD2                  => NULL,
           p_PARAMD3                  => NULL,
           p_PARAMD4                  => NULL,
            p_PARAMD5                  => NULL,
           p_PARAMD6                  => NULL,
           p_PARAMD7                  => NULL,
           p_PARAMD8                  => NULL,
           p_PARAMD9                  => NULL,
           p_PARAMD10                 => NULL,
           p_ATTRIBUTE_CATEGORY       => NULL,
           p_ATTRIBUTE1               => NULL,
           p_ATTRIBUTE2               => NULL,
           p_ATTRIBUTE3               => NULL,
           p_ATTRIBUTE4               => NULL,
           p_ATTRIBUTE5               => NULL,
           p_ATTRIBUTE6               => NULL,
           p_ATTRIBUTE7               => NULL,
           p_ATTRIBUTE8               => NULL,
           p_ATTRIBUTE9               => NULL,
           p_ATTRIBUTE10              => NULL,
           p_ATTRIBUTE11              => NULL,
           p_ATTRIBUTE12              => NULL,
           p_ATTRIBUTE13              => NULL,
           p_ATTRIBUTE14              => NULL,
           p_ATTRIBUTE15              => NULL,
           p_LAST_UPDATE_LOGIN        => FND_GLOBAL.CONC_LOGIN_ID,
            X_Return_Status            => x_return_status,
           X_Msg_Count                => x_msg_count,
           X_Msg_Data                 => x_msg_data
          );


          IF x_return_status <> 'S' THEN
             -- Unable to update repair type. Adding repair activity
             -- process has failed.
             Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_ACTIVITY_FAILED');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

       END IF;

      -- Api body ends here

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      Fnd_Msg_Pub.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
        Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Update_Repair_Type');
      END IF;

  EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO Update_Repair_Type;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Repair_Type;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Update_Repair_Type;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||SQLERRM||']' );
          END IF;

END Update_Repair_Type;

   FUNCTION Is_Flwsts_Update_Allowed(
      p_repair_type_id     IN    NUMBER,
      p_from_flow_status_id   IN    NUMBER,
      p_to_flow_status_id  IN    NUMBER,
      p_responsibility_id     IN    NUMBER
      ) RETURN BOOLEAN IS

   -- CONSTANTS --
   lc_mod_name   CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIRS_PVT.Is_Flwsts_Update_Allowed';
   lc_api_name   CONSTANT VARCHAR2(30)   := 'Is_Flwsts_Update_Allowed';

   -- VARIABLES --
   l_dummy       VARCHAR2(1) := NULL;

   -- CURSORS --
   CURSOR c_is_flwsts_update_allowed IS
      SELECT  'x'
      FROM    CSD_FLWSTS_TRANS_B RT_B
      WHERE   RT_B.FROM_FLOW_STATUS_ID = p_from_flow_status_id AND
              RT_B.TO_FLOW_STATUS_ID = p_to_flow_status_id AND
              RT_B.REPAIR_TYPE_ID = p_repair_type_id AND
              (
               (RT_B.ALLOW_ALL_RESP_FLAG = 'Y') OR
                EXISTS
               (SELECT 'y'
                FROM   CSD_FLWSTS_TRAN_RESPS RESP
                WHERE  RESP. FLWSTS_TRAN_ID = RT_B.FLWSTS_TRAN_ID AND
                       RESP.RESPONSIBILITY_ID = p_responsibility_id)
              );

   BEGIN

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Is_Flwsts_Update_Allowed');
       END IF;

       -- Check the required parameters
       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       END IF;

       -- Check the required parameters
       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_from_flow_status_id,
         p_param_name     => 'P_FROM_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_to_flow_status_id,
         p_param_name     => 'P_TO_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_repair_type_id,
         p_param_name     => 'P_REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

       OPEN c_is_flwsts_update_allowed;
       FETCH c_is_flwsts_update_allowed INTO l_dummy;
       CLOSE c_is_flwsts_update_allowed;

       -- If no records found then the responsibility
       -- does not have access to the transition
       IF l_dummy IS NULL THEN
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
         Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                        'Leaving Is_Flwsts_Update_Allowed');
       END IF;

   END Is_Flwsts_Update_Allowed;

   PROCEDURE Launch_Flwsts_Wf (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT   NOCOPY    VARCHAR2,
      x_msg_count             OUT   NOCOPY    NUMBER,
      x_msg_data              OUT   NOCOPY    VARCHAR2,
      p_flwsts_wf_rec         IN    Flwsts_Wf_Rec_Type
      ) IS

   -- CONSTANTS --
   lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIRS_PVT.launch_flwsts_wf';
   lc_api_name              CONSTANT VARCHAR2(30)   := 'Launch_Flwsts_Wf';
   lc_api_version           CONSTANT NUMBER         := 1.0;

   -- For setting WF engine threshold
   lc_wf_negative_threshold CONSTANT NUMBER         := -1;

   -- For WF Item Attributes
   lc_repair_line_id        CONSTANT VARCHAR2(30)   := 'CSD_REPAIR_LINE_ID';
   lc_repair_type_id        CONSTANT VARCHAR2(30)   := 'CSD_REPAIR_TYPE_ID';
   lc_from_flow_status_id   CONSTANT VARCHAR2(30)   := 'CSD_FROM_FLOW_STATUS_ID';
   lc_to_flow_status_id     CONSTANT VARCHAR2(30)   := 'CSD_TO_FLOW_STATUS_ID';
   lc_object_version_number CONSTANT VARCHAR2(30)   := 'CSD_OBJECT_VERSION_NUMBER';

   -- VARIABLES --
   l_wf_current_threshold  NUMBER := NULL;

   l_wf_aname_TabType    Wf_Engine.NameTabTyp;
   l_wf_avalue_TabType   Wf_Engine.NumTabTyp;

  BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT  Launch_Flwsts_Wf;

       -- Standard call to check for call compatibility.
       IF NOT Fnd_Api.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name,
                                           G_PKG_NAME)
       THEN
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
           Fnd_Msg_Pub.initialize;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Launch_Flwsts_Wf');
       END IF;

       -- Initialize API return status to success
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       END IF;

       -- Check the required parameters
       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.repair_line_id,
         p_param_name     => 'REPAIR_LINE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.repair_type_id,
         p_param_name     => 'REPAIR_TYPE_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.from_flow_status_id,
         p_param_name     => 'FROM_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.to_flow_status_id,
         p_param_name     => 'TO_FLOW_STATUS_ID',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.object_version_number,
         p_param_name     => 'OBJECT_VERSION_NUMBER',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.wf_item_type,
         p_param_name     => 'WF_ITEM_TYPE',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.wf_item_key,
         p_param_name     => 'WF_ITEM_KEY',
         p_api_name    => lc_api_name);

       Csd_Process_Util.Check_Reqd_Param
       ( p_param_value    => p_flwsts_wf_rec.wf_process_name,
         p_param_name     => 'WF_PROCESS_NAME',
         p_api_name    => lc_api_name);

       -- Get the current threshold
       l_wf_current_threshold := Wf_Engine.threshold;

       -- Defer the wf process
       Wf_Engine.threshold := lc_wf_negative_threshold;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling WF_ENGINE.CreateProcess');
       END IF;

       Wf_Engine.CreateProcess(itemtype => p_flwsts_wf_rec.wf_item_type,
                               itemkey => p_flwsts_wf_rec.wf_item_key,
                               process => p_flwsts_wf_rec.wf_process_name --,
                               -- user_key => NULL,
                               -- owner_role => NULL
                               );

       l_wf_aname_TabType(1) := lc_repair_line_id;
       l_wf_avalue_TabType(1) := p_flwsts_wf_rec.repair_line_id;

       l_wf_aname_TabType(2) := lc_repair_type_id;
       l_wf_avalue_TabType(2) := p_flwsts_wf_rec.repair_type_id;

       l_wf_aname_TabType(3) := lc_from_flow_status_id;
       l_wf_avalue_TabType(3) := p_flwsts_wf_rec.from_flow_status_id;

       l_wf_aname_TabType(4) := lc_to_flow_status_id;
       l_wf_avalue_TabType(4) := p_flwsts_wf_rec.to_flow_status_id;

       l_wf_aname_TabType(5) := lc_object_version_number;
       l_wf_avalue_TabType(5) := p_flwsts_wf_rec.object_version_number;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling WF_ENGINE.AddItemAttrNumberArray to add attributes');
       END IF;

       Wf_Engine.AddItemAttrNumberArray(itemtype => p_flwsts_wf_rec.wf_item_type,
                                        itemkey => p_flwsts_wf_rec.wf_item_key,
                                        aname => l_wf_aname_TabType,
                                        avalue => l_wf_avalue_TabType
                                        );


/*
       WF_ENGINE.AddItemAttr (itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key,
                              aname => lc_repair_line_id,
                              number_value => p_flwsts_wf_rec.repair_line_id
                              );

       WF_ENGINE.AddItemAttr (itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key,
                              aname => lc_repair_type_id,
                              number_value => p_flwsts_wf_rec.repair_type_id
                              );

       WF_ENGINE.AddItemAttr (itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key,
                              aname => lc_from_flow_status_id,
                              number_value => p_flwsts_wf_rec.from_flow_status_id
                              );

       WF_ENGINE.AddItemAttr (itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key,
                              aname => lc_to_flow_status_id,
                              number_value => p_flwsts_wf_rec.to_flow_status_id
                              );

       WF_ENGINE.AddItemAttr (itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key,
                              aname => lc_object_version_number,
                              number_value => p_flwsts_wf_rec.object_version_number
                              );
*/

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling WF_ENGINE.StartProcess');
       END IF;

       -- The WF process is kicked off now in deferred mode
       Wf_Engine.StartProcess(itemtype => p_flwsts_wf_rec.wf_item_type,
                              itemkey => p_flwsts_wf_rec.wf_item_key
                              );


       -- Set engine to orginal threshold.
       -- Otherwise all WF process in this session will be deferred.
       Wf_Engine.threshold := l_wf_current_threshold;

      -- Api body ends here

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      Fnd_Msg_Pub.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
        Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Launch_Flwsts_Wf');
      END IF;

  EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO Launch_Flwsts_Wf;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Launch_Flwsts_Wf;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Launch_Flwsts_Wf;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||SQLERRM||']' );
          END IF;

END Launch_Flwsts_Wf;



--   *******************************************************
--   API Name:  UPDATE_RO_STATUS_WebSrvc
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version               IN     NUMBER,
--     p_commit                    IN     VARCHAR2,
--     p_init_msg_list             IN     VARCHAR2,
--     p_validation_level          IN     NUMBER,
--     p_repair_line_id           IN      NUMEBR
--     p_repair_status            IN
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API updates is a wrapper around the update_ro_Status
--                 private API. THis is used by the web service.
--
--
-- ***********************************************************
   PROCEDURE UPDATE_RO_STATUS_WEBSRVC
   (
      p_api_version               IN     NUMBER,
      p_commit                    IN     VARCHAR2,
      p_init_msg_list             IN     VARCHAR2,
      x_return_status             OUT    NOCOPY    VARCHAR2,
      x_msg_count                 OUT    NOCOPY    NUMBER,
      x_msg_data                  OUT    NOCOPY    VARCHAR2,
      p_repair_line_id            IN     NUMBER,
      p_repair_status             IN     VARCHAR2,
      p_reason_code               IN     VARCHAR2,
      p_comments                  IN     VARCHAR2,
      p_check_task_wip          IN     VARCHAR2,
      p_object_version_number     IN     NUMBER

    ) IS
    l_repair_status_rec      Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE;
    l_status_upd_control_rec Csd_Repairs_Pub.STATUS_UPD_CONTROL_REC_TYPE;
    l_object_Version_number   NUMBER;
    l_return_status          VARCHAR2(1);

  lc_mod_name  CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repairs_pvt.update_ro_status_websrvc';
  lc_api_name              CONSTANT VARCHAR2(30)   := 'update_ro_status_websrvc';
  lc_api_version           CONSTANT NUMBER         := 1.0;

    BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  UPDATE_RO_STATUS_WEBSRVC_PVT;

       -- Standard call to check for call compatibility.
       IF NOT Fnd_Api.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name,
                                           G_PKG_NAME)
       THEN
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;
	  --debug('security_group['||SYS_CONTEXT('FND','SECURITY_GROUP_ID')||']');
	  --debug('resp_id['||SYS_CONTEXT('FND','RESP_ID')||']');
	  --debug('resp_appl_id['||SYS_CONTEXT('FND','RESP_APPL_ID')||']');
	  --debug('operatingunit['||SYS_CONTEXT('FND','ORG_ID')||']');

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
           Fnd_Msg_Pub.initialize;
       END IF;

       IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
          Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered UPDATE_RO_STATUS_WEBSRVC');
       END IF;

      l_return_Status :=  Fnd_Api.G_RET_STS_SUCCESS;

	 --debug('In plsql api to update ro status for web service['||to_char(p_repair_line_id)||']');
      csd_repairs_util.Check_WebSrvc_Security(
               p_repair_line_id  => p_repair_line_id,
               x_return_status   => l_return_status);

      IF(l_return_Status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
             Fnd_Message.Set_Name('CSD', 'CSD_SECURITY_CHECK_FAILED');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

        l_repair_status_rec.repair_line_id  := p_repair_line_id;
        l_repair_status_rec.repair_status   := p_repair_status;
        l_repair_status_rec.reason_code     := p_reason_code;
        l_repair_status_rec.comments        := p_comments;
        l_repair_status_rec.object_version_number := p_object_version_number;

        l_status_upd_control_rec.check_task_wip := p_check_task_wip;

	   --debug('calling update_ro_status private api');
        Csd_Repairs_Pvt.UPDATE_RO_STATUS(P_Api_Version      => p_api_version,
                          P_Commit                => p_commit,
                          P_Init_Msg_List         => p_init_msg_list,
                          P_Validation_Level      => Fnd_Api.G_VALID_LEVEL_FULL,
                          X_Return_Status         => x_return_status,
                          X_Msg_Count             => x_msg_count,
                          X_Msg_Data              => x_msg_data,
                          P_REPAIR_STATUS_REC     => l_repair_status_rec,
                          P_STATUS_CONTROL_REC    => l_status_upd_control_rec,
                          X_OBJECT_VERSION_NUMBER => l_object_Version_number);
        --

      -- Standard check of p_commit.
      IF Fnd_Api.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      Fnd_Msg_Pub.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
        Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving UPDATE_RO_STATUS_WEBSRVC');
      END IF;

  EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO UPDATE_RO_STATUS_WEBSRVC_PVT;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO UPDATE_RO_STATUS_WEBSRVC_PVT;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO UPDATE_RO_STATUS_WEBSRVC_PVT;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  Fnd_Msg_Pub.Check_Msg_Level
              (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
              IF (Fnd_Log.LEVEL_STATEMENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                  Fnd_Log.STRING(Fnd_Log.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              END IF;
              Fnd_Msg_Pub.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          Fnd_Msg_Pub.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||SQLERRM||']' );
          END IF;

    END UPDATE_RO_STATUS_WebSrvc;

/*-----------------------------------------------------------------*/
/* procedure name: raise_ro_status_bevent                          */
/* description   : Procedure to raise a Business Even when the     */
/*                 status of the repair order changes              */
/*-----------------------------------------------------------------*/
 PROCEDURE Raise_RO_Status_BEvent
 (
   p_ro_status_bevent_rec  IN   ro_status_bevent_rec_type,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
 )
 IS

 l_event_key   Number;
 l_param_list  wf_parameter_list_t  := wf_parameter_list_t();
 l_param_t     wf_parameter_t       := wf_parameter_t(10,10);
 l_api_name    Varchar2(30) := 'RAISE_RO_STATUS_BEVENT';

 BEGIN

   Savepoint ro_status_bevent_savepoint;

   -- Initialize API return status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Derive the Event Key
   Select csd_ro_status_bevent_key_s1.nextval into l_event_key from dual ;

   -- Initialize Parameters
   l_param_list.extend;
   l_param_list(1) := wf_parameter_t('REPAIR_LINE_ID',p_ro_status_bevent_rec.repair_line_id);

   l_param_list.extend;
   l_param_list(2) := wf_parameter_t('FROM_STATUS_ID',p_ro_status_bevent_rec.from_flow_status_id);

   l_param_list.extend;
   l_param_list(3) := wf_parameter_t('TO_STATUS_ID',p_ro_status_bevent_rec.to_flow_status_id);

   l_param_list.extend;
   l_param_list(4) := wf_parameter_t('OBJECT_VERSION_NUMBER',p_ro_status_bevent_rec.object_version_number);

   -- Call to Raise the Business Event
   wf_event.raise
     ( p_event_name => 'oracle.apps.csd.repair.status.change',
       p_event_key  => l_event_key,
       p_parameters => l_param_list);

   -- Standard check of p_commit.
   If FND_API.To_Boolean( p_commit ) then
    commit;
   End if;

 EXCEPTION
  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To ro_status_bevent_savepoint;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );
 END;

-- R12 development changes End...


/*-------------------------------------------------------------------------------------*/
/* Procedure name: UPDATE_RO_STATUS_WF                                                 */
/* Description   : Procedure called from workflow process to update repair order       */
/*                 status                                                              */
/*                                                                                     */
/* Called from   : Workflow                                                            */
/* PARAMETERS                                                                          */
/*  IN                                                                                 */
/*                                                                                     */
/*   itemtype  - type of the current item                                              */
/*   itemkey   - key of the current item                                               */
/*   actid     - process activity instance id                                          */
/*   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)             */
/*  OUT	                                                                               */
/*   result                                                                            */
/*       - COMPLETE[:<result>]                                                         */
/*           activity has completed with the indicated result                          */
/*       - WAITING                                                                     */
/*           activity is waiting for additional transitions                            */
/*       - DEFERED                                                                     */
/*           execution should be defered to background                                 */
/*       - NOTIFIED[:<notification_id>:<assigned_user>]                                */
/*           activity has notified an external entity that this                        */
/*           step must be performed.  A call to wf_engine.CompleteActivty              */
/*           will signal when this step is complete.  Optional                         */
/*           return of notification ID and assigned user.                              */
/*       - ERROR[:<error_code>]                                                        */
/*           function encountered an error.                                            */
/* Change Hist :                                                                       */
/*   04/18/06  mshirkol  Initial Creation.  ( Fix for bug#5610891 )                    */
/*-------------------------------------------------------------------------------------*/

Procedure UPDATE_RO_STATUS_WF
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             resultout in out nocopy varchar2) IS

l_line_id               number;
l_repair_line_id        number;
l_return_status         varchar2(3);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_module_name           varchar2(80);

--bug#9284580
l_from_flow_status_id	number;
l_to_flow_status_id		number;
l_repair_type_id		number;
l_object_version_number number;
x_object_version_number number;
--bug#9284580

Cursor get_ro_details ( p_line_id in number ) is
select
  csd.repair_line_id
from
  cs_estimate_details est,
  csd_repairs csd
where
est.order_line_id = p_line_id
and est.original_source_id = csd.repair_line_id;

BEGIN

--bug#9284580
 -- set the return status
  l_return_status := fnd_api.g_ret_sts_success;
--bug#9284580

  IF ( funcmode = 'RUN' ) THEN

    l_line_id := to_number(itemkey);

    --
    -- Derive the wf roles for the Contact id
    --
    Open get_ro_details (l_line_id);
    Fetch get_ro_details into l_repair_line_id;
    Close get_ro_details;


--bug#9284580
	l_to_flow_status_id := fnd_profile.value('CSD_DEF_RO_STAT_FR_SHP');

	-- get the 'from' flow status id.
	--
	begin
		select distinct cr.flow_status_id,
			   cr.repair_type_id,
			   cr.object_version_number
		into  l_from_flow_status_id,
			  l_repair_type_id,
			  l_object_version_number
		from csd_repairs cr
		where cr.repair_line_id = l_repair_line_id;
		exception
			when no_data_found then
		  -- should never get in here.
			null;
	end;

	if l_to_flow_status_id <> l_from_flow_status_id then
		csd_repairs_pvt.update_flow_status(p_api_version        => 1.0,
									   p_commit               => fnd_api.g_false,
									   p_init_msg_list        => fnd_api.g_false,
									   p_validation_level     => fnd_api.g_valid_level_full,
									   x_return_status        => l_return_status,
									   x_msg_count            => l_msg_count,
									   x_msg_data             => l_msg_data,
									   p_repair_line_id       => l_repair_line_id,
									   p_repair_type_id       => l_repair_type_id,
									   p_from_flow_status_id  => l_from_flow_status_id,
									   p_to_flow_status_id    => l_to_flow_status_id,
									   p_reason_code          => null,
									   p_comments             => null,
									   p_check_access_flag    => 'Y',
									   p_object_version_number => l_object_version_number,
									   x_object_version_number => x_object_version_number );
	end if;
/*
    CSD_PROCESS_PVT.Close_status
    ( p_api_version           => 1.0,
      p_commit                => 'T',
      p_init_msg_list         => 'T',
      p_validation_level      => CSD_PROCESS_UTIL.G_VALID_LEVEL_FULL,
      p_incident_id           => NULL,
      p_repair_line_id        => l_repair_line_id,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data
     );
*/
--bug#9284580

    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      resultout := 'COMPLETE:ERROR';

      l_module_name := 'UPDATE_RO_STATUS';

      CSD_REPAIRS_PVT.LAUNCH_WFEXCEPTION_BEVENT(
                         p_return_status  => l_return_status,
                         p_msg_count      => l_msg_count,
                         p_msg_data       => l_msg_data,
                         p_repair_line_id => l_repair_line_id,
                         p_module_name    => l_module_name);

    ELSE
      resultout := 'COMPLETE:SUCCESS';
    END IF;

    return;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.CONTEXT('CSD_REPAIRS_PVT','UPDATE_RO_STATUS_WF',itemtype,
                  itemkey,to_char(actid),funcmode);
  raise;
END;

/*-------------------------------------------------------------------------------------*/
/* Procedure name: LAUNCH_WFEXCEPTIONS_BEVENT                                          */
/* Description   : Procedure to launch exceptions Business Event                       */
/*                                                                                     */
/* Called from   : CSD_UPDATE_PROGRAMS_PVT                                             */
/* PARAMETERS                                                                          */
/*  IN                                                                                 */
/*   p_return_status                                                                   */
/*   p_msg_count                                                                       */
/*   p_msg_data                                                                        */
/*   p_repair_line_id                                                                  */
/*   p_module_name                                                                     */
/*                                                                                     */
/* Change Hist :                                                                       */
/*   04/18/06  mshirkol  Initial Creation.  ( Fix for bug#5610891 )                    */
/*-------------------------------------------------------------------------------------*/
Procedure LAUNCH_WFEXCEPTION_BEVENT(
               p_return_status  in varchar2,
               p_msg_count      in number,
               p_msg_data       in varchar2,
               p_repair_line_id in number,
               p_module_name    in varchar2) IS

l_msg                varchar2(2000);
l_next_msg           varchar2(2000);
l_event_key          number;
l_parameter_list     wf_parameter_list_t := wf_parameter_list_t();
l_event_name         varchar2(60) := 'oracle.apps.csd.repair.wfprocess.exceptions';
l_message_code       varchar2(3);

Cursor get_event_key is
select CSD_WF_EXCEPTIONS_BEVENT_S1.nextval from dual;

BEGIN

  -- Derive the message from the message stack
  l_msg          := p_msg_data;
  l_message_code := p_return_status;

  IF p_msg_count = 1 THEN

    IF l_msg is null then
      l_msg :=  fnd_msg_pub.get(p_msg_index => 1,
                                p_encoded   => FND_API.G_FALSE );
    ELSE
      l_next_msg := fnd_msg_pub.get(p_msg_index => 1,
                                    p_encoded   => FND_API.G_FALSE );

      l_msg := substr(l_msg ||'-'||rtrim(l_next_msg),1,2000);
    END IF;

  ELSIF p_msg_count > 1 THEN

    FOR i in 1..p_msg_count LOOP

      IF l_msg is null THEN
        l_msg := fnd_msg_pub.get(p_msg_index => i,
                                 p_encoded   => FND_API.G_FALSE );
      ELSE
        l_next_msg := fnd_msg_pub.get(p_msg_index => i,
                                      p_encoded   => FND_API.G_FALSE );

        l_msg := substr(l_msg ||'-'||rtrim(l_next_msg),1,2000);

      END IF;

    END LOOP;

  END IF;


  -- Derive the event key
  -- Derive this value from sequence..
  Open  get_event_key;
  Fetch get_event_key into l_event_key;
  Close get_event_key;

  IF l_msg is null THEN
    l_msg := ' ';
  END IF;

  -- Initialize the Parameters
  l_parameter_list.extend;
  l_parameter_list(1):= wf_parameter_t('REPAIR_LINE_ID',to_char(p_repair_line_id));

  l_parameter_list.extend;
  l_parameter_list(2):= wf_parameter_t('MODULE_NAME',p_module_name);

  l_parameter_list.extend;
  l_parameter_list(3):= wf_parameter_t('MESSAGE_CODE',l_message_code);

  l_parameter_list.extend;
  l_parameter_list(4) := wf_parameter_t('MESSAGE_TEXT',l_msg);

  -- Call the Raise Event
  wf_event.raise(
       p_event_name => l_event_name,
       p_event_key  => l_event_key,
       p_parameters => l_parameter_list);

  commit;

END;

END Csd_Repairs_Pvt;

/
