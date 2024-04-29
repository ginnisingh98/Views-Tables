--------------------------------------------------------
--  DDL for Package Body OTA_COST_TRANSFER_TO_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_COST_TRANSFER_TO_GL_PKG" as
/* $Header: otactxgl.pkb 120.2 2008/01/23 12:31:08 pekasi noship $ */
/*================================================================*/
/*                    	  PACKAGE GLOBAL DECLARATIONS             */
/*================================================================*/

  v_conc_request_id  fnd_concurrent_requests.request_id%TYPE := -1;
  v_debug_msg                  VARCHAR2(2000);
  v_status                     VARCHAR2(80);
  v_err_num                    VARCHAR2(30) := '';
  v_err_msg                    VARCHAR2(1000) := '';
  v_return_boolean             BOOLEAN := FALSE;
  v_exception_message          VARCHAR2(240) := '';
  v_user_id  number := fnd_profile.value('USER_ID');
  v_login_id number := fnd_profile.value('LOGIN_ID');
  v_sob_id                     NUMBER;
  l_success                    VARCHAR2(1);
  l_err_num   VARCHAR2(30) := '';
  l_err_msg   VARCHAR2(1000) := '';

--
--
/*======================================================================+
|                 --- main procedure for insert_gl_line ---             |
|                                                                       |
*======================================================================*/
 Procedure otagls (p_user_id    in number,
                   p_login_id   in number) IS
   --
   --
   --
   --
  --  Local Variables
  --
    l_cost_center_error          EXCEPTION;
    l_finance_line_error         EXCEPTION;
    l_finance_header_error       EXCEPTION;
    l_amount                     ota_finance_lines.money_amount%TYPE;
  --  l_success                    VARCHAR2(1) := 'T';
    l_upd_header                 VARCHAR2(1);
    l_upd_line                   VARCHAR2(1);
    l_pay_desc         VARCHAR2(35) := 'ota_paying_cc_batch_generated';
    l_rec_desc         VARCHAR2(35) := 'ota_receiving_cc_batch_generated';
    l_value            fnd_profile_option_values.profile_option_value%TYPE;
    l_finance_header_id          OTA_FINANCE_HEADERS.FINANCE_HEADER_ID%type;
    l_exist   varchar2(1);
    l_single_business_group_id 	ota_delegate_bookings.business_group_id%type:=
							fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
    l_business_group_id  	ota_delegate_bookings.business_group_id%type:= null;

  ---*** New variables declared for Bug#2457158
    l_booking_id      ota_delegate_bookings.booking_id%TYPE;
    l_resource_booking_id      ota_resource_bookings.resource_booking_id%TYPE;


  CURSOR ota_fh_csr is
      select
         ofh.FINANCE_HEADER_ID,
         ofh.LAST_UPDATE_DATE,
         ofh.LAST_UPDATED_BY,
         ofh.CREATION_DATE,
         ofh.CREATED_BY,
         ofh.TRANSFER_DATE,
         ofh.OBJECT_VERSION_NUMBER,
         ofh.PAYMENT_STATUS_FLAG,
         ofh.TRANSFER_STATUS,
         ofh.TYPE,
         ofh.COMMENTS,
         ofh.EXTERNAL_REFERENCE,
         ofh.INVOICE_ADDRESS,
         ofh.INVOICE_CONTACT,
         ofh.PAYMENT_METHOD,
         ofh.PYM_ATTRIBUTE1,
         ofh.PYM_ATTRIBUTE10,
         ofh.PYM_ATTRIBUTE11,
         ofh.PYM_ATTRIBUTE12,
         ofh.PYM_ATTRIBUTE13,
         ofh.PYM_ATTRIBUTE14,
         ofh.PYM_ATTRIBUTE15,
         ofh.PYM_ATTRIBUTE16,
         ofh.PYM_ATTRIBUTE17,
         ofh.PYM_ATTRIBUTE18,
         ofh.PYM_ATTRIBUTE19,
         ofh.PYM_ATTRIBUTE2,
         ofh.PYM_ATTRIBUTE20,
         ofh.PYM_ATTRIBUTE3,
         ofh.PYM_ATTRIBUTE4,
         ofh.PYM_ATTRIBUTE5,
         ofh.PYM_ATTRIBUTE6,
         ofh.PYM_ATTRIBUTE7,
         ofh.PYM_ATTRIBUTE8,
         ofh.PYM_ATTRIBUTE9,
         ofh.PYM_INFORMATION_CATEGORY,
         ofh.RECEIVABLE_TYPE,
         ofh.TRANSFER_MESSAGE,
         ofh.VENDOR_ID,
         ofh.CONTACT_ID,
         ofh.TFH_INFORMATION_CATEGORY,
         ofh.TFH_INFORMATION1,
         ofh.TFH_INFORMATION2,
         ofh.TFH_INFORMATION3,
         ofh.TFH_INFORMATION4,
         ofh.TFH_INFORMATION5,
         ofh.TFH_INFORMATION6,
         ofh.TFH_INFORMATION7,
         ofh.TFH_INFORMATION8,
         ofh.TFH_INFORMATION9,
         ofh.TFH_INFORMATION10,
         ofh.TFH_INFORMATION11,
         ofh.TFH_INFORMATION12,
         ofh.TFH_INFORMATION13,
         ofh.TFH_INFORMATION14,
         ofh.TFH_INFORMATION15,
         ofh.TFH_INFORMATION16,
         ofh.TFH_INFORMATION17,
         ofh.TFH_INFORMATION18,
         ofh.TFH_INFORMATION19,
         ofh.TFH_INFORMATION20,
         ofh.PAYING_COST_CENTER,
         ofh.RECEIVING_COST_CENTER,
         ofh.CURRENCY_CODE,
         ofh.TRANSFER_FROM_SET_OF_BOOKS_ID,
         ofh.TRANSFER_TO_SET_OF_BOOKS_ID,
         ofh.FROM_SEGMENT1,
         ofh.FROM_SEGMENT2,
         ofh.FROM_SEGMENT3,
         ofh.FROM_SEGMENT4,
         ofh.FROM_SEGMENT5,
         ofh.FROM_SEGMENT6,
         ofh.FROM_SEGMENT7,
         ofh.FROM_SEGMENT8,
         ofh.FROM_SEGMENT9,
         ofh.FROM_SEGMENT10,
         ofh.FROM_SEGMENT11,
         ofh.FROM_SEGMENT12,
         ofh.FROM_SEGMENT13,
         ofh.FROM_SEGMENT14,
         ofh.FROM_SEGMENT15,
         ofh.FROM_SEGMENT16,
         ofh.FROM_SEGMENT17,
         ofh.FROM_SEGMENT18,
         ofh.FROM_SEGMENT19,
         ofh.FROM_SEGMENT20,
         ofh.FROM_SEGMENT21,
         ofh.FROM_SEGMENT22,
         ofh.FROM_SEGMENT23,
         ofh.FROM_SEGMENT24,
         ofh.FROM_SEGMENT25,
         ofh.FROM_SEGMENT26,
         ofh.FROM_SEGMENT27,
         ofh.FROM_SEGMENT28,
         ofh.FROM_SEGMENT29,
         ofh.FROM_SEGMENT30,
         ofh.TO_SEGMENT1,
         ofh.TO_SEGMENT2,
         ofh.TO_SEGMENT3,
         ofh.TO_SEGMENT4,
         ofh.TO_SEGMENT5,
         ofh.TO_SEGMENT6,
         ofh.TO_SEGMENT7,
         ofh.TO_SEGMENT8,
         ofh.TO_SEGMENT9,
         ofh.TO_SEGMENT10,
         ofh.TO_SEGMENT11,
         ofh.TO_SEGMENT12,
         ofh.TO_SEGMENT13,
         ofh.TO_SEGMENT14,
         ofh.TO_SEGMENT15,
         ofh.TO_SEGMENT16,
         ofh.TO_SEGMENT17,
         ofh.TO_SEGMENT18,
         ofh.TO_SEGMENT19,
         ofh.TO_SEGMENT20,
         ofh.TO_SEGMENT21,
         ofh.TO_SEGMENT22,
         ofh.TO_SEGMENT23,
         ofh.TO_SEGMENT24,
         ofh.TO_SEGMENT25,
         ofh.TO_SEGMENT26,
         ofh.TO_SEGMENT27,
         ofh.TO_SEGMENT28,
         ofh.TO_SEGMENT29,
         ofh.TO_SEGMENT30,
         ofh.TRANSFER_FROM_CC_ID,
         ofh.TRANSFER_TO_CC_ID
      FROM   ota_finance_headers ofh
      WHERE  ofh.TYPE    = 'CT'
      AND    ofh.TRANSFER_STATUS    = 'AT'
      AND    ofh.CANCELLED_FLAG   = 'N'
      ORDER BY
            ofh.finance_header_id,
      	    ofh.paying_cost_center,
      	    ofh.receiving_cost_center,
      	    ofh.currency_code ;
     -- FOR UPDATE;

/* Bug 3611693 Modified the cursor to take care of new Delivery Mode */
        CURSOR FL IS
         SELECT sum(fl.money_amount)
           FROM ota_finance_lines fl,
                ota_delegate_bookings tdb,
 		    ota_booking_status_types bst,
                ota_events evt,
		    ota_category_usages ocu,
                ota_offerings off
           WHERE fl.finance_header_id = l_finance_header_id and
                 tdb.booking_id = fl.booking_id and
                 bst.booking_status_type_id = tdb.booking_status_type_id  and
                 evt.event_id = tdb.event_id and
                 evt.price_basis <> 'N' and
                 evt.parent_offering_id = off.offering_id and
		     off.delivery_mode_id = ocu.category_usage_id and
                 (((ocu.synchronous_flag = 'Y' or (ocu.synchronous_flag = 'N' and
                     ocu.online_flag = 'N' ))  and
                  bst.type in ('A','C')) or
                  ( (ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                     off.learning_object_id is not null and
                      off.learning_object_id in (
                     select pfr.learning_object_id from ota_performances pfr
                     where
                      pfr.user_id= tdb.delegate_person_id and
                      pfr.user_type = 'E' and
                      pfr.lesson_status <> 'N') ) and
                  bst.type in ('A','C','P','E'))  or
                  ((ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                   off.learning_object_id is null and tdb.content_player_status is not null)
                   and bst.type in ('A','C','P','E')) )
                   and
                 fl.transfer_status = 'AT' and
                 fl.cancelled_flag = 'N' and
                 tdb.business_group_id = l_business_group_id;

---*** commented out the definition of FL_CHK cursor. New definition is added
---*** for the cursor FL_CHK for bug#2457158.
  /*       CURSOR FL_CHK IS
         SELECT null
           FROM ota_finance_lines fl,
                ota_delegate_bookings tdb,
 		    ota_booking_status_types bst,
                ota_events evt
           WHERE fl.finance_header_id = l_finance_header_id and
                 tdb.booking_id = fl.booking_id and
                 bst.booking_status_type_id = tdb.booking_status_type_id  and
                 evt.event_id = tdb.event_id and
                 evt.price_basis <> 'N' and
                 ((evt.offering_id is null and
                  bst.type not in ('A','C')) or
                  (evt.offering_id is not null and
                  bst.type not in ('A','C','P','E')))
                 and
                 fl.transfer_status = 'AT' and
                 fl.cancelled_flag = 'Y' and
                 tdb.business_group_id = l_business_group_id; */

         /* bug no 3611693  Modified the cursor to take care of delivery mode*/
	CURSOR FL_CHK IS
	SELECT null
           FROM ota_finance_lines fl,
                ota_delegate_bookings tdb,
       		ota_booking_status_types bst,
                ota_events evt,
		ota_category_usages ocu,
                ota_offerings off
           WHERE fl.finance_header_id = l_finance_header_id and
                tdb.booking_id = fl.booking_id and
                bst.booking_status_type_id = tdb.booking_status_type_id  and
                evt.event_id = tdb.event_id and
		evt.parent_offering_id = off.offering_id and
		off.delivery_mode_id = ocu.category_usage_id and
                evt.price_basis <> 'N' and
                (((ocu.synchronous_flag = 'Y' or (ocu.synchronous_flag = 'N' and
                     ocu.online_flag = 'N' ))  and
                  bst.type not in ('A','C')) or
                  ( (ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                     off.learning_object_id is not null and
                      ((off.learning_object_id in (
                     select pfr.learning_object_id from ota_performances pfr
                     where
                      pfr.user_id= tdb.delegate_person_id and
                      pfr.user_type = 'E' and
                      pfr.lesson_status = 'N')) or
                      ( off.learning_object_id not in(
                     select pfr.learning_object_id from ota_performances pfr
                     where
                      pfr.user_id= tdb.delegate_person_id and
                      pfr.user_type = 'E')))) and
                  bst.type in ('A','C','P','W','R','E'))  or
                  ((ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                   off.learning_object_id is null and tdb.content_player_status is null)
                   and bst.type in ('A','C','P','W','R','E')) )    and
                fl.transfer_status = 'AT' and
                fl.cancelled_flag = 'N' and
             	tdb.business_group_id = l_business_group_id;
/* bug no 3611693 */

         CURSOR FH_LOCK
           IS
           SELECT Finance_header_id
           FROM ota_finance_headers
           WHERE Finance_header_id = l_finance_header_id
           FOR UPDATE;

  ---*** Added FL_RESOURCE ,FL_CHECK and CHK_ENR_RES Cursor definitions --Bug#2457158

          CURSOR FL_RESOURCE IS
               SELECT  sum(fl.money_amount)
                 FROM ota_finance_lines fl,
                      ota_resource_bookings trb,
                      ota_suppliable_resources tsr
                 WHERE fl.finance_header_id = l_finance_header_id and
                       trb.resource_booking_id = fl.resource_booking_id and
                       trb.required_date_to < (trunc(SYSDATE)+1) and
                       tsr.supplied_resource_id = trb.supplied_resource_id and
                       trb.status = 'C' and
                       fl.transfer_status = 'AT' and
                       fl.cancelled_flag = 'N' and
                       tsr.business_group_id = l_business_group_id;

          CURSOR FL_CHECK IS
           SELECT null
            FROM   ota_finance_lines fl
            WHERE  fl.finance_header_id = l_finance_header_id and
                   fl.resource_booking_id is not null and
                   fl.cancelled_flag = 'N';

         CURSOR chk_Enr_Res(p_finance_header_id ota_finance_headers.finance_header_id%TYPE)
         IS
         SELECT count(booking_id),
                count(resource_booking_id)
         FROM ota_finance_lines
         WHERE finance_header_id=p_finance_header_id and
               cancelled_flag = 'N'
         GROUP BY finance_header_id;




  BEGIN

  IF l_single_business_group_id is not null then
     l_business_group_id := l_single_business_group_id;
  ELSE
     l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
  END IF;

    --
    --
    -- Get Set of Books ID
    --
   /*    FND_PROFILE.GET('GL_SET_OF_BOOKS_ID', l_value); */
       v_sob_id  := nvl(to_number(l_value),0);
    --
    --
  /*======================================================================+
  | Create GL Lines for each OTA Finance Header and Finance Lines         |
  |                                                                       |
  *======================================================================*/
  --
  -- Main Loop for ota_finance_headers table
  --
  FOR ota_fh_row IN ota_fh_csr
    LOOP
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering Finance Header :'
            ||to_char(ota_fh_row.finance_header_id));

      l_success := 'T';
     --
     -- Loop to sum money amount for paying_cost_center
     -- and receiving_cost_center
     --
         l_finance_header_id := ota_fh_row.finance_header_id;


    -- To lock the row explicitly
 	for ota_fh_lock IN fh_lock
         LOOP
            null;
         END LOOP;




    BEGIN
     SAVEPOINT GL_TRANSFER;
     if fl_chk%ISOPEN then
        close fl_chk;
     end if;

     if fl%ISOPEN then
        close fl;
     end if;
  ---*** added for Bug#2457158
     l_amount := NULL;
     l_booking_id := 0;
     l_resource_booking_id := 0;
     IF chk_Enr_Res%ISOPEN THEN
       CLOSE  chk_Enr_Res;
     END IF;

     OPEN chk_Enr_Res(l_finance_header_id);
     FETCH chk_Enr_Res INTO l_booking_id, l_resource_booking_id;
     CLOSE chk_Enr_Res;

IF l_booking_id <> 0 and l_resource_booking_id = 0 THEN

   OPEN fl_chk;
   FETCH fl_chk INTO l_exist;
   IF fl_chk%notfound then          --bug no 3611693 ---*** replaced %notfound with %found for Bug#2457158

     OPEN fl;
     FETCH fl INTO l_amount;
     IF fl%found then
      If (l_amount is not null or l_amount > 0 ) then


     --
         if ota_fh_row.paying_cost_center is null then
            l_amount := 0;
         end if;
     --
      if ota_fh_row.paying_cost_center is not null then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into GL interface table for Paying cost center:' || ','
            ||ota_fh_row.paying_cost_center);
         ota_tfh_api_shd.lck(ota_fh_row.finance_header_id,ota_fh_row.object_version_number);  ---*** Bug#2820365
         l_success  := otagli (ota_fh_row.finance_header_id,
                           ota_fh_row.paying_cost_center,
                           ota_fh_row.Transfer_from_set_of_books_id,
                           l_amount,
                           0,
                           ota_fh_row.currency_code,
                           l_pay_desc,
 				   ota_fh_row.transfer_from_cc_id);
     --
     --
         if l_success = 'F' then
            RAISE l_cost_center_error;
         end if;


     --
         if ota_fh_row.receiving_cost_center is not null then
            if l_amount is null then
               l_amount := 0;
            end if;

     --
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into GL interface table for Recieving cost center,'
            ||ota_fh_row.receiving_cost_center);
            ota_tfh_api_shd.lck(ota_fh_row.finance_header_id,ota_fh_row.object_version_number);    ---*** Bug#2820365
            l_success  := otagli (ota_fh_row.finance_header_id,
                           ota_fh_row.receiving_cost_center,
                           ota_fh_row.Transfer_to_set_of_books_id,
                           0,
                           l_amount,
                           ota_fh_row.currency_code,
                           l_rec_desc,
				   ota_fh_row.transfer_to_cc_id);
     --
     --
            if l_success = 'F' then
               RAISE l_cost_center_error;
            end if;

          end if;
     --
     --
      l_upd_line := upd_ota_line (ota_fh_row.finance_header_id);
     --
      if l_upd_line = 'F' then
         RAISE l_finance_line_error;
      end if;



	     l_upd_header := upd_ota_header (ota_fh_row.finance_header_id,
                                     ota_fh_row.object_version_number);
     --
     	 if l_upd_header = 'F' then
        	 RAISE l_finance_header_error;
	 end if;


     --
     else
     FND_FILE.PUT_LINE(FND_FILE.LOG,'This Finance Header' || ','
           ||to_char(ota_fh_row.finance_header_id)||' doesnot have paying cost center'  );

    end if;
   end if;
  end if;
  CLOSE fl;

    IF l_success = 'F' then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Rollback for :'
            ||to_char(ota_fh_row.finance_header_id));
       ROLLBACK TO GL_TRANSFER;
    ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Commiting for :'
            ||to_char(ota_fh_row.finance_header_id));
       COMMIT;
    END IF;
 end if;
 CLOSE fl_chk;
----------------------------*** Code (start) added for Bug#2457158 ***------------------
ELSIF l_booking_id = 0 and l_resource_booking_id <> 0 THEN
 if fl_check%ISOPEN then
        close fl_check;
     end if;

     if fl_resource%ISOPEN then
        close fl_resource;
     end if;

  OPEN fl_check;
   FETCH fl_check INTO l_exist;
   IF fl_check%found then
     OPEN fl_resource;
     FETCH fl_resource INTO l_amount;


     IF fl_resource%found then
      If l_amount is not null or l_amount > 0 then
     --
         if ota_fh_row.paying_cost_center is null then
            l_amount := 0;
         end if;
     --
      if ota_fh_row.paying_cost_center is not null then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into GL interface table for Paying cost center:' || ','
            ||ota_fh_row.paying_cost_center);
         ota_tfh_api_shd.lck(ota_fh_row.finance_header_id,ota_fh_row.object_version_number);  ---*** Bug#2820365
         l_success  := otagli (ota_fh_row.finance_header_id,
                           ota_fh_row.paying_cost_center,
                           ota_fh_row.Transfer_from_set_of_books_id,
                           l_amount,
                           0,
                           ota_fh_row.currency_code,
                           l_pay_desc,
 				   ota_fh_row.transfer_from_cc_id);
     --
     --
         if l_success = 'F' then
            RAISE l_cost_center_error;
         end if;


     --
         if ota_fh_row.receiving_cost_center is not null then
            if l_amount is null then
               l_amount := 0;
            end if;

     --
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into GL interface table for Recieving cost center,'
            ||ota_fh_row.receiving_cost_center);
            ota_tfh_api_shd.lck(ota_fh_row.finance_header_id,ota_fh_row.object_version_number);    ---*** Bug#2820365
            l_success  := otagli (ota_fh_row.finance_header_id,
                           ota_fh_row.receiving_cost_center,
                           ota_fh_row.Transfer_to_set_of_books_id,
                           0,
                           l_amount,
                           ota_fh_row.currency_code,
                           l_rec_desc,
				   ota_fh_row.transfer_to_cc_id);
     --
     --
            if l_success = 'F' then
               RAISE l_cost_center_error;
            end if;

          end if;
     --
     --
      l_upd_line := upd_ota_line (ota_fh_row.finance_header_id);
     --
      if l_upd_line = 'F' then
         RAISE l_finance_line_error;
      end if;


      l_upd_header := upd_ota_header (ota_fh_row.finance_header_id,
                                     ota_fh_row.object_version_number);
     --
      if l_upd_header = 'F' then
         RAISE l_finance_header_error;
      end if;

     --
     else
     FND_FILE.PUT_LINE(FND_FILE.LOG,'This Finance Header' || ','
           ||to_char(ota_fh_row.finance_header_id)||' doesnot have paying cost center'  );

    end if;
   end if;
  end if;
  CLOSE fl_resource;

    IF l_success = 'F' then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Rollback for :'
            ||to_char(ota_fh_row.finance_header_id));
       ROLLBACK TO GL_TRANSFER;
    ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Commiting for :'
            ||to_char(ota_fh_row.finance_header_id));
       COMMIT;
    END IF;

 end if;
 CLOSE fl_check;

 ELSIF l_booking_id <> 0 and l_resource_booking_id <> 0 THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG,'This Finance Header ' ||to_char(ota_fh_row.finance_header_id)||
    ' has not transferred to GL because it includes ');

FND_FILE.PUT_LINE(FND_FILE.LOG,'both Enrollment and Resource Booking finance lines. You must submit ');

FND_FILE.PUT_LINE(FND_FILE.LOG,'Resource Booking and Enrollment lines under separate finance headers.');

end if;
----------------------------*** Code (end  ) added for Bug#2457158 ***------------------

    EXCEPTION
        WHEN l_finance_header_error then
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in Updating Finance header' || ','
           ||to_char(ota_fh_row.finance_header_id)||','||  l_err_msg);

   --   fnd_message.raise_error;
        ROLLBACK TO GL_TRANSFER;
   WHEN l_finance_line_error then
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in Updating Finance line for header ' || ','
            ||to_char(ota_fh_row.finance_header_id)||','||  l_err_msg);

 --     fnd_message.raise_error;
        ROLLBACK TO GL_TRANSFER;
    WHEN l_cost_center_error then
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in creating GL ' || ','
         ||to_char(ota_fh_row.finance_header_id) ||','|| l_err_msg);

 --     fnd_message.raise_error;
        ROLLBACK TO GL_TRANSFER;
    WHEN OTHERS then
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'When Others Error occured in ' || ','
         ||to_char(ota_fh_row.finance_header_id)||','||l_err_msg);

  --    fnd_message.raise_error;

    ROLLBACK TO GL_TRANSFER;

    END;

    END LOOP;  /* This is to close OTA Finance Header cursor loop */
     --
  --  COMMIT;
     --
   EXCEPTION

     WHEN l_cost_center_error THEN

             if ota_fh_csr%ISOPEN then
               close ota_fh_csr;
             end if;

             --
      v_err_num := SQLCODE;
      v_err_msg := SUBSTR(SQLERRM, 1, 100);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'L_Cost_Center_error occured:' || ','
         ||v_err_msg);
      --
      --
   --   fnd_message.raise_error;
      --
      --
    --  ROLLBACK;



      WHEN OTHERS THEN

             if ota_fh_csr%ISOPEN then
               close ota_fh_csr;
             end if;

             --
      v_err_num := SQLCODE;
      v_err_msg := SUBSTR(SQLERRM, 1, 100);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'When Others Error occured : ' || ','
         ||v_err_msg);
      --
      --
 --     fnd_message.raise_error;
      --
      --
    --  ROLLBACK;
  --
  --
 END otagls;
--

 FUNCTION otagli (p_finance_header_id   in number,
                  p_code_combination_id in varchar2,
                  p_set_of_books_id     in number,
                  p_debited_amount      in number,
                  p_credited_amount     in number,
                  p_currency_code       in varchar2,
                  p_desc                in varchar2,
			p_cc_id               in number
) RETURN VARCHAR2 IS

   -- l_success   VARCHAR2(1) := 'T';

 --
 -- Insert to gl interface
 --
   BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting in Insert to GL interface ');
    --
     INSERT INTO gl_interface
                            (STATUS
                            ,LEDGER_ID  -- Bug#6763652
                            ,SET_OF_BOOKS_ID
                            ,ACCOUNTING_DATE
                            ,CURRENCY_CODE
                            ,DATE_CREATED
                            ,CREATED_BY
                            ,ACTUAL_FLAG
                            ,USER_JE_CATEGORY_NAME
                            ,USER_JE_SOURCE_NAME
                            ,CURRENCY_CONVERSION_DATE
                            ,ENCUMBRANCE_TYPE_ID
                            ,BUDGET_VERSION_ID
                            ,USER_CURRENCY_CONVERSION_TYPE
                            ,CURRENCY_CONVERSION_RATE
                            ,SEGMENT1
                            ,SEGMENT2
                            ,SEGMENT3
                            ,SEGMENT4
                            ,SEGMENT5
                            ,SEGMENT6
                            ,SEGMENT7
                            ,SEGMENT8
                            ,SEGMENT9
                            ,SEGMENT10
                            ,SEGMENT11
                            ,SEGMENT12
                            ,SEGMENT13
                            ,SEGMENT14
                            ,SEGMENT15
                            ,SEGMENT16
                            ,SEGMENT17
                            ,SEGMENT18
                            ,SEGMENT19
                            ,SEGMENT20
                            ,SEGMENT21
                            ,SEGMENT22
                            ,SEGMENT23
                            ,SEGMENT24
                            ,SEGMENT25
                            ,SEGMENT26
                            ,SEGMENT27
                            ,SEGMENT28
                            ,SEGMENT29
                            ,SEGMENT30
                            ,ENTERED_DR
                            ,ENTERED_CR
                            ,ACCOUNTED_DR
                            ,ACCOUNTED_CR
                            ,TRANSACTION_DATE
                            ,REFERENCE1
                            ,REFERENCE2
                            ,REFERENCE3
                            ,REFERENCE4
                            ,REFERENCE5
                            ,REFERENCE6
                            ,REFERENCE7
                            ,REFERENCE8
                            ,REFERENCE9
                            ,REFERENCE10
                            ,REFERENCE11
                            ,REFERENCE12
                            ,REFERENCE13
                            ,REFERENCE14
                            ,REFERENCE15
                            ,REFERENCE16
                            ,REFERENCE17
                            ,REFERENCE18
                            ,REFERENCE19
                            ,REFERENCE20
                            ,REFERENCE21
                            ,REFERENCE22
                            ,REFERENCE23
                            ,REFERENCE24
                            ,REFERENCE25
                            ,REFERENCE26
                            ,REFERENCE27
                            ,REFERENCE28
                            ,REFERENCE29
                            ,REFERENCE30
                            ,JE_BATCH_ID
                            ,PERIOD_NAME
                            ,JE_HEADER_ID
                            ,JE_LINE_NUM
                            ,CHART_OF_ACCOUNTS_ID
                            ,FUNCTIONAL_CURRENCY_CODE
                            ,CODE_COMBINATION_ID
                            ,DATE_CREATED_IN_GL
                            ,WARNING_CODE
                            ,STATUS_DESCRIPTION
                            ,STAT_AMOUNT
                            ,GROUP_ID
                            ,REQUEST_ID
                            ,SUBLEDGER_DOC_SEQUENCE_ID
                            ,SUBLEDGER_DOC_SEQUENCE_VALUE
                            ,ATTRIBUTE1
                            ,ATTRIBUTE2
                            ,ATTRIBUTE3
                            ,ATTRIBUTE4
                            ,ATTRIBUTE5
                            ,ATTRIBUTE6
                            ,ATTRIBUTE7
                            ,ATTRIBUTE8
                            ,ATTRIBUTE9
                            ,ATTRIBUTE10
                            ,ATTRIBUTE11
                            ,ATTRIBUTE12
                            ,ATTRIBUTE13
                            ,ATTRIBUTE14
                            ,ATTRIBUTE15
                            ,ATTRIBUTE16
                            ,ATTRIBUTE17
                            ,ATTRIBUTE18
                            ,ATTRIBUTE19
                            ,ATTRIBUTE20
                            ,CONTEXT
                            ,CONTEXT2
                            ,INVOICE_DATE
                            ,TAX_CODE
                            ,INVOICE_IDENTIFIER
                            ,INVOICE_AMOUNT
                            ,CONTEXT3
                            ,USSGL_TRANSACTION_CODE
                            ,DESCR_FLEX_ERROR_MESSAGE
                            )
     VALUES
      (
    'NEW',                    -- STATUS          --required
     p_set_of_books_id,       -- LEDGER_ID - new column added in R12 Bug#6763652
     p_set_of_books_id,       -- SET_OF_BOOKS_ID --required
     SYSDATE,                 -- ACCOUNTING_DATE --required
     p_currency_code,         -- CURRENCY_CODE   --required
     SYSDATE,                 -- DATE_CREATED    --required
     v_login_id,              -- CREATED_BY      --required
     'A',                     -- ACTUAL_FLAG     --required
     'Transfer',              -- USER_JE_CATEGORY_NAME --required
     'Transfer',              -- USER_JE_SOURCE_NAME   --required
     NULL,                           -- CURRENCY_CONVERSION_DATE
     NULL,                           -- ENCUMBRANCE_TYPE_ID
     NULL,                           -- BUDGET_VERSION_ID
     NULL,                           -- USER_CURRENCY_CONVERSION_TYPE
     NULL,                           -- CURRENCY_CONVERSION_RATE
     NULL,					 -- SEGMENT1
     NULL,                           -- SEGMENT2
     NULL,                           -- SEGMENT3
     NULL,                           -- SEGMENT4
     NULL,                           -- SEGMENT5
     NULL,                           -- SEGMENT6
     NULL,                           -- SEGMENT7
     NULL,                           -- SEGMENT8
     NULL,                           -- SEGMENT9
     NULL,                           -- SEGMENT10
     NULL,                           -- SEGMENT11
     NULL,                           -- SEGMENT12
     NULL,                           -- SEGMENT13
     NULL,                           -- SEGMENT14
     NULL,                           -- SEGMENT15
     NULL,                           -- SEGMENT16
     NULL,                           -- SEGMENT17
     NULL,                           -- SEGMENT18
     NULL,                           -- SEGMENT19
     NULL,                           -- SEGMENT20
     NULL,                           -- SEGMENT21
     NULL,                           -- SEGMENT22
     NULL,                           -- SEGMENT23
     NULL,                           -- SEGMENT24
     NULL,                           -- SEGMENT25
     NULL,                           -- SEGMENT26
     NULL,                           -- SEGMENT27
     NULL,                           -- SEGMENT28
     NULL,                           -- SEGMENT29
     NULL,                           -- SEGMENT30
     p_debited_amount,               -- ENTERED_DR
     p_credited_amount,              -- ENTERED_CR
     NULL,                           -- ACCOUNTED_DR
     NULL,                           -- ACCOUNTED_CR
     NULL,                           -- TRANSACTION_DATE-required NULL by JI
     'OTA_GL_BATCH',       		 -- REFERENCE1-batch name ** JTH Previous Value NULL
     'Cross Charge Transfer to GL',  -- REFERENCE2-batch desc
     NULL,                           -- required NULL by JI
     'Cost Transfer',        		 -- REFERENCE4-JE name   ** JTH Previous Value NULL
     NULL,                           -- REFERENCE5-JE desc
     NULL,                           -- REFERENCE6-JE ref
     NULL,                           -- REFERENCE7-JE Reversal period
     NULL,                           -- REFERENCE8-JE line desc
     NULL,                           -- required NULL by JI
     p_desc,                         --REFERENCE10-JE line desc
     NULL,                           -- REFERENCE11-required NULL by JI
     NULL,                           -- REFERENCE12-required NULL by JI
     NULL,                           -- REFERENCE13-required NULL by JI
     NULL,                           -- REFERENCE14-required NULL by JI
     NULL,                           -- REFERENCE15-required NULL by JI
     NULL,                           -- REFERENCE16-required NULL by JI
     NULL,                           -- REFERENCE17-required NULL by JI
     NULL,                           -- REFERENCE18-required NULL by JI
     NULL,                           -- REFERENCE19-required NULL by JI
     NULL,                           -- REFERENCE20-required NULL by JI
     NULL,                           -- REFERENCE21
     NULL,                           -- REFERENCE22
     NULL,                           -- REFERENCE23
     NULL,                           -- REFERENCE24
     NULL,                           -- REFERENCE25
     NULL,                           -- REFERENCE26
     NULL,                           -- REFERENCE27
     NULL,                           -- REFERENCE28
     NULL,                           -- REFERENCE29
     to_char(p_finance_header_id),            -- REFERENCE30
     NULL,                           -- JE_BATCH_ID-required NULL by JI
     NULL,    -- PERIOD_NAME-enter value only if ACTUAL_FLAG = 'B' (Budget Data)
     NULL,                      -- JE_HEADER_ID-required NULL by JI
     NULL,                      -- JE_LINE_NUM-required NULL by JI
     NULL,                      -- CHART_OF_ACCOUNTS_ID-required NULL by JI
     NULL,                      -- FUNCTIONAL_CURRENCY_CODE-required NULL by JI
     p_cc_id, 			   -- CODE_COMBINATION_ID
     NULL,    -- DATE_CREATED_IN_GL-required NULL by JI
     NULL,                           -- WARNING_CODE-required NULL by JI
     NULL,                           -- STATUS_DESCRIPTION-required NULL by JI
     NULL,                           -- STAT_AMOUNT
     NULL,                           -- GROUP_ID
     NULL,                           -- REQUEST_ID-required NULL by JI
     NULL,                  -- SUBLEDGER_DOC_SEQUENCE_ID-required NULL by JI
     NULL,                  -- SUBLEDGER_DOC_SEQUENCE_VALUE-required NULL by JI
     NULL,              -- ATTRIBUTE1
     NULL,              -- ATTRIBUTE2
     NULL,              -- ATTRIBUTE3
     NULL,              -- ATTRIBUTE4
     NULL,              -- ATTRIBUTE5
     NULL,              -- ATTRIBUTE6
     NULL,              -- ATTRIBUTE7
     NULL,              -- ATTRIBUTE8
     NULL,              -- ATTRIBUTE9
     NULL,              -- ATTRIBUTE10
     NULL,              -- ATTRIBUTE11
     NULL,              -- ATTRIBUTE12
     NULL,              -- ATTRIBUTE13
     NULL,              -- ATTRIBUTE14
     NULL,              -- ATTRIBUTE15
     NULL,              -- ATTRIBUTE16
     NULL,              -- ATTRIBUTE17
     NULL,              -- ATTRIBUTE18
     NULL,              -- ATTRIBUTE19
     NULL,              -- ATTRIBUTE20
     NULL,              -- CONTEXT
     NULL,              -- CONTEXT2
     NULL,              -- INVOICE_DATE
     NULL,              -- TAX_CODE
     NULL,              -- INVOICE_IDENTIFIER
     NULL,              -- INVOICE_AMOUNT
     NULL,              -- CONTEXT3
     NULL,              -- USSGL_TRANSACTION_CODE
     NULL               -- DESCR_FLEX_ERROR_MESSAGE-required NULL by JI
    );
    --
    --
       return(l_success);

      EXCEPTION
       WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);
    --
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in Inserting into GL interface '||' '||
		to_char(p_finance_header_id)||','||l_err_msg);

        l_success := 'F';
        return(l_success);
    --
   END otagli;
    --
    -- Update OTA Finance Headers for Cost Transfer
    --

-- ----------------------------------------------------------------------------
-- |---------------------------------< Upd_ota_header  >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  will be used to update finance header information.
--
--   This function can be only called by  otagls procedure.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_finance_header_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
FUNCTION upd_ota_header (p_finance_header_id in number,
                         p_object_version_number in number)
RETURN VARCHAR2 AS
 l_upd_header VARCHAR2(1);
 l_object_version_number  number(15);

 BEGIN

    l_object_version_number := p_object_version_number;

      /*ota_tfh_api_upd.upd( p_finance_header_id 	      =>    p_finance_header_id
		    		  ,p_object_version_number    => l_object_version_number
		    		  ,p_transfer_status	      => 'ST'
           			  ,p_external_reference       => 'OTA_GL_BATCH'
                          ,p_transfer_date         	=> SYSDATE
		     		  ,p_validate			=> False
		     		  ,p_Transaction_type		=> 'UPDATE'); */

      UPDATE  ota_finance_headers
      SET  last_update_date       = SYSDATE
          ,last_updated_by        = v_user_id
          ,last_update_login      = v_login_id
          ,transfer_status        = 'ST'
          ,external_reference     = 'OTA_GL_BATCH'
          ,transfer_date          = SYSDATE
      WHERE    finance_header_id    = p_finance_header_id;
    --
    l_upd_header := 'T';
    return(l_upd_header);
    --
    --
    EXCEPTION
      WHEN OTHERS THEN
    --
    --
      l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 100);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' ||
                       'Updating finance header'||' '||
		           to_char(p_finance_header_id)||','||l_err_msg);
      l_success := 'F';
           --
      l_upd_header := 'F';
      return(l_upd_header);

    END upd_ota_header ;

-- ----------------------------------------------------------------------------
-- |---------------------------------< Upd_ota_line  >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  will be used to update finance lines information.
--
--   This function can be only called by  otagls procedure.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_finance_header_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

 FUNCTION upd_ota_line (p_finance_header_id in number) RETURN VARCHAR2 AS
   l_upd_line VARCHAR2(1);
   l_line_ovn   number(9);
   l_date_raised  date;
   l_sequence_number  number(15);
   --
     /* CURSOR fh IS
        SELECT finance_line_id,
               object_version_number,
               date_raised,
               sequence_number
         FROM ota_finance_lines
      WHERE finance_header_id = p_finance_header_id and
                 booking_id  in (Select Booking_id
 					   from  OTA_DELEGATE_BOOKINGS
 					   WHERE booking_status_type_id in
                                 (Select Booking_status_type_id
                                  FROM OTA_BOOKING_STATUS_TYPES
					    WHERE Type = 'A')); */


/* Bug 3611693 Modified the cursor to take care of new Delivery Mode */

    CURSOR FL IS
         SELECT fl.finance_line_id,
               fl.object_version_number,
               fl.date_raised,
               fl.sequence_number
           FROM ota_finance_lines fl,
                ota_delegate_bookings tdb,
 		    ota_booking_status_types bst,
                ota_events evt,
		    ota_category_usages ocu,
                ota_offerings off
           WHERE fl.finance_header_id = p_finance_header_id and
                 tdb.booking_id = fl.booking_id and
                 bst.booking_status_type_id = tdb.booking_status_type_id  and
                 evt.event_id = tdb.event_id and
                 evt.price_basis <> 'N' and
                 evt.parent_offering_id = off.offering_id and
		     off.delivery_mode_id = ocu.category_usage_id and
                 (((ocu.synchronous_flag = 'Y' or (ocu.synchronous_flag = 'N' and
                     ocu.online_flag = 'N' ))  and
                  bst.type in ('A','C')) or
                  ( (ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                      off.learning_object_id is not null and
                      off.learning_object_id in (
                     select pfr.learning_object_id from ota_performances pfr
                     where
                      pfr.user_id= tdb.delegate_person_id and
                      pfr.user_type = 'E' and
                      pfr.lesson_status <> 'N') ) and
                  bst.type in ('A','C','P','E'))  or
                  ((ocu.synchronous_flag = 'N' and ocu.online_flag = 'Y' and
                   off.learning_object_id is null and tdb.content_player_status is not null)
                   and bst.type in ('A','C','P','E')) )
                   and
                 fl.transfer_status = 'AT' and
                 fl.cancelled_flag = 'N'
                FOR UPDATE OF fl.finance_line_id;




   ---*** Cursor FL_RESOURCE definition added for Bug#2457158
   CURSOR FL_RESOURCE IS
             SELECT  fl.finance_line_id,
                     fl.object_version_number,
                     fl.date_raised,
                     fl.sequence_number
                 FROM ota_finance_lines fl,
                      ota_resource_bookings trb
                 WHERE fl.finance_header_id = p_finance_header_id and
                       trb.resource_booking_id = fl.resource_booking_id and
                       trb.required_date_to < (trunc(SYSDATE)+1) and
                       trb.status = 'C' and
                       fl.transfer_status = 'AT' and
                       fl.cancelled_flag = 'N'
                 FOR UPDATE OF fl.finance_line_id;


   --
   BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting into Update Finance Line ');
   --
      FOR fl_rec IN fl LOOP
         l_date_raised := fl_rec.date_raised;
         l_sequence_number := fl_rec.sequence_number;
         l_line_ovn := fl_rec.object_version_number;

       /*  ota_tfl_api_upd.upd(
					p_finance_line_id 	=> fl_rec.finance_line_id,
					p_date_raised		=> l_date_raised,
					p_object_version_number => l_line_ovn,
					p_transfer_status		=> 'ST',
					p_sequence_number		=> l_sequence_number,
                              p_transfer_date         => sysdate,
					p_validate			=> false,
					p_transaction_type 	=> 'UPDATE'); */

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating Finance line: ' ||
		           to_char(fl_rec.finance_line_id));

      UPDATE  ota_finance_lines
        SET  last_update_date       = SYSDATE
            ,last_updated_by        = v_user_id
            ,last_update_login      = v_login_id
            ,transfer_status        = 'ST'
            ,transfer_date          = SYSDATE
        WHERE    finance_line_id = fl_rec.finance_line_id;

      END LOOP;
   --
   -------------------- *** Code (start) added for Bug#2457158 ***---------------
   FOR fl_rec IN fl_resource LOOP
         l_date_raised := fl_rec.date_raised;
         l_sequence_number := fl_rec.sequence_number;
         l_line_ovn := fl_rec.object_version_number;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating Finance line: ' ||
		           to_char(fl_rec.finance_line_id));

      UPDATE  ota_finance_lines
        SET  last_update_date       = SYSDATE
            ,last_updated_by        = v_user_id
            ,last_update_login      = v_login_id
            ,transfer_status        = 'ST'
            ,transfer_date          = SYSDATE
        WHERE    finance_line_id = fl_rec.finance_line_id;

      END LOOP;
   -------------------- *** Code (end  ) added for Bug#2457158 ***---------------
    l_upd_line := 'T';
    return(l_upd_line);
   --
   EXCEPTION
     WHEN OTHERS THEN
    --
    --
     l_err_num := SQLCODE;
     l_err_msg := SUBSTR(SQLERRM, 1, 100);
    --
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' ||
                     'Updating finance lines for header'||' '||
		           to_char(p_finance_header_id)||','||l_err_msg);

    --
     --
      l_success := 'F';
      l_upd_line := 'F';
      return(l_upd_line);
   --
   END upd_ota_line ;
--
--
--
END OTA_COST_TRANSFER_TO_GL_PKG;

/
