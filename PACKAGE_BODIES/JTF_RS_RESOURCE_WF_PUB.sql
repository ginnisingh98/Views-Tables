--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_WF_PUB" AS
/* $Header: jtfrswrb.pls 120.0.12010000.2 2008/10/03 08:27:50 avjha ship $ */

   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_RS_RESOURCE_WF_PUB';

  /* Procedure to start the update resource workflow */

   PROCEDURE start_update_resource_wf (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_resource_id            IN       jtf_rs_resource_extns.resource_id%type,
      p_category               IN       jtf_rs_resource_extns.category%type,
      p_resource_number        IN       jtf_rs_resource_extns.resource_number%type,
      p_resource_name          IN       jtf_rs_resource_extns_vl.resource_name%type default fnd_api.g_miss_char,
      p_address_id             IN       jtf_rs_resource_extns.address_id%type default fnd_api.g_miss_num,
      p_source_email           IN       jtf_rs_resource_extns.source_email%type default fnd_api.g_miss_char,
      p_source_phone           IN       jtf_rs_resource_extns.source_phone%type default fnd_api.g_miss_char,
      p_source_office          IN       jtf_rs_resource_extns.source_office%type default fnd_api.g_miss_char,
      p_source_location        IN       jtf_rs_resource_extns.source_location%type default fnd_api.g_miss_char,
      p_source_mailstop        IN       jtf_rs_resource_extns.source_mailstop%type default fnd_api.g_miss_char,
      p_time_zone              IN       jtf_rs_resource_extns.time_zone%type default fnd_api.g_miss_num,
      p_support_site_id        IN       jtf_rs_resource_extns.support_site_id%type default fnd_api.g_miss_num,
      p_primary_language       IN       jtf_rs_resource_extns.primary_language%type default fnd_api.g_miss_char,
      p_secondary_language     IN       jtf_rs_resource_extns.secondary_language%type default fnd_api.g_miss_char,
      p_cost_per_hr            IN       jtf_rs_resource_extns.cost_per_hr%type default fnd_api.g_miss_num,
      p_attribute_access_level IN       jtf_rs_table_attributes_b.attribute_access_level%type,
      p_object_version_number  IN       jtf_rs_resource_extns.object_version_number%type,
      --p_wf_display_name      IN       VARCHAR2 DEFAULT NULL,
      p_wf_process             IN       VARCHAR2 DEFAULT 'EMP_UPDATE_PROCESS',
      p_wf_item_type           IN       VARCHAR2 DEFAULT 'EMP_TYPE',
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_source_mobile_phone    IN       jtf_rs_resource_extns.source_mobile_phone%type default fnd_api.g_miss_char,
      p_source_pager           IN       jtf_rs_resource_extns.source_pager%type default fnd_api.g_miss_char
   )

   IS

      l_api_version             CONSTANT NUMBER := 1.0;
      l_api_name                CONSTANT VARCHAR2(30) := 'START_RS_RESOURCE_WF_PUB';
      l_wf_process_id           NUMBER;
      l_itemkey                 wf_item_activity_statuses.item_key%TYPE;
      l_userkey                 varchar2(30);

      l_resource_id             jtf_rs_resource_extns.resource_id%type        := p_resource_id;
      l_attr_access_level       jtf_rs_table_attributes_b.attribute_access_level%type := p_attribute_access_level;
      l_object_version_number   jtf_rs_resource_extns.object_version_number%type := p_object_version_number;

      l_new_address_id          jtf_rs_resource_extns.address_id%type;
      l_new_resource_name       jtf_rs_resource_extns_vl.resource_name%type;
      l_new_phone_number        jtf_rs_resource_extns.source_phone%type;
      l_new_email_address       jtf_rs_resource_extns.source_email%type;
      l_new_source_office       jtf_rs_resource_extns.source_office%type;
      l_new_source_location     jtf_rs_resource_extns.source_location%type;
      l_new_source_mailstop     jtf_rs_resource_extns.source_mailstop%type;
      l_new_source_mobile_phone jtf_rs_resource_extns.source_mobile_phone%type;
      l_new_source_pager        jtf_rs_resource_extns.source_pager%type;
      l_new_time_zone           jtf_rs_resource_extns.time_zone%type;
      l_new_support_site_id     jtf_rs_resource_extns.support_site_id%type;
      l_new_primary_language    jtf_rs_resource_extns.primary_language%type;
      l_new_secondary_language  jtf_rs_resource_extns.secondary_language%type;
      l_new_cost_per_hr         jtf_rs_resource_extns.cost_per_hr%type;

      l_category                jtf_rs_resource_extns.category%type;
      l_resource_number         jtf_rs_resource_extns.resource_number%type;
      l_source_name             jtf_rs_resource_extns.source_name%type;
      l_old_resource_name       jtf_rs_resource_extns_vl.resource_name%type;
      l_old_address_id          jtf_rs_resource_extns.address_id%type;
      l_old_phone_number        jtf_rs_resource_extns.source_phone%type;
      l_old_email_address       jtf_rs_resource_extns.source_email%type;
      l_old_source_office       jtf_rs_resource_extns.source_office%type;
      l_old_source_location     jtf_rs_resource_extns.source_location%type;
      l_old_source_mailstop     jtf_rs_resource_extns.source_mailstop%type;
      l_old_source_mobile_phone jtf_rs_resource_extns.source_mobile_phone%type;
      l_old_source_pager        jtf_rs_resource_extns.source_pager%type;
      l_old_time_zone           jtf_rs_resource_extns.time_zone%type;
      l_old_support_site_id     jtf_rs_resource_extns.support_site_id%type;
      l_old_primary_language    jtf_rs_resource_extns.primary_language%type;
      l_old_secondary_language  jtf_rs_resource_extns.secondary_language%type;
      l_old_cost_per_hr         jtf_rs_resource_extns.cost_per_hr%type;

      l_old_address             varchar2(2000);
      l_new_address             varchar2(2000);

      l_old_timezone_name        varchar2(100);
      l_new_timezone_name        varchar2(100);

      l_old_support_site        varchar2(100);
      l_new_support_site        varchar2(100);

      l_user_id                 jtf_rs_resource_extns.user_id%type;
      l_source_id               jtf_rs_resource_extns.source_id%type;
      l_source_mgr_id           jtf_rs_resource_extns.source_mgr_id%type;

      l_source_number           jtf_rs_resource_extns.source_number%type;

      l_approver                fnd_user.user_name%type;
      l_requestor               fnd_user.user_name%type;

      l_errname                 varchar2(60);
      l_errmsg                  varchar2(2000);
      l_errstack                varchar2(4000);

      l_approved		varchar2(2);
      l_error_flag		varchar2(1) 	:= 'N';

      CURSOR c_user (l_employee_id number) IS
         SELECT user_name
         FROM fnd_user
         WHERE employee_id = l_employee_id
         ORDER by creation_date desc;

      CURSOR c_resource (l_resource_id number) IS
         SELECT category, resource_number, resource_name, source_name, source_number,
                source_phone, source_email, source_office, source_location,
                source_mailstop, source_mobile_phone, source_pager, time_zone,
                support_site_id, primary_language, secondary_language, cost_per_hr,
                address_id, user_id, source_id, source_mgr_id
         FROM jtf_rs_resource_extns_vl
         WHERE resource_id = l_resource_id;

      CURSOR c_address (l_address_id number) IS
         SELECT description
         FROM hr_locations
         WHERE location_id = l_address_id;

      CURSOR c_timezone (l_timezone_id number) IS
         SELECT name
         FROM fnd_timezones_vl
         WHERE upgrade_tz_id = l_timezone_id;

      CURSOR c_support_site (l_support_site_id number) IS
         SELECT a.city
         FROM hz_locations a, hz_party_site_uses c, hz_party_sites b
         WHERE c.site_use_type = 'SUPPORT_SITE'
         AND c.party_site_id = b.party_site_id
         AND a.location_id = b.location_id
         AND b.party_site_id = l_support_site_id;

      CURSOR c_resource_update (l_resource_id number) IS
         SELECT
            DECODE (p_resource_name, fnd_api.g_miss_char, resource_name, p_resource_name) resource_name,
            DECODE (p_source_email, fnd_api.g_miss_char, source_email, p_source_email) source_email,
            DECODE (p_source_phone, fnd_api.g_miss_char, source_phone, p_source_phone) source_phone,
            DECODE (p_source_office, fnd_api.g_miss_char, source_office, p_source_office) source_office,
            DECODE (p_source_location, fnd_api.g_miss_char, source_location, p_source_location) source_location,
            DECODE (p_source_mailstop, fnd_api.g_miss_char, source_mailstop, p_source_mailstop) source_mailstop,
            DECODE (p_source_mobile_phone, fnd_api.g_miss_char, source_mobile_phone, p_source_mobile_phone) source_mobile_phone,
            DECODE (p_source_pager, fnd_api.g_miss_char, source_pager, p_source_pager) source_pager,
            DECODE (p_time_zone, fnd_api.g_miss_num, time_zone, p_time_zone) time_zone,
            DECODE (p_support_site_id, fnd_api.g_miss_num, support_site_id, p_support_site_id) support_site_id,
            DECODE (p_primary_language, fnd_api.g_miss_char, primary_language, p_primary_language) primary_language,
            DECODE (p_secondary_language, fnd_api.g_miss_char, secondary_language, p_secondary_language) secondary_language,
            DECODE (p_cost_per_hr, fnd_api.g_miss_num, cost_per_hr, p_cost_per_hr) cost_per_hr,
            DECODE (p_address_id, fnd_api.g_miss_num, address_id, p_address_id) address_id
         FROM jtf_rs_resource_extns_vl
         WHERE resource_id = l_resource_id;

      resource_rec   c_resource_update%ROWTYPE;

   BEGIN

      --dbms_output.put_line ('Begin Workflow API');

      SAVEPOINT start_rs_workflow;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF l_attr_access_level = 'UWA' THEN
         l_approved := 'A';
      ELSE
         l_approved := 'T';
      END IF;


      OPEN c_resource(l_resource_id);
      FETCH c_resource INTO l_category, l_resource_number, l_old_resource_name, l_source_name,
        l_source_number, l_old_phone_number, l_old_email_address, l_old_source_office,
        l_old_source_location, l_old_source_mailstop, l_old_source_mobile_phone,
        l_old_source_pager, l_old_time_zone, l_old_support_site_id, l_old_primary_language,
        l_old_secondary_language, l_old_cost_per_hr, l_old_address_id, l_user_id,
        l_source_id, l_source_mgr_id;
      IF c_resource%NOTFOUND THEN
         --dbms_output.put_line('The Resource passed is Invalid');
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_EMP_RESOURCE_ID');
         fnd_message.set_token('P_EMP_RESOURCE_ID', l_resource_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_resource;

      OPEN c_resource_update(l_resource_id);
      FETCH c_resource_update INTO resource_rec;
      IF c_resource_update%NOTFOUND THEN
         --dbms_output.put_line('The Resource passed is Invalid');
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_EMP_RESOURCE_ID');
         fnd_message.set_token('P_EMP_RESOURCE_ID', l_resource_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_resource_update;

      IF l_attr_access_level = 'UWA' THEN
         l_approved := 'A';
      ELSE
         l_approved := 'T';
      END IF;

      IF l_source_mgr_id is NULL THEN
         l_error_flag := 'Y';
         IF l_attr_access_level = 'UWA' THEN
            l_approved := 'AE';
         ELSE
            l_approved := 'TE';
         END IF;
      ELSE
         OPEN c_user(l_source_mgr_id);
         FETCH c_user INTO l_approver;
         IF c_user%NOTFOUND THEN
            l_error_flag := 'Y';
            IF l_attr_access_level = 'UWA' THEN
               l_approved := 'AE';
            ELSE
               l_approved := 'TE';
            END IF;
         END IF;
         CLOSE c_user;
      END IF;

      l_new_address_id          := resource_rec.address_id;
      l_new_resource_name       := resource_rec.resource_name;
      l_new_phone_number        := resource_rec.source_phone;
      l_new_email_address       := resource_rec.source_email;
      l_new_source_office       := resource_rec.source_office;
      l_new_source_location     := resource_rec.source_location;
      l_new_source_mailstop     := resource_rec.source_mailstop;
      l_new_source_mobile_phone := resource_rec.source_mobile_phone;
      l_new_source_pager        := resource_rec.source_pager;
      l_new_time_zone           := resource_rec.time_zone;
      l_new_support_site_id     := resource_rec.support_site_id;
      l_new_primary_language    := resource_rec.primary_language;
      l_new_secondary_language  := resource_rec.secondary_language;
      l_new_cost_per_hr         := resource_rec.cost_per_hr;

      IF l_old_address_id IS NOT NULL THEN
        OPEN c_address (l_old_address_id);
        FETCH c_address INTO l_old_address;
        CLOSE c_address;
      END IF;

      IF l_old_time_zone IS NOT NULL THEN
        OPEN c_timezone (l_old_time_zone);
        FETCH c_timezone INTO l_old_timezone_name;
        CLOSE c_timezone;
      END IF;

      IF l_old_support_site_id IS NOT NULL THEN
        OPEN c_support_site (l_old_support_site_id);
        FETCH c_support_site INTO l_old_support_site;
        CLOSE c_support_site;
      END IF;

      SELECT jtf_rs_resource_wf_s.nextval INTO l_itemkey FROM dual;
      SELECT fnd_global.user_name INTO l_requestor FROM dual;

      IF p_address_id = fnd_api.g_miss_num THEN
         l_new_address := l_old_address;
      ELSE
         IF l_new_address_id IS NOT NULL THEN
            OPEN c_address (l_new_address_id);
            FETCH c_address INTO l_new_address;
            CLOSE c_address;
         END IF;
      END IF;

      IF p_time_zone = fnd_api.g_miss_num THEN
         l_new_timezone_name := l_old_timezone_name;
      ELSE
         IF l_new_time_zone IS NOT NULL THEN
            OPEN c_timezone (l_new_time_zone);
            FETCH c_timezone INTO l_new_timezone_name;
            CLOSE c_timezone;
         END IF;
      END IF;

      IF p_support_site_id = fnd_api.g_miss_num THEN
         l_new_support_site := l_old_support_site;
      ELSE
         IF l_new_support_site_id IS NOT NULL THEN
            OPEN c_support_site (l_new_support_site_id);
            FETCH c_support_site INTO l_new_support_site;
            CLOSE c_support_site;
         END IF;
      END IF;

      wf_engine.createprocess (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         process  => p_wf_process
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'P_APPROVED',
         avalue   => l_approved
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'ERROR_FLAG',
         avalue   => l_error_flag
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'USER',
         avalue   => l_approver
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'REQUESTOR',
         avalue   => l_requestor
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'ATTRIBUTE_ACCESS_LEVEL',
         avalue   => l_attr_access_level
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'OBJECT_VERSION_NUMBER',
         avalue   => l_object_version_number
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'CATEGORY',
         avalue   => l_category
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'ADDRESS_ID',
         avalue   => l_new_address_id
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'OLD_ADDRESS',
         avalue   => l_old_address
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'NEW_ADDRESS',
         avalue   => l_new_address
     );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'RESOURCE_ID',
         avalue   => l_resource_id
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'RESOURCE_NUMBER',
         avalue   => l_resource_number
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_NUMBER',
         avalue   => l_source_number
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_NAME',
         avalue   => l_source_name
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'RESOURCE_NAME',
         avalue   => l_old_resource_name
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'RESOURCE_NAME_NEW',
         avalue   => l_new_resource_name
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'PHONE_NUMBER',
         avalue   => l_old_phone_number
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'PHONE_NUMBER_NEW',
         avalue   => l_new_phone_number
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'EMAIL_ADDRESS',
         avalue   => l_old_email_address
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'EMAIL_ADDRESS_NEW',
         avalue   => l_new_email_address
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_OFFICE',
         avalue   => l_old_source_office
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_OFFICE_NEW',
         avalue   => l_new_source_office
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_LOCATION',
         avalue   => l_old_source_location
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_LOCATION_NEW',
         avalue   => l_new_source_location
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_MAILSTOP',
         avalue   => l_old_source_mailstop
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_MAILSTOP_NEW',
         avalue   => l_new_source_mailstop
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_MOBILE_PHONE',
         avalue   => l_old_source_mobile_phone
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_MOBILE_PHONE_NEW',
         avalue   => l_new_source_mobile_phone
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_PAGER',
         avalue   => l_old_source_pager
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SOURCE_PAGER_NEW',
         avalue   => l_new_source_pager
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'TIME_ZONE',
         avalue   => l_new_time_zone
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'TIMEZONE_NAME',
         avalue   => l_old_timezone_name
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'TIMEZONE_NAME_NEW',
         avalue   => l_new_timezone_name
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SUPPORT_SITE_ID',
         avalue   => l_new_support_site_id
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SUPPORT_SITE',
         avalue   => l_old_support_site
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SUPPORT_SITE_NEW',
         avalue   => l_new_support_site
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'PRIMARY_LANGUAGE',
         avalue   => l_old_primary_language
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'PRIMARY_LANGUAGE_NEW',
         avalue   => l_new_primary_language
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SECONDARY_LANGUAGE',
         avalue   => l_old_secondary_language
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'SECONDARY_LANGUAGE_NEW',
         avalue   => l_new_secondary_language
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'COST_PER_HR',
         avalue   => l_old_cost_per_hr
      );

      wf_engine.setitemattrtext (
         itemtype => p_wf_item_type,
         itemkey  => l_itemkey,
         aname    => 'COST_PER_HR_NEW',
         avalue   => l_new_cost_per_hr
      );

     wf_engine.startprocess (
         itemtype => p_wf_item_type,
         itemkey => l_itemkey
     );

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN

         ROLLBACK TO start_rs_workflow;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
            ROLLBACK TO start_rs_workflow ;

            wf_core.get_error(l_errname, l_errmsg, l_errstack);

            if (l_errname is not null) then
                  fnd_message.set_name('FND', 'WF_ERROR');
                  fnd_message.set_token('ERROR_MESSAGE', l_errmsg);
                        fnd_message.set_token('ERROR_STACK', l_errstack);
                        fnd_msg_pub.add;
            end if;

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END start_update_resource_wf;

   PROCEDURE check_error_flag (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   )
   IS

   l_resultout   VARCHAR2(200);

   BEGIN
      --
      -- RUN mode - normal process execution
      --
      IF (funcmode = 'RUN')
      THEN
         --
         -- Return process to run
         --
         l_resultout :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'ERROR_FLAG'
            );
         resultout := 'COMPLETE:' || l_resultout;

         RETURN;
      END IF;

      --
      -- CANCEL mode - activity 'compensation'
      --
      IF (funcmode = 'CANCEL')
      THEN
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT')
      THEN
         resultout := 'COMPLETE';
         RETURN;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.context (
            'EMP_TYPE',
            'Check Attribute Access Level',
            itemtype,
            itemkey,
            actid,
            funcmode
         );
         RAISE;

   END check_error_flag;


   PROCEDURE check_attr_access_level (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   )
   IS

      l_resultout   VARCHAR2(200);

   BEGIN
      --
      -- RUN mode - normal process execution
      --
      IF (funcmode = 'RUN')
      THEN
         --
         -- Return process to run
         --
         l_resultout :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'ATTRIBUTE_ACCESS_LEVEL'
            );
         resultout := 'COMPLETE:' || l_resultout;

         RETURN;
      END IF;

      --
      -- CANCEL mode - activity 'compensation'
      --
      IF (funcmode = 'CANCEL')
      THEN
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT')
      THEN
         resultout := 'COMPLETE';
         RETURN;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.context (
            'EMP_TYPE',
            'Check Attribute Access Level',
            itemtype,
            itemkey,
            actid,
            funcmode
         );
         RAISE;

   END check_attr_access_level;

  PROCEDURE call_update_resource_api (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   )
   IS

      l_resource_id         jtf_rs_resource_extns.resource_id%type;
      l_address_id          jtf_rs_resource_extns.address_id%type;
      l_resource_number     jtf_rs_resource_extns.resource_number%type;
      l_resource_name       jtf_rs_resource_extns_vl.resource_name%type;
      l_source_name         jtf_rs_resource_extns.source_name%type;
      l_source_phone        jtf_rs_resource_extns.source_phone%type;
      l_source_email        jtf_rs_resource_extns.source_email%type;
      l_source_office       jtf_rs_resource_extns.source_office%type;
      l_source_location     jtf_rs_resource_extns.source_location%type;
      l_source_mailstop     jtf_rs_resource_extns.source_mailstop%type;
      l_source_mobile_phone jtf_rs_resource_extns.source_mobile_phone%type;
      l_source_pager        jtf_rs_resource_extns.source_pager%type;
      l_time_zone           jtf_rs_resource_extns.time_zone%type;
      l_support_site_id     jtf_rs_resource_extns.support_site_id%type;
      l_primary_language    jtf_rs_resource_extns.primary_language%type;
      l_secondary_language  jtf_rs_resource_extns.secondary_language%type;
      l_cost_per_hr         jtf_rs_resource_extns.cost_per_hr%type;

      l_object_version_number   jtf_rs_resource_extns.object_version_number%type;
      x_msg_count               number;
      x_msg_data                varchar2(2000);
      x_resultout               varchar2(200);
      x_return_status           varchar2(1);

      l_msg_data                varchar2(2000);
      l_msg_data1               varchar2(2000);
      l_msg_index_out           varchar2(2000);

      l_approved		varchar2(2);

   BEGIN

      --
      -- RUN mode - normal process execution
      --
      IF (funcmode = 'RUN')
      THEN
         --
         -- Return process to run
         --

         l_resource_id :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'RESOURCE_ID'
            );

         l_address_id :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'ADDRESS_ID'
            );
         l_resource_number :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'RESOURCE_NUMBER'
            );
         l_source_name :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_NAME'
            );
         l_approved :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'P_APPROVED'
            );
         l_resource_name :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'RESOURCE_NAME_NEW'
            );
         l_source_phone :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'PHONE_NUMBER_NEW'
            );
         l_source_email :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'EMAIL_ADDRESS_NEW'
            );
         l_source_location :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_LOCATION_NEW'
            );
         l_source_office :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_OFFICE_NEW'
            );
         l_source_mailstop :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_MAILSTOP_NEW'
            );
         l_source_mobile_phone :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_MOBILE_PHONE_NEW'
            );
         l_source_pager :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SOURCE_PAGER_NEW'
            );
         l_time_zone :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'TIME_ZONE'
            );
         l_support_site_id :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SUPPORT_SITE_ID'
            );
         l_primary_language :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'PRIMARY_LANGUAGE_NEW'
            );
         l_secondary_language :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'SECONDARY_LANGUAGE_NEW'
            );
         l_cost_per_hr :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'COST_PER_HR_NEW'
            );
         l_object_version_number :=
            wf_engine.getitemattrtext (
               itemtype => itemtype,
               itemkey => itemkey,
               aname => 'OBJECT_VERSION_NUMBER'
            );

      jtf_rs_res_sswa_pub.update_resource (
         P_API_VERSION             =>   1.0,
         P_RESOURCE_ID             =>   l_resource_id,
         P_RESOURCE_NUMBER         =>   l_resource_number,
         P_RESOURCE_NAME           =>   l_resource_name,
         P_SOURCE_NAME             =>   l_source_name,
         P_SOURCE_EMAIL            =>   l_source_email,
         P_SOURCE_PHONE            =>   l_source_phone,
         P_SOURCE_OFFICE           =>   l_source_office,
         P_SOURCE_LOCATION         =>   l_source_location,
         P_SOURCE_MAILSTOP         =>   l_source_mailstop,
         P_TIME_ZONE               =>   l_time_zone,
         P_SUPPORT_SITE_ID         =>   l_support_site_id,
         P_PRIMARY_LANGUAGE        =>   l_primary_language,
         P_SECONDARY_LANGUAGE      =>   l_secondary_language,
         P_COST_PER_HR             =>   l_cost_per_hr,
         P_ADDRESS_ID              =>   l_address_id,
         P_OBJECT_VERSION_NUMBER   =>   l_object_version_number,
         P_APPROVED                =>   l_approved,
         X_RETURN_STATUS           =>   x_return_status,
         X_MSG_COUNT               =>   x_msg_count,
         X_MSG_DATA                =>   x_msg_data,
         P_SOURCE_MOBILE_PHONE     =>   l_source_mobile_phone,
         P_SOURCE_PAGER            =>   l_source_pager
        );

         if (x_return_status <> 'S') then
             x_resultout := 'U';
            if (fnd_msg_pub.count_msg > 0) then
               for i in 1..fnd_msg_pub.count_msg loop
                  fnd_msg_pub.get (
                     p_msg_index     => i,
                     p_data          => l_msg_data,
                     p_encoded       => 'F',
                     p_msg_index_out => l_msg_index_out
                  );
                  --dbms_output.put_line(l_msg_data);
                  l_msg_data1 := l_msg_data1 ||''|| l_msg_data;
               end loop;

                  wf_engine.setitemattrtext (
                     itemtype => itemtype,
                     itemkey => itemkey,
                     aname => 'ERROR_MESSAGE',
                     avalue => l_msg_data1
                  );

            end if;
         else
            x_resultout := x_return_status;
         end if;

         resultout := 'COMPLETE:' || x_resultout;
         RETURN;
      END IF;

      --
      -- CANCEL mode - activity 'compensation'
      --
      IF (funcmode = 'CANCEL')
      THEN
         --
         -- Return process to run
         --
         resultout := 'COMPLETE';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT')
      THEN
         resultout := 'COMPLETE';
         RETURN;
      END IF;
   --

  END call_update_resource_api;

END JTF_RS_RESOURCE_WF_PUB;

/
