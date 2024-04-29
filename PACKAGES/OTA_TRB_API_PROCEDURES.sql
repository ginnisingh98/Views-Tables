--------------------------------------------------------
--  DDL for Package OTA_TRB_API_PROCEDURES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRB_API_PROCEDURES" AUTHID CURRENT_USER as
/* $Header: ottrb02t.pkh 120.5.12000000.3 2007/07/05 09:09:07 aabalakr noship $ */
--
-- The business rules......
--
--
--
-- takes into account even PLANNED bookings while checking conflicts
function check_booking_conflict(p_supplied_resource_id in number
                             ,p_required_date_from in Date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in Date
                             ,p_required_end_time in varchar2
			     ,p_timezone in varchar2
                             ,p_resource_booking_id in number default null
			     ,p_book_entire_period_flag in varchar2 default 'Y'
                             )return varchar2  ;

function is_booking_conflict(p_supplied_resource_id in number
                             ,p_required_date_from in Date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in Date
                             ,p_required_end_time in varchar2
			     ,p_timezone in varchar2
                             ,p_target_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2 default 'Y'
                             )return varchar2  ;

function check_ss_double_booking(p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2) return varchar2;

-- ---------------------------------------------------------------------
-- |----------------------------< check_obj_booking_dates >---------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Required dates must be within boudaries of suppliable
--              resource validity dates.
--
procedure check_obj_booking_dates(p_supplied_resource_id in number,
			  p_req_from in date,
                          p_req_to in date,
                          p_event_id in number,
                          p_chat_id in number,
                          p_forum_id in number,
			  p_timezone_code in varchar2,
			  p_req_time_from in varchar2,
		          p_req_time_to in varchar2,
				  p_warning out nocopy varchar2);
-- --------------------------------------------------------------------
-- |------------------< check_resource_type >--------------------------
-- ----------------------------------------------------------------aru_LM Class1----
-- PRIVATE
-- Description: This function returns a TRUE if the resource type is a
--              venue based upon the given supplied_resource_id. This is
--              only for use by procedures in this package.
--
function check_resource_type(p_supplied_resource_id in number,
			     p_type in varchar2)
return boolean;
--
-- ---------------------------------------------------------------------
-- |-------------------< check_role_to_play >---------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The role_to_play field must be in the domain
--              Trainer Participation.
--
procedure check_role_to_play(p_role_to_play in varchar2);
--
-- ---------------------------------------------------------------------
-- |------------------< check_role_res_type_excl >----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description:
--
procedure check_role_res_type_excl(p_supplied_resource_id in number,
				   p_role_to_play in varchar2);
--
-- ---------------------------------------------------------------------
-- |------------------------< get_total_cost >--------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: get the total cost of all resources required for the
--              event.
--
procedure get_total_cost(p_event_id in number,
			 p_total_cost in out nocopy number);
--
-- ---------------------------------------------------------------------
-- |--------------------< check_quantity_entered >----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The quantity field can only be entered if the resource
--              type is not VENUE.
--
procedure check_quantity_entered(p_supplied_resource_id in number,
				 p_quantity in number);
--
-- ---------------------------------------------------------------------
-- |-------------------< check_delivery_address >-----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Delivery address cannot be entered if resource type is
--              VENUE or TRAINER.
--
procedure check_delivery_address(p_supplied_resource_id in number,
				 p_del_add in varchar2);
--
-- ---------------------------------------------------------------------
-- |------------------------< get_resource_booking_id >-----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Return the RESOURCE BOOKING ID when supplied with only
--              the SUPPLIED RESOURCE ID and EVENT ID.
--
function get_resource_booking_id(p_supplied_resource_id in number,
				 p_event_id in number)
return number;
--
-- ---------------------------------------------------------------------
-- |-----------------------< resource_booked_for_event >----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Return a TRUE if any resource bookings have been made
--              for the specified event. Otherwise return a FALSE.
--
function resource_booked_for_event(p_event_id in number)
return boolean;
--
-- ---------------------------------------------------------------------
-- |----------------------------< check_dates_tsr >---------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Required dates must be within boudaries of suppliable
--              resource validity dates.
--
procedure check_dates_tsr(p_supplied_resource_id in number,
			  p_req_from in date,
                          p_req_to in date,
                          p_req_start_time in varchar2,
                          p_req_end_time in varchar2,
						  p_timezone_code in varchar2);
--
-- ---------------------------------------------------------------------
-- |-------------------------< check_evt_tsr_bus_grp >------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The events business group id must be the same as that of
--              the suppliable resource.
--
-- NB: This business rule may well disappear in the future as the
--     structure of organizations for OTA may change with the
--     addition of a VENDORS table. Suppliable Resources table may
--     well then contain a business_group_id column anyway.
--     KLS 24/11/94.
--
procedure check_evt_tsr_bus_grp(p_event_id in number,
				p_supplied_resource_id in number);
--
-- ---------------------------------------------------------------------
-- |---------------------------< check_from_to_dates >------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: required date from must be less than or equal to the
--              required date to.
--
procedure check_from_to_dates(p_req_from in date,
			      p_req_to in date);
--
-- ---------------------------------------------------------------------
-- |----------------------------< check_update_tra >--------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Update of required dates must not invalidate any
--              resource allocations.
--
procedure check_update_tra(p_resource_booking_id in number,
			   p_req_date_from in date,
			   p_req_date_to in date);
--
-- ---------------------------------------------------------------------
-- |------------------------< check_tra_trainer_exists >----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: A resource booking may not be deleted if a row exists
--              in OTA_RESOURCE_ALLOCATIONS with this resource booking
--              id.
--
procedure check_tra_trainer_exists(p_resource_booking_id in number);
--
-- ---------------------------------------------------------------------
-- |--------------------< check_tra_resource_exists >-------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: A resource booking may not be deleted if in use as a
--              EQUIPMENT_RESOURCE_BOOKING_ID in
--              OTA_RESOURCE_ALLOCATIONS.
--
procedure check_tra_resource_exists(p_resource_booking_id in number);
--
-- ---------------------------------------------------------------------
-- |------------------------< check_status >----------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The user status must be in the domain RESOURCE BOOKING
--              STATUS.
--
procedure check_status(p_status in varchar2);
--
-- ---------------------------------------------------------------------
-- |-----------------------< check_status_value >-----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: If status is confirmed then check that its valid to have
--              confirmed resource bookings against this event.
--
procedure check_status_value;
--
-- ---------------------------------------------------------------------
-- |---------------------< check_primary_venue >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Only one venue resource booking may be a primary venue.
--
procedure check_primary_venue(p_event_id in number,
                              p_resource_booking_id in number,
			      p_prim_ven in varchar2,
                              p_req_from in date,
                              p_req_to in date);
--
-- ---------------------------------------------------------------------
-- |--------------------< check_double_booking >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Function returning TRUE is another CONFIRMED booking for the
--              resource is found
--
function check_double_booking(p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2
			     ,p_last_res_bkng_id in number default null) return boolean;
--
-- ---------------------------------------------------------------------
-- |---------------------< check_if_tfl_exists >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: If finance lines exist for the booking it may not be
--              deleted.
--
procedure check_if_tfl_exists(p_resource_booking_id in number);
--
-- -------------------------------------------------------------------
-- |-------------------< check_event_type >---------------------------
-- -------------------------------------------------------------------
-- PUBLIC
-- Description: Resource bookings may be made for the following event
--              types: SCEDULED, SESSION, PROGRAMME MEMBER, DEVELOPMENT
--
procedure check_event_type(p_event_id in number);
--
-- -------------------------------------------------------------------
-- |-------------------< check_update_quant_del >---------------------
-- -------------------------------------------------------------------
-- PUBLIC
-- Description: If the Quantity or Delegates_per_unit fields are upated
--              then a check needs to made to ensure that their sum is
--              not exceeded by the number of resource allocations made
--              to the booking.
--
--               returns TRUE if no. of allocations is ok or the
--               calculation cannot be performed due to one of the
--               variables being null. Returns FALSE if no. of
--               allocations not ok.
--
function check_update_quant_del(p_resource_booking_id in number,
				p_quantity in number,
				p_del_per_unit in number)
return boolean;
--
-- ------------------------------------------------------------------
-- |---------------------< get_required_resources>------------------
---------------------------------------------------------------------
-- Description: Get the mandatory resources defined for an activity

 Procedure get_required_resources(p_activity_version_id in number,
				  p_event_id in number,
       		        	  p_date_booking_placed in date,
				  p_event_start_date in date,
				  p_event_end_date in date );
--
-- -------------------------------------------------------------------
-- |----------------------< get_evt_defaults >------------------------
-- -------------------------------------------------------------------
-- PUBLIC
procedure get_evt_defaults(p_event_id in number,
			   p_event_title in out nocopy varchar2,
                           p_event_start_date in out nocopy date,
                           p_event_end_date in out nocopy date,
                           p_event_start_time in out nocopy varchar2,
                           p_event_end_time in out nocopy varchar2,
                           p_curr_code in out nocopy varchar2,
                           p_curr_meaning in out nocopy varchar2);
--
-- ---------------------------------------------------------------------
-- -------------------< check_trainer_venue_book >----------------------
-- ---------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check that Trainers and Venues cannot be double booked
--              if Confirmed
--
--
procedure check_trainer_venue_book
                             (p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2
			    );
--
-- ---------------------------------------------------------------------
-- |---------------------< check_start_end_times >----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Start time must be before end time.
--
procedure check_start_end_times(p_start_time in varchar2,
                                p_end_time in varchar2);
--
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- |--------------------< check_trainer_competence >--------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Check trainer competence match the activity.
--
procedure check_trainer_competence (p_event_id in number,
                                    p_supplied_resource_id in number,
				    p_required_date_from IN DATE,
				    p_required_date_to   IN DATE,
				    p_end_of_time	 IN DATE,
			            p_warn   out nocopy boolean) ;

end ota_trb_api_procedures;

 

/
