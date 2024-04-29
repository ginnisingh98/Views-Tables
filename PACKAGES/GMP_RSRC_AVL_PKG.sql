--------------------------------------------------------
--  DDL for Package GMP_RSRC_AVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_RSRC_AVL_PKG" AUTHID CURRENT_USER as
/* $Header: GMPAVLS.pls 120.1 2006/03/16 14:30:14 rpatangy noship $ */
/*#
 * This is the API for Resource Availability calculations.
 * Important inputs to the API are Calendar,Resource and the Dates
 * It returns the available hours of that Resource during the specified period
 * @rep:scope public
 * @rep:product GMP
 * @rep:displayname Resource Availability Calculations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMP_RSRC_AVL_PKG
*/
gmp_setup               BOOLEAN:=FALSE;
gmp_api_version         NUMBER;
gmp_user_id             NUMBER;
gmp_user_name           VARCHAR2(50);
gmp_login_id            NUMBER;
gmp_timestamp           DATE;


TYPE out_cal_shift_typ is RECORD
( out_resource_count number,
  out_cal_date date,
  out_shift_num number,
  out_cal_from_date date,
  out_cal_to_date date
);

out_calendar_record  out_cal_shift_typ;
TYPE cal_tab2 is table of out_cal_shift_typ index by BINARY_INTEGER;
out_cal_rec  cal_tab2;
out_rec  cal_tab2;
--
/*#
 *  Returns the available hours of that Resource during the specified
 *  period after netting out un-availability from calendar. Important inputs
 *  include Calendar, Resource, and the Dates.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_cal_code This is the calendar code, that is associated with a
 *         OPM Organization or Resource
 *  @param p_resource_id This is the Id of the Resource, that is associated
 *         with a OPM Plant
 *  @param p_from_date This is the start date of the period for which
 *  availability is to be computed
 *  @param p_to_date This is the end date of the period
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @param x_msg_count Number of messages on message stack
 *  @param x_msg_data Actual message data from message stack
 *  @param x_return_code Error code returned from the API
 *  @param p_rec This is the availability information stored in PL/SQL table
 *           of records which contains resource count, Calendar Date,
 *           Shift Number, available start date-time and end date-time
 *  @param p_flag This is indicator flag denoting invalid input parameter
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname Resource Availability Calculations
*/

PROCEDURE rsrc_avl(
                    p_api_version        IN NUMBER,
                    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
                    p_cal_code           IN VARCHAR2,   -- B4999940
                    p_resource_id        IN NUMBER,
                    p_from_date          IN DATE,
                    p_to_date            IN DATE,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2,
                    x_return_code        OUT NOCOPY VARCHAR2,
                    p_rec                IN OUT NOCOPY cal_tab2,
                    p_flag               IN OUT NOCOPY VARCHAR2
                    ) ;

-- Overriden procedure, cal_id not mentioned
/*#
 *  Returns the available hours of that Resource during the specified
 *  period after netting out un-availability from calendar. Important inputs
 *  include Calendar, Resource, and the Dates.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_resource_id This is the Id of the Resource, that is associated
 *         with a OPM Plant
 *  @param p_from_date This is the start date of the period for which
 *  availability is to be computed
 *  @param p_to_date This is the end date of the period
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @param x_msg_count Number of messages on message stack
 *  @param x_msg_data Actual message data from message stack
 *  @param x_return_code Error code returned from the API
 *  @param p_rec This is the availability information stored in PL/SQL table
 *           of records which contains resource count, Calendar Date,
 *           Shift Number, available start date-time and end date-time
 *  @param p_flag This is indicator flag denoting invalid input parameter
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname Resource Availability Calculations
*/
PROCEDURE rsrc_avl(
                    p_api_version        IN NUMBER,
                    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
                    p_resource_id        IN NUMBER,
                    p_from_date          IN DATE,
                    p_to_date            IN DATE,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2,
                    x_return_code        OUT NOCOPY VARCHAR2,
                    p_rec                IN OUT NOCOPY cal_tab2,
                    p_flag               IN OUT NOCOPY VARCHAR2
                    );

END gmp_rsrc_avl_pkg;

 

/
