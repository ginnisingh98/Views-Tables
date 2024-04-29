--------------------------------------------------------
--  DDL for Package Body CS_TM_LABOR_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TM_LABOR_SCHEDULE_PVT" AS
/* $Header: csxvtmsb.pls 120.1 2005/09/20 18:26:39 talex noship $ */
RECORD_LOCK_EXCEPTION EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCK_EXCEPTION,-0054);

-- Structure Definitions
TYPE TM_REC_TYPE IS RECORD
 ( START_TIME                    DATE          ,
   END_TIME                      DATE          ,
   DAY                           VARCHAR2(40)  ,
   HOLIDAY_FLAG                  VARCHAR2(1)
 );

TYPE TM_TBL_TYPE IS TABLE OF TM_REC_TYPE INDEX BY BINARY_INTEGER;

-- Private Procedures
PROCEDURE VALIDATE_COMPLETE_CHECK
 ( P_TM_TBL_TYPE           IN         TM_TBL_TYPE,
   X_RETURN_STATUS         OUT NOCOPY VARCHAR2
 );

PROCEDURE VALIDATE_OVERLAP
 ( P_TM_TBL_TYPE           IN         TM_TBL_TYPE,
   X_RETURN_STATUS         OUT NOCOPY VARCHAR2
 );

--************************************************************************
 -- Procedure to validate labor schedule is not overlapping with one another
 -- for a specific business process
 -- Defination of the Validate_Schedule_Overlap API
--************************************************************************

 PROCEDURE VALIDATE_SCHEDULE_OVERLAP(
   P_LABOR_SCHEDULE_TBL IN TM_SCHEDULE_TBL_TYPE,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   P_API_VERSION        IN         NUMBER,
   P_INIT_MSG_LIST      IN         VARCHAR2 := FND_API.G_FALSE
  ) IS

  lv_return_status VARCHAR2(1);
  lv_return_message VARCHAR2(2000);

  -- declaring counters for populating the individual
  lv_counter1  NUMBER := 0;
  lv_counter2  NUMBER := 0;
  lv_counter3  NUMBER := 0;
  lv_counter4  NUMBER := 0;
  lv_counter5  NUMBER := 0;
  lv_counter6  NUMBER := 0;
  lv_counter7  NUMBER := 0;
  lv_counter8  NUMBER := 0;
  lv_counter9  NUMBER := 0;
  lv_counter10 NUMBER := 0;
  lv_counter11 NUMBER := 0;
  lv_counter12 NUMBER := 0;
  lv_counter13 NUMBER := 0;
  lv_counter14 NUMBER := 0;

 -- declaring the tables for the Regular and Holidays Days
  lv_tm_mon_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_tue_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_wed_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_thurs_reg_tbl_type TM_TBL_TYPE;
  lv_tm_fri_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_sat_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_sun_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_mon_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_tue_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_wed_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_thurs_hol_tbl_type TM_TBL_TYPE;
  lv_tm_fri_hoL_tbl_type   TM_TBL_TYPE;
  lv_tm_sat_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_sun_hol_tbl_type   TM_TBL_TYPE;

  -- DEBUG
  l_errm  VARCHAR2(200);

  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(30) := 'Validate_Schedule_Overlap';
  l_api_name_full VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;


 BEGIN

   -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /**-- Initialize the message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;**/


  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin the validate overlap functionality check
  -- The table passed in this api will be sorted by holiday flag and start time

  FOR lv_temp IN 1..P_LABOR_SCHEDULE_TBL.COUNT LOOP

    IF ((p_labor_schedule_tbl(lv_temp).monday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
       -- The Schedule is for Monday - Regular Day
       -- Populate The Monday Regular Table
       -- initialize the lv_counter to 1
       lv_counter1 := lv_counter1 + 1;
       lv_tm_mon_reg_tbl_type(lv_counter1).start_time := p_labor_schedule_tbl(lv_temp).start_time;
       lv_tm_mon_reg_tbl_type(lv_counter1).end_time := p_labor_schedule_tbl(lv_temp).end_time;
       lv_tm_mon_reg_tbl_type(lv_counter1).day := 'MONDAY';
       lv_tm_mon_reg_tbl_type(lv_counter1).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).tuesday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Tuesday - Regular Day
        -- Populate The Tuesday Regular Table
        -- Initialize lv_counter2 to 1
        lv_counter2 := lv_counter2 + 1;
        lv_tm_tue_reg_tbl_type(lv_counter2).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_tue_reg_tbl_type(lv_counter2).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_tue_reg_tbl_type(lv_counter2).day := 'TUESDAY';
        lv_tm_tue_reg_tbl_type(lv_counter2).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).wednesday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Wednesday - Regular Day
        -- Populate The Wednesday Regular Table
        -- Initialize lv_counter3 to 1
        lv_counter3 := lv_counter3 + 1;
        lv_tm_wed_reg_tbl_type(lv_counter3).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_wed_reg_tbl_type(lv_counter3).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_wed_reg_tbl_type(lv_counter3).day := 'WEDNESDAY';
        lv_tm_wed_reg_tbl_type(lv_counter3).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).thursday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Thursday - Regular Day
        -- Populate The Thursday Regular Table
        -- Initialize lv_counter4 to 1
        lv_counter4 := lv_counter4 + 1;
        lv_tm_thurs_reg_tbl_type(lv_counter4).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_thurs_reg_tbl_type(lv_counter4).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_reg_tbl_type(lv_counter4).day := 'THURSDAY';
        lv_tm_thurs_reg_tbl_type(lv_counter4).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).friday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Friday - Regular Day
        -- Populate The Friday Regular Table
        -- Initialize lv_counter5 to 1
        lv_counter5 := lv_counter5 + 1;
        lv_tm_fri_reg_tbl_type(lv_counter5).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_fri_reg_tbl_type(lv_counter5).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_reg_tbl_type(lv_counter5).day := 'FRIDAY';
        lv_tm_thurs_reg_tbl_type(lv_counter5).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).saturday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Saturday - Regular Day
        -- Populate The Saturday Regular Table
        -- Initialize the lv_counter6 to 1
        lv_counter6 := lv_counter6 + 1;
        lv_tm_sat_reg_tbl_type(lv_counter6).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sat_reg_tbl_type(lv_counter6).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sat_reg_tbl_type(lv_counter6).day := 'SATURDAY';
        lv_tm_sat_reg_tbl_type(lv_counter6).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).sunday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Sunday - Regular Day
        -- Populate The Sunday Regular Table
        -- Initialize the lv_counter7 to 1
        lv_counter7 := lv_counter7 + 1;
        lv_tm_sun_reg_tbl_type(lv_counter7).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sun_reg_tbl_type(lv_counter7).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sun_reg_tbl_type(lv_counter7).day := 'SUNDAY';
        lv_tm_sun_reg_tbl_type(lv_counter7).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).monday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Monday - Holiday Day
        -- Populate The Monday Holiday Table
        -- Initialize lv_counter8 to 1
        lv_counter8 := lv_counter8 + 1;
        lv_tm_mon_hol_tbl_type(lv_counter8).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_mon_hol_tbl_type(lv_counter8).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_mon_hol_tbl_type(lv_counter8).day := 'MONDAY';
        lv_tm_mon_hol_tbl_type(lv_counter8).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).tuesday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Tuesday - Holiday Day
        -- Populate The Tuesady Holiday Table
        -- Initialize lv_counter9 to 1
        lv_counter9 := lv_counter9 + 1;
        lv_tm_tue_hol_tbl_type(lv_counter9).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_tue_hol_tbl_type(lv_counter9).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_mon_hol_tbl_type(lv_counter9).day := 'TUESDAY';
        lv_tm_mon_hol_tbl_type(lv_counter9).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).wednesday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Wednesday - Holiday Day
        -- Populate the Wednesday Holiday Table
        -- Initialize the lv_counter10 to 1
        lv_counter10 := lv_counter10 + 1;
        lv_tm_wed_hol_tbl_type(lv_counter10).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_wed_hol_tbl_type(lv_counter10).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_wed_hol_tbl_type(lv_counter10).day := 'WEDNESDAY';
        lv_tm_wed_hol_tbl_type(lv_counter10).holiday_flag := 'Y';

    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).thursday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Thursday - Holiday Day
        -- Populate The Thursday Holiday Table
        -- Initialize the lv_counter11 to 1
        lv_counter11 := lv_counter11 + 1;
        lv_tm_thurs_hol_tbl_type(lv_counter11).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_thurs_hol_tbl_type(lv_counter11).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_hol_tbl_type(lv_counter11).day := 'THURSDAY';
        lv_tm_thurs_hol_tbl_type(lv_counter11).holiday_flag  := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).friday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Friday - Holiday Day
        -- Populate The Friday Holiday Table
        -- Initialize lv_counter12 to 1
        lv_counter12 := lv_counter12 + 1;
        lv_tm_fri_hol_tbl_type(lv_counter12).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_fri_hol_tbl_type(lv_counter12).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_fri_hol_tbl_type(lv_counter12).day := 'FRIDAY';
        lv_tm_fri_hol_tbl_type(lv_counter12).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).saturday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Saturday - Holiday Day
        -- Populate The Saturday Holiday Table
        -- Initialize lv_counter13 to 1;
        lv_counter13 := lv_counter13 + 1;
        lv_tm_sat_hol_tbl_type(lv_counter13).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sat_hol_tbl_type(lv_counter13).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sat_hol_tbl_type(lv_counter12).day := 'SATURDAY';
        lv_tm_sat_hol_tbl_type(lv_counter12).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).sunday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Sunday - Holiday Day
        -- Populate The Sunday Holiday Table
        -- Initialize lv_counter13 to 1;
        lv_counter14 := lv_counter14 + 1;
        lv_tm_sun_hol_tbl_type(lv_counter14).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sun_hol_tbl_type(lv_counter14).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sun_hol_tbl_type(lv_counter14).day := 'SUNDAY';
        lv_tm_sun_hol_tbl_type(lv_counter14).holiday_flag := 'Y';
    END IF;

  END LOOP;

    -- Validate Monday Regular Table for Overlap
    IF lv_tm_mon_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'MONDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Monday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_mon_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Tuesday Regular Table for Overlap
    IF lv_tm_tue_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'TUESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Tuesday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_tue_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Wednesday Regular Table for Overlap
    IF lv_tm_wed_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'WEDNESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Wednesday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_wed_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Thursday Regular Table for Overlap
    IF lv_tm_thurs_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'THURSDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Thursday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_thurs_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Friday Regular Table for Overlap
    IF lv_tm_fri_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'FRIDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Friday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_fri_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Saturday Regular Table for Overlap
    IF lv_tm_sat_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'SATURDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Saturday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_sat_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Sunday Regular Table for Overlap
    IF lv_tm_sun_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'SUNDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Sunday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_sun_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Monday Holiday Table for Overlap
    -- Following commented out for 11.5.9 Release.
 /*   IF lv_tm_mon_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'MONDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Monday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_mon_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Tuesday Holiday Table for Overlap
    IF lv_tm_tue_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'TUESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Tuesday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_tue_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Wednesday Holiday Table for Overlap
    IF lv_tm_wed_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'WEDNESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Wednesday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_wed_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Thursday Holiday Table for Overlap
    IF lv_tm_thurs_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'THURSDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Thursday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_thurs_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Friday Holiday Table for Overlap
    IF lv_tm_fri_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'FRIDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Friday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_fri_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Saturday Holiday Table for Overlap
    IF lv_tm_sat_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'SATURDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Saturday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_sat_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Sunday Holiday Table for Overlap
    IF lv_tm_sun_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token ('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'SUNDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Friday Holiday Table
      VALIDATE_OVERLAP
        (p_tm_tbl_type           => lv_tm_sun_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

*/

 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := fnd_msg_pub.get;


  WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_error;



 END VALIDATE_SCHEDULE_OVERLAP; -- End of Procedure Validate_Schedule_Overlap

--************************************************************************
 -- Procedure to validate if there is a complete labor schedule defined
 -- for a specific business process
 -- Defination of the Validate_Schedule_Overlap API
--************************************************************************
 PROCEDURE VALIDATE_SCHEDULE_MISSING(
   P_LABOR_SCHEDULE_TBL IN TM_SCHEDULE_TBL_TYPE,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   P_API_VERSION        IN         NUMBER,
   P_INIT_MSG_LIST      IN         VARCHAR2 := FND_API.G_FALSE
  ) IS

  -- assuming the the record will be sorted by holiday_flag and start_time

  lv_return_status VARCHAR2(1);
  lv_return_message VARCHAR2(2000);

  -- declaring counters for populating the individual
  lv_counter1  NUMBER := 0;
  lv_counter2  NUMBER := 0;
  lv_counter3  NUMBER := 0;
  lv_counter4  NUMBER := 0;
  lv_counter5  NUMBER := 0;
  lv_counter6  NUMBER := 0;
  lv_counter7  NUMBER := 0;
  lv_counter8  NUMBER := 0;
  lv_counter9  NUMBER := 0;
  lv_counter10 NUMBER := 0;
  lv_counter11 NUMBER := 0;
  lv_counter12 NUMBER := 0;
  lv_counter13 NUMBER := 0;
  lv_counter14 NUMBER := 0;

 -- declaring the tables for the Regular and Holidays Days
  lv_tm_mon_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_tue_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_wed_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_thurs_reg_tbl_type TM_TBL_TYPE;
  lv_tm_fri_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_sat_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_sun_reg_tbl_type   TM_TBL_TYPE;
  lv_tm_mon_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_tue_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_wed_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_thurs_hol_tbl_type TM_TBL_TYPE;
  lv_tm_fri_hoL_tbl_type   TM_TBL_TYPE;
  lv_tm_sat_hol_tbl_type   TM_TBL_TYPE;
  lv_tm_sun_hol_tbl_type   TM_TBL_TYPE;

  -- DEBUG
  l_errm  VARCHAR2(200);

  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(30) := 'Validate_Schedule_Missing';
  l_api_name_full VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;


 BEGIN

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/*   -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
*/

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR lv_temp IN 1..P_LABOR_SCHEDULE_TBL.COUNT LOOP
    IF ((p_labor_schedule_tbl(lv_temp).monday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
       -- The Schedule is for Monday - Regular Day
       -- Populate The Monday Regular Table
       -- initialize the lv_counter to 1
       lv_counter1 := lv_counter1 + 1;
       lv_tm_mon_reg_tbl_type(lv_counter1).start_time := p_labor_schedule_tbl(lv_temp).start_time;
       lv_tm_mon_reg_tbl_type(lv_counter1).end_time := p_labor_schedule_tbl(lv_temp).end_time;
       lv_tm_mon_reg_tbl_type(lv_counter1).day := 'MONDAY';
       lv_tm_mon_reg_tbl_type(lv_counter1).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).tuesday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
       -- The Schedule is for Tuesday - Regular Day
       -- Populate The Tuesday Regular Table
       -- Initialize lv_counter2 to 1
       lv_counter2 := lv_counter2 + 1;
       lv_tm_tue_reg_tbl_type(lv_counter2).start_time := p_labor_schedule_tbl(lv_temp).start_time;
       lv_tm_tue_reg_tbl_type(lv_counter2).end_time := p_labor_schedule_tbl(lv_temp).end_time;
       lv_tm_tue_reg_tbl_type(lv_counter2).day := 'TUESDAY';
       lv_tm_tue_reg_tbl_type(lv_counter2).holiday_flag := 'N';
    END IF;


    IF ((p_labor_schedule_tbl(lv_temp).wednesday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Wednesday - Regular Day
        -- Populate The Wednesday Regular Table
        -- Initialize lv_counter3 to 1
        lv_counter3 := lv_counter3 + 1;
        lv_tm_wed_reg_tbl_type(lv_counter3).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_wed_reg_tbl_type(lv_counter3).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_wed_reg_tbl_type(lv_counter3).day := 'WEDNESDAY';
        lv_tm_wed_reg_tbl_type(lv_counter3).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).thursday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Thursday - Regular Day
        -- Populate The Thursday Regular Table
        -- Initialize lv_counter4 to 1
        lv_counter4 := lv_counter4 + 1;
        lv_tm_thurs_reg_tbl_type(lv_counter4).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_thurs_reg_tbl_type(lv_counter4).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_reg_tbl_type(lv_counter4).day := 'THURSDAY';
        lv_tm_thurs_reg_tbl_type(lv_counter4).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).friday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Friday - Regular Day
        -- Populate The Friday Regular Table
        -- Initialize lv_counter5 to 1
        lv_counter5 := lv_counter5 + 1;
        lv_tm_fri_reg_tbl_type(lv_counter5).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_fri_reg_tbl_type(lv_counter5).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_reg_tbl_type(lv_counter5).day := 'FRIDAY';
        lv_tm_thurs_reg_tbl_type(lv_counter5).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).saturday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Saturday - Regular Day
        -- Populate The Saturday Regular Table
        -- Initialize the lv_counter6 to 1
        lv_counter6 := lv_counter6 + 1;
        lv_tm_sat_reg_tbl_type(lv_counter6).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sat_reg_tbl_type(lv_counter6).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sat_reg_tbl_type(lv_counter6).day := 'SATURDAY';
        lv_tm_sat_reg_tbl_type(lv_counter6).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).sunday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'N')) THEN
        -- The Schedule is for Sunday - Regular Day
        -- Populate The Sunday Regular Table
        -- Initialize the lv_counter7 to 1
        lv_counter7 := lv_counter7 + 1;
        lv_tm_sun_reg_tbl_type(lv_counter7).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sun_reg_tbl_type(lv_counter7).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sun_reg_tbl_type(lv_counter7).day := 'SUNDAY';
        lv_tm_sun_reg_tbl_type(lv_counter7).holiday_flag := 'N';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).monday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Monday - Holiday Day
        -- Populate The Monday Holiday Table
        -- Initialize lv_counter8 to 1
        lv_counter8 := lv_counter8 + 1;
        lv_tm_mon_hol_tbl_type(lv_counter8).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_mon_hol_tbl_type(lv_counter8).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_mon_hol_tbl_type(lv_counter8).day := 'MONDAY';
        lv_tm_mon_hol_tbl_type(lv_counter8).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).tuesday_flag = 'Y') AND
          (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
          -- The Schedule is for Tuesday - Holiday Day
          -- Populate The Tuesady Holiday Table
          -- Initialize lv_counter9 to 1
          lv_counter9 := lv_counter9 + 1;
          lv_tm_tue_hol_tbl_type(lv_counter9).start_time := p_labor_schedule_tbl(lv_temp).start_time;
          lv_tm_tue_hol_tbl_type(lv_counter9).end_time := p_labor_schedule_tbl(lv_temp).end_time;
          lv_tm_mon_hol_tbl_type(lv_counter9).day := 'TUESDAY';
          lv_tm_mon_hol_tbl_type(lv_counter9).holiday_flag := 'Y';

    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).wednesday_flag = 'Y')  AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Wednesday - Holiday Day
        -- Populate the Wednesday Holiday Table
        -- Initialize the lv_counter10 to 1
        lv_counter10 := lv_counter10 + 1;
        lv_tm_wed_hol_tbl_type(lv_counter10).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_wed_hol_tbl_type(lv_counter10).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_wed_hol_tbl_type(lv_counter10).day := 'WEDNESDAY';
        lv_tm_wed_hol_tbl_type(lv_counter10).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).thursday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Thursday - Holiday Day
        -- Populate The Thursday Holiday Table
        -- Initialize the lv_counter11 to 1
        lv_counter11 := lv_counter11 + 1;
        lv_tm_thurs_hol_tbl_type(lv_counter11).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_thurs_hol_tbl_type(lv_counter11).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_thurs_hol_tbl_type(lv_counter11).day := 'THURSDAY';
        lv_tm_thurs_hol_tbl_type(lv_counter11).holiday_flag  := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).friday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Friday - Holiday Day
        -- Populate The Friday Holiday Table
        -- Initialize lv_counter12 to 1
        lv_counter12 := lv_counter12 + 1;
        lv_tm_fri_hol_tbl_type(lv_counter12).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_fri_hol_tbl_type(lv_counter12).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_fri_hol_tbl_type(lv_counter12).day := 'FRIDAY';
        lv_tm_fri_hol_tbl_type(lv_counter12).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).saturday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Saturday - Holiday Day
        -- Populate The Saturday Holiday Table
        -- Initialize lv_counter13 to 1;
        lv_counter13 := lv_counter13 + 1;
        lv_tm_sat_hol_tbl_type(lv_counter13).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sat_hol_tbl_type(lv_counter13).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sat_hol_tbl_type(lv_counter12).day := 'SATURDAY';
        lv_tm_sat_hol_tbl_type(lv_counter12).holiday_flag := 'Y';
    END IF;

    IF ((p_labor_schedule_tbl(lv_temp).sunday_flag = 'Y') AND
        (p_labor_schedule_tbl(lv_temp).holiday_flag = 'Y')) THEN
        -- The Schedule is for Sunday - Holiday Day
        -- Populate The Sunday Holiday Table
        -- Initialize lv_counter13 to 1;
        lv_counter14 := lv_counter14 + 1;
        lv_tm_sun_hol_tbl_type(lv_counter14).start_time := p_labor_schedule_tbl(lv_temp).start_time;
        lv_tm_sun_hol_tbl_type(lv_counter14).end_time := p_labor_schedule_tbl(lv_temp).end_time;
        lv_tm_sun_hol_tbl_type(lv_counter14).day := 'SUNDAY';
        lv_tm_sun_hol_tbl_type(lv_counter14).holiday_flag := 'Y';
    END IF;

  END LOOP;

    -- Validate Monday Regular Table for Completeness
    IF lv_tm_mon_reg_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'MONDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Monday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_mon_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Tuesday Regular Table for Completeness
    IF lv_TM_TUE_REG_TBL_TYPE.COUNT = 0 THEN
    -- error
       FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
       FND_MESSAGE.set_token('API_NAME', l_api_name);
       FND_MESSAGE.set_token('VALUE', 'Regular');
       FND_MESSAGE.set_token('DAY', 'TUESDAY');
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
    ELSE -- Call Function to validate the Tuesday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_tue_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Wednesday Regular Table for Completeness
    IF lv_TM_WED_REG_TBL_TYPE.COUNT = 0 THEN
    --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'Wednesday');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;

    ELSE -- Call Function to validate
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_wed_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Thursday Regular Table for Completeness
    IF lv_TM_THURS_REG_TBL_TYPE.COUNT = 0 THEN
    --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'THURSDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE -- Call Function to validate
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_thurs_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Friday Regular Table for Completeness
    IF lv_TM_FRI_REG_TBL_TYPE.COUNT = 0 THEN
    --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Regular');
      FND_MESSAGE.set_token('DAY', 'FRIDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE -- Call Function to validate
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_fri_reg_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

   -- Validate Saturday Regular Table for Completeness
   IF lv_TM_SAT_REG_TBL_TYPE.COUNT = 0 THEN
   --error
     FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
     FND_MESSAGE.set_token('API_NAME', l_api_name);
     FND_MESSAGE.set_token('VALUE', 'Regular');
     FND_MESSAGE.set_token('DAY', 'SATURDAY');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   ELSE -- Call Function to validate
     VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_sat_reg_tbl_type,
         x_return_status         => lv_return_status
         );
     IF lv_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   -- Validate Sunday Regular Table for Completeness
   IF lv_TM_SUN_REG_TBL_TYPE.COUNT = 0  THEN
   --error
     FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
     FND_MESSAGE.set_token('API_NAME', l_api_name);
     FND_MESSAGE.set_token('VALUE', 'Regular');
     FND_MESSAGE.set_token('DAY', 'SUNDAY');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   ELSE -- Call Function to validate
     VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_sun_reg_tbl_type,
         x_return_status         => lv_return_status
         );
     IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
     END IF;
   END IF;

   -- Validate Monday Holiday Table for Completeness
   -- Following Commented out for 11.5.9 release.
/*   IF lv_tm_mon_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'MONDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Monday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_mon_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Tuesday Holiday Table for Completeness
    IF lv_tm_tue_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'TUESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Tuesday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_tue_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Wednesday Holiday Table for Completeness
    IF lv_tm_wed_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'WEDNESDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Wednesday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_wed_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Thursday Holiday Table for Completeness
    IF lv_tm_thurs_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'THURSDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Thursday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_thurs_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Friday Holiday Table for Completeness
    IF lv_tm_fri_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'FRIDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Friday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_fri_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Saturday Holiday Table for Completeness
    IF lv_tm_sat_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'SATURDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Saturday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_sat_hol_tbl_type,
         x_return_status         => lv_return_status
         );

      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate Sunday Holiday Table for Completeness
    IF lv_tm_sun_hol_tbl_type.count = 0 THEN
     --error
      FND_MESSAGE.set_name('CS','CS_CHG_API_DAY_NOT_SETUP');
      FND_MESSAGE.set_token('API_NAME', l_api_name);
      FND_MESSAGE.set_token('VALUE', 'Holiday');
      FND_MESSAGE.set_token('DAY', 'SUNDAY');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE ---Call Function To validate Friday Holiday Table
      VALIDATE_COMPLETE_CHECK
        (p_tm_tbl_type           => lv_tm_sun_hol_tbl_type,
         x_return_status         => lv_return_status
         );
      IF lv_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
*/

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     x_msg_data := fnd_msg_pub.get;

    WHEN OTHERS THEN

      l_errm := SQLERRM;

  END VALIDATE_SCHEDULE_MISSING;

--************************************************************************
 -- Procedure to Process an input debrief labor activity, break in into
 -- several Time and Material labor coverage time segments based on
 -- the Time and Material Schedule table.  This procedure will return a set of
 -- records which contain several labor covergae time that represents the complete
 -- input activity time.
 -- Defination of the Get_labor_Coverages API
--************************************************************************

 PROCEDURE GET_LABOR_COVERAGES(
     P_BUSINESS_PROCESS_ID IN NUMBER,
     P_ACTIVITY_START_DATE_TIME IN DATE,
     P_ACTIVITY_END_DATE_TIME   IN DATE,
     X_LABOR_COVERAGE_TBL       OUT NOCOPY TM_COVERAGE_TBL_TYPE,
     X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
     X_MSG_COUNT                OUT NOCOPY NUMBER,
     X_MSG_DATA                 OUT NOCOPY VARCHAR2,
     P_API_VERSION              IN NUMBER,
     P_INIT_MSG_LIST            IN VARCHAR2
     ) IS

    --Time Card Record
    TYPE TM_CARD_REC IS RECORD (START_TIME    DATE,
                                END_TIME      DATE,
                                DAY           VARCHAR2(10),
                                HOLIDAY_FLAG  VARCHAR2(1) DEFAULT 'N');

     time_card_table       TM_CARD_REC;
     TYPE ref_cursor       IS REF CURSOR;
     tmpl_csr              ref_cursor;
     l_start_time          DATE;
     l_inv_item_id         NUMBER;
     l_end_time            DATE;
     --Added to Fix Bug # 3269347
     l_end_time2           DATE;
     l_api_name            CONSTANT VARCHAR2(30)  :=  'Get_Labor_Coverages';
     l_api_name_full       CONSTANT VARCHAR2(80)  :=  G_PKG_NAME ||'.'||l_api_name;
     l_api_version         CONSTANT NUMBER        :=  1;
     l_labor_coverages_tbl cs_tm_labor_schedule_pvt.tm_coverage_tbl_type;
     i                     BINARY_INTEGER         := 1;
     j                     BINARY_INTEGER         := 0;
     l_stmt                VARCHAR2(4000);
     l_proc                VARCHAR2(200);
     l_hol                 VARCHAR2(200);
     l_order               VARCHAR2(200);
     l_day                 VARCHAR2(100);
     l_days_gap            NUMBER;
     l_found               VARCHAR2(1)            := 'N';
     l_day_number          NUMBER;

     l_tm_sched_complete_flag  VARCHAR2(1);

     -- DEBUG ONLY
     l_errm  varchar2(200);

     -- Added to resolve bug # 2933203 - mviswana
      CURSOR tm_validate_csr(p_business_process_id number) IS
      SELECT NVL(tm_sched_complete_flag, 'N')
        FROM cs_business_processes
       WHERE business_process_id = p_business_process_id;


 BEGIN

   -- Standard Call to check API Compatibility
   IF NOT FND_API.Compatible_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize the message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Initialize the API Return Success to TRUE
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Added to resolve bug # 2933203 - mviswana

   -- Check if the Time and Material Labor Schedule is valid for the business
   -- process that is passed
   -- Retrieve the tm_sched_complete_flag for the business_process_id.

   OPEN tm_validate_csr(p_business_process_id);
   FETCH tm_validate_csr into l_tm_sched_complete_flag;
   IF tm_validate_csr%NOTFOUND THEN
     CLOSE tm_validate_csr;

     FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
     FND_MESSAGE.Set_Token('API_NAME', l_api_name);
     FND_MESSAGE.Set_Token('VALUE', p_business_process_id);
     FND_MESSAGE.Set_Token('PARAMETER', 'p_business_process_id');
     FND_MSG_PUB.Add;
     RAISE FND_API.g_exc_error;

   END IF;
   CLOSE tm_validate_csr;

   -- If the Tm_sched_complete_flag is 'N' then return error;

   IF l_tm_sched_complete_flag <> 'Y' THEN
     --raise error
     FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_TM_SCHED_INCOMPLETE');
     FND_MESSAGE.Set_Token('API_NAME', l_api_name);
     FND_MESSAGE.Set_Token('BUSINESS_PROC_ID', p_business_process_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.g_exc_error;
   END IF;

   -- Check to see if activity occurs in the same day
   IF trunc(p_activity_end_date_time) - trunc(p_activity_start_date_time) = 0 THEN

     --If activity on the same day then populate time card record with in parameters
     time_card_table.start_time := trunc(sysdate) +
                               (p_activity_start_date_time - trunc(p_activity_start_date_time));
     time_card_table.end_time   := trunc(sysdate) +
                               (p_activity_end_date_time - trunc(p_activity_end_date_time));

     -- Added to fix Fixed Bug # 3528586
     -- l_day_number required for getting the day of the week (eg 'D' comes out as 1)
     l_day_number := to_char( P_ACTIVITY_START_DATE_TIME, 'D');

     --Do the decode of the l_day_number
     IF l_day_number = 1 THEN
       time_card_table.day := 'SUNDAY';
     ELSIF l_day_number = 2 THEN
       time_card_table.day := 'MONDAY';
     ELSIF l_day_number = 3 THEN
       time_card_table.day := 'TUESDAY';
     ELSIF l_day_number = 4 THEN
       time_card_table.day := 'WEDNESDAY';
     ELSIF l_day_number = 5 THEN
       time_card_table.day := 'THURSDAY';
     ELSIF l_day_number = 6 THEN
       time_card_table.day := 'FRIDAY';
     ELSIF l_day_number = 7 THEN
       time_card_table.day := 'SATURDAY';
     END IF;

     -- Call ATG program with p_start_acitivty
     -- Time_card_table.holiday_flag := ATG(P_ACTIVITY_START_DATE_TIME);
     time_card_table.holiday_flag := 'N';

   ELSE
     -- END activity does not end on the same day as START activity (outside the scope of this program)
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


    l_stmt := 'SELECT trunc(sysdate)+(start_hour/24)+(start_minute/(24*60)) START_TIME, ';
    l_stmt := l_stmt||'trunc(sysdate)+(end_hour/24)+(end_minute/(24*60))  END_TIME, ';
    l_stmt := l_stmt||'inventory_item_id FROM cs_tm_labor_schedules WHERE 1 = 1 AND ';
    l_proc  := 'Business_process_id = '||P_BUSINESS_PROCESS_ID||' AND ';
    l_hol   := 'NVL(HOLIDAY_FLAG, ''N'') = '||''''||Time_card_table.holiday_flag||''''||' AND ';
    l_day   := Time_card_table.day||'_FLAG = ''Y'' ';
    l_order := 'order by trunc(sysdate) + (start_time - trunc(start_time))';
    l_stmt  := l_stmt || l_proc || l_hol || l_day || l_order;

    OPEN tmpl_csr FOR l_stmt;
      -- Used to restore retain the date component of the OUT records
      l_days_gap  := TRUNC(p_activity_start_date_time) - TRUNC(SYSDATE);
      LOOP

      -- infinite loop not possible because each day is fully defined

      FETCH tmpl_csr INTO
      l_start_time,
      l_end_time,
      l_inv_item_id;

      IF tmpl_csr%FOUND THEN
        IF l_found = 'N' THEN
          --Added to Fix Bug # 3269347
          l_end_time2 := l_end_time - (1/86400);

          IF Time_card_table.start_time BETWEEN l_start_time AND l_end_time2 THEN
            j  :=  j + 1;
            l_found := 'Y';
            X_LABOR_COVERAGE_TBL(j).labor_start_date_time     := (Time_card_table.start_time + l_days_gap);
            X_LABOR_COVERAGE_TBL(j).inventory_item_id         := l_inv_item_id;

            --Changed from <= to < to Fix Bug # 3269347

            IF l_end_time < Time_card_table.end_time THEN
              X_LABOR_COVERAGE_TBL(j).labor_end_date_time := (l_end_time + l_days_gap);
            ELSE
              X_LABOR_COVERAGE_TBL(j).labor_end_date_time := (time_card_table.end_time + l_days_gap);
              EXIT;
            END IF;
          END IF;
       --l_found = 'Y'
      ELSE
        j  :=  j + 1;

        X_LABOR_COVERAGE_TBL(j).labor_start_date_time  := (l_start_time + l_days_gap);
        X_LABOR_COVERAGE_TBL(j).inventory_item_id      := l_inv_item_id;

        --Changed from >= to > to Fix Bug # 3269347

        IF Time_card_table.end_time > l_end_time THEN
          X_LABOR_COVERAGE_TBL(j).labor_end_date_time       := (l_end_time + l_days_gap);
        ELSE
          X_LABOR_COVERAGE_TBL(j).labor_end_date_time       := (Time_card_table.end_time + l_days_gap);
          EXIT;
        END IF;
      END IF;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  CLOSE tmpl_csr;

 EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_RETURN_STATUS  :=  FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    X_RETURN_STATUS  :=  FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    X_RETURN_STATUS  :=  FND_API.G_RET_STS_UNEXP_ERROR;

 END GET_LABOR_COVERAGES;


 --************************************************************************
 -- Private Procedure Validate_Complete_Check
 --************************************************************************

 PROCEDURE VALIDATE_COMPLETE_CHECK
    (P_TM_TBL_TYPE           IN         TM_TBL_TYPE,
     X_RETURN_STATUS         OUT NOCOPY VARCHAR2
     ) IS

    lv_index              BINARY_INTEGER := 0;
    lv_sum                NUMBER := 0;

    e_gap_in_schedule     EXCEPTION;
    e_comp_chk_failure    EXCEPTION;

  l_api_name VARCHAR2(30) := 'Validate_Schedule_Missing';
  l_api_name_full VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;


  -- DEBUG
  l_errm  VARCHAR2(200);

 BEGIN

 lv_index := P_TM_TBL_TYPE.FIRST;

--   FOR lv_temp IN 1..P_TM_TBL_TYPE.COUNT LOOP

  LOOP
      IF lv_index = P_TM_TBL_TYPE.FIRST THEN
         lv_sum := lv_sum + (P_TM_TBL_TYPE(lv_index).end_time - P_TM_TBL_TYPE(lv_index).start_time);
      ELSE
        IF P_TM_TBL_TYPE(lv_index).start_time <> P_TM_TBL_TYPE(lv_index - 1).end_time THEN
        --error
          fnd_message.set_name('CS','CS_CHG_API_GAP_IN_SCHEDULE');
          fnd_message.set_token('API_NAME', l_api_name);
          fnd_message.set_token('DAY', P_TM_TBL_TYPE(lv_index).day);
          fnd_message.set_token('START_TIME', TO_CHAR(P_TM_TBL_TYPE(lv_index).start_time,'HH24:MI'));
          fnd_message.set_token('PREVIOUS_END_TIME', TO_CHAR(P_TM_TBL_TYPE(lv_index - 1).end_time, 'HH24:MI'));
          --fnd_message.set_token('HOLIDAY_FLAG', P_TM_TBL_TYPE(lv_index).holiday_flag);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSE
           lv_sum :=  lv_sum + (P_TM_TBL_TYPE(lv_index).end_time - P_TM_TBL_TYPE(lv_index).start_time);
        END IF;
     END IF;

     EXIT WHEN lv_index = P_TM_TBL_TYPE.LAST;
     lv_index := P_TM_TBL_TYPE.NEXT(lv_index);

   END LOOP;

   IF lv_sum < .9993 THEN
   --error
   --RAISE e_comp_chk_failure;
       fnd_message.set_name('CS','CS_CHG_API_COMPLETE_CHECK_FAIL');
       fnd_message.set_token('API_NAME', l_api_name);
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;

   END IF;

   EXCEPTION

     WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

     WHEN OTHERS THEN
       l_errm := SQLERRM;
 END VALIDATE_COMPLETE_CHECK;

 --************************************************************************
 -- Private Procedure Validate_Complete_Check
 --************************************************************************

 PROCEDURE VALIDATE_OVERLAP
    (P_TM_TBL_TYPE           IN         TM_TBL_TYPE,
     X_RETURN_STATUS         OUT NOCOPY VARCHAR2
     ) IS

    lv_index              BINARY_INTEGER := 0;

  -- DEBUG
  l_errm  VARCHAR2(200);

  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(30) := 'Validate_Schedule_Overlap';
  l_api_name_full VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;


 BEGIN

 lv_index := P_TM_TBL_TYPE.FIRST;

--   FOR lv_temp IN 1..P_TM_TBL_TYPE.COUNT LOOP

     LOOP
      IF lv_index <> P_TM_TBL_TYPE.FIRST THEN
        IF P_TM_TBL_TYPE(lv_index).start_time < P_TM_TBL_TYPE(lv_index - 1).end_time THEN
          --error
            fnd_message.set_name('CS','CS_CHG_API_OVERLAP_FOUND');
            fnd_message.set_token('API_NAME', l_api_name);
            fnd_message.set_token('DAY', P_TM_TBL_TYPE(lv_index).day);
            fnd_message.set_token('START_TIME', TO_CHAR(P_TM_TBL_TYPE(lv_index).start_time,'HH24:MI'));
            fnd_message.set_token('PREVIOUS_END_TIME', TO_CHAR(P_TM_TBL_TYPE(lv_index - 1).end_time, 'HH24:MI'));
            --fnd_message.set_token('HOLIDAY_FLAG', P_TM_TBL_TYPE(lv_index).holiday_flag);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        ELSE
        null;
        END IF;
      END IF;
     EXIT WHEN lv_index = P_TM_TBL_TYPE.LAST;
     lv_index := P_TM_TBL_TYPE.NEXT(lv_index);

     END LOOP;

   EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN OTHERS THEN
       --l_errm := SQLERRM;
       x_return_status := fnd_api.g_ret_sts_error;

   END VALIDATE_OVERLAP;

END CS_TM_LABOR_SCHEDULE_PVT;

/
