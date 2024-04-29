--------------------------------------------------------
--  DDL for Package EAM_METER_READINGS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METER_READINGS_JSP" AUTHID CURRENT_USER AS
/* $Header: EAMMRRJS.pls 115.5 2002/11/19 23:53:13 aan ship $
   $Author: aan $ */
  -- Author  : YULIN
  -- Created : 6/1/01 1:18:57 PM
  -- Purpose : API for JSP pages to call to add meter reading

  -- Public type declarations
   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   g_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   g_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   g_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

/**
  * Wrapper function. Retrun 'Yes'/'No' for if a job has
  * has mandatory meter readings or not.
  */
-------------------------------------------------------------------------------
-- check if work order has mandatory meter reading
  function has_mandatory_meter_reading(p_wip_entity_id in number) return varchar2;

-------------------------------------------------------------------------------
-- check if meter is mandatory
  function is_meter_reading_mandatory( p_wip_entity_id in number, p_meter_id in number) RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- get the last reading's meter reading id of a meter
  function get_latest_meter_reading_id( p_meter_id in number) RETURN NUMBER;

-------------------------------------------------------------------------
--- insert a meter reading row into eam_meter_readings table
-------------------------------------------------------------------------
  procedure insert_row
  (
     p_meter_id               IN NUMBER
    ,p_current_reading        IN NUMBER
    ,p_current_reading_date   IN DATE
    ,p_reset_flag             IN VARCHAR2
    ,p_life_to_date_reading   IN NUMBER
    ,p_wip_entity_id          IN NUMBER
    ,p_description            IN VARCHAR2
  );

-------------------------------------------------------------------------
-- caculate current reading and current life to date reading
-------------------------------------------------------------------------
  procedure get_current_reading_data
  (
     p_reading                     IN    NUMBER
    ,p_reading_change              IN    NUMBER
    ,p_reset_flag                  IN    VARCHAR2
    ,p_meter_direction             IN    NUMBER
    ,p_before_reading              IN    NUMBER
    ,p_before_ltd_reading          IN    NUMBER
    ,p_after_reading               IN    NUMBER
    ,p_after_ltd_reading           IN    NUMBER
    ,p_reading_date                IN    DATE
    ,p_meter_name                  IN    VARCHAR2
    ,x_current_reading             OUT NOCOPY   NUMBER
    ,x_current_ltd_reading         OUT NOCOPY   NUMBER
    ,p_mtr_warning_shown           IN OUT NOCOPY  VARCHAR2
--    ,x_return_status               OUT   VARCHAR2
--    ,x_msg_count                   OUT   NUMBER
--    ,x_msg_data                    OUT   VARCHAR2
  );

-------------------------------------------------------------------------
-- check asset and meter associating
-------------------------------------------------------------------------
  procedure check_asset_meter_association
  (
    p_meter_id                    IN    NUMBER
   ,p_wip_entity_id               IN    NUMBER
   ,p_org_id                      IN    NUMBER        := NULL
   ,p_asset_number                IN    VARCHAR2      := NULL
   ,p_asset_group_id              IN    NUMBER        := NULL
   ,x_return_status               OUT NOCOPY   VARCHAR2
   ,x_msg_count                   OUT NOCOPY   NUMBER
   ,x_msg_data                    OUT NOCOPY   VARCHAR2
  );

--------------------------------------------------------------------------------------
-- get the reading that is just before/after the current reading date
-- we need to know the previous reading data and next reading data to do validation
--------------------------------------------------------------------------------------
  procedure get_adjacent_reading
  (
     p_before                      IN    VARCHAR2     := FND_API.G_TRUE
    ,p_meter_id                    IN    NUMBER
    ,p_reading_date                IN    DATE
    ,x_reading_id                  OUT NOCOPY   NUMBER
    ,x_reading_date                OUT NOCOPY   DATE
    ,x_reading                     OUT NOCOPY   NUMBER
    ,x_ltd_reading                 OUT NOCOPY   NUMBER
  );

------------------------------------------------------------------------------------
-- record a meter reading data
------------------------------------------------------------------------------------
  procedure add_meter_reading
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_meter_id                    IN    NUMBER
    ,p_reading_date                IN    DATE
    ,p_reading                     IN    NUMBER
    ,p_reading_change              IN    NUMBER
    ,p_reset_flag                  IN    VARCHAR2
    ,p_mtr_warning_shown           IN OUT NOCOPY  VARCHAR2
  );

end EAM_METER_READINGS_JSP;

 

/
