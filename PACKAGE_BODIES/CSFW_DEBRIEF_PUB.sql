--------------------------------------------------------
--  DDL for Package Body CSFW_DEBRIEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_DEBRIEF_PUB" AS
/*$Header: csfwdbfb.pls 120.12.12010000.3 2009/04/08 11:45:23 shadas ship $*/

PROCEDURE Create_Debrief_header
  ( p_task_assignment_id     IN         NUMBER
  , p_error_id               OUT NOCOPY NUMBER
  , p_error                  OUT NOCOPY VARCHAR2
  , p_debrief_header_id      OUT NOCOPY NUMBER
  )
IS
P_DEBRIEF_Rec CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type;
x_header_id       number;
l_return_status   varchar2(2000);
l_msg_count       number;
l_msg_data        varchar2(2000);
l_header_id       number;
l_debrief_number  number;
l_user            number;
l_data            varchar2(2000);
l_msg_index_out   number;

cursor c_header_id is select CSF_DEBRIEF_HEADERS_S1.nextval  from dual;
cursor c_header_number is select CSF_DEBRIEF_HEADERS_S2.nextval  from dual;

Begin
	p_error_id := 0; --Assume success

	open c_header_id;
        fetch c_header_id into l_header_id;
        close c_header_id;

        open c_header_number;
        fetch c_header_number into l_debrief_number;
        close c_header_number;

	l_user  := FND_GLOBAL.user_id;

	P_DEBRIEF_Rec.DEBRIEF_HEADER_ID  := l_header_id ;
	P_DEBRIEF_Rec.DEBRIEF_NUMBER     := to_char(l_debrief_number);
	P_DEBRIEF_Rec.DEBRIEF_DATE       := sysdate;
	P_DEBRIEF_Rec.TASK_ASSIGNMENT_ID := p_task_assignment_id;

	CSF_DEBRIEF_PUB.Create_DEBRIEF(
	    P_Api_Version_Number  => 1.0,
	    P_Init_Msg_List       => FND_API.G_FALSE,
	    P_Commit              => FND_API.G_FALSE,
	    P_DEBRIEF_Rec         => P_DEBRIEF_Rec,
	    P_DEBRIEF_LINE_tbl    => CSF_DEBRIEF_PUB.G_MISS_DEBRIEF_LINE_Tbl  ,
	    X_DEBRIEF_HEADER_ID   => x_header_id,
	    X_Return_Status       => l_return_status,
	    X_Msg_Count           => l_msg_count,
	    X_Msg_Data            => l_msg_data
	    );

	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	  THEN
	    /* API-call was successfull */
	      p_error_id := 0;
	      p_error := FND_API.G_RET_STS_SUCCESS;
	      p_debrief_header_id := x_header_id;
	  ELSE

	    FOR l_counter IN 1 .. l_msg_count
	    LOOP
		      fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_data
			, p_msg_index_out => l_msg_index_out
			);
		      --dbms_output.put_line( 'Message: '||l_data );
	    END LOOP ;
	    p_error_id := 1;
	    p_error := l_data;
	    p_debrief_header_id := 0;
	  END IF;

				   if p_error = FND_API.G_RET_STS_SUCCESS
			             then
					p_error := '';
				   end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;
    p_debrief_header_id := 0;

END Create_Debrief_header;


-- Bug Number : 4543409, added quantity and uom
PROCEDURE Create_Labor_Line
  ( p_debrief_header_id      IN  NUMBER,
    p_labor_start_date       IN  DATE,
    p_labor_end_date         IN  DATE,
    p_service_date           IN  DATE,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_quantity		     IN  NUMBER,
    p_uom		     IN  VARCHAR2,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_debrief_line_id        OUT NOCOPY NUMBER,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2

  )
IS

l_return_status varchar2(2000);
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_dbf_line_id number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_TBL         CSF_DEBRIEF_PUB.DEBRIEF_LINE_Tbl_Type ;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;
l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;
l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;
l_line_number NUMBER;
l_dt_format   varchar2(20);
l_sr_date   DATE;
l_charge_Entry varchar2(1);


l_resource_type VARCHAR2(30);
l_resource_id   NUMBER;
l_validate_lab_time_msg varchar2(255);


cursor find_resource is
select a.resource_id resource_id, b.resource_type resource_type
from CSP_RS_RESOURCES_V b, jtf_rs_resource_extns a
where a.resource_id =b.resource_id
  and a.user_id = FND_GLOBAL.USER_ID;

r_find_resource find_resource%ROWTYPE;


cursor c_dbf_line_id is select CSF_DEBRIEF_LINES_S.nextval from dual;

cursor c_uom_code(v_org_id number, v_item_id number)
is
        select primary_uom_code  from mtl_system_items_vl
        where organization_id = v_org_id
        and inventory_item_id = v_item_id;

cursor c_creation_date (v_incident_id number)
is
select creation_date from cs_incidents_all_b where incident_id = v_incident_id;


BEGIN
	l_order_header_id := 0;
	p_error_id := 0; --Assume success
	l_header_id := p_debrief_header_id;

	l_user := FND_GLOBAL.user_id ;

        open c_dbf_line_id;
        fetch c_dbf_line_id into l_dbf_line_id;
        close c_dbf_line_id;

	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);


    -------------------------------------------------------------------------------------------------
    -------
    -------  check for the Service date, which should not be less than SR date and more than Sysdate
    -------
    -------------------------------------------------------------------------------------------------
        -- first get the date format
        -- Bug 2862796. Using ICX: Date Format Mask in place of CSFW: Date Format.
	FND_PROFILE.GET('ICX_DATE_FORMAT_MASK', l_dt_format);

        -- Now get the SR Date in date format
        open c_creation_date(p_incident_id);
        fetch c_creation_date into l_sr_date;
        close c_creation_date;

        -- now check if it is more than sysdate
        -- BUG 2225745
	-- if l_sr_date is p_service_date, then make l_sr_date = l_sr_date - 1
	-- Now that we are dealing with dates all over we do not need this

        --   IF trunc(l_sr_date) = trunc(p_service_date)
	--    THEN
	--      	l_sr_date := l_sr_date - 1;
	--   END IF; --BUG 2451683

/*  bug# 2844824
-- remove the checks
	--if start Date is not between the creation date and sysdate
        IF p_labor_start_date between l_sr_date and sysdate
        THEN
		null;
	ELSE
	     --convert the Server to Client time zone
             FND_MESSAGE.Set_Name('CSF', 'CSFW_SERVICE_DATE');
             FND_MESSAGE.Set_Token('P_SR_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(l_sr_date), l_dt_format||' HH24:MI'));
             FND_MESSAGE.Set_Token('P_SYSTEM_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(sysdate), l_dt_format||' HH24:MI'));

             p_error := -21;
             p_error := FND_MESSAGE.Get;

             RETURN ;
        END IF;

	-- SAme For End date
        IF p_labor_end_date between l_sr_date and sysdate
        THEN
		null;
	ELSE
	     --convert the Server to Client time zone
             FND_MESSAGE.Set_Name('CSF', 'CSFW_SERVICE_DATE_END');
             FND_MESSAGE.Set_Token('P_SR_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(l_sr_date), l_dt_format||' HH24:MI'));
             FND_MESSAGE.Set_Token('P_SYSTEM_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(sysdate), l_dt_format||' HH24:MI'));

             p_error := -21;
             p_error := FND_MESSAGE.Get;

             RETURN ;
        END IF;
*/

        IF (p_labor_start_date >= p_labor_end_date) THEN
	     FND_MESSAGE.Set_Name('CSF', 'CSFW_START_END_DATE_SAME');
             p_error := -30;
             p_error := FND_MESSAGE.Get;
	     RETURN;
        END IF;

	-- CALL THE VALIDATE FUNCTION
	OPEN find_resource;
	fetch find_resource INTO r_find_resource;
	close find_resource;
	l_validate_lab_time_msg := validate_labor_time(r_find_resource.resource_type, r_find_resource.resource_id, l_dbf_line_id,p_labor_start_date, p_labor_end_date);
	IF l_validate_lab_time_msg <> 'S' THEN
		p_error := -22;
		p_error := l_validate_lab_time_msg;
		RETURN;
	END IF;


	 P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID       := l_dbf_line_id;
	 P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID     := l_header_id;--from header record
	 P_DEBRIEF_LINE_Rec.SERVICE_DATE          := p_service_date;
	 P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID   := p_txn_billing_type_id;

	 IF p_inventory_item_id <> 0 THEN
		open c_uom_code (l_organization_id, p_inventory_item_id);
		fetch c_uom_code into l_UOM_code;
		close c_uom_code;

		 P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID     := p_inventory_item_id;
		 P_DEBRIEF_LINE_Rec.UOM_CODE              := l_UOM_code;
	 END IF;

	 P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID   := p_business_process_id;
	 P_DEBRIEF_LINE_Rec.LABOR_START_DATE      := p_labor_start_date;
	 P_DEBRIEF_LINE_Rec.LABOR_END_DATE        := p_labor_end_date;
	 P_DEBRIEF_LINE_Rec.channel_code          := 'WIRELESS_USER';
	 P_DEBRIEF_LINE_Rec.issuing_inventory_org_id          := l_organization_id;
	 P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID	  := p_txnTypeId;
	 P_DEBRIEF_LINE_Rec.LABOR_REASON_CODE          := p_justificationCode;
	 P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE         := p_return_reason_code;

	 -- Bug 4543409
	 P_DEBRIEF_LINE_Rec.UOM_CODE		  := p_uom;
	 IF p_quantity IS NOT NULL THEN
	 	P_DEBRIEF_LINE_Rec.QUANTITY		  := p_quantity;
	 END IF;

	P_DEBRIEF_TBL (1) := P_DEBRIEF_LINE_Rec;
	CSF_DEBRIEF_PUB.Create_debrief_lines(
	    P_Api_Version_Number        => 1.0,
	    P_Init_Msg_List             => FND_API.G_FALSE,
	    P_Commit                    => FND_API.G_TRUE,
	    P_Upd_tskassgnstatus        => NULL,
	    P_Task_Assignment_status    => NULL,
	    P_DEBRIEF_LINE_Tbl          => P_DEBRIEF_TBL ,
	    P_DEBRIEF_HEADER_ID         => l_header_id,
	    P_SOURCE_OBJECT_TYPE_CODE   => 'CSFW' ,
	    X_Return_Status             => l_return_status ,
	    X_Msg_Count                 => l_msg_count ,
	    X_Msg_Data                  => l_msg_data
	    );

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		FOR l_counter IN 1 .. l_msg_count
			LOOP
				fnd_msg_pub.get
					( p_msg_index     => l_counter
					, p_encoded       => FND_API.G_FALSE
					, p_data          => l_data
					, p_msg_index_out => l_msg_index_out
					);
			END LOOP;
				    p_error_id := 1;
				    p_error := l_data;
   ELSE
      p_debrief_line_id := l_dbf_line_id;       -- added to return dbf_line_id
	END IF;
	if p_error = FND_API.G_RET_STS_SUCCESS	then
		p_error := '';
	end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END Create_Labor_Line;




PROCEDURE Create_Expense_Line
  ( p_debrief_header_id      IN  NUMBER,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_expense_amount         IN  NUMBER,
    p_currency_code          IN  VARCHAR2,
    p_txnTypeId		     IN  NUMBER,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_quantity               IN  NUMBER,
    p_uom_code               IN  VARCHAR2,
    p_debrief_line_id        OUT NOCOPY NUMBER,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2

  ) IS

l_return_status varchar2(2000);
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_dbf_line_id number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_TBL         CSF_DEBRIEF_PUB.DEBRIEF_LINE_Tbl_Type ;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;
l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;
l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;
l_line_number NUMBER;
l_charge_Entry VARCHAR2(1);

cursor c_dbf_lineId is select CSF_DEBRIEF_LINES_S.nextval  from dual;
cursor c_uom_code (v_org_id number, v_item_id number)
is
select primary_uom_code  from mtl_system_items_vl
        where organization_id = v_org_id
        and inventory_item_id = v_item_id;


BEGIN
	l_order_header_id := 0;
	p_error_id := 0; --Assume success
	l_header_id := p_debrief_header_id;

	open c_dbf_lineId;
        fetch c_dbf_lineId into l_dbf_line_id;
        close c_dbf_lineId;

        l_user := FND_GLOBAL.user_id ;

	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);

        open c_uom_code (l_organization_id, p_inventory_item_id);
        fetch c_uom_code into l_UOM_code;
        close c_uom_code;



	 P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID       := l_dbf_line_id;
	 P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID     := l_header_id;--from header record
	 P_DEBRIEF_LINE_Rec.SERVICE_DATE          := sysdate;
	 P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID   := p_txn_billing_type_id;
	 P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID     := p_inventory_item_id;
	 P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID   := p_business_process_id;

	 IF p_expense_amount IS NOT NULL  THEN
	   P_DEBRIEF_LINE_Rec.UOM_CODE              := l_UOM_code;
	   P_DEBRIEF_LINE_Rec.EXPENSE_AMOUNT        := p_expense_amount;
	   P_DEBRIEF_LINE_Rec.CURRENCY_CODE         := p_currency_code;
	 ELSE
	   P_DEBRIEF_LINE_Rec.QUANTITY                := p_quantity;
      P_DEBRIEF_LINE_Rec.UOM_CODE                := p_uom_code;
    END IF;

	 P_DEBRIEF_LINE_Rec.channel_code	  := 'WIRELESS_USER';
	 P_DEBRIEF_LINE_Rec.issuing_inventory_org_id          := l_organization_id;
	 P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID	  := p_txnTypeId;
	 P_DEBRIEF_LINE_Rec.EXPENSE_REASON_CODE := p_justificationCode;
         P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE  := p_return_reason_code;

	P_DEBRIEF_TBL (1) := P_DEBRIEF_LINE_Rec;
	CSF_DEBRIEF_PUB.Create_debrief_lines(
	    P_Api_Version_Number        => 1.0,
	    P_Init_Msg_List             => FND_API.G_FALSE,
	    P_Commit                    => FND_API.G_TRUE,
	    P_Upd_tskassgnstatus        => NULL,
	    P_Task_Assignment_status    => NULL,
	    P_DEBRIEF_LINE_Tbl          => P_DEBRIEF_TBL ,
	    P_DEBRIEF_HEADER_ID         => l_header_id,
	    P_SOURCE_OBJECT_TYPE_CODE   => 'CSFW' ,
	    X_Return_Status             => l_return_status ,
	    X_Msg_Count                 => l_msg_count ,
	    X_Msg_Data                  => l_msg_data
	    );

	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	  THEN
	   p_debrief_line_id := l_dbf_line_id;    -- Added to return newly created Line_ID
	  null;
	  ELSE
   		FOR l_counter IN 1 .. l_msg_count
		LOOP
			fnd_msg_pub.get
				( p_msg_index     => l_counter
				, p_encoded       => FND_API.G_FALSE
				, p_data          => l_data
				, p_msg_index_out => l_msg_index_out
				);
		END LOOP;
			    p_error_id := 1;
			    p_error := l_data;


	  END IF;
	   if p_error = FND_API.G_RET_STS_SUCCESS
	     then
		p_error := '';
	   end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END Create_Expense_Line;






PROCEDURE Update_debrief_Expense_line(
    p_debrief_line_id        IN  NUMBER,
    p_expense_amount         IN  NUMBER,
    p_currency_code          IN  VARCHAR2,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_quantity               IN  NUMBER,
    p_uom_code               IN  VARCHAR2,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2
     )IS

l_return_status varchar2(2000);
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_dbf_line_id number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;
l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;
l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;
l_line_number NUMBER;
l_charge_Entry VARCHAR2(1);

cursor c_DEBRIEF_HEADER_ID(v_debrief_line_id number ) is
        select DEBRIEF_HEADER_ID from CSF_DEBRIEF_LINES where DEBRIEF_LINE_ID =
v_debrief_line_id ;

cursor c_uom_code(v_org_id number, v_item_id number) is
select primary_uom_code  from mtl_system_items_vl
        where organization_id = v_org_id
        and inventory_item_id = v_item_id;

BEGIN
	p_error_id := 0; --Assume success

        open c_DEBRIEF_HEADER_ID(p_debrief_line_id);
        fetch c_DEBRIEF_HEADER_ID into l_header_id;
        close c_DEBRIEF_HEADER_ID;

	l_user := FND_GLOBAL.user_id  ;

	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);

        open c_uom_code (l_organization_id, p_inventory_item_id);
        fetch c_uom_code into l_UOM_code;
        close c_uom_code;

	 P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID       := p_debrief_line_id;
	 P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID     := l_header_id;--from header record
	 P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID   := p_txn_billing_type_id;
	 P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID     := p_inventory_item_id;
	 P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID   := p_business_process_id;

	 IF p_expense_amount IS NOT NULL  THEN
	   P_DEBRIEF_LINE_Rec.UOM_CODE              := l_UOM_code;
	   P_DEBRIEF_LINE_Rec.EXPENSE_AMOUNT        := p_expense_amount;
	   P_DEBRIEF_LINE_Rec.CURRENCY_CODE         := p_currency_code;
      P_DEBRIEF_LINE_Rec.QUANTITY                  := null;
   ELSE
      P_DEBRIEF_LINE_Rec.QUANTITY                  := p_quantity;
      P_DEBRIEF_LINE_Rec.UOM_CODE                  := p_uom_code;
      P_DEBRIEF_LINE_Rec.EXPENSE_AMOUNT        := null;
      P_DEBRIEF_LINE_Rec.CURRENCY_CODE         := null;
   END IF;

    P_DEBRIEF_LINE_Rec.channel_code	  := 'WIRELESS_USER';
	 P_DEBRIEF_LINE_Rec.issuing_inventory_org_id          := l_organization_id;
	 P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID	  := p_txnTypeId;
	 P_DEBRIEF_LINE_Rec.EXPENSE_REASON_CODE := p_justificationCode;
         P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE  := p_return_reason_code;


	CSF_DEBRIEF_PUB.Update_debrief_line(
	    P_Api_Version_Number         => 1.0,
	    P_Init_Msg_List             => FND_API.G_FALSE,
	    P_Commit                    => FND_API.G_FALSE,
	    P_Upd_tskassgnstatus        => NULL,
	    P_Task_Assignment_status    => NULL,
	    P_DEBRIEF_LINE_Rec          => P_DEBRIEF_LINE_Rec,
	    X_Return_Status             => l_return_status ,
	    X_Msg_Count                 => l_msg_count ,
	    X_Msg_Data                  => l_msg_data
	    );


	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	  THEN
		NULL;
	  ELSE
   		FOR l_counter IN 1 .. l_msg_count
            		LOOP
                      		fnd_msg_pub.get
                        		( p_msg_index     => l_counter
                        		, p_encoded       => FND_API.G_FALSE
                        		, p_data          => l_data
                        		, p_msg_index_out => l_msg_index_out
                        		);
                        END LOOP;
				    p_error_id := 1;
				    p_error := l_data;


	  END IF;

	   if p_error = FND_API.G_RET_STS_SUCCESS
	     then
		p_error := '';
	   end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END Update_debrief_Expense_line;


-- Bug Number : 4543409, added quantity and uom
PROCEDURE Update_debrief_Labor_line(
    p_debrief_line_id        IN  NUMBER,
    p_labor_start_date       IN  DATE,
    p_labor_end_date         IN  DATE,
    p_service_date           IN  DATE,
    p_txn_billing_type_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER,
    p_business_process_id    IN  NUMBER,
    p_charge_Entry           IN  VARCHAR2,
    p_incident_id            IN  NUMBER,
    p_txnTypeId		     IN  NUMBER,
    p_quantity		     IN  NUMBER,
    p_uom		     IN  VARCHAR2,
    p_justificationCode      IN  VARCHAR2,
    p_return_reason_code     IN  VARCHAR2,
    p_error_id               OUT NOCOPY NUMBER,
    p_error                  OUT NOCOPY VARCHAR2
    )IS

l_resource_type VARCHAR2(30);
l_resource_id   NUMBER;

l_return_status varchar2(2000);
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_dbf_line_id number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;
l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;

l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;
l_line_number NUMBER;

l_dt_format   varchar2(20);
l_sr_date   DATE;
l_charge_Entry varchar2(1);

cursor c_DEBRIEF_HEADER_ID(v_debrief_line_id number ) is
        select DEBRIEF_HEADER_ID from CSF_DEBRIEF_LINES where DEBRIEF_LINE_ID =
v_debrief_line_id;

cursor c_uom_code(v_org_id number, v_item_id number) is
select primary_uom_code  from mtl_system_items_vl
        where organization_id = v_org_id
        and inventory_item_id = v_item_id;

cursor c_creation_date(v_incident_id number) is
select creation_date  from cs_incidents_all_b where incident_id = v_incident_id;
l_validate_lab_time_msg varchar2(255);


cursor find_resource is
select a.resource_id resource_id, b.resource_type resource_type
from CSP_RS_RESOURCES_V b, jtf_rs_resource_extns a
where a.resource_id =b.resource_id
  and a.user_id = FND_GLOBAL.USER_ID;

r_find_resource find_resource%ROWTYPE;

BEGIN
	p_error_id := 0; --Assume success

       open c_DEBRIEF_HEADER_ID(p_debrief_line_id);
        fetch c_DEBRIEF_HEADER_ID into l_header_id;
        close c_DEBRIEF_HEADER_ID;


        --select FND_GLOBAL.user_id  into l_user from dual;
        l_user :=FND_GLOBAL.user_id  ;

        FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);



    -------------------------------------------------------------------------------------------------
    -------
    -------  check for the Service date, which should not be less than SR date and more than Sysdate
    -------
    -------------------------------------------------------------------------------------------------
        -- first get the date format
        -- Bug 2862796. Using ICX: Date Format Mask in place of CSFW: Date Format.
	FND_PROFILE.GET('ICX_DATE_FORMAT_MASK', l_dt_format);
        -- Now get the SR Date in date format
        open c_creation_date(p_incident_id);
        fetch c_creation_date into l_sr_date;
        close c_creation_date;


        -- now check if it is more than sysdate
        -- BUG 2225745
	-- if l_sr_date is p_service_date, then make l_sr_date = l_sr_date - 1
--WE do not need this  as these are all date ...
--           IF trunc(l_sr_date) = trunc(p_service_date)
--	    THEN
--      	l_sr_date := l_sr_date - 1;
--	   END IF;

/*

        IF p_service_date between l_sr_date and sysdate
        THEN
		null;
 	ELSE
             FND_MESSAGE.Set_Name('CSF', 'CSFW_SERVICE_DATE');
             FND_MESSAGE.Set_Token('P_SR_DATE', to_char(l_sr_date, l_dt_format));
             FND_MESSAGE.Set_Token('P_SYSTEM_DATE', to_char(sysdate, l_dt_format));
             p_error := -21;
             p_error := FND_MESSAGE.Get;
             return;

        END IF;
*/
        IF (p_labor_start_date >= p_labor_end_date) THEN
	     FND_MESSAGE.Set_Name('CSF', 'CSFW_START_END_DATE_SAME');
             p_error := -30;
             p_error := FND_MESSAGE.Get;
	     RETURN;
        END IF;

	-- CALL THE VALIDATE FUNCTION
	OPEN find_resource;
	fetch find_resource INTO r_find_resource;
	close find_resource;
	l_validate_lab_time_msg := validate_labor_time(r_find_resource.resource_type, r_find_resource.resource_id, l_dbf_line_id,p_labor_start_date, p_labor_end_date);
	IF l_validate_lab_time_msg <> 'S' THEN
		p_error := -22;
		p_error := l_validate_lab_time_msg;
		RETURN;
	END IF;


	 P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID       := p_debrief_line_id;
	 P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID     := l_header_id;--from header record
	 P_DEBRIEF_LINE_Rec.SERVICE_DATE          := p_service_date;
	 P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID   := p_txn_billing_type_id;
	 IF p_inventory_item_id <> 0 THEN
		open c_uom_code(l_organization_id, p_inventory_item_id);
		fetch c_uom_code into l_UOM_code;
		close c_uom_code;

		P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID     := p_inventory_item_id;
		P_DEBRIEF_LINE_Rec.UOM_CODE              := l_UOM_code;
	 ELSE
		P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID     := NULL;		-- Bug Number   : 3491830
	 END IF;

	 P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID   := p_business_process_id;
	 P_DEBRIEF_LINE_Rec.LABOR_START_DATE      := p_labor_start_date;
	 P_DEBRIEF_LINE_Rec.LABOR_END_DATE        := p_labor_end_date;
	 P_DEBRIEF_LINE_Rec.channel_code          := 'WIRELESS_USER';
	 P_DEBRIEF_LINE_Rec.issuing_inventory_org_id          := l_organization_id;
	 P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID	  := p_txnTypeId;

	 P_DEBRIEF_LINE_Rec.LABOR_REASON_CODE          := p_justificationCode;
         P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE         := p_return_reason_code;

	 -- Bug 4543409
	 P_DEBRIEF_LINE_Rec.UOM_CODE		  := p_uom;
	 IF p_quantity IS NOT NULL THEN
	 	P_DEBRIEF_LINE_Rec.QUANTITY		  := p_quantity;
	 END IF;

	CSF_DEBRIEF_PUB.Update_debrief_line(
	    P_Api_Version_Number         => 1.0,
	    P_Init_Msg_List             => FND_API.G_FALSE,
	    P_Commit                    => FND_API.G_FALSE,
	    P_Upd_tskassgnstatus        => NULL,
	    P_Task_Assignment_status    => NULL,
	    P_DEBRIEF_LINE_Rec          => P_DEBRIEF_LINE_Rec,
	    X_Return_Status             => l_return_status ,
	    X_Msg_Count                 => l_msg_count ,
	    X_Msg_Data                  => l_msg_data
	    );


	IF l_return_status = FND_API.G_RET_STS_SUCCESS
	  THEN
	  NULL;
	  ELSE
   		FOR l_counter IN 1 .. l_msg_count
            		LOOP
                      		fnd_msg_pub.get
                        		( p_msg_index     => l_counter
                        		, p_encoded       => FND_API.G_FALSE
                        		, p_data          => l_data
                        		, p_msg_index_out => l_msg_index_out
                        		);
                        END LOOP;
				    p_error_id := 1;
				    p_error := l_data;

	END IF;

				   if p_error = FND_API.G_RET_STS_SUCCESS
			             then
					p_error := '';
				   end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END Update_debrief_Labor_line;

PROCEDURE SAVE_DEBRIEF_MATERIAL_LINE (
	p_taskid		IN VARCHAR2,
	p_taskassignmentid	IN VARCHAR2,
	p_incidentid		IN VARCHAR2,
	p_partyid		IN VARCHAR2,
	p_dbfNr			IN VARCHAR2,
	p_billingTypeId		IN VARCHAR2,
	p_txnTypeId		IN VARCHAR2,
	p_orderCategoryCode	IN VARCHAR2,
	p_txnTypeName		IN VARCHAR2,
	p_itemId		IN VARCHAR2,
	p_revisionFlag		IN VARCHAR2,
	p_businessProcessId	IN VARCHAR2,
	p_subTypeId		IN VARCHAR2,
	p_updateIBFlag		IN VARCHAR2,
	p_srcChangeOwner	IN VARCHAR2,
	p_srcChangeOwnerToCode	IN VARCHAR2,
	p_srcReferenceReqd	IN VARCHAR2,
	p_srcReturnReqd		IN VARCHAR2,
	p_parentReferenceReqd	IN VARCHAR2,
	p_srcStatusId		IN VARCHAR2,
	p_srcStatusName		IN VARCHAR2,
	p_csiTxnTypeId		IN VARCHAR2,
	p_subInv		IN VARCHAR2,
	p_orgId			IN VARCHAR2,
	p_serviceDate		IN VARCHAR2,
	p_qty			IN VARCHAR2,
	p_chgFlag		IN VARCHAR2,
	p_ibFlag		IN VARCHAR2,
	p_invFlag		IN VARCHAR2,
	p_reasonCd		IN VARCHAR2,
	p_instanceId		IN VARCHAR2,
	p_parentProductId	IN VARCHAR2,
	p_partStatusCd		IN VARCHAR2,
	p_recoveredPartId	IN VARCHAR2,
	p_retReasonCd		IN VARCHAR2,
	p_serialNr		IN VARCHAR2,
	p_lotNr			IN VARCHAR2,
	p_revisionNr		IN VARCHAR2,
	p_locatorId		IN VARCHAR2,
	p_UOM			IN VARCHAR2,
	p_updateFlag		IN NUMBER,
	p_dbfLineId		IN NUMBER,
   p_ret_dbfLine_id         OUT NOCOPY NUMBER,
	p_error_id               OUT NOCOPY NUMBER,
	p_error                  OUT NOCOPY VARCHAR2,
	p_return_date           IN VARCHAR2

)IS

--l_return_status varchar2(2000);
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_dbf_line_id number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_TBL         CSF_DEBRIEF_PUB.DEBRIEF_LINE_Tbl_Type ;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;
l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;
l_Charges_Rec			CS_Charge_Details_PUB.Charges_Rec_Type;
l_object_version_number		NUMBER;
l_estimate_detail_id NUMBER;
l_line_number NUMBER;
l_dt_format   varchar2(20);
l_sr_date   DATE;
l_interface_status         varchar2(20);
l_interface_status_meaning varchar2(20);

/* FOR INVENTORY */
  l_transaction_type_id      number    ;
  l_lot_number               varchar2(30) ;
  l_revision                 varchar2(3)  ;
  l_serial_number          varchar2(30) ;
  l_transfer_to_subinventory varchar2(10):= NULL; --optional
  l_transfer_to_locator      number      := NULL; --optional
  l_transfer_to_organization number      := NULL; --optional
  l_api_version              number       := 1.1;
  l_account_id               number      ;
  mesg 			     Varchar2(2000);
  l_locator_id		    number;
  lx_transaction_header_id  number;
  lx_transaction_id         number;

  /* for IB */
  l_in_out_flag              varchar2(4);
  l_transaction_type_id_csi    number      ;
  l_txn_sub_type_id            number      ;

  l_instance_id		       number      ;
  l_parent_instance_id         number      ;
  l_new_instance_id            number      := null;
  l_new_instance_number        Varchar2(40);

  l_inventory_item_id          number      ;
  l_inv_organization_id        number      ;
  l_inv_subinventory_name      varchar2(60);
  l_inv_master_organization_id number      ;
  l_quantity                   number      ;
  l_mfg_serial_number_flag     varchar2(3) ;
  l_service_date               date        ;
  l_shipped_date	        date;
  l_currency_code              varchar2(10);

  l_party_id                   number      ;
  l_party_account_id           number      ;
  l_customer_id                number      ;
  l_party_site_id              number;

  l_debrief_line_id            number  ;
  l_debrief_header_id          number  ;
  l_incident_id                number  ;


  l_return_status              varchar2(1);
  l_mesg                       varchar2(2000);
  l_counter                    number;
  l_install_site_use_id        number;
  l_ship_site_use_id           number;
  l_parent_cpid			number;

/* declaration for all the fields to check for null */
	l_taskid		Number;
	l_taskassignmentid	Number;
	l_incidentid		Number;
	l_partyid		Number;
	l_dbfNr			varchar2(30);
	l_billingTypeId		Number;
	l_txnTypeId		Number;
	l_orderCategoryCode	varchar2(30);
	l_txnTypeName		varchar2(30);
	l_itemId		Number;
	l_revisionFlag		varchar2(30);
	l_businessProcessId	Number;
	l_subTypeId		Number;
	l_updateIBFlag		varchar2(30);
	l_srcChangeOwner	varchar2(30);
	l_srcChangeOwnerToCode	varchar2(30);
	l_srcReferenceReqd	varchar2(30);
	l_srcReturnReqd		varchar2(30);
	l_parentReferenceReqd	varchar2(30);
	l_srcStatusId		Number;
	l_srcStatusName		varchar2(30);
	l_csiTxnTypeId		Number;
	l_subInv		varchar2(30);
	l_orgId			Number;
	l_serviceDate		varchar2(30);
	l_qty			Number;
	l_chgFlag		varchar2(30);
	l_ibFlag		varchar2(30);
	l_invFlag		varchar2(30);
	l_reasonCd		varchar2(30);
	l_instanceId		Number;
	l_parentProductId	Number;
	l_partStatusCd		varchar2(30);
	l_recoveredPartId	Number;
	l_retReasonCd		varchar2(30);
	l_serialNr		varchar2(30);
	l_lotNr			varchar2(30);
	l_revisionNr		varchar2(30);
	l_locatorId		Number;
	l_UOM			varchar2(30);
	lp_servicedate DATE;

	l_client_tz_id  number;
	l_server_tz_id  number;
	l_server_time   date;

	l_part_status_name varchar2(30);


 Cursor c_site (p_incident_id number) Is
        select install_site_use_id,
               ship_to_site_use_id
        from   cs_incidents_all
        where  incident_id = p_incident_id;
 cursor c_party_site_id (p_install_site_id number) Is
        select party_site_id
        from hz_party_site_uses
        where party_site_use_id = p_install_site_id;
 Cursor c_instance_number(p_instance_id Number) is
       select instance_number
       from   csi_item_instances
       where  instance_id = p_instance_id;

 Cursor c_internal_party_id  Is
        select internal_party_id
        from csi_install_parameters;


cursor  c_line_type_id_order (p_order_type_id number,p_incident_id Number) is
         select default_outbound_line_type_id
         from   oe_transaction_types_all
         where  transaction_type_id = p_order_type_id
         and    transaction_type_code = 'ORDER';

 cursor  c_line_type_id_return (p_order_type_id number,p_incident_id number) is
         select default_inbound_line_type_id
         from   oe_transaction_types_all
         where  transaction_type_id = p_order_type_id
         and    transaction_type_code = 'ORDER';



 Cursor c_status_meaning(p_code Varchar2) Is
  	select  meaning
  	from fnd_lookups
  	where lookup_type = 'CSF_INTERFACE_STATUS'
	and   lookup_code = p_code;


/* commenting this cursor since it's used no where
cursor c_party(b_dbfId  number) is
select customer_id,customer_account_id  from csf_debrief_tasks_v where debrief_header_id = b_dbfId;
r_party           c_party%ROWTYPE;
*/

cursor c_DEBRIEF_HEADER_ID(v_dbf_nr varchar2) is
select DEBRIEF_HEADER_ID   from csf_debrief_headers where debrief_number = v_dbf_nr;


cursor c_dbf_lines is   select CSF_DEBRIEF_LINES_S.nextval  from dual;

cursor c_status_name(v_partStatusCd varchar2) is
select name
from csi_instance_statuses
where INSTANCE_STATUS_ID = v_partStatusCd;

cursor c_creation_date(v_incident_id number) is
select creation_date  from cs_incidents_all_b where incident_id = v_incident_id;



BEGIN

--dbms_output.put_line('BEGINING....');
	l_client_tz_id := to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
	l_server_tz_id := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

-- first lets get the nulls out
if p_taskid = '$$#@' then
	l_taskid  := null;
else
	l_taskid  := to_number(p_taskid);
end if;
if p_itemId= '$$#@' then
	l_itemId := null;
else
	l_itemId := to_number(p_itemId);
end if;

if p_taskassignmentid = '$$#@' then
	l_taskassignmentid  := null;
else
	l_taskassignmentid  := to_number(p_taskassignmentid);
end if;

if p_incidentid = '$$#@' then
	l_incidentid := null;
else
	l_incidentid  := to_number(p_incidentid);
end if;

if p_partyid = '$$#@' then
	l_partyid := null;
else
	l_partyid := to_number(p_partyid);
end if;

if p_dbfNr = '$$#@' then
	l_dbfNr := null;
else
	l_dbfNr := p_dbfNr;
end if;

if p_billingTypeId = '$$#@' then
	l_billingTypeId := null;
else
	l_billingTypeId := to_number(p_billingTypeId);
end if;
if p_txnTypeId = '$$#@' then
	l_txnTypeId := null;
else
	l_txnTypeId := to_number(p_txnTypeId);
end if;
if p_businessProcessId = '$$#@' then
	l_businessProcessId := null;
else
	l_businessProcessId := to_number(p_businessProcessId);
end if;
if p_subTypeId = '$$#@' then
	l_subTypeId := null;
else
	l_subTypeId := to_number(p_subTypeId);
end if;
if p_srcStatusId = '$$#@' then
	l_srcStatusId := null;
else
	l_srcStatusId  := to_number(p_srcStatusId);
end if;
if p_locatorId = '$$#@' then
	l_locatorId := null;
else
	l_locatorId := to_number(p_locatorId);
end if;
if p_csiTxnTypeId = '$$#@' then
	l_csiTxnTypeId := null;
else
	l_csiTxnTypeId := to_number(p_csiTxnTypeId);
end if;
if p_orgId = '$$#@' then
	l_orgId := null;
else
	l_orgId := to_number(p_orgId);
end if;
if p_qty = '$$#@' then
	l_qty := null;
else
	l_qty := to_number(p_qty);
end if;
if p_instanceId = '$$#@' then
	l_instanceId := null;
else
	l_instanceId := to_number(p_instanceId );
end if;
if p_parentProductId =  '$$#@' then
	l_parentProductId := null;
else
	l_parentProductId := to_number(p_parentProductId );
end if;
if p_recoveredPartId = '$$#@' then
	l_recoveredPartId := null;
else
	l_recoveredPartId := to_number(p_recoveredPartId);
end if;
if p_revisionFlag = '$$#@' then
	l_revisionFlag := null;
else
	l_revisionFlag := p_revisionFlag;
end if;
if p_srcStatusName = '$$#@' then
	l_srcStatusName := null;
else
	l_srcStatusName := p_srcStatusName;
end if;
if p_partStatusCd = '$$#@' then
	l_partStatusCd := null;
else
	l_partStatusCd := p_partStatusCd;
end if;
if p_chgFlag = '$$#@' then
	l_chgFlag := null;
else
	l_chgFlag := p_chgFlag ;
end if;
if p_ibFlag = '$$#@' then
	l_ibFlag := null;
else
	l_ibFlag := p_ibFlag ;
end if;
if p_invFlag = '$$#@' then
	l_invFlag := null;
else
	l_invFlag := p_invFlag ;
end if;
if p_reasonCd = '$$#@' then
	l_reasonCd := null;
else
	l_reasonCd := p_reasonCd;
end if;
if p_subInv = '$$#@' then
	l_subInv := null;
else
	l_subInv := p_subInv;
end if;

if p_orderCategoryCode = '$$#@' then
	l_orderCategoryCode := null;
else
	l_orderCategoryCode := p_orderCategoryCode;
end if;
if p_serviceDate = '$$#@' then
	l_serviceDate := null;
else
	l_serviceDate := p_serviceDate;
end if;
if p_txnTypeName = '$$#@' then
	l_txnTypeName := null;
else
	l_txnTypeName := p_txnTypeName;
end if;
if p_updateIBFlag = '$$#@' then
	l_updateIBFlag := null;
else
	l_updateIBFlag  := p_updateIBFlag;
end if;

if p_retReasonCd = '$$#@' then
	l_retReasonCd := null;
else
	l_retReasonCd  := p_retReasonCd;
end if;
if p_serialNr = '$$#@' then
	l_serialNr := null;
else
	l_serialNr := p_serialNr ;
end if;
if p_lotNr = '$$#@' then
	l_lotNr := null;
else
	l_lotNr := p_lotNr ;
end if;
if p_revisionNr = '$$#@' then
	l_revisionNr := null;
else
	l_revisionNr := p_revisionNr;
end if;
if p_UOM = '$$#@' then
	l_UOM := null;
else
	l_UOM := p_UOM;
end if;
if p_srcChangeOwner = '$$#@' then
	l_srcChangeOwner := null;
else
	l_srcChangeOwner := p_srcChangeOwner;
end if;
if p_srcChangeOwnerToCode = '$$#@' then
	l_srcChangeOwnerToCode := null;
else
	l_srcChangeOwnerToCode := p_srcChangeOwnerToCode ;
end if;
if p_srcReferenceReqd = '$$#@' then
	l_srcReferenceReqd := null;
else
	l_srcReferenceReqd := p_srcReferenceReqd ;
end if;
if p_srcReturnReqd = '$$#@' then
	l_srcReturnReqd := null;
else
	l_srcReturnReqd := p_srcReturnReqd;
end if;
if p_parentReferenceReqd = '$$#@' then
	l_parentReferenceReqd := null;
else
	l_parentReferenceReqd := p_parentReferenceReqd;
end if;



	--dbms_output.put_line('So far so good....');
	l_order_header_id := 0;


        open c_DEBRIEF_HEADER_ID(l_dbfNr);
        fetch c_DEBRIEF_HEADER_ID into l_header_id;
        close c_DEBRIEF_HEADER_ID;

        open c_dbf_lines;
        fetch c_dbf_lines into l_dbf_line_id;
        close c_dbf_lines;

	if (l_partStatusCd is not null or rtrim(l_partStatusCd) <> '') then
                open c_status_name(l_partStatusCd);
                fetch c_status_name into l_part_status_name;
                close c_status_name;
	end if;
	--This part was done as the debrief was looking for part status naem in stead of the id

	if (l_part_status_name is not null or rtrim(l_part_status_name) <> '') then
		l_partStatusCd := l_part_status_name  ;
	end if;



    -------------------------------------------------------------------------------------------------
    -------
    -------  check for the Service date, which should not be less than SR date and more than Sysdate
    -------
    -------------------------------------------------------------------------------------------------
        -- first get the date format
        -- Bug 2862796. Using ICX: Date Format Mask in place of CSFW: Date Format.
	FND_PROFILE.GET('ICX_DATE_FORMAT_MASK', l_dt_format);

        -- Now get the SR Date in date format
        open c_creation_date(l_incidentid);
        fetch c_creation_date into l_sr_date;
        close c_creation_date;

	-- bug # 5351199
	-- Save service line with 23:59 time
	-- bug # 5519603
	if(to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(sysdate), l_dt_format) = l_serviceDate)
	then
		lp_servicedate := to_date(l_serviceDate || ' ' || to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(sysdate), 'HH24:MI'), l_dt_format || ' HH24:MI');
	else
		lp_servicedate := to_date(l_serviceDate || ' 23:59', l_dt_format || ' HH24:MI');
	end if;
	-- add the return date
	if p_return_date <>  '$$#@' then
		P_DEBRIEF_LINE_Rec.RETURN_DATE :=  to_date(p_return_date, l_dt_format);
	end if;


        -- now check if it is more than sysdate
        -- BUG 2225745
	-- if l_sr_date is p_service_date, then make l_sr_date = l_sr_date - 1

           IF trunc(l_sr_date) = trunc(lp_servicedate)
	    THEN
        	l_sr_date := l_sr_date - 1;
	   END IF;

        /* check in JSP only
	IF lp_servicedate  not between l_sr_date and sysdate
        THEN
             FND_MESSAGE.Set_Name('CSF', 'CSFW_SERVICE_DATE');
	     FND_MESSAGE.Set_Token('P_SR_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(l_sr_date), l_dt_format||' HH24:MI'));
             FND_MESSAGE.Set_Token('P_SYSTEM_DATE', to_char(CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(sysdate), l_dt_format||' HH24:MI'));


             p_error := -21;
             p_error := FND_MESSAGE.Get;
             RETURN ;
        END IF;

	*/
--dbms_output.put_line('Start to fill the record.....');

	if(p_updateFlag = 1) then
		P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID		:= p_dbfLineId;
	else
		P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID		:= l_dbf_line_id;
	end if;


	-- lp_servicedate is in Client Time Zone. Lets Convert it to Service Time Zone
	IF (fnd_timezones.timezones_enabled = 'Y') THEN
		HZ_TIMEZONE_PUB.GET_TIME(1.0, 'F',l_client_tz_id ,l_server_tz_id , lp_servicedate, l_server_time, l_return_status, l_msg_count, l_msg_data);
	ELSE
		l_server_time := lp_servicedate;
	END IF;




	P_DEBRIEF_LINE_Rec.DEBRIEF_HEADER_ID		:= l_header_id ;
	P_DEBRIEF_LINE_Rec.SERVICE_DATE                 := l_server_time;
	P_DEBRIEF_LINE_Rec.BUSINESS_PROCESS_ID		:= l_businessProcessId;
	P_DEBRIEF_LINE_Rec.TXN_BILLING_TYPE_ID          := l_billingTypeId;
	P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID            := l_itemId;

	P_DEBRIEF_LINE_Rec.INSTANCE_ID                  := l_instanceId;
	P_DEBRIEF_LINE_Rec.PARENT_PRODUCT_ID            := l_parentProductId;
	P_DEBRIEF_LINE_Rec.REMOVED_PRODUCT_ID           := l_recoveredPartId;

	P_DEBRIEF_LINE_Rec.STATUS_OF_RECEIVED_PART      := l_partStatusCd;
	P_DEBRIEF_LINE_Rec.ITEM_SERIAL_NUMBER           := l_serialNr;
	P_DEBRIEF_LINE_Rec.ITEM_REVISION                := l_revisionNr;
	P_DEBRIEF_LINE_Rec.ITEM_LOTNUMBER               := l_lotNr;
	P_DEBRIEF_LINE_Rec.UOM_CODE                     := l_UOM;
	P_DEBRIEF_LINE_Rec.QUANTITY                     := l_qty;
	P_DEBRIEF_LINE_Rec.MATERIAL_REASON_CODE         := l_reasonCd;
	P_DEBRIEF_LINE_Rec.CHANNEL_CODE                 := 'WIRELESS_USER';
	P_DEBRIEF_LINE_Rec.RETURN_REASON_CODE           := l_retReasonCd;

	IF l_orderCategoryCode = 'ORDER'
	  THEN
		P_DEBRIEF_LINE_Rec.ISSUING_INVENTORY_ORG_ID     := l_orgId;
		P_DEBRIEF_LINE_Rec.ISSUING_SUB_INVENTORY_CODE   := l_subInv;
		P_DEBRIEF_LINE_Rec.ISSUING_LOCATOR_ID           := l_locatorId;
	  ELSE
		P_DEBRIEF_LINE_Rec.ISSUING_INVENTORY_ORG_ID     := NULL;-- This is a hack for BUG 2431433 should be removed when the bug is fixed at the core debrief level
                p_debrief_line_rec.issuing_sub_inventory_code   := NULL;-- this is also a hack
		P_DEBRIEF_LINE_Rec.RECEIVING_INVENTORY_ORG_ID   := l_orgId;
		P_DEBRIEF_LINE_Rec.RECEIVING_SUB_INVENTORY_CODE := l_subInv;
		P_DEBRIEF_LINE_Rec.RECEIVING_LOCATOR_ID         := l_locatorId;
	 END IF;

--	P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_NUMBER
--	P_DEBRIEF_LINE_Rec.RMA_HEADER_ID
--	P_DEBRIEF_LINE_Rec.DISPOSITION_CODE
--	P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_STATUS_ID
--	P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_STATUS
--	P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_MSG_CODE
--	P_DEBRIEF_LINE_Rec.CHARGE_UPLOAD_MESSAGE
--	P_DEBRIEF_LINE_Rec.IB_UPDATE_STATUS
--	P_DEBRIEF_LINE_Rec.IB_UPDATE_MSG_CODE
--	P_DEBRIEF_LINE_Rec.IB_UPDATE_MESSAGE
--	P_DEBRIEF_LINE_Rec.SPARE_UPDATE_STATUS
--	P_DEBRIEF_LINE_Rec.SPARE_UPDATE_MSG_CODE
--	P_DEBRIEF_LINE_Rec.SPARE_UPDATE_MESSAGE
	--Setting the Transaction Id
	P_DEBRIEF_LINE_Rec.TRANSACTION_TYPE_ID	  := l_txnTypeId;


	--dbms_output.put_line('putting into table....');
	--dbms_output.put_line('P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID....'||P_DEBRIEF_LINE_Rec.INVENTORY_ITEM_ID);


	P_DEBRIEF_TBL (1) := P_DEBRIEF_LINE_Rec;
	--dbms_output.put_line('table filled. Call API....');


	if (p_updateFlag = 1) then

		CSF_DEBRIEF_PUB.Update_debrief_line(
		P_Api_Version_Number         => 1.0,
		P_Init_Msg_List             => FND_API.G_FALSE,
		P_Commit                    => FND_API.G_TRUE,
		P_Upd_tskassgnstatus        => NULL,
		P_Task_Assignment_status    => NULL,
		P_DEBRIEF_LINE_Rec          => P_DEBRIEF_LINE_Rec,
		X_Return_Status             => l_return_status ,
		X_Msg_Count                 => l_msg_count ,
		X_Msg_Data                  => l_msg_data
		);
	else
		CSF_DEBRIEF_PUB.Create_debrief_lines(
	    	P_Api_Version_Number        => 1.0,
	    	P_Init_Msg_List             => FND_API.G_FALSE,
	    	P_Commit                    => FND_API.G_TRUE,
	    	P_Upd_tskassgnstatus        => NULL,
	    	P_Task_Assignment_status    => NULL,
	    	P_DEBRIEF_LINE_Tbl          => P_DEBRIEF_TBL ,
	    	P_DEBRIEF_HEADER_ID         => l_header_id,
	    	P_SOURCE_OBJECT_TYPE_CODE   => 'CSFW' ,
	    	X_Return_Status             => l_return_status ,
	    	X_Msg_Count                 => l_msg_count ,
	    	X_Msg_Data                  => l_msg_data
	    	);

	end if;


	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	 THEN
		p_error_id := 0;
		p_error := 'S';
      p_ret_dbfLine_id := P_DEBRIEF_LINE_Rec.DEBRIEF_LINE_ID;     -- for DFF
	 ELSE
   		FOR l_counter IN 1 .. l_msg_count
            		LOOP
                      		fnd_msg_pub.get
                        		( p_msg_index     => l_counter
                        		, p_encoded       => FND_API.G_FALSE
                        		, p_data          => l_data
                        		, p_msg_index_out => l_msg_index_out
                        		);
				--dbms_output.put_line('l_data '|| l_data);
                        END LOOP;
				    p_error_id := 1;
				    p_error := l_data;


	  END IF;
	if p_error = FND_API.G_RET_STS_SUCCESS
	then
		p_error := '';
	end if;
EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END SAVE_DEBRIEF_MATERIAL_LINE ;


/*
PROCEDURE UPDATE_CHARGES(
p_dbfLineId in number,
p_incidentId in number,
p_error       out NOCOPY varchar2,
p_error_id    out NOCOPY number
)IS
l_return_status varchar2(10);
l_object_version_number		NUMBER;
l_estimate_detail_id number;
l_msg_count number;
l_msg_data   varchar2(2000);
l_header_id  number;
l_busProcessId number;
l_user           number;
l_data            varchar2(2000);
l_msg_index_out   number;
P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;
l_organization_id number;

l_UOM_code varchar2(100);
l_order_header_id number;
l_order_type_id   number;
l_line_type_id    number;
l_Charges_Rec			CS_Charge_Details_PUB.Charges_Rec_Type;
l_line_number NUMBER;
l_dt_format   varchar2(20);
l_sr_date   DATE;
l_interface_status         varchar2(20);
l_interface_status_meaning varchar2(20);
l_orderCategoryCode        varchar2(50);


cursor  c_line_type_id_order (p_order_type_id number,p_incident_id Number) is
         select default_outbound_line_type_id
         from   oe_transaction_types_all
         where  transaction_type_id = p_order_type_id
         and    transaction_type_code = 'ORDER';

 cursor  c_line_type_id_return (p_order_type_id number,p_incident_id number) is
         select default_inbound_line_type_id
         from   oe_transaction_types_all
         where  transaction_type_id = p_order_type_id
         and    transaction_type_code = 'ORDER';

 Cursor c_status_meaning(p_code Varchar2) Is
  	select  meaning
  	from fnd_lookups
  	where lookup_type = 'CSF_INTERFACE_STATUS'
	and   lookup_code = p_code;


CURSOR c_dbfLineRec
    ( b_dbfLineId  csf_debrief_lines.DEBRIEF_LINE_ID%TYPE
    )
  IS
    SELECT BUSINESS_PROCESS_ID
    ,      inventory_item_id
    ,      UOM_CODE
    ,      QUANTITY
    ,      TXN_BILLING_TYPE_ID
    ,      REMOVED_PRODUCT_ID
    ,      RETURN_REASON_CODE
    FROM   CSF_DEBRIEF_MAT_LINES_V
    WHERE  DEBRIEF_LINE_ID = b_dbfLineId;

r_dbfLineRec           c_dbfLineRec%ROWTYPE;


BEGIN

	l_order_header_id := 0;


	OPEN c_dbfLineRec
	( b_dbfLineId => p_dbfLineId
	);
	FETCH c_dbfLineRec
	INTO r_dbfLineRec;
	CLOSE c_dbfLineRec;




	select line_order_category_code into l_orderCategoryCode
	from cs_transaction_types_b
	where TRANSACTION_TYPE_ID = (select TRANSACTION_TYPE_ID from CSF_DEBRIEF_MAT_LINES_V
					where DEBRIEF_LINE_ID = p_dbfLineId);


	select order_type_id into l_order_type_id from cs_business_processes where business_process_id = r_dbfLineRec.BUSINESS_PROCESS_ID;

			 if (l_orderCategoryCode = 'ORDER') then
			       open  c_line_type_id_order (l_order_type_id,p_incidentId);
			       fetch c_line_type_id_order into l_line_type_id;
			       close c_line_type_id_order;
		         else
			       open c_line_type_id_return (l_order_type_id,p_incidentId);
			       fetch c_line_type_id_return into l_line_type_id;
			       close c_line_type_id_return;
			 end if;




			l_Charges_Rec.original_source_id := p_incidentId;
			l_Charges_Rec.original_source_code := 'SR' ;
			l_Charges_Rec.incident_id :=  p_incidentId ;
			l_Charges_Rec.business_process_id := r_dbfLineRec.BUSINESS_PROCESS_ID;
			l_Charges_Rec.order_header_id := l_order_header_id ;
			l_Charges_Rec.line_category_code := l_orderCategoryCode;
			--l_Charges_Rec.line_type_id := l_line_type_id ;
			l_Charges_Rec.source_code := 'SD';
			l_Charges_Rec.source_id := p_dbfLineId;

			l_Charges_Rec.inventory_item_id_in := r_dbfLineRec.inventory_item_id;
			l_charges_rec.unit_of_measure_code := r_dbfLineRec.UOM_CODE;
			l_charges_rec.quantity_required := r_dbfLineRec.QUANTITY;
			l_charges_rec.txn_billing_type_id := r_dbfLineRec.TXN_BILLING_TYPE_ID;
			l_charges_rec.customer_product_id := r_dbfLineRec.REMOVED_PRODUCT_ID;
			l_charges_rec.installed_cp_return_by_date := sysdate;
			l_charges_rec.after_warranty_cost := null;
			l_charges_rec.currency_code := null;
			l_charges_rec.return_reason_code := r_dbfLineRec.RETURN_REASON_CODE;

			CS_Charge_Details_PUB.Create_Charge_Details(
				p_api_version 		=> 1.0,
				x_return_status 	=> l_return_status,
				x_msg_count 		=> l_msg_count,
				x_object_version_number => l_object_version_number,
				x_msg_data 		=> l_msg_data,
				x_estimate_detail_id 	=> l_estimate_detail_id,
				x_line_number		=> l_line_number,
				p_Charges_Rec 		=> l_Charges_Rec
					);

				 IF l_return_status = FND_API.G_RET_STS_SUCCESS
				  THEN
				    l_interface_status := 'SUCCEEDED';
				  ELSE
				    l_interface_status := 'FAILED';
				  END IF;

				open c_status_meaning(l_interface_status);
				fetch c_status_meaning INTO l_interface_status_meaning;
				close c_status_meaning;

CSF_DEBRIEF_LINES_PKG.Update_Row(
          p_DEBRIEF_LINE_ID            => p_dbfLineId,
          p_DEBRIEF_HEADER_ID          => FND_API.G_MISS_NUM,
          p_DEBRIEF_LINE_NUMBER        => FND_API.G_MISS_NUM,
          p_SERVICE_DATE               => FND_API.G_MISS_DATE,
          p_BUSINESS_PROCESS_ID        => FND_API.G_MISS_NUM,
          p_TXN_BILLING_TYPE_ID        => FND_API.G_MISS_NUM,
          p_INVENTORY_ITEM_ID          => FND_API.G_MISS_NUM,
          P_INSTANCE_ID                => FND_API.G_MISS_NUM,
          p_ISSUING_INVENTORY_ORG_ID   => FND_API.G_MISS_NUM,
          p_RECEIVING_INVENTORY_ORG_ID => FND_API.G_MISS_NUM,
          p_ISSUING_SUB_INVENTORY_CODE   => FND_API.G_MISS_CHAR,
          p_RECEIVING_SUB_INVENTORY_CODE => FND_API.G_MISS_CHAR,
          p_ISSUING_LOCATOR_ID           => FND_API.G_MISS_NUM,
          p_RECEIVING_LOCATOR_ID         => FND_API.G_MISS_NUM,
          p_PARENT_PRODUCT_ID            => FND_API.G_MISS_NUM,
          p_REMOVED_PRODUCT_ID           => FND_API.G_MISS_NUM,
          p_STATUS_OF_RECEIVED_PART      => FND_API.G_MISS_CHAR,
          p_ITEM_SERIAL_NUMBER           => FND_API.G_MISS_CHAR,
          p_ITEM_REVISION                => FND_API.G_MISS_CHAR,
          p_ITEM_LOTNUMBER               => FND_API.G_MISS_CHAR,
          p_UOM_CODE                     => FND_API.G_MISS_CHAR,
          p_QUANTITY                     => FND_API.G_MISS_NUM,
          p_RMA_HEADER_ID                => FND_API.G_MISS_NUM,
          p_DISPOSITION_CODE             => FND_API.G_MISS_CHAR,
          p_MATERIAL_REASON_CODE         => FND_API.G_MISS_CHAR,
          p_LABOR_REASON_CODE            => FND_API.G_MISS_CHAR,
          p_EXPENSE_REASON_CODE          => FND_API.G_MISS_CHAR,
          p_LABOR_START_DATE             => FND_API.G_MISS_DATE,
          p_LABOR_END_DATE               => FND_API.G_MISS_DATE,
          p_STARTING_MILEAGE             => FND_API.G_MISS_NUM,
          p_ENDING_MILEAGE               => FND_API.G_MISS_NUM,
          p_EXPENSE_AMOUNT               => FND_API.G_MISS_NUM,
          p_CURRENCY_CODE                => FND_API.G_MISS_CHAR,
          p_DEBRIEF_LINE_STATUS_ID       => FND_API.G_MISS_NUM,
          P_RETURN_REASON_CODE           => FND_API.G_MISS_CHAR,
          p_CHANNEL_CODE                 => 'WIRELESS_USER',
          p_CHARGE_UPLOAD_STATUS         => l_interface_status,
          p_CHARGE_UPLOAD_MSG_CODE       => FND_API.G_MISS_CHAR,
          p_CHARGE_UPLOAD_MESSAGE        => l_interface_status_meaning,
          p_IB_UPDATE_STATUS             => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_MSG_CODE           => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_MESSAGE            => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_STATUS          => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_MSG_CODE        => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_MESSAGE         => FND_API.G_MISS_CHAR,
          p_CREATED_BY                   => FND_API.G_MISS_NUM,
          p_CREATION_DATE                => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY              => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE             => FND_API.G_MISS_DATE,
          p_LAST_UPDATE_LOGIN            => FND_API.G_MISS_NUM,
          p_ATTRIBUTE1                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY           => FND_API.G_MISS_CHAR);

          commit work;

		   p_error := 'S';
		   p_error_id := 0;


	if p_error = FND_API.G_RET_STS_SUCCESS
	then
		p_error := '';
	end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;


END UPDATE_CHARGES;


PROCEDURE UPDATE_IB
(
p_dbfLineId in number,
p_incidentId in number,
p_error_id out NOCOPY number,
p_error out NOCOPY varchar2

) IS
  l_in_out_flag              varchar2(4);
  l_transaction_type_id_csi    number      ;
  l_txn_sub_type_id            number      ;

  l_instance_id		       number      ;
  l_parent_instance_id         number      ;
  l_new_instance_id            number      := null;
  l_new_instance_number        Varchar2(40);

  l_inventory_item_id          number      ;
  l_inv_organization_id        number      ;
  l_inv_subinventory_name      varchar2(60);
  l_inv_master_organization_id number      ;
  l_quantity                   number      ;
  l_mfg_serial_number_flag     varchar2(3) ;
  l_service_date               date        ;
  l_shipped_date	        date;
  l_currency_code              varchar2(10);

  l_party_id                   number      ;
  l_party_account_id           number      ;
  l_customer_id                number      ;
  l_party_site_id              number;

  l_debrief_line_id            number  ;
  l_debrief_header_id          number  ;
  l_incident_id                number  ;


  l_return_status              varchar2(1);
  l_mesg                       varchar2(2000);
  l_counter                    number;
  l_install_site_use_id        number;
  l_ship_site_use_id           number;
  l_parent_cpid			number;
  l_serial_number          varchar2(30) ;
  l_lot_number             varchar2(30) ;
  l_UOM			varchar2(30);
  l_msg_count       number;
  l_msg_index_out   number;
  l_interface_status         varchar2(20);
  l_interface_status_meaning varchar2(20);
  l_data varchar2(1000);
  l_msg_data varchar2(1000);
  P_DEBRIEF_LINE_Rec    CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type;


 Cursor c_internal_party_id  Is
        select internal_party_id
        from csi_install_parameters;

 Cursor c_status_meaning(p_code Varchar2) Is
  	select  meaning
  	from fnd_lookups
  	where lookup_type = 'CSF_INTERFACE_STATUS'
	and   lookup_code = p_code;

 Cursor c_site (p_incident_id number) Is
        select install_site_use_id,
               ship_to_site_use_id
        from   cs_incidents_all
        where  incident_id = p_incident_id;
 cursor c_party_site_id (p_install_site_id number) Is
        select party_site_id
        from hz_party_site_uses
        where party_site_use_id = p_install_site_id;
 Cursor c_instance_number(p_instance_id Number) is
       select instance_number
       from   csi_item_instances
       where  instance_id = p_instance_id;




CURSOR c_dbfLineRec
    ( b_dbfLineId  csf_debrief_lines.DEBRIEF_LINE_ID%TYPE
    )
  IS
    SELECT service_date
    ,      DEBRIEF_HEADER_ID
    ,      inventory_item_id
    ,      PARENT_PRODUCT_ID
    ,      ITEM_SERIAL_NUMBER
    ,      INVENTORY_ORG_ID
    ,      SUB_INVENTORY_CODE
    ,      INSTANCE_ID
    ,      QUANTITY
    ,      UOM_CODE

    FROM   CSF_DEBRIEF_MAT_LINES_V
    WHERE  DEBRIEF_LINE_ID = b_dbfLineId;

r_dbfLineRec           c_dbfLineRec%ROWTYPE;



cursor c_ib_rec (b_dbfLineId  csf_debrief_lines.DEBRIEF_LINE_ID%TYPE) is
select
        ctst.sub_type_id           sub_type_id                           ,
        ctst.transaction_type_id   transaction_type_id_csi ,
	cttv.line_order_category_code line_order_category_code
        from
        cs_transaction_types_vl cttv,
        cs_txn_billing_types    ctbt,
        cs_bus_process_txns     cbpt,
        cs_business_processes   cbp,
        csi_txn_sub_types       ctst,
        csi_txn_types           ctt,
        csi_instance_statuses    cis
        where
        cttv.transaction_type_id = ctbt.transaction_type_id and
        ctbt.transaction_type_id = cbpt.transaction_type_id
        and ctbt.transaction_type_id = (select transaction_type_id from CSF_DEBRIEF_MAT_LINES_V where debrief_line_id = b_dbfLineId)
        and trunc(sysdate) between nvl(ctbt.start_date_active,to_date(sysdate)) and nvl(ctbt.end_date_active,to_date(sysdate))
        and trunc(sysdate) between nvl(cbpt.start_date_active, to_date(sysdate)) and nvl(cbpt.end_date_active, to_date(sysdate))
        and cbpt.business_process_id = cbp.business_process_id
        and cbpt.business_process_id = (select business_process_id from CSF_DEBRIEF_MAT_LINES_V where debrief_line_id = b_dbfLineId)
        and cbp.field_service_flag = 'Y'
        and ctbt.billing_type = 'M'
        and ctst.cs_transaction_type_id = cttv.transaction_type_id
        and ctt.source_application_id=513
        and ctt.transaction_type_id = ctst.transaction_type_id
        and ctst.src_status_id = cis.instance_status_id(+)
        and (nvl(ctst.update_ib_flag, 'N') = 'N'
         or (    ctst.update_ib_flag = 'Y'
           and   trunc(sysdate) between nvl(cis.start_date_active,trunc(sysdate)) and nvl(cis.end_date_active,trunc(sysdate))
           and   nvl(cis.terminated_flag, 'N') <> 'Y'
           and   ctst.src_change_owner = 'Y'
           and   nvl(ctst.src_return_reqd, 'N') = 'N'
           and (
             (ctst.src_change_owner_to_code = 'I'
              and nvl(ctst.parent_reference_reqd, 'N') = 'N'
              and cttv.line_order_category_code='RETURN')
             or
             (ctst.src_change_owner_to_code = 'E'
              and ctst.src_reference_reqd = 'Y'
              and cttv.line_order_category_code='ORDER')
             )
           )
         ) ;

r_ib_rec c_ib_rec%ROWTYPE;

cursor c_party(b_dbfId  number) is
select customer_id,customer_account_id  from csf_debrief_tasks_v where debrief_header_id = b_dbfId;
r_party           c_party%ROWTYPE;


BEGIN


	OPEN c_ib_rec
	( b_dbfLineId => p_dbfLineId
	);
	FETCH c_ib_rec
	INTO r_ib_rec;
	CLOSE c_ib_rec;

	OPEN c_dbfLineRec
	( b_dbfLineId => p_dbfLineId
	);
	FETCH c_dbfLineRec
	INTO r_dbfLineRec;
	CLOSE c_dbfLineRec;


	l_currency_code :='USD';-- this method is never used now



	l_service_Date            := r_dbfLineRec.service_date;
	l_shipped_date            := r_dbfLineRec.service_date;
	l_debrief_line_id         := p_dbfLineId;
	l_debrief_header_id       := r_dbfLineRec.DEBRIEF_HEADER_ID;
	l_incident_id             := p_incidentId;
	l_parent_cpid             := r_dbfLineRec.PARENT_PRODUCT_ID;
	l_serial_number           := r_dbfLineRec.ITEM_SERIAL_NUMBER;
	l_transaction_type_id_csi := r_ib_rec.transaction_type_id_csi;
	l_txn_sub_type_id         := r_ib_rec.sub_type_id;

	l_instance_id		  := r_dbfLineRec.INSTANCE_ID;
	l_parent_instance_id      := r_dbfLineRec.PARENT_PRODUCT_ID;
	l_inventory_item_id       := r_dbfLineRec.inventory_item_id;
	l_inv_organization_id     := r_dbfLineRec.INVENTORY_ORG_ID ;
	l_inv_subinventory_name   := r_dbfLineRec.SUB_INVENTORY_CODE ;
	l_inv_master_organization_id  := r_dbfLineRec.INVENTORY_ORG_ID ;
	l_quantity                := r_dbfLineRec.QUANTITY;
	l_uom                     := r_dbfLineRec.UOM_CODE;
	l_mfg_serial_number_flag  := 'N' ;

	OPEN c_party
	( b_dbfId   => r_dbfLineRec.DEBRIEF_HEADER_ID
	);
	FETCH c_party
	INTO r_party;
	CLOSE c_party;

	l_party_id              := r_party.customer_id;
	l_party_account_id      := r_party.customer_account_id;


	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_inv_organization_id);

	  if  (r_ib_rec.line_order_category_code = 'RETURN' ) then
	     l_in_out_flag:='IN';
	     open c_internal_party_id;
	     fetch c_internal_party_id into l_party_id;
	     close c_internal_party_id;
	   else
	     l_in_out_flag:='OUT';
	     open c_site(l_incident_id);
	     fetch c_site into l_install_site_use_id, l_ship_site_use_id;
	     close c_site;
	     l_install_site_use_id := nvl(l_install_site_use_id, l_ship_site_use_id);
	     open c_party_site_id (l_install_site_use_id);
	     fetch c_party_site_id into l_party_site_id;
	     close c_party_site_id;
	  end if;

	csf_ib.update_install_base(
	p_api_version            => 1.0,
	p_init_msg_list          => null,
	p_commit                 => null,
	p_validation_level       => null,
	x_return_status          => l_return_status,
	x_msg_count              => l_msg_count,
	x_msg_data               => l_msg_data,
	x_new_instance_id        => l_new_instance_id,
	p_in_out_flag            => l_in_out_flag,
	p_transaction_type_id    => l_transaction_type_id_csi,
	p_txn_sub_type_id        => l_txn_sub_type_id,
	p_instance_id            => l_instance_id,
	p_inventory_item_id      => l_inventory_item_id,
	p_inv_organization_id    => l_inv_organization_id,
	p_inv_subinventory_name  => l_inv_subinventory_name,
	p_quantity               => l_quantity,
	p_inv_master_organization_id => l_inv_master_organization_id,
	p_mfg_serial_number_flag => l_mfg_serial_number_flag,
	p_serial_number          => l_serial_number,
	p_lot_number             => l_lot_number,
	p_unit_of_measure        => l_uom,
	p_party_id               => l_party_id,
	p_party_account_id       => l_party_account_id,
	p_party_site_id          => l_party_site_id,
	p_parent_instance_id     => l_parent_instance_id) ;


	   if l_RETURN_STATUS = 'S' then -- success
		   l_interface_status := 'SUCCEEDED';
	   else
	      l_interface_status := 'FAILED';
	    FOR l_counter IN 1 .. l_msg_count
	    LOOP
		      fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_data
			, p_msg_index_out => l_msg_index_out
			);
		      --dbms_output.put_line( 'Message: '||l_data );
	    END LOOP ;



	   end if;

	  open c_status_meaning(l_interface_status);
	  fetch c_status_meaning INTO l_interface_status_meaning;
	  close c_status_meaning;

CSF_DEBRIEF_LINES_PKG.Update_Row(
          p_DEBRIEF_LINE_ID            => p_dbfLineId,
          p_DEBRIEF_HEADER_ID          => FND_API.G_MISS_NUM,
          p_DEBRIEF_LINE_NUMBER        => FND_API.G_MISS_NUM,
          p_SERVICE_DATE               => FND_API.G_MISS_DATE,
          p_BUSINESS_PROCESS_ID        => FND_API.G_MISS_NUM,
          p_TXN_BILLING_TYPE_ID        => FND_API.G_MISS_NUM,
          p_INVENTORY_ITEM_ID          => FND_API.G_MISS_NUM,
          P_INSTANCE_ID                => FND_API.G_MISS_NUM,
          p_ISSUING_INVENTORY_ORG_ID   => FND_API.G_MISS_NUM,
          p_RECEIVING_INVENTORY_ORG_ID => FND_API.G_MISS_NUM,
          p_ISSUING_SUB_INVENTORY_CODE   => FND_API.G_MISS_CHAR,
          p_RECEIVING_SUB_INVENTORY_CODE => FND_API.G_MISS_CHAR,
          p_ISSUING_LOCATOR_ID           => FND_API.G_MISS_NUM,
          p_RECEIVING_LOCATOR_ID         => FND_API.G_MISS_NUM,
          p_PARENT_PRODUCT_ID            => FND_API.G_MISS_NUM,
          p_REMOVED_PRODUCT_ID           => FND_API.G_MISS_NUM,
          p_STATUS_OF_RECEIVED_PART      => FND_API.G_MISS_CHAR,
          p_ITEM_SERIAL_NUMBER           => FND_API.G_MISS_CHAR,
          p_ITEM_REVISION                => FND_API.G_MISS_CHAR,
          p_ITEM_LOTNUMBER               => FND_API.G_MISS_CHAR,
          p_UOM_CODE                     => FND_API.G_MISS_CHAR,
          p_QUANTITY                     => FND_API.G_MISS_NUM,
          p_RMA_HEADER_ID                => FND_API.G_MISS_NUM,
          p_DISPOSITION_CODE             => FND_API.G_MISS_CHAR,
          p_MATERIAL_REASON_CODE         => FND_API.G_MISS_CHAR,
          p_LABOR_REASON_CODE            => FND_API.G_MISS_CHAR,
          p_EXPENSE_REASON_CODE          => FND_API.G_MISS_CHAR,
          p_LABOR_START_DATE             => FND_API.G_MISS_DATE,
          p_LABOR_END_DATE               => FND_API.G_MISS_DATE,
          p_STARTING_MILEAGE             => FND_API.G_MISS_NUM,
          p_ENDING_MILEAGE               => FND_API.G_MISS_NUM,
          p_EXPENSE_AMOUNT               => FND_API.G_MISS_NUM,
          p_CURRENCY_CODE                => FND_API.G_MISS_CHAR,
          p_DEBRIEF_LINE_STATUS_ID       => FND_API.G_MISS_NUM,
          P_RETURN_REASON_CODE           => FND_API.G_MISS_CHAR,
          p_CHANNEL_CODE                 => 'WIRELESS_USER',
          p_CHARGE_UPLOAD_STATUS         => FND_API.G_MISS_CHAR,
          p_CHARGE_UPLOAD_MSG_CODE       => FND_API.G_MISS_CHAR,
          p_CHARGE_UPLOAD_MESSAGE        => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_STATUS             => l_interface_status,
          p_IB_UPDATE_MSG_CODE           => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_MESSAGE            => l_interface_status_meaning,
          p_SPARE_UPDATE_STATUS          => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_MSG_CODE        => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_MESSAGE         => FND_API.G_MISS_CHAR,
          p_CREATED_BY                   => FND_API.G_MISS_NUM,
          p_CREATION_DATE                => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY              => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE             => FND_API.G_MISS_DATE,
          p_LAST_UPDATE_LOGIN            => FND_API.G_MISS_NUM,
          p_ATTRIBUTE1                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY           => FND_API.G_MISS_CHAR);

commit work;

		   p_error := 'S';
		   p_error_id := 0;


	if p_error = FND_API.G_RET_STS_SUCCESS
	then
		p_error := '';
	end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;


END UPDATE_IB;

PROCEDURE UPDATE_SPARES(
p_dbfLineId in number,
p_dbfNr in varchar2,
p_error_id out NOCOPY number,
p_error out NOCOPY varchar2
)IS

  l_transaction_type_id      number    ;
  l_lot_number               varchar2(30) ;
  l_revision                 varchar2(3)  ;
  l_serial_number          varchar2(30) ;
  l_transfer_to_subinventory varchar2(10):= NULL; --optional
  l_transfer_to_locator      number      := NULL; --optional
  l_transfer_to_organization number      := NULL; --optional
  l_api_version              number       := 1.1;
  l_account_id               number      ;
  l_msg_Count number      ;
  mesg 			     Varchar2(2000);
  l_msg_data Varchar2(2000);
  l_locator_id		    number;
  lx_transaction_header_id  number;
  lx_transaction_id         number;
l_interface_status         varchar2(20);
l_interface_status_meaning varchar2(20);
l_return_status varchar2(10);
l_data varchar2(2000);
l_msg_index_out number;

 Cursor c_status_meaning(p_code Varchar2) Is
  	select  meaning
  	from fnd_lookups
  	where lookup_type = 'CSF_INTERFACE_STATUS'
	and   lookup_code = p_code;


CURSOR c_dbfLineRec
    ( b_dbfLineId  csf_debrief_lines.DEBRIEF_LINE_ID%TYPE
    )
  IS
    SELECT DEBRIEF_HEADER_ID
    ,      inventory_item_id
    ,      PARENT_PRODUCT_ID
    ,      ITEM_SERIAL_NUMBER
    ,      INVENTORY_ORG_ID
    ,      SUB_INVENTORY_CODE
    ,      INSTANCE_ID
    ,      QUANTITY
    ,      UOM_CODE
    ,      LOCATOR
    ,      ITEM_REVISION
    ,      ITEM_LOTNUMBER
    FROM   CSF_DEBRIEF_MAT_LINES_V
    WHERE  DEBRIEF_LINE_ID = b_dbfLineId;

r_dbfLineRec           c_dbfLineRec%ROWTYPE;



cursor c_ib_rec (b_dbfLineId  csf_debrief_lines.DEBRIEF_LINE_ID%TYPE) is
select
        ctst.sub_type_id           sub_type_id                           ,
        ctst.transaction_type_id   transaction_type_id_csi ,
	cttv.line_order_category_code line_order_category_code
        from
        cs_transaction_types_vl cttv,
        cs_txn_billing_types    ctbt,
        cs_bus_process_txns     cbpt,
        cs_business_processes   cbp,
        csi_txn_sub_types       ctst,
        csi_txn_types           ctt,
        csi_instance_statuses    cis
        where
        cttv.transaction_type_id = ctbt.transaction_type_id and
        ctbt.transaction_type_id = cbpt.transaction_type_id
        and ctbt.transaction_type_id = (select transaction_type_id from CSF_DEBRIEF_MAT_LINES_V where debrief_line_id = b_dbfLineId)
        and trunc(sysdate) between nvl(ctbt.start_date_active,to_date(sysdate)) and nvl(ctbt.end_date_active,to_date(sysdate))
        and trunc(sysdate) between nvl(cbpt.start_date_active, to_date(sysdate)) and nvl(cbpt.end_date_active, to_date(sysdate))
        and cbpt.business_process_id = cbp.business_process_id
        and cbpt.business_process_id = (select business_process_id from CSF_DEBRIEF_MAT_LINES_V where debrief_line_id = b_dbfLineId)
        and cbp.field_service_flag = 'Y'
        and ctbt.billing_type = 'M'
        and ctst.cs_transaction_type_id = cttv.transaction_type_id
        and ctt.source_application_id=513
        and ctt.transaction_type_id = ctst.transaction_type_id
        and ctst.src_status_id = cis.instance_status_id(+)
        and (nvl(ctst.update_ib_flag, 'N') = 'N'
         or (    ctst.update_ib_flag = 'Y'
           and   trunc(sysdate) between nvl(cis.start_date_active,trunc(sysdate)) and nvl(cis.end_date_active,trunc(sysdate))
           and   nvl(cis.terminated_flag, 'N') <> 'Y'
           and   ctst.src_change_owner = 'Y'
           and   nvl(ctst.src_return_reqd, 'N') = 'N'
           and (
             (ctst.src_change_owner_to_code = 'I'
              and nvl(ctst.parent_reference_reqd, 'N') = 'N'
              and cttv.line_order_category_code='RETURN')
             or
             (ctst.src_change_owner_to_code = 'E'
              and ctst.src_reference_reqd = 'Y'
              and cttv.line_order_category_code='ORDER')
             )
           )
         ) ;

r_ib_rec c_ib_rec%ROWTYPE;

BEGIN

	OPEN c_ib_rec
	( b_dbfLineId => p_dbfLineId
	);
	FETCH c_ib_rec
	INTO r_ib_rec;
	CLOSE c_ib_rec;

	OPEN c_dbfLineRec
	( b_dbfLineId => p_dbfLineId
	);
	FETCH c_dbfLineRec
	INTO r_dbfLineRec;
	CLOSE c_dbfLineRec;

	p_error_id := 0;
	p_error := 'S';




	if  (r_ib_rec.line_order_category_code = 'ORDER' ) then
		l_transaction_type_id := 93;  --ISSUEING
	else
		l_transaction_type_id := 94;  --RECEIVING
	end if;


			   CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL(
			   p_api_version            => l_api_version,
			   x_return_status          => l_RETURN_STATUS,
			   x_msg_count              => l_MSG_COUNT,
			   x_msg_data               => l_MSG_DATA,
			   p_init_msg_list          => FND_API.G_TRUE,
			   p_commit                 => FND_API.G_FALSE,
			   p_inventory_item_id      => r_dbfLineRec.inventory_item_id,
			   p_organization_id        => r_dbfLineRec.INVENTORY_ORG_ID,
			   p_subinventory_code      => r_dbfLineRec.SUB_INVENTORY_CODE,
			   p_locator_id             => r_dbfLineRec.LOCATOR,
			   p_serial_number          => r_dbfLineRec.ITEM_SERIAL_NUMBER,
			   p_quantity               => r_dbfLineRec.QUANTITY,
			   p_uom                    => r_dbfLineRec.UOM_CODE,
			   p_revision               => r_dbfLineRec.ITEM_REVISION ,
			   p_lot_number             => r_dbfLineRec.ITEM_LOTNUMBER,
			   p_transfer_to_subinventory => l_transfer_to_subinventory,
			   p_transfer_to_locator      => l_transfer_to_organization,
			   p_transfer_to_organization => l_transfer_to_organization,
			   p_source_id              => NULL,
			   p_source_line_id         => NULL,
			   p_transaction_type_id    => l_transaction_type_id,
			   p_account_id             => l_account_id,
			   px_transaction_header_id => lx_transaction_header_id,
			   px_transaction_id        => lx_transaction_id,
			   p_transaction_source_id  => r_dbfLineRec.DEBRIEF_HEADER_ID,
			   p_trx_source_line_id     => p_dbfLineId,
			   p_transaction_source_name => p_dbfNr );

			   if l_RETURN_STATUS = 'S' then -- success
			      l_interface_status := 'SUCCEEDED';
			   else
				l_interface_status := 'FAILED';
	    FOR l_counter IN 1 .. l_msg_count
	    LOOP
		      fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_data
			, p_msg_index_out => l_msg_index_out
			);
		      --dbms_output.put_line( 'Message: '||l_data );
	    END LOOP ;

			   end if;

				open c_status_meaning(l_interface_status);
				fetch c_status_meaning INTO l_interface_status_meaning;
				close c_status_meaning;

	CSF_DEBRIEF_LINES_PKG.Update_Row(
          p_DEBRIEF_LINE_ID            => p_dbfLineId,
          p_DEBRIEF_HEADER_ID          => FND_API.G_MISS_NUM,
          p_DEBRIEF_LINE_NUMBER        => FND_API.G_MISS_NUM,
          p_SERVICE_DATE               => FND_API.G_MISS_DATE,
          p_BUSINESS_PROCESS_ID        => FND_API.G_MISS_NUM,
          p_TXN_BILLING_TYPE_ID        => FND_API.G_MISS_NUM,
          p_INVENTORY_ITEM_ID          => FND_API.G_MISS_NUM,
          P_INSTANCE_ID                => FND_API.G_MISS_NUM,
          p_ISSUING_INVENTORY_ORG_ID   => FND_API.G_MISS_NUM,
          p_RECEIVING_INVENTORY_ORG_ID => FND_API.G_MISS_NUM,
          p_ISSUING_SUB_INVENTORY_CODE   => FND_API.G_MISS_CHAR,
          p_RECEIVING_SUB_INVENTORY_CODE => FND_API.G_MISS_CHAR,
          p_ISSUING_LOCATOR_ID           => FND_API.G_MISS_NUM,
          p_RECEIVING_LOCATOR_ID         => FND_API.G_MISS_NUM,
          p_PARENT_PRODUCT_ID            => FND_API.G_MISS_NUM,
          p_REMOVED_PRODUCT_ID           => FND_API.G_MISS_NUM,
          p_STATUS_OF_RECEIVED_PART      => FND_API.G_MISS_CHAR,
          p_ITEM_SERIAL_NUMBER           => FND_API.G_MISS_CHAR,
          p_ITEM_REVISION                => FND_API.G_MISS_CHAR,
          p_ITEM_LOTNUMBER               => FND_API.G_MISS_CHAR,
          p_UOM_CODE                     => FND_API.G_MISS_CHAR,
          p_QUANTITY                     => FND_API.G_MISS_NUM,
          p_RMA_HEADER_ID                => FND_API.G_MISS_NUM,
          p_DISPOSITION_CODE             => FND_API.G_MISS_CHAR,
          p_MATERIAL_REASON_CODE         => FND_API.G_MISS_CHAR,
          p_LABOR_REASON_CODE            => FND_API.G_MISS_CHAR,
          p_EXPENSE_REASON_CODE          => FND_API.G_MISS_CHAR,
          p_LABOR_START_DATE             => FND_API.G_MISS_DATE,
          p_LABOR_END_DATE               => FND_API.G_MISS_DATE,
          p_STARTING_MILEAGE             => FND_API.G_MISS_NUM,
          p_ENDING_MILEAGE               => FND_API.G_MISS_NUM,
          p_EXPENSE_AMOUNT               => FND_API.G_MISS_NUM,
          p_CURRENCY_CODE                => FND_API.G_MISS_CHAR,
          p_DEBRIEF_LINE_STATUS_ID       => FND_API.G_MISS_NUM,
          P_RETURN_REASON_CODE           => FND_API.G_MISS_CHAR,
          p_CHANNEL_CODE                 => 'WIRELESS_USER',
          p_CHARGE_UPLOAD_STATUS         => FND_API.G_MISS_CHAR,
          p_CHARGE_UPLOAD_MSG_CODE       => FND_API.G_MISS_CHAR,
          p_CHARGE_UPLOAD_MESSAGE        => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_STATUS             => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_MSG_CODE           => FND_API.G_MISS_CHAR,
          p_IB_UPDATE_MESSAGE            => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_STATUS          => l_interface_status,
          p_SPARE_UPDATE_MSG_CODE        => FND_API.G_MISS_CHAR,
          p_SPARE_UPDATE_MESSAGE         => l_interface_status_meaning,
          p_CREATED_BY                   => FND_API.G_MISS_NUM,
          p_CREATION_DATE                => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY              => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_DATE             => FND_API.G_MISS_DATE,
          p_LAST_UPDATE_LOGIN            => FND_API.G_MISS_NUM,
          p_ATTRIBUTE1                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                   => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY           => FND_API.G_MISS_CHAR);

	commit work;



if p_error = FND_API.G_RET_STS_SUCCESS
then
	p_error := '';
end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END UPDATE_SPARES;
*/

FUNCTION validate_labor_time(
      p_resource_type_code         in  Varchar2,
      p_resource_id                in  Number,
      p_debrief_line_id            in  Number,
      p_labor_start_date           in  Date,
      p_labor_end_date             in  Date
)
return varchar IS

l_return_status  varchar2(1);
l_msg_count      number;
l_msg_data       varchar2(255);
l_debrief_number number;
l_task_number    varchar2(30);
l_return_value VARCHAR2(255);


BEGIN

l_return_value := 'S';

CSF_DEBRIEF_PVT.VALIDATE_LABOR_TIMES (
      P_Init_Msg_List              =>  FND_API.G_FALSE,
      P_api_version_number         => 1.0,
      p_resource_type_code         => p_resource_type_code,
      p_resource_id                => p_resource_id,
      p_debrief_line_id            => p_debrief_line_id,
      p_labor_start_date           => p_labor_start_date,
      p_labor_end_date             => p_labor_end_date,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      x_debrief_number             => l_debrief_number,
      x_task_number                => l_task_number
  );

IF l_return_status <> 'S' THEN
	l_return_value := l_msg_data;
ELSE
	l_return_value := 'S';
END IF;

RETURN l_return_value;

END  validate_labor_time;


/* Updates info for travel debrief */
PROCEDURE Create_Travel_Debrief
  ( p_task_assignment_id     IN         NUMBER
  , p_debrief_header_id      IN		NUMBER
  , p_start_date	     IN		DATE
  , p_end_date		     IN		DATE
  , p_distance     	     IN		NUMBER
  , p_error_id               OUT NOCOPY NUMBER
  , p_error                  OUT NOCOPY VARCHAR2
  )
IS
P_DEBRIEF_Rec CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type;

l_return_status   varchar2(2000);
l_msg_count       number;
l_msg_data        varchar2(2000);
l_user            number;
l_data            varchar2(2000);
l_msg_index_out   number;

-- cursors

cursor c_dbf_rec (v_hrd_id number, v_asgn_id number) is
	select
	DEBRIEF_HEADER_ID, DEBRIEF_NUMBER,
	DEBRIEF_DATE, DEBRIEF_STATUS_ID,
	TASK_ASSIGNMENT_ID, CREATED_BY,
	CREATION_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
	ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
	ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
	ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
	ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
	ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
	ATTRIBUTE_CATEGORY, object_version_number,
	TRAVEL_START_TIME, TRAVEL_END_TIME,
	TRAVEL_DISTANCE_IN_KM
	from CSF_DEBRIEF_HEADERS
	where DEBRIEF_HEADER_ID = v_hrd_id
	and TASK_ASSIGNMENT_ID = v_asgn_id;

Begin
	p_error_id := 0; --Assume success

	l_user  := FND_GLOBAL.user_id;

	/* getting present values of the debrief header */
	open c_dbf_rec(p_debrief_header_id, p_task_assignment_id);
        fetch c_dbf_rec into P_DEBRIEF_Rec;
        close c_dbf_rec;

	/* changing the values to be updated */
	P_DEBRIEF_Rec.DEBRIEF_HEADER_ID		:= p_debrief_header_id;
	P_DEBRIEF_Rec.TRAVEL_START_TIME		:= p_start_date;
	P_DEBRIEF_Rec.TRAVEL_END_TIME		:= p_end_date;
	P_DEBRIEF_Rec.TRAVEL_DISTANCE_IN_KM     := p_distance;
	P_DEBRIEF_Rec.TASK_ASSIGNMENT_ID	:= p_task_assignment_id;

	CSF_DEBRIEF_PUB.Update_DEBRIEF(
	    P_Api_Version_Number  => 1.0,
	    P_Init_Msg_List       => FND_API.G_FALSE,
	    P_Commit              => FND_API.G_TRUE,
	    P_DEBRIEF_Rec         => P_DEBRIEF_Rec,
	    X_Return_Status       => l_return_status,
	    X_Msg_Count           => l_msg_count,
	    X_Msg_Data            => l_msg_data
	    );


	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	  THEN
	    /* API-call was successfull */
	      p_error_id := 0;
	      p_error := FND_API.G_RET_STS_SUCCESS;
	  ELSE
	    FOR l_counter IN 1 .. l_msg_count
	    LOOP
		      fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_data
			, p_msg_index_out => l_msg_index_out
			);
	    END LOOP ;
	    p_error_id := 1;
	    p_error := l_data;
	  END IF;

	   if p_error = FND_API.G_RET_STS_SUCCESS
	     then
		p_error := '';
	   end if;

EXCEPTION
  WHEN OTHERS
  THEN
    p_error_id := -1;
    p_error := SQLERRM;

END Create_Travel_Debrief;

-- To Update Debrief Header DFF values
PROCEDURE Update_Debrief_Header
   (  p_DEBRIEF_ID            IN    NUMBER,
      p_DEBRIEF_NUMBER        IN    VARCHAR2,
      p_DEBRIEF_DATE          IN    DATE,
      p_DEBRIEF_STATUS_ID     IN    NUMBER,
      p_TASK_ASSIGNMENT_ID    IN    NUMBER,
      p_CREATED_BY            IN    NUMBER,
      p_CREATION_DATE         IN    DATE,
      p_LAST_UPDATED_BY       IN    NUMBER,
      p_LAST_UPDATE_DATE      IN    DATE,
      p_LAST_UPDATE_LOGIN     IN    NUMBER,
      p_ATTRIBUTE1            IN    VARCHAR2,
      p_ATTRIBUTE2            IN    VARCHAR2,
      p_ATTRIBUTE3            IN    VARCHAR2,
      p_ATTRIBUTE4            IN    VARCHAR2,
      p_ATTRIBUTE5            IN    VARCHAR2,
      p_ATTRIBUTE6            IN    VARCHAR2,
      p_ATTRIBUTE7            IN    VARCHAR2,
      p_ATTRIBUTE8            IN    VARCHAR2,
      p_ATTRIBUTE9            IN    VARCHAR2,
      p_ATTRIBUTE10           IN    VARCHAR2,
      p_ATTRIBUTE11           IN    VARCHAR2,
      p_ATTRIBUTE12           IN    VARCHAR2,
      p_ATTRIBUTE13           IN    VARCHAR2,
      p_ATTRIBUTE14           IN    VARCHAR2,
      p_ATTRIBUTE15           IN    VARCHAR2,
      p_ATTRIBUTE_CATEGORY    IN    VARCHAR2,
      p_return_status         OUT NOCOPY VARCHAR2,
      p_error_count           OUT NOCOPY NUMBER,
      p_error                 OUT NOCOPY VARCHAR2
   )
IS
   P_DEBRIEF_Rec CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type;
   l_error_msg       VARCHAR2(2000);
   l_msg_index_out   NUMBER;
BEGIN

   -- set debrief_id
   P_DEBRIEF_Rec.DEBRIEF_HEADER_ID := p_DEBRIEF_ID;

   -- set other parameters
   IF p_ATTRIBUTE1 IS NULL OR p_ATTRIBUTE1 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE1 := p_ATTRIBUTE1;
   END IF;

   IF p_ATTRIBUTE2 IS NULL OR p_ATTRIBUTE2 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE2 := p_ATTRIBUTE2;
   END IF;

   IF p_ATTRIBUTE3 IS NULL OR p_ATTRIBUTE3 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE3 := p_ATTRIBUTE3;
   END IF;

   IF p_ATTRIBUTE4 IS NULL OR p_ATTRIBUTE4 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE4 := p_ATTRIBUTE4;
   END IF;

   IF p_ATTRIBUTE5 IS NULL OR p_ATTRIBUTE5 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE5 := p_ATTRIBUTE5;
   END IF;

   IF p_ATTRIBUTE6 IS NULL OR p_ATTRIBUTE6 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE6 := p_ATTRIBUTE6;
   END IF;

   IF p_ATTRIBUTE7 IS NULL OR p_ATTRIBUTE7 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE7 := p_ATTRIBUTE7;
   END IF;

   IF p_ATTRIBUTE8 IS NULL OR p_ATTRIBUTE8 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE8 := p_ATTRIBUTE8;
   END IF;

   IF p_ATTRIBUTE9 IS NULL OR p_ATTRIBUTE9 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE9 := p_ATTRIBUTE9;
   END IF;

   IF p_ATTRIBUTE10 IS NULL OR p_ATTRIBUTE10 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE10 := p_ATTRIBUTE10;
   END IF;

   IF p_ATTRIBUTE11 IS NULL OR p_ATTRIBUTE11 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE11 := p_ATTRIBUTE11;
   END IF;

   IF p_ATTRIBUTE12 IS NULL OR p_ATTRIBUTE12 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE12 := p_ATTRIBUTE12;
   END IF;

   IF p_ATTRIBUTE13 IS NULL OR p_ATTRIBUTE13 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE13 := p_ATTRIBUTE13;
   END IF;

   IF p_ATTRIBUTE14 IS NULL OR p_ATTRIBUTE14 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE14 := p_ATTRIBUTE14;
   END IF;

   IF p_ATTRIBUTE15 IS NULL OR p_ATTRIBUTE15 <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE15 := p_ATTRIBUTE15;
   END IF;

   IF p_ATTRIBUTE_CATEGORY IS NULL OR p_ATTRIBUTE_CATEGORY <> '#%*%#'
   THEN
      P_DEBRIEF_Rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
   END IF;

   CSF_DEBRIEF_PUB.Update_debrief (
      P_Api_Version_Number    => 1.0,
      P_Init_Msg_List         => FND_API.G_FALSE,
      P_Commit                => FND_API.G_FALSE,
      P_DEBRIEF_Rec           => P_DEBRIEF_Rec,
      X_Return_Status         => p_return_status,
      X_Msg_Count             => p_error_count,
      X_Msg_Data              => l_error_msg
      );

   IF p_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      commit;
   ELSE
      FOR l_counter IN 1 .. p_error_count
	   LOOP
	      FND_MSG_PUB.Get (
	         p_msg_index     => l_counter,
	         p_encoded       => FND_API.G_FALSE,
	         p_data          => l_error_msg,
	         p_msg_index_out => l_msg_index_out
            );
      END LOOP ;
      p_error := l_error_msg;
   END IF;


EXCEPTION
  WHEN OTHERS
  THEN
    p_error := SQLERRM;

END Update_Debrief_Header;

END csfw_debrief_pub;


/
