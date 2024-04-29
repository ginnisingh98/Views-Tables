--------------------------------------------------------
--  DDL for Package OTA_EVT_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVT_BUS2" AUTHID CURRENT_USER as
/* $Header: otevt02t.pkh 120.1 2007/11/21 13:42:02 shwnayak noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Lock_Event >----------------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description: Locks the Event
Procedure Lock_Event (p_event_id in number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get Total Places >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Get total number of placed delegates.
--
--
Function Get_Total_Places(p_all_or_internal in varchar2
			 ,p_event_id in number) return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Check Places >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Checks the Maximum_Attendees and Maximum_Internal_Attendees
--		when updated.
--
--
Procedure Check_Places(p_event_id in number
		      ,p_maximum_attendees in number
		      ,p_maximum_internal_attendees in number);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< Reset_Event_Status >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Reset Event Status
--
--              Resets the Event Status for the event record if event is reached
--		to full.
--
Procedure Reset_Event_Status(p_event_id in number
			    ,p_object_version_number in out nocopy number
			    ,p_event_status in varchar2
			    ,p_maximum_attendees in number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Resource Bookings Exists >--------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description: Checks whether Resource bookings exists for a particular event.
--
--
Function Resource_Booking_Exists (p_event_id in number) return boolean;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Finance Line Exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Checks whether a finance line exists for a particular booking_Id.
--
--
Function Finance_Line_Exists (p_booking_id in number
			     ,p_cancelled_flag in varchar2) return boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get Vacancies >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Get Vacancies
--
--              Get current vacancies for a particular event.
--
Function Get_Vacancies(p_event_id in number) return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Wait List Required >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check if Wait List window is required.
--
--              Returns Boolean
--
Function Wait_List_Required     (p_event_type in varchar2
				,p_event_id in number
				,p_event_status in varchar2
				,p_booking_status_type_id in number default null)
Return Boolean;
--
----------------------------------------------------------------------------
-- |--------------------------< Check Mandatory Association for event >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check if mandatory enrollments exist for the event
--

procedure Check_Mandatory_Associations(p_event_id in number
		      ,p_maximum_attendees in number
		      ,p_maximum_internal_attendees in number);


-- --------------------------------------------------------------------------------------------
-- |--------------------------< Check if Mandatory Asociation exists for a particular event >--------------------------------|
-- ------------------------------------------------------------------------------------------
--
--              Returns Boolean
--
function mandatory_associations_exists(p_event_id in number)return boolean ;
--
end ota_evt_bus2;

/
