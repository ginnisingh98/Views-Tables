--------------------------------------------------------
--  DDL for Package HXT_HXC_RETRIEVAL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXC_RETRIEVAL_PROCESS" AUTHID CURRENT_USER AS
/* $Header: hxthcrtp.pkh 120.1.12010000.4 2009/06/07 16:25:11 asrajago ship $ */

--
g_full_name         VARCHAR2(240);
g_messages          hxc_self_service_time_deposit.message_table;
--
g_otm_messages      hxc_self_service_time_deposit.message_table;

-- Bug 7557568
-- Added the following record type to process deleted details.
TYPE DETAIL_REC  IS RECORD
( detail_bb_id   NUMBER,
  detail_bb_ovn  NUMBER,
  parent_id      NUMBER,
  parent_ovn     NUMBER,
  type           VARCHAR2(50),
  measure        NUMBER,
  start_time     DATE,
  new            VARCHAR2(10),
  date_to        DATE);

TYPE DETAIL_TAB  IS TABLE OF DETAIL_REC INDEX BY VARCHAR2(30);

g_detail_tab   DETAIL_TAB;

-- Bug 8486310
-- Added the following types and variables to store the alternate
--  name identifiers and alias defns respectively.
TYPE VARCHARTAB IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(50);
g_an_id  VARCHARTAB;
g_alias_id  NUMBER;

PROCEDURE synchronize_deletes_in_otlr
 (p_time_building_blocks IN  hxc_self_service_time_deposit.timecard_info
 ,p_time_att_info        IN  hxc_self_Service_time_deposit.app_attributes_info
 ,p_messages             IN OUT  NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE
 ,p_timecard_source      IN VARCHAR	-- added for 5137310
 );

PROCEDURE otm_validate_process
            (p_operation            IN            VARCHAR2
            ,p_time_building_blocks IN OUT NOCOPY VARCHAR2
            ,p_time_attributes      IN OUT NOCOPY VARCHAR2
            ,p_messages             IN OUT NOCOPY VARCHAR2);
--
PROCEDURE validate_timecard
 (p_operation            IN            VARCHAR2
 ,p_time_building_blocks IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
 ,p_time_attributes      IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
 ,p_messages             IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE);
--
Procedure otlr_validation_required
           (p_operation            in            varchar2
           ,p_otm_explosion        in            varchar2
           ,p_otm_rtr_id           in            number
           ,p_app_set_id           in            number
           ,p_timecard_id          in            number
           ,p_timecard_ovn         in            number
           ,p_time_building_blocks in            hxc_self_service_time_deposit.timecard_info
           ,p_time_att_info        in            hxc_self_Service_time_deposit.app_attributes_info
           ,p_messages             in out nocopy hxc_self_service_time_deposit.message_table
           );
--
PROCEDURE otlr_review_details(
 p_time_building_blocks IN     HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
,p_time_attributes      IN     HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
,p_messages             IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE
,p_detail_build_blocks IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
,p_detail_attributes  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info);
--
FUNCTION build_attributes(
     p_detail_attributes  IN HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
           )
RETURN HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info;
--

-- Bug 8486310
-- Added new procedure to save Alt Name Identifiers.
PROCEDURE save_an_ids(p_element IN VARCHAR2) ;

-- Bug 7557568
-- Added the following function to check if a detail is deleted
-- after a SAVE.
PROCEDURE check_restrict_edit( p_time_building_blocks  IN      HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info,
                               p_messages              IN  OUT  NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.message_table );



END hxt_hxc_retrieval_process;


/
