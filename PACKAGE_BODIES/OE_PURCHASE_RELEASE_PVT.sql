--------------------------------------------------------
--  DDL for Package Body OE_PURCHASE_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PURCHASE_RELEASE_PVT" AS
/* $Header: OEXVDSPB.pls 120.14.12010000.4 2010/01/28 09:15:59 spothula ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Purchase_Release_PVT';


/*-----------------------------------------------------------------
PROCEDURE  : OELOGO
DESCRIPTION: Writes Values to the concurrent program log file
-----------------------------------------------------------------*/
Procedure OELOGO(p_drop_ship_line_rec IN Drop_Ship_Line_Rec_Type,
                 p_mode               IN VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF (p_mode = G_MODE_CONCURRENT) THEN
       fnd_file.put_line(FND_FILE.LOG, 'Line ID =  '|| p_drop_ship_line_rec.line_id);
       fnd_file.put_line(FND_FILE.LOG, 'Header ID =  '|| p_drop_ship_line_rec.header_id);
       fnd_file.put_line(FND_FILE.LOG, 'Source Type Code' || p_drop_ship_line_rec.source_type_code);
       fnd_file.put_line(FND_FILE.LOG, 'Project Id' || p_drop_ship_line_rec.project_id);
       fnd_file.put_line(FND_FILE.LOG, 'Task Id ' || p_drop_ship_line_rec.task_id);
       fnd_file.put_line(FND_FILE.LOG, 'End Item Unit Number ' || p_drop_ship_line_rec.end_item_unit_number);
       fnd_file.put_line(FND_FILE.LOG, 'Employee Id' || p_drop_ship_line_rec.employee_id);
       fnd_file.put_line(FND_FILE.LOG, 'Inventory_Item_Id' || p_drop_ship_line_rec.inventory_item_id);
       fnd_file.put_line(FND_FILE.LOG, 'Charge Account Id ' || p_drop_ship_line_rec.charge_account_id);
  END IF;
END;
/*-----------------------------------------------------------------
PROCEDURE  : Purchase_Release
DESCRIPTION: For the each record that is passed to this procedure,
             it will do the following:
             1. Check for holds on the record
             2. If not on holds, check for valid location
             3. If location is valid, check for valid user
             4. If user is valid, insert into PO_REQUISITION_INTERFACE and
                OE_DROP_SHIP_SOURCES tables
             This program will be called as a concurrent program or from the
             workflow.
-----------------------------------------------------------------*/

Procedure Purchase_Release
(    p_api_version_number            IN  NUMBER
,    p_drop_ship_tbl                 IN  Drop_Ship_Tbl_Type
,    p_mode                          IN  VARCHAR2 := G_MODE_ONLINE
, x_drop_ship_tbl OUT NOCOPY Drop_Ship_Tbl_Type

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

)
IS

  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30):= 'Purchase Release';
  l_drop_ship_line_rec          Drop_Ship_Line_Rec_Type;
  l_drop_ship_tbl               Drop_Ship_Tbl_Type;
  l_x_drop_ship_tbl             Drop_Ship_Tbl_Type;
  l_drop_ship_source_id         NUMBER;
  l_invoke_verify_payment       VARCHAR2(1) := 'Y';
  l_return_status               VARCHAR2(1);
  l_result                      Varchar2(30);
  l_count                       NUMBER;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000) := NULL;
  l_user_id                     NUMBER;
  l_resp_id                     NUMBER;
  l_application_id              NUMBER;
  l_org_id                      NUMBER;
  l_org_id2                     NUMBER;
  l_login_id                    NUMBER;
  l_request_id                  NUMBER;
  l_program_id                  NUMBER;
  l_old_header_id               NUMBER;
  l_payment_type                VARCHAR2(50);
  l_item_type_code              VARCHAR2(30);
  l_ato_line_id                 NUMBER;
  -- For Process Order
  l_line_rec                    OE_ORDER_PUB.line_rec_type;
  l_old_line_tbl                OE_ORDER_PUB.line_tbl_type;
  l_line_tbl                    OE_ORDER_PUB.line_tbl_type;
  l_control_rec                 OE_GLOBALS.control_rec_type;

  l_valid_employee              VARCHAR2(25);
  l_temp_employee_Id            NUMBER;    -- Temp ID got from profile option
  l_order_source_id             NUMBER;
  l_source_document_type_id     NUMBER;
  item_purchase_enabled         VARCHAR2(1);  -- Fix for bug2097383
  v_tmp NUMBER;
  v_request_date                DATE;
  l_shippable_flag              VARCHAR2(1);
  l_ou_id                       NUMBER; -- R12.MOAC
  l_exists                      varchar2(1); -- added for bug 7433481

  Purchase_Release_Incomplete   EXCEPTION;

  Cursor C_Check_Employee_ID (x_employee_id NUMBER) IS
	    SELECT 'Yes '
	    FROM   PER_WORKFORCE_CURRENT_X --hr_employees_current_v 9281079
	    WHERE  person_id = x_employee_id;
  Cursor C_Payment_Type(x_header_id NUMBER) IS
	    SELECT payment_type_code
	    FROM   oe_order_headers
	    WHERE  header_id = x_header_id;
  Cursor Req_Date  (v_line_id NUMBER) is
            SELECT REQUEST_DATE
            FROM   OE_ORDER_LINES
            WHERE  LINE_ID = v_line_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Entering Purchase Release' , 1 ) ;
   END IF;

   IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_drop_ship_tbl := p_drop_ship_tbl;

   -- l_user_id            := FND_GLOBAL.USER_ID; -- Commented for bug 6118936
   l_login_id           := FND_GLOBAL.LOGIN_ID;
   l_request_id         := FND_GLOBAL.CONC_REQUEST_ID;
   -- l_application_id     := FND_GLOBAL.RESP_APPL_ID; -- Commented for bug 6118936
   l_program_id         := FND_GLOBAL.CONC_PROGRAM_ID;
   -- l_resp_id            := FND_GLOBAL.RESP_ID; -- Commented for bug 6118936
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
   l_org_id2            := FND_PROFILE.VALUE('OE_ORGANIZATION_ID');
   l_org_id             := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('User id => ' ||l_user_id,1);
       oe_debug_pub.add('Responsibility id => ' ||l_resp_id,1);
       oe_debug_pub.add('Application id => ' ||l_application_id,1);
       oe_debug_pub.add('Organization id => ' ||l_org_id,1);
   END IF;

   l_old_header_id := 0;

   FOR I IN 1..l_drop_ship_tbl.COUNT LOOP
   BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Processing Line ID : '||l_drop_ship_tbl(i).line_id,1);
      END IF;
      l_drop_ship_line_rec := l_drop_ship_tbl(I);


/* Added for the bug 6118936 */

      l_user_id := wf_engine.GetItemAttrNumber( OE_GLOBALS.G_WFI_LIN , to_char(l_drop_ship_line_rec.line_id) , 'USER_ID');
      l_resp_id := wf_engine.GetItemAttrNumber( OE_GLOBALS.G_WFI_LIN , to_char(l_drop_ship_line_rec.line_id) , 'RESPONSIBILITY_ID');
      l_application_id := wf_engine.GetItemAttrNumber( OE_GLOBALS.G_WFI_LIN , to_char(l_drop_ship_line_rec.line_id) , 'APPLICATION_ID');


      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('User id => ' ||l_user_id,1);
       oe_debug_pub.add('Responsibility id => ' ||l_resp_id,1);
       oe_debug_pub.add('Application id => ' ||l_application_id,1);
       oe_debug_pub.add('Organization id => ' ||l_org_id,1);
      END IF;

/* End of bug 6118936 */


      IF FND_PROFILE.VALUE('ONT_INCLUDED_ITEM_FREEZE_METHOD') = OE_GLOBALS.G_IIFM_PICK_RELEASE THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('may need to freeze inc items',5);
         END IF;

         SELECT item_type_code, ato_line_id
         INTO   l_item_type_code, l_ato_line_id
         FROM   oe_order_lines
         WHERE  line_id = l_drop_ship_line_rec.line_id;

         IF (l_item_type_code = 'MODEL' OR
            l_item_type_code = 'KIT' OR
            l_item_type_code = 'CLASS') AND
            l_ato_line_id is NULL THEN

            l_return_status := OE_Config_Util.Freeze_Included_Items (l_drop_ship_line_rec.line_id);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Freeze ret status '||l_return_status,5);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE Purchase_Release_Incomplete;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

      END IF;

      IF l_drop_ship_line_rec.header_id <> l_old_header_id THEN
	    l_invoke_verify_payment := 'Y';
	    l_old_header_id := l_drop_ship_line_rec.header_id;
      END IF;
      OELOGO(p_drop_ship_line_rec => l_drop_ship_line_rec,
             p_mode               => p_mode);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Source Type Code => '||l_drop_ship_line_rec.source_type_code,5);
      END IF;
      IF (l_drop_ship_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_SERVICE) THEN
	 OPEN C_Payment_Type(l_drop_ship_line_rec.header_id);
	 FETCH C_Payment_Type INTO l_payment_type;
	 CLOSE C_Payment_Type;

	 --IF l_payment_type = 'CREDIT_CARD' THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('before calling verify payment ',1);
            END IF;
	    IF l_invoke_verify_payment = 'Y' THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Before calling verify payment for header '||to_char(l_drop_ship_line_rec.header_id),1);
               END IF;

	       OE_VERIFY_PAYMENT_PUB.VERIFY_PAYMENT(
	          p_header_id         => l_drop_ship_line_rec.header_id,
		  p_calling_action    => 'PICKING',
		  p_delayed_request   => NULL,
                  p_return_status     => l_return_status,
                  p_msg_count         => l_msg_count,
                  p_msg_data          => l_msg_data);

               l_invoke_verify_payment := 'N';

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Exception: verify payment returns failure',1);
                  END IF;
                  OE_MSG_PUB.Add_Text(p_message_text => l_msg_data);--bug4683857
                  OE_MSG_PUB.Save_API_Messages;  --bug4683857
                  IF l_return_status = FND_API.G_RET_STS_ERROR then
                     RAISE Purchase_Release_Incomplete;
                  ELSE
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;
         END IF;
      --END IF; -- for 2412678

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('After the call to verify payment ',5);
      END IF;

      /* Check if there are holds on this line or its header,
         If yes, bypass this line */

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calling check holds including activity based holds',5);
      END IF;
      OE_Holds_PUB.Check_Holds
         (   p_api_version       => 1.0
            ,p_init_msg_list     => FND_API.G_FALSE
            ,p_commit            => FND_API.G_FALSE
            ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status     => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data          => l_msg_data
            ,p_line_id           => l_drop_ship_line_rec.line_id
            ,p_hold_id           => NULL
            ,p_entity_code       => NULL
            ,p_entity_id         => NULL
            ,p_wf_item           => 'OEOL'
            ,p_wf_activity       => 'PUR_REL_THE_LINE'
            ,x_result_out        => l_result);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('After calling check holds return status => '||l_return_status,1);
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Return result => '||l_result,1);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

         OE_MSG_PUB.Add_Text(p_message_text => l_msg_data);--bug4683857
         OE_MSG_PUB.Save_API_Messages;    --bug4683857
         IF l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE Purchase_Release_Incomplete;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF (l_result = FND_API.G_TRUE) then
         FND_MESSAGE.SET_NAME('ONT','OE_II_HOLD_FOUND');
         OE_MSG_PUB.Add;
         l_drop_ship_line_rec.result   :=  OE_Purchase_Release_PVT.G_RES_ONHOLD;
         l_drop_ship_line_rec.return_status := FND_API.G_RET_STS_ERROR;
         RAISE Purchase_Release_Incomplete;
      END IF;
  END IF;/* If line is not a service line */

  IF l_drop_ship_line_rec.deliver_to_location_id is null THEN
     FND_MESSAGE.SET_NAME('ONT','OE_DS_NO_LOC_LINK');
     OE_MSG_PUB.Add;
     l_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exception, Deliver to Location is not setup correctly',1);
     END IF;
     RAISE  Purchase_Release_Incomplete;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Deliver to location => ' || l_drop_ship_line_rec.deliver_to_location_id,1);
  END IF;

  -- Check to see if the user who entered the order is a valid employee

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Employee id check '||l_drop_ship_line_rec.employee_id,1);
  END IF;
  OPEN C_Check_Employee_ID (l_drop_ship_line_rec.employee_id);
  FETCH C_Check_Employee_ID INTO l_valid_employee;
  CLOSE C_Check_Employee_ID;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Is this a valid employee ? '||l_valid_employee,1);
  END IF;

  IF l_valid_employee is null THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Invalid employee id. checking whether this is self-service order..',5);
     END IF;
     --R12.MOAC
     SELECT nvl(ORDER_SOURCE_ID,0),nvl(SOURCE_DOCUMENT_TYPE_ID,0),org_id
     INTO   l_order_source_id,l_source_document_type_id,l_ou_id
     FROM   OE_ORDER_HEADERS_ALL
     WHERE  HEADER_ID = l_drop_ship_line_rec.header_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Order source id for this order is '||to_char ( l_order_source_id ) , 5 ) ;
         oe_debug_pub.add('Source document type id for this order is '||to_char ( l_source_document_type_id ) , 5 ) ;
     END IF;
     IF l_order_source_id between 11 and 19 OR
	l_source_document_type_id between 11 and 19 THEN  -- 11 and 19 for self service orders
        --R12.MOAC Start
        -- Call to Oe_Sys_Parameters.Value as profile moved to system parameter
       /*
           -- changed call from fnd_profile.value to oe_profile.value to retrieve profile in created_by context
	   l_temp_employee_id := oe_profile.value(p_header_id => null,
                                                  p_line_id => l_drop_ship_line_rec.line_id,
                                                  p_profile_option_name => 'ONT_EMP_ID_FOR_SS_ORDERS');
      */
       l_temp_employee_id := Oe_Sys_Parameters.Value('ONT_EMP_ID_FOR_SS_ORDERS',l_ou_id);
       --R12.MOAC End
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Assigning employee id to this order as -> '||to_char ( l_temp_employee_id ),5);
           END IF;
	   l_drop_ship_line_rec.employee_id := l_temp_employee_id;
           OPEN C_Check_Employee_ID (l_temp_employee_id);
	   FETCH C_Check_Employee_ID INTO l_valid_employee;
	   CLOSE C_Check_Employee_ID;
     END IF;
  ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Employee id set for this order '||to_char ( l_drop_ship_line_rec.employee_id ),5);
     END IF;
  END IF;

  IF l_valid_employee is null THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('No records found for this employee id',1);
     END IF;
     FND_MESSAGE.SET_NAME('ONT','OE_DS_NOT_VALID_EMP');
     OE_MSG_PUB.Add;
     RAISE Purchase_Release_Incomplete;
  END IF;

  -- Fix for the bug2097383 and 2201362
  SELECT PURCHASING_ENABLED_FLAG
  INTO item_purchase_enabled
  FROM MTL_SYSTEM_ITEMS
  WHERE INVENTORY_ITEM_ID = l_drop_ship_line_rec.inventory_item_id
  AND ORGANIZATION_ID = l_drop_ship_line_rec.ship_from_org_id;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.add('Item Purchase Enabled : '||item_purchase_enabled,1);
  END IF;

  IF nvl(item_purchase_enabled,'N') <> 'Y' THEN
     FND_MESSAGE.SET_NAME('PO','PO_RI_INVALID_ITEM_SRC_VEND_P');
     OE_MSG_PUB.Add;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.add('Exception, item is not purchasing enabled',1);
     END IF;
     RAISE Purchase_Release_Incomplete;
  END IF;

  -- Fix for #2003381

  IF l_drop_ship_line_rec.schedule_ship_date is null THEN

     OPEN REQ_DATE (l_drop_ship_line_rec.line_id);
     FETCH REQ_DATE INTO v_request_date;
     CLOSE REQ_DATE;

     if v_request_date is null then
        -- raise error, request date cannot be null #2003381.
        FND_MESSAGE.SET_NAME('ONT','OE_REQUEST_DATE_FOR_PR_REQD');
        OE_MSG_PUB.Add;
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.add('Exception, Reqeust Date is either null or not valid',1);
        END IF;
        RAISE Purchase_Release_Incomplete;
     end if;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Source type code ' || l_drop_ship_line_rec.source_type_code , 1 ) ;
     oe_debug_pub.add('Item type code ' || l_drop_ship_line_rec.item_type_code , 1 ) ;
  END IF;


  IF NOT OE_GLOBALS.Equal(l_drop_ship_line_rec.source_type_code, OE_GLOBALS.G_SOURCE_EXTERNAL) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Wrong source type '|| l_drop_ship_line_rec.line_id,3);
     END IF;
     l_drop_ship_line_rec.result          := G_RES_NOT_APPLICABLE;
     l_drop_ship_line_rec.return_status   := FND_API.G_RET_STS_SUCCESS;
     goto end_of_for_loop;
  ELSE
     SELECT shippable_flag
     INTO   l_shippable_flag
     FROM   oe_order_lines
     WHERE  line_id = l_drop_ship_line_rec.line_id;

     IF nvl(l_shippable_flag, 'N') = 'N' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Non shippable!! '|| l_drop_ship_line_rec.line_id,3);
       END IF;
       l_drop_ship_line_rec.result          := G_RES_NOT_APPLICABLE;
       l_drop_ship_line_rec.return_status   := FND_API.G_RET_STS_SUCCESS;
       goto end_of_for_loop;
     END IF;

     --Fix for bug#2678070-Begin

     IF l_drop_ship_line_rec.schedule_ship_date is null THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Updating sch ship date from request date',1);
        END IF;

        -- Turning off Perform Scheduling Flag Before calling
        -- this procedure since this procedure is calling Process Order
        -- which in turn will call scheduling if this flag is not turned off.

        -- Bug# 4189838 Start
           OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
        -- Bug# 4189838 End

        OE_LINE_UTIL.Query_Row(p_line_id  => l_drop_ship_line_rec.line_id
                                  ,x_line_rec => l_line_rec);

        l_old_line_tbl(1)                  := l_line_rec;

        l_line_rec.schedule_ship_date      := l_line_rec.request_date;

        l_line_rec.operation               := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(1)                      := l_line_rec;

        /* Start Audit Trail */
        l_line_tbl(1).change_reason := 'SYSTEM';
        /* End Audit Trail */

        l_control_rec.controlled_operation := TRUE;
        l_control_rec.default_attributes   := TRUE;
        l_control_rec.change_attributes    := TRUE;
        l_control_rec.validate_entity      := TRUE;
        l_control_rec.write_to_DB          := TRUE;
        l_control_rec.check_security       := TRUE;
        l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;
        l_control_rec.process              := TRUE;

        --  Instruct API to retain its caches

        l_control_rec.clear_api_cache      := FALSE;
        l_control_rec.clear_api_requests   := FALSE;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Now calling Process Order from OEXVDSPB',1);
        END IF;

        OE_ORDER_PVT.Lines
              (p_validation_level        => FND_API.G_VALID_LEVEL_NONE
              ,p_control_rec             => l_control_rec
              ,p_x_line_tbl              => l_line_tbl
              ,p_x_old_line_tbl          => l_old_line_tbl
              ,x_return_status           => l_return_status);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('After calling process lines' , 1 ) ;
            oe_debug_pub.add('Return Status ' || l_return_status , 1 ) ;
        END IF;

        -- Bug# 4189838 Start
           OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        -- Bug# 4189838 End

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.add('Calling Process Request and Notify',1);
        END IF;

        OE_ORDER_PVT.Process_Requests_And_notify
              ( p_process_requests       => l_control_rec.process
               ,p_notify                 => TRUE
               ,x_return_status          => l_return_status
               ,p_line_tbl               => l_line_tbl
               ,p_old_line_tbl           => l_old_line_tbl);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF; /* If schedule_ship_date is null */
     --Fix for bug#2678070-End

    begin
    select 'Y'				 -- added begin block for bug 7433481
    into l_exists
    from oe_drop_ship_sources
    where line_id=l_drop_ship_line_rec.line_id;
    exception
    when no_data_found then
    l_exists:='N';
    when too_many_rows then
    l_exists:='Y';
    end;
    oe_debug_pub.add('Record already exists in drop ship table,Y OR N ? '||l_exists);
if l_exists='N' then --added for bug 7433481

     SELECT oe_drop_ship_source_s.nextval
     INTO l_drop_ship_source_id
     FROM dual;

     /* insert into po_requisition_interface table */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Before inserting into Requisitions Interface Table' , 1 ) ;
     END IF;

     Insert_Into_Po_Req_Interface
         (p_drop_ship_line_rec    => l_drop_ship_line_rec
          ,x_return_status        => l_return_status
          ,p_user_id              => l_user_id
          ,p_resp_id              => l_resp_id
          ,p_application_id       => l_application_id
          ,p_org_id               => l_org_id
          ,p_login_id             => l_login_id
          ,p_drop_ship_source_id  => l_drop_ship_source_id
         );

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('After inserting ',1);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
        IF l_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     /* insert into oe_drop_ship_sources table */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Inserting Dropship Source Record',1);
     END IF;

     Insert_Drop_Ship_Source
         ( p_drop_ship_line_rec   => l_drop_ship_line_rec
          ,x_return_status        => l_return_status
          ,p_user_id              => l_user_id
          ,p_resp_id              => l_resp_id
          ,p_application_id       => l_application_id
          ,p_org_id               => l_org_id
          ,p_login_id             => l_login_id
          ,p_drop_ship_source_id  => l_drop_ship_source_id
         );

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Inserted into Dropship Source Record', 1);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
        IF l_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;
   end if; --added for bug 7433481
  END IF;

  l_drop_ship_line_rec.return_status := FND_API.G_RET_STS_SUCCESS;
  l_drop_ship_line_rec.result        := OE_Purchase_Release_PVT.G_RES_COMPLETE;

  EXCEPTION
      WHEN Purchase_Release_Incomplete THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Exception Purchase Release Incomplete',1);
              oe_debug_pub.add('Purchase Release activity is incomplete for line ID : '||l_drop_ship_line_rec.line_id,1);
           END IF;
           l_drop_ship_line_rec.return_status   := FND_API.G_RET_STS_ERROR;
           IF l_drop_ship_line_rec.result <>  OE_Purchase_Release_PVT.G_RES_ONHOLD THEN
              l_drop_ship_line_rec.result := OE_Purchase_Release_PVT.G_RES_INCOMPLETE;
           END IF;
           --OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Purchase_Release'); bug 4683857
      WHEN FND_API.G_EXC_ERROR THEN
           l_drop_ship_line_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
            -- Changes for Bug - 2352589
           IF l_drop_ship_line_rec.result <>  OE_Purchase_Release_PVT.G_RES_ONHOLD THEN
               l_drop_ship_line_rec.result := OE_Purchase_Release_PVT.G_RES_INCOMPLETE;
           END IF;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Purchase_Release');
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('AN EXPECTED ERROR RAISED..'||SQLERRM , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR; -- bug 4683857
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Purchase_Release');
           x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('AN UNEXPECTED ERROR RAISED..'||SQLERRM , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN OTHERS THEN
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,   'Purchase_Release');
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('OTHER ERROR RAISED..'||SQLERRM , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;
  <<end_of_for_loop>>
  l_x_drop_ship_tbl(I) := l_drop_ship_line_rec;
  l_old_header_id := l_drop_ship_line_rec.header_id;
END LOOP;
x_drop_ship_tbl := l_x_drop_ship_tbl;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exit Purchase Release for line ID : '||l_drop_ship_line_rec.line_id , 1 ) ;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purchase_Release');
        END IF; --bug 5030428
        --OE_MSG_PUB.reset_msg_context('Purchase_Release'); 5030428
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purchase_Release');
        END IF;  --bug 5030428
        --OE_MSG_PUB.reset_msg_context('Purchase_Release'); 5030428
        RAISE;

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Purchase_Release');
        END IF;
        --OE_MSG_PUB.reset_msg_context('Purchase_Release'); 5030428
END Purchase_Release;

/*-----------------------------------------------------------------
PROCEDURE  : Insert_Into_Po_Req_Interface
DESCRIPTION:
-----------------------------------------------------------------*/

Procedure Insert_Into_Po_Req_Interface
(p_drop_ship_line_rec    IN  Drop_Ship_Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2

,p_user_id               IN NUMBER
,p_resp_id               IN NUMBER
,p_application_id        IN NUMBER
,p_org_id                IN NUMBER
,p_login_id              IN NUMBER
,p_drop_ship_source_id   IN NUMBER
)
IS
l_destination_type_code      VARCHAR2(25) ;
l_authorization_status       VARCHAR2(25) := 'APPROVED';
l_project_accounting_context VARCHAR2(30) := null;
l_schedule_ship_date         DATE         := null;
l_stock_enabled_flag         VARCHAR2(1); /* 1835314 */
l_source_code                VARCHAR2(30); /*2058542 */
l_prof_value                 NUMBER; --Fix for bug#2172019
l_item_revision              VARCHAR2(3);
l_revision_control_code      NUMBER;
l_ou_org_id                  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'BEFORE INSERTING RECORDS INTO PO REQUISITIONS INTERFACE ' , 1 ) ;
 END IF;

 IF  p_drop_ship_line_rec.project_id is not null AND
     p_drop_ship_line_rec.project_id <> FND_API.G_MISS_NUM AND
     p_drop_ship_line_rec.project_id <> -1 THEN
    l_project_accounting_context := 'Y';
 ELSE
    l_project_accounting_context := null;
 END IF;

 IF p_drop_ship_line_rec.schedule_ship_date is null THEN
   l_schedule_ship_date := p_drop_ship_line_rec.request_date;
 ELSE
   l_schedule_ship_date := p_drop_ship_line_rec.schedule_ship_date;
 END IF;

 BEGIN
    -- SQL Performance ID 14882612
    -- Replaced org_organization_definitions with inv_organization_info_v which
    -- includes the validation that the organization is inventory enabled.
    -- Please see bug 3742393 for details.
    -- The table FND_PRODUCT_GROUPs (in inv_organization_info_v) always has one row and hence
    -- FTS on this table can be ignored.

    SELECT msi.stock_enabled_flag ,revision_qty_control_code
    INTO   l_stock_enabled_flag, l_revision_control_code
    FROM   mtl_system_items msi,inv_organization_info_v org
    WHERE  msi.inventory_item_id = p_drop_ship_line_rec.inventory_item_id
    AND    org.organization_id = msi.organization_id
    AND    org.organization_id = p_drop_ship_line_rec.ship_from_org_id;

    IF l_stock_enabled_flag = 'N' THEN
       l_destination_type_code := 'EXPENSE';
    ELSE
       l_destination_type_code := 'INVENTORY';
    END IF;

 EXCEPTION WHEN NO_DATA_FOUND THEN
    l_destination_type_code := 'INVENTORY';
    l_revision_control_code := 1;
 END;

  -- added for bug 2201362
  if nvl(l_revision_control_code,1)=2 then
     IF NVL(FND_PROFILE.VALUE('INV_PURCHASING_BY_REVISION'),2) = 1 THEN
        BEGIN
          select MAX(revision)
          into   l_item_revision
          from   mtl_item_revisions mir,
                 mtl_system_items  mti
          where  mir.inventory_item_id = mti.inventory_item_id
          and    mir.organization_id  = mti.organization_id
          and    mti.inventory_item_id = p_drop_ship_line_rec.inventory_item_id
          and    mti.organization_id  = p_drop_ship_line_rec.ship_from_org_id
          and    mti.REVISION_QTY_CONTROL_CODE =2  /* Means item is under revision control */
          and    mir.effectivity_date < SYSDATE+1
          and    mir.effectivity_date =
                               ( select MAX(mir1.effectivity_date)
                                 from   mtl_item_revisions mir1
                                 where  mir1.inventory_item_id = mir.inventory_item_id
                                 and    mir1.organization_id = mir.organization_id
                                 and    mir1.effectivity_date < SYSDATE+1
                                  );

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_item_revision := NULL;
           WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ERROR WHILE RETRIEVING ITEM REVISION INFO '||SQLERRM , 1 ) ;
                END IF;
                l_item_revision := NULL;
        END;
     END IF;
  END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  '------------INSERTING VALUES: ----------' , 1 ) ;
     oe_debug_pub.add(  'DESTINATION_ORGANIZATION_ID: '||P_DROP_SHIP_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
     oe_debug_pub.add(  'DELIVER_TO_LOCATION_ID : '||P_DROP_SHIP_LINE_REC.DELIVER_TO_LOCATION_ID , 1 ) ;
     oe_debug_pub.add(  'DELIVER_TO_REQUESTOR_ID : '||P_DROP_SHIP_LINE_REC.EMPLOYEE_ID , 1 ) ;
     oe_debug_pub.add(  'NEED_BY_DATE : '||L_SCHEDULE_SHIP_DATE , 1 ) ;
     oe_debug_pub.add(  'LAST_UPDATED_BY : '||P_USER_ID , 1 ) ;
     oe_debug_pub.add(  'LAST_UPDATE_LOGIN : '||P_LOGIN_ID , 1 ) ;
     oe_debug_pub.add(  'DESTINATION_TYPE_CODE : '||L_DESTINATION_TYPE_CODE , 1 ) ;
     oe_debug_pub.add(  'QUANTITY : '||P_DROP_SHIP_LINE_REC.OPEN_QUANTITY , 1 ) ;
     oe_debug_pub.add(  'AUTHORIZATION_STATUS : '||L_AUTHORIZATION_STATUS , 1 ) ;
     oe_debug_pub.add(  'PREPARER_ID : '||P_DROP_SHIP_LINE_REC.EMPLOYEE_ID , 1 ) ;
     oe_debug_pub.add(  'ITEM_ID : '||P_DROP_SHIP_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
     oe_debug_pub.add(  'STOCK ENABLED FLAG : '||L_STOCK_ENABLED_FLAG , 1 ) ;
     oe_debug_pub.add(  'CHARGE_ACCOUNT_ID : '||P_DROP_SHIP_LINE_REC.CHARGE_ACCOUNT_ID , 1 ) ;
     oe_debug_pub.add(  'INTERFACE_SOURCE_LINE_ID : '||P_DROP_SHIP_SOURCE_ID , 1 ) ;
     oe_debug_pub.add(  'PROJECT_ID : '||P_DROP_SHIP_LINE_REC.PROJECT_ID , 1 ) ;
     oe_debug_pub.add(  'TASK_ID : '||P_DROP_SHIP_LINE_REC.TASK_ID , 1 ) ;
     oe_debug_pub.add(  'END_ITEM_UNIT_NUMBER : '||P_DROP_SHIP_LINE_REC.END_ITEM_UNIT_NUMBER , 1 ) ;
     oe_debug_pub.add(  'PROJECT_ACCOUNTING_CONTEXT : '||L_PROJECT_ACCOUNTING_CONTEXT , 1 ) ;
     oe_debug_pub.add(  'UNIT LIST PRICE : '||TO_CHAR ( P_DROP_SHIP_LINE_REC.UNIT_LIST_PRICE ) , 1 ) ;
     oe_debug_pub.add(  'DESTINATION TYPE CODE : '||L_DESTINATION_TYPE_CODE , 1 ) ;
     oe_debug_pub.add(  'ITEM REVISION : '||L_ITEM_REVISION , 1 ) ;
 END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  '----------------------' , 1 ) ;
 END IF;

 -- Fix for bug2058542
 l_source_code :=fnd_profile.value('ONT_SOURCE_CODE');
 l_prof_value :=fnd_profile.value('ONT_POPULATE_BUYER'); --Fix for bug#2172019

 IF PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J THEN
    -- SQL Performance ID 14882656
    -- Replaced org_organization_definitions with inv_organization_info_v which
    -- includes the validation that the organization is inventory enabled.
    -- Please see bug 3742393 for details.
    -- The table FND_PRODUCT_GROUPs (in inv_organization_info_v) always has one row and hence
    -- FTS on this table can be ignored.

    SELECT operating_unit
    INTO l_ou_org_id
    FROM inv_organization_info_v
    WHERE organization_id = p_drop_ship_line_rec.ship_from_org_id;

 END IF;


 INSERT INTO po_requisitions_interface_all
             (interface_source_code,
             destination_organization_id,
             deliver_to_location_id,
             deliver_to_requestor_id,
             need_by_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             creation_date,
             created_by,
             destination_type_code,
             quantity,
             uom_code,
             secondary_quantity,      -- OPM
             secondary_uom_code,      -- OPM
             preferred_grade,         -- OPM
             authorization_status,
             preparer_id,
             item_id,
             charge_account_id,
             accrual_account_id,      -- OPM
             interface_source_line_id,
             source_type_code,
             unit_price,
             project_id,
             task_id,
             end_item_unit_number,
             project_accounting_context,
             item_revision,
             suggested_buyer_id, -- Fix for bug 2122969
             item_description,
             org_id)
             VALUES
             (
             l_source_code,
             p_drop_ship_line_rec.ship_from_org_id,
             p_drop_ship_line_rec.deliver_to_location_id,
             p_drop_ship_line_rec.employee_id,
             l_schedule_ship_date,
             p_user_id,
             SYSDATE,
             p_login_id,
             SYSDATE,
             p_user_id,
             l_destination_type_code,
             p_drop_ship_line_rec.open_quantity,
             p_drop_ship_line_rec.uom_code,
             p_drop_ship_line_rec.open_quantity2,          -- OPM
             p_drop_ship_line_rec.uom2_code,               -- OPM
             p_drop_ship_line_rec.preferred_grade,         -- OPM
             l_authorization_status,
             p_drop_ship_line_rec.employee_id,
             p_drop_ship_line_rec.inventory_item_id,
             p_drop_ship_line_rec.charge_account_id,
             p_drop_ship_line_rec.accrual_account_id,      -- OPM
             p_drop_ship_source_id,
             'VENDOR',
             NULL,
             decode(p_drop_ship_line_rec.project_id, -1, NULL, p_drop_ship_line_rec.project_id),
             decode(p_drop_ship_line_rec.task_id, -1, NULL, p_drop_ship_line_rec.task_id),
             decode(p_drop_ship_line_rec.end_item_unit_number, '-1', NULL, p_drop_ship_line_rec.end_item_unit_number),
             l_project_accounting_context,
             l_item_revision,
             decode(nvl(l_prof_value,0),1,p_drop_ship_line_rec.employee_id,NULL), -- Modified Fix for bug 2122969 through bug 2172019
              p_drop_ship_line_rec.item_description,
              l_ou_org_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'END OF INSERT_INTO_PO_REQ_INTERFACE' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Into_Po_Req_Interface'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Into_Po_Req_Interface;

/*-----------------------------------------------------------------
PROCEDURE  : Insert_Drop_Ship_Source
DESCRIPTION:
-----------------------------------------------------------------*/

Procedure Insert_Drop_Ship_Source
(p_drop_ship_line_rec   IN  Drop_Ship_Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2

,p_user_id              IN NUMBER
,p_resp_id              IN NUMBER
,p_application_id       IN NUMBER
,p_org_id               IN NUMBER
,p_login_id             IN NUMBER
,p_drop_ship_source_id  IN NUMBER
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'START OF INSERT_DROP_SHIP_SOURCE' , 1 ) ;
     END IF;


     INSERT INTO oe_drop_ship_sources
                (drop_ship_source_id,
                 header_id,
                 line_id,
                 destination_organization_id,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 creation_date,
                 created_by,
                 org_id
                 )
                VALUES
                (p_drop_ship_source_id,
                 p_drop_ship_line_rec.header_id,
                 p_drop_ship_line_rec.line_id,
                 p_drop_ship_line_rec.ship_from_org_id,
                 p_user_id,
                 SYSDATE,
                 p_login_id,
                 SYSDATE,
                 p_user_id,
                 p_org_id
                 );

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'END OF INSERT_DROP_SHIP_SOURCE' , 1 ) ;
     END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Drop_Ship_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Drop_Ship_Source;

/*-----------------------------------------------------------------
PROCEDURE  : Associate_address
DESCRIPTION:
-----------------------------------------------------------------*/

Procedure Associate_address(p_drop_ship_line_rec   IN Drop_Ship_Line_Rec_Type
,x_drop_ship_line_rec OUT NOCOPY Drop_Ship_Line_Rec_Type

,x_return_status OUT NOCOPY VARCHAR2)

IS
 l_drop_ship_line_rec  Drop_Ship_Line_Rec_Type;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  l_drop_ship_line_rec := p_drop_ship_line_rec;

  x_drop_ship_line_rec := l_drop_ship_line_rec;
  IF l_drop_ship_line_rec.deliver_to_location_id = -1 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ONT','OE_DS_NO_LOC_LINK');
     OE_MSG_PUB.Add;
  ELSE
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
END Associate_address;

/*-----------------------------------------------------------------
PROCEDURE  : Get_Eligible_lines
DESCRIPTION:
-----------------------------------------------------------------*/

Procedure Get_Eligible_lines
(p_line_id          IN NUMBER
,x_drop_ship_tbl OUT NOCOPY Drop_Ship_Tbl_Type

,x_return_status OUT NOCOPY VARCHAR2)

IS
   CURSOR eligible_lines_cursor(p_line_id IN NUMBER) IS
        SELECT /* MOAC_SQL_CHANGE */ sl.item_type_code, 'STANDARD',
               sh.order_number, sl.line_number,
               sl.header_id, sl.line_id, sl.ship_from_org_id,
               nvl(sl.project_id, -1), nvl(sl.task_id, -1),
               nvl(sl.end_item_unit_number,'-1'),fu.user_name,
               nvl(fu.employee_id, -99), sl.request_date,
               sl.schedule_ship_date,
               sl.ordered_quantity,
               sl.ordered_quantity2,              -- OPM
               sl.ordered_quantity_uom2,          -- OPM
               sl.preferred_grade,                -- OPM
               sl.inventory_item_id,
               sl.source_type_code, decode(msi.inventory_asset_flag,
               'Y', mp.material_account, nvl(msi.expense_account,
               mp.expense_account)), nvl(pla.location_id, -1)
        FROM   po_location_associations pla, oe_order_lines_all sl,
               mtl_parameters mp, fnd_user fu, mtl_system_items msi,
               oe_order_headers sh
        WHERE  sl.header_id = sh.header_id
               AND sl.line_id = p_line_id
               AND fu.user_id = sh.created_by
               AND sl.source_type_code is not null
               AND sl.ship_from_org_id is not null
               AND sl.inventory_item_id = msi.inventory_item_id
               AND sl.ship_from_org_id = msi.organization_id
               AND mp.organization_id = msi.organization_id
               AND sl.ship_to_org_id = pla.site_use_id(+)
               AND sl.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL;

l_drop_ship_line_rec          Drop_Ship_Line_Rec_Type;
l_drop_ship_tbl               Drop_Ship_Tbl_Type;
l_line_count                  NUMBER;
l_line_id                     NUMBER;
l_header_id                   NUMBER;
l_order_type_name             VARCHAR2(240);
l_order_number                NUMBER;
l_line_number                 NUMBER;
l_item_type_code              VARCHAR2(30);
l_inventory_item_id           NUMBER;
l_open_quantity               NUMBER;
l_project_id                  NUMBER;
l_task_id                     NUMBER;
l_end_item_unit_number        VARCHAR2(30);
l_user_name                   VARCHAR2(100); -- bug 4189862
l_employee_id                 NUMBER;
l_request_date                DATE;
l_schedule_ship_date          DATE;
l_source_type_code            VARCHAR2(30);
l_charge_account_id           NUMBER;
l_deliver_to_location_id      NUMBER;
l_ship_from_org_id            NUMBER;
/* OPM variables */
l_open_quantity2    NUMBER;
l_uom2_code         VARCHAR2(25);
l_preferred_grade      VARCHAR2(150);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_ELIGIBLE_LINES' , 1 ) ;
  END IF;
  l_line_id := p_line_id;
  l_line_count := 0;
  OPEN eligible_lines_cursor(p_line_id => l_line_id);
  LOOP
  FETCH eligible_lines_cursor INTO
        l_item_type_code,l_order_type_name, l_order_number, l_line_number,
        l_header_id, l_line_id, l_ship_from_org_id,l_project_id, l_task_id,
        l_end_item_unit_number,l_user_name, l_employee_id,
        l_request_date,l_schedule_ship_date,
        l_open_quantity, l_open_quantity2, l_uom2_code,  l_preferred_grade,
        l_inventory_item_id, l_source_type_code,
        l_charge_account_id, l_deliver_to_location_id;
  EXIT WHEN eligible_lines_cursor%NOTFOUND;

  l_line_count := l_line_count + 1;
  l_drop_ship_line_rec.header_id                    := l_header_id;
  l_drop_ship_line_rec.order_type_name              := l_order_type_name;
  l_drop_ship_line_rec.order_number                 := l_order_number;
  l_drop_ship_line_rec.line_number                  := l_line_number;
  l_drop_ship_line_rec.line_id                      := l_line_id;
  l_drop_ship_line_rec.ship_from_org_id             := l_ship_from_org_id;
  l_drop_ship_line_rec.item_type_code               := l_item_type_code;
  l_drop_ship_line_rec.inventory_item_id            := l_inventory_item_id;
  l_drop_ship_line_rec.open_quantity                := l_open_quantity;
  l_drop_ship_line_rec.open_quantity2               := l_open_quantity2;          -- OPM
  l_drop_ship_line_rec.uom2_code                    := l_uom2_code;               -- OPM
  l_drop_ship_line_rec.preferred_grade              := l_preferred_grade;         -- OPM
  l_drop_ship_line_rec.project_id                   := l_project_id;
  l_drop_ship_line_rec.task_id                      := l_task_id;
  l_drop_ship_line_rec.end_item_unit_number         := l_end_item_unit_number;
  l_drop_ship_line_rec.user_name                    := l_user_name;
  l_drop_ship_line_rec.employee_id                  := l_employee_id;
  l_drop_ship_line_rec.request_date                 := l_request_date;
  l_drop_ship_line_rec.schedule_ship_date           := l_schedule_ship_date;
  l_drop_ship_line_rec.source_type_code             := l_source_type_code;
  l_drop_ship_line_rec.charge_account_id            := l_charge_account_id;
  l_drop_ship_line_rec.deliver_to_location_id       := l_deliver_to_location_id;

  l_drop_ship_tbl(l_line_count)  := l_drop_ship_line_rec;
  END LOOP;
  CLOSE eligible_lines_cursor;
  x_drop_ship_tbl                := l_drop_ship_tbl;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING GET_ELIGIBLE_LINES' , 1 ) ;
  END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Eligible_lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Eligible_lines;

FUNCTION Get_Shipto_Location_Id
(p_site_use_id          IN        NUMBER
)
RETURN NUMBER
IS
 l_ship_to_location_id     NUMBER;
BEGIN

  SELECT loc.location_id
    INTO l_ship_to_location_id
    FROM hz_cust_site_uses_all   site_uses,
         hz_cust_acct_sites_all  acct_site,
         hz_party_sites          party_site,
         hz_locations            loc
  WHERE site_uses.cust_acct_site_id =  acct_site.cust_acct_site_id
    AND acct_site.party_site_id     =  party_site.party_site_id
    AND loc.location_id             =  party_site.location_id
    AND site_uses.site_use_code     =  'SHIP_TO'
    AND site_uses.site_use_id       =  p_site_use_id;

  RETURN l_ship_to_location_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN NULL;
END Get_Shipto_Location_Id;


Procedure Process_DropShip_CMS_Requests
(p_request_tbl      IN OUT NOCOPY OE_ORDER_PUB.Request_Tbl_Type
,x_return_status       OUT NOCOPY VARCHAR2
)
IS
 I                                NUMBER;
 l_return_status                  VARCHAR2(3);
 l_count                          NUMBER        :=  1;
 l_can_count                      NUMBER        :=  1;

 l_req_header_id                  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_req_line_id                    PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_po_header_id          	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_po_release_id         	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_po_line_id            	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_po_line_location_id   	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();

 l_can_req_header_id              PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_can_req_line_id                PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_can_po_header_id          	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_can_po_release_id         	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_can_po_line_id            	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_can_po_line_location_id   	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();

 l_quantity              	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_secondary_quantity    	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_need_by_date          	  PO_TBL_DATE   :=  PO_TBL_DATE();
 l_ship_to_location      	  PO_TBL_NUMBER :=  PO_TBL_NUMBER();
 l_sales_order_updated_date 	  PO_TBL_DATE   :=  PO_TBL_DATE();
 l_grade                         po_tbl_varchar240 := po_tbl_varchar240(); -- INVCONV

 l_ds_quantity                    NUMBER;
 l_ds_ordered_quantity_uom        VARCHAR2(3);
 l_ds_ordered_quantity2           NUMBER;
 l_ds_ordered_quantity_uom2       VARCHAR2(3);
 l_ds_preferred_grade             VARCHAR2(150);
 l_ds_schedule_ship_date          DATE;

 l_ds_old_ship_to_location_id     NUMBER;
 l_ds_new_ship_to_location_id     NUMBER;
 l_ds_ship_to_location_id         NUMBER;

 l_requisition_header_id          NUMBER;
 l_pur_header_id                  NUMBER;
 l_requisition_line_id            NUMBER;
 l_pur_line_id                    NUMBER;
 l_pur_release_id                 NUMBER;
 l_line_loc_id                    NUMBER;
 l_drop_ship_id                   NUMBER;


 l_req_created                    VARCHAR2(1);
 l_po_created                     VARCHAR2(1);
 l_changed_flag                   VARCHAR2(1);
 l_msg_data                       VARCHAR2(2000);
 l_error_msg                      VARCHAR2(2000);
 l_msg_count                      NUMBER;
 l_msg_index                      NUMBER;
 --l_po_status                      VARCHAR2(4100);
 l_process_flag                   VARCHAR2(30);
 l_line_num                       VARCHAR2(30);

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_source_code VARCHAR2(30)    := FND_PROFILE.Value('ONT_SOURCE_CODE');
 --bug 4411054
 l_po_status_rec         PO_STATUS_REC_TYPE;
 l_autorization_status   VARCHAR2(30);

BEGIN

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Entering Process_DropShip_CMS_Requests...', 2);
     OE_DEBUG_PUB.Add('No of Records:'|| p_request_tbl.count , 2);
  END IF;

  I := p_request_tbl.FIRST;

  WHILE I IS NOT NULL LOOP

     IF p_request_tbl(I).request_type = 'DROPSHIP_CMS' THEN

        -- Initialize all the Variables.
        l_req_created                  := 'N';
        l_po_created                   := 'N';
        l_changed_flag                 := 'N';
        l_ds_quantity                  := NULL;
        l_ds_ordered_quantity_uom      := NULL;
        l_ds_ordered_quantity2         := NULL;
        l_ds_ordered_quantity_uom2     := NULL;
        l_ds_preferred_grade           := NULL;
        l_ds_schedule_ship_date        := NULL;
        l_ds_old_ship_to_location_id   := NULL;
        l_ds_new_ship_to_location_id   := NULL;
        l_ds_ship_to_location_id       := NULL;

        OE_DEBUG_PUB.Add('After Initializing Local Variable', 2);

        SELECT  requisition_header_id,po_header_id,
                requisition_line_id,po_line_id,
                line_location_id,po_release_id,drop_ship_source_id
          INTO  l_requisition_header_id,l_pur_header_id,
                l_requisition_line_id,l_pur_line_id,
                l_line_loc_id,l_pur_release_id,l_drop_ship_id
          FROM  oe_drop_ship_sources
         WHERE  line_id   = p_request_tbl(I).entity_id;

        IF l_requisition_header_id IS NOT NULL THEN
           l_req_created := 'Y';
        END IF;

        IF l_pur_header_id IS NOT NULL THEN
           l_po_created := 'Y';
        END IF;

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Line Id:'||p_request_tbl(I).entity_id,2);
           OE_DEBUG_PUB.Add('Req Created: '||l_req_created,2);
           OE_DEBUG_PUB.Add('PO Created: '||l_po_created,2);
        END IF;

        IF l_req_created = 'Y' THEN
           -- 3579735
           oe_debug_pub.add(' Extending req hdr ', 1);
           l_req_header_id.extend;
           l_req_line_id.extend;
           l_po_header_id.extend;
           l_po_release_id.extend;
           l_po_line_id.extend;
           l_po_line_location_id.extend;
           l_quantity.extend;
           l_secondary_quantity.extend;
           l_grade.extend;   -- bug 4639066 , missed by INVCONV
           l_need_by_date.extend;
           l_ship_to_location.extend;
           l_sales_order_updated_date.extend;

           --l_req_header_id.extend(l_count);
           --l_req_line_id.extend(l_count);
           --l_po_header_id.extend(l_count);
           --l_po_release_id.extend(l_count);
           --l_po_line_id.extend(l_count);
           --l_po_line_location_id.extend(l_count);
           --l_quantity.extend(l_count);
           --l_secondary_quantity.extend(l_count);
           --l_need_by_date.extend(l_count);
           --l_ship_to_location.extend(l_count);
           --l_sales_order_updated_date.extend(l_count);

       /* Commented for bug 4639066, because EXTEND would add a new NULL element
           l_req_header_id(l_count)              := NULL;
           l_req_line_id(l_count)                := NULL;
           l_po_header_id(l_count)               := NULL;
           l_po_release_id(l_count)              := NULL;
           l_po_line_id(l_count)                 := NULL;
           l_po_line_location_id(l_count)        := NULL;
           l_quantity(l_count)                   := NULL;
           l_secondary_quantity(l_count)         := NULL;
           l_grade(l_count)											 := NULL; -- INVCONV
           l_need_by_date(l_count)               := NULL;
           l_ship_to_location(l_count)           := NULL;
           l_sales_order_updated_date(l_count)   := NULL;
        */
        END IF;

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Compare the Old and New CMS Parameters...', 2);
           OE_DEBUG_PUB.Add('Operation Performed:'||p_request_tbl(I).param15, 2);
        END IF;

        IF p_request_tbl(I).param15 = 'UPDATE' THEN

         IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param1
                                      ,p_request_tbl(I).param8) THEN

             IF l_req_created = 'N' THEN
                l_ds_quantity  := p_request_tbl(I).param8;
             ELSE
                l_req_header_id(l_count)        := l_requisition_header_id;
                l_req_line_id(l_count)          := l_requisition_line_id;
                l_po_header_id(l_count)         := l_pur_header_id;
                l_po_line_id(l_count)           := l_pur_line_id;
                l_po_release_id(l_count)        := l_pur_release_id;
                l_po_line_location_id(l_count)  := l_line_loc_id;
                l_quantity(l_count)             := p_request_tbl(I).param8;
                l_changed_flag                  := 'Y';
             END IF;


             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Ordered Quantity Changed----', 2);
                OE_DEBUG_PUB.Add('Old :'||p_request_tbl(I).param1||
                                 ' New :'||p_request_tbl(I).param8,1);
                OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;

         END IF;


         IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param2
                                      ,p_request_tbl(I).param9) THEN
             IF l_req_created = 'N' THEN
                l_ds_ordered_quantity_uom  := p_request_tbl(I).param9;
             END IF;

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Ordered Quantity UOM Changed----', 2);
                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).param2||
                                 'New:'||p_request_tbl(I).param9,1);
                OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;


         END IF;

         IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param3
                                      ,p_request_tbl(I).param10) THEN

              l_ds_new_ship_to_location_id := Get_Shipto_Location_id(p_request_tbl(I).param10);
              l_ds_old_ship_to_location_id := Get_Shipto_Location_id(p_request_tbl(I).param3);

              IF NOT OE_GLOBALS.EQUAL(l_ds_new_ship_to_location_id,
                                      l_ds_old_ship_to_location_id) THEN

                 IF l_req_created = 'N' THEN
                    l_ds_ship_to_location_id := l_ds_new_ship_to_location_id;
                 ELSE
                     l_req_header_id(l_count)        := l_requisition_header_id;
                     l_req_line_id(l_count)          := l_requisition_line_id;
                     l_po_header_id(l_count)         := l_pur_header_id;
                     l_po_line_id(l_count)           := l_pur_line_id;
                     l_po_release_id(l_count)        := l_pur_release_id;
                     l_po_line_location_id(l_count)  := l_line_loc_id;
                     l_ship_to_location(l_count)     := l_ds_new_ship_to_location_id;
                     l_changed_flag                  := 'Y';

                 END IF;

              END IF;


             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Ship To Location Changed----', 2);
                OE_DEBUG_PUB.Add('Old:'||l_ds_old_ship_to_location_id||
                                 ' New:'||l_ds_new_ship_to_location_id,1);
                OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;

            END IF;



           IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param4
                                      ,p_request_tbl(I).param11) THEN

             IF l_req_created = 'N' THEN
                l_ds_ordered_quantity2 := p_request_tbl(I).param11;
             ELSE
                 l_req_header_id(l_count)        := l_requisition_header_id;
                 l_req_line_id(l_count)          := l_requisition_line_id;
                 l_po_header_id(l_count)         := l_pur_header_id;
                 l_po_line_id(l_count)           := l_pur_line_id;
                 l_po_release_id(l_count)        := l_pur_release_id;
                 l_po_line_location_id(l_count)  := l_line_loc_id;
                 l_secondary_quantity(l_count)   := p_request_tbl(I).param11;
                 l_changed_flag                  := 'Y';
             END IF;


             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Secondary Quantity Changed----', 2);
                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).param4||
                                 ' New:'||p_request_tbl(I).param11,1);
                OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;

           END IF;


           IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param5
                                      ,p_request_tbl(I).param12) THEN

             IF l_req_created = 'N' THEN
                l_ds_ordered_quantity_uom2  := p_request_tbl(I).param12;
             END IF;

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Secondary Quantity UOM Changed----', 2);
                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).param5||
                                 'New:'||p_request_tbl(I).param12,1);
                OE_DEBUG_PUB.Add('--------------------------------------', 2);
             END IF;

           END IF;

           IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param6
                                      ,p_request_tbl(I).param13) THEN

             IF l_req_created = 'N' THEN
                l_ds_preferred_grade  := p_request_tbl(I).param13;
             END IF;

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Preferred Grade Changed----', 2);
                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).param6||
                                 'New:'||p_request_tbl(I).param13,1);
                OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;


           END IF;


  /*****Begin changes for bug#6918700*********/

         --  IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).param7 ,p_request_tbl(I).param14) THEN

           IF NOT OE_GLOBALS.EQUAL(p_request_tbl(I).date_param1 ,p_request_tbl(I).date_param2) THEN
/*****End changes for bug#6918700*********/

            IF l_req_created = 'N' THEN
/*****Begin changes for bug#6918700*********/
            --  l_ds_schedule_ship_date  := p_request_tbl(I).param14;
		l_ds_schedule_ship_date  := p_request_tbl(I).date_param2;
/*****End changes for bug#6918700*********/
             ELSE
                 l_req_header_id(l_count)        := l_requisition_header_id;
                 l_req_line_id(l_count)          := l_requisition_line_id;
                 l_po_header_id(l_count)         := l_pur_header_id;
                 l_po_line_id(l_count)           := l_pur_line_id;
                 l_po_release_id(l_count)        := l_pur_release_id;
                 l_po_line_location_id(l_count)  := l_line_loc_id;
 /*****Begin changes for bug#6918700*********/
            --   l_need_by_date(l_count)         := p_request_tbl(I).param14;
                 l_need_by_date(l_count)         := p_request_tbl(I).date_param2;
/*****End changes for bug#6918700*********/
                 l_changed_flag                  := 'Y';

             END IF;

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('----Schedule Ship Date Changed----', 2);
/*****Begin changes for bug#6918700*********/
/*                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).param7||
                                 'New:'||p_request_tbl(I).param14,1);
 */
                OE_DEBUG_PUB.Add('Old:'||p_request_tbl(I).date_param1||
                                 'New:'||p_request_tbl(I).date_param2,1);
/*****End changes for bug#6918700*********/
               OE_DEBUG_PUB.Add('--------------------------------', 2);
             END IF;

           END IF;


           IF  p_request_tbl(I).param16 = 'Y' AND
               l_req_created = 'Y' and l_po_created = 'Y'  THEN

               -- comment out for bug 4411054
               /*l_po_status := UPPER(PO_HEADERS_SV3.Get_PO_Status
                                        (x_po_header_id => l_pur_header_id
                                        ));

              IF l_debug_level > 0 THEN
                  OE_DEBUG_PUB.Add('Check PO Status : '|| l_po_status, 2);
              END IF;
              */
              PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK
                                (p_api_version => 1.0
                                , p_header_id => l_pur_header_id
                                , p_release_id => l_pur_release_id --bug 5328526
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);

 	      IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             	  l_autorization_status := l_po_status_rec.authorization_status(1);

                  IF l_debug_level > 0 THEN
                    OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
                    OE_DEBUG_PUB.Add('Check PO Status : '|| l_autorization_status, 2);
                  END IF;
       	       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
       	       END IF;

              --IF (INSTR(nvl(l_po_status,'z'), 'APPROVED') <> 0 ) THEN
              IF(nvl(l_autorization_status,'z')= 'APPROVED')  THEN
                 l_req_header_id(l_count)        := l_requisition_header_id;
                 l_req_line_id(l_count)          := l_requisition_line_id;
                 l_po_header_id(l_count)         := l_pur_header_id;
                 l_po_line_id(l_count)           := l_pur_line_id;
                 l_po_release_id(l_count)        := l_pur_release_id;
                 l_po_line_location_id(l_count)  := l_line_loc_id;
                 l_sales_order_updated_date(l_count)   := sysdate;
                 l_changed_flag                  := 'Y';

                 IF l_debug_level > 0 THEN
                    OE_DEBUG_PUB.Add('----Ref Data Elem Changed----', 2);
                    OE_DEBUG_PUB.Add('Req:'||l_req_created||'PO:'||l_po_created||
                                                   'Release:'||l_pur_release_id, 2);
                    OE_DEBUG_PUB.Add('--------------------------------', 2);
                 END IF;

              END IF;

          END IF;



           IF l_req_created = 'N'  THEN

                -- Lock the Interface record

                SELECT process_flag
                  INTO l_process_flag
                  FROM po_requisitions_interface_all
                 WHERE interface_source_line_id = l_drop_ship_id
                   AND interface_source_code    = l_source_code;

                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.Add('After Querying: '||l_drop_ship_id, 2);
                END IF;

                SELECT RTRIM(line_number      || '.' ||
                             shipment_number  || '.' ||
                             option_number    || '.' ||
                             component_number || '.' ||
                             service_number, '.')
                INTO   l_line_num
                FROM   oe_order_lines_all
                WHERE  line_id = p_request_tbl(I).entity_id;

                IF l_process_flag is NULL THEN

                   -- Update the Interface Record
                   -- Analyzed for SQL performance ID 14882834, No changes required
                   -- as we do not have any more where condition criteria
                   UPDATE po_requisitions_interface_all
                      SET quantity                 =   nvl(l_ds_quantity,quantity),
                          uom_code                 =   nvl(l_ds_ordered_quantity_uom,
                                                           uom_code),
                          secondary_quantity       =   nvl(l_ds_ordered_quantity2,
                                                           secondary_quantity),
                          secondary_uom_code       =   nvl(l_ds_ordered_quantity_uom2,
                                                           secondary_uom_code),
                          preferred_grade          =   nvl(l_ds_preferred_grade,
                                                           preferred_grade),
                          need_by_date             =   nvl(l_ds_schedule_ship_date,
                                                           need_by_date),
                          deliver_to_location_id   =   nvl(l_ds_ship_to_location_id,
                                                           deliver_to_location_id)
                   WHERE  interface_source_line_id =   l_drop_ship_id
                     AND  interface_source_code    =   l_source_code;

                   IF l_debug_level > 0 THEN
                      OE_DEBUG_PUB.Add('After Updating PO_Requisitions_Interface_All..', 2);
                   END IF;

                ELSIF l_process_flag = 'ERROR' THEN
                      FND_MESSAGE.SET_NAME('ONT','ONT_DS_LINE_IN_ERROR');
                      FND_MESSAGE.SET_TOKEN('LINE_NUM',l_line_num);
                      OE_MSG_PUB.Add;
                ELSIF l_process_flag is NOT NULL THEN
                      FND_MESSAGE.SET_NAME('ONT','ONT_DS_LINE_IN_PROCESS');
                      FND_MESSAGE.SET_TOKEN('LINE_NUM',l_line_num);
                      OE_MSG_PUB.Add;
                      RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            IF l_changed_flag  =   'Y' THEN
               l_count := l_count  +  1;
            END IF;


     END IF;  -- Update

     IF p_request_tbl(I).param15   = 'CANCEL' THEN

        oe_debug_pub.add('1 extending can req hdr ', 1);
        -- 3579735
      --l_can_req_header_id.extend(l_can_count);
      --l_can_req_line_id.extend(l_can_count);
      --l_can_po_header_id.extend(l_can_count);
      --l_can_po_release_id.extend(l_can_count);
      --l_can_po_line_id.extend(l_can_count);
      --l_can_po_line_location_id.extend(l_can_count);

        l_can_req_header_id.extend;
        l_can_req_line_id.extend;
        l_can_po_header_id.extend;
        l_can_po_release_id.extend;
        l_can_po_line_id.extend;
        l_can_po_line_location_id.extend;

        IF  l_req_created = 'N'  THEN

         BEGIN
            SELECT process_flag
              INTO l_process_flag
              FROM po_requisitions_interface_all
             WHERE interface_source_line_id =   l_drop_ship_id
               AND interface_source_code    =   l_source_code ;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- #5262032, no data found when the req interface  records deleted
              IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.add('No po req interface records for this line',1);
              END IF;
         END;


             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('After Querying,dropship_id: '||l_drop_ship_id||' ,process_flag:'||l_process_flag, 2);
             END IF;

             Begin
               SELECT RTRIM(line_number      || '.' ||
                            shipment_number  || '.' ||
                            option_number    || '.' ||
                            component_number || '.' ||
                            service_number, '.')
               INTO   l_line_num
               FROM   oe_order_lines_all
               WHERE  line_id = p_request_tbl(I).entity_id;
             Exception
               When Others Then
               /* Bug 4922019: Changes done to ATO configuration resutls in
                  deletion of the config line. Hence the above select would fail.
                  If line has been deleted, then its OK to have the line number NULL */
                  Null;
             End;

             IF l_process_flag is NULL THEN
                -- Analysed for SQL Performance ID 14882874, No changes required
                -- as we do not have any more where condition criteria
                DELETE FROM po_requisitions_interface_all
                WHERE interface_source_line_id = l_drop_ship_id
                  AND interface_source_code    = l_source_code;

                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.Add('After Deleting: '||l_drop_ship_id, 2);
                END IF;

             ELSIF l_process_flag = 'ERROR' THEN
                   FND_MESSAGE.SET_NAME('ONT','ONT_DS_LINE_IN_ERROR');
                   FND_MESSAGE.SET_TOKEN('LINE_NUM',l_line_num);
                   OE_MSG_PUB.Add;
             ELSIF l_process_flag is NOT NULL THEN
                   FND_MESSAGE.SET_NAME('ONT','ONT_DS_LINE_IN_PROCESS');
                   FND_MESSAGE.SET_TOKEN('LINE_NUM',l_line_num);
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
             END IF;

        ELSE
            oe_debug_pub.add('assigning values to cancel records', 1);
            l_can_req_header_id(l_can_count)       :=   l_requisition_header_id;
            l_can_req_line_id(l_can_count)         :=   l_requisition_line_id;
            l_can_po_header_id(l_can_count)        :=   l_pur_header_id;
            l_can_po_line_id(l_can_count)          :=   l_pur_line_id;
            l_can_po_release_id(l_can_count)       :=   l_pur_release_id;
            l_can_po_line_location_id(l_can_count) :=   l_line_loc_id;
            l_can_count := l_can_count  +  1;
        END IF;


     END IF;

    ELSE
      oe_debug_pub.add('not a dropship request ', 1);
    END IF; -- Dropship CMS


    I := p_request_tbl.NEXT(I);

  END LOOP;

  IF l_count > 1 THEN

     IF l_debug_level  > 0 THEN
       OE_DEBUG_PUB.Add('Before Calling Update_Req_PO...',2) ;
       OE_DEBUG_PUB.Add('No of Req Records PO: '||to_char(l_count -1),2) ;
     END IF;
--

      PO_OM_INTEGRATION_GRP.Update_Req_PO
                       (p_api_version                =>  1.0
                       ,p_req_header_id              =>  l_req_header_id
                       ,p_req_line_id                =>  l_req_line_id
                       ,p_po_header_id               =>  l_po_header_id
                       ,p_po_release_id              =>  l_po_release_id
                       ,p_po_line_id                 =>  l_po_line_id
                       ,p_po_line_location_id        =>  l_po_line_location_id
                       ,p_quantity                   =>  l_quantity
                       ,p_secondary_quantity         =>  l_secondary_quantity
                       ,p_need_by_date               =>  l_need_by_date
                       ,p_ship_to_location_id        =>  l_ship_to_location
                       ,p_sales_order_update_date    =>  l_sales_order_updated_date
                       ,p_preferred_grade           =>   l_grade -- INVCONV
                       ,x_return_status              =>  l_return_status
                       ,x_msg_count                  =>  l_msg_count
                       ,x_msg_data                   =>  l_msg_data
                       );

  IF l_debug_level  > 0 THEN
     OE_DEBUG_PUB.Add(' After Calling update_req_po...'||l_return_status,2) ;
     OE_DEBUG_PUB.Add(' Message Count:'||l_msg_count,2) ;
     OE_DEBUG_PUB.Add(' Message Data:'||l_msg_data,2) ;
  END IF;

   IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         OE_MSG_PUB.Transfer_Msg_Stack;
         l_msg_count:=OE_MSG_PUB.COUNT_MSG;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN

          OE_MSG_PUB.Transfer_Msg_Stack;
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          FOR I in 1..l_msg_count LOOP
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Messages from Update PO;'||l_msg_data,1 ) ;
              END IF;
          END LOOP;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF l_can_count > 1 THEN

    IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('Before Calling Cancel_Req_PO...',2) ;
      OE_DEBUG_PUB.Add
      ('No of Records for PO Cancellation...'||l_can_count ,2) ;
    END IF;

     FOR I in l_can_req_header_id.FIRST..l_can_req_header_id.LAST
     LOOP
       oe_debug_pub.add('req hdr '|| l_can_req_header_id(I), 1);

        -- added for bug 3946163
        -- The p_po_line_id shall be passed as NULL for all the lines that are
        -- attached to a blanket purchase agreement
        IF l_can_po_release_id(I) is NOT NULL THEN
           l_can_po_line_id(I) := NULL;
        END IF;
     END LOOP;

     PO_OM_INTEGRATION_GRP.Cancel_Req_PO
                       (p_api_version                =>  1.0
                       ,p_req_header_id              =>  l_can_req_header_id
                       ,p_req_line_id                =>  l_can_req_line_id
                       ,p_po_header_id               =>  l_can_po_header_id
                       ,p_po_release_id              =>  l_can_po_release_id
                       ,p_po_line_id                 =>  l_can_po_line_id
                       ,p_po_line_location_id        =>  l_can_po_line_location_id
                       ,x_return_status              =>  l_return_status
                       ,x_msg_data                   =>  l_msg_data
                       ,x_msg_count                  =>  l_msg_count
                       );


     IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('After Calling Cancel_Req_PO: '||l_return_status,2) ;
        OE_DEBUG_PUB.Add(' Message Count:'||l_msg_count,2) ;
        OE_DEBUG_PUB.Add(' Message Data:'||l_msg_data,2) ;
     END IF;

     IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          OE_MSG_PUB.Transfer_Msg_Stack;
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN

          OE_MSG_PUB.Transfer_Msg_Stack;
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          FOR I in 1..l_msg_count LOOP
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Messages from Cancel PO;'||l_msg_data,1 ) ;
              END IF;
          END LOOP;

        IF l_debug_level  > 0 THEN
           OE_DEBUG_PUB.Add('Errors from Cancel_req_po: '||l_msg_data,2) ;
        END IF;

           -- bug 5358405
           FND_MESSAGE.set_name('ONT','OE_CANCEL_FAILED');
           OE_MSG_PUB.Add;

           RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;


  -- Error during updates, mark the requests as NOT processed

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      I := p_request_tbl.FIRST;
      WHILE I IS NOT NULL LOOP
        IF p_request_tbl(I).request_type = 'DROPSHIP_CMS' THEN
           p_request_tbl(I).processed := 'N';
        END IF;
        I := p_request_tbl.NEXT(I);
      END LOOP;
  END IF;

  IF l_debug_level > 0 then
     OE_DEBUG_PUB.Add('Exiting Process_DropShip_CMS_Requests..:'||x_return_status);
  END IF;

  x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Expected Error in Process_DropShip_CMS_Requests...',4);
         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExpected Error in Process_DropShip_CMS_Requests...'||sqlerrm,4);
         END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
         OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Process_DropShip_CMS_Requests'
            );
    END IF;

END Process_DropShip_CMS_Requests;

END OE_Purchase_Release_PVT;

/
