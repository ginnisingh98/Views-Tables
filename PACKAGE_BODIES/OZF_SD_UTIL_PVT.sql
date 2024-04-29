--------------------------------------------------------
--  DDL for Package Body OZF_SD_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_UTIL_PVT" as
/* $Header: ozfvsdub.pls 120.17.12010000.31 2010/06/04 08:49:44 annsrini ship $ */

-- Start of Comments
-- Package name     : OZF_SD_UTIL_PVT
-- Purpose          :
-- History          : 28-OCT-2009 - ANNSRINI - Fix for bug 9057734 - l_conv_adj_amount added in procedure create_adjustment
--                  : 07-DEC-2009 - ANNSRINI - changes w.r.t multicurrency
-- NOTE             :
-- End of Comments

G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'OZF_SD_UTIL_PVT';
G_FILE_NAME 	CONSTANT VARCHAR2(12) 	:= 'ozfvsdub.pls';


--l_debug_level NUMBER  := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

function SD_CONVERT_CURRENCY(p_batch_line_id number,p_amount number ) return number
is

l_from_currency VARCHAR2(15):=NULL;
l_to_currency VARCHAR2(15):=NULL;
l_conv_date DATE;
l_from_amount NUMBER;
x_to_amount NUMBER;
l_util_id NUMBER;
x_return_status VARCHAR2(200);
  begin

     select UTILIZATION_ID,CLAIM_AMOUNT_CURRENCY_CODE into l_util_id,l_from_currency from OZF_SD_BATCH_LINES_ALL where batch_line_id=p_batch_line_id;

    -- select currency_code into l_from_currency from  OZF_FUNDS_UTILIZED_ALL_B where utilization_id=l_util_id;

     select currency_code into l_to_currency from ozf_sd_batch_headers_all
            where batch_id=(select batch_id from ozf_sd_batch_lines_all
                                   where batch_line_id = p_batch_line_id);

   --  select exchange_rate_date into l_conv_date from OZF_FUNDS_UTILIZED_ALL_B where utilization_id=l_util_id;

OZF_UTILITY_PVT.Convert_Currency (
   x_return_status      ,
   l_from_currency       ,
   l_to_currency          ,
   sysdate          ,
   p_amount       ,
   x_to_amount
   );

    return x_to_amount;


  end;

-----------------------------------------------------------------------------------------------------------
    -- FUNCTION
    --  GET_CONVERTED_CURRENCY
    -- PURPOSE
    --  This API does currency conversion in 1 or 2 steps
        --      based on the difference in the plan,batch and functional currencies
        --
        -- PARAMETERS
        --      p_plan_currency
        --      p_batch_currency
        --      p_functional_curr
        --      p_exchange_rate_type - Exchange Rate Type
        --      p_date - Exchange Rate Date of Accrual
        --      p_amount - Amount to be converted
        --
    -- NOTES
        --      if (Plan Currency != Functional Currency AND Functional Currency == Batch Currency)
        --              Convert Claim_Amount (in plan currency) to Functional currency on Exchange Rate Date of Accrual
        --      else if (Plan Currency!= Functional Currency AND Functional Currency!= Batch Currency)
        --              1. Convert Claim Amount(in plan currency) to functional currency on Exchange Rate Date of Accrual
        --              2. Convert computed Function Amount to batch currency on sysdate or creation Date
        --      else if (Plan Currency == Functional Currency AND Functional Currency!=batch Currency)
        --              Convert  Claim Amount(in plan currency) to batch currency on sysdate
    --
--------------------------------------------------------------------------------------------------------------

function GET_CONVERTED_CURRENCY(p_plan_currency varchar2,p_batch_currency varchar2,p_functional_curr varchar2,p_exchange_rate_type varchar2,p_conv_rate number,p_date DATE,p_amount number) return number
is

x_to_amount_func NUMBER;
x_to_amount_batch NUMBER;
x_return_status VARCHAR2(200);
x_rate          NUMBER;

  begin

        IF((p_plan_currency <> p_functional_curr) AND (p_functional_curr=p_batch_currency)) THEN
                OZF_UTILITY_PVT.Convert_Currency (
                p_from_currency      => p_plan_currency,
                p_to_currency        => p_batch_currency,
		p_conv_type          => p_exchange_rate_type,
		p_conv_rate          => FND_API.G_MISS_NUM,
                p_conv_date          => p_date,
                p_from_amount        => p_amount,
                x_return_status      => x_return_status,
                x_to_amount          => x_to_amount_batch,
		x_rate               => x_rate
                );
        ELSIF((p_plan_currency <> p_functional_curr) AND (p_functional_curr <> p_batch_currency)) THEN

                OZF_UTILITY_PVT.Convert_Currency (
                p_from_currency      => p_plan_currency,
                p_to_currency        => p_functional_curr,
		p_conv_type          => p_exchange_rate_type,
		p_conv_rate          => FND_API.G_MISS_NUM,
                p_conv_date          => p_date,
                p_from_amount        => p_amount,
                x_return_status      => x_return_status,
                x_to_amount          => x_to_amount_func,
		x_rate               => x_rate
                );

                OZF_UTILITY_PVT.Convert_Currency (
                p_from_currency      => p_functional_curr,
                p_to_currency        => p_batch_currency,
		p_conv_type          => p_exchange_rate_type,
		p_conv_rate          => FND_API.G_MISS_NUM,
                p_conv_date          => SYSDATE,
                p_from_amount        => x_to_amount_func,
                x_return_status      => x_return_status,
                x_to_amount          => x_to_amount_batch,
		x_rate               => x_rate
                );

        ELSIF((p_plan_currency = p_functional_curr) AND (p_functional_curr <> p_batch_currency)) THEN

                OZF_UTILITY_PVT.Convert_Currency (
                p_from_currency      => p_plan_currency,
                p_to_currency        => p_batch_currency,
		p_conv_type          => p_exchange_rate_type,
		p_conv_rate          => FND_API.G_MISS_NUM,
                p_conv_date          => SYSDATE,
                p_from_amount        => p_amount,
                x_return_status      => x_return_status,
                x_to_amount          => x_to_amount_batch,
		x_rate               => x_rate
                );

        END IF;
  return x_to_amount_batch;
end;


procedure SD_AMOUNT_POSTBACK(p_batch_line_id number, x_return_status OUT NOCOPY   VARCHAR2,
   x_meaning       OUT NOCOPY   VARCHAR2)
  is
	l_claim_amount number;
	l_acctd_amount_remaining number;
	l_univ_curr_amount_remaining number;
	l_fund_req_amount_remaining number;
	l_util_id number;
	l_amount_remaining number;

  begin

 select UTILIZATION_ID ,claim_amount,acctd_amount_remaining,univ_curr_amount_remaining,fund_request_amount_remaining,amount_remaining
 into  l_util_id, l_claim_amount ,l_acctd_amount_remaining,l_univ_curr_amount_remaining,l_fund_req_amount_remaining,l_amount_remaining
 from OZF_SD_BATCH_LINES_ALL
 where batch_line_id=p_batch_line_id;



	UPDATE OZF_FUNDS_UTILIZED_ALL_B
	SET amount_remaining=amount_remaining+l_amount_remaining,
        PLAN_CURR_AMOUNT_REMAINING=PLAN_CURR_AMOUNT_REMAINING+l_claim_amount,
	acctd_amount_remaining=acctd_amount_remaining+l_acctd_amount_remaining,
	univ_curr_amount_remaining=univ_curr_amount_remaining+l_amount_remaining,
        fund_request_amount_remaining=fund_request_amount_remaining+l_fund_req_amount_remaining

	WHERE UTILIZATION_ID=l_util_id;

        DELETE FROM OZF_SD_BATCH_LINES_ALL WHERE batch_line_id=p_batch_line_id;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_meaning :=  NULL;


EXCEPTION

--error code will be returned to java layer where commit or rollback can happen
WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_meaning :=  NULL;
RETURN;

  end;

  PROCEDURE CONVERT_TO_RN_DATE(
     p_server_date              IN DATE,
     x_rn_date                  OUT NOCOPY VARCHAR2)
  IS
     l_utc_date                 DATE;
     l_milliseconds             VARCHAR2(5);
     l_server_timezone          VARCHAR2(50);
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN

     IF(p_server_date is null) THEN
        x_rn_date := null;
          RETURN;
     END IF;
      x_rn_date :=  TO_CHAR(p_server_date,'YYYYMMDD')||'Z';


  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;

  END CONVERT_TO_RN_DATE;

  PROCEDURE CONVERT_TO_DB_DATE(
     p_rn_date                  IN VARCHAR2,
     x_db_date                  OUT NOCOPY DATE)
  IS
     l_server_date              DATE;
     l_utc_datetime             DATE;
     l_count_t_appearanace      NUMBER;
     l_error_code               NUMBER;
     l_rn_frmt_date             VARCHAR2(30);
     l_rn_timezone              VARCHAR2(30);
     l_db_timezone              VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN


        IF(p_rn_date is null) THEN
           x_db_date := null;

           RETURN;
        END IF;
       l_count_t_appearanace := instr(p_rn_date,'T');
       IF (l_count_t_appearanace > 0) THEN
           --Datetime Format: YYYYMMDDThhmmss.SSSZ
           l_rn_timezone := fnd_profile.value('CLN_RN_TIMEZONE');

           -- get the timezone of the db server
           l_db_timezone := FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE;


           l_rn_frmt_date     :=    substr(p_rn_date,1,8)||substr(p_rn_date,10,6);

           l_utc_datetime := TO_DATE(l_rn_frmt_date,'YYYYMMDDHH24MISS');

           -- this function converts the datetime from the user entered/db timezone to UTC
           x_db_date    := FND_TIMEZONES_PVT.adjust_datetime(l_utc_datetime,l_rn_timezone,l_db_timezone);

       ELSE
           --Date Format    : YYYYMMDDZ

           l_rn_frmt_date       :=      substr(p_rn_date,1,8);

           x_db_date := TO_DATE(l_rn_frmt_date,'YYYYMMDD');

       END IF;

  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;

  END CONVERT_TO_DB_DATE;



---------------------------------------------------------------------
    -- PROCEDURE
    --    UPDATE_SD_REQ_PRICES
    --
    -- PURPOSE
    --    Updates the Ship and Debit price interface table with correct request line iD
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number for transaction
    --		b) p_request_line_id : Correct request line Id
    --
    -- NOTES
    --
---------------------------------------------------------------------------

  PROCEDURE UPDATE_SD_REQ_PRICES(p_request_number IN VARCHAR2,p_request_line_id IN NUMBER)
   IS
      l_req_header_id    NUMBER ;
      l_req_line_id    NUMBER ;

    BEGIN

    UPDATE OZF_SD_RES_DIST_PRICES_INTF SET REQUEST_LINE_ID=p_request_line_id
    WHERE REQUEST_NUMBER=p_request_number
    AND REQUEST_LINE_ID IS NULL;

    COMMIT;

   END UPDATE_SD_REQ_PRICES;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    PROCESS_SD_RESPONSE
    --
    -- PURPOSE
    --    Updates the Ship and Debit header and base tables for the inbound data
    --    only when the business validation(s) are passed
    --    The business validation involved are
    --		a)
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number
    --		b) x_return_status : Return status for the processing
    --          c) x_msg_data : Error message if the validation errored out
    -- NOTES
    --
    ----------------------------------------------------------------------

PROCEDURE PROCESS_SD_RESPONSE(p_request_number IN VARCHAR2
            ,   x_return_status OUT nocopy VARCHAR2
            ,   x_msg_data OUT nocopy VARCHAR2    )
    IS

    l_return_status VARCHAR2(30);
    l_msg_data              VARCHAR2(2000):='Data submitted is not valid  :';
    l_req_id    NUMBER :=0 ;
    l_req_number_count NUMBER ;
    l_req_status AMS_USER_STATUSES_B.SYSTEM_STATUS_CODE%TYPE;
    l_request_status OZF_SD_REQUEST_HEADERS_ALL_B.USER_STATUS_ID%TYPE;
    l_curr_prod_context OZF_SD_REQUEST_LINES_ALL.PRODUCT_CONTEXT%TYPE ;
    l_curr_code OZF_SD_REQUEST_HEADERS_ALL_B.REQUEST_CURRENCY_CODE%TYPE;
    l_approved_lines NUMBER :=0;
    l_error_count NUMBER := 0 ;
    l_currency_count NUMBER :=0 ;
    l_line_status VARCHAR2(1) :='S' ;
    l_authorization_number OZF_SD_RES_HEADER_INTF.AUTH_NUMBER%TYPE ;
    l_error_message FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE ;

    CURSOR FETCH_PROD_INTF_REC IS
      SELECT	PRODINTF.REQUEST_LINE_ID INF_REQUEST_LINE_ID,
		PRODINTF.PROD_TYPE INF_PROD_TYPE,
		PRODINTF.PROD_REJECTION_CODE INF_REJ_CODE,
		PRODLINES.PRODUCT_CONTEXT LINE_PROD_CONTEXT,
		PROD.CONCATENATED_SEGMENTS LINE_PROD_CODE,
		PRODINTF.SUPP_PROD_CODE INF_PROD_CODE,
		PRODINTF.APPROVED_DISCOUNT_TYPE INTF_DISCOUNT_TYE,
		PRODLINES.REQUESTED_DISCOUNT_TYPE LINE_DISCOUNT_TYPE,
		PRODLINES.REQUESTED_DISCOUNT_CURRENCY LINE_DISCOUNT_CUR,
		PRODINTF.APPROVED_DISCOUNT_CURR INTF_CURR_CODE,
		NVL(PRODINTF.APPROVED_DISCOUNT_VALUE,PRODLINES.REQUESTED_DISCOUNT_VALUE) INTF_APPROVED_DISCOUNT_VALUE,
		NVL(PRODINTF.PROD_AUTHORIZED_QUANTITY,PRODLINES.MAX_QTY) INTF_APPROVED_QUANTITY
    FROM OZF_SD_RES_PROD_INTF PRODINTF,
	OZF_SD_REQUEST_LINES_ALL PRODLINES,
	mtl_system_items_b_kfv PROD
    where  NVL(PRODINTF.PROCESSED_FLAG,'N') <>'Y' and
    PRODINTF.REQUEST_NUMBER=p_request_number
    AND PRODLINES.REQUEST_HEADER_ID=request_header_id
    AND PRODINTF.REQUEST_LINE_ID = PRODLINES.REQUEST_LINE_ID
    AND PRODLINES.PRODUCT_CONTEXT = 'PRODUCT'
    AND PRODLINES.ORG_ID=PROD.ORGANIZATION_ID
    AND PRODLINES.INVENTORY_ITEM_ID=PROD.INVENTORY_ITEM_ID

    UNION
    SELECT	PRODINTF.REQUEST_LINE_ID INF_REQUEST_LINE_ID,
		PRODINTF.PROD_TYPE INF_PROD_TYPE,
		PRODINTF.PROD_REJECTION_CODE INF_REJ_CODE,
		PRODLINES.PRODUCT_CONTEXT LINE_PROD_CONTEXT,
		NVL(D.CATEGORY_DESC, 'NA') PROD_CODE,
		PRODINTF.SUPP_PROD_CODE INF_PROD_CODE,
		PRODINTF.APPROVED_DISCOUNT_TYPE INTF_DISCOUNT_TYE,
		PRODLINES.REQUESTED_DISCOUNT_TYPE LINE_DISCOUNT_TYPE,
		PRODLINES.REQUESTED_DISCOUNT_CURRENCY LINE_DISCOUNT_CUR,
		PRODINTF.APPROVED_DISCOUNT_CURR INTF_CURR_CODE,
		NVL(PRODINTF.APPROVED_DISCOUNT_VALUE,PRODLINES.REQUESTED_DISCOUNT_VALUE) INTF_APPROVED_DISCOUNT_VALUE,
		NVL(PRODINTF.PROD_AUTHORIZED_QUANTITY,PRODLINES.MAX_QTY) INTF_APPROVED_QUANTITY
    FROM OZF_SD_RES_PROD_INTF PRODINTF,
	OZF_SD_REQUEST_LINES_ALL PRODLINES,
	ENI_PROD_DEN_HRCHY_PARENTS_V D
    WHERE  NVL(PRODINTF.PROCESSED_FLAG,'N') <>'Y' and
    PRODINTF.REQUEST_NUMBER=p_request_number
    AND PRODLINES.REQUEST_HEADER_ID=request_header_id
    AND PRODINTF.REQUEST_LINE_ID = PRODLINES.REQUEST_LINE_ID
    AND PRODLINES.PRODUCT_CONTEXT ='PRODUCT_CATEGORY'
    AND PRODLINES.PROD_CATG_ID=D.CATEGORY_ID
    AND PRODLINES.PRODUCT_CAT_SET_ID = D.CATEGORY_SET_ID ;

    BEGIN

	x_msg_data := '';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;
	l_error_message := FND_MESSAGE.GET_STRING('OZF','OZF_SD_FEED_DATA_ERROR') ;

	-- Validate the SDR Request Number
	Select count(*) into l_req_number_count from OZF_SD_REQUEST_HEADERS_ALL_B
	where REQUEST_NUMBER = p_request_number ;
	IF l_req_number_count = 0 THEN

           l_msg_data := l_msg_data ||','|| 'The request number '||p_request_number ||' is not valid.' ;
	   x_msg_data := 'No Ship and Debit Request exists for : '||p_request_number;
	   x_return_status := FND_API.G_RET_STS_ERROR ;

		-- DO THE MASS UPDATE FOR THE INTERFACE TABLES
		UPDATE OZF_SD_RES_HEADER_INTF SET PROCESSED_FLAG='Y',ERROR_TXT=x_msg_data WHERE REQUEST_NUMBER=p_request_number and PROCESSED_FLAG in('N',null) ;

		UPDATE OZF_SD_RES_CUST_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and PROCESSED_FLAG in('N',null) ;

		UPDATE OZF_SD_RES_PROD_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and PROCESSED_FLAG in('N',null) ;

		UPDATE OZF_SD_RES_DIST_PRICES_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and PROCESSED_FLAG in('N',null) ;

		COMMIT ;
		return ;

	END IF ;


	Select REQ.request_header_id,STATUS.SYSTEM_STATUS_CODE,REQ.request_currency_code into l_req_id,l_req_status,l_curr_code
	from OZF_SD_REQUEST_HEADERS_ALL_B REQ,AMS_USER_STATUSES_VL STATUS
	where  REQ.REQUEST_NUMBER = p_request_number
        AND REQ.USER_STATUS_ID=STATUS.USER_STATUS_ID ;


	-- If the request status is "PENDING_SUPPLIER_APPROVAL" then process the product lines in loop
	   IF l_req_status='PENDING_SUPPLIER_APPROVAL' THEN

	      -- Update the non responded lines as 'rejected' and rejection code as ' No response from vendor'
	      UPDATE OZF_SD_REQUEST_LINES_ALL SET VENDOR_APPROVED_FLAG='N',REJECTION_CODE='OZF_SD_NO_RESPONSE'
	      WHERE REQUEST_HEADER_ID=request_header_id
	      AND REQUEST_LINE_ID IN (	SELECT REQUEST_LINE_ID FROM OZF_SD_REQUEST_LINES_ALL
					WHERE REQUEST_HEADER_ID=request_header_id
					MINUS
					SELECT REQUEST_LINE_ID FROM OZF_SD_RES_PROD_INTF
					WHERE REQUEST_NUMBER=p_request_number
					AND NVL(PROCESSED_FLAG,'N') <>'Y') ;


	      FOR PROD_REC IN FETCH_PROD_INTF_REC
	      LOOP
                     	l_msg_data := '';
			-- Set the line status as valid
			l_line_status := 'S' ;

			-- Validate the product type
			IF PROD_REC.INF_PROD_TYPE IS NOT NULL AND
			   PROD_REC.LINE_PROD_CONTEXT <> UPPER(PROD_REC.INF_PROD_TYPE) THEN


			   l_msg_data := l_msg_data ||','|| 'Product context mismatch' ;

			   UPDATE OZF_SD_RES_PROD_INTF SET ERROR_TXT = l_msg_data
				WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID
				AND NVL(PROCESSED_FLAG,'N') <>'Y';

			   l_error_count := l_error_count +1 ;
			   x_msg_data := l_error_message;
			   x_return_status := FND_API.G_RET_STS_ERROR ;
			   l_line_status := 'E' ;
			END IF;

			-- Validate the product code
			IF PROD_REC.LINE_PROD_CONTEXT<>'PRODUCT_CATEGORY' AND
			   PROD_REC.LINE_PROD_CODE<>PROD_REC.INF_PROD_CODE  THEN


			   l_msg_data := l_msg_data ||','|| 'Product code mismatch' ;

			   UPDATE OZF_SD_RES_PROD_INTF SET ERROR_TXT = l_msg_data
			      WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID
			      AND NVL(PROCESSED_FLAG,'N') <>'Y' ;

			      l_error_count := l_error_count +1 ;
			      x_msg_data := l_error_message;
			      x_return_status := FND_API.G_RET_STS_ERROR ;
			      l_line_status := 'E' ;
			END IF;

			   -- Validate the discount type
			IF PROD_REC.INTF_DISCOUNT_TYE IS NOT NULL AND
			   PROD_REC.INTF_DISCOUNT_TYE <> PROD_REC.LINE_DISCOUNT_TYPE THEN


			   l_msg_data := l_msg_data ||','|| 'Discount type mismatch' ;

			   UPDATE OZF_SD_RES_PROD_INTF SET ERROR_TXT = 'Discount type mismatch'
				  WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID
				  AND NVL(PROCESSED_FLAG,'N') <>'Y' ;

    			  l_error_count := l_error_count +1 ;
			  x_msg_data := l_error_message;
			  x_return_status := FND_API.G_RET_STS_ERROR ;
			  l_line_status := 'E' ;
		      END IF;

			-- Validate the currency if not null

			l_curr_code := PROD_REC.INTF_CURR_CODE ;
			IF PROD_REC.INTF_CURR_CODE IS NULL OR trim(PROD_REC.INTF_CURR_CODE)='' THEN
				l_curr_code := PROD_REC.LINE_DISCOUNT_CUR ;
			END IF ;


			IF PROD_REC.LINE_DISCOUNT_TYPE <>'%' THEN


			    SELECT count(*) INTO l_currency_count
			    FROM FND_CURRENCIES
			    WHERE currency_code = l_curr_code;
			    IF l_currency_count=0 THEN


			   l_msg_data := l_msg_data ||','|| 'Currency code mismatch' ;

				UPDATE OZF_SD_RES_PROD_INTF SET ERROR_TXT = 'Currency code mismatch'
        			        WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID
					AND NVL(PROCESSED_FLAG,'N') <>'Y' ;

				l_error_count := l_error_count +1 ;
			        x_msg_data := l_error_message;
			        x_return_status := FND_API.G_RET_STS_ERROR ;
				l_line_status := 'E' ;
			   END IF;
			END IF ;

			-- Check the validation status of line : If an valid line then update the base table data
			IF l_line_status <> 'E'	THEN
				-- Update the status for product line as 'Rejected'
				IF PROD_REC.INF_REJ_CODE IS NOT NULL THEN
					 UPDATE OZF_SD_REQUEST_LINES_ALL SET REJECTION_CODE=PROD_REC.INF_REJ_CODE,VENDOR_APPROVED_FLAG='N'
					 WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID;

				END IF;
					-- Update the approved amount,approved currency and type in the base line table
					UPDATE OZF_SD_REQUEST_LINES_ALL SET APPROVED_DISCOUNT_TYPE=PROD_REC.LINE_DISCOUNT_TYPE,
									    APPROVED_DISCOUNT_VALUE=PROD_REC.INTF_APPROVED_DISCOUNT_VALUE,
									    APPROVED_MAX_QTY=PROD_REC.INTF_APPROVED_QUANTITY,
									    APPROVED_DISCOUNT_CURRENCY=l_curr_code
					 WHERE REQUEST_LINE_ID=PROD_REC.INF_REQUEST_LINE_ID;


			END IF;
	      END LOOP;


		-- UPDATE THE REQUEST STATUS IN HEADER TABLE : OZF_SD_REQUEST_HEADERS_ALL_B
		SELECT COUNT(*) INTO l_approved_lines FROM OZF_SD_REQUEST_LINES_ALL
		WHERE REQUEST_HEADER_ID=l_req_id
		AND VENDOR_APPROVED_FLAG = 'Y' ;


		IF l_approved_lines > 0 THEN
			SELECT user_status_id INTO l_request_status FROM ams_user_statuses_vl
					where system_status_TYPE='OZF_SD_REQUEST_STATUS'
						and SYSTEM_STATUS_CODE='SUPPLIER_APPROVED'
						and default_flag='Y'
						and enabled_flag='Y' ;
		ELSE
			SELECT user_status_id INTO l_request_status FROM ams_user_statuses_vl
					where system_status_TYPE='OZF_SD_REQUEST_STATUS'
						and SYSTEM_STATUS_CODE='SUPPLIER_REJECTED'
						and default_flag='Y'
						and enabled_flag='Y' ;
		END IF ;

		SELECT AUTH_NUMBER INTO l_authorization_number FROM OZF_SD_RES_HEADER_INTF WHERE request_number=p_request_number
		AND NVL(PROCESSED_FLAG,'N') <>'Y' ;

		UPDATE OZF_SD_REQUEST_HEADERS_ALL_B SET user_status_id= l_request_status,AUTHORIZATION_NUMBER=l_authorization_number
		WHERE REQUEST_HEADER_ID=l_req_id ;


	ELSE
		l_msg_data := l_msg_data ||','|| 'The ststus is not pending suppler approval' ;
		x_msg_data := 'Currently the request is not pending for supplier approval';
	        x_return_status := FND_API.G_RET_STS_ERROR;

		UPDATE OZF_SD_RES_HEADER_INTF SET ERROR_TXT=x_msg_data WHERE REQUEST_NUMBER=p_request_number
		and NVL(PROCESSED_FLAG,'N') <>'Y';


	END IF ;


	-- DO THE MASS UPDATE FOR THE INTERFACE TABLES

	UPDATE OZF_SD_RES_HEADER_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_CUST_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_PROD_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_DIST_PRICES_INTF SET PROCESSED_FLAG='Y' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	COMMIT ;
  EXCEPTION

    WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- DO THE MASS UPDATE FOR THE INTERFACE TABLES
	UPDATE OZF_SD_RES_HEADER_INTF SET PROCESSED_FLAG='Y',ERROR_TXT='Error' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_CUST_INTF SET PROCESSED_FLAG='Y',ERROR_TXT='Error' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_PROD_INTF SET PROCESSED_FLAG='Y',ERROR_TXT='Error' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';
	UPDATE OZF_SD_RES_DIST_PRICES_INTF SET PROCESSED_FLAG='Y',ERROR_TXT='Error' WHERE REQUEST_NUMBER=p_request_number and NVL(PROCESSED_FLAG,'N') <>'Y';

	COMMIT ;
        RETURN;

END PROCESS_SD_RESPONSE;


PROCEDURE CONVERT_TO_RN_DATETIME(
     p_server_date              IN DATE,
     x_rn_datetime              OUT NOCOPY VARCHAR2)
  IS
     l_error_code               NUMBER;
     l_utc_date                 DATE;
     l_milliseconds             VARCHAR2(5);
     l_server_timezone          VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN

     IF(p_server_date is null) THEN
        x_rn_datetime := null;

        RETURN;
     END IF;

     CONVERT_TO_RN_TIMEZONE(
        p_input_date          =>  p_server_date,
        x_utc_date            =>  l_utc_date );

     l_milliseconds := '000'; --We wont get milliseconds

     x_rn_datetime := TO_CHAR(l_utc_date,'YYYYMMDD')||'T'||TO_CHAR(l_utc_date,'hh24miss')||'.'||l_milliseconds||'Z';


  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;

  END CONVERT_TO_RN_DATETIME;



  PROCEDURE CONVERT_TO_RN_TIMEZONE(
     p_input_date               IN DATE,
     x_utc_date                 OUT NOCOPY DATE )
  IS
     l_error_code               NUMBER;
     l_db_timezone              VARCHAR2(30);
     l_rn_timezone              VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN

     -- get the timezone of the db server
     l_db_timezone := FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE;

     l_rn_timezone := fnd_profile.value('CLN_RN_TIMEZONE');


     -- this function converts the datetime from the user entered/db timezone to UTC
     x_utc_date         := FND_TIMEZONES_PVT.adjust_datetime(p_input_date,l_db_timezone,l_rn_timezone);


  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;

  END CONVERT_TO_RN_TIMEZONE;

---------------------------------------------------------------------
    -- PROCEDURE
    --    UPDATE_SD_REQ_STALE_DATA
    --
    -- PURPOSE
    --    Updates the Ship and Debit interface tables for any stale data
    --
    -- PARAMETERS
    --		a) p_request_number  : The SD Request Number
    -- NOTES
    --
----------------------------------------------------------------------

PROCEDURE UPDATE_SD_REQ_STALE_DATA(p_request_number IN VARCHAR2)
 IS
  l_req_number_count NUMBER :=0;
 BEGIN

	UPDATE OZF_SD_RES_HEADER_INTF SET PROCESSED_FLAG='S' WHERE REQUEST_NUMBER=p_request_number AND PROCESSED_FLAG='N' ;
	UPDATE OZF_SD_RES_CUST_INTF SET PROCESSED_FLAG='S' WHERE REQUEST_NUMBER=p_request_number AND PROCESSED_FLAG='N' ;
	UPDATE OZF_SD_RES_PROD_INTF SET PROCESSED_FLAG='S' WHERE REQUEST_NUMBER=p_request_number AND PROCESSED_FLAG='N' ;
	UPDATE OZF_SD_RES_DIST_PRICES_INTF SET PROCESSED_FLAG='S' WHERE REQUEST_NUMBER=p_request_number AND PROCESSED_FLAG='N' ;
	COMMIT ;

 END UPDATE_SD_REQ_STALE_DATA;

---------------------------------------------------------------------
    -- PROCEDURE
    --    SD_RAISE_EVENT
    --
    -- PURPOSE
    --    This procedure raises a Business Event based on batch action.
    --
    -- PARAMETERS
    --		a) Batch ID
    --          b) Batch Action - can be EXPORT,CREATE, RESPONSE and CLAIM.
    -- NOTES
    --
----------------------------------------------------------------------


  PROCEDURE SD_RAISE_EVENT(P_BATCH_ID IN NUMBER,
                           P_BATCH_ACTION IN VARCHAR2,
			   x_return_status OUT NOCOPY   VARCHAR2)  IS

    p_event_name VARCHAR2(100) := 'oracle.apps.ozf.sd.batch.lifecycle';
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
    evtkey VARCHAR2(100);


  BEGIN
      evtkey := 'SDB' || P_BATCH_ID || dbms_utility.get_time();
      wf_event.addparametertolist(p_name => 'BATCH_ID',   p_value => P_BATCH_ID,   p_parameterlist => l_parameter_list);
      wf_event.addparametertolist(p_name => 'ACTION_NAME',   p_value => P_BATCH_ACTION,   p_parameterlist => l_parameter_list);
      wf_event.RAISE(p_event_name,   evtkey,   NULL,   l_parameter_list,   sysdate);

  EXCEPTION

    WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;

END SD_RAISE_EVENT;


---------------------------------------------------------------------
    -- PROCEDURE
    --    PROCESS_BATCH_ADJUST_CLAIM
    --
    -- PURPOSE
    --    This procedure is to process the submitted batch for claim and adjustment
    --     This will be called from the batch UI in Close and Export
    --
    -- PARAMETERS
    --		a) p_batch_header_id - Batch header Id
    --
    -- NOTES
    --
----------------------------------------------------------------------
 PROCEDURE PROCESS_BATCH_ADJUST_CLAIM(  p_batch_header_id NUMBER,
			    p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full,
			    p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
			    x_return_status    OUT NOCOPY      VARCHAR2,
			    x_msg_count        OUT NOCOPY      NUMBER,
			    x_msg_data         OUT NOCOPY      VARCHAR2) IS

  l_procedure_name VARCHAR2(30) := 'PROCESS_BATCH_ADJUST_CLAIM' ;
  l_unapproved_line_count NUMBER ;
  l_approved_line_count   NUMBER;
  l_total_line_count   NUMBER;
  l_full_write_off VARCHAR2(1) := fnd_api.g_false ;
  l_status_code  VARCHAR2(30) ;
  l_claim_id number ;
  l_orig_app_line_count NUMBER ;
  l_orig_total_line_count NUMBER ;
  l_create_claim VARCHAR2(1) := fnd_api.g_false ;

  l_total_app_claim_amt NUMBER ;
  l_tot_non_rma_lines NUMBER ;




  BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submitted batch is '||p_batch_header_id);

        SAVEPOINT process_batch_adjust_claim_sv;


	-- Check if the sum is negative

	  select sum(approved_unit_claim_amount) INTO l_total_app_claim_amt from (
		select
		  CASE
			WHEN((approved_amount is null and QUANTITY_APPROVED is null) OR ( approved_currency_code <> CLAIM_AMOUNT_CURRENCY_CODE ) OR approved_amount < 0 OR QUANTITY_APPROVED < 0) then null
			WHEN (approved_amount is null and QUANTITY_APPROVED IS NOT NULL AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN ((list_price-agreement_price) )
			WHEN (approved_amount is null and QUANTITY_APPROVED IS NOT NULL AND DISCOUNT_TYPE IN ('AMT')) THEN discount_value
			WHEN (QUANTITY_APPROVED is null and approved_amount is not null AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN  ((list_price - approved_amount) )
			WHEN (QUANTITY_APPROVED is null and approved_amount is not null AND DISCOUNT_TYPE IN ('AMT')) THEN  approved_amount
			WHEN (QUANTITY_APPROVED is not null and quantity_approved <> 0 and approved_amount is not null and approved_amount <> 0 AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN  ((list_price - approved_amount) )
			WHEN (QUANTITY_APPROVED is not null and quantity_approved <> 0 and approved_amount is not null and approved_amount <> 0  AND DISCOUNT_TYPE IN ('AMT')) THEN  (approved_amount)
	           END  approved_unit_claim_amount

		  from OZF_SD_BATCH_LINES_ALL line
		  WHERE line.complete_flag ='Y'
		  AND   line.batch_id = p_batch_header_id
		  AND   line.purge_flag <>'Y'
		  AND  line.ORIGINAL_CLAIM_AMOUNT >0
		  AND  (line.ORIGINAL_CLAIM_AMOUNT-line.CLAIM_AMOUNT)<>0
		  AND  line.status_code NOT IN ('APPROVED','COMPLETED') ) ;





	SELECT app_lines.app_count,
	      all_lines.total_count
	    INTO l_orig_app_line_count, l_orig_total_line_count
	    FROM
		(SELECT COUNT(1) total_count
		   FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id = p_batch_header_id
		) all_lines,
		(SELECT COUNT(1) app_count
		  FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id  = p_batch_header_id
		  AND status_code = 'APPROVED'
		) app_lines ;


	IF (l_total_app_claim_amt>0) THEN

		UPDATE OZF_SD_BATCH_LINES_ALL
		SET status_code    ='APPROVED'
		WHERE batch_id     = p_batch_header_id
		AND batch_line_id IN
		  (
			  select line.batch_line_id
			  from OZF_SD_BATCH_LINES_ALL line
			  WHERE line.complete_flag ='Y'
			  AND   line.batch_id = p_batch_header_id
			  AND   line.purge_flag <>'Y'
			  AND  line.ORIGINAL_CLAIM_AMOUNT >0
			  AND  (line.ORIGINAL_CLAIM_AMOUNT-line.CLAIM_AMOUNT)<>0
			  AND  line.status_code NOT IN ('APPROVED','COMPLETED')

			  minus

			  select batch_line_id
			  from ozf_sd_batch_line_disputes
			  where dispute_code in('OZF_SD_CURR_CODE_MISMATCH', 'OZF_SD_VENDOR_AUTH_AMT_NGTVE' ,'OZF_SD_VENDOR_AUTH_QTY_NGTVE','OZF_SD_AUTH_AMT_QTY_NULL','OZF_SD_NO_RESPONSE')
			  and batch_id        = p_batch_header_id
			  group by batch_line_id,dispute_code
			  having count(dispute_code)>0
		  ) ;

	  END IF ;

	  select status_code into l_status_code
	  from OZF_SD_BATCH_headers_all
	  where BATCH_ID=p_batch_header_id ;




	    SELECT (all_lines.total_count - app_lines.app_count),
	    app_lines.app_count,
	    all_lines.total_count
	    INTO l_unapproved_line_count, l_approved_line_count, l_total_line_count
	    FROM
		(SELECT COUNT(1) total_count
		   FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id = p_batch_header_id
		) all_lines,
		(SELECT COUNT(1) app_count
		  FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id  = p_batch_header_id
		  AND status_code = 'APPROVED'
		) app_lines ;



              -- Check if all lines are approved and batch header is not APPROVED.
	IF(l_approved_line_count = l_total_line_count) THEN

           l_full_write_off := fnd_api.g_true;

           FND_FILE.PUT_LINE(FND_FILE.LOG, '- All the lines are approved');


	       -- Only for WIP batch create claim
               IF (l_orig_app_line_count <> l_orig_total_line_count) THEN

		    l_full_write_off := fnd_api.g_FALSE ;
		    l_create_claim := fnd_api.g_true;

		    FND_FILE.PUT_LINE(FND_FILE.LOG, '- All the lines are approved and processing the claim');

                    OZF_SD_BATCH_FEED_PVT.process_claim(p_batch_header_id,
		                                        x_return_status,
							x_msg_data,l_claim_id);

		    FND_FILE.PUT_LINE(FND_FILE.LOG, ' - Status of claim API call '||x_return_status);

		    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      ROLLBACK TO SAVEPOINT process_batch_adjust_claim_sv;

			 FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);

                      RETURN ;
                    END IF ;

		    FND_FILE.PUT_LINE(FND_FILE.LOG, ' -Claim created successfully ');

		end if ;

		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claiing the create Adjustment API ');

                create_adjustment(p_batch_header_id =>p_batch_header_id,
		p_comp_wrt_off=> l_full_write_off,
		x_return_status=> x_return_status,
		x_msg_count=> x_msg_count,
		x_msg_data=> x_msg_data);


		FND_FILE.PUT_LINE(FND_FILE.LOG, ' Status of Adjustment API call '||x_return_status);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS AND l_full_write_off = fnd_api.g_FALSE  THEN

			ROLLBACK TO SAVEPOINT process_batch_adjust_claim_sv;

			FOR I IN 1..x_msg_count LOOP

			  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
			    '  Msg from Claim API while invoking claim for batch '
			   ||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );

			END LOOP;

			RETURN;
		END IF;

		IF (l_create_claim=fnd_api.g_true) THEN

		   sd_raise_event (p_batch_header_id, 'CLAIM', x_return_status);

		   FND_FILE.PUT_LINE(FND_FILE.LOG, ' -Raised life cycle business event ');


		END IF ;


		FND_FILE.PUT_LINE(FND_FILE.LOG, ' Adjustment completed');



        else


	      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Few or all lines are not ');

              if (l_approved_line_count > 0)  THEN

       		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Few lines are approved - Calling create child batch');


                  OZF_SD_BATCH_FEED_PVT.PROCESS_CHILD_BATCH(p_batch_header_id,x_return_status,x_msg_data) ;

		  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Process child batch returned status '||x_return_status);
               End if;

                  -- The unapproved lines, with complete flag true, the complete write off would happen
                  l_full_write_off :=  fnd_api.g_true ;

 		  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Adjusting the lines of the current batch');


		  create_adjustment(p_batch_header_id =>p_batch_header_id,
		p_comp_wrt_off=> l_full_write_off,
		x_return_status=> x_return_status,
		x_msg_count=> x_msg_count,
		x_msg_data=> x_msg_data);


		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Adjusted the batch '||x_return_status);

        end if ;


	-- Update the Batch as closed based on the all lines status

	SELECT (all_lines.total_count - (app_lines.app_count + com_lines.com_count + rma_lines.rma_count))
	    INTO l_unapproved_line_count
	    FROM
		(SELECT COUNT(1) total_count
		   FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id = p_batch_header_id
		) all_lines,
		(SELECT COUNT(1) app_count
		  FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id  = p_batch_header_id
		  AND status_code = 'APPROVED'
		) app_lines,
		(SELECT COUNT(1) com_count
		  FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id  = p_batch_header_id
		  AND status_code = 'COMPLETED'
		) com_lines,
		(SELECT COUNT(1) rma_count
		  FROM OZF_SD_BATCH_LINES_ALL
		  WHERE batch_id  = p_batch_header_id
		  AND ORIGINAL_CLAIM_AMOUNT < 0
		) rma_lines ;

	 IF (l_unapproved_line_count = 0 ) THEN

      	      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Changing status to Closed');


		UPDATE ozf_sd_batch_headers_all
		SET status_code = 'CLOSED'
		WHERE BATCH_ID = p_batch_header_id ;

	 END IF ;

        COMMIT;

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

  EXCEPTION

    WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_ERROR;

	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected exception is :' || sqlerrm);

        ROLLBACK TO SAVEPOINT process_batch_adjust_claim_sv;
    RETURN;

END PROCESS_BATCH_ADJUST_CLAIM;


---------------------------------------------------------------------
    -- PROCEDURE
    --    CREATE_ADJUSTMENT
    --
    -- PURPOSE
    --    This procedure is to create adjustment for submitted batch
    --
    -- PARAMETERS
    --		a) p_batch_header_id - Batch header Id
    --
    -- NOTES
    --
----------------------------------------------------------------------
 PROCEDURE CREATE_ADJUSTMENT( p_batch_header_id NUMBER,
			    p_comp_wrt_off     IN VARCHAR2 := fnd_api.g_false,
			    x_return_status    OUT NOCOPY      VARCHAR2,
			    x_msg_count        OUT NOCOPY      NUMBER,
			    x_msg_data         OUT NOCOPY      VARCHAR2) IS


  l_procedure_name	VARCHAR2(30) := 'CREATE_ADJUSTMENT' ;
  l_act_budgets_rec     ozf_actbudgets_pvt.act_budgets_rec_type;
  l_act_util_rec        ozf_actbudgets_pvt.act_util_rec_type;
  x_act_budget_id       NUMBER;
  l_new_util_id		NUMBER ;
  l_fail_count		NUMBER := 0;
  l_validation_level	NUMBER := fnd_api.g_valid_level_full;
  l_init_msg_list	VARCHAR2(1) := fnd_api.g_false ;
  l_conv_adj_amount     NUMBER; -- added to fix bug 9057734


  CURSOR c_batch_details IS
      SELECT lines.batch_line_id,
	    lines.utilization_id ,
	    lines.ADJUSTMENT_TYPE_ID,
	    decode (lines.status_code, 'APPROVED', (lines.ORIGINAL_CLAIM_AMOUNT - lines.CLAIM_AMOUNT), lines.ORIGINAL_CLAIM_AMOUNT)  adj_amount ,
	    lines.agreement_currency_code line_curr_code,
	    adj.adjustment_type adj_type_name,
	    util.cust_account_id,
	    util.billto_cust_account_id,
	    util.bill_to_site_use_id,
	    util.product_level_type,
	    util.product_id,
	    util.object_type,
	    util.object_id,
	    util.order_line_id,
	    util.org_id,
	    util.fund_id,
	    util.currency_code,
	    util.plan_currency_code,
	    util.plan_type,
	    util.plan_id,
	    util.exchange_rate_date
	  FROM OZF_SD_BATCH_LINES_ALL lines ,
	    ozf_funds_utilized_all_b util,
            ozf_claim_types_all_vl adj

	  WHERE lines.batch_id           = p_batch_header_id
	   AND (lines.status_code         = 'APPROVED'
		OR
		lines.COMPLETE_FLAG='Y')
          and lines.ADJUSTMENT_TYPE_ID = adj.claim_type_id
	  AND lines.utilization_id = util.utilization_id
	  AND lines.ORIGINAL_CLAIM_AMOUNT >0
	  AND lines.ADJ_UTILIZATION_ID is null;

  BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS ;


	FND_FILE.PUT_LINE(FND_FILE.LOG, p_batch_header_id||' - Submitted for adjustment');


      	FOR adj_rec IN c_batch_details
	LOOP

	IF(adj_rec.adj_amount<0) THEN

		adj_rec.adj_amount := adj_rec.adj_amount * (-1) ;
	END IF ;

	IF(adj_rec.adj_amount<>0) THEN



		FND_FILE.PUT_LINE(FND_FILE.LOG, p_batch_header_id||' - Line for adjustment is '||adj_rec.batch_line_id);


		l_act_util_rec.adjustment_type        := adj_rec.adj_type_name; --'DECREASE_EARNED';
		l_act_util_rec.adjustment_type_id     := adj_rec.ADJUSTMENT_TYPE_ID;
		l_act_util_rec.utilization_type       := 'ADJUSTMENT';
		l_act_util_rec.orig_utilization_id    := adj_rec.utilization_id;
		l_act_util_rec.adjustment_date        := SYSDATE;
		l_act_util_rec.gl_date                := SYSDATE;
		l_act_util_rec.cust_account_id        := adj_rec.cust_account_id;
		l_act_util_rec.billto_cust_account_id := adj_rec.billto_cust_account_id;
		l_act_util_rec.bill_to_site_use_id    := adj_rec.bill_to_site_use_id;
		l_act_util_rec.product_level_type     := adj_rec.product_level_type;
		l_act_util_rec.product_id             := adj_rec.product_id;
		l_act_util_rec.object_type            := adj_rec.object_type;
		l_act_util_rec.object_id              := adj_rec.object_id;
		l_act_util_rec.order_line_id          := adj_rec.order_line_id;
		l_act_util_rec.org_id                 := adj_rec.org_id;


                l_act_budgets_rec.request_amount         := adj_rec.adj_amount;
		l_act_budgets_rec.status_code            := 'APPROVED';
		l_act_budgets_rec.parent_source_id       := adj_rec.fund_id;
		l_act_budgets_rec.parent_src_curr        := adj_rec.currency_code;
		l_act_budgets_rec.request_currency       := adj_rec.plan_currency_code;
		l_act_budgets_rec.budget_source_type     := adj_rec.plan_type;
		l_act_budgets_rec.budget_source_id       := adj_rec.plan_id;
		l_act_budgets_rec.arc_act_budget_used_by := adj_rec.plan_type;
		l_act_budgets_rec.act_budget_used_by_id  := adj_rec.plan_id;
		l_act_budgets_rec.exchange_rate_date     := adj_rec.exchange_rate_date;


		l_act_budgets_rec.transfer_type          := 'UTILIZED';
		l_act_budgets_rec.transaction_type       := 'DEBIT';-- All the utilization for DECREADED OR INCREASED Earned is of type DEBIT

		ozf_fund_utilized_pvt.create_act_utilization(p_api_version      => 1.0
	                                            ,p_init_msg_list    => l_init_msg_list
	                                            ,p_validation_level => l_validation_level
	                                            ,x_return_status    => x_return_status
	                                            ,x_msg_count        => x_msg_count
	                                            ,x_msg_data         => x_msg_data
	                                            ,p_act_budgets_rec  => l_act_budgets_rec
	                                            ,p_act_util_rec     => l_act_util_rec
	                                            ,x_act_budget_id    => x_act_budget_id
						    ,x_utilization_id   => l_new_util_id
	                                            );


	FND_FILE.PUT_LINE(FND_FILE.LOG,p_batch_header_id||'-'||adj_rec.batch_line_id||' Return staus for ASJ private call '||x_return_status );



		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN


			     fnd_msg_pub.count_and_get (
				p_encoded=> fnd_api.g_false
				,p_count=> x_msg_count
				,p_data=> x_msg_data);


			IF (p_comp_wrt_off = fnd_api.g_false) THEN
	                    RETURN;
		        END IF;


              ELSE

		    UPDATE ozf_funds_utilized_all_b
		      SET amount_remaining = 0,
			  acctd_amount_remaining = 0,
			  plan_curr_amount_remaining = 0,
			  univ_curr_amount_remaining = 0
		      WHERE utilization_id = l_new_util_id;

	    END IF;


	 -- If complete write off, then change the line status to COMPLETE and update the new utlization iD
	 -- Else update the utilization id but the line status
	 IF (p_comp_wrt_off = fnd_api.g_true) THEN

		   UPDATE OZF_SD_BATCH_LINES_ALL
		   SET ADJ_UTILIZATION_ID = l_new_util_id,
		       status_code = 'COMPLETED'
		   WHERE batch_line_id = adj_rec.batch_line_id ;

	  ELSE
		  UPDATE OZF_SD_BATCH_LINES_ALL
		   SET ADJ_UTILIZATION_ID = l_new_util_id
		   WHERE batch_line_id = adj_rec.batch_line_id;

	  END IF;


	  		FND_FILE.PUT_LINE(FND_FILE.LOG,p_batch_header_id||' -Utilization created for line '||adj_rec.batch_line_id );


	END IF ;
	END LOOP;



	FND_FILE.PUT_LINE(FND_FILE.LOG,p_batch_header_id||' -Adjustment completed '||x_return_status );
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

  EXCEPTION

    WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_ERROR;

	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected exception is :' || sqlerrm);


	RETURN;

END CREATE_ADJUSTMENT;


-- Start of comments
--	API name        : PROCESS_SD_PEN_CLOSE_BATCHES
--	Type            : Private
--	Pre-reqs        : Batch Status should be Pending Close
--      Function        : Executable target for concurrent program
--                      : Executable Name "OZFSDPBPEX"
--                      : Processes the batch for Adjustment and Claim
--	Parameters      :
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments

  PROCEDURE PROCESS_SD_PEN_CLOSE_BATCHES(errbuf OUT nocopy VARCHAR2,
					     retcode          OUT nocopy NUMBER,
                                             p_batch_id       NUMBER) IS


l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000) ;
l_curr_batch_status VARCHAR2(30);

l_status_code  VARCHAR2(30) := NULL;
l_request_id   NUMBER := NULL;
l_phase_code   VARCHAR2(1) := NULL;

Cursor c_pen_close_batches (p_batch_id number) is
select bh.status_code, cr.request_id, cr.phase_code
  from OZF_SD_BATCH_HEADERS_ALL bh, FND_CONCURRENT_PROGRAMS cp , FND_CONCURRENT_REQUESTS cr
 where cp.concurrent_program_name = 'OZFSDPBPPRG'
   and cp.concurrent_program_id = bh.program_id
   and cr.request_id(+) = bh.request_id
   and bh.batch_id = p_batch_id;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG, ' Processing for batch '|| p_batch_id || ' for closure.');


OPEN  c_pen_close_batches (p_batch_id);
FETCH c_pen_close_batches into l_status_code, l_request_id, l_phase_code;
CLOSE c_pen_close_batches;


FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current Status of batch is  '|| l_status_code);

-- True when the request in BH not found in FND_Concurrent_Reqeusts / The current request is the request tagged in BH / Last request has finshed processing.
IF  ( l_status_code ='PENDING_CLOSE'
  AND ( l_request_id is null OR l_request_id = FND_GLOBAL.CONC_REQUEST_ID OR l_phase_code = 'C')) THEN

   update ozf_sd_batch_headers_all
   set request_id = FND_GLOBAL.CONC_REQUEST_ID,
       program_id = FND_GLOBAL.CONC_PROGRAM_ID,
       last_update_date = sysdate,
       last_updated_by =  FND_GLOBAL.USER_ID,
       last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
	   object_version_number = object_version_number + 1
   where batch_id = p_batch_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoking api for processing Claim / Adjustment.');

     PROCESS_BATCH_ADJUST_CLAIM(  p_batch_header_id => p_batch_id,
			    p_validation_level=> fnd_api.g_valid_level_full,
			    p_init_msg_list=> fnd_api.g_false,
			    x_return_status=> l_return_status ,
			    x_msg_count=> l_msg_count ,
			    x_msg_data=> l_msg_data ) ;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'The processing for the batch is completed  '|| l_return_status);

 ELSE

	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch could not be processed by this request.');
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Either the batch is not in Pending Close state or it is currently being processed by another request.');

END IF ;

END PROCESS_SD_PEN_CLOSE_BATCHES ;



-- Start of comments
--	API name        : SET_COMPLETE_FLAGS
--	Type            : Private
--	Purpose         : Mark the line status to complete
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments


PROCEDURE SET_COMPLETE_FLAGS(  p_batch_header_id NUMBER,
			      x_return_status    OUT NOCOPY      VARCHAR2) IS

l_incomplete_count NUMBER ;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

    UPDATE OZF_SD_BATCH_LINES_ALL
    SET complete_flag='Y'
    WHERE batch_id=p_batch_header_id ;

    COMMIT;

     EXCEPTION

    WHEN OTHERS then
	x_return_status := FND_API.G_RET_STS_ERROR;

	FND_FILE.PUT_LINE(FND_FILE.LOG,p_batch_header_id||' Unexpected exception occured ' );

	RETURN;


END SET_COMPLETE_FLAGS ;


-- Start of comments
--	API name        : PROCESS_SD_PEN_CLOSE_BATCHES
--	Type            : Private
--	Purpose         : Check if few lines have complete not set
--	Parameters      :
--      IN              :       p_batch_id                        IN NUMBER

-- End of comments


PROCEDURE CHECK_COMPLETE_FLAGS(  p_batch_header_id NUMBER,
			      x_return_status    OUT NOCOPY      VARCHAR2) IS


l_incomplete_count NUMBER ;


BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	SELECT COUNT(1) INTO l_incomplete_count
	FROM OZF_SD_BATCH_LINES_ALL
	WHERE status_code IN( 'REJECTED','SUBMITTED')
	AND NVL(complete_flag,'N')<>'Y'
	AND batch_id=p_batch_header_id ;


	IF (l_incomplete_count>0) THEN

		x_return_status := FND_API.G_RET_STS_ERROR ;
       END IF ;


END CHECK_COMPLETE_FLAGS ;

end OZF_SD_UTIL_PVT;

/
