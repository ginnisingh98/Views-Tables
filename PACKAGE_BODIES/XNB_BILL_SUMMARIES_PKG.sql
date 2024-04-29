--------------------------------------------------------
--  DDL for Package Body XNB_BILL_SUMMARIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_BILL_SUMMARIES_PKG" as
/* $Header: XNBTBSB.pls 120.0 2005/05/30 13:45:26 appldev noship $ */

-- Start of Comments
-- Package name     : XNB_BILL_SUMMARIES_PKG
-- Purpose          : Defines public APIs to insert/update records into XNB BILL SUMMARIES schema
-- NOTE             :
-- History          :
--        DATE          AUTHOR		COMMENTS
--        24-Aug-2004   dbhagat     Create table handler
--        04-Feb-2005   DPUTHIYE    Added p_api_version parameter to APIs. (Fixed bug 4159395).
--        14-Apr-2005   dbhagat     Removed Bill Cycle End Date a mandatory for update. (Fixed bug 4300093).
-- End of Comments

    G_PKG_NAME CONSTANT VARCHAR2(30):= 'XNB_BILL_SUMMARIES_PKG';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'xnbtbsb.pls';


    -- Start of comments
    --	API name 	: Insert_Row_Batch
    --	Type		: Public
    --	Pre-reqs	: None.
    --	Function	: Inserts the given bill summary rows into the XNB table
    --              . XNB_BILL_SUMMARIES
    -- Assumptions  :
        -- All records whose
		-- 1.	Account Number must exit in eBusiness suite database schema
		-- 		HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER.
		-- 2.	Account Number, Bill Number, Bill Cycle End Date and Billing
		-- 		Vendor Name are required.
		-- 3.	Bill Number, Account Number and Billing Vendor Name combined
		-- 		must be unique for insertion.
		-- 4.	For all above validations, in case of failure, only those records
		-- 		will be rejected and rest inserted. Any other validation failure will
		--		not insert any record (All or none are inserted/ rolled back).
		-- 5.	All data inserted or updated are case sensitive.
    --	Parameters	:
    --	IN		:	p_api_version IN NUMBER	Required
    --  IN      :   p_bill_summaries IN	bill_summaries_table
    --                 -- The table of bill summary records to be inserted.
    --  OUT     :   x_return_status OUT NOCOPY VARCHAR2
    --                 -- Execution status returned.
    --                 -- FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_SUCCESS
    --  OUT     :   x_msg_data OUT NOCOPY VARCHAR2
    --                 -- Error message returned.
    --	Version	: Current version	1.0
    --			  Initial version 	1.0
    -- End of comments
    PROCEDURE Insert_Row_Batch(
	            p_api_version           IN 				NUMBER,
                p_bill_summaries        IN		        bill_summaries_table,
                x_return_status         OUT   NOCOPY    VARCHAR2,
                x_msg_data		  	    OUT   NOCOPY    VARCHAR2
              )
    IS
        --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
        --Change: Added parameter p_api_version to comply to Business API standards.
        --        Added Std API documentation header for the API.
        --        Moved Assumptions from below this comment to API doc Header
        --Other Files Impact: None.
        l_api_version CONSTANT NUMBER := 1.0;						-- added to fix Bug#:4159395
        l_api_name	  CONSTANT VARCHAR2(20)	:= 'Insert_Row_Batch';  -- added to fix Bug#:4159395

        null_excep      EXCEPTION;                          -- exception declaration

        l_bs_all_rec_count NUMBER := 0;                     -- Total bill summaries recpunt received
        l_bs_valid_rec_count NUMBER := 0;                   -- Valid bill summary record to be inserted
        l_bs_valid_rec_flag varchar2(1) := null;            -- Validity of a bill summary record is true
        --l_err_msg_count NUMBER := 0;                      -- Total number of error found

        l_num_init NUMBER := 0;                             -- intialize varray variable of NUMBER type
        l_var_init varchar2(5) := null;                     -- intialize varray variable of varchar2 type

        tmp_acc_num varchar2(30) := null;                   -- account number to validate in eBusiness DB
        tmp_acc_num2 varchar2(30) := null;                  -- account number to hold in temp account number

        t_acc_num varchar2(30) := null;                  	-- account number to hold in temp account number
        t_bill_num varchar2(30) := null;                  	-- bill number to hold in temp bill number
        t_bill_vendor varchar2(30) := null;                 -- billing vendor name to hold in temp billing vendor name
		t_uniq_val 	  VARCHAR2(1) := null;

        -- declaring varray to hold bill summary records
        l_bill_summary_id                   v_number;
        l_account_number                    v_var30;
        l_total_amount_due                  v_var30;
        l_adjustments                       v_var30;
        l_unresolved_disputes               v_var30;
        l_bill_number                       v_var30;
        l_bill_cycle_start_date             v_date;
        l_bill_cycle_end_date               v_date;
        l_due_date                          v_date;
        l_new_charges                       v_var30;
        l_payment                           v_var30;
        l_balance                           v_var30;
        l_previous_balance                  v_var30;
        l_billing_vendor_name               v_var240;
        l_bill_location_url                 v_var240;
        l_due_now                           v_var30;
        l_created_by                        v_number;
        l_creation_date                     v_date;
        l_last_updated_by                   v_number;
        l_last_update_date                  v_date;
        l_last_update_login                 v_number;
        l_object_version_number             v_number;
        l_attribute_category                v_var30;
        l_attribute1                        v_var150;
        l_attribute2                        v_var150;
        l_attribute3                        v_var150;
        l_attribute4                        v_var150;
        l_attribute5                        v_var150;
        l_attribute6                        v_var150;
        l_attribute7                        v_var150;
        l_attribute8                        v_var150;
        l_attribute9                        v_var150;
        l_attribute10                       v_var150;
        l_attribute11                       v_var150;
        l_attribute12                       v_var150;
        l_attribute13                       v_var150;
        l_attribute14                       v_var150;
        l_attribute15                       v_var150;

        Cursor c_get_acc_num is
            select ACCOUNT_NUMBER
            from HZ_CUST_ACCOUNTS
            where ACCOUNT_NUMBER = tmp_acc_num;

        Cursor c_check_uniq_constrain is
            select 1
            from XNB_BILL_SUMMARIES
            where ACCOUNT_NUMBER = t_acc_num
			and BILL_NUMBER = t_bill_num
			and BILLING_VENDOR_NAME = t_bill_vendor;

    BEGIN
        SAVEPOINT BULK_INSERT;

 	    --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
 	    --Change: The savepoint above has been moved from a place below to the cur loc.
        --Change: The following check was added to check API compatibility
        --Other Files Impact: None.

		-- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(
		                l_api_version,
						p_api_version,
						l_api_name,
                        G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Initialize API return status to success and other variables
        l_bs_all_rec_count := p_bill_summaries.last;
        l_bs_valid_rec_flag := 'T';
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := null;

        -- Intialize all local varray and extend to intialize for all records
        l_bill_summary_id                   :=v_number(l_num_init);
        l_bill_summary_id.EXTEND(l_bs_all_rec_count,1);
        l_account_number                    :=v_var30(l_var_init);
        l_account_number.EXTEND(l_bs_all_rec_count,1);
        l_total_amount_due                  :=v_var30(l_var_init);
        l_total_amount_due.EXTEND(l_bs_all_rec_count,1);
        l_adjustments                       :=v_var30(l_var_init);
        l_adjustments.EXTEND(l_bs_all_rec_count,1);
        l_unresolved_disputes               :=v_var30(l_var_init);
        l_unresolved_disputes.EXTEND(l_bs_all_rec_count,1);
        l_bill_number                       :=v_var30(l_var_init);
        l_bill_number.EXTEND(l_bs_all_rec_count,1);
        l_bill_cycle_start_date             :=v_date(null);
        l_bill_cycle_start_date.EXTEND(l_bs_all_rec_count,1);
        l_bill_cycle_end_date               :=v_date(null);
        l_bill_cycle_end_date.EXTEND(l_bs_all_rec_count,1);
        l_due_date                          :=v_date(null);
        l_due_date.EXTEND(l_bs_all_rec_count,1);
        l_new_charges                       :=v_var30(l_var_init);
        l_new_charges.EXTEND(l_bs_all_rec_count,1);
        l_payment                           :=v_var30(l_var_init);
        l_payment.EXTEND(l_bs_all_rec_count,1);
        l_balance                           :=v_var30(l_var_init);
        l_balance.EXTEND(l_bs_all_rec_count,1);
        l_previous_balance                  :=v_var30(l_var_init);
        l_previous_balance.EXTEND(l_bs_all_rec_count,1);
        l_billing_vendor_name               :=v_var240(l_var_init);
        l_billing_vendor_name.EXTEND(l_bs_all_rec_count,1);
        l_bill_location_url                 :=v_var240(l_var_init);
        l_bill_location_url.EXTEND(l_bs_all_rec_count,1);
        l_due_now                           :=v_var30(l_var_init);
        l_due_now.EXTEND(l_bs_all_rec_count,1);
        l_created_by                        :=v_number(l_num_init);
        l_created_by.EXTEND(l_bs_all_rec_count,1);
        l_creation_date                     :=v_date(null);
        l_creation_date.EXTEND(l_bs_all_rec_count,1);
        l_last_updated_by                   :=v_number(l_num_init);
        l_last_updated_by.EXTEND(l_bs_all_rec_count,1);
        l_last_update_date                  :=v_date(null);
        l_last_update_date.EXTEND(l_bs_all_rec_count,1);
        l_last_update_login                 :=v_number(l_num_init);
        l_last_update_login.EXTEND(l_bs_all_rec_count,1);
        l_object_version_number             :=v_number(l_num_init);
        l_object_version_number.EXTEND(l_bs_all_rec_count,1);
        l_attribute_category                :=v_var30(l_var_init);
        l_attribute_category.EXTEND(l_bs_all_rec_count,1);
        l_attribute1                        :=v_var150(l_var_init);
        l_attribute1.EXTEND(l_bs_all_rec_count,1);
        l_attribute2                        :=v_var150(l_var_init);
        l_attribute2.EXTEND(l_bs_all_rec_count,1);
        l_attribute3                        :=v_var150(l_var_init);
        l_attribute3.EXTEND(l_bs_all_rec_count,1);
        l_attribute4                        :=v_var150(l_var_init);
        l_attribute4.EXTEND(l_bs_all_rec_count,1);
        l_attribute5                        :=v_var150(l_var_init);
        l_attribute5.EXTEND(l_bs_all_rec_count,1);
        l_attribute6                        :=v_var150(l_var_init);
        l_attribute6.EXTEND(l_bs_all_rec_count,1);
        l_attribute7                        :=v_var150(l_var_init);
        l_attribute7.EXTEND(l_bs_all_rec_count,1);
        l_attribute8                        :=v_var150(l_var_init);
        l_attribute8.EXTEND(l_bs_all_rec_count,1);
        l_attribute9                        :=v_var150(l_var_init);
        l_attribute9.EXTEND(l_bs_all_rec_count,1);
        l_attribute10                       :=v_var150(l_var_init);
        l_attribute10.EXTEND(l_bs_all_rec_count,1);
        l_attribute11                       :=v_var150(l_var_init);
        l_attribute11.EXTEND(l_bs_all_rec_count,1);
        l_attribute12                       :=v_var150(l_var_init);
        l_attribute12.EXTEND(l_bs_all_rec_count,1);
        l_attribute13                       :=v_var150(l_var_init);
        l_attribute13.EXTEND(l_bs_all_rec_count,1);
        l_attribute14                       :=v_var150(l_var_init);
        l_attribute14.EXTEND(l_bs_all_rec_count,1);
        l_attribute15                       :=v_var150(l_var_init);
        l_attribute15.EXTEND(l_bs_all_rec_count,1);

          -- Loop to validate and initialize all records
          FOR i IN 1..l_bs_all_rec_count LOOP
            l_bs_valid_rec_flag := 'T';

            -- Record cannot be Null
			/*
            IF (p_bill_summaries(i) IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BS_REC_IS_NULL');
                fnd_message.SET_TOKEN('REC_NUM',n);
            END IF;
			*/

            -- Bill Number is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).BILL_NUMBER IS NULL ) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BILL_NUM_IS_NULL');
            END IF;

            -- Account Number is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).ACCOUNT_NUMBER IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data ||  ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_ACC_NUM_IS_NULL');
            ELSE
                tmp_acc_num := p_bill_summaries(i).ACCOUNT_NUMBER;
                tmp_acc_num2 := null;

                -- Fetch account number from HZ_CUST_ACCOUNTS table
                open c_get_acc_num;
					begin
			  			fetch c_get_acc_num into tmp_acc_num2;
						if (c_get_acc_num%NOTFOUND OR tmp_acc_num2 IS NULL) then
						   raise no_data_found;
	 	    		   end if;
					exception
						when no_data_found then
			                l_bs_valid_rec_flag := 'F';  -- validity is false
			                x_return_status := FND_API.G_RET_STS_ERROR;
			                fnd_message.SET_NAME('XNB','XNB_PLS_ACC_NUM_NOT_VALID');
			                fnd_message.SET_TOKEN('ACC_NUM',tmp_acc_num);
			                x_msg_data := x_msg_data || '  '  || fnd_message.GET;
	     					--dbms_output.put_line(' no data found= ' || l_bs_valid_rec_flag );
					end;
                close c_get_acc_num;
                -- Account Number must exist in eBusiness suit database
                --IF (tmp_acc_num2 IS NULL) THEN
                --END IF;
            END IF;

            -- Bill Cycle End Date is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).BILL_CYCLE_END_DATE IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BILL_END_DT_IS_NULL');
            END IF;

            -- Bill Vendor Name is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).BILLING_VENDOR_NAME IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BILL_VEN_IS_NULL');
            END IF;

 			-- Check for Uniqe Constraints...
            t_acc_num := p_bill_summaries(i).ACCOUNT_NUMBER;
            t_bill_num := p_bill_summaries(i).BILL_NUMBER;
            t_bill_vendor := p_bill_summaries(i).BILLING_VENDOR_NAME;
			t_uniq_val := null;
            open c_check_uniq_constrain;
				 begin
				 	fetch c_check_uniq_constrain into t_uniq_val;
					if (c_check_uniq_constrain%FOUND OR t_uniq_val ='1') then
		                l_bs_valid_rec_flag := 'F';  -- validity is false
		                x_return_status := FND_API.G_RET_STS_ERROR;
		                fnd_message.SET_NAME('XNB','XNB_PLS_BILL_SUM_REC_NOT_UNQ');
		                fnd_message.SET_TOKEN('ACC_NUM',t_acc_num);
		                fnd_message.SET_TOKEN('BILL_NUM',t_bill_num);
		                fnd_message.SET_TOKEN('BILL_VEN',t_bill_vendor);
		                x_msg_data := x_msg_data || '  '  || fnd_message.GET;
					end if;
				exception
					when no_data_found then
						 null;
				end;
            close c_check_uniq_constrain;

           -- If the bill summary record is valid
            IF l_bs_valid_rec_flag = 'T' THEN
                l_bs_valid_rec_count := l_bs_valid_rec_count + 1;

                l_account_number(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ACCOUNT_NUMBER;
                l_total_amount_due(l_bs_valid_rec_count) :=	  p_bill_summaries(i).TOTAL_AMOUNT_DUE;
                l_adjustments(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ADJUSTMENTS;
                l_unresolved_disputes(l_bs_valid_rec_count) :=	  p_bill_summaries(i).UNRESOLVED_DISPUTES;
                l_bill_number(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_NUMBER;
                l_bill_cycle_start_date(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_CYCLE_START_DATE;
                l_bill_cycle_end_date(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_CYCLE_END_DATE;
                l_due_date(l_bs_valid_rec_count) :=	  p_bill_summaries(i).DUE_DATE;
                l_new_charges(l_bs_valid_rec_count) :=	  p_bill_summaries(i).NEW_CHARGES;
                l_payment(l_bs_valid_rec_count) :=	  p_bill_summaries(i).PAYMENT;
                l_balance(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BALANCE;
                l_previous_balance(l_bs_valid_rec_count) :=	  p_bill_summaries(i).PREVIOUS_BALANCE;
                l_billing_vendor_name(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILLING_VENDOR_NAME;
                l_bill_location_url(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_LOCATION_URL;
                l_due_now(l_bs_valid_rec_count) :=	  p_bill_summaries(i).DUE_NOW;

                IF (p_bill_summaries(i).CREATED_BY IS NULL) THEN
                    l_created_by(l_bs_valid_rec_count) := FND_GLOBAL.USER_ID;
                ELSE
                    l_created_by(l_bs_valid_rec_count) := p_bill_summaries(i).CREATED_BY;
                END IF;

                l_creation_date(l_bs_valid_rec_count) :=	  SYSDATE;

                IF (p_bill_summaries(i).LAST_UPDATED_BY IS NULL) THEN
                    l_last_updated_by(l_bs_valid_rec_count) := FND_GLOBAL.USER_ID;
                ELSE
                    l_last_updated_by(l_bs_valid_rec_count) := p_bill_summaries(i).LAST_UPDATED_BY;
                END IF;

                l_last_update_date(l_bs_valid_rec_count) :=	  SYSDATE;

                IF (p_bill_summaries(i).LAST_UPDATE_LOGIN IS NULL) THEN
                    l_last_update_login(l_bs_valid_rec_count) := FND_GLOBAL.LOGIN_ID;
                ELSE
                    l_last_update_login(l_bs_valid_rec_count) := p_bill_summaries(i).LAST_UPDATE_LOGIN;
                END IF;

                l_object_version_number(l_bs_valid_rec_count) :=	  1;
                l_attribute_category(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE_CATEGORY;
                l_attribute1(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE1;
                l_attribute2(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE2;
                l_attribute3(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE3;
                l_attribute4(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE4;
                l_attribute5(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE5;
                l_attribute6(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE6;
                l_attribute7(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE7;
                l_attribute8(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE8;
                l_attribute9(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE9;
                l_attribute10(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE10;
                l_attribute11(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE11;
                l_attribute12(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE12;
                l_attribute13(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE13;
                l_attribute14(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE14;
                l_attribute15(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE15;
            END IF;

          END LOOP; -- End For loop

          -- batch insert all valid records in database
          FORALL i IN 1..l_bs_valid_rec_count
              INSERT INTO XNB_BILL_SUMMARIES(
                      BILL_SUMMARY_ID,
                      ACCOUNT_NUMBER,
                      TOTAL_AMOUNT_DUE,
                      ADJUSTMENTS,
                      UNRESOLVED_DISPUTES,
                      BILL_NUMBER,
                      BILL_CYCLE_START_DATE,
                      BILL_CYCLE_END_DATE,
                      DUE_DATE,
                      NEW_CHARGES,
                      PAYMENT,
                      BALANCE,
                      PREVIOUS_BALANCE,
                      BILLING_VENDOR_NAME,
                      BILL_LOCATION_URL,
                      DUE_NOW,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATE_LOGIN,
                      OBJECT_VERSION_NUMBER,
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
                      ATTRIBUTE15
                  ) VALUES (
                        XNB_BILL_SUMMARIES_S.nextval,
                        l_account_number(i),
                        l_total_amount_due(i),
                        l_adjustments(i),
                        l_unresolved_disputes(i),
                        l_bill_number(i),
                        l_bill_cycle_start_date(i),
                        l_bill_cycle_end_date(i),
                        l_due_date(i),
                        l_new_charges(i),
                        l_payment(i),
                        l_balance(i),
                        l_previous_balance(i),
                        l_billing_vendor_name(i),
                        l_bill_location_url(i),
                        l_due_now(i),
                        l_created_by(i),
                        l_creation_date(i),
                        l_last_updated_by(i),
                        l_last_update_date(i),
                        l_last_update_login(i),
                        l_object_version_number(i),
                        l_attribute_category(i),
                        l_attribute1(i),
                        l_attribute2(i),
                        l_attribute3(i),
                        l_attribute4(i),
                        l_attribute5(i),
                        l_attribute6(i),
                        l_attribute7(i),
                        l_attribute8(i),
                        l_attribute9(i),
                        l_attribute10(i),
                        l_attribute11(i),
                        l_attribute12(i),
                        l_attribute13(i),
                        l_attribute14(i),
                        l_attribute15(i)
                   ); -- End Forall loop

          -- If Null bill number or account number throw error
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE null_excep;
          END IF;

          -- Handle all exceptions
          Exception
             -- Handle null exceptions
             WHEN null_excep THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_SUCC_INS');

             WHEN NO_DATA_FOUND then
                ROLLBACK TO BULK_INSERT;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_NO_REC_FND');

  	         --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
             --Change: The following exception section was added to trap API version check exceptions.
             --Other Files Impact: None.
             WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO BULK_INSERT;
                FND_MESSAGE.SET_NAME('XNB','XNB_PLS_MSG_INCOMPAT_API');
                FND_MESSAGE.SET_TOKEN('API_FULL_NAME', G_PKG_NAME || '.' || l_api_name );
                FND_MESSAGE.SET_TOKEN('GIVEN_VER', p_api_version);
                FND_MESSAGE.SET_TOKEN('CURR_VER', l_api_version);
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || FND_MESSAGE.GET;

             WHEN OTHERS THEN
                ROLLBACK TO BULK_INSERT;
   	            --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
                --Change: On OTHERS error, the public API should return G_RET_STS_UNEXP_ERROR. Corrected return code.
                --Other Files Impact: None.
                --x_return_status := FND_API.G_RET_STS_ERROR;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_NO_REC_INS');

    End Insert_Row_Batch;


    -- Start of comments
    --	API name 	: Update_Row_Batch
    --	Type		: Public
    --	Pre-reqs	: None.
    --	Function	: Updates the given bill summary rows in the XNB table
    --              . XNB_BILL_SUMMARIES.
    -- Assumptions  :
        -- All records whose
		-- 1.	Account Number must exit in eBusiness suite database schema
		-- 	HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER.
		-- 2.	Account Number, Bill Number, Bill Cycle End Date and Billing
		-- 	Vendor Name are required.
		-- 3.	Account Number, Bill Number and Billing Vendor Name cannot be
		-- 	updated and hence must be present for updating.
		-- 4.	For all above validations, in case of failure, only those records
		-- 	will be rejected and rest inserted. Any other validation failure
		--	will not insert any record (All or none are inserted/ rolled back).
		-- 5.	All data inserted are case sensitive.
    --	Parameters	:
    --	IN		:	p_api_version IN NUMBER	Required
    --  IN      :   p_bill_summaries IN	bill_summaries_table
    --                 -- The table of bill summary records to be inserted.
    --  OUT     :   x_return_status OUT NOCOPY VARCHAR2
    --                 -- Execution status returned.
    --                 -- FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_SUCCESS
    --  OUT     :   x_msg_data OUT NOCOPY VARCHAR2
    --                 -- Error message returned.
    --	Version	: Current version	1.0
    --			  Initial version 	1.0
    -- End of comments

    PROCEDURE Update_Row_Batch(
                p_api_version 		    IN 				NUMBER,
                p_bill_summaries        IN	            bill_summaries_table,
                x_return_status         OUT   NOCOPY    VARCHAR2,
                x_msg_data		  	    OUT   NOCOPY    VARCHAR2
              )
    IS
        --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
        --Change: Added parameter p_api_version to comply to Business API standards.
        --        Added Std API documentation header for the API.
        --        Moved Assumptions from below this comment to API doc Header
        --Other Files Impact: None.
        l_api_version CONSTANT NUMBER := 1.0;						-- added to fix Bug#:4159395
        l_api_name	  CONSTANT VARCHAR2(20)	:= 'Update_Row_Batch';  -- added to fix Bug#:4159395

        null_excep      EXCEPTION;                          -- exception declaration

        l_bs_all_rec_count NUMBER := 0;                     -- Total bill summaries recpunt received
        l_bs_valid_rec_count NUMBER := 0;                   -- Valid bill summary record to be inserted
        l_bs_valid_rec_flag varchar2(1) := null;            -- Validity of a bill summary record is true
        --l_err_msg_count NUMBER := 0;                      -- Total number of error found

        l_num_init NUMBER := 0;                             -- intialize varray variable of NUMBER type
        l_var_init varchar2(5) := null;                     -- intialize varray variable of varchar2 type

        -- declaring varray to hold bill summary records
        l_bill_summary_id                   v_number;
        l_account_number                    v_var30;
        l_total_amount_due                  v_var30;
        l_adjustments                       v_var30;
        l_unresolved_disputes               v_var30;
        l_bill_number                       v_var30;
        l_bill_cycle_start_date             v_date;
        l_bill_cycle_end_date               v_date;
        l_due_date                          v_date;
        l_new_charges                       v_var30;
        l_payment                           v_var30;
        l_balance                           v_var30;
        l_previous_balance                  v_var30;
        l_billing_vendor_name               v_var240;
        l_bill_location_url                 v_var240;
        l_due_now                           v_var30;
        l_created_by                        v_number;
        l_creation_date                     v_date;
        l_last_updated_by                   v_number;
        l_last_update_date                  v_date;
        l_last_update_login                 v_number;
        l_object_version_number             v_number;
        l_attribute_category                v_var30;
        l_attribute1                        v_var150;
        l_attribute2                        v_var150;
        l_attribute3                        v_var150;
        l_attribute4                        v_var150;
        l_attribute5                        v_var150;
        l_attribute6                        v_var150;
        l_attribute7                        v_var150;
        l_attribute8                        v_var150;
        l_attribute9                        v_var150;
        l_attribute10                       v_var150;
        l_attribute11                       v_var150;
        l_attribute12                       v_var150;
        l_attribute13                       v_var150;
        l_attribute14                       v_var150;
        l_attribute15                       v_var150;

        t_acc_num varchar2(30) := null;                  	-- account number to hold in temp account number
        t_bill_num varchar2(30) := null;                  	-- bill number to hold in temp bill number
        t_bill_vendor varchar2(30) := null;                 -- billing vendor name to hold in temp billing vendor name
		t_uniq_val 	  VARCHAR2(1) := null;

        Cursor c_check_uniq_constrain is
            select
                    TOTAL_AMOUNT_DUE ,
                    ADJUSTMENTS ,
                    UNRESOLVED_DISPUTES ,
                    BILL_CYCLE_START_DATE,
                    BILL_CYCLE_END_DATE,
                    DUE_DATE,
                    NEW_CHARGES,
                    PAYMENT,
                    BALANCE,
                    PREVIOUS_BALANCE,
                    BILL_LOCATION_URL,
                    DUE_NOW ,
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
                    ATTRIBUTE15
            from XNB_BILL_SUMMARIES
            where ACCOUNT_NUMBER = t_acc_num
			and BILL_NUMBER = t_bill_num
			and BILLING_VENDOR_NAME = t_bill_vendor;

    BEGIN
        SAVEPOINT BULK_UPDATE;
        --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
        --Change: The following check was added to check API compatibility
        --Other Files Impact: None.

		-- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(
		                l_api_version,
						p_api_version,
						l_api_name,
                        G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Initialize API return status to success and other variables
        l_bs_all_rec_count := p_bill_summaries.last;
        l_bs_valid_rec_flag := 'T';
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := null;

        -- Intialize all local varray and extend to intialize for all records
        l_bill_summary_id                   :=v_number(l_num_init);
        l_bill_summary_id.EXTEND(l_bs_all_rec_count,1);
        l_account_number                    :=v_var30(l_var_init);
        l_account_number.EXTEND(l_bs_all_rec_count,1);
        l_total_amount_due                  :=v_var30(l_var_init);
        l_total_amount_due.EXTEND(l_bs_all_rec_count,1);
        l_adjustments                       :=v_var30(l_var_init);
        l_adjustments.EXTEND(l_bs_all_rec_count,1);
        l_unresolved_disputes               :=v_var30(l_var_init);
        l_unresolved_disputes.EXTEND(l_bs_all_rec_count,1);
        l_bill_number                       :=v_var30(l_var_init);
        l_bill_number.EXTEND(l_bs_all_rec_count,1);
        l_bill_cycle_start_date             :=v_date(null);
        l_bill_cycle_start_date.EXTEND(l_bs_all_rec_count,1);
        l_bill_cycle_end_date               :=v_date(null);
        l_bill_cycle_end_date.EXTEND(l_bs_all_rec_count,1);
        l_due_date                          :=v_date(null);
        l_due_date.EXTEND(l_bs_all_rec_count,1);
        l_new_charges                       :=v_var30(l_var_init);
        l_new_charges.EXTEND(l_bs_all_rec_count,1);
        l_payment                           :=v_var30(l_var_init);
        l_payment.EXTEND(l_bs_all_rec_count,1);
        l_balance                           :=v_var30(l_var_init);
        l_balance.EXTEND(l_bs_all_rec_count,1);
        l_previous_balance                  :=v_var30(l_var_init);
        l_previous_balance.EXTEND(l_bs_all_rec_count,1);
        l_billing_vendor_name               :=v_var240(l_var_init);
        l_billing_vendor_name.EXTEND(l_bs_all_rec_count,1);
        l_bill_location_url                 :=v_var240(l_var_init);
        l_bill_location_url.EXTEND(l_bs_all_rec_count,1);
        l_due_now                           :=v_var30(l_var_init);
        l_due_now.EXTEND(l_bs_all_rec_count,1);
        l_created_by                        :=v_number(l_num_init);
        l_created_by.EXTEND(l_bs_all_rec_count,1);
        l_creation_date                     :=v_date(null);
        l_creation_date.EXTEND(l_bs_all_rec_count,1);
        l_last_updated_by                   :=v_number(l_num_init);
        l_last_updated_by.EXTEND(l_bs_all_rec_count,1);
        l_last_update_date                  :=v_date(null);
        l_last_update_date.EXTEND(l_bs_all_rec_count,1);
        l_last_update_login                 :=v_number(l_num_init);
        l_last_update_login.EXTEND(l_bs_all_rec_count,1);
        l_object_version_number             :=v_number(l_num_init);
        l_object_version_number.EXTEND(l_bs_all_rec_count,1);
        l_attribute_category                :=v_var30(l_var_init);
        l_attribute_category.EXTEND(l_bs_all_rec_count,1);
        l_attribute1                        :=v_var150(l_var_init);
        l_attribute1.EXTEND(l_bs_all_rec_count,1);
        l_attribute2                        :=v_var150(l_var_init);
        l_attribute2.EXTEND(l_bs_all_rec_count,1);
        l_attribute3                        :=v_var150(l_var_init);
        l_attribute3.EXTEND(l_bs_all_rec_count,1);
        l_attribute4                        :=v_var150(l_var_init);
        l_attribute4.EXTEND(l_bs_all_rec_count,1);
        l_attribute5                        :=v_var150(l_var_init);
        l_attribute5.EXTEND(l_bs_all_rec_count,1);
        l_attribute6                        :=v_var150(l_var_init);
        l_attribute6.EXTEND(l_bs_all_rec_count,1);
        l_attribute7                        :=v_var150(l_var_init);
        l_attribute7.EXTEND(l_bs_all_rec_count,1);
        l_attribute8                        :=v_var150(l_var_init);
        l_attribute8.EXTEND(l_bs_all_rec_count,1);
        l_attribute9                        :=v_var150(l_var_init);
        l_attribute9.EXTEND(l_bs_all_rec_count,1);
        l_attribute10                       :=v_var150(l_var_init);
        l_attribute10.EXTEND(l_bs_all_rec_count,1);
        l_attribute11                       :=v_var150(l_var_init);
        l_attribute11.EXTEND(l_bs_all_rec_count,1);
        l_attribute12                       :=v_var150(l_var_init);
        l_attribute12.EXTEND(l_bs_all_rec_count,1);
        l_attribute13                       :=v_var150(l_var_init);
        l_attribute13.EXTEND(l_bs_all_rec_count,1);
        l_attribute14                       :=v_var150(l_var_init);
        l_attribute14.EXTEND(l_bs_all_rec_count,1);
        l_attribute15                       :=v_var150(l_var_init);
        l_attribute15.EXTEND(l_bs_all_rec_count,1);

        -- Loop to validate and initialize all records
        FOR i IN 1..l_bs_all_rec_count LOOP
            l_bs_valid_rec_flag := 'T';

            -- Bill Number is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).BILL_NUMBER IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BILL_NUM_IS_NULL');
            END IF;

            -- Account Number is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).ACCOUNT_NUMBER IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data ||  ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_ACC_NUM_IS_NULL');
            END IF;

             -- Bill Vendor Name is mandatory (NOT NULL field)
            IF (p_bill_summaries(i).BILLING_VENDOR_NAME IS NULL) THEN
                l_bs_valid_rec_flag := 'F';  -- validity is false
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || fnd_message.GET_STRING('XNB','XNB_PLS_BILL_VEN_IS_NULL');
            END IF;

 			-- Check for Uniqe Constraints...
            t_acc_num := p_bill_summaries(i).ACCOUNT_NUMBER;
            t_bill_num := p_bill_summaries(i).BILL_NUMBER;
            t_bill_vendor := p_bill_summaries(i).BILLING_VENDOR_NAME;
			t_uniq_val := null;
            l_bs_valid_rec_count := l_bs_valid_rec_count + 1;
            open c_check_uniq_constrain;
				 begin
				 	fetch c_check_uniq_constrain into
                        l_total_amount_due(l_bs_valid_rec_count),
                        l_adjustments(l_bs_valid_rec_count),
                        l_unresolved_disputes(l_bs_valid_rec_count),
                        l_bill_cycle_start_date(l_bs_valid_rec_count),
                        l_bill_cycle_end_date(l_bs_valid_rec_count),
                        l_due_date(l_bs_valid_rec_count),
                        l_new_charges(l_bs_valid_rec_count),
                        l_payment(l_bs_valid_rec_count),
                        l_balance(l_bs_valid_rec_count),
                        l_previous_balance(l_bs_valid_rec_count),
                        l_bill_location_url(l_bs_valid_rec_count),
                        l_due_now(l_bs_valid_rec_count),
                        l_attribute_category(l_bs_valid_rec_count),
                        l_attribute1(l_bs_valid_rec_count),
                        l_attribute2(l_bs_valid_rec_count),
                        l_attribute3(l_bs_valid_rec_count),
                        l_attribute4(l_bs_valid_rec_count),
                        l_attribute5(l_bs_valid_rec_count),
                        l_attribute6(l_bs_valid_rec_count),
                        l_attribute7(l_bs_valid_rec_count),
                        l_attribute8(l_bs_valid_rec_count),
                        l_attribute9(l_bs_valid_rec_count),
                        l_attribute10(l_bs_valid_rec_count),
                        l_attribute11(l_bs_valid_rec_count),
                        l_attribute12(l_bs_valid_rec_count),
                        l_attribute13(l_bs_valid_rec_count),
                        l_attribute14(l_bs_valid_rec_count),
                        l_attribute15(l_bs_valid_rec_count)
                                                    ;

                    if (c_check_uniq_constrain%NOTFOUND ) then
					   raise no_data_found;
                    end if;
				exception
					when no_data_found then
		                l_bs_valid_rec_flag := 'F';  -- validity is false
                        l_bs_valid_rec_count := l_bs_valid_rec_count - 1;
		                x_return_status := FND_API.G_RET_STS_ERROR;
		                fnd_message.SET_NAME('XNB','XNB_PLS_BILL_SUM_REC_UNQ');
		                fnd_message.SET_TOKEN('ACC_NUM',t_acc_num);
		                fnd_message.SET_TOKEN('BILL_NUM',t_bill_num);
		                fnd_message.SET_TOKEN('BILL_VEN',t_bill_vendor);
		                x_msg_data := x_msg_data || '  '  || fnd_message.GET;
				end;
            close c_check_uniq_constrain;

           -- If the bill summary record is valid
            IF l_bs_valid_rec_flag = 'T' THEN

                l_account_number(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ACCOUNT_NUMBER;
                l_bill_number(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_NUMBER;
                l_billing_vendor_name(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILLING_VENDOR_NAME;
                IF (p_bill_summaries(i).TOTAL_AMOUNT_DUE IS NOT NULL) THEN
                    l_total_amount_due(l_bs_valid_rec_count) :=	  p_bill_summaries(i).TOTAL_AMOUNT_DUE;
                END IF;
                IF (p_bill_summaries(i).ADJUSTMENTS IS NOT NULL) THEN
                    l_adjustments(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ADJUSTMENTS;
                END IF;
                IF (p_bill_summaries(i).UNRESOLVED_DISPUTES IS NOT NULL) THEN
                    l_unresolved_disputes(l_bs_valid_rec_count) :=	  p_bill_summaries(i).UNRESOLVED_DISPUTES;
                END IF;
                IF (p_bill_summaries(i).BILL_CYCLE_START_DATE IS NOT NULL) THEN
                    l_bill_cycle_start_date(l_bs_valid_rec_count) := p_bill_summaries(i).BILL_CYCLE_START_DATE;
                END IF;
                IF (p_bill_summaries(i).BILL_CYCLE_END_DATE IS NOT NULL) THEN
                    l_bill_cycle_end_date(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_CYCLE_END_DATE;
                END IF;
                IF (p_bill_summaries(i).DUE_DATE IS NOT NULL) THEN
                    l_due_date(l_bs_valid_rec_count) :=	  p_bill_summaries(i).DUE_DATE;
                END IF;
                IF ( p_bill_summaries(i).NEW_CHARGES IS NOT NULL) THEN
                    l_new_charges(l_bs_valid_rec_count) :=	  p_bill_summaries(i).NEW_CHARGES;
                END IF;
                IF (p_bill_summaries(i).PAYMENT IS NOT NULL) THEN
                    l_payment(l_bs_valid_rec_count) :=	  p_bill_summaries(i).PAYMENT;
                END IF;
                IF (p_bill_summaries(i).BALANCE IS NOT NULL) THEN
                    l_balance(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BALANCE;
                END IF;
                IF (p_bill_summaries(i).PREVIOUS_BALANCE IS NOT NULL) THEN
                    l_previous_balance(l_bs_valid_rec_count) :=	  p_bill_summaries(i).PREVIOUS_BALANCE;
                END IF;
                IF (p_bill_summaries(i).BILL_LOCATION_URL IS NOT NULL) THEN
                    l_bill_location_url(l_bs_valid_rec_count) :=	  p_bill_summaries(i).BILL_LOCATION_URL;
                END IF;
                IF ( p_bill_summaries(i).DUE_NOW IS NOT NULL) THEN
                    l_due_now(l_bs_valid_rec_count) :=	  p_bill_summaries(i).DUE_NOW;
                END IF;

                IF (p_bill_summaries(i).LAST_UPDATED_BY IS NULL) THEN
                    l_last_updated_by(l_bs_valid_rec_count) := FND_GLOBAL.USER_ID;
                ELSE
                    l_last_updated_by(l_bs_valid_rec_count) := p_bill_summaries(i).LAST_UPDATED_BY;
                END IF;

                l_last_update_date(l_bs_valid_rec_count) :=	  SYSDATE;

                IF (p_bill_summaries(i).LAST_UPDATE_LOGIN IS NULL) THEN
                    l_last_update_login(l_bs_valid_rec_count) := FND_GLOBAL.LOGIN_ID;
                ELSE
                    l_last_update_login(l_bs_valid_rec_count) := p_bill_summaries(i).LAST_UPDATE_LOGIN;
                END IF;

                IF (p_bill_summaries(i).ATTRIBUTE_CATEGORY IS NOT NULL) THEN
                    l_attribute_category(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE_CATEGORY;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE1 IS NOT NULL) THEN
                    l_attribute1(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE1;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE2 IS NOT NULL) THEN
                    l_attribute2(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE2;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE3 IS NOT NULL) THEN
                    l_attribute3(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE3;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE4 IS NOT NULL) THEN
                    l_attribute4(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE4;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE5 IS NOT NULL) THEN
                    l_attribute5(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE5;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE6 IS NOT NULL) THEN
                    l_attribute6(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE6;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE7 IS NOT NULL) THEN
                    l_attribute7(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE7;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE8 IS NOT NULL) THEN
                    l_attribute8(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE8;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE9 IS NOT NULL) THEN
                    l_attribute9(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE9;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE10 IS NOT NULL) THEN
                    l_attribute10(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE10;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE11 IS NOT NULL) THEN
                    l_attribute11(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE11;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE12 IS NOT NULL) THEN
                    l_attribute12(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE12;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE13 IS NOT NULL) THEN
                    l_attribute13(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE13;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE14 IS NOT NULL) THEN
                    l_attribute14(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE14;
                END IF;
                IF (p_bill_summaries(i).ATTRIBUTE15 IS NOT NULL) THEN
                    l_attribute15(l_bs_valid_rec_count) :=	  p_bill_summaries(i).ATTRIBUTE15;
                END IF;
            END IF;

        END LOOP; -- End For loop

        -- batch update all valid records in database
        FORALL i IN 1..l_bs_valid_rec_count
              Update XNB_BILL_SUMMARIES
                SET
                      TOTAL_AMOUNT_DUE	    = l_total_amount_due(i),
                      ADJUSTMENTS		    = l_adjustments(i),
                      UNRESOLVED_DISPUTES	= l_unresolved_disputes(i),
                      BILL_CYCLE_START_DATE = l_bill_cycle_start_date(i),
                      BILL_CYCLE_END_DATE	= l_bill_cycle_end_date(i),
                      DUE_DATE			    = l_due_date(i),
                      NEW_CHARGES		    = l_new_charges(i),
                      PAYMENT			    = l_payment(i),
                      BALANCE			    = l_balance(i),
                      PREVIOUS_BALANCE	    = l_previous_balance(i),
                      BILL_LOCATION_URL	    = l_bill_location_url(i),
                      DUE_NOW			    = l_due_now(i),
                      LAST_UPDATED_BY		= l_last_updated_by(i),
                      LAST_UPDATE_DATE	    = SYSDATE,
                      LAST_UPDATE_LOGIN	    = l_last_update_login(i),
                      OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                      ATTRIBUTE_CATEGORY	= l_attribute_category(i),
                      ATTRIBUTE1		    = l_attribute1(i),
                      ATTRIBUTE2		    = l_attribute2(i),
                      ATTRIBUTE3		    = l_attribute3(i),
                      ATTRIBUTE4		    = l_attribute4(i),
                      ATTRIBUTE5		    = l_attribute5(i),
                      ATTRIBUTE6		    = l_attribute6(i),
                      ATTRIBUTE7		    = l_attribute7(i),
                      ATTRIBUTE8		    = l_attribute8(i),
                      ATTRIBUTE9		    = l_attribute9(i),
                      ATTRIBUTE10		    = l_attribute10(i),
                      ATTRIBUTE11		    = l_attribute11(i),
                      ATTRIBUTE12		    = l_attribute12(i),
                      ATTRIBUTE13		    = l_attribute13(i),
                      ATTRIBUTE14		    = l_attribute14(i),
                      ATTRIBUTE15		    = l_attribute15(i)
                where BILL_NUMBER = l_bill_number(i) and
                      ACCOUNT_NUMBER = l_account_number(i) and
					  BILLING_VENDOR_NAME = l_billing_vendor_name(i);

          --IF (SQL%NOTFOUND) THEN
                --RAISE NO_DATA_FOUND;
          --END IF;

          -- If Null bill number or account number or Billing Vendor Name throw error
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE null_excep;
          END IF;

          -- Handle all exceptions
          Exception
             -- Handle null exceptions
             WHEN null_excep THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_SUCC_UPD');

            WHEN NO_DATA_FOUND then
                ROLLBACK TO BULK_UPDATE;
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_ACC_BILL_NUM');

            --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
            --Change: The following exception section was added to trap API version check exceptions.
            --Other Files Impact: None.
            WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO BULK_UPDATE;
                FND_MESSAGE.SET_NAME('XNB','XNB_PLS_MSG_INCOMPAT_API');
                FND_MESSAGE.SET_TOKEN('API_FULL_NAME', G_PKG_NAME || '.' || l_api_name );
                FND_MESSAGE.SET_TOKEN('GIVEN_VER', p_api_version);
                FND_MESSAGE.SET_TOKEN('CURR_VER', l_api_version);
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := x_msg_data || ' ' || FND_MESSAGE.GET;

            WHEN OTHERS THEN
                ROLLBACK TO BULK_UPDATE;
                --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
                --Change: On OTHERS error, the public API should return G_RET_STS_UNEXP_ERROR. Corrected return code.
                --Other Files Impact: None.
                --x_return_status := FND_API.G_RET_STS_ERROR;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := x_msg_data || ' ' || SQLERRM || '  ' || fnd_message.GET_STRING('XNB','XNB_PLS_MSG_NO_REC_UPD');

    End Update_Row_Batch;


End XNB_BILL_SUMMARIES_PKG;

/
