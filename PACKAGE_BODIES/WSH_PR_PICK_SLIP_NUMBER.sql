--------------------------------------------------------
--  DDL for Package Body WSH_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_PICK_SLIP_NUMBER" AS
/* $Header: WSHPRPNB.pls 120.1 2006/06/20 09:06:52 aymohant noship $ */

 /*
 ###############   PLEASE READ ####################################
   Following type/variable declarations  were owned by WSH until
   patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these type/variable declarations  only if you are making bug-fix for
   pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
   --
   -- PACKAGE TYPES
   --
      TYPE keyRecTyp IS RECORD (
         grouping_rule_id         NUMBER		:= FND_API.G_MISS_NUM,
         header_id                NUMBER		:= FND_API.G_MISS_NUM,
         customer_id              NUMBER		:= FND_API.G_MISS_NUM,
         ship_method_code         VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
         ship_to_loc_id           NUMBER		:= FND_API.G_MISS_NUM,
         shipment_priority        VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
         subinventory             VARCHAR2(10)	:= FND_API.G_MISS_CHAR,
         trip_stop_id             NUMBER		:= FND_API.G_MISS_NUM,
         delivery_id              NUMBER		:= FND_API.G_MISS_NUM,
         inventory_item_id        NUMBER     	:= FND_API.G_MISS_NUM,
         locator_id               NUMBER     	:= FND_API.G_MISS_NUM,
-- HW OPMCONV - Increate the size of lot_number
         lot_number               VARCHAR2(80)   	:= FND_API.G_MISS_CHAR,
         revision                 VARCHAR2(3)    	:= FND_API.G_MISS_CHAR,
         organization_id          NUMBER		:= FND_API.G_MISS_NUM,
         pick_slip_number         NUMBER		:= FND_API.G_MISS_NUM,
         counter                  NUMBER		:= FND_API.G_MISS_NUM
      );


      TYPE keyTabTyp IS TABLE OF keyRecTyp INDEX BY BINARY_INTEGER;

      TYPE grpRecTyp IS RECORD (
         grouping_rule_id         NUMBER	:= FND_API.G_MISS_NUM,
         use_order_ps             VARCHAR2(1)   := 'N',
         use_sub_ps               VARCHAR2(1)   := 'N',
         use_customer_ps          VARCHAR2(1)   := 'N',
         use_ship_to_ps           VARCHAR2(1)   := 'N',
         use_carrier_ps           VARCHAR2(1)   := 'N',
         use_ship_priority_ps     VARCHAR2(1)   := 'N',
         use_trip_stop_ps         VARCHAR2(1)   := 'N',
         use_delivery_ps          VARCHAR2(1)   := 'N',
         use_item_ps              VARCHAR2(1)   := 'N',
         use_locator_ps           VARCHAR2(1)   := 'N',
         use_lot_ps               VARCHAR2(1)   := 'N',
         use_revision_ps          VARCHAR2(1)   := 'N',
	    pick_method              VARCHAR2(30)  := '-99'
      );

      TYPE grpTabTyp IS TABLE OF grpRecTyp INDEX BY BINARY_INTEGER;

   --
   -- PACKAGE VARIABLES
   --
      g_rule_table                            grpTabTyp;
      g_pskey_table                           keyTabTyp;

      g_hash_base NUMBER := 1;
      g_hash_size NUMBER := power(2, 25);

   -- For cahing the limit information for an org

      g_prev_org_id NUMBER;
      g_pickslip_limit NUMBER;
   --
   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PR_PICK_SLIP_NUMBER';
   --
   --
   -- Name
   --   PROCEDURE Print_Pvt
   --
   -- Purpose
   --   Print Pick Slip based on Pick Slip Number
   --
   -- Input Parameter
   --   p_report_set_id    => report set
   --   p_pick_slip_number => pick slip number
   --   p_order_header_id  => sales Order Header id
   --    Order Header id is mainly to Obtain the Order Number which has to be passed on
   --    to the Call to Document Set thru l_document_info table. (Ref. bug: 1520991)
   --   p_batch_id        =>  batch id , which is also the Move Order High and Low,
   --                         this is passed on for an entire Batch,
   --                         ie. when a particular P.slip No. is not specified
   --
   -- Output Parameters
   --   x_api_status    => FND_API.G_RET_STS_SUCESSS or
   --                      FND_API.G_RET_STS_ERROR or
   --                      FND_API.G_RET_STS_UNEXP_ERROR
   --
   PROCEDURE Print_Pvt (
      p_report_set_id            IN  NUMBER,
      p_organization_id          IN  NUMBER,
      p_pick_slip_number         IN  NUMBER,
      p_order_header_id          IN  NUMBER,
      p_batch_id                 IN  NUMBER,
      p_ps_mode                  IN  VARCHAR2 default NULL ,
      x_api_status               OUT NOCOPY VARCHAR2)
   IS

      CURSOR get_order_number (X_order_header_id in number) is
      SELECT order_number
      FROM oe_order_headers_all
      WHERE header_id = X_order_header_id;

      -- Bug# 1577520 - Pass the Batch Name to MoveOrderHeader, instead of Batch Id
      -- Prasanna Vanguri 5th March'01
      CURSOR get_batch_name (X_batch_id in number ) is
      SELECT name
      FROM   wsh_picking_batches
      WHERE  batch_id = X_batch_id;

      l_batch_name    varchar2(30);
      l_order_number  OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE;
      l_report_set_id NUMBER;
      l_trip_ids      WSH_UTIL_CORE.Id_Tab_Type;
      l_stop_ids      WSH_UTIL_CORE.Id_Tab_Type;
      l_delivery_ids  WSH_UTIL_CORE.Id_Tab_Type;
      l_document_info WSH_DOCUMENT_SETS.document_set_tab_type;
      l_organization_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_PVT';
--
   BEGIN
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --

      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.logmsg(l_module_name,  'Inside print_pvt ');
          --
          WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PICK_SLIP_NUMBER',P_PICK_SLIP_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
          WSH_DEBUG_SV.logmsg(l_module_name,  'REPORT SET ID ' || TO_CHAR ( P_REPORT_SET_ID )  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'p_ps_mode ' || p_ps_mode  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'count of g_printertab  ' || WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count   );
      END IF;
      --
      l_order_number := null;
      IF ( nvl(p_order_header_id,0) <> 0) THEN
         OPEN  get_order_number(p_order_header_id);
         FETCH get_order_number
         INTO  l_order_number;

         IF get_order_number%NOTFOUND THEN
            null;
         END IF;
 	 --
 	 IF l_debug_on THEN
 	     WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HDR ID: ' || TO_CHAR ( P_ORDER_HEADER_ID )  );
 	     WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER NUMBER: ' || L_ORDER_NUMBER  );
 	 END IF;
 	 --
         CLOSE get_order_number;
      END IF;

      l_report_set_id := p_report_set_id;
      IF ( nvl(p_batch_id, 0) <> 0) THEN
         --Bug# 1577520 , Assign Batch name to Move Order , instead of Batchid

         OPEN   get_batch_name(p_batch_id);
         FETCH  get_batch_name into l_batch_name;
         CLOSE  get_batch_name;

         l_document_info(1).p_move_order_h  := l_batch_name;
         l_document_info(1).p_move_order_l  := l_batch_name;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_batch_name',l_batch_name);
         END IF;

      ELSE
         l_document_info(1).pick_slip_num_l := p_pick_slip_number;
         l_document_info(1).pick_slip_num_h := p_pick_slip_number;
      END IF;

      IF ( nvl(p_order_header_id,0) <> 0) THEN
         l_document_info(1).p_order_num_low := l_order_number;
         l_document_info(1).p_order_num_high := l_order_number;
      END IF;

      l_organization_id := p_organization_id;


      if p_ps_mode <> 'I' and WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count > 0 Then
          for i in 1..WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count  LOOP

               l_document_info(1).p_printer_name := WSH_INV_INTEGRATION_GRP.G_PRINTERTAB(i);
	       --
               IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'Calling Print_Document_sets for printer   ' || WSH_INV_INTEGRATION_GRP.G_PRINTERTAB(i)   );
              END IF ;
               --
               WSH_DOCUMENT_SETS.Print_Document_Sets(
                  p_report_set_id       => l_report_set_id,
                  p_organization_id     => l_organization_id,
                  p_trip_ids            => l_trip_ids,
                  p_stop_ids            => l_stop_ids,
                  p_delivery_ids        => l_delivery_ids,
                  p_document_param_info => l_document_info,
                  x_return_status       => x_api_status);
         --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'x_api_status',x_api_status);
                      WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
         --
           End LOOP ;
       else
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER NUMBER: ' || L_ORDER_NUMBER  );
           END IF;
           WSH_DOCUMENT_SETS.Print_Document_Sets(
                  p_report_set_id       => l_report_set_id,
                  p_organization_id     => l_organization_id,
                  p_trip_ids            => l_trip_ids,
                  p_stop_ids            => l_stop_ids,
                  p_delivery_ids        => l_delivery_ids,
                  p_document_param_info => l_document_info,
                  x_return_status       => x_api_status);
         --
           IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_api_status',x_api_status);
                WSH_DEBUG_SV.pop(l_module_name);
           END IF;
         --
       end if ;

   END Print_Pvt;
   --
   -- Name
   --   PROCEDURE Print_Pick_Slip
   --
   -- Purpose
   --   This function initializesthe g_use_ variables to be used
   --   in determining the how to group pick slips.
   --
   -- Input Parameters
   --   p_pick_slip_number => pick slip number
   --   p_report_set_id    => report set
   --   p_order_header_id  => Order Header id
   --   p_batch_id         => Batch Id of the Picking Batch id
   --
   -- Output Parameters
   --   x_api_status    => FND_API.G_RET_STS_SUCESSS or
   --                      FND_API.G_RET_STS_ERROR or
   --                      FND_API.G_RET_STS_UNEXP_ERROR
   --   x_error_message => Error message
   --
   PROCEDURE Print_Pick_Slip (
      p_pick_slip_number         IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
      p_report_set_id            IN  NUMBER,
      p_organization_id          IN  NUMBER,
      p_order_header_id          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
      p_batch_id                 IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
      p_ps_mode                  IN  VARCHAR2 DEFAULT NULL,
      x_api_status               OUT NOCOPY VARCHAR2,
      x_error_message            OUT NOCOPY VARCHAR2 )
   IS
      l_index         NUMBER;
      l_ps_num        NUMBER;
      l_organization_id	NUMBER;
      l_batch_id       	NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_PICK_SLIP';
l_pick_slip_number	NUMBER;
--
   CURSOR ps_list IS
   SELECT pick_slip_number
     FROM mtl_pick_slip_numbers
   WHERE pick_slip_batch_id = WSH_PICK_LIST.G_BATCH_ID
   AND status = 1;

   BEGIN

      /* p_report_set_id is no longer used as we print the seeded Pick Slip report always
         Stored in WSH_PICK_LIST.G_SEED_DOC_SET. Keeping it for compilation dependency
      */
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'P_PICK_SLIP_NUMBER',P_PICK_SLIP_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PS_MODE',P_PS_MODE);
      END IF;
      --
 /*
 ###############   PLEASE READ ####################################
   Get_pick_slip_number API was owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.

   This API populates g_pskey_table and Print API reads from the table.

   Hence, we have the following in-line branch in the code.

   IF WSH is at level before I, we continue to read
   from wsh_pr_pick_slip_number.g_pskey_table
   Otherwise,
    we read from inv_pr_pick_slip_number.g_pskey_table
 */

      IF WSH_CODE_CONTROL.Get_Code_Release_Level >= '110509'
      THEN
      l_index := INV_PR_PICK_SLIP_NUMBER.g_pskey_table.first;
      ELSE
      l_index := g_pskey_table.first;
      END IF;
      --
      x_api_status := FND_API.G_RET_STS_SUCCESS;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
     END IF;

      -- If report set id is NULL, there is no report to print
      IF (WSH_PICK_LIST.G_SEED_DOC_SET IS NULL) THEN
         x_api_status := FND_API.G_RET_STS_SUCCESS;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'there is no report to print');
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      -- Added if condition  IF WSH_PICK_LIST.G_PICK_REL_PARALLEL for
      -- parallel pick-release

      IF (p_pick_slip_number = FND_API.G_MISS_NUM) THEN
         IF (p_ps_mode = 'I') THEN
            -- Loop through the pl-sql table to print the remaining pick slips
	    IF WSH_PICK_LIST.G_PICK_REL_PARALLEL THEN
	      OPEN ps_list;
	      LOOP
	         FETCH ps_list into l_pick_slip_number;
		 EXIT WHEN ps_list%NOTFOUND;
		 Print_Pvt(p_report_set_id    => WSH_PICK_LIST.G_SEED_DOC_SET,
			   p_organization_id  => p_organization_id,
		           p_pick_slip_number => l_pick_slip_number,
		           p_order_header_id  => p_order_header_id,
		           p_batch_id         => NULL,
		           p_ps_mode          => p_ps_mode ,
		           x_api_status       => x_api_status);
	       END LOOP;
	       CLOSE ps_list;
	     ELSE
	      WHILE l_index IS NOT NULL LOOP
	       l_batch_id := null;   /* Since specific P.slip Numbers are used here */
	       --
               IF WSH_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
                   Print_Pvt(p_report_set_id    => WSH_PICK_LIST.G_SEED_DOC_SET,
			     p_organization_id  => p_organization_id,
		             p_pick_slip_number => INV_PR_PICK_SLIP_NUMBER.g_pskey_table(l_index).pick_slip_number,
                             p_order_header_id  => p_order_header_id,
			     p_batch_id         => l_batch_id,
			     p_ps_mode          => p_ps_mode ,
			     x_api_status       => x_api_status);
                   -- Remove from table
                   INV_PR_PICK_SLIP_NUMBER.g_pskey_table.delete(l_index);
                   l_index := INV_PR_PICK_SLIP_NUMBER.g_pskey_table.next(l_index);
	       ELSE
                   Print_Pvt(p_report_set_id    => WSH_PICK_LIST.G_SEED_DOC_SET,
			     p_organization_id  => p_organization_id,
		             p_pick_slip_number => g_pskey_table(l_index).pick_slip_number,
                             p_order_header_id  => p_order_header_id,
			     p_batch_id         => l_batch_id,
			     p_ps_mode          => p_ps_mode ,
			     x_api_status       => x_api_status);
                   -- Remove from table
                   g_pskey_table.delete(l_index);
                   l_index := g_pskey_table.next(l_index);
	       END IF;
	       --
            END LOOP;
	   END IF;
         ELSE
            l_ps_num := null;     /* Since this is for an entire Batch and Not for p.Slip No (s) */
            --
            Print_Pvt(p_report_set_id    => WSH_PICK_LIST.G_SEED_DOC_SET,
		      p_organization_id  => p_organization_id,
		      p_pick_slip_number => l_ps_num,
		      p_order_header_id  => p_order_header_id,
		      p_batch_id         => p_batch_id,
		      p_ps_mode          => p_ps_mode ,
		      x_api_status       => x_api_status);
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'X_API_STATUS PRINT_PVT:'|| X_API_STATUS  );
            END IF;
            --
         END IF;
      ELSE
         Print_Pvt(p_report_set_id    => WSH_PICK_LIST.G_SEED_DOC_SET,
		   p_organization_id  => p_organization_id,
		   p_pick_slip_number => p_pick_slip_number,
		   p_order_header_id  => p_order_header_id,
                   p_batch_id         => l_batch_id,
		   p_ps_mode          => p_ps_mode ,
		   x_api_status       => x_api_status);
      END IF;

      IF x_api_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_error_message := 'Error occurred in call to ' ||
                            'Print_Pvt in ' ||
                            'WSH_PR_PICK_SLIP_NUMBER.Print_Pick_Slip';
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Error:',x_error_message);

         END IF;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'x_api_status',x_api_status);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Exception occurred in WSH_PR_PICK_SLIP_NUMBER.Print_Pick_Slip';
         x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
   END Print_Pick_Slip;

   --Procedure
   -- Delete_Pick_Slip_Numbers for Parallel Pick-Release process
   --

   PROCEDURE delete_pick_slip_numbers(p_batch_id    IN NUMBER)  IS
    BEGIN
    /*if nvl(p_batch_id, -1) = -1 then
        p_batch_id := wsh_pick_list.g_batch_id;
      end if; */

      DELETE FROM mtl_pick_slip_numbers
        WHERE pick_slip_batch_id = p_batch_id;

   END delete_pick_slip_numbers;

 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
   --
   -- Name
   --   PROCEDURE Insert_Key
   --
   -- Purpose
   --   Insert new key to table and returns newly generated pick slip number
   --
   -- Input Parameter
   --   l_hash_value
   --   l_Insert_key_Rec
   --
   -- Output Parameter
   --   x_pick_slip_number   => pick_slip_number
   --   x_error_message      => Error message
   --

   PROCEDURE Insert_Key (
      l_hash_value                 IN      NUMBER,
      l_Insert_key_Rec             IN      keyRecTyp,
      x_pick_slip_number           OUT     NOCOPY NUMBER,
      x_error_message              OUT     NOCOPY VARCHAR2)
   IS

   BEGIN
 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
      SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL
      INTO x_pick_slip_number
      FROM DUAL;

       g_pskey_table(l_hash_value) := l_Insert_key_Rec;
       g_pskey_table(l_hash_value).counter := 1;
       g_pskey_table(l_hash_value).pick_slip_number := x_pick_slip_number;
   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Error occurred in WSH_PR_PICK_NUMBER.Insert_Key';
   END Insert_Key;

   --
   -- Name
   --   PROCEDURE CreateHash
   --
   -- Purpose
   --  Generate a hash value for the given values for the column strings
   --
   -- Input Parameter
   --   p_rule_index         => index to the grouping rule table
   --   p_header_id          => order header id
   --   p_customer_id        => customer id
   --   p_ship_method_code   => ship method
   --   p_ship_to_loc_id     => ship to location
   --   p_shipment_priority  => shipment priority
   --   p_subinventory       => subinventory
   --   p_trip_stop_id       => trip stop
   --   p_delivery_id        => delivery
   --   p_inventory_item_id  => item
   --   p_locator_id         => locator
   --   p_lot_number         => lot number
   --   p_revision           => revision
   --   p_org_id             => organization
   --
   -- Output Parameter
   --   x_hash_value         => hash value for g_pskey_table
   --   x_Insert_key_Rec     => keyRecTyp
   --   x_error_message      => Error message
   --
 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */

   PROCEDURE Create_Hash (
      p_rule_index                 IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id          IN      NUMBER,
      p_locator_id                 IN      NUMBER,
      p_lot_number                 IN      VARCHAR2,
      p_revision                   IN      VARCHAR2,
      p_org_id                     IN      NUMBER,
      x_hash_value                 OUT     NOCOPY NUMBER,
      x_Insert_key_Rec             OUT     NOCOPY keyRecTyp,
      x_error_message              OUT     NOCOPY VARCHAR2)
   IS
      l_hash_string  VARCHAR2(2000) := NULL;

   BEGIN
 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */

      l_hash_string  := to_char(g_rule_table(p_rule_index).grouping_rule_id);

      x_Insert_key_Rec.grouping_rule_id := g_rule_table(p_rule_index).grouping_rule_id;

      IF (g_rule_table(p_rule_index).use_order_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_header_id);
         x_Insert_key_Rec.header_id := p_header_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_sub_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| p_subinventory;
         x_Insert_key_Rec.subinventory := p_subinventory;
      END IF;
      IF (g_rule_table(p_rule_index).use_customer_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_customer_id);
         x_Insert_key_Rec.customer_id := p_customer_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_carrier_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| p_ship_method_code;
         x_Insert_key_Rec.ship_method_code := p_ship_method_code;
      END IF;
      IF (g_rule_table(p_rule_index).use_ship_to_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_ship_to_loc_id);
          x_Insert_key_Rec.ship_to_loc_id := p_ship_to_loc_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_ship_priority_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| p_shipment_priority;
         x_Insert_key_Rec.shipment_priority := p_shipment_priority;
      END IF;
      IF (g_rule_table(p_rule_index).use_trip_stop_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_trip_stop_id);
         x_Insert_key_Rec.trip_stop_id := p_trip_stop_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_delivery_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_delivery_id);
         x_Insert_key_Rec.delivery_id := p_delivery_id;
      END IF;

      IF (g_rule_table(p_rule_index).use_item_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_inventory_item_id);
         x_Insert_key_Rec.inventory_item_id := p_inventory_item_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_locator_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| to_char(p_locator_id);
         x_Insert_key_Rec.locator_id := p_locator_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_lot_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| p_lot_number;
         x_Insert_key_Rec.lot_number := p_lot_number;
      END IF;
      IF (g_rule_table(p_rule_index).use_revision_ps = 'Y') THEN
         l_hash_string  := l_hash_string ||'-'|| p_revision;
         x_Insert_key_Rec.revision := p_revision;
      END IF;

      x_Insert_key_Rec.organization_id := p_org_id;
      l_hash_string  := l_hash_string ||'-'|| to_char(p_org_id);

      x_hash_value := dbms_utility.get_hash_value(
                                  name => l_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Error occurred in WSH_PR_PICK_NUMBER.Create_Hash';
   END Create_Hash;

 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
   --
   -- Name
   --   PROCEDURE Get_Pick_Slip_Number
   --
   -- Purpose
   --   Returns pick slip number
   --
   -- Input Parameters
   --   p_ps_mode              => pick slip print mode: I=immed, E=deferred
   --   p_pick_grouping_rule_id => pick grouping rule id
   --   p_org_id               => organization_id
   --   p_header_id            => order header id
   --   p_customer_id          => customer id
   --   p_ship_method_code     => ship method
   --   p_ship_to_loc_id       => ship to location
   --   p_shipment_priority    => shipment priority
   --   p_subinventory         => subinventory
   --   p_trip_stop_id         => trip stop
   --   p_delivery_id          => delivery
   --   p_inventory_item_id    => item
   --   p_locator_id           => locator
   --   p_lot_number           => lot number
   --   p_revision             => revision
   --
   -- Output Parameters
   --   x_pick_slip_number     => pick_slip_number
   --   x_ready_to_print       => FND_API.G_TRUE or FND_API.G_FALSE
   --   x_api_status           => FND_API.G_RET_STS_SUCESSS or
   --                             FND_API.G_RET_STS_ERROR or
   --                             FND_API.G_RET_STS_UNEXP_ERROR
   --   x_error_message        => Error message
   --
   PROCEDURE Get_Pick_Slip_Number (
      p_ps_mode                    IN      VARCHAR2,
      p_pick_grouping_rule_id      IN      NUMBER,
      p_org_id                     IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id	     IN      NUMBER   DEFAULT NULL,
      p_locator_id                 IN      NUMBER   DEFAULT NULL,
      p_lot_number                 IN      VARCHAR2 DEFAULT NULL,
      p_revision                   IN      VARCHAR2 DEFAULT NULL,
      x_pick_slip_number           OUT     NOCOPY NUMBER,
      x_ready_to_print             OUT     NOCOPY VARCHAR2,
      x_call_mode                  OUT     NOCOPY VARCHAR2,
      x_api_status                 OUT     NOCOPY VARCHAR2,
      x_error_message              OUT     NOCOPY VARCHAR2
   ) IS
      -- cursor to get the pick slip grouping rule
      CURSOR ps_rule (v_pgr_id IN NUMBER) IS
      SELECT NVL(ORDER_NUMBER_FLAG, 'N'),
             NVL(SUBINVENTORY_FLAG, 'N'),
             NVL(CUSTOMER_FLAG, 'N'),
             NVL(SHIP_TO_FLAG, 'N'),
             NVL(CARRIER_FLAG, 'N'),
             NVL(SHIPMENT_PRIORITY_FLAG, 'N'),
             NVL(TRIP_STOP_FLAG, 'N'),
             NVL(DELIVERY_FLAG, 'N'),
	        NVL(ITEM_FLAG, 'N'),
	        NVL(LOCATOR_FLAG, 'N'),
	        NVL(LOT_FLAG, 'N'),
	        NVL(REVISION_FLAG, 'N'),
		   NVL(PICK_METHOD,'-99')
      FROM   WSH_PICK_GROUPING_RULES
      WHERE  PICK_GROUPING_RULE_ID = v_pgr_id;

      -- cursor to get number of times called before printer
      CURSOR get_limit (v_org_id IN NUMBER) IS
      SELECT NVL(pick_slip_lines,-1)
      FROM   WSH_SHIPPING_PARAMETERS
      WHERE  ORGANIZATION_ID = v_org_id;

      l_limit        NUMBER;
      l_Insert_key_Rec  keyRecTyp;
      l_hash_value   NUMBER;
      l_rule_index   NUMBER;
      l_found        BOOLEAN;
      i              NUMBER;

   BEGIN
 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
      IF (WSH_PICK_LIST.G_BATCH_ID IS NOT NULL) THEN
        -- Needed for inventory to know whether this API is triggered manually
        -- or through pick release
        x_call_mode := 'Y';
      END IF;

      -- get the number of times called for a pick slip before
      -- setting the ready to print flag to TRUE, if print is immediate
      -- pickslip limit is cahed and fetched only if current org defers from the last org

      IF p_ps_mode =  'I' THEN
         IF p_org_id = g_prev_org_id THEN
            l_limit := g_pickslip_limit;
         ELSE
            OPEN get_limit(p_org_id);
            FETCH get_limit INTO l_limit;
            IF get_limit%NOTFOUND THEN
               x_error_message := 'Organization ' ||
                               to_char(p_org_id) ||
                               ' does not exist. ';
               x_api_status := FND_API.G_RET_STS_ERROR;
               RETURN;
            END IF;
            g_prev_org_id := p_org_id;
            g_pickslip_limit := l_limit;
         END IF;
      END IF;


      -- Set ready to print flag to FALSE initially
      x_ready_to_print :=  FND_API.G_FALSE;

      -- find grouping rule in table
      l_found := FALSE;


    IF g_rule_table.exists(p_pick_grouping_rule_id) THEN
      l_found := TRUE;
      l_rule_index := p_pick_grouping_rule_id;
    END IF;



	 IF ((l_found) AND (g_rule_table(l_rule_index).pick_method = '3')) THEN -- Cluster Picking
	   /* Do not store the pick slip numbers generated for cluster picking
		 as we want to generate a new one for each line
        */
           SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL
           INTO   x_pick_slip_number
           FROM   DUAL;

	   x_api_status := FND_API.G_RET_STS_SUCCESS;
	   RETURN;
         END IF;
-- Create hash for g_pskey table here instead of in Insert_Key

      -- if not found, fetch information about pick slip grouping rule
      IF (NOT l_found) THEN
         l_rule_index := p_pick_grouping_rule_id;
         OPEN    ps_rule(p_pick_grouping_rule_id);
         FETCH   ps_rule
         INTO    g_rule_table(l_rule_index).use_order_ps,
                 g_rule_table(l_rule_index).use_sub_ps,
                 g_rule_table(l_rule_index).use_customer_ps,
                 g_rule_table(l_rule_index).use_ship_to_ps,
                 g_rule_table(l_rule_index).use_carrier_ps,
                 g_rule_table(l_rule_index).use_ship_priority_ps,
                 g_rule_table(l_rule_index).use_trip_stop_ps,
                 g_rule_table(l_rule_index).use_delivery_ps,
                 g_rule_table(l_rule_index).use_item_ps,
	         	  g_rule_table(l_rule_index).use_locator_ps,
		       g_rule_table(l_rule_index).use_lot_ps,
		       g_rule_table(l_rule_index).use_revision_ps,
			  g_rule_table(l_rule_index).pick_method;
         IF ps_rule%NOTFOUND THEN
            x_error_message := 'Pick grouping rule '
                               || to_char(p_pick_grouping_rule_id) ||
                               ' does not exist';
            x_api_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;

         g_rule_table(l_rule_index).grouping_rule_id := p_pick_grouping_rule_id;

         IF (g_rule_table(l_rule_index).pick_method = '3') THEN -- Cluster Picking
           /* Do not store the pick slip numbers generated for cluster picking
		    as we want to generate a new one for each line
           */
           SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL
           INTO   x_pick_slip_number
           FROM   DUAL;
         ELSE
           -- Insert new key to table based on grouping rule

           Create_Hash(p_rule_index       => l_rule_index,
                      p_header_id         => p_header_id,
                      p_customer_id       => p_customer_id,
                      p_ship_method_code  => p_ship_method_code,
                      p_ship_to_loc_id    => p_ship_to_loc_id,
                      p_shipment_priority => p_shipment_priority,
                      p_subinventory      => p_subinventory,
                      p_trip_stop_id      => p_trip_stop_id,
                      p_delivery_id       => p_delivery_id,
                      p_inventory_item_id => p_inventory_item_id,
                      p_locator_id        => p_locator_id,
                      p_lot_number        => p_lot_number,
                      p_revision          => p_revision,
                      p_org_id            => p_org_id,
                      x_hash_value        => l_hash_value,
                      x_Insert_key_Rec    => l_Insert_key_Rec,
                      x_error_message     => x_error_message);


           Insert_Key(l_hash_value        => l_hash_value,
                      l_Insert_key_Rec    => l_Insert_key_Rec,
                      x_pick_slip_number  => x_pick_slip_number,
                      x_error_message     => x_error_message);
         END IF;
         x_api_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;

      END IF;

      -- Comes here only if l_found TRUE
      -- If grouping rule is stored, find stored pick slip number for rule
      -- l_found := FALSE;  -- No longer required

         -- If key table is empty, there is no looping through table

           Create_Hash(p_rule_index       => l_rule_index,
                      p_header_id         => p_header_id,
                      p_customer_id       => p_customer_id,
                      p_ship_method_code  => p_ship_method_code,
                      p_ship_to_loc_id    => p_ship_to_loc_id,
                      p_shipment_priority => p_shipment_priority,
                      p_subinventory      => p_subinventory,
                      p_trip_stop_id      => p_trip_stop_id,
                      p_delivery_id       => p_delivery_id,
                      p_inventory_item_id => p_inventory_item_id,
                      p_locator_id        => p_locator_id,
                      p_lot_number        => p_lot_number,
                      p_revision          => p_revision,
                      p_org_id            => p_org_id,
                      x_hash_value        => l_hash_value,
                      x_Insert_key_Rec    => l_Insert_key_Rec,
                      x_error_message     => x_error_message);


           IF g_pskey_table.exists(l_hash_value) THEN
               x_pick_slip_number := g_pskey_table(l_hash_value).pick_slip_number;
               g_pskey_table(l_hash_value).counter := g_pskey_table(l_hash_value).counter + 1;

               -- Print is immediate so check if limit has been reached
               IF (p_ps_mode = 'I' AND l_limit <> -1) THEN
                  IF (g_pskey_table(l_hash_value).counter >= l_limit) THEN
                     x_ready_to_print :=  FND_API.G_TRUE;
                     g_print_ps_table(g_print_ps_table.count + 1) := x_pick_slip_number;
                     g_pskey_table.delete(l_hash_value);
                  END IF;
               END IF;
           ELSE
               -- Insert new key

               Insert_Key(l_hash_value        => l_hash_value,
                          l_Insert_key_Rec    => l_Insert_key_Rec,
                          x_pick_slip_number  => x_pick_slip_number,
                          x_error_message     => x_error_message);
           END IF;

      x_api_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Error occurred in WSH_PR_PICK_NUMBER.Get_Pick_Slip_Number';
         x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END Get_Pick_Slip_Number;

--
-- Name
--   PROCEDURE DELETE_PS_TBL
--
-- Purpose
--   Deletes the global PL/SQL table used to store pick slip numbers
--   For Code levels after  11.5.9  , it will delete the global table from INV
--
-- Input Parameters
--   None
--
-- Output Parameters
--   None
PROCEDURE DELETE_PS_TBL
    ( x_api_status                 OUT     NOCOPY VARCHAR2,
      x_error_message              OUT     NOCOPY VARCHAR2  ) IS
BEGIN

    x_api_status := FND_API.G_RET_STS_SUCCESS;
    IF WSH_CODE_CONTROL.Get_Code_Release_Level >= '110509'
    THEN
        INV_PR_PICK_SLIP_NUMBER.g_pskey_table.delete ;
    ELSE
        g_pskey_table.delete ;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       x_error_message := 'Error occurred in WSH_PR_PICK_NUMBER.DELETE_PS_TBL: ' || SQLERRM;
       x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
END DELETE_PS_TBL ;

END WSH_PR_PICK_SLIP_NUMBER;

/
