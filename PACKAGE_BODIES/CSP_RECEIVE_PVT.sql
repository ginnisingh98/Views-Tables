--------------------------------------------------------
--  DDL for Package Body CSP_RECEIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RECEIVE_PVT" AS
/* $Header: cspvrcvb.pls 120.6.12010000.5 2011/06/07 11:03:34 htank ship $*/

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSP_RECEIVE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrcvb.pls';

Procedure Get_Messages(x_message OUT NOCOPY Varchar2) Is
l_msg_index_out		  NUMBER;
x_msg_data_temp		  Varchar2(2000);
x_msg_data		  Varchar2(4000);
Begin
If fnd_msg_pub.count_msg > 0 Then
  FOR i IN REVERSE 1..fnd_msg_pub.count_msg Loop
	fnd_msg_pub.get(p_msg_index => i,
		   p_encoded => 'F',
		   p_data => x_msg_data_temp,
		   p_msg_index_out => l_msg_index_out);
	x_msg_data := x_msg_data || x_msg_data_temp;
   End Loop;
   x_message := substr(x_msg_data,1,2000);
   -- fnd_msg_pub.delete_msg;
End if;
End;

PROCEDURE gen_receipt_num(
    x_receipt_num     OUT NOCOPY VARCHAR2
  , p_organization_id            NUMBER
  , x_return_status   OUT NOCOPY VARCHAR2
  , x_msg_count       OUT NOCOPY NUMBER
  , x_msg_data        OUT NOCOPY VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_receipt_exists NUMBER;
    l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(400);
    l_progress       VARCHAR2(10);
    l_receipt_code   VARCHAR2(25);
    l_api_name       VARCHAR2(25) := 'gen_receipt_num';
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    UPDATE rcv_parameters
       SET next_receipt_num = next_receipt_num + 1
     WHERE organization_id = p_organization_id
     RETURNING next_receipt_num INTO x_receipt_num;

    COMMIT;

    BEGIN
      SELECT 1
        INTO l_receipt_exists
        FROM rcv_shipment_headers rsh
       WHERE receipt_num = x_receipt_num
         AND ship_to_org_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_receipt_exists  := 0;
      WHEN OTHERS THEN
        RAISE;
    END;

    IF (l_receipt_exists = 1) THEN
        fnd_message.set_name('CSP','CSP_RECEIPT_NUM_EXISTS');
        fnd_message.set_token('RECEIPT',x_receipt_num,false);
       	fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
        fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	fnd_message.set_token('ROUTINE',l_api_name,false);
	fnd_message.set_token('SQLERRM',sqlerrm,false);
       	fnd_msg_pub.add;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
  END gen_receipt_num;

FUNCTION get_employee (emp_id OUT NOCOPY number,
		   emp_name OUT NOCOPY varchar2,
		   location_id OUT NOCOPY number,
		   location_code OUT NOCOPY varchar2,
		   is_buyer OUT NOCOPY BOOLEAN,
                   emp_flag OUT NOCOPY BOOLEAN
		  )
RETURN BOOLEAN IS

X_user_id varchar2(80) ;/* stores the user id */
X_emp_id	NUMBER := 0 ;		/*   stores the employee_id */
X_location_id	NUMBER := 0 ;		/*   stores the location_id */
X_emp_name	VARCHAR2(240) := '' ;	/* stores the employee_name */

X_location_code hr_locations_all.location_code%TYPE :='';
X_buyer_code VARCHAR2(1) := 'Y' ; 	/* dummy, stores buyer status */
mesg_buffer	VARCHAR2(2000) := '' ;  /* for handling error messages */
X_progress varchar2(3) := '';
l_api_name Varchar2(25) := 'get_employee';
x_msg_count number;
x_msg_data varchar2(4000);
x_return_status varchar2(1);

BEGIN
    /* get user id */

    FND_PROFILE.GET('USER_ID', X_user_id);
    if X_user_id is null then
       fnd_message.set_name('CSP','CSP_INVALID_USER_ID');
       fnd_msg_pub.add;
       return False;
    end if;
    BEGIN
        SELECT HR.EMPLOYEE_ID,
               HR.FULL_NAME,
               NVL(HR.LOCATION_ID,0)
        INTO   X_emp_id,
               X_emp_name,
               X_location_id
        FROM   FND_USER FND, PER_EMPLOYEES_CURRENT_X HR
        WHERE  FND.USER_ID = X_user_id
        AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID
        AND    ROWNUM = 1;
    /* if no rows selected
       then user is not an employee
       else user is an employee */

     emp_flag := TRUE;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/* the user is not an employee */
		emp_flag := FALSE ;
		return(TRUE) ;
	WHEN OTHERS THEN
                raise;
    END ;


    /* get location_code */

    IF (X_location_id <> 0) THEN
    BEGIN

        /* if location id belongs to an org
              if the org is in the current set of books
                 return location code
              else
                 return location id is 0

         */
            select hr.location_code
            into   x_location_code
            from   hr_locations hr,
                   financials_system_parameters fsp,
	           hr_organization_information hoi
            where  hr.location_id = x_location_id
            and    hr.inventory_organization_id = hoi.organization_id
            and    to_char(fsp.set_of_books_id) = hoi.org_information1
			AND    ROWNUM = 1;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		X_location_id := 0 ;
	WHEN OTHERS THEN
                raise;
    END ;
    END IF ;

    /* check if employee is a buyer */

    BEGIN
        SELECT 'Y'
        INTO   X_buyer_code
        FROM   PO_AGENTS
        WHERE  agent_id = X_emp_id
        AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE - 1)
                       AND NVL(END_DATE_ACTIVE, SYSDATE + 1);

    /* if no rows returned
       then user is not a buyer
       else user is a buyer */

       is_buyer := TRUE ;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/* user is not a buyer */
		is_buyer := FALSE ;
	WHEN OTHERS THEN
                raise;
    END ;


    /* assign all the local variables to the parameters */

    emp_id := X_emp_id;
    emp_name := X_emp_name ;


    IF (X_location_id <> 0) THEN
        location_id :=  X_location_id ;
	location_code := X_location_code ;
    ELSE
        location_id := '' ;
	location_code := '' ;
    END IF ;

    return(TRUE);
exception
        WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
        return FALSE;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS);
        return FALSE;
        WHEN OTHERS THEN
        fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	fnd_message.set_token('ROUTINE',l_api_name,false);
	fnd_message.set_token('SQLERRM',sqlerrm,false);
       	fnd_msg_pub.add;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
        return FALSE;
END get_employee ;

PROCEDURE receive_shipments
		       (P_Api_Version_Number 	IN NUMBER,
			P_init_Msg_List      	IN VARCHAR2,
    			P_Commit             	IN VARCHAR2,
    			P_Validation_Level   	IN NUMBER,
			p_receive_hdr_rec	IN rcv_hdr_rec_type,
			p_receive_rec_tbl	IN rcv_rec_tbl_type,
    			X_Return_Status      	OUT NOCOPY VARCHAR2,
    			X_Msg_Count             OUT NOCOPY NUMBER,
    		 	X_Msg_Data 		OUT NOCOPY VARCHAR2) IS
l_sqlcode		  NUMBER;
l_sqlerrm		  Varchar2(4000);
l_api_name                CONSTANT VARCHAR2(30) := 'receive_shipments';
l_api_version_number      CONSTANT NUMBER   	:= 1.0;
l_return_status_full      VARCHAR2(1);
x_message		  VARCHAR2(2000);

Cursor c_lot_exists(p_lot_number Varchar2,p_item_id number, p_org_id number) Is
Select 'Y'
FROM  mtl_lot_numbers
WHERE lot_number        = Ltrim(Rtrim(p_lot_number))
AND   inventory_item_id = p_item_id
AND   organization_id   = p_org_id;

Cursor c_serial_exists(p_serial_number Varchar2,p_item_id number) Is
Select 'Y'
FROM mtl_serial_numbers
WHERE serial_number = p_serial_number
AND inventory_item_id = p_item_id;

Cursor c_Subinventory(p_inv_loc_assignment_id number) Is
Select subinventory_code,organization_id
from csp_inv_loc_assignments
where csp_inv_loc_assignment_id = p_inv_loc_assignment_id;

l_organization_id		Number;
l_subinventory 			Varchar2(10);
l_lot_exists			Varchar2(1);
l_serial_exists			Varchar2(1);
l_lot_interface_id		Number;
l_serial_interface_id		Number;
x_serial_transaction_temp_id	Number;
x_interface_transaction_id	Number;
l_header_interface_id		Number;
l_group_id			Number;
l_source_doc_code		Varchar2(25);
L_rcv_transaction_rec		rcv_rec_type;


l_employee_id     	NUMBER;
l_employee_name     	VARCHAR2(240);
l_location_code 	VARCHAR2(60);
l_location_id 		NUMBER;
l_is_buyer 		BOOLEAN;
l_emp_flag 		BOOLEAN;

l_serial_interface_inserted BOOLEAN;

l_module_name varchar2(100) := 'csp.plsql.csp_receive_pvt.receive_shipments';
l_org_id number;
l_org_org_id number;

-- bug # 10401140
l_rcpt_num number;
cursor get_rcpt_num is
select RECEIPT_NUM
from RCV_SHIPMENT_HEADERS
where shipment_header_id = p_receive_hdr_rec.receipt_header_id;

BEGIN
    SAVEPOINT receive_shipments_pvt;
--  MO_GLOBAL.init('CSF');

-- bug # 10425434
-- change context to operating unit where you want to receive the part

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'Trying to get org_id for p_receive_hdr_rec.receipt_header_id = '
            || p_receive_hdr_rec.receipt_header_id);
	end if;

    SELECT reqd.org_id
    INTO l_org_id
    FROM PO_REQ_DISTRIBUTIONS_ALL reqd,
      RCV_SHIPMENT_LINES rsl
    WHERE rsl.shipment_header_id = p_receive_hdr_rec.receipt_header_id
    AND reqd.distribution_id     = rsl.req_distribution_id
    AND rownum                   = 1;

	l_org_org_id := mo_global.get_current_org_id;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_org_id = ' || l_org_id);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_org_org_id = ' || l_org_org_id);
	end if;

	if l_org_org_id is null then
		po_moac_utils_pvt.INITIALIZE;
		l_org_org_id := mo_global.get_current_org_id;
	end if;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_org_id = ' || l_org_id);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_org_org_id = ' || l_org_org_id);
	end if;

	if l_org_id <> nvl(l_org_org_id, -999) and l_org_id is not null then
		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'changing context to l_org_id = ' || l_org_id);
		end if;
		po_moac_utils_pvt.set_org_context(l_org_id);
	end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list
     IF fnd_api.to_boolean(p_init_msg_list) THEN
      	fnd_msg_pub.initialize;
     END IF;


      -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

     If NOT get_employee (l_employee_id,
		   l_employee_name,
		   l_location_id ,
		   l_location_code ,
		   l_is_buyer ,
                   l_emp_flag
		  ) Then
		GET_MESSAGES(x_msg_data);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     End If;

     -- bug # 10401140
	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'p_receive_hdr_rec.receipt_num = ' || p_receive_hdr_rec.receipt_num);
	end if;

     if p_receive_hdr_rec.receipt_num is null then
        l_rcpt_num := null;
        open get_rcpt_num;
        fetch get_rcpt_num into l_rcpt_num;
        close get_rcpt_num;
     else
        l_rcpt_num := p_receive_hdr_rec.receipt_num;
     end if;

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_rcpt_num = ' || l_rcpt_num);
	end if;

      --
      -- API body
      --
   	insert_rcv_hdr_interface
		       (P_Api_Version_Number 	=> 1.0
			,P_init_Msg_List      	=> FND_API.G_FALSE
    			,P_Commit             	=> FND_API.G_FALSE
    			,P_Validation_Level   	=> p_validation_level
    			,X_Return_Status      	=> X_return_Status
    			,X_Msg_Count           	=> X_Msg_Count
    		 	,X_Msg_Data            	=> X_Msg_Data
			,p_header_interface_id  => p_receive_hdr_rec.header_interface_id
			,p_group_id       	=> p_receive_hdr_rec.group_id
			,p_source_type_code 	=> p_receive_hdr_rec.source_type_code
			,p_receipt_source_code 	=> p_receive_hdr_rec.receipt_source_code
			,p_vendor_id		=> p_receive_hdr_rec.vendor_id
			,p_vendor_site_id	=> p_receive_hdr_rec.vendor_site_id
			,p_ship_to_org_id	=> p_receive_hdr_rec.ship_to_org_id
			,p_shipment_num		=> p_receive_hdr_rec.rcv_shipment_num
			,p_receipt_header_id	=> p_receive_hdr_rec.receipt_header_id
			,p_receipt_num		=> l_rcpt_num
			,p_bill_of_lading	=> p_receive_hdr_rec.bill_of_lading
			,p_packing_slip		=> p_receive_hdr_rec.packing_slip
			,p_shipped_date		=> p_receive_hdr_rec.shipped_date
			,p_freight_carrier_code	=> p_receive_hdr_rec.freight_carrier_code
			,p_expected_receipt_date => p_receive_hdr_rec.expected_receipt_date
			,p_employee_id		=> nvl(p_receive_hdr_rec.employee_id,l_employee_id)
			,p_waybill_airbill_num	=> p_receive_hdr_rec.waybill_airbill_num
			,p_usggl_transaction_code => p_receive_hdr_rec.usggl_transaction_code
			,p_processing_request_id => p_receive_hdr_rec.processing_request_id
			,p_customer_id	=>	p_receive_hdr_rec.customer_id
			,p_customer_site_id	=> p_receive_hdr_rec.customer_site_id
			,x_header_interface_id	=> l_header_interface_id
			,x_group_id		=> l_group_id);
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
		Get_Messages(X_MSG_DATA);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
    	FOR i in 1..p_receive_rec_tbl.COUNT LOOP

	If p_receive_rec_tbl(i).inv_loc_assignment_id is not null Then
		open c_subinventory(p_receive_rec_tbl(i).inv_loc_assignment_id);
		fetch c_subinventory into l_subinventory,l_organization_id;
		close c_subinventory;
		else
			l_organization_id :=	p_receive_rec_tbl(i).to_organization_id;
			l_subinventory 	:=	p_receive_rec_tbl(i).destination_subinventory;
	End If;
	l_rcv_transaction_rec := p_receive_rec_tbl(i);
 	l_rcv_transaction_rec.header_interface_id := l_header_interface_id;
 	l_rcv_transaction_rec.group_id := l_group_id;
 	l_rcv_transaction_rec.employee_id := l_employee_id;
	l_rcv_transaction_rec.to_organization_id := l_organization_id;
	l_rcv_transaction_rec.destination_subinventory 	:= l_subinventory;
        l_rcv_transaction_rec.primary_quantity :=
    		rcv_transactions_interface_sv.convert_into_correct_qty(
			l_rcv_transaction_rec.transaction_quantity,
			l_rcv_transaction_rec.transaction_uom,
			l_rcv_transaction_rec.item_id,
			l_rcv_transaction_rec.primary_uom);
    	insert_rcv_txn_interface
		       (P_Api_Version_Number 		=> 1.0
			,P_init_Msg_List      		=> FND_API.G_FALSE
    			,P_Commit             		=> FND_API.G_FALSE
    			,P_Validation_Level   		=> p_Validation_Level
    			,X_Return_Status      		=> X_return_Status
    			,X_Msg_Count             	=> X_Msg_Count
    		 	,X_Msg_Data              	=> X_Msg_Data
			,x_interface_transaction_id => x_interface_transaction_id
			,p_receive_rec		=> l_rcv_transaction_rec);

			If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
				Get_Messages(X_MSG_DATA);
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			End If;
 	l_serial_interface_inserted := FALSE;
        l_serial_interface_id := null;
        l_lot_interface_id := null;
	-- Lot/Serial
	If p_receive_rec_tbl(i).fm_serial_number is not null then
  		insert_serial_interface (
					    p_api_version               => 1.0
					  , p_init_msg_list             => FND_API.G_FALSE
					  , x_return_status             => x_return_status
					  , x_msg_count                 => x_msg_count
					  , x_msg_data                  => x_msg_data
					  , px_transaction_interface_id => l_serial_interface_id
					  , p_product_transaction_id    => x_interface_transaction_id
					  , p_product_code              => p_receive_rec_tbl(i).product_code
					  , p_fm_serial_number          => p_receive_rec_tbl(i).fm_serial_number
					  , p_to_serial_number          => p_receive_rec_tbl(i).to_serial_number);
				If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
					Get_Messages(X_MSG_DATA);
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				End If;
	end if;
	If p_receive_rec_tbl(i).lot_number is not null then
		insert_lots_interface (
				      p_api_version 			=> 1.0
				    , p_init_msg_list    		=> FND_API.G_FALSE
				    , x_return_status  			=> x_return_status
				    , x_msg_count 			=> x_msg_count
				    , x_msg_data 			=> x_msg_data
				    , p_transaction_interface_id   	=> l_lot_interface_id
				    , p_lot_number 			=> p_receive_rec_tbl(i).lot_number
				    , p_transaction_quantity       	=> p_receive_rec_tbl(i).lot_quantity
				    , p_primary_quantity           	=> p_receive_rec_tbl(i).lot_primary_quantity
				    , p_organization_id            	=> p_receive_rec_tbl(i).to_organization_id
				    , p_inventory_item_id          	=> p_receive_rec_tbl(i).item_id
				    , p_serial_transaction_temp_id 	=> l_serial_interface_id
				    , p_product_transaction_id     	=> x_interface_transaction_id
				    , p_product_code               	=> p_receive_rec_tbl(i).product_code);
				If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
					Get_Messages(X_MSG_DATA);
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				End If;
	End If;

END LOOP;

COMMIT;

--- Reestablish the save point
    SAVEPOINT receive_shipments_pvt;
---  Process the interface record
 	rcv_online_request (p_group_id	=> l_group_id,
		 	x_return_status => x_return_status,
	         	x_msg_data      => x_msg_data);
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
		GET_MESSAGES(x_msg_data);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
--- Commit;

	if l_org_id <> l_org_org_id then
		if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
				'changing context to l_org_org_id = ' || l_org_org_id);
		end if;
		po_moac_utils_pvt.set_org_context(l_org_org_id);
	end if;

	COMMIT;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MESSAGE
              ,X_RETURN_STATUS => X_RETURN_STATUS);

        if l_org_id <> l_org_org_id then
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'changing context to l_org_org_id = ' || l_org_org_id);
            end if;
            po_moac_utils_pvt.set_org_context(l_org_org_id);
        end if;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MESSAGE
               ,X_RETURN_STATUS => X_RETURN_STATUS);

        if l_org_id <> l_org_org_id then
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'changing context to l_org_org_id = ' || l_org_org_id);
            end if;
            po_moac_utils_pvt.set_org_context(l_org_org_id);
        end if;

        WHEN OTHERS THEN
        fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	fnd_message.set_token('ROUTINE',l_api_name,false);
	fnd_message.set_token('SQLERRM',sqlerrm,false);
       	fnd_msg_pub.add;
	get_messages(x_msg_data);
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MESSAGE
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

        if l_org_id <> l_org_org_id then
            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'changing context to l_org_org_id = ' || l_org_org_id);
            end if;
            po_moac_utils_pvt.set_org_context(l_org_org_id);
        end if;

END;

PROCEDURE insert_rcv_hdr_interface
		       (P_Api_Version_Number 	IN NUMBER,
			P_init_Msg_List      	IN VARCHAR2,
    			P_Commit             	IN VARCHAR2,
    			P_Validation_Level   	IN NUMBER,
    			X_Return_Status      	OUT NOCOPY VARCHAR2,
    			X_Msg_Count             OUT  NOCOPY NUMBER,
    		 	X_Msg_Data              OUT  NOCOPY VARCHAR2,
			p_header_interface_id   IN NUMBER,
			p_group_id       	IN NUMBER,
			p_receipt_source_code	IN VARCHAR2,
			p_source_type_code	IN VARCHAR2,
			p_vendor_id		IN NUMBER,
			p_vendor_site_id	IN NUMBER,
			p_ship_to_org_id	IN NUMBER,
			p_shipment_num		IN VARCHAR2,
			p_receipt_header_id	IN NUMBER,
			p_receipt_num		IN VARCHAR2,
			p_bill_of_lading	IN VARCHAR2,
			p_packing_slip		IN VARCHAR2,
			p_shipped_date		IN DATE,
			p_freight_carrier_code	IN VARCHAR2,
			p_expected_receipt_date	IN DATE,
			p_employee_id		IN NUMBER,
			p_waybill_airbill_num	IN VARCHAR2,
			p_usggl_transaction_code IN VARCHAR2,
			p_processing_request_id	IN NUMBER,
			p_customer_id		IN NUMBER,
			p_customer_site_id	IN NUMBER,
			x_header_interface_id 	OUT NOCOPY NUMBER,
			x_group_id 		OUT NOCOPY NUMBER) IS

l_api_name                CONSTANT VARCHAR2(30) := 'INSERT_RCV_HDR_INTERFACE';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_header_interface_id 	NUMBER;
l_group_id		NUMBER;
l_receipt_num     	NUMBER;
l_receipt_header_id     NUMBER;
l_shipment_num          VARCHAR2(30);

BEGIN
    SAVEPOINT insert_rcv_hdr_interface_pvt;

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
      	fnd_msg_pub.initialize;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;


     l_header_interface_id := p_header_interface_id;
     If (l_header_interface_id IS NULL) THEN
     	SELECT  rcv_headers_interface_s.NEXTVAL
     	INTO    l_header_interface_id
     	FROM    sys.dual;
     End If;

     l_group_id := p_group_id;
     If (l_group_id IS NULL) THEN
     	SELECT  rcv_interface_groups_s.NEXTVAL
     	INTO    l_group_id
     	FROM    sys.dual;
     End If;
     l_receipt_num := p_receipt_num;
     If l_receipt_num is NULL Then
     		gen_receipt_num(
		    x_receipt_num     => l_receipt_num
		  , p_organization_id  => p_ship_to_org_id
		  , x_return_status   => x_return_status
		  , x_msg_count       => x_msg_count
	  	  , x_msg_data        => x_msg_data);
	If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
		GET_MESSAGES(x_msg_data);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;
      End If;
      IF p_source_type_code = 'INTERNAL' THEN
        l_receipt_header_id := p_receipt_header_id;
        l_shipment_num      := p_shipment_num;
      ELSE
        l_receipt_header_id := NULL;
        l_shipment_num      := NULL;
      END IF;

      INSERT INTO RCV_HEADERS_INTERFACE (
	     header_interface_id
	   , group_id
	   , processing_status_code
	   , transaction_type
	   , validation_flag
	   , auto_transact_code
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
	   , receipt_source_code
	   , vendor_id
 	   , vendor_site_id
	   , ship_to_organization_id
	   , shipment_num
	   , receipt_header_id
	   , receipt_num
	   , bill_of_lading
	   , packing_slip
	   , shipped_date
	   , freight_carrier_code
	   , expected_receipt_date
	   , employee_id
	   , waybill_airbill_num
	   , usggl_transaction_code
	   , processing_request_id
	   , customer_id
	   , customer_site_id)
	VALUES
           (l_header_interface_id
	   ,l_group_id
	   ,'PENDING'
	   ,'NEW'
	   ,'Y'
	   ,'RECEIVE'
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , FND_GLOBAL.LOGIN_ID
	   , p_receipt_source_code
	   , p_vendor_id
	   , p_vendor_site_id
	   , p_ship_to_org_id
	   , l_shipment_num
	   , l_receipt_header_id
	   , l_receipt_num
	   , p_bill_of_lading
	   , p_packing_slip
	   , p_shipped_date
	   , p_freight_carrier_code
	   , nvl(p_expected_receipt_date,sysdate)
	   , p_employee_id
	   , p_waybill_airbill_num
	   , p_usggl_transaction_code
	   , p_processing_request_id
	   , p_customer_id
	   , p_customer_site_id);

     x_header_interface_id := l_header_interface_id;
     x_group_id := l_group_id;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
        fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	fnd_message.set_token('ROUTINE',l_api_name,false);
	fnd_message.set_token('SQLERRM',sqlerrm,false);
       	fnd_msg_pub.add;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;


PROCEDURE insert_rcv_txn_interface
		       (P_Api_Version_Number 	IN NUMBER,
			P_init_Msg_List      	IN VARCHAR2,
    			P_Commit             	IN VARCHAR2,
    			P_Validation_Level   	IN NUMBER,
    			X_Return_Status      	OUT NOCOPY VARCHAR2,
    			X_Msg_Count             OUT  NOCOPY NUMBER,
    		 	X_Msg_Data              OUT  NOCOPY VARCHAR2,
			x_interface_transaction_id OUT NOCOPY NUMBER,
			p_receive_rec		IN rcv_rec_type) IS
l_api_name                CONSTANT VARCHAR2(30) := 'INSERT_RCV_TXN_INTERFACE';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_transaction_interface_id Number;
l_source_code 		Number;
l_source_line_id 	Number;
l_interface_transaction_id    NUMBER;
x_message	Varchar2(2000);
l_rcv_transaction_rec rcv_rec_type;
l_auto_transact_code         VARCHAR2(30);
l_shipment_line_id           NUMBER;
l_primary_uom                VARCHAR2(25);
l_blind_receiving_flag       VARCHAR2(1);
l_receipt_source_code        VARCHAR2(30);
l_vendor_id                  NUMBER;
l_vendor_site_id             NUMBER;
l_from_org_id                NUMBER;
l_to_org_id                  NUMBER;
l_source_doc_code            VARCHAR2(30);
l_po_header_id               NUMBER;
l_po_release_id              NUMBER;
l_po_line_id                 NUMBER;
l_po_line_location_id        NUMBER;
l_po_distribution_id         NUMBER;
l_req_line_id                NUMBER;
l_sub_unordered_code         VARCHAR2(30);
l_deliver_to_person_id       NUMBER;
l_location_id                NUMBER;
l_deliver_to_location_id     NUMBER;
l_subinventory               VARCHAR2(10);
l_locator_id                 NUMBER;
l_wip_entity_id              NUMBER;
l_wip_line_id                NUMBER;
l_department_code            VARCHAR2(30);
l_wip_rep_sched_id           NUMBER;
l_wip_oper_seq_num           NUMBER;
l_wip_res_seq_num            NUMBER;
l_bom_resource_id            NUMBER;
l_oe_order_header_id         NUMBER;
l_oe_order_line_id           NUMBER;
l_customer_item_num          NUMBER;
l_customer_id                NUMBER;
l_customer_site_id           NUMBER;
l_rate                       NUMBER;
l_rate_date                  DATE;
l_rate_gl                    NUMBER;
l_shipment_header_id         NUMBER;
l_header_interface_id        NUMBER;
l_lpn_group_id         	     NUMBER;
l_num_of_distributions       NUMBER;
l_validation_flag	     VARCHAR2(1);
l_project_id		     NUMBER;
l_task_id		     NUMBER;

x_available_qty              NUMBER;
x_ordered_qty                NUMBER;
x_primary_qty                NUMBER;
x_tolerable_qty              NUMBER;
x_uom                        VARCHAR2(25);
x_primary_uom                VARCHAR2(25);
x_valid_ship_to_location     BOOLEAN;
x_num_of_distributions       NUMBER;
x_po_distribution_id         NUMBER;
x_destination_type_code      VARCHAR2(30);
x_destination_type_dsp       VARCHAR2(80);
x_deliver_to_location_id     NUMBER;
x_deliver_to_location        VARCHAR2(80);
x_deliver_to_person_id       NUMBER;
x_deliver_to_person          VARCHAR2(240);
x_deliver_to_sub             VARCHAR2(10);
x_deliver_to_locator_id      NUMBER;
x_wip_entity_id              NUMBER;
x_wip_repetitive_schedule_id NUMBER;
x_wip_line_id                NUMBER;
x_wip_operation_seq_num      NUMBER;
x_wip_resource_seq_num       NUMBER;
x_bom_resource_id            NUMBER;
x_to_organization_id         NUMBER;
x_job                        VARCHAR2(80);
x_line_num                   VARCHAR2(10);
x_sequence                   NUMBER;
x_department                 VARCHAR2(40);
x_enforce_ship_to_loc        VARCHAR2(30);
x_allow_substitutes          VARCHAR2(3);
x_routing_id                 NUMBER;
x_qty_rcv_tolerance          NUMBER;
x_qty_rcv_exception          VARCHAR2(30);
x_days_early_receipt         NUMBER;
x_days_late_receipt          NUMBER;
x_rcv_days_exception         VARCHAR2(30);
x_item_revision              VARCHAR2(3);
x_locator_control            NUMBER;
x_inv_destinations           BOOLEAN;
x_rate                       NUMBER;
x_rate_date                  DATE;
x_project_id                 NUMBER;
x_task_id                    NUMBER;
x_req_line_id                NUMBER;
x_pos                        NUMBER;
x_oe_order_line_id           NUMBER;
x_item_id                    NUMBER;
x_org_id                     NUMBER;
x_category_id                NUMBER;
x_category_set_id            NUMBER;
x_routing_name               VARCHAR2(240);
l_operating_unit             NUMBER;
BEGIN
    SAVEPOINT insert_rcv_txn_interface_pvt;

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
      	fnd_msg_pub.initialize;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_rcv_transaction_rec := p_receive_rec;

     l_interface_transaction_id := l_rcv_transaction_rec.interface_transaction_id;
     If (l_interface_transaction_id IS NULL) THEN
    	SELECT  rcv_transactions_interface_s.NEXTVAL
      	INTO    l_interface_transaction_id
      	FROM    sys.dual;
     END IF;

--  call defaulting api
   begin
    rcv_receipts_query_sv.post_query(
      l_rcv_transaction_rec.po_line_location_id
    , l_rcv_transaction_rec.rcv_shipment_line_id
    , l_rcv_transaction_rec.receipt_source_code
    , l_rcv_transaction_rec.to_organization_id
    , l_rcv_transaction_rec.item_id
    , l_rcv_transaction_rec.primary_uom_class
    , l_rcv_transaction_rec.ship_to_location_id
    , l_rcv_transaction_rec.vendor_id
    , l_rcv_transaction_rec.customer_id
    , l_rcv_transaction_rec.item_rev_control_flag_to
    , x_available_qty
    , x_primary_qty
    , x_tolerable_qty
    , x_uom
    , x_primary_uom
    , x_valid_ship_to_location
    , x_num_of_distributions
    , x_po_distribution_id
    , x_destination_type_code
    , x_destination_type_dsp
    , x_deliver_to_location_id
    , x_deliver_to_location
    , x_deliver_to_person_id
    , x_deliver_to_person
    , x_deliver_to_sub
    , x_deliver_to_locator_id
    , x_wip_entity_id
    , x_wip_repetitive_schedule_id
    , x_wip_line_id
    , x_wip_operation_seq_num
    , x_wip_resource_seq_num
    , x_bom_resource_id
    , x_to_organization_id
    , x_job
    , x_line_num
    , x_sequence
    , x_department
    , x_enforce_ship_to_loc
    , x_allow_substitutes
    , x_routing_id
    , x_qty_rcv_tolerance
    , x_qty_rcv_exception
    , x_days_early_receipt
    , x_days_late_receipt
    , x_rcv_days_exception
    , x_item_revision
    , x_locator_control
    , x_inv_destinations
    , x_rate
    , x_rate_date
    , l_rcv_transaction_rec.asn_type
    , l_rcv_transaction_rec.oe_order_header_id
    , l_rcv_transaction_rec.oe_order_line_id
    , l_rcv_transaction_rec.from_organization_id);
    EXCEPTION
	WHEN OTHERS THEN
	    fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	    fnd_message.set_token('ROUTINE','rcv_receipts_query_sv.post_query',false);
	    fnd_message.set_token('SQLERRM',sqlerrm,false);
	    fnd_msg_pub.add;
	    get_messages(x_msg_data);
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;


    IF (NOT x_valid_ship_to_location) THEN
      	l_rcv_transaction_rec.ship_to_location_id := '';
     END IF;

     l_to_org_id := l_rcv_transaction_rec.to_organization_id;

     BEGIN
     	SELECT BLIND_RECEIVING_FLAG
     	INTO   l_blind_receiving_flag
     	FROM   rcv_parameters
     	WHERE  organization_id = l_to_org_id;

     EXCEPTION
	WHEN OTHERS THEN
	    fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	    fnd_message.set_token('ROUTINE','get receiving flag',false);
	    fnd_message.set_token('SQLERRM',sqlerrm,false);
	    fnd_msg_pub.add;
	    get_messages(x_msg_data);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

    IF l_blind_receiving_flag = 'Y' THEN
      l_rcv_transaction_rec.ordered_qty := 0;
    END IF;

    --l_rcv_transaction_rec.destination_type_code_hold := l_rcv_transactions_rec.destination_type_code;

    IF l_rcv_transaction_rec.routing_id is NULL  THEN
	l_rcv_transaction_rec.routing_id := x_routing_id;
    END IF;

    IF l_rcv_transaction_rec.routing_id IN('1', '2') THEN
      l_rcv_transaction_rec.destination_type_code := 'RECEIVING';
      l_rcv_transaction_rec.po_distribution_id := x_po_distribution_id;
      l_rcv_transaction_rec.deliver_to_location_id := x_deliver_to_location_id;
      l_rcv_transaction_rec.deliver_to_person_id := x_deliver_to_person_id;

      IF (x_wip_entity_id > 0) THEN
        l_rcv_transaction_rec.wip_entity_id := x_wip_entity_id;
        l_rcv_transaction_rec.wip_line_id := x_wip_line_id;
        l_rcv_transaction_rec.wip_repetitive_schedule_id := x_wip_repetitive_schedule_id;
        l_rcv_transaction_rec.wip_operation_seq_num := x_wip_operation_seq_num;
        l_rcv_transaction_rec.wip_resource_seq_num := x_wip_resource_seq_num;
        l_rcv_transaction_rec.bom_resource_id := x_bom_resource_id;
      END IF;

      IF x_num_of_distributions <= 1 THEN
        l_rate      := l_rcv_transaction_rec.currency_conversion_rate_pod ;
        l_rate_date := l_rcv_transaction_rec.currency_conversion_date_pod;
      END IF;

      IF l_rcv_transaction_rec.match_option <> 'P' THEN
	l_rate_date := SYSDATE;
        l_rcv_transaction_rec.currency_conversion_date_pod := SYSDATE;

        IF (l_rcv_transaction_rec.currency_code <> l_rcv_transaction_rec.currency_code_sob) THEN
          l_rate := l_rcv_transaction_rec.currency_conversion_rate;

          IF (l_rcv_transaction_rec.currency_conversion_type <> 'User') THEN
            BEGIN
              l_rate_gl :=
                gl_currency_api.get_rate(
                  l_rcv_transaction_rec.set_of_books_id_sob
                , l_rcv_transaction_rec.currency_code
                , l_rcv_transaction_rec.currency_conversion_date_pod
                , l_rcv_transaction_rec.currency_conversion_type
                );
            EXCEPTION
              WHEN OTHERS THEN
                l_rate_gl := NULL;
            END;
          END IF;

          l_rate := l_rate_gl;
        END IF;
      END IF;

     /* IF (
          x_req_line_id IS NOT NULL
          AND x_deliver_to_locator_id IS NOT NULL
          AND NVL(l_rcv_transaction_rec.receipt_source_code, 'VENDOR') <> 'VENDOR'
         ) THEN
        SELECT project_id
             , task_id
          INTO x_project_id
             , x_task_id
          FROM po_req_distributions
         WHERE requisition_line_id = x_req_line_id;
      END IF;

      IF x_project_id IS NOT NULL THEN
        pjm_project_locator.get_defaultprojectlocator(
        			p_organization_id
        		, x_deliver_to_locator_id
        		, x_project_id
        		, x_task_id
        		, x_deliver_to_locator_id);
      END IF; */
    END IF;

    l_receipt_source_code := l_rcv_transaction_rec.receipt_source_code;
    l_source_doc_code := l_rcv_transaction_rec.order_type_code;
    l_to_org_id := l_rcv_transaction_rec.to_organization_id;
    l_sub_unordered_code := l_rcv_transaction_rec.substitute_receipt;

    IF l_rcv_transaction_rec.source_type_code IN('VENDOR', 'ASN') THEN
      l_vendor_id := l_rcv_transaction_rec.vendor_id;
      l_vendor_site_id := l_rcv_transaction_rec.vendor_site_id;
      l_po_header_id := l_rcv_transaction_rec.po_header_id;
      l_po_release_id := l_rcv_transaction_rec.po_release_id;
      l_po_line_id := l_rcv_transaction_rec.po_line_id;
      l_po_line_location_id := l_rcv_transaction_rec.po_line_location_id;
    ELSIF l_rcv_transaction_rec.source_type_code = 'INTERNAL' THEN
      l_req_line_id := l_rcv_transaction_rec.req_line_id;
      l_from_org_id := l_rcv_transaction_rec.from_organization_id;
      l_shipment_line_id := l_rcv_transaction_rec.rcv_shipment_line_id;
    END IF;


    IF l_rcv_transaction_rec.destination_type_code = 'RECEIVING' THEN
      l_auto_transact_code := 'RECEIVE';
      l_location_id  := l_rcv_transaction_rec.ship_to_location_id;
      l_subinventory := l_rcv_transaction_rec.destination_subinventory;
      l_locator_id   := l_rcv_transaction_rec.locator_id;
    ELSE
      l_auto_transact_code := 'DELIVER';
      l_po_distribution_id := l_rcv_transaction_rec.po_distribution_id;
      l_deliver_to_person_id := l_rcv_transaction_rec.deliver_to_person_id;
      l_deliver_to_location_id := l_rcv_transaction_rec.deliver_to_location_id;
      l_subinventory := l_rcv_transaction_rec.destination_subinventory;
      l_locator_id := l_rcv_transaction_rec.locator_id;
      l_location_id := l_rcv_transaction_rec.deliver_to_location_id;

      IF l_rcv_transaction_rec.source_type_code IN('VENDOR', 'ASN') THEN
        l_wip_entity_id := l_rcv_transaction_rec.wip_entity_id;
        l_wip_line_id := l_rcv_transaction_rec.wip_line_id;
        l_department_code := l_rcv_transaction_rec.department_code;
        l_wip_rep_sched_id := l_rcv_transaction_rec.wip_repetitive_schedule_id;
        l_wip_oper_seq_num := l_rcv_transaction_rec.wip_operation_seq_num;
        l_wip_res_seq_num := l_rcv_transaction_rec.wip_resource_seq_num;
        l_bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
      END IF;
    END IF;

    l_sub_unordered_code := l_rcv_transaction_rec.substitute_receipt;

    IF l_rcv_transaction_rec.source_type_code = 'INTERNAL' THEN
        l_shipment_header_id := l_rcv_transaction_rec.rcv_shipment_header_id;
      ELSE
        l_shipment_header_id := NULL;
    END IF;

    l_lpn_group_id := l_rcv_transaction_rec.group_id;
    l_validation_flag := 'Y';
    l_header_interface_id := l_rcv_transaction_rec.header_interface_id;
    l_project_id := NULL;
    l_task_id := NULL;

   l_operating_unit := mo_global.get_current_org_id;

    -- populate DB items in rcv_transaction block
    INSERT INTO rcv_transactions_interface
              (
               interface_transaction_id
             , header_interface_id
             , GROUP_ID
             , last_update_date
             , last_updated_by
             , creation_date
             , created_by
             , last_update_login
             , transaction_type
             , transaction_date
             , processing_status_code
             , processing_mode_code
             , processing_request_id
             , transaction_status_code
             , category_id
             , quantity
             , unit_of_measure
             , interface_source_code
             , interface_source_line_id
             , inv_transaction_id
             , item_id
             , item_description
             , item_revision
             , uom_code
             , employee_id
             , auto_transact_code
             , shipment_header_id
             , shipment_line_id
             , ship_to_location_id
             , primary_quantity
             , primary_unit_of_measure
             , receipt_source_code
             , vendor_id
             , vendor_site_id
             , from_organization_id
             , to_organization_id
             , routing_header_id
             , routing_step_id
             , source_document_code
             , parent_transaction_id
             , po_header_id
             , po_revision_num
             , po_release_id
             , po_line_id
             , po_line_location_id
             , po_unit_price
             , currency_code
             , currency_conversion_type
             , currency_conversion_rate
             , currency_conversion_date
             , po_distribution_id
             , requisition_line_id
             , req_distribution_id
             , charge_account_id
             , substitute_unordered_code
             , receipt_exception_flag
             , accrual_status_code
             , inspection_status_code
             , inspection_quality_code
             , destination_type_code
             , deliver_to_person_id
             , location_id
             , deliver_to_location_id
             , subinventory
             , locator_id
             , wip_entity_id
             , wip_line_id
             , department_code
             , wip_repetitive_schedule_id
             , wip_operation_seq_num
             , wip_resource_seq_num
             , bom_resource_id
             , shipment_num
             , freight_carrier_code
             , bill_of_lading
             , packing_slip
             , shipped_date
             , expected_receipt_date
             , actual_cost
             , transfer_cost
             , transportation_cost
             , transportation_account_id
             , num_of_containers
             , waybill_airbill_num
             , vendor_item_num
             , vendor_lot_num
             , rma_reference
             , comments
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
             , ship_head_attribute_category
             , ship_head_attribute1
             , ship_head_attribute2
             , ship_head_attribute3
             , ship_head_attribute4
             , ship_head_attribute5
             , ship_head_attribute6
             , ship_head_attribute7
             , ship_head_attribute8
             , ship_head_attribute9
             , ship_head_attribute10
             , ship_head_attribute11
             , ship_head_attribute12
             , ship_head_attribute13
             , ship_head_attribute14
             , ship_head_attribute15
             , ship_line_attribute_category
             , ship_line_attribute1
             , ship_line_attribute2
             , ship_line_attribute3
             , ship_line_attribute4
             , ship_line_attribute5
             , ship_line_attribute6
             , ship_line_attribute7
             , ship_line_attribute8
             , ship_line_attribute9
             , ship_line_attribute10
             , ship_line_attribute11
             , ship_line_attribute12
             , ship_line_attribute13
             , ship_line_attribute14
             , ship_line_attribute15
             , ussgl_transaction_code
             , government_context
             , reason_id
             , destination_context
             , source_doc_quantity
             , source_doc_unit_of_measure
             , use_mtl_lot
             , use_mtl_serial
             , qa_collection_id
             , country_of_origin_code
             , oe_order_header_id
             , oe_order_line_id
             , customer_item_num
             , customer_id
             , customer_site_id
             , mobile_txn
             , lpn_group_id
             , validation_flag
             --, project_id
             --, task_id
             ,org_id
              )
       VALUES (
               l_interface_transaction_id
	     , l_header_interface_id --l_rcv_transaction_rec.header_interface_id
             , l_rcv_transaction_rec.group_id
             , SYSDATE
             , FND_GLOBAL.USER_ID
             , SYSDATE
             , FND_GLOBAL.USER_ID
             , FND_GLOBAL.LOGIN_ID
             , 'RECEIVE'
             , SYSDATE
             , 'PENDING'  /* Processing status code */
	     , 'ONLINE'
             , NULL
             , 'PENDING'  /* Transaction status code */
             , l_rcv_transaction_rec.item_category_id
             , l_rcv_transaction_rec.transaction_quantity
             , l_rcv_transaction_rec.transaction_uom
             , l_rcv_transaction_rec.product_code  /* interface source code */
             , NULL  /* interface source line id */
             , NULL  /* inv_transaction id */
             , l_rcv_transaction_rec.item_id
             , l_rcv_transaction_rec.item_description
             , l_rcv_transaction_rec.item_revision
             , l_rcv_transaction_rec.uom_code
             , l_rcv_transaction_rec.employee_id
             , l_auto_transact_code  /* Auto transact code */
             , l_shipment_header_id  /* shipment header id */
             , l_shipment_line_id  /* shipment line id */
             , l_rcv_transaction_rec.ship_to_location_id
             , l_rcv_transaction_rec.primary_quantity  /* primary quantity */
             , l_rcv_transaction_rec.primary_uom  /* primary uom */
             , l_receipt_source_code  /* receipt source code */
             , l_vendor_id
             , l_vendor_site_id
             , l_from_org_id  /* from org id */
             , l_to_org_id  /* to org id */
             , l_rcv_transaction_rec.routing_id
             , 1  /* routing step id*/
             , l_source_doc_code  /* source document code */
             , NULL  /* Parent trx id */
             , l_po_header_id
             , NULL  /* PO Revision number */
             , l_po_release_id
             , l_po_line_id
             , l_po_line_location_id
             , l_rcv_transaction_rec.unit_price
             , l_rcv_transaction_rec.currency_code  /* Currency_Code */
             , l_rcv_transaction_rec.currency_conversion_type
             , l_rcv_transaction_rec.currency_conversion_rate
             , TRUNC(l_rcv_transaction_rec.currency_conversion_date)
             , l_po_distribution_id /* po_distribution_Id */
             , l_req_line_id
             , l_rcv_transaction_rec.req_distribution_id
             , NULL  /* Charge_Account_Id */
             , l_sub_unordered_code  /* Substitute_Unordered_Code */
             , l_rcv_transaction_rec.receipt_exception  /* Receipt_Exception_Flag  forms check box?*/
             , NULL  /* Accrual_Status_Code */
             , 'NOT INSPECTED'  /* Inspection_Status_Code */
             , NULL  /* Inspection_Quality_Code */
             , l_rcv_transaction_rec.destination_type_code  /* Destination_Type_Code */
             , l_deliver_to_person_id  /* Deliver_To_Person_Id */
             , l_location_id  /* Location_Id */
             , l_deliver_to_location_id  /* Deliver_To_Location_Id */
             , l_subinventory  /* Subinventory */
             , l_locator_id  /* Locator_Id */
             , l_wip_entity_id  /* Wip_Entity_Id */
             , l_wip_line_id  /* Wip_Line_Id */
             , l_department_code  /* Department_Code */
             , l_wip_rep_sched_id  /* Wip_Repetitive_Schedule_Id */
             , l_wip_oper_seq_num  /* Wip_Operation_Seq_Num */
             , l_wip_res_seq_num  /* Wip_Resource_Seq_Num */
             , l_bom_resource_id  /* Bom_Resource_Id */
             , l_rcv_transaction_rec.rcv_shipment_number
             , NULL
             , NULL  /* Bill_Of_Lading */
             , NULL  /* Packing_Slip */
             , TRUNC(l_rcv_transaction_rec.shipped_date)
             , TRUNC(l_rcv_transaction_rec.expected_receipt_date)  /* Expected_Receipt_Date */
             , NULL  /* Actual_Cost */
             , NULL  /* Transfer_Cost */
             , NULL  /* Transportation_Cost */
             , NULL  /* Transportation_Account_Id */
             , NULL  /* Num_Of_Containers */
             , NULL  /* Waybill_Airbill_Num */
             , l_rcv_transaction_rec.vendor_item_number  /* Vendor_Item_Num */
             , l_rcv_transaction_rec.vendor_lot_num  /* Vendor_Lot_Num */
             , NULL  /* Rma_Reference */
             , l_rcv_transaction_rec.comments  /* Comments  ? from form*/
             , l_rcv_transaction_rec.attribute_category  /* Attribute_Category */
             , l_rcv_transaction_rec.attribute1  /* Attribute1 */
             , l_rcv_transaction_rec.attribute2  /* Attribute2 */
             , l_rcv_transaction_rec.attribute3  /* Attribute3 */
             , l_rcv_transaction_rec.attribute4  /* Attribute4 */
             , l_rcv_transaction_rec.attribute5  /* Attribute5 */
             , l_rcv_transaction_rec.attribute6  /* Attribute6 */
             , l_rcv_transaction_rec.attribute7  /* Attribute7 */
             , l_rcv_transaction_rec.attribute8  /* Attribute8 */
             , l_rcv_transaction_rec.attribute9  /* Attribute9 */
             , l_rcv_transaction_rec.attribute10  /* Attribute10 */
             , l_rcv_transaction_rec.attribute11  /* Attribute11 */
             , l_rcv_transaction_rec.attribute12  /* Attribute12 */
             , l_rcv_transaction_rec.attribute13  /* Attribute13 */
             , l_rcv_transaction_rec.attribute14  /* Attribute14 */
             , l_rcv_transaction_rec.attribute15  /* Attribute15 */
             , NULL  /* Ship_Head_Attribute_Category */
             , NULL  /* Ship_Head_Attribute1 */
             , NULL  /* Ship_Head_Attribute2 */
             , NULL  /* Ship_Head_Attribute3 */
             , NULL  /* Ship_Head_Attribute4 */
             , NULL  /* Ship_Head_Attribute5 */
             , NULL  /* Ship_Head_Attribute6 */
             , NULL  /* Ship_Head_Attribute7 */
             , NULL  /* Ship_Head_Attribute8 */
             , NULL  /* Ship_Head_Attribute9 */
             , NULL  /* Ship_Head_Attribute10 */
             , NULL  /* Ship_Head_Attribute11 */
             , NULL  /* Ship_Head_Attribute12 */
             , NULL  /* Ship_Head_Attribute13 */
             , NULL  /* Ship_Head_Attribute14 */
             , NULL  /* Ship_Head_Attribute15 */
             , NULL  /* Ship_Line_Attribute_Category */
             , NULL  /* Ship_Line_Attribute1 */
             , NULL  /* Ship_Line_Attribute2 */
             , NULL  /* Ship_Line_Attribute3 */
             , NULL  /* Ship_Line_Attribute4 */
             , NULL  /* Ship_Line_Attribute5 */
             , NULL  /* Ship_Line_Attribute6 */
             , NULL  /* Ship_Line_Attribute7 */
             , NULL  /* Ship_Line_Attribute8 */
             , NULL  /* Ship_Line_Attribute9 */
             , NULL  /* Ship_Line_Attribute10 */
             , NULL  /* Ship_Line_Attribute11 */
             , NULL  /* Ship_Line_Attribute12 */
             , NULL  /* Ship_Line_Attribute13 */
             , NULL  /* Ship_Line_Attribute14 */
             , NULL  /* Ship_Line_Attribute15 */
             , l_rcv_transaction_rec.ussgl_transaction_code  /* Ussgl_Transaction_Code */
             , l_rcv_transaction_rec.government_context  /* Government_Context */
             , l_rcv_transaction_rec.reason_id  /* ? */
             , l_rcv_transaction_rec.destination_type_code  /* Destination_Context */
             , l_rcv_transaction_rec.ordered_qty
             , l_rcv_transaction_rec.ordered_uom
             , l_rcv_transaction_rec.lot_control_code
             , l_rcv_transaction_rec.serial_number_control_code
             , NULL
             , l_rcv_transaction_rec.country_of_origin_code
             , l_oe_order_header_id
             , l_oe_order_line_id
             , l_customer_item_num
             , l_customer_id
             , l_customer_site_id
	     , 'N' /* mobile_txn */
	     , NULL -- l_lpn_group_id
	     , l_validation_flag
             --, l_project_id
             --, l_task_id
             ,l_operating_unit
              );

      	x_interface_transaction_id :=  l_interface_transaction_id;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MESSAGE
              ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MESSAGE
               ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
        fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
	fnd_message.set_token('ROUTINE',l_api_name,false);
	fnd_message.set_token('SQLERRM',sqlerrm,false);
       	fnd_msg_pub.add;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MESSAGE
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;

PROCEDURE insert_lots_interface (
      p_api_version                IN             NUMBER
    , p_init_msg_list              IN             VARCHAR2
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_serial_transaction_temp_id IN   	NUMBER
    , p_transaction_interface_id   IN 		NUMBER
    , p_lot_number                 IN             VARCHAR2
    , p_transaction_quantity       IN             NUMBER
    , p_primary_quantity           IN             NUMBER
    , p_organization_id            IN             NUMBER
    , p_inventory_item_id          IN             NUMBER
    , p_product_transaction_id     IN 		NUMBER
    , p_product_code               IN             VARCHAR2) IS
    CURSOR c_mln_attributes(  v_lot_number        VARCHAR2
                            , v_inventory_item_id NUMBER
                            , v_organization_id   NUMBER) IS
      SELECT lot_number
         , expiration_date
         , description
         , vendor_name
         , supplier_lot_number
         , grade_code
         , origination_date
         , date_code
         , status_id
         , change_date
         , age
         , retest_date
         , maturity_date
         , item_size
         , color
         , volume
         , volume_uom
         , place_of_origin
         , best_by_date
         , LENGTH
         , length_uom
         , recycled_content
         , thickness
         , thickness_uom
         , width
         , width_uom
         , curl_wrinkle_fold
         , vendor_id
         , territory_code
         , lot_attribute_category
         , c_attribute1
         , c_attribute2
         , c_attribute3
         , c_attribute4
         , c_attribute5
         , c_attribute6
         , c_attribute7
         , c_attribute8
         , c_attribute9
         , c_attribute10
         , c_attribute11
         , c_attribute12
         , c_attribute13
         , c_attribute14
         , c_attribute15
         , c_attribute16
         , c_attribute17
         , c_attribute18
         , c_attribute19
         , c_attribute20
         , d_attribute1
         , d_attribute2
         , d_attribute3
         , d_attribute4
         , d_attribute5
         , d_attribute6
         , d_attribute7
         , d_attribute8
         , d_attribute9
         , d_attribute10
         , n_attribute1
         , n_attribute2
         , n_attribute3
         , n_attribute4
         , n_attribute5
         , n_attribute6
         , n_attribute7
         , n_attribute8
         , n_attribute9
         , n_attribute10
      FROM  mtl_lot_numbers
      WHERE lot_number        = Ltrim(Rtrim(v_lot_number))
      AND   inventory_item_id = v_inventory_item_id
      AND   organization_id   = v_organization_id;


    l_lot_number          mtl_lot_numbers.lot_number%type;
    l_expiration_date     mtl_lot_numbers.expiration_date%type;
    l_description         mtl_lot_numbers.description%type;
    l_vendor_name         mtl_lot_numbers.vendor_name%type;
    l_supplier_lot_number mtl_lot_numbers.supplier_lot_number%type;
    l_grade_code          mtl_lot_numbers.grade_code%type;
    l_origination_date    mtl_lot_numbers.origination_date%type;
    l_date_code	          mtl_lot_numbers.date_code%type;
    l_status_id	          mtl_lot_numbers.status_id%type;
    l_change_date         mtl_lot_numbers.change_date%type;
    l_age                 mtl_lot_numbers.age%type;
    l_retest_date         mtl_lot_numbers.retest_date%type;
    l_maturity_date       mtl_lot_numbers.maturity_date%type;
    l_item_size	          mtl_lot_numbers.item_size%type;
    l_color               mtl_lot_numbers.color%type;
    l_volume              mtl_lot_numbers.volume%type;
    l_volume_uom          mtl_lot_numbers.volume_uom%type;
    l_place_of_origin     mtl_lot_numbers.place_of_origin%type;
    l_best_by_date        mtl_lot_numbers.best_by_date%type;
    l_length              mtl_lot_numbers.length%type;
    l_length_uom          mtl_lot_numbers.length_uom%type;
    l_recycled_content    mtl_lot_numbers.recycled_content%type;
    l_thickness           mtl_lot_numbers.thickness%type;
    l_thickness_uom       mtl_lot_numbers.thickness_uom%type;
    l_width               mtl_lot_numbers.width%type;
    l_width_uom           mtl_lot_numbers.width_uom%type;
    l_curl_wrinkle_fold   mtl_lot_numbers.curl_wrinkle_fold%type;
    l_vendor_id           mtl_lot_numbers.vendor_id%type;
    l_territory_code      mtl_lot_numbers.territory_code%type;
    l_lot_attribute_category  mtl_lot_numbers.lot_attribute_category%type;
    l_c_attribute1        mtl_lot_numbers.c_attribute1%type ;
    l_c_attribute2        mtl_lot_numbers.c_attribute2%type;
    l_c_attribute3        mtl_lot_numbers.c_attribute3%type;
    l_c_attribute4        mtl_lot_numbers.c_attribute4%type;
    l_c_attribute5        mtl_lot_numbers.c_attribute5%type;
    l_c_attribute6        mtl_lot_numbers.c_attribute6%type;
    l_c_attribute7        mtl_lot_numbers.c_attribute7%type;
    l_c_attribute8        mtl_lot_numbers.c_attribute8%type;
    l_c_attribute9        mtl_lot_numbers.c_attribute9%type;
    l_c_attribute10       mtl_lot_numbers.c_attribute10%type ;
    l_c_attribute11       mtl_lot_numbers.c_attribute11%type ;
    l_c_attribute12       mtl_lot_numbers.c_attribute12%type;
    l_c_attribute13       mtl_lot_numbers.c_attribute13%type;
    l_c_attribute14       mtl_lot_numbers.c_attribute14%type;
    l_c_attribute15       mtl_lot_numbers.c_attribute15%type;
    l_c_attribute16       mtl_lot_numbers.c_attribute16%type;
    l_c_attribute17       mtl_lot_numbers.c_attribute17%type;
    l_c_attribute18       mtl_lot_numbers.c_attribute18%type;
    l_c_attribute19       mtl_lot_numbers.c_attribute19%type;
    l_c_attribute20       mtl_lot_numbers.c_attribute20%type;
    l_d_attribute1        mtl_lot_numbers.d_attribute1%type ;
    l_d_attribute2        mtl_lot_numbers.d_attribute2%type;
    l_d_attribute3        mtl_lot_numbers.d_attribute3%type;
    l_d_attribute4        mtl_lot_numbers.d_attribute4%type;
    l_d_attribute5        mtl_lot_numbers.d_attribute5%type;
    l_d_attribute6        mtl_lot_numbers.d_attribute6%type;
    l_d_attribute7        mtl_lot_numbers.d_attribute7%type;
    l_d_attribute8        mtl_lot_numbers.d_attribute8%type;
    l_d_attribute9        mtl_lot_numbers.d_attribute9%type;
    l_d_attribute10       mtl_lot_numbers.d_attribute10%type;
    l_n_attribute1        mtl_lot_numbers.n_attribute1%type ;
    l_n_attribute2        mtl_lot_numbers.n_attribute2%type ;
    l_n_attribute3        mtl_lot_numbers.n_attribute3%type ;
    l_n_attribute4        mtl_lot_numbers.n_attribute4%type;
    l_n_attribute5        mtl_lot_numbers.n_attribute5%type;
    l_n_attribute6        mtl_lot_numbers.n_attribute6%type;
    l_n_attribute7        mtl_lot_numbers.n_attribute7%type ;
    l_n_attribute8        mtl_lot_numbers.n_attribute8%type;
    l_n_attribute9        mtl_lot_numbers.n_attribute9%type;
    l_n_attribute10       mtl_lot_numbers.n_attribute10%type ;
    l_source_code         mtl_transaction_lots_interface.source_code%TYPE;
    l_source_line_id      mtl_transaction_lots_interface.source_line_id%TYPE;
    l_serial_control_code mtl_system_items.serial_number_control_code%TYPE;

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'insert_lots_interface';
    l_transaction_interface_id Number;

    x_message		  Varchar2(4000);

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, G_PKG_NAME) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_transaction_interface_id := p_transaction_interface_id;
     If (l_transaction_interface_id IS NULL) THEN
    	SELECT  mtl_material_transactions_s.NEXTVAL
      	INTO    l_transaction_interface_id
      	FROM    sys.dual;
     END IF;

     OPEN  c_mln_attributes(p_lot_number, p_inventory_item_id, p_organization_id);
     FETCH c_mln_attributes INTO
           l_lot_number
         , l_expiration_date
         , l_description
         , l_vendor_name
         , l_supplier_lot_number
         , l_grade_code
         , l_origination_date
         , l_date_code
         , l_status_id
         , l_change_date
         , l_age
         , l_retest_date
         , l_maturity_date
         , l_item_size
         , l_color
         , l_volume
         , l_volume_uom
         , l_place_of_origin
         , l_best_by_date
         , l_length
         , l_length_uom
         , l_recycled_content
         , l_thickness
         , l_thickness_uom
         , l_width
         , l_width_uom
         , l_curl_wrinkle_fold
         , l_vendor_id
         , l_territory_code
         , l_lot_attribute_category
         , l_c_attribute1
         , l_c_attribute2
         , l_c_attribute3
         , l_c_attribute4
         , l_c_attribute5
         , l_c_attribute6
         , l_c_attribute7
         , l_c_attribute8
         , l_c_attribute9
         , l_c_attribute10
         , l_c_attribute11
         , l_c_attribute12
         , l_c_attribute13
         , l_c_attribute14
         , l_c_attribute15
         , l_c_attribute16
         , l_c_attribute17
         , l_c_attribute18
         , l_c_attribute19
         , l_c_attribute20
         , l_d_attribute1
         , l_d_attribute2
         , l_d_attribute3
         , l_d_attribute4
         , l_d_attribute5
         , l_d_attribute6
         , l_d_attribute7
         , l_d_attribute8
         , l_d_attribute9
         , l_d_attribute10
         , l_n_attribute1
         , l_n_attribute2
         , l_n_attribute3
         , l_n_attribute4
         , l_n_attribute5
         , l_n_attribute6
         , l_n_attribute7
         , l_n_attribute8
         , l_n_attribute9
         , l_n_attribute10;
       CLOSE c_mln_attributes;
    INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
             transaction_interface_id
           , source_code
           , source_line_id
	   , product_code
	   , product_transaction_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , lot_number
           , lot_expiration_date
           , transaction_quantity
           , primary_quantity
           , serial_transaction_temp_id
           , description
           , vendor_name
           , supplier_lot_number
           , origination_date
           , date_code
           , grade_code
           , change_date
           , maturity_date
           , status_id
           , retest_date
           , age
           , item_size
           , color
           , volume
           , volume_uom
           , place_of_origin
           , best_by_date
           , length
           , length_uom
           , recycled_content
           , thickness
           , thickness_uom
           , width
           , width_uom
           , curl_wrinkle_fold
           , lot_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
           , vendor_id
           , territory_code
            )
    VALUES (
             l_transaction_interface_id
           , 1
           , -1
	   , p_product_code
           , p_product_transaction_id
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , FND_GLOBAL.LOGIN_ID
           , Ltrim(Rtrim(p_lot_number))
           , l_expiration_date
           , p_transaction_quantity
           , p_primary_quantity
           , p_serial_transaction_temp_id
           , l_description
           , l_vendor_name
           , l_supplier_lot_number
           , l_origination_date
           , l_date_code
           , l_grade_code
           , l_change_date
           , l_maturity_date
           , l_status_id
           , l_retest_date
           , l_age
           , l_item_size
           , l_color
           , l_volume
           , l_volume_uom
           , l_place_of_origin
           , l_best_by_date
           , l_length
           , l_length_uom
           , l_recycled_content
           , l_thickness
           , l_thickness_uom
           , l_width
           , l_width_uom
           , l_curl_wrinkle_fold
           , l_lot_attribute_category
           , l_c_attribute1
           , l_c_attribute2
           , l_c_attribute3
           , l_c_attribute4
           , l_c_attribute5
           , l_c_attribute6
           , l_c_attribute7
           , l_c_attribute8
           , l_c_attribute9
           , l_c_attribute10
           , l_c_attribute11
           , l_c_attribute12
           , l_c_attribute13
           , l_c_attribute14
           , l_c_attribute15
           , l_c_attribute16
           , l_c_attribute17
           , l_c_attribute18
           , l_c_attribute19
           , l_c_attribute20
           , l_d_attribute1
           , l_d_attribute2
           , l_d_attribute3
           , l_d_attribute4
           , l_d_attribute5
           , l_d_attribute6
           , l_d_attribute7
           , l_d_attribute8
           , l_d_attribute9
           , l_d_attribute10
           , l_n_attribute1
           , l_n_attribute2
           , l_n_attribute3
           , l_n_attribute4
           , l_n_attribute5
           , l_n_attribute6
           , l_n_attribute7
           , l_n_attribute8
           , l_n_attribute9
           , l_n_attribute10
           , l_vendor_id
           , l_territory_code
            );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MESSAGE
              ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MESSAGE
               ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
      fnd_message.set_token('ROUTINE',l_api_name,false);
      fnd_message.set_token('SQLERRM',sqlerrm,false);
      fnd_msg_pub.add;
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
  END;

  /*----------------------------------------------------------------------------
    * PROCEDURE:
    * Description:
    *   This procedure inserts a record into MTL_SERIAL_NUMBERS_INTERFACE
    *     Generate transaction_interface_id if the parameter is NULL
    *     Generate product_transaction_id if the parameter is NULL
    *     The insert logic is based on the parameter p_att_exist.
    *     If p_att_exist is "N" Then (attributes are not available in table)
    *       Read the input parameters (including attributes) into a PL/SQL table
    *       Insert one record into MSNI with the from and to serial numbers passed
    *     Else
    *       Loop through each serial number between the from and to serial number
    *       Fetch the attributes into one row of the PL/SQL table and
    *     For each row in the PL/SQL table, insert one MSNI record
    *     End If
    *
    *    @param p_api_version             - Version of the API
    *    @param p_init_msg_list            - Flag to initialize message list
    *    @param x_return_status
    *      Return status indicating Success (S), Error (E), Unexpected Error (U)
    *    @param x_msg_count
    *      Number of messages in  message list
    *    @param x_msg_data
    *      Stacked messages text
    *    @param p_transaction_interface_id - MTLI.Interface Transaction ID
    *    @param p_fm_serial_number         - From Serial Number
    *    @param p_to_serial_number         - To Serial Number
    *    @param p_organization_id         - Organization ID
    *    @param p_inventory_item_id       - Inventory Item ID
    *    @param p_status_id               - Material Status for the lot
    *    @param p_product_transaction_id  - Product Transaction Id. This parameter
    *           is stamped with the transaction identifier with
    *    @param p_product_code            - Code of the product creating this record
    *    @param p_att_exist               - Flag to indicate if attributes exist
    *    @param p_update_msn              - Flag to update MSN with attributes
    *    @param named attributes          - Named attributes
    *    @param C Attributes              - Character atributes (1 - 20)
    *    @param D Attributes              - Date atributes (1 - 10)
    *    @param N Attributes              - Number atributes (1 - 10)
    *    @param p_attribute_cateogry      - Attribute Category
    *    @param Attribute1-15             - Serial Attributes
    *
    * @ return: NONE
    *---------------------------------------------------------------------------*/

  PROCEDURE insert_serial_interface(
		    p_api_version               IN            NUMBER
		  , p_init_msg_list             IN            VARCHAR2
		  , x_return_status             OUT    NOCOPY VARCHAR2
		  , x_msg_count                 OUT    NOCOPY NUMBER
		  , x_msg_data                  OUT    NOCOPY VARCHAR2
		  , px_transaction_interface_id IN OUT NOCOPY NUMBER
		  , p_product_transaction_id    IN 	      NUMBER
		  , p_product_code              IN            VARCHAR2
		  , p_fm_serial_number          IN            VARCHAR2
		  , p_to_serial_number          IN            VARCHAR2
  ) IS

  l_api_version         	CONSTANT NUMBER := 1.0;
  l_api_name            	CONSTANT VARCHAR2(30) := 'insert_serial_interface';

  l_transaction_interface_id Number;

  x_message varchar2(4000);
  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version,
				       p_api_version,
              				l_api_name,
					G_PKG_NAME) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status  := fnd_api.g_ret_sts_success;

    --Generate transaction_interface_id if necessary
    l_transaction_interface_id := px_transaction_interface_id;
    IF (l_transaction_interface_id IS NULL) THEN
      SELECT  mtl_material_transactions_s.NEXTVAL
      INTO    l_transaction_interface_id
      FROM    sys.dual;
    END IF;

    Insert into MTL_SERIAL_NUMBERS_INTERFACE
	     (
		      transaction_interface_id,
		      Source_Code,
		      Source_Line_Id,
		      Process_flag,
		      Last_Update_Date,
		      Last_Updated_By,
		      Last_update_login,
		      Creation_Date,
		      Created_By,
		      Fm_Serial_Number,
		      To_Serial_Number,
		      PRODUCT_CODE,
		      PRODUCT_TRANSACTION_ID)
     	VALUES
	     	(
		      l_transaction_interface_id,
		      1,
		      -1,
		      1,
		      SYSDATE
           	      ,FND_GLOBAL.USER_ID
           	      ,FND_GLOBAL.LOGIN_ID
		      ,sysdate
           	      ,FND_GLOBAL.USER_ID
		      ,p_fm_serial_number
		      ,p_to_serial_number
		      ,p_product_code
		      ,p_product_transaction_id);

    px_transaction_interface_id := l_transaction_interface_id;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MESSAGE
              ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MESSAGE
               ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
      fnd_message.set_token('ROUTINE',l_api_name,false);
      fnd_message.set_token('SQLERRM',sqlerrm,false);
      fnd_msg_pub.add;
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME 	=> L_API_NAME
                  ,P_PKG_NAME 	=> G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE 	=> JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT 		=> X_MSG_COUNT
                  ,X_MSG_DATA 	=> X_MESSAGE
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;

PROCEDURE rcv_online_request (p_group_id IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
			      x_msg_data      OUT NOCOPY VARCHAR2)
  IS
   rc NUMBER;
   l_api_name varchar2(20) := 'rcv_online_request';
   l_timeout NUMBER := 300;
   l_outcome VARCHAR2(200) := NULL;
   l_message VARCHAR2(4000) := NULL;
   x_str varchar2(6000) := NULL;
   r_val1 varchar2(300) := NULL;
   r_val2 varchar2(300) := NULL;
   r_val3 varchar2(300) := NULL;
   r_val4 varchar2(300) := NULL;
   r_val5 varchar2(300) := NULL;
   r_val6 varchar2(300) := NULL;
   r_val7 varchar2(300) := NULL;
   r_val8 varchar2(300) := NULL;
   r_val9 varchar2(300) := NULL;
   r_val10 varchar2(300) := NULL;
   r_val11 varchar2(300) := NULL;
   r_val12 varchar2(300) := NULL;
   r_val13 varchar2(300) := NULL;
   r_val14 varchar2(300) := NULL;
   r_val15 varchar2(300) := NULL;
   r_val16 varchar2(300) := NULL;
   r_val17 varchar2(300) := NULL;
   r_val18 varchar2(300) := NULL;
   r_val19 varchar2(300) := NULL;
   r_val20 varchar2(300) := NULL;
   po_message varchar2(2000);

   l_module_name varchar2(100) := 'csp.plsql.csp_receive_pvt.rcv_online_request';
BEGIN

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Begin for p_group_id = ' || p_group_id);
    end if;

   x_return_status := fnd_api.g_ret_sts_success;

   rc := fnd_transaction.synchronous
     (
      l_timeout, l_outcome, l_message, 'PO', 'RCVTPO',
      'ONLINE',p_group_id,
      NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL);

	if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'rc = ' || rc);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_outcome = ' || l_outcome);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			'l_message = ' || l_message);
	end if;

    IF (rc =  1) THEN
        fnd_message.set_name('FND', 'TM-TIMEOUT');
        FND_MESSAGE.set_name('FND','CONC-Error running standalone');
        fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
        fnd_message.set_token('REQUEST', p_group_id);
        fnd_message.set_token('REASON', x_str);
        fnd_msg_pub.ADD;
        x_return_status := fnd_api.g_ret_sts_error;
    ELSIF (rc =  2) THEN
        fnd_message.set_name('FND', 'TM-SVC LOCK HANDLE FAILED');
        FND_MESSAGE.set_name('FND','CONC-Error running standalone');
        fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
        fnd_message.set_token('REQUEST', p_group_id);
        fnd_message.set_token('REASON', x_str);
        fnd_msg_pub.ADD;
        x_return_status := fnd_api.g_ret_sts_error;
    ELSIF (rc = 3 or (l_outcome IN ('WARNING', 'ERROR'))) THEN
        BEGIN
            select ERROR_MESSAGE  INTO po_message
            from po_interface_errors
            where BATCH_ID = p_group_id;

            if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'po_message = ' || po_message);
            end if;

            FND_MESSAGE.set_name('CSP', 'CSP_ATP');
            fnd_message.set_token('ERROR', po_message);
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
        Exception
            when NO_DATA_FOUND THEN

                rc := fnd_transaction.get_values
                (
                r_val1, r_val2, r_val3, r_val4, r_val5, r_val6,
                r_val7, r_val8, r_val9, r_val10, r_val11, r_val12,
                r_val13, r_val14, r_val15, r_val16, r_val17, r_val18,
                r_val19, r_val20);
                x_str := r_val1;

                IF (r_val2 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val2;
                END IF;
                IF (r_val3 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val3;
                END IF;
                IF (r_val4 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val4;
                END IF;
                IF (r_val5 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val5;
                END IF;
                IF (r_val6 IS NOT NULL)  THEN
                    x_str := x_str || ' '  || r_val6;
                END IF;
                IF (r_val7 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val7;
                END IF;
                IF (r_val8 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val8;
                END IF;
                IF (r_val9 IS NOT NULL)  THEN
                    x_str := x_str || ' ' || r_val9;
                END IF;
                IF (r_val10 IS NOT NULL) THEN
                    x_str := x_str || ' ' || r_val10;
                END IF;
                IF (r_val11 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val11;
                END IF;
                IF (r_val12 IS NOT NULL) THEN
                    x_str := x_str || ' ' || r_val12;
                END IF;
                IF (r_val13 IS NOT NULL) THEN
                    x_str := x_str || ' ' || r_val13;
                END IF;
                IF (r_val14 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val14;
                END IF;
                IF (r_val15 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val15;
                END IF;
                IF (r_val16 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val16;
                END IF;
                IF (r_val17 IS NOT NULL) THEN
                    x_str := x_str || ' ' || r_val17;
                END IF;
                IF (r_val18 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val18;
                END IF;
                IF (r_val19 IS NOT NULL) THEN
                    x_str := x_str || ' '|| r_val19;
                END IF;
                IF (r_val20 IS NOT NULL) THEN
                    x_str := x_str || ' ' || r_val20;
                END IF;

                if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'x_str = ' || x_str);
                end if;

                if l_message is not null then
                    l_message := l_message || '; ' || x_str;
                else
                    l_message := x_str;
                end if;

                FND_MESSAGE.set_name('FND','CONC-Error running standalone');
                fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
                fnd_message.set_token('REQUEST', p_group_id);
                fnd_message.set_token('REASON', l_message);
                fnd_msg_pub.ADD;
                x_return_status := fnd_api.g_ret_sts_error;
        END;
      END IF;
EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('CSP','CSP_UNEXPECTED_EXEC_ERRORS');
      fnd_message.set_token('ROUTINE',l_api_name,FALSE);
      fnd_message.set_token('SQLERRM',sqlerrm,FALSE);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
END rcv_online_request;

/*
Function : USER_INPUT_REQUIRED
*/

FUNCTION USER_INPUT_REQUIRED(p_header_id number)
RETURN VARCHAR2 IS
l_header_id number;
l_count number;
l_locator_controlled Varchar2(1);

CURSOR check_serial_lot_revision (v_header_id Number) is
select ms.po_header_id
from   mtl_supply ms,
       po_lines_all pla,
       mtl_system_items_b msi
where  msi.organization_id = ms.to_organization_id
and    msi.inventory_item_id = ms.item_id
and    pla.po_line_id = ms.po_line_id
and    ms.po_header_id = v_header_id
and    (msi.serial_number_control_code <> 1
or      msi.lot_control_code <> 1
or      (msi.revision_qty_control_code = 2 and pla.item_revision is null));


CURSOR find_all_items(v_header_id number) is
select ms.item_id,
       ms.to_organization_id,
       ms.to_subinventory
from   mtl_supply ms
where  ms.po_header_id = v_header_id;

CURSOR locator_check (v_org_id Number, v_item_id number, v_sub_inv varchar2) IS
select 'Y'
from mtl_parameters a,
     mtl_system_items_b b,
     mtl_secondary_inventories c
where a.organization_id = b.organization_id
  and a.organization_id = c.organization_id
  and a.organization_id   = v_org_id
  and b.inventory_item_id = v_item_id
  and c.secondary_inventory_name = v_sub_inv
   and (     a.stock_locator_control_code in (2,3)   --Org Control should be  2 or 3
          OR a.stock_locator_control_code = 4 AND c.locator_type in (2,3) --org Control 4 and sub control 2 or 3
	  OR a.stock_locator_control_code = 4 AND c.locator_type = 5 AND b.location_control_code in (2,3) );



begin
l_header_id := p_header_id;
l_locator_controlled := 'N'; -- not locator controlled
l_count := 0;

--First Check Serial Lot and Revision Control of Item
OPEN  check_serial_lot_revision(l_header_id);
FETCH check_serial_lot_revision INTO l_count;
CLOSE check_serial_lot_revision;

IF (nvl(l_count,0) > 0) THEN
	RETURN 'Y';
END IF;

--Checking for Locator
for r_find_all_items in find_all_items(l_header_id)
LOOP
        --Now we need to find out whethere this is Locator Controlled Item for this org and Sub
        OPEN locator_check (r_find_all_items.TO_ORGANIZATION_ID ,
                            r_find_all_items.ITEM_ID,
                            r_find_all_items.TO_SUBINVENTORY);
        FETCH locator_check INTO l_locator_controlled;
        CLOSE locator_check;
	IF (l_locator_controlled = 'Y') THEN
		RETURN 'Y';
	END IF;
END LOOP;

RETURN 'N';

END USER_INPUT_REQUIRED;

function vendor(p_vendor_id number)
return varchar2 is
l_vendor        varchar2(240);
cursor c_vendor is
select vendor_name
from   po_vendors
where  vendor_id = p_vendor_id;
begin
  open  c_vendor;
  fetch c_vendor into l_vendor;
  close c_vendor;
  return l_vendor;
end vendor;


END CSP_RECEIVE_PVT;

/
