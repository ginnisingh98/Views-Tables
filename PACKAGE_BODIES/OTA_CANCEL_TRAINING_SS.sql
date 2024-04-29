--------------------------------------------------------
--  DDL for Package Body OTA_CANCEL_TRAINING_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CANCEL_TRAINING_SS" AS
/* $Header: otssctrn.pkb 120.0 2005/05/29 07:33:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------<create_enroll_wf_process>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to set the item attributes in workflow.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_item_key
--   p_item_type
--   p_person_id
--   p_event_title
--   p_course_start_date
--   p_course_end_date
-- Out Arguments:
--   x_return_status
--   x_msg_data
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
------------------------------------------------------------------------------
PROCEDURE create_enroll_wf_process
          (x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_item_key           IN wf_items.item_key%TYPE,
           p_item_type          IN wf_items.item_type%TYPE,
           p_person_id          IN number default NULL,
           p_event_title        IN ota_events.title%TYPE,
           p_course_start_date  IN ota_events.course_start_date%TYPE,
           p_course_end_date    IN ota_events.course_end_date%TYPE,
           p_version_name IN ota_activity_versions.Version_name%type )
--
--
--
IS
--
l_proc                  VARCHAR2(72) := 'ota_cancel_enrollment_ss.create_enroll_wf_process';
l_current_username      VARCHAR2(80):= fnd_profile.value('USERNAME');
l_current_userid        NUMBER := fnd_profile.value('USER_ID');
l_display_person_id     fnd_user.employee_id%TYPE;
l_current_person_name   VARCHAR2(80);
l_person_displayname    per_all_people_f.full_name%TYPE;
l_creator_displayname   per_all_people_f.full_name%TYPE;
--
--Bug 2480134
l_supervisor_id         per_all_people_f.person_id%Type;
l_supervisor_username   fnd_user.user_name%TYPE;
l_supervisor_full_name  per_all_people_f.full_name%TYPE;
--Bug 2480134
CURSOR person_username_csr (p_person_id IN NUMBER) IS
SELECT user_name
FROM   fnd_user
WHERE  employee_id = p_person_id;
--
CURSOR display_person_id_csr (l_current_user_id IN NUMBER) IS
SELECT employee_id
FROM   fnd_user
WHERE  user_id = l_current_userid;
--
CURSOR display_name_csr (l_display_person_id IN NUMBER) IS
                        -- ,p_course_start_date IN DATE,
                        -- p_course_end_date IN DATE) IS
SELECT full_name
FROM   per_all_people_f p
WHERE  person_id = l_display_person_id
  --Modified for bug#4057241
  --AND  effective_start_date <= p_course_start_date
  --AND  effective_start_date <= nvl(p_course_start_date, SYSDATE)
  --AND  NVL(effective_end_date, SYSDATE) >= NVL(p_course_end_date, SYSDATE);
    AND trunc(sysdate) between p.effective_start_date and p.effective_end_date;
--
-- Bug 2480134
  CURSOR csr_supervisor_id IS
  SELECT asg.supervisor_id, per.full_name
    FROM per_all_assignments_f asg,
         per_all_people_f per
   WHERE asg.person_id = p_person_id
     AND per.person_id = asg.supervisor_id
     AND asg.primary_flag = 'Y'
     AND trunc(sysdate)
 BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND trunc(sysdate)
 BETWEEN per.effective_start_date AND per.effective_end_date;

 CURSOR csr_supervisor_user IS
 SELECT user_name
   FROM fnd_user
  WHERE employee_id= l_supervisor_id;
-- Bug 2480134

BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 10);
-- Get the current user name
--
   OPEN  person_username_csr (p_person_id);
   FETCH person_username_csr INTO l_current_person_name;
   CLOSE person_username_csr;
--
-- Get the current display person id
--
   OPEN  display_person_id_csr (l_current_userid);
   FETCH display_person_id_csr INTO l_display_person_id;
   CLOSE display_person_id_csr;
--
-- Get the person display name
--
   OPEN  display_name_csr (p_person_id);
                          --,p_course_start_date,
                          -- p_course_end_date);
   FETCH display_name_csr INTO l_person_displayname;
   CLOSE display_name_csr;

-- Get value for creator display name attribute if current user is
-- different than person whose class will be canceled
--
   IF l_display_person_id <> p_person_id THEN
--
      OPEN  display_name_csr (l_display_person_id);
                              --,p_course_start_date,
                             -- p_course_end_date);
      FETCH display_name_csr INTO l_creator_displayname;
      CLOSE display_name_csr;
--
   ELSE
      l_creator_displayname := l_person_displayname;
   END IF;

--Bug 2480134
      FOR a IN csr_supervisor_id LOOP
          l_supervisor_id := a.supervisor_id;
          l_supervisor_full_name := a.full_name;
      END LOOP;


     FOR b IN csr_supervisor_user LOOP
         l_supervisor_username := b.user_name;
     END LOOP;


      wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'SUPERVISOR_USERNAME',
             l_supervisor_username);


        wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'SUPERVISOR_DISPLAY_NAME',
             l_supervisor_full_name);

         wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'SUPERVISOR_ID',
             l_supervisor_id);

--Bug 2480134
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'OTA_EVENT_TITLE',
             p_event_title);
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'CURRENT_PERSON_ID',
             p_person_id);
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'CURRENT_PERSON_USERNAME',
             l_current_person_name);
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'CREATOR_PERSON_USERNAME',
             l_current_username);
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'CURRENT_PERSON_DISPLAY_NAME',
             l_person_displayname);
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'APPROVAL_CREATOR_DISPLAY_NAME',
             l_creator_displayname);
--
   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'OTA_COURSE_START_DATE',
             p_course_start_date);

   wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'OTA_ACTIVITY_VERSION_NAME',
             p_version_name);

--
  hr_utility.set_location('Leaving:'||l_proc, 20);
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLCODE||': '||SUBSTR(SQLERRM, 1, 950);
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
--
END create_enroll_wf_process;
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the entry point to this package and will be called from the
--   View Enrollment Details Screen on pressing 'Submit'.
--   This procedure will be used to call the cancel the enrollment Id passed in and
--   update the Enrollment with the Cancellation details.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_init_msg_list
--   p_booking_id
--   p_event_id
--   p_person_id
--   p_booking_status_type_id
--   p_cancel_reason
--   p_username
--   p_waitlist_size
--   p_item_key
--   p_item_type
--
-- Out Arguments:
--   x_return_status
--   x_msg_count
--   x_msg_data
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
PROCEDURE cancel_enrollment
                        (p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_booking_id IN NUMBER,
                         p_event_id IN NUMBER,
                         p_person_id IN NUMBER,
                         p_booking_status_type_id IN NUMBER,
                         p_cancel_reason IN VARCHAR2,
                         p_username IN VARCHAR2,
                         p_waitlist_size IN NUMBER,
                         p_item_key IN VARCHAR2 DEFAULT NULL,
                         p_item_type IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information_category IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information1 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information2 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information3 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information4 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information5 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information6 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information7 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information8 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information9 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information10 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information11 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information12 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information13 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information14 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information15 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information16 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information17 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information18 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information19 IN VARCHAR2 DEFAULT NULL,
			 p_tdb_information20 IN VARCHAR2 DEFAULT NULL
                         )
--
IS
--
-- ------------------------
--  event_csr variables
-- ------------------------
--
    l_event_title             ota_events.title%TYPE;
    l_event_status            ota_events.event_status%TYPE;
    l_course_start_date       ota_events.course_start_date%TYPE;
    l_course_start_time       ota_events.course_start_time%TYPE;
    l_course_end_date         ota_events.course_start_date%TYPE;
    l_owner_id                ota_events.owner_id%TYPE;
--
-- ------------------------
--  booking_csr variables
-- ------------------------
--
    l_date_booking_placed     ota_delegate_bookings.date_booking_placed%TYPE;
    l_content_player_status   ota_delegate_bookings.content_player_status%TYPE;
    l_object_version_number   ota_delegate_bookings.object_version_number%TYPE;
--
-- ------------------------
--  Finance_csr Variables
-- ------------------------
--
    l_finance_line_id	     ota_finance_lines.finance_line_id%TYPE;
    l_finance_header_id	     ota_finance_lines.finance_header_id%TYPE;
    l_transfer_status  	     ota_finance_lines.transfer_status%TYPE;
    lf_booking_id            ota_finance_lines.booking_id%TYPE;
    lf_object_version_number ota_finance_lines.object_version_number%TYPE;
    l_sequence_number        ota_finance_lines.sequence_number%TYPE;
    l_finance_count          number(10);
    l_cancelled_flag         ota_finance_lines.cancelled_flag%type;
    l_cancel_header_id       ota_finance_headers.finance_header_id%TYPE;
--
-- ------------------------
--  header_csr Variables
-- ------------------------
--
    lh_finance_header_id     ota_finance_headers.finance_header_id%TYPE;
    lh_cancelled_flag        ota_finance_headers.cancelled_flag%TYPE;
    lh_transfer_status       ota_finance_headers.transfer_status%TYPE;
    lh_object_version_number ota_finance_headers.object_version_number%TYPE;
--
-- ------------------------
--  other local Variables
-- ------------------------
--
    l_hours_until_class_starts 	NUMBER;
    l_minimum_advance_notice 	NUMBER;
    l_auto_waitlist_days 	NUMBER;
    l_sysdate 			DATE := SYSDATE;
    l_return_status 		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_data 			VARCHAR2(1000);
    l_daemon_flag 		ota_delegate_bookings.daemon_flag%TYPE;
    l_daemon_type 		ota_delegate_bookings.daemon_type%TYPE;
    lb_object_version_number 	ota_delegate_bookings.object_version_number%TYPE;
    l_wf_exception 		EXCEPTION;
    ltt_item_attribute 		hr_workflow_service.g_varchar2_tab_type;
    ltt_item_attribute_value 	hr_workflow_service.g_varchar2_tab_type;
    l_proc                  	VARCHAR2(72) := 'ota_cancel_enrollment_ss.cancel_enrollment';
    l_activity_version_name   ota_activity_versions.version_name%TYPE;
--
CURSOR event_csr (p_event_id ota_events.event_id%TYPE)
IS
SELECT a.version_name,
       e.title,
       e.event_status,
       e.course_start_date,
       e.course_start_time,
       e.course_end_date,
       e.owner_id
FROM   ota_events_vl e,
       ota_activity_versions_tl a
WHERE  a.activity_version_id = e.activity_version_id
AND    e.event_id = p_event_id
AND    language=userenv('LANG');
--

CURSOR booking_csr (p_booking_id ota_delegate_bookings.booking_id%TYPE)
IS
SELECT b.date_booking_placed, b.content_player_status, b.object_version_number
FROM   ota_delegate_bookings b
WHERE  b.booking_id = p_booking_id;
--
CURSOR finance_csr (p_booking_id ota_finance_lines.booking_id%TYPE)
IS
SELECT fln.finance_line_id finance_line_id,
	 fln.finance_header_id finance_header_id,
	 fln.transfer_status transfer_status,
	 fln.booking_id booking_id,
	 fln.object_version_number object_version_number,
	 fln.sequence_number sequence_number,
	 fln.Cancelled_flag cancelled_flag
FROM   ota_finance_lines fln
WHERE  fln.booking_id = p_booking_id;
--
CURSOR finance_count_csr (p_finance_header_id ota_finance_lines.finance_header_id%TYPE)
IS
SELECT COUNT(*)
FROM	 ota_finance_lines fln
WHERE	 fln.finance_header_id = p_finance_header_id;
--
CURSOR header_csr (p_booking_id ota_finance_lines.booking_id%TYPE)
IS
SELECT flh.finance_header_id finance_header_id,
	 flh.cancelled_flag cancelled_flag,
	 flh.transfer_status transfer_status,
	 flh.object_version_number object_version_number
FROM   ota_finance_headers flh,
       ota_finance_lines fln
WHERE  flh.finance_header_id =  fln.finance_header_id
   AND fln.booking_id = p_booking_id;
--
--
CURSOR  C_USER(p_owner_id  NUMBER) IS
SELECT  USER_NAME
  FROM  FND_USER
 WHERE  Employee_id = p_owner_id;
l_username 	fnd_user.user_name%TYPE;
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 10);

   IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;
--
   OPEN event_csr (p_event_id);
   FETCH event_csr INTO l_activity_version_name,
                        l_event_title,
                        l_event_status,
                        l_course_start_date,
                        l_course_start_time,
                        l_course_end_date, --l_course_start_date,
			l_owner_id;
   CLOSE event_csr;
--
   IF l_owner_id IS NULL THEN
      l_owner_id := fnd_profile.value('OTA_DEFAULT_EVENT_OWNER');
   END IF;


   OPEN c_user(l_owner_id);
   FETCH c_user INTO l_username;
   CLOSE c_user;

   OPEN booking_csr (p_booking_id);
   FETCH booking_csr INTO l_date_booking_placed,
                          l_content_player_status,
                          l_object_version_number;
   CLOSE booking_csr;
--
   OPEN  finance_csr (p_booking_id);
   FETCH finance_csr INTO l_finance_line_id,
                      l_finance_header_id,
                      l_transfer_status,
                      lf_booking_id,
                      lf_object_version_number,
                      l_sequence_number,
                      l_cancelled_flag ;
--
--Start Bug 2700158--
 l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MON-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
--End Bug 2700158--

   IF finance_csr%found  THEN
--
      l_minimum_advance_notice := NVL(TO_NUMBER(fnd_profile.value('OTA_CANCEL_HOURS_BEFORE_EVENT')), 0);
--
 --l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MON-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);


--
      IF l_transfer_status = 'ST' OR
         l_cancelled_flag = 'Y' OR
         l_content_player_status IS NOT NULL OR
         l_hours_until_class_starts < l_minimum_advance_notice THEN
         NULL;
      ELSE         --  Call Finance Lines API (Cancel Finance Line)
--
         OPEN  finance_count_csr (l_finance_header_id);
         FETCH finance_count_csr INTO l_finance_count;
         CLOSE finance_count_csr;
--
         IF l_finance_count = 1 THEN  --  If only one Finance Line
--
            OPEN  header_csr (p_booking_id);
            FETCH header_csr INTO lh_finance_header_id,
                              lh_cancelled_flag,
                              lh_transfer_status,
                              lh_object_version_number;
            CLOSE header_csr;

--
            IF lh_transfer_status <> 'ST' or lh_cancelled_flag <>'Y'  THEN  -- Call Finance Header API
--                                                                             to Cancel Finance Header
--
               ota_tfh_api_business_rules.cancel_header
                     (p_finance_header_id => lh_finance_header_id,
                      p_cancel_header_id  => l_cancel_header_id,
                      p_date_raised       => l_sysdate,
                      p_validate          => false,
                      p_commit            => false);
            END IF;
--
         ELSE
--
             ota_tfl_api_upd.upd(p_finance_line_id       =>  l_finance_line_id,
                                p_date_raised           =>  l_sysdate,
                                p_cancelled_flag        => 'Y',
                                p_object_version_number =>  lf_object_version_number,
                                p_sequence_number       =>  l_sequence_number,
                                p_validate              =>  false,
                                p_transaction_type      => 'CANCEL_HEADER_LINE');
--
         END IF;
--
--
      END IF; -- For Lines;
--
   END IF;
--
   CLOSE finance_csr;
--
--  Initialize workflow setings
--
   l_auto_waitlist_days := TO_NUMBER(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));
--
   IF (p_waitlist_size > 0) THEN
--
      IF (l_hours_until_class_starts >= l_auto_waitlist_days) THEN
--
         l_daemon_flag := 'Y';
         l_daemon_type := 'W';
--
      ELSE
--
	IF l_username IS NOT NULL THEN
           ota_initialization_wf.manual_waitlist
                  (p_itemtype    => 'OTWF',
                   p_process     => 'OTA_MANUAL_WAITLIST',
                   p_event_title => l_event_title,
                   p_event_id    => p_event_id,
                   p_item_key    => p_booking_id||':'||to_char(l_sysdate,'DD-MON-YYYY:HH24:MI:SS'),
--                                    fnd_date.date_to_displaydate(l_sysdate),
                   p_user_name   => l_username);
        END IF;
--
      END IF;
--
   ELSE
--
      l_daemon_flag := NULL;
      l_daemon_type := NULL;
--
   END IF;
--
--  Call update enrollment API to cancel Enrollment
--
   ota_tdb_api_upd2.update_enrollment
            (p_booking_id                 => p_booking_id,
             p_booking_status_type_id     => p_booking_status_type_id,
             p_object_version_number      => l_object_version_number,
             p_event_id		          => p_event_id,
             p_status_change_comments     => p_cancel_reason,  --Bug 2332743
             p_tfl_object_version_number  => lf_object_version_number,
             p_finance_line_id            => l_finance_line_id,
             p_daemon_flag                => l_daemon_flag,
             p_daemon_type                => l_daemon_type,
             p_date_status_changed        => l_sysdate,
             p_date_booking_placed        => l_date_booking_placed,
	     p_tdb_information_category   => p_tdb_information_category,
             p_tdb_information1     	  => p_tdb_information1,
             p_tdb_information2     	  => p_tdb_information2,
             p_tdb_information3     	  => p_tdb_information3,
             p_tdb_information4     	  => p_tdb_information4,
             p_tdb_information5     	  => p_tdb_information5,
             p_tdb_information6     	  => p_tdb_information6,
             p_tdb_information7     	  => p_tdb_information7,
             p_tdb_information8     	  => p_tdb_information8,
             p_tdb_information9     	  => p_tdb_information9,
             p_tdb_information10     	  => p_tdb_information10,
             p_tdb_information11     	  => p_tdb_information11,
             p_tdb_information12     	  => p_tdb_information12,
             p_tdb_information13     	  => p_tdb_information13,
             p_tdb_information14     	  => p_tdb_information14,
             p_tdb_information15     	  => p_tdb_information15,
             p_tdb_information16     	  => p_tdb_information16,
             p_tdb_information17     	  => p_tdb_information17,
             p_tdb_information18     	  => p_tdb_information18,
             p_tdb_information19     	  => p_tdb_information19,
             p_tdb_information20     	  => p_tdb_information20
	     );
--
--  Call cancel enrollment workflow
--
    create_enroll_wf_process
             (x_return_status            => l_return_status,
              x_msg_data                 => l_msg_data,
              p_item_key                 => p_item_key,
              p_item_type                => p_item_type ,
              p_person_id                => p_person_id,
              p_event_title              => l_event_title,
              p_course_start_date        => l_course_start_date,
              p_course_end_date          => l_course_end_date,
              p_version_name             =>  l_activity_version_name);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE l_wf_exception;
   END IF;
--
-- Populate standard return values if cancel enrollment
-- and work flow creation were successful
--
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 1;
   x_msg_data := 'OTA_CANCEL_ENROLLMENT';  -- return message name
--
  hr_utility.set_location('Leaving:'||l_proc, 20);

EXCEPTION
--
   WHEN l_wf_exception THEN
--
      FND_MESSAGE.SET_NAME('OTA', 'OTA_IBE_UNEXP_ERR');
      FND_MESSAGE.SET_TOKEN('OTA_IBE_UNEXP_ERR_MSG', l_msg_data);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                p_data => x_msg_data);
      hr_utility.set_location('Leaving:'||l_proc, 30);

      x_return_status := 'E';
  --

--
   WHEN OTHERS THEN
--
      l_msg_data := SQLCODE||': '||SUBSTR(SQLERRM, 1, 950);
      FND_MESSAGE.SET_NAME('OTA', 'OTA_IBE_UNEXP_ERR');
      FND_MESSAGE.SET_TOKEN('OTA_IBE_UNEXP_ERR_MSG', l_msg_data);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                                p_data => x_msg_data);
      x_return_status := 'E';
      hr_utility.set_location('Leaving:'||l_proc, 40);
--
END cancel_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_booking_status_comments >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the comments from the booking history table for the
-- booking_id and booking_status_type_id passed in as parameters.
--
--

FUNCTION get_booking_status_comments(p_booking_id IN NUMBER,
                                     p_booking_status_type_id IN NUMBER) RETURN VARCHAR2
IS
CURSOR comments_cr IS
SELECT bsh.comments
  FROM ota_booking_status_histories bsh
 WHERE bsh.booking_id = p_booking_id
   AND bsh.booking_status_type_id = p_booking_status_type_id
 ORDER BY bsh.start_date ASC;
--
  --
  l_comments    ota_booking_status_histories.comments%TYPE := null;
  l_proc        varchar2(72) :=  'ota_cancel_enrollment_ss.get_booking_status_comments';
  --
begin
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    --
        FOR comments_rec IN comments_cr
       LOOP
            l_comments := comments_rec.comments;

        END LOOP;

RETURN l_comments;
    --
  --
EXCEPTION
     WHEN others then
   RETURN l_comments;
END get_booking_status_comments;

END ota_cancel_training_ss;

/
