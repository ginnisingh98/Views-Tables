--------------------------------------------------------
--  DDL for Package Body CS_GET_REACTION_TIMES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_GET_REACTION_TIMES_PUB" AS
/* $Header: csctrtmb.pls 115.9 99/07/16 08:54:04 porting ship $ */

/*****************************************************************************/

  PROCEDURE Convert_To_Mts(
					  p_hours            IN  NUMBER,
					  p_minutes          IN  NUMBER,
					  x_all_minutes      OUT NUMBER)  IS
    l_all_minutes    NUMBER;
  BEGIN
    l_all_minutes    := (nvl(p_hours,0) * 60) + nvl(p_minutes,0);
    x_all_minutes    := l_all_minutes;
  END Convert_To_Mts;

/*****************************************************************************/

  PROCEDURE Convert_To_GMT(
					  p_time_zone_id     IN  NUMBER,
					  p_time_mts         IN  OUT NUMBER,
					  p_date			 IN	OUT DATE,
					  x_return_status    OUT VARCHAR2,
                           x_msg_count        OUT NUMBER,
                           x_msg_data         OUT VARCHAR2)  IS
    CURSOR   GMT_csr IS
    SELECT   TO_CHAR(TZ1.Offset_Time,'HH24') Offset_Hours,
		   TO_CHAR(TZ1.Offset_Time,'MI')   Offset_Mts,
		   TZ1.Offset_Indicator            Offset_Indicator
    FROM     CS_TIME_ZONES                   TZ1
    WHERE    TZ1.Time_Zone_Id              = p_time_zone_id;

    l_offset_hours       NUMBER;
    l_offset_mts         NUMBER;
    l_offset_all_mts     NUMBER;
    l_offset_indicator   VARCHAR2(2);
  BEGIN
    OPEN     GMT_csr;
    FETCH    GMT_csr
    INTO     l_offset_hours,
		   l_offset_mts,
		   l_offset_indicator;

    IF GMT_csr%NOTFOUND THEN
	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	 FND_MESSAGE.Set_Token('VALUE','TIME ZONE');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE    GMT_csr;

-- DBMS_Output.Put_Line('Offset Hours='|| to_char(l_offset_hours));
-- DBMS_Output.Put_Line('Offset Mts='|| to_char(l_offset_mts));

    Convert_to_Mts (l_offset_hours,
				l_offset_mts,
				l_offset_all_mts);

--DBMS_Output.Put_Line('Offset All Mts='|| to_char(l_offset_all_mts));

    IF l_offset_indicator = '+'  THEN
	 p_time_mts     := p_time_mts       + l_offset_all_mts;
	 /**
	 while (p_time_mts > 24*60) Loop
		p_time_mts := p_time_mts - (24*60);
		p_date	:= p_date + 1;
	 END LOOP;
	 **/
    ELSE
	   p_time_mts   := p_time_mts       - l_offset_all_mts;
	   /***
	   While (p_time_mts < 0) LOOP
	   	p_time_mts   := p_time_mts + (24*60) ;
		p_date       := p_date + 1;
	   END LOOP;
	   **/
    END IF;

  END Convert_To_GMT;

  PROCEDURE Convert_FROM_GMT(
					  p_time_zone_id     IN  NUMBER,
					  p_time_mts         IN  OUT NUMBER,
					  p_date			 IN	OUT DATE,
					  x_return_status    OUT VARCHAR2,
                           x_msg_count        OUT NUMBER,
                           x_msg_data         OUT VARCHAR2)  IS
    CURSOR   GMT_csr IS
    SELECT   TO_CHAR(TZ1.Offset_Time,'HH24') Offset_Hours,
		   TO_CHAR(TZ1.Offset_Time,'MI')   Offset_Mts,
		   TZ1.Offset_Indicator            Offset_Indicator
    FROM     CS_TIME_ZONES                   TZ1
    WHERE    TZ1.Time_Zone_Id              = p_time_zone_id;

    l_offset_hours       NUMBER;
    l_offset_mts         NUMBER;
    l_offset_all_mts     NUMBER;
    l_offset_indicator   VARCHAR2(2);
  BEGIN
    OPEN     GMT_csr;
    FETCH    GMT_csr
    INTO     l_offset_hours,
		   l_offset_mts,
		   l_offset_indicator;

    IF GMT_csr%NOTFOUND THEN
	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	 FND_MESSAGE.Set_Token('VALUE','TIME ZONE');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE    GMT_csr;

    Convert_to_Mts (l_offset_hours,
				l_offset_mts,
				l_offset_all_mts);

--DBMS_Output.Put_Line('Convert from GMT Offset='|| to_char(l_offset_all_mts));
--DBMS_Output.Put_Line('Offset Indicator='|| l_offset_indicator);

    IF l_offset_indicator = '+'  THEN
	 p_time_mts     := p_time_mts       - l_offset_all_mts;
	 /***
	 while (p_time_mts > 24*60) Loop
		p_time_mts := p_time_mts + (24*60);
		p_date	:= p_date + 1;
	 END LOOP;
	 ***/
    ELSE
	   p_time_mts   := p_time_mts       + l_offset_all_mts;
	   IF (p_time_mts < 0) THEN
		p_time_mts := p_time_mts * -1;
	   END IF;
	   /***
	   While (p_time_mts < 0) LOOP
	   	p_time_mts   := p_time_mts - (24*60) ;
		p_date       := p_date - 1;
	   END LOOP;
	   ***/
    END IF;

  END Convert_FROM_GMT;

/*****************************************************************************/

  PROCEDURE Convert_To_Hours_Mts(
					  p_end_time_all_mts    IN  NUMBER,
					  x_end_time_hours      OUT NUMBER,
					  x_end_time_mts        OUT NUMBER)  IS
  BEGIN
    x_end_time_hours := TRUNC(p_end_time_all_mts / 60);
    x_end_time_mts   := MOD(p_end_time_all_mts, 60);
  END Convert_To_Hours_Mts;

/*****************************************************************************/

  PROCEDURE Get_Next_Days_Coverage_Time(
					p_coverage_txn_group_id   IN  NUMBER,
					p_coverage_day   		 IN  OUT NUMBER,
                         x_cov_start_time_hours    OUT NUMBER,
                         x_cov_start_time_mts      OUT NUMBER,
                         x_cov_end_time_hours      OUT NUMBER,
                         x_cov_end_time_mts        OUT NUMBER,
					x_return_status           OUT VARCHAR2,
                         x_msg_count               OUT NUMBER,
                         x_msg_data                OUT VARCHAR2)  IS

  CURSOR     Coverage_Time_csr IS
    SELECT   Decode(p_coverage_day,
				1, To_Char(TXN.Sunday_Start_Time   ,'HH24'),
				2, To_Char(TXN.Monday_Start_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_Start_Time,'HH24'),
				5, To_Char(TXN.Thursday_Start_Time ,'HH24'),
				6, To_Char(TXN.Friday_Start_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_Start_Time ,'HH24'))
							Cov_Start_Time_Hours,
		   Decode(p_coverage_day,
				1, To_Char(TXN.Sunday_Start_Time   ,'MI'),
				2, To_Char(TXN.Monday_Start_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_Start_Time,'MI'),
				5, To_Char(TXN.Thursday_Start_Time ,'MI'),
				6, To_Char(TXN.Friday_Start_Time   ,'MI'),
				7, To_Char(TXN.Saturday_Start_Time ,'MI'))
							Cov_Start_Time_Mts,
		   Decode(p_coverage_day,
				1, To_Char(TXN.Sunday_End_Time   ,'HH24'),
				2, To_Char(TXN.Monday_End_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_End_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_End_Time,'HH24'),
				5, To_Char(TXN.Thursday_End_Time ,'HH24'),
				6, To_Char(TXN.Friday_End_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_End_Time ,'HH24'))
							Cov_End_Time_Hours,
		   Decode(p_coverage_day,
				1, To_Char(TXN.Sunday_End_Time   ,'MI'),
				2, To_Char(TXN.Monday_End_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_End_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_End_Time,'MI'),
				5, To_Char(TXN.Thursday_End_Time ,'MI'),
				6, To_Char(TXN.Friday_End_Time   ,'MI'),
				7, To_Char(TXN.Saturday_End_Time ,'MI'))
							Cov_End_Time_Mts
    FROM     CS_COVERAGE_TXN_GROUPS	TXN
    WHERE    TXN.Coverage_Txn_Group_Id = P_Coverage_Txn_Group_Id;
  BEGIN

-- DBMS_Output.Put_Line('In get next days coverage');

    p_coverage_day           :=  p_coverage_day + 1;
    IF (NVL(p_coverage_day,8) >  7) THEN
	 p_coverage_day         :=  1;

--     DBMS_Output.Put_Line('coverage day=1');
    END IF;

    OPEN     Coverage_Time_csr;
    FETCH    Coverage_Time_csr
    INTO     x_cov_start_time_hours,
		   x_cov_start_time_mts,
		   x_cov_end_time_hours,
		   x_cov_end_time_mts;

-- DBMS_Output.Put_Line('Fetched cov. start and end');

    IF Coverage_Time_csr%NOTFOUND THEN
	 FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	 FND_MESSAGE.Set_Token('VALUE','COVERAGE TIMES');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE    Coverage_Time_csr;

-- DBMS_Output.Put_Line('End of Get Next days coverage');

  END Get_Next_Days_Coverage_Time;

/*****************************************************************************/

  -- Start of comments
  -- API name            : Get_Reaction_Times
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This procedure returns the reaction times as defined
  --                       for the specified transaction group within the contract.
  --                       It also calculates the expected completion time based
  --                       upon the coverage and reaction times as defined.
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_coverage_id             NUMBER    Required
  --                         p_business_process_id     NUMBER    Required
  --                         p_start_date_time         DATE      Required
  --                         p_call_time_zone_id       NUMBER    Required
  --           		    p_incident_severity_id    NUMBER    Required
  --                         p_exception_coverage_flag VARCHAR2
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  -- IN OUT              :
  --        		         p_Reaction_time_id        NUMBER
  -- OUT                 :
  --        		         x_Reaction_time           VARCHAR2
  --                         x_Reaction_time_Sunday    NUMBER
  --                         x_Reaction_time_Monday    NUMBER
  --                         x_Reaction_time_Tuesday   NUMBER
  --                         x_Reaction_time_Wednesday NUMBER
  --                         x_Reaction_time_Thursday  NUMBER
  --                         x_Reaction_time_Friday    NUMBER
  --                         x_Reaction_time_Saturday  NUMBER
  --                         x_Worckflow               VARCHAR2
  --                         x_always_covered          VARCHAR2
  --           		    x_incident_severity       VARCHAR2
  --                         x_Expected_End_Date_Time  DATE
  --                         x_Use_for_SR_Date_Calc    VARCHAR2
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

  PROCEDURE Get_Reaction_Times (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
                p_business_process_id     IN  NUMBER,
                p_start_date_time         IN  DATE,
                p_call_time_zone_id       IN  NUMBER,
			 p_incident_severity_id    IN  NUMBER,
                p_exception_coverage_flag IN  VARCHAR2,
		      p_Reaction_time_id        IN OUT NUMBER,
		      x_Reaction_time           OUT VARCHAR2,
                x_Reaction_time_Sunday    OUT NUMBER,
                x_Reaction_time_Monday    OUT NUMBER,
                x_Reaction_time_Tuesday   OUT NUMBER,
                x_Reaction_time_Wednesday OUT NUMBER,
                x_Reaction_time_Thursday  OUT NUMBER,
                x_Reaction_time_Friday    OUT NUMBER,
                x_Reaction_time_Saturday  OUT NUMBER,
                x_Workflow                OUT VARCHAR2,
                x_always_covered          OUT VARCHAR2,
			 x_incident_severity       OUT VARCHAR2,
                x_Expected_End_Date_Time  OUT DATE,
                x_Use_for_SR_Date_Calc    OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  ) IS

    l_coverage_id               CS_COVERAGES.COVERAGE_ID%TYPE;

    CURSOR   Reaction_Times_csr IS
    SELECT   CRT.Reaction_time_id,
		   CRT.Name             Reaction_Time,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
					 1, CRT.Reaction_Time_Sunday   ,
					 2, CRT.Reaction_Time_Monday   ,
					 3, CRT.Reaction_Time_Tuesday  ,
					 4, CRT.Reaction_Time_Wednesday,
					 5, CRT.Reaction_Time_Thursday ,
					 6, CRT.Reaction_Time_Friday   ,
					 7, CRT.Reaction_Time_Saturday) Reaction_Time,
             To_Char(p_start_date_time,'HH24') Start_Time_Hours,
             To_Char(p_start_date_time,'MI')   Start_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
				1, SUBSTR(CRT.Reaction_Time_Sunday,1,
							LENGTH(CRT.Reaction_Time_Sunday) - 2),
				2, SUBSTR(CRT.Reaction_Time_Monday,1,
							LENGTH(CRT.Reaction_Time_Monday) - 2),
				3, SUBSTR(CRT.Reaction_Time_Tuesday,1,
							LENGTH(CRT.Reaction_Time_Tuesday) - 2),
				4, SUBSTR(CRT.Reaction_Time_Wednesday,1,
							LENGTH(CRT.Reaction_Time_Wednesday) - 2),
				5, SUBSTR(CRT.Reaction_Time_Thursday,1,
							LENGTH(CRT.Reaction_Time_Thursday ) - 2),
				6, SUBSTR(CRT.Reaction_Time_Friday,1,
							LENGTH(CRT.Reaction_Time_Friday   ) - 2),
				7, SUBSTR(CRT.Reaction_Time_Saturday,1,
							LENGTH(CRT.Reaction_Time_Saturday) - 2))
							Reaction_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
				1, SUBSTR(CRT.Reaction_Time_Sunday,
							LENGTH(CRT.Reaction_Time_Sunday   ) - 1,2),
				2, SUBSTR(CRT.Reaction_Time_Monday,
							LENGTH(CRT.Reaction_Time_Monday   ) - 1,2),
				3, SUBSTR(CRT.Reaction_Time_Tuesday,
							LENGTH(CRT.Reaction_Time_Tuesday  ) - 1,2),
				4, SUBSTR(CRT.Reaction_Time_Wednesday,
							LENGTH(CRT.Reaction_Time_Wednesday) - 1,2),
				5, SUBSTR(CRT.Reaction_Time_Thursday,
							LENGTH(CRT.Reaction_Time_Thursday ) - 1,2),
				6, SUBSTR(CRT.Reaction_Time_Friday,
							LENGTH(CRT.Reaction_Time_Friday   ) - 1,2),
				7, SUBSTR(CRT.Reaction_Time_Saturday,
							LENGTH(CRT.Reaction_Time_Saturday) - 1,2))
							Reaction_Time_Mts,
		   CRT.Reaction_Time_Sunday   ,
	        CRT.Reaction_Time_Monday   ,
		   CRT.Reaction_Time_Tuesday  ,
		   CRT.Reaction_Time_Wednesday,
		   CRT.Reaction_Time_Thursday ,
		   CRT.Reaction_Time_Friday   ,
		   CRT.Reaction_Time_Saturday ,
		   CRT.Workflow               ,
		   INS.Name                   Incident_Severity,
		   CRT.Always_Covered         ,
		   CRT.Use_for_SR_Date_Calc   ,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_Start_Time   ,'HH24'),
				2, To_Char(TXN.Monday_Start_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_Start_Time,'HH24'),
				5, To_Char(TXN.Thursday_Start_Time ,'HH24'),
				6, To_Char(TXN.Friday_Start_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_Start_Time ,'HH24'))
				Cov_Start_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_Start_Time   ,'MI'),
				2, To_Char(TXN.Monday_Start_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_Start_Time,'MI'),
				5, To_Char(TXN.Thursday_Start_Time ,'MI'),
				6, To_Char(TXN.Friday_Start_Time   ,'MI'),
				7, To_Char(TXN.Saturday_Start_Time ,'MI'))
				Cov_Start_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_End_Time   ,'HH24'),
				2, To_Char(TXN.Monday_End_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_End_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_End_Time,'HH24'),
				5, To_Char(TXN.Thursday_End_Time ,'HH24'),
				6, To_Char(TXN.Friday_End_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_End_Time ,'HH24'))
				Cov_End_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_End_Time   ,'MI'),
				2, To_Char(TXN.Monday_End_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_End_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_End_Time,'MI'),
				5, To_Char(TXN.Thursday_End_Time ,'MI'),
				6, To_Char(TXN.Friday_End_Time   ,'MI'),
				7, To_Char(TXN.Saturday_End_Time ,'MI'))
				Cov_End_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, 1,
				2, 2,
				3, 3,
				4, 4,
				5, 5,
				6, 6,
				7, 7),
		   TXN.Time_Zone_Id      ,
		   TXN.Coverage_Txn_Group_Id
    FROM     CS_COV_REACTION_TIMES           CRT,
		   CS_INCIDENT_SEVERITIES          INS,
		   CS_COVERAGES                    COV,
		   CS_COVERAGE_TXN_GROUPS          TXN
    WHERE    COV.Coverage_id             = l_coverage_id
    AND      COV.Coverage_id             = TXN.Coverage_id
    AND      TXN.Business_Process_Id     = p_business_process_id
    AND      TXN.Coverage_Txn_Group_Id   = CRT.Coverage_Txn_Group_Id
    AND      CRT.Incident_Severity_Id    = p_incident_severity_id
    AND      CRT.Use_For_SR_Date_Calc    = 'Y'
    AND      CRT.Incident_Severity_Id    = INS.Incident_Severity_Id(+);


    CURSOR   Reaction_Times_id_csr IS
    SELECT   CRT.Name             Reaction_Time,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
					 1, CRT.Reaction_Time_Sunday   ,
					 2, CRT.Reaction_Time_Monday   ,
					 3, CRT.Reaction_Time_Tuesday  ,
					 4, CRT.Reaction_Time_Wednesday,
					 5, CRT.Reaction_Time_Thursday ,
					 6, CRT.Reaction_Time_Friday   ,
					 7, CRT.Reaction_Time_Saturday) Reaction_Time,
             To_Char(p_start_date_time,'HH24') Start_Time_Hours,
             To_Char(p_start_date_time,'MI')   Start_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
				1, SUBSTR(CRT.Reaction_Time_Sunday,1,
						LENGTH(CRT.Reaction_Time_Sunday) - 2),
				2, SUBSTR(CRT.Reaction_Time_Monday,1,
						LENGTH(CRT.Reaction_Time_Monday) - 2),
				3, SUBSTR(CRT.Reaction_Time_Tuesday,1,
						LENGTH(CRT.Reaction_Time_Tuesday) - 2),
				4, SUBSTR(CRT.Reaction_Time_Wednesday,1,
						LENGTH(CRT.Reaction_Time_Wednesday) - 2),
				5, SUBSTR(CRT.Reaction_Time_Thursday,1,
						LENGTH(CRT.Reaction_Time_Thursday ) - 2),
				6, SUBSTR(CRT.Reaction_Time_Friday,1,
						LENGTH(CRT.Reaction_Time_Friday   ) - 2),
				7, SUBSTR(CRT.Reaction_Time_Saturday,1,
						LENGTH(CRT.Reaction_Time_Saturday) - 2))
								Reaction_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_start_date_time),'D'),
				1, SUBSTR(CRT.Reaction_Time_Sunday,
						LENGTH(CRT.Reaction_Time_Sunday   ) - 1,2),
				2, SUBSTR(CRT.Reaction_Time_Monday,
						LENGTH(CRT.Reaction_Time_Monday   ) - 1,2),
				3, SUBSTR(CRT.Reaction_Time_Tuesday,
						LENGTH(CRT.Reaction_Time_Tuesday  ) - 1,2),
				4, SUBSTR(CRT.Reaction_Time_Wednesday,
						LENGTH(CRT.Reaction_Time_Wednesday) - 1,2),
				5, SUBSTR(CRT.Reaction_Time_Thursday,
						LENGTH(CRT.Reaction_Time_Thursday ) - 1,2),
				6, SUBSTR(CRT.Reaction_Time_Friday,
						LENGTH(CRT.Reaction_Time_Friday   ) - 1,2),
				7, SUBSTR(CRT.Reaction_Time_Saturday,
						LENGTH(CRT.Reaction_Time_Saturday) - 1,2))
								Reaction_Time_Mts,
		   CRT.Reaction_Time_Sunday   ,
	        CRT.Reaction_Time_Monday   ,
		   CRT.Reaction_Time_Tuesday  ,
		   CRT.Reaction_Time_Wednesday,
		   CRT.Reaction_Time_Thursday ,
		   CRT.Reaction_Time_Friday   ,
		   CRT.Reaction_Time_Saturday ,
		   CRT.Workflow               ,
		   INS.Name                   Incident_Severity,
		   CRT.Always_Covered         ,
		   CRT.Use_for_SR_Date_Calc   ,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_Start_Time   ,'HH24'),
				2, To_Char(TXN.Monday_Start_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_Start_Time,'HH24'),
				5, To_Char(TXN.Thursday_Start_Time ,'HH24'),
				6, To_Char(TXN.Friday_Start_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_Start_Time ,'HH24'))
						Cov_Start_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_Start_Time   ,'MI'),
				2, To_Char(TXN.Monday_Start_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_Start_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_Start_Time,'MI'),
				5, To_Char(TXN.Thursday_Start_Time ,'MI'),
				6, To_Char(TXN.Friday_Start_Time   ,'MI'),
				7, To_Char(TXN.Saturday_Start_Time ,'MI'))
						Cov_Start_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_End_Time   ,'HH24'),
				2, To_Char(TXN.Monday_End_Time   ,'HH24'),
				3, To_Char(TXN.Tuesday_End_Time  ,'HH24'),
				4, To_Char(TXN.Wednesday_End_Time,'HH24'),
				5, To_Char(TXN.Thursday_End_Time ,'HH24'),
				6, To_Char(TXN.Friday_End_Time   ,'HH24'),
				7, To_Char(TXN.Saturday_End_Time ,'HH24'))
						Cov_End_Time_Hours,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, To_Char(TXN.Sunday_End_Time   ,'MI'),
				2, To_Char(TXN.Monday_End_Time   ,'MI'),
				3, To_Char(TXN.Tuesday_End_Time  ,'MI'),
				4, To_Char(TXN.Wednesday_End_Time,'MI'),
				5, To_Char(TXN.Thursday_End_Time ,'MI'),
				6, To_Char(TXN.Friday_End_Time   ,'MI'),
				7, To_Char(TXN.Saturday_End_Time ,'MI'))
						Cov_End_Time_Mts,
		   Decode(TO_CHAR(TO_DATE(p_Start_date_time),'D'),
				1, 1,
				2, 2,
				3, 3,
				4, 4,
				5, 5,
				6, 6,
				7, 7),
		   TXN.Time_Zone_Id       ,
		   TXN.Coverage_Txn_Group_Id
    FROM     CS_COV_REACTION_TIMES           CRT,
		   CS_INCIDENT_SEVERITIES          INS,
		   CS_COVERAGES                    COV,
		   CS_COVERAGE_TXN_GROUPS          TXN
    WHERE    COV.Coverage_id             = l_coverage_id
    AND      COV.Coverage_id             = TXN.Coverage_id
    AND      TXN.Business_Process_Id     = p_business_process_id
    AND      TXN.Coverage_Txn_Group_Id   = CRT.Coverage_Txn_Group_Id
    AND      CRT.Reaction_time_id        = p_reaction_time_id
    AND      CRT.Use_For_SR_Date_Calc    = 'Y'
    AND      CRT.Incident_Severity_Id    = INS.Incident_Severity_Id(+);



    l_api_name         CONSTANT  VARCHAR2(30)  := 'Get_Reaction_Times';
    l_api_version      CONSTANT  NUMBER        := 1;
    l_return_status              VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_start_time                 DATE;
    l_end_time                   DATE;
    l_end_time_all_mts           NUMBER;
    l_start_time_all_mts         NUMBER;
    l_end_time_mts               NUMBER;
    l_start_time_mts             NUMBER;
    l_end_time_hours             NUMBER;
    l_start_time_hours           NUMBER;
    l_day                        NUMBER;
    l_reaction_time              NUMBER;
    l_reaction_time_hours        NUMBER;
    l_reaction_time_mts          NUMBER;
    l_reaction_time_all_mts      NUMBER;
    l_cov_start_time_hours       NUMBER;
    l_cov_end_time_hours         NUMBER;
    l_cov_start_time_mts         NUMBER;
    l_cov_end_time_mts           NUMBER;
    l_cov_start_time_all_mts     NUMBER;
    l_cov_end_time_all_mts       NUMBER;
    l_coverage_day               NUMBER;
    l_rtm_diff                   NUMBER;
    l_cov_diff                   NUMBER;
    l_end_date_time              DATE;
    l_time_zone_id               NUMBER;
    l_coverage_txn_group_id		NUMBER;
    l_count					NUMBER;
    l_reaction_time_used			NUMBER;
    l_reaction_time_remaining		NUMBER;
	l_loop_count				NUMBER;
	l_time_diff				NUMBER;

  BEGIN
    l_return_status   := TAPI_DEV_KIT.START_ACTIVITY(  l_api_name,
                                                       G_PKG_NAME,
                                                       l_api_version,
                                                       p_api_version,
                                                       p_init_msg_list,
                                                       '_pub',
                                                       x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (NVL(p_exception_coverage_flag,'N') = 'Y') THEN
	 CS_GET_COVERAGE_VALUES_PUB.Get_Exception_Coverage(
					 					      1,
										      FND_API.G_FALSE,
										      FND_API.G_FALSE,
										      p_coverage_id,
										      l_coverage_id,
										      x_return_status,
										      x_msg_count,
										      x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','EXCEPTION COVERAGE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
	 l_coverage_id := p_coverage_id;
    END IF;

    IF (p_reaction_time_id IS NOT NULL)  THEN
      OPEN     Reaction_Times_id_csr;
      FETCH    Reaction_Times_id_csr
      INTO     x_reaction_time              ,
		     l_reaction_time              ,
		     l_start_time_hours           ,
		     l_start_time_mts             ,
		     l_reaction_time_hours        ,
		     l_reaction_time_mts          ,
		     x_reaction_time_sunday       ,
		     x_reaction_time_monday       ,
		     x_reaction_time_tuesday      ,
		     x_reaction_time_wednesday    ,
		     x_reaction_time_thursday     ,
		     x_reaction_time_friday       ,
		     x_reaction_time_saturday     ,
		     x_workflow                   ,
		     x_incident_severity          ,
		     x_always_covered             ,
		     x_use_for_SR_date_calc       ,
		     l_cov_start_time_hours       ,
		     l_cov_start_time_mts         ,
		     l_cov_end_time_hours         ,
		     l_cov_end_time_mts           ,
		     l_coverage_day               ,
               l_time_zone_id               ,
			l_coverage_txn_group_id		;


      IF Reaction_Times_id_csr%NOTFOUND THEN
        CLOSE Reaction_Times_id_csr;
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','REACTION TIMES ID');
        TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                                  x_msg_count,
                                  x_msg_data);
        x_return_status  := FND_API.G_RET_STS_ERROR;
	   RETURN;
      END IF;
      CLOSE Reaction_Times_id_csr;
    ELSE
-- DBMS_Output.Put_line('Reaction time id is null');
      OPEN     Reaction_Times_csr;
      FETCH    Reaction_Times_csr
      INTO     p_reaction_time_id           ,
			x_reaction_time              ,
		     l_reaction_time              ,
		     l_start_time_hours           ,
		     l_start_time_mts             ,
		     l_reaction_time_hours        ,
		     l_reaction_time_mts          ,
		     x_reaction_time_sunday       ,
		     x_reaction_time_monday       ,
		     x_reaction_time_tuesday      ,
		     x_reaction_time_wednesday    ,
		     x_reaction_time_thursday     ,
		     x_reaction_time_friday       ,
		     x_reaction_time_saturday     ,
		     x_workflow                   ,
		     x_incident_severity          ,
		     x_always_covered             ,
		     x_use_for_SR_date_calc       ,
		     l_cov_start_time_hours       ,
		     l_cov_start_time_mts         ,
		     l_cov_end_time_hours         ,
		     l_cov_end_time_mts           ,
		     l_coverage_day               ,
               l_time_zone_id               ,
			l_coverage_txn_group_id		;

      IF Reaction_Times_csr%NOTFOUND THEN
        CLOSE Reaction_Times_csr;
	   FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
	   FND_MESSAGE.Set_Token('VALUE','REACTION TIMES');
        TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                                  x_msg_count,
                                  x_msg_data);
        x_return_status  := FND_API.G_RET_STS_ERROR;
	   RETURN;
      END IF;
      CLOSE Reaction_Times_csr;
    END IF;

/***
DBMS_Output.Put_Line('Obtained values. Reaction time='|| x_reaction_time);
DBMS_Output.Put_Line('Start time hh=' || to_char(l_start_time_hours) ||
				' mts=' || to_char(l_start_time_mts) );
DBMS_Output.Put_Line('Reaction time hours=' || to_char(l_reaction_time_hours) ||
				 ' mts=' || to_char(l_reaction_time_mts));
DBMS_Output.Put_Line('Coverage_Day='|| to_char(l_coverage_day));
DBMS_Output.Put_Line('Cov start time hh=' || to_char(l_cov_start_time_hours) ||
				' mts=' || to_char(l_cov_start_time_mts));
DBMS_Output.Put_Line('Cov end time hh=' || to_char(l_cov_end_time_hours) ||
				' mts=' || to_char(l_cov_end_time_mts));
***/

    Convert_to_Mts( l_start_time_hours,
				l_start_time_mts,
				l_start_time_all_mts);

  	Convert_to_Mts( l_reaction_time_hours,
						l_reaction_time_mts,
						l_reaction_time_all_mts);

    /*** If coverage Start and End time is not null then
    convert to minutes **/

    /****
    IF ((NVL(l_cov_start_time_hours,0) <> 0)  OR
	    (NVL(l_cov_start_time_mts,0) <> 0)   ) AND
       ((NVL(l_cov_end_time_hours,0) <> 0)  OR
	    (NVL(l_cov_end_time_mts,0) <> 0)    ) THEN
	    ****/
      Convert_to_Mts( l_cov_start_time_hours,
				  l_cov_start_time_mts,
				  l_cov_start_time_all_mts);
      Convert_to_Mts( l_cov_end_time_hours,
				  l_cov_end_time_mts,
				  l_cov_end_time_all_mts);
	/****
	ELSE
		l_cov_start_time_all_mts  := 0;
		l_cov_end_time_all_mts := 0;

    END IF;
    ****/

    l_end_date_time      := p_start_date_time;

/***
DBMS_Output.PUT_LINE('1.Reaction time all mts='||
					to_char(l_reaction_time_all_mts));
DBMS_Output.PUT_LINE('1.Start time all mts='||
					to_char(l_start_time_all_mts));
DBMS_OUtput.Put_Line('1.Coverage start time='||
					to_char(l_cov_start_time_all_Mts));
DBMS_OUtput.Put_Line('1.Coverage End time='||
					to_char(l_cov_end_time_all_Mts));
***/

	l_loop_count	:= 0;

	WHILE ((( l_loop_count < 6 ) AND
		  ( l_cov_start_time_all_mts = 0) AND
		  ( l_cov_end_time_all_mts   = 0))  AND
		  ( l_reaction_time_all_mts <> 0 ))
	LOOP
--	DBMS_Output.Put_Line('In while loop=' || to_char(l_loop_count));
		Get_Next_Days_Coverage_Time(
						l_coverage_txn_group_id,
						l_coverage_day,
						l_cov_start_time_hours,
						l_cov_start_time_mts,
						l_cov_end_time_hours,
						l_cov_end_time_mts,
						x_return_status,
						x_msg_count,
						x_msg_data);

		convert_to_mts(l_cov_start_time_hours,
					l_cov_start_time_mts,
					l_cov_start_time_all_mts);

		convert_to_mts(l_cov_end_time_hours,
					l_cov_end_time_mts,
					l_cov_end_time_all_mts);

		l_loop_count := l_loop_count + 1;

		l_start_time_all_mts := l_cov_start_time_all_mts;

    		l_end_date_time      := l_end_date_time + 1;

--	DBMS_Output.Put_Line('Cov. start time=' || to_char(l_cov_start_time_all_mts));

	END LOOP;


    IF (NVL(l_time_zone_id,0)  <> 0      )  AND
        (p_call_time_zone_id  <> l_time_zone_id)  THEN

--DBMS_Output.Put_Line('l_time zone=' || to_char(l_time_zone_id));
		Convert_To_GMT(p_call_time_zone_id,
				  	l_start_time_all_mts,
					l_end_date_time,
				  	x_return_status,
                        	x_msg_count,
                        	x_msg_data);

           Convert_To_GMT(l_time_zone_id,
				  	l_cov_start_time_all_mts,
					l_end_date_time,
				  	x_return_status,
              			x_msg_count,
                        	x_msg_data);

		Convert_To_GMT(l_time_zone_id,
				  	l_cov_end_time_all_mts,
					l_end_date_time,
				  	x_return_status,
                         x_msg_count,
                         x_msg_data);
	END IF;


    /** Perform calculation only if always covered is
	not 'Y' and coverage start and end times are
	not null ***/

/***
DBMS_Output.Put_Line('Reaction time all mts=' ||
							to_char(l_reaction_time_all_mts));
**/

	l_time_diff := l_cov_end_time_all_mts - l_cov_start_time_all_mts;

-- DBMS_Output.Put_Line('Cov. End - Cov. Start='||
-- 						to_char(l_time_diff));

    IF ((x_always_covered     <> 'Y')  AND
	   (l_cov_end_time_all_mts <>0 )  AND
	   (l_cov_start_time_all_mts <>0 )  AND
        (l_time_diff < l_reaction_time_all_mts ))  THEN

 -- DBMS_Output.Put_Line('Start time='|| to_char(l_start_time_all_mts));

		IF (l_start_time_all_mts > l_cov_end_time_all_mts ) THEN
-- DBMS_Output.Put_Line('Getting next days coverage');
			Get_Next_Days_Coverage_Time(l_coverage_txn_group_id,
							 l_coverage_day,
							 l_cov_start_time_hours,
							 l_cov_start_time_mts,
							 l_cov_end_time_hours,
							 l_cov_end_time_mts,
						      x_return_status,
                                    x_msg_count,
                                    x_msg_data);

        		l_end_date_time            := l_end_date_time + 1;

			IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
				FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
				FND_MESSAGE.Set_Token('VALUE','NEXT DAY COVERAGE');
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
				FND_MESSAGE.Set_Name ('CS','CS_CONTRACTS_VALUE_NOT_FOUND');
				FND_MESSAGE.Set_Token('VALUE','NEXT DAY COVERAGE');
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			convert_to_mts(l_cov_start_time_hours,
	                    l_cov_start_time_mts,
				     l_cov_start_time_all_mts);

        		convert_to_mts(l_cov_end_time_hours,
			          l_cov_end_time_mts,
				     l_cov_end_time_all_mts);

          	IF (l_time_zone_id  IS NOT NULL      )  AND
	        	(p_call_time_zone_id  <> l_time_zone_id)  THEN

            		Convert_To_GMT(l_time_zone_id,
						  	l_cov_start_time_all_mts,
							l_end_date_time,
						  	x_return_status,
              	             	x_msg_count,
              	             	x_msg_data);

            		Convert_To_GMT(l_time_zone_id,
						  	l_cov_end_time_all_mts,
							l_end_date_time,
						  	x_return_status,
              	             	x_msg_count,
              	             	x_msg_data);
            		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)  THEN
	         			FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
	         			FND_MESSAGE.Set_Token('VALUE','CONVERT TO GMT');
              			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
	         			FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
	         			FND_MESSAGE.Set_Token('VALUE','CONVERT TO GMT');
              			RAISE FND_API.G_EXC_ERROR;
            		END IF;
			END If;

			l_start_time_all_mts := l_cov_start_time_all_mts;
-- DBMS_Output.Put_Line('IN here Start time='|| to_char(l_start_time_all_mts));

		 END IF;

/***
DBMS_Output.Put_Line('Reaction time='|| to_char(l_reaction_time_all_mts));
DBMS_Output.Put_Line('Start time='|| to_char(l_start_time_all_mts));
DBMS_Output.Put_Line('Cov start='|| to_char(l_cov_start_time_all_mts));
DBMS_Output.Put_Line('Cov end='|| to_char(l_cov_end_time_all_mts));
**/

			l_cov_diff	:= l_cov_end_time_all_mts
							- l_cov_start_time_all_mts;
			l_reaction_time_used := l_cov_end_time_all_mts
								 - l_start_time_all_mts;
			l_reaction_time_remaining := l_reaction_time_all_mts
								- l_reaction_time_used;

			IF (l_reaction_time_remaining <= 0) THEN
				l_end_time_all_mts := l_start_time_all_mts
						+ l_reactioN_time_all_mts;
-- DBMS_OUTPUT.PUT_LINE('In one day end time=' || to_char(l_end_time_all_mts));
				IF (p_call_time_zone_id <> l_time_zone_id) THEN
					Convert_From_GMT( p_call_time_zone_id,
						  		l_end_time_all_mts,
								l_end_date_time,
						  		x_return_status,
                        		   		x_msg_count,
                        		   		x_msg_data);

/***
DBMS_OUTPUT.Put_LIne('Converted from GMT. end time='||
							to_char(l_end_time_all_mts));
**/
				END IF;
			ELSE
			/***
			DBMS_Output.Put_Line('2.RT Used='||
						to_char(l_reaction_time_used));
			DBMS_Output.Put_Line('2.RT Remaining='||
						to_char(l_reaction_time_remaining));
						***/
			while (l_reaction_time_remaining > 0) LOOP
						Get_Next_Days_Coverage_Time(
							l_coverage_txn_group_id,
							 l_coverage_day,
							 l_cov_start_time_hours,
							 l_cov_start_time_mts,
							 l_cov_end_time_hours,
							 l_cov_end_time_mts,
						      x_return_status,
                                    x_msg_count,
                                    x_msg_data);
/**
DBMS_Output.PUt_Line('Back from Next days cov date='||
					to_char(l_end_date_time, 'DD-MON-RR HH24:MI'));
***/

        					l_end_date_time  := l_end_date_time + 1;
/***
DBMS_Output.Put_Line('End date time='||
					to_char(l_end_date_time, 'DD-MON-RR HH24:MI'));
**/

						IF (x_return_status =
								FND_API.G_RET_STS_UNEXP_ERROR)  THEN
							FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
							FND_MESSAGE.Set_Token('VALUE','
									NEXT DAY COVERAGE');
							RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
						ELSIF(x_return_status = FND_API.G_RET_STS_ERROR)
															THEN
							FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
							FND_MESSAGE.Set_Token('VALUE',
									'NEXT DAY COVERAGE');
							RAISE FND_API.G_EXC_ERROR;
						END IF;

-- DBMS_Output.Put_Line('Converting to mts cov. start time');

						convert_to_mts(l_cov_start_time_hours,
	                    				l_cov_start_time_mts,
				     				l_cov_start_time_all_mts);
-- 	DBMS_Output.Put_Line('Converting to mts cov. end time');
        					convert_to_mts(l_cov_end_time_hours,
			          				l_cov_end_time_mts,
				     				l_cov_end_time_all_mts);

-- DBMS_Output.Put_Line('Converted to mts');

          				IF (l_time_zone_id  IS NOT NULL      )  AND
	        				(p_call_time_zone_id  <> l_time_zone_id)  THEN

            					Convert_To_GMT(l_time_zone_id,
					  					l_cov_start_time_all_mts,
										l_end_date_time,
					  					x_return_status,
                           					x_msg_count,
                           					x_msg_data);

            					Convert_To_GMT(l_time_zone_id,
					  					l_cov_end_time_all_mts,
										l_end_date_time,
					  					x_return_status,
                           					x_msg_count,
                           					x_msg_data);

            					IF (x_return_status =
								FND_API.G_RET_STS_UNEXP_ERROR)  THEN
	         						FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
	         						FND_MESSAGE.Set_Token('VALUE',
									'CONVERT TO GMT');
              						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            					ELSIF (x_return_status =
								FND_API.G_RET_STS_ERROR)  THEN
	         						FND_MESSAGE.Set_Name ('CS',
									'CS_CONTRACTS_VALUE_NOT_FOUND');
	         						FND_MESSAGE.Set_Token('VALUE',
									'CONVERT TO GMT');
              						RAISE FND_API.G_EXC_ERROR;
            					END IF;
						END IF;
					l_cov_diff := l_cov_end_time_all_mts
								- l_cov_start_time_all_mts;

/***
DBMS_Output.Put_Line('Cov diff='|| to_char(l_cov_diff));
DBMS_Output.Put_Line('reaction time remaining='||
				to_char(l_reaction_time_remaining));
				**/

					IF (l_reaction_time_remaining <= l_cov_diff) THEN
							l_end_time_all_mts :=
								l_cov_start_time_all_mts +
								l_reaction_time_remaining;
							l_reaction_time_remaining := 0;

--DBMS_OUTPUT.PUT_LINE('Final Time='|| to_char(l_end_time_all_mts));

						IF (l_time_zone_id <> p_call_time_zone_id) THEN
							Convert_From_GMT( p_call_time_zone_id,
					  					l_end_time_all_mts,
										l_end_date_time,
					  					x_return_status,
                           					x_msg_count,
                           					x_msg_data);

--DBMS_OUTPUT.PUT_LINE('Final Time From GMT='|| to_char(l_end_time_all_mts));
						END IF ;
						Exit;
					ELSE
						l_reaction_time_used :=
									l_reaction_time_used + l_cov_diff;
						l_reaction_time_remaining :=
								l_reaction_time_all_mts
								- l_reaction_time_used;
					END IF;
				END LOOP;
			END IF;
	ELSE
	 l_cov_end_time_all_mts := (24 * 60) - 1;
	 l_cov_start_time_all_mts := 0;
      IF ((l_cov_end_time_all_mts
		- l_start_time_all_mts )< l_reaction_time_all_mts)THEN
        l_rtm_diff := l_reaction_time_all_mts
					- (l_cov_end_time_all_mts - l_start_time_all_mts);
--DBMS_Output.Put_Line('Else Rtm diff='|| to_char(l_rtm_diff));
	   LOOP
          l_end_date_time  := l_end_date_time + 1;
          l_cov_diff       := l_cov_end_time_all_mts
						- l_cov_start_time_all_mts;
--DBMS_Output.Put_Line('Else cov. diff='|| to_char(l_cov_diff));
          IF (l_rtm_diff < l_cov_diff)  THEN
            l_end_time_all_mts := l_cov_start_time_all_mts + l_rtm_diff;
		  EXIT;
	     ELSE
            l_rtm_diff     := l_rtm_diff - l_cov_diff;
          END IF;
	   END LOOP;
	 ELSE
        l_end_time_all_mts := l_start_time_all_mts + l_reaction_time_all_mts;
	 END IF;
    END IF;

--DBMS_OUtput.Put_Line('Before convert l_end_time_all_mts='||
--				to_char(l_end_time_all_mts));

    IF (l_end_time_all_mts <> 0) THEN
    		convert_to_hours_mts(l_end_time_all_mts,
					l_end_time_hours,
					l_end_time_mts);
	ELSE
		l_end_time_hours := l_start_time_hours;
		l_end_time_mts := l_start_time_mts;
	END IF;

/***
DBMS_OUtput.Put_Line('Converted date='||
		to_char(l_end_date_time,'DD-MM-RR') );
DBMS_Output.Put_Line('End hours='|| to_char(l_end_time_hours));
DBMS_Output.Put_Line('End mts='|| to_char(l_end_time_mts));
***/

    x_Expected_End_Date_Time := TO_DATE(TO_CHAR(l_end_date_time,'DD-MM-RR')
						 || ' '
					      || LPAD(l_end_time_hours,2,'0')
						 || LPAD(l_end_time_mts,2,'0'),'DD-MM-RR HH24:MI');

/***
DBMS_Output.Put_Line('Expected end date=' ||
		to_char(x_expected_end_date_time,'DD-MM-RR HH24:MI') );
**/


    TAPI_DEV_KIT.END_ACTIVITY(p_commit,
                              x_msg_count,
                              x_msg_data);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
      APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR   THEN
      x_return_status  := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
                          (l_api_name,
                           G_PKG_NAME,
                           'FND_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count,
                           x_msg_data,
                           '_pub');
      APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Reaction_Times;

END CS_GET_REACTION_TIMES_PUB;

/
