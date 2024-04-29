--------------------------------------------------------
--  DDL for Package Body OKS_COVERAGE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COVERAGE_UTIL_PVT" AS
/* $Header: OKSRCUTB.pls 120.4 2005/08/09 13:57:22 sasethi noship $ */

-- Purpose: Utility package for OKS Coverage Times
--

  -- Global Constants
  G_APP_NAME				 CONSTANT VARCHAR2(5) := 'OKS';
  G_COV_DEF_TZONE_MSG		 CONSTANT VARCHAR2(30) := 'OKS_INQ_COV_DEF_TZONE_TXT';
  G_COV_DEF_TZONE_MSG_TKN	 CONSTANT VARCHAR2(30) := 'TIMEZONE';


  /**
   * Helper API to check if the Coverage Times for the given Timezone Id has already
   * been processed and inserted into the GT table within a session.
   */
  FUNCTION isTimezoneAlreadyProcessed (cov_timezone_id NUMBER)
  RETURN VARCHAR2
  IS
     l_count number := 0;
     l_api_name          CONSTANT VARCHAR2(30) := 'isTimezoneAlreadyProcessed';
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
       ,'100: Entered isTimezoneAlreadyProcessed');
    END IF;

    -- check if the Coverage Times for given timezone id has already been inserted into
    -- GT table.
    SELECT
    count(*)
    into l_count
    from oks_coverage_times_gt
    where COV_TZE_LINE_ID = cov_timezone_id;

    -- If Count is greater then 0, return Y
    IF l_count > 0 THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'110: Returning Y');
        END IF;
        return 'Y';
    ELSE
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'120: Returning N');
        END IF;
        return 'N';
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
         ,'200: Leaving isTimezoneAlreadyProcessed');
    END IF;
  END; -- End of isTimezoneAlreadyProcessed

  /**
   * Helper API to find out if the given Start and End time lies between the given
   * Coverage Start and End Time
   */
  FUNCTION intervals_match
  (start_time  IN   NUMBER,
   end_time  IN   NUMBER,
   cov_start_time IN NUMBER,
   cov_end_time IN NUMBER
  ) RETURN VARCHAR2
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'intervals_match';
  BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
         ,'100: Entering intervals_match');
      END IF;

      IF start_time >= cov_start_time AND end_time <= cov_end_time THEN
          return 'Y';
      ELSE
          return 'N';
      END IF;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
         ,'200: Leaving intervals_match');
      END IF;
  END; -- End of intervals_match

  /**
   * Procedure to process new Coverage Times into a PL/SQL record := new_coverage_times_rec
   * and return back the record.
   * @param flattened_st_end_limit_recs PL/SQL table structure of Flattened Start and End times
   * @param coverage_times_recs Actual Coverage Times records from OKS_COVERAGE_TIMES loaded
   * into this PL/SQL table structure
   * @param new_coverage_times_rec New Coverage Times PL/SQL Record returned to the calling
   * API (init_coverage_times_view)
   */
  PROCEDURE process_new_coverage_times(
       flattened_st_end_limit_recs IN flattened_time_limits_TBL,
       coverage_times_recs         IN ui_coverage_times_tbl,
       new_coverage_times_rec      OUT NOCOPY ui_coverage_times_rec,
       x_msg_data                  OUT NOCOPY VARCHAR2,
       x_msg_count                 OUT NOCOPY NUMBER,
       x_return_status             OUT NOCOPY VARCHAR2)
  IS
      -- Procedure Name ussed for loggin
     l_api_name          CONSTANT VARCHAR2(30) := 'process_new_coverage_times';
     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_intervals_match_flag VARCHAR2(1) := 'N';

  BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'100: Entered process_new_coverage_times');
        END IF;

        -- Loop thru Flattened Start and End Times PL/SQL Table structure
        IF flattened_st_end_limit_recs.COUNT > 0 THEN
            -- Record current record's Start and Times, one concatenated with ":"
            -- and other just like 2243, 2359 for computation
            new_coverage_times_rec.start_time :=
                flattened_st_end_limit_recs(0).concatenate_time;
            new_coverage_times_rec.end_time   :=
                flattened_st_end_limit_recs(1).concatenate_time;
            new_coverage_times_rec.start_hour_minute :=
                flattened_st_end_limit_recs(0).time;
            new_coverage_times_rec.end_hour_minute   :=
                flattened_st_end_limit_recs(1).time;

            -- Default settings of New Coverage Times for Days of Week
            new_coverage_times_rec.monday_yn     := 'N';
            new_coverage_times_rec.tuesday_yn    := 'N';
            new_coverage_times_rec.wednesday_yn  := 'N';
            new_coverage_times_rec.thursday_yn   := 'N';
            new_coverage_times_rec.friday_yn     := 'N';
            new_coverage_times_rec.saturday_yn   := 'N';
            new_coverage_times_rec.sunday_yn     := 'N';

            -- loop thru coverage_times_recs, identify if the new Start-End Time interval
            -- exists in the given Coverage Time Interval, If found, process new Coverage
            -- Times as per the Covered Days in the given Coverage time interval
            IF coverage_times_recs.COUNT > 0 THEN
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                   '103: Number of records in coverage_times_recs :'||
                                   to_char(coverage_times_recs.COUNT));
                END IF;
                FOR i IN coverage_times_recs.FIRST..coverage_times_recs.LAST LOOP

                    -- check if given start_time and end_time exists between the current
                    -- coverage_times interval
                    l_intervals_match_flag := intervals_match(
                                   start_time       => flattened_st_end_limit_recs(0).time,
                                   end_time         => flattened_st_end_limit_recs(1).time,
                                   cov_start_time   => coverage_times_recs(i).start_hour_minute,
                                   cov_end_time     => coverage_times_recs(i).end_hour_minute);

                    -- intiailize New Coverage Times record with the Coverage Timezone Id
                    new_coverage_times_rec.COV_TZE_LINE_ID := coverage_times_recs(i).COV_TZE_LINE_ID;

                    -- If Intervals match, create new coverage times
                    IF ( l_intervals_match_flag = 'Y' ) THEN

                        -- set Covered Days Flags
                        IF (new_coverage_times_rec.monday_yn = 'N') THEN
                            new_coverage_times_rec.monday_yn     := coverage_times_recs(i).monday_yn;
                        END IF;
                        IF (new_coverage_times_rec.tuesday_yn = 'N') THEN
                            new_coverage_times_rec.tuesday_yn    := coverage_times_recs(i).tuesday_yn;
                        END IF;
                        IF (new_coverage_times_rec.wednesday_yn = 'N') THEN
                            new_coverage_times_rec.wednesday_yn    := coverage_times_recs(i).wednesday_yn;
                        END IF;
                        IF (new_coverage_times_rec.thursday_yn = 'N') THEN
                            new_coverage_times_rec.thursday_yn    := coverage_times_recs(i).thursday_yn;
                        END IF;
                        IF (new_coverage_times_rec.friday_yn = 'N') THEN
                            new_coverage_times_rec.friday_yn    := coverage_times_recs(i).friday_yn;
                        END IF;
                        IF (new_coverage_times_rec.saturday_yn = 'N') THEN
                            new_coverage_times_rec.saturday_yn    := coverage_times_recs(i).saturday_yn;
                        END IF;
                        IF (new_coverage_times_rec.sunday_yn = 'N') THEN
                            new_coverage_times_rec.sunday_yn    := coverage_times_recs(i).sunday_yn;
                        END IF;
                    END IF; -- IF ( l_intervals_match_flag = 'Y' )
                END LOOP;
            END IF; -- IF coverage_times_recs.COUNT > 0
        END IF;
        -- set return status as success
        x_return_status := l_return_status;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'200: Leaving process_new_coverage_times');
        END IF;
   END; -- END OF process_new_coverage_times

  /**
   * Procedure invoked by the Middle-Tier application to initialize the GT table
   * with the new Coverage Times processed in the database.
   * @param cov_timezone_id Coverage Timezone Id
   */
   PROCEDURE init_coverage_times_view
   (    p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        cov_timezone_id         IN NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2)
    IS
      -- Procedure Name ussed for loggin
     l_api_name          CONSTANT VARCHAR2(30) := 'init_coverage_times_view';
     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

     CURSOR flattened_time_limits_cur IS
        SELECT
            to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) time,
            to_char(to_date(start_hour||':'||start_minute, 'HH24:MI'), 'HH24:MI') concatenate_time
        FROM OKS_COVERAGE_TIMES
        WHERE
            COV_TZE_LINE_ID = cov_timezone_id
        UNION ALL
        SELECT to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) time,
             to_char(to_date(end_hour||':'||end_minute, 'HH24:MI'), 'HH24:MI') concatenate_time
        FROM OKS_COVERAGE_TIMES
        WHERE
            COV_TZE_LINE_ID = cov_timezone_id
        ORDER BY time;

        -- Declaration of original Coverage Times table, read into this PL/SQL table
        coverage_times_recs ui_coverage_times_tbl;

        -- Declaration of original Coverage Times table, write into this PL/SQL table
        new_coverage_times_rec ui_coverage_times_rec;

        -- Declaration of original Coverage Times table, write into this PL/SQL table
        new_coverage_times_recs ui_coverage_times_tbl;

        -- Declaration of Flattened time limits table
        flattened_time_limits_recs flattened_time_limits_TBL;

        -- Enter the procedure variables here. As shown below
        start_time        NUMBER := -1;
        end_time          NUMBER := -1;
        flattened_st_end_limit_recs flattened_time_limits_TBL;
        j PLS_INTEGER := 0;
        is_timezone_exists VARCHAR2(1) := 'N';

   BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'100: Entered init_coverage_times_view');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'101: Coverage Time Zone Id'||cov_timezone_id);
        END IF;

        -- check if coverage times for the given timezone id is already been
        -- populated
        IF isTimezoneAlreadyProcessed(cov_timezone_id) = 'Y' THEN
            -- set return status as success
            x_return_status := l_return_status;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'200: Leaving init_coverage_times_view');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'201: Coverage Time Zone Id'||cov_timezone_id);
            END IF;
            return;
        END IF;

        -- Bulk collect coverage times for the given timezone id
        SELECT
            NVL(MONDAY_YN, 'N') MONDAY_YN,
            NVL(TUESDAY_YN, 'N') TUESDAY_YN,
            NVL(WEDNESDAY_YN, 'N') WEDNESDAY_YN,
            NVL(THURSDAY_YN, 'N') THURSDAY_YN,
            NVL(FRIDAY_YN, 'N') FRIDAY_YN,
            NVL(SATURDAY_YN, 'N') SATURDAY_YN,
            NVL(SUNDAY_YN, 'N') SUNDAY_YN,
            COV_TZE_LINE_ID,
            null start_time,
            null end_time,
            to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) START_HOUR_MINUTE,
            to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE))END_HOUR_MINUTE
             BULK COLLECT INTO coverage_times_recs
        FROM
            OKS_COVERAGE_TIMES
        WHERE
            COV_TZE_LINE_ID = cov_timezone_id
        ORDER BY start_hour asc;

        -- Fetch Flattened time limits
        OPEN  flattened_time_limits_cur;
        FETCH flattened_time_limits_cur BULK COLLECT INTO  flattened_time_limits_recs;
        IF flattened_time_limits_cur %ISOPEN THEN
          CLOSE flattened_time_limits_cur ;
        END IF;

        -- Loop Through Flattened time limits
        IF flattened_time_limits_recs.COUNT > 0 THEN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '103: Number of records in flattened_time_limits_recs :'||to_char(flattened_time_limits_recs.COUNT));
            END IF;

            j := 0;
            FOR i IN flattened_time_limits_recs.FIRST..flattened_time_limits_recs.LAST LOOP

                -- This implies that start_time and end_time variables are not set
                IF start_time = -1 AND end_time = -1 THEN

                    -- Get the first Start Limit into start_time
                    start_time := flattened_time_limits_recs(i).time;
                    flattened_st_end_limit_recs(0) := flattened_time_limits_recs(i);
                    -- and loop thru to get the next record

                ELSE -- enter this condition from second row onwards
                    -- set end_time
                    end_time := flattened_time_limits_recs(i).time;
                    flattened_st_end_limit_recs(1) := flattened_time_limits_recs(i);

                    -- If start_time and end_time limits are set
                    IF start_time <> -1 AND end_time <> -1 THEN

                        -- If start_time limit is not equal to end_time limit
                        IF start_time <> end_time THEN
                            -- navigate thru orginal coverage times records and
                            -- identify covered days for the given start and end
                            -- intervals
                            process_new_coverage_times(
                                flattened_st_end_limit_recs => flattened_st_end_limit_recs,
                                coverage_times_recs => coverage_times_recs,
                                new_coverage_times_rec => new_coverage_times_rec,
                                x_msg_data => x_msg_data,
                                x_msg_count => x_msg_count,
                                x_return_status => x_return_status);

                            -- Add New Coverage Time record to TBL of new Coverage Times
                            new_coverage_times_recs(j) := new_coverage_times_rec;
                            j := j+1;

                            -- reset start_time and end_time intervals
                            start_time := end_time;
                            end_time := -1;
                            flattened_st_end_limit_recs(0) := flattened_st_end_limit_recs(1);

                        END IF; -- IF start_time <> end_time
                    END IF; -- IF start_time <> -1 AND end_time <> -1
                END IF; -- IF end_time <> -1
            END LOOP;
        END IF; -- IF flattened_time_limits_recs.COUNT > 0

        -- Bulk Insert
        FORALL k IN new_coverage_times_recs.FIRST..new_coverage_times_recs.LAST
        INSERT INTO OKS_COVERAGE_TIMES_GT VALUES new_coverage_times_recs(k);

        -- set return status as success
        x_return_status := l_return_status;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'200: Leaving init_coverage_times_view');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'201: Coverage Time Zone Id'||cov_timezone_id);
        END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'1000: Leaving init_coverage_times_view with G_EXC_ERROR: '||
                substr(sqlerrm,1,200));
            END IF;
            IF flattened_time_limits_cur %ISOPEN THEN
              CLOSE flattened_time_limits_cur ;
            END IF;
            x_return_status := G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'1000: Leaving init_coverage_times_view with G_EXC_UNEXPECTED_ERROR :'||substr(sqlerrm,1,200));
            END IF;
            IF flattened_time_limits_cur %ISOPEN THEN
              CLOSE flattened_time_limits_cur ;
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data
            );

    WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,
                '1000: Leaving init_coverage_times_view with OTHER ERRORS :'||substr(sqlerrm,1,200));
            END IF;
            IF flattened_time_limits_cur %ISOPEN THEN
              CLOSE flattened_time_limits_cur ;
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME,l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(
              p_count =>  x_msg_count,
              p_data  =>  x_msg_data
            );

   END; -- END OF init_coverage_times_view

    /**
     * Returns Timezone value appended with (Default)
     * @param p_timezone_name Timezone name
     */
	FUNCTION Get_Default_Timezone_Msg
	(p_timezone_name  IN VARCHAR2) RETURN VARCHAR2 IS

  	BEGIN

  	    -- set message
  	    Fnd_Message.Set_Name( G_APP_NAME, G_COV_DEF_TZONE_MSG );

  	    -- set token
  	    Fnd_Message.Set_Token( token => G_COV_DEF_TZONE_MSG_TKN,
  	    					   value => p_timezone_name);

		return Fnd_Message.Get;

  	END; -- END OF Get_Default_Timezone_Msg

  -- End Added by SASETHI

END OKS_COVERAGE_UTIL_PVT;


/
