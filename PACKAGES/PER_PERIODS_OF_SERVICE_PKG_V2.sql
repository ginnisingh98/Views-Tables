--------------------------------------------------------
--  DDL for Package PER_PERIODS_OF_SERVICE_PKG_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERIODS_OF_SERVICE_PKG_V2" AUTHID CURRENT_USER AS
/* $Header: pepds02t.pkh 120.1 2006/05/08 08:43:58 lsilveir noship $ */
--
-- flemonni
-- hire date changes bug # 625423
--
-- |--------------------------------------------------------------------------|
-- |-- < Get_Max_Last_Process_date >------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- gets the most recent final process date of a period of service
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns the final process date
--
-- Post Failure:
-- returns null
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Max_Last_Process_date
  ( p_person_id IN NUMBER
  )
RETURN DATE;
-- |--------------------------------------------------------------------------|
-- |-- < Get_Valid_Hire_Dates >-----------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- checks the person / assignemnt and periods_of_service tables in the schema
-- for a min max range of hire date
--
-- Prerequisites:
-- none
--
-- Post Success:
-- the minimum and maximum hire dates are returned as well as whether a
-- back to back contract is permissible
--
-- Post Failure:
-- error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE Get_Valid_Hire_Dates
  ( p_person_id			IN per_all_people_f.person_id%TYPE
  , p_session_date		IN DATE
  , p_dob			IN DATE
  , p_business_group_id		IN NUMBER
  , p_min_date 			OUT NOCOPY DATE
  , p_max_date			OUT NOCOPY DATE
  , p_b2b_allowed		OUT NOCOPY BOOLEAN
  , p_pds_not_terminated	OUT NOCOPY BOOLEAN
  );
-- |--------------------------------------------------------------------------|
-- |-- < IsBackToBackContract >-----------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- given a hire date checks whether the period of service was created as
-- a back to back contract
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns true
--
-- Post Failure:
-- returns false
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION IsBackToBackContract
  ( p_person_id			IN per_people_f.person_id%TYPE
  , p_hire_date_of_current_pds	IN DATE
  )
RETURN BOOLEAN;
-- |--------------------------------------------------------------------------|
-- |-- < Get_Current_PDS_Start_Date >-----------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- gets the start date of the period of service id
--
-- Prerequisites:
-- if p_type is null, searches for the current employment (i.e. not terminated)
-- if p_type is RECENT, then checks for the most recent pds, terminated or not
--
-- Post Success:
-- returns the start date
--
-- Post Failure:
-- returns null
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Current_PDS_Start_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_type 		IN VARCHAR2 DEFAULT NULL
  )
RETURN DATE;
-- |--------------------------------------------------------------------------|
-- |-- < Get_Current_Open_PDS_id >--------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- gets the most recent (open) period of service id
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns the period of service id
--
-- Post Failure:
-- returns null
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Current_Open_PDS_id
  ( p_person_id 	IN per_people_f.person_id%TYPE
  )
RETURN NUMBER;
-- |--------------------------------------------------------------------------|
-- |-- < Is_Max_PDS_Not_Closed >----------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- checks whther most recent pds is terminated or not (final process date is
-- filled in)
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns true
--
-- Post Failure:
-- returns false
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Is_Max_PDS_Not_Closed
  ( p_person_id 	IN per_people_f.person_id%TYPE
  )
RETURN BOOLEAN;
END PER_PERIODS_OF_SERVICE_PKG_V2;

 

/
