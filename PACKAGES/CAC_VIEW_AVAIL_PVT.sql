--------------------------------------------------------
--  DDL for Package CAC_VIEW_AVAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_AVAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvavs.pls 120.1 2005/07/02 02:19:58 appldev noship $ */
/*#
 * This package provides APIs to check resource availability.
 * The use of this package is restricted to ATG Calendar Application Development.
 * This is a replica of JTF_CAL_AVLBLTY_PVT.
 * The new functions are added to check free_busy_type and perform with task_id.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Calendar View Availability
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/******************************************************************************
** Record to store Resource Information. (Input)
******************************************************************************/
TYPE RSRec IS RECORD
( resourceID       NUMBER
, resourceType     VARCHAR2(30) -- 'RS_EMPLOYEE' or 'RS_GROUP' for now
, resourceName     VARCHAR2(360)-- Resource Name
);

/******************************************************************************
** Table to store the list of resources (Input)
******************************************************************************/
TYPE RSTab IS TABLE OF RSRec INDEX BY BINARY_INTEGER;

/******************************************************************************
** Record to store availability slots of a resource
******************************************************************************/
TYPE AvlblRc IS RECORD
( ResourceID      NUMBER
, ResourceType    VARCHAR2(30) -- 'RS_EMPLOYEE' or 'RS_GROUP' for now
, ResourceName    VARCHAR2(360)-- 'Resource name'
, SlotSequence    NUMBER       -- 1=first slot, 2=second slot etc
, SlotAvailable   NUMBER       -- 1=Yes 0=No
);

/******************************************************************************
** Table to store availability of all resources
******************************************************************************/
TYPE AvlblTb IS TABLE OF AvlblRc INDEX BY BINARY_INTEGER;

/**
 * This procedure checks the availability for all the resources given by P_RSList.
 * This doesn't support free_busy_type and a function to check the availability.
 * for all the resources assigned to task_id.
 * @param p_api_version API version number
 * @param p_init_msg_list a flag to indicate if message list is initialized
 * @param x_return_status return status
 * @param x_msg_count the number of message
 * @param x_msg_data message data
 * @param p_RSList A list of resource
 * @param p_StartDateTime Start datetime of the period to check the availability
 * @param p_EndDateTime End datetime of the period to check the availability
 * @param p_SlotSize The slot size in minute
 * @param x_NumberOfSlots The number of slots
 * @param x_AvailbltyList List of resources and their availability
 * @param x_TotalAvailbltyList Total availability List
 * @rep:displayname Availability
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE availability
( p_api_version         IN     NUMBER
, p_init_msg_list       IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status       OUT    NOCOPY   VARCHAR2
, x_msg_count           OUT    NOCOPY   NUMBER
, x_msg_data            OUT    NOCOPY   VARCHAR2
, p_RSList              IN     RSTab
, p_StartDateTime       IN     DATE          -- Start DateTime of the period to check
, p_EndDateTime         IN     DATE          -- End DateTime of the period to check
, p_SlotSize            IN     NUMBER        -- The slot size in minutes
, x_NumberOfSlots       OUT    NOCOPY   NUMBER
, x_AvailbltyList       OUT    NOCOPY   AvlblTb  -- list of resources and their availability
, x_TotalAvailbltyList  OUT    NOCOPY   AvlblTb  -- Total availability
);

/**
 * This procedure checks the availability for all the resources given by P_RSList.
 * This considers free_busy_type for the decision of availability.
 * @param p_api_version API version number
 * @param p_init_msg_list a flag to indicate if message list is initialized
 * @param x_return_status return status
 * @param x_msg_count the number of message
 * @param x_msg_data message data
 * @param p_RSList A list of resource
 * @param p_StartDateTime Start datetime of the period to check the availability
 * @param p_EndDateTime End datetime of the period to check the availability
 * @param p_SlotSize The slot size in minute
 * @param x_NumberOfSlots The number of slots
 * @param x_AvailbltyList List of resources and their availability
 * @param x_TotalAvailbltyList Total availability List
 * @rep:displayname Check Availability
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE CHECK_AVAILABILITY
( p_api_version         IN     NUMBER
, p_init_msg_list       IN     VARCHAR2
, p_RSList              IN     RSTab
, p_StartDateTime       IN     DATE     -- Start DateTime of the period to check
, p_EndDateTime         IN     DATE     -- End DateTime of the period to check
, p_SlotSize            IN     NUMBER   -- The slot size in minutes
, x_NumberOfSlots       OUT    NOCOPY NUMBER
, x_AvailbltyList       OUT    NOCOPY AvlblTb  -- list of resources and their availability
, x_TotalAvailbltyList  OUT    NOCOPY AvlblTb  -- Total availability
, x_return_status       OUT    NOCOPY VARCHAR2
, x_msg_count           OUT    NOCOPY NUMBER
, x_msg_data            OUT    NOCOPY VARCHAR2
);

/**
 * This procedure checks the availability for all the resources given by task_id
 * This considers free_busy_type for the decision of availability.
 * @param p_api_version API version number
 * @param p_init_msg_list a flag to indicate if message list is initialized
 * @param x_return_status return status
 * @param x_msg_count the number of message
 * @param x_msg_data message data
 * @param p_task_id Task Id
 * @param p_StartDateTime Start datetime of the period to check the availability
 * @param p_EndDateTime End datetime of the period to check the availability
 * @param p_SlotSize The slot size in minute
 * @param x_NumberOfSlots The number of slots
 * @param x_AvailbltyList List of resources and their availability
 * @param x_TotalAvailbltyList Total availability List
 * @rep:displayname Check Availability
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE CHECK_AVAILABILITY
( p_api_version         IN     NUMBER
, p_init_msg_list       IN     VARCHAR2
, p_task_id             IN     NUMBER
, p_StartDateTime       IN     DATE     -- Start DateTime of the period to check
, p_EndDateTime         IN     DATE     -- End DateTime of the period to check
, p_SlotSize            IN     NUMBER   -- The slot size in minutes
, x_NumberOfSlots       OUT    NOCOPY NUMBER
, x_AvailbltyList       OUT    NOCOPY AvlblTb  -- list of resources and their availability
, x_TotalAvailbltyList  OUT    NOCOPY AvlblTb  -- Total availability
, x_return_status       OUT    NOCOPY VARCHAR2
, x_msg_count           OUT    NOCOPY NUMBER
, x_msg_data            OUT    NOCOPY VARCHAR2
);



END CAC_VIEW_AVAIL_PVT;

 

/
