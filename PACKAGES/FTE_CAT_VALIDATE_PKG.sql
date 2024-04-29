--------------------------------------------------------
--  DDL for Package FTE_CAT_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_CAT_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: FTECATVS.pls 115.5 2002/11/21 00:22:32 hbhagava noship $ */

--
-- Package
--        FTE_CAT_VALIDATE_PKG
--
--
-- Purpose
--   This package does the following:
--    1. Validate a stop location belongs to origin/destination region
--       of a lane/schedule
--    2. Validate stop times (departure and arrival dates )
--       against lane/schedule

--    3. Validate Service type of a Lane
--
      G_PACKAGE_NAME             CONSTANT        VARCHAR2(50) := 'FTE_CAT_VALIDATE_PKG';

   --
   -- Declaring Constant Variables
   -- 1 - Departure Date is Match with Departure Date - G_MATCH_WITH_DEP_DATE
   -- 2 - Departure Date is Match with Arrival Date  - G_MATCH_WITH_ARR_DATE
   -- 3 - Departure Date is between Departure and Arrival Dates - G_BETWEEN_DATES

   -- 4 - Departure Date is Outside the Range ( before ). -G_BEFORE_DEP_DATE

   -- 5 - Departure Date is Outside the Range ( after). - G_AFTER_ARRIVAL_DATE
   --

      G_MATCH_WITH_DEP_DATE      CONSTANT        NUMBER := 1 ;
      G_MATCH_WITH_ARR_DATE      CONSTANT        NUMBER := 2 ;
      G_BETWEEN_DATES            CONSTANT        NUMBER := 3 ;
      G_BEFORE_DEP_DATE          CONSTANT        NUMBER := 4 ;
      G_AFTER_ARRIVAL_DATE       CONSTANT        NUMBER := 5 ;

   -- Procedure Name
   --
   --   PROCEDURE Validate_Loc_To_Region
   --

   -- Purpose
   --  Validate a stop location belongs to origin/destination region
   --  of a lane/schedule
   --
   -- IN Parameters
   --    1. Lane Id
   --    2. Location Id
   --    3. Search Criteria
   --       Valid Values are 'O'-Origin, 'D'-Destination, and 'A'-Any One
   --       This input criteria will be used to validate only those region
   -- Out Parameters
   --    1. x_valid_flag :returns "Y" or "N"
   --      Y-means entered location is valid, otherwise "N"


   PROCEDURE Validate_Loc_To_Region(
      p_lane_id		    IN  NUMBER,
      p_location_id	    IN  NUMBER,
      p_search_criteria     IN  VARCHAR2 default 'A',
      p_init_msg_list        IN  VARCHAR2 default fnd_api.g_false,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_valid_flag          OUT NOCOPY VARCHAR2
   );

   -- Procdure Name
   --
   --   PROCEDURE Validate_Schedule_Date

   --
   -- Purpose
   --  Validate stop times (departure and arrival dates )
   --  against lane/schedule
   --
   -- IN Parameters
   --    1. Lane Id
   --    2. Schedule Id
   --    3. Departure Date
   --    4. Arrival Date
   -- Out Parameters
   --    1. x_dep_match_flag : returns the following Values
   --       MD - Departure Date is Match with Departure Date - MATCH_WITH_DEP_DATE

   --       MA - Departure Date is Match with Arrival Date  - MATCH_WITH_ARR_DATE

   --       BW - Departure Date is between Departure and Arrival Dates - BETWEEN_DATES

   --       BD - Departure Date is Outside the Range ( before ). -BEFORE_DEP_DATE

   --       AA - Departure Date is Outside the Range ( after). - AFTER_ARRIVAL_DATE


   --    2. x_arr_match_flag : returns the following Values
   --       D - Arrival Date is Match with Departure Date
   --       A - Arrival Date is Match with Arrival Date
   --       W - Arrival Date is between Departure and Arrival Dates
   --       B - Arrival Date is Outside the Range ( before ).
   --       O - Arrival Date is Outside the Range ( after ).

   PROCEDURE Validate_Schedule_Date(
      p_lane_id		    IN  NUMBER,
      p_schedule_id	    IN  NUMBER,
      p_departure_date      IN  DATE,
      p_arrival_date        IN  DATE,

      p_init_msg_list        IN  VARCHAR2 default fnd_api.g_false,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_dep_match_flag      OUT NOCOPY NUMBER,
      x_arr_match_flag      OUT NOCOPY NUMBER
   );

   -- Procdure Name
   --
   --   PROCEDURE Validate_Service_Type
   --
   -- Purpose
   --  Validate Service type of a Lane
   --

   -- IN Parameters
   --    1. Lane Id
   --    2. Service Type
   -- Out Parameters
   --    1. x_valid_flag :returns "Y" or "N"
   --      Y-means entered service type is valid, otherwise "N"

   PROCEDURE Validate_Service_Type(
      p_lane_id		    IN  NUMBER,
      p_service_type        IN  VARCHAR2,
      p_init_msg_list        IN  VARCHAR2 default fnd_api.g_false,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_valid_flag          OUT NOCOPY VARCHAR2

   );

END FTE_CAT_VALIDATE_PKG;

 

/
