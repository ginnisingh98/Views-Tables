--------------------------------------------------------
--  DDL for Package Body AMS_CTD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTD_UTIL_PKG" AS
/* $Header: amsvctub.pls 120.4 2006/01/31 20:29:10 batoleti noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_CTD_UTIL_PKG`
-- Purpose
--
-- This package contains utility methods for CTD
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_CTD_UTIL_PKG';
G_AMPERSAND VARCHAR2(1) := '&';

-- Start of Comments
-- Name
-- GET_TRACKING_URL
--
-- Note: Once we start supporting Offer for Web ADI,
-- we need to add Offer Code

Procedure   GET_TRACKING_URL(
              p_ctd_id number,
              p_schedule_id NUMBER,
              p_schedule_src_code varchar2,
              p_track_flag varchar2,
              x_tracking_url OUT nocopy varchar2
            )
IS
BEGIN
   x_tracking_url := 'amsWebTracking.jsp?ctdid='||p_ctd_id||G_Ampersand||'sccd='||p_schedule_src_code||G_Ampersand||'objid='||p_schedule_id||G_Ampersand||'t='||p_track_flag;
END GET_TRACKING_URL;

PROCEDURE GET_EVENT_INFO
          (p_event_id number,
           x_source_code out nocopy varchar2
          )

IS

 -- The SQL taken from oracle.apps.ams.java.oa.events.server.EventOfferDetailsVVO.xml

 CURSOR C_GET_EVENT_INFO
 IS
 SELECT
 DECODE(e.parent_type,'CAMP',s.source_code,e.source_code) event_source_code
 FROM
 AMS_EVENT_OFFERS_ALL_B e,
 ams_campaign_schedules_b s
 WHERE
 e.event_offer_id = s.related_event_id (+)
 AND     s.related_event_from(+) = 'EONE'
 AND   e.EVENT_OFFER_ID = p_event_id;

BEGIN
   open C_GET_EVENT_INFO;

   fetch C_GET_EVENT_INFO
   into x_source_code;

   close C_GET_EVENT_INFO;

END;

PROCEDURE GET_SURVEY_URL(p_deployment_id number,
                         x_survey_url out nocopy varchar2)

IS

  CURSOR C_CHECK_SURVEY_TABLE (p_table_owner varchar2)
  IS
  SELECT 'Y'
  FROM ALL_TAB_COLUMNS
  WHERE TABLE_NAME='IES_SVY_SURVEYS_ALL'
  AND COLUMN_NAME = 'SURVEY_TYPE'
  AND OWNER = p_table_owner;

  CURSOR C_GET_SURVEY_TYPE
  IS
  select svy.survey_type
  from ies_svy_surveys_all svy,
       IES_SVY_CYCLES_ALL cyc,
       IES_SVY_DEPLYMENTS_ALL dep
  where dep.survey_deployment_id = p_deployment_id
  and dep.survey_cycle_id = cyc.survey_cycle_id
  and cyc.survey_id = svy.survey_id;

  l_flag varchar2(1);
  l_survey_type varchar2(30);
  l_return_status boolean;
  l_status varchar2(30);
  l_industry varchar2(30);
  l_table_owner varchar2(30);


BEGIN

   -- Get the schema owner
   l_return_status := FND_INSTALLATION.GET_APP_INFO
                         ( application_short_name => 'IES',
                           status => l_status,
                           industry => l_industry,
                           oracle_schema =>l_table_owner);


   -- Check whether Survey Table exists or not
   OPEN C_CHECK_SURVEY_TABLE(l_table_owner);
   FETCH C_CHECK_SURVEY_TABLE
   INTO l_flag;
   CLOSE C_CHECK_SURVEY_TABLE;

   IF (l_flag = 'Y') THEN

      -- Get Survey Type
      open C_GET_SURVEY_TYPE;
      fetch C_GET_SURVEY_TYPE
      into l_survey_type;
      close C_GET_SURVEY_TYPE;

      IF ((l_survey_type is null) or (l_survey_type = 'JTT')) THEN

        x_survey_url := 'iessvymain.jsp?dID='||p_deployment_id;


      ELSE
         x_survey_url := 'OA.jsp?OAFunc=IES_SURVEY_OARUNTIME'||G_AMPERSAND||'dID='||p_deployment_id;

      END IF;

   ELSE
        x_survey_url := 'iessvymain.jsp';

   END IF;






END;

-- Start of Comments
-- Name
-- GET_FORWARDING_URL
--

Procedure   GET_FORWARDING_URL(
              p_action_id NUMBER,
              p_parameter_id1 NUMBER,
              p_parameter_id2 NUMBER,
              p_parameter_id3 NUMBER,
              p_add_param1 varchar2,
              p_add_param_value1 varchar2,
              p_add_param2 varchar2,
              p_add_param_value2 varchar2,
              p_add_param3 varchar2,
              p_add_param_value3 varchar2,
              p_add_param4 varchar2,
              p_add_param_value4 varchar2,
              p_add_param5 varchar2,
              p_add_param_value5 varchar2,
              p_url_text varchar2,
              p_schedule_id number,
              x_forwarding_url out nocopy varchar2
            )
IS

cursor c_get_source_code_id
is
select source_code_id from ams_source_codes
where arc_source_code_for = 'CSCH'
and source_code_for_id = p_schedule_id
and active_flag='Y';

l_source_code_id number;
l_event_source_code varchar2(2000);
l_encrypted_source_code varchar2(2050);
l_survey_url varchar2(250);


BEGIN

   -- Get Source Code Id if its an iStore Action
   IF (p_action_id in (2,3,4,5,6,7)) THEN
      open c_get_source_code_id;
      fetch c_get_source_code_id into l_source_code_id;
      close c_get_source_code_id;

   END IF;

   IF (p_action_id = 1) THEN
      -- Go To URL
      x_forwarding_url := p_url_text;
   ELSIF (p_action_id = 6) THEN
      -- Go To iStore Registration
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=signin'||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 7) THEN
      -- Go To Minisite
      -- x_forwarding_url := 'ibeCZzpEntry.jsp?go=catalog'||G_Ampersand||'site='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=catalog'||G_Ampersand||'minisite='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 5) THEN
      -- Go to Section
      -- x_forwarding_url := 'ibeCZzpEntry.jsp?go=section'||G_Ampersand||'site='||p_parameter_id1||G_Ampersand||'section='||p_parameter_id2||G_Ampersand||'msource='||to_char(l_source_code_id);
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=section'||G_Ampersand||'minisite='||p_parameter_id1||G_Ampersand||'section='||p_parameter_id2||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 2) THEN
      -- Go to shopping Cart
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=cart'||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 4) THEN
      -- Go to shopping Cart with an item
      -- x_forwarding_url := 'ibeCZzpEntry.jsp?go=buy'||G_Ampersand||'site='||p_parameter_id2||G_Ampersand||'item='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=buy'||G_Ampersand||'minisite='||p_parameter_id2||G_Ampersand||'item='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 3) THEN
      -- Go to item details
      -- x_forwarding_url := 'ibeCZzpEntry.jsp?go=item'||G_Ampersand||'site='||p_parameter_id2||G_Ampersand||'section='||p_parameter_id3||G_Ampersand||'item='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
      x_forwarding_url := 'ibeCZzpEntry.jsp?go=item'||G_Ampersand||'minisite='||p_parameter_id2||G_Ampersand||'section='||p_parameter_id3||G_Ampersand||'item='||p_parameter_id1||G_Ampersand||'msource='||to_char(l_source_code_id);
   ELSIF (p_action_id = 9) THEN
      -- Go to content item
      x_forwarding_url := 'ibcGetContentItem.jsp?cItemId='||p_parameter_id1||G_Ampersand||'stlId='||p_parameter_id2||G_Ampersand||'loadMode=deep';
   ELSIF (p_action_id = 8) THEN

      GET_SURVEY_URL (p_parameter_id1,l_survey_url);

      -- Go to Web Script
      IF (p_parameter_id2 is not null) THEN

         GET_EVENT_INFO(p_parameter_id2,l_event_source_code);

         Encrypt(l_event_source_code,l_encrypted_source_code);

         IF (l_encrypted_source_code is not null) then
            l_event_source_code := l_encrypted_source_code;
         END IF;

        x_forwarding_url := l_survey_url||G_Ampersand||'esscd='||l_event_source_code;

      ELSE
        x_forwarding_url := l_survey_url;

      END IF;

      IF ((p_add_param1 is not null) and (p_add_param_value1 is not null)) THEN
           x_forwarding_url := x_forwarding_url||G_Ampersand||p_add_param1||'='||p_add_param_value1;
      END IF;

      IF ((p_add_param2 is not null) and (p_add_param_value2 is not null)) THEN
           x_forwarding_url := x_forwarding_url||G_Ampersand||p_add_param2||'='||p_add_param_value2;
      END IF;

      IF ((p_add_param3 is not null) and (p_add_param_value3 is not null)) THEN
           x_forwarding_url := x_forwarding_url||G_Ampersand||p_add_param3||'='||p_add_param_value3;
      END IF;

      IF ((p_add_param4 is not null) and (p_add_param_value4 is not null)) THEN
           x_forwarding_url := x_forwarding_url||G_Ampersand||p_add_param4||'='||p_add_param_value4;
      END IF;

      IF ((p_add_param5 is not null) and (p_add_param_value5 is not null)) THEN
           x_forwarding_url := x_forwarding_url||G_Ampersand||p_add_param5||'='||p_add_param_value5;
      END IF;

   END IF;

END GET_FORWARDING_URL;


Procedure   GET_ACTION_PARAM_ID (
              p_action_id NUMBER,
              x_act_param_code_list out nocopy jtf_varchar2_table_100,
              x_act_param_id_list out nocopy  jtf_number_table
            )
IS
cursor c_get_act_param
is
select action_param_id,action_param_code
from ams_clik_thru_act_params_b
where action_id=p_action_id;

BEGIN
   OPEN c_get_act_param;
   fetch c_get_act_param
   bulk collect into x_act_param_id_list,x_act_param_code_list;
   close c_get_act_param;
END;

Procedure GetUsedByType(
             p_activity_id number,
             x_used_by_type out nocopy varchar2
            )
IS
BEGIN
   IF (p_activity_id = 30) THEN
      x_used_by_type := 'WEB_AD';
   ELSIF (p_activity_id = 40) THEN
      x_used_by_type := 'WEB_OFFER';
   END IF;
END;

Procedure Encrypt (
                   p_value varchar2,
                   x_value out nocopy varchar2
                  )
IS

l_encryption_key varchar2(30);
l_left_enc_delim varchar2(30);
l_right_enc_delim varchar2(30);
l_encrypted_value varchar2(2000);

BEGIN

   IF (p_value is not null) THEN

       -- Check the Fulfillment security profile
       -- Get the Encryption Key
       l_encryption_key := FND_PROFILE.Value('JTF_FM_SECURITY_KEY');

       l_left_enc_delim := FND_PROFILE.Value('JTF_FM_LENCRYPT_DELIM');
       l_right_enc_delim := FND_PROFILE.VALUE('JTF_FM_RENCRYPT_DELIM');

       IF ((l_encryption_key is not null) AND (l_left_enc_delim is not null)
            AND (l_right_enc_delim is not null))
       THEN

          l_encrypted_value := fnd_web_sec.encrypt(l_encryption_key,p_value);
          x_value := l_left_enc_delim||l_encrypted_value||l_right_enc_delim;

       END IF;

   END IF;

END;



END AMS_CTD_UTIL_PKG;

/
