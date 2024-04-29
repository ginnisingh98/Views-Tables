--------------------------------------------------------
--  DDL for Package Body OTA_ILEARNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ILEARNING" as
/* $Header: otilncnt.pkb 120.2 2008/01/17 11:50:07 smahanka noship $ */
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
         15-Jan-02            HDSHAH               Created
         23-Jan-02  115.2     HDSHAH    2193880    Cursor csr_get_date_time updated.
         25-Jan-02  115.3     HDSHAH    2200017    Timezone included in event creation and update procedure calls.
         28-Jan-02  115.4     HDSHAH    2201416    book_independent_flag parameter missing for create event procedure call.
         29-Jan-02  115.5     HDSHAH    2201416    trunc() included for course_start_date, course_end_date,
                                                   enrollment_start_date,enrollment_end_date in included for
                                                   ota_evt_ins.ins and ota_evt_upd.upd procedure calls
         29-Jan-02  115.6     DHMULIA   2201416    Added Trunc() to sysdate before calling ota_tav_ins.
         30-Jan-02  115.7     HDSHAH    2201416    Added Trunc() to l_course_date parameter for ota_tav_upd procedure calls.
         15-Feb-02  115.8     HDSHAH    2209467    p_start_date and p_end_date parameter type changed to varchar2 in
                                                   crt_or_chk_xml_prcs_tbl and upd_xml_prcs_tbl procedure.
         21-Feb-02  115.9     HDSHAH    2236928    Log messages modified.
         21-Feb-02  115.10    HDSHAH    2236928    Log messages modified.
         16-APR-02  115.11    HDSHAH    2324698    Modified cur_get_date_time cursor in crt_or_upd_event procedure.
         26-NOV-02  115.12    ARKASHYA  2684733    Included the NOCOPY directive in OUT and IN OUT parameters for procedures.
         25-Mar-03  115.13    Pbhasin              MLS changes added.
	 30-May-03  115.14    Arkashya  2984480    MLS Changes (Additional) Added calls to insert and update functions on _TL
	                                           tables for activity version and events.
         24-Dec-03 115.15     arkashya  Modified for eBS changed the call to ota_aci_api.ins to ota_aci_ins.ins
         10-Jan-04 115.16     arkashya  Modified for eBS changed the call to ota_tcu_api.ins to ota_ctu_ins.ins
	                                                    Also added the call to ota_ctt_ins.ins_tl and defaulted synchronous_flag
							    and online_flag.
         28-jun-04 115.17     ssur      3725560    Restricted import of newly created RCO and Offerings.
         07-Jan-08 120.1      aabalakr  6683076, modified to include the new enrollment status, 'E'(Pending Evaluation)
*/
--------------------------------------------------------------------------------
g_package  varchar2(33) := '  ota_ilearning.';  -- Global package name
--

--
-- ----------------------------------------------------------------------------
-- |------------------------< create_or_update_activity_version >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description :  Create or update activity version based on input data.
--
Procedure crt_or_upd_activity
  (
   p_update                   in  varchar2
  ,p_rco_id                   in  number
  ,p_language_code            in  varchar2
  ,p_activity_version_name    in  varchar2
  ,p_description              in  varchar2
  ,p_objectives               in  varchar2
  ,p_audience                 in  varchar2
  ,p_business_group_id        in  number
  ,p_activity_definition_name in  varchar2
  ,p_activity_version_id      out nocopy number
  ,p_language_id              out nocopy number
  ,p_status                   out nocopy varchar2
  ,p_message                  out nocopy varchar2
  ) is

no_language_id_found     EXCEPTION;
l_proc                   varchar2(72) := g_package||'crt_or_upd_activity';
l_activity_version_id    OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID%TYPE;
l_object_version_number  OTA_ACTIVITY_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
l_activity_version_name  OTA_ACTIVITY_VERSIONS_TL.VERSION_NAME%TYPE;  --MLS change _TL added
l_activity_id            OTA_ACTIVITY_DEFINITIONS.ACTIVITY_ID%TYPE;
l2_language_id           FND_LANGUAGES.LANGUAGE_ID%TYPE;
l_sysdate                date;

cursor cur_get_activity_version_id is
     select
            activity_version_id,
            language_id,
            object_version_number
     from
            ota_activity_versions OAV
     where
            OAV.rco_id = p_rco_id and
            OAV.developer_organization_id = p_business_group_id;


cursor cur_get_activity_version_name is
     select
            version_name
     from
            ota_activity_versions_vl OAV -- MLS change _vl added
     where
            OAV.version_name = p_activity_version_name and
            OAV.developer_organization_id = p_business_group_id;

/*
cursor cur_get_activity_id is
     select
            OAD.activity_id
     from
            ota_activity_definitions   OAD
     where
            OAD.name = p_activity_definition_name  and
            OAD.business_group_id = p_business_group_id;
*/

cursor cur_get_event_id is
       select
              event_id,
              object_version_number
       from
              ota_events
       where
              activity_version_id = l_activity_version_id and
              business_group_id = p_business_group_id;


cursor cur_get_language_id is
       select
              language_id
       from
              fnd_languages
       where
              language_code = p_language_code;


begin
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);


if p_update is null then -- if not only update

      open cur_get_activity_version_id;
      fetch cur_get_activity_version_id into l_activity_version_id,p_language_id,l_object_version_number;

      if cur_get_activity_version_id%NOTFOUND then  --if activity_version_id
          close cur_get_activity_version_id;

          l_activity_id :=  FND_PROFILE.VALUE('OTA_ILEARNING_DEFAULT_ACTIVITY');
/*
          open  cur_get_activity_id;
          fetch cur_get_activity_id into l_activity_id;
          if cur_get_activity_id%NOTFOUND then --if activity_id
             close cur_get_activity_id;
             FND_FILE.PUT_LINE(FND_FILE.LOG,'No Activity_Id found corresponding to - ' ||
                                                        p_activity_definition_name);
             p_message := 'No Activity_Id found corresponding to ';
          --   dbms_output.put_line(p_message);
             p_activity_version_id := NULL;
             p_status := 'F';
             return;
           end if; --if activity_id
             close cur_get_activity_id;
*/

             open  cur_get_language_id;
             fetch cur_get_language_id into p_language_id;
             if cur_get_language_id%NOTFOUND then  --if language_id
                 close cur_get_language_id;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The application did not create an Activity version for the RCO ' ||
                       p_activity_version_name || ' because the Language code '|| p_language_code || ' does not exist. Please return to OiL and correct the Language Name in the RCO.');
                 p_message := 'No language found corresponding to ';
              --   dbms_output.put_line(p_message);
                 p_activity_version_id := NULL;
               --  p_status := 'F';
                 p_status := 'W';
                 raise no_language_id_found;
                -- return;
             end if; --if language_id
                 close cur_get_language_id;

             open cur_get_activity_version_name;
             fetch cur_get_activity_version_name into l_activity_version_name;

             if cur_get_activity_version_name%FOUND then  --if activity_version_id
                 close cur_get_activity_version_name;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The Activity Version Name ' || p_activity_version_name|| ' already exists. You must rename all but one RCO of that name.');
                 p_message := 'Activity_version_name already exist ';
               --  dbms_output.put_line(p_message);
                 p_activity_version_id := NULL;
               --  p_status := 'F';
                 p_status := 'E';
                 return;

             end if;
             close cur_get_activity_version_name;

             /* for Bug 2201416 Added Trunc when selecting sysdate */
             select trunc(sysdate) into l_sysdate from dual;

--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert Activity with  rco_id - '|| p_rco_id);
            -- Create activity_version

               BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
/* change for eBS
                ota_tav_ins.Ins
                (
                 P_activity_version_id        	=> l_activity_version_id     -- (Output)
                ,P_activity_id                	=> l_activity_id             -- (Input)
                ,P_developer_organization_id    => p_business_group_id       -- (Input)
                ,P_description                  => p_description             -- (Input)
                ,P_language_id                  => p_language_id             -- (Input)
                ,P_start_date                   => l_sysdate                 -- (Input)
                ,P_version_name                 => p_activity_version_name   -- (Input)
                ,P_intended_audience            => p_audience                -- (Input)
                ,P_objectives                   => p_objectives              -- (Input)
                ,P_object_version_number        => l_object_version_number   -- (Output)
                ,P_RCO_ID                       => p_rco_id                  -- (Input)
                ,P_VALIDATE                     => false);                   -- (Input)

	       --Bug 2984480 - arkashya MLS Changes calls to _TL row handler for Insert
                 ota_avt_ins.ins_tl
                  (
                    P_effective_date               => l_sysdate
                   ,P_language_code                => USERENV('LANG')
                   ,P_activity_version_id          => l_activity_version_id
                   ,P_version_name                 => p_activity_version_name
                   ,P_description                  => p_description
                   ,P_intended_audience            => p_audience
                   ,P_objectives                   => p_objectives
                   );
                   */
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The RCO ' || p_activity_version_name||' cannot be transferred into iLearning 11i. You must launch iLearning 11i and create the new course there. ');
                  --  dbms_output.put_line(p_message);
                  --  p_activity_version_id := l_activity_version_id;
                    p_status := 'S';
                    return;
/* change for eBS
              EXCEPTION
                   when others then
                   fND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not create an Activity Version for RCO '||
                                                         p_activity_version_name || '. Reason:' || hr_utility.get_message);
                   p_message := 'Error in creating Activity_version found corresponding to ';
                 --  dbms_output.put_line(p_message);
                   p_activity_version_id := NULL;
                -- p_status := 'F';
                   p_status := 'W';
                   return;
*/
              END;



     else   --if activity_version_id
             close cur_get_activity_version_id;

             open  cur_get_language_id;
             fetch cur_get_language_id into l2_language_id;
             if cur_get_language_id%NOTFOUND then  --if language_id
                 close cur_get_language_id;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The application did not create Activity version for RCO ' ||
                                        p_activity_version_name || ' because the Language code '|| p_language_code || ' does not exist. Please return to OiL and correct the Language Name in the RCO.');
--                 FND_FILE.PUT_LINE(FND_FILE.LOG,'No language_id found corresponding to - ' ||
--                                                    p_language_code);
                 p_message := 'No language found corresponding to ';
               --  dbms_output.put_line(p_message);
                 p_activity_version_id := NULL;
               -- p_status := 'F';
                 p_status := 'W';
                 return;
             end if; --if language_id
             close cur_get_language_id;

       --- update activity_version
            BEGIN
             -- clear message before calling API
             hr_utility.clear_message;

            ota_tav_upd.Upd
            (
             P_activity_version_id           => l_activity_version_id        -- (Input)
            ,P_version_name                  => p_activity_version_name      -- (Input)
            ,P_description                   => p_description                -- (Input)
            ,P_intended_audience             => p_audience                   -- (Input)
            ,P_language_id                   => p_language_id                -- (Input)
            ,P_objectives                    => p_objectives                 -- (Input)
            ,P_object_version_number         => l_object_version_number      -- (Input Output)
           -- ,p_rco_id                        => p_rco_id                     -- (Input)
            ,P_validate                      => false);                      -- (Input)

         --Bug 2984480 - arkashya MLS Changes calls to _TL row handler for insert
             select trunc(sysdate) into l_sysdate from dual;
              ota_avt_upd.upd_tl
                  (
                    P_effective_date               => l_sysdate
                   ,P_language_code                => USERENV('LANG')
                   ,P_activity_version_id          => l_activity_version_id
                   ,P_version_name                 => p_activity_version_name
                   ,P_description                  => p_description
                   ,P_intended_audience            => p_audience
                   ,P_objectives                   => p_objectives
                   );
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated the Activity Version for RCO ' ||
                                                                 p_activity_version_name||'.');
                p_message := 'updated successfully ';
              --  dbms_output.put_line(p_message);
                p_activity_version_id := l_activity_version_id;

             EXCEPTION
                when others then
                   fND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the Activity Version for RCO '||
                                                         p_activity_version_name || '. Reason:' || hr_utility.get_message);
--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:In updating Activity version for rco_id - ' ||
--                                                   p_rco_id || '. REASON:' || hr_utility.get_message);
                    p_message := 'updated successfully ';
                  --  dbms_output.put_line(p_message);
                  -- p_status := 'F';
                    p_status := 'W';
                    return;
             END;


             if p_language_id <> l2_language_id then -- if language changed for activity
                --update all events with new activity_language;


                   for cur_evt in cur_get_event_id
                   LOOP
                     BEGIN
                     -- clear message before calling API
                        hr_utility.clear_message;

                       OTA_EVT_UPD.UPD
                       (
                        P_EVENT_ID                   => cur_evt.event_id                                -- (Input)
                       ,P_BUSINESS_GROUP_ID          => p_business_group_id                             -- (Input)
                       ,P_LANGUAGE_ID                => l2_language_id                                  -- (Input)
                       ,P_OBJECT_VERSION_NUMBER      => cur_evt.object_version_number                   -- (Output)
                       ,P_VALIDATE                   => false                                           -- (Input)
                       );


                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated the Language ID for Event ID '|| cur_evt.event_id ||
                                          '.');
                        p_message := 'Event updated successfully.Event id is -'||cur_evt.event_id||
                                          ' for Language id - '||l2_language_id;
                      --  dbms_output.put_line(p_message);
                    EXCEPTION
                      when others then
                        fND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the language ID for Event ID '||
                                                          cur_evt.event_id || '. Reason:' || hr_utility.get_message);
--                        FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:In updating Event.Event id is - '|| cur_evt.event_id ||
--                                          ' for Language id - ' || l2_language_id || '. REASON:' || hr_utility.get_message);
                        p_message := 'ERROR:In updating Event.Event id is -'||cur_evt.event_id||
                                          ' for Language id - '||l2_language_id;
                      --  dbms_output.put_line(p_message);
                      -- p_status := 'F';
                        p_status := 'W';
                        return;
                    END;


                   END LOOP;

                   p_language_id := l2_language_id;
             end if; -- if language changed for activity

             p_status := 'S';
             return;


     end if; ---if activity_version_id

else -- if not only update

      open cur_get_activity_version_id;
      fetch cur_get_activity_version_id into l_activity_version_id,p_language_id,l_object_version_number;

      if cur_get_activity_version_id%NOTFOUND then  --if activity_version_id
          close cur_get_activity_version_id;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'The RCO ' || p_activity_version_name || ' update failed because no activity version exists. Please return to OiL and update any Offering of this RCO.');
          p_message := 'ERROR:no activity_version_id found for update corresponding to Rco_Id - '|| p_rco_id;
        --  dbms_output.put_line(p_message);
          p_activity_version_id := NULL;
        --  p_status := 'F';
          p_status := 'W';
          return;
       end if; --if activity_id
          close cur_get_activity_version_id;

             open  cur_get_language_id;
             fetch cur_get_language_id into l2_language_id;
             if cur_get_language_id%NOTFOUND then  --if language_id
                 close cur_get_language_id;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The application did not update the Activity version for the RCO '||
                              p_activity_version_name || ' because the Language code '|| p_language_code || ' does not exist. Please return to OiL and correct the Language Name in the RCO.');
--                 FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:No language_id found corresponding to - ' ||
--                                                                    p_language_code);
                 p_message := 'ERROR:No language found corresponding to - '|| p_language_code;
               --  dbms_output.put_line(p_message);
                 p_activity_version_id := NULL;
               --  p_status := 'F';
                 p_status := 'W';
                 return;
             end if; --if language_id
             close cur_get_language_id;

       --- update activity_version
           BEGIN
            -- clear message before calling API
               hr_utility.clear_message;

            ota_tav_upd.Upd
           (
             P_activity_version_id           => l_activity_version_id        -- (Input)
            ,P_version_name                  => p_activity_version_name      -- (Input)
            ,P_description                   => p_description                -- (Input)
            ,P_intended_audience             => p_audience                   -- (Input)
            ,P_language_id                   => l2_language_id               -- (Input)
            ,P_objectives                    => p_objectives                 -- (Input)
            ,P_object_version_number         => l_object_version_number      -- (Input Output)
           -- ,p_rco_id                        => p_rco_id                     -- (Input)
            ,P_validate                      => false);                      -- (Input)

    --Bug 2984480 - arkashya MLS Changes calls to _TL row handler for Update
	       select trunc(sysdate) into l_sysdate from dual;
	     ota_avt_upd.upd_tl
                  (
                    P_effective_date               => l_sysdate
                   ,P_language_code                => USERENV('LANG')
                   ,P_activity_version_id          => l_activity_version_id
                   ,P_version_name                 => p_activity_version_name
                   ,P_description                  => p_description
                   ,P_intended_audience            => p_audience
                   ,P_objectives                   => p_objectives
                   );

                FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated the Activity Version for RCO ' ||
                                                                 p_activity_version_name || '.');
               p_message := 'updated successfully ';
             --  dbms_output.put_line(p_message);
               p_activity_version_id := l_activity_version_id;

           EXCEPTION
                when others then
                  fND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the Activity Version for RCO '||
                                                         p_activity_version_name || '. Reason:' || hr_utility.get_message);
--                  FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:In updating Activity version for rco_id - ' ||
--                                                  p_rco_id || '.REASON:' || hr_utility.get_message);
                  p_message := 'ERROR:In updating Activity version for rco_id - ' || p_rco_id;
                --  dbms_output.put_line(p_message);
                --  p_status := 'F';
                  p_status := 'W';
                  return;
           END;


             if p_language_id <> l2_language_id then -- if language changed for activity
                --update all events with new activity_language;

                   for cur_evt in cur_get_event_id
                   LOOP
                     BEGIN
                     -- clear message before calling API
                        hr_utility.clear_message;

                       OTA_EVT_UPD.UPD
                       (
                        P_EVENT_ID                   => cur_evt.event_id                                -- (Input)
                       ,P_BUSINESS_GROUP_ID          => p_business_group_id                             -- (Input)
                       ,P_LANGUAGE_ID                => l2_language_id                                  -- (Input)
                       ,P_OBJECT_VERSION_NUMBER      => cur_evt.object_version_number                   -- (Output)
                       ,P_VALIDATE                   => false                                           -- (Input)
                       );

                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated the Language ID for Event ID '|| cur_evt.event_id ||   '.');
--                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated .Event id is - '|| cur_evt.event_id ||
--                                          ' for Language id - ' || l2_language_id);
                        p_message := 'Event updated successfully.Event id is -'||cur_evt.event_id||
                                          ' for Language id - '||l2_language_id;
                      --  dbms_output.put_line(p_message);
                    EXCEPTION
                      when others then
                        fND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the language ID for Event ID '||
                                                          cur_evt.event_id || '. Reason:' || hr_utility.get_message);
--                        FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:In updating Event.Event id is - '|| cur_evt.event_id ||
--                                          ' for Language id - ' || l2_language_id || '. REASON:' || hr_utility.get_message);
                        p_message := 'ERROR:In updating Event.Event id is -'||cur_evt.event_id||
                                          ' for Language id - '||l2_language_id;
                      --  dbms_output.put_line(p_message);
                      --  p_status := 'F';
                        p_status := 'W';
                        return;
                    END;


                   END LOOP;

                   p_language_id := l2_language_id;
             end if; -- if language changed for activity

             p_status := 'S';
             return;



end if;  -- if not only update

exception
    when no_language_id_found then
       null;
--       FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: No Language Id Found ');

    when others then

       FND_FILE.PUT_LINE(FND_FILE.LOG,'An error occurred while processing RCO '||
                                                       p_activity_version_name ||'. SQLERRM:'|| SQLERRM);
       p_message := 'ERROR:In when others exception for Rco_Id - ' || p_rco_id;
     --  dbms_output.put_line(p_message);
       p_activity_version_id := NULL;
     --  p_status := 'F';
       p_status := 'W';
       return;


end crt_or_upd_activity;



Procedure crt_or_upd_event
  (
   p_transaction                        in number
  ,p_offering_title                     in varchar2
  ,p_offering_id                        in number
  ,p_offering_start_date                in date
  ,p_offering_end_date                  in date
  ,p_offering_timezone                  in varchar2
  ,p_enrollment_start_date              in date
  ,p_enrollment_end_date                in date
  ,p_offering_max_attendees             in number
  ,p_offering_type                      in varchar2
  ,p_offering_ispublished               in varchar2
  ,p_language_id                        in number
  ,p_activity_version_id                in number
  ,p_business_group_id                  in number
  ,p_status                             out nocopy varchar2
  ,p_message                            out nocopy varchar2
  ) is

l_proc                             varchar2(72) := g_package||'crt_or_upd_event';
l_activity_start_date              OTA_ACTIVITY_VERSIONS.START_DATE%TYPE;
l_activity_ovn                     OTA_ACTIVITY_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
l_event_type                       OTA_EVENTS.EVENT_TYPE%TYPE;
l2_event_type                      OTA_EVENTS.EVENT_TYPE%TYPE;
l_event_status                     OTA_EVENTS.EVENT_STATUS%TYPE;
l_event_id                         OTA_EVENTS.EVENT_ID%TYPE;
l_course_start_date                OTA_EVENTS.COURSE_START_DATE%TYPE;
l_course_end_date                  OTA_EVENTS.COURSE_END_DATE%TYPE;
l2_course_end_date                 OTA_EVENTS.COURSE_END_DATE%TYPE;
l3_course_end_date                 OTA_EVENTS.COURSE_END_DATE%TYPE;
l_course_start_time                OTA_EVENTS.COURSE_START_TIME%TYPE;
l_course_end_time                  OTA_EVENTS.COURSE_END_TIME%TYPE;
l_enrollment_start_date            OTA_EVENTS.ENROLMENT_START_DATE%TYPE;
l_enrollment_end_date              OTA_EVENTS.ENROLMENT_END_DATE%TYPE;
l2_enrollment_end_date             OTA_EVENTS.ENROLMENT_END_DATE%TYPE;
l3_enrollment_end_date             OTA_EVENTS.ENROLMENT_END_DATE%TYPE;
l_default_event_owner_id           OTA_EVENTS.OWNER_ID%TYPE;
l_owner_id                         OTA_EVENTS.OWNER_ID%TYPE;
l_maximum_attendees                OTA_EVENTS.MAXIMUM_ATTENDEES%TYPE;
l_event_ovn                        OTA_EVENTS.OBJECT_VERSION_NUMBER%TYPE;
l_category                         OTA_CATEGORY_USAGES.CATEGORY%TYPE;
l_category_usage_id                OTA_CATEGORY_USAGES.CATEGORY_USAGE_ID%TYPE;
l_cat_usages_ovn                   OTA_CATEGORY_USAGES.OBJECT_VERSION_NUMBER%TYPE;
l_cat_inc_ovn                      OTA_ACT_CAT_INCLUSIONS.OBJECT_VERSION_NUMBER%TYPE;
l_primary_flag                     OTA_ACT_CAT_INCLUSIONS.PRIMARY_FLAG%TYPE;
l_dummy                            varchar2(6);
l_primary_count                    number(1);
l_sysdate                          date;
l_no_of_enrollments                number(9);
l_waitlist_size                    number(3);
l_course_start_date_time           date;
l_waitlist_hours                   number;
l_diff_hours                       number;
l_call_auto_enroll                 varchar2(1)  := 'N';
l_auto_enroll_status               varchar2(1);
l_total_placed                     number;
l_sysdatetime                      varchar2(30);
l_user_name                        fnd_user.user_name%TYPE;
l_event_title                      OTA_EVENTS_TL.TITLE%TYPE;  -- MLS change _TL added
l_synchronous_flag  ota_category_usages.synchronous_flag%type;
 l_online_flag ota_category_usages.synchronous_flag%type;

cursor cur_get_event_id is
      select
             event_id,
             object_version_number,
             event_type,
             course_end_date,
             enrolment_end_date,
             event_status,
             maximum_attendees,
--             to_date(to_char(Course_start_date,'DD-MON-YYYY')||Course_start_time,'DD-MON-YYYYHH24:MI'),
             to_date(to_char(Course_start_date,'DD/MM/YYYY')||Course_start_time,'DD/MM/YYYYHH24:MI'),
             owner_id
      from
             ota_events
      where
             offering_id = p_offering_id and
             business_group_id = p_business_group_id;



cursor cur_get_cat_usage_id is
       select
              category_usage_id
       from
              ota_category_usages
       where
              business_group_id = p_business_group_id and
              type = 'DM' and
              category = l_category;



cursor cur_get_date_time (l_date in date) is
       select l_date,
--       select to_date(to_char(l_date,'DD/MM/YYYY')),
--       select to_date(to_char(l_date,'DD-MON-RRRR')),
--Bug#2324698 hdshah changed to MI instead of MM
--            to_char(l_date,'HH24:MM')
              to_char(l_date,'HH24:MI')
       from
              dual;


cursor cur_check_cat_inclusions is
       select
             'dummy'
       from
             ota_act_cat_inclusions
       where
             activity_version_id = p_activity_version_id and
             category_usage_id   = l_category_usage_id;


cursor cur_get_primary_count is
       select
              count(*)
       from
              ota_category_usages  OCU,
              ota_act_cat_inclusions   OAC
       where
              OAC.activity_version_id = p_activity_version_id   and
              OAC.category_usage_id = OCU.category_usage_id   and
              OCU.type = 'DM'   and
              OAC.primary_flag = 'Y';


cursor cur_get_activity_start_date is
       select
              start_date,
              object_version_number
       from
              ota_activity_versions
       where
              activity_version_id = p_activity_version_id;


cursor cur_check_enroll_exist is
       select
             count(*)
       from
             ota_delegate_bookings
       where
             event_id = l_event_id;

cursor cur_waitlist_size is
      select count(*)
      from   ota_delegate_bookings
      where  booking_status_type_id in (SELECT booking_status_type_id
                                        FROM ota_booking_status_types
                                        WHERE type = 'W')
        and event_id = l_event_id;


cursor cur_get_total_placed is
      select count(*)
      from   ota_delegate_bookings
      where  booking_status_type_id in (SELECT booking_status_type_id
                                        FROM ota_booking_status_types
                                        WHERE type in ('A','P','E'))
        and event_id = l_event_id;


cursor  cur_user (l_owner_id OTA_EVENTS.OWNER_ID%TYPE) is
        select  user_name
        from  fnd_user
        where  employee_id = l_owner_id;

cursor  cur_get_event_title is
        select title
        from ota_events_vl -- MLS change _vl added
        where title = p_offering_title and
              business_group_id = p_business_group_id;

begin
-- FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);


 IF p_offering_type <> 'C'  then --if not  INCLASS EVENT


     if p_offering_type in ('W','B') then --if offering type
           l_event_type := 'SCHEDULED';
     else
           l_event_type := 'SELFPACED';
     end if; -- if offering type

     if p_offering_end_date is NULL then --if offering end date is null
         select to_date('31/12/4712','DD/MM/YYYY') into l_course_end_date from dual;
         l_course_end_time := '23:59';
     else
         open  cur_get_date_time(p_offering_end_date);
         fetch cur_get_date_time into l_course_end_date, l_course_end_time;
         close cur_get_date_time;
     end if;  --if offering end date is null

     if p_offering_start_date is NULL then  --if offering start date is null
           FND_FILE.PUT_LINE(FND_FILE.LOG,'The application did not create or update the Event for the Offering '||
                              p_offering_title || '. You must return to OiL and enter a Start Date for the Offering.');
           p_message := 'ERROR:Offering start date is null for offering id - '|| p_offering_id;
         --  dbms_output.put_line(p_message);
         --  p_status := 'F';
           p_status := 'W';
           return;
     else
           open  cur_get_date_time(p_offering_start_date);
           fetch cur_get_date_time into l_course_start_date, l_course_start_time;
           close cur_get_date_time;
     end if;  --if offering start date is null

     open  cur_get_activity_start_date;
     fetch cur_get_activity_start_date into l_activity_start_date, l_activity_ovn;
     close cur_get_activity_start_date;

         if p_enrollment_start_date is null then --if enrollment start date is null
              if l_activity_start_date > l_course_start_date then  --if event start date is earlier
                   l_enrollment_start_date := l_course_start_date;
              else
                   l_enrollment_start_date := l_activity_start_date;
              end if;  --if event start date is earlier
         else
              l_enrollment_start_date := p_enrollment_start_date;
         end if; --if enrollment start date is null


         if trunc(l_enrollment_start_date) > trunc(l_course_start_date) then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'The Enrollment Start Date must be earlier than the Offering Start Date. Please return to OiL and correct the Enrollment Start Date for the Offering '||
                                                       p_offering_title ||'.');
              p_status := 'W';
              return;
         end if;

         if p_enrollment_end_date is null then   --if enrollment end date is null use event end date
              l_enrollment_end_date := l_course_end_date;
         else
              l_enrollment_end_date := p_enrollment_end_date;
         end if;  --if enrollment end date is null use event end date

         l_default_event_owner_id := FND_PROFILE.VALUE('OTA_DEFAULT_EVENT_OWNER');

     open  cur_get_event_id;
     fetch cur_get_event_id into l_event_id,l_event_ovn,l2_event_type,l2_course_end_date,
                                 l2_enrollment_end_date,l_event_status,l_maximum_attendees,l_course_start_date_time,l_owner_id;
     if cur_get_event_id%NOTFOUND then -- if event does not exist
         close cur_get_event_id;

         if p_offering_ispublished = 'N' then --if offering is unpublished and event does not exist
             FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not create an Event for Offering '|| p_offering_title ||
                                            ', because the Offering is Unpublished.');
             p_message := 'Concurrent program will not process offering id - ' || p_offering_id ||
                         ', Because Event id does not exist and Offering is Unpublished.';
           --  dbms_output.put_line(p_message);
           --  p_status := 'F';
             p_status := 'W';
             return;
         end if;  --if offering is unpublished and event does not exist

             open cur_get_event_title;
             fetch cur_get_event_title into l_event_title;

             if cur_get_event_title%FOUND then
                 close cur_get_event_title;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The Event Title ' || p_offering_title
                                  || ' already exists. You must rename all but one Offering of that name.');
                 p_message := 'Event Title already exist ';
               --  dbms_output.put_line(p_message);
              --   p_status := 'F';
                 p_status := 'E';
                 return;

             end if;
             close cur_get_event_title;



         if p_offering_type = 'B' then           --if offering type
              l_category := 'ESEMINAR_SCHEDULED';
	      l_synchronous_flag := 'Y';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'O' then
              l_category := 'OFFLINE_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'N';
         elsif p_offering_type = 'Q' then
              l_category := 'ESEMINAR_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'R' then
              l_category := 'ECLASS_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'S' then
              l_category := 'ESTUDY_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'W' then
              l_category := 'ECLASS';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         end if; -- if offering type

         open cur_get_cat_usage_id ;
         fetch cur_get_cat_usage_id into l_category_usage_id;
         if cur_get_cat_usage_id%NOTFOUND then  --if category usage does not exist
              close cur_get_cat_usage_id;

              BEGIN
                -- clear message before calling API
                hr_utility.clear_message;

              ota_ctu_ins.ins
             (
               p_category_usage_id            => l_category_usage_id                --(Output)
              ,p_business_group_id            => p_business_group_id                --(Input)
              ,p_category                     => l_category                         --(Input)
              ,p_object_version_number        => l_cat_usages_ovn                   --(Output)
              ,p_type                         => 'DM'
	      ,p_synchronous_flag =>  l_synchronous_flag
	      ,p_online_flag           => l_online_flag               --(Input)
        --    ,p_start_date_active            => l_start_date_active                --(Input)
--            ,p_end_date_active              => l_end_date_active                  --(Input)
              ,p_effective_date                     => trunc(sysdate)                             --(Input)
             );

	       ota_ctt_ins. ins_tl
  (p_effective_date  =>trunc(sysdate)
  ,p_language_code  =>USERENV('LANG')
  ,p_category_usage_id    =>l_category_usage_id
  ,p_category                => l_category);

                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully created the Delivery Method for Category ' || l_category||'.');
                  p_message := 'Category usage id - ' || l_category_usage_id || ' created successfully.';
                --  dbms_output.put_line(p_message);

             EXCEPTION
                  when others then

                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not create the Delivery Method for Category ' || l_category
                                                          || '. Reason:' || hr_utility.get_message);

--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:Unable to create category usage for category - '||
--                                                   l_category || '. REASON:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to create category usage for category - '|| l_category;
                  --  dbms_output.put_line(p_message);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;
             END;

         else
             close cur_get_cat_usage_id;
         end if;--if category usage does not exist

         open  cur_check_cat_inclusions;
         fetch cur_check_cat_inclusions into l_dummy;
         if cur_check_cat_inclusions%NOTFOUND then --if cat inclusion does not exist
             close cur_check_cat_inclusions;
             open  cur_get_primary_count;
             fetch cur_get_primary_count into l_primary_count;
             close cur_get_primary_count;
             if (l_primary_count = 0) then -- if primary count
                 l_primary_flag := 'Y';
             else
                 l_primary_flag := 'N';
             end if;    -- if primary count
           -- create category inclusions

             BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
         /*    OTA_ACI_API.INS
            (
             p_activity_version_id          => p_activity_version_id              -- (Input)
            ,p_activity_category            => l_category                         -- (Input)
            ,p_object_version_number        => l_cat_inc_ovn                      -- (Output)
--          ,p_start_date_active            => l_start_date_active                -- (Input)
--          ,p_end_date_active              => l_end_date_active                  -- (Input)
            ,p_primary_flag                 => l_primary_flag                     -- (Input)
            ,p_category_usage_id            => l_category_usage_id                -- (Input)
            ,p_validate                     => false                              -- (Input)
            );*/

	    OTA_ACI_INS.INS
            (
             p_activity_version_id          => p_activity_version_id              -- (Input)
            ,p_activity_category            => l_category                         -- (Input)
            ,p_object_version_number        => l_cat_inc_ovn                      -- (Output)
--          ,p_start_date_active            => l_start_date_active                -- (Input)
--          ,p_end_date_active              => l_end_date_active                  -- (Input)
            ,p_primary_flag                 => l_primary_flag                     -- (Input)
            ,p_category_usage_id            => l_category_usage_id                -- (Input)
            ,p_effective_date              => trunc(sysdate)                       -- (Input)
            );

                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully included Delivery Method in Activity Version ID '||
                                                       p_activity_version_id ||'.');
                  p_message := 'Successfully created category inclusion for category usage id - '|| l_category_usage_id;
                --  dbms_output.put_line(p_message);

             EXCEPTION
                  when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not include Delivery Method in Activity Version ID '||
                                             p_activity_version_id  || '. Reason:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to create category inclusion for category usage id - '|| l_category_usage_id;
                 --  dbms_output.put_line(p_message);
                 --   dbms_output.put_line('p_activity_version_id - ' || p_activity_version_id);
                 --   dbms_output.put_line('l_category - ' || l_category);
                 --   dbms_output.put_line('l_cat_inc_ovn - ' || l_cat_inc_ovn);
                --  dbms_output.put_line('l_start_date_active - ' || l_start_date_active);
                --  dbms_output.put_line('l_end_date_active - ' || l_end_date_active);
                 --   dbms_output.put_line('l_primary_flag - ' || l_primary_flag);
                 --   dbms_output.put_line('l_category_usage_id - ' || l_category_usage_id);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;

             END;
        else
             close  cur_check_cat_inclusions;
        end if; --if cat inclusion does not exist

         if l_activity_start_date > l_course_start_date then --if event start date is earlier then activity start date

              BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
                -- Bug#2201416 trunc included for l_course_start_date parameter.
              ota_tav_upd.Upd
             (
              p_activity_version_id           => p_activity_version_id               -- (Input)
             ,p_start_date                    => trunc(l_course_start_date)          -- (Input)
             ,p_object_version_number         => l_activity_ovn                      -- (Input Output)
            -- ,p_rco_id                        => p_rco_id                            -- (Input)
             ,p_validate                      => false                               -- (Input)
             );

             EXCEPTION
                 when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update Activity Start Date for Activity Version ID '||
                                                   p_activity_version_id  || '. REASON:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to update Activity start date for activity_version_id - '||
                                                       p_activity_version_id || ' And offering Id - ' ||p_offering_id;
                  --  dbms_output.put_line(p_message);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;

             END;
         end if;--if event start date is earlier then activity start date


         -- Create Event

         BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
/* change for eBS
         OTA_EVT_INS.INS
        (
         P_EVENT_ID                   => l_event_id                                     -- (Output)
        ,P_BUSINESS_GROUP_ID          => p_business_group_id                            -- (Input)
        ,P_EVENT_TYPE                 => l_event_type                                   -- (Input)
        ,P_OBJECT_VERSION_NUMBER      => l_event_ovn                                    -- (Output)
        ,P_TITLE                      => p_offering_title                               -- (Input)
        ,P_LANGUAGE_ID                => p_language_id                                  -- (Input)
        ,P_PRICE_BASIS                => 'N'                                            -- (Input)
        ,P_ACTIVITY_VERSION_ID        => p_activity_version_id                          -- (Input)
        ,P_COURSE_START_DATE          => trunc(l_course_start_date)                     -- (Input)
        ,P_COURSE_START_TIME          => l_course_start_time                            -- (Input)
        ,P_COURSE_END_DATE            => trunc(l_course_end_date)                       -- (Input)
        ,P_COURSE_END_TIME            => l_course_end_time                              -- (Input)
        ,P_ENROLMENT_START_DATE       => trunc(l_enrollment_start_date)                 -- (Input)
        ,P_ENROLMENT_END_DATE         => trunc(l_enrollment_end_date)                   -- (Input)
        ,P_EVENT_STATUS               => 'N'                                            -- (Input)
        ,P_MAXIMUM_ATTENDEES          => p_offering_max_attendees                       -- (Input)
        ,P_MAXIMUM_INTERNAL_ATTENDEES => p_offering_max_attendees                       -- (Input)
        ,P_PUBLIC_EVENT_FLAG          => 'Y'                                            -- (Input)
        ,P_SECURE_EVENT_FLAG          => 'N'                                            -- (Input)
        ,P_OWNER_ID                   => l_default_event_owner_id                       -- (Input)
        ,P_OFFERING_ID                => p_offering_id                                  -- (Input)
--Bug#2200017 timezone included.
        ,P_TIMEZONE                   => p_offering_timezone                            -- (Input)
-- Bug#2201416 book_independent_flag included.
        ,P_BOOK_INDEPENDENT_FLAG      => 'N'                                            -- (Input)
        ,P_VALIDATE                   => false                                          -- (Input)
        );

  --Bug 2984480 - arkashya MLS Changes calls to _TL row handler for insert
  select trunc(sysdate)  into l_sysdate from dual;
      OTA_ENT_INS.INS_TL
       (
        p_effective_date               => l_sysdate
       ,p_language_code                => USERENV('LANG')
       ,p_event_id                     => l_event_id
       ,p_title                        => p_offering_title
       );

*/
            FND_FILE.PUT_LINE(FND_FILE.LOG,'The offering '|| p_offering_title || ' cannot be transferred into iLearning 11i. You must launch iLearning 11i and create the new class there. ');
          --  p_message := 'Event created successfully.Event id is -'||l_event_id||' for Offering id - '||p_offering_id;
          --  dbms_output.put_line(p_message);
            p_status := 'S';
            return;
/*
        EXCEPTION
            when others then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not create an Event for the Offering '|| p_offering_title
                                             || '. Reason:' || hr_utility.get_message);
              p_message := 'ERROR:Unable to create Event for Offering id - '||p_offering_id;

--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_event_id -' || l_event_id);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_business_group_id - ' || p_business_group_id);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_event_type - ' || l_event_type);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_event_ovn - ' || l_event_ovn);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_offering_title - ' || p_offering_title);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_language_id - ' || p_language_id);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_activity_version_id - ' || p_activity_version_id);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_course_start_date - ' || l_course_start_date);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_course_end_date - ' || l_course_end_date);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_course_start_time - ' || l_course_start_time);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_course_end_time - ' || l_course_end_time);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_enrollment_start_date - ' || l_enrollment_start_date);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_enrollment_end_date - ' || l_enrollment_end_date);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_offering_max_attendees - ' || p_offering_max_attendees);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'l_default_event_owner_id - ' || l_default_event_owner_id);
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_offering_id - ' || p_offering_id);

            --  dbms_output.put_line(p_message);
            --  p_status := 'F';
              p_status := 'W';
              return;
*/
        END;


     else -- if event does not exist
         close cur_get_event_id;

        -- if event type changed from self-paced to schedule or schedule to self-paced
         if l_event_type <> l2_event_type then --if event type changed
               FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update Offering '|| p_offering_title ||
                                              ', because you cannot change Offerings from Self-Paced to Scheduled or Scheduled to Self-Paced ');
               p_message := 'ERROR:Event type changed from Self-Paced to Schedule or Schedule to Self-Paced ' ||
                                                'for offering Id - ' || p_offering_id;
             --  dbms_output.put_line(p_message);
             --  p_status := 'F';
               p_status := 'W';
               return;
         end if; --if event type changed

   /*      if p_offering_type = 'B' then           --if offering type
              l_category := 'ESEMINAR_SCHEDULED';
         elsif p_offering_type = 'O' then
              l_category := 'OFFLINE_SELF_PACED';
         elsif p_offering_type = 'Q' then
              l_category := 'ESEMINAR_SELF_PACED';
         elsif p_offering_type = 'R' then
              l_category := 'ECLASS_SELF_PACED';
         elsif p_offering_type = 'S' then
              l_category := 'ESTUDY_SELF_PACED';
         elsif p_offering_type = 'W' then
              l_category := 'ECLASS';
         end if; -- if offering type*/



	  if p_offering_type = 'B' then           --if offering type
              l_category := 'ESEMINAR_SCHEDULED';
	      l_synchronous_flag := 'Y';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'O' then
              l_category := 'OFFLINE_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'N';
         elsif p_offering_type = 'Q' then
              l_category := 'ESEMINAR_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'R' then
              l_category := 'ECLASS_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'S' then
              l_category := 'ESTUDY_SELF_PACED';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         elsif p_offering_type = 'W' then
              l_category := 'ECLASS';
	      l_synchronous_flag := 'N';
	      l_online_flag := 'Y';
         end if; -- if offering type

         open cur_get_cat_usage_id ;
         fetch cur_get_cat_usage_id into l_category_usage_id;
         if cur_get_cat_usage_id%NOTFOUND then  --if category usage does not exist
              close cur_get_cat_usage_id;

              BEGIN
                -- clear message before calling API
                hr_utility.clear_message;

              ota_ctu_ins.ins
             (
               p_category_usage_id            => l_category_usage_id                --(Output)
              ,p_business_group_id            => p_business_group_id                --(Input)
              ,p_category                     => l_category                         --(Input)
              ,p_object_version_number        => l_cat_usages_ovn                   --(Output)
              ,p_type                         => 'DM'
	      ,p_synchronous_flag   => l_synchronous_flag
	     , p_online_flag               => l_online_flag                             --(Input)
--            ,p_start_date_active            => l_start_date_active                --(Input)
--            ,p_end_date_active              => l_end_date_active                  --(Input)
              ,p_effective_date                   => trunc(sysdate)                           --(Input)
             );

	     ota_ctt_ins. ins_tl
  (p_effective_date  =>trunc(sysdate)
  ,p_language_code  =>USERENV('LANG')
  ,p_category_usage_id    =>l_category_usage_id
  ,p_category                => l_category);


                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully created the Delivery Method for Category ' || l_category||'.');
--                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Category usage id - ' || l_category_usage_id ||
--                                                   ' created successfully ');
                  p_message := 'Category usage id - ' || l_category_usage_id || ' created successfully.';
                --  dbms_output.put_line(p_message);

             EXCEPTION
                  when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not create the Delivery Method for Category ' || l_category
                                                          || '. Reason:' || hr_utility.get_message);
--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:Unable to create category usage for category - '||
--                                                   l_category || '. REASON:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to create category usage for category - '|| l_category;
                  --  dbms_output.put_line(p_message);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;
             END;

         else
             close cur_get_cat_usage_id;
         end if;--if category usage does not exist

         open  cur_check_cat_inclusions;
         fetch cur_check_cat_inclusions into l_dummy;
         if cur_check_cat_inclusions%NOTFOUND then --if cat inclusion does not exist
             close cur_check_cat_inclusions;
             open  cur_get_primary_count;
             fetch cur_get_primary_count into l_primary_count;
             close cur_get_primary_count;
             if (l_primary_count = 0) then -- if primary count
                 l_primary_flag := 'Y';
             else
                 l_primary_flag := 'N';
             end if;    -- if primary count
           -- create category inclusions

             BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
     /*        OTA_ACI_API.INS
            (
             p_activity_version_id          => p_activity_version_id              -- (Input)
            ,p_activity_category            => l_category                         -- (Input)
            ,p_object_version_number        => l_cat_inc_ovn                      -- (Output)
--          ,p_start_date_active            => l_start_date_active                -- (Input)
--          ,p_end_date_active              => l_end_date_active                  -- (Input)
            ,p_primary_flag                 => l_primary_flag                     -- (Input)
            ,p_category_usage_id            => l_category_usage_id                -- (Input)
            ,p_validate                     => false                              -- (Input)
            );*/

	      OTA_ACI_INS.INS
            (
             p_activity_version_id          => p_activity_version_id              -- (Input)
            ,p_activity_category            => l_category                         -- (Input)
            ,p_object_version_number        => l_cat_inc_ovn                      -- (Output)
--          ,p_start_date_active            => l_start_date_active                -- (Input)
--          ,p_end_date_active              => l_end_date_active                  -- (Input)
            ,p_primary_flag                 => l_primary_flag                     -- (Input)
            ,p_category_usage_id            => l_category_usage_id                -- (Input)
            ,p_effective_date                 => trunc(sysdate)                              -- (Input)
            );

                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully included Delivery Method in Activity Version ID '||
                                                       p_activity_version_id ||'.');
--                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully created category inclusion for category usage id- '||
--                                                       l_category_usage_id);
                  p_message := 'Successfully created category inclusion for category usage id - '|| l_category_usage_id;
                --  dbms_output.put_line(p_message);

             EXCEPTION
                  when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not include Delivery Method in Activity Version ID '||
                                             p_activity_version_id  || '. Reason:' || hr_utility.get_message);
--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:Unable to create category inclusion for category usage id- '||
--                                                   l_category_usage_id || '. REASON:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to create category inclusion for category usage id - '|| l_category_usage_id;
                  --  dbms_output.put_line(p_message);
                  --  dbms_output.put_line('p_activity_version_id - ' || p_activity_version_id);
                  --  dbms_output.put_line('l_category - ' || l_category);
                  --  dbms_output.put_line('l_cat_inc_ovn - ' || l_cat_inc_ovn);
                --  dbms_output.put_line('l_start_date_active - ' || l_start_date_active);
                --  dbms_output.put_line('l_end_date_active - ' || l_end_date_active);
                  --  dbms_output.put_line('l_primary_flag - ' || l_primary_flag);
                  --  dbms_output.put_line('l_category_usage_id - ' || l_category_usage_id);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;

             END;
        else
             close  cur_check_cat_inclusions;
        end if; --if cat inclusion does not exist


         if l_activity_start_date > l_course_start_date then --if event start date is earlier then activity start date

              BEGIN
                -- clear message before calling API
                hr_utility.clear_message;
                -- Bug#2201416 trunc included for l_course_start_date parameter.
              ota_tav_upd.Upd
             (
              p_activity_version_id           => p_activity_version_id               -- (Input)
             ,p_start_date                    => trunc(l_course_start_date)          -- (Input)
             ,p_object_version_number         => l_activity_ovn                      -- (Input Output)
            -- ,p_rco_id                        => p_rco_id                            -- (Input)
             ,p_validate                      => false                               -- (Input)
             );
             EXCEPTION
                when others then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update Activity Start Date for Activity Version ID '||
                                                   p_activity_version_id  || '. REASON:' || hr_utility.get_message);
--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:Unable to update Activity start date for activity_version_id - '||
--                                                       p_activity_version_id || ' And offering Id - ' ||p_offering_id
--                                                   || '. REASON:' || hr_utility.get_message);
                    p_message := 'ERROR:Unable to update Activity start date for activity_version_id - '||
                                                       p_activity_version_id || ' And offering Id - ' ||p_offering_id;
                  --  dbms_output.put_line(p_message);
                  --  p_status := 'F';
                    p_status := 'W';
                    return;
             END;

         end if;--if event start date is earlier then activity start date

        if l_course_end_date is null then
             l3_course_end_date := l2_course_end_date;
        else
             l3_course_end_date := l_course_end_date;
        end if;

        if l_enrollment_end_date is null then
             l3_enrollment_end_date := l2_enrollment_end_date;
        else
             l3_enrollment_end_date := l_enrollment_end_date;
        end if;

        select sysdate into l_sysdate from dual;

        open  cur_check_enroll_exist;
        fetch cur_check_enroll_exist into l_no_of_enrollments;
        close cur_check_enroll_exist;

       -- if offering changed from published to unpublished
        if p_offering_ispublished = 'N'   then  --if
              if (l3_course_end_date < l_sysdate) or (l_no_of_enrollments >0) then
                    if l3_enrollment_end_date > l_sysdate then
                       l_enrollment_end_date := l_sysdate;
                    end if;
              else
                   if (l3_course_end_date > l_sysdate) and  (l_no_of_enrollments = 0 ) then
                       l_event_status := 'A';
                   end if;
              end if;

        -- if offering changed from unpublished to published.
        elsif p_offering_ispublished = 'Y'  then

             NULL;
            -- change the event status to Normal

        end if;

       -- if maximum attendees changed on iLearning side then
        if l_maximum_attendees <> p_offering_max_attendees then

             -- if max attendees increased
             if l_maximum_attendees < p_offering_max_attendees then

                   open  cur_waitlist_size;
                   fetch cur_waitlist_size into l_waitlist_size;
                   close cur_waitlist_size;


                  -- if Auto Waitlist Active profile is turned ON
                  if ('Y' =  FND_PROFILE.VALUE('OTA_AUTO_WAITLIST_ACTIVE')) then


                     select sysdate into l_sysdate from dual;
                     l_diff_hours  := l_course_start_date_time - l_sysdate ;
                     l_diff_hours  := l_diff_hours  * 24 ;
                     l_waitlist_hours  := FND_PROFILE.VALUE('OTA_AUTO_WAITLIST_DAYS');

                       IF l_diff_hours <= nvl(l_waitlist_hours,0)  THEN  -- if not enough time then
                          -- update max attendees and notify Event Owner
                          l_maximum_attendees := p_offering_max_attendees;

                          -- send notification to event owner  if waitlist candidates > 0
                             if l_waitlist_size > 0 then
                                 -- send notification
                                  SELECT to_char(sysdate,'DD/MM/YYYY:HH24:MI:SS') INTO l_sysdatetime FROM dual;
                              --    SELECT to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS') INTO l_sysdatetime FROM dual;

                                  if l_owner_id is null then
                                    OPEN CUR_USER(l_default_event_owner_id);
                                  else
                                    OPEN  CUR_USER(l_owner_id);
                                  end if;
                                    FETCH CUR_USER INTO l_user_name;
                                    CLOSE CUR_USER;

                                    OTA_INITIALIZATION_WF.MANUAL_WAITLIST(p_itemtype     => 'OTWF',
                                                                        p_process      => 'OTA_MANUAL_WAITLIST',
                                                                        p_event_title  =>  p_offering_title,
                                                                        p_event_id     =>  l_event_id,
                                                                        p_item_key     =>  l_sysdatetime,
                                                                        p_user_name    =>  l_user_name);
                             end if;

                       ELSE -- if enough time
                          l_maximum_attendees := p_offering_max_attendees;

                          -- if waitlist candidates > 0 call auto enroll
                          if l_waitlist_size > 0 then
                               l_call_auto_enroll := 'Y';
                          end if;


                       END IF;


                  else -- if Auto Waitlist Active profile is turned OFF
                    -- update max attendees
                    l_maximum_attendees := p_offering_max_attendees;

                    -- send notification to event owner  if waitlist candidates > 0
                     if l_waitlist_size > 0 then
                       -- send notification
                          SELECT to_char(sysdate,'DD/MM/YYYY:HH24:MI:SS') INTO l_sysdatetime FROM dual;
                       --   SELECT to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS') INTO l_sysdatetime FROM dual;

                            if l_owner_id is null then
                                   OPEN CUR_USER(l_default_event_owner_id);
                            else
                                   OPEN  CUR_USER(l_owner_id);
                            end if;
                            FETCH CUR_USER INTO l_user_name;
                            CLOSE CUR_USER;

                            OTA_INITIALIZATION_WF.MANUAL_WAITLIST(p_itemtype     => 'OTWF',
                                                                p_process      => 'OTA_MANUAL_WAITLIST',
                                                                p_event_title  =>  p_offering_title,
                                                                p_event_id     =>  l_event_id,
                                                                p_item_key     =>  l_sysdatetime,
                                                                p_user_name    =>  l_user_name);
                     end if;

                  end if;



             else -- if max attendees decreased

                   open  cur_get_total_placed;
                   fetch cur_get_total_placed into l_total_placed;
                   close cur_get_total_placed;

                   if l_total_placed < p_offering_max_attendees then

                          l_maximum_attendees := p_offering_max_attendees;

                   else
                         FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update Maximum attendees to '||
                                     p_offering_max_attendees || 'for the Event ' ||
                                                p_offering_title || ' , because '|| l_total_placed ||
                                                ' students have already enrolled in the event.');
                         p_message := 'ERROR:Maximum attendees for event id - ' ||
                                                l_event_id || ' cannot be updated to '|| p_offering_max_attendees ||
                                                ' because '|| l_total_placed || ' students are already enrolled.';
                       --  dbms_output.put_line(p_message);
                       --  p_status := 'F';
                         p_status := 'W';
                         return;
                   end if;

             end if;


        end if;





       -- Update event

        BEGIN
-- clear message before calling API
        hr_utility.clear_message;

        OTA_EVT_UPD.UPD
       (
        P_EVENT_ID                   => l_event_id                                      -- (Input)
       ,P_BUSINESS_GROUP_ID          => p_business_group_id                             -- (Input)
       ,P_EVENT_TYPE                 => l_event_type                                    -- (Input)
       ,P_OBJECT_VERSION_NUMBER      => l_event_ovn                                     -- (Output)
       ,P_TITLE                      => p_offering_title                                -- (Input)
       ,P_COURSE_START_DATE          => trunc(l_course_start_date)                      -- (Input)
       ,P_COURSE_START_TIME          => l_course_start_time                             -- (Input)
       ,P_COURSE_END_DATE            => trunc(l_course_end_date)                        -- (Input)
       ,P_COURSE_END_TIME            => l_course_end_time                               -- (Input)
       ,P_ENROLMENT_START_DATE       => trunc(l_enrollment_start_date)                  -- (Input)
       ,P_ENROLMENT_END_DATE         => trunc(l_enrollment_end_date)                    -- (Input)
       ,P_MAXIMUM_ATTENDEES          => l_maximum_attendees                             -- (Input)
       ,P_MAXIMUM_INTERNAL_ATTENDEES => l_maximum_attendees                             -- (Input)
       ,P_EVENT_STATUS               => l_event_status                                  -- (Input)
--Bug#2200017 timezone included.
       ,P_TIMEZONE                   => p_offering_timezone                             -- (Input)
       ,P_VALIDATE                   => false                                           -- (Input)
       );


  --Bug 2984480 - arkashya MLS Changes calls to _TL row handler for
         select trunc(sysdate) into l_sysdate from dual;
	 OTA_ENT_UPD.UPD_TL
		       (
		        p_effective_date             => l_sysdate
                       ,p_language_code              => USERENV('LANG')
                       ,p_event_id                   => l_event_id
		       ,p_title                      => p_offering_title
		       );


            FND_FILE.PUT_LINE(FND_FILE.LOG,'Successfully updated the Event '|| p_offering_title  || '.');
            p_message := 'Event updated successfully.Event id is -'||l_event_id||' for Offering id - '||p_offering_id;
          --  dbms_output.put_line(p_message);
          --  p_status := 'S';
          --  return;

       EXCEPTION
         when others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not update the Event '|| p_offering_title ||
                                           '. Reason:' || hr_utility.get_message);
            p_message := 'ERROR:Unable to update Event.Event id is -'||l_event_id||' for Offering id - '||p_offering_id;
          --  dbms_output.put_line(p_message);
          --  dbms_output.put_line(l_event_id);
          --  dbms_output.put_line(p_business_group_id);
          --  dbms_output.put_line(l_event_type);
          --  dbms_output.put_line('object_version_number - '|| l_event_ovn);
          --  dbms_output.put_line(p_offering_title);
          --  dbms_output.put_line(l_course_start_date);
          --  dbms_output.put_line(l_course_end_date);
          --  dbms_output.put_line(l_course_start_time);
          --  dbms_output.put_line(l_course_end_time);
          --  dbms_output.put_line(l_enrollment_start_date);
          --  dbms_output.put_line(l_enrollment_end_date);
          --  dbms_output.put_line(p_offering_max_attendees);

          --  p_status := 'F';
            p_status := 'W';
            return;

       END;


       IF (l_call_auto_enroll = 'Y') then

             OTA_OM_TDB_WAITLIST_API.AUTO_ENROLL_FROM_WAITLIST
             (
              p_validate               => false
             ,p_business_group_id      => p_business_group_id
             ,p_event_id               => l_event_id
             ,p_return_status          => l_auto_enroll_status
             );

             if l_auto_enroll_status = 'F' then

                 FND_FILE.PUT_LINE(FND_FILE.LOG,'The application could not automatically enroll students from the waitlists in the Event ' || p_offering_title || '.');
                 p_message := 'ERROR:Error in Auto_Enroll_From_Waitlist procedure for event id - ' ||
                                                l_event_id || '.';

               --  dbms_output.put_line(p_message);
               --  p_status := 'F';
                 p_status := 'W';
                 return;
             else
                 p_status := 'S';
                 return;
             end if;

       ELSE
            p_status := 'S';
            return;
       END IF;


     end if; -- if event does not exist

 ELSE

      FND_FILE.PUT_LINE(FND_FILE.LOG,'The Offering ' || p_offering_title ||
                          ' is an inClass Offering. The application does not import inClass Offerings.');
      p_message := 'Concurrent program will not process Offering id - ' || p_offering_id ||
                                       ' due to offering type - ' || p_offering_type;
    --  dbms_output.put_line(p_message);
      p_status := 'F';
      return;

 END IF; --if not INCLASS EVENT


exception
    when others then

       FND_FILE.PUT_LINE(FND_FILE.LOG,'An error occurred while processing the Offering ' || p_offering_title ||'. SQLERRM:'
                                 || SQLERRM);
       p_message := 'ERROR:In when others exception for Offering Id -  '|| p_offering_id;
      -- dbms_output.put_line(p_message);
      -- p_status := 'F';
       p_status := 'W';
       return;




end crt_or_upd_event;



procedure offering_rco_import (
   p_array                       in OTA_OFFERING_STRUCT_TAB
  ,p_business_group_id           in varchar2
  ,p_activity_definition_name    in varchar2
  ,p_status                      out nocopy varchar2
  ) is

l_proc                            varchar2(72) := g_package||'offering_rco_import';
l_activity_version_id             OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID%TYPE;
l_language_id                     FND_LANGUAGES.LANGUAGE_ID%TYPE;
l_rco_status                      varchar2(1);
l_rco_message                     varchar2(100);
l_offering_status                 varchar2(1);
l_offering_message                varchar2(100);
l_update                          varchar2(10);
l_activity_success                number(10)     := 0;
l_activity_fail                   number(10)     := 0;
l_activity_warning                number(10)     := 0;
l_event_success                   number(10)     := 0;
l_event_fail                      number(10)     := 0;
l_event_warning                   number(10)     := 0;

begin
--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);


--      FND_FILE.PUT_LINE(FND_FILE.LOG,'Value of p_array.LAST is:'  || p_array.LAST);



  FOR p_array_idx IN p_array.FIRST..p_array.LAST  LOOP


  IF p_array(p_array_idx).rco_id is null then

      FND_FILE.PUT_LINE(FND_FILE.LOG,'The RCO ID is missing for the Offering ' || p_array(p_array_idx).offering_title ||
                                     '.');

  ELSE

       if p_array(p_array_idx).offering_ispublished = 'N' then --if
             l_update := 'true';
       else
             l_update := NULL;
       end if;
--      FND_FILE.PUT_LINE(FND_FILE.LOG,'creating/updating activity' || 'RCO-ID:' || to_number(p_array(p_array_idx).rco_id) );


      -- Issue SavePoint
      SAVEPOINT save_activity;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'**-----------------------------------------------------------**');

       crt_or_upd_activity
      (
        p_update                   => l_update                                 -- (Input)
       ,p_rco_id                   => to_number(p_array(p_array_idx).rco_id)   -- (Input)
       ,p_language_code            => p_array(p_array_idx).rco_language        -- (Input)
       ,p_activity_version_name    => p_array(p_array_idx).rco_title           -- (Input)
       ,p_description              => p_array(p_array_idx).rco_description     -- (Input)
       ,p_objectives               => p_array(p_array_idx).rco_objective       -- (Input)
       ,p_audience                 => p_array(p_array_idx).rco_audience        -- (Input)
       ,p_business_group_id        => to_number(p_business_group_id)           -- (Input)
       ,p_activity_definition_name => p_activity_definition_name               -- (Input)
       ,p_activity_version_id      => l_activity_version_id                    -- (Output)
       ,p_language_id              => l_language_id                            -- (Output)
       ,p_status                   => l_rco_status                             -- (Output)
       ,p_message                  => l_rco_message                            -- (Output)
      );


      if l_rco_status = 'S' then
          l_activity_success := l_activity_success +1;
          -- do commit
          commit;
--          FND_FILE.PUT_LINE(FND_FILE.LOG,'Activity Insert/Update commited.');

      elsif l_rco_status = 'W' then
          l_activity_warning := l_activity_warning +1;
          ROLLBACK TO save_activity;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'The import could not create an activity for the RCO:' || p_array(p_array_idx).rco_title);
      else
          l_activity_fail := l_activity_fail +1;
          -- rollback to save_activity
          ROLLBACK TO save_activity;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'The import could not create an activity for the RCO:' || p_array(p_array_idx).rco_title);
      end if;


--      FND_FILE.PUT_LINE(FND_FILE.LOG,'creating/updating Event');

    if (to_number(p_array(p_array_idx).offering_id) <> -1 and l_activity_version_id is not null) then

      -- Issue Savepoint
      SAVEPOINT save_event;

      crt_or_upd_event
     (
      p_transaction                     => to_number(p_array(p_array_idx).offering_transaction)     -- (Input)
     ,p_offering_title                  => p_array(p_array_idx).offering_title                      -- (Input)
     ,p_offering_id                     => to_number(p_array(p_array_idx).offering_id)              -- (Input)
     ,p_offering_start_date             => to_date(p_array(p_array_idx).offering_start_date,'yyyy-mm-dd hh24:mi:ss')   -- (Input)
     ,p_offering_end_date               => to_date(p_array(p_array_idx).offering_end_date,'yyyy-mm-dd hh24:mi:ss')     -- (Input)
     ,p_offering_timezone               => p_array(p_array_idx).offering_timezone                   -- (Input)
     ,p_enrollment_start_date           => to_date(p_array(p_array_idx).enrollment_start_date,'yyyy-mm-dd hh24:mi:ss') -- (Input)
     ,p_enrollment_end_date             => to_date(p_array(p_array_idx).enrollment_end_date,'yyyy-mm-dd hh24:mi:ss')   -- (Input)
     ,p_offering_max_attendees          => to_number(p_array(p_array_idx).offering_max_attendees)   -- (Input)
     ,p_offering_type                   => p_array(p_array_idx).offering_type                       -- (Input)
     ,p_offering_ispublished            => p_array(p_array_idx).offering_ispublished                -- (Input)
     ,p_language_id                     => l_language_id                                            -- (Input)
     ,p_activity_version_id             => l_activity_version_id                                    -- (Input)
     ,p_business_group_id               => to_number(p_business_group_id)                           -- (Input)
     ,p_status                          => l_offering_status                                        -- (Output)
     ,p_message                         => l_offering_message                                       -- (Output)
     );


     if l_offering_status = 'S' then
         l_event_success := l_event_success + 1;
         -- do commit;
         commit;
--         FND_FILE.PUT_LINE(FND_FILE.LOG,'Event Insert/Update commited.');
     elsif l_offering_status = 'W' then
         l_event_warning := l_event_warning + 1;
         -- rollback to save_event
         ROLLBACK TO save_event;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'The import could not create an event for the Offering:' || to_number(p_array(p_array_idx).offering_id) );
     else
         l_event_fail := l_event_fail + 1;
         -- rollback to save_event
         ROLLBACK TO save_event;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'The import could not create an event for the Offering:' || to_number(p_array(p_array_idx).offering_id) );
     end if;

    elsif (to_number(p_array(p_array_idx).offering_id) <> -1 and l_activity_version_id is  null) then

           l_event_warning := l_event_warning + 1;
           FND_FILE.PUT_LINE(FND_FILE.LOG,'The application did not create an event for the offering '||
                           p_array(p_array_idx).offering_title ||
                           ', because it could not create an activity version from its associated RCO, '||
                           p_array(p_array_idx).rco_title||'.');

    end if;


  END IF;

  END LOOP;

  if ( l_activity_fail > 0 or l_event_fail > 0) then
     p_status := 'F';
  elsif (l_activity_warning > 0 or l_event_warning > 0) then
     p_status := 'W';
  else
     p_status := 'S';
  end if;


   l_event_fail := l_event_fail + l_event_warning;
   l_activity_fail := l_activity_fail + l_activity_warning;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'**-----------------------------------------------------------**');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'               IMPORT RESULTS FOR OFFERINGS');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'---------------------------------------------------------------');
--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of Activities Processed Successfully:' || l_activity_success);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'         Number of Activities Not Processed:' || l_activity_fail);
--  FND_FILE.PUT_LINE(FND_FILE.LOG,'    Number of Events Processed Successfully:' || l_event_success);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'             Number of Events Not Processed:' || l_event_fail );
  FND_FILE.PUT_LINE(FND_FILE.LOG,'-----------------------------------------------------------------');
--  FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting:' || l_proc);


end offering_rco_import;





procedure rco_import (
   p_array                       in OTA_RCO_STRUCT_TAB
  ,p_business_group_id           in varchar2
  ,p_activity_definition_name    in varchar2
  ) is

l_proc                   varchar2(72) := g_package||'rco_import';
l_activity_version_id    OTA_ACTIVITY_VERSIONS.ACTIVITY_VERSION_ID%TYPE;
l_language_id            FND_LANGUAGES.LANGUAGE_ID%TYPE;
l_rco_status             varchar2(1);
l_message                varchar2(100);
l_update                 varchar2(10);
l_activity_success                number(10)     := 0;
l_activity_fail                   number(10)     := 0;

begin
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc || 'p_array_LAST-' ||p_array.LAST);


   FOR p_array_idx IN p_array.FIRST..p_array.LAST  LOOP

--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);

  -- Issue Savepoint
  SAVEPOINT save_activity;

  crt_or_upd_activity
  (
   p_update                   => 'false'                                  -- (Input)
  ,p_rco_id                   => to_number(p_array(p_array_idx).rco_id)   -- (Input)
  ,p_language_code            => p_array(p_array_idx).rco_language        -- (Input)
  ,p_activity_version_name    => p_array(p_array_idx).rco_title           -- (Input)
  ,p_description              => p_array(p_array_idx).rco_description     -- (Input)
  ,p_objectives               => p_array(p_array_idx).rco_objective       -- (Input)
  ,p_audience                 => p_array(p_array_idx).rco_audience        -- (Input)
  ,p_business_group_id        => to_number(p_business_group_id)           -- (Input)
  ,p_activity_definition_name => p_activity_definition_name               -- (Input)
  ,p_activity_version_id      => l_activity_version_id                    -- (Output)
  ,p_language_id              => l_language_id                            -- (Output)
  ,p_status                   => l_rco_status                             -- (Output)
  ,p_message                  => l_message                                -- (Output)
  );


  if l_rco_status = 'S' then
     l_activity_success := l_activity_success +1;
     -- do commit;
     commit;
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'Activity Update commited.');
  else
     l_activity_fail := l_activity_fail +1;
     -- rollback to save_activity
     ROLLBACK TO save_activity;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'The import could not create an activity for the RCO:' || to_number(p_array(p_array_idx).rco_id) );
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'Activity Update rolled back.');
  end if;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'               IMPORT RESULTS FOR RCOS');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of Activities Processed Successfully:' || l_activity_success);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'         Number of Activities Not Processed:' || l_activity_fail);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'---------------------------------------------------------------');
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting:' || l_proc);

end rco_import;




procedure crt_or_chk_xml_prcs_tbl (
   p_site_id                     in varchar2
  ,p_business_group_id           in varchar2
  ,p_process_name                in varchar2
--  ,p_start_date                  in date
--  ,p_end_date                    in date
  ,p_start_date                  in varchar2
  ,p_end_date                    in varchar2
  ,p_status                      out nocopy varchar2
  ,p_process_type                out nocopy varchar2
  ) is

l_proc                        varchar2(72) := g_package||'crt_or_upd_xml_prcs_tbl';
l_business_group_id           number := to_number(p_business_group_id);
l_site_id                     number := to_number(p_site_id);
l_end_date                    date;
l_2_site_id                   number;
l_2_business_group_id         number;
l_status                      varchar2(1) := 'F';
l_process_type                varchar2(1) := 'A'; ---'A' for Automatic  'M' for Manual
l_sysdate                     date;

pl_start_date                  date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
pl_end_date                    date := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS');

cursor cur_get_record1 is
       select
              to_date
       from
              ota_iln_xml_processes
       where
              executable_name = p_process_name and
              business_group_id = l_business_group_id and
              site_id = l_site_id;


cursor cur_get_record2 is
       select
              site_id
       from
              ota_iln_xml_processes
       where
              executable_name = p_process_name and
              business_group_id = l_business_group_id;


cursor cur_get_record3 is
       select
              business_group_id
       from
              ota_iln_xml_processes
       where
              executable_name = p_process_name and
              site_id = l_site_id;

begin
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);

    select sysdate into l_sysdate from dual;

-- if (p_start_date is null) or (p_end_date is null) or (p_start_date > p_end_date) or (p_end_date > l_sysdate) then
 if (pl_start_date is null) or (pl_end_date is null) or (pl_start_date > pl_end_date) or (pl_end_date > l_sysdate) then
     l_status := 'F';
    FND_FILE.PUT_LINE(FND_FILE.LOG,'The Start Date must be earlier than the End Date and the End Date cannot be later than the Current date and time.');

 else


   open  cur_get_record1;
   fetch cur_get_record1 into l_end_date;
   if cur_get_record1%NOTFOUND then
         close cur_get_record1;

         open  cur_get_record2;
         fetch cur_get_record2 into l_2_site_id;
         if cur_get_record2%NOTFOUND then
              close cur_get_record2;

              open  cur_get_record3;
              fetch cur_get_record3 into l_2_business_group_id;
              if cur_get_record3%NOTFOUND then
                    close cur_get_record3;
                    insert into ota_iln_xml_processes
                                  (executable_name,
                                   business_group_id,
                                   site_id,
                                   from_date,
                                   to_date)
                           values (p_process_name,
                                   l_business_group_id,
                                   l_site_id,
                                   pl_start_date,
                                   pl_end_date);

                    l_status := 'S';

--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Record created in ota_iln_xml_processes table for ' ||
--                                                   ' process '|| p_process_name ||
--                                                   ' business group id ' || l_business_group_id ||
--                                                   ' and site id ' || l_site_id || '.');
              else
                    close cur_get_record3;
--                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Process '|| p_process_name || ' for site id ' ||
--                                             l_site_id || ' is attached to business group id ' || l_business_group_id ||
--                                             ' in ota_iln_xml_processes table. Where as concurrent program is using ' ||
--                                             ' business group id ' || l_2_business_group_id || '. Please Correct.');

                    FND_FILE.PUT_LINE(FND_FILE.LOG,'The Site ID '|| l_site_id || ' is already mapped to the Business Group ID '||
                                                    l_2_business_group_id || '.');

              end if;

         else
              close cur_get_record2;
--              FND_FILE.PUT_LINE(FND_FILE.LOG,'Process '|| p_process_name || ' for business group id ' ||
--                                             l_business_group_id || ' is attached to site id ' || l_site_id ||
--                                             ' in ota_iln_xml_processes table. Where as concurrent program is using site id ' ||
--                                             l_2_site_id || '. Please Correct.');

              FND_FILE.PUT_LINE(FND_FILE.LOG,'The Business Group ID '|| l_business_group_id || ' is already mapped to the Site ID '||
                                                    l_2_site_id || '.');
         end if;

   else
      close cur_get_record1;

      l_status := 'S';


--       if p_start_date = l_end_date then
       if pl_start_date = l_end_date then

/* --Do not need to update now. Created new procedure to update the table
         update
                ota_iln_xml_processes
         set
                from_date = p_start_date,
                to_date   = p_end_date
         where
                executable_name = p_process_name and
                business_group_id = l_business_group_id and
                site_id = l_site_id;

*/


            FND_FILE.PUT_LINE(FND_FILE.LOG,'');
--            FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program will update ota_iln_xml_processes table' ||
--                                           ' with start and end date. ');
      else
            l_process_type := 'M';
--            FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent program will not update ota_iln_xml_processes' ||
--                                           ' with start and end date. ');
      end if;

   end if;

 end if;

   p_status       := l_status;
   p_process_type := l_process_type;

--    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_status:' || p_status);
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting:' || l_proc);


EXCEPTION
   when others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:When others exception in procedure crt_or_chk_xml_prcs_tbl.');
            p_status := 'F';

end crt_or_chk_xml_prcs_tbl;


procedure upd_xml_prcs_tbl (
   p_site_id                     in varchar2
  ,p_business_group_id           in varchar2
  ,p_process_name                in varchar2
--  ,p_start_date                  in date
--  ,p_end_date                    in date
  ,p_start_date                  in varchar2
  ,p_end_date                    in varchar2
  ,p_status                      out nocopy varchar2
  ) is

l_proc                        varchar2(72) := g_package||'upd_xml_prcs_tbl';
l_business_group_id           number := to_number(p_business_group_id);
l_site_id                     number := to_number(p_site_id);
l_start_date                  date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
l_end_date                    date := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS');

begin
--    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entering:' || l_proc);


         update
                ota_iln_xml_processes
         set
                from_date = l_start_date,
                to_date   = l_end_date
         where
                executable_name = p_process_name and
                business_group_id = l_business_group_id and
                site_id = l_site_id;


--            FND_FILE.PUT_LINE(FND_FILE.LOG,'ota_iln_xml_processes table updated successfully' ||
--                                           ' with start and end date. ');
            p_status := 'S';

EXCEPTION
   when others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR:When others exception in procedure upd_xml_prcs_tbl.');
            p_status := 'F';

end upd_xml_prcs_tbl;


end     OTA_ILEARNING;

/
