--------------------------------------------------------
--  DDL for Package Body HXC_SELF_SERVICE_TIMECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SELF_SERVICE_TIMECARD_API" AS
/* $Header: hxctcmapi.pkb 115.11 2003/07/02 23:39:41 mvilrokx noship $ */

   PROCEDURE execute_deposit_process (
      p_validate            IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN              hxc_self_service_time_deposit.app_attributes_info,
      p_messages            OUT NOCOPY      hxc_self_service_time_deposit.message_table,
      p_mode                                VARCHAR2,
      p_deposit_process                     VARCHAR2,
      p_retrieval_process                   VARCHAR2 DEFAULT NULL,
      p_timecard_id         OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn        OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
   BEGIN
      timecard_pump (
         p_validate=> p_validate,
         p_app_blocks=> p_app_blocks,
         p_app_attributes=> p_app_attributes,
         p_messages=> p_messages,
         p_mode=> p_mode,
         p_deposit_process=> p_deposit_process,
         p_retrieval_process=> p_retrieval_process,
         p_timecard_id=> p_timecard_id,
         p_timecard_ovn=> p_timecard_ovn
      );
   END execute_deposit_process;

   PROCEDURE timecard_pump (
      p_validate            IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN              hxc_self_service_time_deposit.app_attributes_info,
      p_messages            OUT NOCOPY      hxc_self_service_time_deposit.message_table,
      p_mode                                VARCHAR2,
      p_deposit_process                     VARCHAR2,
      p_retrieval_process                   VARCHAR2 DEFAULT NULL,
      p_timecard_id         OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn        OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
      -- Need this declaration because p_app_attributes is NOT an OUT parameter
      -- in this procedure but it is in the new API, so I cannot use
      -- p_app_attributes directly to pass to the API and I do not want to
      -- change the interface of this API to assure backwards compatitibility.
      l_app_attributes   hxc_self_service_time_deposit.app_attributes_info;
   BEGIN
      l_app_attributes := p_app_attributes;
      hxc_timestore_deposit.execute_deposit_process (
         p_validate=> p_validate,
         p_mode=> p_mode,
         p_deposit_process=> p_deposit_process,
         p_retrieval_process=> p_retrieval_process,
         p_app_attributes=> l_app_attributes,
         p_app_blocks=> p_app_blocks,
         p_messages=> p_messages,
         p_timecard_id=> p_timecard_id,
         p_timecard_ovn=> p_timecard_ovn
      );
   END timecard_pump;
END hxc_self_service_timecard_api;

/
