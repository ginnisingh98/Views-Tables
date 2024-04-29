--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_UTILITIES" AUTHID CURRENT_USER AS
      /* $Header: hxcaprutil.pkh 120.0.12010000.3 2015/08/14 11:38:27 rpakalap ship $ */

         /*=========================================================================
          * This procedure returns result for Mass Timecard Approval page
          *========================================================================*/
         PROCEDURE get_approval_notifications(
             p_approver_id     IN NUMBER
            ,p_approval_array OUT NOCOPY HXC_NOTIFICATION_TABLE_TYPE
            ,p_resource_id     IN VARCHAR2
            ,p_from_date       IN VARCHAR2
            ,p_to_date         IN VARCHAR2
            ,p_adv_search      IN VARCHAR2
            ,p_mode            IN VARCHAR2 DEFAULT 'PENDING'
         );

         FUNCTION attribute_search(
           p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
          ,p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
          ,p_search_by       IN VARCHAR2
          ,p_search_value    IN VARCHAR2
          ,p_search_operator IN VARCHAR2
          ,p_resource_id     IN VARCHAR2
         ) RETURN VARCHAR2;


         FUNCTION has_detail_comment(
           p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
          ,p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
          ,p_operator  IN VARCHAR2
          ,p_comment   IN VARCHAR2

         ) RETURN VARCHAR2;

         FUNCTION has_comment(
           p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
          ,p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
          ,p_operator  IN VARCHAR2
          ,p_comment   IN VARCHAR2

         ) RETURN VARCHAR2;
		 --Start bug 21490110 ----
		 TYPE VARCHARTABLE IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(200);
		 g_concatenated_name   VARCHARTABLE;
         g_translated_name       VARCHARTABLE;


		 FUNCTION get_translated_name
        (p_concatenated_name IN varchar2
         ) RETURN varchar2;
         --End bug 21490110 ----
         PROCEDURE release_locks;


         END hxc_approval_utilities;

/
