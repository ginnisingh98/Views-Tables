--------------------------------------------------------
--  DDL for Package EAM_METERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METERS_UTIL" AUTHID CURRENT_USER AS
/* $Header: EAMETERS.pls 120.1 2005/06/20 05:43:21 appldev ship $ */

 /**
  * This procedure updates LTD readings for disabled change meter readings
  */
  procedure update_change_meter_ltd(p_meter_id in number,
                                    p_meter_reading_id in number);

 /**
   * This function is used to calcuate the meter usage rate. The algorithm it
   * uses put equal weight on each individual meter reading.
   */
  function get_meter_usage_rate(p_meter_id in number,
                                p_user_defined_rate in number,
                                p_use_past_reading in number)
                             return number;
  /**
  This function provides another signature for get_usage_rate function.
  */
  function get_meter_usage_rate(p_meter_id in number
                                  )
                             return number;

  /**
   * This function is used to tell whether there is any mandatory meter reading
   * or not for completing the given work order.
   */
  function has_mandatory_meter_reading(p_wip_entity_id in number)
                                                   return boolean;


  /**
   * This function is used to determine whether the meter reading is mandatory
   * for the given wo or not. It should be called in the meter reading form when
   * referenced by the completion page.
   */
  function is_meter_reading_mandatory(p_wip_entity_id  in number,
                                      p_meter_id in number)
                             return boolean;

  /**
   * This function is used to determine whether the meter reading is mandatory
   * for the given wo or not. It should be called in the meter reading form when
   * referenced by the completion page.
   */
  function is_meter_reading_mandatory_v(p_wip_entity_id  in number,
                                      p_meter_id in number)
                             return varchar2;

  /**
   * This procedure determines if the Last Service Reading of the meter for
   * the asset activity association is mandatory by checking if the meter
   * is used in any of the PM defined for the association. If it is required,
   * then the function returns true, otherwise false.
   */
  function is_meter_reading_required(p_activity_assoc_id in number,
  	         	      	      p_meter_id in number)
				    return boolean;
   /**
   * This procedure determines if the Last Service Reading of the meter for
   * the asset activity association is mandatory by checking if the meter
   * is used in any of the PM defined for the association. If it is required,
   * then the function returns 'Y', otherwise 'N'.
   */
  function is_meter_reading_required_v(p_activity_assoc_id in number,
  	         	      	      p_meter_id in number)
 				    return varchar2;

  /**
   * This procedure updates the last service reading of the meter for the
   * asset activity association. It also recursively updates the meter readings
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_reading(p_wip_entity_id in number,
				p_activity_assoc_id in number,
                                 p_meter_id in number,
                                 p_meter_reading in number);

 /**
   * This procedure updates the last service reading of the meter for the
   * asset activity association. It also recursively updates the meter readings
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_reading_wo(p_wip_entity_id in number,
                                           p_meter_id in number,
                                           p_meter_reading in number,
					   p_wo_end_date in date,
                                           x_return_status		OUT NOCOPY	VARCHAR2,
                                           x_msg_count			OUT NOCOPY	NUMBER,
                                    	   x_msg_data			OUT NOCOPY	VARCHAR2);

  /**
   * This procedure is a wrapper over update_last_service_dates
   * This is getting called from
   * EAMPLNWB.fmb -> MASS_COMPLETE block -> Work_Order_Completion
   * procedure. Do not call this from other locations
   */
  procedure updt_last_srvc_dates_wo_wpr (p_wip_entity_id in number,
                                         p_start_date in date,
                                         p_end_date in date,
                                         x_return_status		OUT NOCOPY	VARCHAR2,
                                         x_msg_count			OUT NOCOPY	NUMBER,
                                    	 x_msg_data			OUT NOCOPY	VARCHAR2) ;

  /**
   * This procedure updates the last service start/end date for the
   * asset activity association. It also recursively updates dates
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_dates( p_wip_entity_id in number,
                                       p_activity_assoc_id in number,
                                       p_start_date in date,
                                       p_end_date in date);

  /**
   * This procedure updates the last service start/end date for the
   * asset activity association. It also recursively updates dates
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_dates_wo(p_wip_entity_id in number,
                                       p_start_date in date,
                                       p_end_date in date,
                                       x_return_status		OUT NOCOPY	VARCHAR2,
                                       x_msg_count			OUT NOCOPY	NUMBER,
                                   	   x_msg_data			OUT NOCOPY	VARCHAR2);


  /**
   * This procedure should be called when resetting a meter. It updates the corresponding
   * PM schedule rule data if applicable.
   */
  procedure reset_meter(p_meter_id        in number,
                        p_current_reading in number,
                        p_last_reading    in number,
                        p_change_val      in number);

/**
   * This procedure calculates the average of the meter readings for the meter
   */
  procedure get_average(p_meter_id   in number,
			p_from_date in date,
			p_to_date in date,
			x_average OUT NOCOPY number );


  /**
    * This function checks if the user can enter a reading for the specified date.
    * It checks if the reading date falls in between a normal reading and a reset reading
    */
    function cannot_enter_value(p_meter_id        in number,
                                p_reading_date      in date
                            )return boolean;

    /**
    * This function checks if the user is trying to update a reset reading
    */
    function cannot_update_reset(p_meter_id        in number,
                                p_reading_date      in date
                        )return boolean;

   /**
    * This function checks if a particular reading is a reset reading
    */
    function reset_reading_exists(p_meter_id        in number,
                                    p_reading_date      in date
                        )return boolean;

    /* this function checks if a particular reading is a normal (non-reset)
       reading that is right prior to a reset reading */
/*
    function normal_reading_before_reset ( p_meter_reading_id in number)
        return boolean;
*/

/* following function checks if there exists and readings after the
   specific reading date */
    function next_reading_exists (p_meter_id in number,
				  p_reading_date in date)
	return boolean;

/* following function determines whether a non-disabled reading
   exists on p_reading_date for meter p_meter_id
*/
    function reading_exists(p_meter_id in number,
			    p_reading_date in date)
	return boolean;

/* This function determines whether a new meter reading would
violate the ascending or descending order of the meter.
If there is violation, "true" is returned; otherwise, "false" is
returned. */

    function violate_order(p_meter_id in number,
			   p_reading_date in date,
			   p_current_reading in number)
 	return boolean;

/* This function calculates the life_to_date reading for a new reading. */
    function calculate_ltd(p_meter_id in number,
			   p_reading_date in date,
			   p_new_reading in number,
               p_meter_type in number)
	return number;


/* This function verifies that the meter reading meets the follow criteria:
 1. meter reading is not a reading between a normal reading and a reset reading
 2. meter reading is not a reset reading with normal readings after it.
*/
   function can_be_disabled(p_meter_id number,
			    p_meter_reading_id number,
                            x_reason_cannot_disable out nocopy number)
        return boolean;


  /**
   * This is a private function to resursively iterate through the suppression tree
   * to see whether any one of them needs meter reading.
   */
  function pm_need_meter_reading(p_parent_pm_id in number)
                             return boolean;

 /**
   * This is a private helper function that retrieves the activity association id
   * given the wip entity id.
   */
  function get_activity_assoc_id(p_wip_entity_id number)
                             return number;

  /**
   * This is a private function. It resursively iterate through the suppression tree
   * to see whether the meter is used in the sub tree of the given node.
   */
  function mr_mandatory_for_pm(p_activity_assoc_id    in number,
                               p_meter_id in number) return boolean;

   PROCEDURE VALIDATE_USED_IN_SCHEDULING(p_meter_id    IN    NUMBER,
                                       x_return_status		OUT NOCOPY	VARCHAR2,
                                       x_msg_count			OUT NOCOPY	NUMBER,
                                   	x_msg_data			OUT NOCOPY	VARCHAR2);



END eam_meters_util;



 

/
