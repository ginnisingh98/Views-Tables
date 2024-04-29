--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDERBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDERBILLING_PVT" AS
/* $Header: EAMVWOBB.pls 120.4.12010000.2 2009/04/08 10:06:23 smrsharm ship $ */


-- Start of comments
--	API name 	: insert_AR_Interface
--	Type		: Private.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_WorkOrderBilling_PVT';

PROCEDURE insert_AR_Interface
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,
	p_ra_line			IN	WO_Billing_RA_Rec_Type
)

IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_AR_Interface';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_invoice_num              	NUMBER;
l_set_of_books			NUMBER;
l_uom_name			VARCHAR2(25);
l_desc_of_invoice		VARCHAR2(240);
l_count				NUMBER;
l_term_id			NUMBER;
l_business_group_id		NUMBER;
l_rounded_amount		NUMBER;
l_rounded_unit_price		NUMBER;
l_rounded_conv_rate		NUMBER;
l_batch_source_name            VARCHAR2(50);
l_stmt number :=0;
l_a_count number;
l_ou_id number;

BEGIN

    l_stmt := 10;
	-- Standard Start of API savepoint
    SAVEPOINT	insert_AR_Interface_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

-- validation 0: All required fields have to be present.
	if (p_ra_line.wip_entity_id is null) or
	   (p_ra_line.wip_entity_name is null) or
	   (p_ra_line.currency_code is null) or
           (p_ra_line.invoice_num is null) or
           (p_ra_line.line_num is null)
	then
		FND_MESSAGE.SET_NAME('EAM', 'EAM_NOT_ENOUGH_PARAMS');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
	end if;

	 l_stmt := 20;

/*CBOPPANA - FOR BUG 3050249 .

     COMMENTED THE FOLLOWING CODE AND ADDED ANOTHER COLUMN 'PRIMARY_SALESREP_NUMBER' IN THE INSERT STATEMENT TO ENTER ALWAYS -3 INTO AR INTERFACE TABLES

    EFFECT : EAM WILL NOT CHECK IF THE 'REQUIRE SALESREP 'OPTION IS SET TO YES/NO
  */


-- validation 2: customer chosen should exist in the table 'hz_cust_accounts'.
	select count(*) into l_count
	from hz_cust_accounts
	where cust_account_id=p_ra_line.customer_id;

	if (l_count=0) then
		FND_MESSAGE.SET_NAME('EAM', 'EAM_CUSTOMER_NOT_EXIST');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
	end if;

-- validation 3: unit selling price * quantity = amount
	if not (p_ra_line.unit_selling_price * p_ra_line.quantity = p_ra_line.billed_amount)
	then
		FND_MESSAGE.SET_NAME('EAM', 'EAM_RA_WRONG_AMOUNT');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
	end if;

	 l_stmt := 30;

-- find the necessary data before inserting into the table

    begin

	SELECT org_information1, to_number(ORG_INFORMATION3)
	  INTO l_set_of_books, l_ou_id
	  FROM hr_organization_information
	 WHERE org_information_context = 'Accounting Information'
	   AND organization_id = p_ra_line.org_id;




    exception
	when no_data_found then
	  FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_ORG_ID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    end;

	-- get desc. of invoice
	l_desc_of_invoice:='Invoice for work order #' || p_ra_line.wip_entity_id || ', ' || p_ra_line.wip_entity_name;

	-- get uom name
    begin
	select unit_of_measure into l_uom_name
	from mtl_units_of_measure
	where uom_code = p_ra_line.uom_code;
    exception
        when no_data_found then
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_UOM_CODE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    end;

 l_stmt := 40;
	-- get term id
begin
select nvl(payment_term_id, 4)
into l_term_id
from hz_cust_accounts
where cust_account_id = p_ra_line.customer_id;

 exception
 when others then
 l_term_id :=4;
end;



-- get rounded amount
      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_ra_line.billed_amount, c1.precision),
                        round(p_ra_line.billed_amount/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_amount
      from
        fnd_currencies c1
      where
        c1.currency_code = p_ra_line.currency_code;

-- get rounded unit price
      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_ra_line.unit_selling_price, c1.precision),
                        round(p_ra_line.unit_selling_price/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_unit_price
      from
        fnd_currencies c1
      where
        c1.currency_code = p_ra_line.currency_code;

-- get rounded conversion rate
      select decode(c1.minimum_accountable_unit,
                        NULL, round(nvl(p_ra_line.conversion_rate, 1), c1.precision),
                        round(nvl(p_ra_line.conversion_rate,1)/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_conv_rate
      from
        fnd_currencies c1
      where
        c1.currency_code = p_ra_line.currency_code;

         l_stmt := 45;

/*  Added Code for bug # 3680865 - Start */
--      get the BATCH SOURCE NAME from the ra_interfaces_batches corresponging to batch_source_id=25 for work order billing




		SELECT NAME
        INTO l_batch_source_name
        FROM RA_BATCH_SOURCES_all
        WHERE BATCH_SOURCE_ID=25
		and org_id = l_ou_id;       --For Work Order Billing



 l_stmt := 50;
-- insert into the table.
/*CBOPPANA 3050249 ALWAYS INSERT VALUE -3 FOR COLUMN 'PRIMARY_SALESREP_NUMBER' */

	insert into ra_interface_lines_all
(interface_line_context,
interface_line_Attribute1,
interface_line_Attribute2,
interface_line_Attribute3,
interface_line_Attribute4,
interface_line_Attribute5,
interface_line_Attribute6,
interface_line_Attribute7,
interface_line_Attribute8,
batch_source_name,
set_of_books_id,
line_type,
description,
currency_code,
amount,
cust_trx_type_name,
cust_trx_type_id,
term_id,
orig_system_bill_customer_id,
orig_system_bill_address_id,
conversion_type,
conversion_date,
conversion_rate,
inventory_item_id,
uom_code,
uom_name,
tax_exempt_flag,
org_id,
quantity,
unit_selling_price,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
primary_salesrep_number)
values
('Work Order Billing',
 p_ra_line.wip_entity_id,
 p_ra_line.wip_entity_name,
 p_ra_line.invoice_num,
 p_ra_line.line_num,
 p_ra_line.work_request,
 null,
 p_ra_line.project_id,
 p_ra_line.task_id,
l_batch_source_name, --bug 3680865
l_set_of_books,
'LINE',
l_desc_of_invoice,
p_ra_line.currency_code,
--p_ra_line.billed_amount,
l_rounded_amount,
'INVOICE',
1,
l_term_id,
p_ra_line.customer_id,
p_ra_line.bill_to_address,
nvl(p_ra_line.conversion_type, 'User'),
p_ra_line.conversion_date,
--nvl(p_ra_line.conversion_rate, 1),
l_rounded_conv_rate,
p_ra_line.billed_inventory_item_id,
p_ra_line.uom_code,
l_uom_name,
'S',
l_ou_id,
p_ra_line.quantity,
l_rounded_unit_price,
fnd_global.user_id,
sysdate,
fnd_global.user_id,
sysdate    ,
fnd_global.login_id,
TO_CHAR(-3)
);


 l_stmt := 60;
-- Bug 3050249: DGUPTA: Need to enter sales credit information for -3
insert into RA_INTERFACE_SALESCREDITS_ALL
(interface_line_context,
interface_line_Attribute1,
interface_line_Attribute2,
interface_line_Attribute3,
interface_line_Attribute4,
interface_line_Attribute5,
interface_line_Attribute6,
interface_line_Attribute7,
interface_line_Attribute8,
salesrep_number,
sales_credit_type_name,
sales_credit_percent_split,
ORG_ID)
values(
'Work Order Billing' ,
 p_ra_line.wip_entity_id,
 p_ra_line.wip_entity_name,
 p_ra_line.invoice_num,
 p_ra_line.line_num,
 p_ra_line.work_request,
 null,
 p_ra_line.project_id,
 p_ra_line.task_id,
'-3',
'Quota Sales Credit',
100,
l_ou_id);



 l_stmt := 70;

	-- End of API body.

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO insert_AR_Interface_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_AR_Interface_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>       x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_AR_Interface_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END insert_AR_Interface;



PROCEDURE insert_WOB_Table
(       p_api_version                   IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL      ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY    NUMBER                          ,
        x_msg_data                      OUT NOCOPY    VARCHAR2                        ,
        p_wob_rec                       IN      WO_Billing_Rec_Type
) IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_WO_Table';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_rounded_amount		NUMBER;
l_rounded_unit_price		NUMBER;
l_rounded_conv_rate		NUMBER;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	insert_WO_Table_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	-- check all the "not null" fields
	if (p_wob_rec.organization_id is null) or
	   --(p_wob_rec.customer_id is null) or
	   --(p_wob_rec.bill_to_address_id is null) or
	   (p_wob_rec.wip_entity_id is null) or
	   (p_wob_rec.billed_inventory_item_id is null) or
	   (p_wob_rec.billed_uom_code is null) or
	   (p_wob_rec.billed_amount is null) or
	   --(p_wob_rec.invoice_trx_number is null) or
	   --(p_wob_rec.invoice_line_number is null) or
	   (p_wob_rec.currency_code is null)
	then
                FND_MESSAGE.SET_NAME('EAM', 'EAM_WRONG_PARAM_COST_PL');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
	end if;

-- get rounded amount
      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_wob_rec.billed_amount, c1.precision),
                        round(p_wob_rec.billed_amount/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_amount
      from
        fnd_currencies c1
      where
        c1.currency_code = p_wob_rec.currency_code;

-- get rounded cost_or_list_price
      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_wob_rec.cost_or_listprice, c1.precision),
                        round(p_wob_rec.cost_or_listprice/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_unit_price
      from
        fnd_currencies c1
      where
        c1.currency_code = p_wob_rec.currency_code;

-- get rounded conversion rate
      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_wob_rec.conversion_rate, c1.precision),
                        round(p_wob_rec.conversion_rate/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
        into l_rounded_conv_rate
      from
        fnd_currencies c1
      where
        c1.currency_code = p_wob_rec.currency_code;


	insert into eam_work_order_bills
(
	 ORGANIZATION_ID               ,
 CUSTOMER_ID                     ,
 BILL_TO_ADDRESS_ID            ,
 WIP_ENTITY_ID                ,
 OPERATION_SEQ_NUM            ,
 INVENTORY_ITEM_ID      ,
 RESOURCE_ID                   ,
 BILLED_INVENTORY_ITEM_ID     ,
 BILLED_UOM_CODE             ,
 BILLED_QUANTITY            ,
 PRICE_LIST_HEADER_ID      ,
 COST_TYPE_ID             ,
 COST_OR_LISTPRICE       ,
 COSTPLUS_PERCENTAGE    ,
 BILLED_AMOUNT         ,
 INVOICE_TRX_NUMBER     ,
 INVOICE_LINE_NUMBER   ,
 CURRENCY_CODE        ,
 CONVERSION_RATE     ,
 CONVERSION_TYPE_CODE      ,
 CONVERSION_RATE_DATE     ,
 PROJECT_ID             ,
 TASK_ID                 ,
 WORK_REQUEST_ID       ,
 PA_EVENT_ID          ,
 BILLING_BASIS,
 BILLING_METHOD,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY            ,
 CREATION_DATE             ,
 CREATED_BY               ,
 LAST_UPDATE_LOGIN
)
values
(
 p_wob_rec.organization_id,
 p_wob_rec.customer_id,
 p_wob_rec.bill_to_address_id,
 p_wob_rec.wip_entity_id,
 p_wob_rec.operation_seq_num,
 p_wob_rec.inventory_item_id,
 p_wob_rec.resource_id,
 p_wob_rec.billed_inventory_item_id,
 p_wob_rec.billed_uom_code,
 p_wob_rec.billed_quantity,
 p_wob_rec.price_list_header_id,
 p_wob_rec.cost_type_id,
-- p_wob_rec.cost_or_listprice,
 l_rounded_unit_price,
 p_wob_rec.costplus_percentage,
-- p_wob_rec.billed_amount,
 l_rounded_amount,
 p_wob_rec.invoice_trx_number,
 p_wob_rec.invoice_line_number,
 p_wob_rec.currency_code,
-- p_wob_rec.conversion_rate,
 l_rounded_conv_rate,
 p_wob_rec.conversion_type_code,
 p_wob_rec.conversion_rate_date,
 p_wob_rec.project_id,
 p_wob_rec.task_id,
 p_wob_rec.work_request_id,
 p_wob_rec.pa_event_id,
 p_wob_rec.billing_basis,
 p_wob_rec.billing_method,
 sysdate,
 fnd_global.user_id,
 sysdate    ,
 fnd_global.user_id,
 fnd_global.login_id
);



	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO insert_WO_Table_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_WO_Table_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_WO_Table_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END insert_WOB_Table;


/*
PROCEDURE insert_PAEvent_Table
(       p_api_version                   IN      NUMBER
,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE
,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL
,
        x_return_status         OUT NOCOPY    VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER
,
        x_msg_data                      OUT NOCOPY    VARCHAR2
,
        p_pa_rec                       IN      WO_Billing_PA_Event_Rec_Type
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_PAEvent_Table';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
--l_event_num			number;
--l_event_id			number;

   l_multi_currency_billing_flag     VARCHAR2(15);
   l_baseline_funding_flag           VARCHAR2(15);
   l_revproc_currency_code           VARCHAR2(15);
   l_invproc_currency_code           VARCHAR2(30);
   l_project_currency_code           VARCHAR2(15);
   l_project_bil_rate_date_code      VARCHAR2(30);
   l_project_bil_rate_type           VARCHAR2(30);
   l_project_bil_rate_date           DATE;
   l_project_bil_exchange_rate       NUMBER;
   l_projfunc_currency_code          VARCHAR2(15);
   l_projfunc_bil_rate_date_code     VARCHAR2(30);
   l_projfunc_bil_rate_type          VARCHAR2(30);
   l_invproc_currency_type           VARCHAR2(30);
   l_projfunc_bil_rate_date          DATE;
   l_projfunc_bil_exchange_rate      NUMBER;
   l_funding_rate_date_code          VARCHAR2(30);
   l_funding_rate_type               VARCHAR2(30);
   l_funding_rate_date               DATE;
   l_funding_exchange_rate           NUMBER;
   l_return_status                   VARCHAR2(30);
   l_msg_count                       NUMBER;
   l_msg_data                        VARCHAR2(30);
   l_rounded_amount		     NUMBER;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	insert_PAEvent_Table_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

/*
	-- get event_num

	SELECT NVL(MAX(Event_Num) , 0) + 1 into l_event_num
  	FROM pa_events
  	WHERE Project_ID = p_pa_rec.project_id
  	AND (( Task_ID IS NULL and p_pa_rec.task_id is null) OR Task_ID = p_pa_rec.task_id);

	-- get event_id

	SELECT pa_events_s.nextval into l_event_id
    	FROM   dual;
*######/

	-- get pa default values
--dbms_output.put_line('before defaults');

  PA_MULTI_CURRENCY_BILLING.get_project_defaults
  ( P_project_id                  => p_pa_rec.project_id
  , X_multi_currency_billing_flag => l_multi_currency_billing_flag
  , X_baseline_funding_flag       => l_baseline_funding_flag
  , X_revproc_currency_code       => l_revproc_currency_code
  , X_invproc_currency_type       => l_invproc_currency_type
  , X_invproc_currency_code       => l_invproc_currency_code
  , X_project_currency_code       => l_project_currency_code
  , X_project_bil_rate_date_code  => l_project_bil_rate_date_code
  , X_project_bil_rate_type       => l_project_bil_rate_type
  , X_project_bil_rate_date       => l_project_bil_rate_date
  , X_project_bil_exchange_rate   => l_project_bil_exchange_rate
  , X_projfunc_currency_code      => l_projfunc_currency_code
  , X_projfunc_bil_rate_date_code => l_projfunc_bil_rate_date_code
  , X_projfunc_bil_rate_type      => l_projfunc_bil_rate_type
  , X_projfunc_bil_rate_date      => l_projfunc_bil_rate_date
  , X_projfunc_bil_exchange_rate  => l_projfunc_bil_exchange_rate
  , X_funding_rate_date_code      => l_funding_rate_date_code
  , X_funding_rate_type           => l_funding_rate_type
  , X_funding_rate_date           => l_funding_rate_date
  , X_funding_exchange_rate       => l_funding_exchange_rate
  , X_return_status               => l_return_status
  , X_msg_count                   => l_msg_count
  , X_msg_data                    => l_msg_data);

  if (l_return_status='E') then
         FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_PROJ_ID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
  end if;


-- Get the rounded amount

      select decode(c1.minimum_accountable_unit,
                        NULL, round(p_pa_rec.bill_trans_bill_amount, c1.precision),
                        round(p_pa_rec.bill_trans_bill_amount/c1.minimum_accountable_unit)
                        * c1.minimum_accountable_unit )
	into l_rounded_amount
      from
        fnd_currencies c1
      where
        c1.currency_code = p_pa_rec.billing_currency_code;


  --dbms_output.put_line('got defaults');
	-- insert into pa_events
	insert into pa_events
	(
	task_id,
	event_num,
	event_type,
	description,
	bill_amount,
	revenue_amount,
	revenue_distributed_flag,
	bill_hold_flag,
	project_id,
	organization_id,
	calling_place,
	calling_process,
	event_id,
	reference1,
	reference2,
	reference3,
	reference4,
	billed_flag,
	bill_trans_currency_code,
	bill_trans_bill_amount,
	bill_trans_rev_amount,
	project_currency_code,
	projfunc_currency_code,
	funding_rate_type,
	funding_rate_date,
	funding_exchange_rate,
	revproc_currency_code,
	invproc_currency_code,
	completion_date,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login)
	values
	(
	p_pa_rec.task_id,
	p_pa_rec.event_num,
	'Manual',
	'Event for Work Order #' || p_pa_rec.wip_entity_id || ', ' || p_pa_rec.wip_entity_name,
	0,
	0,
	'N',
	'N',
	p_pa_rec.project_id,
	p_pa_rec.organization_id,
	'EAM',
	'Work Order Billing',
	p_pa_rec.event_id,
	p_pa_rec.wip_entity_id,
	p_pa_rec.wip_entity_name,
	p_pa_rec.work_request_id,
	p_pa_rec.service_request_id,
	'N',
	p_pa_rec.billing_currency_code,
	--p_pa_rec.bill_trans_bill_amount,
	--p_pa_rec.bill_trans_rev_amount,
	l_rounded_amount,
	l_rounded_amount,
        l_project_currency_code,
        l_projfunc_currency_code,
        l_funding_rate_type,
        l_funding_rate_date,
        l_funding_exchange_rate,
        l_revproc_currency_code,
        l_invproc_currency_code,
	sysdate,
 	sysdate    ,
 	fnd_global.user_id,
 	sysdate,
 	fnd_global.user_id,
 	fnd_global.login_id
	);

	--dbms_output.put_line('finished inserting');


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO insert_PAEvent_Table_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_PAEvent_Table_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO insert_PAEvent_Table_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END insert_PAEvent_Table;
*/





END EAM_WorkOrderBilling_PVT;


/
