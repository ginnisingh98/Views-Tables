--------------------------------------------------------
--  DDL for Package AMS_COPYACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COPYACTIVITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpas.pls 120.1 2007/12/26 09:34:44 spragupa ship $ */

-- Start Of Comments
--
-- Name:
--   Ams_CopyActivities_PVT
--
-- Purpose:
--   This is the specification for copying the different activities in Oracle Marketing.
--   such as promotions,campaigns,media,channels,events,etc while copying them. These
--   procedures will be called from the forms to copy the main marketing activities from an existing one
--   and create a new one.
--Procedures:
--  copy_event_headers
--  copy_event_offering
--  copy_deliv_header
--  copy_campaign
--  copy_campaign_schedules
-- Notes:
--
-- History:
--   01/17/2000  Mumu Pande Created (mpande@us.oracle.com)
--   07/11/2000  Satish Karumuri
--  Added tasks and partners in camp_elements_rec_type
--  Removed code from rosetta generated wrapper.
-- Included over loaded procedure instead to handle logging
-- Messages.  Added 4 wrapper procedures
-- 05-oct-2003 sodixit   Added p_TGRP and p_COLT attributes to schedule_attr_rec_type for 11.5.10
-- 24-Dec-2007 spragupa	 ER - 6467510 - Extend Copy functionality to include TASKS for campaign schedules/activities
-- End Of Comments
--



   TYPE camp_elements_rec_type IS RECORD(
      p_access                      VARCHAR2(1)  := 'N',
      p_geo_areas                   VARCHAR2(1)  := 'N',
      p_products                    VARCHAR2(1)  := 'N',
      p_sub_camp                    VARCHAR2(1)  := 'N',
      p_offers                      VARCHAR2(1)  := 'N',
      p_attachments                 VARCHAR2(1)  := 'N',
      p_messages                    VARCHAR2(1)  := 'N',
      p_obj_asso                    VARCHAR2(1)  := 'N',
      p_segments                    VARCHAR2(1)  := 'N',
      p_resources                   VARCHAR2(1)  := 'N',
      p_tasks                       VARCHAR2(1)  := 'N',
      p_partners                    VARCHAR2(1)  := 'N',
      p_camp_sch                    VARCHAR2(1)  := 'N');

-- A pl/sql record type to hold the flags of yes or no. These flags passed by the user will specify if that
-- particular element of event header would be copied or not. This record is passed in the copy_event_headers
-- procedure

   TYPE eveh_elements_rec_type IS RECORD(
      p_products                    VARCHAR2(1)  := 'Y',
      p_sub_eveh                    VARCHAR2(1)  := 'Y',
      p_attachments                 VARCHAR2(1)  := 'Y',
      p_offers                      VARCHAR2(1)  := 'Y',
      p_messages                    VARCHAR2(1)  := 'Y',
      p_resources                   VARCHAR2(1)  := 'Y',
      p_obj_asso                    VARCHAR2(1)  := 'Y',
      p_geo_areas                   VARCHAR2(1)  := 'Y',
      p_event_offer                 VARCHAR2(1)  := 'Y',
      p_segments                    VARCHAR2(1)  := 'Y');
-- A pl/sql record type to hold the flags of yes or no. These flags passed by the user will specify if that
-- particular element of event header would be copied or not. This record is passed in the copy_event_headers
-- procedure

   TYPE eveo_elements_rec_type IS RECORD(
      p_geo_areas                   VARCHAR2(1)  := 'Y',
      p_products                    VARCHAR2(1)  := 'Y',
      p_segments                    VARCHAR2(1)  := 'Y',
      p_sub_eveo                    VARCHAR2(1)  := 'Y',
      p_attachments                 VARCHAR2(1)  := 'Y',
      p_resources                   VARCHAR2(1)  := 'Y',
      p_offers                      VARCHAR2(1)  := 'Y',
      p_messages                    VARCHAR2(1)  := 'Y',
      p_obj_asso                    VARCHAR2(1)  := 'Y');
-- A pl/sql record type to hold the flags of yes or no. These flags passed by the user will specify if that
-- particular element of deliverable offering would be copied or not. This record is passed in the
-- copy_deliv_offerings  procedure

   TYPE deli_elements_rec_type IS RECORD(
      p_attachments                 VARCHAR2(1)  := 'Y',
      p_kitflag                     VARCHAR2(1)  := 'Y',
      p_access                      VARCHAR2(1)  := 'N',
      p_products                    VARCHAR2(1)  := 'N',
      p_offers                      VARCHAR2(1)  := 'N',
      p_obj_asso                    VARCHAR2(1)  := 'Y',
      p_bus_party                   VARCHAR2(1)  := 'N',
      p_geo_areas                   VARCHAR2(1)  := 'N',
      p_categories                  VARCHAR2(1)  := 'N');

  -- A PL/SQL record type to hold the flags of yes or no, for copying schedule attributes to a new schedule.
  -- added new attribute p_TASK by spragupa on 23-nov-2007 for ER 6467510 -
  -- For extending COPY functionality for TASKS
     TYPE schedule_attr_rec_type IS RECORD(
      p_AGEN                 VARCHAR2(1)  := 'N',
      p_ATCH                 VARCHAR2(1)  := 'N',
      p_CATG                 VARCHAR2(1)  := 'N',
      p_CELL                 VARCHAR2(1)  := 'N',
      p_DELV                 VARCHAR2(1)  := 'N',
      p_MESG                 VARCHAR2(1)  := 'N',
      p_PROD                 VARCHAR2(1)  := 'N',
      p_PTNR                 VARCHAR2(1)  := 'N',
      p_REGS                 VARCHAR2(1)  := 'N',
      p_CONTENT              VARCHAR2(1)  := 'N',
      p_TGRP                 VARCHAR2(1)  := 'N',
      p_COLT                 VARCHAR2(1)  := 'N',
      p_TASK                 VARCHAR2(1)  := 'N'
      );



   PROCEDURE copy_campaign(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_campaign_id         OUT NOCOPY      NUMBER,
      p_src_camp_id         IN       NUMBER,
      p_new_camp_name       IN       VARCHAR2 := NULL,
      p_par_camp_id         IN       NUMBER := NULL,
      p_source_code         IN       VARCHAR2 := NULL,
      p_camp_elements_rec   IN       camp_elements_rec_type,
      p_end_date            IN       DATE := FND_API.G_MISS_DATE,
      p_start_date          IN       DATE := FND_API.G_MISS_DATE);

   PROCEDURE copy_campaign(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_campaign_id         OUT NOCOPY      NUMBER,
      p_src_camp_id         IN       NUMBER,
      p_new_camp_name       IN       VARCHAR2 := NULL,
      p_par_camp_id         IN       NUMBER := NULL,
      p_source_code         IN       VARCHAR2 := NULL,
      p_camp_elements_rec   IN       camp_elements_rec_type,
      p_end_date            IN       DATE := NULL,
      p_start_date          IN       DATE := NULL,
	 x_transaction_id      OUT NOCOPY      NUMBER);

-- This is a procedure to copy a event header.
-- IN Parameters:
--      p_src_header_id     : Source header ID from which it is going to copy
--      p_main_header_id    : An event header can be a child of another event header . This parameter if passed then
--                            the current header would be a child of this parent header.
--      p_event_header_name : A new header name
--      p_eveh_elements_rec : A record type which provides from the user what elements of the event header we need to copy
--      p_eveh_elements_rec : A record type which provides from the user what elements of the event offering associated
--                            with the event header we need to copy
--

   PROCEDURE copy_event_header(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveh_id             OUT NOCOPY      NUMBER,
      p_src_eveh_id         IN       NUMBER,
      p_new_eveh_name       IN       VARCHAR2,
      p_par_eveh_id         IN       NUMBER := NULL,
      p_eveh_elements_rec   IN       eveh_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      p_source_code         IN       VARCHAR2 := NULL);

   PROCEDURE copy_event_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveo_id             OUT NOCOPY      NUMBER,
      p_src_eveo_id         IN       NUMBER,
      p_event_header_id     IN       NUMBER,
      p_new_eveo_name       IN       VARCHAR2 := NULL,
      p_par_eveo_id         IN       NUMBER := NULL,
      p_eveo_elements_rec   IN       eveo_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      p_source_code         IN       VARCHAR2 := NULL);

   PROCEDURE copy_deliverables(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_deliverable_id      OUT NOCOPY      NUMBER,
      p_src_deliv_id        IN       NUMBER,
      p_new_deliv_name      IN       VARCHAR2,
      p_new_deliv_code      IN       VARCHAR2 := NULL,
      p_deli_elements_rec   IN       deli_elements_rec_type,
      p_new_version         IN       VARCHAR2);

   PROCEDURE copy_event_header(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveh_id             OUT NOCOPY      NUMBER,
      p_src_eveh_id         IN       NUMBER,
      p_new_eveh_name       IN       VARCHAR2,
      p_par_eveh_id         IN       NUMBER,
      p_eveh_elements_rec   IN       eveh_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
	 x_transaction_id      OUT NOCOPY      NUMBER,
      p_source_code         IN       VARCHAR2 := NULL);

   PROCEDURE copy_event_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveo_id             OUT NOCOPY      NUMBER,
      p_src_eveo_id         IN       NUMBER,
      p_event_header_id     IN       NUMBER,
      p_new_eveo_name       IN       VARCHAR2 := NULL,
      p_par_eveo_id         IN       NUMBER := NULL,
      p_eveo_elements_rec   IN       eveo_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
	 x_transaction_id      OUT NOCOPY      NUMBER,
      p_source_code         IN       VARCHAR2 := NULL);

   PROCEDURE copy_deliverables(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_deliverable_id      OUT NOCOPY      NUMBER,
      p_src_deliv_id        IN       NUMBER,
      p_new_deliv_name      IN       VARCHAR2,
      p_new_deliv_code      IN       VARCHAR2 := NULL,
      p_deli_elements_rec   IN       deli_elements_rec_type,
      p_new_version         IN       VARCHAR2,
	 x_transaction_id      OUT NOCOPY      NUMBER);



   --
   -- Create by soagrawa on 03-May-2001
   -- Copy attributes of a source schedule to a new target schedule
   --
   PROCEDURE copy_schedule_attributes (
      p_api_version     IN NUMBER,
      p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
      p_commit          IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_object_type     IN VARCHAR2,
      p_src_object_id   IN NUMBER,
      p_tar_object_id   IN NUMBER,
      p_attr_list       IN schedule_attr_rec_type
   );

   --
   -- Added by rrajesh on 15-Aug-2001
   -- Copy the attributes of a source campaign to a new campaign
   --
   PROCEDURE copy_campaign_new(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN   AMS_CpyUtility_PVT.copy_attributes_table_type,
    p_copy_columns_table         IN   AMS_CpyUtility_PVT.copy_columns_table_type,
    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
     );

   --
   -- Added by rrajesh on 05-Sep-2001
   -- Log function
   --
   PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2 DEFAULT 'CAMP',
                           p_log_used_by_id in number);
END ;

/
