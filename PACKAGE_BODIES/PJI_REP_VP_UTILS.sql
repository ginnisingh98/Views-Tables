--------------------------------------------------------
--  DDL for Package Body PJI_REP_VP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_VP_UTILS" AS
/* $Header: PJIRX14B.pls 120.0 2005/05/29 12:33:09 appldev noship $ */

PROCEDURE Check_Plan_Version_Lock
(p_version_id NUMBER
, p_user_id NUMBER
, p_budget_forecast_flag VARCHAR2
, p_plan_type_code VARCHAR2
, x_lock_flag OUT NOCOPY VARCHAR2
, x_lock_msg OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2)
IS
l_is_locked_by_user_id VARCHAR2(1);
l_locked_by_person_id VARCHAR2(256);
BEGIN

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	Pa_Fin_Plan_Utils.Check_Locked_By_User
	(p_user_id,
	 p_version_id,
	 l_is_locked_by_user_id,
	 l_locked_by_person_id,
	 x_return_status,
	 x_msg_count,
	 x_msg_data);

    -- temporarily make it qualified
--    l_locked_by_person_id := NULL;
	IF (l_locked_by_person_id IS NULL) OR (l_is_locked_by_user_id = 'Y') THEN
		x_lock_flag := 'F';
		x_lock_msg := '';
	ELSE
		x_lock_flag := 'T';
		IF p_budget_forecast_flag = 'B' THEN
		   IF p_plan_type_code = 'COST_ONLY' THEN
		   	  Fnd_Message.SET_NAME('PJI', 'PJI_REP_COST_BDGT_LOCK');
		   ELSIF p_plan_type_code = 'REVENUE_ONLY'THEN
		      Fnd_Message.SET_NAME('PJI', 'PJI_REP_REV_BDGT_LOCK');
		   ELSE
		   	  Fnd_Message.SET_NAME('PJI', 'PJI_REP_COST_REV_BDGT_LOCK');
		   END IF;
		ELSE
		   IF p_plan_type_code = 'COST_ONLY' THEN
		   	  Fnd_Message.SET_NAME('PJI', 'PJI_REP_COST_FCST_LOCK');
		   ELSIF p_plan_type_code = 'REVENUE_ONLY'THEN
		      Fnd_Message.SET_NAME('PJI', 'PJI_REP_REV_FCST_LOCK');
		   ELSE
		   	  Fnd_Message.SET_NAME('PJI', 'PJI_REP_COST_REV_FCST_LOCK');
		   END IF;
		END IF;
		Fnd_Message.SET_TOKEN('USER_NAME',Pa_Fin_Plan_Utils.get_person_name(l_locked_by_person_id));
		x_lock_msg := Fnd_Message.GET;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Vp_Utils.Check_Plan_Version_Lock');
	RAISE;

END Check_Plan_Version_Lock;

PROCEDURE Get_currency_tip(
                           p_project_id         IN     NUMBER,
                           p_curr_type          IN     VARCHAR2,
                           p_version_type       IN     VARCHAR2,
                           x_tip_msg            OUT NOCOPY    VARCHAR2,
                           x_return_status      OUT NOCOPY    VARCHAR2,
                           x_msg_count          OUT NOCOPY    NUMBER  ,
                           x_msg_data           OUT NOCOPY    VARCHAR2
                         ) IS

l_prj_curr            VARCHAR2(30);
l_pfc_curr             VARCHAR2(30);

l_curr_text           VARCHAR2(60);
l_version_text        VARCHAR2(60);

l_curr_code          VARCHAR2(30);
l_curr_type_msg      fnd_new_messages.MESSAGE_TEXT%TYPE; /* commented and modified for bug 4133853 VARCHAR2(40); */

l_version_type_msg   fnd_new_messages.MESSAGE_TEXT%TYPE; /* commented and modified for bug 4133853 VARCHAR(60); */


BEGIN


	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

   SELECT project_currency_code,
          projfunc_currency_code
     INTO l_prj_curr,
          l_pfc_curr
     FROM pa_projects
    WHERE project_id = p_project_id;




    /* Record type id for the project currency code is 8
       PFC is 4 */

    IF (p_curr_type = '8') THEN

        l_curr_code        := l_prj_curr;
        l_curr_type_msg    := Fnd_Message.get_string('PJI', 'PJI_REP_PROJECT_CURR');

    ELSIF (p_curr_type = '4') THEN

        l_curr_code := l_pfc_curr;
        l_curr_type_msg   := Fnd_Message.get_string('PJI', 'PJI_REP_PFC_CURR');

    ELSE

        l_curr_code        := l_prj_curr;
        l_curr_type_msg    := Fnd_Message.get_string('PJI', 'PJI_REP_PROJECT_CURR');


    END IF;


    IF (p_version_type = 'COST') THEN

       l_version_type_msg := Fnd_Message.get_string('PJI', 'PJI_REP_DISPLAY_COST_VERSION');

    ELSIF (p_version_type = 'REVENUE') THEN

       l_version_type_msg := Fnd_Message.get_string('PJI', 'PJI_REP_DISPLAY_REV_VERSION');

    ELSE

       l_version_type_msg := NULL;

    END IF;


    Fnd_Message.set_name('PJI','PJI_REP_VP_CURR_TIP');

    Fnd_Message.set_token('CURRTYPE', l_curr_type_msg);
    Fnd_Message.set_token('CURRCODE',l_curr_code);
    Fnd_Message.set_token('VERSIONTYPE',l_version_type_msg);

    x_tip_msg := Fnd_Message.get;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
	Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NO_DATA_MSG', p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING, p_token1=>'ITEM_NAME', p_token1_value=>'tip bean message');
	WHEN OTHERS THEN
	x_msg_count := 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Vp_Utils.Get_Currency_Tip');
	RAISE;

END Get_currency_tip;


END Pji_Rep_Vp_Utils;

/
