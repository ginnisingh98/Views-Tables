--------------------------------------------------------
--  DDL for Package Body OTA_ILEARNING2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ILEARNING2" as
/* $Header: otilnprf.pkb 115.4 2002/11/26 12:47:33 arkashya noship $ */
/*
  ===========================================================================
 |               Copyright (c) 1996 Oracle Corporation                       |
 |                       All rights reserved.                                |
  ===========================================================================
Name
        General Oracle iLearning utilities
Purpose
        To provide procedures/functions for iLearning integration
History
         15-Jan-02  115.0     HDSHAH           Created
         21-Feb-02  115.1     HDSHAH  2236928  Modified log messages.
                                          Used OTA_ILEARNING_DEFAULT_ATTENDED
					  profile instead of reading from cursor.
         27-Feb-02  115.2     DHMULIA 2242840  Modified upd_history to call
 					  ota_tfh_api_upd.upd instead of Finance line
					  api.
         28-Feb-02  115.3     HDSHAH  2246791  Need to lock record before calling update_enrollment procedure.
         26-nov-02  115.4    ARKASHYA 2684733  Included NOCOPY directive in the OUT and IN OUT parameters.
*/
--------------------------------------------------------------------------------
g_package  varchar2(33) := '  ota_ilearning2.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |---------------< create_or_update_activity_version >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description :  Update history  based on input data.

--
Procedure upd_history
  (
   p_person_id                in  number
  ,p_rco_id                   in  number
  ,p_isroot                   in  varchar2
  ,p_status                   in  varchar2
  ,p_score                    in  number
  ,p_time                     in  varchar2
  ,p_complete                 in  number
  ,p_total                    in  number
  ,p_business_group_id        in  number
  ,p_history_status           out nocopy varchar2
  ,p_message                  out nocopy varchar2
  ) is

l_proc                   varchar2(72) := g_package||'upd_history.';
l_booking_id             OTA_DELEGATE_BOOKINGS.BOOKING_ID%TYPE;
l_ovn                    OTA_DELEGATE_BOOKINGS.OBJECT_VERSION_NUMBER%TYPE;
l_finance_line_id        OTA_FINANCE_LINES.FINANCE_LINE_ID%TYPE;
l_tfl_finance_line_id    OTA_FINANCE_LINES.FINANCE_LINE_ID%TYPE;
l_sequence_number        OTA_FINANCE_LINES.SEQUENCE_NUMBER%TYPE;
l_fl_ovn                 OTA_FINANCE_LINES.OBJECT_VERSION_NUMBER%TYPE;
l_tfl_ovn                OTA_FINANCE_LINES.OBJECT_VERSION_NUMBER%TYPE;
l_date_raised            OTA_FINANCE_LINES.DATE_RAISED%TYPE;
l_booking_status_type_id OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID%TYPE;

l_cur_booking_status_type_id OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID%TYPE;
l_cur_content_player_status  OTA_DELEGATE_BOOKINGS.CONTENT_PLAYER_STATUS%TYPE;
l_cur_tdb_ovn            OTA_DELEGATE_BOOKINGS.OBJECT_VERSION_NUMBER%TYPE;
l_cur_event_id           OTA_DELEGATE_BOOKINGS.EVENT_ID%TYPE;
l_status_type            OTA_BOOKING_STATUS_TYPES.TYPE%type;
l_date_booking_placed    OTA_DELEGATE_BOOKINGS.DATE_BOOKING_PLACED%TYPE;
l_auto_transfer          varchar2(4) := FND_PROFILE.VALUE('OTA_SSHR_AUTO_GL_TRANSFER');
l_user_id                NUMBER := FND_PROFILE.VALUE('USER_ID');
l_finance_header_ovn     OTA_FINANCE_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
l_finance_header_id      OTA_FINANCE_HEADERS.FINANCE_HEADER_ID%TYPE;

cursor cur_get_booking_id is
     select
            max(booking_id) booking_id
     from
            ota_delegate_bookings TDB,
            ota_events            EVT,
            ota_activity_versions OAV
     where
            OAV.rco_id = p_rco_id                             and
            OAV.activity_version_id = EVT.activity_version_id and
            EVT.event_id = TDB.event_id                       and
            TDB.delegate_person_id = p_person_id              and
            TDB.business_group_id  = p_business_group_id;


cursor cur_get_tdb_details is
     select
            booking_status_type_id,
            content_player_status,
            object_version_number,
            event_id,
            date_booking_placed
     from
            ota_delegate_bookings
     where
            booking_id  = l_booking_id;



cursor cur_get_finance_line_id is
     select
            finance_line_id,
            object_version_number,
            sequence_number,
            date_raised,
            finance_header_id
     from
            ota_finance_lines
     where
            booking_id      = l_booking_id  and
            cancelled_flag  = 'N'           and
	    transfer_status = 'NT';


cursor cur_get_status_type_id is
     select
            booking_status_type_id
     from
            ota_booking_status_types
     where
            type          = 'A'  and
            default_flag  = 'Y'  and
            active_flag   = 'Y'  and
            business_group_id = p_business_group_id;

cursor csr_booking_status(p_status_type_id number) is
Select type
from   ota_booking_status_types
where booking_status_type_id = p_status_type_id;

/* for Bug 2242840 */
cursor csr_finance_header(p_finance_header_id IN number) IS
select object_version_number from
ota_finance_headers
where finance_header_id = p_finance_header_id;




begin
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'p_person_id:' || p_person_id);
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'p_rco_id:' || p_rco_id);
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'p_business_group_id:' || p_business_group_id);



   FOR cur_booking_id IN cur_get_booking_id
   LOOP

       l_booking_id := cur_booking_id.booking_id;

       open  cur_get_tdb_details;
       fetch cur_get_tdb_details into l_cur_booking_status_type_id,
                                      l_cur_content_player_status,
                                      l_cur_tdb_ovn,
                                      l_cur_event_id,
                                      l_date_booking_placed;
       close cur_get_tdb_details;

--     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_booking_id:' || l_booking_id);

       open  cur_get_finance_line_id;
       fetch cur_get_finance_line_id into l_finance_line_id,
                                          l_fl_ovn,
                                          l_sequence_number,
                                          l_date_raised,
                                          l_finance_header_id;

       if cur_get_finance_line_id%NOTFOUND then
          close cur_get_finance_line_id;
--          FND_FILE.PUT_LINE(FND_FILE.LOG,'Finance Line ID not found for rco id ' || p_rco_id ||
--                                         ' and person id ' || p_person_id );
       else
          close cur_get_finance_line_id;

           if l_cur_content_player_status is NULL then


             BEGIN

                -- clear message before calling API
                hr_utility.clear_message;
              if l_auto_transfer = 'Y' then  /* Start for Bug 2242840 */
                 for finance_rec in csr_finance_header (l_finance_header_id)
                 LOOP
                 exit when  csr_finance_header%notfound ;
                 l_finance_header_ovn := finance_rec.object_version_number;
                 END LOOP;

                  ota_tfh_api_shd.lck(l_finance_header_id, l_finance_header_ovn );

                  ota_tfh_api_upd.upd(p_finance_header_id    => l_finance_header_id,
                                      p_authorizer_person_id => l_user_id,
						  p_object_version_number => l_finance_header_ovn ,
                                      p_transfer_status  => 'AT');

                 /* End for Bug 2242840 */


  /*               ota_tfl_api_upd.upd   ----  ottfl01t.pkb
                (p_finance_line_id              => l_finance_line_id                 --  (Input)
                ,p_date_raised                  => l_date_raised                     --  (In Out)
                ,p_object_version_number        => l_fl_ovn                          --  (Output)
                ,p_sequence_number              => l_sequence_number                 --  (In Out)
                ,p_transfer_status              => 'AT'                              --  (Input)   Awaiting Transfer
                ,p_validate                     => false                             --  (Input)
                ,p_transaction_type             => 'UPDATE'                          --  (Input)
                ); */

--                FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated finance line for rco_id - '|| p_rco_id ||
--                                           ' person id-' || p_person_id || ' and booking ID-' ||
--                                           cur_booking_id.booking_id || ' and finance_line_id-' || l_finance_line_id);
                p_message := 'Successfully updated finance line ';
                --  dbms_output.put_line(p_message);

             end if;

             EXCEPTION
                when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the finance line for RCO ID '|| p_rco_id ||
                                           ', Person ID ' || p_person_id || ', Booking ID-' ||
                                           cur_booking_id.booking_id || ', and Finance Line ID-' || l_finance_line_id
                                           || '. Reason:' || hr_utility.get_message);
                    p_message := 'Error in updating finance line ';
                  --  dbms_output.put_line(p_message);
             END;


         else
               FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
--               FND_FILE.PUT_LINE(FND_FILE.LOG,'concurrent program will not update finance line for rco_id - '|| p_rco_id ||
--                                              ' person id-' || p_person_id || ' and booking ID-' ||
--                                              cur_booking_id.booking_id || ' and finance_line_id-' || l_finance_line_id ||
--                                              ' because content player status is not null.');

         end if;

       end if;


       if p_status in ('C','P') then
           /*open  cur_get_status_type_id;
           fetch cur_get_status_type_id into l_booking_status_type_id;
           if cur_get_status_type_id%NOTFOUND then
                 close cur_get_status_type_id;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:Default booking_status_type_id not found for Attended status' ||
                                                ' for business group id ' || p_business_group_id);
                 p_message := 'ERROR: Default booking_status_type_id not found ';
               --  dbms_output.put_line(p_message);
                 p_history_status := 'F';
                 return;
           end if;
           close cur_get_status_type_id;
           */

           FOR status_type in csr_booking_status(l_cur_booking_status_type_id)
           LOOP
           if status_type.type <> 'A' then
             l_booking_status_type_id := FND_PROFILE.VALUE('OTA_ILEARNING_DEFAULT_ATTENDED');
             if l_booking_status_type_id is null then
                FND_FILE.PUT_LINE(FND_FILE.LOG,'You must enter a default Attended Enrollment Status for the profile OTA:Default Attended Enrollment Status.');
                 p_message := 'ERROR: Default booking_status_type_id not found ';
               --  dbms_output.put_line(p_message);
                 p_history_status := 'F';

             end if;

            else
               l_booking_status_type_id := l_cur_booking_status_type_id;

            end if;

           END LOOP;

       else
           l_booking_status_type_id := l_cur_booking_status_type_id;
       end if;

           l_ovn := l_cur_tdb_ovn;

--Bug#2246791 hdshah lock record before calling update_enrollment procedure.
       ota_tdb_shd.lck(cur_booking_id.booking_id,l_ovn);

       BEGIN
           -- clear message before calling API
             hr_utility.clear_message;

           if l_booking_status_type_id = l_cur_booking_status_type_id then
              ota_tdb_api_upd2.update_enrollment
              (p_booking_id                 =>  cur_booking_id.booking_id             --   (Input)
              ,p_booking_status_type_id     =>  l_booking_status_type_id              --   (Input)
              ,p_object_version_number      =>  l_ovn                                 --   (In Out)
              ,p_event_id                   =>  l_cur_event_id                        --   (Input)
              ,p_content_player_status      =>  p_status                              --   (Input)
              ,p_score                      =>  p_score                               --   (Input)
              ,p_total_training_time        =>  p_time                                --   (Input)
              ,p_completed_content          =>  p_complete                            --   (Input)
              ,p_total_content              =>  p_total                               --   (Input)
              ,p_tfl_object_version_number  =>  l_tfl_ovn                             --   (In Out)
              ,p_finance_line_id            =>  l_tfl_finance_line_id                 --   (In Out)
              );
           else
              ota_tdb_api_upd2.update_enrollment
              (p_booking_id                 =>  cur_booking_id.booking_id             --   (Input)
              ,p_booking_status_type_id     =>  l_booking_status_type_id              --   (Input)
              ,p_object_version_number      =>  l_ovn                                 --   (In Out)
              ,p_event_id                   =>  l_cur_event_id                        --   (Input)
              ,p_content_player_status      =>  p_status                              --   (Input)
              ,p_score                      =>  p_score                               --   (Input)
              ,p_total_training_time        =>  p_time                                --   (Input)
              ,p_completed_content          =>  p_complete                            --   (Input)
              ,p_total_content              =>  p_total                               --   (Input)
              ,p_tfl_object_version_number  =>  l_tfl_ovn                             --   (In Out)
              ,p_finance_line_id            =>  l_tfl_finance_line_id                 --   (In Out)
              ,p_date_status_changed        =>   sysdate
              ,p_date_booking_placed        => l_date_booking_placed);

           end if;


            FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated history for RCO ID - '|| p_rco_id ||
                                           ', Person ID ' || p_person_id || ', and Booking ID ' ||
                                           cur_booking_id.booking_id ||'.');
            p_message := 'Successfully updated history ';
          --  dbms_output.put_line(p_message);
            p_history_status := 'S';
            return;

       EXCEPTION
            when others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update history for RCO ID - '|| p_rco_id ||
                                           ', Person ID ' || p_person_id || ', and Booking ID ' ||
                                           cur_booking_id.booking_id || '. REASON:' || hr_utility.get_message);
--            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in updating history for  rco_id - '|| p_rco_id ||
--                                           ' person id-' || p_person_id || ' and booking ID-' ||
--                                           cur_booking_id.booking_id || '. REASON:' || hr_utility.get_message);

--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_booking_id:' ||  cur_booking_id.booking_id);
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_booking_status_type_id:' ||  l_booking_status_type_id);
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_object_version_number:' || l_ovn );
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_content_player_status:' || p_status);
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_score:' || p_score);
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_total_training_time:' ||  p_time );
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_completed_content:' ||   p_complete );
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_total_content:' ||  p_total );
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_tfl_object_version_number:' || l_tfl_ovn  );
--           FND_FILE.PUT_LINE(FND_FILE.LOG,'p_finance_line_id:' || l_tfl_finance_line_id  );

            p_message := 'Error in updating history ';
          --  dbms_output.put_line(p_message);
            p_history_status := 'F';
            return;
       END;

  END LOOP;

exception
    when others then

       FND_FILE.PUT_LINE(FND_FILE.LOG,'An error occurred while updating RCO ID  '|| p_rco_id ||
                                           ', Person ID ' || p_person_id || ', and Booking ID ' ||
                                           l_booking_id ||'.');
       p_message := 'upd_history:ERROR:In when others exception for Rco_Id - ' || p_rco_id;
     --  dbms_output.put_line(p_message);
       p_history_status := 'F';
       return;


end upd_history;




procedure history_import (
   p_array                       in OTA_HISTORY_STRUCT_TAB
  ,p_business_group_id           in varchar2
  ) is

l_proc                   varchar2(72) := g_package||'history_import';
l_history_status         varchar2(1);
l_message                varchar2(100);
l_update                 varchar2(10);
l_history_success        number(10)     := 0;
l_history_fail           number(10)     := 0;

begin
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);


   FOR p_array_idx IN p_array.FIRST..p_array.LAST  LOOP

  -- Issue Savepoint
  SAVEPOINT save_history;

  upd_history
  (
   p_person_id                => to_number(p_array(p_array_idx).history_personid)    -- (Input)
  ,p_rco_id                   => to_number(p_array(p_array_idx).history_rco_id)      -- (Input)
  ,p_isroot                   => p_array(p_array_idx).history_isroot                 -- (Input)
  ,p_status                   => p_array(p_array_idx).history_status                 -- (Input)
  ,p_score                    => to_number(p_array(p_array_idx).history_score)       -- (Input)
  ,p_time                     => p_array(p_array_idx).history_time                   -- (Input)
  ,p_complete                 => to_number(p_array(p_array_idx).history_complete)    -- (Input)
  ,p_total                    => to_number(p_array(p_array_idx).history_total)       -- (Input)
  ,p_business_group_id        => to_number(p_business_group_id)                      -- (Input)
  ,p_history_status           => l_history_status                                    -- (Output)
  ,p_message                  => l_message                                           -- (Output)
  );


  if l_history_status = 'S' then
     l_history_success := l_history_success +1;
     -- do commit;
     commit;
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'History Update committed.');
  else
     l_history_fail := l_history_fail +1;
     -- rollback to save_activity
     ROLLBACK TO save_history;
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'History Update rolled back.');
  end if;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'              IMPORT RESULTS FOR TRAINING HISTORIES ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of Histories Processed Successfully:' || l_history_success);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'         Number of Histories Not Processed:' || l_history_fail);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'---------------------------------------------------------------');
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting:' || l_proc);

end history_import;

end OTA_ILEARNING2;

/
