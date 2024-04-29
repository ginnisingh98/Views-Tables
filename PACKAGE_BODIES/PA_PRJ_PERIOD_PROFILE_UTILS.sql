--------------------------------------------------------
--  DDL for Package Body PA_PRJ_PERIOD_PROFILE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PRJ_PERIOD_PROFILE_UTILS" as
/* $Header: PAPJPDPB.pls 120.1.12010000.8 2009/05/21 12:15:37 vgovvala ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_module_name VARCHAR2(100) := 'pa.plsql.pa_prj_period_profile_utils';

Procedure Maintain_Prj_Period_Profile(
                          p_project_id IN NUMBER,
                          p_period_profile_type IN VARCHAR2,
                          p_plan_period_type    IN VARCHAR2,
                          p_period_set_name     IN VARCHAR2,
                          p_gl_period_type      IN VARCHAR2,
                          p_pa_period_type      IN VARCHAR2,
                          p_start_date          IN DATE,
                          px_end_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          px_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_commit_flag         IN VARCHAR2,
                          px_number_of_periods  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_debug_mode          IN VARCHAR2,
                          p_add_msg_in_stack    IN VARCHAR2,
                          x_plan_start_date     OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2    )  --File.Sql.39 bug 4440895
IS
   l_cnt number;
   l_period_name_tab     PA_PLSQL_DATATYPES.Char50TabTyp;
   l_st_dt_tab           PA_PLSQL_DATATYPES.DateTabTyp;
   l_end_dt_tab          PA_PLSQL_DATATYPES.DateTabTyp;
   l_period_type         Gl_Periods.Period_Type%TYPE;
   l_tab_count number(10);
   l_temp number(10);
   CURSOR c1(c_period_set_name varchar2,
              c_period_type varchar2,
              c_st_dt date ,
              c_end_dt date) is
       SELECT G.period_name,
              G.start_date,
              G.end_date FROM
       Gl_Periods G
   WHERE
      G.start_date      >= c_st_dt and
      G.end_date        <= c_end_dt and
      G.period_set_name = c_period_set_name and
      G.period_type      = c_period_type and
      G.adjustment_period_flag = 'N'
   ORDER BY G.start_date;
   l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
   l_created_by        NUMBER := FND_GLOBAL.USER_ID;
   l_creation_date     DATE := SYSDATE;
   l_last_update_date  DATE := l_creation_date;
   l_last_update_login      NUMBER := FND_GLOBAL.LOGIN_ID;
   l_program_application_id NUMBER := FND_GLOBAL.PROG_APPL_ID;
   l_request_id NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   l_program_id NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

   l_plan_end_period VARCHAR2(30);
BEGIN
  /* If all the periods needs to be populated for the project,
     then p_end_date parameter should be passed as NULL, and the
     API will calculate the end date by adding 10 yrs.
     If less than 52 periods ( max pds ) to be populated then
     the p_end_date should be passed with the actual date. */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PA_DEBUG.Set_Curr_Function( p_function   => 'Maintain_Prj_Period_Profile',
                              p_debug_mode => p_debug_mode );

  IF px_end_date IS NULL THEN
    IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'end date is null, setting the end dt';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
     px_end_date := ADD_MONTHS(p_start_date,120);
  END IF;
  IF p_plan_period_type = 'PA' THEN
     l_period_type := p_pa_period_type;
  ELSIF p_plan_period_type = 'GL' THEN
     l_period_type := p_gl_period_type;
  END IF;
  OPEN c1(p_period_set_name,
          l_period_type,
          p_start_date,
          px_end_date);

    FETCH c1  BULK COLLECT INTO
             l_period_name_tab,
             l_st_dt_tab,
             l_end_dt_tab  LIMIT 52;
    IF c1%notfound THEN
       null;
    END IF;
  CLOSE c1;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'after fetching pds';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
  l_plan_end_period := NULL;
  l_tab_count := l_period_name_tab.count;
  px_number_of_periods := l_tab_count;
  IF l_tab_count = 0 THEN
     IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'table count is zero for the given dt range, returning ';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_add_msg_in_stack = 'Y' THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_DATE_RANGE');
     ELSE
        x_msg_data      := 'PA_FP_INVALID_DATE_RANGE';
     END IF;
     PA_DEBUG.Reset_Curr_Function;
     RETURN;
  END IF;

  l_plan_end_period := l_period_name_tab(l_tab_count);
  l_temp := l_tab_count  + 1;
  x_plan_start_date := l_st_dt_tab(1);
  x_plan_end_date   := l_end_dt_tab(l_tab_count);

  WHILE l_temp <= 52 LOOP
    l_period_name_tab(l_temp) := null;
    l_st_dt_tab(l_temp)       := null;
    l_end_dt_tab(l_temp)      := null;

    l_temp := l_temp + 1;
  END LOOP;

 l_temp := 0;
 IF px_period_profile_id IS  NOT NULL THEN
   UPDATE pa_proj_period_profiles SET
     number_of_periods = l_tab_count,
     period_name1 = l_period_name_tab(1),
     period_name2 = l_period_name_tab(2),
     period_name3 = l_period_name_tab(3),
     period_name4 = l_period_name_tab(4),
     period_name5 = l_period_name_tab(5),
     period_name6 = l_period_name_tab(6),
     period_name7 = l_period_name_tab(7),
     period_name8 = l_period_name_tab(8),
     period_name9 = l_period_name_tab(9),
     period_name10 = l_period_name_tab(10),
     period_name11 = l_period_name_tab(11),
     period_name12 = l_period_name_tab(12),
     period_name13 = l_period_name_tab(13),
     period_name14 = l_period_name_tab(14),
     period_name15 = l_period_name_tab(15),
     period_name16 = l_period_name_tab(16),
     period_name17 = l_period_name_tab(17),
     period_name18 = l_period_name_tab(18),
     period_name19 = l_period_name_tab(19),
     period_name20 = l_period_name_tab(20),
     period_name21 = l_period_name_tab(21),
     period_name22 = l_period_name_tab(22),
     period_name23 = l_period_name_tab(23),
     period_name24 = l_period_name_tab(24),
     period_name25 = l_period_name_tab(25),
     period_name26 = l_period_name_tab(26),
     period_name27 = l_period_name_tab(27),
     period_name28 = l_period_name_tab(28),
     period_name29 = l_period_name_tab(29),
     period_name30 = l_period_name_tab(30),
     period_name31 = l_period_name_tab(31),
     period_name32 = l_period_name_tab(32),
     period_name33 = l_period_name_tab(33),
     period_name34 = l_period_name_tab(34),
     period_name35 = l_period_name_tab(35),
     period_name36 = l_period_name_tab(36),
     period_name37 = l_period_name_tab(37),
     period_name38 = l_period_name_tab(38),
     period_name39 = l_period_name_tab(39),
     period_name40 = l_period_name_tab(40),
     period_name41 = l_period_name_tab(41),
     period_name42 = l_period_name_tab(42),
     period_name43 = l_period_name_tab(43),
     period_name44 = l_period_name_tab(44),
     period_name45 = l_period_name_tab(45),
     period_name46 = l_period_name_tab(46),
     period_name47 = l_period_name_tab(47),
     period_name48 = l_period_name_tab(48),
     period_name49 = l_period_name_tab(49),
     period_name50 = l_period_name_tab(50),
     period_name51 = l_period_name_tab(51),
     period_name52 = l_period_name_tab(52),
     period1_start_date = l_st_dt_tab(1),
     period2_start_date = l_st_dt_tab(2),
     period3_start_date = l_st_dt_tab(3),
     period4_start_date = l_st_dt_tab(4),
     period5_start_date = l_st_dt_tab(5),
     period6_start_date = l_st_dt_tab(6),
     period7_start_date = l_st_dt_tab(7),
     period8_start_date = l_st_dt_tab(8),
     period9_start_date = l_st_dt_tab(9),
     period10_start_date = l_st_dt_tab(10),
     period11_start_date = l_st_dt_tab(11),
     period12_start_date = l_st_dt_tab(12),
     period13_start_date = l_st_dt_tab(13),
     period14_start_date = l_st_dt_tab(14),
     period15_start_date = l_st_dt_tab(15),
     period16_start_date = l_st_dt_tab(16),
     period17_start_date = l_st_dt_tab(17),
     period18_start_date = l_st_dt_tab(18),
     period19_start_date = l_st_dt_tab(19),
     period20_start_date = l_st_dt_tab(20),
     period21_start_date = l_st_dt_tab(21),
     period22_start_date = l_st_dt_tab(22),
     period23_start_date = l_st_dt_tab(23),
     period24_start_date = l_st_dt_tab(24),
     period25_start_date = l_st_dt_tab(25),
     period26_start_date = l_st_dt_tab(26),
     period27_start_date = l_st_dt_tab(27),
     period28_start_date = l_st_dt_tab(28),
     period29_start_date = l_st_dt_tab(29),
     period30_start_date = l_st_dt_tab(30),
     period31_start_date = l_st_dt_tab(31),
     period32_start_date = l_st_dt_tab(32),
     period33_start_date = l_st_dt_tab(33),
     period34_start_date = l_st_dt_tab(34),
     period35_start_date = l_st_dt_tab(35),
     period36_start_date = l_st_dt_tab(36),
     period37_start_date = l_st_dt_tab(37),
     period38_start_date = l_st_dt_tab(38),
     period39_start_date = l_st_dt_tab(39),
     period40_start_date = l_st_dt_tab(40),
     period41_start_date = l_st_dt_tab(41),
     period42_start_date = l_st_dt_tab(42),
     period43_start_date = l_st_dt_tab(43),
     period44_start_date = l_st_dt_tab(44),
     period45_start_date = l_st_dt_tab(45),
     period46_start_date = l_st_dt_tab(46),
     period47_start_date = l_st_dt_tab(47),
     period48_start_date = l_st_dt_tab(48),
     period49_start_date = l_st_dt_tab(49),
     period50_start_date = l_st_dt_tab(50),
     period51_start_date = l_st_dt_tab(51),
     period52_start_date = l_st_dt_tab(52),
     period1_end_date = l_end_dt_tab(1),
     period2_end_date = l_end_dt_tab(2),
     period3_end_date = l_end_dt_tab(3),
     period4_end_date = l_end_dt_tab(4),
     period5_end_date = l_end_dt_tab(5),
     period6_end_date = l_end_dt_tab(6),
     period7_end_date = l_end_dt_tab(7),
     period8_end_date = l_end_dt_tab(8),
     period9_end_date = l_end_dt_tab(9),
     period10_end_date = l_end_dt_tab(10),
     period11_end_date = l_end_dt_tab(11),
     period12_end_date = l_end_dt_tab(12),
     period13_end_date = l_end_dt_tab(13),
     period14_end_date = l_end_dt_tab(14),
     period15_end_date = l_end_dt_tab(15),
     period16_end_date = l_end_dt_tab(16),
     period17_end_date = l_end_dt_tab(17),
     period18_end_date = l_end_dt_tab(18),
     period19_end_date = l_end_dt_tab(19),
     period20_end_date = l_end_dt_tab(20),
     period21_end_date = l_end_dt_tab(21),
     period22_end_date = l_end_dt_tab(22),
     period23_end_date = l_end_dt_tab(23),
     period24_end_date = l_end_dt_tab(24),
     period25_end_date = l_end_dt_tab(25),
     period26_end_date = l_end_dt_tab(26),
     period27_end_date = l_end_dt_tab(27),
     period28_end_date = l_end_dt_tab(28),
     period29_end_date = l_end_dt_tab(29),
     period30_end_date = l_end_dt_tab(30),
     period31_end_date = l_end_dt_tab(31),
     period32_end_date = l_end_dt_tab(32),
     period33_end_date = l_end_dt_tab(33),
     period34_end_date = l_end_dt_tab(34),
     period35_end_date = l_end_dt_tab(35),
     period36_end_date = l_end_dt_tab(36),
     period37_end_date = l_end_dt_tab(37),
     period38_end_date = l_end_dt_tab(38),
     period39_end_date = l_end_dt_tab(39),
     period40_end_date = l_end_dt_tab(40),
     period41_end_date = l_end_dt_tab(41),
     period42_end_date = l_end_dt_tab(42),
     period43_end_date = l_end_dt_tab(43),
     period44_end_date = l_end_dt_tab(44),
     period45_end_date = l_end_dt_tab(45),
     period46_end_date = l_end_dt_tab(46),
     period47_end_date = l_end_dt_tab(47),
     period48_end_date = l_end_dt_tab(48),
     period49_end_date = l_end_dt_tab(49),
     period50_end_date = l_end_dt_tab(50),
     period51_end_date = l_end_dt_tab(51),
     period52_end_date = l_end_dt_tab(52),
     LAST_UPDATE_LOGIN = l_last_update_login,
     LAST_UPDATED_BY   = l_last_updated_by,
     LAST_UPDATE_DATE  = l_last_update_date,
     PROFILE_END_PERIOD_NAME   = l_plan_end_period
     WHERE period_profile_id = px_period_profile_id;

     IF SQL%ROWCOUNT = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'no record updated for the gievn id';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF p_add_msg_in_stack = 'Y' THEN
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_INVALID_PRJ_PROFILE');
        ELSE
           x_msg_data      := 'PA_FP_INVALID_PRJ_PROFILE';
        END IF;
        PA_DEBUG.Reset_Curr_Function;
        RETURN;
     END IF;
   ELSE
     INSERT INTO pa_proj_period_profiles (
     CREATION_DATE ,
     CREATED_BY ,
     LAST_UPDATE_LOGIN ,
     LAST_UPDATED_BY ,
     LAST_UPDATE_DATE ,
     period_profile_id ,
     period_profile_type ,
     period_set_name ,
     gl_period_type ,
     plan_period_type,
     project_id ,
     period_name1 ,
     period_name2 ,
     period_name3 ,
     period_name4 ,
     period_name5 ,
     period_name6 ,
     period_name7 ,
     period_name8 ,
     period_name9 ,
     period_name10 ,
     period_name11 ,
     period_name12 ,
     period_name13 ,
     period_name14 ,
     period_name15 ,
     period_name16 ,
     period_name17 ,
     period_name18 ,
     period_name19 ,
     period_name20 ,
     period_name21 ,
     period_name22 ,
     period_name23 ,
     period_name24 ,
     period_name25 ,
     period_name26 ,
     period_name27 ,
     period_name28 ,
     period_name29 ,
     period_name30 ,
     period_name31 ,
     period_name32 ,
     period_name33 ,
     period_name34 ,
     period_name35 ,
     period_name36 ,
     period_name37 ,
     period_name38 ,
     period_name39 ,
     period_name40 ,
     period_name41 ,
     period_name42 ,
     period_name43 ,
     period_name44 ,
     period_name45 ,
     period_name46 ,
     period_name47 ,
     period_name48 ,
     period_name49 ,
     period_name50 ,
     period_name51 ,
     period_name52 ,
     period1_start_date ,
     period2_start_date ,
     period3_start_date ,
     period4_start_date ,
     period5_start_date ,
     period6_start_date ,
     period7_start_date ,
     period8_start_date ,
     period9_start_date ,
     period10_start_date ,
     period11_start_date ,
     period12_start_date ,
     period13_start_date ,
     period14_start_date ,
     period15_start_date ,
     period16_start_date ,
     period17_start_date ,
     period18_start_date ,
     period19_start_date ,
     period20_start_date ,
     period21_start_date ,
     period22_start_date ,
     period23_start_date ,
     period24_start_date ,
     period25_start_date ,
     period26_start_date ,
     period27_start_date ,
     period28_start_date ,
     period29_start_date ,
     period30_start_date ,
     period31_start_date ,
     period32_start_date ,
     period33_start_date ,
     period34_start_date ,
     period35_start_date ,
     period36_start_date ,
     period37_start_date ,
     period38_start_date ,
     period39_start_date ,
     period40_start_date ,
     period41_start_date ,
     period42_start_date ,
     period43_start_date ,
     period44_start_date ,
     period45_start_date ,
     period46_start_date ,
     period47_start_date ,
     period48_start_date ,
     period49_start_date ,
     period50_start_date ,
     period51_start_date ,
     period52_start_date ,
     period1_end_date ,
     period2_end_date ,
     period3_end_date ,
     period4_end_date ,
     period5_end_date ,
     period6_end_date ,
     period7_end_date ,
     period8_end_date ,
     period9_end_date ,
     period10_end_date ,
     period11_end_date ,
     period12_end_date ,
     period13_end_date ,
     period14_end_date ,
     period15_end_date ,
     period16_end_date ,
     period17_end_date ,
     period18_end_date ,
     period19_end_date ,
     period20_end_date ,
     period21_end_date ,
     period22_end_date ,
     period23_end_date ,
     period24_end_date ,
     period25_end_date ,
     period26_end_date ,
     period27_end_date ,
     period28_end_date ,
     period29_end_date ,
     period30_end_date ,
     period31_end_date ,
     period32_end_date ,
     period33_end_date ,
     period34_end_date ,
     period35_end_date ,
     period36_end_date ,
     period37_end_date ,
     period38_end_date ,
     period39_end_date ,
     period40_end_date ,
     period41_end_date ,
     period42_end_date ,
     period43_end_date ,
     period44_end_date ,
     period45_end_date ,
     period46_end_date ,
     period47_end_date ,
     period48_end_date ,
     period49_end_date ,
     period50_end_date ,
     period51_end_date ,
     period52_end_date ,
     number_of_periods,
     PROFILE_END_PERIOD_NAME  )
     VALUES (
     l_creation_date ,
     l_created_by ,
     l_last_update_login ,
     l_last_updated_by ,
     l_last_update_date ,
     PA_PROJ_PERIOD_PROFILES_S.nextval,
     p_period_profile_type,
     p_period_set_name,
     p_gl_period_type,
     p_plan_period_type,
     p_project_id,
     l_period_name_tab(1),
     l_period_name_tab(2),
     l_period_name_tab(3),
     l_period_name_tab(4),
     l_period_name_tab(5),
     l_period_name_tab(6),
     l_period_name_tab(7),
     l_period_name_tab(8),
     l_period_name_tab(9),
     l_period_name_tab(10),
     l_period_name_tab(11),
     l_period_name_tab(12),
     l_period_name_tab(13),
     l_period_name_tab(14),
     l_period_name_tab(15),
     l_period_name_tab(16),
     l_period_name_tab(17),
     l_period_name_tab(18),
     l_period_name_tab(19),
     l_period_name_tab(20),
     l_period_name_tab(21),
     l_period_name_tab(22),
     l_period_name_tab(23),
     l_period_name_tab(24),
     l_period_name_tab(25),
     l_period_name_tab(26),
     l_period_name_tab(27),
     l_period_name_tab(28),
     l_period_name_tab(29),
     l_period_name_tab(30),
     l_period_name_tab(31),
     l_period_name_tab(32),
     l_period_name_tab(33),
     l_period_name_tab(34),
     l_period_name_tab(35),
     l_period_name_tab(36),
     l_period_name_tab(37),
     l_period_name_tab(38),
     l_period_name_tab(39),
     l_period_name_tab(40),
     l_period_name_tab(41),
     l_period_name_tab(42),
     l_period_name_tab(43),
     l_period_name_tab(44),
     l_period_name_tab(45),
     l_period_name_tab(46),
     l_period_name_tab(47),
     l_period_name_tab(48),
     l_period_name_tab(49),
     l_period_name_tab(50),
     l_period_name_tab(51),
     l_period_name_tab(52),
     l_st_dt_tab(1),
     l_st_dt_tab(2),
     l_st_dt_tab(3),
     l_st_dt_tab(4),
     l_st_dt_tab(5),
     l_st_dt_tab(6),
     l_st_dt_tab(7),
     l_st_dt_tab(8),
     l_st_dt_tab(9),
     l_st_dt_tab(10),
     l_st_dt_tab(11),
     l_st_dt_tab(12),
     l_st_dt_tab(13),
     l_st_dt_tab(14),
     l_st_dt_tab(15),
     l_st_dt_tab(16),
     l_st_dt_tab(17),
     l_st_dt_tab(18),
     l_st_dt_tab(19),
     l_st_dt_tab(20),
     l_st_dt_tab(21),
     l_st_dt_tab(22),
     l_st_dt_tab(23),
     l_st_dt_tab(24),
     l_st_dt_tab(25),
     l_st_dt_tab(26),
     l_st_dt_tab(27),
     l_st_dt_tab(28),
     l_st_dt_tab(29),
     l_st_dt_tab(30),
     l_st_dt_tab(31),
     l_st_dt_tab(32),
     l_st_dt_tab(33),
     l_st_dt_tab(34),
     l_st_dt_tab(35),
     l_st_dt_tab(36),
     l_st_dt_tab(37),
     l_st_dt_tab(38),
     l_st_dt_tab(39),
     l_st_dt_tab(40),
     l_st_dt_tab(41),
     l_st_dt_tab(42),
     l_st_dt_tab(43),
     l_st_dt_tab(44),
     l_st_dt_tab(45),
     l_st_dt_tab(46),
     l_st_dt_tab(47),
     l_st_dt_tab(48),
     l_st_dt_tab(49),
     l_st_dt_tab(50),
     l_st_dt_tab(51),
     l_st_dt_tab(52),
     l_end_dt_tab(1),
     l_end_dt_tab(2),
     l_end_dt_tab(3),
     l_end_dt_tab(4),
     l_end_dt_tab(5),
     l_end_dt_tab(6),
     l_end_dt_tab(7),
     l_end_dt_tab(8),
     l_end_dt_tab(9),
     l_end_dt_tab(10),
     l_end_dt_tab(11),
     l_end_dt_tab(12),
     l_end_dt_tab(13),
     l_end_dt_tab(14),
     l_end_dt_tab(15),
     l_end_dt_tab(16),
     l_end_dt_tab(17),
     l_end_dt_tab(18),
     l_end_dt_tab(19),
     l_end_dt_tab(20),
     l_end_dt_tab(21),
     l_end_dt_tab(22),
     l_end_dt_tab(23),
     l_end_dt_tab(24),
     l_end_dt_tab(25),
     l_end_dt_tab(26),
     l_end_dt_tab(27),
     l_end_dt_tab(28),
     l_end_dt_tab(29),
     l_end_dt_tab(30),
     l_end_dt_tab(31),
     l_end_dt_tab(32),
     l_end_dt_tab(33),
     l_end_dt_tab(34),
     l_end_dt_tab(35),
     l_end_dt_tab(36),
     l_end_dt_tab(37),
     l_end_dt_tab(38),
     l_end_dt_tab(39),
     l_end_dt_tab(40),
     l_end_dt_tab(41),
     l_end_dt_tab(42),
     l_end_dt_tab(43),
     l_end_dt_tab(44),
     l_end_dt_tab(45),
     l_end_dt_tab(46),
     l_end_dt_tab(47),
     l_end_dt_tab(48),
     l_end_dt_tab(49),
     l_end_dt_tab(50),
     l_end_dt_tab(51),
     l_end_dt_tab(52),
     l_tab_count     ,
     l_plan_end_period ) returning period_profile_id into
                          px_period_profile_id;

    IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'after inserting pd profile';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

     UPDATE PA_PROJ_PERIOD_PROFILES SET CURRENT_FLAG = 'N' WHERE
            Period_Profile_Type = p_period_profile_type AND
            Plan_Period_Type    = p_plan_period_type    AND
            Project_Id          = p_project_id          AND
            Current_Flag        = 'Y';

     UPDATE PA_PROJ_PERIOD_PROFILES SET CURRENT_FLAG = 'Y' WHERE
              Period_Profile_Id = px_period_profile_id;

   END IF;
   IF NVL(p_commit_flag,'N') = 'Y' THEN
      COMMIT;
   END IF;
   PA_DEBUG.Reset_Curr_Function;
   RETURN;
   EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Maintain_Prj_Period_Profile;

    Procedure Get_Prj_Period_Profile_Dtls(
                          p_period_profile_id  IN  NUMBER,
                          p_debug_mode          IN VARCHAR2,
                          p_add_msg_in_stack    IN VARCHAR2,
                          x_period_profile_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_plan_period_type    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_period_set_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_gl_period_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_plan_start_date     OUT  NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_number_of_periods   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2 ) IS  --File.Sql.39 bug 4440895
  l_cursor_id integer;
  l_plan_end_date date;
  l_stmt varchar2(1000);
  l_column_name varchar2(100);
  l_dummy integer;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Prj_Period_Profile_Dtls',
                               p_debug_mode => p_debug_mode );
   BEGIN
      SELECT Period_Profile_Type,
             Plan_Period_Type,
             Period_Set_Name,
             Gl_Period_Type,
             Number_Of_Periods,
             Period1_Start_Date INTO
      x_period_profile_type,
      x_plan_period_type,
      x_period_set_name,
      x_gl_period_type,
      x_number_of_periods,
      x_plan_start_date FROM Pa_Proj_Period_Profiles
      WHERE Period_Profile_Id = NVL(p_period_profile_id,0);

  l_column_name := 'PERIOD'||LTRIM(TO_CHAR(x_number_of_periods))||'_END_DATE';
  l_cursor_id := dbms_sql.open_cursor;
  l_stmt := 'select ' ||l_column_name
            || ' from pa_proj_period_profiles  where ' ||
               ' period_profile_id =  '||to_char(p_period_profile_id);

  dbms_sql.parse(l_cursor_id,l_stmt,dbms_sql.native);
  dbms_sql.define_column(l_cursor_id,1,l_plan_end_date);

  l_dummy := dbms_sql.execute_and_fetch(l_cursor_id);


  dbms_sql.column_value(l_cursor_id,1,l_plan_end_date);
  dbms_sql.close_cursor(l_cursor_id);
  x_plan_end_date := l_plan_end_date;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'no data found for the given pd profile id';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF p_add_msg_in_stack = 'Y' THEN
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_INVALID_PRJ_PROFILE');
        ELSE
           x_msg_data      := 'PA_FP_INVALID_PRJ_PROFILE';
        END IF;
   END;
   PA_DEBUG.Reset_Curr_Function;
   RETURN;

END Get_Prj_Period_Profile_Dtls;

  PROCEDURE Get_Date_Details(
                         p_project_id IN NUMBER,
                         p_period_name IN VARCHAR2,
                         p_plan_period_type IN VARCHAR2,
                         x_start_date  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_end_date    OUT NOCOPY VARCHAR2 )  IS  --File.Sql.39 bug 4440895
  l_start_Date VARCHAR2(30);
  l_end_date   VARCHAR2(30);
  BEGIN
    l_start_Date := NULL;
    l_end_date   := NULL;
    IF p_plan_period_type = 'GL' THEN
     BEGIN
     SELECT TO_CHAR(gl.start_date,'rrrr/mm/dd'),
            TO_CHAR(gl.end_date,'rrrr/mm/dd') INTO l_start_date,l_end_Date FROM
     Gl_Periods gl, Pa_Implementations_All imp ,Pa_Projects_All p ,
     Gl_Sets_Of_Books sob WHERE
     p.Project_Id = p_project_id AND
     nvl(p.Org_Id,-99) = NVL(imp.Org_Id,-99) AND
     imp.Set_Of_Books_Id = sob.Set_Of_Books_Id AND
     gl.Period_Set_Name = imp.Period_Set_Name AND
     gl.Period_Type     = sob.Accounted_Period_Type AND
     gl.Period_Name     = p_period_name AND
     gl.Adjustment_Period_Flag = 'N' ;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     END;
   ELSIF p_plan_period_type = 'PA' THEN
     BEGIN
     SELECT TO_CHAR(gl.start_date,'rrrr/mm/dd'),
            TO_CHAR(gl.end_date,'rrrr/mm/dd') INTO l_start_date,l_end_Date FROM
     Gl_Periods gl, Pa_Implementations_All imp ,Pa_Projects_All p WHERE
     p.Project_Id = p_project_id AND
     nvl(p.Org_Id,-99) = nvl(imp.Org_Id,-99) AND
     gl.Period_Set_Name = imp.Period_Set_Name AND
     gl.Period_Type     = imp.Pa_Period_Type AND
     gl.Period_Name     = p_period_name      AND
     gl.Adjustment_Period_Flag = 'N' ;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     END;
   END IF;
    x_start_date := l_start_date;

    x_end_Date := l_end_Date;

  END;


--
--Name:              	Maintain_Prj_Profile_wrp
--Type:               	Procedure
--
--Description:
--Called subprograms: none
--
--
--
--History:
--      14-NOV-2001     SManivannan   - Created
--
--   	17-MAR-03	jwhite        - Bug 2589885
--                                      Add logic and edits to enforce entry of GL/PA periods
--                                      within project duration.
--

Procedure Maintain_Prj_Profile_wrp(
                          p_project_id          IN NUMBER,
                          p_period_profile_type IN VARCHAR2,
                          p_pa_start_date          IN DATE,
                          px_pa_end_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          px_pa_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_commit_flag         IN VARCHAR2,
                          px_pa_number_of_periods  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_debug_mode          IN VARCHAR2,
                          p_add_msg_in_stack    IN VARCHAR2,
                          x_pa_plan_start_date     OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_pa_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_pa_start_period        IN  VARCHAR2,
                          p_pa_end_period          IN  VARCHAR2,
                          p_gl_start_period        IN  VARCHAR2,
                          p_gl_end_period          IN  VARCHAR2,
                          p_gl_start_date IN DATE,
                          px_gl_end_date IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          px_gl_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          px_gl_number_of_periods IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_old_pa_profile_id      IN NUMBER ,
                          p_old_gl_profile_id      IN NUMBER ,
                          p_refresh_option_code    IN VARCHAR2,
                          x_conc_req_id            OUT NOCOPY VARCHAR2   ) IS --File.Sql.39 bug 4440895
  l_para_plan_start_Date DATE;
  l_para_plan_end_Date DATE;
  l_pa_start_Date DATE;
  l_pa_end_date   DATE;
  l_gl_start_Date DATE;
  l_gl_end_date   DATE;
  l_pa_start_Date1 DATE;
  l_pa_end_date1   DATE;
  l_gl_start_Date1 DATE;
  l_gl_end_date1   DATE;
  l_gl_period_set_name Gl_Periods.Period_Set_Name%TYPE;
  l_gl_period_type     Gl_Periods.Period_Type%TYPE;
  l_pa_period_type     Gl_Periods.Period_Type%TYPE;
  l_pa_plan_start_date    DATE;
  l_pa_plan_end_date      DATE;
  l_gl_plan_start_date    DATE;
  l_gl_plan_end_date      DATE;
  l_plan_period_type   Pa_Proj_Period_Profiles.Plan_Period_Type%TYPE;
  l_para_start_Date DATE;
  l_para_end_Date DATE;
  l_para_period_profile_id NUMBER;
  l_para_number_of_periods NUMBER;
  l_old_pa_profile_id NUMBER;
  l_old_gl_profile_id NUMBER;
  l_return_status VARCHAR2(30);
  l_pa_return_status VARCHAR2(30);
  l_gl_return_status VARCHAR2(30);
  l_old_upd_profile_id NUMBER;
  l_valid_pa_period_flag VARCHAR2(1);
  l_valid_gl_period_flag VARCHAR2(1);
  l_call_profile_pa_flag VARCHAR2(1);
  l_call_profile_gl_flag VARCHAR2(1);
  l_old_pa_start_period Pa_Proj_Period_Profiles.Period_Name1%TYPE;
  l_old_gl_start_period Pa_Proj_Period_Profiles.Period_Name1%TYPE;
  l_old_pa_end_period Pa_Proj_Period_Profiles.Period_Name1%TYPE;
  l_old_gl_end_period Pa_Proj_Period_Profiles.Period_Name1%TYPE;
  l_periods_count NUMBER;
  l_msg_count          NUMBER :=0;
  l_msg_data           VARCHAR2(2000);
  l_data               VARCHAR2(2000);
  l_msg_index_out      NUMBER;
  l_rpt_request_id     NUMBER;
  l_debug_mode VARCHAR2(30);
  l_conc_pa_profile_id NUMBER;
  l_conc_gl_profile_id NUMBER;
  l_bv_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
  l_locked_person_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
  l_plan_proc_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;


  -- Bug 2589885, 17-MAR-2003, jwhite, Begin: --------------------

	l_prj_start_date        DATE := NULL;
        l_prj_completion_date   DATE := NULL;

	l_prj_PAper_start_date        DATE := NULL;
	l_prj_PAper_end_date          DATE := NULL;
	l_prj_GLper_start_date        DATE := NULL;
	l_prj_GLper_end_date          DATE := NULL;

        l_invalid_prj_dur_PA    VARCHAR2(1) := 'N';
        l_invalid_prj_dur_GL    VARCHAR2(1) := 'N';


  -- Bug 2589885, End: ---------------------------------------------

    nc_pa_end_date             DATE;
    nc_pa_period_profile_id    NUMBER;
    nc_pa_number_of_periods    NUMBER;
    nc_gl_end_date   		   DATE;
    nc_gl_period_profile_id    NUMBER;
    nc_gl_number_of_periods    NUMBER;

BEGIN
    nc_pa_end_date := px_pa_end_date;
    nc_pa_period_profile_id := px_pa_period_profile_id;
    nc_pa_number_of_periods := px_pa_number_of_periods;
    nc_gl_end_date := px_gl_end_date;
    nc_gl_period_profile_id := px_gl_period_profile_id;
    nc_gl_number_of_periods := px_gl_number_of_periods;

     x_conc_req_id := '0';
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_gl_return_status := FND_API.G_RET_STS_SUCCESS;
     l_pa_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     l_valid_pa_period_flag := 'Y';
     l_valid_gl_period_flag := 'Y';
     l_old_pa_profile_id := px_pa_period_profile_id;
     l_old_gl_profile_id := px_gl_period_profile_id;
     l_call_profile_pa_flag := 'Y';
     l_call_profile_gl_flag := 'Y';

     /* Bug 2689403 - Start of validations based on the bug */

     /* Validating i/p start and end dates.
        Either both should be null or both should be not null */

     IF (p_pa_start_period IS NULL and p_pa_end_period IS NOT NULL) or
        (p_pa_start_period IS NOT NULL and p_pa_end_period IS NULL) THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Only one of the pa start or end periods are not null..';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_ENTER_PA_PP_ST_END_DT');
     END IF;

     IF (p_gl_start_period IS NULL and p_gl_end_period IS NOT NULL) or
        (p_gl_start_period IS NOT NULL and p_gl_end_period IS NULL) THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Only one of the gl start or end periods are not null..';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_ENTER_GL_PP_ST_END_DT');
     END IF;

     /* If start and end periods are null then there should not have been an existing period profile */

     IF (p_pa_start_period IS NULL and p_pa_end_period IS NULL) THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Both pa start and end periods are null...';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         l_valid_pa_period_flag := 'N';
         IF p_old_pa_profile_id IS NOT NULL THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_ENTER_PA_PERIODS');
         ELSE
             l_call_profile_pa_flag := 'N';
         END IF;
     END IF;

     IF (p_gl_start_period IS NULL and p_gl_end_period IS NULL) THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Both gl start and end periods are null...';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         l_valid_gl_period_flag := 'N';
         IF p_old_gl_profile_id IS NOT NULL THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_ENTER_GL_PERIODS');
         ELSE
             l_call_profile_gl_flag := 'N';
         END IF;
     END IF;

     SELECT  imp.Pa_Period_Type,
             imp.Period_Set_Name,
             sob.Accounted_Period_Type   INTO
     l_pa_period_type,
     l_gl_period_set_name,
     l_gl_period_type FROM
     Pa_Implementations_All imp ,Pa_Projects_All p ,
     Gl_Sets_Of_Books sob WHERE
     p.Project_Id = p_project_id AND
     nvl(p.Org_Id,-99) = NVL(imp.Org_Id,-99) AND
     imp.Set_Of_Books_id = sob.Set_Of_Books_Id;

     /* The following validations need to be done only if the start and end dates are not null
        and there was not validation failure before this. */

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

         IF l_valid_pa_period_flag = 'Y' THEN

                 BEGIN
                      SELECT gl.Start_Date,gl.End_Date INTO l_pa_start_date,l_pa_end_Date FROM
                      Gl_Periods gl WHERE
                      gl.Period_Set_Name = l_gl_period_set_name AND
                      gl.Period_Type     = l_pa_period_type and
                      gl.Period_Name     = p_pa_start_period     AND
                      gl.Adjustment_Period_Flag = 'N' ;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         l_valid_pa_period_flag := 'N';
                         x_msg_count := x_msg_count + 1;
                         l_call_profile_pa_flag := 'N';
                         l_pa_return_status := FND_API.G_RET_STS_ERROR;
                         PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_PP_INVALID_PERIOD',
                                 p_token1         => 'PERIOD',
                                 p_value1         => p_pa_start_period);
                 END;

                 BEGIN
                     SELECT gl.Start_Date,gl.End_Date INTO   l_pa_start_date1,l_pa_end_Date1 FROM
                     Gl_Periods gl WHERE
                     gl.Period_Set_Name = l_gl_period_set_name AND
                     gl.Period_Type     = l_pa_period_type AND
                     gl.Period_Name     = p_pa_end_period     AND
                    gl.Adjustment_Period_Flag = 'N' ;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         l_valid_pa_period_flag := 'N';
                         x_msg_count := x_msg_count + 1;
                         l_call_profile_pa_flag := 'N';
                         l_pa_return_status := FND_API.G_RET_STS_ERROR;
                         PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_FP_PP_INVALID_PERIOD',
                                           p_token1         => 'PERIOD',
                                           p_value1         => p_pa_end_period);
                 END;

         END IF;

         IF l_valid_gl_period_flag = 'Y' THEN

             BEGIN
                 SELECT gl.Start_Date,gl.End_Date INTO l_gl_start_date,l_gl_end_Date FROM
                 Gl_Periods gl WHERE
                 gl.Period_Set_Name = l_gl_period_set_name AND
                 gl.Period_Type     = l_gl_period_type AND
                 gl.Period_Name     = p_gl_start_period AND
                 gl.Adjustment_Period_Flag = 'N' ;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     x_msg_count := x_msg_count + 1;
                     l_valid_gl_period_flag := 'N';
                     l_call_profile_gl_flag := 'N';
                     l_gl_return_status := FND_API.G_RET_STS_ERROR;
                     PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_PP_INVALID_PERIOD',
                                      p_token1         => 'PERIOD',
                                      p_value1         => p_gl_start_period);
             END;

             BEGIN
                 SELECT gl.Start_Date,gl.End_Date INTO l_gl_start_date1,l_gl_end_Date1 FROM
                 Gl_Periods gl WHERE
                 gl.Period_Set_Name = l_gl_period_set_name AND
                 gl.Period_Type     = l_gl_period_type AND
                 gl.Period_Name     = p_gl_end_period AND
                 gl.Adjustment_Period_Flag = 'N' ;

                 l_para_period_profile_id := px_gl_period_profile_id;
                 l_para_number_of_periods := px_gl_number_of_periods;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     l_valid_gl_period_flag := 'N';
                     x_msg_count := x_msg_count + 1;
                     l_call_profile_gl_flag := 'N';
                     l_gl_return_status := FND_API.G_RET_STS_ERROR;
                     PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_PP_INVALID_PERIOD',
                                      p_token1         => 'PERIOD',
                                      p_value1         => p_gl_end_period);
             END;

         END IF;

         IF l_valid_pa_period_flag = 'Y' THEN
             SELECT COUNT(*) INTO l_periods_count FROM Gl_Periods gl
             WHERE
             Start_Date BETWEEN l_pa_start_date AND l_pa_start_date1 AND
             gl.Period_Set_Name = l_gl_period_set_name AND
             gl.Period_Type     = l_pa_period_type AND
             gl.Adjustment_Period_Flag = 'N' ;
             IF l_periods_count > 52 THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := x_msg_count + 1;
                 l_call_profile_pa_flag := 'N';
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_PP_EXCEED_MAX_PDS');
             END IF;
             IF l_pa_start_date > l_pa_start_date1 THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := x_msg_count + 1;
                 l_call_profile_pa_flag := 'N';
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_PP_INVALID_PERIOD_RANGE');
             END IF;
         END IF;

         IF l_valid_gl_period_flag = 'Y' THEN
             SELECT COUNT(*) INTO l_periods_count FROM Gl_Periods gl
             WHERE
             Start_Date BETWEEN l_gl_start_date AND l_gl_start_date1 AND
             gl.Period_Set_Name = l_gl_period_set_name AND
             gl.Period_Type     = l_gl_period_type AND
             gl.Adjustment_Period_Flag = 'N' ;
             IF l_periods_count > 52 THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := x_msg_count + 1;
                 l_call_profile_gl_flag := 'N';
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_PP_EXCEED_MAX_PDS_GL');
             END IF;
             IF l_gl_start_date > l_gl_start_date1 THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := x_msg_count + 1;
                 l_call_profile_gl_flag := 'N';
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_PP_INVALID_PD_RANGE_GL');
             END IF;
         END IF;



   -- Bug 2589885, 17-MAR-2003, jwhite, Begin: --------------------
   --
   -- Edit to Enforce Entered Periods within Project Duration

                -- All New Code for this Bug Fix --


        IF ( (l_valid_pa_period_flag = 'Y') OR (l_valid_gl_period_flag = 'Y') )
           THEN

            -- Find Start and End Dates for Project, If ANy

              SELECT start_Date
                     ,  completion_date
              INTO   l_prj_start_date
                     , l_prj_completion_date
              FROM   Pa_Projects_All
              WHERE  Project_Id = p_project_id;


            -- PA Period Validation
            IF (l_valid_PA_period_flag = 'Y')
               THEN


               IF (l_prj_start_date IS NOT NULL)
                  THEN

                     -- STARTING Period Edit ----------------------------------------------

                     -- Find the Corresponding PA Period for the Project START Date
                     -- AND save the PA Period's START date for subsequent processing

                     -- Issue: If project start date does not have corresponding
                     --        period in GL_Periods, use the project start date.

                     BEGIN

                        SELECT Start_Date
                        INTO   l_prj_PAper_start_date
                        FROM   Gl_Periods
                        WHERE  Period_Set_Name        = l_gl_period_set_name
                        AND    Period_Type            = l_PA_period_type
                        AND    Adjustment_Period_Flag = 'N'
                        and    l_prj_start_date between start_date and end_date;

                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             l_prj_PAper_start_date   := l_prj_start_date;

                     END;


                     -- IF the Start Date of the Entered PA Start Period is EARLIER than the Start Date
                     -- of the PA Period Corresponding to the Start Date of the Project
                     --         THEN  Issue error message.



                        IF ( l_PA_START_date < l_prj_PAper_START_date)
                           THEN

                             x_return_status := FND_API.G_RET_STS_ERROR;
                             x_msg_count := x_msg_count + 1;
                             l_call_profile_pa_flag := 'N';
                             l_invalid_prj_dur_PA   := 'Y';
                             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                 , p_msg_name     => 'PA_FP_PP_INVALID_PRJ_DUR_PA');
                        END IF;



                  END IF; -- l_prj_start_date IS NOT NULL




                   -- ENDING Period Edit ----------------------------------------------

                     -- IF Project Completion Date Exists AND PA Periods Passed Previous Edit,
                     --    THEN
                     --        IF the End Date of the Entered PA End Period is LATER than the End Date
                     --        of the PA Period Corresponding to the Completion Date of the Project
                     --           THEN
                     --             Issue error message.

                     IF ( (l_invalid_prj_dur_PA = 'N') AND (l_prj_completion_date IS NOT NULL) )
                        THEN


                        -- Find the Corresponding PA Period for the Project COMPLETION Date
                        -- AND save the PA Period's END date for subsequent processing

                        -- Issue: If project completion date does not have corresponding
                        --        period in GL_Periods, use the completion date.

                        BEGIN

                          SELECT End_Date
                          INTO   l_prj_PAper_end_date
                          FROM   Gl_Periods
                          WHERE  Period_Set_Name        = l_gl_period_set_name
                          AND    Period_Type            = l_PA_period_type
                          AND    Adjustment_Period_Flag = 'N'
                          and    l_prj_completion_date between start_date and end_date;


                          EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                               l_prj_PAper_END_date   := l_prj_completion_date;

                        END;


                        -- IF the END Date of the Entered PA Ending Period is LATER than the END Date
                        -- of the PA Period Corresponding to the COMPLETION Date of the Project
                        --         THEN  Issue error message.



                             IF ( l_PA_END_Date1 > l_prj_PAper_END_date)
                               THEN

                               x_return_status := FND_API.G_RET_STS_ERROR;
                               x_msg_count := x_msg_count + 1;
                               l_call_profile_pa_flag := 'N';
                               l_invalid_prj_dur_PA   := 'Y';
                               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                   , p_msg_name     => 'PA_FP_PP_INVALID_PRJ_DUR_PA');

                             END IF;

                     END IF; -- ENDING Period Edit

                 END IF;  -- (l_valid_PA_period_flag = 'Y


	         -- GL Period Validation
                 IF (l_valid_GL_period_flag = 'Y')
                     THEN


                   IF (l_prj_start_date IS NOT NULL)
                       THEN

                     -- STARTING Period Edit ----------------------------------------------

                     -- Find the Corresponding GL Period for the Project START Date
                     -- AND save the GL Period's START date for subsequent processing


                     -- Issue: If project start date does not have corresponding
                     --        period in GL_Periods, use the project start date.

                     BEGIN

                       SELECT Start_Date
                       INTO   l_prj_GLper_start_date
                       FROM   Gl_Periods
                       WHERE  Period_Set_Name        = l_gl_period_set_name
                       AND    Period_Type            = l_GL_period_type
                       AND    Adjustment_Period_Flag = 'N'
                       and    l_prj_start_date between start_date and end_date;


                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             l_prj_GLper_start_date   := l_prj_start_date;

                     END;


                     -- IF the Start Date of the Entered GL Start Period is EARLIER than the Start Date
                     -- of the GL Period Corresponding to the Start Date of the Project
                     --         THEN  Issue error message.

                     IF ( l_GL_START_date < l_prj_GLper_START_date)
                        THEN

                           x_return_status := FND_API.G_RET_STS_ERROR;
                           x_msg_count := x_msg_count + 1;
                           l_call_profile_gl_flag := 'N';
                           l_invalid_prj_dur_GL   := 'Y';
                           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                 , p_msg_name     => 'PA_FP_PP_INVALID_PRJ_DUR_GL');

                     END IF;

                   END IF; -- l_prj_start_date IS NOT NULL


                     -- ENDING Period Edit ----------------------------------------------

                     -- IF Project Completion Date Exists AND GL Periods Passed Previous Edit,
                     --    THEN
                     --        IF the End Date of the Entered GL End Period is LATER than the End Date
                     --        of the GL Period Corresponding to the Completion Date of the Project
                     --           THEN
                     --             Issue error message.

                     IF ( (l_invalid_prj_dur_GL = 'N') AND (l_prj_completion_date IS NOT NULL) )
                        THEN


                        -- Find the Corresponding GL Period for the Project COMPLETION Date
                        -- AND save the GL Period's END date for subsequent processing


                        -- Issue: If project completion date does not have corresponding
                        --        period in GL_Periods, use the completion date.

                        BEGIN

                          SELECT End_Date
                          INTO   l_prj_GLper_end_date
                          FROM   Gl_Periods
                          WHERE  Period_Set_Name        = l_gl_period_set_name
                          AND    Period_Type            = l_GL_period_type
                          AND    Adjustment_Period_Flag = 'N'
                          and    l_prj_completion_date between start_date and end_date;


                         EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                               l_prj_GLper_END_date   := l_prj_completion_date;

                        END;

                        -- IF the END Date of the Entered GL Ending Period is LATER than the END Date
                        -- of the GL Period Corresponding to the COMPLETION Date of the Project
                        --         THEN  Issue error message.

                        IF ( l_GL_END_Date1 > l_prj_GLper_END_date)
                           THEN

                             x_return_status := FND_API.G_RET_STS_ERROR;
                             x_msg_count := x_msg_count + 1;
                             l_call_profile_gl_flag := 'N';
                             l_invalid_prj_dur_GL   := 'Y';
                             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                                   , p_msg_name     => 'PA_FP_PP_INVALID_PRJ_DUR_GL');

                        END IF;

                     END IF; -- ENDING Period Edit

                 END IF;  -- GL Validation


        END IF; -- ( if pa/gl flags are Y ...


   -- Bug 2589885, End: ---------------------------------------------

     END IF; -- x_return_status = FND_API.G_RET_STS_SUCCESS


     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_msg_count := fnd_msg_pub.count_msg;
         IF x_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.Get_Messages (
                                      p_encoded        => FND_API.G_TRUE,
                                      p_msg_index      => 1,
                                      p_msg_count      => 1 ,
                                      p_msg_data       => l_msg_data ,
                                      p_data           => x_msg_data,
                                      p_msg_index_out  => l_msg_index_out );
         END IF;
         RETURN;
     END IF;

     IF p_old_pa_profile_id IS NOT NULL THEN
         SELECT PERIOD_NAME1 , PROFILE_END_PERIOD_NAME INTO
         l_old_pa_start_period,l_old_pa_end_period FROM
         Pa_Proj_Period_Profiles WHERE
         Period_Profile_Id = p_old_pa_profile_id;
         IF l_old_pa_start_period = p_pa_start_period AND
             l_old_pa_end_period   = p_pa_end_period       THEN
             l_call_profile_pa_flag := 'N';
         END IF;
     END IF;

     IF p_old_gl_profile_id IS NOT NULL THEN
         SELECT PERIOD_NAME1 , PROFILE_END_PERIOD_NAME INTO
         l_old_gl_start_period,l_old_gl_end_period FROM
         Pa_Proj_Period_Profiles WHERE
         Period_Profile_Id = p_old_gl_profile_id;
         IF l_old_gl_start_period = p_gl_start_period AND
             l_old_gl_end_period   = p_gl_end_period       THEN
             l_call_profile_gl_flag := 'N';
         END IF;
     END IF;

 IF l_call_profile_gl_flag = 'Y' THEN
    Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                        p_project_id          => p_project_id,
                        p_period_profile_type => p_period_profile_type,
                        p_plan_period_type    => 'GL',
                        p_period_set_name     => l_gl_period_set_name,
                        p_gl_period_type      => l_gl_period_type,
                        p_pa_period_type      => l_pa_period_type,
                        p_start_date          => l_gl_start_Date,
                        px_end_date           => l_gl_end_date1,
                        px_period_profile_id  => px_gl_period_profile_id,
                        p_commit_flag         => p_commit_flag,
                        px_number_of_periods  => px_gl_number_of_periods,
                        p_debug_mode          => p_debug_mode,
                        p_add_msg_in_stack    => p_add_msg_in_stack,
                        x_plan_start_date     => l_para_plan_start_date,
                        x_plan_end_date       => l_para_plan_end_date,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ROLLBACK;
         RETURN;
      END IF;
  END IF;
  IF l_call_profile_pa_flag = 'Y' THEN
    Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                        p_project_id          => p_project_id,
                        p_period_profile_type => p_period_profile_type,
                        p_plan_period_type    => 'PA',
                        p_period_set_name     => l_gl_period_set_name,
                        p_gl_period_type      => l_gl_period_type,
                        p_pa_period_type      => l_pa_period_type,
                        p_start_date          => l_pa_start_Date,
                        px_end_date           => l_pa_end_date1,
                        px_period_profile_id  => px_pa_period_profile_id,
                        p_commit_flag         => p_commit_flag,
                        px_number_of_periods  => px_pa_number_of_periods,
                        p_debug_mode          => p_debug_mode,
                        p_add_msg_in_stack    => p_add_msg_in_stack,
                        x_plan_start_date     => l_para_plan_start_date,
                        x_plan_end_date       => l_para_plan_end_date,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ROLLBACK;
         RETURN;
      END IF;
  END IF;

  /* even if the concurrent program request fails, the modified period
     information should be saved   */

  IF l_call_profile_gl_flag = 'Y' OR
     l_call_profile_pa_flag = 'Y' THEN
     COMMIT;
  END IF;

  IF p_refresh_option_code <> 'NONE' THEN
    /* calling the concurrent program */
             fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

             IF l_call_profile_gl_flag = 'Y' THEN
                l_conc_gl_profile_id :=  px_gl_period_profile_id;
             ELSE
                l_conc_gl_profile_id :=  p_old_gl_profile_id;
             END IF;
             IF l_call_profile_pa_flag = 'Y' THEN
                l_conc_pa_profile_id :=  px_pa_period_profile_id;
             ELSE
                l_conc_pa_profile_id :=  p_old_pa_profile_id;
             END IF;

             l_rpt_request_id := FND_REQUEST.submit_request
             (application                =>   'PA',
              program                    =>   'PAPDPROF',
              description                =>   'PRC: Refresh Plan Versions Period Profile',
              start_time                 =>   NULL,
              sub_request                =>   false,
              argument1                  =>   NULL,
              argument2                  =>   NULL,
              argument3                  =>   p_project_id,
              argument4                  =>   p_refresh_option_code,
              argument5                  =>   l_conc_gl_profile_id,
              argument6                  =>   l_conc_pa_profile_id,
              argument7                  =>   l_debug_mode );

          IF l_rpt_request_id = 0 then
             IF P_PA_DEBUG_MODE = 'Y' THEN
                     PA_DEBUG.g_err_stage := 'Error while submitting Report [PAFPEXRP]';
                     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_PP_CONC_PGM_ERR');
             x_return_status := FND_API.G_RET_STS_ERROR;
             ROLLBACK;
             RETURN;
          ELSE
             /* added for locking the budget versions  */
                l_bv_id_tab.DELETE;
                l_locked_person_id_tab.DELETE;
                l_plan_proc_code_tab.DELETE;
                IF (p_refresh_option_code = 'ALL') THEN
                  SELECT budget_version_id,
                         locked_by_person_id,
                         plan_processing_Code
                  BULK COLLECT INTO
                       l_bv_id_tab,
                       l_locked_person_id_tab,
                       l_plan_proc_code_tab
                  FROM
                        Pa_budget_versions
                  WHERE
                  project_id = p_project_id
                  AND period_profile_id IS NOT NULL;
                ELSIF (p_refresh_option_code = 'SELECTED') THEN
                  SELECT budget_version_id,
                         locked_by_person_id,
                         plan_processing_Code
                  BULK COLLECT INTO
                       l_bv_id_tab,
                       l_locked_person_id_tab,
                       l_plan_proc_code_tab
                  FROM
                        Pa_budget_versions
                  WHERE
                        project_id = p_project_id
                  AND period_profile_id IS NOT NULL
                  AND
                  (
                        (current_working_flag = 'Y' AND budget_status_code IN ('W','S'))
                    OR  (current_flag = 'Y' AND budget_status_code = 'B')
                    OR  (current_original_flag = 'Y' AND budget_status_code = 'B')
                  );
                END IF;
                /* FOR l_idx IN 1 .. l_bv_id_tab.COUNT LOOP
                    IF l_locked_person_id_tab IS NULL THEN
                       UPDATE
                    END IF;
                END LOOP;  */
                /* PPP - Period Profile refresh in Process */
				/* Commented code from here for 7563735, locking will be done in the procedure Maintain_Prj_Period_Profile now.
                FORALL ii IN 1 .. l_bv_id_tab.COUNT
                UPDATE pa_budget_versions SET
                       plan_processing_code = 'PPP',
                       locked_by_person_id  = -98,
                       request_id           = l_rpt_request_id,
                       record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate
                WHERE
                       budget_version_id = l_bv_id_tab(ii) AND
                       locked_by_person_id IS NULL; */

             IF P_PA_DEBUG_MODE = 'Y' THEN
                     PA_DEBUG.g_err_stage := 'Exception Report Request Id : ' ||
                                              LTRIM(TO_CHAR(l_rpt_request_id )) ;
                     PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                           p_write_file => 'OUT',
                                           p_write_mode => 1);
                     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;
          END IF;
          x_conc_req_id := LTRIM(RTRIM(TO_CHAR(l_rpt_request_id)));
    END IF;
 IF x_return_Status = FND_API.G_RET_STS_SUCCESS THEN
    COMMIT;
 ELSE
    ROLLBACK;
 END IF;

 EXCEPTION
     WHEN OTHERS THEN
	    px_pa_end_date := nc_pa_end_date;
	    px_pa_period_profile_id := nc_pa_period_profile_id;
	    px_pa_number_of_periods := nc_pa_number_of_periods;
	    px_gl_end_date := nc_gl_end_date;
	    px_gl_period_profile_id := nc_gl_period_profile_id;
	    px_gl_number_of_periods := nc_gl_number_of_periods;
        RAISE;

END Maintain_Prj_Profile_wrp;


--###
--Name:              	Get_Prj_Defaults
--Type:               	Procedure
--
--Description:
--Called subprograms: none
--
--
--
--History:
--      14-NOV-2001     SManivannan   - Created
--
--   	17-MAR-03	jwhite        - Bug 2589885
--                                      Add two new parameters to Get_Prj_Defaults:
--                                      -  x_prj_start_date  OUT VARCHAR2
--                                      -  x_prj_end_date    OUT VARCHAR2
--                                      Also, add code to populate the project
--                                      start- and end-date parameters.
--
--      03-JUN-03       vejayara      - Bug2987076 - Start period info assigned as
--                                      end period whenever start period is derived.



Procedure Get_Prj_Defaults( p_project_id IN NUMBER,
                            p_info_flag  IN VARCHAR2,
                            p_create_defaults IN VARCHAR2, --Y or N
                             x_gl_start_period OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_gl_end_period OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_gl_start_Date OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_pa_start_period OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_pa_end_period OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                             x_pa_start_date   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_plan_version_exists_flag OUT NOCOPY VARCHAR2,           --File.Sql.39 bug 4440895
                             x_prj_start_date  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_prj_end_date   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ) IS

        l_prj_Start_date DATE;
        l_prj_completion_date DATE;
        l_prj_org_id NUMBER;
        l_count NUMBER := 0;
        l_profile_count NUMBER := 0;

        l_dummy_pa_end_date             DATE;
        l_dummy_gl_end_date             DATE;
        l_pd_gl_end_date                DATE;
        l_pd_pa_end_date                DATE;

        l_dummy_pa_period_profile_id    pa_proj_period_profiles.period_profile_id%TYPE;
        l_dummy_gl_period_profile_id    pa_proj_period_profiles.period_profile_id%TYPE;
        l_dummy_pa_number_of_periods    NUMBER;
        l_dummy_gl_number_of_periods    NUMBER;
        l_dummy_pa_plan_start_date      DATE;
        l_dummy_pa_plan_end_date        DATE;
        l_dummy_gl_plan_start_date      DATE;
        l_dummy_gl_plan_end_date        DATE;
        l_dummy_pa_period_profile_type  pa_proj_period_profiles.period_profile_type%TYPE;
        l_dummy_gl_period_profile_type  pa_proj_period_profiles.period_profile_type%TYPE;

        /* Commenting for bug 7578853
        CURSOR end_period_cur(c_period_set_name varchar2,
                              c_period_type     varchar2,
                              c_start_Date      date ) IS
                 SELECT Period_Name,Start_Date,
                        End_Date FROM Gl_Periods WHERE
                 Period_Set_Name = c_period_set_name AND
                 Period_Type = c_period_type  AND Start_Date > c_start_date AND
                  Adjustment_Period_Flag = 'N' AND ROWNUM < 52
                 ORDER BY Start_Date;
        */

        -- Added for bug 7578853
        CURSOR end_period_cur(c_period_set_name varchar2,
                              c_period_type     varchar2,
                              c_start_Date      date ) IS
          SELECT Period_Name,Start_Date, End_Date
          FROM
          (
            SELECT Period_Name,Start_Date, End_Date
            FROM Gl_Periods
            WHERE Period_Set_Name = c_period_set_name AND
                  Period_Type = c_period_type AND Start_Date > c_start_date AND
                  Adjustment_Period_Flag = 'N'
            ORDER BY Start_Date
          )
          WHERE ROWNUM < 52;

        l_period_set_name Gl_Periods.Period_Set_Name%TYPE;
        l_gl_period_type     Gl_Periods.Period_Type%TYPE;
        l_pa_period_type     Gl_Periods.Period_Type%TYPE;

        l_return_status      VARCHAR2(2000);
        l_msg_count          NUMBER := 0;
        l_msg_data           VARCHAR2(2000);
        l_create_pa_profile  VARCHAR2(1) := 'N';
        l_create_gl_profile  VARCHAR2(1) := 'N';
BEGIN
      x_gl_start_period := null;
      x_gl_end_period   := null;
      x_gl_start_Date   := null;
      x_pa_start_period := null;
      x_pa_end_period   := null;
      x_pa_start_date   := null;
      x_plan_version_exists_flag := 'N';
         SELECT COUNT(*) INTO l_count FROM Pa_Budget_Versions
                           WHERE Project_Id = p_project_id AND
                                Period_Profile_Id IS NOT NULL AND
                                Period_Profile_Id > 0;
         IF l_count > 0 THEN
            x_plan_version_exists_flag := 'Y';
         END IF;

    -- Bug 2589885, 17-MAR-03, jwhite, begin: --------------------------

/*    -- Original Code -----------------------
      IF p_info_flag <> 'ALL' THEN
         RETURN;
      END IF;
*/

      -- New Code, begin:-----------------------------
      -- MOVED original code BELOW since this procedure must now always run
      -- to populate the following filters for the page LOVs:
      -- 1)  x_prj_start_date
      -- 2)  x_prj_end_date



      -- New Code, end: -----------------------------


    -- Bug 2589885, 17-MAR-03, jwhite, end: --------------------------


      SELECT COUNT(*) INTO l_profile_count
      FROM pa_proj_period_profiles
      WHERE
      project_id = p_project_id AND
      period_profile_type = 'FINANCIAL_PLANNING' AND
      plan_period_type    = 'PA';
      IF l_profile_count = 0 THEN
         l_create_pa_profile := 'Y';
      END IF;
      SELECT COUNT(*) INTO l_profile_count
      FROM pa_proj_period_profiles
      WHERE
      project_id = p_project_id AND
      period_profile_type = 'FINANCIAL_PLANNING' AND
      plan_period_type    = 'GL';
      IF l_profile_count = 0 THEN
         l_create_gl_profile := 'Y';
      END IF;


      BEGIN

    -- Bug 2589885, 17-MAR-03, jwhite, begin: --------------------------

/*    -- Original Code -----------------------

         SELECT start_Date, completion_date, nvl(org_id,-99)
         INTO
                l_prj_start_date,l_prj_completion_date,l_prj_org_id FROM
                  Pa_Projects_All WHERE
         Project_Id = p_project_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN;
      END;



*/

      -- New Code, begin:-----------------------------

/* Bug 3354518- FP.M -dbora- Modified the sql statement associated with the start_date select
 */
         SELECT nvl(start_Date, trunc(sysdate))
                , completion_date
                , nvl(org_id,-99)
                , decode (start_date, NULL, NULL, TO_CHAR(start_date,'rrrr/mm/dd') )
                , decode (completion_date, NULL, NULL, TO_CHAR(completion_date,'rrrr/mm/dd') )
         INTO  l_prj_start_date
                ,l_prj_completion_date
                ,l_prj_org_id
                ,x_prj_start_date
                ,x_prj_end_date
         FROM  Pa_Projects_All
         WHERE     Project_Id = p_project_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_prj_start_date := NULL;
         x_prj_end_date   := NULL;
         RETURN;

      END; -- select start_date


      -- Original Code from ABOVE put here to make sure that the following
      -- OUT-parameters will always be populated for the page LOVs
      -- 1)  x_prj_start_date
      -- 2)  x_prj_end_date

      IF p_info_flag <> 'ALL' THEN
         RETURN;
      END IF;



    -- New Code, end: -----------------------------


    -- Bug 2589885, 17-MAR-03, jwhite, end: --------------------------



      BEGIN
         SELECT imp.Period_Set_Name,imp.Pa_Period_Type,sob.Accounted_Period_Type
                INTO l_period_set_name , l_pa_period_type,l_gl_period_type
         FROM Pa_Implementations_All imp, Gl_Sets_Of_Books sob WHERE
         --NVL(imp.Org_Id,-99)  = l_prj_org_id AND
	 imp.Org_Id = l_prj_org_id AND -- Bug Ref # 6327662
         imp.Set_Of_Books_Id = sob.Set_Of_Books_Id;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              RETURN;
      END;

      IF l_prj_start_date IS NOT NULL THEN
          BEGIN
             SELECT gl.Period_Name,TO_CHAR(glp.start_Date,'rrrr/mm/dd'),
                       glp.end_date
                       INTO x_gl_start_period,x_gl_start_date,
                       l_pd_gl_end_date
               FROM
              Gl_Date_Period_Map gl,
              gl_periods glp WHERE
              gl.Period_Set_Name = l_period_set_name AND
              gl.Period_Type     = l_gl_period_type AND
              gl.Accounting_Date = l_prj_start_date AND
              glp.period_set_name = gl.Period_Set_Name AND
              glp.Period_Type    = gl.Period_Type  AND
              glp.adjustment_period_flag = 'N' AND
              glp.period_name = gl.period_name;

              /* Assigned start period info as end period info for bug# 2987076 */
              x_gl_end_period := x_gl_start_period;
              l_dummy_gl_end_date := l_pd_gl_end_Date;
              /* modified the above assignment from x_gl_start_date to
                 period end date (l_pd_gl_end_date ) for bug 3045693 */

              EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
          END;
          BEGIN
             SELECT gl.Period_Name,TO_CHAR(glp.start_Date,'rrrr/mm/dd'),
                           glp.end_date
                           INTO x_pa_start_period,x_pa_start_date,
                                l_pd_pa_end_date
               FROM
             Gl_Date_Period_Map gl,
             gl_periods glp WHERE
             gl.Period_Set_Name = l_period_set_name AND
             gl.Period_Type     = l_pa_period_type AND
             gl.Accounting_Date = l_prj_start_date AND
             glp.period_set_name = gl.Period_Set_Name AND
             glp.Period_Type    = gl.Period_Type  AND
             glp.adjustment_period_flag = 'N' AND
             glp.period_name = gl.period_name;

              /* Assigned start period info as end period info for bug# 2987076 */
              x_pa_end_period := x_pa_start_period;
              l_dummy_pa_end_date := l_pd_pa_end_date;
              /* modified the above assignment from x_pa_start_date to
                 period end date (l_pd_pa_end_date ) for bug 3045693 */
             EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
          END;
         /* setting the end periods */
         /* check for prj_completion date to null removed
            for bug 2581913 */
            FOR cur_rec IN end_period_cur(l_period_Set_name,
                                          l_pa_period_type,
                                          l_prj_start_Date )
                                            LOOP
                IF cur_rec.start_date > l_prj_completion_date  AND
                   l_prj_completion_date IS NOT NULL THEN
                   EXIT;
                END IF;
                x_pa_end_period := cur_rec.period_name;

                /* review changes. msoundra 02-JAN-2003.
                   End date should not be passed as NULL. If passed as NULL,
                   the default profile would be created for the maximum periods
                   ( 52 or less ) regardless of the proj completion date. */

                l_dummy_pa_end_date := cur_rec.end_date;
            END LOOP;

            FOR cur_rec IN end_period_cur(l_period_Set_name,
                                          l_gl_period_type,
                                          l_prj_start_Date )
                                            LOOP
                IF cur_rec.start_date > l_prj_completion_date AND
                   l_prj_completion_date IS NOT NULL THEN
                   EXIT;
                END IF;
                x_gl_end_period := cur_rec.period_name;

                /* review changes. msoundra 02-JAN-2003.
                   End date should not be passed as NULL. If passed as NULL,
                   the default profile would be created for the maximum periods
                   ( 52 or less ) regardless of the proj completion date. */

                l_dummy_gl_end_date := cur_rec.end_date;
            END LOOP;
      END IF;

      /* Bug 2689403 - If we are able derive a default for pa period profile dtls,
         create the same immediately and commit it before the period profile page is rendered.
         The period profile page would then fetch the queried record to be displayed on screen */

      /* The default period profile info just derived needs to created (inserted) for the project
         only when p_create_defaults */

      IF p_create_defaults = 'Y' THEN

      IF x_pa_start_date IS NOT NULL AND
         l_create_pa_profile = 'Y' THEN

          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Calling Maintain_Prj_Period_Profile to create the PA period profile ....';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                          p_project_id          => p_project_id,
                          p_period_profile_type => 'FINANCIAL_PLANNING',
                          p_plan_period_type    => 'PA',
                          p_period_set_name     => l_period_set_name,
                          p_gl_period_type      => l_gl_period_type,
                          p_pa_period_type      => l_pa_period_type,
                          p_start_date          => to_date(x_pa_start_date,'rrrr/mm/dd'),
                          px_end_date           => l_dummy_pa_end_date ,
                          px_period_profile_id  => l_dummy_pa_period_profile_id,
                          p_commit_flag         => 'Y',
                          px_number_of_periods  => l_dummy_pa_number_of_periods,
                          p_debug_mode          => 'Y',
                          p_add_msg_in_stack    => 'Y',
                          x_plan_start_date     => l_dummy_pa_plan_start_date,
                          x_plan_end_date       => l_dummy_pa_plan_end_date,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := ' Maintain_Prj_Period_Profile Errored for PA';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

      END IF;

      /* Bug 2689403 - If we are able derive a default for gl period profile dtls,
         create the same immediately and commit it before the period profile page is rendered.
         The period profile page would then fetch the queried record to be displayed on screen */

      IF x_gl_start_date IS NOT NULL AND
         l_create_gl_profile = 'Y' THEN
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Calling Maintain_Prj_Period_Profile to create the GL period profile ....';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                          p_project_id          => p_project_id,
                          p_period_profile_type => 'FINANCIAL_PLANNING',
                          p_plan_period_type    => 'GL',
                          p_period_set_name     => l_period_set_name,
                          p_gl_period_type      => l_gl_period_type,
                          p_pa_period_type      => l_pa_period_type,
                          p_start_date          => to_date(x_gl_start_date,'rrrr/mm/dd'),
                          px_end_date           => l_dummy_gl_end_date ,
                          px_period_profile_id  => l_dummy_gl_period_profile_id,
                          p_commit_flag         => 'Y',
                          px_number_of_periods  => l_dummy_gl_number_of_periods,
                          p_debug_mode          => 'Y',
                          p_add_msg_in_stack    => 'Y',
                          x_plan_start_date     => l_dummy_gl_plan_start_date,
                          x_plan_end_date       => l_dummy_gl_plan_end_date,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := ' Maintain_Prj_Period_Profile Errored for PA';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
      END IF;
      END IF;
      RETURN;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= l_msg_data;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
            pa_debug.g_err_stage := sqlerrm;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE;
END Get_Prj_Defaults;

/*===================================================================
  This api returns the current period profile id,start period and end
  period for givenproject id, plan period type and period profile type
  ==================================================================*/

PROCEDURE Get_Curr_Period_Profile_Info(
             p_project_id           IN VARCHAR2
             ,p_period_type         IN VARCHAR2
             ,p_period_profile_type IN VARCHAR2
             ,x_period_profile_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_start_period        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_end_period          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data            OUT NOCOPY VARCHAR2  ) --File.Sql.39 bug 4440895
AS


    l_return_status      VARCHAR2(2000);
    l_msg_count          NUMBER :=0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    l_period_profile_id  pa_proj_period_profiles.period_profile_id%TYPE;
    l_start_period       pa_proj_period_profiles.period_name1%TYPE;
    l_end_period         pa_proj_period_profiles.profile_end_period_name%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.set_err_stack('Get_Curr_Period_Profile_Info');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Get_Curr_Period_Profile_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    -- Check for not null parameters

    pa_debug.g_err_stage := 'Checking for valid parameters:';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id  IS NULL)   OR
       (p_period_type  NOT IN (PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL,PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA)) OR
       (p_period_profile_type IS NULL)
    THEN

        pa_debug.g_err_stage := 'Project='||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.g_err_stage := 'Period_type='||p_period_type;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.g_err_stage := 'P_period_profile_type='||p_period_profile_type;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage := 'Parameter validation complete';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch Profile Info

    BEGIN

         pa_debug.g_err_stage := 'Fetching Profile Info';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

         SELECT period_profile_id
                ,period_name1
                ,profile_end_period_name
         INTO   l_period_profile_id
                ,l_start_period
                ,l_end_period
         FROM   pa_proj_period_profiles
         WHERE  project_id = p_project_id
         AND    current_flag = 'Y'
         AND    period_profile_type = p_period_profile_type
         AND    plan_period_type = p_period_type;

    EXCEPTION

         WHEN NO_DATA_FOUND THEN

              --There is no current profile for project.return null

              pa_debug.g_err_stage := 'Current period profile doesnt exist for project';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;

              l_period_profile_id :=  NULL;
              l_start_period      :=  NULL;
              l_end_period        :=  NULL;

    END;

    --Pass out_parameters to calling program

    x_period_profile_id := l_period_profile_id;
    x_start_period      := l_start_period;
    x_end_period        := l_end_period;


    pa_debug.g_err_stage := ' Exiting Get_Curr_Period_Profile_Info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.reset_err_stack;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN

             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);

             x_msg_data := l_data;
             x_msg_count := l_msg_count;

        ELSE

            x_msg_count := l_msg_count;

        END IF;

         pa_debug.g_err_stage:='Invalid Arguments Passed';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;

         x_return_status:= FND_API.G_RET_STS_ERROR;

         pa_debug.reset_err_stack;

         RAISE;

   WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_PRJ_PERIOD_PROFILE_UTILS'
                        ,p_procedure_name  => 'Get_Curr_Period_Profile_Info');

        pa_debug.g_err_stage:='Unexpected Error' || SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Period_Profile_Info: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        pa_debug.reset_err_stack;

        RAISE;

END Get_Curr_Period_Profile_Info;

/*
        NEED TO CUT THE FUNCTION AND THE PROCEDURE BELOW
        AND PASTE THESE IN THE PERIOD PROFILES PACKAGE
*/
--This function is a local function and is not exposed to other APIs
--This is used to calculate the amount type id based on the amount
--type code passed to it
FUNCTION GET_AMTTYPE_ID
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE
                              := NULL
  ) RETURN NUMBER IS
    l_amount_type_id pa_amount_types_b.amount_type_id%TYPE;
    l_amt_code pa_fp_org_fcst_gen_pub.char240_data_type_table;
    l_amt_id   pa_fp_org_fcst_gen_pub.number_data_type_table;

    l_debug_mode VARCHAR2(30);

    CURSOR get_amt_det IS
    SELECT atb.amount_type_id
          ,atb.amount_type_code
      FROM pa_amount_types_b atb
     WHERE atb.amount_type_class = 'R';

    l_stage number := 0;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_PLAN_MATRIX.GET_AMTTYPE_ID');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('GET_AMTTYPE_ID: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

       l_amount_type_id := -99;

       IF l_amt_code.last IS NULL THEN
          OPEN get_amt_det;
          LOOP
              FETCH get_amt_det into l_amt_id(nvl(l_amt_id.last+1,1))
                                    ,l_amt_code(nvl(l_amt_code.last+1,1));
              EXIT WHEN get_amt_det%NOTFOUND;
          END LOOP;
       END IF;

       IF l_amt_code.last IS NOT NULL THEN
          FOR i in l_amt_id.first..l_amt_id.last LOOP
              IF l_amt_code(i) = p_amt_typ_code THEN
                 l_amount_type_id := l_amt_id(i);
              END IF;
          END LOOP;
       END IF;
       IF l_amount_type_id = -99 THEN
                 pa_debug.g_err_stage := 'p_amt_typ_code         ['||p_amt_typ_code          ||']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('GET_AMTTYPE_ID: ' || pa_debug.g_err_stage);
                 END IF;
       END IF;
       pa_debug.reset_err_stack;
       RETURN(l_amount_type_id);

EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_GEN_PUB.get_amttype_id'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('GET_AMTTYPE_ID: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
              RAISE;
END GET_AMTTYPE_ID;

--This API is called on refresh of period profiles.
--The API deletes current record from the pa_proj_periods_denorm table
--for the budget version passed to it. It then populates the
--Pa_Fin_Plan_Lines_Tmp table from the records in the Pa_Budget_Lines
--table. The API then calls the Maintain Plan Matrix API to populate
--the budget lines table with preceding and succeeding period values and
--inserts the current period amounts in the pa_proj_periods_denorm table

PROCEDURE Refresh_Period_Profile
                (
                        p_budget_version_id             IN NUMBER,
                        p_period_profile_id             IN NUMBER,
                        p_project_id                    IN NUMBER,
                        x_return_status                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                )
IS
-- Local Variable Declaration
       l_budget_version_id      NUMBER;
       l_period_profile_id      NUMBER;
       l_project_id             NUMBER;
       l_version_type           VARCHAR2(30);
       l_data_source            VARCHAR2(30);
       l_debug_mode             VARCHAR2(30);
       amt_rec                  PA_PLAN_MATRIX.AMOUNT_TYPE_TABTYP;
       l_request_id NUMBER;
BEGIN
       l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
-- Setting the Debug Statements
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Set_Curr_Function( p_function   => 'Refresh_Period_Profile',
                                        p_debug_mode => l_debug_mode );
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Entering Refresh Period Profile ' ||
                'for Refreshing the Period Profile';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Concurrent request id :' ||
                             to_char(nvl(l_request_id,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

-- Set the savepoint to return if any of the merges fail
-- for control items

savepoint before_refresh_pd_profile;

--Checking for the budget version id to be null
--If budget version id is null then no processing will take place as there is no
--record in denorm for that budget version id. If no record then it is the case
--of creating a new profile rather than refreshing an existing profile.
        IF p_budget_version_id IS NULL THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'No Budget Version ID is specified ' ||
                         'or budget version id is null';
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
              /*   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => 'NULL_BDGT_VSN_ID');
                        invalid message code, so commented */
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 /* x_msg_data      := 'NULL_BDGT_VSN_ID';  */
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.Reset_Curr_Function;
                 END IF;
                 RETURN;
        END IF;
-- Setting local variable values
        l_data_source := 'BUDGET_LINES';
        l_budget_version_id := p_budget_version_id;
        --l_period_profile_id := p_period_profile_id;
        l_version_type      := NULL;

-- Fix for P1 bug 2682761
-- Updating budget versions table for this budget version
-- before calling call maintain plan matrix

     UPDATE pa_budget_versions bv
     SET bv.period_profile_id = p_period_profile_id,
         record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate
     WHERE bv.budget_version_id = l_budget_version_id
     AND bv.project_id = p_project_id;

   /*

-- Calling the API to populate the Pa_Fin_Plan_Lines_Tmp table
        PA_FIN_PLAN_PUB.CALL_MAINTAIN_PLAN_MATRIX
        (
                p_budget_version_id     => l_budget_version_id,
                p_data_source           => l_data_source,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
        );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO before_refresh_pd_profile;
            UPDATE_BUDGET_VERSION(p_budget_version_id => l_budget_version_id,
                                  p_return_status     => x_return_status,
                                  p_project_id        => p_project_id,
                                  p_request_id        => l_request_id );
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.Reset_Curr_Function;
                 END IF;
            RETURN;
        END IF;

--Calling the ROLL UP API for denorm amounts to aggregate all the records
--The Roll up API that is being called, simply assumes that all parent
--level records for the updated records are available in denorm table.
--This API simply takes sum of amounts at child level records and
--updates the amounts on the parents.
        PA_FP_ROLLUP_PKG.ROLLUP_DENORM_AMOUNTS
        (
                  p_budget_version_id => l_budget_version_id
                 ,x_return_status     => x_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
        );
         Refresh period denorm API takes care of deleting all the
         period denorm records for the given budget version and
         then populate user entered and rollup records.
   */

        PA_FP_ROLLUP_PKG.Refresh_Period_Denorm(
                  p_budget_version_id => l_budget_version_id
                 ,x_return_status     => x_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data    );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO before_refresh_pd_profile;
            UPDATE_BUDGET_VERSION(p_budget_version_id => l_budget_version_id,
                                  p_return_status     => x_return_status,
                                  p_project_id        => p_project_id,
                                  p_request_id        => l_request_id );
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.Reset_Curr_Function;
                 END IF;
            RETURN;
        END IF;

        /* updating budget version for Successful completion. */
        UPDATE_BUDGET_VERSION(p_budget_version_id => l_budget_version_id,
                                  p_return_status     => x_return_status,
                                  p_project_id        => NULL,
                                  p_request_id        => l_request_id );

COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_PRJ_PERIOD_PROFILE_UTILS.refresh_period_profile'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in refresh_period_profile ';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        ROLLBACK TO before_refresh_pd_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        UPDATE_BUDGET_VERSION(p_budget_version_id => l_budget_version_id,
                              p_return_status     => x_return_status,
                              p_project_id        => p_project_id,
                              p_request_id        => l_request_id );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;
END Refresh_Period_Profile;

PROCEDURE Wrapper_Refresh_Pd_Profile
                (
                        errbuff                         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        retcode                         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        p_budget_version_id1            IN NUMBER,
                        p_budget_version_id2            IN NUMBER,
                        p_project_id                    IN NUMBER,
                        p_refresh_option_code           IN VARCHAR2,
                        p_gl_period_profile_id          IN NUMBER,
                        p_pa_period_profile_id          IN NUMBER,
                        p_debug_mode                    IN VARCHAR2
                )
IS
-- Local Variable Declaration
        l_budget_version_id             NUMBER;
        l_budget_version_id1            NUMBER;
        l_budget_version_id2            NUMBER;
        l_project_id                    NUMBER;
        l_refresh_option_code           VARCHAR2(30);
        l_gl_period_profile_id          NUMBER;
        l_pa_period_profile_id          NUMBER;
        l_time_phased_code              VARCHAR2(30);
        l_return_status                 VARCHAR2(2000);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_count                         NUMBER;
        TYPE   budget_version_id_tab    IS   TABLE OF PA_BUDGET_VERSIONS.budget_version_id%type
        INDEX BY BINARY_INTEGER;
        t_budget_version_id               budget_version_id_tab;
        l_request_id                 NUMBER;
        l_locked_person_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
        l_plan_proc_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;
        l_req_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
--Bug 7563735 Locking the records in cursor
				cursor c is
		select budget_version_id
		FROM   Pa_budget_versions
        WHERE  project_id = l_project_id
		FOR UPDATE;
BEGIN
-- Setting the Debug Statements
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Set_Curr_Function( p_function   => 'Wrapper_Refresh_Pd_Profile',
                                        p_debug_mode => p_debug_mode );
        END IF;
        l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;

        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Entering Refresh Period Profile WRAPPER ' ||
                'for Conc Request Id :'||to_char(nvl(l_Request_id,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Parameters : ';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Budget version id1 : '||
                                     to_char(nvl(p_budget_Version_id1,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Budget version id2 : '||
                                     to_char(nvl(p_budget_Version_id2,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Project Id : '||
                                     to_char(nvl(p_project_id,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Refresh option code : '||
                                     nvl(p_refresh_option_code,'NULL');
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Pa Profile Id : '||
                                     to_char(nvl(p_pa_period_profile_id,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                PA_DEBUG.g_err_stage := 'Gl Profile Id : '||
                                     to_char(nvl(p_gl_period_profile_id,0));
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        retcode := '0';

 /* Setting local variable values  */
        l_budget_version_id     := NULL;
        l_budget_version_id1    := p_budget_version_id1;
        l_budget_version_id2    := p_budget_version_id2;
        l_project_id            := p_project_id;
        l_refresh_option_code   := p_refresh_option_code;
        l_gl_period_profile_id  := p_gl_period_profile_id;
        l_pa_period_profile_id  := p_pa_period_profile_id;
        l_time_phased_code      := NULL;
        l_return_status         := NULL;
        l_msg_count             := NULL;
        l_msg_data              := NULL;
        l_count                 := 1;

  /* Deleting any records from the PL/SQL table     */
        t_budget_version_id.DELETE;
        l_req_id_tab.DELETE;
        l_locked_person_id_tab.DELETE;
        l_plan_proc_code_tab.DELETE;

/* Changes for 7563735 - Setting the locked_by_person_id here, and opening cursor c so that sql lock is obtained on those*/

		UPDATE pa_budget_versions SET
                       plan_processing_code = 'PPP',
                       locked_by_person_id  = -98,
                       request_id = l_request_id, /* 8338971 */
                       record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate
                WHERE
                       project_id = l_project_id
                       --locked_by_person_id IS NULL
                                           AND period_profile_id IS NOT NULL;
             /* added for locking the budget versions  */

        open c;
        close c;
/* End Changes for 7563735 - Setting the locked_by_person_id here, and opening cursor c so that sql lock is obtained on those*/
  /* Would go inside this loop only if one of the budget version ids
     is not null */
        IF (l_budget_version_id1 IS NOT NULL OR l_budget_version_id2 IS NOT NULL) THEN
                -- For budget version id 1
                IF l_budget_version_id1 IS NOT NULL THEN
                        t_budget_version_id(l_count) := l_budget_version_id1;
                   select
                         nvl(locked_by_person_id,0),
                         nvl(plan_processing_code,'DUMMY'),
                         nvl(request_id,0) into
                         l_locked_person_id_tab(l_count),
                         l_plan_proc_code_tab(l_count),
                         l_req_id_tab(l_count)
                   from pa_budget_versions where
                        budget_version_id = l_budget_version_id1;


                        l_count := l_count + 1;
                END IF;
                -- For budget version id 2
                IF l_budget_version_id2 IS NOT NULL THEN
                        t_budget_version_id(l_count) := l_budget_version_id2;
                   select
                         nvl(locked_by_person_id,0),
                         NVL(plan_processing_code,'DUMMY'),
                         nvl(request_id,0) into
                         l_locked_person_id_tab(l_count),
                         l_plan_proc_code_tab(l_count),
                         l_req_id_tab(l_count)
                   from pa_budget_versions where
                        budget_version_id = l_budget_version_id2;

                        l_count := l_count + 1;
                END IF;
/* Checking for the refresh option code to be NOT null
If refresh option code is null then the processing should
transfer to checking the two budget version ids. If they are
also null then the process should exit and do nothing in the program

 Check for refresh option code. This WOULD BE NULL under following
 two conditions:
 1) If this API is being called from View Plans Page
 2) If the user chooses no plan version to refresh while refreshing period profiles   */

        ELSIF l_refresh_option_code IS NOT NULL THEN
        --Processing ahead only if project id is not null
           IF l_project_id IS NOT NULL THEN
                --Processing for refresh option code of ALL
                IF (l_refresh_option_code = 'ALL') THEN
                  SELECT budget_version_id,
                         nvl(locked_by_person_id,0),
                         NVL(plan_processing_code,'DUMMY'),
                         nvl(request_id,0)
                  BULK COLLECT INTO
                         t_budget_version_id,
                         l_locked_person_id_tab,
                         l_plan_proc_code_tab,
                         l_req_id_tab
                  FROM
                        Pa_budget_versions
                  WHERE
                  project_id = l_project_id
                  AND period_profile_id IS NOT NULL;
                ELSIF (l_refresh_option_code = 'SELECTED') THEN
                  SELECT budget_version_id,
                         nvl(locked_by_person_id,0),
                         nvl(plan_processing_code,'DUMMY'),
                         nvl(request_id,0)
                  BULK COLLECT INTO
                         t_budget_version_id,
                         l_locked_person_id_tab,
                         l_plan_proc_code_tab,
                         l_req_id_tab
                  FROM
                        Pa_budget_versions
                  WHERE
                        project_id = l_project_id
                  AND period_profile_id IS NOT NULL
                  AND
                  (
                        (current_working_flag = 'Y' AND budget_status_code IN ('W','S'))
                    OR  (current_flag = 'Y' AND budget_status_code = 'B')
                    OR  (current_original_flag = 'Y' AND budget_status_code = 'B')
                  );
                END IF;
           END IF;
        END IF;
        FOR l_cnt IN 1 .. t_budget_version_id.count
        LOOP
        l_budget_version_id := t_budget_version_id(l_cnt);
                BEGIN
                SELECT
                DECODE
                        (po.fin_plan_preference_code,
                        'COST_ONLY',po.cost_time_phased_code,
                        'REVENUE_ONLY',po.revenue_time_phased_code,
                        'COST_AND_REV_SAME',po.all_time_phased_code,
                        DECODE
                                (bv.version_type,
                                'COST',po.cost_time_phased_code,
                                'REVENUE',po.revenue_time_phased_code
                                )
                        )
                INTO
                        l_time_phased_code
                FROM pa_budget_versions bv, pa_proj_fp_options po
                WHERE
                        bv.budget_version_id = l_budget_version_id
                AND     po.fin_plan_version_id = bv.budget_version_id
                AND     po.fin_plan_option_level_code = 'PLAN_VERSION'
                AND     bv.project_id = p_project_id
                AND     po.project_id = bv.project_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                                PA_DEBUG.g_err_stage := 'No data found while trying ' ||
                                'to retrive data for time phased code FOR ' ||
                                'l_refresh_option_code ALL';
                                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                        END IF;
                        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_FP_TM_PHSD_CODE_NOT_FOUND');
                        retcode  := '2';
                        errbuff := 'PA_FP_TM_PHSD_CODE_NOT_FOUND';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           PA_DEBUG.Reset_Curr_Function;
                        END IF;
                END;
                IF (l_time_phased_code = 'P' and
                    l_req_id_tab(l_cnt)= l_request_id and
                    l_plan_proc_code_tab(l_cnt) = 'PPP' ) THEN
                --Knows that time phased code is PA
                --So, check for PA period profile passed to the API
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                                PA_DEBUG.g_err_stage := 'calling PP refresh for ' ||
                                'PA period : ';
                                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                                PA_DEBUG.g_err_stage := 'budget version id ' ||
                                to_char(l_budget_version_id) ||
                                ' period profile id :'||to_char(l_pa_period_profile_id);
                                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                        END IF;
                        IF l_pa_period_profile_id IS NOT NULL THEN
                        --Call the refresh period profile with PA profile ID
                                REFRESH_PERIOD_PROFILE
                                (
                                p_budget_version_id => l_budget_version_id,
                                p_period_profile_id => l_pa_period_profile_id,
                                p_project_id => l_project_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data
                                ) ;
                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             l_msg_data      := 'ERR_CALL_REFRESH_PERIOD_PROFILE';
                             retcode         := '2';
                             errbuff         := l_msg_data;
                           END IF;
                        END IF;
                ELSIF (l_time_phased_code = 'G' and
                       l_req_id_tab(l_cnt)= l_request_id and
                       l_plan_proc_code_tab(l_cnt) = 'PPP' ) THEN
                --Knows that time phased code is GL
                --So, check for GL period profile passed to the API
                        IF l_gl_period_profile_id IS NOT NULL THEN
                        --Call the refresh period profile with GL profile ID
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                                PA_DEBUG.g_err_stage := 'calling PP refresh for ' ||
                                'GL period : ';
                                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                                PA_DEBUG.g_err_stage := 'budget version id ' ||
                                to_char(l_budget_version_id) ||
                                ' period profile id :'||to_char(l_gl_period_profile_id);
                                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                        END IF;
                                REFRESH_PERIOD_PROFILE
                                (
                                p_budget_version_id => l_budget_version_id,
                                p_period_profile_id => l_gl_period_profile_id,
                                p_project_id => l_project_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data
                                ) ;
                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             l_msg_data      := 'ERR_CALL_REFRESH_PERIOD_PROFILE';
                             retcode         := '2';
                             errbuff         := l_msg_data;
                           END IF;
                        END IF;
                END IF;
        END LOOP;
		/* Changes for 7563735 - unsetting the locked_by_person_id here, depending on the return_status code*/
		if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		UPDATE pa_budget_versions SET
                       plan_processing_code = 'PPE',
                       locked_by_person_id  = null,
                       record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate,
					   REQUEST_ID = l_request_id
                WHERE
                       project_id = l_project_id  AND
                       locked_by_person_id ='-98'
					   AND period_profile_id IS NOT NULL;
		ELSE
         	UPDATE pa_budget_versions SET
                       plan_processing_code = 'PPG',
                       locked_by_person_id  = null,
                       record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate,
					   REQUEST_ID = l_request_id
                WHERE
                       project_id = l_project_id  AND
                       locked_by_person_id ='-98'
					   AND period_profile_id IS NOT NULL;
        end if;

		commit;
		/*End Changes for 7563735 - unsetting the locked_by_person_id here, depending on the return_status code*/
EXCEPTION
        WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_PRJ_PERIOD_PROFILE_UTILS.wrapper_refresh_pd_profile'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in wrapper_refresh_pd_profile ';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        retcode         := '2';
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        UPDATE_BUDGET_VERSION(p_budget_version_id => l_budget_version_id,
                              p_return_status     => l_return_status,
                              p_project_id        => p_project_id,
                              p_request_id        => l_request_id );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;
END Wrapper_Refresh_Pd_Profile;

-- +-----------------------------------------------------------------
-- PROCEDURE get_current_period_info - Revision History
-- 06-JAN-03 dlai: created-takes as input period_profile_id, and returns
--                 the period in which sysdate falls
-- 15-JAN-03 dlai: added a couple of flag values:
--    x_cur_period_number = -2, then the current date is BEFORE first period start date
--    x_cur_period_number = -1, then the current date is AFTER last period end date
procedure get_current_period_info
    (p_period_profile_id        IN      pa_proj_period_profiles.period_profile_id%TYPE,
     x_cur_period_number        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_cur_period_name          OUT     NOCOPY pa_proj_period_profiles.period_name1%TYPE, --File.Sql.39 bug 4440895
     x_cur_period_start_date    OUT     NOCOPY pa_proj_period_profiles.period1_start_date%TYPE, --File.Sql.39 bug 4440895
     x_cur_period_end_date      OUT     NOCOPY pa_proj_period_profiles.period1_end_date%TYPE, --File.Sql.39 bug 4440895
     x_return_status            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
as
  l_current_date    DATE;
  l_msg_data        VARCHAR2(1000);
  l_msg_index_out   NUMBER(15);

cursor period_profile_csr is
  select period_name1, period1_start_date, period1_end_date,
         period_name2, period2_start_date, period2_end_date,
         period_name3, period3_start_date, period3_end_date,
         period_name4, period4_start_date, period4_end_date,
         period_name5, period5_start_date, period5_end_date,
         period_name6, period6_start_date, period6_end_date,
         period_name7, period7_start_date, period7_end_date,
         period_name8, period8_start_date, period8_end_date,
         period_name9, period9_start_date, period9_end_date,
         period_name10, period10_start_date, period10_end_date,
         period_name11, period11_start_date, period11_end_date,
         period_name12, period12_start_date, period12_end_date,
         period_name13, period13_start_date, period13_end_date,
         period_name14, period14_start_date, period14_end_date,
         period_name15, period15_start_date, period15_end_date,
         period_name16, period16_start_date, period16_end_date,
         period_name17, period17_start_date, period17_end_date,
         period_name18, period18_start_date, period18_end_date,
         period_name19, period19_start_date, period19_end_date,
         period_name20, period20_start_date, period20_end_date,
         period_name21, period21_start_date, period21_end_date,
         period_name22, period22_start_date, period22_end_date,
         period_name23, period23_start_date, period23_end_date,
         period_name24, period24_start_date, period24_end_date,
         period_name25, period25_start_date, period25_end_date,
         period_name26, period26_start_date, period26_end_date,
         period_name27, period27_start_date, period27_end_date,
         period_name28, period28_start_date, period28_end_date,
         period_name29, period29_start_date, period29_end_date,
         period_name30, period30_start_date, period30_end_date,
         period_name31, period31_start_date, period31_end_date,
         period_name32, period32_start_date, period32_end_date,
         period_name33, period33_start_date, period33_end_date,
         period_name34, period34_start_date, period34_end_date,
         period_name35, period35_start_date, period35_end_date,
         period_name36, period36_start_date, period36_end_date,
         period_name37, period37_start_date, period37_end_date,
         period_name38, period38_start_date, period38_end_date,
         period_name39, period39_start_date, period39_end_date,
         period_name40, period40_start_date, period40_end_date,
         period_name41, period41_start_date, period41_end_date,
         period_name42, period42_start_date, period42_end_date,
         period_name43, period43_start_date, period43_end_date,
         period_name44, period44_start_date, period44_end_date,
         period_name45, period45_start_date, period45_end_date,
         period_name46, period46_start_date, period46_end_date,
         period_name47, period47_start_date, period47_end_date,
         period_name48, period48_start_date, period48_end_date,
         period_name49, period49_start_date, period49_end_date,
         period_name50, period50_start_date, period50_end_date,
         period_name51, period51_start_date, period51_end_date,
         period_name52, period52_start_date, period52_end_date
    from pa_proj_period_profiles
    where period_profile_id = p_period_profile_id;
period_profile_rec period_profile_csr%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  select sysdate
    into l_current_date
    from dual;
  open period_profile_csr;
  fetch period_profile_csr into period_profile_rec;
  if period_profile_csr%NOTFOUND then
    x_return_status := FND_API.G_RET_STS_ERROR;
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_INVALID_PRJ_PROFILE');
    x_msg_count := fnd_msg_pub.count_msg;
    IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.Get_Messages (
                  p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => 1 ,
                  p_msg_data       => l_msg_data ,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out );
    END IF;
  else
    if l_current_date < period_profile_rec.period1_start_date then
      x_cur_period_number := -2;
      x_cur_period_name := null;
      x_cur_period_start_date := null;
      x_cur_period_end_date := null;
    elsif l_current_date >= period_profile_rec.period1_start_date and l_current_date <= period_profile_rec.period1_end_date then
      x_cur_period_number := 1;
      x_cur_period_name := period_profile_rec.period_name1;
      x_cur_period_start_date := period_profile_rec.period1_start_date;
      x_cur_period_end_date := period_profile_rec.period1_end_date;
    elsif l_current_date >= period_profile_rec.period2_start_date and l_current_date <= period_profile_rec.period2_end_date then
      x_cur_period_number := 2;
      x_cur_period_name := period_profile_rec.period_name2;
      x_cur_period_start_date := period_profile_rec.period2_start_date;
      x_cur_period_end_date := period_profile_rec.period2_end_date;
    elsif l_current_date >= period_profile_rec.period3_start_date and l_current_date <= period_profile_rec.period3_end_date then
      x_cur_period_number := 3;
      x_cur_period_name := period_profile_rec.period_name3;
      x_cur_period_start_date := period_profile_rec.period3_start_date;
      x_cur_period_end_date := period_profile_rec.period3_end_date;
    elsif l_current_date >= period_profile_rec.period4_start_date and l_current_date <= period_profile_rec.period4_end_date then
      x_cur_period_number := 4;
      x_cur_period_name := period_profile_rec.period_name4;
      x_cur_period_start_date := period_profile_rec.period4_start_date;
      x_cur_period_end_date := period_profile_rec.period4_end_date;
    elsif l_current_date >= period_profile_rec.period5_start_date and l_current_date <= period_profile_rec.period5_end_date then
      x_cur_period_number := 5;
      x_cur_period_name := period_profile_rec.period_name5;
      x_cur_period_start_date := period_profile_rec.period5_start_date;
      x_cur_period_end_date := period_profile_rec.period5_end_date;
    elsif l_current_date >= period_profile_rec.period6_start_date and l_current_date <= period_profile_rec.period6_end_date then
      x_cur_period_number := 6;
      x_cur_period_name := period_profile_rec.period_name6;
      x_cur_period_start_date := period_profile_rec.period6_start_date;
      x_cur_period_end_date := period_profile_rec.period6_end_date;
    elsif l_current_date >= period_profile_rec.period7_start_date and l_current_date <= period_profile_rec.period7_end_date then
      x_cur_period_number := 7;
      x_cur_period_name := period_profile_rec.period_name7;
      x_cur_period_start_date := period_profile_rec.period7_start_date;
      x_cur_period_end_date := period_profile_rec.period7_end_date;
    elsif l_current_date >= period_profile_rec.period8_start_date and l_current_date <= period_profile_rec.period8_end_date then
      x_cur_period_number := 8;
      x_cur_period_name := period_profile_rec.period_name8;
      x_cur_period_start_date := period_profile_rec.period8_start_date;
      x_cur_period_end_date := period_profile_rec.period8_end_date;
    elsif l_current_date >= period_profile_rec.period9_start_date and l_current_date <= period_profile_rec.period9_end_date then
      x_cur_period_number := 9;
      x_cur_period_name := period_profile_rec.period_name9;
      x_cur_period_start_date := period_profile_rec.period9_start_date;
      x_cur_period_end_date := period_profile_rec.period9_end_date;
    elsif l_current_date >= period_profile_rec.period10_start_date and l_current_date <= period_profile_rec.period10_end_date then
      x_cur_period_number := 10;
      x_cur_period_name := period_profile_rec.period_name10;
      x_cur_period_start_date := period_profile_rec.period10_start_date;
      x_cur_period_end_date := period_profile_rec.period10_end_date;
    elsif l_current_date >= period_profile_rec.period11_start_date and l_current_date <= period_profile_rec.period11_end_date then
      x_cur_period_number := 11;
      x_cur_period_name := period_profile_rec.period_name11;
      x_cur_period_start_date := period_profile_rec.period11_start_date;
      x_cur_period_end_date := period_profile_rec.period11_end_date;
    elsif l_current_date >= period_profile_rec.period12_start_date and l_current_date <= period_profile_rec.period12_end_date then
      x_cur_period_number := 12;
      x_cur_period_name := period_profile_rec.period_name12;
      x_cur_period_start_date := period_profile_rec.period12_start_date;
      x_cur_period_end_date := period_profile_rec.period12_end_date;
    elsif l_current_date >= period_profile_rec.period13_start_date and l_current_date <= period_profile_rec.period13_end_date then
      x_cur_period_number := 13;
      x_cur_period_name := period_profile_rec.period_name13;
      x_cur_period_start_date := period_profile_rec.period13_start_date;
      x_cur_period_end_date := period_profile_rec.period13_end_date;
    elsif l_current_date >= period_profile_rec.period14_start_date and l_current_date <= period_profile_rec.period14_end_date then
      x_cur_period_number := 14;
      x_cur_period_name := period_profile_rec.period_name14;
      x_cur_period_start_date := period_profile_rec.period14_start_date;
      x_cur_period_end_date := period_profile_rec.period14_end_date;
    elsif l_current_date >= period_profile_rec.period15_start_date and l_current_date <= period_profile_rec.period15_end_date then
      x_cur_period_number := 15;
      x_cur_period_name := period_profile_rec.period_name15;
      x_cur_period_start_date := period_profile_rec.period15_start_date;
      x_cur_period_end_date := period_profile_rec.period15_end_date;
    elsif l_current_date >= period_profile_rec.period16_start_date and l_current_date <= period_profile_rec.period16_end_date then
      x_cur_period_number := 16;
      x_cur_period_name := period_profile_rec.period_name16;
      x_cur_period_start_date := period_profile_rec.period16_start_date;
      x_cur_period_end_date := period_profile_rec.period16_end_date;
    elsif l_current_date >= period_profile_rec.period17_start_date and l_current_date <= period_profile_rec.period17_end_date then
      x_cur_period_number := 17;
      x_cur_period_name := period_profile_rec.period_name17;
      x_cur_period_start_date := period_profile_rec.period17_start_date;
      x_cur_period_end_date := period_profile_rec.period17_end_date;
    elsif l_current_date >= period_profile_rec.period18_start_date and l_current_date <= period_profile_rec.period18_end_date then
      x_cur_period_number := 18;
      x_cur_period_name := period_profile_rec.period_name18;
      x_cur_period_start_date := period_profile_rec.period18_start_date;
      x_cur_period_end_date := period_profile_rec.period18_end_date;
    elsif l_current_date >= period_profile_rec.period19_start_date and l_current_date <= period_profile_rec.period19_end_date then
      x_cur_period_number := 19;
      x_cur_period_name := period_profile_rec.period_name19;
      x_cur_period_start_date := period_profile_rec.period19_start_date;
      x_cur_period_end_date := period_profile_rec.period19_end_date;
    elsif l_current_date >= period_profile_rec.period20_start_date and l_current_date <= period_profile_rec.period20_end_date then
      x_cur_period_number := 20;
      x_cur_period_name := period_profile_rec.period_name20;
      x_cur_period_start_date := period_profile_rec.period20_start_date;
      x_cur_period_end_date := period_profile_rec.period20_end_date;
    elsif l_current_date >= period_profile_rec.period21_start_date and l_current_date <= period_profile_rec.period21_end_date then
      x_cur_period_number := 21;
      x_cur_period_name := period_profile_rec.period_name21;
      x_cur_period_start_date := period_profile_rec.period21_start_date;
      x_cur_period_end_date := period_profile_rec.period21_end_date;
    elsif l_current_date >= period_profile_rec.period22_start_date and l_current_date <= period_profile_rec.period22_end_date then
      x_cur_period_number := 22;
      x_cur_period_name := period_profile_rec.period_name22;
      x_cur_period_start_date := period_profile_rec.period22_start_date;
      x_cur_period_end_date := period_profile_rec.period22_end_date;
    elsif l_current_date >= period_profile_rec.period23_start_date and l_current_date <= period_profile_rec.period23_end_date then
      x_cur_period_number := 23;
      x_cur_period_name := period_profile_rec.period_name23;
      x_cur_period_start_date := period_profile_rec.period23_start_date;
      x_cur_period_end_date := period_profile_rec.period23_end_date;
    elsif l_current_date >= period_profile_rec.period24_start_date and l_current_date <= period_profile_rec.period24_end_date then
      x_cur_period_number := 24;
      x_cur_period_name := period_profile_rec.period_name24;
      x_cur_period_start_date := period_profile_rec.period24_start_date;
      x_cur_period_end_date := period_profile_rec.period24_end_date;
    elsif l_current_date >= period_profile_rec.period25_start_date and l_current_date <= period_profile_rec.period25_end_date then
      x_cur_period_number := 25;
      x_cur_period_name := period_profile_rec.period_name25;
      x_cur_period_start_date := period_profile_rec.period25_start_date;
      x_cur_period_end_date := period_profile_rec.period25_end_date;
    elsif l_current_date >= period_profile_rec.period26_start_date and l_current_date <= period_profile_rec.period26_end_date then
      x_cur_period_number := 26;
      x_cur_period_name := period_profile_rec.period_name26;
      x_cur_period_start_date := period_profile_rec.period26_start_date;
      x_cur_period_end_date := period_profile_rec.period26_end_date;
    elsif l_current_date >= period_profile_rec.period27_start_date and l_current_date <= period_profile_rec.period27_end_date then
      x_cur_period_number := 27;
      x_cur_period_name := period_profile_rec.period_name27;
      x_cur_period_start_date := period_profile_rec.period27_start_date;
      x_cur_period_end_date := period_profile_rec.period27_end_date;
    elsif l_current_date >= period_profile_rec.period28_start_date and l_current_date <= period_profile_rec.period28_end_date then
      x_cur_period_number := 28;
      x_cur_period_name := period_profile_rec.period_name28;
      x_cur_period_start_date := period_profile_rec.period28_start_date;
      x_cur_period_end_date := period_profile_rec.period28_end_date;
    elsif l_current_date >= period_profile_rec.period29_start_date and l_current_date <= period_profile_rec.period29_end_date then
      x_cur_period_number := 29;
      x_cur_period_name := period_profile_rec.period_name29;
      x_cur_period_start_date := period_profile_rec.period29_start_date;
      x_cur_period_end_date := period_profile_rec.period29_end_date;
    elsif l_current_date >= period_profile_rec.period30_start_date and l_current_date <= period_profile_rec.period30_end_date then
      x_cur_period_number := 30;
      x_cur_period_name := period_profile_rec.period_name30;
      x_cur_period_start_date := period_profile_rec.period30_start_date;
      x_cur_period_end_date := period_profile_rec.period30_end_date;
    elsif l_current_date >= period_profile_rec.period31_start_date and l_current_date <= period_profile_rec.period31_end_date then
      x_cur_period_number := 31;
      x_cur_period_name := period_profile_rec.period_name31;
      x_cur_period_start_date := period_profile_rec.period31_start_date;
      x_cur_period_end_date := period_profile_rec.period31_end_date;
    elsif l_current_date >= period_profile_rec.period32_start_date and l_current_date <= period_profile_rec.period32_end_date then
      x_cur_period_number := 32;
      x_cur_period_name := period_profile_rec.period_name32;
      x_cur_period_start_date := period_profile_rec.period32_start_date;
      x_cur_period_end_date := period_profile_rec.period32_end_date;
    elsif l_current_date >= period_profile_rec.period33_start_date and l_current_date <= period_profile_rec.period33_end_date then
      x_cur_period_number := 33;
      x_cur_period_name := period_profile_rec.period_name33;
      x_cur_period_start_date := period_profile_rec.period33_start_date;
      x_cur_period_end_date := period_profile_rec.period33_end_date;
    elsif l_current_date >= period_profile_rec.period34_start_date and l_current_date <= period_profile_rec.period34_end_date then
      x_cur_period_number := 34;
      x_cur_period_name := period_profile_rec.period_name34;
      x_cur_period_start_date := period_profile_rec.period34_start_date;
      x_cur_period_end_date := period_profile_rec.period34_end_date;
    elsif l_current_date >= period_profile_rec.period35_start_date and l_current_date <= period_profile_rec.period35_end_date then
      x_cur_period_number := 35;
      x_cur_period_name := period_profile_rec.period_name35;
      x_cur_period_start_date := period_profile_rec.period35_start_date;
      x_cur_period_end_date := period_profile_rec.period35_end_date;
    elsif l_current_date >= period_profile_rec.period36_start_date and l_current_date <= period_profile_rec.period36_end_date then
      x_cur_period_number := 36;
      x_cur_period_name := period_profile_rec.period_name36;
      x_cur_period_start_date := period_profile_rec.period36_start_date;
      x_cur_period_end_date := period_profile_rec.period36_end_date;
    elsif l_current_date >= period_profile_rec.period37_start_date and l_current_date <= period_profile_rec.period37_end_date then
      x_cur_period_number := 37;
      x_cur_period_name := period_profile_rec.period_name37;
      x_cur_period_start_date := period_profile_rec.period37_start_date;
      x_cur_period_end_date := period_profile_rec.period37_end_date;
    elsif l_current_date >= period_profile_rec.period38_start_date and l_current_date <= period_profile_rec.period38_end_date then
      x_cur_period_number := 38;
      x_cur_period_name := period_profile_rec.period_name38;
      x_cur_period_start_date := period_profile_rec.period38_start_date;
      x_cur_period_end_date := period_profile_rec.period38_end_date;
    elsif l_current_date >= period_profile_rec.period39_start_date and l_current_date <= period_profile_rec.period39_end_date then
      x_cur_period_number := 39;
      x_cur_period_name := period_profile_rec.period_name39;
      x_cur_period_start_date := period_profile_rec.period39_start_date;
      x_cur_period_end_date := period_profile_rec.period39_end_date;
    elsif l_current_date >= period_profile_rec.period40_start_date and l_current_date <= period_profile_rec.period40_end_date then
      x_cur_period_number := 40;
      x_cur_period_name := period_profile_rec.period_name40;
      x_cur_period_start_date := period_profile_rec.period40_start_date;
      x_cur_period_end_date := period_profile_rec.period40_end_date;
    elsif l_current_date >= period_profile_rec.period41_start_date and l_current_date <= period_profile_rec.period41_end_date then
      x_cur_period_number := 41;
      x_cur_period_name := period_profile_rec.period_name41;
      x_cur_period_start_date := period_profile_rec.period41_start_date;
      x_cur_period_end_date := period_profile_rec.period41_end_date;
    elsif l_current_date >= period_profile_rec.period42_start_date and l_current_date <= period_profile_rec.period42_end_date then
      x_cur_period_number := 42;
      x_cur_period_name := period_profile_rec.period_name42;
      x_cur_period_start_date := period_profile_rec.period42_start_date;
      x_cur_period_end_date := period_profile_rec.period42_end_date;
    elsif l_current_date >= period_profile_rec.period43_start_date and l_current_date <= period_profile_rec.period43_end_date then
      x_cur_period_number := 43;
      x_cur_period_name := period_profile_rec.period_name43;
      x_cur_period_start_date := period_profile_rec.period43_start_date;
      x_cur_period_end_date := period_profile_rec.period43_end_date;
    elsif l_current_date >= period_profile_rec.period44_start_date and l_current_date <= period_profile_rec.period44_end_date then
      x_cur_period_number := 44;
      x_cur_period_name := period_profile_rec.period_name44;
      x_cur_period_start_date := period_profile_rec.period44_start_date;
      x_cur_period_end_date := period_profile_rec.period44_end_date;
    elsif l_current_date >= period_profile_rec.period45_start_date and l_current_date <= period_profile_rec.period45_end_date then
      x_cur_period_number := 45;
      x_cur_period_name := period_profile_rec.period_name45;
      x_cur_period_start_date := period_profile_rec.period45_start_date;
      x_cur_period_end_date := period_profile_rec.period45_end_date;
    elsif l_current_date >= period_profile_rec.period46_start_date and l_current_date <= period_profile_rec.period46_end_date then
      x_cur_period_number := 46;
      x_cur_period_name := period_profile_rec.period_name46;
      x_cur_period_start_date := period_profile_rec.period46_start_date;
      x_cur_period_end_date := period_profile_rec.period46_end_date;
    elsif l_current_date >= period_profile_rec.period47_start_date and l_current_date <= period_profile_rec.period47_end_date then
      x_cur_period_number := 47;
      x_cur_period_name := period_profile_rec.period_name47;
      x_cur_period_start_date := period_profile_rec.period47_start_date;
      x_cur_period_end_date := period_profile_rec.period47_end_date;
    elsif l_current_date >= period_profile_rec.period48_start_date and l_current_date <= period_profile_rec.period48_end_date then
      x_cur_period_number := 48;
      x_cur_period_name := period_profile_rec.period_name48;
      x_cur_period_start_date := period_profile_rec.period48_start_date;
      x_cur_period_end_date := period_profile_rec.period48_end_date;
    elsif l_current_date >= period_profile_rec.period49_start_date and l_current_date <= period_profile_rec.period49_end_date then
      x_cur_period_number := 49;
      x_cur_period_name := period_profile_rec.period_name49;
      x_cur_period_start_date := period_profile_rec.period49_start_date;
      x_cur_period_end_date := period_profile_rec.period49_end_date;
    elsif l_current_date >= period_profile_rec.period50_start_date and l_current_date <= period_profile_rec.period50_end_date then
      x_cur_period_number := 50;
      x_cur_period_name := period_profile_rec.period_name50;
      x_cur_period_start_date := period_profile_rec.period50_start_date;
      x_cur_period_end_date := period_profile_rec.period50_end_date;
    elsif l_current_date >= period_profile_rec.period51_start_date and l_current_date <= period_profile_rec.period51_end_date then
      x_cur_period_number := 51;
      x_cur_period_name := period_profile_rec.period_name51;
      x_cur_period_start_date := period_profile_rec.period51_start_date;
      x_cur_period_end_date := period_profile_rec.period51_end_date;
    elsif l_current_date >= period_profile_rec.period52_start_date and l_current_date <= period_profile_rec.period52_end_date then
      x_cur_period_number := 52;
      x_cur_period_name := period_profile_rec.period_name52;
      x_cur_period_start_date := period_profile_rec.period52_start_date;
      x_cur_period_end_date := period_profile_rec.period52_end_date;
    else
      -- current date falls AFTER last period end date
      x_cur_period_number := -1;
      x_cur_period_name := null;
      x_cur_period_start_date := null;
      x_cur_period_end_date := null;
    end if;
  end if;
  close period_profile_csr;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_PRJ_PERIOD_PROFILE_UTILS.get_current_period_info'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
    RAISE;
END get_current_period_info;


function has_preceding_periods
    (p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE) RETURN VARCHAR2
is
  l_return_value        VARCHAR2(1);
BEGIN
  l_return_value := 'N';
  select unique 'Y'
    into l_return_value
    from pa_budget_lines
    where budget_version_id = p_budget_version_id and
          bucketing_period_code = 'PD';
  return l_return_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return l_return_value;
END has_preceding_periods;


function has_succeeding_periods
    (p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE) RETURN VARCHAR2
is
  l_return_value        VARCHAR2(1);
BEGIN
  l_return_value := 'N';
  select unique 'Y'
    into l_return_value
    from pa_budget_lines
    where budget_version_id = p_budget_version_id and
          bucketing_period_code = 'SD';
  return l_return_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return l_return_value;
END has_succeeding_periods;

 PROCEDURE UPDATE_BUDGET_VERSION(p_budget_version_id IN NUMBER,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER ) IS
  l_plan_proc_code pa_budget_versions.plan_processing_Code%type;
  BEGIN
    if p_return_status  <>  FND_API.G_RET_STS_SUCCESS then
       l_plan_proc_code := 'PPE';
    else
       l_plan_proc_code := 'PPG';
    end if;
    IF p_project_id IS NOT NULL THEN
       UPDATE PA_BUDGET_VERSIONS
           SET PLAN_PROCESSING_CODE = l_plan_proc_code,
               locked_by_person_id  = NULL,
               record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate
       WHERE
               project_id = p_project_id and
               request_id = p_request_id and
               plan_processing_code = 'PPP';
    ELSE
       UPDATE PA_BUDGET_VERSIONS
           SET PLAN_PROCESSING_CODE = l_plan_proc_code,
               locked_by_person_id  = NULL,
               record_version_number = nvl(record_version_number,0) + 1,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                       LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_DATE  = sysdate
       WHERE
               budget_version_id = p_budget_version_id;
    END IF;
    COMMIT;
  END;


END PA_PRJ_PERIOD_PROFILE_UTILS;

/
