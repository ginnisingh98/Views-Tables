--------------------------------------------------------
--  DDL for Package HXC_TIMESTORE_DEPOSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMESTORE_DEPOSIT" AUTHID CURRENT_USER AS
/* $Header: hxctsdp.pkh 120.8.12010000.2 2009/11/20 10:00:52 bbayragi ship $ */
/*#
 * This package contains procedures that can be used to manage timecards and
 * save them into the OTL TimeStore.
 * @rep:scope public
 * @rep:product HXT
 * @rep:displayname TimeStore Deposit
*/
   g_otl_deposit_process       CONSTANT hxc_deposit_processes.NAME%TYPE
                                                     := 'OTL Deposit Process';
   g_validate BOOLEAN;

   SUBTYPE mode_varchar2 IS VARCHAR2 (15);

   c_hours_uom                 CONSTANT hxc_time_building_blocks.unit_of_measure%TYPE
                                                                   := 'HOURS';
   c_migration                 CONSTANT mode_varchar2          := 'MIGRATION';
   c_tk_save                   CONSTANT mode_varchar2         := 'FORCE_SAVE';
   c_tk_submit                 CONSTANT mode_varchar2       := 'FORCE_SUBMIT';
   c_auto_approve_name         CONSTANT hxc_approval_styles.NAME%TYPE
                                                        := 'OTL Auto Approve';
   c_approval_on_submit_name   CONSTANT hxc_approval_styles.NAME%TYPE
                                                      := 'Approval on Submit';

--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_timecard_tables >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure used to retrieve the Timecard from the TimeStore and place the
 * Time Building Blocks in a SQL Type Nested Table and the attributes in a
 * PL/SQL Type Nested Table.
 *
 * Use this procedure to retrieve the currently active Timecard and its
 * Attributes from the Database into their respective PL/SQL Collections.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * Timecard should be present in the TimeStore.
 *
 * <p><b>Post Success</b><br>
 * SQL and PL/SQL Type Nested Tables will contain Timecard and Timecard
 * Attributes.
 *
 * <p><b>Post Failure</b><br>
 * SQL and PL/SQL Type Nested Tables will be empty.
 *
 * @param p_building_block_id Time Building Block of the Timecard to retrieve.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_clear_mapping_cache can be used to clear the mapping cache
 * @param p_app_blocks SQL Type Nested Table that will hold the Time Building
 * Blocks of the Timecard.
 * @param p_app_attributes PL/SQL Type Nested Table that will hold the Time
 * Attributes of the Timecard.
 * @rep:displayname Get Timecard
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE get_timecard_tables (
      p_building_block_id     IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process       IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_clear_mapping_cache   IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks            OUT NOCOPY      hxc_block_table_type,
      p_app_attributes        OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_timecard_tables >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure used to retrieve the Timecard from the TimeStore and place the
 * Time Building Blocks and the attributes in a PL/SQL Type Nested Table.
 *
 * Use this procedure to retrieve the currently active Timecard and its
 * Attributes from the Database into their respective PL/SQL Collections.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * Timecard should be present in the TimeStore.
 *
 * <p><b>Post Success</b><br>
 * PL/SQL Type Nested Tables will contain Timecard and Timecard Attributes.
 *
 * <p><b>Post Failure</b><br>
 * PL/SQL Type Nested Tables will be empty.
 *
 * @param p_building_block_id Building Block of the Timecard to retrieve.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_clear_mapping_cache can be used to clear the mapping cache
 * @param p_app_blocks PL/SQL Table that will hold the time portion of the
 * Timecard object.
 * @param p_app_attributes PL/SQL Table that will hold the attributes related
 * to the Time Building Blocks held in p_app_blocks.
 * @rep:displayname Get Timecard
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE get_timecard_tables (
      p_building_block_id     IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process       IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_clear_mapping_cache   IN              BOOLEAN DEFAULT FALSE,
      p_app_blocks            OUT NOCOPY      hxc_self_service_time_deposit.timecard_info,
      p_app_attributes        OUT NOCOPY      hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_bb >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure to add one Time Building Block to the Time Building Block SQL Type
 * Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block will have been added to the Time Building Block SQL Type
 * Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block will not be added to the Time Building Block SQL Type
 * Nested Table.
 *
 * @param p_time_building_block_id Surrogate Time Building Block for the Time
 * Building Block, this is needed to link potential child Time Building Blocks
 * to this Time Building Block.
 * @param p_type Type of the Time Building Block: 'MEASURE' or 'RANGE'.
 * @param p_measure The actual time recorded, only provide when type is
 * 'MEASURE'.
 * @param p_unit_of_measure Units of measure for p_measure, the default value
 * is recommended for most scenarios.
 * @param p_start_time The IN time: only provide when type is 'RANGE'.
 * @param p_stop_time The OUT time: only provide when type is 'RANGE'.
 * @param p_parent_building_block_id Identifies the Time Building Block to
 * which this Time Building Block needs to be attached.
 * @param p_parent_is_new Set to 'Y', if the parent Time Building Block does
 * not exist in the database, else set to 'N'.
 * @param p_scope Use one of the following values: 'TIMECARD', 'DAY' or
 * 'DETAIL'.
 * @param p_object_version_number Object version number of the Time Building
 * Block being created, the default value is recommended for most scenarios.
 * @param p_approval_status Use one of the following values: 'WORKING' or
 * 'SUBMITTED'.
 * @param p_resource_id Resource identifier to which the Time Building Block
 * belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_approval_style_id The identifier of the approval style, used to
 * approve the Time Building Block.
 * @param p_date_from Date from which the Time Building Block is valid, the
 * default value is recommended for most scenarios.
 * @param p_date_to The latest date this Time Building Block is valid, the
 * default value is recommended for most scenarios.
 * @param p_comment_text Comment to be stored with the Time Building Block.
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_new For new Time Building Blocks this needs to be 'Y', the default
 * value is recommended for most scenarios.
 * @param p_changed For new Time Building Blocks this needs to be 'N', the
 * default value is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the Time Building Block to. On success, the Time Building Block
 * created will be added to this SQL Type Nested Table.
 * @rep:displayname Create Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_bb (
      p_time_building_block_id      IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT NULL,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT c_hours_uom,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT NULL,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT NULL,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE
            DEFAULT NULL,
      p_parent_is_new               IN              VARCHAR2,
      p_scope                       IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_object_version_number       IN              hxc_time_building_blocks.object_version_number%TYPE
            DEFAULT 1,
      p_approval_status             IN              hxc_time_building_blocks.approval_status%TYPE
            DEFAULT NULL,
      p_resource_id                 IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type               IN              hxc_time_building_blocks.resource_type%TYPE,
      p_approval_style_id           IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_date_from                   IN              hxc_time_building_blocks.date_from%TYPE
            DEFAULT SYSDATE,
      p_date_to                     IN              hxc_time_building_blocks.date_to%TYPE
            DEFAULT hr_general.end_of_time,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT NULL,
      p_new                         IN              VARCHAR2 DEFAULT 'Y',
      p_changed                     IN              VARCHAR2 DEFAULT '',
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_bb >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure to add one Time Building Block to the Time Building Block PL/SQL
 * Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block will have been added to the Time Building Block PL/SQL
 * Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block will not be added to the Time Building Block PL/SQL Type
 * Nested Table.
 *
 * @param p_time_building_block_id Surrogate Time Building Block identifierfor
 * the Time Building Block. This is needed to link potential child Time
 * Building Blocks to this Time Building Block.
 * @param p_type Type of the Time Building Block: 'MEASURE' or 'RANGE'.
 * @param p_measure The actual time recorded, only provide when type is
 * 'MEASURE'.
 * @param p_unit_of_measure Units of measure for p_measure, the default value
 * is recommended for most scenarios.
 * @param p_start_time The IN time: only provide when type is 'RANGE'.
 * @param p_stop_time The OUT time: only provide when type is 'RANGE'.
 * @param p_parent_building_block_id Identifies of the Time Building Block to
 * which this Time Building Block needs to be attached.
 * @param p_parent_is_new Set to 'Y', if the parent Time Building Block does
 * not exist in the database, else set to 'N'.
 * @param p_scope Use one of the following values: 'TIMECARD', 'DAY' or
 * 'DETAIL'.
 * @param p_object_version_number Object version number of the Time Building
 * Block being created, the default value is recommended for most scenarios.
 * @param p_approval_status Use one of the following values: 'WORKING' or
 * 'SUBMITTED'.
 * @param p_resource_id Resource Identifier to which the Time Building Block
 * belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_approval_style_id The identifier of the approval style used to
 * approve the Time Building Block.
 * @param p_date_from Date from which the Time Building Block is valid, the
 * default value is recommended for most scenarios.
 * @param p_date_to The latest date this Time Building Block is valid, the
 * default value is recommended for most scenarios.
 * @param p_comment_text Comment to be stored with the Time Building Block.
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_new For new Time Building Blocks this needs to be 'Y', the default
 * value is recommended for most scenarios.
 * @param p_changed For new Time Building Blocks this needs to be 'N', the
 * default value is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Building Block to. On success, the Time Building Block
 * created will be added to this PL/SQL Type Nested Table.
 * @rep:displayname Create Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_bb (
      p_time_building_block_id      IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT NULL,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT c_hours_uom,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT NULL,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT NULL,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE
            DEFAULT NULL,
      p_parent_is_new               IN              VARCHAR2,
      p_scope                       IN              hxc_time_building_blocks.SCOPE%TYPE,
      p_object_version_number       IN              hxc_time_building_blocks.object_version_number%TYPE
            DEFAULT 1,
      p_approval_status             IN              hxc_time_building_blocks.approval_status%TYPE
            DEFAULT NULL,
      p_resource_id                 IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type               IN              hxc_time_building_blocks.resource_type%TYPE,
      p_approval_style_id           IN              hxc_time_building_blocks.approval_style_id%TYPE,
      p_date_from                   IN              hxc_time_building_blocks.date_from%TYPE
            DEFAULT SYSDATE,
      p_date_to                     IN              hxc_time_building_blocks.date_to%TYPE
            DEFAULT hr_general.end_of_time,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT NULL,
      p_new                         IN              VARCHAR2 DEFAULT 'Y',
      p_changed                     IN              VARCHAR2 DEFAULT '',
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_timecard_bb >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type TIMECARD and adds them
 * to the Time Building Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type TIMECARD will have been added to the Time
 * Building Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type TIMECARD will not get added to the Time Building
 * Block SQL Type Nested Table.
 *
 * @param p_start_time The first day of the TIMECARD.
 * @param p_stop_time The last day of the TIMECARD.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_approval_style_id WORKING' or 'SUBMITTED'. When this parameter is
 * set to null, the real value will be derived from the mode used during
 * deposit.
 * @param p_comment_text Comment to be stored with the TIMECARD Time Building
 * Block.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the TIMECARD Time Building Block to. On success, the Time Building
 * Block created will be added to this SQL Type Nested Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Timecard Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_timecard_bb (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.stop_time%TYPE,
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      -- default to person because there is no other resource type at the moment.
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      -- We cannot use approval_style_name because that is not unique.
      p_approval_style_id        IN              hxc_time_building_blocks.approval_style_id%TYPE
            DEFAULT NULL,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_timecard_bb >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type TIMECARD and adds them
 * to the Time Building Block PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type Timecard will have been added to the Time
 * Building Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type Timecard will not get added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * @param p_start_time The first day of the TIMECARD.
 * @param p_stop_time The last day of the TIMECARD.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_approval_style_id WORKING' or 'SUBMITTED'. When this parameter is
 * set to null, the real value will be derived from the mode used during
 * deposit.
 * @param p_comment_text Comment to be stored with the TIMECARD Time Building
 * Block.
 * @param p_app_blocks Pass in the Timecard PL/SQL Table to attach the TIMECARD
 * Time Building Block to. On success, the Time Building Block created will be
 * added to this PL/SQL Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Timecard Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_timecard_bb (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.stop_time%TYPE,
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      -- default to person because there is no other resource type at the moment.
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      -- We cannot use approval_style_name because that is not unique.
      p_approval_style_id        IN              hxc_time_building_blocks.approval_style_id%TYPE
            DEFAULT NULL,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_day_bb >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DAY and adds them to the
 * Time Building Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type TIMECARD should have been already added to the
 * SQL Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DAY will have been added to the Time Building
 * Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DAY will not be added to the Time Building Block
 * SQL Type Nested Table.
 *
 * @param p_day Day to create the DAY Time Building Block.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_comment_text Comment to be stored with the DAY Time Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the DAY Time Building Block to. On success, the Time Building Block
 * created will be added to this SQL Type Nested Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Day Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_day_bb (
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      -- p_parent_building_block_ovn            hxc_time_building_blocks.parent_building_block_ovn%TYPE
      -- DEFAULT 1,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_day_bb >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DAY and adds them to the
 * Time Building Block PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type TIMECARD should have been added already to the
 * PL/SQL Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DAY will have been added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DAY will not get added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * @param p_day Day to create the DAY Time Building Block.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently must be set to 'PERSON'.
 * @param p_comment_text Comment to be stored with the DAY Time Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the DAY Time Building Block to. On success, the Time Building
 * Block created will be added to this PL/SQL Type Nested Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Day Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_day_bb (
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      -- p_parent_building_block_ovn            hxc_time_building_blocks.parent_building_block_ovn%TYPE
      -- DEFAULT 1,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_day_bb >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DAY and adds them to the
 * Time Building Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type TIMECARD should have been added already to the
 * SQL Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DAY will have been added to the Time Building
 * Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DAY will not get added to the Time Building
 * Block SQL Type Nested Table.
 *
 * @param p_day Day to create the DAY Time Building Block.
 * @param p_parent_building_block_id Identifies the parent (Timecard) Time
 * Building Block.
 * @param p_comment_text Comment to be stored with the DAY Time Building Block.
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the DAY Time Building Block to. On success, the Time Building Block
 * created will be added to this SQL Type Nested Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Day Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_day_bb (
      p_day                         IN              hxc_time_building_blocks.start_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE
            DEFAULT NULL,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT 1,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_day_bb >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DAY and adds them to the
 * Time Building Block PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type TIMECARD should have been added already to the
 * PL/SQL Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DAY will have been added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DAY will not get added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * @param p_day Day to create the DAY Time Building Block.
 * @param p_parent_building_block_id Identifies the parent Timecard Time
 * Building Block.
 * @param p_comment_text Comment to be stored with the DAY Time Building Block.
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the DAY Time Building Block to. On success, the Time Building
 * Block created will be added to this PL/SQL Type Nested Table.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Day Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_day_bb (
      p_day                         IN              hxc_time_building_blocks.start_time%TYPE,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE
            DEFAULT NULL,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT 1,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

 /*  PROCEDURE auto_create_timecard (
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

   PROCEDURE auto_create_timecard (
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   ); */


--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_detail_bb >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DETAIL and adds them to
 * the Time Building Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type DAY should have been added already to the SQL
 * Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DETAIL will have been added to the Time Building
 * Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DETAIL will not get added to the Time Building
 * Block SQL Type Nested Table.
 *
 * @param p_type Type of the Time Building Block: 'MEASURE' or 'RANGE'.
 * @param p_measure The actual time recorded, only provide when type is
 * 'MEASURE'.
 * @param p_start_time The IN time: only provide when type is 'RANGE'.
 * @param p_stop_time The OUT time: only provide when type is 'RANGE'.
 * @param p_parent_building_block_id Identifies the parent (Detail) Time
 * Building Block
 * @param p_comment_text Comment to be stored with the DETAIL Time Building
 * Block
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_unit_of_measure Units of measure for p_measure, the default value
 * is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the DETAIL Time Building Block to. On success, the Time Building
 * Block created will be added to this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Detail Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_detail_bb (
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT NULL,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT NULL,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT NULL,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      -- For now, these need to be the same as the parent BB (the TIMECARD BB).  We set this in the code,
      -- the user cannot manipulate this.
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      -- p_resource_id                IN       hxc_time_building_blocks.resource_id%TYPE,
      -- p_resource_type              IN       hxc_time_building_blocks.resource_type%TYPE,
      -- p_approval_style_id          IN       hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT 1,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT NULL,
      p_app_blocks                  IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes              IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_detail_bb >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Procedure that creates Time Building Blocks of type DETAIL and adds them to
 * the Time Building Block PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * A Time Building Block of type DAY should have been added already to the
 * PL/SQL Type Nested Table.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block of type DETAIL will have been added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block of type DETAIL will not get added to the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * @param p_type Type of the Time Building Block: 'MEASURE' or 'RANGE'.
 * @param p_measure The actual time recorded, only provide when type is
 * 'MEASURE'.
 * @param p_start_time The IN time: only provide when type is 'RANGE'.
 * @param p_stop_time The OUT time: only provide when type is 'RANGE'.
 * @param p_parent_building_block_id Identifies the parent (Detail) Time
 * Building Block.
 * @param p_comment_text Comment to be stored with the DETAIL Time Building
 * Block.
 * @param p_parent_building_block_ovn Object Version Number of the parent Time
 * Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_unit_of_measure Units of measure for p_measure, the default value
 * is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the DETAIL Time Building Block to. On success, the Time Building
 * Block created will be added to this PL/SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Detail Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_detail_bb (
      p_type                        IN              hxc_time_building_blocks.TYPE%TYPE,
      p_measure                     IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT NULL,
      p_start_time                  IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT NULL,
      p_stop_time                   IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT NULL,
      p_parent_building_block_id    IN              hxc_time_building_blocks.parent_building_block_id%TYPE,
      -- For now, these need to be the same as the parent BB (the TIMECARD BB).  We set this in the code,
      -- the user cannot manipulate this.
      -- p_approval_status            IN       hxc_time_building_blocks.approval_status%TYPE,
      -- p_resource_id                IN       hxc_time_building_blocks.resource_id%TYPE,
      -- p_resource_type              IN       hxc_time_building_blocks.resource_type%TYPE,
      -- p_approval_style_id          IN       hxc_time_building_blocks.approval_style_id%TYPE,
      p_comment_text                IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_parent_building_block_ovn   IN              hxc_time_building_blocks.parent_building_block_ovn%TYPE
            DEFAULT 1,
      p_deposit_process             IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_unit_of_measure             IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT NULL,
      p_app_blocks                  IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes              IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id      OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_time_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a &quot;measure&quot; Time Entry to be created, using the Timecard
 * SQL Type Nested Table.
 *
 * This is a specialised procedure that allows creation of a Time Entry.This
 * procedure will take care of creating the corresponding Timecard if it
 * doesn't exist yet. Note that this procedure does not manipulate any of the
 * database table contents. Only the PL/SQL nested table parameters passed into
 * this procedure will be modified.The execute_deposit_process API will need to
 * be used to actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will have been added to
 * the Time Building Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will not get added to
 * the Time Building Block SQL Type Nested Table and an error will be raised.
 *
 * @param p_measure The actual time recorded in hours.
 * @param p_day Day to create the Time Entry.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently we only support 'PERSON'.
 * @param p_comment_text Comment to be stored with the Time Entry.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the Time Entry to. On success, the Time Building Block created will
 * be added to this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Measure Time Entry
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_time_entry (
      p_measure                  IN              hxc_time_building_blocks.measure%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_time_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows creation of a &quot;measure&quot; Time Entry, using the Timecard
 * PL/SQL Type Nested Table.
 *
 * This procedure will take care of creating the corresponding Timecard
 * Structure if it doesn't exist yet. Note that this procedure does not
 * manipulate any of the database table contents. Only the PL/SQL nested table
 * parameters passed into this procedure will be modified. The
 * execute_deposit_process API will need to be used to actually update the
 * database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will have been added to
 * the Time Building Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will not get added to
 * the Time Building Block PL/SQL Type Nested Table and an error will be
 * raised.
 *
 * @param p_measure The actual time recorded in hours.
 * @param p_day Day to create the Time Entry.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently we only support 'PERSON'.
 * @param p_comment_text Comment to be stored with the Time Entry.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Entry to. On success, the Time Building Block created
 * will be added to this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Measure Time Entry
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_time_entry (
      p_measure                  IN              hxc_time_building_blocks.measure%TYPE,
      p_day                      IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_time_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows creation of a &quot;range&quot; Time Entry, using the Timecard SQL
 * Type Nested Table.
 *
 * This is a specialised procedure that allows creation of a Time Entry. This
 * procedure will take care of creating the corresponding Timecard Structure if
 * it doesn't exist yet. Note that this procedure does not manipulate any of
 * the database table contents. Only the PL/SQL nested table parameters passed
 * into this procedure will be modified.The execute_deposit_process API will
 * need to be used to actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will have been added to
 * the Time Building Block SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will not get added to
 * the Time Building Block SQL Type Nested Table and an error will be raised.
 *
 * @param p_start_time The IN time.
 * @param p_stop_time The OUT time.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently we only support 'PERSON'.
 * @param p_comment_text Comment to be stored with the Time Entry.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Entry to. On success, the Time Building Block created
 * will be added to this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Range Time Entry
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_time_entry (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_time_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows creation of a &quot;range&quot; Time Entry, using the Timecard PL/SQL
 * Type Nested Table.
 *
 * Allows creations of a Time Entry. This procedure will take care of creating
 * the corresponding Timecard Structure if it doesn't exist yet. Note that this
 * procedure does not manipulate any of the database table contents. Only the
 * PL/SQL nested table parameters passed into this procedure will be modified.
 * The execute_deposit_process API will need to be used to actually update the
 * database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will have been added to
 * the Time Building Block PL/SQL Type Nested Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Entry (i.e. Time Building Block of type DETAIL) will not get added to
 * the Time Building Block PL/SQL Type Nested Table and an error will be
 * raised.
 *
 * @param p_start_time The IN time.
 * @param p_stop_time The OUT time.
 * @param p_resource_id Resource to which the Time Building Block belongs.
 * @param p_resource_type Type of resource, currently we only support 'PERSON'.
 * @param p_comment_text Comment to be stored with the Time Entry.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Entry to. On success, the Time Building Block created
 * will be added to this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @param p_time_building_block_id Uniquely identifies the Time Building Block
 * created.
 * @rep:displayname Create Range Time Entry
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_time_entry (
      p_start_time               IN              hxc_time_building_blocks.start_time%TYPE,
      p_stop_time                IN              hxc_time_building_blocks.start_time%TYPE,
      p_resource_id              IN              hxc_time_building_blocks.resource_id%TYPE,
      p_resource_type            IN              hxc_time_building_blocks.resource_type%TYPE
            DEFAULT hxc_timecard.c_person_resource,
      p_comment_text             IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT NULL,
      p_deposit_process          IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks               IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes           IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_time_building_block_id   OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_attribute >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Time Attribute to be created, using the Time Attribute PL/SQL Type
 * Nested Table. Note that this procedure does not manipulate any of the
 * database table contents. Only the PL/SQL nested table parameters passed into
 * this procedure will be modified. The execute_deposit_process API will need
 * to be used to actually update the database.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Building Block should already be present in the Timecard PL/SQL
 * Table.
 *
 * <p><b>Post Success</b><br>
 * Time Attribute will have been added to the Time Attribute PL/SQL Type Nested
 * Table.
 *
 * <p><b>Post Failure</b><br>
 * Time Attribute will not get added to the Time Attribute PL/SQL Type Nested
 * Table.
 *
 * @param p_building_block_id Identifies the Time Building Block to attach the
 * Time Attribute too.
 * @param p_attribute_name Name of the attribute to be created.
 * @param p_attribute_value Value of the attribute to be created.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_attribute_id Uniquely identifies the Time Attribute created.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * to attach the Time Attribute to. On success, the Time Attribute created will
 * be added to this PL/SQL Type Nested Table.
 * @rep:displayname Create Time Attribute
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE create_attribute (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_attribute_id        IN              hxc_time_attributes.time_attribute_id%TYPE
            DEFAULT NULL,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_building_block >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Time Building Block to be updated, using the Time Building Block
 * SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Building Block to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block is updated.
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block is not updated.
 *
 * @param p_building_block_id Identifies the Time Building Block to modify.
 * @param p_measure The actual time recorded, only provide when the Time
 * Building Block type is 'MEASURE'.
 * @param p_unit_of_measure Units of measure for p_measure.
 * @param p_start_time The IN time, only required when the Time Building Block
 * type is 'RANGE'.
 * @param p_stop_time The OUT time, only required when the Time Building Block
 * type is 'RANGE'.
 * @param p_comment_text Comment to be stored with the Time Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the Time Entry to. On success, the Time Building Block updated will
 * be updated in this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @rep:displayname Update Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE update_building_block (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_measure             IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT hr_api.g_number,
      p_unit_of_measure     IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT hr_api.g_varchar2,
      p_start_time          IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT hr_api.g_date,
      p_stop_time           IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT hr_api.g_date,
      p_comment_text        IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT hr_api.g_varchar2,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_building_block >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows update of a Time Building Block, using the Time Building Block PL/SQL
 * Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Building Block being updated should exist.
 *
 * <p><b>Post Success</b><br>
 * Time Building Block gets updated
 *
 * <p><b>Post Failure</b><br>
 * Time Building Block does not get updated
 *
 * @param p_building_block_id Identifies the Time Building Block to modify.
 * @param p_measure The actual time recorded, only provide when type is
 * 'MEASURE'.
 * @param p_unit_of_measure Units of measure for p_measure, the default value
 * is recommended for most scenarios.
 * @param p_start_time The IN time: only provide when type is 'RANGE'.
 * @param p_stop_time The OUT time: only provide when type is 'RANGE'.
 * @param p_comment_text Comment to be stored with the Time Building Block.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Entry to. On success, the Time Building Block updated
 * will be in this PL/SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @rep:displayname Update Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE update_building_block (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      p_measure             IN              hxc_time_building_blocks.measure%TYPE
            DEFAULT hr_api.g_number,
      p_unit_of_measure     IN              hxc_time_building_blocks.unit_of_measure%TYPE
            DEFAULT hr_api.g_varchar2,
      p_start_time          IN              hxc_time_building_blocks.start_time%TYPE
            DEFAULT hr_api.g_date,
      p_stop_time           IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT hr_api.g_date,
      p_comment_text        IN              hxc_time_building_blocks.comment_text%TYPE
            DEFAULT hr_api.g_varchar2,
      --  p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_attribute >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Time Attribute to be updated, using the Time Attribute SQL Type
 * Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Attribute being updated should already exist.
 *
 * <p><b>Post Success</b><br>
 * Time Attribute is updated.
 *
 * <p><b>Post Failure</b><br>
 * Time Attribute is not updated.
 *
 * @param p_time_attribute_id Identifies the Time Attribute to modify.
 * @param p_attribute_name Name of the attribute.
 * @param p_attribute_value Value of the attribute.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table.
 * This procedure does not update the table.
 * @param p_app_attributes Pass in the Attribute PL/SQL Nested Table containing
 * the attribute to be updated. On success, the Time Attribute updated will be
 * updated in this PL/SQL Nested Table.
 * @rep:displayname Update Time Attribute
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE update_attribute (
      p_time_attribute_id   IN              hxc_time_attributes.time_attribute_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE
            DEFAULT hr_api.g_varchar2,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_attribute >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Time Attribute to be updated, using the Time Attribute PL/SQL Type
 * Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Attribute being updated should already exist.
 *
 * <p><b>Post Success</b><br>
 * Time Attribute is updated.
 *
 * <p><b>Post Failure</b><br>
 * Time Attribute is not updated.
 *
 * @param p_time_attribute_id Identifies the Time Attribute to modify.
 * @param p_attribute_name Name of the attribute.
 * @param p_attribute_value Value of the attribute.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested
 * Table. This procedure will not update the table.
 * @param p_app_attributes Pass in the Attribute PL/SQL Nested Table containing
 * the attribute to update. On success, the Time Attribute updated will be in
 * this PL/SQL Nested Table.
 * @rep:displayname Update Time Attribute
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE update_attribute (
      p_time_attribute_id   IN              hxc_time_attributes.time_attribute_id%TYPE,
      p_attribute_name      IN              hxc_mapping_components.field_name%TYPE,
      p_attribute_value     IN              hxc_time_attributes.attribute1%TYPE
            DEFAULT hr_api.g_varchar2,
      -- p_category            IN       hxc_bld_blk_info_type_usages.building_block_category%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_detail_bb >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Detail Time Building Block to be deleted, using the Time Building
 * Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Time Building Block is deleted from the Timecard.
 *
 * <p><b>Post Failure</b><br>
 * The Time Building Block is not deleted from the Timecard.
 *
 * @param p_building_block_id Identifies the Time Building Block to delete.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_effective_date Date at which the delete becomes effective, the
 * default value is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block SQL Type Nested Table to
 * attach the Time Entry to. On success, the Time Building Block deleted will
 * be removed from this SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @rep:displayname Delete Detail Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE delete_detail_bb (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_effective_date      IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT SYSDATE,
      p_app_blocks          IN OUT NOCOPY   hxc_block_table_type,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_detail_bb >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allows a Detail Time Building Block to be deleted, using the Time Building
 * Block PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be modified. The execute_deposit_process API will need to be used to
 * actually update the database.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Time Building Block is deleted from the Timecard.
 *
 * <p><b>Post Failure</b><br>
 * The Time Building Block is not deleted from the Timecard.
 *
 * @param p_building_block_id Identifies the Time Building Block to delete.
 * @param p_deposit_process Deposit process indicates which attribute to
 * application mapping should be used to retrieve the Timecard attributes.
 * @param p_effective_date Date at which the delete becomes effective, the
 * default value is recommended for most scenarios.
 * @param p_app_blocks Pass in the Time Building Block PL/SQL Type Nested Table
 * to attach the Time Entry to. On success, the Time Building Block deleted
 * will be removed from this PL/SQL Type Nested Table.
 * @param p_app_attributes Pass in the Time Attribute PL/SQL Type Nested Table
 * containing the Time Building Blocks attributes which have already been
 * created. This procedure will not modify the table contents.
 * @rep:displayname Delete Detail Time Building Block
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE delete_detail_bb (
      p_building_block_id   IN              hxc_time_building_blocks.time_building_block_id%TYPE,
      -- p_time_recipient_id   IN       NUMBER,
      p_deposit_process     IN              hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_effective_date      IN              hxc_time_building_blocks.stop_time%TYPE
            DEFAULT SYSDATE,
      p_app_blocks          IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_timecard >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Deletes the entire Timecard.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Timecard is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Timecard is not deleted.
 *
 * @param p_building_block_id Identifies the Timecard to deleted.
 * @param p_mode Delete mode, the default value is recommended for most
 * scenarios.
 * @param p_deposit_process Obsolete parameter, do not use.
 * @param p_retrieval_process Obsolete parameter, do not use.
 * @param p_effective_date Date at which the delete becomes effective, the
 * default value is recommended for most scenarios.
 * @param p_template Set to 'Y' if deleting a template, else use 'N'
 * (=Default).
 * @rep:displayname Delete Timecard
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE delete_timecard (
      p_building_block_id   IN   hxc_time_building_blocks.time_building_block_id%TYPE,
      p_mode                IN   VARCHAR2 DEFAULT hxc_timecard.c_delete,
      p_deposit_process     IN   hxc_deposit_processes.NAME%TYPE
            DEFAULT g_otl_deposit_process,
      p_retrieval_process   IN   VARCHAR2 DEFAULT NULL,
      p_effective_date      IN   hxc_time_building_blocks.stop_time%TYPE
            DEFAULT SYSDATE,
      p_template            IN   VARCHAR2 DEFAULT hxc_timecard.c_no
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< execute_deposit_process >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Deposits the Timecard in the TimeStore, using the Timecard SQL Type Nested
 * Table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Timecard will be deposited into the TimeStore.
 *
 * <p><b>Post Failure</b><br>
 * The Timecard will not be deposited in the TimeStore, error messages will be
 * logged in the message table out parameter.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_mode Mode must be set to 'SUBMIT', 'SAVE', 'MIGRATION',
 * 'FORCE_SAVE' or 'FORCE_SUBMIT'.
 * @param p_deposit_process Process to be used for deposit.
 * @param p_retrieval_process Process to be used for retrieval, only use if
 * mode = 'MIGRATION'.
 * @param p_app_attributes Attributes to deposit.
 * @param p_app_blocks Time Building Blocks to deposit.
 * @param p_messages Contains all the messages raised during the execution of
 * this procedure.
 * @param p_timecard_id Uniquely identifies the created Timecard.
 * @param p_timecard_ovn Set to the object version number of the created
 * Timecard.
 * @param p_template Set to 'Y' if creating a template, else set to 'N'
 * (default).
 * @param p_item_type Workflow item type which contains the timecard approval
 * process, the default value is recommended for most scenarios.
 * @param p_approval_prc Workflow process name that corresponds to the timecard
 * approval process, the default value is recommended for most scenarios.
 * @param p_process_terminated_employees Flag that can be used to indicate
 * whether you are also trying to upload timecard for terminated employees.
 * @param p_approve_term_emps_on_submit Flag that can be used to indicate
 * whether you want to approve the timecards of terminated employees when
 * submitting.  This parameter is ignored when p_process_terminated_employees is
 * FALSE.
 * @rep:displayname Execute Deposit Process
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE execute_deposit_process (
      p_validate                       IN              BOOLEAN DEFAULT FALSE,
      p_mode                           IN              VARCHAR2,
      p_deposit_process                IN              VARCHAR2,
      p_retrieval_process              IN              VARCHAR2 DEFAULT NULL,
      -- p_add_security        IN              BOOLEAN DEFAULT TRUE,
      p_app_attributes                 IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_app_blocks                     IN OUT NOCOPY   hxc_block_table_type,
      -- hxc_self_service_time_deposit.timecard_info,
      p_messages                       OUT NOCOPY      hxc_message_table_type,
      -- hxc_self_service_time_deposit.message_table,
      p_timecard_id                    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn                   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE,
      p_template                       IN              VARCHAR2
            DEFAULT hxc_timecard.c_no,
      p_item_type                      IN              wf_items.item_type%TYPE
            DEFAULT 'HXCEMP',
      p_approval_prc                   IN              wf_process_activities.process_name%TYPE
            DEFAULT 'HXC_APPROVAL',
      p_process_terminated_employees   IN              BOOLEAN DEFAULT FALSE,
      p_approve_term_emps_on_submit    IN              BOOLEAN DEFAULT FALSE
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< execute_deposit_process >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Allow a Timecard to be deposited in the TimeStore, using the Timecard PL/SQL
 * Type Nested Table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Timecard will be deposited into the TimeStore.
 *
 * <p><b>Post Failure</b><br>
 * The Timecard will not be deposited into the TimeStore, error messages will
 * be logged in the message table out parameter.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_mode Mode must be set to 'SUBMIT', 'SAVE', 'MIGRATION',
 * 'FORCE_SAVE' or 'FORCE_SUBMIT'.
 * @param p_deposit_process Process to be used for deposit.
 * @param p_retrieval_process Process to be used for retrieval, only use if
 * mode = 'MIGRATION'.
 * @param p_app_attributes Attributes to deposit.
 * @param p_app_blocks Time Building Blocks to deposit.
 * @param p_messages Contains all the messages raised during the execution of
 * this procedure.
 * @param p_timecard_id Uniquely identifies the created Timecard.
 * @param p_timecard_ovn Set to the object version number of the created
 * Timecard.
 * @param p_template Set to 'Y' if creating a template, else set to 'N'
 * (default).
 * @param p_item_type Workflow item type which contains the timecard approval
 * process, the default value is recommended for most scenarios.
 * @param p_approval_prc Workflow process name that corresponds to the timecard
 * approval process, the default value is recommended for most scenarios.
 * @param p_process_terminated_employees Flag that can be used to indicate
 * whether you are also trying to upload timecard for terminated employees.
 * @param p_approve_term_emps_on_submit Flag that can be used to indicate
 * whether you want to approve the timecards of terminated employees when
 * submitting.  This parameter is ignored when p_process_terminated_employees is
 * FALSE.
 * @rep:displayname Execute Deposit Process
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE execute_deposit_process (
      p_validate                       IN              BOOLEAN DEFAULT FALSE,
      p_mode                           IN              VARCHAR2,
      p_deposit_process                IN              VARCHAR2,
      p_retrieval_process              IN              VARCHAR2 DEFAULT NULL,
      -- p_add_security        IN              BOOLEAN DEFAULT TRUE,
      p_app_attributes                 IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_app_blocks                     IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_messages                       OUT NOCOPY      hxc_self_service_time_deposit.message_table,
      p_timecard_id                    OUT NOCOPY      hxc_time_building_blocks.time_building_block_id%TYPE,
      p_timecard_ovn                   OUT NOCOPY      hxc_time_building_blocks.object_version_number%TYPE,
      p_template                       IN              VARCHAR2
            DEFAULT hxc_timecard.c_no,
      p_item_type                      IN              wf_items.item_type%TYPE
            DEFAULT 'HXCEMP',
      p_approval_prc                   IN              wf_process_activities.process_name%TYPE
            DEFAULT 'HXC_APPROVAL',
      p_process_terminated_employees   IN              BOOLEAN DEFAULT FALSE,
      p_approve_term_emps_on_submit    IN              BOOLEAN DEFAULT FALSE
   );

--
-- ----------------------------------------------------------------------------
-- |------------------------< clear_building_block_table >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Clears the Time Building Block SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be cleared.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Nested Table is cleared.
 *
 * <p><b>Post Failure</b><br>
 * The Nested Table is not cleared.
 *
 * @param p_app_blocks Timecard SQL Type Nested Table to be cleared.
 * @rep:displayname Clear Time Building Block Table
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE clear_building_block_table (
      p_app_blocks   IN OUT NOCOPY   hxc_block_table_type
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< clear_attribute_table >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Clears a Time Attribute PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be cleared.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Nested Table is cleared.
 *
 * <p><b>Post Failure</b><br>
 * The Nested Table is not cleared.
 *
 * @param p_app_attributes Time Atrribute PL/SQL Table to be cleared.
 * @rep:displayname Clear Time Attribute Table
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE clear_attribute_table (
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< clear_message_table >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Clears a Message PL/SQL Type Nested Table.
 *
 * Note that this procedure does not manipulate any of the database table
 * contents. Only the PL/SQL nested table parameters passed into this procedure
 * will be cleared.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Nested Table is cleared.
 *
 * <p><b>Post Failure</b><br>
 * The Nested Table is not cleared.
 *
 * @param p_messages Message PL/SQL Table to be cleared.
 * @rep:displayname Clear Message Table
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE clear_message_table (
      p_messages   IN OUT NOCOPY   hxc_message_table_type
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< log_timecard >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * A debug helper procedure for logging a Timecard SQL Type Nested Table.
 *
 * Use this procedure when you need to verify the content of the Timecard SQL
 * Type Nested Table and the corresponding Timecard Attributes.When you use
 * this procedure it will write the content of the passed in Timecard and
 * Attributes into the fnd_log_messages table.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Timecard will be logged.
 *
 * <p><b>Post Failure</b><br>
 * The Timecard will not be logged.
 *
 * @param p_app_blocks Timecard SQL Type Nested Table to log.
 * @param p_app_attributes Corresponding Time Attributes to log.
 * @rep:displayname Log Timecard
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_block_table_type,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< log_timecard >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * A debug helper procedure for logging a Timecard PL/SQL Type Nested Table.
 *
 * Use this procedure when you need to verify the content of the Timecard
 * PL/SQL Type Nested Table and the corresponding Timecard Attributes.When you
 * use this procedure it will write the content of the passed in Timecard and
 * Attributes into the fnd_log_messages table.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Timecard will be logged.
 *
 * <p><b>Post Failure</b><br>
 * The Timecard will not be logged.
 *
 * @param p_app_blocks Timecard PL/SQL Type Nested Table to log.
 * @param p_app_attributes Corresponding Time Attributes to log.
 * @rep:displayname Log Timecard
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE log_timecard (
      p_app_blocks       IN   hxc_self_service_time_deposit.timecard_info,
      p_app_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< log_messages >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * A debug helper procedure for logging a Message SQL Type Nested Table.
 *
 * Use this procedure when you need to verify the content of the Message SQL
 * Type Nested Table. When you use this procedure it will write the content of
 * the passed in Message SQL Type Nested Table into the fnd_log_messages table.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Messages will be logged.
 *
 * <p><b>Post Failure</b><br>
 * The Messages will not be logged.
 *
 * @param p_messages Message SQL Type Nested Table to log.
 * @rep:displayname Log Messages
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE log_messages (p_messages IN hxc_message_table_type);

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< log_messages >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * A debug helper procedure for logging a Message PL/SQL Type Nested Table.
 *
 * Use this procedure when you need to verify the content of the Message PL/SQL
 * Type Nested Table. When you use this procedure it will write the content of
 * the passed in Message PL/SQL Type Nested Table into the fnd_log_messages
 * table.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The Messages will be logged.
 *
 * <p><b>Post Failure</b><br>
 * The Messages will not be logged.
 *
 * @param p_messages Message PL/SQL Type Nested Table to log.
 * @rep:displayname Log Messages
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:metalink 223987.1 OTL HXC TimeStore Deposit
*/
--
-- {End Of Comments}
--
   PROCEDURE log_messages (
      p_messages   IN   hxc_self_service_time_deposit.message_table
   );
END hxc_timestore_deposit;

/
