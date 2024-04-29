--------------------------------------------------------
--  DDL for Package Body OTA_CANCEL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CANCEL_API" as
/* $Header: ottomint.pkb 120.43.12010000.13 2009/08/31 13:50:06 smahanka ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------

g_package  varchar2(33) := '  ota_cancel_api.';  -- Global package name

l_conc_request_id  fnd_concurrent_requests.request_id%TYPE := -1;
l_debug_msg                  VARCHAR2(2000);
l_status                     VARCHAR2(80);
l_err_num                    VARCHAR2(30) := '';
l_err_msg                    VARCHAR2(1000) := '';
l_return_boolean             BOOLEAN := FALSE;
l_exception_message          VARCHAR2(240) := '';
l_user_id  number := fnd_profile.value('USER_ID');
l_login_id number := fnd_profile.value('LOGIN_ID');
l_sob_id                     NUMBER;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cancel_line>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to update delegate booking and event table.
--
--   This procedure will only be used for OTA and OM integration. The prurpose
--   of this procedure is only be called by OM Process Order API when the order
--   line got canceled or deleted. This procedure being created because Order
--   Management doesnot support workflow for Cancel or delete Order Line.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_org_id
--   p_uom
--   p_daemon_type
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
Procedure delete_cancel_line
 (
  p_line_id    IN Number,
  p_org_id     IN Number,
  p_UOM        IN Varchar2,
  P_daemon_type   IN varchar2,
  x_return_status OUT NOCOPY varchar2)

  is

  l_proc    varchar2(72) := g_package||'cnc_evt_enr';

l_event_id           ota_events.event_id%type;
l_event_business_group_id     ota_events.business_group_id%type;
l_event_status       varchar2(100);
l_title           ota_events_tl.title%type;  -- MLS change _tl added
l_owner_id           ota_events.owner_id%type := null;
l_owner_email        varchar2(100);
l_type            varchar2(4);
l_event_ovn          ota_events.object_version_number%type;
l_full_name          per_people_f.full_name%type;

l_booking_id         ota_delegate_bookings.booking_id%type;
l_booking_status_type_id   ota_delegate_bookings.booking_status_type_id%type;
l_enr_business_group_id    ota_delegate_bookings.business_group_id%type;
l_enr_ovn            ota_delegate_bookings.object_version_number%type;
l_booking_status_type      ota_booking_status_types.type%type;
l_tfl_ovn            ota_finance_lines.object_version_number%type;
l_new_fl          ota_finance_lines.finance_line_id%type;
l_user_name                   fnd_user.user_name%type;

l_cancel_hours                number := FND_PROFILE.VALUE('OTA_AUTO_WAITLIST_DAYS');

 l_different_hours      number(11,3);
 l_event_date          date;
 l_current_date        date;
 l_sysdate             date;
 l_wf_date             varchar2(30);
-- l_event_owner_id      ota_events.owner_id%type;

l2_event_status           OTA_EVENTS.EVENT_STATUS%TYPE;
--
CURSOR C_event IS
SELECT
  Event_ID,
  Business_Group_ID ,
  Event_status,
  Title,
  Owner_Id,
  Object_Version_number
  FROM OTA_Events_vl --MLS change _vl added
  WHERE Line_Id = p_line_Id;

 CURSOR C_PEOPLE IS
 SELECT
   email_address, full_name
 FROM
   per_all_people_f
 WHERE
 person_id = l_owner_id and
   trunc(sysdate) between
   effective_start_date and
   effective_end_date;

CURSOR C_USER IS
SELECT
 USER_NAME
FROM
 FND_USER
WHERE
Employee_id = l_owner_id
AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892

--

 CURSOR C_ENROLLMENT IS
 SELECT
    tdb.Booking_id,
    tdb.Booking_status_type_id,
    tdb.Business_group_id,
    tdb.Object_version_number,
    tdb.event_id,
    evt.title
 FROM
    OTA_DELEGATE_BOOKINGS tdb,
    OTA_EVENTS_tl evt -- MLS change _tl added
 WHERE
    tdb.Line_id = p_line_id and
    evt.event_id = tdb.event_id;

--

CURSOR C_BOOKING_STATUS IS
 SELECT
   Type
 FROM
   OTA_BOOKING_STATUS_TYPES
 WHERE
   booking_status_type_id = l_booking_status_type_id;
--bug # 5231470 first Date format changed to DD/MM/YYYY from DD-MON-YYYY
CURSOR C_EVENT_DATE (p_event_id ota_events.event_ID%type) IS
SELECT to_date(to_char(evt.Course_start_date,'DD/MM/YYYY')||EVT.Course_start_time,'DD/MM/YYYYHH24:MI'),
       OWNER_ID
FROM   OTA_EVENTS  EVT
WHERE  evt.event_id = p_event_id;

CURSOR c_sysdate IS
SELECT
   sysdate
FROM
   dual;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN c_sysdate;
  FETCH c_sysdate INTO l_sysdate;
  CLOSE c_sysdate;

  x_return_status := 'S';
  IF p_uom = 'EVT' THEN
     OPEN C_EVENT;
     FETCH C_EVENT INTO l_event_id,
               l_event_business_group_id,
            l_Event_status,
            l_Title,
            l_Owner_Id,
            l_event_ovn;
     IF c_event%found then
    /* OPEN c_people;
        FETCH c_people into l_owner_email,l_full_name ;
        IF c_people%found then */
         OPEN C_USER;
         FETCH C_USER INTO l_user_name;
           IF p_daemon_type = 'C' THEN
        hr_utility.set_location('Entering:'||l_proc, 10);

-- Bug # 2707198

            OTA_INITIALIZATION_WF.INITIALIZE_CANCEL_ORDER (
                                p_itemtype      => 'OTWF',
                                p_process       => 'OTA_CANCEL_ORDER_LINE_2',
                                p_Event_title   => l_title      ,
                                p_event_id      => l_event_id,
                                p_user_name     => l_user_name,
                                p_line_id       => p_line_id,
                                p_status        => 'C',
                                p_full_name     => l_full_name);

            hr_approval_wf.create_item_attrib_if_notexist  (p_item_type  => 'OTWF'
                                                ,p_item_key   => to_char(p_line_id)
                                                ,p_name       => 'CALLER_SOURCE');

            WF_ENGINE.setitemattrtext('OTWF',
                            to_char(p_line_id),
                            'CALLER_SOURCE',
                            'ONT');
-- Bug # 2707198


--Enh#1753511 HDSHAH
                 l_booking_status_type_id := Fnd_profile.value('OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS');
                 l2_event_status := 'A';
                  OTA_EVT_API_UPD2.UPDATE_EVENT (
                                                 P_EVENT                      => 'STATUS',
                                                 P_EVENT_ID                   => l_event_id,
                                                 P_OBJECT_VERSION_NUMBER      => l_event_ovn,
                                                 P_EVENT_STATUS               => l2_event_status,
                                                 P_VALIDATE                   => false,
                                                 P_BOOKING_STATUS_TYPE_ID     => l_booking_status_type_id,
                                                 P_UPDATE_FINANCE_LINE        => 'C',
                                                 P_DATE_STATUS_CHANGED        => l_sysdate);


/*       OTA_INITIALIZATION_WF.INITIALIZE_CANCEL_ORDER (
            p_itemtype     => 'OTWF',
            p_process      => 'OTA_CANCEL_ORDER_LINE_2',
            p_Event_title  => l_title  ,
            p_event_id        => l_event_id,
            p_user_name    => l_user_name,
            p_line_id      => p_line_id,
            p_status    => 'C',
            p_full_name       => l_full_name);       */

--Enh#1753511 HDSHAH

/* Hitesh Shah
         OTA_INITIALIZATION_WF.INITIALIZE_CANCEL_ORDER (
            p_itemtype     => 'OTWF',
            p_process      => 'OTA_CANCEL_ORDER_LINE',
            p_Event_title  => l_title  ,
            p_event_id        => l_event_id,
            p_user_name    => l_user_name,
            p_line_id      => p_line_id,
            p_status    => 'C',
            p_full_name       => l_full_name);
*/

         ELSIF p_daemon_type = 'D' THEN
         hr_utility.set_location('Entering:'||l_proc, 15);
               ota_evt_upd.upd(
            p_Event_id        => l_Event_Id
            ,P_Business_Group_id    => l_event_Business_group_id
            ,P_Object_version_number => l_event_ovn
            ,p_comments       => 'The Order Line for this event has been deleted.'
            ,p_Line_id        => Null
            ,p_Org_id         => Null
            ,P_validate       => False);

        hr_utility.set_location('Entering:'||l_proc, 20);


         OTA_INITIALIZATION_WF.INITIALIZE_CANCEL_ORDER (
            p_itemtype     => 'OTWF',
            p_process      => 'OTA_CANCEL_ORDER_LINE',
            p_Event_title  => l_title  ,
            p_event_id        => l_event_id,
            p_user_name    => l_user_name,
            p_line_id      => p_line_id,
            p_status    => 'D',
            p_full_name       => l_full_name);

           ELSIF p_daemon_type = 'P' THEN
         hr_utility.set_location('Entering:'||l_proc, 15);
               ota_evt_upd.upd(
            p_Event_id        => l_Event_Id
            ,P_Business_Group_id    => l_event_Business_group_id
            ,P_Object_version_number => l_event_ovn
            ,p_comments       => 'The Order  Line for this event has been closed.'
            ,p_Line_id        => Null
            ,p_Org_id         => Null
            ,P_validate       => False);

        hr_utility.set_location('Entering:'||l_proc, 20);

         END IF;
         CLOSE C_USER;
       /* END IF;
     CLOSE c_people; */
     END IF;
     CLOSE C_EVENT;

  ELSIF p_uom = 'ENR' THEN

    hr_utility.set_location('Entering:'||l_proc, 25);
    BEGIN
    OPEN C_ENROLLMENT;
    FETCH c_enrollment into
         l_booking_id,
            l_Booking_status_type_id,
         l_enr_Business_group_id,
         l_enr_ovn,
            l_event_id,
            l_title;
    IF c_enrollment%found THEN

       OPEN c_event_date(l_event_id);
       FETCH c_event_date into l_event_date,l_owner_id;
       CLOSE c_event_date;

       OPEN c_sysdate;
       FETCH c_sysdate INTO l_sysdate;
       CLOSE c_sysdate;

      l_different_hours := l_event_date - l_sysdate ;
      l_different_hours  := l_different_hours  * 24 ;
      IF l_different_hours <= nvl(l_cancel_hours,0)  THEN
         OPEN C_USER;
         FETCH C_USER INTO l_user_name;
       select to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS') into l_wf_date from dual;

         OTA_INITIALIZATION_WF.MANUAL_WAITLIST(
                        p_itemtype     => 'OTWF',
            p_process      => 'OTA_MANUAL_WAITLIST',
            p_Event_title  => l_title  ,
            p_event_id        => l_event_id,
            p_item_key        => l_booking_id||':'||l_wf_date,
            p_user_name    => l_user_name);
      END IF;
       OPEN C_BOOKING_STATUS;
       FETCH  c_booking_status into
               l_booking_status_type;
       IF c_booking_status%found then
         IF l_booking_status_type not in('A','C') then
         hr_utility.set_location('Entering:'||l_proc, 30);
               ota_tdb_api_upd2.update_enrollment(
         p_booking_id         =>  l_booking_id
         ,p_object_version_number   => l_enr_ovn
         ,p_event_id       => l_event_id
         ,p_daemon_flag       => 'Y'
         ,p_tfl_object_version_number  => l_tfl_ovn
              ,p_booking_status_type_id   => l_Booking_status_type_id
      -- ,p_update_finance_line     => 'N'
         ,p_finance_line_id      => l_new_fl
         ,p_daemon_type       => p_daemon_type
         ,p_status_change_comments  => null); /* Bug# 3469326 */

         END IF;
   END IF;
      CLOSE C_BOOKING_status;
     END IF;
     CLOSE C_ENROLLMENT;

     EXCEPTION WHEN
     OTHERS THEN
     x_return_status := 'E';
     RAISE;
     END;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION WHEN
OTHERS THEN
x_return_status := 'E';
RAISE;
END;


-- ----------------------------------------------------------------------------
-- |---------------------------------< cancel_enrollment  >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_user_id,
--   p_login_id
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

Procedure cancel_enrollment
(p_user_id in number,
p_login_id in number)IS


l_status_name  varchar2(80);
l_status_id       ota_delegate_bookings.booking_status_type_id%type;
-- Define Local variable for booking

  l_event_id         ota_delegate_bookings.event_id%type;
  l_old_event_id        ota_delegate_bookings.event_id%type;    -- added for bug #1632104
  l_booking_id       ota_delegate_bookings.booking_id%type;
  l_booking_status_type_id ota_delegate_bookings.booking_status_type_id%type;
  l_enr_business_group_id     ota_delegate_bookings.business_group_id%type;
  l_enr_ovn          ota_delegate_bookings.object_version_number%type;
  l_booking_status_type    ota_booking_status_types.type%type;
  l_daemon_flag         ota_delegate_bookings.daemon_flag%type;
  l_daemon_type         ota_delegate_bookings.daemon_type%type;
  l_line_id          ota_delegate_bookings.line_id%type;
  l_event_title         ota_events_tl.title%type;  -- MLS change _tl added
  l_business_group_id      ota_delegate_bookings.business_group_id%type;
  l_single_business_group_id     ota_delegate_bookings.business_group_id%type:=
                     fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
-- Define local variable for status
l_status_type_id           ota_delegate_bookings.booking_status_type_id%type;

-- Define local variable for lines
l_line_ovn           ota_finance_lines.object_version_number%type;
l_Finance_Line_id       ota_finance_lines.finance_line_id%type;
l_Finance_header_id     ota_finance_lines.finance_header_id%type;
l_line_transfer_Status     ota_finance_lines.transfer_status%type;
l_Sequence_Number       ota_finance_lines.sequence_number%type;
l_Date_raised        ota_finance_lines.date_raised%type;

-- Define local variable for header;
l_header_ovn         ota_finance_headers.object_version_number%type;
l_header_Transfer_status   ota_finance_headers.transfer_status%type;
-- Define local variable for other
l_auto_waitlist         varchar2(1);
l_sysdate            date;
l_count           number(6);
l_tfl_ovn            ota_finance_lines.object_version_number%type;
l_new_fl             ota_finance_lines.finance_line_id%type;
l_return_status         varchar2(1):= 'T';
  e_validation_error exception;

 l_cancel_hours               number := FND_PROFILE.VALUE('OTA_AUTO_WAITLIST_DAYS');

 l_different_hours      number(11,3);
 l_event_date          date;
 l_current_date        date;
 l_owner_id            ota_events.owner_id%type;

 l_date_booking_placed   date;

-- Define Enrollment cursor

CURSOR C_ENROLLMENT IS
 SELECT
    Event_id,
    Booking_id,
    Booking_status_type_id,
    Business_group_id,
    Object_version_number,
    daemon_flag,
    daemon_type,
    line_id,
    old_event_id,    -- added for bug #1632104
    date_booking_placed  -- Added for bug 1708632
 FROM
    OTA_DELEGATE_BOOKINGS
 WHERE
    (daemon_flag = 'Y' OR daemon_flag IS NULL) and
    daemon_type is not null and
    business_group_id = l_business_group_id;
--fnd_profile.VALUE('PER_BUSINESS_GROUP_ID');
-- FOR UPDATE nowait;

-- Define status cursor

CURSOR C_STATUS IS
SELECT
   BOOKING_STATUS_TYPE_ID
FROM
   OTA_BOOKING_STATUS_TYPES
WHERE
   Name =  l_status_name;

-- Define booking status cursor

CURSOR C_BOOKING_STATUS IS
SELECT
   name
FROM
   OTA_BOOKING_STATUS_TYPES_TL  -- MLS change _TL added
WHERE
   booking_status_type_id =  l_booking_status_type_id;

-- Define finance line cursor

CURSOR C_LINES IS
SELECT
    Finance_Line_id,
    Finance_header_id,
    Transfer_Status,
    Object_version_number,
       Sequence_Number,
    Date_raised
FROM
    OTA_FINANCE_LINES
WHERE  Booking_id =  l_Booking_id;

-- Define finance header cursor


CURSOR C_HEADER IS
SELECT
    Object_version_number,
       Transfer_status
FROM
   ota_finance_headers
WHERE
   finance_header_id = l_finance_header_id;

-- define caount finance line cursor

CURSOR c_count IS
SELECT
   count(finance_line_id)
FROM
   ota_finance_lines
WHERE
   finance_header_id = l_finance_header_id;

CURSOR c_sysdate IS
SELECT
   sysdate
FROM
   dual;
--bug # 5231470 first date format changed to DD/MM/YYYY from DD-MON-YYYY
CURSOR C_EVENT_DATE (p_event_id ota_events.event_ID%type) IS
SELECT to_date(to_char(evt.Course_start_date,'DD/MM/YYYY')||EVT.Course_start_time,'DD/MM/YYYYHH24:MI'),
       OWNER_ID
FROM   OTA_EVENTS  EVT
WHERE  evt.event_id = p_event_id;


  l_proc       varchar2(72) := g_package||'cancel_enrollment';


BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 5);
 -- l_status_name := Fnd_profile.value('OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS');
    l_status_id := Fnd_profile.value('OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS');
  l_auto_waitlist := Fnd_profile.value('OTA_AUTO_WAITLIST_ACTIVE');

-- FND_FILE.PUT_LINE(FND_FILE.LOG,'Start test of concurrent program');
  IF l_single_business_group_id is not null then
     l_business_group_id := l_single_business_group_id;
  ELSE
     l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
  END IF;

  OPEN C_ENROLLMENT;
  LOOP
  hr_utility.set_location(l_proc, 10);

   FETCH c_enrollment into
      l_event_id,
         l_booking_id,
            l_Booking_status_type_id,
         l_enr_Business_group_id,
         l_enr_ovn,
            l_daemon_flag,
      l_daemon_type,
            l_line_id,
            l_old_event_id,  -- added for bug #1632104
            l_date_booking_placed;  -- Added for bug# 1708632
   EXIT when c_enrollment%notfound;
      BEGIN
       savepoint Cancel_enrollment;
       l_return_status := 'T';
      IF l_daemon_type = 'C' then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Daemon type :' || l_daemon_type );
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing booking id : ' || l_booking_id);
         OPEN c_lines;
      FETCH c_lines INTO   l_Finance_Line_id,
               l_Finance_header_id,
               l_line_transfer_Status,
               l_line_ovn,
                  l_Sequence_Number,
               l_Date_raised ;
      IF c_lines%found THEN

      IF l_line_transfer_status <> 'ST' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cancelling Finance Line for booking id : ' || l_booking_id);
         hr_utility.set_location('Entering:'|| l_proc, 10);
               BEGIN
         ota_tfl_api_upd.upd(
               p_finance_line_id    => l_finance_line_id,
               p_date_raised     => l_date_raised,
               p_cancelled_flag     => 'Y',
               p_object_version_number => l_line_ovn,
               p_transfer_status    => l_line_transfer_Status,
               p_sequence_number    => l_sequence_number,
               p_validate        => false,
               p_transaction_type   => 'UPDATE');
          exception when others then
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 100);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               'Booking Id :'||to_char(l_booking_id)||','||
               'Finance_line_id :'||to_char(l_finance_line_id)||','||l_err_msg);
                   l_return_status := 'F';
                END;
         OPEN c_count;
         FETCH c_count INTO l_count;
         IF l_count = 1  THEN

         OPEN c_header;
         FETCH c_header INTO l_header_ovn,
                    l_header_Transfer_status;
         IF c_header%found THEN

            IF l_header_transfer_status <> 'ST' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Cancelling Finance Header for booking id : ' || l_booking_id);
            BEGIN
            hr_utility.set_location('Entering:'|| l_proc, 30);
                  ota_tfh_api_upd.upd( p_finance_header_id  => l_finance_header_id
                       ,p_object_version_number    => l_header_ovn
                       ,p_cancelled_flag        => 'Y'
                       ,p_validate        => False
                       ,p_Transaction_type      => 'UPDATE');
                        exception when others then
                     l_err_num := SQLCODE;
                     l_err_msg := SUBSTR(SQLERRM, 1, 100);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               'Booking Id :'||to_char(l_booking_id)||','||
               'Finance_header_id :'||to_char(l_finance_header_id)||','||l_err_msg);
                          l_return_status := 'F';
                       END;

            END IF;
         END IF;
            CLOSE C_header;
          END IF;
          CLOSE c_count;
       END IF;
          END IF;
          CLOSE C_lines;

            IF  l_status_id is not null THEN
        BEGIN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating booking id : ' || l_booking_id);
              hr_utility.set_location('Entering:'|| l_proc, 40);
               ota_tdb_shd.lck(l_booking_id,l_enr_ovn);
        ota_tdb_api_upd2.Update_Enrollment(
             p_booking_id        => l_booking_id
               ,p_booking_status_type_id  => l_status_id
            ,p_event_id       => l_event_id
            ,p_business_group_id    => l_enr_business_group_id
            ,p_object_version_number   => l_enr_ovn
            ,p_update_finance_line     => 'N'
            ,p_finance_line_id      => l_new_fl
            ,p_tfl_object_version_number  => l_tfl_ovn
            ,p_validate       => False
            ,p_daemon_flag       => null
            ,p_daemon_type       => null
            ,p_date_status_changed     => sysdate   -- Added for bug# 1708632
            ,p_date_booking_placed     => l_date_booking_placed  -- Added for bug# 1708632
            ,p_status_change_comments  => null); /* Bug# 3469326 */
              exception when others then
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 500);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||l_err_msg);
                   l_return_status := 'F';

        END;
            ELSE
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||'OTA:OM Default Enrollment Cancalled Status profile '||
                                   'value has not been defined yet' );
                   l_return_status := 'F';

            END IF;

      ELSIF l_daemon_type = 'P' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Daemon type :' || l_daemon_type );
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing booking id : ' || l_booking_id);
            hr_utility.set_location('Entering:'|| l_proc, 45);
            BEGIN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating booking id : ' || l_booking_id);
            ota_tdb_shd.lck(l_booking_id,l_enr_ovn);
      ota_tdb_api_upd2.Update_Enrollment(
         p_booking_id         => l_booking_id
            ,p_booking_status_type_id  => l_booking_status_type_id
         ,p_event_id       => l_event_id
         ,p_business_group_id    => l_enr_business_group_id
         ,p_object_version_number   => l_enr_ovn
         ,p_update_finance_line     => 'N'
         ,p_finance_line_id      => l_new_fl
         ,p_validate       => False
         ,p_tfl_object_version_number  => l_tfl_ovn
         ,P_Line_id        => null
         ,p_Org_id         => null
         ,p_daemon_flag       => null
         ,p_daemon_type       => null
         ,p_status_change_comments  => null); /* Bug# 3469326 */
      EXCEPTION WHEN OTHERS THEN
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 500);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||l_err_msg);
                   l_return_status := 'F';
         END;
/** Created for Bug 1576558 **/

      ELSIF l_daemon_type = 'D' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Daemon type :' || l_daemon_type );
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing booking id : ' || l_booking_id);
            hr_utility.set_location('Entering:'|| l_proc, 47);
          IF  l_status_id is not null THEN

            BEGIN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating booking id : ' || l_booking_id);
            ota_tdb_shd.lck(l_booking_id,l_enr_ovn);
      ota_tdb_api_upd2.Update_Enrollment(
         p_booking_id         => l_booking_id
            ,p_booking_status_type_id  => l_status_id
         ,p_event_id       => l_event_id
         ,p_business_group_id    => l_enr_business_group_id
         ,p_object_version_number   => l_enr_ovn
         ,p_update_finance_line     => 'N'
         ,p_finance_line_id      => l_new_fl
         ,p_validate       => False
         ,p_tfl_object_version_number  => l_tfl_ovn
         ,P_Line_id        => null
         ,p_Org_id         => null
         ,p_daemon_flag       => null
         ,p_daemon_type       => null
         ,p_date_status_changed     => sysdate   -- Added for bug# 1708632
         ,p_date_booking_placed     => l_date_booking_placed  -- Added for bug# 1708632
         ,p_status_change_comments  => null); /* Bug# 3469326 */

      EXCEPTION WHEN OTHERS THEN
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 500);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||l_err_msg);
                   l_return_status := 'F';
         END;
           ELSE
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||'OTA:OM Default Enrollment Cancalled Status profile '||
                                   'value has not been defined yet' );
                   l_return_status := 'F';

          END IF;
/** End Created for Bug 1576558 **/

   ELSIF l_daemon_type = 'W' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Daemon type :' || l_daemon_type );
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing booking id : ' || l_booking_id);

            hr_utility.set_location('Entering:'|| l_proc, 50);
            BEGIN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating booking id : ' || l_booking_id);
            ota_tdb_shd.lck(l_booking_id,l_enr_ovn);
      ota_tdb_api_upd2.Update_Enrollment(
         p_booking_id         => l_booking_id
            ,p_booking_status_type_id  => l_booking_status_type_id
         ,p_event_id       => l_event_id
         ,p_business_group_id    => l_enr_business_group_id
         ,p_object_version_number   => l_enr_ovn
         ,p_update_finance_line     => 'N'
         ,p_finance_line_id      => l_new_fl
         ,p_validate       => False
         ,p_tfl_object_version_number  => l_tfl_ovn
         ,p_daemon_flag       => null
         ,p_daemon_type       => null
         ,p_status_change_comments  => null); /* Bug# 3469326 */
            EXCEPTION WHEN OTHERS THEN
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 100);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||l_err_msg);
                   l_return_status := 'F';
            END;

   ELSIF l_daemon_type = 'E' THEN  -- added for bug #1632104
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Daemon type :' || l_daemon_type );
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing booking id : ' || l_booking_id);
            hr_utility.set_location('Entering:'|| l_proc, 55);  -- err location added for bug#1632104
            BEGIN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating booking id : ' || l_booking_id);
             ota_tdb_shd.lck(l_booking_id,l_enr_ovn);
      ota_tdb_api_upd2.Update_Enrollment(
         p_booking_id         => l_booking_id
            ,p_booking_status_type_id  => l_booking_status_type_id
         ,p_event_id       => l_event_id
         ,p_business_group_id    => l_enr_business_group_id
         ,p_object_version_number   => l_enr_ovn
         ,p_update_finance_line     => 'N'
         ,p_finance_line_id      => l_new_fl
         ,p_validate       => False
         ,p_tfl_object_version_number  => l_tfl_ovn
         ,p_daemon_flag       => null
         ,p_daemon_type       => null
         ,p_old_event_id         => null
         ,p_status_change_comments  => null); /* Bug# 3469326 */
            EXCEPTION WHEN OTHERS THEN
                  l_err_num := SQLCODE;
                  l_err_msg := SUBSTR(SQLERRM, 1, 100);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               to_char(l_booking_id)||','||l_err_msg);
                   l_return_status := 'F';
            END;

      END IF;
       IF l_return_status = 'T' then
     IF l_auto_waitlist = 'Y' THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto Waitlist profile value is :' || l_auto_waitlist );
           IF l_daemon_type in ('D','C','W','E') THEN  -- modified for bug #1632104

             IF l_daemon_type in ('D','C','W') THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Daemon type :' ||l_daemon_type );
               OPEN c_event_date(l_event_id);
               FETCH c_event_date into l_event_date,l_owner_id;
               CLOSE c_event_date;

               OPEN c_sysdate;
               FETCH c_sysdate INTO l_sysdate;
               CLOSE c_sysdate;

             ELSIF l_daemon_type = 'E' THEN  -- added for bug #1632104
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Daemon type :' ||l_daemon_type );
               OPEN c_event_date(l_old_event_id);
               FETCH c_event_date into l_event_date,l_owner_id;
               CLOSE c_event_date;

               OPEN c_sysdate;
               FETCH c_sysdate INTO l_sysdate;
               CLOSE c_sysdate;

             END IF;

             l_different_hours := l_event_date - l_sysdate ;
             l_different_hours  := l_different_hours  * 24 ;

             IF l_different_hours > nvl(l_cancel_hours,0)  THEN

               IF l_daemon_type in ('D','C','W') THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing for Daemon Type:' ||l_daemon_type );
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing for Event:' ||l_event_id);
                 hr_utility.set_location('Entering:'|| l_proc, 60);
           OTA_OM_TDB_WAITLIST_API.AUTO_ENROLL_FROM_WAITLIST
         (p_validate           => false
         ,p_business_group_id  => l_enr_business_group_id
         ,p_event_id        => l_event_id
         ,p_return_status      => l_return_status);

               ELSIF l_daemon_type = 'E' THEN  -- added for bug #1632104
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing for Daemon Type:' ||l_daemon_type );
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing for old Event:' ||l_old_event_id);
                 hr_utility.set_location('Entering:'|| l_proc, 60);
           OTA_OM_TDB_WAITLIST_API.AUTO_ENROLL_FROM_WAITLIST
         (p_validate           => false
         ,p_business_group_id  => l_enr_business_group_id
         ,p_event_id        => l_old_event_id
         ,p_return_status      => l_return_status);

               END IF;
            /*  ELSE
                 IF l_daemon_type = 'E'
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Please do a manual waitlist for Event :'|| l_old_event_id );
                 ELSE
                   IF l_daemon_type in ('D','C','W') then
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'Please do a manual waitlist for Event :'|| l_event_id );
                   END IF;
                 END IF; */
             END IF;

        END IF;
     END IF;
      END IF;
      IF l_return_status = 'T' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Committing for Booking_id :' ||l_booking_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------------');
      COMMIT;
      ELSE
         rollback to Cancel_enrollment;
      END IF;
     exception
     when others then
    --
      l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 500);
      --
      --
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
      to_char(l_booking_id)||','||l_err_msg);

     -- fnd_message.raise_error;
      rollback to Cancel_enrollment;
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  END;
  END LOOP;
  CLOSE C_enrollment;
  hr_utility.set_location('Leaving:'|| l_proc, 70);
 exception
      when e_validation_error then
    --
      l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 100);
      --
      --
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
      to_char(l_booking_id)||','||l_err_msg);

      fnd_message.raise_error;

    -- A validation or unexpected error has occured
    --

   -- rollback to Cancel_enrollment;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

    when others then
    --
      l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 500);
      --
      --
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
      to_char(l_booking_id)||','||l_err_msg);

      fnd_message.raise_error;

    -- A validation or unexpected error has occured
    --

    --rollback to Cancel_enrollment;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

END cancel_enrollment;


--
-- ----------------------------------------------------------------------------
-- |------------------------------------< upd_max_attendee  >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to update event maximum atenddee and will be
--   called by Pricing API if Pricing Attribute in OM got changed.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_org_id,
--   p_max_attendee
--   p_uom
--   p_operation
--
-- Out Arguments:
-- x_return_status
-- x_msg_data
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

Procedure upd_max_attendee
(p_line_id in number,
p_org_id in number,
p_max_attendee in number,
p_uom   in varchar2,
p_operation in varchar2,
x_return_status out nocopy varchar2,
x_msg_data   out nocopy varchar2
)
IS

l_event_id           ota_events.event_id%type;
l_event_business_group_id     ota_events.business_group_id%type;
l_event_ovn          ota_events.object_version_number%type;
l_max_attendee       ota_events.maximum_attendees%type;
l_return_status            varchar2(1) := 'S';
l_booking_ovn                 ota_delegate_bookings.object_version_number%type;
l_finance_line_id             ota_finance_lines.finance_line_id%type;
l_tfl_ovn                     ota_finance_lines.object_version_number%type;
l_update_finance              varchar2(1);
l_booking_id                  ota_delegate_bookings.booking_id%type;
l_count           number;
l_proc            varchar2(72) := g_package||'upd_max_attendee';

CURSOR C_event IS
SELECT
  Event_ID,
  Business_Group_ID ,
  Object_Version_number,
  maximum_attendees
  FROM OTA_Events
  WHERE Line_Id = p_line_Id;


CURSOR c_booking is
SELECT
  booking_id,
  Object_Version_number,
  business_group_id,
  booking_status_type_id
  FROM OTA_Delegate_bookings
  WHERE event_Id = l_event_id and
  number_of_places = l_max_attendee;

CURSOR c_tfl IS
Select finance_line_id,
object_version_number
FROM OTA_FINANCE_LINES
WHERE booking_id = l_booking_id;


BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
 x_return_status := 'S';
 IF p_uom = 'EVT' AND p_operation = 'UPDATE' THEN

  OPEN C_event;
  FETCH c_event INTO l_event_id,
            l_event_business_group_id,
            l_event_ovn,
            l_max_attendee;
  IF c_event%found THEN
   IF l_max_attendee < p_max_attendee THEN
       hr_utility.set_location('Entering:'||l_proc, 10);
         ota_evt_upd.upd(
            p_Event_id        => l_Event_Id
            ,P_Business_Group_id    => l_event_Business_group_id
            ,P_Object_version_number => l_event_ovn
            ,p_maximum_attendees => p_max_attendee
            ,P_validate       => False);

        /* For bug 1819473 */
        For db in c_booking
           LOOP
            select count(*) into l_count
            from ota_delegate_bookings
            where  event_id = l_event_id;
            if l_count = 1 then
             l_booking_id := db.booking_id;
             FOR r_tfl in c_tfl
             LOOP
               l_finance_line_id := r_tfl.finance_line_id;
               l_tfl_ovn  := r_tfl.object_version_number;

             END LOOP;
             if l_finance_line_id is not null then
                  l_update_finance := 'Y';
             else
                  l_update_finance := 'N';
             end if;

             l_booking_ovn := db.object_version_number;
             ota_tdb_shd.lck(db.booking_id,l_booking_ovn);

             ota_tdb_api_upd2.Update_Enrollment(
         p_booking_id         => db.booking_id
            ,p_event_id       => l_event_id
         ,p_business_group_id    => db.business_group_id
                   ,p_booking_status_type_id => db.booking_status_type_id
         ,p_object_version_number   => l_booking_ovn
         ,p_update_finance_line     => l_update_finance
         ,p_finance_line_id      => l_finance_line_id
                   ,p_number_of_places         => p_max_attendee
         ,p_validate       => False
         ,p_tfl_object_version_number  => l_tfl_ovn
         ,p_status_change_comments  => null); /* Bug# 3469326 */

            end if;
           END LOOP;
       /* END  bug 1819473 */

   END IF;
  END IF;
   CLOSE c_event;
    hr_utility.set_location(' Leaving:'||l_proc, 20);
END IF;
 EXCEPTION
 WHEN OTHERS THEN
  x_return_status := 'E';
  x_msg_data := 'OTA_13894_UPD_ERR';
 -- x_msg_data := SUBSTR(SQLERRM, 1, 200);

 -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

--
-- ----------------------------------------------------------------------------
-- |----------------------< initial_cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   errbuf
--   retcode
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

Procedure initial_cancel_enrollment
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2) as

p_user_id      number;
p_login_id     number;
l_completed    boolean;
failure     exception;
l_proc      varchar2(72) := g_package||'initial_cancel_enrollment';

BEGIN
   p_user_id  := fnd_profile.value('USER_ID');
   p_login_id := fnd_profile.value('LOGIN_ID');

   ota_cancel_api.cancel_enrollment(p_user_id,
                    p_login_id);
   EXCEPTION
     when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
      ||','||SUBSTR(SQLERRM, 1, 500));

END;


end ota_cancel_api ;

/
