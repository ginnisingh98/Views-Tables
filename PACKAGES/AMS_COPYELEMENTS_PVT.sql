--------------------------------------------------------
--  DDL for Package AMS_COPYELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COPYELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpes.pls 120.2 2007/12/26 09:35:56 spragupa ship $ */

-- Start Of Comments
--
-- Name:
--   Ams_CopyElements_PVT
--
-- Purpose:
--   This is the specification for copying the different elements
--   in Oracle Marketing.
--   These procedures will be called by marketing activities such as campaigns,
--       deliverables,events,etc while copying them.
--       Called from AMS_COPYACTIVITIES_PVT
--   This should be called from inside AMS only and not by any
--       external source for copying campaigns
-- Procedures:
-- copy_act_objectives       (see below for specification)
-- copy_act_offers           (see below for specification)
-- copy_act_offer_products   (see below for specification)
-- copy_act_sripts           (see below for specification)
-- copy_act_resources        (see below for specification)
-- copy_act_products         (see below for specification)
-- copy_act_cells            (see below for specification)
-- copy_act_geo_area         (see below for specification)
-- copy_act_attachments      (see below for specification)
-- copy_object_associations  (see below for specification)
-- copy_act_list_headers     (see below for specification)
-- copy_act_access           (see below for specification)
-- copy_list_select_actions (see below for specification)
-- Notes:
--
-- History:
--   05/25/1999  Mumu Pande Updated Comments
--   ams_CopyElements_PVT package.
--   05/15/1999  Mumu Pande Created (mpande@us.oracle.com)
--   07/11/2000  skarumur
--   Added the following procedures
--            copy_tasks           (see below for specification)
--            copy_partners (see below for specification)
--   Removed the following procedures
--            copy_act_offers
--            copy_act_offers
-- 05-Apr-2001    choang      - Added copy_list_select_actions
--                            - added g_attribute task, team and trng
-- 18-Aug-2001    ptendulk      Added copy_act_schedules to copy schedules
-- 25-jan-2002    soagrawa      Added copy_act_content to copy content
-- 01-may-2003    nyostos       Added G_ATTRIBUTE_SELC to copy Scoring Run Data Selections
-- 30-sep-2003    soagrawa      Added API copy_act_collateral
-- 06-oct-2003    soagrawa      Added API copy_target_group
-- 24-Dec-2007    spragupa	ER - 6467510 - Extend Copy functionality to include TASKS for campaign schedules/activities
-- End Of Comments

   -- global constants
   --
   -- choang - 05-apr-2001
   -- add attributes/elements for copy here using the format:
   -- G_ATTRIBUTE_xxxx, and in alphabetical order
   G_ATTRIBUTE_CELL     CONSTANT VARCHAR2(30) := 'CELL';
   G_ATTRIBUTE_PROD     CONSTANT VARCHAR2(30) := 'PROD';
   -- nyostos - 01-may-2003
   -- Added to copy data selections for Scoring Runs.
   G_ATTRIBUTE_SELC     CONSTANT VARCHAR2(30) := 'SELC';
   G_ATTRIBUTE_TASK     CONSTANT VARCHAR2(30) := 'TASK';
   G_ATTRIBUTE_TEAM     CONSTANT VARCHAR2(30) := 'TEAM';
   G_ATTRIBUTE_TRNG     CONSTANT VARCHAR2(30) := 'TRNG';


   -- Sub-Program unit declarations
   /* Copy products from campaign,event headers,event offerings - all activities */
   PROCEDURE copy_act_prod (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

   /* Copy associations of campaign,deliverables,events - all activities.
      The procedure has flags .Depending on yes or no of the flag the
      campaigns,deliverables, event offering, event headers would be copied.
      Should be noted that all these components use the same activity
      object association table*/

   PROCEDURE copy_object_associations (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

   -- Sub-Program unit declarations

   -- Sub-Program unit declarations
   /* Copy geo_areas from campaign,event headers,event offerings -
      all activities */

   PROCEDURE copy_act_geo_areas (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

   -- Sub-Program unit declarations
   /* Copy resources from campaign,event headers,event offerings -
      all activities */

/* commented OUT NOCOPY by murali on may 13-2002 we don't support copying resource
PROCEDURE copy_act_resources (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
*/
   -- Sub-Program unit declarations
   /* Copy attachments from campaign,event headers,event offerings -
      all activities */

   PROCEDURE copy_act_attachments (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
-- Sub-Program unit declarations
   /* Copy access from campaign,event headers,event offerings -
      all activities */

   PROCEDURE copy_act_access (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

   -- Sub-Program unit declarations
   /* Copy delivkits from campaign,event headers,event offerings - all
      activities */

   PROCEDURE copy_deliv_kits (
      p_src_deli_id    IN       NUMBER,
      p_new_deliv_id   IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

   /* Copy categories from campaign,event headers,event offerings -
      all activities */
   PROCEDURE copy_act_categories (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
   /* Copy messages from campaign,event headers,event offerings - all activities */
   PROCEDURE copy_act_messages (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2

   );

   /* Copy market segments from campaign,event headers,event offerings -
      all activities */
   PROCEDURE copy_act_market_segments (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );


   /* Copy camapign schdelues from campaign - all activities */

  -- removed by soagrawa on 02-oct-2002
  -- refer to bug# 2605184

/*
   PROCEDURE copy_campaign_schedules (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_campaign_schedule_id   OUT NOCOPY      NUMBER,
      p_src_camp_schedule_id   IN       NUMBER,
      p_new_camp_id            IN       NUMBER
   );
*/
   PROCEDURE copy_tasks (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_camp_id            IN       NUMBER,
      p_new_camp_id            IN       NUMBER,
	 p_task_id                IN       NUMBER,
	 p_owner_id               IN       NUMBER,
	 p_actual_due_date        IN       DATE
   );

   PROCEDURE copy_partners (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_camp_id            IN       NUMBER,
      p_new_camp_id            IN       NUMBER
   );


   --
   -- Purpose
   --    Copy list select actions for a given object
   --    to a new object of the same type.
   PROCEDURE copy_list_select_actions (
      p_api_version     IN NUMBER,
      p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
      p_commit          IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_object_type     IN VARCHAR2,
      p_src_object_id   IN NUMBER,
      p_tar_object_id   IN NUMBER
   );

   -- copy partners - generic type i.e. not just for CAMP
   PROCEDURE copy_partners_generic (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_id                 IN       NUMBER,
      p_new_id                 IN       NUMBER,
      p_type                   IN       VARCHAR2
   );

--======================================================================
-- FUNCTION
--    copy_act_schedules
--
-- PURPOSE
--    Created to copy schedules for the campaign.
--
-- HISTORY
--    18-Aug-2001  ptendulk  Create.
--======================================================================
PROCEDURE copy_act_schedules(
   p_old_camp_id     IN    NUMBER,
   p_new_camp_id     IN    NUMBER,
   p_new_start_date  IN    DATE,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2) ;

--======================================================================
-- FUNCTION
--    copy_selected_schedule
--
-- PURPOSE
--    Created to copy selected schedules of the campaign.
--
-- HISTORY
--    04-Sep-2001  rrajesh  Created.
--======================================================================

PROCEDURE copy_selected_schedule(
   p_old_camp_id     IN    NUMBER,
   p_new_camp_id     IN    NUMBER,
   p_old_schedule_id IN    NUMBER,
   p_new_start_date  IN    DATE,
   p_new_end_date    IN    DATE,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2);


--======================================================================
-- FUNCTION
--    copy_act_content
--
-- PURPOSE
--    Created to copy content bug# 2175580
--
-- HISTORY
--    25-jan-2002  soagrawa  Created.
--======================================================================

   PROCEDURE copy_act_content (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

--======================================================================
-- FUNCTION
--    copy_act_collateral
--
-- PURPOSE
--    Created to copy collateral for 11.5.10
--
-- HISTORY
--    30-sep-2003  soagrawa  Created.
--======================================================================

   PROCEDURE copy_act_collateral (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );

--======================================================================
-- FUNCTION
--    copy_target_group
--
-- PURPOSE
--    Created to copy target group for 11.5.10
--
-- HISTORY
--    06-oct-2003  sodixit  Created.
--======================================================================

   PROCEDURE copy_target_group (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );


    -- Sub-Program unit declarations
    -- added by spragupa on 23-nov-2007 for ER 6467510 - For extending COPY functionality for TASKS
   /* Copy tasks from one  activity to other */
   PROCEDURE copy_act_task (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );


END ams_copyelements_pvt;

/
