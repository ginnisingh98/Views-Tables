--------------------------------------------------------
--  DDL for Package Body AMS_ADI_PRETTY_URL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_PRETTY_URL_PVT" AS
/* $Header: amsvadpb.pls 120.1 2005/07/04 04:30:36 appldev noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_ADI_PRETTY_URL_PVT
-- Purpose
--
-- This package contains all the program units for Click Through Destinations
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_PRETTY_URL_PVT';

-- Start of Comments
-- Name
-- CREATE_PRETTY_URL
--
Procedure   CREATE_PRETTY_URL(
              p_pretty_url varchar2,
              p_add_url_param varchar2,
              p_ctd_id number,
              p_schedule_id number,
              p_activity_id number,
              p_schedule_src_code varchar2,
              x_msg_count number,
              x_msg_data varchar2,
              x_return_status out nocopy varchar2
            )
IS
   l_pretty_url_rec AMS_PRETTY_URL_PVT.pretty_url_rec_type;
   l_system_url_rec AMS_System_Pretty_Url_PVT.system_pretty_url_rec_type;
   l_pretty_url_assoc AMS_Prty_Url_Assoc_PVT.prty_url_assoc_rec_type;

   l_pretty_url_id number;
   l_return_status varchar2(30);
   l_msg_count number;
   l_msg_data varchar2(4000);
   l_tracking_url varchar2(2000);
   l_system_url_id number;
   l_assoc_id number;

BEGIN
   -- Create Pretty URL
   l_pretty_url_rec.landing_page_url := p_pretty_url;
   AMS_PRETTY_URL_PVT.Create_Pretty_Url(
     p_api_version_number => 1.0,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data,
     p_pretty_url_rec => l_pretty_url_rec,
     x_pretty_url_id => l_pretty_url_id
     );

    -- Get Track URL
    AMS_CTD_UTIL_PKG.GET_TRACKING_URL(
              p_ctd_id => p_ctd_id,
              p_schedule_id => p_schedule_id,
              p_schedule_src_code => p_schedule_src_code,
              p_track_flag => 'N',
              x_tracking_url => l_tracking_url
            );
  --dbms_output.put_line('Pretty URL Id ='||l_pretty_url_id);

   -- Create System Pretty URL
  l_system_url_rec.pretty_url_id := l_pretty_url_id;
  l_system_url_rec.track_url := l_tracking_url;
  l_system_url_rec.ctd_id := p_ctd_id;
  l_system_url_rec.additional_url_param:= p_add_url_param;
  l_system_url_rec.system_url := p_pretty_url|| '/' || p_add_url_param;

   AMS_System_Pretty_Url_PVT.Create_System_Pretty_Url
   (
         p_api_version_number => 1.0,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_system_pretty_url_rec => l_system_url_rec,
         x_system_url_id => l_system_url_id
   );

  --dbms_output.put_line('Pretty URL Id ='||l_system_url_id);

   -- Create Association
  l_pretty_url_assoc.system_url_id := l_system_url_id;
  l_pretty_url_assoc.used_by_obj_type := 'CSCH';
  l_pretty_url_assoc.used_by_obj_id := p_schedule_id;

  AMS_Prty_Url_Assoc_PVT.Create_Prty_Url_Assoc
         (
         p_api_version_number => 1.0,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_prty_url_assoc_rec => l_pretty_url_assoc,
         x_assoc_id => l_assoc_id
         );

  x_return_status := l_return_status;

END CREATE_PRETTY_URL;


END AMS_ADI_PRETTY_URL_PVT;

/
