--------------------------------------------------------
--  DDL for Package Body PA_INTERFACE_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INTERFACE_UTILS_PUB" as
--$Header: PAPMUTPB.pls 120.5.12010000.3 2008/11/10 08:53:57 jcgeorge ship $
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'PA_INTERFACE_UTILS_PUB';

PROCEDURE get_messages
(p_encoded        IN VARCHAR2 := FND_API.G_FALSE,
 p_msg_index      IN NUMBER   := FND_API.G_MISS_NUM,
 p_msg_count      IN NUMBER   := 1,
 p_msg_data       IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_data           OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
 p_msg_index_out  OUT NOCOPY NUMBER /*Added the nocopy check for 4537865 */
)  IS

--l_encoded     BOOLEAN;
l_data        VARCHAR2(2000);
l_msg_index   NUMBER;

BEGIN

  IF p_msg_index = FND_API.G_MISS_NUM THEN
     l_msg_index := FND_MSG_PUB.G_NEXT;
  ELSE
     l_msg_index := p_msg_index;
  END IF;

/* The comments put in to fix 1276810 in the previous version  have been
   removed to fix bug 962199. They are not needed since changes have been
   made in FND_MESSGAE package (File: AFNLMSGB.pls version 115.7) */

-- bug 1276810: remove the call to FND_MESSAGE.GET,
-- use FND_MSG_PUB.get to get the message text
-- for both single (p_msg_count = 1) and multiple
-- messages. changed in rel 11.5.

/*  IF p_msg_count = 1 THEN
     FND_MESSAGE.SET_ENCODED (p_msg_data);
     p_data := FND_MESSAGE.GET;
  ELSE */

    FND_MSG_PUB.get (
    p_msg_index      => l_msg_index,
    p_encoded        => p_encoded,
    p_data           => p_data,
    p_msg_index_out  => p_msg_index_out );
-- END IF;

EXCEPTION
WHEN OTHERS THEN
	p_data := NULL ;
	p_msg_index_out := NULL ;

	-- Did not include RAISE because this API is used to retrive error msg data
	-- In case of Exception ,just return the data as NULL .
END get_messages;

FUNCTION get_bg_id RETURN NUMBER IS
   X_business_group_id   NUMBER(15);
  BEGIN
    SELECT business_group_id
      INTO X_business_group_id
      FROM pa_implementations;

    RETURN(X_business_group_id);

END get_bg_id;

/** Bug 1940353 -  Added one IN parameter p_resp_appl_id in this procedure **/

PROCEDURE Set_Global_Info
          (p_api_version_number  IN NUMBER,
           p_responsibility_id   IN NUMBER := G_PA_MISS_NUM,
           p_user_id           IN NUMBER := G_PA_MISS_NUM,
           p_resp_appl_id      IN NUMBER := 275,
           p_advanced_proj_sec_flag IN VARCHAR2 := 'N',   --bug 2471668
           p_calling_mode      IN VARCHAR2 := 'AMG',    --bug 2783845
           p_operating_unit_id   IN NUMBER := G_PA_MISS_NUM, -- 4363092 Added for MOAC Changes
           p_msg_count          OUT NOCOPY NUMBER, /*Added the nocopy check for 4537865 */
           p_msg_data           OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
           p_return_status      OUT NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
) IS

-- This procedure sets the global values for User_id,login_id and
-- also populates the server side env variable CLIENT_INFO
-- with the relevant org id (for multi org purposes)

l_api_version_number    CONSTANT    NUMBER      :=  1.0;
l_api_name              CONSTANT    VARCHAR2(30):= 'Set_Global_Info';
l_value_conversion_error            BOOLEAN     :=  FALSE;
l_return_status                     VARCHAR2(1);
l_dummy         VARCHAR2(1);
l_temp_num              NUMBER ;

/** Bug 1940353 - Modified the cursor l_resp_csr to check the combination of
resposibility and application id. Commented out the cursor l_resp_appl_csr **/

CURSOR l_resp_csr IS
SELECT 'x'
FROM  fnd_responsibility
WHERE responsibility_id = p_responsibility_id
AND application_id = p_resp_appl_id;

/* Bug 1940353 - Commented the following cursor.

CURSOR l_resp_appl_csr IS
SELECT application_id
FROM  fnd_responsibility
WHERE responsibility_id = p_responsibility_id;
*/


CURSOR l_user_csr IS
SELECT 'x'
FROM fnd_user
WHERE user_id = p_user_id;
l_resp_csr_rec      l_resp_csr%ROWTYPE;
/* Bug 1940353 - l_resp_appl_csr_rec        l_resp_appl_csr%ROWTYPE; */

-- 4363092 MOAC Changes
l_msg_data varchar2(2000);
l_msg_count number;
l_ou_id number;
-- 4363092 end

BEGIN
  -- Standard Api compatibility call
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Ensure the responsibility id passed is valid
    IF p_responsibility_id IS NULL or p_responsibility_id =
       G_PA_MISS_NUM THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('PA','PA_RESP_ID_REQD');
        FND_MSG_PUB.add;
    END IF;

    RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN l_resp_csr;
    FETCH l_resp_csr INTO l_dummy;
    IF l_resp_csr%NOTFOUND THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('PA','PA_RESP_ID_INVALID');
          FND_MSG_PUB.add;
       END IF;
       CLOSE l_resp_csr;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE l_resp_csr;
    END IF;

  -- Ensure the user id passed is valid
    IF p_user_id IS NULL or p_user_id =
       G_PA_MISS_NUM THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('PA','PA_USER_ID_REQD');
        FND_MSG_PUB.add;
    END IF;

    RAISE FND_API.G_EXC_ERROR;
    END IF;


    OPEN l_user_csr ;
    FETCH l_user_csr INTO l_dummy;
    IF l_user_csr%NOTFOUND THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('PA','PA_USER_ID_INVALID');
          FND_MSG_PUB.add;
       END IF;
       CLOSE l_user_csr;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE l_user_csr;
    END IF;

 -- 07-NOV-97, jwhite ---------------------------------------------------

-- Based on the Responsibility, Intialize the Application

/* Bug 1940353 Begin-- Commented the following code(cursor Open, Fetch and Close).
the newly added parameter p_resp_appl_id is passed to Apps_initialize procedure */

/*    OPEN l_resp_appl_csr;
    FETCH l_resp_appl_csr INTO l_resp_appl_csr_rec;
    FND_GLOBAL.Apps_Initialize
        ( user_id           => p_user_id
          , resp_id             => p_responsibility_id
          , resp_appl_id    => l_resp_appl_csr_rec.application_id
        );
    CLOSE l_resp_appl_csr;
*/

        FND_GLOBAL.Apps_Initialize
                ( user_id               => p_user_id
                  , resp_id             => p_responsibility_id
                  , resp_appl_id        => p_resp_appl_id
                );

/* Bug 1940353 End */

        -- 4363092 MOAC Changes, Added code to do MO initialization and set the context to 'S'

        l_ou_id := p_operating_unit_id;

        PA_MOAC_UTILS.MO_INIT_SET_CONTEXT
                (
                    p_org_id          => l_ou_id
                  , p_product_code    => 'PA'
                  , p_msg_count       => l_msg_count
                  , p_msg_data        => l_msg_data
                  , p_return_status   => l_return_status
                );

        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR ;
        END IF ;

        -- 4363092 end

/*
Changed the call to the procedure Apps_Initalize to get the application Id
according to the responsibility and to avoide the hardcoding of the application id
FND_GLOBAL.Apps_Initialize
    (user_id            => p_user_id
      , resp_id             => p_responsibility_id
      , resp_appl_id    => 275
    );
*/

--bug 2471668
--Advanced Security model changes
--Initialize the global flag G_ADVANCED_PROJ_SEC_FLAG
  G_ADVANCED_PROJ_SEC_FLAG := p_advanced_proj_sec_flag;
--bug 2471668

-- Make Sure AMG Licensed
/* Commented out the AMG licensing. Please refer bug 2988747 for more info.
IF p_calling_mode <> 'PUBLISH'    --bug 2783845
THEN
   IF ( FND_PROFILE.Value('PA_AMG_LICENSED') IS NULL OR
     FND_PROFILE.Value('PA_AMG_LICENSED')  <> 'Y')
   THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('PA','PA_AMG_NOT_LICENSED');
        FND_MSG_PUB.add;
    END IF;

    RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF;
*/ --End bug 2988747

-- 11,13-NOV-97, jwhite:
-- Set HR Globals for Security Access
   HR_SECURITY_UTILS.Set_Custom_Schema;
-- -----------------------------------------------------------------------------

create_amg_mapping_msg;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN OTHERS
    THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

END Set_global_info;

PROCEDURE GET_DEFAULTS (p_def_char OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
            p_def_num OUT NOCOPY  NUMBER, /*Added the nocopy check for 4537865 */
                        p_def_date OUT NOCOPY DATE, /*Added the nocopy check for 4537865 */
                        p_return_status OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
                        p_msg_count     OUT NOCOPY NUMBER, /*Added the nocopy check for 4537865 */
                        p_msg_data   OUT NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
) IS

l_api_name              CONSTANT    VARCHAR2(30):= 'Get_Defaults';
BEGIN

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    p_def_char :=  G_PA_MISS_CHAR;
    p_def_num  :=  G_PA_MISS_NUM;
    p_def_date :=  G_PA_MISS_DATE;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

	-- 4537865
	p_def_char := NULL ;
	p_def_num:= NULL ;
	p_def_date := NULL ;

        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- 4537865
        p_def_char := NULL ;
        p_def_num:= NULL ;
        p_def_date := NULL ;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN OTHERS
    THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- 4537865
        p_def_char := NULL ;
        p_def_num:= NULL ;
        p_def_date := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

END GET_DEFAULTS;


PROCEDURE Get_Accum_Period_Info
    ( p_api_version_number      IN  NUMBER,
      p_project_id          IN  NUMBER,
      p_last_accum_period       OUT NOCOPY    VARCHAR2, /*Added the nocopy check for 4537865 */
      p_last_accum_start_date   OUT NOCOPY DATE, /*Added the nocopy check for 4537865 */
      p_last_accum_end_date     OUT NOCOPY DATE, /*Added the nocopy check for 4537865 */
      p_current_reporting_period    OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
      p_current_period_start_date   OUT NOCOPY  DATE, /*Added the nocopy check for 4537865 */
      p_current_period_end_date OUT NOCOPY DATE, /*Added the nocopy check for 4537865 */
          p_return_status       OUT NOCOPY     VARCHAR2, /*Added the nocopy check for 4537865 */
          p_msg_count           OUT NOCOPY     NUMBER, /*Added the nocopy check for 4537865 */
          p_msg_data            OUT NOCOPY     VARCHAR2 /*Added the nocopy check for 4537865 */
) IS
  --
  -- Cursor to select the previous accumulation period
  -- for the given project
  --
  CURSOR l_proj_csr IS
    SELECT accum_period
      FROM pa_project_accum_headers
     WHERE project_id = p_project_id
       AND task_id = 0
       AND resource_list_member_id = 0;

  l_api_version_number    CONSTANT    NUMBER      :=  1.0;
  l_api_name              CONSTANT    VARCHAR2(30):= 'Get_Accum_Period_Info';
  l_prev_accum_period   VARCHAR2(20) := NULL;
  l_impl_option     VARCHAR2(30);
  l_current_pa_period   VARCHAR2(20);
  l_current_gl_period   VARCHAR2(20);
  l_current_pa_start_date  DATE;
  l_current_pa_end_date    DATE;
  l_current_gl_start_date  DATE;
  l_current_gl_end_date    DATE;
  l_current_year    NUMBER;
  l_err_stack       VARCHAR2(630);
  l_err_stage       VARCHAR2(30);
  l_err_code        NUMBER;


BEGIN

  IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                       p_api_version_number   ,
                                       l_api_name             ,
                                       G_PKG_NAME             )  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the reporting period type, either 'PA' or 'GL'
  --
  PA_ACCUM_UTILS.Get_Impl_Option(
        x_impl_option   =>  l_impl_option,
        x_err_stack =>  l_err_stack,
        x_err_stage =>  l_err_stage,
        x_err_code  =>  l_err_code );


  OPEN l_proj_csr;
  FETCH l_proj_csr INTO l_prev_accum_period;

  IF (l_proj_csr%NOTFOUND or l_prev_accum_period IS NULL) THEN

    p_last_accum_period := NULL;
    p_last_accum_start_date := NULL;
    p_last_accum_end_date := NULL;

  ELSE

    p_last_accum_period := l_prev_accum_period;

    IF (l_impl_option = 'PA') THEN

      SELECT pa_start_date, pa_end_date
        INTO p_last_accum_start_date, p_last_accum_end_date
        FROM pa_periods_v
       WHERE period_name = l_prev_accum_period;

    ELSIF (l_impl_option = 'GL') THEN

      SELECT distinct gl_start_date, gl_end_date
        INTO p_last_accum_start_date, p_last_accum_end_date
        FROM pa_periods_v
       WHERE gl_period_name = l_prev_accum_period;

    END IF;

  END IF;

  CLOSE l_proj_csr;

  PA_ACCUM_UTILS.Get_Current_Period_Info (
        x_current_pa_period =>  l_current_pa_period,
        x_current_gl_period =>  l_current_gl_period,
        x_current_pa_start_date =>  l_current_pa_start_date,
        x_current_pa_end_date   =>  l_current_pa_end_date,
        x_current_gl_start_date =>  l_current_gl_start_date,
        x_current_gl_end_date   =>  l_current_gl_end_date,
        x_current_year      =>  l_current_year,
        x_err_stack     =>  l_err_stack,
        x_err_stage     =>  l_err_stage,
        x_err_code      =>  l_err_code );

  IF (l_impl_option = 'GL') THEN

    p_current_reporting_period  := l_current_gl_period;
    p_current_period_start_date := l_current_gl_start_date;
    p_current_period_end_date   := l_current_gl_end_date;

  ELSIF (l_impl_option = 'PA') THEN

    p_current_reporting_period  := l_current_pa_period;
    p_current_period_start_date := l_current_pa_start_date;
    p_current_period_end_date   := l_current_pa_end_date;

  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => p_msg_count,
      p_data  => p_msg_data
    );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;

      -- RESET OUT PARAMS : 4537865
      p_last_accum_period      := NULL ;
      p_last_accum_start_date  := NULL ;
      p_last_accum_end_date    := NULL ;
      p_current_reporting_period := NULL ;
      p_current_period_start_date   := NULL ;
      p_current_period_end_date := NULL;

    FND_MSG_PUB.Count_And_Get (
         p_count  =>    p_msg_count,
         p_data   =>    p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- RESET OUT PARAMS : 4537865
      p_last_accum_period      := NULL ;
      p_last_accum_start_date  := NULL ;
      p_last_accum_end_date    := NULL ;
      p_current_reporting_period := NULL ;
      p_current_period_start_date   := NULL ;
      p_current_period_end_date := NULL;

    FND_MSG_PUB.Count_And_Get (
         p_count  =>    p_msg_count,
         p_data   =>    p_msg_data );

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


      -- RESET OUT PARAMS : 4537865
      p_last_accum_period      := NULL ;
      p_last_accum_start_date  := NULL ;
      p_last_accum_end_date    := NULL ;
      p_current_reporting_period := NULL ;
      p_current_period_start_date   := NULL ;
      p_current_period_end_date := NULL;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

      FND_MSG_PUB.add_exc_msg (
                 p_pkg_name     => G_PKG_NAME,
         p_procedure_name   => l_api_name   );

    END IF;

    FND_MSG_PUB.Count_And_Get (
         p_count  =>    p_msg_count,
         p_data   =>    p_msg_data );

END Get_Accum_Period_Info;

PROCEDURE Get_Release_info (
     p_current_release           OUT NOCOPY  VARCHAR2, /*Added the nocopy check for 4537865 */
          p_return_status     OUT NOCOPY  VARCHAR2, /*Added the nocopy check for 4537865 */
          p_msg_count         OUT NOCOPY  NUMBER, /*Added the nocopy check for 4537865 */
          p_msg_data          OUT NOCOPY   VARCHAR2  /*Added the nocopy check for 4537865 */
) IS

--  This procedure returns information on which Applications Release
--  you are running against.
--  For example under Rel 10.7 the procedure returns the value
--  '10.7.0' and under Rel 11 the procedure returns the value
--  '11.0.28' . The release information is returned in the OUT parameter
--  p_current_release.

l_api_name              CONSTANT    VARCHAR2(30):= 'Get_Release_info';
l_rel_name              VARCHAR2(60);
l_other                 VARCHAR2(60);
l_ret_val               BOOLEAN;

BEGIN
   l_ret_val := FND_RELEASE.get_release
                            (RELEASE_NAME       => l_rel_name,
                             OTHER_RELEASE_INFO => l_other);

   IF l_ret_val THEN
      p_current_release := l_rel_name;
   ELSE
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR
   THEN

      p_return_status := FND_API.G_RET_STS_ERROR;

      -- RESET OUT PARAMS : 4537865
      p_current_release := NULL ;

      FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- RESET OUT PARAMS : 4537865
      p_current_release := NULL ;

   FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

   WHEN OTHERS
   THEN

   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- RESET OUT PARAMS : 4537865
      p_current_release := NULL ;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.add_exc_msg
            ( p_pkg_name      => G_PKG_NAME
            , p_procedure_name   => l_api_name  );

   END IF;

   FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

END Get_Release_info;

-------------------------------------------------------------
-- Name     :create_amg_mapping_msg
-- Type     :PL/SQL Procedure
--Description   :This procedure will populate the pl/sql table
--              using old message code and new message
--                with message context.
--
-- Called Subprograms:
--
-- History  :03/17/98   Sakthivel Balasubramanian   Created
--
-- Message format :   create_amg_mapping_message ()
-------------------------------------------------------------
PROCEDURE create_amg_mapping_msg
IS

    i           NUMBER := 1;

BEGIN

--  PAPMPRPB.pls procedure create_project

    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CUSTOMER_NOT_OVERRIDABLE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CUST_NOT_OVERRIDABLE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_DESCRIPTION_NOT_OVERRIDABLE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_DESC_NOT_OVERRIDABLE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_GET_CUSTOMER_INFO_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_GET_CUST_INFO_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NAME_NOT_UNIQUE_A_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDP';


    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NUM_NOT_UNIQUE_A_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_SOURCE_TEMPLATE_IS_MISSING';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_SOURCE_TEMP_IS_MISSING_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NAME_NOT_UNIQUE_M_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'MODP';

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NUM_NOT_UNIQUE_M_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'MODP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_INVALID_COMPLETION_DATE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_INVALID_COMP_DATE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'TASK';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CHANGE_TASK_NUM_OK_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CHANGE_TK_NUM_OK_FAIL_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'MODT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CHECK_ADD_SUBTASK_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CHECK_ADD_ST_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CHECK_DEL_PROJECT_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CHECK_DEL_PR_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CHECK_DELETE_TASK_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CHECK_DEL_TK_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

        -- 4096218
        i := i + 1;
        pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PS_TASK_HAS_PROG';
        pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PS_TASK_HAS_PROG_AMG' ;
        pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_ROLE_TYPE_NOT_OVERRIDABLE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_ROLE_TYPE_NOT_OVER_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CLASS_CAT_NOT_OVERRIDABLE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CLASS_CAT_NOT_OVER_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TK_OUTSIDE_PROJECT_RANGE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TK_OUTSIDE_PROJ_RANGE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'TASK';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJECT_REF_AND_ID_MISSING';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_REF_AND_ID_MISSING_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TOP_TASK_CHILD_NO_DELETE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TOP_TK_CHILD_NO_DEL_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'TASK';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_INV_IND_RATE_SCH_ID_REQD';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_INV_IND_RT_SCH_ID_REQD_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_INVALID_NON_LABOR_SCH_TYPE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_INV_NON_LAB_SCH_TYPE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NON_LBR_ORG_ID_NOT_VALID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NON_LBR_ORG_ID_NT_VALID_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_REV_IND_RATE_SCH_ID_REQD';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_REV_IND_RT_SCH_ID_REQD_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

   i := i+1;
   pa_pm_message_amg_tbl(i).p_old_message_code  := 'PA_PARENT_COMPLETION_EARLIER';
   pa_pm_message_amg_tbl(i).p_new_message_code  := 'PA_PARENT_COMPL_EARLIER_AMG';
   pa_pm_message_amg_tbl(i).p_msg_context          := 'TASK';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_RESOURCE_LIST_IS_MISSING';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_RES_LIST_IS_MISSING_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BUGDET_LINE_INDEX_MISSING';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BUGD_LINE_INDEX_MISS_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BUDGET_PERIOD_IS_INVALID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BUDGET_PERIOD_IS_INV_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_CALC_BURDENED_COST_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_CALC_BURD_COST_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_GET_DRAFT_VERSION_FAILED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_GET_DRAFT_VER_FAILED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BUDGET_LINE_ALREADY_EXISTS';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BUD_LINE_ALREADY_EXISTS_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TASK_IS_NOT_TOP_OR_LOWEST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TASK_IS_NOT_TOP_OR_LOW_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'TASK';

-- lower level API's

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NAME_NOT_UNIQUE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i + 1; /***Added for 3650505**/
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_INVALID_CLASS_CATEGORY';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_INVALID_CLASS_CATEGORY_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    /**changed ended for 3650505**/

    i := i + 1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NUM_NOT_UNIQUE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BU_AMT_ALLOC_LT_AMT_ACCRUED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BU_AMT_ALLOC_LT_ACCR_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BU_UNBALANCED_PROJ_BUDGET';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BU_UNBAL_PROJ_BUDG_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_BU_UNBALANCED_TASK_BUDGET';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_BU_UNBAL_TASK_BUDG_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TASK_FUND_NO_PROJ_EVENTS';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TASK_FUND_NO_PROJ_EVT_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'BUDG';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_TASK_ID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_TASK_ID_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TASK_BURDEN_SUM_DEST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TASK_BURDEN_SUM_DEST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_AP_INV_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_AP_INV_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_BUDGET_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_BUDGET_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_CMT_TXN_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_CMT_TXN_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_COMP_RULE_SET_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_RULE_SET_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_EVENT_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_EVENT_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_EXP_ITEM_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_EXP_ITEM_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_FUND_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_FUND_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_PO_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_PO_DIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_PO_REQ_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_PO_REQ_DIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_TASK_ID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_TASK_ID_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_TOP_TASK_ID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_TOP_TASK_ID_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_BURDEN_SUM_DEST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_BURDEN_SUM_DEST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_ASSET_ASSIGNMT_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_ASSETASSIG_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_BUDGET_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_BUDGET_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_BURDEN_SCH_OVRIDE_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_BUR_SCHOVR_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_JOB_BILL_RATE_O_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_JBILL_RATE_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_LABOR_MULTIPLIER_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_LAB_MULT_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_NL_BILL_RATE_O_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_NLBIL_RAT_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_PCT_COMPL_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_PCT_COMPL_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

   i := i+1;
   pa_pm_message_amg_tbl(i).p_old_message_code  := 'PA_TSK_PCT_COMPL_EXIST';
   pa_pm_message_amg_tbl(i).p_new_message_code  := 'PA_TSK_PCT_COMPL_EXIST_D_AMG';
   pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_TXN_CONST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_TXN_CONST_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_JOB_BILL_TITLE_O_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_JBILLTITLE_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_JOB_ASSIGNMENT_O_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_JOBASSIG_O_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_EXP_ITEM_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_EXP_ITEM_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_PO_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_PO_DIST_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_PO_REQ_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_PO_REQDIST_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_AP_INV_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_AP_INV_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_AP_INV_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_APINV_DIST_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_PROJ_ID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_PROJ_ID_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_AP_INV_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_INV_DIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_AP_INV_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_AP_INV_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_BUDGET_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_BUDGET_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_BURDEN_SUM_DEST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_BURDEN_SUM_DEST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_CMT_TXN_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_CMT_TXN_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_COMP_RULE_SET_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_COM_RUL_SET_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_CREATED_REF_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_CREATED_REF_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

    i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_EVENT_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_EVENT_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_EXP_ITEM_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_EXP_ITEM_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_FUND_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_FUND_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_IN_USE_EXTERNAL';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_IN_USE_EXTERNAL_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_PO_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_PO_DIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_PO_REQ_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_PORDIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELP';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TASK_IN_USE_EXTERNAL';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TASK_IN_USE_EXTERNAL_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_AP_INV_DIST_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_AP_INV_DIST_EXIST_D_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'DELT';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TASK_BURDEN_SUM_DEST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TASK_BURDEN_SUM_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_EMP_BILL_RATE_O_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_EBILLRATE_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_LABOR_COST_MUL_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_LCOST_MUL_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_TXN_CONT_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_TXN_CONT_EXIST_ST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';

/* Added this part of code as fix for bug 1538208 */
/* start of fix */
i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_TSK_CC_PROJ_EXIST';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_TSK_CC_PROJ_ST_EXIST_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'ADDST';
/* End of fix */
i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_ORIG_PROJ_ID';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_ORIG_PROJ_ID_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_NO_PROJ_CREATED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_NO_PROJ_CREATED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_NO_PROJ_NAME';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NO_PROJ_NAME_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_NO_PROJ_NUM';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_NO_PROJ_NUM_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PR_START_DATE_NEEDED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_START_DATE_NEEDED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJ_ORG_NOT_ACTIVE';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PROJ_ORG_NOT_ACTIVE_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_SU_INVALID_DATES';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_SU_INVALID_DATES_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'PROJ';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_FUNCTION_SECURITY_ENFORCED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_FUNC_SECURITY_ENFORCED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

i := i+1;
    pa_pm_message_amg_tbl(i).p_old_message_code     := 'PA_PROJECT_SECURITY_ENFORCED';
    pa_pm_message_amg_tbl(i).p_new_message_code     := 'PA_PR_SECURITY_ENFORCED_AMG';
    pa_pm_message_amg_tbl(i).p_msg_context          := 'GENERAL';

    RETURN;

END create_amg_mapping_msg;

-----------------------------------------------------------
-- Name     :Get_new_message_code
-- Type     :PL/SQL Procedure
--Description   :This objective of this API is to get new
--              message code mapped with old message code
--                and message context.
--
-- Called Subprograms:
--
-- History  :03/17/98   Sakthivel Balasubramanian   Created
--
-- Message format : get_new_message_code()
-----------------------------------------------------------

FUNCTION get_new_message_code
( p_message_code        IN  VARCHAR2    :=FND_API.G_FALSE
 ,p_msg_context    IN   VARCHAR2    := FND_API.G_FALSE
) RETURN VARCHAR2
IS
    p_new_message_code  VARCHAR2(50);
    i                       NUMBER  :=1;
    tot_num_record         NUMBER   :=0;
BEGIN

    IF pa_pm_message_amg_tbl.EXISTS(1) THEN
      tot_num_record    := pa_pm_message_amg_tbl.COUNT;
    END IF;

   FOR i  IN 1.. tot_num_record
   LOOP

        IF pa_pm_message_amg_tbl(i).p_old_message_code = p_message_code
        AND pa_pm_message_amg_tbl(i).p_msg_context = p_msg_context
        THEN
           p_new_message_code := pa_pm_message_amg_tbl(i).p_new_message_code;
           exit;
        END IF;

   END LOOP;

   IF p_new_message_code IS NULL
   THEN
      --FND_MESSAGE.SET_NAME('PA','PA_PR_NO_NEW_MESSAGE_CODE');
/*  We just need to return the message. map_new_amg_msg will add this message to stack
    Dicussed with Sakthi.
      FND_MESSAGE.SET_NAME('PA', p_message_code);
      FND_MSG_PUB.add;
      APP_EXCEPTION.RAISE_EXCEPTION;
*/
      RETURN p_message_code;
   ELSE
       RETURN (p_new_message_code);
   END IF;

END get_new_message_code;

------------------------------------------------------------------
-- Name     :map_new_amg_msg
-- Type     :PL/SQL Procedure
-- Description  :This procedure will map old message with pl/sql
--              table and display new meaningful
--                message to user.
--
-- Called Subprograms:
--
-- History  :03/17/98   Sakthivel Balasubramanian   Created
--
-- Message format :
--map_new_amg_msg ( 'Message_Code','CHANGE/SPLIT', 'Y/N',
--                  'GENERAL/ADDP/MODP/DELP/PROJ/ADDB/MODB/DELB/BUDG/
--                  ADDT/MODT/DELT/TASK/ADDST/MODST/DELST',
--                  '','','','','');
------------------------------------------------------------------

PROCEDURE map_new_amg_msg
( p_old_message_code        IN  VARCHAR2    :=FND_API.G_FALSE
 ,p_msg_attribute           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_resize_flag         IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_context         IN  VARCHAR2    := FND_API.G_FALSE
 ,p_attribute1          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_attribute2          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_attribute3          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_attribute4          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_attribute5          IN  VARCHAR2    := FND_API.G_FALSE
)
IS
    p_new_message_code  VARCHAR2(50);
    i                       BINARY_INTEGER  := 1000;
  l_msg_count_index              NUMBER;
  l_msg_count                    NUMBER;
  l_data                         VARCHAR2(2000);
BEGIN

--  p_old_message_code is mandatory
  --Added below if condition for bug 4762153
  IF p_msg_attribute = 'NOCHANGE'
   THEN
	   p_new_message_code := p_old_message_code;
  END IF;
  IF p_msg_attribute = 'CHANGE' AND p_resize_flag = 'N'
   THEN
       p_new_message_code := p_old_message_code || '_AMG';
   ELSIF p_msg_attribute = 'CHANGE' AND p_resize_flag = 'Y'
   THEN
--get the new error message code associated to the old
--message code and p_msg_context
      p_new_message_code := get_new_message_code(p_old_message_code,
                            p_msg_context);
   ELSIF p_msg_attribute = 'SPLIT' AND p_resize_flag = 'Y'
   THEN
--get the new error message code associated to the old
--message code and p_msg_context
      p_new_message_code := get_new_message_code(p_old_message_code,
                            p_msg_context);
   ELSIF p_msg_attribute = 'SPLIT' AND p_resize_flag = 'N'
   THEN
        IF p_msg_context in ('ADDP','ADDB','ADDT')
        THEN
            p_new_message_code := p_old_message_code || '_A'||'_AMG';
       ELSIF p_msg_context in ('MODP','MODB','MODT')
        THEN
            p_new_message_code := p_old_message_code || '_M'||'_AMG';
       ELSIF p_msg_context in ('DELP','DELB','DELT')
        THEN
            p_new_message_code := p_old_message_code || '_D'||'_AMG';
       ELSIF p_msg_context in ('ADDST','MODST','DELST')
        THEN
             IF p_msg_context = 'ADDST'
             THEN
               p_new_message_code := p_old_message_code || '_ST'||'_AMG';
           ELSIF p_msg_context = 'MODST'
             THEN
               p_new_message_code := p_old_message_code || '_MT'||'_AMG';
           ELSIF p_msg_context = 'DELST'
           THEN
               p_new_message_code := p_old_message_code || '_DT'||'_AMG';
           END IF;
       END IF;
   END IF;

   FND_MESSAGE.SET_NAME('PA',p_new_message_code);

   -- <Bug#2840688>
   IF (p_new_message_code <> p_old_message_code)
   THEN
   -- <Bug#2840688>

    -- ***********START MODIFICATIONS FOR THE AGREEMENT AND FUNDING AMG API's

      IF p_msg_context in ('AGREEMENT')
      THEN
              FND_MESSAGE.SET_TOKEN('AGREEMENT',  p_attribute1);
      -- p_attribute1 = agreement_reference
      END IF;

      IF p_msg_context in ('FUNDING')
      THEN
              FND_MESSAGE.SET_TOKEN('FUNDING',  p_attribute2);
      -- p_attribute2 = funding_reference
      END IF;

      -- **********END MODIFICATIONS FOR THE AGREEMENT AND FUNDING AMG API's

    -- ***********START MODIFICATIONS FOR THE EVENT AMG API's
      IF p_msg_context in ('EVENT')
      THEN
              FND_MESSAGE.SET_TOKEN('EVENT',  p_attribute1);
      END IF;

      -- **********END MODIFICATIONS FOR THE EVENT AMG API's
      /* Added EVENT check for bug#3009144 */
      IF p_msg_context not in ('GENERAL','AGREEMENT','FUNDING','EVENT')
      THEN
       FND_MESSAGE.SET_TOKEN('PROJECT',  p_attribute1);
   -- p_attribute1 = project_id
      END IF;

    IF p_msg_context in ('ADDT','MODT','DELT','TASK',
                           'ADDST','MODST','DELST')
    THEN
       FND_MESSAGE.SET_TOKEN('TASK',  p_attribute2);
   -- p_attribute2 = task_id
    ELSIF p_msg_context in ('ADDB','MODB','DELB','BUDG')
    THEN
        FND_MESSAGE.SET_TOKEN('TASK',  p_attribute2);
   -- p_attribute2 = task_id
        FND_MESSAGE.SET_TOKEN('BUDGET_TYPE',  p_attribute3);
   -- p_attribute3 = budget_type
        FND_MESSAGE.SET_TOKEN('SOURCE_NAME',  p_attribute4);
   -- p_attribute4 = resource_name
        FND_MESSAGE.SET_TOKEN('START_DATE',  p_attribute5);
   -- p_attribute5 = start_date
    END IF;

      END IF; --<Bug#2840688/>
   FND_MSG_PUB.add;
    RETURN;

END map_new_amg_msg;

------------------------------------------------------------------
-- Name     :get_task_number_amg
-- Type     :PL/SQL Procedure
-- Description  :This function will get task number to calling
--              procedure.
--
-- Called Subprograms:
--
-- History  :03/17/98   Sakthivel Balasubramanian   Created
--
-- Message format :
--
--get_task_number_amg ( task_number, task_reference, task_id);
--
------------------------------------------------------------------

FUNCTION get_task_number_amg
( p_task_number         IN VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_task_reference      IN  VARCHAR2    := FND_API.G_MISS_CHAR
 ,p_task_id               IN    VARCHAR2    := FND_API.G_MISS_CHAR
)
RETURN VARCHAR2 IS

    p_result_task_number        VARCHAR2(50);
    p_result_task_name          VARCHAR2(20);
    p_result_task_reference         VARCHAR2(25);
   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_name,
            pm_task_reference
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

    p_result_task_number := NULL;

    IF p_task_number IS NOT NULL and p_task_reference IS NOT NULL
    THEN
       p_result_task_number	:= substrb(p_task_number,1,20)||'-'||p_task_reference; --Bug 5733285. Added substrb
    ELSIF  p_task_id IS NOT NULL AND p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- Bug 6518944
    THEN
     OPEN l_amg_task_csr( p_task_id );
     FETCH l_amg_task_csr INTO p_result_task_name, p_result_task_reference;
     CLOSE l_amg_task_csr;
       p_result_task_number := p_result_task_name||'-'||p_result_task_reference;
    END IF;

     RETURN(p_result_task_number);

END get_task_number_amg;

END PA_INTERFACE_UTILS_PUB;

/
