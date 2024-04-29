--------------------------------------------------------
--  DDL for Package Body FTE_CAT_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_CAT_VALIDATE_PKG" AS
/* $Header: FTECATVB.pls 115.7 2002/11/21 00:22:09 hbhagava noship $ */

--
-- Package
--        FTE_CAT_VALIDATE_PKG
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
   -- Defined Constant Variables in the specs
   -- 1 - Departure Date is Match with Departure Date - G_MATCH_WITH_DEP_DATE
   -- 2 - Departure Date is Match with Arrival Date  - G_MATCH_WITH_ARR_DATE
   -- 3 - Departure Date is between Departure and Arrival Dates - G_BETWEEN_DATES

   -- 4 - Departure Date is Outside the Range ( before ). -G_BEFORE_DEP_DATE
   -- 5 - Departure Date is Outside the Range ( after). - G_AFTER_ARRIVAL_DATE
   --
   --========================================================================
   -- Procedure Name
   --
   --   PROCEDURE Validate_Loc_To_Region
   --========================================================================
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
   --    4. p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list

   -- Out Parameters
   --   1.x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;


   --   2. x_valid_flag :returns "Y" or "N"
   --      Y-means entered location is valid, otherwise "N"

   PROCEDURE Validate_Loc_To_Region(
      p_lane_id		    IN  NUMBER,
      p_location_id	    IN  NUMBER,
      p_search_criteria     IN  VARCHAR2 default 'A',
      p_init_msg_list        IN  VARCHAR2 default fnd_api.g_false,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_valid_flag          OUT NOCOPY VARCHAR2
   ) is


cursor c_origin_exists_cursor is
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
         hz_locations hl,
         wsh_regions wrb
    where fl.origin_id = wr.region_id
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.state,wrb.state_code)
union
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
	 hr_locations_all hl, hr_locations_all_tl hlt,
         wsh_regions wrb
    where fl.origin_id = wr.region_id
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.town_or_city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.region_2,wrb.state_code)
    and nvl (hl.business_group_id,nvl(hr_general.get_business_group_id, -99) )
             = nvl (hr_general.get_business_group_id, -99)
    and hl.location_id = hlt.location_id and hlt.language = userenv('LANG')
;



cursor c_dest_exists_cursor is
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
         hz_locations hl,
         wsh_regions wrb
    where fl.destination_id = wr.region_id
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.state,wrb.state_code)
union
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
	 hr_locations_all hl, hr_locations_all_tl hlt,
         wsh_regions wrb
    where fl.destination_id = wr.region_id
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.town_or_city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.region_2,wrb.state_code)
    and nvl (hl.business_group_id,nvl(hr_general.get_business_group_id, -99) )
             = nvl (hr_general.get_business_group_id, -99)
    and hl.location_id = hlt.location_id and hlt.language = userenv('LANG')
;


cursor c_any_exists_cursor is
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
         hz_locations hl,
         wsh_regions wrb
    where fl.destination_id = wr.region_id
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.state,wrb.state_code)
union
    select 'Y'
    from fte_lanes fl,
         wsh_regions_tl wr,
	 hr_locations_all hl, hr_locations_all_tl hlt,
         wsh_regions wrb
    where (fl.origin_id = wr.region_id or fl.DESTINATION_ID = wr.region_id)
    and wr.region_id = wrb.region_id
    and fl.lane_id = p_lane_id
    and hl.location_id = p_location_id
    and nvl(wr.city,'XX') = decode(wr.city, NULL, 'XX', nvl(hl.town_or_city,wr.city))
    and nvl(wrb.country_code,'XX') = decode(wrb.country_code, NULL, 'XX', nvl(hl.country,wrb.country_code))
    and nvl(wr.postal_code_from,'99') <= decode(wr.postal_code_from, NULL, '99',nvl(hl.postal_code,wr.postal_code_from))
    and nvl(wr.postal_code_to,'99') <= decode(wr.postal_code_to, NULL, '99',nvl(hl.postal_code,wr.postal_code_to))
    and nvl(wrb.state_code,'XX') = nvl(hl.region_2,wrb.state_code)
    and nvl (hl.business_group_id,nvl(hr_general.get_business_group_id, -99) )
             = nvl (hr_general.get_business_group_id, -99)
    and hl.location_id = hlt.location_id and hlt.language = userenv('LANG')
;


   --

   begin
     SAVEPOINT Validate_Loc_To_Region;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     --
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_valid_flag := 'Y';
     -- Validate Region
     if p_search_criteria = 'O' then
        open c_origin_exists_cursor;
        fetch c_origin_exists_cursor into x_valid_flag;
        if c_origin_exists_cursor%NOTFOUND then
           close c_origin_exists_cursor;
           x_valid_flag := 'N';
        end if;
        if c_origin_exists_cursor%ISOPEN then
          close c_origin_exists_cursor;
        end if;
     elsif p_search_criteria = 'D' then
        open c_dest_exists_cursor;
        fetch c_dest_exists_cursor into x_valid_flag;
        if c_dest_exists_cursor%NOTFOUND then
           close c_dest_exists_cursor;
           x_valid_flag := 'N';
        end if;
        if c_dest_exists_cursor%ISOPEN then
          close c_dest_exists_cursor;
        end if;
     elsif p_search_criteria = 'A' then
        open c_any_exists_cursor;
        fetch c_any_exists_cursor into x_valid_flag;
        if c_any_exists_cursor%NOTFOUND then
           close c_any_exists_cursor;
           x_valid_flag := 'N';
        end if;
        if c_any_exists_cursor%ISOPEN then
          close c_any_exists_cursor;
        end if;
     end if;
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        if c_origin_exists_cursor%isopen then
           close c_origin_exists_cursor;
        end if;
        if c_dest_exists_cursor%isopen then
           close c_dest_exists_cursor;
        end if;
        if c_any_exists_cursor%isopen then
           close c_any_exists_cursor;
        end if;
        x_valid_flag := 'N';
        ROLLBACK TO Validate_Loc_To_Region;
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if c_origin_exists_cursor%isopen then
           close c_origin_exists_cursor;
        end if;
        if c_dest_exists_cursor%isopen then
           close c_dest_exists_cursor;
        end if;
        if c_any_exists_cursor%isopen then
           close c_any_exists_cursor;
        end if;
        x_valid_flag := 'N';
        ROLLBACK TO Validate_Loc_To_Region;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
        if c_origin_exists_cursor%isopen then
           close c_origin_exists_cursor;
        end if;
        if c_dest_exists_cursor%isopen then
           close c_dest_exists_cursor;
        end if;
        if c_any_exists_cursor%isopen then
           close c_any_exists_cursor;
        end if;
        x_valid_flag := 'N';
        ROLLBACK TO Validate_Loc_To_Region;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END Validate_Loc_To_Region ;
   --
   --========================================================================
   -- Procdure Name
   --
   --   PROCEDURE Validate_Schedule_Date
   --========================================================================
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
   --    5. p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   -- Out Parameters
   --   1.x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;


   --   2. x_dep_match_flag : returns the following Values
   --       1 - Departure Date is Match with Departure Date - MATCH_WITH_DEP_DATE

   --       2 - Departure Date is Match with Arrival Date  - MATCH_WITH_ARR_DATE


   --       3 - Departure Date is between Departure and Arrival Dates - BETWEEN_DATES

   --       4 - Departure Date is Outside the Range ( before ). -BEFORE_DEP_DATE


   --       5 - Departure Date is Outside the Range ( after). - AFTER_ARRIVAL_DATE

   --   3. x_arr_match_flag : returns the following Values
   --       1 - Arrival Date is Match with Departure Date
   --       2 - Arrival Date is Match with Arrival Date
   --       3 - Arrival Date is between Departure and Arrival Dates
   --       4 - Arrival Date is Outside the Range ( before ).
   --       5 - Arrival Date is Outside the Range ( after ).

   PROCEDURE Validate_Schedule_Date(
      p_lane_id		    IN  NUMBER,
      p_schedule_id	    IN  NUMBER,

      p_departure_date      IN  DATE,
      p_arrival_date        IN  DATE,
      p_init_msg_list        IN  VARCHAR2 default fnd_api.g_false,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_dep_match_flag      OUT NOCOPY NUMBER,
      x_arr_match_flag      OUT NOCOPY NUMBER
   ) is
   l_departure_date date;
   l_arrival_date  date;
   cursor c_schedule_cursor is
   select  departure_date, arrival_date from fte_schedules
   where lane_id = p_lane_id and schedules_id = p_schedule_id
   and departure_date is not null and arrival_date is not null;

   --
   begin
     SAVEPOINT Validate_Schedule_Date;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     --
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     open c_schedule_cursor;
     fetch c_schedule_cursor into l_departure_date, l_arrival_date;

     if c_schedule_cursor%notfound then
        close c_schedule_cursor;
        raise no_data_found;
     end if;
     --
     if p_departure_date = l_departure_date then
        x_dep_match_flag := G_MATCH_WITH_DEP_DATE;
     end if;
     if p_departure_date = l_arrival_date then
        x_dep_match_flag := G_MATCH_WITH_ARR_DATE ;
     end if;
     if p_departure_date > l_departure_date and
        p_departure_date < l_arrival_date then

        x_dep_match_flag := G_BETWEEN_DATES ;
     end if;
     if p_departure_date < l_departure_date then
        x_dep_match_flag := G_BEFORE_DEP_DATE ;
     end if;
     if p_departure_date > l_arrival_date then
        x_dep_match_flag := G_AFTER_ARRIVAL_DATE ;
     end if;
     --
     if p_arrival_date = l_departure_date then
        x_arr_match_flag := G_MATCH_WITH_DEP_DATE;
     end if;
     if p_arrival_date = l_arrival_date then

        x_arr_match_flag := G_MATCH_WITH_ARR_DATE ;
     end if;
     if p_arrival_date > l_departure_date and
        p_arrival_date < l_arrival_date then
        x_arr_match_flag := G_BETWEEN_DATES ;
     end if;
     if p_arrival_date < l_departure_date then
        x_arr_match_flag := G_BEFORE_DEP_DATE ;
     end if;
     if p_arrival_date > l_arrival_date then
        x_arr_match_flag := G_AFTER_ARRIVAL_DATE ;
     end if;
     if c_schedule_cursor%isopen then

        close c_schedule_cursor;
     end if;
     --
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        if c_schedule_cursor%isopen then
          close c_schedule_cursor;
        end if;
        ROLLBACK TO Validate_Schedule_Date;
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if c_schedule_cursor%isopen then
          close c_schedule_cursor;

        end if;
        ROLLBACK TO Validate_Schedule_Date;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
        if c_schedule_cursor%isopen then
          close c_schedule_cursor;
        end if;
        ROLLBACK TO Validate_Schedule_Date;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END Validate_Schedule_Date;
   --
   --========================================================================
   -- Procdure Name

   --
   --   PROCEDURE Validate_Service_Type
   --========================================================================
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
   ) is
   cursor c_service_type is
   select 'Y' from fte_lane_services where service_code = p_service_type and lane_id = p_lane_id;

   begin

     SAVEPOINT Validate_Service_Type;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     --
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_valid_flag := 'Y';
     -- Validate service
     open c_service_type;
     fetch c_service_type into x_valid_flag;
     if c_service_type%NOTFOUND then

        close c_service_type;
        x_valid_flag := 'N';
     end if;
     if c_service_type%ISOPEN then
        close c_service_type;
     end if;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        if c_service_type%isopen then
           close c_service_type;
           x_valid_flag := 'N';
        end if;
        ROLLBACK TO Validate_Service_Type;

        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if c_service_type%isopen then
           close c_service_type;
           x_valid_flag := 'N';
        end if;
        ROLLBACK TO Validate_Service_Type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
        if c_service_type%isopen then
           close c_service_type;
           x_valid_flag := 'N';
        end if;

        ROLLBACK TO Validate_Service_Type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END Validate_Service_Type;
   --
END FTE_CAT_VALIDATE_PKG;

/
