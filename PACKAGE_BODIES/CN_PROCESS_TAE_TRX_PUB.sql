--------------------------------------------------------
--  DDL for Package Body CN_PROCESS_TAE_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PROCESS_TAE_TRX_PUB" AS
--$Header: cnpptxwb.pls 120.2.12010000.2 2009/01/29 07:06:19 gmarwah ship $


/*-------------------------------------------------------------------------*
 |                             PRIVATE CONSTANTS
 *-------------------------------------------------------------------------*/
   G_PKG_NAME  CONSTANT VARCHAR2(30):='CN_PROCESS_TAE_TRX_PUB';
   G_FILE_NAME CONSTANT VARCHAR2(12):='cnpptxwb.pls';


/*-------------------------------------------------------------------------*
 |                             PRIVATE DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/

FUNCTION get_adjusted_by
   RETURN VARCHAR2 IS
   l_adjusted_by 	VARCHAR2(100) := '0';
BEGIN
   SELECT user_name
     INTO l_adjusted_by
     FROM fnd_user
    WHERE user_id  = fnd_profile.value('USER_ID');
   RETURN l_adjusted_by;
EXCEPTION
   WHEN OTHERS THEN
      RETURN l_adjusted_by;
END;


/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

PROCEDURE Process_Trx_Records(
 	p_api_version   	    	IN	NUMBER,
     	p_init_msg_list         	IN      VARCHAR2 	:= FND_API.G_TRUE,
	p_commit	            	IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      	IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,

	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
	p_org_id                         IN NUMBER)
IS
    CURSOR trx_records IS
    SELECT WIN.TRANS_OBJECT_ID,
           WIN.org_id,
           WIN.role,
           WIN.resource_id
    FROM
         JTF_TAE_1001_SC_WINNERS WIN

    WHERE
       WIN.SOURCE_ID = -1001 AND
       WIN.TRANS_OBJECT_TYPE_ID = -1002 AND
       WIN.ORG_ID=p_org_id;

    TYPE api_id_list         	is TABLE of cn_comm_lines_api.comm_lines_api_id%TYPE;
    TYPE org_id_list         	is TABLE of cn_comm_lines_api.org_id%TYPE;
    TYPE role_list        	is TABLE of JTF_TAE_1001_SC_WINNERS.role%TYPE;
    TYPE resource_id_list    	is TABLE of JTF_TAE_1001_SC_WINNERS.resource_id%TYPE;

    l_api_id           api_id_list;
    l_org_id           org_id_list;
    l_role		role_list;
    l_resource_id	resource_id_list;

    l_max_rows         NUMBER := 10000;
    l_attempts         NUMBER := 0;
    l_exceptions       BOOLEAN := FALSE;

    l_api_name			CONSTANT VARCHAR2(30) := 'process_trx_records';
    l_api_version      		CONSTANT NUMBER := 1.0;
    l_adjusted_by	        VARCHAR2(30);

BEGIN

    l_adjusted_by := get_adjusted_by;

   -- Standard Start of API savepoint
   SAVEPOINT process_trx_records;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


    l_attempts    := 1;
    l_exceptions  := FALSE;

    --dbms_output.put_line('Before Insert Statement');

    INSERT into CN_COMM_LINES_API
      ( SALESREP_ID,
        PROCESSED_DATE,
        PROCESSED_PERIOD_ID,
        TRANSACTION_AMOUNT,
        TRX_TYPE,
        REVENUE_CLASS_ID,
        LOAD_STATUS,
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
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
        ATTRIBUTE21,
        ATTRIBUTE22,
        ATTRIBUTE23,
        ATTRIBUTE24,
        ATTRIBUTE25,
        ATTRIBUTE26,
        ATTRIBUTE27,
        ATTRIBUTE28,
        ATTRIBUTE29,
        ATTRIBUTE30,
        ATTRIBUTE31,
        ATTRIBUTE32,
        ATTRIBUTE33,
        ATTRIBUTE34,
        ATTRIBUTE35,
        ATTRIBUTE36,
        ATTRIBUTE37,
        ATTRIBUTE38,
        ATTRIBUTE39,
        ATTRIBUTE40,
        ATTRIBUTE41,
        ATTRIBUTE42,
        ATTRIBUTE43,
        ATTRIBUTE44,
        ATTRIBUTE45,
        ATTRIBUTE46,
        ATTRIBUTE47,
        ATTRIBUTE48,
        ATTRIBUTE49,
        ATTRIBUTE50,
        ATTRIBUTE51,
        ATTRIBUTE52,
        ATTRIBUTE53,
        ATTRIBUTE54,
        ATTRIBUTE55,
        ATTRIBUTE56,
        ATTRIBUTE57,
        ATTRIBUTE58,
        ATTRIBUTE59,
        ATTRIBUTE60,
        ATTRIBUTE61,
        ATTRIBUTE62,
        ATTRIBUTE63,
        ATTRIBUTE64,
        ATTRIBUTE65,
        ATTRIBUTE66,
        ATTRIBUTE67,
        ATTRIBUTE68,
        ATTRIBUTE69,
        ATTRIBUTE70,
        ATTRIBUTE71,
        ATTRIBUTE72,
        ATTRIBUTE73,
        ATTRIBUTE74,
        ATTRIBUTE75,
        ATTRIBUTE76,
        ATTRIBUTE77,
        ATTRIBUTE78,
        ATTRIBUTE79,
        ATTRIBUTE80,
        ATTRIBUTE81,
        ATTRIBUTE82,
        ATTRIBUTE83,
        ATTRIBUTE84,
        ATTRIBUTE85,
        ATTRIBUTE86,
        ATTRIBUTE87,
        ATTRIBUTE88,
        ATTRIBUTE89,
        ATTRIBUTE90,
        ATTRIBUTE91,
        ATTRIBUTE92,
        ATTRIBUTE93,
        ATTRIBUTE94,
        ATTRIBUTE95,
        ATTRIBUTE96,
        ATTRIBUTE97,
        ATTRIBUTE98,
        ATTRIBUTE99,
        ATTRIBUTE100,
        COMM_LINES_API_ID,
        CONC_BATCH_ID,
        PROCESS_BATCH_ID,
        SALESREP_NUMBER,
        ROLLUP_DATE,
        SOURCE_DOC_ID,
        SOURCE_DOC_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        TRANSACTION_CURRENCY_CODE,
        EXCHANGE_RATE,
        ACCTD_TRANSACTION_AMOUNT,
        TRX_ID,
        TRX_LINE_ID,
        TRX_SALES_LINE_ID,
        QUANTITY,
        SOURCE_TRX_NUMBER,
        DISCOUNT_PERCENTAGE,
        MARGIN_PERCENTAGE,
        SOURCE_TRX_ID,
        SOURCE_TRX_LINE_ID,
        SOURCE_TRX_SALES_LINE_ID,
        NEGATED_FLAG,
        CUSTOMER_ID,
        INVENTORY_ITEM_ID,
        ORDER_NUMBER,
        BOOKED_DATE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ADJUST_DATE,
        ADJUSTED_BY,
        REVENUE_TYPE,
        ADJUST_ROLLUP_FLAG,
        ADJUST_COMMENTS,
        ADJUST_STATUS,
        LINE_NUMBER,
        BILL_TO_ADDRESS_ID,
        SHIP_TO_ADDRESS_ID,
        BILL_TO_CONTACT_ID,
        SHIP_TO_CONTACT_ID,
        ADJ_COMM_LINES_API_ID,
        PRE_DEFINED_RC_FLAG,
        ROLLUP_FLAG,
        FORECAST_ID,
        UPSIDE_QUANTITY,
        UPSIDE_AMOUNT,
        UOM_CODE,
        REASON_CODE,
        TYPE,
        PRE_PROCESSED_CODE,
        QUOTA_ID,
        SRP_PLAN_ASSIGN_ID,
        ROLE_ID,
        COMP_GROUP_ID,
        COMMISSION_AMOUNT,
        EMPLOYEE_NUMBER,
        REVERSAL_FLAG,
        REVERSAL_HEADER_ID,
        SALES_CHANNEL,
        OBJECT_VERSION_NUMBER,
        SPLIT_PCT,
        SPLIT_STATUS,
	ORG_ID)
SELECT  ILV.SALESREP_ID,
        CCLA.PROCESSED_DATE,
        CCLA.PROCESSED_PERIOD_ID,
        --CCLA.TRANSACTION_AMOUNT,
        ILV.net_trx_amount,
        CCLA.TRX_TYPE,
        CCLA.REVENUE_CLASS_ID,
        'UNLOADED',
        CCLA.ATTRIBUTE_CATEGORY,
        CCLA.ATTRIBUTE1,
        CCLA.ATTRIBUTE2,
        CCLA.ATTRIBUTE3,
        CCLA.ATTRIBUTE4,
        CCLA.ATTRIBUTE5,
        CCLA.ATTRIBUTE6,
        CCLA.ATTRIBUTE7,
        CCLA.ATTRIBUTE8,
        CCLA.ATTRIBUTE9,
        CCLA.ATTRIBUTE10,
        CCLA.ATTRIBUTE11,
        CCLA.ATTRIBUTE12,
        CCLA.ATTRIBUTE13,
        CCLA.ATTRIBUTE14,
        CCLA.ATTRIBUTE15,
        CCLA.ATTRIBUTE16,
        CCLA.ATTRIBUTE17,
        CCLA.ATTRIBUTE18,
        CCLA.ATTRIBUTE19,
        CCLA.ATTRIBUTE20,
        CCLA.ATTRIBUTE21,
        CCLA.ATTRIBUTE22,
        CCLA.ATTRIBUTE23,
        CCLA.ATTRIBUTE24,
        CCLA.ATTRIBUTE25,
        CCLA.ATTRIBUTE26,
        CCLA.ATTRIBUTE27,
        CCLA.ATTRIBUTE28,
        CCLA.ATTRIBUTE29,
        CCLA.ATTRIBUTE30,
        CCLA.ATTRIBUTE31,
        CCLA.ATTRIBUTE32,
        CCLA.ATTRIBUTE33,
        CCLA.ATTRIBUTE34,
        CCLA.ATTRIBUTE35,
        CCLA.ATTRIBUTE36,
        CCLA.ATTRIBUTE37,
        CCLA.ATTRIBUTE38,
        CCLA.ATTRIBUTE39,
        CCLA.ATTRIBUTE40,
        CCLA.ATTRIBUTE41,
        CCLA.ATTRIBUTE42,
        CCLA.ATTRIBUTE43,
        CCLA.ATTRIBUTE44,
        CCLA.ATTRIBUTE45,
        CCLA.ATTRIBUTE46,
        CCLA.ATTRIBUTE47,
        CCLA.ATTRIBUTE48,
        CCLA.ATTRIBUTE49,
        CCLA.ATTRIBUTE50,
        CCLA.ATTRIBUTE51,
        CCLA.ATTRIBUTE52,
        CCLA.ATTRIBUTE53,
        CCLA.ATTRIBUTE54,
        CCLA.ATTRIBUTE55,
        CCLA.ATTRIBUTE56,
        CCLA.ATTRIBUTE57,
        CCLA.ATTRIBUTE58,
        CCLA.ATTRIBUTE59,
        CCLA.ATTRIBUTE60,
        CCLA.ATTRIBUTE61,
        CCLA.ATTRIBUTE62,
        CCLA.ATTRIBUTE63,
        CCLA.ATTRIBUTE64,
        CCLA.ATTRIBUTE65,
        CCLA.ATTRIBUTE66,
        CCLA.ATTRIBUTE67,
        CCLA.ATTRIBUTE68,
        CCLA.ATTRIBUTE69,
        CCLA.ATTRIBUTE70,
        CCLA.ATTRIBUTE71,
        CCLA.ATTRIBUTE72,
        CCLA.ATTRIBUTE73,
        CCLA.ATTRIBUTE74,
        CCLA.ATTRIBUTE75,
        CCLA.ATTRIBUTE76,
        CCLA.ATTRIBUTE77,
        CCLA.ATTRIBUTE78,
        CCLA.ATTRIBUTE79,
        CCLA.ATTRIBUTE80,
        CCLA.ATTRIBUTE81,
        CCLA.ATTRIBUTE82,
        CCLA.ATTRIBUTE83,
        CCLA.ATTRIBUTE84,
        CCLA.ATTRIBUTE85,
        CCLA.ATTRIBUTE86,
        CCLA.ATTRIBUTE87,
        CCLA.ATTRIBUTE88,
        CCLA.ATTRIBUTE89,
        CCLA.ATTRIBUTE90,
        CCLA.ATTRIBUTE91,
        CCLA.ATTRIBUTE92,
        CCLA.ATTRIBUTE93,
        CCLA.ATTRIBUTE94,
        CCLA.ATTRIBUTE95,
        CCLA.ATTRIBUTE96,
        CCLA.ATTRIBUTE97,
        CCLA.ATTRIBUTE98,
        CCLA.ATTRIBUTE99,
        CCLA.ATTRIBUTE100,
        cn_comm_lines_api_s.NEXTVAL,
        CCLA.CONC_BATCH_ID,
        CCLA.PROCESS_BATCH_ID,
        NULL,
        CCLA.ROLLUP_DATE,
        CCLA.SOURCE_DOC_ID,
        CCLA.SOURCE_DOC_TYPE,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        CCLA.TRANSACTION_CURRENCY_CODE,
        CCLA.EXCHANGE_RATE,
        CCLA.ACCTD_TRANSACTION_AMOUNT,
        CCLA.TRX_ID,
        CCLA.TRX_LINE_ID,
        CCLA.TRX_SALES_LINE_ID,
        CCLA.QUANTITY,
        CCLA.SOURCE_TRX_NUMBER,
        CCLA.DISCOUNT_PERCENTAGE,
        CCLA.MARGIN_PERCENTAGE,
        CCLA.SOURCE_TRX_ID,
        CCLA.SOURCE_TRX_LINE_ID,
        CCLA.SOURCE_TRX_SALES_LINE_ID,
        CCLA.NEGATED_FLAG,
        CCLA.CUSTOMER_ID,
        CCLA.INVENTORY_ITEM_ID,
        CCLA.ORDER_NUMBER,
        CCLA.BOOKED_DATE,
        CCLA.INVOICE_NUMBER,
        CCLA.INVOICE_DATE,
        SYSDATE,
        l_adjusted_by,
        CCLA.REVENUE_TYPE,
        CCLA.ADJUST_ROLLUP_FLAG,
        'Created by TAE',
        NVL(CCLA.ADJUST_STATUS,'NEW'),
        CCLA.LINE_NUMBER,
        CCLA.BILL_TO_ADDRESS_ID,
        CCLA.SHIP_TO_ADDRESS_ID,
        CCLA.BILL_TO_CONTACT_ID,
        CCLA.SHIP_TO_CONTACT_ID,
        CCLA.COMM_LINES_API_ID,
        CCLA.PRE_DEFINED_RC_FLAG,
        CCLA.ROLLUP_FLAG,
        CCLA.FORECAST_ID,
        CCLA.UPSIDE_QUANTITY,
        CCLA.UPSIDE_AMOUNT,
        CCLA.UOM_CODE,
        CCLA.REASON_CODE,
        CCLA.TYPE,
        CCLA.PRE_PROCESSED_CODE,
        CCLA.QUOTA_ID,
        CCLA.SRP_PLAN_ASSIGN_ID,
        --CR.ROLE_ID,
        --JR.ROLE_ID, -- Added for 4438001
        ILV.role_id,
        CCLA.COMP_GROUP_ID,
        CCLA.COMMISSION_AMOUNT,
        ILV.EMPLOYEE_NUMBER,
        CCLA.REVERSAL_FLAG,
        CCLA.REVERSAL_HEADER_ID,
        CCLA.SALES_CHANNEL,
        CCLA.OBJECT_VERSION_NUMBER,
        CCLA.SPLIT_PCT,
        CCLA.SPLIT_STATUS,
        ILV.ORG_ID
  FROM (
-- Starting of ILV
SELECT org_id,
       comm_lines_api_id,
       resource_id,
       role_id,
       salesrep_id,
       employee_number,
       split_trx_amout - LAG(split_trx_amout, 1, 0)
       OVER (PARTITION BY comm_lines_api_id ORDER BY rn) net_trx_amount
  FROM (
SELECT a.org_id,
       a.comm_lines_api_id,
       b.resource_id,
       JR.role_id,
       CS.salesrep_id,
       CS.employee_number,
       ROUND(a.transaction_amount *
             CUME_DIST() OVER (PARTITION BY a.comm_lines_api_id
	                       ORDER BY b.resource_id), 2) split_trx_amout,
       ROW_NUMBER() OVER (PARTITION BY a.comm_lines_api_id
                          ORDER BY b.resource_id) rn
  FROM cn_comm_lines_api a,
       JTF_TAE_1001_SC_WINNERS b,
       jtf_rs_roles_vl JR,
       cn_salesreps CS
 WHERE a.comm_lines_api_id = b.trans_object_id
   AND NVL(a.org_id, -777) = NVL(b.org_id, -777)
   AND b.org_id=CS.org_id
   AND JR.role_code           = b.role
   AND CS.resource_id 	= b.resource_id AND
   a.org_id=p_org_id) result) ILV,
-- End of the ILV
       cn_comm_lines_api CCLA
 WHERE ILV.comm_lines_api_id = CCLA.comm_lines_api_id and
 ILV.ORG_ID=CCLA.ORG_ID AND
 CCLA.ORG_ID=p_org_id;

 --dbms_output.put_line('After Insert Statement');
 --dbms_output.put_line('SQL%ROWCOUNT :'||SQL%ROWCOUNT);

    OPEN trx_records;
    FETCH trx_records
    BULK COLLECT INTO l_api_id, l_org_id, l_role, l_resource_id limit 1000;
    CLOSE trx_records;

    IF  l_api_id.count > 0 THEN

     FORALL j IN 1..l_api_id.COUNT

        UPDATE cn_comm_lines_api  api
        SET load_status 	    = 'OBSOLETE',
            adjust_status 	    = 'FROZEN',
            adjust_date   	    = sysdate,
            adjusted_by   	    = l_adjusted_by,
            adjust_comments 	    = 'Negated for TAE'
        WHERE comm_lines_api_id = l_api_id(j)
        AND   NVL(org_id, -777) = NVL(l_org_id(j), -777);

     END IF;

     --dbms_output.put_line('After the UPDATE statement ');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO process_trx_records;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO process_trx_records;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      ROLLBACK TO process_trx_records;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END Process_Trx_Records;

END CN_PROCESS_TAE_TRX_PUB;

/
