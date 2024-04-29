--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_COMMON" AS
/* $Header: cacstcob.pls 120.7 2006/02/12 23:57:41 deeprao noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavscb.pls                                                         |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |        function.                                                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 01-Feb-2002   rdespoto         Modified                               |
 | 12-Feb-2002   cjang            Added get_userid,get_resourceid,       |
 |                                   get_timezoneid,get_messages         |
 | 27-Feb-2002   hbouten          Added get_territory_code               |
 +======================================================================*/
   FUNCTION get_seqid
   RETURN NUMBER
   IS
      l_seqnum  NUMBER := 0;
   BEGIN
      SELECT jta_sync_contact_mapping_s.nextval
        INTO l_seqnum
        FROM DUAL;

      RETURN l_seqnum;
   END get_seqid;

   FUNCTION is_success (
      p_return_status IN VARCHAR2
      )
      RETURN BOOLEAN
   IS
   BEGIN
      IF (p_return_status = fnd_api.g_ret_sts_success)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

   PROCEDURE put_messages_to_result (
      p_task_rec     IN OUT NOCOPY cac_sync_task.task_rec,
      p_status       IN     NUMBER,
      p_user_message IN     VARCHAR2,
      p_token_name   IN     VARCHAR2 default null,
      p_token_value  IN     VARCHAR2 default null
   )
   IS
      no_of_messages NUMBER;
      l_msg_data VARCHAR2(2000);
   BEGIN
   --   p_task_rec.resultusermessage := p_user_message;
     fnd_message.set_name('JTF', p_user_message);
     --check if token name and value exists...limitation is that it takes one token(name,value)
     --at a time
     if ((p_token_name is not null) and (p_token_value is not null)) then
     fnd_message.set_token(p_token_name,p_token_value);
     end if;

     fnd_msg_pub.add;

     IF fnd_msg_pub.count_msg > 0
     THEN
       FOR j IN 1 .. fnd_msg_pub.count_msg
       LOOP
         l_msg_data := fnd_msg_pub.get (p_msg_index => j, p_encoded => 'F');
         p_task_rec.resultusermessage := p_task_rec.resultusermessage ||
                                            fnd_global.local_chr (10)||l_msg_data;
       END LOOP;
     END IF;

     p_task_rec.resultusermessage := substr(p_task_rec.resultusermessage,1,2000);
     p_task_rec.resultid := p_status;

     if (p_status <> cac_sync_task_common.g_sync_success) then
     p_task_rec.resultsystemmessage := cac_sync_common.sync_failure;
     else
     p_task_rec.resultsystemmessage := cac_sync_common.sync_success;
     end if;


   END;



/* commented for bug # 5031090
   PROCEDURE put_messages_to_result (
      p_contact_rec  IN OUT NOCOPY jta_sync_contact.contact_rec,
      p_status       IN     NUMBER
   )
   IS
   BEGIN
      p_contact_rec.resultid   := p_status;
      p_contact_rec.syncAnchor := SYSDATE;
      p_contact_rec.resultusermessage := jta_sync_contact_common.GET_MSG();

   IF (p_status = 0) THEN
      p_contact_rec.resultsystemmessage := sync_success;
   ELSE
      p_contact_rec.resultsystemmessage := sync_failure;
   END IF;

   END put_messages_to_result; */

   PROCEDURE apps_login (
      p_user_id IN NUMBER
   )
   IS
   BEGIN
      fnd_global.apps_initialize (user_id => p_user_id
                                , resp_id => fnd_global.resp_id --21787
                                , resp_appl_id => fnd_global.resp_appl_id --690
                                , security_group_id => fnd_global.security_group_id --0
      );
   END;


   PROCEDURE get_userid (p_user_name  IN VARCHAR2
                        ,x_user_id   OUT NOCOPY NUMBER)
   IS
       CURSOR c_user IS
       SELECT user_id
         FROM fnd_user
        WHERE user_name = p_user_name;
   BEGIN
       OPEN c_user;
       FETCH c_user INTO x_user_id;
       IF c_user%NOTFOUND THEN
           x_user_id := 0;
       END IF;
       CLOSE c_user;
   END get_userid;

   PROCEDURE get_resourceid (p_user_id      IN NUMBER
                            ,x_resource_id OUT NOCOPY NUMBER)
   IS
       CURSOR c_resource IS
       SELECT resource_id
         FROM jtf_rs_resource_extns
        WHERE user_id = p_user_id;
   BEGIN
       OPEN c_resource;
       FETCH c_resource INTO x_resource_id;
       IF c_resource%NOTFOUND THEN
           x_resource_id := 0;
       END IF;
       CLOSE c_resource;
   END get_resourceid;

   PROCEDURE get_timezoneid (p_timezone_name  IN VARCHAR2
                            ,x_timezone_id   OUT NOCOPY NUMBER)
   IS
       CURSOR c_timezone IS
       SELECT timezone_id
         FROM HZ_TIMEZONES
        WHERE global_timezone_name = p_timezone_name;
   BEGIN
       OPEN c_timezone;
       FETCH c_timezone INTO x_timezone_id;
       IF c_timezone%NOTFOUND THEN
           x_timezone_id := 0;
       END IF;
       CLOSE c_timezone;
   END get_timezoneid;

   FUNCTION get_messages
   RETURN VARCHAR2
   IS
       l_msg_count NUMBER;
       l_msg_data  VARCHAR2(5000);
   BEGIN
       l_msg_count := fnd_msg_pub.count_msg;

       FOR i IN 1..l_msg_count LOOP
           l_msg_data := substr(l_msg_data||fnd_msg_pub.get( i , 'F' ),1,5000);
       END LOOP;

       RETURN l_msg_data;
   END get_messages;

   --------------------------------------------------------------------------
   --  API name    : get_territory_code
   --  Type        : Private
   --  Function    : Tries to convert a country into a CRM territory_code
   --  Notes:
   --------------------------------------------------------------------------
   FUNCTION get_territory_code
   ( p_country IN     VARCHAR2
   )RETURN VARCHAR2
   IS
     CURSOR c_territory
     (b_country IN VARCHAR2
     )IS SELECT territory_code code
         FROM fnd_territories_tl -- using TL since a match in any language will do
         WHERE UPPER(b_country) = UPPER(territory_short_name)
         OR    UPPER(b_country) = UPPER(description)
         OR    UPPER(b_country) = UPPER(territory_code);

     l_territory_code VARCHAR2(2);

   BEGIN
    OPEN c_territory(p_country);

    FETCH c_territory INTO l_territory_code;

    CLOSE c_territory;

    RETURN NVL(l_territory_code,p_country);

   END get_territory_code;



 PROCEDURE put_message_to_excl_record (
      p_exclusion_rec     IN OUT NOCOPY  cac_sync_task.exclusion_rec,
      p_status       IN     NUMBER,
      p_user_message IN     VARCHAR2,
      p_token_name   IN     VARCHAR2 default null,
      p_token_value  IN     VARCHAR2 default null
   )
   IS
      no_of_messages NUMBER;
      l_msg_data VARCHAR2(2000);
   BEGIN

     fnd_message.set_name('JTF', p_user_message);
     --check if token name and value exists...limitation is that it takes one token(name,value)
     --at a time
     if ((p_token_name is not null) and (p_token_value is not null)) then
     fnd_message.set_token(p_token_name,p_token_value);
     end if;

     fnd_msg_pub.add;

     IF fnd_msg_pub.count_msg > 0
     THEN
       FOR j IN 1 .. fnd_msg_pub.count_msg
       LOOP
         l_msg_data := fnd_msg_pub.get (p_msg_index => j, p_encoded => 'F');
       p_exclusion_rec.resultusermessage := p_exclusion_rec.resultusermessage ||
                                          fnd_global.local_chr (10)||l_msg_data;
       END LOOP;
     END IF;

    p_exclusion_rec.resultusermessage := substr(p_exclusion_rec.resultusermessage,1,2000);
    p_exclusion_rec.resultid := p_status;
    p_exclusion_rec.resultsystemmessage := cac_sync_common.sync_failure;

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_common.put_messages_to_excl_record', ' p_exclusion_rec.resultusermessage for task '|| p_exclusion_rec.subject|| ' is '||p_exclusion_rec.resultusermessage);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_common.put_messages_to_excl_record', ' p_exclusion_rec.p_task_rec.resultid for task '|| p_exclusion_rec.subject|| ' is '||p_exclusion_rec.resultid);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_common.put_messages_to_excl_record', ' p_exclusion_rec.resultsystemmessage '|| p_exclusion_rec.subject|| ' is '||p_exclusion_rec.resultsystemmessage);

    end if;


   END;


END;

/
